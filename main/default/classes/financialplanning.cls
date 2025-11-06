public with sharing class financialplanning {



    //Saqlain part Code 

     @AuraEnabled(cacheable=true)
    public static String getCurrencySymbol() {
    Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
    String currencyISO;
    Decimal currencyRate;
    String userIsoCode;

    String selectedIso = null; // ← no input, uses user's default

    if (selectedIso != null) {
        currencyISO = selectedIso;
    } else {
        currencyISO = UserInfo.getDefaultCurrency();
    }

    if (multiCurrencyEnabled) {
        userIsoCode = currencyISO;
        String iso = userIsoCode;
        String q = 'SELECT IsoCode, conversionRate FROM CurrencyType WHERE IsoCode = :iso';
        currencyRate = (Decimal) Database.query(q)[0].get('conversionRate');
    } else {
        userIsoCode = currencyISO;
        currencyRate = 1;
    }

    // ✅ Symbol mapping
    Map<String, String> symbolMap = new Map<String, String>{
        'USD' => '$',
        'GBP' => '£',
        'EUR' => '€',
        'JPY' => '¥'
    };

    return symbolMap.containsKey(currencyISO) ? symbolMap.get(currencyISO) : currencyISO;
}


    @AuraEnabled(cacheable=true)
    public static Account getDefaultOrg() {
      
      return UtilClass.getOrganisationByLogin_Employee();
}

   @AuraEnabled(cacheable=true)
public static Map<String, List<Decimal>> getMonthlyCreditDebitSummary(Integer year) {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    System.debug('🔍 Organisation ID: ' + org.Id);
    System.debug('📅 Filtering by Year: ' + year);

    // Get credit notes with valid date
    List<AggregateResult> creditResults = [
        SELECT CALENDAR_MONTH(ERP7__Date__c) month, SUM(ERP7__Balance__c) total
        FROM ERP7__Credit_Note__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Date__c != null
            AND CALENDAR_YEAR(ERP7__Date__c) = :year
        GROUP BY CALENDAR_MONTH(ERP7__Date__c)
        ORDER BY CALENDAR_MONTH(ERP7__Date__c)
    ];

    // Get debit notes with valid date
    List<AggregateResult> debitResults = [
        SELECT CALENDAR_MONTH(ERP7__Credit_Note_Date__c) month, SUM(ERP7__Debit__c) total
        FROM ERP7__Debit_Note__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Credit_Note_Date__c != null
            AND CALENDAR_YEAR(ERP7__Credit_Note_Date__c) = :year
        GROUP BY CALENDAR_MONTH(ERP7__Credit_Note_Date__c)
        ORDER BY CALENDAR_MONTH(ERP7__Credit_Note_Date__c)
    ];

    List<Decimal> credits = new List<Decimal>(new Decimal[12]);
    List<Decimal> debits = new List<Decimal>(new Decimal[12]);

    for (AggregateResult ar : creditResults) {
        Integer month = (Integer) ar.get('month');        Decimal total = (Decimal) ar.get('total');        credits[month - 1] = total;
        System.debug('✅ Credit - Month: ' + month + ', Amount: ' + total);
    }

    for (AggregateResult ar : debitResults) {
        Integer month = (Integer) ar.get('month');        Decimal total = (Decimal) ar.get('total');        debits[month - 1] = total;
        System.debug('✅ Debit - Month: ' + month + ', Amount: ' + total);
    }

    for (Integer i = 0; i < 12; i++) {
        if (credits[i] == null) credits[i] = 0;
        if (debits[i] == null) debits[i] = 0;
    }

    System.debug('📈 Final Monthly Credits: ' + credits);
    System.debug('📉 Final Monthly Debits: ' + debits);

    return new Map<String, List<Decimal>>{
        'credits' => credits,
        'debits' => debits
    };
}


// @AuraEnabled(cacheable=true)
// public static Map<String, List<Decimal>> getMonthlyIncomeExpense(Integer year) {
//     Account org = UtilClass.getOrganisationByLogin_Employee();
//     System.debug('🔍 Organisation: ' + org);
//     System.debug('📅 Year filter: ' + year);

//     List<AggregateResult> invoiceResults = [
//         SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
//         FROM ERP7__Invoice__c
//         WHERE ERP7__Paid__c = true
//             AND ERP7__Organisation__c = :org.Id
//             AND ERP7__Invoice_Date__c != null
//             AND CALENDAR_YEAR(ERP7__Invoice_Date__c) = :year
//         GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
//         ORDER BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
//     ];

//     List<AggregateResult> billResults = [
//         SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
//         FROM ERP7__Bill__c
//         WHERE ERP7__Status__c = 'Paid'
//             AND ERP7__Organisation__c = :org.Id
//             AND ERP7__Bill_Date__c != null
//             AND CALENDAR_YEAR(ERP7__Bill_Date__c) = :year
//         GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
//         ORDER BY CALENDAR_MONTH(ERP7__Bill_Date__c)
//     ];

//     List<Decimal> income = new List<Decimal>(new Decimal[12]);
//     List<Decimal> expense = new List<Decimal>(new Decimal[12]);

//     for (AggregateResult ar : invoiceResults) {
//         Integer m = (Integer) ar.get('month');        Decimal total = (Decimal) ar.get('total');        income[m - 1] = total;
//         System.debug('✅ Income → Month ' + m + ': ₹' + total);
//     }

//     for (AggregateResult ar : billResults) {
//         Integer m = (Integer) ar.get('month');        Decimal total = (Decimal) ar.get('total');        expense[m - 1] = total;
//         System.debug('✅ Expense → Month ' + m + ': ₹' + total);
//     }

//     // ✅ Replace nulls with 0 before returning
//     for (Integer i = 0; i < 12; i++) {
//         if (income[i] == null) income[i] = 0;
//         if (expense[i] == null) expense[i] = 0;
//     }

//     System.debug('📈 Final Income Array: ' + income);
//     System.debug('📉 Final Expense Array: ' + expense);

//     return new Map<String, List<Decimal>>{
//         'income' => income,
//         'expense' => expense
//     };
// }


@AuraEnabled(cacheable=true)
public static Map<String, List<Decimal>> getMonthlyIncomeExpense(Integer year) {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    System.debug('🔍 Organisation: ' + org);
    System.debug('📅 Year filter: ' + year);

    List<AggregateResult> invoiceResults = [
        SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
        FROM ERP7__Invoice__c
        WHERE ERP7__Paid__c = true
            AND ERP7__Organisation__c = :org.Id
            AND ERP7__Invoice_Date__c != null
            AND CALENDAR_YEAR(ERP7__Invoice_Date__c) = :year
        GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
        ORDER BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
    ];

    List<AggregateResult> billResults = [
        SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Status__c = 'Paid'
            AND ERP7__Organisation__c = :org.Id
            AND ERP7__Bill_Date__c != null
            AND CALENDAR_YEAR(ERP7__Bill_Date__c) = :year
        GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
        ORDER BY CALENDAR_MONTH(ERP7__Bill_Date__c)
    ];

    List<AggregateResult> expenseResults = [
        SELECT CALENDAR_MONTH(ERP7__Date__c) month, SUM(ERP7__Amount__c) total
        FROM ERP7__Expense__c
        WHERE ERP7__Paid__c = true
            AND ERP7__Date__c != null
            AND CALENDAR_YEAR(ERP7__Date__c) = :year
        GROUP BY CALENDAR_MONTH(ERP7__Date__c)
        ORDER BY CALENDAR_MONTH(ERP7__Date__c)
    ];

    List<Decimal> income = new List<Decimal>(new Decimal[12]);
    List<Decimal> expense = new List<Decimal>(new Decimal[12]);
    List<Decimal> additionalExpense = new List<Decimal>(new Decimal[12]);

    for (AggregateResult ar : invoiceResults) {
        Integer m = (Integer) ar.get('month');
        Decimal total = (Decimal) ar.get('total');
        income[m - 1] = total;
        System.debug('✅ Income → Month ' + m + ': ₹' + total);
    }

    for (AggregateResult ar : billResults) {
        Integer m = (Integer) ar.get('month');
        Decimal total = (Decimal) ar.get('total');
        expense[m - 1] = total;
        System.debug('✅ Bill Expense → Month ' + m + ': ₹' + total);
    }

    for (AggregateResult ar : expenseResults) {
        Integer m = (Integer) ar.get('month');
        Decimal total = (Decimal) ar.get('total');
        additionalExpense[m - 1] = total;
        System.debug('🆕 Extra Expense → Month ' + m + ': ₹' + total);
    }

    // Combine both expenses, replace nulls with 0
    for (Integer i = 0; i < 12; i++) {
        if (income[i] == null) income[i] = 0;
        if (expense[i] == null) expense[i] = 0;
        if (additionalExpense[i] == null) additionalExpense[i] = 0;
        expense[i] += additionalExpense[i];
    }

    System.debug('📈 Final Income Array: ' + income);
    System.debug('📉 Final Expense Array (combined): ' + expense);

    return new Map<String, List<Decimal>>{
        'income' => income,
        'expense' => expense
    };
}

@AuraEnabled(cacheable=true)
public static Map<String, List<Object>> getChartOfAccountsByType(String recordType) {
    Account org = UtilClass.getOrganisationByLogin_Employee();

    List<ERP7__Chart_of_Accounts__c> coaList = [
        SELECT Name, ERP7__Total_Debit__c, ERP7__Total_Credit__c
        FROM ERP7__Chart_of_Accounts__c
        WHERE RecordType.Name = :recordType
            AND ERP7__Organisation__c = :org.Id
            AND (ERP7__Total_Debit__c > 5000 OR ERP7__Total_Credit__c > 5000)
    ];

    List<String> labels = new List<String>();
    List<Decimal> debits = new List<Decimal>();
    List<Decimal> credits = new List<Decimal>();

    for (ERP7__Chart_of_Accounts__c coa : coaList) {
        labels.add(coa.Name);        debits.add(coa.ERP7__Total_Debit__c != null ? coa.ERP7__Total_Debit__c : 0);        credits.add(coa.ERP7__Total_Credit__c != null ? coa.ERP7__Total_Credit__c : 0);
    }

    return new Map<String, List<Object>>{
        'labels' => labels,
        'debits' => debits,
        'credits' => credits
    };
}


@AuraEnabled(cacheable=true)
public static Map<String, Object> getCustomerInvoiceSummary(String type) {
    System.debug('--- Method Entry: getCustomerInvoiceSummary ---');
    System.debug('Type: ' + type);

    Map<String, Decimal> summaryMap = new Map<String, Decimal>();
    Map<String, Integer> countMap = new Map<String, Integer>();

    if (type == 'Overdue') {
        List<ERP7__Invoice__c> overdueInvoices = [
            SELECT Id, Name, ERP7__Account__r.Name, ERP7__Sub_Total_Amount__c, ERP7__Status__c
            FROM ERP7__Invoice__c
            WHERE ERP7__Status__c = 'Overdue'
        ];

        System.debug('Overdue Invoices Count: ' + overdueInvoices.size());
        System.debug('Overdue Invoices: ' + JSON.serialize(overdueInvoices));   

        for (ERP7__Invoice__c inv : overdueInvoices) {
            String customer = inv.ERP7__Account__r != null ? inv.ERP7__Account__r.Name : 'Unknown';           Decimal amount = inv.ERP7__Sub_Total_Amount__c != null ? inv.ERP7__Sub_Total_Amount__c : 0;

            if (!summaryMap.containsKey(customer)) {               summaryMap.put(customer, amount);                countMap.put(customer, 1);
            } else {
                summaryMap.put(customer, summaryMap.get(customer) + amount);                countMap.put(customer, countMap.get(customer) + 1);
            }

            System.debug('Customer: ' + customer + ', Amount: ' + amount);
        }
    } else if (type == 'Unpaid') {        Date today = Date.today();

        List<ERP7__Bill__c> unpaidBills = [
            SELECT Id, Name, ERP7__Vendor__r.Name, ERP7__Total_Amount__c, ERP7__Due_Date__c, ERP7__Status__c
            FROM ERP7__Bill__c
            WHERE ERP7__Status__c != 'Paid' AND ERP7__Due_Date__c < :today 
        ];

        System.debug('Unpaid Bills Count: ' + unpaidBills.size());
        System.debug('Unpaid Bills: ' + JSON.serialize(unpaidBills));

        for (ERP7__Bill__c bill : unpaidBills) {            String vendor = bill.ERP7__Vendor__r != null ? bill.ERP7__Vendor__r.Name : 'Unknown';            Decimal amount = bill.ERP7__Total_Amount__c != null ? bill.ERP7__Total_Amount__c : 0;

            if (!summaryMap.containsKey(vendor)) {               summaryMap.put(vendor, amount);                countMap.put(vendor, 1);
            } else {
                summaryMap.put(vendor, summaryMap.get(vendor) + amount);                countMap.put(vendor, countMap.get(vendor) + 1);
            }

            System.debug('Vendor: ' + vendor + ', Amount: ' + amount);
        }
    }

    List<String> labels = new List<String>();
    List<Decimal> amounts = new List<Decimal>();
    List<Integer> counts = new List<Integer>();

    for (String key : summaryMap.keySet()) {
        labels.add(key);        amounts.add(summaryMap.get(key));        counts.add(countMap.get(key));
        System.debug('Summary Entry - Name: ' + key + ', Amount: ' + summaryMap.get(key) + ', Count: ' + countMap.get(key));
    }

    Map<String, Object> result = new Map<String, Object>();
    result.put('labels', labels);
    result.put('amounts', amounts);
    result.put('counts', counts);

    System.debug('--- Method Exit: getCustomerInvoiceSummary ---');
    return result;
}

public class InvoiceBillDetail {
    @AuraEnabled public String recordName { get; set; }
    @AuraEnabled public String recordId { get; set; }
    @AuraEnabled public Decimal amount { get; set; }

    public InvoiceBillDetail(String recordName, Decimal amount, String recordId) {
        this.recordName = recordName;
        this.recordId = recordId;
        this.amount = amount;
    }
}

@AuraEnabled(cacheable=true)
public static Map<String, List<InvoiceBillDetail>> getGroupedInvoiceBillDetails(String type) {
    Map<String, List<InvoiceBillDetail>> groupedData = new Map<String, List<InvoiceBillDetail>>();

    if (type == 'Overdue') {
        List<ERP7__Invoice__c> invoices = [
            SELECT Id, Name, ERP7__Account__r.Name, ERP7__Sub_Total_Amount__c
            FROM ERP7__Invoice__c
            WHERE ERP7__Status__c = 'Overdue'
        ];

        for (ERP7__Invoice__c inv : invoices) {
            System.debug('Processing Invoice: ' + inv.Name);
            System.debug('Customer: ' + (inv.ERP7__Account__r != null ? inv.ERP7__Account__r.Name : 'Unknown'));
            System.debug('Sub Total Amount: ' + (inv.ERP7__Sub_Total_Amount__c != null ? inv.ERP7__Sub_Total_Amount__c : 0));
            String invoiceId = inv.Id;
            String customer = inv.ERP7__Account__r != null ? inv.ERP7__Account__r.Name : 'Unknown';
            Decimal amount = inv.ERP7__Sub_Total_Amount__c != null ? inv.ERP7__Sub_Total_Amount__c : 0;

            if (!groupedData.containsKey(customer)) {
                groupedData.put(customer, new List<InvoiceBillDetail>());
            }
            groupedData.get(customer).add(new InvoiceBillDetail(inv.Name, amount, invoiceId));
        }
    }
    else if (type == 'Unpaid') {
        Date today = Date.today();

        List<ERP7__Bill__c> bills = [
            SELECT Id, Name, ERP7__Vendor__r.Name, ERP7__Total_Amount__c
            FROM ERP7__Bill__c
            WHERE ERP7__Status__c != 'Paid' AND ERP7__Due_Date__c < :today
        ];

        for (ERP7__Bill__c bill : bills) {
            System.debug('Processing Bill: ' + bill.Name);
            System.debug('Vendor: ' + (bill.ERP7__Vendor__r != null ? bill.ERP7__Vendor__r.Name : 'Unknown'));
            System.debug('Total Amount: ' + (bill.ERP7__Total_Amount__c != null ? bill.ERP7__Total_Amount__c : 0));
            String billId = bill.Id;
            String vendor = bill.ERP7__Vendor__r != null ? bill.ERP7__Vendor__r.Name : 'Unknown';
            Decimal amount = bill.ERP7__Total_Amount__c != null ? bill.ERP7__Total_Amount__c : 0;

            if (!groupedData.containsKey(vendor)) {
                groupedData.put(vendor, new List<InvoiceBillDetail>());
            }
            groupedData.get(vendor).add(new InvoiceBillDetail(bill.Name, amount, billId));
        }
    }

    return groupedData;
}



  public class ProductRevenueCostDTO {
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal cost;
        @AuraEnabled public Decimal revenue;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductRevenueCostDTO> getRevenueCostPerProduct() {
        Account org = UtilClass.getOrganisationByLogin_Employee();
        System.debug('🔍 Organisation ID: ' + org.Id);

        Map<Id, ProductRevenueCostDTO> productMap = new Map<Id, ProductRevenueCostDTO>();

        // 🔻 Get Purchase Line Items (calculate cost)
        List<ERP7__Purchase_Line_Items__c> purchaseLines = [
            SELECT ERP7__Product__c, ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Unit_Price__c
            FROM ERP7__Purchase_Line_Items__c
            WHERE ERP7__Product__c != null
              AND ERP7__Organisation__c = :org.Id
        ];

        for (ERP7__Purchase_Line_Items__c item : purchaseLines) {
            if (!productMap.containsKey(item.ERP7__Product__c)) {                ProductRevenueCostDTO dto = new ProductRevenueCostDTO();              dto.productName = item.ERP7__Product__r.Name;                dto.cost = 0;                dto.revenue = 0;                productMap.put(item.ERP7__Product__c, dto);
            }

            Decimal lineCost = (item.ERP7__Quantity__c != null ? item.ERP7__Quantity__c : 0) *                               (item.ERP7__Unit_Price__c != null ? item.ERP7__Unit_Price__c : 0);           productMap.get(item.ERP7__Product__c).cost += lineCost;

            System.debug('💰 COST → ' + item.ERP7__Product__r.Name + ' + ' + lineCost);
        }

        // 🔻 Get Sales Line Items (use Total_Price)
        List<ERP7__Sales_Order_Line_Item__c> salesLines = [
            SELECT ERP7__Product__c, ERP7__Product__r.Name, ERP7__Total_Price__c
            FROM ERP7__Sales_Order_Line_Item__c
            WHERE ERP7__Product__c != null
              AND ERP7__Organisation__c = :org.Id
        ];

        for (ERP7__Sales_Order_Line_Item__c item : salesLines) {
            if (!productMap.containsKey(item.ERP7__Product__c)) {                ProductRevenueCostDTO dto = new ProductRevenueCostDTO();                dto.productName = item.ERP7__Product__r.Name;                dto.cost = 0;                dto.revenue = 0;                productMap.put(item.ERP7__Product__c, dto);
            }

            Decimal revenue = item.ERP7__Total_Price__c != null ? item.ERP7__Total_Price__c : 0;            productMap.get(item.ERP7__Product__c).revenue += revenue;

            System.debug('📈 REVENUE → ' + item.ERP7__Product__r.Name + ' + ' + revenue);
        }

        // ✅ Filter: Only products with both cost > 0 and revenue > 0
        List<ProductRevenueCostDTO> result = new List<ProductRevenueCostDTO>();
        for (ProductRevenueCostDTO dto : productMap.values()) {
            if (dto.cost > 0 && dto.revenue > 0) {                result.add(dto);
            }
        }

        System.debug('📊 Filtered Result (Cost > 0 & Revenue > 0): ' + result);
        return result;
    }



    //   @AuraEnabled(cacheable=true)
    // public static Map<String, Map<String, List<Decimal>>> getMonthlyIncomeExpensenew(Date fromDate, Date toDate) {
    //     Account org = UtilClass.getOrganisationByLogin_Employee();

    //     List<Decimal> paidIncome = new List<Decimal>(new Decimal[12]);
    //     List<Decimal> unpaidIncome = new List<Decimal>(new Decimal[12]);
    //     List<Decimal> paidExpense = new List<Decimal>(new Decimal[12]);
    //     List<Decimal> unpaidExpense = new List<Decimal>(new Decimal[12]);

    //     // ✅ Paid Invoices (Income)
    //     List<AggregateResult> paidInvoiceResults = [
    //         SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
    //         FROM ERP7__Invoice__c
    //         WHERE ERP7__Organisation__c = :org.Id
    //             AND ERP7__Paid__c = true
    //             AND ERP7__Invoice_Date__c != null
    //             AND ERP7__Invoice_Date__c >= :fromDate
    //             AND ERP7__Invoice_Date__c <= :toDate
    //         GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
    //     ];

    //     // ✅ Unpaid Invoices (Income)
    //     List<AggregateResult> unpaidInvoiceResults = [
    //         SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
    //         FROM ERP7__Invoice__c
    //         WHERE ERP7__Organisation__c = :org.Id
    //             AND ERP7__Paid__c = false
    //             AND ERP7__Invoice_Date__c != null
    //             AND ERP7__Invoice_Date__c >= :fromDate
    //             AND ERP7__Invoice_Date__c <= :toDate
    //         GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
    //     ];

    //     // ✅ Paid Bills (Expenses)
    //     List<AggregateResult> paidBillResults = [
    //         SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
    //         FROM ERP7__Bill__c
    //         WHERE ERP7__Organisation__c = :org.Id
    //             AND ERP7__Status__c = 'Paid'
    //             AND ERP7__Bill_Date__c != null
    //             AND ERP7__Bill_Date__c >= :fromDate
    //             AND ERP7__Bill_Date__c <= :toDate
    //         GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
    //     ];

    //     // ✅ Unpaid Bills (Expenses)
    //     List<AggregateResult> unpaidBillResults = [
    //         SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
    //         FROM ERP7__Bill__c
    //         WHERE ERP7__Organisation__c = :org.Id
    //             AND ERP7__Status__c != 'Paid'
    //             AND ERP7__Bill_Date__c != null
    //             AND ERP7__Bill_Date__c >= :fromDate
    //             AND ERP7__Bill_Date__c <= :toDate
    //         GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
    //     ];

    //     // 🔄 Process Results
    //     for (AggregateResult ar : paidInvoiceResults) {
    //         Integer month = (Integer) ar.get('month');            paidIncome[month - 1] = (Decimal) ar.get('total');
    //     }
    //     for (AggregateResult ar : unpaidInvoiceResults) {
    //         Integer month = (Integer) ar.get('month');            unpaidIncome[month - 1] = (Decimal) ar.get('total');
    //     }
    //     for (AggregateResult ar : paidBillResults) {
    //         Integer month = (Integer) ar.get('month');          paidExpense[month - 1] = (Decimal) ar.get('total');
    //     }
    //     for (AggregateResult ar : unpaidBillResults) {
    //         Integer month = (Integer) ar.get('month');            unpaidExpense[month - 1] = (Decimal) ar.get('total');
    //     }

    //     // 💡 Null safety
    //     for (Integer i = 0; i < 12; i++) {
    //         if (paidIncome[i] == null) paidIncome[i] = 0;
    //         if (unpaidIncome[i] == null) unpaidIncome[i] = 0;
    //         if (paidExpense[i] == null) paidExpense[i] = 0;
    //         if (unpaidExpense[i] == null) unpaidExpense[i] = 0;
    //     }

    //     return new Map<String, Map<String, List<Decimal>>>{
    //         'paid' => new Map<String, List<Decimal>>{
    //             'income' => paidIncome,
    //             'expense' => paidExpense
    //         },
    //         'unpaid' => new Map<String, List<Decimal>>{
    //             'income' => unpaidIncome,
    //             'expense' => unpaidExpense
    //         }
    //     };
    // }


    @AuraEnabled(cacheable=true)
public static Map<String, Map<String, List<Decimal>>> getMonthlyIncomeExpensenew(Date fromDate, Date toDate) {
    Account org = UtilClass.getOrganisationByLogin_Employee();

    List<Decimal> paidIncome = new List<Decimal>(new Decimal[12]);
    List<Decimal> unpaidIncome = new List<Decimal>(new Decimal[12]);
    List<Decimal> paidExpense = new List<Decimal>(new Decimal[12]);
    List<Decimal> unpaidExpense = new List<Decimal>(new Decimal[12]);

    // ✅ Paid Invoices (Income)
    List<AggregateResult> paidInvoiceResults = [
        SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
        FROM ERP7__Invoice__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Paid__c = true
            AND ERP7__Invoice_Date__c != null
            AND ERP7__Invoice_Date__c >= :fromDate
            AND ERP7__Invoice_Date__c <= :toDate
        GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
    ];

    // ✅ Unpaid Invoices (Income)
    List<AggregateResult> unpaidInvoiceResults = [
        SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
        FROM ERP7__Invoice__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Paid__c = false
            AND ERP7__Invoice_Date__c != null
            AND ERP7__Invoice_Date__c >= :fromDate
            AND ERP7__Invoice_Date__c <= :toDate
        GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
    ];

    // ✅ Paid Bills (Expenses)
    List<AggregateResult> paidBillResults = [
        SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Status__c = 'Paid'
            AND ERP7__Bill_Date__c != null
            AND ERP7__Bill_Date__c >= :fromDate
            AND ERP7__Bill_Date__c <= :toDate
        GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
    ];

    // ✅ Unpaid Bills (Expenses)
    List<AggregateResult> unpaidBillResults = [
        SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Status__c != 'Paid'
            AND ERP7__Bill_Date__c != null
            AND ERP7__Bill_Date__c >= :fromDate
            AND ERP7__Bill_Date__c <= :toDate
        GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
    ];

    // ✅ Paid My Expenses
    List<AggregateResult> paidMyExpenseResults = [
        SELECT CALENDAR_MONTH(ERP7__Date__c) month, SUM(ERP7__Amount__c) total
        FROM ERP7__Expense__c
       // WHERE ERP7__Organisation__c = :org.Id
            WHERE ERP7__Paid__c = true
            AND ERP7__Date__c >= :fromDate
            AND ERP7__Date__c <= :toDate
        GROUP BY CALENDAR_MONTH(ERP7__Date__c)
    ];

    // ✅ Unpaid My Expenses
    List<AggregateResult> unpaidMyExpenseResults = [
        SELECT CALENDAR_MONTH(ERP7__Date__c) month, SUM(ERP7__Amount__c) total
        FROM ERP7__Expense__c
       // WHERE ERP7__Organisation__c = :org.Id
            WHERE ERP7__Paid__c = false
            AND ERP7__Date__c >= :fromDate
            AND ERP7__Date__c <= :toDate
        GROUP BY CALENDAR_MONTH(ERP7__Date__c)
    ];

    // 🔄 Process Results
    for (AggregateResult ar : paidInvoiceResults) {
        Integer month = (Integer) ar.get('month');
        paidIncome[month - 1] = (Decimal) ar.get('total');
    }

    for (AggregateResult ar : unpaidInvoiceResults) {
        Integer month = (Integer) ar.get('month');
        unpaidIncome[month - 1] = (Decimal) ar.get('total');
    }

    for (AggregateResult ar : paidBillResults) {
        Integer month = (Integer) ar.get('month');
        paidExpense[month - 1] = (Decimal) ar.get('total');
    }

    for (AggregateResult ar : unpaidBillResults) {
        Integer month = (Integer) ar.get('month');
        unpaidExpense[month - 1] = (Decimal) ar.get('total');
    }

    // 🔄 Add My Expenses to Expense Totals
    for (AggregateResult ar : paidMyExpenseResults) {
        Integer month = (Integer) ar.get('month');
        Decimal total = (Decimal) ar.get('total');
        if (paidExpense[month - 1] == null) paidExpense[month - 1] = 0;
        paidExpense[month - 1] += total;
    }

    for (AggregateResult ar : unpaidMyExpenseResults) {
        Integer month = (Integer) ar.get('month');
        Decimal total = (Decimal) ar.get('total');
        if (unpaidExpense[month - 1] == null) unpaidExpense[month - 1] = 0;
        unpaidExpense[month - 1] += total;
    }

    // 💡 Null safety
    for (Integer i = 0; i < 12; i++) {
        if (paidIncome[i] == null) paidIncome[i] = 0;
        if (unpaidIncome[i] == null) unpaidIncome[i] = 0;
        if (paidExpense[i] == null) paidExpense[i] = 0;
        if (unpaidExpense[i] == null) unpaidExpense[i] = 0;
    }

    return new Map<String, Map<String, List<Decimal>>>{
        'paid' => new Map<String, List<Decimal>>{
            'income' => paidIncome,
            'expense' => paidExpense
        },
        'unpaid' => new Map<String, List<Decimal>>{
            'income' => unpaidIncome,
            'expense' => unpaidExpense
        }
    };
}


// @AuraEnabled(cacheable=true)
// public static Map<String, Decimal> getOverallIncomeAndExpenseTotals() {
//     Account org = UtilClass.getOrganisationByLogin_Employee();
//     System.debug('🏢 Organisation: ' + org.Name);

//     // ✅ Get Total Income (all Invoices with valid dates)
//     AggregateResult incomeResult = [
//         SELECT SUM(ERP7__Sub_Total_Amount__c) total
//         FROM ERP7__Invoice__c
//         WHERE ERP7__Organisation__c = :org.Id
//             AND ERP7__Invoice_Date__c != null
//     ];

//     // ✅ Get Total Expense (all Bills with valid dates)
//     AggregateResult expenseResult = [
//         SELECT SUM(ERP7__Total_Amount__c) total
//         FROM ERP7__Bill__c
//         WHERE ERP7__Organisation__c = :org.Id
//             AND ERP7__Bill_Date__c != null
//     ];

//     Decimal totalIncome = (Decimal)(incomeResult.get('total') ?? 0);
//     Decimal totalExpense = (Decimal)(expenseResult.get('total') ?? 0);

//     System.debug('💰 Total Income (All Time): ' + totalIncome);
//     System.debug('💸 Total Expense (All Time): ' + totalExpense);

//     return new Map<String, Decimal>{
//         'totalIncome' => totalIncome,
//         'totalExpense' => totalExpense
//     };
// }

@AuraEnabled(cacheable=true)
public static Map<String, Decimal> getOverallIncomeAndExpenseTotals() {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    System.debug('🏢 Organisation: ' + org.Name);

    // ✅ Get Total Income (all Invoices with valid dates)
    AggregateResult incomeResult = [
        SELECT SUM(ERP7__Sub_Total_Amount__c) total
        FROM ERP7__Invoice__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Invoice_Date__c != null
    ];

    // ✅ Get Total Expense (Bills with valid dates)
    AggregateResult billExpenseResult = [
        SELECT SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Bill_Date__c != null
    ];

    // ✅ Get My Expenses
    AggregateResult myExpenseResult = [
        SELECT SUM(ERP7__Amount__c) total
        FROM ERP7__Expense__c
       // WHERE ERP7__Organisation__c = :org.Id
            WHERE ERP7__Date__c != null
    ];

    Decimal totalIncome = (Decimal)(incomeResult.get('total') ?? 0);
    Decimal totalBillExpense = (Decimal)(billExpenseResult.get('total') ?? 0);
    Decimal totalMyExpense = (Decimal)(myExpenseResult.get('total') ?? 0);

    Decimal totalExpense = totalBillExpense + totalMyExpense;

    System.debug('💰 Total Income (All Time): ' + totalIncome);
    System.debug('💸 Total Bill Expense: ' + totalBillExpense);
    System.debug('💸 Total My Expense: ' + totalMyExpense);
    System.debug('📊 Final Total Expense (Bill + My): ' + totalExpense);

    return new Map<String, Decimal>{
        'totalIncome' => totalIncome,
        'totalExpense' => totalExpense
    };
}

//   public class ExpenseBreakdown {
//     @AuraEnabled public Decimal totalExpenseBill { get; set; }
//     @AuraEnabled public Decimal totalPOBill { get; set; }
//     @AuraEnabled public Decimal totalAdvance { get; set; }

//     public ExpenseBreakdown() {
//         totalExpenseBill = 0.0;
//         totalPOBill = 0.0;
//         totalAdvance = 0.0;
//     }
// }

// @AuraEnabled(cacheable=true)
// public static ExpenseBreakdown getOverallExpenseBreakdown() {
//     ExpenseBreakdown amt = new ExpenseBreakdown();

//     Account org = UtilClass.getOrganisationByLogin_Employee();

//     for (AggregateResult ar : [
//         SELECT RecordType.Name name, SUM(ERP7__Total_Amount__c) total
//         FROM ERP7__Bill__c
//         WHERE ERP7__Organisation__c = :org.Id 
//               AND ERP7__Bill_Date__c != null
//               AND RecordType.Name IN ('Expense Bill', 'PO Bill', 'Advance to Vendor')
//         GROUP BY RecordType.Name
//     ]) {        String name = String.valueOf(ar.get('name'));        Decimal total = (Decimal)ar.get('total');

//         if (name == 'Expense Bill') {            amt.totalExpenseBill = total;        } else if (name == 'PO Bill') {            amt.totalPOBill = total;       } else if (name == 'Advance to Vendor') {            amt.totalAdvance = total;
//         }
//     }

//     // 🧾 Debug logs for each
//     System.debug('🔹 Expense Bill Total: ' + amt.totalExpenseBill);
//     System.debug('🔹 PO Bill Total: ' + amt.totalPOBill);
//     System.debug('🔹 Advance to Vendor Total: ' + amt.totalAdvance);

//     // 🧮 Grand Total
//     Decimal grandTotal = amt.totalExpenseBill + amt.totalPOBill + amt.totalAdvance;
//     System.debug('🧾 Grand Total of All Expenses: ' + grandTotal);

//     return amt;
// }



public class ExpenseBreakdown {
    @AuraEnabled public Decimal totalExpenseBill { get; set; }
    @AuraEnabled public Decimal totalPOBill { get; set; }
    @AuraEnabled public Decimal totalAdvance { get; set; }
    @AuraEnabled public Decimal totalMyExpense { get; set; } // ✅ New field

    public ExpenseBreakdown() {
        totalExpenseBill = 0.0;
        totalPOBill = 0.0;
        totalAdvance = 0.0;
        totalMyExpense = 0.0; // ✅ Init My Expense
    }
}

@AuraEnabled(cacheable=true)
public static ExpenseBreakdown getOverallExpenseBreakdown() {
    ExpenseBreakdown amt = new ExpenseBreakdown();
    Account org = UtilClass.getOrganisationByLogin_Employee();

    // ✅ Existing: Grouped expense types from Bill object
    for (AggregateResult ar : [
        SELECT RecordType.Name name, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Organisation__c = :org.Id 
              AND ERP7__Bill_Date__c != null
              AND RecordType.Name IN ('Expense Bill', 'PO Bill', 'Advance to Vendor')
        GROUP BY RecordType.Name
    ]) {
        String name = String.valueOf(ar.get('name'));
        Decimal total = (Decimal) ar.get('total');

        if (name == 'Expense Bill') {
            amt.totalExpenseBill = total;
        } else if (name == 'PO Bill') {
            amt.totalPOBill = total;
        } else if (name == 'Advance to Vendor') {
            amt.totalAdvance = total;
        }
    }

    // ✅ NEW: Add "My Expenses" from ERP7__Expense__c
    AggregateResult myExpenseResult = [
        SELECT SUM(ERP7__Amount__c) total
        FROM ERP7__Expense__c
       // WHERE ERP7__Organisation__c = :org.Id 
              WHERE ERP7__Date__c != null
    ];
    amt.totalMyExpense = (Decimal)(myExpenseResult.get('total') ?? 0);

    // 🔍 Debug logs
    System.debug('🔹 Expense Bill Total: ' + amt.totalExpenseBill);
    System.debug('🔹 PO Bill Total: ' + amt.totalPOBill);
    System.debug('🔹 Advance to Vendor Total: ' + amt.totalAdvance);
    System.debug('🔹 My Expense Total: ' + amt.totalMyExpense);

    // 🧮 Grand Total Log
    Decimal grandTotal = amt.totalExpenseBill + amt.totalPOBill + amt.totalAdvance + amt.totalMyExpense;
    System.debug('🧾 Grand Total of All Expenses: ' + grandTotal);

    return amt;
}


// @AuraEnabled(cacheable=true)
// public static ExpenseBreakdown getFilteredExpenseBreakdown(Date fromDate, Date toDate) {
//     ExpenseBreakdown breakdown = new ExpenseBreakdown();

//     Account org = UtilClass.getOrganisationByLogin_Employee();

//     for (AggregateResult ar : [
//         SELECT RecordType.Name name, SUM(ERP7__Total_Amount__c) total
//         FROM ERP7__Bill__c
//         WHERE ERP7__Organisation__c = :org.Id
//             AND ERP7__Bill_Date__c >= :fromDate
//             AND ERP7__Bill_Date__c <= :toDate
//             AND RecordType.Name IN ('Expense Bill', 'PO Bill', 'Advance to Vendor')
//         GROUP BY RecordType.Name
//     ]) {        String name = String.valueOf(ar.get('name'));        Decimal total = (Decimal)ar.get('total');

//         if (name == 'Expense Bill') {            breakdown.totalExpenseBill = total;       } else if (name == 'PO Bill') {           breakdown.totalPOBill = total;       } else if (name == 'Advance to Vendor') {           breakdown.totalAdvance = total;
//         }
//     }

//     system.debug('📊 Filtered Expense Breakdown: ' + JSON.serialize(breakdown));
//     system.debug('📅 From Date: ' + fromDate + ', To Date: ' + toDate);
//     return breakdown;
// }



@AuraEnabled(cacheable=true)
public static ExpenseBreakdown getFilteredExpenseBreakdown(Date fromDate, Date toDate) {
    ExpenseBreakdown breakdown = new ExpenseBreakdown();
    Account org = UtilClass.getOrganisationByLogin_Employee();

    // 🔹 Bills Breakdown
    for (AggregateResult ar : [
        SELECT RecordType.Name name, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Organisation__c = :org.Id
            AND ERP7__Bill_Date__c >= :fromDate
            AND ERP7__Bill_Date__c <= :toDate
            AND RecordType.Name IN ('Expense Bill', 'PO Bill', 'Advance to Vendor')
        GROUP BY RecordType.Name
    ]) {
        String name = String.valueOf(ar.get('name'));
        Decimal total = (Decimal) ar.get('total');

        if (name == 'Expense Bill') {
            breakdown.totalExpenseBill = total;
        } else if (name == 'PO Bill') {
            breakdown.totalPOBill = total;
        } else if (name == 'Advance to Vendor') {
            breakdown.totalAdvance = total;
        }
    }

    // 🔹 My Expenses Breakdown (NEW)
    AggregateResult myExpenseResult = [
        SELECT SUM(ERP7__Amount__c) total
        FROM ERP7__Expense__c
        WHERE ERP7__Date__c >= :fromDate
            AND ERP7__Date__c <= :toDate
    ];
    breakdown.totalMyExpense = (Decimal)(myExpenseResult.get('total') ?? 0);

    // 📋 Logs
    System.debug('📊 Filtered Expense Breakdown: ' + JSON.serialize(breakdown));
    System.debug('📅 From Date: ' + fromDate + ', To Date: ' + toDate);

    return breakdown;
}


    // @AuraEnabled(cacheable=true)
    // public static List<Map<String, Object>> getBudgetPlanData() {
    //     List<Map<String, Object>> resultList = new List<Map<String, Object>>();

    //     List<ERP7__Project__c> projectsWithBudgetAccounts = [
    //         SELECT Name,
    //                (SELECT
    //                     ERP7__Chart_of_Account__r.Name,
    //                     (SELECT
    //                          ERP7__Budget_Category__c,
    //                          ERP7__Approved_Amount__c,
    //                          ERP7__Consumed_Amount__c,
    //                          ERP7__Committed__c,
    //                          ERP7__Remaining_Amount__c
    //                      FROM ERP7__Budget_Plan__c)
    //                 FROM ERP7__Budget_Account__c)
    //         FROM ERP7__Project__c
    //         WHERE Id IN (SELECT ERP7__Project__c FROM ERP7__Budget_Account__c)
    //     ];

    //     System.debug('📌 Total Projects with Budget Accounts: ' + projectsWithBudgetAccounts.size());

    //     for (ERP7__Project__c project : projectsWithBudgetAccounts) {
    //         String projectName = project.Name;

    //         for (ERP7__Budget_Account__c budgetAcc : project.ERP7__Budget_Account__r) {
    //             String coaName = budgetAcc.ERP7__Chart_of_Account__c != null ? budgetAcc.ERP7__Chart_of_Account__r.Name : 'N/A';

    //             for (ERP7__Budget_Plan__c plan : budgetAcc.ERP7__Budget_Plan__c) {
    //                 Map<String, Object> row = new Map<String, Object>();
    //                 row.put('projectName', projectName);
    //                 row.put('chartOfAccount', coaName);
    //                 row.put('budgetCategory', plan.ERP7__Budget_Category__c);
    //                 row.put('approved', plan.ERP7__Approved_Amount__c);
    //                 row.put('consumed', plan.ERP7__Consumed_Amount__c);
    //                 row.put('committed', plan.ERP7__Committed__c);
    //                 row.put('remaining', plan.ERP7__Remaining_Amount__c);

    //                 resultList.add(row);
    //             }
    //         }
    //     }

    //     System.debug('✅ Final Result List: ' + JSON.serialize(resultList));
    //     return resultList;
    // }
@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getBudgetPlanData() {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    System.debug('🏢 Organisation: ' + org.Name);
    List<Map<String, Object>> resultList = new List<Map<String, Object>>();

    List<ERP7__Budget_Plan__c> plans = [
        SELECT Id, Name, ERP7__Total_Budget_Amount__c, ERP7__Consumed_Amount__c,
               ERP7__Remaining_Amount__c, ERP7__Committed__c, ERP7__Budget_Category__c,
               (SELECT Id, Name, ERP7__Chart_of_Account__r.Name, ERP7__Project__r.Name 
                FROM ERP7__Budget_Account__r)
        FROM ERP7__Budget_Plan__c
    ];

    System.debug('📦 Total Budget Plans: ' + plans.size());

    for (ERP7__Budget_Plan__c plan : plans) {
        for (ERP7__Budget_Account__c acc : plan.ERP7__Budget_Account__r) {           Map<String, Object> row = new Map<String, Object>();           row.put('projectName', acc.ERP7__Project__r != null ? acc.ERP7__Project__r.Name : 'N/A');           row.put('chartOfAccount', acc.ERP7__Chart_of_Account__r != null ? acc.ERP7__Chart_of_Account__r.Name : 'N/A');            String category = plan.ERP7__Budget_Category__c != null ? plan.ERP7__Budget_Category__c : 'Unknown';
            // Standardize category names
            if (category == 'Cost') category = 'Cost Budget';           else if (category == 'Time and Material') category = 'Time and Material Budget';            else if (category == 'Fixed') category = 'Fixed Budget';            row.put('budgetCategory', category); // Use consistent key name           row.put('approved', plan.ERP7__Total_Budget_Amount__c != null ? plan.ERP7__Total_Budget_Amount__c : 0);            row.put('consumed', plan.ERP7__Consumed_Amount__c != null ? plan.ERP7__Consumed_Amount__c : 0);            row.put('remaining', plan.ERP7__Remaining_Amount__c != null ? plan.ERP7__Remaining_Amount__c : 0);            row.put('committed', plan.ERP7__Committed__c != null ? plan.ERP7__Committed__c : 0);            resultList.add(row);
        }
    }

    System.debug('✅ Final Result List: ' + JSON.serialize(resultList));
    return resultList;
}


@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getChartOfAccountTotals() {
    Account org = UtilClass.getOrganisationByLogin_Employee(); // Get current org
    System.debug('🏢 Organisation: ' + org.Name);

    // Grouping by Chart of Account
    Map<String, Map<String, Object>> coaMap = new Map<String, Map<String, Object>>();

    List<ERP7__Budget_Plan__c> plans = [
        SELECT Id, Name, ERP7__Total_Budget_Amount__c, ERP7__Consumed_Amount__c,
               ERP7__Remaining_Amount__c, ERP7__Committed__c,
               (SELECT Id, Name, ERP7__Chart_of_Account__r.Name 
                FROM ERP7__Budget_Account__r)
        FROM ERP7__Budget_Plan__c
        WHERE ERP7__Organisation__c = :org.Id
    ];

    for (ERP7__Budget_Plan__c plan : plans) {
        for (ERP7__Budget_Account__c acc : plan.ERP7__Budget_Account__r) {            String chartOfAccount = acc.ERP7__Chart_of_Account__r != null ? acc.ERP7__Chart_of_Account__r.Name : 'N/A';

            if (!coaMap.containsKey(chartOfAccount)) {               coaMap.put(chartOfAccount, new Map<String, Object>{                    'chartOfAccount' => chartOfAccount,                    'approved' => 0,                    'consumed' => 0,                    'remaining' => 0,                    'committed' => 0
                });
            }

            Map<String, Object> data = coaMap.get(chartOfAccount);              data.put('approved', (Decimal)data.get('approved') + (plan.ERP7__Total_Budget_Amount__c != null ? plan.ERP7__Total_Budget_Amount__c : 0));               data.put('consumed', (Decimal)data.get('consumed') + (plan.ERP7__Consumed_Amount__c != null ? plan.ERP7__Consumed_Amount__c : 0));              data.put('remaining', (Decimal)data.get('remaining') + (plan.ERP7__Remaining_Amount__c != null ? plan.ERP7__Remaining_Amount__c : 0));              data.put('committed', (Decimal)data.get('committed') + (plan.ERP7__Committed__c != null ? plan.ERP7__Committed__c : 0));
        }
    }

    List<Map<String, Object>> resultList = new List<Map<String, Object>>();
    resultList.addAll(coaMap.values());

    System.debug('📊 Org-Filtered Chart of Account Totals: ' + JSON.serialize(resultList));
    return resultList;
}



@AuraEnabled(cacheable=true)
public static List<ProjectBudgetWrapper> getProjectBudgetsByChartOfAccount(Id chartOfAccountId) {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    Map<Id, ProjectBudgetWrapper> projectData = new Map<Id, ProjectBudgetWrapper>();

    List<ERP7__Budget_Account__c> accounts = [
        SELECT Id, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Budget_Plan__c,
               ERP7__Chart_of_Account__c,
               ERP7__Budget_Plan__r.ERP7__Total_Budget_Amount__c,
               ERP7__Budget_Plan__r.ERP7__Consumed_Amount__c,
               ERP7__Budget_Plan__r.ERP7__Remaining_Amount__c,
               ERP7__Budget_Plan__r.ERP7__Committed__c
        FROM ERP7__Budget_Account__c
        WHERE ERP7__Chart_of_Account__c = :chartOfAccountId
        //AND ERP7__Budget_Plan__r.ERP7__Organisation__c= :org.Id
     
    ];
    System.debug('📊 Total Budget Accounts for Chart of Account ' + chartOfAccountId + ': ' + accounts.size());

    for (ERP7__Budget_Account__c acc : accounts) {
        Id projectId = acc.ERP7__Project__c;          if (!projectData.containsKey(projectId)) {              projectData.put(projectId, new ProjectBudgetWrapper(             acc.ERP7__Project__r.Name, 0, 0, 0, 0
            ));
        }

         System.debug('📊 Processing Budget Account: ' + acc.Id + ', Project: ' + acc.ERP7__Project__r.Name);
        ProjectBudgetWrapper pbw = projectData.get(projectId);          pbw.total     += acc.ERP7__Budget_Plan__r.ERP7__Total_Budget_Amount__c   != null ? acc.ERP7__Budget_Plan__r.ERP7__Total_Budget_Amount__c   : 0;     pbw.consumed  += acc.ERP7__Budget_Plan__r.ERP7__Consumed_Amount__c       != null ? acc.ERP7__Budget_Plan__r.ERP7__Consumed_Amount__c       : 0;     pbw.remaining += acc.ERP7__Budget_Plan__r.ERP7__Remaining_Amount__c      != null ? acc.ERP7__Budget_Plan__r.ERP7__Remaining_Amount__c      : 0;     pbw.committed += acc.ERP7__Budget_Plan__r.ERP7__Committed__c             != null ? acc.ERP7__Budget_Plan__r.ERP7__Committed__c             : 0;

    }

    System.debug('📊 Final Project Budget Data: ' + JSON.serialize(projectData.values()));
    return projectData.values();
}

public class ProjectBudgetWrapper {
    @AuraEnabled public String projectName;
    @AuraEnabled public Decimal total;
    @AuraEnabled public Decimal consumed;
    @AuraEnabled public Decimal remaining;
    @AuraEnabled public Decimal committed;

    public ProjectBudgetWrapper(String name, Decimal total, Decimal consumed, Decimal remaining, Decimal committed) {
        this.projectName = name;
        this.total = total;
        this.consumed = consumed;
        this.remaining = remaining;
        this.committed = committed;
    }
}

  @AuraEnabled(cacheable=true)
    public static List<IdNameWrapper> getProjectsByChartOfAccount(Id chartOfAccountId) {
        Set<Id> projectIds = new Set<Id>();
        List<IdNameWrapper> projects = new List<IdNameWrapper>();

        for (ERP7__Budget_Account__c acc : [
            SELECT ERP7__Project__c, ERP7__Project__r.Name
            FROM ERP7__Budget_Account__c
            WHERE ERP7__Chart_of_Account__c = :chartOfAccountId
            AND ERP7__Project__c != null
        ]) {            if (!projectIds.contains(acc.ERP7__Project__c)) {       projectIds.add(acc.ERP7__Project__c);          projects.add(new IdNameWrapper(acc.ERP7__Project__c, acc.ERP7__Project__r.Name));
            }
        }
        return projects;
    }

    @AuraEnabled(cacheable=true)
    public static ProjectBudgetWrapper getSingleProjectBudget(Id chartOfAccountId, Id projectId) {
        Decimal total = 0, consumed = 0, remaining = 0, committed = 0;

        for (ERP7__Budget_Account__c acc : [
            SELECT ERP7__Budget_Plan__r.ERP7__Total_Budget_Amount__c,
                   ERP7__Budget_Plan__r.ERP7__Consumed_Amount__c,
                   ERP7__Budget_Plan__r.ERP7__Remaining_Amount__c,
                   ERP7__Budget_Plan__r.ERP7__Committed__c
            FROM ERP7__Budget_Account__c
            WHERE ERP7__Chart_of_Account__c = :chartOfAccountId
            AND ERP7__Project__c = :projectId
            AND ERP7__Budget_Plan__c != null
        ]) {           total     += acc.ERP7__Budget_Plan__r.ERP7__Total_Budget_Amount__c   != null ? acc.ERP7__Budget_Plan__r.ERP7__Total_Budget_Amount__c   : 0;       consumed  += acc.ERP7__Budget_Plan__r.ERP7__Consumed_Amount__c       != null ? acc.ERP7__Budget_Plan__r.ERP7__Consumed_Amount__c       : 0;       remaining += acc.ERP7__Budget_Plan__r.ERP7__Remaining_Amount__c      != null ? acc.ERP7__Budget_Plan__r.ERP7__Remaining_Amount__c      : 0;    committed += acc.ERP7__Budget_Plan__r.ERP7__Committed__c             != null ? acc.ERP7__Budget_Plan__r.ERP7__Committed__c             : 0;
        }

        return new ProjectBudgetWrapper(null, total, consumed, remaining, committed);
    }

    // public class ProjectBudgetWrapper {
    //     @AuraEnabled public String projectName;
    //     @AuraEnabled public Decimal total;
    //     @AuraEnabled public Decimal consumed;
    //     @AuraEnabled public Decimal remaining;
    //     @AuraEnabled public Decimal committed;

    //     public ProjectBudgetWrapper(String name, Decimal total, Decimal consumed, Decimal remaining, Decimal committed) {
    //         this.projectName = name;
    //         this.total = total;
    //         this.consumed = consumed;
    //         this.remaining = remaining;
    //         this.committed = committed;
    //     }
    // }

    public class IdNameWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;

        public IdNameWrapper(Id id, String name) {  this.id = id;  this.name = name;
        }
    }



@AuraEnabled(cacheable=true)
public static List<Id> getChartOfAccountsWithBudgetAccounts() {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    
    Set<Id> chartOfAccountIds = new Set<Id>();

    List<ERP7__Budget_Account__c> budgetAccounts = [
        SELECT ERP7__Chart_of_Account__c
        FROM ERP7__Budget_Account__c
        WHERE ERP7__Budget_Plan__r.ERP7__Organisation__c = :org.Id
        AND ERP7__Chart_of_Account__c != null
        AND ERP7__Project__c != null
        AND ERP7__Budget_Plan__c != null
    ];

    for (ERP7__Budget_Account__c acc : budgetAccounts) {
        chartOfAccountIds.add(acc.ERP7__Chart_of_Account__c);
    }
    System.debug('📊 Chart of Accounts with Budget Accounts: ' + chartOfAccountIds);
    
    return new List<Id>(chartOfAccountIds);
}

private static List<Decimal> predictFuture(List<Decimal> values, Integer steps) {
    List<Decimal> forecast = new List<Decimal>();
    if (values == null || values.size() < 2) return forecast;

    Decimal alpha = 0.8;
    Decimal beta = 0.2;
    Decimal level = values[0];
    Decimal trend = values[1] - values[0];

    for (Integer i = 1; i < values.size(); i++) {
        Decimal prevLevel = level;
        level = alpha * values[i] + (1 - alpha) * (level + trend);
        trend = beta * (level - prevLevel) + (1 - beta) * trend;
    }

    for (Integer s = 1; s <= steps; s++) {
        forecast.add((level + s * trend).setScale(2));
    }

    return forecast;
}

@AuraEnabled(cacheable=true)
public static Map<String, Object> getYearlyIncomeAndExpenseWithPrediction() {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    Integer currentYear = Date.today().year();
    Integer startYear = currentYear - 5;
    Integer endYear = currentYear;

    Map<Integer, Decimal> incomeByYear = new Map<Integer, Decimal>();
    Map<Integer, Decimal> expenseByYear = new Map<Integer, Decimal>();

    for (Integer y = startYear; y <= endYear; y++) {
        incomeByYear.put(y, 0);
        expenseByYear.put(y, 0);
    }

    List<AggregateResult> incomeResults = [
        SELECT CALENDAR_YEAR(ERP7__Invoice_Date__c) yr, SUM(ERP7__Sub_Total_Amount__c) amt
        FROM ERP7__Invoice__c
        WHERE ERP7__Organisation__c = :org.Id
        AND ERP7__Invoice_Date__c != null
        GROUP BY CALENDAR_YEAR(ERP7__Invoice_Date__c)
    ];

    for (AggregateResult res : incomeResults) {
        Integer yr = (Integer)res.get('yr');       if (incomeByYear.containsKey(yr)) {          incomeByYear.put(yr, (Decimal)res.get('amt'));
        }
    }

    List<AggregateResult> expenseResults = [
        SELECT CALENDAR_YEAR(ERP7__Bill_Date__c) yr, SUM(ERP7__Total_Amount__c) amt
        FROM ERP7__Bill__c
        WHERE ERP7__Organisation__c = :org.Id
        AND ERP7__Bill_Date__c != null
        GROUP BY CALENDAR_YEAR(ERP7__Bill_Date__c)
    ];

    for (AggregateResult res : expenseResults) {
        Integer yr = (Integer)res.get('yr');        if (expenseByYear.containsKey(yr)) {           expenseByYear.put(yr, (Decimal)res.get('amt'));
        }
    }

    List<Integer> years = new List<Integer>();
    List<Decimal> incomeList = new List<Decimal>();
    List<Decimal> expenseList = new List<Decimal>();

    for (Integer y = startYear; y <= endYear; y++) {
        years.add(y);
        incomeList.add(incomeByYear.get(y));
        expenseList.add(expenseByYear.get(y));
    }

    // Predict next 5 years
    List<Decimal> predictedIncomeList = predictFuture(incomeList, 5);
    List<Decimal> predictedExpenseList = predictFuture(expenseList, 5);

    // Append future years
    for (Integer i = 1; i <= 5; i++) {
        years.add(currentYear + i);
    }

    return new Map<String, Object>{
        'years' => years,
        'income' => incomeList,
        'expense' => expenseList,
        'predictedIncome' => predictedIncomeList,
        'predictedExpense' => predictedExpenseList
    };
}




// @AuraEnabled(cacheable=true)
// public static Map<String, Object> getMonthlyIncomeExpenseWithPrediction() {
//     Account org = UtilClass.getOrganisationByLogin_Employee();
//     Integer currentYear = Date.today().year();
//     Integer currentMonth = Date.today().month();

//     Date endDate = Date.today();
//     Date startDate = endDate.addYears(-3); // Last 3 years

//     // ===== Current Year Actuals =====
//     List<AggregateResult> invoiceResults = [
//         SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
//         FROM ERP7__Invoice__c
//         WHERE ERP7__Paid__c = true
//             AND ERP7__Organisation__c = :org.Id
//             AND ERP7__Invoice_Date__c != null
//             AND CALENDAR_YEAR(ERP7__Invoice_Date__c) = :currentYear
//         GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
//     ];

//     List<AggregateResult> billResults = [
//         SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
//         FROM ERP7__Bill__c
//         WHERE ERP7__Status__c = 'Paid'
//             AND ERP7__Organisation__c = :org.Id
//             AND ERP7__Bill_Date__c != null
//             AND CALENDAR_YEAR(ERP7__Bill_Date__c) = :currentYear
//         GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
//     ];

//     List<AggregateResult> expenseResults = [
//         SELECT CALENDAR_MONTH(ERP7__Date__c) month, SUM(ERP7__Amount__c) total
//         FROM ERP7__Expense__c
//         WHERE ERP7__Paid__c = true
//             AND ERP7__Date__c != null
//             AND CALENDAR_YEAR(ERP7__Date__c) = :currentYear
//         GROUP BY CALENDAR_MONTH(ERP7__Date__c)
//     ];

//     List<Decimal> income = new List<Decimal>(new Decimal[12]);
//     List<Decimal> expense = new List<Decimal>(new Decimal[12]);
//     List<Decimal> additionalExpense = new List<Decimal>(new Decimal[12]);

//     for (AggregateResult ar : invoiceResults) {
//         Integer m = (Integer) ar.get('month');
//         Decimal total = (Decimal) ar.get('total');
//         income[m - 1] = total;
//     }

//     for (AggregateResult ar : billResults) {
//         Integer m = (Integer) ar.get('month');
//         Decimal total = (Decimal) ar.get('total');
//         expense[m - 1] = total;
//     }

//     for (AggregateResult ar : expenseResults) {
//         Integer m = (Integer) ar.get('month');
//         Decimal total = (Decimal) ar.get('total');
//         additionalExpense[m - 1] = total;
//     }

//     // Combine bill + expense amounts
//     for (Integer i = 0; i < 12; i++) {
//         if (income[i] == null) income[i] = 0;
//         if (expense[i] == null) expense[i] = 0;
//         if (additionalExpense[i] == null) additionalExpense[i] = 0;
//         expense[i] += additionalExpense[i];
//     }

//     // ===== Historical Data for Prediction (Past 3 years) =====
//     List<AggregateResult> historicalInvoices = [
//         SELECT CALENDAR_YEAR(ERP7__Invoice_Date__c) yr, CALENDAR_MONTH(ERP7__Invoice_Date__c) mon, SUM(ERP7__Sub_Total_Amount__c) total
//         FROM ERP7__Invoice__c
//         WHERE ERP7__Paid__c = true
//             AND ERP7__Organisation__c = :org.Id
//             AND ERP7__Invoice_Date__c >= :startDate AND ERP7__Invoice_Date__c <= :endDate
//         GROUP BY CALENDAR_YEAR(ERP7__Invoice_Date__c), CALENDAR_MONTH(ERP7__Invoice_Date__c)
//     ];

//     List<AggregateResult> historicalExpenses = [
//         SELECT CALENDAR_YEAR(ERP7__Bill_Date__c) yr, CALENDAR_MONTH(ERP7__Bill_Date__c) mon, SUM(ERP7__Total_Amount__c) total
//         FROM ERP7__Bill__c
//         WHERE ERP7__Status__c = 'Paid'
//             AND ERP7__Organisation__c = :org.Id
//             AND ERP7__Bill_Date__c >= :startDate AND ERP7__Bill_Date__c <= :endDate
//         GROUP BY CALENDAR_YEAR(ERP7__Bill_Date__c), CALENDAR_MONTH(ERP7__Bill_Date__c)
//     ];

//     Map<Integer, List<Decimal>> incomeHistory = new Map<Integer, List<Decimal>>();
//     Map<Integer, List<Decimal>> expenseHistory = new Map<Integer, List<Decimal>>();

//     for (Integer i = 1; i <= 12; i++) {
//         incomeHistory.put(i, new List<Decimal>());
//         expenseHistory.put(i, new List<Decimal>());
//     }

//     for (AggregateResult ar : historicalInvoices) {
//         Integer m = (Integer) ar.get('mon');
//         Decimal total = (Decimal) ar.get('total');
//         incomeHistory.get(m).add(total);
//     }

//     for (AggregateResult ar : historicalExpenses) {
//         Integer m = (Integer) ar.get('mon');
//         Decimal total = (Decimal) ar.get('total');
//         expenseHistory.get(m).add(total);
//     }

//     List<Decimal> predictedIncome = new List<Decimal>();
//     List<Decimal> predictedExpense = new List<Decimal>();
//     List<String> monthLabels = new List<String>();

//     for (Integer m = 1; m <= 12; m++) {
//         Decimal incomeSum = 0;
//         Decimal expenseSum = 0;

//         for (Decimal val : incomeHistory.get(m)) {
//             incomeSum += val;
//         }

//         for (Decimal val : expenseHistory.get(m)) {
//             expenseSum += val;
//         }

//         Decimal incomeAvg = incomeHistory.get(m).isEmpty() ? 0 : incomeSum / incomeHistory.get(m).size();
//         Decimal expenseAvg = expenseHistory.get(m).isEmpty() ? 0 : expenseSum / expenseHistory.get(m).size();

//         if (m > currentMonth) {
//             predictedIncome.add(incomeAvg.setScale(2));
//             predictedExpense.add(expenseAvg.setScale(2));
//         } else {
//             predictedIncome.add(0);
//             predictedExpense.add(0);
//         }

//         monthLabels.add(getMonthLabel(m));
//     }

//     return new Map<String, Object>{
//         'income' => income,
//         'expense' => expense,
//         'predictedIncome' => predictedIncome,
//         'predictedExpense' => predictedExpense,
//         'monthLabels' => monthLabels
//     };
// }

// // Helper to return month label
// private static String getMonthLabel(Integer month) {
//     List<String> months = new List<String>{
//         'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     };
//     return months[month - 1];
// }


@AuraEnabled(cacheable=true)
public static Map<String, Object> getMonthlyIncomeExpenseWithPrediction() {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    Integer currentYear = Date.today().year();
    Integer currentMonth = Date.today().month();

    Date endDate = Date.today();
    Date startDate = endDate.addYears(-3); // Last 3 years

    // ===== Current Year Actuals =====
    List<Decimal> income = new List<Decimal>(new Decimal[12]);
    List<Decimal> expense = new List<Decimal>(new Decimal[12]);
    List<Decimal> additionalExpense = new List<Decimal>(new Decimal[12]);

    for (Integer i = 0; i < 12; i++) {
        income[i] = 0;
        expense[i] = 0;
        additionalExpense[i] = 0;
    }

    for (AggregateResult ar : [
        SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
        FROM ERP7__Invoice__c
        WHERE ERP7__Paid__c = true AND ERP7__Organisation__c = :org.Id AND
              ERP7__Invoice_Date__c != null AND CALENDAR_YEAR(ERP7__Invoice_Date__c) = :currentYear
        GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
    ]) {
        Integer m = (Integer) ar.get('month');
        income[m - 1] = (Decimal) ar.get('total');
    }

    for (AggregateResult ar : [
        SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Status__c = 'Paid' AND ERP7__Organisation__c = :org.Id AND
              ERP7__Bill_Date__c != null AND CALENDAR_YEAR(ERP7__Bill_Date__c) = :currentYear
        GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
    ]) {
        Integer m = (Integer) ar.get('month');
        expense[m - 1] = (Decimal) ar.get('total');
    }

    for (AggregateResult ar : [
        SELECT CALENDAR_MONTH(ERP7__Date__c) month, SUM(ERP7__Amount__c) total
        FROM ERP7__Expense__c
        WHERE ERP7__Paid__c = true AND ERP7__Date__c != null AND
              CALENDAR_YEAR(ERP7__Date__c) = :currentYear
        GROUP BY CALENDAR_MONTH(ERP7__Date__c)
    ]) {
        Integer m = (Integer) ar.get('month');
        additionalExpense[m - 1] = (Decimal) ar.get('total');
    }

    for (Integer i = 0; i < 12; i++) {
        expense[i] += additionalExpense[i];
    }

    // Historical Data
    Map<Integer, List<Decimal>> incomeHistory = new Map<Integer, List<Decimal>>();
    Map<Integer, List<Decimal>> expenseHistory = new Map<Integer, List<Decimal>>();

    for (Integer i = 1; i <= 12; i++) {
        incomeHistory.put(i, new List<Decimal>());
        expenseHistory.put(i, new List<Decimal>());
    }

    for (AggregateResult ar : [
        SELECT CALENDAR_YEAR(ERP7__Invoice_Date__c) yr, CALENDAR_MONTH(ERP7__Invoice_Date__c) mon, SUM(ERP7__Sub_Total_Amount__c) total
        FROM ERP7__Invoice__c
        WHERE ERP7__Paid__c = true AND ERP7__Organisation__c = :org.Id AND
              ERP7__Invoice_Date__c >= :startDate AND ERP7__Invoice_Date__c <= :endDate
        GROUP BY CALENDAR_YEAR(ERP7__Invoice_Date__c), CALENDAR_MONTH(ERP7__Invoice_Date__c)
    ]) {
         incomeHistory.get((Integer) ar.get('mon')).add((Decimal) ar.get('total'));
    }
    System.debug('📊 Income History: ' + JSON.serialize(incomeHistory));

    for (AggregateResult ar : [
        SELECT CALENDAR_YEAR(ERP7__Bill_Date__c) yr, CALENDAR_MONTH(ERP7__Bill_Date__c) mon, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Status__c = 'Paid' AND ERP7__Organisation__c = :org.Id AND
              ERP7__Bill_Date__c >= :startDate AND ERP7__Bill_Date__c <= :endDate
        GROUP BY CALENDAR_YEAR(ERP7__Bill_Date__c), CALENDAR_MONTH(ERP7__Bill_Date__c)
    ]) {
        expenseHistory.get((Integer) ar.get('mon')).add((Decimal) ar.get('total'));
    }
    System.debug('📊 Expense History: ' + JSON.serialize(expenseHistory));

    // Holt-Winters Prediction (simplified)
    List<Decimal> predictedIncome = applyHoltWinters(incomeHistory, currentMonth);
    List<Decimal> predictedExpense = applyHoltWinters(expenseHistory, currentMonth);

    List<String> monthLabels = new List<String>();
    for (Integer m = 1; m <= 12; m++) {
        monthLabels.add(getMonthLabel(m));
    }

    return new Map<String, Object>{
        'income' => income,
        'expense' => expense,
        'predictedIncome' => predictedIncome,
        'predictedExpense' => predictedExpense,
        'monthLabels' => monthLabels,
        'incomeHistory' => incomeHistory,
        'expenseHistory' => expenseHistory
    };
}

private static List<Decimal> applyHoltWinters(Map<Integer, List<Decimal>> history, Integer currentMonth) {
    Decimal alpha = 0.6;
    Decimal beta = 0.2;
    Decimal gamma = 0.1;

    List<Decimal> result = new List<Decimal>();

    Decimal level = 0;
    Decimal trend = 0;
    List<Decimal> seasonality = new List<Decimal>(new Decimal[12]);

    // Initialize level and seasonality
    for (Integer i = 0; i < 12; i++) {
        List<Decimal> monthData = history.get(i + 1);
        Decimal avg = 0;
        if (!monthData.isEmpty()) {
            for (Decimal val : monthData) avg += val;
            avg /= monthData.size();
        }
        seasonality[i] = avg;
        level += avg;
    }
    level /= 12;

    trend = (seasonality[11] - seasonality[0]) / 11;
for (Integer i = 0; i < 12; i++) {
    if (i < currentMonth) {
        result.add(0); // Actuals already exist
    } else {
        Integer idx = Math.mod(i, 12); // wrap index between 0-11

        Decimal seasonal = gamma * seasonality[idx] + (1 - gamma) * seasonality[idx];
        level = alpha * (seasonality[idx] != null ? seasonality[idx] : 0) + (1 - alpha) * (level + trend);
        trend = beta * (level - (result.size() > 0 ? result[result.size() - 1] : level)) + (1 - beta) * trend;

        Decimal forecast = level + trend + seasonal;

        // ✅ Stop prediction if forecast goes negative or zero
        if (forecast <= 0) {
            // Fill remaining months with 0
            while (result.size() < 12) {
                result.add(0);
            }
            break;
        }

        result.add(forecast.setScale(2));
    }
}


    return result;
}




    @AuraEnabled
public static Map<String, Object> simulateForecastWithInputs(Map<String, Object> simulatedValues) {
    Account org = UtilClass.getOrganisationByLogin_Employee();
    Integer currentYear = Date.today().year();
    Integer currentMonth = Date.today().month();

    Date endDate = Date.today();
    Date startDate = endDate.addYears(-3); // Last 3 years

    // Initialize data structures
    List<Decimal> income = new List<Decimal>(new Decimal[12]);
    List<Decimal> expense = new List<Decimal>(new Decimal[12]);
    List<Decimal> additionalExpense = new List<Decimal>(new Decimal[12]);

    for (Integer i = 0; i < 12; i++) {
        income[i] = 0;
        expense[i] = 0;
        additionalExpense[i] = 0;
    }

    // Fetch current year actuals
    for (AggregateResult ar : [
        SELECT CALENDAR_MONTH(ERP7__Invoice_Date__c) month, SUM(ERP7__Sub_Total_Amount__c) total
        FROM ERP7__Invoice__c
        WHERE ERP7__Paid__c = true AND ERP7__Organisation__c = :org.Id AND
              ERP7__Invoice_Date__c != null AND CALENDAR_YEAR(ERP7__Invoice_Date__c) = :currentYear
        GROUP BY CALENDAR_MONTH(ERP7__Invoice_Date__c)
    ]) {
        Integer m = (Integer) ar.get('month');
        income[m - 1] = (Decimal) ar.get('total');
    }

 


    for (AggregateResult ar : [
        SELECT CALENDAR_MONTH(ERP7__Bill_Date__c) month, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Status__c = 'Paid' AND ERP7__Organisation__c = :org.Id AND
              ERP7__Bill_Date__c != null AND CALENDAR_YEAR(ERP7__Bill_Date__c) = :currentYear
        GROUP BY CALENDAR_MONTH(ERP7__Bill_Date__c)
    ]) {
        Integer m = (Integer) ar.get('month');
        expense[m - 1] = (Decimal) ar.get('total');
    }



    for (AggregateResult ar : [
        SELECT CALENDAR_MONTH(ERP7__Date__c) month, SUM(ERP7__Amount__c) total
        FROM ERP7__Expense__c
        WHERE ERP7__Paid__c = true AND ERP7__Date__c != null AND
              CALENDAR_YEAR(ERP7__Date__c) = :currentYear
        GROUP BY CALENDAR_MONTH(ERP7__Date__c)
    ]) {
        Integer m = (Integer) ar.get('month');
        additionalExpense[m - 1] = (Decimal) ar.get('total');
    }

    for (Integer i = 0; i < 12; i++) {
        expense[i] += additionalExpense[i];
    }


    
   System.debug('📊 Current Year Income: ' + JSON.serialize(income));
    System.debug('📊 Current Year Expense: ' + JSON.serialize(expense));
    System.debug('📊 Current Year Additional Expense: ' + JSON.serialize(additionalExpense));

    // Historical Data
    Map<Integer, List<Decimal>> incomeHistory = new Map<Integer, List<Decimal>>();
    Map<Integer, List<Decimal>> expenseHistory = new Map<Integer, List<Decimal>>();

    for (Integer i = 1; i <= 12; i++) {
        incomeHistory.put(i, new List<Decimal>());
        expenseHistory.put(i, new List<Decimal>());
    }

    // Fetch historical data for the last 3 years
    System.debug('📊 Fetching historical data for the last 3 years...');
    System.debug('📊 Organisation ID: ' + org.Id);
    System.debug('📊 Start Date: ' + startDate);
    System.debug('📊 End Date: ' + endDate);


    for (AggregateResult ar : [
        SELECT CALENDAR_YEAR(ERP7__Invoice_Date__c) yr, CALENDAR_MONTH(ERP7__Invoice_Date__c) mon, SUM(ERP7__Sub_Total_Amount__c) total
        FROM ERP7__Invoice__c
        WHERE ERP7__Paid__c = true AND ERP7__Organisation__c = :org.Id AND
              ERP7__Invoice_Date__c >= :startDate AND ERP7__Invoice_Date__c <= :endDate
        GROUP BY CALENDAR_YEAR(ERP7__Invoice_Date__c), CALENDAR_MONTH(ERP7__Invoice_Date__c)
    ]) {
        Integer month = (Integer) ar.get('mon');
        if (!incomeHistory.containsKey(month)) {
            incomeHistory.put(month, new List<Decimal>());
        }
        incomeHistory.get(month).add((Decimal) ar.get('total'));
    }

    for (AggregateResult ar : [
        SELECT CALENDAR_YEAR(ERP7__Bill_Date__c) yr, CALENDAR_MONTH(ERP7__Bill_Date__c) mon, SUM(ERP7__Total_Amount__c) total
        FROM ERP7__Bill__c
        WHERE ERP7__Status__c = 'Paid' AND ERP7__Organisation__c = :org.Id AND
              ERP7__Bill_Date__c >= :startDate AND ERP7__Bill_Date__c <= :endDate
        GROUP BY CALENDAR_YEAR(ERP7__Bill_Date__c), CALENDAR_MONTH(ERP7__Bill_Date__c)
    ]) {
        Integer month = (Integer) ar.get('mon');
        if (!expenseHistory.containsKey(month)) {
            expenseHistory.put(month, new List<Decimal>());
        }
        expenseHistory.get(month).add((Decimal) ar.get('total'));
    }

    System.debug('📊 Income History: ' + JSON.serialize(incomeHistory));
    System.debug('📊 Expense History: ' + JSON.serialize(expenseHistory));
    System.debug('📊 Current Year Additional Expense: ' + JSON.serialize(additionalExpense));


    // Merge simulated values into historical data for the current year
    Map<String, Integer> monthToIndex = new Map<String, Integer>{
        'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6,
        'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
    };

    for (String month : simulatedValues.keySet()) {
    // Safely convert the raw object to Map<String, Object>
    Map<String, Object> values = new Map<String, Object>();
    Object raw = simulatedValues.get(month);

    if (raw instanceof Map<Object, Object>) {
        Map<Object, Object> rawMap = (Map<Object, Object>) raw;
        for (Object key : rawMap.keySet()) {
            values.put(String.valueOf(key), rawMap.get(key));
        }
    }

    Integer monthIndex = monthToIndex.get(month);

    if (monthIndex != null) {
        if (values.containsKey('income') && values.get('income') != null) {
            Decimal simIncome = (Decimal) values.get('income');
            income[monthIndex - 1] = simIncome;

            if (!incomeHistory.containsKey(monthIndex)) {
                incomeHistory.put(monthIndex, new List<Decimal>());
            }
            incomeHistory.get(monthIndex).add(simIncome);
        }

        if (values.containsKey('expense') && values.get('expense') != null) {
            Decimal simExpense = (Decimal) values.get('expense');
            expense[monthIndex - 1] = simExpense;

            if (!expenseHistory.containsKey(monthIndex)) {
                expenseHistory.put(monthIndex, new List<Decimal>());
            }
            expenseHistory.get(monthIndex).add(simExpense);
        }
    }
}
    

    // Run Holt-Winters prediction with updated data
    List<Decimal> predictedIncome = applyHoltWintersnew(incomeHistory, currentMonth);
    List<Decimal> predictedExpense = applyHoltWintersnew(expenseHistory, currentMonth);

    // Prepare simulated data arrays
    List<Decimal> simulatedIncome = new List<Decimal>(new Decimal[12]);
    List<Decimal> simulatedExpense = new List<Decimal>(new Decimal[12]);
    for (Integer i = 0; i < 12; i++) {
        simulatedIncome[i] = 0;
        simulatedExpense[i] = 0;
    }

    for (String month : simulatedValues.keySet()) {
        Map<String, Object> values = (Map<String, Object>) simulatedValues.get(month);
        Integer monthIndex = monthToIndex.get(month);
        if (monthIndex != null) {
            if (values.containsKey('income') && values.get('income') != null) {
                simulatedIncome[monthIndex - 1] = (Decimal) values.get('income');
            }
            if (values.containsKey('expense') && values.get('expense') != null) {
                simulatedExpense[monthIndex - 1] = (Decimal) values.get('expense');
            }
        }
    }

    List<String> monthLabels = new List<String>();
    for (Integer m = 1; m <= 12; m++) {
        monthLabels.add(getMonthLabel(m));
    }


    System.debug('📊 Simulated Income: ' + JSON.serialize(simulatedIncome));
    System.debug('📊 Simulated Expense: ' + JSON.serialize(simulatedExpense));
    System.debug('📊 Predicted Income: ' + JSON.serialize(predictedIncome));
    System.debug('📊 Predicted Expense: ' + JSON.serialize(predictedExpense));
    System.debug('📊 Month Labels: ' + JSON.serialize(monthLabels));


    return new Map<String, Object>{
        'actualIncome' => income,
        'actualExpense' => expense,
        'predictedIncome' => predictedIncome,
        'predictedExpense' => predictedExpense,
        'simulatedIncome' => simulatedIncome,
        'simulatedExpense' => simulatedExpense,
        'monthLabels' => monthLabels
    };
}


private static List<Decimal> applyHoltWintersnew(Map<Integer, List<Decimal>> history, Integer currentMonth) {
    Decimal alpha = 0.6; // Level smoothing
    Decimal beta = 0.2;  // Trend smoothing
    Decimal gamma = 0.1; // Seasonality smoothing

    List<Decimal> result = new List<Decimal>();
    Decimal level = 0;
    Decimal trend = 0;
    List<Decimal> seasonality = new List<Decimal>(new Decimal[12]);

    System.debug('📊 Applying Holt-Winters with current month: ' + currentMonth);  
    System.debug('📊 History: ' + JSON.serialize(history));

    // Initialize with available data
    Integer nonZeroMonths = 0;
    Decimal totalLevel = 0;
    for (Integer i = 0; i < 12; i++) {
        List<Decimal> monthData = history.get(i + 1);
        Decimal avg = 0;
        if (!monthData.isEmpty()) {
            for (Decimal val : monthData) {
                avg += val;
            }
            avg /= monthData.size();
            if (avg > 0) {
                seasonality[i] = avg;
                totalLevel += avg;
                nonZeroMonths++;
            }
        }
    }
    level = nonZeroMonths > 0 ? totalLevel / nonZeroMonths : 100; // Default to 100 if no data
    for (Integer i = 0; i < 12; i++) {
        if (seasonality[i] == 0 && nonZeroMonths > 0) {
            seasonality[i] = level / nonZeroMonths; // Distribute average to zero months
        }
    }

    trend = nonZeroMonths > 1 ? (seasonality[11] - seasonality[0]) / 11 : 0.01; // Minimum trend

    System.debug('📊 Initial Level: ' + level);
    System.debug('📊 Initial Trend: ' + trend);
    System.debug('📊 Initial Seasonality: ' + JSON.serialize(seasonality));

    // Generate forecasts
    for (Integer i = 0; i < 12; i++) {
        if (i < currentMonth - 1) {
            result.add(0); // Actuals already exist
        } else {
            Integer idx = Math.mod(i, 12);
            Decimal lastValue = result.isEmpty() ? level : result[result.size() - 1];
            level = alpha * (seasonality[idx] != null ? seasonality[idx] : level) + (1 - alpha) * (lastValue + trend);
            trend = beta * (level - lastValue) + (1 - beta) * trend;
            Decimal seasonal = seasonality[idx];
            seasonality[idx] = gamma * (lastValue + trend - level) + (1 - gamma) * seasonal;

            Decimal forecast = level + trend + seasonal;
            result.add(forecast > 0 ? forecast.setScale(2) : 0.01); // Minimum value of 0.01
        }
    }

    System.debug('📊 Holt-Winters Forecast: ' + JSON.serialize(result));
    System.debug('📊 Updated Seasonality: ' + JSON.serialize(seasonality));

    return result;
}

private static String getMonthLabel(Integer month) {
    List<String> months = new List<String>{
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    };
    return months[month - 1];
}


}