/*
* CreatedBy - Arshad
* LastModifiedBy - Arshad
* LastModifiedDate - 14/06/2023
*/
/*
* Modified by - Shaguftha
* LastModifiedBy - Shaguftha
* changes - added preventShipmentcounterTrigger to avoid execute from test class
* LastModifiedDate - 29/07/2024
*/

trigger ShipmentAutoNumberTrigger on ERP7__Shipment__c (before insert) {
    if(PreventRecursiveLedgerEntry.preventShipmentcounterTrigger){
        PreventRecursiveLedgerEntry.preventShipmentcounterTrigger = false;
        List<ERP7__Custom_Auto_Number_Counter__c> CommercialInvShipmentCounter = [Select Id, Name, ERP7__Counter__c, ERP7__Field_Name__c, ERP7__Object_Name__c from ERP7__Custom_Auto_Number_Counter__c 
                                                                                  Where ERP7__Object_Name__c = 'ERP7__Shipment__c' AND ERP7__Field_Name__c = 'ERP7__Commercial_Invoice_Number__c'];
        
        ERP7__Custom_Auto_Number_Counter__c CommercialInvShipmentCounter2Upsert = new ERP7__Custom_Auto_Number_Counter__c();
        Integer CommInvShipcounter = 1;
        
        if(CommercialInvShipmentCounter.size() > 0){
            CommercialInvShipmentCounter2Upsert = CommercialInvShipmentCounter[0];
            if(CommercialInvShipmentCounter[0].ERP7__Counter__c != null){
                CommInvShipcounter = Integer.valueOf(CommercialInvShipmentCounter[0].ERP7__Counter__c) + 1;
            }
        }else{
            CommercialInvShipmentCounter2Upsert.Name = 'Shipment-CommercialInvoiceNumber';
            CommercialInvShipmentCounter2Upsert.ERP7__Field_Name__c = 'ERP7__Commercial_Invoice_Number__c';
            CommercialInvShipmentCounter2Upsert.ERP7__Object_Name__c = 'ERP7__Shipment__c';
            //CommercialInvShipmentCounter2Upsert.ERP7__Counter__c = CommInvShipcounter;
        }
        
        String prefix1 = System.Label.CommercialInvoiceAutoNumberPrefix;
        
        for (ERP7__Shipment__c ship : Trigger.new) {
            ship.ERP7__Commercial_Invoice_Number__c = prefix1 + String.valueOf(CommInvShipcounter).leftPad(4, '0');
            CommInvShipcounter++;
        }
        
        CommercialInvShipmentCounter2Upsert.ERP7__Counter__c = CommInvShipcounter - 1;
        upsert CommercialInvShipmentCounter2Upsert;
    }
}