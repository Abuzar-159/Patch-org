public with sharing class MultipleManufacturingOrder {
    
    @AuraEnabled
    public static wrapper fetchChannelAndDist(){
        wrapper wr=new wrapper();
        try{
            ERP7__Employees__c currentEmployee =new ERP7__Employees__c();
            for(ERP7__Employees__c rec:[Select Id, Name, First_Name__c, Channel__c, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,Organisation_Business_Unit__c From ERP7__Employees__c Where Employee_User__c = : UserInfo.getUserId() Order by CreatedDate Asc Limit 1])
                currentEmployee=rec;
            if(currentEmployee != null) wr.currentEmployee=currentEmployee; else wr.errorMsg='Employee Not Found';
            
            ERP7__Channel__c currentSalepoint = new ERP7__Channel__c();
            for(ERP7__Channel__c rec:[Select Id, Name, Organisation__c, Organisation_Business_Unit__c From ERP7__Channel__c where Id = : wr.currentEmployee.Channel__c Limit 1])
                currentSalepoint=rec;
            if(currentSalepoint != null) wr.currentSalepoint=currentSalepoint; else wr.errorMsg='Channel Not Found on Employee Record';
            
            
            wr.DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                     From Distribution_Channel__c
                                     Where 
                                     Channel__c = : wr.currentSalepoint.Id And Active__c = true order by ERP7__Priority__c ASC];
        }catch(Exception e){wr.errorMsg=e.getMessage()+'    Line:'+e.getLineNumber();}
        return wr;
    }
    
    @AuraEnabled
    public static wrapper fetchProducts(String searchText,Integer show,Integer Offset,String dChannelId){
        wrapper wr=new wrapper();
        try{
            if(Schema.sobjectType.ERP7__Manufacturing_Order__c.Fields.ERP7__Sales_Order__c.isAccessible()) wr.SOAccess=true;            else if(Schema.sobjectType.ERP7__Manufacturing_Order__c.Fields.ERP7__Order__c.isAccessible()) wr.SOAccess=false;
            List<Product2> proList=new List<Product2>();
            List<Product2> Recs = new List<Product2>(); 
            String searchText1 = '%'+searchText+'%';
            proList=Database.query('Select Id,Name,QuantityUnitOfMeasure,Track_Inventory__c,ERP7__MOQ__c from Product2 where Name like: searchText1 AND IsActive=true AND ERP7__Track_Inventory__c=true AND ERP7__Issue_Manufacturing_Order__c=true Order By createdDate Desc Limit 10000');
            
            wr.recSize = proList.size();
            wr.PNS = new List<Integer>();
            wr.show = Show;
            wr.Offset = Offset;
            Integer ES = wr.recSize;
            Integer j=0;
            while(ES >= wr.show){ j++; wr.PNS.add(j); ES=ES-wr.show;} 
            if(ES > 0) wr.PNS.add(j+1);
            
            for(Integer i = 0; i < proList.size(); i++){
                if(i >= wr.Offset+wr.show) break;
                if(i >= wr.Offset) Recs.add(proList[i]);
            }
            proList = Recs;
            wr.prodList=proList;
            if(proList.size() > 0 && wr.Offset != 0){ wr.startCount = wr.Offset + 1; wr.endCount = wr.Offset + proList.size(); wr.PageNum = (wr.Offset+wr.show)/wr.show;}
            else if(proList.size() > 0 && wr.Offset == 0){
                wr.startCount = 1;
                wr.endCount = proList.size();
                wr.PageNum = 1;
            }  
            
            /*ERP7__Employees__c currentEmployee =new ERP7__Employees__c();
            for(ERP7__Employees__c rec:[Select Id, Name, First_Name__c, Channel__c, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,Organisation_Business_Unit__c From ERP7__Employees__c Where Employee_User__c = : UserInfo.getUserId() Order by CreatedDate Asc Limit 1])
                currentEmployee=rec;
            if(currentEmployee != null) wr.currentEmployee=currentEmployee; else wr.errorMsg='Employee Not Found';
            
            ERP7__Channel__c currentSalepoint = new ERP7__Channel__c();
            for(ERP7__Channel__c rec:[Select Id, Name, Organisation__c, Organisation_Business_Unit__c From ERP7__Channel__c where Id = : wr.currentEmployee.Channel__c Limit 1])
                currentSalepoint=rec;
            if(currentSalepoint != null) wr.currentSalepoint=currentSalepoint; else wr.errorMsg='Channel Not Found on Employee Record';
           
            
            wr.DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                     From Distribution_Channel__c
                                     Where 
                                     Channel__c = : wr.currentSalepoint.Id And Active__c = true order by ERP7__Priority__c ASC];
            List <Id> siteIds = new List <Id>();            
            for(Distribution_Channel__c DC: wr.DistributionChannels) {
                siteIds.add(DC.Site__c);
            }*/
            
            wr.DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                     From Distribution_Channel__c
                                     Where 
                                     Id=:dChannelId And Active__c = true order by ERP7__Priority__c ASC];
            List <Id> siteIds = new List <Id>();            
            for(Distribution_Channel__c DC: wr.DistributionChannels) {
                siteIds.add(DC.Site__c);
            }
            
            Set<Id> productIds=new Set<Id>();
            for(Product2 pr:wr.prodList){
                if(pr.ERP7__MOQ__c == null) pr.ERP7__MOQ__c=1;
                productIds.add(pr.Id);
            }
           
            List<ERP7__Reordering_Rule__c> reOrdRule=[Select Id,Name,ERP7__MinimumHoldingQuantity__c,ERP7__MinimumOrderingQuantity__c,ERP7__Minimum_Quantity__c,ERP7__Product__c from ERP7__Reordering_Rule__c where ERP7__Product__c In:productIds];
            
            List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                            Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                            Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                            From Inventory_Stock__c
                                            Where product__c In: productIds And
                                            Active__c = true And
                                            Warehouse__c In: siteIds 
                                           ];
                
            
            for(Product2 proId:wr.prodList){
                productAndStock ps=new productAndStock();
                Decimal myStock = 0;Decimal demand=0; Decimal AWaitingStocks = 0.0;
                for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                    if(proId.Id == WIIS.product__c){
                        myStock += WIIS.Number_of_Item_In_Stock__c; 
                    	demand+=WIIS.ERP7__No_of_Items_Requested__c; 
                        AWaitingStocks += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                    }
                       
                }                
                ps.prod=proId;
                ps.stock=myStock;       
                ps.demand=demand;
                ps.diffDmnStk=ps.demand-ps.stock;
                ps.AwaitingStock = AWaitingStocks;
                /*for(ERP7__Reordering_Rule__c ro:reOrdRule){
                    if(ro.ERP7__MinimumHoldingQuantity__c == null) ro.ERP7__MinimumHoldingQuantity__c=0;
                    if(proId.Id == ro.ERP7__Product__c)
                       ps.minReOrd=ro.ERP7__MinimumHoldingQuantity__c;
                }*/
                
                
                wr.prodStockList.add(ps);
            }
            wr.prodStockList.sort();
            

            List<productAndStock> prList=new List<productAndStock>();
            for(Integer i=wr.prodStockList.size()-1;i>=0;i--){
                prList.add(wr.prodStockList[i]);
            }
            wr.prodStockList=prList;
            
            
        }catch(Exception e){wr.errorMsg=e.getMessage()+'    Line:'+e.getLineNumber();}
        return wr;
    }
    
    @AuraEnabled
    public static wrapper fetchVersionAndRouting(List<Id> prodList){
        wrapper wr=new wrapper();
        try{
            
            List<Product2> pList=[Select Id,Name,ERP7__Version__c,ERP7__Routing__c from Product2 where Id In:prodList];
            Set<Id> productIds=new Set<Id>();
            for(Product2 pr:pList){
                if(pr.ERP7__Version__c == null) productIds.add(pr.Id);
            }
            List<ERP7__Version__c> verList=[Select Id,Name from ERP7__Version__c where ERP7__Active__c=true AND ERP7__Product__c In: productIds];
            Set<Id> verIds=new Set<Id>();
            for(ERP7__Version__c vr:verList) verIds.add(vr.Id);
            
            List<ERP7__Routing__c> routingList=[Select Id,Name,ERP7__BOM_Version__c,ERP7__Product__c from ERP7__Routing__c where ERP7__BOM_Version__c In: verIds];
            
            List<ERP7__Manufacturing_Order__c> MOrder2InsertList=new List<ERP7__Manufacturing_Order__c>();
            for(Product2 pr:pList){
                if(pr.ERP7__Version__c == null){
                    for(ERP7__Routing__c rt:routingList){ if(pr.Id == rt.ERP7__Product__c){ pr.ERP7__Version__c=rt.ERP7__BOM_Version__c; pr.ERP7__Routing__c=rt.Id; }   
                    }
                }
                
                ERP7__Manufacturing_Order__c manuOrder=new ERP7__Manufacturing_Order__c();
                
                manuOrder.ERP7__Product__c = pr.Id;
                manuOrder.ERP7__Version__c = pr.ERP7__Version__c;
                manuOrder.ERP7__Routing__c = pr.ERP7__Routing__c;
                manuOrder.ERP7__StartDate__c=System.now();
                manuOrder.ERP7__ExpectedDate__c=System.now().addHours(1);
                manuOrder.ERP7__Status__c='Draft';
                manuOrder.ERP7__Owner__c=UserInfo.getUserId();
                manuOrder.ERP7__Escape_Process__c = true;
                
                MOrder2InsertList.add(manuOrder);
            }
            
            wr.MOrder2InsertList=MOrder2InsertList;
            
            
            
            
            
            Schema.DescribeFieldResult fieldResult = ERP7__Manufacturing_Order__c.ERP7__Status__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f: ple) {
                wr.moStatus.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            
        }catch(Exception e){wr.errorMsg=e.getmessage()+'    Line:'+e.getLineNumber();}        
        return wr;
    }
    
    @AuraEnabled
    public static wrapper saveMO(String MOrder2Insert){
        wrapper wr=new wrapper();
        try{
            List<ERP7__Manufacturing_Order__c> mo2Insert= (List<ERP7__Manufacturing_Order__c>) JSON.deserialize(MOrder2Insert, List<ERP7__Manufacturing_Order__c> .class);
            Set<Id> proIds=new Set<Id>();
            for(ERP7__Manufacturing_Order__c mo:mo2Insert)
                proIds.add(mo.ERP7__Product__c);
            //Map<Id,Product2> proNameMap=new Map<Id,Product2>([Select Id,Name from Product2 where Id In:proIds]);
            for(ERP7__Manufacturing_Order__c mo:mo2Insert)
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.Name.isCreateable()){mo.Name='MO'+mo.ERP7__ExpectedDate__c;}else{/*No access*/}		//proNameMap.get(mo.ERP7__Product__c).Name+' '+Integer.valueOf(mo.ERP7__Quantity__c);
            if(Schema.sObjectType.ERP7__Manufacturing_Order__c.isCreateable()){insert mo2Insert;}else{/*No access*/}
            Set<Id> moIds=new Set<Id>();
            for(ERP7__Manufacturing_Order__c mo:mo2Insert) moIds.add(mo.Id);
            List<ERP7__Manufacturing_Order__c> mo2Insert1=[Select Id,Name,ERP7__Quantity__c,ERP7__Status__c from ERP7__Manufacturing_Order__c where Id in:moIds];
            
            wr.MOrder2InsertList=mo2Insert;
            
            
            Set<Id> RoutingIds=new set<Id>();
            for(ERP7__Manufacturing_Order__c mo:mo2Insert){
                RoutingIds.add(mo.ERP7__Routing__c);
            }
            
            
            Map < Id, Set < Id >> RoutingWorkCenters = new Map < Id, Set < Id >> ();
            Map < Id, Set < Id >> RoutingProcesses = new Map < Id, Set < Id >> ();
            Map<Id, ERP7__Operation__c> OperationMap = new Map<Id, ERP7__Operation__c>();
            list < ERP7__WO__c > WOs2Create = new list < ERP7__WO__c > ();
            Map < Id, List < ERP7__Operation__c >> Routing_Operations = new Map < Id, List < ERP7__Operation__c >> ();
            Map < Id, Id > ProcessWC = new Map < Id, Id > (); 
            if(RoutingIds.size() > 0){                
                //Map<Id, ERP7__Operation__c> OperationMap = new Map<Id, ERP7__Operation__c>();
                List < ERP7__Operation__c > Operations = [Select Id, Name, ERP7__Routing_Link__c, ERP7__Description__c, ERP7__Fixed_Cost__c, ERP7__Move_Time__c, ERP7__Next_Operation_No__c, ERP7__Operation_No__c,
                                                          ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, ERP7__Process_Cycle__r.ERP7__Progress__c ,ERP7__Process_Cycle__r.ERP7__Process__c, ERP7__Quantity__c, ERP7__Required__c, ERP7__Routing__c, ERP7__Run_Time__c, ERP7__Setup_Time__c, ERP7__Variable_Cost__c,
                                                          ERP7__Work_Center__c, ERP7__Wait_Time__c, ERP7__Type__c, ERP7__Auto_Clock_In__c 
                                                          From ERP7__Operation__c Where ERP7__Routing__c In: RoutingIds And ERP7__Process_Cycle__c != Null AND ERP7__Work_Center__c != Null Order By ERP7__Process_Cycle__r.CreatedDate ASC
                                                         ];
                for (ERP7__Operation__c Operation: Operations) {
                    OperationMap.put(Operation.ERP7__Process_Cycle__c, Operation);
                    if (Operation.ERP7__Routing__c != Null && Routing_Operations.containskey(Operation.ERP7__Routing__c)) { Routing_Operations.get(Operation.ERP7__Routing__c).add(Operation);
                    } else if (Operation.ERP7__Routing__c != Null && !Routing_Operations.containskey(Operation.ERP7__Routing__c)) {
                        List < ERP7__Operation__c > myList = new List < ERP7__Operation__c > ();
                        myList.add(Operation);
                        Routing_Operations.put(Operation.ERP7__Routing__c, myList);
                    }
                    
                    if (Operation.ERP7__Routing__c != Null && RoutingWorkCenters.containskey(Operation.ERP7__Routing__c)) { RoutingWorkCenters.get(Operation.ERP7__Routing__c).add(Operation.ERP7__Work_Center__c);
                    } else if (Operation.ERP7__Routing__c != Null && !RoutingWorkCenters.containskey(Operation.ERP7__Routing__c)) {
                        Set < Id > myList = new Set < Id > ();
                        myList.add(Operation.ERP7__Work_Center__c);
                        RoutingWorkCenters.put(Operation.ERP7__Routing__c, myList);
                    }
                    
                    if (Operation.ERP7__Routing__c != Null && RoutingProcesses.containskey(Operation.ERP7__Routing__c)) { RoutingProcesses.get(Operation.ERP7__Routing__c).add(Operation.ERP7__Process_Cycle__c);
                    } else if (Operation.ERP7__Routing__c != Null && !RoutingProcesses.containskey(Operation.ERP7__Routing__c)) {
                        Set < Id > myList = new Set < Id > ();
                        myList.add(Operation.ERP7__Process_Cycle__c);
                        RoutingProcesses.put(Operation.ERP7__Routing__c, myList);
                    }
                    
                    if (Operation.ERP7__Process_Cycle__c != Null && Operation.ERP7__Work_Center__c != Null) {
                        ProcessWC.put(Operation.ERP7__Process_Cycle__c, Operation.ERP7__Work_Center__c);
                    }
                }
                
                for (Manufacturing_Order__c MO: mo2Insert) {
                    //if (MO.ERP7__Product__c != Null) IsProductKit.put(MO.ERP7__Product__c, MO.ERP7__Is_Kit__c);
                    Integer rps = 0;
                    if (RoutingWorkCenters.containsKey(MO.ERP7__Routing__c)) {
                        for (Id wcId: RoutingProcesses.get(MO.ERP7__Routing__c)) {
                            ERP7__WO__c WO2Create = new ERP7__WO__c();
                            if(Schema.sObjectType.ERP7__WO__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.Name.isUpdateable()){WO2Create.Name = OperationMap.get(WCId).ERP7__Process_Cycle__r.Name; }else{/*No access*/}
                            //WO2Create.ERP7__Site__c = MO.ERP7__Finished_Products_Site__c;
                            if(Schema.sObjectType.ERP7__WO__c.fields.Planned_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.Planned_Date__c.isUpdateable()){WO2Create.Planned_Date__c = System.Today();}else{/*No access*/}
                            
                            //WO2Create.Progress__c = OperationMap.get(WCId).ERP7__Process_Cycle__r.ERP7__Progress__c;
                            if(Schema.sObjectType.ERP7__WO__c.fields.Progress__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.Progress__c.isUpdateable()){WO2Create.Progress__c = 0;}else{/*No access*/}
                            
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Process_Cycle__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Process_Cycle__c.isUpdateable()){WO2Create.ERP7__Process_Cycle__c = WCId;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Status__c.isUpdateable()){WO2Create.ERP7__Status__c = 'Issued';}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Version__c.isUpdateable()){WO2Create.ERP7__Version__c = MO.ERP7__Version__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Project__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Project__c.isUpdateable()){WO2Create.ERP7__Project__c = MO.ERP7__Project__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Routing__c.isUpdateable()){WO2Create.ERP7__Routing__c = MO.ERP7__Routing__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Site__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Site__c.isUpdateable()){WO2Create.ERP7__Site__c = MO.ERP7__Finished_Products_SiteId__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isUpdateable()){WO2Create.ERP7__MO__c = MO.Id;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Product__c.isUpdateable()){WO2Create.ERP7__Product__c = MO.ERP7__Product__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isUpdateable()){WO2Create.ERP7__Quantity_Ordered__c = MO.ERP7__Quantity__c;}else{/*No access*/}
                            //WO2Create.ERP7__Sales_Order__c = MO.ERP7__Sales_Order__c;
                            //WO2Create.ERP7__Start_Date__c = MO.ERP7__StartDate__c;
                            //WO2Create.ERP7__End_Date__c = MO.ERP7__End_Date__c;
                            
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Type__c.isUpdateable()){WO2Create.ERP7__Type__c = 'Manufacturing';}else{/*No access*/}
                            if(rps == 0){
                                if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Start_Date__c.isUpdateable()){WO2Create.ERP7__Start_Date__c = system.Now();}else{/*No access*/}
                                if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__End_Date__c.isUpdateable()){WO2Create.ERP7__End_Date__c = system.Now().addHours(1);}else{/*No access*/}
                            }
                            else{
                                if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Start_Date__c.isUpdateable()){WO2Create.ERP7__Start_Date__c = system.Now().addHours(rps); }else{/*No access*/}    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__End_Date__c.isUpdateable()){WO2Create.ERP7__End_Date__c = system.Now().addHours(1+rps);}else{/*No access*/}
                            }
                            if(Schema.sObjectType.Manufacturing_Order__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.Manufacturing_Order__c.fields.ERP7__End_Date__c.isUpdateable()){MO.ERP7__End_Date__c = WO2Create.ERP7__End_Date__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__ExpectedDate__c.isUpdateable()){WO2Create.ERP7__ExpectedDate__c = MO.ERP7__End_Date__c; }else{/*No access*/}
							if(ProcessWC.containsKey(WCId) && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Work_Center__c.isUpdateable()){ WO2Create.ERP7__Work_Center__c = ProcessWC.get(WCId);}else{/*No access*/}
                            WOs2Create.add(WO2Create);
                            rps++;
                        }
                    }
                    
                }
            }
            PreventRecursiveLedgerEntry.testCasesTransactions = false;
            if (WOs2Create.size() > 0 && Schema.SObjectType.ERP7__WO__c.isCreateable() && Schema.SObjectType.ERP7__WO__c.isUpdateable()){ upsert WOs2Create;}else{/*No access*/}
            if(Schema.SObjectType.Manufacturing_Order__c.isCreateable() && Schema.SObjectType.Manufacturing_Order__c.isUpdateable()){upsert mo2Insert;}else{/*No access*/}
            list <ERP7__Work_Order_Line_Items__c> WOLines2Create = new list <ERP7__Work_Order_Line_Items__c>();
            for (ERP7__WO__c WO: WOs2Create) {
                ERP7__Work_Order_Line_Items__c WOLine2Create = new ERP7__Work_Order_Line_Items__c();
                if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Name.isUpdateable()){WOLine2Create.Name = WO.Name;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Active__c.isUpdateable()){WOLine2Create.ERP7__Active__c = true;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Version__c.isUpdateable()){WOLine2Create.ERP7__Version__c = WO.ERP7__Version__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Work_Orders__c.isCreateable()){WOLine2Create.ERP7__Work_Orders__c = WO.Id;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Product__c.isUpdateable()){WOLine2Create.ERP7__Product__c = WO.ERP7__Product__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Quantity__c.isUpdateable()){WOLine2Create.ERP7__Quantity__c = WO.ERP7__Quantity_Ordered__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Sales_Order__c.isUpdateable()){WOLine2Create.ERP7__Sales_Order__c = WO.ERP7__Sales_Order__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Manufacturing_Order__c.isUpdateable()){WOLine2Create.Manufacturing_Order__c = WO.ERP7__MO__c;}else{/*No access*/}
                //if (IsProductKit.containsKey(WO.ERP7__Product__c)) WOLine2Create.ERP7__Explode__c = IsProductKit.get(WO.ERP7__Product__c);
                WOLines2Create.add(WOLine2Create);
            }
            if (WOLines2Create.size() > 0 && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isUpdateable()){ upsert WOLines2Create; }else{/*No access*/}           
            
        }catch(Exception e){wr.errorMsg=e.getMessage()+'    Line:'+e.getLineNumber();}
        return wr;
    }
    
    public class productAndStock implements Comparable{
        @AuraEnabled public Product2 prod {get;set;}
        @AuraEnabled public Decimal stock {get;set;}
        //@AuraEnabled public Decimal minReOrd {get;set;}
        @AuraEnabled public Decimal demand {get;set;}
        @AuraEnabled public Decimal diffDmnStk {get;set;}
        @AuraEnabled public Decimal AwaitingStock  {get;set;}
        @AuraEnabled public boolean isSelected {get;set;}
        public productAndStock(){
            prod=new Product2();
            stock=0;
            //minReOrd=0;
            demand=0;
            diffDmnStk=0;
            AwaitingStock = 0.0;
            isSelected=false;
        }
        public Integer compareTo(Object instance){
            productAndStock that = (productAndStock)instance;
            if (this.diffDmnStk > that.diffDmnStk) return 1;
            if (this.diffDmnStk < that.diffDmnStk) return -1;
            return 0;
        }
    }
    
    public class wrapper{
        @AuraEnabled public String errorMsg {get;set;}
        @AuraEnabled public ERP7__Employees__c currentEmployee {get;set;}
        @AuraEnabled public ERP7__Channel__c currentSalepoint {get;set;}
        @AuraEnabled public List <Distribution_Channel__c> DistributionChannels {get;set;}
        @AuraEnabled public List<productAndStock> prodStockList {get;set;}
        @AuraEnabled public List<selectOptions> moStatus                            { get ; set; }
        @AuraEnabled public List<ERP7__Manufacturing_Order__c> MOrder2InsertList {get;set;}
        @AuraEnabled public boolean SOAccess {get;set;}
        
        @AuraEnabled public List<Product2> prodList {get;set;}
        @AuraEnabled public List<Integer> PNS                                                       { get; set; }
        @AuraEnabled public Integer startCount                                                      { get; set; }
        @AuraEnabled public Integer endCount                                                        { get; set; }
        @AuraEnabled public Integer Offset                                                          { get; set; }
        @AuraEnabled public Integer recSize                                                         { get; set; }
        @AuraEnabled public Integer PageNum                                                         { get; set; }
        @AuraEnabled public Integer show                                                            { get; set; }
        
        public wrapper(){
            errorMsg='';
            currentEmployee=new ERP7__Employees__c();
            currentSalepoint=new ERP7__Channel__c();
            DistributionChannels=new List<Distribution_Channel__c>();
            prodStockList=new List<productAndStock>();
            moStatus = new List < selectOptions > ();
            MOrder2InsertList=new List<ERP7__Manufacturing_Order__c>();
            SOAccess=false;
            
            
            prodList=new List<Product2>();
            PNS = new List<Integer>();
            //show = 25;
            startCount = endCount = Offset = recSize = PageNum = 0;
        }
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
        }        
    }

}