trigger createInterviewActions on ERP7__Job_Applicant__c (after update) {
   /* // Collect all interview and position ids from the Trigger
    Set<Id> interviewIds = new Set<Id>();
    Set<Id> positionIds = new Set<Id>();

    // Loop through job applicants to collect interview and position IDs
    for(ERP7__Job_Applicant__c applicant : Trigger.new) {
        if(applicant.ERP7__Interview__c != null) {
            interviewIds.add(applicant.ERP7__Interview__c);
        }
    }

    // Exit early if no interviews or positions found
    if(interviewIds.isEmpty()) {
        return;
    }

    // Query all checklists matching the interview and position combinations
    List<ERP7__Checklist__c> interviewCheckList = [
        SELECT Id, Name, ERP7__Interview__c ,ERP7__Action_Detail__c, ERP7__Action_Type__c
        FROM ERP7__Checklist__c 
        WHERE ERP7__Interview__c IN :interviewIds 
    ];

    // Fetch the Record Type ID for 'Interview Task'
    String interviewTaskRecordTypeName = 'Interview Task';
    RecordType interviewTaskRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'ERP7__Actions_Tasks__c' AND Name = :interviewTaskRecordTypeName LIMIT 1];

    // Prepare to map the job applicant ID to its corresponding interview and position
    Map<Id, ERP7__Job_Applicant__c> jobApplicantMap = new Map<Id, ERP7__Job_Applicant__c>(Trigger.new);

    // List to hold actions to be upserted
    List<ERP7__Actions_Tasks__c> actions2upsert = new List<ERP7__Actions_Tasks__c>();

    // Loop through each job applicant
    for(ERP7__Job_Applicant__c applicant : Trigger.new) {
        // Only process if interview and position are filled
        if(applicant.ERP7__Interview__c != null && applicant.ERP7__Position__c != null) {
            // Loop through the checklists and create tasks/actions
            for(ERP7__Checklist__c chk : interviewCheckList) {
                if(chk.ERP7__Interview__c == applicant.ERP7__Interview__c) {
                    ERP7__Actions_Tasks__c act = new ERP7__Actions_Tasks__c();
                    act.ERP7__Checklist__c = chk.Id;
                    act.Name = chk.Name;
                    act.ERP7__Job_Applicant__c = applicant.Id;
                    act.ERP7__Action_Detail__c = chk.ERP7__Action_Detail__c;
                    act.ERP7__Action_Type__c = chk.ERP7__Action_Type__c;

                    // Assign the 'Interview Task' record type
                    act.RecordTypeId = interviewTaskRecordType.Id;

                    actions2upsert.add(act);
                }
            }
        }
    }

    // Perform DML on the collected actions/tasks in bulk
    if(!actions2upsert.isEmpty()) {
        upsert actions2upsert;
    }*/
}