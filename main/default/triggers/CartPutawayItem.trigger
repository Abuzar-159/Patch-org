trigger CartPutawayItem on Cart_Putaway_Item__c (after insert,after update) {
    Map<Id,Id> siliMap = new Map<Id,Id>();
    Map<Id,ERP7__Inventory_Stock__c> stockMap = new Map<Id,ERP7__Inventory_Stock__c>();
    Map<Id,ERP7__Inventory_Stock__c> SerialstockMap = new Map<Id,ERP7__Inventory_Stock__c>();
    List<Stock_Inward_Line_Item__c> InwardList = new List<Stock_Inward_Line_Item__c>();
    List<Inventory_Stock__c> InventoryStockList = new List<Inventory_Stock__c>();
    List<ERP7__Serial_Number__c> serial2update = new List<ERP7__Serial_Number__c>();
    set<Id> pid = new set<Id>();
    set<Id> FAid = new set<Id>();
    set<Id> siteids = new set<Id>();
    set<Id> locid = new set<Id>();
    for(Cart_Putaway_Item__c putawayItem : [SELECT Id, Name, Putaway_Quantity__c, To_Location__c, Site__c, Cart_Item__c, Cart_Item__r.Product__c, Cart_Item__r.ERP7__Serial_Number__c,Cart_Item__r.Batch_Lot__c, Cart_Item__r.Fixed_Asset__c,Cart_Item__r.ERP7__Inventory_Stock__c,Cart_Item__r.ERP7__Inventory_Stock__r.ERP7__Checked_In_Date__c FROM Cart_Putaway_Item__c WHERE Id IN: Trigger.newMap.keyset() AND Cart_Item__c != null]){
        if(putawayItem.Cart_Item__r.Product__c != null )pid.add(putawayItem.Cart_Item__r.Product__c);
        if(putawayItem.Cart_Item__r.Fixed_Asset__c != null )FAid.add(putawayItem.Cart_Item__r.Fixed_Asset__c);
        if(putawayItem.To_Location__c != null)locid.add(putawayItem.To_Location__c);
        if(putawayItem.Site__c != null)siteids.add(putawayItem.Site__c);
    }
    system.debug('siteids : '+siteids);
    system.debug('locid : '+locid);
    List<Inventory_Stock__c> invlist = new List<Inventory_Stock__c>();
    if(siteids.size() > 0 && locid.size() > 0){
        system.debug('1 inv');
        invlist = [SELECT Id,Name,Product__c,Fixed_Asset__c,ERP7__Batch_Lot__c,ERP7__Serial__c,ERP7__Location__c,ERP7__Warehouse__c FROM ERP7__Inventory_Stock__c WHERE (Fixed_Asset__c IN: FAid or Product__c IN: Pid) AND Warehouse__c IN: siteids AND Location__c IN: locid AND name != 'Awaiting Stock'];
    }
    else if(siteids.size() > 0){        system.debug('2 else inv');        invlist = [SELECT Id,Name,Product__c,Fixed_Asset__c,ERP7__Batch_Lot__c,ERP7__Serial__c,ERP7__Location__c,ERP7__Warehouse__c FROM ERP7__Inventory_Stock__c WHERE (Fixed_Asset__c IN: FAid or Product__c IN: Pid) AND Warehouse__c IN: siteids AND name != 'Awaiting Stock' AND Location__c = null]; /*added location null on 19 dec,24 shaguftha M*/    }
    
    system.debug('invlist : '+invlist.size());
    for(ERP7__Inventory_Stock__c Inv : invlist){
        stockMap.put(Inv.Product__c,Inv);
        if(Inv.ERP7__Serial__c != null) SerialstockMap.put(Inv.ERP7__Serial__c,Inv);
    }
    system.debug('stockMap : '+stockMap.size());
    system.debug('SerialstockMap: '+SerialstockMap.size());
    for(Stock_Inward_Line_Item__c inward : [SELECT Id,Cart_Putaway_Item__c FROM Stock_Inward_Line_Item__c WHERE Cart_Putaway_Item__c IN: Trigger.newMap.keyset()]) siliMap.put(inward.Cart_Putaway_Item__c,inward.Id); 
    
    for(Cart_Putaway_Item__c putawayItem : [SELECT Id, Name, Putaway_Quantity__c, To_Location__c, Site__c, Cart_Item__c, Cart_Item__r.Product__c,Cart_Item__r.Product__r.ERP7__Lot_Tracked__c,Cart_Item__r.Product__r.ERP7__Serialise__c,Cart_Item__r.Product__r.Name, Cart_Item__r.ERP7__Serial_Number__c,Cart_Item__r.Batch_Lot__c, Cart_Item__r.Fixed_Asset__c,Cart_Item__r.Fixed_Asset__r.Name,Cart_Item__r.ERP7__Inventory_Stock__r.ERP7__Checked_In_Date__c,Cart_Item__r.ERP7__Inventory_Stock__c FROM Cart_Putaway_Item__c WHERE Id IN: Trigger.newMap.keyset() AND Cart_Item__c != null]){
        system.debug('in for');
        String stockAddress = (putawayItem.Site__c != null)?putawayItem.Site__c:''; 
        if(putawayItem.Site__c != null && putawayItem.Cart_Item__r.ERP7__Serial_Number__c != null) {
            
            serial2update.add(new ERP7__Serial_Number__c(Id=putawayItem.Cart_Item__r.ERP7__Serial_Number__c,ERP7__Warehouse__c = putawayItem.Site__c,ERP7__Available__c = true));
            system.debug('serial2update 1 : '+serial2update);
        }
        ERP7__Inventory_Stock__c stock  = new ERP7__Inventory_Stock__c(); 
        //added checkedIndate and transferred date
        Stock.ERP7__Checked_In_Date__c = putawayItem.Cart_Item__r.ERP7__Inventory_Stock__r.ERP7__Checked_In_Date__c;
        Stock.ERP7__Transferred_Date__c = system.today();
        
        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Batch_Lot__c.isUpdateable()){stock.Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c;}else{/*No access*/}       
        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isUpdateable()){ stock.ERP7__Serial__c=putawayItem.Cart_Item__r.ERP7__Serial_Number__c;}else{/*No access*/}    
        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isUpdateable()){stock.Warehouse__c = putawayItem.Site__c;}else{/*No access*/}
        if(putawayItem.To_Location__c != null){
            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Location__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Location__c.isUpdateable()){stock.Location__c = putawayItem.To_Location__c ;  }else{/*No access*/}
            stockAddress += stock.Location__c;
        }
        ERP7__Stock_Inward_Line_Item__c sili = new ERP7__Stock_Inward_Line_Item__c(Id = siliMap.get(putawayItem.Id));        
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){sili.ERP7__Quantity__c  = putawayItem.ERP7__Putaway_Quantity__c;}else{/*No access*/}        
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){sili.ERP7__Serial__c = putawayItem.Cart_Item__r.ERP7__Serial_Number__c;}else{/*No access*/}        
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){sili.ERP7__Material_Batch_Lot__c  = putawayItem.Cart_Item__r.Batch_Lot__c;}else{/*No access*/}        
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Location__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Location__c.isUpdateable()){sili.ERP7__Location__c=putawayItem.To_Location__c;}else{/*No access*/}        
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Cart_Putaway_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Cart_Putaway_Item__c.isUpdateable()){sili.Cart_Putaway_Item__c = putawayItem.Id;}else{/*No access*/}
        if(putawayItem.Cart_Item__r.Product__c != null){
            if(stockMap.get(putawayItem.Cart_Item__r.Product__c) != null){
                system.debug('in for if');
                //====Modified by AK=====
                Boolean invAssign=false;
                if(putawayItem.Cart_Item__r.Batch_Lot__c != null && putawayItem.Cart_Item__r.ERP7__Serial_Number__c != null){                    if(putawayItem.Cart_Item__r.Batch_Lot__c != null && putawayItem.Cart_Item__r.ERP7__Serial_Number__c != null &&  putawayItem.To_Location__c != null && SerialstockMap.containsKey(putawayItem.Cart_Item__r.ERP7__Serial_Number__c) && (putawayItem.Cart_Item__r.Batch_Lot__c == SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).ERP7__Batch_Lot__c &&  putawayItem.Cart_Item__r.ERP7__Serial_Number__c == SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).ERP7__Serial__c) && putawayItem.To_Location__c ==SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).ERP7__Location__c){                        system.debug('Lot serial 1');                        sili.Site_ProductService_InventoryStock__c = SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).Id;                        stock.id = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;                          invAssign=true;                    }                    else if(putawayItem.Cart_Item__r.Batch_Lot__c != null && putawayItem.Cart_Item__r.ERP7__Serial_Number__c != null  && putawayItem.To_Location__c == null && SerialstockMap.containsKey(putawayItem.Cart_Item__r.ERP7__Serial_Number__c) && (putawayItem.Cart_Item__r.Batch_Lot__c == SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).ERP7__Batch_Lot__c &&  putawayItem.Cart_Item__r.ERP7__Serial_Number__c == SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).ERP7__Serial__c)){                        system.debug('Lot serial 2');                        sili.Site_ProductService_InventoryStock__c = SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).Id;                        stock.id = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;                          invAssign=true;                     }                 }
                
                else{
                    if(putawayItem.Cart_Item__r.Batch_Lot__c != null && putawayItem.Cart_Item__r.Batch_Lot__c == stockMap.get(putawayItem.Cart_Item__r.Product__c).ERP7__Batch_Lot__c && putawayItem.To_Location__c == stockMap.get(putawayItem.Cart_Item__r.Product__c).ERP7__Location__c){
                        system.debug('1');
                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){sili.Site_ProductService_InventoryStock__c = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;    }else{/*No access*/}    stock.id = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id; invAssign=true;
                    }else if(putawayItem.ERP7__To_Location__c != null && putawayItem.Cart_Item__r.ERP7__Serial_Number__c != null && SerialstockMap.containsKey(putawayItem.Cart_Item__r.ERP7__Serial_Number__c) && putawayItem.Cart_Item__r.ERP7__Serial_Number__c == SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).ERP7__Serial__c && putawayItem.To_Location__c == SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).ERP7__Location__c){
                        system.debug('2');
                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){sili.Site_ProductService_InventoryStock__c = SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).Id;    }else{/*No access*/}     stock.id = SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).Id; invAssign=true;
                    }
                    else if(putawayItem.Cart_Item__r.Batch_Lot__c != null && putawayItem.Cart_Item__r.Batch_Lot__c == stockMap.get(putawayItem.Cart_Item__r.Product__c).ERP7__Batch_Lot__c && putawayItem.To_Location__c == null){                        system.debug('1222');                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){sili.Site_ProductService_InventoryStock__c = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;    }else{/*No access*/}    stock.id = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id; invAssign=true;
                    }else if(putawayItem.ERP7__To_Location__c == null && putawayItem.Cart_Item__r.ERP7__Serial_Number__c != null && SerialstockMap.containsKey(putawayItem.Cart_Item__r.ERP7__Serial_Number__c) && putawayItem.Cart_Item__r.ERP7__Serial_Number__c == SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).ERP7__Serial__c){
                        system.debug('2222');                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){sili.Site_ProductService_InventoryStock__c = SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).Id;    }else{/*No access*/}     stock.id = SerialstockMap.get(putawayItem.Cart_Item__r.ERP7__Serial_Number__c).Id; invAssign=true;                    }
                    else if(!putawayItem.Cart_Item__r.Product__r.ERP7__Lot_Tracked__c && !putawayItem.Cart_Item__r.Product__r.ERP7__Serialise__c && putawayItem.To_Location__c == stockMap.get(putawayItem.Cart_Item__r.Product__c).ERP7__Location__c && stockMap.get(putawayItem.Cart_Item__r.Product__c).ERP7__Location__c != null){                   
                        system.debug('3');
                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){sili.Site_ProductService_InventoryStock__c = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id; }else{/*No access*/}   stock.id = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;  invAssign=true;                    }else if(putawayItem.ERP7__To_Location__c == null && putawayItem.Site__c == stockMap.get(putawayItem.Cart_Item__r.Product__c).ERP7__Warehouse__c && putawayItem.Cart_Item__r.ERP7__Serial_Number__c == null  ){                        system.debug('4');                     sili.Site_ProductService_InventoryStock__c = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;                        stock.id = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;                          invAssign=true;                    } 
                }
               
                system.debug('invAssign : '+invAssign);
                if(!invAssign){                     if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){string name = putawayItem.Cart_Item__r.Product__r.Name; if(name.length() > 80) stock.Name = name.substring(0,79); else stock.Name =putawayItem.Cart_Item__r.Product__r.Name;   }else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isUpdateable()){stock.Product__c = putawayItem.Cart_Item__r.Product__c;  }else{/*No access*/}    stockAddress += stock.Product__c;  stockAddress+=putawayItem.Id;    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Stock_Address__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Stock_Address__c.isUpdateable()){stock.Stock_Address__c = stockAddress; }else{/*No access*/}         if(siliMap.get(putawayItem.Id) == null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){  sili.Site_ProductService_InventoryStock__r = new ERP7__Inventory_Stock__c(Stock_Address__c = stockAddress);}else{/*No access*/}                }
                //====Modified by AK=====                
                //sili.Site_ProductService_InventoryStock__c = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;
                //stock.id = stockMap.get(putawayItem.Cart_Item__r.Product__c).Id;
                
                
                
            }else{
                system.debug('in for else'); 
                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){string name = putawayItem.Cart_Item__r.Product__r.Name; if(name.length() > 80) stock.Name = name.substring(0,79); else stock.Name = putawayItem.Cart_Item__r.Product__r.Name; }else{/*No access*/}     if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isUpdateable()){stock.Product__c = putawayItem.Cart_Item__r.Product__c; }else{/*No access*/}     stockAddress += stock.Product__c; stockAddress += putawayItem.Id;  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Stock_Address__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Stock_Address__c.isUpdateable()){stock.Stock_Address__c = stockAddress;}else{/*No access*/}      if(siliMap.get(putawayItem.Id) == null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){ sili.Site_ProductService_InventoryStock__r = new ERP7__Inventory_Stock__c(Stock_Address__c = stockAddress);}else{/*No access*/}
            }
            
            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){string name = putawayItem.Cart_Item__r.Product__r.Name; if(name.length() > 80) sili.Name = name.substring(0,79); else sili.Name = putawayItem.Cart_Item__r.Product__r.Name;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isUpdateable()){sili.Product__c = putawayItem.Cart_Item__r.Product__c; }else{/*No access*/}        }else if(putawayItem.Cart_Item__r.Fixed_Asset__c != null){            if(stockMap.get(putawayItem.Cart_Item__r.ERP7__Fixed_Asset__c) != null){                  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){sili.Site_ProductService_InventoryStock__c = stockMap.get(putawayItem.Cart_Item__r.ERP7__Fixed_Asset__c).Id;  }else{/*No access*/}                stock.id = stockMap.get(putawayItem.Cart_Item__r.ERP7__Fixed_Asset__c).Id;            }else{                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){stock.Name = putawayItem.Cart_Item__r.Fixed_Asset__r.Name; }else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Fixed_Asset__c.isUpdateable()){stock.Fixed_Asset__c = putawayItem.Cart_Item__r.Fixed_Asset__c; }else{/*No access*/}  stockAddress += stock.Fixed_Asset__c;   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Stock_Address__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Stock_Address__c.isUpdateable()){stock.Stock_Address__c = stockAddress; }else{/*No access*/}   if(siliMap.get(putawayItem.Id) == null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()){ sili.Site_ProductService_InventoryStock__r = new ERP7__Inventory_Stock__c(Stock_Address__c = stockAddress);}else{/*No access*/}            }            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){sili.Name = putawayItem.Cart_Item__r.Fixed_Asset__r.Name;  }else{/*No access*/}            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Fixed_Asset__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Fixed_Asset__c.isUpdateable()){sili.ERP7__Fixed_Asset__c = putawayItem.Cart_Item__r.ERP7__Fixed_Asset__c;}else{/*No access*/}        }
        if(siliMap.get(putawayItem.Id) == null)
            InventoryStockList.add(stock);
        InwardList.add(sili);   
    }
    
    if(InventoryStockList.size()> 0 && Schema.SObjectType.Inventory_Stock__c.isCreateable() && Schema.SObjectType.Inventory_Stock__c.isUpdateable()){upsert InventoryStockList;}else{/*not allower to upsert*/}
    
    if(InwardList.size()> 0 && Schema.SObjectType.Stock_Inward_Line_Item__c.isCreateable() && Schema.SObjectType.Stock_Inward_Line_Item__c.isUpdateable()){upsert InwardList;}else{ /*not allower to upsert*/}
    if(serial2update.size() > 0) update serial2update;
    
}