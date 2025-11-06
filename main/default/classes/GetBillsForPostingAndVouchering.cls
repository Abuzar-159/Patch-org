public with sharing class GetBillsForPostingAndVouchering{
  public class Response{
    @InvocableVariable(label = 'Bills to Post'description = 'List of Bill record IDs that are matched but not posted.')
    public List<Id> BillsToPost;
    @InvocableVariable(label = 'Bills to Create Vouchers For'description = 'List of Bill record IDs that are posted but have no vouchers yet.')
    public List<Id> BillsToCreateVouchers;
    @InvocableVariable(label = 'Skipped - Exceeds Post Limits (HTML)'description = 'Formatted HTML list of bills skipped from posting due to exceeding amount or quantity limits.')
    public String BillsSkippedForPostHtml;
    @InvocableVariable(label = 'Skipped - Exceeds Voucher Limits (HTML)'description = 'Formatted HTML list of bills skipped from voucher creation due to exceeding amount or quantity limits.')
    public String BillsSkippedForVoucherHtml;
    @InvocableVariable(label = 'Matched but Not Posted (HTML)'description = 'Formatted HTML block showing bills that are matched but not yet posted.')
    public String MatchedNotPostedHtml;
    @InvocableVariable(label = 'Posted but No Voucher (HTML)'description = 'Formatted HTML block showing bills that are posted but have no vouchers.')
    public String PostedNoVoucherHtml;
  }

  public class Request{
    @InvocableVariable(label = 'Time Period'description = 'The period to filter bills by (e.g., THIS_YEAR, LAST_MONTH, etc.).')
    public String Period;
    @InvocableVariable(label = 'Limit for Display'description = 'The number of records to show in the HTML output (default is 10 if none given).')
    public Decimal QuantityLimit;
  }

  @InvocableMethod(label = '🔎 Get Bills for Posting & Vouchering Enhanced'description = 'Returns a list of Bills that are matched but not posted and/or bills that are posted but have no vouchers.')
  public static List<Response> getBills(List<Request> requests){
    List<Response> results = new List<Response>();
    if (requests.isEmpty())
      return results;
    Request req = requests[0];
    Decimal postAmountLimit = 0;
    Decimal postQuantityLimit = 0;
    Decimal voucherAmountLimit = 0;
    Decimal voucherQuantityLimit = 0;

    Map<String, AXO_Meta_Data_Types__c> limitsMap = new Map<String, AXO_Meta_Data_Types__c>();
    for (AXO_Meta_Data_Types__c conf : [SELECT Name, Bill_Amount_Treshold__c, Bill_Quantity_Treshold__c
                                        FROM AXO_Meta_Data_Types__c
                                        WHERE Name IN ('Bill Post Limit', 'Voucher Creation Limit')]){
      limitsMap.put(conf.Name, conf);
    }

    if (limitsMap.containsKey('Bill Post Limit')){
      postAmountLimit = limitsMap.get('Bill Post Limit').Bill_Amount_Treshold__c;
      postQuantityLimit = limitsMap.get('Bill Post Limit').Bill_Quantity_Treshold__c;
    }
    if (limitsMap.containsKey('Voucher Creation Limit')){
      voucherAmountLimit = limitsMap.get('Voucher Creation Limit').Bill_Amount_Treshold__c;
      voucherQuantityLimit = limitsMap.get('Voucher Creation Limit').Bill_Quantity_Treshold__c;
    }

    Response res = new Response();
    String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/';

    String soql = 'SELECT Id, Name, Matched__c, Posted__c, Vendor__c, Amount_Due__c, TDS_Amount__c, Total_Amount__c ' +
                 'FROM Bill__c WHERE (Matched__c = true OR Posted__c = true) ' +
                 'AND CreatedDate = ' + req.Period + ' ORDER BY CreatedDate DESC';

    List<Bill__c> bills = Database.query(soql);
    Set<Id> billIds = new Set<Id>();
    for (Bill__c b : bills)
      billIds.add(b.Id);
    Map<Id, List<Voucher__c>> voucherMap = new Map<Id, List<Voucher__c>>();
    for (Voucher__c v : [SELECT Id, Vendor_invoice_Bill__c
                         FROM Voucher__c
                         WHERE Vendor_invoice_Bill__c IN:billIds]){
      if (!voucherMap.containsKey(v.Vendor_invoice_Bill__c)){
        voucherMap.put(v.Vendor_invoice_Bill__c, new List<Voucher__c>());
      }
      voucherMap.get(v.Vendor_invoice_Bill__c).add(v);
    }

    List<Id> billsToPost = new List<Id>();
    List<Id> billsToVoucher = new List<Id>();
    List<String> matchedNotPostedList = new List<String>();
    List<String> postedNoVoucherList = new List<String>();
    List<String> skippedForPostList = new List<String>();
    List<String> skippedForVoucherList = new List<String>();

    Decimal postRunningAmount = 0;
    Decimal voucherRunningAmount = 0;

    for (Bill__c bill : bills){
      Decimal totalAmount = bill.Total_Amount__c != null ? bill.Total_Amount__c : 0;
      String billUrl = baseUrl + 'Bill__c/' + bill.Id + '/view';

      if (bill.Matched__c && !bill.Posted__c){
        if (billsToPost.size() < postQuantityLimit && (postRunningAmount + totalAmount) <= postAmountLimit){
          billsToPost.add(bill.Id);
          postRunningAmount += totalAmount;
          matchedNotPostedList.add('<li>🧾 <a href="' + billUrl + '" target="_blank"><b>' + bill.Name + '</b></a>' +
                                   '<br>💰 <b>Amount:</b> $' + String.valueOf(totalAmount.setScale(2)) + '</li>');
        } else{
          skippedForPostList.add('<li>❌ <a href="' + billUrl + '" target="_blank"><b>' + bill.Name + '</b></a>' +
                                   '<br>💰 <b>Amount:</b> $' + String.valueOf(totalAmount.setScale(2)) + '</li>');
        }
      }

      if (bill.Posted__c && (!voucherMap.containsKey(bill.Id) || voucherMap.get(bill.Id).isEmpty())){
        if (billsToVoucher.size() < voucherQuantityLimit && (voucherRunningAmount + totalAmount) <= voucherAmountLimit){
          billsToVoucher.add(bill.Id);
          voucherRunningAmount += totalAmount;
          postedNoVoucherList.add('<li>🧾 <a href="' + billUrl + '" target="_blank"><b>' + bill.Name + '</b></a>' +
                                 '<br>💰 <b>Amount:</b> $' + String.valueOf(totalAmount.setScale(2)) + '</li>');
        } else{
          skippedForVoucherList.add('<li>❌ <a href="' + billUrl + '" target="_blank"><b>' + bill.Name + '</b></a>' +
                                 '<br>💰 <b>Amount:</b> $' + String.valueOf(totalAmount.setScale(2)) + '</li>');
        }
      }
    }

    res.BillsToPost = billsToPost;
    res.BillsToCreateVouchers = billsToVoucher;
    res.MatchedNotPostedHtml = formatBlock(matchedNotPostedList, '#f8d7da', '🟠 Matched but Not Posted Bills');
    res.PostedNoVoucherHtml = formatBlock(postedNoVoucherList, '#fff3cd', '🟡 Posted but No Voucher');
    res.BillsSkippedForPostHtml = formatBlock(skippedForPostList, '#ffe0e0', '⛔ Skipped from Posting Due to Limits');
    res.BillsSkippedForVoucherHtml = formatBlock(skippedForVoucherList, '#fdf3e0', '⛔ Skipped from Voucher Creation Due to Limits');

    results.add(res);
    return results;
  }

  private static String formatBlock(List<String> lines, String bgColor, String title){
    if (lines.isEmpty())
      return '';
    String html = '<div style="background:' + bgColor + ';padding:12px;border-radius:8px;margin:10px 0;">';
    html += '<h3 style="margin:0 0 8px 0;">' + title + '</h3><ul style="padding-left:20px;">';
    for (String line : lines)
      html += line;
    html += '</ul></div>';
    return html;
  }

}