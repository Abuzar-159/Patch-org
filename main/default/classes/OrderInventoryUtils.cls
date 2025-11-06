Public with sharing Class OrderInventoryUtils { 
    
    /* 
Method to create Product Purchase Line Items for insert and undelete of Line Items. 
*/  
    public static void createProductPurchaseLineItems(set<Id> lineItemIds){
        System.debug('inside createProductPurchaseLineItems');
        System.debug('PreventRecursiveLedgerEntry.SOLI_AllocateStock:'+PreventRecursiveLedgerEntry.SOLI_AllocateStock);
        if(PreventRecursiveLedgerEntry.SOLI_AllocateStock){
            PreventRecursiveLedgerEntry.SOLI_AllocateStock = false;
            system.debug('createProductPurchaseLineItems enter lineItemIds==>'+lineItemIds);
            List<ERP7__Manufacturing_Order__c> SOMOs = new List<ERP7__Manufacturing_Order__c>();
            List<ERP7__PO__c> SOPOs = new List<ERP7__PO__c>();
            //Set<Id> lineItemIds = new Set<Id>();
            Set<Id> salepointIds = new Set<Id>();
            Set<Id> productIds = new Set<Id>();
            Set<Id> assetIds = new Set<Id>();
            Set<Id> allSalepointSiteIds = new Set<Id>();
            Map<Id, Set<Id>> salepointSites = new Map<Id, Set<Id>>();
            Map<Id, Set<Inventory_Stock__c>> productSites = new Map<Id, Set<Inventory_Stock__c>>();
            Map<Id, List<Stock_Outward_Line_Item__c>> existingSoliAndSOWMap = new Map<Id, List<Stock_Outward_Line_Item__c>>();
            List<Stock_Outward_Line_Item__c> existingSOWList = new List<Stock_Outward_Line_Item__c>();
            
            List<Sales_Order_Line_Item__c> currentLineItems;
            
            if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isAccessible()){
                
                UtilClass.FlsCheck(new String[]{'ERP7__Base_Price__c','ERP7__Discount_Amount__c','ERP7__Invoice__c','ERP7__Price_Product__c','ERP7__Total_Price__c','ERP7__VAT_Amount__c', 'ERP7__Inventory_Tracked__c','ERP7__Product__c','ERP7__Quantity__c','ERP7__Sales_Order__c','ERP7__Loyalty_Points__c','ERP7__Loyalty_Program__c','ERP7__Checked_Out_Process__c','ERP7__Commission__c','ERP7__Commission_Rate_Card__c','ERP7__Status__c'},'ERP7__Sales_Order_Line_Item__c');
                UtilClass.FlsCheck(new String[]{'ERP7__Sub_Total__c','ERP7__Total_Discount__c','ERP7__Total_Due__c','ERP7__Total_Tax_Amount__c','ERP7__Channel__c','ERP7__Order_Status__c','ERP7__Is_Back_Order__c'},'ERP7__Sales_Order__c');
                UtilClass.FlsCheck(new String[]{'ERP7__SKU__c','ERP7__Track_Inventory__c'},'ERP7__Product__c');
                if(!Schema.sObjectType.ERP7__Commission_Rate_Card__c.fields.Commission_Plan__c.isAccessible()) return ;
                
                currentLineItems = [Select Id, Name, Base_Price__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c,  Inventory_Tracked__c, ERP7__Organisation__c,
                                    Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Loyalty_Points__c, Loyalty_Program__c, Checked_Out_Process__c, Is_Back_Order__c, Is_Pre_Order__c,
                                    ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c,Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c, Commission__c, Commission_Rate_Card__c,
                                    Commission_Rate_Card__r.Commission_Plan__c, Status__c, Product__r.Track_Inventory__c, Sales_Order__r.Channel__c, Sales_Order__r.Order_Status__c, Sales_Order__r.Is_Back_Order__c, Sales_Order__r.Is_Pre_Order__c,
                                    ERP7__Asset__c, Asset__r.Serial__c, ERP7__Serial__c, ERP7__Version__c, Product__r.ERP7__Serialise__c, Product__r.ERP7__Lot_Tracked__c
                                    From Sales_Order_Line_Item__c 
                                    Where Id In: lineItemIds];
            }
            Boolean AllocateOrderSpecificStocks = false;
            list<String> SolidIds=new list<String>(); Set<Id> backOrderProdIds=new Set<Id>();
            for(Sales_Order_Line_Item__c lineItem : currentLineItems){
                SolidIds.add(lineItem.Id); 
                if(lineItem.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c) AllocateOrderSpecificStocks = true;
                if(lineItem.Is_Back_Order__c) backOrderProdIds.add(lineItem.Product__c);
            }
            system.debug('AllocateOrderSpecificStocks : '+AllocateOrderSpecificStocks);
            existingSOWList=[SELECT Id, Name, ERP7__Sales_Order__c, Sales_Order_Line_Item__c,ERP7__Quantity__c
                             FROM Stock_Outward_Line_Item__c WHERE Sales_Order_Line_Item__c IN:SolidIds AND ERP7__Logistic_Line_Item__c!=NULL AND ERP7__Quantity__c>0];
            
            /*OderInv existingSOWList==>'+existingSOWList.size()+'  ,existingSOWList==>'+existingSOWList*/
            Set<Id> orderIds= new Set<Id>();
            for(Sales_Order_Line_Item__c lineItem : currentLineItems ){ 
                orderIds.add(lineItem.ERP7__Sales_Order__c);
                if(lineItem.Product__c != Null){
                    if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible()) productIds.add(lineItem.Product__c);
                } 
                if(lineItem.asset__c != Null){
                    if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.asset__c.isAccessible()) assetIds.add(lineItem.asset__c);
                }
                if(lineItem.Sales_Order__r.Channel__c != Null){
                    if(Schema.sObjectType.Sales_Order__c.isAccessible() && Schema.sObjectType.Sales_Order__c.fields.Channel__c.isAccessible() && Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible()) salepointIds.add(lineItem.Sales_Order__r.Channel__c);
                }
                if(lineItem.Id != Null){
                    if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible() && Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()){
                        list<Stock_Outward_Line_Item__c> swList=new list<Stock_Outward_Line_Item__c>();   
                        for(Stock_Outward_Line_Item__c sw : existingSOWList ){ if(lineItem.Id==sw.Sales_Order_Line_Item__c) swList.add(sw); } 
                        existingSoliAndSOWMap.put(lineItem.Id, swList);   
                    }
                    
                } 
                
            } 
            /*OderInv existingSoliAndSOWMap==>'+existingSoliAndSOWMap.size()+'  ,existingSoliAndSOWMap==>'+existingSoliAndSOWMap*/
            
            List<Distribution_Channel__c> DistributionChannels;
            if(Schema.sObjectType.Distribution_Channel__c.isAccessible()){
                UtilClass.FlsCheck(new String[]{'ERP7__Active__c','ERP7__Channel__c','ERP7__Site__c','ERP7__Organisation__c','ERP7__Organisation_Business_Unit__c','ERP7__Channel__c','ERP7__Site__c','ERP7__Priority__c'},'ERP7__Distribution_Channel__c');
                DistributionChannels = [Select Id, Name, Active__c,  Channel__c, Site__c, Priority__c
                                        From Distribution_Channel__c
                                        Where Channel__c In : salepointIds And
                                        Active__c = true AND ( ERP7__Priority__c != '')
                                        Order By ERP7__Priority__c ASC NULLS LAST];
                
            }
            for(Id sId : salepointIds){
                Set<Id> siteIds = new Set<Id>();
                for(Distribution_Channel__c DC : DistributionChannels){
                    if(sId == DC.Channel__c) { 
                        if(Schema.sObjectType.Distribution_Channel__c.fields.Site__c.isAccessible()) siteIds.add(DC.Site__c);
                        if(Schema.sObjectType.Distribution_Channel__c.fields.Site__c.isAccessible()) allSalepointSiteIds.add(DC.Site__c);
                    }
                }
                salepointSites.put(sId,siteIds);
            }
            
            //Creating Inventory for product which don't have any inventory.
            List<Id> allSalepointSiteIdsList=new List<Id>();  allSalepointSiteIdsList.addAll(allSalepointSiteIds);
            if(backOrderProdIds.size() > 0){                 List<Inventory_Stock__c> invforBackOrders=[Select Id,Name,ERP7__Product__c from Inventory_Stock__c where ERP7__Product__c In:backOrderProdIds];                Map<Id,Id> prodIdWithInv=new Map<Id,Id>(); for(Inventory_Stock__c inv:invforBackOrders) prodIdWithInv.put(inv.ERP7__Product__c,inv.Id); List<Inventory_Stock__c> inventoryList=new List<Inventory_Stock__c>();                if(prodIdWithInv.size()>0){for(Sales_Order_Line_Item__c ordItm:currentLineItems){ if(prodIdWithInv.get(ordItm.Product__c)==null){ Inventory_Stock__c inv=new Inventory_Stock__c(); inv.Name=ordItm.Product__r.Name; inv.ERP7__Product__c=ordItm.Product__c; inv.ERP7__Warehouse__c=allSalepointSiteIdsList[0]; inv.ERP7__Active__c=true;  inv.ERP7__Checked_In_Date__c=System.today(); inventoryList.add(inv);  }  } if(inventoryList.size() > 0) insert inventoryList;}            }            if(AllocateOrderSpecificStocks){                SOMOs = [Select Id,Name from ERP7__Manufacturing_Order__c where ERP7__Sales_Order_Line_Item__c IN:lineItemIds and ERP7__Product__c IN:productIds];                SOPOs = [Select Id,Name from ERP7__PO__c where ERP7__Sales_Order__c IN:orderIds and ERP7__Ready_To_Receive__c =:true];            }
            
            
            List<Inventory_Stock__c> WarehouseItemInventoryStocks = new List<Inventory_Stock__c>();
                if(AllocateOrderSpecificStocks){                    if(SOMOs.size() > 0 || SOPOs.size() > 0){                        set<Id> MoIds = new set<Id>();                        set<Id> PoIds = new set<Id>();                        set<Id> InvIds = new set<Id>();                        for(ERP7__Manufacturing_Order__c MO : SOMOs) MoIds.add(MO.Id);                        for(ERP7__PO__c PO : SOPOs) PoIds.add(PO.Id);                        system.debug('MoIds : '+MoIds);                        List<ERP7__Stock_Inward_Line_Item__c> stinlist = [Select Id,Name,ERP7__Site_ProductService_InventoryStock__c from ERP7__Stock_Inward_Line_Item__c where ERP7__Active__c = true and ERP7__Scrap__c = false and (ERP7__Purchase_Orders__c IN:PoIds or ERP7__Manufacturing_Order__c IN: MoIds) and ERP7__Quantity__c > 0 and ERP7__Status__c != 'Awaiting Stock'];                        for(ERP7__Stock_Inward_Line_Item__c sin : stinlist) InvIds.add(sin.ERP7__Site_ProductService_InventoryStock__c);                        system.debug('InvIds : '+InvIds);                                                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c,  Warehouse__c, Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,                                                        Product__c,  Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,                                                         Number_of_Items_Dispatched__c, No_of_Items_Sold__c, Checked_In_Date__c                                                         From Inventory_Stock__c                                                        Where (Product__c In: productIds Or Fixed_Asset__c In: assetIds) And                                                        Active__c = true And                                                        Warehouse__c In: allSalepointSiteIds                                                        and (ERP7__Manufacturing_Order__c In:MoIds or Id IN:InvIds)                                                        and Name != 'Awaiting Stock'                                                        Order By Checked_In_Date__c ASC];                        system.debug('WarehouseItemInventoryStocks : '+WarehouseItemInventoryStocks.size());                    }                    else{                        system.debug('No MOs or POs associated with the order ');                    }                }              
            else{
                    WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c,  Warehouse__c, Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c,
                                                    Product__c,  Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, 
                                                    Number_of_Items_Dispatched__c, No_of_Items_Sold__c, Checked_In_Date__c 
                                                    From Inventory_Stock__c
                                                    Where (Product__c In: productIds Or Fixed_Asset__c In: assetIds) And
                                                    Active__c = true And
                                                    Warehouse__c In: allSalepointSiteIds
                                                    //And Number_of_Item_In_Stock__c > 0
                                                    Order By Checked_In_Date__c ASC];
                }
            
            List<Stock_Outward_Line_Item__c> pplis2Insert = new List<Stock_Outward_Line_Item__c>(); 
            List<Id> SerialStockIds = new List<Id>();
            if(WarehouseItemInventoryStocks.size() > 0){
                for(Id pId : productIds){
                    Set<Inventory_Stock__c> sites = new Set<Inventory_Stock__c>();
                    for(Inventory_Stock__c WIIS : WarehouseItemInventoryStocks){ if(pId == WIIS.Product__c) sites.add(WIIS); }
                    productSites.put(pId,sites);
                }
                
                for(Id pId : assetIds){ 
                    Set<Inventory_Stock__c> sites = new Set<Inventory_Stock__c>(); 
                    for(Inventory_Stock__c WIIS : WarehouseItemInventoryStocks){ if(pId == WIIS.Fixed_Asset__c) sites.add(WIIS); } 
                    productSites.put(pId,sites); 
                }
                 
                for(Sales_Order_Line_Item__c lineItem : currentLineItems ){  
                    boolean succeed = false;
                    Set<Id> currSalepointSites=new Set<Id>();
                    currSalepointSites = salepointSites.get(lineItem.Sales_Order__r.Channel__c);
                    Set<Inventory_Stock__c> currTempProductSites;
                    if(lineItem.Product__c != Null) currTempProductSites = productSites.get(lineItem.Product__c);
                    if(lineItem.Asset__c != Null) currTempProductSites = productSites.get(lineItem.Asset__c);
                    Set<Inventory_Stock__c> currProductSites = new Set<Inventory_Stock__c>();
                    
                    List<Inventory_Stock__c> currTempProductSitess = new List<Inventory_Stock__c>();
                    if(currTempProductSites != null && currTempProductSites.size() >0) currTempProductSitess.addAll(currTempProductSites);
                    List<Inventory_Stock__c> currProductSitess = new List<Inventory_Stock__c>();
                    
                    if(lineItem.Checked_Out_Process__c == 'LIFO'){                        for(Integer i=currTempProductSitess.size(); i>0; i--){ currProductSitess.add(currTempProductSitess[i-1]); }                        currProductSites.addAll(currProductSitess);                    } else currProductSites = currTempProductSites;                    
                    
                     Decimal quantity = (lineItem.ERP7__Quantity__c != Null)? lineItem.ERP7__Quantity__c : 0;
                Decimal SWQuantity = 0; 
                
                if(existingSoliAndSOWMap.containskey(lineItem.id)){
                    for(Stock_Outward_Line_Item__c sto : existingSoliAndSOWMap.get(lineItem.id)){ if(sto.ERP7__Quantity__c!=null) SWQuantity+=sto.ERP7__Quantity__c;  /*OrderInventoryUtils insert for enter qt'+sto.ERP7__Quantity__c*/ } 
                }
                if(SWQuantity!=null && SWQuantity!=0) quantity=quantity-SWQuantity;
                 
                if(lineItem.Inventory_Tracked__c == true && !lineItem.Is_Back_Order__c && !lineItem.Is_Pre_Order__c){
                    for(Id currSalepointSite : currSalepointSites){
                        for(Inventory_Stock__c currProductSite : currProductSites){
                            if(currSalepointSite == currProductSite.Warehouse__c && quantity > 0  && (lineItem.ERP7__Version__c == null || (lineItem.ERP7__Version__c != null && lineItem.ERP7__Version__c == currProductSite.ERP7__Version__c))){
                                
                                if(currProductSite.Number_of_Item_In_Stock__c > 0 && currProductSite.Number_of_Item_In_Stock__c >= quantity){
                                    Integer loopquantity = 1;
                                    if(lineItem.Product__r.ERP7__Serialise__c){ SerialStockIds.add(currProductSite.Id); loopquantity = Integer.valueof(quantity); }
                                    for(Integer i=0; i<loopquantity; i++){
                                        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) PPLI.Active__c = true;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.ERP7__Sales_Order__c = lineItem.Sales_Order__c;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) PPLI.Product__c = lineItem.Product__c;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isUpdateable()) PPLI.Fixed_Asset__c = lineItem.Asset__c;
                                        if(lineItem.Asset__c != Null && lineItem.Asset__r.Serial__c != Null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isUpdateable()) PPLI.Serial__c = lineItem.Asset__r.Serial__c;
                                        //if(currProductSite.Serial__c != Null) PPLI.Serial__c = currProductSite.Serial__c;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){ if(lineItem.Product__r.ERP7__Serialise__c) PPLI.Quantity__c = 1; else PPLI.Quantity__c = quantity; }
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.Sales_Order__c = lineItem.Sales_Order__c;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) PPLI.Sales_Order_Line_Item__c = lineItem.Id;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) PPLI.Site_Product_Service_Inventory_Stock__c = currProductSite.Id;
                                        //if(currProductSite.ERP7__Serial__c != null ) PPLI.ERP7__Serial__c = currProductSite.ERP7__Serial__c;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()) PPLI.ERP7__Material_Batch_Lot__c = currProductSite.ERP7__Batch_Lot__c;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()) PPLI.ERP7__Version__c = currProductSite.ERP7__Version__c;
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){ if(lineItem.Sales_Order__r.Order_Status__c == 'Entered')  PPLI.Status__c = 'Reserved'; else if(lineItem.Sales_Order__r.Order_Status__c == 'Closed')  PPLI.Status__c = 'Committed';  }
                                        pplis2Insert.add(PPLI);
                                    }
                                    succeed = true;
                                    break;
                                }
                                else if(currProductSite.Number_of_Item_In_Stock__c > 0) {                                    Integer loopquantity = 1;                                    if(lineItem.Product__r.ERP7__Serialise__c){ SerialStockIds.add(currProductSite.Id);   loopquantity = Integer.valueof(currProductSite.Number_of_Item_In_Stock__c);                                                                              }                                    for(Integer i=0; i<loopquantity; i++){                                        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) PPLI.Active__c = true;                                         if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.ERP7__Sales_Order__c = lineItem.Sales_Order__c;                                         if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) PPLI.Product__c = lineItem.Product__c;                                         if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isUpdateable()) PPLI.Fixed_Asset__c = lineItem.Asset__c;                                        if(lineItem.Asset__c != Null && lineItem.Asset__r.Serial__c != Null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isUpdateable()) PPLI.Serial__c = lineItem.Asset__r.Serial__c;                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){ if(lineItem.Product__r.ERP7__Serialise__c) PPLI.Quantity__c = 1;else PPLI.Quantity__c = currProductSite.Number_of_Item_In_Stock__c; }                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) PPLI.Sales_Order_Line_Item__c = lineItem.Id;                                         if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) PPLI.Site_Product_Service_Inventory_Stock__c = currProductSite.Id;                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()) PPLI.ERP7__Material_Batch_Lot__c = currProductSite.ERP7__Batch_Lot__c;                                          if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()) PPLI.ERP7__Version__c = currProductSite.ERP7__Version__c;                                         if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.Sales_Order__c = lineItem.Sales_Order__c;                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){ if(lineItem.Sales_Order__r.Order_Status__c == 'Entered') PPLI.Status__c = 'Reserved'; else if(lineItem.Sales_Order__r.Order_Status__c == 'Closed') PPLI.Status__c = 'Committed'; }                                        pplis2Insert.add(PPLI);                                        quantity -= currProductSite.Number_of_Item_In_Stock__c;                                    }                                }                              
                                /*'OrderInventoryUtils pplis2Insert 1==>'+pplis2Insert.size()+'  ,pplis2Insert==>'+pplis2Insert*/
                            }
                        }  
                        if(succeed){ break; } 
                    }
                } 
                
                else if(lineItem.Inventory_Tracked__c == true && (lineItem.Is_Back_Order__c || lineItem.Is_Pre_Order__c) && lineItem.Sales_Order__r.Order_Status__c == 'Entered'){                    for(Id currSalepointSite : currSalepointSites){                        List<Inventory_Stock__c> Stocks;                        if(currProductSites.size() > 0) {Stocks = new list<Inventory_Stock__c>();Stocks.addAll(currProductSites); Inventory_Stock__c Stock = Stocks[0];                                                         if(lineItem.ERP7__Version__c != null) for(Inventory_Stock__c IS : currProductSites){ if(lineItem.ERP7__Version__c == IS.ERP7__Version__c){ Stock = IS; break; } }                                                                                                                  Integer loopquantity = 1;                                                         if(lineItem.Product__r.ERP7__Serialise__c){ SerialStockIds.add(Stock.Id); loopquantity = Integer.valueof(quantity);                                                                                                   }                                                         for(Integer i=0; i<loopquantity; i++){                                                             Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();                                                              if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.ERP7__Sales_Order__c = lineItem.Sales_Order__c;                                                              if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) PPLI.Site_Product_Service_Inventory_Stock__c = Stock.Id;                                                             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()) PPLI.ERP7__Version__c = Stock.ERP7__Version__c;                                                              if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) PPLI.Active__c = true;                                                                   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.Sales_Order__c = lineItem.Sales_Order__c;                                                                  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) PPLI.Product__c = lineItem.Product__c;                                                              if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isUpdateable()) PPLI.Fixed_Asset__c = lineItem.Asset__c;                                                             if(lineItem.Asset__c != Null && lineItem.Asset__r.Serial__c != Null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isUpdateable()) PPLI.Serial__c = lineItem.Asset__r.Serial__c;                                                             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){ if(lineItem.Product__r.ERP7__Serialise__c) PPLI.Quantity__c = 1;  else PPLI.Quantity__c = quantity; }                                                             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) PPLI.Sales_Order_Line_Item__c = lineItem.Id;                                                              if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) PPLI.Status__c = 'Requested';                                                              pplis2Insert.add(PPLI);                                                         }                                                        }                        succeed = true;  break;                    }                 }         
                } 
            }
            
            if(pplis2Insert.size() > 0){
                List<ERP7__Serial_Number__c> serials2Update = new List<ERP7__Serial_Number__c>();
                if(SerialStockIds.size() > 0){                    List< ERP7__Stock_Inward_Line_Item__c > SILIS =  [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Available__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,                                                                      Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c                                                                      From ERP7__Stock_Inward_Line_Item__c                                                                       Where ERP7__Serial__c != Null And                                                                       ERP7__Serial__r.ERP7__Available__c = true And                                                                       ERP7__Serial__r.ERP7__Expired__c = false And                                                                      Active__c = true And                                                                        ERP7__Site_ProductService_InventoryStock__c In :SerialStockIds Limit 1000];                    List<Id> SerialIds = new List<Id>();                    /*295 pplis2Insert : ' +pplis2Insert.size() */                    for(Stock_Outward_Line_Item__c pplil : pplis2Insert){                        if(SerialStockIds.contains(pplil.Site_Product_Service_Inventory_Stock__c)){                            for(ERP7__Stock_Inward_Line_Item__c silil : SILIS){                                if(pplil.Site_Product_Service_Inventory_Stock__c == silil.ERP7__Site_ProductService_InventoryStock__c){                                    if(!SerialIds.contains(silil.ERP7__Serial__c)) {                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isUpdateable()) pplil.ERP7__Serial__c = silil.ERP7__Serial__c;                                        SerialIds.add(silil.ERP7__Serial__c);                                        break;                                    }                                }                            }                        }                    }                                        for(Id SerialId : SerialIds) {                        ERP7__Serial_Number__c SN = new ERP7__Serial_Number__c(Id = SerialId);                        if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Available__c.isUpdateable()) SN.ERP7__Available__c = false;                        serials2Update.add(SN);                    }                }               
                if(Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()) { PreventRecursiveLedgerEntry.proceedDeleteZeroReserverSTOLI = true; PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true; upsert pplis2Insert; } else{ /*not allowed to upsert*/}
                if(serials2Update.size() > 0 && Schema.sObjectType.ERP7__Serial_Number__c.isUpdateable()) { update serials2Update; } else{ /*not allowed to update*/}
                
            }
        }
    }
    
    /* 
Method to update Product Purchase Line Items for update of Line Items.
*/    
    
    public static void updateProductPurchaseLineItems(set<Id> lineItemIds){
        System.debug('inside updateProductPurchaseLineItems');
        if(test.isRunningTest()) PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        if(PreventRecursiveLedgerEntry.SOLI_AllocateStock){
            PreventRecursiveLedgerEntry.SOLI_AllocateStock = false;
            Set<Id> salepointIds = new Set<Id>(); Set<Id> productIds = new Set<Id>();
            Set<Id> allSalepointSiteIds = new Set<Id>(); Map<Id, Set<Id>> salepointSites = new Map<Id, Set<Id>>();
            Map<Id, Set<Inventory_Stock__c>> productSites = new Map<Id, Set<Inventory_Stock__c>>();       
            List<Sales_Order_Line_Item__c> currentLineItems;
            Map<Id, List<Stock_Outward_Line_Item__c>> existingSoliAndSOWMap = new Map<Id, List<Stock_Outward_Line_Item__c>>();
            list<Stock_Outward_Line_Item__c> existingSOWList = new List<Stock_Outward_Line_Item__c>(); 
            
            if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()){
                UtilClass.FlsCheck(new String[]{'ERP7__Base_Price__c','ERP7__Discount_Amount__c','ERP7__Invoice__c','ERP7__Price_Product__c','ERP7__Total_Price__c','ERP7__VAT_Amount__c','ERP7__Organisation__c','ERP7__Organisation_Business_Unit__c','ERP7__Inventory_Tracked__c','ERP7__Product__c','ERP7__Quantity__c','ERP7__Sales_Order__c','ERP7__Loyalty_Points__c','ERP7__Loyalty_Program__c','ERP7__Checked_Out_Process__c','ERP7__Commission__c','ERP7__Commission_Rate_Card__c','ERP7__Status__c'},'ERP7__Sales_Order_Line_Item__c');
                UtilClass.FlsCheck(new String[]{'ERP7__Sub_Total__c','ERP7__Total_Discount__c','ERP7__Total_Due__c','ERP7__Total_Tax_Amount__c','ERP7__Channel__c','ERP7__Order_Status__c','ERP7__Is_Back_Order__c'},'ERP7__Sales_Order__c');
                UtilClass.FlsCheck(new String[]{'ERP7__SKU__c','ERP7__Track_Inventory__c'},'ERP7__Product__c');
                if(!Schema.sObjectType.ERP7__Commission_Rate_Card__c.fields.Commission_Plan__c.isAccessible()) return ;
                
                currentLineItems = [Select Id, Name, Base_Price__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c,Organisation__c, Organisation_Business_Unit__c, Inventory_Tracked__c, Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Loyalty_Points__c, Loyalty_Program__c, Checked_Out_Process__c, Is_Pre_Order__c, Is_Back_Order__c,   Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c, Commission__c, Commission_Rate_Card__c,   Commission_Rate_Card__r.Commission_Plan__c, Status__c, Product__r.Track_Inventory__c, Sales_Order__r.Channel__c, Sales_Order__r.Order_Status__c, Sales_Order__r.Is_Back_Order__c, ERP7__Version__c From Sales_Order_Line_Item__c Where Id In: lineItemIds];
            }
            
            list<String> SolidIds=new list<String>();
            for(Sales_Order_Line_Item__c lineItem : currentLineItems) SolidIds.add(lineItem.Id);
            
            existingSOWList=[SELECT Id, Name, ERP7__Sales_Order__c, Sales_Order_Line_Item__c, ERP7__Logistic_Line_Item__c, ERP7__Quantity__c FROM Stock_Outward_Line_Item__c WHERE Sales_Order_Line_Item__c IN:SolidIds AND ((ERP7__Logistic_Line_Item__c!=NULL AND ERP7__Status__c='Reserved') OR ERP7__Status__c='Requested') AND ERP7__Quantity__c>0]; //AND ERP7__Status__c='Committed'
            
            
            /* List<Stock_Outward_Line_Item__c> pplis2delete;
Map<Id, Id> lineStock = new Map<Id, Id>();
if(Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()){
UtilClass.FlsCheck(new String[]{'ERP7__Active__c','ERP7__Product__c','ERP7__Quantity__c','ERP7__Sales_Order_Line_Item__c','ERP7__Site_Product_Service_Inventory_Stock__c'},'ERP7__Stock_Outward_Line_Item__c');

pplis2delete = [Select Id, Name, Active__c, Product__c, Quantity__c, Sales_Order_Line_Item__c, Site_Product_Service_Inventory_Stock__c, ERP7__Picked_Date__c
From Stock_Outward_Line_Item__c
Where Sales_Order_Line_Item__c In : lineItemIds And
ERP7__Picked_Date__c = Null And
Active__c = true];
}*/
            
            // if(pplis2delete.size() > 0) if (Schema.sObjectType.Stock_Outward_Line_Item__c.isDeletable()) DMLManager.deleteAsUser(pplis2delete);
            
            for(Sales_Order_Line_Item__c lineItem : currentLineItems ){  
                if(lineItem.Product__c != Null){ if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible()) productIds.add(lineItem.Product__c);
                                               } 
                if(lineItem.Sales_Order__r.Channel__c != Null){  if(Schema.sObjectType.Sales_Order__c.isAccessible() && Schema.sObjectType.Sales_Order__c.fields.Channel__c.isAccessible() && Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible()) salepointIds.add(lineItem.Sales_Order__r.Channel__c);
                                                              } 
                if(lineItem.Id != Null){if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible() && Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()){
                    list<Stock_Outward_Line_Item__c> swList=new list<Stock_Outward_Line_Item__c>();   
                    for(Stock_Outward_Line_Item__c sw : existingSOWList){    if(lineItem.Id==sw.Sales_Order_Line_Item__c) swList.add(sw);
                                                                        } 
                    existingSoliAndSOWMap.put(lineItem.Id, swList);   
                }
                                       }
                
            } 
            
            
            List<Distribution_Channel__c> DistributionChannels;
            if(Schema.sObjectType.Distribution_Channel__c.isAccessible()){
                UtilClass.FlsCheck(new String[]{'ERP7__Active__c','ERP7__Channel__c','ERP7__Site__c','ERP7__Priority__cActive__c','ERP7__Organisation__c','ERP7__Organisation_Business_Unit__c','ERP7__Channel__c','ERP7__Site__c','ERP7__Priority__c'},'ERP7__Distribution_Channel__c');
                DistributionChannels = [Select Id, Name, Active__c, Channel__c, Site__c, Priority__c  From Distribution_Channel__c  Where Channel__c In : salepointIds And  Active__c = true Order By Priority__c ASC];
            }
            for(Id sId : salepointIds){  Set<Id> siteIds = new Set<Id>();
                                       for(Distribution_Channel__c DC : DistributionChannels){ if(sId == DC.Channel__c) { if(Schema.sObjectType.Distribution_Channel__c.fields.Site__c.isAccessible()) siteIds.add(DC.Site__c);
                                                                                                                         if(Schema.sObjectType.Distribution_Channel__c.fields.Site__c.isAccessible()) allSalepointSiteIds.add(DC.Site__c);
                                                                                                                        }
                                                                                             }
                                       salepointSites.put(sId,siteIds);
                                      }
            
            List<Inventory_Stock__c> WarehouseItemInventoryStocks;
            if(Schema.sObjectType.Inventory_Stock__c.isAccessible()){
                UtilClass.FlsCheck(new String[]{'ERP7__Active__c','ERP7__Organisation__c','ERP7__Organisation_Business_Unit__c','ERP7__Warehouse__c','ERP7__Item__c','ERP7__Number_of_Item_In_Stock__c','ERP7__Number_of_Item_Purchased_In__c','ERP7__Number_of_Items_Dispatched__c','ERP7__No_of_Items_Sold__c','ERP7__Checked_In_Date__c'},'ERP7__Inventory_Stock__c');
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, ERP7__Serial__c, ERP7__Batch_Lot__c, Version__c,  Product__c,  Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,  Number_of_Items_Dispatched__c, No_of_Items_Sold__c, Checked_In_Date__c  From Inventory_Stock__c  Where Product__c In: productIds And Active__c = true And   Warehouse__c In: allSalepointSiteIds Order By Checked_In_Date__c ASC];//And Number_of_Item_In_Stock__c > 0
            }
            for(Id pId : productIds){
                Set<Inventory_Stock__c> sites = new Set<Inventory_Stock__c>();
                for(Inventory_Stock__c WIIS : WarehouseItemInventoryStocks){   if(pId == WIIS.Product__c) if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) sites.add(WIIS);
                                                                           }
                productSites.put(pId,sites);
            }
            
            List<Stock_Outward_Line_Item__c> pplis2Insert = new List<Stock_Outward_Line_Item__c>();                                                                     
            for(Sales_Order_Line_Item__c lineItem : currentLineItems ){  
                boolean succeed = false; Set<Id> currSalepointSites=new Set<Id>();
                if(Schema.sObjectType.Sales_Order__c.isAccessible() && Schema.sObjectType.Sales_Order__c.fields.Channel__c.isAccessible() && Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible()) currSalepointSites = salepointSites.get(lineItem.Sales_Order__r.Channel__c);
                Set<Inventory_Stock__c> currTempProductSites;
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible()) currTempProductSites = productSites.get(lineItem.Product__c);
                Set<Inventory_Stock__c> currProductSites = new Set<Inventory_Stock__c>(); List<Inventory_Stock__c> currTempProductSitess = new List<Inventory_Stock__c>();
                currTempProductSitess.addAll(currTempProductSites);
                List<Inventory_Stock__c> currProductSitess = new List<Inventory_Stock__c>();
                
                if(lineItem.Checked_Out_Process__c == 'LIFO'){  for(Integer i=currTempProductSitess.size(); i>0; i--){ if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) currProductSitess.add(currTempProductSitess[i-1]); } currProductSites.addAll(currProductSitess);
                                                             } else currProductSites = currTempProductSites;
                Decimal quantity;
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Quantity__c.isAccessible())  quantity = lineItem.Quantity__c;
                
                Decimal SWQuantity=0; 
                
                if(existingSoliAndSOWMap.containskey(lineItem.Id)){
                    for(Stock_Outward_Line_Item__c sto : existingSoliAndSOWMap.get(lineItem.Id)){ 
                        if(sto.ERP7__Quantity__c!=null){  SWQuantity+=sto.ERP7__Quantity__c; 
                                                       }   
                    } 
                }
                
                
                if(SWQuantity!=null && SWQuantity!=0) quantity=quantity-SWQuantity;
                if(lineItem.Inventory_Tracked__c == true && !lineItem.Is_Back_Order__c && !lineItem.Is_Pre_Order__c && quantity>0){
                    /*--- not Back order or not Pre order'*/
                    for(Id currSalepointSite : currSalepointSites){
                        for(Inventory_Stock__c currProductSite : currProductSites){
                            if(currSalepointSite == currProductSite.Warehouse__c && quantity > 0 && (lineItem.ERP7__Version__c == null || (lineItem.ERP7__Version__c != null && lineItem.ERP7__Version__c == currProductSite.ERP7__Version__c))){
                                if(currProductSite.Number_of_Item_In_Stock__c > 0 && currProductSite.Number_of_Item_In_Stock__c >= quantity){
                                    Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) PPLI.Active__c = true;  
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.ERP7__Sales_Order__c = lineItem.Sales_Order__c; 
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) PPLI.Product__c = lineItem.Product__c; 
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) PPLI.Quantity__c = quantity; 
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) PPLI.Sales_Order_Line_Item__c = lineItem.Id; 
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) PPLI.Site_Product_Service_Inventory_Stock__c = currProductSite.Id; 
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()) PPLI.ERP7__Material_Batch_Lot__c = currProductSite.ERP7__Batch_Lot__c;  
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()) PPLI.ERP7__Version__c = currProductSite.ERP7__Version__c;
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){
                                        if(lineItem.Sales_Order__r.Order_Status__c == 'Entered')  PPLI.Status__c = 'Reserved';
                                        else if(lineItem.Sales_Order__r.Order_Status__c == 'Closed') PPLI.Status__c = 'Committed';
                                    }
                                    pplis2Insert.add(PPLI); 
                                    succeed = true; break;
                                }
                                else if(currProductSite.Number_of_Item_In_Stock__c > 0) {                                    Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) PPLI.Active__c = true;                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.ERP7__Sales_Order__c = lineItem.Sales_Order__c;                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) PPLI.Product__c = lineItem.Product__c;                                     if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) PPLI.Quantity__c = currProductSite.Number_of_Item_In_Stock__c;                                     if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) PPLI.Sales_Order_Line_Item__c = lineItem.Id;                                      if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) PPLI.Site_Product_Service_Inventory_Stock__c = currProductSite.Id;                                       if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()) PPLI.ERP7__Material_Batch_Lot__c = currProductSite.ERP7__Batch_Lot__c;                                      if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()) PPLI.ERP7__Version__c = currProductSite.ERP7__Version__c;                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){                                        if(lineItem.Sales_Order__r.Order_Status__c == 'Entered') PPLI.Status__c = 'Reserved';                                        else if(lineItem.Sales_Order__r.Order_Status__c == 'Closed') PPLI.Status__c = 'Committed';                                    }                                    pplis2Insert.add(PPLI);                                     quantity -= currProductSite.Number_of_Item_In_Stock__c;                                }                
                            }
                        }  
                        if(succeed){ break; } 
                    }
                } 
                else if(lineItem.Inventory_Tracked__c == true && quantity>0 && (lineItem.Is_Back_Order__c || lineItem.Is_Pre_Order__c) && lineItem.Sales_Order__r.Order_Status__c == 'Entered'){                    /* --- Is Back order or Is Pre order' */                    for(Id currSalepointSite : currSalepointSites){                        List<Inventory_Stock__c> Stocks;                        if(currProductSites.size() > 0) {                            Stocks = new list<Inventory_Stock__c>(); Stocks.addAll(currProductSites);  Inventory_Stock__c Stock = Stocks[0];                            if(lineItem.ERP7__Version__c != null) for(Inventory_Stock__c IS : currProductSites){ if(lineItem.ERP7__Version__c == IS.ERP7__Version__c){ Stock = IS; break; } }                            Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();                             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) PPLI.Active__c = true;                             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()) PPLI.ERP7__Sales_Order__c = lineItem.Sales_Order__c;                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) PPLI.Product__c = lineItem.Product__c;                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) PPLI.Quantity__c = quantity;                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) PPLI.Sales_Order_Line_Item__c = lineItem.Id;                             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) PPLI.Site_Product_Service_Inventory_Stock__c = Stock.Id;                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()) PPLI.ERP7__Version__c = Stock.ERP7__Version__c;                             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) PPLI.Status__c = 'Requested';                              pplis2Insert.add(PPLI);                            succeed = true;                            break;                        }                    }                         if(succeed){ break; }                 }         
            } 
            
            if(pplis2Insert.size() > 0 && Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()){ PreventRecursiveLedgerEntry.proceedDeleteZeroReserverSTOLI = true; PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true; upsert pplis2Insert; }else{/*not allowed*/}
        }
    }
    
    
    /* 
Method to delete Product Purchase Line Items for delete of Line Items.
*/
    
    public static void deleteProductPurchaseLineItems(List<Sales_Order_Line_Item__c> lineItems){
        Set<Id> lineItemIds = new Set<Id>();
        for(Sales_Order_Line_Item__c lineItem : lineItems){   lineItemIds.add(lineItem.Id);
                                                          }  
        
        List<Sales_Order_Line_Item__c> currentLineItems;
        if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()){
            /*'inside if'*/
            UtilClass.FlsCheck(new String[]{'ERP7__Base_Price__c','ERP7__Discount_Amount__c','ERP7__Invoice__c','ERP7__Price_Product__c','ERP7__Total_Price__c','ERP7__VAT_Amount__c','ERP7__Inventory_Tracked__c','ERP7__Product__c','ERP7__Quantity__c','ERP7__Sales_Order__c','ERP7__Loyalty_Points__c','ERP7__Loyalty_Program__c','ERP7__Checked_Out_Process__c','ERP7__Commission__c','ERP7__Commission_Rate_Card__c','ERP7__Status__c'},'ERP7__Sales_Order_Line_Item__c');
            UtilClass.FlsCheck(new String[]{'ERP7__Sub_Total__c','ERP7__Total_Discount__c','ERP7__Total_Due__c','ERP7__Total_Tax_Amount__c','ERP7__Channel__c','ERP7__Order_Status__c','ERP7__Is_Back_Order__c'},'ERP7__Sales_Order__c');
            UtilClass.FlsCheck(new String[]{'ERP7__SKU__c','ERP7__Track_Inventory__c'},'ERP7__Product__c');
            if(!Schema.sObjectType.ERP7__Commission_Rate_Card__c.fields.Commission_Plan__c.isAccessible()) return ;
            
            currentLineItems = [Select Id, Name, Base_Price__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c, Inventory_Tracked__c,Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Loyalty_Points__c, Loyalty_Program__c, Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c, Commission__c, Commission_Rate_Card__c,  Commission_Rate_Card__r.Commission_Plan__c, Status__c, Product__r.Track_Inventory__c, Sales_Order__r.Channel__c   From Sales_Order_Line_Item__c  Where Id In: lineItemIds];
        }
        
        UtilClass.FlsCheck(new String[]{'ERP7__Active__c','ERP7__Product__c','ERP7__Quantity__c','ERP7__Sales_Order_Line_Item__c','ERP7__Site_Product_Service_Inventory_Stock__c','ERP7__Status__c'},'ERP7__Stock_Outward_Line_Item__c');
        List<Stock_Outward_Line_Item__c> pplis2delete = [Select Id, Name, Active__c,  Product__c, Quantity__c, Sales_Order_Line_Item__c, Site_Product_Service_Inventory_Stock__c, Status__c, ERP7__Fixed_Asset__c From Stock_Outward_Line_Item__c Where Sales_Order_Line_Item__c In : lineItemIds And Active__c = true];
        List <Id> AssetsIds = new List<Id>();                                                   
        for(Stock_Outward_Line_Item__c soli : pplis2delete) if(soli.ERP7__Fixed_Asset__c != Null) AssetsIds.add(soli.ERP7__Fixed_Asset__c);                                                   
        List<ERP7__Asset__c> assets2Update = [Select Id, Name, ERP7__Available__c, ERP7__Status__c From ERP7__Asset__c  Where Id In :AssetsIds];
        for(ERP7__Asset__c Asset : assets2Update){ 
            if(Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Available__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Available__c.isUpdateable()) Asset.ERP7__Available__c = true;
            if(Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Status__c.isUpdateable()) Asset.ERP7__Status__c = 'Available';
        }                                                    
        
        if(pplis2delete.size() > 0) if(Schema.sObjectType.Stock_Outward_Line_Item__c.isDeletable()){ delete pplis2delete; } else{ /*not allowed to delete*/}
        if(assets2Update.size() > 0 && Schema.sObjectType.ERP7__Asset__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.isUpdateable()){ DMLManager.upsertAsUser(assets2Update); } else{/*user is not allowed to upsert*/}
    }
    
    
    public static void updateProductPurchaseLineItemsonSalesOrder(List<Sales_Order__c> salesOrders){
        Set<Id> salesOrdersIds = new Set<Id>();
        for(Sales_Order__c so : salesOrders){ if(Schema.sObjectType.Sales_Order__c.isAccessible()) salesOrdersIds.add(so.Id); }  
        
        List<Stock_Outward_Line_Item__c> pplis2update;
        if(Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()){
            UtilClass.FlsCheck(new String[]{'ERP7__Active__c','ERP7__Product__c','ERP7__Quantity__c','ERP7__Sales_Order_Line_Item__c','ERP7__Site_Product_Service_Inventory_Stock__c'},'ERP7__Stock_Outward_Line_Item__c');
            if(!Schema.sOBjectType.ERP7__Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible()) return ;
            if(!Schema.sOBjectType.ERP7__Sales_Order__c.fields.Order_Status__c.isAccessible()) return ;
            if(!Schema.sOBjectType.ERP7__Sales_Order__c.fields.Is_Back_Order__c.isAccessible()) return ;
            pplis2update = [Select Id, Name, Active__c,  Product__c, Quantity__c, Sales_Order_Line_Item__c, Site_Product_Service_Inventory_Stock__c, Status__c, Sales_Order_Line_Item__r.Sales_Order__c, Sales_Order_Line_Item__r.Sales_Order__r.Order_Status__c, Sales_Order_Line_Item__r.Is_Back_Order__c, Sales_Order_Line_Item__r.Is_Pre_Order__c From Stock_Outward_Line_Item__c Where Sales_Order_Line_Item__r.Sales_Order__c In : salesOrdersIds And Active__c = true];
        }
        
        for(Stock_Outward_Line_Item__c ppli : pplis2update){            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){                if(ppli.Sales_Order_Line_Item__r.Sales_Order__r.Order_Status__c == 'Entered' && (ppli.Sales_Order_Line_Item__r.Is_Back_Order__c || ppli.Sales_Order_Line_Item__r.Is_Pre_Order__c)) ppli.Status__c = 'Requested';                else if(ppli.Sales_Order_Line_Item__r.Sales_Order__r.Order_Status__c == 'Entered') if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isAccessible()) ppli.Status__c = 'Reserved';                else if(ppli.Sales_Order_Line_Item__r.Sales_Order__r.Order_Status__c == 'Closed') if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isAccessible()) ppli.Status__c = 'Committed';            }        }
        
        
        if(pplis2update.size() > 0 && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()) { PreventRecursiveLedgerEntry.proceedDeleteZeroReserverSTOLI = true; PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true; update pplis2update; } else{/*not allowed*/}
    } 
    
}