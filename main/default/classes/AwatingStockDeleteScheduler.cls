public class AwatingStockDeleteScheduler implements Schedulable{
	public void execute(SchedulableContext b) {       
       try{
          List<ERP7__Inventory_Stock__c> invtodelete = new List<ERP7__Inventory_Stock__c>();
           set<Id> awaitingInventory = new set<Id>();
             List<ERP7__Stock_Inward_Line_Item__c> allAwaitingstin = [Select Id,ERP7__Quantity__c,ERP7__Site_ProductService_InventoryStock__c,Name,ERP7__Manufacturing_Order__c,ERP7__Purchase_Orders__c,ERP7__Manufacturing_Order__r.ERP7__Status__c,ERP7__Purchase_Orders__r.ERP7__Status__c,ERP7__Purchase_Orders__r.ERP7__Is_Closed__c from ERP7__Stock_Inward_Line_Item__c where Name='Awaiting Stock' and ERP7__Status__c = 'Awaiting Stock' and (ERP7__Manufacturing_Order__c != null or ERP7__Purchase_Orders__c != null) and ERP7__Quantity__c = 0];
           system.debug('allAwaitingstin : '+allAwaitingstin.size());
           if(allAwaitingstin.size() > 0){
               for(ERP7__Stock_Inward_Line_Item__c stin : allAwaitingstin){
                   system.debug('stin.ERP7__Manufacturing_Order__c : '+stin.ERP7__Manufacturing_Order__c);
                   system.debug('stin.ERP7__Purchase_Orders__c : '+stin.ERP7__Purchase_Orders__c);
                   if(stin.ERP7__Manufacturing_Order__c != null){
                       if(stin.ERP7__Manufacturing_Order__r.ERP7__Status__c == 'Complete' && stin.ERP7__Quantity__c == 0) { system.debug('MO If executed '); awaitingInventory.add(stin.ERP7__Site_ProductService_InventoryStock__c); }
                   }
                   else if(stin.ERP7__Purchase_Orders__c != null){
                       if(stin.ERP7__Purchase_Orders__r.ERP7__Status__c == 'Closed' && stin.ERP7__Purchase_Orders__r.ERP7__Is_Closed__c && stin.ERP7__Quantity__c == 0) {system.debug('PO If executed '); awaitingInventory.add(stin.ERP7__Site_ProductService_InventoryStock__c); }
                   }
               }
               system.debug('awaitingInventory : '+awaitingInventory.size());
               if(awaitingInventory.size() > 0){
                   invtodelete = [Select Id,Name from ERP7__Inventory_Stock__c where Id In:awaitingInventory and ERP7__Number_of_Items_Awaiting_in_Stock__c = 0 and ERP7__Number_of_Item_In_Stock__c = 0];
                   system.debug('invtodelete : '+invtodelete.size());
                   if(invtodelete.size() > 0) database.delete(invtodelete);
               }
           }
       }catch(Exception e){
           system.debug('Exception-->'+e+e.getLineNumber());
       }  
        
        DateTime dtime = system.now().addMinutes(120);
        String day = string.valueOf(dtime.day());
        String month = string.valueOf(dtime.month());
        String hour = string.valueOf(dtime.hour());
        String minute = string.valueOf(dtime.minute());
        String second = string.valueOf(dtime.second());
        String year = string.valueOf(dtime.year());        
        String strJobName = 'AwatingStockDeleteScheduler '+ day + '/' + month + '/' + year + ' ' + hour + ':' + minute;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new AwatingStockDeleteScheduler());
        system.abortJob(b.getTriggerId()); 
    } 
}