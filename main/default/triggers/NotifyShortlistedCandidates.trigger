trigger NotifyShortlistedCandidates on ERP7__Job_Applicant__c (after update) {
   /* Set<Id> applicantIds = new Set<Id>();

    // Collect IDs of applicants whose status changed to 'Interview'
    for (ERP7__Job_Applicant__c applicant : Trigger.New) {
        if (applicant.ERP7__Status__c == 'Interview' && Trigger.oldMap.get(applicant.Id).ERP7__Status__c != 'Interview') {
            applicantIds.add(applicant.Id);
        }
    }

    // Fetch the job applicants
    List<ERP7__Job_Applicant__c> applicants = [SELECT Id, ERP7__Email__c, Name FROM ERP7__Job_Applicant__c WHERE Id IN :applicantIds];
    
    // Create a list to hold email messages
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    // Prepare email for each applicant
    for (ERP7__Job_Applicant__c applicant : applicants) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { applicant.ERP7__Email__c });
        email.setSubject('Congratulations! You Are Shortlisted for the Next Round');
        
        // Set the interview date 7 days from the current date
        Date interviewDate = Date.today().addDays(7);
        
        // Check if the interview date falls on a Saturday or Sunday
        DateTime dt = (DateTime) interviewDate;
        String dayOfWeek = dt.format('E'); // 'E' returns the day of the week abbreviation

        if (dayOfWeek == 'Sat') {
            interviewDate = interviewDate.addDays(2); // Move to next Monday
        } else if (dayOfWeek == 'Sun') {
            interviewDate = interviewDate.addDays(1); // Move to Monday
        }
        
        // Prepare the email body
        String body = 'Dear ' + applicant.Name + ',\n\n' +
                      'Congratulations! You have been shortlisted for the next round of the interview process.\n\n' +
                      'Your interview is scheduled for ' + interviewDate.format() + '.\n\n' +
                      'Best regards,\n' +
                      '[Your Name]';
        
        email.setPlainTextBody(body);
        
        emails.add(email);
    }
    
    // Send all emails
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }*/
}