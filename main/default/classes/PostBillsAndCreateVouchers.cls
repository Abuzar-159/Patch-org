public with sharing class PostBillsAndCreateVouchers{
  public class Request{
    @InvocableVariable(label = 'Bills to Process' description = 'List of Bill record IDs to be posted (if not already) and for which vouchers should be created (if missing). These Ids are to be obtained from the previous step of fetching bills for posting and vouchering.')
    public List<Id> BillIds;
  }

  public class Response{
    @InvocableVariable(label = 'Posting Results (HTML)' description = 'Formatted HTML summary showing which bills were successfully posted.')
    public String PostingResultsHtml;
    @InvocableVariable(label = 'Voucher Results (HTML)' description = 'Formatted HTML summary showing the vouchers that were created and their amounts.')
    public String VoucherResultsHtml;
  }

  @InvocableMethod(label = '🚀 Post Bills & Create Vouchers'  description = 'Automatically posts and creates vouchers for the specified bills.')
  public static List<Response> postAndCreate(List<Request> requests){
    List<Response> responses = new List<Response>();
    if (requests.isEmpty())
      return responses;
    Request req = requests[0];
    Response res = new Response();
    String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/';

    List<Bill__c> bills = [SELECT Id, Name, Matched__c, Posted__c, Vendor__c, Purchase_Order__c, Amount_Due__c, TDS_Amount__c, Total_Amount__c
                           FROM Bill__c
                           WHERE Id IN:req.BillIds];

    Map<Id, List<Voucher__c>> voucherMap = new Map<Id, List<Voucher__c>>();
    for (Voucher__c v : [SELECT Id, Vendor_invoice_Bill__c
                         FROM Voucher__c
                         WHERE Vendor_invoice_Bill__c IN:req.BillIds]){
      if (!voucherMap.containsKey(v.Vendor_invoice_Bill__c)){
        voucherMap.put(v.Vendor_invoice_Bill__c, new List<Voucher__c>());
      }
      voucherMap.get(v.Vendor_invoice_Bill__c).add(v);
    }

    List<Bill__c> toPost = new List<Bill__c>();
    List<Voucher__c> vouchersToInsert = new List<Voucher__c>();

    List<String> postingResults = new List<String>();
    List<String> voucherResults = new List<String>();

    for (Bill__c b : bills){
      if (!b.Posted__c){
        b.Posted__c = true;
        toPost.add(b);
        String billUrl = baseUrl + 'Bill__c/' + b.Id + '/view';
        postingResults.add('<li>✅ Posted: <a href="' + billUrl + '" target="_blank"><b>' + b.Name + '</b></a></li>');
      }

      if (!voucherMap.containsKey(b.Id) || voucherMap.get(b.Id).isEmpty()){
        Decimal finalAmount = (b.TDS_Amount__c != null && b.TDS_Amount__c > 0) ? b.Amount_Due__c - b.TDS_Amount__c : b.Total_Amount__c;

        Voucher__c v = new Voucher__c();
        v.Name = 'Auto Voucher - ' + b.Name;
        v.Vendor_invoice_Bill__c = b.Id;
        v.Vendor__c = b.Vendor__c;
        v.Amount__c = finalAmount;
        if (b.Purchase_Order__c != null)
          v.Purchase_Orders__c = b.Purchase_Order__c;
        vouchersToInsert.add(v);
      }
    }

    if (!toPost.isEmpty())
      update toPost;
    if (!vouchersToInsert.isEmpty())
      insert vouchersToInsert;
    for (Voucher__c v : vouchersToInsert){
      String voucherUrl = baseUrl + 'Voucher__c/' + v.Id + '/view';
      voucherResults.add('<li>✅ Voucher Created: <a href="' + voucherUrl + '" target="_blank"><b>' + v.Name + '</b></a>' +
                               '<br>💰 <b>Amount:</b> $' + String.valueOf(v.Amount__c.setScale(2)) + '</li>');
    }

    res.PostingResultsHtml = formatBlock(postingResults, '#e2f0cb', '📌 Bill Posting Results');
    res.VoucherResultsHtml = formatBlock(voucherResults, '#d4edda', '🧾 Voucher Creation Results');
    responses.add(res);
    return responses;
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