public with sharing class supplyPlanningController {
   // supply demand based on months
/*   

@AuraEnabled(cacheable=true)
public static List<MonthlySupplyDemandWrapper> getMonthlySupplyDemand(
    String productId,
    Id organisationId,
    Date fromDate,
    Date toDate
) {
    System.debug('📦 Fetching monthly supply & demand for productId: ' + productId);
    System.debug('📅 From: ' + fromDate + ' To: ' + toDate);

    List<MonthlySupplyDemandWrapper> results = new List<MonthlySupplyDemandWrapper>();

    for (AggregateResult ar : [
        SELECT
            FISCAL_MONTH(OrderItem.CreatedDate) monthNum,
            SUM(Quantity) totalDemand,
            SUM(ERP7__Shipped_Quantity__c) totalSupply
        FROM OrderItem
        WHERE Product2Id = :productId 
            AND Order.Status = 'Activated'
            AND Order.ERP7__Organisation__c = :organisationId
            AND OrderItem.CreatedDate >= :fromDate
            AND OrderItem.CreatedDate <= :toDate
        GROUP BY FISCAL_MONTH(OrderItem.CreatedDate)
        ORDER BY FISCAL_MONTH(OrderItem.CreatedDate)
    ]) {
        Integer month = (Integer) ar.get('monthNum');
        Decimal demand = (Decimal) ar.get('totalDemand');
        Decimal supply = (Decimal) ar.get('totalSupply');

        System.debug('📊 Fiscal Month: ' + month + ', Demand: ' + demand + ', Supply: ' + supply);

        results.add(new MonthlySupplyDemandWrapper(month, demand, supply));
    }

    System.debug('✅ Total records returned: ' + results.size());
    return results;
}

    
    public class MonthlySupplyDemandWrapper {
        @AuraEnabled public Integer month;
        @AuraEnabled public Decimal totalDemand;
        @AuraEnabled public Decimal totalSupply;
    
        public MonthlySupplyDemandWrapper(Integer month, Decimal demand, Decimal supply) {
            this.month = month;
            this.totalDemand = demand;
            this.totalSupply = supply;
        }
    }

    

    
    //for top 5 supply and demand
    
    /*───────────────────────────────────────────────────────────────
     // Add this inside the SAME class that already has
    // getMonthlySupplyDemand and MonthlySupplyDemandWrapper.
     //──────────────────────────────────────────────────────────────
    @AuraEnabled(cacheable=true)
public static List<ProductSupplyDemandSummary> getTop5SupplyAndDemand(
    Id organisationId,
    Date fromDate,
    Date toDate
) {
    List<ProductSupplyDemandSummary> results = new List<ProductSupplyDemandSummary>();

    // -------- TOP 5 by DEMAND --------
    for (AggregateResult ar : [
        SELECT Product2Id                      pId,
               Product2.Name                   pName,
               SUM(Quantity)                  qDemand,
               SUM(ERP7__Shipped_Quantity__c) qSupply
        FROM   OrderItem
        WHERE  Order.Status = 'Activated'
        AND    CreatedDate >= :fromDate
        AND    CreatedDate <= :toDate
        AND    Order.ERP7__Organisation__c = :organisationId
        GROUP  BY Product2Id, Product2.Name
        ORDER  BY SUM(Quantity) DESC
        LIMIT  5
    ]) {
        results.add(new ProductSupplyDemandSummary(
            (Id)      ar.get('pId'),
            (String)  ar.get('pName'),
            (Decimal) ar.get('qDemand'),
            (Decimal) ar.get('qSupply'),
            'Demand'
        ));
    }

    // -------- TOP 5 by SUPPLY --------
    for (AggregateResult ar : [
        SELECT Product2Id                      pId,
               Product2.Name                   pName,
               SUM(Quantity)                  qDemand,
               SUM(ERP7__Shipped_Quantity__c) qSupply
        FROM   OrderItem
        WHERE  Order.Status = 'Activated'
        AND    CreatedDate >= :fromDate
        AND    CreatedDate <= :toDate
        AND    Order.ERP7__Organisation__c = :organisationId
        GROUP  BY Product2Id, Product2.Name
        ORDER  BY SUM(ERP7__Shipped_Quantity__c) DESC
        LIMIT  5
    ]) {
        results.add(new ProductSupplyDemandSummary(
            (Id)      ar.get('pId'),
            (String)  ar.get('pName'),
            (Decimal) ar.get('qDemand'),
            (Decimal) ar.get('qSupply'),
            'Supply'
        ));
    }

    return results;
}

    /*───────────────────────────────────────────────
     *  Re‑use / extend the wrapper you already had
     *  (keep it INSIDE the same Apex class)
     *──────────────────────────────────────────────
    public class ProductSupplyDemandSummary {
        @AuraEnabled public Id      productId;
        @AuraEnabled public String  productName;
        @AuraEnabled public Decimal totalDemand;
        @AuraEnabled public Decimal totalSupply;
        @AuraEnabled public String  rankingType;   // 'Demand' or 'Supply'
    
        public ProductSupplyDemandSummary(
                Id productId, String productName,
                Decimal demand, Decimal supply,
                String rankingType) {
            this.productId   = productId;
            this.productName = productName;
            this.totalDemand = demand;
            this.totalSupply = supply;
            this.rankingType = rankingType;
        }
    }
    
    //Country supply demand for the top 5 countries
@AuraEnabled(cacheable=true)
public static List<Top5CountrySupplyDemandWrapper> getTop5CountrySupplyDemand(
    Id organisationId,
    Date fromDate,
    Date toDate
) {
    List<Top5CountrySupplyDemandWrapper> results = new List<Top5CountrySupplyDemandWrapper>();

    // 🔄 Fetch OrderItems within date range
    List<OrderItem> orderItems = [
        SELECT Quantity, ERP7__Shipped_Quantity__c,
               Order.AccountId, Order.ERP7__Contact__c
        FROM OrderItem
        WHERE Order.Status = 'Activated'
          AND Order.ERP7__Organisation__c = :organisationId
          AND CreatedDate >= :fromDate
          AND CreatedDate <= :toDate
    ];

    Set<Id> accountIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();

    for (OrderItem oi : orderItems) {
        if (oi.Order.AccountId != null) accountIds.add(oi.Order.AccountId);
        if (oi.Order.ERP7__Contact__c != null) contactIds.add(oi.Order.ERP7__Contact__c);
    }

    // 📦 Get shipping address country mapping
    Map<String, String> accountContactToCountry = new Map<String, String>();
    for (ERP7__Address__c addr : [
        SELECT ERP7__Customer__c, ERP7__Contact__c, ERP7__Country__c, ERP7__Is_Shipping_Address__c
        FROM ERP7__Address__c
        WHERE ERP7__Customer__c IN :accountIds
          AND ERP7__Contact__c != NULL
          AND ERP7__Country__c != NULL
          AND ERP7__Is_Shipping_Address__c = true
    ]) {
        String key = String.valueOf(addr.ERP7__Customer__c) + ':' + String.valueOf(addr.ERP7__Contact__c);
        accountContactToCountry.put(key, addr.ERP7__Country__c);
    }

    // 📊 Aggregate demand & supply per country
    Map<String, Decimal> demandMap = new Map<String, Decimal>();
    Map<String, Decimal> supplyMap = new Map<String, Decimal>();

    for (OrderItem oi : orderItems) {
        if (oi.Order.ERP7__Contact__c == null) continue;

        String key = String.valueOf(oi.Order.AccountId) + ':' + String.valueOf(oi.Order.ERP7__Contact__c);
        if (!accountContactToCountry.containsKey(key)) continue;

        String country = accountContactToCountry.get(key);
        Decimal currentDemand = demandMap.containsKey(country) ? demandMap.get(country) : 0;
        Decimal currentSupply = supplyMap.containsKey(country) ? supplyMap.get(country) : 0;

        demandMap.put(country, currentDemand + oi.Quantity);
        supplyMap.put(country, currentSupply + (oi.ERP7__Shipped_Quantity__c != null ? oi.ERP7__Shipped_Quantity__c : 0));
    }

    for (String country : demandMap.keySet()) {
        results.add(new Top5CountrySupplyDemandWrapper(
            country,
            demandMap.get(country),
            supplyMap.get(country)
        ));
    }

    results.sort(new Top5CountryDemandComparator());
    
        List<Top5CountrySupplyDemandWrapper> topResults;

        if (results.size() > 5) {
            topResults = new List<Top5CountrySupplyDemandWrapper>();
            for (Integer i = 0; i < 5; i++) {
                topResults.add(results[i]);
            }
        } else {
            topResults = results;
        }
        
        return topResults;
    }
    
    public class Top5CountrySupplyDemandWrapper {
        @AuraEnabled public String country;
        @AuraEnabled public Decimal totalDemand;
        @AuraEnabled public Decimal totalSupply;
    
        public Top5CountrySupplyDemandWrapper(String country, Decimal demand, Decimal supply) {
            this.country = country;
            this.totalDemand = demand;
            this.totalSupply = supply;
        }
    }
    
    public class Top5CountryDemandComparator implements Comparator<Top5CountrySupplyDemandWrapper> {
        public Integer compare(Top5CountrySupplyDemandWrapper a, Top5CountrySupplyDemandWrapper b) {
            if (a.totalDemand > b.totalDemand) return -1;
            if (a.totalDemand < b.totalDemand) return 1;
            return 0;
        }
    }

    //Country Supply demand
    @AuraEnabled(cacheable=false)
public static List<CountrySupplyDemandWrapper> getSupplyDemandByCountry(
    Id productId,
    Id organisationId,
    Date fromDate,
    Date toDate
) {
    List<CountrySupplyDemandWrapper> results = new List<CountrySupplyDemandWrapper>();

    // Step 1: Get relevant OrderItems
    List<OrderItem> orderItems = [
        SELECT Quantity, ERP7__Shipped_Quantity__c,
               Order.AccountId, Order.ERP7__Contact__c
        FROM OrderItem
        WHERE Product2Id = :productId
          AND Order.Status = 'Activated'
          AND Order.ERP7__Organisation__c = :organisationId
          AND CreatedDate >= :fromDate
          AND CreatedDate <= :toDate
    ];

    Set<Id> accountIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();

    for (OrderItem oi : orderItems) {
        if (oi.Order.AccountId != null) accountIds.add(oi.Order.AccountId);
        if (oi.Order.ERP7__Contact__c != null) contactIds.add(oi.Order.ERP7__Contact__c);
    }

    // Step 3: Fetch matching shipping addresses with country info
    Map<String, String> accountContactKeyToCountry = new Map<String, String>();

    for (ERP7__Address__c addr : [
        SELECT ERP7__Customer__c, ERP7__Contact__c, ERP7__Country__c, ERP7__Is_Shipping_Address__c
        FROM ERP7__Address__c
        WHERE ERP7__Customer__c IN :accountIds
          AND ERP7__Contact__c != NULL
          AND ERP7__Country__c != NULL
          AND ERP7__Is_Shipping_Address__c = true
    ]) {
        String key = String.valueOf(addr.ERP7__Customer__c) + ':' + String.valueOf(addr.ERP7__Contact__c);
        accountContactKeyToCountry.put(key, addr.ERP7__Country__c);
    }

    Map<String, Decimal> demandMap = new Map<String, Decimal>();
    Map<String, Decimal> supplyMap = new Map<String, Decimal>();

    for (OrderItem oi : orderItems) {
        if (oi.Order.ERP7__Contact__c == null) continue;

        String key = String.valueOf(oi.Order.AccountId) + ':' + String.valueOf(oi.Order.ERP7__Contact__c);
        if (!accountContactKeyToCountry.containsKey(key)) continue;

        String country = accountContactKeyToCountry.get(key);
        Decimal currentDemand = demandMap.containsKey(country) ? demandMap.get(country) : 0;
        Decimal currentSupply = supplyMap.containsKey(country) ? supplyMap.get(country) : 0;

        demandMap.put(country, currentDemand + oi.Quantity);
        supplyMap.put(country, currentSupply + (oi.ERP7__Shipped_Quantity__c != null ? oi.ERP7__Shipped_Quantity__c : 0));
    }

    for (String country : demandMap.keySet()) {
        results.add(new CountrySupplyDemandWrapper(
            country,
            demandMap.get(country),
            supplyMap.get(country)
        ));
    }

    return results;
}

    public class CountrySupplyDemandWrapper {
        @AuraEnabled public String country;
        @AuraEnabled public Decimal totalDemand;
        @AuraEnabled public Decimal totalSupply;
    
        public CountrySupplyDemandWrapper(String country, Decimal demand, Decimal supply) {
            this.country = country;
            this.totalDemand = demand;
            this.totalSupply = supply;
        }
    }


    // SupplierScorecardController 
                @AuraEnabled(cacheable=true)
public static Map<String, String> getDefaultTopVendor(Id organisationId, Integer year) {
    Map<String, String> result = new Map<String, String>();
    if (organisationId == null || year == null) return result;

    // Step 1: Find vendors with Paid Payments
    Set<Id> vendorsWithSpend = new Set<Id>();
    for (AggregateResult ar : [
        SELECT ERP7__Accounts__c accId
        FROM ERP7__Payment__c
        WHERE ERP7__Status__c = 'Paid'
          AND ERP7__Account__c = :organisationId
          AND ERP7__Accounts__c != null
          AND FISCAL_YEAR(CreatedDate) = :year
        GROUP BY ERP7__Accounts__c
    ]) {
        vendorsWithSpend.add((Id) ar.get('accId'));
    }

    // Step 2: Find vendors with POs in fiscal year
    Set<Id> vendorsWithPO = new Set<Id>();
    for (AggregateResult ar : [
        SELECT ERP7__Vendor__c vendorId
        FROM ERP7__PO__c
        WHERE ERP7__Order_Date__c != null
          AND FISCAL_YEAR(ERP7__Order_Date__c) = :year
        GROUP BY ERP7__Vendor__c
    ]) {
        vendorsWithPO.add((Id) ar.get('vendorId'));
    }

    // Step 3: Find vendors with Stock Inward Line Items (quality)
    Set<Id> vendorsWithQuality = new Set<Id>();
    for (AggregateResult ar : [
        SELECT ERP7__Purchase_Orders__r.ERP7__Vendor__c vendorId
        FROM ERP7__Stock_Inward_Line_Item__c
        WHERE ERP7__Purchase_Orders__r.ERP7__Vendor__c != null
          AND FISCAL_YEAR(CreatedDate) = :year
        GROUP BY ERP7__Purchase_Orders__r.ERP7__Vendor__c
    ]) {
        vendorsWithQuality.add((Id) ar.get('vendorId'));
    }

    // Step 4: Intersection of all 3
    Set<Id> eligibleVendors = new Set<Id>();
    for (Id vId : vendorsWithSpend) {
        if (vendorsWithPO.contains(vId) && vendorsWithQuality.contains(vId)) {
            eligibleVendors.add(vId);
        }
    }

    // Step 5: Pick the top vendor by spend
    if (!eligibleVendors.isEmpty()) {
        List<AggregateResult> topVendor = [
            SELECT ERP7__Accounts__c accId, MAX(ERP7__Accounts__r.Name) accName, SUM(ERP7__Amount__c) total
            FROM ERP7__Payment__c
            WHERE ERP7__Status__c = 'Paid'
              AND ERP7__Account__c = :organisationId
              AND ERP7__Accounts__c IN :eligibleVendors
              AND FISCAL_YEAR(CreatedDate) = :year
            GROUP BY ERP7__Accounts__c
            ORDER BY  SUM(ERP7__Amount__c) DESC
            LIMIT 1
        ];

        if (!topVendor.isEmpty()) {
            result.put('Id', (String) topVendor[0].get('accId'));
            result.put('Name', (String) topVendor[0].get('accName'));
        }
    }

    return result;
}

    
    //spend over time real data

    @AuraEnabled(cacheable=true)
public static String getCurrencySymbol() {
    Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
    String currencyISO;
    Decimal currencyRate;
    String userIsoCode;

    if (UserInfo.getDefaultCurrency() != null) {
        currencyISO = UserInfo.getDefaultCurrency();
    } else {
        currencyISO = 'USD'; // Fallback
    }

    if (multiCurrencyEnabled) {
        String q = 'SELECT IsoCode, conversionRate FROM CurrencyType WHERE IsoCode = :currencyISO';
        currencyRate = (Decimal) Database.query(q)[0].get('conversionRate');
    } else {
        currencyRate = 1;
    }

    Map<String, String> symbolMap = new Map<String, String>{
        'USD' => '$',
        'GBP' => '£',
        'EUR' => '€',
        'JPY' => '¥',
        'INR' => '₹',
        'CNY' => '¥',
        'AUD' => 'A$',
        'CAD' => 'C$'
    };

    return symbolMap.containsKey(currencyISO) ? symbolMap.get(currencyISO) : currencyISO;
}

                @AuraEnabled(cacheable=true)
                public static List<Map<String, Object>> getSpendOverTime(Id vendorId, Id organisationId, Integer year) {
                List<Map<String, Object>> result = new List<Map<String, Object>>();
    
                    if (vendorId == null || organisationId == null || year == null) {
                return result;
            }
            try {
                // Query payments by vendor, org, year with filters
                List<AggregateResult> monthlyTotals = [
                    SELECT CALENDAR_MONTH(CreatedDate) month,
                        SUM(ERP7__Amount__c) total
                    FROM ERP7__Payment__c
                    WHERE ERP7__Accounts__c = :vendorId
                    AND ERP7__Status__c = 'Paid'
                    AND ERP7__Purchase_Orders__c != null
                    AND ERP7__Bill__c != null
                    AND ERP7__Account__c = :organisationId
                    AND CALENDAR_YEAR(CreatedDate) = :year
                    GROUP BY CALENDAR_MONTH(CreatedDate)
                    ORDER BY CALENDAR_MONTH(CreatedDate)
                ];
    
                // Month names
                List<String> monthNames = new List<String>{
                    'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'
                };
    
                // Build result list
                for (AggregateResult ar : monthlyTotals) {
                    Integer monthIndex = (Integer) ar.get('month') - 1;
                    result.add(new Map<String, Object>{
                        'month' => monthNames[monthIndex],
                        'amount' => (Decimal) ar.get('total')
                    });
                }
    
            } catch (Exception e) {
                System.debug('❌ Error in getSpendOverTime: ' + e.getMessage());
    
                // Still return dummy if exception occurs
                List<String> monthNames = new List<String>{
                    'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'
                };
                for (Integer i = 0; i < 12; i++) {
                    result.add(new Map<String, Object>{
                        'month' => monthNames[i],
                        'amount' => Math.mod((i + 1) * 2500 + 1000, 30000)
                    });
                }
            }
            return result;
        }

// ontime delivery
                @AuraEnabled(cacheable=true)
                public static List<Map<String, Object>> getOnTimeDeliveryMapped(Id vendorId, Id organisationId, Integer year) {
                    List<Map<String, Object>> results = new List<Map<String, Object>>();
                    System.debug('==== Method Invoked ====');
                    System.debug('Vendor Id: ' + vendorId);
                    System.debug('Year: ' + year);
    
                    if (vendorId == null || year == null) {
                        System.debug('Vendor ID or Year is null. Returning empty result.');
                        return results;
                    }
    
                    // Get relevant POs
                    Map<Id, ERP7__PO__c> poMap = new Map<Id, ERP7__PO__c>();
                    List<ERP7__PO__c> pos = [
                        SELECT Id, Name,
                            ERP7__Expected_Date__c,
                            ERP7__Order_Date__c
                        FROM ERP7__PO__c
                        WHERE ERP7__Vendor__c = :vendorId
                        AND ERP7__Order_Date__c != null
                        AND CALENDAR_YEAR(ERP7__Order_Date__c) = :year
                    ];
    
                    for (ERP7__PO__c po : pos) {
                        poMap.put(po.Id, po);
                    }
    
                    if (poMap.isEmpty()) {
                        return results;
                    }
    
                    // Fetch related Stock Inward Line Items
                    List<ERP7__Stock_Inward_Line_Item__c> lineItems = [
                        SELECT ERP7__Received_Month__c, ERP7__Purchase_Orders__c
                        FROM ERP7__Stock_Inward_Line_Item__c
                        WHERE ERP7__Purchase_Orders__c IN :poMap.keySet()
                        AND ERP7__Received_Month__c != null
                    ];
    
                    // Group delivery status by month
                    Map<String, Map<String, Integer>> monthSummary = new Map<String, Map<String, Integer>>();
    
                    for (ERP7__Stock_Inward_Line_Item__c item : lineItems) {
                        ERP7__PO__c po = poMap.get(item.ERP7__Purchase_Orders__c);
                        if (po == null || po.ERP7__Expected_Date__c == null) continue;
    
                        String expectedMonth = po.ERP7__Expected_Date__c.format().substring(0, 7); // 'YYYY-MM'
                        String receivedMonth = item.ERP7__Received_Month__c;
                        Boolean isOnTime = receivedMonth.compareTo(expectedMonth) <= 0;
    
                        // Group by receivedMonth (not expectedMonth), adjust if needed
                        String keyMonth = receivedMonth;
    
                        if (!monthSummary.containsKey(keyMonth)) {
                            monthSummary.put(keyMonth, new Map<String, Integer>{
                                'onTime' => 0,
                                'late' => 0
                            });
                        }
    
                        if (isOnTime) {
                            monthSummary.get(keyMonth).put('onTime', monthSummary.get(keyMonth).get('onTime') + 1);
                        } else {
                            monthSummary.get(keyMonth).put('late', monthSummary.get(keyMonth).get('late') + 1);
                        }
                    }
    
                    // Convert to List<Map<String, Object>> format
                    for (String month : monthSummary.keySet()) {
                        Map<String, Integer> counts = monthSummary.get(month);
                        results.add(new Map<String, Object>{
                            'month' => month,
                            'onTime' => counts.get('onTime'),
                            'late' => counts.get('late')
                        });
                    }
    
                    return results;
                }
    //Quality analysis
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, Integer>> getMonthlyQualityData(Id vendorId, Id organisationId, Integer year) {
        Map<String, Map<String, Integer>> result = new Map<String, Map<String, Integer>>();
    
        // Initialize map with all 12 months
        for (Integer i = 1; i <= 12; i++) {
            result.put(String.valueOf(i), new Map<String, Integer>{
                'good' => 0,
                'bad' => 0
            });
        }
    
        // ✅ Dynamically use selected year to create range
        Date startDate = Date.newInstance(year, 1, 1);
        Date endDate = Date.newInstance(year, 12, 31);
    
        List<ERP7__Stock_Inward_Line_Item__c> lineItems = [
            SELECT Name,
                   CreatedDate,
                   ERP7__Status__c,
                   ERP7__Purchase_Orders__r.ERP7__Vendor__c,
                   ERP7__Purchase_Orders__r.ERP7__Vendor_Contact__c,
                   ERP7__Purchase_Orders__r.ERP7__Active__c
            FROM ERP7__Stock_Inward_Line_Item__c
            WHERE Name != 'Awaiting stock'
              AND ERP7__Status__c IN ('In Stock', 'Committed', 'Rejected')
              AND ERP7__Purchase_Orders__r.ERP7__Active__c = true
              AND ERP7__Purchase_Orders__r.ERP7__Vendor__c = :vendorId
              AND CreatedDate >= :startDate
              AND CreatedDate <= :endDate
        ];
    
        for (ERP7__Stock_Inward_Line_Item__c item : lineItems) {
            Integer month = item.CreatedDate.month();
            String status = item.ERP7__Status__c;
    
            if (status == 'Rejected') {
                result.get(String.valueOf(month)).put('bad', result.get(String.valueOf(month)).get('bad') + 1);
            } else if (status == 'In Stock' || status == 'Committed') {
                result.get(String.valueOf(month)).put('good', result.get(String.valueOf(month)).get('good') + 1);
            }
        }
    
        return result;
    }
    
    

    // Wrapper class defined outside any method in a graph
    public class InventorySummaryWrapper {
        @AuraEnabled public Decimal totalExpectedRaw = 0;
        @AuraEnabled public Decimal totalConsumedRaw = 0;
        @AuraEnabled public Decimal totalScrappedRaw = 0;
    
        @AuraEnabled public Decimal totalWipQuantity = 0;
        @AuraEnabled public Decimal totalWipScrapped = 0;
    
        @AuraEnabled public Decimal totalFinishedRequested = 0;
        @AuraEnabled public Decimal totalFinishedInStock = 0;
        @AuraEnabled public Decimal totalFinishedScrapped = 0;
        @AuraEnabled public Decimal totalFinishedScrap = 0;
    }
    
    // based on the product name filter date from to date

        @AuraEnabled
        public static InventorySummaryWrapper getSummedInventory(Id productId, Date fromDate, Date toDate, Id organizationId) {
            // Fallback to current fiscal year (assume FY starts in April)
                System.debug('📨 Apex called with Product: ' + productId + ', From: ' + fromDate + ', To: ' + toDate);

            if (fromDate == null || toDate == null) {
                Date today = Date.today();
                Integer fiscalYearStartMonth = 4; // April
                Integer year = today.month() >= fiscalYearStartMonth ? today.year() : today.year() - 1;
                fromDate = Date.newInstance(year, fiscalYearStartMonth, 1);
                toDate = fromDate.addMonths(12).addDays(-1);
            }
    
            // Get Manufacturing Orders by product and date range
            List<ERP7__Manufacturing_Order__c> moList;
            if (productId != null) {
            moList = [
                SELECT Id FROM ERP7__Manufacturing_Order__c
                WHERE ERP7__Product__c = :productId
                AND CreatedDate >= :fromDate AND CreatedDate <= :toDate
            ];
        } else {
            moList = [
                SELECT Id FROM ERP7__Manufacturing_Order__c
                WHERE CreatedDate >= :fromDate AND CreatedDate <= :toDate
            ];
        }
    
            Set<Id> moIds = new Set<Id>();
            for (ERP7__Manufacturing_Order__c mo : moList) {
                moIds.add(mo.Id);
            }
    
            InventorySummaryWrapper summary = new InventorySummaryWrapper();
    
            // RAW
            for (ERP7__MRP__c rec : [
                SELECT ERP7__Expected_Quantity__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c
                FROM ERP7__MRP__c WHERE ERP7__MO__c IN :moIds
            ]) {
                summary.totalExpectedRaw += rec.ERP7__Expected_Quantity__c != null ? rec.ERP7__Expected_Quantity__c : 0;
                summary.totalConsumedRaw += rec.ERP7__Consumed_Quantity__c != null ? rec.ERP7__Consumed_Quantity__c : 0;
                summary.totalScrappedRaw += rec.ERP7__Scrapped_Quantity__c != null ? rec.ERP7__Scrapped_Quantity__c : 0;
            }
    
            // WIP
            for (ERP7__WIP__c rec : [
                SELECT ERP7__Quantity__c, ERP7__Scrapped_Quantity__c
                FROM ERP7__WIP__c WHERE ERP7__MO__c IN :moIds
            ]) {
                summary.totalWipQuantity += rec.ERP7__Quantity__c != null ? rec.ERP7__Quantity__c : 0;
                summary.totalWipScrapped += rec.ERP7__Scrapped_Quantity__c != null ? rec.ERP7__Scrapped_Quantity__c : 0;
            }
    
            // Finished
            for (ERP7__Inventory_Stock__c rec : [
                SELECT ERP7__No_of_Items_Requested__c, ERP7__Number_of_Item_In_Stock__c,
                       ERP7__Number_of_Items_Scrapped__c, ERP7__Scrap__c
                FROM ERP7__Inventory_Stock__c WHERE ERP7__Manufacturing_Order__c IN :moIds
            ]) {
                summary.totalFinishedRequested += rec.ERP7__No_of_Items_Requested__c != null ? rec.ERP7__No_of_Items_Requested__c : 0;
                summary.totalFinishedInStock += rec.ERP7__Number_of_Item_In_Stock__c != null ? rec.ERP7__Number_of_Item_In_Stock__c : 0;
                summary.totalFinishedScrapped += rec.ERP7__Number_of_Items_Scrapped__c != null ? rec.ERP7__Number_of_Items_Scrapped__c : 0;
                // summary.totalFinishedScrap += rec.ERP7__Scrap__c != null ? rec.ERP7__Scrap__c : 0;
            }
    
            return summary;
        }
        
        
    // based on the top 5 product name filter date from to date
public class Top5InventorySummaryWrapper implements Comparable {
    @AuraEnabled public Id productId;
    @AuraEnabled public String productName;

    @AuraEnabled public Decimal totalExpectedRaw = 0;
    @AuraEnabled public Decimal totalConsumedRaw = 0;
    @AuraEnabled public Decimal totalScrappedRaw = 0;

    @AuraEnabled public Decimal totalWipQuantity = 0;
    @AuraEnabled public Decimal totalWipScrapped = 0;

    @AuraEnabled public Decimal totalFinishedRequested = 0;
    @AuraEnabled public Decimal totalFinishedInStock = 0;
    @AuraEnabled public Decimal totalFinishedScrapped = 0;
    @AuraEnabled public Decimal totalFinishedScrap = 0;

    @AuraEnabled public Decimal totalAll = 0;
    public Integer compareTo(Object other) {
    Top5InventorySummaryWrapper o = (Top5InventorySummaryWrapper) other;
    Decimal diff = o.totalAll - this.totalAll;
    if (diff > 0) return 1;
    if (diff < 0) return -1;
    return 0;
}
}


   @AuraEnabled
public static List<Top5InventorySummaryWrapper> getTop5Inventory() {
    // Get fiscal year start and end from org settings
    Organization orgInfo = [SELECT FiscalYearStartMonth FROM Organization LIMIT 1];
    Integer startMonth = orgInfo.FiscalYearStartMonth;
    Date today = Date.today();
    Integer year = today.month() >= startMonth ? today.year() : today.year() - 1;
    Date fromDate = Date.newInstance(year, startMonth, 1);
    Date toDate = fromDate.addMonths(12).addDays(-1);

    // Get MOs within fiscal year
    List<ERP7__Manufacturing_Order__c> mos = [
        SELECT Id, ERP7__Product__c, ERP7__Product__r.Name
        FROM ERP7__Manufacturing_Order__c
        WHERE CreatedDate >= :fromDate AND CreatedDate <= :toDate
              AND ERP7__Product__c != null
    ];

    Map<Id, Top5InventorySummaryWrapper> productSummaryMap = new Map<Id, Top5InventorySummaryWrapper>();
    Set<Id> moIds = new Set<Id>();
    Map<Id, Id> moToProductMap = new Map<Id, Id>();

    for (ERP7__Manufacturing_Order__c mo : mos) {
        moIds.add(mo.Id);
        moToProductMap.put(mo.Id, mo.ERP7__Product__c);
        if (!productSummaryMap.containsKey(mo.ERP7__Product__c)) {
            Top5InventorySummaryWrapper wrap = new Top5InventorySummaryWrapper();
            wrap.productId = mo.ERP7__Product__c;
            wrap.productName = mo.ERP7__Product__r.Name;
            productSummaryMap.put(mo.ERP7__Product__c, wrap);
        }
    }

    // RAW
    for (ERP7__MRP__c rec : [
        SELECT ERP7__MO__c, ERP7__Expected_Quantity__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c
        FROM ERP7__MRP__c WHERE ERP7__MO__c IN :moIds
    ]) {
        Id productId = moToProductMap.get(rec.ERP7__MO__c);
        if (productSummaryMap.containsKey(productId)) {
            Top5InventorySummaryWrapper wrap = productSummaryMap.get(productId);
            wrap.totalExpectedRaw += rec.ERP7__Expected_Quantity__c != null ? rec.ERP7__Expected_Quantity__c : 0;
            wrap.totalConsumedRaw += rec.ERP7__Consumed_Quantity__c != null ? rec.ERP7__Consumed_Quantity__c : 0;
            wrap.totalScrappedRaw += rec.ERP7__Scrapped_Quantity__c != null ? rec.ERP7__Scrapped_Quantity__c : 0;
        }
    }

    // WIP
    for (ERP7__WIP__c rec : [
        SELECT ERP7__MO__c, ERP7__Quantity__c, ERP7__Scrapped_Quantity__c
        FROM ERP7__WIP__c WHERE ERP7__MO__c IN :moIds
    ]) {
        Id productId = moToProductMap.get(rec.ERP7__MO__c);
        if (productSummaryMap.containsKey(productId)) {
            Top5InventorySummaryWrapper wrap = productSummaryMap.get(productId);
            wrap.totalWipQuantity += rec.ERP7__Quantity__c != null ? rec.ERP7__Quantity__c : 0;
            wrap.totalWipScrapped += rec.ERP7__Scrapped_Quantity__c != null ? rec.ERP7__Scrapped_Quantity__c : 0;
        }
    }

    // Finished
    for (ERP7__Inventory_Stock__c rec : [
        SELECT ERP7__Manufacturing_Order__c, ERP7__No_of_Items_Requested__c,
               ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Items_Scrapped__c, ERP7__Scrap__c
        FROM ERP7__Inventory_Stock__c
        WHERE ERP7__Manufacturing_Order__c IN :moIds
    ]) {
        Id productId = moToProductMap.get(rec.ERP7__Manufacturing_Order__c);
        if (productSummaryMap.containsKey(productId)) {
            Top5InventorySummaryWrapper wrap = productSummaryMap.get(productId);
            wrap.totalFinishedRequested += rec.ERP7__No_of_Items_Requested__c != null ? rec.ERP7__No_of_Items_Requested__c : 0;
            wrap.totalFinishedInStock += rec.ERP7__Number_of_Item_In_Stock__c != null ? rec.ERP7__Number_of_Item_In_Stock__c : 0;
            wrap.totalFinishedScrapped += rec.ERP7__Number_of_Items_Scrapped__c != null ? rec.ERP7__Number_of_Items_Scrapped__c : 0;
            // wrap.totalFinishedScrap += rec.ERP7__Scrap__c != null ? rec.ERP7__Scrap__c : 0;
        }
    }

    // Compute total and sort
    List<Top5InventorySummaryWrapper> sortedList = new List<Top5InventorySummaryWrapper>();
    for (Top5InventorySummaryWrapper wrap : productSummaryMap.values()) {
        wrap.totalAll = wrap.totalExpectedRaw + wrap.totalWipQuantity + wrap.totalFinishedInStock;
        sortedList.add(wrap);
    }

    sortedList.sort(); // Uses compareTo() defined above
List<Top5InventorySummaryWrapper> top5List = new List<Top5InventorySummaryWrapper>();

for (Integer i = 0; i < Math.min(5, sortedList.size()); i++) {
    top5List.add(sortedList[i]);
}
return top5List;
}

@AuraEnabled(cacheable=true)
public static Integer getOrgFiscalStartMonth() {
    return [SELECT FiscalYearStartMonth FROM Organization LIMIT 1].FiscalYearStartMonth;
}
    */
    }