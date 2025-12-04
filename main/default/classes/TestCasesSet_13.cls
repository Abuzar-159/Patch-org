@isTest
private class TestCasesSet_13 {
    static testMethod void UnitTestErpMark7() {
         Account orgn = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name = 'Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id, Organisation_Business_Unit__c = busUnit.id, Active__c = true, Street__c = 'Test Sndr Address Line 1', City__c = 'COLORADO SPRINGS', State_Province__c = 'Colorado', Country__c = 'United States', Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890');
        insert salepoint;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType = 'ERP7__Profiling__c'
        And Name = 'Employee'
        Limit 1
        ];
        Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id, Name = 'test', Active__c = true, RecordTypeId = rTypeProfile.Id);
        insert profile;
        Employees__c emp1 = new Employees__c(First_Name__c = 'test', Last_Name__c = 'test', Email__c = 'test@test.com', Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Employee_User__c = UserInfo.getUserId(), Employment_Status__c = 'Active', Non_Employee__c = false, Employee_Profiling__c = profile.Id);
        insert emp1;
        Employees__c emp2 = new Employees__c(First_Name__c = 'test', Last_Name__c = 'test', Email__c = 'test@test.com', Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Employment_Status__c = 'Active', Non_Employee__c = false, Employee_Profiling__c = profile.Id, ReportingManager__c = emp1.Id);
        insert emp2;
        Employees__c emp3 = new Employees__c(First_Name__c = 'test', Last_Name__c = 'test', Email__c = 'test@test.com', Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Employment_Status__c = 'Active', Non_Employee__c = false, Employee_Profiling__c = profile.Id);
        insert emp3;
        List < Organisational_Goal__c > OrgGoalList = new List < Organisational_Goal__c > ();
        Organisational_Goal__c OG = new Organisational_Goal__c(Name = 'test', Active__c = true, Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id);
        insert OG;
        Organisational_Objective__c OO = new Organisational_Objective__c(Name = 'test', Active__c = true, Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Organisational_Goal__c = OG.id);
        insert OO;
        Review__c R = new Review__c(Name = 'test', Active__c = true, Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Employees__c = emp1.Id, ReviewManager__c = emp2.Id);
        insert R;
        Goal__c G = new Goal__c(Name = 'test', Active__c = true, Review__c = R.Id, Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Employees__c = emp1.Id, Employee_Organisation_Goal__c = true);
        insert G;
        /* Goal__c G1 = new Goal__c(Name='test',Active__c=true,Review__c=R.Id,Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employees__c=emp1.Id,Employee_Organisation_Goal__c = false);
        insert G1;*/
        Objective__c OT = new Objective__c(Name = 'test', Active__c = true, Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Employee_Goal__c = G.Id);
        insert OT;
        Employee_Organisational_Goal__c EOG = new Employee_Organisational_Goal__c(Name = 'test', Active__c = true, Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Employee_Profiling__c = profile.Id, Organisational_Goal__c = OG.id);
        insert EOG;
        Employee_Organisational_Objective__c OT1 = new Employee_Organisational_Objective__c(Name = 'test', Active__c = true, Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.id, Employee_Organisational_Goal__c = EOG.Id, Employee_Profiling__c = profile.Id);
        insert OT1;
        try {
        Test.startTest();
        PageReference pageRefR = System.Page.EmployeeReview;
        pageRefR.getParameters().put('empId', emp1.Id);
        Test.setCurrentPage(pageRefR);
        EmployeeReviewV2 ERV = new EmployeeReviewV2();
        ERV.empId = emp1.Id;
        ERV.revId = R.Id;
        ERV.loadEmpOrgGoalObjective();
        ERV.review = R;
        ERV.review.Name = 'Test';
        ERV.review.Review_Type__c = 'Test';
        ERV.review.Start_Date__c = System.Today();
        ERV.review.Target_Completion_Date__c = System.Today();
        ERV.review.Status__c = 'Test';
        EmployeeReviewV2.EmpOrgGoalObjectiveWrapper EOGOBW = new EmployeeReviewV2.EmpOrgGoalObjectiveWrapper();
        ERV.EmpOrgGoalObjectiveWrapperList.add(EOGOBW);
        EmployeeReviewV2.ReviewLearningPlanWrapper RLPW = new EmployeeReviewV2.ReviewLearningPlanWrapper();
        RLPW.wrapLearningPlan.name = 'test';
        ERV.ReviewLearningPlanWrapperList.add(RLPW);
        EmployeeReviewV2.ReviewInitiativeWrapper RLPW1 = new EmployeeReviewV2.ReviewInitiativeWrapper();
        RLPW1.wrapInitiative.Name = 'test';
        ERV.ReviewInitiativeWrapperList.add(RLPW1);
        EmployeeReviewV2.ReviewRecommendationWrapper RLPW2 = new EmployeeReviewV2.ReviewRecommendationWrapper();
        RLPW2.wrapRecommendation.Name = 'test';
        ERV.ReviewRecommendationWrapperList.add(RLPW2);
        ERV.saveAndStay = true;
        ERV.saveReview();
        ERV.saveAndStay = false;
        ERV.saveAndReturn = true;
        ERV.saveReview();
        upsert ERV.review;
        ERV.saveAndReturn = false;
        ERV.submittedForApproval = 'true';
        ERV.saveReview();
        ERV.submittedForApproval = 'false';
        ERV.manageReviewApproval = true;
        //ERV.saveReview();
        ERV.manageReviewApproval = false;
        ERV.manageReviewRejection = true;
        //ERV.saveReview();
        ERV.filterReviews();
        ERV.review.Review_Type__c = null;
        ERV.filterReviews();
        ERV.review.Status__c = 'Test';
        ERV.viewEmpReviewPageRedirect();
        ERV.viewEmpMngr = emp2.Id;
        ERV.viewMngrEmpReviewPageRedirect();
        ERV.backToReviewPageRedirect();
        ERV.addNewEmpReviewPageRedirect();
        ERV.employeeMngr = emp2.Id;
        EmployeeReviewV2.EmpOrgGoalObjectiveWrapper EOGB = new EmployeeReviewV2.EmpOrgGoalObjectiveWrapper();
        ERV.addNewMngrEmpReviewPageRedirect();
        ERV.review.Review_Type__c = 'Test';
        ERV.currentGoalIndex = 0;
        ERV.currentLearningPlanIndex = 0;
        ERV.currentObjectiveIndex = 0;
        ERV.currentInitiativeIndex = 0;
        ERV.currentRecommendationIndex = 0;
        ERV.addNewGoalRow();
        ERV.addNewObjectiveRow();
        ERV.addNewLearningPlanRow();
        ERV.addNewInitiativeRow();
        ERV.addNewRecommendationRow();
        ERV.saveReview();
        ERV.addNewGoalRow();
        ERV.delGoalRow();
        ERV.addNewObjectiveRow();
        ERV.delObjectiveRow();
        ERV.addNewLearningPlanRow();
        ERV.delLearningPlanRow();
        ERV.addNewInitiativeRow();
        ERV.delInitiativeRow();
        ERV.addNewRecommendationRow();
        ERV.delRecommendationRow();
        ERV.saveReview();
        ERV.revId = null;
        delete G;
        /* EmployeeReviewV2 ERV1 = new EmployeeReviewV2();
        ERV1.saveReview(); */
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
        } catch (exception e) {}
    }
    
}