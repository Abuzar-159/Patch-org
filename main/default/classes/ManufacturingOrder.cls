public with sharing class ManufacturingOrder {
    
    @AuraEnabled //(Cacheable = true) // did fls changes for  get all method on 17.6.2025
    public static comWrap getAll(String vmoy,Boolean applyLimit,Boolean ShowAllWO) {   
        comWrap comW = new comWrap();  
        try{    
            system.debug('getAll called');
            
            String AllTaskFields ='Id,Name, ERP7__Type__c,ERP7__Work_Center__r.Name, ERP7__Work_Center__r.ERP7__Supervisor__c, ERP7__Work_Center__r.ERP7__Supervisor__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Is_Signature_Required__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c, ERP7__Operation__r.ERP7__Sort__c, ERP7__Reviewed_By__r.Name,ERP7__Status__c,ERP7__Finished_Quantity__c,Auto_Clock_In__c,Start_Date__c,End_Date__c ';
            String TSFields = UtilClass.selectStarFromSObject('ERP7__Timesheet__c');
            String AllTSFields = TSFields + ''; 
            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
            String ProductFields = UtilClass.selectStarFromSObject('Product2');
            String AllProductFields = ProductFields + '';
            String RoutingFields = UtilClass.selectStarFromSObject('ERP7__Routing__c');
            String AllRoutingFields = RoutingFields + '';
            String VersionFields = UtilClass.selectStarFromSObject('ERP7__Version__c');
            String AllVersionFields = VersionFields + '';
            
            Schema.DescribeFieldResult fieldResult = ERP7__Manufacturing_Order__c.ERP7__Status__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f: ple) {
                comW.moStatus.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            
            if(vmoy != '' && vmoy != Null){
                system.debug('inhere vmoy~>'+vmoy);
                
                comW.manuOrders = Database.query('SELECT Id,Name,ERP7__End_Date__c,ERP7__Manufacturing_Order__c,ERP7__Product__r.ERP7__Quality_Check_QA__c,ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c,ERP7__Product__r.ERP7__UoM__c,ERP7__Routing__c,ERP7__Routing__r.ERP7__Max_Allowed_Cuts__c,ERP7__Routing__r.Name,ERP7__Routing__r.ERP7__Raw_Materials_Site__c,ERP7__Routing__r.ERP7__Auto_Stock_Allocation__c,ERP7__Manufacturing_Order__r.Name,ERP7__Quantity__c,ERP7__Version__c,ERP7__Version__r.Name,ERP7__Status__c,ERP7__StartDate__c,ERP7__ExpectedDate__c,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name,ERP7__Order_Product__c,ERP7__Order_Product__r.OrderItemNumber,ERP7__Sales_Order_Line_Item__c,ERP7__Sales_Order_Line_Item__r.Name,ERP7__Labour_Cost__c,ERP7__Material_Cost__c,ERP7__Overhead_Cost__c,ERP7__Cost__c,ERP7__Scrap_Cost__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Rejected_Cost__c FROM ERP7__Manufacturing_Order__c WHERE Id = :vmoy Limit 1');
                
                Map<String,ERP7__Manufacturing_Order__c> prodMRPsMoMap = new Map<String,ERP7__Manufacturing_Order__c>();
                
                for(ERP7__Manufacturing_Order__c cMO : Database.query('SELECT Id,Name,ERP7__Routing__c,ERP7__Routing__r.Name,ERP7__Routing__r.ERP7__Raw_Materials_Site__c,ERP7__Manufacturing_Order__c,ERP7__Routing__r.ERP7__Auto_Stock_Allocation__c,ERP7__Manufacturing_Order__r.Name,ERP7__Quantity__c,ERP7__Version__c,ERP7__Version__r.Name,ERP7__Status__c,ERP7__StartDate__c,ERP7__ExpectedDate__c,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name,ERP7__Order_Product__c,ERP7__Sales_Order_Line_Item__c,ERP7__Labour_Cost__c,ERP7__Material_Cost__c,ERP7__Overhead_Cost__c,ERP7__Cost__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c FROM ERP7__Manufacturing_Order__c WHERE ERP7__Manufacturing_Order__c = :vmoy ')){
                    if(cMO.ERP7__Product__c != null && cMO.ERP7__MRP_Material_Requirement_Planning__c != null){
                        String key = ''+cMO.ERP7__Product__c+cMO.ERP7__MRP_Material_Requirement_Planning__c+'';
                        prodMRPsMoMap.put(key, cMO);
                    }
                }
                
                List<ERP7__MRP__c> MRPs = [Select Id, Name,ERP7__BOM_unit_Price__c, ERP7__BOM__r.ERP7__Cost_Price__c, ERP7__Total_Amount_Required__c, ERP7__BOM__c,toLabel( ERP7__BOM__r.ERP7__Unit_of_Measure__c), ERP7__BOM__r.Name, ERP7__BOM__r.ERP7__BOM_Version__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ProductCode,ERP7__MRP_Product__r.ERP7__Vendor_product_Name__c,ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c,ERP7__Order_Product__c , Sales_Order_Line_Item__c, RecordType.Name, ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c, ERP7__BOM__r.ERP7__Exact_Quantity__c, 
                                           ERP7__Work_Order__c, ERP7__Work_Order__r.Name, ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__MO__r.ERP7__Version__c,ERP7__MO__r.ERP7__Quantity__c, ERP7__Fulfilled_Amount__c, ERP7__BOM__r.ERP7__Is_Protected__c, ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__MRP_Product__r.ERP7__Issue_Purchase_Order__c, ERP7__MRP_Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__Status__c, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c,
                                           ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c, ERP7__BOM__r.ERP7__Product_Feature__c, ERP7__BOM__r.ERP7__Product_Feature__r.Name, 
                                           toLabel(ERP7__MRP_Product__r.QuantityUnitOfMeasure), ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c
                                           From ERP7__MRP__c Where ERP7__MO__c = :vmoy Order By ERP7__Work_Order__c ASC]; //ERP7__BOM__r.ERP7__Product_Feature__c, ERP7__BOM__r.ERP7__Sort__c,
                
                system.debug('MRPs~>'+MRPs.size());
                Map<Id,Integer> WOMRPCount = new Map<Id,Integer>();
                List<ERP7__MRP__c> feature_MRPs = new List<ERP7__MRP__c>(); 
                for(ERP7__MRP__c MRP : MRPs) if(MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null || MRP.ERP7__BOM__r.ERP7__Product_Feature__c == Null) feature_MRPs.add(MRP);
                //for(ERP7__MRP__c MRP : MRPs) if(MRP.ERP7__BOM__r.ERP7__Product_Feature__c == Null) feature_MRPs.add(MRP);
                MRPs = feature_MRPs;
                feature_MRPs = new List<ERP7__MRP__c>(); 
                //Added code by shguftha to get batch No only when product is not serialized
                List<ERP7__Stock_Outward_Line_Item__c> SOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
                if(!comW.manuOrders.ERP7__Product__r.ERP7__Serialise__c){
                    SOLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__BoM__r.ERP7__Quantity__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Date_of_Manufacture__c,  ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
                             ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name
                             From Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c In: MRPs AND ERP7__MRP_Material_Requirements_Planning__c != null];
                    
                }
                /* List<ERP7__Stock_Outward_Line_Item__c> SOLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Date_of_Manufacture__c,  ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name
From Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c In: MRPs AND ERP7__MRP_Material_Requirements_Planning__c != null];     
List<Id> SerialIds = new List<Id>();
List<Id> BatchIds = new List<Id>();

Map<String,List<ERP7__Stock_Outward_Line_Item__c>> MrpSOLIMap = new Map<String,List<ERP7__Stock_Outward_Line_Item__c>>();
Map<String,Decimal> MrpSOLIQtyMap = new Map<String,Decimal>();
Map<String,List<ERP7__Serial_Number__c>> MrpSOLISerialsMap = new Map<String,List<ERP7__Serial_Number__c>>();
Map<String,List<ERP7__Batch__c>> MrpSOLIBatchsMap = new Map<String,List<ERP7__Batch__c>>();

List<ERP7__Stock_Outward_Line_Item__c> tempSOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
for(ERP7__Stock_Outward_Line_Item__c soli : SOLIs){
if(soli.ERP7__Serial__c != Null) SerialIds.add(soli.ERP7__Serial__c);
if(soli.ERP7__Material_Batch_Lot__c != Null) BatchIds.add(soli.ERP7__Material_Batch_Lot__c);

tempSOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
if(MrpSOLIMap.containsKey(soli.ERP7__MRP_Material_Requirements_Planning__c)) tempSOLIs = MrpSOLIMap.get(soli.ERP7__MRP_Material_Requirements_Planning__c);
tempSOLIs.add(soli);
MrpSOLIMap.put(soli.ERP7__MRP_Material_Requirements_Planning__c, tempSOLIs);
//changed from multiple loops to one
Decimal qty = 0;
if(MrpSOLIQtyMap.containsKey(soli.ERP7__MRP_Material_Requirements_Planning__c)) qty = MrpSOLIQtyMap.get(soli.ERP7__MRP_Material_Requirements_Planning__c);
qty += soli.ERP7__Quantity__c;
MrpSOLIQtyMap.put(soli.ERP7__MRP_Material_Requirements_Planning__c,qty);
if(soli.ERP7__Serial__c != Null) {
//   if(SerialMap.containsKey(soli.ERP7__Serial__c)){
List<ERP7__Serial_Number__c> tempSerials = new List<ERP7__Serial_Number__c>();
if(MrpSOLISerialsMap.containsKey(soli.ERP7__MRP_Material_Requirements_Planning__c)) tempSerials = MrpSOLISerialsMap.get(soli.ERP7__MRP_Material_Requirements_Planning__c);
tempSerials.add(new ERP7__Serial_Number__c(Id = soli.ERP7__Serial__c,Name = soli.ERP7__Serial__r.Name,ERP7__Date_of_Manufacture__c = soli.ERP7__Serial__r.ERP7__Date_of_Manufacture__c));
MrpSOLISerialsMap.put(soli.ERP7__MRP_Material_Requirements_Planning__c, tempSerials);
// }
}

if(soli.ERP7__Material_Batch_Lot__c != Null) {
// if(BatchMap.containsKey(soli.ERP7__Material_Batch_Lot__c)){ 
List<ERP7__Batch__c> tempBatchs = new List<ERP7__Batch__c>();
if(MrpSOLIBatchsMap.containsKey(soli.ERP7__MRP_Material_Requirements_Planning__c)) tempBatchs = MrpSOLIBatchsMap.get(soli.ERP7__MRP_Material_Requirements_Planning__c);
tempBatchs.add(new ERP7__Batch__c(Id = soli.ERP7__Material_Batch_Lot__c,Name = soli.ERP7__Material_Batch_Lot__r.Name));
MrpSOLIBatchsMap.put(soli.ERP7__MRP_Material_Requirements_Planning__c, tempBatchs);
// }
}

}
tempSOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
SOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
system.debug('0 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());


// String allFields = UtilClass.selectStarFromSObject('ERP7__Serial_Number__c');
// String allFields = 'Id ,Name, ERP7__Serial_Number__c,ERP7__Date_of_Manufacture__c,ERP7__Availability_date__c,ERP7__Shelf_Life_Expiration_Date__c,ERP7__Cost_Price__c,ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Product__r.Name,ERP7__Product__r.Barcode__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ';
//  String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Serial_Number__c where Id In :SerialIds';
// Map<Id,ERP7__Serial_Number__c> SerialMap = new Map<Id,ERP7__Serial_Number__c>([Select Id ,Name, ERP7__Serial_Number__c,ERP7__Date_of_Manufacture__c,ERP7__Availability_date__c,ERP7__Shelf_Life_Expiration_Date__c,ERP7__Cost_Price__c,ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Product__r.Name,ERP7__Product__r.Barcode__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c from ERP7__Serial_Number__c where Id In :SerialIds]); 

//List<ERP7__Serial_Number__c> SerialNos = Database.query(query);

// Map<Id, List<ERP7__Batch__c>> lineBatches = new Map<Id, List<ERP7__Batch__c>>();
//  Map<Id, ERP7__Batch__c> BatchNumber = new Map<Id, ERP7__Batch__c>();
//String allFields1 = UtilClass.selectStarFromSObject('ERP7__Batch__c');
//  String allFields1 = 'Id,Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.Barcode__c ';
//  String query1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__Batch__c where Id In :BatchIds';
//  Map<Id,ERP7__Batch__c> BatchMap = new Map<Id,ERP7__Batch__c>([Select Id,Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.Barcode__c from ERP7__Batch__c where Id In :BatchIds]);
// List<ERP7__Batch__c> Batches = Database.query(query1);

system.debug('01 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());



/*   for(ERP7__Stock_Outward_Line_Item__c soli : SOLIs){
Decimal qty = 0;
if(MrpSOLIQtyMap.containsKey(soli.ERP7__MRP_Material_Requirements_Planning__c)) qty = MrpSOLIQtyMap.get(soli.ERP7__MRP_Material_Requirements_Planning__c);
qty += soli.ERP7__Quantity__c;
MrpSOLIQtyMap.put(soli.ERP7__MRP_Material_Requirements_Planning__c,qty);

if(soli.ERP7__Serial__c != Null) {
if(SerialMap.containsKey(soli.ERP7__Serial__c)){
List<ERP7__Serial_Number__c> tempSerials = new List<ERP7__Serial_Number__c>();
if(MrpSOLISerialsMap.containsKey(soli.ERP7__MRP_Material_Requirements_Planning__c)) tempSerials = MrpSOLISerialsMap.get(soli.ERP7__MRP_Material_Requirements_Planning__c);
tempSerials.add(SerialMap.get(soli.ERP7__Serial__c));
MrpSOLISerialsMap.put(soli.ERP7__MRP_Material_Requirements_Planning__c, tempSerials);
}
}

if(soli.ERP7__Material_Batch_Lot__c != Null) {
if(BatchMap.containsKey(soli.ERP7__Material_Batch_Lot__c)){ 
List<ERP7__Batch__c> tempBatchs = new List<ERP7__Batch__c>();
if(MrpSOLIBatchsMap.containsKey(soli.ERP7__MRP_Material_Requirements_Planning__c)) tempBatchs = MrpSOLIBatchsMap.get(soli.ERP7__MRP_Material_Requirements_Planning__c);
tempBatchs.add(BatchMap.get(soli.ERP7__Material_Batch_Lot__c));
MrpSOLIBatchsMap.put(soli.ERP7__MRP_Material_Requirements_Planning__c, tempBatchs);
}
}

}*/
                
                Set<Id> proIds = new Set<Id>();
                Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
                for(MRP__c mrp : MRPS){
                    if(mrp.ERP7__MRP_Product__c != Null) proIds.add(mrp.ERP7__MRP_Product__c);
                    if(mrp.ERP7__Work_Order__c != null) {
                        WOMRPCount.put(mrp.ERP7__Work_Order__c,0);
                        if(WOMRPCount.containsKey(mrp.ERP7__Work_Order__c)) {
                            WOMRPCount.put(mrp.ERP7__Work_Order__c,WOMRPCount.get(mrp.ERP7__Work_Order__c) + 1);
                        }
                    }
                }
                String selectedSite = comW.manuOrders.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                String finishedProduct = comW.manuOrders.ERP7__Product__c;
                
                if(selectedSite != Null && selectedSite != ''){
                    for(AggregateResult result: [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock  FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c = :selectedSite 
                                                 And 
                                                 (ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 And Name = 'Serial Stock Holder')) //change shaguftha on 14_10_24
                                                 and ERP7__Product__c IN:proIds GROUP BY ERP7__Product__c]){
                        Decimal myStock = 0;
                        Id ProdId = (Id)result.get('ERP7__Product__c');
                        if(stockMap.containsKey(ProdId)) myStock = stockMap.get(ProdId);
                        myStock +=(Decimal)result.get('totalStock'); 
                        stockMap.put(ProdId,myStock);
                    }
                }
                
                comW.UOMCs = [Select MasterLabel, QualifiedApiName, DeveloperName,ERP7__From_UOM__c, ERP7__From_Value__c,ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 1000];
                List<mrpWrap> mrpWrapList = new List<mrpWrap>();
                
                system.debug('1 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                
               
                for(Integer i=0; i<MRPs.size(); i++){
                    ERP7__MRP__c MRP = MRPs[i];
                    mrpWrap mrpWraper = new mrpWrap();
                    
                    mrpWraper.MRP = MRP;
                    
                    if((i == 0 && MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null) || (i > 0 && MRP.ERP7__BOM__r.ERP7__Product_Feature__c != MRPs[i-1].ERP7__BOM__r.ERP7__Product_Feature__c)){
                        if(MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null){
                            mrpWraper.Feature.Id = MRP.ERP7__BOM__r.ERP7__Product_Feature__c; 
                            mrpWraper.Feature.Name = MRP.ERP7__BOM__r.ERP7__Product_Feature__r.Name; 
                        } else mrpWraper.Feature.Name = ''; 
                    } 
                    
                    if(stockMap.containsKey(MRP.ERP7__MRP_Product__c)) mrpWraper.Stock = stockMap.get(MRP.ERP7__MRP_Product__c).setscale(4); //changed the sectscale from 2 to 4 11_01_24 Shaguftha
                    
                    if(mrpWraper.Stock == 0) mrpWraper.bgColor = 'red-s';
                    else if(mrpWraper.Stock > 0 && mrpWraper.Stock < mrpWraper.MRP.ERP7__Total_Amount_Required__c) mrpWraper.bgColor = 'orange';
                    else if(mrpWraper.Stock > 0 && mrpWraper.Stock >= mrpWraper.MRP.ERP7__Total_Amount_Required__c) { 
                        mrpWraper.bgColor = 'green'; 
                        if(mrpWraper.MRP.ERP7__Fulfilled_Amount__c < mrpWraper.MRP.ERP7__Total_Amount_Required__c && mrpWraper.MRP.ERP7__Status__c == 'Requested') {  comW.ReserveStock = true;}
                        system.debug('mrpWraper.MRP.ERP7__Status__c : '+mrpWraper.MRP.ERP7__Status__c);
                        //if(mrpWraper.MRP.ERP7__Fulfilled_Amount__c == mrpWraper.MRP.ERP7__Total_Amount_Required__c){  comW.ReserveStock = false;}  
                    }
                    
                    //Changed by Arshad 05 Sep 2023
                    if(MRP.ERP7__MRP_Product__c != null && MRP.Id != null){
                        String Key = ''+MRP.ERP7__MRP_Product__c+MRP.Id+'';
                        if(prodMRPsMoMap.containsKey(Key)){
                            mrpWraper.MO = prodMRPsMoMap.get(Key);
                        }
                    }
                  
                    set<Id> batchIds = new set<Id>();
                    System.debug('SOLIs : '+SOLIs.size());
                    if(SOLIs.size() > 0){
                        for(ERP7__Stock_Outward_Line_Item__c soli : SOLIs){
                            if(MRP.Id == soli.ERP7__MRP_Material_Requirements_Planning__c){
                                // if(soli.ERP7__Serial__c != Null) { if(!mrpWraper.SerialNos.contains(SerialMap.get(soli.ERP7__Serial__c))) mrpWraper.SerialNos.add(SerialMap.get(soli.ERP7__Serial__c)); }
                                if(soli.ERP7__Material_Batch_Lot__c != Null && !batchIds.contains(soli.ERP7__Material_Batch_Lot__c)) {  mrpWraper.Batches.add(new ERP7__Batch__c(Id=soli.ERP7__Material_Batch_Lot__c,Name=soli.ERP7__Material_Batch_Lot__r.Name)); batchIds.add(soli.ERP7__Material_Batch_Lot__c); }
                            }
                        }
                    }
                    
                    
                    
                    if(MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c != Null) {
                        mrpWraper.SelectedUOM = MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                        mrpWraper.UOMS.add(new SelectOptions(mrpWraper.SelectedUOM, mrpWraper.SelectedUOM, true));
                        if(MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure != mrpWraper.SelectedUOM) mrpWraper.UOMS.add(new SelectOptions(MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure, MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure));
                    }
                    
                    if(MRP.ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c != null){
                        String UOMS = MRP.ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c;
                        List<String> arr = UOMS.split(';');
                        for(String str : arr){
                            if(str != mrpWraper.SelectedUOM && str != MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure) mrpWraper.UOMS.add(new SelectOptions(str, str));
                        }
                    } 
                     List<ERP7__Stock_Outward_Line_Item__c> mrpSOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
    for(ERP7__Stock_Outward_Line_Item__c soli : SOLIs){
        if(MRP.Id == soli.ERP7__MRP_Material_Requirements_Planning__c){
            mrpSOLIs.add(soli);
        }
    }
    mrpWraper.SOLIs = mrpSOLIs;
    
    // Calculate pagination
    calculatePagination(mrpWraper);
                    mrpWrapList.add(mrpWraper);
                }
                
                system.debug('2 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                
                comW.MRPs = mrpWrapList;
                
                //added by shaguftha on 06/09/2023
                mrpWrapList = new List<mrpWrap>();
                //MrpSOLIMap = new Map<String,List<ERP7__Stock_Outward_Line_Item__c>>();
                stockMap = new Map<ID,Decimal>();
                system.debug('3 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                
                if(comW.manuOrders.ERP7__Routing__r.ERP7__Auto_Stock_Allocation__c == false) comW.ReserveStock = false;
                comW.WOs = Database.query('SELECT Id,Name,ERP7__End_Date__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Product__r.ERP7__UoM__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Quantity_Built__c,ERP7__Quantity_Ordered__c,ERP7__Code__c,ERP7__Work_Center__c,ERP7__Work_Center__r.Id,ERP7__Work_Center__r.Name,ERP7__Start_Date__c,ERP7__ExpectedDate__c,ERP7__Lead_Time__c,toLabel(ERP7__Status__c) FROM ERP7__WO__c WHERE ERP7__MO__c = :vmoy');
                // comW.SOLIs = Database.query('SELECT Id,Name,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.Name,ERP7__MO_WO_Material_Batch_Lot__c,ERP7__MO_WO_Material_Batch_Lot__r.Name,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__MO_WO_Serial__c,ERP7__MO_WO_Serial__r.Name,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Manufacturing_Order__c = :vmoy');
                //  comW.SILIs = Database.query('SELECT Id,Name,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Version__c,ERP7__Version__r.Name,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Quantity__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.Name,ERP7__Location__c,ERP7__Location__r.Name,ERP7__Scrap__c,ERP7__Work_Order__c,ERP7__Work_Order__r.Name,ERP7__WIP_Flow__c FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__Manufacturing_Order__c = :vmoy Order BY CreatedDate Asc'); // AND ERP7__Product__c = :finishedProduct
                
                system.debug('4 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                
                // String querySN = 'select ' + String.escapeSingleQuotes(allFields) + ' ,Barcode__c from ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c = :vmoy';
                // String wpquery = 'select Id,Name from ERP7__WIP__c where ERP7__MO__c = :vmoy';
                // List<ERP7__WIP__c> wips = Database.query(wpquery);
                String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP_Flow__c');
                wpallFields += ' , ERP7__Product__r.Name, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Work_Orders__r.Name, ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c ,ERP7__Work_Orders__r.ERP7__Quantity_Scrapped__c,ERP7__Product__r.ERP7__UoM__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Version__r.Name,ERP7__WIP__r.Name,ERP7__WIP__r.ERP7__Material_Batch_Lot__c,ERP7__WIP__r.ERP7__Material_Batch_Lot__r.Name,ERP7__WIP__r.ERP7__Serial_Number__c,ERP7__WIP__r.ERP7__Serial_Number__r.Name';
                string wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP_Flow__c where ERP7__WIP__r.ERP7__MO__c   = :vmoy limit 100';
                List<ERP7__WIP_Flow__c> wipflows =  Database.query(wpquery);
                comW.wipflowsLength = (Integer)[SELECT COUNT(Id) total FROM ERP7__WIP_Flow__c WHERE ERP7__WIP__r.ERP7__MO__c = :vmoy][0].get('total');
                
                //Added by Arshad 05 Sep 2023
                // wips = new List<ERP7__WIP__c>();
                wpallFields = '';
                wpquery  = '';
                //comW.wipflows = Database.query(wpquery);
                /* if(applyLimit && wipflows.size() > 2000){
comw.totalWips = wipflows.size();
List<ERP7__WIP_Flow__c> limitedWipflows = new List<ERP7__WIP_Flow__c>();
for(Integer i= 0;i <=2000; i++) limitedWipflows.add(wipflows[i]);
comW.wipflows = limitedWipflows;
}else*/
                comW.wipflows = wipflows;
                
                //Added by Arshad 05 Sep 2023
                wipflows = new List<ERP7__WIP_Flow__c>();
                
                system.debug('5 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                
                List<ERP7__Serial_Number__c> MOserialNos = Database.query('select Id ,Name, ERP7__Serial_Number__c,ERP7__Date_of_Manufacture__c,ERP7__Availability_date__c,ERP7__Shelf_Life_Expiration_Date__c,ERP7__Cost_Price__c,ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Product__r.Name,ERP7__Product__r.Barcode__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ,Barcode__c ,ERP7__Scrap__c,ERP7__Available__c from ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c = :vmoy limit 100');
                /*if(applyLimit && MOserialNos.size() > 2000){ 
comw.totalSerials = MOserialNos.size();
List<ERP7__Serial_Number__c> limitedWipflows = new List<ERP7__Serial_Number__c>();
for(Integer i= 0;i <2000; i++) limitedWipflows.add(MOserialNos[i]);
comW.moSerialNos = limitedWipflows;
} else*/ comW.moSerialNos = MOserialNos;
                comW.serialsLength= (Integer)[SELECT COUNT(Id) total FROM ERP7__Serial_Number__c WHERE ERP7__Manufacturing_Order__c  = :vmoy][0].get('total');
                
                //Added by Arshad 05 Sep 2023
                MOserialNos = new List<ERP7__Serial_Number__c>();
                
                system.debug('6 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                
                List< ERP7__Purchase_Requisition_Line_Items__c > PRQLIS = [Select Id, Name, ERP7__Purchase_Requisition__c from ERP7__Purchase_Requisition_Line_Items__c Where ERP7__MRP__c In :MRPs Or ERP7__MRP__r.ERP7__Work_Order__r.ERP7__MO__c =: vmoy];
                Set<Id> PRIds = new Set<Id>();
                for(ERP7__Purchase_Requisition_Line_Items__c PRq : PRQLIS){ if(PRq.ERP7__Purchase_Requisition__c != Null) PRIds.add(PRq.ERP7__Purchase_Requisition__c); }
                
                comW.PRS = [Select Id, Name, ERP7__Purchase_Orders__c, ERP7__Manufacturing_Order__c, ERP7__Work_Order__c, ERP7__Work_Order__r.ERP7__MO__c From ERP7__Requisition__c Where ERP7__Manufacturing_Order__c =: vmoy Or ERP7__Work_Order__r.ERP7__MO__c =: vmoy OR Id In :PRIds ];
                List< ERP7__Purchase_Line_Items__c > PRLIS = [Select Id, Name, ERP7__Purchase_Orders__c from ERP7__Purchase_Line_Items__c Where ERP7__MRP_Material_Requirements_Planning__c In :MRPs Or ERP7__MRP_Material_Requirements_Planning__r.ERP7__Work_Order__r.ERP7__MO__c =: vmoy];
                Set<Id> POIds = new Set<Id>();
                
                for(ERP7__Purchase_Line_Items__c PR : PRLIS){ if(PR.ERP7__Purchase_Orders__c != Null) POIds.add(PR.ERP7__Purchase_Orders__c); }
                
                comW.POS = [Select Id, Name, ERP7__Total_Quantity__c, ERP7__Reconciled_Quantity__c, ERP7__Inbound_Total_Quantity__c, ERP7__Inbound_Received_Quantity__c From ERP7__PO__c Where Id In : POIds];
                //String queryBT = 'select ' + String.escapeSingleQuotes(allFields1) + ',Barcode__c from ERP7__Batch__c where ERP7__Manufacturing_Order__c = :vmoy';
                comW.moBatchNos = Database.query('select Id,Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.Barcode__c ,Barcode__c,Date_of_Manufacture__c from ERP7__Batch__c where ERP7__Manufacturing_Order__c = :vmoy');
                
                //Additional code for MO Traveller
                Set<Id> woIds = new Set<Id>();
                for(WO__c WO : comW.WOs){ woIds.add(WO.Id); WOWrap WOW = new WOWrap(); WOW.WorkOrder = WO;
                                         if(ShowAllWO == false)  {
                                             if(WOMRPCount.containsKey(WO.Id)) comW.WOWS.add(WOW);
                                         }
                                         else  comW.WOWS.add(WOW);
                                        }
                
                Map<Id, List<ERP7__Actions_Tasks__c>> WOTasks = new Map<Id, List<ERP7__Actions_Tasks__c>>();
                Map<Id, List<ERP7__Time_Card_Entry__c>> WOTCEs = new Map<Id, List<ERP7__Time_Card_Entry__c>>();
                Map<Id, List<ERP7__Resource_Allocation__c>> WORAs = new Map<Id, List<ERP7__Resource_Allocation__c>>();
                
                List<ERP7__Actions_Tasks__c> Tasks = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c = :woIds Order By ERP7__Operation__r.ERP7__Sort__c ASC limit 1000');
                List<ERP7__Time_Card_Entry__c> TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :woIds Order BY CreatedDate Desc limit 1000');
                // String wcFields = UtilClass.selectStarFromSObject('ERP7__Resource_Allocation__c');
                
                String wcFields = 'Id,Name,Type__c,Start_Date__c,End_Date__c,Hours__c, ERP7__Resource_Group__r.Name, ERP7__Employees__r.Name, ERP7__Machine__r.Name ';
               // utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Allocation__c');  
                String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource_Allocation__c Where ERP7__Work_Order__c = :woIds Order by CreatedDate Asc limit 1000';
                List< ERP7__Resource_Allocation__c > RAS = Database.query(query);
                
                for(ERP7__Actions_Tasks__c Task : Tasks){
                    if(WOTasks.containsKey(Task.ERP7__Work_Order__c)) WOTasks.get(Task.ERP7__Work_Order__c).add(Task);
                    else WOTasks.put(Task.ERP7__Work_Order__c, new List<ERP7__Actions_Tasks__c>{Task});
                }
                for(ERP7__Time_Card_Entry__c TCE : TimeCardEntries ){
                    if(WOTCEs.containsKey(TCE.ERP7__Timesheet__r.ERP7__Work_Order__c)) WOTCEs.get(TCE.ERP7__Timesheet__r.ERP7__Work_Order__c).add(TCE);
                    else WOTCEs.put(TCE.ERP7__Timesheet__r.ERP7__Work_Order__c, new List<ERP7__Time_Card_Entry__c>{TCE});
                }
                for(ERP7__Resource_Allocation__c RA : RAS){
                    if(WORAs.containsKey(RA.ERP7__Work_Order__c)) WORAs.get(RA.ERP7__Work_Order__c).add(RA);
                    else WORAs.put(RA.ERP7__Work_Order__c, new List<ERP7__Resource_Allocation__c>{RA});
                }
                for(WOWrap WOW : comW.WOWS){
                    WOW.Tasks = WOTasks.get(WOW.WorkOrder.Id);
                    WOW.TimeCardEntries = WOTCEs.get(WOW.WorkOrder.Id);
                    WOW.RAS = WORAs.get(WOW.WorkOrder.Id);
                }
                
                List<Attachment> Attachments = [Select Id, Name, ParentId, Owner.Name, CreatedDate From Attachment Where ParentId =: vmoy And Name = 'Signature' Order By CreatedDate Asc];
                if(Attachments.size() > 0) comW.Attachment = Attachments[0];
                
                comW.SelectedAttachments = [Select Id, Name, ParentId, Owner.Name, CreatedDate From Attachment Where ParentId =: vmoy And Name = 'Signature' Order By CreatedDate Asc];
                comW.Product = new Product2(Id=comW.manuOrders.ERP7__Product__c, Name=comW.manuOrders.ERP7__Product__r.Name);
                comW.Routing = new ERP7__Routing__c(Id=comW.manuOrders.ERP7__Routing__c, Name=comW.manuOrders.ERP7__Routing__r.Name,ERP7__Max_Allowed_Cuts__c = comW.manuOrders.ERP7__Routing__r.ERP7__Max_Allowed_Cuts__c);
                comW.Version = new ERP7__Version__c(Id=comW.manuOrders.ERP7__Version__c, Name=comW.manuOrders.ERP7__Version__r.Name);
                
                /* Visibility Control */
                ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
                
                if(FC == null){ 
                    FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
                }
                if(FC != null){
                    if(!FC.ERP7__Manufacturing_Is_Console_Editable__c) comW.isEditable = false;
                    else if(comW.manuOrders.ERP7__Status__c == 'Complete') comW.isEditable = false;
                    comW.showCosts = FC.ERP7__Manufacturing_Console_Show_Costs__c;
                    comW.linksNewOptions = FC.ERP7__Manufacturing_Links_New_Options__c;
                    comW.showAutoStockAllocation = FC.ERP7__MO_AutoStockAllocation__c;
                    comW.showManualStockAllocation = FC.ERP7__MO_ManualStockAllocation__c;
                    comW.allowMultiPos = FC.ERP7__Allow_Multi_POs_from_Manufacturing_order__c;
                    comW.isStandardOrder = FC.ERP7__Is_Standard_Order__c;
                    comW.ShowCustomSerailNumberGeneration = FC.ERP7__Show_Custom_generation_of_serial_numbers__c;
                    comW.ShowLangOptionForTraveller= FC.ERP7__ShowLangOptionForTraveller__c;
                    comW.ReplaceTravellerOrgURL= FC.ERP7__Replace_Traveller_OrgURL__c;
                    comW.ShowProdStatus = FC.ERP7__Show_Production_Status_Traveller__c;
                    comW.showVendorCode = FC.ERP7__Show_Vendor_Product_Code__c;
                    comW.showScrapDetails = FC.ERP7__Hide_Scrap_and_Waste_in_MO_and_WO__c;
                    comW.showMOLabels = FC.ERP7__show_Manufacturing_label__c;
                    comW.AllowMRPDelete = FC.ERP7__AllowMRPDeleteinMO__c;
                    comW.enableQA = FC.ERP7__Enable_QA_in_Manufacturing_process__c;
                    comW.PreventStatusEdit = FC.ERP7__Prevent_Status_edit_after_Receiving__c;
                    comW.showUplaodforItems = FC.ERP7__Show_upload_for_each_item_in_Receive__c;
                    if(FC.ERP7__hide_purchase_requisition_in_MO__c) comW.showRequisition = false; else comW.showRequisition = true;
                }
                
            } 
            
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); }
        return comW;
    }
    private static void calculatePagination(mrpWrap mrpW) {
    if(mrpW.SOLIs == null || mrpW.SOLIs.isEmpty()) {
        mrpW.pagedSOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
        mrpW.totalPages = 1;
        mrpW.currentPage = 1;
        mrpW.displayPages = new List<Integer>();
        mrpW.pageInfo = 'Showing 0 to 0 of 0 records';
        return;
    }
    
    // Ensure current page is valid
    if(mrpW.currentPage < 1) mrpW.currentPage = 1;
    
    // Calculate total pages
    mrpW.totalPages = (Integer)Math.ceil((Decimal)mrpW.SOLIs.size() / mrpW.pageSize);
    if(mrpW.currentPage > mrpW.totalPages) {
        mrpW.currentPage = mrpW.totalPages;
    }
    
    // Calculate paged data
    Integer startIndex = (mrpW.currentPage - 1) * mrpW.pageSize;
    Integer endIndex = Math.min(startIndex + mrpW.pageSize, mrpW.SOLIs.size());
    
    mrpW.pagedSOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
    if(startIndex < mrpW.SOLIs.size()) {
        for(Integer i = startIndex; i < endIndex; i++) {
            mrpW.pagedSOLIs.add(mrpW.SOLIs[i]);
        }
    }
    
    // Calculate page numbers to display
    Integer maxPagesToShow = 40;
    Integer startPage = Math.max(1, mrpW.currentPage - Math.floor(maxPagesToShow / 2).intValue());
    Integer endPage = Math.min(mrpW.totalPages, startPage + maxPagesToShow - 1);
    
    mrpW.displayPages = new List<Integer>();
    for(Integer pageNum = startPage; pageNum <= endPage; pageNum++) {
        mrpW.displayPages.add(pageNum);
    }
    
    // Create page info text
    Integer start = startIndex + 1;
    Integer end1 = endIndex;
    Integer total = mrpW.SOLIs.size();
    mrpW.pageInfo = 'Showing ' + start + ' to ' + end1 + ' of ' + total + ' records';
}
    @AuraEnabled
    public static List<SelectOptions> getInwardStatus(){
        List<SelectOptions> options = new List<SelectOptions>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Stock_Inward_Line_Item__c.ERP7__Status__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOptions(f.getValue(), f.getLabel()));
            //statusMap.put(f.getLabel(),f.getValue());
            //if(f.getValue() != 'Awaiting Stock') options.add(f.getValue()); 
        }
        if(options.size() > 0) return options;
        else return null;
    }
    @AuraEnabled
    public static comWrap SaveM(String MO){   
        ERP7__Manufacturing_Order__c MOs = (ERP7__Manufacturing_Order__c) JSON.deserialize(MO, ERP7__Manufacturing_Order__c .class);
        comWrap comW = new comWrap();
        try{
            if(MOs.ERP7__End_Date__c == Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__End_Date__c.isUpdateable()){ MOs.ERP7__End_Date__c = MOs.ERP7__ExpectedDate__c;}else{/*No access*/}
            // if(MOs.ERP7__Sales_Order__c != Null) MOs.ERP7__Sales_Order__c = MOs.ERP7__Sales_Order__c;
            // if(MOs.ERP7__Sales_Order_Line_Item__c != Null) MOs.ERP7__Sales_Order_Line_Item__c = MOs.ERP7__Sales_Order_Line_Item__c;
            if(Schema.sObjectType.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.isUpdateable()){upsert MOs;}else{comW.errorMsg ='Not allowed to upsert Manufacturing Order';}
            comW.manuOrders = MOs;
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
  @AuraEnabled
public static List<String> getAllreservedSerials(String productId) {
    List<String> list2return = new List<String>();
    system.debug('productId : ' + productId);
    
    if (productId != null && productId != '') {

        // Step 1: Get serials that have at least one Reserved SOLI for this product
        Set<String> serialsWithReservation = new Set<String>();

        for (AggregateResult ar : [
            SELECT ERP7__Serial__c
            FROM ERP7__Stock_Outward_Line_Item__c
            WHERE ERP7__Product__c = :productId
            AND ERP7__Serial__c != null
            AND ERP7__Status__c = 'Reserved'
            GROUP BY ERP7__Serial__c
            LIMIT 1000
        ]) {
            serialsWithReservation.add((String) ar.get('ERP7__Serial__c'));
        }

        system.debug('serialsWithReservation : ' + serialsWithReservation);

        if (!serialsWithReservation.isEmpty()) {

            // Step 2: From those serials, only exclude the ones where stock is 0
            for (ERP7__Inventory_Stock__c invStock : [
                SELECT ERP7__Serial__c
                FROM ERP7__Inventory_Stock__c
                WHERE ERP7__Serial__c IN :serialsWithReservation
                AND ERP7__Number_of_Item_In_Stock__c = 0
            ]) {
                if (invStock.ERP7__Serial__c != null) {
                    list2return.add(invStock.ERP7__Serial__c);
                }
            }
        }
    }

    system.debug('Serials to exclude (reserved + zero stock): ' + list2return);
    return list2return.size() > 0 ? list2return : null;
}
    
    
    @AuraEnabled
    public static comWrap SaveAllMRPs(String MRPs){   
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        comWrap comW = new comWrap();
        try{
            comW.errorMsg = '';
            List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();
            for(mrpWrap mrpWrapper : mrpWrappers){
                MRPs2Upsert.add(mrpWrapper.MRP);
            }
            if(MRPs2Upsert.size() > 0 && Schema.SObjectType.ERP7__MRP__c.isCreateable() && Schema.SObjectType.ERP7__MRP__c.isUpdateable()){ upsert MRPs2Upsert;}else{/*No access*/}
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static void deleteSerial(String RecId){
        ERP7__Serial_Number__c ser = [Select Id,Name from ERP7__Serial_Number__c where Id=:RecId limit 1];
        if(Schema.sObjectType.ERP7__Serial_Number__c.isDeletable())delete ser;
    }
    
    @AuraEnabled
    public static comWrap SaveSerial(String SerialNumber, String MO){   
        ERP7__Manufacturing_Order__c MOs = (ERP7__Manufacturing_Order__c) JSON.deserialize(MO, ERP7__Manufacturing_Order__c .class);
        ERP7__Serial_Number__c SlNumber = (ERP7__Serial_Number__c) JSON.deserialize(SerialNumber, ERP7__Serial_Number__c .class);
        comWrap comW = new comWrap();
        try{
            // if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isUpdateable()){
            SlNumber.ERP7__Warehouse__c = MOs.ERP7__Routing__r.ERP7__Finished_Products_Site__c;//}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Product__c.isUpdateable()){
            SlNumber.ERP7__Product__c = MOs.ERP7__Product__c;//}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Production_Version__c.isUpdateable()){
            SlNumber.ERP7__Production_Version__c = MOs.ERP7__Version__c;//}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){
            SlNumber.ERP7__Manufacturing_Order__c = MOs.Id;//}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Serial_Number__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.isUpdateable()){
            upsert SlNumber;//}else{ comW.errorMsg='not allowed to upsert';}
            comW.manuOrders = MOs;
            comW.errorMsg = '';
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap SaveBatch(String Batch, String MO){   
        ERP7__Manufacturing_Order__c MOs = (ERP7__Manufacturing_Order__c) JSON.deserialize(MO, ERP7__Manufacturing_Order__c .class);
        ERP7__Batch__c SlNumber = (ERP7__Batch__c) JSON.deserialize(Batch, ERP7__Batch__c .class);
        comWrap comW = new comWrap();
        try{
            if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Product__c.isUpdateable()){SlNumber.ERP7__Product__c = MOs.ERP7__Product__c;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Production_Version__c.isUpdateable()){SlNumber.ERP7__Production_Version__c = MOs.ERP7__Version__c;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SlNumber.ERP7__Manufacturing_Order__c = MOs.Id;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Batch__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.isUpdateable()){upsert SlNumber;}else{comW.errorMsg='Not allowed to upsert batch';}
            comW.manuOrders = MOs;
            comW.errorMsg = '';
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap MRPEdit(String MRP, String MRPs){   
        comWrap comWrapper = new comWrap();
        try{ 
            List<Id> bomIds = new List<Id>();
            mrpWrap mrpWrapper = (mrpWrap) JSON.deserialize(MRP, mrpWrap .class);
            List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
            for(mrpWrap mrrp : mrpWrappers){
                if(mrrp.MRP.ERP7__BOM__c != Null) bomIds.add(mrrp.MRP.ERP7__BOM__c);
            }
            
            comWrapper.AlternativeBOMs = [Select Id, Name, ERP7__Bill_Of_Material__c, ERP7__BOM_Variance__c, ERP7__Product__c, ERP7__Product_Feature__c, ERP7__Type__c, ERP7__BOM_Variance__r.ERP7__BOM_Component__r.Name,
                                          ERP7__BOM_Variance__r.ERP7__BOM_Component__c, ERP7__BOM_Variance__r.RecordType.Name, ERP7__BOM_Variance__r.RecordTypeId, ERP7__BOM_Variance__r.ERP7__BOM_Version__c,
                                          ERP7__BOM_Variance__r.ERP7__Unit_of_Measure__c
                                          From ERP7__Variance__c 
                                          Where ERP7__Type__c = 'Alternative' And
                                          ERP7__BOM_Variance__r.ERP7__BOM_Version__c =: mrpWrapper.MRP.ERP7__BOM__r.ERP7__BOM_Version__c And
                                          ERP7__Bill_Of_Material__c Not In: bomIds And
                                          ERP7__Bill_Of_Material__c = :mrpWrapper.MRP.ERP7__BOM__c
                                         ];
            
            String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
            String AllWarehouseFields = WarehouseFields + '';
            Set<Id> proIds = new Set<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            for(ERP7__Variance__c bom : comWrapper.AlternativeBOMs){ if(bom.ERP7__BOM_Variance__r.ERP7__BOM_Component__c != Null) proIds.add(bom.ERP7__BOM_Variance__r.ERP7__BOM_Component__c);
                                                                   }
            String selectedSite = mrpWrapper.MRP.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            if(selectedSite != Null && selectedSite != ''){
                List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                                    +' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC'); 
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    for(Inventory_Stock__c stock : WIISLists){
                        if(proId == stock.Product__c){  myStock += stock.Number_of_Item_In_Stock__c;  }
                    }                   
                    stockMap.put(proId,myStock);
                }
            }  
            comWrapper.MRPs = new List<mrpWrap>(); 
            Id rTpe_MRPMAN; rTpe_MRPMAN = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Manufacturing').getRecordTypeId();
            for(ERP7__Variance__c bom : comWrapper.AlternativeBOMs){
                mrpWrap mrpW = new mrpWrap();
                ERP7__MRP__c MRPn = new ERP7__MRP__c(Name = BOM.ERP7__BOM_Variance__r.ERP7__BOM_Component__r.Name,ERP7__Total_Amount_Required__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c,ERP7__BOM__c = BOM.ERP7__BOM_Variance__c,ERP7__MRP_Product__c = BOM.ERP7__BOM_Variance__r.ERP7__BOM_Component__c,ERP7__Version__c = BOM.ERP7__BOM_Variance__r.ERP7__BOM_Version__c, ERP7__MO__c = mrpWrapper.MRP.ERP7__MO__c);
                mrpW.Qnty = mrpWrapper.MRP.ERP7__Total_Amount_Required__c;
                if(bom.ERP7__BOM_Variance__r.RecordType.Name == 'Manufacturing BOM' && rTpe_MRPMAN != null) MRPn.RecordTypeId = rTpe_MRPMAN;
                mrpW.MRP = MRPn;
                if(stockMap.containsKey(BOM.ERP7__BOM_Variance__r.ERP7__BOM_Component__c)) mrpW.Stock = stockMap.get(BOM.ERP7__BOM_Variance__r.ERP7__BOM_Component__c);
                comWrapper.MRPs.add(mrpW);
            }
        } catch(Exception e) { comWrapper.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comWrapper;
    }
    
    @AuraEnabled
    public static comWrap MRPUpdate(string mrpMain1, String alternateMrps){   
        List<mrpWrap> mrpWrapper = (List<mrpWrap>) JSON.deserialize(alternateMrps, List<mrpWrap> .class);
        ERP7__MRP__c mrpMain = (ERP7__MRP__c) JSON.deserialize(mrpMain1, ERP7__MRP__c .class);
        comWrap comWrapper = new comWrap();
        try{
            //upsert mrpMain;
            List<ERP7__MRP__c> alternateMrps2upsert = new List<ERP7__MRP__c>();
            List<ERP7__MRP__c> alternateMrps2delete = new List<ERP7__MRP__c>();
            
            for(mrpWrap mrp : mrpWrapper){
                if(mrp.isSelect && mrp.Qnty > 0) { mrp.MRP.ERP7__Total_Amount_Required__c = mrp.Qnty; alternateMrps2upsert.add(mrp.MRP); }
            }
           // if((mrpMain.ERP7__BOM__r.ERP7__Is_Protected__c == true && alternateMrps2upsert.size() > 0) || !(mrpMain.ERP7__Total_Amount_Required__c > 0)) alternateMrps2delete.add(mrpMain);
             alternateMrps2upsert.add(mrpMain);
            
            if(alternateMrps2upsert.size() > 0){ if(Schema.SObjectType.ERP7__MRP__c.isCreateable() && Schema.SObjectType.ERP7__MRP__c.isUpdateable()){upsert alternateMrps2upsert;}else{comWrapper.errorMsg='Not allowed to upsert MRPs';} }
            if(alternateMrps2delete.size() > 0 && ERP7__MRP__c.sObjectType.getDescribe().isDeletable()) delete alternateMrps2delete;
            //Commented by bushra 01-07-2025  because the mrp is getting deleted if the qty is 0 , issue reported by POLYMEM
            //if(alternateMrps2delete.size() > 0 && ERP7__MRP__c.sObjectType.getDescribe().isDeletable()) comWrapper.errorMsg='Required Qty cannot be 0 or negative';
        } catch(Exception e) { comWrapper.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comWrapper;
    }
   /* @AuraEnabled
public static comWrap MRPUpdate(string mrpMain1, String alternateMrps) {
    List<mrpWrap> mrpWrapper = (List<mrpWrap>) JSON.deserialize(alternateMrps, List<mrpWrap>.class);
    ERP7__MRP__c mrpMain = (ERP7__MRP__c) JSON.deserialize(mrpMain1, ERP7__MRP__c.class);
    comWrap comWrapper = new comWrap();
    
    try {
        List<ERP7__MRP__c> alternateMrps2upsert = new List<ERP7__MRP__c>();
        
        // Process alternate MRPs
        for(mrpWrap mrp : mrpWrapper) {
            if(mrp.isSelect && mrp.Qnty > 0) {
                mrp.MRP.ERP7__Total_Amount_Required__c = mrp.Qnty;
                alternateMrps2upsert.add(mrp.MRP);
            }
            // Add validation for negative quantities if needed
            else if(mrp.Qnty < 0) {
                comWrapper.errorMsg = 'Quantity cannot be negative';
                return comWrapper;
            }
        }
        
        // Handle main MRP
        if(mrpMain.ERP7__Total_Amount_Required__c < 0) {
            comWrapper.errorMsg = 'Main MRP quantity cannot be negative';
            return comWrapper;
        }
        
        // Add main MRP to upsert list if not protected or has positive quantity
        if(!(mrpMain.ERP7__BOM__r.ERP7__Is_Protected__c == true && alternateMrps2upsert.size() > 0)) {
            alternateMrps2upsert.add(mrpMain);
        }
        
        // Perform upsert if we have records and permissions
        if(alternateMrps2upsert.size() > 0) {
            if(Schema.SObjectType.ERP7__MRP__c.isCreateable() && Schema.SObjectType.ERP7__MRP__c.isUpdateable()) {
                upsert alternateMrps2upsert;
            } else {
                comWrapper.errorMsg = 'Not allowed to upsert MRPs';
            }
        }
        
    } catch(Exception e) {
        comWrapper.errorMsg = e.getMessage() + ' Line Number @ : ' + e.getLineNumber();
    }
    
    return comWrapper;
}*/
    
    @AuraEnabled
    public static comWrap getAllSOLI(string mosoliId,string MOrdItm) {
        comWrap comW = new comWrap();
        if(mosoliId!= null && mosoliId != ''){
            ERP7__Sales_Order_Line_Item__c soli = [Select Id, Name, ERP7__Sales_Order__c, ERP7__Active__c, ERP7__Product__c, ERP7__Product__r.Name,
                                                   ERP7__Status__c, ERP7__Quantity__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__Routing__c, ERP7__Routing__r.Name,
                                                   ERP7__Product__r.ERP7__Routing__c, ERP7__Product__r.ERP7__Routing__r.Name , ERP7__Product__r.ERP7__Version__c, ERP7__Product__r.ERP7__Version__r.Name,
                                                   ERP7__Start_Time__c, ERP7__End_Time__c from ERP7__Sales_Order_Line_Item__c where Id=:mosoliId];
            
            comW.manuOrders.ERP7__Sales_Order_Line_Item__c = soli.Id;
            comW.manuOrders.ERP7__Product__c = soli.ERP7__Product__c;
            if(soli.ERP7__Version__c != null) 
            {
                comW.manuOrders.ERP7__Version__c = soli.ERP7__Version__c;
                comW.Version = new ERP7__Version__c(Id=soli.ERP7__Version__c, Name=soli.ERP7__Version__r.Name);
                
            }
            else {
                comW.manuOrders.ERP7__Version__c = soli.ERP7__Product__r.ERP7__Version__c;
                comW.Version = new ERP7__Version__c(Id=soli.ERP7__Product__r.ERP7__Version__c, Name=soli.ERP7__Product__r.ERP7__Version__r.Name);
            }
            if(soli.ERP7__Routing__c != null) {
                comW.manuOrders.ERP7__Routing__c = soli.ERP7__Routing__c;
                comW.Routing = new ERP7__Routing__c(Id=soli.ERP7__Routing__c, Name=soli.ERP7__Routing__r.Name);
            }
            else { 
                comW.manuOrders.ERP7__Routing__c = soli.ERP7__Product__r.ERP7__Routing__c;
                comW.Routing = new ERP7__Routing__c(Id=soli.ERP7__Product__r.ERP7__Routing__c, Name=soli.ERP7__Product__r.ERP7__Routing__r.Name);
            }
            comW.manuOrders.ERP7__Sales_Order__c = soli.ERP7__Sales_Order__c;
            comW.manuOrders.ERP7__Quantity__c = soli.ERP7__Quantity__c;
            comW.manuOrders.ERP7__StartDate__c = soli.ERP7__Start_Time__c;
            comW.manuOrders.ERP7__End_Date__c = soli.ERP7__End_Time__c;
            //ERP7__Routing__r.Name, ERP7__Product__r.Name, ERP7__Version__r.Name
            comW.Product = new Product2(Id=soli.ERP7__Product__c, Name=soli.ERP7__Product__r.Name);
            
            
        }
        else if(MOrdItm!= null && MOrdItm != ''){
            OrderItem oItm = [Select Id, OrderItemNumber, OrderId, ERP7__Active__c, Product2Id, Product2.Name,
                              ERP7__Status__c, Quantity, ERP7__Version__c, ERP7__Version__r.Name, ERP7__Routing__c, ERP7__Routing__r.Name,
                              Product2.ERP7__Routing__c, Product2.ERP7__Version__c,Product2.ERP7__Routing__r.Name,Product2.ERP7__Version__r.Name,
                              ERP7__Start_Time__c, ERP7__End_Time__c from OrderItem where Id=:MOrdItm];
            comW.manuOrders.ERP7__Order_Product__c = oItm.Id;
            //   comW.manuOrders.ERP7__Order_Product__r.OrderItemNumber = oItm.OrderItemNumber;
            comW.manuOrders.ERP7__Product__c = oItm.Product2Id;
            if(oItm.ERP7__Version__c != null)
            {
                comW.manuOrders.ERP7__Version__c = oItm.ERP7__Version__c;
                comW.Version = new ERP7__Version__c(Id=oItm.ERP7__Version__c, Name=oItm.ERP7__Version__r.Name);
            }
            else{
                comW.manuOrders.ERP7__Version__c = oItm.Product2.ERP7__Version__c;  
                comW.Version = new ERP7__Version__c(Id=oItm.Product2.ERP7__Version__c, Name=oItm.Product2.ERP7__Version__r.Name);
            }
            if(oItm.ERP7__Routing__c != null){
                comW.manuOrders.ERP7__Routing__c = oItm.ERP7__Routing__c;
                comW.Routing = new ERP7__Routing__c(Id=oItm.ERP7__Routing__c, Name=oItm.ERP7__Routing__r.Name);
            }
            else{
                comW.manuOrders.ERP7__Routing__c = oItm.Product2.ERP7__Routing__c; 
                comW.Routing = new ERP7__Routing__c(Id=oItm.Product2.ERP7__Routing__c, Name=oItm.Product2.ERP7__Routing__r.Name);
            }
            comW.manuOrders.ERP7__Order__c = oItm.OrderId;
            comW.manuOrders.ERP7__Quantity__c = oItm.Quantity;
            comW.manuOrders.ERP7__StartDate__c = oItm.ERP7__Start_Time__c;
            comW.manuOrders.ERP7__End_Date__c = oItm.ERP7__End_Time__c;
            //ERP7__Routing__r.Name, ERP7__Product__r.Name, ERP7__Version__r.Name
            comW.Product = new Product2(Id=oItm.Product2Id, Name=oItm.Product2.Name);
            
            
        }
        return comW;
    }
    
    @AuraEnabled
    public static mrpWrap getAllMO(string mrpId) {
        ERP7__Manufacturing_Order__c MOmrp = new ERP7__Manufacturing_Order__c();
        mrpWrap mrpWraper = new mrpWrap();
        ERP7__MRP__c MRP = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__BOM__r.ERP7__Unit_of_Measure__c, ERP7__BOM__r.Name, ERP7__BOM__r.ERP7__BOM_Version__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name, ERP7__MRP_Product__r.ERP7__Version__c, ERP7__MRP_Product__r.ERP7__Routing__c, ERP7__MRP_Product__r.ERP7__Version__r.Name, ERP7__MRP_Product__r.ERP7__Routing__r.Name, ERP7__BOM__r.ERP7__Exact_Quantity__c, 
                            ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__MO__r.ERP7__Version__c, ERP7__Fulfilled_Amount__c, ERP7__BOM__r.ERP7__Is_Protected__c, ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__MRP_Product__r.ERP7__Issue_Purchase_Order__c, ERP7__MRP_Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__MO__r.Name, ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c,
                            ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__BOM__r.ERP7__Product_Feature__c, ERP7__BOM__r.ERP7__Product_Feature__r.Name
                            From ERP7__MRP__c  
                            Where Id = :mrpId Order By ERP7__BOM__r.ERP7__Sort__c ASC];
        
        MOmrp.Name = MRP.ERP7__MRP_Product__r.Name;
        MOmrp.ERP7__Quantity__c = MRP.ERP7__Total_Amount_Required__c;
        MOmrp.ERP7__Product__c = MRP.ERP7__MRP_Product__c;
        MOmrp.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;
        MOmrp.ERP7__MRP_Material_Requirement_Planning__c = MRP.Id;
        MOmrp.ERP7__Routing__c = MRP.ERP7__MRP_Product__r.ERP7__Routing__c;
        MOmrp.ERP7__Version__c = MRP.ERP7__MRP_Product__r.ERP7__Version__c;
        mrpWraper.MRP = MRP;
        mrpWraper.MO = MOmrp;
        mrpWraper.Product = new Product2(Id=MRP.ERP7__MRP_Product__c, Name=MRP.ERP7__MRP_Product__r.Name);
        mrpWraper.Routing = new ERP7__Routing__c(Id=MRP.ERP7__MRP_Product__r.ERP7__Routing__c, Name=MRP.ERP7__MRP_Product__r.ERP7__Routing__r.Name);
        mrpWraper.Version = new ERP7__Version__c(Id=MRP.ERP7__MRP_Product__r.ERP7__Version__c, Name=MRP.ERP7__MRP_Product__r.ERP7__Version__r.Name);
        return mrpWraper;
    }
    
    @AuraEnabled
    public static mrpWrap getAllMPS(string mpslineId) {
        ERP7__Manufacturing_Order__c MOmrp = new ERP7__Manufacturing_Order__c();
        mrpWrap mrpWraper = new mrpWrap();
        String mpsLineFields = UtilClass.selectStarFromSObject('ERP7__MPS_line_Item__c');
        utilClass.FLSCheck(mpsLineFields.split(','),'ERP7__MPS_line_Item__c');
        String query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c, ERP7__MPS__r.ERP7__Version__c, ERP7__MPS__r.ERP7__Version__r.Name, ERP7__MPS__r.ERP7__Product__r.ERP7__Version__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Routing__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Routing__r.Name, ERP7__MPS__r.ERP7__Product__r.Name, ERP7__MPS__r.ERP7__Lot_Size__c, ERP7__MPS__r.ERP7__Product__c from ERP7__MPS_line_Item__c where Id =: mpslineId ';
        List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
        if(MPSSLines.size() > 0){
            MOmrp.Name = MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.Name;
            MOmrp.ERP7__Quantity__c = MPSSLines[0].ERP7__MPS__r.ERP7__Lot_Size__c;
            MOmrp.ERP7__Product__c = MPSSLines[0].ERP7__MPS__r.ERP7__Product__c;
            MOmrp.ERP7__Routing__c = MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.ERP7__Routing__c;
            MOmrp.ERP7__Version__c = (MPSSLines[0].ERP7__MPS__r.ERP7__Version__c != Null)? MPSSLines[0].ERP7__MPS__r.ERP7__Version__c : MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.ERP7__Version__c;
            
            mrpWraper.Product = new Product2(Id=MPSSLines[0].ERP7__MPS__r.ERP7__Product__c, Name=MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.Name);
            mrpWraper.Routing = new ERP7__Routing__c(Id=MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.ERP7__Routing__c, Name=MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.ERP7__Routing__r.Name);
            if(MPSSLines[0].ERP7__MPS__r.ERP7__Version__c != Null) mrpWraper.Version = new ERP7__Version__c(Id=MPSSLines[0].ERP7__MPS__r.ERP7__Version__c, Name=MPSSLines[0].ERP7__MPS__r.ERP7__Version__r.Name);
        }
        mrpWraper.MO = MOmrp;
        return mrpWraper;
    }
    
    /* @AuraEnabled
public static comWrap ReserveMRPSStocks(String MRPs){
List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
comWrap comW = new comWrap();

try{
comW.errorMsg = '';
List<mrpWrap> mrpWrapret = new List<mrpWrap>();
String selectedSite = comW.manuOrders.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
String finishedProduct = comW.manuOrders.ERP7__Product__c;
List<Id> proIds = new List<Id>();
Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
Map<Id,List<Inventory_Stock__c>> productSites = new Map<Id,List<Inventory_Stock__c>>();

for(mrpWrap mrpWrapper : mrpWrappers){
if(mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != Null) selectedSite = mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
if(mrpWrapper.mrp.ERP7__MRP_Product__c != Null) proIds.add(mrpWrapper.mrp.ERP7__MRP_Product__c);
}

if(selectedSite != Null && selectedSite != ''){
String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
String AllWarehouseFields = WarehouseFields + '';
List<ERP7__Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', ERP7__Warehouse__r.Name, ERP7__Location__r.Name, ERP7__StorageContainer__r.Name, ERP7__Warehouse__r.ERP7__Barcode__c, ERP7__Location__r.ERP7__Barcode__c, '+
+' ERP7__StorageContainer__r.ERP7__Barcode__c from ERP7__Inventory_Stock__c where (ERP7__Warehouse__c =: selectedSite And (ERP7__Product__c In: proIds And ERP7__Number_of_Item_In_Stock__c > 0) And ERP7__Active__c = true) Order By ERP7__Expiry_Date__c ASC'); 

for(Id proId : proIds){
Decimal myStock = 0;
if(!productSites.containsKey(proId)) productSites.put(proId, new List<ERP7__Inventory_Stock__c>());
for(ERP7__Inventory_Stock__c stock : WIISLists){
if(proId == stock.Product__c){
myStock += stock.ERP7__Number_of_Item_In_Stock__c;
List<ERP7__Inventory_Stock__c> myStocks = productSites.get(proId);
myStocks.add(stock);
productSites.put(proId,myStocks);
}
}
stockMap.put(proId,myStock);
}

}
List<Stock_Outward_Line_Item__c> SDLIs2Upsert = new List<Stock_Outward_Line_Item__c>();
List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();

for(mrpWrap mrpWrapper : mrpWrappers){
if(mrpWrapper.Stock > 0 && mrpWrapper.MRP.ERP7__Status__c == 'Requested' && mrpWrapper.Stock >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c){                    
List<Inventory_Stock__c> WIISs = productSites.get(mrpWrapper.MRP.MRP_Product__c);
if(WIISs != Null && WIISs.size() > 0){
ERP7__Inventory_Stock__c WIIS = (mrpWrapper.MRP.ERP7__Check_Out_Process__c == 'LIFO')? WIISs[WIISs.size()-1] : WIISs[0];
ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
if(mrpWrapper.MRP.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
}
if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
SDLIs2Upsert.add(SDLI);
mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c;
mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
MRPs2Upsert.add(mrpWrapper.MRP);
comW.errorMsg = '';
mrpWrapret.add(mrpWrapper);

}
}
}
if(SDLIs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){upsert SDLIs2Upsert;}else{comW.errorMsg ='Not allowed to upsert SDLI';} }
if(MRPs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isUpdateable()){upsert MRPs2Upsert;}else{comW.errorMsg ='Not allowed to upsert MRPs';} }
List<mrpWrap> retunrMRP = new List<mrpWrap>();
for(mrpWrap mrpWrapper : mrpWrapret){
for(ERP7__MRP__c mrp : MRPs2Upsert){
if(mrpWrapper.MRP.ERP7__MRP_Product__c == mrp.ERP7__MRP_Product__c){
mrpWrapper.MRP = mrp;
}                    
}
retunrMRP.add(mrpWrapper);
}
comW.MRPs=retunrMRP;
} catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
return comW;
}*/
   /* 
	@AuraEnabled
	public static comWrap ReserveMRPSStocks(String MRPs,Integer AutostkLimit){
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        comWrap comW = new comWrap();
        system.debug('AutostkLimit : '+AutostkLimit);
        try{
            comW.errorMsg = '';
            List<mrpWrap> mrpWrapret = new List<mrpWrap>();
            String selectedSite = comW.manuOrders.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            String finishedProduct = comW.manuOrders.ERP7__Product__c;
            List<Id> proIds = new List<Id>();
            //Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            set<Id> MRPIds = new set<Id>();
            Map<Id,List<Inventory_Stock__c>> productSites = new Map<Id,List<Inventory_Stock__c>>();
            Map<Id,Decimal> Mapexistingstock = new Map<Id,Decimal>();
            Map<Id,Set<Id>> MapexistingstockSerials = new Map<Id,Set<Id>>();
            String MOId = '';
            for(mrpWrap mrpWrapper : mrpWrappers){
                if(MOId == '') MOId = mrpWrapper.mrp.ERP7__MO__c;
                if(mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != Null) selectedSite = mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                if(mrpWrapper.mrp.ERP7__MRP_Product__c != Null) proIds.add(mrpWrapper.mrp.ERP7__MRP_Product__c);
                MRPIds.add(mrpWrapper.mrp.Id);
            }
            List<ERP7__Stock_Outward_Line_Item__c> fulfilledStock = [Select Id,Name,ERP7__Quantity__c,ERP7__MRP_Material_Requirements_Planning__c,ERP7__MO_WO_Serial__c from ERP7__Stock_Outward_Line_Item__c where ERP7__MRP_Material_Requirements_Planning__c In:MRPIds and ERP7__Active__c =true];
            
            
            List<ERP7__Serial_Number__c> SNS = new List<ERP7__Serial_Number__c> ();
            Map<Id,ERP7__Serial_Number__c> SNSMap = new Map<Id,ERP7__Serial_Number__c> ();
            ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c();
            
            Set<Id> SerialNos = new Set<Id>();
            for(mrpWrap mrpWrapper : mrpWrappers){
                Decimal allocatedqty = 0;
                
                for(ERP7__Stock_Outward_Line_Item__c stk : fulfilledStock){
                    if(stk.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) { 
                        allocatedqty += stk.ERP7__Quantity__c;
                        if(stk.ERP7__MO_WO_Serial__c != Null) SerialNos.add(stk.ERP7__MO_WO_Serial__c);
                        // system.debug('allocatedqty : '+allocatedqty);
                    }
                }
                MapexistingstockSerials.put(mrpWrapper.MRP.Id, SerialNos);  
                if(allocatedqty > 0) Mapexistingstock.put(mrpWrapper.MRP.Id,allocatedqty);
            }
            fulfilledStock = new List<ERP7__Stock_Outward_Line_Item__c>();
            system.debug('Mapexistingstock : '+Mapexistingstock);
            system.debug('SerialNos : '+SerialNos);
            if(MOId != '') {
                MO = [Select Id, Name, ERP7__Product__r.ERP7__Serialise__c From ERP7__Manufacturing_Order__c Where Id =: MOId];
                if(MO.ERP7__Product__r.ERP7__Serialise__c == true) {
                    SNSMap = new Map<Id,ERP7__Serial_Number__c> ([Select Id, Name, ERP7__Material_Batch_Lot__c, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Serial_Number__c Where ERP7__Manufacturing_Order__c =: MO.Id and Id Not IN :SerialNos limit :AutostkLimit]);
                    SNS = SNSMap.Values();
                }
            }
            system.debug('*** SNS : '+SNS.size());
            if(selectedSite != Null && selectedSite != ''){
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + '';
                List<ERP7__Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', ERP7__Warehouse__r.Name, ERP7__Location__r.Name, ERP7__StorageContainer__r.Name, ERP7__Warehouse__r.ERP7__Barcode__c, ERP7__Location__r.ERP7__Barcode__c, '+
                                                                          +' ERP7__StorageContainer__r.ERP7__Barcode__c from ERP7__Inventory_Stock__c where (ERP7__Warehouse__c =: selectedSite And (ERP7__Product__c In: proIds And ERP7__Number_of_Item_In_Stock__c > 0) And ERP7__Active__c = true) Order By ERP7__Checked_In_Date__c ASC, ERP7__Expiration_Date__c ASC NULLS LAST Limit 1000');//added ERP7__Expiration_Date__c ASC filter on 22_07_24 //changed to check in date on 30_05_24// ERP7__Number_of_Item_In_Stock__c DESC removed on 29_02_24// changed DESC limit 1000 19_08_23 and order by ERP7__Number_of_Item_In_Stock__c from Expiry date
                
                
                List<ERP7__Inventory_Stock__c> withExpirationDate = new List<ERP7__Inventory_Stock__c>();
                List<ERP7__Inventory_Stock__c> withoutExpirationDate = new List<ERP7__Inventory_Stock__c>();
                
                for (ERP7__Inventory_Stock__c record : WIISLists) {
                    if (record.ERP7__Expiration_Date__c != null) {
                        withExpirationDate.add(record);
                    } else {
                        withoutExpirationDate.add(record);
                    }
                }
                
                // Manual sort of the list with Expiration_Date__c
                for (Integer i = 0; i < withExpirationDate.size() - 1; i++) {
                    for (Integer j = i + 1; j < withExpirationDate.size(); j++) {
                        if (withExpirationDate[i].ERP7__Expiration_Date__c > withExpirationDate[j].ERP7__Expiration_Date__c) {
                            // Swap elements if needed
                            ERP7__Inventory_Stock__c temp = withExpirationDate[i];
                            withExpirationDate[i] = withExpirationDate[j];
                            withExpirationDate[j] = temp;
                        }
                    }
                }
                
                // Merge the sorted lists while maintaining the original order for records without expiration dates
                List<ERP7__Inventory_Stock__c> sortedInventoryStocks = new List<ERP7__Inventory_Stock__c>();
                Integer expIndex = 0;
                Integer noExpIndex = 0;
                
                for (ERP7__Inventory_Stock__c record : WIISLists) {
                    if (record.ERP7__Expiration_Date__c != null) {
                        sortedInventoryStocks.add(withExpirationDate[expIndex]);
                        expIndex++;
                    } else {
                        sortedInventoryStocks.add(withoutExpirationDate[noExpIndex]);
                        noExpIndex++;
                    }
                }
                
                // Output the sorted results
              // for (ERP7__Inventory_Stock__c inv : sortedInventoryStocks) {
                //    System.debug('inv: ' + inv);
                //}
                
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    if(!productSites.containsKey(proId)) productSites.put(proId, new List<ERP7__Inventory_Stock__c>());
                    for(ERP7__Inventory_Stock__c stock : sortedInventoryStocks){
                        if(proId == stock.Product__c){
                            
                            // myStock += stock.ERP7__Number_of_Item_In_Stock__c;
                            List<ERP7__Inventory_Stock__c> myStocks = productSites.get(proId);
                            myStocks.add(stock);
                            productSites.put(proId,myStocks);
                        }
                    }
                    
                    // stockMap.put(proId,myStock);
                    
                }
                WIISLists = new List<ERP7__Inventory_Stock__c>();
                
            }
            // system.debug('stockMap ; '+stockMap);
            List<Stock_Outward_Line_Item__c> SDLIs2Upsert = new List<Stock_Outward_Line_Item__c>();
            List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();
            
            System.debug('Limits.getCpuTime 1- '+ Limits.getCpuTime());
            System.debug('Limits.getLimitCpuTime 1- '+ Limits.getLimitCpuTime());
            System.debug('Limits.getHeapSize 1- '+ Limits.getHeapSize());
            System.debug('Limits.getLimitHeapSize 1- '+ Limits.getLimitHeapSize());
            Map<Id,decimal> SerialsStockAllocated = new Map<Id,decimal>();
            for(mrpWrap mrpWrapper : mrpWrappers){
                Decimal WM = mrpWrapper.WeightMultiplier;
                system.debug('Product : '+mrpWrapper.MRP.MRP_Product__c+'   mrpWrapper.Stock : '+mrpWrapper.Stock+ ' 2.mrpWrapper.MRP.ERP7__Status__c : '+mrpWrapper.MRP.ERP7__Status__c+ ' 3.mrpWrapper.MRP.ERP7__Total_Amount_Required__c : '+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                decimal stockAllocated = 0;
                if(mrpWrapper.Stock > 0 && mrpWrapper.MRP.ERP7__Status__c == 'Requested'){  //&& ((mrpWrapper.Stock >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c) || ((mrpWrapper.Stock + mrpWrapper.mrp.ERP7__Fulfilled_Amount__c) >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c))                   
                    system.debug('if');
                    List<Inventory_Stock__c> WIISs = productSites.get(mrpWrapper.MRP.MRP_Product__c);
                    system.debug('stockAllocated 1: '+stockAllocated);
                    if(WIISs != Null && WIISs.size() > 0){
                        system.debug('WIISs : Not null ');
                        ERP7__Inventory_Stock__c WIIS = (mrpWrapper.MRP.ERP7__Check_Out_Process__c == 'LIFO')? WIISs[WIISs.size()-1] : WIISs[0];
                        system.debug('WIIS : '+WIIS.ERP7__Number_of_Item_In_Stock__c);
                        
                        
                        // Single WIIS straight forward reduction and reserving
                        if((WIIS.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.mrp.ERP7__Fulfilled_Amount__c/WM) >= (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM)){
                            system.debug('In if 1');
                            if(SNS.size() > 0){
                                for(ERP7__Serial_Number__c SN : SNS){
                                    if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id)){
                                        system.debug('*** SNS In One: '+SN.Name);
                                        ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                        //if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - Mapexistingstock.get(mrpWrapper.MRP.Id) ;
                                        //else SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c;
                                        stockAllocated += (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM);
                                        SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                        
                                        SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                        if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                        if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                        if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                        if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                            SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                            SDLI.Total_Amount__c = SDLI.ERP7__Quantity__c*SDLI.Unit_Price__c;
                                        }
                                        if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                        if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                        if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                        SDLIs2Upsert.add(SDLI);
                                        MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                    }
                                    
                                }
                            }
                            else{ 
                                system.debug('*** SNS out One: ');
                                ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) {
                                    system.debug('out 1');
                                    stockAllocated +=  (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM) - Mapexistingstock.get(mrpWrapper.MRP.Id);
                                    SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM - Mapexistingstock.get(mrpWrapper.MRP.Id);
                                }
                                else { system.debug('out 2'); SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM).setScale(4); stockAllocated += (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM);}
                                
                                if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                    SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                    SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                }
                                if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                SDLIs2Upsert.add(SDLI);
                            }
                            system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c bfr : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                            system.debug('stockAllocated : '+stockAllocated);
                            system.debug('WM : '+WM);
                            
                            mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = (mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (stockAllocated * WM)).setScale(4); //added setscale on 20_10_2023  //mrpWrapper.MRP.ERP7__Total_Amount_Required__c; change added by shaguftha 11/09/23
                            system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c 1 : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                            mrpWrapper.Stock = (mrpWrapper.Stock - stockAllocated).setScale(4); // added setScale on 20_10_23
                            system.debug('1 : mrpWrapper.Stock : '+mrpWrapper.Stock);
                            mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                            if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c == mrpWrapper.MRP.ERP7__Total_Amount_Required__c) mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                            MRPs2Upsert.add(mrpWrapper.MRP);
                            comW.errorMsg = '';
                            mrpWrapret.add(mrpWrapper); 
                            
                        }
                        
                        
                        //Multiple WIIS calculative Reserving and other calculations
                        else if(WIIS.ERP7__Number_of_Item_In_Stock__c < mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM){
                            system.debug('else if 1');
                            
                            //Need Change Imran
                            Decimal remainingqty = 0;
                            for(Inventory_Stock__c stk : WIISs){
                                if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c != mrpWrapper.MRP.ERP7__Total_Amount_Required__c && mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                    if(SNS.size() > 0){
                                        Decimal WIISStock = stk.ERP7__Number_of_Item_In_Stock__c;
                                        system.debug('WIISStock : '+WIISStock);
                                        if(WIISStock > 0 && WIISStock >= (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)){ 
                                            while(SNSMap.values().size() > 0){
                                                ERP7__Serial_Number__c SN = SNSMap.values()[0];
                                                system.debug('SN : '+SN);
                                                system.debug('!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) : '+!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id));
                                                //for(ERP7__Serial_Number__c SN : SNS){
                                                if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id)){ // && WIISStock > 0 && WIISStock >= (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)
                                                    system.debug('*** SNS In two : '+SN.Name);
                                                    ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                                    //totalAllocatedQty += stk.ERP7__Number_of_Item_In_Stock__c;
                                                    //if(((mrpWrapper.MRP.ERP7__Total_Amount_Required__c == stk.ERP7__Number_of_Item_In_Stock__c) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c > (stk.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c))) || remainingqty >= stk.ERP7__Number_of_Item_In_Stock__c || remainingqty == 0) { SDLI.ERP7__Quantity__c = stk.ERP7__Number_of_Item_In_Stock__c; system.debug('stk.ERP7__Number_of_Item_In_Stock__c 1 ***: '+stk.ERP7__Number_of_Item_In_Stock__c); }
                                                    //else if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) { SDLI.ERP7__Quantity__c = remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id); system.debug('SDLI.ERP7__Quantity__c  1 ***: '+SDLI.ERP7__Quantity__c ); }
                                                    //else { SDLI.ERP7__Quantity__c = remainingqty;  system.debug('remainingqty  1 ***: '+remainingqty );}//stk.ERP7__Number_of_Item_In_Stock__c -  mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                                    stockAllocated += (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM);
                                                    system.debug('stockAllocated 2: '+stockAllocated);
                                                    SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                                    
                                                    SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                                    if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                                    
                                                    if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                                    if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                                    if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                                        SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                                        SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                                    }
                                                    if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                                    if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                                    if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                                    SDLIs2Upsert.add(SDLI);
                                                    mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4);
                                                    WIISStock = WIISStock - SDLI.ERP7__Quantity__c;
                                                    system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP Fulfilled QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                                    MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                                    if(WIISStock <= 0 || WIISStock < SDLI.ERP7__Quantity__c) break;
                                                }
                                                SNSMap.remove(SN.Id);
                                                system.debug('SNSMap : '+SNSMap.size());
                                            }
                                        }
                                        // Start Shaguftha change 23_11_23
                                        else if(WIISStock > 0 && WIISStock < (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)){
                                            while(SNSMap.values().size() > 0){
                                                ERP7__Serial_Number__c SN = SNSMap.values()[0];
                                                system.debug('SN : '+SN);
                                                system.debug('!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) : '+!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id));
                                                if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id)){ // && WIISStock > 0 && WIISStock >= (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)
                                                    system.debug('*** SNS In two : '+SN.Name);
                                                    ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                                    //stockAllocated += (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM);
                                                    system.debug('stockAllocated 2: '+stockAllocated);
                                                    SDLI.ERP7__Quantity__c = WIISStock; //(mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                                    stockAllocated += SDLI.ERP7__Quantity__c;
                                                    SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                                    if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                                    
                                                    if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                                    if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                                    if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                                        SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                                        SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                                    }
                                                    if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                                    if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                                    if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                                    SDLIs2Upsert.add(SDLI);
                                                    mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4);
                                                    WIISStock = WIISStock - SDLI.ERP7__Quantity__c;
                                                    system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP Fulfilled QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                                    if(SerialsStockAllocated.containsKey(SN.Id)) SerialsStockAllocated.put(SN.Id,(SerialsStockAllocated.get(SN.Id) + SDLI.ERP7__Quantity__c));
                                                    else SerialsStockAllocated.put(SN.Id,SDLI.ERP7__Quantity__c);
                                                    if(SerialsStockAllocated.containsKey(SN.Id) && SerialsStockAllocated.get(SN.Id) == (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)) MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                                    if(WIISStock <= 0 || WIISStock < SDLI.ERP7__Quantity__c) break;                                                    
                                                }
                                                system.debug('remove');
                                                SNSMap.remove(SN.Id);
                                                system.debug('SNSMap : '+SNSMap.size());
                                            }
                                        }
                                        // end Shaguftha change 23_11_23
                                    }
                                    else{
                                        system.debug('*** SNS out two: ');
                                        ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                        //totalAllocatedQty += stk.ERP7__Number_of_Item_In_Stock__c;
                                        if(((mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM == stk.ERP7__Number_of_Item_In_Stock__c) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM > (stk.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c/WM))) || remainingqty >= stk.ERP7__Number_of_Item_In_Stock__c || remainingqty == 0) { 
                                            //stockAllocated += stk.ERP7__Number_of_Item_In_Stock__c;
    SDLI.ERP7__Quantity__c = stk.ERP7__Number_of_Item_In_Stock__c; system.debug('stk.ERP7__Number_of_Item_In_Stock__c 1 ***: '+stk.ERP7__Number_of_Item_In_Stock__c); }
                                        else if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) { SDLI.ERP7__Quantity__c = (remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id)).setScale(4); 
//stockAllocated += (remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id));
    	system.debug('SDLI.ERP7__Quantity__c  1 ***: '+SDLI.ERP7__Quantity__c ); }
                                        else { SDLI.ERP7__Quantity__c = (remainingqty).setScale(4);  //stockAllocated += remainingqty;  
                                              system.debug('remainingqty  1 ***: '+remainingqty );}//stk.ERP7__Number_of_Item_In_Stock__c -  mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                        stockAllocated += SDLI.ERP7__Quantity__c; // uncommented on 18_10_23
                                        
                                        if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                        if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                        if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                            SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                            SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                        }
                                        if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                        if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                        if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                        SDLIs2Upsert.add(SDLI);
                                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4); // 18_10_23 SDLI.ERP7__Quantity__c from StockAllocated
                                        system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                    }
                                    //mrpWrapper.Stock = mrpWrapper.Stock - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;       
                                    //mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + Decimal.valueOf(stockAllocated * WM);
                                    remainingqty = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c)/WM;
                                    if(remainingqty < 0) remainingqty = 0;
                                    system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c 1 : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                                    if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                        Decimal totalFulfilled =  (Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) ?  (Mapexistingstock.get(mrpWrapper.MRP.Id)) : 0;
                                        //for(ERP7__Stock_Outward_Line_Item__c ss : SDLIs2Upsert){
//if(ss.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) totalFulfilled += ss.ERP7__Quantity__c;}
                                        System.debug('totalFulfilled : '+totalFulfilled);
                                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = (totalFulfilled * WM) + (stockAllocated * WM); // added * WM for totalfulfilled Shaguftha 02_01_2024
                                        system.debug('totalFulfilled else if 2 after: '+totalFulfilled+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                        if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c) mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                                        // mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                        system.debug('mrpWrapper.Stock  : '+mrpWrapper.Stock);
                                        //  MRPs2Upsert.add(mrpWrapper.MRP);
                                        comW.errorMsg = '';
                                        mrpWrapret.add(mrpWrapper);
                                        break;
                                    } 
                                }
                            } // for WIIS
                            system.debug('stockAllocated : '+stockAllocated);
                            system.debug('mrpWrapper.Stock : '+mrpWrapper.Stock);
                            mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                            mrpWrapper.Stock = mrpWrapper.Stock - stockAllocated;
                            MRPs2Upsert.add(mrpWrapper.MRP);
                            mrpWrapret.add(mrpWrapper); 
                            system.debug('MRPs2Upsert : '+MRPs2Upsert);
                        } // Multiple WIIS
                        
                        
                    } // WIIS size > 0
                } // MRP Stock > 0
                
               
            }
            mrpWrappers = new List<mrpWrap>();
            System.debug('Limits.getCpuTime 2- '+ Limits.getCpuTime());
            System.debug('Limits.getLimitCpuTime 2- '+ Limits.getLimitCpuTime());
            System.debug('Limits.getHeapSize 2- '+ Limits.getHeapSize());
            System.debug('Limits.getLimitHeapSize 2- '+ Limits.getLimitHeapSize());
            
            if(SDLIs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()){ PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler=false; upsert SDLIs2Upsert;}else{comW.errorMsg ='Not allowed to upsert SDLI';} }
            SDLIs2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            if(MRPs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){PreventRecursiveLedgerEntry.MRPFlowTrigger = false; upsert MRPs2Upsert;}else{comW.errorMsg ='Not allowed to upsert MRPs';} }
            List<mrpWrap> retunrMRP = new List<mrpWrap>();
            for(mrpWrap mrpWrapper : mrpWrapret){
                for(ERP7__MRP__c mrp : MRPs2Upsert){
                    if(mrpWrapper.MRP.ERP7__MRP_Product__c == mrp.ERP7__MRP_Product__c){  
                        mrpWrapper.MRP = mrp;
                        // mrpWrapper.Stock = mrpWrapper.Stock - mrp.ERP7__Fulfilled_Amount__c;
                        system.debug('mrpWrapper.Stock : '+mrpWrapper.Stock);
                    }                    
                }
                retunrMRP.add(mrpWrapper);
            }
            MRPs2Upsert = new List<ERP7__MRP__c>();
            mrpWrapret = new List<mrpWrap>();
            comW.MRPs=retunrMRP;
            retunrMRP = new List<mrpWrap>();
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }
        return comW;
    }  
   */ 
    



//new    
@AuraEnabled
    public static comWrap ReserveMRPSStocks(String MRPs,Integer AutostkLimit){
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        comWrap comW = new comWrap();
        system.debug('AutostkLimit : '+AutostkLimit);
        try{
            comW.errorMsg = '';
            Set<Id> bomStockAllocProdIds = new Set<Id>();
            List<mrpWrap> mrpWrapret = new List<mrpWrap>();
            String selectedSite = comW.manuOrders.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            String finishedProduct = comW.manuOrders.ERP7__Product__c;
            List<Id> proIds = new List<Id>();
            //Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            set<Id> MRPIds = new set<Id>();
            Map<Id,List<Inventory_Stock__c>> productSites = new Map<Id,List<Inventory_Stock__c>>();
            Map<Id,Decimal> Mapexistingstock = new Map<Id,Decimal>();
            Map<Id,Set<Id>> MapexistingstockSerials = new Map<Id,Set<Id>>();
            String MOId = '';
            Map<Id,decimal> bomDupProductStockAllocated = new Map<Id,decimal>();
            Map<Id,decimal> inventoryStockAllocated = new Map<Id,decimal>();
            Map<Id, Decimal> serialAllocatedQty = new Map<Id, Decimal>();



            for(mrpWrap mrpWrapper : mrpWrappers){
                if(MOId == '') MOId = mrpWrapper.mrp.ERP7__MO__c;
                if(mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != Null) selectedSite = mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                if(mrpWrapper.mrp.ERP7__MRP_Product__c != Null) proIds.add(mrpWrapper.mrp.ERP7__MRP_Product__c);
                MRPIds.add(mrpWrapper.mrp.Id);
                
                if(mrpWrapper.mrp.MRP_Product__c != Null) bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, 0);

            }
            List<ERP7__Stock_Outward_Line_Item__c> fulfilledStock = [Select Id,Name,ERP7__Quantity__c,ERP7__MRP_Material_Requirements_Planning__c,ERP7__MO_WO_Serial__c from ERP7__Stock_Outward_Line_Item__c where ERP7__MRP_Material_Requirements_Planning__c In:MRPIds and ERP7__Active__c =true];
            
            
            List<ERP7__Serial_Number__c> SNS = new List<ERP7__Serial_Number__c> ();
            Map<Id,ERP7__Serial_Number__c> SNSMap = new Map<Id,ERP7__Serial_Number__c> ();
            ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c();
            
            Set<Id> SerialNos = new Set<Id>();
            for(mrpWrap mrpWrapper : mrpWrappers){
                Decimal allocatedqty = 0;
                
                for(ERP7__Stock_Outward_Line_Item__c stk : fulfilledStock){
                    if(stk.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) { 
                        allocatedqty += stk.ERP7__Quantity__c;
                        if(stk.ERP7__MO_WO_Serial__c != Null){
                            SerialNos.add(stk.ERP7__MO_WO_Serial__c);
                        // system.debug('allocatedqty : '+allocatedqty);
                        //new changes by matheen 7-4-25
                        if (!serialAllocatedQty.containsKey(stk.ERP7__MO_WO_Serial__c)) {
                            serialAllocatedQty.put(stk.ERP7__MO_WO_Serial__c, stk.ERP7__Quantity__c);
                        } else {
                            serialAllocatedQty.put(stk.ERP7__MO_WO_Serial__c,
                            serialAllocatedQty.get(stk.ERP7__MO_WO_Serial__c) + stk.ERP7__Quantity__c);
                        }
                        // new changes ends
                        } 
                    }
                }
                MapexistingstockSerials.put(mrpWrapper.MRP.Id, SerialNos);  
                if(allocatedqty > 0) Mapexistingstock.put(mrpWrapper.MRP.Id,allocatedqty);
            }
            fulfilledStock = new List<ERP7__Stock_Outward_Line_Item__c>();
            
            if(MOId != '') {
                MO = [Select Id, Name, ERP7__Product__r.ERP7__Serialise__c From ERP7__Manufacturing_Order__c Where Id =: MOId];
                if(MO.ERP7__Product__r.ERP7__Serialise__c == true) {
                    SNSMap = new Map<Id,ERP7__Serial_Number__c> ([Select Id, Name, ERP7__Material_Batch_Lot__c, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Serial_Number__c Where ERP7__Manufacturing_Order__c =: MO.Id and Id Not IN :SerialNos limit :AutostkLimit]);
                    SNS = SNSMap.Values();
                }
            }
            //system.debug('*** SNS : '+SNS.size());
            if(selectedSite != Null && selectedSite != ''){
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + '';
                List<ERP7__Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', ERP7__Warehouse__r.Name, ERP7__Location__r.Name, ERP7__StorageContainer__r.Name, ERP7__Warehouse__r.ERP7__Barcode__c, ERP7__Location__r.ERP7__Barcode__c, '+
                                                                          +' ERP7__StorageContainer__r.ERP7__Barcode__c from ERP7__Inventory_Stock__c where (ERP7__Warehouse__c =: selectedSite And (ERP7__Product__c In: proIds And ERP7__Number_of_Item_In_Stock__c > 0) And ERP7__Active__c = true) Order By ERP7__Expiry_Date__c ASC NULLS LAST, ERP7__Checked_In_Date__c ASC Limit 1000');//added ERP7__Expiration_Date__c ASC filter on 22_07_24 //changed to check in date on 30_05_24// ERP7__Number_of_Item_In_Stock__c DESC removed on 29_02_24// changed DESC limit 1000 19_08_23 and order by ERP7__Number_of_Item_In_Stock__c from Expiry date
                
               // Order By ERP7__Checked_In_Date__c ASC, ERP7__Expiration_Date__c ASC NULLS LAST  changed this by matheen on 30/4/25
                System.debug('WIISLists->'+WIISLists);
                List<ERP7__Inventory_Stock__c> withExpirationDate = new List<ERP7__Inventory_Stock__c>();
                List<ERP7__Inventory_Stock__c> withoutExpirationDate = new List<ERP7__Inventory_Stock__c>();
                
                for (ERP7__Inventory_Stock__c record : WIISLists) {
                    inventoryStockAllocated.put(record.Id, 0);
                    if (record.ERP7__Expiration_Date__c != null) {
                        withExpirationDate.add(record);
                    } else {
                        withoutExpirationDate.add(record);
                    }
                }
                
                // Manual sort of the list with Expiration_Date__c
                for (Integer i = 0; i < withExpirationDate.size() - 1; i++) {
                    for (Integer j = i + 1; j < withExpirationDate.size(); j++) {
                        if (withExpirationDate[i].ERP7__Expiration_Date__c > withExpirationDate[j].ERP7__Expiration_Date__c) {
                            // Swap elements if needed
                            ERP7__Inventory_Stock__c temp = withExpirationDate[i];
                            withExpirationDate[i] = withExpirationDate[j];
                            withExpirationDate[j] = temp;
                        }
                    }
                }
                
                // Merge the sorted lists while maintaining the original order for records without expiration dates
                List<ERP7__Inventory_Stock__c> sortedInventoryStocks = new List<ERP7__Inventory_Stock__c>();
                Integer expIndex = 0;
                Integer noExpIndex = 0;
                
                for (ERP7__Inventory_Stock__c record : WIISLists) {
                    if (record.ERP7__Expiration_Date__c != null) {
                        sortedInventoryStocks.add(withExpirationDate[expIndex]);
                        expIndex++;
                    } else {
                        sortedInventoryStocks.add(withoutExpirationDate[noExpIndex]);
                        noExpIndex++;
                    }
                }
               //System.debug('sortedInventoryStocks->'+sortedInventoryStocks);
                // Output the sorted results
               /*  for (ERP7__Inventory_Stock__c inv : sortedInventoryStocks) {
                    System.debug('inv: ' + inv);
                }*/
                
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    if(!productSites.containsKey(proId)) productSites.put(proId, new List<ERP7__Inventory_Stock__c>());
                    for(ERP7__Inventory_Stock__c stock : sortedInventoryStocks){
                        if(proId == stock.Product__c){
                            
                            // myStock += stock.ERP7__Number_of_Item_In_Stock__c;
                            List<ERP7__Inventory_Stock__c> myStocks = productSites.get(proId);
                            myStocks.add(stock);
                            productSites.put(proId,myStocks);
                        }
                    }
                    
                    // stockMap.put(proId,myStock);
                    
                }
                WIISLists = new List<ERP7__Inventory_Stock__c>();
                
            }
            // system.debug('stockMap ; '+stockMap);
            List<Stock_Outward_Line_Item__c> SDLIs2Upsert = new List<Stock_Outward_Line_Item__c>();
            List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();
            
            System.debug('Limits.getCpuTime 1- '+ Limits.getCpuTime());
            System.debug('Limits.getLimitCpuTime 1- '+ Limits.getLimitCpuTime());
            System.debug('Limits.getHeapSize 1- '+ Limits.getHeapSize());
            System.debug('Limits.getLimitHeapSize 1- '+ Limits.getLimitHeapSize());
            Map<Id,decimal> SerialsStockAllocated = new Map<Id,decimal>();
            
            
            for(mrpWrap mrpWrapper : mrpWrappers){
                System.debug('SNSMAP->'+SNSMAP);
                Decimal SA = bomDupProductStockAllocated.get(mrpWrapper.mrp.MRP_Product__c);
                mrpWrapper.Stock = mrpWrapper.Stock - SA;
                
                System.debug('in for main logic');
                /*
                if(bomStockAllocProdIds.contains(mrpWrapper.MRP.MRP_Product__c)){
					continue;                    
                }  
                */
                //System.debug('Processing Product ID: ' + mrpWrapper.MRP.MRP_Product__c);
                
               //System.debug('Updated bomStockAllocProdIds Set: ' + bomStockAllocProdIds);
                
                Decimal WM = mrpWrapper.WeightMultiplier;
                system.debug('Product : '+mrpWrapper.MRP.MRP_Product__c+'   mrpWrapper.Stock : '+mrpWrapper.Stock+ ' 2.mrpWrapper.MRP.ERP7__Status__c : '+mrpWrapper.MRP.ERP7__Status__c+ ' 3.mrpWrapper.MRP.ERP7__Total_Amount_Required__c : '+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                decimal stockAllocated = 0;
                
                if(mrpWrapper.Stock > 0 && mrpWrapper.MRP.ERP7__Status__c == 'Requested'){ 
                    Decimal requiredQty = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                    //system.debug('')
                    if (mrpWrapper.Stock <= 0) { //mrpWrapper.Stock < requiredQty
                        //comW.errorMsg = 'Insufficient stock for auto allocation. Available: ' + mrpWrapper.Stock + ', Required: ' + requiredQty;
                        //return comW;
                        continue;
                    }
                    //&& ((mrpWrapper.Stock >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c) || ((mrpWrapper.Stock + mrpWrapper.mrp.ERP7__Fulfilled_Amount__c) >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c))                   
                    // system.debug('if');
                    List<Inventory_Stock__c> WIISs = productSites.get(mrpWrapper.MRP.MRP_Product__c);
                    system.debug('stockAllocated 1: '+stockAllocated);
                    if(WIISs != Null && WIISs.size() > 0){
                        //bomStockAllocProdIds.add(mrpWrapper.MRP.MRP_Product__c);
                        system.debug('WIISs : Not null ');
                        ERP7__Inventory_Stock__c WIIS = (mrpWrapper.MRP.ERP7__Check_Out_Process__c == 'LIFO')? WIISs[WIISs.size()-1] : WIISs[0];
                        system.debug('WIIS : '+WIIS.ERP7__Number_of_Item_In_Stock__c);
                        
                        
                        // Single WIIS straight forward reduction and reserving
                        if((WIIS.ERP7__Number_of_Item_In_Stock__c + (mrpWrapper.mrp.ERP7__Fulfilled_Amount__c/WM) - SA) >= (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM)){
                            system.debug('In if 1');
                            if(SNS.size() > 0){
                                for(ERP7__Serial_Number__c SN : SNS){
                                    if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id)){
                                        system.debug('*** SNS In One: '+SN.Name);
                                        ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                        //if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - Mapexistingstock.get(mrpWrapper.MRP.Id) ;
                                        //else SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c;
                                        stockAllocated += (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM);
                                        SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(6);
                                       
                                        SA = SA + SDLI.ERP7__Quantity__c;
                            			bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                                        Decimal WIIS_Allocated = inventoryStockAllocated.get(WIIS.Id);
                                        inventoryStockAllocated.put(WIIS.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c)); 

                                        
                                        SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                        if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                        if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                        if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                        if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                            SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                            SDLI.Total_Amount__c = SDLI.ERP7__Quantity__c*SDLI.Unit_Price__c;
                                        }
                                        if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                        if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                        if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                        SDLIs2Upsert.add(SDLI);
                                        MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                    }
                                    
                                }
                            }
                            else{ 
                                system.debug('*** SNS out One: ');
                                ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) {
                                    system.debug('out 1');
                                    stockAllocated +=  (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM) - Mapexistingstock.get(mrpWrapper.MRP.Id);
                                    SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM - Mapexistingstock.get(mrpWrapper.MRP.Id);
                                    System.debug('what is total req qty ?'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                                }
                                else { system.debug('out 2'); SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM).setScale(6); stockAllocated += (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM);}
                                System.debug('what is total req qty ?'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                                if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                    SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                    SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                }
                                if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                System.debug('what is total req qty ?'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                                if(mrpWrapper.Stock < SDLI.ERP7__Quantity__c) SDLI.ERP7__Quantity__c = mrpWrapper.Stock;
                                SA = SA + SDLI.ERP7__Quantity__c;
                                bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);
                                
                                Decimal WIIS_Allocated = inventoryStockAllocated.get(WIIS.Id);
                                inventoryStockAllocated.put(WIIS.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c));   

                                SDLIs2Upsert.add(SDLI);
                            }
                            system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c bfr : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                            system.debug('stockAllocated : '+stockAllocated);
                            system.debug('WM : '+WM);
                            
                            mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = (mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (stockAllocated * WM)).setScale(6); //added setscale on 20_10_2023  //mrpWrapper.MRP.ERP7__Total_Amount_Required__c; change added by shaguftha 11/09/23
                            system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c 1 : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                            mrpWrapper.Stock = (mrpWrapper.Stock - stockAllocated).setScale(6); // added setScale on 20_10_23
                            system.debug('1 : mrpWrapper.Stock : '+mrpWrapper.Stock);
                            mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                            if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c == mrpWrapper.MRP.ERP7__Total_Amount_Required__c) mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                            MRPs2Upsert.add(mrpWrapper.MRP);
                            comW.errorMsg = '';
                            mrpWrapret.add(mrpWrapper); 
                            
                        }
                            
                        //Multiple WIIS calculative Reserving and other calculations
                        else if(WIIS.ERP7__Number_of_Item_In_Stock__c - SA < mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM){
                            system.debug('else if 1');
                            
                            //Need Change Imran
                            Decimal remainingqty = 0;

                            for(Inventory_Stock__c stk : WIISs){
                                System.debug('in for stk ->'+stk);System.debug('inventoryStockAllocated.get(stk.Id)->'+inventoryStockAllocated.get(stk.Id));
                                 Decimal WIISStock = stk.ERP7__Number_of_Item_In_Stock__c - inventoryStockAllocated.get(stk.Id);
                                 if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c != mrpWrapper.MRP.ERP7__Total_Amount_Required__c && mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                    if(SNS.size() > 0){
                                       system.debug('WIISStock : '+WIISStock);
                                        if(WIISStock > 0 && WIISStock >= (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)){ 
                                            System.debug('bfr loop ERP7__Total_Amount_Required__c->'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c+'stockAllocated->'+stockAllocated);
                                            while(SNSMap.values().size() > 0 && stockAllocated<mrpWrapper.MRP.ERP7__Total_Amount_Required__c){//matheen aulterd condition
                                                ERP7__Serial_Number__c SN = SNSMap.values()[0];
                                                system.debug('SN : '+SN);
                                                system.debug('!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) : '+!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id));
                                                //for(ERP7__Serial_Number__c SN : SNS){ 
                                                Decimal alreadyAllocated = serialAllocatedQty.containsKey(SN.Id) ? serialAllocatedQty.get(SN.Id) : 0;
                                                Decimal maxAllowed = mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c / WM;
                                                Boolean isFullyAllocated = alreadyAllocated >= maxAllowed;
                                                System.debug('isFullyAllocated->'+isFullyAllocated+'alreadyAllocated->'+alreadyAllocated+'maxAllowed'+maxAllowed);
                                                System.debug('mapexisting or is fully allocated ->'+(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) || !isFullyAllocated));
                                                if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) || !isFullyAllocated){ // && WIISStock > 0 && WIISStock >= (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)
                                                    system.debug('*** SNS In two : '+SN.Name);
                                                    ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                                    //totalAllocatedQty += stk.ERP7__Number_of_Item_In_Stock__c;
                                                    //if(((mrpWrapper.MRP.ERP7__Total_Amount_Required__c == stk.ERP7__Number_of_Item_In_Stock__c) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c > (stk.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c))) || remainingqty >= stk.ERP7__Number_of_Item_In_Stock__c || remainingqty == 0) { SDLI.ERP7__Quantity__c = stk.ERP7__Number_of_Item_In_Stock__c; system.debug('stk.ERP7__Number_of_Item_In_Stock__c 1 ***: '+stk.ERP7__Number_of_Item_In_Stock__c); }
                                                    //else if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) { SDLI.ERP7__Quantity__c = remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id); system.debug('SDLI.ERP7__Quantity__c  1 ***: '+SDLI.ERP7__Quantity__c ); }
                                                    //else { SDLI.ERP7__Quantity__c = remainingqty;  system.debug('remainingqty  1 ***: '+remainingqty );}//stk.ERP7__Number_of_Item_In_Stock__c -  mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                                    //stockAllocated += (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM);
                                                   //matheen changes 6-4-25 
                                                    // Decimal remain=0.0;
                                                    // remain=(mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c)/WM;
                                                    // if(remain < (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)){ 
                                                    //       SDLI.ERP7__Quantity__c = remain;
                                                    //    	  System.debug('in if ->'+SDLI.ERP7__Quantity__c);
                                                    // }
                                                    // else {
                                                    //     SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                                    //      System.debug('in else ->'+SDLI.ERP7__Quantity__c);
                                                    // }
                                                   // Decimal alreadyAllocated = serialAllocatedQty.containsKey(SN.Id) ? serialAllocatedQty.get(SN.Id) : 0;
                                                    //Decimal maxAllowed = mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c / WM;
                                                    Decimal remainingForSerial = maxAllowed - alreadyAllocated;
													System.debug('remainingForSerial->'+remainingForSerial+'serial->'+SN.Id);
                                                    if(remainingForSerial <= 0) {
                                                        System.debug('removing serial 1 ->'+SN.Id+'remainingForSerial='+remainingForSerial);
                                                        SNSMap.remove(SN.Id);
                                                        continue;
                                                    }

                                                    Decimal toAllocate = Math.min(WIISStock, remainingForSerial);
                                                    SDLI.ERP7__Quantity__c = toAllocate;
                                                    stockAllocated += SDLI.ERP7__Quantity__c;

                                                    //  Track allocated
                                                    serialAllocatedQty.put(SN.Id, alreadyAllocated + toAllocate);
                                                    // changes ends from matheen
                                                    //stockAllocated += (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM); // commented by matheen
                                                   // stockAllocated+=SDLI.ERP7__Quantity__c;
                                                    system.debug('stockAllocated 2: '+stockAllocated);
                                                    //SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                                    
                                                    SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                                    if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                                    
                                                    if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                                    if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                                    if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                                        SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                                        SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                                    }
                                                    if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                                    if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                                    if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                                    SDLIs2Upsert.add(SDLI);
                                                    
                                                    SA = SA + SDLI.ERP7__Quantity__c;
                                                    System.debug('SA in SNS TWO->'+SA);
                            						bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                                                     Decimal WIIS_Allocated = inventoryStockAllocated.get(stk.Id);
                                                    inventoryStockAllocated.put(stk.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c)); 



                                                    
                                                    mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4);
                                                    WIISStock = WIISStock - SDLI.ERP7__Quantity__c;
                                                    system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP Fulfilled QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                                    MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                                    System.debug('WIISStock->'+WIISStock+'SDLI.ERP7__Quantity__c->'+SDLI.ERP7__Quantity__c);
                                                    if(WIISStock <= 0) break;//|| WIISStock < SDLI.ERP7__Quantity__c removed by matheen
                                                }
                                                if(isFullyAllocated){
                                                    System.debug('removing serial 2 ->'+SN.Id);
                                                	SNSMap.remove(SN.Id);
                                                	system.debug('SNSMap 2 : '+SNSMap.size());  
                                                }
                                               
                                            }
                                        }
                                        // Start Shaguftha change 23_11_23
                                        else if(WIISStock > 0 && WIISStock < (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)){
                                            while(SNSMap.values().size() > 0){
                                                ERP7__Serial_Number__c SN = SNSMap.values()[0];
                                                system.debug('SN : '+SN);
                                                system.debug('!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) : '+!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id));
                                                 Decimal alreadyAllocated = serialAllocatedQty.containsKey(SN.Id) ? serialAllocatedQty.get(SN.Id) : 0;
                                                Decimal maxAllowed = mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c / WM;
                                                Boolean isFullyAllocated = alreadyAllocated >= maxAllowed;
                                                System.debug('isFullyAllocated->'+isFullyAllocated+'alreadyAllocated->'+alreadyAllocated+'maxAllowed'+maxAllowed);
                                                System.debug('mapexisting or is fully allocated ->'+(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) || !isFullyAllocated));
                                                if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) || !isFullyAllocated){ // && WIISStock > 0 && WIISStock >= (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)
                                                    system.debug('*** SNS In two 3 : '+SN.Name);
                                                    ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                                    //stockAllocated += (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM);
                                                     // matheen changes starts 7-4-25
                                                   // Decimal alreadyAllocated = serialAllocatedQty.containsKey(SN.Id) ? serialAllocatedQty.get(SN.Id) : 0;
                                                   // Decimal maxAllowed = mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c / WM;
                                                    Decimal remainingForSerial = maxAllowed - alreadyAllocated;
													System.debug('remainingForSerial->'+remainingForSerial+'serial->'+SN.Id);
                                                    if (remainingForSerial <= 0) {
                                                        System.debug('removing serial 1 ->'+SN.Id+'remainingForSerial='+remainingForSerial);
                                                        SNSMap.remove(SN.Id);
                                                        continue;
                                                    }

                                                    Decimal toAllocate = Math.min(WIISStock, remainingForSerial);
                                                    SDLI.ERP7__Quantity__c = toAllocate;
                                                    serialAllocatedQty.put(SN.Id, alreadyAllocated + toAllocate);

                                                    //matheen changes ends 
                                                    system.debug('stockAllocated 3: '+stockAllocated);
                                                    //SDLI.ERP7__Quantity__c = WIISStock; //commented by matheen (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                                    stockAllocated += SDLI.ERP7__Quantity__c;
                                                    system.debug('stockAllocated 4: '+stockAllocated);
                                                    SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                                    if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                                    
                                                    if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                                    if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                                    if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                                        SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                                        SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                                    }
                                                    if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                                    if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                                    if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                                    SDLIs2Upsert.add(SDLI);
                                                     //matheen added changes 6-4-25
                                                    SA = SA + SDLI.ERP7__Quantity__c;
                                                    System.debug('SA in SNS THREE->'+SA);
                            						bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                                                     Decimal WIIS_Allocated = inventoryStockAllocated.get(stk.Id);
                                                    inventoryStockAllocated.put(stk.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c)); 
                                                    // matheen changes ends 
                                                    mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4);
                                                    WIISStock = WIISStock - SDLI.ERP7__Quantity__c;
                                                    system.debug('SDLI else if 3: '+SDLI.ERP7__Quantity__c+' MRP Fulfilled QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                                    if(SerialsStockAllocated.containsKey(SN.Id)) SerialsStockAllocated.put(SN.Id,(SerialsStockAllocated.get(SN.Id) + SDLI.ERP7__Quantity__c));
                                                    else SerialsStockAllocated.put(SN.Id,SDLI.ERP7__Quantity__c);
                                                    if(SerialsStockAllocated.containsKey(SN.Id) && SerialsStockAllocated.get(SN.Id) == (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)) MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                                    System.debug('WIISStock->'+WIISStock+'SDLI.ERP7__Quantity__c->'+SDLI.ERP7__Quantity__c);
                                                    if(WIISStock <= 0) break; //|| WIISStock < SDLI.ERP7__Quantity__c removed by matheen                                                   
                                                }
                                                if(isFullyAllocated){
                                                    System.debug('removing serial 3e ->'+SN.Id);
                                                	SNSMap.remove(SN.Id);
                                                	system.debug('SNSMap 3e : '+SNSMap.size());  
                                                }
                                            }
                                        }
                                        // end Shaguftha change 23_11_23
                                    }
                                    else{

                                        system.debug('*** SNS out two: ');
                                        ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                       // totalAllocatedQty += stk.ERP7__Number_of_Item_In_Stock__c;
                                                //    System.debug('== Debugging MRP Allocation Condition ==');
                                                //    System.debug('Total_Amount_Required: ' + mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                                                //    System.debug('Fulfilled_Amount: ' + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                                                //    System.debug('WM (Working Multiplier): ' + WM);
                                                //    System.debug('WIISStock: ' + WIISStock);
                                                //    System.debug('remainingqty: ' + remainingqty);
                                                    
                                                //     Individual condition components for clarity
                                                //     Decimal requiredDivWM = mrpWrapper.MRP.ERP7__Total_Amount_Required__c / WM;
                                                //    Decimal fulfilledDivWM = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c / WM;
                                                //     Decimal stockPlusFulfilled = WIISStock + fulfilledDivWM;
                                                    
                                                //    System.debug('Required / WM: ' + requiredDivWM);
                                                //    System.debug('Fulfilled / WM: ' + fulfilledDivWM);
                                                //    System.debug('Stock + Fulfilled: ' + stockPlusFulfilled);
                                                //    System.debug('Condition1 (Required / WM == WIISStock): ' + (requiredDivWM == WIISStock));
                                                //    System.debug('Condition2 (Required / WM > Stock + Fulfilled): ' + (requiredDivWM > stockPlusFulfilled));
                                                //    System.debug('Condition3 (remainingqty >= WIISStock): ' + (remainingqty >= WIISStock));
                                                //    System.debug('Condition4 (remainingqty == 0): ' + (remainingqty == 0));
											remainingqty = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c)/WM; // added by matheen bcz for 1st INV the remaining will be always 0 will lead to skip that INV 
                                        if (((mrpWrapper.MRP.ERP7__Total_Amount_Required__c / WM == WIISStock) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c / WM > (WIISStock + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c / WM))) || remainingqty >= WIISStock || remainingqty == 0) {
                                            /*stockAllocated += stk.ERP7__Number_of_Item_In_Stock__c;*/
                                            //added this condition by matheen 24/2/25
                                            System.debug('remainingqty->'+remainingqty+'WIISStock->'+WIISStock);
                                            if(remainingqty < WIISStock){ 
                                                SDLI.ERP7__Quantity__c =remainingqty ;
                                            }else {
                                                SDLI.ERP7__Quantity__c = WIISStock;
                                            }
                                            
                                            // matheen changes ends here
                                         
                                            system.debug('WIISStock ***: ' + WIISStock);
                                        } else if (Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) {
                                            SDLI.ERP7__Quantity__c = (remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id)).setScale(6); /*stockAllocated += (remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id));*/
                                            system.debug('SDLI.ERP7__Quantity__c  1 ***: ' + SDLI.ERP7__Quantity__c);
                                        } else {
                                            SDLI.ERP7__Quantity__c = (remainingqty).setScale(6); /*stockAllocated += remainingqty; */
                                            system.debug('remainingqty  1 ***: ' + remainingqty);
                                        } //stk.ERP7__Number_of_Item_In_Stock__c -  mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                        
                                        
                                        //partial allocation bushra
                                        if(mrpWrapper.Stock < SDLI.ERP7__Quantity__c) SDLI.ERP7__Quantity__c = mrpWrapper.Stock;
                                        SA = SA + SDLI.ERP7__Quantity__c;
                            			bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                                        Decimal WIIS_Allocated = inventoryStockAllocated.get(stk.Id);
                                        inventoryStockAllocated.put(stk.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c)); 
                                        
                                        stockAllocated += SDLI.ERP7__Quantity__c; // uncommented on 18_10_23
                                        
                                        if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                        if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                        if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                            SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                            SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                        }
                                        if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                        if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                        if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                        
                                        
                                        SDLIs2Upsert.add(SDLI);
                                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4); // 18_10_23 SDLI.ERP7__Quantity__c from StockAllocated
                                        system.debug('SDLI else if 4: '+SDLI.ERP7__Quantity__c+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                    }
                                    //mrpWrapper.Stock = mrpWrapper.Stock - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;       
                                    //mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + Decimal.valueOf(stockAllocated * WM);
                                     System.debug('mrpWrapper.MRP.ERP7__Total_Amount_Required__c 1639->'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c );
                                     System.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c 1640-> '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                                     remainingqty = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c)/WM;
                                     System.debug('remainingqty 1643->'+remainingqty);
                                    if(remainingqty < 0) remainingqty = 0;
                                    system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c 1 : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                                    if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                        Decimal totalFulfilled =  (Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) ?  (Mapexistingstock.get(mrpWrapper.MRP.Id)) : 0;
                                        /*for(ERP7__Stock_Outward_Line_Item__c ss : SDLIs2Upsert){
                                                    if(ss.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) totalFulfilled += ss.ERP7__Quantity__c;
                                                    }*/ 
                                        System.debug('totalFulfilled : '+totalFulfilled);
                                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = (totalFulfilled * WM) + (stockAllocated * WM); // added * WM for totalfulfilled Shaguftha 02_01_2024
                                        system.debug('totalFulfilled else if 2 after: '+totalFulfilled+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                        if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c) mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                                        // mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                        system.debug('mrpWrapper.Stock  : '+mrpWrapper.Stock);
                                        //  MRPs2Upsert.add(mrpWrapper.MRP);
                                        comW.errorMsg = '';
                                        mrpWrapret.add(mrpWrapper);
                                        break;
                                    } 
                                }
                            } // for WIIS
                            system.debug('stockAllocated : '+stockAllocated);
                            system.debug('mrpWrapper.Stock : '+mrpWrapper.Stock);
                            mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                            mrpWrapper.Stock = mrpWrapper.Stock - stockAllocated;
                            MRPs2Upsert.add(mrpWrapper.MRP);
                            mrpWrapret.add(mrpWrapper); 
                            system.debug('MRPs2Upsert : '+MRPs2Upsert);
                        } // Multiple WIIS
                        
                        
                    } // WIIS size > 0
                } // MRP Stock > 0   
            }
            mrpWrappers = new List<mrpWrap>();
            System.debug('Limits.getCpuTime 2- '+ Limits.getCpuTime());
            System.debug('Limits.getLimitCpuTime 2- '+ Limits.getLimitCpuTime());
            System.debug('Limits.getHeapSize 2- '+ Limits.getHeapSize());
            System.debug('Limits.getLimitHeapSize 2- '+ Limits.getLimitHeapSize());
            
            if(SDLIs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()){ PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler=false; upsert SDLIs2Upsert;}else{comW.errorMsg ='Not allowed to upsert SDLI';} }
            SDLIs2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            if(MRPs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){PreventRecursiveLedgerEntry.MRPFlowTrigger = false; upsert MRPs2Upsert;}else{comW.errorMsg ='Not allowed to upsert MRPs';} }
            List<mrpWrap> retunrMRP = new List<mrpWrap>();
            for(mrpWrap mrpWrapper : mrpWrapret){
                for(ERP7__MRP__c mrp : MRPs2Upsert){
                    if(mrpWrapper.MRP.ERP7__MRP_Product__c == mrp.ERP7__MRP_Product__c){  
                        mrpWrapper.MRP = mrp;
                        // mrpWrapper.Stock = mrpWrapper.Stock - mrp.ERP7__Fulfilled_Amount__c;
                        system.debug('mrpWrapper.Stock : '+mrpWrapper.Stock);
                    }                    
                }
                retunrMRP.add(mrpWrapper);
            }
            MRPs2Upsert = new List<ERP7__MRP__c>();
            mrpWrapret = new List<mrpWrap>();
            comW.MRPs=retunrMRP;
            retunrMRP = new List<mrpWrap>();
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }
        return comW;
    } 
    
 /*  @AuraEnabled 
public static comWrap ReserveMRPSStocksNew(String MRPs,Integer AutostkLimit){ 
    List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
    comWrap comW = new comWrap();
    system.debug('AutostkLimit : '+AutostkLimit);
    try{
        comW.errorMsg = '';
        Set<Id> bomStockAllocProdIds = new Set<Id>();
        List<mrpWrap> mrpWrapret = new List<mrpWrap>();

        // FIX: comW.manuOrders is not set in this method; avoid null deref
        String selectedSite = null;
        String finishedProduct = null;

        List<Id> proIds = new List<Id>();
        //Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
        set<Id> MRPIds = new set<Id>();
        Map<Id,List<Inventory_Stock__c>> productSites = new Map<Id,List<Inventory_Stock__c>>();
        Map<Id,Decimal> Mapexistingstock = new Map<Id,Decimal>();
        Map<Id,Set<Id>> MapexistingstockSerials = new Map<Id,Set<Id>>();
        String MOId = '';
        Map<Id,decimal> bomDupProductStockAllocated = new Map<Id,decimal>();
        Map<Id,decimal> inventoryStockAllocated = new Map<Id,decimal>();
        Map<Id, Decimal> serialAllocatedQty = new Map<Id, Decimal>();

        for(mrpWrap mrpWrapper : mrpWrappers){
            if(MOId == '') MOId = mrpWrapper.mrp.ERP7__MO__c;
            if(mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != Null) selectedSite = mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            if(mrpWrapper.mrp.ERP7__MRP_Product__c != Null) proIds.add(mrpWrapper.mrp.ERP7__MRP_Product__c);
            MRPIds.add(mrpWrapper.mrp.Id);

            if(mrpWrapper.mrp.MRP_Product__c != Null) bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, 0);
        }

        // FIX: SOQL syntax IN :MRPIds (was In:MRPIds)
        List<ERP7__Stock_Outward_Line_Item__c> fulfilledStock = [
            Select Id,Name,ERP7__Quantity__c,ERP7__MRP_Material_Requirements_Planning__c,ERP7__MO_WO_Serial__c
            from ERP7__Stock_Outward_Line_Item__c
            where ERP7__MRP_Material_Requirements_Planning__c IN :MRPIds
            and ERP7__Active__c =true
        ];

        List<ERP7__Serial_Number__c> SNS = new List<ERP7__Serial_Number__c> ();
        Map<Id,ERP7__Serial_Number__c> SNSMap = new Map<Id,ERP7__Serial_Number__c> ();
        ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c();

        Set<Id> SerialNos = new Set<Id>();

        for(mrpWrap mrpWrapper : mrpWrappers){
            Decimal allocatedqty = 0;

            // FIX: per-MRP set, do not reuse one shared Set across MRPs
            Set<Id> mrpSerials = new Set<Id>();

            for(ERP7__Stock_Outward_Line_Item__c stk : fulfilledStock){
                if(stk.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) {
                    // FIX: outward quantities may be stored negative; treat allocated as absolute
                    Decimal q = (stk.ERP7__Quantity__c == null) ? 0 : Math.abs(stk.ERP7__Quantity__c);
                    allocatedqty += q;

                    if(stk.ERP7__MO_WO_Serial__c != Null){
                        mrpSerials.add(stk.ERP7__MO_WO_Serial__c);
                        SerialNos.add(stk.ERP7__MO_WO_Serial__c);

                        // new changes by matheen 7-4-25 (FIXED: use ABS qty as well)
                        if (!serialAllocatedQty.containsKey(stk.ERP7__MO_WO_Serial__c)) {
                            serialAllocatedQty.put(stk.ERP7__MO_WO_Serial__c, q);
                        } else {
                            serialAllocatedQty.put(
                                stk.ERP7__MO_WO_Serial__c,
                                serialAllocatedQty.get(stk.ERP7__MO_WO_Serial__c) + q
                            );
                        }
                        // new changes ends
                    }
                }
            }
            MapexistingstockSerials.put(mrpWrapper.MRP.Id, mrpSerials);
            if(allocatedqty > 0) Mapexistingstock.put(mrpWrapper.MRP.Id,allocatedqty);
        }
        fulfilledStock = new List<ERP7__Stock_Outward_Line_Item__c>();

        // ===========================
        // FIX: choose one MO end-serial and attach it to ALL BOM SDLI lines
        // ===========================
        Id endMoSerialId = null;
        Id endMoSerialBatchLotId = null;

        if(MOId != '') {
            MO = [Select Id, Name, ERP7__Product__c, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Product__r.ERP7__Serialise__c From ERP7__Manufacturing_Order__c Where Id =: MOId];
            if(selectedSite == null) selectedSite = MO.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            finishedProduct = MO.ERP7__Product__c;

            if(MO.ERP7__Product__r.ERP7__Serialise__c == true) {
                SNSMap = new Map<Id,ERP7__Serial_Number__c> ([Select Id, Name, ERP7__Material_Batch_Lot__c, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Serial_Number__c Where ERP7__Manufacturing_Order__c =: MO.Id and Id Not IN :SerialNos limit :AutostkLimit]);
                SNS = SNSMap.Values();

                // pick 1 end-product serial to apply to all BOM SDLI lines
                if(SNS != null && !SNS.isEmpty()){
                    endMoSerialId = SNS[0].Id;
                    endMoSerialBatchLotId = SNS[0].ERP7__Material_Batch_Lot__c;
                }
            }
        }
        //system.debug('*** SNS : '+SNS.size());
        if(selectedSite != Null && selectedSite != ''){
            String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
            String AllWarehouseFields = WarehouseFields + '';
            List<ERP7__Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', ERP7__Warehouse__r.Name, ERP7__Location__r.Name, ERP7__StorageContainer__r.Name, ERP7__Warehouse__r.ERP7__Barcode__c, ERP7__Location__r.ERP7__Barcode__c, '+
                                                                      +' ERP7__StorageContainer__r.ERP7__Barcode__c from ERP7__Inventory_Stock__c where (ERP7__Warehouse__c =: selectedSite And (ERP7__Product__c In: proIds And ERP7__Number_of_Item_In_Stock__c > 0) And ERP7__Active__c = true) Order By ERP7__Expiry_Date__c ASC NULLS LAST, ERP7__Checked_In_Date__c ASC Limit 1000');

           // Order By ERP7__Checked_In_Date__c ASC, ERP7__Expiration_Date__c ASC NULLS LAST  changed this by matheen on 30/4/25
            System.debug('WIISLists->'+WIISLists);
            List<ERP7__Inventory_Stock__c> withExpirationDate = new List<ERP7__Inventory_Stock__c>();
            List<ERP7__Inventory_Stock__c> withoutExpirationDate = new List<ERP7__Inventory_Stock__c>();

            for (ERP7__Inventory_Stock__c record : WIISLists) {
                inventoryStockAllocated.put(record.Id, 0);
                if (record.ERP7__Expiration_Date__c != null) {
                    withExpirationDate.add(record);
                } else {
                    withoutExpirationDate.add(record);
                }
            }

            // Manual sort of the list with Expiration_Date__c
            for (Integer i = 0; i < withExpirationDate.size() - 1; i++) {
                for (Integer j = i + 1; j < withExpirationDate.size(); j++) {
                    if (withExpirationDate[i].ERP7__Expiration_Date__c > withExpirationDate[j].ERP7__Expiration_Date__c) {
                        // Swap elements if needed
                        ERP7__Inventory_Stock__c temp = withExpirationDate[i];
                        withExpirationDate[i] = withExpirationDate[j];
                        withExpirationDate[j] = temp;
                    }
                }
            }

            // Merge the sorted lists while maintaining the original order for records without expiration dates
            List<ERP7__Inventory_Stock__c> sortedInventoryStocks = new List<ERP7__Inventory_Stock__c>();
            Integer expIndex = 0;
            Integer noExpIndex = 0;

            for (ERP7__Inventory_Stock__c record : WIISLists) {
                if (record.ERP7__Expiration_Date__c != null) {
                    sortedInventoryStocks.add(withExpirationDate[expIndex]);
                    expIndex++;
                } else {
                    sortedInventoryStocks.add(withoutExpirationDate[noExpIndex]);
                    noExpIndex++;
                }
            }

            for(Id proId : proIds){
                Decimal myStock = 0;
                if(!productSites.containsKey(proId)) productSites.put(proId, new List<ERP7__Inventory_Stock__c>());
                for(ERP7__Inventory_Stock__c stock : sortedInventoryStocks){
                    if(proId == stock.Product__c){
                        List<ERP7__Inventory_Stock__c> myStocks = productSites.get(proId);
                        myStocks.add(stock);
                        productSites.put(proId,myStocks);
                    }
                }
            }
            WIISLists = new List<ERP7__Inventory_Stock__c>();
        }

        List<Stock_Outward_Line_Item__c> SDLIs2Upsert = new List<Stock_Outward_Line_Item__c>();
        List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();

        System.debug('Limits.getCpuTime 1- '+ Limits.getCpuTime());
        System.debug('Limits.getLimitCpuTime 1- '+ Limits.getLimitCpuTime());
        System.debug('Limits.getHeapSize 1- '+ Limits.getHeapSize());
        System.debug('Limits.getLimitHeapSize 1- '+ Limits.getLimitHeapSize());
        Map<Id,decimal> SerialsStockAllocated = new Map<Id,decimal>();

        for(mrpWrap mrpWrapper : mrpWrappers){
            System.debug('SNSMAP->'+SNSMAP);
            Decimal SA = bomDupProductStockAllocated.get(mrpWrapper.mrp.MRP_Product__c);
            mrpWrapper.Stock = mrpWrapper.Stock - SA;

            System.debug('in for main logic');

            Decimal WM = mrpWrapper.WeightMultiplier;
            system.debug('Product : '+mrpWrapper.MRP.MRP_Product__c+'   mrpWrapper.Stock : '+mrpWrapper.Stock+ ' 2.mrpWrapper.MRP.ERP7__Status__c : '+mrpWrapper.MRP.ERP7__Status__c+ ' 3.mrpWrapper.MRP.ERP7__Total_Amount_Required__c : '+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
            decimal stockAllocated = 0;

            if(mrpWrapper.Stock > 0 && mrpWrapper.MRP.ERP7__Status__c == 'Requested'){ 
                Decimal requiredQty = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                if (mrpWrapper.Stock <= 0) {
                    continue;
                }

                // FIX: serial logic must be decided by BOM product, not global SNS size
                Boolean isSerialProduct = (mrpWrapper.MRP.ERP7__MRP_Product__r != null && mrpWrapper.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true);

                List<Inventory_Stock__c> WIISs = productSites.get(mrpWrapper.MRP.MRP_Product__c);
                system.debug('stockAllocated 1: '+stockAllocated);
                if(WIISs != Null && WIISs.size() > 0){
                    system.debug('WIISs : Not null ');
                    ERP7__Inventory_Stock__c WIIS = (mrpWrapper.MRP.ERP7__Check_Out_Process__c == 'LIFO')? WIISs[WIISs.size()-1] : WIISs[0];
                    system.debug('WIIS : '+WIIS.ERP7__Number_of_Item_In_Stock__c);

                    if((WIIS.ERP7__Number_of_Item_In_Stock__c + (mrpWrapper.mrp.ERP7__Fulfilled_Amount__c/WM) - SA) >= (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM)){
                        system.debug('In if 1');
                        if(isSerialProduct && SNS.size() > 0){
                            for(ERP7__Serial_Number__c SN : SNS){
                                if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id)){
                                    system.debug('*** SNS In One: '+SN.Name);
                                    ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                    stockAllocated += (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM);
                                    SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);

                                    SA = SA + SDLI.ERP7__Quantity__c;
                                    bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                                    Decimal WIIS_Allocated = inventoryStockAllocated.get(WIIS.Id);
                                    inventoryStockAllocated.put(WIIS.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c)); 

                                    SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                    if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                    if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                    if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                    if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                        SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                        SDLI.Total_Amount__c = SDLI.ERP7__Quantity__c*SDLI.Unit_Price__c;
                                    }
                                    if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                    if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                    if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                    SDLIs2Upsert.add(SDLI);
                                    MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                }
                            }
                        }
                        else{ 
                            system.debug('*** SNS out One: ');
                            ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);

                            // FIX: attach end-product serial to ALL BOM SDLI lines (when MO is serialized)
                            if(endMoSerialId != null){
                                SDLI.ERP7__MO_WO_Serial__c = endMoSerialId;
                                if(endMoSerialBatchLotId != null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = endMoSerialBatchLotId;
                            }

                            if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) {
                                system.debug('out 1');
                                stockAllocated +=  (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM) - Mapexistingstock.get(mrpWrapper.MRP.Id);
                                SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM - Mapexistingstock.get(mrpWrapper.MRP.Id);
                                System.debug('what is total req qty ?'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                            }
                            else { system.debug('out 2'); SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM).setScale(4); stockAllocated += (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM);}

                            System.debug('what is total req qty ?'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                            if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                            if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                            if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                            }
                            if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                            if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                            if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                            System.debug('what is total req qty ?'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                            if(mrpWrapper.Stock < SDLI.ERP7__Quantity__c) SDLI.ERP7__Quantity__c = mrpWrapper.Stock;

                            SA = SA + SDLI.ERP7__Quantity__c;
                            bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                            Decimal WIIS_Allocated = inventoryStockAllocated.get(WIIS.Id);
                            inventoryStockAllocated.put(WIIS.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c));   

                            SDLIs2Upsert.add(SDLI);
                        }
                        system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c bfr : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                        system.debug('stockAllocated : '+stockAllocated);
                        system.debug('WM : '+WM);

                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = (mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (stockAllocated * WM)).setScale(4);
                        if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < 0) mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = 0;

                        system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c 1 : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                        mrpWrapper.Stock = (mrpWrapper.Stock - stockAllocated).setScale(4);
                        system.debug('1 : mrpWrapper.Stock : '+mrpWrapper.Stock);
                        mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                        if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c == mrpWrapper.MRP.ERP7__Total_Amount_Required__c) mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                        MRPs2Upsert.add(mrpWrapper.MRP);
                        comW.errorMsg = '';
                        mrpWrapret.add(mrpWrapper); 
                    }

                    else if(WIIS.ERP7__Number_of_Item_In_Stock__c - SA < mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM){
                        system.debug('else if 1');
                        Decimal remainingqty = 0;

                        for(Inventory_Stock__c stk : WIISs){
                            System.debug('in for stk ->'+stk);System.debug('inventoryStockAllocated.get(stk.Id)->'+inventoryStockAllocated.get(stk.Id));
                             Decimal WIISStock = stk.ERP7__Number_of_Item_In_Stock__c - inventoryStockAllocated.get(stk.Id);
                             if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c != mrpWrapper.MRP.ERP7__Total_Amount_Required__c && mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < mrpWrapper.MRP.ERP7__Total_Amount_Required__c){

                                if(isSerialProduct && SNS.size() > 0){
                                   system.debug('WIISStock : '+WIISStock);
                                    if(WIISStock > 0 && WIISStock >= (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)){ 
                                        System.debug('bfr loop ERP7__Total_Amount_Required__c->'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c+'stockAllocated->'+stockAllocated);
                                        while(SNSMap.values().size() > 0 && stockAllocated<mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                            ERP7__Serial_Number__c SN = SNSMap.values()[0];
                                            system.debug('SN : '+SN);
                                            system.debug('!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) : '+!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id));
                                            Decimal alreadyAllocated = serialAllocatedQty.containsKey(SN.Id) ? serialAllocatedQty.get(SN.Id) : 0;
                                            Decimal maxAllowed = mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c / WM;
                                            Boolean isFullyAllocated = alreadyAllocated >= maxAllowed;
                                            System.debug('isFullyAllocated->'+isFullyAllocated+'alreadyAllocated->'+alreadyAllocated+'maxAllowed'+maxAllowed);
                                            System.debug('mapexisting or is fully allocated ->'+(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) || !isFullyAllocated));
                                            if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) || !isFullyAllocated){
                                                system.debug('*** SNS In two : '+SN.Name);
                                                ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);

                                                Decimal remainingForSerial = maxAllowed - alreadyAllocated;
                                                System.debug('remainingForSerial->'+remainingForSerial+'serial->'+SN.Id);
                                                if(remainingForSerial <= 0) {
                                                    System.debug('removing serial 1 ->'+SN.Id+'remainingForSerial='+remainingForSerial);
                                                    SNSMap.remove(SN.Id);
                                                    continue;
                                                }

                                                Decimal toAllocate = Math.min(WIISStock, remainingForSerial);
                                                SDLI.ERP7__Quantity__c = toAllocate;
                                                stockAllocated += SDLI.ERP7__Quantity__c;

                                                serialAllocatedQty.put(SN.Id, alreadyAllocated + toAllocate);

                                                system.debug('stockAllocated 2: '+stockAllocated);

                                                SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                                if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;

                                                if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                                if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                                if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                                    SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                                    SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                                }
                                                if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                                if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                                if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                                SDLIs2Upsert.add(SDLI);

                                                SA = SA + SDLI.ERP7__Quantity__c;
                                                System.debug('SA in SNS TWO->'+SA);
                            						bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                                                Decimal WIIS_Allocated = inventoryStockAllocated.get(stk.Id);
                                                inventoryStockAllocated.put(stk.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c)); 

                                                mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);
                                                if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < 0) mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = 0;

                                                WIISStock = WIISStock - SDLI.ERP7__Quantity__c;
                                                system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP Fulfilled QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                                MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                                System.debug('WIISStock->'+WIISStock+'SDLI.ERP7__Quantity__c->'+SDLI.ERP7__Quantity__c);
                                                if(WIISStock <= 0) break;
                                            }
                                            if(isFullyAllocated){
                                                System.debug('removing serial 2 ->'+SN.Id);
                                                	SNSMap.remove(SN.Id);
                                                	system.debug('SNSMap 2 : '+SNSMap.size());  
                                            }
                                        }
                                    }
                                    else if(WIISStock > 0 && WIISStock < (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)){
                                        while(SNSMap.values().size() > 0){
                                            ERP7__Serial_Number__c SN = SNSMap.values()[0];
                                            system.debug('SN : '+SN);
                                            system.debug('!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) : '+!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id));
                                             Decimal alreadyAllocated = serialAllocatedQty.containsKey(SN.Id) ? serialAllocatedQty.get(SN.Id) : 0;
                                            Decimal maxAllowed = mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c / WM;
                                            Boolean isFullyAllocated = alreadyAllocated >= maxAllowed;
                                            System.debug('isFullyAllocated->'+isFullyAllocated+'alreadyAllocated->'+alreadyAllocated+'maxAllowed'+maxAllowed);
                                            System.debug('mapexisting or is fully allocated ->'+(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) || !isFullyAllocated));
                                            if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) || !isFullyAllocated){
                                                system.debug('*** SNS In two 3 : '+SN.Name);
                                                ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);

                                                Decimal remainingForSerial = maxAllowed - alreadyAllocated;
                                                System.debug('remainingForSerial->'+remainingForSerial+'serial->'+SN.Id);
                                                if (remainingForSerial <= 0) {
                                                    System.debug('removing serial 1 ->'+SN.Id+'remainingForSerial='+remainingForSerial);
                                                    SNSMap.remove(SN.Id);
                                                    continue;
                                                }

                                                Decimal toAllocate = Math.min(WIISStock, remainingForSerial);
                                                SDLI.ERP7__Quantity__c = toAllocate;
                                                serialAllocatedQty.put(SN.Id, alreadyAllocated + toAllocate);

                                                system.debug('stockAllocated 3: '+stockAllocated);
                                                stockAllocated += SDLI.ERP7__Quantity__c;
                                                system.debug('stockAllocated 4: '+stockAllocated);
                                                SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                                if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;

                                                if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                                if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                                if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                                    SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                                    SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                                }
                                                if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                                if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                                if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                                SDLIs2Upsert.add(SDLI);

                                                SA = SA + SDLI.ERP7__Quantity__c;
                                                System.debug('SA in SNS THREE->'+SA);
                            						bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                                                Decimal WIIS_Allocated = inventoryStockAllocated.get(stk.Id);
                                                inventoryStockAllocated.put(stk.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c)); 

                                                mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);
                                                if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < 0) mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = 0;

                                                WIISStock = WIISStock - SDLI.ERP7__Quantity__c;
                                                system.debug('SDLI else if 3: '+SDLI.ERP7__Quantity__c+' MRP Fulfilled QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                                if(SerialsStockAllocated.containsKey(SN.Id)) SerialsStockAllocated.put(SN.Id,(SerialsStockAllocated.get(SN.Id) + SDLI.ERP7__Quantity__c));
                                                else SerialsStockAllocated.put(SN.Id,SDLI.ERP7__Quantity__c);
                                                if(SerialsStockAllocated.containsKey(SN.Id) && SerialsStockAllocated.get(SN.Id) == (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)) MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                                System.debug('WIISStock->'+WIISStock+'SDLI.ERP7__Quantity__c->'+SDLI.ERP7__Quantity__c);
                                                if(WIISStock <= 0) break;                                                    
                                            }
                                            if(isFullyAllocated){
                                                System.debug('removing serial 3e ->'+SN.Id);
                                                	SNSMap.remove(SN.Id);
                                                	system.debug('SNSMap 3e : '+SNSMap.size());  
                                            }
                                        }
                                    }
                                }
                                else{
                                    system.debug('*** SNS out two: ');
                                    ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);

                                    // FIX: attach end-product serial to ALL BOM SDLI lines (when MO is serialized)
                                    if(endMoSerialId != null){
                                        SDLI.ERP7__MO_WO_Serial__c = endMoSerialId;
                                        if(endMoSerialBatchLotId != null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = endMoSerialBatchLotId;
                                    }

                                    remainingqty = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c)/WM; 
                                    if (((mrpWrapper.MRP.ERP7__Total_Amount_Required__c / WM == WIISStock) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c / WM > (WIISStock + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c / WM))) || remainingqty >= WIISStock || remainingqty == 0) {
                                        System.debug('remainingqty->'+remainingqty+'WIISStock->'+WIISStock);
                                        if(remainingqty < WIISStock){ 
                                            SDLI.ERP7__Quantity__c =remainingqty ;
                                        }else {
                                            SDLI.ERP7__Quantity__c = WIISStock;
                                        }

                                        system.debug('WIISStock ***: ' + WIISStock);
                                    } else if (Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) {
                                        SDLI.ERP7__Quantity__c = (remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id)).setScale(4);
                                        system.debug('SDLI.ERP7__Quantity__c  1 ***: ' + SDLI.ERP7__Quantity__c);
                                    } else {
                                        SDLI.ERP7__Quantity__c = (remainingqty).setScale(4);
                                        system.debug('remainingqty  1 ***: ' + remainingqty);
                                    }

                                    if(mrpWrapper.Stock < SDLI.ERP7__Quantity__c) SDLI.ERP7__Quantity__c = mrpWrapper.Stock;
                                    SA = SA + SDLI.ERP7__Quantity__c;
                                    bomDupProductStockAllocated.put(mrpWrapper.mrp.MRP_Product__c, SA);

                                    Decimal WIIS_Allocated = inventoryStockAllocated.get(stk.Id);
                                    inventoryStockAllocated.put(stk.Id, (WIIS_Allocated+SDLI.ERP7__Quantity__c)); 

                                    stockAllocated += SDLI.ERP7__Quantity__c;

                                    if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                    if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                    if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                        SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                        SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                    }
                                    if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                    if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                    if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;

                                    SDLIs2Upsert.add(SDLI);
                                    mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c * WM);
                                    if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < 0) mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = 0;

                                    system.debug('SDLI else if 4: '+SDLI.ERP7__Quantity__c+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                }

                                 System.debug('mrpWrapper.MRP.ERP7__Total_Amount_Required__c 1639->'+mrpWrapper.MRP.ERP7__Total_Amount_Required__c );
                                 System.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c 1640-> '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                                 remainingqty = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c)/WM;
                                 System.debug('remainingqty 1643->'+remainingqty);
                                if(remainingqty < 0) remainingqty = 0;
                                system.debug('mrpWrapper.MRP.ERP7__Fulfilled_Amount__c 1 : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                                if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                    Decimal totalFulfilled =  (Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) ?  (Mapexistingstock.get(mrpWrapper.MRP.Id)) : 0;
                                    System.debug('totalFulfilled : '+totalFulfilled);
                                    mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = (totalFulfilled * WM) + (stockAllocated * WM);
                                    if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < 0) mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = 0;

                                    system.debug('totalFulfilled else if 2 after: '+totalFulfilled+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                    if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c) mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                                    system.debug('mrpWrapper.Stock  : '+mrpWrapper.Stock);
                                    comW.errorMsg = '';
                                    mrpWrapret.add(mrpWrapper);
                                    break;
                                } 
                            }
                        }
                        system.debug('stockAllocated : '+stockAllocated);
                        system.debug('mrpWrapper.Stock : '+mrpWrapper.Stock);
                        mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                        mrpWrapper.Stock = mrpWrapper.Stock - stockAllocated;
                        MRPs2Upsert.add(mrpWrapper.MRP);
                        mrpWrapret.add(mrpWrapper); 
                        system.debug('MRPs2Upsert : '+MRPs2Upsert);
                    }
                }
            } 
        }
        mrpWrappers = new List<mrpWrap>();
        System.debug('Limits.getCpuTime 2- '+ Limits.getCpuTime());
        System.debug('Limits.getLimitCpuTime 2- '+ Limits.getLimitCpuTime());
        System.debug('Limits.getHeapSize 2- '+ Limits.getHeapSize());
        System.debug('Limits.getLimitHeapSize 2- '+ Limits.getLimitHeapSize());

        if(SDLIs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()){ PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler=false; upsert SDLIs2Upsert;}else{comW.errorMsg ='Not allowed to upsert SDLI';} }
        SDLIs2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
        if(MRPs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){PreventRecursiveLedgerEntry.MRPFlowTrigger = false; upsert MRPs2Upsert;}else{comW.errorMsg ='Not allowed to upsert MRPs';} }
        List<mrpWrap> retunrMRP = new List<mrpWrap>();
        for(mrpWrap mrpWrapper : mrpWrapret){
            for(ERP7__MRP__c mrp : MRPs2Upsert){
                if(mrpWrapper.MRP.ERP7__MRP_Product__c == mrp.ERP7__MRP_Product__c){  
                    mrpWrapper.MRP = mrp;
                    system.debug('mrpWrapper.Stock : '+mrpWrapper.Stock);
                }                    
            }
            retunrMRP.add(mrpWrapper);
        }
        MRPs2Upsert = new List<ERP7__MRP__c>();
        mrpWrapret = new List<mrpWrap>();
        comW.MRPs=retunrMRP;
        retunrMRP = new List<mrpWrap>();
    } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }
    return comW;
}*/





    @AuraEnabled
    public static comWrap SaveNewSOLI(String NewSOLI, String MRPs, String SerialNos,String locationId ){
        Savepoint sp = Database.setSavepoint();
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        ERP7__Stock_Outward_Line_Item__c mySOLI = (ERP7__Stock_Outward_Line_Item__c) JSON.deserialize(NewSOLI, ERP7__Stock_Outward_Line_Item__c .class);
        List<Id> moSerialNos = (List<Id>) JSON.deserialize(SerialNos, List<Id> .class);
        
        mrpWrap mrp = new mrpWrap();
        for(mrpWrap mrpW : mrpWrappers){
            if(mrpW.isSelect) mrp = mrpW;
        }
        comWrap comW = new comWrap();
        comW.errorMsg = '';
        try{
            if(mrp.isSelect){
                Decimal WM = mrp.WeightMultiplier;
                String selectedSite = mrp.MRP.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                String MOId = mrp.MRP.ERP7__MO__c;
                String Prod = mrp.MRP.ERP7__MRP_Product__c;
                if(selectedSite != Null && selectedSite != ''){
                    String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                    String AllWarehouseFields = WarehouseFields + ''; 
                    List<Inventory_Stock__c> WIISLists = new List<Inventory_Stock__c> ();
                  //  if(!mrp.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && !mrp.MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c)
                  //      WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c =: Prod And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC'); 
                   if(!mrp.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && !mrp.MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c) {
    String locId = locationId; // assign to local variable for SOQL binding
    if(locId != null && locId != '') {
        WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, StorageContainer__r.Barcode__c from Inventory_Stock__c where Warehouse__c =: selectedSite And Product__c =: Prod And Number_of_Item_In_Stock__c > 0 And Active__c = true And ERP7__Location__c =: locId Order By ERP7__Expiry_Date__c ASC');
    } else {
        WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, StorageContainer__r.Barcode__c from Inventory_Stock__c where Warehouse__c =: selectedSite And Product__c =: Prod And Number_of_Item_In_Stock__c > 0 And Active__c = true Order By ERP7__Expiry_Date__c ASC');
    }

                   } else if(mrp.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c){
                        List<ERP7__Stock_Inward_Line_Item__c>  SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                                                                        Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c,
                                                                        ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c
                                                                        From ERP7__Stock_Inward_Line_Item__c 
                                                                        Where Product__c = :Prod And 
                                                                        ERP7__Serial__c != Null And 
                                                                        ERP7__Serial__r.ERP7__Available__c = true And 
                                                                        ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And 
                                                                        ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c = : selectedSite And
                                                                        ERP7__Serial__c = :mySOLI.ERP7__Serial__c Limit 1];
                        if(SDLIs.size() > 0){
                            String stkId = SDLIs[0].ERP7__Site_ProductService_InventoryStock__c;
                            WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, StorageContainer__r.Barcode__c from Inventory_Stock__c where Id =: stkId'); 
                        }
                    }
                    else if(mrp.MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c){
                        String batch = mySOLI.ERP7__Material_Batch_Lot__c;
                        WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c =: Prod And Number_of_Item_In_Stock__c > 0) And Active__c = true And ERP7__Batch_Lot__c =: batch) Order By ERP7__Expiry_Date__c ASC'); 
                        
                    }
                    
                    Decimal myStock = 0;
                    for(Inventory_Stock__c stock : WIISLists){
                        myStock += stock.Number_of_Item_In_Stock__c;
                    }
                    
                    mySOLI.ERP7__Quantity__c = mySOLI.ERP7__Quantity__c.setScale(6);
                    system.debug('moSerialNos.size() : '+moSerialNos.size());
                    Decimal totalQuantity = (moSerialNos.size() > 0)? mySOLI.ERP7__Quantity__c * moSerialNos.size() : mySOLI.ERP7__Quantity__c;
                    if(myStock >= totalQuantity){
                        system.debug('mrp.MRP.ERP7__Total_Amount_Required__c : '+ mrp.MRP.ERP7__Total_Amount_Required__c);
                        system.debug('mrp.MRP.ERP7__Fulfilled_Amount__c : '+ mrp.MRP.ERP7__Fulfilled_Amount__c);
                        // if(mrp.Stock > 0 && mrp.MRP.ERP7__Status__c == 'Requested' && mrp.Stock >= mrp.mrp.ERP7__Total_Amount_Required__c && mrp.MRP.ERP7__Fulfilled_Amount__c == mrp.MRP.ERP7__Total_Amount_Required__c)
                        
                        
                        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isUpdateable()){
                            mrp.MRP.ERP7__Fulfilled_Amount__c = (mrp.MRP.ERP7__Fulfilled_Amount__c != null)? mrp.MRP.ERP7__Fulfilled_Amount__c.setScale(6) : 0 ; 
                            mrp.ActualWeight = mrp.MRP.ERP7__Fulfilled_Amount__c;
                        }else{ /*No access*/ } //.setScale(2)
                        if(Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isUpdateable()){
                            if(mrp.MRP.ERP7__Status__c == 'Requested' && mrp.MRP.ERP7__Fulfilled_Amount__c == mrp.MRP.ERP7__Total_Amount_Required__c) mrp.MRP.Status__c = 'Reserved';
                        }else{/*No access*/} // status change code moved after setting scale to 4 on fulfilled qty as it was not changing the status to reserved - Shaguftha 15_03_24
                        system.debug('mrp.MRP.ERP7__Status__c : '+ mrp.MRP.ERP7__Status__c);
                        Decimal AllocatedStock = 0;
                        List<ERP7__Stock_Outward_Line_Item__c> SOLIs2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
                        system.debug('AllocatedStock  : '+AllocatedStock );
                        system.debug('totalQuantity: '+totalQuantity);
                        if(moSerialNos.size() == 0){
                            for(Inventory_Stock__c stock : WIISLists){
                                if(AllocatedStock < totalQuantity){
                                    ERP7__Stock_Outward_Line_Item__c myNewSOLI = new ERP7__Stock_Outward_Line_Item__c();
                                    if(mySOLI.ERP7__Quantity__c <= stock.Number_of_Item_In_Stock__c ){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){myNewSOLI.ERP7__Quantity__c = mySOLI.ERP7__Quantity__c;}else{/*No access*/} }
                                    else{ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){myNewSOLI.ERP7__Quantity__c = stock.Number_of_Item_In_Stock__c;}else{/*No access*/} }
                                    AllocatedStock += myNewSOLI.ERP7__Quantity__c;
                                    mySOLI.ERP7__Quantity__c = mySOLI.ERP7__Quantity__c - myNewSOLI.ERP7__Quantity__c; // added by shaguftha on 08_04_24 to fix the issue of allocating more quantity when the stock on fisrt inventory record is less than total required
                                    system.debug('myNewSOLI.ERP7__Quantity__c : '+myNewSOLI.ERP7__Quantity__c);
                                    system.debug('mySOLI.ERP7__Quantity__c : '+mySOLI.ERP7__Quantity__c);
                                    //mrp.ActualWeight += myNewSOLI.ERP7__Quantity__c;
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){myNewSOLI.ERP7__Product__c = mrp.MRP.ERP7__MRP_Product__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){myNewSOLI.ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){myNewSOLI.ERP7__Status__c = 'Reserved';}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){myNewSOLI.ERP7__Version__c = mrp.MRP.ERP7__Version__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){myNewSOLI.ERP7__Active__c = true;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isUpdateable()){myNewSOLI.ERP7__MRP_Material_Requirements_Planning__c = mrp.MRP.Id;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isUpdateable()){myNewSOLI.ERP7__BoM__c = mrp.MRP.ERP7__BOM__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isUpdateable()){myNewSOLI.ERP7__Work_Orders__c = mrp.MRP.ERP7__Work_Order__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){myNewSOLI.ERP7__Manufacturing_Order__c = mrp.MRP.ERP7__MO__c;}else{/*No access*/}
                                    if(mySOLI.ERP7__Material_Batch_Lot__c != Null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){ myNewSOLI.ERP7__Material_Batch_Lot__c = mySOLI.ERP7__Material_Batch_Lot__c; }else{/*No access*/}
                                    if(mySOLI.ERP7__Serial__c != Null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){ myNewSOLI.ERP7__Serial__c = mySOLI.ERP7__Serial__c; }else{/*No access*/}
                                    if(mySOLI.ERP7__MO_WO_Material_Batch_Lot__c != Null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Material_Batch_Lot__c.isUpdateable()){ myNewSOLI.ERP7__MO_WO_Material_Batch_Lot__c = mySOLI.ERP7__MO_WO_Material_Batch_Lot__c; }else{/*No access*/}
                                    if(mySOLI.ERP7__MO_WO_Serial__c != Null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Serial__c.isUpdateable()){ myNewSOLI.ERP7__MO_WO_Serial__c = mySOLI.ERP7__MO_WO_Serial__c; }else{/*No access*/}
                                    
                                    if(mrp.MRP.BOM_Requirement_Cost__c != Null){
                                        mySOLI.Total_Amount__c = mrp.MRP.BOM_Requirement_Cost__c/WM;
                                        mySOLI.Unit_Price__c = (mrp.MRP.Total_Amount_Required__c != Null && mrp.MRP.Total_Amount_Required__c > 0)? (mrp.MRP.BOM_Requirement_Cost__c/mrp.MRP.Total_Amount_Required__c)/WM : 0;
                                    }
                                    
                                    SOLIs2Upsert.add(myNewSOLI);
                                }
                            }
                        } 
                        else {
                            Map<Id, Decimal> serialAllocationMap = new Map<Id, Decimal>(); 
                            for (Id moSNId : moSerialNos) {
                                serialAllocationMap.put(moSNId, 0); 
                            }
                            for(Inventory_Stock__c stock : WIISLists){
                                Decimal currentStock = stock.ERP7__Number_of_Item_In_Stock__c;
                                for(Id moSNId:  moSerialNos){
                                    Decimal allocatedQty = serialAllocationMap.get(moSNId);
                                    system.debug('allocatedQty : '+allocatedQty);
                                    if (allocatedQty >= mySOLI.ERP7__Quantity__c) {
                                        continue; // Skip serials that are fully allocated
                                    }
                                    system.debug('currentStock bfr: '+currentStock);
                                    if(AllocatedStock < totalQuantity && currentStock > 0){    
                                        ERP7__Stock_Outward_Line_Item__c myNewSOLI = new ERP7__Stock_Outward_Line_Item__c();
                                         Decimal remainingQtyForSerial = mySOLI.ERP7__Quantity__c - allocatedQty;
                                        system.debug('remainingQtyForSerial : '+remainingQtyForSerial);
                                        if(remainingQtyForSerial <= currentStock){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){myNewSOLI.ERP7__Quantity__c = remainingQtyForSerial;}else{/*No access*/} }
                                        else{ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){myNewSOLI.ERP7__Quantity__c = currentStock;}else{/*No access*/} }
                                        AllocatedStock += myNewSOLI.ERP7__Quantity__c;
                                        
                                        currentStock -= myNewSOLI.ERP7__Quantity__c;
                                       serialAllocationMap.put(moSNId, allocatedQty + myNewSOLI.ERP7__Quantity__c);
                                        //system.debug('myNewSOLI.ERP7__Quantity__c : '+myNewSOLI.ERP7__Quantity__c);
                                        system.debug('mySOLI.ERP7__Quantity__c : '+mySOLI.ERP7__Quantity__c);
                                        // mrp.ActualWeight += myNewSOLI.ERP7__Quantity__c;
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){myNewSOLI.ERP7__Product__c = mrp.MRP.ERP7__MRP_Product__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){myNewSOLI.ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){myNewSOLI.ERP7__Status__c = 'Reserved';}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){myNewSOLI.ERP7__Version__c = mrp.MRP.ERP7__Version__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){myNewSOLI.ERP7__Active__c = true;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isUpdateable()){myNewSOLI.ERP7__MRP_Material_Requirements_Planning__c = mrp.MRP.Id;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isUpdateable()){myNewSOLI.ERP7__BoM__c = mrp.MRP.ERP7__BOM__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isUpdateable()){myNewSOLI.ERP7__Work_Orders__c = mrp.MRP.ERP7__Work_Order__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){myNewSOLI.ERP7__Manufacturing_Order__c = mrp.MRP.ERP7__MO__c;}else{/*No access*/}
                                        if(mySOLI.ERP7__Material_Batch_Lot__c != Null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){ myNewSOLI.ERP7__Material_Batch_Lot__c = mySOLI.ERP7__Material_Batch_Lot__c; }else{/*No access*/}
                                        if(mySOLI.ERP7__Serial__c != Null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){ myNewSOLI.ERP7__Serial__c = mySOLI.ERP7__Serial__c; }else{/*No access*/}
                                        if(mySOLI.ERP7__MO_WO_Material_Batch_Lot__c != Null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Material_Batch_Lot__c.isUpdateable()){ myNewSOLI.ERP7__MO_WO_Material_Batch_Lot__c = mySOLI.ERP7__MO_WO_Material_Batch_Lot__c; }else{/*No access*/}
                                        if(mySOLI.ERP7__MO_WO_Serial__c != Null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Serial__c.isUpdateable()){ myNewSOLI.ERP7__MO_WO_Serial__c = moSNId; }else{/*No access*/}
                                        
                                        if(mrp.MRP.BOM_Requirement_Cost__c != Null){
                                            mySOLI.Total_Amount__c = mrp.MRP.BOM_Requirement_Cost__c/WM;
                                            mySOLI.Unit_Price__c = (mrp.MRP.Total_Amount_Required__c != Null && mrp.MRP.Total_Amount_Required__c > 0)? (mrp.MRP.BOM_Requirement_Cost__c/mrp.MRP.Total_Amount_Required__c)/WM : 0;
                                        }
                                        SOLIs2Upsert.add(myNewSOLI);
                                    }
                                    else if(currentStock == 0){
                                        continue;
                                    }
                                    system.debug('currentStock afte: '+currentStock);
                                }
                            }
                        }
                        if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){upsert mrp.MRP;system.debug('mrp.MRP.ERP7__Status__c after update MRP: '+ mrp.MRP.ERP7__Status__c);}else{comW.errorMsg = 'Not allowed to upsert MRPs';}
                        if(SOLIs2Upsert.size()>0){
                            if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()){upsert SOLIs2Upsert; system.debug('mrp.MRP.ERP7__Status__c after update sOLI: '+ mrp.MRP.ERP7__Status__c);}else{comW.errorMsg = 'Not allowed to upsert Stock Outward';}
                            
                        } 
                        mrp.SOLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__BoM__r.ERP7__Quantity__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
                                     ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name
                                     From ERP7__Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c =: mrp.MRP.Id];
                        set<String> serialsIds = new set<String> ();
                        //new code start
                        Map<String, Decimal> serialQuantityMap = new Map<String, Decimal>();
                        
                        for (ERP7__Stock_Outward_Line_Item__c soli : mrp.SOLIs) {
                            if (soli.ERP7__MO_WO_Serial__c != null) {
                                if (serialQuantityMap.containsKey(soli.ERP7__MO_WO_Serial__c)) {
                                    serialQuantityMap.put(soli.ERP7__MO_WO_Serial__c, serialQuantityMap.get(soli.ERP7__MO_WO_Serial__c) + soli.ERP7__Quantity__c);
                                } else {
                                    serialQuantityMap.put(soli.ERP7__MO_WO_Serial__c, soli.ERP7__Quantity__c);
                                }
                            }
                        }
                        for (ERP7__Stock_Outward_Line_Item__c soli : mrp.SOLIs) {
                            if (soli.ERP7__MO_WO_Serial__c != null && serialQuantityMap.containsKey(soli.ERP7__MO_WO_Serial__c)) {
                                Decimal totQuantity = serialQuantityMap.get(soli.ERP7__MO_WO_Serial__c);
                                if (totQuantity == soli.ERP7__BoM__r.ERP7__Quantity__c) {
                                    serialsIds.add(soli.ERP7__MO_WO_Serial__c);
                                }
                            }
                        }
                        //new code end
                       // for(ERP7__Stock_Outward_Line_Item__c stk : mrp.SOLIs) { if(stk.ERP7__MO_WO_Serial__c != null) serialsIds.add(stk.ERP7__MO_WO_Serial__c); }
                        mrp.Stock = mrp.Stock - totalQuantity;
                        mrp.MRPQuantity = (mrp.Stock > 0 && mrp.Stock > mrp.MRP.Total_Amount_Required__c) ? (mrp.MRP.Total_Amount_Required__c - mrp.MRP.ERP7__Fulfilled_Amount__c) : mrp.Stock;
                        system.debug('totalQuantity : '+totalQuantity);
                        comW.MRPs = mrpWrappers;
                        List<String> serialsList = new List<String>(serialsIds);
                        comW.moSerialNos = getSerialNumbers(0,MOId,500,serialsList); // changed on 26_09_24 to fix the serial display issue
                            //[Select Id,Name,ERP7__Availability_date__c,ERP7__Available__c,ERP7__Barcode__c,ERP7__Date_of_Manufacture__c,ERP7__Serial_Number__c,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Id,ERP7__Manufacturing_Order__r.Name from  ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c   = :MOId and Id Not IN : serialsIds LIMIT 1000];
                    }
                    else{
                        Database.rollback(sp);
                        comW.errorMsg = System.Label.Invalid_stock;
                    }
                } else{
                    Database.rollback(sp);
                    comW.errorMsg = 'Raw Material Missing/Invalid on Routing';
                }
            }
        }
        catch(DMLException e){
            Database.rollback(sp);
            comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();
        }
        return comW;
    }
    @AuraEnabled
    public static List<ERP7__Stock_Outward_Line_Item__c> getMRPDetails(String MRP,String Mo){
        List<ERP7__Stock_Outward_Line_Item__c> stk = new List<ERP7__Stock_Outward_Line_Item__c>();
        stk = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__BoM__r.ERP7__Quantity__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Date_of_Manufacture__c,  ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
               ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name
               From ERP7__Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c =: MRP AND ERP7__MRP_Material_Requirements_Planning__c != null];
        return stk;
        
    }
    @AuraEnabled
    public static Double getSerialStock(String serialId){
        
        Double serialStock = 0.0;
        try{
            Set<Id> stockIds = new Set<Id>();
            List<AggregateResult> serialInv = new List<AggregateResult>();
            List<AggregateResult> serialInvOut = new List<AggregateResult>();
            serialInv = [Select SUM(ERP7__Number_of_Item_In_Stock__c)avaialbleStock from ERP7__Inventory_Stock__c WHERE ERP7__Serial__c =: serialId AND ERP7__Serial__c != null GROUP BY ERP7__Serial__c];
            //List<ERP7__Stock_Inward_Line_Item__c> inwards = List<ERP7__Stock_Inward_Line_Item__c>();
            //  serialInv = [SELECT SUM(ERP7__Quantity__c)avaialbleStock FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__Serial__c =: serialId AND ERP7__Serial__c != null GROUP BY ERP7__Serial__c];
            // serialInvOut = [SELECT SUM(ERP7__Quantity__c)avaialbleStock FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Serial__c =: serialId AND ERP7__Serial__c != null GROUP BY ERP7__Serial__c];
            //stockIds = inwards.KeySet();
            //batchInv = [SELECT SUM(ERP7__Number_of_Item_In_Stock__c) avaialbleStock FROM ERP7__Inventory_Stock__c WHERE Id IN: stockIds GROUP BY Id];
            //if(serialInv.size() > 0 && serialInvOut.size() > 0) serialStock = (Double)serialInv[0].get('avaialbleStock') - (Double)serialInvOut[0].get('avaialbleStock');
            //else
            if(serialInv.size() > 0) serialStock = (Double)serialInv[0].get('avaialbleStock');
            
        }catch(Exception e){
            /*'exception occured : '+ e.getMessage() + '; At line : ' + e.getLineNumber()*/
            //throw new AuraHandledException(e.getMessage());
        }
        return serialStock; 
    }
    
    //Added the site to fetch only the raw material site stock - shaguftha change 03/08/23
    @AuraEnabled
    public static Double getBatchStock(String batchId,string site){
        try{
            Double batchStock = 0.0;
            List<AggregateResult> batchInv = new List<AggregateResult>();
            batchInv = [SELECT SUM(ERP7__Number_of_Item_In_Stock__c) avaialbleStock FROM ERP7__Inventory_Stock__c WHERE ERP7__Batch_Lot__c =: batchId AND ERP7__Batch_Lot__c != null AND ERP7__Number_of_Item_In_Stock__c > 0 and ERP7__Warehouse__c =: site GROUP BY ERP7__Batch_Lot__c];
            if(batchInv.size() > 0) batchStock = (Double)batchInv[0].get('avaialbleStock');
            return batchStock; 
        }catch(Exception e){ throw new AuraHandledException(e.getMessage()); }
    }
    
    /*   @AuraEnabled
public static String setSerials(String startNum,String MOId,String serPrefix,Integer startFrom,Integer EndNo,List<Id> serialsId){
comWrap comW = new comWrap();
try{
List<ERP7__Serial_Number__c> failedRecords = new List<ERP7__Serial_Number__c>();
if(startNum != null && MOId != null && MOId != ''){
String allFields = 'Id ,Name, ERP7__Serial_Number__c,ERP7__Date_of_Manufacture__c,ERP7__Availability_date__c,ERP7__Shelf_Life_Expiration_Date__c,ERP7__Cost_Price__c,ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Product__r.Name,ERP7__Product__r.Barcode__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ';

List<ERP7__Serial_Number__c> serials = [Select Id ,Name, ERP7__Serial_Number__c,ERP7__Date_of_Manufacture__c,ERP7__Availability_date__c,ERP7__Shelf_Life_Expiration_Date__c,ERP7__Cost_Price__c,ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Product__r.Name,ERP7__Product__r.Barcode__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c  ,Barcode__c  from ERP7__Serial_Number__c
where ERP7__Manufacturing_Order__c = :MOId and Id IN: serialsId
LIMIT :EndNo 
OFFSET :startFrom];
//[Select Id,Name,ERP7__Serial_Number__c,ERP7__Barcode__c from ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c =: MOId];
if(serials.size() > 0){
String format = (serPrefix != null && serPrefix != '') ? serPrefix : System.Label.Serial_Number_Format;
system.debug('format : '+format);
Integer numericValue = Integer.valueOf(startNum.replaceFirst('^0+', ''));
for(ERP7__Serial_Number__c ser : serials){
ser.Name = ser.ERP7__Serial_No__c = ser.ERP7__Barcode__c = format + String.valueOf(numericValue).leftPad(startNum.length(), '0');
system.debug('ser.Name  : '+ser.Name );
numericValue++;
}
List<Database.SaveResult> updateResults = Database.update(serials, false);
//serials = new Map<Id,ERP7__Serial_Number__c>();
Integer counter = 0; 
for(Integer i=0;i < updateResults.size(); i++){
if (updateResults.get(i).isSuccess()){
updateResults.get(i).getId();

}else if (!updateResults.get(i).isSuccess()){
// DML operation failed
Database.Error error = updateResults.get(i).getErrors().get(0);
String failedDML = error.getMessage();
failedRecords.add(serials.get(i));//failed record from the list
system.debug('Failed ID'+updateResults.get(i).Id);
}

}

if (failedRecords.isEmpty()) {
String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP_Flow__c');
wpallFields += ' , ERP7__Product__r.Name, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Work_Orders__r.Name, ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c ,ERP7__Work_Orders__r.ERP7__Quantity_Scrapped__c,ERP7__Product__r.ERP7__UoM__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Version__r.Name';
String wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP_Flow__c where ERP7__WIP__r.ERP7__MO__c  = :MOId limit 100';
List<ERP7__WIP_Flow__c> wipflows =  Database.query(wpquery);
comW.moSerialNos = Database.query('select ' + String.escapeSingleQuotes(allFields) + ' ,Barcode__c  from ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c = :MOId limit 10000');
comW.wipflows = wipflows;

//comW.moSerialNos = serials;
return JSON.serialize(comW);
}
else{
String failedRecordsMessage = 'Failed to generate the following serial numbers: ';

for (ERP7__Serial_Number__c failedRecord : failedRecords) {
failedRecordsMessage +=  failedRecord.Name + ', ';
}
failedRecordsMessage += 'as the serial number already exists ';
return failedRecordsMessage;
}
}
}

return null;
}
catch(Exception e){
if (e.getMessage().contains('Duplicate') || e.getMessage().contains('duplicate')){
return 'Duplicate serial numbers found. Please change the serial start number.';
} else {
return 'Error: ' + e.getMessage();
}        
}
}
*/ 
    @AuraEnabled
    public static String setSerials(String MOId,String serialsList){
        try{
            List<ERP7__Serial_Number__c> serials = (List<ERP7__Serial_Number__c>) JSON.deserialize(serialsList,List<ERP7__Serial_Number__c>.class);
            if (serials.size() > 0) {
                List<ERP7__Serial_Number__c> failedRecords = new List<ERP7__Serial_Number__c>();
                List<Database.SaveResult> updateResults = Database.update(serials, false);
                Integer counter = 0;
                for (Integer i = 0; i < updateResults.size(); i++) {
                    if (!updateResults.get(i).isSuccess()) {
                        // DML operation failed
                        Database.Error error = updateResults.get(i).getErrors().get(0);
                        failedRecords.add(serials.get(i)); // failed record from the list
                        System.debug('Failed ID' + updateResults.get(i).Id+ 'error : '+error);
                    }
                }
                if (failedRecords.isEmpty()) {
                    return 'Success';
                }
                else{
                    String failedRecordsMessage = 'Failed to generate the following serial numbers: ';
                    
                    for (ERP7__Serial_Number__c failedRecord : failedRecords) {
                       // system.debug('failedRecord : '+failedRecord);
                        failedRecordsMessage +=  failedRecord.Name + ', ';
                    }
                    failedRecordsMessage += 'as the serial number already exists/Product code doesn\'t Match ';
                    return failedRecordsMessage;
                }
            }
            return null;
        } catch (Exception e) {
            if (e.getMessage().contains('Duplicate') || e.getMessage().contains('duplicate')) {
                return 'Duplicate serial numbers found. Please change the serial start number.';
            } else {
                return 'Error: ' + e.getMessage();
            }
        }
    }
    @AuraEnabled
    public static comWrap DeleteSOLI(String SOLI, String MRPs){   
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        ERP7__Stock_Outward_Line_Item__c mySOLI = [Select Id, Name, ERP7__Quantity__c from ERP7__Stock_Outward_Line_Item__c where Id =:SOLI];
        
        mrpWrap mrp = new mrpWrap();
        for(mrpWrap mrpW : mrpWrappers){
            if(mrpW.isSelect) mrp = mrpW;
        }
        comWrap comW = new comWrap();
        comW.errorMsg = '';
        try{
            if(mrp.isSelect){
                if(ERP7__Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete mySOLI;
                mrp.ActualWeight -= (mySOLI.ERP7__Quantity__c);
                if(mrp.MRP.ERP7__Fulfilled_Amount__c >= mySOLI.ERP7__Quantity__c){ if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isUpdateable()){mrp.MRP.ERP7__Fulfilled_Amount__c -= (mySOLI.ERP7__Quantity__c*mrp.WeightMultiplier);}else{/*No access*/} }
                else{ if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isUpdateable()){mrp.MRP.ERP7__Fulfilled_Amount__c = 0;}else{/*No access*/} }
                if(mrp.MRP.ERP7__Fulfilled_Amount__c != mrp.MRP.ERP7__Total_Amount_Required__c) mrp.MRP.ERP7__Status__c = 'Requested';
                mrp.Stock += mySOLI.ERP7__Quantity__c; // Change SM 4
                mrp.MRPQuantity = (mrp.MRP.ERP7__Total_Amount_Required__c - mrp.MRP.ERP7__Fulfilled_Amount__c); // change SM 5
                if(Schema.sObjectType.ERP7__MRP__c.isUpdateable()){update mrp.MRP;}else{/*not allowed to update*/}
                mrp.SOLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__BoM__r.ERP7__Quantity__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
                             ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name
                             From ERP7__Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c =: mrp.MRP.Id];   
                comW.MRPs = mrpWrappers;
                //new code to get updated mo serials after deleting SOLI
                Map<String, Decimal> serialQuantityMap = new Map<String, Decimal>();
                set<String> serialsIds = new set<String> ();
                for (ERP7__Stock_Outward_Line_Item__c stk : mrp.SOLIs) {
    				if (stk.ERP7__MO_WO_Serial__c != null) {
                        if(!serialQuantityMap.containskey(stk.ERP7__MO_WO_Serial__c)){
        					serialQuantityMap.put(stk.ERP7__MO_WO_Serial__c, stk.ERP7__Quantity__c);
                        }else{
                            serialQuantityMap.put(stk.ERP7__MO_WO_Serial__c,serialQuantityMap.get(stk.ERP7__MO_WO_Serial__c)+stk.ERP7__Quantity__c);
                        }
    				}
				}
                for (ERP7__Stock_Outward_Line_Item__c stk : mrp.SOLIs) {
    				if (
        					stk.ERP7__MO_WO_Serial__c != null &&
        					stk.ERP7__BoM__c != null &&
        					stk.ERP7__BoM__r.ERP7__Quantity__c != null
    					) {
        				Decimal actualQty = serialQuantityMap.get(stk.ERP7__MO_WO_Serial__c);
        				Decimal bomQty = stk.ERP7__BoM__r.ERP7__Quantity__c;

        				if (actualQty == bomQty) {
            				serialsIds.add(stk.ERP7__MO_WO_Serial__c);
        				}
    				}
				}
               // for(ERP7__Stock_Outward_Line_Item__c stk : mrp.SOLIs) { if(stk.ERP7__MO_WO_Serial__c != null&& stk.ERP7__BoM__c!=null && stk.ERP7__BoM__r.ERP7__Quantity__c!=null && stk.ERP7__Quantity__c==stk.ERP7__BoM__r.ERP7__Quantity__c) serialsIds.add(stk.ERP7__MO_WO_Serial__c); }
                List<String> serialsList = new List<String>(serialsIds);System.debug('serialsList '+serialsList.size());
                ERP7__MRP__c temp=[select Id, name, ERP7__MO__c  from ERP7__MRP__c where Id=: mrp.MRP.Id limit 1];
                if(temp!=null && temp.ERP7__MO__c!=null){comW.moSerialNos = getSerialNumbers(0,temp.ERP7__MO__c,500,serialsList);System.debug('comW.moSerialNos.length '+comW.moSerialNos.size());}
                //new code end
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
 /*   @AuraEnabled
public static comWrap MRPNewUpdate1(string MRP1){ 
    ERP7__MRP__c MRP = (ERP7__MRP__c) JSON.deserialize(MRP1, ERP7__MRP__c.class);
    comWrap comWrapper = new comWrap();
    try {
        ERP7__WO__c WO = [Select Id, Name, ERP7__Process_Cycle__c, ERP7__Version__c, ERP7__Product__c, ERP7__Work_Center__c 
                          From ERP7__WO__c Where Id =: MRP.ERP7__Work_Order__c];
        Product2 prod = [Select Id, Name From Product2 Where Id =: MRP.ERP7__MRP_Product__c];
        
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isUpdateable()) {
            MRP.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Order__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Order__c.isUpdateable()) {
            MRP.ERP7__Work_Order__c = WO.Id;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isUpdateable()) {
            MRP.ERP7__Version__c = WO.ERP7__Version__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()) {
            MRP.ERP7__MRP_Product__c = prod.Id;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isUpdateable()) {
            MRP.ERP7__Work_Center__c = WO.ERP7__Work_Center__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) {
            upsert MRP;
        } else {
            comWrapper.errorMsg = 'not allowed to upsert';
        }
    } catch(Exception e) { 
        comWrapper.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
    }
    return comWrapper;
}*/
/*    @AuraEnabled
public static comWrap MRPNewUpdate1(string MRP1){ 
    ERP7__MRP__c MRP = (ERP7__MRP__c) JSON.deserialize(MRP1, ERP7__MRP__c.class);
    comWrap comWrapper = new comWrap();
    try {
        ERP7__WO__c WO = [Select Id, Name, ERP7__Process_Cycle__c, ERP7__Version__c, ERP7__Product__c, ERP7__Work_Center__c 
                          From ERP7__WO__c Where Id =: MRP.ERP7__Work_Order__c];
        Product2 prod = [Select Id, Name, QuantityUnitOfMeasure From Product2 Where Id =: MRP.ERP7__MRP_Product__c];
        
        Id bomRecordTypeId = Schema.SObjectType.ERP7__BOM__c.getRecordTypeInfosByName().get('Manufacturing BOM').getRecordTypeId();

        if (MRP.Id == null) {
            ERP7__BOM__c newBOM = new ERP7__BOM__c();
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.Name.isCreateable()) {
                newBOM.Name = prod.Name;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isUpdateable()) {
                newBOM.ERP7__BOM_Product__c = WO.ERP7__Product__c;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isUpdateable()) {
                newBOM.ERP7__BOM_Component__c = prod.Id;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable()) {
                newBOM.ERP7__BOM_Version__c = WO.ERP7__Version__c;
            }
            
            newBOM.RecordTypeId = bomRecordTypeId;
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isUpdateable()) {
                newBOM.ERP7__Active__c = true;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isUpdateable()) {
                newBOM.ERP7__Type__c = 'Primary';
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isUpdateable()) {
                newBOM.ERP7__Unit_of_Measure__c = prod.QuantityUnitOfMeasure;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isUpdateable()) {
                newBOM.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
            }
            
          
            if (Schema.sObjectType.ERP7__BOM__c.isCreateable()) {
                insert newBOM;
            } else {
                comWrapper.errorMsg = 'not allowed to create BOM';
            }
            
            if (Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && 
                Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()) {
                MRP.ERP7__BOM__c = newBOM.Id;
            }
        }

        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isUpdateable()) {
            MRP.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Order__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Order__c.isUpdateable()) {
            MRP.ERP7__Work_Order__c = WO.Id;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isUpdateable()) {
            MRP.ERP7__Version__c = WO.ERP7__Version__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()) {
            MRP.ERP7__MRP_Product__c = prod.Id;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isUpdateable()) {
            MRP.ERP7__Work_Center__c = WO.ERP7__Work_Center__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) {
            upsert MRP;
        } else {
            comWrapper.errorMsg = 'not allowed to upsert';
        }
    } catch(Exception e) { 
        comWrapper.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
    }
    return comWrapper;
}*/
 /*   @AuraEnabled
public static comWrap MRPNewUpdate1(string MRP1){ 
    ERP7__MRP__c MRP = (ERP7__MRP__c) JSON.deserialize(MRP1, ERP7__MRP__c.class);
    comWrap comWrapper = new comWrap();
    try {
        ERP7__WO__c WO = [Select Id, Name, ERP7__Process_Cycle__c, ERP7__Version__c, ERP7__Product__c, ERP7__Work_Center__c, ERP7__MO__c 
                          From ERP7__WO__c Where Id =: MRP.ERP7__Work_Order__c];
        Product2 prod = [Select Id, Name, QuantityUnitOfMeasure From Product2 Where Id =: MRP.ERP7__MRP_Product__c];
        
        Id bomRecordTypeId = Schema.SObjectType.ERP7__BOM__c.getRecordTypeInfosByName().get('Manufacturing BOM').getRecordTypeId();

        if (MRP.Id == null) {
            ERP7__BOM__c newBOM = new ERP7__BOM__c();
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.Name.isCreateable()) {
                newBOM.Name = prod.Name;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isUpdateable()) {
                newBOM.ERP7__BOM_Product__c = WO.ERP7__Product__c;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isUpdateable()) {
                newBOM.ERP7__BOM_Component__c = prod.Id;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable()) {
                newBOM.ERP7__BOM_Version__c = WO.ERP7__Version__c;
            }
            
            newBOM.RecordTypeId = bomRecordTypeId;
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isUpdateable()) {
                newBOM.ERP7__Active__c = true;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isUpdateable()) {
                newBOM.ERP7__Type__c = 'Primary';
            }
             if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isUpdateable()) {
                newBOM.ERP7__Type__c = 'Certified';
            }
           
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isUpdateable()) {
                newBOM.ERP7__Unit_of_Measure__c = prod.QuantityUnitOfMeasure;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isUpdateable()) {
                newBOM.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
            }
            
            // Set ERP7__Quantity__c on BOM from user input
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isUpdateable()) {
                newBOM.ERP7__Quantity__c = MRP.ERP7__Total_Amount_Required__c;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.isCreateable()) {
                insert newBOM;
            } else {
                comWrapper.errorMsg = 'not allowed to create BOM';
            }
            
            if (Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && 
                Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()) {
                MRP.ERP7__BOM__c = newBOM.Id;
            }
        } else {
            // Update existing BOM if MRP already exists
            ERP7__BOM__c existingBOM = [SELECT Id, ERP7__Quantity__c FROM ERP7__BOM__c WHERE Id = :MRP.ERP7__BOM__c];
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isUpdateable()) {
                existingBOM.ERP7__Quantity__c = MRP.ERP7__Total_Amount_Required__c;
                update existingBOM;
            }
        }

        // Fetch MO to get ERP7__Quantity__c
        ERP7__Manufacturing_Order__c mo = [SELECT ERP7__Quantity__c FROM ERP7__Manufacturing_Order__c WHERE Id = :WO.ERP7__MO__c LIMIT 1];
        
        // Calculate ERP7__Total_Amount_Required__c for MRP
        if (Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && 
            Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()) {
            Decimal bomQuantity = MRP.ERP7__Total_Amount_Required__c; // This is the user input now stored in BOM
            Decimal moQuantity = mo.ERP7__Quantity__c != null ? mo.ERP7__Quantity__c : 0;
            MRP.ERP7__Total_Amount_Required__c = bomQuantity * moQuantity;
        }

        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isUpdateable()) {
            MRP.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Order__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Order__c.isUpdateable()) {
            MRP.ERP7__Work_Order__c = WO.Id;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isUpdateable()) {
            MRP.ERP7__Version__c = WO.ERP7__Version__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()) {
            MRP.ERP7__MRP_Product__c = prod.Id;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isUpdateable()) {
            MRP.ERP7__Work_Center__c = WO.ERP7__Work_Center__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) {
            upsert MRP;
        } else {
            comWrapper.errorMsg = 'not allowed to upsert';
        }
    } catch(Exception e) { 
        comWrapper.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
    }
    return comWrapper;
}*/
    @AuraEnabled
public static comWrap MRPNewUpdate1(string MRP1){ 
    ERP7__MRP__c MRP = (ERP7__MRP__c) JSON.deserialize(MRP1, ERP7__MRP__c.class);
    comWrap comWrapper = new comWrap();
    try {
        ERP7__WO__c WO = [Select Id, Name, ERP7__Process_Cycle__c, ERP7__Version__c, ERP7__Product__c, ERP7__Work_Center__c, ERP7__MO__c 
                          From ERP7__WO__c Where Id =: MRP.ERP7__Work_Order__c];
        Product2 prod = [Select Id, Name, QuantityUnitOfMeasure From Product2 Where Id =: MRP.ERP7__MRP_Product__c];
        
        Id bomRecordTypeId = Schema.SObjectType.ERP7__BOM__c.getRecordTypeInfosByName().get('Manufacturing BOM').getRecordTypeId();

        // Query ERP7__Routing_Link__c records related to the Process Cycle
        List<ERP7__Routing_Link__c> routingLinks = [SELECT Id 
                                                   FROM ERP7__Routing_Link__c 
                                                   WHERE ERP7__Process_Cycle__c = :WO.ERP7__Process_Cycle__c 
                                                   LIMIT 1];

        // Select the first ERP7__Routing_Link__c record, if available
        Id routingLinkId = (routingLinks != null && !routingLinks.isEmpty()) ? routingLinks[0].Id : null;

        if (MRP.Id == null) {
            ERP7__BOM__c newBOM = new ERP7__BOM__c();
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.Name.isCreateable()) {
                newBOM.Name = prod.Name;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isUpdateable()) {
                newBOM.ERP7__BOM_Product__c = WO.ERP7__Product__c;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isUpdateable()) {
                newBOM.ERP7__BOM_Component__c = prod.Id;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable()) {
                newBOM.ERP7__BOM_Version__c = WO.ERP7__Version__c;
            }
            
            newBOM.RecordTypeId = bomRecordTypeId;
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isUpdateable()) {
                newBOM.ERP7__Active__c = true;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isUpdateable()) {
                newBOM.ERP7__Type__c = 'Primary';
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isUpdateable()) {
                newBOM.ERP7__Unit_of_Measure__c = prod.QuantityUnitOfMeasure;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isUpdateable()) {
                newBOM.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
            }
            
            // Set ERP7__Quantity__c on BOM from user input
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isUpdateable()) {
                newBOM.ERP7__Quantity__c = MRP.ERP7__Total_Amount_Required__c;
            }
            
            // Set ERP7__Status__c to 'Certified'
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isUpdateable()) {
                newBOM.ERP7__Status__c = 'Certified';
            }
            
            // Set ERP7__Routing_Link__c from queried Routing Link
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isCreateable() && 
                Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isUpdateable() && 
                routingLinkId != null) {
                newBOM.ERP7__Routing_Link__c = routingLinkId;
            }
            
            if (Schema.sObjectType.ERP7__BOM__c.isCreateable()) {
                insert newBOM;
            } else {
                comWrapper.errorMsg = 'not allowed to create BOM';
            }
            
            if (Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && 
                Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()) {
                MRP.ERP7__BOM__c = newBOM.Id;
            }
        } else {
            // Update existing BOM if MRP already exists
            ERP7__BOM__c existingBOM = [SELECT Id, ERP7__Quantity__c, ERP7__Status__c, ERP7__Routing_Link__c 
                                        FROM ERP7__BOM__c WHERE Id = :MRP.ERP7__BOM__c];
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isUpdateable()) {
                existingBOM.ERP7__Quantity__c = MRP.ERP7__Total_Amount_Required__c;
            }
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isUpdateable()) {
                existingBOM.ERP7__Status__c = 'Certified';
            }
            if (Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isUpdateable() && 
                routingLinkId != null) {
                existingBOM.ERP7__Routing_Link__c = routingLinkId;
            }
            update existingBOM;
        }

        // Fetch MO to get ERP7__Quantity__c
        ERP7__Manufacturing_Order__c mo = [SELECT ERP7__Quantity__c FROM ERP7__Manufacturing_Order__c WHERE Id = :WO.ERP7__MO__c LIMIT 1];
        
        // Calculate ERP7__Total_Amount_Required__c for MRP
        if (Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && 
            Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()) {
            Decimal bomQuantity = MRP.ERP7__Total_Amount_Required__c; // This is the user input now stored in BOM
            Decimal moQuantity = mo.ERP7__Quantity__c != null ? mo.ERP7__Quantity__c : 0;
            MRP.ERP7__Total_Amount_Required__c = bomQuantity * moQuantity;
        }

        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isUpdateable()) {
            MRP.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isUpdateable()) {
            MRP.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()) {
            MRP.Name = prod.Name;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isUpdateable()) {
            MRP.ERP7__Version__c = WO.ERP7__Version__c;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()) {
            MRP.ERP7__MRP_Product__c = prod.Id;
        }
        if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isCreateable() && 
           Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isUpdateable()) {
            MRP.ERP7__Work_Center__c = WO.ERP7__Work_Center__c;
        }
        MRP.ERP7__BOM_unit_Price__c = 0.0;

        if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) {
            upsert MRP;
        } else {
            comWrapper.errorMsg = 'not allowed to upsert';
        }
    } catch(Exception e) { 
        comWrapper.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
    }
    return comWrapper;
}
    
    @AuraEnabled
    public static comWrap GetDefaults(String  proId){   
        comWrap comWrapper = new comWrap();
        comWrapper.Product = [Select Id, Name, ERP7__Version__c, ERP7__Routing__c, ERP7__Version__r.Name, ERP7__Routing__r.Name From Product2 Where Id =: proId];
        comWrapper.Routing = new ERP7__Routing__c(Id=comWrapper.Product.ERP7__Routing__c, Name=comWrapper.Product.ERP7__Routing__r.Name);
        comWrapper.Version = new ERP7__Version__c(Id=comWrapper.Product.ERP7__Version__c, Name=comWrapper.Product.ERP7__Version__r.Name);
        return comWrapper;  
    }
    
    @AuraEnabled
    public static comWrap GetRouting(String  routingId){   
        comWrap comWrapper = new comWrap();
        comWrapper.Routing = [Select Id, Name, ERP7__Lead_Time_days__c From ERP7__Routing__c Where Id =: routingId];
        comWrapper.StartDate = system.today();
        comWrapper.ExpectedDate = system.today()+1;
        if(comWrapper.Routing.ERP7__Lead_Time_days__c != Null) comWrapper.ExpectedDate = system.today()+Integer.valueof(comWrapper.Routing.ERP7__Lead_Time_days__c);
        return comWrapper;
    }
    
    @AuraEnabled
    public static ScanWrap SearchScanCode(String scanCode, String MRPs){   
        ScanWrap scanWrapper = new ScanWrap();
        try{
            List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
            List<ERP7__Serial_Number__c> SNS = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Serial_Number__c Where ERP7__Barcode__c =: scanCode Limit 1];
            if(SNS.size() > 0) {
                scanWrapper.Serial = SNS[0];
                scanWrapper.substep = 'Serial';
                for(mrpWrap mrrp : mrpWrappers){
                    if(mrrp.isSelect){
                        if(scanWrapper.Serial.ERP7__Manufacturing_Order__c != Null && scanWrapper.Serial.ERP7__Manufacturing_Order__c == mrrp.MRP.ERP7__MO__c) {
                            scanWrapper.step = 'MO';
                        }
                        else if(scanWrapper.Serial.ERP7__Product__c == mrrp.MRP.ERP7__MRP_Product__c){
                            scanWrapper.step = 'MRP';
                        }
                    }
                    if(scanWrapper.step != '') break;
                }
            }
            else{
                List<ERP7__Batch__c> BTS = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Batch__c Where ERP7__Barcode__c =: scanCode Limit 1];
                if(BTS.size() > 0) {
                    scanWrapper.Batch = BTS[0];
                    scanWrapper.substep = 'Batch';
                    for(mrpWrap mrrp : mrpWrappers){
                        if(mrrp.isSelect && scanWrapper.Batch.ERP7__Manufacturing_Order__c != Null && scanWrapper.Batch.ERP7__Manufacturing_Order__c == mrrp.MRP.ERP7__MO__c) {
                            scanWrapper.step = 'MO';
                        }
                        else if(mrrp.isSelect && scanWrapper.Batch.ERP7__Product__c == mrrp.MRP.ERP7__MRP_Product__c){
                            scanWrapper.step = 'MRP';
                        }
                        if(scanWrapper.step != '') break;
                    }
                }
            }
        } catch(Exception e) { scanWrapper.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return scanWrapper;
    }
    
    @AuraEnabled
    public static List<Attachment> GetAttachments(String MOId) {   
        comWrap comW = new comWrap();
        List<Attachment> MYATS = [Select Id, Name, ParentId, ContentType, Owner.Name, CreatedDate From Attachment Where ParentId = :MOId And Name = 'Signature' Order By CreatedDate Asc];
        return MYATS;
    }
    
    @AuraEnabled
    public static comWrap DeleteAT(String RAId, String ObjName){   
        comWrap comW = new comWrap();
        String query = 'select Id from ' +String.escapeSingleQuotes(ObjName)+ ' Where Id =:RAId';
        SObject AT = Database.query(query);
        SObjectType sObjType = ((SObject) Type.forName(ObjName).newInstance()).getSObjectType();
        if(sObjType.getDescribe().isDeletable()){ delete AT;}else{/*No access*/}        
        return comW;
    }
    @AuraEnabled
    public static List<ERP7__WIP_Flow__c> getWIPFlows(Integer offsetVal,string Mo){
        List<ERP7__WIP_Flow__c> wipflows = [Select Id,Name,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Version__c,ERP7__Version__r.Name,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Work_Orders__c,ERP7__Work_Orders__r.Id,ERP7__Work_Orders__r.Name,ERP7__Quantity_Ordered__c,ERP7__Quantity__c,ERP7__Quantity_Scrapped__c,ERP7__WIP__c,ERP7__WIP__r.ERP7__Serial_Number__c,ERP7__WIP__r.ERP7__Serial_Number__r.Name,ERP7__WIP__r.ERP7__Material_Batch_Lot__c,ERP7__WIP__r.ERP7__Material_Batch_Lot__r.Name from  ERP7__WIP_Flow__c where ERP7__WIP__r.ERP7__MO__c   = :Mo LIMIT 100 OFFSET :offsetVal];
        return wipflows;
    }
    @AuraEnabled
    public static List<ERP7__Serial_Number__c> getSerialNumbers(Integer offsetVal,string Mo,Integer limitSer,List<String> SerialIds){
        if(limitSer == null || limitSer == 0) limitSer = 4000;
        if(SerialIds == null) SerialIds = new List<String>();
        List<ERP7__Serial_Number__c> serialNums= [Select Id,Name,ERP7__Availability_date__c,ERP7__Available__c,ERP7__Barcode__c,ERP7__Date_of_Manufacture__c,ERP7__Serial_Number__c,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Id,ERP7__Manufacturing_Order__r.Name from  ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c   = :Mo and Id Not In : SerialIds  LIMIT :limitSer OFFSET :offsetVal];
        return serialNums;
    }
    @AuraEnabled
    public static String deleteSelectedMRP(List<String> MRPIds){
        if(MRPIds.size() > 0){
            List<ERP7__MRP__c> Mrps2Delete = new List<ERP7__MRP__c>();
            for(String mrpId : MRPIds){
                ERP7__MRP__c mrp = new ERP7__MRP__c(Id = mrpId);
                Mrps2Delete.add(mrp);
            }
            if(Mrps2Delete.size() > 0) delete Mrps2Delete;
            return 'Success'; 
        }else return null;
    }
    @AuraEnabled
    public static List<ReceivedSILIWrap> getStockinwards(Integer offsetVal,string MoId){
        List<ReceivedSILIWrap> sinwards = new List<ReceivedSILIWrap>();
        String status = 'Quality Check(QA)';
        if(MoId != null && MoId != ''){
            set<Id> prodIds = new set<Id>();
            set<Id> receivedSili = new set<Id>();
            List<ERP7__Stock_Inward_Line_Item__c> sinwardslist = [Select Id,Name,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Quality_Check_QA__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.Name,ERP7__Scrap__c,ERP7__Status__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Quantity__c from ERP7__Stock_Inward_Line_Item__c where ERP7__Manufacturing_Order__c = : MoId and ERP7__Status__c = :status limit 100 OFFSET :offsetVal];
            for(ERP7__Stock_Inward_Line_Item__c sin : sinwardslist){
                if(sin.ERP7__Product__c != null) prodIds.add(sin.ERP7__Product__c);
                receivedSili.add(sin.Id);
            }
            if(prodIds.size() > 0){
                List<ERP7__Checklist__c> checklists = new List<ERP7__Checklist__c>();
                checklists = [Select Id,Name,ERP7__Is_Mandatory__c,ERP7__Action_Detail__c ,ERP7__Has_Checklist__c, toLabel(ERP7__Comply__c), toLabel(ERP7__Result__c), ERP7__Notes__c, ERP7__Product__c   
                              from ERP7__Checklist__c where ERP7__Product__c != null AND ERP7__Product__c IN: prodIds AND ERP7__Product__r.ERP7__Quality_Check_QA__c = true Order by createdDate asc];
                Map<Id, UserRecordAccess> userAccessMap = new Map<Id, UserRecordAccess>();
                if(checklists.size() > 0){
                    Set<Id> checklistIds = new Set<Id>();
                    for(ERP7__Checklist__c chk: checklists){ checklistIds.add(chk.Id); }
                    userAccessMap = new Map<Id, UserRecordAccess>([SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :checklistIds]);
                }
                
                List<ERP7__Guideline_Checklists__c> enteredChecklists = new List<ERP7__Guideline_Checklists__c>();
                enteredChecklists = [Select Id, Name, ERP7__Checklist__c,ERP7__Is_Mandatory__c, ERP7__Status__c,ERP7__Instructions__c, ERP7__Stock_Inward_Line_Item__c, ERP7__Checklist__r.ERP7__Is_Mandatory__c, ERP7__Checklist__r.ERP7__Action_Detail__c, ERP7__Checklist__r.ERP7__Has_Checklist__c,ERP7__Checklist__r.Name, toLabel(ERP7__Checklist__r.ERP7__Comply__c), toLabel(ERP7__Checklist__r.ERP7__Result__c), ERP7__Checklist__r.ERP7__Product__c,
                                     (Select Id, Name, ParentId from Attachments) 
                                     from ERP7__Guideline_Checklists__c where ERP7__Stock_Inward_Line_Item__c IN: receivedSili AND ERP7__Checklist__c != null AND ERP7__Stock_Inward_Line_Item__c != null];
                Map<String,List<ERP7__Guideline_Checklists__c>> guideMAp = new Map<String,List<ERP7__Guideline_Checklists__c>>();
                for(ERP7__Guideline_Checklists__c guide: enteredChecklists){
                    String key = ''+guide.ERP7__Stock_Inward_Line_Item__c+guide.ERP7__Checklist__c;
                    system.debug('key setting~>'+key);
                    if(guideMAp.containsKey(key)) guideMAp.get(key).add(guide);
                    else guideMAp.put(key, new List<ERP7__Guideline_Checklists__c>{guide});
                }
                for(ERP7__Stock_Inward_Line_Item__c stinReceived : sinwardslist){
                    ReceivedSILIWrap wrapReceive = new ReceivedSILIWrap();
                    wrapReceive.sili = stinReceived;
                    
                    for(ERP7__Checklist__c check : checklists){
                        String key = ''+stinReceived.Id+check.Id;
                        system.debug('key checkinghere~>'+key);
                        system.debug('guideMAp.containsKey(key)~>'+guideMAp.containsKey(key));
                        if(guideMAp.containsKey(key)){
                            system.debug('inhere1');
                            wrapReceive.guideline.addAll(guideMAp.get(key));
                            system.debug('wrapReceive.guideline~>'+wrapReceive.guideline.size());
                            for(ERP7__Guideline_Checklists__c gu : wrapReceive.guideline){
                                if(gu.ERP7__Checklist__c != null){
                                    UserRecordAccess userAccess = (userAccessMap.containsKey(gu.ERP7__Checklist__c)) ? userAccessMap.get(gu.ERP7__Checklist__c) : null;
                                    gu.Name = gu.ERP7__Checklist__r.Name;
                                    if(gu.ERP7__Checklist__r.ERP7__Comply__c != '') gu.Name = gu.ERP7__Checklist__r.ERP7__Comply__c; 
                                    gu.ERP7__Is_Mandatory__c = false;
                                    if (userAccess != null){
                                        if(userAccess.HasEditAccess) gu.ERP7__Is_Mandatory__c = true; //set to true if it has edit access - used to disable picklist/input on UI
                                    }
                                }
                            }
                        }
                        else{
                            if(check.ERP7__Product__c == stinReceived.ERP7__Product__c){
                                system.debug('inhere2');
                                UserRecordAccess userAccess = (userAccessMap.containsKey(check.Id)) ? userAccessMap.get(check.Id) : null;
                                ERP7__Guideline_Checklists__c guideChecks = new ERP7__Guideline_Checklists__c();
                                guideChecks.Name = check.Name;
                                if(check.ERP7__Comply__c != '') guideChecks.Name = check.ERP7__Comply__c; 
                                guideChecks.ERP7__Checklist__c = check.Id;
                                guideChecks.ERP7__Checklist__r = new  ERP7__Checklist__c(ERP7__Is_Mandatory__c = check.ERP7__Is_Mandatory__c,ERP7__Comply__c = check.ERP7__Comply__c,ERP7__Result__c = check.ERP7__Result__c,ERP7__Notes__c = check.ERP7__Notes__c); 
                                guideChecks.ERP7__Instructions__c = guideChecks.ERP7__Status__c = check.ERP7__Has_Checklist__c ? check.ERP7__Result__c : check.ERP7__Action_Detail__c;
                                guideChecks.ERP7__Stock_Inward_Line_Item__c = stinReceived.Id;
                                guideChecks.ERP7__Is_Mandatory__c = false;
                                if (userAccess != null){
                                    if(userAccess.HasEditAccess) guideChecks.ERP7__Is_Mandatory__c = true; //set to true if it has edit access - used to disable picklist/input on UI
                                }
                                wrapReceive.guideline.add(guideChecks);
                            }
                        }
                    }
                    sinwards.add(wrapReceive);
                }
                
            }
        }
        if(sinwards.size() > 0){
            return sinwards;
        }
        else return null;
    }
    @AuraEnabled
    public static string saveAlldetail(String createdsili){
        if(createdsili != null && createdsili != ''){
            List<ReceivedSILIWrap> sili2updateWrap = new List<ReceivedSILIWrap>();
            sili2updateWrap = (List<ReceivedSILIWrap>) JSON.deserialize(createdsili,List<ReceivedSILIWrap>.class);
            List<ERP7__Stock_Inward_Line_Item__c> sili2update = new List<ERP7__Stock_Inward_Line_Item__c>();
            List<ERP7__Guideline_Checklists__c>  guidelines2update = new List<ERP7__Guideline_Checklists__c>();
            set<Id> QAProdIds = new set<Id>();
            if(sili2updateWrap.size() > 0) { 
                for(ReceivedSILIWrap wrap : sili2updateWrap){
                    sili2update.add(wrap.sili);
                    QAProdIds.add(wrap.sili.ERP7__Product__c);
                    system.debug('sili wrap status : '+wrap.sili.ERP7__Status__c);
                    if(wrap.guideline != null) guidelines2update.addAll(wrap.guideline);
                }
                 update sili2update; 
             }
            
             if(guidelines2update.size() > 0){ 
                 List<ERP7__Checklist__c> checklists = new List<ERP7__Checklist__c>();
                 checklists = [Select Id,Name,ERP7__Is_Mandatory__c,ERP7__Action_Detail__c ,ERP7__Has_Checklist__c, toLabel(ERP7__Comply__c), toLabel(ERP7__Result__c), ERP7__Notes__c, ERP7__Product__c   
                               from ERP7__Checklist__c where ERP7__Product__c != null AND ERP7__Product__c IN: QAProdIds AND ERP7__Product__r.ERP7__Quality_Check_QA__c = true Order by createdDate asc];
                 
                 Map<Id, UserRecordAccess> userAccessMap = new Map<Id, UserRecordAccess>();
                 if(checklists.size() > 0){
                     Set<Id> checklistIds = new Set<Id>();
                     for(ERP7__Checklist__c chk: checklists){ checklistIds.add(chk.Id); }
                     userAccessMap = new Map<Id, UserRecordAccess>([SELECT RecordId, HasEditAccess  FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :checklistIds]);
                 }
                List<ERP7__Guideline_Checklists__c> updatedGuidelines = new List<ERP7__Guideline_Checklists__c>();
                
                for(ERP7__Guideline_Checklists__c guide : guidelines2update){
                    if(guide.ERP7__Checklist__c != null){
                        UserRecordAccess userAccess = (userAccessMap.containsKey(guide.ERP7__Checklist__c)) ? userAccessMap.get(guide.ERP7__Checklist__c) : null;
                        if (userAccess != null){
                            if(userAccess.HasEditAccess){
                                guide.ERP7__Checklist__r = null;
                                guide.ERP7__Status__c = guide.ERP7__Instructions__c;
                                guide.ERP7__Is_Mandatory__c = false;
                                //guide.Attachments = null;
                                updatedGuidelines.add(guide);
                            }
                        }
                    }
                }
                upsert updatedGuidelines;
            }  
            return 'Success';
        }
        return null;
    }
      @AuraEnabled
    public static List<Attachment> uploadMultipleFilesforQAguideline(String parent, List<String> fileName, List<String> base64Data, List<String> contentType) { 
        try{
            List<Attachment> attachments2Insert = new List<Attachment>(); 
            List<Attachment> Attachments = new List<Attachment>(); 
            if(String.isNotEmpty(parent)){
                
                ERP7__Guideline_Checklists__c guidelines2update = (ERP7__Guideline_Checklists__c) JSON.deserialize(parent,ERP7__Guideline_Checklists__c.class);
                
                guidelines2update.ERP7__Checklist__r = null;
                guidelines2update.ERP7__Status__c = guidelines2update.ERP7__Instructions__c;
                guidelines2update.ERP7__Is_Mandatory__c = false;
                //guidelines2update.Attachments = null;
                
                upsert guidelines2update;
                
                for (Integer i = 0; i < fileName.size(); i++) {
                    base64Data[i] = EncodingUtil.urlDecode(base64Data[i], 'UTF-8'); 
                    Attachment a = new Attachment(); a.parentId = guidelines2update.Id;  a.Body = EncodingUtil.base64Decode(base64Data[i]); a.Name = fileName[i];  a.ContentType = contentType[i];
                    attachments2Insert.add(a); 
                } 
                insert attachments2Insert; 
                Attachments = [Select Id, Name, ParentId from Attachment where ParentId =:guidelines2update.Id Order By CreatedDate ASC]; 
            } 
            return Attachments;  
        } 
        catch(Exception e) {
            /* throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString() ); */
            return null;
        } 
    }
    
    
    public class ReceivedSILIWrap{
        @AuraEnabled public  Stock_Inward_Line_Item__c sili                                           { get; set; }
        @AuraEnabled public List<ERP7__Guideline_Checklists__c>  guideline                            { get; set; }
        public ReceivedSILIWrap(){
            sili = new Stock_Inward_Line_Item__c();
            guideline = new List<ERP7__Guideline_Checklists__c>();
        }
    }
    public class comWrap {
        @AuraEnabled public Boolean ShowCustomSerailNumberGeneration                { get ; set; }
        @AuraEnabled public ERP7__Manufacturing_Order__c manuOrders                 { get ; set; }
        @AuraEnabled public List<ERP7__WIP_Flow__c> wipflows                        { get ; set; }
        @AuraEnabled public List<ERP7__WIP_Flow__c> wipflowsList                        { get ; set; }
        @AuraEnabled public List<mrpWrap> MRPs                                      { get ; set; }
        @AuraEnabled public List<ERP7__WO__c> WOs                                   { get ; set; }
        @AuraEnabled public List<ERP7__Stock_Outward_Line_Item__c> SOLIs            { get ; set; }
        @AuraEnabled public List<ERP7__Stock_Inward_Line_Item__c> SILIs             { get ; set; }
        @AuraEnabled public List< ERP7__Variance__c > AlternativeBOMs               { get ; set; }
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public Boolean isSelect                                        { get ; set; }
        @AuraEnabled public Boolean ReserveStock                                    { get ; set; }
        @AuraEnabled public List<ERP7__Serial_Number__c> moSerialNos                { get ; set; }
        @AuraEnabled public List<ERP7__Serial_Number__c> moSerialNosList           { get ; set; }
        @AuraEnabled public List<ERP7__Batch__c> moBatchNos                         { get ; set; }
        @AuraEnabled public ERP7__Serial_Number__c SerialNumber2Upsert              { get ; set; }
        @AuraEnabled public ERP7__Batch__c Batch2Upsert                             { get ; set; }
        @AuraEnabled public ERP7__Stock_Outward_Line_Item__c NewSOLI                { get ; set; }
        @AuraEnabled public ERP7__MRP__c NewMRP                                     { get ; set; }
        @AuraEnabled public List<ERP7__PO__c> POS                                   { get ; set; }
        @AuraEnabled public List<ERP7__Requisition__c> PRS                          { get ; set; }
        @AuraEnabled public Product2 Product                                        { get ; set; }
        @AuraEnabled public ERP7__Routing__c Routing                                { get ; set; }
        @AuraEnabled public ERP7__Version__c Version                                { get ; set; }
        @AuraEnabled public List<selectOptions> moStatus                            { get ; set; }
        @AuraEnabled public List<ERP7__UOM_Conversion__mdt> UOMCs                   { get ; set; }
        @AuraEnabled public Date StartDate                                          { get ; set; }
        @AuraEnabled public Date ExpectedDate                                       { get ; set; }
        @AuraEnabled public List<WOWrap> WOWS                                       { get ; set; }
        @AuraEnabled public Attachment Attachment                                   { get ; set; }
        @AuraEnabled public List<Attachment> SelectedAttachments                    { get ; set; }
        @AuraEnabled public Boolean  allowMultiPos                                  { get ; set; }
        @AuraEnabled public Boolean isEditable                                      { get ; set; }
        @AuraEnabled public Boolean showCosts                                       { get ; set; }
        @AuraEnabled public Boolean linksNewOptions                                 { get ; set; }
        @AuraEnabled public Boolean showAutoStockAllocation                         { get ; set; }
        @AuraEnabled public Boolean showManualStockAllocation                       { get ; set; }
        @AuraEnabled public Boolean  isStandardOrder                                { get ; set; }
        @AuraEnabled public Integer totalWips                                       { get ; set; }
        @AuraEnabled public Integer totalSerials                                       { get ; set; }
        @AuraEnabled public Boolean  ShowLangOptionForTraveller                                { get; set; }
        @AuraEnabled public Boolean  ReplaceTravellerOrgURL                                { get; set; }
        @AuraEnabled public Boolean showRequisition                                   { get; set; }
        @AuraEnabled public Integer wipflowsLength                                     { get; set; }
        @AuraEnabled public Integer serialsLength                                     { get; set; }
        @AuraEnabled public Boolean ShowProdStatus                                   { get; set; }
        @AuraEnabled public Boolean showVendorCode                                   { get; set; }
        @AuraEnabled public Boolean showScrapDetails                                     { get; set; }
        @AuraEnabled public Boolean showMOLabels                                         { get; set; }
        @AuraEnabled public Boolean  AllowMRPDelete                                       { get; set; }
        @AuraEnabled public Boolean enableQA										     { get; set; }
        @AuraEnabled public Boolean PreventStatusEdit                                    { get; set; }
        @AuraEnabled public Boolean showUplaodforItems                                              { get; set; }
        public comWrap() {
            serialsLength= 0;
            wipflowsLength= 0;
            showRequisition = true;
            ShowCustomSerailNumberGeneration = showVendorCode = showScrapDetails = showMOLabels = AllowMRPDelete = PreventStatusEdit = enableQA = showUplaodforItems = false;
            isStandardOrder = false;
            totalWips = 0;
            totalSerials = 0;
            manuOrders = new ERP7__Manufacturing_Order__c(ERP7__StartDate__c = system.today(), ERP7__Expected_Date__c = system.today()+1, ERP7__ExpectedDate__c= system.today()+1);
            wipflows = new List<ERP7__WIP_Flow__c>(); 
            wipflowsList = new List<ERP7__WIP_Flow__c>(); 
            MRPs = new List<mrpWrap>();
            WOs = new List<ERP7__WO__c>();
            SOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
            SILIs = new List<ERP7__Stock_Inward_Line_Item__c>();
            AlternativeBOMs = new List<ERP7__Variance__c>();
            errorMsg = ''; 
            isSelect = false;
            ReserveStock = false;
            moSerialNos = new List<ERP7__Serial_Number__c>();
            moSerialNosList = new List<ERP7__Serial_Number__c>();
            moBatchNos = new List<ERP7__Batch__c>();
            SerialNumber2Upsert = new ERP7__Serial_Number__c();
            Batch2Upsert = new ERP7__Batch__c(); 
            NewSOLI = new ERP7__Stock_Outward_Line_Item__c();
            NewMRP = new ERP7__MRP__c(); 
            POS = new List<ERP7__PO__c>();
            PRS = new List<ERP7__Requisition__c>(); 
            Product = new Product2();
            moStatus = new List < selectOptions > ();
            UOMCs = new List<ERP7__UOM_Conversion__mdt>();
            ExpectedDate = system.today()+1;
            StartDate = system.today();
            Routing = new ERP7__Routing__c();
            Version = new ERP7__Version__c();
            WOWS = new List<WOWrap>();
            Attachment = new Attachment();
            SelectedAttachments = new List<Attachment>();
            isEditable = true;
            showCosts = true;
            linksNewOptions = true;
            showAutoStockAllocation = true;
            showManualStockAllocation = true;
            ShowLangOptionForTraveller= false;
            ReplaceTravellerOrgURL= false;
            ShowProdStatus = false;
        }
    }  
    
    public class mrpWrap {
        @AuraEnabled public ERP7__MRP__c MRP                                        { get ; set; }
        @AuraEnabled public List<ERP7__MRP__c> MRPs                                 { get ; set; }
        @AuraEnabled public List<ERP7__Stock_Outward_Line_Item__c> SOLIs            { get ; set; }
        @AuraEnabled public Decimal Stock                                           { get ; set; }
        @AuraEnabled public Decimal Qnty                                            { get ; set; }
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public Boolean isSelect                                        { get ; set; }
        @AuraEnabled public String bgColor                                          { get ; set; }
        @AuraEnabled public ERP7__Manufacturing_Order__c MO                         { get ; set; }
        @AuraEnabled public List<ERP7__Serial_Number__c> SerialNos                  { get ; set; }
        @AuraEnabled public List<ERP7__Batch__c> Batches                            { get ; set; }
        @AuraEnabled public Decimal ActualWeight                                    { get ; set; }
        @AuraEnabled public List<selectOptions> UOMS                                { get ; set; }
        @AuraEnabled public String SelectedUOM                                      { get ; set; }
        @AuraEnabled public Decimal WeightMultiplier                                { get ; set; }
        @AuraEnabled public Decimal BOMWeightMultiplier                             { get ; set; }
        @AuraEnabled public ERP7__Product_Feature__c Feature                        { get ; set; }
        @AuraEnabled public Product2 Product                                        { get ; set; }
        @AuraEnabled public ERP7__Routing__c Routing                                { get ; set; }
        @AuraEnabled public ERP7__Version__c Version                                { get ; set; }
        @AuraEnabled public Decimal oldMRPQty                                       { get ; set; }
        @AuraEnabled public Decimal MRPQuantity                                     { get ; set; }
 @AuraEnabled  public List<ERP7__Stock_Outward_Line_Item__c> pagedSOLIs {get; set;}
   public List<Integer> displayPages {get; set;}
   public Integer currentPage {get; set;}
   public Integer totalPages {get; set;}
    public Integer pageSize {get; set;}
    public String pageInfo {get; set;}
        
        public mrpWrap() {
             this.SOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
        this.pagedSOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
        this.displayPages = new List<Integer>();
        this.currentPage = 1;
        this.totalPages = 1;
        this.pageSize = 50;
        this.pageInfo = '';
            MRPQuantity = 0;
            MRP = new ERP7__MRP__c();
            MRPs = new List<ERP7__MRP__c>();
            Stock = 0;
            Qnty = 0;
            oldMRPQty = 0;
            ActualWeight = 0;
            WeightMultiplier = 1;
            BOMWeightMultiplier = 1;
            errorMsg = '';
            isSelect = false;
            bgColor = '#fff'; 
            MO = new ERP7__Manufacturing_Order__c();
            SOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
            SerialNos = new List<ERP7__Serial_Number__c>();
            Batches = new List<ERP7__Batch__c>();
            UOMS = new List < selectOptions > ();
            SelectedUOM = '';
            Feature = new ERP7__Product_Feature__c();
            Product = new Product2();
            Routing = new ERP7__Routing__c();
            Version = new ERP7__Version__c();
        }
    }
    
    public class ScanWrap {
        @AuraEnabled public String step                                             { get ; set; }
        @AuraEnabled public String substep                                          { get ; set; }
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public ERP7__Serial_Number__c Serial                           { get ; set; }
        @AuraEnabled public ERP7__Batch__c Batch                                    { get ; set; }
        
        public ScanWrap() {   
            step = '';
            substep = '';
            errorMsg = '';
            Serial = new ERP7__Serial_Number__c();    
            Batch = new ERP7__Batch__c();
        }
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
            //selected = false;
        }
        public selectOptions(String lab, string val, Boolean sel) {  
            label = lab;
            value = val;
            selected = sel;     
        }
    }
    
    public class WOWrap {
        @AuraEnabled public ERP7__WO__c WorkOrder                                   { get ; set; }
        @AuraEnabled public List< ERP7__Time_Card_Entry__c > TimeCardEntries        { get ; set; }
        @AuraEnabled public List<ERP7__Actions_Tasks__c> Tasks                      { get ; set; }
        @AuraEnabled public List< ERP7__MRP__c > MRPS                               { get ; set; }
        @AuraEnabled public List<ERP7__Serial_Number__c> SerialNos                  { get ; set; }
        @AuraEnabled public List<ERP7__Batch__c> BatchNos                           { get ; set; }
        @AuraEnabled public List< ERP7__Resource_Allocation__c > RAS                { get ; set; }
        @AuraEnabled public Boolean isSelect                                        { get ; set; }
        
        public WOWrap() {
            WorkOrder = new ERP7__WO__c();
            TimeCardEntries= new List< ERP7__Time_Card_Entry__c >();
            Tasks = new List<ERP7__Actions_Tasks__c>();
            MRPS = new List< ERP7__MRP__c >();
            SerialNos = new List<ERP7__Serial_Number__c>();
            BatchNos = new List<ERP7__Batch__c>(); 
            RAS = new List< ERP7__Resource_Allocation__c >();
            isSelect = false;
        }
    }
     public static final String base64Chars = '' +
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
    @AuraEnabled 
    public static Map<String, List<SelectOptions>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        Map<String,List<SelectOptions>> objResults = new Map<String,List<SelectOptions>>();
        //Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){  return objResults; }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){ return objResults;     
                                                                                                   }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            String value = ple.getValue();
            //objResults.put(label, new List<String>());
            //controllingValues.add(label);
            objResults.put(label, new List<SelectOptions>());
            controllingValues.add(label);
        }
        for (PicklistEntryWrapper plew : depEntries) {
            
            String label = plew.label;
            String value = plew.value;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    //objResults.get(controllingValues.get(i)).add(label);
                    objResults.get(controllingValues.get(i)).add(new SelectOptions(value,label));
                }
            }
        }
        return objResults;
    }
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        
        public String label {get;set;} public String active {get;set;} public String value {get;set;}
        public String validFor {get;set;} public String defaultValue {get;set;}public PicklistEntryWrapper(){            
        }
     
    }
   @AuraEnabled
public static List<String> getLocationsForProduct(String productId, String siteId) {
    List<String> locationIds = new List<String>();
    if(productId == null || siteId == null) return locationIds;
    
    // Locations are in related list of warehouse - filter by warehouse (site)
    for(AggregateResult ar : [
        SELECT ERP7__Location__c locId
        FROM ERP7__Inventory_Stock__c
        WHERE ERP7__Warehouse__c = :siteId
        AND ERP7__Product__c = :productId
        AND ERP7__Number_of_Item_In_Stock__c > 0
        AND ERP7__Active__c = true
        AND ERP7__Location__c != null
        GROUP BY ERP7__Location__c
    ]) {
        locationIds.add((String)ar.get('locId'));
    }
    return locationIds;
}
    @AuraEnabled
public static Decimal getLocationStock(String locationId, String productId, String siteId) {
    if(locationId == null || productId == null) return 0;
    
    Decimal stock = 0;
    for(AggregateResult ar : [
        SELECT SUM(ERP7__Number_of_Item_In_Stock__c) totalStock
        FROM ERP7__Inventory_Stock__c
        WHERE ERP7__Location__c = :locationId
        AND ERP7__Product__c = :productId
        AND ERP7__Warehouse__c = :siteId
        AND ERP7__Number_of_Item_In_Stock__c > 0
        AND ERP7__Active__c = true
    ]) {
        if(ar.get('totalStock') != null) stock = (Decimal)ar.get('totalStock');
    }
    return stock;
}
}