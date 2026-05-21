public with sharing Class MPS_AT_Lightning {     
    @AuraEnabled 
    public static InitWrap getAllInitial(String ProductName,Date StartDate,Date EndDate,String siteId,String period){
        InitWrap MPS = new InitWrap();
        try
        {
            system.debug('StartDate : '+StartDate);
            system.debug('EndDate : '+EndDate);
            if(StartDate == null) StartDate = MPS.StartDate;
            else  MPS.StartDate = StartDate;
            if(EndDate == null) EndDate =MPS.EndDate;
            else  MPS.EndDate = EndDate;
            system.debug('StartDate after: '+StartDate);
            system.debug('EndDate after: '+EndDate);
            Schema.DescribeFieldResult fieldResult = ERP7__MPS__c.ERP7__Schedule_Period__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f: ple) { MPS.mpsStatus.add(new SelectOptions(f.getLabel(), f.getValue())); }
            if (String.isNotBlank(ProductName))  ProductName = '%'+ProductName+'%';
            
            List<Product2> prodlist =new List<Product2>();
            String query = 'Select Id,Name,Description,ProductCode,ERP7__Purchase_Lead_Time_days__c,ERP7__Vendor_product_Name__c,ERP7__Preview_Image__c,ERP7__Picture__c,ERP7__Issue_Manufacturing_Order__c,ERP7__Issue_Purchase_Order__c from Product2 where IsActive = true and ERP7__Track_Inventory__c = true';
            if(String.isNotBlank(ProductName))  query+= ' and (Name LIKE :ProductName or ProductCode LIKE :ProductName or StockKeepingUnit LIKE :ProductName ) ';
            query+= ' Order by CreatedDate DESC Limit 20';
            prodlist = database.query(query);
            if(prodlist.size() > 0){
                set<Id> prodIds = new set<Id>();
                for(Product2 prod : prodlist) prodIds.add(prod.Id);
                String query2 = 'Select Id,ERP7__Product__c,Name,ERP7__Location__c,ERP7__Location__r.Name,ERP7__No_of_Items_Requested__c,ERP7__No_of_Items_Reserved__c,ERP7__Number_of_Items_Awaiting_in_Stock__c,ERP7__Number_of_Item_In_Stock__c,ERP7__StorageContainer__c,ERP7__StorageContainer__r.Name,ERP7__Warehouse__c,ERP7__Warehouse__r.Name from ERP7__Inventory_Stock__c where ERP7__Product__c IN :prodIds and ERP7__Active__c = true and ERP7__Number_of_Item_In_Stock__c > 0';
                if(String.isNotBlank(siteId))  query2 += ' and ERP7__Warehouse__c = :siteId ';
                
                List<ERP7__Inventory_Stock__c> invList = database.query(query2);
                Map<Id,decimal> ProdStock = new Map<Id,decimal>();
                for(ERP7__Inventory_Stock__c inv : invList){
                    decimal ItemsInstock = 0;
                    if(ProdStock.containsKey(inv.ERP7__Product__c))  {
                        ItemsInstock = ProdStock.get(inv.ERP7__Product__c) + inv.ERP7__Number_of_Item_In_Stock__c;
                        ProdStock.put(inv.ERP7__Product__c,ItemsInstock);
                    } 
                    else ProdStock.put(inv.ERP7__Product__c,inv.ERP7__Number_of_Item_In_Stock__c);
                }
                List< OrderItem > OrderItems = [Select Id, OrderItemNumber, Product2Id, Quantity, Order.ERP7__Expected_Date__c, ERP7__Version__c 
                                                From OrderItem 
                                                Where Product2Id In : prodIds And 
                                                Order.ERP7__Expected_Date__c >= :StartDate And
                                                Order.ERP7__Expected_Date__c <= :EndDate And
                                                Quantity > 0];
                Map<Id,decimal> OrderDemand = new Map<Id,decimal>();
                for(OrderItem ord : OrderItems){
                    If(OrderDemand.containsKey(ord.Product2Id)){
                        decimal qtydemand = OrderDemand.get(ord.Product2Id) + ord.Quantity;
                        OrderDemand.put(ord.Product2Id,qtydemand);
                    }
                    else OrderDemand.put(ord.Product2Id,ord.Quantity);
                }
                system.debug('OrderDemand : '+OrderDemand);
                String MRPstatus = 'Requested';
                List< ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c, ERP7__MRP_Product__c, ERP7__Total_Amount_Required__c, ERP7__MO__r.ERP7__ExpectedDate__c, ERP7__Version__c
                                             From ERP7__MRP__c
                                             Where ERP7__MRP_Product__c In : prodIds And 
                                             ( (ERP7__Order_Product__r.Order.ERP7__Expected_Date__c >= :StartDate And ERP7__Order_Product__r.Order.ERP7__Expected_Date__c <= :EndDate) Or
                                              (ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= :StartDate And ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= :EndDate) Or
                                              (ERP7__MO__r.ERP7__ExpectedDate__c >= :StartDate And ERP7__MO__r.ERP7__ExpectedDate__c <= :EndDate)) And
                                             ERP7__Total_Amount_Required__c > 0 and ERP7__Status__c=:MRPstatus];
                system.debug('MRPS : '+MRPS.size());
                Map<Id,decimal> MRPDemand = new Map<Id,decimal>();
                for(ERP7__MRP__c mrp : MRPS){
                    If(MRPDemand.containsKey(mrp.ERP7__MRP_Product__c)){
                        decimal qtydemand = MRPDemand.get(mrp.ERP7__MRP_Product__c) + mrp.ERP7__Total_Amount_Required__c;
                        MRPDemand.put(mrp.ERP7__MRP_Product__c,qtydemand);
                    }
                    else MRPDemand.put(mrp.ERP7__MRP_Product__c,mrp.ERP7__Total_Amount_Required__c);
                }
                system.debug('MRPDemand : '+MRPDemand);
                List< ERP7__Manufacturing_Order__c > MOS = [Select Id, Name, ERP7__ExpectedDate__c,ERP7__Expected_Date__c, ERP7__Product__c, ERP7__Version__c, ERP7__Quantity__c
                                                            From ERP7__Manufacturing_Order__c
                                                            Where ERP7__Product__c In : prodIds And 
                                                            (ERP7__ExpectedDate__c >= :StartDate And ERP7__ExpectedDate__c <= :EndDate) And
                                                            ERP7__Quantity__c > 0 and ERP7__Status__c != 'Completed'];                                
                system.debug('MOS : '+MOS.size());
                Map<Id,decimal> MOQty = new Map<Id,decimal>();
                for(ERP7__Manufacturing_Order__c mo : MOS){
                    If(MOQty.containsKey(mo.ERP7__Product__c)){
                        decimal qty = MOQty.get(mo.ERP7__Product__c) + mo.ERP7__Quantity__c;
                        MOQty.put(mo.ERP7__Product__c,qty);
                    }
                    else MOQty.put(mo.ERP7__Product__c,mo.ERP7__Quantity__c);
                }
                system.debug('MOQty : '+MOQty);
                List<ERP7__Purchase_Line_Items__c> PurchaseLines = [Select Id, Name, ERP7__Active__c, ERP7__Version__c, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.ERP7__Expected_Date__c, ERP7__Product__c, ERP7__Quantity__c,ERP7__Quantity_Received__c
                                                                    From ERP7__Purchase_Line_Items__c
                                                                    Where ERP7__Product__c In : prodIds And 
                                                                    (ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= :StartDate And ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= :EndDate) And
                                                                    ERP7__Quantity__c > 0];
                system.debug('PurchaseLines : '+PurchaseLines);
                Map<Id,decimal> POQty = new Map<Id,decimal>();
                for(ERP7__Purchase_Line_Items__c po : PurchaseLines){
                    If(POQty.containsKey(po.ERP7__Product__c)){
                        decimal qty = (po.ERP7__Quantity_Received__c > 0) ? (po.ERP7__Quantity__c - po.ERP7__Quantity_Received__c) + POQty.get(po.ERP7__Product__c) : POQty.get(po.ERP7__Product__c) + po.ERP7__Quantity__c;
                        POQty.put(po.ERP7__Product__c,qty);
                    }
                    else {
                        decimal poReceivedqty = (po.ERP7__Quantity_Received__c > 0) ? (po.ERP7__Quantity__c - po.ERP7__Quantity_Received__c) : po.ERP7__Quantity__c;
                        POQty.put(po.ERP7__Product__c,poReceivedqty);
                    }
                }
                system.debug('POQty : '+POQty);
                system.debug('period : '+period);
                List<ERP7__Reordering_Rule__c> rrList = [Select Id,Name,ERP7__Minimum_Quantity__c,ERP7__MinimumOrderingQuantity__c,ERP7__Product__c from ERP7__Reordering_Rule__c where ERP7__Product__c IN :prodIds ];
                Map<Id,ERP7__Reordering_Rule__c> rrMap = new Map<Id,ERP7__Reordering_Rule__c>();
                for(ERP7__Reordering_Rule__c rr : rrList){
                    if(!rrMap.containsKey(rr.ERP7__Product__c)) rrMap.put(rr.ERP7__Product__c,rr);
                } 
                system.debug('StartDate : '+StartDate);
                system.debug(' MPS.StartDate : '+MPS.StartDate);
                
                Date sd = StartDate;
                Date ed = EndDate;
                List<prodWrap> prodWraplist = new List<prodWrap>();
                //if(period == 'Monthly'){ 
                Integer Months = sd.monthsBetween(ed);
                List<String> newstr = new List<String>();
                /* while(Months > 0){
if (ed.day() > sd.day()) Months++;
Integer i = 0;
system.debug('Months : '+Months);
Integer curMonth = ((sd.Month()+i) > 12)? (sd.Month()+i-12):(sd.Month()+i);
String viewStr = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
Date tempEd = sd.addMonths(i);
viewStr += ' '+String.valueof(tempEd.year());
newstr.add(viewStr);
i++;
Months--;
}*/
                system.debug('sd : '+sd);
                for(Product2 prod : prodlist){
                    prodWrap newWrap = new prodWrap();
                    //newWrap.viewStr =newstr;
                    newWrap.Prod = prod;
                    newWrap.StartDate = sd;
                    newWrap.EndDate = ed;
                    if(OrderDemand.containsKey(prod.Id)) newWrap.OrdDemand = OrderDemand.get(prod.Id);
                    else newWrap.OrdDemand = 0;
                    if(MRPDemand.containsKey(prod.Id)) newWrap.MRPDemand = MRPDemand.get(prod.Id);
                    else newWrap.MRPDemand = 0;
                    Decimal OrderderQty = 0;
                    if(MOQty.containsKey(prod.Id)) OrderderQty += MOQty.get(prod.Id);
                    if(POQty.containsKey(prod.Id)) OrderderQty += POQty.get(prod.Id);
                    newWrap.OrderedQty = OrderderQty;
                    if(rrMap.containsKey(prod.Id)) newWrap.rrRule = rrMap.get(prod.Id);
                    else newWrap.rrRule = new ERP7__Reordering_Rule__c(ERP7__Minimum_Quantity__c = 0,ERP7__MinimumOrderingQuantity__c = 0,ERP7__Product__c= prod.Id);
                    if(ProdStock.containsKey(prod.Id)) newWrap.NetInventory = ProdStock.get(prod.Id);
                    else newWrap.NetInventory = 0;
                    newWrap.toProduce = ((newWrap.OrdDemand + newWrap.MRPDemand) <= ((newWrap.NetInventory - newWrap.rrRule.ERP7__Minimum_Quantity__c) + newWrap.OrderedQty)) ? 0 : ((newWrap.OrdDemand + newWrap.MRPDemand) - (newWrap.NetInventory - newWrap.rrRule.ERP7__Minimum_Quantity__c) - newWrap.OrderedQty);
                        newWrap.ProjectedInventory =  ((newWrap.NetInventory - newWrap.rrRule.ERP7__Minimum_Quantity__c) + newWrap.OrderedQty +  newWrap.toProduce) ;
                    
                    prodWraplist.add(newWrap);
                    
                    
                    
                }
                // }
                /* else if(period == 'Weekly'){
sd = sd.toStartOfWeek();
Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
Integer Weeks = sd.daysBetween(ed)/7;
if(Math.Mod(Weeks,7) > 0) Weeks++;
Integer i = 0;
while(Weeks > 0){
if(i>=2) {
String viewStr = sdt.addDays((i*7)+1).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+7).format(' dd MMM yyyy');
MPS.viewStr.add(viewStr);    
i++;
Weeks--;
}
else{
String viewStr = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
MPS.viewStr.add(viewStr);    
i++;
Weeks--;
}
}
}
else if(period == 'quarterly'){
Date sdt=Date.newInstance(sd.Year(), 1, 1);
Date edt=Date.newInstance(sd.Year(), 3, 31);
Date edt2=Date.newInstance(sd.Year(), 6, 30);
Date edt3=Date.newInstance(sd.Year(), 9, 30);
Date edt4=Date.newInstance(sd.Year(), 12, 31);
if((sd>=sdt) && (ed<=edt)) { String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year(); MPS.viewStr.add(viewStr);
}else if((sd>=sdt && sd<=edt) && (ed>edt && ed<=edt2)) {
MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
}
else if((sd>=sdt && sd<=edt2) && (ed>edt2 && ed<=edt3)) {
MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
MPS.viewStr.add('Q3'+'-'+sd.addMonths(2*3).Year());
}
else if((sd>=sdt && sd<=edt3) && (ed>edt3 && ed<=edt4)) {
MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
MPS.viewStr.add('Q3'+'-'+sd.addMonths(2*3).Year());
MPS.viewStr.add('Q4'+'-'+sd.addMonths(3*3).Year());
}
else if((sd>edt && sd<=edt2) && (ed>edt && ed<=edt2)){
MPS.viewStr.add('Q2'+'-'+sd.addMonths(0*3).Year());
}
else if((sd>edt && ed>edt2 && sd<=edt2) && ed<=edt3){
MPS.viewStr.add('Q3'+'-'+sd.addMonths(0*3).Year());
MPS.viewStr.add('Q4'+'-'+sd.addMonths(1*3).Year());
}
else if((sd>=edt && ed>edt3 && sd<=edt2) && ed<=edt4){
MPS.viewStr.add('Q2'+'-'+sd.addMonths(0*3).Year());
MPS.viewStr.add('Q3'+'-'+sd.addMonths(1*3).Year());
MPS.viewStr.add('Q4'+'-'+sd.addMonths(2*3).Year());
}
else if((sd>edt2 && ed>edt2 && sd<=edt2) && ed<=edt3){
MPS.viewStr.add('Q3'+'-'+sd.addMonths(0*3).Year());
MPS.viewStr.add('Q4'+'-'+sd.addMonths(1*3).Year());
}
else if((sd>edt2 && ed>edt3) && ed<=edt4){
MPS.viewStr.add('Q4'+'-'+sd.addMonths(0*3).Year());
}
else{
MPS.viewStr.add('Q4'+'-'+sd.addMonths(0*3).Year());
}
} */
                MPS.ProdList = prodWraplist;   
            }
            
        }catch(exception e){
            MPS.errMsg =  'Error : '+e.getMessage()+' @ Line Num : '+e.getLineNumber();
        }
        return MPS;
        
    }
    
    @AuraEnabled 
    public static MPS getAll(String mpsId){ 
        MPS MPS = new MPS(); 
        List<ERP7__MPS__c> BOMMPS2upsert = new List<ERP7__MPS__c>(); 
        try{
            String mpsFields = UtilClass.selectStarFromSObject('ERP7__MPS__c');
            mpsFields += ' ,ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c,ERP7__Product__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Bill_Of_Material__r.ERP7__Quantity__c ';
            //utilClass.FLSCheck(mpsFields.split(','),'ERP7__MPS__c');    
            String mpsLineFields = UtilClass.selectStarFromSObject('ERP7__MPS_line_Item__c');
            mpsLineFields += ',ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__MPS__r.ERP7__Master_Production_Schedule__c';
            //utilClass.FLSCheck(mpsLineFields.split(','),'ERP7__MPS_line_Item__c');
            
            if(mpsId != Null){
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where Id =: MPSId Or ERP7__Master_Production_Schedule__c =: MPSId Order by CreatedDate Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                
                query = 'select ' + mpsLineFields + ' from ERP7__MPS_line_Item__c where ERP7__MPS__c =: MPSId Or ERP7__MPS__r.ERP7__Master_Production_Schedule__c =: MPSId Order by ERP7__Line_Count__c Asc limit 10000';
                //List<ERP7__MPS_line_Item__c> MPSSLines = Da+tabase.query(query);
                List<ERP7__MPS_line_Item__c> MPSSLines = [Select Id, Name, ERP7__MPS__c, ERP7__Line_Count__c, ERP7__To_Supply_Manufacture__c, ERP7__Available_To_Promise__c, ERP7__Actual_Demand__c, ERP7__Demand_Forecast__c, ERP7__Net_Inventory_Before_Supply_Produce__c, ERP7__Projected_Inventory__c,
                                                          ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__MPS__r.ERP7__Master_Production_Schedule__c
                                                          From ERP7__MPS_line_Item__c 
                                                          Where ERP7__MPS__c =: MPSId Or ERP7__MPS__r.ERP7__Master_Production_Schedule__c =: MPSId 
                                                          Order by ERP7__Line_Count__c Asc limit 10000];
                system.debug('MPSSLines : '+MPSSLines.size());
                Set<Id> productIds = new Set<Id>();
                Date StartDate, EndDate;
                Map<Id, List<ERP7__Sales_Order_Line_Item__c>> productOrderLines = new Map<Id, List<ERP7__Sales_Order_Line_Item__c>>(); 
                Map<Id, List<OrderItem>> productOrderItemLines = new Map<Id, List<OrderItem>>(); 
                Map<Id, List<ERP7__MRP__c>> productMRPS = new Map<Id, List<ERP7__MRP__c>>(); 
                Map<Id, List<ERP7__Manufacturing_Order__c>> productMOS = new Map<Id, List<ERP7__Manufacturing_Order__c>>();
                Map<Id, List<ERP7__Purchase_Line_Items__c>> productPOLines = new Map<Id, List<ERP7__Purchase_Line_Items__c>>(); 
                for(ERP7__MPS__c MP : MPSS){
                    productIds.add(MP.ERP7__Product__c);
                    if(MP.Id == mpsId) {
                        StartDate = MP.ERP7__Start_Date__c;
                        EndDate = MP.ERP7__End_Date__c;
                    }
                }
                
                List< ERP7__Sales_Order_Line_Item__c > SOLIS = [Select Id, Name, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__r.ERP7__Expected_Date__c, ERP7__Version__c 
                                                                From ERP7__Sales_Order_Line_Item__c 
                                                                Where ERP7__Product__c In : productIds And 
                                                                ERP7__Sales_Order__r.ERP7__Expected_Date__c >= :StartDate And
                                                                ERP7__Sales_Order__r.ERP7__Expected_Date__c <= :EndDate And
                                                                ERP7__Quantity__c > 0];
                
                List< OrderItem > OrderItems = [Select Id, OrderItemNumber, Product2Id, Quantity, Order.ERP7__Expected_Date__c, ERP7__Version__c 
                                                From OrderItem 
                                                Where Product2Id In : productIds And 
                                                Order.ERP7__Expected_Date__c >= :StartDate And
                                                Order.ERP7__Expected_Date__c <= :EndDate And
                                                Quantity > 0];
                system.debug('OrderItems : '+OrderItems.size());
                List< ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c, ERP7__MRP_Product__c, ERP7__Total_Amount_Required__c, ERP7__MO__r.ERP7__ExpectedDate__c, ERP7__Version__c
                                             From ERP7__MRP__c
                                             Where ERP7__MRP_Product__c In : productIds And 
                                             ( (ERP7__Order_Product__r.Order.ERP7__Expected_Date__c >= :StartDate And ERP7__Order_Product__r.Order.ERP7__Expected_Date__c <= :EndDate) Or
                                              (ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= :StartDate And ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= :EndDate) Or
                                              (ERP7__MO__r.ERP7__ExpectedDate__c >= :StartDate And ERP7__MO__r.ERP7__ExpectedDate__c <= :EndDate)) And
                                             ERP7__Total_Amount_Required__c > 0];
                
                List< ERP7__Manufacturing_Order__c > MOS = [Select Id, Name, ERP7__Expected_Date__c,ERP7__ExpectedDate__c, ERP7__Product__c, ERP7__Version__c, ERP7__Quantity__c
                                                            From ERP7__Manufacturing_Order__c
                                                            Where ERP7__Product__c In : productIds And 
                                                            (ERP7__ExpectedDate__c >= :StartDate And ERP7__ExpectedDate__c <= :EndDate) And
                                                            ERP7__Quantity__c > 0];                                
                
                List<ERP7__Purchase_Line_Items__c> PurchaseLines = [Select Id, Name, ERP7__Active__c, ERP7__Version__c, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.ERP7__Expected_Date__c, ERP7__Product__c, ERP7__Quantity__c
                                                                    From ERP7__Purchase_Line_Items__c
                                                                    Where ERP7__Product__c In : productIds And 
                                                                    (ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= :StartDate And ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= :EndDate) And
                                                                    ERP7__Quantity__c > 0];
                
                for(Id pId : productIds){
                    List< ERP7__Sales_Order_Line_Item__c > mySOLIS = new List< ERP7__Sales_Order_Line_Item__c >();
                    for(ERP7__Sales_Order_Line_Item__c SOLI : SOLIS) if(SOLI.ERP7__Product__c == pId) mySOLIS.add(SOLI);
                    productOrderLines.put(pId,mySOLIS);
                    
                    List< OrderItem > myOLIS = new List< OrderItem >();
                    for(OrderItem SOLI : OrderItems) if(SOLI.Product2Id == pId) myOLIS.add(SOLI);
                    productOrderItemLines.put(pId,myOLIS);
                    system.debug('productOrderItemLines : '+productOrderItemLines);
                    List< ERP7__MRP__c > myMRPS = new List< ERP7__MRP__c >();
                    for(ERP7__MRP__c MRP : MRPS) if(MRP.ERP7__MRP_Product__c == pId) myMRPS.add(MRP);
                    productMRPS.put(pId,myMRPS);
                    
                    List< ERP7__Manufacturing_Order__c > myMOS = new List< ERP7__Manufacturing_Order__c >();
                    for(ERP7__Manufacturing_Order__c MO : MOS) if(MO.ERP7__Product__c == pId) myMOS.add(MO);
                    productMOS.put(pId,myMOS);
                    
                    List< ERP7__Purchase_Line_Items__c > myPLS = new List< ERP7__Purchase_Line_Items__c >();
                    for(ERP7__Purchase_Line_Items__c PL : PurchaseLines) if(PL.ERP7__Product__c == pId) myPLS.add(PL);
                    productPOLines.put(pId,myPLS);
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    if(MP.Id == mpsId) {
                        List<ERP7__MPS_line_Item__c> myMPSSLines = new List<ERP7__MPS_line_Item__c>();
                        for(ERP7__MPS_line_Item__c MPSSLine : MPSSLines){
                            if(MP.Id == MPSSLine.ERP7__MPS__c) myMPSSLines.add(MPSSLine);
                        }
                        MPS.MPS = MP; 
                        system.debug('myMPSSLines.size() : '+myMPSSLines.size());
                        if(myMPSSLines.size() > 0){
                            MPS.Dirty = false;
                            MPS.Dirtys = false;
                            for(ERP7__MPS_line_Item__c MPSSLine : myMPSSLines){
                                system.debug('MPSSLine : '+MPSSLine);
                                MPSLine MPLine = new MPSLine();
                                MPLine.IssueMO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                MPLine.IssuePO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                MPLine.MPSLine = MPSSLine;
                                MPS.MPSLines.add(MPLine);
                            }
                        }
                        else{
                            MPS.Dirty = true;
                            MPS.Dirtys = true;
                            if(MP.ERP7__Schedule_Period__c == 'Monthly'){ 
                                Date sd = MP.ERP7__Start_Date__c;
                                Date ed = MP.ERP7__End_Date__c;
                                Integer Months = sd.monthsBetween(ed);
                                if (ed.day() > sd.day()) Months++;
                                Integer i = 0;
                                while(Months > 0){
                                Integer curMonth = math.mod((sd.Month() + i - 1),12) + 1;
                                system.debug('curMonth :'+curMonth );
                                  //  Integer curMonth = ((sd.Month()+i) > 12)? (sd.Month()+i-12):(sd.Month()+i);
                                        MPSLine MPLine = new MPSLine();
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    Date stDate = sd.AddMonths(i);
                                    Integer lastDay = Date.daysInMonth(stDate.year(), stDate.month());
                                    Date edDate = Date.newInstance(stDate.year(), stDate.month(), lastDay);
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.Quantity;
                                    system.debug('actualDemand : '+actualDemand);
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    MPS.MPSLines.add(MPLine);
                                    i++;
                                    Months--;
                                    
                                }
                            } 
                            else if(MP.ERP7__Schedule_Period__c == 'Weekly'){ 
                                Date sd = MP.ERP7__Start_Date__c;
                                Date ed = MP.ERP7__End_Date__c;
                                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                sd = sd.toStartOfWeek();
                                Integer Weeks = sd.daysBetween(ed)/7;
                                if(Math.Mod(Weeks,7) > 0) Weeks++;
                                Integer i = 0;
                                while(Weeks > 0){
                                    MPSLine MPLine = new MPSLine();
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    Date stDate = sd.addDays(i*7);
                                    Date edDate = sd.addDays((i*7)+6);
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) { system.debug('1 : '); if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)){ actualDemand += SOLI.Quantity; system.debug('2 :SOLI.Quantity : '+SOLI.Quantity);}}
                                    system.debug('actualDemand : '+actualDemand);
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    system.debug('actualDemandIndirect : '+actualDemandIndirect);
                                    if(actualDemandIndirect == null) actualDemandIndirect = 0;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    MPS.MPSLines.add(MPLine);
                                    i++;
                                    Weeks--;
                                }
                            }
                            else if(MP.ERP7__Schedule_Period__c == 'Quarterly'){  
                                Date sd = MP.ERP7__Start_Date__c;
                                Date ed = MP.ERP7__End_Date__c;
                                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                sd = Date.newInstance(sd.Year(), 1, 1);
                                ed = Date.newInstance(ed.Year()+1, 1, 1)-1;
                                
                                Integer Quarters = (ed.Year() == sd.Year())? 4 : (ed.Year() - sd.Year()+1)*4;
                                Integer i = 0;
                                while(Quarters > 0){
                                    MPSLine MPLine = new MPSLine();
                                    Date stDate = sd.addMonths(i);
                                    Date edDate = sd.addMonths(i*3)-1;
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = 'Q'+String.valueOf(i+1)+'-'+stDate.Year();      
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.Quantity;
                                    
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    MPS.MPSLines.add(MPLine);
                                    i++;
                                    Quarters--;
                                }
                            }
                        }
                        break;   
                    }
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    if(MP.ERP7__Master_Production_Schedule__c == mpsId) {
                        MPS cMPS = new MPS();
                        
                        List<ERP7__MPS_line_Item__c> myMPSSLines = new List<ERP7__MPS_line_Item__c>();
                        if(MP.ERP7__Start_Date__c == StartDate && MP.ERP7__End_Date__c == EndDate){
                            for(ERP7__MPS_line_Item__c MPSSLine : MPSSLines){
                                if(MP.Id == MPSSLine.ERP7__MPS__c) myMPSSLines.add(MPSSLine);
                            }
                        }
                        else{
                            MP.ERP7__Start_Date__c = StartDate;
                            MP.ERP7__End_Date__c = EndDate;
                            BOMMPS2upsert.add(MP);
                        }
                        cMPS.MPS = MP; 
                        if(myMPSSLines.size() > 0){
                            MPS.Dirty = false;
                            MPS.Dirtys = false;
                            for(ERP7__MPS_line_Item__c MPSSLine : myMPSSLines){
                                MPSLine MPLine = new MPSLine();
                                MPLine.MPSLine = MPSSLine;
                                MPLine.IssueMO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                MPLine.IssuePO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                cMPS.MPSLines.add(MPLine);
                            }
                        }
                        else{
                            MPS.Dirty = true;
                            MPS.Dirtys = true;
                            cMPS.MPS = MP;
                            if(MP.ERP7__Schedule_Period__c == 'Monthly'){
                                Date sd = MP.ERP7__Start_Date__c;
                                Date ed = MP.ERP7__End_Date__c;
                                Integer Months = sd.monthsBetween(ed);
                                if (ed.day() > sd.day()) Months++;
                                Integer i = 0;
                                while(Months > 0){
                                    Integer curMonth = ((sd.Month()+i) > 12)? (sd.Month()+i-12):(sd.Month()+i);
                                        MPSLine MPLine = new MPSLine();
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    Date stDate = sd.AddMonths(i);
                                    Integer lastDay = Date.daysInMonth(stDate.year(), stDate.month());
                                    Date edDate = Date.newInstance(stDate.year(), stDate.month(), lastDay);
                                    //Date edDate = sd.AddMonths(i+1);
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.Quantity;
                                    
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    cMPS.MPSLines.add(MPLine);
                                    i++; 
                                    Months--;
                                }
                            }
                            else if(MP.ERP7__Schedule_Period__c == 'Weekly'){ 
                                Date sd = MP.ERP7__Start_Date__c;
                                Date ed = MP.ERP7__End_Date__c;
                                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                sd = sd.toStartOfWeek();
                                Integer Weeks = sd.daysBetween(ed)/7;
                                if(Math.Mod(Weeks,7) > 0) Weeks++;
                                Integer i = 0;
                                while(Weeks > 0){
                                    MPSLine MPLine = new MPSLine();
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    Date stDate = sd.addDays(i*7);
                                    Date edDate = sd.addDays((i*7)+6);
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.Quantity;
                                    
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    cMPS.MPSLines.add(MPLine);
                                    i++;
                                    Weeks--;
                                }
                            }
                            else if(MP.ERP7__Schedule_Period__c == 'Quarterly'){ 
                                Date sd = MP.ERP7__Start_Date__c;
                                Date ed = MP.ERP7__End_Date__c;
                                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                sd = Date.newInstance(sd.Year(), 1, 1);
                                ed = Date.newInstance(ed.Year()+1, 1, 1)-1;
                                
                                Integer Quarters = (ed.Year() == sd.Year())? 4 : (ed.Year() - sd.Year()+1)*4;
                                Integer i = 0;
                                while(Quarters > 0){
                                    MPSLine MPLine = new MPSLine();
                                    Date stDate = sd.addMonths(i);
                                    Date edDate = sd.addMonths(i*3)-1;
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = 'Q'+String.valueOf(i+1)+'-'+stDate.Year();     
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.Quantity;
                                    
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    cMPS.MPSLines.add(MPLine);
                                    i++;
                                    Quarters--;
                                }
                            }
                        }
                        MPS.MPSS.add(cMPS);                
                    }
                }
            }
            Schema.DescribeFieldResult fieldResult = ERP7__MPS__c.ERP7__Schedule_Period__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f: ple) { MPS.mpsStatus.add(new SelectOptions(f.getLabel(), f.getValue())); } } catch(Exception e) {  MPS.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();
             if(BOMMPS2upsert.size() > 0) upsert BOMMPS2upsert;                                                                                                                           }
        MPS.InitialDate=system.Today();
        return MPS;
    }
    
    @AuraEnabled 
    public static MPS getAllSTockRR(String mpsId, Date onload,String ProdId,String MPSDetails){ 
        MPS MPS = new MPS();  
        try{
            String mpsFields = UtilClass.selectStarFromSObject('ERP7__MPS__c');
            mpsFields += ' ,ERP7__Master_Production_Schedule__r.ERP7__Product__c,ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Bill_Of_Material__r.ERP7__Quantity__c ,ERP7__Product__r.ERP7__Issue_Purchase_Order__c,ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c';
            //utilClass.FLSCheck(mpsFields.split(','),'ERP7__MPS__c');    
            String mpsLineFields = UtilClass.selectStarFromSObject('ERP7__MPS_line_Item__c');
            mpsLineFields += ',ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__MPS__r.ERP7__Master_Production_Schedule__c';
            //utilClass.FLSCheck(mpsLineFields.split(','),'ERP7__MPS_line_Item__c');
            if(ProdId != null &&  ProdId != ''){
                Product2 prod = [Select Id,Name,ERP7__Issue_Manufacturing_Order__c from Product2 where Id=:ProdId LIMIT 1];
                ERP7__MPS__c masterMps = (ERP7__MPS__c)JSON.deserialize(MPSDetails, ERP7__MPS__c.class); 
                Date StartDate = masterMps.ERP7__Start_Date__c;
                Date EndDate = masterMps.ERP7__End_Date__c;
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where ERP7__Product__c =: ProdId and ERP7__Start_Date__c = :StartDate and ERP7__End_Date__c =:EndDate  Order by CreatedDate Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                system.debug('MPSS : '+MPSS.size());
                
                if(prod.ERP7__Issue_Manufacturing_Order__c){
                    List<ERP7__Version__c> version = [Select Id,Name from ERP7__Version__c where ERP7__Product__c=:ProdId and ERP7__Active__c = true and ERP7__Start_Date__c <= :System.today() and ERP7__To_Date__c >= :System.today() Order By ERP7__Default__c ];
                    if(version.size() > 0) { masterMps.ERP7__Version__c = version[0].Id; }
                }
                if(MPSS.size() > 0) { mpsId = MPSS[0].Id; }
                else { PreventRecursiveLedgerEntry.preventMPsTrigger = true; upsert masterMps; mpsId = masterMps.Id; }
                system.debug('masterMps : '+masterMps);
                
            }
            system.debug('mpsId : '+mpsId);
            if(mpsId != Null){
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where Id =: MPSId Or ERP7__Master_Production_Schedule__c =: MPSId Order by CreatedDate Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                query = 'select ' + mpsLineFields + ' from ERP7__MPS_line_Item__c where ERP7__MPS__c =: MPSId Or ERP7__MPS__r.ERP7__Master_Production_Schedule__c =: MPSId Order by ERP7__Line_Count__c Asc limit 10000';
                
                //List<ERP7__MPS_line_Item__c> MPSSLines = Da+tabase.query(query);
                List<ERP7__MPS_line_Item__c> MPSSLines = [Select Id, Name, ERP7__MPS__c, ERP7__Line_Count__c, ERP7__To_Supply_Manufacture__c, ERP7__Available_To_Promise__c, ERP7__Actual_Demand__c, ERP7__Demand_Forecast__c, ERP7__Net_Inventory_Before_Supply_Produce__c, ERP7__Projected_Inventory__c,
                                                          ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__MPS__r.ERP7__Master_Production_Schedule__c,ERP7__MPS__r.ERP7__Schedule_Period__c
                                                          From ERP7__MPS_line_Item__c 
                                                          Where ERP7__MPS__c =: MPSId Or ERP7__MPS__r.ERP7__Master_Production_Schedule__c =: MPSId 
                                                          Order by ERP7__Line_Count__c Asc limit 10000];
                system.debug('MPSSLines : '+MPSSLines.size());
                Set<Id> productIds = new Set<Id>();
                Date StartDate, EndDate;
                Map<Id, List<ERP7__Sales_Order_Line_Item__c>> productOrderLines = new Map<Id, List<ERP7__Sales_Order_Line_Item__c>>(); 
                Map<Id, List<OrderItem>> productOrderItemLines = new Map<Id, List<OrderItem>>();
                Map<Id, List<ERP7__MRP__c>> productMRPS = new Map<Id, List<ERP7__MRP__c>>(); 
                Map<Id, List<ERP7__Manufacturing_Order__c>> productMOS = new Map<Id, List<ERP7__Manufacturing_Order__c>>();
                Map<Id, List<ERP7__Purchase_Line_Items__c>> productPOLines = new Map<Id, List<ERP7__Purchase_Line_Items__c>>(); 
                for(ERP7__MPS__c MP : MPSS){
                    productIds.add(MP.ERP7__Product__c);
                    if(MP.Id == mpsId) {
                        StartDate = onload;
                        EndDate = MP.ERP7__End_Date__c;
                    }
                }
                system.debug('productIds : '+productIds);
                system.debug('StartDate : '+StartDate);
                system.debug('EndDate : '+EndDate);
                List< ERP7__Sales_Order_Line_Item__c > SOLIS = [Select Id, Name, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__r.ERP7__Expected_Date__c, ERP7__Version__c 
                                                                From ERP7__Sales_Order_Line_Item__c 
                                                                Where ERP7__Product__c In : productIds And 
                                                                ERP7__Sales_Order__r.ERP7__Expected_Date__c >= :StartDate And
                                                                ERP7__Sales_Order__r.ERP7__Expected_Date__c <= :EndDate And
                                                                ERP7__Quantity__c > 0];
                system.debug('SOLIS : '+SOLIS.size());
                List< OrderItem > OrderItems = [Select Id, OrderItemNumber, Product2Id, Quantity, Order.ERP7__Expected_Date__c, ERP7__Version__c 
                                                From OrderItem 
                                                Where Product2Id In : productIds And 
                                                Order.ERP7__Expected_Date__c >= :StartDate And
                                                Order.ERP7__Expected_Date__c <= :EndDate And
                                                Quantity > 0];
                system.debug('OrderItems : '+OrderItems.size());
                List< ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c, ERP7__MRP_Product__c, ERP7__Total_Amount_Required__c, ERP7__MO__r.ERP7__ExpectedDate__c, ERP7__Version__c
                                             From ERP7__MRP__c
                                             Where ERP7__MRP_Product__c In : productIds And 
                                             ((ERP7__Order_Product__r.Order.ERP7__Expected_Date__c >= :StartDate And ERP7__Order_Product__r.Order.ERP7__Expected_Date__c <= :EndDate) Or
                                              (ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= :StartDate And ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= :EndDate) Or
                                              (ERP7__MO__r.ERP7__ExpectedDate__c>= :StartDate And ERP7__MO__r.ERP7__ExpectedDate__c<= :EndDate)) And
                                             ERP7__Total_Amount_Required__c > 0];
                system.debug('MRPS : '+MRPS.size());
                List< ERP7__Manufacturing_Order__c > MOS = [Select Id, Name, ERP7__ExpectedDate__c,ERP7__Expected_Date__c, ERP7__Product__c, ERP7__Version__c, ERP7__Quantity__c
                                                            From ERP7__Manufacturing_Order__c
                                                            Where ERP7__Product__c In : productIds And 
                                                            (ERP7__ExpectedDate__c>= :StartDate And ERP7__ExpectedDate__c<= :EndDate) And
                                                            ERP7__Quantity__c > 0];                                
                system.debug('MOS : '+MOS.size());
                List<ERP7__Purchase_Line_Items__c> PurchaseLines = [Select Id, Name, ERP7__Active__c, ERP7__Version__c, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.ERP7__Expected_Date__c, ERP7__Product__c, ERP7__Quantity__c
                                                                    From ERP7__Purchase_Line_Items__c
                                                                    Where ERP7__Product__c In : productIds And 
                                                                    (ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= :StartDate And ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= :EndDate) And
                                                                    ERP7__Quantity__c > 0];
                system.debug('PurchaseLines : '+PurchaseLines.size());
                
                for(Id pId : productIds){
                    List< ERP7__Sales_Order_Line_Item__c > mySOLIS = new List< ERP7__Sales_Order_Line_Item__c >();
                    for(ERP7__Sales_Order_Line_Item__c SOLI : SOLIS) if(SOLI.ERP7__Product__c == pId) mySOLIS.add(SOLI);
                    productOrderLines.put(pId,mySOLIS);
                    
                    List< OrderItem > myOLIS = new List< OrderItem >();
                    for(OrderItem SOLI : OrderItems) if(SOLI.Product2Id == pId) myOLIS.add(SOLI);
                    productOrderItemLines.put(pId,myOLIS);
                    
                    List< ERP7__MRP__c > myMRPS = new List< ERP7__MRP__c >();
                    for(ERP7__MRP__c MRP : MRPS) if(MRP.ERP7__MRP_Product__c == pId) myMRPS.add(MRP);
                    productMRPS.put(pId,myMRPS);
                    
                    List< ERP7__Manufacturing_Order__c > myMOS = new List< ERP7__Manufacturing_Order__c >();
                    for(ERP7__Manufacturing_Order__c MO : MOS) if(MO.ERP7__Product__c == pId) myMOS.add(MO);
                    productMOS.put(pId,myMOS);
                    
                    List< ERP7__Purchase_Line_Items__c > myPLS = new List< ERP7__Purchase_Line_Items__c >();
                    for(ERP7__Purchase_Line_Items__c PL : PurchaseLines) if(PL.ERP7__Product__c == pId) myPLS.add(PL);
                    productPOLines.put(pId,myPLS);
                }
                system.debug('productOrderLines : '+productOrderLines.size());
                system.debug('productOrderItemLines : '+productOrderItemLines.size());
                system.debug('productMRPS : '+productMRPS.size());
                system.debug('productMOS : '+productMOS.size());
                system.debug('productPOLines : '+productPOLines.size());
                for(ERP7__MPS__c MP : MPSS){
                    system.debug('MP.Id :'+MP.Id);
                    system.debug('mpsId :'+mpsId);
                    if(MP.Id == mpsId) {
                        List<ERP7__MPS_line_Item__c> myMPSSLines = new List<ERP7__MPS_line_Item__c>(); 
                        for(ERP7__MPS_line_Item__c MPSSLine : MPSSLines){ if(MP.Id == MPSSLine.ERP7__MPS__c){ system.debug('Match line Ids'); myMPSSLines.add(MPSSLine); } }
                        System.debug('myMPSSLines : '+myMPSSLines.size());
                        MPS.MPS = MP; 
                        if(myMPSSLines.size() > 0){
                            MPS.Dirty = false;
                            MPS.Dirtys = false;
                            for(ERP7__MPS_line_Item__c MPSSLine : myMPSSLines){
                                system.debug('MPSSLine : '+MPSSLine);
                                MPSLine MPLine = new MPSLine();
                                MPLine.IssueMO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                MPLine.IssuePO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                MPLine.MPSLine = MPSSLine;
                                MPS.MPSLines.add(MPLine);
                            }
                        }
                        else{
                            MPS.Dirty = true;
                            MPS.Dirtys = true;
                            if(MP.ERP7__Schedule_Period__c == 'Monthly'){ 
                                Date sd = onload;
                                system.debug('sd Monthly: '+sd);
                                Date ed = MP.ERP7__End_Date__c;
                                system.debug('sd ed: '+ed);
                                Integer Months = sd.monthsBetween(ed);
                                system.debug('Months : '+Months);
                                if (ed.day() > sd.day()) Months++;
                                
                                Date current=system.today();
                                Integer currentMonth=current.Month();
                                System.debug('currentMonth : '+currentMonth);
                                Integer i = 0;
                                while(Months > 0){
                                    Integer NewSDMonth = sd.Month() + i;
                                    system.debug('NewSDMonth : '+NewSDMonth);
                                    Integer curMonth = math.mod((sd.Month() + i - 1),12) + 1;
                                        //((sd.Month() + i - 1) % 12) + 1; //((sd.Month()+i) > 12)? (sd.Month()+i-12):(sd.Month()+i);
                                    System.debug('curMonth : '+curMonth);
                                    String name=(curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                                    system.debug('name Months: '+name);
                                    MPSLine MPLine = new MPSLine();
                                    MPLine.IssueMO = MP.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                    MPLine.IssuePO = MP.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = MP.ERP7__Default_Demand_Forecast__c;
                                    Date stDate = sd.AddMonths(i);
                                    system.debug('stDate Months: '+stDate);
                                    Integer lastDay = Date.daysInMonth(stDate.year(), stDate.month());
                                    Date edDate = Date.newInstance(stDate.year(), stDate.month(), lastDay);
                                  //  Date edDate = sd.AddMonths(i+1);
                                    system.debug('edDate Months: '+edDate);
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && ((SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null) || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.Quantity;
                                    system.debug('actualDemand : '+actualDemand);
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    System.debug('actualDemandIndirect : '+actualDemandIndirect);
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    if((curMonth>=currentMonth)) MPLine.display=true; else MPLine.display=false;
                                    system.debug('MPLine.display : '+MPLine.display);
                                    MPS.MPSLines.add(MPLine);
                                    i++;
                                    Months--;
                                }
                            } 
                            else if(MP.ERP7__Schedule_Period__c == 'Weekly'){ 
                                Date sd = onload;
                                sd = sd.toStartOfWeek();
                                Date ed = MP.ERP7__End_Date__c;
                                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                
                                Integer Weeks = sd.daysBetween(ed)/7;
                                if(Math.Mod(Weeks,7) > 0) Weeks++;
                                Integer i = 0;
                                while(Weeks > 0){
                                    String name;
                                    /* if(i>=2) {
name = sdt.addDays((i*7)+1).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+7).format(' dd MMM yyyy');

}
else{
name = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');

}*/
                                    system.debug('name Weeks: '+name);
                                    //String name=sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                                    /* for(ERP7__MPS_line_Item__c MPSSLine : myMPSSLines){
system.debug('MPSSLine.Name Weeks: '+MPSSLine.Name);
if(name==MPSSLine.Name){ MPSLine MPLine = new MPSLine();
MPLine.IssueMO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
MPLine.IssuePO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
MPLine.MPSLine = MPSSLine; MPS.MPSLines.add(MPLine);
}
}*/
                                    MPSLine MPLine = new MPSLine();
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.IssueMO = MP.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                    MPLine.IssuePO = MP.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                    MPLine.MPSLine.Name = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    Date stDate = sd.addDays(i*7);
                                    Date edDate = sd.addDays((i*7)+6);
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) { system.debug('1 : '); if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)){ actualDemand += SOLI.Quantity; system.debug('2 :SOLI.Quantity : '+SOLI.Quantity);}}
                                    system.debug('actualDemand : '+actualDemand);
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    system.debug('actualDemandIndirect : '+actualDemandIndirect);
                                    if(actualDemandIndirect == null) actualDemandIndirect = 0;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    MPS.MPSLines.add(MPLine);
                                    i++;
                                    Weeks--;
                                }
                            }
                            else if(MP.ERP7__Schedule_Period__c == 'Quarterly'){  
                                Date sd = onload;
                                Date ed = MP.ERP7__End_Date__c;
                                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                sd = Date.newInstance(sd.Year(), 1, 1);
                                ed = Date.newInstance(ed.Year()+1, 1, 1)-1;
                                
                                Integer Quarters = (ed.Year() == sd.Year())? 4 : (ed.Year() - sd.Year()+1)*4;
                                Integer i = 0;
                                while(Quarters > 0){
                                    Date stDate = sd.addMonths(i);
                                    Date edDate = sd.addMonths(i*3)-1;
                                    String name='Q'+String.valueOf(i+1)+'-'+stDate.Year();
                                    system.debug('name Quarters: '+name);
                                    MPSLine MPLine = new MPSLine();
                                    // Date stDate = sd.addMonths(i);
                                    //  Date edDate = sd.addMonths(i*3)-1;
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = name;  //'Q'+String.valueOf(i+1)+'-'+stDate.Year();      
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    MPLine.IssueMO = MP.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                    MPLine.IssuePO = MP.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.Quantity;
                                    
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    MPS.MPSLines.add(MPLine);
                                    /*for(ERP7__MPS_line_Item__c MPSSLine : myMPSSLines){
system.debug('MPSSLine.Name Quarters: '+MPSSLine.Name);
if(name==MPSSLine.Name){ MPSLine MPLine = new MPSLine();
MPLine.IssueMO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
MPLine.IssuePO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
MPLine.MPSLine = MPSSLine; MPS.MPSLines.add(MPLine);
}
}*/
                                    i++;
                                    Quarters--;
                                }
                            }
                           /* if(MP.ERP7__Schedule_Period__c == 'Monthly' && MPS.MPSLines.size() > 0){
                                MP.ERP7__Schedule_Period__c = 'Weekly';
                                if(MP.ERP7__Schedule_Period__c == 'Weekly'){ 
                                    Date sd = onload;
                                    sd = sd.toStartOfWeek();
                                    Date ed = MP.ERP7__End_Date__c;
                                    Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                    Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                    
                                    Integer Weeks = sd.daysBetween(ed)/7;
                                    if(Math.Mod(Weeks,7) > 0) Weeks++;
                                    Integer i = 0;
                                    while(Weeks > 0){
                                        String name;
                                        system.debug('name Weeks: '+name);
                                        MPSLine MPLine = new MPSLine();
                                        MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                        MPLine.IssueMO = MP.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                        MPLine.IssuePO = MP.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                        MPLine.MPSLine.Name = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                                        MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                        MPLine.MPSLine.ERP7__Demand_Forecast__c = MP.ERP7__Default_Demand_Forecast__c;
                                        Date stDate = sd.addDays(i*7);
                                        Date edDate = sd.addDays((i*7)+6);
                                        Decimal actualDemand = 0;
                                        for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                        for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) { system.debug('1 : '); if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)){ actualDemand += SOLI.Quantity; system.debug('2 :SOLI.Quantity : '+SOLI.Quantity);}}
                                        system.debug('actualDemand : '+actualDemand);
                                        Decimal actualDemandIndirect = 0;
                                        for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__Expected_Date__c >= stDate && MRP.ERP7__MO__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                        system.debug('actualDemandIndirect : '+actualDemandIndirect);
                                        if(actualDemandIndirect == null) actualDemandIndirect = 0;
                                        MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                        for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__Expected_Date__c >= stDate && MO.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                        for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                        MPS.MPSLines.add(MPLine);
                                        i++;
                                        Weeks--;
                                    }
                                }
                            }*/
                            break;   
                        }
                    }
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    if(MP.ERP7__Master_Production_Schedule__c == mpsId && MP.ERP7__Product__c != MP.ERP7__Master_Production_Schedule__r.ERP7__Product__c) {
                        MPS cMPS = new MPS();
                        List<ERP7__MPS_line_Item__c> myMPSSLines = new List<ERP7__MPS_line_Item__c>();
                        for(ERP7__MPS_line_Item__c MPSSLine : MPSSLines){ if(MP.Id == MPSSLine.ERP7__MPS__c) myMPSSLines.add(MPSSLine); }
                        cMPS.MPS = MP; 
                        system.debug('myMPSSLines 2nd loop : '+myMPSSLines.size());
                        if(myMPSSLines.size() > 0){
                            if(MP.ERP7__Schedule_Period__c=='Weekly'){
                                for(ERP7__MPS_line_Item__c MPSSLine : myMPSSLines){ MPSLine MPLine = new MPSLine(); MPLine.MPSLine = MPSSLine;
                                                                                   MPLine.IssueMO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                                                                   MPLine.IssuePO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                                                                   cMPS.MPSLines.add(MPLine);
                                                                                  }
                            }
                            else if(MP.ERP7__Schedule_Period__c == 'Quarterly'){
                                for(ERP7__MPS_line_Item__c MPSSLine : myMPSSLines){ MPSLine MPLine = new MPSLine(); MPLine.MPSLine = MPSSLine;
                                                                                   MPLine.IssueMO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                                                                   MPLine.IssuePO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                                                                   cMPS.MPSLines.add(MPLine);
                                                                                  }
                            }else{
                                MPS.Dirty = false; MPS.Dirtys = false; Date sd = onload; Date ed = MP.ERP7__End_Date__c; Integer Months = sd.monthsBetween(ed);
                                if (ed.day() > sd.day()) Months++;
                                Integer i = 0;
                                while(Months > 0){
                                    Integer curMonth = ((sd.Month()+i) > 12)? (sd.Month()+i-12):(sd.Month()+i);
                                        //String viewStr = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                                        String name=(curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                                    for(ERP7__MPS_line_Item__c MPSSLine : myMPSSLines){
                                        if(name==MPSSLine.Name){ MPSLine MPLine = new MPSLine(); MPLine.MPSLine = MPSSLine;
                                                                MPLine.IssueMO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c;
                                                                MPLine.IssuePO = MPSSLine.ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c;
                                                                cMPS.MPSLines.add(MPLine);
                                                               }
                                    }
                                    i++;
                                    Months--;
                                }
                            }
                        }
                        else{
                            MPS.Dirty = true; MPS.Dirtys = true; cMPS.MPS = MP;
                            if(MP.ERP7__Schedule_Period__c == 'Monthly'){
                                Date sd = onload;
                                Date ed = MP.ERP7__End_Date__c;
                                Integer Months = sd.monthsBetween(ed);
                                if (ed.day() > sd.day()) Months++;
                                Integer i = 0;
                                while(Months > 0){
                                    Integer NewSDMonth = sd.Month() + i;
                                    system.debug('NewSDMonth : '+NewSDMonth);
                                    Integer curMonth = ((sd.Month()+i) > 12)? (sd.Month()+i-12):(sd.Month()+i);
                                        system.debug('curMonth : '+curMonth);
                                    MPSLine MPLine = new MPSLine();
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    Date stDate = sd.AddMonths(i);
                                    Integer lastDay = Date.daysInMonth(stDate.year(), stDate.month());
                                    Date edDate = Date.newInstance(stDate.year(), stDate.month(), lastDay);
                                    //Date edDate = sd.AddMonths(i+1);
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem OLI : productOrderItemLines.get(MP.ERP7__Product__c)){ system.debug('1'); if(OLI.Order.ERP7__Expected_Date__c >= stDate && OLI.Order.ERP7__Expected_Date__c <= edDate && (OLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == OLI.ERP7__Version__c)){ system.debug('OLI.Quantity : '+OLI.Quantity);  actualDemand += OLI.Quantity;} }
                                    system.debug('actualDemand : '+actualDemand);
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    cMPS.MPSLines.add(MPLine);
                                    i++; 
                                    Months--;
                                }
                            }
                            else if(MP.ERP7__Schedule_Period__c == 'Weekly'){ 
                                Date sd = MP.ERP7__Start_Date__c; Date ed = MP.ERP7__End_Date__c;
                                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                sd = sd.toStartOfWeek(); Integer Weeks = sd.daysBetween(ed)/7;
                                if(Math.Mod(Weeks,7) > 0) Weeks++;
                                Integer i = 0;
                                system.debug('Weeks : '+Weeks);
                                while(Weeks > 0){
                                    MPSLine MPLine = new MPSLine();
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    Date stDate = sd.addDays(i*7); Date edDate = sd.addDays((i*7)+6); Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem OLI : productOrderItemLines.get(MP.ERP7__Product__c)){ system.debug('1'); if(OLI.Order.ERP7__Expected_Date__c >= stDate && OLI.Order.ERP7__Expected_Date__c <= edDate && (OLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == OLI.ERP7__Version__c)){ system.debug('OLI.Quantity : '+OLI.Quantity);  actualDemand += OLI.Quantity;} }
                                    system.debug('actualDemand : '+actualDemand);
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    cMPS.MPSLines.add(MPLine);
                                    i++;
                                    Weeks--;
                                }
                            }
                            else if(MP.ERP7__Schedule_Period__c == 'Quarterly'){ 
                                Date sd = MP.ERP7__Start_Date__c; Date ed = MP.ERP7__End_Date__c;
                                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                                sd = Date.newInstance(sd.Year(), 1, 1); ed = Date.newInstance(ed.Year()+1, 1, 1)-1;
                                
                                Integer Quarters = (ed.Year() == sd.Year())? 4 : (ed.Year() - sd.Year()+1)*4;
                                Integer i = 0;
                                while(Quarters > 0){
                                    MPSLine MPLine = new MPSLine();
                                    Date stDate = sd.addMonths(i); Date edDate = sd.addMonths(i*3)-1;
                                    MPLine.MPSLine.ERP7__MPS__c = MP.Id;
                                    MPLine.MPSLine.Name = 'Q'+String.valueOf(i+1)+'-'+stDate.Year();     
                                    MPLine.MPSLine.ERP7__Line_Count__c = i+1;
                                    MPLine.MPSLine.ERP7__Demand_Forecast__c = 0;//MP.ERP7__Default_Demand_Forecast__c;
                                    
                                    Decimal actualDemand = 0;
                                    for(ERP7__Sales_Order_Line_Item__c SOLI : productOrderLines.get(MP.ERP7__Product__c)) if(SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= stDate && SOLI.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.ERP7__Quantity__c;
                                    for(OrderItem SOLI : productOrderItemLines.get(MP.ERP7__Product__c)) if(SOLI.Order.ERP7__Expected_Date__c >= stDate && SOLI.Order.ERP7__Expected_Date__c <= edDate && (SOLI.ERP7__Version__c == null || MP.ERP7__Version__c == Null || MP.ERP7__Version__c == SOLI.ERP7__Version__c)) actualDemand += SOLI.Quantity;
                                    
                                    Decimal actualDemandIndirect = 0;
                                    for(ERP7__MRP__c MRP : productMRPS.get(MP.ERP7__Product__c)) if(MRP.ERP7__MO__r.ERP7__ExpectedDate__c >= stDate && MRP.ERP7__MO__r.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MRP.ERP7__Version__c)) actualDemandIndirect += MRP.ERP7__Total_Amount_Required__c;
                                    MPLine.MPSLine.ERP7__Actual_Demand__c = actualDemand + actualDemandIndirect;
                                    for(ERP7__Manufacturing_Order__c MO : productMOS.get(MP.ERP7__Product__c)) if(MO.ERP7__ExpectedDate__c >= stDate && MO.ERP7__ExpectedDate__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    for(ERP7__Purchase_Line_Items__c MO : productPOLines.get(MP.ERP7__Product__c)) if(MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= stDate && MO.ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= edDate && (MP.ERP7__Version__c == Null || MP.ERP7__Version__c == MO.ERP7__Version__c)) MPLine.OrderedQuantity += MO.ERP7__Quantity__c;
                                    cMPS.MPSLines.add(MPLine);
                                    i++;
                                    Quarters--;
                                }
                            }
                        }
                        system.debug('cMPS.MPSLines.size() : '+cMPS.MPSLines.size());
                        MPS.MPSS.add(cMPS);                
                    }
                }
            }
            
            Schema.DescribeFieldResult fieldResult = ERP7__MPS__c.ERP7__Schedule_Period__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f: ple) { MPS.mpsStatus.add(new SelectOptions(f.getLabel(), f.getValue())); } } catch(Exception e) {  MPS.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }
            MPS.InitialDate=system.Today();
            return MPS;
    }
    
    @AuraEnabled
    public static MPS Evaluates(String StrMPS){
        MPS MPS = (MPS) JSON.deserialize(StrMPS, MPS .class);
        try{
            MPS.errMsg = '';
            for(Integer i = 0; i < MPS.MPSLines.size(); i++){
                MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c = (i==0) ? (MPS.MPS.ERP7__Starting_Inventory__c -(MPS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c) + MPS.MPS.ERP7__Minimum_Inventory_Level__c) : (MPS.MPSLines[i-1].MPSLine.ERP7__Projected_Inventory__c - (MPS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c));
                MPS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c = ((MPS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c) == 0) ? 0 : (MPS.MPS.ERP7__Lot_Size__c > ((MPS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c) - MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c)) ? MPS.MPS.ERP7__Lot_Size__c : ((MPS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c) - MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c);
                MPS.MPSLines[i].MPSLine.ERP7__Projected_Inventory__c = MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c + MPS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c;
                MPS.MPSLines[i].MPSLine.ERP7__Available_To_Promise__c = (MPS.MPSLines[i].MPSLine.ERP7__Projected_Inventory__c) - (MPS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c);
               }
           /*   for(Integer i = 0; i < MPS.MPSLines.size(); i++){
                MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c = (i==0)? (MPS.MPS.ERP7__Starting_Inventory__c-math.Max(MPS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c,MPS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c)) : MPS.MPSLines[i-1].MPSLine.ERP7__Projected_Inventory__c-math.Max(MPS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c,MPS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c);
                System.debug('MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c : '+MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c);
                MPS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c = (MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c < MPS.MPS.ERP7__Minimum_Inventory_Level__c)? MPS.MPS.ERP7__Lot_Size__c : 0;
                System.debug('MPS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c : '+MPS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c);
                MPS.MPSLines[i].MPSLine.ERP7__Projected_Inventory__c = MPS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c + MPS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c;
                System.debug('MPS.MPSLines[i].MPSLine.ERP7__Projected_Inventory__c : '+MPS.MPSLines[i].MPSLine.ERP7__Projected_Inventory__c);
            }          
          for(Integer k = 0; k < MPS.MPSLines.size(); k++){
                MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c = MPS.MPSLines[k].MPSLine.ERP7__To_Supply_Manufacture__c;
                system.debug('MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c 1: '+MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c);
                if(k == 0) MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c += MPS.MPS.ERP7__Starting_Inventory__c;
                system.debug('MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c 2: '+MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c);
                MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c -= MPS.MPSLines[k].MPSLine.ERP7__Actual_Demand__c;
                system.debug('MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c 3: '+MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c);
                for(Integer j = k; j < MPS.MPSLines.size(); j++){
                    system.debug('J : '+j);
                    system.debug('K : '+k);
                    system.debug('MPS.MPSLines[j].MPSLine.ERP7__To_Supply_Manufacture__c 4 11: '+MPS.MPSLines[j].MPSLine.ERP7__To_Supply_Manufacture__c);
                    if(MPS.MPSLines[j].MPSLine.ERP7__To_Supply_Manufacture__c > 0) { break; }
                    else { 
                        system.debug('MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c 4 12: '+MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c);
                        system.debug('MPS.MPSLines[k].MPSLine.ERP7__Actual_Demand__c 4 13: '+MPS.MPSLines[j].MPSLine.ERP7__Actual_Demand__c);
                        MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c -= MPS.MPSLines[j].MPSLine.ERP7__Actual_Demand__c; 
                    }
                    system.debug('MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c 4: '+MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c);
                }
                system.debug('MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c INNNNN: '+MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c);
            }   */
            system.debug('MPS.MPSS : '+MPS.MPSS.size());
            for(MPS MPSS : MPS.MPSS){
                ERP7__MPS__c MP = MPSS.MPS;
                for(Integer i = 0; i < MPSS.MPSLines.size(); i++){
                    MPSS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c = (i==0) ? (MPSS.MPS.ERP7__Starting_Inventory__c -(MPSS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPSS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c) + MPSS.MPS.ERP7__Minimum_Inventory_Level__c) : (MPSS.MPSLines[i-1].MPSLine.ERP7__Projected_Inventory__c - (MPSS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPSS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c));
                    MPSS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c = ((MPSS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPSS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c) == 0) ? 0 : (MPSS.MPS.ERP7__Lot_Size__c > ((MPSS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPSS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c) - MPSS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c)) ? MPSS.MPS.ERP7__Lot_Size__c : ((MPSS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPSS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c) - MPSS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c);
                    MPSS.MPSLines[i].MPSLine.ERP7__Projected_Inventory__c = MPSS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c + MPSS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c;
                    MPSS.MPSLines[i].MPSLine.ERP7__Available_To_Promise__c = (MPSS.MPSLines[i].MPSLine.ERP7__Projected_Inventory__c) - (MPSS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c + MPSS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c);
                }
               /* for(Integer i = 0; i < MPSS.MPSLines.size(); i++){
                    MPSS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c = (i==0)? (MPSS.MPS.ERP7__Starting_Inventory__c-math.Max(MPSS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c, MPSS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c)) : MPSS.MPSLines[i-1].MPSLine.ERP7__Projected_Inventory__c-math.Max(MPSS.MPSLines[i].MPSLine.ERP7__Demand_Forecast__c, MPSS.MPSLines[i].MPSLine.ERP7__Actual_Demand__c);
                    MPSS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c = (MPSS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c < MPSS.MPS.ERP7__Minimum_Inventory_Level__c)? MPSS.MPS.ERP7__Lot_Size__c : 0;
                    MPSS.MPSLines[i].MPSLine.ERP7__Projected_Inventory__c = MPSS.MPSLines[i].MPSLine.ERP7__Net_Inventory_Before_Supply_Produce__c + MPSS.MPSLines[i].MPSLine.ERP7__To_Supply_Manufacture__c;
                }           
                for(Integer k = 0; k < MPSS.MPSLines.size(); k++){
                    MPSS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c = MPSS.MPSLines[k].MPSLine.ERP7__To_Supply_Manufacture__c;
                    
                    if(k == 0) MPSS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c += MP.ERP7__Starting_Inventory__c;
                    MPSS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c -= MPSS.MPSLines[k].MPSLine.ERP7__Actual_Demand__c;
                    for(Integer j = k; j < MPSS.MPSLines.size(); j++){
                        if(MPSS.MPSLines[j].MPSLine.ERP7__To_Supply_Manufacture__c > 0) break;
                        else MPSS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c -= MPSS.MPSLines[j].MPSLine.ERP7__Actual_Demand__c;
                        system.debug('MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c 8: '+MPS.MPSLines[k].MPSLine.ERP7__Available_To_Promise__c);
                    }
                }    */               
            }
        } catch(Exception e) { MPS.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return MPS;
    }
    
    @AuraEnabled
    public static MPS Saves(String StrMPS){
        MPS MPS = (MPS) JSON.deserialize(StrMPS, MPS .class);
        try{
            MPS.errMsg = '';
            List<ERP7__MPS_line_Item__c> MPSLines2upsert = new List<ERP7__MPS_line_Item__c>();
            for(Integer i = 0; i < MPS.MPSLines.size(); i++) MPSLines2upsert.add(MPS.MPSLines[i].MPSLine);          
            for(MPS MPSS : MPS.MPSS) for(Integer i = 0; i < MPSS.MPSLines.size(); i++) MPSLines2upsert.add(MPSS.MPSLines[i].MPSLine);              
            if(MPSLines2upsert.size() > 0 && Schema.SObjectType.ERP7__MPS_line_Item__c.isCreateable() && Schema.SObjectType.ERP7__MPS_line_Item__c.isUpdateable()){upsert MPSLines2upsert;}else{MPS.errMsg ='Not allowed to upsert MPS Line';}
        } catch(Exception e) { MPS.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return MPS;
    }
    
    @AuraEnabled
    public static MPS SavesMPS(String StrMPS){
        MPS MPS = (MPS) JSON.deserialize(StrMPS, MPS .class);
        try{
            MPS.errMsg = '';
            if(Schema.SObjectType.ERP7__MPS__c.isCreateable() && Schema.SObjectType.ERP7__MPS__c.isUpdateable()){upsert MPS.MPS;}else{MPS.errMsg ='Not allowed to upsert MPS';}
            MPS = getAll(MPS.MPS.Id);} catch(Exception e) { MPS.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return MPS;
    }
    
    @AuraEnabled
    public static String MO_WO_URL(String RecId){
        String strURL = '';
        try{
            String mpsLineFields = UtilClass.selectStarFromSObject('ERP7__MPS_line_Item__c');
            utilClass.FLSCheck(mpsLineFields.split(','),'ERP7__MPS_line_Item__c');
            String query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c from ERP7__MPS_line_Item__c where Id =: RecId ';
            List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
            if(MPSSLines.size() > 0){ if(MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Purchase_Order__c) strURL = '/apex/ERP7__CreatePurchaseOrderLC?mpslineId='+MPSSLines[0].Id;  else if(MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c) strURL = '/apex/ERP7__ManufacturingOrderLC?mpslineId='+MPSSLines[0].Id; } } catch(Exception e) { }
        return strURL;
    }
    
    @AuraEnabled
    public static MPS getAllStockRunRate(String currentMPS, String IsNew){
        MPS MPS = new MPS();
        if(IsNew == 'false'){
            MPS = (MPS) JSON.deserialize(currentMPS, MPS .class);
            MPS.MPSS = new List<MPS>();
            MPS.viewStr = new List<String>();
        }
        if(IsNew == 'true'){
            Schema.DescribeFieldResult fieldResult = ERP7__MPS__c.ERP7__Schedule_Period__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f: ple) {  MPS.mpsStatus.add(new SelectOptions(f.getLabel(), f.getValue()));
                                             }
            MPS.MPS.ERP7__Schedule_Period__c = 'Monthly';
        }
        try{
            String mpsFields = UtilClass.selectStarFromSObject('ERP7__MPS__c');
            mpsFields += ' ,ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Bill_Of_Material__r.ERP7__Quantity__c ';
            utilClass.FLSCheck(mpsFields.split(','),'ERP7__MPS__c');    
            String mpsLineFields = UtilClass.selectStarFromSObject('ERP7__MPS_line_Item__c');
            utilClass.FLSCheck(mpsLineFields.split(','),'ERP7__MPS_line_Item__c');
            
            Date sd = MPS.InitialDate;//MPS.StartDate;
            system.debug('MPS.InitialDate : '+MPS.InitialDate);
            Date ed = MPS.EndDate;
            system.debug('MPS.EndDate : '+MPS.EndDate);
            Id DC = MPS.MPS.ERP7__Distribution_Channel__c;
            system.debug('DC : '+DC);
            if(MPS.MPS.ERP7__Schedule_Period__c == 'Monthly'){
                Integer Months = sd.monthsBetween(ed);
                if (ed.day() > sd.day()) Months++;
                Integer i = 0;
                while(Months > 0){
                    Integer curMonth = ((sd.Month()+i) > 12)? (sd.Month()+i-12):(sd.Month()+i);
                        String viewStr = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                    Date tempEd = sd.addMonths(i);
                    viewStr += ' '+String.valueof(tempEd.year());
                    MPS.viewStr.add(viewStr);    
                    i++;
                    Months--;
                }
                String str = ''; //MPS.searchString;
                str = '%'+str+'%';
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where ERP7__Start_Date__c <= :sd And ERP7__End_Date__c >= :ed And ERP7__Product__r.Name like :str And ERP7__Schedule_Period__c = \'Monthly\' ';
                if(DC != null) query += ' And ERP7__Distribution_Channel__c = :DC Order by ERP7__Product__r.Name Asc limit 1000';
                else query += ' Order by ERP7__Product__r.Name Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c from ERP7__MPS_line_Item__c where ERP7__MPS__c In : MPSS Order By ERP7__Line_Count__c Asc';
                List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
                Map<Id, List<ERP7__MPS_line_Item__c>> myMPSSLines = new Map<Id, List<ERP7__MPS_line_Item__c>>();
                for(ERP7__MPS__c MP : MPSS){
                    List<ERP7__MPS_line_Item__c> myLines = new List<ERP7__MPS_line_Item__c>();
                    for(ERP7__MPS_line_Item__c MPLine : MPSSLines){
                        if(MP.Id == MPLine.ERP7__MPS__c) {
                            myLines.add(MPLine);
                        }
                    }
                    myMPSSLines.put(MP.Id,myLines);
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    List<MPSLine> myLines = new List<MPSLine>();
                    Map<String, MPSLine> vsMPSLine = new Map<String, MPSLine>();
                    for(ERP7__MPS_line_Item__c MPLine : myMPSSLines.get(MP.Id)){
                        if(MP.Id == MPLine.ERP7__MPS__c){
                            MPSLine MLine = new MPSLine();
                            MLine.MPSLine = MPLine;
                            Decimal curMonth = MP.ERP7__Start_Date__c.month()+MPLine.ERP7__Line_Count__c-1;
                            MLine.viewStr = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                            MLine.viewStr += ' '+String.valueof(MP.ERP7__Start_Date__c.year());
                            vsMPSLine.put(MLine.viewStr,MLine);
                        }
                    }
                    if(vsMPSLine.size() > 0){
                        for(String vs : MPS.viewStr){
                            MPSLine MLine = (vsMPSLine.containsKey(vs))? vsMPSLine.get(vs) : new MPSLine();
                            MLine.viewStr = vs; myLines.add(MLine);
                        }
                        MPS cMPS = new MPS(); cMPS.MPS = MP; cMPS.searchString = MP.Name +' '+MP.ERP7__Product__r.Name;
                        cMPS.MPSLines = myLines; MPS.MPSS.add(cMPS);
                    }
                }
            }
            else if(MPS.MPS.ERP7__Schedule_Period__c == 'Weekly'){
                sd = sd.toStartOfWeek();
                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                Integer Weeks = sd.daysBetween(ed)/7;
                if(Math.Mod(Weeks,7) > 0) Weeks++;
                Integer i = 0;
                while(Weeks > 0){
                    if(i>=2) {
                        String viewStr = sdt.addDays((i*7)+1).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+7).format(' dd MMM yyyy');
                        MPS.viewStr.add(viewStr);    
                        i++;
                        Weeks--;
                    }
                    else{
                        String viewStr = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                        MPS.viewStr.add(viewStr);    
                        i++;
                        Weeks--;
                    }
                }
                String str = ''; //MPS.searchString;
                str = '%'+str+'%';
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where ERP7__Start_Date__c <= :sd And ERP7__End_Date__c >= :ed And ERP7__Product__r.Name like :str  And ERP7__Schedule_Period__c = \'Weekly\' ';
                if(DC != null) query += ' And ERP7__Distribution_Channel__c = :DC Order by ERP7__Product__r.Name Asc limit 1000';
                else query += ' Order by ERP7__Product__r.Name Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c from ERP7__MPS_line_Item__c where ERP7__MPS__c In : MPSS Order By ERP7__Line_Count__c Asc';
                List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
                
                Map<Id, List<ERP7__MPS_line_Item__c>> myMPSSLines = new Map<Id, List<ERP7__MPS_line_Item__c>>();
                for(ERP7__MPS__c MP : MPSS){
                    List<ERP7__MPS_line_Item__c> myLines = new List<ERP7__MPS_line_Item__c>();
                    for(ERP7__MPS_line_Item__c MPLine : MPSSLines){ if(MP.Id == MPLine.ERP7__MPS__c) { myLines.add(MPLine); } }
                    myMPSSLines.put(MP.Id,myLines);
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    List<MPSLine> myLines = new List<MPSLine>(); Map<String, MPSLine> vsMPSLine = new Map<String, MPSLine>();
                    for(ERP7__MPS_line_Item__c MPLine : myMPSSLines.get(MP.Id)){
                        if(MP.Id == MPLine.ERP7__MPS__c){ MPSLine MLine = new MPSLine(); MLine.MPSLine = MPLine; MLine.viewStr = MPLine.Name; vsMPSLine.put(MLine.viewStr,MLine); }
                    }
                    if(vsMPSLine.size() > 0){
                        for(String vs : MPS.viewStr){ MPSLine MLine = (vsMPSLine.containsKey(vs))? vsMPSLine.get(vs) : new MPSLine(); MLine.viewStr = vs; myLines.add(MLine);
                                                    }
                        MPS cMPS = new MPS(); cMPS.MPS = MP; cMPS.searchString = MP.Name +' '+MP.ERP7__Product__r.Name; cMPS.MPSLines = myLines;
                        MPS.MPSS.add(cMPS);
                    }
                }
                
            }
            else if(MPS.MPS.ERP7__Schedule_Period__c == 'quarterly'){
                /*Integer Months = sd.monthsBetween(ed);
Integer days=sd.daysBetween(ed);
Double QuartersDynamic=Math.floor(days/30);
if (ed.day() > sd.day()) Months++;
sd = Date.newInstance(sd.Year(), 1, 1);
ed = Date.newInstance(ed.Year()+1, 1, 1)-1;
Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
Integer Quarters = (ed.Year() == sd.Year())? 4 : (ed.Year() - sd.Year()+1)*4;
Integer curMonth = sd.Month();
Integer endMonth = ed.Month();
//String startMonth=(curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
//String endMonth=(endMonth == 1)? 'Jan' : (endMonth == 2)? 'Feb' : (endMonth == 3)? 'Mar' : (endMonth == 4)? 'Apr' : (endMonth == 5)? 'May' : (endMonth == 6)? 'Jun' : (endMonth == 7)? 'Jul' : (endMonth == 8)? 'Aug' : (endMonth == 9)? 'Sep' : (endMonth == 10)? 'Oct' : (endMonth == 11)? 'Nov' : 'Dec';
Integer difference=endMonth-curMonth;
Integer currentQ =((difference-1)/3) + 1;
//FLOOR (((YEAR (B2)*12+MONTH (B2))- (YEAR (A2)*12+MONTH (A2)))/3,1)


//if(curMonth==endMonth)
Integer i = 0;
if(Months>=3){
Quarters=1;
}
Integer Quarters2;
if(Months<=6 && Months>3){
Quarters2=2;
}
if(Quarters==1){
String viewStr = 'Q4'+'-'+sd.addMonths(i*3).Year(); 
MPS.viewStr.add(viewStr);
}
if(Quarters2==2){
String viewStr = 'Q3'+'-'+sd.addMonths(i*3).Year(); 
MPS.viewStr.add(viewStr);
}
/*while(Quarters > 0){
String viewStr = 'Q'+((math.mod((i+4),4) == 0)? 4 : math.mod((i+1),4))+'-'+sd.addMonths(i*3).Year(); 
MPS.viewStr.add(viewStr);    
i++;
Quarters--;
}*/
                
                
                //sd = Date.newInstance(sd.Year()-1, 1, 1);
                //ed = Date.newInstance(ed.Year()+1, 1, 1)-1;
                //sd = Date.newInstance(sd.Year()-1, 1, 1);
                Date sdt=Date.newInstance(sd.Year(), 1, 1);
                Date edt=Date.newInstance(sd.Year(), 3, 31);
                Date edt2=Date.newInstance(sd.Year(), 6, 30);
                Date edt3=Date.newInstance(sd.Year(), 9, 30);
                Date edt4=Date.newInstance(sd.Year(), 12, 31);
                if((sd>=sdt) && (ed<=edt)) { String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year(); MPS.viewStr.add(viewStr);
                                           }else if((sd>=sdt && sd<=edt) && (ed>edt && ed<=edt2)) {
                                               //String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year();
                                               MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
                                               //String viewStr2 = 'Q2'+'-'+sd.addMonths(1*3).Year();
                                               MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
                                           }
                else if((sd>=sdt && sd<=edt2) && (ed>edt2 && ed<=edt3)) {
                    //String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year();
                    MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr2 = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
                    //String viewStr3 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(2*3).Year());
                }
                else if((sd>=sdt && sd<=edt3) && (ed>edt3 && ed<=edt4)) {
                    //String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year();
                    MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr2 = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
                    //String viewStr3 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(2*3).Year());
                    //String viewStr4 = 'Q4'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(3*3).Year());
                }
                else if((sd>edt && sd<=edt2) && (ed>edt && ed<=edt2)){
                    //String viewStr = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(0*3).Year());
                }
                else if((sd>edt && ed>edt2 && sd<=edt2) && ed<=edt3){
                    //String viewStr2 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr3 = 'Q4'+'-'+sd.addMonths(3*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(1*3).Year());
                }
                else if((sd>=edt && ed>edt3 && sd<=edt2) && ed<=edt4){
                    //String viewStr = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr2 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(1*3).Year());
                    //String viewStr3 = 'Q4'+'-'+sd.addMonths(3*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(2*3).Year());
                }
                else if((sd>edt2 && ed>edt2 && sd<=edt2) && ed<=edt3){
                    //String viewStr2 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr3 = 'Q4'+'-'+sd.addMonths(3*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(1*3).Year());
                }
                else if((sd>edt2 && ed>edt3) && ed<=edt4){
                    //String viewStr3 = 'Q4'+'-'+sd.addMonths(3*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(0*3).Year());
                }
                else{
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(0*3).Year());
                }
                
                String str = ''; 
                str = '%'+str+'%';
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where ERP7__Start_Date__c <= :sd And ERP7__End_Date__c >= :ed And ERP7__Product__r.Name like :str  And ERP7__Schedule_Period__c = \'quarterly\' ';
                if(DC != null) query += ' And ERP7__Distribution_Channel__c = :DC Order by ERP7__Product__r.Name Asc limit 1000';
                else query += ' Order by ERP7__Product__r.Name Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                
                query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c from ERP7__MPS_line_Item__c where ERP7__MPS__c In : MPSS Order By ERP7__Line_Count__c Asc';
                List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
                
                Map<Id, List<ERP7__MPS_line_Item__c>> myMPSSLines = new Map<Id, List<ERP7__MPS_line_Item__c>>();
                for(ERP7__MPS__c MP : MPSS){
                    List<ERP7__MPS_line_Item__c> myLines = new List<ERP7__MPS_line_Item__c>();
                    for(ERP7__MPS_line_Item__c MPLine : MPSSLines){
                        if(MP.Id == MPLine.ERP7__MPS__c) {
                            myLines.add(MPLine);
                        }
                    }
                    myMPSSLines.put(MP.Id,myLines);
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    List<MPSLine> myLines = new List<MPSLine>();
                    Map<String, MPSLine> vsMPSLine = new Map<String, MPSLine>();
                    for(ERP7__MPS_line_Item__c MPLine : myMPSSLines.get(MP.Id)){
                        if(MP.Id == MPLine.ERP7__MPS__c){
                            MPSLine MLine = new MPSLine();
                            MLine.MPSLine = MPLine;
                            MLine.viewStr = MPLine.Name;
                            vsMPSLine.put(MLine.viewStr,MLine);
                        }
                    }
                    if(vsMPSLine.size() > 0){
                        for(String vs : MPS.viewStr){
                            MPSLine MLine = (vsMPSLine.containsKey(vs))? vsMPSLine.get(vs) : new MPSLine();
                            MLine.viewStr = vs;
                            myLines.add(MLine);
                        }
                        MPS cMPS = new MPS();
                        cMPS.MPS = MP;
                        cMPS.searchString = MP.Name +' '+MP.ERP7__Product__r.Name;
                        cMPS.MPSLines = myLines;
                        MPS.MPSS.add(cMPS);
                    }
                }
            }
        } catch(Exception e) { MPS.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        //MPS = Evaluates(JSON.serialize(MPS));
        return MPS;
    }
    
    @AuraEnabled
    public static MPS getAllStockRunRateOnDate(String currentMPS, String IsNew){
        MPS MPS = new MPS();
        if(IsNew == 'false'){
            MPS = (MPS) JSON.deserialize(currentMPS, MPS .class);
            MPS.MPSS = new List<MPS>();
            MPS.viewStr = new List<String>();
        }
        if(IsNew == 'true'){
            Schema.DescribeFieldResult fieldResult = ERP7__MPS__c.ERP7__Schedule_Period__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f: ple) {
                MPS.mpsStatus.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            MPS.MPS.ERP7__Schedule_Period__c = 'Monthly';
        }
        try{
            String mpsFields = UtilClass.selectStarFromSObject('ERP7__MPS__c');
            mpsFields += ' ,ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Bill_Of_Material__r.ERP7__Quantity__c ';
            utilClass.FLSCheck(mpsFields.split(','),'ERP7__MPS__c');    
            String mpsLineFields = UtilClass.selectStarFromSObject('ERP7__MPS_line_Item__c');
            utilClass.FLSCheck(mpsLineFields.split(','),'ERP7__MPS_line_Item__c');
            
            Date sd = MPS.InitialDate;//MPS.StartDate;
            Date ed = MPS.EndDate;
            Id DC = MPS.MPS.ERP7__Distribution_Channel__c;
            if(MPS.MPS.ERP7__Schedule_Period__c == 'Monthly'){
                Integer Months = sd.monthsBetween(ed);
                if (ed.day() > sd.day()) Months++;
                Integer i = 0;
                while(Months > 0){
                    Integer curMonth = ((sd.Month()+i) > 12)? (sd.Month()+i-12):(sd.Month()+i);
                        String viewStr = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                    Date tempEd = sd.addMonths(i);
                    viewStr += ' '+String.valueof(tempEd.year());
                    MPS.viewStr.add(viewStr);    
                    i++;
                    Months--;
                }
                String str = ''; //MPS.searchString;
                str = '%'+str+'%';
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where ERP7__Start_Date__c <= :sd And ERP7__End_Date__c >= :ed And ERP7__Product__r.Name like :str And ERP7__Schedule_Period__c = \'Monthly\' ';
                if(DC != null) query += ' And ERP7__Distribution_Channel__c = :DC Order by ERP7__Product__r.Name Asc limit 1000';
                else query += ' Order by ERP7__Product__r.Name Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c from ERP7__MPS_line_Item__c where ERP7__MPS__c In : MPSS Order By ERP7__Line_Count__c Asc';
                List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
                Map<Id, List<ERP7__MPS_line_Item__c>> myMPSSLines = new Map<Id, List<ERP7__MPS_line_Item__c>>();
                for(ERP7__MPS__c MP : MPSS){
                    List<ERP7__MPS_line_Item__c> myLines = new List<ERP7__MPS_line_Item__c>();
                    for(ERP7__MPS_line_Item__c MPLine : MPSSLines){
                        if(MP.Id == MPLine.ERP7__MPS__c) {
                            myLines.add(MPLine);
                        }
                    }
                    myMPSSLines.put(MP.Id,myLines);
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    List<MPSLine> myLines = new List<MPSLine>();
                    Map<String, MPSLine> vsMPSLine = new Map<String, MPSLine>();
                    for(ERP7__MPS_line_Item__c MPLine : myMPSSLines.get(MP.Id)){
                        if(MP.Id == MPLine.ERP7__MPS__c){
                            MPSLine MLine = new MPSLine();
                            MLine.MPSLine = MPLine;
                            Decimal curMonth = MP.ERP7__Start_Date__c.month()+MPLine.ERP7__Line_Count__c-1;
                            MLine.viewStr = (curMonth == 1)? 'Jan' : (curMonth == 2)? 'Feb' : (curMonth == 3)? 'Mar' : (curMonth == 4)? 'Apr' : (curMonth == 5)? 'May' : (curMonth == 6)? 'Jun' : (curMonth == 7)? 'Jul' : (curMonth == 8)? 'Aug' : (curMonth == 9)? 'Sep' : (curMonth == 10)? 'Oct' : (curMonth == 11)? 'Nov' : 'Dec';
                            MLine.viewStr += ' '+String.valueof(MP.ERP7__Start_Date__c.year());
                            vsMPSLine.put(MLine.viewStr,MLine);
                        }
                    }
                    if(vsMPSLine.size() > 0){
                        for(String vs : MPS.viewStr){
                            MPSLine MLine = (vsMPSLine.containsKey(vs))? vsMPSLine.get(vs) : new MPSLine();
                            MLine.viewStr = vs; myLines.add(MLine);
                        }
                        MPS cMPS = new MPS(); cMPS.MPS = MP; cMPS.searchString = MP.Name +' '+MP.ERP7__Product__r.Name; 
                        cMPS.MPSLines = myLines; MPS.MPSS.add(cMPS);
                    }
                }
            }
            else if(MPS.MPS.ERP7__Schedule_Period__c == 'Weekly'){
                sd = sd.toStartOfWeek();
                Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
                Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);
                Integer Weeks = sd.daysBetween(ed)/7;
                if(Math.Mod(Weeks,7) > 0) Weeks++;
                Integer i = 0;
                while(Weeks > 0){
                    String viewStr = sdt.addDays(i*7).format('dd MMM yyyy ') +'-'+sdt.addDays((i*7)+6).format(' dd MMM yyyy');
                    MPS.viewStr.add(viewStr);    
                    i++;
                    Weeks--;
                }
                String str = ''; //MPS.searchString;
                str = '%'+str+'%';
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where ERP7__Start_Date__c <= :sd And ERP7__End_Date__c >= :ed And ERP7__Product__r.Name like :str  And ERP7__Schedule_Period__c = \'Weekly\' ';
                if(DC != null) query += ' And ERP7__Distribution_Channel__c = :DC Order by ERP7__Product__r.Name Asc limit 1000';
                else query += ' Order by ERP7__Product__r.Name Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c from ERP7__MPS_line_Item__c where ERP7__MPS__c In : MPSS Order By ERP7__Line_Count__c Asc';
                List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
                
                Map<Id, List<ERP7__MPS_line_Item__c>> myMPSSLines = new Map<Id, List<ERP7__MPS_line_Item__c>>();
                for(ERP7__MPS__c MP : MPSS){
                    List<ERP7__MPS_line_Item__c> myLines = new List<ERP7__MPS_line_Item__c>();
                    for(ERP7__MPS_line_Item__c MPLine : MPSSLines){
                        if(MP.Id == MPLine.ERP7__MPS__c) { myLines.add(MPLine); }
                    }
                    myMPSSLines.put(MP.Id,myLines);
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    List<MPSLine> myLines = new List<MPSLine>();
                    Map<String, MPSLine> vsMPSLine = new Map<String, MPSLine>();
                    for(ERP7__MPS_line_Item__c MPLine : myMPSSLines.get(MP.Id)){
                        if(MP.Id == MPLine.ERP7__MPS__c){ MPSLine MLine = new MPSLine();
                                                         MLine.MPSLine = MPLine; MLine.viewStr = MPLine.Name;
                                                         vsMPSLine.put(MLine.viewStr,MLine);
                                                        }
                    }
                    if(vsMPSLine.size() > 0){
                        for(String vs : MPS.viewStr){
                            MPSLine MLine = (vsMPSLine.containsKey(vs))? vsMPSLine.get(vs) : new MPSLine();
                            MLine.viewStr = vs; myLines.add(MLine);
                        }
                        MPS cMPS = new MPS(); cMPS.MPS = MP; cMPS.searchString = MP.Name +' '+MP.ERP7__Product__r.Name;
                        cMPS.MPSLines = myLines; MPS.MPSS.add(cMPS);
                    }
                }
                
            }
            else if(MPS.MPS.ERP7__Schedule_Period__c == 'quarterly'){
                /*Integer Months = sd.monthsBetween(ed);
if (ed.day() > sd.day()) Months++;
sd = Date.newInstance(sd.Year(), 1, 1);
ed = Date.newInstance(ed.Year()+1, 1, 1)-1;
Datetime sdt = Datetime.newInstance(sd.year(), sd.Month(), sd.Day(), 0, 0, 0);
Datetime edt = Datetime.newInstance(ed.year(), ed.Month(), ed.Day(), 0, 0, 0);

Integer Quarters = (ed.Year() == sd.Year())? 4 : (ed.Year() - sd.Year()+1)*4;
Integer curMonth = sd.Month();
Integer endMonth = ed.Month();
//if(curMonth==endMonth)
Integer i = 0;
if(Months>=3){
Quarters=1;
}
Integer Quarters2;
if(Months<=6 && Months>3){
Quarters2=2;
}

if(Quarters2==2){
String viewStr = 'Q3'+'-'+sd.addMonths(i*3).Year(); 
MPS.viewStr.add(viewStr);
}
if(Quarters==1){
String viewStr = 'Q4'+'-'+sd.addMonths(i*3).Year(); 
MPS.viewStr.add(viewStr);
}
/*while(Quarters > 0){
String viewStr = 'Q'+((math.mod((i+4),4) == 0)? 4 : math.mod((i+1),4))+'-'+sd.addMonths(i*3).Year(); 
MPS.viewStr.add(viewStr);    
i++;
Quarters--;
}*/
                
                Date sdt=Date.newInstance(sd.Year(), 1, 1);
                Date edt=Date.newInstance(sd.Year(), 3, 31);
                Date edt2=Date.newInstance(sd.Year(), 6, 30);
                Date edt3=Date.newInstance(sd.Year(), 9, 30);
                Date edt4=Date.newInstance(sd.Year(), 12, 31);
                if((sd>=sdt) && (ed<=edt)) {
                    String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year(); MPS.viewStr.add(viewStr);
                }else if((sd>=sdt && sd<=edt) && (ed>edt && ed<=edt2)) {
                    //String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year();
                    MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr2 = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
                }
                else if((sd>=sdt && sd<=edt2) && (ed>edt2 && ed<=edt3)) {
                    //String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year();
                    MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr2 = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
                    //String viewStr3 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(2*3).Year());
                }
                else if((sd>=sdt && sd<=edt3) && (ed>edt3 && ed<=edt4)) {
                    //String viewStr = 'Q1'+'-'+sd.addMonths(0*3).Year();
                    MPS.viewStr.add('Q1'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr2 = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(1*3).Year());
                    //String viewStr3 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(2*3).Year());
                    //String viewStr4 = 'Q4'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(3*3).Year());
                }
                else if((sd>edt && sd<=edt2) && (ed>edt && ed<=edt2)){
                    //String viewStr = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(0*3).Year());
                }
                else if((sd>edt && ed>edt2 && sd<=edt2) && ed<=edt3){
                    //String viewStr2 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr3 = 'Q4'+'-'+sd.addMonths(3*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(1*3).Year());
                }
                else if((sd>=edt && ed>edt3 && sd<=edt2) && ed<=edt4){
                    //String viewStr = 'Q2'+'-'+sd.addMonths(1*3).Year();
                    MPS.viewStr.add('Q2'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr2 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(1*3).Year());
                    //String viewStr3 = 'Q4'+'-'+sd.addMonths(3*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(2*3).Year());
                }
                else if((sd>edt2 && ed>edt2 && sd<=edt2) && ed<=edt3){
                    //String viewStr2 = 'Q3'+'-'+sd.addMonths(2*3).Year();
                    MPS.viewStr.add('Q3'+'-'+sd.addMonths(0*3).Year());
                    //String viewStr3 = 'Q4'+'-'+sd.addMonths(3*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(1*3).Year());
                }
                else if((sd>edt2 && ed>edt3) && ed<=edt4){
                    //String viewStr3 = 'Q4'+'-'+sd.addMonths(3*3).Year();
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(0*3).Year());
                }
                else{
                    MPS.viewStr.add('Q4'+'-'+sd.addMonths(0*3).Year());
                }
                
                String str = ''; 
                str = '%'+str+'%';
                String query = 'select ' + String.escapeSingleQuotes(mpsFields) + ' from ERP7__MPS__c where ERP7__Start_Date__c <= :sd And ERP7__End_Date__c >= :ed And ERP7__Product__r.Name like :str  And ERP7__Schedule_Period__c = \'quarterly\' ';
                if(DC != null) query += ' And ERP7__Distribution_Channel__c = :DC Order by ERP7__Product__r.Name Asc limit 1000';
                else query += ' Order by ERP7__Product__r.Name Asc limit 1000';
                List<ERP7__MPS__c> MPSS = Database.query(query);
                
                query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c from ERP7__MPS_line_Item__c where ERP7__MPS__c In : MPSS Order By ERP7__Line_Count__c Asc';
                List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
                
                Map<Id, List<ERP7__MPS_line_Item__c>> myMPSSLines = new Map<Id, List<ERP7__MPS_line_Item__c>>();
                for(ERP7__MPS__c MP : MPSS){
                    List<ERP7__MPS_line_Item__c> myLines = new List<ERP7__MPS_line_Item__c>();
                    for(ERP7__MPS_line_Item__c MPLine : MPSSLines){
                        if(MP.Id == MPLine.ERP7__MPS__c) { myLines.add(MPLine); }
                    }
                    myMPSSLines.put(MP.Id,myLines);
                }
                
                for(ERP7__MPS__c MP : MPSS){
                    List<MPSLine> myLines = new List<MPSLine>();
                    Map<String, MPSLine> vsMPSLine = new Map<String, MPSLine>();
                    for(ERP7__MPS_line_Item__c MPLine : myMPSSLines.get(MP.Id)){
                        if(MP.Id == MPLine.ERP7__MPS__c){ MPSLine MLine = new MPSLine();
                                                         MLine.MPSLine = MPLine; MLine.viewStr = MPLine.Name;
                                                         vsMPSLine.put(MLine.viewStr,MLine);
                                                        }
                    }
                    if(vsMPSLine.size() > 0){
                        for(String vs : MPS.viewStr){
                            MPSLine MLine = (vsMPSLine.containsKey(vs))? vsMPSLine.get(vs) : new MPSLine();
                            MLine.viewStr = vs; myLines.add(MLine);
                        }
                        MPS cMPS = new MPS(); cMPS.MPS = MP; cMPS.searchString = MP.Name +' '+MP.ERP7__Product__r.Name;
                        cMPS.MPSLines = myLines; MPS.MPSS.add(cMPS);
                    }
                }
                
            }
        } catch(Exception e) { MPS.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        //MPS.InitialDate=system.Today();
        return MPS;
    }
    @AuraEnabled
    public static MPS getBomMPS(String StrMPS,String versionId,String siteId){
        MPS mps = new MPS();
        try{
        if(StrMPS != null && StrMPS != ''){
            ERP7__MPS__c currentMPs = (ERP7__MPS__c) JSON.deserialize(StrMPS, ERP7__MPS__c.class);
            Id ProdID = currentMPs.ERP7__Product__c;
            system.debug('ProdID : '+ProdID);
            if(versionId != null && versionId != ''){
                if(currentMPs.ERP7__Version__c == null) {currentMPs.ERP7__Version__c =versionId; update currentMPs; }
                List<ERP7__BOM__c> BOms = [Select Id,Name,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__BOM_Product__c,ERP7__BOM_Version__c from ERP7__BOM__c where ERP7__Active__c = true and ERP7__BOM_Component__c != null and ERP7__BOM_Product__c =:ProdID and ERP7__Type__c='Primary' and ERP7__Status__c = 'Certified' and ERP7__BOM_Version__c=:versionId order by ERP7__BOM_Component__c];
                system.debug('BOms : '+BOms.size());
                List<ERP7__WIP_Link__c> WIPs = [Select Id,Name,ERP7__Process_Output_Product__c,ERP7__Process_Output_Product__r.Name,ERP7__Quantity_Unit__c,ERP7__Product__c,ERP7__Version__c from ERP7__WIP_Link__c where ERP7__Version__c=:versionId and ERP7__Process_Output_Product__c != null and ERP7__Product__c=:ProdID];
                set<Id> ProdIds = new set<Id>();
                Map<Id,String> ProdIdName = new Map<Id,String>();
                Map<Id,ERP7__BOM__c> ProdIdBOM = new Map<Id,ERP7__BOM__c>();
                for(ERP7__BOM__c bom : BOms){
                    ProdIds.add(bom.ERP7__BOM_Component__c);
                    ProdIdName.put(bom.ERP7__BOM_Component__c,bom.ERP7__BOM_Component__r.Name);
                    ProdIdBOM.put(bom.ERP7__BOM_Component__c,bom);
                }
                for(ERP7__WIP_Link__c wip : WIPs) {
                    if(ProdID != wip.ERP7__Process_Output_Product__c){
                        ProdIds.add(wip.ERP7__Process_Output_Product__c);
                        ProdIdName.put(wip.ERP7__Process_Output_Product__c,wip.ERP7__Process_Output_Product__r.Name);
                    }
                }
                If(ProdIds.size() > 0){
                    date startdate = currentMPs.ERP7__Start_Date__c;
                    date endDate = currentMPs.ERP7__End_Date__c;
                    List<ERP7__MPS__c> BomWipMPs = [Select Id,Name from ERP7__MPS__c where ERP7__Master_Production_Schedule__c =:currentMPs.Id and ERP7__Product__c IN:ProdIds and ERP7__Start_Date__c=:startdate and ERP7__End_Date__c=:endDate and ERP7__Schedule_Period__c=:currentMPs.ERP7__Schedule_Period__c limit 100];
                    system.debug('BomWipMPs : '+BomWipMPs);
                    if(BomWipMPs.size() > 0){
                      mps =  getAllSTockRR(currentMPs.Id,startdate,'','');
                    }
                    else{
                        String query2 = 'Select Id,ERP7__Product__c,Name,ERP7__Location__c,ERP7__Location__r.Name,ERP7__No_of_Items_Requested__c,ERP7__No_of_Items_Reserved__c,ERP7__Number_of_Items_Awaiting_in_Stock__c,ERP7__Number_of_Item_In_Stock__c,ERP7__StorageContainer__c,ERP7__StorageContainer__r.Name,ERP7__Warehouse__c,ERP7__Warehouse__r.Name from ERP7__Inventory_Stock__c where ERP7__Product__c IN :prodIds and ERP7__Active__c = true and ERP7__Number_of_Item_In_Stock__c > 0';
                        if(String.isNotBlank(siteId))  query2 += ' and ERP7__Warehouse__c = :siteId ';
                        
                        List<ERP7__Inventory_Stock__c> invList = database.query(query2);
                        Map<Id,decimal> ProdStock = new Map<Id,decimal>();
                        for(ERP7__Inventory_Stock__c inv : invList){
                            decimal ItemsInstock = 0;
                            if(ProdStock.containsKey(inv.ERP7__Product__c))  {
                                ItemsInstock = ProdStock.get(inv.ERP7__Product__c) + inv.ERP7__Number_of_Item_In_Stock__c;
                                ProdStock.put(inv.ERP7__Product__c,ItemsInstock);
                            } 
                            else ProdStock.put(inv.ERP7__Product__c,inv.ERP7__Number_of_Item_In_Stock__c);
                        }
                        List< OrderItem > OrderItems = [Select Id, OrderItemNumber, Product2Id, Quantity, Order.ERP7__Expected_Date__c, ERP7__Version__c 
                                                        From OrderItem 
                                                        Where Product2Id In : prodIds And 
                                                        Order.ERP7__Expected_Date__c >= :StartDate And
                                                        Order.ERP7__Expected_Date__c <= :EndDate And
                                                        Quantity > 0];
                        Map<Id,decimal> OrderDemand = new Map<Id,decimal>();
                        for(OrderItem ord : OrderItems){
                            If(OrderDemand.containsKey(ord.Product2Id)){
                                decimal qtydemand = OrderDemand.get(ord.Product2Id) + ord.Quantity;
                                OrderDemand.put(ord.Product2Id,qtydemand);
                            }
                            else OrderDemand.put(ord.Product2Id,ord.Quantity);
                        }
                        system.debug('OrderDemand : '+OrderDemand);
                        String MRPstatus = 'Requested';
                        List< ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c, ERP7__MRP_Product__c, ERP7__Total_Amount_Required__c, ERP7__MO__r.ERP7__ExpectedDate__c, ERP7__Version__c
                                                     From ERP7__MRP__c
                                                     Where ERP7__MRP_Product__c In : prodIds And 
                                                     ( (ERP7__Order_Product__r.Order.ERP7__Expected_Date__c >= :StartDate And ERP7__Order_Product__r.Order.ERP7__Expected_Date__c <= :EndDate) Or
                                                      (ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c >= :StartDate And ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Expected_Date__c <= :EndDate) Or
                                                      (ERP7__MO__r.ERP7__ExpectedDate__c >= :StartDate And ERP7__MO__r.ERP7__ExpectedDate__c <= :EndDate)) And
                                                     ERP7__Total_Amount_Required__c > 0 and ERP7__Status__c=:MRPstatus];
                        Map<Id,decimal> MRPDemand = new Map<Id,decimal>();
                        for(ERP7__MRP__c mrp : MRPS){
                            If(MRPDemand.containsKey(mrp.ERP7__MRP_Product__c)){
                                decimal qtydemand = MRPDemand.get(mrp.ERP7__MRP_Product__c) + mrp.ERP7__Total_Amount_Required__c;
                                MRPDemand.put(mrp.ERP7__MRP_Product__c,qtydemand);
                            }
                            else MRPDemand.put(mrp.ERP7__MRP_Product__c,mrp.ERP7__Total_Amount_Required__c);
                        }
                        system.debug('MRPDemand : '+MRPDemand);
                        List< ERP7__Manufacturing_Order__c > MOS = [Select Id, Name, ERP7__ExpectedDate__c,ERP7__Expected_Date__c, ERP7__Product__c, ERP7__Version__c, ERP7__Quantity__c
                                                                    From ERP7__Manufacturing_Order__c
                                                                    Where ERP7__Product__c In : prodIds And 
                                                                    (ERP7__ExpectedDate__c >= :StartDate And ERP7__ExpectedDate__c <= :EndDate) And
                                                                    ERP7__Quantity__c > 0 and ERP7__Status__c != 'Completed'];                                
                        system.debug('MOS : '+MOS.size());
                        Map<Id,decimal> MOQty = new Map<Id,decimal>();
                        for(ERP7__Manufacturing_Order__c mo : MOS){
                            If(MOQty.containsKey(mo.ERP7__Product__c)){
                                decimal qty = MOQty.get(mo.ERP7__Product__c) + mo.ERP7__Quantity__c;
                                MOQty.put(mo.ERP7__Product__c,qty);
                            }
                            else MOQty.put(mo.ERP7__Product__c,mo.ERP7__Quantity__c);
                        }
                        system.debug('MOQty : '+MOQty);
                        List<ERP7__Purchase_Line_Items__c> PurchaseLines = [Select Id, Name, ERP7__Active__c, ERP7__Version__c, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.ERP7__Expected_Date__c, ERP7__Product__c, ERP7__Quantity__c,ERP7__Quantity_Received__c
                                                                            From ERP7__Purchase_Line_Items__c
                                                                            Where ERP7__Product__c In : prodIds And 
                                                                            (ERP7__Purchase_Orders__r.ERP7__Expected_Date__c >= :StartDate And ERP7__Purchase_Orders__r.ERP7__Expected_Date__c <= :EndDate) And
                                                                            ERP7__Quantity__c > 0];
                        system.debug('PurchaseLines : '+PurchaseLines);
                        Map<Id,decimal> POQty = new Map<Id,decimal>();
                        for(ERP7__Purchase_Line_Items__c po : PurchaseLines){
                            If(POQty.containsKey(po.ERP7__Product__c)){
                                decimal qty = (po.ERP7__Quantity_Received__c > 0) ? (po.ERP7__Quantity__c - po.ERP7__Quantity_Received__c) + POQty.get(po.ERP7__Product__c) : POQty.get(po.ERP7__Product__c) + po.ERP7__Quantity__c;
                                POQty.put(po.ERP7__Product__c,qty);
                            }
                            else {
                                decimal poReceivedqty = (po.ERP7__Quantity_Received__c > 0) ? (po.ERP7__Quantity__c - po.ERP7__Quantity_Received__c) : po.ERP7__Quantity__c;
                                POQty.put(po.ERP7__Product__c,poReceivedqty);
                            }
                        }
                        system.debug('POQty : '+POQty);
                        List<ERP7__Reordering_Rule__c> rrList = [Select Id,Name,ERP7__Minimum_Quantity__c,ERP7__MinimumOrderingQuantity__c,ERP7__Product__c from ERP7__Reordering_Rule__c where ERP7__Product__c IN :prodIds ];
                        Map<Id,ERP7__Reordering_Rule__c> rrMap = new Map<Id,ERP7__Reordering_Rule__c>();
                        for(ERP7__Reordering_Rule__c rr : rrList){
                            if(!rrMap.containsKey(rr.ERP7__Product__c)) rrMap.put(rr.ERP7__Product__c,rr);
                        }
                        List<ERP7__MPS__c> MPS2create = new  List<ERP7__MPS__c>();
                        for(Id prod: prodIds){
                            ERP7__MPS__c newMPS = new ERP7__MPS__c();
                            newMPS.ERP7__Product__c = prod;
                            newMPS.ERP7__Version__c = versionId;
                            newMPS.ERP7__Start_Date__c = startdate;
                            newMPS.ERP7__End_Date__c = endDate;
                            newMPS.ERP7__Master_Production_Schedule__c = currentMPs.Id;
                            newMPS.ERP7__Bill_Of_Material__c = ProdIdBOM.containsKey(prod) ? ProdIdBOM.get(prod).Id : null;
                            newMPS.ERP7__Schedule_Period__c = currentMPs.ERP7__Schedule_Period__c;
                            String prodName = ProdIdName.containsKey(prod) ? (ProdIdName.get(prod)+ ' -MPS') : currentMPs.ERP7__Schedule_Period__c + '-MPS';
                            newMPS.Name = (prodName.length() > 80) ? (prodName.substring(0,79)) : prodName ;
                            Decimal demand = 0;
                            if(OrderDemand.containsKey(prod)) demand += OrderDemand.get(prod);
                            if(MRPDemand.containsKey(prod)) demand += MRPDemand.get(prod);
                            newMPS.ERP7__Default_Demand_Forecast__c = demand;
                            Decimal OrderderQty = 0;
                            if(MOQty.containsKey(prod)) OrderderQty += MOQty.get(prod);
                            if(POQty.containsKey(prod)) OrderderQty += POQty.get(prod);
                            if(OrderderQty == null) OrderderQty = 0;
                            if(rrMap.containsKey(prod) && rrMap.get(prod) != null) {
                                newMPS.ERP7__Reordering_Rule__c = rrMap.get(prod).Id;
                                newMPS.ERP7__Minimum_Inventory_Level__c = rrMap.get(prod).ERP7__Minimum_Quantity__c;
                            }
                            else newMPS.ERP7__Minimum_Inventory_Level__c = 0;
                            newMPS.ERP7__Starting_Inventory__c = ProdStock.containsKey(prod) ? ProdStock.get(prod) : 0;
                            system.debug('newMPS.ERP7__Starting_Inventory__c : '+newMPS.ERP7__Starting_Inventory__c);
                            newMPS.ERP7__Lot_Size__c = (newMPS.ERP7__Default_Demand_Forecast__c <= ((newMPS.ERP7__Starting_Inventory__c - newMPS.ERP7__Minimum_Inventory_Level__c) + OrderderQty)) ? 0 : (newMPS.ERP7__Default_Demand_Forecast__c - ((newMPS.ERP7__Starting_Inventory__c - newMPS.ERP7__Minimum_Inventory_Level__c) + OrderderQty));
                                //((newMPS.ERP7__Default_Demand_Forecast__c <= ((newMPS.ERP7__Starting_Inventory__c - newMPS.ERP7__Minimum_Inventory_Level__c) + OrderderQty)) ? 0 : ((newMPS.ERP7__Default_Demand_Forecast__c) - (newMPS.ERP7__Starting_Inventory__c - newMPS.ERP7__Minimum_Inventory_Level__c) - OrderderQty);
                                MPS2create.add(newMPS);
                        }
                        system.debug('MPS2create : '+MPS2create.size());
                        If(MPS2create.size() > 0) {
                            PreventRecursiveLedgerEntry.preventMPsTrigger = true;
                            upsert MPS2create;
                        }
                        mps =  getAllSTockRR(currentMPs.Id,startdate,'','');
                    }
                }
            }
        }
        }catch(Exception e){
            mps.errMsg = 'Error : '+e.getMessage()+' @Line : '+e.getLineNumber();
            system.debug('mps.errMsg : '+mps.errMsg);
        }
        return mps;
    }
    public class MPS {
        @AuraEnabled public ERP7__MPS__c MPS                                    { get; set; }
        @AuraEnabled public List<MPSLine> MPSLines                              { get; set; }
        @AuraEnabled public List<MPS> MPSS                                      { get; set; }
        @AuraEnabled public Boolean Dirty                                       { get; set; }
        @AuraEnabled public Boolean Dirtys                                      { get; set; }
        @AuraEnabled public String errMsg                                       { get; set; }
        @AuraEnabled public Date StartDate                                      { get; set; }
        @AuraEnabled public Date EndDate                                        { get; set; }
        @AuraEnabled public String searchString                                 { get; set; }
        @AuraEnabled public List<String> viewStr                                { get; set; }         @AuraEnabled public List<String> viewStr2                                { get; set; }
        @AuraEnabled public List<selectOptions> mpsStatus                       { get ; set; }
        @AuraEnabled public Date InitialDate                                    {get;set;}
        @AuraEnabled public Boolean display                                     {get;set;}
         
        public MPS() {
            this.MPS = new ERP7__MPS__c();
            this.MPSLines = new List<MPSLine>();
            this.MPSS = new List<MPS>();
            this.Dirty = false;
            this.Dirtys = false;
            this.errMsg = '';
            this.StartDate = Date.newinstance(system.today().year(), 01, 01);
            this.EndDate = Date.newinstance(system.today().year(), 12, 31);
            this.InitialDate = system.Today();
            this.searchString = ''; 
            viewStr = new List<String>();
            mpsStatus = new List<selectOptions>();
            this.display = false;
        }
    }
    
    public class MPSLine {
        @AuraEnabled public ERP7__MPS_line_Item__c MPSLine                      { get; set; }
        @AuraEnabled public Decimal OrderedQuantity                             { get; set; }
        @AuraEnabled public Boolean IssuePO                                     { get; set; }
        @AuraEnabled public Boolean IssueMO                                     { get; set; }
        @AuraEnabled public String viewStr                                      { get; set; }
        @AuraEnabled public Boolean display                                     {get;set;}
        public MPSLine() {
            this.MPSLine = new ERP7__MPS_line_Item__c(ERP7__Actual_Demand__c=0, ERP7__Available_To_Promise__c=0, ERP7__Demand_Forecast__c=0, ERP7__Net_Inventory_Before_Supply_Produce__c=0, ERP7__Projected_Inventory__c =0, ERP7__To_Supply_Manufacture__c=0);
            this.OrderedQuantity = 0;
            this.IssuePO = false;
            this.IssueMo = false;  
            this.viewStr = ''; 
            this.display = false;
        }
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }        @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
            //selected = false;
        }
    }
    Public class InitWrap{
        @AuraEnabled public String errMsg                                       { get; set; }
        @AuraEnabled public List<prodWrap> ProdList                                       { get; set; }
        @AuraEnabled public Date StartDate                                      { get; set; }
        @AuraEnabled public Date EndDate                                        { get; set; }
        @AuraEnabled public Date InitialDate                                    { get; set;  }
        @AuraEnabled public List<selectOptions> mpsStatus                       { get; set; }
        public InitWrap(){
            this.errMsg = '';
            ProdList = new List<prodWrap>();
            this.StartDate = Date.newinstance(system.today().year(), 01, 01);
            this.EndDate = Date.newinstance(system.today().year(), 12, 31);
            this.InitialDate = system.Today();
            mpsStatus = new List<selectOptions>();
        }
    }
    Public class prodWrap{
        @AuraEnabled public Product2 Prod                                       { get; set; }
        @AuraEnabled public Decimal OrdDemand                                   { get; set; }
        @AuraEnabled public Decimal MRPDemand                                   { get; set; }
        @AuraEnabled public Decimal NetInventory                                { get; set; }
        @AuraEnabled public Decimal toProduce                                   { get; set; }
        @AuraEnabled public Decimal ProjectedInventory                          { get; set; }
        @AuraEnabled public Decimal OrderedQty                                  { get; set; }
        @AuraEnabled public List<String> viewStr                                { get; set; }
        @AuraEnabled public  ERP7__Reordering_Rule__c rrRule                    { get; set; }
        @AuraEnabled public date StartDate                                      { get; set; }
        @AuraEnabled public date EndDate                                        { get; set; }          
        public prodWrap(){
            this.Prod = new Product2(); 
            this.MRPDemand = 0;
            this.OrdDemand = 0;
            this.NetInventory = 0;
            this.toProduce = 0;
            OrderedQty = 0;
            this.ProjectedInventory = 0;
            this.viewStr = new List<String>();
            rrRule = new ERP7__Reordering_Rule__c();
            
        }
    }
}