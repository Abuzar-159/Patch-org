/* Changes made on 07/07/2023 by shaguftha 
* Issue : logistic Qty was updating twice
* fix :  getCreateLogistic commented 861-907
*
* Changed by Arshad 10 Aug 2023
* Reason - order to logistic flow enhancement -
*       if MOs or POs created for any specific orders, consider those inventory stock records first to be reserved for stock outward (batch or serial associted with that specific order to be reserved first)- should also work for partial or full qty.
*       if not fullfilled by above MOs or POs inventory stock records, consider non MOs POs inventory list for either remaining partial or full qty.
*       if still cannot be fullfiled after all this, throws No Stock available error.
* method - getCreateLogistic
*
* Changed by Arshad 26 Oct 2023
* Reason - To include return shipping type & speed, return billing options flow
* 
*/
 
public with sharing class SalesOrderToLogistic {
    @AuraEnabled public ERP7__Logistic__c Logistic                { get;set;}
    @AuraEnabled public ERP7__Logistic_Line_Item__c LogisticLI    { get;set;}
    @AuraEnabled public list<SelectOption> LogisticTypeList        { get;set;} 
    @AuraEnabled public list<ERP7__Sales_Order_Line_Item__c> SoliList  {get;set;}
    @AuraEnabled public list<ERP7__Purchase_Line_Items__c> POList  {get;set;}
    @AuraEnabled public list<OrderItem> OrdList  {get;set;}
    @AuraEnabled public  ERP7__Sales_Order__c SO                       {get;set;}
    @AuraEnabled public  Order Ord                                       {get;set;}
    @AuraEnabled public  ERP7__PO__c PO                       {get;set;}
    @AuraEnabled public String DistributeChannelId                     {get;set;}
     @AuraEnabled public String fromContact                             {get;set;}
    @AuraEnabled public Boolean isReadyToPickPack                      {get;set;}
    @AuraEnabled public Boolean showReadyToShip                      {get;set;}
    @AuraEnabled public Boolean  allowEdit                              {get;set;}
    @AuraEnabled public Boolean  dontallowChannelRemove                                 {get;set;}
    @AuraEnabled public Boolean   showShipmentDetails   {get;set;}
    @AuraEnabled public Boolean   ShowReturnShipSection   {get;set;}
    @AuraEnabled public List <bomwrapper>   BOMS   {get;set;}
    @AuraEnabled public String ordId {get;set;}
    
    
    public SalesOrderToLogistic(){ 
        LogisticTypeList=new list<SelectOption>();
        OrdList = new list<OrderItem>();
        SoliList=new list<ERP7__Sales_Order_Line_Item__c>();
        SO=new ERP7__Sales_Order__c();
        isReadyToPickPack=false; showReadyToShip=false;
        POList=new list<ERP7__Purchase_Line_Items__c>();
        PO=new ERP7__PO__c();
        BOMS  = new List <bomwrapper>();
        allowEdit = true;
        dontallowChannelRemove  = true;
        showShipmentDetails = ShowReturnShipSection = false;
    } 
    
    public class SelectOption {
        @AuraEnabled public String value { get;set; }  
        @AuraEnabled public String label { get;set; }
        @AuraEnabled public String defaultValue { get;set; }
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;     
        } 
        public SelectOption(String value, String label, String defaultValue) {
            this.value = value;
            this.label = label;   
            this.defaultValue = defaultValue;
        } 
    }
    
    @AuraEnabled
    Public Static SalesOrderToLogistic getInstances(){     
        SalesOrderToLogistic so=new SalesOrderToLogistic();
        so.Logistic=new ERP7__Logistic__c();
        so.LogisticLI=new ERP7__Logistic_Line_Item__c();
        
        list<SelectOption> tolList=new list<SelectOption>();
        tolList.add(new SelectOption('','-- None --')); 
        List<Schema.PicklistEntry> tolValues = Schema.sObjectType.ERP7__Logistic__c.Fields.ERP7__Type__c.getPickListValues();       
        for(Schema.PicklistEntry a:tolValues) tolList.add(new SelectOption(a.getValue(),a.getLabel())); 
        so.LogisticTypeList=tolList;
        
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());  
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance(); 
        }
        if(FC != null){ 
            so.showReadyToShip =FC.ERP7__showReadyToShipMLog__c;
            so.allowEdit = FC.ERP7__Allow_Edit_of_Logistic_and_it_s_item_Nam__c;
            so.dontallowChannelRemove  = FC.ERP7__Restrict_Selected_Channel__c;
            so.showShipmentDetails = FC.ERP7__Show_Ship_Details_in_Orders_to_Logistic__c;
            so.ShowReturnShipSection = FC.ERP7__ShowReturnShipSection__c;
        }            
        return so; 
    }
    
  @AuraEnabled
    public static SalesOrderToLogistic getPOItemList(String POId){ System.debug('in getPOItemList');
        SalesOrderToLogistic PO=new SalesOrderToLogistic();
        if(String.isNotEmpty(POId)){
            // matheen added ERP7__Vendor_Address__c in this query for GIIH 683
            ERP7__PO__c POrd=[Select Id,Name,ERP7__Channel__c,ERP7__Distribution_Channel__c,ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Primary_Contact__c,ERP7__Distribution_Channel__r.ERP7__Site__r.ERP7__Address__c,ERP7__Vendor__c,ERP7__Vendor_Contact__c,ERP7__Vendor_Address__c,ERP7__Shipment_Type__c,ERP7__Shipment_Preference_Speed__c from ERP7__PO__c Where Id =:POId];
            PO.PO=Pord;
            
            List<ERP7__Purchase_Line_Items__c> POItemList=[SELECT Id, Name , ERP7__Product__c, ERP7__Product__r.Name,ERP7__Product__r.ERP7__Track_Inventory__c, ERP7__Quantity__c, ERP7__Unit_Price__c, ERP7__Tax__c, 
                                                           ERP7__Site__c,ERP7__Active__c,ERP7__Picked_Quantity__c,ERP7__Packed_Quantity__c,ERP7__Logistic_Quantity__c,ERP7__Remaining_Quantity__c,
                                                           ERP7__Purchase_Orders__r.Name,ERP7__Purchase_Orders__r.ERP7__Ready_To_Pick_Pack__c,ERP7__Purchase_Orders__r.ERP7__Ready_To_Receive__c 
                                                           FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c=:POId AND ERP7__Product__c!=Null];           
            //Set<String> POLIIds=new Set<String>(); 
            List<ERP7__Purchase_Line_Items__c> POItmToReturn=new List<ERP7__Purchase_Line_Items__c>();
            for(ERP7__Purchase_Line_Items__c POLI:POItemList){
                //POLIIds.add(POLI.Id);
                if(POLI.ERP7__Quantity__c != POLI.ERP7__Logistic_Quantity__c){
                    if(POLI.ERP7__Logistic_Quantity__c == null) POLI.ERP7__Logistic_Quantity__c=0;
                    POItmToReturn.add(POLI);
                }                   
            }            
            PO.POList=POItmToReturn;
            
        }
        System.debug('po '+PO);
        return PO;
    }
    
    @AuraEnabled
    public static List<String> getBillingOptions(){ List<String> options = new List<String>(); Schema.DescribeFieldResult fieldResult = ERP7__Logistic__c.ERP7__Bill_To_Return__c .getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(f.getLabel());} return options; }
    
    @AuraEnabled
    Public Static SalesOrderToLogistic getordItemList(String orderId){ //, String DistributeChannelId
        SalesOrderToLogistic so=new SalesOrderToLogistic(); 
        try{ 
            if(String.isNotEmpty(orderId)){  
                list<OrderItem> SoliList=new list<OrderItem>();       
                SoliList=[SELECT Id , Product2Id, Product2.Name,UnitPrice,Product2.ERP7__Track_Inventory__c,Product2.ERP7__Is_Kit__c, Quantity, ERP7__Base_Price__c, ERP7__VAT_Amount__c, ERP7__Discount_Amount__c ,
                          OrderItemNumber,OrderId,Order.Name, Order.ERP7__Ready_To_Pick_Pack__c, ERP7__Site__c, ERP7__Active__c, ERP7__Logistic_Quantity__c,ERP7__Version__c,ERP7__Inventory_Tracked__c,ERP7__Is_Kit__c,ERP7__PriceBookId__c,
                          ERP7__Picked_Quantity__c, ERP7__Packed_Quantity__c, ERP7__Shipped_Quantity__c, ERP7__Reserved_Quantity__c,ERP7__Remaining_Quantity__c 
                          FROM OrderItem WHERE OrderId=:orderId AND Product2Id != Null AND (Product2.ERP7__Track_Inventory__c=true OR Product2.ERP7__Is_Kit__c=true)]; //  AND ERP7__Site__c=:dc.ERP7__Site__c   //ERP7__Site__c='a2B1o000001pkxzEAA' 
                
                list<OrderItem> trackinventoryProds =new list<OrderItem>();
                list<OrderItem> nontrackinventoryProds =new list<OrderItem>();
                
                set<String> SoliIds=new set<String>();            
                for(OrderItem s:SoliList) SoliIds.add(s.Id); 
                
                for(Integer i=0; i<SoliList.size(); i++) SoliList[i].ERP7__Active__c=false;        
                
                list<ERP7__Logistic__c> LogList=new list<ERP7__Logistic__c>();  
                LogList=[SELECT Id, Name, ERP7__Order_S__c, ERP7__Active__c FROM ERP7__Logistic__c WHERE ERP7__Order_S__c=:orderId AND ERP7__Active__c=true];
                
                set<String> LogIds=new set<String>();      
                for(ERP7__Logistic__c s:LogList) LogIds.add(s.Id);
                list<ERP7__Logistic_Line_Item__c> LLIList=new list<ERP7__Logistic_Line_Item__c>();  
                LLIList=[SELECT Id, Name, ERP7__Order_Product__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Logistic__c IN:LogIds AND ERP7__Product__c!=Null]; //ERP7__Sales_Order_Line_Item__c IN:SoliIds       
                
                list<OrderItem> SoliListFinal=new list<OrderItem>();        
                for(Integer i=0; i<SoliList.size(); i++){               
                    if(SoliList[i].ERP7__Logistic_Quantity__c==null) SoliList[i].ERP7__Logistic_Quantity__c=0;    
                    if(SoliList[i].Quantity==null) SoliList[i].Quantity=0;    
                    if(SoliList[i].ERP7__Remaining_Quantity__c==null) SoliList[i].ERP7__Remaining_Quantity__c=0;    
                    if(SoliList[i].ERP7__Logistic_Quantity__c<SoliList[i].Quantity && SoliList[i].Order.ERP7__Ready_To_Pick_Pack__c==false) SoliList[i].ERP7__Active__c=true;  
                    SoliListFinal.add(SoliList[i]);
                }      
                
                List<String> productIds = new List<String>();
                for(OrderItem so_li :SoliListFinal){ productIds.add(so_li.Product2Id); }
                
                so.Ord=[SELECT Id, Name, AccountId, ERP7__Contact__c, ERP7__Ship_To_Address__c, ERP7__Channel__c, ERP7__Ready_To_Pick_Pack__c, Description,ERP7__Ship_From_Address__c, 
                        ERP7__Shipment_Type__c, ERP7__Shipment_Preference_Speed__c, BillToContactId, ERP7__Bill_To_Address__c, ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c  
                        FROM Order WHERE Id=:orderId limit 1]; 
                
                ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
                if(so.Ord.ERP7__Channel__c != null){
                    dc = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c,ERP7__Site__r.ERP7__Primary_Contact__c, ERP7__Active__c
                          FROM ERP7__Distribution_Channel__c WHERE ERP7__Channel__c=:so.Ord.ERP7__Channel__c AND ERP7__Site__c != null order by ERP7__Priority__c LIMIT 1];
                }
                
                if(dc.Id != null){
                    so.DistributeChannelId=dc.Id;    
                    so.fromContact = (dc.ERP7__Site__c != null && dc.ERP7__Site__r.ERP7__Primary_Contact__c != null) ? dc.ERP7__Site__r.ERP7__Primary_Contact__c : null;
                    Map < Id, List<ERP7__Inventory_Stock__c> > ProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
                    for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks: [Select Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c,ERP7__Warehouse__c, ERP7__product__c,
                                                                                 ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c,ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c 
                                                                                 From ERP7__Inventory_Stock__c Where ERP7__product__c IN: productIds And ERP7__Active__c = true And (ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 And Name = 'Serial Stock Holder')) And ERP7__Warehouse__c =:dc.ERP7__Site__c]) 
                    {
                        if(ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)){
                            ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);
                        }else{
                            List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>(); 
                            WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks); 
                            ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists);
                        }
                    }
                    
                    for(Integer i=0; i<SoliListFinal.size(); i++){                   
                        Decimal proStockCount = 0;
                        if (ProductMap2Stock != null && ProductMap2Stock.keyset().contains(SoliListFinal[i].Product2Id)) {
                            for(ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(SoliListFinal[i].Product2Id)){
                                proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                            }
                        } 
                        SoliListFinal[i].ERP7__Reserved_Quantity__c = proStockCount;
                        SoliListFinal[i].ERP7__Remaining_Quantity__c = SoliListFinal[i].Quantity - SoliListFinal[i].ERP7__Logistic_Quantity__c;
                        
                        //if(SoliListFinal[i].ERP7__Reserved_Quantity__c<=0) SoliListFinal[i].ERP7__Active__c=false;
                        
                    }  
                }
                
                
                for(Integer i=0; i<SoliListFinal.size(); i++)  if(SoliListFinal[i].Quantity-SoliListFinal[i].ERP7__Logistic_Quantity__c<=0) SoliListFinal[i].ERP7__Active__c=false;
                
                // To fetch boms from the kit product version
                
                Set < Id > BomproductIds = new Set < Id > (); 
                
                list < Id > soliIds2explode = new list < Id > ();  
                list < Id > proIds = new list < Id > (); 
                Map < Id, List < ERP7__BOM__c >> soliBOMS = new Map < Id, List < ERP7__BOM__c >> (); 
                Map < Id, Decimal > proStocks = new Map < Id, Decimal > (); 
                List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > (); 
                
                Set < Id > priceBookIds = new Set < Id > ();    
                list < Id > soliBOMVersion = new List < Id > (); 
                 
                for(OrderItem Foli : SoliListFinal){
                    if(!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c ){//&& Foli.ERP7__Version__c != null
                        proIds.add(Foli.Product2Id); 
                        if(Foli.ERP7__PriceBookId__c != null) priceBookIds.add(Foli.ERP7__PriceBookId__c); 
                        if(Foli.ERP7__Version__c != null) soliBOMVersion.add(Foli.ERP7__Version__c);
                    }
                }
                
                Set<Id> alternateBOMs = new Set<Id>();
                Set<Id> alternateBOMProds = new Set<Id>();
                
                List<ERP7__BOM__c> BOMList = new List<ERP7__BOM__c>();
                
               /* if (proIds.size() > 0) {
                    BOMList = [Select Id, Name, ERP7__Active__c,ERP7__BOM_Alternate_Of__c,ERP7__BOM_Alternate_Of__r.ERP7__Type__c,ERP7__BOM_Alternate_Of__r.ERP7__Quantity__c,ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c,BOM_Product__c, BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name, BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c,  BOM_Version__r.Type__c, BOM_Version__r.Status__c From ERP7__BOM__c  Where((ERP7__Active__c = true And ERP7__Type__c != 'Alternate' and BOM_Version__r.RecordType.Name = 'Kit' And ERP7__BOM_Product__c In: proIds And BOM_Version__r.Active__c = true And BOM_Version__r.Start_Date__c <= Today And BOM_Version__r.To_Date__c >= Today And(BOM_Version__r.Type__c = 'Assembly' Or BOM_Version__r.Type__c = 'Sales') AND BOM_Version__r.Status__c = 'Certified') OR(Id In: soliBOMVersion AND BOM_Version__r.Status__c = 'Certified'))    Order by BOM_Version__r.Default__c DESC];
                    
                }*/ //below lines added by bushra 090702025
                if (proIds.size() > 0) {
                    // First get the versions from the order items
                    Set<Id> orderItemVersions = new Set<Id>();
                    for(OrderItem oi : SoliListFinal) {
                        if(oi.ERP7__Version__c != null) {
                            orderItemVersions.add(oi.ERP7__Version__c);
                        }
                    }
                    
                    // Then query BOMs that either:
                    // 1. Are active, non-alternate BOMs for the products with matching versions
                    // OR
                    // 2. Are in the soliBOMVersion set
                    BOMList = [
                        SELECT Id, Name, ERP7__Active__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.ERP7__Type__c, 
                        ERP7__BOM_Alternate_Of__r.ERP7__Quantity__c, ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c,
                        BOM_Product__c, BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, 
                        ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, 
                        RecordType.Name, BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, 
                        BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c, BOM_Version__r.Type__c, BOM_Version__r.Status__c 
                        FROM ERP7__BOM__c  
                        WHERE (
                            (ERP7__Active__c = true 
                             AND ERP7__Type__c != 'Alternate' 
                             AND BOM_Version__r.RecordType.Name = 'Kit' 
                             AND ERP7__BOM_Product__c IN :proIds 
                             AND BOM_Version__r.Active__c = true 
                             AND BOM_Version__r.Start_Date__c <= TODAY 
                             AND BOM_Version__r.To_Date__c >= TODAY 
                             AND (BOM_Version__r.Type__c = 'Assembly' OR BOM_Version__r.Type__c = 'Sales') 
                             AND BOM_Version__r.Status__c = 'Certified'
                             AND BOM_Version__c IN :orderItemVersions)
                            OR 
                            (Id IN :soliBOMVersion AND BOM_Version__r.Status__c = 'Certified')
                        )
                        ORDER BY BOM_Version__r.Default__c DESC
                    ];
                }
                
                for(ERP7__BOM__c bomItems :BOMList){ 
                    BomproductIds.add(bomItems.ERP7__BOM_Component__c); 
                    //  if(bomItems.ERP7__BOM_Alternate_Of__c != null) alternateBOMProds.add(bomItems.ERP7__BOM_Alternate_Of__c);
                }
                
                //if(BOMList.size() > 0){
                
                
                ERP7__Distribution_Channel__c dchannel = new ERP7__Distribution_Channel__c();
                if(so.Ord.ERP7__Channel__c != null){
                    dchannel = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
                                FROM ERP7__Distribution_Channel__c WHERE ERP7__Channel__c=:so.Ord.ERP7__Channel__c AND ERP7__Site__c != null order by ERP7__Priority__c LIMIT 1];
                }
                
                if(dchannel.Id != null){
                    
                    //so.DistributeChannelId=dc.Id;    
                    
                    Map < Id, List<ERP7__Inventory_Stock__c> > BOMProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
                    for (ERP7__Inventory_Stock__c WarehouseItemInventoryBOMStocks: [Select Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c,ERP7__Warehouse__c, ERP7__product__c,
                                                                                    ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c,ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c 
                                                                                    From ERP7__Inventory_Stock__c Where ERP7__product__c IN: BomproductIds And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 And ERP7__Warehouse__c =:dchannel.ERP7__Site__c]) 
                    {
                        if(BOMProductMap2Stock.containsKey(WarehouseItemInventoryBOMStocks.ERP7__product__c)){
                            BOMProductMap2Stock.get(WarehouseItemInventoryBOMStocks.ERP7__product__c).add(WarehouseItemInventoryBOMStocks);
                        }else{
                            List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockListsBom = new List<ERP7__Inventory_Stock__c>(); 
                            WarehouseItemInventoryStockListsBom.add(WarehouseItemInventoryBOMStocks); 
                            BOMProductMap2Stock.put(WarehouseItemInventoryBOMStocks.ERP7__product__c, WarehouseItemInventoryStockListsBom);
                        }
                    }
                    
                    /*list<Id> bomprodIds = new list<Id>();
                    for(ERP7__BOM__c b:BOMList){
                    bomprodIds.add(b.ERP7__BOM_Component__c);
                    }*/
                    
                    Order orderdetail = new Order();
                    orderdetail =[SELECT Id, Name, AccountId, Pricebook2Id, ERP7__Contact__c, ERP7__Ship_To_Address__c, ERP7__Channel__c, ERP7__Ready_To_Pick_Pack__c, Description,
                                  ERP7__Shipment_Type__c, ERP7__Shipment_Preference_Speed__c, BillToContactId, ERP7__Bill_To_Address__c, ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c 
                                  FROM Order WHERE Id=:orderId limit 1];
                    
                    List<PricebookEntry> pbe=new List<PricebookEntry>();
                    pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Is_Kit__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.QuantityUnitOfMeasure 
                           from PricebookEntry where Pricebook2Id =:orderdetail.Pricebook2Id AND Product2Id In:BomproductIds AND IsActive=TRUE];
                    
                    Map <Id,PricebookEntry> pbeMap = new Map <Id,PricebookEntry>();
                    
                    for(PricebookEntry pb : pbe){
                        pbeMap.put(pb.Product2.Id,pb);     
                    }
                    
                    list<ERP7__BOM__c>BOMListFinal=new list<ERP7__BOM__c>();  
                    
                    for(OrderItem Foli : SoliListFinal){
                        if(!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c ){
                            for(ERP7__BOM__c bom :BOMList){
                                if(bom.ERP7__BOM_Component__c != null && bom.ERP7__BOM_Product__c==Foli.Product2Id){
                                    bomwrapper bomwrap = new bomwrapper();
                                    Decimal proStockCount = 0;
                                    if (bom.ERP7__Quantity__c == null || Foli.Quantity == null) {
                                        throw new AuraHandledException('Quantity is missing for BOM or Order Item. Please ensure all quantities are properly set.');
                                    }
                                  else  bom.ERP7__Quantity__c = bom.ERP7__Quantity__c*Foli.Quantity;
                                    if (BOMProductMap2Stock.containsKey(bom.ERP7__BOM_Component__c)) {
                                        for(ERP7__Inventory_Stock__c IS : BOMProductMap2Stock.get(bom.ERP7__BOM_Component__c)){
                                            proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                                        }
                                    }
                                    if(pbeMap.containsKey(bom.ERP7__BOM_Component__c))      bomwrap.pbe  = pbeMap.get(bom.ERP7__BOM_Component__c);   
                                    bomwrap.stock = proStockCount;
                                    bomwrap.Bom = bom;
                                    bomwrap.OrderProdId = Foli.Id;
                                    so.BOMS.add(bomwrap);
                                    
                                }
                            }
                        }
                    }
                    
                  /*  for(ERP7__BOM__c Boli : BOMList){
                        
                        bomwrapper bomwrap = new bomwrapper();
                        Decimal proStockCount = 0;
                        
                        if(Boli.ERP7__BOM_Component__c != null){
                            if (BOMProductMap2Stock.containsKey(Boli.ERP7__BOM_Component__c)) {
                                for(ERP7__Inventory_Stock__c IS : BOMProductMap2Stock.get(Boli.ERP7__BOM_Component__c)){
                                    proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                                }
                            }
                            if(pbeMap.containsKey(Boli.ERP7__BOM_Component__c))      bomwrap.pbe  = pbeMap.get(Boli.ERP7__BOM_Component__c);   
                            bomwrap.stock = proStockCount;
                            bomwrap.Bom = Boli;
                            so.BOMS.add(bomwrap);
                        }
                    } */
                    //so.BOMS = BomWrapList; 
                    so.OrdList=SoliListFinal; 
                    
                    if(so.Ord.Id != null){
                        so.isReadyToPickPack = so.Ord.ERP7__Ready_To_Pick_Pack__c;
                    } 
                }
                
                ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
                if(FC == null){
                    FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());  
                    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance(); 
                }
                if(FC != null){ 
                    so.showShipmentDetails = FC.ERP7__Show_Ship_Details_in_Orders_to_Logistic__c;
                    so.ShowReturnShipSection = FC.ERP7__ShowReturnShipSection__c;
                }            
                
                return so; 
            }
            else {
                so.OrdList=new list<OrderItem>();  so.Ord=new Order();  so.DistributeChannelId='';  so.Logistic=new ERP7__Logistic__c();  return so; 
            }
        }
        catch (AuraHandledException e) {
        // Re-throw the AuraHandledException to preserve the user-friendly message
        throw e;
    } catch (Exception e) {
        // Handle unexpected errors with a generic message
        throw new AuraHandledException('An unexpected error occurred while processing the order: ' + e.getMessage());
    }
    } 
    
    @AuraEnabled
    public static SalesOrderToLogistic getSoliList(String SOId){ //, String DistributeChannelId
        SalesOrderToLogistic so=new SalesOrderToLogistic(); 
        if(String.isNotEmpty(SOId)){
            List<ERP7__Sales_Order_Line_Item__c> SoliList=new List<ERP7__Sales_Order_Line_Item__c>();       
            SoliList=[SELECT Id, Name , ERP7__Product__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Track_Inventory__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Quantity__c, ERP7__Base_Price__c, ERP7__VAT_Amount__c, ERP7__Discount_Amount__c 
                      ,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name, ERP7__Sales_Order__r.ERP7__Ready_To_Pick_Pack__c, ERP7__Site__c, ERP7__Active__c, ERP7__Logistic_Quantity__c, ERP7__Picked_Quantity__c, ERP7__Packed_Quantity__c, ERP7__Shipped_Quantity__c, ERP7__Reserved_Quantity__c,ERP7__Price_Product__c,
                      ERP7__Is_Kit__c, ERP7__Inventory_Tracked__c, ERP7__Version__c, ERP7__PriceBookId__c, ERP7__Insufficient_BOM__c
                      FROM ERP7__Sales_Order_Line_Item__c
                      WHERE ERP7__Sales_Order__c=:SOId AND ERP7__Product__c!=Null AND (ERP7__Product__r.ERP7__Track_Inventory__c=true OR ERP7__Product__r.ERP7__Is_Kit__c=true)]; //  AND ERP7__Site__c=:dc.ERP7__Site__c   //ERP7__Site__c='a2B1o000001pkxzEAA'
        
            set<String> SoliIds=new set<String>();            
            for(ERP7__Sales_Order_Line_Item__c s:SoliList) SoliIds.add(s.Id); //
            
            for(Integer i=0; i<SoliList.size(); i++) SoliList[i].ERP7__Active__c=false;        
            
            list<ERP7__Logistic__c> LogList=new list<ERP7__Logistic__c>();  
            LogList=[SELECT Id, Name, ERP7__Sales_Order__c, ERP7__Active__c FROM ERP7__Logistic__c WHERE ERP7__Sales_Order__c=:SOId AND ERP7__Active__c=true];
            set<String> LogIds=new set<String>();      
            for(ERP7__Logistic__c s:LogList) LogIds.add(s.Id);
            list<ERP7__Logistic_Line_Item__c> LLIList=new list<ERP7__Logistic_Line_Item__c>();  
            LLIList=[SELECT Id, Name, ERP7__Sales_Order_Line_Item__c FROM ERP7__Logistic_Line_Item__c
                     WHERE ERP7__Logistic__c IN:LogIds AND ERP7__Product__c!=Null]; //ERP7__Sales_Order_Line_Item__c IN:SoliIds       
            
            list<ERP7__Sales_Order_Line_Item__c> SoliListFinal=new list<ERP7__Sales_Order_Line_Item__c>();        
            for(Integer i=0; i<SoliList.size(); i++){              
                if(SoliList[i].ERP7__Logistic_Quantity__c==null) SoliList[i].ERP7__Logistic_Quantity__c=0;    
                if(SoliList[i].ERP7__Quantity__c==null) SoliList[i].ERP7__Quantity__c=0;    
                if(SoliList[i].ERP7__Picked_Quantity__c==null) SoliList[i].ERP7__Picked_Quantity__c = 0;
                if(SoliList[i].ERP7__Packed_Quantity__c==null) SoliList[i].ERP7__Packed_Quantity__c = 0;
                if(SoliList[i].ERP7__Logistic_Quantity__c<SoliList[i].ERP7__Quantity__c && SoliList[i].ERP7__Sales_Order__r.ERP7__Ready_To_Pick_Pack__c==false) SoliList[i].ERP7__Active__c=true;  
                
                SoliListFinal.add(SoliList[i]);
            }      
            
            Set<Id> productIds = new Set<Id>();
            for(ERP7__Sales_Order_Line_Item__c so_li :SoliListFinal){ productIds.add(so_li.product__c); }
            
            Map < Id, List<ERP7__Inventory_Stock__c> > ProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
            for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks: [Select Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c,
                                                                         ERP7__Warehouse__c, ERP7__product__c,ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c,
                                                                         ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c From ERP7__Inventory_Stock__c
                                                                         Where ERP7__product__c IN: productIds And ERP7__Active__c = true And (ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 and Name = 'Serial Stock Holder'))])  // serial stock holder condition -- shaguftha 13/09/23
            {
                if(ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)){
                    ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);
                }else{
                    List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>(); 
                    WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks); 
                    ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists);
                }
            }
            
            for(Integer i=0; i<SoliListFinal.size(); i++){                   
                Decimal proStockCount = 0;
                if (ProductMap2Stock != null && ProductMap2Stock.keyset().contains(SoliListFinal[i].ERP7__Product__c)) {
                    for(ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(SoliListFinal[i].ERP7__Product__c)){
                        proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                    }
                } 
                SoliListFinal[i].ERP7__Reserved_Quantity__c = proStockCount;
                //if(SoliListFinal[i].ERP7__Reserved_Quantity__c<=0) SoliListFinal[i].ERP7__Active__c=false;
                
            }      
            
            for(Integer i=0; i<SoliListFinal.size(); i++)  if(SoliListFinal[i].ERP7__Quantity__c-SoliListFinal[i].ERP7__Logistic_Quantity__c<=0) SoliListFinal[i].ERP7__Active__c=false;
            
            so.SoliList=SoliListFinal; 
            
            ERP7__Sales_Order__c SalOrder=new ERP7__Sales_Order__c();
            SalOrder=[SELECT Id, Name, ERP7__Ready_To_Pick_Pack__c FROM ERP7__Sales_Order__c WHERE Id=:SOId];
            so.isReadyToPickPack=SalOrder.ERP7__Ready_To_Pick_Pack__c;
            
            so.SO=[SELECT Id, Name,ERP7__Account__c, ERP7__Contact__c,ERP7__Ship_To_Address__c,ERP7__Channel__c ,ERP7__Ship_From_Address__c 
                   FROM ERP7__Sales_Order__c
                   WHERE Id=:SOId]; 
            
            ERP7__Distribution_Channel__c dc=[Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.ERP7__Primary_Contact__c,ERP7__Active__c
                                              FROM ERP7__Distribution_Channel__c
                                              WHERE ERP7__Channel__c=:so.SO.ERP7__Channel__c order by ERP7__Priority__c LIMIT 1];
            
            so.DistributeChannelId=dc.Id;       
            so.fromContact = (dc.ERP7__Site__c != null && dc.ERP7__Site__r.ERP7__Primary_Contact__c != null) ? dc.ERP7__Site__r.ERP7__Primary_Contact__c : null;
            return so;  
        }else {
            so.SoliList=new list<ERP7__Sales_Order_Line_Item__c>();  
            so.SO=new ERP7__Sales_Order__c();  so.DistributeChannelId='';  so.Logistic=new ERP7__Logistic__c(); 
            return so; 
        }     
    } 
    
  /* @AuraEnabled
    Public Static stockwrapper getupdatedstocksDC(String orditms,String chnId,String DCId,String OrdId,String LogItems, String idType){ 
        try{
            stockwrapper stockwrap = new stockwrapper();
            //list<OrderItem> UpdatedOrdList = new list<OrderItem>();
            list<OrderItem> Ordlist = new list<OrderItem>();
            system.debug('String.isNotEmpty(LogItems) : '+LogItems);
            system.debug('String.isNotEmpty(orditms) : '+orditms);
            if(String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(LogItems) && LogItems != null && LogItems != '' && LogItems != '[]'){
                list<ERP7__Logistic_Line_Item__c> logItemslist = new list<ERP7__Logistic_Line_Item__c>();
                logItemslist = (List<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LogItems, List<ERP7__Logistic_Line_Item__c> .class);
                 set<Id> productIds = new set<Id>();
                    for(ERP7__Logistic_Line_Item__c loli :logItemslist){
                        if(loli.ERP7__Product__c != null){
                            productIds.add(loli.ERP7__Product__c); 
                        }
                    }
                ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
                dc = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
                      FROM ERP7__Distribution_Channel__c WHERE Id =:DCId AND ERP7__Channel__c=:chnId AND ERP7__Site__c != null order by ERP7__Priority__c LIMIT 1];
                if(dc.Id != null){
                    
                    Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
                    
                    for (AggregateResult result : [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock  FROM ERP7__Inventory_Stock__c   WHERE ERP7__product__c IN: productIds And ERP7__Active__c = true And (ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 and Name = 'Serial Stock Holder')) And ERP7__Warehouse__c =:dc.ERP7__Site__c GROUP BY ERP7__Product__c]) {
                        Id ProdId = (Id)result.get('ERP7__Product__c');
                        Decimal totalStock = (Decimal)result.get('totalStock');
                        
                        if (stockMap.containsKey(ProdId)) {
                            stockMap.put(ProdId, stockMap.get(ProdId) + totalStock);
                        } else {
                            stockMap.put(ProdId, totalStock);
                        }
                    }

                    for(ERP7__Logistic_Line_Item__c loli :logItemslist){             
                        Decimal proStockCount = 0;
                        if(loli.ERP7__Product__c != null){
                                if (stockMap.containsKey(loli.ERP7__Product__c)) {
                                        proStockCount += stockMap.get(loli.ERP7__Product__c); 
                                } 
                            }
                            loli.ERP7__Fulfilled_Quantity__c = proStockCount;
                            stockwrap.UpdatedlogList.add(loli);
                        }  
                        //return UpdatedOrdList;
                    }
            }
            else{
                if(String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(orditms)){
                    system.debug('inside orditms::');
                    Ordlist =  (List<OrderItem>) JSON.deserialize(orditms, List<OrderItem> .class);
                    
                    //Storing orderitem product Id's in the set productIds
                    List<String> productIds = new List<String>();
                    for(OrderItem soli :Ordlist){
                        if(soli.Product2Id != null){
                            if(!productIds.contains(soli.Product2Id)){ productIds.add(soli.Product2Id);  }
                        }
                    }    
                    ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
                    dc = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
                          FROM ERP7__Distribution_Channel__c WHERE Id =:DCId AND ERP7__Channel__c=:chnId AND ERP7__Site__c != null order by ERP7__Priority__c LIMIT 1];
                    if(dc.Id != null){
                        
                        Map < Id, List<ERP7__Inventory_Stock__c> > ProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
                        
                        
                        for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks: [Select Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c,ERP7__Warehouse__c, ERP7__product__c,
                                                                                     ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c,ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c 
                                                                                     From ERP7__Inventory_Stock__c Where ERP7__product__c IN: productIds And ERP7__Active__c = true And (ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 and Name = 'Serial Stock Holder')) And ERP7__Warehouse__c =:dc.ERP7__Site__c]) // added by shaguftha serial stock holder condition
                        {
                            if(ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)){
                                ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);
                            }else{
                                List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>(); 
                                WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks); 
                                ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists);
                            }
                        }
                        
                        
                        
                        for(OrderItem soli :Ordlist){                   
                            Decimal proStockCount = 0;
                            if(soli.Product2Id != null){
                                if (ProductMap2Stock.containsKey(soli.Product2Id)) {
                                    for(ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(soli.Product2Id)){
                                        proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                                    }
                                } 
                            }
                            soli.ERP7__Reserved_Quantity__c = proStockCount;
                            soli.ERP7__Remaining_Quantity__c = soli.Quantity - soli.ERP7__Logistic_Quantity__c;
                            stockwrap.UpdatedOrdList.add(soli);
                        }  
                        //return UpdatedOrdList;
                    }
                }
                if(String.isNotEmpty(chnId) && String.isNotEmpty(DCId)){
                    
                    // To fetch boms from the kit product version
                    
                    Set < Id > BomproductIds = new Set < Id > (); 
                    list < Id > proIds = new list < Id > (); 
                    Map < Id, Decimal > proStocks = new Map < Id, Decimal > (); 
                    List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > (); 
                    
                    Set < Id > priceBookIds = new Set < Id > ();    
                    list < Id > soliBOMVersion = new List < Id > (); 
                    
                    Map<Id,Id> prodMap = new Map<Id,Id>();
                    
                    for(OrderItem Foli : Ordlist){
                        if(!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c ){
                            proIds.add(Foli.Product2Id); 
                            if(Foli.ERP7__PriceBookId__c != null) priceBookIds.add(Foli.ERP7__PriceBookId__c); 
                            if(Foli.ERP7__Version__c != null) soliBOMVersion.add(Foli.ERP7__Version__c);
                            prodMap.put(foli.Product2Id,Foli.Id);
                        }
                    }
                    
                    Set<Id> alternateBOMs = new Set<Id>();
                    Set<Id> alternateBOMProds = new Set<Id>();
                    
                    List<ERP7__BOM__c> BOMList = new List<ERP7__BOM__c>();
                    
                    
                    if (proIds.size() > 0) {
                        
                        BOMList = [Select Id, Name, ERP7__Active__c,ERP7__BOM_Alternate_Of__c,ERP7__BOM_Alternate_Of__r.ERP7__Type__c,ERP7__BOM_Alternate_Of__r.ERP7__Quantity__c,ERP7__BOM_Alternate_Of__r.ERP7__BOM_Component__c,BOM_Product__c, BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name, BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c,  BOM_Version__r.Type__c, BOM_Version__r.Status__c From ERP7__BOM__c  Where((ERP7__Active__c = true And ERP7__Type__c != 'Alternate' and BOM_Version__r.RecordType.Name = 'Kit' And ERP7__BOM_Product__c In: proIds And BOM_Version__r.Active__c = true And BOM_Version__r.Start_Date__c <= Today And BOM_Version__r.To_Date__c >= Today And(BOM_Version__r.Type__c = 'Assembly' Or BOM_Version__r.Type__c = 'Sales') AND BOM_Version__r.Status__c = 'Certified') OR(Id In: soliBOMVersion AND BOM_Version__r.Status__c = 'Certified'))    Order by BOM_Version__r.Default__c DESC];
                        
                    }
                    
                    for(ERP7__BOM__c bomItems :BOMList){ 
                        BomproductIds.add(bomItems.ERP7__BOM_Component__c); 
                    }
                    
                    //if(BOMList.size() > 0){
                    
                    
                    ERP7__Distribution_Channel__c dchannel = new ERP7__Distribution_Channel__c();
                    
                    dchannel = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
                                FROM ERP7__Distribution_Channel__c WHERE Id =:DCId AND ERP7__Channel__c=:chnId AND ERP7__Site__c != null order by ERP7__Priority__c LIMIT 1];
                    
                    
                    if(dchannel.Id != null){
                        
                        //so.DistributeChannelId=dc.Id;    
                        
                        Map < Id, List<ERP7__Inventory_Stock__c> > BOMProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
                        for (ERP7__Inventory_Stock__c WarehouseItemInventoryBOMStocks: [Select Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c,ERP7__Warehouse__c, ERP7__product__c,
                                                                                        ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c,ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c 
                                                                                        From ERP7__Inventory_Stock__c Where ERP7__product__c IN: BomproductIds And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 And ERP7__Warehouse__c =:dchannel.ERP7__Site__c]) 
                        {
                            if(BOMProductMap2Stock.containsKey(WarehouseItemInventoryBOMStocks.ERP7__product__c)){
                                BOMProductMap2Stock.get(WarehouseItemInventoryBOMStocks.ERP7__product__c).add(WarehouseItemInventoryBOMStocks);
                            }else{
                                List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockListsBom = new List<ERP7__Inventory_Stock__c>(); 
                                WarehouseItemInventoryStockListsBom.add(WarehouseItemInventoryBOMStocks); 
                                BOMProductMap2Stock.put(WarehouseItemInventoryBOMStocks.ERP7__product__c, WarehouseItemInventoryStockListsBom);
                            }
                        }
                        
                        list<Id> bomprodIds = new list<Id>();
                        for(ERP7__BOM__c b:BOMList){
                            bomprodIds.add(b.ERP7__BOM_Component__c);
                        }
                        
                        Order orderdetail = new Order();
                                                
                        orderdetail = [SELECT Id, Name, AccountId, Pricebook2Id, ERP7__Contact__c, ERP7__Ship_To_Address__c, ERP7__Channel__c, ERP7__Ready_To_Pick_Pack__c, Description,
                                        ERP7__Shipment_Type__c, ERP7__Shipment_Preference_Speed__c, BillToContactId, ERP7__Bill_To_Address__c, ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c 
                                        FROM Order WHERE Id=:OrdId limit 1];
                        
                        List<PricebookEntry> pbe=new List<PricebookEntry>();
                        pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Is_Kit__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.QuantityUnitOfMeasure from PricebookEntry where Pricebook2Id =:orderdetail.Pricebook2Id AND Product2Id In:bomprodIds AND IsActive=TRUE];
                        
                        Map <Id,PricebookEntry> pbeMap = new Map <Id,PricebookEntry>();
                        
                        for(PricebookEntry pb : pbe){ pbeMap.put(pb.Product2.Id,pb); }
                        
                        list<ERP7__BOM__c>BOMListFinal=new list<ERP7__BOM__c>();  
                        
                        
                        for(OrderItem Foli : Ordlist){
                            if(!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c ){
                                for(ERP7__BOM__c bom :BOMList){
                                    if(bom.ERP7__BOM_Component__c != null && bom.ERP7__BOM_Product__c == Foli.Product2Id) bom.ERP7__Quantity__c = bom.ERP7__Quantity__c*Foli.Quantity;
                                    BOMListFinal.add(bom);
                                }
                            }
                        }
                        
                        for(ERP7__BOM__c Boli : BOMList){
                            
                            bomwrapper bomwrap = new bomwrapper();
                            Decimal proStockCount = 0;
                            
                            if(Boli.ERP7__BOM_Component__c != null){
                                if (BOMProductMap2Stock.containsKey(Boli.ERP7__BOM_Component__c)) {
                                    for(ERP7__Inventory_Stock__c IS : BOMProductMap2Stock.get(Boli.ERP7__BOM_Component__c)){
                                        proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                                    }
                                }
                                
                                bomwrap.stock = proStockCount;
                                bomwrap.Bom = Boli;
                                if(prodMap.containsKey(Boli.BOM_Product__c)) bomwrap.OrderProdId  = prodMap.get(Boli.BOM_Product__c);
                                if(pbeMap.containsKey(Boli.ERP7__BOM_Component__c)) bomwrap.pbe  = pbeMap.get(Boli.ERP7__BOM_Component__c);
                                stockwrap.UpdatedBomList.add(bomwrap);
                                
                            }
                            
                        }
                        
                        
                    }
                } 
                
            }
            return stockwrap;
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        } 
    }*/
    
 /*  @AuraEnabled
    public static stockwrapper getupdatedstocksDC(String orditms, String chnId, String DCId, String OrdId, String LogItems, String idType) { 
    try {
        stockwrapper stockwrap = new stockwrapper();
        list<OrderItem> Ordlist = new list<OrderItem>();
        system.debug('String.isNotEmpty(LogItems) : ' + LogItems);
        system.debug('String.isNotEmpty(orditms) : ' + orditms);
        
        if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(LogItems) && LogItems != null && LogItems != '' && LogItems != '[]') {
            list<ERP7__Logistic_Line_Item__c> logItemslist = new list<ERP7__Logistic_Line_Item__c>();
            logItemslist = (List<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LogItems, List<ERP7__Logistic_Line_Item__c>.class);
            set<Id> productIds = new set<Id>();
            for (ERP7__Logistic_Line_Item__c loli : logItemslist) {
                if (loli.ERP7__Product__c != null) {
                    productIds.add(loli.ERP7__Product__c); 
                }
            }
            ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
            dc = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
                  FROM ERP7__Distribution_Channel__c WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null order by ERP7__Priority__c LIMIT 1];
            if (dc.Id != null) {
                Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
                for (AggregateResult result : [Select ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock 
                                              FROM ERP7__Inventory_Stock__c 
                                              WHERE ERP7__product__c IN: productIds 
                                              AND ERP7__Active__c = true 
                                              AND (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 AND Name = 'Serial Stock Holder')) 
                                              AND ERP7__Warehouse__c =: dc.ERP7__Site__c 
                                              GROUP BY ERP7__Product__c]) {
                    Id ProdId = (Id)result.get('ERP7__Product__c');
                    Decimal totalStock = (Decimal)result.get('totalStock');
                    if (stockMap.containsKey(ProdId)) {
                        stockMap.put(ProdId, stockMap.get(ProdId) + totalStock);
                    } else {
                        stockMap.put(ProdId, totalStock);
                    }
                }
                for (ERP7__Logistic_Line_Item__c loli : logItemslist) {             
                    Decimal proStockCount = 0;
                    if (loli.ERP7__Product__c != null) {
                        if (stockMap.containsKey(loli.ERP7__Product__c)) {
                            proStockCount += stockMap.get(loli.ERP7__Product__c); 
                        } 
                    }
                    loli.ERP7__Fulfilled_Quantity__c = proStockCount;
                    stockwrap.UpdatedlogList.add(loli);
                }
            }
        } else {
            if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(orditms)) {
                system.debug('inside orditms::');
                Ordlist = (List<OrderItem>) JSON.deserialize(orditms, List<OrderItem>.class);
                List<String> productIds = new List<String>();
                for (OrderItem soli : Ordlist) {
                    if (soli.Product2Id != null) {
                        if (!productIds.contains(soli.Product2Id)) {
                            productIds.add(soli.Product2Id);
                        }
                    }
                }    
                ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
                dc = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
                      FROM ERP7__Distribution_Channel__c WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null order by ERP7__Priority__c LIMIT 1];
                if (dc.Id != null) {
                    Map<Id, List<ERP7__Inventory_Stock__c>> ProductMap2Stock = new Map<Id, List<ERP7__Inventory_Stock__c>>();
                    for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks : [Select Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Warehouse__c, ERP7__product__c,
                                                                                 ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c 
                                                                                 FROM ERP7__Inventory_Stock__c 
                                                                                 WHERE ERP7__product__c IN: productIds 
                                                                                 AND ERP7__Active__c = true 
                                                                                 AND (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 AND Name = 'Serial Stock Holder')) 
                                                                                 AND ERP7__Warehouse__c =: dc.ERP7__Site__c]) {
                        if (ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)) {
                            ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);
                        } else {
                            List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>(); 
                            WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks); 
                            ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists);
                        }
                    }
                    for (OrderItem soli : Ordlist) {                   
                        Decimal proStockCount = 0;
                        if (soli.Product2Id != null) {
                            if (ProductMap2Stock.containsKey(soli.Product2Id)) {
                                for (ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(soli.Product2Id)) {
                                    proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                                }
                            } 
                        }
                        soli.ERP7__Reserved_Quantity__c = proStockCount;
                        soli.ERP7__Remaining_Quantity__c = soli.Quantity - soli.ERP7__Logistic_Quantity__c;
                        stockwrap.UpdatedOrdList.add(soli);
                    }
                }
            }
            if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId)) {
                Set<Id> BomproductIds = new Set<Id>(); 
                list<Id> proIds = new list<Id>(); 
                Map<Id, Decimal> proStocks = new Map<Id, Decimal>(); 
                List<Inventory_Stock__c> WarehouseItemInventoryStocks = new List<Inventory_Stock__c>(); 
                Set<Id> priceBookIds = new Set<Id>();    
                list<Id> soliBOMVersion = new List<Id>(); 
                Map<Id, Id> prodMap = new Map<Id, Id>();
                
                for (OrderItem Foli : Ordlist) {
                    if (!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c) {
                        proIds.add(Foli.Product2Id); 
                        if (Foli.ERP7__PriceBookId__c != null) priceBookIds.add(Foli.ERP7__PriceBookId__c); 
                        if (Foli.ERP7__Version__c != null) soliBOMVersion.add(Foli.ERP7__Version__c);
                        prodMap.put(Foli.Product2Id, Foli.Id);
                    }
                }
                
                Set<Id> alternateBOMs = new Set<Id>();
                Set<Id> alternateBOMProds = new Set<Id>();
                
                List<ERP7__BOM__c> BOMList = new List<ERP7__BOM__c>();
                if (proIds.size() > 0) {
                    if (soliBOMVersion != null && !soliBOMVersion.isEmpty()) {
                        // Fetch BOMs only from specific versions present on order items
                        BOMList = [
                            SELECT Id, Name, ERP7__Active__c, ERP7__BOM_Product__c, ERP7__BOM_Component__c, ERP7__Quantity__c,
                                   BOM_Version__c, BOM_Version__r.Status__c, BOM_Version__r.RecordType.Name, 
                                   ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c
                            FROM ERP7__BOM__c
                            WHERE BOM_Version__c IN :soliBOMVersion
                              AND BOM_Version__r.Status__c = 'Certified'
                        ];
                    } else {
                        // Fallback: Fetch active, certified, default BOMs based on product and today’s date
                        /*BOMList = [
                            SELECT Id, Name, ERP7__Active__c, ERP7__BOM_Product__c, ERP7__BOM_Component__c, ERP7__Quantity__c,
                                   BOM_Version__c, BOM_Version__r.Status__c, BOM_Version__r.RecordType.Name, BOM_Version__r.Default__c,
                                   BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c, BOM_Version__r.Type__c,
                                   ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c
                            FROM ERP7__BOM__c
                            WHERE ERP7__Active__c = true
                              AND ERP7__Type__c != 'Alternate'
                              AND ERP7__BOM_Product__c IN :proIds
                              AND BOM_Version__r.Active__c = true
                              AND BOM_Version__r.RecordType.Name = 'Kit'
                              AND BOM_Version__r.Start_Date__c <= :System.today()
                              AND BOM_Version__r.To_Date__c >= :System.today()
                              AND BOM_Version__r.Status__c = 'Certified'
                              AND (BOM_Version__r.Type__c = 'Assembly' OR BOM_Version__r.Type__c = 'Sales')
                            ORDER BY BOM_Version__r.Default__c DESC
                        ];
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                                                                   'No BOM versions are associated with the order products.'));
                        
                        // Set BOMList to empty to display nothing
                        BOMList = new List<ERP7__BOM__c>();
                        
                    }
                }
                
                for (ERP7__BOM__c bomItems : BOMList) { 
                    BomproductIds.add(bomItems.ERP7__BOM_Component__c); 
                }
                
                ERP7__Distribution_Channel__c dchannel = new ERP7__Distribution_Channel__c();
                dchannel = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
                            FROM ERP7__Distribution_Channel__c WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null order by ERP7__Priority__c LIMIT 1];
                
                if (dchannel.Id != null) {
                    Map<Id, List<ERP7__Inventory_Stock__c>> BOMProductMap2Stock = new Map<Id, List<ERP7__Inventory_Stock__c>>();
                    for (ERP7__Inventory_Stock__c WarehouseItemInventoryBOMStocks : [Select Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Warehouse__c, ERP7__product__c,
                                                                                    ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c 
                                                                                    FROM ERP7__Inventory_Stock__c 
                                                                                    WHERE ERP7__product__c IN: BomproductIds 
                                                                                    AND ERP7__Active__c = true 
                                                                                    AND ERP7__Number_of_Item_In_Stock__c > 0 
                                                                                    AND ERP7__Warehouse__c =: dchannel.ERP7__Site__c]) {
                        if (BOMProductMap2Stock.containsKey(WarehouseItemInventoryBOMStocks.ERP7__product__c)) {
                            BOMProductMap2Stock.get(WarehouseItemInventoryBOMStocks.ERP7__product__c).add(WarehouseItemInventoryBOMStocks);
                        } else {
                            List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockListsBom = new List<ERP7__Inventory_Stock__c>(); 
                            WarehouseItemInventoryStockListsBom.add(WarehouseItemInventoryBOMStocks); 
                            BOMProductMap2Stock.put(WarehouseItemInventoryBOMStocks.ERP7__product__c, WarehouseItemInventoryStockListsBom);
                        }
                    }
                    
                    list<Id> bomprodIds = new list<Id>();
                    for (ERP7__BOM__c b : BOMList) {
                        bomprodIds.add(b.ERP7__BOM_Component__c);
                    }
                    
                    Order orderdetail = new Order();
                    orderdetail = [SELECT Id, Name, AccountId, Pricebook2Id, ERP7__Contact__c, ERP7__Ship_To_Address__c, ERP7__Channel__c, ERP7__Ready_To_Pick_Pack__c, Description,
                                   ERP7__Shipment_Type__c, ERP7__Shipment_Preference_Speed__c, BillToContactId, ERP7__Bill_To_Address__c, ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c 
                                   FROM Order WHERE Id =: OrdId LIMIT 1];
                    
                    List<PricebookEntry> pbe = new List<PricebookEntry>();
                    pbe = [Select UnitPrice, ERP7__Purchase_Price__c, Product2.Id, Product2.Name, Product2.ProductCode, Product2.Description, Product2.ERP7__Version__c, Product2.ERP7__Configure__c, Product2.ERP7__Allow_Back_Orders__c, Product2.ERP7__Is_Kit__c, Product2.ERP7__Picture__c, Product2.ERP7__Serialise__c, Product2.QuantityUnitOfMeasure 
                           FROM PricebookEntry 
                           WHERE Pricebook2Id =: orderdetail.Pricebook2Id 
                           AND Product2Id IN: bomprodIds 
                           AND IsActive = TRUE];
                    
                    Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
                    for (PricebookEntry pb : pbe) {
                        pbeMap.put(pb.Product2.Id, pb);
                    }
                    
                    list<ERP7__BOM__c> BOMListFinal = new list<ERP7__BOM__c>();  
                    for (OrderItem Foli : Ordlist) {
                        if (!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c) {
                            for (ERP7__BOM__c bom : BOMList) {
                                if (bom.ERP7__BOM_Component__c != null && bom.ERP7__BOM_Product__c == Foli.Product2Id) {
                                    bom.ERP7__Quantity__c = bom.ERP7__Quantity__c * Foli.Quantity;
                                    BOMListFinal.add(bom);
                                }
                            }
                        }
                    }
                    
                    for (ERP7__BOM__c Boli : BOMList) {
                        bomwrapper bomwrap = new bomwrapper();
                        Decimal proStockCount = 0;
                        if (Boli.ERP7__BOM_Component__c != null) {
                            if (BOMProductMap2Stock.containsKey(Boli.ERP7__BOM_Component__c)) {
                                for (ERP7__Inventory_Stock__c IS : BOMProductMap2Stock.get(Boli.ERP7__BOM_Component__c)) {
                                    proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                                }
                            }
                            bomwrap.stock = proStockCount;
                            bomwrap.Bom = Boli;
                            if (prodMap.containsKey(Boli.BOM_Product__c)) {
                                bomwrap.OrderProdId = prodMap.get(Boli.BOM_Product__c);
                            }
                            if (pbeMap.containsKey(Boli.ERP7__BOM_Component__c)) {
                                bomwrap.pbe = pbeMap.get(Boli.ERP7__BOM_Component__c);
                            }
                            stockwrap.UpdatedBomList.add(bomwrap);
                        }
                    }
                }
            }
            
        }
            return stockwrap;
        } catch (Exception e) {
            System.debug('Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        } 
    }*/
    
    
    
   /* @AuraEnabled
public static stockwrapper getupdatedstocksDC(String orditms, String chnId, String DCId, String OrdId, String LogItems, String idType) { 
    try {

        System.debug('=== START getupdatedstocksDC ===');
        System.debug('Input orditms: ' + orditms);
        System.debug('Input chnId: ' + chnId);
        System.debug('Input DCId: ' + DCId);
        System.debug('Input OrdId: ' + OrdId);
        System.debug('Input LogItems: ' + LogItems);

        stockwrapper stockwrap = new stockwrapper();
        List<OrderItem> Ordlist = new List<OrderItem>();
        
        // Handle Logistic Line Items
        System.debug('Checking Logistic Items Condition...');
        if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(LogItems) && LogItems != null && LogItems != '[]') {

            System.debug('--- LOGISTIC ITEMS BRANCH ---');
            System.debug('Deserializing Logistic Items...');

            List<ERP7__Logistic_Line_Item__c> logItemslist = 
                (List<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LogItems, List<ERP7__Logistic_Line_Item__c>.class);

            System.debug('Logistic Items count: ' + logItemslist.size());

            Set<Id> productIds = new Set<Id>();
            for (ERP7__Logistic_Line_Item__c loli : logItemslist) {
                if (loli.ERP7__Product__c != null) {
                    productIds.add(loli.ERP7__Product__c);
                }
            }
            System.debug('Logistic productIds: ' + productIds);

            ERP7__Distribution_Channel__c dc = [
                SELECT Id, Name, ERP7__Site__c 
                FROM ERP7__Distribution_Channel__c 
                WHERE Id =: DCId 
                AND ERP7__Channel__c =: chnId 
                AND ERP7__Site__c != null 
                LIMIT 1
            ];
            System.debug('DC Found Logistic Site: ' + dc.ERP7__Site__c);

            if (dc.Id != null) {
                System.debug('Running Inventory Aggregate for logistic items...');

                Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
                
                for (AggregateResult result : [
                    SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock 
                    FROM ERP7__Inventory_Stock__c 
                    WHERE ERP7__product__c IN: productIds 
                    AND ERP7__Active__c = true 
                    AND ERP7__Warehouse__c =: dc.ERP7__Site__c 
                    GROUP BY ERP7__Product__c
                ]) {
                    Id ProdId = (Id)result.get('ERP7__Product__c');
                    Decimal totalStock = (Decimal)result.get('totalStock');
                    stockMap.put(ProdId, totalStock);

                    System.debug('Stock for ' + ProdId + ' = ' + totalStock);
                }

                for (ERP7__Logistic_Line_Item__c loli : logItemslist) {
                    Decimal proStockCount = stockMap.containsKey(loli.ERP7__Product__c) 
                                            ? stockMap.get(loli.ERP7__Product__c) 
                                            : 0;

                    System.debug('Setting Fulfilled Qty for ' + loli.ERP7__Product__c + ' = ' + proStockCount);

                    loli.ERP7__Fulfilled_Quantity__c = proStockCount;
                    stockwrap.UpdatedlogList.add(loli);
                }
            }
        }

        // Handle Order Items
        else if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(orditms)) {

            System.debug('--- ORDER ITEMS BRANCH ---');
            System.debug('Deserializing Order Items...');

            Ordlist = (List<OrderItem>) JSON.deserialize(orditms, List<OrderItem>.class);

            System.debug('Order Items count: ' + Ordlist.size());

            List<String> productIds = new List<String>();
            for (OrderItem soli : Ordlist) {
                if (soli.Product2Id != null && !productIds.contains(soli.Product2Id)) {
                    productIds.add(soli.Product2Id);
                }
            }
            System.debug('Order ProductIds: ' + productIds);

            ERP7__Distribution_Channel__c dc = [
                SELECT Id, Name, ERP7__Site__c 
                FROM ERP7__Distribution_Channel__c 
                WHERE Id =: DCId 
                AND ERP7__Channel__c =: chnId 
                AND ERP7__Site__c != null 
                LIMIT 1
            ];

            System.debug('DC Found Order Site: ' + dc.ERP7__Site__c);

            if (dc.Id != null) {
                System.debug('Fetching Inventory Stock for Order Products...');

                Map<Id, List<ERP7__Inventory_Stock__c>> ProductMap2Stock = new Map<Id, List<ERP7__Inventory_Stock__c>>();

                for (ERP7__Inventory_Stock__c st : [
                    SELECT Id, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c 
                    FROM ERP7__Inventory_Stock__c 
                    WHERE ERP7__product__c IN: productIds 
                    AND ERP7__Active__c = true 
                    AND ERP7__Warehouse__c =: dc.ERP7__Site__c
                ]) {
                    if (!ProductMap2Stock.containsKey(st.ERP7__product__c)) {
                        ProductMap2Stock.put(st.ERP7__product__c, new List<ERP7__Inventory_Stock__c>());
                    }
                    ProductMap2Stock.get(st.ERP7__product__c).add(st);

                    System.debug('StockRow => ' + st.ERP7__product__c + ', qty=' + st.ERP7__Number_of_Item_In_Stock__c);
                }

                for (OrderItem soli : Ordlist) {
                    Decimal proStockCount = 0;

                    if (soli.Product2Id != null && ProductMap2Stock.containsKey(soli.Product2Id)) {
                        for (ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(soli.Product2Id)) {
                            proStockCount += IS.ERP7__Number_of_Item_In_Stock__c;
                        }
                    }

                    System.debug('Order product ' + soli.Product2Id + ' total stock=' + proStockCount);

                    soli.ERP7__Reserved_Quantity__c = proStockCount;
                    soli.ERP7__Remaining_Quantity__c = soli.Quantity - soli.ERP7__Logistic_Quantity__c;
                    stockwrap.UpdatedOrdList.add(soli);
                }
            }

            // Exploded Items
            System.debug('Checking Exploded/StockOutward/MRP status...');

            Set<Id> orderItemIds = new Set<Id>();
            for (OrderItem oi : Ordlist) orderItemIds.add(oi.Id);

            Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>([
                SELECT Id, ERP7__Explode__c 
                FROM OrderItem 
                WHERE Id IN :orderItemIds 
                AND ERP7__Explode__c = true
            ]);
            System.debug('Explode__c Ids: ' + orderItemMap.keySet());

            List<ERP7__Stock_Outward_Line_Item__c> stockOutwardItems = [
                SELECT ERP7__Order_Product__c 
                FROM ERP7__Stock_Outward_Line_Item__c 
                WHERE ERP7__Order_Product__c IN :orderItemIds
            ];
            System.debug('StockOutward count: ' + stockOutwardItems.size());

            List<ERP7__MRP__c> mrpRecords = [
                SELECT ERP7__Order_Product__c 
                FROM ERP7__MRP__c 
                WHERE ERP7__Order_Product__c IN :orderItemIds 
                AND RecordType.Name = 'MRP Kit'
            ];
            System.debug('MRP records count: ' + mrpRecords.size());

            Map<Id, Boolean> explodedOrderItems = new Map<Id, Boolean>();

            for (Id oiId : orderItemIds) {
                Boolean isExploded = orderItemMap.containsKey(oiId);
                Boolean hasSO = false;
                Boolean hasMRP = false;

                for (ERP7__Stock_Outward_Line_Item__c so : stockOutwardItems)
                    if (so.ERP7__Order_Product__c == oiId) hasSO = true;

                for (ERP7__MRP__c mrp : mrpRecords)
                    if (mrp.ERP7__Order_Product__c == oiId) hasMRP = true;

                Boolean finalValue = (isExploded && hasSO && hasMRP);

                explodedOrderItems.put(oiId, finalValue);

                System.debug('Exploded[' + oiId + '] = ' + finalValue);
            }

            stockwrap.ExplodedOrderItems = explodedOrderItems;

            // ===============================
            // BOM Section (With Simple Debugs)
            // ===============================

            System.debug('--- BOM SECTION START ---');

            if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId)) {

                Set<Id> BomproductIds = new Set<Id>(); 
                List<Id> proIds = new List<Id>(); 
                List<Id> soliBOMVersion = new List<Id>(); 
                Map<Id, Id> prodMap = new Map<Id, Id>();

                for (OrderItem Foli : Ordlist) {
                    if (!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c) {
                        proIds.add(Foli.Product2Id);
                        if (Foli.ERP7__Version__c != null) soliBOMVersion.add(Foli.ERP7__Version__c);
                        prodMap.put(Foli.Product2Id, Foli.Id);
                    }
                }

                System.debug('proIds (Kits): ' + proIds);
                System.debug('soliBOMVersion: ' + soliBOMVersion);

                List<ERP7__BOM__c> BOMList = new List<ERP7__BOM__c>();

                if (!soliBOMVersion.isEmpty()) {

                    System.debug('Fetching BOM List...');

                    BOMList = [
                        SELECT Id, ERP7__BOM_Product__c, ERP7__BOM_Component__c,
                               ERP7__Quantity__c, BOM_Version__c
                        FROM ERP7__BOM__c
                        WHERE BOM_Version__c IN :soliBOMVersion
                        AND BOM_Version__r.Status__c = 'Certified'
                    ];
                }

                System.debug('BOMList size: ' + BOMList.size());

                for (ERP7__BOM__c bom : BOMList)
                    BomproductIds.add(bom.ERP7__BOM_Component__c);

                System.debug('BOM product Ids: ' + BomproductIds);

                ERP7__Distribution_Channel__c dchannel = [
                    SELECT Id, ERP7__Site__c 
                    FROM ERP7__Distribution_Channel__c 
                    WHERE Id =: DCId 
                    AND ERP7__Channel__c =: chnId 
                    LIMIT 1
                ];

                System.debug('DC Site(BOM): ' + dchannel.ERP7__Site__c);

                if (dchannel.Id != null) {

                    Map<Id, List<ERP7__Inventory_Stock__c>> BOMProductMap2Stock =
                        new Map<Id, List<ERP7__Inventory_Stock__c>>();

                    for (ERP7__Inventory_Stock__c st : [
                        SELECT ERP7__product__c, ERP7__Number_of_Item_In_Stock__c
                        FROM ERP7__Inventory_Stock__c
                        WHERE ERP7__product__c IN :BomproductIds
                        AND ERP7__Warehouse__c =: dchannel.ERP7__Site__c
                    ]) {
                        if (!BOMProductMap2Stock.containsKey(st.ERP7__product__c)) {
                            BOMProductMap2Stock.put(st.ERP7__product__c, new List<ERP7__Inventory_Stock__c>());
                        }
                        BOMProductMap2Stock.get(st.ERP7__product__c).add(st);

                        System.debug('BOM StockRow => ' + st.ERP7__product__c + ', qty=' + st.ERP7__Number_of_Item_In_Stock__c);
                    }

                    List<Id> bomprodIds = new List<Id>();
                    for (ERP7__BOM__c b : BOMList) bomprodIds.add(b.ERP7__BOM_Component__c);

                    Order orderdetail = [
                        SELECT Pricebook2Id
                        FROM Order 
                        WHERE Id =: OrdId LIMIT 1
                    ];

                    List<PricebookEntry> pbe = [
                        SELECT Product2Id, UnitPrice 
                        FROM PricebookEntry
                        WHERE Pricebook2Id =: orderdetail.Pricebook2Id
                        AND Product2Id IN: bomprodIds
                        AND IsActive = true
                    ];

                    Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
                    for (PricebookEntry pb : pbe) pbeMap.put(pb.Product2Id, pb);

                    for (ERP7__BOM__c Boli : BOMList) {

                        bomwrapper bomwrap = new bomwrapper();
                        Decimal proStockCount = 0;

                        if (Boli.ERP7__BOM_Component__c != null) {

                            if (BOMProductMap2Stock.containsKey(Boli.ERP7__BOM_Component__c)) {
                                for (ERP7__Inventory_Stock__c IS : BOMProductMap2Stock.get(Boli.ERP7__BOM_Component__c)) {
                                    proStockCount += IS.ERP7__Number_of_Item_In_Stock__c;
                                }
                            }

                            System.debug('BOM component ' + Boli.ERP7__BOM_Component__c + ' stock=' + proStockCount);

                            bomwrap.stock = proStockCount;
                            bomwrap.Bom = Boli;

                            if (prodMap.containsKey(Boli.ERP7__BOM_Product__c))
                                bomwrap.OrderProdId = prodMap.get(Boli.ERP7__BOM_Product__c);

                            if (pbeMap.containsKey(Boli.ERP7__BOM_Component__c))
                                bomwrap.pbe = pbeMap.get(Boli.ERP7__BOM_Component__c);

                            stockwrap.UpdatedBomList.add(bomwrap);
                        }
                    }
                }
            }
        }

        System.debug('=== END getupdatedstocksDC ===');
        return stockwrap;

    } catch (Exception e) {
        System.debug('Exception: ' + e.getMessage());
        System.debug('Stack: ' + e.getStackTraceString());
        throw new AuraHandledException(e.getMessage());
    } 
}*/


    
    // commented by saqlain to check the issue 

    // below code commented by abubakar toadd the Salesorderline item functionality in this below methord
//  @AuraEnabled
// public static stockwrapper getupdatedstocksDC(String orditms, String chnId, String DCId, String OrdId, String LogItems, String idType) { 
//     try {
//         stockwrapper stockwrap = new stockwrapper();

//         // Initialize the wrapper list if not already done in the wrapper class constructor
//         if(stockwrap.UpdatedSoliList == null) stockwrap.UpdatedSoliList = new List<ERP7__Sales_Order_Line_Item__c>();
//         if(stockwrap.UpdatedOrdList == null) stockwrap.UpdatedOrdList = new List<OrderItem>();

//         List<OrderItem> Ordlist = new List<OrderItem>();
        
//         // Handle Logistic Line Items
//         if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(LogItems) && LogItems != null && LogItems != '[]') {
//             List<ERP7__Logistic_Line_Item__c> logItemslist = (List<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LogItems, List<ERP7__Logistic_Line_Item__c>.class);
//             Set<Id> productIds = new Set<Id>();
//             for (ERP7__Logistic_Line_Item__c loli : logItemslist) {
//                 if (loli.ERP7__Product__c != null) {
//                     productIds.add(loli.ERP7__Product__c); 
//                 }
//             }
//             ERP7__Distribution_Channel__c dc = [SELECT Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
//                                                 FROM ERP7__Distribution_Channel__c 
//                                                 WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null 
//                                                 ORDER BY ERP7__Priority__c LIMIT 1];
//             if (dc.Id != null) {
//                 Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
//                 for (AggregateResult result : [SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock 
//                                               FROM ERP7__Inventory_Stock__c 
//                                               WHERE ERP7__product__c IN: productIds 
//                                               AND ERP7__Active__c = true 
//                                               AND (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 AND Name = 'Serial Stock Holder')) 
//                                               AND ERP7__Warehouse__c =: dc.ERP7__Site__c 
//                                               GROUP BY ERP7__Product__c]) {
//                     Id ProdId = (Id)result.get('ERP7__Product__c');
//                     Decimal totalStock = (Decimal)result.get('totalStock');
//                     stockMap.put(ProdId, stockMap.containsKey(ProdId) ? stockMap.get(ProdId) + totalStock : totalStock);
//                 }
//                 for (ERP7__Logistic_Line_Item__c loli : logItemslist) {             
//                     Decimal proStockCount = stockMap.containsKey(loli.ERP7__Product__c) ? stockMap.get(loli.ERP7__Product__c) : 0;
//                     loli.ERP7__Fulfilled_Quantity__c = proStockCount;
//                     stockwrap.UpdatedlogList.add(loli);
//                 }
//             }
//         } else if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(orditms)) {
//             // Handle Order Items
//             Ordlist = (List<OrderItem>) JSON.deserialize(orditms, List<OrderItem>.class);
//             List<String> productIds = new List<String>();
//             for (OrderItem soli : Ordlist) {
//                 if (soli.Product2Id != null) {
//                     if (!productIds.contains(soli.Product2Id)) {
//                         productIds.add(soli.Product2Id);
//                     }
//                 }
//             }    
//             ERP7__Distribution_Channel__c dc = [SELECT Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
//                                                 FROM ERP7__Distribution_Channel__c 
//                                                 WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null 
//                                                 ORDER BY ERP7__Priority__c LIMIT 1];
//             if (dc.Id != null) {
//                 Map<Id, List<ERP7__Inventory_Stock__c>> ProductMap2Stock = new Map<Id, List<ERP7__Inventory_Stock__c>>();
//                 for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks : [SELECT Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Warehouse__c, ERP7__product__c,
//                                                                              ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c 
//                                                                              FROM ERP7__Inventory_Stock__c 
//                                                                              WHERE ERP7__product__c IN: productIds 
//                                                                              AND ERP7__Active__c = true 
//                                                                              AND (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 AND Name = 'Serial Stock Holder')) 
//                                                                              AND ERP7__Warehouse__c =: dc.ERP7__Site__c]) {
//                     if (ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)) {
//                         ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);
//                     } else {
//                         List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>(); 
//                         WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks); 
//                         ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists);
//                     }
//                 }
//                 for (OrderItem soli : Ordlist) {                   
//                     Decimal proStockCount = 0;
//                     if (soli.Product2Id != null && ProductMap2Stock.containsKey(soli.Product2Id)) {
//                         for (ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(soli.Product2Id)) {
//                             proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
//                         }
//                     }
//                     soli.ERP7__Reserved_Quantity__c = proStockCount;
//                     soli.ERP7__Remaining_Quantity__c = soli.Quantity - soli.ERP7__Logistic_Quantity__c;
//                     stockwrap.UpdatedOrdList.add(soli);
//                 }
//             }

//             // promt to geminai: the code below this comment needs to procccessed for salesorder line item as well

//             // Check for Explode__c, Stock_Outward_Line_Item__c, and MRP__c
//             Set<Id> orderItemIds = new Set<Id>();
//             for (OrderItem oi : Ordlist) {
//                 orderItemIds.add(oi.Id);
//             }
//             Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>([
//                 SELECT Id, ERP7__Explode__c   // promt to geminai : in SOLIs also we have this field : ERP7__Explode__c
//                 FROM OrderItem 
//                 WHERE Id IN :orderItemIds AND ERP7__Explode__c = true
//             ]);
//             List<ERP7__Stock_Outward_Line_Item__c> stockOutwardItems = [
//                 SELECT Id, ERP7__Order_Product__c 
//                 FROM ERP7__Stock_Outward_Line_Item__c 
//                 WHERE ERP7__Order_Product__c IN :orderItemIds   // promt to geminai : in this object salesorder line items (SOLIs) are linked with a field : ERP7__Sales_Order_Line_Item__c 
//             ];
//             List<ERP7__MRP__c> mrpRecords = [
//                 SELECT Id, ERP7__Order_Product__c 
//                 FROM ERP7__MRP__c 
//                 WHERE ERP7__Order_Product__c IN :orderItemIds AND RecordType.Name = 'MRP Kit' // promt to geminai : in this object SOLIs are linked with a field : ERP7__Sales_Order_Line_Item__c
//             ];
//             Map<Id, Boolean> explodedOrderItems = new Map<Id, Boolean>();
//             for (Id oiId : orderItemIds) {
//                 Boolean isExploded = orderItemMap.containsKey(oiId);
//                 Boolean hasStockOutward = false;
//                 Boolean hasMRP = false;
//                 for (ERP7__Stock_Outward_Line_Item__c soli : stockOutwardItems) {
//                     if (soli.ERP7__Order_Product__c == oiId) {
//                         hasStockOutward = true;
//                         break;
//                     }
//                 }
//                 for (ERP7__MRP__c mrp : mrpRecords) {
//                     if (mrp.ERP7__Order_Product__c == oiId) {
//                         hasMRP = true;
//                         break;
//                     }
//                 }
//                 explodedOrderItems.put(oiId, isExploded && hasStockOutward && hasMRP);
//             }
//             stockwrap.ExplodedOrderItems = explodedOrderItems; // promt to geminai : for the SOLIs we can create a new wrapper to send this info 

//             // Handle BOM for Kits
//             if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId)) {
//                 Set<Id> BomproductIds = new Set<Id>(); 
//                 List<Id> proIds = new List<Id>(); 
//                 Map<Id, Decimal> proStocks = new Map<Id, Decimal>(); 
//                 Set<Id> priceBookIds = new Set<Id>();    
//                 List<Id> soliBOMVersion = new List<Id>(); 
//                 Map<Id, Id> prodMap = new Map<Id, Id>();
                
//                 for (OrderItem Foli : Ordlist) {
//                     if (!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c) { // promt to geminai : in SOLIs we have these fileds : ERP7__Inventory_Tracked__c, ERP7__Is_Kit__c
//                         proIds.add(Foli.Product2Id); 
//                         if (Foli.ERP7__PriceBookId__c != null) priceBookIds.add(Foli.ERP7__PriceBookId__c);  // promt to geminai : in SOLIs also we have this fields : ERP7__PriceBookId__c
//                         if (Foli.ERP7__Version__c != null) soliBOMVersion.add(Foli.ERP7__Version__c); // promt to geminai : in SOLIs also we have this field: ERP7__Version__c
//                         prodMap.put(Foli.Product2Id, Foli.Id);
//                     }
//                 }
                
//                 List<ERP7__BOM__c> BOMList = new List<ERP7__BOM__c>();
//                 if (proIds.size() > 0) {
//                     if (soliBOMVersion != null && !soliBOMVersion.isEmpty()) {
//                         BOMList = [
//                             SELECT Id, Name, ERP7__Active__c, ERP7__BOM_Product__c, ERP7__BOM_Component__c, ERP7__Quantity__c,
//                                    BOM_Version__c, BOM_Version__r.Status__c, BOM_Version__r.RecordType.Name, 
//                                    ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c
//                             FROM ERP7__BOM__c
//                             WHERE BOM_Version__c IN :soliBOMVersion
//                               AND BOM_Version__r.Status__c = 'Certified'
//                         ];
//                     }
//                 }
                
//                 for (ERP7__BOM__c bomItems : BOMList) { 
//                     BomproductIds.add(bomItems.ERP7__BOM_Component__c); 
//                 }
                
//                 ERP7__Distribution_Channel__c dchannel = [SELECT Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
//                                                         FROM ERP7__Distribution_Channel__c 
//                                                         WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null 
//                                                         ORDER BY ERP7__Priority__c LIMIT 1];
                
//                 if (dchannel.Id != null) {
//                     Map<Id, List<ERP7__Inventory_Stock__c>> BOMProductMap2Stock = new Map<Id, List<ERP7__Inventory_Stock__c>>();
//                     for (ERP7__Inventory_Stock__c WarehouseItemInventoryBOMStocks : [SELECT Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Warehouse__c, ERP7__product__c,
//                                                                                     ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c 
//                                                                                     FROM ERP7__Inventory_Stock__c 
//                                                                                     WHERE ERP7__product__c IN: BomproductIds 
//                                                                                     AND ERP7__Active__c = true 
//                                                                                     AND ERP7__Number_of_Item_In_Stock__c > 0 
//                                                                                     AND ERP7__Warehouse__c =: dchannel.ERP7__Site__c]) {
//                         if (BOMProductMap2Stock.containsKey(WarehouseItemInventoryBOMStocks.ERP7__product__c)) {
//                             BOMProductMap2Stock.get(WarehouseItemInventoryBOMStocks.ERP7__product__c).add(WarehouseItemInventoryBOMStocks);
//                         } else {
//                             List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockListsBom = new List<ERP7__Inventory_Stock__c>(); 
//                             WarehouseItemInventoryStockListsBom.add(WarehouseItemInventoryBOMStocks); 
//                             BOMProductMap2Stock.put(WarehouseItemInventoryBOMStocks.ERP7__product__c, WarehouseItemInventoryStockListsBom);
//                         }
//                     }
                    
//                     List<Id> bomprodIds = new List<Id>();
//                     for (ERP7__BOM__c b : BOMList) {
//                         bomprodIds.add(b.ERP7__BOM_Component__c);
//                     }
                    
//                     // 1. Initialize a variable to hold the Pricebook ID we need to find
//                     List<String> targetPricebookId = new List<String>();

//                     // 2. Logic to find the Pricebook ID based on the Type
//                     if (idType == 'Order') {
//                         // --- STANDARD ORDER LOGIC ---
//                         List<Order> orderdetails = [SELECT Id, Name, AccountId, Pricebook2Id, ERP7__Contact__c, ERP7__Ship_To_Address__c, ERP7__Channel__c, ERP7__Ready_To_Pick_Pack__c, Description,
//                                         ERP7__Shipment_Type__c, ERP7__Shipment_Preference_Speed__c, BillToContactId, ERP7__Bill_To_Address__c, ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c 
//                                         FROM Order 
//                                         WHERE Id = :OrdId LIMIT 1];
                        
//                         if (!orderdetails.isEmpty()) {
//                             targetPricebookId.add(orderdetails[0].Pricebook2Id);
//                         }
                    
//                     } else if (idType == 'SalesOrder') {
//                         // --- SALES ORDER LOGIC ---
//                         // Query Sales Order Line Items to get the mapped Pricebook ID
//                         List<ERP7__Sales_Order_Line_Item__c> soLines = [SELECT Id, ERP7__PriceBookId__c 
//                                                                         FROM ERP7__Sales_Order_Line_Item__c 
//                                                                         WHERE ERP7__Sales_Order__c = :OrdId 
//                                                                         AND ERP7__PriceBookId__c != null];
                        
//                         if (!soLines.isEmpty()) {
//                             for(ERP7__Sales_Order_Line_Item__c soLine : soLines) {
//                                 if (!targetPricebookId.contains(soLine.ERP7__PriceBookId__c)) {
//                                     targetPricebookId.add(soLine.ERP7__PriceBookId__c);
//                                 }
//                             }
//                         }
//                     }
                    
//                     List<PricebookEntry> pbe = new List<PricebookEntry>();
                    
//                     if(targetPricebookId.size() > 0){
//                         pbe = [SELECT UnitPrice, ERP7__Purchase_Price__c, Product2.Id, Product2.Name, Product2.ProductCode, Product2.Description, Product2.ERP7__Version__c, Product2.ERP7__Configure__c, Product2.ERP7__Allow_Back_Orders__c, Product2.ERP7__Is_Kit__c, Product2.ERP7__Picture__c, Product2.ERP7__Serialise__c, Product2.QuantityUnitOfMeasure 
//                                                FROM PricebookEntry 
//                                                WHERE Pricebook2Id IN: targetPricebookId 
//                                                AND Product2Id IN: bomprodIds 
//                                                AND IsActive = TRUE];
//                     }

//                     Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
//                     for (PricebookEntry pb : pbe) {
//                         pbeMap.put(pb.Product2.Id, pb);
//                     }
                    
//                     List<ERP7__BOM__c> BOMListFinal = new List<ERP7__BOM__c>();  
//                     for (OrderItem Foli : Ordlist) {
//                         if (!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c) {
//                             for (ERP7__BOM__c bom : BOMList) {
//                                 if (bom.ERP7__BOM_Component__c != null && bom.ERP7__BOM_Product__c == Foli.Product2Id) {
//                                     bom.ERP7__Quantity__c = bom.ERP7__Quantity__c * Foli.Quantity;
//                                     BOMListFinal.add(bom);
//                                 }
//                             }
//                         }
//                     }
                    
//                     for (ERP7__BOM__c Boli : BOMList) {
//                         bomwrapper bomwrap = new bomwrapper();
//                         Decimal proStockCount = 0;
//                         if (Boli.ERP7__BOM_Component__c != null) {
//                             if (BOMProductMap2Stock.containsKey(Boli.ERP7__BOM_Component__c)) {
//                                 for (ERP7__Inventory_Stock__c IS : BOMProductMap2Stock.get(Boli.ERP7__BOM_Component__c)) {
//                                     proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
//                                 }
//                             }
//                             bomwrap.stock = proStockCount;
//                             bomwrap.Bom = Boli;
//                             if (prodMap.containsKey(Boli.BOM_Product__c)) {
//                                 bomwrap.OrderProdId = prodMap.get(Boli.BOM_Product__c);
//                             }
//                             if (pbeMap.containsKey(Boli.ERP7__BOM_Component__c)) {
//                                 bomwrap.pbe = pbeMap.get(Boli.ERP7__BOM_Component__c);
//                             }
//                             stockwrap.UpdatedBomList.add(bomwrap);
//                         }
//                     }
//                 }
//             }
//         }
//         return stockwrap;
//     } catch (Exception e) {
//         System.debug('Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
//         throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
//     } 
// }

    //below updated getupdatedstocksDC added by Abubakar on 14-sep-2026
    @AuraEnabled
    public static stockwrapper getupdatedstocksDC(String orditms, String chnId, String DCId, String OrdId, String LogItems, String idType) { 
        try {
            stockwrapper stockwrap = new stockwrapper();

            // Initialize wrapper lists
            if(stockwrap.UpdatedOrdList == null) stockwrap.UpdatedOrdList = new List<OrderItem>();
            if(stockwrap.ExplodedOrderItems == null) stockwrap.ExplodedOrderItems = new Map<Id, Boolean>();

            // 1. Handle Logistic Line Items (Common for all)
            if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(LogItems) && LogItems != null && LogItems != '[]') {
                List<ERP7__Logistic_Line_Item__c> logItemslist = (List<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LogItems, List<ERP7__Logistic_Line_Item__c>.class);
                Set<Id> productIds = new Set<Id>();
                for (ERP7__Logistic_Line_Item__c loli : logItemslist) {
                    if (loli.ERP7__Product__c != null) productIds.add(loli.ERP7__Product__c); 
                }
                
                ERP7__Distribution_Channel__c dc = [SELECT Id, ERP7__Site__c FROM ERP7__Distribution_Channel__c WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null LIMIT 1];
                
                if (dc.Id != null) {
                    Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
                    for (AggregateResult result : [SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock 
                                                  FROM ERP7__Inventory_Stock__c 
                                                  WHERE ERP7__product__c IN: productIds AND ERP7__Active__c = true 
                                                  AND (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 AND Name = 'Serial Stock Holder')) 
                                                  AND ERP7__Warehouse__c =: dc.ERP7__Site__c GROUP BY ERP7__Product__c]) {
                        stockMap.put((Id)result.get('ERP7__Product__c'), (Decimal)result.get('totalStock'));
                    }
                    for (ERP7__Logistic_Line_Item__c loli : logItemslist) {             
                        Decimal proStockCount = stockMap.containsKey(loli.ERP7__Product__c) ? stockMap.get(loli.ERP7__Product__c) : 0;
                        loli.ERP7__Fulfilled_Quantity__c = proStockCount;
                        stockwrap.UpdatedlogList.add(loli);
                    }
                }
            } 
            
            // ==========================================================================
            // LOGIC FOR SALES ORDERS (ERP7__Sales_Order__c)
            // ==========================================================================
            else if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(orditms) && idType == 'SalesOrder') {
                
                List<ERP7__Sales_Order_Line_Item__c> SoliList = (List<ERP7__Sales_Order_Line_Item__c>) JSON.deserialize(orditms, List<ERP7__Sales_Order_Line_Item__c>.class);
                Set<Id> productIds = new Set<Id>();
                Set<Id> soliIds = new Set<Id>();
                
                for(ERP7__Sales_Order_Line_Item__c s : SoliList){
                    if(s.ERP7__Product__c != null) productIds.add(s.ERP7__Product__c);
                    soliIds.add(s.Id);
                }

                ERP7__Distribution_Channel__c dc = [SELECT Id, ERP7__Site__c FROM ERP7__Distribution_Channel__c WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null LIMIT 1];
                
                if (dc.Id != null) {
                    // 1. Map stock by Product ID
                    Map<Id, Decimal> productStockMap = new Map<Id, Decimal>();
                    for (AggregateResult result : [SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock 
                                                FROM ERP7__Inventory_Stock__c 
                                                WHERE ERP7__product__c IN: productIds AND ERP7__Active__c = true 
                                                AND (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 AND Name = 'Serial Stock Holder')) 
                                                AND ERP7__Warehouse__c =: dc.ERP7__Site__c GROUP BY ERP7__Product__c]) {
                        productStockMap.put((Id)result.get('ERP7__Product__c'), (Decimal)result.get('totalStock'));
                    }
                    
                    // 2. Prepare for Exploded Check
                    Map<Id, ERP7__Sales_Order_Line_Item__c> explodedSoliMap = new Map<Id, ERP7__Sales_Order_Line_Item__c>([
                        SELECT Id, ERP7__Explode__c FROM ERP7__Sales_Order_Line_Item__c WHERE Id IN :soliIds AND ERP7__Explode__c = true
                    ]);
                    List<ERP7__Stock_Outward_Line_Item__c> stockOutwardItems = [
                        SELECT Id, ERP7__Sales_Order_Line_Item__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Sales_Order_Line_Item__c IN :soliIds
                    ];
                    List<ERP7__MRP__c> mrpRecords = [
                        SELECT Id, ERP7__Sales_Order_Line_Item__c FROM ERP7__MRP__c WHERE ERP7__Sales_Order_Line_Item__c IN :soliIds AND RecordType.Name = 'MRP Kit'
                    ];

                    // 3. Process each SOLI and create Wrapper
                    for (ERP7__Sales_Order_Line_Item__c soli : SoliList) {
                        SoliWrapper wrapper = new SoliWrapper();
                        wrapper.soli = soli;

                        // A. Calculate Reserved
                        Decimal proStockCount = productStockMap.containsKey(soli.ERP7__Product__c) ? productStockMap.get(soli.ERP7__Product__c) : 0;
                        wrapper.reservedQty = proStockCount;

                        // B. Calculate Remaining (Qty - LogisticQty)
                        Decimal qty = soli.ERP7__Quantity__c != null ? soli.ERP7__Quantity__c : 0;
                        Decimal logQty = soli.ERP7__Logistic_Quantity__c != null ? soli.ERP7__Logistic_Quantity__c : 0;
                        wrapper.remainingQty = qty - logQty;

                        // C. Determine Active Status (Logic from OrderItem)
                        Boolean isReadyToPickPack = (soli.ERP7__Sales_Order__r != null && soli.ERP7__Sales_Order__r.ERP7__Ready_To_Pick_Pack__c == true);
                        if(wrapper.remainingQty <= 0) {
                            wrapper.isActive = false;
                        } else if (wrapper.remainingQty > 0 && (wrapper.remainingQty <= proStockCount || isReadyToPickPack)) {
                            wrapper.isActive = true;
                        } else {
                            wrapper.isActive = false; // Not enough stock or other condition
                        }

                        // D. Determine Exploded Status
                        Boolean isExploded = explodedSoliMap.containsKey(soli.Id);
                        Boolean hasStockOutward = false;
                        Boolean hasMRP = false;
                        for(ERP7__Stock_Outward_Line_Item__c so : stockOutwardItems){
                            if(so.ERP7__Sales_Order_Line_Item__c == soli.Id) { hasStockOutward = true; break; }
                        }
                        for(ERP7__MRP__c mrp : mrpRecords){
                            if(mrp.ERP7__Sales_Order_Line_Item__c == soli.Id) { hasMRP = true; break; }
                        }
                        wrapper.isExploded = (isExploded && hasStockOutward && hasMRP);

                        stockwrap.UpdatedSoliListWrapper.add(wrapper);
                    }

                    // 4. Handle BOM/Kits for SOLI (Populate UpdatedBomList)
                    // [Insert logic to query BOMs and fill stockwrap.UpdatedBomList based on SOLI products]
                    // This logic mirrors the OrderItem BOM logic but uses SOLI fields.
                    Set<Id> priceBookIds = new Set<Id>();
                    List<Id> bomVersions = new List<Id>();
                    Set<Id> kitProductIds = new Set<Id>();

                    for (ERP7__Sales_Order_Line_Item__c soli : SoliList) {
                        if (soli.ERP7__Is_Kit__c == true && soli.ERP7__Inventory_Tracked__c == false) {
                            kitProductIds.add(soli.ERP7__Product__c);
                            if (soli.ERP7__PriceBookId__c != null) priceBookIds.add(soli.ERP7__PriceBookId__c);
                            if (soli.ERP7__Version__c != null) bomVersions.add(soli.ERP7__Version__c);
                        }
                    }
                
                    if (!kitProductIds.isEmpty()) {
                        // Fetch BOMs (Using same query logic as OrderItem but adapted)
                        List<ERP7__BOM__c> BOMList = new List<ERP7__BOM__c>();
                        if(!bomVersions.isEmpty()){
                            BOMList = [SELECT Id, Name, ERP7__Active__c, ERP7__BOM_Product__c, ERP7__BOM_Component__c, ERP7__Quantity__c,
                                        BOM_Version__c, BOM_Version__r.Status__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c 
                                        FROM ERP7__BOM__c
                                        WHERE BOM_Version__c IN :bomVersions AND BOM_Version__r.Status__c = 'Certified'];
                        }

                        Set<Id> bomComponentIds = new Set<Id>();
                        for (ERP7__BOM__c b : BOMList) bomComponentIds.add(b.ERP7__BOM_Component__c);

                        if (dc.Id != null) {
                            // Get Inventory for BOM Components
                            Map<Id, Decimal> compStockMap = new Map<Id, Decimal>();
                            for (AggregateResult result : [SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock 
                                                        FROM ERP7__Inventory_Stock__c 
                                                        WHERE ERP7__product__c IN: bomComponentIds AND ERP7__Active__c = true 
                                                        AND ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =: dc.ERP7__Site__c GROUP BY ERP7__Product__c]) {
                                compStockMap.put((Id)result.get('ERP7__Product__c'), (Decimal)result.get('totalStock'));
                            }

                            // Get Pricebook Entries for BOM Components
                            // Note: SOLIs might have different Pricebooks, we collect all relevant PBEs
                            List<PricebookEntry> pbeList = [SELECT UnitPrice, ERP7__Purchase_Price__c, Product2.Id, Product2.Name 
                                                            FROM PricebookEntry 
                                                            WHERE Pricebook2Id IN :priceBookIds AND Product2Id IN :bomComponentIds AND IsActive = TRUE];
                            Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
                            for(PricebookEntry p : pbeList) pbeMap.put(p.Product2Id, p);

                            // Process BOM Wrappers
                            for (ERP7__Sales_Order_Line_Item__c soli : SoliList) {
                                if (soli.ERP7__Is_Kit__c == true && soli.ERP7__Inventory_Tracked__c == false) {
                                    for (ERP7__BOM__c bom : BOMList) {
                                        if (bom.ERP7__BOM_Component__c != null && bom.ERP7__BOM_Product__c == soli.ERP7__Product__c) {
                                            // Create Clone of BOM to adjust quantity
                                            ERP7__BOM__c bomClone = bom.clone(true, true, true, true);
                                            Decimal soliQty = soli.ERP7__Quantity__c != null ? soli.ERP7__Quantity__c : 0;
                                            bomClone.ERP7__Quantity__c = (bom.ERP7__Quantity__c != null ? bom.ERP7__Quantity__c : 0) * soliQty;
                                            
                                            bomwrapper bw = new bomwrapper();
                                            bw.Bom = bomClone;
                                            bw.stock = compStockMap.containsKey(bom.ERP7__BOM_Component__c) ? compStockMap.get(bom.ERP7__BOM_Component__c) : 0;
                                            bw.OrderProdId = soli.Id; // Mapping SOLI Id here
                                            if (pbeMap.containsKey(bom.ERP7__BOM_Component__c)) bw.pbe = pbeMap.get(bom.ERP7__BOM_Component__c);
                                            
                                            stockwrap.UpdatedBomList.add(bw);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // ==========================================================================
            // LOGIC FOR STANDARD ORDERS (Order)
            // ==========================================================================
            else if (String.isNotEmpty(chnId) && String.isNotEmpty(DCId) && String.isNotEmpty(orditms) && idType == 'Order') { //  && idType == 'Order' (Optional check)
                
                // --- A. Deserialize & Update Stock for Order Items ---
                List<OrderItem> Ordlist = (List<OrderItem>) JSON.deserialize(orditms, List<OrderItem>.class);
                List<String> productIds = new List<String>();
                Set<Id> orderItemIds = new Set<Id>();
                
                for (OrderItem soli : Ordlist) {
                    if (soli.Product2Id != null) {
                        if (!productIds.contains(soli.Product2Id)) productIds.add(soli.Product2Id);
                    }
                    orderItemIds.add(soli.Id);
                }    
                
                ERP7__Distribution_Channel__c dc = [SELECT Id, ERP7__Site__c FROM ERP7__Distribution_Channel__c WHERE Id =: DCId AND ERP7__Channel__c =: chnId AND ERP7__Site__c != null LIMIT 1];
                
                if (dc.Id != null) {
                    Map<Id, Decimal> productStockMap = new Map<Id, Decimal>();
                    for (AggregateResult result : [SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock 
                                                  FROM ERP7__Inventory_Stock__c 
                                                  WHERE ERP7__product__c IN: productIds AND ERP7__Active__c = true 
                                                  AND (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 AND Name = 'Serial Stock Holder')) 
                                                  AND ERP7__Warehouse__c =: dc.ERP7__Site__c GROUP BY ERP7__Product__c]) {
                        productStockMap.put((Id)result.get('ERP7__Product__c'), (Decimal)result.get('totalStock'));
                    }

                    for (OrderItem soli : Ordlist) {                   
                        Decimal proStockCount = productStockMap.containsKey(soli.Product2Id) ? productStockMap.get(soli.Product2Id) : 0;
                        soli.ERP7__Reserved_Quantity__c = proStockCount;
                        soli.ERP7__Remaining_Quantity__c = soli.Quantity - soli.ERP7__Logistic_Quantity__c;
                        stockwrap.UpdatedOrdList.add(soli);
                    }

                    // --- B. Explode Logic for Order Item ---
                    Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>([
                        SELECT Id, ERP7__Explode__c FROM OrderItem WHERE Id IN :orderItemIds AND ERP7__Explode__c = true
                    ]);
                    List<ERP7__Stock_Outward_Line_Item__c> stockOutwardItems = [
                        SELECT Id, ERP7__Order_Product__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Order_Product__c IN :orderItemIds
                    ];
                    List<ERP7__MRP__c> mrpRecords = [
                        SELECT Id, ERP7__Order_Product__c FROM ERP7__MRP__c WHERE ERP7__Order_Product__c IN :orderItemIds AND RecordType.Name = 'MRP Kit'
                    ];
                    
                    for (Id oiId : orderItemIds) {
                        Boolean isExploded = orderItemMap.containsKey(oiId);
                        Boolean hasStockOutward = false; 
                        Boolean hasMRP = false;
                        for (ERP7__Stock_Outward_Line_Item__c soli : stockOutwardItems) {
                            if (soli.ERP7__Order_Product__c == oiId) { hasStockOutward = true; break; }
                        }
                        for (ERP7__MRP__c mrp : mrpRecords) {
                            if (mrp.ERP7__Order_Product__c == oiId) { hasMRP = true; break; }
                        }
                        stockwrap.ExplodedOrderItems.put(oiId, isExploded && hasStockOutward && hasMRP);
                    }

                    // --- C. Handle BOM/Kits for Order Item ---
                    Set<Id> proIds = new Set<Id>(); 
                    Set<Id> priceBookIds = new Set<Id>();    
                    List<Id> soliBOMVersion = new List<Id>(); 
                    Map<Id, Id> prodMap = new Map<Id, Id>();
                    
                    for (OrderItem Foli : Ordlist) {
                        if (!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c) {
                            proIds.add(Foli.Product2Id); 
                            if (Foli.ERP7__PriceBookId__c != null) priceBookIds.add(Foli.ERP7__PriceBookId__c);
                            if (Foli.ERP7__Version__c != null) soliBOMVersion.add(Foli.ERP7__Version__c);
                            prodMap.put(Foli.Product2Id, Foli.Id);
                        }
                    }
                    
                    if (proIds.size() > 0 && !soliBOMVersion.isEmpty()) {
                        List<ERP7__BOM__c> BOMList = [
                            SELECT Id, Name, ERP7__Active__c, ERP7__BOM_Product__c, ERP7__BOM_Component__c, ERP7__Quantity__c,
                                   BOM_Version__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c
                            FROM ERP7__BOM__c
                            WHERE BOM_Version__c IN :soliBOMVersion AND BOM_Version__r.Status__c = 'Certified'
                        ];
                        
                        Set<Id> BomproductIds = new Set<Id>();
                        for (ERP7__BOM__c bomItems : BOMList) BomproductIds.add(bomItems.ERP7__BOM_Component__c);

                        // Get Inventory for BOM Components
                        Map<Id, Decimal> compStockMap = new Map<Id, Decimal>();
                        for (AggregateResult result : [SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock 
                                                      FROM ERP7__Inventory_Stock__c 
                                                      WHERE ERP7__product__c IN: BomproductIds AND ERP7__Active__c = true 
                                                      AND ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =: dc.ERP7__Site__c GROUP BY ERP7__Product__c]) {
                            compStockMap.put((Id)result.get('ERP7__Product__c'), (Decimal)result.get('totalStock'));
                        }

                        // Get Pricebook ID (Assuming single order pricebook for standard order)
                        List<Order> orderdetails = [SELECT Pricebook2Id FROM Order WHERE Id = :OrdId LIMIT 1];
                        List<String> targetPricebookId = new List<String>();
                        if (!orderdetails.isEmpty()) targetPricebookId.add(orderdetails[0].Pricebook2Id);
                        
                        List<PricebookEntry> pbe = new List<PricebookEntry>();
                        if(targetPricebookId.size() > 0){
                            pbe = [SELECT UnitPrice, Product2.Id, Product2.Name FROM PricebookEntry 
                                   WHERE Pricebook2Id IN: targetPricebookId AND Product2Id IN: BomproductIds AND IsActive = TRUE];
                        }
                        Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
                        for (PricebookEntry pb : pbe) pbeMap.put(pb.Product2.Id, pb);
                        
                        // Create Wrapper
                        for (OrderItem Foli : Ordlist) {
                            if (!Foli.ERP7__Inventory_Tracked__c && Foli.Is_Kit__c) {
                                for (ERP7__BOM__c bom : BOMList) {
                                    if (bom.ERP7__BOM_Component__c != null && bom.ERP7__BOM_Product__c == Foli.Product2Id) {
                                        ERP7__BOM__c bomClone = bom.clone(true, true, true, true);
                                        bomClone.ERP7__Quantity__c = (bom.ERP7__Quantity__c != null ? bom.ERP7__Quantity__c : 0) * (Foli.Quantity != null ? Foli.Quantity : 0);
                                        
                                        bomwrapper bomwrap = new bomwrapper();
                                        bomwrap.stock = compStockMap.containsKey(bom.ERP7__BOM_Component__c) ? compStockMap.get(bom.ERP7__BOM_Component__c) : 0;
                                        bomwrap.Bom = bomClone;
                                        if (prodMap.containsKey(bom.ERP7__BOM_Product__c)) bomwrap.OrderProdId = prodMap.get(bom.ERP7__BOM_Product__c);
                                        if (pbeMap.containsKey(bom.ERP7__BOM_Component__c)) bomwrap.pbe = pbeMap.get(bom.ERP7__BOM_Component__c);
                                        
                                        stockwrap.UpdatedBomList.add(bomwrap);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return stockwrap;
        } catch (Exception e) {
            System.debug('Exception ~> ' + e.getMessage() + '; at line ~> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getStackTraceString());
        } 
    }

    
    public class bomwrapper{
        
        @AuraEnabled public Decimal stock                               { get; set; }
        @AuraEnabled public ERP7__BOM__c Bom                            { get; set; }
        @AuraEnabled public PricebookEntry pbe                          { get; set; }
        @AuraEnabled public Id OrderProdId                              { get; set; }
        public bomwrapper(){    
            OrderProdId = null; 
            pbe = new PricebookEntry();
            stock=0;
            Bom = new ERP7__BOM__c();
        }
    }
    
    public  class stockwrapper {
        @AuraEnabled public List<OrderItem> UpdatedOrdList { get; set; } 
        @AuraEnabled public List<SoliWrapper> UpdatedSoliListWrapper { get; set; }
        @AuraEnabled public List<bomwrapper> UpdatedBomList { get; set; }
        @AuraEnabled public List<ERP7__Logistic_Line_Item__c> UpdatedlogList { get; set; }
        @AuraEnabled public Map<Id, Boolean> ExplodedOrderItems { get; set; } 
        
        public stockwrapper (){
            UpdatedlogList = new List<ERP7__Logistic_Line_Item__c>();
            UpdatedOrdList = new List<OrderItem>();
            UpdatedSoliListWrapper = new List<SoliWrapper>();
            UpdatedBomList = new List<bomwrapper>();
            ExplodedOrderItems = new Map<Id, Boolean>();
        }
    }
    
    public class SoliWrapper {
        @AuraEnabled public ERP7__Sales_Order_Line_Item__c soli {get;set;}
        @AuraEnabled public Decimal remainingQty {get;set;}
        @AuraEnabled public Decimal reservedQty {get;set;}
        @AuraEnabled public Boolean isActive {get;set;}
        @AuraEnabled public Boolean isExploded {get;set;}
        
        public SoliWrapper(){
            soli = new ERP7__Sales_Order_Line_Item__c();
            remainingQty = 0;
            reservedQty = 0;
            isActive = false;
            isExploded = false;
        }
    }

    @AuraEnabled
    public static String getStoreAddress(String chanId){ 
        String DCId = '';
        list<ERP7__Distribution_Channel__c> dc = new list<ERP7__Distribution_Channel__c>();
        dc = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c
              FROM ERP7__Distribution_Channel__c
              WHERE ERP7__Channel__c=:chanId AND ERP7__Site__c != null order by createdDate DESC];
        
        
        if(dc.size()==1) DCId = dc[0].Id;
        return DCId; 
    }
    
    @AuraEnabled
    public static ERP7__Logistic_Line_Item__c getLLIInstance(){
        return new ERP7__Logistic_Line_Item__c();        
    }
    
    @AuraEnabled
    public static ERP7__Logistic__c getLogisticInstance(){
        return new ERP7__Logistic__c();        
    }
    
    @AuraEnabled
    public static logWrap getLogisticAndItems(string LogisticId){
        logWrap wrap = new logWrap();
        if(LogisticId != null && LogisticId != ''){
            wrap.logistic= [Select Id, Name, ERP7__Account__c,ERP7__From_Address__c,ERP7__From_Contact__c, ERP7__Account__r.Name, ERP7__Contact__c, ERP7__Contact__r.Name, ERP7__To_Address__c, ERP7__To_Address__r.Name, ERP7__Ready_To_Ship__c,  ERP7__Channel__c, ERP7__Channel__r.Id, ERP7__Channel__r.Name, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Id, ERP7__Distribution_Channel__r.Name, 
                            ERP7__Shipment_type__c, ERP7__Shipping_Preferences__c, ERP7__Billing_options__c, ERP7__Billing_Account_number__c, ERP7__Billing_Country_Code__c, ERP7__Billing_Postal_Code__c, ERP7__Billing_Contact__c, ERP7__Billing_Address__c, ERP7__Special_Instructions__c,
                            ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c, ERP7__Shipment_type_Return__c, ERP7__Shipping_Preferences_Return__c from ERP7__Logistic__c where Id=:LogisticId limit 1];
            system.debug('wrap.logistic.ERP7__Shipping_Preferences__c : '+wrap.logistic.ERP7__Shipping_Preferences__c);
             system.debug('wrap.logistic.ERP7__Shipping_Preferences_Return__c : '+wrap.logistic.ERP7__Shipping_Preferences_Return__c);
            wrap.shipPreferences =wrap.logistic.ERP7__Shipping_Preferences__c;
            wrap.shipReturnPreferences = wrap.logistic.ERP7__Shipping_Preferences_Return__c;
            wrap.logItems = [Select Id,Name,ERP7__Product__c,ERP7__Fulfilled_Quantity__c,ERP7__Product__r.Id,ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Price_Product__c from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c = :LogisticId];
            return wrap;
        } 
        else return null;
    }

    //Commented by Arshad 09 Aug 2023
    /*
    @AuraEnabled
    public static String getCreateLogistic(String LogisticJSON, String LLIListJSON,String OrderLIneItems,String BomItems){ 
        try{
            
            list<OrderItem> Orditem = (OrderLIneItems != '') ? (list<OrderItem>) JSON.deserialize(OrderLIneItems, list<OrderItem> .class) : new list<OrderItem>();
            list<ERP7__BOM__c> bomitem = (BomItems != '') ? (list<ERP7__BOM__c>) JSON.deserialize(BomItems, list<ERP7__BOM__c> .class) : new list<ERP7__BOM__c>();
            
            Id rTpe_MRPKIT; rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
            list<ERP7__MRP__c> MRPS2Insert = new list<ERP7__MRP__c>();
            map<string,ERP7__MRP__c> MRPmap = new map<string,ERP7__MRP__c>();
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            for(OrderItem orditm:Orditem){
                if(orditm.Product2.ERP7__Is_Kit__c){
                    for(ERP7__BOM__c bom:bomitem){
                        ERP7__MRP__c MRP = new ERP7__MRP__c();
                        if(orditm.Product2Id == bom.ERP7__BOM_Product__c){
                            if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()){MRP.Name = bom.Name;} else{ } 
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()){MRP.ERP7__Total_Amount_Required__c = bom.Quantity__c*orditm.Quantity; } else{ } 
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()){MRP.ERP7__BOM__c = bom.Id;} else {  } 
                            if(Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isUpdateable()){MRP.Version__c = orditm.Version__c; } else{   } 
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()){MRP.ERP7__MRP_Product__c = bom.ERP7__BOM_Component__c; } else{  }  
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Order_Product__c.isUpdateable()){MRP.ERP7__Order_Product__c = orditm.Id;} else {  }   
                            if(rTpe_MRPKIT != null && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isUpdateable()){ MRP.RecordTypeId = rTpe_MRPKIT; } else{  }  
                            if(orditm.ERP7__Insufficient_BOM__c != true &&  Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isUpdateable()) {MRP.Status__c = 'Reserved'; } else { }   
                            MRPS2Insert.add(MRP);      
                        }
                    }
                }
            }   
            
            if (MRPS2Insert.size() > 0 && Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) { 
                upsert MRPS2Insert;  system.debug('inside MRP Creation1-->:');
                
                for(ERP7__MRP__c Mrp :MRPS2Insert){
                    MRPmap.put(Mrp.ERP7__MRP_Product__c,Mrp);
                }
                system.debug('MRPmap:-->'+MRPmap);
                
            } else{  }   
            
            ERP7__Logistic__c Logistic = (ERP7__Logistic__c) JSON.deserialize(LogisticJSON, ERP7__Logistic__c .class);
            system.debug('Logistic : '+Logistic.ERP7__Shipping_Preferences__c);
            System.debug('Logistic Order : '+Logistic.ERP7__Order_S__c);
            Id orderId = Logistic.ERP7__Order_S__c;
            String SORecTypeId='';
            if(String.isNotEmpty(Logistic.ERP7__Sales_Order__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','SO');
            if(String.isNotEmpty(Logistic.ERP7__Order_S__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Order');
            if(String.isNotEmpty(Logistic.ERP7__Purchase_Order__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Purchase_Order');
            Logistic.RecordTypeId = SORecTypeId;
            system.debug('RecordTypeId : '+Logistic.RecordTypeId);
            list<ERP7__Logistic_Line_Item__c> LogisticLI = (list<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LLIListJSON, list<ERP7__Logistic_Line_Item__c> .class); 
            
            set<String> proList=new set<String>();
            set<Id> OrderProdIds=new set<Id>();
            
            for(ERP7__Logistic_Line_Item__c log:LogisticLI){
                if(log.ERP7__Product__c != null && !proList.contains(log.ERP7__Product__c)) proList.add(log.ERP7__Product__c);
                if(log.ERP7__Order_Product__c != null) OrderProdIds.add(log.ERP7__Order_Product__c);
            }
            
            List<Product2> proList1 = [Select Id,Name,ERP7__Serialise__c,ERP7__Lot_Tracked__c,ERP7__Track_Inventory__c from Product2 where Id In:proList];
            Map<String,String> proName=new Map<String,String>();
            Map<String,Boolean> proSerial=new Map<String,Boolean>();
            
            for(Product2 pr:proList1){
                proName.put(pr.Id,pr.Name);
                proSerial.put(pr.Id,pr.ERP7__Serialise__c);
            } 
            
            ERP7__Distribution_Channel__c dc = [Select Id,Name,ERP7__Site__c from ERP7__Distribution_Channel__c where Id=:Logistic.ERP7__Distribution_Channel__c Limit 1];
            List<ERP7__Manufacturing_Order__c> SOMOs = new List<ERP7__Manufacturing_Order__c>();
            List<ERP7__PO__c> SOPOs = new List<ERP7__PO__c>();
            
            List<ERP7__Inventory_Stock__c> invtoryList = new List<ERP7__Inventory_Stock__c>();
            
            system.debug('orderId~>'+orderId);
            if(orderId != null && OrderProdIds.size() > 0 && proList.size() > 0){
                SOMOs = [Select Id,Name from ERP7__Manufacturing_Order__c where (ERP7__Order_Product__c IN:OrderProdIds and ERP7__Order__c =:orderId) and ERP7__Product__c IN:proList];
                System.debug('SOMOs : '+SOMOs.size());    
                
                SOPOs = [Select Id,Name from ERP7__PO__c where ERP7__Order__c =:orderId and ERP7__Ready_To_Receive__c =:true];
                System.debug('SOPOs : '+SOPOs.size()); 
            }
            
            if(SOMOs.size() > 0 || SOPOs.size() > 0){
                set<Id> MoIds = new set<Id>();
                set<Id> PoIds = new set<Id>();
                set<Id> InvIds = new set<Id>();
                
                for(ERP7__Manufacturing_Order__c MO : SOMOs) MoIds.add(MO.Id);
                for(ERP7__PO__c PO : SOPOs) PoIds.add(PO.Id);
                system.debug('MoIds ~>'+MoIds);
                
                List<ERP7__Stock_Inward_Line_Item__c> stinlist = [Select Id,Name,Product__c,ERP7__Site_ProductService_InventoryStock__c from ERP7__Stock_Inward_Line_Item__c 
                                                                  where ERP7__Active__c = true and Product__c IN :proList and ERP7__Scrap__c = false AND (ERP7__Purchase_Orders__c IN:PoIds or ERP7__Manufacturing_Order__c IN: MoIds) 
                                                                  AND ERP7__Quantity__c > 0 AND ERP7__Status__c != 'Awaiting Stock'];
                
                for(ERP7__Stock_Inward_Line_Item__c sin : stinlist) InvIds.add(sin.ERP7__Site_ProductService_InventoryStock__c);
                system.debug('InvIds ~>'+InvIds);
                
                invtoryList = [Select Id, Name, Active__c, Organisation__c,  Warehouse__c, Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,Product__c,  Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, 
                               Number_of_Items_Dispatched__c, No_of_Items_Sold__c, Checked_In_Date__c From Inventory_Stock__c
                               Where ERP7__product__c != null and Product__c In: proList And Active__c = true And Warehouse__c  =:dc.ERP7__Site__c
                               AND Id IN:InvIds //(ERP7__Manufacturing_Order__c In:MoIds or 
                               AND Name != 'Awaiting Stock' And Number_of_Item_In_Stock__c > 0 Order By Checked_In_Date__c ASC]; 
            }
            else{
                invtoryList = [Select Id,Name,ERP7__Product__c,ERP7__Warehouse__c, ERP7__Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,ERP7__Number_of_Item_In_Stock__c, 
                             ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c, ERP7__Checked_In_Date__c  from ERP7__Inventory_Stock__c
                             where ERP7__product__c != null AND ERP7__product__c In:proList And ERP7__Active__c = true AND ERP7__Warehouse__c =:dc.ERP7__Site__c and Name != 'Awaiting Stock'
                             And ERP7__Number_of_Item_In_Stock__c > 0 ORDER BY createdDate ASC];
            }
            
            Map<String,ERP7__Inventory_Stock__c> proInv = new Map<String,ERP7__Inventory_Stock__c>();
            for(ERP7__Inventory_Stock__c invt:invtoryList){
                if(proInv.get(invt.ERP7__Product__c) == null) proInv.put(invt.ERP7__Product__c,invt);
            }
            
            for(ERP7__Logistic_Line_Item__c log:LogisticLI){
                if(!proInv.containsKey(log.ERP7__Product__c)) return 'Does not have inventory for product :'+proName.get(log.ERP7__Product__c)+' on selected distribution Centers site';
            }
            
            if(String.isNotEmpty(Logistic.ERP7__Sales_Order__c)){
                ERP7__Sales_Order__c SalOrder=new ERP7__Sales_Order__c();      
                SalOrder=[SELECT Id, Name, Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__c FROM ERP7__Sales_Order__c WHERE Id=:Logistic.ERP7__Sales_Order__c]; 
                if(SalOrder.ERP7__Channel__c != null){
                    if(SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c != null){
                        Logistic.ERP7__From_Address__c = SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c; 
                    }
                }
            }  
            else if(String.isNotEmpty(Logistic.ERP7__Order_S__c)){
                Order SalOrder=new Order();   SalOrder=[SELECT Id, Name, Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__c,ERP7__Shipment_Type__c, ERP7__Shipment_Preference_Speed__c, BillToContactId, ERP7__Bill_To_Address__c, ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c  FROM Order WHERE Id=:Logistic.ERP7__Order_S__c]; 
                if(SalOrder.ERP7__Channel__c != null){
                    if(SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c != null){
                        Logistic.ERP7__From_Address__c = SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c;  
                    }
                } 
                if(Logistic.ERP7__Shipment_Type__c == null || Logistic.ERP7__Shipment_Type__c == '') Logistic.ERP7__Shipment_Type__c = SalOrder.ERP7__Shipment_Type__c;
                system.debug('Logistic.ERP7__Shipment_Type__c : '+Logistic.ERP7__Shipment_Type__c);
            }
            else if(String.isNotEmpty(Logistic.ERP7__Purchase_Order__c)){
                String PORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Purchase_Order'); 
                Logistic.RecordTypeId = PORecTypeId;
            }
            
            if(Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isUpdateable()){ upsert Logistic; } 
            else{ return 'Don\'t have access to upsert logistic'; }
            
            list<String> SOLIIds=new list<String>();
            list<String> ordItemIds=new list<String>();
            list<String> POItemIds=new list<String>();
            
            for(ERP7__Logistic_Line_Item__c log:LogisticLI){
                log.ERP7__Status__c = 'Reserved';
                log.ERP7__Logistic__c=Logistic.Id;
                if(log.ERP7__Sales_Order_Line_Item__c !=null) SOLIIds.add(log.ERP7__Sales_Order_Line_Item__c);
                if(log.ERP7__Order_Product__c !=null) ordItemIds.add(log.ERP7__Order_Product__c);
                if(log.ERP7__Purchase_Line_Items__c !=null) POItemIds.add(log.ERP7__Purchase_Line_Items__c);                
            }
            
            if(LogisticLI.size() > 0){
                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable()){ 
                    upsert LogisticLI; 
                } else{ return 'Does not have access to upsert logistic line items'; } 
            }
            
            List<ERP7__Stock_Outward_Line_Item__c> SWLIToUpsert=new List<ERP7__Stock_Outward_Line_Item__c>();
            
            for(ERP7__Logistic_Line_Item__c log:LogisticLI){
                if(log.ERP7__Product__c != null && log.ERP7__Quantity__c > 0 && ((Logistic.ERP7__Sales_Order__c != null && log.ERP7__Sales_Order_Line_Item__c != null) || (Logistic.ERP7__Order_S__c != null && log.ERP7__Order_Product__c != null))){
                    if(Logistic.ERP7__Purchase_Order__c == null && proInv.containsKey(log.ERP7__Product__c) && proSerial.containsKey(log.ERP7__Product__c)){
                        Integer loopquantity = 1;
                        if(proSerial.get(log.ERP7__Product__c)){
                            loopquantity = Integer.valueof(log.ERP7__Quantity__c);
                        }
                        for(Integer i=0; i<loopquantity; i++){
                            ERP7__Stock_Outward_Line_Item__c sto = new ERP7__Stock_Outward_Line_Item__c();
                            sto.Name = log.Name; 
                            
                            if(log.ERP7__Sales_Order_Line_Item__c != null) sto.ERP7__Sales_Order_Line_Item__c = log.ERP7__Sales_Order_Line_Item__c; 
                            if(Logistic.ERP7__Sales_Order__c != null) sto.ERP7__Sales_Order__c = Logistic.ERP7__Sales_Order__c;
                            
                            if(log.ERP7__Order_Product__c != null) sto.ERP7__Order_Product__c = log.ERP7__Order_Product__c;
                            if(Logistic.ERP7__Order_S__c != null) sto.ERP7__Order__c = Logistic.ERP7__Order_S__c; 
                            
                            sto.ERP7__Product__c = log.ERP7__Product__c;
                            sto.ERP7__Active__c = true; 
                            sto.ERP7__Status__c = 'Reserved'; 
                            
                            if(proSerial.get(log.ERP7__Product__c)) sto.ERP7__Quantity__c = 1;
                            else sto.ERP7__Quantity__c = log.ERP7__Quantity__c; 
                            
                            sto.ERP7__Site_Product_Service_Inventory_Stock__c = proInv.get(log.ERP7__Product__c).Id; 
                            sto.ERP7__Logistic_Line_Item__c = log.Id;
                            
                            if(MRPmap.containsKey(log.ERP7__Product__c)) sto.ERP7__MRP_Material_Requirements_Planning__c = MRPmap.get(log.ERP7__Product__c).Id;
                            
                            if(proInv.get(log.ERP7__Product__c).ERP7__Serial__c != null) sto.ERP7__Serial__c = proInv.get(log.ERP7__Product__c).ERP7__Serial__c;
                            if(proInv.get(log.ERP7__Product__c).ERP7__Batch_Lot__c != null) sto.ERP7__Material_Batch_Lot__c = proInv.get(log.ERP7__Product__c).ERP7__Batch_Lot__c;
                            if(proInv.get(log.ERP7__Product__c).ERP7__Version__c != null) sto.ERP7__Version__c = proInv.get(log.ERP7__Product__c).ERP7__Version__c;
                            
                            SWLIToUpsert.add(sto);
                        }
                        //break;
                    }
                }
            }
            
            set<Id> serialIds = new set<Id>();
            for(ERP7__Stock_Outward_Line_Item__c ppli : SWLIToUpsert){
                system.debug('ppli.ERP7__Serial__c  bf: '+ppli.ERP7__Serial__c );
                serialIds.add(ppli.ERP7__Serial__c);
                if(ppli.ERP7__Serial__c != null){
                    for(ERP7__Inventory_Stock__c invt:invtoryList){
                        system.debug('serialIds.contains(invt.ERP7__Serial__c) : '+serialIds.contains(invt.ERP7__Serial__c));
                        if(ppli.ERP7__Product__c == invt.ERP7__Product__c && invt.ERP7__Serial__c != ppli.ERP7__Serial__c && ppli.ERP7__Site_Product_Service_Inventory_Stock__c != invt.Id && !serialIds.contains(invt.ERP7__Serial__c)){
                            
                            ppli.ERP7__Serial__c = invt.ERP7__Serial__c;
                            system.debug('ppli.ERP7__Serial__c after : '+ppli.ERP7__Serial__c );
                            ppli.ERP7__Site_Product_Service_Inventory_Stock__c = invt.Id;
                            serialIds.add(ppli.ERP7__Serial__c);
                            break;
                        }
                    }
                }
            }
            
            if(SWLIToUpsert.size() > 0){
                if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()) {
                    system.debug('SWLIToUpsert size~>'+SWLIToUpsert.size());
                    upsert SWLIToUpsert; 
                }  else{ return 'Don\'t have access to upsert Stock Outward'; }
            } 
            
            if(SOLIIds.size()>0){
                list<ERP7__Logistic_Line_Item__c> LogLIList=new list<ERP7__Logistic_Line_Item__c>();
                LogLIList=[SELECT Id, Name, ERP7__Quantity__c, ERP7__Sales_Order_Line_Item__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Sales_Order_Line_Item__c IN:SOLIIds];
                
                for(ERP7__Sales_Order_Line_Item__c soli:[SELECT Id, ERP7__Logistic_Quantity__c FROM ERP7__Sales_Order_Line_Item__c WHERE Id IN:SOLIIds]){ 
                    Decimal LogQuantity=0; 
                    for(ERP7__Logistic_Line_Item__c logLi:LogLIList){ 
                        if(logLi.ERP7__Sales_Order_Line_Item__c==soli.Id) LogQuantity+=logLi.ERP7__Quantity__c;                                           
                    }
                    soli.ERP7__Logistic_Quantity__c=LogQuantity;
                    try{  if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Logistic_Quantity__c.isUpdateable()){  update soli; } else { return 'User is allowed to update SalesOrder Line Item';} }catch(DMLException e){ return e.getMessage() +','+e.getStackTraceString();}     
                } 
            } 
            // Commented as the code was updatng the order product logistic Qty twice
            // else if(ordItemIds.size()>0){
            // list<OrderItem> OrdItems2Update = new list<OrderItem>();
            // list<ERP7__Logistic_Line_Item__c> LogLIList=new list<ERP7__Logistic_Line_Item__c>();
            // LogLIList=[SELECT Id, Name, ERP7__Quantity__c, ERP7__Order_Product__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Order_Product__c IN:ordItemIds];
            
            // for(OrderItem soli:[SELECT Id, ERP7__Logistic_Quantity__c FROM OrderItem WHERE Id IN:ordItemIds]){ 
            // Decimal LogQuantity=0; 
            // for(ERP7__Logistic_Line_Item__c logLi:LogLIList){
            // if(logLi.ERP7__Order_Product__c==soli.Id && logLi.ERP7__Quantity__c != null){
            // if(logLi.ERP7__Quantity__c > 0) LogQuantity += logLi.ERP7__Quantity__c;    
            // }
            // }
            // system.debug('LogQuantity : '+LogQuantity);
            // if(soli.ERP7__Logistic_Quantity__c != null) soli.ERP7__Logistic_Quantity__c = soli.ERP7__Logistic_Quantity__c + LogQuantity;
            // else soli.ERP7__Logistic_Quantity__c = LogQuantity;
            // system.debug('soli.ERP7__Logistic_Quantity__c : '+soli.ERP7__Logistic_Quantity__c);
            // OrdItems2Update.add(soli);
            // }
            // if(OrdItems2Update.size()>0) Update OrdItems2Update;
            // }
            else if(POItemIds.size() > 0){
                list<ERP7__Logistic_Line_Item__c> LogLIList=new list<ERP7__Logistic_Line_Item__c>();
                LogLIList=[SELECT Id, Name, ERP7__Quantity__c, ERP7__Purchase_Line_Items__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Purchase_Line_Items__c IN:POItemIds];
                
                for(ERP7__Purchase_Line_Items__c poli:[SELECT Id, ERP7__Logistic_Quantity__c FROM ERP7__Purchase_Line_Items__c WHERE Id IN:POItemIds]){ 
                    Decimal LogQuantity=0; 
                    for(ERP7__Logistic_Line_Item__c logLi:LogLIList){
                        if(logLi.ERP7__Purchase_Line_Items__c==poli.Id) LogQuantity+=logLi.ERP7__Quantity__c;                                           
                    }
                    poli.ERP7__Logistic_Quantity__c=LogQuantity;
                    try{  if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Logistic_Quantity__c.isUpdateable())  { update poli; } else{ return 'User is not allowed to update POLI'; } }catch(DMLException e){return e.getMessage() +','+e.getStackTraceString();}     
                } 
            }
            //return Logistic.Id;
            return null;
            
        }catch(Exception ex){
            System.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString());
            return ex.getMessage() +','+ex.getStackTraceString();
        }    
    }
    */
    
    //Added by Arshad 09 Aug 2023
    // @AuraEnabled
    // public static String getCreateLogistic(String LogisticJSON, String LLIListJSON,String OrderLIneItems,String BomItems){ 
    //     try{
    //         system.debug('getCreateLogistic called');
    //         System.debug('LogisticJson ->'+LogisticJSON);
    //         System.debug('LLIListJSON '+LLIListJSON);
    //         System.debug('OrderLIneItems '+OrderLIneItems);
    //         System.debug('BomItems '+BomItems);
            
    //         list<OrderItem> Orditem = (OrderLIneItems != '') ? (list<OrderItem>) JSON.deserialize(OrderLIneItems, list<OrderItem> .class) : new list<OrderItem>();
    //         list<ERP7__BOM__c> bomitem = (BomItems != '') ? (list<ERP7__BOM__c>) JSON.deserialize(BomItems, list<ERP7__BOM__c> .class) : new list<ERP7__BOM__c>();
            
    //         Id rTpe_MRPKIT; rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
    //         list<ERP7__MRP__c> MRPS2Insert = new list<ERP7__MRP__c>();
    //         map<string,ERP7__MRP__c> MRPmap = new map<string,ERP7__MRP__c>();
    //         PreventRecursiveLedgerEntry.testCasesTransactions = true;
    //         for(OrderItem orditm:Orditem){
    //             if(orditm.Product2.ERP7__Is_Kit__c){
    //                 for(ERP7__BOM__c bom:bomitem){
    //                     ERP7__MRP__c MRP = new ERP7__MRP__c();
    //                     if(orditm.Product2Id == bom.ERP7__BOM_Product__c){
    //                         MRP.Name = bom.Name;
    //                         MRP.ERP7__Total_Amount_Required__c = bom.Quantity__c*orditm.Quantity;
    //                         MRP.ERP7__BOM__c = bom.Id;
    //                         MRP.Version__c = orditm.Version__c; 
    //                         MRP.ERP7__MRP_Product__c = bom.ERP7__BOM_Component__c; 
    //                         MRP.ERP7__Order_Product__c = orditm.Id; 
    //                         if(rTpe_MRPKIT != null){ MRP.RecordTypeId = rTpe_MRPKIT; }
    //                         if(orditm.ERP7__Insufficient_BOM__c != true){ MRP.Status__c = 'Reserved'; }
    //                         MRPS2Insert.add(MRP);      
    //                     }
    //                 }
    //             }
    //         }   
    //         system.debug('MRPS2Insert : '+MRPS2Insert.size());
    //         if(MRPS2Insert.size() > 0)upsert MRPS2Insert;  
    //         system.debug('inside MRP Creation1-->:');
            
    //         for(ERP7__MRP__c Mrp :MRPS2Insert){
    //             MRPmap.put(Mrp.ERP7__MRP_Product__c,Mrp);
    //         }
    //         system.debug('MRPmap:-->'+MRPmap);
            
    //         ERP7__Logistic__c Logistic = (ERP7__Logistic__c) JSON.deserialize(LogisticJSON, ERP7__Logistic__c .class);
    //         system.debug('Logistic : '+Logistic.ERP7__Shipping_Preferences__c);
    //         System.debug('Logistic Order : '+Logistic.ERP7__Order_S__c);
    //         System.debug('Logistic to address '+Logistic.ERP7__To_Address__c);
    //         Id orderId = Logistic.ERP7__Order_S__c;
    //         String SORecTypeId='';
    //         if(String.isNotEmpty(Logistic.ERP7__Sales_Order__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','SO');
    //         if(String.isNotEmpty(Logistic.ERP7__Order_S__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Order');
    //         if(String.isNotEmpty(Logistic.ERP7__Purchase_Order__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Purchase_Order');
    //         Logistic.RecordTypeId = SORecTypeId;
    //         system.debug('RecordTypeId : '+Logistic.RecordTypeId);
    //         list<ERP7__Logistic_Line_Item__c> LogisticLI = (list<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LLIListJSON, list<ERP7__Logistic_Line_Item__c> .class); 
            
    //         set<String> proList=new set<String>();
    //         set<Id> OrderProdIds=new set<Id>();
    //         Map<String,Decimal> prodRequestedQtyMap = new Map<String,Decimal>();
    //         Map<String,Decimal> OrderRequestedQtyMap = new Map<String,Decimal>();
    //         for(ERP7__Logistic_Line_Item__c log :LogisticLI){
    //             if(log.ERP7__Product__c != null && !proList.contains(log.ERP7__Product__c)){
    //                 proList.add(log.ERP7__Product__c);
    //                 prodRequestedQtyMap.put(log.ERP7__Product__c,log.ERP7__Quantity__c);
    //             }
    //             if(log.ERP7__Order_Product__c != null) {
    //                 OrderProdIds.add(log.ERP7__Order_Product__c);
    //                 OrderRequestedQtyMap.put(log.ERP7__Order_Product__c,log.ERP7__Quantity__c);
    //             }
    //         }
    //         //code to check whether the logistic is created or not
    //         if (OrderProdIds.size() > 0) {
    //             List<OrderItem> ordItemsList = [SELECT Id, OrderItemNumber, Quantity, ERP7__Is_Kit__c, ERP7__Logistic_Quantity__c FROM OrderItem WHERE Id IN :OrderProdIds];
                
    //             for (OrderItem ord : ordItemsList) {
    //                 if (!ord.ERP7__Is_Kit__c && OrderRequestedQtyMap.containsKey(ord.Id)) { // added ord.ERP7__Is_Kit__c on 22_07_24
    //                     Decimal logQty = OrderRequestedQtyMap.get(ord.Id);
    //                     system.debug('logQty : '+logQty);
    //                     if ((logQty + ord.ERP7__Logistic_Quantity__c) > ord.Quantity) {
    //                         return 'Logistic cannot be created for more than order quantity';
    //                     }
    //                 }
    //             }
    //         }
    //         //code to check whether the logistic is created or not ends
            
            
    //         List<Product2> proList1 = [Select Id,Name,ERP7__Serialise__c,ERP7__Lot_Tracked__c,ERP7__Track_Inventory__c from Product2 where Id In:proList];
    //         Map<String,String> proName=new Map<String,String>();
    //         Map<String,Boolean> proSerial=new Map<String,Boolean>();
            
    //         for(Product2 pr:proList1){
    //             proName.put(pr.Id,pr.Name);
    //             proSerial.put(pr.Id,pr.ERP7__Serialise__c);
    //         } 
            
    //         ERP7__Distribution_Channel__c dc = [Select Id,Name,ERP7__Site__c from ERP7__Distribution_Channel__c where Id=:Logistic.ERP7__Distribution_Channel__c Limit 1];
    //         List<ERP7__Manufacturing_Order__c> SOMOs = new List<ERP7__Manufacturing_Order__c>();
    //         List<ERP7__PO__c> SOPOs = new List<ERP7__PO__c>();
            
    //         List<ERP7__Inventory_Stock__c> invtoryList = new List<ERP7__Inventory_Stock__c>();
    //         List<ERP7__Inventory_Stock__c> MOPOinvtoryList = new List<ERP7__Inventory_Stock__c>();
            
    //         system.debug('orderId~>'+orderId);
    //         if(orderId != null && OrderProdIds.size() > 0 && proList.size() > 0){
    //             SOMOs = [Select Id,Name from ERP7__Manufacturing_Order__c where (ERP7__Order_Product__c IN:OrderProdIds and ERP7__Order__c =:orderId) and ERP7__Product__c IN:proList];
    //             System.debug('SOMOs : '+SOMOs.size());    
                
    //             SOPOs = [Select Id,Name from ERP7__PO__c where ERP7__Order__c =:orderId and ERP7__Ready_To_Receive__c =:true];
    //             System.debug('SOPOs : '+SOPOs.size()); 
    //         }
            
    //         Map<String,List<ERP7__Inventory_Stock__c>> proInvMap = new Map<String,List<ERP7__Inventory_Stock__c>>();
    //         Map<String,Decimal> prodStockQtyMap = new Map<String,Decimal>();
            
    //         if(SOMOs.size() > 0 || SOPOs.size() > 0){ 
    //             set<Id> MoIds = new set<Id>();
    //             set<Id> PoIds = new set<Id>();
    //             set<Id> InvIds = new set<Id>();
                
    //             for(ERP7__Manufacturing_Order__c MO : SOMOs) MoIds.add(MO.Id);
    //             for(ERP7__PO__c PO : SOPOs) PoIds.add(PO.Id);
    //             system.debug('MoIds ~>'+MoIds);
                
    //             List<ERP7__Stock_Inward_Line_Item__c> stinlist = [Select Id,Name,Product__c,ERP7__Site_ProductService_InventoryStock__c from ERP7__Stock_Inward_Line_Item__c 
    //                                                               where ERP7__Active__c = true and Product__c IN :proList and ERP7__Scrap__c = false AND (ERP7__Purchase_Orders__c IN:PoIds or ERP7__Manufacturing_Order__c IN: MoIds) 
    //                                                               AND ERP7__Quantity__c > 0 AND ERP7__Status__c != 'Awaiting Stock'];
                
    //             for(ERP7__Stock_Inward_Line_Item__c sin : stinlist) InvIds.add(sin.ERP7__Site_ProductService_InventoryStock__c);
    //             system.debug('MoIds InvIds ~>'+InvIds);
                
    //             MOPOinvtoryList = [Select Id, Name, Active__c, Organisation__c,  Warehouse__c, Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,Product__c,  Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, 
    //                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c, Checked_In_Date__c From Inventory_Stock__c
    //                                Where ERP7__product__c != null and Product__c In:proList And Active__c = true And Warehouse__c =:dc.ERP7__Site__c
    //                                AND Id IN:InvIds AND Name != 'Awaiting Stock' And Number_of_Item_In_Stock__c > 0 Order By Checked_In_Date__c ASC]; 
                
    //             system.debug('MOPOinvtoryList~>'+MOPOinvtoryList.size());
                
    //             //below code added by Arshad 09 Aug 23
    //             for(ERP7__Inventory_Stock__c invt:MOPOinvtoryList){
    //                 List<ERP7__Inventory_Stock__c> invlistformap = new List<ERP7__Inventory_Stock__c>();
    //                 if(proInvMap.containsKey(invt.ERP7__Product__c)) invlistformap = proInvMap.get(invt.ERP7__Product__c);
    //                 invlistformap.add(invt);
    //                 proInvMap.put(invt.ERP7__Product__c,invlistformap);
    //             }
                
    //             for(String key: proInvMap.keyset()){
    //                 //system.debug('product key 1~>'+key);
    //                 Decimal Qty = 0; 
    //                 for(ERP7__Inventory_Stock__c inv : proInvMap.get(key)){
    //                     //system.debug('inv map 1~>'+inv.Id);
    //                     Qty = Qty + inv.Number_of_Item_In_Stock__c;
    //                 }
    //                 prodStockQtyMap.put(key,Qty);
    //             }
    //             //
    //         }
            
    //         //below code added by Arshad 09 Aug 23
    //         Boolean checkInventoryList = false;
            
    //         //First check after MOs/POs
    //         for(String key : prodRequestedQtyMap.keyset()){
    //             if(prodStockQtyMap.containsKey(key)){
    //                 system.debug('prodStockQtyMap.get(key) first check~>'+prodStockQtyMap.get(key));
    //                 if(prodStockQtyMap.get(key) < prodRequestedQtyMap.get(key)){
    //                     checkInventoryList = true;
    //                     break;
    //                 }
    //             }else{
    //                 checkInventoryList = true;
    //                 break;
    //             }
    //         }
            
    //         system.debug('checkInventoryList~>'+checkInventoryList);
            
    //         if(checkInventoryList){ 
    //             system.debug('MOPOinvtoryList size~>'+MOPOinvtoryList.size());
                
    //             if(MOPOinvtoryList.size() > 0){
    //                 invtoryList = [Select Id,Name,ERP7__Product__c,ERP7__Warehouse__c, ERP7__Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,ERP7__Number_of_Item_In_Stock__c, 
    //                                ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c, ERP7__Checked_In_Date__c  from ERP7__Inventory_Stock__c
    //                                where ERP7__product__c != null AND ERP7__product__c In:proList And ERP7__Active__c = true AND ERP7__Warehouse__c =:dc.ERP7__Site__c 
    //                                AND Name != 'Awaiting Stock' And ERP7__Number_of_Item_In_Stock__c > 0 AND Id NOT IN:MOPOinvtoryList ORDER BY Checked_In_Date__c ASC];
    //             }else{
    //                 invtoryList = [Select Id,Name,ERP7__Product__c,ERP7__Warehouse__c, ERP7__Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,ERP7__Number_of_Item_In_Stock__c, 
    //                                ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c, ERP7__Checked_In_Date__c  from ERP7__Inventory_Stock__c
    //                                where ERP7__product__c != null AND ERP7__product__c In:proList And ERP7__Active__c = true AND ERP7__Warehouse__c =:dc.ERP7__Site__c 
    //                                AND Name != 'Awaiting Stock' And ERP7__Number_of_Item_In_Stock__c > 0 ORDER BY Checked_In_Date__c ASC]; //CreatedDate DESC  //Checked_In_Date__c ASC
    //             }
                
    //             for(ERP7__Inventory_Stock__c invt:invtoryList){
    //                 List<ERP7__Inventory_Stock__c> invlistformap = new List<ERP7__Inventory_Stock__c>();
    //                 if(proInvMap.containsKey(invt.ERP7__Product__c)) invlistformap = proInvMap.get(invt.ERP7__Product__c);
    //                 invlistformap.add(invt);
    //                 proInvMap.put(invt.ERP7__Product__c,invlistformap);
    //             }
                
    //             for(String key: proInvMap.keyset()){
    //                 //system.debug('product key 2~>'+key);
    //                 Decimal Qty = 0; 
    //                 for(ERP7__Inventory_Stock__c inv : proInvMap.get(key)){
    //                     //system.debug('inv map 2~>'+inv.Id);
    //                     Qty = Qty + inv.Number_of_Item_In_Stock__c;
    //                 }
    //                 Decimal totalQty = 0;
    //                 if(prodStockQtyMap.containsKey(key)) totalQty = prodStockQtyMap.get(key);
    //                 totalQty = totalQty + Qty;
    //                 prodStockQtyMap.put(key,totalQty);
    //             }
    //         }
            
    //         //Second check after MOs/POs inventory & after normal inventorylist
    //         if(!String.isNotEmpty(Logistic.ERP7__Purchase_Order__c)){
    //             for(String key : prodRequestedQtyMap.keyset()){
    //                 if(prodStockQtyMap.containsKey(key)){
    //                     if(prodStockQtyMap.get(key) < prodRequestedQtyMap.get(key)){
    //                         return 'Does not have inventory for product :'+proName.get(key)+' on selected distribution Centers site';
    //                     }
    //                 }else{
    //                     return 'Does not have inventory for product :'+proName.get(key)+' on selected distribution Centers site';
    //                 }
    //             }
    //         }
    //         //above code added by Arshad 09 Aug 23
            
    //         if(String.isNotEmpty(Logistic.ERP7__Sales_Order__c)){
    //             ERP7__Sales_Order__c SalOrder=new ERP7__Sales_Order__c();      
    //             SalOrder=[SELECT Id, Name, Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__c FROM ERP7__Sales_Order__c WHERE Id=:Logistic.ERP7__Sales_Order__c]; 
    //             if(SalOrder.ERP7__Channel__c != null){
    //                 if(Logistic.ERP7__From_Address__c == null && SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c != null){
    //                     Logistic.ERP7__From_Address__c = SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c; 
    //                 }
    //             }
    //         }  
    //         else if(String.isNotEmpty(Logistic.ERP7__Order_S__c)){
    //             Order SalOrder=new Order();  
    //             SalOrder=[SELECT Id, Name, Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__c,ERP7__Shipment_Type__c, ERP7__Shipment_Preference_Speed__c, BillToContactId, ERP7__Bill_To_Address__c, ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c  
    //                         FROM Order WHERE Id=:Logistic.ERP7__Order_S__c]; 
                
    //             if(SalOrder.ERP7__Channel__c != null){
    //                 if(Logistic.ERP7__From_Address__c == null && SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c != null){
    //                     Logistic.ERP7__From_Address__c = SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c;  
    //                 }
    //             } 
    //             if(Logistic.ERP7__Shipment_Type__c == null || Logistic.ERP7__Shipment_Type__c == '') Logistic.ERP7__Shipment_Type__c = SalOrder.ERP7__Shipment_Type__c;
    //             system.debug('Logistic.ERP7__Shipment_Type__c : '+Logistic.ERP7__Shipment_Type__c);
    //         }
    //         else if(String.isNotEmpty(Logistic.ERP7__Purchase_Order__c)){
    //             String PORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Purchase_Order'); 
    //             Logistic.RecordTypeId = PORecTypeId;
    //         }
            
    //         if(Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isUpdateable()){ upsert Logistic; } 
    //         else{ return 'Don\'t have access to upsert logistic'; }
            
    //         list<String> SOLIIds=new list<String>();
    //         list<String> ordItemIds=new list<String>();
    //         list<String> POItemIds=new list<String>();
            
    //         for(ERP7__Logistic_Line_Item__c log:LogisticLI){
    //             String Name = log.Name;
    //             if(Name.length() > 80) log.Name = Name.subString(0,79);
    //             log.ERP7__Status__c = 'Reserved';
    //             log.ERP7__Logistic__c = Logistic.Id;
    //             if(log.ERP7__Sales_Order_Line_Item__c !=null) SOLIIds.add(log.ERP7__Sales_Order_Line_Item__c);
    //             if(log.ERP7__Order_Product__c !=null) ordItemIds.add(log.ERP7__Order_Product__c);
    //             if(log.ERP7__Purchase_Line_Items__c !=null) POItemIds.add(log.ERP7__Purchase_Line_Items__c);                
    //         }
            
    //         if(LogisticLI.size() > 0){
    //             if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable()){ 
    //                 upsert LogisticLI; 
    //             } else{ return 'Does not have access to upsert logistic line items'; } 
    //         }
            
    //         List<ERP7__Stock_Outward_Line_Item__c> SWLIToUpsert = new List<ERP7__Stock_Outward_Line_Item__c>();
    //         Map<Id, ERP7__Inventory_Stock__c> pliStock = new Map<Id, ERP7__Inventory_Stock__c>();
    //         Map<Id, Stock_Outward_Line_Item__c> pliStockInward = new Map<Id, Stock_Outward_Line_Item__c>();
    //         List<Inventory_Stock__c> Inventory2Upsert = new List<Inventory_Stock__c>();
    //         //changed below code Arshad 09 Aug 23
    //         for(ERP7__Logistic_Line_Item__c log:LogisticLI){
    //             system.debug('log line item inhere');
    //             if(log.ERP7__Product__c != null && log.ERP7__Quantity__c > 0 && ((Logistic.ERP7__Sales_Order__c != null && log.ERP7__Sales_Order_Line_Item__c != null) || (Logistic.ERP7__Order_S__c != null && log.ERP7__Order_Product__c != null))){
    //                 if(Logistic.ERP7__Purchase_Order__c == null && proInvMap.containsKey(log.ERP7__Product__c) && proSerial.containsKey(log.ERP7__Product__c)){
    //                     system.debug('log line item inhere2 log.ERP7__Quantity__c~>'+log.ERP7__Quantity__c);
    //                     Decimal remainintQty = log.ERP7__Quantity__c;
                        
    //                     for(ERP7__Inventory_Stock__c inv : proInvMap.get(log.ERP7__Product__c)){
    //                         if(remainintQty > 0){
    //                             Decimal qtytoprocess = 0;
    //                             if(proSerial.get(log.ERP7__Product__c)){
    //                                 Inventory_Stock__c inv2Create = new Inventory_Stock__c(Active__c = true, Product__c = log.ERP7__Product__c, Name = 'Serial Stock Holder', Warehouse__c = dc.ERP7__Site__c);
    //                                 Inventory2Upsert.add(inv2Create);
    //                                 system.debug('inhere serial');
    //                                 qtytoprocess = 0;
    //                                 ERP7__Stock_Outward_Line_Item__c sto = new ERP7__Stock_Outward_Line_Item__c();
    //                                 sto.Name = 'Serial Stock Holder'; 
    //                                 sto.ERP7__Product__c = log.ERP7__Product__c; 
    //                                 sto.ERP7__Active__c = true; 
    //                                 sto.ERP7__Status__c = 'Reserved'; 
    //                                  if(log.ERP7__Sales_Order_Line_Item__c != null) sto.ERP7__Sales_Order_Line_Item__c = log.ERP7__Sales_Order_Line_Item__c; 
    //                                 if(Logistic.ERP7__Sales_Order__c != null) sto.ERP7__Sales_Order__c = Logistic.ERP7__Sales_Order__c;
                                    
    //                                 if(log.ERP7__Order_Product__c != null) sto.ERP7__Order_Product__c = log.ERP7__Order_Product__c;
    //                                 if(Logistic.ERP7__Order_S__c != null) sto.ERP7__Order__c = Logistic.ERP7__Order_S__c; 
    //                                 sto.ERP7__Logistic_Line_Item__c = log.Id;
    //                                 sto.ERP7__Quantity__c = remainintQty;
    //                                 SWLIToUpsert.add(sto);
    //                                 pliStock.put(log.Id,inv2Create);
    //                                 pliStockInward.put(log.Id,sto);
    //                                 remainintQty = 0;
    //                                 system.debug('qtytoprocess~>'+qtytoprocess);
    //                                 system.debug('remainintQty~>'+remainintQty);
    //                             }
    //                             else{
    //                                 system.debug('inhere non serial inv.Number_of_Item_In_Stock__c~>'+inv.Number_of_Item_In_Stock__c);
    //                                 if(inv.Number_of_Item_In_Stock__c < remainintQty){
    //                                     system.debug('inhere inv.Number_of_Item_In_Stock__c < remainintQty');
    //                                     qtytoprocess = inv.Number_of_Item_In_Stock__c;
    //                                     remainintQty = remainintQty - inv.Number_of_Item_In_Stock__c;
    //                                 }else{
    //                                     system.debug('inhere else inv.Number_of_Item_In_Stock__c >= remainintQty');
    //                                     qtytoprocess = remainintQty;
    //                                     remainintQty = remainintQty - qtytoprocess;
    //                                 }
    //                                 system.debug('qtytoprocess~>'+qtytoprocess);
    //                                 system.debug('remainintQty~>'+remainintQty);
    //                             }
                                
    //                             if(qtytoprocess > 0){
    //                                 ERP7__Stock_Outward_Line_Item__c sto = new ERP7__Stock_Outward_Line_Item__c();
    //                                 sto.Name = log.Name; 
                                    
    //                                 if(log.ERP7__Sales_Order_Line_Item__c != null) sto.ERP7__Sales_Order_Line_Item__c = log.ERP7__Sales_Order_Line_Item__c; 
    //                                 if(Logistic.ERP7__Sales_Order__c != null) sto.ERP7__Sales_Order__c = Logistic.ERP7__Sales_Order__c;
                                    
    //                                 if(log.ERP7__Order_Product__c != null) sto.ERP7__Order_Product__c = log.ERP7__Order_Product__c;
    //                                 if(Logistic.ERP7__Order_S__c != null) sto.ERP7__Order__c = Logistic.ERP7__Order_S__c; 
                                    
    //                                 sto.ERP7__Product__c = log.ERP7__Product__c; 
    //                                 sto.ERP7__Active__c = true; 
    //                                 sto.ERP7__Status__c = 'Reserved'; 
                                    
    //                                 if(proSerial.get(log.ERP7__Product__c)) sto.ERP7__Quantity__c = 1;
    //                                 else sto.ERP7__Quantity__c = qtytoprocess; 
                                    
    //                                 system.debug('inv.Id for stock outward~>'+inv.Id);
    //                                 sto.ERP7__Site_Product_Service_Inventory_Stock__c = inv.Id; 
    //                                 sto.ERP7__Logistic_Line_Item__c = log.Id;
                                    
    //                                 if(MRPmap.containsKey(log.ERP7__Product__c)) sto.ERP7__MRP_Material_Requirements_Planning__c = MRPmap.get(log.ERP7__Product__c).Id;
                                    
    //                                 system.debug('inv.ERP7__Serial__c~>'+inv.ERP7__Serial__c);
                                    
    //                                 if(inv.ERP7__Serial__c != null) sto.ERP7__Serial__c = inv.ERP7__Serial__c;
    //                                 if(inv.ERP7__Batch_Lot__c != null) sto.ERP7__Material_Batch_Lot__c = inv.ERP7__Batch_Lot__c;
    //                                 if(inv.ERP7__Version__c != null) sto.ERP7__Version__c = inv.ERP7__Version__c;
                                    
    //                                 SWLIToUpsert.add(sto);
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //         //
            
    //         system.debug('SWLIToUpsert size~>'+SWLIToUpsert.size());
            
    //         //There was a block of code here in previous method, commented that as not needed - Arshad 10 Aug 23
    //         if(Inventory2Upsert.size() > 0) insert Inventory2Upsert;
    //         for(Id pliId : pliStockInward.KeySet()){
    //             pliStockInward.get(pliId).Site_Product_Service_Inventory_Stock__c= pliStock.get(pliId).Id;
    //         }
            
    //         if(SWLIToUpsert.size() > 0){
    //             if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()) {
    //                 system.debug('SWLIToUpsert size~>'+SWLIToUpsert.size());
    //                 upsert SWLIToUpsert; 
    //             }  else{ return 'Don\'t have access to upsert Stock Outward'; }
    //         } 
             
    //         if(SOLIIds.size()>0){
    //             list<ERP7__Logistic_Line_Item__c> LogLIList=new list<ERP7__Logistic_Line_Item__c>();
    //             LogLIList=[SELECT Id, Name, ERP7__Quantity__c, ERP7__Sales_Order_Line_Item__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Sales_Order_Line_Item__c IN:SOLIIds];
                
    //             for(ERP7__Sales_Order_Line_Item__c soli:[SELECT Id, ERP7__Logistic_Quantity__c FROM ERP7__Sales_Order_Line_Item__c WHERE Id IN:SOLIIds]){ 
    //                 Decimal LogQuantity=0; 
    //                 for(ERP7__Logistic_Line_Item__c logLi:LogLIList){ 
    //                     if(logLi.ERP7__Sales_Order_Line_Item__c==soli.Id) LogQuantity+=logLi.ERP7__Quantity__c;                                           
    //                 }
    //                 soli.ERP7__Logistic_Quantity__c=LogQuantity;
    //                 try{ if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Logistic_Quantity__c.isUpdateable()){  update soli; } else { return 'User is not allowed to update SalesOrder Line Item';} }catch(DMLException e){ return e.getMessage() +','+e.getStackTraceString();}     
    //             } 
    //         } 
    //         else if(POItemIds.size() > 0){
    //             list<ERP7__Logistic_Line_Item__c> LogLIList=new list<ERP7__Logistic_Line_Item__c>();
    //             LogLIList=[SELECT Id, Name, ERP7__Quantity__c, ERP7__Purchase_Line_Items__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Purchase_Line_Items__c IN:POItemIds];
                
    //             for(ERP7__Purchase_Line_Items__c poli:[SELECT Id, ERP7__Logistic_Quantity__c FROM ERP7__Purchase_Line_Items__c WHERE Id IN:POItemIds]){ 
    //                 Decimal LogQuantity=0; 
    //                 for(ERP7__Logistic_Line_Item__c logLi:LogLIList){
    //                     if(logLi.ERP7__Purchase_Line_Items__c==poli.Id) LogQuantity+=logLi.ERP7__Quantity__c;                                           
    //                 }
    //                 poli.ERP7__Logistic_Quantity__c=LogQuantity;
    //                 try{  if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Logistic_Quantity__c.isUpdateable())  { update poli; } else{ return 'User is not allowed to update POLI'; } }catch(DMLException e){return e.getMessage() +','+e.getStackTraceString();}     
    //             } 
    //         }
            
    //         return null;   
    //     }catch(Exception e){
    //         System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
    //         throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
    //     }    
    // }
 @AuraEnabled
    public static String getCreateLogistic(String LogisticJSON, String LLIListJSON,String OrderLIneItems,String BomItems, String SoliListItems){ 
        try{
            system.debug('getCreateLogistic called');
            System.debug('LogisticJson ->'+LogisticJSON);
            System.debug('LLIListJSON '+LLIListJSON);
            System.debug('OrderLIneItems '+OrderLIneItems);
            System.debug('BomItems '+BomItems);
            
            list<OrderItem> Orditem = (OrderLIneItems != '') ? (list<OrderItem>) JSON.deserialize(OrderLIneItems, list<OrderItem> .class) : new list<OrderItem>();
            System.debug('ordtem sizeeeee'+Orditem.size());
            list<ERP7__BOM__c> bomitem = (BomItems != '') ? (list<ERP7__BOM__c>) JSON.deserialize(BomItems, list<ERP7__BOM__c> .class) : new list<ERP7__BOM__c>();
            system.debug('bomitem records received: ' + bomitem.size());

            // --- NEW: Deserialize SOLI List ---
            List<ERP7__Sales_Order_Line_Item__c> SoliList = (String.isNotEmpty(SoliListItems)) ? (List<ERP7__Sales_Order_Line_Item__c>) JSON.deserialize(SoliListItems, List<ERP7__Sales_Order_Line_Item__c>.class) : new List<ERP7__Sales_Order_Line_Item__c>();

            Id rTpe_MRPKIT; rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
            list<ERP7__MRP__c> MRPS2Insert = new list<ERP7__MRP__c>();
            map<string,ERP7__MRP__c> MRPmap = new map<string,ERP7__MRP__c>();
            PreventRecursiveLedgerEntry.testCasesTransactions = true;

            if(SoliList.size() > 0){
                // --- NEW: SOLI MRP Logic (Mirroring Order Item) ---
                for(ERP7__Sales_Order_Line_Item__c soli : SoliList){
                    if(soli.ERP7__Is_Kit__c){ // Ensure this field is queried in your getSoliList method
                        for(ERP7__BOM__c bom : bomitem){
                            ERP7__MRP__c MRP = new ERP7__MRP__c();
                            // Match SOLI Product to BOM Product
                            if(soli.ERP7__Product__c == bom.ERP7__BOM_Product__c){
                                MRP.Name = bom.Name;
                                // Calculate Required Qty: BOM Qty * SOLI Qty
                                MRP.ERP7__Total_Amount_Required__c = bom.ERP7__Quantity__c; // Note: In helper, we typically multiply by Parent Qty if needed, or pass the calculated qty.
                                MRP.ERP7__BOM__c = bom.Id;
                                MRP.Version__c = soli.ERP7__Version__c; 
                                MRP.ERP7__MRP_Product__c = bom.ERP7__BOM_Component__c; 
                                
                                // Link to SOLI instead of Order Item
                                MRP.ERP7__Sales_Order_Line_Item__c = soli.Id; 
                                
                                if(rTpe_MRPKIT != null){ MRP.RecordTypeId = rTpe_MRPKIT; }
                                if(soli.ERP7__Insufficient_BOM__c != true){ MRP.Status__c = 'Reserved'; }
                                
                                MRPS2Insert.add(MRP);      
                            }
                        }
                    }
                } 
            }

            else if(Orditem.size() > 0){
                for(OrderItem orditm:Orditem){
                    if(orditm.Product2.ERP7__Is_Kit__c){
                        for(ERP7__BOM__c bom:bomitem){
                            ERP7__MRP__c MRP = new ERP7__MRP__c();
                            if(orditm.Product2Id == bom.ERP7__BOM_Product__c){
                                MRP.Name = bom.Name;
                                MRP.ERP7__Total_Amount_Required__c = bom.Quantity__c;//*orditm.Quantity
                                MRP.ERP7__BOM__c = bom.Id;
                                MRP.Version__c = orditm.Version__c; 
                                MRP.ERP7__MRP_Product__c = bom.ERP7__BOM_Component__c; 
                                MRP.ERP7__Order_Product__c = orditm.Id; 
                                if(rTpe_MRPKIT != null){ MRP.RecordTypeId = rTpe_MRPKIT; }
                                if(orditm.ERP7__Insufficient_BOM__c != true){ MRP.Status__c = 'Reserved'; }
                                MRPS2Insert.add(MRP);      
                            }
                        }
                    }
                }
            }
            
            system.debug('MRPS2Insert : '+MRPS2Insert.size());
            if(MRPS2Insert.size() > 0)upsert MRPS2Insert;  
            system.debug('inside MRP Creation1-->:');
            
            for(ERP7__MRP__c Mrp :MRPS2Insert){
                MRPmap.put(Mrp.ERP7__MRP_Product__c,Mrp);
            }
            system.debug('MRPmap:-->'+MRPmap);
            
            ERP7__Logistic__c Logistic = (ERP7__Logistic__c) JSON.deserialize(LogisticJSON, ERP7__Logistic__c .class);
            system.debug('Logistic : '+Logistic.ERP7__Shipping_Preferences__c);
            System.debug('Logistic Order : '+Logistic.ERP7__Order_S__c);
            System.debug('Logistic to address '+Logistic.ERP7__To_Address__c);
            Id orderId = Logistic.ERP7__Order_S__c;
            String SORecTypeId='';
            if(String.isNotEmpty(Logistic.ERP7__Sales_Order__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','SO');
            if(String.isNotEmpty(Logistic.ERP7__Order_S__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Order');
            if(String.isNotEmpty(Logistic.ERP7__Purchase_Order__c)) SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Purchase_Order');
            Logistic.RecordTypeId = SORecTypeId;
            system.debug('RecordTypeId : '+Logistic.RecordTypeId);
            list<ERP7__Logistic_Line_Item__c> LogisticLI = (list<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LLIListJSON, list<ERP7__Logistic_Line_Item__c> .class); 
            
            set<String> proList=new set<String>();
            set<Id> OrderProdIds=new set<Id>();
            Map<String,Decimal> prodRequestedQtyMap = new Map<String,Decimal>();
            Map<String,Decimal> OrderRequestedQtyMap = new Map<String,Decimal>();
            for(ERP7__Logistic_Line_Item__c log :LogisticLI){
                if(log.ERP7__Product__c != null && !proList.contains(log.ERP7__Product__c)){
                    proList.add(log.ERP7__Product__c);
                    prodRequestedQtyMap.put(log.ERP7__Product__c,log.ERP7__Quantity__c);
                }
                if(log.ERP7__Order_Product__c != null) {
                    OrderProdIds.add(log.ERP7__Order_Product__c);
                    OrderRequestedQtyMap.put(log.ERP7__Order_Product__c,log.ERP7__Quantity__c);
                }
            }
            //code to check whether the logistic is created or not
            if (OrderProdIds.size() > 0) {
                List<OrderItem> ordItemsList = [SELECT Id, OrderItemNumber, Quantity, ERP7__Is_Kit__c, ERP7__Logistic_Quantity__c FROM OrderItem WHERE Id IN :OrderProdIds];
                
                for (OrderItem ord : ordItemsList) {
                    if (!ord.ERP7__Is_Kit__c && OrderRequestedQtyMap.containsKey(ord.Id)) { // added ord.ERP7__Is_Kit__c on 22_07_24
                        Decimal logQty = OrderRequestedQtyMap.get(ord.Id);
                        system.debug('logQty : '+logQty);
                        if ((logQty + ord.ERP7__Logistic_Quantity__c) > ord.Quantity) {
                            return 'Logistic cannot be created for more than order quantity';
                        }
                    }
                }
            }
            //code to check whether the logistic is created or not ends
            
            
            List<Product2> proList1 = [Select Id,Name,ERP7__Serialise__c,ERP7__Lot_Tracked__c,ERP7__Track_Inventory__c from Product2 where Id In:proList];
            Map<String,String> proName=new Map<String,String>();
            Map<String,Boolean> proSerial=new Map<String,Boolean>();
            
            for(Product2 pr:proList1){
                proName.put(pr.Id,pr.Name);
                proSerial.put(pr.Id,pr.ERP7__Serialise__c);
            } 
            
            ERP7__Distribution_Channel__c dc = [Select Id,Name,ERP7__Site__c from ERP7__Distribution_Channel__c where Id=:Logistic.ERP7__Distribution_Channel__c Limit 1];
            List<ERP7__Manufacturing_Order__c> SOMOs = new List<ERP7__Manufacturing_Order__c>();
            List<ERP7__PO__c> SOPOs = new List<ERP7__PO__c>();
            
            List<ERP7__Inventory_Stock__c> invtoryList = new List<ERP7__Inventory_Stock__c>();
            List<ERP7__Inventory_Stock__c> MOPOinvtoryList = new List<ERP7__Inventory_Stock__c>();
            
            system.debug('orderId~>'+orderId);
            if(orderId != null && OrderProdIds.size() > 0 && proList.size() > 0){
                SOMOs = [Select Id,Name from ERP7__Manufacturing_Order__c where (ERP7__Order_Product__c IN:OrderProdIds and ERP7__Order__c =:orderId) and ERP7__Product__c IN:proList];
                System.debug('SOMOs : '+SOMOs.size());    
                
                SOPOs = [Select Id,Name from ERP7__PO__c where ERP7__Order__c =:orderId and ERP7__Ready_To_Receive__c =:true];
                System.debug('SOPOs : '+SOPOs.size()); 
            }
            
            Map<String,List<ERP7__Inventory_Stock__c>> proInvMap = new Map<String,List<ERP7__Inventory_Stock__c>>();
            Map<String,Decimal> prodStockQtyMap = new Map<String,Decimal>();
            
            if(SOMOs.size() > 0 || SOPOs.size() > 0){ 
                set<Id> MoIds = new set<Id>();
                set<Id> PoIds = new set<Id>();
                set<Id> InvIds = new set<Id>();
                
                for(ERP7__Manufacturing_Order__c MO : SOMOs) MoIds.add(MO.Id);
                for(ERP7__PO__c PO : SOPOs) PoIds.add(PO.Id);
                system.debug('MoIds ~>'+MoIds);
                
                List<ERP7__Stock_Inward_Line_Item__c> stinlist = [Select Id,Name,Product__c,ERP7__Site_ProductService_InventoryStock__c from ERP7__Stock_Inward_Line_Item__c 
                                                                  where ERP7__Active__c = true and Product__c IN :proList and ERP7__Scrap__c = false AND (ERP7__Purchase_Orders__c IN:PoIds or ERP7__Manufacturing_Order__c IN: MoIds) 
                                                                  AND ERP7__Quantity__c > 0 AND ERP7__Status__c != 'Awaiting Stock'];
                
                for(ERP7__Stock_Inward_Line_Item__c sin : stinlist) InvIds.add(sin.ERP7__Site_ProductService_InventoryStock__c);
                system.debug('MoIds InvIds ~>'+InvIds);
                
                MOPOinvtoryList = [Select Id, Name, Active__c, Organisation__c,  Warehouse__c, Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,Product__c,  Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, 
                                   Number_of_Items_Dispatched__c, No_of_Items_Sold__c, Checked_In_Date__c From Inventory_Stock__c
                                   Where ERP7__product__c != null and Product__c In:proList And Active__c = true And Warehouse__c =:dc.ERP7__Site__c
                                   AND Id IN:InvIds AND Name != 'Awaiting Stock' And Number_of_Item_In_Stock__c > 0 Order By Checked_In_Date__c ASC]; 
                
                system.debug('MOPOinvtoryList~>'+MOPOinvtoryList.size());
                
                //below code added by Arshad 09 Aug 23
                for(ERP7__Inventory_Stock__c invt:MOPOinvtoryList){
                    List<ERP7__Inventory_Stock__c> invlistformap = new List<ERP7__Inventory_Stock__c>();
                    if(proInvMap.containsKey(invt.ERP7__Product__c)) invlistformap = proInvMap.get(invt.ERP7__Product__c);
                    invlistformap.add(invt);
                    proInvMap.put(invt.ERP7__Product__c,invlistformap);
                }
                
                for(String key: proInvMap.keyset()){
                    //system.debug('product key 1~>'+key);
                    Decimal Qty = 0; 
                    for(ERP7__Inventory_Stock__c inv : proInvMap.get(key)){
                        //system.debug('inv map 1~>'+inv.Id);
                        Qty = Qty + inv.Number_of_Item_In_Stock__c;
                    }
                    prodStockQtyMap.put(key,Qty);
                }
                //
            }
            
            //below code added by Arshad 09 Aug 23
            Boolean checkInventoryList = false;
            
            //First check after MOs/POs
            for(String key : prodRequestedQtyMap.keyset()){
                if(prodStockQtyMap.containsKey(key)){
                    system.debug('prodStockQtyMap.get(key) first check~>'+prodStockQtyMap.get(key));
                    if(prodStockQtyMap.get(key) < prodRequestedQtyMap.get(key)){
                        checkInventoryList = true;
                        break;
                    }
                }else{
                    checkInventoryList = true;
                    break;
                }
            }
            
            system.debug('checkInventoryList~>'+checkInventoryList);
            
            if(checkInventoryList){ 
                system.debug('MOPOinvtoryList size~>'+MOPOinvtoryList.size());
                
                if(MOPOinvtoryList.size() > 0){
                    invtoryList = [Select Id,Name,ERP7__Product__c,ERP7__Warehouse__c, ERP7__Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,ERP7__Number_of_Item_In_Stock__c, 
                                   ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c, ERP7__Checked_In_Date__c  from ERP7__Inventory_Stock__c
                                   where ERP7__product__c != null AND ERP7__product__c In:proList And ERP7__Active__c = true AND ERP7__Warehouse__c =:dc.ERP7__Site__c 
                                   AND Name != 'Awaiting Stock' And ERP7__Number_of_Item_In_Stock__c > 0 AND Id NOT IN:MOPOinvtoryList ORDER BY Checked_In_Date__c ASC];
                }else{
                    invtoryList = [Select Id,Name,ERP7__Product__c,ERP7__Warehouse__c, ERP7__Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,ERP7__Number_of_Item_In_Stock__c, 
                                   ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c, ERP7__Checked_In_Date__c  from ERP7__Inventory_Stock__c
                                   where ERP7__product__c != null AND ERP7__product__c In:proList And ERP7__Active__c = true AND ERP7__Warehouse__c =:dc.ERP7__Site__c 
                                   AND Name != 'Awaiting Stock' And ERP7__Number_of_Item_In_Stock__c > 0 ORDER BY Checked_In_Date__c ASC]; //CreatedDate DESC  //Checked_In_Date__c ASC
                }
                
                for(ERP7__Inventory_Stock__c invt:invtoryList){
                    List<ERP7__Inventory_Stock__c> invlistformap = new List<ERP7__Inventory_Stock__c>();
                    if(proInvMap.containsKey(invt.ERP7__Product__c)) invlistformap = proInvMap.get(invt.ERP7__Product__c);
                    invlistformap.add(invt);
                    proInvMap.put(invt.ERP7__Product__c,invlistformap);
                }
                
                for(String key: proInvMap.keyset()){
                    //system.debug('product key 2~>'+key);
                    Decimal Qty = 0; 
                    for(ERP7__Inventory_Stock__c inv : proInvMap.get(key)){
                        //system.debug('inv map 2~>'+inv.Id);
                        Qty = Qty + inv.Number_of_Item_In_Stock__c;
                    }
                    Decimal totalQty = 0;
                    if(prodStockQtyMap.containsKey(key)) totalQty = prodStockQtyMap.get(key);
                    totalQty = totalQty + Qty;
                    prodStockQtyMap.put(key,totalQty);
                }
            }
            
            //Second check after MOs/POs inventory & after normal inventorylist
            if(!String.isNotEmpty(Logistic.ERP7__Purchase_Order__c)){
                for(String key : prodRequestedQtyMap.keyset()){
                    if(prodStockQtyMap.containsKey(key)){
                        if(prodStockQtyMap.get(key) < prodRequestedQtyMap.get(key)){
                            return 'Does not have inventory for product :'+proName.get(key)+' on selected distribution Centers site';
                        }
                    }else{
                        return 'Does not have inventory for product :'+proName.get(key)+' on selected distribution Centers site';
                    }
                }
            }
            //above code added by Arshad 09 Aug 23
            
            if(String.isNotEmpty(Logistic.ERP7__Sales_Order__c)){
                ERP7__Sales_Order__c SalOrder=new ERP7__Sales_Order__c();      
                SalOrder=[SELECT Id, Name, Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__c FROM ERP7__Sales_Order__c WHERE Id=:Logistic.ERP7__Sales_Order__c]; 
                if(SalOrder.ERP7__Channel__c != null){
                    if(Logistic.ERP7__From_Address__c == null && SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c != null){
                        Logistic.ERP7__From_Address__c = SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c; 
                    }
                }
            }  
            else if(String.isNotEmpty(Logistic.ERP7__Order_S__c)){
                Order SalOrder=new Order();  
                SalOrder=[SELECT Id, Name, Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__c,ERP7__Shipment_Type__c, ERP7__Shipment_Preference_Speed__c, BillToContactId, ERP7__Bill_To_Address__c, ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c  
                            FROM Order WHERE Id=:Logistic.ERP7__Order_S__c]; 
                
                if(SalOrder.ERP7__Channel__c != null){
                    if(Logistic.ERP7__From_Address__c == null && SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c != null){
                        Logistic.ERP7__From_Address__c = SalOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c;  
                    }
                } 
                if(Logistic.ERP7__Shipment_Type__c == null || Logistic.ERP7__Shipment_Type__c == '') Logistic.ERP7__Shipment_Type__c = SalOrder.ERP7__Shipment_Type__c;
                system.debug('Logistic.ERP7__Shipment_Type__c : '+Logistic.ERP7__Shipment_Type__c);
            }
            else if(String.isNotEmpty(Logistic.ERP7__Purchase_Order__c)){
                String PORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Logistic__c','Purchase_Order'); 
                Logistic.RecordTypeId = PORecTypeId;
            }
            
            if(Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isUpdateable()){ upsert Logistic; } 
            else{ return 'Don\'t have access to upsert logistic'; }
            
            list<String> SOLIIds=new list<String>();
            list<String> ordItemIds=new list<String>();
            list<String> POItemIds=new list<String>();
            
            for(ERP7__Logistic_Line_Item__c log:LogisticLI){
                String Name = log.Name;
                if(Name.length() > 80) log.Name = Name.subString(0,79);
                log.ERP7__Status__c = 'Reserved';
                log.ERP7__Logistic__c = Logistic.Id;
                if(log.ERP7__Sales_Order_Line_Item__c !=null) SOLIIds.add(log.ERP7__Sales_Order_Line_Item__c);
                if(log.ERP7__Order_Product__c !=null) ordItemIds.add(log.ERP7__Order_Product__c);
                if(log.ERP7__Purchase_Line_Items__c !=null) POItemIds.add(log.ERP7__Purchase_Line_Items__c);                
            }
            
            if(LogisticLI.size() > 0){
                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable()){ 
                    upsert LogisticLI; 
                } else{ return 'Does not have access to upsert logistic line items'; } 
            }
            
            List<ERP7__Stock_Outward_Line_Item__c> SWLIToUpsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            Map<Id, ERP7__Inventory_Stock__c> pliStock = new Map<Id, ERP7__Inventory_Stock__c>();
            Map<Id, Stock_Outward_Line_Item__c> pliStockInward = new Map<Id, Stock_Outward_Line_Item__c>();
            List<Inventory_Stock__c> Inventory2Upsert = new List<Inventory_Stock__c>();
            //changed below code Arshad 09 Aug 23
            for(ERP7__Logistic_Line_Item__c log:LogisticLI){
                system.debug('log line item inhere');
                if(log.ERP7__Product__c != null && log.ERP7__Quantity__c > 0 && ((Logistic.ERP7__Sales_Order__c != null && log.ERP7__Sales_Order_Line_Item__c != null) || (Logistic.ERP7__Order_S__c != null && log.ERP7__Order_Product__c != null))){
                    if(Logistic.ERP7__Purchase_Order__c == null && proInvMap.containsKey(log.ERP7__Product__c) && proSerial.containsKey(log.ERP7__Product__c)){
                        system.debug('log line item inhere2 log.ERP7__Quantity__c~>'+log.ERP7__Quantity__c);
                        Decimal remainintQty = log.ERP7__Quantity__c;
                        
                        for(ERP7__Inventory_Stock__c inv : proInvMap.get(log.ERP7__Product__c)){
                            if(remainintQty > 0){
                                Decimal qtytoprocess = 0;
                                if(proSerial.get(log.ERP7__Product__c)){
                                    Inventory_Stock__c inv2Create = new Inventory_Stock__c(Active__c = true, Product__c = log.ERP7__Product__c, Name = 'Serial Stock Holder', Warehouse__c = dc.ERP7__Site__c);
                                    Inventory2Upsert.add(inv2Create);
                                    system.debug('inhere serial');
                                    qtytoprocess = 0;
                                    ERP7__Stock_Outward_Line_Item__c sto = new ERP7__Stock_Outward_Line_Item__c();
                                    sto.Name = 'Serial Stock Holder'; 
                                    sto.ERP7__Product__c = log.ERP7__Product__c; 
                                    sto.ERP7__Active__c = true; 
                                    sto.ERP7__Status__c = 'Reserved'; 
                                     if(log.ERP7__Sales_Order_Line_Item__c != null) sto.ERP7__Sales_Order_Line_Item__c = log.ERP7__Sales_Order_Line_Item__c; 
                                    if(Logistic.ERP7__Sales_Order__c != null) sto.ERP7__Sales_Order__c = Logistic.ERP7__Sales_Order__c;
                                    
                                    if(log.ERP7__Order_Product__c != null) sto.ERP7__Order_Product__c = log.ERP7__Order_Product__c;
                                    if(Logistic.ERP7__Order_S__c != null) sto.ERP7__Order__c = Logistic.ERP7__Order_S__c; 
                                    sto.ERP7__Logistic_Line_Item__c = log.Id;
                                    sto.ERP7__Quantity__c = remainintQty;
                                    SWLIToUpsert.add(sto);
                                    pliStock.put(log.Id,inv2Create);
                                    pliStockInward.put(log.Id,sto);
                                    remainintQty = 0;
                                    system.debug('qtytoprocess~>'+qtytoprocess);
                                    system.debug('remainintQty~>'+remainintQty);
                                }
                                else{
                                    system.debug('inhere non serial inv.Number_of_Item_In_Stock__c~>'+inv.Number_of_Item_In_Stock__c);
                                    if(inv.Number_of_Item_In_Stock__c < remainintQty){
                                        system.debug('inhere inv.Number_of_Item_In_Stock__c < remainintQty');
                                        qtytoprocess = inv.Number_of_Item_In_Stock__c;
                                        remainintQty = remainintQty - inv.Number_of_Item_In_Stock__c;
                                    }else{
                                        system.debug('inhere else inv.Number_of_Item_In_Stock__c >= remainintQty');
                                        qtytoprocess = remainintQty;
                                        remainintQty = remainintQty - qtytoprocess;
                                    }
                                    system.debug('qtytoprocess~>'+qtytoprocess);
                                    system.debug('remainintQty~>'+remainintQty);
                                }
                                
                                if(qtytoprocess > 0){
                                    ERP7__Stock_Outward_Line_Item__c sto = new ERP7__Stock_Outward_Line_Item__c();
                                    sto.Name = log.Name; 
                                    
                                    if(log.ERP7__Sales_Order_Line_Item__c != null) sto.ERP7__Sales_Order_Line_Item__c = log.ERP7__Sales_Order_Line_Item__c; 
                                    if(Logistic.ERP7__Sales_Order__c != null) sto.ERP7__Sales_Order__c = Logistic.ERP7__Sales_Order__c;
                                    
                                    if(log.ERP7__Order_Product__c != null) sto.ERP7__Order_Product__c = log.ERP7__Order_Product__c;
                                    if(Logistic.ERP7__Order_S__c != null) sto.ERP7__Order__c = Logistic.ERP7__Order_S__c; 
                                    
                                    sto.ERP7__Product__c = log.ERP7__Product__c; 
                                    sto.ERP7__Active__c = true; 
                                    sto.ERP7__Status__c = 'Reserved'; 
                                    
                                    if(proSerial.get(log.ERP7__Product__c)) sto.ERP7__Quantity__c = 1;
                                    else sto.ERP7__Quantity__c = qtytoprocess; 
                                    
                                    system.debug('inv.Id for stock outward~>'+inv.Id);
                                    sto.ERP7__Site_Product_Service_Inventory_Stock__c = inv.Id; 
                                    sto.ERP7__Logistic_Line_Item__c = log.Id;
                                    
                                    if(MRPmap.containsKey(log.ERP7__Product__c)) sto.ERP7__MRP_Material_Requirements_Planning__c = MRPmap.get(log.ERP7__Product__c).Id;
                                    
                                    system.debug('inv.ERP7__Serial__c~>'+inv.ERP7__Serial__c);
                                    
                                    if(inv.ERP7__Serial__c != null) sto.ERP7__Serial__c = inv.ERP7__Serial__c;
                                    if(inv.ERP7__Batch_Lot__c != null) sto.ERP7__Material_Batch_Lot__c = inv.ERP7__Batch_Lot__c;
                                    if(inv.ERP7__Version__c != null) sto.ERP7__Version__c = inv.ERP7__Version__c;
                                    
                                    SWLIToUpsert.add(sto);
                                }
                            }
                        }
                    }
                }
            }
            //
            
            system.debug('SWLIToUpsert size~>'+SWLIToUpsert.size());
            
            //There was a block of code here in previous method, commented that as not needed - Arshad 10 Aug 23
            if(Inventory2Upsert.size() > 0) insert Inventory2Upsert;
            for(Id pliId : pliStockInward.KeySet()){
                pliStockInward.get(pliId).Site_Product_Service_Inventory_Stock__c= pliStock.get(pliId).Id;
            }
            
            if(SWLIToUpsert.size() > 0){
                if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()) {
                    system.debug('SWLIToUpsert size~>'+SWLIToUpsert.size());
                    upsert SWLIToUpsert; 
                }  else{ return 'Don\'t have access to upsert Stock Outward'; }
            } 
             
            if(SOLIIds.size()>0){
                list<ERP7__Logistic_Line_Item__c> LogLIList=new list<ERP7__Logistic_Line_Item__c>();
                LogLIList=[SELECT Id, Name, ERP7__Quantity__c, ERP7__Sales_Order_Line_Item__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Sales_Order_Line_Item__c IN:SOLIIds];
                
                for(ERP7__Sales_Order_Line_Item__c soli:[SELECT Id, ERP7__Logistic_Quantity__c FROM ERP7__Sales_Order_Line_Item__c WHERE Id IN:SOLIIds]){ 
                    Decimal LogQuantity=0; 
                    for(ERP7__Logistic_Line_Item__c logLi:LogLIList){ 
                        if(logLi.ERP7__Sales_Order_Line_Item__c==soli.Id) LogQuantity+=logLi.ERP7__Quantity__c;                                           
                    }
                    soli.ERP7__Logistic_Quantity__c=LogQuantity;
                    try{ if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Logistic_Quantity__c.isUpdateable()){  update soli; } else { return 'User is not allowed to update SalesOrder Line Item';} }catch(DMLException e){ return e.getMessage() +','+e.getStackTraceString();}     
                } 
            } 
            // else if(POItemIds.size() > 0){
            //     list<ERP7__Logistic_Line_Item__c> LogLIList=new list<ERP7__Logistic_Line_Item__c>();
            //     LogLIList=[SELECT Id, Name, ERP7__Quantity__c, ERP7__Purchase_Line_Items__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Purchase_Line_Items__c IN:POItemIds];
                
            //     for(ERP7__Purchase_Line_Items__c poli:[SELECT Id, ERP7__Logistic_Quantity__c FROM ERP7__Purchase_Line_Items__c WHERE Id IN:POItemIds]){ 
            //         Decimal LogQuantity=0; 
            //         for(ERP7__Logistic_Line_Item__c logLi:LogLIList){
            //             if(logLi.ERP7__Purchase_Line_Items__c==poli.Id) LogQuantity+=logLi.ERP7__Quantity__c;                                           
            //         }
            //         poli.ERP7__Logistic_Quantity__c=LogQuantity;
            //         System.debug('poli.ERP7__Logistic_Quantity__c -> '+poli.ERP7__Logistic_Quantity__c);
            //         try{  if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Logistic_Quantity__c.isUpdateable())  {  System.debug('Updated POLI ->'+poli);    update poli; } else{ return 'User is not allowed to update POLI'; } }catch(DMLException e){return e.getMessage() +','+e.getStackTraceString();}     
            //     } 
            // }
            // updated by matheen on 7/8/25 to optimise bcz its querying in the loop which may lead to hit giverner limit also for large set
            // else if (POItemIds.size() > 0) {
            //         // Query related Logistic Line Items
            //         List<ERP7__Logistic_Line_Item__c> logLIList = [SELECT Id, ERP7__Quantity__c, ERP7__Purchase_Line_Items__c FROM ERP7__Logistic_Line_Item__c WHERE ERP7__Purchase_Line_Items__c IN :POItemIds];
            //         System.debug('logLIList ->'+logLIList);
            //         // Map to store total logistic quantity per Purchase Line Item
            //         Map<Id, Decimal> poliToLogQtyMap = new Map<Id, Decimal>();
            //             for (ERP7__Logistic_Line_Item__c logLI : logLIList) {
            //                 Id poliId = logLI.ERP7__Purchase_Line_Items__c;
            //                 if (poliId != null) {
            //                     Decimal existingQty = poliToLogQtyMap.containsKey(poliId) ? poliToLogQtyMap.get(poliId) : 0;
            //                     poliToLogQtyMap.put(poliId, existingQty + logLI.ERP7__Quantity__c);
            //                 }
            //             }


            //         // Query and update the Purchase Line Items
            //         List<ERP7__Purchase_Line_Items__c> toUpdate = new List<ERP7__Purchase_Line_Items__c>();
            //         for (ERP7__Purchase_Line_Items__c poli : [SELECT Id, ERP7__Logistic_Quantity__c FROM ERP7__Purchase_Line_Items__c WHERE Id IN :POItemIds]) {
            //             Decimal logQty = poliToLogQtyMap.get(poli.Id);
            //             poli.ERP7__Logistic_Quantity__c = (logQty != null) ? logQty : 0;
            //             System.debug('Updated Logistic Quantity for POLI ' + poli.Id + ' = ' + poli.ERP7__Logistic_Quantity__c);
            //             toUpdate.add(poli);
            //         }

            //         // Perform bulk update
            //         if (!toUpdate.isEmpty()) {
            //             if (Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Logistic_Quantity__c.isUpdateable()) {
            //                 try {
            //                     update toUpdate;
            //                 } catch (DMLException e) {
            //                     return e.getMessage() + ', ' + e.getStackTraceString();
            //                 }
            //             } else {
            //                 return 'User is not allowed to update POLI';
            //             }
            //         }
            // }
            else if (POItemIds.size() > 0) {
                // Step 1: Query related Logistic Line Items
                List<ERP7__Logistic_Line_Item__c> logLIList = [
                    SELECT Id, ERP7__Quantity__c, ERP7__Purchase_Line_Items__c
                    FROM ERP7__Logistic_Line_Item__c
                    WHERE ERP7__Purchase_Line_Items__c IN :POItemIds
                ];

                System.debug('===== [LOG] Queried Logistic Line Items =====');
                for (ERP7__Logistic_Line_Item__c lli : logLIList) {
                    System.debug('[LOG] LLI Id = ' + lli.Id + ', POLI Id = ' + lli.ERP7__Purchase_Line_Items__c + ', Quantity = ' + lli.ERP7__Quantity__c);
                }

                // Step 2: Aggregate Logistic Quantity by POLI
                Map<Id, Decimal> poliToLogQtyMap = new Map<Id, Decimal>();
                System.debug('===== [LOG] Starting aggregation =====');

                for (ERP7__Logistic_Line_Item__c logLI : logLIList) {
                    Id poliId = logLI.ERP7__Purchase_Line_Items__c;
                    Decimal lliQty = logLI.ERP7__Quantity__c;

                    if (poliId != null) {
                        Decimal existingQty = poliToLogQtyMap.containsKey(poliId) ? poliToLogQtyMap.get(poliId) : 0;
                        Decimal updatedQty = existingQty + lliQty;
                        poliToLogQtyMap.put(poliId, updatedQty);

                        System.debug('[LOG] Adding to POLI: ' + poliId + ' | LLI Qty: ' + lliQty + ' | Existing Qty: ' + existingQty + ' | Updated Qty: ' + updatedQty);
                    }
                }

                System.debug('===== [LOG] Final Aggregated Logistic Quantities =====');
                for (Id key : poliToLogQtyMap.keySet()) {
                    System.debug('[LOG] POLI: ' + key + ' => Total Logistic Qty: ' + poliToLogQtyMap.get(key));
                }

                // Step 3: Query and Update the Purchase Line Items
                List<ERP7__Purchase_Line_Items__c> toUpdate = new List<ERP7__Purchase_Line_Items__c>();
                for (ERP7__Purchase_Line_Items__c poli : [
                    SELECT Id, ERP7__Logistic_Quantity__c
                    FROM ERP7__Purchase_Line_Items__c
                    WHERE Id IN :POItemIds
                ]) {
                    Decimal logQty = poliToLogQtyMap.get(poli.Id);
                    poli.ERP7__Logistic_Quantity__c = (logQty != null) ? logQty : 0;
                    System.debug('[LOG] Updated Logistic Quantity for POLI ' + poli.Id + ' = ' + poli.ERP7__Logistic_Quantity__c);
                    toUpdate.add(poli);
                }

                // Step 4: Perform the update
                if (!toUpdate.isEmpty()) {
                    if (Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Logistic_Quantity__c.isUpdateable()) {
                        try {
                            update toUpdate;
                            System.debug('[LOG] POLIs updated successfully.');
                        } catch (DMLException e) {
                            System.debug('[ERROR] DML Exception: ' + e.getMessage());
                            return e.getMessage() + ', ' + e.getStackTraceString();
                        }
                    } else {
                        System.debug('[ERROR] Field ERP7__Logistic_Quantity__c is not updateable.');
                        return 'User is not allowed to update POLI';
                    }
                }
            }

            
            return null;   
        }catch(Exception e){
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }    
    }
    @AuraEnabled
    Public Static list<LogisticWrap> getLogisticExisting(String SOId,String OrderId,String POId){ 
        list<LogisticWrap> LogisticList=new list<LogisticWrap>();  
        if(String.isNotEmpty(SOId)){  
            list<ERP7__Logistic__c>  LogList=[SELECT Id, Name, ERP7__Active__c,ERP7__Account__c,ERP7__Account__r.Name, ERP7__Contact__c, ERP7__Contact__r.Name, ERP7__To_Address__c, ERP7__To_Address__r.Name, ERP7__Ready_To_Ship__c,
                                              ERP7__Shipment_type__c, ERP7__Shipping_Preferences__c, ERP7__Billing_options__c, ERP7__Billing_Account_number__c, ERP7__Billing_Country_Code__c, ERP7__Billing_Postal_Code__c, ERP7__Billing_Contact__c, ERP7__Billing_Address__c, ERP7__Special_Instructions__c,
                                              ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c, ERP7__Shipment_type_Return__c, ERP7__Shipping_Preferences_Return__c 
                                              FROM ERP7__Logistic__c WHERE ERP7__Sales_Order__c=:SOId AND ERP7__Active__c=true Order By createdDate ASC];
            
            for(ERP7__Logistic__c log:LogList) { 
                LogisticWrap w=new LogisticWrap(); 
                w.Id=log.Id; w.Name=log.Name;  
                if(log.ERP7__Account__c != null) w.Account=log.ERP7__Account__r.Name; 
                if(log.ERP7__Contact__c != null) w.Contact=log.ERP7__Contact__r.Name;  
                if(log.ERP7__To_Address__c != null) w.ToAddress=log.ERP7__To_Address__r.Name; 
                w.ReadyToShip=log.ERP7__Ready_To_Ship__c;  
                LogisticList.add(w); 
            }
            return LogisticList;   
        }
        else if(String.isNotEmpty(OrderId)){
            list<ERP7__Logistic__c>  LogList=[SELECT Id, Name, ERP7__Active__c,ERP7__Account__c,ERP7__Account__r.Name, ERP7__Contact__c, ERP7__Contact__r.Name, ERP7__To_Address__c, ERP7__To_Address__r.Name, ERP7__Ready_To_Ship__c,
                                              ERP7__Shipment_type__c, ERP7__Shipping_Preferences__c, ERP7__Billing_options__c, ERP7__Billing_Account_number__c, ERP7__Billing_Country_Code__c, ERP7__Billing_Postal_Code__c, ERP7__Billing_Contact__c, ERP7__Billing_Address__c, ERP7__Special_Instructions__c,
                                              ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c, ERP7__Shipment_type_Return__c, ERP7__Shipping_Preferences_Return__c 
                                              FROM ERP7__Logistic__c WHERE ERP7__Order_S__c=:OrderId AND ERP7__Active__c=true Order By createdDate ASC];
            
            
            for(ERP7__Logistic__c log:LogList) {  LogisticWrap w=new LogisticWrap();  w.Id=log.Id; w.Name=log.Name;  w.Account=log.ERP7__Account__r.Name;  w.Contact=log.ERP7__Contact__r.Name;  w.ToAddress=log.ERP7__To_Address__r.Name; w.ReadyToShip=log.ERP7__Ready_To_Ship__c;  LogisticList.add(w); 
                                               }
            return LogisticList;  
        }else if(String.isNotEmpty(POId)){
            list<ERP7__Logistic__c>  LogList=[SELECT Id, Name, ERP7__Active__c,ERP7__Account__c,ERP7__Account__r.Name, ERP7__Contact__c, ERP7__Contact__r.Name, ERP7__To_Address__c, ERP7__To_Address__r.Name, ERP7__Ready_To_Ship__c,
                                              ERP7__Shipment_type__c, ERP7__Shipping_Preferences__c, ERP7__Billing_options__c, ERP7__Billing_Account_number__c, ERP7__Billing_Country_Code__c, ERP7__Billing_Postal_Code__c, ERP7__Billing_Contact__c, ERP7__Billing_Address__c, ERP7__Special_Instructions__c,
                                              ERP7__Bill_To_Return__c, ERP7__Billing_Account_Number_Return__c, ERP7__Billing_Address_Return__c, ERP7__Billing_Contact_Return__c, ERP7__Shipment_type_Return__c, ERP7__Shipping_Preferences_Return__c 
                                              FROM ERP7__Logistic__c WHERE ERP7__Purchase_Order__c=:POId AND ERP7__Active__c=true Order By createdDate ASC];
            
            
            for(ERP7__Logistic__c log:LogList) {  LogisticWrap w=new LogisticWrap();  w.Id=log.Id; w.Name=log.Name;  w.Account=log.ERP7__Account__r.Name;  w.Contact=log.ERP7__Contact__r.Name;  w.ToAddress=log.ERP7__To_Address__r.Name; w.ReadyToShip=log.ERP7__Ready_To_Ship__c;  LogisticList.add(w); 
                                               }
            return LogisticList; 
        } else return null;                                                           
        
    } 
    
    @AuraEnabled
    public static String getUpdateLogistic(String LogisticJSON, String LLIListJSON){ 
        try{
            system.debug('getUpdateLogistic called');
            ERP7__Logistic__c Logistic = (ERP7__Logistic__c) JSON.deserialize(LogisticJSON, ERP7__Logistic__c.class);
            list<ERP7__Logistic_Line_Item__c> LogisticLI = (list<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LLIListJSON, list<ERP7__Logistic_Line_Item__c>.class); 
            set<Id> prodIds=new set<Id>();
            set<Id> loglineIds =new set<Id>();
            for(ERP7__Logistic_Line_Item__c log :LogisticLI){
                if(log.ERP7__Product__c != null) prodIds.add(log.ERP7__Product__c);
                if(log.Id != null) loglineIds.add(log.Id);
            }
            ERP7__Distribution_Channel__c dc = [Select Id,Name,ERP7__Site__c from ERP7__Distribution_Channel__c where Id=:Logistic.ERP7__Distribution_Channel__c Limit 1];
            List<ERP7__Inventory_Stock__c> invtoryList = new List<ERP7__Inventory_Stock__c>();
            invtoryList = [Select Id,Name,ERP7__Product__c,ERP7__Warehouse__c, ERP7__Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,ERP7__Number_of_Item_In_Stock__c, 
                                   ERP7__Number_of_Item_Purchased_In__c, ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c, ERP7__Checked_In_Date__c  from ERP7__Inventory_Stock__c
                                   where ERP7__product__c != null AND ERP7__product__c In:prodIds And ERP7__Active__c = true AND ERP7__Warehouse__c =:dc.ERP7__Site__c 
                                   AND Name != 'Awaiting Stock' And ERP7__Number_of_Item_In_Stock__c > 0 ORDER BY ERP7__Number_of_Item_In_Stock__c DESC];
            
            Map<String,List<ERP7__Inventory_Stock__c>> proInvMap = new Map<String,List<ERP7__Inventory_Stock__c>>();
            Map<String,Decimal> prodStockQtyMap = new Map<String,Decimal>();
            
            for(ERP7__Inventory_Stock__c invt:invtoryList){
                List<ERP7__Inventory_Stock__c> invlistformap = new List<ERP7__Inventory_Stock__c>();
                if(proInvMap.containsKey(invt.ERP7__Product__c)) invlistformap = proInvMap.get(invt.ERP7__Product__c);
                invlistformap.add(invt);
                proInvMap.put(invt.ERP7__Product__c,invlistformap);
                Decimal Qty = 0; 
                if(prodStockQtyMap.containsKey(invt.ERP7__Product__c)) {
                    Qty = prodStockQtyMap.get(invt.ERP7__Product__c);
                } 
                Qty += invt.ERP7__Number_of_Item_In_Stock__c;
                prodStockQtyMap.put(invt.ERP7__Product__c,Qty);
            }
            upsert logistic;
            if(LogisticLI.size() > 0){
                upsert LogisticLI;
            }
            
            List<ERP7__Stock_Outward_Line_Item__c> SWLI = new List<ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Stock_Outward_Line_Item__c> SWLI2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Inventory_Stock__c> inven2updtae = new List<ERP7__Inventory_Stock__c>();
            SWLI = [Select Id,Name,ERP7__Product__c,ERP7__Quantity__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Site_Product_Service_Inventory_Stock__c,ERP7__Logistic_Line_Item__r.ERP7__Quantity__c,ERP7__Order_Product__c,ERP7__Order__c,ERP7__Logistic_Line_Item__c,ERP7__MRP_Material_Requirements_Planning__c from ERP7__Stock_Outward_Line_Item__c where ERP7__Logistic_Line_Item__c IN :loglineIds and  ERP7__Logistic_Line_Item__c != null and ERP7__Quantity__c > 0 and ERP7__Status__c = 'Reserved'];
            
            for(ERP7__Stock_Outward_Line_Item__c stoli : SWLI){
                if(prodStockQtyMap.containsKey(stoli.ERP7__Product__c) && prodStockQtyMap.get(stoli.ERP7__Product__c) >= stoli.ERP7__Quantity__c){
                    if(stoli.ERP7__Product__r.ERP7__Serialise__c){
                        inven2updtae.add(new ERP7__Inventory_Stock__c(Id = stoli.ERP7__Site_Product_Service_Inventory_Stock__c,Warehouse__c = dc.ERP7__Site__c));
                    }
                    else{
                        List<ERP7__Inventory_Stock__c> prodInventory = proInvMap.get(stoli.ERP7__Product__c);
                        if(prodInventory.size() > 0 && prodInventory[0].Number_of_Item_In_Stock__c >= stoli.ERP7__Quantity__c){
                            system.debug('else if 1');
                            stoli.ERP7__Site_Product_Service_Inventory_Stock__c = prodInventory[0].Id; 
                            system.debug('prodInventory[0].ERP7__Batch_Lot__c if : '+prodInventory[0].ERP7__Batch_Lot__c);
                            if(prodInventory[0].ERP7__Batch_Lot__c != null) stoli.ERP7__Material_Batch_Lot__c = prodInventory[0].ERP7__Batch_Lot__c;
                            SWLI2Upsert.add(stoli);
                            system.debug('SWLI2Upsert if: '+SWLI2Upsert.size());
                        }
                        else{
                            decimal remainintQty = stoli.ERP7__Quantity__c;
                            system.debug('remainintQty else 1: '+remainintQty);
                            if(remainintQty > 0 && prodInventory[0].Number_of_Item_In_Stock__c < remainintQty){
                                stoli.ERP7__Quantity__c = prodInventory[0].Number_of_Item_In_Stock__c;
                                stoli.ERP7__Site_Product_Service_Inventory_Stock__c = prodInventory[0].Id;
                                system.debug('prodInventory[0].ERP7__Batch_Lot__c else : '+prodInventory[0].ERP7__Batch_Lot__c);
                                if(prodInventory[0].ERP7__Batch_Lot__c != null) stoli.ERP7__Material_Batch_Lot__c = prodInventory[0].ERP7__Batch_Lot__c;
                                remainintQty = remainintQty - prodInventory[0].Number_of_Item_In_Stock__c;
                                system.debug('remainintQty else 2: '+remainintQty);
                                prodInventory.remove(0);
                                SWLI2Upsert.add(stoli);
                                system.debug('SWLI2Upsert : '+SWLI2Upsert.size());
                                while(remainintQty > 0 && prodInventory.size() > 0){
                                    ERP7__Stock_Outward_Line_Item__c sto = new ERP7__Stock_Outward_Line_Item__c(Name = stoli.Name,ERP7__Order_Product__c = stoli.ERP7__Order_Product__c,ERP7__Order__c = stoli.ERP7__Order__c, ERP7__Product__c = stoli.ERP7__Product__c,ERP7__Active__c = true,ERP7__Status__c = 'Reserved',ERP7__Logistic_Line_Item__c = stoli.ERP7__Logistic_Line_Item__c,ERP7__MRP_Material_Requirements_Planning__c = stoli.ERP7__MRP_Material_Requirements_Planning__c);
                                      //  stoli.clone(true,false,false,false);
                                    sto.ERP7__Quantity__c = (prodInventory[0].Number_of_Item_In_Stock__c >= remainintQty) ? remainintQty : (remainintQty - prodInventory[0].Number_of_Item_In_Stock__c );
                                    sto.ERP7__Site_Product_Service_Inventory_Stock__c = prodInventory[0].Id;
                                    system.debug('prodInventory[0].ERP7__Batch_Lot__c while : '+prodInventory[0].ERP7__Batch_Lot__c);
                                    if(prodInventory[0].ERP7__Batch_Lot__c != null) sto.ERP7__Material_Batch_Lot__c = prodInventory[0].ERP7__Batch_Lot__c;
                                    if(prodInventory[0].ERP7__Version__c != null) sto.ERP7__Version__c = prodInventory[0].ERP7__Version__c;
                                    remainintQty = remainintQty - prodInventory[0].Number_of_Item_In_Stock__c;
                                    system.debug('remainintQty else 3: '+remainintQty);
                                    prodInventory.remove(0);
                                    SWLI2Upsert.add(sto);
                                    system.debug('SWLI2Upsert in while: '+SWLI2Upsert.size());
                                }   
                            }
                            
                        }
                        
                    }
                }
            
            }
            if(inven2updtae.size() > 0) upsert inven2updtae;
            if(SWLI2Upsert.size() > 0) upsert SWLI2Upsert;
        }
        catch(Exception e){
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
        return null;
    }
    Public class LogisticWrap{
        @AuraEnabled
        public String Id {get;set;} 
        @AuraEnabled
        public String Name {get;set;} 
        @AuraEnabled
        public String Account {get;set;} 
        @AuraEnabled
        public String Contact {get;set;} 
        @AuraEnabled
        public String ToAddress {get;set;} 
        @AuraEnabled
        public Boolean ReadyToShip   {get;set;} 
        
        public LogisticWrap(){
            Name=Account=Contact=ToAddress='';  ReadyToShip=false;   
        }    
        
    }
    // For dependent Picklist
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    @AuraEnabled 
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        System.debug('ObjectName : '+ObjectName);
        System.debug('parentField: '+parentField);
        System.debug('childField: '+childField);
        Map<String,List<SelectOption>> pickListMap = new Map<String,List<SelectOption>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        List<SelectOption> controllingValues = new List<SelectOption>();
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        
        
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            //system.debug('arshad ple~>'+ple); 
            pickListMap.put(ple.getLabel(), new List<SelectOption>());
            controllingValues.add(new SelectOption(ple.value,ple.label));
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    if(controllingValues.get(i).label != System.label.NonePicklistType){
                        pickListMap.get(controllingValues.get(i).label).add(new SelectOption(plew.value,plew.label));
                    }
                }
            }
        }
        
        if(controllingValues.size() > 0){
            controllingValues.add(0,new SelectOption('',System.label.NonePicklistType));
        }
        
        pw.controllingValues = controllingValues;
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
        public Map<String, List<SelectOption>> pickListMap;
        @AuraEnabled
        public List<SelectOption> controllingValues;
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
    public class logWrap{
        @AuraEnabled
        public  ERP7__Logistic__c logistic {get;set;}
        @AuraEnabled
        public  List<ERP7__Logistic_Line_Item__c> logItems {get;set;}
        @AuraEnabled
        public  String shipPreferences {get;set;}
        @AuraEnabled
        public  String shipReturnPreferences {get;set;}
        public logWrap(){
            logistic = new ERP7__Logistic__c();
            logItems = new List<ERP7__Logistic_Line_Item__c>();
            shipPreferences = shipReturnPreferences = '';
        }
    }
    
}