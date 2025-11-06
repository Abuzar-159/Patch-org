/*
 * 
 * changes made by - Arshad
 * Date - 14 December 2022
 * Change made - methods getAllDetails,getscannedProducts
 * Reason - to show zero in stock inventory records as well
 * 
*/
public  with sharing class StockTake {
    @AuraEnabled public List<ERP7__Location__c> locationList         { get; set; } 
    @AuraEnabled public List<ERP7__StorageContainer__c > binList     { get; set; }
    @AuraEnabled public String LocationsIds                          { get; set; }
    @AuraEnabled public String BinIds                                { get; set; }
    
    public StockTake(){
        locationList = new List<ERP7__Location__c>();
        binList = new List<ERP7__StorageContainer__c>();
    }
    
    // For Stock Take List Start
    
    @AuraEnabled      
    public static stocksWrapper getAll(String searchText, String Channel, String Site, Integer Offset, Integer Show){
        stocksWrapper sWrap = new stocksWrapper();
        String stockFields = UtilClass.selectStarFromSObject('ERP7__Stock_Take__c');
        utilClass.FLSCheck(stockFields.split(','),'ERP7__Stock_Take__c');
        
        try{
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Last_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name,  ERP7__Employee_User__c, 
                       ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c
                       From ERP7__Employees__c
                       Where ERP7__Employee_User__c = : UserInfo.getUserId()
                       Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) {
                sWrap.Employee = empList[0]; 
                if(Channel != Null && Channel != '') sWrap.Employee.ERP7__Channel__c = Channel;
                if(sWrap.Employee.ERP7__Channel__c != Null){
                    List<ERP7__Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Primary__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Site__r.Name
                                                                                From ERP7__Distribution_Channel__c
                                                                                Where ERP7__Channel__c = : sWrap.Employee.ERP7__Channel__c And 
                                                                                ERP7__Active__c = true And 
                                                                                ERP7__Site__c != Null
                                                                                Order By ERP7__Primary__c Desc];
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) { 
                            sWrap.channelSites.add(new pickOptions(DC.ERP7__Site__c, DC.ERP7__Site__r.Name));
                        }
                        sWrap.selectedSite = DistributionChannels[0].ERP7__Site__c;
                    }  
                    if(Site != Null && Site != '') sWrap.selectedSite = Site;
                }
                
                String empChannel = sWrap.Employee.ERP7__Channel__c;
                String selectedSite = sWrap.selectedSite;
                String searchAllText = '%'+searchText+'%';
                List<ERP7__Stock_Take__c> Stocks = new List<ERP7__Stock_Take__c>();
                List<ERP7__Stock_Take__c> Recs = new List<ERP7__Stock_Take__c>();
                
                Stocks = Database.query('select ' + String.escapeSingleQuotes(stockFields) + ' , ERP7__Employee__r.ERP7__Channel__c, ERP7__Employee__r.Name, ERP7__Approver__r.Name from ERP7__Stock_Take__c where (ERP7__Status__c  =\'Open\') And ERP7__Line_Item_Count__c > 0 And ERP7__Channel__c =: empChannel And ERP7__Site__c =: selectedSite And (Name like : searchAllText Or ERP7__Employee__r.Name like : searchAllText Or ERP7__Approver__r.Name like : searchAllText) Order by CreatedDate Desc Limit 9999');
                sWrap.recSize = Stocks.size();
                sWrap.PNS = new List<Integer>();
                sWrap.show = Show;
                sWrap.Offset = Offset;
                Integer ES = sWrap.recSize;
                Integer j=0;
                while(ES >= sWrap.show){ j++; sWrap.PNS.add(j); ES=ES-sWrap.show; } 
                if(ES > 0) sWrap.PNS.add(j+1);
                
                for(Integer i = 0; i < Stocks.size(); i++){ if(i >= sWrap.Offset+sWrap.show) break; if(i >= sWrap.Offset) Recs.add(Stocks[i]); }
                
                Stocks = Recs;
                
                if(Stocks.size() > 0 && sWrap.Offset != 0){ sWrap.startCount = sWrap.Offset + 1; sWrap.endCount = sWrap.Offset + Stocks.size(); sWrap.PageNum = (sWrap.Offset+sWrap.show)/sWrap.show; }
                else if(Stocks.size() > 0 && sWrap.Offset == 0){ sWrap.startCount = 1; sWrap.endCount = Stocks.size(); sWrap.PageNum = 1; }
                
                if(Stocks.size() > 0) sWrap.StockTakeRecs = Stocks;
            }
        return sWrap; } catch (Exception ex){ sWrap.exceptionError = ex.getMessage() +' Line Number @ : '+ ex.getLineNumber();   System.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString()); return sWrap; }
    }
    
    @AuraEnabled
    public static ERP7__Stock_Take__c getStockTakeRec(String StTaId){
        try{
            ERP7__Stock_Take__c stRec = new ERP7__Stock_Take__c();
            if(String.isNotEmpty(StTaId)) stRec = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Employee__c, ERP7__Employee__r.Name, ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c, toLabel(ERP7__Status__c), ERP7__Description__c FROM ERP7__Stock_Take__c WHERE Id =: StTaId Limit 1];
            if(stRec.Id != null) return stRec; else return null; } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber()); } 
    }
    
    @AuraEnabled
    public static string deleteStockTake(String StTaId){
        try{
            if(String.isNotEmpty(StTaId)){
                ERP7__Stock_Take__c stRec = new ERP7__Stock_Take__c();
                stRec = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name , ERP7__Site__c, ERP7__Site__r.Name, ERP7__Employee__c, ERP7__Employee__r.Name, ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c, toLabel(ERP7__Status__c), ERP7__Description__c FROM ERP7__Stock_Take__c WHERE Id =: StTaId Limit 1];
                if(stRec.Id != null && ERP7__Stock_Take__c.sObjectType.getDescribe().isDeletable()) { delete stRec;   } else { return ' No access to delete'; }  
            }
            return ''; } catch (Exception ex){ System.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString()); return ex.getMessage();  }
    }
    
    @AuraEnabled
    public static string updateStockTake(String StockTakeRec){
        try{
            if(String.isNotEmpty(StockTakeRec)){
                ERP7__Stock_Take__c StTaRec = new ERP7__Stock_Take__c();
                StTaRec = (ERP7__Stock_Take__c) JSON.deserialize(StockTakeRec, ERP7__Stock_Take__c.class);
                if(StTaRec.Id != null && Schema.sObjectType.ERP7__Stock_Take__c.isUpdateable()) { update StTaRec; } else{ return 'No access to update' ;}
            }
            return ''; } catch (Exception ex){ System.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString()); return ex.getMessage(); }
    }
    
    // For Stock Take List End
    
    // For Stock Take Process Start
    
    @AuraEnabled      
    public static defaultWrapper getAllDetails(String recordId, String searchText, String Channel, String Site,Integer Offset, Integer Show,String location,String inventoryRecs,Boolean showlocStocks,String ProdId){
        defaultWrapper dWrap = new defaultWrapper();
        try{
            if(showlocStocks == null) showlocStocks = false;
            String stockFields = 'Id,Name,ERP7__Channel__c,ERP7__Channel__r.Name,ERP7__Site__c,ERP7__Site__r.Name,ERP7__Location__c,ERP7__Location__r.Name,ERP7__Employee__c,ERP7__Employee__r.Name,ERP7__Approver__c,ERP7__Approver__r.Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__Description__c,ERP7__Audit_Period__c';
            utilClass.FLSCheck(stockFields.split(','),'ERP7__Stock_Take__c');
            
            String iSFields = 'Id,Name,ERP7__Product__c,ERP7__Serial__c,ERP7__Batch_Lot__c,ERP7__Number_of_Item_In_Stock__c';
            utilClass.FLSCheck(iSFields.split(','),'ERP7__Inventory_Stock__c');
            
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Last_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name,  ERP7__Employee_User__c, 
                       ERP7__Employee_User__r.ManagerId, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c
                       From ERP7__Employees__c
                       Where ERP7__Employee_User__c != null AND ERP7__Employee_User__c = : UserInfo.getUserId()
                       Order by CreatedDate Asc Limit 1];
             
            Boolean considerZeroStocks = false;
            List<String> inventoryIds = new List<String>();
            if(inventoryRecs != null && inventoryRecs != '') inventoryIds = (List<String>) JSON.deserialize(inventoryRecs,List<String>.class);
            List<pickOptions> statusOptions = new List<pickOptions>(); 
            Schema.DescribeFieldResult fieldResult = ERP7__Stock_Take__c.Status__c .getDescribe(); 
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
            for (Schema.PicklistEntry f: ple) dWrap.statusOption.add(new pickOptions(f.getValue(), f.getLabel()));
            
            List<pickOptions> options1 = new List<pickOptions>(); 
            Schema.DescribeFieldResult fieldResult1 = Stock_Outward_Line_Item__c.Status__c .getDescribe(); 
            List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues(); 
            for (Schema.PicklistEntry f: ple1) options1.add(new pickOptions(f.getValue(), f.getLabel()));
            dWrap.stockOutwardStatus = options1;
            
            List<pickOptions> options2 = new List<pickOptions>(); 
            Schema.DescribeFieldResult fieldResult2 = ERP7__Stock_Inward_Line_Item__c.ERP7__Reason__c.getDescribe(); 
            List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues(); 
            for (Schema.PicklistEntry f: ple2) options2.add(new pickOptions(f.getValue(), f.getLabel()));
            dWrap.stockInwardReason = options2;
            
            List<pickOptions> options3 = new List<pickOptions>(); 
            Schema.DescribeFieldResult fieldResult3 = ERP7__Stock_Take__c.ERP7__Audit_Period__c .getDescribe(); 
            List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues(); 
            for (Schema.PicklistEntry f: ple3) options3.add(new pickOptions(f.getValue(), f.getLabel()));
            dWrap.stAudit = options3;
            
            Boolean DontshowzeroQtyInvnetory  = false;
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   
                if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  
            }
            if(FC != null){ 
                dwrap.showVendorCode = FC.ERP7__Show_Vendor_Product_Code__c;
                dwrap.showAdjustedQty = FC.ERP7__Show_adjusted_Qty_in_Stock_Take__c;
                DontshowzeroQtyInvnetory  = FC.ERP7__Do_not_consider_zero_inventory__c;
                dWrap.displayStockAddress =FC.ERP7__Show_Stock_Address_In_Outbound__c; dWrap.displayAudit = FC.ERP7__Show_Audit_in_Stock_Take__c; dWrap.showProdCode = FC.ERP7__hide_product_code_in_stock_take__c; dWrap.showApprover = FC.ERP7__showApproverStockTake__c;
            }
            
            if(empList.size() > 0) {
                dWrap.Employee = empList[0]; 
                if(Channel != Null && Channel != '') dWrap.Employee.ERP7__Channel__c = Channel;
                if(dWrap.Employee.ERP7__Channel__c != Null){
                    List<ERP7__Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Primary__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Site__r.Name
                                                                                From ERP7__Distribution_Channel__c
                                                                                Where ERP7__Channel__c = : dWrap.Employee.ERP7__Channel__c And 
                                                                                ERP7__Active__c = true And 
                                                                                ERP7__Site__c != Null
                                                                                Order By ERP7__Primary__c Desc];
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) { 
                            dWrap.channelSites.add(new pickOptions(DC.ERP7__Site__c, DC.ERP7__Site__r.Name));
                        }
                        dWrap.selectedSite = DistributionChannels[0].ERP7__Site__c;
                    }  
                    if(Site != Null && Site != '') dWrap.selectedSite = Site;
                }
                
                String empChannel = dWrap.Employee.ERP7__Channel__c;
                String selectedSite = dWrap.selectedSite;
                
                String searchAllText = '%'+searchText+'%';
                
                ERP7__Stock_Take__c  stockTake = new ERP7__Stock_Take__c();
                
                if(String.isNotEmpty(recordId)){
                    List<stockTakeWrapper> stockTakeWrapperList = new List<stockTakeWrapper>();
                    List<stockTakeWrapper> stockTakeWrapperListRecs = new List<stockTakeWrapper>();
                    Map<Id, List<ERP7__Stock_Outward_Line_Item__c>> stockOutWardMap = new Map<Id, List<ERP7__Stock_Outward_Line_Item__c>>();
                    Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> stockInWardMap = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>();
                    
                    stockTake = [SELECT Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Channel__r.Id, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Status__c, ERP7__Audit_Period__c, ERP7__Site__r.Name, ERP7__Site__r.Id, ERP7__Employee__c, 
                                 ERP7__Employee__r.Name, ERP7__Employee__r.Id, ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Approver__r.Id, ERP7__Description__c FROM ERP7__Stock_Take__c WHERE Id=:recordId];
                    
                    for(ERP7__Stock_Inward_Line_Item__c sili : [SELECT Id, Name, ERP7__Reason__c, ERP7__Stock_Take_Line_Item__c, ERP7__Stock_Take_Line_Item__r.Id, ERP7__Stock_Take_Line_Item__r.Name, ERP7__Location__c, ERP7__Location__r.Id,
                                                                ERP7__Location__r.Name, ERP7__StorageContainer__c, ERP7__StorageContainer__r.Id, ERP7__StorageContainer__r.Name, ERP7__Serial__c, ERP7__Serial__r.Id, ERP7__Serial__r.Name, 
                                                                ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Id, ERP7__Material_Batch_Lot__r.Name, ERP7__Product__c, ERP7__Product__r.Id,ERP7__Stock_Take_Id__c, 
                                                                ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.Id, ERP7__Site_ProductService_InventoryStock__r.Name, ERP7__Notes__c,
                                                                ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Id, ERP7__Purchase_Orders__r.Name, ERP7__Purchase_Line_Items__c, ERP7__Purchase_Line_Items__r.Id, ERP7__Purchase_Line_Items__r.Name, ERP7__Scrap__c 
                                                                FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__Stock_Take_Line_Item__r.ERP7__Stock_Take__c =: recordId]){
                        List<ERP7__Stock_Inward_Line_Item__c> stockTakeList = (stockInWardMap.get(sili.ERP7__Stock_Take_Line_Item__c) !=null)? stockInWardMap.get(sili.ERP7__Stock_Take_Line_Item__c): new List<ERP7__Stock_Inward_Line_Item__c>();
                        stockTakeList.add(sili);
                        stockInWardMap.put(sili.ERP7__Stock_Take_Line_Item__c,stockTakeList);
                    }
                    
                    for(ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, Name, ERP7__Stock_Take_Line_Item__c, ERP7__Stock_Take_Line_Item__r.Id, ERP7__Stock_Take_Line_Item__r.Name, ERP7__Serial__c, ERP7__Serial__r.Id, ERP7__Serial__r.Name, ERP7__Material_Batch_Lot__c,
                                                                 ERP7__Material_Batch_Lot__r.Id, ERP7__Material_Batch_Lot__r.Name, ERP7__Product__c, ERP7__Product__r.Id, ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c,ERP7__Stock_Take_Id__c, 
                                                                 ERP7__Site_Product_Service_Inventory_Stock__r.Id, ERP7__Site_Product_Service_Inventory_Stock__r.Name, ERP7__Notes__c, ERP7__Scrap__c, ERP7__Status__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Stock_Take_Line_Item__r.ERP7__Stock_Take__c =: recordId]){        
                        List<ERP7__Stock_Outward_Line_Item__c> stockTakeList = (stockOutWardMap.get(soli.ERP7__Stock_Take_Line_Item__c) !=null)? stockOutWardMap.get(soli.ERP7__Stock_Take_Line_Item__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                        stockTakeList.add(soli);
                        stockOutWardMap.put(soli.ERP7__Stock_Take_Line_Item__c,stockTakeList);
                    }
                    List<String> StInvIds = new List<String>();
                    
                    for(ERP7__Stock_Take_Line_Item__c  stockTakeLI : [SELECT Id, Name, ERP7__Adjusted_Quantity__c, ERP7__Inventory_Stock__c, ERP7__Material_Batch_Lot__c, ERP7__Product__c, ERP7__Serial__c, ERP7__Stock_Available__c, ERP7__Stock_In_Hand__c, ERP7__Stock_Take__c, ERP7__Variance__c, ERP7__Inventory_Stock__r.Id,
                                                                      ERP7__Inventory_Stock__r.Name, ERP7__Inventory_Stock__r.ERP7__Location__c,ERP7__Inventory_Stock__r.ERP7__Warehouse__c,ERP7__Inventory_Stock__r.ERP7__Warehouse__r.Name ,ERP7__Inventory_Stock__r.ERP7__Location__r.Id, ERP7__Inventory_Stock__r.ERP7__Location__r.Name,
                                                                      ERP7__Inventory_Stock__r.ERP7__Serial__c, ERP7__Inventory_Stock__r.ERP7__Serial__r.Id, ERP7__Inventory_Stock__r.ERP7__Serial__r.Name,ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c, 
                                                                      ERP7__Inventory_Stock__r.ERP7__Batch_Lot__r.Id, ERP7__Inventory_Stock__r.ERP7__Batch_Lot__r.Name, ERP7__Inventory_Stock__r.ERP7__StorageContainer__c, ERP7__Inventory_Stock__r.ERP7__StorageContainer__r.Id, ERP7__Inventory_Stock__r.ERP7__StorageContainer__r.Name,
                                                                      ERP7__Serial__r.Id,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Material_Batch_Lot__r.Id,ERP7__Material_Batch_Lot__r.Name,
                                                                      ERP7__Product__r.Id, ERP7__Product__r.Name,  ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Product__r.StockKeepingUnit, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c 
                                                                      FROM ERP7__Stock_Take_Line_Item__c Where ERP7__Stock_Take__c =: recordId AND ERP7__Inventory_Stock__c != null]){
                        stockTakeWrapper stockTakeItem = new stockTakeWrapper();
                        stockTakeItem.stockTakeLineItem = stockTakeLI;
                        stockTakeItem.stockInWardList = (stockInWardMap.get(stockTakeLI.Id) != null)?stockInWardMap.get(stockTakeLI.Id):new List<ERP7__Stock_Inward_Line_Item__c>();
                        stockTakeItem.stockOutWardList = (stockOutWardMap.get(stockTakeLI.Id) != null)?stockOutWardMap.get(stockTakeLI.Id):new List<ERP7__Stock_Outward_Line_Item__c>();
                        //stockTakeItem.stockInWardList = new List<ERP7__Stock_Inward_Line_Item__c>();
                        //stockTakeItem.stockOutWardList = new List<ERP7__Stock_Outward_Line_Item__c>();
                          if(stockTakeLI.ERP7__Inventory_Stock__c != null){
                              if(!StInvIds.contains(stockTakeLI.ERP7__Inventory_Stock__c)){
                                  StInvIds.add(stockTakeLI.ERP7__Inventory_Stock__c);
                              }
                          }  
                        dwrap.adjustedstockTakeWrapperList.add(stockTakeItem);
                    }
                    
                    List<ERP7__Inventory_Stock__c> inventoryStocks = new List<ERP7__Inventory_Stock__c>();
                    
                    String invqry = 'select ' + String.escapeSingleQuotes(iSFields) + ' , ERP7__Warehouse__r.Id,ERP7__Warehouse__r.Name,ERP7__Product__r.Id, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Vendor_product_Name__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.StockKeepingUnit, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Track_Inventory__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ProductCode,ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Fixed_Asset__r.ERP7__Serial__c,ERP7__Location__r.Id, ERP7__Location__r.Name, ERP7__Fixed_Asset__r.ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Fixed_Asset__r.Name, ERP7__Fixed_Asset__r.ERP7__Serial__r.Name,ERP7__StorageContainer__r.Id, ERP7__StorageContainer__r.Name,ERP7__Batch_Lot__r.Id, ERP7__Batch_Lot__r.Name,ERP7__Batch_Lot__r.ERP7__Barcode__c,ERP7__Serial__r.Id, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Serial__r.ERP7__Barcode__c,ERP7__Version__r.Id,ERP7__Version__r.Name  from ERP7__Inventory_Stock__c where ERP7__Number_of_Item_In_Stock__c >= 0 And ERP7__Warehouse__c  =: selectedSite And (Name like : searchAllText Or ERP7__Product__r.Name like : searchAllText Or ERP7__Product__r.ERP7__Barcode__c like : searchAllText Or ERP7__Serial__r.Name like :searchAllText Or ERP7__Batch_Lot__r.Name like :searchAllText or ERP7__Product__r.ProductCode like :searchAllText) AND ERP7__Product__c != null AND ERP7__Product__r.IsActive = true And ERP7__Product__r.ERP7__Track_Inventory__c = true ';
                    
                    String Awaiting = '%Awaiting%';
                    invqry += ' AND (Not Name Like :Awaiting) ';
                    if(DontshowzeroQtyInvnetory)  invqry += ' AND ERP7__Number_of_Item_In_Stock__c > 0 ';
                    if(StInvIds.size() > 0) invqry += ' AND Id Not In : StInvIds ';
                    if(inventoryIds.size() > 0) invqry += ' AND Id Not In : inventoryIds ';
                    invqry += ' AND ERP7__Product__r.ERP7__Not_for_Stock_Take__c = false';
                    if(location != null  && location != '') invqry += ' AND ERP7__Location__c =: location ';
                    system.debug('showlocStocks : '+showlocStocks); 
                    if (showlocStocks) {
                        invqry += ' AND ERP7__Location__c != null ';
                        if (location != null && location != '') {
                            invqry += ' AND ERP7__Location__c =: location ';
                        }
                    } else {
                        if (location != null && location != '') {
                            invqry += ' AND ERP7__Location__c =: location ';
                        } else {
                            invqry += ' AND ERP7__Location__c = null ';
                        }
                    }
                    invqry += ' Order by ERP7__Product__r.Name ASC Limit 2000 '; //changed from Lastmodified to Product name on 28_03_23 //Order by LastModifiedDate Desc Limit 9999 //ORDER BY ERP7__Product__r.ERP7__Serialise__c ASC
                    
                    Boolean showOtherProds = false;
                    
                    if(stockTake.Id != null){
                        if(String.isNotEmpty(stockTake.ERP7__Status__c)){ if(stockTake.ERP7__Status__c == 'Open'){ showOtherProds = true; }else showOtherProds = false; }else showOtherProds = false;
                    }
                    Map<Id,Integer> countofInventoryduplicate = new  Map<Id,Integer>();
                    Map<Id,ERP7__Stock_Take_Line_Item__c> stkProd = new  Map<Id,ERP7__Stock_Take_Line_Item__c>();
                    if(showOtherProds){
                        inventoryStocks = Database.query(invqry);
                        system.debug('inventoryStocks size~>'+inventoryStocks.size());                    
                        system.debug('1 Limits.getLimitHeapSize() : '+Limits.getLimitHeapSize()+ ' Actual heap size : '+Limits.getHeapSize());
                        for(ERP7__Inventory_Stock__c  Is :inventoryStocks){
                            stockTakeWrapper stockTakeItem = new stockTakeWrapper();  ERP7__Stock_Take_Line_Item__c stli = new ERP7__Stock_Take_Line_Item__c();
                            stli.ERP7__Inventory_Stock__c  = Is.Id; stli.ERP7__Inventory_Stock__r = Is; stli.ERP7__Product__c = Is.ERP7__Product__c; stli.ERP7__Product__r = Is.ERP7__Product__r;
                            if(Is.ERP7__Location__c == null && Is.ERP7__StorageContainer__c == null){
                                stockTakeItem.inventoryLocation =  Is.ERP7__Warehouse__r.Name;
                            }
                            else if(Is.ERP7__Location__c != null && Is.ERP7__StorageContainer__c == null){
                                stockTakeItem.inventoryLocation = Is.ERP7__Location__r.Name;
                            }
                            else if(Is.ERP7__Location__c != null && Is.ERP7__StorageContainer__c != null){
                                stockTakeItem.inventoryLocation = Is.ERP7__Location__r.Name+ '-' +Is.ERP7__StorageContainer__r.Name;
                            }
                            if(Is.ERP7__Serial__c != null){ stli.ERP7__Serial__c = Is.ERP7__Serial__c; stli.ERP7__Serial__r = Is.ERP7__Serial__r;
                            } 
                            if(Is.ERP7__Batch_Lot__c != null){ stli.ERP7__Material_Batch_Lot__c = Is.ERP7__Batch_Lot__c; stli.ERP7__Material_Batch_Lot__r = Is.ERP7__Batch_Lot__r;
                            } 
                            stli.ERP7__Stock_Available__c = Is.ERP7__Number_of_Item_In_Stock__c; stli.ERP7__Stock_In_Hand__c = null; stli.ERP7__Variance__c = 0.00; stli.ERP7__Adjusted_Quantity__c = 0.00;
                            stockTakeItem.stockTakeLineItem = stli;
                            if(stli.ERP7__Product__r.ProductCode != null && String.isNotEmpty(stli.ERP7__Product__r.ProductCode)){ stockTakeItem.stliProdCodeSKU = stli.ERP7__Product__r.ProductCode;
                            }else if(stli.ERP7__Product__r.StockKeepingUnit != null && String.isNotEmpty(stli.ERP7__Product__r.StockKeepingUnit)){ stockTakeItem.stliProdCodeSKU = stli.ERP7__Product__r.StockKeepingUnit;
                            }
                              if(countofInventoryduplicate.containsKey(stli.ERP7__Product__c) &&  stli.ERP7__Serial__c == null && stli.ERP7__Material_Batch_Lot__c == null ){
                                    Integer count = countofInventoryduplicate.get(stli.ERP7__Product__c);
                                    count = count + 1;
                                    countofInventoryduplicate.put(stli.ERP7__Product__c,count);
                                }
                                else countofInventoryduplicate.put(stli.ERP7__Product__c,1);
                            if(stli.ERP7__Stock_Available__c == 0 && stli.ERP7__Serial__c == null && stli.ERP7__Material_Batch_Lot__c == null){
                             if(countofInventoryduplicate.containsKey(stli.ERP7__Product__c) && countofInventoryduplicate.get(stli.ERP7__Product__c) > 1){
                             }
                             else{
                                stockTakeWrapperList.add(stockTakeItem);
                              }
                                //stkProd.put(stli.ERP7__Inventory_Stock__c,stli);
                              
                            }
                            
                            else stockTakeWrapperList.add(stockTakeItem);
                        }
                        
                    }
                    system.debug('2 Limits.getLimitHeapSize() : '+Limits.getLimitHeapSize()+ ' Actual heap size : '+Limits.getHeapSize());
                    
                    dWrap.allstockTakeWrapperList = stockTakeWrapperList;
                    system.debug('stockTakeWrapperList size~>'+stockTakeWrapperList.size());
                    
                    dWrap.recSize = stockTakeWrapperList.size();
                    dWrap.PNS = new List<Integer>();
                    dWrap.show = Show;
                    dWrap.Offset = Offset;
                    Integer ES = dWrap.recSize;
                    Integer j=0;
                    while(ES >= dWrap.show){ j++; dWrap.PNS.add(j); ES=ES-dWrap.show; } 
                    if(ES > 0) dWrap.PNS.add(j+1);
                    
                    Integer countST = 0;
                    for(Integer i = 0; i < stockTakeWrapperList.size(); i++){ 
                        if(countST < (dWrap.Offset + dWrap.show) && countST >= dWrap.Offset){ stockTakeWrapperListRecs.add(stockTakeWrapperList[i]); } 
                        if(countST > (dWrap.Offset+dWrap.show)) break;
                        countST++; 
                    }
                     system.debug('3 Limits.getLimitHeapSize() : '+Limits.getLimitHeapSize()+ ' Actual heap size : '+Limits.getHeapSize());
                    stockTakeWrapperList = stockTakeWrapperListRecs;
                    
                    if(stockTakeWrapperList.size() > 0 && dWrap.Offset != 0){  dWrap.startCount = dWrap.Offset + 1;  dWrap.endCount = dWrap.Offset + stockTakeWrapperList.size();  dWrap.PageNum = (dWrap.Offset+dWrap.show)/dWrap.show;  }
                    else if(stockTakeWrapperList.size() > 0 && dWrap.Offset == 0){  dWrap.startCount = 1;  dWrap.endCount = stockTakeWrapperList.size();  dWrap.PageNum = 1; 
                    }
                    
                    dWrap.stockTakeWrapperList = stockTakeWrapperList;
                    
                    if(stockTake.Id != null) dWrap.StockTakeRec = stockTake;
                    
                }
                else {
                    
                    stockTake.Name='STK-'+System.Today().Format();
                    stockTake.ERP7__Audit_Period__c = 'Monthly';
                    stockTake.ERP7__Full_Audit__c = false;
                    stockTake.ERP7__Start_Date__c=System.Today();
                    if(dWrap.Employee.Id != null){
                        stockTake.ERP7__Employee__c = dWrap.Employee.Id;
                        List<ERP7__Employees__c> empManager = new List<ERP7__Employees__c>();
                        if(dWrap.Employee.ERP7__Employee_User__r.ManagerId != null){
                            empManager = [Select Id, Name, ERP7__Employee_User__c FROM ERP7__Employees__c WHERE ERP7__Employee_User__c =: dWrap.Employee.ERP7__Employee_User__r.ManagerId]; 
                            if(empManager.size()>0) stockTake.ERP7__Approver__c = empManager[0].Id;
                        }
                    }
                        
                    List<stockTakeWrapper> stockTakeWrapperList = new List<stockTakeWrapper>();
                    List<stockTakeWrapper> stockTakeWrapperListRecs = new List<stockTakeWrapper>();
                    
                    List<ERP7__Inventory_Stock__c> inventoryStocks = new List<ERP7__Inventory_Stock__c>();
                 
                    String invqry = 'select ' + String.escapeSingleQuotes(iSFields) + ' , ERP7__Warehouse__r.Id,ERP7__Warehouse__r.Name,ERP7__Product__r.Id, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.StockKeepingUnit, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Track_Inventory__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ProductCode,ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Fixed_Asset__r.ERP7__Serial__c,ERP7__Location__r.Id, ERP7__Location__r.Name, ERP7__Fixed_Asset__r.ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Fixed_Asset__r.Name, ERP7__Fixed_Asset__r.ERP7__Serial__r.Name,ERP7__StorageContainer__r.Id, ERP7__StorageContainer__r.Name,ERP7__Batch_Lot__r.Id, ERP7__Batch_Lot__r.Name,ERP7__Batch_Lot__r.ERP7__Barcode__c,ERP7__Serial__r.Id, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Serial__r.ERP7__Barcode__c,ERP7__Version__r.Id,ERP7__Version__r.Name  from ERP7__Inventory_Stock__c where ERP7__Number_of_Item_In_Stock__c >= 0 And ERP7__Warehouse__c  =: selectedSite And (Name like : searchAllText Or ERP7__Product__r.Name like : searchAllText Or ERP7__Product__r.ERP7__Barcode__c like : searchAllText Or ERP7__Serial__r.Name like :searchAllText Or ERP7__Batch_Lot__r.Name like :searchAllText or ERP7__Product__r.ProductCode like :searchAllText) AND ERP7__Product__c != null AND ERP7__Product__r.IsActive = true And ERP7__Product__r.ERP7__Track_Inventory__c = true ';
                    
                    String Awaiting = '%Awaiting%'; 
                    invqry += ' AND (Not Name Like :Awaiting) ';
                    if(DontshowzeroQtyInvnetory)  invqry += ' AND ERP7__Number_of_Item_In_Stock__c > 0 ';
                    invqry += ' AND ERP7__Product__r.ERP7__Not_for_Stock_Take__c = false';
                    if(inventoryIds.size() > 0) invqry += ' AND Id Not In : inventoryIds ';
                    if (showlocStocks) {
                        invqry += ' AND ERP7__Location__c != null ';
                        if (location != null && location != '') {
                            invqry += ' AND ERP7__Location__c =: location ';
                        }
                    } else {
                        if (location != null && location != '') {
                            invqry += ' AND ERP7__Location__c =: location ';
                        } else {
                            invqry += ' AND ERP7__Location__c = null ';
                        }
                    }
					if(ProdId != null && ProdId != '') invqry += ' AND ERP7__Product__c = :ProdId '; // added by shaguftha on 13_02_23
                    invqry += ' Order by ERP7__Product__r.Name ASC Limit 9999 '; //changed from Lastmodified to Product name on 28_03_23  //Order by LastModifiedDate Desc Limit 9999 //ORDER BY ERP7__Product__r.ERP7__Serialise__c ASC
                    
                    inventoryStocks = Database.query(invqry);
                    system.debug('inventoryStocks size~>'+inventoryStocks.size());
                    system.debug('1 Limits.getLimitHeapSize() : '+Limits.getLimitHeapSize()+ ' Actual heap size : '+Limits.getHeapSize());
                     Map<Id,Integer> countofInventoryduplicate = new Map<Id,Integer>();
                    Map<Id,ERP7__Stock_Take_Line_Item__c> stkProd = new  Map<Id,ERP7__Stock_Take_Line_Item__c>();
                    for(ERP7__Inventory_Stock__c  Is :inventoryStocks){
                        stockTakeWrapper stockTakeItem = new stockTakeWrapper();  ERP7__Stock_Take_Line_Item__c stli = new ERP7__Stock_Take_Line_Item__c();
                        stli.ERP7__Inventory_Stock__c  = Is.Id; stli.ERP7__Inventory_Stock__r = Is; stli.ERP7__Product__c = Is.ERP7__Product__c; stli.ERP7__Product__r = Is.ERP7__Product__r;
                        if(Is.ERP7__Location__c == null && Is.ERP7__StorageContainer__c == null){
                            stockTakeItem.inventoryLocation =  Is.ERP7__Warehouse__r.Name;
                        }
                        else if(Is.ERP7__Location__c != null && Is.ERP7__StorageContainer__c == null){
                            stockTakeItem.inventoryLocation = Is.ERP7__Location__r.Name;
                        }
                        else if(Is.ERP7__Location__c != null && Is.ERP7__StorageContainer__c != null){
                            stockTakeItem.inventoryLocation = Is.ERP7__Location__r.Name+ '-' +Is.ERP7__StorageContainer__r.Name;
                        }
                        if(Is.ERP7__Serial__c != null){stli.ERP7__Serial__c = Is.ERP7__Serial__c; stli.ERP7__Serial__r = Is.ERP7__Serial__r;
                        } 
                        if(Is.ERP7__Batch_Lot__c != null){ stli.ERP7__Material_Batch_Lot__c = Is.ERP7__Batch_Lot__c; stli.ERP7__Material_Batch_Lot__r = Is.ERP7__Batch_Lot__r;
                        } 
                        stli.ERP7__Stock_Available__c = Is.ERP7__Number_of_Item_In_Stock__c; stli.ERP7__Stock_In_Hand__c = null; stli.ERP7__Variance__c = 0.00; stli.ERP7__Adjusted_Quantity__c = 0.00; 
                        stockTakeItem.stockTakeLineItem = stli;
                        if(stli.ERP7__Product__r.ProductCode != null && String.isNotEmpty(stli.ERP7__Product__r.ProductCode)){ stockTakeItem.stliProdCodeSKU = stli.ERP7__Product__r.ProductCode;
                        }else if(stli.ERP7__Product__r.StockKeepingUnit != null && String.isNotEmpty(stli.ERP7__Product__r.StockKeepingUnit)){ stockTakeItem.stliProdCodeSKU = stli.ERP7__Product__r.StockKeepingUnit;
                        }
                        if(countofInventoryduplicate.containsKey(stli.ERP7__Product__c) &&  stli.ERP7__Serial__c == null && stli.ERP7__Material_Batch_Lot__c == null){
                            Integer count = countofInventoryduplicate.get(stli.ERP7__Product__c); count = count + 1; countofInventoryduplicate.put(stli.ERP7__Product__c,count);
                        }
                        else countofInventoryduplicate.put(stli.ERP7__Product__c,1);
                        if(stli.ERP7__Stock_Available__c == 0 && stli.ERP7__Serial__c == null && stli.ERP7__Material_Batch_Lot__c == null){ 
                             if(countofInventoryduplicate.containsKey(stli.ERP7__Product__c) && countofInventoryduplicate.get(stli.ERP7__Product__c) > 1){
                                 //stkProd.put(stli.ERP7__Inventory_Stock__c,stli); 
                             }
                            else{
                                stockTakeWrapperList.add(stockTakeItem);
                            }
                        }
                        else stockTakeWrapperList.add(stockTakeItem);
                    }
                   system.debug('2 Limits.getLimitHeapSize() : '+Limits.getLimitHeapSize()+ ' Actual heap size : '+Limits.getHeapSize());
                   
                     system.debug('stockTakeWrapperList after : '+stockTakeWrapperList.size());
                    dWrap.allstockTakeWrapperList = stockTakeWrapperList;
                    dWrap.recSize = stockTakeWrapperList.size();
                    dWrap.PNS = new List<Integer>();
                    dWrap.show = Show;
                    dWrap.Offset = Offset;
                    Integer ES = dWrap.recSize;
                    Integer j=0;
                    while(ES >= dWrap.show){ j++; dWrap.PNS.add(j); ES=ES-dWrap.show; } 
                    if(ES > 0) dWrap.PNS.add(j+1);
                    
                    Integer countST = 0;
                    for(Integer i = 0; i < stockTakeWrapperList.size(); i++){ 
                        if(countST < (dWrap.Offset + dWrap.show) && countST >= dWrap.Offset){ stockTakeWrapperListRecs.add(stockTakeWrapperList[i]); } 
                        if(countST > (dWrap.Offset+dWrap.show)) break;
                        countST++; 
                    }
                    system.debug('3 Limits.getLimitHeapSize() : '+Limits.getLimitHeapSize()+ ' Actual heap size : '+Limits.getHeapSize());
                    stockTakeWrapperList = stockTakeWrapperListRecs;
                    
                    if(stockTakeWrapperList.size() > 0 && dWrap.Offset != 0){  dWrap.startCount = dWrap.Offset + 1;  dWrap.endCount = dWrap.Offset + stockTakeWrapperList.size();  dWrap.PageNum = (dWrap.Offset+dWrap.show)/dWrap.show; 
                    }
                    else if(stockTakeWrapperList.size() > 0 && dWrap.Offset == 0){  dWrap.startCount = 1;  dWrap.endCount = stockTakeWrapperList.size();  dWrap.PageNum = 1; 
                    }
                    dWrap.stockTakeWrapperList = stockTakeWrapperList;
                    
                    dWrap.StockTakeRec = stockTake;
                }
                
            }
            
        } catch (Exception ex){ system.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString());  dWrap.exceptionError = ex.getMessage() +' Line Number @ : '+ ex.getLineNumber();  }
        return dWrap;
    }
    
    @AuraEnabled
    public static stockTakeObjWrapper update_Stocks(String stockTakeObj,String stockTakeITemsObj){ //,String stockInList
        try{
        stockTakeObjWrapper  stockTake_Obj = new stockTakeObjWrapper();
            if(String.isNotEmpty(stockTakeObj) && String.isNotEmpty(stockTakeITemsObj)){
                
                ERP7__Stock_Take__c  stockTake = new ERP7__Stock_Take__c();
                stockTake = (ERP7__Stock_Take__c) JSON.deserialize(stockTakeObj, ERP7__Stock_Take__c.class);
                if(Schema.sObjectType.ERP7__Stock_Take__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Take__c.isUpdateable()){ upsert stockTake; } else{ /* no access*/}
                stockTake_Obj.stockTake = stockTake;
                List<ERP7__Stock_Take_Line_Item__c> stockTakeList2Createlist = new List<ERP7__Stock_Take_Line_Item__c>();
                List<ERP7__Stock_Outward_Line_Item__c> stockOutWardList = new List<ERP7__Stock_Outward_Line_Item__c>();
                List<ERP7__Stock_Inward_Line_Item__c> stockInWardList = new List<ERP7__Stock_Inward_Line_Item__c>();
                
                List<stockTakeWrapper> stockTakeWrapperList = new List<stockTakeWrapper>();
                stockTakeWrapperList = (List<stockTakeWrapper>) JSON.deserialize(stockTakeITemsObj, List<stockTakeWrapper>.class);
                
                for(stockTakeWrapper stockTakeWrapperObj : stockTakeWrapperList){
                    if(stockTakeWrapperObj.stockTakeLineItem.ERP7__Product__c != null){
                        //stockTakeWrapperObj.stockTakeLineItem.ERP7__Inventory_Stock__r = null;
                        String Name = 'STLI-'+stockTakeWrapperObj.stockTakeLineItem.ERP7__Product__r.Name;  
                        if(stockTakeWrapperObj.stockTakeLineItem.ERP7__Stock_Take__c == null) stockTakeWrapperObj.stockTakeLineItem.ERP7__Stock_Take__c = stockTake.Id;
                        stockTakeWrapperObj.stockTakeLineItem.Name = (Name.length() >= 79) ? Name.substring(0,78) : Name; // added to trim name 80 chars
                        stockTakeWrapperObj.stockTakeLineItem.ERP7__Adjusted_Quantity__c = (stockTakeWrapperObj.stockTakeLineItem.ERP7__Variance__c < 0)? (0-stockTakeWrapperObj.stockTakeLineItem.ERP7__Variance__c) : stockTakeWrapperObj.stockTakeLineItem.ERP7__Variance__c;
                        stockTakeList2Createlist.add(stockTakeWrapperObj.stockTakeLineItem);
                    }
                }
                
                system.debug('stockTakeList2Createlist~>'+stockTakeList2Createlist.size());
                if(stockTakeList2Createlist.size()>0 && Schema.sObjectType.ERP7__Stock_Take_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Take_Line_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Stock_Take_Line_Item__c.fields.ERP7__Adjusted_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Take_Line_Item__c.fields.ERP7__Adjusted_Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Take_Line_Item__c.fields.ERP7__Stock_Take__c.isCreateable()){
                    upsert stockTakeList2Createlist;
                } else{ /* no access*/ } 
                
                
                for(Integer i=0;i<stockTakeList2Createlist.size();i++){
                    if(stockTakeWrapperList[i].stockInWardList.size() >0){
                        for(Integer j=0;j<stockTakeWrapperList[i].stockInWardList.size();j++){
                            if(stockTakeWrapperList[i].stockInWardList[j].ERP7__Product__c != null){
                                //if(stockTakeWrapperList[i].stockInWardList[j].ERP7__Quantity__c != null && stockTakeWrapperList[i].stockInWardList[j].ERP7__Quantity__c > 0){
                                stockTakeWrapperList[i].stockInWardList[j].ERP7__Stock_Take_Line_Item__c = stockTakeList2Createlist[i].Id;
                                stockTakeWrapperList[i].stockInWardList[j].ERP7__Stock_Take_Line_Item__r = null;
                                //stockTakeWrapperList[i].stockInWardList[j].ERP7__Stock_Take_Line_Item__r = new ERP7__Stock_Take_Line_Item__c(Name =  stockTakeList2Createlist[i].Name);
                                if(stockTakeWrapperList[i].stockInWardList[j].ERP7__Location__c == null)stockTakeWrapperList[i].stockInWardList[j].ERP7__Location__r = null;
                                if(stockTakeWrapperList[i].stockInWardList[j].ERP7__StorageContainer__c == null)stockTakeWrapperList[i].stockInWardList[j].ERP7__StorageContainer__r = null;
                                if(stockTakeWrapperList[i].stockInWardList[j].ERP7__Serial__c == null)stockTakeWrapperList[i].stockInWardList[j].ERP7__Serial__r = null;
                                if(stockTakeWrapperList[i].stockInWardList[j].ERP7__Serial__c != null)stockTakeWrapperList[i].stockInWardList[j].ERP7__Serial__c = stockTakeList2Createlist[i].ERP7__Serial__c;
                                stockTakeWrapperList[i].stockInWardList[j].ERP7__Material_Batch_Lot__c = stockTakeList2Createlist[i].ERP7__Material_Batch_Lot__c;
                                if(stockTakeWrapperList[i].stockInWardList[j].ERP7__Version__c == null) stockTakeWrapperList[i].stockInWardList[j].ERP7__Version__c= stockTakeList2Createlist[i].ERP7__Inventory_Stock__r.ERP7__Version__c;
                                String name = stockTakeWrapperList[i].stockInWardList[j].Name;
                                system.debug('Name : '+name);
                                stockTakeWrapperList[i].stockInWardList[j].Name = (name.length() >= 80)  ? name.subString(0,78) : name;
                                system.debug('stockTakeWrapperList[i].stockInWardList[j].Name : '+stockTakeWrapperList[i].stockInWardList[j].Name);
                                stockInWardList.add(stockTakeWrapperList[i].stockInWardList[j]); 
                                /*}else{
                                system.debug('inward to del');
                                //delete todo stli if id exists (need confirmation)
                                }*/
                            }
                        }
                    }
                    
                    if(stockTakeWrapperList[i].stockOutWardList.size() >0){
                        for(Integer j=0;j<stockTakeWrapperList[i].stockOutWardList.size();j++){
                            if(stockTakeWrapperList[i].stockOutWardList[j].ERP7__Product__c != null){
                                // if(stockTakeWrapperList[i].stockOutWardList[j].ERP7__Quantity__c != null && stockTakeWrapperList[i].stockOutWardList[j].ERP7__Quantity__c > 0){
                                stockTakeWrapperList[i].stockOutWardList[j].ERP7__Stock_Take_Line_Item__c = stockTakeList2Createlist[i].Id;
                                stockTakeWrapperList[i].stockOutWardList[j].ERP7__Stock_Take_Line_Item__r = null;
                                //stockTakeWrapperList[i].stockOutWardList[j].ERP7__Stock_Take_Line_Item__r = new ERP7__Stock_Take_Line_Item__c(Name =  stockTakeList2Createlist[i].Name);
                                if(stockTakeWrapperList[i].stockOutWardList[j].ERP7__Serial__c == null) stockTakeWrapperList[i].stockOutWardList[j].ERP7__Serial__r = null;
                                stockTakeWrapperList[i].stockOutWardList[j].ERP7__Material_Batch_Lot__c = stockTakeList2Createlist[i].ERP7__Material_Batch_Lot__c;
                                stockTakeWrapperList[i].stockOutWardList[j].ERP7__Status__c = 'Committed';
                                String name = stockTakeWrapperList[i].stockOutWardList[j].Name;
                                system.debug('Name bfr: '+name.length());
                                stockTakeWrapperList[i].stockOutWardList[j].Name = (name.length() >= 80)  ? name.subString(0,78) : name;
                                system.debug('Name after: '+stockTakeWrapperList[i].stockOutWardList[j].Name.length());
                                stockOutWardList.add(stockTakeWrapperList[i].stockOutWardList[j]); 
                                /* }else{
                                    system.debug('outward to del');
                                    //delete todo stli if id exists (need confirmation)
                                } */
                            }
                        }
                    }
                }
                
                system.debug('stockInWardList~>'+stockInWardList.size());
                if(stockInWardList.size()>0 && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__StorageContainer__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__StorageContainer__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Location__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Location__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Stock_Take_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Stock_Take_Line_Item__c.isUpdateable()){ upsert stockInWardList; 
                } else{ /* no access*/ } 
                                            
                system.debug('stockOutWardList~>'+stockOutWardList.size());
                if(stockOutWardList.size()>0 && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Stock_Take_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Stock_Take_Line_Item__c.isUpdateable()){ upsert stockOutWardList;
                } else{ /* no access*/ }  
                
                stockTake_Obj.stockTakeWrapperList = stockTakeWrapperList;
            }  
            return stockTake_Obj; } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber()); } 
    }
    
    @AuraEnabled
    public static void DeleteByOutWardById(String recordData){
        ERP7__Stock_Outward_Line_Item__c  SOLI_2_Delete = (ERP7__Stock_Outward_Line_Item__c)JSON.deserialize(recordData, ERP7__Stock_Outward_Line_Item__c.class);
        if(ERP7__Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) { delete SOLI_2_Delete; } else{ /* no access */ }
    }
    
    @AuraEnabled
    public static void DeleteByInWardById(String recordData){
        ERP7__Stock_Inward_Line_Item__c   SILI_2_Delete = (ERP7__Stock_Inward_Line_Item__c )JSON.deserialize(recordData, ERP7__Stock_Inward_Line_Item__c.class);
        if(ERP7__Stock_Inward_Line_Item__c.sObjectType.getDescribe().isDeletable()) { delete SILI_2_Delete; } else{ /* no access */}
    }
    
    @AuraEnabled
    public static List<String> getStockOutWardStatus(){
        List<String> options = new List<String>(); 
        Schema.DescribeFieldResult fieldResult = Stock_Outward_Line_Item__c.Status__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    
     @AuraEnabled
    public static List<String> getSTAudit(){
        List<String> options = new List<String>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Stock_Take__c.ERP7__Audit_Period__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    
    @AuraEnabled
    public static List<String> getStockInWardReason(){
        List<String> options = new List<String>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Stock_Inward_Line_Item__c.ERP7__Reason__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    
    // For Stock Take Process End
    
    @AuraEnabled
    public static List<selectOptions> getStockTakeStatus(){
        List<selectOptions> options = new List<selectOptions>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Stock_Take__c.Status__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(new SelectOptions(f.getLabel(), f.getValue())); 
        return options;
    }
    
    @AuraEnabled
    public static StockTake fetchLocations_Bins(String recordId){
        StockTake stocktake = new StockTake();
        if(String.isNotEmpty(recordId) && recordId instanceof Id){
            Map<Id,ERP7__Location__c> locationMap = new Map<Id,ERP7__Location__c>([Select Id,Name FROM ERP7__Location__c Where ERP7__Site__c =: recordId]);
            stocktake.locationList = locationMap.values();
            stocktake.LocationsIds = string.valueof(locationMap.keyset());
            Map<Id,ERP7__StorageContainer__c> binMap = new Map<Id,ERP7__StorageContainer__c>([Select Id,Name FROM ERP7__StorageContainer__c Where ERP7__Site__c =: recordId]);
            stocktake.binList = binMap.values();
            stocktake.BinIds = string.valueof(locationMap.keyset());
        }
        return stocktake;
    }
    
    @AuraEnabled
    public static List<stockTakeWrapper> fetch_Products(String siteFilter, String locationFilter, Integer offset, Integer RecordLimit){
        List<stockTakeWrapper> stockTakeWrapperList = new List<stockTakeWrapper>();
        /* removed as we are no longer using this method */
        return stockTakeWrapperList;
    }
    
    @AuraEnabled
    public static List<stockTakeWrapper> getscannedProducts(String scanval,String site,String location){
        List<stockTakeWrapper> stockTakeWrapperList = new List<stockTakeWrapper>();
        Set<Id> pids = new Set<Id>();
        if(scanval != null && scanval != '' && site != null && site != ''){
            Map<Id,Product2> productMap = new Map<Id,Product2>([Select Id, Name, ERP7__Is_Kit__c, ERP7__Is_Asset__c, StockKeepingUnit, ERP7__Barcode__c, ERP7__Track_Inventory__c, ERP7__Serialise__c, ERP7__Lot_Tracked__c, ERP7__Item_Type__c, ProductCode FROM Product2 Where ERP7__Barcode__c=:scanval And IsActive = true And ERP7__Track_Inventory__c = true limit 9999]);
            pids = productMap.keySet();
            
            List<ERP7__Inventory_Stock__c> inventoryStocks = new List<ERP7__Inventory_Stock__c>(); List<ERP7__Inventory_Stock__c> newInventoryStocks = new List<ERP7__Inventory_Stock__c>(); List<ERP7__Inventory_Stock__c> inventoryStocksRecs = new List<ERP7__Inventory_Stock__c>();                    
            
            String Awaiting = '%Awaiting%';
            
            String iSFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c'); utilClass.FLSCheck(iSFields.split(','),'ERP7__Inventory_Stock__c');
            inventoryStocks = Database.query('select ' + String.escapeSingleQuotes(iSFields) + ' , ERP7__Product__r.StockKeepingUnit, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Fixed_Asset__r.ERP7__Serial__c, ERP7__Location__r.Name, ERP7__Fixed_Asset__r.ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Fixed_Asset__r.Name, ERP7__Fixed_Asset__r.ERP7__Serial__r.Name, ERP7__StorageContainer__r.Name, ERP7__Batch_Lot__r.Name, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Version__r.Name  from ERP7__Inventory_Stock__c where (ERP7__Product__c in: pids or ERP7__Fixed_Asset__r.ERP7__Product__c in: pids) AND  (Not Name Like :Awaiting)  AND  ERP7__Number_of_Item_In_Stock__c >= 0 And ERP7__Warehouse__c  =: site And (Name like : scanval Or ERP7__Product__r.Name like : scanval Or ERP7__Product__r.ERP7__Barcode__c like : scanval  AND ERP7__Location__c =:location )  Order by CreatedDate Desc Limit 9999 ');
            
            newInventoryStocks = inventoryStocks;
            
            for(ERP7__Inventory_Stock__c  Is :newInventoryStocks){ product2 pro = (Is.ERP7__Product__c != null)?productMap.get(Is.ERP7__Product__c):productMap.get(Is.ERP7__Fixed_Asset__r.ERP7__Product__c); stockTakeWrapper stockTakeItem = new stockTakeWrapper();  stockTakeItem.stockTakeLineItem = new ERP7__Stock_Take_Line_Item__c(ERP7__Inventory_Stock__c  = Is.Id, ERP7__Inventory_Stock__r = new ERP7__Inventory_Stock__c( Id=Is.Id, Name = Is.Name, ERP7__Version__c=Is.ERP7__Version__c,ERP7__Version__r = new ERP7__Version__c(Id=Is.ERP7__Version__c,Name =Is.ERP7__Version__r.Name),ERP7__Location__c = Is.ERP7__Location__c, ERP7__Location__r = new ERP7__Location__c( Id=Is.ERP7__Location__c, Name =Is.ERP7__Location__r.Name ), ERP7__Serial__c = Is.ERP7__Serial__c, ERP7__Serial__r = new ERP7__Serial_Number__c(Id = Is.ERP7__Serial__c, Name = Is.ERP7__Serial__r.Name, ERP7__Serial_Number__c = Is.ERP7__Serial__r.ERP7__Serial_Number__c), ERP7__Batch_Lot__c = Is.ERP7__Batch_Lot__c, ERP7__Batch_Lot__r = new ERP7__Batch__c( Id = Is.ERP7__Batch_Lot__c, Name = Is.ERP7__Batch_Lot__r.Name ), ERP7__StorageContainer__c = Is.ERP7__StorageContainer__c, ERP7__StorageContainer__r = new ERP7__StorageContainer__c( Id=Is.ERP7__StorageContainer__c, Name=Is.ERP7__StorageContainer__r.Name ) ), ERP7__Product__c =pro.Id, ERP7__Product__r = new product2( Id = pro.Id, Name = pro.Name, StockKeepingUnit = pro.StockKeepingUnit, ERP7__Barcode__c = pro.ERP7__Barcode__c, ERP7__Is_Asset__c = pro.ERP7__Is_Asset__c, ERP7__Serialise__c = pro.ERP7__Serialise__c, ERP7__Lot_Tracked__c = pro.ERP7__Lot_Tracked__c ), ERP7__Serial__c = Is.ERP7__Serial__c, ERP7__Material_Batch_Lot__c = Is.ERP7__Batch_Lot__c, ERP7__Stock_Available__c = Is.ERP7__Number_of_Item_In_Stock__c, ERP7__Stock_In_Hand__c = null, ERP7__Variance__c = 0.00, ERP7__Adjusted_Quantity__c = 0.00); stockTakeWrapperList.add(stockTakeItem); }
            
        }
        
        return stockTakeWrapperList;
    }
    
    @AuraEnabled 
    public static String SearchScanCode(String scanCode,String selectedsite){
        try{
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            
            if(String.isNotEmpty(scanCode)){
                List<ERP7__Site__c > sites = new List<ERP7__Site__c >();
                sites = [SELECT Id,Name FROM ERP7__Site__c Where ERP7__Barcode__c =:scanCode ];
                if(sites.size()>0){
                    gen.writeStringField ('Name',sites[0].Name);
                    gen.writeStringField ('step','Site');
                    gen.writeStringField ('Id',sites[0].Id);
                    gen.writeEndObject();
                    return gen.getAsString();
                }
                if(String.isNotEmpty(selectedsite)){ List<ERP7__Location__c> locations = new List<ERP7__Location__c>(); locations = [SELECT Id,Name FROM ERP7__Location__c  Where ERP7__Barcode__c =:scanCode AND ERP7__Site__c=:selectedsite]; if(locations.size()>0){ gen.writeStringField ('Name',locations[0].Name); gen.writeStringField ('step','location'); gen.writeStringField ('Id',locations[0].Id); gen.writeEndObject(); return gen.getAsString(); } }
                
            }
            return null; }catch(Exception e){ System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber()); }
    }
    
    @AuraEnabled
    public static stockTakeObjWrapper StockTakeDetails(String recordId){
        stockTakeObjWrapper  stockTake_Obj = new stockTakeObjWrapper();
        /* removed as we are no longer using this method */
        return  stockTake_Obj;
    }
    
    @AuraEnabled
    public static stocksWrapper fetchSortedList(String OrderBy,String SortOrder, String site,String ChId,Integer Show,Integer Offset){
        stocksWrapper sWrap = new stocksWrapper(); String stockFields = UtilClass.selectStarFromSObject('ERP7__Stock_Take__c'); utilClass.FLSCheck(stockFields.split(','),'ERP7__Stock_Take__c');
        try{
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c From ERP7__Employees__c Where ERP7__Employee_User__c = : UserInfo.getUserId() Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) {
                sWrap.Employee = empList[0]; 
                if(ChId != Null && ChId != '') sWrap.Employee.ERP7__Channel__c = ChId;
                if(sWrap.Employee.ERP7__Channel__c != Null){
                    List<ERP7__Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Primary__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Site__r.Name From ERP7__Distribution_Channel__c Where ERP7__Channel__c = : sWrap.Employee.ERP7__Channel__c And  ERP7__Active__c = true And  ERP7__Site__c != Null Order By ERP7__Primary__c Desc];
                    if(DistributionChannels.size() > 0) { for(Distribution_Channel__c DC: DistributionChannels) {  sWrap.channelSites.add(new pickOptions(DC.ERP7__Site__c, DC.ERP7__Site__r.Name)); } sWrap.selectedSite = DistributionChannels[0].ERP7__Site__c; }  
                    if(site != Null && site != '') sWrap.selectedSite = site;
                    
                }
                String empChannel = sWrap.Employee.ERP7__Channel__c; String selectedSite = sWrap.selectedSite; List<ERP7__Stock_Take__c> Stocks = new List<ERP7__Stock_Take__c>(); List<ERP7__Stock_Take__c> Recs = new List<ERP7__Stock_Take__c>();
                String query = 'select '+ String.escapeSingleQuotes(stockFields) +' , ERP7__Employee__r.ERP7__Channel__c, ERP7__Employee__r.Name, ERP7__Approver__r.Name from ERP7__Stock_Take__c where (ERP7__Status__c  =\'Open\') And ERP7__Line_Item_Count__c > 0 And ERP7__Channel__c =: empChannel And ERP7__Site__c =: selectedSite Order by  ';
                query = query + String.escapeSingleQuotes(OrderBy) + ' ' + String.escapeSingleQuotes(SortOrder);
                Stocks = Database.query(query); sWrap.recSize = Stocks.size(); sWrap.PNS = new List<Integer>(); sWrap.show = Show; sWrap.Offset = Offset; Integer ES = sWrap.recSize; Integer j=0;
                while(ES >= sWrap.show){ j++; sWrap.PNS.add(j); ES=ES-sWrap.show; } 
                if(ES > 0) sWrap.PNS.add(j+1);
                for(Integer i = 0; i < Stocks.size(); i++){ if(i >= sWrap.Offset+sWrap.show) break; if(i >= sWrap.Offset) Recs.add(Stocks[i]); }
                
                Stocks = Recs;
                
                if(Stocks.size() > 0 && sWrap.Offset != 0){ sWrap.startCount = sWrap.Offset + 1; sWrap.endCount = sWrap.Offset + Stocks.size(); sWrap.PageNum = (sWrap.Offset+sWrap.show)/sWrap.show; }
                else if(Stocks.size() > 0 && sWrap.Offset == 0){ sWrap.startCount = 1; sWrap.endCount = Stocks.size(); sWrap.PageNum = 1; }
                
                if(Stocks.size() > 0) sWrap.StockTakeRecs = Stocks;
            }
       return sWrap; } catch(Exception e){ sWrap.exceptionError = 'Error at fetchSortedList: '+e.getLineNumber()+'  Message : '+e.getMessage(); return sWrap; }
        
        
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; } @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) { label = lab; value = val; } public selectOptions(String lab, string val, Boolean sel) { label = lab; value = val; selected = sel; }
    }
    
    public class stockTakeObjWrapper{
        @AuraEnabled
        public List<stockTakeWrapper> stockTakeWrapperList { get; set;  }
        @AuraEnabled
        public ERP7__Stock_Take__c  stockTake { get; set;  }
        public stockTakeObjWrapper(){
            stockTake = new  ERP7__Stock_Take__c(); 
            stockTakeWrapperList = new List<stockTakeWrapper>();
        }
    }
    
    public class stocksWrapper {
        @AuraEnabled public List<ERP7__Stock_Take__c> StockTakeRecs                  { get; set; }
        @AuraEnabled public Employees__c Employee                                    { get; set; }
        @AuraEnabled public List<pickOptions> channelSites                           { get; set; }
        @AuraEnabled public String selectedSite                                      { get; set; }
        @AuraEnabled public String ChannelName                                       { get; set; } 
        @AuraEnabled public String SiteName                                          { get; set; }
        @AuraEnabled public String exceptionError                                    { get; set; }
        
        @AuraEnabled public List<Integer> PNS                                        { get; set; }
        @AuraEnabled public Integer startCount                                       { get; set; }
        @AuraEnabled public Integer endCount                                         { get; set; }
        @AuraEnabled public Integer Offset                                           { get; set; }
        @AuraEnabled public Integer recSize                                          { get; set; }
        @AuraEnabled public Integer PageNum                                          { get; set; }
        @AuraEnabled public Integer show                                             { get; set; }
        
        public stocksWrapper() {
            StockTakeRecs = new List<ERP7__Stock_Take__c>();
            Employee = new Employees__c();
            channelSites = new List<pickOptions>();
            selectedSite = '';
            ChannelName = '';
            SiteName = '';
            exceptionError = '';
            
            PNS = new List<Integer>();
            startCount = endCount = Offset = recSize = PageNum = 0;
            show = 25;
        }
    }
    
    public class defaultWrapper {
        @AuraEnabled public List<stockTakeWrapper> stockTakeWrapperList              { get; set; }
        @AuraEnabled public List<stockTakeWrapper> allstockTakeWrapperList      { get; set; }
        @AuraEnabled public List<stockTakeWrapper> adjustedstockTakeWrapperList      { get; set; }
        @AuraEnabled public ERP7__Stock_Take__c StockTakeRec                         { get; set; }
        @AuraEnabled public Employees__c Employee                                    { get; set; }
        @AuraEnabled public List<pickOptions> channelSites                           { get; set; }
        @AuraEnabled public List<pickOptions> statusOption                           { get; set; }
        @AuraEnabled public String selectedSite                                      { get; set; }
        @AuraEnabled public String ChannelName                                       { get; set; } 
        @AuraEnabled public String SiteName                                          { get; set; }
        @AuraEnabled public String exceptionError                                    { get; set; }
        
        @AuraEnabled public List<Integer> PNS                                        { get; set; }
        @AuraEnabled public Integer startCount                                       { get; set; }
        @AuraEnabled public Integer endCount                                         { get; set; }
        @AuraEnabled public Integer Offset                                           { get; set; }
        @AuraEnabled public Integer recSize                                          { get; set; }
        @AuraEnabled public Integer PageNum                                          { get; set; }
        @AuraEnabled public Integer show                                             { get; set; }
        @AuraEnabled public Boolean displayStockAddress                         	 { get; set; }
         @AuraEnabled public Boolean showVendorCode									 { get; set; }
        @AuraEnabled public Boolean displayAudit                        			 { get; set; }
        @AuraEnabled public Boolean showProdCode                        { get; set; }
        @AuraEnabled public Boolean showAdjustedQty                     { get; set; }
        @AuraEnabled public Boolean showApprover                        { get; set; }
        @AuraEnabled public List<pickOptions> stockOutwardStatus                        { get; set; }
        @AuraEnabled public List<pickOptions> stockInwardReason                        { get; set; }
        @AuraEnabled public List<pickOptions> stAudit                        { get; set; }
        
        
        public defaultWrapper() {
            displayStockAddress = displayAudit = showProdCode = showApprover = showVendorCode = false;
            stockTakeWrapperList = new List<stockTakeWrapper>();
             allstockTakeWrapperList = new List<stockTakeWrapper>();
            adjustedstockTakeWrapperList = new List<stockTakeWrapper>();
            StockTakeRec = new ERP7__Stock_Take__c();
            Employee = new Employees__c();
            channelSites = new List<pickOptions>();
            statusOption = new List<pickOptions>();
            selectedSite = '';
            ChannelName = '';
            SiteName = '';
            exceptionError = '';
            PNS = new List<Integer>();
            startCount = endCount = Offset = recSize = PageNum = 0;
            show = 25;
            stockOutwardStatus = stockInwardReason = stAudit = new List<pickOptions>();
            showAdjustedQty = true;
        }
    }
    
    public class stockTakeWrapper{
        @AuraEnabled public Boolean showSelected                                       { get; set; }
        @AuraEnabled public ERP7__Stock_Take_Line_Item__c stockTakeLineItem            { get; set; }
        @AuraEnabled Public List<ERP7__Stock_Inward_Line_Item__c>  stockInWardList     { get; set; }
        @AuraEnabled Public List<ERP7__Stock_Outward_Line_Item__c>  stockOutWardList   { get; set; }
        @AuraEnabled public Integer recSize                                            { get; set; }
        @AuraEnabled public String stliProdCodeSKU                                       { get; set; }
        @AuraEnabled public String inventoryLocation						{ get; set; }
        @AuraEnabled public Boolean isScanned                                       { get; set; }
        
        public stockTakeWrapper(){
            showSelected  = true;
            stockTakeLineItem = new ERP7__Stock_Take_Line_Item__c();
            stockInWardList = new List<ERP7__Stock_Inward_Line_Item__c>();
            stockOutWardList = new List<ERP7__Stock_Outward_Line_Item__c>();
            recSize = 0;
            stliProdCodeSKU = '';
            inventoryLocation = '';
            isScanned = false;
        }
    }
    
    public class pickOptions {
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public String label     { get; set; } @AuraEnabled public Boolean selected { get; set; }
        
        public pickOptions(String val, string lab) { value = val; label = lab; } public pickOptions(String val, string lab, Boolean sel) { value = val; label = lab; selected = sel; }
    }
}