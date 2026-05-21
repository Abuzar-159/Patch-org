trigger SendRejectionEmail on ERP7__Actions_Tasks__c (after update) {
  /*  List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    // Collect Job Applicant IDs for querying
    Set<Id> applicantIds = new Set<Id>();
    
    for (ERP7__Actions_Tasks__c actionTask : Trigger.new) {
        if (actionTask.Status__c == 'Rejected') {
            // Add the Job Applicant ID to the set
            applicantIds.add(actionTask.Job_Applicant__c);
        }
    }
    
    // Query related Job Applicants
    Map<Id, ERP7__Job_Applicant__c> applicantMap = new Map<Id, ERP7__Job_Applicant__c>();
    if (!applicantIds.isEmpty()) {
        List<ERP7__Job_Applicant__c> applicants = [SELECT Id, ERP7__First_Name__c, ERP7__Email__c FROM ERP7__Job_Applicant__c WHERE Id IN :applicantIds];
        for (ERP7__Job_Applicant__c applicant : applicants) {
            applicantMap.put(applicant.Id, applicant);
        }
    }
    
    // Create emails for each rejected action/task
    for (ERP7__Actions_Tasks__c actionTask : Trigger.new) {
        if (actionTask.Status__c == 'Rejected') {
            // Get the related Job Applicant
            ERP7__Job_Applicant__c applicant = applicantMap.get(actionTask.Job_Applicant__c);
            
            if (applicant != null) {
                // Create and configure the email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { applicant.ERP7__Email__c });
                email.setSubject('Interview Status: Application Update');
                email.setPlainTextBody('Dear ' + applicant.ERP7__First_Name__c + ',\n\n' +
                                        'We regret to inform you that you did not qualify for ' + actionTask.Name + ' of the interview process.\n\n' +
                                        'Thank you for your interest in the position and for the time you invested in your application. We encourage you to apply for future opportunities that align with your skills and interests.\n\n' +
                                        'If you have any questions or need further information, please feel free to reach out.\n\n' +
                                        'Best regards,\n' +
                                        'Axolt\n' +
                                        'HR Manager');
                emails.add(email);
            }
        }
    }
    
    // Send the emails if there are any
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }*/
}