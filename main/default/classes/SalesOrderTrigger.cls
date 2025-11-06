public with sharing class SalesOrderTrigger { 
     
    //public static void ManageSalesOrderWarranties(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, List < Sales_Order__c > Trigger_New, List < Sales_Order__c > Trigger_Old) {
    public static void ManageSalesOrderWarranties(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, String Trigger_New1, String Trigger_Old1) {
        List<Sales_Order__c> Trigger_New = (List<Sales_Order__c>)JSON.deserialize(Trigger_New1, List<Sales_Order__c>.class);
        List<Sales_Order__c> Trigger_Old = (List<Sales_Order__c>)JSON.deserialize(Trigger_Old1, List<Sales_Order__c>.class);
        List < Id > warSoIds = new List < Id > (); 
        List < Id > productIds = new List < Id > ();  
        List < Id > soliIds = new List < Id > ();
        List < Id > stoliIds = new List < Id > ();
        Map < Id, Warranty__c > lineWarranty = new Map < Id, Warranty__c > ();
        Map < Id, Warranty_Return_Policy__c > itemPolicy = new Map < Id, Warranty_Return_Policy__c > ();
        List < Warranty__c > Warranties2Insert = new List < Warranty__c > ();
        List < Id > cancelledPOIds = new List < Id > ();
        for (Sales_Order__c SO: trigger_New) {
            if (SO.ERP7__Status__c == 'Cancelled')  cancelledPOIds.add(SO.Id);
            if (SO.ERP7__Issue_Warranty__c == True)  warSoIds.add(SO.Id);
            else if (Trigger_IsUpdate) {
                for (Sales_Order__c SOD: Trigger_Old) {
                    if (SO.Id == SOD.Id && SOD.ERP7__Issue_Warranty__c != True && SO.ERP7__Issue_Warranty__c == True) {
                        warSoIds.add(SO.Id); break;
                    }
                }  
            }
        }  
        if (!PreventRecursiveLedgerEntry.testCasesTransactions) {
            List< Stock_Outward_Line_Item__c > STOLIS;
            if(Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()){
                if(warSoIds.size()>0) {
                    STOLIS = [Select Id, Name, Active__c, Fixed_Asset__c, Product__c, Product__r.Name, Quantity__c, Sales_Order__c, Sales_Order_Line_Item__c, Serial__c, Material_Batch_Lot__c, Sales_Order_Line_Item__r.Organisation__c, Sales_Order_Line_Item__r.Organisation_Business_Unit__c From Stock_Outward_Line_Item__c  Where Sales_Order__c In: warSoIds];
                    if(STOLIS.size() > 0 ){
                        for(Stock_Outward_Line_Item__c STOLI : STOLIS){ stoliIds.add(STOLI.Id); productIds.add(STOLI.Product__c); }
                        
                        List<Warranty_Return_Policy__c> WRPS;
                        if(Schema.sObjectType.Warranty_Return_Policy__c.isAccessible()){
                            UtilClass.FlsCheck(new String[]{'ERP7__Active__c', 'ERP7__Days_of_Warranty__c', 'ERP7__Exchange__c', 'ERP7__Number_Days_From_Trans_Return_Accepted__c', 'ERP7__Organisation__c', 'ERP7__Organisation_Business_Unit__c', 'ERP7__Product__c', 'ERP7__Standard_Manufacturing_Warranty__c'},'ERP7__Warranty_Return_Policy__c');
                            if(productIds.size()>0){
                                WRPS = [Select Id, Name, Active__c, Days_of_Warranty__c, Exchange__c, Number_Days_From_Trans_Return_Accepted__c, Organisation__c, Organisation_Business_Unit__c, Product__c, Standard_Manufacturing_Warranty__c From Warranty_Return_Policy__c Where Product__c In: productIds And Active__c = true];}
                                        
                            if(WRPS != null)  for(Warranty_Return_Policy__c WRP : WRPS){ itemPolicy.put(WRP.Product__c, WRP); }
                        }
                        
                        List<Warranty__c> WS;
                        if(Schema.sObjectType.Warranty__c.isAccessible()){
                            UtilClass.FlsCheck(new String[]{'ERP7__Organisation__c', 'ERP7__Organisation_Business_Unit__c', 'ERP7__Product__c', 'ERP7__Quantity__c', 'ERP7__Sales_Order_Line_Item__c', 'ERP7__Type__c', 'ERP7__Valid_From__c', 'ERP7__Valid_Till__c', 'ERP7__Warranty_Return_Policy__c'},'ERP7__Warranty__c');
                            if(stoliIds.size()>0) WS = [Select Id, Name, Organisation__c, Organisation_Business_Unit__c, Product__c, Quantity__c, Stock_Outward_Line_Item__c From Warranty__c Where Stock_Outward_Line_Item__c In: stoliIds];
                            if(WS != null) for(Warranty__c W : WS) lineWarranty.put(W.Stock_Outward_Line_Item__c, W); 
                        }
                      
                        for (Stock_Outward_Line_Item__c STOLI: STOLIS) {
                             if (!lineWarranty.containsKey(STOLI.Id) && itemPolicy.containsKey(STOLI.Product__c)) {
                                Warranty_Return_Policy__c itmPolicy = itemPolicy.get(STOLI.Product__c);
                                Warranty__c W = new Warranty__c(Organisation__c = STOLI.Sales_Order_Line_Item__r.Organisation__c, Organisation_Business_Unit__c = STOLI.Sales_Order_Line_Item__r.Organisation_Business_Unit__c, Product__c = STOLI.Product__c, Quantity__c = STOLI.Quantity__c, Stock_Outward_Line_Item__c = STOLI.Id, ERP7__Sales_Order_Line_Item__c = STOLI.Sales_Order_Line_Item__c,Type__c = 'Standard',Valid_From__c = System.Today(),Valid_Till__c = System.Today() + integer.Valueof(itmPolicy.Days_of_Warranty__c),Warranty_Return_Policy__c = itmPolicy.Id); Warranties2Insert.add(W);                                
                            }
                        }
                    } else Trigger_New[0].addError('No stock outwards created for this sales order to issue warranty');
                }
                
                if (Warranties2Insert.size() > 0) { if(Schema.sObjectType.Warranty__c.isCreateable() && Schema.sObjectType.Warranty__c.isUpdateable()) { DMLManager.UpsertAsUser(Warranties2Insert); } else{ /*not allowd */ } } 
                
                if (cancelledPOIds.size() > 0) {
                    List < ERP7__Stock_Outward_Line_Item__c > cancelStock = [Select Id, Name, ERP7__Sales_Order__c, ERP7__Status__c, ERP7__Fixed_Asset__c From ERP7__Stock_Outward_Line_Item__c Where ERP7__Sales_Order__c In: cancelledPOIds And ERP7__Status__c != 'Rejected'];
                    List < Id > AssetsIds = new List < Id > ();
                    for (ERP7__Stock_Outward_Line_Item__c soli: cancelStock) {  soli.ERP7__Status__c = 'Rejected';  if (soli.ERP7__Fixed_Asset__c != Null) AssetsIds.add(soli.ERP7__Fixed_Asset__c);
                    }
                    List < ERP7__Asset__c > assets2Update = [Select Id, Name, ERP7__Available__c, ERP7__Status__c From ERP7__Asset__c Where Id In: AssetsIds];
                    for (ERP7__Asset__c Asset: assets2Update) { Asset.ERP7__Available__c = true;   Asset.ERP7__Status__c = 'Available';}
                    List < ERP7__Logistic__c > cancelLogistics = [Select Id, Name, ERP7__Sales_Order__c, ERP7__Closed__c From ERP7__Logistic__c Where ERP7__Sales_Order__c In: cancelledPOIds And ERP7__Closed__c = false];
                    for (ERP7__Logistic__c logis: cancelLogistics) { logis.ERP7__Closed__c = true; }
                    if (cancelStock.size() > 0) { if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()) { upsert cancelStock;} else{ /*not allowed */ } }
                    if (assets2Update.size() > 0){if(Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Available__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Available__c.isUpdateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Status__c.isUpdateable()){ upsert assets2Update;} else { /* not allowed */ } } 
                    if (cancelLogistics.size() > 0){ if(Schema.sObjectType.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Closed__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Closed__c.isUpdateable()){ upsert cancelLogistics; } else { /* not allowed */ }} 
                }
            }
        }
    }
    
    //public static void ManageSalesOrderLogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, Boolean Trigger_IsAfter, List < Sales_Order__c > Trigger_New, List < Sales_Order__c > Trigger_Old) {
    public static void ManageSalesOrderLogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, Boolean Trigger_IsAfter, String Trigger_New1, String Trigger_Old1) {
        List<Sales_Order__c> Trigger_New = (List<Sales_Order__c>)JSON.deserialize(Trigger_New1, List<Sales_Order__c>.class);
        List<Sales_Order__c> Trigger_Old = (List<Sales_Order__c>)JSON.deserialize(Trigger_Old1, List<Sales_Order__c>.class);
        List < Id > POIds = new List < Id > ();
        List < Id > soliIds = new List < Id > ();
        List < ERP7__Logistic__c > logistics2upsert = new List < ERP7__Logistic__c >();
        List < ERP7__Logistic_Line_Item__c > logisticsLines2upsert = new List < ERP7__Logistic_Line_Item__c >();
        List<Sales_Order_Line_Item__c> SOLIS = new List<Sales_Order_Line_Item__c>();
        List<ERP7__Stock_Outward_Line_Item__c> pplis = new List<ERP7__Stock_Outward_Line_Item__c>();
        List<ERP7__Logistic__c> existingLogistics = new List<ERP7__Logistic__c>();
        
        Map < Id, Sales_Order__c> SOMap = new Map < Id, Sales_Order__c> ();
        Map < Id, List<Sales_Order_Line_Item__c>> SO_Solis_Map = new Map < Id, List<Sales_Order_Line_Item__c>> ();
        Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> solis_PPLI_Map = new Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> ();
        Map < Id, ERP7__Logistic__c> existingLogisticMap = new Map < Id, ERP7__Logistic__c> ();
        Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> logAndLine = new Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> ();
        Map < String, ERP7__Distribution_Channel__c> siteDistribution = new Map < String, ERP7__Distribution_Channel__c> ();
        
        String SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Logistic__c','SO');
        String Reserved = 'Reserved';
        //String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
        //UtilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');   
        //String SOLIFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order_Line_Item__c');
        //UtilClass.FLSCheck(SOLIFields.split(','),'ERP7__Sales_Order_Line_Item__c');
        
        List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name
                                                                        From Distribution_Channel__c
                                                                        Where Active__c = true 
                                                                        Order By Priority__c ASC NULLS LAST];
        for(ERP7__Distribution_Channel__c DC : DistributionChannels){
            String DCId = DC.Site__c +''+ DC.Channel__c; 
            siteDistribution.put(DCId,DC);
        } 
        if(Trigger_IsAfter && Schema.sObjectType.ERP7__Logistic__c.isAccessible()){
            set<Id> allTrgSOIds = new set<Id>();
            for (Integer i=0; i<trigger_New.size(); i++) {      //!PreventRecursiveLedgerEntry.Loged && trigger_New[i].ERP7__Total_Quantity__c > trigger_New[i].ERP7__Total_Logistic_Quantity__c                                     
                if (trigger_New[i].ERP7__Ready_To_Pick_Pack__c && !PreventRecursiveLedgerEntry.Loged && trigger_New[i].ERP7__Total_Quantity__c > trigger_New[i].ERP7__Total_Logistic_Quantity__c) { // !trigger_New[i].ERP7__Logistic__c // trigger_New[i].ERP7__Authorised__c     
                    POIds.add(trigger_New[i].Id);
                    SO_Solis_Map.put(trigger_New[i].Id, new List<Sales_Order_Line_Item__c>());                   
                    SOMap.put(trigger_New[i].Id, trigger_New[i]);
                }
                allTrgSOIds.add(trigger_New[i].Id);
            }
            List<ERP7__Sales_Order_Line_Item__c> kitSOLIS = new List<ERP7__Sales_Order_Line_Item__c>();
            kitSOLIS = Database.query('select Id, ERP7__Sales_Order__c, ERP7__Sales_Order__r.ERP7__Ready_To_Pick_Pack__c from Sales_Order_Line_Item__c where (Sales_Order__c In : allTrgSOIds And ERP7__Product__r.ERP7__Is_Kit__c=true)');
            for(Integer i=0; i<kitSOLIS.size(); i++){
                if (kitSOLIS[i].ERP7__Sales_Order__r.ERP7__Ready_To_Pick_Pack__c && !PreventRecursiveLedgerEntry.Loged) {
                   POIds.add(kitSOLIS[i].ERP7__Sales_Order__c);
                    SO_Solis_Map.put(kitSOLIS[i].ERP7__Sales_Order__c, new List<Sales_Order_Line_Item__c>());
                    for (Integer j=0; j<trigger_New.size(); j++){
                        if(trigger_New[j].Id == kitSOLIS[i].ERP7__Sales_Order__c){
                            SOMap.put(kitSOLIS[i].ERP7__Sales_Order__c, trigger_New[j]);
                            break;
                        }
                    }
                }
            }
            if(SOMap.Values().size() > 0){
                Set<Id> orderIds = SOMap.keySet();
                //SOLIS = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' from Sales_Order_Line_Item__c where (Sales_Order__c In : orderIds And (ERP7__Product__r.ERP7__Track_Inventory__c=true Or ERP7__Product__r.ERP7__Is_Kit__c=true Or ERP7__Product__r.ERP7__Is_Asset__c=true))');
                //pplis = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ', ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Sales_Order_Line_Item__r.Sales_Order__c from Stock_Outward_Line_Item__c where ERP7__Sales_Order__c In: orderIds and ERP7__Status__c  = :Reserved and ERP7__Quantity__c > 0 Order By ERP7__Sales_Order__c Asc');
                SOLIS = Database.query('select Id,Name,Sales_Order__c,ERP7__Is_Kit__c,ERP7__Product__c,ERP7__Version__c,ERP7__Explode__c,ERP7__Price_Product__c,ERP7__Detailed_Description__c from Sales_Order_Line_Item__c where (Sales_Order__c In : orderIds And (ERP7__Product__r.ERP7__Track_Inventory__c=true Or ERP7__Product__r.ERP7__Is_Kit__c=true Or ERP7__Product__r.ERP7__Is_Asset__c=true))');
                pplis = Database.query('select Id,Name,ERP7__Active__c,ERP7__Batch_Lot_Code__c,ERP7__BoM__c,ERP7__Sales_Order_Line_Item__c,ERP7__Fixed_Asset__c,ERP7__Site_Product_Service_Inventory_Stock__c,ERP7__Sales_Order__c,ERP7__Status__c,ERP7__Quantity__c,ERP7__Customer__c,ERP7__Logistic_Line_Item__c,ERP7__Manufacturing_Order__c,ERP7__Material_Batch_Lot__c,ERP7__Product__c,ERP7__Version__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Sales_Order_Line_Item__r.Sales_Order__c from Stock_Outward_Line_Item__c where ERP7__Sales_Order__c In: orderIds and ERP7__Status__c  = :Reserved and ERP7__Quantity__c > 0 Order By ERP7__Sales_Order__c Asc');
                
                for(Sales_Order_Line_Item__c SOLI :SOLIS){
                    if(SO_Solis_Map.containsKey(SOLI.Sales_Order__c)) SO_Solis_Map.get(SOLI.Sales_Order__c).add(SOLI);
                    else {
                        List<Sales_Order_Line_Item__c> mySOLI = new List<Sales_Order_Line_Item__c>();   mySOLI.add(SOLI);  SO_Solis_Map.put(SOLI.Sales_Order__c, mySOLI);
                    }
                    solis_PPLI_Map.put(SOLI.Id, new List<Stock_Outward_Line_Item__c>());
                }
                
                for(Stock_Outward_Line_Item__c ppli :pplis){
                    if(solis_PPLI_Map.containsKey(ppli.ERP7__Sales_Order_Line_Item__c)) solis_PPLI_Map.get(ppli.ERP7__Sales_Order_Line_Item__c).add(ppli);
                    else {
                        List<Stock_Outward_Line_Item__c> myPPLI = new List<Stock_Outward_Line_Item__c>();   myPPLI.add(ppli); solis_PPLI_Map.put(ppli.ERP7__Sales_Order_Line_Item__c, myPPLI);
                    }
                } 
                
                list<Stock_Outward_Line_Item__c> stoListFinal=new list<Stock_Outward_Line_Item__c>();
                try{
                    stoListFinal=[SELECT Id, Name, ERP7__Quantity__c, Sales_Order_Line_Item__c, ERP7__Product__c, ERP7__Logistic_Line_Item__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Status__c 
                                  FROM ERP7__Stock_Outward_Line_Item__c
                                  WHERE ERP7__Sales_Order__c IN:SOMap.keySet() AND ERP7__Status__c='Reserved' AND ERP7__Logistic_Line_Item__c=NULL AND ERP7__Quantity__c>0];
                    
                    existingLogistics = [Select Id, Name, ERP7__Type__c, ERP7__Account__c, ERP7__Contact__c, ERP7__Sales_Order__c, ERP7__Active__c, Channel__c, ERP7__To_Address__c, ERP7__From_Address__c, RecordTypeId, ERP7__Distribution_Channel__c, ERP7__Closed__c From ERP7__Logistic__c Where ERP7__Sales_Order__c In :SOMap.keySet()];
                } catch(Exception ex){ /*' ManageSalesOrderLogistics catch enter'*/ }  
                
                Map<Id, ERP7__Sales_Order__c> soList = new Map<Id, ERP7__Sales_Order__c>();
                List<List<Stock_Outward_Line_Item__c>> loliOutwards = new List<List<Stock_Outward_Line_Item__c>>();
                List<ERP7__Logistic_Line_Item__c> AllTheLolis = new List<ERP7__Logistic_Line_Item__c>();
                
                if(stoListFinal.size()>0){   
                    for(Sales_Order__c SO : SOMap.Values()){
                        Set<Id> mySites = new Set<Id>();
                        if(SO_Solis_Map.containsKey(SO.Id)){
                            
                            for(Sales_Order_Line_Item__c SOLI : SO_Solis_Map.get(SO.Id)){
                                //for(Stock_Outward_Line_Item__c ppli : solis_PPLI_Map.get(SOLI.Id)) mySites.add(ppli.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c);     
                                for(Stock_Outward_Line_Item__c ppli :stoListFinal) mySites.add(ppli.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c);                        
                            }
                            Integer i = 1+existingLogistics.size();
                            for(Id siteId : mySites){ 
                                String DCId = siteId +''+ SO.ERP7__Channel__c;
                                ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=SO.Name+'-Logistic-'+String.valueof(i), ERP7__Type__c='Outbound', ERP7__Account__c=SO.ERP7__Account__c, ERP7__Contact__c=SO.ERP7__Contact__c, ERP7__Sales_Order__c=SO.Id, ERP7__Active__c=true,Channel__c=SO.ERP7__Channel__c, ERP7__To_Address__c = SO.ERP7__Ship_To_Address__c, ERP7__From_Address__c = SO.ERP7__Ship_From_Address__c,RecordTypeId=SORecTypeId,ERP7__Distribution_Channel__c=(siteDistribution.get(DCId) != null)?siteDistribution.get(DCId).Id:null);
                                if(SO.ERP7__Shipment_Type__c != null && SO.ERP7__Shipment_Type__c != '') { Logistic.ERP7__Shipment_type__c = SO.ERP7__Shipment_Type__c; Logistic.ERP7__Shipping_Preferences__c = '--None--';}
                                else { Logistic.ERP7__Shipment_type__c = '--None--'; Logistic.ERP7__Shipping_Preferences__c = '--None--';}
                                for(ERP7__Logistic__c Log : existingLogistics){
                                    if(Log.ERP7__Type__c == 'Outbound' && Log.ERP7__Sales_Order__c == SO.Id && Log.ERP7__Active__c == true && Log.Channel__c == SO.ERP7__Channel__c && Log.RecordTypeId == SORecTypeId && Log.ERP7__Closed__c == false && siteDistribution.containsKey(DCId) && Log.ERP7__Distribution_Channel__c == siteDistribution.get(DCId).Id){ Logistic = Log;  break;
                                                                                                                                                                                                                                                                                                                                                                   }
                                }
                                ERP7__Sales_Order__c sorder = new ERP7__Sales_Order__c(Id=SO.Id, ERP7__Logistic__c = True);
                                soList.put(SO.Id, sorder);
                                system.debug('soList : '+soList);
                                List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>();
                                i++; Integer j = 1;
                                
                                for(Sales_Order_Line_Item__c SOLI : SO_Solis_Map.get(SO.Id)){
                                    system.debug('SOLI.ERP7__Is_Kit__c : '+SOLI.ERP7__Is_Kit__c);
                                    if(!SOLI.ERP7__Is_Kit__c){
                                        ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=SOLI.Name+'-LogisticLine-'+String.valueof(j), ERP7__Product__c=SOLI.ERP7__Product__c, ERP7__Logistic__c = null,
                                                                                                           ERP7__Sales_Order_Line_Item__c=SOLI.Id, ERP7__Status__c='Reserved', ERP7__Production_Version__c = SOLI.ERP7__Version__c, ERP7__Explode__c = SOLI.ERP7__Explode__c, ERP7__Price_Product__c = SOLI.ERP7__Price_Product__c,
                                                                                                           ERP7__Quantity__c=0, ERP7__Detail_Description__c=SOLI.ERP7__Detailed_Description__c);  
                                        Decimal myQuantity = 0; 
                                        List<Stock_Outward_Line_Item__c> myOutwards = new List<Stock_Outward_Line_Item__c>();                          
                                        for(Integer k=0; k<stoListFinal.size(); k++){ 
                                            if(stoListFinal[k].Sales_Order_Line_Item__c == SOLI.Id && stoListFinal[k].ERP7__Quantity__c != null && stoListFinal[k].ERP7__Quantity__c > 0){  
                                                if(siteId == stoListFinal[k].ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c) {
                                                    myQuantity+=stoListFinal[k].ERP7__Quantity__c; 
                                                    myOutwards.add(stoListFinal[k]);
                                                }
                                            }  
                                        }  
                                        loli.ERP7__Quantity__c = myQuantity;
                                        if(loli.ERP7__Quantity__c > 0) { 
                                            myLines.add(loli);
                                            AllTheLolis.add(loli);
                                            loliOutwards.add(myOutwards);
                                            j++; 
                                        }
                                    }
                                    else if(SOLI.ERP7__Is_Kit__c){
                                        List<Stock_Outward_Line_Item__c> myOutwards = new List<Stock_Outward_Line_Item__c>();
                                        for(Integer k=0; k<stoListFinal.size(); k++){
                                            Decimal myQuantity = 0;
                                            if(stoListFinal[k].Sales_Order_Line_Item__c == SOLI.Id && stoListFinal[k].ERP7__Quantity__c != null && stoListFinal[k].ERP7__Quantity__c > 0){ 
                                                ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=SOLI.Name+'-LogisticLine-'+String.valueof(j), ERP7__Product__c=stoListFinal[k].ERP7__Product__c, ERP7__Logistic__c = null,
                                                                                                                   ERP7__Sales_Order_Line_Item__c=stoListFinal[k].ERP7__Sales_Order_Line_Item__c, ERP7__Status__c='Reserved', ERP7__Production_Version__c = SOLI.ERP7__Version__c, ERP7__Explode__c = SOLI.ERP7__Explode__c, ERP7__Price_Product__c = SOLI.ERP7__Price_Product__c,
                                                                                                                   ERP7__Quantity__c=0);
                                                if(siteId == stoListFinal[k].ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c) {
                                                    myQuantity+=stoListFinal[k].ERP7__Quantity__c; 
                                                    myOutwards.add(stoListFinal[k]);
                                                }
                                                loli.ERP7__Quantity__c = myQuantity;
                                                if(loli.ERP7__Quantity__c > 0) { 
                                                    myLines.add(loli);
                                                    AllTheLolis.add(loli);
                                                    loliOutwards.add(myOutwards);
                                                    j++; 
                                                }
                                            }
                                        }
                                    }
                                } 
                                
                                if(myLines.size() > 0) logAndLine.put(Logistic, myLines);
                            }
                        }
                    }
                }
                
                if(logAndLine.keySet().size() > 0){
                    logistics2upsert.addAll(logAndLine.keySet());
                    if(Schema.sObjectType.ERP7__Logistic__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isUpdateable() &&  Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isUpdateable()){ upsert logistics2upsert; } else{ /*Not allowed to upsert Logistic */ }
                    
                    Integer j=0;
                    for(List<ERP7__Logistic_Line_Item__c> allLolis : logAndLine.Values()){
                        for(ERP7__Logistic_Line_Item__c loli : allLolis) loli.ERP7__Logistic__c = logistics2upsert[j].Id;
                        logisticsLines2upsert.addAll(allLolis); j++;
                    }
                    system.debug('logisticsLines2upsert : '+logisticsLines2upsert.size());
                    if(logisticsLines2upsert.size() > 0) {
                        PreventRecursiveLedgerEntry.Loged = true;
                        if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()) { upsert logisticsLines2upsert; } else{ /* not allowed*/ }
                        //for(Integer m=0; m<logisticsLines2upsert.size(); m++)  stoListFinal[m].ERP7__Logistic_Line_Item__c=logisticsLines2upsert[m].Id;
                        system.debug('after LOLI upsert');
                        
                        List<Stock_Outward_Line_Item__c> allOutwards = new List<Stock_Outward_Line_Item__c>(); 
                        for(Integer x=0; x<logisticsLines2upsert.size(); x++){
                            for(Stock_Outward_Line_Item__c mySOLI : loliOutwards[x]){
                                if(logisticsLines2upsert[x].ERP7__Product__c == mySOLI.ERP7__Product__c) {
                                    system.debug('value matched');
                                    mySOLI.ERP7__Logistic_Line_Item__c = AllTheLolis[x].Id;
                                    allOutwards.add(mySOLI);
                                }
                            }
                        }
                        if(soList.size() > 0){  update soList.values(); }
                        system.debug('allOutwards : '+allOutwards.size());
                        if(allOutwards.size() > 0){ update allOutwards; }//if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()){ update allOutwards; }  else{/*not allwed to update*/ } }
                        system.debug('soList : '+soList.size()+' values :'+soList.values());
                        //if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Logistic__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()){ update soList.values();} else{ /*not allwed to update*/ }}
                    }
                      /*  
                      for(Integer k=0; k<stoListFinal.size(); k++) stoListFinal[k].ERP7__Status__c='Reserved';
                  
                      */
                }
                
            }
        }
        
    }
    
    //public static void ManagePurchaseOrderLogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, List < PO__c > Trigger_New, List < PO__c > Trigger_Old) {
    public static void ManagePurchaseOrderLogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, String Trigger_New1, String Trigger_Old1) {
        system.debug('ManagePurchaseOrderLogistics called');
        List<PO__c> Trigger_New = (List<PO__c>)JSON.deserialize(Trigger_New1, List<PO__c>.class);
        List<PO__c> Trigger_Old = (List<PO__c>)JSON.deserialize(Trigger_Old1, List<PO__c>.class);
        List < Id > POIds = new List < Id > ();
        List < Id > poliIds = new List < Id > ();
        List < ERP7__Logistic__c > logistics2upsert = new List < ERP7__Logistic__c >();
        List < ERP7__Logistic_Line_Item__c > logisticsLines2upsert = new List < ERP7__Logistic_Line_Item__c >();
        List < ERP7__Purchase_Line_Items__c > POLI2upsert = new List < ERP7__Purchase_Line_Items__c >();
        List<ERP7__Purchase_Line_Items__c> poliS = new List<ERP7__Purchase_Line_Items__c>();
        List<ERP7__Stock_Outward_Line_Item__c> pplis = new List<ERP7__Stock_Outward_Line_Item__c>();
        List<List<Stock_Outward_Line_Item__c>> loliOutwards = new List<List<Stock_Outward_Line_Item__c>>();
        List<ERP7__Logistic_Line_Item__c> AllTheLolis = new List<ERP7__Logistic_Line_Item__c>();
        List<ERP7__Logistic__c> existingLogistics = new List<ERP7__Logistic__c>();
        
        Map < Id, PO__c> POMapOutbound = new Map < Id, PO__c> ();
        Map < Id, PO__c> POMapInbound = new Map < Id, PO__c> ();
        Map < Id, ERP7__Logistic__c> existingLogisticMapOutbound = new Map < Id, ERP7__Logistic__c> ();
        Map < Id, ERP7__Logistic__c> existingLogisticMapInbound = new Map < Id, ERP7__Logistic__c> ();
        Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> logAndLine = new Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> ();
        Map < String, ERP7__Distribution_Channel__c> siteDistribution = new Map < String, ERP7__Distribution_Channel__c> ();
        
        String PORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Logistic__c','Purchase_Order');
        String Reserved = 'Reserved';
        String ReturnStat = 'Returned to Supplier';
        String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
        UtilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');   
        String poliFields = UtilClass.selectStarFromSObject('ERP7__Purchase_Line_Items__c');
        UtilClass.FLSCheck(poliFields.split(','),'ERP7__Purchase_Line_Items__c');
                                                                                 
        if(Trigger.IsAfter && Trigger_IsUpdate  && Schema.sObjectType.ERP7__Logistic__c.isAccessible()){
          //  List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name From Distribution_Channel__c Where Active__c = true Order By Priority__c Desc];
          List<ERP7__Distribution_Channel__c> DistributionChannels;
			  if (Test.isRunningTest()) {
               
            } else {
					DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name From Distribution_Channel__c Where Active__c = true Order By Priority__c Desc];
           
            for(ERP7__Distribution_Channel__c DC : DistributionChannels){
                String DCId = DC.Site__c +''+ DC.Channel__c;
                siteDistribution.put(DCId,DC);
            }          
            }
            
            for (Integer i=0; i<trigger_New.size(); i++) {
                system.debug('trigger_New[i].ERP7__Ready_To_Pick_Pack__c : '+trigger_New[i].ERP7__Ready_To_Pick_Pack__c);
                system.debug('trigger_New[i].ERP7__Ready_To_Receive__c : '+trigger_New[i].ERP7__Ready_To_Receive__c);
                system.debug('trigger_New[i].ERP7__Logistic_Created__ : '+trigger_New[i].ERP7__Logistic_Created__c);

                if (trigger_New[i].ERP7__Ready_To_Pick_Pack__c || (trigger_New[i].ERP7__Ready_To_Receive__c && trigger_New[i].ERP7__Logistic_Created__c == false)) {
                    POIds.add(trigger_New[i].Id);
                }
            }
            system.debug('POIds : '+POIds);
            if(POIds.size() > 0) existingLogistics = [Select Id, Name, ERP7__Type__c, ERP7__Purchase_Order__c From ERP7__Logistic__c Where ERP7__Purchase_Order__c In :POIds];
            for(ERP7__Logistic__c Log : existingLogistics){
                if(Log.ERP7__Type__c=='Outbound') existingLogisticMapOutbound.put(Log.ERP7__Purchase_Order__c, Log);
                else if(Log.ERP7__Type__c=='Inbound') existingLogisticMapInbound.put(Log.ERP7__Purchase_Order__c, Log);
            }
            
            for (Integer i=0; i<trigger_New.size(); i++) {
                if (trigger_New[i].ERP7__Ready_To_Pick_Pack__c && !existingLogisticMapOutbound.containsKey(trigger_New[i].Id)) {
                    POMapOutbound.put(trigger_New[i].Id, trigger_New[i]);
                }
                if (trigger_New[i].ERP7__Ready_To_Receive__c && trigger_New[i].ERP7__Logistic_Created__c == false && !existingLogisticMapInbound.containsKey(trigger_New[i].Id)) {
                    POMapInbound.put(trigger_New[i].Id, trigger_New[i]);
                }
            }
            system.debug('POMapInbound : '+POMapInbound.Values().size());
            // Outbound Logistics and Lines Creation
            if(POMapOutbound.Values().size() > 0){
                Set<Id> orderIds = POMapOutbound.keySet();
                Map < Id, List<ERP7__Purchase_Line_Items__c>> PO_Polis_Map = new Map < Id, List<ERP7__Purchase_Line_Items__c>> ();
                Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> polis_PPLI_Map = new Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> ();
                
                polis = Database.query('select ' + String.escapeSingleQuotes(poliFields) + ' from ERP7__Purchase_Line_Items__c where (ERP7__Purchase_Orders__c In : orderIds And (ERP7__Product__r.ERP7__Track_Inventory__c=true Or ERP7__Product__r.ERP7__Is_Kit__c=true Or ERP7__Product__r.ERP7__Is_Asset__c=true))');
                pplis = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ', ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c from Stock_Outward_Line_Item__c where ERP7__Purchase_Orders__c In: orderIds and (ERP7__Status__c  = :Reserved Or ERP7__Status__c = :ReturnStat) and ERP7__Quantity__c > 0 Order By ERP7__Purchase_Orders__c Asc');
                
                for(ERP7__Purchase_Line_Items__c POLI :POLIS){
                    if(PO_Polis_Map == Null) PO_Polis_Map.put(POLI.ERP7__Purchase_Orders__c, new List<ERP7__Purchase_Line_Items__c>());
                    if(PO_Polis_Map.containsKey(POLI.ERP7__Purchase_Orders__c)){
                        PO_Polis_Map.get(POLI.ERP7__Purchase_Orders__c).add(POLI);
                    } else {
                        List<ERP7__Purchase_Line_Items__c> myPOLI = new List<ERP7__Purchase_Line_Items__c>();
                        myPOLI.add(POLI);
                        PO_Polis_Map.put(POLI.ERP7__Purchase_Orders__c, myPOLI);
                    }
                    polis_PPLI_Map.put(POLI.Id, new List<Stock_Outward_Line_Item__c>());
                }
                
                for(Stock_Outward_Line_Item__c ppli :pplis){
                    if(polis_PPLI_Map.containsKey(ppli.ERP7__Purchase_Line_Items__c)) polis_PPLI_Map.get(ppli.ERP7__Purchase_Line_Items__c).add(ppli);
                    else {
                        List<Stock_Outward_Line_Item__c> myPPLI = new List<Stock_Outward_Line_Item__c>(); myPPLI.add(ppli); polis_PPLI_Map.put(ppli.ERP7__Purchase_Line_Items__c, myPPLI);
                    }
                }
                
                for(PO__c SO : POMapOutbound.Values()){
                    Set<Id> mySites = new Set<Id>();
                    if(PO_Polis_Map.containsKey(SO.Id)){
                        for(ERP7__Purchase_Line_Items__c poli : PO_Polis_Map.get(SO.Id)){
                            for(Stock_Outward_Line_Item__c ppli : polis_PPLI_Map.get(poli.Id)) mySites.add(ppli.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c);
                        }
                        Integer i = 1;
                        for(Id siteId : mySites){
                            String DCId = siteId +''+ SO.ERP7__Channel__c;
                            ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=SO.Name+'-Logistic-'+String.valueof(i), ERP7__Type__c='Outbound', ERP7__Account__c=SO.ERP7__Vendor__c, ERP7__Contact__c=SO.ERP7__Vendor_Contact__c, ERP7__Purchase_Order__c=SO.Id, ERP7__Active__c=true,Channel__c=SO.ERP7__Channel__c, ERP7__To_Address__c = SO.ERP7__Vendor_Address__c, ERP7__From_Address__c = SO.ERP7__Delivery_Address__c, RecordTypeId=PORecTypeId,ERP7__Distribution_Channel__c=siteDistribution.get(DCId).Id);
                            
                            Logistic.ERP7__Shipment_type__c = SO.ERP7__Shipment_type__c;
                        	Logistic.ERP7__Shipping_Preferences__c = SO.ERP7__Shipment_Preference_Speed__c;
                            
                            
                            List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>(); i++; Integer j = 1;
                            for(ERP7__Purchase_Line_Items__c poli : PO_Polis_Map.get(SO.Id)){
                                string name = poli.Name+'-LogisticLine-'+String.valueof(j);
                                system.debug('name length : '+name.length()+'name : '+name );
                                if(name.Length() >= 80){
                                    name = name.substring(0, 60) + '-LogisticLine-'+String.valueof(j);
                                    system.debug('name : '+name);
                                    system.debug('name length : '+name.length());
                                }
                                ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=name, ERP7__Product__c=POLI.ERP7__Product__c, ERP7__Purchase_Line_Items__c=POLI.Id, ERP7__Quantity__c=0, ERP7__Production_Version__c = POLI.ERP7__Version__c, ERP7__Explode__c = POLI.ERP7__Explode__c, ERP7__Price_Product__c = POLI.ERP7__Unit_Price__c,ERP7__Status__c='Reserved');  // ERP7__Price_Product__c = POLI.ERP7__Total_Price__c We should be considering Unit Price
                                List<Stock_Outward_Line_Item__c> myOutwards = new List<Stock_Outward_Line_Item__c>();  
                                for(Stock_Outward_Line_Item__c ppli : polis_PPLI_Map.get(poli.Id)){
                                    if(siteId == ppli.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c){
                                        loli.ERP7__Quantity__c+=ppli.ERP7__Quantity__c; myOutwards.add(ppli);
                                    }
                                }
                                if(loli.ERP7__Quantity__c > 0) {
                                    myLines.add(loli);  AllTheLolis.add(loli); loliOutwards.add(myOutwards); j++; 
                                }
                            }
                            if(myLines.size() > 0) logAndLine.put(Logistic, myLines);
                        }
                    }
                }
            }
            // Inbound Logistics and Lines Creation
            if(POMapInbound.Values().size() > 0){
                Map < Id, List<ERP7__Purchase_Line_Items__c>> PO_Polis_Map = new Map < Id, List<ERP7__Purchase_Line_Items__c>> ();
                Set<Id> orderIds = POMapInbound.keySet();
                polis = Database.query('select ' + String.escapeSingleQuotes(poliFields) + ' from ERP7__Purchase_Line_Items__c where (ERP7__Purchase_Orders__c In : orderIds And (ERP7__Product__r.ERP7__Track_Inventory__c=true Or ERP7__Product__r.ERP7__Is_Kit__c=true Or ERP7__Product__r.ERP7__Is_Asset__c=true))');
                
                for(ERP7__Purchase_Line_Items__c POLI :POLIS){
                    if(PO_Polis_Map == Null) PO_Polis_Map.put(POLI.ERP7__Purchase_Orders__c, new List<ERP7__Purchase_Line_Items__c>());
                    if(PO_Polis_Map.containsKey(POLI.ERP7__Purchase_Orders__c)) PO_Polis_Map.get(POLI.ERP7__Purchase_Orders__c).add(POLI);
                    else {
                        List<ERP7__Purchase_Line_Items__c> myPOLI = new List<ERP7__Purchase_Line_Items__c>();
                        myPOLI.add(POLI);   PO_Polis_Map.put(POLI.ERP7__Purchase_Orders__c, myPOLI);
                    }
                }
                
                for(PO__c SO : POMapInbound.Values()){
                    if(PO_Polis_Map.containsKey(SO.Id)){
                        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=SO.Name+'-Logistic', ERP7__Type__c='Inbound', ERP7__Account__c=SO.ERP7__Vendor__c, ERP7__Contact__c=SO.ERP7__Vendor_Contact__c, ERP7__Purchase_Order__c=SO.Id, ERP7__Active__c=true,Channel__c=SO.ERP7__Channel__c, ERP7__To_Address__c = SO.ERP7__Delivery_Address__c, ERP7__From_Address__c = SO.ERP7__Vendor_Address__c,RecordTypeId=PORecTypeId,ERP7__Distribution_Channel__c=SO.ERP7__Distribution_Channel__c);
                        
                        Logistic.ERP7__Shipment_type__c = SO.ERP7__Shipment_type__c;
                        Logistic.ERP7__Shipping_Preferences__c = SO.ERP7__Shipment_Preference_Speed__c;
                            
                        List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>();  Integer j = 1;
                        
                        for(ERP7__Purchase_Line_Items__c poli : PO_Polis_Map.get(SO.Id)){
                            poli.ERP7__Logistic_Quantity__c=poli.ERP7__Quantity__c; POLI2upsert.add(poli);
                            string name = poli.Name+'-LogisticLine-'+String.valueof(j);
                            system.debug('name length : '+name.length()+'name : '+name );
                            if(name.Length() >= 80){
                                name = name.substring(0, 60) + '-LogisticLine-'+String.valueof(j);
                                system.debug('name : '+name);
                                system.debug('name length : '+name.length());
                            }
                            ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=name, ERP7__Product__c=POLI.ERP7__Product__c, ERP7__Purchase_Line_Items__c=POLI.Id, ERP7__Production_Version__c = POLI.ERP7__Version__c, ERP7__Explode__c = POLI.ERP7__Explode__c, ERP7__Price_Product__c = POLI.ERP7__Unit_Price__c,ERP7__Status__c='Reserved',ERP7__Quantity__c=poli.ERP7__Quantity__c);  //// ERP7__Price_Product__c = POLI.ERP7__Total_Price__c We should be considering Unit Price
                            myLines.add(loli);  j++; 
                           
                        }
                        if(myLines.size() > 0) logAndLine.put(Logistic, myLines);
                    }
                }
            }
            
            if(logAndLine.keySet().size() > 0){
                logistics2upsert.addAll(logAndLine.keySet());
                if(Schema.sObjectType.ERP7__Logistic__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isUpdateable() &&  Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Purchase_Order__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Purchase_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isUpdateable()){ upsert logistics2upsert;}else{/*not allowed*/ }
                Integer j=0;
                for(List<ERP7__Logistic_Line_Item__c> allLolis : logAndLine.Values()){
                    for(ERP7__Logistic_Line_Item__c loli : allLolis) loli.Logistic__c = logistics2upsert[j].Id;
                    logisticsLines2upsert.addAll(allLolis);  j++;
                }
                if(logisticsLines2upsert.size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){
                    upsert logisticsLines2upsert;
                }else{/*no allwed*/ }
                
                system.debug('after LOLI upsert');
                List<Stock_Outward_Line_Item__c> allOutwards = new List<Stock_Outward_Line_Item__c>();     
                for(Integer x=0; x<AllTheLolis.size(); x++){
                    for(Stock_Outward_Line_Item__c mySOLI : loliOutwards[x]){
                        if(AllTheLolis[x].Id != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()) mySOLI.ERP7__Logistic_Line_Item__c = AllTheLolis[x].Id;
                        if(mySOLI.ERP7__Status__c == 'Returned to Supplier') mySOLI.ERP7__Status__c = '	Reserved';
                        allOutwards.add(mySOLI);
                    }
                }
                system.debug('allOutwards length~>'+allOutwards.size());
                if(POLI2upsert.size() > 0 && Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Logistic_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Logistic_Quantity__c.isUpdateable()) { upsert POLI2upsert; } else{ /*not allowed*/ }
                
                if(allOutwards.size() > 0 && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()) { update allOutwards;} else{/*not allwed*/}
                
                
            }
        }
    }
    
    public static void manageTaxUponProfileChange(Set<Id> SOIds){
        List<ERP7__Sales_Order_Line_Item__c> SOLIList1=[Select Id,Name,ERP7__VAT_Amount__c,ERP7__Other_Tax__c,ERP7__Tax__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c In:SOIds];        
        for(ERP7__Sales_Order_Line_Item__c SOLI:SOLIList1){  SOLI.ERP7__VAT_Amount__c=0; SOLI.ERP7__Other_Tax__c=0; SOLI.ERP7__Tax__c=null; }  if(SOLIList1.size() > 0) update SOLIList1;                
    }
    
    //public static void ManageWorkOrderLogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, List < WO__c > Trigger_New, List < WO__c > Trigger_Old) {
    public static void ManageWorkOrderLogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, String Trigger_New1, String Trigger_Old1) {
        List<WO__c> Trigger_New = (List<WO__c>)JSON.deserialize(Trigger_New1, List<WO__c>.class);
        List<WO__c> Trigger_Old = (List<WO__c>)JSON.deserialize(Trigger_Old1, List<WO__c>.class);
        List < Id > WOIds = new List < Id > ();
        List < Id > woliIds = new List < Id > ();
        List < ERP7__Logistic__c > logistics2upsert = new List < ERP7__Logistic__c >();
        List < ERP7__Logistic_Line_Item__c > logisticsLines2upsert = new List < ERP7__Logistic_Line_Item__c >();
        List<ERP7__Work_Order_Line_Items__c> wolis = new List<ERP7__Work_Order_Line_Items__c>();
        List<ERP7__Stock_Outward_Line_Item__c> pplis = new List<ERP7__Stock_Outward_Line_Item__c>();
        List<ERP7__Logistic__c> existingLogistics = new List<ERP7__Logistic__c>();
        
        Map < Id, WO__c> WOMapOutbound = new Map < Id, WO__c> ();
        Map < Id, WO__c> WOMapInbound = new Map < Id, WO__c> ();
        Map < Id, ERP7__Logistic__c> existingLogisticMapOutbound = new Map < Id, ERP7__Logistic__c> ();
        Map < Id, ERP7__Logistic__c> existingLogisticMapInbound = new Map < Id, ERP7__Logistic__c> ();
        Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> logAndLine = new Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> ();
        Map < String, ERP7__Distribution_Channel__c> siteDistribution = new Map < String, ERP7__Distribution_Channel__c> ();
        
        String WORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Logistic__c','Work_Order');
        String Reserved = 'Reserved';
        String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
        UtilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');   
        String poliFields = UtilClass.selectStarFromSObject('ERP7__Work_Order_Line_Items__c');
        UtilClass.FLSCheck(poliFields.split(','),'ERP7__Work_Order_Line_Items__c');
        
        List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name From Distribution_Channel__c Where Active__c = true  Order By Priority__c Desc];
        for(ERP7__Distribution_Channel__c DC : DistributionChannels){ String DCId = DC.Site__c +''+ DC.Channel__c; siteDistribution.put(DCId,DC);
        }                                                                                   
        if(Trigger.IsAfter && Trigger_IsUpdate  && Schema.sObjectType.ERP7__Logistic__c.isAccessible()){
            for (Integer i=0; i<trigger_New.size(); i++) {
                if (trigger_New[i].ERP7__Ready_To_Pick_Pack__c || trigger_New[i].ERP7__Ready_To_Receive__c) { WOIds.add(trigger_New[i].Id);
                }
            }
            if(WOIds.size() > 0) existingLogistics = [Select Id, Name, ERP7__Type__c, ERP7__Work_Order__c From ERP7__Logistic__c Where ERP7__Work_Order__c In :WOIds];
            for(ERP7__Logistic__c Log : existingLogistics){
                if(Log.ERP7__Type__c=='Outbound') existingLogisticMapOutbound.put(Log.ERP7__Work_Order__c, Log);
                else if(Log.ERP7__Type__c=='Inbound') existingLogisticMapInbound.put(Log.ERP7__Work_Order__c, Log);
            }
            
            for (Integer i=0; i<trigger_New.size(); i++) {
                if (trigger_New[i].ERP7__Ready_To_Pick_Pack__c && !existingLogisticMapOutbound.containsKey(trigger_New[i].Id)) { WOMapOutbound.put(trigger_New[i].Id, trigger_New[i]);
                }
                if (trigger_New[i].ERP7__Ready_To_Receive__c && !existingLogisticMapInbound.containsKey(trigger_New[i].Id)) { WOMapInbound.put(trigger_New[i].Id, trigger_New[i]);
                }
            }
            
            // Outbound Logistics and Lines Creation
            if(WOMapOutbound.Values().size() > 0){
                Map < Id, List<ERP7__Work_Order_Line_Items__c>> WO_wolis_Map = new Map < Id, List<ERP7__Work_Order_Line_Items__c>> ();
                Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> wolis_PPLI_Map = new Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> ();
        
                Set<Id> orderIds = WOMapOutbound.keySet();
                wolis = Database.query('select ' + String.escapeSingleQuotes(poliFields) + ' from ERP7__Work_Order_Line_Items__c where (ERP7__Work_Orders__c In : orderIds And (ERP7__Product__r.ERP7__Track_Inventory__c=true Or ERP7__Product__r.ERP7__Is_Kit__c=true Or ERP7__Product__r.ERP7__Is_Asset__c=true))');
                pplis = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ', ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c from Stock_Outward_Line_Item__c where ERP7__Work_Orders__c In: orderIds and ERP7__Status__c  = :Reserved and ERP7__Quantity__c > 0 Order By ERP7__Work_Orders__c Asc');
                
                for(ERP7__Work_Order_Line_Items__c WOLI :wolis){
                    if(WO_wolis_Map == Null) WO_wolis_Map.put(WOLI.ERP7__Work_Orders__c, new List<ERP7__Work_Order_Line_Items__c>());
                    if(WO_wolis_Map.containsKey(WOLI.ERP7__Work_Orders__c)){  WO_wolis_Map.get(WOLI.ERP7__Work_Orders__c).add(WOLI);
                    } else {
                        List<ERP7__Work_Order_Line_Items__c> myPOLI = new List<ERP7__Work_Order_Line_Items__c>(); myPOLI.add(WOLI); WO_wolis_Map.put(WOLI.ERP7__Work_Orders__c, myPOLI);
                    }
                    wolis_PPLI_Map.put(WOLI.Id, new List<Stock_Outward_Line_Item__c>());
                }
                
                for(Stock_Outward_Line_Item__c ppli :pplis){
                    if(wolis_PPLI_Map.containsKey(ppli.ERP7__Work_Order_Line_Items__c)){  wolis_PPLI_Map.get(ppli.ERP7__Work_Order_Line_Items__c).add(ppli);
                    } else {
                        List<Stock_Outward_Line_Item__c> myPPLI = new List<Stock_Outward_Line_Item__c>();  myPPLI.add(ppli); wolis_PPLI_Map.put(ppli.ERP7__Work_Order_Line_Items__c, myPPLI);
                    }
                }
                
                for(WO__c WO : WOMapOutbound.Values()){
                    Set<Id> mySites = new Set<Id>();
                    if(WO_wolis_Map.containsKey(WO.Id)){
                        for(ERP7__Work_Order_Line_Items__c woli : WO_wolis_Map.get(WO.Id)){
                            for(Stock_Outward_Line_Item__c ppli : wolis_PPLI_Map.get(WOLI.Id)){ mySites.add(ppli.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c);
                            }
                        }
                        Integer i = 1;
                        for(Id siteId : mySites){
                            String DCId = siteId +''+ WO.ERP7__Channel__c;
                            ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=WO.Name+'-Logistic-'+String.valueof(i), ERP7__Type__c='Outbound', ERP7__Account__c=WO.ERP7__WO_Supplier__c, ERP7__Contact__c=WO.ERP7__Contact__c, ERP7__Work_Order__c=WO.Id, ERP7__Active__c=true,Channel__c=WO.ERP7__Channel__c, ERP7__To_Address__c = WO.ERP7__Shipping_Address__c, ERP7__From_Address__c = WO.ERP7__Billing_Address__c,RecordTypeId=WORecTypeId,ERP7__Distribution_Channel__c=WO.ERP7__Distribution_Channel__c,ERP7__Shipment_type__c='',ERP7__Shipping_Preferences__c='');  i++;
                            List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>(); Integer j = 1;
                            for(ERP7__Work_Order_Line_Items__c woli : WO_wolis_Map.get(WO.Id)){ ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=woli.Name+'-LogisticLine-'+String.valueof(j), ERP7__Product__c=woli.ERP7__Product__c, ERP7__Work_Order_Line_Items__c=woli.Id, ERP7__Quantity__c=0, ERP7__Production_Version__c = woli.ERP7__Version__c, ERP7__Explode__c = woli.ERP7__Explode__c, ERP7__Price_Product__c = woli.ERP7__Unit_Price__c,ERP7__Status__c='Reserved');
                                for(Stock_Outward_Line_Item__c ppli : wolis_PPLI_Map.get(WOLI.Id)){ if(siteId == ppli.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c) loli.ERP7__Quantity__c+=ppli.ERP7__Quantity__c;
                                }
                                if(loli.ERP7__Quantity__c > 0) { myLines.add(loli); j++; 
                                }
                            }
                            if(myLines.size() > 0) logAndLine.put(Logistic, myLines);
                        }
                    }
                }
            }
            // Inbound Logistics and Lines Creation
            if(WOMapInbound.Values().size() > 0){
                Map < Id, List<ERP7__Work_Order_Line_Items__c>> WO_wolis_Map = new Map < Id, List<ERP7__Work_Order_Line_Items__c>> ();
                Set<Id> orderIds = WOMapInbound.keySet();
                wolis = Database.query('select ' + String.escapeSingleQuotes(poliFields) + ' from ERP7__Work_Order_Line_Items__c where (ERP7__Work_Orders__c In : orderIds And (ERP7__Product__r.ERP7__Track_Inventory__c=true Or ERP7__Product__r.ERP7__Is_Kit__c=true Or ERP7__Product__r.ERP7__Is_Asset__c=true))');
                
                for(ERP7__Work_Order_Line_Items__c WOLI :wolis){
                    if(WO_wolis_Map == Null) WO_wolis_Map.put(WOLI.ERP7__Work_Orders__c, new List<ERP7__Work_Order_Line_Items__c>());
                    if(WO_wolis_Map.containsKey(WOLI.ERP7__Work_Orders__c)){ WO_wolis_Map.get(WOLI.ERP7__Work_Orders__c).add(WOLI);
                    } else {
                        List<ERP7__Work_Order_Line_Items__c> myWOLI = new List<ERP7__Work_Order_Line_Items__c>(); myWOLI.add(WOLI);  WO_wolis_Map.put(WOLI.ERP7__Work_Orders__c, myWOLI);
                    }
                }
                
                for(WO__c WO : WOMapInbound.Values()){
                    if(WO_wolis_Map.containsKey(WO.Id)){
                        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=WO.Name+'-Logistic', ERP7__Type__c='Inbound', ERP7__Account__c=WO.ERP7__WO_Supplier__c, ERP7__Contact__c=WO.ERP7__Contact__c, ERP7__Work_Order__c=WO.Id, ERP7__Active__c=true,Channel__c=WO.ERP7__Channel__c, ERP7__To_Address__c = WO.ERP7__Shipping_Address__c, ERP7__From_Address__c = WO.ERP7__Billing_Address__c,RecordTypeId=WORecTypeId,ERP7__Distribution_Channel__c=WO.ERP7__Distribution_Channel__c,ERP7__Shipment_type__c='',ERP7__Shipping_Preferences__c='');
                        List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>();
                        Integer j = 1;
                        for(ERP7__Work_Order_Line_Items__c woli : WO_wolis_Map.get(WO.Id)){
                            ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=woli.Name+'-LogisticLine-'+String.valueof(j), ERP7__Product__c=woli.ERP7__Product__c, ERP7__Work_Order_Line_Items__c=woli.Id, ERP7__Quantity__c=woli.ERP7__Quantity__c, ERP7__Production_Version__c = woli.ERP7__Version__c, ERP7__Explode__c = woli.ERP7__Explode__c, ERP7__Price_Product__c = woli.ERP7__Unit_Price__c,ERP7__Status__c='Reserved');
                            myLines.add(loli); j++; 
                        }
                        if(myLines.size() > 0) logAndLine.put(Logistic, myLines);
                    }
                }
            }
            
            if(logAndLine.keySet().size() > 0){
                logistics2upsert.addAll(logAndLine.keySet());
                if(Schema.sObjectType.ERP7__Logistic__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isUpdateable() &&  Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Work_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isUpdateable()){ upsert logistics2upsert;}else{ /* not alllowed */ }
                Integer j=0;
                for(List<ERP7__Logistic_Line_Item__c> allLolis : logAndLine.Values()){
                    for(ERP7__Logistic_Line_Item__c loli : allLolis) loli.Logistic__c = logistics2upsert[j].Id;
                    logisticsLines2upsert.addAll(allLolis); j++;
                }
                if(logisticsLines2upsert.size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){ upsert logisticsLines2upsert;}else{/*not allowed */ }
            }
        }
    }
    
    //public static void ManageTransferOrderLogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, List < Transfer_Order__c > Trigger_New, List < Transfer_Order__c > Trigger_Old) {
    public static void ManageTransferOrderLogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, String Trigger_New1, String Trigger_Old1) {
        try{
            system.debug('ManageTransferOrderLogistics called');
            List<Transfer_Order__c> Trigger_New = (List<Transfer_Order__c>)JSON.deserialize(Trigger_New1, List<Transfer_Order__c>.class);
            List<Transfer_Order__c> Trigger_Old = (List<Transfer_Order__c>)JSON.deserialize(Trigger_Old1, List<Transfer_Order__c>.class);
            List < Id > ToIds = new List < Id > ();
            List < Id > TOLIIds = new List < Id > ();
            List < ERP7__Logistic__c > logistics2upsert = new List < ERP7__Logistic__c >();
            List < ERP7__Logistic_Line_Item__c > logisticsLines2upsert = new List < ERP7__Logistic_Line_Item__c >();
            List<ERP7__Transfer_Order_Line_Items__c> TOLIs = new List<ERP7__Transfer_Order_Line_Items__c>();
            List<ERP7__Stock_Outward_Line_Item__c> pplis = new List<ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Logistic__c> existingLogistics = new List<ERP7__Logistic__c>();
            
            Map < Id, Transfer_Order__c> TOMapOutbound = new Map < Id, Transfer_Order__c> ();
            Map < Id, Transfer_Order__c> TOMapInbound = new Map < Id, Transfer_Order__c> ();
            Map < Id, ERP7__Logistic__c> existingLogisticMapOutbound = new Map < Id, ERP7__Logistic__c> ();
            Map < Id, ERP7__Logistic__c> existingLogisticMapInbound = new Map < Id, ERP7__Logistic__c> ();
            Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> logAndLine = new Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> ();
            Map < String, ERP7__Distribution_Channel__c> siteDistribution = new Map < String, ERP7__Distribution_Channel__c> ();
            
            List<List<Stock_Outward_Line_Item__c>> loliOutwards = new List<List<Stock_Outward_Line_Item__c>>();
            List<ERP7__Logistic_Line_Item__c> AllTheLolis = new List<ERP7__Logistic_Line_Item__c>();
            
            String TORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Logistic__c','Transfer_Order');
            String Reserved = 'Reserved';
            String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
            UtilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');   
            String poliFields = UtilClass.selectStarFromSObject('ERP7__Transfer_Order_Line_Items__c');
            UtilClass.FLSCheck(poliFields.split(','),'ERP7__Transfer_Order_Line_Items__c');
            
            List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c,Site__r.ERP7__Primary_Contact__c, Site__r.Name From Distribution_Channel__c Where Active__c = true  Order By Priority__c Desc];
            for(ERP7__Distribution_Channel__c DC : DistributionChannels){ String DCId = DC.Site__c +''+ DC.Channel__c; siteDistribution.put(DCId,DC);
                                                                        }                                                                                   
            if(Trigger.IsAfter && Trigger_IsUpdate  && Schema.sObjectType.ERP7__Logistic__c.isAccessible()){
                for (Integer i=0; i<trigger_New.size(); i++) {
                    if (trigger_New[i].ERP7__Ready_To_Pick_Pack__c || trigger_New[i].ERP7__Ready_To_Receive__c) {
                        ToIds.add(trigger_New[i].Id);
                    }
                }
                if(ToIds.size() > 0) existingLogistics = [Select Id, Name, ERP7__Type__c, ERP7__Transfer_Order__c From ERP7__Logistic__c Where ERP7__Transfer_Order__c In :ToIds];
                for(ERP7__Logistic__c Log : existingLogistics){
                    if(Log.ERP7__Type__c=='Outbound') existingLogisticMapOutbound.put(Log.ERP7__Transfer_Order__c, Log);
                    else if(Log.ERP7__Type__c=='Inbound') existingLogisticMapInbound.put(Log.ERP7__Transfer_Order__c, Log);
                }
                
                for (Integer i=0; i<trigger_New.size(); i++) {
                    if (trigger_New[i].ERP7__Ready_To_Pick_Pack__c && !existingLogisticMapOutbound.containsKey(trigger_New[i].Id)) {
                        TOMapOutbound.put(trigger_New[i].Id, trigger_New[i]);
                    }
                    if (trigger_New[i].ERP7__Ready_To_Receive__c && !existingLogisticMapInbound.containsKey(trigger_New[i].Id)) {
                        TOMapInbound.put(trigger_New[i].Id, trigger_New[i]);
                    }
                }
                
                // Outbound Logistics and Lines Creation
                if(TOMapOutbound.Values().size() > 0){
                    system.debug('here 1');
                    Map < Id, List<ERP7__Transfer_Order_Line_Items__c>> TO_TOLIs_Map = new Map < Id, List<ERP7__Transfer_Order_Line_Items__c>> ();
                    Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> TOLIs_PPLI_Map = new Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> ();
                    
                    Set<Id> orderIds = TOMapOutbound.keySet();
                    TOLIs = Database.query('select ' + String.escapeSingleQuotes(poliFields) + ' from ERP7__Transfer_Order_Line_Items__c where (ERP7__Transfer_Order__c In : orderIds And (ERP7__Products__r.ERP7__Track_Inventory__c=true Or ERP7__Products__r.ERP7__Is_Kit__c=true Or ERP7__Products__r.ERP7__Is_Asset__c=true))');
                    pplis = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ', ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c from Stock_Outward_Line_Item__c where ERP7__Transfer_Order__c In: orderIds and ERP7__Status__c  = :Reserved and ERP7__Quantity__c > 0 Order By ERP7__Transfer_Order__c Asc');
                    system.debug('TOLIs=>'+TOLIs);
                    system.debug('pplis=>'+pplis);
                    
                    for(ERP7__Transfer_Order_Line_Items__c TOLI :TOLIs){
                        if(TO_TOLIs_Map == Null) TO_TOLIs_Map.put(TOLI.ERP7__Transfer_Order__c, new List<ERP7__Transfer_Order_Line_Items__c>());
                        if(TO_TOLIs_Map.containsKey(TOLI.ERP7__Transfer_Order__c)){
                            TO_TOLIs_Map.get(TOLI.ERP7__Transfer_Order__c).add(TOLI);
                        } else {
                            List<ERP7__Transfer_Order_Line_Items__c> myPOLI = new List<ERP7__Transfer_Order_Line_Items__c>(); myPOLI.add(TOLI);  TO_TOLIs_Map.put(TOLI.ERP7__Transfer_Order__c, myPOLI);
                        }
                        TOLIs_PPLI_Map.put(TOLI.Id, new List<Stock_Outward_Line_Item__c>());
                    }
                    
                    for(Stock_Outward_Line_Item__c ppli :pplis){
                        if(TOLIs_PPLI_Map.containsKey(ppli.ERP7__Transfer_Order_Line_Item__c)){
                            TOLIs_PPLI_Map.get(ppli.ERP7__Transfer_Order_Line_Item__c).add(ppli);
                        } else {
                            List<Stock_Outward_Line_Item__c> myPPLI = new List<Stock_Outward_Line_Item__c>(); myPPLI.add(ppli);  TOLIs_PPLI_Map.put(ppli.ERP7__Transfer_Order_Line_Item__c, myPPLI);
                        }
                    }
                    
                    for(Transfer_Order__c TO : TOMapOutbound.Values()){
                        system.debug('here 2');
                        Set<Id> mySites = new Set<Id>();
                        if(TO_TOLIs_Map.containsKey(TO.Id)){
                            for(ERP7__Transfer_Order_Line_Items__c TOLI : TO_TOLIs_Map.get(TO.Id)){
                                for(Stock_Outward_Line_Item__c ppli : TOLIs_PPLI_Map.get(TOLI.Id)){
                                    mySites.add(ppli.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c);
                                }
                            }
                            Integer i = 1+existingLogistics.size()+logAndLine.keySet().size();
                            for(Id siteId : mySites){
                                system.debug('here 3');
                                String DCId = siteId +''+ TO.ERP7__Channel__c;
                                ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=TO.Name+'-Logistic-'+String.valueof(i), ERP7__Type__c='Outbound', ERP7__Account__c=TO.ERP7__Customer__c, ERP7__Contact__c=TO.ERP7__Contact__c, ERP7__Transfer_Order__c=TO.Id, ERP7__Active__c=true,Channel__c=TO.ERP7__Channel__c, ERP7__To_Address__c = TO.ERP7__To_Address__c, ERP7__From_Address__c = TO.ERP7__From_Address__c,RecordTypeId=TORecTypeId,ERP7__Distribution_Channel__c=TO.ERP7__Distribution_Channel__c); 
                                Logistic.ERP7__From_Contact__c = (siteDistribution.containskey(DCId) ? siteDistribution.get(DCId).ERP7__Site__r.ERP7__Primary_Contact__c : null); //added by shaguftha 02_07_24
                               
                                if(TO.ERP7__Shipment_type__c != null && TO.ERP7__Shipment_type__c != '') Logistic.ERP7__Shipment_type__c = TO.ERP7__Shipment_type__c;
                                else Logistic.ERP7__Shipment_type__c = '--None--';
                                if(TO.ERP7__Shipment_Preference_Speed__c != null && TO.ERP7__Shipment_Preference_Speed__c != '') Logistic.ERP7__Shipping_Preferences__c = TO.ERP7__Shipment_Preference_Speed__c;
                                else Logistic.ERP7__Shipping_Preferences__c = '--None--';
                                
                                i++;
                                
                                List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>(); Integer j = 1;
                                
                                for(ERP7__Transfer_Order_Line_Items__c TOLI : TO_TOLIs_Map.get(TO.Id)){
                                    system.debug('here 4');
                                    ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name='',ERP7__Product__c=TOLI.ERP7__Products__c, ERP7__Transfer_Order_Line_Item__c=TOLI.Id, ERP7__Quantity__c=0, ERP7__Production_Version__c = TOLI.ERP7__Version__c, ERP7__Explode__c = TOLI.ERP7__Explode__c,ERP7__Status__c='Reserved',ERP7__Batch_Lot__c = string.valueOf(TOLI.ERP7__Batch_Lot__c),ERP7__Serial_Number__c = string.valueOf(TOLI.ERP7__SerialNumber__c)); //Name=TOLI.Name+'-LogisticLine-'+String.valueof(j),
                                    string name = TOLI.Name+'-LogisticLine-'+String.valueof(j); 
                                    if(name.length() > 80) loli.Name = name.substring(0,79); 
                                    else loli.Name = name;
                                    List<Stock_Outward_Line_Item__c> myOutwards = new List<Stock_Outward_Line_Item__c>();       
                                    for(Stock_Outward_Line_Item__c ppli : TOLIs_PPLI_Map.get(TOLI.Id)){
                                        if(siteId == ppli.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c){
                                            loli.ERP7__Quantity__c+=ppli.ERP7__Quantity__c;
                                            myOutwards.add(ppli);
                                        } 
                                    }
                                    if(loli.ERP7__Quantity__c > 0) {
                                        system.debug('here 5');
                                        myLines.add(loli);   
                                        AllTheLolis.add(loli); 
                                        loliOutwards.add(myOutwards);
                                        j++; 
                                    }
                                }
                                if(myLines.size() > 0) logAndLine.put(Logistic, myLines);
                            }
                        }
                    }
                }
                
                // Inbound Logistics and Lines Creation
                if(TOMapInbound.Values().size() > 0){
                    Map < Id, List<ERP7__Transfer_Order_Line_Items__c>> TO_TOLIs_Map = new Map < Id, List<ERP7__Transfer_Order_Line_Items__c>> ();
                    Set<Id> orderIds = TOMapInbound.keySet();
                    TOLIs = Database.query('select ' + String.escapeSingleQuotes(poliFields) + ' from ERP7__Transfer_Order_Line_Items__c where (ERP7__Transfer_Order__c In : orderIds And (ERP7__Products__r.ERP7__Track_Inventory__c=true Or ERP7__Products__r.ERP7__Is_Kit__c=true Or ERP7__Products__r.ERP7__Is_Asset__c=true))');
                    
                    for(ERP7__Transfer_Order_Line_Items__c TOLI :TOLIs){
                        if(TO_TOLIs_Map == Null) TO_TOLIs_Map.put(TOLI.ERP7__Transfer_Order__c, new List<ERP7__Transfer_Order_Line_Items__c>());
                        if(TO_TOLIs_Map.containsKey(TOLI.ERP7__Transfer_Order__c)){ TO_TOLIs_Map.get(TOLI.ERP7__Transfer_Order__c).add(TOLI);
                                                                                  } else {
                                                                                      List<ERP7__Transfer_Order_Line_Items__c> myTOLI = new List<ERP7__Transfer_Order_Line_Items__c>(); myTOLI.add(TOLI); TO_TOLIs_Map.put(TOLI.ERP7__Transfer_Order__c, myTOLI);
                                                                                  }
                    }
                    
                    for(Transfer_Order__c TO : TOMapInbound.Values()){
                        if(TO_TOLIs_Map.containsKey(TO.Id)){
                            Integer p = 1+existingLogistics.size()+logAndLine.keySet().size();
                            ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=TO.Name+'-Logistic-'+String.valueof(p), ERP7__Type__c='Inbound', ERP7__Account__c=TO.ERP7__Customer__c, ERP7__Contact__c=TO.ERP7__Contact__c, ERP7__Transfer_Order__c=TO.Id, ERP7__Active__c=true,Channel__c=TO.ERP7__To_Channel__c, ERP7__To_Address__c = TO.ERP7__To_Address__c, ERP7__From_Address__c = TO.ERP7__From_Address__c,RecordTypeId=TORecTypeId,ERP7__Distribution_Channel__c=TO.ERP7__To_Distribution_Channel__c);
                            p++;
                            List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>(); Integer j = 1;
                            if(TO.ERP7__Shipment_type__c != null && TO.ERP7__Shipment_type__c != '') Logistic.ERP7__Shipment_type__c = TO.ERP7__Shipment_type__c;
                            else Logistic.ERP7__Shipment_type__c = '--None--';
                            if(TO.ERP7__Shipment_Preference_Speed__c != null && TO.ERP7__Shipment_Preference_Speed__c != '') Logistic.ERP7__Shipping_Preferences__c = TO.ERP7__Shipment_Preference_Speed__c;
                            else Logistic.ERP7__Shipping_Preferences__c = '--None--';
                            
                            for(ERP7__Transfer_Order_Line_Items__c TOLI : TO_TOLIs_Map.get(TO.Id)){
                                ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name='',ERP7__Product__c=TOLI.ERP7__Products__c, ERP7__Transfer_Order_Line_Item__c=TOLI.Id, ERP7__Quantity__c=TOLI.ERP7__Quantity_requested__c, ERP7__Production_Version__c = TOLI.ERP7__Version__c, ERP7__Explode__c = TOLI.ERP7__Explode__c,ERP7__Status__c='Reserved',ERP7__Batch_Lot__c = string.valueOf(TOLI.ERP7__Batch_Lot__c),ERP7__Serial_Number__c = string.valueOf(TOLI.ERP7__SerialNumber__c)); //Name=TOLI.Name+'-LogisticLine-'+String.valueof(j), 
                                string name = TOLI.Name+'-LogisticLine-'+String.valueof(j); 
                                if(name.length() > 80) loli.Name = name.substring(0,79); 
                                else loli.Name = name;
                                myLines.add(loli); j++; 
                            }
                            if(myLines.size() > 0) logAndLine.put(Logistic, myLines);
                        }
                    }
                }
                
                if(logAndLine.keySet().size() > 0){
                    logistics2upsert.addAll(logAndLine.keySet());
                    system.debug('logistics2upsert size ~>'+logistics2upsert.size());
                    if(Schema.sObjectType.ERP7__Logistic__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isUpdateable() &&  Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Transfer_Order__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Transfer_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__From_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isUpdateable()){ upsert logistics2upsert;}else{ /*No access */}
                    Integer j=0;
                    for(List<ERP7__Logistic_Line_Item__c> allLolis : logAndLine.Values()){
                        for(ERP7__Logistic_Line_Item__c loli : allLolis) loli.Logistic__c = logistics2upsert[j].Id; logisticsLines2upsert.addAll(allLolis); j++;
                    }
                    if(logisticsLines2upsert.size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){ upsert logisticsLines2upsert;}else{/*cannot upsert*/ }
                    
                    List<Stock_Outward_Line_Item__c> allOutwards = new List<Stock_Outward_Line_Item__c>();     
                    for(Integer x=0; x<AllTheLolis.size(); x++){
                        for(Stock_Outward_Line_Item__c mySOLI : loliOutwards[x]){
                            if(AllTheLolis[x].Id != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()) mySOLI.ERP7__Logistic_Line_Item__c = AllTheLolis[x].Id;
                            allOutwards.add(mySOLI);
                        }
                    }
                    system.debug('allOutwards length~>'+allOutwards.size());
                    if(allOutwards.size() > 0 && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()) { update allOutwards;} else{/*not allwed*/}
                    
                
                }
            }
        } catch (Exception e) {
            System.debug('Exception ManageTransferOrderLogistics~> '+ e.getMessage()+'; at line ~> '+e.getLineNumber());
        } 
    }
    
    //public static void ManageRMALogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, List < ERP7__Return_Merchandise_Authorisation__c > Trigger_New, List < ERP7__Return_Merchandise_Authorisation__c > Trigger_Old) {
    public static void ManageRMALogistics(Boolean Trigger_IsInsert, Boolean Trigger_IsUpdate, String Trigger_New1, String Trigger_Old1) {
        List<ERP7__Return_Merchandise_Authorisation__c> Trigger_New = (List<ERP7__Return_Merchandise_Authorisation__c>)JSON.deserialize(Trigger_New1, List<ERP7__Return_Merchandise_Authorisation__c>.class);
        List<ERP7__Return_Merchandise_Authorisation__c> Trigger_Old = (List<ERP7__Return_Merchandise_Authorisation__c>)JSON.deserialize(Trigger_Old1, List<ERP7__Return_Merchandise_Authorisation__c>.class);
        List < Id > POIds = new List < Id > ();
        List < Id > soliIds = new List < Id > ();
        List < ERP7__Logistic__c > logistics2upsert = new List < ERP7__Logistic__c >();
        List < ERP7__Logistic_Line_Item__c > logisticsLines2upsert = new List < ERP7__Logistic_Line_Item__c >();
        List< ERP7__RMA_Line_Item__c > SOLIS = new List< ERP7__RMA_Line_Item__c >();
        List<ERP7__Stock_Outward_Line_Item__c> pplis = new List<ERP7__Stock_Outward_Line_Item__c>();
        List<ERP7__Logistic__c> existingLogistics = new List<ERP7__Logistic__c>();
        
        Map < Id, ERP7__Return_Merchandise_Authorisation__c> SOMap = new Map < Id, ERP7__Return_Merchandise_Authorisation__c> ();
        Map < Id, List< ERP7__RMA_Line_Item__c >> SO_Solis_Map = new Map < Id, List< ERP7__RMA_Line_Item__c >> ();
        Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> solis_PPLI_Map = new Map < Id, List<ERP7__Stock_Outward_Line_Item__c>> ();
        Map < Id, ERP7__Logistic__c> existingLogisticMap = new Map < Id, ERP7__Logistic__c> ();
        Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> logAndLine = new Map < ERP7__Logistic__c, List < ERP7__Logistic_Line_Item__c >> ();
        Map < String, ERP7__Distribution_Channel__c> siteDistribution = new Map < String, ERP7__Distribution_Channel__c> ();
        
        String RMARecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Logistic__c','RMA');
        String Reserved = 'Reserved';
        String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
        UtilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');   
        String SOLIFields = UtilClass.selectStarFromSObject('ERP7__RMA_Line_Item__c');
        UtilClass.FLSCheck(SOLIFields.split(','),'ERP7__RMA_Line_Item__c');
        
        if(Trigger.IsAfter && Trigger_IsUpdate  && Schema.sObjectType.ERP7__Logistic__c.isAccessible()){
            System.debug('Inside ManageRMALogistics');//1
            for (Integer i=0; i<trigger_New.size(); i++) { if (trigger_New[i].ERP7__Ready_To_Receive__c) { POIds.add(trigger_New[i].Id); SO_Solis_Map.put(trigger_New[i].Id, new List<RMA_Line_Item__c>());
                }
            }
            if(POIds.size() > 0) existingLogistics = [Select Id, Name, RMA__c From ERP7__Logistic__c Where RMA__c In :POIds];
            for(ERP7__Logistic__c Log : existingLogistics) existingLogisticMap.put(Log.RMA__c, Log);
            
            for (Integer i=0; i<trigger_New.size(); i++) {
                if (trigger_New[i].ERP7__Ready_To_Receive__c && !existingLogisticMap.containsKey(trigger_New[i].Id)) { SOMap.put(trigger_New[i].Id, trigger_New[i]);
                }
            }
            if(SOMap.Values().size() > 0){
                System.debug('SOMap--> '+ SOMap);//2
                Set<Id> orderIds = SOMap.keySet();
                SOLIS = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' from RMA_Line_Item__c where (Return_Merchandise_Authorisation__c In : orderIds And (ERP7__Product__r.ERP7__Track_Inventory__c=true Or ERP7__Product__r.ERP7__Is_Kit__c=true Or ERP7__Product__r.ERP7__Is_Asset__c=true))');
                System.debug('SOLIS--> '+ SOLIS);
                for(RMA_Line_Item__c SOLI :SOLIS){
                    if(SO_Solis_Map.containsKey(SOLI.Return_Merchandise_Authorisation__c)){ SO_Solis_Map.get(SOLI.Return_Merchandise_Authorisation__c).add(SOLI);
                    } else {
                        List<RMA_Line_Item__c> mySOLI = new List<RMA_Line_Item__c>(); mySOLI.add(SOLI); SO_Solis_Map.put(SOLI.Return_Merchandise_Authorisation__c, mySOLI);
                    }
                }
               System.debug('SOLIS--> '+ SO_Solis_Map);//3
                for(Return_Merchandise_Authorisation__c SO : SOMap.Values()){
                    if(SO_Solis_Map.containsKey(SO.Id)){
                        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=SO.Name+'-Logistic', ERP7__Type__c='Inbound', ERP7__Account__c=SO.ERP7__Account__c, ERP7__Contact__c=SO.ERP7__Return_Contact__c, ERP7__RMA__c=SO.Id, ERP7__Active__c=true,Channel__c=SO.ERP7__Channel__c, ERP7__To_Address__c = SO.ERP7__Address__c,RecordTypeId=RMARecTypeId,ERP7__Distribution_Channel__c=SO.ERP7__Distribution_Channel__c,ERP7__Site__c=SO.ERP7__Site__c,ERP7__Logistic_Expected_Date__c = SO.ERP7__Expected_Date__c);
                        Logistic.ERP7__Shipment_type__c = '--None--'; Logistic.ERP7__Shipping_Preferences__c = '--None--';
                        
                        List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>(); Integer j = 1;
                        
                        for(RMA_Line_Item__c SOLI : SO_Solis_Map.get(SO.Id)){
                            ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=SOLI.Name+'-LogisticLine-'+String.valueof(j), ERP7__Product__c=SOLI.ERP7__Product__c, ERP7__RMA_Line_Item__c=SOLI.Id, ERP7__Status__c=SOLI.ERP7__Return_Status__c, ERP7__Production_Version__c = SOLI.ERP7__Version__c, ERP7__Explode__c = SOLI.ERP7__Explode__c,ERP7__Quantity__c=SOLI.ERP7__Quantity_Return__c,ERP7__Price_Product__c=SOLI.ERP7__Sale_Price__c);
                            if(loli.ERP7__Quantity__c > 0) { myLines.add(loli);  j++; 
                               
                            }  
                        } 
                        system.debug('myLines.size()=='+myLines.size());
                        if(myLines.size() > 0) logAndLine.put(Logistic, myLines);
                    }
                }
                System.debug('logAndLine--> '+ logAndLine);//4
                if(logAndLine.keySet().size() > 0){ logistics2upsert.addAll(logAndLine.keySet());
                    if(Schema.sObjectType.ERP7__Logistic__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Contact__c.isUpdateable() &&  Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__RMA__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__RMA__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Active__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.Channel__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Site__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Site__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isCreateable() && Schema.sObjectType.ERP7__Logistic__c.fields.ERP7__Distribution_Channel__c.isUpdateable()){ upsert logistics2upsert;}else{/*No access*/ }
                    Integer j=0;
                    for(List<ERP7__Logistic_Line_Item__c> allLolis : logAndLine.Values()){
                        for(ERP7__Logistic_Line_Item__c loli : allLolis) loli.Logistic__c = logistics2upsert[j].Id; logisticsLines2upsert.addAll(allLolis); j++;
                        
                    }
                    if(logisticsLines2upsert.size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__RMA_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__RMA_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Production_Version__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Explode__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Price_Product__c.isUpdateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){ upsert logisticsLines2upsert;}else{/*No access*/ }
                } 
                System.debug('logistics2upsert--> '+ logistics2upsert);//5
                System.debug('logisticsLines2upsert--> '+ logisticsLines2upsert);//6
            }
        }
    } 
}