public With Sharing class SalesOrdersToaLogistic {
    @AuraEnabled
    public static ERP7__Distribution_Channel__c getDC(String ChId){
        ERP7__Distribution_Channel__c Dc = new ERP7__Distribution_Channel__c();
        if(ChId != null && ChId != ''){
            List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:ChId and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
            if(dcList.size() > 0 ) Dc = dcList[0];
 
        }
        if(Dc != null) return Dc;
        else return null;
    }
    @AuraEnabled
    public static Integer TotalRecords(String channelId){
        Integer totalRecords = 0;
        
        system.debug('channelId : '+channelId);
        if(channelId == '' || channelId == null) {
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            system.debug('empList.size() : '+empList.size());
            if(empList.size()>0 && empList != null){
                channelId = empList[0].ERP7__Channel__c;
            }
        }
        Boolean StandOrder =controlCheck();
        system.debug('StandOrder : '+StandOrder);
        if(!StandOrder)  totalRecords = [Select count() from ERP7__Sales_Order__c WHERE ERP7__Active__c =:true and ERP7__Ready_To_Pick_Pack__c =:false and ERP7__Logistic__c=:false and ERP7__Channel__c=:channelId];
        else totalRecords = [Select count() from Order WHERE ERP7__Active__c =:true and ERP7__Ready_To_Pick_Pack__c =:false and ERP7__Logistic__c=:false and ERP7__Channel__c=:channelId and ERP7__Total_Number_of_Items__c > 0];
        system.debug('totalRecords : '+totalRecords);
        return totalRecords;
        
    }
    @AuraEnabled(cacheable=true)
    public static String getSOlist(String searchString, String ChannelId, Integer pageSize, Integer pageNumber) {
        SOdata wrap = new SOdata();
        
        ERP7__Distribution_Channel__c Dc = new ERP7__Distribution_Channel__c();
        ERP7__Channel__c chanel = new ERP7__Channel__c();
        List<ERP7__Sales_Order__c> Saleslist  = new  List<ERP7__Sales_Order__c>();
        List<Order> orderlist  = new  List<Order>();
        Integer ikOffset = (pageNumber - 1) * pageSize;
        system.debug('ikOffset : '+ikOffset);
        Integer recordEnd = pageSize * pageNumber;
        // Integer ikRecordLimit = Integer.valueof(RecordLimit);
        // system.debug('ikRecordLimit : '+ikRecordLimit);
        system.debug('ChannelId : '+ChannelId);
        //string searchKeyword = '%' + searchKey + '%';
        
        if(ChannelId == '' || ChannelId == null){
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            system.debug('empList.size() : '+empList.size());
            if(empList.size()>0 && empList != null){
                ChannelId = empList[0].ERP7__Channel__c;
                chanel = [Select Id,Name from ERP7__Channel__c where Id=:empList[0].ERP7__Channel__c Limit  1];
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:ChannelId and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                
                if(dcList.size() > 0) Dc = dcList[0];
            }
            
        }
        system.debug('searchString : '+searchString);
        system.debug('ChannelId after: '+ChannelId);
        
        Boolean StandOrder =controlCheck();
        system.debug('StandOrder : '+StandOrder);
        if(StandOrder){
            if(searchString != '' && searchString != null) {
                String strKey ='%'+searchString+'%';
                system.debug('strKey : '+strKey);
                system.debug('if executed');
                Integer totalRecords = [SELECT COUNT() FROM Order WHERE  ERP7__Active__c =:true  AND  Name like :strKey AND ERP7__Ready_To_Pick_Pack__c =false and ERP7__Channel__c=:ChannelId and ERP7__Logistic__c=:false  and ERP7__Total_Number_of_Items__c > 0];
                wrap.pageSize = pageSize;
                wrap.pageNumber = pageNumber;
                wrap.recordStart = ikOffset + 1;
                wrap.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                wrap.totalRecords = totalRecords;
                orderlist = [SELECT Id, Name,AccountId,Account.Name,ERP7__Is_Back_Order__c,ERP7__Total_Quantity__c,ERP7__Total_Logistic_Quantity_U__c,ERP7__Total_Number_of_Items__c, ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Channel__c FROM Order WHERE  ERP7__Active__c =:true  AND Name like :strKey AND ERP7__Ready_To_Pick_Pack__c =false and ERP7__Logistic__c=:false and ERP7__Channel__c=:ChannelId  and ERP7__Total_Number_of_Items__c > 0 ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :ikOffset];
                system.debug('if Saleslist : '+Saleslist.size());
                wrap.SOlist = orderlist;
            }
            else  {
                Integer totalRecords = [SELECT COUNT() FROM Order WHERE  ERP7__Active__c =:true  AND ERP7__Ready_To_Pick_Pack__c =false and ERP7__Channel__c=:ChannelId and ERP7__Logistic__c=:false  and ERP7__Total_Number_of_Items__c > 0];
                wrap.pageSize = pageSize;
                wrap.pageNumber = pageNumber;
                wrap.recordStart = ikOffset + 1;
                wrap.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                wrap.totalRecords = totalRecords;
                orderlist = [SELECT Id, Name,AccountId,Account.Name,ERP7__Is_Back_Order__c,ERP7__Total_Quantity__c,ERP7__Total_Logistic_Quantity_U__c,ERP7__Total_Number_of_Items__c, ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Channel__c FROM Order WHERE  ERP7__Active__c =:true  AND ERP7__Ready_To_Pick_Pack__c =false and ERP7__Channel__c=:ChannelId and ERP7__Logistic__c=:false  and ERP7__Total_Number_of_Items__c > 0 ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :ikOffset];        system.debug('orderlist : '+orderlist.size());
                wrap.SOlist = orderlist;
            }
            
        }
        else{
            if(searchString != '' && searchString != null) {
                String strKey ='%'+searchString+'%';
                system.debug('strKey : '+strKey);
                system.debug('if executed');
                Integer totalRecords = [SELECT COUNT() FROM ERP7__Sales_Order__c WHERE  ERP7__Active__c =:true  AND Name like :strKey AND ERP7__Ready_To_Pick_Pack__c =false and ERP7__Channel__c=:ChannelId and ERP7__Logistic__c=:false  and ERP7__Total_Number_of_Items__c > 0];
                wrap.pageSize = pageSize;
                wrap.pageNumber = pageNumber;
                wrap.recordStart = ikOffset + 1;
                wrap.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                wrap.totalRecords = totalRecords;
                Saleslist = [SELECT Id, Name,ERP7__Account__c,ERP7__Is_Back_Order__c,ERP7__Total_Quantity__c,ERP7__Total_Number_of_Items__c,ERP7__Total_Logistic_Quantity__c,ERP7__Account__r.Name, ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Channel__c FROM ERP7__Sales_Order__c WHERE  ERP7__Active__c =:true  AND Name like :strKey AND ERP7__Ready_To_Pick_Pack__c =false and ERP7__Logistic__c=:false and ERP7__Channel__c=:ChannelId  ORDER BY CreatedDate DESC limit :pageSize Offset :ikOffset];
                system.debug('if Saleslist : '+Saleslist.size());
                wrap.SOlist = Saleslist;
            }
            else  {
                Integer totalRecords = [SELECT COUNT() FROM ERP7__Sales_Order__c WHERE  ERP7__Active__c =:true  AND ERP7__Ready_To_Pick_Pack__c =false and ERP7__Channel__c=:ChannelId and ERP7__Logistic__c=:false  and ERP7__Total_Number_of_Items__c > 0];
                wrap.pageSize = pageSize;
                wrap.pageNumber = pageNumber;
                wrap.recordStart = ikOffset + 1;
                wrap.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                wrap.totalRecords = totalRecords;
                Saleslist = [SELECT Id, Name,ERP7__Account__c,ERP7__Is_Back_Order__c,ERP7__Total_Quantity__c,ERP7__Total_Number_of_Items__c,ERP7__Total_Logistic_Quantity__c,ERP7__Account__r.Name, ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Channel__c FROM ERP7__Sales_Order__c WHERE  ERP7__Active__c =:true  AND ERP7__Ready_To_Pick_Pack__c =false and ERP7__Channel__c=:ChannelId and ERP7__Logistic__c=:false ORDER BY CreatedDate DESC limit :pageSize Offset :ikOffset];        system.debug('Saleslist : '+Saleslist.size());
                wrap.SOlist = Saleslist;
            }
            
        }
        /* if(saleslist.size() > 0){
wrap.solist = Saleslist;
wrap.channel = chanel;
wrap.Dchannel = Dc;
wrap.Error = '';
}
else{
wrap.Error = 'No records available to display!Please change channel and try again';
wrap.channel = chanel;
wrap.Dchannel = Dc;
wrap.solist = null;
}*/
        String jsonDT = JSON.serialize(wrap);
        
        return jsonDT;
    }
    @AuraEnabled
    public static logwrapper  createLogistics(String SOList,String DCId){
        system.debug('createLogistics called');
        set<Id> soIds = new set<Id>();
        logwrapper wrap = new logwrapper();
        Boolean StandOrder =controlCheck();
        wrap.StandardOrder = StandOrder;
        system.debug('StandOrder : '+StandOrder);
        system.debug('SOList : '+SOList);
        if(!StandOrder){
            List < String >  SOLst1= (List < String >) JSON.deserialize(SOList, List < String >.class);
            List < ERP7__Sales_Order_Line_Item__c > SOLI2upsert = new List < ERP7__Sales_Order_Line_Item__c >();
            system.debug('SOLst1.size() : '+SOLst1.size());
            if(SOLst1.size() > 0){
                for(String po : SOLst1){
                    soIds.add(po); 
                } 
                List<ERP7__Sales_Order__c> SOlst = [Select Id,Name,ERP7__Logistic__c,ERP7__Ready_To_Pick_Pack__c,ERP7__Channel__c,ERP7__Account__c,ERP7__Account__r.Name,ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Contact__r.FirstName,ERP7__Contact__r.LastName,ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Ship_From_Address__c,ERP7__Expected_Date__c,ERP7__Barcode__c from ERP7__Sales_Order__c where Id In:soIds];
                if(SOlst.size() > 0){
                    system.debug('SOLst[0].ERP7__Channel__c : '+SOLst[0].ERP7__Channel__c);
                    ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
                    if(DCId == '' || DCId == null){
                        dc=[Select Id,Name,ERP7__Site__c,ERP7__Channel__c from ERP7__Distribution_Channel__c where ERP7__Channel__c=:SOLst[0].ERP7__Channel__c and Active__c = true
                            Order By Priority__c Desc  Limit 1];
                        DCId = dc.Id;
                    }
                    else{
                        dc=[Select Id,Name,ERP7__Site__c,ERP7__Channel__c from ERP7__Distribution_Channel__c where ERP7__Channel__c=:SOLst[0].ERP7__Channel__c and Id=:DCId Limit 1];
                    }
                    List<ERP7__Sales_Order_Line_Item__c> SOLIS = [Select Id,Name,ERP7__Is_Back_Order__c,ERP7__Logistic_Quantity__c,ERP7__Detailed_Description__c,ERP7__Product__c,ERP7__Version__c,ERP7__Base_Price__c,ERP7__Quantity__c,ERP7__Explode__c,ERP7__Price_Product__c,ERP7__Product__r.Name,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c In :soIds];
                    Set<Id> proList = new Set<Id>();
                    system.debug('dc.ERP7__Site__c : '+dc.ERP7__Site__c);
                    for(ERP7__Sales_Order_Line_Item__c solisitem : SOLIS) proList.add(solisitem.ERP7__Product__c);
                    system.debug('proList : '+proList.size()+'  proList : '+proList);
                    List<ERP7__Inventory_Stock__c> invtoryList=[Select Id,Name,ERP7__product__c from ERP7__Inventory_Stock__c
                                                                where ERP7__product__c In:proList And  ERP7__Active__c=true AND ERP7__Warehouse__c =:dc.ERP7__Site__c
                                                                And ERP7__Number_of_Item_In_Stock__c>0 ORDER BY createdDate ASC];
                    
                    Map<String,String> proInv=new Map<String,String>();
                    for(ERP7__Inventory_Stock__c invt:invtoryList){
                        if(proInv.get(invt.ERP7__product__c) == null) proInv.put(invt.ERP7__product__c,invt.Id);
                    }
                    String SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Logistic__c','SO');
                    ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=System.today()+'-Logistic', ERP7__Type__c='Outbound', ERP7__Account__c=SOLst[0].ERP7__Account__c, ERP7__Contact__c=SOLst[0].ERP7__Contact__c, ERP7__Active__c=true,Channel__c=SOLst[0].ERP7__Channel__c, ERP7__To_Address__c = SOLst[0].ERP7__Ship_To_Address__c, ERP7__From_Address__c = SOLst[0].ERP7__Ship_From_Address__c,RecordTypeId=SORecTypeId,ERP7__Distribution_Channel__c=DCId,ERP7__Logistic_Expected_Date__c = SOLst[0].ERP7__Expected_Date__c,ERP7__Logistic_Barcode__c = SOLst[0].ERP7__Barcode__c);
                    if(Logistic.ERP7__Shipment_type__c == null || Logistic.ERP7__Shipment_type__c == '' ) Logistic.ERP7__Shipment_type__c = 'UPS';
                    if(Logistic.ERP7__Shipping_Preferences__c == null || Logistic.ERP7__Shipping_Preferences__c == '' ) Logistic.ERP7__Shipment_type__c = '--None--';
                    if(!test.isRunningTest()) Logistic.ERP7__Account__r = new Account(Id = SOLst[0].ERP7__Account__c,Name = SOLst[0].ERP7__Account__r.Name);
                    if(!test.isRunningTest()) Logistic.ERP7__Contact__r = new Contact(Id = SOLst[0].ERP7__Contact__c,FirstName = SOLst[0].ERP7__Contact__r.Name,LastName=SOLst[0].ERP7__Contact__r.LastName);
                    if(!test.isRunningTest()) Logistic.ERP7__To_Address__r = new ERP7__Address__c(Id = SOLst[0].ERP7__Ship_To_Address__c,Name = SOLst[0].ERP7__Ship_To_Address__r.Name);
                    List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>();
                    for(ERP7__Sales_Order_Line_Item__c soli :SOLIS){
                        Integer j = 1;
                        string name = soli.Name+'-LogisticLine-'+String.valueof(j);
                        if(name.Length() > 80){
                            name = name.substring(0, 60) + '-LogisticLine-'+String.valueof(j);
                            system.debug('name : '+name);
                        }
                        ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=name, ERP7__Product__c=soli.ERP7__Product__c, ERP7__Logistic__c = null,
                                                                                           ERP7__Sales_Order_Line_Item__c=soli.Id, ERP7__Status__c='Reserved', ERP7__Production_Version__c = soli.ERP7__Version__c, ERP7__Explode__c = soli.ERP7__Explode__c, ERP7__Price_Product__c = soli.ERP7__Price_Product__c,
                                                                                           ERP7__Detail_Description__c=soli.ERP7__Detailed_Description__c);   
                        if(soli.ERP7__Logistic_Quantity__c == null) soli.ERP7__Logistic_Quantity__c = 0;
                        loli.ERP7__Quantity__c=soli.ERP7__Quantity__c - soli.ERP7__Logistic_Quantity__c;
                        loli.ERP7__Product__r = new Product2(Id = soli.ERP7__Product__c,Name = soli.ERP7__Product__r.Name);
                        loli.ERP7__Sales_Order_Line_Item__r = new ERP7__Sales_Order_Line_Item__c(Id = soli.Id,Name = soli.Name,ERP7__Is_Back_Order__c = soli.ERP7__Is_Back_Order__c,ERP7__Sales_Order__c = soli.ERP7__Sales_Order__c,ERP7__Sales_Order__r = new ERP7__Sales_Order__c(Id = soli.ERP7__Sales_Order__c,Name = soli.ERP7__Sales_Order__r.Name),ERP7__Quantity__c=soli.ERP7__Quantity__c);
                        if(loli.ERP7__Quantity__c > 0) myLines.add(loli);  
                        j++; 
                        // soli.ERP7__Logistic_Quantity__c=soli.ERP7__Quantity__c; SOLI2upsert.add(soli);
                    }
                    wrap.logistic = Logistic;
                    system.debug('wrap.logistic : '+wrap.logistic);
                    system.debug('myLines : '+myLines.size());
                    if(myLines.size() > 0){
                        
                        wrap.logisticlines = myLines;
                    }
                    /*  if(myLines.size() > 0){
upsert Logistic;
List<ERP7__Logistic_Line_Item__c> logisticsLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
for(ERP7__Logistic_Line_Item__c allLolis : myLines){
allLolis.Logistic__c = Logistic.Id;
logisticsLines2upsert.add(allLolis); 
}
if(logisticsLines2upsert.size() > 0) upsert logisticsLines2upsert;
set<Id> loglineIds = new set<Id>();
for(ERP7__Logistic_Line_Item__c loglne:logisticsLines2upsert) loglineIds.add(loglne.Id);
List<ERP7__Logistic_Line_Item__c> loglineCreated = [Select Id,Name,ERP7__Product__c,ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c,ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Production_Version__c,ERP7__Production_Version__r.Id,ERP7__Production_Version__r.Name,ERP7__Sales_Order_Line_Item__c,ERP7__Sales_Order_Line_Item__r.Name from ERP7__Logistic_Line_Item__c where Id In : loglineIds and Logistic__c = :Logistic.Id];
List<ERP7__Stock_Outward_Line_Item__c> SWLIToUpsert=new List<ERP7__Stock_Outward_Line_Item__c>();
for(ERP7__Logistic_Line_Item__c log:loglineCreated){

ERP7__Stock_Outward_Line_Item__c sto=new ERP7__Stock_Outward_Line_Item__c();
sto.Name=log.Name; 
system.debug('log.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c : '+log.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c);
sto.ERP7__Sales_Order_Line_Item__c=log.ERP7__Sales_Order_Line_Item__c;  
sto.ERP7__Sales_Order__c = log.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c;
sto.ERP7__Product__c=log.ERP7__Product__c;
sto.ERP7__Active__c=true; 
sto.ERP7__Status__c='Reserved';
sto.ERP7__Quantity__c=log.ERP7__Quantity__c; 
system.debug('proInv.get(log.ERP7__Product__c) : '+proInv.get(log.ERP7__Product__c));
sto.ERP7__Site_Product_Service_Inventory_Stock__c=proInv.get(log.ERP7__Product__c);
sto.ERP7__Logistic_Line_Item__c=log.Id;
SWLIToUpsert.add(sto);

}
if(SWLIToUpsert.size() > 0){ upsert SWLIToUpsert;}
wrap.logistic = [Select Id,Name,Channel__c,Channel__r.Name,ERP7__Distribution_Channel__c,ERP7__Distribution_Channel__r.Name,ERP7__Active__c,ERP7__Total_Quantity__c,ERP7__Logistic_Barcode__c,ERP7__Logistic_Expected_Date__c,ERP7__Order_S__c,ERP7__Order_S__r.OrderNumber from Logistic__c where Id=:Logistic.Id];

wrap.logisticlines = loglineCreated;
for(ERP7__Sales_Order__c so : SOLst) {so.ERP7__Ready_To_Pick_Pack__c = true; so.ERP7__Logistic__c = true; }
PreventRecursiveLedgerEntry.Loged = true; update SOLst;
update SOLI2upsert;

}*/
                } 
            }
        }
        else if(StandOrder){
            List < string >  SOLst1= (List < string >) JSON.deserialize(SOList, List < string >.class);
            List < OrderItem > SOLI2upsert = new List < OrderItem >();
            system.debug('SOLst1.size()StandOrder : '+SOLst1.size());
            if(SOLst1.size() > 0){
                for(String po : SOLst1){
                    soIds.add(po); 
                }  
                List<Order> SOlst = [Select Id,Name,ERP7__Logistic__c,ERP7__Ready_To_Pick_Pack__c,ERP7__Channel__c,AccountId,Account.Name,ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Contact__r.FirstName,ERP7__Contact__r.LastName,ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Ship_From_Address__c,ERP7__Expected_Date__c,ERP7__Barcode__c from Order where Id In:soIds];
                if(SOlst.size() > 0){
                    system.debug('SOLst[0].ERP7__Channel__c StandOrder: '+SOLst[0].ERP7__Channel__c);
                    ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
                    if(DCId == '' || DCId == null){
                        dc=[Select Id,Name,ERP7__Site__c,ERP7__Channel__c from ERP7__Distribution_Channel__c where ERP7__Channel__c=:SOLst[0].ERP7__Channel__c and Active__c = true
                            Order By Priority__c Desc  Limit 1];
                        DCId = dc.Id;
                    }
                    else{
                        dc=[Select Id,Name,ERP7__Site__c,ERP7__Channel__c from ERP7__Distribution_Channel__c where ERP7__Channel__c=:SOLst[0].ERP7__Channel__c and Id=:DCId Limit 1];
                    }
                    List<OrderItem> SOLIS = [Select Id,OrderItemNumber,OrderId,Order.Name,ERP7__Logistic_Quantity__c,ERP7__Detailed_Description__c,Product2Id,ERP7__Version__c,ERP7__Base_Price__c,Quantity,ERP7__Explode__c,UnitPrice,Product2.Name,ERP7__Is_Back_Order__c from OrderItem where OrderId In :soIds];
                    Set<Id> proList = new Set<Id>();
                    system.debug('dc.ERP7__Site__c StandOrder: '+dc.ERP7__Site__c);
                    system.debug('DCId StandOrder: '+DCId);
                    for(OrderItem solisitem : SOLIS) proList.add(solisitem.Product2Id);
                    system.debug('proList : '+proList.size()+'  proList : '+proList);
                    List<ERP7__Inventory_Stock__c> invtoryList=[Select Id,Name,ERP7__product__c from ERP7__Inventory_Stock__c
                                                                where ERP7__product__c In:proList And  ERP7__Active__c=true AND ERP7__Warehouse__c =:dc.ERP7__Site__c
                                                                And ERP7__Number_of_Item_In_Stock__c>0 ORDER BY createdDate ASC];
                    
                    Map<String,String> proInv=new Map<String,String>();
                    for(ERP7__Inventory_Stock__c invt:invtoryList){
                        if(proInv.get(invt.ERP7__product__c) == null) proInv.put(invt.ERP7__product__c,invt.Id);
                    }
                    String SORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Logistic__c','Order');
                    ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=System.today()+'-Logistic', ERP7__Type__c='Outbound', ERP7__Account__c=SOLst[0].AccountId, ERP7__Contact__c=SOLst[0].ERP7__Contact__c, ERP7__Active__c=true,Channel__c=SOLst[0].ERP7__Channel__c, ERP7__To_Address__c = SOLst[0].ERP7__Ship_To_Address__c, ERP7__From_Address__c = SOLst[0].ERP7__Ship_From_Address__c,RecordTypeId=SORecTypeId,ERP7__Distribution_Channel__c=DCId);
                    Logistic.ERP7__Logistic_Expected_Date__c = (SOLst[0].ERP7__Expected_Date__c != null) ? SOLst[0].ERP7__Expected_Date__c : system.today();
                    Logistic.ERP7__Logistic_Barcode__c = (SOLst[0].ERP7__Barcode__c != null && SOLst[0].ERP7__Barcode__c != '') ? SOLst[0].ERP7__Barcode__c : generateRandomString(12);
                    if(!test.isRunningTest()) Logistic.ERP7__Account__r = new Account(Id = SOLst[0].AccountId,Name = SOLst[0].Account.Name);
                    if(!test.isRunningTest()) Logistic.ERP7__Contact__r = new Contact(Id = SOLst[0].ERP7__Contact__c,FirstName = SOLst[0].ERP7__Contact__r.Name,LastName=SOLst[0].ERP7__Contact__r.LastName);
                    if(!test.isRunningTest()) Logistic.ERP7__To_Address__r = new ERP7__Address__c(Id = SOLst[0].ERP7__Ship_To_Address__c,Name = SOLst[0].ERP7__Ship_To_Address__r.Name);
                    List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>();
                    for(OrderItem soli :SOLIS){
                        Integer j = 1;
                        string name = soli.OrderItemNumber+'-LogisticLine-'+String.valueof(j);
                        if(name.Length() > 80){    name = name.substring(0, 60) + '-LogisticLine-'+String.valueof(j);  system.debug('name : '+name); }
                        ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=name, ERP7__Product__c=soli.Product2Id, ERP7__Logistic__c = null,
                                                                                           ERP7__Order_Product__c=soli.Id, ERP7__Status__c='Reserved', ERP7__Production_Version__c = soli.ERP7__Version__c, ERP7__Explode__c = soli.ERP7__Explode__c, ERP7__Price_Product__c = soli.UnitPrice,
                                                                                           ERP7__Detail_Description__c=soli.ERP7__Detailed_Description__c);  
                        if(soli.ERP7__Logistic_Quantity__c == null) soli.ERP7__Logistic_Quantity__c = 0;
                        loli.ERP7__Quantity__c=soli.Quantity - soli.ERP7__Logistic_Quantity__c;
                        loli.ERP7__Order_Product__r = new OrderItem(Id=soli.Id,ERP7__Name__c = soli.OrderItemNumber,ERP7__Is_Back_Order__c = soli.ERP7__Is_Back_Order__c,Quantity = soli.Quantity);
                        loli.ERP7__Product__r = new Product2(Id = soli.Product2Id,Name = soli.Product2.Name);
                        system.debug('loli.ERP7__Quantity__c : '+loli.ERP7__Quantity__c);
                        if(loli.ERP7__Quantity__c > 0) myLines.add(loli);  
                        j++; 
                        //soli.ERP7__Logistic_Quantity__c=soli.Quantity; SOLI2upsert.add(soli);
                    }
                    wrap.logistic = Logistic;
                    if(myLines.size() > 0){
                        
                        wrap.logisticlines = myLines;
                    }
                    /*  if(myLines.size() > 0){
upsert Logistic;
List<ERP7__Logistic_Line_Item__c> logisticsLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
for(ERP7__Logistic_Line_Item__c allLolis : myLines){
allLolis.Logistic__c = Logistic.Id;
logisticsLines2upsert.add(allLolis); 
}
if(logisticsLines2upsert.size() > 0) upsert logisticsLines2upsert;
set<Id> loglineIds = new set<Id>();
for(ERP7__Logistic_Line_Item__c loglne:logisticsLines2upsert) loglineIds.add(loglne.Id);
List<ERP7__Logistic_Line_Item__c> loglineCreated = [Select Id,Name,ERP7__Product__c,ERP7__Order_Product__r.OrderId,ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Production_Version__c,ERP7__Production_Version__r.Id,ERP7__Production_Version__r.Name,ERP7__Order_Product__c,ERP7__Order_Product__r.OrderItemNumber from ERP7__Logistic_Line_Item__c where Id In : loglineIds and Logistic__c = :Logistic.Id];
List<ERP7__Stock_Outward_Line_Item__c> SWLIToUpsert=new List<ERP7__Stock_Outward_Line_Item__c>();
for(ERP7__Logistic_Line_Item__c log:loglineCreated){

ERP7__Stock_Outward_Line_Item__c sto=new ERP7__Stock_Outward_Line_Item__c();
sto.Name=log.Name; 
system.debug('log.ERP7__Order_Product__r.OrderId : '+log.ERP7__Order_Product__r.OrderId);
system.debug('log.ERP7__Product__c : '+log.ERP7__Product__c);
sto.ERP7__Order_Product__c=log.ERP7__Order_Product__c;  
sto.ERP7__Order__c = log.ERP7__Order_Product__r.OrderId;
sto.ERP7__Product__c=log.ERP7__Product__c;
sto.ERP7__Active__c=true; 
sto.ERP7__Status__c='Reserved';
sto.ERP7__Quantity__c=log.ERP7__Quantity__c; 
system.debug('proInv.get(log.ERP7__Product__c) : '+proInv.get(log.ERP7__Product__c));
sto.ERP7__Site_Product_Service_Inventory_Stock__c=proInv.get(log.ERP7__Product__c);
sto.ERP7__Logistic_Line_Item__c=log.Id;
SWLIToUpsert.add(sto);

}
if(SWLIToUpsert.size() > 0){ upsert SWLIToUpsert;}
wrap.logistic = [Select Id,Name,Channel__c,Channel__r.Name,ERP7__Distribution_Channel__c,ERP7__Distribution_Channel__r.Name,ERP7__Active__c,ERP7__Total_Quantity__c,ERP7__Logistic_Barcode__c,ERP7__Logistic_Expected_Date__c,ERP7__Order_S__c,ERP7__Order_S__r.OrderNumber from Logistic__c where Id=:Logistic.Id];

wrap.logisticlines = loglineCreated;
for(Order so : SOLst) {so.ERP7__Ready_To_Pick_Pack__c = true; so.ERP7__Logistic__c = true; }
PreventRecursiveLedgerEntry.Loged = true; update SOLst;
update SOLI2upsert;

} */
                } 
            }
        }
        
        
        return wrap;
    }
    public static Boolean controlCheck(){
        Boolean StandOrder = false;
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        system.debug('FC : '+FC);
        if(FC == null){     FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId()); if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
                      }
        if(FC != null){
            StandOrder = FC.ERP7__Is_Standard_Order__c;
        }
        
        return StandOrder;
    }
    @AuraEnabled
    public static  String updateLogistics(ERP7__Logistic__c Logistic,List<Id> SelectedLIs,String LOLI){
        List<ERP7__Logistic_Line_Item__c> logsticlst = (List<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LOLI, List<ERP7__Logistic_Line_Item__c>.class);
        List<ERP7__Logistic_Line_Item__c> logline2upsert = new List<ERP7__Logistic_Line_Item__c>();
        Set<Id> proList = new Set<Id>();
        String LogID = '';
        system.debug('Log DC : '+Logistic.ERP7__Distribution_Channel__c);
        system.debug(' logsticlst size : '+logsticlst.size());
        String DCId = Logistic.ERP7__Distribution_Channel__c;
        system.debug('DCId : '+DCId);
        if(DCId != '' && DCId != null && logsticlst.size() > 0 &&  SelectedLIs.size() > 0){
            List<ERP7__Sales_Order_Line_Item__c> SOLIlst = [Select Id,Name,ERP7__Sales_Order__c,ERP7__Logistic_Quantity__c from ERP7__Sales_Order_Line_Item__c where Id In :SelectedLIs];
            List<OrderItem> OLIlst = [Select Id,ERP7__Name__c,OrderId,ERP7__Logistic_Quantity__c from OrderItem where Id In :SelectedLIs];
            ERP7__Distribution_Channel__c dc = [Select Id,Name,ERP7__Site__c from ERP7__Distribution_Channel__c Where Id =:DCId limit 1];
            for(ERP7__Logistic_Line_Item__c solisitem : logsticlst){
                if(SOLIlst.size() > 0){
                    for(ERP7__Sales_Order_Line_Item__c soli : SOLIlst){
                        if(solisitem.ERP7__Sales_Order_Line_Item__c == soli.Id){
                            proList.add(solisitem.ERP7__Product__c); 
                            logline2upsert.add(solisitem);
                            if(soli.ERP7__Logistic_Quantity__c == null) soli.ERP7__Logistic_Quantity__c = 0;
                            soli.ERP7__Logistic_Quantity__c = soli.ERP7__Logistic_Quantity__c + solisitem.ERP7__Quantity__c;
                        }
                    }  
                }
                else if(OLIlst.size() > 0){
                    for(OrderItem soli : OLIlst){
                        if(solisitem.ERP7__Order_Product__c == soli.Id){
                            proList.add(solisitem.ERP7__Product__c); 
                            logline2upsert.add(solisitem);
                            if(soli.ERP7__Logistic_Quantity__c == null) soli.ERP7__Logistic_Quantity__c = 0;
                            soli.ERP7__Logistic_Quantity__c = soli.ERP7__Logistic_Quantity__c + solisitem.ERP7__Quantity__c;
                        }
                    }
                }
                
                
            } 
            if(logline2upsert.size() > 0 && proList.size() > 0){
                List<ERP7__Inventory_Stock__c> invtoryList=[Select Id,Name,ERP7__product__c,ERP7__Batch_Lot__c,ERP7__Serial__c from ERP7__Inventory_Stock__c
                                                            where ERP7__product__c In:proList And  ERP7__Active__c=true AND ERP7__Warehouse__c =:dc.ERP7__Site__c
                                                            And ERP7__Number_of_Item_In_Stock__c>0 ORDER BY createdDate ASC];
                Map<String,ERP7__Inventory_Stock__c> proInv=new Map<String,ERP7__Inventory_Stock__c>();
                for(ERP7__Inventory_Stock__c invt:invtoryList){
                    if(proInv.get(invt.ERP7__product__c) == null) proInv.put(invt.ERP7__product__c,invt);
                }
                for(ERP7__Logistic_Line_Item__c log:logline2upsert){
                    if(proInv.get(log.ERP7__Product__c)==null) return 'Don\'t have inventory for product :'+log.ERP7__Product__r.Name+' on selected distribution channel\'s site';
                }
                if(Logistic.ERP7__Shipment_type__c == null || Logistic.ERP7__Shipment_type__c == '' ) Logistic.ERP7__Shipment_type__c = 'UPS';
                if(Logistic.ERP7__Shipping_Preferences__c == null || Logistic.ERP7__Shipping_Preferences__c == '' ) Logistic.ERP7__Shipment_type__c = '--None--';
                upsert Logistic;
                for(ERP7__Logistic_Line_Item__c allLolis : logline2upsert){
                    allLolis.Logistic__c = Logistic.Id;
                }
                if(logline2upsert.size() > 0) upsert logline2upsert;
                set<Id> loglineIds = new set<Id>();
                for(ERP7__Logistic_Line_Item__c loglne:logline2upsert) loglineIds.add(loglne.Id);
                List<ERP7__Logistic_Line_Item__c> loglineCreated = [Select Id,Name,ERP7__Product__c,ERP7__Order_Product__r.OrderId,ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Production_Version__c,ERP7__Production_Version__r.Id,ERP7__Production_Version__r.Name,ERP7__Order_Product__c,ERP7__Order_Product__r.OrderItemNumber,ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c,ERP7__Sales_Order_Line_Item__c from ERP7__Logistic_Line_Item__c where Id In : loglineIds and Logistic__c = :Logistic.Id];
                List<ERP7__Stock_Outward_Line_Item__c> SWLIToUpsert=new List<ERP7__Stock_Outward_Line_Item__c>();
                for(ERP7__Logistic_Line_Item__c log:loglineCreated){
                    
                    ERP7__Stock_Outward_Line_Item__c sto=new ERP7__Stock_Outward_Line_Item__c();
                    sto.Name=log.Name; 
                    if(log.ERP7__Order_Product__c != null){
                        sto.ERP7__Order_Product__c=log.ERP7__Order_Product__c;  
                        sto.ERP7__Order__c = log.ERP7__Order_Product__r.OrderId;  
                    }
                    else if(log.ERP7__Sales_Order_Line_Item__c != null){
                        sto.ERP7__Sales_Order_Line_Item__c = log.ERP7__Sales_Order_Line_Item__c;
                        sto.ERP7__Sales_Order__c = log.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c;
                    }
                    sto.ERP7__Product__c=log.ERP7__Product__c;
                    sto.ERP7__Active__c=true; 
                    sto.ERP7__Status__c='Reserved';
                    sto.ERP7__Quantity__c=log.ERP7__Quantity__c; 
                    if(proInv.get(log.ERP7__Product__c).ERP7__Batch_Lot__c != null) sto.ERP7__Material_Batch_Lot__c = proInv.get(log.ERP7__Product__c).ERP7__Batch_Lot__c;
                    if(proInv.get(log.ERP7__Product__c).ERP7__Serial__c != null) sto.ERP7__Serial__c = proInv.get(log.ERP7__Product__c).ERP7__Serial__c;
                    system.debug('proInv.get(log.ERP7__Product__c) : '+proInv.get(log.ERP7__Product__c));
                    sto.ERP7__Site_Product_Service_Inventory_Stock__c=proInv.get(log.ERP7__Product__c).Id;
                    sto.ERP7__Logistic_Line_Item__c=log.Id;
                    SWLIToUpsert.add(sto);
                    
                }
                if(SWLIToUpsert.size() > 0){ upsert SWLIToUpsert;}
                LogID =  Logistic.Id;
                system.debug('LogID : '+LogID);
                return LogID;
            } 
        }
        else return 'Select Line items to create Logistic';
        
        return LogID; 
    }
    /*public class wrapper{
@AuraEnabled public List<ERP7__Sales_Order__c> solist {get;set;}
@AuraEnabled public ERP7__Channel__c channel {get;set;}
@AuraEnabled public ERP7__Distribution_Channel__c Dchannel {get;set;}
@AuraEnabled public String Error {get;set;}
public wrapper(){
solist = new List<ERP7__Sales_Order__c>();
channel = new ERP7__Channel__c();
Dchannel = new ERP7__Distribution_Channel__c();
Error = '';
}
}*/
    public class logwrapper{
        @AuraEnabled public Logistic__c logistic {get; set;} 
        @AuraEnabled public List<ERP7__Logistic_Line_Item__c> logisticlines {get; set;}
        @AuraEnabled public Boolean StandardOrder {get; set;}
        public logwrapper(){
            logistic = new Logistic__c();
            logisticlines=new List<ERP7__Logistic_Line_Item__c>();
            StandardOrder = false;
        }
        
    }
    public class SOdata{
        @AuraEnabled  public List<SObject> SOlist { get;set;}
        @AuraEnabled  public Integer recsize { get;set;}
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        
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
    
}