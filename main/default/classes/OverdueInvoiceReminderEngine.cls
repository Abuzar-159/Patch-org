public with sharing class OverdueInvoiceReminderEngine {

    public class Request {
        @InvocableVariable(label = 'Period')
        public String Period;

        @InvocableVariable(label = 'Months')
        public Integer Months;

        @InvocableVariable(label = 'Send Emails?')
        public Boolean sendEmails;
    }

    public class Response {
        @InvocableVariable(label = 'Overdue Invoice Summary (HTML)')
        public String SummaryHtml;

        @InvocableVariable(label = 'Email Status (HTML)')
        public String EmailStatusHtml;
    }

    @InvocableMethod(label = 'Get Overdue Invoices and Optionally Send Emails')
    public static List<Response> getOverdueInvoicesAndOptionallySendEmails(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests.isEmpty()) return responses;

        Request req = requests[0];
        Date today = Date.today();
        Date fromDate;
        Date toDate = today;

        if (req.Period == 'LAST_X_MONTHS' && req.Months != null) {
            fromDate = today.addMonths(-req.Months);
        } else if (req.Period == 'LAST_3_MONTHS') {
            fromDate = today.addMonths(-3);
        } else if (req.Period == 'LAST_3_YEARS') {
            fromDate = today.addYears(-3);
        } else if (req.Period == 'THIS_YEAR') {
            fromDate = Date.newInstance(today.year(), 1, 1);
        } else if (req.Period == 'LAST_YEAR') {
            fromDate = Date.newInstance(today.year() - 1, 1, 1);
            toDate = Date.newInstance(today.year() - 1, 12, 31);
        } else if (req.Period == 'FROM_LAST_YEAR_TILL_NOW') {
            fromDate = Date.newInstance(today.year() - 1, 1, 1);
        } else if (req.Period == 'LAST_MONTH') {
            Integer lastMonth = today.month() == 1 ? 12 : today.month() - 1;
            Integer yearOfLastMonth = today.month() == 1 ? today.year() - 1 : today.year();
            Integer daysInMonth = Date.daysInMonth(yearOfLastMonth, lastMonth);
            fromDate = Date.newInstance(yearOfLastMonth, lastMonth, 1);
            toDate = Date.newInstance(yearOfLastMonth, lastMonth, daysInMonth);
        } else if (req.Period == 'THIS_MONTH'){
            fromDate = Date.newInstance(today.year(), today.month(), 1);
            Integer daysInMonth = Date.daysInMonth(today.year(), today.month());
            toDate = Date.newInstance(today.year(), today.month(), daysInMonth);
        } else {
            fromDate = today.addMonths(-3);
        }

        Set<Id> paidInvoiceIds = new Set<Id>();
        for (Payment__c pmt : [SELECT Invoice__c FROM Payment__c WHERE Invoice__c != null]) {
            paidInvoiceIds.add(pmt.Invoice__c);
        }

        List<Invoice__c> overdueInvoices = [
            SELECT Name, Account__r.Name, Account__r.Email__c, Due_Date__c, Invoice_Amount__c
            FROM Invoice__c
            WHERE Id NOT IN :paidInvoiceIds
              AND Due_Date__c < :today
              AND Due_Date__c >= :fromDate
              AND Due_Date__c <= :toDate
            ORDER BY Account__r.Name
        ];

        Map<String, List<Invoice__c>> customerMap = new Map<String, List<Invoice__c>>();
        for (Invoice__c inv : overdueInvoices) {
            String name = inv.Account__r.Name;
            if (!customerMap.containsKey(name)) {
                customerMap.put(name, new List<Invoice__c>());
            }
            customerMap.get(name).add(inv);
        }

        List<String> htmlBlocks = new List<String>();
        List<String> emailStatuses = new List<String>();
        Decimal totalDue = 0;

        for (String customer : customerMap.keySet()) {
            List<Invoice__c> invs = customerMap.get(customer);
            String block = '<div style="border:1px solid #ccc;padding:10px;border-radius:8px;margin-bottom:12px;">';
            block += '<h3>👤 ' + customer + '</h3>';
            block += '<table style="width:100%;border-collapse:collapse;"><tr><th style="border-bottom:1px solid #ccc;">Invoice</th><th style="border-bottom:1px solid #ccc;">Due Date</th><th style="border-bottom:1px solid #ccc;">Amount (₹)</th></tr>';
            Decimal custTotal = 0;
            for (Invoice__c i : invs) {
                block += '<tr><td>' + i.Name + '</td><td>' + i.Due_Date__c.format() + '</td><td>' + String.valueOf(i.Invoice_Amount__c) + '</td></tr>';
                custTotal += i.Invoice_Amount__c;
            }
            block += '<tr><td colspan="2"><strong>Total</strong></td><td><strong>₹' + String.valueOf(custTotal) + '</strong></td></tr>';
            block += '</table></div>';
            htmlBlocks.add(block);
            totalDue += custTotal;

            if (req.sendEmails && invs[0].Account__r.Email__c != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{invs[0].Account__r.Email__c});
                mail.setSubject('Reminder: Overdue Invoices for ' + customer);

                String emailBody = '<p>Dear ' + customer + ',</p>' +
                                   '<p>Please find below your overdue invoices:</p>' +
                                   block +
                                   '<p><strong>Total Due: ₹' + String.valueOf(custTotal.setScale(2)) + '</strong></p>' +
                                   '<p>Please make payment at your earliest convenience. If already paid, ignore this.</p>' +
                                   '<p>Thank you,<br/>Accounts Receivable Team</p>';

                mail.setHtmlBody(emailBody);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                emailStatuses.add('📧 Sent to: <strong>' + customer + '</strong> at ' + invs[0].Account__r.Email__c);
            }
        }

        Response res = new Response();
        if(req.sendEmails == false){
            res.SummaryHtml = htmlBlocks.isEmpty()
                ? '<div style="background:#d4edda;padding:10px;border-radius:8px;">✅ No Overdue Invoices found.</div>'
                : '<h2>📌 Overdue Invoices</h2>' + String.join(htmlBlocks, '');
        }

        res.EmailStatusHtml = emailStatuses.isEmpty()
            ? (req.sendEmails ? '<div style="color:red;">⚠️ No emails sent (missing Email addresses).</div>' : '<div style="color:gray;">ℹ️ Email sending was skipped.</div>')
            : '<div style="background:#e2f0fb;padding:10px;border-radius:8px;"><strong>Email Summary</strong><ul><li>' + String.join(emailStatuses, '</li><li>') + '</li></ul></div>';

        responses.add(res);
        return responses;
    }
}