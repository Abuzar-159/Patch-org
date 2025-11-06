/* Changes made by Shaguftha on 03/05/2023
 * Reason : For Kit products the batch was defaulting for both serial and Lot tracked product 
 * fix: handled through custom setting already used for Non-kit products
 * Changes made in redirect2NextTab methos on line 915,920 and 931
 * 
 * Changes made by Arshad on 18/09/2023
 * Reason : Heap size issue fix for 4000+ qty to be displayed on pickscreen
 * Changes made in redirect2NextTab, added new method getcommitedSOLIs
 * 
*/
/* Changes made by shaguftha on 18/09/24
 * Reason : the stock of the product was not populating correctly
 * use Map<Id,<Id,String>> instead of Map<Id,String>
 * 
*/
public With Sharing Class OutboundLogisticsLightning { 
    //Change made on 1764 & 1765 line in method createPacksInit to populate the PO num from order to package
    @AuraEnabled      
    public static comWrap getAll(String logisticId, String searchText, String Channel, String Site, Integer Offset, Integer Show,string filter,String shipFilter){
        
       
        String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
        utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');    
     
        String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
        utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
        logLineFields += ', ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c, ERP7__Order_Product__r.OrderId ,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c, ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
            +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c, ERP7__Order_Product__r.Order.Name, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name, ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name';
        
        String PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
        utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');            
        String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
        utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');     
        
        comWrap comW = new comWrap();
        try{
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){ comW.Allowscanning = FC.ERP7__Enable_Scanning_for_Flows__c; comW.dontallowChannelRemove = FC.ERP7__Restrict_Selected_Channel__c; comW.ShowAllfilters = FC.ERP7__Show_all_Filters_in_outbound_screen__c; comW.ShowShipfilters = FC.ERP7__Show_Ship_Filter_in_Outbound__c;}
            if(comW.ShowShipfilters){
                List<String> options = new List<String>();   options.add('--None--'); Schema.DescribeFieldResult fieldResult = ERP7__Logistic__c.ERP7__Shipment_type__c.getDescribe();  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();  for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); comW.shiptypes = options;
            }
            
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                       ERP7__Organisation_Business_Unit__c
                       From ERP7__Employees__c
                       Where ERP7__Employee_User__c = : UserInfo.getUserId()
                       Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) { 
                comW.Employee = empList[0]; 
                if(Channel != Null && Channel != '') comW.Employee.Channel__c = Channel;
                if(comW.Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name
                                                                                  From Distribution_Channel__c
                                                                                  Where Channel__c = : comW.Employee.Channel__c And Active__c = true And Site__c != Null
                                                                                  Order By ERP7__Priority__c ASC];
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {
                            comW.channelSites.add(new SelectOptions(DC.Site__c, DC.Name));
                        }
                        comW.selectedSite = DistributionChannels[0].Site__c;
                    }  
                    if(Site != Null && Site != '') comW.selectedSite = Site;
                } 
            } 
            String tempPOChannel = comW.Employee.Channel__c;   
            List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>(); 
            List<ERP7__Logistic__c> Recs = new List<ERP7__Logistic__c>(); 
            String selectedSite = comW.selectedSite;      
            if(!Schema.sObjectType.ERP7__Logistic__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic__c.Label));
            else { 
                String query1 = 'select ' + String.escapeSingleQuotes(logFields) + ' , ERP7__Transfer_Order__r.ERP7__Is_Closed__c,ERP7__Order_S__r.ERP7__Is_Back_Order__c ,ERP7__Order_S__r.Name , ERP7__Order_S__r.OrderNumber ,ERP7__Sales_Order__r.ERP7__Is_Back_Order__c, ERP7__Sales_Order__r.Name, ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, '+
                    +' ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where (ERP7__Type__c =\'Outbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__RMA__c = Null ';
                comW.allLogs = Database.query(query1);
                if(logisticId != null && logisticId != ''){                    Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ', ERP7__Transfer_Order__r.ERP7__Is_Closed__c,ERP7__Order_S__r.ERP7__Is_Back_Order__c ,ERP7__Order_S__r.Name ,ERP7__Sales_Order__r.ERP7__Is_Back_Order__c, ERP7__Sales_Order__r.Name , ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where ERP7__Active__c = true And Total_Quantity__c > 0 And (ERP7__Type__c =\'Outbound\') And Id =\'' + String.escapeSingleQuotes(logisticId) + '\' And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Channel__c =: tempPOChannel And ERP7__RMA__c = Null Order by CreatedDate Desc Limit 1');
                } else {
                system.debug('filter : '+filter );
                    String searchTextPat = '%'+searchText+'%';
                   
                                        string query = 'select ' + String.escapeSingleQuotes(logFields) + ' , ERP7__Transfer_Order__r.ERP7__Is_Closed__c,ERP7__Order_S__r.ERP7__Is_Back_Order__c ,ERP7__Order_S__r.Name , ERP7__Order_S__r.OrderNumber ,ERP7__Sales_Order__r.ERP7__Is_Back_Order__c, ERP7__Sales_Order__r.Name, ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, '+
                        +' ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where (ERP7__Type__c =\'Outbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__RMA__c = Null And (Name like :searchTextPat Or ERP7__Sales_Order__r.Name like :searchTextPat Or ERP7__Order_S__r.Name like :searchTextPat Or ERP7__Account__r.Name like :searchTextPat Or ERP7__Barcode__c like :searchTextPat)';
                    if(filter != 'DeliveredOrders' && filter != 'ShippedOrders') query += ' and ERP7__Closed__c = false';
                    
                    if(filter == 'OrdersToBeShipped' && comW.ShowAllfilters == true) query += ' and ERP7__Shipped_Quantity__c = 0 and ERP7__Delivered_Quantity__c = 0 and ERP7__Packed_Quantity__c  > 0  and ERP7__Ready_To_Ship__c = true'; //
                    else if(filter == 'OrdersToBeShipped' && comW.ShowAllfilters == false) query += ' and ERP7__Shipped_Quantity__c = 0 and ERP7__Delivered_Quantity__c = 0 and ERP7__Picked_Quantity__c >= 0 '; //and ERP7__Ready_To_Ship__c = true // ERP7__Packed_Quantity__c  >= 0 and commented by shaguftha on 06/09/2023
                    if(filter == 'PartiallyShippedOrders') query += ' and ERP7__Shipped_Quantity__c > 0  and ERP7__Ready_To_Ship__c = true ';
                    if(filter == 'NewOrders') query += ' and ERP7__Picked_Quantity__c = 0 and ERP7__Packed_Quantity__c = 0 and ERP7__Shipped_Quantity__c = 0';
                    if(filter == 'DeliveredOrders') query += ' and ((ERP7__Shipped_Quantity__c > 0 and ERP7__Delivered_Quantity__c > 0) OR ERP7__Closed__c = true) ';
                    if(filter == 'ShippedOrders') query += ' and  ERP7__Picked_Quantity__c > 0 and ERP7__Packed_Quantity__c > 0 and ERP7__Shipped_Quantity__c > 0 and ERP7__Closed__c = false';
                     if(shipFilter != null && shipFilter != '' && shipFilter != '--None--') query += ' and ERP7__Shipment_type__c =:shipFilter';
                    query +=' Order by CreatedDate Desc Limit 1000';
                    comW.query = query ;
                    Logs = Database.query(query);
                    system.debug('Logs : '+Logs.size());
                    if(filter == 'PartiallyShippedOrders'){
                        List<ERP7__Logistic__c> partialLogs = new List<ERP7__Logistic__c>();
                        for(ERP7__Logistic__c log : Logs){ if(log.ERP7__Total_Quantity__c > 0 && log.ERP7__Shipped_Quantity__c > 0 && log.ERP7__Shipped_Quantity__c  < log.ERP7__Total_Quantity__c && log.ERP7__Packed_Quantity__c > 0){  partialLogs.add(log);
                            }
                        }
                        Logs = partialLogs;
                    }
                   
                    if(filter == 'ShippedOrders'){
                         List<ERP7__Logistic__c> ShippedLogs = new List<ERP7__Logistic__c>();
                        for(ERP7__Logistic__c log : Logs){   if(log.ERP7__Total_Quantity__c > 0 && log.ERP7__Shipped_Quantity__c > 0 && log.ERP7__Shipped_Quantity__c == log.ERP7__Total_Quantity__c  && log.ERP7__Packed_Quantity__c > 0 && log.ERP7__Packed_Quantity__c == log.ERP7__Total_Quantity__c && log.ERP7__Picked_Quantity__c > 0 && log.ERP7__Picked_Quantity__c == log.ERP7__Total_Quantity__c){  ShippedLogs.add(log);
                            }
                        }
                        Logs = ShippedLogs;
                    }
                    
                    
                    comW.recSize = Logs.size();
                    comW.PNS = new List<Integer>();
                    comW.show = Show;
                    comW.Offset = Offset;
                    Integer ES = comW.recSize;
                    Integer j=0;
                    while(ES >= comW.show){ j++; comW.PNS.add(j); ES=ES-comW.show;
                                          } 
                    if(ES > 0) comW.PNS.add(j+1);
                    
                    for(Integer i = 0; i < Logs.size(); i++){
                        if(i >= comW.Offset+comW.show) break;
                        if(i >= comW.Offset) Recs.add(Logs[i]);
                    }
                    Logs = Recs;
                    if(Logs.size() > 0 && comW.Offset != 0){ comW.startCount = comW.Offset + 1; comW.endCount = comW.Offset + Logs.size(); comW.PageNum = (comW.Offset+comW.show)/comW.show;
                                                           }
                    else if(Logs.size() > 0 && comW.Offset == 0){
                        comW.startCount = 1;
                        comW.endCount = Logs.size();
                        comW.PageNum = 1;
                    }  
                }
            } 
            Set<Id> loIds = new Set<Id>();
            Map<Id, Map<Id, String>> logOrders = new Map<Id, Map<Id, String>>();
            List< ERP7__Logistic_Line_Item__c > loliList = new List< ERP7__Logistic_Line_Item__c >();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>();
            Map<Id, List<ERP7__Logistic_Line_Item__c>> logLinesMap = new Map<Id, List<ERP7__Logistic_Line_Item__c>>();
            for(ERP7__Logistic__c log : Logs) { loIds.add(log.Id); logLinesMap.put(log.Id, new List<ERP7__Logistic_Line_Item__c>()); logOrders.put(log.Id, new Map<Id, String>());}  
            
            if(loIds.size() > 0) {
                if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic_Line_Item__c.Label));
                else loliList = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where (ERP7__Logistic__c In : loIds)');
                
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from ERP7__Package__c where (ERP7__Logistic__c In: loIds)'); 
                
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from ERP7__Shipment__c where (ERP7__Logistic__c In: loIds AND ERP7__Return_Shipment__c = false)'); 
            }
            if(Logs.size() > 0) {
                
                for(ERP7__Logistic_Line_Item__c loli : loliList) { 
                    List<ERP7__Logistic_Line_Item__c> myLogLine = logLinesMap.get(loli.ERP7__Logistic__c);
                    myLogLine.add(loli);
                    logLinesMap.put(loli.ERP7__Logistic__c, myLogLine);
                }
                
                for(ERP7__Logistic_Line_Item__c solis: loliList) {
                    Map<Id, String> myLogOrders = logOrders.get(solis.ERP7__Logistic__c);
                    
                    if(solis.ERP7__Order_Product__r.OrderId != Null) {
                        myLogOrders.put(solis.ERP7__Order_Product__r.OrderId, solis.ERP7__Order_Product__r.Order.Name);
                    }
                    if(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != Null) {
                        myLogOrders.put(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name);
                    } 
                    if(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != Null) {                        myLogOrders.put(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name);
                    }
                    if(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c != Null){                        myLogOrders.put(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name);
                    }
                    if(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != Null) {  myLogOrders.put(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name);
                    }
                    if(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c != Null) {                        myLogOrders.put(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name);
                    }
                    logOrders.put(solis.ERP7__Logistic__c, myLogOrders);
                }
                
                system.debug('*** logOrders.size '+ logOrders);
                
                for(ERP7__Logistic__c log : Logs) { 
                    Wrappers wrap = new Wrappers();  
                    
                    Map<Id, String> myLogOrders = logOrders.get(log.Id);
                    for(Id oId : myLogOrders.keySet()) {
                        orderWrapper owrap = new orderWrapper();
                        owrap.OrderId = oId;
                        owrap.OrderName = myLogOrders.get(oId);
                        wrap.orderWrapperList.add(owrap);
                    }
                    
                    for(ERP7__Logistic_Line_Item__c loli : logLinesMap.get(log.Id)) { 
                        if(loli.ERP7__Logistic__c == log.Id && loli.Picked_Quantity__c != loli.Packed_Quantity__c) {   wrap.isAvailablePackages = true; break; } 
                    }
                    for(Package__c pkg : pkgList) { if(pkg.ERP7__Logistic__c == log.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) { 
                        if(ship.ERP7__Logistic__c == log.Id) {  wrap.isAvailableShipments = true;  if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++; if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    }
                    if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;
                    wrap.Logistic = log;
                    comW.Logistics.add(wrap);
                }
            } 
            else comW.exceptionError = 'Sorry, no records available to view.';  } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
        
    }
    
    @AuraEnabled
    public static comWrap fetchSortedLogistics(String OrderBy,String SortOrder, String DcId,String ChId,Integer Show,Integer Offset, String filter){
        system.debug('filter-->'+filter);
        system.debug('SortOrder-->'+SortOrder);
        
        String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
        utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c'); 
        comWrap comW =  new comWrap();
        system.debug('filterss-->'+comW.ShowAllfilters);
       
        String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
        utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
        logLineFields += ', ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c, ERP7__Order_Product__r.OrderId ,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c, ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
            +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c, ERP7__Order_Product__r.Order.Name, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name, ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name';
        
        String PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
        utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');            
        
        String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
        utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c'); 
        try{
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                       ERP7__Organisation_Business_Unit__c
                       From ERP7__Employees__c
                       Where ERP7__Employee_User__c = : UserInfo.getUserId()
                       Order by CreatedDate Asc Limit 1];
            if(empList.size() > 0){
                comW.Employee = empList[0]; 
                if(ChId != Null && ChId != '') comW.Employee.Channel__c = ChId;
                if(comW.Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name
                                                                                  From Distribution_Channel__c
                                                                                  Where Channel__c = : comW.Employee.Channel__c And Active__c = true And Site__c != Null
                                                                                  Order By ERP7__Primary__c Desc];
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {  comW.channelSites.add(new SelectOptions(DC.Site__c, DC.Name)); }
                        comW.selectedSite = DistributionChannels[0].Site__c;
                        
                    }
                    if(DcId != Null && DcId != '') comW.selectedSite = DcId;
                    
                }
                
            }
            String tempPOChannel = comW.Employee.Channel__c;   
            List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>(); 
            List<ERP7__Logistic__c> Recs = new List<ERP7__Logistic__c>(); 
            String selectedSite = comW.selectedSite;
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){ comW.ShowAllfilters = FC.ERP7__Show_all_Filters_in_outbound_screen__c; }
            system.debug('filterss-->'+comW.ShowAllfilters);
            if(!Schema.sObjectType.ERP7__Logistic__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic__c.Label));
            else{
                
                String query =' Select '+ String.escapeSingleQuotes(logFields) +', ERP7__Transfer_Order__r.ERP7__Is_Closed__c,ERP7__Order_S__r.ERP7__Is_Back_Order__c ,ERP7__Order_S__r.Name , ERP7__Order_S__r.OrderNumber ,ERP7__Sales_Order__r.ERP7__Is_Back_Order__c, ERP7__Sales_Order__r.Name, ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, '+
                    +' ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where (ERP7__Type__c =\'Outbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__RMA__c = Null And ERP7__Closed__c = false '; 
                if(filter != 'DeliveredOrders' && filter != 'ShippedOrders') query += ' and ERP7__Closed__c = false';
                if(filter == 'OrdersToBeShipped' && comW.ShowAllfilters == true) query += ' and ERP7__Shipped_Quantity__c = 0 and ERP7__Delivered_Quantity__c = 0 and ERP7__Packed_Quantity__c  > 0  and ERP7__Ready_To_Ship__c = true'; //
                else if(filter == 'OrdersToBeShipped' && comW.ShowAllfilters == false) query += ' and ERP7__Shipped_Quantity__c = 0 and ERP7__Delivered_Quantity__c = 0 and ERP7__Picked_Quantity__c >= 0 '; //and ERP7__Ready_To_Ship__c = true // ERP7__Packed_Quantity__c  >= 0 and commented by shaguftha on 06/09/2023
                if(filter == 'PartiallyShippedOrders') query += ' and ERP7__Shipped_Quantity__c > 0  and ERP7__Ready_To_Ship__c = true ';
                if(filter == 'NewOrders') query += ' and ERP7__Picked_Quantity__c = 0 and ERP7__Packed_Quantity__c = 0 and ERP7__Shipped_Quantity__c = 0';
                if(filter == 'DeliveredOrders') query += ' and ERP7__Shipped_Quantity__c > 0 and ERP7__Delivered_Quantity__c > 0 and ERP7__Closed__c = true ';
                if(filter == 'ShippedOrders') query += ' and  ERP7__Picked_Quantity__c > 0 and ERP7__Packed_Quantity__c > 0 and ERP7__Shipped_Quantity__c > 0 and ERP7__Closed__c = false';
                query +=' Order by ';
                query = query + String.escapeSingleQuotes(OrderBy) + ' ' + String.escapeSingleQuotes(SortOrder);
                
                Logs = Database.query(query);
                system.debug('Logs : '+Logs.size());
                if(filter == 'PartiallyShippedOrders'){                    List<ERP7__Logistic__c> partialLogs = new List<ERP7__Logistic__c>();                    for(ERP7__Logistic__c log : Logs){                        if(log.ERP7__Total_Quantity__c > 0 && log.ERP7__Shipped_Quantity__c > 0 && log.ERP7__Shipped_Quantity__c  < log.ERP7__Total_Quantity__c && log.ERP7__Packed_Quantity__c > 0){                            partialLogs.add(log);                       }                   }                    Logs = partialLogs;                }
                
                if(filter == 'ShippedOrders'){                    List<ERP7__Logistic__c> ShippedLogs = new List<ERP7__Logistic__c>();                    for(ERP7__Logistic__c log : Logs){                        if(log.ERP7__Total_Quantity__c > 0 && log.ERP7__Shipped_Quantity__c > 0 && log.ERP7__Shipped_Quantity__c == log.ERP7__Total_Quantity__c  && log.ERP7__Packed_Quantity__c > 0 && log.ERP7__Packed_Quantity__c == log.ERP7__Total_Quantity__c && log.ERP7__Picked_Quantity__c > 0 && log.ERP7__Picked_Quantity__c == log.ERP7__Total_Quantity__c){                           ShippedLogs.add(log);                       }                    }                    Logs = ShippedLogs;               }
                comW.recSize = Logs.size();
                comW.PNS = new List<Integer>();
                comW.show = Show;
                comW.Offset = Offset;
                Integer ES = comW.recSize;
                Integer j=0;
                while(ES >= comW.show){ j++; comW.PNS.add(j); ES=ES-comW.show;
                                      } 
                if(ES > 0) comW.PNS.add(j+1);
                for(Integer i = 0; i < Logs.size(); i++){
                    if(i >= comW.Offset+comW.show) break;
                    if(i >= comW.Offset) Recs.add(Logs[i]);
                }
                Logs = Recs;
                if(Logs.size() > 0 && comW.Offset != 0){ comW.startCount = comW.Offset + 1; comW.endCount = comW.Offset + Logs.size(); comW.PageNum = (comW.Offset+comW.show)/comW.show;
                                                       }
                else if(Logs.size() > 0 && comW.Offset == 0){ comW.startCount = 1; comW.endCount = Logs.size(); comW.PageNum = 1;
                                                            } 
            }
            Set<Id> loIds = new Set<Id>();
            Map<Id, Map<Id, String>> logOrders = new Map<Id, Map<Id, String>>();
            List< ERP7__Logistic_Line_Item__c > loliList = new List< ERP7__Logistic_Line_Item__c >();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>();
            Map<Id, List<ERP7__Logistic_Line_Item__c>> logLinesMap = new Map<Id, List<ERP7__Logistic_Line_Item__c>>();
            for(ERP7__Logistic__c log : Logs) { loIds.add(log.Id); logLinesMap.put(log.Id, new List<ERP7__Logistic_Line_Item__c>()); logOrders.put(log.Id, new Map<Id, String>());}  
            
            if(loIds.size() > 0) {
                if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic_Line_Item__c.Label));
                else loliList = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where (ERP7__Logistic__c In : loIds)');
                
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from ERP7__Package__c where (ERP7__Logistic__c In: loIds)'); 
                
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from ERP7__Shipment__c where (ERP7__Logistic__c In: loIds AND ERP7__Return_Shipment__c = false)'); 
                
            }
            if(Logs.size() > 0) {
                
                for(ERP7__Logistic_Line_Item__c loli : loliList) { 
                    List<ERP7__Logistic_Line_Item__c> myLogLine = logLinesMap.get(loli.ERP7__Logistic__c);
                    myLogLine.add(loli);
                    logLinesMap.put(loli.ERP7__Logistic__c, myLogLine);
                }
                
                for(ERP7__Logistic_Line_Item__c solis: loliList) {
                    Map<Id, String> myLogOrders = logOrders.get(solis.ERP7__Logistic__c);
                    
                    if(solis.ERP7__Order_Product__r.OrderId != Null) {                       myLogOrders.put(solis.ERP7__Order_Product__r.OrderId, solis.ERP7__Order_Product__r.Order.Name);
                    }
                    if(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != Null) {
                        myLogOrders.put(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name);
                    } 
                    if(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != Null) {                        myLogOrders.put(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name);
                    }
                    if(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c != Null){                        myLogOrders.put(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name);
                    }
                    if(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != Null) {                       myLogOrders.put(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name);
                    }
                    if(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c != Null) {                        myLogOrders.put(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name);
                    }
                    logOrders.put(solis.ERP7__Logistic__c, myLogOrders);
                }
                
                system.debug('*** logOrders.size '+ logOrders);
                
                
                for(ERP7__Logistic__c log : Logs) { 
                    Wrappers wrap = new Wrappers();  
                    
                    Map<Id, String> myLogOrders = logOrders.get(log.Id);
                    for(Id oId : myLogOrders.keySet()) {
                        orderWrapper owrap = new orderWrapper();
                        owrap.OrderId = oId;
                        owrap.OrderName = myLogOrders.get(oId);
                        wrap.orderWrapperList.add(owrap);
                    }
                    
                    for(ERP7__Logistic_Line_Item__c loli : logLinesMap.get(log.Id)) { 
                        if(loli.ERP7__Logistic__c == log.Id && loli.Picked_Quantity__c != loli.Packed_Quantity__c) { 
                            wrap.isAvailablePackages = true; break; 
                        } 
                    }
                    for(Package__c pkg : pkgList) { if(pkg.ERP7__Logistic__c == log.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) {                         if(ship.ERP7__Logistic__c == log.Id) { wrap.isAvailableShipments = true;                                                              if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++;                                                              if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');                                                             } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;
                    wrap.Logistic = log;
                    comW.Logistics.add(wrap);
                }
            }
        }
        catch(Exception e){comW.exceptionError=e.getMessage()+' at '+e.getLineNumber(); system.debug('comW.exceptionError : '+comW.exceptionError);}
        
        return comW;
    }
    
    //Added by Arshad 18 Sep 2023
    @AuraEnabled
    public static List<CommittedStockWrap> getcommitedSOLIs(String soliIds){
        system.debug('getcommitedSOLIs called');
        Set<String> solis = (Set<String>) JSON.deserialize(soliIds, Set<String> .class);
        String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
        Transient List<ERP7__Stock_Outward_Line_Item__c> Allpplis = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ',ERP7__Logistic_Line_Item__r.ERP7__Quantity__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Picture__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__r.Name,ERP7__Product__r.Name,ERP7__Logistic_Line_Item__r.Name, ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c,ERP7__Logistic_Line_Item__r.ERP7__Packed_Quantity__c,ERP7__Serial__r.Id, ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c from Stock_Outward_Line_Item__c where Id IN :solis ');
        List<CommittedStockWrap> cswList = new List<CommittedStockWrap>();
        system.debug('getcommitedSOLIs Allpplis~>'+Allpplis.size());
        for(ERP7__Stock_Outward_Line_Item__c soli : Allpplis){
            CommittedStockWrap csw = new CommittedStockWrap();
            csw.soli = soli;
            cswList.add(csw);
        }
        system.debug('cswList~>'+cswList.size());
        return cswList;
    }

      @AuraEnabled
    public  static comWrap redirect2NextTab(String LogisticIds){
        system.debug('redirect2NextTab called');
        
        String MRPFields = ERP7.UtilClass.selectStarFromSObject('ERP7__MRP__c');
       
        String PPLIFields = ERP7.UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
        ERP7.utilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');           
             
        String warehouseFields = ERP7.UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');       
        ERP7.utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c');          
       
        String logFields = ERP7.UtilClass.selectStarFromSObject('ERP7__Logistic__c');
        ERP7.utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');    
        String logLineFields = ERP7.UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
        ERP7.utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
        logLineFields += ', ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c, ERP7__Order_Product__r.OrderId ,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c, ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
            +'ERP7__Logistic__r.ERP7__Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.ERP7__Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c';
        
        
        List<String> soIdss = (List<String>) JSON.deserialize(LogisticIds, List<String> .class);
        String selectedSite = '';
        Set<Id> OrderIds = new Set<Id>();
        Set<Id> spIds = new Set<Id>();
        comWrap comW = new comWrap();
       
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
        if(FC != null){
            comW.Allowscanning = FC.ERP7__Enable_Scanning_for_Flows__c; comW.displayStockAddress =FC.ERP7__Show_Stock_Address_In_Outbound__c; comW.dontDefaultSnLotPick = FC.ERP7__dontDefaultSnLotPick__c;
            comW.dontallowChannelRemove = FC.ERP7__Restrict_Selected_Channel__c; comW.hideBarcodeLabel = FC.ERP7__Hide_Barcode_in_Pick__c; comW.ShowLangOptionForPickSlip = FC.ERP7__ShowLangOptionForPickSlip__c;
            comW.ReplacePickSlipOrgURL = FC.ERP7__Replace_Pickslip_OrgURL__c;
        }
        
        comW.LogisticRecs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' ,ERP7__Order_S__r.Name, ERP7__Sales_Order__r.Name, ERP7__To_Address__r.ERP7__Address_Line1__c, ERP7__To_Address__r.ERP7__Address_Line2__c, ERP7__To_Address__r.ERP7__Address_Line3__c, ERP7__To_Address__r.ERP7__City__c, ERP7__To_Address__r.ERP7__County__c, '+
                                           +'ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Channel__r.Name, ERP7__Distribution_Channel__r.ERP7__Site__r.Name,  ERP7__To_Address__r.ERP7__Country__c, ERP7__To_Address__r.ERP7__State__c, ERP7__To_Address__r.ERP7__Postal_Code__c, ERP7__Account__r.Name from ERP7__Logistic__c where Id IN :soIdss'); 
        if(comW.LogisticRecs.size() > 0){
            comW.SiteName = comW.LogisticRecs[0].ERP7__Distribution_Channel__r.ERP7__Site__r.Name;
            comW.ChannelName = comW.LogisticRecs[0].ERP7__Channel__r.Name;
            comW.ChannelId = comW.LogisticRecs[0].ERP7__Channel__c;
            comW.selectedSite = comW.LogisticRecs[0].ERP7__Distribution_Channel__r.ERP7__Site__c;
            selectedSite = comW.selectedSite;
        }
        List<Id> soIds = new List<Id>();
        for(ERP7__Logistic__c logistic :comW.LogisticRecs){
            soIds.add(logistic.Id);
            if(logistic.ERP7__Order_S__c != Null) OrderIds.add(logistic.ERP7__Order_S__c);
            if(logistic.ERP7__Sales_Order__c != Null) OrderIds.add(logistic.ERP7__Sales_Order__c);
            if(logistic.ERP7__Purchase_Order__c != Null) OrderIds.add(logistic.ERP7__Purchase_Order__c);
            if(logistic.ERP7__Work_Order__c != Null) OrderIds.add(logistic.ERP7__Work_Order__c);
            if(logistic.ERP7__Transfer_Order__c != Null) OrderIds.add(logistic.ERP7__Transfer_Order__c);
            spIds.add(logistic.ERP7__Channel__c);
        }
        
        
        try {            
            Boolean error = false;
            String customerId = '';
            Boolean showSN = false;
            Boolean showBatch = false;
            String Reserved = 'Reserved';
            String Committed = 'Committed'; // change Shaguftha 09_08_24
            String ReturnedToSupplier = 'Returned to Supplier';
            
            Set<Id> proIds = new Set<Id>();
            Set<Id> assIds = new Set<Id>();
            
            List<Id> SerialIds2Exempt = new List<Id>();
            String selectedOrders = '', barcodeLoc = '', barcodeLocMsg = '';            
            List<ERP7__Location__c> SSLList = new List<ERP7__Location__c>();
            List<Wrappers> soliWrapperList = new List<Wrappers>();
            List<ERP7__StorageContainer__c> binList = new List<ERP7__StorageContainer__c>();
            List<ERP7__Stock_Outward_Line_Item__c> PPLIList2Delete = new List<ERP7__Stock_Outward_Line_Item__c>(); 
            Map<Id, Id> stockMap = new Map<Id, Id>();
            //logistic Ids
            if(soIds.size() > 0) {
                if(!error) { 
                    String errorMsg =  '';
                    Map<Id, Product2> productMap = new Map<Id, Product2>();
                    Map<Id, ERP7__Asset__c> assetMap = new Map<Id, ERP7__Asset__c>();
                    List<ERP7__MRP__c> MRPS = new List<ERP7__MRP__c>();                 
                    Set<Id> WIISIds = new Set<Id>();
                    Set<Id> mrpIds = new Set<Id>();
                    Map<Id, List<ERP7__Stock_Outward_Line_Item__c>> lolisSolis = new Map<Id, List<ERP7__Stock_Outward_Line_Item__c>>();
                    String mrpKit = 'MRP Kit';
                    String TrueValue = 'True'; 
                    
                    List<ERP7__Logistic_Line_Item__c> soliss = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In: soIds and ERP7__RMA_Line_Item__c = Null order by ERP7__Logistic__c ASC'); 
                    // One logistic Order for Multiple SOs
                    
                    //Added by Arshad 18 Sep 2023
                    Set<Id> LOLIsIds = new Set<Id>(); 
                    Set<Id> LOLIsProdsIds = new Set<Id>(); 
                    Set<Id> LOLIsOrdlinesIds = new Set<Id>(); 
                    Set<Id> LOLIsSOlinessIds = new Set<Id>(); 
                    Set<Id> LOLIsPOlinesIds = new Set<Id>(); 
                    Set<Id> LOLIsWOlinesIds = new Set<Id>(); 
                    Set<Id> LOLIsTOlinesIds = new Set<Id>(); 
                    Map<Id,Decimal> batchStocks = new Map<Id,Decimal>(); 
                    Map<String, Map<String, Decimal>> normalStocks = new Map<String, Map<String, Decimal>>();

                    Set<Id> batchStocksIds = new Set<Id>(); 
                    
                    for(ERP7__Logistic_Line_Item__c solis: soliss) {
                        //Added by Arshad 18 Sep 2023
                        LOLIsIds.add(solis.Id); 
                        if(solis.ERP7__Product__c != null) LOLIsProdsIds.add(solis.ERP7__Product__c);
                        if(solis.ERP7__Order_Product__c != null){                            LOLIsOrdlinesIds.add(solis.ERP7__Order_Product__c);                            if(solis.ERP7__Order_Product__r.OrderId != Null) OrderIds.add(solis.ERP7__Order_Product__r.OrderId);                        }
                        if(solis.ERP7__Sales_Order_Line_Item__c != null){
                            LOLIsSOlinessIds.add(solis.ERP7__Sales_Order_Line_Item__c);
                            if(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != Null) OrderIds.add(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c);
                        }
                        if(solis.ERP7__Purchase_Line_Items__c != null){ LOLIsPOlinesIds.add(solis.ERP7__Purchase_Line_Items__c);   if(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != Null) OrderIds.add(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c);
                        }
                        if(solis.ERP7__Work_Order_Line_Items__c != null){                            LOLIsWOlinesIds.add(solis.ERP7__Work_Order_Line_Items__c);                            if(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c != Null) OrderIds.add(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c);                        }
                        if(solis.ERP7__Transfer_Order_Line_Item__c != null){                            LOLIsTOlinesIds.add(solis.ERP7__Transfer_Order_Line_Item__c);                            if(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != Null) OrderIds.add(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c);                        }
                    }
                    
                    system.debug('*** OrderIds : '+OrderIds);
                    Transient List<ERP7__Stock_Outward_Line_Item__c> pplis = new List<ERP7__Stock_Outward_Line_Item__c>();
                    Transient List<ERP7__Stock_Outward_Line_Item__c> Allpplis = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ',ERP7__Logistic_Line_Item__r.ERP7__Quantity__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Picture__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__r.Name,ERP7__Product__r.Name,ERP7__Logistic_Line_Item__r.Name, ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c,ERP7__Logistic_Line_Item__r.ERP7__Packed_Quantity__c,ERP7__Serial__r.Id, ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c,ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c,ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name from ERP7__Stock_Outward_Line_Item__c where (ERP7__Order__c =: OrderIds OR ERP7__Sales_Order__c In: OrderIds Or ERP7__Work_Orders__c In: OrderIds Or ERP7__Purchase_Orders__c In: OrderIds Or ERP7__Transfer_Order__c In: OrderIds) and (ERP7__Status__c  = :Reserved Or ERP7__Status__c =:Committed Or ERP7__Status__c =:ReturnedToSupplier ) and ERP7__Quantity__c > 0 and ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :selectedSite and ERP7__RMA_Line_Item__c = Null ');
                    ERP7__Stock_Outward_Line_Item__c ss = new ERP7__Stock_Outward_Line_Item__c();
                    system.debug('Allpplis : '+Allpplis.size());
                    
                    //Changed by Arshad 18 Sep 2023 - was for loop; changed to while
                    
                    while(Allpplis.size() > 0){
                        ss = Allpplis[0];
                        if(ss.ERP7__Status__c  == 'Reserved'){
                            pplis.add(ss);
                            //Added by Arshad 18 Sep 2023
                            WIISIds.add(ss.ERP7__Site_Product_Service_Inventory_Stock__c);
                            if(ss.ERP7__Product__c != Null) proIds.add(ss.ERP7__Product__c);
                            if(ss.ERP7__Fixed_Asset__c != Null) proIds.add(ss.ERP7__Fixed_Asset__r.ERP7__Product__c);
                            if(ss.ERP7__Fixed_Asset__c != Null) assIds.add(ss.ERP7__Fixed_Asset__c);
                            if(ss.ERP7__MRP_Material_Requirements_Planning__c != Null) mrpIds.add(ss.ERP7__MRP_Material_Requirements_Planning__c);
                            if(ss.ERP7__Product__c != null && LOLIsProdsIds.contains(ss.ERP7__Product__c) && ss.ERP7__Logistic_Line_Item__c != null && LOLIsIds.contains(ss.ERP7__Logistic_Line_Item__c) && ((ss.ERP7__Order_Product__c != Null && LOLIsOrdlinesIds.contains(ss.ERP7__Order_Product__c)) || (ss.ERP7__Sales_Order_Line_Item__c != Null && LOLIsSOlinessIds.contains(ss.ERP7__Sales_Order_Line_Item__c)) || (ss.ERP7__Purchase_Line_Items__c != Null && LOLIsPOlinesIds.contains(ss.ERP7__Purchase_Line_Items__c)) || (ss.ERP7__Work_Order_Line_Items__c != Null && LOLIsWOlinesIds.contains(ss.ERP7__Work_Order_Line_Items__c)) || (ss.ERP7__Transfer_Order_Line_Item__c != Null && LOLIsTOlinesIds.contains(ss.ERP7__Transfer_Order_Line_Item__c)))){
                                if(lolisSolis.ContainsKey(ss.ERP7__Logistic_Line_Item__c)) lolisSolis.get(ss.ERP7__Logistic_Line_Item__c).add(ss);
                                else lolisSolis.put(ss.ERP7__Logistic_Line_Item__c,new List<ERP7__Stock_Outward_Line_Item__c>{ss});
                                
                                Decimal stockOutQuan=0;
                                if(ss.ERP7__Material_Batch_Lot__c != null && !batchStocksIds.contains(ss.ERP7__Material_Batch_Lot__c)){                                   stockOutQuan+=ss.ERP7__Quantity__c+ss.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c;                                    batchStocks.put(ss.ERP7__Material_Batch_Lot__c,stockOutQuan);                                    batchStocksIds.add(ss.ERP7__Material_Batch_Lot__c);                                }
                                // 1st change 26_04_24
                                if(ss.ERP7__Material_Batch_Lot__c == null && ss.ERP7__Serial__c == null){
                                    if(ss.ERP7__Site_Product_Service_Inventory_Stock__c != null){
                                        if(ss.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c != null){                                            String productId = ss.ERP7__Product__c;                                           String location = ss.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c;                                            Decimal quantity = ss.ERP7__Quantity__c;                                             if (!normalStocks.containsKey(productId)) {                                                normalStocks.put(productId, new Map<String, Decimal>());                                            }                                            Map<String, Decimal> locationMap = normalStocks.get(productId);                                            if (locationMap.containsKey(location)) {                                                Decimal normalQty = locationMap.get(location);                                                locationMap.put(location, normalQty + quantity);                                             } else {                                               locationMap.put(location, quantity);                                            }                                             normalStocks.put(productId,locationMap);                                   }
                                        else{
                                            if(ss.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c != null){
                                                String productId = ss.ERP7__Product__c;
                                                String location = ss.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;
                                                Decimal quantity = ss.ERP7__Quantity__c; 
                                                if (!normalStocks.containsKey(productId)) {
                                                    normalStocks.put(productId, new Map<String, Decimal>());
                                                }
                                                Map<String, Decimal> locationMap = normalStocks.get(productId);
                                                if (locationMap.containsKey(location)) {                                                    Decimal normalQty = locationMap.get(location);                                                    locationMap.put(location, normalQty + quantity);                                                } 
                                                else {
                                                    locationMap.put(location, quantity);
                                                } 
                                                normalStocks.put(productId,locationMap);
                                            }
                                        }
                                   
                                }
                                
                            }
                            //
                        }
                        }
                        system.debug('normalStocks : '+normalStocks);
                        //system.debug('ss.ERP7__Status__c : '+ss.ERP7__Status__c);
                        //// change Shaguftha 09_08_24
                        system.debug('LOLIsIds.contains(ss.ERP7__Logistic_Line_Item__c) : '+LOLIsIds.contains(ss.ERP7__Logistic_Line_Item__c));
                        if((ss.ERP7__Status__c == 'Committed' || ss.ERP7__Status__c == 'Returned to Supplier') && ss.ERP7__Logistic_Line_Item__r.ERP7__Packed_Quantity__c != ss.ERP7__Logistic_Line_Item__r.ERP7__Quantity__c && LOLIsIds.contains(ss.ERP7__Logistic_Line_Item__c)){ // && ss.ERP7__Logistic_Line_Item__r.ERP7__Packed_Quantity__c == 0) {
                            //Boolean isbatch = false; Boolean isSerial = false;
                            //if(ss.ERP7__Product__r.ERP7__Lot_Tracked__c && ss.ERP7__Material_Batch_Lot__c != null) isbatch = true;
                            //else if(ss.ERP7__Product__r.ERP7__Serialise__c && ss.ERP7__Serial__c != null) isSerial = true;
                            //comW.commitedSOLI.add(new CommittedStockWrap(ss,false,false));
                            comW.commitedSOLIIdsList.add(ss.Id);
                        }
                        Allpplis.remove(0);
                    }
                    
                    //Added by Arshad 18 Sep 2023
                    system.debug('commitedSOLIIdsList : '+comW.commitedSOLIIdsList.size());
                    system.debug('pplis : '+pplis.size());
                    Allpplis = new List<ERP7__Stock_Outward_Line_Item__c>();
                    system.debug('Allpplis 2: '+Allpplis.size());
                    
                    
                    system.debug('proIds : '+proIds);
                    MRPS = Database.query('select ' + String.escapeSingleQuotes(MRPFields) + ' ,ERP7__Order_Product__r.OrderId, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ERP7__Picture__c, ERP7__MRP_Product__r.ERP7__Preview_Image__c, RecordType.Name, ERP7__MRP_Product__r.ERP7__Item_Description__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Serialise__c from ERP7__MRP__c where ((ERP7__Order_Product__r.OrderId IN: OrderIds OR ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c In :OrderIds Or ERP7__Purchase_Order__c In :OrderIds Or ERP7__Work_Order__c In :OrderIds Or ERP7__Transfer_Order__c In :OrderIds) And ERP7__Status__c  = :Reserved And RecordType.Name = :mrpKit And Id In: mrpIds)');
                    system.debug('MRPS : '+MRPS.size());
                   System.debug('Limits.getCpuTime 1- '+ Limits.getCpuTime());
                    System.debug('Limits.getLimitCpuTime 1- '+ Limits.getLimitCpuTime());
                    System.debug('Limits.getHeapSize 1- '+ Limits.getHeapSize());
                    System.debug('Limits.getLimitHeapSize 1- '+ Limits.getLimitHeapSize());
                    
                    
                    //Added by Arshad 18 Sep 2023
                    system.debug('lolisSolis : '+lolisSolis.keyset());
                    //for(Id i: lolisSolis.keyset()){
                    //    system.debug('key~>'+i+' value size~>'+lolisSolis.get(i).size());
                    //}
                    
                    productMap = new Map<Id, Product2>([Select Id, Name, ProductCode, ERP7__Picture__c, ERP7__Preview_Image__c, ERP7__Item_Description__c, ERP7__Lot_Tracked__c, ERP7__Special_Instructions__c, ERP7__Weight__c, ERP7__Barcode__c From Product2 Where Id In: proIds]); //Serialise__c
                    assetMap = new Map<Id, ERP7__Asset__c>([Select Id, Name, ERP7__Picture__c, ERP7__Preview_Image__c, ERP7__Status__c, ERP7__Item_Description__c, ERP7__Special_Instructions__c, ERP7__Weight__c, ERP7__Barcode__c, ERP7__Serialise__c From ERP7__Asset__c Where Id In: assIds]); //Serialise__c
                    system.debug('productMap : '+productMap.size());
                    Transient List<ERP7__Inventory_Stock__c> WIISLists = new List<ERP7__Inventory_Stock__c>();
                    WIISLists = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ', ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Warehouse__r.Name, ERP7__Location__r.Name, ERP7__StorageContainer__r.Name, ERP7__Warehouse__r.ERP7__Barcode__c, ERP7__Location__r.ERP7__Barcode__c, '+
                                               +' ERP7__StorageContainer__r.ERP7__Barcode__c from ERP7__Inventory_Stock__c where ERP7__Warehouse__c =: selectedSite And ((ERP7__Product__c In: proIds And ((ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 and Name = \'Serial Stock Holder\')) Or Id In :WIISIds)) Or ERP7__Fixed_Asset__r.ERP7__Product__c In: proIds ) Order By ERP7__Product__c ASC'); 
                    
                    system.debug('proIds~>'+proIds.size()+' and assIds~>'+assIds.size());
                    
                     System.debug('Limits.getCpuTime 2- '+ Limits.getCpuTime());
                    System.debug('Limits.getLimitCpuTime 2- '+ Limits.getLimitCpuTime());
                    System.debug('Limits.getHeapSize 2- '+ Limits.getHeapSize());
                    System.debug('Limits.getLimitHeapSize 2- '+ Limits.getLimitHeapSize());
                    
                    Map<Id,Set<SelectOptions>> WIISoptions3 = new Map<Id, Set<SelectOptions>>();
                    Set<Id> options3Ids = new Set<Id>(); 

                    Map<Id, Set<SelectOptions>> WIISaddress = new Map<Id, Set<SelectOptions>>();
                    set<Id> addressIds = new Set<Id>(); 

                    Map<Id,Set<SelectOptions>> WIISoptions2 = new Map<Id, Set<SelectOptions>>();
                    Set<Id> options2Ids = new Set<Id>(); 

                    Map<Id,Set<SelectOptions>> WIISoptions1 = new Map<Id, Set<SelectOptions>>();
                    Set<Id> options1Ids = new Set<Id>(); 

                    Map<String,Decimal> ProdStockWIIS = new Map<String,Decimal>();
                    Map<Id,ERP7__Inventory_Stock__c> WIISstockMap = new Map<Id,ERP7__Inventory_Stock__c>();
                    Map<Id,set<String>> WIISLocAddress = new Map<Id,set<String>>();
                    set<Id> InventorysIds = new set<Id>();
                    system.debug('WIISLists~>'+WIISLists.size());
                    for(ERP7__Inventory_Stock__c wiis: WIISLists) {
                        InventorysIds.add(wiis.Id);
                        string prodKey = wiis.ERP7__Product__c;
                        if(wiis.ERP7__StorageContainer__c != null) prodKey += '|' + wiis.ERP7__StorageContainer__c;
                        else if(wiis.ERP7__Location__c != null) prodKey += '|' + wiis.ERP7__Location__c;
                        else if(wiis.ERP7__Warehouse__c != null) prodKey += '|' + wiis.ERP7__Warehouse__c;
                        system.debug('prodKey : '+prodKey);
                        if(wiis.ERP7__Product__c != null && WIISstockMap.containsKey(wiis.ERP7__Product__c)) WIISstockMap.put(wiis.ERP7__Product__c, wiis); // 26_04_24 removed and added ! for WIISstockMap condition to add only first inventory record 
                        if(wiis.ERP7__StorageContainer__c != null) {
                            if(!WIISoptions3.containsKey(wiis.ERP7__Product__c))  options3Ids.remove(wiis.ERP7__StorageContainer__c);
                            if(wiis.ERP7__StorageContainer__r.Name != null && !options3Ids.contains(wiis.ERP7__StorageContainer__c)){
                                if(WIISoptions3.containsKey(wiis.ERP7__Product__c)) WIISoptions3.get(wiis.ERP7__Product__c).add(new SelectOptions(wiis.ERP7__StorageContainer__c, wiis.ERP7__StorageContainer__r.Name));
                                else WIISoptions3.put(wiis.ERP7__Product__c,new set<SelectOptions>{new SelectOptions(wiis.ERP7__StorageContainer__c, wiis.ERP7__StorageContainer__r.Name)});
                            }
                            options3Ids.add(wiis.ERP7__StorageContainer__c);
                            if(wiis.ERP7__StorageContainer__r.ERP7__Barcode__c != null) {
                                if(!WIISaddress.containsKey(wiis.ERP7__Product__c))  addressIds.remove(wiis.ERP7__Warehouse__c);
                                Set<String> productAddress = WIISLocAddress.containsKey(wiis.ERP7__Product__c) ? WIISLocAddress.get(wiis.ERP7__Product__c) : new set<String>();
                                if(!productAddress.contains(wiis.ERP7__StorageContainer__c)){
                                    if(WIISaddress.containsKey(wiis.ERP7__Product__c)) WIISaddress.get(wiis.ERP7__Product__c).add(new SelectOptions(wiis.ERP7__StorageContainer__c, wiis.ERP7__StorageContainer__r.ERP7__Barcode__c));
                                    else WIISaddress.put(wiis.ERP7__Product__c,new set<SelectOptions>{new SelectOptions(wiis.ERP7__StorageContainer__c, wiis.ERP7__StorageContainer__r.ERP7__Barcode__c)});
                                    if(WIISLocAddress.containsKey(wiis.ERP7__Product__c)) WIISLocAddress.get(wiis.ERP7__Product__c).add(wiis.ERP7__StorageContainer__c);
                                    else WIISLocAddress.put(wiis.ERP7__Product__c,new set<String>{wiis.ERP7__StorageContainer__c});
                                }
                                addressIds.add(wiis.ERP7__StorageContainer__c);
                                if(ProdStockWIIS.containsKey(prodKey)) {                                  Decimal myStock = ProdStockWIIS.get(prodKey) + WIIS.ERP7__Number_of_Item_In_Stock__c;                                    ProdStockWIIS.put(prodKey,myStock);                                } 
                                else ProdStockWIIS.put(prodKey,WIIS.ERP7__Number_of_Item_In_Stock__c);
                            }
                        }
                        else if(wiis.ERP7__Location__c != null) {
                             if(!WIISoptions2.containsKey(wiis.ERP7__Product__c))  options2Ids.remove(wiis.ERP7__Warehouse__c);
                            system.debug('wiis.ERP7__Location__r.Name : '+wiis.ERP7__Location__r.Name);
                            if(wiis.ERP7__Location__r.Name != null && !options2Ids.contains(wiis.ERP7__Location__c)){
                                if(WIISoptions2.containsKey(wiis.ERP7__Product__c)) WIISoptions2.get(wiis.ERP7__Product__c).add(new SelectOptions(wiis.ERP7__Location__c, wiis.ERP7__Location__r.Name));
                                else WIISoptions2.put(wiis.ERP7__Product__c,new set<SelectOptions>{new SelectOptions(wiis.ERP7__Location__c, wiis.ERP7__Location__r.Name)});
                            }
                            options2Ids.add(wiis.ERP7__Location__c);
                            system.debug('wiis.ERP7__Location__r.ERP7__Barcode__c : '+wiis.ERP7__Location__r.ERP7__Barcode__c);
                            if(wiis.ERP7__Location__r.ERP7__Barcode__c != null) {
                                if(!WIISaddress.containsKey(wiis.ERP7__Product__c))  addressIds.remove(wiis.ERP7__Location__c);
                                Set<String> productAddress = WIISLocAddress.containsKey(wiis.ERP7__Product__c) ? WIISLocAddress.get(wiis.ERP7__Product__c) : new set<String>();
                                if(!productAddress.contains(wiis.ERP7__Location__c)){
                                    if(WIISaddress.containsKey(wiis.ERP7__Product__c)) WIISaddress.get(wiis.ERP7__Product__c).add(new SelectOptions(wiis.ERP7__Location__c, wiis.ERP7__Location__r.ERP7__Barcode__c));
                                    else WIISaddress.put(wiis.ERP7__Product__c,new set<SelectOptions>{new SelectOptions(wiis.ERP7__Location__c, wiis.ERP7__Location__r.ERP7__Barcode__c)});
                                    if(WIISLocAddress.containsKey(wiis.ERP7__Product__c)) WIISLocAddress.get(wiis.ERP7__Product__c).add(wiis.ERP7__Location__c);
                                    else WIISLocAddress.put(wiis.ERP7__Product__c,new set<String>{wiis.ERP7__Location__c});
                                }
                                addressIds.add(wiis.ERP7__Location__c);
                                if(ProdStockWIIS.containsKey(prodKey)) {                                    Decimal myStock = ProdStockWIIS.get(prodKey) + WIIS.ERP7__Number_of_Item_In_Stock__c;                                    ProdStockWIIS.put(prodKey,myStock);                                } 
                                else ProdStockWIIS.put(prodKey,WIIS.ERP7__Number_of_Item_In_Stock__c);
                            }
                        }
                        else if(wiis.ERP7__Warehouse__c != null) {
                            if(wiis.Name != 'Serial Stock Holder'){
                                if(!WIISoptions1.containsKey(wiis.ERP7__Product__c))  options1Ids.remove(wiis.ERP7__Warehouse__c);
                                if(wiis.ERP7__Warehouse__r.Name != null && !options1Ids.contains(wiis.ERP7__Warehouse__c)) {
                                    if(WIISoptions1.containsKey(wiis.ERP7__Product__c)) WIISoptions1.get(wiis.ERP7__Product__c).add(new SelectOptions(wiis.ERP7__Warehouse__c, wiis.ERP7__Warehouse__r.Name));
                                    else WIISoptions1.put(wiis.ERP7__Product__c,new set<SelectOptions>{new SelectOptions(wiis.ERP7__Warehouse__c, wiis.ERP7__Warehouse__r.Name)});
                                }
                                options1Ids.add(wiis.ERP7__Warehouse__c);
                            }
                            if(wiis.ERP7__Warehouse__r.ERP7__Barcode__c != null) {
                                if(wiis.Name != 'Serial Stock Holder'){
                                    if(!WIISaddress.containsKey(wiis.ERP7__Product__c))  addressIds.remove(wiis.ERP7__Warehouse__c);
                                     Set<String> productAddress = WIISLocAddress.containsKey(wiis.ERP7__Product__c) ? WIISLocAddress.get(wiis.ERP7__Product__c) : new set<String>();
                                    if(!productAddress.contains(wiis.ERP7__Warehouse__c) ){
                                        if(WIISaddress.containsKey(wiis.ERP7__Product__c)) WIISaddress.get(wiis.ERP7__Product__c).add(new SelectOptions(wiis.ERP7__Warehouse__c, wiis.ERP7__Warehouse__r.ERP7__Barcode__c));
                                        else WIISaddress.put(wiis.ERP7__Product__c,new set<SelectOptions>{new SelectOptions(wiis.ERP7__Warehouse__c, wiis.ERP7__Warehouse__r.ERP7__Barcode__c)});
                                        if(WIISLocAddress.containsKey(wiis.ERP7__Product__c)) WIISLocAddress.get(wiis.ERP7__Product__c).add(wiis.ERP7__Warehouse__c);
                                        else WIISLocAddress.put(wiis.ERP7__Product__c,new set<String>{wiis.ERP7__Warehouse__c});
                                    }
                                    addressIds.add(wiis.ERP7__Warehouse__c);
                                    if(ProdStockWIIS.containsKey(prodKey)) {                                        Decimal myStock = ProdStockWIIS.get(prodKey) + WIIS.ERP7__Number_of_Item_In_Stock__c;                                        ProdStockWIIS.put(prodKey,myStock);                                   } 
                                    else ProdStockWIIS.put(prodKey,WIIS.ERP7__Number_of_Item_In_Stock__c);
                                }
                            }       
                        }
                    }
                    system.debug('ProdStockWIIS : '+ProdStockWIIS);
                    WIISLists = new List<ERP7__Inventory_Stock__c>(); 
                    System.debug('Limits.getCpuTime 3- '+ Limits.getCpuTime());
                    System.debug('Limits.getLimitCpuTime 3- '+ Limits.getLimitCpuTime());
                    System.debug('Limits.getHeapSize 3- '+ Limits.getHeapSize());
                    System.debug('Limits.getLimitHeapSize 3- '+ Limits.getLimitHeapSize());
                    
                    Transient List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = new List<ERP7__Stock_Inward_Line_Item__c>();
                    StockInwardLineItems = [Select Id, Name, ERP7__Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Serial__c, ERP7__Serial__r.ERP7__Available__c,ERP7__Serial__r.ERP7__Material_Batch_Lot__c,
                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Material_Batch_Lot__r.ERP7__Production_Version__c
                                            From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: InventorysIds And
                                            (ERP7__Product__c In :proIds Or ERP7__Fixed_Asset__c In: assIds) And ERP7__Active__c = True  Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                    
                    system.debug('StockInwardLineItems~>'+StockInwardLineItems.size()+' and MRPS~>'+MRPS.size());
                    
                    Decimal myStock = 0;
                    Set<Id> warehouseIds = new Set<Id>();
                    Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();  
                    Map<Id,Id> bin2exclude = new Map<Id,Id>();
                    Map<Id,Id> loc2exclude = new Map<Id,Id>();
                    Map<Id,Id> batchVersion = new Map<Id,Id>();
                    Map<Id,List<ERP7__Inventory_Stock__c>> productStocks = new Map<Id,List<ERP7__Inventory_Stock__c>>();
                    Map<String,Set<SelectOptions>> stockBatches = new Map<String,Set<SelectOptions>>();
                    Map<Id,Set<Id>> stockSerials = new Map<Id,Set<Id>>();
                    Map<Id,Set<Id>> serialBatchmap = new Map<Id,Set<Id>>();
                    
                    //Changed by Arshad 18 Sep 2023 - was for loop; changed to while
                    ERP7__Stock_Inward_Line_Item__c InwardLine = new ERP7__Stock_Inward_Line_Item__c();
                    while(StockInwardLineItems.size() > 0){
                        InwardLine = StockInwardLineItems[0];
                        if(InwardLine.ERP7__Material_Batch_Lot__c != Null ){/*'inside when batch not null'*/ //&& InwardLine.ERP7__Serial__c == Null
                            if(InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Production_Version__c != null){/*'inside when production version not null'*/ batchVersion.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Production_Version__c);}
                            //Here it's taking all stock from a batches     batchId:batchStock
                            batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                            if(!stockBatches.containsKey(InwardLine.ERP7__Product__c)) { 
                                Set<SelectOptions> myBatches = new Set<SelectOptions>();
                                if(!InwardLine.ERP7__Product__r.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOptions('','--None--'));
                                myBatches.add(new SelectOptions(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                stockBatches.put(InwardLine.ERP7__Product__c, myBatches);   } else{                                Set<SelectOptions> myBatches = stockBatches.get(InwardLine.ERP7__Product__c);                                Boolean found = false;                                for(SelectOptions SO : myBatches){                                    if(SO.Value == String.valueof(InwardLine.ERP7__Material_Batch_Lot__c)) { found = true; break; }                                }                                if(!found){                                    myBatches.add(new SelectOptions(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));                                    stockBatches.put(InwardLine.ERP7__Product__c, myBatches);                                }
                                system.debug('stockBatches : '+stockBatches);
                            }
                        }
                        else if(InwardLine.ERP7__Serial__c != Null){
                            if(InwardLine.ERP7__Serial__r.ERP7__Available__c){
                                if(!stockSerials.containsKey(InwardLine.ERP7__Product__c)) { 
                                    Set<Id> mySerials = new Set<Id>();
                                    mySerials.add(InwardLine.ERP7__Serial__c);
                                    stockSerials.put(InwardLine.ERP7__Product__c,mySerials);   } else{                                   Set<Id> mySerials = stockSerials.get(InwardLine.ERP7__Product__c);                                    mySerials.add(InwardLine.ERP7__Serial__c);                                    stockSerials.put(InwardLine.ERP7__Product__c,mySerials);                                }
                                if(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c != null){                                   if(!serialBatchmap.containsKey(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c)){                                        Set<Id> serialnos = new Set<Id>();                                        serialnos.add(InwardLine.ERP7__Serial__c);                                       serialBatchmap.put(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c,serialnos);                                    }else{                                       Set<Id> serialnos = serialBatchmap.get(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c);                                        serialnos.add(InwardLine.ERP7__Serial__c);                                        serialBatchmap.put(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c,serialnos);                                    }                                }
                            }
                        } 
                        if(InwardLine.ERP7__Serial__c != Null) SerialIds2Exempt.add(InwardLine.ERP7__Serial__c);
                        StockInwardLineItems.remove(0);
                    }
                    
                    StockInwardLineItems = new List<ERP7__Stock_Inward_Line_Item__c>();
                    system.debug('StockInwardLineItems2 size~>'+StockInwardLineItems.size());
                    
                    system.debug('stockSerials : '+stockSerials);
                    
                    Map<Id, List<ERP7__MRP__c>> soliMRPS = new Map<Id, List<ERP7__MRP__c>>();
                    
                    if(MRPS.size() > 0){
                        for(ERP7__Logistic_Line_Item__c solis : soliss) {
                            Set<ERP7__MRP__c> myMRPS = new Set<ERP7__MRP__c>();
                            for(ERP7__MRP__c mrp : MRPS) {
                                if((solis.ERP7__Order_Product__c != Null && mrp.ERP7__Order_Product__c == solis.ERP7__Order_Product__c) || (solis.ERP7__Sales_Order_Line_Item__c != Null && mrp.ERP7__Sales_Order_Line_Item__c == solis.ERP7__Sales_Order_Line_Item__c) || (solis.ERP7__Purchase_Line_Items__c != Null && mrp.ERP7__Purchase_Line_Items__c == solis.ERP7__Purchase_Line_Items__c) || (solis.ERP7__Work_Order_Line_Items__c != Null && mrp.ERP7__Work_Order_Line_Items__c == solis.ERP7__Work_Order_Line_Items__c) || (solis.ERP7__Transfer_Order_Line_Item__c != Null && mrp.ERP7__Transfer_Order_Line_Item__c == solis.ERP7__Transfer_Order_Line_Item__c)){
                                    myMRPS.add(mrp);
                                }
                            }
                            List<ERP7__MRP__c> myMRPSNew = new List<ERP7__MRP__c>();
                            myMRPSNew.addAll(myMRPS);
                            soliMRPS.put(solis.Id,myMRPSNew);
                        }
                    }
                    
                    
                    System.debug('Limits.getCpuTime 4- '+ Limits.getCpuTime());
                    System.debug('Limits.getLimitCpuTime 4- '+ Limits.getLimitCpuTime());
                    System.debug('Limits.getHeapSize 4- '+ Limits.getHeapSize());
                    System.debug('Limits.getLimitHeapSize 4- '+ Limits.getLimitHeapSize());
                    
                    for(ERP7__Logistic_Line_Item__c solis : soliss) {
                        Wrappers swrap_IN = new Wrappers();
                        swrap_IN.Product = null; 
                        if(solis.ERP7__Quantity__c > 0 && ((solis.ERP7__Picked_Quantity__c == 0 || solis.ERP7__Picked_Quantity__c == Null) || solis.ERP7__Quantity__c > solis.ERP7__Picked_Quantity__c) && lolisSolis.containsKey(solis.Id)){ // added solis.ERP7__Picked_Quantity__c == 0
                            Boolean runOnceForSerialise = true;
                            for(ERP7__Stock_Outward_Line_Item__c sli : lolisSolis.get(solis.Id)){ 
                                system.debug('lolisSolis : '+lolisSolis.get(solis.Id).size());
                                system.debug('val : '+(solis.ERP7__Product__r.ERP7__Is_Kit__c && solis.ERP7__Explode__c));
                                if((!solis.ERP7__Product__r.ERP7__Is_Kit__c && !solis.ERP7__Explode__c)){
                                    system.debug('if executed : prodduct : '+sli.ERP7__Product__c);
                                    Wrappers swrap = new Wrappers();        if(sli.ERP7__Product__c != Null) swrap.Product = productMap.get(sli.ERP7__Product__c);
                                    if(sli.ERP7__Fixed_Asset__c != Null) swrap.Asset = assetMap.get(sli.ERP7__Fixed_Asset__c);   swrap.loli = solis;                                    myStock = 0;
                                    system.debug('swrap.LOLI.Picked_Quantity__c  : '+swrap.LOLI.ERP7__Picked_Quantity__c );
                                    if(swrap.LOLI.ERP7__Picked_Quantity__c != null) { if(swrap.loli.ERP7__Picked_Quantity__c == swrap.loli.ERP7__Quantity__c) {swrap.raisedQty = double.valueof(swrap.loli.ERP7__Picked_Quantity__c);              swrap.remainingQty = double.valueof(swrap.loli.ERP7__Quantity__c - swrap.raisedQty);   } else if(swrap.loli.ERP7__Picked_Quantity__c < swrap.loli.ERP7__Quantity__c) {  swrap.raisedQty = double.valueof(swrap.loli.ERP7__Picked_Quantity__c);                       swrap.remainingQty = double.valueof(swrap.loli.ERP7__Quantity__c - swrap.raisedQty);                        swrap.requiredQty = (swrap.remainingQty > 0)? 1 : 0;
                                        }
                                    } 
                                    else { 
                                        system.debug('swrap.loli.ERP7__Quantity__c : '+swrap.loli.ERP7__Quantity__c);
                                        swrap.requiredQty = (Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.Fields.ERP7__Quantity__c.isAccessible()) ? double.valueof(swrap.loli.ERP7__Quantity__c) : 0;
                                        swrap.remainingQty = (Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.Fields.ERP7__Quantity__c.isAccessible()) ? double.valueof(swrap.loli.ERP7__Quantity__c) : 0; 
                                    }
                                    
                                    Set<SelectOptions> options1 = new Set <SelectOptions>();        Set<SelectOptions> options2 = new Set <SelectOptions>();           Set<SelectOptions> options3 = new Set <SelectOptions>();                                     Set<SelectOptions> address = new Set <SelectOptions>();
                                   // Set<Id> addressIds = new Set<Id>(); 
                                   // Set<Id> options1Ids = new Set<Id>(); 
                                  //  Set<Id> options2Ids = new Set<Id>(); 
                                  //  Set<Id> options3Ids = new Set<Id>(); 
                                   /* if(runOnceForSerialise){
                                        system.debug('inhere runOnceForSerialise once');
                                        if(swrap.loli.ERP7__Product__r.ERP7__Serialise__c) runOnceForSerialise = false;
                                        
                                    }*/
                                    system.debug('WIISaddress.containsKey(solis.ERP7__Product__c) : '+WIISaddress.containsKey(solis.ERP7__Product__c));
                                    if(WIISaddress.containsKey(solis.ERP7__Product__c))  swrap.address.addAll(WIISaddress.get(solis.ERP7__Product__c));if(WIISoptions1.containsKey(solis.ERP7__Product__c)) swrap.CurrentWarehouses.addAll(WIISoptions1.get(solis.ERP7__Product__c)); 
                                    if(WIISoptions2.containsKey(solis.ERP7__Product__c)) swrap.CurrentLocations.addAll(WIISoptions2.get(solis.ERP7__Product__c));      if(WIISoptions3.containsKey(solis.ERP7__Product__c)) swrap.CurrentBins.addAll(WIISoptions3.get(solis.ERP7__Product__c)); 
                                    system.debug('WIISstockMap.containsKey(solis.ERP7__Product__c) : '+WIISstockMap.containsKey(solis.ERP7__Product__c));
                                    if(WIISstockMap.containsKey(solis.ERP7__Product__c)){
                                        system.debug('WIISstockMap.get(solis.ERP7__Product__c).ERP7__Location__c : '+WIISstockMap.get(solis.ERP7__Product__c).ERP7__Location__c);
                                        if(WIISstockMap.get(solis.ERP7__Product__c).ERP7__StorageContainer__c != null) swrap.binName = swrap.AddressName = WIISstockMap.get(solis.ERP7__Product__c).ERP7__StorageContainer__r.Name; else if(WIISstockMap.get(solis.ERP7__Product__c).ERP7__Location__c != null){
                                            if(sli.ERP7__Site_Product_Service_Inventory_Stock__c == WIISstockMap.get(solis.ERP7__Product__c).Id && sli.ERP7__Logistic_Line_Item__c == solis.Id){ // 2nd change 26_04_24
                                                swrap.LN = WIISstockMap.get(solis.ERP7__Product__c).ERP7__Location__r.Name; swrap.LocationName = swrap.AddressName  = WIISstockMap.get(solis.ERP7__Product__c).ERP7__Location__c;
                                                system.debug('un 1 ii');
                                            }
                                            else { swrap.LN = WIISstockMap.get(solis.ERP7__Product__c).ERP7__Location__r.Name; swrap.LocationName = swrap.AddressName  = WIISstockMap.get(solis.ERP7__Product__c).ERP7__Location__c; }
                                        }
                                        else if(WIISstockMap.get(solis.ERP7__Product__c).ERP7__Warehouse__c != null){                                            swrap.WN = WIISstockMap.get(solis.ERP7__Product__c).ERP7__Warehouse__r.Name;
                                            swrap.WarehouseName = swrap.AddressName = WIISstockMap.get(solis.ERP7__Product__c).ERP7__Warehouse__c;
                                        }
                                        stockMap.put(solis.ERP7__Product__c,WIISstockMap.get(solis.ERP7__Product__c).Id);
                                    }
                                    if(swrap.address.size() > 0){                                        String prodKey = solis.ERP7__Product__c + '|' + swrap.address[0].value;
                                        system.debug('prodKey : '+prodKey);
                                        if(ProdStockWIIS.containsKey(prodKey)) {                                            myStock = ProdStockWIIS.get(prodKey);
                                            system.debug('myStock 11: '+myStock);
                                            system.debug('swrap.AddressName : '+swrap.address[0].value);
                                            if(!solis.ERP7__Product__r.ERP7__Lot_Tracked__c && !solis.ERP7__Product__r.ERP7__Serialise__c && normalStocks.containsKey(solis.ERP7__Product__c) && myStock != 0){ // 3rd change 26_04_24
                                                Map<string,Decimal> normal = new Map<String,Decimal>();                                                normal = normalStocks.get(solis.ERP7__Product__c);
                                                if(normal.containsKey(swrap.address[0].value)) myStock += normal.get(swrap.address[0].value);
                                                system.debug('myStock after: '+myStock);
                                            }
                                        }
                                    }
                                    //Changes started here from imran for polymem fix
                                    if(swrap.binName != null){                                        swrap.AddressName = swrap.binName;
                                    }
                                    else if(swrap.LocationName != null){                                        swrap.AddressName = swrap.LocationName;
                                    }
                                    //Changes ended here imran
                                    system.debug('myStock 222: '+myStock);
                                    system.debug('swrap.loli.Quantity__c 222: '+swrap.loli.ERP7__Quantity__c);
                                    system.debug('swrap.raisedQty 222: '+swrap.raisedQty);
                                    if((swrap.loli.ERP7__Status__c == 'Reserved' || swrap.loli.ERP7__Status__c == 'Requested') && myStock == 0) swrap.inventoryStock = swrap.loli.ERP7__Quantity__c - swrap.raisedQty; // added on 04-12-23
                                    //else if((swrap.loli.ERP7__Status__c == 'Reserved' || swrap.loli.ERP7__Status__c == 'Requested') && myStock > 0) swrap.inventoryStock = myStock + swrap.loli.ERP7__Quantity__c - swrap.raisedQty;  // commented on 04-12-23
                                    else swrap.inventoryStock = myStock; 
                                    
                                    // First AddressName and it's stock only .......
                                    swrap.BatchLotCodes = new List <SelectOptions>();  if(comW.dontDefaultSnLotPick){ swrap.BatchLotCodes.add(new SelectOptions('','--None--'));  }
                                    //system.debug('solis.ERP7__Production_Version__c : '+solis.ERP7__Production_Version__c);
                                    //system.debug('stockBatches.ContainsKey(solis.Product__c) : '+stockBatches.ContainsKey(solis.Product__c));
                                    if(solis.ERP7__Production_Version__c != Null && stockBatches.ContainsKey(solis.ERP7__Product__c)){
                                        //system.debug('in if');
                                        List <SelectOptions> stkBatches = new List <SelectOptions>(); stkBatches.addAll(stockBatches.get(solis.ERP7__Product__c));
                                        //system.debug('stkBatches : '+stkBatches.size());
                                        for(SelectOptions SO : stockBatches.get(solis.ERP7__Product__c)){  if(SO.Value != null && SO.Value != ''){
                                                //system.debug('batchVersion.ContainsKey(SO.Value) : '+batchVersion.ContainsKey(SO.Value));
                                                //system.debug('batchVersion.get(SO.Value): '+batchVersion.get(SO.Value));
                                                if(batchVersion.ContainsKey(SO.Value) && batchVersion.get(SO.Value) == solis.ERP7__Production_Version__c)                                                     swrap.BatchLotCodes.add(SO);
                                            }
                                        }
                                    }
                                    else if(stockBatches.ContainsKey(solis.ERP7__Product__c)) { system.debug('else in no versions'); swrap.BatchLotCodes.addAll(stockBatches.get(solis.ERP7__Product__c)); }
                                    //system.debug('swrap.BatchLotCodes.size() : '+swrap.BatchLotCodes.size());
                                    //system.debug('solis.ERP7__Product__r.ERP7__Lot_Tracked__c : '+solis.ERP7__Product__r.ERP7__Lot_Tracked__c);
                                    if(swrap.BatchLotCodes.size() > 0 && solis.ERP7__Product__r.ERP7__Lot_Tracked__c == true){ if(!comW.dontDefaultSnLotPick){                                            swrap.BatchLotCode = swrap.BatchLotCodes[0].Value;
                                            //Decimal bStock = (batchAvailStocks.get(swrap.BatchLotCodes[0].Value) != null)? batchAvailStocks.get(swrap.BatchLotCodes[0].Value) : 0;
                                            //if((swrap.loli.Status__c == 'Reserved' || swrap.loli.Status__c == 'Requested') && bStock >= 0) swrap.inventoryStock = bStock+swrap.loli.Quantity__c-swrap.raisedQty; 
                                            //***********New change for batch stock******************
                                            ERP7__Batch__c batch=new ERP7__Batch__c(); 
                                            //system.debug('swrap.BatchLotCode  : '+swrap.BatchLotCode );
                                            //system.debug('batchStocks.get(swrap.BatchLotCodes[0].Value) : '+batchStocks.get(swrap.BatchLotCodes[0].Value));
                                            if(batchStocks.get(swrap.BatchLotCodes[0].Value) == null) batch=[Select Id,Name,ERP7__Available_Quantity__c from ERP7__Batch__c where Id =:swrap.BatchLotCode Limit 1];
                                            Decimal bStock = (batchStocks.get(swrap.BatchLotCodes[0].Value) != null)? batchStocks.get(swrap.BatchLotCodes[0].Value) : batch.ERP7__Available_Quantity__c;
                                            //Imran need to verify this
                                            if((swrap.loli.ERP7__Status__c == 'Reserved' || swrap.loli.ERP7__Status__c == 'Requested') && bStock >= 0) swrap.inventoryStock = bStock;     }else swrap.BatchLotCode = ''; 
                                        system.debug('swrap.inventoryStock batch: '+swrap.inventoryStock);
                                    }else swrap.BatchLotCode = ''; 
                                    
                                    if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);
                                    //system.debug('swrap.requiredQty : '+swrap.requiredQty);
                                    Boolean breaknow = false;
                                 if(swrap.raisedQty != swrap.loli.ERP7__Quantity__c){
                                        //system.debug('in here raisedQty ==  QTY');
                                        if(swrap.loli.ERP7__Product__r.ERP7__Serialise__c){
                                            system.debug('in here serialized and dontDefaultSnLotPick~>'+comW.dontDefaultSnLotPick);
                                            if(swrap.requiredQty > 0) swrap.requiredQty = 1;
                                            swrap.serialized = true; showSN = true; swrap.SerialNumbers = sli; breaknow = true;
                                            if(comW.dontDefaultSnLotPick) swrap.SerialNumbers.ERP7__Serial__c = null;
                                            system.debug('stockSerials.ContainsKey(solis.ERP7__Product__c) : '+stockSerials.ContainsKey(solis.ERP7__Product__c));
                                            system.debug('swrap.SerialNumbers.Serial__c bfr~>'+swrap.SerialNumbers.ERP7__Serial__c);
                                            if(stockSerials.ContainsKey(solis.ERP7__Product__c) && stockSerials.get(solis.ERP7__Product__c).size() > 0 && swrap.SerialNumbers.ERP7__Serial__c == Null) {
                                                List<Id> srIds = new List<Id>();
                                                srIds.addAll(stockSerials.get(solis.ERP7__Product__c));
                                                if(!comW.dontDefaultSnLotPick) swrap.SerialNumbers.ERP7__Serial__c = srIds.remove(0);
                                                //system.debug('srIds.remove(0)~>'+srIds.remove(0)); //commented by arshad 31/01/23, throwing error List index out of bounds
                                                
                                                Set<Id> setIds = new Set<Id>(srIds);                                                stockSerials.put(solis.ERP7__Product__c,setIds);
                                            }
                                            system.debug('sli.ERP7__Serial__c : '+sli.ERP7__Serial__c);
                                            //if(swrap.SerialNumbers.Serial__c == null) swrap.SerialNumbers.Serial__c = sli.ERP7__Serial__c;
                                            system.debug('swrap.SerialNumbers.Serial__c~>'+swrap.SerialNumbers.ERP7__Serial__c);
                                        } else if(solis.ERP7__Quantity__c == swrap.loli.ERP7__Quantity__c) breaknow = true;
                                        if(swrap.BatchLotCodes.size() > 0 && swrap.loli.ERP7__Product__r.ERP7__Serialise__c == false && swrap.loli.ERP7__Product__r.ERP7__Lot_Tracked__c) showBatch = true;
                                        soliWrapperList.add(swrap);
                                        if(breaknow) break;
                                    }
                                } 
                               else {
                                    system.debug('else mrp executed');
                                    
                                    for(ERP7__MRP__c mrp : soliMRPS.get(solis.Id)){
                                        
                                        system.debug('1');
                                        system.debug('sli.ERP7__Product__c : '+sli.ERP7__Product__c);
                                        system.debug('mrp.ERP7__MRP_Product__c : '+mrp.ERP7__MRP_Product__c);
                                        if(sli.ERP7__MRP_Material_Requirements_Planning__c == mrp.Id && sli.ERP7__Product__c == mrp.ERP7__MRP_Product__c){
                                            system.debug('condition else true');
                                            
                                            swrap_IN.Product = productMap.get(mrp.ERP7__MRP_Product__c);                                            swrap_IN.loli = solis; swrap_IN.MRP = mrp; myStock = 0;
                                            system.debug('swrap_IN.mrp.Picked_Quantity__c : '+swrap_IN.mrp.ERP7__Picked_Quantity__c);
                                            if(swrap_IN.mrp.ERP7__Picked_Quantity__c != null && swrap_IN.mrp.ERP7__Picked_Quantity__c > 0) {
                                                if(swrap_IN.mrp.ERP7__Picked_Quantity__c == swrap_IN.mrp.ERP7__Total_Amount_Required__c) {
                                                    swrap_IN.raisedQty = double.valueof(swrap_IN.mrp.ERP7__Picked_Quantity__c); swrap_IN.remainingQty = double.valueof(swrap_IN.mrp.ERP7__Total_Amount_Required__c - swrap_IN.raisedQty);
                                                } else if(swrap_IN.mrp.ERP7__Picked_Quantity__c < swrap_IN.mrp.ERP7__Total_Amount_Required__c) {
                                                    swrap_IN.raisedQty = double.valueof(swrap_IN.mrp.ERP7__Picked_Quantity__c); 
                                                    swrap_IN.remainingQty = double.valueof(swrap_IN.mrp.ERP7__Total_Amount_Required__c - swrap_IN.raisedQty);                                      
                                                    //swrap_IN.requiredQty = double.valueof(swrap_IN.mrp.Total_Amount_Required__c - swrap_IN.raisedQty);
                                                    swrap_IN.requiredQty = (swrap_IN.requiredQty > 0)? 1 : 0;
                                                }
                                            }
                                            else {                                              swrap_IN.requiredQty = double.valueof(swrap_IN.mrp.ERP7__Total_Amount_Required__c);                                                 system.debug('swrap_IN.requiredQty : '+swrap_IN.requiredQty);                                                swrap_IN.remainingQty = double.valueof(swrap_IN.mrp.ERP7__Total_Amount_Required__c);                                             }                                            Set<SelectOptions> options1_IN = new Set <SelectOptions>();                                             Set<SelectOptions> options2_IN = new Set <SelectOptions>();                                            Set<SelectOptions> options3_IN = new Set <SelectOptions>();                                            Set<SelectOptions> address_IN = new Set <SelectOptions>(); 
                                           /* for(ERP7__Inventory_Stock__c wiis: WIISLists) {
                                                if(wiis.Product__c == mrp.ERP7__MRP_Product__c) { // && (solis.ERP7__Production_Version__c == Null || solis.ERP7__Production_Version__c == wiis.ERP7__Version__c)
                                                    
                                                    if(wiis.ERP7__StorageContainer__c != null) {
                                                        swrap_IN.binName = swrap_IN.AddressName = wiis.ERP7__StorageContainer__c; 
                                                        if(wiis.ERP7__StorageContainer__r.Name != null) options3_IN.add(new SelectOptions(wiis.ERP7__StorageContainer__c, wiis.ERP7__StorageContainer__r.Name));
                                                        if(wiis.ERP7__StorageContainer__r.Barcode__c != null) { 
                                                            address_IN.add(new SelectOptions(wiis.ERP7__StorageContainer__c, wiis.ERP7__StorageContainer__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                                        }
                                                    } else if(wiis.ERP7__Location__c != null) {
                                                        swrap_IN.LN = wiis.ERP7__Location__r.Name; swrap_IN.LocationName = swrap_IN.AddressName  = wiis.ERP7__Location__c;
                                                        if(wiis.ERP7__Location__r.Name != null) options2_IN.add(new SelectOptions(wiis.ERP7__Location__c, wiis.ERP7__Location__r.Name));
                                                        if(wiis.ERP7__Location__r.Barcode__c != null){
                                                            address_IN.add(new SelectOptions(wiis.ERP7__Location__c, wiis.ERP7__Location__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                                        }
                                                    } else if(wiis.ERP7__Warehouse__c != null) {
                                                        swrap_IN.WN = wiis.Warehouse__r.Name; swrap_IN.WarehouseName = swrap_IN.AddressName = wiis.ERP7__Warehouse__c;
                                                        if(wiis.Warehouse__r.Name != null) options1_IN.add(new SelectOptions(wiis.ERP7__Warehouse__c, wiis.Warehouse__r.Name)); 
                                                        if(wiis.Warehouse__r.Barcode__c != null){
                                                            address_IN.add(new SelectOptions(wiis.ERP7__Warehouse__c, wiis.Warehouse__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                                        }
                                                    }                   
                                                    stockMap.put(wiis.Product__c, wiis.Id);
                                                }
                                            }*/
                                            if(WIISaddress.containsKey(mrp.ERP7__MRP_Product__c))  swrap_IN.address.addAll(WIISaddress.get(mrp.ERP7__MRP_Product__c));
                                            if(WIISoptions1.containsKey(mrp.ERP7__MRP_Product__c)) swrap_IN.CurrentWarehouses.addAll(WIISoptions1.get(mrp.ERP7__MRP_Product__c)); 
                                            if(WIISoptions2.containsKey(mrp.ERP7__MRP_Product__c)) swrap_IN.CurrentLocations.addAll(WIISoptions2.get(mrp.ERP7__MRP_Product__c));    
                                            if(WIISoptions3.containsKey(mrp.ERP7__MRP_Product__c)) swrap_IN.CurrentBins.addAll(WIISoptions3.get(mrp.ERP7__MRP_Product__c)); 
                                            if(WIISstockMap.containsKey(mrp.ERP7__MRP_Product__c)){
                                                if(WIISstockMap.get(mrp.ERP7__MRP_Product__c).ERP7__StorageContainer__c != null) swrap_IN.binName = swrap_IN.AddressName = WIISstockMap.get(mrp.ERP7__MRP_Product__c).ERP7__StorageContainer__r.Name; 
                                                else if(WIISstockMap.get(mrp.ERP7__MRP_Product__c).ERP7__Location__c != null){
                                                    swrap_IN.LN = WIISstockMap.get(mrp.ERP7__MRP_Product__c).ERP7__Location__r.Name; swrap_IN.LocationName = swrap_IN.AddressName  = WIISstockMap.get(mrp.ERP7__MRP_Product__c).ERP7__Location__c;
                                        }
                                        else if(WIISstockMap.get(mrp.ERP7__MRP_Product__c).ERP7__Warehouse__c != null){
                                            swrap_IN.WN = WIISstockMap.get(mrp.ERP7__MRP_Product__c).ERP7__Warehouse__r.Name;
                                            swrap_IN.WarehouseName = swrap_IN.AddressName = WIISstockMap.get(mrp.ERP7__MRP_Product__c).ERP7__Warehouse__c;
                                        }
                                        stockMap.put(mrp.ERP7__MRP_Product__c,WIISstockMap.get(mrp.ERP7__MRP_Product__c).Id);
                                    }
                                    if(ProdStockWIIS.containsKey(mrp.ERP7__MRP_Product__c)) myStock = ProdStockWIIS.get(mrp.ERP7__MRP_Product__c);
                                            
                                            if(swrap_IN.binName != null){                                                swrap_IN.AddressName = swrap_IN.binName;
                                            }
                                            else if(swrap_IN.LocationName != null){                                                swrap_IN.AddressName = swrap_IN.LocationName;
                                            } 
                                            
                                            system.debug('swrap_IN.loli.Status__c : '+swrap_IN.loli.ERP7__Status__c);
                                            system.debug('myStock : '+myStock);
                                            if(swrap_IN.loli.ERP7__Status__c == 'Reserved' && myStock >= 0) swrap_IN.inventoryStock = myStock+swrap_IN.mrp.ERP7__Total_Amount_Required__c-swrap_IN.raisedQty;  
                                            else swrap_IN.inventoryStock = myStock; 
                                            system.debug('swrap_IN.inventoryStock : '+swrap_IN.inventoryStock);
                                            swrap_IN.BatchLotCodes = new List <SelectOptions>();   
                                            if(stockBatches.ContainsKey(mrp.ERP7__MRP_Product__c)) { swrap_IN.BatchLotCodes.addAll(stockBatches.get(mrp.ERP7__MRP_Product__c)); }
                                            system.debug('In else MRP comW.dontDefaultSnLotPick : '+comW.dontDefaultSnLotPick);
                                            if(swrap_IN.BatchLotCodes.size() > 0 && mrp.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true){
                                                if(!comW.dontDefaultSnLotPick){ // added the change on 3/05/2023 to not default batch
                                                    swrap_IN.BatchLotCode = swrap_IN.BatchLotCodes[0].Value; 
                                                    Decimal bStock = (batchAvailStocks.get(swrap_IN.BatchLotCodes[0].Value) != null)? batchAvailStocks.get(swrap_IN.BatchLotCodes[0].Value) : 0;
                                                    if((swrap_IN.loli.ERP7__Status__c == 'Reserved' || swrap_IN.loli.ERP7__Status__c == 'Requested') && bStock >= 0) swrap_IN.inventoryStock = bStock+swrap_IN.loli.ERP7__Quantity__c-swrap_IN.raisedQty; 
                                                    
                                                }else swrap_IN.BatchLotCode = ''; //swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                                            }
                                            else swrap_IN.BatchLotCode = '';
                                            if(swrap_IN.requiredQty >= swrap_IN.inventoryStock) swrap_IN.requiredQty = double.valueof(swrap_IN.inventoryStock); 
                                            if(swrap_IN.raisedQty != swrap_IN.mrp.ERP7__Total_Amount_Required__c){
                                                if(swrap_IN.mrp.ERP7__MRP_Product__r.ERP7__Serialise__c){
                                                    if(swrap_IN.requiredQty > 0) swrap_IN.requiredQty = 1;
                                                    swrap_IN.serialized = true; showSN = true;
                                                    if(stockSerials.ContainsKey(mrp.ERP7__MRP_Product__c) && stockSerials.get(mrp.ERP7__MRP_Product__c).size() > 0 && swrap_IN.SerialNumbers.ERP7__Serial__c == Null){
                                                        List<Id> srIds = new List<Id>();
                                                        srIds.addAll(stockSerials.get(mrp.ERP7__MRP_Product__c));
                                                        if(!comW.dontDefaultSnLotPick) swrap_IN.SerialNumbers.ERP7__Serial__c = srIds.remove(0);
                                                        system.debug('swrap_IN.SerialNumbers.Serial__c~>'+swrap_IN.SerialNumbers.ERP7__Serial__c);
                                                        Set<Id> setIds = new Set<Id>(srIds);
                                                        stockSerials.put(mrp.ERP7__MRP_Product__c,setIds);
                                                    }
                                                } 
                                                if(swrap_IN.BatchLotCodes.size() > 0  && swrap_IN.mrp.ERP7__MRP_Product__r.ERP7__Serialise__c == false && swrap_IN.mrp.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c) showBatch = true;
                                                //swrap.MRPsWrapperList.add(swrap_IN);
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            if(swrap_IN.Product != null) soliWrapperList.add(swrap_IN);
                        }        
                    }
                    
                    
                    
                    system.debug('soliWrapperList : '+soliWrapperList.size());
                    comW.soliWrapperList = soliWrapperList; 
                    comW.barcodeLocMsg = barcodeLocMsg; 
                    comW.showBatch = showBatch; 
                    comW.showSN = showSN; 
                    comW.SerialIds2Exempt = SerialIds2Exempt;
                    comW.stockMap = stockMap;
                    
                    return comW;                 
                }                
            } else comW.exceptionError = 'Please select an order to proceed.';
            
        } catch(Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
        }
        
        return comW;
    }
 
    //commented on 21_11_2023 and added above optimized code
   /* @AuraEnabled
    public static comWrap redirect2NextTab(String LogisticIds){
        system.debug('redirect2NextTab called');
        
        String binFields = UtilClass.selectStarFromSObject('ERP7__StorageContainer__c');
        utilClass.FLSCheck(binFields.split(','),'ERP7__StorageContainer__c');
        String siteFields = UtilClass.selectStarFromSObject('ERP7__Site__c');         
        utilClass.FLSCheck(siteFields.split(','),'ERP7__Site__c');          
        String SOFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order__c');
        utilClass.FLSCheck(SOFields.split(','),'ERP7__Sales_Order__c');
        String OFields = UtilClass.selectStarFromSObject('Order');
        utilClass.FLSCheck(OFields.split(','),'Order');
        String PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
        utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');            
        String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
        utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');          
        String packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
        utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');
        String SOLIFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order_Line_Item__c');
        String MRPFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
        utilClass.FLSCheck(SOLIFields.split(','),'ERP7__Sales_Order_Line_Item__c');
        String OLIFields = UtilClass.selectStarFromSObject('OrderItem');
        utilClass.FLSCheck(OLIFields.split(','),'OrderItem');
        String channelFields = UtilClass.selectStarFromSObject('ERP7__Distribution_Channel__c'); 
        utilClass.FLSCheck(channelFields.split(','),'ERP7__Distribution_Channel__c');
        String locationsFields = UtilClass.selectStarFromSObject('ERP7__Location__c'); 
        utilClass.FLSCheck(locationsFields.split(','),'ERP7__Location__c');
        String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
        utilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');           
        String PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
        utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c');           
        String warehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');       
        utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c');          
        String prodFields = UtilClass.selectStarFromSObject('Product2');
        utilClass.FLSCheck(prodFields.split(','),'Product2'); 
        
        String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
        utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');    
        String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
        utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
        logLineFields += ', ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c, ERP7__Order_Product__r.OrderId ,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c, ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
            +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c';
        
        
        List<String> soIdss = (List<String>) JSON.deserialize(LogisticIds, List<String> .class);
        String selectedSite = '';
        Set<Id> OrderIds = new Set<Id>();
        Set<Id> spIds = new Set<Id>();
        comWrap comW = new comWrap();
        List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
        empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                   ERP7__Organisation_Business_Unit__c
                   From ERP7__Employees__c
                   Where ERP7__Employee_User__c = : UserInfo.getUserId()
                   Order by CreatedDate Asc Limit 1];
        
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
        if(FC != null){
            comW.Allowscanning = FC.ERP7__Enable_Scanning_for_Flows__c; comW.displayStockAddress =FC.ERP7__Show_Stock_Address_In_Outbound__c; comW.dontDefaultSnLotPick = FC.ERP7__dontDefaultSnLotPick__c;
            comW.dontallowChannelRemove = FC.ERP7__Restrict_Selected_Channel__c; comW.hideBarcodeLabel = FC.ERP7__Hide_Barcode_in_Pick__c; comW.ShowLangOptionForPickSlip = FC.ERP7__ShowLangOptionForPickSlip__c;
            comW.ReplacePickSlipOrgURL = FC.ERP7__Replace_Pickslip_OrgURL__c;
        }
        
        if(empList.size() > 0) { 
            comW.Employee = empList[0]; 
            
            if(comW.Employee.Channel__c != Null){ 
                List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name
                                                                              From Distribution_Channel__c
                                                                              Where Channel__c = : comW.Employee.Channel__c And Active__c = true And Site__c != Null
                                                                              Order By ERP7__Primary__c Desc];
                if(DistributionChannels.size() > 0) {
                    for(Distribution_Channel__c DC: DistributionChannels) {
                        comW.channelSites.add(new SelectOptions(DC.Site__c, DC.Name));
                    }
                } 
            } 
        } 
        comW.LogisticRecs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' ,ERP7__Order_S__r.Name, ERP7__Sales_Order__r.Name, ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, '+
                                           +'ERP7__Distribution_Channel__r.ERP7__Site__c, Channel__r.Name, ERP7__Distribution_Channel__r.ERP7__Site__r.Name,  ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where Id IN :soIdss'); 
        if(comW.LogisticRecs.size() > 0){
            comW.SiteName = comW.LogisticRecs[0].ERP7__Distribution_Channel__r.ERP7__Site__r.Name;
            comW.ChannelName = comW.LogisticRecs[0].Channel__r.Name;
            comW.ChannelId = comW.LogisticRecs[0].Channel__c;
            comW.selectedSite = comW.LogisticRecs[0].ERP7__Distribution_Channel__r.ERP7__Site__c;
            selectedSite = comW.selectedSite;
        }
        List<Id> soIds = new List<Id>();
        for(ERP7__Logistic__c logistic :comW.LogisticRecs){
            soIds.add(logistic.Id);
            if(logistic.ERP7__Order_S__c != Null) OrderIds.add(logistic.ERP7__Order_S__c);
            if(logistic.ERP7__Sales_Order__c != Null) OrderIds.add(logistic.ERP7__Sales_Order__c);
            if(logistic.ERP7__Purchase_Order__c != Null) OrderIds.add(logistic.ERP7__Purchase_Order__c);
            if(logistic.ERP7__Work_Order__c != Null) OrderIds.add(logistic.ERP7__Work_Order__c);
            if(logistic.ERP7__Transfer_Order__c != Null) OrderIds.add(logistic.ERP7__Transfer_Order__c);
            spIds.add(logistic.Channel__c);
        }
        
        
        try {            
            Boolean error = false;
            String customerId = '';
            Boolean showSN = false;
            Boolean showBatch = false;
            String Reserved = 'Reserved';
            String Committed = 'Committed';
            String ReturnedToSupplier = 'Returned to Supplier';
            
            Set<Id> proIds = new Set<Id>();
            Set<Id> assIds = new Set<Id>();
            
            List<Id> SerialIds2Exempt = new List<Id>();
            String selectedOrders = '', barcodeLoc = '', barcodeLocMsg = '';            
            List<Location__c> SSLList = new List<Location__c>();
            List<Wrappers> soliWrapperList = new List<Wrappers>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            List<Stock_Outward_Line_Item__c> PPLIList2Delete = new List<Stock_Outward_Line_Item__c>(); 
            Map<Id, Id> stockMap = new Map<Id, Id>();
            //logistic Ids
            if(soIds.size() > 0) {
                if(!error) { 
                    String errorMsg =  '';
                    Map<Id, Product2> productMap = new Map<Id, Product2>();
                    Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>();
                    List<MRP__c> MRPS = new List<MRP__c>();                 
                    Set<Id> WIISIds = new Set<Id>();
                    Set<Id> mrpIds = new Set<Id>();
                    Map<Id, List<ERP7__Stock_Outward_Line_Item__c>> lolisSolis = new Map<Id, List<ERP7__Stock_Outward_Line_Item__c>>();
                    String mrpKit = 'MRP Kit';
                    String TrueValue = 'True'; 
                    
                    List<ERP7__Logistic_Line_Item__c> soliss = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In: soIds and ERP7__RMA_Line_Item__c = Null order by ERP7__Logistic__c ASC'); 
                    // One logistic Order for Multiple SOs
                    
                    //Added by Arshad 18 Sep 2023
                    Set<Id> LOLIsIds = new Set<Id>(); 
                    Set<Id> LOLIsProdsIds = new Set<Id>(); 
                    Set<Id> LOLIsOrdlinesIds = new Set<Id>(); 
                    Set<Id> LOLIsSOlinessIds = new Set<Id>(); 
                    Set<Id> LOLIsPOlinesIds = new Set<Id>(); 
                    Set<Id> LOLIsWOlinesIds = new Set<Id>(); 
                    Set<Id> LOLIsTOlinesIds = new Set<Id>(); 
                    Map<Id,Decimal> batchStocks = new Map<Id,Decimal>(); 
                    Set<Id> batchStocksIds = new Set<Id>(); 

                    for(ERP7__Logistic_Line_Item__c solis: soliss) {
                        //Added by Arshad 18 Sep 2023
                        LOLIsIds.add(solis.Id); 
                        if(solis.ERP7__Product__c != null) LOLIsProdsIds.add(solis.ERP7__Product__c);
                        if(solis.ERP7__Order_Product__c != null){
                            LOLIsOrdlinesIds.add(solis.ERP7__Order_Product__c);
                            if(solis.ERP7__Order_Product__r.OrderId != Null) OrderIds.add(solis.ERP7__Order_Product__r.OrderId);
                        }
                        if(solis.ERP7__Sales_Order_Line_Item__c != null){
                            LOLIsSOlinessIds.add(solis.ERP7__Sales_Order_Line_Item__c);
                            if(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != Null) OrderIds.add(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c);
                        }
                        if(solis.ERP7__Purchase_Line_Items__c != null){
                            LOLIsPOlinesIds.add(solis.ERP7__Purchase_Line_Items__c);
                            if(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != Null) OrderIds.add(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c);
                        }
                        if(solis.ERP7__Work_Order_Line_Items__c != null){
                            LOLIsWOlinesIds.add(solis.ERP7__Work_Order_Line_Items__c);
                            if(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c != Null) OrderIds.add(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c);
                        }
                        if(solis.ERP7__Transfer_Order_Line_Item__c != null){
                            LOLIsTOlinesIds.add(solis.ERP7__Transfer_Order_Line_Item__c);
                            if(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != Null) OrderIds.add(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c);
                        }
                    }
                    
                    system.debug('*** OrderIds : '+OrderIds);
                    Transient List<ERP7__Stock_Outward_Line_Item__c> pplis = new List<ERP7__Stock_Outward_Line_Item__c>();
                    Transient List<ERP7__Stock_Outward_Line_Item__c> Allpplis = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ',ERP7__Logistic_Line_Item__r.ERP7__Quantity__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Picture__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__r.Name,ERP7__Product__r.Name,ERP7__Logistic_Line_Item__r.Name, ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c,ERP7__Logistic_Line_Item__r.ERP7__Packed_Quantity__c,ERP7__Serial__r.Id, ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c from Stock_Outward_Line_Item__c where (ERP7__Order__c =: OrderIds OR ERP7__Sales_Order__c In: OrderIds Or ERP7__Work_Orders__c In: OrderIds Or ERP7__Purchase_Orders__c In: OrderIds Or ERP7__Transfer_Order__c In: OrderIds) and (ERP7__Status__c  = :Reserved Or ERP7__Status__c =:Committed Or ERP7__Status__c =:ReturnedToSupplier ) and ERP7__Quantity__c > 0 and ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :selectedSite and ERP7__RMA_Line_Item__c = Null ');
                    ERP7__Stock_Outward_Line_Item__c ss = new ERP7__Stock_Outward_Line_Item__c();
                    system.debug('Allpplis : '+Allpplis.size());
                    
                    //Changed by Arshad 18 Sep 2023 - was for loop; changed to while
                    while(Allpplis.size() > 0){
                        ss = Allpplis[0];
                        if(ss.ERP7__Status__c  == 'Reserved'){
                            pplis.add(ss);
                            //Added by Arshad 18 Sep 2023
                            WIISIds.add(ss.Site_Product_Service_Inventory_Stock__c);
                            if(ss.ERP7__Product__c != Null) proIds.add(ss.ERP7__Product__c);
                            if(ss.ERP7__Fixed_Asset__c != Null) proIds.add(ss.ERP7__Fixed_Asset__r.ERP7__Product__c);
                            if(ss.ERP7__Fixed_Asset__c != Null) assIds.add(ss.ERP7__Fixed_Asset__c);
                            if(ss.ERP7__MRP_Material_Requirements_Planning__c != Null) mrpIds.add(ss.ERP7__MRP_Material_Requirements_Planning__c);
                            if(ss.ERP7__Product__c != null && LOLIsProdsIds.contains(ss.ERP7__Product__c) && ss.ERP7__Logistic_Line_Item__c != null && LOLIsIds.contains(ss.ERP7__Logistic_Line_Item__c) && ((ss.ERP7__Order_Product__c != Null && LOLIsOrdlinesIds.contains(ss.ERP7__Order_Product__c)) || (ss.ERP7__Sales_Order_Line_Item__c != Null && LOLIsSOlinessIds.contains(ss.ERP7__Sales_Order_Line_Item__c)) || (ss.ERP7__Purchase_Line_Items__c != Null && LOLIsPOlinesIds.contains(ss.ERP7__Purchase_Line_Items__c)) || (ss.ERP7__Work_Order_Line_Items__c != Null && LOLIsWOlinesIds.contains(ss.ERP7__Work_Order_Line_Items__c)) || (ss.ERP7__Transfer_Order_Line_Item__c != Null && LOLIsTOlinesIds.contains(ss.ERP7__Transfer_Order_Line_Item__c)))){
                                if(lolisSolis.ContainsKey(ss.ERP7__Logistic_Line_Item__c)) lolisSolis.get(ss.ERP7__Logistic_Line_Item__c).add(ss);
                                else lolisSolis.put(ss.ERP7__Logistic_Line_Item__c,new List<ERP7__Stock_Outward_Line_Item__c>{ss});

                                Decimal stockOutQuan=0;
                                if(ss.ERP7__Material_Batch_Lot__c != null && !batchStocksIds.contains(ss.ERP7__Material_Batch_Lot__c)){
                                    stockOutQuan+=ss.ERP7__Quantity__c+ss.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c;
                                    batchStocks.put(ss.ERP7__Material_Batch_Lot__c,stockOutQuan);
                                    batchStocksIds.add(ss.ERP7__Material_Batch_Lot__c);
                                }
                            }
                            //
                        }
                        //system.debug('ss.ERP7__Status__c : '+ss.ERP7__Status__c);
                        if((ss.ERP7__Status__c == 'Committed' || ss.ERP7__Status__c == 'Returned to Supplier') && ss.ERP7__Logistic_Line_Item__r.ERP7__Packed_Quantity__c != ss.ERP7__Logistic_Line_Item__r.ERP7__Quantity__c){ // && ss.ERP7__Logistic_Line_Item__r.ERP7__Packed_Quantity__c == 0) {
                            //Boolean isbatch = false; Boolean isSerial = false;
                            //if(ss.ERP7__Product__r.ERP7__Lot_Tracked__c && ss.ERP7__Material_Batch_Lot__c != null) isbatch = true;
                            //else if(ss.ERP7__Product__r.ERP7__Serialise__c && ss.ERP7__Serial__c != null) isSerial = true;
                            //comW.commitedSOLI.add(new CommittedStockWrap(ss,false,false));
                            comW.commitedSOLIIdsList.add(ss.Id);
                        }
                        Allpplis.remove(0);
                    }
                    
                    //Added by Arshad 18 Sep 2023
                    system.debug('commitedSOLIIdsList : '+comW.commitedSOLIIdsList.size());
                    system.debug('pplis : '+pplis.size());
                    Allpplis = new List<ERP7__Stock_Outward_Line_Item__c>();
                    system.debug('Allpplis 2: '+Allpplis.size());
                    
                    //commented by Arshad 18 Sep 2023
                   //
                    for(ERP7__Stock_Outward_Line_Item__c ppli: pplis) {
                       // if(ppli.Name != 'Serial Stock Holder') 
                        WIISIds.add(ppli.Site_Product_Service_Inventory_Stock__c);
                        if(ppli.ERP7__Product__c != Null) proIds.add(ppli.ERP7__Product__c);
                        if(ppli.ERP7__Fixed_Asset__c != Null) proIds.add(ppli.ERP7__Fixed_Asset__r.ERP7__Product__c);
                        if(ppli.ERP7__Fixed_Asset__c != Null) assIds.add(ppli.ERP7__Fixed_Asset__c);
                        if(ppli.ERP7__MRP_Material_Requirements_Planning__c != Null) mrpIds.add(ppli.ERP7__MRP_Material_Requirements_Planning__c);
                    }
                    //

                    system.debug('proIds : '+proIds);
                    MRPS = Database.query('select ' + String.escapeSingleQuotes(MRPFields) + ' ,ERP7__Order_Product__r.OrderId, Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, RecordType.Name, ERP7__MRP_Product__r.ERP7__Item_Description__c, MRP_Product__r.ERP7__Lot_Tracked__c, MRP_Product__r.Serialise__c from MRP__c where ((ERP7__Order_Product__r.OrderId IN: OrderIds OR Sales_Order_Line_Item__r.ERP7__Sales_Order__c In :OrderIds Or ERP7__Purchase_Order__c In :OrderIds Or ERP7__Work_Order__c In :OrderIds Or ERP7__Transfer_Order__c In :OrderIds) And ERP7__Status__c  = :Reserved And RecordType.Name = :mrpKit And Id In: mrpIds)');
                    system.debug('MRPS : '+MRPS.size());
                    
                    //commented by Arshad 18 Sep 2023
                   //
                    for(ERP7__Logistic_Line_Item__c loli : soliss){
                        List<ERP7__Stock_Outward_Line_Item__c> mySolis = new List<ERP7__Stock_Outward_Line_Item__c>();
                        for(ERP7__Stock_Outward_Line_Item__c ppli: pplis) {
                            if(loli.ERP7__Product__c == ppli.ERP7__Product__c && loli.Id == ppli.ERP7__Logistic_Line_Item__c && ((ppli.ERP7__Order_Product__c != Null && ppli.ERP7__Order_Product__c == loli.ERP7__Order_Product__c) || (ppli.ERP7__Sales_Order_Line_Item__c != Null && ppli.ERP7__Sales_Order_Line_Item__c == loli.ERP7__Sales_Order_Line_Item__c) || (ppli.ERP7__Purchase_Line_Items__c != Null && ppli.ERP7__Purchase_Line_Items__c == loli.ERP7__Purchase_Line_Items__c) || (ppli.ERP7__Work_Order_Line_Items__c != Null && ppli.ERP7__Work_Order_Line_Items__c == loli.ERP7__Work_Order_Line_Items__c) || (ppli.ERP7__Transfer_Order_Line_Item__c != Null && ppli.ERP7__Transfer_Order_Line_Item__c == loli.ERP7__Transfer_Order_Line_Item__c))){
                                //system.debug('lolisSolis : '+lolisSolis.ContainsKey(loli.Id));
                                if(lolisSolis.ContainsKey(loli.Id)) lolisSolis.get(loli.Id).add(ppli);
                                else lolisSolis.put(loli.Id,new  List<ERP7__Stock_Outward_Line_Item__c>{ppli});
                                // mySolis.add(ppli);
                                //system.debug('lolisSolis : '+lolisSolis);
                            }
                        } 
                    }
                    //

                    //Added by Arshad 18 Sep 2023
                    system.debug('lolisSolis : '+lolisSolis.keyset());
                    //for(Id i: lolisSolis.keyset()){
                    //    system.debug('key~>'+i+' value size~>'+lolisSolis.get(i).size());
                    //}

                    productMap = new Map<Id, Product2>([Select Id, Name, ProductCode, Picture__c, Preview_Image__c, Item_Description__c, ERP7__Lot_Tracked__c, Special_Instructions__c, Weight__c, Barcode__c From Product2 Where Id In: proIds]); //Serialise__c
                    assetMap = new Map<Id, Asset__c>([Select Id, Name, Picture__c, Preview_Image__c, Status__c, Item_Description__c, Special_Instructions__c, Weight__c, Barcode__c, ERP7__Serialise__c From Asset__c Where Id In: assIds]); //Serialise__c
                    system.debug('productMap : '+productMap.size());
                    Transient List<Inventory_Stock__c> WIISLists = new List<Inventory_Stock__c>();
                    WIISLists = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ', Fixed_Asset__r.Product__c, Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                               +' StorageContainer__r.Barcode__c from Inventory_Stock__c where Warehouse__c =: selectedSite And ((Product__c In: proIds And ((ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 and Name = \'Serial Stock Holder\')) Or Id In :WIISIds)) Or Fixed_Asset__r.Product__c In: proIds ) Order By ERP7__Expiry_Date__c ASC'); 
                    
                    system.debug('proIds~>'+proIds.size()+' and assIds~>'+assIds.size());
                    
                    Transient List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = new List<ERP7__Stock_Inward_Line_Item__c>();
                    StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Serial__c, ERP7__Serial__r.ERP7__Available__c,ERP7__Serial__r.ERP7__Material_Batch_Lot__c,
                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c, Fixed_Asset__c, Fixed_Asset__r.Product__c, ERP7__Material_Batch_Lot__r.ERP7__Production_Version__c
                                            From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISLists And
                                            (ERP7__Product__c In :proIds Or Fixed_Asset__c In: assIds) And Active__c = True  Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                    
                    system.debug('WIISLists~>'+WIISLists.size()+' and StockInwardLineItems~>'+StockInwardLineItems.size()+' and MRPS~>'+MRPS.size());
                    
                    Decimal myStock = 0;
                    Set<Id> warehouseIds = new Set<Id>();
                    Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();  
                    Map<Id,Id> bin2exclude = new Map<Id,Id>();
                    Map<Id,Id> loc2exclude = new Map<Id,Id>();
                    Map<Id,Id> batchVersion = new Map<Id,Id>();
                    Map<Id,List<ERP7__Inventory_Stock__c>> productStocks = new Map<Id,List<ERP7__Inventory_Stock__c>>();
                    Map<String,Set<SelectOptions>> stockBatches = new Map<String,Set<SelectOptions>>();
                    Map<Id,Set<Id>> stockSerials = new Map<Id,Set<Id>>();
                    Map<Id,Set<Id>> serialBatchmap = new Map<Id,Set<Id>>();
                    
                    //Changed by Arshad 18 Sep 2023 - was for loop; changed to while
                    ERP7__Stock_Inward_Line_Item__c InwardLine = new ERP7__Stock_Inward_Line_Item__c();
                    while(StockInwardLineItems.size() > 0){
                        InwardLine = StockInwardLineItems[0];
                        if(InwardLine.ERP7__Material_Batch_Lot__c != Null ){
//'inside when batch not null' //&& InwardLine.ERP7__Serial__c == Null
                            if(InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Production_Version__c != null){
//'inside when production version not null'
batchVersion.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Production_Version__c);}
                            //Here it's taking all stock from a batches     batchId:batchStock
                            batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                            if(!stockBatches.containsKey(InwardLine.ERP7__Product__c)) { 
                                Set<SelectOptions> myBatches = new Set<SelectOptions>();
                                if(!InwardLine.ERP7__Product__r.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOptions('','--None--'));
                                myBatches.add(new SelectOptions(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                stockBatches.put(InwardLine.ERP7__Product__c, myBatches);
                            } else{
                                Set<SelectOptions> myBatches = stockBatches.get(InwardLine.ERP7__Product__c);
                                Boolean found = false;
                                for(SelectOptions SO : myBatches){
                                    if(SO.Value == String.valueof(InwardLine.ERP7__Material_Batch_Lot__c)) { found = true; break; }
                                }
                                if(!found){
                                    myBatches.add(new SelectOptions(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                    stockBatches.put(InwardLine.ERP7__Product__c, myBatches);
                                }
                                system.debug('stockBatches : '+stockBatches);
                            }
                        }
                        else if(InwardLine.ERP7__Serial__c != Null){
                            if(InwardLine.ERP7__Serial__r.ERP7__Available__c){
                                if(!stockSerials.containsKey(InwardLine.ERP7__Product__c)) { 
                                    Set<Id> mySerials = new Set<Id>();
                                    mySerials.add(InwardLine.ERP7__Serial__c);
                                    stockSerials.put(InwardLine.ERP7__Product__c,mySerials);
                                } else{
                                    Set<Id> mySerials = stockSerials.get(InwardLine.ERP7__Product__c);
                                    mySerials.add(InwardLine.ERP7__Serial__c);
                                    stockSerials.put(InwardLine.ERP7__Product__c,mySerials);
                                }
                                if(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c != null){
                                    if(!serialBatchmap.containsKey(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c)){
                                        Set<Id> serialnos = new Set<Id>();
                                        serialnos.add(InwardLine.ERP7__Serial__c);
                                        serialBatchmap.put(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c,serialnos);
                                    }else{
                                        Set<Id> serialnos = serialBatchmap.get(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c);
                                        serialnos.add(InwardLine.ERP7__Serial__c);
                                        serialBatchmap.put(InwardLine.ERP7__Serial__r.ERP7__Material_Batch_Lot__c,serialnos);
                                    }
                                }
                            }
                        } 
                        if(InwardLine.ERP7__Serial__c != Null) SerialIds2Exempt.add(InwardLine.ERP7__Serial__c);
                        StockInwardLineItems.remove(0);
                    }

                    StockInwardLineItems = new List<ERP7__Stock_Inward_Line_Item__c>();
                    system.debug('StockInwardLineItems2 size~>'+StockInwardLineItems.size());

                    system.debug('stockSerials : '+stockSerials);

                    Map<Id, List<MRP__c>> soliMRPS = new Map<Id, List<MRP__c>>();
                    
                    if(MRPS.size() > 0){
                        for(ERP7__Logistic_Line_Item__c solis : soliss) {
                            Set<MRP__c> myMRPS = new Set<MRP__c>();
                            for(MRP__c mrp : MRPS) {
                                if((solis.ERP7__Order_Product__c != Null && mrp.ERP7__Order_Product__c == solis.ERP7__Order_Product__c) || (solis.ERP7__Sales_Order_Line_Item__c != Null && mrp.Sales_Order_Line_Item__c == solis.ERP7__Sales_Order_Line_Item__c) || (solis.ERP7__Purchase_Line_Items__c != Null && mrp.ERP7__Purchase_Line_Items__c == solis.ERP7__Purchase_Line_Items__c) || (solis.Work_Order_Line_Items__c != Null && mrp.ERP7__Work_Order_Line_Items__c == solis.Work_Order_Line_Items__c) || (solis.ERP7__Transfer_Order_Line_Item__c != Null && mrp.ERP7__Transfer_Order_Line_Item__c == solis.ERP7__Transfer_Order_Line_Item__c)){
                                    myMRPS.add(mrp);
                                }
                            }
                            List<MRP__c> myMRPSNew = new List<MRP__c>();
                            myMRPSNew.addAll(myMRPS);
                            soliMRPS.put(solis.Id,myMRPSNew);
                        }
                    }


                    //*******************New Changes for batch stock****************************
                    //commented by Arshad 18 Sep 2023
                    /*
                    Map<Id,Decimal> batchStocks = new Map<Id,Decimal>(); 
                    for(ERP7__Logistic_Line_Item__c solis : soliss) {
                        if(lolisSolis.containskey(solis.Id)){
                            for(ERP7__Stock_Outward_Line_Item__c SOLI:lolisSolis.get(solis.Id)){
                                Decimal stockOutQuan=0;
                                if(SOLI.ERP7__Material_Batch_Lot__c != null){
                                    stockOutQuan+=SOLI.ERP7__Quantity__c+SOLI.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c;
                                    batchStocks.put(SOLI.ERP7__Material_Batch_Lot__c,stockOutQuan);
                                }
                            } 
                        }
                    }
                   
                    //*******************New Changes for batch stock ends****************************

                    
                    System.debug('Limits.getCpuTime 4- '+ Limits.getCpuTime());
                    System.debug('Limits.getLimitCpuTime 4- '+ Limits.getLimitCpuTime());
                    System.debug('Limits.getHeapSize 4- '+ Limits.getHeapSize());
                    System.debug('Limits.getLimitHeapSize 4- '+ Limits.getLimitHeapSize());
                    
                    //WIISLists = new List<Inventory_Stock__c>();
                    for(ERP7__Logistic_Line_Item__c solis : soliss) {
                        Wrappers swrap_IN = new Wrappers();
                        swrap_IN.Product = null; 
                        if(solis.ERP7__Quantity__c > 0 && (solis.ERP7__Picked_Quantity__c == Null || solis.ERP7__Quantity__c > solis.ERP7__Picked_Quantity__c) && lolisSolis.containsKey(solis.Id)){
                            Boolean runOnceForSerialise = true;
                            for(ERP7__Stock_Outward_Line_Item__c sli : lolisSolis.get(solis.Id)){ 
                                system.debug('lolisSolis : '+lolisSolis.get(solis.Id).size());
                                system.debug('val : '+(solis.Product__r.ERP7__Is_Kit__c && solis.Explode__c));
                                if((!solis.Product__r.ERP7__Is_Kit__c && !solis.Explode__c)){
                                    system.debug('if executed : prodduct : '+sli.Product__c);
                                    Wrappers swrap = new Wrappers(); 
                                    if(sli.Product__c != Null) swrap.Product = productMap.get(sli.Product__c);
                                    if(sli.Fixed_Asset__c != Null) swrap.Asset = assetMap.get(sli.ERP7__Fixed_Asset__c);
                                    swrap.loli = solis;
                                    myStock = 0;
                                    system.debug('swrap.LOLI.Picked_Quantity__c  : '+swrap.LOLI.Picked_Quantity__c );
                                    if(swrap.LOLI.Picked_Quantity__c != null) { 
                                        if(swrap.loli.Picked_Quantity__c == swrap.loli.Quantity__c) {
                                            swrap.raisedQty = double.valueof(swrap.loli.Picked_Quantity__c);     
                                            swrap.remainingQty = double.valueof(swrap.loli.Quantity__c - swrap.raisedQty);
                                        } else if(swrap.loli.Picked_Quantity__c < swrap.loli.Quantity__c) {
                                            swrap.raisedQty = double.valueof(swrap.loli.Picked_Quantity__c); 
                                            swrap.remainingQty = double.valueof(swrap.loli.Quantity__c - swrap.raisedQty);                                      
                                            swrap.requiredQty = (swrap.remainingQty > 0)? 1 : 0;
                                        }
                                    } 
                                    else { 
                                        system.debug('swrap.loli.Quantity__c : '+swrap.loli.Quantity__c);
                                        swrap.requiredQty = (Schema.sObjectType.Stock_Outward_Line_Item__c.Fields.Quantity__c.isAccessible()) ? double.valueof(swrap.loli.Quantity__c) : 0;
                                        swrap.remainingQty = (Schema.sObjectType.Stock_Outward_Line_Item__c.Fields.Quantity__c.isAccessible()) ? double.valueof(swrap.loli.Quantity__c) : 0; 
                                    }
                                    
                                    Set<SelectOptions> options1 = new Set <SelectOptions>(); 
                                    Set<SelectOptions> options2 = new Set <SelectOptions>();
                                    Set<SelectOptions> options3 = new Set <SelectOptions>(); 
                                    Set<SelectOptions> address = new Set <SelectOptions>();
                                    Set<Id> addressIds = new Set<Id>(); 
                                    Set<Id> options1Ids = new Set<Id>(); 
                                    Set<Id> options2Ids = new Set<Id>(); 
                                    Set<Id> options3Ids = new Set<Id>(); 
                                    if(runOnceForSerialise){
                                        system.debug('inhere runOnceForSerialise once');
                                        if(swrap.loli.Product__r.Serialise__c) runOnceForSerialise = false;
                                        for(ERP7__Inventory_Stock__c wiis: WIISLists) {
                                            if((wiis.Product__c == solis.Product__c || wiis.Fixed_Asset__r.Product__c == solis.Product__c) && (solis.ERP7__Production_Version__c == Null || solis.ERP7__Production_Version__c == wiis.ERP7__Version__c)) {
                                                //system.debug('wiis.StorageContainer__c  : '+wiis.StorageContainer__c);
                                                //system.debug('wiis.Location__c  : '+wiis.Location__c);
                                                //system.debug('wiis.Warehouse__c  : '+wiis.Warehouse__c);
                                                if(wiis.StorageContainer__c != null) {
                                                    swrap.binName = swrap.AddressName = wiis.StorageContainer__c; 
                                                    if(wiis.StorageContainer__r.Name != null && !options3Ids.contains(wiis.StorageContainer__c)) options3.add(new SelectOptions(wiis.StorageContainer__c, wiis.StorageContainer__r.Name));
                                                    options3Ids.add(wiis.StorageContainer__c);
                                                    if(wiis.StorageContainer__r.Barcode__c != null) { 
                                                        if(!addressIds.contains(wiis.StorageContainer__c)) address.add(new SelectOptions(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c));
                                                        addressIds.add(wiis.StorageContainer__c);
                                                        myStock += WIIS.Number_of_Item_In_Stock__c;
                                                    }
                                                } 
                                                else if(wiis.Location__c != null) {
                                                    //Changes started here from imran for polymem fix
                                                    //swrap.LN = wiis.Location__r.Name; swrap.LocationName = swrap.AddressName  = wiis.Location__c;
                                                    if(sli.ERP7__Site_Product_Service_Inventory_Stock__c == wiis.Id && sli.ERP7__Logistic_Line_Item__c == solis.Id) {
                                                        swrap.LN = wiis.Location__r.Name; swrap.LocationName = swrap.AddressName  = wiis.Location__c;
                                                    }
                                                    //Changes ended here imran
                                                    if(wiis.Location__r.Name != null && !options2Ids.contains(wiis.Location__c)) options2.add(new SelectOptions(wiis.Location__c, wiis.Location__r.Name));
                                                    options2Ids.add(wiis.Location__c);
                                                    if(wiis.Location__r.Barcode__c != null){
                                                        if(!addressIds.contains(wiis.Location__c)) address.add(new SelectOptions(wiis.Location__c, wiis.Location__r.Barcode__c)); 
                                                        addressIds.add(wiis.Location__c);
                                                        myStock += WIIS.Number_of_Item_In_Stock__c;
                                                    }
                                                } 
                                                else if(wiis.Warehouse__c != null) {
                                                    swrap.WN = wiis.Warehouse__r.Name;
                                                    swrap.WarehouseName = swrap.AddressName = wiis.Warehouse__c;
                                                    //system.debug('swrap.WarehouseName : '+swrap.WarehouseName);
                                                    if(wiis.Name != 'Serial Stock Holder'){
                                                        if(wiis.Warehouse__r.Name != null && !options1Ids.contains(wiis.Warehouse__c)) options1.add(new SelectOptions(wiis.Warehouse__c, wiis.Warehouse__r.Name)); 
                                                        options1Ids.add(wiis.Warehouse__c);
                                                    }
                                                    //system.debug('wiis.Warehouse__r.Barcode__c : '+wiis.Warehouse__r.Barcode__c);
                                                    if(wiis.Warehouse__r.Barcode__c != null){
                                                        if(wiis.Name != 'Serial Stock Holder'){
                                                            if(!addressIds.contains(wiis.Warehouse__c)) address.add(new SelectOptions(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c));
                                                            addressIds.add(wiis.Warehouse__c);
                                                        }
                                                        myStock += WIIS.Number_of_Item_In_Stock__c;
                                                    }
                                                }
                                                stockMap.put(wiis.Product__c, wiis.Id);
                                            }
                                        }
                                    }
                                    swrap.address.addAll(address);
                                    swrap.CurrentWarehouses.addAll(options1); 
                                    swrap.CurrentLocations.addAll(options2);    
                                    swrap.CurrentBins.addAll(options3); 
                                    
                                    //Changes started here from imran for polymem fix
                                    if(swrap.binName != null){
                                        swrap.AddressName = swrap.binName;
                                    }
                                    else if(swrap.LocationName != null){
                                        swrap.AddressName = swrap.LocationName;
                                    }
                                    //Changes ended here imran
                                    system.debug('myStock 222: '+myStock);
                                    system.debug('swrap.loli.Quantity__c 222: '+swrap.loli.Quantity__c);
                                    system.debug('swrap.raisedQty 222: '+swrap.raisedQty);
                                    if((swrap.loli.Status__c == 'Reserved' || swrap.loli.Status__c == 'Requested') && myStock >= 0) swrap.inventoryStock = myStock+swrap.loli.Quantity__c-swrap.raisedQty;  
                                    else swrap.inventoryStock = myStock; 
                                    
                                    // First AddressName and it's stock only .......
                                    swrap.BatchLotCodes = new List <SelectOptions>(); 
                                    if(comW.dontDefaultSnLotPick){ swrap.BatchLotCodes.add(new SelectOptions('','--None--'));  }
                                    //system.debug('solis.ERP7__Production_Version__c : '+solis.ERP7__Production_Version__c);
                                    //system.debug('stockBatches.ContainsKey(solis.Product__c) : '+stockBatches.ContainsKey(solis.Product__c));
                                    if(solis.ERP7__Production_Version__c != Null && stockBatches.ContainsKey(solis.Product__c)){
                                        //system.debug('in if');
                                        List <SelectOptions> stkBatches = new List <SelectOptions>();
                                        stkBatches.addAll(stockBatches.get(solis.Product__c));
                                        //system.debug('stkBatches : '+stkBatches.size());
                                        for(SelectOptions SO : stockBatches.get(solis.Product__c)){
                                            if(SO.Value != null && SO.Value != ''){
                                                //system.debug('batchVersion.ContainsKey(SO.Value) : '+batchVersion.ContainsKey(SO.Value));
                                                //system.debug('batchVersion.get(SO.Value): '+batchVersion.get(SO.Value));
                                                if(batchVersion.ContainsKey(SO.Value) && batchVersion.get(SO.Value) == solis.ERP7__Production_Version__c) 
                                                    swrap.BatchLotCodes.add(SO);
                                            }
                                        }
                                    }
                                    else if(stockBatches.ContainsKey(solis.Product__c)) { system.debug('else in no versions'); swrap.BatchLotCodes.addAll(stockBatches.get(solis.Product__c)); }
                                    //system.debug('swrap.BatchLotCodes.size() : '+swrap.BatchLotCodes.size());
                                    //system.debug('solis.ERP7__Product__r.ERP7__Lot_Tracked__c : '+solis.ERP7__Product__r.ERP7__Lot_Tracked__c);
                                    if(swrap.BatchLotCodes.size() > 0 && solis.ERP7__Product__r.ERP7__Lot_Tracked__c == true){
                                        if(!comW.dontDefaultSnLotPick){
                                            swrap.BatchLotCode = swrap.BatchLotCodes[0].Value;
                                            //Decimal bStock = (batchAvailStocks.get(swrap.BatchLotCodes[0].Value) != null)? batchAvailStocks.get(swrap.BatchLotCodes[0].Value) : 0;
                                            //if((swrap.loli.Status__c == 'Reserved' || swrap.loli.Status__c == 'Requested') && bStock >= 0) swrap.inventoryStock = bStock+swrap.loli.Quantity__c-swrap.raisedQty; 
                                            //***********New change for batch stock******************
                                            ERP7__Batch__c batch=new ERP7__Batch__c(); 
                                            //system.debug('swrap.BatchLotCode  : '+swrap.BatchLotCode );
                                            //system.debug('batchStocks.get(swrap.BatchLotCodes[0].Value) : '+batchStocks.get(swrap.BatchLotCodes[0].Value));
                                            if(batchStocks.get(swrap.BatchLotCodes[0].Value) == null) batch=[Select Id,Name,ERP7__Available_Quantity__c from ERP7__Batch__c where Id =:swrap.BatchLotCode Limit 1];
                                            Decimal bStock = (batchStocks.get(swrap.BatchLotCodes[0].Value) != null)? batchStocks.get(swrap.BatchLotCodes[0].Value) : batch.ERP7__Available_Quantity__c;
                                            //Imran need to verify this
                                            if((swrap.loli.Status__c == 'Reserved' || swrap.loli.Status__c == 'Requested') && bStock >= 0) swrap.inventoryStock = bStock;   //-swrap.raisedQty
                                        }else swrap.BatchLotCode = ''; 
                                        system.debug('swrap.inventoryStock batch: '+swrap.inventoryStock);
                                    }else swrap.BatchLotCode = ''; 
                                    
                                    if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);
                                    //system.debug('swrap.requiredQty : '+swrap.requiredQty);
                                    Boolean breaknow = false;
                                    if(swrap.raisedQty != swrap.loli.Quantity__c){
                                        //system.debug('in here raisedQty ==  QTY');
                                        if(swrap.loli.Product__r.Serialise__c){
                                            system.debug('in here serialized and dontDefaultSnLotPick~>'+comW.dontDefaultSnLotPick);
                                            if(swrap.requiredQty > 0) swrap.requiredQty = 1;
                                            swrap.serialized = true; showSN = true; swrap.SerialNumbers = sli; breaknow = true;
                                            if(comW.dontDefaultSnLotPick) swrap.SerialNumbers.Serial__c = null;
                                            if(stockSerials.ContainsKey(solis.Product__c) && stockSerials.get(solis.Product__c).size() > 0 && swrap.SerialNumbers.Serial__c == Null) {
                                                List<Id> srIds = new List<Id>();
                                                srIds.addAll(stockSerials.get(solis.Product__c));
                                                if(!comW.dontDefaultSnLotPick) swrap.SerialNumbers.Serial__c = srIds.remove(0);
                                                //system.debug('srIds.remove(0)~>'+srIds.remove(0)); //commented by arshad 31/01/23, throwing error List index out of bounds
                                                
                                                Set<Id> setIds = new Set<Id>(srIds);
                                                stockSerials.put(solis.Product__c,setIds);
                                            }
                                            system.debug('sli.ERP7__Serial__c : '+sli.ERP7__Serial__c);
                                            //if(swrap.SerialNumbers.Serial__c == null) swrap.SerialNumbers.Serial__c = sli.ERP7__Serial__c;
                                            system.debug('swrap.SerialNumbers.Serial__c~>'+swrap.SerialNumbers.Serial__c);
                                        } else if(solis.ERP7__Quantity__c == swrap.loli.Quantity__c) breaknow = true;
                                        if(swrap.BatchLotCodes.size() > 0 && swrap.loli.Product__r.Serialise__c == false && swrap.loli.Product__r.ERP7__Lot_Tracked__c) showBatch = true;
                                        soliWrapperList.add(swrap);
                                        if(breaknow) break;
                                    }
                                } 
                                else {
                                    system.debug('else mrp executed');
                                    
                                    for(MRP__c mrp : soliMRPS.get(solis.Id)){
                                        
                                        system.debug('1');
                                        system.debug('sli.ERP7__Product__c : '+sli.ERP7__Product__c);
                                        system.debug('mrp.ERP7__MRP_Product__c : '+mrp.ERP7__MRP_Product__c);
                                        if(sli.ERP7__MRP_Material_Requirements_Planning__c == mrp.Id && sli.ERP7__Product__c == mrp.ERP7__MRP_Product__c){
                                            system.debug('condition else true');
                                            
                                            swrap_IN.Product = productMap.get(mrp.MRP_Product__c);
                                            swrap_IN.loli = solis; swrap_IN.MRP = mrp; myStock = 0;
                                            system.debug('swrap_IN.mrp.Picked_Quantity__c : '+swrap_IN.mrp.Picked_Quantity__c);
                                            if(swrap_IN.mrp.Picked_Quantity__c != null && swrap_IN.mrp.Picked_Quantity__c > 0) {
                                                if(swrap_IN.mrp.Picked_Quantity__c == swrap_IN.mrp.Total_Amount_Required__c) {
                                                    swrap_IN.raisedQty = double.valueof(swrap_IN.mrp.Picked_Quantity__c); swrap_IN.remainingQty = double.valueof(swrap_IN.mrp.Total_Amount_Required__c - swrap_IN.raisedQty);
                                                } else if(swrap_IN.mrp.Picked_Quantity__c < swrap_IN.mrp.Total_Amount_Required__c) {
                                                    swrap_IN.raisedQty = double.valueof(swrap_IN.mrp.Picked_Quantity__c); 
                                                    swrap_IN.remainingQty = double.valueof(swrap_IN.mrp.Total_Amount_Required__c - swrap_IN.raisedQty);                                      
                                                    //swrap_IN.requiredQty = double.valueof(swrap_IN.mrp.Total_Amount_Required__c - swrap_IN.raisedQty);
                                                    swrap_IN.requiredQty = (swrap_IN.requiredQty > 0)? 1 : 0;
                                                }
                                            }
                                            else {
                                                swrap_IN.requiredQty = double.valueof(swrap_IN.mrp.Total_Amount_Required__c); 
                                                system.debug('swrap_IN.requiredQty : '+swrap_IN.requiredQty);
                                                swrap_IN.remainingQty = double.valueof(swrap_IN.mrp.Total_Amount_Required__c); 
                                                //swrap_IN.requiredQty = 1; 
                                            }
                                            Set<SelectOptions> options1_IN = new Set <SelectOptions>(); 
                                            Set<SelectOptions> options2_IN = new Set <SelectOptions>();
                                            Set<SelectOptions> options3_IN = new Set <SelectOptions>(); 
                                            Set<SelectOptions> address_IN = new Set <SelectOptions>(); 
                                            for(ERP7__Inventory_Stock__c wiis: WIISLists) {
                                                if(wiis.Product__c == mrp.MRP_Product__c) { // && (solis.ERP7__Production_Version__c == Null || solis.ERP7__Production_Version__c == wiis.ERP7__Version__c)
                                                    
                                                    if(wiis.StorageContainer__c != null) {
                                                        swrap_IN.binName = swrap_IN.AddressName = wiis.StorageContainer__c; 
                                                        if(wiis.StorageContainer__r.Name != null) options3_IN.add(new SelectOptions(wiis.StorageContainer__c, wiis.StorageContainer__r.Name));
                                                        if(wiis.StorageContainer__r.Barcode__c != null) { 
                                                            address_IN.add(new SelectOptions(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                                        }
                                                    } else if(wiis.Location__c != null) {
                                                        swrap_IN.LN = wiis.Location__r.Name; swrap_IN.LocationName = swrap_IN.AddressName  = wiis.Location__c;
                                                        if(wiis.Location__r.Name != null) options2_IN.add(new SelectOptions(wiis.Location__c, wiis.Location__r.Name));
                                                        if(wiis.Location__r.Barcode__c != null){
                                                            address_IN.add(new SelectOptions(wiis.Location__c, wiis.Location__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                                        }
                                                    } else if(wiis.Warehouse__c != null) {
                                                        swrap_IN.WN = wiis.Warehouse__r.Name; swrap_IN.WarehouseName = swrap_IN.AddressName = wiis.Warehouse__c;
                                                        if(wiis.Warehouse__r.Name != null) options1_IN.add(new SelectOptions(wiis.Warehouse__c, wiis.Warehouse__r.Name)); 
                                                        if(wiis.Warehouse__r.Barcode__c != null){
                                                            address_IN.add(new SelectOptions(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                                        }
                                                    }                   
                                                    stockMap.put(wiis.Product__c, wiis.Id);
                                                }
                                            }
                                            swrap_IN.address.addAll(address_IN);
                                            swrap_IN.CurrentWarehouses.addAll(options1_IN); 
                                            swrap_IN.CurrentLocations.addAll(options2_IN);    
                                            swrap_IN.CurrentBins.addAll(options3_IN); 
                                            
                                            if(swrap_IN.binName != null){
                                                swrap_IN.AddressName = swrap_IN.binName;
                                            }
                                            else if(swrap_IN.LocationName != null){
                                                swrap_IN.AddressName = swrap_IN.LocationName;
                                            } 
                                            
                                            system.debug('swrap_IN.loli.Status__c : '+swrap_IN.loli.Status__c);
                                            system.debug('myStock : '+myStock);
                                            if(swrap_IN.loli.Status__c == 'Reserved' && myStock >= 0) swrap_IN.inventoryStock = myStock+swrap_IN.mrp.Total_Amount_Required__c-swrap_IN.raisedQty;  
                                            else swrap_IN.inventoryStock = myStock; 
                                            system.debug('swrap_IN.inventoryStock : '+swrap_IN.inventoryStock);
                                            swrap_IN.BatchLotCodes = new List <SelectOptions>();   
                                            if(stockBatches.ContainsKey(mrp.MRP_Product__c)) { swrap_IN.BatchLotCodes.addAll(stockBatches.get(mrp.MRP_Product__c)); }
                                            system.debug('In else MRP comW.dontDefaultSnLotPick : '+comW.dontDefaultSnLotPick);
                                            if(swrap_IN.BatchLotCodes.size() > 0 && mrp.MRP_Product__r.ERP7__Lot_Tracked__c == true){
                                                if(!comW.dontDefaultSnLotPick){ // added the change on 3/05/2023 to not default batch
                                                    swrap_IN.BatchLotCode = swrap_IN.BatchLotCodes[0].Value; 
                                                    Decimal bStock = (batchAvailStocks.get(swrap_IN.BatchLotCodes[0].Value) != null)? batchAvailStocks.get(swrap_IN.BatchLotCodes[0].Value) : 0;
                                                    if((swrap_IN.loli.Status__c == 'Reserved' || swrap_IN.loli.Status__c == 'Requested') && bStock >= 0) swrap_IN.inventoryStock = bStock+swrap_IN.loli.Quantity__c-swrap_IN.raisedQty; 
                                                    
                                                }else swrap_IN.BatchLotCode = ''; //swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                                            }
                                            else swrap_IN.BatchLotCode = '';
                                            if(swrap_IN.requiredQty >= swrap_IN.inventoryStock) swrap_IN.requiredQty = double.valueof(swrap_IN.inventoryStock); 
                                            if(swrap_IN.raisedQty != swrap_IN.mrp.Total_Amount_Required__c){
                                                if(swrap_IN.mrp.MRP_Product__r.Serialise__c){
                                                    if(swrap_IN.requiredQty > 0) swrap_IN.requiredQty = 1;
                                                    swrap_IN.serialized = true; showSN = true;
                                                    if(stockSerials.ContainsKey(mrp.MRP_Product__c) && stockSerials.get(mrp.MRP_Product__c).size() > 0 && swrap_IN.SerialNumbers.Serial__c == Null){
                                                        List<Id> srIds = new List<Id>();
                                                        srIds.addAll(stockSerials.get(mrp.MRP_Product__c));
                                                        if(!comW.dontDefaultSnLotPick) swrap_IN.SerialNumbers.Serial__c = srIds.remove(0);
                                                        system.debug('swrap_IN.SerialNumbers.Serial__c~>'+swrap_IN.SerialNumbers.Serial__c);
                                                        Set<Id> setIds = new Set<Id>(srIds);
                                                        stockSerials.put(mrp.MRP_Product__c,setIds);
                                                    }
                                                } 
                                                if(swrap_IN.BatchLotCodes.size() > 0  && swrap_IN.mrp.MRP_Product__r.Serialise__c == false && swrap_IN.mrp.MRP_Product__r.ERP7__Lot_Tracked__c) showBatch = true;
                                                //swrap.MRPsWrapperList.add(swrap_IN);
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            if(swrap_IN.Product != null) soliWrapperList.add(swrap_IN);
                        }        
                    }
                    
                    
                    
                    
                    comW.soliWrapperList = soliWrapperList; 
                    comW.barcodeLocMsg = barcodeLocMsg; 
                    comW.showBatch = showBatch; 
                    comW.showSN = showSN; 
                    comW.SerialIds2Exempt = SerialIds2Exempt;
                    comW.stockMap = stockMap;
                    
                    return comW;                 
                }                
            } else comW.exceptionError = 'Please select an order to proceed.';
            
        } catch(Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
        }
        
        return comW;
    }
    */
    @AuraEnabled
    public static comWrap CreateBarcode(String SWL){
        comWrap comW = new comWrap();
        String errorMsg = '';
        PrintBarcodes PB = new PrintBarcodes();
        try {                        
            Boolean error = false;
            List<Id> soliIds = new List<Id>();
            Set<Id> pIds = new Set<Id>();
            String prodFields = UtilClass.selectStarFromSObject('Product2');
            utilClass.FLSCheck(prodFields.split(','),'Product2'); 
            List<Wrappers> soliWrapperList = (List<Wrappers>) JSON.deserialize(SWL, List<Wrappers> .class);
            List<Wrappers> soliSelectedWrapperList = new List<Wrappers>();
            PB.BarcodeWrapperList = new List<PrintBarcodes.BarcodeWrapper>();           
            if(soliWrapperList.size() > 0) {
                for(Wrappers wrap : soliWrapperList) {                     if(wrap.soliSelected == true) {                       soliIds.add(wrap.loli.Id);                         pIds.add(wrap.loli.Product__c);                         soliSelectedWrapperList.add(wrap);                     }                 }
                if(soliSelectedWrapperList.size() > 0) {                     errorMsg = '';                    List<Product2> prods = Database.query('select ' + String.escapeSingleQuotes(prodFields) +' from Product2 where Id In: pIds');                        Map<Id, Product2> pMap = new Map<Id, Product2>();                    for(Product2 prod: prods) { pMap.put(prod.Id, prod); }                                     for(Wrappers wrap : soliSelectedWrapperList) {                        PrintBarcodes.BarcodeWrapper BW;                        if(PB.LabelField != Null && PB.LabelField != '') BW = new PrintBarcodes.BarcodeWrapper(wrap.LOLI.Product__r.Barcode__c, wrap.LOLI.Product__r.Name, wrap.LOLI.Product__r.Name);                        else  BW = new PrintBarcodes.BarcodeWrapper(wrap.LOLI.Product__r.Barcode__c, '' , wrap.LOLI.Product__r.Name);                        BW.products = pMap.get(wrap.LOLI.Product__c);                        PB.BarcodeWrapperList.add(BW);                    }                 } else { errorMsg = 'Please select a line item to print barcode.'; }                  
            } else { errorMsg = 'Items have been picked, please proceed to packing.'; } 
        } catch(Exception e) { errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); } 
        comW.PB = String.valueof(PB);
        comW.exceptionError = errorMsg;
        //return Page.LogisticsPrintPickProductsPDF;
        return comW;
    }
    
   
    @AuraEnabled
    public static comWrap unCommitSOLI(String SoliId){
        comWrap comW = new comWrap();
        try {
            List<ERP7__Stock_Outward_Line_Item__c> SOLIS = [SELECT Id, ERP7__Picked_Quantity__c, ERP7__Status__c, ERP7__Picked_Date__c,ERP7__Serial__c FROM ERP7__Stock_Outward_Line_Item__c WHERE Id =: SoliId  LIMIT 1];
           List<ERP7__Serial_Number__c> serials2Update = new List<ERP7__Serial_Number__c>(); // 19_12_23 shaguftha to mark the deleted outward serials as avaialble
            for(ERP7__Stock_Outward_Line_Item__c SOLI : SOLIS){
                SOLI.ERP7__Picked_Quantity__c = 0;
                SOLI.ERP7__Picked_Date__c = null;
                SOLI.ERP7__Status__c = 'Reserved';
                if(SOLI.ERP7__Serial__c != null) serials2Update.add(new ERP7__Serial_Number__c(Id = SOLI.ERP7__Serial__c ,ERP7__Available__c= true));
            }
            update SOLIS;
            if(serials2Update.size() > 0) upsert serials2Update;
        } catch(exception e){            comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();        }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap PreparePickSerialNos(String logisticLineId, String searchString, List<Id> reservedSelectedSerials){
        comWrap comW = new comWrap();
        try {
            List<SerialWrapper> SWL = new List<SerialWrapper>();
            List<SerialWrapper> ASWL = new List<SerialWrapper>();
            
            if(logisticLineId != Null && logisticLineId != ''){
                List<ERP7__Logistic_Line_Item__c> logline = [Select Name,Id,ERP7__Product__c,ERP7__Order_Product__c,ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c,ERP7__Quantity__c,ERP7__Picked_Quantity__c,ERP7__Logistic__r.ERP7__Order_S__c from ERP7__Logistic_Line_Item__c where Id=:logisticLineId limit 1];
                if(logline.size() > 0){
                    String siteId = (logline[0].ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c != Null) ? logline[0].ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c : '';
                    List<Id> ReservedSerials = new List<Id>();
                    List<ERP7__Stock_Outward_Line_Item__c> stkList = [Select Id,Name,ERP7__Product__c,ERP7__Serial__c,ERP7__Serial__r.Name from ERP7__Stock_Outward_Line_Item__c where ERP7__Logistic_Line_Item__c != null and ERP7__Logistic_Line_Item__c=:logisticLineId And ERP7__Status__c = 'Reserved' and ERP7__Quantity__c > 0 limit 500]; //  added validation Qty greater than zero shaguftha 14/08/23
                    for(ERP7__Stock_Outward_Line_Item__c stk : stkList){                        if(stk.ERP7__Serial__c != null) {                            ReservedSerials.add(stk.ERP7__Serial__c);                            SerialWrapper SW = new SerialWrapper();                            SW.SerialNo = new ERP7__Serial_Number__c(Id=stk.ERP7__Serial__c, Name=stk.ERP7__Serial__r.Name);                            SWL.add(SW);                        }                    }
                    Decimal remainingQty = (logline[0].ERP7__Picked_Quantity__c != null && logline[0].ERP7__Picked_Quantity__c > 0) ? logline[0].ERP7__Quantity__c  - logline[0].ERP7__Picked_Quantity__c : logline[0].ERP7__Quantity__c;
                    if(SWL.size() == 0 && remainingQty > 0){
                        set<Id> MoIds = new set<Id>();
                        set<Id> PoIds = new set<Id>();
                        List<ERP7__Manufacturing_Order__c> SOMOs = new List<ERP7__Manufacturing_Order__c>();
                        List<ERP7__PO__c> SOPOs = new List<ERP7__PO__c>();
                        
                        Id OrderId = logline[0].ERP7__Logistic__r.ERP7__Order_S__c;
                        Id OrderProdIds = logline[0].ERP7__Order_Product__c;
                        if(OrderId != null && OrderProdIds != null){                            SOMOs = [Select Id,Name from ERP7__Manufacturing_Order__c where (ERP7__Order_Product__c =:OrderProdIds and ERP7__Order__c =:orderId) and ERP7__Product__c =:logline[0].ERP7__Product__c];
                            System.debug('SOMOs : '+SOMOs.size());    
                        }
                        if(OrderId != null){                            SOPOs = [Select Id,Name from ERP7__PO__c where ERP7__Order__c =:orderId and ERP7__Order__c != null and ERP7__Ready_To_Receive__c =:true];
                            System.debug('SOPOs : '+SOPOs.size());
                            
                        }
                        if(SOMOs.size() > 0 || SOPOs.size() > 0){ 
                            for(ERP7__Manufacturing_Order__c MO : SOMOs) MoIds.add(MO.Id);                            for(ERP7__PO__c PO : SOPOs) PoIds.add(PO.Id);
                            system.debug('MoIds ~>'+MoIds);
                            
                            List<ERP7__Stock_Inward_Line_Item__c> stinlist = [Select Id,Name,Product__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Site_ProductService_InventoryStock__c from ERP7__Stock_Inward_Line_Item__c                                                                               where ERP7__Active__c = true and Product__c =:logline[0].ERP7__Product__c and ERP7__Scrap__c = false AND (ERP7__Purchase_Orders__c IN:PoIds or ERP7__Manufacturing_Order__c IN: MoIds)                                                                               AND ERP7__Quantity__c > 0 AND ERP7__Status__c != 'Awaiting Stock' and ERP7__Site_ProductService_InventoryStock__r.Number_of_Item_In_Stock__c > 0 and ERP7__Site_ProductService_InventoryStock__r.Warehouse__c =: siteId limit 500 ];   //:Integer.valueOf(remainingQty)                          
                            for(ERP7__Stock_Inward_Line_Item__c sin : stinlist){                               if(sin.ERP7__Serial__c != null) {                                    ReservedSerials.add(sin.ERP7__Serial__c);                                    SerialWrapper SW = new SerialWrapper();                                    SW.SerialNo = new ERP7__Serial_Number__c(Id=sin.ERP7__Serial__c, Name=sin.ERP7__Serial__r.Name);                                    SWL.add(SW);                                }                            }                      }
                    }
                    comW.PickSelectedSerialNos = SWL;
                    searchString = '%'+searchString+'%';
                    if(reservedSelectedSerials != Null && reservedSelectedSerials.size() > 0) {
                        ReservedSerials = reservedSelectedSerials;
                    }
                    //added  by shaguftha to fetch only the serials which has stocks
                    Transient List<ERP7__Inventory_Stock__c> inventoryList = [Select Id,Name,ERP7__Serial__c from ERP7__Inventory_Stock__c where ERP7__Serial__c != null and (ERP7__Serial__r.Name like :searchString or ERP7__Serial__r.ERP7__Barcode__c like :searchString) AND ERP7__Product__c=:logline[0].ERP7__Product__c and ERP7__Warehouse__c=:siteId  and ERP7__Number_of_Item_In_Stock__c > 0 limit 1000];
                    Set<Id> stockedSerials = new set<Id>();
                    for(ERP7__Inventory_Stock__c inv : inventoryList){                       stockedSerials.add(inv.ERP7__Serial__c);                    }
                    List<ERP7__Serial_Number__c> serlst = [Select Id,Name,ERP7__Available__c,ERP7__Product__c,ERP7__Barcode__c from ERP7__Serial_Number__c where (Name like :searchString or ERP7__Barcode__c like :searchString) And ERP7__Product__c=:logline[0].ERP7__Product__c and ERP7__Warehouse__c=:siteId  and ERP7__Available__c = true and ERP7__Scrap__c = false and Id Not In :ReservedSerials and Id IN: stockedSerials Limit 1000];
                    if(serlst.size() == 1){                            SerialWrapper SW = new SerialWrapper();                            SW.SerialNo = new ERP7__Serial_Number__c(Id=serlst[0].Id, Name=serlst[0].Name,ERP7__Barcode__c = serlst[0].ERP7__Barcode__c);                            SW.isSelected = true;                            ASWL.add(SW);                    }
                    else{
                        for(ERP7__Serial_Number__c ser : serlst){                            SerialWrapper SW = new SerialWrapper();                            SW.SerialNo = new ERP7__Serial_Number__c(Id=ser.Id, Name=ser.Name,ERP7__Barcode__c = ser.ERP7__Barcode__c);                            ASWL.add(SW);                        }
                    }
                     comW.PickSerialNos = ASWL;
                     if(ASWL.size() == 0 && SWL.size() == 0) comW.exceptionError = 'Serial Number not available'; 
                }
            }
        } catch(exception e){            comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();
        }
        return comW;
    }
    @AuraEnabled
    public static comWrap fetchBatchStocks(String SWL, String SM){
        comWrap comW = new comWrap();
        try {
            Wrappers SW = (Wrappers) JSON.deserialize(SWL, Wrappers .class);
            Map<Id, Id> stockMap = (Map<Id, Id>) JSON.deserialize(SM, Map<Id, Id> .class);
            List<Wrappers> soliWrap = new List<Wrappers>();
            soliWrap.add(SW);
            List<Inventory_Stock__c> WIISList = new List<Inventory_Stock__c>();
            if(soliWrap != null && soliWrap.size() > 0) {
                Wrappers swrap = soliWrap[0];
                if((swrap.addressName == '' || swrap.addressName == null) && swrap.Address.size() > 0) swrap.addressName = swrap.Address[0].value;
                system.debug('swrap.addressName : '+swrap.addressName);
                system.debug('swrap.batchLotCode : '+swrap.batchLotCode);
                if(swrap.batchLotCode != null && swrap.batchLotCode != '' && swrap.batchLotCode != '--None--'){
                    string query = 'Select Id,Name,Product__c,Number_of_Item_In_Stock__c from Inventory_Stock__c where Active__c = true And (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Reserved__c > 0) and ERP7__Batch_Lot__c =\''+swrap.BatchLotCode+'\' ';
                    if(swrap.addressName != null && swrap.addressName != '') query += ' AND (ERP7__Warehouse__c =\'' + String.escapeSingleQuotes(swrap.addressName) + '\' or ERP7__Location__c = \'' + String.escapeSingleQuotes(swrap.addressName) + '\' or ERP7__StorageContainer__c =\'' + String.escapeSingleQuotes(swrap.addressName) + '\' )';
                    query +=' Order By ERP7__Expiry_Date__c ASC';
                    system.debug('query : '+query);
                    WIISList = Database.query(query);
                    Decimal myStock = 0;
                    for(Inventory_Stock__c WIIS : WIISList) {                         if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                    } 
                    List<ERP7__Stock_Outward_Line_Item__c> reservedSTOLI = new List<ERP7__Stock_Outward_Line_Item__c>();
                    if(swrap.addressName != null && swrap.addressName != '') {
                        for(ERP7__Stock_Outward_Line_Item__c SOW:[SELECT Id,ERP7__Quantity__c, ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Logistic_Line_Item__c =: swrap.LOLI.Id AND ERP7__Status__c = 'Reserved' AND ERP7__Quantity__c > 0 AND ERP7__Material_Batch_Lot__c =:swrap.BatchLotCode 
                                                                  and (ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :swrap.addressName or ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c = :swrap.addressName or ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__StorageContainer__c = :swrap.addressName) LIMIT 1]) 
                            reservedSTOLI.add(SOW);
                    }
                    else{ for(ERP7__Stock_Outward_Line_Item__c SOW:[SELECT Id,ERP7__Quantity__c, ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Logistic_Line_Item__c =: swrap.LOLI.Id AND ERP7__Status__c = 'Reserved' AND ERP7__Quantity__c > 0 AND ERP7__Material_Batch_Lot__c =:swrap.BatchLotCode  LIMIT 1])  reservedSTOLI.add(SOW); }
                	Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                    for(ERP7__Stock_Outward_Line_Item__c outward : reservedSTOLI){
                        if(batchAvailStocks.containsKey(outward.ERP7__Material_Batch_Lot__c)) batchAvailStocks.put(outward.ERP7__Material_Batch_Lot__c,(batchAvailStocks.get(outward.ERP7__Material_Batch_Lot__c) + outward.ERP7__Quantity__c));
                        else batchAvailStocks.put(outward.ERP7__Material_Batch_Lot__c,(outward.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c + outward.ERP7__Quantity__c));
                    }
                    if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null && batchAvailStocks.containsKey(swrap.BatchLotCode)) {
                        if(reservedSTOLI.size() > 0) { if(swrap.BatchLotCode == reservedSTOLI[0].ERP7__Material_Batch_Lot__c) swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); }
                        else swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                    }else swrap.inventoryStock = myStock;
                    if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);  
                    else swrap.requiredQty = double.valueof(swrap.remainingQty);
                    if(swrap.requiredQty > 1) swrap.requiredQty = 1;
                }
                comW.soliWrapperList.add(swrap);
            }
        }
        catch(Exception e) { 
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            comW.exceptionError = 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString();
        } 
        return comW;
    }
   /* @AuraEnabled
    public static comWrap fetchBatchStocks(String SWL, String SM){
        comWrap comW = new comWrap();
        try {
            Wrappers SW = (Wrappers) JSON.deserialize(SWL, Wrappers .class);
            Map<Id, Id> stockMap = (Map<Id, Id>) JSON.deserialize(SM, Map<Id, Id> .class);
            List<Wrappers> soliWrap = new List<Wrappers>();
            soliWrap.add(SW);
            List<Inventory_Stock__c> WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            String siteFields = UtilClass.selectStarFromSObject('ERP7__Site__c');         
            utilClass.FLSCheck(siteFields.split(','),'ERP7__Site__c'); 
            String locationsFields = UtilClass.selectStarFromSObject('ERP7__Location__c'); 
            utilClass.FLSCheck(locationsFields.split(','),'ERP7__Location__c');
            String binFields = UtilClass.selectStarFromSObject('ERP7__StorageContainer__c');
            utilClass.FLSCheck(binFields.split(','),'ERP7__StorageContainer__c');
            String warehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');       
            utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c'); 
            if(soliWrap != null && soliWrap.size() > 0) {
                Wrappers swrap = soliWrap[0];
                List<ERP7__Stock_Outward_Line_Item__c> reservedSTOLI = new List<ERP7__Stock_Outward_Line_Item__c>();
                for(ERP7__Stock_Outward_Line_Item__c SOW:[SELECT Id,ERP7__Quantity__c, ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Logistic_Line_Item__c =: swrap.LOLI.Id AND ERP7__Status__c = 'Reserved' AND ERP7__Quantity__c > 0 AND ERP7__Material_Batch_Lot__c =:swrap.BatchLotCode  LIMIT 1])  reservedSTOLI.add(SOW);
                system.debug('swrap.BatchLotCode :'+swrap.BatchLotCode);
                //reservedSTOLI = [SELECT Id,ERP7__Quantity__c, ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Logistic_Line_Item__c =: swrap.LOLI.Id AND ERP7__Status__c = 'Reserved' AND ERP7__Quantity__c > 0 AND ERP7__Material_Batch_Lot__c =:swrap.BatchLotCode  LIMIT 1];//AND ERP7__Material_Batch_Lot__c != null AND ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c > 0
                system.debug('soliWrap[0].addressName : '+soliWrap[0].addressName);
                if((soliWrap[0].addressName == '' || soliWrap[0].addressName == null) && soliWrap[0].Address.size() > 0) soliWrap[0].addressName = soliWrap[0].Address[0].value;
                system.debug('soliWrap[0].addressName after: '+soliWrap[0].addressName);
                system.debug('swrap.AddressName : '+swrap.AddressName);
                if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
                else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
                else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
                else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                system.debug('binList.size() : '+binList.size());
                system.debug('SSLList.size() : '+SSLList.size());
                system.debug('siteList.size() : '+siteList.size());
                if(binList.size() > 0) {                  
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0 and ERP7__Batch_Lot__c =\''+swrap.BatchLotCode+'\') Order By ERP7__Expiry_Date__c ASC'); } 
                    for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    
                    
                    
                    Decimal myStock = 0; 
                    if(soliWrap.size() > 0){
                        List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                      ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c 
                                                                                      ,ERP7__Site_ProductService_InventoryStock__r.ERP7__StorageContainer__c,ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c
                                                                                      From ERP7__Stock_Inward_Line_Item__c
                                                                                      Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                      ERP7__Product__c = :swrap.Product.Id And ERP7__Material_Batch_Lot__c=:swrap.BatchLotCode AND
                                                                                      Active__c = True
                                                                                      Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                        for(Inventory_Stock__c WIIS : WIISList) { 
                            if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                        }   
                        
                        system.debug('myStock 1: '+myStock);
                        
                        Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                        Set<SelectOption> myBatches = new Set<SelectOption>();
                        if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                        for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                            if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                                //batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                                  if(swrap.AddressName != ''  && swrap.AddressName != null  && (swrap.AddressName == InwardLine.ERP7__Site_ProductService_InventoryStock__r.ERP7__StorageContainer__c))batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c);
                                else batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                       
                                myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                            }
                        }
                        if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null && batchAvailStocks.containsKey(swrap.BatchLotCode)) {
                            if(reservedSTOLI.size() > 0) { if(swrap.BatchLotCode == reservedSTOLI[0].ERP7__Material_Batch_Lot__c) swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode)+swrap.loli.ERP7__Quantity__c-swrap.raisedQty; }
                            else swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                            system.debug('inventorystock 1: '+swrap.inventoryStock);
                        }
                        else{ swrap.inventoryStock = myStock;}
                        
                        if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);  
                        else swrap.requiredQty = double.valueof(swrap.remainingQty);
                        if(swrap.requiredQty > 1) swrap.requiredQty = 1;
                        
                    }
                    
                } 
                
                else if(SSLList.size() > 0) {                   
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Reserved__c > 0) and ERP7__Batch_Lot__c =\''+swrap.BatchLotCode+'\') Order By ERP7__Expiry_Date__c ASC'); }
                    for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    system.debug('stockMap : '+stockMap);
                    system.debug('soliWrap : '+soliWrap.size());
                    Decimal myStock = 0;        
                    if(soliWrap.size() > 0) {
                        system.debug('swrap.Product.Id : '+swrap.Product.Id);
                        system.debug('swrap.BatchLotCode : '+swrap.BatchLotCode);
                        List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                      ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c 
                                                                                      ,ERP7__Site_ProductService_InventoryStock__r.ERP7__Location__c,ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c
                                                                                      From ERP7__Stock_Inward_Line_Item__c
                                                                                      Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                      ERP7__Product__c = :swrap.Product.Id And  ERP7__Material_Batch_Lot__c=:swrap.BatchLotCode And
                                                                                      Active__c = True
                                                                                      Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                        for(Inventory_Stock__c WIIS : WIISList) { 
                            if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                        }   
                        system.debug('myStock 2: '+myStock);
                        Set<SelectOption> myBatches = new Set<SelectOption>();
                        Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                        if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                        
                        for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                            if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                                //batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                                 if(swrap.AddressName != ''  && swrap.AddressName != null  && (swrap.AddressName == InwardLine.ERP7__Site_ProductService_InventoryStock__r.ERP7__Location__c)) batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c);
                                else batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                       
                                myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                            }
                        }
                        
                       //if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); }
//else swrap.inventoryStock = myStock;
                        system.debug('batchAvailStocks.size() : '+batchAvailStocks.size());
                        swrap.inventoryStock = 0;
                        if(batchAvailStocks.size() > 0){
                            system.debug('swrap.inventoryStock bfr : '+swrap.inventoryStock);
                            
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null && batchAvailStocks.containsKey(swrap.BatchLotCode)) {
                                system.debug('reservedSTOLI.size() : '+reservedSTOLI.size());
                                if(reservedSTOLI.size() > 0){ if(reservedSTOLI[0].ERP7__Material_Batch_Lot__c != Null && swrap.BatchLotCode == reservedSTOLI[0].ERP7__Material_Batch_Lot__c) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode) + swrap.loli.ERP7__Quantity__c-swrap.raisedQty;  system.debug('swrap.inventoryStock 246: '+swrap.inventoryStock);} }
                                else swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                                system.debug('batchAvailStocks.get(swrap.BatchLotCode) : '+batchAvailStocks.get(swrap.BatchLotCode));
                                system.debug('swrap.inventoryStock 289: '+swrap.inventoryStock);
                            }
                            else{ swrap.inventoryStock = myStock; system.debug('swrap.inventoryStock else: '+swrap.inventoryStock);}
                        }
                        if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);  
                        else swrap.requiredQty = double.valueof(swrap.remainingQty);
                        if(swrap.requiredQty > 1) swrap.requiredQty = 1;
                        
                    }
                    
                } 
                else if(siteList.size() > 0) {
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0 and ERP7__Batch_Lot__c =\''+swrap.BatchLotCode+'\') Order By ERP7__Expiry_Date__c ASC'); }
                    for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    
                    Decimal myStock = 0;        
                    if(soliWrap.size() > 0) {
                        List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                      ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c
                                                                                       ,ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c ,ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c
                                                                                      From ERP7__Stock_Inward_Line_Item__c
                                                                                      Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                      ERP7__Product__c = :swrap.Product.Id And ERP7__Material_Batch_Lot__c = :swrap.BatchLotCode And
                                                                                      Active__c = True
                                                                                      Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                        for(Inventory_Stock__c WIIS : WIISList) {
                            if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                        }
                        system.debug('myStock 3: '+myStock);
                        Set<SelectOption> myBatches = new Set<SelectOption>();
                        Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                        if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                        for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                            if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                                myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                //batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                                if(swrap.AddressName != ''  && swrap.AddressName != null  && (swrap.AddressName == InwardLine.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c ))batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c);
                                else batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                       
                            }
                        }   
                        if(swrap.requiredQty >= myStock) swrap.requiredQty = double.valueof(myStock);  
                        else if(swrap.SOLI != null) swrap.requiredQty = (swrap.MRP.Id == Null) ? double.valueof(swrap.SOLI.Quantity__c) : double.valueof(swrap.MRP.Total_Amount_Required__c);
                        else if(swrap.OLI != null) swrap.requiredQty = (swrap.MRP.Id == Null) ? double.valueof(swrap.OLI.Quantity) : double.valueof(swrap.MRP.Total_Amount_Required__c);
                        
                        //if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { 
//swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
//}
//else swrap.inventoryStock = myStock;
                        
                        
                        
                        //List<Inventory_Stock__c> inventoryList=[Select Id,Name,ERP7__Number_of_Item_In_Stock__c from Inventory_Stock__c where Active__c = true And Number_of_Item_In_Stock__c >= 0  Order By ERP7__Expiry_Date__c ASC];
                      //if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) {
//if(swrap.BatchLotCode == reservedSTOLI.ERP7__Material_Batch_Lot__c) swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode)+swrap.loli.ERP7__Quantity__c-swrap.raisedQty;
//else swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
//}
//else{ swrap.inventoryStock = myStock;}
                        //*****************new changes for stock outward*************************
                        ERP7__Batch__c batch=new ERP7__Batch__c();
                        system.debug('reservedSTOLI.size() : '+reservedSTOLI.size());
                        if(reservedSTOLI.size() == 0 && swrap.BatchLotCode != '' && swrap.BatchLotCode != null) batch=[Select Id,Name,ERP7__Available_Quantity__c from ERP7__Batch__c where Id =:swrap.BatchLotCode];
                        
                        system.debug('batch : '+batch);
                        if(batchAvailStocks.size() > 0){
                            system.debug('swrap.inventoryStock bfr : '+swrap.inventoryStock);
                            swrap.inventoryStock = 0;
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null && batchAvailStocks.containsKey(swrap.BatchLotCode)) {
                                system.debug('reservedSTOLI.size() : '+reservedSTOLI.size());
                                system.debug('batchAvailStocks.get(swrap.BatchLotCode) : '+batchAvailStocks.get(swrap.BatchLotCode));
                                if(reservedSTOLI.size() > 0){ 
                                    system.debug('reservedSTOLI[0].ERP7__Material_Batch_Lot__c : '+reservedSTOLI[0].ERP7__Material_Batch_Lot__c); 
                                    system.debug('swrap.BatchLotCode : '+swrap.BatchLotCode); 
                                    if(reservedSTOLI[0].ERP7__Material_Batch_Lot__c != Null && swrap.BatchLotCode == reservedSTOLI[0].ERP7__Material_Batch_Lot__c) { 
                                        system.debug('swrap.loli.ERP7__Quantity__c : '+swrap.loli.ERP7__Quantity__c);
                                        system.debug('swrap.raisedQty : '+swrap.raisedQty);
                                        swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode)+swrap.loli.ERP7__Quantity__c-swrap.raisedQty;  
                                        system.debug('swrap.inventoryStock 246: '+swrap.inventoryStock);
                                    } 
                                }
                                else swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                                system.debug('batchAvailStocks.get(swrap.BatchLotCode) : '+batchAvailStocks.get(swrap.BatchLotCode));
                                system.debug('swrap.inventoryStock 289: '+swrap.inventoryStock);
                            }
                            else{ swrap.inventoryStock = myStock; system.debug('swrap.inventoryStock else: '+swrap.inventoryStock);}
                        }
                        
                       //
                       // if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) {
                       //     if(reservedSTOLI.size() > 0) if(swrap.BatchLotCode == reservedSTOLI[0].ERP7__Material_Batch_Lot__c) swrap.inventoryStock = reservedSTOLI[0].ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c+reservedSTOLI[0].ERP7__Quantity__c;   //-swrap.raisedQty
                        //    else swrap.inventoryStock = batch.ERP7__Available_Quantity__c;
                        //    system.debug('swrap.inventoryStock 3: '+swrap.inventoryStock);
                       // }
                       // else{ swrap.inventoryStock = myStock; }
                        //
                        
                        if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);  
                        else swrap.requiredQty = double.valueof(swrap.remainingQty);
                        
                        if(swrap.requiredQty > 1) swrap.requiredQty = 1;
                        
                        if(swrap.soli !=null){ 
                            if(swrap.soli.Order_Line_Status__c == 'Reserved' && swrap.inventoryStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = swrap.inventoryStock+swrap.SOLI.Quantity__c-swrap.raisedQty; 
                            else if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                        }                        
                        else if(swrap.oli !=null){ 
                            if(swrap.oli.Order_Line_Status__c == 'Reserved' && swrap.inventoryStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = swrap.inventoryStock+swrap.OLI.Quantity-swrap.raisedQty; 
                            else if(swrap.oli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;
                        }
                    }
                } 
                comW.soliWrapperList.add(swrap);
                
            }              
        } catch(Exception e) { 
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            comW.exceptionError = 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString();
        } 
        return comW;
    }
    */
    
        @AuraEnabled
    public static comWrap fetchBinStocks(String SWL, String SM){
        comWrap comW = new comWrap();
        try {
            Wrappers SW = (Wrappers) JSON.deserialize(SWL, Wrappers .class);
            Map<Id, Id> stockMap = (Map<Id, Id>) JSON.deserialize(SM, Map<Id, Id> .class);
            List<Wrappers> soliWrap = new List<Wrappers>();
            soliWrap.add(SW);
            List<Inventory_Stock__c> WIISList = new List<Inventory_Stock__c>();
            if(soliWrap != null && soliWrap.size() > 0) {
                Wrappers swrap = soliWrap[0];
                if((swrap.addressName == '' || swrap.addressName == null) && swrap.Address.size() > 0) swrap.addressName = swrap.Address[0].value;
                system.debug('swrap.addressName : '+swrap.addressName);
                system.debug('swrap.batchLotCode : '+swrap.batchLotCode);
                if(!swrap.LOLI.ERP7__Product__r.ERP7__Serialise__c && swrap.batchLotCode != null && swrap.batchLotCode != '' && swrap.batchLotCode != '--None--'){
                    string query = 'Select Id,Name,Product__c,Number_of_Item_In_Stock__c from Inventory_Stock__c where Active__c = true And (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Reserved__c > 0) and ERP7__Batch_Lot__c =\''+swrap.BatchLotCode+'\' ';
                    if(swrap.addressName != null && swrap.addressName != '') query += ' AND (ERP7__Warehouse__c =\'' + String.escapeSingleQuotes(swrap.addressName) + '\' or ERP7__Location__c = \'' + String.escapeSingleQuotes(swrap.addressName) + '\' or ERP7__StorageContainer__c =\'' + String.escapeSingleQuotes(swrap.addressName) + '\' )';
                    query +=' Order By ERP7__Expiry_Date__c ASC';
                    WIISList = Database.query(query);
                    Decimal myStock = 0;                    for(Inventory_Stock__c WIIS : WIISList) {                         if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;                      } 
                    system.debug('myStock : '+myStock);
                    List<ERP7__Stock_Outward_Line_Item__c> reservedSTOLI = new List<ERP7__Stock_Outward_Line_Item__c>();
                    if(swrap.addressName != null && swrap.addressName != '') {
                        for(ERP7__Stock_Outward_Line_Item__c SOW:[SELECT Id,ERP7__Quantity__c, ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Logistic_Line_Item__c =: swrap.LOLI.Id AND ERP7__Status__c = 'Reserved' AND ERP7__Quantity__c > 0 AND ERP7__Material_Batch_Lot__c =:swrap.BatchLotCode 
                                                                  and (ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :swrap.addressName or ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c = :swrap.addressName or ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__StorageContainer__c = :swrap.addressName) LIMIT 1]) 
                            reservedSTOLI.add(SOW);
                    }
                    else{ for(ERP7__Stock_Outward_Line_Item__c SOW:[SELECT Id,ERP7__Quantity__c, ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Logistic_Line_Item__c =: swrap.LOLI.Id AND ERP7__Status__c = 'Reserved' AND ERP7__Quantity__c > 0 AND ERP7__Material_Batch_Lot__c =:swrap.BatchLotCode  LIMIT 1])  reservedSTOLI.add(SOW); }
                	Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                    for(ERP7__Stock_Outward_Line_Item__c outward : reservedSTOLI){
                        if(batchAvailStocks.containsKey(outward.ERP7__Material_Batch_Lot__c)) batchAvailStocks.put(outward.ERP7__Material_Batch_Lot__c,(batchAvailStocks.get(outward.ERP7__Material_Batch_Lot__c) + outward.ERP7__Quantity__c));
                        else batchAvailStocks.put(outward.ERP7__Material_Batch_Lot__c,(outward.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c + outward.ERP7__Quantity__c));
                    }
                    if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null && batchAvailStocks.containsKey(swrap.BatchLotCode)) {
                        if(reservedSTOLI.size() > 0) { if(swrap.BatchLotCode == reservedSTOLI[0].ERP7__Material_Batch_Lot__c) swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); }
                        else swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                    }else swrap.inventoryStock = myStock;
                    if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);  
                    else swrap.requiredQty = double.valueof(swrap.remainingQty);
                    if(swrap.requiredQty > 1) swrap.requiredQty = 1;
                }
               else if(swrap.LOLI.ERP7__Product__r.ERP7__Serialise__c){                    String SerialID = swrap.SerialNumbers.ERP7__Serial__c;
                    string query = 'Select Id,Name,Product__c,Number_of_Item_In_Stock__c from Inventory_Stock__c where Active__c = true And (Number_of_Item_In_Stock__c > 0) ';
                    if(SerialID != null && SerialID != '')  query += ' AND ERP7__Serial__c =\'' + String.escapeSingleQuotes(SerialID) + '\' ';
                    if(swrap.addressName != null && swrap.addressName != '') query += ' AND (ERP7__Warehouse__c =\'' + String.escapeSingleQuotes(swrap.addressName) + '\' or ERP7__Location__c = \'' + String.escapeSingleQuotes(swrap.addressName) + '\' or ERP7__StorageContainer__c =\'' + String.escapeSingleQuotes(swrap.addressName) + '\' )';
                    query +=' Order By ERP7__Expiry_Date__c ASC';
                    system.debug('serial query : '+query);
                    WIISList = Database.query(query);                    Decimal myStock = 0;
                    for(Inventory_Stock__c WIIS : WIISList) {                         if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  
                    }
                    system.debug('Serial stock : '+myStock);
                    swrap.inventoryStock = myStock;
                    if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);  
                    else swrap.requiredQty = double.valueof(swrap.remainingQty);
                    if(swrap.requiredQty > 1) swrap.requiredQty = 1;
                }
                else if(!swrap.LOLI.ERP7__Product__r.ERP7__Serialise__c && !swrap.LOLI.ERP7__Product__r.ERP7__Lot_Tracked__c){
                    string query = 'Select Id,Name,Product__c,Number_of_Item_In_Stock__c from Inventory_Stock__c where Active__c = true And (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Reserved__c > 0) ';
                    if(swrap.addressName != null && swrap.addressName != '') query += ' AND (ERP7__Warehouse__c =\'' + String.escapeSingleQuotes(swrap.addressName) + '\' or ERP7__Location__c = \'' + String.escapeSingleQuotes(swrap.addressName) + '\' or ERP7__StorageContainer__c =\'' + String.escapeSingleQuotes(swrap.addressName) + '\' )';
                    query +=' Order By ERP7__Expiry_Date__c ASC';
                    system.debug('normal query : '+query);
                    WIISList = Database.query(query);                    Decimal myStock = 0;
                    for(Inventory_Stock__c WIIS : WIISList) {                         if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  
                    }
                    system.debug('normal stock : '+myStock);
                    List<ERP7__Stock_Outward_Line_Item__c> reservedSTOLI = new List<ERP7__Stock_Outward_Line_Item__c>();
                    if(swrap.addressName != null && swrap.addressName != '') {
                        for(ERP7__Stock_Outward_Line_Item__c SOW:[SELECT Id,ERP7__Quantity__c, ERP7__Product__c,ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Logistic_Line_Item__c =: swrap.LOLI.Id AND ERP7__Status__c = 'Reserved' AND ERP7__Quantity__c > 0 
                                                                  and (ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :swrap.addressName or ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c = :swrap.addressName or ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__StorageContainer__c = :swrap.addressName)]) 
                            reservedSTOLI.add(SOW);
                    }
                    else{ for(ERP7__Stock_Outward_Line_Item__c SOW:[SELECT Id,ERP7__Quantity__c, Product__c,ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Logistic_Line_Item__c =: swrap.LOLI.Id AND ERP7__Status__c = 'Reserved' AND ERP7__Quantity__c >0 ])  reservedSTOLI.add(SOW); }
                	Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                    for(ERP7__Stock_Outward_Line_Item__c outward : reservedSTOLI){
                        if(batchAvailStocks.containsKey(outward.Product__c)) batchAvailStocks.put(outward.Product__c,(batchAvailStocks.get(outward.Product__c) + outward.ERP7__Quantity__c));
                        else batchAvailStocks.put(outward.Product__c,outward.ERP7__Quantity__c);
                    }
                    if(reservedSTOLI.size() > 0) { if(swrap.Product.Id  == reservedSTOLI[0].Product__c) swrap.inventoryStock = batchAvailStocks.get(swrap.Product.Id) + myStock; }
                    else swrap.inventoryStock = myStock;
                    if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = double.valueof(swrap.inventoryStock);  
                    else swrap.requiredQty = double.valueof(swrap.remainingQty);
                    if(swrap.requiredQty > 1) swrap.requiredQty = 1;
                }
                comW.soliWrapperList.add(swrap);
            }
        }
        catch(Exception e) { 
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            comW.exceptionError = 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString();
        } 
        return comW;
    }
    //added by matheen
    @AuraEnabled
    public static String getAddressIdByBarcode(String barcode) {
        try {
            System.debug('Querying for barcode: ' + barcode);
            List<Site__c> sites = [SELECT Id FROM Site__c WHERE Barcode__c = :barcode AND Active__c = TRUE LIMIT 1];
            System.debug('Sites found: ' + sites);
            if (!sites.isEmpty()) {                return sites[0].Id;
            }
            List<Location__c> locations = [SELECT Id FROM Location__c WHERE Barcode__c = :barcode AND Active__c = TRUE LIMIT 1];
            System.debug('Locations found: ' + locations);
            if (!locations.isEmpty()) {                return locations[0].Id;
            }
            List<StorageContainer__c> bins = [SELECT Id FROM StorageContainer__c WHERE Barcode__c = :barcode AND Active__c = TRUE LIMIT 1];
            System.debug('Bins found: ' + bins);
            if (!bins.isEmpty()) {
                return bins[0].Id;
            }
            return null; // No matching record found
        } catch (Exception e) {
            System.debug('Exception in getAddressIdByBarcode: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            throw new AuraHandledException('Error in getAddressIdByBarcode: ' + e.getMessage());
        }
    }
  /*  @AuraEnabled
    public static comWrap fetchBinStocks(String SWL, String SM){
        comWrap comW = new comWrap();
        // try {
        Wrappers SW = (Wrappers) JSON.deserialize(SWL, Wrappers .class);
        Map<Id, Id> stockMap = (Map<Id, Id>) JSON.deserialize(SM, Map<Id, Id> .class);
        List<Wrappers> soliWrap = new List<Wrappers>();
        soliWrap.add(SW);
        List<Inventory_Stock__c> WIISList = new List<Inventory_Stock__c>();
        List<Site__c> siteList = new List<Site__c>();                        
        List<Location__c> SSLList = new List<Location__c>();
        List<StorageContainer__c> binList = new List<StorageContainer__c>();
        String siteFields = UtilClass.selectStarFromSObject('ERP7__Site__c');         
        utilClass.FLSCheck(siteFields.split(','),'ERP7__Site__c'); 
        String locationsFields = UtilClass.selectStarFromSObject('ERP7__Location__c'); 
        utilClass.FLSCheck(locationsFields.split(','),'ERP7__Location__c');
        String binFields = UtilClass.selectStarFromSObject('ERP7__StorageContainer__c');
        utilClass.FLSCheck(binFields.split(','),'ERP7__StorageContainer__c');
        String warehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');       
        utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c'); 
        if(soliWrap != null && soliwrap.size() > 0) {
            Wrappers swrap = soliWrap[0];
            if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
            else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
            if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
            else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
            if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
            else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
            if(binList.size() > 0) {   
                if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                else { 
                    String query = 'select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) ';
                   	if(swrap.batchLotCode != '' && swrap.batchLotCode != null) query += ' AND ERP7__Batch_Lot__c =\'' + String.escapeSingleQuotes(swrap.batchLotCode) + '\' ';
                    query += ' Order By ERP7__Expiry_Date__c ASC';
                    WIISList = Database.query(query); 
                } 
                for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                
                Decimal myStock = 0; //solis.MRP.MRP_Product__r.Item_Description__c != null && solis.MRP.Id != null
                
                if(soliWrap.size() > 0) {
                    List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                  ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c 
                                                                                  From ERP7__Stock_Inward_Line_Item__c
                                                                                  Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                  ERP7__Product__c = :swrap.Product.Id And
                                                                                  Active__c = True
                                                                                  Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                    for(Inventory_Stock__c WIIS : WIISList) { 
                        if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                    }   
                    
                    
                    
                    Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                    Set<SelectOptions> myBatches = new Set<SelectOptions>();
                    if((!swrap.Product.ERP7__Lot_Tracked__c == true )) myBatches.add(new SelectOptions('','--None--'));
                    
                    for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                        if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                            batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                            myBatches.add(new SelectOptions(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                        }
                    }
                    if(swrap.requiredQty >= myStock) swrap.requiredQty = double.valueof(myStock);  
                    else if(swrap.SOLI!=null){
                        swrap.requiredQty = (swrap.MRP.Id == Null) ? double.valueof(swrap.SOLI.Quantity__c) : double.valueof(swrap.MRP.Total_Amount_Required__c);
                    }
                    else if(swrap.OLI!=null){ swrap.requiredQty = (swrap.MRP.Id == Null) ? double.valueof(swrap.OLI.Quantity) : double.valueof(swrap.MRP.Total_Amount_Required__c); }
                    swrap.inventoryStock = myStock; swrap.binName = swrap.addressName;
                    swrap.locationName = binList[0].Location__c; swrap.warehouseName = binList[0].Site__c;
                    swrap.WN = binList[0].Site__r.Name; swrap.LN = binList[0].Location__r.Name;
                    swrap.BatchLotCodes = new List<SelectOptions>();
                    swrap.BatchLotCodes.addAll(myBatches);
                    if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){
                        if(swrap.BatchLotCode != '' && swrap.BatchLotCode != null){
                           swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); 
                        }
                        else{
                            swrap.BatchLotCode = swrap.BatchLotCodes[0].value;
                            swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].value);
                        }   
                    }
                    else swrap.BatchLotCode = '';
                }
                
            } 
            else if(SSLList.size() > 0) {  
                //Changes started here from imran for polymem fix
                String loliId = (swrap.LOLI.Id != Null)? swrap.LOLI.Id : '';
                Set<Id> WIISIds = new Set<Id>();
                List<ERP7__Stock_Outward_Line_Item__c> pplis = Database.query('Select Id, Name, Site_Product_Service_Inventory_Stock__c,ERP7__Site_Product_Service_Inventory_Stock__r.Location__c,ERP7__Quantity__c, ERP7__Logistic_Line_Item__c,ERP7__Status__c,ERP7__Material_Batch_Lot__c From Stock_Outward_Line_Item__c Where ERP7__Logistic_Line_Item__c != null and ERP7__Logistic_Line_Item__c = :loliId ');
                system.debug('pplis : '+pplis.size());
                Map<Id,Decimal> BatchStock = new Map<Id,Decimal>();
                for(ERP7__Stock_Outward_Line_Item__c ppli: pplis) {
                    WIISIds.add(ppli.Site_Product_Service_Inventory_Stock__c);
                    if(ppli.ERP7__Status__c == 'Reserved' && ppli.ERP7__Material_Batch_Lot__c != null && ppli.ERP7__Site_Product_Service_Inventory_Stock__r.Location__c == SSLList[0].Id){
                        if(BatchStock.containsKey(ppli.ERP7__Material_Batch_Lot__c)) BatchStock.put(ppli.ERP7__Material_Batch_Lot__c,(BatchStock.get(ppli.ERP7__Material_Batch_Lot__c) + ppli.ERP7__Quantity__c));
                        else BatchStock.put(ppli.ERP7__Material_Batch_Lot__c,ppli.ERP7__Quantity__c);
                    } 
                }
                //Changes ended here imran 
                
                if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label)); 
                else { 
                    String query = 'select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And (ERP7__Number_of_Item_In_Stock__c > 0 Or Id In :WIISIds) And Active__c = true ) ';
                    if(swrap.batchLotCode != '' && swrap.batchLotCode != null) query += ' AND ERP7__Batch_Lot__c =\'' + String.escapeSingleQuotes(swrap.batchLotCode) + '\' ';
                    query +=' Order By ERP7__Expiry_Date__c ASC';
                    WIISList = Database.query(query); 
                }
                
                for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                
                Decimal myStock = 0;        
                if(soliWrap.size() > 0) {
                    
                    List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                  ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c 
                                                                                  From ERP7__Stock_Inward_Line_Item__c
                                                                                  Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                  ERP7__Product__c = :swrap.Product.Id And
                                                                                  Active__c = True
                                                                                  Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                    for(Inventory_Stock__c WIIS : WIISList) { 
                        if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                    }   
                    Set<SelectOptions> myBatches = new Set<SelectOptions>();
                    Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                    if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOptions('','--None--'));
                    for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                        if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                            if(BatchStock.containsKey(InwardLine.ERP7__Material_Batch_Lot__c)){
                                if(!batchAvailStocks.containsKey(InwardLine.ERP7__Material_Batch_Lot__c)) myBatches.add(new SelectOptions(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c, (InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c + BatchStock.get(InwardLine.ERP7__Material_Batch_Lot__c)));
                           
                            }
                            else{
                                if(!batchAvailStocks.containsKey(InwardLine.ERP7__Material_Batch_Lot__c)) myBatches.add(new SelectOptions(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c, InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                            }
                        }
                    }
                    if(swrap.requiredQty >= myStock) swrap.requiredQty = double.valueof(myStock);  
                    else if(swrap.SOLI!=null) swrap.requiredQty = (swrap.MRP.Id == Null) ? double.valueof(swrap.SOLI.Quantity__c) : double.valueof(swrap.MRP.Total_Amount_Required__c);
                    else if(swrap.OLI!=null){ swrap.requiredQty = (swrap.MRP.Id == Null) ? double.valueof(swrap.OLI.Quantity) : double.valueof(swrap.MRP.Total_Amount_Required__c); }
                    swrap.inventoryStock = myStock; swrap.binName = null;
                    swrap.locationName = SSLList[0].Id; swrap.warehouseName = SSLList[0].Site__c;
                    swrap.WN = SSLList[0].Site__r.Name; swrap.LN = SSLList[0].Name; 
                    swrap.BatchLotCodes = new List<SelectOptions>(); swrap.BatchLotCodes.addAll(myBatches);
                    if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){
                         if(swrap.batchLotCode != '' && swrap.batchLotCode != null){
                           swrap.inventoryStock = batchAvailStocks.get(swrap.batchLotCode); 
                        }
                        else{
                            swrap.batchLotCode = swrap.BatchLotCodes[0].value;
                            swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].value);
                        }
                    }
                    else swrap.BatchLotCode = ''; 
                    
                }
                
            } 
            else if(siteList.size() > 0) {
                if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                else { 
                    String query = 'select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) ';
                    if(swrap.batchLotCode != '' && swrap.batchLotCode != null) query += ' AND ERP7__Batch_Lot__c =\'' + String.escapeSingleQuotes(swrap.batchLotCode) + '\' ';
                    query += ' Order By ERP7__Expiry_Date__c ASC';
                    WIISList = Database.query(query); }
                for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                Decimal myStock = 0;        
                if(soliWrap.size() > 0) {
                    List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                  ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c
                                                                                  From ERP7__Stock_Inward_Line_Item__c
                                                                                  Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                  ERP7__Product__c = :swrap.Product.Id And
                                                                                  Active__c = True
                                                                                  Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                    for(Inventory_Stock__c WIIS : WIISList) { 
                        if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                    }
                    Set<SelectOptions> myBatches = new Set<SelectOptions>();
                    Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                    if(swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOptions('','--None--'));
                    for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                        if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                            myBatches.add(new SelectOptions(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                            batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                        }
                    } 
                    if(swrap.requiredQty >= myStock) swrap.requiredQty = double.valueof(myStock);  
                    else if(swrap.SOLI!=null) swrap.requiredQty = (swrap.MRP.Id == Null) ? double.valueof(swrap.SOLI.Quantity__c) : double.valueof(swrap.MRP.Total_Amount_Required__c);
                    else if(swrap.OLI!=null){ swrap.requiredQty = (swrap.MRP.Id == Null) ? double.valueof(swrap.OLI.Quantity) : double.valueof(swrap.MRP.Total_Amount_Required__c); }
                    if(swrap.soli!=null){
                        if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = myStock+swrap.SOLI.Quantity__c-swrap.raisedQty; 
                        else if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                        else swrap.inventoryStock = myStock;}
                    else if (swrap.oli!=null){
                        if(swrap.oli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = myStock+swrap.OLI.Quantity-swrap.raisedQty; 
                        else if(swrap.oli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                        else swrap.inventoryStock = myStock;                            
                    }
                    swrap.binName = null; swrap.locationName = null; swrap.warehouseName = siteList[0].Id;
                    swrap.WN = siteList[0].Name; swrap.LN = '';
                    swrap.BatchLotCodes = new List<SelectOptions>(); swrap.BatchLotCodes.addAll(myBatches);
                    
                    if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true ){
                         if(swrap.batchLotCode != '' && swrap.batchLotCode != null){
                           swrap.inventoryStock = batchAvailStocks.get(swrap.batchLotCode); 
                        }
                        else{
                            if(swrap.BatchLotCodes[0].value != null && swrap.BatchLotCodes[0].value != '')
                            { 
                                swrap.batchLotCode = swrap.BatchLotCodes[0].value;
                                swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].value); 
                            }
                        }
                    }
                    else swrap.batchLotCode = '';
                    
                }
            } 
            comW.soliWrapperList.add(swrap);
        }              
        // } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber() +'Cause : '+e.getCause(); } 
        return comW;
    }*/
    
    @AuraEnabled
    public static comWrap saveSOLIs(String SWL, String SE, String SM, String LogisticIds){
        comWrap comW = new comWrap();
        String errorMsg = '';
        try {
            List<Wrappers> soliWrapperList = (List<Wrappers>) JSON.deserialize(SWL, List<Wrappers> .class);
            List<Id> SerialIds2Exempt = (List<Id>) JSON.deserialize(SE, List<Id> .class);
            Map<Id, Id> stockMap = (Map<Id, Id>) JSON.deserialize(SM, Map<Id, Id> .class);
            
            Boolean error = false;
            List<Id> soliIds = new List<Id>();
            List<Id> lineIds = new List<Id>();
            List<Id> logIds = new List<Id>();
            List<Id> assetIds = new List<Id>();
            set<Id> prodIds = new set<Id>();
            List<Wrappers> soliSelectedWrapperList = new List<Wrappers>();
            List<Stock_Outward_Line_Item__c> PPLIList = new List<Stock_Outward_Line_Item__c>();
            List<Stock_Outward_Line_Item__c> ppliItemList = new List<Stock_Outward_Line_Item__c>(); 
            List<Id> SerialIds2Update = new List<Id>();
            Map<Id,Id> SerialStock2Inward = new Map<Id,Id>();
            
            String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
            utilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');
            Map<Id,ERP7__Serial_Number__c> SerialMap = new Map<Id,ERP7__Serial_Number__c>();
            
            system.debug('soliWrapperList size~>'+soliWrapperList.size());
            set<Id> siteAddress = new set<Id>();
            Map<string,String>  SelectedbatchLotCode = new Map<string,String>();
            if(soliWrapperList.size() > 0) {          
                for(Wrappers wrap : soliWrapperList) {
                    if(wrap.soliSelected == true) { 
                        if(wrap.SerialNumbers.Fixed_Asset__c != Null) assetIds.add(wrap.SerialNumbers.Fixed_Asset__c);  
                        if(wrap.loli.Sales_Order_Line_Item__c != Null) lineIds.add(wrap.loli.Sales_Order_Line_Item__c);
                        system.debug('lineIds 1: '+lineIds);
                        if(wrap.loli.ERP7__Order_Product__c != Null) lineIds.add(wrap.loli.ERP7__Order_Product__c); 
                        system.debug('lineIds 5: '+lineIds);
                        if(wrap.loli.Work_Order_Line_Items__c != Null) lineIds.add(wrap.loli.Work_Order_Line_Items__c); 
                        system.debug('lineIds 4: '+lineIds);
                        if(wrap.loli.ERP7__Purchase_Line_Items__c != Null) lineIds.add(wrap.loli.ERP7__Purchase_Line_Items__c); 
                        system.debug('lineIds 3: '+lineIds);
                        if(wrap.loli.Transfer_Order_Line_Item__c != Null) lineIds.add(wrap.loli.Transfer_Order_Line_Item__c); 
                        system.debug('lineIds 2: '+lineIds);
                        if(wrap.loli != null && wrap.loli.Id != null)  { logIds.add(wrap.loli.Id);  soliIds.add(wrap.loli.Id); }
                        if(wrap.loli.ERP7__Product__c != null) prodIds.add(wrap.loli.ERP7__Product__c);
                        system.debug('logIds 1: '+logIds);
                       
                         if(wrap.loli != null) soliSelectedWrapperList.add(wrap); 
                        if(wrap.AddressName != null && wrap.AddressName != '')  siteAddress.add(wrap.AddressName);
                        if(wrap.batchLotCode != null && wrap.batchLotCode != '') SelectedbatchLotCode.put(wrap.Product.Id,wrap.batchLotCode);
                    } 
                }
                system.debug('siteAddress : '+siteAddress);
                system.debug('logIds : '+logIds.size());
                
                if(soliSelectedWrapperList.size() > 0) {                     errorMsg = '';
                    List <ERP7__Serial_Number__c> SNS = new List <ERP7__Serial_Number__c>();
                    for(Wrappers wrap : soliSelectedWrapperList) {                        if(wrap.inventoryStock == 0) { errorMsg = 'Sorry, no available inventory for the selected item to proceed.'; error = true; break; }                              else if(wrap.requiredQty > wrap.inventoryStock) { errorMsg = 'Quantity cannot be greater than available stock.'; error = true; break; }                        else if(wrap.requiredQty > wrap.remainingQty) { errorMsg = 'Quantity cannot be greater than remaining Quantity.'; error = true; break; }                        else if(wrap.LOLI.Product__r.Serialise__c && wrap.SerialNumbers.ERP7__Serial__c == Null && wrap.MultiSerialIds.size() == 0) { errorMsg = 'Required field missing - Serial Number'; error = true; break; }
                        
                        if(wrap.MultiSerialIds.size() > 0){                            SerialIds2Update.addAll(wrap.MultiSerialIds);                        }                       else if(wrap.LOLI.Product__r.Serialise__c && (wrap.SerialNumbers.ERP7__Serial__c != Null)) {                            SerialIds2Update.add(wrap.SerialNumbers.ERP7__Serial__c);                        }                     }
                    if(SerialIds2Update.size() > 0){
                        SNS = [Select Id, Name, ERP7__Available__c,ERP7__Material_Batch_Lot__c From ERP7__Serial_Number__c Where Id In : SerialIds2Update];
                        for(ERP7__Serial_Number__c SN : SNS){ 
                            if(!SN.ERP7__Available__c && !SerialIds2Exempt.contains(SN.Id)){ errorMsg = 'Serial Number unavailable'; error = true; break; }
                            else SerialMap.put(SN.Id,SN);
                        }
                        //Added below by Arshad by 14 Aug 2023
                        List<ERP7__Inventory_Stock__c> SerialInventoryStocks = [SELECT Id, Name, ERP7__Serial__c, ERP7__Warehouse__c FROM ERP7__Inventory_Stock__c   
                                                                                Where ERP7__Serial__c != null AND ERP7__Warehouse__c != null AND ERP7__Serial__c In: SerialIds2Update                                                                                
                                                                                AND ERP7__Active__c = True];

                        for(ERP7__Inventory_Stock__c SI : SerialInventoryStocks){                             SerialStock2Inward.put(SI.ERP7__Serial__c,SI.Id);                        }
                        
                        //Commented by Arshad by 14 Aug 2023
                        /*
                        List<ERP7__Stock_Inward_Line_Item__c> SerialInwards = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Serial__c, ERP7__Serial__r.ERP7__Available__c,
                                                                               ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c, Fixed_Asset__c, Fixed_Asset__r.Product__c, ERP7__Material_Batch_Lot__r.ERP7__Production_Version__c
                                                                               From ERP7__Stock_Inward_Line_Item__c
                                                                               Where ERP7__Serial__c In: SerialIds2Update And
                                                                               Active__c = True];
                        for(ERP7__Stock_Inward_Line_Item__c SI : SerialInwards){ 
                            SerialStock2Inward.put(SI.ERP7__Serial__c,SI.ERP7__Site_ProductService_InventoryStock__c);
                        }
                        */
                    }
                    
                    if(!error) {
                        if(lineIds.size() > 0) {                            string query = 'select ' + String.escapeSingleQuotes(PPLIFields) + ' , ERP7__Serial__r.Name from Stock_Outward_Line_Item__c where ((ERP7__Order_Product__c IN : lineIds Or Sales_Order_Line_Item__c In : lineIds Or Work_Order_Line_Items__c In : lineIds Or ERP7__Purchase_Line_Items__c In : lineIds Or Transfer_Order_Line_Item__c In : lineIds) and Picked_Date__c = null and ERP7__Logistic_Line_Item__c In :logIds) and ERP7__Quantity__c > 0';
                            //if(siteAddress.size() > 0) query += '  AND (ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c IN : siteAddress or ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c IN : siteAddress)';
                            //if(SelectedbatchLotCode.size() > 0) query += '  AND (ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c IN : siteAddress or ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c IN : siteAddress)';
                            ppliItemList = Database.query(query); 
                        } 
                        MAP<Id, ERP7__Logistic_Line_Item__c > soliMap = new MAP<Id, ERP7__Logistic_Line_Item__c >();
                        MAP<Id, MRP__c> mrpMap = new MAP<Id, MRP__c>();                        MAP<Id, Asset__c> assetMap = new MAP<Id, Asset__c>();                        List<Id> serialIds = new List<Id>();                        set<String> AssignedBatchIds = new set<String>();
                        if(assetIds.size() > 0) assetMap = new MAP<Id, Asset__c>([Select Id, Name, Active__c, Barcode__c, Serialise__c, Status__c From Asset__c Where Id In :assetIds]);
                        if(ppliItemList.size() > 0){                            for(Stock_Outward_Line_Item__c stk : ppliItemList){                                if(stk.ERP7__Material_Batch_Lot__c != null) AssignedBatchIds.add(stk.ERP7__Material_Batch_Lot__c);
                            }
                            //ik
                            Set<Id> batIds = new Set<Id>();                            Map<Id, ERP7__Inventory_Stock__c> BatchStock_Map = new Map<Id, ERP7__Inventory_Stock__c>();                             Map<Id, ERP7__Inventory_Stock__c> LocStock_Map = new Map<Id, ERP7__Inventory_Stock__c>();
                            for(Wrappers wrap : soliSelectedWrapperList){                                if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '' && wrap.LOLI.Product__r.ERP7__Lot_Tracked__c){                                    batIds.add(wrap.BatchLotCode);
                                }
                            }
                            //if(batIds.size() > 0){
                                //List<ERP7__Inventory_Stock__c> batchInventories = [Select Id, Name, ERP7__Batch_Lot__c, ERP7__Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Inventory_Stock__c WHERE ERP7__Batch_Lot__c != null AND ERP7__Batch_Lot__r.ERP7__Available_Quantity__c > 0 AND ERP7__Batch_Lot__c In :batIds];
                            string query = 'Select Id, Name,ERP7__Location__c, ERP7__Product__c, ERP7__Batch_Lot__c, ERP7__Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Inventory_Stock__c WHERE (ERP7__Warehouse__c IN : siteAddress or ERP7__Location__c IN : siteAddress) ';
                            if(batIds.size() == 0) query += ' ANd ERP7__Product__c In : prodIds';
                            if(batIds.size() > 0) query += ' AND (ERP7__Product__c IN :prodIds OR ERP7__Batch_Lot__c IN :batIds)';
                            List<ERP7__Inventory_Stock__c> batchInventories = database.query(query);
                                //[Select Id, Name, ERP7__Product__c, ERP7__Batch_Lot__c, ERP7__Batch_Lot__r.ERP7__Available_Quantity__c FROM ERP7__Inventory_Stock__c WHERE ERP7__Batch_Lot__c In :batIds AND (ERP7__Warehouse__c IN : siteAddress or ERP7__Location__c IN : siteAddress)];
                                for(ERP7__Inventory_Stock__c IS : batchInventories) {                                    if(IS.ERP7__Batch_Lot__c != null) BatchStock_Map.put(IS.ERP7__Batch_Lot__c, IS);                                    if(IS.ERP7__Batch_Lot__c == null && IS.ERP7__Location__c != null) LocStock_Map.put(IS.ERP7__Location__c,IS);                                }
                            
                           // }
                            //end
                            
                            
                            for(Wrappers wrap : soliSelectedWrapperList) {                   Set<Id> allSelectedSerials = new Set<Id>();                                allSelectedSerials.addAll(wrap.MultiSerialIds);
                                system.debug('allSelectedSerials.size() bfr : '+allSelectedSerials.size());
                                if(allSelectedSerials.size() == 0 && wrap.SerialNumbers.Serial__c != Null) allSelectedSerials.add(wrap.SerialNumbers.Serial__c); 
                                for(Stock_Outward_Line_Item__c ppli: ppliItemList) { 
                                    if(wrap.LOLI.Product__c != Null && wrap.asset.Id == Null){
                                        if(!(wrap.LOLI.Product__r.Serialise__c) || (wrap.LOLI.Product__r.Serialise__c && ((wrap.MultiSerialIds.size() == 0 && !serialIds.contains(wrap.SerialNumbers.Serial__c)) || wrap.MultiSerialIds.size() > 0))){ // imran add list condition
                                            if(!(wrap.LOLI.Product__r.ERP7__Is_Kit__c && wrap.LOLI.Explode__c) && wrap.LOLI.Product__c == ppli.Product__c && ((wrap.LOLI.Sales_Order_Line_Item__c != Null && wrap.LOLI.Sales_Order_Line_Item__c == ppli.Sales_Order_Line_Item__c) || (wrap.LOLI.ERP7__Order_Product__c != Null && wrap.LOLI.ERP7__Order_Product__c == ppli.ERP7__Order_Product__c) || (wrap.LOLI.ERP7__Purchase_Line_Items__c != Null && wrap.LOLI.ERP7__Purchase_Line_Items__c == ppli.ERP7__Purchase_Line_Items__c) || (wrap.LOLI.ERP7__Work_Order_Line_Items__c != Null && wrap.LOLI.ERP7__Work_Order_Line_Items__c == ppli.ERP7__Work_Order_Line_Items__c) || (wrap.LOLI.ERP7__Transfer_Order_Line_Item__c != Null && wrap.LOLI.ERP7__Transfer_Order_Line_Item__c == ppli.ERP7__Transfer_Order_Line_Item__c)) && (ppli.Picked_Quantity__c == null || ppli.Picked_Quantity__c == 0)){
                                                if(wrap.LOLI.Product__r.Serialise__c){
                                                 //   system.debug('allSelectedSerials.size() bfr : '+allSelectedSerials.size());
                                               //     if(allSelectedSerials.size() == 0 && wrap.SerialNumbers.Serial__c != Null) allSelectedSerials.add(wrap.SerialNumbers.Serial__c); 
                                                    system.debug('allSelectedSerials.size() after : '+allSelectedSerials.size());
                                                    while(allSelectedSerials.size() > 0){                                                        Boolean breaknow = false;                                                        Decimal requiredQty = (wrap.requiredQty != null)? wrap.requiredQty : 0;
                                                        system.debug('old soli QTY before~>'+ppli.Quantity__c);
                                                        system.debug('requiredQty before~>'+requiredQty);
                                                        if(requiredQty > ppli.Quantity__c){		requiredQty = double.valueof(ppli.Quantity__c);                                                           wrap.requiredQty = wrap.requiredQty - double.valueof(ppli.Quantity__c);                                                       } 
                                                        /*else{
                                                            if(wrap.MultiSerialIds.size() == 0) breaknow = true; //imran
                                                        }*/
                                                        system.debug('requiredQty after~>'+requiredQty);
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) ppli.Quantity__c = ppli.Quantity__c - requiredQty; 
                                                        system.debug('old soli QTY after~>'+ppli.Quantity__c);
                                                        if(ppli.Quantity__c == 0) breaknow = true; // shaguftha
                                                        
                                                        Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c();  
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()) pplis.Name = 'STOLI-' + wrap.LOLI.Name;
                                                        if(wrap.LOLI.Product__c != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) pplis.Product__c = ppli.Product__c;
                                                        if(requiredQty != null){ pplis.Quantity__c = requiredQty;  pplis.Picked_Quantity__c = requiredQty; }
                                                        else{ pplis.Quantity__c = 0;  pplis.Picked_Quantity__c = 0; }
                                                        system.debug('new solis qty~>'+pplis.Quantity__c+' picked qty~>'+pplis.Picked_Quantity__c);
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isUpdateable()) pplis.Picked_Date__c = System.Now(); //ERP7__Order_Product__c
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) pplis.Status__c = 'Committed'; // change Shaguftha 09_08_24
                                                        
                                                        if(wrap.LOLI.Sales_Order_Line_Item__c != Null){
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) pplis.Sales_Order_Line_Item__c = wrap.LOLI.Sales_Order_Line_Item__c; 
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isUpdateable()) pplis.Sales_Order__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__c;
                                                        }
                                                        else if(wrap.LOLI.ERP7__Order_Product__c != Null){
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order_Product__c.isUpdateable()) pplis.ERP7__Order_Product__c = wrap.LOLI.ERP7__Order_Product__c; 
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order__c.isUpdateable()) pplis.ERP7__Order__c = wrap.LOLI.ERP7__Order_Product__r.OrderId; 
                                                        }
                                                        else if(wrap.LOLI.ERP7__Purchase_Line_Items__c != Null){
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable())  pplis.ERP7__Purchase_Line_Items__c = wrap.LOLI.ERP7__Purchase_Line_Items__c; 
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) pplis.Purchase_Orders__c = wrap.LOLI.ERP7__Purchase_Line_Items__r.Purchase_Orders__c;
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) pplis.Status__c = 'Returned to Supplier';
                                                        }
                                                        else if(wrap.LOLI.ERP7__Work_Order_Line_Items__c != Null){
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isUpdateable()) pplis.ERP7__Work_Order_Line_Items__c = wrap.LOLI.ERP7__Work_Order_Line_Items__c; 
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isUpdateable()) pplis.Work_Orders__c = wrap.LOLI.ERP7__Work_Order_Line_Items__r.Work_Orders__c;
                                                        }
                                                        else if(wrap.LOLI.ERP7__Transfer_Order_Line_Item__c != Null){
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isUpdateable()) pplis.ERP7__Transfer_Order_Line_Item__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__c; 
                                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Transfer_Order__c.isUpdateable()) pplis.Transfer_Order__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c;
                                                        }
                                                        
                                                        if(String.isNotEmpty(wrap.LOLI.Id) && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()) pplis.ERP7__Logistic_Line_Item__c=wrap.LOLI.Id;
                                                        
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) pplis.Active__c = true; 
                                                        
                                                        //if(ppli.ERP7__Site_Product_Service_Inventory_Stock__c != Null && !(wrap.LOLI.ERP7__Product__r.ERP7__Serialise__c) && !(wrap.LOLI.ERP7__Product__r.ERP7__Lot_Tracked__c))
                                                        //pplis.Site_Product_Service_Inventory_Stock__c = ppli.ERP7__Site_Product_Service_Inventory_Stock__c;
                                                        
                                                        if(ppli.ERP7__Site_Product_Service_Inventory_Stock__c != Null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable()) pplis.Site_Product_Service_Inventory_Stock__c = ppli.ERP7__Site_Product_Service_Inventory_Stock__c;
                                                        system.debug('ppli.ERP7__Site_Product_Service_Inventory_Stock__c 1 : '+ppli.ERP7__Site_Product_Service_Inventory_Stock__c);
                                                        system.debug('ppli.ERP7__BoM__c : '+ppli.ERP7__BoM__c);
                                                        if(ppli.ERP7__MRP_Material_Requirements_Planning__c != null) pplis.ERP7__MRP_Material_Requirements_Planning__c = ppli.ERP7__MRP_Material_Requirements_Planning__c;
                                                        if(ppli.ERP7__BoM__c != null) pplis.ERP7__BoM__c = ppli.ERP7__BoM__c;
                                                        if(BatchStock_Map.size() > 0 && wrap.BatchLotCode != ''){
                                                            //if(BatchStock_Map.containsKey(wrap.BatchLotCode) && BatchStock_Map.get(wrap.BatchLotCode) != Null) pplis.ERP7__Site_Product_Service_Inventory_Stock__c = BatchStock_Map.get(wrap.BatchLotCode);
                                                            if(BatchStock_Map.containsKey(wrap.BatchLotCode)) pplis.ERP7__Site_Product_Service_Inventory_Stock__c = BatchStock_Map.get(wrap.BatchLotCode).Id;
                                                            else if(stockMap.get(wrap.LOLI.Product__c) != null) pplis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.LOLI.Product__c);
                                                        }
                                                         system.debug('wrap.BatchLotCode : '+wrap.BatchLotCode);
                                                        if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '') pplis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;     
                                                        
                                                        if(allSelectedSerials.size() > 0){                                                            Id mySerialId = (new list<Id>(allSelectedSerials))[0];
                                                            system.debug('mySerialId : '+mySerialId);
                                                            serialIds.add(mySerialId);                                                            pplis.Serial__c = mySerialId;
                                                            if(SerialMap.containsKey(mySerialId) && SerialMap.get(mySerialId).ERP7__Material_Batch_Lot__c != null) pplis.ERP7__Material_Batch_Lot__c = SerialMap.get(mySerialId).ERP7__Material_Batch_Lot__c;
                                                            SerialIds2Update.add(mySerialId);
                                                            if(SerialStock2Inward.ContainsKey(mySerialId)  && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) pplis.Site_Product_Service_Inventory_Stock__c = SerialStock2Inward.get(mySerialId);
                                                            system.debug(' pplis.Site_Product_Service_Inventory_Stock__c 2 : '+ pplis.Site_Product_Service_Inventory_Stock__c);
                                                            allSelectedSerials.remove(mySerialId);
                                                            if(allSelectedSerials.size() == 0) breaknow = true;
                                                        }
                                                        else if(wrap.MultiSerialIds.size() == 0 && wrap.SerialNumbers.Serial__c != null ) { //imran add 3rd change with list
                                                            /*'Inside Serial no not null'*/
                                                            breaknow = true;                                                            serialIds.add(wrap.SerialNumbers.Serial__c);
                                                            pplis.Serial__c = wrap.SerialNumbers.Serial__c;
                                                            if(SerialMap.containsKey(wrap.SerialNumbers.Serial__c) && SerialMap.get(wrap.SerialNumbers.Serial__c).ERP7__Material_Batch_Lot__c != null) pplis.ERP7__Material_Batch_Lot__c = SerialMap.get(wrap.SerialNumbers.Serial__c).ERP7__Material_Batch_Lot__c;
                                                            SerialIds2Update.add(wrap.SerialNumbers.Serial__c);
                                                            if(SerialStock2Inward.ContainsKey(wrap.SerialNumbers.Serial__c)) pplis.Site_Product_Service_Inventory_Stock__c = SerialStock2Inward.get(wrap.SerialNumbers.Serial__c);
                                                            system.debug(' pplis.Site_Product_Service_Inventory_Stock__c if 3 : '+ pplis.Site_Product_Service_Inventory_Stock__c);
                                                        } 
                                                                
                                                        //orderNumber = wrap.LOLI.Logistic__r.Name;
                                                        
                                                        if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Picked_Quantity__c.isUpdateable()){
                                                            if(wrap.LOLI.Picked_Quantity__c == null) wrap.LOLI.Picked_Quantity__c = requiredQty;
                                                            else wrap.LOLI.Picked_Quantity__c += requiredQty;
                                                        }
                                                        soliMap.put(wrap.LOLI.Id, wrap.LOLI);                                                        PPLIList.add(pplis);
                                                        if(ppli.Name != 'Serial Stock Holder') {   system.debug('add PPLI 1');                       PPLIList.add(ppli);
                                                        }
                                                        if(breaknow) break;
                                                    }
                                                    if(ppli.Name == 'Serial Stock Holder') {	PPLIList.add(ppli);
                                                        system.debug('add PPLI 2');
                                                    }
                                                }
                                                else{
                                                    Boolean createNewBatchOutward = false;
                                                    if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '' && AssignedBatchIds.size() > 0 && !AssignedBatchIds.contains(wrap.BatchLotCode)) createNewBatchOutward = true;
                                                    if(!createNewBatchOutward && SelectedbatchLotCode.containsKey(ppli.ERP7__Product__c)) {
                                                    	if(ppli.ERP7__Material_Batch_Lot__c != null && SelectedbatchLotCode.get(ppli.ERP7__Product__c) != ppli.ERP7__Material_Batch_Lot__c) continue;
                                                    }
                                                    system.debug('continuee');
                                                    Boolean breaknow = false;
                                                    Decimal requiredQty = (wrap.requiredQty != null)? wrap.requiredQty : 0;
                                                    system.debug('old soli QTY before~>'+ppli.Quantity__c);
                                                    system.debug('requiredQty before~>'+requiredQty);
                                                    if(requiredQty > ppli.Quantity__c){	requiredQty = double.valueof(ppli.Quantity__c);  wrap.requiredQty = wrap.requiredQty - double.valueof(ppli.Quantity__c);
                                                    } else{  if(wrap.MultiSerialIds.size() == 0) breaknow = true; //imran
                                                    }
                                                    
                                                    system.debug('requiredQty after~>'+requiredQty);
                                                    
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) {
                                                        if(ppli.ERP7__Material_Batch_Lot__c != null && ppli.ERP7__Material_Batch_Lot__c == wrap.batchLotCode) {	 ppli.Quantity__c = ppli.Quantity__c - requiredQty; 
                                                        }
                                                        else ppli.Quantity__c = ppli.Quantity__c - requiredQty; 
                                                    }
                                                    system.debug('old soli QTY after~>'+ppli.Quantity__c);
                                                    
                                                    PPLIList.add(ppli);
                                                     system.debug('add PPLI 3');
                                                    Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c();  
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()) pplis.Name = 'STOLI-' + wrap.LOLI.Name;
                                                    if(wrap.LOLI.Product__c != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) pplis.Product__c = ppli.Product__c;
                                                    if(requiredQty != null){ pplis.Quantity__c = requiredQty;  pplis.Picked_Quantity__c = requiredQty; }
                                                    else{ pplis.Quantity__c = 0;  pplis.Picked_Quantity__c = 0; }
                                                    system.debug('new solis qty~>'+pplis.Quantity__c+' picked qty~>'+pplis.Picked_Quantity__c);
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isUpdateable()) pplis.Picked_Date__c = System.Now(); //ERP7__Order_Product__c
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) pplis.Status__c = 'Committed'; // change Shaguftha 09_08_24
                                                    
                                                    if(wrap.LOLI.Sales_Order_Line_Item__c != Null){	if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) pplis.Sales_Order_Line_Item__c = wrap.LOLI.Sales_Order_Line_Item__c; 
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isUpdateable()) pplis.Sales_Order__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__c;
                                                    }
                                                    else if(wrap.LOLI.ERP7__Order_Product__c != Null){	 if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order_Product__c.isUpdateable()) pplis.ERP7__Order_Product__c = wrap.LOLI.ERP7__Order_Product__c; 
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order__c.isUpdateable()) pplis.ERP7__Order__c = wrap.LOLI.ERP7__Order_Product__r.OrderId; 
                                                    }
                                                    else if(wrap.LOLI.ERP7__Purchase_Line_Items__c != Null){	 if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable())  pplis.ERP7__Purchase_Line_Items__c = wrap.LOLI.ERP7__Purchase_Line_Items__c; 
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) pplis.Purchase_Orders__c = wrap.LOLI.ERP7__Purchase_Line_Items__r.Purchase_Orders__c;
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) pplis.Status__c = 'Returned to Supplier';
                                                    }
                                                    else if(wrap.LOLI.ERP7__Work_Order_Line_Items__c != Null){
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isUpdateable()) pplis.ERP7__Work_Order_Line_Items__c = wrap.LOLI.ERP7__Work_Order_Line_Items__c; 
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isUpdateable()) pplis.Work_Orders__c = wrap.LOLI.ERP7__Work_Order_Line_Items__r.Work_Orders__c;
                                                    }
                                                    else if(wrap.LOLI.ERP7__Transfer_Order_Line_Item__c != Null){
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isUpdateable()) pplis.ERP7__Transfer_Order_Line_Item__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__c; 
                                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Transfer_Order__c.isUpdateable()) pplis.Transfer_Order__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c;
                                                    }
                                                    
                                                    if(String.isNotEmpty(wrap.LOLI.Id) && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()) pplis.ERP7__Logistic_Line_Item__c=wrap.LOLI.Id;
                                                    
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) pplis.Active__c = true; 
                                                    
                                                    //if(ppli.ERP7__Site_Product_Service_Inventory_Stock__c != Null && !(wrap.LOLI.ERP7__Product__r.ERP7__Serialise__c) && !(wrap.LOLI.ERP7__Product__r.ERP7__Lot_Tracked__c))
                                                    //pplis.Site_Product_Service_Inventory_Stock__c = ppli.ERP7__Site_Product_Service_Inventory_Stock__c;
                                                    system.debug(' ppli.ERP7__Site_Product_Service_Inventory_Stock__c 4 : '+ ppli.ERP7__Site_Product_Service_Inventory_Stock__c);
                                                    if(ppli.ERP7__Site_Product_Service_Inventory_Stock__c != Null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable()) pplis.Site_Product_Service_Inventory_Stock__c = ppli.ERP7__Site_Product_Service_Inventory_Stock__c;
                                                     system.debug(' ppli.ERP7__Site_Product_Service_Inventory_Stock__c 5 : '+ ppli.ERP7__Site_Product_Service_Inventory_Stock__c);
                                                    system.debug('ppli.ERP7__MRP_Material_Requirements_Planning__c : '+ppli.ERP7__MRP_Material_Requirements_Planning__c);
                                                    system.debug('ppli.ERP7__BoM__c : '+ppli.ERP7__BoM__c);
                                                    if(ppli.ERP7__MRP_Material_Requirements_Planning__c != null) pplis.ERP7__MRP_Material_Requirements_Planning__c = ppli.ERP7__MRP_Material_Requirements_Planning__c;
                                                    if(ppli.ERP7__BoM__c != null) pplis.ERP7__BoM__c = ppli.ERP7__BoM__c;
                                                    //commened these lines of code as it was assigning same inventory Id for all stock ouwards if the outward is created from different locations -- Shaguftha 04/10/23
                                                    //Moin uncommented this 
                                                    system.debug('LocStock_Map.size() : '+LocStock_Map.size());
                                                    if((wrap.AddressName == null || wrap.AddressName == '') && wrap.Address.size() > 0) wrap.AddressName =wrap.Address[0].value;
                                                    if(wrap.AddressName != '' && wrap.AddressName != null && LocStock_Map.size() > 0 && LocStock_Map.containsKey(wrap.AddressName)) {
                                                        system.debug('LocStock_Map.get(wrap.AddressName).Product__c : '+LocStock_Map.get(wrap.AddressName).Product__c);
                                                        system.debug('wrap.LOLI.Product__c : '+wrap.LOLI.Product__c);
                                                        if(LocStock_Map.get(wrap.AddressName).Product__c == wrap.LOLI.Product__c) pplis.ERP7__Site_Product_Service_Inventory_Stock__c = LocStock_Map.get(wrap.AddressName).Id;
                                                        system.debug('pplis.ERP7__Site_Product_Service_Inventory_Stock__c 6 : '+pplis.ERP7__Site_Product_Service_Inventory_Stock__c);
                                                    }
                                                  if(BatchStock_Map.size() > 0 && wrap.BatchLotCode != ''){
                                                        //if(BatchStock_Map.containsKey(wrap.BatchLotCode) && BatchStock_Map.get(wrap.BatchLotCode) != Null) pplis.ERP7__Site_Product_Service_Inventory_Stock__c = BatchStock_Map.get(wrap.BatchLotCode); already commented
                                                        if(BatchStock_Map.containsKey(wrap.BatchLotCode)) pplis.ERP7__Site_Product_Service_Inventory_Stock__c = BatchStock_Map.get(wrap.BatchLotCode).Id;
                                                        else if(stockMap.get(wrap.LOLI.Product__c) != null) pplis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.LOLI.Product__c);
                                                    }
                                                    if(wrap.MultiSerialIds.size() > 0){
                                                        Id mySerialId = (new list<Id>(allSelectedSerials))[0];                                                        serialIds.add(mySerialId);
                                                        pplis.Serial__c = mySerialId;
                                                        if(SerialMap.containsKey(mySerialId) && SerialMap.get(mySerialId).ERP7__Material_Batch_Lot__c != null) pplis.ERP7__Material_Batch_Lot__c = SerialMap.get(mySerialId).ERP7__Material_Batch_Lot__c;
                                                        SerialIds2Update.add(mySerialId);
                                                        if(SerialStock2Inward.ContainsKey(mySerialId)  && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) pplis.Site_Product_Service_Inventory_Stock__c = SerialStock2Inward.get(mySerialId);
                                                        system.debug('serial pplis.Site_Product_Service_Inventory_Stock__c if 7: '+pplis.Site_Product_Service_Inventory_Stock__c);
                                                        allSelectedSerials.remove(mySerialId);
                                                        if(allSelectedSerials.size() == 0) breaknow = true;
                                                    }
                                                    else if(wrap.MultiSerialIds.size() == 0 && wrap.SerialNumbers.Serial__c != null ) { //imran add 3rd change with list
                                                        /*'Inside Serial no not null'*/
                                                        breaknow = true;
                                                        serialIds.add(wrap.SerialNumbers.Serial__c);
                                                        pplis.Serial__c = wrap.SerialNumbers.Serial__c;
                                                        if(SerialMap.containsKey(wrap.SerialNumbers.Serial__c) && SerialMap.get(wrap.SerialNumbers.Serial__c).ERP7__Material_Batch_Lot__c != null) pplis.ERP7__Material_Batch_Lot__c = SerialMap.get(wrap.SerialNumbers.Serial__c).ERP7__Material_Batch_Lot__c;
                                                        SerialIds2Update.add(wrap.SerialNumbers.Serial__c);
                                                        if(SerialStock2Inward.ContainsKey(wrap.SerialNumbers.Serial__c)) pplis.Site_Product_Service_Inventory_Stock__c = SerialStock2Inward.get(wrap.SerialNumbers.Serial__c);
                                                        system.debug('serial pplis.Site_Product_Service_Inventory_Stock__c 8: '+pplis.Site_Product_Service_Inventory_Stock__c);
                                                    } 
                                                    system.debug('wrap.BatchLotCode : '+wrap.BatchLotCode);
                                                    if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '') pplis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;              
                                                    //orderNumber = wrap.LOLI.Logistic__r.Name;
                                                    
                                                    if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Picked_Quantity__c.isUpdateable()){
                                                        if(wrap.LOLI.Picked_Quantity__c == null) wrap.LOLI.Picked_Quantity__c = requiredQty;
                                                        else wrap.LOLI.Picked_Quantity__c += requiredQty;
                                                    }
                                                    system.debug('pplis.ERP7__Site_Product_Service_Inventory_Stock__c 9 : '+pplis.ERP7__Site_Product_Service_Inventory_Stock__c);
                                                    soliMap.put(wrap.LOLI.Id, wrap.LOLI);
                                                    PPLIList.add(pplis);
                                                    if(breaknow) break;
                                                }
                                                
                                            }
                                            else if((wrap.LOLI.Product__r.ERP7__Is_Kit__c && wrap.LOLI.Explode__c) && wrap.MRP.MRP_Product__c == ppli.Product__c && ((wrap.LOLI.Sales_Order_Line_Item__c != Null && wrap.LOLI.Sales_Order_Line_Item__c == ppli.Sales_Order_Line_Item__c) || (wrap.LOLI.ERP7__Order_Product__c != Null && wrap.LOLI.ERP7__Order_Product__c == ppli.ERP7__Order_Product__c)|| (wrap.LOLI.ERP7__Purchase_Line_Items__c != Null && wrap.LOLI.ERP7__Purchase_Line_Items__c == ppli.ERP7__Purchase_Line_Items__c) || (wrap.LOLI.ERP7__Work_Order_Line_Items__c != Null && wrap.LOLI.ERP7__Work_Order_Line_Items__c == ppli.ERP7__Work_Order_Line_Items__c) || (wrap.LOLI.ERP7__Transfer_Order_Line_Item__c != Null && wrap.LOLI.ERP7__Transfer_Order_Line_Item__c == ppli.ERP7__Transfer_Order_Line_Item__c)) && ppli.Picked_Quantity__c == null)
                                                 /* if((wrap.LOLI.Product__c !=null) && wrap.MRP.MRP_Product__c == ppli.Product__c && ((wrap.LOLI.Sales_Order_Line_Item__c != Null && wrap.LOLI.Sales_Order_Line_Item__c == ppli.Sales_Order_Line_Item__c) || (wrap.LOLI.ERP7__Order_Product__c != Null && wrap.LOLI.ERP7__Order_Product__c == ppli.ERP7__Order_Product__c)|| (wrap.LOLI.ERP7__Purchase_Line_Items__c != Null && wrap.LOLI.ERP7__Purchase_Line_Items__c == ppli.ERP7__Purchase_Line_Items__c) || (wrap.LOLI.ERP7__Work_Order_Line_Items__c != Null && wrap.LOLI.ERP7__Work_Order_Line_Items__c == ppli.ERP7__Work_Order_Line_Items__c) || (wrap.LOLI.ERP7__Transfer_Order_Line_Item__c != Null && wrap.LOLI.ERP7__Transfer_Order_Line_Item__c == ppli.ERP7__Transfer_Order_Line_Item__c)) && ppli.Picked_Quantity__c == null)*/{ 
                                                /*'Inside Product Kit'*/
                                                Boolean breaknow = false;
                                                Decimal requiredQty = (wrap.requiredQty != null)? wrap.requiredQty : 0;
                                                system.debug('Kit before requiredQty Qty:'+requiredQty);
                                                if(requiredQty > ppli.Quantity__c){
                                                    requiredQty = double.valueof(ppli.Quantity__c); 
                                                    wrap.requiredQty = double.valueof(wrap.requiredQty - ppli.Quantity__c);
                                                } else breaknow = true;
                                                
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) ppli.Quantity__c = ppli.Quantity__c - requiredQty;                                                                                                                               
                                                PPLIList.add(ppli);
                                                      system.debug('add PPLI 4');
                                                system.debug('Kit After requiredQty Qty:'+requiredQty);
                                                Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c();  
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()) pplis.Name = 'STOLI-' + wrap.LOLI.Name;
                                                if(wrap.LOLI.Product__c != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) pplis.Product__c = ppli.Product__c;
                                                if(requiredQty != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) pplis.Quantity__c = requiredQty;
                                                if(requiredQty != null  && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Quantity__c.isUpdateable()) pplis.Picked_Quantity__c = requiredQty;
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isUpdateable()) pplis.Picked_Date__c = System.Now();//ERP7__Order_Product__c
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) pplis.Status__c = 'Committed'; // change Shaguftha 09_08_24
                                                if(wrap.LOLI.Sales_Order_Line_Item__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) pplis.Sales_Order_Line_Item__c = wrap.LOLI.Sales_Order_Line_Item__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isUpdateable()) pplis.Sales_Order__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__c; 
                                                }
                                                else if(wrap.LOLI.ERP7__Order_Product__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order_Product__c.isUpdateable()) pplis.ERP7__Order_Product__c = wrap.LOLI.ERP7__Order_Product__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order__c.isUpdateable()) pplis.ERP7__Order__c = wrap.LOLI.ERP7__Order_Product__r.OrderId; 
                                                }
                                                else if(wrap.LOLI.ERP7__Purchase_Line_Items__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable())  pplis.ERP7__Purchase_Line_Items__c = wrap.LOLI.ERP7__Purchase_Line_Items__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) pplis.Purchase_Orders__c = wrap.LOLI.ERP7__Purchase_Line_Items__r.Purchase_Orders__c;
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) pplis.Status__c = 'Returned to Supplier';
                                                }
                                                else if(wrap.LOLI.ERP7__Work_Order_Line_Items__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isUpdateable()) pplis.ERP7__Work_Order_Line_Items__c = wrap.LOLI.ERP7__Work_Order_Line_Items__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isUpdateable()) pplis.Work_Orders__c = wrap.LOLI.ERP7__Work_Order_Line_Items__r.Work_Orders__c;
                                                }
                                                else if(wrap.LOLI.ERP7__Transfer_Order_Line_Item__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isUpdateable()) pplis.ERP7__Transfer_Order_Line_Item__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Transfer_Order__c.isUpdateable()) pplis.Transfer_Order__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c;
                                                }
                                                
                                                
                                                if(String.isNotEmpty(wrap.LOLI.Id) && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()) pplis.ERP7__Logistic_Line_Item__c=wrap.LOLI.Id;
                                                
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) pplis.Active__c = true; 
                                                
                                                if(BatchStock_Map.size() > 0 && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable()){
                                                    if(SerialStock2Inward.ContainsKey(wrap.SerialNumbers.Serial__c)) pplis.Site_Product_Service_Inventory_Stock__c = SerialStock2Inward.get(wrap.SerialNumbers.Serial__c);
                                                    else if(BatchStock_Map.containsKey(wrap.BatchLotCode)) pplis.ERP7__Site_Product_Service_Inventory_Stock__c = BatchStock_Map.get(wrap.BatchLotCode).Id;
                                                    else if(stockMap.get(wrap.MRP.ERP7__MRP_Product__c) != null) pplis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.MRP.ERP7__MRP_Product__c);
                                                }
                                                
                                                if(wrap.SerialNumbers.Serial__c != null) {
                                                    breaknow = true;
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isUpdateable()) pplis.Serial__c = wrap.SerialNumbers.Serial__c;
                                                    SerialIds2Update.add(wrap.SerialNumbers.Serial__c);
                                                    if(SerialStock2Inward.ContainsKey(wrap.SerialNumbers.Serial__c) && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) pplis.Site_Product_Service_Inventory_Stock__c = SerialStock2Inward.get(wrap.SerialNumbers.Serial__c);
                                                }
                                                if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '' && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()) pplis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;              
                                                //orderNumber = wrap.LOLI.Logistic__r.Name;
                                                if(Schema.sObjectType.MRP__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.MRP__c.fields.Picked_Quantity__c.isUpdateable()){
                                                    if(wrap.MRP.Picked_Quantity__c == null) wrap.MRP.Picked_Quantity__c = requiredQty;
                                                    else wrap.MRP.Picked_Quantity__c += requiredQty;
                                                }
                                                mrpMap.put(wrap.mrp.Id, wrap.mrp);
                                                //new line added
                                                //soliMap.put(wrap.LOLI.Id, wrap.LOLI);
                                                
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isUpdateable()) pplis.MRP_Material_Requirements_Planning__c = wrap.MRP.Id;
                                                system.debug('pplis.ERP7__MRP_Material_Requirements_Planning__c 111: '+pplis.ERP7__MRP_Material_Requirements_Planning__c);
                                                PPLIList.add(pplis);
                                            } 
                                        } 
                                    }
                                    else if(wrap.asset.Id != Null){
                                        /*'inside Asset not null'*/
                                        if(!(wrap.asset.Serialise__c) || (wrap.asset.Serialise__c)){ // && wrap.SerialNumbers.Serial__c == ppli.Serial__c
                                            if(wrap.asset.Id == ppli.Fixed_Asset__c && ((wrap.LOLI.ERP7__Order_Product__c != Null && wrap.LOLI.ERP7__Order_Product__c == ppli.ERP7__Order_Product__c) || (wrap.LOLI.Sales_Order_Line_Item__c != Null && wrap.LOLI.Sales_Order_Line_Item__c == ppli.Sales_Order_Line_Item__c) || (wrap.LOLI.ERP7__Purchase_Line_Items__c != Null && wrap.LOLI.ERP7__Purchase_Line_Items__c == ppli.ERP7__Purchase_Line_Items__c) || (wrap.LOLI.ERP7__Work_Order_Line_Items__c != Null && wrap.LOLI.ERP7__Work_Order_Line_Items__c == ppli.ERP7__Work_Order_Line_Items__c) || (wrap.LOLI.ERP7__Transfer_Order_Line_Item__c != Null && wrap.LOLI.ERP7__Transfer_Order_Line_Item__c == ppli.ERP7__Transfer_Order_Line_Item__c)) && ppli.Picked_Quantity__c == null) { 
                                                Boolean breaknow = false;	Decimal requiredQty = (wrap.requiredQty != null)? wrap.requiredQty : 0;
                                                if(requiredQty > ppli.Quantity__c){	requiredQty = double.valueof(ppli.Quantity__c); 	wrap.requiredQty = double.valueof(wrap.requiredQty - ppli.Quantity__c);
                                                } else breaknow = true;
                                                
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) ppli.Quantity__c = ppli.Quantity__c - requiredQty;                                                                                                                               
                                                PPLIList.add(ppli);
                                                 system.debug('add PPLI 5');
                                                Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c();  
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()) pplis.Name = 'STOLI-' + wrap.LOLI.Name;
                                                if(wrap.asset.Id != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isUpdateable()) pplis.Fixed_Asset__c = wrap.asset.Id;
                                                if(requiredQty != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) pplis.Quantity__c = requiredQty;
                                                if(requiredQty != null  && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Quantity__c.isUpdateable()) pplis.Picked_Quantity__c = requiredQty;
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isUpdateable()) pplis.Picked_Date__c = System.Now(); //ERP7__Order_Product__c
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) pplis.Status__c = 'Committed'; // change Shaguftha 09_08_24
                                                if(wrap.LOLI.Sales_Order_Line_Item__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()) pplis.Sales_Order_Line_Item__c = wrap.LOLI.Sales_Order_Line_Item__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isUpdateable()) pplis.Sales_Order__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__c;
                                                }
                                                else if(wrap.LOLI.ERP7__Order_Product__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order_Product__c.isUpdateable()) pplis.ERP7__Order_Product__c = wrap.LOLI.ERP7__Order_Product__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Order__c.isUpdateable()) pplis.ERP7__Order__c = wrap.LOLI.ERP7__Order_Product__r.OrderId; 
                                                }
                                                else if(wrap.LOLI.ERP7__Purchase_Line_Items__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable())  pplis.ERP7__Purchase_Line_Items__c = wrap.LOLI.ERP7__Purchase_Line_Items__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) pplis.Purchase_Orders__c = wrap.LOLI.ERP7__Purchase_Line_Items__r.Purchase_Orders__c;
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()) pplis.Status__c = 'Returned to Supplier';
                                                }
                                                else if(wrap.LOLI.ERP7__Work_Order_Line_Items__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isUpdateable()) pplis.ERP7__Work_Order_Line_Items__c = wrap.LOLI.ERP7__Work_Order_Line_Items__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isUpdateable()) pplis.Work_Orders__c = wrap.LOLI.ERP7__Work_Order_Line_Items__r.Work_Orders__c;
                                                }
                                                else if(wrap.LOLI.ERP7__Transfer_Order_Line_Item__c != Null){
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isUpdateable()) pplis.ERP7__Transfer_Order_Line_Item__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__c; 
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Transfer_Order__c.isUpdateable()) pplis.Transfer_Order__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c;
                                                }
                                                
                                                
                                                
                                                if(String.isNotEmpty(wrap.LOLI.Id) && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()) pplis.ERP7__Logistic_Line_Item__c=wrap.LOLI.Id;
                                                
                                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()) pplis.Active__c = true; 
                                                
                                                if(wrap.SerialNumbers.Serial__c != null) {
                                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isUpdateable()) pplis.Serial__c = wrap.SerialNumbers.Serial__c;
                                                    SerialIds2Update.add(wrap.SerialNumbers.Serial__c);
                                                }
                                                if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '' && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()) pplis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;              
                                                //orderNumber = wrap.LOLI.Logistic__r.Name;
                                                
                                                if(wrap.SerialNumbers.Site_Product_Service_Inventory_Stock__c != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable()) pplis.Site_Product_Service_Inventory_Stock__c = wrap.SerialNumbers.Site_Product_Service_Inventory_Stock__c;
                                                
                                                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Picked_Quantity__c.isUpdateable()){
                                                    if(wrap.LOLI.Picked_Quantity__c == null) wrap.LOLI.Picked_Quantity__c = requiredQty;
                                                    else wrap.LOLI.Picked_Quantity__c += requiredQty;
                                                }
                                                soliMap.put(wrap.LOLI.Id, wrap.LOLI);
                                                PPLIList.add(pplis);
                                            } 
                                        }
                                    }
                                }
                            }    
                        }  else errorMsg = 'No reserved stock outward Lines to pick';
                        /*
                        for(ERP7__Stock_Outward_Line_Item__c SOW:PPLIList){
                             'SOW Id:'+SOW.Id);
                            'Inventory of SOW:'+SOW.ERP7__Site_Product_Service_Inventory_Stock__c);
                            'Status:'+SOW.Status__c);
                            'Batch:'+SOW.ERP7__Material_Batch_Lot__c);
                        }
                        */
                        if(PPLIList.size() > 0 || assetMap.Values().size() > 0) { 
                            //PreventRecursiveLedgerEntry.testCasesTransactions = true;
                            PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; 
                            //PreventRecursiveLedgerEntry.Loged = false;
                            //PreventRecursiveLedgerEntry.LogisticLineRollup = false;
                            
                            if(PPLIList.size() > 0){
                                for(ERP7__Stock_Outward_Line_Item__c SOW:PPLIList){	string name = SOW.Name;
                                    if(name.length() > 80) SOW.Name = name.substring(0,79);
                                    system.debug('Quantity__c~>'+SOW.Quantity__c+'and Status~>'+SOW.Status__c+' and Id~>'+SOW.Id+'  Serial Id : '+SOW.Serial__c);
                                }
                            }
                            
                            PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;  PreventRecursiveLedgerEntry.proceedDeleteZeroReserverSTOLI = true;
                            
                            if(PPLIList.size() > 0 && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()) { upsert PPLIList;} else{ errorMsg ='Not allowed to upsert stock outward';}
                            if(mrpMap.Values().size() > 0 && Schema.sObjectType.MRP__c.isCreateable() && Schema.sObjectType.MRP__c.isUpdateable()) { upsert mrpMap.Values(); } else{errorMsg ='Not allowed to upsert MRP'; }
                            if(assetMap.Values().size() > 0 && Schema.sObjectType.Asset__c.isCreateable() && Schema.sObjectType.Asset__c.isUpdateable()) { upsert assetMap.Values(); } else{errorMsg ='Not allowed to upsert Assest'; }
                            
                            //PreventRecursiveLedgerEntry.LogisticLineRollup = true;
                            if(soliMap.Values().size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()) { upsert soliMap.Values();}  else{errorMsg ='Not allowed to upsert LOLI';}
                            for(ERP7__Serial_Number__c SN : SNS) if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Available__c.isUpdateable()) SN.ERP7__Available__c = false;
                            PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation = false;
                            PreventRecursiveLedgerEntry.ProceedSerialsTrigger = false;
                            if(Schema.sObjectType.ERP7__Serial_Number__c.isUpdateable()) { update SNS; } else{ errorMsg= ' Not allowed to update serial number'; }
                            //comW = redirect2NextTab(LogisticIds);
                            return comW;
                        }
                    }
                } else errorMsg = 'Please select a line item to pick.';                  
            } else errorMsg = 'Items have been picked, please proceed to packing.';
        } catch(Exception e) { 
            errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();
            system.debug('err'+e.getMessage() +' Line Number @ : '+ e.getLineNumber());
        }  
        comW.exceptionError = errorMsg;     
        return comW;
    }
    
    @AuraEnabled
    public static comWrap createPacksInit(String LogisticIds, String Customer){
        comWrap comW = new comWrap();
        String errorMsg = '';
        try {
            String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');    
            String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
            utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
            logLineFields += ',  ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.ERP7__Shipment_type__c,ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.ERP7__Shipment_type__c,ERP7__Logistic__r.ERP7__Order__c,ERP7__Logistic__r.ERP7__Order_S__c,ERP7__Logistic__r.ERP7__Sales_Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c,ERP7__Order_Product__r.OrderId, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c,ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
                +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Order_Product__r.OrderItemNumber,ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c';
            String PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
            utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');            
            String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');  
            String MRPFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(MRPFields.split(','),'ERP7__MRP__c');
            String packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
            utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');
            String PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
            utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c');
            
            List<String> soIdss = (List<String>) JSON.deserialize(LogisticIds, List<String> .class);
            String selectedSite = '';
            String orderNumber = '';
            Set<Id> OrderIds = new Set<Id>();
            Set<Id> spIds = new Set<Id>();
            string PONumber = '';
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                       ERP7__Organisation_Business_Unit__c
                       From ERP7__Employees__c
                       Where ERP7__Employee_User__c = : UserInfo.getUserId()
                       Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) { 
                comW.Employee = empList[0]; 
                
                if(comW.Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Primary__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Site__r.Name
                                                                                  From ERP7__Distribution_Channel__c
                                                                                  Where ERP7__Channel__c = : comW.Employee.ERP7__Channel__c And ERP7__Active__c = true And ERP7__Site__c != Null
                                                                                  Order By ERP7__Primary__c Desc];
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {
                            comW.channelSites.add(new SelectOptions(DC.ERP7__Site__c, DC.Name));
                        }
                    } 
                } 
            } 
            comW.LogisticRecs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' ,ERP7__Order_S__r.Name , ERP7__Order_S__r.ERP7__Customer_Purchase_Order_Reference__c,ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,ERP7__Sales_Order__r.Name,ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__To_Address__r.ERP7__Address_Line1__c, ERP7__To_Address__r.ERP7__Address_Line2__c, ERP7__To_Address__r.ERP7__Address_Line3__c, ERP7__To_Address__r.ERP7__City__c, ERP7__To_Address__r.ERP7__County__c, '+
                                               +'ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Channel__r.Name, ERP7__Distribution_Channel__r.ERP7__Site__r.Name,  ERP7__To_Address__r.ERP7__Country__c, ERP7__To_Address__r.ERP7__State__c, ERP7__To_Address__r.ERP7__Postal_Code__c, ERP7__Account__r.Name from ERP7__Logistic__c where Id IN :soIdss'); 
            if(comW.LogisticRecs.size() > 0){
                comW.SiteName = comW.LogisticRecs[0].ERP7__Distribution_Channel__r.ERP7__Site__r.Name;
                comW.ChannelName = comW.LogisticRecs[0].Channel__r.Name;
                comW.ChannelId = comW.LogisticRecs[0].Channel__c;
                comW.selectedSite = comW.LogisticRecs[0].ERP7__Distribution_Channel__r.ERP7__Site__c;
                
                selectedSite = comW.selectedSite;
            }
            List<Id> soIds = new List<Id>();
            for(ERP7__Logistic__c logistic :comW.LogisticRecs){
                soIds.add(logistic.Id);
                if(logistic.ERP7__Order_S__c != Null) { OrderIds.add(logistic.ERP7__Order_S__c);   PONumber =logistic.ERP7__Order_S__r.ERP7__Customer_Purchase_Order_Reference__c; } 
                if(logistic.ERP7__Sales_Order__c != Null) { OrderIds.add(logistic.ERP7__Sales_Order__c); PONumber =logistic.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c; } 
                if(logistic.ERP7__Purchase_Order__c != Null) OrderIds.add(logistic.ERP7__Purchase_Order__c);
                if(logistic.ERP7__Work_Order__c != Null) OrderIds.add(logistic.ERP7__Work_Order__c);
                if(logistic.ERP7__Transfer_Order__c != Null) OrderIds.add(logistic.ERP7__Transfer_Order__c);
                spIds.add(logistic.Channel__c);
            }
            
            if(soIds.size() > 0) {
                List<Wrappers> soliWrapperList = new List<Wrappers>();
                
                List<Id> soliIds = new List<Id>();
                Map<Id,ERP7__Logistic_Line_Item__c> soliMap = new Map<Id,ERP7__Logistic_Line_Item__c>();
                List<Id> proIds = new List<Id>();
                String mrpKit = 'MRP Kit';
                String Reserved = 'Reserved';
                Boolean createPack = false; 
                Boolean isAwaiting = false;
                String pkgTypeValue = '';
                Boolean CustomerPresent = false;
                String errorMsg2 = '';
                
                List<ERP7__Logistic_Line_Item__c> soliss = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' ,ERP7__Order_Product__r.Order.ERP7__Shipment_Preference_Speed__c from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In: soIds order by ERP7__Logistic__c ASC');
                
                for(ERP7__Logistic_Line_Item__c solis: soliss) {
                    
                    // One logistic Order for Multiple SOs
                    if(solis.ERP7__Order_Product__r.OrderId != Null) OrderIds.add(solis.ERP7__Order_Product__r.OrderId);
                    if(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != Null) OrderIds.add(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c);
                    if(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != Null) OrderIds.add(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c);
                    if(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c != Null) OrderIds.add(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c);
                    if(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != Null) OrderIds.add(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c);
                    
                    if(Customer == Null || Customer == '') Customer = solis.Logistic__r.Account__c;
                    if(!(solis.Product__r.ERP7__Is_Kit__c && solis.Explode__c) && solis.Packed_Quantity__c < solis.Picked_Quantity__c && solis.Picked_Quantity__c <= solis.Quantity__c && !(solis.Packed_Quantity__c < 0)) {
                        Wrappers swrap = new Wrappers(); 
                        swrap.LOLI = solis; swrap.isSOLIawaiting = true;
                        orderNumber = solis.Logistic__r.Name; proIds.add(solis.Product__c);
                        soliWrapperList.add(swrap);
                    } else{
                        if(solis.ERP7__Sales_Order_Line_Item__c != Null) soliMap.put(solis.ERP7__Sales_Order_Line_Item__c,solis);
                        if(solis.ERP7__Order_Product__c != Null) soliMap.put(solis.ERP7__Order_Product__c,solis);
                        if(solis.ERP7__Purchase_Line_Items__c != Null) soliMap.put(solis.ERP7__Purchase_Line_Items__c,solis);
                        if(solis.Work_Order_Line_Items__c != Null) soliMap.put(solis.Work_Order_Line_Items__c,solis);
                        if(solis.ERP7__Transfer_Order_Line_Item__c != Null) soliMap.put(solis.ERP7__Transfer_Order_Line_Item__c,solis);
                        soliIds.add(solis.Id);
                    }
                }
                
                List<MRP__c> MRPSS = Database.query('select ' + String.escapeSingleQuotes(MRPFields) + ' ,Sales_Order_Line_Item__r.ERP7__Sales_Order__c,ERP7__Order_Product__r.OrderId, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ProductCode, ERP7__MRP_Product__r.ERP7__Weight__c, ERP7__MRP_Product__r.ERP7__Picture__c, ERP7__MRP_Product__r.ERP7__Preview_Image__c, RecordType.Name, ERP7__MRP_Product__r.ERP7__Item_Description__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Serialise__c from MRP__c where ((Sales_Order_Line_Item__r.ERP7__Sales_Order__c In :OrderIds Or ERP7__Order_Product__r.OrderId In :OrderIds Or ERP7__Purchase_Order__c In :OrderIds Or ERP7__Work_Order__c In :OrderIds Or ERP7__Transfer_Order__c In :OrderIds) And ERP7__Status__c  = :Reserved And RecordType.Name = :mrpKit)');
                for(MRP__c MRP : MRPSS) {
                    if(MRP.Packed_Quantity__c < MRP.Picked_Quantity__c && MRP.Picked_Quantity__c <= MRP.Total_Amount_Required__c && !(MRP.Packed_Quantity__c < 0)) {
                        Wrappers swrap = new Wrappers(); 
                        if(MRP.Sales_Order_Line_Item__c != Null) swrap.LOLI = soliMap.get(MRP.Sales_Order_Line_Item__c);//ERP7__Order_Product__c
                        if(MRP.ERP7__Order_Product__c != Null) swrap.LOLI = soliMap.get(MRP.ERP7__Order_Product__c);
                        if(MRP.ERP7__Purchase_Line_Items__c != Null) swrap.LOLI = soliMap.get(MRP.ERP7__Purchase_Line_Items__c);
                        if(MRP.Work_Order_Line_Items__c != Null) swrap.LOLI = soliMap.get(MRP.Work_Order_Line_Items__c);
                        if(MRP.ERP7__Transfer_Order_Line_Item__c != Null) swrap.LOLI = soliMap.get(MRP.ERP7__Transfer_Order_Line_Item__c);
                        swrap.MRP = MRP; proIds.add(MRP.ERP7__MRP_Product__c);
                        swrap.isSOLIawaiting = true; orderNumber = swrap.LOLI.Logistic__r.Name;
                        soliWrapperList.add(swrap);
                    } 
                }
                
                Map<Id, Product2> productMap = new Map<Id, Product2>([Select Id, Name, Picture__c, Preview_Image__c, Item_Description__c, ERP7__Lot_Tracked__c, Special_Instructions__c, Weight__c, Barcode__c From Product2 Where Id In: proIds]);
                
                List<Package__c> Packages = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ', ERP7__Logistic__r.Name ,ERP7__Order__r.Name,ERP7__Order__r.Account.Name, ERP7__Sales_Order__r.Name,Transfer_Order__r.Name, ERP7__Sales_Order__r.ERP7__Account__r.Name, ERP7__Shipment__r.Id, ERP7__Shipment__r.Name, ERP7__Shipment__r.ERP7__Shipment_Date__c, '+
                                                           +' ERP7__Logistic__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c,ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Shipment_Type__c, ERP7__Logistic__r.ERP7__Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Shipment__r.ERP7__Status__c, ERP7__Logistic__r.ERP7__Ready_To_Ship__c from ERP7__Package__c where (ERP7__Active__c = true And ERP7__Logistic__c In: soIds) Order by ERP7__Shipment__r.Name, CreatedDate Asc');                       
                
                Map <Id, Package__c> packMap = new Map <Id, Package__c>(Packages); 
                
                if(Packages.size() > 0 && soliWrapperList.size() > 0) { createPack = true; isAwaiting = true; }
                else if(Packages.size() > 0) { createPack = false; isAwaiting = true; } 
                else if(soliWrapperList.size() > 0) { createPack = true; isAwaiting = false; }
                
                Set<Id> pkgIds = new Set<Id>();
                if(Packages.size() > 0) { for(Package__c pack: Packages) { pkgIds.add(pack.Id); } }       
                String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Shipment__c','UPS_Shipping');
                List<Shipment__c> Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from ERP7__Shipment__c where (ERP7__Return_Shipment__c = false AND ERP7__Package__c In: pkgIds And ERP7__Status__c = \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');    
                List<Package_List__c> packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ', ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.Account__r.Name from ERP7__Package_List__c where (ERP7__Package__c In: pkgIds And ERP7__Active__c = true) Order by CreatedDate Asc'); 
                
                //*****************************************************************            
                List<lineItemWrapper> lineItemWrapperList = new List<lineItemWrapper>();
                for(Package__c P : Packages) { 
                    lineItemWrapper LW = new lineItemWrapper();
                    LW.pack = P;
                    if(P.Weight_Unit__c == 'KGS') LW.units = 'cm';
                    else LW.units = 'in';
                    
                    for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                    LW.NoofLineItems = P.Package_Quantity__c;                
                    lineItemWrapperList.add(LW);
                }
                
                // **************************************************************** 
                Id pikid = null;
                Package__c Package2Create = new Package__c(Package_Type__c='Package');
                Package2Create.Weight__c = 0;
                Package2Create.Declared_Value__c = 0;
                if(Schema.sObjectType.Package__c.fields.Declared_Value__c.isCreateable() && Schema.sObjectType.Package__c.fields.Declared_Value__c.isUpdateable()){ comW.enableDecalre = true; }
                else{ comW.enableDecalre = false; }
                
                
                if(Package2Create.Package_Type__c != null && Package2Create.Package_Type__c != '') {
                    pkgTypeValue = Package2Create.Package_Type__c;  
                    //populatePackDetails(); 
                    List<Package_Details__c> pkgDetailList = new List<Package_Details__c>();
                    if(pkgTypeValue != null && pkgTypeValue != '--None--') {
                        pkgDetailList = Database.query('select ' + String.escapeSingleQuotes(PackageCustomSettingFields) + ' from ERP7__Package_Details__c where (Package_Type__c =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\' or Name  =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\') Limit 1');                             
                        if(pkgDetailList.size() > 0) { Package2Create.Length__c = pkgDetailList[pkgDetailList.size() - 1].Length__c;
                                                      Package2Create.Width__c = pkgDetailList[pkgDetailList.size() - 1].Width__c;            
                                                      Package2Create.Height__c = pkgDetailList[pkgDetailList.size() - 1].Height__c;
                                                      Package2Create.Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].Weight_Unit__c;
                                                      if(comW.LogisticRecs[0].ERP7__Sales_Order__r.ERP7__Shipment_Type__c != null && comW.LogisticRecs[0].ERP7__Sales_Order__r.ERP7__Shipment_Type__c != '') Package2Create.Shipment_Type__c = comW.LogisticRecs[0].ERP7__Sales_Order__r.ERP7__Shipment_Type__c;            
                                                     }
                    } else errorMsg2 = 'Sorry, selected package type not available.';
                }
                
                //if(soIds.size() > 0) Package2Create.Logistic__c = (new list<Id>(soIds))[0]; ERP7__Order_S__c  
                if(soIds.size() > 0) { Id lId = soIds[0]; Package2Create.Logistic__c = lId;}
                List<packageWrapper> packageWrapperList = new List<packageWrapper>();
                Package2Create.Status__c = 'Deposited To Front Desk'; 
                Package2Create.ERP7__PO_Reference__c = PONumber;
                if(Packages != null) Package2Create.Name = Package2Create.Barcode__c = Package2Create.Name__c = 'Pkg-'+ orderNumber  +'-'+ Integer.valueof(Packages.size()+1);
                for(Wrappers wrap : soliWrapperList) { 
                    if(wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__c != null){
                        
                        if(wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Shipment_Type__c != null) Package2Create.Shipment_Type__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Shipment_Type__c;  
                        if(wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Special_Instructions__c != null) Package2Create.Description__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Special_Instructions__c; 
                        if(wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__r.ERP7__UPS_Service__c != null) Package2Create.Shipment_Service_Type__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__r.ERP7__UPS_Service__c; 
                        if(wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Purchase_Order_Number__c != null) Package2Create.PO_Reference__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Purchase_Order_Number__c;
                        if(wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__c != null && wrap.LOLI.ERP7__Logistic__r.ERP7__Sales_Order__c != null) Package2Create.ERP7__Sales_Order__c = wrap.LOLI.Sales_Order_Line_Item__r.Sales_Order__c;
                    }
                    if(wrap.LOLI.ERP7__Order_Product__r.OrderId != null){
                        system.debug('wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c : '+wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c);
                        if(wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c != null) Package2Create.Shipment_Type__c = wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c;  
                        if(wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c != null) Package2Create.Description__c = wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c; 
                        if(wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__UPS_Service__c != null) Package2Create.Shipment_Service_Type__c = wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__UPS_Service__c; 
                        if(wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Shipment_Preference_Speed__c != null && wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Shipment_Preference_Speed__c != '--None--') Package2Create.Shipment_Service_Type__c = wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Shipment_Preference_Speed__c; 
                        if(wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c != null) Package2Create.PO_Reference__c = wrap.LOLI.ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c;
                        if(wrap.LOLI.ERP7__Order_Product__r.Order != null && wrap.LOLI.ERP7__Logistic__r.ERP7__Order_S__c != null) Package2Create.ERP7__Order__c = wrap.LOLI.ERP7__Order_Product__r.OrderId;
                        
                    }
                   
                    if(wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != null ){
                        Package2Create.ERP7__Transfer_Order__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c;
                        if(wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.ERP7__Shipment_type__c != null && wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.ERP7__Shipment_type__c != '') Package2Create.Shipment_Type__c = wrap.LOLI.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.ERP7__Shipment_type__c;
                    }   
                    if(wrap.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != null ){
                        Package2Create.ERP7__Purchase_Order__c = wrap.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c;
                        if(wrap.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.ERP7__Shipment_Type__c != null && wrap.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.ERP7__Shipment_type__c != '') Package2Create.Shipment_Type__c = wrap.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.ERP7__Shipment_type__c;
                    }   
                    if(wrap.isSOLIawaiting == true) { 
                        if(!(wrap.LOLI.Product__r.ERP7__Is_Kit__c && wrap.LOLI.Explode__c)){
                            packageWrapper PW = new packageWrapper();                            
                            PW.pkgSelected = true; PW.Loli = wrap.loli;
                            PW.qtyToPick = wrap.LOLI.Picked_Quantity__c;
                            if(wrap.LOLI.Picked_Quantity__c != null && wrap.LOLI.Packed_Quantity__c != null) 
                                PW.qtyToPack = wrap.LOLI.Picked_Quantity__c - wrap.LOLI.Packed_Quantity__c;
                            else PW.qtyToPack = wrap.LOLI.Picked_Quantity__c;
                            if(PW.LOLI.Product__r.Weight__c != null && Customer == PW.LOLI.Logistic__r.Account__c) Package2Create.Weight__c += (PW.LOLI.Product__r.Weight__c * PW.qtyToPack);                                                                
                            
                            if(PW.LOLI.Price_Product__c != null  && Customer == PW.LOLI.Logistic__r.Account__c) Package2Create.Declared_Value__c += (PW.LOLI.Price_Product__c * PW.qtyToPack);
                            
                            if(PW.qtyToPack != 0) packageWrapperList.add(PW);
                        } else{
                            packageWrapper PW = new packageWrapper();                            
                            PW.pkgSelected = true; PW.loli = wrap.loli; 
                            PW.mrp = wrap.mrp;
                            PW.qtyToPick = wrap.MRP.Picked_Quantity__c;
                            if(wrap.MRP.Picked_Quantity__c != null && wrap.MRP.Packed_Quantity__c != null)  PW.qtyToPack = wrap.MRP.Picked_Quantity__c - wrap.MRP.Packed_Quantity__c;
                            else PW.qtyToPack = wrap.MRP.Picked_Quantity__c;
                            
                            if(PW.MRP.MRP_Product__r.Weight__c != null  && Customer == PW.LOLI.Logistic__r.Account__c) Package2Create.Weight__c += (PW.MRP.MRP_Product__r.Weight__c * PW.qtyToPack);                                                                
                            //if(PW.LOLI.Price_Product__c != null) Package2Create.Declared_Value__c += (PW.LOLI.Price_Product__c * PW.qtyToPack);
                            if(PW.qtyToPack != 0) packageWrapperList.add(PW);
                        }
                    }
                } 
                Set<Id> custIds = new Set<Id>();
                List<SelectOptions> Customers = new List<SelectOptions>();
                Set<SelectOptions> AllCustomers = new Set<SelectOptions>(); 
                for(packageWrapper wrap : packageWrapperList) {  wrap.pkgSelected = false;
                    if(!custIds.contains(wrap.loli.Logistic__r.Account__c)) AllCustomers.add(new SelectOptions(wrap.loli.Logistic__r.Account__c,wrap.loli.Logistic__r.Account__r.Name));
                    custIds.add(wrap.loli.Logistic__r.Account__c);
                    if(Customer == null || Customer == '') Customer = wrap.loli.Logistic__r.Account__c;
                }
                Customers.addAll(AllCustomers);
                if(Customers.size() > 0 && (Customers[0].label != '' && Customers[0].label != null) && (Customers[0].value != '' && Customers[0].value != null) ) CustomerPresent = true;
                List<packageWrapper> pwln = new list<packageWrapper>();
                //for(Id custId : custIds){
                for(packageWrapper wrap : packageWrapperList){
                    if(wrap.loli.Logistic__r.Account__c == Customer) {  wrap.pkgSelected = true;  pwln.add(wrap);
                    }
                }
                //}
               
                packageWrapperList = pwln;
                
                comW.lineItemWrapperList = lineItemWrapperList;
                comW.packageWrapperList = packageWrapperList;
                
                system.debug('comW.LogisticRecs[0].ERP7__Shipment_type__c : '+comW.LogisticRecs[0].ERP7__Shipment_type__c);
                system.debug('comW.LogisticRecs[0].ERP7__Shipping_Preferences__c : '+comW.LogisticRecs[0].ERP7__Shipping_Preferences__c);
                if(comW.LogisticRecs[0].ERP7__Shipment_type__c != null) Package2Create.Shipment_Type__c = comW.LogisticRecs[0].ERP7__Shipment_type__c; // added this by khaleqq && comW.LogisticRecs[0].Shipment_type__c != '--None--'
                if(comW.LogisticRecs[0].ERP7__Shipping_Preferences__c != null) Package2Create.ERP7__Shipment_Service_Type__c = comW.LogisticRecs[0].ERP7__Shipping_Preferences__c;
                if(comW.LogisticRecs[0].ERP7__Special_Instructions__c != null) Package2Create.ERP7__Description__c = comW.LogisticRecs[0].ERP7__Special_Instructions__c;
                    
                
                Schema.DescribeFieldResult fieldResultCntry = ERP7__Package__c.ERP7__Weight_Unit__c.getDescribe();
                List < Schema.PicklistEntry > cntry = fieldResultCntry.getPicklistValues();
                for(Schema.PicklistEntry f: cntry) {
                    comW.WeightUnit.add(new SelectOptions(f.getValue(), f.getLabel()));
                }
                
                fieldResultCntry = ERP7__Package__c.ERP7__Dimension__c.getDescribe();
                cntry = fieldResultCntry.getPicklistValues();
                
                for(Schema.PicklistEntry f: cntry) {
                    comW.DimensionUnit.add(new SelectOptions(f.getValue(), f.getLabel()));
                }
                
                fieldResultCntry = ERP7__Package__c.ERP7__Shipment_Type__c.getDescribe();
                cntry = fieldResultCntry.getPicklistValues();
                 String defaultShipmentTypeLabel = '';//added by khaleeq
                for(Schema.PicklistEntry f: cntry) {
                    comW.ShipmentType.add(new SelectOptions(f.getValue(), f.getLabel()));
                    if (f.isDefaultValue()) {       // if section added by khaleeq
                        defaultShipmentTypeLabel = f.getLabel();
                    }
                }
                
                fieldResultCntry = ERP7__Package__c.ERP7__Package_Type__c.getDescribe();
                cntry = fieldResultCntry.getPicklistValues();
                for(Schema.PicklistEntry f: cntry) {
                    comW.PackageType.add(new SelectOptions(f.getValue(), f.getLabel()));
                }
                
                if(Package2Create.Shipment_Type__c == null || Package2Create.Shipment_Type__c == '' || Package2Create.Shipment_Type__c == '--None--') {  
                    if(defaultShipmentTypeLabel != ''){     // if section added by khaleeeq
                        Package2Create.Shipment_Type__c = defaultShipmentTypeLabel; 
                    }else{Package2Create.Shipment_Type__c =comW.ShipmentType[0].Label;  //changed to label from value
                         }
                    system.debug('iff inn');
                }
                
                system.debug('Package2Create.Shipment_Type__c after: '+Package2Create.Shipment_Type__c);
                comW.Package2Create = Package2Create;
                
                //arshad - below not needed for mobile app?
                if(pkgIds.size() > 0){ 
                    List<ERP7__Package__c> pack = [Select id,Name,ERP7__Sales_Order__c,ERP7__Order__c,ERP7__Shipment_Type__c from ERP7__Package__c where Id=:pkgIds];
                    List<Id> SalesId = new List<Id>();
                    List<id> OrdIds = new List<Id>();
                    string shipmenttype = '';
                    for(ERP7__Package__c pp : pack){
                        shipmenttype = pp.ERP7__Shipment_Type__c;
                        if(pp.ERP7__Sales_Order__c != null){ SalesId.add(pp.ERP7__Sales_Order__c);}
                        if(pp.ERP7__Order__c != null){ OrdIds.add(pp.ERP7__Order__c);}
                    }
                    if(SalesId.size() > 0 && String.isNotEmpty(shipmenttype)){
                        ERP7__Sales_Order__c so = [select Id, Name,ERP7__Shipment_Type__c from ERP7__Sales_Order__c where Id =: SalesId[0]];
                        if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Shipment_Type__c.isUpdateable()) so.ERP7__Shipment_Type__c = shipmenttype;
                        if(Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { update so; } else{ errorMsg = ' Not allwed to update sales Order';}
                    }
                    if(OrdIds.size() > 0 && String.isNotEmpty(shipmenttype)){	Order ord = [select Id, Name,ERP7__Shipment_Type__c from Order where Id =: OrdIds[0]];
                        if(Schema.sObjectType.Order.fields.ERP7__Shipment_Type__c.isUpdateable()) ord.ERP7__Shipment_Type__c = shipmenttype;
                        if(Schema.sObjectType.Order.isUpdateable()){PreventRecursiveLedgerEntry.testCasesTransactions= true;/*added on 02_1_24  shagufths to prevent recursive call to order  and order item trigger*/ update ord; } else{ errorMsg = ' Not allwed to update Order';}
                    }
                }
                
                comW.errorMsg2 = errorMsg2; 
                comW.Customers = Customers; 
                comW.Customer = Customer; 
                comW.CustomerPresent = CustomerPresent;
                comW.createPack = createPack;
                comW.isAwaiting = isAwaiting;
                comW.pkgTypeValue = pkgTypeValue;
                 
                ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
                customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
                if(customList == null){ 
                    customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
                    if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
                }
                if(customList != null){
                    comW.showSSType = customList.ERP7__Pack_Shipment_Service_Type_Display__c;
                    comW.disablePackName = customList.ERP7__disablePackName__c;
                    comW.disablePackDeclaredValue = customList.ERP7__disablePackDeclaredValue__c;
                    comW.allowZerodeclaredValue = customList.ERP7__Allow_zero_declared_value_in_Pack__c;
                    comW.disableShipType = customList.ERP7__Disable_Shipment_type_in_Pack__c;
                    comW.Allowscanning = customList.ERP7__Enable_Scanning_for_Flows__c;
                    comW.ShowLangOptionForPackList = customList.ERP7__ShowLangOptionForPackList__c;
                    comW.ReplacePackListOrgURL = customList.ERP7__Replace_PackList_OrgURL__c;
                    comW.enableUPSRestAPI = customList.ERP7__Enable_UPS_Rest_APIs__c;
                    comW.enableFedexRestAPI = customList.ERP7__Enable_Fedex_Rest_APIs__c;
                }
                
            } else errorMsg = 'Please select an Order to proceed.';             
        } catch(Exception e) { errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        comW.exceptionError = errorMsg;
        return comW;
    }
    
    @AuraEnabled
    public static comWrap editPackage(String pack2updateId){
        comWrap comW = new comWrap();
        String errorMsg = '';
        try {
            String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');    
            String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
            utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
            logLineFields += ', ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c, ERP7__Order_Product__r.OrderId,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c,ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
                +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name,ERP7__Order_Product__r.OrderItemNumber, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c';
            String PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
            utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');            
            String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');  
            String MRPFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(MRPFields.split(','),'ERP7__MRP__c');
            String packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
            utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');
            String PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
            utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c');
            
            Set<Id> soIds = new Set<Id>();
            List<Package__c> Packages = new List<Package__c>();
            List<Package_List__c> packageLists = new List<Package_List__c>();
            Package__c Package2Create = new Package__c();
            List<packageWrapper> packageWrapperList = new List<packageWrapper>();
            Map <Id, Package__c> packMap = new Map <Id, Package__c>();
            List<Shipment__c> Shipments = new List<Shipment__c>();
            List<ERP7__Logistic_Line_Item__c>currentItems = new List<ERP7__Logistic_Line_Item__c>();        
            List<lineItemWrapper> lineItemWrapperList = new List<lineItemWrapper>();
            Boolean createPack = false;
            Boolean isAwaiting = false; 
            if(Schema.sObjectType.Package__c.fields.Declared_Value__c.isCreateable() && Schema.sObjectType.Package__c.fields.Declared_Value__c.isUpdateable()){
                
                comW.enableDecalre = true;
            }
            else{
                comW.enableDecalre = false; 
            }
            if(pack2updateId != null) {
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else { Package2Create = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,ERP7__Order__r.AccountId,Sales_Order__r.Account__c, Shipment__r.Name, Logistic__r.ERP7__Ready_To_Ship__c from Package__c where (Id =\'' + String.escapeSingleQuotes(pack2updateId) + '\')');  
                      packMap = new Map <Id, Package__c>(Packages);
                     }
                currentItems = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c = \'' + String.escapeSingleQuotes(Package2Create.Logistic__c) + '\' order by ERP7__Logistic__c ASC');
                
                String status = 'Cancelled';        
                String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Shipment__c','UPS_Shipping');
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from ERP7__Shipment__c where '+
                                                  '(ERP7__Return_Shipment__c = false AND ERP7__Logistic__c = \'' + String.escapeSingleQuotes(Package2Create.Logistic__c) + '\' And ERP7__Status__c !=\'' + String.escapeSingleQuotes(status) + '\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');
                     }
                if(!Schema.sObjectType.Package_List__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package_List__c.Label));
                else { packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ', ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c, Logistic__r.Account__c, Logistic__r.Account__r.Name from ERP7__Package_List__c where (ERP7__Package__c =\'' + String.escapeSingleQuotes(Package2Create.Id) + '\' And ERP7__Active__c = true) Order by CreatedDate Asc'); }                        
                if(Package2Create != null) Packages.add(Package2Create);
                lineItemWrapperList = new List<lineItemWrapper>();
                for(Package__c P : Packages) { 
                    lineItemWrapper LW = new lineItemWrapper(); 
                    LW.pack = P;
                    if(P.Weight_Unit__c == 'KGS') LW.units = 'cm';
                    else LW.units = 'in';
                    
                    for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                    LW.NoofLineItems = P.Package_Quantity__c;                
                    lineItemWrapperList.add(LW);
                }    
                
                packageWrapperList = new List<packageWrapper>();                                
                for(ERP7__Logistic_Line_Item__c soli : currentItems){
                    packageWrapper PW = new packageWrapper();
                    List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>();
                    for(Package_List__c pl : packageLists){
                        if(pl.ERP7__Logistic_Line_Item__c == soli.Id) { 
                            PW.Loli = soli;
                            PW.qtyToPick = pl.ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c;
                            PW.qtyToPack = pl.Quantity__c;                                
                            innerPackageWrapper ipw = new innerPackageWrapper();
                            ipw.pack = String.valueof(pl.Package__c);
                            ipw.packege = packMap.get(pl.Package__c); 
                            ipw.packageList = pl;
                            
                            ipw.packList.add(new SelectOptions('','--None--'));
                            if(ipw.packege.Status__c == 'Shipped' || ipw.packege.Status__c == 'Picked Up' || ipw.packege.Status__c == 'Delivered')
                                ipw.packList.add(new SelectOptions(String.valueof(ipw.packege.Id),ipw.packege.Name__c)); 
                            
                            for(Package__c P : Packages){
                                if((P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered') && (ipw.packege.Status__c != 'Shipped' && ipw.packege.Status__c != 'Picked Up' && ipw.packege.Status__c != 'Delivered'))
                                    ipw.packList.add(new SelectOptions(String.valueof(P.Id),P.Name__c));  
                            } 
                            ipwList.add(ipw);
                        }
                    } 
                    if(ipwList.size() > 0) { PW.innerPackList = ipwList; packageWrapperList.add(PW); }
                } CreatePack = true; isAwaiting = false;    
            }       
            comW.lineItemWrapperList = lineItemWrapperList;
            comW.Package2Create = Package2Create;
            comW.packageWrapperList = packageWrapperList;
            comW.createPack = createPack;
            comW.isAwaiting = isAwaiting;                  
        } catch(Exception e) { errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        comW.exceptionError = errorMsg;
        return comW;
    }
    
    @AuraEnabled
    public static comWrap deletePackage(String pack2updateId, String LogisticIds){
        comWrap comW = new comWrap();
        String errorMsg = '';
        try {
            String packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
            utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');
            String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
            utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
            logLineFields += ', ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c,ERP7__Order_Product__r.OrderId,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c,ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
                +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c';
            
            Set<Id> soliIds = new Set<Id>();
            MAP<Id, ERP7__Logistic_Line_Item__c > soliMap = new MAP<Id, ERP7__Logistic_Line_Item__c >();
            if(pack2updateId != null) {
                List<Package_List__c> packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,ERP7__Order_Product__r.ERP7__Packed_Quantity__c,Sales_Order_Line_Item__r.Packed_Quantity__c from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(pack2updateId) + '\' And Active__c = true) Order by CreatedDate Asc');
                for(Package_List__c pls: packList) { soliIds.add(pls.ERP7__Logistic_Line_Item__c); }
                List< ERP7__Logistic_Line_Item__c > soliList = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where Id In: soliIds'); 
                for(Package_List__c pl: packList) {
                    for(ERP7__Logistic_Line_Item__c solis: soliList) {
                        if(pl.ERP7__Logistic_Line_Item__c == solis.Id) {
                            if(solis.Packed_Quantity__c != null) {
                                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Packed_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Packed_Quantity__c.isUpdateable()) solis.Packed_Quantity__c = solis.Packed_Quantity__c - pl.Quantity__c;
                                soliMap.put(solis.Id, solis);
                            } break;
                        }
                    }
                }
            }
            if(soliMap.size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()) { upsert soliMap.values(); } else{errorMsg = 'Not allowed to upsert loli';}
            if(pack2updateId != null && Package__c.sObjectType.getDescribe().isDeletable()) { delete new Package__c(Id = pack2updateId);   } else{ errorMsg = 'Not allowed to delete package';}         
            comW = createPacksInit(LogisticIds, '');
        } catch(Exception e) { errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        comW.exceptionError = errorMsg;
        return comW;
    }
    
    @AuraEnabled
    public static comWrap populatePackDetails(String Package2Create1, String pkgTypeValue){
        ERP7__Package__c Package2Create = (ERP7__Package__c) JSON.deserialize(Package2Create1, ERP7__Package__c.class);
        comWrap comW = new comWrap();
        String errorMsg = '';
        String errorMsg2 = '';
        try { 
            String PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
            utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c');  
            List<Package_Details__c> pkgDetailList = new List<Package_Details__c>();
            if(pkgTypeValue != null && pkgTypeValue != '--None--') {
                pkgDetailList = Database.query('select ' + String.escapeSingleQuotes(PackageCustomSettingFields) + ' from ERP7__Package_Details__c where (Package_Type__c =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\' Or Name=\'' + String.escapeSingleQuotes(pkgTypeValue) + '\' ) Limit 1');                             
                if(pkgDetailList.size() > 0) { 
                    Package2Create.Length__c = pkgDetailList[pkgDetailList.size() - 1].Length__c;  Package2Create.Width__c = pkgDetailList[pkgDetailList.size() - 1].Width__c;            
                    Package2Create.Height__c = pkgDetailList[pkgDetailList.size() - 1].Height__c;Package2Create.Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].Weight_Unit__c;	Package2Create.Weight__c = pkgDetailList[pkgDetailList.size() - 1].Weight__c;
                    //Package2Create.Shipment_Type__c = 'UPS';            
                } else errorMsg2 = 'Sorry, selected package type not available.';
            } else errorMsg2 = 'Sorry, selected package type not available.';
        } catch(Exception e) { errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        comW.exceptionError = errorMsg;
        comW.errorMsg2 = errorMsg2;
        comW.Package2Create = Package2Create;
        return comW;
    }
    
    @AuraEnabled
    public static comWrap updatePacks(String Package2Create1, String PackageWrapperListJs, String LogisticIds, Boolean IsAwaiting) {
        ERP7__Package__c Package2Create = (ERP7__Package__c) JSON.deserialize(Package2Create1, ERP7__Package__c.class); 
        comWrap comW = new comWrap();
        try { 
            Boolean error = false;  
            List<packageWrapper> packageWrapperList = (List<packageWrapper>) JSON.deserialize(PackageWrapperListJs, List<packageWrapper> .class);           
            if(packageWrapperList != null) {
                List<Package_List__c> PLS = new List<Package_List__c>();
                MAP<Id, ERP7__Logistic_Line_Item__c> soliMap = new MAP<Id, ERP7__Logistic_Line_Item__c>();
                MAP<Id, MRP__c> mrpMap = new MAP<Id, MRP__c>();
                
                if(!error) { 
                    String PackgeId ='';
                    if(Schema.sObjectType.ERP7__Package__c.fields.Active__c.isCreateable() && Schema.sObjectType.ERP7__Package__c.fields.Active__c.isUpdateable()) Package2Create.Active__c = true;
                    if(Package2Create != null && Schema.sObjectType.ERP7__Package__c.isCreateable() && Schema.sObjectType.ERP7__Package__c.isUpdateable()) { upsert Package2Create; } else{ comW.exceptionError = 'Not allowed to upsert package';}
                    
                    for(Integer i=1; i<=packageWrapperList.size(); i++) {
                        if(packageWrapperList[i-1].pkgSelected == true) { 
                            Package_List__c packageList = (packageWrapperList[i-1].innerPackList.size() > 0 && packageWrapperList[i-1].innerPackList[0].packageList.Id != Null)? new Package_List__c(id=packageWrapperList[i-1].innerPackList[0].packageList.Id) : new Package_List__c(Name = 'Package List - '+i);                            
                            if(Schema.sObjectType.Package_List__c.fields.Active__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Active__c.isUpdateable()){ packageList.Active__c = true; } else{}
                            if(Schema.sObjectType.Package_List__c.fields.Package__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Package__c.isUpdateable()){  packageList.Package__c = Package2Create.Id; } else{}
                            if(Schema.sObjectType.Package_List__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Quantity__c.isUpdateable()){ packageList.Quantity__c = packageWrapperList[i-1].qtyToPack;/* if(packageList.ERP7__RemaingQuantity__c == null) packageList.ERP7__RemaingQuantity__c= packageWrapperList[i-1].qtyToPack;*/} else{}
                            if(Schema.sObjectType.Package_List__c.fields.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()){  packageList.ERP7__Logistic_Line_Item__c = packageWrapperList[i-1].loli.Id; } else{}
                            if(Schema.sObjectType.Package_List__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Logistic__c.isUpdateable()){  packageList.Logistic__c = packageWrapperList[i-1].loli.Logistic__c; } else{}
                            
                            if(packageWrapperList[i-1].loli.Sales_Order_Line_Item__c != Null) {if(Schema.sObjectType.Package_List__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Sales_Order_Line_Item__c.isUpdateable()){  packageList.Sales_Order_Line_Item__c = packageWrapperList[i-1].loli.Sales_Order_Line_Item__c; } else{}
                                if(Schema.sObjectType.Package_List__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Sales_Order__c.isUpdateable()){  packageList.Sales_Order__c = packageWrapperList[i-1].loli.Sales_Order_Line_Item__r.Sales_Order__c;  } else{}
                            }
                            if(packageWrapperList[i-1].loli.ERP7__Order_Product__c != Null) { if(Schema.sObjectType.Package_List__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.ERP7__Order_Product__c.isUpdateable()){  packageList.ERP7__Order_Product__c = packageWrapperList[i-1].loli.ERP7__Order_Product__c; } else{ }
                                if(Schema.sObjectType.Package_List__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.ERP7__Order__c.isUpdateable()){  packageList.ERP7__Order__c = packageWrapperList[i-1].loli.ERP7__Order_Product__r.OrderId;  } else{}
                            }
                            if(packageWrapperList[i-1].loli.Work_Order_Line_Items__c != Null) {if(Schema.sObjectType.Package_List__c.fields.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Work_Order_Line_Items__c.isUpdateable()){  packageList.Work_Order_Line_Items__c = packageWrapperList[i-1].loli.Work_Order_Line_Items__c;  } else{ }
                                if(Schema.sObjectType.Package_List__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Work_Orders__c.isUpdateable()){   packageList.Work_Orders__c = packageWrapperList[i-1].loli.Work_Order_Line_Items__r.Work_Orders__c; } else{}
                            }
                            if(packageWrapperList[i-1].loli.ERP7__Purchase_Line_Items__c != Null) {   if(Schema.sObjectType.Package_List__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable()){  packageList.ERP7__Purchase_Line_Items__c = packageWrapperList[i-1].loli.ERP7__Purchase_Line_Items__c; }else{ }
                                if(Schema.sObjectType.Package_List__c.fields.ERP7__Purchase_Orders__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.ERP7__Purchase_Orders__c.isUpdateable()){ packageList.ERP7__Purchase_Orders__c = packageWrapperList[i-1].loli.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c; } else{ }
                            }
                            if(packageWrapperList[i-1].loli.Transfer_Order_Line_Item__c != Null) {    if(Schema.sObjectType.Package_List__c.fields.Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Transfer_Order_Line_Item__c.isUpdateable()){ packageList.Transfer_Order_Line_Item__c = packageWrapperList[i-1].loli.Transfer_Order_Line_Item__c;} else{}
                                if(Schema.sObjectType.Package_List__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Transfer_Order__c.isUpdateable()){  packageList.Transfer_Order__c = packageWrapperList[i-1].loli.Transfer_Order_Line_Item__r.Transfer_Order__c; } else{}
                            }
                            
                            if(!(packageWrapperList[i-1].loli.Product__r.ERP7__Is_Kit__c && packageWrapperList[i-1].loli.Explode__c)){
                                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Packed_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Packed_Quantity__c.isUpdateable()){
                                    if(packageWrapperList[i-1].loli.Packed_Quantity__c == null || packageWrapperList[i-1].loli.Packed_Quantity__c == 0) packageWrapperList[i-1].loli.Packed_Quantity__c = packageWrapperList[i-1].qtyToPack;
                                    else if(isAwaiting) packageWrapperList[i-1].loli.Packed_Quantity__c += packageWrapperList[i-1].qtyToPack;
                                    else packageWrapperList[i-1].loli.Packed_Quantity__c = packageWrapperList[i-1].loli.Packed_Quantity__c + packageWrapperList[i-1].qtyToPack - packageList.ERP7__Quantity__c;
                                }
                                soliMap.put(packageWrapperList[i-1].loli.Id, packageWrapperList[i-1].loli);
                            } else{
                                if(Schema.sObjectType.MRP__c.fields.Packed_Quantity__c.isCreateable() && Schema.sObjectType.MRP__c.fields.Packed_Quantity__c.isUpdateable()){
                                    if(packageWrapperList[i-1].mrp.Packed_Quantity__c == null || packageWrapperList[i-1].mrp.Packed_Quantity__c == 0) packageWrapperList[i-1].mrp.Packed_Quantity__c = packageWrapperList[i-1].qtyToPack;
                                    else if(isAwaiting) packageWrapperList[i-1].mrp.Packed_Quantity__c = packageWrapperList[i-1].mrp.Packed_Quantity__c + packageWrapperList[i-1].qtyToPack - packageList.ERP7__Quantity__c;
                                    else packageWrapperList[i-1].mrp.Packed_Quantity__c += packageWrapperList[i-1].qtyToPack;
                                }
                                mrpMap.put(packageWrapperList[i-1].mrp.Id, packageWrapperList[i-1].mrp);
                                if(Schema.sObjectType.Package_List__c.fields.MRP_Material_Requirement_Planning__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.MRP_Material_Requirement_Planning__c.isUpdateable()){  packageList.MRP_Material_Requirement_Planning__c = packageWrapperList[i-1].mrp.Id; } else{ }
                                soliMap.put(packageWrapperList[i-1].loli.Id, packageWrapperList[i-1].loli);
                            }
                            
                            PLS.add(packageList);
                        }                        
                    } 
                    if(PLS.size() > 0) { 
                        PreventRecursiveLedgerEntry.testCasesTransactions = true;
                        if(soliMap.Values().size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()){ upsert soliMap.Values(); } else{ comW.exceptionError = 'Not allowed to upsert LOLI';}
                        if(mrpMap.Values().size() > 0 && Schema.sObjectType.MRP__c.isCreateable() && Schema.sObjectType.MRP__c.isUpdateable()) { upsert mrpMap.Values(); }else{ comW.exceptionError = 'not allowed to upsert MRP';}
                        if(Schema.sObjectType.Package_List__c.isCreateable() && Schema.sObjectType.Package_List__c.isUpdateable()) { upsert PLS; } else{ comW.exceptionError = 'not allowed to upsert Package list';}
                        
                        if(soliMap.Values().size() > 0){
                            PreventRecursiveLedgerEntry.LogisticLineRollup = true;
                            List<Id> loliIds = new List<Id>();
                            for(Logistic_Line_Item__c loli : soliMap.Values()) loliIds.add(loli.Id);
                            if(loliIds.size() > 0) RollUpSummaryFuture.rollUp2SolisTrigger(loliIds);
                        }
                    }  
                    comW = createPacksInit(LogisticIds, '');
                }            
            }
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap createShipments(String LogisticIds) {
        comWrap comW = new comWrap();
        List<Wrappers> shipmentWrapperList = new List<Wrappers>();
        String errorMsg = '';
        try {
            String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c'); 
            String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');
            List<String> soIdss = (List<String>) JSON.deserialize(LogisticIds, List<String> .class);
            String selectedSite = '';
            Set<Id> OrderIds = new Set<Id>();
            Set<Id> spIds = new Set<Id>();
            List<Shipment__c> shipmentList = new List<Shipment__c>();
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){ 
                comW.Allowscanning = FC.ERP7__Enable_Scanning_for_Flows__c; 
                comW.ReplaceShipSlipOrgURL = FC.ERP7__Replace_ShipSlip_OrgURL__c; 
                comW.ShowLangOptionForShipSlip = FC.ERP7__ShowLangOptionForShipSlip__c; 
                comW.enableUPSRestAPI = FC.ERP7__Enable_UPS_Rest_APIs__c; 
                comW.enableFedexRestAPI = FC.ERP7__Enable_Fedex_Rest_APIs__c;
                comW.enableFedexRestAPI = FC.ERP7__Enable_Fedex_Rest_APIs__c;
            }
            
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                       ERP7__Organisation_Business_Unit__c
                       From ERP7__Employees__c
                       Where ERP7__Employee_User__c = : UserInfo.getUserId()
                       Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) { 
                comW.Employee = empList[0]; 
                
                if(comW.Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Primary__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Site__r.Name
                                                                                  From ERP7__Distribution_Channel__c
                                                                                  Where ERP7__Channel__c = : comW.Employee.ERP7__Channel__c And ERP7__Active__c = true And ERP7__Site__c != Null
                                                                                  Order By ERP7__Primary__c Desc];
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {
                            comW.channelSites.add(new SelectOptions(DC.ERP7__Site__c, DC.Name));
                        }
                    } 
                } 
            } 
            comW.LogisticRecs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' , ERP7__Order_S__r.Name,ERP7__Order_S__r.OrderNumber,ERP7__Sales_Order__r.Name, ERP7__To_Address__r.ERP7__Address_Line1__c, ERP7__To_Address__r.ERP7__Address_Line2__c, ERP7__To_Address__r.ERP7__Address_Line3__c, ERP7__To_Address__r.ERP7__City__c, ERP7__To_Address__r.ERP7__County__c, '+
                                               +'ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Channel__r.Name, ERP7__Distribution_Channel__r.ERP7__Site__r.Name,  ERP7__To_Address__r.ERP7__Country__c, ERP7__To_Address__r.ERP7__State__c, ERP7__To_Address__r.ERP7__Postal_Code__c, ERP7__Account__r.Name from ERP7__Logistic__c where Id IN :soIdss'); 
            if(comW.LogisticRecs.size() > 0){
                comW.SiteName = comW.LogisticRecs[0].ERP7__Distribution_Channel__r.ERP7__Site__r.Name;
                comW.ChannelName = comW.LogisticRecs[0].Channel__r.Name;
                comW.ChannelId = comW.LogisticRecs[0].Channel__c;
                comW.selectedSite = comW.LogisticRecs[0].ERP7__Distribution_Channel__r.ERP7__Site__c;
                selectedSite = comW.selectedSite;
            }
            List<Id> soIds = new List<Id>();
            for(ERP7__Logistic__c logistic :comW.LogisticRecs){
                soIds.add(logistic.Id);
                if(logistic.ERP7__Sales_Order__c != Null) OrderIds.add(logistic.ERP7__Sales_Order__c);
                if(logistic.ERP7__Order_S__c != Null) OrderIds.add(logistic.ERP7__Order_S__c);
                if(logistic.ERP7__Purchase_Order__c != Null) OrderIds.add(logistic.ERP7__Purchase_Order__c);
                if(logistic.ERP7__Work_Order__c != Null) OrderIds.add(logistic.ERP7__Work_Order__c);
                if(logistic.ERP7__Transfer_Order__c != Null) OrderIds.add(logistic.ERP7__Transfer_Order__c);
                spIds.add(logistic.Channel__c);
            }
            
            if(soIds.size() > 0) {
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { shipmentList = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' ,RecordType.Name, ERP7__Order__r.Name,Sales_Order__r.Name, Customer__r.Name, Shipping_Address__r.Customer__r.Name, Shipping_Address__r.Address_Line1__c, Shipping_Address__r.Address_Line2__c, Shipping_Address__r.Address_Line3__c, '+
                                                     +' Shipping_Address__r.City__c, Shipping_Address__r.County__c, Shipping_Address__r.Country__c, Shipping_Address__r.Contact__r.Phone, Shipping_Address__r.Contact__r.Fax, Shipping_Address__r.Contact__r.Name, Shipping_Address__r.Contact__r.Email, '+
                                                     +' Shipping_Address__r.State__c, Shipping_Address__r.Postal_Code__c from ERP7__Shipment__c where (ERP7__Logistic__c In: soIds And ERP7__Active__c = true AND ERP7__Return_Shipment__c = false) Order by CreatedDate Asc');
                     }
                for(Shipment__c shp: shipmentList) { Wrappers wrap = new Wrappers(); wrap.shipM = shp;
                                                    if(wrap.shipM.RecordType.Name == 'UPS Shipping') wrap.shipmentType = 'UPS';
                                                    else if(wrap.shipM.RecordType.Name == 'Internal Shipping') wrap.shipmentType = 'Shipment';
                                                    else if(wrap.shipM.RecordType.Name == 'Fedex Shipping') wrap.shipmentType = 'FedEx';
                                                    else if(wrap.shipM.RecordType.Name == 'DHL Shipping') wrap.shipmentType = 'DHL';
                                                    else if(wrap.shipM.RecordType.Name == 'USPS Shipping') wrap.shipmentType = 'USPS';
                                                    else if(wrap.shipM.RecordType.Name == 'Canada Post shipping') wrap.shipmentType = 'Canada Post';
                                                    if(shp.ERP7__TrackingNumber__c != null) wrap.trackingNo += shp.ERP7__TrackingNumber__c.replace(',','<br/>');
                                                    shipmentWrapperList.add(wrap);
                                                   } 
            } else errorMsg = 'Please select an order to proceed.';
            comW.shipmentWrapperList = shipmentWrapperList;
            comW.exceptionError = errorMsg;
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap deleteShipments(String ShipmentId, String LogisticIds){
        comWrap comW = new comWrap();
        String errorMsg = '';
        try {
            
            String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');
            ERP7__Shipment__c ship = [Select Id, ERP7__TrackingNumber__c, ERP7__Tracking_Number__c ,ERP7__Package__c ,ERP7__Package__r.ERP7__Tracking_Number__c,ERP7__Order__c ,ERP7__Order__r.ERP7__Tracking_Number__c ,ERP7__Sales_Order__c ,ERP7__Sales_Order__r.ERP7__Tracking_Number__c from ERP7__Shipment__c where Id=:ShipmentId];
            if(ship.ERP7__Sales_Order__c!= null){
                ERP7__Sales_Order__c SOupdate = [Select Id , ERP7__Tracking_Number__c from ERP7__Sales_Order__c where Id=:ship.ERP7__Sales_Order__c];
                if(SOupdate!= null) {if(SOupdate.ERP7__Tracking_Number__c == ship.ERP7__TrackingNumber__c){ if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isUpdateable()) SOupdate.ERP7__Tracking_Number__c = ''; if(Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { update SOupdate;} else{ errorMsg = 'Not allowed to update tracking number of order';} } }
            }
            if(ShipmentId!= null){
                set<Id> packIds = new set<Id>();
                List<ERP7__Package__c> packupdate = [Select Id , ERP7__Shipment__c,ERP7__Tracking_Number__c from ERP7__Package__c where ERP7__Shipment__c=:ShipmentId];
                if(packupdate!= null && packupdate.size() > 0) {
                    for(ERP7__Package__c pack : packupdate){
                        if(pack.ERP7__Tracking_Number__c == ship.ERP7__TrackingNumber__c){ 
                            if(Schema.sObjectType.ERP7__Package__c.fields.ERP7__Tracking_Number__c.isUpdateable()) pack.ERP7__Tracking_Number__c = ''; 
                            packIds.add(pack.Id);
                            
                        }
                    }
                    
                    if(Schema.sObjectType.ERP7__Package__c.isUpdateable()){ update packupdate;} else{errorMsg = 'Not allowed to update package track number';} 
                    if(packIds.size() >  0){
                        Set<Id> soliIds = new Set<Id>();
                        MAP<Id, ERP7__Logistic_Line_Item__c > soliMap = new MAP<Id, ERP7__Logistic_Line_Item__c >();
                        List<Package_List__c> packList = [select  Id,Name ,Quantity__c,ERP7__Logistic_Line_Item__c,ERP7__Order_Product__r.ERP7__Packed_Quantity__c,Sales_Order_Line_Item__r.Packed_Quantity__c from Package_List__c where (Package__c  In : packIds  And Active__c = true) Order by CreatedDate Asc];
                        for(Package_List__c pls: packList) { soliIds.add(pls.ERP7__Logistic_Line_Item__c); }
                        List< ERP7__Logistic_Line_Item__c > soliList = [Select Id,Name,ERP7__Shipped_Quantity__c from ERP7__Logistic_Line_Item__c where Id In: soliIds];
                        for(Package_List__c pl: packList) {
                            for(ERP7__Logistic_Line_Item__c solis: soliList) {
                                if(pl.ERP7__Logistic_Line_Item__c == solis.Id) {
                                    if(solis.ERP7__Shipped_Quantity__c != null) {
                                        if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Shipped_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Shipped_Quantity__c.isUpdateable()) solis.ERP7__Shipped_Quantity__c = solis.ERP7__Shipped_Quantity__c - pl.Quantity__c;
                                        soliMap.put(solis.Id, solis);
                                    } break;
                                }
                            }
                        }
                        if(soliMap.size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()) { upsert soliMap.values(); } else{errorMsg = 'Not allowed to upsert loli';}
                        
                    }
                }
            }
            
            
            if(ship.ERP7__Order__c!= null){  Order ordupdate = [Select Id , ERP7__Tracking_Number__c from Order where Id=:ship.ERP7__Order__c];
                                           if(ordupdate!= null) {if(ordupdate.ERP7__Tracking_Number__c == ship.ERP7__TrackingNumber__c){ if(Schema.sObjectType.Order.fields.ERP7__Tracking_Number__c.isUpdateable()) ordupdate.ERP7__Tracking_Number__c = ''; if(Schema.sObjectType.Order.isUpdateable()){ update ordupdate;} else{ errorMsg = 'Not allowed to update tracking number of order';} } }
                                          }
            
            if(ShipmentId != null && ERP7__Shipment__c.sObjectType.getDescribe().isDeletable()) {
                delete new ERP7__Shipment__c(Id =ShipmentId);
            }  else{errorMsg ='Not allowed to delete'; }        
            comW = createShipments(LogisticIds);
        } catch(Exception e) {
            errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
            system.debug('err~>'+e.getMessage() +' Line Number @ : '+ e.getStackTraceString());
        }
        comW.exceptionError = errorMsg;
        return comW;
    }
    
    @AuraEnabled
    public static comWrap scanLogistics(String barcode) {
        comWrap comW = new comWrap();
        try { 
            String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');    
            String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
            utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
            logLineFields += ', ERP7__Logistic__r.ERP7__Order_S__c,ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c,ERP7__Order_Product__r.OrderId,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c,ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
                +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c';
            String PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
            utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');            
            String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');
            
            List<ERP7__Logistic__c> Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ', ERP7__Order_S__r.Name,ERP7__Order_S__r.OrderNumber,ERP7__Sales_Order__r.Name , ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, '+
                                                          +' ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where ERP7__Active__c = true And Total_Quantity__c > 0 And (ERP7__Type__c =\'Outbound\') And (Barcode__c =\'' + String.escapeSingleQuotes(barcode.trim()) + '\' OR ERP7__Barcode_S__c = \'' + String.escapeSingleQuotes(barcode.trim()) + '\' OR ERP7__Logistic_Barcode__c = \'' + String.escapeSingleQuotes(barcode.trim()) + '\') Order by Expected_Date__c Asc Limit 1');
            
            Set<Id> loIds = new Set<Id>();
            List< ERP7__Logistic_Line_Item__c > loliList = new List< ERP7__Logistic_Line_Item__c >();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>();
            for(ERP7__Logistic__c log : Logs) { loIds.add(log.Id); }                                   
            if(loIds.size() > 0) {
                if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic_Line_Item__c.Label));
                else loliList = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where (ERP7__Logistic__c In : loIds)');
                
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from ERP7__Package__c where (ERP7__Logistic__c In: loIds)'); 
                
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from ERP7__Shipment__c where (ERP7__Logistic__c In: loIds AND ERP7__Return_Shipment__c = false)'); 
            }
            if(Logs.size() > 0) {
                for(ERP7__Logistic__c log : Logs) { 
                    Wrappers wrap = new Wrappers();  
                    for(ERP7__Logistic_Line_Item__c loli : loliList) { 
                        if(loli.ERP7__Logistic__c == log.Id && loli.Picked_Quantity__c != loli.Packed_Quantity__c) { 
                            wrap.isAvailablePackages = true; break; 
                        } 
                    }
                    for(Package__c pkg : pkgList) { if(pkg.ERP7__Logistic__c == log.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) { 
                        if(ship.ERP7__Logistic__c == log.Id) { wrap.isAvailableShipments = true;
                                                              if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++;
                                                              if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                                                             } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;
                    wrap.Logistic = log;       wrap.soSelected = true;      comW.Logistics.add(wrap);
                }
            } 
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    // @AuraEnabled
    // public static comWrap scanLines(String barcode, Integer ScanNo, String SWL) {
    //     comWrap comW = new comWrap();
    //     // try { 
    //     string errorMsg = '';
    //     string barcodeLocMsg = '';
    //     string mybarcode = barcode.trim();
    //     system.debug('mybarcode : '+mybarcode);
    //     List<Wrappers> soliWrapperList = (List<Wrappers>) JSON.deserialize(SWL, List<Wrappers> .class);
        
    //     List<ERP7__Logistic_Line_Item__c> loliListcheck;
    //     List<Product2> ProdList = new List<Product2>();
    //     List<Site__c> siteList = new List<Site__c>();            
    //     List<Location__c> SSLList = new List<Location__c>();
    //     List<StorageContainer__c> binList = new List<StorageContainer__c>();
    //     List<ERP7__Batch__c> verifyBatches = new List<ERP7__Batch__c>();     
    //     List<ERP7__Serial_Number__c> verifySerials = new List<ERP7__Serial_Number__c>();     
    //     List< ERP7__BOM__c > PackageBOMs = new List< ERP7__BOM__c >();   
        
    //     if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
    //     else { 
    //         if(!Schema.sObjectType.Site__c.Fields.Barcode__c.isAccessible())throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Site__c.Fields.Barcode__c.getLabel()+' of sObject '+Schema.SObjectType.Site__c.getLabel());
    //         if(!Schema.sObjectType.Site__c.Fields.Name.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Site__c.Fields.Name.getLabel()+' of sObject '+Schema.SObjectType.Site__c.getLabel());
    //         siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =: barcode.trim() and Active__c = true limit 1]; 
    //     }
    //     if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
    //     else { 
    //         if(!Schema.sObjectType.Location__c.Fields.Barcode__c.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Location__c.Fields.Barcode__c.getLabel()+' of sObject '+Schema.SObjectType.Location__c.getLabel());
    //         if(!Schema.sObjectType.Location__c.Fields.Name.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Location__c.Fields.Name.getLabel()+' of sObject '+Schema.SObjectType.Location__c.getLabel());
    //         SSLList = [Select Id, Name, Barcode__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1]; 
    //     }
    //     if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
    //     else binList = [Select Id, Name, Barcode__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
        
    //     if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic_Line_Item__c.Label));
    //     else { 
    //         if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.Fields.Barcode__c.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.ERP7__Logistic_Line_Item__c.Fields.Barcode__c.getLabel()+' of sObject '+Schema.SObjectType.ERP7__Logistic_Line_Item__c.getLabel());
    //         if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.Fields.Name.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.ERP7__Logistic_Line_Item__c.Fields.Name.getLabel()+' of sObject '+Schema.SObjectType.ERP7__Logistic_Line_Item__c.getLabel());            
    //         loliListcheck = [select Id, Name, Barcode__c, Product__c, Product__r.Barcode__c from ERP7__Logistic_Line_Item__c where Barcode__c =:barcode.trim() Or Product__r.Barcode__c =:barcode.trim() limit 1]; 
    //         ProdList = [Select Id,Name,Barcode__c from Product2 where (Barcode__c =:barcode.trim() Or Name =:barcode.trim()) limit 1];
    //         verifyBatches = [Select Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__Available_Quantity__c, ERP7__Product__c From ERP7__Batch__c Where ERP7__Barcode__c =: barcode.trim()];
    //         verifySerials = [Select Id, Name, ERP7__Product__c, ERP7__Warehouse__c,ERP7__Serial_Number__c,  ERP7__Barcode_Type__c, ERP7__Barcode__c FROM ERP7__Serial_Number__c Where ERP7__Product__c != null AND ERP7__Serial_Number__c != null AND ERP7__Available__c = true AND (ERP7__Serial_Number__c =: barcode.trim() or ERP7__Barcode__c=:barcode.trim())];
    //     }    
    //     system.debug('verifyBatches : '+verifyBatches.size());  
    //     system.debug('verifySerials.size() : '+verifySerials.size());
        
    //     if(siteList.size() > 0 || SSLList.size() > 0 || binList.size() > 0) { 
    //         // The Warehouse, location or bin code is found                         
    //         for(Wrappers W : soliWrapperList) {
    //             if(ScanNo == 0 && !W.soliVerified && ((siteList.size() > 0 && W.AddressName == siteList[0].Id) || (SSLList.size()>0 && W.AddressName == SSLList[0].Id) || (binList.size()>0 && W.AddressName == binList[0].Id))) { 
    //                 barcodeLocMsg = ''; W.soliVerified = true; ScanNo = 1; 
    //                 W.include = true;
    //                 comW.exceptionError = errorMsg;
    //                 comW.barcodeLocMsg = barcodeLocMsg;
    //                 comW.soliWrapperList = soliWrapperList;
    //                 comW.ScanNo = ScanNo;
    //                 return comW;
    //             } 
    //         } 
    //     } else if(ScanNo == 0) { 
            
    //         if(loliListcheck.size() > 0 || verifyBatches.size() > 0 || verifySerials.size() > 0) {
    //             Batch__c myBatch = new Batch__c();
    //             for(Wrappers W : soliWrapperList) {
    //                 for(Batch__c bat : verifyBatches){
    //                     if(bat.Product__c == W.loli.Product__c) { //W.soliVerified && 
    //                         myBatch = bat;  W.batchLotCode=myBatch.Id; W.soliVerified = true;  W.soliSelected=true; W.include = true; break;
    //                         system.debug('myBatch : '+myBatch);
    //                     }
    //                     else {
    //                         barcodeLocMsg = 'Invalid Barcode'; 
    //                         system.debug('barcodeLocMsg verifyBatches : '+barcodeLocMsg);
    //                     }
    //                 }
    //             }
    //             ERP7__Serial_Number__c mySN = new ERP7__Serial_Number__c();
    //             for(Wrappers W : soliWrapperList) {
    //               //  barcodeLocMsg = '';
    //                 for(ERP7__Serial_Number__c SN : verifySerials){
    //                     system.debug('SN.ERP7__Product__c : '+SN.ERP7__Product__c);
    //                     system.debug('W.loli.Product__c : '+W.loli.Product__c);
    //                     if(SN.ERP7__Product__c == W.loli.Product__c) {//W.soliVerified && 
    //                         mySN = SN; W.SerialNumbers.ERP7__Serial__c=SN.Id; W.SerialNumbers.ERP7__Serial__r =SN; W.soliVerified = true; W.include = true;  W.soliSelected=true; break;
    //                     }
    //                   /*  else {
    //                        barcodeLocMsg = 'Invalid Barcode'; 
    //                         system.debug('barcodeLocMsg verifySerials : '+barcodeLocMsg);
    //                     }*/
    //                 }
    //             }
    //             if(ProdList.size() > 0){
    //                 for(Wrappers W : soliWrapperList) {
    //                     for(Product2 Prod : ProdList){
    //                         if(Prod.Id == W.loli.Product__c) {//W.soliVerified && 
    //                             W.soliVerified = true; W.include = true;  W.soliSelected=true; break;
    //                         }
    //                     }
    //                 }
    //             }
    //             system.debug('*** soliWrapperList scan: '+soliWrapperList.size());
    //             for(Wrappers W : soliWrapperList) {
                    
    //                 if(W.soliVerified && W.soliSelected && (barcode.trim() == W.loli.Barcode__c || barcode.trim() == W.loli.Product__r.Barcode__c || myBatch.Product__c == W.loli.Product__c || mySN.ERP7__Product__c == W.loli.Product__c)) {
                        
                        
    //                     if(!(W.LOLI.Product__r.Is_Kit__c && W.LOLI.Explode__c) && W.requiredQty <= (W.LOLI.Quantity__c - W.raisedQty) && ((W.inventoryStock - W.requiredQty) > 0) && W.requiredQty < W.LOLI.Quantity__c){
    //                         if(!W.LOLI.Product__r.ERP7__Serialise__c) { W.requiredQty += 1; }else W.requiredQty = 1;
    //                         W.include = true;
    //                         comW.exceptionError = errorMsg;
    //                         comW.barcodeLocMsg = barcodeLocMsg;
    //                         comW.soliWrapperList = soliWrapperList;
    //                         comW.ScanNo = ScanNo;
    //                         return comW;
    //                     } else if(W.LOLI.Product__r.Is_Kit__c && W.LOLI.Explode__c && W.requiredQty <= (W.MRP.Total_Amount_Required__c - W.raisedQty) && ((W.inventoryStock - W.requiredQty) > 0)){
    //                         if(!W.LOLI.Product__r.ERP7__Serialise__c) W.requiredQty += 1; else W.requiredQty = 1;
    //                         W.include = true;
    //                         comW.exceptionError = errorMsg;
    //                         comW.barcodeLocMsg = barcodeLocMsg;
    //                         comW.soliWrapperList = soliWrapperList;
    //                         comW.ScanNo = ScanNo;
    //                         return comW;
    //                     }  
    //                 } 
    //             }
    //         }
    //         else {
    //             barcodeLocMsg = 'Invalid Barcode';
    //              system.debug('barcodeLocMsg final : '+barcodeLocMsg);
    //         }
    //         comW.exceptionError = errorMsg;
    //         comW.barcodeLocMsg = barcodeLocMsg;
    //         comW.soliWrapperList = soliWrapperList;
    //         comW.ScanNo = ScanNo;
    //         return comW;
    //     }
    //     /*
    //         '*** barcode : '+barcode);
    //         '*** loliListcheck : '+loliListcheck);
    //         '*** ScanNo : '+ScanNo);
    //         '*** verifyBatches : '+verifyBatches);*/
    //     // If product or line item is found  
        
    //     if(loliListcheck.size() > 0 && (ScanNo == 1 || ScanNo ==0) ) {
    //         for(Wrappers W : soliWrapperList) {
    //             if(W.soliVerified && !W.soliSelected && (barcode.trim() == W.loli.Barcode__c || barcode.trim() == W.loli.Product__r.Barcode__c)) {
    //                 barcodeLocMsg = ''; W.soliSelected = true; ScanNo = 0; 
    //                 W.include = true;
    //                 comW.exceptionError = errorMsg;
    //                 comW.barcodeLocMsg = barcodeLocMsg;
    //                 comW.soliWrapperList = soliWrapperList;
    //                 comW.ScanNo = ScanNo;
    //                 return comW;
    //             } 
    //         }
    //     }
    //     if(verifyBatches.size() > 0  && (ScanNo == 1 || ScanNo ==0)){
    //         Boolean breakAll = false;
    //         for(Wrappers W : soliWrapperList) {
    //             for(Batch__c bat : verifyBatches){
    //                 if(W.soliVerified && !W.soliSelected && bat.Product__c == W.loli.Product__c) {
    //                     for(SelectOptions bc : W.BatchLotCodes) {
    //                         if(bc.value == bat.Id){
    //                             barcodeLocMsg = ''; W.soliSelected = true; ScanNo = 0;
    //                             if(W.batchLotCode != bat.Id){
    //                                 W.batchLotCode = bat.Id; W.inventoryStock = bat.ERP7__Available_Quantity__c;
    //                             }
    //                             W.include = true;
    //                             breakAll = true;
    //                             break;
    //                         }
    //                     }
    //                 }
    //                 if(breakAll) break;
    //             }
    //             if(breakAll) break;
    //         }
    //     } 
    //     if(verifySerials.size() > 0  && (ScanNo == 1 || ScanNo ==0)){
    //         Boolean breakAll = false;
    //         for(Wrappers W : soliWrapperList) {
    //             for(ERP7__Serial_Number__c SN : verifySerials){
    //                 if(W.soliVerified && !W.soliSelected && SN.ERP7__Product__c == W.loli.Product__c) {
    //                     W.SerialNumbers.ERP7__Serial__c = SN.Id;
    //                     //W.SerialNumbers.ERP7__Serial__r = new ERP7__Serial_Number__c(Name=SN.Name);
    //                     barcodeLocMsg = ''; W.soliSelected = true; ScanNo = 0;
    //                     W.include = true;
    //                     breakAll = true;
    //                     break;
    //                 }
    //             }
    //             if(breakAll) break;
    //         }
    //     } 
    //     if(ScanNo == 1) { barcodeLocMsg = 'Invalid Product/Serial/Batch'; }
    //     comW.exceptionError = errorMsg;
    //     comW.barcodeLocMsg = barcodeLocMsg;
    //     comW.soliWrapperList = soliWrapperList;
    //     comW.ScanNo = ScanNo;
        
    //     // } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
    //     return comW;
    // }
    // @AuraEnabled
    // public static comWrap scanLines(String barcode, Integer ScanNo, String SWL) {
    //     comWrap comW = new comWrap();
    //     try {
    //         String myBarcode = barcode.trim();
    //         System.debug('scanLines started: barcode=' + myBarcode + ', ScanNo=' + ScanNo + ', SWL size=' + SWL.length());
    
    //         List<Wrappers> soliWrapperList = (List<Wrappers>) JSON.deserialize(SWL, List<Wrappers>.class);
    //         System.debug('soliWrapperList size: ' + soliWrapperList.size());
    //         System.debug('soliWrapperList: ' + JSON.serialize(soliWrapperList));
    
    //         String scannedLocationId = getAddressIdByBarcode(myBarcode);
    //         System.debug('Scanned Location ID: ' + scannedLocationId);
    
    //         List<ERP7__Logistic_Line_Item__c> loliList = [SELECT Id, Name, Barcode__c, Product__c, Product__r.Barcode__c 
    //                                                       FROM ERP7__Logistic_Line_Item__c 
    //                                                       WHERE Barcode__c = :myBarcode OR Product__r.Barcode__c = :myBarcode LIMIT 1];
    //         List<Product2> prodList = [SELECT Id, Name, Barcode__c FROM Product2 WHERE Barcode__c = :myBarcode OR Name = :myBarcode LIMIT 1];
    //         List<ERP7__Batch__c> batchList = [SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__Available_Quantity__c, ERP7__Product__c 
    //                                           FROM ERP7__Batch__c WHERE ERP7__Barcode__c = :myBarcode];
    //         List<ERP7__Serial_Number__c> serialList = [SELECT Id, Name, ERP7__Product__c, ERP7__Warehouse__c, ERP7__Serial_Number__c, ERP7__Barcode__c 
    //                                                   FROM ERP7__Serial_Number__c 
    //                                                   WHERE ERP7__Product__c != NULL AND ERP7__Serial_Number__c != NULL 
    //                                                   AND ERP7__Available__c = TRUE AND (ERP7__Serial_Number__c = :myBarcode OR ERP7__Barcode__c = :myBarcode)];
    
    //         // Check if any record is selected
    //         Wrappers selectedWrapper = null;
    //         for (Wrappers w : soliWrapperList) {
    //             if (w.soliSelected) {
    //                 selectedWrapper = w;
    //                 break;
    //             }
    //         }
    
    //         if (ScanNo == 0 && scannedLocationId != null) {
    //             // If a record is selected, update it; otherwise, update the first unverified record
    //             if (selectedWrapper != null) {
    //                 System.debug('Updating selected record with AddressName: ' + scannedLocationId);
    //                 selectedWrapper.AddressName = scannedLocationId;
    //                 selectedWrapper.soliVerified = true;
    //                 selectedWrapper.include = true;
    //                 comW.ScanNo = 1;
    //             } else {
    //                 for (Wrappers w : soliWrapperList) {
    //                     w.AddressName = scannedLocationId;
    //                     w.soliVerified = true;
    //                     w.include = true;
    //                     comW.ScanNo = 1;
    //                     break;
    //                 }
    //             }
    //         } else if (ScanNo == 0 && (loliList.size() > 0 || batchList.size() > 0 || serialList.size() > 0 || prodList.size() > 0)) {
    //             for (Wrappers w : soliWrapperList) {
    //                 for (ERP7__Batch__c batch : batchList) {
    //                     if (batch.ERP7__Product__c == w.loli.Product__c) {
    //                         w.batchLotCode = batch.Id;
    //                         w.soliVerified = true;
    //                         w.soliSelected = true;
    //                         w.include = true;
    //                         break;
    //                     }
    //                 }
    //                 for (ERP7__Serial_Number__c serial : serialList) {
    //                     if (serial.ERP7__Product__c == w.loli.Product__c) {
    //                         w.SerialNumbers.ERP7__Serial__c = serial.Id;
    //                         w.SerialNumbers.ERP7__Serial__r = serial;
    //                         w.soliVerified = true;
    //                         w.soliSelected = true;
    //                         w.include = true;
    //                         break;
    //                     }
    //                 }
    //                 for (Product2 prod : prodList) {
    //                     if (prod.Id == w.loli.Product__c) {
    //                         w.soliVerified = true;
    //                         w.soliSelected = true;
    //                         w.include = true;
    //                         break;
    //                     }
    //                 }
    //                 if (w.soliVerified && w.soliSelected && (
    //                     myBarcode == w.loli.Barcode__c || myBarcode == w.loli.Product__r.Barcode__c ||
    //                     batchList.size() > 0 && batchList[0].ERP7__Product__c == w.loli.Product__c ||
    //                     serialList.size() > 0 && serialList[0].ERP7__Product__c == w.loli.Product__c)) {
    //                     if (!(w.LOLI.Product__r.Is_Kit__c && w.LOLI.Explode__c) && 
    //                         w.requiredQty <= (w.LOLI.Quantity__c - w.raisedQty) && 
    //                         (w.inventoryStock - w.requiredQty) > 0 && w.requiredQty < w.LOLI.Quantity__c) {
    //                         w.requiredQty += !w.LOLI.Product__r.ERP7__Serialise__c ? 1 : 1;
    //                         w.include = true;
    //                     } else if (w.LOLI.Product__r.Is_Kit__c && w.LOLI.Explode__c && 
    //                                w.requiredQty <= (w.MRP.Total_Amount_Required__c - w.raisedQty) && 
    //                                (w.inventoryStock - w.requiredQty) > 0) {
    //                         w.requiredQty += !w.LOLI.Product__r.ERP7__Serialise__c ? 1 : 1;
    //                         w.include = true;
    //                     }
    //                 }
    //             }
    //         } else if (ScanNo == 1) {
    //             boolean updated = false;
    //             for (Wrappers w : soliWrapperList) {
    //                 if (w.soliVerified && !w.soliSelected) {
    //                     if (loliList.size() > 0 && (myBarcode == w.loli.Barcode__c || myBarcode == w.loli.Product__r.Barcode__c)) {
    //                         w.soliSelected = true;
    //                         comW.ScanNo = 0;
    //                         w.include = true;
    //                         updated = true;
    //                         break;
    //                     }
    //                     for (ERP7__Batch__c batch : batchList) {
    //                         if (batch.ERP7__Product__c == w.loli.Product__c) {
    //                             for (SelectOptions bc : w.BatchLotCodes) {
    //                                 if (bc.value == batch.Id) {
    //                                     w.soliSelected = true;
    //                                     w.batchLotCode = batch.Id;
    //                                     w.inventoryStock = batch.ERP7__Available_Quantity__c;
    //                                     comW.ScanNo = 0;
    //                                     w.include = true;
    //                                     updated = true;
    //                                     break;
    //                                 }
    //                             }
    //                         }
    //                     }
    //                     for (ERP7__Serial_Number__c serial : serialList) {
    //                         if (serial.ERP7__Product__c == w.loli.Product__c) {
    //                             w.SerialNumbers.ERP7__Serial__c = serial.Id;
    //                             w.soliSelected = true;
    //                             comW.ScanNo = 0;
    //                             w.include = true;
    //                             updated = true;
    //                             break;
    //                         }
    //                     }
    //                 }
    //             }
    //             if (!updated) {
    //                 comW.barcodeLocMsg = 'Invalid Product/Serial/Batch';
    //             }
    //         } else {
    //             comW.barcodeLocMsg = 'Invalid Barcode';
    //         }
    
    //         comW.soliWrapperList = soliWrapperList;
    //         return comW;
    //     } catch (Exception e) {
    //         System.debug('Error in scanLines: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
    //         comW.exceptionError = 'An error occurred while scanning: ' + e.getMessage();
    //         return comW;
    //     }
    // }
    @AuraEnabled
    public static comWrap scanLines(String barcode, Integer ScanNo, String SWL) {
        comWrap comW = new comWrap();
        try {
            String myBarcode = barcode.trim();
            System.debug('scanLines started: barcode=' + myBarcode + ', ScanNo=' + ScanNo + ', SWL size=' + SWL.length());
    
            List<Wrappers> soliWrapperList = (List<Wrappers>) JSON.deserialize(SWL, List<Wrappers>.class);
            System.debug('soliWrapperList size: ' + soliWrapperList.size());
            System.debug('soliWrapperList: ' + JSON.serialize(soliWrapperList));
    
            String scannedLocationId = getAddressIdByBarcode(myBarcode);
            System.debug('Scanned Location ID: ' + scannedLocationId);
    
            List<ERP7__Logistic_Line_Item__c> loliList = [SELECT Id, Name, Barcode__c, Product__c, Product__r.Barcode__c 
                                                          FROM ERP7__Logistic_Line_Item__c 
                                                          WHERE Barcode__c = :myBarcode OR Product__r.Barcode__c = :myBarcode LIMIT 1];
            List<Product2> prodList = [SELECT Id, Name, Barcode__c FROM Product2 WHERE Barcode__c = :myBarcode OR Name = :myBarcode LIMIT 1];
    
            // Lookup batch Id by Name (barcode)
            List<ERP7__Batch__c> batchRecords = [SELECT Id, ERP7__Product__c 
                                                 FROM ERP7__Batch__c 
                                                 WHERE Name = :myBarcode LIMIT 1];
            String batchId = batchRecords.isEmpty() ? null : batchRecords[0].Id;
            List<ERP7__Batch__c> batchList = batchId != null ? [SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__Available_Quantity__c, ERP7__Product__c 
                                                                FROM ERP7__Batch__c WHERE Id = :batchId] : new List<ERP7__Batch__c>();
            System.debug('Batch list: ' + batchList);
    
            // Lookup serial number Id by Name (barcode)
            List<ERP7__Serial_Number__c> serialRecords = [SELECT Id, ERP7__Product__c 
                                                         FROM ERP7__Serial_Number__c 
                                                         WHERE Name = :myBarcode AND ERP7__Available__c = TRUE LIMIT 1];
            String serialId = serialRecords.isEmpty() ? null : serialRecords[0].Id;
            List<ERP7__Serial_Number__c> serialList = serialId != null ? [SELECT Id, Name, ERP7__Product__c, ERP7__Warehouse__c, ERP7__Serial_Number__c, ERP7__Barcode__c 
                                                                         FROM ERP7__Serial_Number__c 
                                                                         WHERE Id = :serialId AND ERP7__Product__c != NULL AND ERP7__Serial_No__c != NULL 
                                                                         AND ERP7__Available__c = TRUE] : new List<ERP7__Serial_Number__c>();
            System.debug('Serial list: ' + serialList);
    
            Wrappers selectedWrapper = null;
            for (Wrappers w : soliWrapperList) {
                if (w.soliSelected) {   selectedWrapper = w;
                    break;
                }
            }
    
            if (ScanNo == 0 && scannedLocationId != null) {
                if (selectedWrapper != null) {
                    System.debug('Updating selected record with AddressName: ' + scannedLocationId);
                    selectedWrapper.AddressName = scannedLocationId; selectedWrapper.soliVerified = true; selectedWrapper.include = true; comW.ScanNo = 1;
                } else {
                    for (Wrappers w : soliWrapperList) {                        w.AddressName = scannedLocationId; w.soliVerified = true;  w.include = true; comW.ScanNo = 1;
                        break;
                    }
                }
            } else if (ScanNo == 0 && (loliList.size() > 0 || batchList.size() > 0 || serialList.size() > 0 || prodList.size() > 0)) {
                for (Wrappers w : soliWrapperList) {
                    for (ERP7__Batch__c batch : batchList) {
                        if (batch.ERP7__Product__c == w.loli.Product__c) {                            w.batchLotCode = batch.Id;               w.soliVerified = true;             w.soliSelected = true;              w.include = true;      break;
                        }
                    }
                    for (ERP7__Serial_Number__c serial : serialList) {
                        if (serial.ERP7__Product__c == w.loli.Product__c) {                            w.SerialNumbers.ERP7__Serial__c = serial.Id;                            w.SerialNumbers.ERP7__Serial__r = serial;                            w.soliVerified = true;                            w.soliSelected = true;                            w.include = true;                            break;
                        }
                    }
                    for (Product2 prod : prodList) {
                        if (prod.Id == w.loli.Product__c) {                            w.soliVerified = true;                            w.soliSelected = true;                            w.include = true;                            break;
                        }
                    }
                    if (w.soliVerified && w.soliSelected && (
                        myBarcode == w.loli.Barcode__c || myBarcode == w.loli.Product__r.Barcode__c ||
                        batchList.size() > 0 && batchList[0].ERP7__Product__c == w.loli.Product__c ||
                        serialList.size() > 0 && serialList[0].ERP7__Product__c == w.loli.Product__c)) {
                        if (!(w.LOLI.Product__r.Is_Kit__c && w.LOLI.Explode__c) && 
                            w.requiredQty <= (w.LOLI.Quantity__c - w.raisedQty) && 
                            (w.inventoryStock - w.requiredQty) > 0 && w.requiredQty < w.LOLI.Quantity__c) {
                            w.requiredQty += !w.LOLI.Product__r.ERP7__Serialise__c ? 1 : 1;
                            w.include = true;
                        } else if (w.LOLI.Product__r.Is_Kit__c && w.LOLI.Explode__c && 
                                   w.requiredQty <= (w.MRP.Total_Amount_Required__c - w.raisedQty) && 
                                   (w.inventoryStock - w.requiredQty) > 0) {
                            w.requiredQty += !w.LOLI.Product__r.ERP7__Serialise__c ? 1 : 1;
                            w.include = true;
                        }
                    }
                }
            } else if (ScanNo == 1) {
                boolean updated = false;
                for (Wrappers w : soliWrapperList) {
                    if (w.soliVerified && !w.soliSelected) {
                        if (loliList.size() > 0 && (myBarcode == w.loli.Barcode__c || myBarcode == w.loli.Product__r.Barcode__c)) {
                            w.soliSelected = true;                            comW.ScanNo = 0;                            w.include = true;                            updated = true;                            break;
                        }
                        for (ERP7__Batch__c batch : batchList) {
                            System.debug('Checking batch ' + batch.Id + ' for product ' + w.loli.Product__c);
                            if (batch.ERP7__Product__c == w.loli.Product__c) {
                                for (SelectOptions bc : w.BatchLotCodes) {
                                    if (bc.value == batch.Id) {                                        w.soliSelected = true;                                        w.batchLotCode = batch.Id;                                        w.inventoryStock = batch.ERP7__Available_Quantity__c;                                        comW.ScanNo = 0;                                        w.include = true;                                        updated = true;                                        break;
                                    }
                                }
                            }
                        }
                        for (ERP7__Serial_Number__c serial : serialList) {
                            System.debug('Checking serial ' + serial.Id + ' for product ' + w.loli.Product__c);
                            if (serial.ERP7__Product__c == w.loli.Product__c) {                                w.SerialNumbers.ERP7__Serial__c = serial.Id;                                w.soliSelected = true;                                comW.ScanNo = 0;                                w.include = true;                                updated = true;                                break;
                            }
                        }
                    }
                }
                if (!updated) {
                    comW.barcodeLocMsg = 'Invalid Product/Serial/Batch';
                    System.debug('No match found for barcode ' + myBarcode + ', serialList: ' + serialList + ', batchList: ' + batchList);
                }
            } else {
                comW.barcodeLocMsg = 'Invalid Barcode';
            }
    
            comW.soliWrapperList = soliWrapperList;
            return comW;
        } catch (Exception e) {
            System.debug('Error in scanLines: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
            comW.exceptionError = 'An error occurred while scanning: ' + e.getMessage();
            return comW;
        }
    }
    @AuraEnabled
    public static logWrap getLogisticDetails(String LogisticIds){
        
        logWrap log = new logWrap();
        
        try{
            
            
            String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
            utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
            logLineFields += ',ERP7__Product__r.Name, ERP7__Product__r.Picture__c, ERP7__Product__r.Family, ERP7__Logistic__r.Name'; //,Picked_Quantity__c,Packed_Quantity__c, Shipped_Quantity__c,Quantity__c
            List<String> soIdss = (List<String>) JSON.deserialize(LogisticIds, List<String> .class);
            if (soIdss != null) {
                
                List<ERP7__Logistic__c> SOS = [Select Id, Name from ERP7__Logistic__c where (Id IN :soIdss or Name In :soIdss) Limit 1];
                
                if(SOS.size() > 0){
                    Integer shipedItems = 0; Integer packedItems = 0;Integer pickedItems = 0;
                    ERP7__Logistic__c LO = SOS[0];
                    log.LogName=SOS[0].Name;
                    List <ERP7__Logistic_Line_Item__c> solisItemLists = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In :soIdss or ERP7__Logistic__r.Name IN :soIdss');
                    for(ERP7__Logistic_Line_Item__c so_li :solisItemLists){
                        if(so_li.Picked_Quantity__c != so_li.Quantity__c && so_li.Picked_Quantity__c != Null){ pickedItems=pickedItems+1; }
                        if(so_li.Picked_Quantity__c != Null && so_li.Picked_Quantity__c > 0 && ((so_li.Packed_Quantity__c != Null && so_li.Picked_Quantity__c > so_li.Packed_Quantity__c) || so_li.Packed_Quantity__c == Null)){ packedItems= packedItems+1;   }
                        if(so_li.Packed_Quantity__c != Null && so_li.Packed_Quantity__c > 0 && ((so_li.Shipped_Quantity__c != Null && so_li.Packed_Quantity__c > so_li.Shipped_Quantity__c) || so_li.Shipped_Quantity__c == Null)){ shipedItems=shipedItems+1; }
                    }
                    //LogId = LO.Id;
                    log.solisItemList = solisItemLists;
                    log.pickItems = pickedItems;
                    log.packItems = packedItems;
                    log.shipItems = shipedItems;
                    
                }
                
            }} catch(Exception e) { log.exceptionErrors = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return log;
    }
    public class logWrap{
        @AuraEnabled public List <ERP7__Logistic_Line_Item__c> solisItemList                { get; set; }
        @AuraEnabled public String exceptionErrors                                          { get; set; }
        @AuraEnabled  public Integer pickItems                                              { get; set; }
        @AuraEnabled  public Integer packItems                                              { get; set; }
        @AuraEnabled  public Integer shipItems                                              { get; set; }
        @AuraEnabled  public String  LogName                                                { get; set; }
    }
    
    public class comWrap {
        @AuraEnabled public List<Wrappers> Logistics                                 { get; set; }
        @AuraEnabled public List<Wrappers> soliWrapperList                           { get; set; }
        @AuraEnabled public List<ERP7__Logistic__c> LogisticRecs                     { get; set; }
        @AuraEnabled public List<ERP7__Logistic__c> allLogs                         { get; set; }
        @AuraEnabled public Employees__c Employee                                    { get; set; }
        @AuraEnabled public List<SelectOptions> channelSites                         { get; set; }
        @AuraEnabled public String query                                             { get; set; }
        @AuraEnabled public String selectedSite                                      { get; set; } 
        @AuraEnabled public String Barcode                                           { get; set; } 
        @AuraEnabled public String exceptionError                                    { get; set; } 
        @AuraEnabled public String ChannelName                                       { get; set; } 
        @AuraEnabled public String ChannelId                                         { get; set; } 
        @AuraEnabled public String SiteName                                          { get; set; } 
        @AuraEnabled public List<Id> SerialIds2Exempt                                { get; set; } 
        @AuraEnabled public Map<Id, Id> stockMap                                     { get; set; } 
        @AuraEnabled public List<Integer> PNS                                        { get; set; }
        @AuraEnabled public Integer startCount                                       { get; set; }
        @AuraEnabled public Integer endCount                                         { get; set; }
        @AuraEnabled public Integer Offset                                           { get; set; }
        @AuraEnabled public Integer recSize                                          { get; set; }
        @AuraEnabled public Integer PageNum                                          { get; set; }
        @AuraEnabled public Integer show                                             { get; set; }
        
        @AuraEnabled public Boolean showBatch                                        { get; set; }
        @AuraEnabled public Boolean showSSType                                       { get; set; }
        @AuraEnabled public Boolean disablePackName                                       { get; set; }
        @AuraEnabled public Boolean disablePackDeclaredValue                                       { get; set; }
        @AuraEnabled public Boolean showSN                                           { get; set; } 
        @AuraEnabled public String barcodeLocMsg                                     { get; set; } 
        @AuraEnabled public String PB                                                { get; set; } 
        @AuraEnabled public Boolean hideBarcodeLabel                                  { get; set; }  
        @AuraEnabled public List<lineItemWrapper> lineItemWrapperList                { get; set; }
        @AuraEnabled public List<packageWrapper> packageWrapperList                  { get; set; }
        @AuraEnabled public Package__c Package2Create                                { get; set; }
        @AuraEnabled public List<SelectOptions> Customers                            { get; set; }
        @AuraEnabled public String Customer                                          { get; set; }
        @AuraEnabled public String pkgTypeValue                                      { get; set; }
        @AuraEnabled public String errorMsg2                                         { get; set; }
        @AuraEnabled public Boolean createPack                                       { get; set; }
        @AuraEnabled public Boolean isAwaiting                                       { get; set; }
        @AuraEnabled public Boolean CustomerPresent                                  { get; set; } 
        @AuraEnabled public List<SelectOptions> WeightUnit                           { get; set; }
        @AuraEnabled public List<SelectOptions> DimensionUnit                        { get; set; }
        @AuraEnabled public List<SelectOptions> PackageType                          { get; set; }
        @AuraEnabled public List<SelectOptions> ShipmentType                         { get; set; }
        @AuraEnabled public Boolean enableDecalre                                    { get; set; } 
        @AuraEnabled public List<Wrappers> shipmentWrapperList                       { get; set; }
        @AuraEnabled public Transient List<CommittedStockWrap> commitedSOLI      { get; set; }
        @AuraEnabled public Transient Set<String> commitedSOLIIdsList      { get; set; }
        @AuraEnabled public Integer ScanNo                                           { get; set; }
        @AuraEnabled public Boolean displayStockAddress                         { get; set; }
        @AuraEnabled public Boolean dontDefaultSnLotPick                         { get; set; }
        @AuraEnabled public Boolean  dontallowChannelRemove   { get; set; }
        @AuraEnabled public Boolean ShowAllfilters { get; set; }
        @AuraEnabled public Boolean ShowShipfilters  { get; set; }
        @AuraEnabled public Boolean allowZerodeclaredValue      { get; set; }
        @AuraEnabled public Boolean disableShipType             { get; set; }
        @AuraEnabled public List<String> shiptypes              { get; set; }
        @AuraEnabled public Boolean Allowscanning               { get; set; }
        @AuraEnabled public Boolean ReplacePackListOrgURL               { get; set; }
        @AuraEnabled public Boolean enableUPSRestAPI               { get; set; }
        @AuraEnabled public Boolean enableFedexRestAPI                     { get; set; }
        @AuraEnabled public Boolean ReplacePickSlipOrgURL               { get; set; }
        @AuraEnabled public Boolean ReplaceShipSlipOrgURL               { get; set; }
        @AuraEnabled public Boolean ShowLangOptionForPickSlip               { get; set; }
        @AuraEnabled public Boolean ShowLangOptionForPackList               { get; set; }
        @AuraEnabled public Boolean ShowLangOptionForShipSlip               { get; set; }
        
        @AuraEnabled public Transient List<SerialWrapper> PickSelectedSerialNos               { get; set; }
        @AuraEnabled public Transient List<SerialWrapper> PickSerialNos                       { get; set; }
        
        public comWrap() {
            enableUPSRestAPI = Allowscanning = ReplacePackListOrgURL = ReplaceShipSlipOrgURL = ShowLangOptionForPickSlip = ShowLangOptionForPackList = ShowLangOptionForShipSlip = ReplacePickSlipOrgURL = false;
            shiptypes = new List<String>();
            disableShipType = false;
            showSSType = false;
            disablePackName = false;
            disablePackDeclaredValue = false;
            commitedSOLI = new List<CommittedStockWrap>();
            displayStockAddress = dontDefaultSnLotPick = false;
            Logistics = new List<Wrappers>();
            soliWrapperList = new List<Wrappers>(); 
            Employee = new Employees__c();
            channelSites = new List<SelectOptions>();
            DimensionUnit= new List<SelectOptions>();
            Barcode = '';
            selectedSite = '';
            exceptionError = '';
            ChannelName = ChannelId = '';
            SiteName = '';
            LogisticRecs = new List<ERP7__Logistic__c>();
            allLogs = new List<ERP7__Logistic__c>();
            SerialIds2Exempt = new List<Id>();
            stockMap = new Map<Id, Id>();
            PNS = new List<Integer>();
            show = 25;
            startCount = endCount = Offset = recSize = PageNum = 0;
            PB = '';
            ScanNo = 0;
            dontallowChannelRemove = false;
            lineItemWrapperList = new List<lineItemWrapper>();
            packageWrapperList = new List<packageWrapper>();
            Package2Create = new Package__c();
            Customers = new List<SelectOptions>();
            Customer = errorMsg2 = pkgTypeValue = '';
            createPack = isAwaiting = CustomerPresent = false;
            WeightUnit = new List<SelectOptions>();
            PackageType = new List<SelectOptions>();
            ShipmentType = new List<SelectOptions>();
            commitedSOLIIdsList = new Set<String>();
            shipmentWrapperList = new List<Wrappers>();
            PickSelectedSerialNos = new List<SerialWrapper>();
            PickSelectedSerialNos = new List<SerialWrapper>();
        }
    }
    
    
    public class CommittedStockWrap{
        @AuraEnabled public Transient ERP7__Stock_Outward_Line_Item__c soli        { get; set; }
        @AuraEnabled public Transient Boolean editbatch      { get; set; }
        @AuraEnabled public Transient Boolean editserial      { get; set; }
        public CommittedStockWrap(ERP7__Stock_Outward_Line_Item__c sli,Boolean batchedit,Boolean serEdit){
            soli =  sli; editbatch = batchedit; editserial = serEdit;
        }
        public CommittedStockWrap(){
            soli = new ERP7__Stock_Outward_Line_Item__c();
            editbatch = editserial = false;
        }
    }
    
    public class orderWrapper{
        @AuraEnabled public String OrderId        { get; set; }
        @AuraEnabled public String OrderName      { get; set; }
        public orderWrapper(){
            OrderId = OrderName = '';
        }
    }
    
    public class Wrappers {        
        @AuraEnabled public String warehouseName                            { get; set; } 
        @AuraEnabled public String WN                                       { get; set; } 
        @AuraEnabled public String LN                                       { get; set; } 
        @AuraEnabled public String binName                                  { get; set; }         
        @AuraEnabled public String batchLotCode                             { get; set; }   
        @AuraEnabled public String stockId                                  { get; set; } 
        @AuraEnabled public ERP7__Package__c sPkg                           { get; set; }        
        @AuraEnabled public Decimal raisedQty                               { get; set; }
        @AuraEnabled public Boolean soSelected                              { get; set; }        
        @AuraEnabled public Boolean shipSelected                            { get; set; }    
        @AuraEnabled public Decimal requiredQty                             { get; set; }
        @AuraEnabled public String locationName                             { get; set; }
        @AuraEnabled public String trackingNo                               { get; set; }
        @AuraEnabled public ERP7__Shipment__c shipM                         { get; set; }
        @AuraEnabled public String shipmentType                             { get; set; }
        @AuraEnabled public Decimal remainingQty                            { get; set; }
        @AuraEnabled public Boolean soliSelected                            { get; set; }
        @AuraEnabled public Boolean soliVerified                            { get; set; }   
        @AuraEnabled public Boolean include                                 { get; set; }
        @AuraEnabled public Boolean isSOLIawaiting                          { get; set; }       
        @AuraEnabled public Decimal inventoryStock                          { get; set; } 
        @AuraEnabled public ERP7__Sales_Order_Line_Item__c SOLI             { get; set; }  
        @AuraEnabled public OrderItem OLI                                   { get; set; }  
        @AuraEnabled public Boolean isAvailablePackages                     { get; set; }
        @AuraEnabled public Boolean isAvailableShipments                    { get; set; } 
        @AuraEnabled public Boolean isAllShipmentsDelivered                 { get; set; } 
        @AuraEnabled public List<SelectOptions> CurrentBins                 { get; set; }        
        @AuraEnabled public List<SelectOptions> CurrentLocations            { get; set; }
        @AuraEnabled public List<SelectOptions> CurrentWarehouses           { get; set; }
        @AuraEnabled public List<SelectOptions> Address                     { get; set; }
        @AuraEnabled public String AddressName                              { get; set; }
        @AuraEnabled public String SD                                       { get; set; }
        @AuraEnabled public List<SelectOptions> BatchLotCodes               { get; set; }
        @AuraEnabled public ERP7__MRP__c MRP                                { get; set; }
        @AuraEnabled public Product2 Product                                { get; set; }
        @AuraEnabled public ERP7__Asset__c Asset                            { get; set; }
        @AuraEnabled public List<Wrappers> MRPsWrapperList                  { get; set; }
        @AuraEnabled public ERP7__Stock_Outward_Line_Item__c SerialNumbers  { get; set; }
        @AuraEnabled public Boolean serialized                              { get; set; }
        
        @AuraEnabled public ERP7__Logistic__c Logistic                      { get; set; }
        @AuraEnabled public ERP7__Logistic_Line_Item__c LOLI                { get; set; } 
        @AuraEnabled public List<orderWrapper> orderWrapperList             { get; set; }
        
        @AuraEnabled public List<Id> MultiSerialIds                         { get; set; }
        
        public Wrappers() {  
            SD = '';          
            WN = '';     
            LN = '';
            //batchLotCode = '';
            AddressName = '';
            include = false;            
            binName = null;
            stockId = null;                  
            raisedQty = 0.00;
            requiredQty = 0.00;
            remainingQty = 0.00;
            trackingNo = ''; 
            inventoryStock = 0;                  
            soSelected = false;  
            soliSelected = false;
            soliVerified = false;
            shipSelected = false;
            locationName = null;                                   
            isSOLIawaiting = false;                          
            warehouseName = null;
            shipM = new ERP7__Shipment__c();
            sPkg = new ERP7__Package__c();
            isAvailablePackages = false;
            isAvailableShipments = false;  
            isAllShipmentsDelivered = false;              
            Address = new List<SelectOptions>();                                
            SOLI = new Sales_Order_Line_Item__c();
            CurrentBins = new List<SelectOptions>();
            CurrentLocations = new List<SelectOptions>();
            CurrentWarehouses = new List<SelectOptions>(); 
            BatchLotCodes = new List<SelectOptions>();   
            MRP = new ERP7__MRP__c(); 
            MRPsWrapperList = new List<Wrappers>(); 
            product = new product2();   
            Asset = new ERP7__Asset__c();
            serialized = false;
            SerialNumbers = new Stock_Outward_Line_Item__c();  
            Logistic = new ERP7__Logistic__c();     
            LOLI = new ERP7__Logistic_Line_Item__c(); 
            orderWrapperList = new List<orderWrapper>();   
            MultiSerialIds = new List<Id>();         
        }           
    }
    
    public class innerPackageWrapper{
        @AuraEnabled public List<SelectOptions> packList               { get; set; }
        @AuraEnabled public String pack                               { get; set; }
        @AuraEnabled public ERP7__Package__c packege                  { get; set; }
        @AuraEnabled public Package_List__c packageList               { get; set; }
        
        public innerPackageWrapper(){ 
            packege = new Package__c();
            packageList = new Package_List__c();
            packList = new List<SelectOptions>();
            pack = '';
        }
    }    
    
    public class SerialWrapper{
        @AuraEnabled public ERP7__Serial_Number__c SerialNo           { get; set; }
        @AuraEnabled public Boolean isSelected                        { get; set; }
        
        public SerialWrapper(){ 
            SerialNo = new ERP7__Serial_Number__c();
            isSelected = false;
        }
    }  
    
    public class packageWrapper {
        @AuraEnabled public Decimal qtyToPick                                 { get; set; }   
        @AuraEnabled public Decimal qtyToPack                                 { get; set; }
        @AuraEnabled public Boolean pkgSelected                               { get; set; } 
        @AuraEnabled public Logistic_Line_Item__c loli                        { get; set; }
        @AuraEnabled public MRP__c mrp                                        { get; set; }
        @AuraEnabled public List<innerPackageWrapper> innerPackList           { get; set; }        
        
        public packageWrapper(){
            qtyToPick = 0; 
            qtyToPack = 0;
            pkgSelected = false;
            loli = new Logistic_Line_Item__c();
            mrp = new MRP__c();
            innerPackList = new List<innerPackageWrapper>();    
        }  
    }   
    
    public class lineItemWrapper {
        @AuraEnabled public Boolean sel                               { get; set; }
        @AuraEnabled public String units                              { get; set; }  
        @AuraEnabled public Package__c pack                           { get; set; }
        @AuraEnabled public Shipment__c shipment                      { get; set; }
        @AuraEnabled public Decimal NoofLineItems                     { get; set; }          
        
        public lineItemWrapper() {
            units = ''; 
            sel = false;            
            NoofLineItems = 0;
            pack = new Package__c();
            shipment = new Shipment__c(Name='');                
        }
    }  
    
    public class SelectOptions {
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        
        public SelectOptions(String val, string lab) {
            value = val;
            label = lab;
            //selected = false;
        }
        public SelectOptions(String val, string lab, Boolean sel) {
            value = val;
            label = lab;
            selected = sel;
        }
    }
    @AuraEnabled public static String getBatchStocks(String batchId,String soli){
        try{ 
            Boolean noerror = false;
            List<ERP7__Stock_Outward_Line_Item__c> stk = new List<ERP7__Stock_Outward_Line_Item__c>();
            if(batchId != null && batchId != ''){
                List<ERP7__Batch__c> batch2check = [Select Id,Name,ERP7__Outward_Quantity__c,ERP7__Available_Quantity__c from ERP7__Batch__c where Id =:batchId limit 1];
                Decimal qty = 0;
                stk = [Select Id,Name,ERP7__Active__c,ERP7__Quantity__c,ERP7__Product__c,ERP7__Version__c,ERP7__Order_Product__c,ERP7__Customer__c,ERP7__Logistic_Line_Item__c,ERP7__Material_Batch_Lot__c,ERP7__Order__c from ERP7__Stock_Outward_Line_Item__c where Id=:soli limit 1];
                if(stk.size() > 0){ qty = stk[0].ERP7__Quantity__c; }
                if(batch2check.size() > 0){
                    system.debug('batch2check[0].ERP7__Available_Quantity__c : '+batch2check[0].ERP7__Available_Quantity__c);
                    system.debug('qty : '+qty);
                    if(batch2check[0].ERP7__Available_Quantity__c > 0 && batch2check[0].ERP7__Available_Quantity__c >= qty) noerror = true;
                    else return 'Selected batch doesn\'t have enough quantity';
                }
            }
            system.debug('noerror : '+noerror);
            if(noerror){
                system.debug('soli : '+soli);
                if(soli != null && soli != ''){
                    String oldbatchId = ''; Decimal qty = 0;
                    system.debug('oldbatchId : '+oldbatchId);
                    stk = [Select Id,Name,ERP7__Active__c,ERP7__Quantity__c,ERP7__Product__c,ERP7__Version__c,ERP7__Order_Product__c,ERP7__Customer__c,ERP7__Logistic_Line_Item__c,ERP7__Material_Batch_Lot__c,ERP7__Order__c from ERP7__Stock_Outward_Line_Item__c where Id=:soli limit 1];
                    if(stk.size() > 0){
                        if(stk[0].ERP7__Material_Batch_Lot__c != batchId){
                            oldbatchId = stk[0].ERP7__Material_Batch_Lot__c;
                            stk[0].ERP7__Material_Batch_Lot__c = batchId;
                            qty = stk[0].ERP7__Quantity__c;
                        }
                        update stk[0];
                        List<ERP7__Batch__c> batch2update = [Select Id,Name,ERP7__Outward_Quantity__c from ERP7__Batch__c where Id =:oldbatchId limit 1];
                        if(batch2update.size() > 0) {
                            batch2update[0].ERP7__Outward_Quantity__c = batch2update[0].ERP7__Outward_Quantity__c - qty;
                            update batch2update[0];
                        }
                    }
                    stk = [Select Id,Name,ERP7__Active__c,ERP7__Quantity__c,ERP7__Product__c,ERP7__Version__c,ERP7__Order_Product__c,ERP7__Customer__c,ERP7__Logistic_Line_Item__c,ERP7__Material_Batch_Lot__c,ERP7__Order__c from ERP7__Stock_Outward_Line_Item__c where Id=:stk[0].Id limit 1];
                    
                    return JSON.serialize(stk[0]);
                }
                
            }
            else return null;            
        }
        catch(Exception e){
            system.debug('err : '+e.getMessage() +' Line Number @ : '+ e.getLineNumber());
        }
        
        return null;
    }
    
    @AuraEnabled public static List<SelectOptions>  getAvailableSerial(String siteId,String loliIds){
        try{
        List<ERP7__Serial_Number__c> serlst = new List<ERP7__Serial_Number__c>();
        List<SelectOptions> allSerials = new List<SelectOptions>();
            system.debug('loliIds : '+loliIds);
            system.debug('siteId : '+siteId);
        if(siteId != null && siteId != '' && loliIds != null && loliIds != ''){
            List<ERP7__Logistic_Line_Item__c> logline = [Select Name,Id,ERP7__Product__c from ERP7__Logistic_Line_Item__c where Id=:loliIds limit 1];
                if(logline.size() > 0){
                    set<Id> ReservedSerials = new set<Id>();
                    List<ERP7__Stock_Outward_Line_Item__c> stkList = [Select Id,Name,ERP7__Product__c,ERP7__Serial__c,ERP7__Serial__r.Name from ERP7__Stock_Outward_Line_Item__c where ERP7__Logistic_Line_Item__c != null and ERP7__Logistic_Line_Item__c=:loliIds];
                    for(ERP7__Stock_Outward_Line_Item__c stk : stkList){
                        if(stk.ERP7__Serial__c != null) {
                            ReservedSerials.add(stk.ERP7__Serial__c);
                            allSerials.add(new SelectOptions(String.valueOf(stk.ERP7__Serial__c),stk.ERP7__Serial__r.Name,true));
                        }
                    }
                    system.debug('ReservedSerials : '+ReservedSerials.size());
                    system.debug('allSerials : '+allSerials.size());
                    serlst = [Select Id,Name,ERP7__Available__c,ERP7__Product__c from ERP7__Serial_Number__c where ERP7__Product__c=:logline[0].ERP7__Product__c and ERP7__Warehouse__c=:siteId  and ERP7__Available__c = true and ERP7__Scrap__c = false and Id Not In :ReservedSerials Limit 2000];
                    system.debug('serlst : '+serlst.size());
                    for(ERP7__Serial_Number__c ser : serlst){
                        allSerials.add(new SelectOptions(String.valueOf(ser.Id),ser.Name,false));
                    }
                    
                }
            
            
        }
        if(allSerials.size() > 0) return allSerials;
        else return null;
        }catch(Exception e){
            system.debug('Error : '+e.getLineNumber()+' Msg : '+e.getMessage());
            return null;
        }
    }
     @AuraEnabled
    public static List<String> getAllreservedSerials(String productId) {
        List<String> list2return = new List<String>();
        system.debug('productId : '+productId);
        if (productId != null && productId != '') {
            // Query to get the serials
            List<ERP7__Stock_Outward_Line_Item__c> soutlist = [
                SELECT ERP7__Serial__c 
                FROM ERP7__Stock_Outward_Line_Item__c 
                WHERE ERP7__Product__c = :productId 
                AND ERP7__Serial__c != null 
                AND ERP7__Status__c = 'Reserved'   limit 1000
            ];
            
            // Extracting serials into the list
            for (ERP7__Stock_Outward_Line_Item__c sout : soutlist) {
                list2return.add(sout.ERP7__Serial__c);
            }
        }
        system.debug('list2return : '+list2return);
        if(list2return.size() > 0) return list2return;
        else return null;
    }
    
    @AuraEnabled public static String updateSerial(String serId,String soli){
        Savepoint sp = Database.setSavepoint();
        try{
            Boolean noerror = false;
            List<ERP7__Stock_Outward_Line_Item__c> stk = new List<ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Serial_Number__c> serlst = new List<ERP7__Serial_Number__c>();
            if(serId != null && serId != ''){
                serlst = [Select Id,Name,ERP7__Available__c from ERP7__Serial_Number__c where Id=:serId limit 1];
                if(serlst.size() > 0){
                    if(serlst[0].ERP7__Available__c) {
                        noerror = true;
                    } 
                    else return 'Selected serial is not avialable';
                } 
            }
            if(noerror && soli != null && soli != ''){
                stk = [Select Id,Name,ERP7__Active__c,ERP7__Quantity__c,ERP7__Sales_Order__c,Sales_Order_Line_Item__c,ERP7__Material_Batch_Lot__c,Status__c,ERP7__Picked_Quantity__c,ERP7__Picked_Date__c,ERP7__Return_Merchandise_Authorisation__c,ERP7__RMA_Line_Item__c,ERP7__Transfer_Order__c,ERP7__Transfer_Order_Line_Item__c,ERP7__Unit_Price__c,ERP7__Product__c,ERP7__Version__c,ERP7__Order_Product__c,ERP7__Customer__c,ERP7__Logistic_Line_Item__c,ERP7__Serial__c,ERP7__Order__c from ERP7__Stock_Outward_Line_Item__c where Id=:soli limit 1];
                List<ERP7__Inventory_Stock__c> siliinv = [Select Id,Name from ERP7__Inventory_Stock__c where ERP7__Serial__c =:serId limit 1];
                if(stk.size() > 0){
                    string oldserial = stk[0].ERP7__Serial__c;
                    
                    
                    List<ERP7__Serial_Number__c> oldserlst = [Select Id,Name,ERP7__Available__c from ERP7__Serial_Number__c where Id=:serId limit 1];
                    if(oldserlst.size() > 0){
                        oldserlst[0].ERP7__Available__c = true;
                        update oldserlst[0];
                    } 
                    ERP7__Stock_Outward_Line_Item__c newstk = stk[0].clone(false,true,false,false);
                    newstk.ERP7__Serial__c = serId;
                    if(siliinv.size() > 0) newstk.ERP7__Site_Product_Service_Inventory_Stock__c = siliinv[0].Id;
                    system.debug('newstk : '+newstk);
                    if(newstk.ERP7__Site_Product_Service_Inventory_Stock__c != null) insert newstk; else { database.rollback(sp); return 'Selected serial is not avialable'; }
                    delete stk[0];
                    ERP7__Stock_Outward_Line_Item__c newstk1 = [Select Id,Name,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Picture__c,ERP7__Packed_Quantity__c,ERP7__Picked_Quantity__c,ERP7__Logistic_Line_Item__c,ERP7__Logistic_Line_Item__r.Name,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Quantity__c,ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.Name from ERP7__Stock_Outward_Line_Item__c where Id=:newstk.Id limit 1];
                    return JSON.serialize(newstk1);
                }
            }
            else return null;
        }
        catch(Exception e){
            database.rollback(sp);
            system.debug('err : '+e.getMessage() +' Line Number @ : '+ e.getLineNumber());
        }
        
        return null;
    }
    // For dependent Picklist
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    @AuraEnabled 
    public static PicklistWrapper getDependentPicklistMap(String ObjectName, string parentField, string childField) {
        System.debug('ObjectName : '+ObjectName);
        System.debug('parentField: '+parentField);
        System.debug('childField: '+childField);
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
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
        public Map<String, List<String>> pickListMap;
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
}