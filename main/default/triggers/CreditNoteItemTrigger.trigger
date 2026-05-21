trigger CreditNoteItemTrigger on ERP7__Credit_Note_Item__c (after insert, after update, after delete, after undelete) {
    try{ 
        Set<Id> invoiceLineIds = new Set<Id>();
        
        // Get Invoice Line Item IDs from trigger context (insert/update/delete)
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            for (Credit_Note_Item__c cn : Trigger.new) {
                if (cn.Invoice_Line_Item__c != null) {
                    invoiceLineIds.add(cn.Invoice_Line_Item__c);
                }
            }
        } else if (Trigger.isDelete) {  for (Credit_Note_Item__c cn : Trigger.old) {   if (cn.Invoice_Line_Item__c != null) { invoiceLineIds.add(cn.Invoice_Line_Item__c);
                }
            }
        }
        System.debug('Invoice Line IDs: ' + invoiceLineIds);
        
        // Step 2: Map Invoice Line → Order Product (SOLI)
        Map<Id, Id> invoiceLineToSoliMap = new Map<Id, Id>();
        Set<Id> soliIds = new Set<Id>();
        
        for (ERP7__Invoice_Line_Item__c ili : [
            SELECT Id, ERP7__Order_Product__c
            FROM ERP7__Invoice_Line_Item__c
            WHERE Id IN :invoiceLineIds
        ]) {
            //invoiceLineToSoliMap.put(ili.Id, ili.ERP7__Order_Product__c);
            soliIds.add(ili.ERP7__Order_Product__c);
        }
        System.debug('SOLI IDs: ' + soliIds);
        
        // Step 3: Get Total Invoice Quantity per SOLI
        Map<Id, Decimal> soliToTotalInvoiceQty = new Map<Id, Decimal>();
        Set<Id> allInvoiceLineItemIds = new Set<Id>();
        
        for (ERP7__Invoice_Line_Item__c ili : [
            SELECT Id, ERP7__Quantity__c, ERP7__Order_Product__c
            FROM ERP7__Invoice_Line_Item__c
            WHERE ERP7__Order_Product__c IN :soliIds and ERP7__Invoice__r.RecordType.Name='Sales'
        ]) {
            invoiceLineToSoliMap.put(ili.Id, ili.ERP7__Order_Product__c); Id soliId = ili.ERP7__Order_Product__c;
     Decimal qty = ili.ERP7__Quantity__c != null ? ili.ERP7__Quantity__c : 0;
            
            allInvoiceLineItemIds.add(ili.Id);
            
            soliToTotalInvoiceQty.put(
                soliId,
                soliToTotalInvoiceQty.containsKey(soliId)
                ? soliToTotalInvoiceQty.get(soliId) + qty
                : qty
            );
        }
        System.debug('Total Invoice Quantity per SOLI: ' + soliToTotalInvoiceQty);
        
        // Step 4: Get Total Credit Quantity per SOLI (from DB only)
        Map<Id, Decimal> soliToTotalCreditQty = new Map<Id, Decimal>();
        
        for (Credit_Note_Item__c cni : [
            SELECT Id, Quantity__c, Invoice_Line_Item__c
            FROM Credit_Note_Item__c
            WHERE Invoice_Line_Item__c IN :allInvoiceLineItemIds
        ]) {
            Id invLineId = cni.Invoice_Line_Item__c; if (!invoiceLineToSoliMap.containsKey(invLineId)) continue;
            
            Id soliId = invoiceLineToSoliMap.get(invLineId);  Decimal qty = cni.Quantity__c != null ? cni.Quantity__c : 0;
            
            soliToTotalCreditQty.put(
                soliId,
                soliToTotalCreditQty.containsKey(soliId)
                ? soliToTotalCreditQty.get(soliId) + qty
                : qty
            );
        }
        System.debug('Total Credit Quantity per SOLI: ' + soliToTotalCreditQty);
        
        // Step 5: Compute final invoiced quantity per SOLI
        Map<Id, Decimal> soliToFinalQty = new Map<Id, Decimal>();
        for (Id soliId : soliToTotalInvoiceQty.keySet()) {
            Decimal invoiceQty = soliToTotalInvoiceQty.get(soliId); Decimal creditQty = soliToTotalCreditQty.get(soliId) != null ? soliToTotalCreditQty.get(soliId) : 0;
            
            soliToFinalQty.put(soliId, invoiceQty - creditQty);
        }
        System.debug('Final Invoiced Quantity per SOLI: ' + soliToFinalQty);
        
        // Step 6: Update OrderItem (SOLI)
        Map<Id, OrderItem> soliRecords = new Map<Id, OrderItem>(
            [SELECT Id, ERP7__Invoiced_Quantity__c FROM OrderItem WHERE Id IN :soliIds]
        );
        
        List<OrderItem> updates = new List<OrderItem>();
        for (Id soliId : soliToFinalQty.keySet()) {
            if (!soliRecords.containsKey(soliId)) continue;
            
            OrderItem so = soliRecords.get(soliId);so.ERP7__Invoiced_Quantity__c = soliToFinalQty.get(soliId); updates.add(so);
        }
        
        if (!updates.isEmpty()) {
            update updates;
        }
        
    }catch(Exception ex){
        System.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString());
        String exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString(); 
    }  
    
}