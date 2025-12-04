public with sharing class EmployeeReviewV2 {

    public Employees__c employee        {get; set;}
    public Review__c review             {get; set;}    
    public List<Review__c> reviewList   {get; set;}  
    public Id revId                     {get; set;}
    public Id empId                     {get; set;}
    public Id mngrId                    {get; set;}
    public boolean isManager            {get; set;}
    public string tb1                   {get; set;}
    public string tb2                   {get; set;}
    public boolean showEmpTable         {get; set;}
    public boolean showMngrTable        {get; set;}
    public String comAppend             {get; set;}
    
    public EmployeeReviewV2(){
        
        comAppend = Community_Util.communityValue();
        if(comAppend == null || comAppend == ''){
            comAppend = '/apex'; } else {comAppend = '/' + comAppend + '/apex';}
            
        isManager = False;
        tb1 = 'False';
        tb2 = 'False';
        showEmpTable = False;
        showMngrTable = False;
        String tempShowEmpTable;
        if(ApexPages.currentPage().getParameters().get('tb1') != null)tempShowEmpTable = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('tb1'),'UTF-8');
        String tempshowMngrTable;
        if(ApexPages.currentPage().getParameters().get('tb2') != null)tempshowMngrTable = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('tb2'),'UTF-8');
        if(tempShowEmpTable == 'true'){showEmpTable = true;showMngrTable = False;      
        }
        if(tempshowMngrTable == 'true'){showMngrTable = true;showEmpTable = False;       
        }       
        submittedForApproval = 'False';
        manageReviewApproval = False;
        manageReviewRejection = False;
        saveAndStay = False;
        saveAndReturn = False;
        Id userId;
        userId = UserInfo.getUserId();        
        Id loggedUser;
        if(Schema.sObjectType.User.isAccessible())
        loggedUser = [Select Id, Name, username from User where Id =: userId limit 1].id;
        
        empId = ApexPages.currentPage().getParameters().get('emp');
        if(empId == null){
            List<Employees__c> empTempList;
            if(Schema.sObjectType.Employees__c.isAccessible())
            empTempList = [Select Id, Name, Employee_User__c from Employees__c where Employee_User__c =: loggedUser limit 1]; 
                if(empTempList.size()>0){
                    empId = empTempList[0].Id;
                }           
        }
        
        if(empId != null){
            List<Employees__c> isEmpManagerList = new List<Employees__c>();
            if(Schema.sObjectType.Employees__c.isAccessible())
            isEmpManagerList = [Select Id, Name, ReportingManager__c from Employees__c 
                                                where ReportingManager__c =: empId limit 10000];
            if(isEmpManagerList.size() > 0){
                isManager = true;
                mngrId = empId;
            }
            reviewList = new List<Review__c>();
            if(Schema.sObjectType.Review__c.isAccessible())
            reviewList = [Select Name, Id, Target_Completion_Date__c, Status__c, Start_Date__c, Signed_Off__c, Review_Type__c, 
                                                        Review_Overall_Score__c, ReviewManager__c, Over_All_Objectives_Achieved__c, Organisation__c, 
                                                        Organisation_Business_Unit__c, Last_Review__c, Is_Locked__c, Employees__c, Date_Submitted_to_Manager__c, 
                                                        Date_Signed_Off__c, Active__c, Employees__r.Organisation__c, Employees__r.Organisation_Business_Unit__c,
                                                        ReviewManager__r.Employee_User__r.Name, Organisation_Business_Unit__r.Id, Organisation__r.Id, LastModifiedDate,
                                                        ReviewManager__r.First_Name__c, ReviewManager__r.Last_Name__c, Employees__r.Employee_User__r.ManagerId, Employees__r.Employee_User__r.Manager.Name,
                                                        of_Over_All_Goals_Achieved__c 
                                                   From Review__c 
                                                   where Employees__c =: empId ORDER BY Start_Date__c asc limit 10000];
                                        
        } 
      
        if(Schema.sObjectType.Employees__c.isAccessible()) 
        employee = (empId == null)? new Employees__c():[Select Name, Id, Work_Status__c,  Social_Security_Number__c, Channel__c, ReportingManager__c, 
                                                            Organisation__c, Organisation_Business_Unit__c, Non_Employee__c, Marital_Status__c, Address__c, 
                                                            Last_Name__c, Job_Title__c, Gender__c, Former_Employee__c, Former_Employee_Record__c, 
                                                            First_Working_Day__c, First_Name__c, Employment_Status__c, Employment_Start_Date__c, Employment_End_Date__c, 
                                                            Employee_User__c, Employee_Profiling__c, Email__c, Description__c, Date_Of_Birth__c, Contract_Offer_Issue_Date__c, 
                                                            Commission_Plan__c,  Active__c, Employee_Profiling__r.Id, Organisation__r.Id, Organisation__r.Name,
                                                            Organisation_Business_Unit__r.Name, Employee_User__r.Id, 
                                                            ReportingManager__r.Name, ReportingManager__r.First_Name__c, ReportingManager__r.Last_Name__c,
                                                            Employee_User__r.ManagerId, Employee_User__r.Manager.Name
                                                        From Employees__c 
                                                        where Id =: empId limit 1];
                                                       
        if(ApexPages.currentPage().getParameters().get('rev') != null)revId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('rev'),'UTF-8');
         if(Schema.sObjectType.Review__c.isAccessible())
        review = (revId == null)? new Review__c():[Select Name, Id, Target_Completion_Date__c, Status__c, Start_Date__c, Signed_Off__c, Review_Type__c, Review_Overall_Score__c, ReviewManager__c, Over_All_Objectives_Achieved__c, Organisation__c, Organisation_Business_Unit__c, Last_Review__c, Is_Locked__c, Employees__c, Date_Submitted_to_Manager__c, Date_Signed_Off__c, Active__c, Employees__r.Organisation__c, Employees__r.Organisation_Business_Unit__c, ReviewManager__r.Employee_User__r.Name, Organisation_Business_Unit__r.Id, Organisation__r.Id, ReviewManager__r.First_Name__c, ReviewManager__r.Last_Name__c, Employees__r.Employee_User__r.ManagerId, Employees__r.Employee_User__r.Manager.Name, of_Over_All_Goals_Achieved__c From Review__c where Id=:revId limit 1];

        if(ApexPages.currentPage().getParameters().get('mngr') != null)mngrId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('mngr'),'UTF-8');
        if(mngrId != null ){
                
        }
        
        /* For Live system enable below line and disable above set of code */ 
        EmployeeReviewWrapperList = new List<EmployeeReviewWrapper>();
        GoalObjectiveWrapperList = new List<GoalObjectiveWrapper>();
        GoalToDeleteList = new List<Goal__c>();
        ObjectiveToDeleteList = new List<Objective__c>();
        EmpOrgGoalObjectiveWrapperList = new List<EmpOrgGoalObjectiveWrapper>();
        ReviewLearningPlanWrapperList = new List<ReviewLearningPlanWrapper>();
        LearningPlanToDeleteList = new List<Learning_Plan__c>();
	    ReviewInitiativeWrapperList = new List<ReviewInitiativeWrapper>();
        InitiativeToDeleteList = new List<Employee_Initiative__c>();
        ReviewRecommendationWrapperList = new List<ReviewRecommendationWrapper>();
        RecommendationToDeleteList = new List<Employee_Review_Recommendation__c>();     
        OrgGoalObjectiveWrapperList = new List<OrgGoalObjectiveWrapper>();
        Map<Id, Goal__c> myEG = new Map<Id, Goal__c>();
        if(empId != null){          
            
            if(employee.Organisation__c != null){
                OrgGoalList = new List<Organisational_Goal__c>();
                OrgObjectiveList = new List<Organisational_Objective__c>();
                
                if(Schema.sObjectType.Organisational_Goal__c.isAccessible())
                OrgGoalList = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Organisation__r.Id
                                    from Organisational_Goal__c 
                                    where Organisation__c =: employee.Organisation__r.Id];
                if(Schema.sObjectType.Organisational_Objective__c.isAccessible())                   
                OrgObjectiveList = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Organisation__r.Id, Organisational_Goal__c
                                    from Organisational_Objective__c 
                                    where Organisation__c =: employee.Organisation__r.Id];                                  
            }            

            if(OrgGoalList.size() > 0){
                OrgGoalObjectiveList = new List<Organisational_Objective__c>();
                if(Schema.sObjectType.Organisational_Objective__c.isAccessible())
                OrgGoalObjectiveList = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Organisation__r.Id, Organisational_Goal__c
                                    from Organisational_Objective__c 
                                    where Organisation__c =: OrgGoalList[0].Organisation__r.Id];             
                OrgGoalObjectiveMap = new Map<Organisational_Goal__c, List<Organisational_Objective__c>>();

                for(Organisational_Goal__c g : OrgGoalList){
                    List<Organisational_Objective__c> OrgGoalObjectiveList = new List<Organisational_Objective__c>();
                    for(Organisational_Objective__c ob : OrgObjectiveList){
                        if(ob.Organisational_Goal__c == g.Id){
                            OrgGoalObjectiveList.add(ob);
                        }
                    }
                    OrgGoalObjectiveMap.put(g, OrgGoalObjectiveList);
                }
                for(Organisational_Goal__c g : OrgGoalList){
                    List<Organisational_Objective__c> OrgGoalObjectiveList = OrgGoalObjectiveMap.get(g);
                    OrgGoalObjectiveWrapper goWrap = new OrgGoalObjectiveWrapper();
                    goWrap.wrapOrgGoal = g;
                    goWrap.wrapOrgGoalObjectiveList = OrgGoalObjectiveList;
                    
                    OrgGoalObjectiveWrapperList.add(goWrap);
                }
            }
            EmployeeList = new List<Employees__c>();
            if(Schema.sObjectType.Employees__c.isAccessible())
            EmployeeList = [Select Name, Id, Work_Status__c,  Social_Security_Number__c, Channel__c, ReportingManager__c, 
                                    Organisation__c, Organisation_Business_Unit__c, Non_Employee__c, Marital_Status__c, Address__c, 
                                    Last_Name__c, Job_Title__c, Gender__c, Former_Employee__c, Former_Employee_Record__c, 
                                    First_Working_Day__c, First_Name__c, Employment_Status__c, Employment_Start_Date__c, Employment_End_Date__c, 
                                    Employee_User__c, Employee_Profiling__c, Email__c, Description__c, Date_Of_Birth__c, Contract_Offer_Issue_Date__c, 
                                    Commission_Plan__c, Active__c, Employee_Profiling__r.Id, Organisation__r.Id, Organisation__r.Name,
                                    Organisation_Business_Unit__r.Name, ReportingManager__r.Name, ReportingManager__r.First_Name__c, ReportingManager__r.Last_Name__c,
                                    Employee_User__r.ManagerId, Employee_User__r.Manager.Name
                                From Employees__c 
                                where ReportingManager__c =: empId];        
            if(EmployeeList.size() > 0){
                empReviewList = new List<Review__c>();
                if(Schema.sObjectType.Review__c.isAccessible())
                empReviewList = [Select Name, Id, Target_Completion_Date__c, Status__c, Start_Date__c, Signed_Off__c, Review_Type__c, 
                                        Review_Overall_Score__c, ReviewManager__c, Over_All_Objectives_Achieved__c, Organisation__c, 
                                        Organisation_Business_Unit__c, Last_Review__c, Is_Locked__c, Employees__c, Date_Submitted_to_Manager__c, 
                                        Date_Signed_Off__c, Active__c, Employees__r.Organisation__c, Employees__r.Organisation_Business_Unit__c,
                                        ReviewManager__r.Employee_User__r.Name, Organisation_Business_Unit__r.Id, Organisation__r.Id, LastModifiedDate,
                                        ReviewManager__r.First_Name__c, ReviewManager__r.Last_Name__c, Employees__r.Employee_User__r.ManagerId, Employees__r.Employee_User__r.Manager.Name,
                                        of_Over_All_Goals_Achieved__c 
                                    From Review__c 
                                    where Employees__r.ReportingManager__c =: empId 
                                    and Status__c = 'Submitted To Manager' ORDER BY Start_Date__c asc];    
                EmployeeReviewMap = new Map<Employees__c, List<Review__c>>();
   				for(Employees__c e : EmployeeList){
                    List<Review__c> EmployeeReviewList = new List<Review__c>();
                    for(Review__c r : empReviewList){if(r.Employees__c == e.Id){EmployeeReviewList.add(r);}}
                    EmployeeReviewMap.put(e, EmployeeReviewList);
                }
                for(Employees__c e : EmployeeList){
                    List<Review__c> EmployeeReviewList = EmployeeReviewMap.get(e);
                    EmployeeReviewWrapper goWrap = new EmployeeReviewWrapper();
                    goWrap.wrapEmployee = e;
                    goWrap.wrapEmpReviewList = EmployeeReviewList;
                    EmployeeReviewWrapperList.add(goWrap);
                }
            }               
				if(revId == null){              
                GoalList = new List<Goal__c>();
                if(Schema.sObjectType.Goal__c.isAccessible())
                GoalList = [Select Name, Id, Employee_Organisation_Goal__c, Outcome__c, Organisation__c, Organisation_Business_Unit__c, Of_Over_All_Objectives__c, Objective_Number__c, 
                            Review__c, Review__r.Employees__r.Organisation__c, Review__r.Employees__r.Organisation_Business_Unit__c,     
                            Objective_Comment__c, Employees__c, Employee_Manager__c, DueDate__c, Active__c, Employee_Manager__r.Name, Employee_Organisational_Goal__c
                            From Goal__c 
                            where Employees__c =: empId 
                            and Employee_Organisation_Goal__c = true];        
                List<Objective__c> GoalObjectiveList;
                if(GoalList.size() > 0){
                    ObjectiveList = new List<Objective__c>();
                     if(Schema.sObjectType.Objective__c.isAccessible())
                    ObjectiveList = [Select Name, Id, Task_Comment__c, Score__c, Percentage_Complete__c, Organisation__c, Organisation_Business_Unit__c, 
                                        Objective_Task__c, Employees__c, Employee_Review__c, Employee_Manager__c, Employee_Goal__c, DueDate__c, Active__c, 
                                        Employee_Goal__r.Review__c, Employee_Goal__r.Review__r.Employees__r.Organisation_Business_Unit__c, Employee_Manager__r.Name, 
                                        Employee_Goal__r.Review__r.Employees__r.Organisation__c, Employee_Goal__r.Organisation_Business_Unit__c, Employee_Goal__r.Organisation__c
                                     From Objective__c 
                                     where Employee_Goal__r.Employees__c =: empId
                                     and Employee_Goal__r.Employee_Organisation_Goal__c = true];    
                    GoalObjectiveMap = new Map<Goal__c, List<Objective__c>>();
					for(Goal__c g : GoalList){
                        GoalObjectiveList = new List<Objective__c>();
                        for(Objective__c ob : ObjectiveList){
                            if(ob.Employee_Goal__c == g.Id){
                                GoalObjectiveList.add(ob);
                            }
                        }
                        GoalObjectiveMap.put(g, GoalObjectiveList);
                        if(Schema.sobjectType.Goal__c.fields.Employee_Organisational_Goal__c.isAccessible()) if(g.Employee_Organisational_Goal__c != Null) myEG.put(g.Employee_Organisational_Goal__c, g);
                    }       
                }           
              if(employee.Employee_Profiling__c != null){
                    EmpOrgGoalList = new List<Employee_Organisational_Goal__c>();
                    EmpOrgObjectiveList = new List<Employee_Organisational_Objective__c>();
                    if(Schema.sObjectType.Employee_Organisational_Goal__c.isAccessible())
                    EmpOrgGoalList = [Select Id, Name, Active__c, Employee_Profiling__c, Organisation__c, Organisational_Goal__c, Organisation_Business_Unit__c, Required__c
                                            , Employee_Profiling__r.Id, Employee_Profiling__r.Name, Organisational_Goal__r.Name
                                        from Employee_Organisational_Goal__c 
                                        where Employee_Profiling__c =: employee.Employee_Profiling__r.Id];
                    if(Schema.sObjectType.Employee_Organisational_Objective__c.isAccessible())                    
                    EmpOrgObjectiveList = [Select Id, Name, Active__c, Employee_Profiling__c, Organisation__c, Employee_Organisational_Goal__c, Organisation_Business_Unit__c, Required__c
                                        from Employee_Organisational_Objective__c 
                                        where Employee_Profiling__c =: employee.Employee_Profiling__r.Id];                                  
                }                   
                if(EmpOrgGoalList.size() > 0){
                   EmpOrgGoalObjectiveList = new List<Employee_Organisational_Objective__c>();
                    if(Schema.sObjectType.Employee_Organisational_Objective__c.isAccessible())
                    EmpOrgGoalObjectiveList = [Select Id, Name, Active__c, Employee_Profiling__c, Organisation__c, Employee_Organisational_Goal__c, Organisation_Business_Unit__c, Required__c
                                        from Employee_Organisational_Objective__c 
                                        where Employee_Profiling__c =: EmpOrgGoalList[0].Employee_Profiling__r.Id];             
                    EmpOrgGoalObjectiveMap = new Map<Employee_Organisational_Goal__c, List<Employee_Organisational_Objective__c>>();
				    for(Employee_Organisational_Goal__c g : EmpOrgGoalList){
                        List<Employee_Organisational_Objective__c> EmpOrgGoalObjectiveList = new List<Employee_Organisational_Objective__c>();
                        for(Employee_Organisational_Objective__c ob : EmpOrgObjectiveList){
                            if(ob.Employee_Organisational_Goal__c == g.Id){
                                EmpOrgGoalObjectiveList.add(ob);
                            }
                        }
                        EmpOrgGoalObjectiveMap.put(g, EmpOrgGoalObjectiveList);
                    }               
                  List<Employee_Organisational_Objective__c> empOrgObjList;
                        List<Objective__c> empObjListTemp = new List<Objective__c>();
                        List<Objective__c> empObjListTemp2 = new List<Objective__c>();                  
                    for(Employee_Organisational_Goal__c g : EmpOrgGoalList){
                        Goal__c empGoal;
                        List<Objective__c> empObjList;
                        empOrgObjList = new List<Employee_Organisational_Objective__c>();
                        empOrgObjList = EmpOrgGoalObjectiveMap.get(g);
                        if(GoalList.size() > 0){
                            for(Goal__c goal : GoalList){
                                if(goal.Employee_Organisational_Goal__c == g.Id && goal.Employee_Organisation_Goal__c == true && goal.Outcome__c != 'Achieved'){empObjList = new List<Objective__c>();empObjList = GoalObjectiveMap.get(goal);empObjListTemp = GoalObjectiveMap.get(goal);empObjListTemp2 = GoalObjectiveMap.get(goal); if(empOrgObjList.size() > empObjList.size()){List<Objective__c> empObjListAlt = new List<Objective__c>(); for(Employee_Organisational_Objective__c o : empOrgObjList){boolean add = true; for(Objective__c ot : empObjList){ if(o.Name == ot.Name){add = false;}}if(add){Objective__c eoO= new Objective__c(Organisation__c = review.Organisation__c, Organisation_Business_Unit__c = review.Organisation_Business_Unit__c, Name = o.Name, Employee_Manager__c = review.ReviewManager__c);  empObjListAlt.add(eoO);}} for(Objective__c oAlt : empObjListAlt){empObjList.add(oAlt);} }GoalObjectiveWrapper empGoalObjWrap = new GoalObjectiveWrapper();empGoalObjWrap.wrapGoal = goal;empGoalObjWrap.wrapObjectiveList = empObjList;GoalObjectiveWrapperList.add(empGoalObjWrap);                                                               
                                }
                                else if(goal.Employee_Organisational_Goal__c != g.Id && goal.Employee_Organisation_Goal__c == true && ! myEG.containskey(g.Id)){ 
                                    Goal__c eoG = new Goal__c(Organisation__c = review.Organisation__c, 
                                                                Organisation_Business_Unit__c = review.Organisation_Business_Unit__c,
                                                                Name = g.Name,
                                                                Employee_Manager__c = review.ReviewManager__c,
                                                                Employee_Organisation_Goal__c = true,
                                                                Employee_Organisational_Goal__c = g.Id);
								    empObjList = new List<Objective__c>();
                                    for(Employee_Organisational_Objective__c o : empOrgObjList){
                                        if(o.Name != null){
                                            Objective__c eoO= new Objective__c(Organisation__c = review.Organisation__c,
                                                                                        Organisation_Business_Unit__c = review.Organisation_Business_Unit__c,
                                                                                        Name = o.Name,
                                                                                        Employee_Manager__c = review.ReviewManager__c
                                                                                        );                                  
                                            empObjList.add(eoO);
                                        }
                                    }                               
                                    GoalObjectiveWrapper empGoalObjWrap = new GoalObjectiveWrapper();
                                    empGoalObjWrap.wrapGoal = eoG;
                                    empGoalObjWrap.wrapObjectiveList = empObjList;                                    
                                    GoalObjectiveWrapperList.add(empGoalObjWrap); 

                                    if(Schema.sobjectType.Goal__c.fields.Employee_Organisational_Goal__c.isAccessible()) if(empGoalObjWrap.wrapGoal.Employee_Organisational_Goal__c != Null) myEG.put(empGoalObjWrap.wrapGoal.Employee_Organisational_Goal__c, empGoalObjWrap.wrapGoal); 
                                }                               
                                
                                
                            }
                        }

                        if(GoalList.size() == 0){if(g.Name != null ){   Goal__c eoG = new Goal__c(Organisation__c = review.Organisation__c, Organisation_Business_Unit__c = review.Organisation_Business_Unit__c, Name = g.Name, Employee_Manager__c = review.ReviewManager__c, Employee_Organisation_Goal__c = true, Employee_Organisational_Goal__c = g.Id);empOrgObjList = new List<Employee_Organisational_Objective__c>();empOrgObjList = EmpOrgGoalObjectiveMap.get(g);empObjList = new List<Objective__c>();for(Employee_Organisational_Objective__c o : empOrgObjList){if(o.Name != null){Objective__c eoO= new Objective__c(Organisation__c = review.Organisation__c, Organisation_Business_Unit__c = review.Organisation_Business_Unit__c, Name = o.Name, Employee_Manager__c = review.ReviewManager__c);    empObjList.add(eoO);  }}   GoalObjectiveWrapper empGoalObjWrap = new GoalObjectiveWrapper();empGoalObjWrap.wrapGoal = eoG;empGoalObjWrap.wrapObjectiveList = empObjList;GoalObjectiveWrapperList.add(empGoalObjWrap);                                                               
                            }
                        }
                        
                    }
                }
            }       
                
            if(revId != null){LearningPlanList = new List<Learning_Plan__c>();if(Schema.sObjectType.Learning_Plan__c.isAccessible())LearningPlanList = [Select Id, Name, Active__c, Course__c, Organisation__c, Organisation_Business_Unit__c, Review__c, Review__r.Employees__r.Organisation__c, Review__r.Employees__r.Organisation_Business_Unit__c from Learning_Plan__c where Review__c =: revId];for(Learning_Plan__c lp : LearningPlanList){ ReviewLearningPlanWrapper lpWrap = new ReviewLearningPlanWrapper();lpWrap.wrapLearningPlan = lp;ReviewLearningPlanWrapperList.add(lpWrap);}InitiativeList = new List<Employee_Initiative__c>(); if(Schema.sObjectType.Employee_Initiative__c.isAccessible()) InitiativeList = [Select Id, Name, Active__c, Employees__c, Organisation__c, Organisation_Business_Unit__c, Employee_Review__c, Initiative_Notes__c, Employee_Review__r.Employees__r.Organisation__c, Employee_Review__r.Employees__r.Organisation_Business_Unit__c, Objective__c, Objective__r.Name, Project__c, Project__r.Name, Status__c from Employee_Initiative__c where Employee_Review__c =: revId]; for(Employee_Initiative__c i : InitiativeList){ReviewInitiativeWrapper iWrap = new ReviewInitiativeWrapper();iWrap.wrapInitiative = i;ReviewInitiativeWrapperList.add(iWrap);} RecommendationList = new List<Employee_Review_Recommendation__c>();if(Schema.sObjectType.Employee_Review_Recommendation__c.isAccessible()) RecommendationList = [Select Id, Name, Active__c, Employees__c, Organisation__c, Organisation_Business_Unit__c, Employee_Review__c, Employee_Review__r.Employees__r.Organisation__c, Employee_Review__r.Employees__r.Organisation_Business_Unit__c, Status__c from Employee_Review_Recommendation__c where Employee_Review__c =: revId];for(Employee_Review_Recommendation__c r : RecommendationList){ReviewRecommendationWrapper rWrap = new ReviewRecommendationWrapper();  rWrap.wrapRecommendation = r;ReviewRecommendationWrapperList.add(rWrap);}           
            }
        }        
    }

    public PageReference loadEmpOrgGoalObjective(){
        Map<Id, Goal__c> myEG = new Map<Id, Goal__c>();
        if(empId != null){
                eOGoalList = new List<Goal__c>();
                if(Schema.sObjectType.Goal__c.isAccessible())
                eOGoalList = [Select Name, Id, Outcome__c, Organisation__c, Organisation_Business_Unit__c, Of_Over_All_Objectives__c, Objective_Number__c, 
                              Review__c, Review__r.Employees__r.Organisation__c, Review__r.Employees__r.Organisation_Business_Unit__c, 
                              Objective_Comment__c, Employees__c, Employee_Manager__c, DueDate__c, Active__c, Employee_Organisation_Goal__c, Employee_Manager__r.Name, Employee_Organisational_Goal__c 
                            From Goal__c 
                             where Employees__c =: empId
                             and Employee_Organisation_Goal__c = true];                             
                if(eOGoalList.size() > 0){
                    eOObjectiveList = new List<Objective__c>();
                     if(Schema.sObjectType.Objective__c.isAccessible())
                    eOObjectiveList = [Select Name, Id, Task_Comment__c, Score__c, Percentage_Complete__c, Organisation__c, Organisation_Business_Unit__c, 
                                        Objective_Task__c, Employees__c, Employee_Review__c, Employee_Manager__c, Employee_Goal__c, DueDate__c, Active__c, 
                                        Employee_Goal__r.Review__c, Employee_Goal__r.Review__r.Employees__r.Organisation_Business_Unit__c, Employee_Manager__r.Name,
                                        Employee_Goal__r.Review__r.Employees__r.Organisation__c, Employee_Goal__r.Organisation_Business_Unit__c, Employee_Goal__r.Organisation__c
                                     From Objective__c 
                                     where Employee_Goal__r.Employees__c =: empId
                                     and Employee_Goal__r.Employee_Organisation_Goal__c = true];                                     
                    eOGoalObjectiveMap = new Map<Goal__c, List<Objective__c>>();
                    List<Objective__c> eOGoalObjectiveList;
                    for(Goal__c g : eOGoalList){
                        eOGoalObjectiveList = new List<Objective__c>();
                        for(Objective__c ob : eOObjectiveList){
                            if(ob.Employee_Goal__c == g.Id){
                                eOGoalObjectiveList.add(ob);
                            }
                        }
                        eOGoalObjectiveMap.put(g, eOGoalObjectiveList);
                        if(Schema.sobjectType.Goal__c.fields.Employee_Organisational_Goal__c.isAccessible()) if(g.Employee_Organisational_Goal__c != Null) myEG.put(g.Employee_Organisational_Goal__c, g);
                    }           
                }
               if(revId != null){
                    GoalList = new List<Goal__c>();
                    if(Schema.sObjectType.Goal__c.isAccessible())
                    GoalList = [Select Name, Id, Outcome__c, Organisation__c, Organisation_Business_Unit__c, Of_Over_All_Objectives__c, Objective_Number__c, 
                                Review__c, Review__r.Employees__r.Organisation__c, Review__r.Employees__r.Organisation_Business_Unit__c, 
                                Objective_Comment__c, Employees__c, Employee_Manager__c, DueDate__c, Active__c, Employee_Organisation_Goal__c, Employee_Manager__r.Name, Employee_Organisational_Goal__c 
                                From Goal__c 
                                where Review__c =: revId
                                and Employee_Organisation_Goal__c = false];        
                    if(GoalList.size() > 0){ObjectiveList = new List<Objective__c>();if(Schema.sObjectType.Objective__c.isAccessible())ObjectiveList = [Select Name, Id, Task_Comment__c, Score__c, Percentage_Complete__c, Organisation__c, Organisation_Business_Unit__c, Objective_Task__c, Employees__c, Employee_Review__c, Employee_Manager__c, Employee_Goal__c, DueDate__c, Active__c, Employee_Goal__r.Review__c, Employee_Goal__r.Review__r.Employees__r.Organisation_Business_Unit__c, Employee_Manager__r.Name, Employee_Goal__r.Review__r.Employees__r.Organisation__c, Employee_Goal__r.Organisation_Business_Unit__c, Employee_Goal__r.Organisation__c From Objective__c where Employee_Goal__r.Review__c =: revId and Employee_Goal__r.Employee_Organisation_Goal__c = false];    GoalObjectiveMap = new Map<Goal__c, List<Objective__c>>(); List<Objective__c> GoalObjectiveList;for(Goal__c g : GoalList){GoalObjectiveList = new List<Objective__c>();for(Objective__c ob : ObjectiveList){if(ob.Employee_Goal__c == g.Id){GoalObjectiveList.add(ob);}}GoalObjectiveMap.put(g, GoalObjectiveList);
                        }
                    }
                }
                if(employee.Employee_Profiling__c != null){
                    EmpOrgGoalList = new List<Employee_Organisational_Goal__c>();
                    EmpOrgObjectiveList = new List<Employee_Organisational_Objective__c>();
                     if(Schema.sObjectType.Employee_Organisational_Goal__c.isAccessible())
                    EmpOrgGoalList = [Select Id, Name, Active__c, Employee_Profiling__c, Organisation__c, Organisational_Goal__c, Organisation_Business_Unit__c, Required__c
                                            , Employee_Profiling__r.Id, Employee_Profiling__r.Name, Organisational_Goal__r.Name
                                        from Employee_Organisational_Goal__c 
                                        where Employee_Profiling__c =: employee.Employee_Profiling__r.Id];
                    if(Schema.sObjectType.Employee_Organisational_Objective__c.isAccessible())               
                    EmpOrgObjectiveList = [Select Id, Name, Active__c, Employee_Profiling__c, Organisation__c, Employee_Organisational_Goal__c, Organisation_Business_Unit__c, Required__c
                                        from Employee_Organisational_Objective__c 
                                        where Employee_Profiling__c =: employee.Employee_Profiling__r.Id];                                  
                }                   
                if(EmpOrgGoalList.size() > 0){
                    EmpOrgGoalObjectiveList = new List<Employee_Organisational_Objective__c>();
                    if(Schema.sObjectType.Employee_Organisational_Objective__c.isAccessible())    
                    EmpOrgGoalObjectiveList = [Select Id, Name, Active__c, Employee_Profiling__c, Organisation__c, Employee_Organisational_Goal__c, Organisation_Business_Unit__c, Required__c
                                        from Employee_Organisational_Objective__c 
                                        where Employee_Profiling__c =: EmpOrgGoalList[0].Employee_Profiling__r.Id];             
                    EmpOrgGoalObjectiveMap = new Map<Employee_Organisational_Goal__c, List<Employee_Organisational_Objective__c>>();
                    for(Employee_Organisational_Goal__c g : EmpOrgGoalList){
                        List<Employee_Organisational_Objective__c> EmpOrgGoalObjectiveList = new List<Employee_Organisational_Objective__c>();
                        for(Employee_Organisational_Objective__c ob : EmpOrgObjectiveList){
                            if(ob.Employee_Organisational_Goal__c == g.Id){
                                EmpOrgGoalObjectiveList.add(ob);
                            }
                        }
                        EmpOrgGoalObjectiveMap.put(g, EmpOrgGoalObjectiveList);
                    }               
                    if(revId != null){
                        for(Employee_Organisational_Goal__c g : EmpOrgGoalList){
                            Goal__c empGoal;
                            List<Objective__c> empObjList;
                            List<Employee_Organisational_Objective__c> empOrgObjList;                           
                            empOrgObjList = new List<Employee_Organisational_Objective__c>();
                            empOrgObjList = EmpOrgGoalObjectiveMap.get(g);                            
                            if(eOGoalList.size() > 0){  
                                for(Goal__c goal : eOGoalList){
                                    if(goal.Employee_Organisational_Goal__c == g.Id && goal.Employee_Organisation_Goal__c == true && goal.Outcome__c != 'Achieved'){empObjList = new List<Objective__c>();empObjList = eOGoalObjectiveMap.get(goal);if(empOrgObjList.size() > empObjList.size()){List<Objective__c> empObjListAlt = new List<Objective__c>(); for(Employee_Organisational_Objective__c o : empOrgObjList){boolean add = true;  for(Objective__c ot : empObjList){ if(o.Name == ot.Name){add = false;}}if(add){Objective__c eoO= new Objective__c(Organisation__c = review.Organisation__c, Organisation_Business_Unit__c = review.Organisation_Business_Unit__c, Name = o.Name, Employee_Manager__c = review.ReviewManager__c); empObjListAlt.add(eoO);}} for(Objective__c oAlt : empObjListAlt){ empObjList.add(oAlt);}}  GoalObjectiveWrapper empGoalObjWrap = new GoalObjectiveWrapper();empGoalObjWrap.wrapGoal = goal;empGoalObjWrap.wrapObjectiveList = empObjList;GoalObjectiveWrapperList.add(empGoalObjWrap);                                       
                                    }
                                    else if(goal.Employee_Organisational_Goal__c != g.Id && goal.Employee_Organisation_Goal__c == true && ! myEG.containskey(g.Id)){                             
                                        Goal__c eoG = new Goal__c(Organisation__c = review.Organisation__c, 
                                                                    Organisation_Business_Unit__c = review.Organisation_Business_Unit__c,
                                                                    Name = g.Name,
                                                                    Employee_Manager__c = review.ReviewManager__c,
                                                                    Employee_Organisation_Goal__c = true,
                                                                    Employee_Organisational_Goal__c = g.Id);
                                        empObjList = new List<Objective__c>();
                                        for(Employee_Organisational_Objective__c o : empOrgObjList){
                                            if(o.Name != null){
                                                Objective__c eoO= new Objective__c(Organisation__c = review.Organisation__c,
                                                                                            Organisation_Business_Unit__c = review.Organisation_Business_Unit__c,
                                                                                            Name = o.Name,
                                                                                            Employee_Manager__c = review.ReviewManager__c
                                                                                            );                                  
                                                empObjList.add(eoO);
                                            }
                                        }                               
                                        GoalObjectiveWrapper empGoalObjWrap = new GoalObjectiveWrapper();
                                        empGoalObjWrap.wrapGoal = eoG;
                                        empGoalObjWrap.wrapObjectiveList = empObjList;
                                        GoalObjectiveWrapperList.add(empGoalObjWrap); 
                                        if(Schema.sobjectType.Goal__c.fields.Employee_Organisational_Goal__c.isAccessible()) if(empGoalObjWrap.wrapGoal.Employee_Organisational_Goal__c != Null) myEG.put(empGoalObjWrap.wrapGoal.Employee_Organisational_Goal__c, empGoalObjWrap.wrapGoal);                                     
                                    }    
                                }
                            }
                        }
                    }
                }
                Goal__c empGoal;
                List<Objective__c> empObjList;                              
                if(revId != null && GoalList.size() > 0){   for(Goal__c goal : GoalList){if(goal.Employee_Organisation_Goal__c != true){empObjList = new List<Objective__c>();empObjList = GoalObjectiveMap.get(goal);  GoalObjectiveWrapper empGoalObjWrap = new GoalObjectiveWrapper(); empGoalObjWrap.wrapGoal = goal;empGoalObjWrap.wrapObjectiveList = empObjList; GoalObjectiveWrapperList.add(empGoalObjWrap);                                                                                                                               
                        }
                    }               
                }
        }
        return null;
    }   
    public PageReference saveReview(){                       
        	review.Organisation__c = employee.Organisation__r.Id;
            review.Organisation_Business_Unit__c = employee.Organisation_Business_Unit__r.Id;
            if(Schema.sobjectType.Employees__c.fields.ReportingManager__c.isAccessible())review.ReviewManager__c = employee.ReportingManager__c;
            if(review.Employees__c == null){review.Employees__c = employee.Id;
            }
            if(review.Name == null){review.Name.addError('Please Enter Review Name');return null;
            }
            if(review.Review_Type__c == null){review.Review_Type__c.addError('Please Enter Review Type');return null;}           
            if(review.Start_Date__c == null){review.Start_Date__c.addError('Please Enter Start Date');return null;}   
            if(review.Target_Completion_Date__c == null){review.Target_Completion_Date__c.addError('Please Enter Target End Date');return null;}
			Id managerId;
            if(employee != null && employee.Employee_User__c != null){      
                if(Schema.sObjectType.User.isAccessible())managerId = [Select Id, Name, ManagerId from User where Id =: employee.Employee_User__c limit 1].ManagerId; 
            }  
            if(review.Status__c == null){review.Status__c = 'Created';}
        if(Schema.sObjectType.Review__c.isCreateable() && Schema.sObjectType.Review__c.isUpdateable()) DMLManager.upsertAsUser(review); else{ }
            if(ObjectiveToDeleteList.size() > 0 && Schema.sObjectType.Objective__c.isDeletable()){DMLManager.deleteAsUser(ObjectiveToDeleteList);ObjectiveToDeleteList = new List<Objective__c>();}
            if(GoalToDeleteList.size() > 0 && Schema.sObjectType.Goal__c.isDeletable()){DMLManager.deleteAsUser(GoalToDeleteList);GoalToDeleteList = new List<Goal__c>();}                        
            if(LearningPlanToDeleteList.size() > 0 && Schema.sObjectType.Learning_Plan__c.isDeletable()){DMLManager.deleteAsUser(LearningPlanToDeleteList);LearningPlanToDeleteList = new List<Learning_Plan__c>();
            }                                   
            if(InitiativeToDeleteList.size() > 0 && Schema.sObjectType.Employee_Initiative__c.isDeletable()){DMLManager.deleteAsUser(InitiativeToDeleteList);InitiativeToDeleteList = new List<Employee_Initiative__c>();}                   
            if(RecommendationToDeleteList.size() > 0 && Schema.sObjectType.Employee_Review_Recommendation__c.isDeletable()){DMLManager.deleteAsUser(RecommendationToDeleteList);RecommendationToDeleteList = new List<Employee_Review_Recommendation__c>();}
            if(GoalObjectiveWrapperList.size() > 0){
                for(GoalObjectiveWrapper gow : GoalObjectiveWrapperList){
                        if(gow.wrapGoal.Employees__c == null){
                            gow.wrapGoal.Employees__c = employee.Id; 
                        }
                        if(gow.wrapGoal.Name == null){gow.wrapGoal.Name.addError('Please Enter Goal Name');return null;}                       
                        if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())gow.wrapGoal.Organisation__c = review.Organisation__c;                
                        if(Schema.sobjectType.Review__c.fields.Organisation_Business_Unit__c.isAccessible())gow.wrapGoal.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;
                        if(Schema.sobjectType.Employees__c.fields.ReportingManager__c.isAccessible())gow.wrapGoal.Employees__c = employee.ReportingManager__c;
                        if(review.Id != null){
                            
                            if(gow.wrapGoal.Review__c == null){
                                if(Schema.sobjectType.Review__c.isAccessible())gow.wrapGoal.Review__c = review.Id;
                            }
                        }
                        if(gow.wrapGoal.Of_Over_All_Objectives__c > 100){ gow.wrapGoal.Of_Over_All_Objectives__c.addError('Invalid percent value');   
                        }
                    if(Schema.sObjectType.Goal__c.isCreateable() && Schema.sObjectType.Goal__c.isUpdateable())  DMLManager.upsertasUser(gow.wrapGoal); else{ }                                  
                    for(Objective__c ot : gow.wrapObjectiveList){
                        if(review.Id != null){                           
                            if(ot.Employee_Review__c == null){
                                ot.Employee_Review__c = review.Id;
                            }
                            if(ot.Employee_Goal__c == null){
                                ot.Employee_Goal__c = gow.wrapGoal.Id;
                            }
                            if(ot.Name == null){
                                ot.Name.addError('Please Enter Objective Name');
                                return null;
                            }                               
                            if(ot.Employees__c == null){                            
                                ot.Employees__c = employee.Id;    
                            }
                            if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())ot.Organisation__c = review.Organisation__c;                
                            if(Schema.sobjectType.Review__c.fields.Organisation_Business_Unit__c.isAccessible())ot.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;
                            if(Schema.sobjectType.Employees__c.fields.ReportingManager__c.isAccessible())ot.Employee_Manager__c = employee.ReportingManager__c;
                        }
                        
                        if(ot.Percentage_Complete__c > 100){ot.Percentage_Complete__c.addError('Invalid percent value');    
                        }                       
                    }
                    if(Schema.sObjectType.Objective__c.isCreateable() && Schema.sObjectType.Objective__c.isUpdateable()) DMLManager.upsertAsUser(gow.wrapObjectiveList); else{ }
                }
            }
            if(EmpOrgGoalObjectiveWrapperList.size() > 0){
                for(EmpOrgGoalObjectiveWrapper gow : EmpOrgGoalObjectiveWrapperList){                         
                    if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())gow.wrapEmpOrgGoal.Organisation__c = review.Organisation__c;                
                    if(Schema.sobjectType.Review__c.fields.Organisation_Business_Unit__c.isAccessible())gow.wrapEmpOrgGoal.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;                        
                    for(Employee_Organisational_Objective__c ot : gow.wrapEmpOrgGoalObjectiveList){  if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())ot.Organisation__c = review.Organisation__c;   ot.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;                                                                                                                                        
                    }
                }
            }
            if(OrgGoalObjectiveWrapperList.size() > 0){
                for(OrgGoalObjectiveWrapper gow : OrgGoalObjectiveWrapperList){                         
                    if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())gow.wrapOrgGoal.Organisation__c = review.Organisation__c;                
                    if(Schema.sobjectType.Review__c.fields.Organisation_Business_Unit__c.isAccessible())gow.wrapOrgGoal.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;                        
                    for(Organisational_Objective__c ot : gow.wrapOrgGoalObjectiveList){                                                                                                                                             
                        if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())ot.Organisation__c = review.Organisation__c;                
                        if(Schema.sobjectType.Review__c.fields.Organisation_Business_Unit__c.isAccessible())ot.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;                                                                                                                                        
                    }
                }
            }
            if(ReviewLearningPlanWrapperList.size() > 0){
                for(ReviewLearningPlanWrapper lpw : ReviewLearningPlanWrapperList){
                        if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())lpw.wrapLearningPlan.Organisation__c = review.Organisation__c;                
                        if(Schema.sobjectType.Review__c.fields.Organisation_Business_Unit__c.isAccessible())lpw.wrapLearningPlan.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;
                        if(review.Id != null){
                            if(lpw.wrapLearningPlan.Review__c == null){
                                lpw.wrapLearningPlan.Review__c = review.Id;
                            }
                        }
                        if(lpw.wrapLearningPlan.name == null){lpw.wrapLearningPlan.name.addError('Please Enter Plan Name');return null;
                        }                           
                    if(Schema.sObjectType.Learning_Plan__c.isCreateable() && Schema.sObjectType.Learning_Plan__c.isUpdateable()) DMLManager.upsertAsUser(lpw.wrapLearningPlan); else{ } 
                }
            }
            if(ReviewInitiativeWrapperList.size() > 0){
                for(ReviewInitiativeWrapper iw : ReviewInitiativeWrapperList){
                        if(iw.wrapInitiative.Employees__c == null){
                            iw.wrapInitiative.Employees__c = employee.Id; 
                        }
                        if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())iw.wrapInitiative.Organisation__c = review.Organisation__c;                
                        if(Schema.sobjectType.Review__c.fields.Organisation_Business_Unit__c.isAccessible())iw.wrapInitiative.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;
                        if(review.Id != null){
                            if(iw.wrapInitiative.Employee_Review__c == null){
                                if(Schema.sobjectType.Review__c.isAccessible()) iw.wrapInitiative.Employee_Review__c = review.Id;
                            }
                        }
                        if(iw.wrapInitiative.Name == null){iw.wrapInitiative.Name.addError('Please Enter Initiative Name');return null;
                        }                               
                    if(Schema.sObjectType.Employee_Initiative__c.isCreateable() && Schema.sObjectType.Employee_Initiative__c.isUpdateable()) DMLManager.upsertAsUser(iw.wrapInitiative);    else{ }
                }
            }           

            if(ReviewRecommendationWrapperList.size() > 0){
                for(ReviewRecommendationWrapper rw : ReviewRecommendationWrapperList){
                        if(rw.wrapRecommendation.Employees__c == null){
                            rw.wrapRecommendation.Employees__c = employee.Id; 
                        }
                        if(Schema.sobjectType.Review__c.fields.Organisation__c.isAccessible())rw.wrapRecommendation.Organisation__c = review.Organisation__c;                
                        if(Schema.sobjectType.Review__c.fields.Organisation_Business_Unit__c.isAccessible())rw.wrapRecommendation.Organisation_Business_Unit__c = review.Organisation_Business_Unit__c;
                        if(review.Id != null){
                            if(rw.wrapRecommendation.Employee_Review__c == null){
                                if(Schema.sobjectType.Review__c.isAccessible()) rw.wrapRecommendation.Employee_Review__c = review.Id;
                            }
                        }
                        if(rw.wrapRecommendation.Name == null){rw.wrapRecommendation.Name.addError('Please Enter Recommendation Name');return null;
                        }                               
                    if(Schema.sObjectType.Employee_Review_Recommendation__c.isCreateable() && Schema.sObjectType.Employee_Review_Recommendation__c.isUpdateable()) DMLManager.upsertAsUser(rw.wrapRecommendation);  else{ }
                }
            }
        if(saveAndStay == true){
            saveAndStay = false;
            return null;
        }
        if(saveAndReturn == true){
            saveAndReturn = false;
            PageReference reviewPage = new PageReference(comAppend + '/EmployeeReview');
            reviewPage.setRedirect(true);
            return reviewPage;      
        }
        if(submittedForApproval == 'true'){
            if(managerId == null){return null;
            }if(Schema.sobjectType.ERP7__Review__c.fields.Status__c.isAccessible()) review.Status__c = 'Submitted To Manager'; if(Schema.sobjectType.ERP7__Review__c.fields.Date_Submitted_to_Manager__c.isAccessible()) review.Date_Submitted_to_Manager__c = system.today();
            if(Schema.sObjectType.Review__c.isCreateable() && Schema.sObjectType.Review__c.isUpdateable())  DMLManager.upsertAsUser(review); else{ }
            if(review.Id != null){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); req.setComments('Submitted for approval. Please review and approve.');
                req.setObjectId(review.Id); req.setNextApproverIds(new Id[] {managerId}); Approval.ProcessResult result = Approval.process(req);
                          
            }
            PageReference reviewPage = new PageReference(comAppend + '/EmployeeReview');
            reviewPage.setRedirect(true); return reviewPage;    } if(manageReviewApproval == true){review.Status__c = 'Signed Off';review.Date_Signed_Off__c = system.today();review.Signed_Off__c = true; if(review.Id != null){Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};ProcessInstance[] pi = [Select ID, Status, TargetObject.Name, (SELECT Id, ActorId, ProcessInstanceId FROM Workitems), (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance Where TargetObjectID =: review.Id AND Status = 'Pending'];  for(ProcessInstance instance : pi){ for(ProcessInstanceWorkItem workItem : instance.WorkItems){   Approval.ProcessWorkitemRequest prWkItem = new Approval.ProcessWorkitemRequest();     prWkItem.setWorkItemID(workItem.id);prWkItem.setComments('Request Approved by User: ' + userInfo.getName()); prWkItem.setAction('Approve');prWkItems.add(prWkItem); Approval.ProcessResult result =  Approval.process(prWkItem);  System.assert(result.isSuccess(), 'Result Status:'+result.isSuccess());}}  }PageReference reviewPage = new PageReference(comAppend + '/EmployeeReview');reviewPage.setRedirect(true); return reviewPage;       }     if(manageReviewRejection == true){ review.Status__c = 'Request For Amendment';if(review.Id != null){ Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{}; ProcessInstance[] pi = [Select ID, Status, TargetObject.Name, (SELECT Id, ActorId, ProcessInstanceId FROM Workitems), (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance Where TargetObjectID =: review.Id AND Status = 'Pending']; for(ProcessInstance instance : pi){for(ProcessInstanceWorkItem workItem : instance.WorkItems){   Approval.ProcessWorkitemRequest prWkItem = new Approval.ProcessWorkitemRequest();   prWkItem.setWorkItemID(workItem.id);prWkItem.setComments('Request Rejected by User: ' + userInfo.getName());prWkItem.setAction('Reject');prWkItems.add(prWkItem);   Approval.ProcessResult result =  Approval.process(prWkItem); System.assert(result.isSuccess(), 'Result Status:'+result.isSuccess());}  }    } PageReference reviewPage = new PageReference(comAppend + '/EmployeeReview'); reviewPage.setRedirect(true); return reviewPage;  }   PageReference reviewPage = new PageReference(comAppend + '/EmployeeReview');reviewPage.setRedirect(true);return reviewPage;
        
    }
    
    public boolean saveAndStay {get; set;}
    public boolean saveAndReturn {get; set;}
    public string submittedForApproval {get; set;}
    public boolean manageReviewApproval {get; set;}  
    public boolean manageReviewRejection {get; set;}    
    
    public List<Review__c> reviewListFilter {get; set;}
    public PageReference filterReviews(){
        if(empId != null){
            if(review.Review_Type__c == null){
                reviewListFilter = new List<Review__c>();
                if(Schema.sObjectType.Review__c.isAccessible())
                    reviewListFilter = [Select Name, Id, Target_Completion_Date__c, Status__c, Start_Date__c, Signed_Off__c, Review_Type__c, 
                                                                Review_Overall_Score__c, ReviewManager__c, Over_All_Objectives_Achieved__c, Organisation__c, 
                                                                Organisation_Business_Unit__c, Last_Review__c, Is_Locked__c, Employees__c, Date_Submitted_to_Manager__c, 
                                                                Date_Signed_Off__c, Active__c, Employees__r.Organisation__c, Employees__r.Organisation_Business_Unit__c,
                                                                ReviewManager__r.Employee_User__r.Name, Organisation_Business_Unit__r.Id, Organisation__r.Id, LastModifiedDate,
                                                                ReviewManager__r.First_Name__c, ReviewManager__r.Last_Name__c, Employees__r.Employee_User__r.ManagerId, Employees__r.Employee_User__r.Manager.Name,
                                                                of_Over_All_Goals_Achieved__c 
                                                           From Review__c 
                                                           where Employees__c =: empId ORDER BY Start_Date__c asc limit 10000];
            reviewList = reviewListFilter;
            }
        }    
        if(empId != null){
            if(review.Review_Type__c != null){
                reviewListFilter = new List<Review__c>();
                if(Schema.sObjectType.Review__c.isAccessible())
                reviewListFilter = [Select Name, Id, Target_Completion_Date__c, Status__c, Start_Date__c, Signed_Off__c, Review_Type__c, 
                                                            Review_Overall_Score__c, ReviewManager__c, Over_All_Objectives_Achieved__c, Organisation__c, 
                                                            Organisation_Business_Unit__c, Last_Review__c, Is_Locked__c, Employees__c, Date_Submitted_to_Manager__c, 
                                                            Date_Signed_Off__c, Active__c, Employees__r.Organisation__c, Employees__r.Organisation_Business_Unit__c,
                                                            ReviewManager__r.Employee_User__r.Name, Organisation_Business_Unit__r.Id, Organisation__r.Id, LastModifiedDate,
                                                            ReviewManager__r.First_Name__c, ReviewManager__r.Last_Name__c, Employees__r.Employee_User__r.ManagerId, Employees__r.Employee_User__r.Manager.Name,
                                                            of_Over_All_Goals_Achieved__c 
                                                       From Review__c 
                                                       where Employees__c =: empId 
                                                       and Review_Type__c =: review.Review_Type__c ORDER BY Start_Date__c asc limit 10000];
            reviewList = reviewListFilter;
            }
        }
        return null;
    }
   public PageReference viewEmpReviewPageRedirect(){
        PageReference viewEmpReviewPage = new PageReference(comAppend + '/EmployeeReviewV2');
        viewEmpReviewPage.setRedirect(true);
        viewEmpReviewPage.getParameters().put('rev', revId);
        viewEmpReviewPage.getParameters().put('tb1', tb1);
        return viewEmpReviewPage;
    }
    public string viewEmpMngr {get; set;}
    public string viewEmpRev {get; set;}
    public PageReference viewMngrEmpReviewPageRedirect(){
        if(viewEmpMngr != '' && viewEmpMngr != null){                    
            String tempMngrId = employee.Id;
            isManager = true;
            if(Schema.sObjectType.Employees__c.isAccessible())
            employee = [Select Name, Id, Work_Status__c,  Social_Security_Number__c, Channel__c, ReportingManager__c, 
                                    Organisation__c, Organisation_Business_Unit__c, Non_Employee__c, Marital_Status__c, Address__c, 
                                    Last_Name__c, Job_Title__c, Gender__c, Former_Employee__c, Former_Employee_Record__c, 
                                    First_Working_Day__c, First_Name__c, Employment_Status__c, Employment_Start_Date__c, Employment_End_Date__c, 
                                    Employee_User__c, Employee_Profiling__c, Email__c, Description__c, Date_Of_Birth__c, Contract_Offer_Issue_Date__c, 
                                    Commission_Plan__c,  Active__c, Employee_Profiling__r.Id, Organisation__r.Id, Organisation__r.Name,
                                    Organisation_Business_Unit__r.Name, ReportingManager__r.Name, ReportingManager__r.First_Name__c, ReportingManager__r.Last_Name__c,
                                    Employee_User__r.ManagerId, Employee_User__r.Manager.Name
                                From Employees__c 
                                where Id =: viewEmpMngr];
            PageReference addMngrReviewPage = new PageReference(comAppend + '/EmployeeReviewV2');
            addMngrReviewPage.setRedirect(true);
            addMngrReviewPage.getParameters().put('rev', viewEmpRev);
            addMngrReviewPage.getParameters().put('emp', employee.Id);
            addMngrReviewPage.getParameters().put('mngr', tempMngrId);
            addMngrReviewPage.getParameters().put('tb2', tb2);
            return addMngrReviewPage;}else{return null;
        }   
    }
    public PageReference backToReviewPageRedirect(){
        PageReference backToReviewPage = new PageReference(comAppend + '/EmployeeReview');
        backToReviewPage.setRedirect(true);
        return backToReviewPage;
    }
    public PageReference addNewEmpReviewPageRedirect(){     
        PageReference addReviewPage = new PageReference(comAppend + '/EmployeeReviewV2');
        addReviewPage.setRedirect(true);
        addReviewPage.getParameters().put('tb1', tb1);  
        return addReviewPage;
    }
    public string employeeMngr {get; set;}
    public PageReference addNewMngrEmpReviewPageRedirect(){
        if(employeeMngr != '' && employeeMngr != null){
            String tempMngrId = employee.Id;
            isManager = true;
            if(Schema.sObjectType.Employees__c.isAccessible())
            employee = [Select Name, Id, Work_Status__c,  Social_Security_Number__c, Channel__c, ReportingManager__c, 
                                    Organisation__c, Organisation_Business_Unit__c, Non_Employee__c, Marital_Status__c, Address__c, 
                                    Last_Name__c, Job_Title__c, Gender__c, Former_Employee__c, Former_Employee_Record__c, 
                                    First_Working_Day__c, First_Name__c, Employment_Status__c, Employment_Start_Date__c, Employment_End_Date__c, 
                                    Employee_User__c, Employee_Profiling__c, Email__c, Description__c, Date_Of_Birth__c, Contract_Offer_Issue_Date__c, 
                                    Commission_Plan__c,  Active__c, Employee_Profiling__r.Id, Organisation__r.Id, Organisation__r.Name,
                                    Organisation_Business_Unit__r.Name, ReportingManager__r.Name, ReportingManager__r.First_Name__c, ReportingManager__r.Last_Name__c,
                                    Employee_User__r.ManagerId, Employee_User__r.Manager.Name
                                From Employees__c 
                                where Id =: employeeMngr];
            PageReference viewMngrEmpReviewPage = new PageReference(comAppend + '/EmployeeReviewV2');
            viewMngrEmpReviewPage.setRedirect(true);
            viewMngrEmpReviewPage.getParameters().put('emp', employee.Id);
            viewMngrEmpReviewPage.getParameters().put('mngr', tempMngrId);
            viewMngrEmpReviewPage.getParameters().put('tb2', tb2);
            return viewMngrEmpReviewPage;}else{return null;
        }
    }
        public List<EmployeeReviewWrapper> EmployeeReviewWrapperList {get; set;}
        public Map<Employees__c, List<Review__c>> EmployeeReviewMap {get; set;}
        
        public List<Employees__c> EmployeeList {get; set;}        
        public List<Review__c> empReviewList {get; set;}  public Integer currentEmployeeIndex { get; set; }public Integer currentEmpReviewIndex { get; set; }
        public class EmployeeReviewWrapper {
        public Employees__c wrapEmployee {get; set;}
        public List<Review__c> wrapEmpReviewList {get; set;}
        public EmployeeReviewWrapper(){
            wrapEmployee = new Employees__c();
            wrapEmpReviewList = new List<Review__c>();
        }
    }
        public List<GoalObjectiveWrapper> GoalObjectiveWrapperList {get; set;}
        public Map<Goal__c, List<Objective__c>> GoalObjectiveMap {get; set;}
        public Map<Goal__c, List<Objective__c>> eOGoalObjectiveMap {get; set;}
        public List<Goal__c> eOGoalList {get; set;}        
        public List<Objective__c> eOObjectiveList {get; set;}  
        public List<Goal__c> GoalList {get; set;}        
        public List<Objective__c> ObjectiveList {get; set;}        
        public List<Goal__c> GoalToDeleteList {get; set;} 
        public List<Objective__c> ObjectiveToDeleteList {get; set;} 
        public Integer currentGoalIndex { get; set; }
        public String goalToDeleteId { get; set; }        
        public Integer currentObjectiveIndex { get; set; }
        public String objectiveToDeleteId { get; set; }
        public PageReference addNewGoalRow(){                       
        GoalObjectiveWrapper rev = new GoalObjectiveWrapper();Goal__c g = new Goal__c();rev.wrapGoal = g;GoalObjectiveWrapperList.add(rev);return null;          
    }
    public PageReference delGoalRow(){   
        if(GoalObjectiveWrapperList.size() > 0){                               
            if(goalToDeleteId != null && goalToDeleteId != ''){if(GoalToDeleteList == null){GoalToDeleteList = new List<Goal__c>();}GoalToDeleteList.add(new Goal__c(Id=goalToDeleteId));
            }                
            GoalObjectiveWrapperList.remove(currentGoalIndex);
        }
        return null;         
    }
    public PageReference addNewObjectiveRow(){
        GoalObjectiveWrapper rev = GoalObjectiveWrapperList.get(currentGoalIndex);
            Objective__c o = new Objective__c();
            rev.wrapObjectiveList.add(o);
        return null;         
    }
    public PageReference delObjectiveRow(){                       
        if(GoalObjectiveWrapperList.size() > 0){                               
            if(ObjectiveToDeleteId != null && ObjectiveToDeleteId != ''){if(ObjectiveToDeleteList == null){ObjectiveToDeleteList = new List<Objective__c>();} ObjectiveToDeleteList.add(new Objective__c(Id=ObjectiveToDeleteId));}  
            GoalObjectiveWrapper rev = GoalObjectiveWrapperList.get(currentGoalIndex);             
            rev.wrapObjectiveList.remove(currentObjectiveIndex);
        }
        return null;             
    }
    public class GoalObjectiveWrapper {
        public Goal__c wrapGoal {get; set;}public String wgObjComment{get{ return (this.wrapGoal.Objective_Comment__c != Null)? this.wrapGoal.Objective_Comment__c : ''; }set{ wgObjComment = value; this.wrapGoal.Objective_Comment__c = wgObjComment; }}
        public List<Objective__c> wrapObjectiveList {get; set;}
        public GoalObjectiveWrapper(){
            wrapGoal = new Goal__c();
            wrapObjectiveList = new List<Objective__c>();
        }
    }
    public List<Employee_Organisational_Goal__c> EmpOrgGoalList {get; set;}
    public List<Employee_Organisational_Objective__c> EmpOrgObjectiveList {get; set;}
    public List<Employee_Organisational_Objective__c> EmpOrgGoalObjectiveList {get; set;}   
    public List<EmpOrgGoalObjectiveWrapper> EmpOrgGoalObjectiveWrapperList {get; set;}
    public Map<Employee_Organisational_Goal__c, List<Employee_Organisational_Objective__c>> EmpOrgGoalObjectiveMap {get; set;}  
    public class EmpOrgGoalObjectiveWrapper {
    public Employee_Organisational_Goal__c wrapEmpOrgGoal {get; set;}
    public List<Employee_Organisational_Objective__c> wrapEmpOrgGoalObjectiveList {get; set;}
        public EmpOrgGoalObjectiveWrapper(){
            wrapEmpOrgGoal = new Employee_Organisational_Goal__c();
            wrapEmpOrgGoalObjectiveList = new List<Employee_Organisational_Objective__c>();
        }
    }
        public List<ReviewLearningPlanWrapper> ReviewLearningPlanWrapperList {get; set;}  public List<Learning_Plan__c> LearningPlanList {get; set;}              
        public List<Learning_Plan__c> LearningPlanToDeleteList {get; set;} 
        public Integer currentLearningPlanIndex { get; set; }
        public String LearningPlanToDeleteId { get; set; }        
        public PageReference addNewLearningPlanRow(){                       
        ReviewLearningPlanWrapper rev = new ReviewLearningPlanWrapper();
            Learning_Plan__c lp = new Learning_Plan__c();
            rev.wrapLearningPlan = lp;
            rev.wrapReview = review;
            ReviewLearningPlanWrapperList.add(rev);
        return null;          
    }
    public PageReference delLearningPlanRow(){   
        if(ReviewLearningPlanWrapperList.size() > 0){                               
            if(LearningPlanToDeleteId != null && LearningPlanToDeleteId != ''){if(LearningPlanToDeleteList == null){LearningPlanToDeleteList = new List<Learning_Plan__c>();}LearningPlanToDeleteList.add(new Learning_Plan__c(Id=LearningPlanToDeleteId));}                
            ReviewLearningPlanWrapperList.remove(currentLearningPlanIndex);
        }return null;         
    }
    public class ReviewLearningPlanWrapper {
        public Review__c wrapReview {get; set;}
        public Learning_Plan__c wrapLearningPlan {get; set;}
        public ReviewLearningPlanWrapper (){wrapReview = new Review__c();wrapLearningPlan = new Learning_Plan__c();
        }
    }
 public List<ReviewInitiativeWrapper> ReviewInitiativeWrapperList {get; set;}  public List<Employee_Initiative__c> InitiativeList {get; set;}              
        public List<Employee_Initiative__c> InitiativeToDeleteList {get; set;} 
        public Integer currentInitiativeIndex { get; set; }
        public String InitiativeToDeleteId { get; set; }        
    public PageReference addNewInitiativeRow(){                       
        ReviewInitiativeWrapper rev = new ReviewInitiativeWrapper();
            Employee_Initiative__c lp = new Employee_Initiative__c();
            rev.wrapInitiative = lp;
            rev.wrapReview = review;
            ReviewInitiativeWrapperList.add(rev);
        return null;          
    }
    public PageReference delInitiativeRow(){   
        if(ReviewInitiativeWrapperList.size() > 0){                               
            if(InitiativeToDeleteId != null && InitiativeToDeleteId != ''){if(InitiativeToDeleteList == null){InitiativeToDeleteList = new List<Employee_Initiative__c>();}InitiativeToDeleteList.add(new Employee_Initiative__c(Id=InitiativeToDeleteId));}                
            ReviewInitiativeWrapperList.remove(currentInitiativeIndex);
        }
        return null;         
    }
    public class ReviewInitiativeWrapper {
        public Review__c wrapReview {get; set;}
        public Employee_Initiative__c wrapInitiative {get; set;}
        public ReviewInitiativeWrapper (){
            wrapReview = new Review__c();
            wrapInitiative = new Employee_Initiative__c();
        }
    }
        public List<ReviewRecommendationWrapper> ReviewRecommendationWrapperList {get; set;}   public List<Employee_Review_Recommendation__c> RecommendationList {get; set;}              
        public List<Employee_Review_Recommendation__c> RecommendationToDeleteList {get; set;} 
        public Integer currentRecommendationIndex { get; set; }
        public String RecommendationToDeleteId { get; set; }        
        public PageReference addNewRecommendationRow(){                       
        ReviewRecommendationWrapper rev = new ReviewRecommendationWrapper();
            Employee_Review_Recommendation__c r = new Employee_Review_Recommendation__c();
            rev.wrapRecommendation = r;
            rev.wrapReview = review;
            ReviewRecommendationWrapperList.add(rev);
        return null;          
    }
    public PageReference delRecommendationRow(){   
        if(ReviewRecommendationWrapperList.size() > 0){                               
            if(RecommendationToDeleteId != null && RecommendationToDeleteId != ''){if(RecommendationToDeleteList == null){RecommendationToDeleteList = new List<Employee_Review_Recommendation__c>();}RecommendationToDeleteList.add(new Employee_Review_Recommendation__c(Id=RecommendationToDeleteId));}                
            ReviewRecommendationWrapperList.remove(currentRecommendationIndex);
        }
        return null;         
    }
    public class ReviewRecommendationWrapper {
        public Review__c wrapReview {get; set;}
        public Employee_Review_Recommendation__c wrapRecommendation {get; set;}
        public ReviewRecommendationWrapper (){
            wrapReview = new Review__c();
            wrapRecommendation = new Employee_Review_Recommendation__c();
        }
    }
    public List<Organisational_Goal__c> OrgGoalList {get; set;}
    public List<Organisational_Objective__c> OrgObjectiveList {get; set;}
    public List<Organisational_Objective__c> OrgGoalObjectiveList {get; set;}   
    public List<OrgGoalObjectiveWrapper> OrgGoalObjectiveWrapperList {get; set;}
    public Map<Organisational_Goal__c, List<Organisational_Objective__c>> OrgGoalObjectiveMap {get; set;}  
    public class OrgGoalObjectiveWrapper {
        public Organisational_Goal__c wrapOrgGoal {get; set;}
        public List<Organisational_Objective__c> wrapOrgGoalObjectiveList {get; set;}
        public OrgGoalObjectiveWrapper(){
            wrapOrgGoal = new Organisational_Goal__c();
            wrapOrgGoalObjectiveList = new List<Organisational_Objective__c>();
        }
    }
}