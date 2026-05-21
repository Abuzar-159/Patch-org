public with sharing class supplyPlanningController {
   // supply demand based on months
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
            AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
            AND Order.ERP7__Organisation__c = :organisationId
            AND OrderItem.CreatedDate <= :toDate
            AND OrderItem.CreatedDate >= :fromDate
        GROUP BY FISCAL_MONTH(OrderItem.CreatedDate)
        ORDER BY FISCAL_MONTH(OrderItem.CreatedDate)
    ]) {
        Integer month = (Integer) ar.get('monthNum');  Decimal demand = (Decimal) ar.get('totalDemand');  Decimal supply = (Decimal) ar.get('totalSupply');

        System.debug('📊 Fiscal Month: ' + month + ', Demand: ' + demand + ', Supply: ' + supply);

        results.add(new MonthlySupplyDemandWrapper(month, demand, supply));
    }

    System.debug('✅ Total records returned: ' + results.size());
    return results;
}

@AuraEnabled(cacheable=true)
public static orgDetails getOrgIdFromSite(Id siteId) {
    System.debug('📦 Fetching org from site : ' + siteId);

    orgDetails result = new orgDetails();

    List<ERP7__Site__c> sites = [
        SELECT Id, ERP7__Organisation__c, ERP7__Organisation__r.Name 
        FROM ERP7__Site__c 
        WHERE Id = :siteId 
        LIMIT 1
    ];

    if (!sites.isEmpty()) {
        ERP7__Site__c site = sites[0];
        result = new orgDetails(site.ERP7__Organisation__c, site.ERP7__Organisation__r.Name);
        System.debug('✅ Org details found - ID: ' + result.orgId + ', Name: ' + result.orgName);
    } else {
        System.debug('❌ No site found with ID: ' + siteId);
    }

    return result;
}

public class orgDetails {
    @AuraEnabled public Id orgId;
    @AuraEnabled public String orgName;

    // Default constructor
    public orgDetails() {}

    // Parameterized constructor
    public orgDetails(Id orgId, String orgName) {
        this.orgId = orgId; 
        this.orgName = orgName;
    }
}
    
public class MonthlySupplyDemandWrapper {
    @AuraEnabled public Integer month;
    @AuraEnabled public Decimal totalDemand;
    @AuraEnabled public Decimal totalSupply;

    public MonthlySupplyDemandWrapper(Integer month, Decimal demand, Decimal supply) {
        this.month = month; this.totalDemand = demand; this.totalSupply = supply;
    }
}
    
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

private static String getMonthLabel(Integer monthNum) {
    if (monthNum == null || monthNum < 1 || monthNum > 12) return 'Unknown';
    List<String> monthLabels = new List<String>{
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    };
    return monthLabels[monthNum - 1];
}



// Forecast result structure
public class ForecastResult {
    @AuraEnabled public List<String> forecastMonths;
    @AuraEnabled public List<Decimal> forecastValues;
}

    @AuraEnabled
public static Map<String, Object> getHistoricalSupplyDemandData(Id productId) {
    Date endDate = Date.today();
    Date startDate = endDate.addYears(-3); // Last 3 years

    List<AggregateResult> results = [
        SELECT CALENDAR_YEAR(Order.EffectiveDate) yr,
               CALENDAR_MONTH(Order.EffectiveDate) mon,
               SUM(Quantity) qty,
               SUM(ERP7__Shipped_Quantity__c) shipped
        FROM OrderItem
        WHERE Product2Id = :productId
        AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
        AND Order.EffectiveDate >= :startDate AND Order.EffectiveDate <= :endDate
        GROUP BY CALENDAR_YEAR(Order.EffectiveDate), CALENDAR_MONTH(Order.EffectiveDate)
        ORDER BY CALENDAR_YEAR(Order.EffectiveDate), CALENDAR_MONTH(Order.EffectiveDate)
    ];

    Map<String, Decimal> demandMap = new Map<String, Decimal>();
    Map<String, Decimal> supplyMap = new Map<String, Decimal>();

    for (AggregateResult ar : results) {
        Integer y = (Integer)ar.get('yr');
        Integer m = (Integer)ar.get('mon');
        String label = getMonthLabel(m) + ' ' + y;   Decimal qty = (Decimal)ar.get('qty');   Decimal shipped = (Decimal)ar.get('shipped');
  demandMap.put(label, qty.setScale(2));  supplyMap.put(label, shipped.setScale(2));
    }

    List<String> monthLabels = new List<String>();
    List<Decimal> demandValues = new List<Decimal>();
    List<Decimal> supplyValues = new List<Decimal>();

    Date d = startDate.toStartOfMonth();
    while (d <= endDate) {
        String label = getMonthLabel(d.month()) + ' ' + d.year();
        monthLabels.add(label);
        demandValues.add(demandMap.containsKey(label) ? demandMap.get(label) : 0);
        supplyValues.add(supplyMap.containsKey(label) ? supplyMap.get(label) : 0);
        d = d.addMonths(1);
    }

    Map<String, Object> result = new Map<String, Object>();
    result.put('historicalMonths', monthLabels);
    result.put('historicalDemandValues', demandValues);
    result.put('historicalSupplyValues', supplyValues);
    return result;
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


@AuraEnabled(cacheable=true)
public static Map<String, Object> getSupplyDemandForecastWithHistory(Id productId, String modelName) {
    System.debug('🔮 Running forecast for productId: ' + productId + ' using model: ' + modelName);
    Map<String, Object> history = getHistoricalSupplyDemandData(productId);

    List<Decimal> demandValues = (List<Decimal>) history.get('historicalDemandValues');
    List<Decimal> supplyValues = (List<Decimal>) history.get('historicalSupplyValues');

    ForecastResult demandForecast;
    ForecastResult supplyForecast;

    if (modelName == 'MOVING_AVERAGE') {
       // demandForecast = runMovingAverageForecast(demandValues, 6);
        //supplyForecast = runMovingAverageForecast(supplyValues, 6);
    } else {
        demandForecast = runHoltWintersForecast(demandValues, 12, 12);
        supplyForecast = runHoltWintersForecast(supplyValues, 12, 12);
    }
    System.debug('🔮 demandForecast ' + demandForecast);
    System.debug('🔮 supplyForecast ' +supplyForecast);
    System.debug(' ⚙️ demandValues ' +demandValues);
    System.debug('⚙️ supplyValues ' +supplyValues);


    history.put('forecastMonths', demandForecast.forecastMonths); // Same for both
    history.put('forecastDemandValues', demandForecast.forecastValues);
    history.put('forecastSupplyValues', supplyForecast.forecastValues);

    return history;
}



    

    
    //for top 5 supply and demand
    
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
        WHERE  Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
        AND    CreatedDate >= :fromDate
        AND    CreatedDate <= :toDate
        AND    Order.ERP7__Organisation__c = :organisationId
        GROUP  BY Product2Id, Product2.Name
        ORDER  BY SUM(Quantity) DESC
        LIMIT  5
    ]) {
        results.add(new ProductSupplyDemandSummary(
            (Id)      ar.get('pId'),    (String)  ar.get('pName'),    (Decimal) ar.get('qDemand'),    (Decimal) ar.get('qSupply'),    'Demand'
        ));
    }

    // -------- TOP 5 by SUPPLY --------
    for (AggregateResult ar : [
        SELECT Product2Id                      pId,
               Product2.Name                   pName,
               SUM(Quantity)                  qDemand,
               SUM(ERP7__Shipped_Quantity__c) qSupply
        FROM   OrderItem
        WHERE  Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
        AND    CreatedDate >= :fromDate
        AND    CreatedDate <= :toDate
        AND    Order.ERP7__Organisation__c = :organisationId
        GROUP  BY Product2Id, Product2.Name
        ORDER  BY SUM(ERP7__Shipped_Quantity__c) DESC
        LIMIT  5
    ]) {
        results.add(new ProductSupplyDemandSummary(
            (Id)      ar.get('pId'),   (String)  ar.get('pName'),   (Decimal) ar.get('qDemand'),   (Decimal) ar.get('qSupply'),   'Supply'
        ));
    }

    return results;
}

    
    public class ProductSupplyDemandSummary {
        @AuraEnabled public Id      productId;
        @AuraEnabled public String  productName;
        @AuraEnabled public Decimal totalDemand;
        @AuraEnabled public Decimal totalSupply;
        @AuraEnabled public String  rankingType;   
    
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
        WHERE Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
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
        Decimal currentDemand = demandMap.containsKey(country) ? demandMap.get(country) : 0;   Decimal currentSupply = supplyMap.containsKey(country) ? supplyMap.get(country) : 0;

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
          AND Order.Status NOT IN ('Cancelled', 'Draft', 'Entered')
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
    System.debug('getDefaultTopVendor org id = ' + organisationId + ' year = ' + year);
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



// //forcaste + 

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getSpendOverTimeWithForecast(Id vendorId, Id organisationId, Integer year) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    if (vendorId == null || organisationId == null || year == null) {
        return result;
    }

    try {
        Integer currentMonth = Date.today().month();
        Integer pastYear1 = year - 1;
        Integer pastYear2 = year - 2;
        Integer pastYear3 = year - 3;

        // 1. Fetch current year's actuals
        List<AggregateResult> thisYearTotals = [
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
        ];

        // 2. Fetch historical totals (past 3 years)
        List<AggregateResult> past3YearsTotals = [
            SELECT CALENDAR_MONTH(CreatedDate) month,
                   CALENDAR_YEAR(CreatedDate) yr,
                   SUM(ERP7__Amount__c) total
            FROM ERP7__Payment__c
            WHERE ERP7__Accounts__c = :vendorId
            AND ERP7__Status__c = 'Paid'
            AND ERP7__Purchase_Orders__c != null
            AND ERP7__Bill__c != null
            AND ERP7__Account__c = :organisationId
            AND CALENDAR_YEAR(CreatedDate) IN :new List<Integer>{pastYear1, pastYear2, pastYear3}
            GROUP BY CALENDAR_MONTH(CreatedDate), CALENDAR_YEAR(CreatedDate)
        ];

        Map<Integer, Decimal> currentYearData = new Map<Integer, Decimal>();
        for (AggregateResult ar : thisYearTotals) {
            Integer month = (Integer) ar.get('month');
            Decimal total = (Decimal) ar.get('total');
            currentYearData.put(month, total);
        }

        // 3. Prepare historical averages
        Map<Integer, List<Decimal>> monthToPastAmounts = new Map<Integer, List<Decimal>>();
        for (AggregateResult ar : past3YearsTotals) {
            Integer month = (Integer) ar.get('month');
            Decimal total = (Decimal) ar.get('total');

            if (!monthToPastAmounts.containsKey(month)) {
                monthToPastAmounts.put(month, new List<Decimal>());
            }
            monthToPastAmounts.get(month).add(total);
        }

        Map<Integer, Decimal> forecastMap = new Map<Integer, Decimal>();
        for (Integer m = 1; m <= 12; m++) {
            List<Decimal> values = monthToPastAmounts.containsKey(m) ? monthToPastAmounts.get(m) : new List<Decimal>();
            Decimal sum = 0;
            for (Decimal d : values) {
                sum += d;
            }
            forecastMap.put(m, values.isEmpty() ? 0 : Math.round(sum / values.size()));
        }

        List<String> monthNames = new List<String>{
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        };

        // 4. Build result for 12 months
        for (Integer i = 1; i <= 12; i++) {
            if (currentYearData.containsKey(i)) {
                result.add(new Map<String, Object>{
                    'month' => monthNames[i - 1],
                    'amount' => currentYearData.get(i),
                    'isForecast' => false
                });
            } else {
                result.add(new Map<String, Object>{
                    'month' => monthNames[i - 1],
                    'amount' => forecastMap.get(i),
                    'isForecast' => true
                });
            }
        }

    } catch (Exception e) {
        System.debug('❌ Error in getSpendOverTimeWithForecast: ' + e.getMessage());
        throw new AuraHandledException('Failed to generate forecast: ' + e.getMessage());
    }

    return result;
}



//here end

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
                List<String> monthNames = new List<String>{        'January', 'February', 'March', 'April', 'May', 'June',        'July', 'August', 'September', 'October', 'November', 'December'
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
                SELECT ERP7__Quantity__c, ERP7__Scrapped__c
                FROM ERP7__WIP__c WHERE ERP7__MO__c IN :moIds
            ]) {
                summary.totalWipQuantity += rec.ERP7__Quantity__c != null ? rec.ERP7__Quantity__c : 0;
                summary.totalWipScrapped += rec.ERP7__Scrapped__c != null ? rec.ERP7__Scrapped__c : 0;
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
        SELECT ERP7__MO__c, ERP7__Quantity__c, ERP7__Scrapped__c
        FROM ERP7__WIP__c WHERE ERP7__MO__c IN :moIds
    ]) {
        Id productId = moToProductMap.get(rec.ERP7__MO__c);
        if (productSummaryMap.containsKey(productId)) {
            Top5InventorySummaryWrapper wrap = productSummaryMap.get(productId);
            wrap.totalWipQuantity += rec.ERP7__Quantity__c != null ? rec.ERP7__Quantity__c : 0;
            wrap.totalWipScrapped += rec.ERP7__Scrapped__c != null ? rec.ERP7__Scrapped__c : 0;
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
    // return [SELECT FiscalYearStartMonth FROM Organization LIMIT 1].FiscalYearStartMonth;

      try {
        System.debug('📘 Attempting to fetch FiscalYearSettings...');
        
        FiscalYearSettings fys = [
            SELECT StartDate, YearType, IsStandardYear
            FROM FiscalYearSettings
            LIMIT 1
        ];
        
        System.debug('✅ Retrieved FiscalYearSettings: StartDate = ' + fys.StartDate + ', YearType = ' + fys.YearType);

        // ✅ First, handle Standard Fiscal Year
        if (fys.IsStandardYear == true) {
            System.debug('📘 Detected Standard Fiscal Year. Fetching FiscalYearStartMonth from Organization...');
            
            Organization orgInfo = [
                SELECT FiscalYearStartMonth
                FROM Organization
                LIMIT 1
            ];

            Integer fiscalStartMonth = orgInfo.FiscalYearStartMonth;
            System.debug('✅ Standard Fiscal Year Start Month: ' + fiscalStartMonth);
            return fiscalStartMonth;
        }

        // ✅ Else, handle Custom Fiscal Year
        Integer customStartMonth = fys.StartDate.month();
        System.debug('✅ Custom Fiscal Year detected. Start Month: ' + customStartMonth);
        return customStartMonth;

    } catch (Exception e) {
        System.debug('⚠️ Exception caught: ' + e.getMessage());
        System.debug('🔁 Attempting fallback using Organization object...');

        try {
            Organization orgInfo = [
                SELECT FiscalYearStartMonth
                FROM Organization
                LIMIT 1
            ];

            Integer fiscalStartMonth = orgInfo.FiscalYearStartMonth;
            System.debug('✅ Fallback Fiscal Year Start Month: ' + fiscalStartMonth);
            return fiscalStartMonth;

        } catch (Exception inners) {
            System.debug('❌ Fallback failed: ' + inners.getMessage());
            Integer defaultMonth = Date.today().month();
            System.debug('🚨 Returning current month as last resort: ' + defaultMonth);
            return defaultMonth;
        }
    }
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
        entry.put('accountId', accId);    entry.put('accountName', acc.Name);    entry.put('quantity', qty.setScale(2));    response.add(entry);
    }

    return response;
}

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getStockAlertData(Id siteId, Id location, Id product, Id OrgId) {
    if (siteId == null || OrgId == null) {
        throw new AuraHandledException('Site (Warehouse) and Organisation are required');
    }

    // Base query
    String baseQuery = 'SELECT ERP7__Product__c, ERP7__Number_of_Item_In_Stock__c, ' +
                       'ERP7__Warehouse__r.Name, ERP7__Location__r.Name ' +
                       'FROM ERP7__Inventory_Stock__c ' +
                       'WHERE ERP7__Active__c = true ' +
                       'AND ERP7__Warehouse__c = :siteId ' +
                       'AND ERP7__Organisation__c = :OrgId ' +
                       'AND Name != \'Awaiting Stock\' ' +
                       'AND ERP7__Number_of_Item_In_Stock__c > 0 ';

    if (location != null) {
        baseQuery += 'AND ERP7__Location__c = :location ';
    }
    if (product != null) {
        baseQuery += 'AND ERP7__Product__c = :product ';
    }

    // Optional: Add limit if product and location both given (small result set)
    if (location != null && product != null) {
        baseQuery += 'LIMIT 2000 ';
    }

    List<ERP7__Inventory_Stock__c> inventoryRecords = Database.query(baseQuery);

    // Step 2: Group by Product + Warehouse + Location
    Map<String, Map<String, Object>> dataMap = new Map<String, Map<String, Object>>();
    Set<Id> productIds = new Set<Id>();

    for (ERP7__Inventory_Stock__c stock : inventoryRecords) {
        Id productId = stock.ERP7__Product__c;
        String warehouseName = stock.ERP7__Warehouse__r.Name;     String locationName = stock.ERP7__Location__r.Name;     String key = productId + '|' + warehouseName + '|' + locationName;

        productIds.add(productId);

        if (!dataMap.containsKey(key)) {
            dataMap.put(key, new Map<String, Object>{
                'productId' => productId,    'currentStock' => 0,    'warehouse' => warehouseName,    'location' => locationName
            });
        }

        Decimal existing = (Decimal) dataMap.get(key).get('currentStock');
        dataMap.get(key).put('currentStock', existing + stock.ERP7__Number_of_Item_In_Stock__c);
    }

    if (productIds.isEmpty()) return new List<Map<String, Object>>();

    // Step 3: Product names
    Map<Id, String> productNameMap = new Map<Id, String>();
    for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Id IN :productIds]) {
        productNameMap.put(prod.Id, prod.Name);
    }

    // Step 4: Reordering rules
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

    // Step 5: Assemble result
    List<Map<String, Object>> results = new List<Map<String, Object>>();
    for (Map<String, Object> row : dataMap.values()) {
        Id productId = (Id) row.get('productId');
        Decimal stock = (Decimal) row.get('currentStock');    Decimal reorder = 0;    Decimal safety = 0;

        if (ruleMap.containsKey(productId)) {
            ERP7__Reordering_Rule__c rule = ruleMap.get(productId);
            reorder = rule.ERP7__Reorder_Level__c != null ? rule.ERP7__Reorder_Level__c : 0;
            safety = rule.ERP7__Safety_Stock__c != null ? rule.ERP7__Safety_Stock__c : 0;
        }

        row.put('productName', productNameMap.get(productId));
        row.put('reorderLevel', reorder);
        row.put('safetyStock', safety);

        results.add(row);
    }
System.debug('FINAL RESULTS: ' + results);

    return results;
}



// ================== DROP-IN REPLACEMENT ==================
@AuraEnabled(cacheable=true)
public static List<MonthlyPriceDTO> getMonthlySalesPriceStats(
    Id productId,
    Id customerId,
    Id orgId,
    Date startDate,
    Date endDate
) {
    if (startDate == null) startDate = System.today().addMonths(-12);
    if (endDate == null) endDate = System.today();

    // --------------------------------------------
    // 1) Keep your existing AVG/MIN/MAX (by Invoice date)
    // --------------------------------------------
    String invAgg =
        'SELECT CALENDAR_YEAR(ERP7__Invoice__r.ERP7__Invoice_Date__c) yr, ' +
               'CALENDAR_MONTH(ERP7__Invoice__r.ERP7__Invoice_Date__c) mn, ' +
               'AVG(ERP7__Unit_Price__c) avgP, MIN(ERP7__Unit_Price__c) minP, MAX(ERP7__Unit_Price__c) maxP ' +
        'FROM ERP7__Invoice_Line_Item__c ' +
        'WHERE ERP7__Product__c = :productId ' +
        'AND ERP7__Invoice__r.ERP7__Invoice_Date__c >= :startDate ' +
        'AND ERP7__Invoice__r.ERP7__Invoice_Date__c <= :endDate ';

    if (customerId != null) invAgg += 'AND ERP7__Invoice__r.ERP7__Account__c = :customerId ';
    if (orgId != null) invAgg += 'AND ERP7__Invoice__r.ERP7__Organisation__c = :orgId ';

    invAgg += 'GROUP BY CALENDAR_YEAR(ERP7__Invoice__r.ERP7__Invoice_Date__c), ' +
              'CALENDAR_MONTH(ERP7__Invoice__r.ERP7__Invoice_Date__c) ' +
              'ORDER BY CALENDAR_YEAR(ERP7__Invoice__r.ERP7__Invoice_Date__c) ASC, ' +
                       'CALENDAR_MONTH(ERP7__Invoice__r.ERP7__Invoice_Date__c) ASC';

    List<AggregateResult> invResults = Database.query(invAgg);

    // Store price stats keyed by "YYYY-M" (e.g., 2025-7)
    Map<String, PriceStats> priceByMonth = new Map<String, PriceStats>();
    for (AggregateResult ar : invResults) {
        Integer yr = (Integer)ar.get('yr');
        Integer mn = (Integer)ar.get('mn');
        String key = String.valueOf(yr) + '-' + String.valueOf(mn);
        priceByMonth.put(key, new PriceStats(
            (Decimal)ar.get('avgP'),           (Decimal)ar.get('minP'),            (Decimal)ar.get('maxP')
        ));
    }

    // --------------------------------------------
    // 2) NEW: Pull Sales Orders for the product & window (by OrderItem)
    //    Group by EffectiveDate (month), then break down by Status
    // --------------------------------------------
    // Guard-rail for prod
   // ---- One dynamic SOQL, no if/else ----
Integer MAX_ROWS = 5000;

String baseSoql =
'SELECT Id,' +
'       Order.Id, Order.Name, Order.OrderNumber, Order.EffectiveDate, Order.Status,' +
'       Order.AccountId,' +
'       Order.Account.Name,' + 
'       Order.ERP7__Stage__c, Order.ERP7__Expected_Date__c,' +
'       Order.ERP7__Organisation__c, Order.ERP7__Sub_Total__c, Order.ERP7__Order_Amount__c,' +
'       Order.ERP7__Packed_Quantity__c, Order.ERP7__Picked_Quantity__c,' +
'       Order.ERP7__Shipped_Quantity__c, Order.ERP7__Total_Quantity__c ' +
'FROM OrderItem ' +
'WHERE Product2Id = :productId ' +
'  AND Order.EffectiveDate >= :startDate ' +
'  AND Order.EffectiveDate <= :endDate';

String customerClause = (customerId == null) ? '' : ' AND Order.AccountId = :customerId';
String orgClause = (orgId == null) ? '' : ' AND Order.ERP7__Organisation__c = :orgId';

String finalSoql = baseSoql +
                   customerClause +
                   orgClause +
                   ' ORDER BY Order.EffectiveDate DESC ' +
                   ' LIMIT ' + String.valueOf(MAX_ROWS);

List<OrderItem> ois = Database.query(finalSoql);

    // Per-month containers (key = "YYYY-M")
    Map<String, Integer> monthSOCount   = new Map<String, Integer>();                           // NEW
    // NEW: per-status counts
    Map<String, Integer> monthDraftCount        = new Map<String, Integer>();
    Map<String, Integer> monthEnteredCount      = new Map<String, Integer>();
    Map<String, Integer> monthActivatedCount    = new Map<String, Integer>();
    Map<String, Integer> monthPickedUpCount     = new Map<String, Integer>();
    Map<String, Integer> monthPartShippedCount  = new Map<String, Integer>();
    Map<String, Integer> monthShippedCount      = new Map<String, Integer>();
    Map<String, Integer> monthDeliveredCount    = new Map<String, Integer>();
    Map<String, Integer> monthCancelledCount    = new Map<String, Integer>();

    // NEW: per-status lists (detailed wrappers)
    Map<String, List<SOWrapper>> monthDraftList       = new Map<String, List<SOWrapper>>();
    Map<String, List<SOWrapper>> monthEnteredList     = new Map<String, List<SOWrapper>>();
    Map<String, List<SOWrapper>> monthActivatedList   = new Map<String, List<SOWrapper>>();
    Map<String, List<SOWrapper>> monthPickedUpList    = new Map<String, List<SOWrapper>>();
    Map<String, List<SOWrapper>> monthPartShippedList = new Map<String, List<SOWrapper>>();
    Map<String, List<SOWrapper>> monthShippedList     = new Map<String, List<SOWrapper>>();
    Map<String, List<SOWrapper>> monthDeliveredList   = new Map<String, List<SOWrapper>>();
    Map<String, List<SOWrapper>> monthCancelledList   = new Map<String, List<SOWrapper>>();

    for (OrderItem oi : ois) {
        if (oi.Order == null || oi.Order.EffectiveDate == null) continue;

        Date eff = oi.Order.EffectiveDate;
        String key = eff.year() + '-' + eff.month();

        // init maps
        if (!monthSOCount.containsKey(key)) monthSOCount.put(key, 0);

        // init lists
        if (!monthDraftList.containsKey(key))       monthDraftList.put(key, new List<SOWrapper>());
        if (!monthEnteredList.containsKey(key))     monthEnteredList.put(key, new List<SOWrapper>());
        if (!monthActivatedList.containsKey(key))   monthActivatedList.put(key, new List<SOWrapper>());
        if (!monthPickedUpList.containsKey(key))    monthPickedUpList.put(key, new List<SOWrapper>());
        if (!monthPartShippedList.containsKey(key)) monthPartShippedList.put(key, new List<SOWrapper>());
        if (!monthShippedList.containsKey(key))     monthShippedList.put(key, new List<SOWrapper>());
        if (!monthDeliveredList.containsKey(key))   monthDeliveredList.put(key, new List<SOWrapper>());
        if (!monthCancelledList.containsKey(key))   monthCancelledList.put(key, new List<SOWrapper>());

        if (!monthDraftCount.containsKey(key))       monthDraftCount.put(key, 0);
        if (!monthEnteredCount.containsKey(key))     monthEnteredCount.put(key, 0);
        if (!monthActivatedCount.containsKey(key))   monthActivatedCount.put(key, 0);
        if (!monthPickedUpCount.containsKey(key))    monthPickedUpCount.put(key, 0);
        if (!monthPartShippedCount.containsKey(key)) monthPartShippedCount.put(key, 0);
        if (!monthShippedCount.containsKey(key))     monthShippedCount.put(key, 0);
        if (!monthDeliveredCount.containsKey(key))   monthDeliveredCount.put(key, 0);
        if (!monthCancelledCount.containsKey(key))   monthCancelledCount.put(key, 0);

        // Build detail wrapper
        SOWrapper w = new SOWrapper( // NEW
            (String)oi.Order.Id,
            oi.Order.Name,
            oi.Order.OrderNumber,
            oi.Order.EffectiveDate,
            oi.Order.ERP7__Expected_Date__c,
            oi.Order.Status,
            oi.Order.AccountId,
            (oi.Order.Account != null ? oi.Order.Account.Name : null),  // 🆕 pass Account Name
            (String)oi.Order.ERP7__Organisation__c,
            oi.Order.ERP7__Stage__c,
            oi.Order.ERP7__Sub_Total__c,
            oi.Order.ERP7__Order_Amount__c,
            oi.Order.ERP7__Packed_Quantity__c,
            oi.Order.ERP7__Picked_Quantity__c,
            oi.Order.ERP7__Shipped_Quantity__c,
            oi.Order.ERP7__Total_Quantity__c
        );

        // Tally
        monthSOCount.put(key, monthSOCount.get(key) + 1);

        // Normalize statuses into the 8 buckets you listed
        String st = (oi.Order.Status != null) ? oi.Order.Status.trim() : '';
        if (st == 'Draft') {
            monthDraftCount.put(key, monthDraftCount.get(key)+1);
            monthDraftList.get(key).add(w);
        } else if (st == 'Entered') {
            monthEnteredCount.put(key, monthEnteredCount.get(key)+1);
            monthEnteredList.get(key).add(w);
        } else if (st == 'Activated') {
            monthActivatedCount.put(key, monthActivatedCount.get(key)+1);
            monthActivatedList.get(key).add(w);
        } else if (st == 'Picked Up') {
            monthPickedUpCount.put(key, monthPickedUpCount.get(key)+1);
            monthPickedUpList.get(key).add(w);
        } else if (st == 'Partially Shipped') {
            monthPartShippedCount.put(key, monthPartShippedCount.get(key)+1);
            monthPartShippedList.get(key).add(w);
        } else if (st == 'Shipped') {
            monthShippedCount.put(key, monthShippedCount.get(key)+1);
            monthShippedList.get(key).add(w);
        } else if (st == 'Delivered') {
            monthDeliveredCount.put(key, monthDeliveredCount.get(key)+1);
            monthDeliveredList.get(key).add(w);
        } else if (st == 'Cancelled') {
            monthCancelledCount.put(key, monthCancelledCount.get(key)+1);
            monthCancelledList.get(key).add(w);
        } else {
            // Unknown statuses: optionally bucket to Entered or ignore
            monthEnteredCount.put(key, monthEnteredCount.get(key)+1);
            monthEnteredList.get(key).add(w);
        }
    }

    // --------------------------------------------
    // 3) Build DTOs by union of keys (invoice stats ⨁ order buckets)
    // --------------------------------------------
    Set<String> allKeys = new Set<String>();
    allKeys.addAll(priceByMonth.keySet());
    allKeys.addAll(monthSOCount.keySet());

    List<MonthlyPriceDTO> out = new List<MonthlyPriceDTO>();
    for (String key : allKeys) {
        Integer yr = Integer.valueOf(key.split('-')[0]);
        Integer mn = Integer.valueOf(key.split('-')[1]);

        // default zeros, then override from invoice map if present
        Decimal avgP = 0, minP = 0, maxP = 0;
        if (priceByMonth.containsKey(key)) {
            avgP = priceByMonth.get(key).avgP;
            minP = priceByMonth.get(key).minP;
            maxP = priceByMonth.get(key).maxP;
        }

        MonthlyPriceDTO dto = new MonthlyPriceDTO(yr, mn, avgP, minP, maxP);

        // ---- NEW: sales order counts & lists on DTO ----
        dto.totalSOCount          = monthSOCount.containsKey(key)         ? monthSOCount.get(key)         : 0;
        dto.soDraftCount          = monthDraftCount.containsKey(key)      ? monthDraftCount.get(key)      : 0;
        dto.soEnteredCount        = monthEnteredCount.containsKey(key)    ? monthEnteredCount.get(key)    : 0;
        dto.soActivatedCount      = monthActivatedCount.containsKey(key)  ? monthActivatedCount.get(key)  : 0;
        dto.soPickedUpCount       = monthPickedUpCount.containsKey(key)   ? monthPickedUpCount.get(key)   : 0;
        dto.soPartShippedCount    = monthPartShippedCount.containsKey(key)? monthPartShippedCount.get(key): 0;
        dto.soShippedCount        = monthShippedCount.containsKey(key)    ? monthShippedCount.get(key)    : 0;
        dto.soDeliveredCount      = monthDeliveredCount.containsKey(key)  ? monthDeliveredCount.get(key)  : 0;
        dto.soCancelledCount      = monthCancelledCount.containsKey(key)  ? monthCancelledCount.get(key)  : 0;

        dto.soDraftList           = monthDraftList.get(key);
        dto.soEnteredList         = monthEnteredList.get(key);
        dto.soActivatedList       = monthActivatedList.get(key);
        dto.soPickedUpList        = monthPickedUpList.get(key);
        dto.soPartiallyShippedList= monthPartShippedList.get(key);
        dto.soShippedList         = monthShippedList.get(key);
        dto.soDeliveredList       = monthDeliveredList.get(key);
        dto.soCancelledList       = monthCancelledList.get(key);

        out.add(dto);
    }

    out.sort(); // relies on your MonthlyPriceDTO.compareTo (year, month)
    return out;
}

// Helper holder for price stats (internal to this class)
private class PriceStats {
    Decimal avgP; Decimal minP; Decimal maxP;
    PriceStats(Decimal a, Decimal n, Decimal x) { avgP=a; minP=n; maxP=x; }
}

// ================== ADD THIS WRAPPER (sibling class) ==================
// NEW: Sales Order wrapper returned inside DTO lists
public class SOWrapper {
    @AuraEnabled public String   orderId              { get; set; }
    @AuraEnabled public String   Name            { get; set; }
    @AuraEnabled public String   OrderNumber     { get; set; }
    @AuraEnabled public Date     EffectiveDate   { get; set; }
    @AuraEnabled public Date     ExpectedDate    { get; set; }         // ERP7__Expected_Date__c
    @AuraEnabled public String   Status          { get; set; }
    @AuraEnabled public String   AccountId       { get; set; }
        @AuraEnabled public String   AccountName     { get; set; }         // 🆕 Account Name
    @AuraEnabled public String   OrganisationId  { get; set; }         // ERP7__Organisation__c
    @AuraEnabled public String   Stage           { get; set; }         // ERP7__Stage__c
    @AuraEnabled public Decimal  SubTotal        { get; set; }         // ERP7__Sub_Total__c
    @AuraEnabled public Decimal  OrderAmount     { get; set; }         // ERP7__Order_Amount__c
    @AuraEnabled public Decimal  PackedQty       { get; set; }         // ERP7__Packed_Quantity__c
    @AuraEnabled public Decimal  PickedQty       { get; set; }         // ERP7__Picked_Quantity__c
    @AuraEnabled public Decimal  ShippedQty      { get; set; }         // ERP7__Shipped_Quantity__c
    @AuraEnabled public Decimal  TotalQty        { get; set; }         // ERP7__Total_Quantity__c

    public SOWrapper(String id, String name, String ordNo, Date eff, Date exp, String st,
                     String acctId,  String acctName,String orgId, String stage,
                     Decimal subTot, Decimal ordAmt,
                     Decimal packed, Decimal picked, Decimal shipped, Decimal totalQ) {
        orderId = id; Name = name; OrderNumber = ordNo;
        EffectiveDate = eff; ExpectedDate = exp; Status = st;
                AccountId = acctId; AccountName = acctName;              // 🆕 set AccountName
        AccountId = acctId; OrganisationId = orgId; Stage = stage;
        SubTotal = subTot; OrderAmount = ordAmt;
        PackedQty = packed; PickedQty = picked; ShippedQty = shipped; TotalQty = totalQ;
    }
}



// -------------------------
// PURCHASE PRICE
// -------------------------
@AuraEnabled(cacheable=true)
public static List<MonthlyPriceDTO> getMonthlyPurchasePriceStats(
    Id productId,
    Id supplierId,
    Id orgId,
    Date startDate,
    Date endDate
) {
    if (startDate == null) startDate = System.today().addMonths(-12);
    if (endDate == null) endDate = System.today();

    Integer maxLineItemRows = 5000;
    Integer maxPoRows       = 5000;

    // --- 1) Aggregate avg/min/max by month
    String aggQuery =
        'SELECT CALENDAR_YEAR(ERP7__Purchase_Orders__r.ERP7__Order_Date__c) yr, ' +
        '       CALENDAR_MONTH(ERP7__Purchase_Orders__r.ERP7__Order_Date__c) mn, ' +
        '       AVG(ERP7__Unit_Price__c) avgP, MIN(ERP7__Unit_Price__c) minP, MAX(ERP7__Unit_Price__c) maxP ' +
        'FROM ERP7__Purchase_Line_Items__c ' +
        'WHERE ERP7__Product__c = :productId ' +
        'AND   ERP7__Purchase_Orders__r.ERP7__Order_Date__c >= :startDate ' +
        'AND   ERP7__Purchase_Orders__r.ERP7__Order_Date__c <= :endDate ';

    if (supplierId != null) {
        aggQuery += 'AND   ERP7__Purchase_Orders__r.ERP7__Vendor__c = :supplierId ';
    }
    if (orgId != null) {
        aggQuery += 'AND   ERP7__Purchase_Orders__r.ERP7__Organisation__c = :orgId ';
    }

    aggQuery += 'GROUP BY CALENDAR_YEAR(ERP7__Purchase_Orders__r.ERP7__Order_Date__c), ' +
                '         CALENDAR_MONTH(ERP7__Purchase_Orders__r.ERP7__Order_Date__c) ' +
                'ORDER BY CALENDAR_YEAR(ERP7__Purchase_Orders__r.ERP7__Order_Date__c), ' +
                '         CALENDAR_MONTH(ERP7__Purchase_Orders__r.ERP7__Order_Date__c) ' +
                'LIMIT :maxLineItemRows';

    List<AggregateResult> arList = Database.query(aggQuery);

    Map<String, MonthlyPriceDTO> dtoByKey = new Map<String, MonthlyPriceDTO>();
    for (AggregateResult ar : arList) {
        Integer yr = (Integer) ar.get('yr');
        Integer mn = (Integer) ar.get('mn');
        Decimal avgP = (Decimal) ar.get('avgP');
        Decimal minP = (Decimal) ar.get('minP');
        Decimal maxP = (Decimal) ar.get('maxP');
        String key = yr + '-' + mn;

        MonthlyPriceDTO dto = new MonthlyPriceDTO(yr, mn, avgP, minP, maxP);
        dto.totalPOCount = 0;
        dto.initPOStatusLists(); // ✅ helper method in DTO
        dtoByKey.put(key, dto);
    }

    // --- 2) Fetch detailed POs
    String poQuery =
        'SELECT Id, Name, ERP7__Organisation__c, ERP7__Total_Amount__c, ERP7__Order_Date__c, ' +
        '       ERP7__Status__c, ERP7__Vendor__c, ERP7__Vendor__r.Name ' +
        'FROM ERP7__PO__c ' +
        'WHERE Id IN ( ' +
        '   SELECT ERP7__Purchase_Orders__c FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Product__c = :productId ' +
        ') ' +
        'AND   ERP7__Order_Date__c >= :startDate ' +
        'AND   ERP7__Order_Date__c <= :endDate ';

    if (supplierId != null) {
        poQuery += 'AND   ERP7__Vendor__c = :supplierId ';
    }
    if (orgId != null) {
        poQuery += 'AND   ERP7__Organisation__c = :orgId ';
    }

    poQuery += 'ORDER BY ERP7__Order_Date__c DESC, CreatedDate DESC ' +
               'LIMIT :maxPoRows';

    List<ERP7__PO__c> pos = Database.query(poQuery);

    for (ERP7__PO__c po : pos) {
        if (po.ERP7__Order_Date__c == null) continue;
        Integer yr = po.ERP7__Order_Date__c.year();
        Integer mn = po.ERP7__Order_Date__c.month();
        String key = yr + '-' + mn;

        if (!dtoByKey.containsKey(key)) {
            MonthlyPriceDTO dto = new MonthlyPriceDTO(yr, mn, 0, 0, 0);
            dto.initPOStatusLists();
            dtoByKey.put(key, dto);
        }

        MonthlyPriceDTO dto = dtoByKey.get(key);
        POWrapper wrap = new POWrapper(
            (String)po.Id, po.Name, (String)po.ERP7__Organisation__c,
            po.ERP7__Total_Amount__c, po.ERP7__Order_Date__c,
            po.ERP7__Status__c, (String)po.ERP7__Vendor__c,
            po.ERP7__Vendor__r != null ? po.ERP7__Vendor__r.Name : null
        );

        dto.totalPOCount++;

        // ✅ Handle all status types
        String status = po.ERP7__Status__c;
        if (status == 'Draft') dto.poDraftList.add(wrap);
        else if (status == 'Logged') dto.poLoggedList.add(wrap);
        else if (status == 'Assigned') dto.poAssignedList.add(wrap);        else if (status == 'Approved') dto.poApprovedList.add(wrap); 
        else if (status == 'Rejected') dto.poRejectedList.add(wrap);    
        else if (status == 'In Progress') dto.poInProgressList.add(wrap);        else if (status == 'Booked') dto.poBookedList.add(wrap);
        else if (status == 'Closed') dto.poClosedList.add(wrap);        else if (status == 'Cancelled') dto.poCancelledList.add(wrap);
        else if (status == 'Supplier Accepted') dto.poSupplierAcceptedList.add(wrap);        else if (status == 'Reconciled') dto.poReconciledList.add(wrap);
        else if (status == 'Submitted for Approval') dto.poSubmittedForApprovalList.add(wrap);     else if (status == 'On Hold') dto.poOnHoldList.add(wrap);
    }

    List<MonthlyPriceDTO> out = new List<MonthlyPriceDTO>(dtoByKey.values());
    out.sort();
    return out;
}


// ---------------------- PO Wrapper (for LWC table rows) ----------------------
public class POWrapper {
    @AuraEnabled public String Id { get; set; }
    @AuraEnabled public String Name { get; set; }
    @AuraEnabled public String organisationId { get; set; }
    @AuraEnabled public Decimal totalAmount { get; set; }
    @AuraEnabled public Date orderDate { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public String vendorId { get; set; }
    @AuraEnabled public String vendorName { get; set; }

    public POWrapper(String id, String name, String orgId, Decimal totalAmt, Date ordDate,
                     String stat, String vendId, String vendName) {
        this.Id = id;
        this.Name = name;
        this.organisationId = orgId;
        this.totalAmount = totalAmt;
        this.orderDate = ordDate;
        this.status = stat;
        this.vendorId = vendId;
        this.vendorName = vendName;
    }
}


// ---------------------- Manufacturing Unit Price Stats ----------------------
@AuraEnabled(cacheable=true)
public static List<MonthlyPriceDTO> getMonthlyManufacturingUnitPriceStats(
    Id productId,
    Date startDate,
    Date endDate
) {
    if (startDate == null) startDate = System.today().addMonths(-12);
    if (endDate == null) endDate = System.today();
         Integer maxRows = 5000;

    String baseQuery =
        'SELECT Id, Name, ERP7__StartDate__c, ERP7__End_Date__c, ERP7__ExpectedDate__c, ' +
        '       ERP7__Quantity__c, ERP7__Cost__c, ERP7__Status__c, ' +
        '       ERP7__Duration__c, ERP7__Product__c, ERP7__Product__r.Name ' +
        'FROM ERP7__Manufacturing_Order__c ' +
        'WHERE ERP7__Product__c = :productId ' +
        'AND   ERP7__StartDate__c >= :startDate ' +
        'AND   ERP7__StartDate__c <= :endDate ' +
        'ORDER BY ERP7__StartDate__c DESC, CreatedDate DESC ' +
        'LIMIT :maxRows';

    List<ERP7__Manufacturing_Order__c> orders = Database.query(baseQuery);

    // Maps per month
    Map<String, List<Decimal>> monthUnitCostMap = new Map<String, List<Decimal>>();
    Map<String, List<Decimal>> monthDurationMap = new Map<String, List<Decimal>>();
    Map<String, List<Decimal>> monthDelayMap    = new Map<String, List<Decimal>>();
    Map<String, Integer> monthTotalCount        = new Map<String, Integer>();
    Map<String, Integer> monthCompletedCount    = new Map<String, Integer>();
    Map<String, Integer> monthInProgressCount   = new Map<String, Integer>();
    Map<String, Integer> monthDraftCount        = new Map<String, Integer>();
    Map<String, Integer> monthCancelledCount    = new Map<String, Integer>();
    Map<String, Integer> monthReleaseCount      = new Map<String, Integer>();

    // MO lists per status (Id + Name — kept as-is)
    Map<String, List<IdNameWrapper>> monthCompletedMOs  = new Map<String, List<IdNameWrapper>>();
    Map<String, List<IdNameWrapper>> monthInProgressMOs = new Map<String, List<IdNameWrapper>>();
    Map<String, List<IdNameWrapper>> monthDraftMOs      = new Map<String, List<IdNameWrapper>>();
    Map<String, List<IdNameWrapper>> monthCancelledMOs  = new Map<String, List<IdNameWrapper>>();
    Map<String, List<IdNameWrapper>> monthReleaseMOs    = new Map<String, List<IdNameWrapper>>();

    // ✅ NEW: detailed MO lists per status (with extra fields)
    Map<String, List<MOWrapper>> monthCompletedMODetails  = new Map<String, List<MOWrapper>>();
    Map<String, List<MOWrapper>> monthInProgressMODetails = new Map<String, List<MOWrapper>>();
    Map<String, List<MOWrapper>> monthDraftMODetails      = new Map<String, List<MOWrapper>>();
    Map<String, List<MOWrapper>> monthCancelledMODetails  = new Map<String, List<MOWrapper>>();
    Map<String, List<MOWrapper>> monthReleaseMODetails    = new Map<String, List<MOWrapper>>();

    for (ERP7__Manufacturing_Order__c mo : orders) {
        if (mo.ERP7__StartDate__c == null) continue;
        String key = mo.ERP7__StartDate__c.year() + '-' + mo.ERP7__StartDate__c.month();

        if (!monthUnitCostMap.containsKey(key)) monthUnitCostMap.put(key, new List<Decimal>());
        if (!monthDurationMap.containsKey(key)) monthDurationMap.put(key, new List<Decimal>());
        if (!monthDelayMap.containsKey(key))    monthDelayMap.put(key, new List<Decimal>());
        if (!monthTotalCount.containsKey(key))      monthTotalCount.put(key, 0);
        if (!monthCompletedCount.containsKey(key))  monthCompletedCount.put(key, 0);
        if (!monthInProgressCount.containsKey(key)) monthInProgressCount.put(key, 0);
        if (!monthDraftCount.containsKey(key))      monthDraftCount.put(key, 0);
        if (!monthCancelledCount.containsKey(key))  monthCancelledCount.put(key, 0);
        if (!monthReleaseCount.containsKey(key))    monthReleaseCount.put(key, 0);

        if (!monthCompletedMOs.containsKey(key))  monthCompletedMOs.put(key, new List<IdNameWrapper>());
        if (!monthInProgressMOs.containsKey(key)) monthInProgressMOs.put(key, new List<IdNameWrapper>());
        if (!monthDraftMOs.containsKey(key))      monthDraftMOs.put(key, new List<IdNameWrapper>());
        if (!monthCancelledMOs.containsKey(key))  monthCancelledMOs.put(key, new List<IdNameWrapper>());
        if (!monthReleaseMOs.containsKey(key))    monthReleaseMOs.put(key, new List<IdNameWrapper>());

        // ✅ init detailed lists
        if (!monthCompletedMODetails.containsKey(key))  monthCompletedMODetails.put(key, new List<MOWrapper>());
        if (!monthInProgressMODetails.containsKey(key)) monthInProgressMODetails.put(key, new List<MOWrapper>());
        if (!monthDraftMODetails.containsKey(key))      monthDraftMODetails.put(key, new List<MOWrapper>());
        if (!monthCancelledMODetails.containsKey(key))  monthCancelledMODetails.put(key, new List<MOWrapper>());
        if (!monthReleaseMODetails.containsKey(key))    monthReleaseMODetails.put(key, new List<MOWrapper>());

        // Unit Cost series
        if (mo.ERP7__Quantity__c != null && mo.ERP7__Quantity__c != 0 && mo.ERP7__Cost__c != null) {
            monthUnitCostMap.get(key).add(mo.ERP7__Cost__c / mo.ERP7__Quantity__c);
        }

        // Duration series for average
        if (mo.ERP7__End_Date__c != null) {
            monthDurationMap.get(key).add(mo.ERP7__StartDate__c.date().daysBetween(mo.ERP7__End_Date__c.date()));
        }

        // Delay series
        if (mo.ERP7__End_Date__c != null && mo.ERP7__ExpectedDate__c != null) {
            monthDelayMap.get(key).add(mo.ERP7__ExpectedDate__c.date().daysBetween(mo.ERP7__End_Date__c.date()));
        }

        // ✅ Build detailed wrapper for this MO (extra fields included)
        MOWrapper moDetail = new MOWrapper(
            (String)mo.Id,
            mo.Name,
            mo.ERP7__StartDate__c,
            mo.ERP7__End_Date__c,
            mo.ERP7__Cost__c,
            mo.ERP7__Duration__c,
            (String)mo.ERP7__Product__c,
            mo.ERP7__Product__r != null ? mo.ERP7__Product__r.Name : null   // ✅ Added

        );

        // Status counts + lists
        monthTotalCount.put(key, monthTotalCount.get(key)+1);

        if (mo.ERP7__Status__c == 'Complete') {
            monthCompletedCount.put(key, monthCompletedCount.get(key)+1);
            monthCompletedMOs.get(key).add(new IdNameWrapper(mo.Id, mo.Name));
            monthCompletedMODetails.get(key).add(moDetail);   // ✅ add detailed
        }
        if (mo.ERP7__Status__c == 'In Progress') {
            monthInProgressCount.put(key, monthInProgressCount.get(key)+1);
            monthInProgressMOs.get(key).add(new IdNameWrapper(mo.Id, mo.Name));
            monthInProgressMODetails.get(key).add(moDetail);  // ✅ add detailed
        }
        if (mo.ERP7__Status__c == 'Draft') {
            monthDraftCount.put(key, monthDraftCount.get(key)+1);
            monthDraftMOs.get(key).add(new IdNameWrapper(mo.Id, mo.Name));
            monthDraftMODetails.get(key).add(moDetail);       // ✅ add detailed
        }
        if (mo.ERP7__Status__c == 'Cancelled') {
            monthCancelledCount.put(key, monthCancelledCount.get(key)+1);
            monthCancelledMOs.get(key).add(new IdNameWrapper(mo.Id, mo.Name));
            monthCancelledMODetails.get(key).add(moDetail);   // ✅ add detailed
        }
        if (mo.ERP7__Status__c == 'Release') {
            monthReleaseCount.put(key, monthReleaseCount.get(key)+1);
            monthReleaseMOs.get(key).add(new IdNameWrapper(mo.Id, mo.Name));
            monthReleaseMODetails.get(key).add(moDetail);     // ✅ add detailed
        }
    }

    List<MonthlyPriceDTO> dataList = new List<MonthlyPriceDTO>();

    for (String key : monthUnitCostMap.keySet()) {
        List<Decimal> unitCosts = monthUnitCostMap.get(key);
        List<Decimal> durations = monthDurationMap.get(key);
        List<Decimal> delays    = monthDelayMap.get(key);

        Decimal avgCost = 0, minCost = 0, maxCost = 0;
        if (!unitCosts.isEmpty()) {
            minCost = maxCost = unitCosts[0];
            Decimal totalCost = 0;
            for (Decimal c : unitCosts) {
                totalCost += c;
                if (c < minCost) minCost = c;
                if (c > maxCost) maxCost = c;
            }
            avgCost = totalCost / unitCosts.size();
        }

        Decimal totalDuration = 0;
        for (Decimal d : durations) totalDuration += d;
        Decimal avgDuration = !durations.isEmpty() ? totalDuration / durations.size() : 0;

        Decimal totalDelay = 0;
        for (Decimal d2 : delays) totalDelay += d2;
        Decimal avgDelay = !delays.isEmpty() ? totalDelay / delays.size() : 0;

        Integer yr = Integer.valueOf(key.split('-')[0]);
        Integer mn = Integer.valueOf(key.split('-')[1]);

        MonthlyPriceDTO dto = new MonthlyPriceDTO(yr, mn, avgCost, minCost, maxCost);
        dto.avgDuration    = avgDuration;
        dto.avgDelay       = avgDelay;
        dto.totalCount     = monthTotalCount.get(key);
        dto.completedCount = monthCompletedCount.get(key);
        dto.inProgressCount= monthInProgressCount.get(key);
        dto.draftCount     = monthDraftCount.get(key);
        dto.cancelledCount = monthCancelledCount.get(key);
        dto.releaseCount   = monthReleaseCount.get(key);

        // existing Id+Name lists
        dto.completeMOList    = monthCompletedMOs.get(key);
        dto.inProgressMOList  = monthInProgressMOs.get(key);
        dto.draftMOList       = monthDraftMOs.get(key);
        dto.cancelledMOList   = monthCancelledMOs.get(key);
        dto.releaseMOList     = monthReleaseMOs.get(key);

        // ✅ attach detailed lists
        dto.completeMODetails    = monthCompletedMODetails.get(key);
        dto.inProgressMODetails  = monthInProgressMODetails.get(key);
        dto.draftMODetails       = monthDraftMODetails.get(key);
        dto.cancelledMODetails   = monthCancelledMODetails.get(key);
        dto.releaseMODetails     = monthReleaseMODetails.get(key);

        dataList.add(dto);
    }

    dataList.sort();
    return dataList;
}

// ---------------------- DTOs (siblings) ----------------------
public class IdNameWrapper {
    @AuraEnabled public String Id   { get; set; }
    @AuraEnabled public String Name { get; set; }
    public IdNameWrapper(String id, String name) {
        this.Id = id; this.Name = name;
    }
}

// ✅ NEW: Detailed MO wrapper exposing requested fields
public class MOWrapper {
    @AuraEnabled public String    Id        { get; set; }
    @AuraEnabled public String    Name      { get; set; }
    @AuraEnabled public Datetime  startDate { get; set; }   
    @AuraEnabled public Datetime  endDate   { get; set; }   
    @AuraEnabled public Decimal   cost      { get; set; }   
    @AuraEnabled public Decimal   duration  { get; set; }   
    @AuraEnabled public String    productId { get; set; }   
    @AuraEnabled public String    productName { get; set; }   


    public MOWrapper(String id, String name, Datetime startDt, Datetime endDt,
                     Decimal costAmt, Decimal dur, String prodId, String prodName) {
        this.Id = id;
        this.Name = name;
        this.startDate = startDt;
        this.endDate = endDt;
        this.cost = costAmt;
        this.duration = dur;
        this.productId = prodId;
        this.productName = prodName;

    }
}

public class MonthlyPriceDTO implements Comparable {
    @AuraEnabled public Integer year  { get; set; }
    @AuraEnabled public Integer month { get; set; }
    @AuraEnabled public Decimal avgPrice { get; set; }
    @AuraEnabled public Decimal minPrice { get; set; }
    @AuraEnabled public Decimal maxPrice { get; set; }

    @AuraEnabled public Decimal avgDuration { get; set; }
    @AuraEnabled public Decimal avgDelay    { get; set; }
    @AuraEnabled public Integer totalCount { get; set; }
    @AuraEnabled public Integer completedCount { get; set; }
    @AuraEnabled public Integer inProgressCount { get; set; }
    @AuraEnabled public Integer draftCount { get; set; }
    @AuraEnabled public Integer cancelledCount { get; set; }
    @AuraEnabled public Integer releaseCount { get; set; }

 

    // MO lists per status (Id + Name)
    @AuraEnabled public List<IdNameWrapper> completeMOList   { get; set; }
    @AuraEnabled public List<IdNameWrapper> inProgressMOList { get; set; }
    @AuraEnabled public List<IdNameWrapper> draftMOList      { get; set; }
    @AuraEnabled public List<IdNameWrapper> cancelledMOList  { get; set; }
    @AuraEnabled public List<IdNameWrapper> releaseMOList    { get; set; }

    // ✅ NEW: Detailed MO lists per status
    @AuraEnabled public List<MOWrapper> completeMODetails   { get; set; }
    @AuraEnabled public List<MOWrapper> inProgressMODetails { get; set; }
    @AuraEnabled public List<MOWrapper> draftMODetails      { get; set; }
    @AuraEnabled public List<MOWrapper> cancelledMODetails  { get; set; }
    @AuraEnabled public List<MOWrapper> releaseMODetails    { get; set; }
    public List<String> moNames { get; set; } 

      // --- PO Status Lists ---
@AuraEnabled public List<POWrapper> poDraftList { get; set; }
@AuraEnabled public List<POWrapper> poLoggedList { get; set; }
@AuraEnabled public List<POWrapper> poAssignedList { get; set; }
@AuraEnabled public List<POWrapper> poApprovedList { get; set; }
@AuraEnabled public List<POWrapper> poRejectedList { get; set; }
@AuraEnabled public List<POWrapper> poInProgressList { get; set; }
@AuraEnabled public List<POWrapper> poBookedList { get; set; }
@AuraEnabled public List<POWrapper> poClosedList { get; set; }
@AuraEnabled public List<POWrapper> poCancelledList { get; set; }
@AuraEnabled public List<POWrapper> poSupplierAcceptedList { get; set; }
@AuraEnabled public List<POWrapper> poReconciledList { get; set; }
@AuraEnabled public List<POWrapper> poSubmittedForApprovalList { get; set; }
@AuraEnabled public List<POWrapper> poOnHoldList { get; set; }
    @AuraEnabled public Integer totalPOCount { get; set; }    


    // ---- SALES ORDER FIELDS (NEW) ----
@AuraEnabled public Integer totalSOCount        { get; set; }
@AuraEnabled public Integer soDraftCount        { get; set; }
@AuraEnabled public Integer soEnteredCount      { get; set; }
@AuraEnabled public Integer soActivatedCount    { get; set; }
@AuraEnabled public Integer soPickedUpCount     { get; set; }
@AuraEnabled public Integer soPartShippedCount  { get; set; }
@AuraEnabled public Integer soShippedCount      { get; set; }
@AuraEnabled public Integer soDeliveredCount    { get; set; }
@AuraEnabled public Integer soCancelledCount    { get; set; }

@AuraEnabled public List<SOWrapper> soDraftList            { get; set; }
@AuraEnabled public List<SOWrapper> soEnteredList          { get; set; }
@AuraEnabled public List<SOWrapper> soActivatedList        { get; set; }
@AuraEnabled public List<SOWrapper> soPickedUpList         { get; set; }
@AuraEnabled public List<SOWrapper> soPartiallyShippedList { get; set; }
@AuraEnabled public List<SOWrapper> soShippedList          { get; set; }
@AuraEnabled public List<SOWrapper> soDeliveredList        { get; set; }
@AuraEnabled public List<SOWrapper> soCancelledList        { get; set; }



    public MonthlyPriceDTO(Integer y, Integer m, Decimal avgP, Decimal minP, Decimal maxP) {
        year = y; month = m;
        avgPrice = avgP; minPrice = minP; maxPrice = maxP;
                totalPOCount = 0;


        completeMOList   = new List<IdNameWrapper>();
        inProgressMOList = new List<IdNameWrapper>();
        draftMOList      = new List<IdNameWrapper>();
        cancelledMOList  = new List<IdNameWrapper>();
        releaseMOList    = new List<IdNameWrapper>();

        // init detailed lists
        completeMODetails   = new List<MOWrapper>();
        inProgressMODetails = new List<MOWrapper>();
        draftMODetails      = new List<MOWrapper>();
        cancelledMODetails  = new List<MOWrapper>();
        releaseMODetails    = new List<MOWrapper>();

        moNames = new List<String>();
    }

    public Integer compareTo(Object otherObj) {
        MonthlyPriceDTO other = (MonthlyPriceDTO)otherObj;
        if (this.year != other.year) return this.year - other.year;
        return this.month - other.month;
    }

    public void initPOStatusLists() {
    poDraftList = new List<POWrapper>();
    poLoggedList = new List<POWrapper>();
    poAssignedList = new List<POWrapper>();
    poApprovedList = new List<POWrapper>();
    poRejectedList = new List<POWrapper>();
    poInProgressList = new List<POWrapper>();
    poBookedList = new List<POWrapper>();
    poClosedList = new List<POWrapper>();
    poCancelledList = new List<POWrapper>();
    poSupplierAcceptedList = new List<POWrapper>();
    poReconciledList = new List<POWrapper>();
    poSubmittedForApprovalList = new List<POWrapper>();
    poOnHoldList = new List<POWrapper>();
}
}

   //Sales Price Stats 
    @AuraEnabled(cacheable=true)
    public static Account getDefaultSalesVarianceCustomer(Id companyId, Date fromDate, Date toDate) {
        if (companyId == null) return null;

        if (fromDate == null) fromDate = Date.today().addYears(-1);
        if (toDate == null) toDate = Date.today();

        List<AggregateResult> topCustomers = [
            SELECT Order.AccountId accountId, Order.Account.Name accountName, SUM(Quantity) totalQty
            FROM OrderItem
            WHERE Order.ERP7__Organisation__c = :companyId
            AND Order.EffectiveDate >= :fromDate
            AND Order.EffectiveDate <= :toDate
            AND Order.AccountId != null
            AND Order.Account.ERP7__Account_Type__c = 'Customer'
            GROUP BY Order.AccountId, Order.Account.Name
            ORDER BY SUM(Quantity) DESC
            LIMIT 1
        ];

        if (topCustomers.isEmpty()) return null;

        Id accountId = (Id) topCustomers[0].get('accountId');
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        return accounts.isEmpty() ? null : accounts[0];
    }

    @AuraEnabled(cacheable=true)
    public static Product2 getDefaultSalesVarianceProduct(Id companyId, Id customerId, Date fromDate, Date toDate) {
        if (companyId == null) return null;

        if (fromDate == null) fromDate = Date.today().addYears(-1);
        if (toDate == null) toDate = Date.today();

        List<AggregateResult> topProducts;
        if (customerId != null) {
            topProducts = [
                SELECT Product2Id productId, Product2.Name productName, SUM(Quantity) totalQty
                FROM OrderItem
                WHERE Order.ERP7__Organisation__c = :companyId
                AND Order.AccountId = :customerId
                AND Order.EffectiveDate >= :fromDate
                AND Order.EffectiveDate <= :toDate
                AND Product2Id != null
                GROUP BY Product2Id, Product2.Name
                ORDER BY SUM(Quantity) DESC
                LIMIT 1
            ];
        } else {
            topProducts = [
                SELECT Product2Id productId, Product2.Name productName, SUM(Quantity) totalQty
                FROM OrderItem
                WHERE Order.ERP7__Organisation__c = :companyId
                AND Order.EffectiveDate >= :fromDate
                AND Order.EffectiveDate <= :toDate
                AND Product2Id != null
                GROUP BY Product2Id, Product2.Name
                ORDER BY SUM(Quantity) DESC
                LIMIT 1
            ];
        }

        if (topProducts.isEmpty()) return null;

        Id productId = (Id) topProducts[0].get('productId');
        List<Product2> products = [
            SELECT Id, Name
            FROM Product2
            WHERE Id = :productId
            LIMIT 1
        ];

        return products.isEmpty() ? null : products[0];
    }

    @AuraEnabled(cacheable=true)
    public static List<PriceVarianceWrapper> getSalesPriceData(
        Id productId, 
        Id customerId,
        Id companyId, 
        Date fromDate, 
        Date toDate
    ) {
        // 1. Fetch Actual Sales (Price WITHOUT Price Book)
        // We pull the UnitPrice directly from OrderItem based on your custom ERP7__Organisation__c field
        List<OrderItem> actualSales;
        if (customerId != null) {
            actualSales = [
                SELECT UnitPrice, Order.EffectiveDate 
                FROM OrderItem 
                WHERE Product2Id = :productId 
                AND Order.AccountId = :customerId
                AND Order.ERP7__Organisation__c = :companyId
                AND Order.EffectiveDate >= :fromDate 
                AND Order.EffectiveDate <= :toDate
                ORDER BY Order.EffectiveDate ASC
            ];
        } else {
            actualSales = [
                SELECT UnitPrice, Order.EffectiveDate 
                FROM OrderItem 
                WHERE Product2Id = :productId 
                AND Order.ERP7__Organisation__c = :companyId
                AND Order.EffectiveDate >= :fromDate 
                AND Order.EffectiveDate <= :toDate
                ORDER BY Order.EffectiveDate ASC
            ];
        }

        // 2. Fetch Price Book History (To determine Price WITH Price Book)
        // This allows us to see what the price was BEFORE it was changed
        List<PricebookEntryHistory> historyList = [
            SELECT OldValue, NewValue, CreatedDate 
            FROM PricebookEntryHistory 
            WHERE PricebookEntry.Product2Id = :productId
            AND Field = 'UnitPrice'
            ORDER BY CreatedDate DESC
        ];

        // 3. Get Current Price Book Entry (The "Now" value)
        List<PricebookEntry> currentPBEList = [
            SELECT UnitPrice
            FROM PricebookEntry
            WHERE Product2Id = :productId
            AND IsActive = true
            LIMIT 1
        ];
        Decimal currentBookPrice = !currentPBEList.isEmpty() ? currentPBEList[0].UnitPrice : 0;

        List<PriceVarianceWrapper> wrapperList = new List<PriceVarianceWrapper>();

        // 4. Map-Reduce Logic to align dates
        for (OrderItem item : actualSales) {
            PriceVarianceWrapper record = new PriceVarianceWrapper();
            record.orderDate = item.Order.EffectiveDate;
            record.actualSoldPrice = item.UnitPrice;
            
            // Calculate what the Price Book was on the day the order was placed
            record.bookPriceAtTime = calculateBookPrice(item.Order.EffectiveDate, historyList, currentBookPrice);
            
            wrapperList.add(record);
        }

        return wrapperList;
    }

// Purchase price variance stats 
    @AuraEnabled(cacheable=true)
    public static Account getDefaultPurchaseVarianceSupplier(Id companyId, Date fromDate, Date toDate) {
        if (companyId == null) return null;

        if (fromDate == null) fromDate = Date.today().addYears(-1);
        if (toDate == null) toDate = Date.today();

        List<AggregateResult> topSuppliers = [
            SELECT ERP7__Purchase_Orders__r.ERP7__Vendor__c supplierId,
                   ERP7__Purchase_Orders__r.ERP7__Vendor__r.Name supplierName,
                   SUM(ERP7__Quantity__c) totalQty
            FROM ERP7__Purchase_Line_Items__c
            WHERE ERP7__Purchase_Orders__r.ERP7__Organisation__c = :companyId
            AND ERP7__Purchase_Orders__r.ERP7__Order_Date__c >= :fromDate
            AND ERP7__Purchase_Orders__r.ERP7__Order_Date__c <= :toDate
            AND ERP7__Purchase_Orders__r.ERP7__Vendor__c != null
            AND ERP7__Purchase_Orders__r.ERP7__Vendor__r.ERP7__Account_Type__c = 'Vendor'
            GROUP BY ERP7__Purchase_Orders__r.ERP7__Vendor__c, ERP7__Purchase_Orders__r.ERP7__Vendor__r.Name
            ORDER BY SUM(ERP7__Quantity__c) DESC
            LIMIT 1
        ];

        if (topSuppliers.isEmpty()) return null;

        Id supplierId = (Id) topSuppliers[0].get('supplierId');
        List<Account> suppliers = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :supplierId
            LIMIT 1
        ];

        return suppliers.isEmpty() ? null : suppliers[0];
    }

    @AuraEnabled(cacheable=true)
    public static Product2 getDefaultPurchaseVarianceProduct(Id companyId, Id supplierId, Date fromDate, Date toDate) {
        if (companyId == null) return null;

        if (fromDate == null) fromDate = Date.today().addYears(-1);
        if (toDate == null) toDate = Date.today();

        List<AggregateResult> topProducts;
        if (supplierId != null) {
            topProducts = [
                SELECT ERP7__Product__c productId, ERP7__Product__r.Name productName, SUM(ERP7__Quantity__c) totalQty
                FROM ERP7__Purchase_Line_Items__c
                WHERE ERP7__Purchase_Orders__r.ERP7__Organisation__c = :companyId
                AND ERP7__Purchase_Orders__r.ERP7__Vendor__c = :supplierId
                AND ERP7__Purchase_Orders__r.ERP7__Order_Date__c >= :fromDate
                AND ERP7__Purchase_Orders__r.ERP7__Order_Date__c <= :toDate
                AND ERP7__Product__c != null
                GROUP BY ERP7__Product__c, ERP7__Product__r.Name
                ORDER BY SUM(ERP7__Quantity__c) DESC
                LIMIT 1
            ];
        } else {
            topProducts = [
                SELECT ERP7__Product__c productId, ERP7__Product__r.Name productName, SUM(ERP7__Quantity__c) totalQty
                FROM ERP7__Purchase_Line_Items__c
                WHERE ERP7__Purchase_Orders__r.ERP7__Organisation__c = :companyId
                AND ERP7__Purchase_Orders__r.ERP7__Order_Date__c >= :fromDate
                AND ERP7__Purchase_Orders__r.ERP7__Order_Date__c <= :toDate
                AND ERP7__Product__c != null
                GROUP BY ERP7__Product__c, ERP7__Product__r.Name
                ORDER BY SUM(ERP7__Quantity__c) DESC
                LIMIT 1
            ];
        }

        if (topProducts.isEmpty()) return null;

        Id productId = (Id) topProducts[0].get('productId');
        List<Product2> products = [
            SELECT Id, Name
            FROM Product2
            WHERE Id = :productId
            LIMIT 1
        ];

        return products.isEmpty() ? null : products[0];
    }

    @AuraEnabled(cacheable=true)
    public static List<PurchasePriceVarianceWrapper> getPurchasePriceData(
        Id productId,
        Id supplierId,
        Id companyId,
        Date fromDate,
        Date toDate
    ) {
        if (productId == null) return new List<PurchasePriceVarianceWrapper>();

        if (fromDate == null) fromDate = Date.today().addYears(-1);
        if (toDate == null) toDate = Date.today();

        String lineItemQuery =
            'SELECT ERP7__Unit_Price__c, ERP7__Product__c, ERP7__Purchase_Orders__c, ' +
            '       ERP7__Purchase_Orders__r.Name, ERP7__Purchase_Orders__r.ERP7__Order_Date__c, ' +
            '       ERP7__Purchase_Orders__r.ERP7__Vendor__c, ERP7__Purchase_Orders__r.ERP7__Vendor__r.Name ' +
            'FROM ERP7__Purchase_Line_Items__c ' +
            'WHERE ERP7__Product__c = :productId ' +
            'AND ERP7__Purchase_Orders__r.ERP7__Order_Date__c >= :fromDate ' +
            'AND ERP7__Purchase_Orders__r.ERP7__Order_Date__c <= :toDate ';

        if (supplierId != null) {
            lineItemQuery += 'AND ERP7__Purchase_Orders__r.ERP7__Vendor__c = :supplierId ';
        }
        if (companyId != null) {
            lineItemQuery += 'AND ERP7__Purchase_Orders__r.ERP7__Organisation__c = :companyId ';
        }

        lineItemQuery += 'ORDER BY ERP7__Purchase_Orders__r.ERP7__Order_Date__c ASC';

        List<ERP7__Purchase_Line_Items__c> purchaseLines = Database.query(lineItemQuery);

        List<ERP7__Cost_Card__c> relevantCostCards = getRelevantCostCards(
            productId,
            supplierId,
            fromDate,
            toDate
        );

        List<PurchasePriceVarianceWrapper> wrapperList = new List<PurchasePriceVarianceWrapper>();
        for (ERP7__Purchase_Line_Items__c item : purchaseLines) {
            PurchasePriceVarianceWrapper record = new PurchasePriceVarianceWrapper();
            record.orderDate = item.ERP7__Purchase_Orders__r.ERP7__Order_Date__c;
            record.actualPurchasePrice = item.ERP7__Unit_Price__c;
            record.costPriceAtTime = calculateCostCardPrice(record.orderDate, relevantCostCards);
            record.purchaseOrderId = item.ERP7__Purchase_Orders__c;
            record.purchaseOrderName = item.ERP7__Purchase_Orders__r.Name;
            record.supplierId = item.ERP7__Purchase_Orders__r.ERP7__Vendor__c;
            record.supplierName = item.ERP7__Purchase_Orders__r.ERP7__Vendor__r != null ? item.ERP7__Purchase_Orders__r.ERP7__Vendor__r.Name : null;
            wrapperList.add(record);
        }

        return wrapperList;
    }

    /**
     * Logic: Compares Order Date against History logs. 
     * If an order was placed before a price change, use the 'OldValue'.
     */
 private static Decimal calculateBookPrice(Date orderDate, List<PricebookEntryHistory> history, Decimal currentPrice) {
    for (PricebookEntryHistory h : history) {
        if (orderDate < h.CreatedDate.date()) {
            // Convert the AnyType (String) to a String first, then to a Decimal
            String oldValStr = String.valueOf(h.OldValue);
            return (oldValStr != null) ? Decimal.valueOf(oldValStr) : 0;
        }
    }
    return currentPrice;
}

    public class PriceVarianceWrapper {
        @AuraEnabled public Date orderDate;
        @AuraEnabled public Decimal actualSoldPrice; // "Without Price Book"
        @AuraEnabled public Decimal bookPriceAtTime; // "With Price Book"
    }

    private static List<ERP7__Cost_Card__c> getRelevantCostCards(
        Id productId,
        Id supplierId,
        Date fromDate,
        Date toDate
    ) {
        String exactQuery =
            'SELECT Id, ERP7__Cost__c, ERP7__Product__c, ERP7__Supplier__c, ERP7__Start_Date__c, ERP7__End_Date__c ' +
            'FROM ERP7__Cost_Card__c ' +
            'WHERE ERP7__Product__c = :productId ' +
            'AND (ERP7__Start_Date__c = null OR ERP7__Start_Date__c <= :toDate) ' +
            'AND (ERP7__End_Date__c = null OR ERP7__End_Date__c >= :fromDate) ';

        if (supplierId != null) {
            exactQuery += 'AND ERP7__Supplier__c = :supplierId ';
        }

        exactQuery += 'ORDER BY ERP7__Start_Date__c DESC, ERP7__End_Date__c DESC';

        List<ERP7__Cost_Card__c> costCards = Database.query(exactQuery);

        if (costCards.isEmpty() && supplierId != null) {
            costCards = [
                SELECT Id, ERP7__Cost__c, ERP7__Product__c, ERP7__Supplier__c, ERP7__Start_Date__c, ERP7__End_Date__c
                FROM ERP7__Cost_Card__c
                WHERE ERP7__Product__c = :productId
                AND ERP7__Supplier__c = null
                AND (ERP7__Start_Date__c = null OR ERP7__Start_Date__c <= :toDate)
                AND (ERP7__End_Date__c = null OR ERP7__End_Date__c >= :fromDate)
                ORDER BY ERP7__Start_Date__c DESC, ERP7__End_Date__c DESC
            ];
        }

        return costCards;
    }

    private static Decimal calculateCostCardPrice(Date orderDate, List<ERP7__Cost_Card__c> costCards) {
        if (costCards == null || costCards.isEmpty()) return 0;

        ERP7__Cost_Card__c fallbackCard;
        for (ERP7__Cost_Card__c card : costCards) {
            if (fallbackCard == null) {
                fallbackCard = card;
            }

            Boolean startsBeforeOrOn = (card.ERP7__Start_Date__c == null || card.ERP7__Start_Date__c <= orderDate);
            Boolean endsAfterOrOn = (card.ERP7__End_Date__c == null || card.ERP7__End_Date__c >= orderDate);
            if (startsBeforeOrOn && endsAfterOrOn) {
                return card.ERP7__Cost__c != null ? card.ERP7__Cost__c : 0;
            }
        }

        return fallbackCard != null && fallbackCard.ERP7__Cost__c != null ? fallbackCard.ERP7__Cost__c : 0;
    }

    public class PurchasePriceVarianceWrapper {
        @AuraEnabled public Date orderDate;
        @AuraEnabled public Decimal actualPurchasePrice;
        @AuraEnabled public Decimal costPriceAtTime;
        @AuraEnabled public Id purchaseOrderId;
        @AuraEnabled public String purchaseOrderName;
        @AuraEnabled public Id supplierId;
        @AuraEnabled public String supplierName;
    }
}