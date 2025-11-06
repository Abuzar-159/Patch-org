public with sharing class BillMatchingEvaluator{
  public class Response{
    @InvocableVariable(label = 'Bills Without Logistics'description = 'A formatted HTML list of bills that are missing any related logistics records.')
    public String BillsWithNoLogisticsHtml;
    @InvocableVariable(label = 'Bills Fully Received'description = 'A formatted HTML list of bills that have all logistics fully received and are ready for matching.')
    public String BillsWithFullyReceivedLogisticsHtml;
    @InvocableVariable(label = 'Bills With Pending Logistics'description = 'A formatted HTML list of bills with related logistics that are still partially pending.')
    public String BillsWithPendingLogisticsHtml;
    @InvocableVariable(label = 'Matching Prompt'description = 'A message asking the user whether they want to proceed with auto-matching eligible bills.')
    public String MatchPrompt;
    @InvocableVariable(label = 'Pending Logistics Email Alert'description = 'A message summarizing pending logistics that can be used in an alert or email reminder.')
    public String PendingLogisticsEmailNotice;
    @InvocableVariable(label = 'Auto-Match Result Summary'description = 'A formatted HTML summary of what happened during auto-matching: which bills were matched, posted, or had vouchers created.')
    public String AutoMatchResultsHtml;
    @InvocableVariable(label = 'Bills Skipped Due to Limits'description = 'A formatted HTML list of bills that were skipped from matching due to exceeding quantity or amount thresholds.')
    public String BillsSkippedDueToLimitsHtml;
  }

  public class Request{
    @InvocableVariable(label = 'Period'description = 'The time period to analyze bills for (e.g., LAST_MONTH, THIS_QUARTER, LAST_FISCAL_YEAR).')
    public String period;
    @InvocableVariable(label = 'Auto Match Bills'description = 'If true, matched bills will be auto-posted and vouchers created for posted bills. If false, only analysis will be performed.')
    public Boolean shouldMatchBills;
    @InvocableVariable(label = 'Specific Bill Name (Optional)'description = 'Analyze or process only this bill if specified; leave blank to analyze all bills in the selected period.')
    public String specificBillName;
  }

  @InvocableMethod(label = 'Bill Match + AutoMatch Engine Enhanced' description = 'Evaluates Bills against Purchase Orders, checks logistics, and auto-matches if requested.')
  public static List<Response> BillMatchCheck(List<Request> requests){
    Set<String> processedBillIds = new Set<String>();
    List<Response> responses = new List<Response>();
    List<String> skippedDueToLimit = new List<String>();
    String baseUrl = URL.getOrgDomainUrl().toExternalForm().replace('https://', 'https://') + '/lightning/r/';
    Decimal maxAmountLimit = 0;
    Decimal maxQuantityLimit = 0;
    List<AXO_Meta_Data_Types__c> meta = [SELECT Bill_Amount_Treshold__c, Bill_Quantity_Treshold__c
                                         FROM AXO_Meta_Data_Types__c
                                         WHERE Name = 'Bill Match Limit'];
    if (!meta.isEmpty()){
      maxAmountLimit = meta[0].Bill_Amount_Treshold__c;
      maxQuantityLimit = meta[0].Bill_Quantity_Treshold__c;
    }


    for (Request req : requests){
      List<String> noLogistics = new List<String>();
      List<String> fullyReceived = new List<String>();
      List<String> pendingLogistics = new List<String>();
      List<Bill__c> billsReadyToMatch = new List<Bill__c>();
      List<String> matchedResults = new List<String>();
      Map<String, List<String>> emailToPendingDetails = new Map<String, List<String>>();

      List<Bill__c> billList = new List<Bill__c>();

      // Optional: Match only a specific bill
      if (!String.isBlank(req.specificBillName)){
        billList = [SELECT Id, Name, Matched__c, Purchase_Order__c, Purchase_Order__r.Name, Total_Quantity__c, Total_Amount__c
                    FROM Bill__c
                    WHERE Name = :req.specificBillName];
      } else{
        try{
          billList = (List<Bill__c>)Database.query('SELECT Id, Name, Matched__c, Purchase_Order__c, Purchase_Order__r.Name, Total_Quantity__c, Total_Amount__c ' +
                                                   'FROM Bill__c WHERE CreatedDate = ' + req.period);
        } catch (Exception e){
          Response err = new Response();
          err.MatchPrompt = '<span style="color:red;">❌ Invalid period format:</span> <b>' + req.period + '</b>';
          responses.add(err);
          return responses;
        }
      }

      for (Bill__c bill : billList){
        if (processedBillIds.contains(bill.Id))
          continue;
        processedBillIds.add(bill.Id);

        if (bill.Matched__c == true)
          continue;
        if (bill.Purchase_Order__c == null){
          String billUrl = baseUrl + 'Bill__c/' + bill.Id + '/view';
          noLogistics.add('<b>📦 Bill:</b> <a href="' + billUrl + '" target="_blank">' + bill.Name + '</a> has no linked Purchase Order.');
          continue;
        }

        Id poId = bill.Purchase_Order__c;
        String poName = bill.Purchase_Order__r?.Name;

        List<Logistic__c> logistics = [SELECT Id, Name, To_Address__r.Contact__r.Email
                                       FROM Logistic__c
                                       WHERE Purchase_Order__c = :poId];

        if (logistics.isEmpty()){
          String poUrl = baseUrl + 'PO__c/' + poId + '/view';
          String billUrl = baseUrl + 'Bill__c/' + bill.Id + '/view';
          noLogistics.add('<b>📦 PO:</b> <a href="' + poUrl + '" target="_blank">' + poName + '</a> has no logistics for Bill <a href="' + billUrl + '" target="_blank">' + bill.Name + '</a>.');
          continue;
        }

        Boolean hasUnreceived = false;
        List<String> unreceivedDetails = new List<String>();

        for (Logistic__c log : logistics){
          List<Logistic_Line_Item__c> lineItems = [SELECT Id, Name, Quantity__c, Remaining_Quantity__c
                                                   FROM Logistic_Line_Item__c
                                                   WHERE Logistic__c = :log.Id];

          for (Logistic_Line_Item__c item : lineItems){
            if (item.Remaining_Quantity__c > 0){
              hasUnreceived = true;
              String msg = '<li><b>Item:</b> "' + item.Name + '" → <span style="color:red;">' + item.Remaining_Quantity__c + ' pending</span></li>';
              unreceivedDetails.add(msg);

              String email = log.To_Address__r?.Contact__r?.Email;
              if (!String.isBlank(email)){
                if (!emailToPendingDetails.containsKey(email)){
                  emailToPendingDetails.put(email, new List<String>());
                }
                String poUrl = baseUrl + 'PO__c/' + poId + '/view';
                String billUrl = baseUrl + 'Bill__c/' + bill.Id + '/view';
                emailToPendingDetails.get(email).add('🧾 Bill <a href="' + billUrl + '">' + bill.Name + '</a> from PO <a href="' + poUrl + '">' + poName + '</a><br>' + msg);
              }
            }
          }
        }

        if (hasUnreceived){
          String poUrl = baseUrl + 'PO__c/' + poId + '/view';
          String billUrl = baseUrl + 'Bill__c/' + bill.Id + '/view';
          pendingLogistics.add('<b>🚧 Bill:</b> <a href="' + billUrl + '" target="_blank">' + bill.Name + '</a> from PO <a href="' + poUrl + '" target="_blank">' + poName + '</a> has pending logistics:<ul>' + String.join(unreceivedDetails, '') + '</ul>');
        } else{
          if ((bill.Total_Quantity__c != null && bill.Total_Quantity__c > maxQuantityLimit) || (bill.Total_Amount__c != null && bill.Total_Amount__c > maxAmountLimit)){

            String poUrl = baseUrl + 'PO__c/' + poId + '/view';
            String billUrl = baseUrl + 'Bill__c/' + bill.Id + '/view';
            String reason = '';

            if (bill.Total_Quantity__c > maxQuantityLimit){
              reason += '📦 Quantity <b>(' + bill.Total_Quantity__c + ')</b> exceeds limit (' + maxQuantityLimit + ')<br>';
            }
            if (bill.Total_Amount__c > maxAmountLimit){
              reason += '💰 Amount <b>$' + String.valueOf(bill.Total_Amount__c.setScale(2)) + '</b> exceeds limit ($' + maxAmountLimit + ')<br>';
            }

            skippedDueToLimit.add('<b>🚫 Bill:</b> <a href="' + billUrl + '" target="_blank">' + bill.Name + '</a> from PO <a href="' + poUrl + '" target="_blank">' + poName + '</a><br>' + reason);
            continue;
          }
          String poUrl = baseUrl + 'PO__c/' + poId + '/view';
          String billUrl = baseUrl + 'Bill__c/' + bill.Id + '/view';
          String readyText = '✅ <b>Bill:</b> <a href="' + billUrl + '" target="_blank">' + bill.Name + '</a> from PO <a href="' + poUrl + '" target="_blank">' + poName + '</a> is ready for matching.';
          readyText += '<br>📦 <b>Items:</b> ' + bill.Total_Quantity__c + ' &nbsp;&nbsp; 💰 <b>Amount:</b> $' + String.valueOf(bill.Total_Amount__c.setScale(2));
          fullyReceived.add(readyText);
          billsReadyToMatch.add(bill);
        }
      }

      // ⚙️ If matching requested
      if (req.shouldMatchBills){
        if (!String.isBlank(req.specificBillName)){
          // 🔍 Match specific bill by Name
          List<Bill__c> billListToMatch = [SELECT Id, Name, Matched__c, Total_Quantity__c, Total_Amount__c
                                           FROM Bill__c
                                           WHERE Name = :req.specificBillName
                                           LIMIT 1];

          if (billListToMatch.isEmpty()){
            matchedResults.add('❌ Bill not found: ' + req.specificBillName);
          } else{
            Bill__c bill = billListToMatch[0];
            if (bill.Matched__c == true){
              matchedResults.add('ℹ️ Already matched: ' + bill.Name);
            } else{
              try{
                bill.Matched__c = true;
                update bill;
                matchedResults.add('✅ Matched Bill: <b>' + bill.Name + '</b>');
              } catch (Exception e){
                matchedResults.add('❌ Failed to update Bill: <b>' + bill.Name + '</b> — ' + e.getMessage());
              }
            }
          }
        } else{
          // 🔍 Match all ready bills (already full SObjects)
          List<Bill__c> readyBills = billsReadyToMatch;
          System.debug('🔍 Matching ' + readyBills.size() + ' ready bills.');

          List<Bill__c> toUpdate = new List<Bill__c>();

          for (Bill__c bill : readyBills){
            if (bill.Matched__c == true){
              matchedResults.add('ℹ️ Already matched: ' + bill.Name);
            } else{
              bill.Matched__c = true;
              toUpdate.add(bill);
            }
          }

          if (!toUpdate.isEmpty()){
            try{
              update toUpdate;
              for (Bill__c b : toUpdate){
                String billUrl = baseUrl + 'Bill__c/' + b.Id + '/view';
                String matchText = '✅ Matched Bill: <a href="' + billUrl + '" target="_blank"><b>' + b.Name + '</b></a>';
                matchText += '<br>📦 <b>Items:</b> ' + b.Total_Quantity__c + ' &nbsp;&nbsp; 💰 <b>Amount:</b> $' + String.valueOf(b.Total_Amount__c.setScale(2));
                matchedResults.add(matchText);
              }
            } catch (Exception e){
              matchedResults.add('❌ Failed to update one or more Bills — ' + e.getMessage());
            }
          }
        }
      }

      // 📤 Build response
      Response res = new Response();
      if (matchedResults.isEmpty()){
        res.BillsWithNoLogisticsHtml = formatBlock(noLogistics, '#f8d7da', '❌ Bills With No Logistics');
        res.BillsWithFullyReceivedLogisticsHtml = formatBlock(fullyReceived, '#d4edda', '✅ Bills Ready for Matching');
        res.BillsWithPendingLogisticsHtml = formatBlock(pendingLogistics, '#fff3cd', '🚧 Pending Logistics');
        res.BillsSkippedDueToLimitsHtml = formatBlock(skippedDueToLimit, '#f4cccc', '🚫 Bills Skipped Due to Limit Thresholds');

        if (!String.isBlank(req.specificBillName)){
          res.MatchPrompt = '<b>Matched specific bill:</b> ' + req.specificBillName;
        } else if (!fullyReceived.isEmpty()){
          res.MatchPrompt = '✨ <b>Would you like to auto match all</b> <span style="color:green;">' + fullyReceived.size() + '</span> bill(s)?';
        }

        if (!emailToPendingDetails.isEmpty()){
          List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
          List<String> notified = new List<String>();

          for (String email : emailToPendingDetails.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ email });
            mail.setSubject('Pending Logistics Alert');
            mail.setPlainTextBody('Hello,\n\nThe following logistics are pending:\n\n' + String.join(emailToPendingDetails.get(email), '\n\n') +
                                 '\n\nThank you,\nAxolt Logistics Automation');
            emailList.add(mail);
            notified.add(email);
          }

          Messaging.sendEmail(emailList, false);
          res.PendingLogisticsEmailNotice = '📧 <b>Alerts sent to:</b> ' + String.join(notified, ', ');
        } else if (!pendingLogistics.isEmpty()){
          res.PendingLogisticsEmailNotice = '⚠️ <b>Pending logistics found, but no contact emails available.</b>';
        } else{
          res.PendingLogisticsEmailNotice = '✅ <b>No pending logistics found.</b>';
        }
      }
      // 🤖 Auto Match Results
      res.AutoMatchResultsHtml = formatBlock(matchedResults, '#d1ecf1', '🤖 Auto Match Results');

      responses.add(res);
    }

    return responses;
  }

  private static String formatBlock(List<String> lines, String bgColor, String title){
    if (lines.isEmpty())
      return '';
    String html = '<div style="background:' + bgColor + ';padding:12px;border-radius:8px;margin:10px 0;">';
    html += '<h3 style="margin:0 0 8px 0;">' + title + '</h3><ul style="padding-left:20px;">';
    for (String line : lines){
      html += '<li style="margin-bottom:6px;">' + line + '</li>';
    }
    html += '</ul></div>';
    return html;
  }

}