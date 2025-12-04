public class HandleFailedSerialsQueueable implements System.Queueable {
    private List<ERP7__Serial_Number__c> failedRecords;
    
    public HandleFailedSerialsQueueable(List<ERP7__Serial_Number__c> failedRecords) {
        this.failedRecords = failedRecords;
    }
    
    public void execute(System.QueueableContext context) {
        system.debug('PreventRecursiveLedgerEntry.preventHandlingFailedSerials'+PreventRecursiveLedgerEntry.preventHandlingFailedSerials);
        if(PreventRecursiveLedgerEntry.preventHandlingFailedSerials){
            set<Id> serialsIds = new set<Id>();
            List<ERP7__Serial_Number__c> ser2update = new List<ERP7__Serial_Number__c>();
            
            for(ERP7__Serial_Number__c ser : failedRecords){
                System.debug('Processing failed record: ' + ser.Id);
                serialsIds.add(ser.Id);
                
            }
            List<ERP7__Inventory_Stock__c> invlist = [select Id,Name,ERP7__Serial__c from ERP7__Inventory_Stock__c where ERP7__Serial__c != null AND ERP7__Serial__c IN : serialsIds];
            system.debug('invlist : '+invlist.size());
            Map<Id,ERP7__Inventory_Stock__c> invMAp = new Map<Id,ERP7__Inventory_Stock__c>();
            for(ERP7__Inventory_Stock__c inv : invlist){
                invMAp.put(inv.ERP7__Serial__c,inv);
            }
            
            for(ERP7__Serial_Number__c ser : failedRecords){
                if(!invMAp.containskey(ser.Id)){
                    ERP7__Serial_Number__c sernew = new ERP7__Serial_Number__c(Id = ser.Id);
                    ser2update.add(sernew) ;
                }
            }
            system.debug('ser2update : '+ser2update.size());
            PreventRecursiveLedgerEntry.ProceedSerialsTrigger = true;
            if(ser2update.size() > 0) {
                update ser2update;
                PreventRecursiveLedgerEntry.preventHandlingFailedSerials = false;
            }
                        
        }
        
    }
    
}