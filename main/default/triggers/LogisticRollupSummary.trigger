/* changed by shaguftha ON 01-06-22 to add the functionality to remove stock outward when logitsic is deleted*/
/* changed by shaguftha ON 20-11-24 to add the functionality to remove stock outward when logitsic is deleted based on the logistic line items not order product*/
trigger LogisticRollupSummary on ERP7__Logistic__c (before delete) { //after insert, after update, after delete, after undelete,
    
    if(Trigger.isDelete){
        
        for (ERP7__Logistic__c logistic : Trigger.old) {
            if (logistic.ERP7__Type__c == 'Inbound') {
                Decimal putawayQty = logistic.ERP7__Putaway_Quantity__c != null ? logistic.ERP7__Putaway_Quantity__c : 0;
                Decimal receivedQty = logistic.ERP7__Received_Quantity__c != null ? logistic.ERP7__Received_Quantity__c : 0;

                if (putawayQty > 0 || receivedQty > 0) {
                  //  logistic.addError('Inbound logistic record cannot be deleted as quantities are already received, or partially received.');
                }
            }
        }
    
        List<ERP7__Logistic_Line_Item__c> stkli = [Select Id,Name,ERP7__Order_Product__c,ERP7__Sales_Order_Line_Item__c,ERP7__Purchase_Line_Items__c,ERP7__Quantity__c from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c in :Trigger.oldMap.keySet() and (ERP7__Order_Product__c != null or ERP7__Sales_Order_Line_Item__c != null or ERP7__Purchase_Line_Items__c != null)];
        system.debug('stkli : '+stkli.size());
        if(stkli.size() > 0){
            set<Id> orderIds = new set<Id>();
            set<Id> SalesIds = new set<Id>();
            set<id> poIDs = new set<Id>();

            Map<Id,Decimal> ordLog = new Map<Id,Decimal>();
            Map<Id,Decimal> SordLog = new Map<Id,Decimal>();
            Map<Id,Decimal> pordLog = new Map<Id,Decimal>();

            set<Id> loglineIds = new set<Id>();
            for(ERP7__Logistic_Line_Item__c stkl : stkli){
                loglineIds.add(stkl.Id);
                if(stkl.ERP7__Order_Product__c != null)  { orderIds.add(stkl.ERP7__Order_Product__c);  if(ordLog.containskey(stkl.ERP7__Order_Product__c)){ decimal total = ordLog.get(stkl.ERP7__Order_Product__c) + stkl.ERP7__Quantity__c; ordLog.put(stkl.ERP7__Order_Product__c, total); } else ordLog.put(stkl.ERP7__Order_Product__c, stkl.ERP7__Quantity__c); }
                if(stkl.ERP7__Sales_Order_Line_Item__c != null)  { SalesIds.add(stkl.ERP7__Sales_Order_Line_Item__c); if(SordLog.containskey(stkl.ERP7__Sales_Order_Line_Item__c)){decimal total =SordLog.get(stkl.ERP7__Sales_Order_Line_Item__c) + stkl.ERP7__Quantity__c; SordLog.put(stkl.ERP7__Sales_Order_Line_Item__c, total);} else SordLog.put(stkl.ERP7__Sales_Order_Line_Item__c, stkl.ERP7__Quantity__c);}
                if(stkl.ERP7__Purchase_Line_Items__c != null)  { poIDS.add(stkl.ERP7__Purchase_Line_Items__c);  if(pordLog.containskey(stkl.ERP7__Purchase_Line_Items__c)){ decimal total = pordLog.get(stkl.ERP7__Purchase_Line_Items__c) + stkl.ERP7__Quantity__c; ordLog.put(stkl.ERP7__Purchase_Line_Items__c, total); } else pordLog.put(stkl.ERP7__Purchase_Line_Items__c, stkl.ERP7__Quantity__c); }
            }
            system.debug('orderIds : '+orderIds.size());
            system.debug('SalesIds : '+SalesIds.size());
            system.debug('pordLog : '+pordLog.size());
            if(orderIds.size() > 0) {
                List<OrderItem> itemlst2update = new List<OrderItem>();
                List<OrderItem> itemlst = [Select Id,ERP7__Logistic_Quantity__c from OrderItem where ID In :orderIds]; 
                if(itemlst.size() > 0){
                    for(OrderItem od : itemlst){
                        if(od.ERP7__Logistic_Quantity__c != null && od.ERP7__Logistic_Quantity__c > 0 &&  ordLog.containsKey(od.Id)) {
                            system.debug('ordLog.get(od.Id) : '+ordLog.get(od.Id));
                            system.debug('od.ERP7__Logistic_Quantity__c before : '+od.ERP7__Logistic_Quantity__c); 
                            od.ERP7__Logistic_Quantity__c = od.ERP7__Logistic_Quantity__c - ordLog.get(od.Id); 
                            //od.ERP7__Logistic_Quantity__c = ordLog.get(od.Id) - od.ERP7__Logistic_Quantity__c;  //commented by Arshad 16/03/23 - was calculating wrong ERP7__Logistic_Quantity__c
                            itemlst2update.add(od); 
                        }
                    }
                    system.debug('itemlst2update.size() : '+itemlst2update.size());
                    if(itemlst2update.size() > 0) {PreventRecursiveLedgerEntry.Loged = true; PreventRecursiveLedgerEntry.LogisticLineRollup = false; PreventRecursiveLedgerEntry.testCasesTransactions = true; update itemlst2update; } 
                }
            }
            if(SalesIds.size() > 0) {
                List<ERP7__Sales_Order_Line_Item__c> itemlst2update = new List<ERP7__Sales_Order_Line_Item__c>();
                List<ERP7__Sales_Order_Line_Item__c> itemlst = [Select Id,Name,ERP7__Logistic_Quantity__c from ERP7__Sales_Order_Line_Item__c where ID In :SalesIds]; 
                if(itemlst.size() > 0){
                    for(ERP7__Sales_Order_Line_Item__c od : itemlst){
                        if(od.ERP7__Logistic_Quantity__c != null && od.ERP7__Logistic_Quantity__c > 0 && SordLog.containsKey(od.Id)) { od.ERP7__Logistic_Quantity__c = SordLog.get(od.Id) - od.ERP7__Logistic_Quantity__c; itemlst2update.add(od); system.debug('** Sales od.ERP7__Logistic_Quantity__c : '+od.ERP7__Logistic_Quantity__c);}
                    }
                    system.debug('itemlst2update : '+itemlst2update.size());
                    if(itemlst2update.size() > 0) { PreventRecursiveLedgerEntry.Loged = true; PreventRecursiveLedgerEntry.LogisticLineRollup = false; PreventRecursiveLedgerEntry.testCasesTransactions = true;  update itemlst2update; }
                }
            }
            //added this by matheen on 7/8/25 for GIIH-687
              if(poIDS.size() > 0) {
                List<ERP7__Purchase_Line_Items__c> itemlst2update = new List<ERP7__Purchase_Line_Items__c>();
                List<ERP7__Purchase_Line_Items__c> itemlst = [Select Id,ERP7__Logistic_Quantity__c from ERP7__Purchase_Line_Items__c where ID In :poIDS]; 
                if(itemlst.size() > 0){
                    for(ERP7__Purchase_Line_Items__c PLI : itemlst){
                        if(PLI.ERP7__Logistic_Quantity__c != null && PLI.ERP7__Logistic_Quantity__c > 0 &&  pordLog.containsKey(PLI.Id)) {
                            system.debug('pordLog.get(PLI.Id) : '+pordLog.get(PLI.Id));
                            system.debug('PLI.ERP7__Logistic_Quantity__c before : '+PLI.ERP7__Logistic_Quantity__c); 
                            PLI.ERP7__Logistic_Quantity__c = PLI.ERP7__Logistic_Quantity__c - pordLog.get(PLI.Id); 
                            System.debug('PLI.ERP7__Logistic_Quantity__c AFR'+PLI.ERP7__Logistic_Quantity__c);
                            //PLI.ERP7__Logistic_Quantity__c = pordLog.get(PLI.Id) - PLI.ERP7__Logistic_Quantity__c;  //commented by Arshad 16/03/23 - was calculating wrong ERP7__Logistic_Quantity__c
                            itemlst2update.add(PLI); 
                        }
                    }
                    system.debug('itemlst2update.size() : '+itemlst2update.size());
                    if(itemlst2update.size() > 0) {PreventRecursiveLedgerEntry.Loged = true; PreventRecursiveLedgerEntry.LogisticLineRollup = false; PreventRecursiveLedgerEntry.testCasesTransactions = true; update itemlst2update; } 
                }
            }
            List<ERP7__Stock_Outward_Line_Item__c> soli = [Select Id,Name from ERP7__Stock_Outward_Line_Item__c where ERP7__Active__c = true and ERP7__Logistic_Line_Item__c IN :loglineIds] ; //(ERP7__Order_Product__c In :orderIds or ERP7__Sales_Order_Line_Item__c In :SalesIds)
            List<ERP7__Stock_Inward_Line_Item__c> sili = [Select Id,Name from ERP7__Stock_Inward_Line_Item__c where ERP7__Active__c = true and  ERP7__Purchase_Line_Items__c IN :poIDS] ; 
            system.debug('soli : '+soli.size());
            System.debug('sili :'+sili.size());
            if(soli.size() > 0) delete soli;
            if(sili.size() > 0) {delete sili;
            System.debug('Deleted sucessfully');}
        }
    }
    
    /*
List<ERP7__Logistic__c> Logs = (trigger.isDelete)? trigger.old : trigger.new; 
Map<Id, ERP7__PO__c> poMap = new Map<Id, ERP7__PO__c>();
for(ERP7__Logistic__c Logistic : Logs){
if(Logistic.ERP7__Purchase_Order__c != Null) poMap.put(Logistic.ERP7__Purchase_Order__c, new ERP7__PO__c(Id=Logistic.ERP7__Purchase_Order__c, ERP7__Inbound_Total_Quantity__c=0, ERP7__Inbound_Received_Quantity__c=0));
}
if(poMap.size() > 0){
List<ERP7__Logistic__c> Logistics = [Select Id, Name, ERP7__Purchase_Order__c , ERP7__Received_Quantity__c, ERP7__Total_Quantity__c 
From ERP7__Logistic__c Where (ERP7__Purchase_Order__c != Null And ERP7__Purchase_Order__c In :poMap.keySet())];
for(ERP7__Logistic__c Logistic :Logistics){
if(poMap.containsKey(Logistic.ERP7__Purchase_Order__c)){
ERP7__PO__c PO = poMap.get(Logistic.ERP7__Purchase_Order__c);
if(Logistic.ERP7__Received_Quantity__c != Null) PO.ERP7__Inbound_Received_Quantity__c += Logistic.ERP7__Received_Quantity__c;
if(Logistic.ERP7__Total_Quantity__c != Null) PO.ERP7__Inbound_Total_Quantity__c += Logistic.ERP7__Total_Quantity__c;
poMap.put(Logistic.ERP7__Purchase_Order__c, PO);
}
} 
try{ if(poMap.values().size() > 0) update poMap.values(); } catch(exception e){ }
}
*/
}