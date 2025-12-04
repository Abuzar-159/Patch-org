public with sharing class MultiplePO {
    @AuraEnabled
    public static ERP7__Distribution_Channel__c getnewDc( String DCId){
        List<ERP7__Distribution_Channel__c> dcList = [Select Id,Name,ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c where Id =: DCId limit 1 ]; 
        if(dcList.size() > 0) return dcList[0];
        else return null;
    }
    
    @AuraEnabled
    public static createCCWrapper createCCnew(ERP7__Cost_Card__c CC){
        createCCWrapper ccwrap = new createCCWrapper();
        try {
            ERP7__Cost_Card__c costcard = CC;
            upsert costcard;
            ccwrap.CC = costcard;
        }
        catch (Exception e) { ccwrap.exError='Error Message:'+e.getMessage()+'   Line Number:'+e.getLineNumber(); } 
        return ccwrap;
    }
    public class createCCWrapper{
        @AuraEnabled public ERP7__Cost_Card__c CC        { get; set; }
        @AuraEnabled public String exError              { get; set; }
        public createCCWrapper(){
            CC=new ERP7__Cost_Card__c();
            exError='';
        }
    }
    @AuraEnabled
    public static poliWrap fetchChannelandDC(){
        System.debug('Inside apex method fetchChannelandDC');
        poliWrap mulPO = new poliWrap();
        try{
            set<polilistWrap> initialpoli = new set<polilistWrap>();
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c,ERP7__Channel__r.Id,ERP7__Channel__r.Name from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId() AND ERP7__Active__c = true];
            system.debug('empList.size() : '+empList.size());
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ 
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
            }
            system.debug('FC : '+FC);
            if(FC != null){
                system.debug('FC unit price: '+FC.ERP7__Enable_Unit_price_edit_in_PO__c);
                mulPO.editUnitPrice = FC.ERP7__Enable_Unit_price_edit_in_PO__c;
                mulPO.enableReceive = FC.ERP7__Show_Receive_on_PO__c;
                mulPO.showUpload = FC.ERP7__Show_Upload_in_Create_PO__c;
                mulPO.AllocationAccess = FC.ERP7__Allocation_Process__c;
                mulPO.submitApproval= FC.ERP7__Submit_For_Approval_MultiPO__c;
                mulPO.addressRequired = FC.ERP7__Po_Screen_Vendor_Address_Required__c;
            }
            if(empList.size()>0 && empList != null){
                mulPO.channel = empList[0].ERP7__Channel__c;
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                system.debug('dcList.size() : '+dcList.size());
                if(dcList.size()>0 && dcList != null) {
                    mulPO.distributionChannel = dcList[0];
                    set<Id> prodIds = new set<Id>();
                    set<Id> apprvId = new set<Id>();
                    //List<sObject> prodIdds = new List<sObject>();//change added from here -Asra-11/12
                    Decimal myStock =0.00;
                    Decimal Awaitingstocks =0.00;
                    Decimal demands =0.00;
                    Map<Id,decimal> DemandProd = new Map<Id,decimal>();
                    Map<Id,decimal> StockProd = new Map<Id,decimal>();
                    Map<Id,decimal> AwaitProd = new Map<Id,decimal>();
                    for(AggregateResult result: [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock,SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c)totalAwaiting,SUM(ERP7__No_of_Items_Requested__c) totalRequested  FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c =: dcList[0].ERP7__Site__c And (ERP7__Number_of_Item_In_Stock__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0) GROUP BY ERP7__Product__c]) { 
                        Id prodId = (Id)result.get('ERP7__Product__c');
                        if((Decimal)result.get('totalRequested') > 0 ){
                            prodIds.add(prodId); 
                            //warehouseId.add((Id)result.get('getInvid'));
                        }
                        myStock =(Decimal)result.get('totalStock');
                        StockProd.put(prodId,myStock);
                        Awaitingstocks = (Decimal)result.get('totalAwaiting'); 
                        AwaitProd.put(prodId,Awaitingstocks);
                        demands = (Decimal)result.get('totalRequested'); 
                        DemandProd.put(prodId,demands);
                        
                    }
                    List<Product2> Prods = [Select Id,Name,ERP7__Vendor_product_Name__c, ERP7__Purchase_From_Approved_Vendor__c,ERP7__Purchase_Lead_Time_days__c,Description from Product2 where Id =:prodIds And ERP7__Issue_Purchase_Order__c = true And IsActive = true and ERP7__Track_Inventory__c = true limit 100];//And ERP7__Issue_Manufacturing_Order__c = false --removed
                    //for(Product2 pr : Prods) prodIds.add(pr.Id);//change added till here -Asra-11/12
                    List<ERP7__Approved_Vendor__c> approvedVen = new List<ERP7__Approved_Vendor__c>();
                    approvedVen = [Select Id,Name,ERP7__Cost_Card__c,ERP7__Product__c,ERP7__Vendor__c,ERP7__Lead_Time__c,ERP7__Vendor__r.Name,ERP7__Vendor__r.Id,ERP7__Cost_Card__r.Name,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Cost_Card__r.ERP7__Quantity__c,ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c,ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c,ERP7__Cost_Card__r.ERP7__Start_Date__c, ERP7__Cost_Card__r.ERP7__End_Date__c From ERP7__Approved_Vendor__c where ERP7__Product__c IN :prodIds and ERP7__Cost_Card__c != ''];
                    Map<String, List<ERP7__Approved_Vendor__c>> ProdVen = new Map<String, List<ERP7__Approved_Vendor__c>>();
                    system.debug('prodIds : '+prodIds.size());
                    system.debug('Prods: '+Prods);
                    system.debug('approvedVen : '+approvedVen.size());
                    for(ERP7__Approved_Vendor__c apr : approvedVen) {
                        apprvId.add(apr.ERP7__Product__c);//
                        if(ProdVen.ContainsKey(apr.ERP7__Product__c)) ProdVen.get(apr.ERP7__Product__c).add(apr);
                        else ProdVen.put(apr.ERP7__Product__c,new List<ERP7__Approved_Vendor__c>{apr});
                        system.debug('approvedVen : '+approvedVen);
                    }
                    system.debug('prodIds: '+prodIds);
                    for(Product2 prod : Prods){
                        system.debug('prod name : '+prod.Name);
                        polilistWrap pp = new polilistWrap();
                        if(DemandProd.containskey(prod.Id) && DemandProd.get(prod.Id) > 0 && AwaitProd.containskey(prod.Id) && StockProd.containskey(prod.Id)) {
                            pp.pli = new ERP7__Purchase_Line_Items__c(Name=prod.Name,ERP7__Vendor_product_Name__c=prod.ERP7__Vendor_product_Name__c,ERP7__Product__c = prod.Id,ERP7__Lead_Time_Days__c=prod.ERP7__Purchase_Lead_Time_days__c,ERP7__Description__c = prod.Description);
                            Decimal dem =DemandProd.get(prod.Id).setScale(3, System.RoundingMode.HALF_UP);
                            System.debug('prodName: '+prod.Name +', prodDemand: '+dem);
                            pp.Demand = dem;
                            pp.Stock = StockProd.get(prod.Id);
                            pp.AwaitingStocks = AwaitProd.get(prod.Id);
                            pp.appvendr = ProdVen.get(prod.Id);
                            //pp.isSelected = true;
                            pp.purchaseAppVendor = prod.ERP7__Purchase_From_Approved_Vendor__c;
                            pp.customProduct = false;
                        }
                        system.debug('pp.pli : '+pp.pli.ERP7__Product__c);
                        if(pp.pli.ERP7__Product__c != null) initialpoli.add(pp);
                        
                    }
                }
                system.debug('initialpoli : '+initialpoli.size());
                if(initialpoli.size() > 0) {
                    mulPO.poli.addAll(initialpoli);
                    
                }
                else{
                    polilistWrap pp = new polilistWrap();
                    pp.pli = new ERP7__Purchase_Line_Items__c(Name='',ERP7__Vendor_product_Name__c='');
                    pp.isSelected = false;
                    pp.customProduct = false;
                    initialpoli.add(pp);
                    mulPO.poli.addAll(initialpoli);
                }
            }
        }
        catch(Exception e){ system.debug('Error at fetchChannelandDC : '+e.getLineNumber()+'  Message : '+e.getMessage()); }
        return mulPO;
        
    }
    @AuraEnabled
    public static poliWrap populateMOlines(String MOId){
        if(MOId != null && MOId != ''){
            
            poliWrap pwrap = new poliWrap();
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ 
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
            }
            system.debug('FC : '+FC);
            if(FC != null){
                system.debug('FC unit price: '+FC.ERP7__Enable_Unit_price_edit_in_PO__c);
                pwrap.editUnitPrice = FC.ERP7__Enable_Unit_price_edit_in_PO__c;
                pwrap.enableReceive = FC.ERP7__Show_Receive_on_PO__c;
                pwrap.AllolateProcess = FC.ERP7__Allocation_Process__c;
                pwrap.addressRequired = FC.ERP7__Po_Screen_Vendor_Address_Required__c;
                pwrap.showUpload = FC.ERP7__Show_Upload_in_Create_PO__c;
                pwrap.submitApproval= FC.ERP7__Submit_For_Approval_MultiPO__c;
            }
            set<polilistWrap> initialpoli = new set<polilistWrap>();
            set<Id> productsWithNoStock = new set<Id>();
            String MOFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
            String AllMOFields = MOFields + ', ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Product__r.Name, ERP7__Product__r.QuantityUnitOfMeasure, ERP7__Version__r.Name, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Manufacturing_Order__r.Name, ERP7__Routing__r.ERP7__Finished_Products_Site__c ';
            ERP7__Manufacturing_Order__c MO = Database.query('SELECT '+String.escapeSingleQuotes(AllMOFields)+' FROM ERP7__Manufacturing_Order__c WHERE Id = :MOId Limit 1');
            String selectedSite = MO.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            if(selectedSite != null && selectedSite != ''){
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Site__c=:selectedSite and ERP7__Active__c=true order by ERP7__Priority__c ASC limit 1];
                if(dcList.size() > 0) {
                    pwrap.distributionChannel = dcList[0];  
                    pwrap.channel = dcList[0].ERP7__Channel__c;
                }
            }
            
            String mrpFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(mrpFields.split(','),'ERP7__MRP__c');
            String query = 'select ' + String.escapeSingleQuotes(mrpFields) + ', ERP7__MRP_Product__r.Name,ERP7__MRP_Product__r.ERP7__Serialise__c,ERP7__MRP_Product__r.QuantityUnitOfMeasure,ERP7__BOM__r.ERP7__Unit_of_Measure__c from ERP7__MRP__c where ERP7__MO__c =: MOId ';
            List<ERP7__MRP__c> MRPS = Database.query(query);
            
            Set<Id> proIds = new Set<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            Map<Id, Decimal> DemandMap = new Map<Id, Decimal>();
            Map<Id, Decimal> AwaitingstockMap = new Map<Id, Decimal>();
            for(MRP__c mrp : MRPS){
                if(mrp.ERP7__MRP_Product__c != Null ) proIds.add(mrp.ERP7__MRP_Product__c);
            }
            
            Map<Id, ERP7__Reordering_Rule__c> RRMap = new Map<Id, ERP7__Reordering_Rule__c>();
            if(selectedSite != Null && selectedSite != ''){
                List<ERP7__Reordering_Rule__c> ReorderingRules = [Select Id, Name, ERP7__Base_Quantity__c, ERP7__Channel__c, ERP7__Lead_Time__c, 
                                                                  ERP7__Maximum_Quantity__c, ERP7__Minimum_Quantity__c, ERP7__Product__c, ERP7__Warning_Quantity__c,
                                                                  ERP7__Quantity_Multiple__c, ERP7__Stock_Quantity__c, ERP7__Warehouse__c, ERP7__MinimumHoldingQuantity__c, ERP7__MinimumOrderingQuantity__c
                                                                  From ERP7__Reordering_Rule__c
                                                                  Where ERP7__Product__c In :proIds And
                                                                  ERP7__MinimumHoldingQuantity__c != Null And
                                                                  ERP7__MinimumOrderingQuantity__c != Null And
                                                                  ERP7__Warehouse__c = :selectedSite
                                                                  Order By CreatedDate Desc];
                for (ERP7__Reordering_Rule__c RR : ReorderingRules) if(!RRMap.containsKey(RR.ERP7__Product__c)) RRMap.put(RR.ERP7__Product__c,RR); 
                
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + ''; 
                List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                                    +' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds) And Active__c = true) Order By ERP7__Expiry_Date__c ASC');  // And Number_of_Item_In_Stock__c > 0
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    Decimal mydemand = 0;
                    Decimal myAwaitingStock = 0;
                    for(Inventory_Stock__c stock : WIISLists){
                        if(proId == stock.Product__c && stock.Number_of_Item_In_Stock__c > 0){
                            myStock += stock.Number_of_Item_In_Stock__c;
                        }
                        if(proId == stock.Product__c && stock.ERP7__No_of_Items_Requested__c > 0){
                            mydemand += stock.ERP7__No_of_Items_Requested__c;
                        }
                        if(proId == stock.Product__c && stock.ERP7__Number_of_Items_Awaiting_in_Stock__c > 0){
                            myAwaitingStock += stock.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                        }
                    }
                    stockMap.put(proId,myStock);
                    AwaitingstockMap.put(proId,myAwaitingStock);
                    DemandMap.put(proId,mydemand);
                }
            }
            Map<Id,Decimal> MRPRequiredQtyMap = new Map<Id,Decimal>();
            Map<Id,MRP__c> MRPMap = new Map<Id,MRP__c>();
            //Shaguftha M change 13-11-2023
            List<ERP7__UOM_Conversion__mdt> uom = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 1000];
              
            
            for(MRP__c mrp : MRPS){
                 decimal weightMultiplier = 1;
                if(mrp.ERP7__BOM__c != null && mrp.ERP7__MRP_Product__c != null){
                    String newUOM = mrp.ERP7__MRP_Product__r.QuantityUnitOfMeasure; 
                    String oldUOM = mrp.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                    if(newUOM != '' && newUOM != null && oldUOM != '' && oldUOM != null && newUOM != oldUOM){
                        for(ERP7__UOM_Conversion__mdt uomNew  : uom){
                            if((uomNew.ERP7__From_UOM__c == oldUOM && uomNew.ERP7__To_UOM__c == newUOM) || (uomNew.ERP7__From_UOM__c == newUOM && uomNew.ERP7__To_UOM__c == oldUOM)){
                                if(uomNew.ERP7__From_UOM__c == oldUOM && uomNew.ERP7__To_UOM__c == newUOM){
                                    system.debug('1');
                                   weightMultiplier = uomNew.ERP7__From_Value__c/uomNew.ERP7__To_Value__c;
                                } else if(uomNew.ERP7__From_UOM__c == newUOM && uomNew.ERP7__To_UOM__c == oldUOM){
                                    system.debug('2');
                                    weightMultiplier = uomNew.ERP7__To_Value__c/uomNew.ERP7__From_Value__c;
                                }
                            } 
                        }
                    }
                    
                }
                system.debug('weightMultiplier : '+weightMultiplier);
                
                if(mrp.ERP7__MRP_Product__c != Null && stockMap.containsKey(mrp.ERP7__MRP_Product__c) && mrp.ERP7__Fulfilled_Amount__c != (mrp.ERP7__Total_Amount_Required__c/weightMultiplier)){
                    Decimal FA = (mrp.ERP7__Fulfilled_Amount__c != Null)? mrp.ERP7__Fulfilled_Amount__c : 0;
                    system.debug('FA : '+FA);
                    if(stockMap.get(mrp.ERP7__MRP_Product__c) < ((mrp.ERP7__Total_Amount_Required__c/weightMultiplier) - FA)){
                        productsWithNoStock.add(mrp.ERP7__MRP_Product__c);
                        Decimal curQuan = mrp.ERP7__Total_Amount_Required__c - FA - stockMap.get(mrp.ERP7__MRP_Product__c);
                        system.debug('curQuan : '+curQuan);
                        curQuan = (mrp.ERP7__MRP_Product__r.ERP7__Serialise__c) ? Math.round(curQuan/weightMultiplier) : (curQuan/weightMultiplier).setScale(3);
                        if(RRMap.containsKey(mrp.ERP7__MRP_Product__c) && RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c != null && RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c > curQuan) curQuan = RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c;
                        MRPRequiredQtyMap.put(mrp.ERP7__MRP_Product__c, curQuan);
                        system.debug('MRPRequiredQtyMap : '+MRPRequiredQtyMap);
                        MRPMap.put(mrp.ERP7__MRP_Product__c,mrp);
                    }
                }
            }
            if(productsWithNoStock.size() > 0){
                string appr = 'Approved';
                List<ERP7__Approved_Vendor__c> approvedVen = new List<ERP7__Approved_Vendor__c>();
                approvedVen = [Select Id,Name,ERP7__Cost_Card__c,ERP7__Product__c,ERP7__Vendor__c,ERP7__Lead_Time__c,ERP7__Vendor__r.Name,ERP7__Vendor__r.Id,ERP7__Cost_Card__r.Name,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Cost_Card__r.ERP7__Quantity__c,ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c,ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c,ERP7__Product__r.Description, ERP7__Cost_Card__r.ERP7__Start_Date__c, ERP7__Cost_Card__r.ERP7__End_Date__c From ERP7__Approved_Vendor__c where ERP7__Product__c IN :productsWithNoStock and ERP7__Status__c=:appr and ERP7__Vendor__c != null and ERP7__Cost_Card__c != '' Order By ERP7__Vendor__c]; 
                Map<String, List<ERP7__Approved_Vendor__c>> ProdVen = new Map<String, List<ERP7__Approved_Vendor__c>>();
                system.debug('approvedVen : '+approvedVen.size());
                for(ERP7__Approved_Vendor__c apr : approvedVen) {
                    if(ProdVen.ContainsKey(apr.ERP7__Product__c)) ProdVen.get(apr.ERP7__Product__c).add(apr);
                    else ProdVen.put(apr.ERP7__Product__c,new List<ERP7__Approved_Vendor__c>{apr});
                }
                List<Product2> Prods = [Select Id,Name,Description,ERP7__Vendor_product_Name__c,ERP7__Purchase_Lead_Time_days__c, ERP7__Purchase_From_Approved_Vendor__c from Product2 where ERP7__Issue_Purchase_Order__c = true And IsActive = true and ERP7__Track_Inventory__c = true and Id IN :productsWithNoStock limit 1000];
                for(Product2 prod : Prods){ 
                    polilistWrap pp = new polilistWrap();
                    system.debug('MRPRequiredQtyMap.containsKey(prod.Id) : '+MRPRequiredQtyMap.containsKey(prod.Id));
                    system.debug('prod : '+prod);
                    pp.pli = new ERP7__Purchase_Line_Items__c(Name=prod.Name,ERP7__Description__c=prod.Description,ERP7__Vendor_product_Name__c=prod.ERP7__Vendor_product_Name__c,ERP7__Product__c = prod.Id,ERP7__Lead_Time_Days__c = prod.ERP7__Purchase_Lead_Time_days__c,ERP7__Quantity__c = MRPRequiredQtyMap.containsKey(prod.Id) ? MRPRequiredQtyMap.get(prod.Id) : 0,ERP7__MRP_Material_Requirements_Planning__c = MRPMap.containsKey(prod.Id) ? MRPMap.get(prod.Id).Id  : '');
                    pp.Demand = (DemandMap.containsKey(prod.Id)) ? DemandMap.get(prod.Id).SetScale(3) : 0;
                    pp.Stock = (stockMap.containsKey(prod.Id)) ? stockMap.get(prod.Id) : 0;
                    pp.AwaitingStocks = (AwaitingstockMap.containsKey(prod.Id)) ? AwaitingstockMap.get(prod.Id) : 0;
                    pp.appvendr = ProdVen.get(prod.Id);
                    pp.purchaseAppVendor = prod.ERP7__Purchase_From_Approved_Vendor__c;
                    if(pp.pli.ERP7__Product__c != null) initialpoli.add(pp);
                }
                if(initialpoli.size() > 0) {
                    pwrap.poli.addAll(initialpoli);
                    
                }
                else{
                    pwrap.errorMSg = 'Products might have the required stock or missing the approved vendor set up!!';
                    polilistWrap pp = new polilistWrap();
                    pp.pli = new ERP7__Purchase_Line_Items__c(Name='',ERP7__Vendor_product_Name__c='');
                    pp.isSelected = false;
                    initialpoli.add(pp);
                    pwrap.poli.addAll(initialpoli);
                }
            }
            
            return pwrap;
        }
        else return null;
    }
    @AuraEnabled
    public static polilistWrap getvendor(String ProductId){
        polilistWrap poliwrp = new polilistWrap();
        
        List<ERP7__Approved_Vendor__c> approvedVen = new List<ERP7__Approved_Vendor__c>();
        try{
            String temp = ProductId.replace('"','');
            if(String.isNotEmpty(ProductId)){
                approvedVen = [Select Id,Name,ERP7__Cost_Card__c,ERP7__Product__c,ERP7__Vendor__c,ERP7__Lead_Time__c,ERP7__Vendor__r.Name,ERP7__Vendor__r.Id,ERP7__Cost_Card__r.Name,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Cost_Card__r.ERP7__Quantity__c,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Vendor_product_Name__c From ERP7__Approved_Vendor__c where ERP7__Product__c = :temp and ERP7__Cost_Card__c != ''];
                
            }
        }catch(Exception e){ /*'Error at getvendor : '+e.getLineNumber()+'  Message : '+e.getMessage()*/ }
        poliwrp.appvendr = approvedVen;
        
        // if(poliwrp.diffDmnStk < 0)  poliwrp.diffDmnStk = 0.0;
        return poliwrp;
        
        
    }
    @AuraEnabled
    public static ProductStock getstocks(String ProductId,String DCId){
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
        pr.Demand = demand.SetScale(3);
        pr.Stock = myStock;
        pr.AwaitingStocks=Awaitingstock;
        return pr;
        
    }
    @AuraEnabled
    public static ERP7__Cost_Card__c populatepolidetails(String ProductId,String venId){
        ERP7__Cost_Card__c cc = new ERP7__Cost_Card__c();
        String ProdId = ProductId.replace('"','');
        if(String.isNotEmpty(ProdId) && String.isNotEmpty(venId)){
            ERP7__Approved_Vendor__c appven = [Select Id,Name,ERP7__Cost_Card__c,ERP7__Product__c,ERP7__Vendor__c,ERP7__Lead_Time__c,ERP7__Vendor__r.Name,ERP7__Vendor__r.Id,ERP7__Cost_Card__r.Name,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Cost_Card__r.ERP7__Quantity__c From ERP7__Approved_Vendor__c where ERP7__Product__c = :ProdId AND Id=:venId limit 1];
            Id ccId = appven.ERP7__Cost_Card__c;
            Id vendorId = appven.ERP7__Vendor__c;
            cc = [Select Id,Name , ERP7__Cost__c,ERP7__Product__c,ERP7__Supplier__c,ERP7__Supplier__r.Name , ERP7__Minimum_Quantity__c,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Vendor_product_Name__c from ERP7__Cost_Card__c where Id=: ccId limit 1];
            
        }
        return cc;
        
        
    }
    @AuraEnabled
    public static string getvenId(String ProductId, String vendorId){
        String venid ='';
        List<ERP7__Approved_Vendor__c> appven = [Select Id,Name,ERP7__Cost_Card__c,ERP7__Product__c,ERP7__Vendor__c,ERP7__Lead_Time__c,ERP7__Vendor__r.Name,ERP7__Vendor__r.Id,ERP7__Cost_Card__r.Name,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Cost_Card__r.ERP7__Quantity__c From ERP7__Approved_Vendor__c where ERP7__Product__c = :ProductId AND Id=:vendorId ];
        if(appven.size() > 0) venid = appven[0].ERP7__Vendor__c;
        return venid;
    }
    
    @AuraEnabled
    public static string getvendorId(String ProductId, String vendorId){
        String venid ='';
        Account vendor = [Select Id,Name From Account where Id=:vendorId ];
        return vendor.Id;
    }
    
    @AuraEnabled
    public static Product2 getProdDetails(String ProductId){
        String venid ='';
        Product2 product = [Select Id,Name, ERP7__Vendor_product_Name__c,Description, ERP7__Purchase_From_Approved_Vendor__c,ERP7__Purchase_Lead_Time_days__c, (Select Id,ERP7__Vendor__c,ERP7__Lead_Time__c from ERP7__Approved_Vendors__r) From Product2 where Id = :ProductId];
        return product;
    }
    
    
    @AuraEnabled
    public static ERP7__Cost_Card__c fetchPrice(String ccId){
        ERP7__Cost_Card__c cc = new ERP7__Cost_Card__c();
        if(String.isNotEmpty(ccId)){
            cc  = [Select Id,Name , ERP7__Cost__c,ERP7__Product__c,ERP7__Vendor_Part_Number__c,ERP7__Supplier__c,ERP7__Supplier__r.Name ,ERP7__Quantity__c, ERP7__Minimum_Quantity__c,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Vendor_product_Name__c from ERP7__Cost_Card__c where Id=: ccId limit 1];
            return cc;
        }else{ return null; }
        
    }
    
    @AuraEnabled
    public static String fetchProdCode(String prodId){
        if(String.isNotEmpty(prodId)){
            String pcode = '';
            Product2 prod  = [Select Id, Name, ERP7__Vendor_product_Name__c from Product2 where Id=: prodId limit 1];
            pcode = prod.ERP7__Vendor_product_Name__c;
            return pcode;
        }else{ return null; }
        
    }
    @AuraEnabled
    public static allPOwrap getAllPO(String polist,String chanId,String DCId){
        List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                            where ERP7__Employee_User__c=:UserInfo.getUserId() AND ERP7__Active__c = true];
        String OrgId = '';
        String empId = '';
        if(chanId == null || chanId == '') chanId=empList[0].ERP7__Channel__c;
        if(DCId == null || DCId == ''){
            List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                          where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
            DCId = dcList[0].Id;
        }
        Account acc = new Account();
        String billadd, deliveryadd = '';
        if(empList.size()>0 && empList != null){
            empId = empList[0].Id;
            if(empList[0].ERP7__Channel__r.ERP7__Organisation__c != null)  acc = [Select Id , Name   from Account Where Id=:empList[0].ERP7__Channel__r.ERP7__Organisation__c   limit 1];
            if(acc != null){
                OrgId = acc.Id;
                List<ERP7__Address__c> Addresses = [SELECT Id, Name, ERP7__Active__c, ERP7__Is_Billing_Address__c, ERP7__Is_Shipping_Address__c, ERP7__Customer__c, ERP7__Primary__c FROM ERP7__Address__c WHERE ERP7__Active__c = true And ERP7__Customer__c =: OrgId And (ERP7__Is_Billing_Address__c = true Or ERP7__Is_Shipping_Address__c = true) Order By ERP7__Primary__c DESC LIMIT 100];
                if(Addresses.size() > 0) {
                    for(ERP7__Address__c Address : Addresses){
                        if(Address.ERP7__Is_Billing_Address__c == true){
                            billadd = Address.Id;
                            break;
                        }
                    }
                    for(ERP7__Address__c Address : Addresses){
                        if(Address.ERP7__Is_Shipping_Address__c == true){
                            deliveryadd = Address.Id;
                            break;
                        }
                    }
                }
            }
        }
        allPOwrap allpo = new allPOwrap();
        List<ERP7__Purchase_Line_Items__c> purchaseLine = (List<ERP7__Purchase_Line_Items__c>) JSON.deserialize(polist, List<ERP7__Purchase_Line_Items__c>.class);
        set<Id> prodIds = new set<Id>();
        set<Id> appvenIds = new set<Id>();
        set<Id> venIds = new set<Id>();
        for(ERP7__Purchase_Line_Items__c poli : purchaseLine) { 
            appvenIds.add(poli.ERP7__Approved_Vendor__c);  
            prodIds.add(poli.ERP7__Product__c);
            string name = poli.Name;
            if(name.Length() >= 80){ name = name.substring(0, 79);
                system.debug('name : '+name);
                system.debug('name length changed: '+name.length());
            }
            poli.Name = name;
            system.debug(' poli.Name: '+ poli.Name);
        }
        List<Product2> prodlist = [Select Id,Name,ERP7__Vendor_product_Name__c,ERP7__Purchase_From_Approved_Vendor__c from Product2 where Id In :prodIds];
        Map<Id,Product2> prodVenName = new Map<Id,Product2>();
        for(Product2 pro : prodlist){
            prodVenName.put(pro.Id,pro);
        }
        List<ERP7__Approved_Vendor__c> apvenlist = [Select Id,Name,ERP7__Vendor__c from ERP7__Approved_Vendor__c where Id In : appvenIds];
        Map<Id,Id> appVenMap = new Map<Id,Id>();
        for(ERP7__Purchase_Line_Items__c pollis : purchaseLine){ 
            venIds.add(pollis.ERP7__Vendor__c); 
        }
        Map<Id,List<ERP7__Purchase_Line_Items__c>> venPOliMap = new Map<Id,List<ERP7__Purchase_Line_Items__c>>();
        for(ERP7__Purchase_Line_Items__c pollis : purchaseLine){
            //if(appVenMap.containsKey(pollis.ERP7__Vendor__c)){
            if(venPOliMap.containsKey(pollis.ERP7__Vendor__c))
            {   
                venPOliMap.get(pollis.ERP7__Vendor__c).add(pollis);
                
            }
            else{
                venPOliMap.put(pollis.ERP7__Vendor__c,new List<ERP7__Purchase_Line_Items__c>{pollis});
            }
            //}
            
        }
        
        Map<Id,Account> acclist = new Map<Id,Account>([Select Id,Name from Account where Id In:venIds]);
        List<Contact> conlist = [Select Id,Name,AccountId from Contact where AccountId In: venIds];
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        for(Contact cc :conlist) conMap.put(cc.AccountId,cc);
        Integer i= 1;
        List<POpolis> POpoliList = new List<POpolis>();
        system.debug('venPOliMap.keySet()-->'+venPOliMap.keySet());
        for(Id iid :venPOliMap.keySet()){
            
            POpolis popolinew = new POpolis();
            ERP7__PO__c newPO = new ERP7__PO__c();
            newPO.ERP7__Active__c = true;
            newPO.ERP7__Ready_To_Receive__c = false;
            newPO.ERP7__Channel__c = chanId;
            newPO.ERP7__Distribution_Channel__c = DCId;
            newPO.ERP7__Organisation__c = acc.Id;
            newPO.ERP7__Organisation__r = new Account(Id = acc.Id,Name=acc.Name);
            if(billadd != null && billadd != '') newPO.ERP7__Invoice_Address__c = billadd;
            if(deliveryadd != null && deliveryadd != '') newPO.ERP7__Delivery_Address__c = deliveryadd;
            newPO.ERP7__Status__c = 'Draft';
            newPO.Name = 'Purchase Order -'+i;
            //newPO.ERP7__Barcode__c = generateRandomString(12);
            newPO.ERP7__Vendor__c = iid;
            newPO.ERP7__Expected_Date__c = system.today();
            newPO.ERP7__EmployeeRequester__c = empId;
            if(conMap.containsKey(newPO.ERP7__Vendor__c)) newPO.ERP7__Vendor_Contact__c = conMap.get(newPO.ERP7__Vendor__c).Id;
            if(acclist.containsKey(newPO.ERP7__Vendor__c)) newPO.ERP7__Vendor__r = new Account(Id = acclist.get(newPO.ERP7__Vendor__c).Id,Name=acclist.get(newPO.ERP7__Vendor__c).Name); 
            popolinew.PO = newPO;
            popolinew.POLIs = venPOliMap.get(iid);
            /* for(ERP7__Purchase_Line_Items__c newpp : popolinew.POLIs){
for(Product2 prod : prodlist){
if(newpp.ERP7__Product__c == prod.Id){
newpp.ERP7__Vendor_product_Name__c = prod.ERP7__Vendor_product_Name__c;
newpp.Name = prod.Name;
}
}
} */
            POpoliList.add(popolinew);
            i=i+1;
            
        }
        system.debug('POpoliList-->'+POpoliList.size());
        if(POpoliList.size() > 0 ) POpoliList[0].expanded = true;
        allpo.POlist = POpoliList;
        
        return allpo;
    }
    @AuraEnabled
    public static List<String> getStatus(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = PO__c.Status__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    @AuraEnabled
    public static poliWrap getApprovedvendor(String ProductId,String vendorId){
        poliWrap poliwrp = new poliWrap();
        List<ERP7__Approved_Vendor__c> approvedVen = new List<ERP7__Approved_Vendor__c>();
        try{
            String temp = ProductId.replace('"','');
            if(String.isNotEmpty(ProductId) && String.isNotEmpty(vendorId)){
                approvedVen = [Select Id,Name,ERP7__Cost_Card__c,ERP7__Product__c,ERP7__Vendor__c,ERP7__Lead_Time__c,ERP7__Vendor__r.Name,ERP7__Vendor__r.Id,ERP7__Cost_Card__r.Name,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Cost_Card__r.ERP7__Quantity__c From ERP7__Approved_Vendor__c where ERP7__Product__c = :temp And ERP7__Vendor__c=:vendorId];
                /*'approvedVen : '+approvedVen.size());*/
                
            }
        }catch(Exception e){
            /*'Error at getvendor : '+e.getLineNumber()+'  Message : '+e.getMessage());*/
        }
        poliwrp.appven = approvedVen;
        return poliwrp;
        
    }
    @AuraEnabled
    public static multipoWarp savePOs(String POpolis){
        
        multipoWarp mulWrap = new multipoWarp();
        
        List<ERP7__PO__c> PO2insert = new List<ERP7__PO__c>();
        List<ERP7__Purchase_Line_Items__c> poli2insert = new List<ERP7__Purchase_Line_Items__c> ();
        list<Id> poIds = new list<Id>();
        // try{
        allPOwrap POlistss = (allPOwrap) JSON.deserialize(POpolis, allPOwrap.class);
        List<POpolis> polis = new List<POpolis>();
        polis = POlistss.POlist;
        Map<ERP7__PO__c,List<ERP7__Purchase_Line_Items__c>> POPOLIS2insert = new Map<ERP7__PO__c,List<ERP7__Purchase_Line_Items__c>>();
        for(POpolis ppps : polis){
            POPOLIS2insert.put(ppps.PO,ppps.POLIs);
            //PO2insert.add(ppps.PO);
        }
        /*PO2insert : '+PO2insert.size());*/
        set<Id> ordIds = new set<Id>();
        if(POPOLIS2insert.keySet().size() > 0){
            PO2insert.addAll(POPOLIS2insert.keySet());
            system.debug('PO2insert : '+PO2insert.size());
            system.debug('PO2insert : '+PO2insert);
            for(ERP7__PO__c po : PO2insert){
                if(po.ERP7__Order__c != null) ordIds.add(po.ERP7__Order__c);
            }
            if(Schema.sObjectType.ERP7__PO__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.isUpdateable()){system.debug('PO2 inserted'); upsert PO2insert; }  else{ /*not allowed to upsert*/}              
            
            List<OrderItem> ordList = new List<OrderItem>();
            if(ordIds.size() > 0){ordList = [Select Id,OrderId,Product2Id,Product2.QuantityUnitOfMeasure from OrderItem where OrderId In : ordIds];
            }
            Integer j=0;
            for(List<ERP7__Purchase_Line_Items__c> allpolis : POPOLIS2insert.Values()){
                for(ERP7__Purchase_Line_Items__c poli : allpolis){ 
                    poli.ERP7__Match_Type__c = 'Three-Way';
                    poli.ERP7__Active__c = true;
                    system.debug('j : '+j);
                    poli.ERP7__Purchase_Orders__c = PO2insert[j].Id;
                    for(OrderItem ord : ordList){
                        if(poli.ERP7__Product__c != null && ord.Product2Id == poli.ERP7__Product__c){
                            system.debug('value match');
                            poli.ERP7__Order_Product__c = ord.Id;
                            poli.ERP7__Order__c = ord.OrderId;
                        }
                    }
                    
                }
                poli2insert.addAll(allpolis);
                j++;
            }
            system.debug('poli2insert : '+poli2insert.size());
            if(poli2insert.size() > 0){
                if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Purchase_Line_Items__c.isUpdateable()){
                    upsert poli2insert; 
                }
                else{/*user is not allowed to upsert*/}
                
                
                
            } 
            
            for(ERP7__PO__c pos:PO2insert) mulWrap.insertedPos.add(pos);
            for(ERP7__PO__c po:PO2insert) mulWrap.poIds.add(po.Id);
        }
        
        
        //   }
        // catch(Exception e){ system.debug(' Something went wrong: '+e.getMessage()+' line number : '+e.getLineNumber());  }
        return mulWrap;
        
    }
    
    
    public class multipoWarp{
        @AuraEnabled public List<ERP7__PO__c> insertedPos {get;set;}
        @AuraEnabled public List<Id> poIds {get;set;}
        public multipoWarp(){
            insertedPos = new List<ERP7__PO__c>();
            poIds = new List<Id>();
        }
    }
    
    @AuraEnabled
    public static void AnalyticalAccounts(String AA, List<Id> PId){
        try{
            system.debug('AA-->'+AA);
            system.debug('PId-->'+PId);
            
            String demstring = AA.replace('[[', '[');
            demstring = demstring.replace(']]', ']');
            demstring = demstring.replace('],[', ',');
            demstring = demstring.replace('[null,', '');
            demstring = demstring.replace('null,', '');
            demstring = demstring.replace(',,', '');
            demstring = demstring.replace(',]', ']');
            system.debug('demstring-->'+demstring);
            //demstring = AA.replace('[[', '[');
            //demstring = demstring.replace(']]', ']');
            system.debug('demstring2-->'+demstring);
            //String demstring = AA;
            
            List<ERP7__Dimension__c> demList1 = (List<ERP7__Dimension__c>) JSON.deserialize(demstring, List<ERP7__Dimension__c>.class);
            system.debug('demList-->'+demList1);
            List<Purchase_Line_Items__c> poli = [select Id, Name, ERP7__Organisation__c, ERP7__Sort_Order__c,ERP7__Account_Category__c,ERP7__Chart_of_Account__c from Purchase_Line_Items__c where ERP7__Purchase_Orders__c IN: PId];
            Map<Decimal, Purchase_Line_Items__c > poliMap = new Map<Decimal, Purchase_Line_Items__c >();
            for(Purchase_Line_Items__c pol : poli){
                poliMap.put(pol.ERP7__Sort_Order__c, pol);
            }
            system.debug('poliMap-->'+poliMap);
            if(demList1.size()>0){
                system.debug('demList1');
                for(ERP7__Dimension__c dem1 : demList1){
                    system.debug('Sort Order-->'+dem1.ERP7__Sort_Order__c);
                    if(dem1.ERP7__Sort_Order__c != null){
                        if(poliMap.containsKey(dem1.ERP7__Sort_Order__c)){
                            dem1.ERP7__Purchase_Line_Items__c = poliMap.get(dem1.ERP7__Sort_Order__c).Id;
                            dem1.Name = poliMap.get(dem1.ERP7__Sort_Order__c).Name;
                            dem1.ERP7__Active__c = true;
                            if(poli[0].ERP7__Organisation__c != null) dem1.ERP7__Organisation__c = poli[0].ERP7__Organisation__c;
                            if(poliMap.get(dem1.ERP7__Sort_Order__c).ERP7__Account_Category__c != null) dem1.ERP7__Account_Category__c = poliMap.get(dem1.ERP7__Sort_Order__c).ERP7__Account_Category__c;
                            if(poliMap.get(dem1.ERP7__Sort_Order__c).ERP7__Chart_of_Account__c != null) dem1.ERP7__Chart_of_Account__c = poliMap.get(dem1.ERP7__Sort_Order__c).ERP7__Chart_of_Account__c;
                        }
                    }
                }
                system.debug('demList1-->'+demList1);
                upsert demList1;
            }
        }catch(Exception e){ system.debug('Exception~>'+e.getStackTraceString()+' at' +e.getLineNumber()); }
    }
    
    @AuraEnabled
    public static String uploadFile(String parent, String fileName, String base64Data, String contentType) { 
        system.debug('uploadFile-->');
        try{  base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');  Attachment a = new Attachment();  a.parentId = parent; a.Body = EncodingUtil.base64Decode(base64Data);  a.Name = fileName; a.ContentType = contentType; if(Schema.SObjectType.Attachment.isCreateable()){ system.debug('Attachment-->'+a); insert a; } else{ } return 'Success'; } catch(Exception e) { system.debug('Error:'+e.getMessage()+' Line:'+e.getLineNumber()); String exc=Json.serialize(e); return exc; }
        
    }
    @AuraEnabled
    public static void deleteDimension(String Demid) { 
        system.debug('Demid'+Demid);
        try{ ERP7__Dimension__c dim =[select Id, Name from ERP7__Dimension__c where Id=:Demid];
            delete dim;}catch(Exception e) { system.debug('Error:'+e.getMessage()+' Line:'+e.getLineNumber());}
        
    }
    
    @AuraEnabled
    public static Decimal checkforTax(String addId, String AccId){
        Decimal taxRate = 0.00;
        if(AccId!=''){
            Account acc = new Account();
            acc = [select Id, Name, ERP7__Account_Profile__c from Account where Id=:AccId];
            if(acc.ERP7__Account_Profile__c !=null){
                //ECPQ__Profiling__c profile = new ECPQ__Profiling__c();
                //profile  = [Select Id,Name,ECPQ__Channel__c,ECPQ__Price_Book__c,ECPQ__Tax_Sourcing_Rules__c from ECPQ__Profiling__c where Id =:acc.ERP7__Account_Profile__c Limit 1];
                List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();
                Date todayDate = system.today();
                profileTax=[Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where ERP7__Account_Profile__c =:acc.ERP7__Account_Profile__c AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Tax_Rate__c != Null AND ERP7__Product__c = Null AND ERP7__Active__c=true Order By ERP7__Province__c DESC];
                ERP7__Address__c quoteBillToAdd= new ERP7__Address__c();
                quoteBillToAdd = [Select Id,Name,ERP7__Active__c,Erp7__City__c,Erp7__Country__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where Id =:addId AND Erp7__Active__c=true Limit 1];
                String TaxPostalCode = '';
                String TaxCity = '';
                String TaxProvince = '';
                String TaxCountry = '';
                if(quoteBillToAdd != Null){
                    if(quoteBillToAdd.ERP7__Postal_Code__c != Null && quoteBillToAdd.ERP7__Postal_Code__c != '') TaxPostalCode = quoteBillToAdd.ERP7__Postal_Code__c;
                    if(quoteBillToAdd.ERP7__City__c != Null && quoteBillToAdd.ERP7__City__c != '') TaxCity = quoteBillToAdd.ERP7__City__c;
                    if(quoteBillToAdd.ERP7__State__c != Null && quoteBillToAdd.ERP7__State__c != '') TaxProvince = quoteBillToAdd.ERP7__State__c;
                    if(quoteBillToAdd.ERP7__Country__c != Null && quoteBillToAdd.ERP7__Country__c != '') TaxCountry = quoteBillToAdd.ERP7__Country__c;
                    system.debug('TaxPostalCode-->'+TaxPostalCode);
                    system.debug('TaxCity-->'+TaxCity);
                    system.debug('TaxProvince-->'+TaxProvince);
                    system.debug('TaxCountry-->'+TaxCountry);
                    
                    for(ERP7__Tax__c profileTax1 : profileTax){
                        system.debug('TaxPostalCode-->'+TaxPostalCode);
                        if(TaxPostalCode != null && TaxPostalCode != '' && TaxPostalCode == profileTax1.ERP7__Postal_Code__c){
                            taxRate = profileTax1.ERP7__Tax_Rate__c;
                        }
                        else if(TaxCity != null && TaxCity != '' && TaxCity == profileTax1.ERP7__City__c && (profileTax1.ERP7__Postal_Code__c == null || profileTax1.ERP7__Postal_Code__c == '')){
                            taxRate = profileTax1.ERP7__Tax_Rate__c;
                        }
                        else if(TaxProvince != null && TaxProvince != '' && TaxProvince == profileTax1.ERP7__Province__c  && (profileTax1.ERP7__Postal_Code__c == null || profileTax1.ERP7__Postal_Code__c == '') && (profileTax1.ERP7__City__c == null || profileTax1.ERP7__City__c == '')){
                            taxRate = profileTax1.ERP7__Tax_Rate__c;
                        }
                        else if(TaxCountry != null && TaxCountry != '' && TaxCountry == profileTax1.ERP7__Country__c  && (profileTax1.ERP7__Postal_Code__c == null || profileTax1.ERP7__Postal_Code__c == '') && (profileTax1.ERP7__City__c == null || profileTax1.ERP7__City__c == '') && (profileTax1.ERP7__Province__c == null || profileTax1.ERP7__Province__c == '')){
                            taxRate = profileTax1.ERP7__Tax_Rate__c;
                        }
                    }
                    system.debug('taxRate set here1~>'+taxRate);
                    return taxRate;
                }else{
                    system.debug('taxRate set here2~>'+taxRate);
                    return taxRate;
                }
            }else{
                system.debug('taxRate set here3~>'+taxRate);
                return taxRate; 
            }
        }else{
            system.debug('taxRate set here4~>'+taxRate);
            return taxRate;
        }
    }
     
    @AuraEnabled
    public static AddressWrap getVendorAddress(List<Id> venList) {
        AddressWrap wrap1 = new AddressWrap();
        List<ERP7__Address__c> newaddress= [Select Id, Name, ERP7__Customer__c from ERP7__Address__c where ERP7__Customer__c=:venList and ERP7__Active__c=true order by CreatedDate ASC];
        System.debug('newaddress' + newaddress);
        wrap1.addresses=newaddress ;
        List<Decimal> alltaxes = new List<Decimal>();
        
        for(ERP7__Address__c add: newaddress){
        Decimal tax1 = 00.0;
        tax1 = checkforTax(add.Id, add.ERP7__Customer__c);
        alltaxes.add(tax1);
        }
         wrap1.taxes=alltaxes;
        return wrap1;
    }
     public class AddressWrap{
        @AuraEnabled public List<ERP7__Address__c> addresses                           {get;set;}
        @AuraEnabled public List<Decimal> taxes                                    {get; set;}
     
        public AddressWrap(){
            addresses = new List<ERP7__Address__c>();
            taxes = new List<Decimal>();  
    }
    }
    
    @AuraEnabled
    public static AttachmentAndDimensionWrapper getAllExistDem(String pol) {
        AttachmentAndDimensionWrapper resultWrapper = new AttachmentAndDimensionWrapper();
        System.debug('pol' + pol);
        
        List<ERP7__Purchase_Line_Items__c> poli = [SELECT Id, Name, ERP7__Purchase_Orders__c FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c = :pol];
        List<Id> poliIds = new List<Id>();
        
        for (ERP7__Purchase_Line_Items__c polItem : poli) { poliIds.add(polItem.Id);
        }
        
        List<ERP7__Dimension__c> dim = [SELECT Id, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Allocation_Percentage__c, ERP7__Allocation_Amount__c, ERP7__Purchase_Line_Items__c FROM ERP7__Dimension__c WHERE ERP7__Purchase_Line_Items__c IN :poliIds];
        
        List<Attachment> notesAndAttachments = [SELECT Id, Name, ParentId, CreatedDate, CreatedById FROM Attachment WHERE ParentId =:pol];
        resultWrapper.dimensions = dim;
        resultWrapper.attachments = notesAndAttachments;
        
        return resultWrapper;
    }
    
    @AuraEnabled
    public static List<Attachment> DeleteAttachment(String attachId,String parentId){ try{ List<Attachment> Attachments = new List<Attachment>(); Attachment attach2del = new Attachment(); if(String.isNotEmpty(attachId)){ attach2del = [Select Id, Name, ParentId from Attachment where Id =: attachId AND ParentId != null]; if(attach2del.Id != null){ delete attach2del; } } if(String.isNotEmpty(parentId)) Attachments = [Select Id, Name, ParentId from Attachment where ParentId =:parentId Order By CreatedDate ASC]; return Attachments; } catch(Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } }
    
    public class AttachmentAndDimensionWrapper {
        @AuraEnabled public List<Attachment> attachments { get; set; }
        @AuraEnabled public List<ERP7__Dimension__c> dimensions { get; set; }
        
        public AttachmentAndDimensionWrapper() {
            attachments = new List<Attachment>();
            dimensions = new List<ERP7__Dimension__c>();
        }
    }
    
    @AuraEnabled
    public static allPOwrap getAllExistPO(String polist){
        allPOwrap allpo = new allPOwrap();
        List<String> polis =  (List<String>) JSON.deserialize(polist, List<String>.class);
        if(polis.size() > 0){
            boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            List<ERP7__PO__c> pos = new List<ERP7__PO__c>(); 
            if(IsmultiCurrencyEnabled){pos=Database.Query('Select Id, CurrencyIsoCode, Name, ERP7__Vendor__c,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name,ERP7__Expected_Date__c,ERP7__Status__c,ERP7__EmployeeRequester__c,ERP7__Vendor_Address__c,ERP7__Vendor_Address__r.Name,ERP7__Organisation__c,ERP7__Organisation__r.Name,ERP7__Invoice_Address__c,ERP7__Invoice_Address__r.Name,ERP7__Delivery_Address__c,ERP7__Delivery_Address__r.Name,ERP7__Description__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Vendor__r.Name from ERP7__PO__c where Id In:polis');
            }else{
                pos = [Select Id,Name, ERP7__Vendor__c,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name,ERP7__Expected_Date__c,ERP7__Status__c,ERP7__EmployeeRequester__c,ERP7__Vendor_Address__c,ERP7__Vendor_Address__r.Name,ERP7__Organisation__c,ERP7__Organisation__r.Name,ERP7__Invoice_Address__c,ERP7__Invoice_Address__r.Name,ERP7__Delivery_Address__c,ERP7__Delivery_Address__r.Name,ERP7__Description__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Vendor__r.Name from ERP7__PO__c where Id In:polis];
            }
            //List<ERP7__PO__c> pos = [Select Id,Name, ERP7__Vendor__c,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name,ERP7__Expected_Date__c,ERP7__Status__c,ERP7__EmployeeRequester__c,ERP7__Vendor_Address__c,ERP7__Vendor_Address__r.Name,ERP7__Organisation__c,ERP7__Organisation__r.Name,ERP7__Invoice_Address__c,ERP7__Invoice_Address__r.Name,ERP7__Delivery_Address__c,ERP7__Delivery_Address__r.Name,ERP7__Description__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Vendor__r.Name from ERP7__PO__c where Id In:polis];
            List<ERP7__Purchase_Line_Items__c> polilst = [Select Id,Name,ERP7__Description__c,ERP7__Purchase_Orders__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Vendor_product_Name__c,ERP7__Cost_Card__c,ERP7__Cost_Card__r.Name,ERP7__Quantity__c,ERP7__Unit_Price__c,ERP7__Total_Price__c,ERP7__Active__c,ERP7__Sort_Order__c,ERP7__Account_Category__c,ERP7__Chart_of_Account__c,ERP7__Tax_Rate__c,ERP7__Tax__c,ERP7__Total_Tax__c from ERP7__Purchase_Line_Items__c where ERP7__Purchase_Orders__c In: polis];
            Map<Id,List<ERP7__Purchase_Line_Items__c>> popoliMAp = new Map<Id,List<ERP7__Purchase_Line_Items__c>>();
            List<POpolis> popoli= new List<POpolis>();
            
            for(ERP7__Purchase_Line_Items__c po : polilst){
                if(popoliMAp.containsKey(po.ERP7__Purchase_Orders__c)) popoliMAp.get(po.ERP7__Purchase_Orders__c).add(po);
                else popoliMAp.put(po.ERP7__Purchase_Orders__c, new List<ERP7__Purchase_Line_Items__c>{po});
            }
            for(ERP7__PO__c newpo :pos){
                
                if(popoliMAp.containsKey(newpo.Id)){
                    POpolis popolinew = new POpolis();
                    popolinew.PO = newpo;
                    popolinew.POLIs = popoliMAp.get(newpo.Id);
                    popoli.add(popolinew);
                }
                
                
            }
            if(popoli.size() > 0 ) popoli[0].expanded = true;
            allpo.POlist = popoli;
            
            return allpo;
        } return null;
    }
    @AuraEnabled
    public static List<ERP7__PO__c> updatePOs(string POs){
        List<ERP7__PO__c> polis =  (List<ERP7__PO__c>) JSON.deserialize(POs, List<ERP7__PO__c>.class);
        for(ERP7__PO__c po:polis){
            po.ERP7__Status__c = 'Submitted for Approval'; 
        }
        update polis;
        return polis;
    }
    @AuraEnabled
    public static List<ERP7__PO__c> showPO(string POlist){
        List<ERP7__PO__c> polis =  (List<ERP7__PO__c>) JSON.deserialize(POlist, List<ERP7__PO__c>.class);
        set<Id> poids = new set<Id>();
        set<Id> ordids = new set<Id>();
        for(ERP7__PO__c ppio : polis)  poids.add(ppio.Id);
        List<ERP7__PO__c> returnPO = [Select Id,Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,toLabel(ERP7__Status__c),ERP7__Amount__c,ERP7__Total_Amount__c,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Delivery_Address__c,ERP7__Delivery_Address__r.Name,ERP7__Total_Quantity__c,ERP7__Organisation__c from ERP7__PO__c where Id in :poids];
        /*poids = new set<Id>();
system.debug('poids : '+poids.size());
for(ERP7__PO__c pp : returnPO){
if(pp.ERP7__Order__c != null){
poids.add(pp.Id); 
ordids.add(pp.ERP7__Order__c);
}
}
system.debug('poids : '+poids.size());
system.debug('ordids : '+ordids.size());
if(poids.size() > 0 && ordids.size() > 0){
List<OrderItem> ordList = [Select Id,OrderId,Product2Id,Product2.QuantityUnitOfMeasure from OrderItem where OrderId In : ordids];
List<ERP7__Purchase_Line_Items__c> Prlines = [Select Id,Name,ERP7__Product__c,ERP7__Active__c,ERP7__Order_Product__c ,ERP7__Match_Type__c ,ERP7__Unit_of_Measure__c ,ERP7__Order__c, ERP7__Organisation__c from ERP7__Purchase_Line_Items__c where ERP7__Purchase_Orders__c In : poids];
for(ERP7__Purchase_Line_Items__c pr : Prlines){
for(OrderItem ord : ordList){
if(ord.Product2Id == pr.ERP7__Product__c){
system.debug('value match');
pr.ERP7__Active__c = true;
pr.ERP7__Order_Product__c = ord.Id;
pr.ERP7__Match_Type__c = 'Three-Way';
pr.ERP7__Order__c = ord.OrderId;
}
}
}
update Prlines;
}*/
        return returnPO;
    }
    public class poliWrap{
        @AuraEnabled public List<polilistWrap> poli                           {get;set;}
        @AuraEnabled public List<ERP7__Approved_Vendor__c> appven             {get;set;}
        @AuraEnabled public String channel                                    {get; set;}
        @AuraEnabled public ERP7__Distribution_Channel__c distributionChannel {get; set;}
        @AuraEnabled public Boolean editUnitPrice                              {get; set;}
        @AuraEnabled public Boolean enableReceive                              {get; set;}
        @AuraEnabled public Boolean showUpload                                 {get; set;}
        @AuraEnabled public Boolean AllocationAccess                           {get; set;}
        @AuraEnabled public String errorMSg                                    {get; set;}
        @AuraEnabled public Boolean submitApproval                             {get; set;}
        @AuraEnabled public Boolean AllolateProcess                             {get; set;}
        @AuraEnabled public Boolean addressRequired                             {get; set;}
        public poliWrap(){
            poli = new List<polilistWrap>();
            appven = new List<ERP7__Approved_Vendor__c>();
            channel = ''; errorMSg = '';
            distributionChannel = new ERP7__Distribution_Channel__c();
            editUnitPrice = false; enableReceive = false; showUpload = false; AllocationAccess = false; submitApproval=false; AllolateProcess=false; addressRequired = false;
        }
        
    }
    public class polilistWrap{
        @AuraEnabled public ERP7__Purchase_Line_Items__c pli  {get;set;}
        @AuraEnabled public List<ERP7__Approved_Vendor__c> appvendr             {get;set;}
        @AuraEnabled public Boolean isSelected {get;set;}
        @AuraEnabled public Boolean purchaseAppVendor {get;set;}
        @AuraEnabled public Decimal Demand                                  {get; set;}
        @AuraEnabled public Decimal Stock                                   {get; set;}
        @AuraEnabled public Decimal AwaitingStocks                          {get; set;}
        @AuraEnabled public String  ccqry {get;set;}
        @AuraEnabled public Boolean customProduct {get;set;}
        public polilistWrap(){
            pli = new ERP7__Purchase_Line_Items__c();
            isSelected = purchaseAppVendor = false;
            Demand = 0.0;Stock = 0.0; AwaitingStocks = 0.0;
            appvendr = new List<ERP7__Approved_Vendor__c>();
            ccqry = ''; customProduct = false;
        }
    }
    public class allPOwrap{
        @AuraEnabled public List<POpolis> POlist {get;set;}
        public allPOwrap(){
            POlist = new List<POpolis>();
        }
    }
    public class POpolis{
        @AuraEnabled public Boolean expanded                          {get;set;}
        @AuraEnabled public ERP7__PO__c PO                            {get;set;}
        @AuraEnabled public List<ERP7__Purchase_Line_Items__c> POLIs  {get;set;}
        @AuraEnabled public List<Attachmentwrap> AttachmentList  {get;set;}
        
        //@AuraEnabled public Id FileId  {get;set;}
        public POpolis(){
            PO = new   ERP7__PO__c();
            POLIs = new  List<ERP7__Purchase_Line_Items__c>();
            AttachmentList = new List<Attachmentwrap>();
        }
    }
    
    public class Attachmentwrap{
        @AuraEnabled public String FileItem                         {get;set;}
        public Attachmentwrap(){
            FileItem = '';
        }
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
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    @AuraEnabled
    public static String getOrgCurrencies(String OrgId){
        String OrgIsocode = '';
        System.debug('OrgId' + OrgId);
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        System.debug('IsmultiCurrencyEnabled' + IsmultiCurrencyEnabled);
        if(IsmultiCurrencyEnabled){   
            List <Account> accounts = Database.Query('SELECT Id,Name,CurrencyIsoCode FROM Account where Id = :OrgId limit 1');    
            if(accounts.size() > 0) OrgIsocode = String.valueOf(accounts[0].get('CurrencyIsoCode'));
            else OrgIsocode = '';
            System.debug('OrgIsocode' + OrgIsocode);
        }
        return OrgIsocode;
    }
    
    @AuraEnabled
    public static multiCurrencyWrap getCurrencies( ){
        multiCurrencyWrap mc = new multiCurrencyWrap();
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(IsmultiCurrencyEnabled){  
            String PoIsoCode = '';
            List <ERP7__PO__c> pos = Database.Query('SELECT Id, Name, CurrencyIsoCode FROM ERP7__PO__c limit 1');    
            if(pos.size() > 0) POIsocode = String.valueOf(pos[0].get('CurrencyIsoCode'));
            else POIsocode = '';
            options.add(new SelectOptions(String.valueOf(pos[0].get('CurrencyIsoCode')),String.valueOf(pos[0].get('CurrencyIsoCode'))));
            List <sObject> currencies = Database.Query('SELECT IsoCode FROM CurrencyType');    
            for(sObject a : currencies){   
                if(POIsocode!=String.valueof(a.get('IsoCode'))) options.add(new SelectOptions(String.valueof(a.get('IsoCode')),String.valueof(a.get('IsoCode')))); 
            }
            mc.currencyList = options;
            mc.isMulticurrency = IsmultiCurrencyEnabled;
        }
        return mc;  
    }
    
    public class multiCurrencyWrap{
        @AuraEnabled
        public Boolean isMulticurrency {get;set;}
        @AuraEnabled
        public List<selectOptions> currencyList {get;set;}
        public multiCurrencyWrap(){
            isMulticurrency = false;
            currencyList = new List<selectOptions>();
        }
    } 
    @AuraEnabled
    public static Product2 fetchProductDesc(String productId){  
        if(String.isNotEmpty(productId)) return [Select Id, Name, ERP7__Vendor_Supplier_Description__c,ERP7__Vendor_product_Name__c, ERP7__Version__c, ERP7__Inventory_Account__c, ERP7__Project__c, ERP7__Project__r.ERP7__Account_Category__c from Product2 where Id =: productId Limit 1];
        else return null;
    }
    @AuraEnabled
    public static List<String> getCategoryList(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = ERP7__Dimension__c.ERP7__Account_Category__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        public selectOptions(String lab, string val) {
            label = lab; value = val; 
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab; value = val; selected = sel;
        }
    }
    //from here
     @AuraEnabled 
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        System.debug('ObjectName : '+ObjectName);
        System.debug('parentField: '+parentField);
        System.debug('childField: '+childField);
        Map<String,List<SelectOptions>> pickListMap = new Map<String,List<SelectOptions>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        List<SelectOptions> controllingValues = new List<SelectOptions>();
        
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
            pickListMap.put(ple.getLabel(), new List<SelectOptions>());
            controllingValues.add(new SelectOptions(ple.label,ple.value));
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    if(controllingValues.get(i).label != System.label.NonePicklistType){
                        pickListMap.get(controllingValues.get(i).label).add(new SelectOptions(plew.label,plew.value));
                    }
                }
            }
        }
        
        if(controllingValues.size() > 0){
            controllingValues.add(0,new SelectOptions(System.label.NonePicklistType,''));
        }
        
        pw.controllingValues = controllingValues;
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
        public class PicklistWrapper{
        @AuraEnabled
        public Map<String, List<SelectOptions>> pickListMap;
        @AuraEnabled
        public List<SelectOptions> controllingValues;
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
    
        private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
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
        public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
        //For add products
    @AuraEnabled
    public static WrapLst getProducts(String venId,String searchString,string searchFamily,String DCId,Boolean search,string subFamily){
        WrapLst wrap = new WrapLst();
        if(search == null) search = false;
        wrap.globalSearch = search;
        List<wrapper> wraplist = new List<wrapper>();
        List<Product2> prodList = new List<Product2>();
        system.debug('searchFamily : '+searchFamily);
        system.debug('subFamily : '+subFamily);
        if(searchString != null && searchString != '') searchString = '%'+searchString+'%';
        system.debug('searchString : '+searchString);
        string query = '';
        if((venId == null || venId == '') && (searchFamily == null || searchFamily == '') && (searchString == null || searchString == '') && (subFamily == null || subFamily == '')){
            system.debug('1 if last  ');    
            //wrap.Msg = Label.No_products_avaialble_to_view_based_on_selected_vendor;
            wrap.globalSearch = true;
            prodList = [Select Id,Name,Description,ProductCode,ERP7__Vendor_product_Name__c,ERP7__Purchase_From_Approved_Vendor__c,ERP7__Purchase_Lead_Time_days__c, (SELECT Id, Name,ERP7__Vendor__c, ERP7__Product__c,ERP7__Lead_Time__c FROM ERP7__Approved_Vendors__r  where ERP7__Status__c='Approved' AND ERP7__Default__c= true)  from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true limit 100];
        }
        else{
            
            //Added by Arshad 12 Oct to get Approved vendor products on first page 
            set<Id> alreadyAddedAppVendProds = new set<Id>();
            if(venId != null && venId != ''){
                system.debug('vendor~>'+venId);
                List<ERP7__Approved_Vendor__c> apprVendors = new List<ERP7__Approved_Vendor__c>();
                
                string status = 'Approved';
                query = 'Select Id,Name,ERP7__Product__c from ERP7__Approved_Vendor__c where ERP7__Product__c != null AND ERP7__Product__r.ERP7__Issue_Purchase_Order__c = true AND ERP7__Status__c =: status AND ERP7__Vendor__c =:venId '; 
                query+= ' Order By Name Limit 9000 ';
                
                apprVendors = Database.query(query);
                if(apprVendors.size() > 0){
                    for(ERP7__Approved_Vendor__c appVen:apprVendors){
                        alreadyAddedAppVendProds.add(appVen.ERP7__Product__c);
                        if(alreadyAddedAppVendProds.size() >= 100) break;
                    }
                }
                
                system.debug('alreadyAddedAppVendProds : '+alreadyAddedAppVendProds.size());
            }
            
            query = 'Select Id,Name,Description,ProductCode,ERP7__Vendor_product_Name__c,ERP7__Purchase_Lead_Time_days__c,ERP7__Purchase_From_Approved_Vendor__c, (SELECT Id, Name,ERP7__Vendor__c, ERP7__Product__c,ERP7__Lead_Time__c FROM ERP7__Approved_Vendors__r  where ERP7__Status__c=\'Approved\' AND ERP7__Default__c= true) from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true';
            if(alreadyAddedAppVendProds.size() > 0 && ((searchFamily == null || searchFamily == '') && (searchString == null || searchString == '') && (subFamily == null || subFamily == ''))){
                query+= ' AND Id IN :alreadyAddedAppVendProds ';
            }else{
                if(searchString != null && searchString != '') query+= ' and (Name LIKE :searchString or ProductCode LIKE :searchString or StockKeepingUnit LIKE :searchString or ERP7__Vendor_product_Name__c LIKE :searchString) ';
                if(searchFamily != null && searchFamily != '') query+= ' and Family = :searchFamily ';
                if(subFamily != null && subFamily != '') query+= ' and ERP7__Product_Service_Family__c = :subFamily ';
            }
            query+= ' Order By Name Limit 100 ';
            prodList = Database.query(query);
            system.debug('prodList bfr: '+prodList.size());
            
            if(prodList.size() > 0 && venId != null && venId != ''){
                set<Id> appVendProds = new set<Id>();
                for(Product2 pr : prodList){
                    if(pr.ERP7__Purchase_From_Approved_Vendor__c) appVendProds.add(pr.Id);
                }
                system.debug('appVendProds bfr: '+appVendProds.size());
                if(appVendProds.size() > 0){
                    Map<Id,ERP7__Approved_Vendor__c> ProdVendors = new Map<Id,ERP7__Approved_Vendor__c>();
                    string status = 'Approved';
                    query = 'Select Id,Name,ERP7__Product__c,ERP7__Lead_Time__c from ERP7__Approved_Vendor__c where ERP7__Product__c !=null and ERP7__Product__r.ERP7__Issue_Purchase_Order__c = true and ERP7__Status__c = :status and ERP7__Product__c IN:appVendProds and ERP7__Vendor__c = :venId';
                    query+= ' Order By Name Limit 100';
                    List<ERP7__Approved_Vendor__c> approvedVendors = Database.query(query);
                    system.debug('approvedVendors : '+approvedVendors.size());
                    if(approvedVendors.size() > 0){
                        for(ERP7__Approved_Vendor__c appVen:approvedVendors){
                            if(appVen.ERP7__Product__c != null) ProdVendors.put(appVen.ERP7__Product__c,appVen);
                        }
                        system.debug('ProdVendors : '+ProdVendors.size());
                        Integer index = 0;
                        while(index < prodList.size()){
                            if(prodList[index].ERP7__Purchase_From_Approved_Vendor__c && !ProdVendors.containsKey(prodList[index].Id)) {
                                system.debug('if');
                                prodList.remove(index);
                            }
                            else index++;
                        } 
                        system.debug('prodList after: '+prodList.size());
                    }
                    if(approvedVendors.size() == 0){
                        Integer index = 0;
                        while(index < prodList.size()){
                            if(prodList[index].ERP7__Purchase_From_Approved_Vendor__c) {
                                system.debug('if 2');
                                prodList.remove(index);
                            }
                            else index++;
                        }
                    }
                }
            }
            
        }
        
        List<ERP7__Cost_Card__c> costCards = new List<ERP7__Cost_Card__c>();
        
        system.debug('prodList 3: '+prodList.size());
        
        //Added by Arshad 03 Aug 2023
        if(prodList.size() > 0 && String.isNotEmpty(venId)){
            costCards = [SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c, ERP7__Supplier__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Cost__c, ERP7__Quantity__c, ERP7__Vendor_Part_Number__c, ERP7__Default__c 
                         FROM ERP7__Cost_Card__c WHERE ERP7__Product__c != null AND ERP7__Supplier__c != null AND ERP7__Product__c IN :prodList And ERP7__Supplier__c =:venId  And ERP7__End_Date__c >=: system.today() 
                         And ERP7__Cost__c > 0 And ERP7__Quantity__c > 0 And ERP7__Default__c = true Order by CreatedDate Desc Limit 1];
        }
        Map<String, ERP7__Cost_Card__c> defProdCostCartMap = new Map<String, ERP7__Cost_Card__c>();
        for(ERP7__Cost_Card__c cc: costCards){
            if(!defProdCostCartMap.containsKey(cc.ERP7__Product__c)){
                defProdCostCartMap.put(cc.ERP7__Product__c,cc);
            }
        }
        
        set<Id> siteIds = new set<Id>();
        set<Id> productIds = new set<Id>();
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(DCId != null && DCId != '' && prodList.size() > 0){
            
            List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                                  where Id=:DCId and ERP7__Active__c=true];                
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
            for(Product2 pr:prodList) productIds.add(pr.Id);
            
            if(productIds.size() > 0) {
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,ERP7__No_of_Items_Requested__c,ERP7__Number_of_Items_Awaiting_in_Stock__c,
                                                ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                                Where product__c In: productIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds 
                                                 and  (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
            }
            
        }
        
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        Map<String, Decimal> demandView = new Map<String, Decimal>();
        Map<String, Decimal> AwaitingstockView = new Map<String, Decimal>();
        
        for(Id prId:productIds){
            Decimal stock = 0;
            Decimal demand = 0;
            Decimal Awaitingstock=0;
            for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                if(prId == inven.product__c){
                    stock += inven.ERP7__Number_of_Item_In_Stock__c;
                    demand += inven.ERP7__No_of_Items_Requested__c;
                    Awaitingstock += inven.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                }
            }
            stockView.put(prId,stock);
            demandView.put(prId,demand);
            AwaitingstockView.put(prId,Awaitingstock);
        }
        
        for(Product2 pr:prodList){
            wrapper wrapNew = new wrapper();
            wrapNew.prod = pr;
            wrapNew.VendorPartNumber = pr.ERP7__Vendor_product_Name__c;
            if(stockView.containsKey(pr.Id)) wrapNew.stock = stockView.get(pr.Id);
            else wrapNew.stock = 0;
            if(demandView.containsKey(pr.Id)) wrapNew.demand = demandView.get(pr.Id).SetScale(3);
            else wrapNew.demand = 0;
            if(AwaitingstockView.containsKey(pr.Id)) wrapNew.AwaitStock = AwaitingstockView.get(pr.Id);
            else wrapNew.demand = 0;
            wrapNew.selCostCardId = '';
            wrapNew.selectedCostCard = new ERP7__Cost_Card__c();
            if(defProdCostCartMap.containsKey(pr.Id)){
                wrapNew.selCostCardId = defProdCostCartMap.get(pr.Id).Id;
                wrapNew.selectedCostCard = defProdCostCartMap.get(pr.Id);
            }
            wraplist.add(wrapNew);
        }
        
        system.debug('wraplist : '+wraplist.size());
        if(wraplist.size() > 0){
            wrap.wrapList = wraplist;
        } 
        else {
            wrap.Msg='No products avaialble to view';
        }
        return wrap;
    }
        public class wrapper{
        @AuraEnabled public Product2 prod{get;set;}
       @AuraEnabled public String  VendorPartNumber {get;set;}
        @AuraEnabled public Decimal stock {get;set;}
        @AuraEnabled public Decimal demand {get;set;}
        @AuraEnabled public Decimal AwaitStock {get;set;}
        @AuraEnabled public String selCostCardId {get;set;}
        @AuraEnabled public ERP7__Cost_Card__c selectedCostCard {get;set;}
    }
    
    public class WrapLst{
        @AuraEnabled public List<wrapper> wrapList {get;set;}
        @AuraEnabled public String Msg {get;set;}
        @AuraEnabled public Boolean globalSearch {get;set;}
    }
        @AuraEnabled
    public static CCWrapper fetchPrice2(String ccId){ 
        if(String.isNotEmpty(ccId)){ 
            CCWrapper ccWrapper=new CCWrapper();
            ccWrapper.multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            ERP7__Cost_Card__c cc = new ERP7__Cost_Card__c(); 
            
            if(ccWrapper.multiCurrencyEnabled){
                cc=Database.Query('SELECT Id,CurrencyIsoCode,ERP7__Supplier__c, Name,ERP7__Cost__c, ERP7__Product__c, ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Quantity__c,ERP7__Vendor_Part_Number__c FROM ERP7__Cost_Card__c WHERE Id=:ccId');
            }else{
                cc=[SELECT Id,Name,ERP7__Cost__c, ERP7__Product__c,ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c, ERP7__Quantity__c,ERP7__Vendor_Part_Number__c,ERP7__Supplier__c FROM ERP7__Cost_Card__c WHERE Id=:ccId];
            }
            
            if(cc != null){
                Id prodId = cc.ERP7__Product__c;
                Id SupplierId = cc.ERP7__Supplier__c;
                if(prodId != null && SupplierId != null){
                    List<ERP7__Approved_Vendor__c> app = [Select Id,Name,ERP7__Lead_Time__c from ERP7__Approved_Vendor__c where  ERP7__Product__c=: cc.ERP7__Product__c and ERP7__Vendor__c=:SupplierId and ERP7__Lead_Time__c != null and ERP7__Cost_Card__c = :ccId Limit 1];
                    if(app.size() > 0) ccWrapper.LeadTime = app[0].ERP7__Lead_Time__c;
                }
                else if(prodId != null && prodId != ''){
                    if(cc.ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c != null) ccWrapper.LeadTime = cc.ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c;
                    else ccWrapper.LeadTime = 0;
                }
            }
            
            if(cc.ERP7__Cost__c == null) cc.ERP7__Cost__c=0.00; 
            if(cc.ERP7__Quantity__c == null) cc.ERP7__Quantity__c=0;  
            
            ccWrapper.costcard = cc;
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ 
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
            }
            system.debug('FC : '+FC);
            if(FC != null){
                system.debug('FC unit price: '+FC.ERP7__Enable_Unit_price_edit_in_PO__c);
                ccWrapper.editUnitPrice = FC.ERP7__Enable_Unit_price_edit_in_PO__c;
            }
            
            return ccWrapper;//.ERP7__Cost__c;
        } else return null;
        
        // return 20;                                           
    }
        public class CCWrapper{
        @AuraEnabled public ERP7__Cost_Card__c costcard                                                         { get; set; }
        @AuraEnabled public Boolean multiCurrencyEnabled                                                  { get; set; }
        @AuraEnabled public Boolean editUnitPrice                                                  { get; set; }
        @AuraEnabled public Decimal LeadTime                                                       { get; set; }
        public CCWrapper(){
            costcard=new ERP7__Cost_Card__c();
            multiCurrencyEnabled=false;
            editUnitPrice = false;
            LeadTime = 0;
        }
    }//till here
    
}