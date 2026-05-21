public class MaterialBatchStockInwardProcessor {
    private static Set<Id> processedBatchIds = new Set<Id>();

    public class StockInwardResult {
        @InvocableVariable public Decimal totalCost;
        @InvocableVariable public List<String> inwardSites;
    }

    @InvocableMethod(label='Process Stock Inward' description='Calculates total cost and available sites')
    public static List<StockInwardResult> processStockInward(List<Id> batchLotIds) {
        try {
            List<StockInwardResult> results = new List<StockInwardResult>();
            List<Id> batchLotIdsToUpdate = new List<Id>(); 
            Map<Id, StockInwardResult> batchLotResults = new Map<Id, StockInwardResult>();

            List<ERP7__Stock_Inward_Line_Item__c> inwardLineItems = [
                SELECT Id, ERP7__Purchase_Line_Items__c, ERP7__Purchase_Line_Items__r.ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c  
                FROM ERP7__Stock_Inward_Line_Item__c
                WHERE ERP7__Material_Batch_Lot__c IN :batchLotIds AND ERP7__Active__c = true AND (ERP7__Purchase_Line_Items__c != null OR ERP7__Material_Batch_Lot__c != null)];

            Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> batchLotToLineItems = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>();
            for (ERP7__Stock_Inward_Line_Item__c stockInw : inwardLineItems) {
                if (!batchLotToLineItems.containsKey(stockInw.ERP7__Material_Batch_Lot__c)) {
                    batchLotToLineItems.put(stockInw.ERP7__Material_Batch_Lot__c, new List<ERP7__Stock_Inward_Line_Item__c>());
                }
                batchLotToLineItems.get(stockInw.ERP7__Material_Batch_Lot__c).add(stockInw);
            }

            for (Id batchLotId : batchLotIds) {
                if (processedBatchIds.contains(batchLotId)) {
                    System.debug('Skipping already processed batch lot ID ' + batchLotId);
                    continue;
                }
                processedBatchIds.add(batchLotId);

                List<ERP7__Stock_Inward_Line_Item__c> inwardLineItemsForBatch = batchLotToLineItems.get(batchLotId);

                Decimal totalCost = 0;
                List<String> inwardSites = new List<String>();

                for (ERP7__Stock_Inward_Line_Item__c stockInw : inwardLineItemsForBatch) {
                    if (stockInw.ERP7__Purchase_Line_Items__c != null && stockInw.ERP7__Purchase_Line_Items__r.ERP7__Unit_Price__c != null) {
                        totalCost += stockInw.ERP7__Purchase_Line_Items__r.ERP7__Unit_Price__c;
                    }
                    if (stockInw.ERP7__Site_ProductService_InventoryStock__r != null && stockInw.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c != null) {
                        inwardSites.add(stockInw.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c);
                    }
                }

                System.debug('totalCost--- ' + totalCost);
                System.debug('inwardSites--- ' + inwardSites);

                StockInwardResult result = new StockInwardResult();
                result.totalCost = totalCost;
                result.inwardSites = new List<String>(new Set<String>(inwardSites));
                results.add(result);
                batchLotResults.put(batchLotId, result);
                batchLotIdsToUpdate.add(batchLotId);
            }

            // Perform immediate updates
            if (!batchLotIdsToUpdate.isEmpty()) {
                updateBatchLots(batchLotIdsToUpdate, batchLotResults);
            }

            return results;

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + ' at line ' + e.getLineNumber());
            return new List<StockInwardResult>();
        }
    }

    // Updated method to run synchronously
    private static void updateBatchLots(List<Id> batchLotIds, Map<Id, StockInwardResult> batchLotResults) {
        try {
            List<ERP7__Batch__c> batchLots = [
                SELECT Id, ERP7__Cost_Price__c, ERP7__Received_site__c, ERP7__Inward_Quantity__c
                FROM ERP7__Batch__c
                WHERE Id IN :batchLotIds
            ];

            for (ERP7__Batch__c batchLot : batchLots) {
                StockInwardResult result = batchLotResults.get(batchLot.Id);
                if (result != null) {
                    if (batchLot.ERP7__Inward_Quantity__c != null) {
                        batchLot.ERP7__Cost_Price__c = result.totalCost * batchLot.ERP7__Inward_Quantity__c;
                        system.debug('batchLot.ERP7__Inward_Quantity__c----'+batchLot.ERP7__Inward_Quantity__c);
                        system.debug('ERP7__Cost_Price__c----'+batchLot.ERP7__Cost_Price__c);
                    }
                    
                    batchLot.ERP7__Received_site__c = String.join(new Set<String>(result.inwardSites), ', ').trim().left(254);
                }
            }

            if (!batchLots.isEmpty()) {
                Database.update(batchLots, false); // Allows partial updates
            }

        } catch (Exception e) {
            System.debug('Update Method Exception: ' + e.getMessage());
        }
    }
}

/*public class MaterialBatchStockInwardProcessor {
    // Static Set to track processed batch IDs in the same transaction
    private static Set<Id> processedBatchIds = new Set<Id>();

    public class StockInwardResult {
        @InvocableVariable public Decimal totalCost;
        @InvocableVariable public List<String> inwardSites;
    }

    @InvocableMethod(label='Process Stock Inward' description='Calculates total cost and available sites')
    public static List<StockInwardResult> processStockInward(List<Id> batchLotIds) {
        try {
            List<StockInwardResult> results = new List<StockInwardResult>();
            List<Id> batchLotIdsToUpdate = new List<Id>(); 
            Map<Id, StockInwardResult> batchLotResults = new Map<Id, StockInwardResult>();

            List<ERP7__Stock_Inward_Line_Item__c> inwardLineItems = [
                SELECT Id, ERP7__Purchase_Line_Items__c, 
                       ERP7__Purchase_Line_Items__r.ERP7__Unit_Price__c, 
                       ERP7__Material_Batch_Lot__c, 
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c  
                FROM ERP7__Stock_Inward_Line_Item__c
                WHERE ERP7__Material_Batch_Lot__c IN :batchLotIds 
                      AND ERP7__Active__c = true 
                      AND (ERP7__Purchase_Line_Items__c != null OR ERP7__Material_Batch_Lot__c != null)
            ];

            // Map to group line items by Material_Batch_Lot__c (batchLotId)
            Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> batchLotToLineItems = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>();
            for (ERP7__Stock_Inward_Line_Item__c stockInw : inwardLineItems) {
                if (!batchLotToLineItems.containsKey(stockInw.ERP7__Material_Batch_Lot__c)) {
                    batchLotToLineItems.put(stockInw.ERP7__Material_Batch_Lot__c, new List<ERP7__Stock_Inward_Line_Item__c>());
                }
                batchLotToLineItems.get(stockInw.ERP7__Material_Batch_Lot__c).add(stockInw);
            }

            for (Id batchLotId : batchLotIds) {
                if (processedBatchIds.contains(batchLotId)) {
                    System.debug('Skipping already processed batch lot ID ' + batchLotId);
                    continue; // Prevent recursive updates
                }
                processedBatchIds.add(batchLotId); // Mark as processed

                // Fetch related line items for this batch lot
                List<ERP7__Stock_Inward_Line_Item__c> inwardLineItemsForBatch = batchLotToLineItems.get(batchLotId);

                Decimal totalCost = 0;
                List<String> inwardSites = new List<String>();

                for (ERP7__Stock_Inward_Line_Item__c stockInw : inwardLineItemsForBatch) {
                    if (stockInw.ERP7__Purchase_Line_Items__c != null && stockInw.ERP7__Purchase_Line_Items__r != null) {
                        totalCost += stockInw.ERP7__Purchase_Line_Items__r.ERP7__Unit_Price__c;
                    }
                    if (stockInw.ERP7__Site_ProductService_InventoryStock__r != null) {
                        inwardSites.add(stockInw.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c);
                    }
                }

                system.debug('totalCost--- ' + totalCost);
                system.debug('inwardSites--- ' + inwardSites);

                // Store results in a map for future method
                StockInwardResult result = new StockInwardResult();
                result.totalCost = totalCost;
                result.inwardSites = new List<String>(new Set<String>(inwardSites));
                results.add(result);
                batchLotResults.put(batchLotId, result);

                // Mark the batch lot for update in the future
                batchLotIdsToUpdate.add(batchLotId);
            }

            // Serialize the results to JSON and pass to future method
            if (!batchLotIdsToUpdate.isEmpty()) {
                system.debug('batchLotIdsToUpdate is not empty---   ');
                String serializedResults = JSON.serialize(batchLotResults); // Serialize Map
                system.debug('serializedResults== ' + serializedResults);
                system.debug('batchLotIdsToUpdate== ' + batchLotIdsToUpdate);
                updateBatchLots(batchLotIdsToUpdate, serializedResults);
                system.debug('Future method call finished.');
            }

            return results;

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + ' at line ' + e.getLineNumber());
            return new List<StockInwardResult>();
        }
    }

    // 🔹 Defer updates to prevent recursive Flow execution
    @future
    private static void updateBatchLots(List<Id> batchLotIds, String serializedResults) {
        system.debug('entered future');
        try {
            // Deserialize the results
            Map<Id, StockInwardResult> batchLotResults = (Map<Id, StockInwardResult>) JSON.deserialize(serializedResults, Map<Id, StockInwardResult>.class);

            // Fetch ERP7__Batch__c records using the passed batchLotIds
            List<ERP7__Batch__c> batchLots = [
                SELECT Id, ERP7__Cost_Price__c, ERP7__Received_site__c, ERP7__Inward_Quantity__c
                FROM ERP7__Batch__c
                WHERE Id IN :batchLotIds
            ];

            // Update the batch lots based on the results
            for (ERP7__Batch__c batchLot : batchLots) {
                StockInwardResult result = batchLotResults.get(batchLot.Id); // Corresponding result for this batch lot

                if (result != null) {
                    // Apply the formula: Cost_Price = Total_Cost * Inward_Quantity
                    if (batchLot.ERP7__Inward_Quantity__c != null) {
                        batchLot.ERP7__Cost_Price__c = result.totalCost * batchLot.ERP7__Inward_Quantity__c;
                    }
                    batchLot.ERP7__Received_site__c = String.join(new Set<String>(result.inwardSites), ', ').trim().left(254);
                    system.debug('result cost price---  ' + batchLot.ERP7__Cost_Price__c);
                    system.debug('result inward quantity---  ' + batchLot.ERP7__Received_site__c);
                }

            }

            // Perform the update
            if (!batchLots.isEmpty()) {
                update batchLots;
            }
            

        } catch (Exception e) {
            System.debug('Future Method Exception: ' + e.getMessage());
        }
    }
}
*/