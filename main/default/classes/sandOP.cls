public with sharing class sandOP {
    @AuraEnabled(cacheable=true)
    public static Account getDefaultOrganisation() {        return UtilClass.getOrganisationByLogin_Employee();    }
// Matheen's Code 

@AuraEnabled(cacheable=true)
public static Product2 getDefaultProductFromOrderItem() {
        // Get the first day of the current year
    Date startOfYear = Date.newInstance(Date.today().year(), 1, 1);
    Date endOfYear = Date.newInstance(Date.today().year(), 12, 31);

    List<AggregateResult> topProductResult = [
        SELECT Product2Id, SUM(Quantity) totalQuantity
        FROM OrderItem
        WHERE Product2Id != null
            AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
            AND Order.EffectiveDate >= :startOfYear
            AND Order.EffectiveDate <= :endOfYear

        GROUP BY Product2Id
        ORDER BY SUM(Quantity) DESC
        LIMIT 1
    ];


    if (!topProductResult.isEmpty()) {
        Id topProductId = (Id)topProductResult[0].get('Product2Id');
        List<Product2> products = [
            SELECT Id, Name
            FROM Product2
            WHERE Id = :topProductId
        ];
        return products.isEmpty() ? null : products[0];
    }
    return null;
}
@AuraEnabled(cacheable=true)
public static Account getDefaultCustomerFromOrders() {
    Date startOfYear = Date.newInstance(Date.today().year(), 1, 1);
    Date endOfYear = Date.newInstance(Date.today().year(), 12, 31);

    List<AggregateResult> topCustomerResult = [
        SELECT AccountId, COUNT(Id) orderCount
        FROM Order
        WHERE 
            ERP7__Active__c = true 
            AND AccountId != null
            AND EffectiveDate >= :startOfYear
            AND EffectiveDate <= :endOfYear
        GROUP BY AccountId
        ORDER BY COUNT(Id) DESC
        LIMIT 1
    ];

    if (!topCustomerResult.isEmpty()) {
        Id topCustomerId = (Id) topCustomerResult[0].get('AccountId');
        List<Account> customers = [SELECT Id, Name FROM Account WHERE Id = :topCustomerId];
        return customers.isEmpty() ? null : customers[0];
    }

    return null;
}

@AuraEnabled(cacheable=true)
public static ERP7__Site__c getDefaultWarehouseByStock(Id organisationId) {
    List<ERP7__Site__c> topSite = [
        SELECT Id, Name
        FROM ERP7__Site__c
        WHERE ERP7__Active__c = TRUE
        AND ERP7__Organisation__c = :organisationId
        AND ERP7__Stock__c != null
        ORDER BY ERP7__Stock__c DESC
        LIMIT 1
    ];

    return topSite.isEmpty() ? null : topSite[0];
}


@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getTopCustomersForProduct(Id productId, Integer topN,Id OrgId) {
    Integer currentYear = Date.today().year();
    Date startDate = Date.newInstance(currentYear, 1, 1);
    Date endDate = Date.newInstance(currentYear, 12, 31);

    List<AggregateResult> results = [
        SELECT Order.AccountId accId, SUM(Quantity) totalQty
        FROM OrderItem
        WHERE Product2Id = :productId
        AND Order.Status = 'Activated'
        AND Order.EffectiveDate >= :startDate AND Order.EffectiveDate <= :endDate
        AND ERP7__Organisation__c = :OrgId
        GROUP BY Order.AccountId
        ORDER BY SUM(Quantity) DESC
        LIMIT :topN
    ];

    List<Map<String, Object>> response = new List<Map<String, Object>>();
    for (AggregateResult ar : results) {
        Id accId = (Id)ar.get('accId');
        Decimal qty = (Decimal)ar.get('totalQty');
        Account acc = [SELECT Name FROM Account WHERE Id = :accId LIMIT 1];

        Map<String, Object> entry = new Map<String, Object>();
        entry.put('accountId', accId);
        entry.put('accountName', acc.Name);
        entry.put('quantity', qty.setScale(2));
        response.add(entry);
    }

    return response;
}


  /*  @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDemandData(String productId, String organisationId) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            System.debug('getDemandData called with productId: ' + productId + ', organisationId: ' + organisationId);
            if (String.isBlank(productId) || String.isBlank(organisationId)) {
                throw new AuraHandledException('Product ID and Organisation ID cannot be blank.');
            }
            // Demand by Month: Aggregate quantity by month
            List<AggregateResult> monthlyDemand = [
                SELECT CALENDAR_MONTH(Order.EffectiveDate) month, CALENDAR_YEAR(Order.EffectiveDate) year, SUM(Quantity) totalQuantity
                FROM OrderItem
                WHERE Product2Id = :productId
                AND Order.ERP7__Organisation__c = :organisationId
                AND Order.EffectiveDate = LAST_N_MONTHS:6
                GROUP BY CALENDAR_MONTH(Order.EffectiveDate), CALENDAR_YEAR(Order.EffectiveDate)
                ORDER BY CALENDAR_YEAR(Order.EffectiveDate), CALENDAR_MONTH(Order.EffectiveDate)
                LIMIT 2000
            ];
            System.debug('Monthly demand data: ' + monthlyDemand);
            List<String> monthLabels = new List<String>();
            List<Decimal> monthData = new List<Decimal>();
            for (AggregateResult ar : monthlyDemand) {
                Integer month = (Integer)ar.get('month');
                Integer year = (Integer)ar.get('year');
                monthLabels.add(String.valueOf(month) + '/' + String.valueOf(year));
                monthData.add((Decimal)ar.get('totalQuantity'));
            }
            result.put('monthLabels', monthLabels);
            result.put('monthData', monthData);
            
            // Demand by Customer: Aggregate quantity by customer
            List<AggregateResult> customerDemand = [
                SELECT Order.Account.Name customerName, SUM(Quantity) totalQuantity
                FROM OrderItem
                WHERE Product2Id = :productId
                AND Order.ERP7__Organisation__c = :organisationId
                GROUP BY Order.Account.Name
                ORDER BY Order.Account.Name
                LIMIT 2000
            ];
            System.debug('Customer demand data: ' + customerDemand);
            List<String> customerLabels = new List<String>();
            List<Decimal> customerData = new List<Decimal>();
            for (AggregateResult ar : customerDemand) {
                customerLabels.add((String)ar.get('customerName'));
                customerData.add((Decimal)ar.get('totalQuantity'));
            }
            result.put('customerLabels', customerLabels);
            result.put('customerData', customerData);
            
            AggregateResult productDemand = [
                SELECT SUM(Quantity) totalQuantity
                FROM OrderItem
                WHERE Product2Id = :productId
                AND Order.ERP7__Organisation__c = :organisationId
            ];
            System.debug('Product demand data: ' + productDemand);
            List<String> productLabels = new List<String>{[SELECT Name FROM Product2 WHERE Id = :productId].Name};
            List<Decimal> productData = new List<Decimal>{(Decimal)productDemand.get('totalQuantity')};
            result.put('productLabels', productLabels);
            result.put('productData', productData);
            System.debug('Demand data result: ' + result); 
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching demand data: ' + e.getMessage());
        }
    }
*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTopProductsByDemand(String organisationId) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            System.debug('getTopProductsByDemand called with organisationId: ' + organisationId);
            if (String.isBlank(organisationId)) {
                throw new AuraHandledException('Organisation ID cannot be blank.');
            }
            Date startOfYear = Date.newInstance(Date.today().year(), 1, 1);
            Date endOfYear = Date.newInstance(Date.today().year(), 12, 31);

            List<AggregateResult> topProducts = [
                SELECT Product2.Name productName, SUM(Quantity) totalQuantity
                FROM OrderItem
                WHERE Order.ERP7__Organisation__c = :organisationId
                AND Order.Status NOT IN ('Cancelled','Draft','Entered') 
                AND Order.EffectiveDate >= :startOfYear
                AND Order.EffectiveDate <= :endOfYear
                GROUP BY Product2.Name
                ORDER BY SUM(Quantity) DESC
                LIMIT 5
            ];

            System.debug('Top products data: ' + topProducts);
            List<String> topProductLabels = new List<String>();
            List<Decimal> topProductData = new List<Decimal>();
            for (AggregateResult ar : topProducts) {
                topProductLabels.add((String)ar.get('productName'));
                topProductData.add((Decimal)ar.get('totalQuantity'));
            }
            result.put('topProductLabels', topProductLabels);
            result.put('topProductData', topProductData);
            System.debug('Top products result: ' + result);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching top products: ' + e.getMessage());
        }
    }

        @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWarehouseInventory(String organisationId, String productId) {
        try {
        if (String.isBlank(organisationId)) {
            throw new AuraHandledException('Organisation ID is required.');
        }

        List<AggregateResult> warehouseResults;

            if (String.isNotBlank(productId)) {
                warehouseResults = [
                    SELECT ERP7__Warehouse__r.Name warehouseName, SUM(ERP7__Number_of_Item_In_Stock__c) totalQuantity
                    FROM ERP7__Inventory_Stock__c
                    WHERE ERP7__Warehouse__r.ERP7__Organisation__c = :organisationId
                    AND ERP7__Product__c = :productId
                    AND ERP7__Active__c = true
                    AND Name != 'Awaiting Stock'
                    AND ERP7__Number_of_Item_In_Stock__c > 0
                    GROUP BY ERP7__Warehouse__r.Name
                    ORDER BY SUM(ERP7__Number_of_Item_In_Stock__c) DESC LIMIT 2000
                ];
            } else {
                warehouseResults = [
                    SELECT ERP7__Warehouse__r.Name warehouseName, SUM(ERP7__Number_of_Item_In_Stock__c) totalQuantity
                    FROM ERP7__Inventory_Stock__c
                    WHERE ERP7__Warehouse__r.ERP7__Organisation__c = :organisationId
                    AND ERP7__Active__c = true
                    AND Name != 'Awaiting Stock'
                    AND ERP7__Number_of_Item_In_Stock__c > 0
                    GROUP BY ERP7__Warehouse__r.Name
                    ORDER BY SUM(ERP7__Number_of_Item_In_Stock__c) DESC LIMIT 2000
                ];
            }


        // Process results
        List<String> warehouseLabels = new List<String>();
        List<Decimal> warehouseInventory = new List<Decimal>();

        for (AggregateResult ar : warehouseResults) {
            warehouseLabels.add((String)ar.get('warehouseName'));
            warehouseInventory.add((Decimal)ar.get('totalQuantity'));
        }

        return new Map<String, Object>{
            'warehouseLabels' => warehouseLabels,
            'warehouseInventory' => warehouseInventory
        };
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching warehouse inventory: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLocationInventory(String siteId, String organisationId , String productId) {
        try {
            if (String.isBlank(siteId)) {
                throw new AuraHandledException('Site ID is required.');
            }
            if (String.isBlank(organisationId)) {
                throw new AuraHandledException('Organisation ID is required.');
            }
            List<AggregateResult> locationResults;
            // Query inventory aggregated by location for the specific site
           if(String.isNotBlank(productId)){
            locationResults = [
                SELECT ERP7__Location__r.Name locationName, 
                    SUM(ERP7__Number_of_Item_In_Stock__c) totalQuantity
                FROM ERP7__Inventory_Stock__c
                WHERE ERP7__Warehouse__r.ERP7__Organisation__c = :organisationId
                AND ERP7__Warehouse__c = :siteId
                AND ERP7__Number_of_Item_In_Stock__c > 0
                AND ERP7__Active__c = true
                AND Name != 'Awaiting Stock'
                AND ERP7__Product__c = :productId
                GROUP BY ERP7__Location__r.Name
                ORDER BY SUM(ERP7__Number_of_Item_In_Stock__c) DESC LIMIT 2000
            ];
           }
           else{
           locationResults = [
                SELECT ERP7__Location__r.Name locationName, 
                    SUM(ERP7__Number_of_Item_In_Stock__c) totalQuantity
                FROM ERP7__Inventory_Stock__c
                WHERE ERP7__Warehouse__r.ERP7__Organisation__c = :organisationId
                AND ERP7__Warehouse__c = :siteId
                AND ERP7__Number_of_Item_In_Stock__c > 0
                AND ERP7__Active__c = true
                AND Name != 'Awaiting Stock'
                GROUP BY ERP7__Location__r.Name
                ORDER BY SUM(ERP7__Number_of_Item_In_Stock__c) DESC LIMIT 2000
            ];
           }
            List<String> locationLabels = new List<String>();
            List<Decimal> locationInventory = new List<Decimal>();

            for (AggregateResult ar : locationResults) {
                String locationName = (String)ar.get('locationName');
                Decimal totalQuantity = (Decimal)ar.get('totalQuantity');

                if (locationName == null) {
                    locationName = 'No Location';
                }

                locationLabels.add(locationName);
                locationInventory.add(totalQuantity);
            }

            // If no results, add a placeholder to indicate no inventory
            if (locationLabels.isEmpty()) {
                locationLabels.add('No Location');
                locationInventory.add(0);
            }

            return new Map<String, Object>{
                'locationLabels' => locationLabels,
                'locationInventory' => locationInventory
            };
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching location inventory: ' + e.getMessage());
        }
    }

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getStockAlertData(Id siteId,Id location, Id product,Id OrgId) {
    System.debug('product '+product);
    List<Map<String, Object>> results = new List<Map<String, Object>>();

     if (siteId == null || OrgId == null) {
        throw new AuraHandledException('Site (Warehouse) is required');
    }

    List<ERP7__Inventory_Stock__c> inventoryRecords;

    if (location != null && product != null) {
        inventoryRecords = [
            SELECT ERP7__Product__c, ERP7__Number_of_Item_In_Stock__c,
                   ERP7__Warehouse__r.Name, ERP7__Location__r.Name
            FROM ERP7__Inventory_Stock__c
            WHERE ERP7__Active__c = true
            AND ERP7__Warehouse__c = :siteId
            AND ERP7__Location__c = :location
            AND ERP7__Product__c = :product
            AND Name != 'Awaiting Stock'
            AND ERP7__Organisation__c = :OrgId
            AND ERP7__Number_of_Item_In_Stock__c > 0 LIMIT 2000
        ];
    }
    // Site + Location
    else if (location != null) {
        inventoryRecords = [
            SELECT ERP7__Product__c, ERP7__Number_of_Item_In_Stock__c,
                   ERP7__Warehouse__r.Name, ERP7__Location__r.Name
            FROM ERP7__Inventory_Stock__c
            WHERE ERP7__Active__c = true
            AND ERP7__Warehouse__c = :siteId
            AND ERP7__Location__c = :location
            AND Name != 'Awaiting Stock'
            AND ERP7__Organisation__c = :OrgId
            AND ERP7__Number_of_Item_In_Stock__c > 0
        ];
    }
    // Site + Product
    else if (product != null) {
        inventoryRecords = [
            SELECT ERP7__Product__c, ERP7__Number_of_Item_In_Stock__c,
                   ERP7__Warehouse__r.Name, ERP7__Location__r.Name
            FROM ERP7__Inventory_Stock__c
            WHERE ERP7__Active__c = true
            AND ERP7__Warehouse__c = :siteId
            AND ERP7__Product__c = :product
            AND Name != 'Awaiting Stock'
            AND ERP7__Organisation__c = :OrgId
            AND ERP7__Number_of_Item_In_Stock__c > 0
        ];
    }
    // Only Site
    else {
        inventoryRecords = [
            SELECT ERP7__Product__c, ERP7__Number_of_Item_In_Stock__c,
                   ERP7__Warehouse__r.Name, ERP7__Location__r.Name
            FROM ERP7__Inventory_Stock__c
            WHERE ERP7__Active__c = true
            AND ERP7__Warehouse__c = :siteId
            AND Name != 'Awaiting Stock'
            AND ERP7__Organisation__c = :OrgId
            AND ERP7__Number_of_Item_In_Stock__c > 0
        ];
    }
    // Step 2: Aggregate stock by product + location + warehouse
    Map<String, Map<String, Object>> dataMap = new Map<String, Map<String, Object>>();
    Set<Id> productIds = new Set<Id>();

    for (ERP7__Inventory_Stock__c record : inventoryRecords) {
        Id productId = record.ERP7__Product__c;
        String warehouseName = record.ERP7__Warehouse__r.Name;
        String locationName = record.ERP7__Location__r.Name;
        String key = productId + '|' + warehouseName + '|' + locationName;

        productIds.add(productId);

        if (!dataMap.containsKey(key)) {
            dataMap.put(key, new Map<String, Object>{
                'productId' => productId,
                'currentStock' => 0,
                'warehouse' => warehouseName,
                'location' => locationName
            });
        }

        Decimal currentTotal = (Decimal) dataMap.get(key).get('currentStock');
        dataMap.get(key).put('currentStock', currentTotal + record.ERP7__Number_of_Item_In_Stock__c);
    }

    if (productIds.isEmpty()) return results;

    // Step 3: Get product names
    Map<Id, String> productNameMap = new Map<Id, String>();
    for (Product2 prod : [
        SELECT Id, Name FROM Product2 WHERE Id IN :productIds
    ]) {
        productNameMap.put(prod.Id, prod.Name);
    }

    // Step 4: Get reordering rules
    Map<Id, ERP7__Reordering_Rule__c> ruleMap = new Map<Id, ERP7__Reordering_Rule__c>();
    for (ERP7__Reordering_Rule__c rule : [
        SELECT ERP7__Product__c, ERP7__Safety_Stock__c, ERP7__Reorder_Level__c
        FROM ERP7__Reordering_Rule__c
        WHERE ERP7__Warehouse__c = :siteId
        AND ERP7__Product__c IN :productIds
        AND ERP7__Active__c = true
    ]) {
        ruleMap.put(rule.ERP7__Product__c, rule);
    }

    // Step 5: Assemble final results
    for (Map<String, Object> entry : dataMap.values()) {
        Id productId = (Id) entry.get('productId');
        Decimal currentStock = (Decimal) entry.get('currentStock');
        Decimal reorderLevel = 0;
        Decimal safetyStock = 0;

        if (ruleMap.containsKey(productId)) {
            ERP7__Reordering_Rule__c rule = ruleMap.get(productId);
            reorderLevel = rule.ERP7__Reorder_Level__c != null ? rule.ERP7__Reorder_Level__c : 0;
            safetyStock = rule.ERP7__Safety_Stock__c != null ? rule.ERP7__Safety_Stock__c : 0;
        }

        entry.put('productName', productNameMap.get(productId));
        entry.put('reorderLevel', reorderLevel);
        entry.put('safetyStock', safetyStock);

        results.add(entry);
    }
    System.debug('result '+results);
    return results;
}
@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getDynamicStockAgingData(Id siteId, Id orgId, Id prodId) {
    System.debug('sited id '+siteId+'Orgid '+orgId+' prod Id '+prodId);
    if (siteId == null || orgId == null) {
        throw new AuraHandledException('Site ID and Organisation ID are required.');
    }

    Map<Id, Map<String, Object>> groupedMap = new Map<Id, Map<String, Object>>();

    String baseQuery = 'SELECT ERP7__Product__c, ERP7__Product__r.Name, ERP7__Number_of_Item_In_Stock__c, ' +
                       'ERP7__Checked_In_Date__c, ERP7__Expiry_Date__c, ERP7__Expiration_Date__c, ERP7__Status__c ' +
                       'FROM ERP7__Inventory_Stock__c ' +
                       'WHERE ERP7__Checked_In_Date__c != NULL ' +
                       'AND ERP7__Number_of_Item_In_Stock__c > 0 ' +
                       'AND ERP7__Warehouse__c = :siteId ' +
                       'AND ERP7__Active__c = true ' +
                       'AND Name != \'Awaiting Stock\' ' +
                       'AND ERP7__Organisation__c = :orgId';

    if (prodId != null) {
        baseQuery += ' AND ERP7__Product__c = :prodId';
    }
    baseQuery+= ' LIMIT 2000'; 
    List<ERP7__Inventory_Stock__c> stocks = Database.query(baseQuery);

    for (ERP7__Inventory_Stock__c stock : stocks) {
        Id productId = stock.ERP7__Product__c;
        Boolean isExpired = false;

        if (stock.ERP7__Status__c == 'Expired') {
            isExpired = true;
        } else if (stock.ERP7__Expiry_Date__c != null && stock.ERP7__Expiry_Date__c <= Date.today()) {
            isExpired = true;
        } else if (stock.ERP7__Expiration_Date__c != null && stock.ERP7__Expiration_Date__c <= Date.today()) {
            isExpired = true;
        }

        // Use product ID as key
        if (!groupedMap.containsKey(productId)) {
            groupedMap.put(productId, new Map<String, Object>{
                'productId' => productId,
                'productName' => stock.ERP7__Product__r.Name,
                'quantity' => stock.ERP7__Number_of_Item_In_Stock__c,
                'receivedDate' => stock.ERP7__Checked_In_Date__c,
                'isExpired' => isExpired
            });
        } else {
            Map<String, Object> existing = groupedMap.get(productId);
            Decimal qty = (Decimal)existing.get('quantity');
            Date existingDate = (Date)existing.get('receivedDate');

            existing.put('quantity', qty + stock.ERP7__Number_of_Item_In_Stock__c);
            if (stock.ERP7__Checked_In_Date__c < existingDate) {
                existing.put('receivedDate', stock.ERP7__Checked_In_Date__c);
            }

            if ((Boolean)existing.get('isExpired') == false && isExpired) {
                existing.put('isExpired', true);
            }
        }
    }

    return groupedMap.values();
}
@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getAgingTrendData(Id siteId, Id orgId, Id prodId, String yearStr) {
    Integer year = Integer.valueOf(yearStr);
    Date lastDayOfYear = Date.newInstance(year, 12, 31);
    
    List<Map<String, Object>> trendData = new List<Map<String, Object>>();
    List<String> allBuckets = new List<String>{ '<30d', '30–90d', '90–180d', '180–365d', '>365d', 'Expired' };

    // Step 1: Fetch all stock records received up to the selected year
    String baseQuery = 'SELECT ERP7__Product__c, ERP7__Checked_In_Date__c, ERP7__Number_of_Item_In_Stock__c, ' +
                       'ERP7__Expiry_Date__c, ERP7__Expiration_Date__c, ERP7__Status__c ' +
                       'FROM ERP7__Inventory_Stock__c ' +
                       'WHERE ERP7__Number_of_Item_In_Stock__c > 0 ' +
                       'AND ERP7__Warehouse__c = :siteId ' +
                       'AND ERP7__Organisation__c = :orgId ' +
                       'AND ERP7__Active__c = true ' +
                       'AND Name != \'Awaiting Stock\' ' +
                       'AND ERP7__Checked_In_Date__c <= :lastDayOfYear';
	
    if (prodId != null) {
        baseQuery += ' AND ERP7__Product__c = :prodId';
    }
    baseQuery += ' LIMIT 2000'; 
    List<ERP7__Inventory_Stock__c> allStocks = Database.query(baseQuery);
	System.debug('ALLSTOCKS->'+allStocks);
    // Step 2: Build monthly trend
    for (Integer m = 1; m <= 12; m++) {
        Date snapshotDate = Date.newInstance(year, m, 1).addMonths(1).addDays(-1); // last day of the month

        Integer monthInt = snapshotDate.month();
        String monthStr = (monthInt < 10 ? '0' : '') + String.valueOf(monthInt);
        String monthKey = String.valueOf(snapshotDate.year()) + '-' + monthStr;

        Map<String, Decimal> bucketMap = new Map<String, Decimal>();

        for (ERP7__Inventory_Stock__c stock : allStocks) {
            if (stock.ERP7__Checked_In_Date__c == null || stock.ERP7__Checked_In_Date__c > snapshotDate) {
                continue;
            }

            Integer age = stock.ERP7__Checked_In_Date__c.daysBetween(snapshotDate);

            String bucket;

            if (stock.ERP7__Status__c == 'Expired' ||
                (stock.ERP7__Expiry_Date__c != null && stock.ERP7__Expiry_Date__c <= snapshotDate) ||
                (stock.ERP7__Expiration_Date__c != null && stock.ERP7__Expiration_Date__c <= snapshotDate)) {
                bucket = 'Expired';
            } else if (age < 30) {
                bucket = '<30d';
            } else if (age < 90) {
                bucket = '30–90d';
            } else if (age < 180) {
                bucket = '90–180d';
            } else if (age < 365) {
                bucket = '180–365d';
            } else {
                bucket = '>365d';
            }

            Decimal qty = stock.ERP7__Number_of_Item_In_Stock__c;
            bucketMap.put(bucket, bucketMap.containsKey(bucket) ? bucketMap.get(bucket) + qty : qty);
        }

        // Step 3: Add row to trend data
        Map<String, Object> row = new Map<String, Object>();
        row.put('month', monthKey);
        for (String bucket : allBuckets) {
            row.put(bucket, bucketMap.containsKey(bucket) ? bucketMap.get(bucket) : 0);
        }

        trendData.add(row);
    }
    return trendData;
}
@AuraEnabled(cacheable=true)
public static Map<String, Object> getCustomerOrderTrend(Id customerId, Id productId, Id orgId, String yearStr) {
    System.debug('in getCustomerOrderTrend');

    Map<String, Object> result = new Map<String, Object>();
    System.debug('customerId -> ' + customerId + ' | productId -> ' + productId + ' | orgId -> ' + orgId + ' | yearStr -> ' + yearStr);

    if (String.isBlank(customerId) || String.isBlank(orgId)) {
        System.debug('Missing customerId or orgId');
        result.put('months', new List<String>());
        result.put('quantities', new List<Decimal>());
        return result;
    }

    Integer selectedYear = String.isNotBlank(yearStr) ? Integer.valueOf(yearStr) : Date.today().year();
    Date startOfYear = Date.newInstance(selectedYear, 1, 1);
    Date endOfYear = Date.newInstance(selectedYear, 12, 31);

    List<OrderItem> orderItems;

    if (productId != null) {
        orderItems = [
            SELECT Quantity, Product2Id, Order.EffectiveDate, Order.AccountId
            FROM OrderItem
            WHERE Order.AccountId = :customerId
            AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
            AND Order.EffectiveDate  >= :startOfYear AND Order.EffectiveDate  <= :endOfYear
            AND ERP7__Organisation__c = :orgId
            AND Product2Id = :productId
            LIMIT 2000
        ];
    } else {
        orderItems = [
            SELECT Quantity, Product2Id, Order.EffectiveDate, Order.AccountId
            FROM OrderItem
            WHERE Order.AccountId = :customerId
            AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
            AND Order.EffectiveDate  >= :startOfYear AND Order.EffectiveDate  <= :endOfYear
            AND ERP7__Organisation__c = :orgId
            LIMIT 2000
        ];
    }

    Map<String, Decimal> monthlyData = new Map<String, Decimal>();

    for (OrderItem oi : orderItems) {
        if (oi.Order != null && oi.Order.EffectiveDate  != null) {
            Date orderDate = oi.Order.EffectiveDate;
            String monthLabel = getMonthLabel(orderDate.month());

            if (!monthlyData.containsKey(monthLabel)) {
                monthlyData.put(monthLabel, 0);
            }
            monthlyData.put(monthLabel, monthlyData.get(monthLabel) + oi.Quantity);
        }
    }

    List<String> months = new List<String>{ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' };
    List<Decimal> quantities = new List<Decimal>();
    for (String m : months) {
        quantities.add(monthlyData.containsKey(m) ? monthlyData.get(m) : 0);
    }

    result.put('months', months);
    result.put('quantities', quantities);
    System.debug('result -> ' + result);

    return result;
}

// Helper to convert numeric month to label
private static String getMonthLabel(Integer monthNumber) {
    List<String> monthLabels = new List<String>{
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    };
    return monthLabels[monthNumber - 1];
}
@AuraEnabled(cacheable=true)
public static Map<String, Object> getCustomerSummary(Id customerId, Id productId, String yearStr,Id orgId) {
    Integer year = String.isNotBlank(yearStr) ? Integer.valueOf(yearStr) : Date.today().year();
    Date startOfYear = Date.newInstance(year, 1, 1);
    Date endOfYear = Date.newInstance(year, 12, 31);
    List<OrderItem> items;

if (productId != null) {
    items = [
        SELECT Quantity, TotalPrice, Order.EffectiveDate
        FROM OrderItem
        WHERE Order.AccountId = :customerId
        AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
        AND Order.EffectiveDate >= :startOfYear AND Order.EffectiveDate <= :endOfYear
        AND ERP7__Organisation__c = :orgId
        AND Product2Id = :productId
        LIMIT 2000
    ];
} else {
    items = [
        SELECT Quantity, TotalPrice, Order.EffectiveDate
        FROM OrderItem
        WHERE Order.AccountId = :customerId
        AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
        AND Order.EffectiveDate >= :startOfYear AND Order.EffectiveDate <= :endOfYear
        AND ERP7__Organisation__c = :orgId
        LIMIT 2000
    ];
}
    Integer frequency = items.size();
    Decimal totalAmount = 0;
    Datetime  mostRecentDate = null;

    for (OrderItem oi : items) {
        totalAmount += oi.TotalPrice;
        if (mostRecentDate == null || oi.Order.EffectiveDate > mostRecentDate) {
            mostRecentDate = oi.Order.EffectiveDate;
        }
    }

   Integer daysSinceLastOrder = mostRecentDate != null
    ? Date.today().daysBetween(Date.newInstance(mostRecentDate.year(), mostRecentDate.month(), mostRecentDate.day()))
    : null;


    return new Map<String, Object>{
        'frequency' => frequency,
        'monetary' => totalAmount,
        'recencyDays' => daysSinceLastOrder,
        'lastOrderDate' => mostRecentDate
    };
}

// @AuraEnabled(cacheable=true)
// public static Map<String, Object> getDemandForecastWithHistory(Id productId, String dummyYear) {
//     Date endDate = Date.today();
//     Date startDate = endDate.addYears(-3); // Last 3 years

//     // Step 1: Fetch grouped demand by Year + Month
//     List<AggregateResult> results = [
//         SELECT CALENDAR_YEAR(Order.CreatedDate) yr,
//                CALENDAR_MONTH(Order.CreatedDate) mon,
//                SUM(Quantity) qty
//         FROM OrderItem
//         WHERE Product2Id = :productId
//         AND Order.Status = 'Activated'
//         AND Order.CreatedDate >= :startDate AND Order.CreatedDate <= :endDate
//         GROUP BY CALENDAR_YEAR(Order.CreatedDate), CALENDAR_MONTH(Order.CreatedDate)
//         ORDER BY CALENDAR_YEAR(Order.CreatedDate), CALENDAR_MONTH(Order.CreatedDate)
//     ];

//     // Step 2: Build a complete time series (e.g., "Jan 2022", "Feb 2022", ..., "Jun 2025")
//     Map<String, Decimal> demandMap = new Map<String, Decimal>();
//     for (AggregateResult ar : results) {
//         Integer y = (Integer)ar.get('yr');
//         Integer m = (Integer)ar.get('mon');
//         String label = getMonthLabel(m) + ' ' + y;
//         Decimal qty = (Decimal)ar.get('qty');
//         demandMap.put(label, qty.setScale(2));
//     }

//     List<String> monthLabels = new List<String>();
//     List<Decimal> demandValues = new List<Decimal>();

//     Date d = startDate.toStartOfMonth();
//     while (d <= endDate) {
//         String label = getMonthLabel(d.month()) + ' ' + d.year();
//         monthLabels.add(label);
//         demandValues.add(demandMap.containsKey(label) ? demandMap.get(label) : 0);
//         d = d.addMonths(1);
//     }

//     // Step 3: Run forecast on full series
//     Integer forecastMonths = 6;
//     Integer seasonLength = 12;
//     ForecastResult forecastResult = runHoltWinters(demandValues, forecastMonths, seasonLength);

//     // Step 4: Return combined result
//     Map<String, Object> result = new Map<String, Object>();
//     result.put('historicalMonths', monthLabels);
//     result.put('historicalValues', demandValues);
//     result.put('forecastMonths', forecastResult.forecastMonths);
//     result.put('forecastValues', forecastResult.forecastValues);

//     return result;
// }


// private static ForecastResult runHoltWinters(List<Decimal> values, Integer m, Integer seasonLength) {
//     Decimal alpha = 0.5;
//     Decimal beta = 0.3;
//     Decimal gamma = 0.2;

//     Integer len = values.size();
//     if (len < seasonLength * 2) {
//         throw new AuraHandledException('Not enough data for Holt-Winters.');
//     }

//     List<Decimal> level = new List<Decimal>{ values[0] };
//     List<Decimal> trend = new List<Decimal>{ values[1] - values[0] };
//     List<Decimal> seasonals = initSeasonals(values, seasonLength);

//     for (Integer i = 1; i < len; i++) {
//         Decimal lastLevel = level[i - 1];
//         Decimal lastTrend = trend[i - 1];
//         Integer sIndex = Math.mod(i, seasonLength);
//         Decimal seasonal = seasonals[sIndex];
//         Decimal current = values[i];

//         Decimal newLevel = alpha * (current - seasonal) + (1 - alpha) * (lastLevel + lastTrend);
//         Decimal newTrend = beta * (newLevel - lastLevel) + (1 - beta) * lastTrend;
//         Decimal newSeasonal = gamma * (current - newLevel) + (1 - gamma) * seasonal;

//         level.add(newLevel);
//         trend.add(newTrend);
//         seasonals[sIndex] = newSeasonal;
//     }

//     ForecastResult result = new ForecastResult();
//     result.forecastMonths = new List<String>();
//     result.forecastValues = new List<Decimal>();

//     Date today = Date.today();
//     for (Integer i = 1; i <= m; i++) {
//         Decimal l = level[len - 1];
//         Decimal t = trend[len - 1];
//         Integer sIndex = Math.mod(len + i - 1, seasonLength);
//         Decimal s = seasonals[sIndex];
//         Decimal f = l + (i * t) + s;
//         //result.forecastValues.add(f.setScale(2));
//         result.forecastValues.add(Math.max(f, 0).setScale(2));

//         Date monthDate = today.addMonths(i);
//         result.forecastMonths.add(getMonthLabel(monthDate.month()));
//     }

//     return result;
// }

private static List<Decimal> initSeasonals(List<Decimal> values, Integer seasonLength) {
    List<Decimal> seasonals = new List<Decimal>();
    for (Integer i = 0; i < seasonLength; i++) {
        Decimal sum = 0;
        Integer count = 0;
        for (Integer j = i; j < values.size(); j += seasonLength) {
            sum += values[j];
            count++;
        }
        Decimal avg = (count > 0) ? sum / count : 0;
        seasonals.add(avg);
    }
    return seasonals;
}


// Forecast result structure
public class ForecastResult {
    @AuraEnabled public List<String> forecastMonths;
    @AuraEnabled public List<Decimal> forecastValues;
}

// new 
@AuraEnabled
public static Map<String, Object> getHistoricalDemandData(Id productId, String dummyYear) {
    //System.debug('OrgId -> ' + OrgId + ' | productId -> ' + productId);
    // If(OrgId == null || orgId == ''){
    //     throw new AuraHandledException('Organisation ID is required.');
    // }
    Date endDate = Date.today();
    Date startDate = endDate.addYears(-3); // Last 3 years

    List<AggregateResult> results = [
        SELECT CALENDAR_YEAR(Order.EffectiveDate) yr,
               CALENDAR_MONTH(Order.EffectiveDate) mon,
               SUM(Quantity) qty
        FROM OrderItem
        WHERE Product2Id = :productId
        AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
        AND Order.EffectiveDate >= :startDate AND Order.EffectiveDate <= :endDate
        GROUP BY CALENDAR_YEAR(Order.EffectiveDate), CALENDAR_MONTH(Order.EffectiveDate)
        ORDER BY CALENDAR_YEAR(Order.EffectiveDate), CALENDAR_MONTH(Order.EffectiveDate)
    ];
System.debug('fetched');
    Map<String, Decimal> demandMap = new Map<String, Decimal>();
    for (AggregateResult ar : results) {
        Integer y = (Integer)ar.get('yr');
        Integer m = (Integer)ar.get('mon');
        String label = getMonthLabel(m) + ' ' + y;
        Decimal qty = (Decimal)ar.get('qty');
        demandMap.put(label, qty.setScale(2));
    }

    List<String> monthLabels = new List<String>();
    List<Decimal> demandValues = new List<Decimal>();

    Date d = startDate.toStartOfMonth();
    while (d <= endDate) {
        String label = getMonthLabel(d.month()) + ' ' + d.year();
        monthLabels.add(label);
        demandValues.add(demandMap.containsKey(label) ? demandMap.get(label) : 0);
        d = d.addMonths(1);
    }

    Map<String, Object> result = new Map<String, Object>();
    result.put('historicalMonths', monthLabels);
    result.put('historicalValues', demandValues);
    return result;
}
@AuraEnabled
public static ForecastResult generateForecastFromHistorical(List<Decimal> historicalValues, String modelName) {
    Integer forecastMonths = 6;
    Integer seasonLength = 12;

    if (modelName == 'HOLT_WINTERS') {
        if (historicalValues.size() < seasonLength * 2) {
            throw new AuraHandledException('Not enough data for Holt-Winters.');
        }
        return runHoltWintersForecast(historicalValues, forecastMonths, seasonLength);
    } else if (modelName == 'MOVING_AVERAGE') {
        return runMovingAverageForecast(historicalValues, forecastMonths);
    }

    throw new AuraHandledException('Unsupported model: ' + modelName);
}

private static ForecastResult runHoltWintersForecast(List<Decimal> values, Integer m, Integer seasonLength) {
    Decimal alpha = 0.5;
    Decimal beta = 0.3;
    Decimal gamma = 0.2;

    Integer len = values.size();
    if (len < seasonLength * 2) {
        throw new AuraHandledException('Not enough data for Holt-Winters.');
    }

    List<Decimal> level = new List<Decimal>{ values[0] };
    List<Decimal> trend = new List<Decimal>{ values[1] - values[0] };
    List<Decimal> seasonals = initSeasonals(values, seasonLength);

    for (Integer i = 1; i < len; i++) {
        Decimal lastLevel = level[i - 1];
        Decimal lastTrend = trend[i - 1];
        Integer sIndex = Math.mod(i, seasonLength);
        Decimal seasonal = seasonals[sIndex];
        Decimal current = values[i];

        Decimal newLevel = alpha * (current - seasonal) + (1 - alpha) * (lastLevel + lastTrend);
        Decimal newTrend = beta * (newLevel - lastLevel) + (1 - beta) * lastTrend;
        Decimal newSeasonal = gamma * (current - newLevel) + (1 - gamma) * seasonal;

        level.add(newLevel);
        trend.add(newTrend);
        seasonals[sIndex] = newSeasonal;
    }

    ForecastResult result = new ForecastResult();
    result.forecastMonths = new List<String>();
    result.forecastValues = new List<Decimal>();

    Date today = Date.today();
    for (Integer i = 1; i <= m; i++) {
        Decimal l = level[len - 1];
        Decimal t = trend[len - 1];
        Integer sIndex = Math.mod(len + i - 1, seasonLength);
        Decimal s = seasonals[sIndex];
        Decimal f = l + (i * t) + s;
        result.forecastValues.add(Math.max(f, 0).setScale(2));

        Date monthDate = today.addMonths(i);
        result.forecastMonths.add(getMonthLabel(monthDate.month()) + ' ' + monthDate.year());
    }

    return result;
}
private static ForecastResult runMovingAverageForecast(List<Decimal> inputValues, Integer forecastMonths) {
    Integer window = 12;

    ForecastResult result = new ForecastResult();
    result.forecastValues = new List<Decimal>();
    result.forecastMonths = new List<String>();

    // Clone values to avoid mutating original list
    List<Decimal> values = new List<Decimal>(inputValues);

    Date baseMonth = Date.today();

    for (Integer i = 0; i < forecastMonths; i++) {
        Decimal sum = 0;
        Integer count = 0;

        for (Integer j = values.size() - window; j < values.size(); j++) {
            if (j >= 0) {
                sum += values[j];
                count++;
            }
        }

        Decimal avg = (count > 0) ? (sum / count).setScale(2) : 0;
        values.add(avg); // Extend forecast base

        Date forecastMonth = baseMonth.addMonths(i + 1);
        String label = getMonthLabel(forecastMonth.month()) + ' ' + forecastMonth.year();

        result.forecastMonths.add(label);
        result.forecastValues.add(avg);
    }

    return result;
}

@AuraEnabled(cacheable=true)
public static Map<String, Object> getDemandForecastWithHistory(Id productId, String modelName) {
    System.debug('getDemandForecastWithHistory called for productId: ' + productId + ', modelName: ' + modelName);
    Map<String, Object> history = getHistoricalDemandData(productId, ''); // will ignore this year filter for now
    List<Decimal> demandValues = (List<Decimal>) history.get('historicalValues');

    ForecastResult forecast;

    if (modelName == 'MOVING_AVERAGE') {
        forecast = runMovingAverageForecast(demandValues, 6);
    } else {
        // Default to Holt-Winters
        forecast = runHoltWintersForecast(demandValues, 6, 12);
    }

    history.put('forecastMonths', forecast.forecastMonths);
    history.put('forecastValues', forecast.forecastValues);

    return history;
}


}