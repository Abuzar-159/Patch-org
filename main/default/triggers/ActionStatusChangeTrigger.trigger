trigger ActionStatusChangeTrigger on ERP7__Actions_Tasks__c (after update) {

   /* // Collect job applicant IDs related to the updated actions
    Set<Id> jobApplicantIds = new Set<Id>();
    for (ERP7__Actions_Tasks__c task : Trigger.new) {
        ERP7__Actions_Tasks__c oldTask = Trigger.oldMap.get(task.Id);
        
        if (task.ERP7__Status__c != oldTask.ERP7__Status__c) {
            // Add the job applicant ID to the set
            jobApplicantIds.add(task.ERP7__Job_Applicant__c);
        }
    }

    // Fetch job applicants
    List<ERP7__Job_Applicant__c> applicants = [SELECT Id, ERP7__Email__c, Name FROM ERP7__Job_Applicant__c WHERE Id IN :jobApplicantIds];

    // Create a map to quickly access the email and name by job applicant ID
    Map<Id, ERP7__Job_Applicant__c> applicantMap = new Map<Id, ERP7__Job_Applicant__c>();
    for (ERP7__Job_Applicant__c applicant : applicants) {
        applicantMap.put(applicant.Id, applicant);
    }

    // Create a list to hold email messages
    List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

    // Iterate over the updated records
    for (ERP7__Actions_Tasks__c task : Trigger.new) {
        ERP7__Actions_Tasks__c oldTask = Trigger.oldMap.get(task.Id);

        // Check if the status has changed and determine the next round
        if (task.ERP7__Status__c != oldTask.ERP7__Status__c) {
            String nextRound = '';
            Boolean isNextRound = false;

            // Determine the next round based on the new status
            if (task.ERP7__Status__c == 'Qualified For Next Round') {
                nextRound = 'Group Discussion';
                isNextRound = true;
            } else if (task.ERP7__Status__c == 'Qualified For Next Round') {
                nextRound = 'HR Round';
                isNextRound = true;
            } else if (task.ERP7__Status__c == 'HR Round Passed') {
                nextRound = 'Final Round'; // Adjust based on your process
                isNextRound = true;
            }

            if (isNextRound) {
                // Get the job applicant related to the task
                ERP7__Job_Applicant__c applicant = applicantMap.get(task.ERP7__Job_Applicant__c);

                if (applicant != null) {
                    // Calculate the date two days after the status change
                    Date changeDate = task.LastModifiedDate.date();
                    Date notifyDate = changeDate.addDays(2);

                    // Check if the notify date falls on a weekend
                    DateTime notifyDateTime = (DateTime) notifyDate;
                    String dayOfWeek = notifyDateTime.format('E'); // 'E' returns the day of the week abbreviation

                    if (dayOfWeek == 'Sat') {
                        notifyDate = notifyDate.addDays(2); // Move to next Monday
                    } else if (dayOfWeek == 'Sun') {
                        notifyDate = notifyDate.addDays(1); // Move to Monday
                    }

                    // Convert notifyDate to DateTime for formatting
                    notifyDateTime = (DateTime) notifyDate;

                    // Construct the email body
                    String body = 'Dear ' + applicant.Name + ',\n\n'
                                + 'We are pleased to inform you that you have progressed to the next round of our selection process.\n\n'
                                + 'Next Round: ' + nextRound + '\n'
                                + 'Date of Notification: ' + notifyDateTime.format('yyyy-MM-dd') + '\n\n'
                                + 'Please be prepared for the next steps as outlined. We will provide further details soon.\n\n'
                                + 'Thank you for your continued interest in the position.\n\n'
                                + 'Best regards,\n'
                                + 'The Recruitment Team';

                    // Create and send the email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { applicant.ERP7__Email__c });
                    email.setSubject('Update on Your Interview Rounds');
                    email.setPlainTextBody(body);
                    emailMessages.add(email);
                }
            }
        }
    }

    // Send the emails if there are any
    if (!emailMessages.isEmpty()) {
        Messaging.sendEmail(emailMessages);
    }*/
}