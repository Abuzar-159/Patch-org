public With Sharing class InventoryManagementReport {

  @AuraEnabled(cacheable=true)
  public static List<Map<String, Object>> getBOMByVersion(Id productId, Id routingId) {
      List<Map<String, Object>> resultList = new List<Map<String, Object>>();
      Id routingVersionId;

      // Fetch Routing and check for BOM Version ID
      ERP7__Routing__c routingRecord = fetchRoutingRecord(routingId);
      routingVersionId = routingRecord.ERP7__BOM_Version__c;

      if (routingVersionId == null) {
          throw new AuraHandledException('Routing Version not found for the given routing.');
      }

      // Fetch BOM records
      List<ERP7__BOM__c> bomList = fetchBOMRecords(productId, routingVersionId);
      if (bomList.isEmpty()) {
          throw new AuraHandledException('No BOM records found for the given product and version.');
      }

      // Collect component product IDs for inventory lookup
      Set<Id> componentProductIds = new Set<Id>();
      for (ERP7__BOM__c bom : bomList) {
          componentProductIds.add(bom.ERP7__BOM_Component__c);
      }

      // Get inventory details for all components
      Map<Id, Map<String, Object>> inventoryDetailsMap = getInventoryDetailsMap(componentProductIds);

      // Combine BOM records with inventory details
      for (ERP7__BOM__c bom : bomList) {
          Map<String, Object> resultMap = new Map<String, Object>();
          resultMap.put('BOMId', bom.Id);
          resultMap.put('BOMName', bom.Name);
          resultMap.put('BOMComponentName', bom.ERP7__BOM_Component__r.Name);
          resultMap.put('Quantity', bom.ERP7__Quantity__c);
          resultMap.put('Version', routingRecord.ERP7__BOM_Version__c);

          // Get inventory details
          Map<String, Object> inventoryDetails = inventoryDetailsMap.get(bom.ERP7__BOM_Component__c);
          if (inventoryDetails != null) {
              resultMap.putAll(inventoryDetails);
          }

          resultList.add(resultMap);
      }

      return resultList;
  }

  // Helper method to fetch Routing Record
  private static ERP7__Routing__c fetchRoutingRecord(Id routingId) {
      try {
          return [SELECT Id, Name, ERP7__BOM_Version__c FROM ERP7__Routing__c WHERE Id = :routingId LIMIT 1];
      } catch (QueryException e) {
          throw new AuraHandledException('Routing not found or invalid ID: ' + e.getMessage());
      } catch (Exception e) {
          throw new AuraHandledException('Unexpected error: ' + e.getMessage());
      }
  }

  // Helper method to fetch BOM Records
  private static List<ERP7__BOM__c> fetchBOMRecords(Id productId, Id routingVersionId) {
      return [
          SELECT Id, Name, ERP7__BOM_Component__r.Id, ERP7__BOM_Component__r.Name, ERP7__Quantity__c
          FROM ERP7__BOM__c
          WHERE ERP7__BOM_Product__c = :productId AND ERP7__BOM_Version__c = :routingVersionId
      ];
  }

  // Helper method to get Inventory Details Map
  private static Map<Id, Map<String, Object>> getInventoryDetailsMap(Set<Id> componentProductIds) {
      Map<Id, Map<String, Object>> inventoryDetailsMap = new Map<Id, Map<String, Object>>();
      for (Id componentProductId : componentProductIds) {
          List<Map<String, Object>> inventoryDetails = getInventoryDetails2(componentProductId);
          if (!inventoryDetails.isEmpty()) {
              inventoryDetailsMap.put(componentProductId, inventoryDetails[0]);
          } else {
              inventoryDetailsMap.put(componentProductId, initializeDefaultInventory());
          }
      }
      return inventoryDetailsMap;
  }

  // Helper method to initialize default inventory values
  private static Map<String, Object> initializeDefaultInventory() {
      return new Map<String, Object>{
          'OnHand' => 0,
          'ReservedSO' => 0,
          'AwaitingQty' => 0,
          'IssuedWIP' => 0,
          'DemandSales' => 0,
          'DemandMO' => 0,
          'OrderedQty' => 0
      };
  }



  @AuraEnabled(cacheable=true)
  public static List<Map<String, Object>> getInventoryDetails2(Id productId) {
      List<Map<String, Object>> resultList = new List<Map<String, Object>>();

      // Fetch Product details
      Product2 prod = [SELECT Id, ProductCode
                       FROM Product2
                       WHERE Id = :productId
                       AND IsActive = true
                       LIMIT 1];

      if (prod == null) {
          System.debug('No product found for the provided ID: ' + productId);
          return resultList; // Return empty if no product found
      }

      Map<String, Object> resultMap = new Map<String, Object>();
      resultMap.put('ProductCode', prod.ProductCode);

      // Aggregate inventory stock data
      AggregateResult inventoryResult = [SELECT
                                              SUM(ERP7__Number_of_Item_In_Stock__c) totalStock,
                                              SUM(ERP7__Stock_Reserved_for_SO__c) reservedSO,
                                              SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) awaitingStock
                                          FROM ERP7__Inventory_Stock__c
                                          WHERE ERP7__Active__c = true
                                          AND ERP7__Product__c = :productId
                                          GROUP BY ERP7__Product__c];

      resultMap.put('OnHand', inventoryResult == null ? 0 : (Decimal)inventoryResult.get('totalStock'));
      resultMap.put('ReservedSO', inventoryResult == null ? 0 : (Decimal)inventoryResult.get('reservedSO'));
      resultMap.put('AwaitingQty', inventoryResult == null ? 0 : (Decimal)inventoryResult.get('awaitingStock'));

      // Get other aggregated results
      resultMap.put('IssuedWIP', getManufacturingOrderQuantity(productId));
      resultMap.put('DemandSales', getSalesOrderDemand(productId));
      resultMap.put('DemandMO', getMoDemand(productId));
      // resultMap.put('OrderedQty', getOrderedQuantity(productId));

      // Add the result map to the list
      resultList.add(resultMap);
      return resultList;
  }

  // Helper method to get Manufacturing Order Quantity
  private static Decimal getManufacturingOrderQuantity(Id productId) {
      List<AggregateResult> results = [SELECT
                                           SUM(ERP7__Remaining_Quantity__c) totalQuantity
                                       FROM ERP7__Manufacturing_Order__c
                                       WHERE ERP7__Product__c = :productId
                                       AND ERP7__Remaining_Quantity__c > 0
                                       AND (ERP7__Status__c != 'Complete' AND ERP7__Status__c != 'Cancelled')
                                       GROUP BY ERP7__Product__c];
      return results.isEmpty() ? 0 : (Decimal)results[0].get('totalQuantity');
  }

  // Helper method to get Sales Order Demand
  private static Decimal getSalesOrderDemand(Id productId) {
      List<AggregateResult> results = [SELECT
                                           SUM(ERP7__Required_Stock__c) totalQuantity
                                       FROM OrderItem
                                       WHERE Product2Id = :productId
                                       AND ERP7__Required_Stock__c > 0
                                       AND Order.ERP7__Is_Closed__c = false
                                       GROUP BY Product2Id];
      return results.isEmpty() ? 0 : (Decimal)results[0].get('totalQuantity');
  }

  // Helper method to get Demand (MO)
  private static Decimal getMoDemand(Id productId) {
      List<AggregateResult> results = [SELECT
                                           SUM(ERP7__Remaining_Quantity_to_Allocate__c) totalQuantity
                                       FROM ERP7__MRP__c
                                       WHERE ERP7__MRP_Product__c = :productId
                                       AND ERP7__Remaining_Quantity_to_Allocate__c > 0
                                       AND ERP7__Status__c = 'Requested'
                                       GROUP BY ERP7__MRP_Product__c];
      return results.isEmpty() ? 0 : (Decimal)results[0].get('totalQuantity');
  }

  // Helper method to get Ordered Quantity
  // private static Decimal getOrderedQuantity(Id productId) {
  //     List<AggregateResult> results = [SELECT
  //                                      SUM(ERP7__Ordered_Quantity__c) totalOrderedQty
  //                                  FROM OrderItem
  //                                  WHERE Product2Id = :productId
  //                                  AND Order.ERP7__Is_Closed__c = false
  //                                  GROUP BY Product2Id];
  //     return results.isEmpty() ? 0 : (Decimal)results[0].get('totalOrderedQty');
  // }



    @AuraEnabled
    public static ERP7__Reordering_Rule__c createReorder(string routingDetails){
        if(routingDetails != null && routingDetails != ''){
            ERP7__Reordering_Rule__c reorder = (ERP7__Reordering_Rule__c) JSON.deserialize(routingDetails,ERP7__Reordering_Rule__c.class);
            upsert reorder;
            if(reorder.Id != null) {
                reorder = [Select Id,ERP7__Active__c,Name,ERP7__Lead_Time__c,ERP7__MinimumOrderingQuantity__c,ERP7__Minimum_Quantity__c,ERP7__Maximum_Quantity__c,ERP7__Warning_Quantity__c,ERP7__Product__c,ERP7__Vendor_Account__c,ERP7__Vendor_Account__r.Id,ERP7__Vendor_Account__r.Name,ERP7__Routing__c,ERP7__Routing__r.Id,ERP7__Routing__r.Name from ERP7__Reordering_Rule__c where Id = :reorder.Id];
                return reorder;
            }
            else return null;
        }
        else return null;
    }
    @AuraEnabled
    public static List<ERP7__Reordering_Rule__c> getReorderingRules(string vendor,Decimal LeadTime,Decimal qty,String rotuing,string prodId){
        List<ERP7__Reordering_Rule__c> reorderList = new List<ERP7__Reordering_Rule__c>();
        string query = 'Select Id,Name,ERP7__Lead_Time__c,ERP7__MinimumOrderingQuantity__c,ERP7__Product__c,ERP7__Vendor_Account__c,ERP7__Vendor_Account__r.Id,ERP7__Vendor_Account__r.Name,ERP7__Routing__c,ERP7__Routing__r.Id,ERP7__Routing__r.Name from ERP7__Reordering_Rule__c ';
        query += ' Where ERP7__Product__c != null ';
        if(LeadTime != null && LeadTime > 0) query += ' AND ERP7__Lead_Time__c = :LeadTime ';
        if(qty != null && qty > 0) query += ' AND ERP7__MinimumOrderingQuantity__c = :qty ';
        if(prodId != null && prodId != '') query += ' AND ERP7__Product__c = :prodId ';
        if(vendor != null && vendor != '') query += ' AND ERP7__Vendor_Account__c = :vendor ';
        if(rotuing != null && rotuing != '') query += ' AND ERP7__Routing__c = :rotuing ';
        query += ' limit 10 ';
        system.debug('query : '+query);
        reorderList = database.query(query);
        if(reorderList.size() > 0) return reorderList;
        else return null;
    }


    @AuraEnabled
    public static mainTrackWrap getInvnetoryTrace(String productId,String Lotnumber, String SerialNumber,String searchval,String site,date fromselDate,date toSelDate){
        system.debug('getInvnetoryTrace called');
        mainTrackWrap mainWrap = new mainTrackWrap();
        try
        {
            List<trackWrap> trackwrp = new List<trackWrap>();
            string searchStr = '%'+searchval+'%';
            if(fromselDate == null){
                fromselDate = Date.newInstance(System.today().year(), 1, 1);
            }
            system.debug('fromselDate : '+fromselDate);
            datetime toSelectedDate = system.now();
            // Time currentTime = System.now().time();
            system.debug('toSelDate : '+toSelDate);
            if(toSelDate == null){
                toSelectedDate = Datetime.newInstance(System.now().date(),System.now().time());
            }else {  toSelectedDate = Datetime.newInstance(toSelDate,System.now().time());
                  }
            system.debug('toSelectedDate : '+toSelectedDate);
            String sortOrder = '';
            if(productId != null && productId != ''){
                List<Product2> productlst = [Select Id,Name,ERP7__Lot_Tracked__c,ERP7__Serialise__c from Product2 where Id =:productId limit 1];
                if(productlst.size() > 0) mainWrap.prod = productlst[0];

                String query =  'SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock,   SUM(ERP7__Reserved_Manufactured_Qty__c) reservedMO,     SUM(ERP7__Stock_Reserved_for_SO__c) reservedSO,  SUM(ERP7__No_of_Items_Reserved__c) totalReserved,  SUM(ERP7__Number_of_Items_In_Quality_Check__c) qcStock, SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) awaitingStock,    SUM(ERP7__IC_transfer_Stocks__c) ictransfer   FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true AND ERP7__Product__c = :productId ';
                if(site != null && site != ''){
                    query += ' AND ERP7__Warehouse__c = :site ';
                }

                query += ' GROUP BY ERP7__Product__c';
                List<AggregateResult> inventoryResult1 =  database.query(query);
                system.debug('inventoryResult1.size() : '+inventoryResult1.size());
                if (inventoryResult1.size() > 0) {
                    AggregateResult aggregateResult = inventoryResult1[0];
                    system.debug('aggregateResult : '+aggregateResult);
                    mainWrap.currentStock = (Decimal)aggregateResult.get('totalStock');
                }

                query = 'SELECT ' +
                    'ERP7__Product__c, ERP7__Status__c, ' +
                    'SUM(ERP7__Quantity__c) totalQuantity,SUM(ERP7__Purchase_Items_from_vendor__c) purchasedItems ' +
                    'FROM ERP7__Stock_Inward_Line_Item__c ' +
                    'WHERE ERP7__Active__c = true ' +
                    'AND ERP7__Product__c = :productId';
                system.debug('query : '+query);
                if (fromselDate != null) {
                    query += ' AND CreatedDate >= :fromselDate ';
                }
                if (toSelDate != null) {   query += ' AND CreatedDate <= :toSelectedDate ';
                                       }
                if(site != null && site != ''){
                    query += ' AND ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c = :site ';
                }
                if(Lotnumber != null && Lotnumber != ''){
                    query += ' AND ERP7__Material_Batch_Lot__c = :Lotnumber ';
                }
                if(SerialNumber != null && SerialNumber != ''){   query += ' AND ERP7__Serial__c = :SerialNumber ';
                                                              }
                query += '  GROUP BY ERP7__Product__c,ERP7__Status__c';
                system.debug('query 1  : '+query);
                List<AggregateResult> inventoryResult = Database.query(query);

                for (AggregateResult result : inventoryResult) {
                    Id prodId = (Id) result.get('ERP7__Product__c');
                    String status = (String) result.get('ERP7__Status__c');
                    if(prodId == productId){
                        decimal purchasedItems = (Decimal)result.get('purchasedItems');
                        if(status == 'In Stock' || status == '')   {
                            mainWrap.onHand += (Decimal)result.get('totalQuantity');
                            if(purchasedItems > 0) mainWrap.purchasedItems = (Decimal)result.get('purchasedItems');
                        }
                        //mainWrap.reservedMO =(Decimal)result.get('reservedMO');
                        //mainWrap.reservedSO =(Decimal)result.get('reservedSO');
                        else if(status == 'Quality Check(QA)' || status == 'QC hold') mainWrap.QC +=(Decimal)result.get('totalQuantity');
                        else if (status == 'Awaiting Stock')   mainWrap.orderedQty =(Decimal)result.get('totalQuantity');
                        //  mainWrap.soldStocks = (Decimal)result.get('soldItems');
                        // mainWrap.purchasedItems = (Decimal)result.get('purchasedItems');

                        // mainWrap.icTransfer =(Decimal)result.get('ictransfer');
                    }
                }
                query = ' SELECT ERP7__Product__c, ERP7__Status__c, SUM(ERP7__Quantity__c) totalQuantity,SUM(ERP7__SO_Qty__c) SOreserved,SUM(ERP7__Manufactured_Qty__c) MOreserved, SUM(ERP7__IC_Transfer_Qty__c) ICtransfer FROM ERP7__Stock_Outward_Line_Item__c    WHERE ERP7__Product__c != NULL    AND ERP7__Product__c = :productId AND ERP7__Quantity__c > 0 ';
                if (fromselDate != null) {
                    query += ' AND CreatedDate >= :fromselDate ';
                }
                if (toSelDate != null) {    query += ' AND CreatedDate <= :toSelDate ';
                                       }
                if(site != null && site != ''){
                    query += ' AND ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :site ';
                }
                if(Lotnumber != null && Lotnumber != ''){
                    query += ' AND ERP7__Material_Batch_Lot__c = :Lotnumber ';
                }
                if(SerialNumber != null && SerialNumber != ''){   query += ' AND ERP7__Serial__c = :SerialNumber ';
                                                              }
                query += '  GROUP BY ERP7__Product__c,ERP7__Status__c';
                inventoryResult = Database.query(query);

                for (AggregateResult result : inventoryResult) {
                    Id prodId = (Id)result.get('ERP7__Product__c');
                    if(prodId == productId){
                        String status = (String)result.get('ERP7__Status__c');
                        Decimal totalQuantity = (Decimal)result.get('totalQuantity');
                        Decimal ICtransfer = (Decimal)result.get('ICtransfer');
                        Decimal SOreserved = (Decimal)result.get('SOreserved');
                        Decimal MOreserved = (Decimal)result.get('MOreserved');
                        if (status == 'Reserved') {
                            if(SOreserved > 0) mainWrap.reservedSO += SOreserved;
                            if(MOreserved > 0) mainWrap.reservedMO +=  MOreserved;
                        }
                        else if (status == 'Committed') {  mainWrap.soldStocks += totalQuantity;
                                                         //if(ICtransfer > 0) mainWrap.icTransfer = ICtransfer;
                                                        }
                    }
                }
            }
            String query = 'Select Id,Name,CreatedDate,ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__r.Name,ERP7__Cart_Putaway_Item__r.ERP7__Cart_Item__r.ERP7__Cart__r.Name,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Name,ERP7__Stock_Take_Line_Item__r.Name,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.Name,ERP7__Status__c,ERP7__Stock_Take_Line_Item__c,ERP7__Transfer_Order__c,ERP7__Transfer_Order__r.Name,ERP7__Transfer_Order__r.ERP7__To_Distribution_Channel__c,ERP7__Transfer_Order__r.ERP7__To_Distribution_Channel__r.Name,ERP7__Cart_Picked_Item__c,ERP7__RMA__c,ERP7__RMA__r.Name,ERP7__Location__c,ERP7__Location__r.Name,ERP7__Cart_Putaway_Item__c,ERP7__Cart_Putaway_Item__r.Name,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.Name from ERP7__Stock_Inward_Line_Item__c where ERP7__Product__c != null and ERP7__Quantity__c > 0 ';
            if(productId != null && productId != ''){
                query += ' AND ERP7__Product__c = :productId ';
            }
            if(searchval != null && searchval != ''){     query += ' AND (ERP7__Product__r.Name = :searchStr or  ERP7__Product__r.ProductCode = :searchStr) ';
                                                    }
            if(Lotnumber != null && Lotnumber != ''){
                query += ' AND ERP7__Material_Batch_Lot__c =:Lotnumber ';
            }
            if(SerialNumber != null && SerialNumber != ''){   query += ' AND ERP7__Serial__c =:SerialNumber ';
                                                          }
            if(site != null && site != ''){
                query += ' AND ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c = :site ';
            }
            if (fromselDate != null) {
                query += ' AND CreatedDate >= :fromselDate ';
            }
            if (toSelDate != null) {     query += ' AND CreatedDate <= :toSelectedDate ';
                                   }
            query += 'Order by CreatedDate LIMIT 10000';
            system.debug('query : '+query);
            List<ERP7__Stock_Inward_Line_Item__c> inwardItems = database.query(query);
            for(ERP7__Stock_Inward_Line_Item__c inward : inwardItems){
                trackWrap track = new trackWrap();
                if(inward.ERP7__Purchase_Orders__c != null || inward.ERP7__Manufacturing_Order__c != null){
                    track.dispositionDate = Date.valueOf(inward.CreatedDate);
                    if (inward.ERP7__Status__c != null) {
                        if (inward.ERP7__Purchase_Orders__c != null) {
                            track.disposition = inward.ERP7__Status__c + ' Inventory. Received from: ' + inward.ERP7__Purchase_Orders__r.Name;
                        } else if (inward.ERP7__Manufacturing_Order__c != null) {
                            track.disposition = inward.ERP7__Status__c + ' in Production. Through : ' + inward.ERP7__Manufacturing_Order__r.Name;
                        }
                    } else {
                        if (inward.ERP7__Purchase_Orders__c != null) {    track.disposition = 'Inventory from: ' + inward.ERP7__Purchase_Orders__r.Name;
                                                                     } else if (inward.ERP7__Manufacturing_Order__c != null) { track.disposition = 'In Production: ' + inward.ERP7__Manufacturing_Order__r.Name;
                                                                                                                             }
                    }
                    track.partNumber = inward.ERP7__Product__r.Name;
                    track.LotOrSerialNumber = (inward.ERP7__Material_Batch_Lot__c != null && inward.ERP7__Serial__c != null) ? (inward.ERP7__Material_Batch_Lot__r.Name +'-'+inward.ERP7__Serial__r.Name) : (inward.ERP7__Material_Batch_Lot__c != null ? inward.ERP7__Material_Batch_Lot__r.Name : (inward.ERP7__Serial__c != null ? inward.ERP7__Serial__r.Name : ''));
                        track.Qty = inward.ERP7__Quantity__c;
                    track.itemId = inward.Id;
                    track.location = (inward.ERP7__Location__c != null) ? inward.ERP7__Location__r.Name : inward.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__r.Name;
                    trackwrp.add(track);
                }
                else if(inward.ERP7__Stock_Take_Line_Item__c != null){
                    track.dispositionDate = Date.valueOf(inward.CreatedDate);
                    track.disposition = 'Adjusted Inventory ';
                    track.partNumber = inward.ERP7__Product__r.Name;
                    track.LotOrSerialNumber = (inward.ERP7__Material_Batch_Lot__c != null && inward.ERP7__Serial__c != null) ? (inward.ERP7__Material_Batch_Lot__r.Name +'-'+inward.ERP7__Serial__r.Name) : (inward.ERP7__Material_Batch_Lot__c != null ? inward.ERP7__Material_Batch_Lot__r.Name : (inward.ERP7__Serial__c != null ? inward.ERP7__Serial__r.Name : ''));
                        track.Qty = inward.ERP7__Quantity__c;
                    track.itemId = inward.Id;
                    track.location = (inward.ERP7__Location__c != null) ? inward.ERP7__Location__r.Name : inward.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__r.Name;
                    trackwrp.add(track);
                }
                else if(inward.ERP7__Cart_Putaway_Item__c != null){
                    track.dispositionDate = Date.valueOf(inward.CreatedDate);     track.disposition = 'Transfered from : '+inward.ERP7__Cart_Putaway_Item__r.ERP7__Cart_Item__r.ERP7__Cart__r.Name;     track.partNumber = inward.ERP7__Product__r.Name;    track.LotOrSerialNumber = (inward.ERP7__Material_Batch_Lot__c != null && inward.ERP7__Serial__c != null) ? (inward.ERP7__Material_Batch_Lot__r.Name +'-'+inward.ERP7__Serial__r.Name) : (inward.ERP7__Material_Batch_Lot__c != null ? inward.ERP7__Material_Batch_Lot__r.Name : (inward.ERP7__Serial__c != null ? inward.ERP7__Serial__r.Name : ''));     track.Qty = inward.ERP7__Quantity__c;  track.location = (inward.ERP7__Location__c != null) ? inward.ERP7__Location__r.Name : inward.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__r.Name;      track.itemId = inward.Id; trackwrp.add(track);
                }
                else if(inward.ERP7__Transfer_Order__c != null){
                    track.dispositionDate = Date.valueOf(inward.CreatedDate);     track.disposition = 'Transfered using : '+inward.ERP7__Transfer_Order__r.Name;     track.partNumber = inward.ERP7__Product__r.Name;    track.LotOrSerialNumber = (inward.ERP7__Material_Batch_Lot__c != null && inward.ERP7__Serial__c != null) ? (inward.ERP7__Material_Batch_Lot__r.Name +'-'+inward.ERP7__Serial__r.Name) : (inward.ERP7__Material_Batch_Lot__c != null ? inward.ERP7__Material_Batch_Lot__r.Name : (inward.ERP7__Serial__c != null ? inward.ERP7__Serial__r.Name : ''));       track.Qty = inward.ERP7__Quantity__c;     track.location = (inward.ERP7__Location__c != null) ? inward.ERP7__Location__r.Name : inward.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__r.Name;       track.itemId = inward.Id;     trackwrp.add(track);
                }
                else if(inward.ERP7__RMA__c != null){
                    track.dispositionDate = Date.valueOf(inward.CreatedDate);     track.disposition = 'Returned from RMA : '+inward.ERP7__RMA__r.Name;     track.partNumber = inward.ERP7__Product__r.Name;      track.LotOrSerialNumber = (inward.ERP7__Material_Batch_Lot__c != null && inward.ERP7__Serial__c != null) ? (inward.ERP7__Material_Batch_Lot__r.Name +'-'+inward.ERP7__Serial__r.Name) : (inward.ERP7__Material_Batch_Lot__c != null ? inward.ERP7__Material_Batch_Lot__r.Name : (inward.ERP7__Serial__c != null ? inward.ERP7__Serial__r.Name : ''));        track.Qty = inward.ERP7__Quantity__c;     track.location = (inward.ERP7__Location__c != null) ? inward.ERP7__Location__r.Name : inward.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__r.Name;      track.itemId = inward.Id;     trackwrp.add(track);
                }
                else{
                    track.dispositionDate = Date.valueOf(inward.CreatedDate);
                    track.disposition = 'Added Stock with Status : '+inward.ERP7__Status__c;
                    track.partNumber = inward.ERP7__Product__r.Name;
                    track.LotOrSerialNumber = (inward.ERP7__Material_Batch_Lot__c != null && inward.ERP7__Serial__c != null) ? (inward.ERP7__Material_Batch_Lot__r.Name +'-'+inward.ERP7__Serial__r.Name) : (inward.ERP7__Material_Batch_Lot__c != null ? inward.ERP7__Material_Batch_Lot__r.Name : (inward.ERP7__Serial__c != null ? inward.ERP7__Serial__r.Name : ''));
                        track.Qty = inward.ERP7__Quantity__c;
                    track.itemId = inward.Id;
                    track.location = (inward.ERP7__Location__c != null) ? inward.ERP7__Location__r.Name : inward.ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__r.Name;
                    trackwrp.add(track);
                }
            }
            system.debug('trackwrp : '+trackwrp.size());
            query = 'Select Id,Name,ERP7__Cart__c,ERP7__Cart__r.Name,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Name,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__c,ERP7__Material_Batch_Lot__r.Name,ERP7__Product__c,ERP7__Product__r.Name,CreatedDate,ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__r.Name,ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c,ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Quantity__c,ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.Name,ERP7__Status__c,ERP7__Stock_Take_Line_Item__c,ERP7__Transfer_Order__c,ERP7__Transfer_Order__r.Name,ERP7__Transfer_Order__r.ERP7__Distribution_Channel__c,ERP7__Transfer_Order__r.ERP7__Distribution_Channel__r.Name,ERP7__Cart_Picked_Item__c,ERP7__Return_Merchandise_Authorisation__c,ERP7__Return_Merchandise_Authorisation__r.Name from ERP7__Stock_Outward_Line_Item__c where ERP7__Product__c != null ';
            if(productId != null && productId != ''){
                query += ' AND ERP7__Product__c = :productId ';
            }
            if(searchval != null && searchval != ''){
                query += ' AND (ERP7__Product__r.Name = :searchStr or  ERP7__Product__r.ProductCode = :searchStr) ';
            }
            if(Lotnumber != null && Lotnumber != ''){
                query += ' AND ERP7__Material_Batch_Lot__c =:Lotnumber ';
            }
            if(SerialNumber != null && SerialNumber != ''){
                query += ' AND ERP7__Serial__c =:SerialNumber ';
            }
            if(site != null && site != ''){
                query += ' AND ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :site ';
            }
            if (fromselDate != null) {
                query += ' AND CreatedDate >= :fromselDate ';
            }
            if (toSelDate != null) {
                query += ' AND CreatedDate <= :toSelDate ';
            }
            query += 'Order by CreatedDate LIMIT 10000';
            List<ERP7__Stock_Outward_Line_Item__c> outwardItems = database.query(query);
            for(ERP7__Stock_Outward_Line_Item__c soutward : outwardItems){
                trackWrap track = new trackWrap();
                if(soutward.ERP7__Order__c != null){
                    track.dispositionDate = Date.valueOf(soutward.CreatedDate);
                    track.disposition = 'Stock  '+soutward.ERP7__Status__c+' for Order : '+soutward.ERP7__Order__r.Name;
                    track.partNumber = soutward.ERP7__Product__r.Name;
                    track.LotOrSerialNumber = (soutward.ERP7__Material_Batch_Lot__c != null && soutward.ERP7__Serial__c != null) ? (soutward.ERP7__Material_Batch_Lot__r.Name +'-'+soutward.ERP7__Serial__r.Name) : (soutward.ERP7__Material_Batch_Lot__c != null ? soutward.ERP7__Material_Batch_Lot__r.Name : (soutward.ERP7__Serial__c != null ? soutward.ERP7__Serial__r.Name : ''));
                        track.Qty = soutward.ERP7__Quantity__c;
                    track.itemId = soutward.Id;
                    track.location = (soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c != null) ? soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name : soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__r.Name;
                    trackwrp.add(track);
                }
                else if(soutward.ERP7__Manufacturing_Order__c != null){
                    track.dispositionDate = Date.valueOf(soutward.CreatedDate);              track.disposition = 'Stock  '+soutward.ERP7__Status__c+' for Order : '+soutward.ERP7__Manufacturing_Order__r.Name;         track.partNumber = soutward.ERP7__Product__r.Name;        track.LotOrSerialNumber = (soutward.ERP7__Material_Batch_Lot__c != null && soutward.ERP7__Serial__c != null) ? (soutward.ERP7__Material_Batch_Lot__r.Name +'-'+soutward.ERP7__Serial__r.Name) : (soutward.ERP7__Material_Batch_Lot__c != null ? soutward.ERP7__Material_Batch_Lot__r.Name : (soutward.ERP7__Serial__c != null ? soutward.ERP7__Serial__r.Name : ''));       track.Qty = soutward.ERP7__Quantity__c;       track.itemId = soutward.Id;    track.location = (soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c != null) ? soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name : soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__r.Name;   trackwrp.add(track);
                }
                else if(soutward.ERP7__Stock_Take_Line_Item__c != null){
                    track.dispositionDate = Date.valueOf(soutward.CreatedDate);
                    track.disposition = 'Adjusted Qty '+soutward.ERP7__Status__c;
                    track.partNumber = soutward.ERP7__Product__r.Name;
                    track.LotOrSerialNumber = (soutward.ERP7__Material_Batch_Lot__c != null && soutward.ERP7__Serial__c != null) ? (soutward.ERP7__Material_Batch_Lot__r.Name +'-'+soutward.ERP7__Serial__r.Name) : (soutward.ERP7__Material_Batch_Lot__c != null ? soutward.ERP7__Material_Batch_Lot__r.Name : (soutward.ERP7__Serial__c != null ? soutward.ERP7__Serial__r.Name : ''));
                        track.Qty = soutward.ERP7__Quantity__c;
                    track.itemId = soutward.Id;
                    track.location = (soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c != null) ? soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name : soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__r.Name;
                    trackwrp.add(track);
                }
                else if(soutward.ERP7__Cart_Picked_Item__c != null){
                    track.dispositionDate = Date.valueOf(soutward.CreatedDate);   track.disposition = 'Picked Qty for IC transfer from '+soutward.ERP7__Cart__r.Name;    track.partNumber = soutward.ERP7__Product__r.Name;                    track.LotOrSerialNumber = (soutward.ERP7__Material_Batch_Lot__c != null && soutward.ERP7__Serial__c != null) ? (soutward.ERP7__Material_Batch_Lot__r.Name +'-'+soutward.ERP7__Serial__r.Name) : (soutward.ERP7__Material_Batch_Lot__c != null ? soutward.ERP7__Material_Batch_Lot__r.Name : (soutward.ERP7__Serial__c != null ? soutward.ERP7__Serial__r.Name : ''));        track.Qty = soutward.ERP7__Quantity__c;     track.itemId = soutward.Id;     track.location = (soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c != null) ? soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name : soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__r.Name;     trackwrp.add(track);
                }
                else if(soutward.ERP7__Transfer_Order__c != null){
                    track.dispositionDate = Date.valueOf(soutward.CreatedDate);   track.disposition = 'Transferred through '+soutward.ERP7__Transfer_Order__r.Name+' from '+soutward.ERP7__Transfer_Order__r.ERP7__Distribution_Channel__r.Name;       track.partNumber = soutward.ERP7__Product__r.Name;    track.LotOrSerialNumber = (soutward.ERP7__Material_Batch_Lot__c != null && soutward.ERP7__Serial__c != null) ? (soutward.ERP7__Material_Batch_Lot__r.Name +'-'+soutward.ERP7__Serial__r.Name) : (soutward.ERP7__Material_Batch_Lot__c != null ? soutward.ERP7__Material_Batch_Lot__r.Name : (soutward.ERP7__Serial__c != null ? soutward.ERP7__Serial__r.Name : ''));        track.Qty = soutward.ERP7__Quantity__c;        track.itemId = soutward.Id;      track.location = (soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c != null) ? soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name : soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__r.Name;    trackwrp.add(track);
                }
                else if(soutward.ERP7__Return_Merchandise_Authorisation__c != null){
                    track.dispositionDate = Date.valueOf(soutward.CreatedDate);     track.disposition = 'Stock for '+soutward.ERP7__Return_Merchandise_Authorisation__r.Name+' '+soutward.ERP7__Status__c;     track.partNumber = soutward.ERP7__Product__r.Name;    track.LotOrSerialNumber = (soutward.ERP7__Material_Batch_Lot__c != null && soutward.ERP7__Serial__c != null) ? (soutward.ERP7__Material_Batch_Lot__r.Name +'-'+soutward.ERP7__Serial__r.Name) : (soutward.ERP7__Material_Batch_Lot__c != null ? soutward.ERP7__Material_Batch_Lot__r.Name : (soutward.ERP7__Serial__c != null ? soutward.ERP7__Serial__r.Name : ''));        track.Qty = soutward.ERP7__Quantity__c;    track.itemId = soutward.Id;    track.location = (soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c != null) ? soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name : soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__r.Name;  trackwrp.add(track);
                }
                else if(soutward.ERP7__Purchase_Orders__c != null){
                    track.dispositionDate = Date.valueOf(soutward.CreatedDate);
                    track.disposition = 'Returned Stock for '+soutward.ERP7__Purchase_Orders__r.Name+' '+soutward.ERP7__Status__c;
                    track.partNumber = soutward.ERP7__Product__r.Name;    track.LotOrSerialNumber = (soutward.ERP7__Material_Batch_Lot__c != null && soutward.ERP7__Serial__c != null) ? (soutward.ERP7__Material_Batch_Lot__r.Name +'-'+soutward.ERP7__Serial__r.Name) : (soutward.ERP7__Material_Batch_Lot__c != null ? soutward.ERP7__Material_Batch_Lot__r.Name : (soutward.ERP7__Serial__c != null ? soutward.ERP7__Serial__r.Name : ''));       track.Qty = soutward.ERP7__Quantity__c;    track.itemId = soutward.Id;   track.location = (soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__c != null) ? soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Location__r.Name : soutward.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__r.Name;    trackwrp.add(track);
                }
            }
            system.debug('trackwrp : '+trackwrp.size());
            mainWrap.sortBy = (sortOrder == 'Descending') ? InventoryManagementReport.SORT_Order.Descending : InventoryManagementReport.SORT_Order.Ascending;
            trackwrp.sort();
            mainWrap.tracklst = trackwrp;
        }
        catch(exception e){
            mainWrap.errMsg = 'error : '+e.getMessage()+' line Number : '+e.getLineNumber();
            system.debug('error : '+e.getMessage()+' line Number : '+e.getLineNumber());
        }
        return mainWrap;
    }
    @AuraEnabled
    public static MainWrap getInventoryDetailsbyDate(string searchstr, string family,String subfamily,String selectedSite,Integer pageSize, Integer pageNumber, date fromDate,date toDate){
        MainWrap wrapnew = new MainWrap();
        system.debug('getInventoryDetails called  ');
        if(fromDate == null){
            fromDate = Date.newInstance(System.today().year(), 1, 1);
        }
        system.debug('fromDate : '+fromDate);
        if(toDate == null){
            toDate = system.today()+1;
        }
        else {
            toDate = toDate + 1;
        }
        system.debug('toDate : '+toDate);
        List<wrapper> wraplst = new List<wrapper>();
        string srch = '%' + searchstr + '%';
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        String baseQuery = 'SELECT COUNT() FROM Product2 WHERE (Name LIKE :srch OR ProductCode LIKE :srch) AND IsActive = true ';
        if (family != null && family != '' && family != '--None--') {
            baseQuery += ' AND Family = :family';
        }

        if (subfamily != null && subfamily != '' && subfamily != '--None--') {
            baseQuery += ' AND ERP7__Product_Service_Family__c = :subfamily';
        }
        system.debug('baseQuery : '+baseQuery);
        String customQuery = System.Label.CustomQueryforMRP;
        system.debug('customQuery : '+customQuery);
        if(customQuery != 'None'){
            baseQuery += customQuery;
        }
        system.debug('baseQuery af: '+baseQuery);
        Integer totalRecords = Database.countQuery(baseQuery);
        wrapnew.pageSize = pageSize;
        wrapnew.pageNumber = pageNumber;
        wrapnew.recordStart = offset + 1;
        wrapnew.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        wrapnew.totalRecords = totalRecords;
        String query = 'Select Id,Name, ProductCode, Family, ERP7__Product_Service_Family__c, ERP7__Issue_Purchase_Order__c ,ERP7__Issue_Manufacturing_Order__c from Product2 where IsActive = true';
        if(srch != null && srch != '') query += ' AND (Name Like : srch or ProductCode Like :srch) ';
        if(family != null && family != '' && family != '--None--') query += ' AND Family = :family';
        if(subfamily != null && subfamily != '' && subfamily != '--None--') query += ' AND ERP7__Product_Service_Family__c = :subfamily';
         if(customQuery != 'None'){
            query += customQuery;
        }
        query += ' Limit :pageSize ';
        if ((String.isBlank(family) || family == '--None--') && String.isBlank(searchstr) && (String.isBlank(subfamily) || subfamily == '--None--')) {
            query += ' OFFSET :offset';
        }
        List<Product2> ProdList = database.query(query);
        if(ProdList.size() > 0){
            set<Id> prodIds = new set<Id>();
            for(Product2 prod : ProdList){
                prodIds.add(prod.Id);
            }
            List<ERP7__Reordering_Rule__c> reorderingRules = [Select Id,Name,ERP7__Active__c,ERP7__Lead_Time__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Vendor_Account__c,ERP7__Vendor_Account__r.Name,ERP7__Routing__c,ERP7__Routing__r.Name,ERP7__Minimum_Quantity__c,ERP7__Maximum_Quantity__c,ERP7__MinimumOrderingQuantity__c from ERP7__Reordering_Rule__c where ERP7__Product__c IN: prodIds  ];
            Map<Id,List<ERP7__Reordering_Rule__c>> ProductReorderMap = new Map<Id,List<ERP7__Reordering_Rule__c>>();
            for(ERP7__Reordering_Rule__c rr : reorderingRules){
                if(ProductReorderMap.containsKey(rr.ERP7__Product__c)){
                    ProductReorderMap.get(rr.ERP7__Product__c).add(rr);
                }
                else{
                    ProductReorderMap.put(rr.ERP7__Product__c, new List<ERP7__Reordering_Rule__c>{rr});
                }
            }
            if(selectedSite == null || selectedSite == ''){
                List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                    where ERP7__Employee_User__c=:UserInfo.getUserId()];
                if(empList.size()>0 && empList != null){
                    wrapnew.ChannelId = empList[0].ERP7__Channel__c;
                    List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.ERP7__Address__c,ERP7__Active__c from ERP7__Distribution_Channel__c
                                                                  where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                    if(dcList.size()>0 && dcList != null) selectedSite = dcList[0].ERP7__Site__c;
                }
            }
            Map<Id, AggregateResult> inventoryResultMap = new Map<Id, AggregateResult>();

            Map<String, Decimal[]> productStatusQuantitiesMap = new Map<String, Decimal[]>();
             String queryinv =  'SELECT ERP7__Product__c, SUM(ERP7__Number_of_Item_In_Stock__c) totalStock,   SUM(ERP7__Reserved_Manufactured_Qty__c) reservedMO,     SUM(ERP7__Stock_Reserved_for_SO__c) reservedSO,  SUM(ERP7__No_of_Items_Reserved__c) totalReserved,  SUM(ERP7__Number_of_Items_In_Quality_Check__c) qcStock, SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) awaitingStock,    SUM(ERP7__IC_transfer_Stocks__c) ictransfer   FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true AND ERP7__Product__c IN:prodIds ';
                if(selectedSite != null && selectedSite != ''){
                    queryinv += ' AND ERP7__Warehouse__c = :selectedSite ';
                }

                queryinv += ' GROUP BY ERP7__Product__c';
                List<AggregateResult> inventoryResult1 =  database.query(queryinv);
                system.debug('inventoryResult1.size() : '+inventoryResult1.size());
            Map<Id,decimal> currentStockofProduct = new Map<Id,Decimal>();
                if (inventoryResult1.size() > 0) {
                    for(AggregateResult aggregateResult : inventoryResult1){
                        String productId = (String)aggregateResult.get('ERP7__Product__c');
                        Decimal totalQuantity = (Decimal)aggregateResult.get('totalStock');
                        if(currentStockofProduct.containskey(productId)) {
                            decimal val = currentStockofProduct.get(productId);
                            currentStockofProduct.put(productId,(val + totalQuantity));
                        }else  currentStockofProduct.put(productId,totalQuantity);
                    }

                }

            for (AggregateResult aggregateResult : [
                SELECT ERP7__Product__c, ERP7__Status__c, SUM(ERP7__Quantity__c) totalQuantity
                FROM ERP7__Stock_Inward_Line_Item__c
                WHERE ERP7__Product__c != NULL
                AND ERP7__Quantity__c > 0
                AND CreatedDate <= :toDate
                AND CreatedDate >= :fromDate
                AND ERP7__Active__c = true
                AND ERP7__Product__c IN:prodIds
                AND ERP7__Site_ProductService_InventoryStock__c != null
                AND ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c = :selectedSite
                GROUP BY ERP7__Product__c, ERP7__Status__c
            ]) {
                String productId = (String)aggregateResult.get('ERP7__Product__c');
                String status = (String)aggregateResult.get('ERP7__Status__c');
                Decimal totalQuantity = (Decimal)aggregateResult.get('totalQuantity');

                // Check if the product ID exists in the map
                if (!productStatusQuantitiesMap.containsKey(productId)) {
                    productStatusQuantitiesMap.put(productId, new Decimal[]{0, 0, 0,0,0,0,0});
                }

                // Update the quantities based on the status
                Decimal[] quantities = productStatusQuantitiesMap.get(productId);
                if (status == 'Awaiting Stock') {
                    quantities[0] += totalQuantity;
                } else if (status == 'In Stock' || status == '') {
                    quantities[1] += totalQuantity;
                }
                else if(status == 'Quality Check(QA)' || status == 'QC hold'){
                    quantities[2] += totalQuantity;
                }

                // Update the map with the updated quantities
                productStatusQuantitiesMap.put(productId, quantities);
            }
            for (AggregateResult aggregateResult : [
                SELECT ERP7__Product__c, ERP7__Status__c, SUM(ERP7__Quantity__c) totalQuantity,SUM(ERP7__SO_Qty__c) SOreserved,SUM(ERP7__Manufactured_Qty__c) MOreserved, SUM(ERP7__IC_Transfer_Qty__c) ICtransfer
                FROM ERP7__Stock_Outward_Line_Item__c
                WHERE ERP7__Product__c != NULL
                AND ERP7__Quantity__c > 0
                AND CreatedDate <= :toDate
                AND CreatedDate >= :fromDate
                AND ERP7__Active__c = true
                AND ERP7__Product__c IN:prodIds
                AND ERP7__Site_Product_Service_Inventory_Stock__c != null
                AND ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :selectedSite
                GROUP BY ERP7__Product__c, ERP7__Status__c
            ]) {
                String productId = (String)aggregateResult.get('ERP7__Product__c');
                String status = (String)aggregateResult.get('ERP7__Status__c');
                Decimal totalQuantity = (Decimal)aggregateResult.get('totalQuantity');
                Decimal ICtransfer = (Decimal)aggregateResult.get('ICtransfer');
                Decimal SOreserved = (Decimal)aggregateResult.get('SOreserved');   Decimal MOreserved = (Decimal)aggregateResult.get('MOreserved');
                // Check if the product ID exists in the map
                if (!productStatusQuantitiesMap.containsKey(productId)) {    productStatusQuantitiesMap.put(productId, new Decimal[]{0, 0, 0,0,0,0,0});
                                                                        }

                // Update the quantities based on the status
                Decimal[] quantities = productStatusQuantitiesMap.get(productId);
                if (status == 'Reserved') {
                    if(SOreserved > 0) quantities[3] += SOreserved;
                    if(MOreserved > 0) quantities[4] += MOreserved;

                } else if (status == 'Committed') {
                    if(ICtransfer > 0) quantities[5] += ICtransfer;
                    if(ICtransfer == 0 && totalQuantity > 0) quantities[6] +=totalQuantity;
                }

                // Update the map with the updated quantities
                productStatusQuantitiesMap.put(productId, quantities);
            }


            List<ERP7__Reordering_Rule__c> reorderLst = [Select Id,Name,ERP7__Product__c,ERP7__Lead_Time__c ,ERP7__Maximum_Quantity__c,ERP7__Minimum_Quantity__c from ERP7__Reordering_Rule__c where ERP7__Product__c IN : prodIds Order By createdDate];
            List<ERP7__Approved_Vendor__c> appVenlst = [Select Id,Name,ERP7__Cost_Card__c,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Lead_Time__c,ERP7__Product__c,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Status__c from ERP7__Approved_Vendor__c where ERP7__Product__c IN : prodIds and ERP7__Status__c = 'Approved' and ERP7__Vendor__c != null]; // and ERP7__Cost_Card__c != null removed on 24_07_24
            Map<Id,List<ERP7__Approved_Vendor__c>> ProdAppven = new Map<Id,List<ERP7__Approved_Vendor__c>>();
            Map<Id,ERP7__Reordering_Rule__c> ProdRule = new Map<Id,ERP7__Reordering_Rule__c>();
            for(ERP7__Reordering_Rule__c rr : reorderLst){
                if(rr.ERP7__Product__c != null) ProdRule.put(rr.ERP7__Product__c,rr);
            }
            for(ERP7__Approved_Vendor__c appVen : appVenlst){
                if(appVen.ERP7__Product__c != null){
                    if(ProdAppven.containsKey(appVen.ERP7__Product__c)) ProdAppven.get(appVen.ERP7__Product__c).add(appVen);
                    else ProdAppven.put(appVen.ERP7__Product__c,new List<ERP7__Approved_Vendor__c>{appVen});
                }
            }
            String returnrecordId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__PO__c','Standard_Purchase_Order');
            List<AggregateResult> prliAggregateResults = [SELECT ERP7__Product__c, COUNT_DISTINCT(ERP7__Purchase_Orders__c) purchaseOrderCount, SUM(ERP7__Remaining_Quantity__c) totalQuantity, COUNT(Id) recordCount FROM ERP7__Purchase_Line_Items__c WHERE  ERP7__Logistic_Quantity__c >= 0  AND ERP7__Quantity__c > 0 AND ERP7__Remaining_Quantity__c > 0 AND ERP7__Product__c != null   AND ERP7__Product__c IN :prodIds    AND ERP7__Purchase_Orders__c != null   AND ERP7__Purchase_Orders__r.RecordTypeId = :returnrecordId   AND ERP7__Purchase_Orders__r.ERP7__Distribution_Channel__r.ERP7__Site__c = :selectedSite AND CreatedDate <= :toDate
                                                          AND  (ERP7__Purchase_Orders__r.ERP7__Status__c != 'Cancelled' AND ERP7__Purchase_Orders__r.ERP7__Status__c != 'Closed') And ERP7__Purchase_Orders__r.ERP7__Is_Closed__c = false
                                                          AND CreatedDate >= :fromDate GROUP BY ERP7__Product__c];
            Map<Id,AggregateResult> prliProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : prliAggregateResults){
                Id productId = (Id)result.get('ERP7__Product__c');
                prliProds.put(productId, result);
            }
            List<AggregateResult> aggregateResultsMO = [Select ERP7__Product__c,COUNT (Id) mocount,SUM(ERP7__Remaining_Quantity__c) totalQuantity from ERP7__Manufacturing_Order__c where ERP7__Remaining_Quantity__c > 0 and ERP7__Product__c IN :prodIds and (ERP7__Status__c != 'Cancelled')  AND CreatedDate <= :toDate
                                                        AND CreatedDate >= :fromDate GROUP BY ERP7__Product__c];
            Map<Id,AggregateResult> MOProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : aggregateResultsMO){
                Id productId = (Id)result.get('ERP7__Product__c');
                MOProds.put(productId, result);
            }
            List<AggregateResult> demandSo = [Select Product2Id,SUM(ERP7__Required_Stock__c) totalQuantity, COUNT_DISTINCT (OrderId) orderCount from OrderItem where Product2Id != null AND Product2Id IN:prodIds AND ERP7__Logistic_Quantity__c >= 0 and ERP7__Required_Stock__c > 0 and Order.ERP7__Is_Closed__c = false
                                              AND  CreatedDate <= :toDate
                                              AND CreatedDate >= :fromDate GROUP BY Product2Id];
            Map<Id,AggregateResult> demandSoProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : demandSo){
                Id productId = (Id)result.get('Product2Id');
                demandSoProds.put(productId, result);
            }
            List< AggregateResult > MRPSDemand = [Select ERP7__MRP_Product__c,SUM(ERP7__Remaining_Quantity_to_Allocate__c) totalQuantity,COUNT_DISTINCT(ERP7__MO__c) mocount from ERP7__MRP__c where ERP7__MRP_Product__c IN :prodIds and ERP7__MRP_Product__c != null and ERP7__Remaining_Quantity_to_Allocate__c > 0 and ERP7__MO__c != null and ERP7__Status__c = :'Requested' and (ERP7__MO__r.ERP7__Status__c != 'Complete' and ERP7__MO__r.ERP7__Status__c != 'Cancelled')
                                                  and CreatedDate <= :toDate
                                                  AND CreatedDate >= :fromDate GROUP BY ERP7__MRP_Product__c];
            Map<Id,AggregateResult> MRPsDemandProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : MRPSDemand){
                Id productId = (Id)result.get('ERP7__MRP_Product__c');
                MRPsDemandProds.put(productId, result);
            }
            Integer index = 1;
            for(Product2 pro : ProdList){
                wrapper wrap = new wrapper();
                wrap.index = index;
                wrap.prod=pro;
                if(ProdAppven.containskey(pro.Id)) wrap.approvedVendors = ProdAppven.get(pro.Id);
                if(ProdRule.containskey(pro.Id)){
                    wrap.minQty = ProdRule.get(pro.Id).ERP7__Minimum_Quantity__c;
                    wrap.maxQty = ProdRule.get(pro.Id).ERP7__Maximum_Quantity__c;
                }
                if (productStatusQuantitiesMap.containsKey(pro.Id)) {
                    Decimal[] result = productStatusQuantitiesMap.get(pro.Id);
                      wrap.reservedMO =(Decimal)result[4];            wrap.reservedSO =(Decimal)result[3];      wrap.QC =(Decimal)result[2];     wrap.orderedQty =(Decimal)result[0];       wrap.icTransfer =(Decimal)result[5];
                }/*wrap.onHand =(Decimal)result[1];*/
                if(currentStockofProduct.containsKey(pro.Id)) wrap.onHand = currentStockofProduct.get(pro.Id);
                if(prliProds.containsKey(pro.Id)){
                    AggregateResult result = prliProds.get(pro.Id);
                    wrap.openPosCount =(Integer)result.get('purchaseOrderCount');    wrap.openPos =(Decimal)result.get('totalQuantity');
                }
                if(MOProds.containsKey(pro.Id)){
                    AggregateResult result = MOProds.get(pro.Id);
                    wrap.openMosCount =(Integer)result.get('mocount');
                    wrap.openMos =(Decimal)result.get('totalQuantity');
                }
                if(demandSoProds.containsKey(pro.Id)){
                    AggregateResult result = demandSoProds.get(pro.Id);
                    wrap.demandSalesCount =(Integer)result.get('orderCount');
                    wrap.demandSales =(Decimal)result.get('totalQuantity');
                }
                if(MRPsDemandProds.containsKey(pro.Id)){
                    AggregateResult result = MRPsDemandProds.get(pro.Id);
                    wrap.demandMOCount =(Integer)result.get('mocount');
                    wrap.demandMO =(Decimal)result.get('totalQuantity');
                }
                decimal demand = wrap.demandSales + wrap.demandMO;
                demand = demand - wrap.openPos - wrap.openMos;
                System.debug('demand : '+demand);
                if (wrap.minQty > 0 && wrap.onHand < wrap.minQty) {
                    wrap.suggestedQty = (wrap.minQty + demand) - wrap.onHand;
                }
                else if(wrap.maxQty > 0 && wrap.onHand > wrap.maxQty){    wrap.suggestedQty = 0;
                                                                     }
                else wrap.suggestedQty = (demand > wrap.onHand) ? (demand - wrap.onHand) : 0;
                system.debug('wrap.suggestedQty : '+wrap.suggestedQty);
                if(wrap.suggestedQty < 0) wrap.suggestedQty = 0;
                wrap.netQty = (wrap.onHand + wrap.reservedMO + wrap.reservedSO +  wrap.openPos + wrap.openMos + wrap.icTransfer) - (wrap.demandSales + wrap.demandMO);
                wrap.reorderlist = (ProductReorderMap.containsKey(pro.Id) ? ProductReorderMap.get(pro.Id) : new List<ERP7__Reordering_Rule__c>());
                wraplst.add(wrap);
                index++;
            }

        }
        if(wraplst.size() > 0) wrapnew.Prodwrap = wraplst;
        return wrapnew;
    }
    @AuraEnabled(cacheable=true)
    public static familywrap getPicklistFamilyAndSubFamily(){
        familywrap fwrap = new familywrap();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        fwrap.family.add(new SelectOptions('--None--', '--None--'));
        for(Schema.PicklistEntry f : ple) fwrap.family.add(new SelectOptions(f.getValue(), f.getLabel()));
        fieldResult = Product2.ERP7__Product_Service_Family__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        fwrap.Subfamily.add(new SelectOptions('--None--', '--None--'));
        for(Schema.PicklistEntry f : ple) fwrap.Subfamily.add(new SelectOptions(f.getValue(), f.getLabel()));

        fieldResult = Product2.ERP7__MRP_Algoithm__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        fwrap.algorithm.add(new SelectOptions('--None--', '--None--'));
        for(Schema.PicklistEntry f : ple) fwrap.algorithm.add(new SelectOptions(f.getValue(), f.getLabel()));

        List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                            where ERP7__Employee_User__c=:UserInfo.getUserId()];
        if(empList.size()>0 && empList != null){
            fwrap.ChannelId = empList[0].ERP7__Channel__c;
            List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c,ERP7__Site__r.Name, ERP7__Site__r.ERP7__Address__c,ERP7__Active__c from ERP7__Distribution_Channel__c
                                                          where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
            if(dcList.size()>0 && dcList != null) fwrap.site = new ERP7__site__c(Id=dcList[0].ERP7__Site__c,Name = dcList[0].ERP7__Site__r.Name);
        }
        return fwrap;
    }
    @AuraEnabled(cacheable=true)
    public static MainWrap getInventoryDetails(string searchstr, string family,String subfamily,String selectedSite,Integer pageSize, Integer pageNumber,Integer ind){
        MainWrap wrapnew = new MainWrap();
        system.debug('getInventoryDetails called : '+selectedSite);
        List<wrapper> wraplst = new List<wrapper>();
        string srch = '%' + searchstr + '%';
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        String baseQuery = 'SELECT COUNT() FROM Product2 WHERE (Name LIKE :srch OR ProductCode LIKE :srch) AND IsActive = true';
        if (family != null && family != '' && family != '--None--') {
            baseQuery += ' AND Family = :family';
        }

        if (subfamily != null && subfamily != '' && subfamily != '--None--') {
            baseQuery += ' AND ERP7__Product_Service_Family__c = :subfamily';
        }

        Integer totalRecords = Database.countQuery(baseQuery);
        wrapnew.pageSize = pageSize;
        wrapnew.pageNumber = pageNumber;
        wrapnew.recordStart = offset + 1;
        wrapnew.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        wrapnew.totalRecords = totalRecords;
        String query = 'Select Id,Name, ProductCode, ERP7__MRP_Algoithm__c,Family, ERP7__Product_Service_Family__c, ERP7__Issue_Purchase_Order__c ,ERP7__Issue_Manufacturing_Order__c from Product2 where IsActive = true';
        if(srch != null && srch != '') query += ' AND (Name Like : srch or ProductCode Like :srch) ';
        if(family != null && family != '' && family != '--None--') query += ' AND Family = :family';
        if(subfamily != null && subfamily != '' && subfamily != '--None--') query += ' AND ERP7__Product_Service_Family__c = :subfamily';
        query += ' Limit :pageSize ';
        if ((String.isBlank(family) || family == '--None--') && String.isBlank(searchstr) && (String.isBlank(subfamily) || subfamily == '--None--')) {
            query += ' OFFSET :offset';
        }
        List<Product2> ProdList = database.query(query);
        if(ProdList.size() > 0){
            set<Id> prodIds = new set<Id>();
            for(Product2 prod : ProdList){
                prodIds.add(prod.Id);
            }
            List<ERP7__Reordering_Rule__c> reorderingRules = [Select Id,Name,ERP7__Active__c,ERP7__Lead_Time__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Vendor_Account__c,ERP7__Vendor_Account__r.Name,ERP7__Routing__c,ERP7__Routing__r.Name,ERP7__Minimum_Quantity__c,ERP7__Maximum_Quantity__c,ERP7__MinimumOrderingQuantity__c from ERP7__Reordering_Rule__c where ERP7__Product__c IN: prodIds  ];
            Map<Id,List<ERP7__Reordering_Rule__c>> ProductReorderMap = new Map<Id,List<ERP7__Reordering_Rule__c>>();
            for(ERP7__Reordering_Rule__c rr : reorderingRules){
                if(ProductReorderMap.containsKey(rr.ERP7__Product__c)){
                    ProductReorderMap.get(rr.ERP7__Product__c).add(rr);
                }
                else{
                    ProductReorderMap.put(rr.ERP7__Product__c, new List<ERP7__Reordering_Rule__c>{rr});
                }
            }
            if(selectedSite == null || selectedSite == ''){
                List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                    where ERP7__Employee_User__c=:UserInfo.getUserId()];
                if(empList.size()>0 && empList != null){
                    wrapnew.ChannelId = empList[0].ERP7__Channel__c;
                    List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.ERP7__Address__c,ERP7__Active__c from ERP7__Distribution_Channel__c
                                                                  where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                    if(dcList.size()>0 && dcList != null) selectedSite = dcList[0].ERP7__Site__c;
                }
            }
            Map<Id, AggregateResult> inventoryResultMap = new Map<Id, AggregateResult>();

            List<AggregateResult> inventoryResult= [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock,
                                                    SUM(ERP7__Reserved_Manufactured_Qty__c) reservedMO,SUM(ERP7__Stock_Reserved_for_SO__c)  reservedSO, SUM(ERP7__No_of_Items_Reserved__c) totalReserved,
                                                    SUM(ERP7__Number_of_Items_In_Quality_Check__c) qcStock,SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) awaitingStock, SUM(ERP7__IC_transfer_Stocks__c) ictransfer
                                                    FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true
                                                    And ERP7__Warehouse__c = :selectedSite
                                                    and ERP7__Product__c IN:prodIds GROUP BY ERP7__Product__c];
            for (AggregateResult result : inventoryResult) {
                Id productId = (Id)result.get('ERP7__Product__c');
                inventoryResultMap.put(productId, result);
            }

            List<ERP7__Reordering_Rule__c> reorderLst = [Select Id,Name,ERP7__Product__c,ERP7__Lead_Time__c ,ERP7__Maximum_Quantity__c,ERP7__Minimum_Quantity__c from ERP7__Reordering_Rule__c where ERP7__Product__c IN : prodIds Order By createdDate];
            List<ERP7__Approved_Vendor__c> appVenlst = [Select Id,Name,ERP7__Cost_Card__c,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Lead_Time__c,ERP7__Product__c,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Status__c from ERP7__Approved_Vendor__c where ERP7__Product__c IN : prodIds and ERP7__Status__c = 'Approved' and ERP7__Vendor__c != null ];//and ERP7__Cost_Card__c != null
            Map<Id,List<ERP7__Approved_Vendor__c>> ProdAppven = new Map<Id,List<ERP7__Approved_Vendor__c>>();
            Map<Id,ERP7__Reordering_Rule__c> ProdRule = new Map<Id,ERP7__Reordering_Rule__c>();
            for(ERP7__Reordering_Rule__c rr : reorderLst){
                if(rr.ERP7__Product__c != null) ProdRule.put(rr.ERP7__Product__c,rr);
            }
            for(ERP7__Approved_Vendor__c appVen : appVenlst){
                if(appVen.ERP7__Product__c != null){
                    if(ProdAppven.containsKey(appVen.ERP7__Product__c)) ProdAppven.get(appVen.ERP7__Product__c).add(appVen);
                    else ProdAppven.put(appVen.ERP7__Product__c,new List<ERP7__Approved_Vendor__c>{appVen});
                }
            }
            String returnrecordId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__PO__c','Standard_Purchase_Order');
            List<AggregateResult> prliAggregateResults = [SELECT ERP7__Product__c, COUNT(ERP7__Purchase_Orders__c) purchaseOrderCount, SUM(ERP7__Remaining_Quantity__c) totalQuantity, COUNT(Id) recordCount FROM ERP7__Purchase_Line_Items__c WHERE  ERP7__Logistic_Quantity__c >= 0  AND ERP7__Quantity__c > 0 AND ERP7__Remaining_Quantity__c > 0 AND ERP7__Product__c != null   AND ERP7__Product__c IN :prodIds    AND ERP7__Purchase_Orders__c != null   AND ERP7__Purchase_Orders__r.RecordTypeId = :returnrecordId   AND ERP7__Purchase_Orders__r.ERP7__Distribution_Channel__r.ERP7__Site__c = :selectedSite
                                                           AND (ERP7__Purchase_Orders__r.ERP7__Status__c != 'Cancelled' AND ERP7__Purchase_Orders__r.ERP7__Status__c != 'Closed') And ERP7__Purchase_Orders__r.ERP7__Is_Closed__c = false
                                                          GROUP BY ERP7__Product__c];
            Map<Id,AggregateResult> prliProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : prliAggregateResults){
                Id productId = (Id)result.get('ERP7__Product__c');
                prliProds.put(productId, result);
            }
            List<AggregateResult> aggregateResultsMO = [Select ERP7__Product__c,COUNT (Id) mocount,SUM(ERP7__Remaining_Quantity__c) totalQuantity from ERP7__Manufacturing_Order__c where ERP7__Remaining_Quantity__c > 0 and ERP7__Product__c IN :prodIds and (ERP7__Status__c != 'Complete' AND ERP7__Status__c != 'Cancelled')  GROUP BY ERP7__Product__c];
            Map<Id,AggregateResult> MOProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : aggregateResultsMO){
                Id productId = (Id)result.get('ERP7__Product__c');
                MOProds.put(productId, result);
            }
            List<AggregateResult> demandSo = [Select Product2Id,SUM(ERP7__Required_Stock__c) totalQuantity, COUNT (OrderId) orderCount from OrderItem where Product2Id != null AND Product2Id IN:prodIds AND ERP7__Logistic_Quantity__c >= 0 and ERP7__Required_Stock__c > 0 and Order.ERP7__Is_Closed__c = false GROUP BY Product2Id];
            Map<Id,AggregateResult> demandSoProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : demandSo){
                Id productId = (Id)result.get('Product2Id');
                demandSoProds.put(productId, result);
            }
            List< AggregateResult > MRPSDemand = [Select ERP7__MRP_Product__c,SUM(ERP7__Remaining_Quantity_to_Allocate__c) totalQuantity,count(ERP7__MO__c) mocount from ERP7__MRP__c where ERP7__MRP_Product__c IN :prodIds and ERP7__MRP_Product__c != null and ERP7__Remaining_Quantity_to_Allocate__c > 0 and ERP7__MO__c != null and ERP7__Status__c = :'Requested' and (ERP7__MO__r.ERP7__Status__c != 'Complete' and ERP7__MO__r.ERP7__Status__c != 'Cancelled') GROUP BY ERP7__MRP_Product__c];
            Map<Id,AggregateResult> MRPsDemandProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : MRPSDemand){
                Id productId = (Id)result.get('ERP7__MRP_Product__c');
                MRPsDemandProds.put(productId, result);
            }
            Integer index = (ind > 0) ? ind : 1;
            for(Product2 pro : ProdList){
                wrapper wrap = new wrapper();
                wrap.index = index;
                wrap.prod=pro;
                wrap.reOrderId = '--None--';
                wrap.reorderqry = 'ERP7__Product__c = \'' + pro.Id + '\'';
                wrap.algorithm = (pro.ERP7__MRP_Algoithm__c != null && pro.ERP7__MRP_Algoithm__c != '') ? pro.ERP7__MRP_Algoithm__c  : '--None--';
                if(ProdAppven.containskey(pro.Id)) wrap.approvedVendors = ProdAppven.get(pro.Id);
                if(ProdRule.containskey(pro.Id)){
                    wrap.minQty = ProdRule.get(pro.Id).ERP7__Minimum_Quantity__c;
                    wrap.maxQty = ProdRule.get(pro.Id).ERP7__Maximum_Quantity__c;
                }
                if (inventoryResultMap.containsKey(pro.Id)) {
                    AggregateResult result = inventoryResultMap.get(pro.Id);
                    wrap.onHand =(Decimal)result.get('totalStock');
                    wrap.reservedMO =(Decimal)result.get('reservedMO');
                    wrap.reservedSO =(Decimal)result.get('reservedSO');
                    wrap.QC =(Decimal)result.get('qcStock');
                    wrap.orderedQty =(Decimal)result.get('awaitingStock');
                    wrap.icTransfer =(Decimal)result.get('ictransfer');
                }
                if(prliProds.containsKey(pro.Id)){
                    AggregateResult result = prliProds.get(pro.Id);
                    wrap.openPosCount =(Integer)result.get('purchaseOrderCount');
                    wrap.openPos =(Decimal)result.get('totalQuantity');
                }
                if(MOProds.containsKey(pro.Id)){
                    AggregateResult result = MOProds.get(pro.Id);
                    wrap.openMosCount =(Integer)result.get('mocount');
                    wrap.openMos =(Decimal)result.get('totalQuantity');
                }
                if(demandSoProds.containsKey(pro.Id)){
                    AggregateResult result = demandSoProds.get(pro.Id);
                    wrap.demandSalesCount =(Integer)result.get('orderCount');
                    wrap.demandSales =(Decimal)result.get('totalQuantity');
                }
                if(MRPsDemandProds.containsKey(pro.Id)){
                    AggregateResult result = MRPsDemandProds.get(pro.Id);
                    wrap.demandMOCount =(Integer)result.get('mocount');
                    wrap.demandMO =(Decimal)result.get('totalQuantity');
                }
                decimal demand = wrap.demandSales + wrap.demandMO;
                demand = demand - wrap.openPos - wrap.openMos;
                System.debug('demand : '+demand);
                if (wrap.minQty > 0 && wrap.onHand < wrap.minQty) {
                    wrap.suggestedQty = (wrap.minQty + demand) - wrap.onHand;
                }
                else if(wrap.maxQty > 0 && wrap.onHand > wrap.maxQty){
                    wrap.suggestedQty = 0;
                }
                else wrap.suggestedQty = (demand > wrap.onHand) ? (demand - wrap.onHand) : 0;
                wrap.netQty = (wrap.onHand + wrap.reservedMO + wrap.reservedSO +  wrap.openPos + wrap.openMos + wrap.icTransfer) - (wrap.demandSales + wrap.demandMO);
                wrap.reorderlist = (ProductReorderMap.containsKey(pro.Id) ? ProductReorderMap.get(pro.Id) : new List<ERP7__Reordering_Rule__c>());

                wraplst.add(wrap);
                index++;
            }

        }
        if(wraplst.size() > 0) wrapnew.Prodwrap = wraplst;
        return wrapnew;
    }
    @AuraEnabled
    public static ForecastWrapper getforecastByProduct(String productId,String forecastval,String forecastTypeval,Date fromDate,Date toDate){
        if(productId != null && productId != ''){
            ForecastWrapper forecastWrap = new ForecastWrapper();
            Product2 product = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id = :productId];
            forecastWrap.productName = product.Name;
            forecastWrap.productCode = product.ProductCode;
            forecastWrap.productId= product.Id;
            List<ERP7__Forecast_Plan__c> forecastplans = new List<ERP7__Forecast_Plan__c>();
            forecastplans = [  SELECT Id, Name, ERP7__Product__c,
                             (SELECT Id, Name, ERP7__Actual__c,ERP7__FPA__c,ERP7__Predicted__c,ERP7__Month_Quarter_Year__c FROM ERP7__Forecast_Items__r)
                             FROM ERP7__Forecast_Plan__c
                             WHERE ERP7__Forecast_Category__c = :forecastTypeval
                             AND ERP7__Forecast_Type__c = :forecastval
                             AND ERP7__Product__c = :product.Id
                             AND ERP7__Start_Date__c = :fromDate
                             AND ERP7__End_Date__c = :toDate
                             LIMIT 1
                            ];
            if(forecastplans.size() > 0){
                ERP7__Forecast_Plan__c plan = forecastplans[0];

                List<ERP7__Forecasting_Items__c> forecatsItems1 = forecastplans[0].ERP7__Forecast_Items__r;
                forecastWrap.forecastPlan = plan;
                forecastWrap.forecastItems = forecatsItems1;
                for(ERP7__Forecasting_Items__c item : forecatsItems1){
                    //  KeyForecastMAp.put(item.ERP7__Month_Quarter_Year__c,item);
                    IF(!forecastWrap.monthQuantities.contains(item.ERP7__Month_Quarter_Year__c)) forecastWrap.monthQuantities.add(item.ERP7__Month_Quarter_Year__c);
                }
            }
            else{
                ERP7__Forecast_Plan__c plan = new ERP7__Forecast_Plan__c(Name='Forecast for '+forecastTypeval+'-'+String.valueof(System.today()),ERP7__Forecast_Category__c = forecastTypeval,ERP7__Forecast_Type__c = forecastval,ERP7__Product__c = product.Id,ERP7__Start_Date__c = fromDate , ERP7__End_Date__c = toDate);

                List<ERP7__Forecasting_Items__c> forecatsItems1 =new List<ERP7__Forecasting_Items__c>();

                if (forecastval == 'Month') {
                    Integer startYear = fromDate.year();
                    Integer startMonth = fromDate.month();
                    Integer endYear = toDate.year();
                    Integer endMonth = toDate.month();

                    // Loop through the range of years and months
                    for (Integer year = startYear; year <= endYear; year++) {
                        // Determine the start and end months for each year
                        Integer loopStartMonth = (year == startYear) ? startMonth : 1;
                        Integer loopEndMonth = (year == endYear) ? endMonth : 12;

                        // Generate keys for each month in the range
                        for (Integer month = loopStartMonth; month <= loopEndMonth; month++) {
                            String monthYearKey = String.valueOf(year) + '-' + String.valueOf(month);
                            ERP7__Forecasting_Items__c itemtoAdd =  new ERP7__Forecasting_Items__c();
                            itemtoAdd.ERP7__Month_Quarter_Year__c = monthYearKey;
                            itemtoAdd.Name = monthYearKey;
                            itemtoAdd.ERP7__Actual__c = 0;
                            itemtoAdd.ERP7__FPA__c = 0;
                            itemtoAdd.ERP7__Predicted__c = 0;
                            forecatsItems1.add(itemtoAdd);
                            // forecastWrap.monthQuantities.put(monthYearKey, 0);
                        }
                    }
                    //forecastWrap.monthQuantities.put('Predicted Average', 0);
                }
                else if (forecastval == 'Quarter') {
                    Integer startYear = fromDate.year();
                    Integer startQuarter = (fromDate.month() - 1) / 3 + 1;
                    Integer endYear = toDate.year();
                    Integer endQuarter = (toDate.month() - 1) / 3 + 1;

                    // Loop through the range of years and quarters
                    for (Integer year = startYear; year <= endYear; year++) {
                        // Determine the start and end quarters for each year
                        Integer loopStartQuarter = (year == startYear) ? startQuarter : 1;
                        Integer loopEndQuarter = (year == endYear) ? endQuarter : 4;

                        // Generate keys for each quarter in the range
                        for (Integer quarter = loopStartQuarter; quarter <= loopEndQuarter; quarter++) {
                            String quarterYearKey = String.valueOf(year) + '-Q' + String.valueOf(quarter);
                            ERP7__Forecasting_Items__c itemtoAdd =  new ERP7__Forecasting_Items__c();
                            itemtoAdd.ERP7__Month_Quarter_Year__c = quarterYearKey;
                            itemtoAdd.Name = quarterYearKey;
                            itemtoAdd.ERP7__Actual__c = 0;
                            itemtoAdd.ERP7__FPA__c = 0;
                            itemtoAdd.ERP7__Predicted__c = 0;
                            forecatsItems1.add(itemtoAdd);
                            //forecastWrap.monthQuantities.put(quarterYearKey, 0);
                        }
                    }
                    //  forecastWrap.monthQuantities.put('Predicted Average', 0);
                }
                forecastWrap.forecastPlan = plan;
                forecastWrap.forecastItems = forecatsItems1;
                for(ERP7__Forecasting_Items__c item : forecatsItems1){
                    //KeyForecastMAp.put(item.ERP7__Month_Quarter_Year__c,item);
                    IF(!forecastWrap.monthQuantities.contains(item.ERP7__Month_Quarter_Year__c)) forecastWrap.monthQuantities.add(item.ERP7__Month_Quarter_Year__c);
                }
            }

            if(forecastTypeval == 'Sales'){

                List<OrderItem> ordItemList = [
                    SELECT Id, OrderId,Order.Name, Quantity, Order.CreatedDate,Product2Id,Product2.Name,Order.AccountID,Order.Account.Name
                    FROM OrderItem
                    WHERE Product2Id != null
                    AND Product2Id = :productId
                    AND OrderId != null
                    AND Order.CreatedDate <= :toDate
                    AND Order.CreatedDate >= :fromDate
                    Order by CreatedDate ASC
                ];
                if(forecastval == 'Month'){
                    for(OrderItem ordItem : ordItemList) {
                        String key = ordItem.Order.CreatedDate.year() + '-' + ordItem.Order.CreatedDate.month();
                        for(ERP7__Forecasting_Items__c fr : forecastWrap.forecastItems){
                            if(fr.ERP7__Month_Quarter_Year__c == key){

                                fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + ordItem.Quantity) : ordItem.Quantity;
                            }
                        }
                        /* if (forecastWrap.monthQuantities.containsKey(key)) {
forecastWrap.monthQuantities.put(key, forecastWrap.monthQuantities.get(key) + ordItem.Quantity);
} else {
forecastWrap.monthQuantities.put(key, ordItem.Quantity);
}*/
                        forecastWrap.quantity += ordItem.Quantity;
                        if(!forecastWrap.orderWarp.containsKey(key))      forecastWrap.orderWarp.put(key, new List<OrderDetailsWrap>{ new OrderDetailsWrap(ordItem.Order.Name, ordItem.Order.Account.Name, ordItem.Quantity,ordItem.OrderId) });
                        else {
                            forecastWrap.orderWarp.get(key).add(new OrderDetailsWrap(ordItem.Order.Name,ordItem.Order.Account.Name,ordItem.Quantity,ordItem.OrderId));
                        }
                    }
                }
                else if(forecastval == 'Quarter'){

                    Map<String, Decimal> quarterQuantityMap = new Map<String, Decimal>();
                    for(OrderItem ordItem : ordItemList) {
                        Integer quarter = (ordItem.Order.CreatedDate.month() - 1) / 3 + 1;
                        String key = ordItem.Order.CreatedDate.year() + '-Q' + quarter;
                        for(ERP7__Forecasting_Items__c fr : forecastWrap.forecastItems){
                            if(fr.ERP7__Month_Quarter_Year__c == key){

                                fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + ordItem.Quantity) : ordItem.Quantity;
                            }
                        }
                        /*if (forecastWrap.monthQuantities.containsKey(key)) {
forecastWrap.monthQuantities.put(key, forecastWrap.monthQuantities.get(key) + ordItem.Quantity);
} else {
forecastWrap.monthQuantities.put(key, ordItem.Quantity);
}*/
                        forecastWrap.quantity += ordItem.Quantity;
                        if(!forecastWrap.orderWarp.containsKey(key))      forecastWrap.orderWarp.put(key, new List<OrderDetailsWrap>{ new OrderDetailsWrap(ordItem.Order.Name, ordItem.Order.Account.Name, ordItem.Quantity,ordItem.OrderId) });
                        else {
                            forecastWrap.orderWarp.get(key).add(new OrderDetailsWrap(ordItem.Order.Name,ordItem.Order.Account.Name,ordItem.Quantity,ordItem.OrderId));
                        }
                    }
                }

            }
            else if(forecastTypeval == 'Production/Supply'){
                List<ERP7__Manufacturing_Order__c> moRaised = [Select Id,Name,ERP7__Quantity__c,CreatedDate from ERP7__Manufacturing_Order__c    where ERP7__Product__c != null
                                                               AND ERP7__Product__c = :productId
                                                               AND CreatedDate <= :toDate
                                                               AND CreatedDate >= :fromDate Order by CreatedDate ASC
                                                              ];
                List<ERP7__Purchase_Line_Items__c> poRaised = [Select Id,Name,ERP7__Quantity__c,CreatedDate,ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.Name,ERP7__Purchase_Orders__r.Vendor__c,ERP7__Purchase_Orders__r.Vendor__r.Name from ERP7__Purchase_Line_Items__c    where ERP7__Product__c != null
                                                               AND ERP7__Product__c = :productId
                                                               AND CreatedDate <= :toDate
                                                               AND CreatedDate >= :fromDate Order by CreatedDate ASC
                                                              ];
                if(forecastval == 'Month'){
                    for(ERP7__Manufacturing_Order__c mos : moRaised) {
                        String key = mos.CreatedDate.year() + '-' + mos.CreatedDate.month();
                        for(ERP7__Forecasting_Items__c fr : forecastWrap.forecastItems){
                            if(fr.ERP7__Month_Quarter_Year__c == key){

                                fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + mos.Quantity__c) : mos.Quantity__c;
                            }
                        }

                        /* if (forecastWrap.monthQuantities.containsKey(key)) {
forecastWrap.monthQuantities.put(key, forecastWrap.monthQuantities.get(key) + mos.Quantity__c);
} else {
forecastWrap.monthQuantities.put(key, mos.Quantity__c);
}*/
                        forecastWrap.quantity += mos.Quantity__c;
                        if(!forecastWrap.orderWarp.containsKey(key))      forecastWrap.orderWarp.put(key, new List<OrderDetailsWrap>{ new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id)});
                        else {
                            forecastWrap.orderWarp.get(key).add(new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id));
                        }
                    }
                    for(ERP7__Purchase_Line_Items__c pos : poRaised){
                        String key = pos.CreatedDate.year() + '-' + pos.CreatedDate.month();
                        for(ERP7__Forecasting_Items__c fr : forecastWrap.forecastItems){
                            if(fr.ERP7__Month_Quarter_Year__c == key){

                                fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + pos.Quantity__c) : pos.Quantity__c;
                            }
                        }
                        /*if (forecastWrap.monthQuantities.containsKey(key)) {
forecastWrap.monthQuantities.put(key, forecastWrap.monthQuantities.get(key) + pos.Quantity__c);
} else {
forecastWrap.monthQuantities.put(key, pos.Quantity__c);
}*/
                        forecastWrap.quantity += pos.Quantity__c;
                        if(!forecastWrap.orderWarp.containsKey(key))      forecastWrap.orderWarp.put(key, new List<OrderDetailsWrap>{ new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.ERP7__Purchase_Orders__c)});
                        else {
                            forecastWrap.orderWarp.get(key).add(new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.ERP7__Purchase_Orders__c));
                        }
                    }
                }
                else if(forecastval == 'Quarter'){
                    Map<String, Decimal> quarterQuantityMap = new Map<String, Decimal>();
                    for(ERP7__Manufacturing_Order__c mos : moRaised) {
                        Integer quarter = (mos.CreatedDate.month() - 1) / 3 + 1;
                        String key = mos.CreatedDate.year() + '-Q' + quarter;
                        for(ERP7__Forecasting_Items__c fr : forecastWrap.forecastItems){
                            if(fr.ERP7__Month_Quarter_Year__c == key){

                                fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + mos.Quantity__c) : mos.Quantity__c;
                            }
                        }
                        /* if (forecastWrap.monthQuantities.containsKey(key)) {
forecastWrap.monthQuantities.put(key, forecastWrap.monthQuantities.get(key) + mos.Quantity__c);
} else {
forecastWrap.monthQuantities.put(key, mos.Quantity__c);
}*/
                        forecastWrap.quantity += mos.Quantity__c;
                        if(!forecastWrap.orderWarp.containsKey(key))      forecastWrap.orderWarp.put(key, new List<OrderDetailsWrap>{ new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id)});
                        else {
                            forecastWrap.orderWarp.get(key).add(new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id));
                        }
                    }
                    for(ERP7__Purchase_Line_Items__c pos : poRaised){
                        Integer quarter = (pos.CreatedDate.month() - 1) / 3 + 1;
                        String key = pos.CreatedDate.year() + '-Q' + quarter;
                        for(ERP7__Forecasting_Items__c fr : forecastWrap.forecastItems){
                            if(fr.ERP7__Month_Quarter_Year__c == key){

                                fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + pos.Quantity__c) : pos.Quantity__c;
                            }
                        }
                        /*  if (forecastWrap.monthQuantities.containsKey(key)) {
forecastWrap.monthQuantities.put(key, forecastWrap.monthQuantities.get(key) + pos.Quantity__c);
} else {
forecastWrap.monthQuantities.put(key, pos.Quantity__c);
}*/
                        forecastWrap.quantity += pos.Quantity__c;
                        if(!forecastWrap.orderWarp.containsKey(key))      forecastWrap.orderWarp.put(key, new List<OrderDetailsWrap>{ new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.Id)});
                        else {
                            forecastWrap.orderWarp.get(key).add(new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.Id));
                        }                     }
                }

            }
            Decimal predictiveAverageSales = 0;
            Decimal totalQty = 0;
            decimal monthsize = forecastWrap.monthQuantities.size();
            System.debug('monthsize : '+monthsize);
            /* for(Decimal qty : forecastWrap.monthQuantities.values()){
totalQty += qty;
}*/
            System.debug('totalQty : '+totalQty);
            predictiveAverageSales = Math.Round(totalQty/(monthsize -1));
            //forecastWrap.monthQuantities.put('Predicted Average',predictiveAverageSales);
            return forecastWrap;
        }
        return null;
    }
    @AuraEnabled
    public static MainForecastWrap getforecastforMRPS(String forecastval,String forecastTypeval,Date fromDate,Date toDate,Integer pageSize, Integer pageNumber,List<String> ProdIds,List<string> MPSIds){
        MainForecastWrap wrapnew = new MainForecastWrap();
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        Integer totalRecords = 0;
        if(ProdIds.size() > 0){
            totalRecords = ProdIds.size();
        }
         else{
            String baseQuery = 'SELECT COUNT() FROM Product2 WHERE IsActive = true';
            totalRecords = Database.countQuery(baseQuery);
        }

        wrapnew.pageSize = pageSize;
        wrapnew.pageNumber = pageNumber;
        wrapnew.recordStart = offset + 1;
        wrapnew.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        wrapnew.totalRecords = totalRecords;
        List<Product2> productList = new List<Product2>();
        if(ProdIds.size() > 0){
            productList =   [SELECT Id, Name, ProductCode FROM Product2 WHERE IsActive = true and Id IN:ProdIds Limit :pageSize  OFFSET :offset];
        }
        else productList =   [SELECT Id, Name, ProductCode FROM Product2 WHERE IsActive = true Limit :pageSize  OFFSET :offset];
        MAP<Id,List<ERP7__MPS_line_Item__c>> mpsItemsMap = new MAP<Id,List<ERP7__MPS_line_Item__c>>();
        if(MPSIds.size() > 0){
            List<ERP7__MPS_line_Item__c> mpsItems = [Select Id,Name,ERP7__Actual_Demand__c,ERP7__Demand_Forecast__c,ERP7__FPA__c,ERP7__Month_Quarter_Year__c,ERP7__MPS__c,ERP7__MPS__r.ERP7__Product__c from ERP7__MPS_line_Item__c where ERP7__MPS__c IN:MPSIds and ERP7__MPS__c != null and ERP7__MPS__r.ERP7__Forecast_Type__c = :forecastTypeval and ERP7__MPS__r.ERP7__Schedule_Period__c =: forecastval];
            for(ERP7__MPS_line_Item__c mpsItem :  mpsItems){
                if(mpsItemsMap.containsKey(mpsItem.ERP7__MPS__r.ERP7__Product__c)){
                    mpsItemsMap.get(mpsItem.ERP7__MPS__r.ERP7__Product__c).add(mpsItem);
                }
                   else mpsItemsMap.put(mpsItem.ERP7__MPS__r.ERP7__Product__c,new List<ERP7__MPS_line_Item__c>{mpsItem});
            }
        }
        List<ForecastWrapper> forecastList = new List<ForecastWrapper>();
        Map<Id, ForecastWrapper> productIdToWrapperMap = new Map<Id, ForecastWrapper>();
        Map<Integer, String> monthMap = new Map<Integer, String>{
            1 => 'Jan',
            2 => 'Feb',
            3 => 'Mar',
            4 => 'Apr',
            5 => 'May',
            6 => 'Jun',
            7 => 'Jul',
            8 => 'Aug',
            9 => 'Sep',
            10 => 'Oct',
            11 => 'Nov',
            12 => 'Dec'
                };
        if(productList.size() > 0){
            for (Product2 product : productList) {
                ForecastWrapper forecastWrapper = new ForecastWrapper();
                List<ERP7__MPS_line_Item__c> forecatsItems1 =new List<ERP7__MPS_line_Item__c>();
                Boolean mpsExists = (mpsItemsMap.containsKey(product.Id) && mpsItemsMap.get(product.Id).size() > 0) ? true : false;
               system.debug('mpsExists : '+mpsExists);
                if(mpsExists){
                    forecatsItems1 = mpsItemsMap.get(product.Id);
                }
                else{
                    system.debug('else');
                   if(forecastval == 'Monthly'){
                    Integer startYear = fromDate.year();
                    Integer startMonth = fromDate.month();
                    Integer endYear = toDate.year();
                    Integer endMonth = toDate.month();
                    for (Integer year = startYear; year <= endYear; year++) {
                        // Determine the start and end months for each year
                        Integer loopStartMonth = (year == startYear) ? startMonth : 1;
                        Integer loopEndMonth = (year == endYear) ? endMonth : 12;

                        // Generate keys for each month in the range
                        for (Integer month = loopStartMonth; month <= loopEndMonth; month++) {
                            string monnthval = monthMap.get(month);
                            String monthYearKey = monnthval + '-' + String.valueOf(year);
                            ERP7__MPS_line_Item__c itemtoAdd =  new ERP7__MPS_line_Item__c();
                            itemtoAdd.ERP7__Month_Quarter_Year__c = monthYearKey;
                            itemtoAdd.Name = monthYearKey;
                            itemtoAdd.ERP7__Actual_Demand__c = 0;
                            itemtoAdd.ERP7__FPA__c = 0;
                            itemtoAdd.ERP7__Demand_Forecast__c = 0;
                            forecatsItems1.add(itemtoAdd);
                            // forecastWrapper.monthQuantities.put(monthYearKey, 0);
                        }
                    }
                }
                   else if (forecastval == 'Quarterly') {
                    Integer startYear = fromDate.year();
                    Integer startQuarter = (fromDate.month() - 1) / 3 + 1;
                    Integer endYear = toDate.year();
                    Integer endQuarter = (toDate.month() - 1) / 3 + 1;

                    // Loop through the range of years and quarters
                    for (Integer year = startYear; year <= endYear; year++) {
                        // Determine the start and end quarters for each year
                        Integer loopStartQuarter = (year == startYear) ? startQuarter : 1;
                        Integer loopEndQuarter = (year == endYear) ? endQuarter : 4;

                        // Generate keys for each quarter in the range
                        for (Integer quarter = loopStartQuarter; quarter <= loopEndQuarter; quarter++) {
                            String quarterYearKey = 'Q'+String.valueOf(quarter) + '-'+String.valueOf(year);
                            ERP7__MPS_line_Item__c itemtoAdd =  new ERP7__MPS_line_Item__c();
                            itemtoAdd.ERP7__Month_Quarter_Year__c = quarterYearKey;
                            itemtoAdd.Name = quarterYearKey;
                            itemtoAdd.ERP7__Actual_Demand__c = 0;
                            itemtoAdd.ERP7__FPA__c = 0;
                            itemtoAdd.ERP7__Demand_Forecast__c = 0;
                            forecatsItems1.add(itemtoAdd);
                            //forecastWrapper.monthQuantities.put(quarterYearKey, 0);
                        }
                    }
                }
                }
               system.debug('forecatsItems1 : '+forecatsItems1.size());
                forecastWrapper = new ForecastWrapper(product.Id,product.Name, product.ProductCode, 0,new  Map<String,List<OrderDetailsWrap>>(),forecatsItems1,new List<ReorderingWrap>());
                Map<String,ERP7__MPS_line_Item__c> KeyForecastMAp = new  Map<String,ERP7__MPS_line_Item__c>();
                for(ERP7__MPS_line_Item__c item : forecatsItems1){
                    KeyForecastMAp.put(item.ERP7__Month_Quarter_Year__c,item);
                    IF(!forecastWrapper.monthQuantities.contains(item.ERP7__Month_Quarter_Year__c)) forecastWrapper.monthQuantities.add(item.ERP7__Month_Quarter_Year__c);
                }
                productIdToWrapperMap.put(product.Id, forecastWrapper);
            }
            if(forecastTypeval == 'Sales'){

                List<OrderItem> ordItemList = [
                    SELECT Id, OrderId,Order.Name, Quantity, Order.CreatedDate,Product2Id,Product2.Name,Order.Account.Name,Order.AccountId
                    FROM OrderItem
                    WHERE Product2Id != null
                    AND Product2Id IN :productIdToWrapperMap.keyset()
                    AND OrderId != null
                    AND Order.CreatedDate <= :toDate
                    AND Order.CreatedDate >= :fromDate
                    Order by CreatedDate ASC
                ];
                if(forecastval == 'Monthly'){
                    for (OrderItem ordItem : ordItemList) {
                        String monthYearKey = ordItem.Order.CreatedDate.format('MMM-yyyy');
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(ordItem.Product2Id);
                        for(ERP7__MPS_line_Item__c fr : forecastWrapper.MPSlineitems){
                            if(fr.ERP7__Month_Quarter_Year__c == monthYearKey){

                                fr.ERP7__Actual_Demand__c = (fr.ERP7__Actual_Demand__c > 0) ? (fr.ERP7__Actual_Demand__c + ordItem.Quantity) : ordItem.Quantity;
                            }

                        }
                        if(!forecastWrapper.orderWarp.containsKey(monthYearKey))      forecastWrapper.orderWarp.put(monthYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(ordItem.Order.Name, ordItem.Order.Account.Name, ordItem.Quantity,ordItem.OrderId) });
                        else {    forecastWrapper.orderWarp.get(monthYearKey).add(new OrderDetailsWrap(ordItem.Order.Name,ordItem.Order.Account.Name,ordItem.Quantity,ordItem.OrderId));
                             }
                        productIdToWrapperMap.put(ordItem.Product2Id, forecastWrapper);
                    }
                }
                else if(forecastval == 'Quarterly'){
                    for (OrderItem ordItem : ordItemList) {
                        Integer quarter = (ordItem.Order.CreatedDate.month() - 1) / 3 + 1;
                        String quarterYearKey = 'Q'+quarter + '-'+ordItem.Order.CreatedDate.year();
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(ordItem.Product2Id);
                        for(ERP7__MPS_line_Item__c fr : forecastWrapper.MPSlineitems){
                            if(fr.ERP7__Month_Quarter_Year__c == quarterYearKey){
                                fr.ERP7__Actual_Demand__c = (fr.ERP7__Actual_Demand__c > 0) ? (fr.ERP7__Actual_Demand__c + ordItem.Quantity) : ordItem.Quantity;
                            }
                        }
                        if(!forecastWrapper.orderWarp.containsKey(quarterYearKey))      forecastWrapper.orderWarp.put(quarterYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(ordItem.Order.Name, ordItem.Order.Account.Name, ordItem.Quantity,ordItem.OrderId) });
                        else {
                            forecastWrapper.orderWarp.get(quarterYearKey).add(new OrderDetailsWrap(ordItem.Order.Name,ordItem.Order.Account.Name,ordItem.Quantity,ordItem.OrderId));
                        }
                        productIdToWrapperMap.put(ordItem.Product2Id, forecastWrapper);
                    }
                }
            }
             else if(forecastTypeval == 'Production/Supply'){
                List<ERP7__Manufacturing_Order__c> moRaised = [SELECT Id, Name, ERP7__Quantity__c, CreatedDate, ERP7__Product__c FROM ERP7__Manufacturing_Order__c WHERE ERP7__Product__c IN :productIdToWrapperMap.keySet() AND CreatedDate <= :toDate AND CreatedDate >= :fromDate Order by CreatedDate ASC];
                List<ERP7__Purchase_Line_Items__c> poRaised = [SELECT Id, Name, ERP7__Quantity__c, CreatedDate, ERP7__Product__c,ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.Name,ERP7__Purchase_Orders__r.Vendor__c,ERP7__Purchase_Orders__r.Vendor__r.Name FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Product__c IN :productIdToWrapperMap.keySet() AND CreatedDate <= :toDate AND CreatedDate >= :fromDate Order by CreatedDate ASC];
                if(forecastval == 'Monthly'){
                    for (ERP7__Manufacturing_Order__c mos : moRaised) {
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(mos.ERP7__Product__c);
                        if (forecastWrapper != null) {
                            String monthYearKey = mos.CreatedDate.format('MMM-yyyy');
                            for(ERP7__MPS_line_Item__c fr : forecastWrapper.MPSlineitems){
                                if(fr.ERP7__Month_Quarter_Year__c == monthYearKey){
                                    fr.ERP7__Actual_Demand__c = (fr.ERP7__Actual_Demand__c > 0) ? (fr.ERP7__Actual_Demand__c + mos.ERP7__Quantity__c) : mos.ERP7__Quantity__c;
                                }
                            }
                            if(!forecastWrapper.orderWarp.containsKey(monthYearKey))      forecastWrapper.orderWarp.put(monthYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id)});
                            else {    forecastWrapper.orderWarp.get(monthYearKey).add(new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id));
                                 }
                            productIdToWrapperMap.put(mos.ERP7__Product__c, forecastWrapper);
                        }
                    }
                     for (ERP7__Purchase_Line_Items__c pos : poRaised) {
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(pos.ERP7__Product__c);
                        if (forecastWrapper != null) {
                            String monthYearKey = pos.CreatedDate.format('MMM-yyyy');
                            for(ERP7__MPS_line_Item__c fr : forecastWrapper.MPSlineitems){
                                if(fr.ERP7__Month_Quarter_Year__c == monthYearKey){
                                    fr.ERP7__Actual_Demand__c = (fr.ERP7__Actual_Demand__c > 0) ? (fr.ERP7__Actual_Demand__c + pos.ERP7__Quantity__c) : pos.ERP7__Quantity__c;
                                }
                            }
                             if(!forecastWrapper.orderWarp.containsKey(monthYearKey))      forecastWrapper.orderWarp.put(monthYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.ERP7__Purchase_Orders__c)});
                            else {
                                forecastWrapper.orderWarp.get(monthYearKey).add(new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.ERP7__Purchase_Orders__c));
                            }
                            productIdToWrapperMap.put(pos.ERP7__Product__c, forecastWrapper);
                        }
                     }
                }
                  else if(forecastval == 'Quarterly'){
                    for (ERP7__Manufacturing_Order__c mos : moRaised) {
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(mos.ERP7__Product__c);
                        if (forecastWrapper != null) {
                            Integer quarter = (mos.CreatedDate.month() - 1) / 3 + 1;
                            String quarterYearKey = 'Q'+quarter + '-'+mos.CreatedDate.year();
                            for(ERP7__MPS_line_Item__c fr : forecastWrapper.MPSlineitems){
                                if(fr.ERP7__Month_Quarter_Year__c == quarterYearKey){
                                    fr.ERP7__Actual_Demand__c = (fr.ERP7__Actual_Demand__c > 0) ? (fr.ERP7__Actual_Demand__c + mos.ERP7__Quantity__c) : mos.ERP7__Quantity__c;
                                }
                            }
                             if(!forecastWrapper.orderWarp.containsKey(quarterYearKey))      forecastWrapper.orderWarp.put(quarterYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id)});
                            else {
                                forecastWrapper.orderWarp.get(quarterYearKey).add(new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id));
                            }
                            productIdToWrapperMap.put(mos.ERP7__Product__c,forecastWrapper);
                        }
                    }
                    for (ERP7__Purchase_Line_Items__c pos : poRaised) {
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(pos.ERP7__Product__c);
                        if (forecastWrapper != null) {
                            Integer quarter = (pos.CreatedDate.month() - 1) / 3 + 1;
                            String quarterYearKey =  'Q'+quarter + '-'+pos.CreatedDate.year();
                            for(ERP7__MPS_line_Item__c fr : forecastWrapper.MPSlineitems){
                                if(fr.ERP7__Month_Quarter_Year__c == quarterYearKey){
                                    fr.ERP7__Actual_Demand__c = (fr.ERP7__Actual_Demand__c > 0) ? (fr.ERP7__Actual_Demand__c + pos.ERP7__Quantity__c) : pos.ERP7__Quantity__c;
                                }
                            }
                             if(!forecastWrapper.orderWarp.containsKey(quarterYearKey))      forecastWrapper.orderWarp.put(quarterYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.Id)});
                            else {
                                forecastWrapper.orderWarp.get(quarterYearKey).add(new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.Id));
                            }
                            productIdToWrapperMap.put(pos.ERP7__Product__c,forecastWrapper);
                        }
                    }
                }

            }
        }
        for (ForecastWrapper wrapper : productIdToWrapperMap.values()) {
             forecastList.add(wrapper);
        }
        if(forecastList.size() > 0) {
            wrapnew.ForecastWrap =forecastList;
            return wrapnew;
        }
        else return null;
    }
    @AuraEnabled
    public static MainForecastWrap getforecast(String forecastval,String forecastTypeval,Date fromDate,Date toDate,Integer pageSize, Integer pageNumber,List<String> ProdIds){
        MainForecastWrap wrapnew = new MainForecastWrap();
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        Integer totalRecords = 0;
        if(ProdIds.size() > 0){
            totalRecords = ProdIds.size();
        }
        else{
            String baseQuery = 'SELECT COUNT() FROM Product2 WHERE IsActive = true';
            totalRecords = Database.countQuery(baseQuery);
        }

        wrapnew.pageSize = pageSize;
        wrapnew.pageNumber = pageNumber;
        wrapnew.recordStart = offset + 1;
        wrapnew.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        wrapnew.totalRecords = totalRecords;
        List<Product2> productList = new List<Product2>();
        if(ProdIds.size() > 0){
            productList =   [SELECT Id, Name, ProductCode FROM Product2 WHERE IsActive = true and Id IN:ProdIds Limit :pageSize  OFFSET :offset];
        }
        else productList =   [SELECT Id, Name, ProductCode FROM Product2 WHERE IsActive = true Limit :pageSize  OFFSET :offset];
        List<ForecastWrapper> forecastList = new List<ForecastWrapper>();
        system.debug('forecastTypeval : '+forecastTypeval);
        system.debug('forecastval : '+forecastval);

        Map<Id, ForecastWrapper> productIdToWrapperMap = new Map<Id, ForecastWrapper>();


        if(productList.size() > 0){
            List<ERP7__Forecast_Plan__c> forecastplans = new List<ERP7__Forecast_Plan__c>();
            forecastplans = [  SELECT Id, Name, ERP7__Product__c,
                             (SELECT Id, Name, ERP7__Actual__c,ERP7__FPA__c,ERP7__Predicted__c,ERP7__Month_Quarter_Year__c FROM ERP7__Forecast_Items__r)
                             FROM ERP7__Forecast_Plan__c
                             WHERE ERP7__Forecast_Category__c = :forecastTypeval
                             AND ERP7__Forecast_Type__c = :forecastval
                             AND ERP7__Product__c IN :productList
                             AND ERP7__Start_Date__c = :fromDate
                             AND ERP7__End_Date__c = :toDate
                            ];
            wrapnew.ForecastPlans = forecastplans;
            Map<ERP7__Forecast_Plan__c, List<ERP7__Forecasting_Items__c>> forecastItemsMap = new Map<ERP7__Forecast_Plan__c, List<ERP7__Forecasting_Items__c>>();
            Map<Id,ERP7__Forecast_Plan__c> forecastPlanProductMap = new  Map<Id,ERP7__Forecast_Plan__c> ();
            for (ERP7__Forecast_Plan__c plan : forecastplans) {
                forecastItemsMap.put(plan, plan.ERP7__Forecast_Items__r);
                forecastPlanProductMap.put(plan.ERP7__Product__c,plan);
            }

            for (Product2 product : productList) {
                ForecastWrapper forecastWrapper = new ForecastWrapper();
                if(forecastPlanProductMap.containsKey(product.Id)){
                    ERP7__Forecast_Plan__c plan = forecastPlanProductMap.get(product.Id);

                    List<ERP7__Forecasting_Items__c> forecatsItems1 = forecastItemsMap.get(plan);

                    forecastWrapper = new ForecastWrapper(product.Id,product.Name, product.ProductCode, 0,new  Map<String,List<OrderDetailsWrap>>(),plan,forecatsItems1);
                    Map<String,ERP7__Forecasting_Items__c> KeyForecastMAp = new  Map<String,ERP7__Forecasting_Items__c>();
                    for(ERP7__Forecasting_Items__c item : forecatsItems1){
                        KeyForecastMAp.put(item.ERP7__Month_Quarter_Year__c,item);
                        IF(!forecastWrapper.monthQuantities.contains(item.ERP7__Month_Quarter_Year__c)) forecastWrapper.monthQuantities.add(item.ERP7__Month_Quarter_Year__c);
                    }
                }
                else{
                    ERP7__Forecast_Plan__c plan = new ERP7__Forecast_Plan__c(Name='Forecast for '+forecastTypeval+'-'+String.valueof(System.today()),ERP7__Forecast_Category__c = forecastTypeval,ERP7__Forecast_Type__c = forecastval,ERP7__Product__c = product.Id,ERP7__Start_Date__c = fromDate , ERP7__End_Date__c = toDate);

                    List<ERP7__Forecasting_Items__c> forecatsItems1 =new List<ERP7__Forecasting_Items__c>();
                    Map<String,ERP7__Forecasting_Items__c> KeyForecastMAp = new  Map<String,ERP7__Forecasting_Items__c>();
                    for(ERP7__Forecasting_Items__c item : forecatsItems1){
                        KeyForecastMAp.put(item.ERP7__Month_Quarter_Year__c,item);
                    }

                    if(forecastval == 'Month'){
                        Integer startYear = fromDate.year();
                        Integer startMonth = fromDate.month();
                        Integer endYear = toDate.year();
                        Integer endMonth = toDate.month();
                        for (Integer year = startYear; year <= endYear; year++) {
                            // Determine the start and end months for each year
                            Integer loopStartMonth = (year == startYear) ? startMonth : 1;
                            Integer loopEndMonth = (year == endYear) ? endMonth : 12;

                            // Generate keys for each month in the range
                            for (Integer month = loopStartMonth; month <= loopEndMonth; month++) {
                                String monthYearKey = String.valueOf(year) + '-' + String.valueOf(month);
                                ERP7__Forecasting_Items__c itemtoAdd =  new ERP7__Forecasting_Items__c();
                                itemtoAdd.ERP7__Month_Quarter_Year__c = monthYearKey;
                                itemtoAdd.Name = monthYearKey;
                                itemtoAdd.ERP7__Actual__c = 0;
                                itemtoAdd.ERP7__FPA__c = 0;
                                itemtoAdd.ERP7__Predicted__c = 0;
                                forecatsItems1.add(itemtoAdd);
                                // forecastWrapper.monthQuantities.put(monthYearKey, 0);
                            }
                        }
                    }
                    else if (forecastval == 'Quarter') {
                        Integer startYear = fromDate.year();
                        Integer startQuarter = (fromDate.month() - 1) / 3 + 1;
                        Integer endYear = toDate.year();
                        Integer endQuarter = (toDate.month() - 1) / 3 + 1;

                        // Loop through the range of years and quarters
                        for (Integer year = startYear; year <= endYear; year++) {
                            // Determine the start and end quarters for each year
                            Integer loopStartQuarter = (year == startYear) ? startQuarter : 1;
                            Integer loopEndQuarter = (year == endYear) ? endQuarter : 4;

                            // Generate keys for each quarter in the range
                            for (Integer quarter = loopStartQuarter; quarter <= loopEndQuarter; quarter++) {
                                String quarterYearKey = String.valueOf(year) + '-Q' + String.valueOf(quarter);
                                ERP7__Forecasting_Items__c itemtoAdd =  new ERP7__Forecasting_Items__c();
                                itemtoAdd.ERP7__Month_Quarter_Year__c = quarterYearKey;
                                itemtoAdd.Name = quarterYearKey;
                                itemtoAdd.ERP7__Actual__c = 0;
                                itemtoAdd.ERP7__FPA__c = 0;
                                itemtoAdd.ERP7__Predicted__c = 0;
                                forecatsItems1.add(itemtoAdd);
                                //forecastWrapper.monthQuantities.put(quarterYearKey, 0);
                            }
                        }
                    }
                    forecastWrapper = new ForecastWrapper(product.Id,product.Name, product.ProductCode, 0,new  Map<String,List<OrderDetailsWrap>>(),plan,forecatsItems1);
                    // Map<String,ERP7__Forecasting_Items__c> KeyForecastMAp = new  Map<String,ERP7__Forecasting_Items__c>();
                    for(ERP7__Forecasting_Items__c item : forecatsItems1){
                        KeyForecastMAp.put(item.ERP7__Month_Quarter_Year__c,item);
                        IF(!forecastWrapper.monthQuantities.contains(item.ERP7__Month_Quarter_Year__c)) forecastWrapper.monthQuantities.add(item.ERP7__Month_Quarter_Year__c);
                    }

                }
                productIdToWrapperMap.put(product.Id, forecastWrapper);
            }




            Map<String, Decimal> aggregatedQuantityMap = new Map<String, Decimal>();
            if(forecastTypeval == 'Sales'){

                List<OrderItem> ordItemList = [
                    SELECT Id, OrderId,Order.Name, Quantity, Order.CreatedDate,Product2Id,Product2.Name,Order.Account.Name,Order.AccountId
                    FROM OrderItem
                    WHERE Product2Id != null
                    AND Product2Id IN :productIdToWrapperMap.keyset()
                    AND OrderId != null
                    AND Order.CreatedDate <= :toDate
                    AND Order.CreatedDate >= :fromDate
                    Order by CreatedDate ASC
                ];
                if(forecastval == 'Month'){
                    for (OrderItem ordItem : ordItemList) {
                        String monthYearKey = ordItem.Order.CreatedDate.year() + '-' + ordItem.Order.CreatedDate.month();
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(ordItem.Product2Id);
                        for(ERP7__Forecasting_Items__c fr : forecastWrapper.forecastItems){
                            if(fr.ERP7__Month_Quarter_Year__c == monthYearKey){

                                fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + ordItem.Quantity) : ordItem.Quantity;
                            }
                        }
                        /* if (!forecastWrapper.monthQuantities.containsKey(monthYearKey)) {
forecastWrapper.monthQuantities.put(monthYearKey, 0);
}
forecastWrapper.monthQuantities.put(monthYearKey, forecastWrapper.monthQuantities.get(monthYearKey) + ordItem.Quantity);
forecastWrapper.quantity += ordItem.Quantity;*/
                        if(!forecastWrapper.orderWarp.containsKey(monthYearKey))      forecastWrapper.orderWarp.put(monthYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(ordItem.Order.Name, ordItem.Order.Account.Name, ordItem.Quantity,ordItem.OrderId) });
                        else {    forecastWrapper.orderWarp.get(monthYearKey).add(new OrderDetailsWrap(ordItem.Order.Name,ordItem.Order.Account.Name,ordItem.Quantity,ordItem.OrderId));
                             }
                        productIdToWrapperMap.put(ordItem.Product2Id, forecastWrapper);
                        system.debug('productIdToWrapperMap : '+forecastWrapper);
                    }
                }
                else if(forecastval == 'Quarter'){
                    for (OrderItem ordItem : ordItemList) {
                        Integer quarter = (ordItem.Order.CreatedDate.month() - 1) / 3 + 1;
                        String quarterYearKey = ordItem.Order.CreatedDate.year() + '-Q' + quarter;
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(ordItem.Product2Id);
                        for(ERP7__Forecasting_Items__c fr : forecastWrapper.forecastItems){
                            if(fr.ERP7__Month_Quarter_Year__c == quarterYearKey){
                                fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + ordItem.Quantity) : ordItem.Quantity;
                            }
                        }
                        /*if (!forecastWrapper.monthQuantities.containsKey(quarterYearKey)) {
forecastWrapper.monthQuantities.put(quarterYearKey, 0);
}
forecastWrapper.monthQuantities.put(quarterYearKey, forecastWrapper.monthQuantities.get(quarterYearKey) + ordItem.Quantity);
forecastWrapper.quantity += ordItem.Quantity;*/
                        if(!forecastWrapper.orderWarp.containsKey(quarterYearKey))      forecastWrapper.orderWarp.put(quarterYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(ordItem.Order.Name, ordItem.Order.Account.Name, ordItem.Quantity,ordItem.OrderId) });
                        else {
                            forecastWrapper.orderWarp.get(quarterYearKey).add(new OrderDetailsWrap(ordItem.Order.Name,ordItem.Order.Account.Name,ordItem.Quantity,ordItem.OrderId));
                        }
                        productIdToWrapperMap.put(ordItem.Product2Id, forecastWrapper);
                    }

                }

            }
            else if(forecastTypeval == 'Production/Supply'){
                List<ERP7__Manufacturing_Order__c> moRaised = [SELECT Id, Name, ERP7__Quantity__c, CreatedDate, ERP7__Product__c FROM ERP7__Manufacturing_Order__c WHERE ERP7__Product__c IN :productIdToWrapperMap.keySet() AND CreatedDate <= :toDate AND CreatedDate >= :fromDate Order by CreatedDate ASC];
                List<ERP7__Purchase_Line_Items__c> poRaised = [SELECT Id, Name, ERP7__Quantity__c, CreatedDate, ERP7__Product__c,ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.Name,ERP7__Purchase_Orders__r.Vendor__c,ERP7__Purchase_Orders__r.Vendor__r.Name FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Product__c IN :productIdToWrapperMap.keySet() AND CreatedDate <= :toDate AND CreatedDate >= :fromDate Order by CreatedDate ASC];
                if(forecastval == 'Month'){
                    for (ERP7__Manufacturing_Order__c mos : moRaised) {
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(mos.ERP7__Product__c);
                        if (forecastWrapper != null) {
                            String monthYearKey = mos.CreatedDate.year() + '-' + mos.CreatedDate.month();
                            for(ERP7__Forecasting_Items__c fr : forecastWrapper.forecastItems){
                                if(fr.ERP7__Month_Quarter_Year__c == monthYearKey){
                                    fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + mos.ERP7__Quantity__c) : mos.ERP7__Quantity__c;
                                }
                            }
                            /* if (!forecastWrapper.monthQuantities.containsKey(monthYearKey)) {   forecastWrapper.monthQuantities.put(monthYearKey, 0);
}

forecastWrapper.monthQuantities.put(monthYearKey, forecastWrapper.monthQuantities.get(monthYearKey) + mos.ERP7__Quantity__c);
forecastWrapper.quantity += mos.ERP7__Quantity__c;*/
                            if(!forecastWrapper.orderWarp.containsKey(monthYearKey))      forecastWrapper.orderWarp.put(monthYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id)});
                            else {    forecastWrapper.orderWarp.get(monthYearKey).add(new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id));
                                 }
                            productIdToWrapperMap.put(mos.ERP7__Product__c, forecastWrapper);
                        }
                    }

                    for (ERP7__Purchase_Line_Items__c pos : poRaised) {
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(pos.ERP7__Product__c);
                        if (forecastWrapper != null) {
                            String monthYearKey = pos.CreatedDate.year() + '-' + pos.CreatedDate.month();
                            for(ERP7__Forecasting_Items__c fr : forecastWrapper.forecastItems){
                                if(fr.ERP7__Month_Quarter_Year__c == monthYearKey){
                                    fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + pos.ERP7__Quantity__c) : pos.ERP7__Quantity__c;
                                }
                            }

                            /* if (!forecastWrapper.monthQuantities.containsKey(monthYearKey)) {
forecastWrapper.monthQuantities.put(monthYearKey, 0);
}

forecastWrapper.monthQuantities.put(monthYearKey, forecastWrapper.monthQuantities.get(monthYearKey) + pos.ERP7__Quantity__c);
forecastWrapper.quantity += pos.ERP7__Quantity__c;*/
                            if(!forecastWrapper.orderWarp.containsKey(monthYearKey))      forecastWrapper.orderWarp.put(monthYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.Id)});
                            else {
                                forecastWrapper.orderWarp.get(monthYearKey).add(new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.Id));
                            }
                            productIdToWrapperMap.put(pos.ERP7__Product__c, forecastWrapper);
                        }
                    }
                }
                else if(forecastval == 'Quarter'){
                    for (ERP7__Manufacturing_Order__c mos : moRaised) {
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(mos.ERP7__Product__c);
                        if (forecastWrapper != null) {
                            Integer quarter = (mos.CreatedDate.month() - 1) / 3 + 1;
                            String quarterYearKey = mos.CreatedDate.year() + '-Q' + quarter;
                            for(ERP7__Forecasting_Items__c fr : forecastWrapper.forecastItems){
                                if(fr.ERP7__Month_Quarter_Year__c == quarterYearKey){
                                    fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + mos.ERP7__Quantity__c) : mos.ERP7__Quantity__c;
                                }
                            }

                            /* if (!forecastWrapper.monthQuantities.containsKey(quarterYearKey)) {
forecastWrapper.monthQuantities.put(quarterYearKey, 0);
}
forecastWrapper.monthQuantities.put(quarterYearKey, forecastWrapper.monthQuantities.get(quarterYearKey) + mos.ERP7__Quantity__c);
forecastWrapper.quantity += mos.ERP7__Quantity__c;*/
                            if(!forecastWrapper.orderWarp.containsKey(quarterYearKey))      forecastWrapper.orderWarp.put(quarterYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id)});
                            else {
                                forecastWrapper.orderWarp.get(quarterYearKey).add(new OrderDetailsWrap(mos.Name,'',mos.Quantity__c,mos.Id));
                            }
                            productIdToWrapperMap.put(mos.ERP7__Product__c,forecastWrapper);
                        }
                    }
                    for (ERP7__Purchase_Line_Items__c pos : poRaised) {
                        ForecastWrapper forecastWrapper = productIdToWrapperMap.get(pos.ERP7__Product__c);
                        if (forecastWrapper != null) {
                            Integer quarter = (pos.CreatedDate.month() - 1) / 3 + 1;
                            String quarterYearKey = pos.CreatedDate.year() + '-Q' + quarter;
                            for(ERP7__Forecasting_Items__c fr : forecastWrapper.forecastItems){
                                if(fr.ERP7__Month_Quarter_Year__c == quarterYearKey){
                                    fr.ERP7__Actual__c = (fr.ERP7__Actual__c > 0) ? (fr.ERP7__Actual__c + pos.ERP7__Quantity__c) : pos.ERP7__Quantity__c;
                                }
                            }

                            /* if (!forecastWrapper.monthQuantities.containsKey(quarterYearKey)) {
forecastWrapper.monthQuantities.put(quarterYearKey, 0);
}
forecastWrapper.monthQuantities.put(quarterYearKey, forecastWrapper.monthQuantities.get(quarterYearKey) + pos.ERP7__Quantity__c);
forecastWrapper.quantity += pos.ERP7__Quantity__c;*/
                            if(!forecastWrapper.orderWarp.containsKey(quarterYearKey))      forecastWrapper.orderWarp.put(quarterYearKey, new List<OrderDetailsWrap>{ new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.Id)});
                            else {
                                forecastWrapper.orderWarp.get(quarterYearKey).add(new OrderDetailsWrap(pos.ERP7__Purchase_Orders__r.Name,pos.ERP7__Purchase_Orders__r.Vendor__r.Name,pos.Quantity__c,pos.Id));
                            }
                            productIdToWrapperMap.put(pos.ERP7__Product__c,forecastWrapper);
                        }
                    }
                }

            }
            for (ForecastWrapper wrapper : productIdToWrapperMap.values()) {
                system.debug('wrapper : '+wrapper);
                decimal sizeMonth = wrapper.monthQuantities.size();
                system.debug('sizeMonth : '+sizeMonth);
                Decimal predictiveAverageSales = 0;
                decimal totalQty = 0;
                /*for(Decimal qty : wrapper.monthQuantities.values()){
totalQty += qty;
}*/
                system.debug('totalQty : '+totalQty);
                predictiveAverageSales = (totalQty > 0) ? Math.round(totalQty/sizeMonth) : 0;
                //wrapper.monthQuantities.put('Predicted Average',predictiveAverageSales);
                forecastList.add(wrapper);
            }
            if(forecastList.size() > 0) {
                wrapnew.ForecastWrap =forecastList;
                return wrapnew;
            }
            else return null;
        }
        return null;
    }
    @AuraEnabled
    public static string saveForecasts(String ForecastWraplist,String MRPId,String MRPItems){
        if(ForecastWraplist != null && ForecastWraplist != ''){
            List<ForecastWrapper> wrap = (List<ForecastWrapper>) JSON.deserialize(ForecastWraplist,List<ForecastWrapper>.class);
            List<ERP7__MPS_line_Item__c> mpsLineItems2Upsert = new List<ERP7__MPS_line_Item__c>();
            if(MRPItems != null && MRPItems != ''){
                List<ERP7__MPS__c> mpsItem = (List<ERP7__MPS__c>) JSON.deserialize(MRPItems,List<ERP7__MPS__c>.class);
                if(mpsItem.size() > 0) upsert mpsItem;
            }
            if(wrap.size() > 0){
                 for(ForecastWrapper fr : wrap){
                     mpsLineItems2Upsert.addAll(fr.MPSlineitems);
                }
                if(mpsLineItems2Upsert.size() > 0){
                    upsert mpsLineItems2Upsert;
                    return 'Success';
                }
            }

        }
           /* List<ERP7__Forecast_Plan__c> forecastplan2upsert = new List<ERP7__Forecast_Plan__c>();
            List<ERP7__Forecasting_Items__c> forecastingItemsList = new List<ERP7__Forecasting_Items__c>();
            Map<ERP7__Forecast_Plan__c,List<ERP7__Forecasting_Items__c>> forcastPlanAndItems = new Map<ERP7__Forecast_Plan__c,List<ERP7__Forecasting_Items__c>>();
            if(wrap.size() > 0){
                for(ForecastWrapper fr : wrap){
                    fr.forecastPlan.ERP7__Planned_Date__c = system.today();
                    forcastPlanAndItems.put(fr.forecastPlan,fr.forecastItems);
                }
                if(forcastPlanAndItems.size() > 0){
                    forecastplan2upsert.addAll(forcastPlanAndItems.keySet());
                    upsert forecastplan2upsert;
                    Integer j=0;
                    for(List<ERP7__Forecasting_Items__c> fritems : forcastPlanAndItems.values()){
                        for(ERP7__Forecasting_Items__c items : fritems){
                            items.ERP7__Forecast_Plan__c = forecastplan2upsert[j].Id;
                        }
                        forecastingItemsList.addAll(fritems);
                        j++;

                    }
                    upsert forecastingItemsList;
                    return 'Data updated successfully!';
                }

            }
        }*/
        return null;
    }

    @AuraEnabled
    public static List<String> saveMRPS(String MRP,String MRPItemList){
        List<String> results = new List<String>();
        if(MRP != null && MRP != ''){
            ERP7__Material_Requirement_Planning__c mrp2upsert = (ERP7__Material_Requirement_Planning__c) JSON.deserialize(MRP,ERP7__Material_Requirement_Planning__c.class);

            List<ERP7__MPS__c> MRPItems = (List<ERP7__MPS__c>) JSON.deserialize(MRPItemList,List<ERP7__MPS__c>.class);
            if(MRPItems.size() > 0){
                upsert mrp2upsert;
                system.debug('mrp2upsert : '+mrp2upsert);
               String ForecastRecordId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__MPS__c','Forecast');
               Set<Id> existingProductIds = new Set<Id>();
                for(ERP7__MPS__c existing : [
                    SELECT Id, ERP7__Product__c 
                    FROM ERP7__MPS__c 
                    WHERE ERP7__Master_MRP__c = :mrp2upsert.Id
                    AND RecordTypeId = :ForecastRecordId
                ]) {
                    existingProductIds.add(existing.ERP7__Product__c);
                }
                
                // Prepare items for upsert
                List<ERP7__MPS__c> itemsToUpsert = new List<ERP7__MPS__c>();
                for(ERP7__MPS__c mps : MRPItems) {
                    if(!existingProductIds.contains(mps.ERP7__Product__c)) {
                        mps.ERP7__Master_MRP__c = mrp2upsert.Id;
                        mps.ERP7__Algorithm__c = mrp2upsert.ERP7__Algorithm__c;
                        mps.RecordTypeId = ForecastRecordId;
                        itemsToUpsert.add(mps);
                    }
                } 
                                upsert MRPItems;

                
                // Upsert only if there are items to process
                if(!itemsToUpsert.isEmpty()) {
                    upsert itemsToUpsert;
                }
                results.add(JSON.serialize(mrp2upsert));
                results.add(JSON.serialize(MRPItems));
                return results;
            }
        }
      return null;
    }

    @AuraEnabled
    public static List<String> getMRPDetails(String MRPId){
        List<String> MRPdetails = new List<String>();
        if(MRPId != null && MRPId != ''){
            ERP7__Material_Requirement_Planning__c MRP = new ERP7__Material_Requirement_Planning__c();
            MRP = [Select Id,Name,ERP7__Algorithm__c,ERP7__From_Date__c,ERP7__To_Date__c,ERP7__Site__c,ERP7__Site__r.Id,ERP7__Site__r.Name from ERP7__Material_Requirement_Planning__c where Id =:MRPId limit 1];
            List<ERP7__MPS__c> MRPItemsList = new List<ERP7__MPS__c>();
            MRPItemsList = [Select Id,Name,ERP7__Product__c,ERP7__Schedule_Period__c,ERP7__Forecast_Type__c,ERP7__Starting_Inventory__c,ERP7__Product__r.Id,ERP7__Product__r.ProductCode,ERP7__Demand_MO__c,ERP7__Demand_Sales__c,ERP7__Reserved_SO__c,ERP7__Awaiting_Qty__c,ERP7__Issued_WIP__c,ERP7__Product__r.Name,ERP7__Reordering_Rule__c,ERP7__Reordering_Rule__r.Id,ERP7__Reordering_Rule__r.Name from ERP7__MPS__c where ERP7__Master_MRP__c = :MRPId];
            set<Id> productIDs = new set<Id>();
            for(ERP7__MPS__c MPS : MRPItemsList){
                productIDs.add(MPS.ERP7__Product__c);
            }
            List<ERP7__Reordering_Rule__c> rrlists = [Select Id,Name,ERP7__Active__c,ERP7__Lead_Time__c,ERP7__Maximum_Quantity__c,ERP7__Minimum_Quantity__c,ERP7__MinimumOrderingQuantity__c,ERP7__Routing__c,ERP7__Routing__r.Name,ERP7__Vendor_Account__c,ERP7__Vendor_Account__r.Name,ERP7__Product__c,ERP7__Product__r.Id,ERP7__Product__r.Name from ERP7__Reordering_Rule__c where ERP7__Product__c IN : productIDs];
            MRPdetails.add(JSON.serialize(MRP));

            Map<Id,List<ERP7__Reordering_Rule__c>> productReorderMap = new Map<Id,List<ERP7__Reordering_Rule__c>>();
            for(ERP7__Reordering_Rule__c rr : rrlists){
                if(productReorderMap.containsKey(rr.ERP7__Product__c)){
                    productReorderMap.get(rr.ERP7__Product__c).add(rr);
                }
                else productReorderMap.put(rr.ERP7__Product__c, new List<ERP7__Reordering_Rule__c>{rr});
            }
            List<wrapper> wraplist = new List<wrapper>();
            Integer index = 1;
            for(ERP7__MPS__c MPS : MRPItemsList){
                wrapper wrp = new wrapper();
                wrp.index = index;
                wrp.prod = new Product2(Id = MPS.ERP7__Product__c,Name = MPS.ERP7__Product__r.Name,ProductCode = MPS.ERP7__Product__r.ProductCode);
                wrp.reOrderId = MPS.ERP7__Reordering_Rule__c;
                wrp.reorderqry = 'ERP7__Product__c = \'' + MPS.ERP7__Product__c + '\'';
                wrp.onHand  = MPS.ERP7__Starting_Inventory__c;
                wrp.reservedMO = MPS.ERP7__Issued_WIP__c;
                wrp.reservedSO = MPS.ERP7__Reserved_SO__c;
                wrp.orderedQty = MPS.ERP7__Awaiting_Qty__c;
                wrp.demandSales = MPS.ERP7__Demand_Sales__c;
                wrp.demandMO = MPS.ERP7__Demand_MO__c;
                wrp.reorderlist = (productReorderMap.containsKey(MPS.ERP7__Product__c) ? productReorderMap.get(MPS.ERP7__Product__c) : new List<ERP7__Reordering_Rule__c>());
                wrp.MPSId = MPS.Id;
                wraplist.add(wrp);
                index++;
            }
             MRPdetails.add(JSON.serialize(wraplist));
        }
        if(MRPdetails.size() > 0) return MRPdetails;
        else return null;
    }
    @AuraEnabled
    public static ERP7__Reordering_Rule__c updateReorder(String recId,Boolean active){
        if(recId != null && recId != ''){
            ERP7__Reordering_Rule__c rr = new ERP7__Reordering_Rule__c(Id = recId,ERP7__Active__c = active);
            update rr;
            return rr;
        }
        else return null;

    }
    @AuraEnabled
    public static string deleteMPsRecord(string MPSId){
        if(MPSId != null && MPSId != ''){
            ERP7__MPS__c mps = new ERP7__MPS__c(Id=MPSId);
            delete mps;
            return 'success';
        }
        else return null;

    }

    @AuraEnabled
    public static List<OrderDetailsWrap> getOrderDetailsBasedOnStatus(String recId,String statusVal,date toDate,date fromDate){
        List<OrderDetailsWrap> ordDetails = new List<OrderDetailsWrap>();
        Map<Id,OrderDetailsWrap> ordIdQuantityMap = new Map<Id,OrderDetailsWrap>();
        if(recId != null && recId != ''){
            if(fromDate == null){
                fromDate = Date.newInstance(System.today().year(), 1, 1);
            }
            system.debug('fromDate : '+fromDate);
            if(toDate == null){
                toDate = system.today() + 1;
            }
            else {
                toDate = toDate + 1;
            }
            if(statusVal == 'Reserved SO'){
                List<ERP7__Stock_Outward_Line_Item__c> solist = [Select Id,Name,ERP7__Quantity__c,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Order__r.AccountId,ERP7__Order__r.Account.Name,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name,ERP7__Sales_Order__r.ERP7__Account__c,ERP7__Sales_Order__r.ERP7__Account__r.Name from ERP7__Stock_Outward_Line_Item__c where ERP7__Status__c = 'Reserved' and ERP7__Quantity__c > 0 and (ERP7__Order__c != null or ERP7__Sales_Order__c != null) and ERP7__Product__c =:recId
                                                                and CreatedDate <= :toDate
                                                  AND CreatedDate >= :fromDate];
                set<Id> ordIds = new set<Id>();
                for(ERP7__Stock_Outward_Line_Item__c so : solist){
                 OrderDetailsWrap newOrd = new OrderDetailsWrap();
                    if(so.ERP7__Order__c != null){
                        newOrd.OrderId = so.ERP7__Order__c;
                        newOrd.OrderNumber = so.ERP7__Order__r.Name;
                        newOrd.customer_Vendor = so.ERP7__Order__r.Account.Name;
                        if(ordIdQuantityMap.containskey(so.ERP7__Order__c)) newOrd.Quantity = ordIdQuantityMap.get(so.ERP7__Order__c).Quantity + so.ERP7__Quantity__c;
                        else{
                            newOrd.Quantity = so.ERP7__Quantity__c;

                        }
                        ordIdQuantityMap.put(so.ERP7__Order__c,newOrd);
                    }
                    else if(so.ERP7__Sales_Order__c != null){
                        newOrd.OrderId = so.ERP7__Sales_Order__c;
                        newOrd.OrderNumber = so.ERP7__Sales_Order__r.Name;
                        newOrd.customer_Vendor = so.ERP7__Sales_Order__r.Account__r.Name;
                        if(ordIdQuantityMap.containskey(so.ERP7__Sales_Order__c)) {
                            newOrd.Quantity = ordIdQuantityMap.get(so.ERP7__Sales_Order__c).Quantity + so.ERP7__Quantity__c;
                        }
                        else{
                            newOrd.Quantity = so.ERP7__Quantity__c;
                        }
                        ordIdQuantityMap.put(so.ERP7__Sales_Order__c,newOrd);
                    }
                }
                //ordDetails.addALL(ordIdQuantityMap.Values());
            }
            else if(statusVal == 'Reserved MO'){
                 List<ERP7__Stock_Outward_Line_Item__c> solist = [Select Id,Name,ERP7__Quantity__c,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Name,ERP7__Order__r.AccountId,ERP7__Order__r.Account.Name,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name,ERP7__Sales_Order__r.ERP7__Account__c,ERP7__Sales_Order__r.ERP7__Account__r.Name from ERP7__Stock_Outward_Line_Item__c where ERP7__Status__c = 'Reserved' and ERP7__Quantity__c > 0 and ERP7__Manufacturing_Order__c != null and ERP7__Product__c =:recId
                                                                and CreatedDate <= :toDate
                                                  AND CreatedDate >= :fromDate];
                set<Id> ordIds = new set<Id>();

                for(ERP7__Stock_Outward_Line_Item__c so : solist){
                 OrderDetailsWrap newOrd = new OrderDetailsWrap();
                    if(so.ERP7__Manufacturing_Order__c != null){
                        newOrd.OrderId = so.ERP7__Manufacturing_Order__c;
                        newOrd.OrderNumber = so.ERP7__Manufacturing_Order__r.Name;
                        newOrd.customer_Vendor = '-';
                        if(ordIdQuantityMap.containskey(so.ERP7__Manufacturing_Order__c)) newOrd.Quantity = ordIdQuantityMap.get(so.ERP7__Manufacturing_Order__c).Quantity + so.ERP7__Quantity__c;
                        else{
                            newOrd.Quantity = so.ERP7__Quantity__c;

                        }
                        ordIdQuantityMap.put(so.ERP7__Manufacturing_Order__c,newOrd);
                    }

                }

            }
            else if(statusVal == 'QC Hold'){
                List<ERP7__Stock_Inward_Line_Item__c> sinwards = [Select Id,Name,ERP7__Product__c,ERP7__Quantity__c,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Name,ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.Name,ERP7__Purchase_Orders__r.ERP7__Vendor__c,ERP7__Purchase_Orders__r.ERP7__Vendor__r.Name from ERP7__Stock_Inward_Line_Item__c where (ERP7__Status__c = 'QC hold' or ERP7__Status__c = 'Quality Check(QA)') and ERP7__Quantity__c > 0 and (ERP7__Manufacturing_Order__c != null or ERP7__Purchase_Orders__c != null) and
                                                                  CreatedDate <= :toDate
                                                  AND CreatedDate >= :fromDate and ERP7__Product__c = :recId];
                for(ERP7__Stock_Inward_Line_Item__c so : sinwards){
                     OrderDetailsWrap newOrd = new OrderDetailsWrap();
                    if(so.ERP7__Manufacturing_Order__c != null){
                        newOrd.OrderId = so.ERP7__Manufacturing_Order__c;
                        newOrd.OrderNumber = so.ERP7__Manufacturing_Order__r.Name;
                        newOrd.customer_Vendor = '-';
                        if(ordIdQuantityMap.containskey(so.ERP7__Manufacturing_Order__c)) newOrd.Quantity = ordIdQuantityMap.get(so.ERP7__Manufacturing_Order__c).Quantity + so.ERP7__Quantity__c;
                        else{
                            newOrd.Quantity = so.ERP7__Quantity__c;

                        }
                        ordIdQuantityMap.put(so.ERP7__Manufacturing_Order__c,newOrd);
                    }
                    else if(so.ERP7__Purchase_Orders__c != null){
                        newOrd.OrderId = so.ERP7__Purchase_Orders__c;
                        newOrd.OrderNumber = so.ERP7__Purchase_Orders__r.Name;
                        newOrd.customer_Vendor = so.ERP7__Purchase_Orders__r.ERP7__Vendor__r.Name;
                        if(ordIdQuantityMap.containskey(so.ERP7__Purchase_Orders__c)) newOrd.Quantity = ordIdQuantityMap.get(so.ERP7__Purchase_Orders__c).Quantity + so.ERP7__Quantity__c;
                        else{
                            newOrd.Quantity = so.ERP7__Quantity__c;

                        }
                        ordIdQuantityMap.put(so.ERP7__Purchase_Orders__c,newOrd);
                    }
                }
            }
            else if(statusVal == 'Demand SO'){
                List<OrderItem> ordlist = [Select Id,ERP7__Required_Stock__c,OrderId,Order.Name,Order.accountId,Order.Account.Name from OrderItem where Product2Id =: recId and  ERP7__Required_Stock__c > 0 and Product2Id != null AND  CreatedDate <= :toDate
                                              AND CreatedDate >= :fromDate and order.ERP7__Is_closed__c = false];
                for(OrderItem so : ordlist){
                    OrderDetailsWrap newOrd = new OrderDetailsWrap();
                    newOrd.OrderId = so.OrderId;
                    newOrd.OrderNumber = so.Order.Name;
                    newOrd.customer_Vendor = so.Order.Account.Name;
                    if(ordIdQuantityMap.containskey(so.OrderId)) newOrd.Quantity = ordIdQuantityMap.get(so.OrderId).Quantity + so.ERP7__Required_Stock__c;
                    else{
                        newOrd.Quantity = so.ERP7__Required_Stock__c;

                    }
                    ordIdQuantityMap.put(so.OrderId,newOrd);

                }
            }
            else if(statusVal == 'Demand MO'){
                List<ERP7__MRP__c> ordlist = [Select Id,ERP7__Remaining_Quantity_to_Allocate__c,ERP7__MO__c,ERP7__MO__r.Name,ERP7__MO__r.Order__r.accountId,ERP7__MO__r.Order__r.Account.Name from ERP7__MRP__c where ERP7__MO__c != null and ERP7__MRP_Product__c =: recId and ERP7__Remaining_Quantity_to_Allocate__c > 0 and ERP7__MRP_Product__c != null AND  CreatedDate <= :toDate
                                              AND CreatedDate >= :fromDate and ERP7__MO__r.ERP7__Status__c != 'Complete' and ERP7__MO__r.ERP7__Status__c != 'Cancelled'];
                for(ERP7__MRP__c so : ordlist){
                    OrderDetailsWrap newOrd = new OrderDetailsWrap();
                    newOrd.OrderId = so.ERP7__MO__c;
                    newOrd.OrderNumber = so.ERP7__MO__r.Name;
                    newOrd.customer_Vendor = '-';
                    if(ordIdQuantityMap.containskey(so.ERP7__MO__c)) newOrd.Quantity = ordIdQuantityMap.get(so.ERP7__MO__c).Quantity + so.ERP7__Remaining_Quantity_to_Allocate__c;
                    else{
                        newOrd.Quantity = so.ERP7__Remaining_Quantity_to_Allocate__c;

                    }
                    ordIdQuantityMap.put(so.ERP7__MO__c,newOrd);

                }
            }
            else if(statusVal == 'IC Transfer'){
                List<ERP7__Stock_Outward_Line_Item__c> solist = [Select Id,Name,ERP7__IC_Transfer_Qty__c,ERP7__Transfer_Order__c,ERP7__Transfer_Order__r.Name,ERP7__Transfer_Order__r.ERP7__Customer__c,ERP7__Transfer_Order__r.ERP7__Customer__r.Name,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name,ERP7__Sales_Order__r.ERP7__Account__c,ERP7__Sales_Order__r.ERP7__Account__r.Name from ERP7__Stock_Outward_Line_Item__c where  ERP7__IC_Transfer_Qty__c > 0 and ERP7__Transfer_Order__c != null and ERP7__Product__c =:recId
                                                                 and CreatedDate <= :toDate
                                                                 AND CreatedDate >= :fromDate and ERP7__Status__c = 'Reserved'];
                set<Id> ordIds = new set<Id>();
                for(ERP7__Stock_Outward_Line_Item__c so : solist){
                    OrderDetailsWrap newOrd = new OrderDetailsWrap();
                    if(so.ERP7__Transfer_Order__c != null){
                        newOrd.OrderId = so.ERP7__Transfer_Order__c;
                        newOrd.OrderNumber = so.ERP7__Transfer_Order__r.Name;
                        newOrd.customer_Vendor = so.ERP7__Transfer_Order__r.ERP7__Customer__r.Name;
                        if(ordIdQuantityMap.containskey(so.ERP7__Transfer_Order__c)) newOrd.Quantity = ordIdQuantityMap.get(so.ERP7__Transfer_Order__c).Quantity + so.ERP7__IC_Transfer_Qty__c;
                        else{
                            newOrd.Quantity = so.ERP7__IC_Transfer_Qty__c;

                        }
                        ordIdQuantityMap.put(so.ERP7__Transfer_Order__c,newOrd);
                    }
                }
            }
            else if(statusVal == 'Open POs'){
                String returnrecordId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__PO__c','Standard_Purchase_Order');
                List<ERP7__Purchase_Line_Items__c> prlis = [Select Id,Name,ERP7__Purchase_Orders__r.Name,ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.Vendor__c, ERP7__Purchase_Orders__r.Vendor__r.Name,ERP7__Remaining_Quantity__c
                                                            from ERP7__Purchase_Line_Items__c where ERP7__Product__c != null and ERP7__Product__c = :recId and ERP7__Remaining_Quantity__c > 0 AND ERP7__Purchase_Orders__c != null   AND ERP7__Purchase_Orders__r.RecordTypeId = :returnrecordId and
                                                            (ERP7__Purchase_Orders__r.ERP7__Status__c != 'Cancelled' AND ERP7__Purchase_Orders__r.ERP7__Status__c != 'Closed') And ERP7__Purchase_Orders__r.ERP7__Is_Closed__c = false
                                                            AND CreatedDate >= :fromDate AND CreatedDate <= :toDate];
                for(ERP7__Purchase_Line_Items__c so : prlis){
                    OrderDetailsWrap newOrd = new OrderDetailsWrap();
                    if(so.ERP7__Purchase_Orders__c != null){
                        newOrd.OrderId = so.ERP7__Purchase_Orders__c;
                        newOrd.OrderNumber = so.ERP7__Purchase_Orders__r.Name;
                        newOrd.customer_Vendor = so.ERP7__Purchase_Orders__r.ERP7__Vendor__r.Name;
                        if(ordIdQuantityMap.containskey(so.ERP7__Purchase_Orders__c)) newOrd.Quantity = ordIdQuantityMap.get(so.ERP7__Purchase_Orders__c).Quantity + so.ERP7__Remaining_Quantity__c;
                        else{
                            newOrd.Quantity = so.ERP7__Remaining_Quantity__c;

                        }
                        ordIdQuantityMap.put(so.ERP7__Purchase_Orders__c,newOrd);
                    }
                }

            }
            else if(statusVal == 'Open MOs'){
                   List<ERP7__Manufacturing_Order__c> prlis = [Select Id,Name,ERP7__Remaining_Quantity__c,ERP7__Product__c
                                                            from ERP7__Manufacturing_Order__c where ERP7__Product__c != null and ERP7__Product__c = :recId and ERP7__Remaining_Quantity__c > 0 AND ERP7__Status__c != 'Cancelled'   AND ERP7__Status__c != 'Complete'
                                                           AND CreatedDate >= :fromDate AND CreatedDate <= :toDate];
                 for(ERP7__Manufacturing_Order__c so : prlis){
                     OrderDetailsWrap newOrd = new OrderDetailsWrap();
                     newOrd.OrderId = so.Id;
                     newOrd.OrderNumber = so.Name;
                     newOrd.customer_Vendor = '-';
                     if(ordIdQuantityMap.containskey(so.Id)) newOrd.Quantity = ordIdQuantityMap.get(so.Id).Quantity + so.ERP7__Remaining_Quantity__c;
                     else{
                         newOrd.Quantity = so.ERP7__Remaining_Quantity__c;

                     }
                     ordIdQuantityMap.put(so.Id,newOrd);
                }

            }
            if(ordIdQuantityMap.Values().size() > 0) ordDetails.addALL(ordIdQuantityMap.Values());
        }
        return  ordDetails;
    }
  @AuraEnabled
    public static  MainWrap getInvnetorydatawithFilter(string filterval,string searchkey,string family,string subFamily,string selectedSite, date fromDate,date toDate,integer pageSize,integer pageNumber){
        MainWrap wrapnew = new MainWrap();
        if(fromDate == null){
            fromDate = Date.newInstance(System.today().year(), 1, 1);
        }
        system.debug('fromDate : '+fromDate);
        if(toDate == null){
            toDate = system.today();
        }
        string srch = '%' + searchkey + '%';
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        set<Id> prodIDs = new set<Id>();
        if(selectedSite == null || selectedSite == ''){
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            if(empList.size()>0 && empList != null){
                wrapnew.ChannelId = empList[0].ERP7__Channel__c;
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.ERP7__Address__c,ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                if(dcList.size()>0 && dcList != null) selectedSite = dcList[0].ERP7__Site__c;
            }
        }
        String customQuery = System.Label.CustomQueryforMRP;
     /*   if(filterval == 'high_demand_sales'){
            String baseQuery = 'SELECT Product2Id, SUM(ERP7__Required_Stock__c) totalQuantity, COUNT_DISTINCT(OrderId) orderCount ';
            baseQuery += 'FROM OrderItem WHERE Product2Id != null AND ERP7__Logistic_Quantity__c >= 0 ';
            baseQuery += 'AND ERP7__Required_Stock__c > 0 AND Order.ERP7__Is_Closed__c = false ';
            baseQuery += 'AND CreatedDate <= :toDate AND CreatedDate >= :fromDate AND Product2Id.IsActive = true';
            if (srch != null && srch != '') {
                baseQuery += 'AND (Name LIKE :srch OR ProductCode LIKE :srch) ';
            }
            if (family != null && family != '' && family != '--None--') {
                baseQuery += 'AND Family = :family ';
            }
            if (subfamily != null && subfamily != '' && subfamily != '--None--') {
                baseQuery += 'AND ERP7__Product_Service_Family__c = :subfamily ';
            }
            if (customQuery != 'None') {
                baseQuery += customQuery;
            }
            baseQuery += 'GROUP BY Product2Id ORDER BY SUM(ERP7__Required_Stock__c) DESC';
            List<AggregateResult> demandSo = Database.query(baseQuery);
            Map<Id,AggregateResult> demandSoProds = new Map<Id,AggregateResult>();
            for(AggregateResult result : demandSo){
                Id productId = (Id)result.get('Product2Id');
                prodIDs.add(productId);
                demandSoProds.put(productId, result);
                system.debug('result : '+result);
            }
            if(prodIDs.size() > 0){

                Integer totalRecords =prodIDs.size();
                wrapnew.pageSize = pageSize;
                wrapnew.pageNumber = pageNumber;
                wrapnew.recordStart = offset + 1;
                wrapnew.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                wrapnew.totalRecords = totalRecords;
                String query = 'Select Id,Name, ProductCode, Family, ERP7__Product_Service_Family__c, ERP7__Issue_Purchase_Order__c ,ERP7__Issue_Manufacturing_Order__c from Product2 where IsActive = true';
                if(srch != null && srch != '') query += ' AND (Name Like : srch or ProductCode Like :srch) ';
                if(family != null && family != '' && family != '--None--') query += ' AND Family = :family';
                if(subfamily != null && subfamily != '' && subfamily != '--None--') query += ' AND ERP7__Product_Service_Family__c = :subfamily';
                if(customQuery != 'None'){
                    query += customQuery;
                }
                query += ' AND Id IN: prodIDs ';
                query += ' Limit :pageSize ';
                if ((String.isBlank(family) || family == '--None--') && String.isBlank(srch) && (String.isBlank(subfamily) || subfamily == '--None--')) {
                    query += ' OFFSET :offset';
                }
                List<Product2> ProdList = database.query(query);
                if(ProdList.size() > 0){
                    List<ERP7__Reordering_Rule__c> reorderingRules = [Select Id,Name,ERP7__Active__c,ERP7__Lead_Time__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Vendor_Account__c,ERP7__Vendor_Account__r.Name,ERP7__Routing__c,ERP7__Routing__r.Name,ERP7__Minimum_Quantity__c,ERP7__Maximum_Quantity__c,ERP7__MinimumOrderingQuantity__c from ERP7__Reordering_Rule__c where ERP7__Product__c IN: prodIds  ];
                    Map<Id,List<ERP7__Reordering_Rule__c>> ProductReorderMap = new Map<Id,List<ERP7__Reordering_Rule__c>>();
                    for(ERP7__Reordering_Rule__c rr : reorderingRules){
                        if(ProductReorderMap.containsKey(rr.ERP7__Product__c)){
                            ProductReorderMap.get(rr.ERP7__Product__c).add(rr);
                        }
                        else{
                            ProductReorderMap.put(rr.ERP7__Product__c, new List<ERP7__Reordering_Rule__c>{rr});
                        }
                    }

                }
            }
            else{
                system.debug('no items found with high demand');
            }
        } */

        return wrapnew;
    }
    public class ReorderingWrap{
        @AuraEnabled public Decimal leadTime {get;set;}
        @AuraEnabled public Decimal Quantity {get;set;}
        @AuraEnabled public ERP7__Reordering_Rule__c reorder {get;set;}
        public ReorderingWrap(decimal leadtime,Decimal qty,ERP7__Reordering_Rule__c rr){
            this.leadTime = leadtime;
            this.Quantity = qty;
            this.reorder = rr;
        }
    }
    public class wrapper{
        @AuraEnabled public Product2 prod {get;set;}
        @AuraEnabled public List<ERP7__Approved_Vendor__c> approvedVendors {get;set;}
        @AuraEnabled public Decimal suggestedQty {get;set;}
        @AuraEnabled public Decimal orderedQty {get;set;}
        @AuraEnabled public Decimal onHand {get;set;}
        @AuraEnabled public Decimal reservedSO {get;set;}
        @AuraEnabled public Decimal reservedMO {get;set;}
        @AuraEnabled public Decimal QC {get;set;}
        @AuraEnabled public Decimal openPos {get;set;}
        @AuraEnabled public Decimal openPosCount {get;set;}
        @AuraEnabled public Decimal openMosCount {get;set;}
        @AuraEnabled public Decimal openMos {get;set;}
        @AuraEnabled public Decimal icTransfer {get;set;}
        @AuraEnabled public Decimal demandSales {get;set;}
        @AuraEnabled public Decimal demandSalesCount {get;set;}
        @AuraEnabled public Decimal demandMOCount {get;set;}
        @AuraEnabled public Decimal demandMO {get;set;}
        @AuraEnabled public Decimal indirectDemand {get;set;}
        @AuraEnabled public Decimal minQty {get;set;}
        @AuraEnabled public Decimal maxQty {get;set;}
        @AuraEnabled public Decimal netQty {get;set;}
        @AuraEnabled public Integer index {get;set;}
        @AuraEnabled public String ChannelId {get;set;}
         @AuraEnabled public String MPSId {get;set;}
        @AuraEnabled public List<ERP7__Reordering_Rule__c> reorderlist {get;set;}

        @AuraEnabled public String reorderUrl {get;set;}
         @AuraEnabled public String reorderqry {get;set;}
        @AuraEnabled public String algorithm {get;set;}
         @AuraEnabled public String reOrderId {get;set;}
        public wrapper(){

            reOrderId = algorithm = '';
            reorderUrl = reorderqry = MPSId = '';
            reorderlist = new List<ERP7__Reordering_Rule__c>();
            ChannelId = '';
            prod = new  Product2();
            approvedVendors = new List<ERP7__Approved_Vendor__c>();
            suggestedQty = openPosCount = openMosCount = netQty = maxQty = minQty = indirectDemand =demandMO = demandSales = icTransfer= openMos = 0;
            openPos = QC = reservedMO = reservedSO = onHand =orderedQty = suggestedQty = index = 0;
        }
    }
    Public class SelectOptions{
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        public SelectOptions(String value, String label){
            this.value=value;
            this.label=label;
        }
    }
    public class familywrap{
        @AuraEnabled public List<SelectOptions> family {get; set; }
        @AuraEnabled public List<SelectOptions> Subfamily {get; set; }
        @AuraEnabled public List<SelectOptions> algorithm {get; set; }
        @AuraEnabled public ERP7__site__c site {get; set; }
        @AuraEnabled public String ChannelId {get;set;}
        public familywrap(){
            ChannelId = '';
            family = new List<SelectOptions>();
            Subfamily = new List<SelectOptions>();
            algorithm = new List<SelectOptions>();
            site = new ERP7__site__c();

        }
    }
    public class MainWrap{
        @AuraEnabled public List<wrapper> Prodwrap {get;set;}
        @AuraEnabled public Integer recsize { get;set;}
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer pageNumber {get;set;}
        @AuraEnabled public Integer totalRecords {get;set;}
        @AuraEnabled public Integer recordStart {get;set;}
        @AuraEnabled public Integer recordEnd {get;set;}
        @AuraEnabled public String ChannelId {get;set;}
        public MainWrap(){
            ChannelId = '';
            Prodwrap = new List<wrapper>();
            recordEnd = recordStart = totalRecords = pageNumber =  pageSize = recsize = 0;
        }
    }
    public enum SORT_Order {
        Ascending, Descending
            }

    public class trackWrap implements Comparable {
        @AuraEnabled public date dispositionDate { get; set; }
        @AuraEnabled public String disposition { get; set; }
        @AuraEnabled public String partNumber { get; set; }
        @AuraEnabled public String LotOrSerialNumber { get; set; }
        @AuraEnabled public Decimal Qty { get; set; }
        @AuraEnabled public Id itemId { get; set; }
        @AuraEnabled public Decimal currentStock { get; set; }
        @AuraEnabled public String location { get; set; }

        public SORT_Order sortBy = SORT_Order.Ascending;

        public trackWrap() {
            disposition = partNumber = LotOrSerialNumber = location = '';
            Qty = currentStock = 0;
        }

        public Integer compareTo(Object objToCompare) {
            trackWrap that = (trackWrap) objToCompare;
            if (sortBy == SORT_Order.Ascending) {
                if (this.dispositionDate > that.dispositionDate) return 1;
                if (this.dispositionDate < that.dispositionDate) return -1;
                return 0;
            } else {
                if (this.dispositionDate > that.dispositionDate) return -1;
                if (this.dispositionDate < that.dispositionDate) return 1;
                return 0;
            }
        }
    }

    public class mainTrackWrap{
        @AuraEnabled public List<trackWrap> tracklst          {get;set;}
        @AuraEnabled public Product2 prod                     {get;set;}
        @AuraEnabled public  InventoryManagementReport.SORT_Order sortBy                    {get;set;}
        @AuraEnabled public Decimal orderedQty {get;set;}
        @AuraEnabled public Decimal onHand {get;set;}
        @AuraEnabled public Decimal reservedSO {get;set;}
        @AuraEnabled public Decimal reservedMO {get;set;}
        @AuraEnabled public Decimal QC {get;set;}
        @AuraEnabled public Decimal soldStocks {get;set;}
        @AuraEnabled public Decimal purchasedItems {get;set;}
        @AuraEnabled public Decimal currentStock {get;set;}
        @AuraEnabled public String errMsg {get;set;}
        public mainTrackWrap(){
            currentStock = 0;
            errMsg = '';
            tracklst = new List<trackWrap>();
            prod = new  Product2();
            sortBy = InventoryManagementReport.SORT_Order.Ascending;
            orderedQty = onHand = reservedSO = reservedMO = QC = soldStocks = purchasedItems = 0;

        }
    }
    public class ForecastWrapper {
        @AuraEnabled
        public String productId { get; set; }
        @AuraEnabled
        public ERP7__Forecast_Plan__c forecastPlan { get; set; }
        @AuraEnabled
        public List<ERP7__Forecasting_Items__c> forecastItems { get; set; }

        @AuraEnabled public List<ERP7__MPS_line_Item__c> MPSlineitems {get;set;}
        @AuraEnabled
        public String productName { get; set; }
        @AuraEnabled
        public String productCode { get; set; }
        @AuraEnabled
        public Decimal quantity { get; set; }
        @AuraEnabled
        public List<String> monthQuantities { get; set; }
        @AuraEnabled
        public Map<String,List<OrderDetailsWrap>> orderWarp { get; set; }
         @AuraEnabled public List<ReorderingWrap> ReorderList {get;set;}

        public ForecastWrapper(String productId,String productName, String productCode, Decimal quantity,Map<String,List<OrderDetailsWrap>> orderWrap,ERP7__Forecast_Plan__c forecastPlan,List<ERP7__Forecasting_Items__c> forecastItems) {
            this.productId = productId;
            this.productName = productName;
            this.productCode = productCode;
            this.quantity = quantity;
            this.monthQuantities = new List<String>();
            this.orderWarp = orderWrap;
            this.forecastPlan = forecastPlan;
            this.forecastItems = forecastItems;

        }
         public ForecastWrapper(String productId,String productName, String productCode, Decimal quantity,Map<String,List<OrderDetailsWrap>> orderWrap,List<ERP7__MPS_line_Item__c> MPSItems,List<ReorderingWrap> ReorderList) {
            this.productId = productId;
            this.productName = productName;
            this.productCode = productCode;
            this.quantity = quantity;
            this.monthQuantities = new List<String>();
            this.orderWarp = orderWrap;
            this.MPSlineitems = MPSItems;
            this.ReorderList = ReorderList;
        }
        public ForecastWrapper(){
            this.productId = '';
            this.productName = '';
            this.productCode = '';
            this.quantity = 0;
            this.monthQuantities = new LIST<String>();
            this.orderWarp = new  Map<String,List<OrderDetailsWrap>>();
            this.forecastPlan = new ERP7__Forecast_Plan__c();
            this.forecastItems = new LIST<ERP7__Forecasting_Items__c>();
        }
    }
    public class OrderDetailsWrap{
        @AuraEnabled
        public String  OrderId {get;set;}
        @AuraEnabled
        public String  OrderNumber {get;set;}
        @AuraEnabled
        public String  customer_Vendor {get;set;}
        @AuraEnabled
        public Decimal  Quantity {get;set;}

        public OrderDetailsWrap(){
            this.OrderId = '';
            this.OrderNumber = '';
            this.customer_Vendor = '';
            this.Quantity = 0;
        }
        public OrderDetailsWrap(string num1, string num2,decimal qty,String ItemId){
            this.OrderNumber = num1;
            this.customer_Vendor = num2;
            this.Quantity = qty;
            this.OrderId = ItemId;
        }
    }
    public class MainForecastWrap{
        @AuraEnabled public List<ForecastWrapper> ForecastWrap {get;set;}
        @AuraEnabled public List<ERP7__Forecast_Plan__c> ForecastPlans {get;set;}
        @AuraEnabled public Integer recsize { get;set;}
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer pageNumber {get;set;}
        @AuraEnabled public Integer totalRecords {get;set;}
        @AuraEnabled public Integer recordStart {get;set;}
        @AuraEnabled public Integer recordEnd {get;set;}
        public MainForecastWrap(){
            ForecastWrap = new List<ForecastWrapper>();
            recordEnd = recordStart = totalRecords = pageNumber =  pageSize = recsize = 0;
            ForecastPlans = new List<ERP7__Forecast_Plan__c>();
        }
    }

}