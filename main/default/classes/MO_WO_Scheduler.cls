public with sharing class MO_WO_Scheduler { 
    @AuraEnabled     
    public static comWrap fetchRoutingDetails(String VId, String RId, String PId, String WCId, String Flow, String OrderItemId1) {  
        system.debug('OrderItemId1 : '+OrderItemId1);
        comWrap comW = new comWrap();
        //=====================================        
        User user=[Select Id,Name,ProfileId,Profile.Name from user where Id=:UserInfo.getUserId()];        
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(user.Id);
        if(customList == null){
            customList = ERP7__Functionality_Control__c.getValues(user.ProfileId);
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
        }
        if(customList != null){
            comW.showBuilder=customList.ERP7__Manufacturing_Builder__c;
            comW.showPlanner=customList.ERP7__Manufacturing_Planner__c;
            comW.showSheduler=customList.ERP7__Manufacturing_Scheduler__c;
            comW.StandOrder = customList.ERP7__Is_Standard_Order__c;
            comW.showVerbasedOnOrder=customList.ERP7__Show_Version_based_on_order_Product__c;
        }
        //==============================
        
        String ordProduct = ''; String OrderItemId = OrderItemId1;
        system.debug('OrderItemId : '+OrderItemId); 
        system.debug('PId : '+PId);
        if(OrderItemId != null && OrderItemId != ''){
            
            List<OrderItem> ordItems = new List<OrderItem>();
            
            ordItems = [SELECT Id, Product2Id, Quantity,ERP7__MO_Remaining_Quantity__c,ERP7__Issue_Manufacturing_Order__c,ERP7__Version__c, ERP7__Version__r.Name FROM OrderItem WHERE Id =: OrderItemId and ERP7__Issue_Manufacturing_Order__c = false LIMIT 1];
            // ordProduct = ordItems[0].Product2Id;
            // shagm
            if(ordItems.size()>0){
                PId = ordProduct = ordItems[0].Product2Id;
                 if(comW.showVerbasedOnOrder) VId = ordItems[0].ERP7__Version__c;
                 system.debug('VId from ord : '+VId);
                 system.debug('ordItems[0].ERP7__MO_Remaining_Quantity__c 1: '+Integer.valueOf(ordItems[0].ERP7__MO_Remaining_Quantity__c));
                comW.selecteQty = Integer.valueOf(ordItems[0].ERP7__MO_Remaining_Quantity__c);//Integer.valueOf(ordItems[0].Quantity);
            }
            else{
                ordItems = [SELECT Id, Product2Id, Quantity,ERP7__Issue_Manufacturing_Order__c,ERP7__Version__c, ERP7__Version__r.Name,ERP7__MO_Remaining_Quantity__c FROM OrderItem WHERE Id =: OrderItemId and ERP7__Issue_Manufacturing_Order__c = true LIMIT 1];
                PId = ordProduct = ordItems[0].Product2Id;
                if(ordItems[0].ERP7__MO_Remaining_Quantity__c > 0) {
                    system.debug('ordItems[0].ERP7__MO_Remaining_Quantity__c 2: '+Integer.valueOf(ordItems[0].ERP7__MO_Remaining_Quantity__c));
                    comW.selecteQty = Integer.valueOf(ordItems[0].ERP7__MO_Remaining_Quantity__c) ;
                   
                }
                //VId = ordItems[0].ERP7__Version__c;
                else
                { comW.errorMsg = System.Label.There_is_already_a_MO_created_for_this_Order_product; }
                 if(comW.showVerbasedOnOrder) VId = ordItems[0].ERP7__Version__c;
                    system.debug('VId from ord : '+VId);
                
            }
            
            //VId = ordItems[0].ERP7__Version__c;
            //PId = ordItems[0].Product2Id;
        }
        
        system.debug('ordProduct : '+ordProduct);
        system.debug('comW.selecteQty : '+comW.selecteQty);
        try{  
            String pFields = '';
            String query1 = '';
            if(comW.StandOrder){
                pFields = UtilClass.selectStarFromSObject('OrderItem');
                utilClass.FLSCheck(pFields.split(','),'OrderItem'); 
                pFields += ', Product2.Name, Product2.ERP7__Picture__c, Product2.ProductCode,Order.ERP7__Expected_Date__c, Order.Name '; 
                query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from OrderItem where Quantity > 0 And Order.ERP7__Is_Closed__c = false ';
                query1 += ' And (ERP7__MO_Remaining_Quantity__c > 0)';
                query1 += ' Order by Order.CreatedDate Desc limit 20'; //Order.ERP7__Expected_Date__c
                List<OrderItem> Solis = Database.query(query1); 
                system.debug('Solis : '+Solis.size());
               if(Solis.size() > 0 && (PId == '')){ if(OrderItemId != null && OrderItemId != ''){ for(OrderItem ord : Solis){ if(OrderItemId == ord.Id) { Solis = new List<OrderItem>(); Solis.add(ord); break; } } } comW.OrderItems = Solis; comW.SelectedOrderItems = comW.OrderItems[0]; comW.Types.add(new SelectOptions('Sales Order', System.Label.Sales_Order)); comW.Type = 'Sales Order'; PId = comW.OrderItems[0].Product2Id; if(comW.showVerbasedOnOrder) VId = comW.OrderItems[0].ERP7__Version__c; system.debug('VId from ord : '+VId); } else comW.Type = 'Product';
            }
            else{
                pFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order_Line_Item__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__Sales_Order_Line_Item__c'); 
                pFields += ', ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ProductCode,ERP7__Sales_Order__r.ERP7__Expected_Date__c, ERP7__Sales_Order__r.Name '; 
                query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Sales_Order_Line_Item__c where ERP7__Quantity__c > 0 And ERP7__Sales_Order__r.ERP7__Is_Closed__c = false ';
                query1 += ' And (ERP7__MO_Remaining_Quantity__c > 0 Or ERP7__WO_Remaining_Quantity__c > 0) ';
                query1 += ' Order by ERP7__Sales_Order__r.ERP7__Expected_Date__c Asc limit 20';
                List<ERP7__Sales_Order_Line_Item__c> Solis = Database.query(query1); 
                if(Solis.size() > 0 && PId == ''){
                    comW.Solis = Solis;
                    comW.SelectedSoli = comW.Solis[0];
                    comW.Types.add(new SelectOptions('Sales Order', System.Label.Sales_Order));
                    comW.Type = 'Sales Order';
                    PId = comW.Solis[0].ERP7__Product__c; } else comW.Type = 'Product';
            }
            
            //if(Solis.size() > 0 && PId == '' && (UserInfo.getFirstName() != 'Imran' && UserInfo.getFirstName() != 'Maqsood')){
            
            
            comW.Types.add(new SelectOptions('Product', System.Label.ProductBundleManagement_Recommendation_Product));
            if(Flow == '' || Flow == 'MO') comW.Types.add(new SelectOptions('Manufacturing Order', System.Label.Manufacturing_Order));
            if(Flow == '' || Flow == 'WO') comW.Types.add(new SelectOptions('Work Order', System.Label.Work_Orders));
            
            pFields = 'IsActive,ProductCode,ERP7__Allow_Back_Orders__c,ERP7__Version__c,ERP7__Routing__c,Name,Id';
            //UtilClass.selectStarFromSObject('Product2');
            // utilClass.FLSCheck(pFields.split(','),'Product2');  
            query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from Product2 where Id != Null ';  
            if(Flow == '') query1 += ' And (ERP7__Issue_Manufacturing_Order__c = true Or ERP7__Issue_Work_Order__c = true) ';
            if(Flow == 'MO') query1 += ' And (ERP7__Issue_Manufacturing_Order__c = true) ';
            if(Flow == 'WO') query1 += ' And (ERP7__Issue_Work_Order__c = true) ';
            if(ordProduct != null && ordProduct != '') query1 += 'AND Id =: ordProduct ';
            else if(PId != '' && PId != Null) query1 += ' And Id = : PId ';
            query1 += ' Order by Name Asc limit 20';
            comW.Products = Database.query(query1);
            
            system.debug('comW.Products.size() : '+comW.Products.size());
            if(comW.Products.size() > 0){
                set<Id> siteId = new set<Id>();
                List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c,ERP7__Channel__r.Id,ERP7__Channel__r.Name from ERP7__Employees__c
                                                    where ERP7__Employee_User__c=:UserInfo.getUserId() AND ERP7__Active__c = true limit 1];
                if(empList.size()>0 && empList != null){
                    List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                                  where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC ];
                    if(dcList.size() > 0) {
                        for(ERP7__Distribution_Channel__c dc : dcList)
                                        siteId.add(dc.ERP7__Site__c);
                    }
                }
               /* List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c
                                                Where product__c In:comW.Products  And
                                                Active__c = true And
                                                Warehouse__c IN: siteId 
                                                and (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
                system.debug('WarehouseItemInventoryStocks : '+WarehouseItemInventoryStocks.size());*/
                List<productStock> allStock  = new  List<productStock>();
                // Map to hold product Ids and corresponding stock data
                Map<Id, AggregateResult> productStockMap = new Map<Id, AggregateResult>();
                
                // Perform the aggregate query once and store the results in the map
                for (AggregateResult result : [
                    SELECT ERP7__Product__c, 
                    SUM(ERP7__Number_of_Item_In_Stock__c) totalStock, 
                    SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) totalAwaiting, 
                    SUM(ERP7__No_of_Items_Requested__c) totalRequested  
                    FROM ERP7__Inventory_Stock__c 
                    WHERE ERP7__Active__c = true 
                    AND ERP7__Warehouse__c IN :siteId 
                    And ERP7__Product__c IN : comW.Products
                    AND (ERP7__Number_of_Item_In_Stock__c > 0 
                         OR ERP7__Number_of_Items_Awaiting_in_Stock__c > 0 
                         OR ERP7__No_of_Items_Requested__c > 0)
                    GROUP BY ERP7__Product__c
                ]) {
                    productStockMap.put((Id)result.get('ERP7__Product__c'), result);
                }
                
                // Iterate over the products and fetch stock data from the map
                for (Product2 prod : comW.Products) {
                    Decimal myStock = 0.0;
                    Decimal demands = 0.0;
                    Decimal Awaitingstocks = 0.0;
                    
                    // Check if the product exists in the aggregate result map
                    if (productStockMap.containsKey(prod.Id)) {
                        AggregateResult result = productStockMap.get(prod.Id);
                        myStock = (Decimal) (result.get('totalStock') != null ? result.get('totalStock') : 0);
                        Awaitingstocks = (Decimal) (result.get('totalAwaiting') != null ? result.get('totalAwaiting') : 0);
                        demands = (Decimal) (result.get('totalRequested') != null ? result.get('totalRequested') : 0);
                    }
                    
                    // Create a productStock object and add it to the list
                    productStock pro = new productStock();
                    pro.Product = prod;
                    pro.stock = myStock;
                    pro.demand = demands;
                    pro.AwaitingStock = Awaitingstocks;
                    allStock.add(pro);
                }
                
                /*for(Product2 prod : comW.Products){
                    Decimal myStock = 0.0;
                    Decimal demands=0.0;
                    Decimal Awaitingstocks = 0.0;
                    
                    for(AggregateResult result: [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock,SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c)totalAwaiting,SUM(ERP7__No_of_Items_Requested__c) totalRequested  FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c IN: siteId And (ERP7__Number_of_Item_In_Stock__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0) GROUP BY ERP7__Product__c]) { 
                        if(prod.Id == (Id)result.get('ERP7__Product__c')) {
                            myStock +=(Decimal)result.get('totalStock'); 
                            Awaitingstocks += (Decimal)result.get('totalAwaiting'); 
                            demands += (Decimal)result.get('totalRequested'); 
                        }
                    }
                    productStock pro =new productStock();
                    pro.Product = prod;
                    pro.stock = myStock;
                    pro.demand = demands;
                    pro.AwaitingStock = Awaitingstocks;
                    allStock.add(pro);
                    
                }*/
                comW.prodStocks = allStock;
                //for(Product2 P : comW.Products) if((UserInfo.getFirstName() == 'Imran' || UserInfo.getFirstName() == 'Maqsood') && P.Id == '01t1o00000BXBEI') { comW.SelectedProduct = P; break; }
                if(PId != '' && PId != Null){ boolean found = false; for(Product2 P : comW.Products) if(P.Id == PId) { comW.SelectedProduct = P; found = true; break; } if(!found){ pFields = pFields = 'IsActive,ERP7__Allow_Back_Orders__c,ERP7__Version__c,ERP7__Routing__c,Name,Id'; /*UtilClass.selectStarFromSObject('Product2');*/ /*utilClass.FLSCheck(pFields.split(','),'Product2');  */ query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from Product2 where Id != Null '; query1 += ' And Id = : PId '; Product2 P = Database.query(query1); comW.Products.add(P); comW.SelectedProduct = P; } }
                else{
                    for(Product2 P : comW.Products) if(P.ERP7__Version__c != Null && P.ERP7__Routing__c != Null) { comW.SelectedProduct = P; break; }
                }
                if(comW.SelectedProduct.Id == Null) comW.SelectedProduct = comW.Products[0]; 
                PId = comW.SelectedProduct.Id;
                system.debug('PId : '+PId);  
                system.debug('VId bfr : '+VId);
                pFields = UtilClass.selectStarFromSObject('ERP7__Version__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__Version__c');  
                query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Version__c Where ERP7__Status__c = \'Certified\' And ERP7__Active__c = true And ERP7__To_Date__c >= TODAY';
                if(VId != '' && VId != Null) query1 += ' And Id =: VId';
                if(PId != '' && PId != Null) query1 += ' And ERP7__Product__c = : PId ';
                query1 += ' Order by ERP7__Default__c DESC limit 20';
                List<ERP7__Version__c> SelectedVersions = Database.query(query1);
                if(SelectedVersions.size() > 0){
                    comW.SelectedVersion = SelectedVersions[0];
                    for(ERP7__Version__c V : SelectedVersions) {
                        comW.VersionIds.add(V.Id);
                        comW.Versions.add(new SelectOptions(V.Id, V.Name));
                        if(V.ERP7__Default__c) comW.SelectedVersion = V;
                        else if(comW.SelectedProduct.ERP7__Version__c != Null && VId == '' && comW.SelectedProduct.ERP7__Version__c == V.Id) comW.SelectedVersion = V;
                    }
                    VId = comW.SelectedVersion.Id;
                    system.debug('VId : '+VId);
                    pFields = UtilClass.selectStarFromSObject('ERP7__Routing__c');
                    pFields += ', ERP7__Address__r.ERP7__Address_Line1__c, ERP7__Address__r.ERP7__Address_Line2__c, ERP7__Address__r.ERP7__Address_Line3__c, ERP7__Address__r.ERP7__City__c, ERP7__Address__r.ERP7__State__c, ERP7__Address__r.ERP7__Country__c, ERP7__Address__r.ERP7__Postal_Code__c, ERP7__BOM_Version__r.Name, ERP7__Product__r.Name, ERP7__Process__r.Name, ERP7__Process__r.RecordType.Name, ERP7__Product__r.ERP7__MOQ__c, ERP7__Product__r.ERP7__Configure__c ';
                    utilClass.FLSCheck(pFields.split(','),'ERP7__Routing__c');  
                    query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Routing__c Where ERP7__Status__c = \'Certified\' ';
                    if(RId != '' && RId != Null) query1 += ' And Id = : RId ';
                    if(PId != '' && PId != Null) query1 += ' And ERP7__Product__c = : PId ';
                    if(VId != '' && VId != Null && !comW.showVerbasedOnOrder && comW.StandOrder) query1 += ' And ERP7__BOM_Version__c = : VId ';
                    else if(VId != '' && VId != Null && !comW.showVerbasedOnOrder) query1 += ' And ERP7__BOM_Version__c = : VId '; // added condition !comW.showVerbasedOnOrder to fix OMI issue of not displaying routing when version was based on order product-- 15_12_23
                    if(Flow == 'MO') query1 += ' And ERP7__Process__r.RecordType.Name = \'Manufacturing Process\' ';
                    if(Flow == 'WO') query1 += ' And ERP7__Process__r.RecordType.Name = \'Maintenance Process\' ';
                    query1 += ' Order by Name Asc limit 1000';
                    List<ERP7__Routing__c> SelectedRouting = Database.query(query1);
                    string ProcessId = '';
                    system.debug('SelectedRouting : '+SelectedRouting.size());
                    if(SelectedRouting.size() > 0){
                        if(SelectedRouting[0].ERP7__Product__r.ERP7__MOQ__c > 0) comW.qtyMultiplier = Integer.valueof(SelectedRouting[0].ERP7__Product__r.ERP7__MOQ__c);
                       // comW.SelectedRouting = SelectedRouting[0];//commented by bushra only one line 4/6/2025
                        for(ERP7__Routing__c r:SelectedRouting){
                            if(r.ERP7__BOM_Version__c ==comW.SelectedVersion.Id) comW.SelectedRouting = r;
                        }
                        for(ERP7__Routing__c R : SelectedRouting) {
                            comW.Routings.add(new SelectOptions(R.Id, R.Name));
                            if(comW.SelectedProduct.ERP7__Routing__c != Null && RId == '' && comW.SelectedProduct.ERP7__Routing__c == R.Id) comW.SelectedRouting = R;
                        }
                        RId = comW.SelectedRouting.Id;
                        
                        ProcessId = comW.SelectedRouting.ERP7__Process__c;
                        
                        if(ProcessId != null && ProcessId != ''){
                            List<AggregateResult> prclst = [Select ERP7__Process__c,Sum(ERP7__Progress__c)prgs from ERP7__Process_Cycle__c where ERP7__Process__c =: ProcessId Group by ERP7__Process__c limit 2000];
                            List<ERP7__Process_Cycle__c> Prc2update = [Select Id,Name from ERP7__Process_Cycle__c where ERP7__Process__c =: ProcessId];
                            for(AggregateResult pp : prclst){ if(pp.get('prgs') == null || pp.get('prgs') == 0) { for(ERP7__Process_Cycle__c newPrc : Prc2update){ Decimal d   = 100 ; if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Progress__c.isUpdateable()){newPrc.ERP7__Progress__c = d.divide(Prc2update.size(), 2);}else{/*No access*/} } } }
                            if(Schema.sObjectType.ERP7__Process_Cycle__c.isUpdateable()){update Prc2update;}else{/*No access*/}
                            
                        }
                        
                        Map<Id, ERP7__Operation__c> OperationMap = new Map<Id, ERP7__Operation__c>();
                        Map < Id, ERP7__Work_Center__c > ProcessWC = new Map < Id, ERP7__Work_Center__c > (); 
                        Set < Id > RoutingProcesses = new Set < Id > ();
                        List < ERP7__Operation__c > Operations = [Select Id, Name, ERP7__Routing_Link__c, ERP7__Description__c, ERP7__Fixed_Cost__c, ERP7__Move_Time__c, ERP7__Next_Operation_No__c, ERP7__Operation_No__c,
                                                                  ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, ERP7__Process_Cycle__r.ERP7__Process__c, ERP7__Quantity__c, ERP7__Required__c, ERP7__Routing__c, ERP7__Run_Time__c, ERP7__Setup_Time__c, ERP7__Variable_Cost__c,
                                                                  ERP7__Work_Center__c, ERP7__Work_Center__r.Name,ERP7__Work_Center__r.ERP7__Available_Capacity__c ,ERP7__Wait_Time__c, ERP7__Type__c, ERP7__Auto_Clock_In__c,ERP7__Process_Cycle__r.ERP7__Progress__c
                                                                  From ERP7__Operation__c Where ERP7__Routing__c =: RId And ERP7__Work_Center__c != Null Order By ERP7__Process_Cycle__r.CreatedDate, ERP7__Operation_No__c ASC
                                                                 ];
                        Set<Id> wcIds = new Set<Id>();
                        
                        for (ERP7__Operation__c Operation: Operations) {
                            if(WCId == ''){
                                if(Operation.ERP7__Work_Center__c != Null) wcIds.add(Operation.ERP7__Work_Center__c);
                                if(SelectedRouting[0].ERP7__Process__r.RecordType.Name == 'Manufacturing Process'){
                                    OperationMap.put(Operation.ERP7__Process_Cycle__c, Operation);
                                    if (Operation.ERP7__Process_Cycle__c != Null && Operation.ERP7__Work_Center__c != Null) {
                                        ProcessWC.put(Operation.ERP7__Process_Cycle__c, new ERP7__Work_Center__c(Id=Operation.ERP7__Work_Center__c,Name=Operation.ERP7__Work_Center__r.Name));
                                    }
                                    if (Operation.ERP7__Process_Cycle__c != Null) {
                                        RoutingProcesses.add(Operation.ERP7__Process_Cycle__c);
                                    } 
                                }
                            } else wcIds.add(WCId);
                        }
                        Integer rps = 0;
                      
                        if(SelectedRouting[0].ERP7__Process__r.RecordType.Name == 'Maintenance Process') comW.WOS.add(new ERP7__WO__c(ERP7__Work_Center__c = comW.SelectedRouting.ERP7__Work_Center__c, ERP7__Type__c = 'Maintenance'));
                        String wcFields = UtilClass.selectStarFromSObject('ERP7__Work_Center__c');
                        wcFields += ' ,ERP7__Plant__r.Name, ERP7__Supervisor__r.Name, ERP7__Vendor__r.Name, ERP7__Cost_Center__r.Name ';
                        utilClass.FLSCheck(wcFields.split(','),'ERP7__Work_Center__c');  
                        String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Work_Center__c ';
                        query += ' Where Id In : wcIds And Start_Date__c != Null And End_Date__c != Null ';
                        query += ' Order by CreatedDate Asc limit 1000';
                        
                        comW.WCS = Database.query(query);
                        Map<Id,ERP7__Work_Center__c> workCenterMap = new Map<Id, ERP7__Work_Center__c>();
                        for(ERP7__Work_Center__c wc :  comW.WCS){
                            workCenterMap.put(wc.Id, wc);
                        }
                        
                          for (Id PCId: RoutingProcesses) {
                              
                            ERP7__WO__c WO2Create = new ERP7__WO__c();
                            WO2Create.Name = OperationMap.get(PCId).ERP7__Process_Cycle__r.Name;   //MO.Name;
                            
                            WO2Create.Progress__c = OperationMap.get(PCId).ERP7__Process_Cycle__r.ERP7__Progress__c;
                            
                            WO2Create.Planned_Date__c = System.Today();
                            //WO2Create.Progress__c = 0;
                            WO2Create.ERP7__Process_Cycle__c = PCId;
                            WO2Create.ERP7__Status__c = 'Issued';
                            if(comW.showVerbasedOnOrder) WO2Create.ERP7__Version__c = comW.SelectedVersion.Id;
                            else WO2Create.ERP7__Version__c = SelectedRouting[0].ERP7__BOM_Version__c;
                            //WO2Create.ERP7__Project__c = Routings[0].ERP7__Project__c;
                            WO2Create.ERP7__Routing__c = SelectedRouting[0].Id;
                            WO2Create.ERP7__Site__c = SelectedRouting[0].ERP7__Finished_Products_Site__c;
                            //WO2Create.ERP7__MO__c = MO.Id;
                            WO2Create.ERP7__Product__c = SelectedRouting[0].ERP7__Product__c;
                            //WO2Create.ERP7__Quantity_Ordered__c = MO.ERP7__Quantity__c;
                            //WO2Create.ERP7__Sales_Order__c = MO.ERP7__Sales_Order__c;
                            //WO2Create.ERP7__Sales_Order_Line_Item__c = MO.ERP7__Sales_Order_Line_Item__c;
                            if(rps == 0){
                                WO2Create.ERP7__Start_Date__c = system.Now();
                                WO2Create.ERP7__End_Date__c = system.Now().addHours(1);
                            }
                            else{ WO2Create.ERP7__Start_Date__c = system.Now().addHours(rps); WO2Create.ERP7__End_Date__c = system.Now().addHours(1+rps); }
                            WO2Create.ERP7__Type__c = 'Manufacturing';
                            if(ProcessWC.containsKey(PCId)) {
                                WO2Create.ERP7__Work_Center__c = ProcessWC.get(PCId).Id;
                                if(WO2Create.ERP7__Work_Center__c !=null) WO2Create.ERP7__Work_Center__r = workCenterMap.get(WO2Create.ERP7__Work_Center__c);
                            }
                            comW.WOS.add(WO2Create);
                            rps++;
                        }
                    } else  comW.errorMsg = System.Label.Routings_unavailable_under_Version+' : '+comW.SelectedVersion.Name;
                } else  comW.errorMsg =  System.Label.Versions_unavailable_under_Product+ ' : '+comW.SelectedProduct.Name;
            }
            
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); system.debug('comW.errorMsg : '+comW.errorMsg);}
        return comW;
    }
    
    
    @AuraEnabled   
    public static comWrap fetchMODetails(String MOId) {  
        comWrap comW = new comWrap();    
        try{    
            String pFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
            utilClass.FLSCheck(pFields.split(','),'ERP7__Manufacturing_Order__c'); 
            pFields += ', ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c '; 
            String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Manufacturing_Order__c where Id = : MOId ';
            comW.MOS = Database.query(query1); 
            
            if(comW.MOS.size() > 0){
                String PId = comW.MOS[0].ERP7__Product__c;
                String VId = comW.MOS[0].ERP7__Version__c;
                String RId = comW.MOS[0].ERP7__Routing__c;
                
                pFields = UtilClass.selectStarFromSObject('ERP7__Version__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__Version__c');  
                query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Version__c Where ERP7__Status__c = \'Certified\' And ERP7__Active__c = true And ERP7__To_Date__c >= TODAY';
                if(VId != '' && VId != Null) query1 += ' And Id = : VId ';
                if(PId != '' && PId != Null) query1 += ' And ERP7__Product__c = : PId ';
                query1 += ' Order by Name Asc limit 1000';
                List<ERP7__Version__c> SelectedVersions = Database.query(query1);
                
                if(SelectedVersions.size() > 0){
                    comW.SelectedVersion = SelectedVersions[0];
                    pFields = UtilClass.selectStarFromSObject('ERP7__Routing__c');
                    pFields += ', ERP7__Address__r.ERP7__Address_Line1__c, ERP7__Address__r.ERP7__Address_Line2__c, ERP7__Address__r.ERP7__Address_Line3__c, ERP7__Address__r.ERP7__City__c, ERP7__Address__r.ERP7__State__c, ERP7__Address__r.ERP7__Country__c, ERP7__Address__r.ERP7__Postal_Code__c, ERP7__BOM_Version__r.Name, ERP7__Product__r.Name, ERP7__Process__r.Name, ERP7__Process__r.RecordType.Name, ERP7__Product__r.ERP7__MOQ__c, ERP7__Product__r.ERP7__Configure__c ';
                    utilClass.FLSCheck(pFields.split(','),'ERP7__Routing__c');  
                    query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Routing__c Where ERP7__Status__c = \'Certified\' ';
                    if(RId != '' && RId != Null) query1 += ' And Id = : RId ';
                    query1 += ' Order by Name Asc limit 1000';
                    List<ERP7__Routing__c> SelectedRouting = Database.query(query1);
                    
                    if(SelectedRouting.size() > 0){
                        if(SelectedRouting[0].ERP7__Product__r.ERP7__MOQ__c > 0) comW.qtyMultiplier = Integer.valueof(SelectedRouting[0].ERP7__Product__r.ERP7__MOQ__c);
                        comW.SelectedRouting = SelectedRouting[0];
                        for(ERP7__Routing__c R : SelectedRouting) {
                            comW.Routings.add(new SelectOptions(R.Id, R.Name));
                            if(comW.SelectedProduct.ERP7__Routing__c != Null && RId == '' && comW.SelectedProduct.ERP7__Routing__c == R.Id) comW.SelectedRouting = R;
                        }
                        RId = comW.SelectedRouting.Id;
                    } 
                } 
                pFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__WO__c');  
                query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__WO__c Where ERP7__MO__c = : MOId ';
                comW.WOS = Database.query(query1);
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled   
    public static comWrap fetchWODetails(String WOId) {  
        comWrap comW = new comWrap();    
        try{    
            String pFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            utilClass.FLSCheck(pFields.split(','),'ERP7__WO__c');  
            String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__WO__c Where Id = : WOId ';
            comW.WOS = Database.query(query1); 
            
            if(comW.WOS.size() > 0){
                String PId = comW.WOS[0].ERP7__Product__c;
                String VId = comW.WOS[0].ERP7__Version__c;
                String RId = comW.WOS[0].ERP7__Routing__c;
                
                pFields = UtilClass.selectStarFromSObject('ERP7__Version__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__Version__c');  
                query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Version__c Where ERP7__Status__c = \'Certified\' And ERP7__Active__c = true And ERP7__To_Date__c >= TODAY';
                if(VId != '' && VId != Null) query1 += ' And Id = : VId ';
                if(PId != '' && PId != Null) query1 += ' And ERP7__Product__c = : PId ';
                query1 += ' Order by Name Asc limit 1000';
                List<ERP7__Version__c> SelectedVersions = Database.query(query1);
                
                if(SelectedVersions.size() > 0){
                    comW.SelectedVersion = SelectedVersions[0];
                    pFields = UtilClass.selectStarFromSObject('ERP7__Routing__c');
                    pFields += ', ERP7__Address__r.ERP7__Address_Line1__c, ERP7__Address__r.ERP7__Address_Line2__c, ERP7__Address__r.ERP7__Address_Line3__c, ERP7__Address__r.ERP7__City__c, ERP7__Address__r.ERP7__State__c, ERP7__Address__r.ERP7__Country__c, ERP7__Address__r.ERP7__Postal_Code__c, ERP7__BOM_Version__r.Name, ERP7__Product__r.Name, ERP7__Process__r.Name, ERP7__Process__r.RecordType.Name, ERP7__Product__r.ERP7__MOQ__c, ERP7__Product__r.ERP7__Configure__c ';
                    utilClass.FLSCheck(pFields.split(','),'ERP7__Routing__c');  
                    query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Routing__c Where ERP7__Status__c = \'Certified\' ';
                    if(RId != '' && RId != Null) query1 += ' And Id = : RId ';
                    query1 += ' Order by Name Asc limit 1000';
                    List<ERP7__Routing__c> SelectedRouting = Database.query(query1);
                    
                    if(SelectedRouting.size() > 0){
                        if(SelectedRouting[0].ERP7__Product__r.ERP7__MOQ__c > 0) comW.qtyMultiplier = Integer.valueof(SelectedRouting[0].ERP7__Product__r.ERP7__MOQ__c);
                        comW.SelectedRouting = SelectedRouting[0];
                        for(ERP7__Routing__c R : SelectedRouting) {
                            comW.Routings.add(new SelectOptions(R.Id, R.Name));
                            if(comW.SelectedProduct.ERP7__Routing__c != Null && RId == '' && comW.SelectedProduct.ERP7__Routing__c == R.Id) comW.SelectedRouting = R;
                        }
                        RId = comW.SelectedRouting.Id;
                    } 
                } 
                
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled 
    public static comWrap fetchWorkCenterDetails(String WCId, Date selDate, String Action, String WOId) {  
        Date selectedDate = (selDate != Null)? selDate : system.today();
        if(WOId == Null) WOId = '';
        ERP7__WO__c pWO = new ERP7__WO__c();
        if(WOId != '' && Action == ''){
            String pFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            utilClass.FLSCheck(pFields.split(','),'ERP7__WO__c');  
            String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__WO__c Where Id = : WOId ';
            pWO = Database.query(query1);
            if(selDate == null) selectedDate = Date.valueOf(pWO.ERP7__Start_Date__c);
        }
        if(Action == 'next') selectedDate = selectedDate+1;
        if(Action == 'prev') selectedDate = selectedDate-1;
        comWrap comW = new comWrap(); 
        try{    
            
            //fetching Work Centers
            String wcFields = UtilClass.selectStarFromSObject('ERP7__Work_Center__c');
            utilClass.FLSCheck(wcFields.split(','),'ERP7__Work_Center__c'); 
            wcFields += ' ,ERP7__Plant__r.Name, ERP7__Supervisor__r.Name, ERP7__Vendor__r.Name, ERP7__Cost_Center__r.Name ';
            //utilClass.FLSCheck(wcFields.split(','),'ERP7__Work_Center__c');  //commented by Bushra to check if this is causing issue in Firefox as reported by Jan
            String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Work_Center__c ';
            query += ' Where Id =: WCId And Start_Date__c != Null And End_Date__c != Null ';
            query += ' Order by CreatedDate Asc limit 1000';
            List<ERP7__Work_Center__c> WorkCenters = Database.query(query);
            Set<Decimal> Capacities=new Set<Decimal>(); 
            DateTime StartTime, EndTime;
            DateTime StartDate, EndDate;
            Map<Id, List<ERP7__WO__c>> WCWOS = new Map<Id, List<ERP7__WO__c>>();
            for(ERP7__Work_Center__c WC: WorkCenters){
                system.debug('WC.End_Date__c : '+WC.End_Date__c);
                system.debug('WC.Start_Date__c : '+WC.Start_Date__c);
                system.debug('today : '+System.today());
                if(WC.End_Date__c < System.today()) { comW.errorMsg = System.Label.Please_check_the_start_end_date_of_the_Work_center; return comW;}
                if(WC.Start_Date__c > System.today()) { comW.errorMsg = System.Label.Please_check_the_start_end_date_of_the_Work_center; return comW;}
                if(WC.ERP7__Available_Capacity__c != Null) Capacities.add(WC.ERP7__Available_Capacity__c);
                Date WCST = WC.Start_Date__c.date();
                Date WCET = WC.End_Date__c.date();
                if(selectedDate >= WCST && selectedDate <= WCET){ if(StartTime == Null || StartTime.time() > WC.Start_Date__c.time()) StartTime = Datetime.newInstance(selectedDate, WC.Start_Date__c.time()); if(endTime == Null || endTime.time() < WC.End_Date__c.time()) endTime = Datetime.newInstance(selectedDate, WC.End_Date__c.time()); if(StartDate == Null || StartDate > WC.Start_Date__c) StartDate = WC.Start_Date__c; if(EndDate == Null || EndDate < WC.End_Date__c) EndDate = WC.End_Date__c; }
                WCWOS.put(WC.Id, new List<ERP7__WO__c>());
            }
            
            wcFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            utilClass.FLSCheck(wcFields.split(','),'ERP7__WO__c'); 
            wcFields += ', ERP7__Product__r.Name, ERP7__Version__r.Name, ERP7__Routing__r.Name, ERP7__Project__r.Name, ERP7__Sales_Order__r.Name '; 
            //utilClass.FLSCheck(wcFields.split(','),'ERP7__WO__c'); //commented by Bushra to check if this is causing issue in Firefox as reported by Jan
            query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__WO__c Where ERP7__Is_Closed__c = false And ERP7__Work_Center__c  = :WCId And '; query+= ' ERP7__End_Date__c >= Today And ';
            query+= '((ERP7__Start_Date__c < :StartTime And ERP7__End_Date__c <= :endTime And ERP7__End_Date__c > :StartTime) Or ';
            query+= '(ERP7__Start_Date__c >= :StartTime And ERP7__End_Date__c <= :endTime) Or '; query+= '(ERP7__Start_Date__c >= :StartTime And ERP7__End_Date__c > :endTime And ERP7__Start_Date__c < :endTime) Or '; query+= '(ERP7__Start_Date__c < :StartTime And ERP7__End_Date__c > :endTime)) '; query+= ' Order by ERP7__Start_Date__c Asc limit 10000';
            List< ERP7__WO__c > WOS = Database.query(query);
            for(ERP7__WO__c WO : WOS){ if(WO.ERP7__Work_Center__c != Null && WCWOS.containskey(WO.ERP7__Work_Center__c)) WCWOS.get(WO.ERP7__Work_Center__c).add(WO); }
            List < TimeSlot > times=new List < TimeSlot >();
            times=getAllTimeSlotList(StartTime, endTime, 60);
            
            if(StartTime!=null && endTime!=null) { comW.SliderTimeSlots=getAllTimeSlotList(StartTime, endTime, 60); comW.selDate=selectedDate; if(selectedDate < EndDate.date()) comW.NextDisabled = false; if(selectedDate > system.Today() && selectedDate > StartDate.date()) comW.PrevDisabled = false; comW.WCendDate = EndDate.date(); }
            
            if(comW.SliderTimeSlots.size()>0){ comW.SliderStartTime=(comW.SliderTimeSlots[0].slotST).Hour(); comW.SliderEndTime=(comW.SliderTimeSlots[comW.SliderTimeSlots.size()-1].slotET).Hour(); }
           
            Boolean FAS = false;
            for(ERP7__Work_Center__c WC: WorkCenters){ WorkCenterWrapper WCW = new WorkCenterWrapper(); WCW.WorkCenter = WC; for(TimeSlot TS : comW.SliderTimeSlots){ TimeSlot newTS = new TimeSlot(); newTS.slotST = TS.slotST; newTS.slotET = TS.slotET; newTS.Notification = ''; newTS.selDate = comW.selDate; newTS.WorkCenterId = WC.Id; if(TS.slotST.time() < WC.Start_Date__c.time() || TS.slotET.time() < WC.Start_Date__c.time() || TS.slotST.time() > WC.End_Date__c.time() || TS.slotET.time() > WC.End_Date__c.time()){ newTS.IsAvailable = false; newTS.Status = ''; } else{ newTS.IsAvailable = true; newTS.Status = 'Applicable'; for(ERP7__WO__c WO : WCWOS.get(WC.Id)){System.debug('WO.ERP7__Start_Date__c'+WO.ERP7__Start_Date__c);System.debug('WO.ERP7__End_Date__c'+WO.ERP7__End_Date__c);System.debug('WO.TS.slotST'+TS.slotST);System.debug('WO.TS.slotET'+TS.slotET); if((WO.ERP7__Start_Date__c < TS.slotST && WO.ERP7__End_Date__c <= TS.slotET && WO.ERP7__End_Date__c > TS.slotST) || (WO.ERP7__Start_Date__c >= TS.slotST && WO.ERP7__End_Date__c <= TS.slotET) || (WO.ERP7__Start_Date__c >= TS.slotST && WO.ERP7__End_Date__c > TS.slotET && WO.ERP7__Start_Date__c < TS.slotET) || (WO.ERP7__Start_Date__c < TS.slotST && WO.ERP7__End_Date__c > TS.slotET)){ newTS.RegId = WO.Id; newTS.Status = 'Booked'; newTS.Notification = WO.Name; break; } } } WCW.WorkCenterSlots.add(newTS); if(newTS.IsAvailable == true && newTS.Status == 'Applicable' && FAS == false){ comW.SliderLandingStartTime = newTS.slotST.hour(); comW.SliderLandingEndTime = newTS.slotET.hour(); FAS = true; } } comW.WorkCenterList.add(WCW); }
            
            if(comW.SliderStartTime == Null && selectedDate == system.today() && comW.NextDisabled == false) { comWrap comWn = fetchWorkCenterDetails(WCId, selectedDate+1, '',''); comWn.PrevDisabled = true; return comWn; }
            
            if(StartTime!=null && endTime!=null && comW.SliderStartTime != Null) { if(comW.SliderLandingStartTime == Null) { comW.SliderLandingStartTime=comW.SliderStartTime; comW.SliderLandingEndTime=comW.SliderLandingStartTime+1; } comW.SliderStartTimes = StartTime.getTime(); comW.SliderEndTimes = EndTime.getTime(); comW.SliderLandingStartTimes = StartTime.getTime(); comW.SliderLandingEndTimes = StartTime.addDays(1).getTime(); } else  comW.errorMsg = System.Label.Work_center_unavailable; 
            
            if(WOId != '' && pWO.ERP7__Start_Date__c != Null && pWO.ERP7__End_Date__c != Null){ comW.SliderLandingStartTime = pWO.ERP7__Start_Date__c.hour(); comW.SliderLandingEndTime = pWO.ERP7__End_Date__c.hour(); }
            
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c(); FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid()); if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId()); if(FC==null) FC = ERP7__Functionality_Control__c.getInstance(); } 
            if(FC != null){ comW.showDateEdiatable = FC.ERP7__Show_Date_as_editable_in_Scheduler__c; }
            
            Boolean exist=false;
            
            for(ERP7__WO__c WO : WOS){ /*var Start = Datetime.newInstance(WO.ERP7__Start_Date__c, WC.Start_Date__c.time());*/ if(WO.ERP7__Start_Date__c.hour()==comW.SliderLandingStartTime && WO.ERP7__End_Date__c.hour()==comW.SliderLandingEndTime) { exist=true; } else if(comW.SliderLandingStartTime>WO.ERP7__End_Date__c.hour()) exist=false; }
            
            if(exist){ comWrap comWn = fetchWorkCenterDetails(WCId, selectedDate+1, '',''); comWn.showDateEdiatable =comW.showDateEdiatable; return comWn; }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); system.debug('comW.errorMsg : '+comW.errorMsg);}
        return comW;
    }
    
@AuraEnabled
public static List<comWrap> FetchWC(List<String> WCIds, Date selDate,Date selendDate, String Action, List<String> WOIds) {
    List<comWrap> comWrapList = new List<comWrap>();
    Date selectedDate = (selDate != null) ? selDate : system.today();
      Date selectedEndDate = (selendDate != null) ? selendDate : system.today();

    System.debug('==== WCIds: ' + WCIds);
    System.debug('==== selectedDate: ' + selectedDate);
    System.debug('==== WOIds: ' + WOIds);

    try {
        String wcFields = UtilClass.selectStarFromSObject('ERP7__Work_Center__c');
        wcFields += ', ERP7__Plant__r.Name, ERP7__Supervisor__r.Name, ERP7__Vendor__r.Name, ERP7__Cost_Center__r.Name';
        utilClass.FLSCheck(wcFields.split(','), 'ERP7__Work_Center__c');

        String query = 'SELECT ' + String.escapeSingleQuotes(wcFields) + ' FROM ERP7__Work_Center__c ';
        query += 'WHERE Id IN :WCIds AND Start_Date__c != NULL AND End_Date__c != NULL ';
        query += 'ORDER BY CreatedDate ASC LIMIT 1000';

        List<ERP7__Work_Center__c> WorkCenters = Database.query(query);
        System.debug('==== WorkCenters: ' + WorkCenters.size());

        DateTime StartTime, EndTime;
        DateTime StartDate, EndDate;
        Map<Id, List<ERP7__WO__c>> WCWOS = new Map<Id, List<ERP7__WO__c>>();

        // Initialize WCWOS
        for (ERP7__Work_Center__c WC : WorkCenters) {
            System.debug('==== WC.End_Date__c: ' + WC.End_Date__c);
            System.debug('==== WC.Start_Date__c: ' + WC.Start_Date__c);

            if (WC.End_Date__c < System.today() || WC.Start_Date__c > System.today()) {
                continue; // Skip invalid date ranges
            }
            
            WCWOS.put(WC.Id, new List<ERP7__WO__c>());
        }
        System.debug('==== WCWOS: ' + WCWOS);

        // Query Work Orders
        String woFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
        woFields += ', ERP7__Product__r.Name, ERP7__Version__r.Name, ERP7__Routing__r.Name, ERP7__Project__r.Name, ERP7__Sales_Order__r.Name';
        utilClass.FLSCheck(woFields.split(','), 'ERP7__WO__c');

        query = 'SELECT ' + String.escapeSingleQuotes(woFields) + ' FROM ERP7__WO__c ';
        query += 'WHERE ERP7__Is_Closed__c = false AND ERP7__Work_Center__c IN :WCIds AND ';
        query += 'ERP7__End_Date__c >= TODAY AND ';
        query += '((ERP7__Start_Date__c < :StartTime AND ERP7__End_Date__c <= :EndTime AND ERP7__End_Date__c > :StartTime) OR ';
        query += '(ERP7__Start_Date__c >= :StartTime AND ERP7__End_Date__c <= :EndTime) OR ';
        query += '(ERP7__Start_Date__c >= :StartTime AND ERP7__End_Date__c > :EndTime AND ERP7__Start_Date__c < :EndTime) OR ';
        query += '(ERP7__Start_Date__c < :StartTime AND ERP7__End_Date__c > :EndTime)) ';
        query += 'ORDER BY ERP7__Start_Date__c ASC LIMIT 10000';

        List<ERP7__WO__c> WOS = Database.query(query);
        System.debug('==== WOS: ' + WOS.size());

        // Map Work Orders to Work Centers
        for (ERP7__WO__c WO : WOS) {
            if (WCWOS.containsKey(WO.ERP7__Work_Center__c)) {
                WCWOS.get(WO.ERP7__Work_Center__c).add(WO);
            }
            if (WOIds != null) {
                WOIds.add(WO.Id);
            }
        }

        // Process each comWrap in comWrapList
      //  for (comWrap comW : comWrapList) {
        
      for (ERP7__Work_Center__c WC : WorkCenters) {
          
          System.debug('in for loop 1 ');
          comWrap comW = new comWrap();
          Date WCST = WC.Start_Date__c.date();
            Date WCET = WC.End_Date__c.date();

            if (selectedDate >= WCST && selectedDate <= WCET) {
                System.debug('in if cond1');
                if (StartTime == null || StartTime.time() > WC.Start_Date__c.time())
                    StartTime = Datetime.newInstance(selectedDate, WC.Start_Date__c.time());
                if (EndTime == null || EndTime.time() < WC.End_Date__c.time())
                    EndTime = Datetime.newInstance(selectedDate, WC.End_Date__c.time());
                if (StartDate == null || StartDate > WC.Start_Date__c)
                    StartDate = WC.Start_Date__c;
                if (EndDate == null || EndDate < WC.End_Date__c)
                    EndDate = WC.End_Date__c;
            }
            if (StartTime != null && EndTime != null) {
                /*List<TimeSlot> timeslotList = new List<TimeSlot>(); 
                for (ERP7__WO__c WO : WOS) {
                    TimeSlot tsl = new TimeSlot();
                    tsl = getAllTimeSlotList(StartTime, EndTime, 60);
                    timeslotList.add(tsl);
                }
                comW.SliderTimeSlots = timeslotList;*/
                comW.SliderTimeSlots = getAllTimeSlotList(StartTime, EndTime, 60);
                comW.selDate = selectedDate;
System.debug('==== SliderTimeSlots: ' + comW.SliderTimeSlots);
                // Set navigation buttons
                comW.NextDisabled = selectedDate < EndDate.date();
                comW.PrevDisabled = selectedDate > System.today() && selectedDate > StartDate.date();
                comW.WCendDate = EndDate.date();

                // Process SliderTimeSlots
                if (comW.SliderTimeSlots != null && comW.SliderTimeSlots.size() > 0) {
                    comW.SliderStartTime = (comW.SliderTimeSlots[0].slotST).hour();
                    comW.SliderEndTime = (comW.SliderTimeSlots[comW.SliderTimeSlots.size() - 1].slotET).hour();
                }

                // Process TimeSlots for each Work Center
               // for (ERP7__Work_Center__c WC : WorkCenters) {
                    WorkCenterWrapper WCW = new WorkCenterWrapper();
                    WCW.WorkCenter = WC;
                    WCW.WorkCenterSlots = new List<TimeSlot>();

                    for (TimeSlot TS : comW.SliderTimeSlots) {
                        System.debug('TS'+TS);
                        TimeSlot newTS = new TimeSlot();
                        newTS.slotST = TS.slotST;
                        System.debug('TS slotst'+TS.slotST);
                        newTS.slotET = TS.slotET;
                        System.debug('TS et slot'+TS.slotET);

                        newTS.Notification = '';
                        newTS.selDate = selectedDate;
                        newTS.WorkCenterId = WC.Id;
                        System.debug('TS WorkCenterId'+TS.WorkCenterId);

                      if (TS.slotST.time() < WC.Start_Date__c.time() || TS.slotET.time() > WC.End_Date__c.time() || 
    TS.slotST.time() > WC.End_Date__c.time() || TS.slotET.time() < WC.Start_Date__c.time()) {
                                System.debug('if condition afe for lop');

    // If the time slot falls outside the Work Center's time range
    System.debug('if condition afe for lop newTS.IsAvailable'+newTS.IsAvailable);
    newTS.IsAvailable = false;
    newTS.Status = '';
} else {
    System.debug('else condition afe for lop');
    // If the time slot is within the Work Center's time range
    newTS.IsAvailable = true;
    newTS.Status = 'Applicable';
System.debug('else condition afe for lop newTS.IsAvailable'+newTS.IsAvailable);
    
    // Iterate through Work Orders to check for overlap and update status
    for (ERP7__WO__c WO : WCWOS.get(WC.Id)) {
        System.debug('for loop fr overlap condition afe for lop');
        if ((WO.ERP7__Start_Date__c < TS.slotST && WO.ERP7__End_Date__c <= TS.slotET && WO.ERP7__End_Date__c > TS.slotST) || 
            (WO.ERP7__Start_Date__c >= TS.slotST && WO.ERP7__End_Date__c <= TS.slotET) || 
            (WO.ERP7__Start_Date__c >= TS.slotST && WO.ERP7__End_Date__c > TS.slotET && WO.ERP7__Start_Date__c < TS.slotET) || 
            (WO.ERP7__Start_Date__c < TS.slotST && WO.ERP7__End_Date__c > TS.slotET)) {
            newTS.IsAvailable = false;
            newTS.Status = 'Booked';
            newTS.Notification = WO.Name;
            break; // Exit the loop once a match is found
        }
    }
}


                        // Add TimeSlot to WorkCenterWrapper
                        WCW.WorkCenterSlots.add(newTS);
                    }
                    comW.WorkCenterList.add(WCW);
                
                //}
            }
          comWrapList.add(comW);
      }  
        //}
    } catch (Exception e) {
        comWrap errorWrap = new comWrap();
        errorWrap.errorMsg = e.getMessage() + ' Line Number @ : ' + e.getLineNumber();
        System.debug('errorMsg: ' + errorWrap.errorMsg);
        comWrapList.add(errorWrap);
    }

    return comWrapList;
}




    @AuraEnabled 
    public static comWrap fetchAllProducts(String searchStr, String Type, String Flow) {  
        comWrap comW = new comWrap();
        if(searchStr == null) searchStr = '';
        searchStr = '%'+searchStr+'%';
        boolean StandOrder = false;
        
        User user=[Select Id,Name,ProfileId,Profile.Name from user where Id=:UserInfo.getUserId()];        
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(user.Id);
        if(customList == null){ customList = ERP7__Functionality_Control__c.getValues(user.ProfileId);
                               if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
                              }
        if(customList != null){
            StandOrder = customList.ERP7__Is_Standard_Order__c;
        }
        
        try{
            if(Type == 'Product'){ 
                String pFields = 'IsActive,ERP7__Allow_Back_Orders__c,ProductCode,ERP7__Version__c,ERP7__Routing__c,Name,Id';//UtilClass.selectStarFromSObject('Product2');
                // utilClass.FLSCheck(pFields.split(','),'Product2');  
                String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from Product2 where (ERP7__Issue_Manufacturing_Order__c = true Or ERP7__Issue_Work_Order__c = true) ';
                query1 += ' And (Name like : searchStr ';
                query1 += ' Or ProductCode like : searchStr ';
                query1 += ' Or ERP7__Barcode__c like : searchStr ';
                query1 += ' Or StockKeepingUnit like : searchStr ';
                query1 += ' Or ERP7__SKU__c like : searchStr ';
                query1 += ' Or ERP7__ASIN_Code__c like : searchStr) ';
                if(Flow == 'MO') query1 += ' And (ERP7__Issue_Manufacturing_Order__c = true) ';
                if(Flow == 'WO') query1 += ' And (ERP7__Issue_Work_Order__c = true) ';
                query1 += ' Order by Name Asc limit 20';
                comW.Products = Database.query(query1);
                if(comW.Products.size() > 0){
                   // List<ERP7__Stock_Outward_Line_Item__c> SOLIList=new List<ERP7__Stock_Outward_Line_Item__c>();
                   // List<ERP7__Stock_Inward_Line_Item__c> SILIList=new List<ERP7__Stock_Inward_Line_Item__c>();
                   // SILIList = [Select Id,Name ,ERP7__Product__c,ERP7__Quantity__c from ERP7__Stock_Inward_Line_Item__c where ERP7__Active__c =true AND ERP7__Quantity__c > 0 AND ERP7__Status__c = 'Awaiting Stock' AND ERP7__Product__c In:comW.Products AND (ERP7__Purchase_Orders__c != null Or ERP7__Manufacturing_Order__c != null)];
                    
                   // if(Schema.sobjectType.ERP7__Stock_Outward_Line_Item__c.Fields.ERP7__Sales_Order__c.isAccessible()) SOLIList=[Select Id,Name,ERP7__Product__c,ERP7__Quantity__c from ERP7__Stock_Outward_Line_Item__c where ERP7__Product__c IN:comW.Products AND ERP7__Status__c='Requested' AND ERP7__Sales_Order__c !=null AND ERP7__Sales_Order_Line_Item__c != null AND ERP7__Active__c=true];            else if(Schema.sobjectType.ERP7__Stock_Outward_Line_Item__c.Fields.ERP7__Order__c.isAccessible()) SOLIList=[Select Id,Name,ERP7__Product__c,ERP7__Quantity__c from ERP7__Stock_Outward_Line_Item__c where ERP7__Product__c IN:comW.Products AND ERP7__Status__c='Requested' AND ERP7__Order__c !=null AND ERP7__Order_Product__c != null AND ERP7__Active__c=true];
                    
                    set<Id> siteId = new set<Id>();
                    List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c,ERP7__Channel__r.Id,ERP7__Channel__r.Name from ERP7__Employees__c
                                                        where ERP7__Employee_User__c=:UserInfo.getUserId() AND ERP7__Active__c = true limit 1];
                    if(empList.size()>0 && empList != null){
                        List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                                      where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC ];
                        for(ERP7__Distribution_Channel__c dc : dcList) siteId.add(dc.ERP7__Site__c);
                    }
                  //  List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                   // WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c, Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c, Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__No_of_Items_Requested__c,ERP7__Number_of_Items_Awaiting_in_Stock__c From Inventory_Stock__c Where product__c In:comW.Products  And Active__c = true And Warehouse__c IN: siteId And (Number_of_Item_In_Stock__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0)];
                    List<productStock> allStock  = new  List<productStock>();
                     Map<Id, AggregateResult> productStockMap = new Map<Id, AggregateResult>();
                
                // Perform the aggregate query once and store the results in the map
                    for (AggregateResult result : [
                        SELECT ERP7__Product__c, 
                        SUM(ERP7__Number_of_Item_In_Stock__c) totalStock, 
                        SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) totalAwaiting, 
                        SUM(ERP7__No_of_Items_Requested__c) totalRequested  
                        FROM ERP7__Inventory_Stock__c 
                        WHERE ERP7__Active__c = true 
                        AND ERP7__Warehouse__c IN :siteId 
                        And ERP7__Product__c IN : comW.Products
                        AND (ERP7__Number_of_Item_In_Stock__c > 0 
                             OR ERP7__Number_of_Items_Awaiting_in_Stock__c > 0 
                             OR ERP7__No_of_Items_Requested__c > 0)
                        GROUP BY ERP7__Product__c
                    ]) {
                        productStockMap.put((Id)result.get('ERP7__Product__c'), result);
                    }
                    
                    // Iterate over the products and fetch stock data from the map
                    for (Product2 prod : comW.Products) {
                        Decimal myStock = 0.0;
                        Decimal demands = 0.0;
                        Decimal Awaitingstocks = 0.0;
                        
                        // Check if the product exists in the aggregate result map
                        if (productStockMap.containsKey(prod.Id)) {
                            AggregateResult result = productStockMap.get(prod.Id);
                            myStock = (Decimal) (result.get('totalStock') != null ? result.get('totalStock') : 0);
                            Awaitingstocks = (Decimal) (result.get('totalAwaiting') != null ? result.get('totalAwaiting') : 0);
                            demands = (Decimal) (result.get('totalRequested') != null ? result.get('totalRequested') : 0);
                        }
                        
                        // Create a productStock object and add it to the list
                        productStock pro = new productStock();
                        pro.Product = prod;
                        pro.stock = myStock;
                        pro.demand = demands;
                        pro.AwaitingStock = Awaitingstocks;
                        allStock.add(pro);
                    }
                    
                    /* for(Product2 prod : comW.Products){ 
Decimal myStock = 0.0; 
Decimal demands=0.0; 
Decimal Awaitingstocks = 0.0; 
for(AggregateResult result: [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock,SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c)totalAwaiting,SUM(ERP7__No_of_Items_Requested__c) totalRequested  FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c IN: siteId And (ERP7__Number_of_Item_In_Stock__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0) GROUP BY ERP7__Product__c]) { 
if(prod.Id == (Id)result.get('ERP7__Product__c')) {
myStock +=(Decimal)result.get('totalStock'); 
Awaitingstocks += (Decimal)result.get('totalAwaiting'); 
demands += (Decimal)result.get('totalRequested'); 
}
} productStock pro =new productStock(); pro.Product = prod; pro.stock = myStock; pro.demand = demands; pro.AwaitingStock = Awaitingstocks; allStock.add(pro); }*/
                    comW.prodStocks = allStock;
                }
                if(comW.Products.size() == 0){
                    comW.errorMsg = System.Label.Products_unavailable;
                    
                }
                
                
            }
            else if(Type == 'Sales Order'){
                
                if(StandOrder){
                    try{
                        String pFields = UtilClass.selectStarFromSObject('OrderItem');
                        utilClass.FLSCheck(pFields.split(','),'OrderItem'); 
                        pFields += ', Product2.Name, Product2.ERP7__Picture__c, Product2.ProductCode,Order.ERP7__Expected_Date__c, Order.Name '; 
                        String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from OrderItem where Quantity > 0 And Order.ERP7__Is_Closed__c = false ';
                        query1 += ' And (ERP7__MO_Remaining_Quantity__c > 0)';
                        query1 += ' And (ERP7__Issue_Manufacturing_Order__c = true) ';
                        query1 += ' And Order.Name like : searchStr ';
                        query1 += ' Order by Order.CreatedDate Desc limit 20'; //Order.ERP7__Expected_Date__c
                        List<OrderItem> Solis = Database.query(query1); 
                        system.debug('Solis : '+Solis.size());
                        
                        /*query1 += ' And (Product2.Name like : searchStr ';
                        query1 += ' Or Product2.ProductCode like : searchStr ';
                        query1 += ' Or Product2.ERP7__Barcode__c like : searchStr ';
                        query1 += ' Or Product2.StockKeepingUnit like : searchStr ';
                        query1 += ' Or Product2.ERP7__SKU__c like : searchStr ';
                        query1 += ' Or Product2.ERP7__ASIN_Code__c like : searchStr )';
                        if(Flow == 'MO') query1 += ' And (Product2.ERP7__Issue_Manufacturing_Order__c = true) ';
                        if(Flow == 'WO') query1 += ' And (Product2.ERP7__Issue_Work_Order__c = true) ';*/
                        
                        if(Solis.size() > 0){ comW.StandOrder = StandOrder; comW.OrderItems = Solis; comW.SelectedOrderItems = comW.OrderItems[0]; comW.Types.add(new SelectOptions('Sales Order', 'Sales Order')); comW.Type = 'Sales Order'; } else if(Solis.size() == 0){ comW.errorMsg = System.Label.Order_does_not_Exist; }
                    }
                    catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
                }
                else{
                    
                    String pFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order_Line_Item__c');
                    utilClass.FLSCheck(pFields.split(','),'ERP7__Sales_Order_Line_Item__c'); 
                    pFields += ', ERP7__Product__r.Name, ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Picture__c, ERP7__Sales_Order__r.Name '; 
                    String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Sales_Order_Line_Item__c where ERP7__Quantity__c > 0 And ERP7__Sales_Order__r.ERP7__Is_Closed__c = false ';
                    query1 += ' And (ERP7__MO_Remaining_Quantity__c > 0 Or ERP7__WO_Remaining_Quantity__c > 0) ';
                    /*query1 += ' And (ERP7__Product__r.Name like : searchStr ';
                    query1 += ' Or ERP7__Product__r.ProductCode like : searchStr ';
                    query1 += ' Or ERP7__Product__r.ERP7__Barcode__c like : searchStr ';
                    query1 += ' Or ERP7__Product__r.StockKeepingUnit like : searchStr ';
                    query1 += ' Or ERP7__Product__r.ERP7__SKU__c like : searchStr ';
                    query1 += ' Or ERP7__Product__r.ERP7__ASIN_Code__c like : searchStr ';*///commented by Asra and added And below 
                    query1 += ' And ( Name like : searchStr ';
                    query1 += ' Or ERP7__Sales_Order__r.Name like : searchStr )';
                    if(Flow == 'MO') query1 += ' And (ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c = true) ';
                    if(Flow == 'WO') query1 += ' And (ERP7__Product__r.ERP7__Issue_Work_Order__c = true) ';
                    query1 += ' Order by Name Asc limit 20';
                    comW.Solis = Database.query(query1);
                    if(comW.Solis.size() == 0){
                        comW.errorMsg = System.Label.Products_unavailable;
                    }
                }     
            }
            else if(Type == 'Manufacturing Order'){
                DateTime NOW = system.Now();
                String pFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__Manufacturing_Order__c'); 
                pFields += ', ERP7__Product__r.Name,ERP7__Product__r.ProductCode, ERP7__Product__r.ERP7__Picture__c '; 
                String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Manufacturing_Order__c where ERP7__Quantity__c > 0 And ERP7__Is_Closed__c = false And ERP7__Version__c != Null And ERP7__Status__c != \'Complete\' And ERP7__Routing__c != Null And ERP7__Product__c != Null And ERP7__StartDate__c > :NOW '; // 
                query1 += ' And (ERP7__Product__r.Name like : searchStr ';
                query1 += ' Or ERP7__Product__r.ProductCode like : searchStr ';
                query1 += ' Or ERP7__Product__r.ERP7__Barcode__c like : searchStr ';
                query1 += ' Or ERP7__Product__r.StockKeepingUnit like : searchStr ';
                query1 += ' Or ERP7__Product__r.ERP7__SKU__c like : searchStr ';
                query1 += ' Or ERP7__Product__r.ERP7__ASIN_Code__c like : searchStr ';
                query1 += ' Or Name like : searchStr )';
                if(Flow == 'MO') query1 += ' And (ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c = true) ';
                if(Flow == 'WO') query1 += ' And (ERP7__Product__r.ERP7__Issue_Work_Order__c = true) ';
                query1 += ' Order by Name Asc limit 20';
                comW.MOS = Database.query(query1);
                if(comW.MOS.size() == 0){
                    comW.errorMsg = System.Label.Manufacturing_Orders_unavailable;
                }
            }
            else if(Type == 'Work Order'){
                DateTime NOW = system.Now();
                String pFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__WO__c'); 
                pFields += ', ERP7__Product__r.Name, ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Picture__c '; 
                String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__WO__c where ERP7__Quantity_Ordered__c > 0 And ERP7__Is_Closed__c = false And ERP7__Version__c != Null And ERP7__Routing__c != Null And ERP7__Product__c != Null  And ERP7__Routing__r.ERP7__Process__r.RecordType.Name = \'Maintenance Process\' And ERP7__Start_Date__c > :NOW '; // ERP7__Start_Date__c > :NOW And 
                query1 += ' And (ERP7__Product__r.Name like : searchStr ';
                query1 += ' Or ERP7__Product__r.ProductCode like : searchStr ';
                query1 += ' Or ERP7__Product__r.ERP7__Barcode__c like : searchStr ';
                query1 += ' Or ERP7__Product__r.StockKeepingUnit like : searchStr ';
                query1 += ' Or ERP7__Product__r.ERP7__SKU__c like : searchStr ';
                query1 += ' Or ERP7__Product__r.ERP7__ASIN_Code__c like : searchStr ';
                query1 += ' Or Name like : searchStr )';
                if(Flow == 'MO') query1 += ' And (ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c = true) ';
                if(Flow == 'WO') query1 += ' And (ERP7__Product__r.ERP7__Issue_Work_Order__c = true) ';
                query1 += ' Order by Name Asc limit 20';
                comW.WOS = Database.query(query1);
                if(comW.WOS.size() == 0){
                    comW.errorMsg = System.Label.Work_Orders_unavailable;
                }
            }
            
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled 
    public static comWrap ScheduledWOTime(String selDate, Integer st, Integer et) { 
        Date selectedDate = Date.Valueof(selDate);
        comWrap comW = new comWrap();
        comW.selDate = selectedDate;
        try{   
            if(selectedDate != null && st != null && et != null){  
                comW.WO.ERP7__Start_Date__c = Datetime.newInstance(selectedDate,Time.newInstance(st, 0, 0, 0));
                comW.WO.ERP7__End_Date__c = Datetime.newInstance(selectedDate,Time.newInstance(et, 0, 0, 0));
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static string updateWOs(String WOS){
        if(WOS != null && WOS != ''){
            List<ERP7__WO__c> myWOS = (List<ERP7__WO__c>) JSON.deserialize(WOS, List<ERP7__WO__c> .class); 
            update myWOS;
            return 'Success';
        }
        else return null;
       
    }
    @AuraEnabled
    public static comWrap SaveM(String MO, String WOS){//, String Tms
        Savepoint sp = Database.setSavepoint();
        Boolean createMultipleMOforSerialProd = false;
        
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(userInfo.getUserId());
        if(customList == null){ 
            customList = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
        }
        if(customList != null){
            createMultipleMOforSerialProd = customList.ERP7__Create_MO_for_each_QTY_serial_product__c;
        }
        system.debug('createMultipleMOforSerialProd : '+createMultipleMOforSerialProd);
        
        
        ERP7__Manufacturing_Order__c MOs = (ERP7__Manufacturing_Order__c) JSON.deserialize(MO, ERP7__Manufacturing_Order__c .class);
        Id ProductID;
        Boolean serialProd = false;
        Boolean isKitProd = false;
        if(MOs != null ){
            if(MOs.ERP7__Product__c != Null) ProductID = MOs.ERP7__Product__c;
            if(ProductID != null){
                List<Product2> prod = [Select Id,Name,ERP7__Serialise__c,ERP7__Is_Kit__c from Product2 where Id=:ProductID limit 1]; if(prod.size() > 0) { serialProd = prod[0].ERP7__Serialise__c; isKitProd = prod[0].ERP7__Is_Kit__c; } 
            }
        }
        system.debug('serialProd : '+serialProd);
        if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Owner__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Owner__c.isUpdateable()){MOs.ERP7__Owner__c=UserInfo.getUserId();}else{/*No access*/}
        List<ERP7__WO__c> myWOS = (List<ERP7__WO__c>) JSON.deserialize(WOS, List<ERP7__WO__c> .class);
        //List<newTimesWrap> myWOTimes = (List<newTimesWrap>) JSON.deserialize(Tms, List<newTimesWrap>.class);
        if(MOs.ERP7__Order_Product__c != null){ if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Order__c.isUpdateable() && MOs.ERP7__Order__c == null){MOs.ERP7__Order__c = [SELECT OrderId FROM OrderItem WHERE Id =: MOs.ERP7__Order_Product__c].OrderId;}else{/*No access*/} OrderItem OrdlinetoUpdate = [SELECT Id,ERP7__Issue_Manufacturing_Order__c,ERP7__MO_Quantity__c FROM OrderItem WHERE Id =: MOs.ERP7__Order_Product__c]; Decimal existingMOQuantity = 0; if(OrdlinetoUpdate != null){ existingMOQuantity = OrdlinetoUpdate.ERP7__MO_Quantity__c;  if(Schema.sObjectType.OrderItem.fields.ERP7__Issue_Manufacturing_Order__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Issue_Manufacturing_Order__c.isUpdateable() && OrdlinetoUpdate.ERP7__Issue_Manufacturing_Order__c == false){OrdlinetoUpdate.ERP7__Issue_Manufacturing_Order__c = true;}else{/*No access*/} OrdlinetoUpdate.ERP7__MO_Quantity__c = existingMOQuantity + MOs.ERP7__Quantity__c; if(Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()){update OrdlinetoUpdate;}else{/*'Not allowed to update OrderItem'*/} } }
        
        comWrap comW = new comWrap();
        try{
            if(serialProd && createMultipleMOforSerialProd && MOs.ERP7__Quantity__c > 1){
                List<ERP7__Manufacturing_Order__c> MOs2Insert = new List<ERP7__Manufacturing_Order__c>();
                set<ERP7__WO__c> WOs2upsert = new set<ERP7__WO__c>();
                set<Id> MOIDs = new set<Id>();
                if(MOs.ERP7__ExpectedDate__c == Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__ExpectedDate__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__ExpectedDate__c.isUpdateable()){ MOs.ERP7__ExpectedDate__c = MOs.ERP7__End_Date__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Escape_Process__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Escape_Process__c.isUpdateable()){MOs.ERP7__Escape_Process__c = true;}else{/*No access*/}
                
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.isUpdateable()){ 
                    Integer i = Integer.valueOf(MOs.ERP7__Quantity__c);
                    system.debug('i : '+i);
                    for(Integer j=0;j<i;j++){
                        ERP7__Manufacturing_Order__c newMO = new ERP7__Manufacturing_Order__c();
                        newMO.ERP7__Product__c = MOs.ERP7__Product__c;
                        newMO.ERP7__Quantity__c = 1;
                        newMO.ERP7__Version__c = MOs.ERP7__Version__c;
                        newMO.ERP7__Owner__c = MOs.ERP7__Owner__c;
                        newMO.ERP7__StartDate__c = MOs.ERP7__StartDate__c;
                        newMO.ERP7__End_Date__c = MOs.ERP7__End_Date__c;
                        if(MOs.ERP7__Status__c != null && MOs.ERP7__Status__c != '') newMO.ERP7__Status__c = MOs.ERP7__Status__c;
                        else newMO.ERP7__Status__c = 'Draft';
                        newMO.ERP7__Routing__c = MOs.ERP7__Routing__c;
                        newMO.ERP7__Escape_Process__c = true;
                        newMO.ERP7__Initiate_MO__c = true;
                        newMO.ERP7__ExpectedDate__c = MOs.ERP7__ExpectedDate__c; 
                        newMO.ERP7__Order__c = MOs.ERP7__Order__c; 
                        newMO.ERP7__Order_Product__c = MOs.ERP7__Order_Product__c; 
                        newMO.ERP7__Sales_Order__c = MOs.ERP7__Sales_Order__c; 
                        newMO.ERP7__Sales_Order_Line_Item__c = MOs.ERP7__Sales_Order_Line_Item__c; 
                        MOs2Insert.add(newMO);
                    }
                    system.debug('MOs2Insert : '+MOs2Insert.size());
                    PreventRecursiveLedgerEntry.testCasesTransactions = false;
                    if(MOs2Insert.size() > 0) upsert MOs2Insert;
                    for(ERP7__Manufacturing_Order__c MO1 : MOs2Insert){
                        MOIDs.add(MO1.Id);
                        integer k = 1;
                        if(myWOS.size() > 0){
                            for(ERP7__WO__c WO : myWOS){
                                ERP7__WO__c NewWO = new ERP7__WO__c();
                                NewWO.ERP7__Quantity_Ordered__c = 1;
                                NewWO.ERP7__MO__c = MO1.Id; 
                                NewWO.ERP7__Progress__c = WO.ERP7__Progress__c;
                                NewWO.ERP7__Planned_Date__c = WO.ERP7__Planned_Date__c;
                                NewWO.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
                                NewWO.ERP7__Status__c = WO.ERP7__Status__c;
                                NewWO.ERP7__Site__c = WO.ERP7__Site__c;
                                NewWO.ERP7__Type__c = WO.ERP7__Type__c;
                                NewWO.ERP7__Work_Center__c = WO.ERP7__Work_Center__c;
                                if(MO1.ERP7__Product__c != Null) NewWO.ERP7__Product__c = MO1.ERP7__Product__c;
                                if(MO1.ERP7__Version__c != Null) NewWO.ERP7__Version__c = MO1.ERP7__Version__c;
                                if(MO1.ERP7__Routing__c != Null) NewWO.ERP7__Routing__c = MO1.ERP7__Routing__c;
                                if(MO1.ERP7__Sales_Order__c != Null) NewWO.ERP7__Sales_Order__c = MO1.ERP7__Sales_Order__c;
                                if(MO1.ERP7__Sales_Order_Line_Item__c != Null) NewWO.ERP7__Sales_Order_Line_Item__c = MO1.ERP7__Sales_Order_Line_Item__c;
                                if(WO.ERP7__End_Date__c != Null) { NewWO.ERP7__ExpectedDate__c = WO.ERP7__End_Date__c; MO1.ERP7__ExpectedDate__c = WO.ERP7__End_Date__c;}
                                system.debug('WO.ERP7__Start_Date__c : '+WO.ERP7__Start_Date__c);
                                system.debug('WO.ERP7__End_Date__c : '+WO.ERP7__End_Date__c);
                                NewWO.ERP7__Start_Date__c = WO.ERP7__Start_Date__c;
                                NewWO.ERP7__End_Date__c = WO.ERP7__End_Date__c;
                                if(WO.ERP7__Start_Date__c != Null && (MO1.ERP7__StartDate__c == Null || MO1.ERP7__StartDate__c > WO.ERP7__Start_Date__c)) if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__StartDate__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__StartDate__c.isUpdateable()){MO1.ERP7__StartDate__c = WO.ERP7__Start_Date__c;  }else{/*No access*/}
                                if(WO.ERP7__End_Date__c != Null && (MO1.ERP7__End_Date__c == Null || MO1.ERP7__End_Date__c < WO.ERP7__End_Date__c)) if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__End_Date__c.isUpdateable()){MO1.ERP7__End_Date__c = WO.ERP7__End_Date__c;  }else{/*No access*/}
                                system.debug('NewWO.ERP7__Start_Date__c : '+NewWO.ERP7__Start_Date__c);
                                system.debug('NewWO.ERP7__End_Date__c : '+NewWO.ERP7__End_Date__c);
                                NewWO.Name = WO.Name +'-' +k;
                                system.debug(' WO.ERP7__MO__c  : '+ NewWO.ERP7__MO__c);
                                system.debug(' WO.Name  : '+ NewWO.Name);
                                WOs2upsert.add(NewWO);
                                k++;
                            } 
                        }
                    }
                }else{comW.errorMsg =System.Label.Not_allowed_to_upsert_MO;}
                
                system.debug('MOIDs : '+MOIDs);
                system.debug('WOs2upsert : '+WOs2upsert.size());
                List<ERP7__WO__c> WOS2return = new List<ERP7__WO__c>();
                if(WOs2upsert.size() > 0) {
                    upsert MOs2Insert;
                    
                    List < ERP7__Work_Order_Line_Items__c > WOLines2Create = new List < ERP7__Work_Order_Line_Items__c > (); List<ERP7__WO__c> WOs2upsertlst=new List<ERP7__WO__c>(); PreventRecursiveLedgerEntry.testCasesTransactions = false; 
                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Routing__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Version__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isUpdateable()){
                        WOs2upsertlst.addAll(WOs2upsert); system.debug('WOs2upsertlst : '+WOs2upsertlst.size()); upsert WOs2upsertlst; 
                    }else{comW.errorMsg =System.Label.Not_allowed_to_upsert_Work_Order;}
                    for(ERP7__WO__c WO : WOs2upsertlst){ 
                        ERP7__Work_Order_Line_Items__c WOLine2Create = new ERP7__Work_Order_Line_Items__c(); 
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Name.isUpdateable()){WOLine2Create.Name = WO.Name;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Active__c.isUpdateable()){WOLine2Create.ERP7__Active__c = true;}else{/*No access*/} 
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Version__c.isUpdateable()){WOLine2Create.ERP7__Version__c = WO.ERP7__Version__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Work_Orders__c.isCreateable()){WOLine2Create.ERP7__Work_Orders__c = WO.Id;}else{/*No access*/} 
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Product__c.isUpdateable()){WOLine2Create.ERP7__Product__c = WO.ERP7__Product__c;}else{/*No access*/} 
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Quantity__c.isUpdateable()){WOLine2Create.ERP7__Quantity__c = WO.ERP7__Quantity_Ordered__c;}else{/*No access*/} 
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Sales_Order__c.isUpdateable()){WOLine2Create.ERP7__Sales_Order__c = WO.ERP7__Sales_Order__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Manufacturing_Order__c.isUpdateable()){WOLine2Create.Manufacturing_Order__c = WO.ERP7__MO__c;}else{/*No access*/} if(isKitProd && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Explode__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Explode__c.isUpdateable()){ WOLine2Create.ERP7__Explode__c = true;}else{/*No access*/}
                        WOLines2Create.add(WOLine2Create); 
                      if(MOs2Insert.size() > 0 && MOs2Insert[0].Id == WO.ERP7__MO__c) WOS2return.add(WO);
                    } system.debug('WOLines2Create : '+WOLines2Create.size());
                    if (WOLines2Create.size() > 0 && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isUpdateable()){upsert WOLines2Create;}else{comW.errorMsg =System.Label.Not_allowed_to_upsert_WO_Line_Item;} 
                }
                system.debug('WOS2return : '+WOS2return.size());
                if(WOS2return.size() > 0) comW.WOS = WOS2return;
                system.debug('MOs2Insert : '+MOs2Insert.size());
                if(MOs2Insert.size() > 0) comW.MO = MOs2Insert[0];
                
            }
            else{
                system.debug('inside else');
                if(myWOS.size() > 0){
                    for(ERP7__WO__c WO : myWOS){
                        WO.ERP7__Quantity_Ordered__c = MOs.ERP7__Quantity__c;
                        if(MOs.ERP7__Product__c != Null) WO.ERP7__Product__c = MOs.ERP7__Product__c;
                        if(MOs.ERP7__Version__c != Null) WO.ERP7__Version__c = MOs.ERP7__Version__c;
                        if(MOs.ERP7__Routing__c != Null) WO.ERP7__Routing__c = MOs.ERP7__Routing__c;
                        if(MOs.ERP7__Sales_Order__c != Null) WO.ERP7__Sales_Order__c = MOs.ERP7__Sales_Order__c;
                        if(MOs.ERP7__Sales_Order_Line_Item__c != Null) WO.ERP7__Sales_Order_Line_Item__c = MOs.ERP7__Sales_Order_Line_Item__c;
                        if(WO.ERP7__ExpectedDate__c == Null) WO.ERP7__ExpectedDate__c = WO.ERP7__End_Date__c;
                        if(WO.ERP7__Start_Date__c != Null && (MOs.ERP7__StartDate__c == Null || MOs.ERP7__StartDate__c > WO.ERP7__Start_Date__c)) if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__StartDate__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__StartDate__c.isUpdateable()){MOs.ERP7__StartDate__c = WO.ERP7__Start_Date__c;}else{/*No access*/}
                        if(WO.ERP7__End_Date__c != Null && (MOs.ERP7__End_Date__c == Null || MOs.ERP7__End_Date__c < WO.ERP7__End_Date__c)) if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__End_Date__c.isUpdateable()){MOs.ERP7__End_Date__c = WO.ERP7__End_Date__c;}else{/*No access*/}
                    }
                } 
                if(MOs.ERP7__ExpectedDate__c == Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__ExpectedDate__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__ExpectedDate__c.isUpdateable()){ MOs.ERP7__ExpectedDate__c = MOs.ERP7__End_Date__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Escape_Process__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Escape_Process__c.isUpdateable()){MOs.ERP7__Escape_Process__c = true;}else{/*No access*/}
                 MOs.ERP7__Status__c = 'Draft'; // change SM 16.10.23
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.isUpdateable()){upsert MOs;}else{comW.errorMsg =System.Label.Not_allowed_to_upsert_MO;}
                
                if(myWOS.size() > 0) {
                    ERP7__Manufacturing_Order__c newMO = [Select Id, Name, ERP7__Product__c, ERP7__Product__r.ERP7__Is_Kit__c From ERP7__Manufacturing_Order__c Where Id = :MOs.Id];
                    list < ERP7__Work_Order_Line_Items__c > WOLines2Create = new list < ERP7__Work_Order_Line_Items__c > ();
                    for(ERP7__WO__c WO : myWOS){ 
                        if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isUpdateable()){WO.ERP7__MO__c = MOs.Id; }else{/*No access*/}
                    }
                    PreventRecursiveLedgerEntry.testCasesTransactions = false;
                    
                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Routing__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Version__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isUpdateable()) {
                        PreventRecursiveLedgerEntry.PreventWOLogistic=false;PreventRecursiveLedgerEntry.preventWOExecution=false;   upsert myWOS; comW.WOS = myWOS;
                    }
                    else{comW.errorMsg =System.Label.Not_allowed_to_upsert_Work_Order;}
                    
                    for(ERP7__WO__c WO : myWOS){ 
                        ERP7__Work_Order_Line_Items__c WOLine2Create = new ERP7__Work_Order_Line_Items__c();
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Name.isUpdateable()){WOLine2Create.Name = WO.Name;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Active__c.isUpdateable()){WOLine2Create.ERP7__Active__c = true;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Version__c.isUpdateable()){WOLine2Create.ERP7__Version__c = WO.ERP7__Version__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Work_Orders__c.isCreateable()){WOLine2Create.ERP7__Work_Orders__c = WO.Id;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Product__c.isUpdateable()){WOLine2Create.ERP7__Product__c = WO.ERP7__Product__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Quantity__c.isUpdateable()){WOLine2Create.ERP7__Quantity__c = WO.ERP7__Quantity_Ordered__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Sales_Order__c.isUpdateable()){WOLine2Create.ERP7__Sales_Order__c = WO.ERP7__Sales_Order__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Manufacturing_Order__c.isUpdateable()){WOLine2Create.Manufacturing_Order__c = WO.ERP7__MO__c;}else{/*No access*/}
                        if(newMO.ERP7__Product__r.ERP7__Is_Kit__c && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Explode__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Explode__c.isUpdateable()){ WOLine2Create.ERP7__Explode__c = true;}else{/*No access*/}
                        WOLines2Create.add(WOLine2Create);
                    }
                    
                    if (WOLines2Create.size() > 0 && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isUpdateable()){upsert WOLines2Create;}else{comW.errorMsg =System.Label.Not_allowed_to_upsert_WO_Line_Item;}
                }
                comW.MO = MOs;  
            } 
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
        }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap UpdateM(String MO, String WOS){   
        ERP7__Manufacturing_Order__c MOs = (ERP7__Manufacturing_Order__c) JSON.deserialize(MO, ERP7__Manufacturing_Order__c .class);
        List<ERP7__WO__c> myWOS = (List<ERP7__WO__c>) JSON.deserialize(WOS, List<ERP7__WO__c> .class);
        comWrap comW = new comWrap();
        try{
            if(myWOS.size() > 0){
                for(ERP7__WO__c WO : myWOS){
                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isUpdateable()){WO.ERP7__Quantity_Ordered__c = MOs.ERP7__Quantity__c;}else{/*No access*/}
                    if(WO.ERP7__ExpectedDate__c == Null && Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isUpdateable()){ WO.ERP7__ExpectedDate__c = WO.ERP7__End_Date__c;}else{/*No access*/}
                    if(WO.ERP7__Start_Date__c != Null && (MOs.ERP7__StartDate__c == Null || MOs.ERP7__StartDate__c > WO.ERP7__Start_Date__c) && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__StartDate__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__StartDate__c.isUpdateable()){ MOs.ERP7__StartDate__c = WO.ERP7__Start_Date__c;}else{/*No access*/}
                    if(WO.ERP7__End_Date__c != Null && (MOs.ERP7__End_Date__c == Null || MOs.ERP7__End_Date__c < WO.ERP7__End_Date__c) && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__End_Date__c.isUpdateable()){ MOs.ERP7__End_Date__c = WO.ERP7__End_Date__c;}else{/*No access*/}
                }
            } 
            if(MOs.ERP7__ExpectedDate__c == Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__ExpectedDate__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__ExpectedDate__c.isUpdateable()){ MOs.ERP7__ExpectedDate__c = MOs.ERP7__End_Date__c;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Escape_Process__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Escape_Process__c.isUpdateable()){MOs.ERP7__Escape_Process__c = true;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Manufacturing_Order__c.isUpdateable()){upsert MOs;}else{comW.errorMsg =System.Label.Not_allowed_to_upsert_MO;}
            if(myWOS.size() > 0) {
                if(Schema.sObjectType.ERP7__WO__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.isUpdateable()){upsert myWOS;}else{comW.errorMsg =System.Label.Not_allowed_to_upsert_Work_Order;}
            }
            comW.MO = MOs; } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap SaveW(String WO){   
        ERP7__WO__c WOs = (ERP7__WO__c) JSON.deserialize(WO, ERP7__WO__c .class);
        comWrap comW = new comWrap();
        try{
            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isUpdateable()){WOs.ERP7__ExpectedDate__c = WOs.ERP7__End_Date__c;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__WO__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.isUpdateable()){upsert WOs;}else{comW.errorMsg =System.Label.Not_allowed_to_upsert_Work_Order;}
            comW.WO = WOs; } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    public Static List < TimeSlot > getAllTimeSlotList(DateTime startTime, DateTime EndTime, Integer slotDuration) { Integer TotalMinutes; if (startTime != null && endTime != null) TotalMinutes = (endTime.hour() - startTime.hour()) * 60 + (endTime.Minute() - startTime.Minute()); if (TotalMinutes != null) TotalMinutes = (TotalMinutes / slotDuration); List < TimeSlot > TimeSlotList = new List < TimeSlot > (); TimeSlot TS = new TimeSlot(); if (startTime > System.now()) { TS.slotST = startTime; DateTime myet = startTime.addminutes(slotDuration); TS.slotET = myet; TimeSlotList.add(TS); } Integer slotsMinutes = 0; if (endTime != null && endTime.minute() != null && endTime.minute() != 0 && slotDuration != 0) slotsMinutes = endTime.minute() / slotDuration; Integer count = 0; for (Integer i = 0; i < TotalMinutes - 1; i++) { startTime = startTime.addminutes(slotDuration); DateTime myet = startTime.addminutes(slotDuration); if (startTime.hour() <= endTime.hour()) { if (startTime.hour() < endTime.hour() && startTime >= System.now()) { TS = new TimeSlot(); TS.slotST = startTime; TS.IsAvailable = false; TS.slotET = myet; TimeSlotList.add(TS); } else { if (endTime.minute() >= slotDuration && startTime >= System.now()) { TS = new TimeSlot(); TS.slotST = startTime; TS.IsAvailable = false; TS.slotET = myet; TimeSlotList.add(TS); count = count + 1; if (count > slotsMinutes) break; } } } } return TimeSlotList; }
    
    public class comWrap {
        @AuraEnabled public ERP7__Manufacturing_Order__c MO                         { get ; set; }
        @AuraEnabled public List<ERP7__Manufacturing_Order__c> MOS                  { get ; set; }
        @AuraEnabled public ERP7__WO__c WO                                          { get ; set; }
        @AuraEnabled public List<ERP7__WO__c> WOS                                   { get ; set; }
        @AuraEnabled public List<ERP7__Work_Center__c> WCS                          { get ; set; }
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public List<Id> VersionIds                                     { get ; set; }
        @AuraEnabled public Date selDate                                            { get ; set; }  
        @AuraEnabled public Boolean NextDisabled                                    { get ; set; }  
        @AuraEnabled public Boolean PrevDisabled                                    { get ; set; }  @AuraEnabled public Date WCendDate                                          { get ; set; }
        @AuraEnabled public List<SelectOptions> Routings                            { get ; set; } 
        @AuraEnabled public List<SelectOptions> Versions                            { get ; set; } 
        @AuraEnabled public List<SelectOptions> CapacityList                        { get ; set; }  
        @AuraEnabled public ERP7__Routing__c SelectedRouting                        { get ; set; }
        @AuraEnabled public List<Product2> Products                               { get ; set; }
        @AuraEnabled public Product2 SelectedProduct                                { get ; set; }
        @AuraEnabled public List< ERP7__Sales_Order_Line_Item__c > Solis            { get ; set; }
        @AuraEnabled public ERP7__Sales_Order_Line_Item__c SelectedSoli             { get ; set; }  
        @AuraEnabled public ERP7__Version__c SelectedVersion                        { get ; set; }  
        @AuraEnabled public List<TimeSlot> SliderTimeSlots                          { get ; set; }  
        @AuraEnabled public List<WorkCenterWrapper> WorkCenterList                  { get ; set; }  
        @AuraEnabled public String criteriaMsg                                      { get ; set; } 
        @AuraEnabled public String Type                                             { get ; set; }
        @AuraEnabled public List<SelectOptions> Types                               { get ; set; }
        
        @AuraEnabled Public Integer qtyMultiplier                                   { get ; set; }
        @AuraEnabled Public List<Time> BookedTimes                                  { get ; set; } @AuraEnabled Public Integer SliderStartTime                                 { get ; set; } @AuraEnabled Public Integer SliderEndTime                                   { get ; set; } @AuraEnabled Public Integer SliderLandingStartTime                          { get ; set; } @AuraEnabled Public Integer SliderLandingEndTime                            { get ; set; } @AuraEnabled Public Integer selecteQty                                      { get ; set; } @AuraEnabled Public Long SliderStartTimes                                 { get ; set; } @AuraEnabled Public Long SliderEndTimes                                   { get ; set; } @AuraEnabled Public Long SliderLandingStartTimes                          { get ; set; } @AuraEnabled Public Long SliderLandingEndTimes                            { get ; set; }      
        
        @AuraEnabled public Boolean showPlanner                                        { get; set; }
        @AuraEnabled public Boolean showSheduler                                      { get; set; }
        @AuraEnabled public Boolean showBuilder                                        { get; set; }
        @AuraEnabled public Boolean showVerbasedOnOrder                               { get; set; }
        @AuraEnabled public List<productStock> prodStocks                             { get; set; }
        @AuraEnabled public Boolean StandOrder                                        { get; set; }
        @AuraEnabled public Boolean  showDateEdiatable                                { get; set; }
        @AuraEnabled public List< OrderItem > OrderItems                              { get; set; }
        @AuraEnabled public OrderItem SelectedOrderItems                              { get; set; }
        public comWrap() {
            showDateEdiatable = false;
            prodStocks = new List<productStock>();
            MO = new ERP7__Manufacturing_Order__c();
            MOS = new List<ERP7__Manufacturing_Order__c>();
            WO = new ERP7__WO__c();
            WOS = new List<ERP7__WO__c>();
            WCS = new List<ERP7__Work_Center__c>();
            errorMsg = ''; 
            StandOrder = false;
            selDate = system.today();
            NextDisabled = PrevDisabled = true;
            Routings = new List<SelectOptions>();
            Versions = new List<SelectOptions>();
            CapacityList = new List<SelectOptions>{ new SelectOptions('', 'All') };
                SelectedRouting = new ERP7__Routing__c();
            SelectedVersion = new ERP7__Version__c(); 
            Products = new List< Product2 >();
            SelectedProduct = new Product2();
            Solis = new List< ERP7__Sales_Order_Line_Item__c >();
            SelectedSoli = new ERP7__Sales_Order_Line_Item__c();
            OrderItems = new List< OrderItem >();
            SelectedOrderItems = new OrderItem();
            SliderTimeSlots = new List<TimeSlot>();  
            WorkCenterList = new List<WorkCenterWrapper>();  
            criteriaMsg = ''; 
            Type = '';
            Types = new List<SelectOptions>();
            qtyMultiplier = 1;
            selecteQty=0;
            VersionIds = new List<Id>();
            BookedTimes = new List<Time>();     
            //SliderStartTime = 10;  
            //SliderEndTime = 22; 
            //SliderLandingStartTime = 10; 
            //SliderLandingEndTime = 11;        
            showPlanner=true;
            showSheduler=true;
            showBuilder=true;  
            showVerbasedOnOrder = false;            
        }
    }  
    
    public class TimeSlot{ @AuraEnabled public DateTime slotST                                { get ; set; } @AuraEnabled public DateTime slotET                                { get ; set; } @AuraEnabled public Boolean IsAvailable                            { get ; set; } @AuraEnabled public String WorkCenterId                            { get ; set; } @AuraEnabled public String RegId                                   { get ; set; } @AuraEnabled public String Status                                  { get ; set; } @AuraEnabled public String Notification                            { get ; set; } @AuraEnabled public Date selDate                                   { get ; set; } public TimeSlot(){ slotST = slotET = selDate = Null; WorkCenterId = RegId = Null; IsAvailable = false; Status = 'NA'; Notification = 'Not Available'; } } 
    
    public class WorkCenterWrapper{ @AuraEnabled public List<TimeSlot> WorkCenterSlots                 { get ; set; } @AuraEnabled public Integer Capacity                               { get ; set; } @AuraEnabled public ERP7__Work_Center__c WorkCenter                { get ; set; } public WorkCenterWrapper(){ WorkCenterSlots = new List<TimeSlot>(); Capacity = 0; WorkCenter = new ERP7__Work_Center__c(); } }
    
    public class SelectOptions {
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public String label     { get; set; }
        
        public SelectOptions(String val, string lab) {
            value = val;
            label = lab;
        }
    }
    
    public class newTimesWrap{
        @AuraEnabled public String id       { get; set; }
        @AuraEnabled public String stDate   { get; set; }
        @AuraEnabled public String enDate   { get; set; }
        
        public newTimesWrap(){
            id = '';
            stDate = '';
            enDate = '';
        }
    }
    public class productStock{
        @AuraEnabled public Product2 Product       { get; set; }
        @AuraEnabled public Decimal stock   { get; set; }
        @AuraEnabled public Decimal demand   { get; set; }
        @AuraEnabled public Decimal AwaitingStock   { get; set; }
        
        public productStock(){
            Product = new Product2();
            stock = 0.0; demand = 0.0; AwaitingStock = 0.0;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues() {
        List<String> picklistValues = new List<String>();
        // Describe the object and field
        Schema.DescribeFieldResult fieldResult = ERP7__Routing__c.ERP7__Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        System.debug('Retrieved picklist entries: ' + picklistEntries);
        // Extract picklist values
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                picklistValues.add(entry.getLabel());
            }
        }
        return picklistValues;
    }


}