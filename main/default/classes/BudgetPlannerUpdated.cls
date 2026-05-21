public with sharing class BudgetPlannerUpdated {
    @AuraEnabled
    Public list<SelectOption> coaRevenueRecordTypeList  {set;get;} 
    @AuraEnabled
    Public list<SelectOption> coaExpenseRecordTypeList  {set;get;} 
    
    public class budget{ 
        @AuraEnabled
        public Decimal VarianceAmount  {set;get;}
        @AuraEnabled
        public Decimal BudgetAmount  {set;get;}
        @AuraEnabled
        public Decimal ExpenseAmount  {set;get;}
        @AuraEnabled
        public Map<String,list<Decimal>> RevenueBudgetMap {set;get;}
        @AuraEnabled
        public Map<String,list<Decimal>> ExpenseBudgetMap {set;get;}
        
        @AuraEnabled
        Public list<SelectOption> coaRevenueRecordTypeList  {set;get;} 
        @AuraEnabled
        Public list<SelectOption> coaExpenseRecordTypeList  {set;get;} 
        
        @AuraEnabled
        Public list<Decimal> PreviousTwoYearsRevenueValues  {set;get;} 
        @AuraEnabled
        Public Decimal PreviousTwoYearsTotalRevenueValues  {set;get;}
        
        @AuraEnabled
        Public list<Decimal> PreviousOneYearsRevenueValues  {set;get;} 
        @AuraEnabled
        Public Decimal PreviousOneYearsTotalRevenueValues  {set;get;}
    }
    
    public class budgetWrapper{
        @AuraEnabled public List<ERP7__Budget_Account__c> assetAccount {get;set;}
        @AuraEnabled public List<ERP7__Budget_Account__c> laibilityAccount {get;set;}
        @AuraEnabled public List<ERP7__Budget_Account__c> EquityAccount {get;set;}
        @AuraEnabled public List<ERP7__Budget_Account__c> RevenueAccount {get;set;}
        @AuraEnabled public List<ERP7__Budget_Account__c> ExpenseAccount {get;set;}
        public budgetWrapper(){
            assetAccount = laibilityAccount = EquityAccount = RevenueAccount = ExpenseAccount = new List<ERP7__Budget_Account__c>();
        }
    }
    
    public class DepartmentWrapper{
        @AuraEnabled public String DepartmentId {get;set;}
        @AuraEnabled public Integer DepartmentBudgetAmount {get;set;}
        @AuraEnabled public List<ERP7__Budget_Account__c> budgetAccount {get;set;}
        @AuraEnabled public List<ERP7__Budget_Account__c> budgetTimeAccount {get;set;}
        public DepartmentWrapper(){
            DepartmentId = '';
            DepartmentBudgetAmount = 0;
            budgetAccount = new List<ERP7__Budget_Account__c>();
            budgetTimeAccount = new List<ERP7__Budget_Account__c>();
        }
    }
    public class projectWrapper{
        @AuraEnabled public String Project {get;set;}
        @AuraEnabled public Integer ProjectBudgetAmount {get;set;}
        @AuraEnabled public List<DepartmentWrapper> depWrapList {get;set;}
        public projectWrapper(){
            Project = '';
            ProjectBudgetAmount = 0;
            depWrapList = new List<DepartmentWrapper>();
        }
    }
    
    public class programmeWrapper{
        @AuraEnabled public String Programme {get;set;}
        @AuraEnabled public List<projectWrapper> projWrapList {get;set;}
        public programmeWrapper(){
            Programme = '';
            projWrapList = new List<projectWrapper>();
        }
    }  
    
    @AuraEnabled 
    public static projectWrapper getProjectWrapp(){
        projectWrapper pwrap = new projectWrapper();
        DepartmentWrapper drwap = new DepartmentWrapper();
        ERP7__Budget_Account__c nb = new ERP7__Budget_Account__c(Name = 'Budget', ERP7__Chart_of_Account__c = null, ERP7__Amount__c = 0.00);
        drwap.budgetAccount.add(nb);
        pwrap.depWrapList.add(drwap);
        return pwrap;
    }
    
    @AuraEnabled 
    public static programmeWrapper getProgrammeWrapp(){
        programmeWrapper pwrap = new programmeWrapper();
        projectWrapper prwrap = new projectWrapper();
        DepartmentWrapper drwap = new DepartmentWrapper();
        ERP7__Budget_Account__c nb = new ERP7__Budget_Account__c(Name = 'Budget', ERP7__Chart_of_Account__c = null, ERP7__Amount__c = 0.00);
        drwap.budgetAccount.add(nb);
        prwrap.depWrapList.add(drwap);
        pwrap.projWrapList.add(prwrap);
        return pwrap;
    }
    
    @AuraEnabled 
    public static ERP7__Budget_Account__c getBudgetInstance(){
        ERP7__Budget_Account__c nb = new ERP7__Budget_Account__c(Name = 'Budget', ERP7__Chart_of_Account__c = null, ERP7__Amount__c = 0.00);
        return nb;
    }
    
    @AuraEnabled 
    public static DepartmentWrapper getDepartmentWrapp(){
        DepartmentWrapper dwrap = new DepartmentWrapper();
        ERP7__Budget_Account__c nb = new ERP7__Budget_Account__c(Name = 'Budget', ERP7__Chart_of_Account__c = null, ERP7__Amount__c = 0.00);
        dwrap.budgetAccount.add(nb);
        return dwrap;
    }
    
    @AuraEnabled 
    public static ERP7__Chart_of_Accounts__c  getChartOfAccountDetails(String coaId){
        ERP7__Chart_of_Accounts__c  coa = new ERP7__Chart_of_Accounts__c();
        coa = [select Id, Name, ERP7__Account_Code__c, RecordType.DeveloperName from ERP7__Chart_of_Accounts__c where Id=:coaId];
        return coa;
    }
    
    
    public class Wrapper{
        @AuraEnabled public list<ERP7__Budget_Plan__c> CompleteBudgetList                   {get;set;}
         @AuraEnabled public list<ERP7__Budget_Plan__c> FilteredBudgetList                   {get;set;}
        @AuraEnabled public Integer recSize                                                     {get;set;}
        public Wrapper(){
            CompleteBudgetList=new list<ERP7__Budget_Plan__c>();
            FilteredBudgetList=new list<ERP7__Budget_Plan__c>();
        }
    }
    
    @AuraEnabled 
    public static Account getDefaultOrganisation(){
        return UtilClass.getOrganisationByLogin_Employee();
    }  
    
    @AuraEnabled
    public static List<String> getYearsList() {
        List<String> years = new List<String>();
        Integer currentYear = Date.today().year();
        for(Integer i = currentYear; i <= currentYear + 10; i++) {
            years.add(String.valueOf(i));
        }
        return years;
    }
    
    @AuraEnabled 
    public static ERP7__Budget_Plan__c getBudgetDetails(String BudgetId){
        ERP7__Budget_Plan__c bplan = new ERP7__Budget_Plan__c();
        bplan = [select Id, Name, ERP7__Threshold_Limit__c, ERP7__Posted_Actual_Expenditures__c,ERP7__UnPosted_Actual_Expenditures__c, ERP7__Budget_Type__c, ERP7__Budget_Category__c, ERP7__Organisation__c,Start_Date__c, End_Date__c  from ERP7__Budget_Plan__c where Id=:BudgetId];
        return bplan;
    }
    @AuraEnabled
    public static String SaveMonthlyBudgetUpdated(String OrgId, String year, String month, String wrapListJSON, String BudgetId, String budgetType, String budgetCat, Decimal threshold, String budgetControl, Decimal budgetAmount) {
        system.debug('threshold-->'+threshold);
        system.debug('budgetControl-->'+budgetControl);
        system.debug('year-->'+year);
        system.debug('budgetCat-->'+budgetCat);
        String resultMessage = '';
        List<programmeWrapper> wrapList = (List<programmeWrapper>) JSON.deserialize(wrapListJSON, List<programmeWrapper>.class);
        Date startDate;
        Date endDate;
        system.debug('wrapList-->'+wrapList);
        
        // Map month names to their numeric values
        Map<String, Integer> monthMap = new Map<String, Integer>{
            'January' => 1,
                'February' => 2,
                'March' => 3,
                'April' => 4,
                'May' => 5,
                'June' => 6,
                'July' => 7,
                'August' => 8,
                'September' => 9,
                'October' => 10,
                'November' => 11,
                'December' => 12
                };
                    
        Integer numericMonth = monthMap.get(month);
        Integer numericYear = Integer.valueOf(year);
        if(budgetType=='Monthly' && numericYear != null && numericMonth!=null){
            startDate = Date.newInstance(numericYear, numericMonth, 1);
            endDate = startDate.addMonths(1).addDays(-1);
        }else if(budgetType!='--None--' && numericYear != null && numericMonth!=null){
            startDate = Date.newInstance(numericYear, numericMonth, 1);
            endDate = startDate.addYears(1).addDays(-1);
        }
        
        // Now you can use startDate and endDate to set the fields in bplan or perform other operations
        
        ERP7__Budget_Plan__c bplan = new ERP7__Budget_Plan__c();
        bplan.ERP7__Threshold_Limit__c  = threshold;
        system.debug('budgetControl-->'+budgetControl);
        system.debug('budgetAmount-->'+budgetAmount);
        if(budgetControl=='Posted Actual Expenditures'){
            bplan.ERP7__Posted_Actual_Expenditures__c = true;
            bplan.ERP7__UnPosted_Actual_Expenditures__c = false;
        }else{
            bplan.ERP7__UnPosted_Actual_Expenditures__c = true;
            bplan.ERP7__Posted_Actual_Expenditures__c = false;
        }
        bplan.ERP7__Total_Budget_Amount__c = budgetAmount;
        system.debug('budgetType-->'+budgetType);
        // Set other fields of bplan as needed
        if(budgetType=='Monthly'){
            bplan.ERP7__Budget_Type__c = 'Monthly';
            bplan.Name = month + ' ' +'Budget '+ year;
        }else if(budgetType=='Quarterly'){
            bplan.ERP7__Budget_Type__c = 'Quarterly';
            bplan.Name = 'Quarterly' + ' ' +'Budget ' + year;
        }else if(budgetType=='Yearly'){
            bplan.ERP7__Budget_Type__c = 'Yearly';
            bplan.Name = 'Yearly' + ' ' +'Budget ' + year;
        }else{
            bplan.ERP7__Budget_Type__c = 'Monthly';
            bplan.Name = 'Project Budgetting';
        }
        bplan.ERP7__Budget_Category__c = budgetCat;
        // Set the start date and end date fields
        if(startDate!=null) bplan.Start_Date__c = startDate;
        if(endDate!=null) bplan.End_Date__c = endDate;
        bplan.ERP7__Organisation__c = OrgId;
        // Perform any other operations needed for saving the monthly budget
        system.debug('bplan-->'+bplan);
        // Example: Insert the bplan record into the database
        try {
            system.debug('BudgetId-->'+BudgetId);
            String BudgetingId = '';
            if(BudgetId!=null && BudgetId!=''){
                bplan.Id = BudgetId;
            }
            upsert bplan;
            BudgetingId = bplan.Id;
            
            list<ERP7__Budget_Account__c> bAccounts = new list<ERP7__Budget_Account__c>();
            for(programmeWrapper pwrap : wrapList){
                for(ProjectWrapper projrap : pwrap.projWrapList){
                    for(DepartmentWrapper dwrap : projrap.depWrapList){
                        for(ERP7__Budget_Account__c bac : dwrap.budgetAccount){ if(dwrap.DepartmentId!=null && dwrap.DepartmentId!='') bac.ERP7__Business_Unit__c = dwrap.DepartmentId; if(projrap.Project!=null && projrap.Project!='') bac.ERP7__Project__c = projrap.Project;  if(pwrap.Programme!=null && pwrap.Programme!='') bac.ERP7__Programme__c = pwrap.Programme;  bAccounts.add(bac);
                        }
                        if(dwrap.budgetTimeAccount!=null){
                            for(ERP7__Budget_Account__c bac : dwrap.budgetTimeAccount){
                                system.debug('Entered');
                                if(dwrap.DepartmentId!=null && dwrap.DepartmentId!='') bac.ERP7__Business_Unit__c = dwrap.DepartmentId; if(projrap.Project!=null && projrap.Project!='') bac.ERP7__Project__c = projrap.Project;  if(pwrap.Programme!=null && pwrap.Programme!='') bac.ERP7__Programme__c = pwrap.Programme; bAccounts.add(bac);
                            }
                        }
                    }
                }
            }
            system.debug('bAccounts-->'+bAccounts.size());
            for(ERP7__Budget_Account__c bac : bAccounts){
                bac.ERP7__Budget_Plan__c = BudgetingId;
                if(budgetType=='Monthly'){ bac.RecordTypeId = Schema.SObjectType.ERP7__Budget_Account__c.getRecordTypeInfosByDeveloperName().get('Monthly').getRecordTypeId();
                                         }else if(budgetType=='Quarterly'){  bac.RecordTypeId = Schema.SObjectType.ERP7__Budget_Account__c.getRecordTypeInfosByDeveloperName().get('Quarterly').getRecordTypeId();
                                                                          }else{  bac.RecordTypeId = Schema.SObjectType.ERP7__Budget_Account__c.getRecordTypeInfosByDeveloperName().get('Yearly').getRecordTypeId();
                                                                               }
            }
            if(bAccounts!=null && bAccounts.size()>0){  upsert bAccounts;
            }
            
            resultMessage = 'Budget Plan saved successfully.';
        } catch (Exception e) {
            resultMessage = 'An error occurred while saving the Budget Plan: ' + e.getMessage() + e.getLineNumber();
        }
        
        return resultMessage;
    }
    
    @AuraEnabled
    public static List<ProgrammeWrapper> fetchMonthlyBudgetUpdate(String OrgId, String BudgetId) {
        system.debug('called');
        List<ProgrammeWrapper> pwrapList = new List<ProgrammeWrapper>(); // Corrected to ProjectWrapper
        if (String.isNotBlank(BudgetId)) {
            List<ERP7__Budget_Account__c> budgetAccountList = [
                SELECT Id, ERP7__Cost_Per_Hour__c , ERP7__Activity_Type__c, ERP7__Project_Hour__c, ERP7__Q1_Allocated_Hours__c, ERP7__Q2_Allocated_Hours__c, ERP7__Q3_Allocated_Hours__c, ERP7__Q4_Allocated_Hours__c, ERP7__Business_Unit__c, Name, ERP7__December_Budget__c, ERP7__November_Budget__c, 
                ERP7__October_Budget__c, ERP7__September_Budget__c, ERP7__August_Budget__c, ERP7__July_Budget__c, 
                ERP7__June_Budget__c, ERP7__May_Budget__c, ERP7__April_Budget__c, ERP7__March_Budget__c, 
                ERP7__January_Budget__c, ERP7__February_Budget__c, ERP7__First_Quarter_Amount__c, 
                ERP7__Second_Quarter_Amount__c, ERP7__Third_Quarter_Amount__c, ERP7__Fourth_Quarter_Amount__c, 
                ERP7__Project__c, ERP7__Account_Number__c, ERP7__Budget_Account_Category__c, ERP7__Amount__c, 
                ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, 
                ERP7__Chart_of_Account__r.RecordTypeId, ERP7__Organisation__c, ERP7__Programme__c 
                FROM ERP7__Budget_Account__c 
                WHERE ERP7__Budget_Plan__c = :BudgetId AND ERP7__Project__c != null order by ERP7__Project__c
            ];
            
            // Group budgetAccountList by Project
            Map<String, ProjectWrapper> projectMap = new Map<String, ProjectWrapper>();
            Map<String, ProgrammeWrapper> progMap = new Map<String, ProgrammeWrapper>();
            
            for (ERP7__Budget_Account__c budgetAccount : budgetAccountList) {
                system.debug('id-->'+budgetAccount.Id);
                if(budgetAccount.Id!=null){
                    String progName = '';
                    if(budgetAccount.ERP7__Programme__c!=null){
                        progName = budgetAccount.ERP7__Programme__c;
                    }
                     
                    
                    if (!progMap.containsKey(progName)) {
                        progMap.put(progName, new ProgrammeWrapper()); // Corrected to ProgrammeWrapper
                    }
                    
                    ProgrammeWrapper progWrapper = progMap.get(progName); // Corrected to ProgrammeWrapper
                    progWrapper.Programme = progName;
                    system.debug('budgetAccount-->'+budgetAccount);
                    String projectName = budgetAccount.ERP7__Project__c;
                    
                    if (!projectMap.containsKey(projectName)) {
                        projectMap.put(projectName, new ProjectWrapper());
                        ProjectWrapper projectWrapper = projectMap.get(projectName);
                        projectWrapper.Project = projectName;
                        // Check if the department already exists
                        DepartmentWrapper existingDepartment = null;
                        for (DepartmentWrapper depWrapper : projectWrapper.depWrapList) {
                            system.debug('Business Unit-->'+budgetAccount.ERP7__Business_Unit__c);
                            system.debug('Depart Id-->'+depWrapper.DepartmentId);
                            if (depWrapper.DepartmentId!=null && depWrapper.DepartmentId!='' && depWrapper.DepartmentId == budgetAccount.ERP7__Business_Unit__c) {
                                existingDepartment = depWrapper;
                                break;
                            }
                        }
                        system.debug('existingDepartment-->'+existingDepartment);
                        // If the department does not exist, add a new one
                        if (existingDepartment == null) {
                            DepartmentWrapper depWrapper = new DepartmentWrapper();
                            if(budgetAccount.ERP7__Business_Unit__c!=null){
                                depWrapper.DepartmentId = budgetAccount.ERP7__Business_Unit__c;
                            }else{
                                depWrapper.DepartmentId = '';
                            }
                            depWrapper.budgetAccount.add(budgetAccount);
                            system.debug('size-->'+depWrapper.budgetAccount.size());
                            projectWrapper.depWrapList.add(depWrapper);
                        } else {
                            // Add the budgetAccount to the existing department
                            existingDepartment.budgetAccount.add(budgetAccount);
                            system.debug('size-->'+existingDepartment.budgetAccount.size());
                        }
                        progWrapper.projWrapList.add(projectWrapper);
                    }else{
                        ProjectWrapper projectWrapper = projectMap.get(projectName);
                        // Check if the department already exists
                        DepartmentWrapper existingDepartment = null; for (DepartmentWrapper depWrapper : projectWrapper.depWrapList) {
                            system.debug('Business Unit-->'+budgetAccount.ERP7__Business_Unit__c);
                            system.debug('Depart Id-->'+depWrapper.DepartmentId);
                            if (depWrapper.DepartmentId!=null && depWrapper.DepartmentId!='' && depWrapper.DepartmentId == budgetAccount.ERP7__Business_Unit__c) { existingDepartment = depWrapper; break;
                            }
                        }
                        system.debug('existingDepartment-->'+existingDepartment);
                        // If the department does not exist, add a new one
                        if (existingDepartment == null) {  DepartmentWrapper depWrapper = new DepartmentWrapper();
                            if(budgetAccount.ERP7__Business_Unit__c!=null){  depWrapper.DepartmentId = budgetAccount.ERP7__Business_Unit__c;
                            }else{   depWrapper.DepartmentId = '';
                            }
                            if(budgetAccount.ERP7__Activity_Type__c!=null && budgetAccount.ERP7__Activity_Type__c!='' && budgetAccount.ERP7__Activity_Type__c!='--None--') depWrapper.budgetTimeAccount.add(budgetAccount);
                            else depWrapper.budgetAccount.add(budgetAccount);
                            system.debug('size-->'+depWrapper.budgetAccount.size());
                            projectWrapper.depWrapList.add(depWrapper);
                        } else {
                            // Add the budgetAccount to the existing department
                            if(budgetAccount.ERP7__Activity_Type__c!=null && budgetAccount.ERP7__Activity_Type__c!='' && budgetAccount.ERP7__Activity_Type__c!='--None--')  existingDepartment.budgetTimeAccount.add(budgetAccount);
                            else existingDepartment.budgetAccount.add(budgetAccount);
                            system.debug('size-->'+existingDepartment.budgetAccount.size());
                        }
                    }
                    progMap.put(progName, progWrapper);
                }
            }
            
            // Add all ProjectWrappers from the map to the final list
            pwrapList.addAll(progMap.values()); // Corrected to ProjectWrapper
        }
        
        return pwrapList; // Corrected to ProjectWrapper
    }
    
    public class BudgetFlsWrap{
        @AuraEnabled public Boolean displayProgramme            { get; set; }
        @AuraEnabled public Boolean displayDepartment            { get; set; }
        public BudgetFlsWrap(){
         displayProgramme = displayDepartment = false;
        }
    }
    @AuraEnabled
    Public static BudgetFlsWrap getBudgetFC(){
      BudgetFlsWrap Budget = new BudgetFlsWrap();
        try{
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c(); FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();   }  if(FC != null){ Budget.displayDepartment = FC.ERP7__Budget_Department_Allocation__c;  }  if(FC != null){ Budget.displayProgramme = FC.ERP7__Budget_Programme_Allocation__c;}
        }catch(Exception e){ System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); }
        return Budget;
    }
    
    @AuraEnabled
    public static String SaveMonthlyBudget(String OrgId, String year, String month, String wrapListJSON, String BudgetId) {
        String resultMessage = '';
        budgetWrapper wrapList = (budgetWrapper) JSON.deserialize(wrapListJSON, budgetWrapper.class);
        Date startDate;
        Date endDate;
        
        // Map month names to their numeric values
        Map<String, Integer> monthMap = new Map<String, Integer>{
            'January' => 1,
                'February' => 2,
                'March' => 3,
                'April' => 4,
                'May' => 5,
                'June' => 6,
                'July' => 7,
                'August' => 8,
                'September' => 9,
                'October' => 10,
                'November' => 11,
                'December' => 12
                };
                    
                    Integer numericMonth = monthMap.get(month);
        Integer numericYear = Integer.valueOf(year);
        
        startDate = Date.newInstance(numericYear, numericMonth, 1);
        endDate = startDate.addMonths(1).addDays(-1);
        
        // Now you can use startDate and endDate to set the fields in bplan or perform other operations
        
        ERP7__Budget_Plan__c bplan = new ERP7__Budget_Plan__c();
        bplan.Name = month + ' ' + year;
        // Set other fields of bplan as needed
        
        // Set the start date and end date fields
        bplan.Start_Date__c = startDate;
        bplan.End_Date__c = endDate;
        bplan.ERP7__Organisation__c = OrgId;
        // Perform any other operations needed for saving the monthly budget
        system.debug('bplan-->'+bplan);
        // Example: Insert the bplan record into the database
        try {
            system.debug('BudgetId-->'+BudgetId);
            String BudgetingId = '';
            if(BudgetId!=null && BudgetId!=''){
                ERP7__Budget_Plan__c bpla = [select Id, Name, Start_Date__c, End_Date__c, ERP7__Organisation__c from ERP7__Budget_Plan__c where Id=:BudgetId];
                bpla.Start_Date__c = startDate;
                bpla.End_Date__c = endDate;
                bpla.ERP7__Organisation__c = OrgId;
                BudgetingId = bpla.Id;
                update bpla;
            }else{
                upsert bplan;
                BudgetingId = bplan.Id;
            }
            
            list<ERP7__Budget_Account__c> bAccounts = new list<ERP7__Budget_Account__c>();
            system.debug('wrapList-->'+wrapList);
            bAccounts.addAll(wrapList.assetAccount); bAccounts.addAll(wrapList.laibilityAccount); bAccounts.addAll(wrapList.EquityAccount); bAccounts.addAll(wrapList.RevenueAccount); bAccounts.addAll(wrapList.ExpenseAccount);
  for(ERP7__Budget_Account__c bac : bAccounts){ bac.ERP7__Budget_Plan__c = BudgetingId;
            }
            if(bAccounts!=null && bAccounts.size()>0){   upsert bAccounts;
            }
            resultMessage = 'Budget Plan saved successfully.';
        } catch (Exception e) {
            resultMessage = 'An error occurred while saving the Budget Plan: ' + e.getMessage() + e.getLineNumber();
        }
        
        return resultMessage;
    }


    
    @AuraEnabled 
    public static budgetWrapper fetchMonthlyBudget(String OrgId, String BudgetId){
        budgetWrapper bwrap = new budgetWrapper();
        List<ERP7__Budget_Account__c> assetAccount = new List<ERP7__Budget_Account__c>();
        List<ERP7__Budget_Account__c> liabAccount = new List<ERP7__Budget_Account__c>();
        List<ERP7__Budget_Account__c> equAccount = new List<ERP7__Budget_Account__c>();
        List<ERP7__Budget_Account__c> revAccount = new List<ERP7__Budget_Account__c>();
        List<ERP7__Budget_Account__c> expAccount = new List<ERP7__Budget_Account__c>();
        Set<Id> coaIds = new Set<Id>();
        if(BudgetId!='' && BudgetId!=null){
            List<ERP7__Budget_Account__c> budgetAccountList = new List<ERP7__Budget_Account__c>();
            budgetAccountList = [select Id, Name, ERP7__Amount__c, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.RecordTypeId, ERP7__Organisation__c from ERP7__Budget_Account__c where ERP7__Budget_Plan__c=:BudgetId];
            if(budgetAccountList!=null && budgetAccountList.size()>0){
                for(ERP7__Budget_Account__c bac : budgetAccountList){
                    String recordTypeDevName = bac.ERP7__Chart_of_Account__r.RecordType != null ? bac.ERP7__Chart_of_Account__r.RecordType.DeveloperName : null;
                    if(recordTypeDevName != null) {
                        coaIds.add(bac.ERP7__Chart_of_Account__c);
                        switch on recordTypeDevName {
                            when 'Assets' {  assetAccount.add(bac);
                                System.debug('Added to assetAccount: ' + bac);
                            }
                            when 'Liability' {  liabAccount.add(bac);
                                System.debug('Added to laibilityAccount: ' + bac);
                            }
                            when 'Equity' { equAccount.add(bac);
                                System.debug('Added to EquityAccount: ' + bac);
                            }
                            when 'Income_Revenue' {  revAccount.add(bac);
                                System.debug('Added to RevenueAccount: ' + bac);
                            }
                            when 'Expense' {  expAccount.add(bac);
                                System.debug('Added to ExpenseAccount: ' + bac);
                            }
                            // Add additional cases as needed
                            when else {
                                System.debug('Unhandled RecordType DeveloperName: ' + recordTypeDevName);
                            }
                        }
                    } else {
                        System.debug('RecordType is null for Chart of Account: ' + bac.Name);
                    }
                }
            }
        }
        
        system.debug('coaIds-->'+coaIds.size());
        List<ERP7__Chart_of_Accounts__c> coaList = [
            SELECT Id, Name, RecordType.DeveloperName, RecordTypeId 
            FROM ERP7__Chart_of_Accounts__c 
            WHERE ERP7__Active__c = true 
            AND ERP7__Available_for_Budgeting_Process__c = true 
            AND ERP7__Organisation__c = :OrgId
            AND Id Not IN :coaIds
        ];
        
        for(ERP7__Chart_of_Accounts__c coa : coaList) {
            String recordTypeDevName = coa.RecordType != null ? coa.RecordType.DeveloperName : null;
            System.debug('RecordType DeveloperName: ' + recordTypeDevName);
            if(recordTypeDevName != null) {
                ERP7__Budget_Account__c bac = createBudgetAccount(coa, OrgId);
                
                switch on recordTypeDevName { when 'Assets' {  assetAccount.add(bac);
                        System.debug('Added to assetAccount: ' + bac);
                    }
                    when 'Liability' {   liabAccount.add(bac);
                        System.debug('Added to laibilityAccount: ' + bac);
                    }
                    when 'Equity' {  equAccount.add(bac);
                        System.debug('Added to EquityAccount: ' + bac);
                    }
                    when 'Income_Revenue' { revAccount.add(bac);
                        System.debug('Added to RevenueAccount: ' + bac);
                    }
                    when 'Expense' { expAccount.add(bac);
                        System.debug('Added to ExpenseAccount: ' + bac);
                    }
                    // Add additional cases as needed
                    when else {
                        System.debug('Unhandled RecordType DeveloperName: ' + recordTypeDevName);
                    }
                }
            } else {
                System.debug('RecordType is null for Chart of Account: ' + coa.Name);
            }
        }
        bwrap.assetAccount = assetAccount;
        
        bwrap.laibilityAccount  = liabAccount;
        bwrap.EquityAccount = equAccount;
        bwrap.RevenueAccount = revAccount;
        bwrap.ExpenseAccount = expAccount;
        system.debug('bwrap-->' + bwrap);
        return bwrap;
    }

    
    public static ERP7__Budget_Account__c createBudgetAccount(ERP7__Chart_of_Accounts__c coa, String OrgId) {
        ERP7__Budget_Account__c bac = new ERP7__Budget_Account__c();
        bac.ERP7__Amount__c = 0;
        bac.ERP7__Chart_of_Account__c = coa.Id;
        bac.ERP7__Organisation__c = OrgId;
        bac.Name = coa.Name;
        return bac;
    }

    @AuraEnabled
    public static Wrapper getBudgetList(String OrgId, String OrderBy, String Order,Integer Offset, Integer RecordLimit){
        system.debug('orgId-->'+OrgId);
        Wrapper wrap=new Wrapper();
        try{
            String OrgFilter='';
            Integer ikOffset = Integer.valueof(Offset);
            Integer ikRecordLimit = Integer.valueof(RecordLimit);
            String OrderBy2=OrderBy;
            String Order2=Order;
            //String Limit += '  order by '+OrderBy2+' '+Order2+' limit :ikRecordLimit Offset :ikOffset ';
            if(String.isNotEmpty(OrgId)) OrgFilter=' ERP7__Organisation__c=:OrgId';
            else OrgFilter=' ERP7__Organisation__c=null';
            String query2='select Id, ERP7__Budget_Category__c , Name, ERP7__Status__c, ERP7__Budget_Used__c, ERP7__Consumed_Amount__c, ERP7__Remaining_Amount__c , ERP7__Total_Budget_Amount__c, ERP7__Budget_Type__c, ERP7__Approved__c, ERP7__Start_Date__c, ERP7__End_Date__c From ERP7__Budget_Plan__c where'+String.escapeSingleQuotes(OrgFilter)+' order by createddate desc';
            System.debug('query2'+query2);
            wrap.CompleteBudgetList=database.query(query2);
            wrap.recSize=wrap.CompleteBudgetList.size();
            OrgFilter+= '  order by createddate desc limit :ikRecordLimit Offset :ikOffset ';
            String query3='select Id, Name,ERP7__Budget_Category__c , ERP7__Status__c, ERP7__Budget_Used__c, ERP7__Consumed_Amount__c, ERP7__Remaining_Amount__c , ERP7__Total_Budget_Amount__c, ERP7__Budget_Type__c, ERP7__Approved__c, ERP7__Start_Date__c, ERP7__End_Date__c From ERP7__Budget_Plan__c  where'+String.escapeSingleQuotes(OrgFilter);
            System.debug('query3'+database.query(query3));
            wrap.FilteredBudgetList=database.query(query3);
            //BankRecon_obj=database.query(query2);
        }
        catch(Exception ex){
            
        }
        return wrap;
    }
    
    
  public class SelectOption { 
    @AuraEnabled
    public String value { get;set; }  
    @AuraEnabled
    public String label { get;set; }
    public SelectOption(String value, String label) {
        this.value = value;
        this.label = label;     
    }
  }   
    
    
    //Forecasting Code
    
    public class projectForecastWrapper{
        @AuraEnabled public String Project {get;set;}
        @AuraEnabled public Boolean UnpostedEx {get;set;}
        @AuraEnabled public Decimal ProjectBudgetAmount {get;set;}
        @AuraEnabled public Decimal ProjectConsumeAmount {get;set;}
        @AuraEnabled public Decimal ProjectCommittedAmount {get;set;}
        @AuraEnabled public Decimal ProjectAmountUsed {get;set;}
        @AuraEnabled public List<DepartmentForecastWrapper> DepList {get;set;}
        @AuraEnabled public List<BudgetForecastWrapper> budgetAccount {get;set;}
        public projectForecastWrapper(){
            Project = '';
            UnpostedEx = false;
            ProjectBudgetAmount = ProjectAmountUsed = ProjectConsumeAmount = ProjectCommittedAmount = 0;
            budgetAccount = new List<BudgetForecastWrapper>();
        }
    }
	
    public class DepartmentForecastWrapper{
        @AuraEnabled public String DepId {get;set;}
        @AuraEnabled public Decimal DepBudgetAmount {get;set;}
        @AuraEnabled public Decimal DepConsumeAmount {get;set;}
        @AuraEnabled public Decimal DepCommittedAmount {get;set;}
        @AuraEnabled public Decimal DepAmountUsed {get;set;}
        @AuraEnabled public List<BudgetForecastWrapper> budgetAccount {get;set;}
        
        public DepartmentForecastWrapper(){
            DepId = '';
            DepBudgetAmount = DepConsumeAmount = DepCommittedAmount = DepAmountUsed = 0;
            budgetAccount = new List<BudgetForecastWrapper>();
        }
    }    
    public class BudgetForecastWrapper{
        @AuraEnabled public String CoaId {get;set;}
        @AuraEnabled public String AccountType {get;set;}
        @AuraEnabled public String AccountNumber {get;set;}
        
        //attribute for monthly budget
        @AuraEnabled public Decimal budgetAmount {get;set;}
        @AuraEnabled public Decimal remainingAmount {get;set;}
        @AuraEnabled public Decimal committedAmount {get;set;}
        @AuraEnabled public Decimal consumedAmount {get;set;}
        @AuraEnabled public Decimal budgetUsed {get;set;}
        
        //attribute for querterly budget
        @AuraEnabled public Decimal Q1budgetAmount {get;set;}
        @AuraEnabled public Decimal Q1consumedAmount {get;set;}
        @AuraEnabled public Decimal Q1budgetUsed {get;set;}
        
        @AuraEnabled public Decimal Q2budgetAmount {get;set;}
        @AuraEnabled public Decimal Q2consumedAmount {get;set;}
        @AuraEnabled public Decimal Q2budgetUsed {get;set;}
        
        @AuraEnabled public Decimal Q3budgetAmount {get;set;}
        @AuraEnabled public Decimal Q3consumedAmount {get;set;}
        @AuraEnabled public Decimal Q3budgetUsed {get;set;}
        
        @AuraEnabled public Decimal Q4budgetAmount {get;set;}
        @AuraEnabled public Decimal Q4consumedAmount {get;set;}
        @AuraEnabled public Decimal Q4budgetUsed {get;set;}
        
        //attribute for yearly budget
        @AuraEnabled public Decimal janbudgetAmount {get;set;}
        @AuraEnabled public Decimal janconsumedAmount {get;set;}
        @AuraEnabled public Decimal janbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal febbudgetAmount {get;set;}
        @AuraEnabled public Decimal febconsumedAmount {get;set;}
        @AuraEnabled public Decimal febbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal marbudgetAmount {get;set;}
        @AuraEnabled public Decimal marconsumedAmount {get;set;}
        @AuraEnabled public Decimal marbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal aprbudgetAmount {get;set;}
        @AuraEnabled public Decimal aprconsumedAmount {get;set;}
        @AuraEnabled public Decimal aprbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal maybudgetAmount {get;set;}
        @AuraEnabled public Decimal mayconsumedAmount {get;set;}
        @AuraEnabled public Decimal maybudgetUsed {get;set;}
        
        @AuraEnabled public Decimal junbudgetAmount {get;set;}
        @AuraEnabled public Decimal junconsumedAmount {get;set;}
        @AuraEnabled public Decimal junbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal julbudgetAmount {get;set;}
        @AuraEnabled public Decimal julconsumedAmount {get;set;}
        @AuraEnabled public Decimal julbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal augbudgetAmount {get;set;}
        @AuraEnabled public Decimal augconsumedAmount {get;set;}
        @AuraEnabled public Decimal augbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal sepbudgetAmount {get;set;}
        @AuraEnabled public Decimal sepconsumedAmount {get;set;}
        @AuraEnabled public Decimal sepbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal octbudgetAmount {get;set;}
        @AuraEnabled public Decimal octconsumedAmount {get;set;}
        @AuraEnabled public Decimal octbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal novbudgetAmount {get;set;}
        @AuraEnabled public Decimal novconsumedAmount {get;set;}
        @AuraEnabled public Decimal novbudgetUsed {get;set;}
        
        @AuraEnabled public Decimal decbudgetAmount {get;set;}
        @AuraEnabled public Decimal decconsumedAmount {get;set;}
        @AuraEnabled public Decimal decbudgetUsed {get;set;}
        
        public BudgetForecastWrapper(){
            CoaId = AccountType = AccountNumber = '';
            
            //Attribute for monthly budget
            budgetAmount = consumedAmount = committedAmount = budgetUsed = 0;
            
			//attribute for querterly budget
			Q1budgetAmount = Q1consumedAmount = Q1budgetUsed = 0;   
            Q2budgetAmount = Q2consumedAmount = Q2budgetUsed = 0;   
            Q3budgetAmount = Q3consumedAmount = Q3budgetUsed = 0;   
            Q4budgetAmount = Q4consumedAmount = Q4budgetUsed = 0; 
            
            //attribute for yearly budget
            janbudgetAmount = janconsumedAmount = janbudgetUsed = 0; 
            febbudgetAmount = febconsumedAmount = febbudgetUsed = 0; 
            marbudgetAmount = marconsumedAmount = marbudgetUsed = 0; 
            aprbudgetAmount = aprconsumedAmount = aprbudgetUsed = 0; 
            maybudgetAmount = mayconsumedAmount = maybudgetUsed = 0; 
            junbudgetAmount = junconsumedAmount = junbudgetUsed = 0; 
            julbudgetAmount = julconsumedAmount = julbudgetUsed = 0; 
            augbudgetAmount = augconsumedAmount = augbudgetUsed = 0; 
            sepbudgetAmount = sepconsumedAmount = sepbudgetUsed = 0; 
            octbudgetAmount = octconsumedAmount = octbudgetUsed = 0; 
            novbudgetAmount = novconsumedAmount = novbudgetUsed = 0; 
            decbudgetAmount = decconsumedAmount = decbudgetUsed = 0; 
        }
    }  
    
    @AuraEnabled
    public static void submitRecordForApproval(Id recordId) {
        try {
            // Submit record for approval
            Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
            submitRequest.setObjectId(recordId);
            
            // Submit the approval request
            Approval.ProcessResult result = Approval.process(submitRequest);
            
            // Handle the result if needed
            if (!result.isSuccess()) {  throw new AuraHandledException('Error submitting for approval: ' + result.getErrors()[0].getMessage());
            }
        } catch(Exception e) {
            throw new AuraHandledException('Error submitting for approval: ' + e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static List<projectForecastWrapper> fetchMonthlyBudgetForecast(String OrgId, String BudgetId){
        List<projectForecastWrapper> pwrapList = new List<projectForecastWrapper>();
        Set<Id> coaIds = new Set<Id>();
        if(BudgetId!='' && BudgetId!=null){
            ERP7__Budget_Plan__c  bplan = [select Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__UnPosted_Actual_Expenditures__c  from ERP7__Budget_Plan__c where Id=:BudgetId];
            Date sDate = bplan.ERP7__Start_Date__c;
            Date eDate = bplan.ERP7__End_Date__c;
            Boolean unposted = bplan.ERP7__UnPosted_Actual_Expenditures__c;
            system.debug('unposted-->'+unposted);
            List<ERP7__Budget_Account__c> budgetAccountList = new List<ERP7__Budget_Account__c>();
            budgetAccountList = [select Id, ERP7__Committed_Amount__c , ERP7__Consumed_Amount__c, ERP7__Remaining_Amount__c , Name, ERP7__Project__c, ERP7__Account_Number__c, ERP7__Budget_Account_Category__c, ERP7__Amount__c, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.RecordTypeId, ERP7__Organisation__c from ERP7__Budget_Account__c where ERP7__Budget_Plan__c=:BudgetId and ERP7__Project__c	!=null];//ERP7__December_Budget__c, ERP7__November_Budget__c, ERP7__October_Budget__c, ERP7__September_Budget__c, ERP7__August_Budget__c, ERP7__July_Budget__c, ERP7__June_Budget__c, ERP7__May_Budget__c, ERP7__April_Budget__c,  ERP7__March_Budget__c, ERP7__January_Budget__c, ERP7__February_Budget__c, ERP7__First_Quarter_Amount__c, ERP7__Second_Quarter_Amount__c,ERP7__Third_Quarter_Amount__c, ERP7__Fourth_Quarter_Amount__c,
            if(budgetAccountList!=null && budgetAccountList.size()>0){
                Map<Id, List<ERP7__Budget_Account__c>> projBudgetMap = new Map<Id, List<ERP7__Budget_Account__c>>();
                for(ERP7__Budget_Account__c ba : budgetAccountList){
                    if(projBudgetMap.containskey(ba.ERP7__Project__c)){
                        projBudgetMap.get(ba.ERP7__Project__c).add(ba);
                    }else{
                        List<ERP7__Budget_Account__c> budtAccountList = new List<ERP7__Budget_Account__c>();
                        budtAccountList.add(ba);
                        projBudgetMap.put(ba.ERP7__Project__c, budtAccountList);
                    }
                }
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> projLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                if(!projBudgetMap.isEmpty() && projBudgetMap.size()>0 && !unposted){
                    Set<Id> projIds = new Set<Id>();
                    projIds = projBudgetMap.keyset();
                    List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                    fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: sDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: eDate];
                    system.debug('fgleList-->'+fgleList);
                    if(fgleList!=null && fgleList.size()>0){
                        for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){ String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                            if(projLedgerMap.containskey(mapkey)){ projLedgerMap.get(mapkey).add(fgle);
                            }else{
                                List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();  ledgerList.add(fgle);  projLedgerMap.put(mapkey, ledgerList);
                            }
                        }
                    }
                }
                if(!projBudgetMap.isEmpty() && projBudgetMap.size()>0 && !unposted){
                    for(String project : projBudgetMap.keyset()){
                        projectForecastWrapper pwrap = new projectForecastWrapper();
                        pwrap.Project = project;
                        Decimal projBudget = 0;
                        Decimal projConsume = 0;
                        List<BudgetForecastWrapper> bfrList = new List<BudgetForecastWrapper>();
                        for(ERP7__Budget_Account__c bac : projBudgetMap.get(project)){
                            BudgetForecastWrapper bfr = new BudgetForecastWrapper();
                            bfr.AccountType = bac.ERP7__Chart_of_Account__r.RecordType.DeveloperName;
                            bfr.CoaId = bac.ERP7__Chart_of_Account__c;
                            bfr.AccountNumber = bac.ERP7__Account_Number__c;
                            if(bac.ERP7__Amount__c!=null){
                                projBudget = projBudget + bac.ERP7__Amount__c;
                                bfr.budgetAmount = bac.ERP7__Amount__c;
                            }
                            Decimal consumeAmount = 0;
                            if(!projLedgerMap.isEmpty() && projLedgerMap.size()>0){
                                String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                system.debug('mapkey-->'+mapkey);
                                system.debug('projLedgerMap-->'+projLedgerMap.keySet());
                                if(projLedgerMap.containskey(mapkey)){
                                    for(ERP7__Finance_General_Ledger_Entry__c fgle : projLedgerMap.get(mapkey)){ consumeAmount = consumeAmount + fgle.ERP7__Debit_Entry__c;  projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                    }
                                }
                            }
                            bfr.consumedAmount = consumeAmount;
                            if(consumeAmount!=0) bfr.budgetUsed = ((consumeAmount/bac.ERP7__Amount__c)*100).setScale(2);
                            bfrList.add(bfr);
                        }
                        pwrap.ProjectBudgetAmount = projBudget;
                        pwrap.ProjectConsumeAmount = projConsume;
                        pwrap.ProjectAmountUsed = ((projConsume/projBudget)*100).setScale(2);
                        pwrap.budgetAccount = bfrList;
                        pwrapList.add(pwrap);
                    }
                }
                if(!projBudgetMap.isEmpty() && projBudgetMap.size()>0 && unposted){
                    for(String project : projBudgetMap.keyset()){
                        projectForecastWrapper pwrap = new projectForecastWrapper();
                        pwrap.Project = project;
                        pwrap.UnpostedEx = unposted;
                        Decimal projBudget = 0;
                        Decimal projConsume = 0;
                        Decimal projCommitted = 0;
                        List<BudgetForecastWrapper> bfrList = new List<BudgetForecastWrapper>();
                        for(ERP7__Budget_Account__c bac : projBudgetMap.get(project)){
                            BudgetForecastWrapper bfr = new BudgetForecastWrapper();
                            bfr.AccountType = bac.ERP7__Chart_of_Account__r.RecordType.DeveloperName;
                            bfr.CoaId = bac.ERP7__Chart_of_Account__c;
                            bfr.AccountNumber = bac.ERP7__Account_Number__c;
                            if(bac.ERP7__Amount__c!=null){
                                projBudget = projBudget + bac.ERP7__Amount__c;
                                bfr.budgetAmount = bac.ERP7__Amount__c;
                            }
                            if(bac.ERP7__Committed_Amount__c!=null){
                                projCommitted = projCommitted + bac.ERP7__Committed_Amount__c;
                                bfr.committedAmount = bac.ERP7__Committed_Amount__c;
                            }
                            if(bac.ERP7__Consumed_Amount__c!=null){
                                projConsume = projConsume + bac.ERP7__Consumed_Amount__c;
                                bfr.consumedAmount = bac.ERP7__Consumed_Amount__c;
                            }
                            bfr.remainingAmount = bac.ERP7__Remaining_Amount__c;
                            if(bac.ERP7__Remaining_Amount__c!=0) bfr.budgetUsed = (((bfr.committedAmount+bfr.consumedAmount)/bac.ERP7__Amount__c)*100).setScale(2);
                            bfrList.add(bfr);
                        }
                        pwrap.ProjectBudgetAmount = projBudget;
                        pwrap.ProjectConsumeAmount = projConsume;
                        pwrap.ProjectCommittedAmount = projCommitted;
                        pwrap.ProjectAmountUsed = (((projConsume+projCommitted)/projBudget)*100).setScale(2);
                        pwrap.budgetAccount = bfrList;
                        pwrapList.add(pwrap);
                    }
                }
            }
        }
        return pwrapList;
    }
    
    
    @AuraEnabled 
    public static List<projectForecastWrapper> fetchQuerterBudgetForecast(String OrgId, String BudgetId){
        List<projectForecastWrapper> pwrapList = new List<projectForecastWrapper>();
        Set<Id> coaIds = new Set<Id>();
        if(BudgetId!='' && BudgetId!=null){
            ERP7__Budget_Plan__c  bplan = [select Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c  from ERP7__Budget_Plan__c where Id=:BudgetId];
            Date sDate = bplan.ERP7__Start_Date__c;
            Date eDate = bplan.ERP7__End_Date__c;
            List<Period> periodlist = [Select Type, StartDate, EndDate From Period where Type = 'Quarter' and EndDate<:system.today().addyears(1) order by StartDate desc limit 4];
            Date q4SDate = periodlist[0].StartDate;
            Date q4EDate = periodlist[0].EndDate;
            Date q3SDate = periodlist[1].StartDate;
            Date q3EDate = periodlist[1].EndDate;
            Date q2SDate = periodlist[2].StartDate;
            Date q2EDate = periodlist[2].EndDate;
            Date q1SDate = periodlist[3].StartDate;
            Date q1EDate = periodlist[3].EndDate;
            List<ERP7__Budget_Account__c> budgetAccountList = new List<ERP7__Budget_Account__c>();
            budgetAccountList = [select Id, ERP7__First_Quarter_Amount__c, ERP7__Second_Quarter_Amount__c, ERP7__Third_Quarter_Amount__c, ERP7__Fourth_Quarter_Amount__c, Name, ERP7__Project__c, ERP7__Account_Number__c, ERP7__Budget_Account_Category__c, ERP7__Amount__c, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.RecordTypeId, ERP7__Organisation__c from ERP7__Budget_Account__c where ERP7__Budget_Plan__c=:BudgetId and ERP7__Project__c	!=null];//ERP7__December_Budget__c, ERP7__November_Budget__c, ERP7__October_Budget__c, ERP7__September_Budget__c, ERP7__August_Budget__c, ERP7__July_Budget__c, ERP7__June_Budget__c, ERP7__May_Budget__c, ERP7__April_Budget__c,  ERP7__March_Budget__c, ERP7__January_Budget__c, ERP7__February_Budget__c, ERP7__First_Quarter_Amount__c, ERP7__Second_Quarter_Amount__c,ERP7__Third_Quarter_Amount__c, ERP7__Fourth_Quarter_Amount__c,
            if(budgetAccountList!=null && budgetAccountList.size()>0){
                Map<Id, List<ERP7__Budget_Account__c>> projBudgetMap = new Map<Id, List<ERP7__Budget_Account__c>>();
                for(ERP7__Budget_Account__c ba : budgetAccountList){
                    if(projBudgetMap.containskey(ba.ERP7__Project__c)){
                        projBudgetMap.get(ba.ERP7__Project__c).add(ba);
                    }else{
                        List<ERP7__Budget_Account__c> budtAccountList = new List<ERP7__Budget_Account__c>();
                        budtAccountList.add(ba);
                        projBudgetMap.put(ba.ERP7__Project__c, budtAccountList);
                    }
                }
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> Q1projLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> Q2projLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> Q3projLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> Q4projLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                if(!projBudgetMap.isEmpty() && projBudgetMap.size()>0){
                    Set<Id> projIds = new Set<Id>();
                    projIds = projBudgetMap.keyset();
                    system.debug('projIds-->'+projIds);
                    system.debug('q1SDate-->'+q1SDate);
                    system.debug('q1EDate-->'+q1EDate);
                    List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                    fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: q4SDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: q4EDate];
                    system.debug('fgleList-->'+fgleList);
                    if(fgleList!=null && fgleList.size()>0){
                        for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                            String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                            if(Q4projLedgerMap.containskey(mapkey)){
                                Q4projLedgerMap.get(mapkey).add(fgle);
                            }else{
                                List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                ledgerList.add(fgle);
                                Q4projLedgerMap.put(mapkey, ledgerList);
                            }
                        }
                    }
                    
                    
                    // q3
                    fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: q3SDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: q3EDate];
                    system.debug('fgleList-->'+fgleList);
                    if(fgleList!=null && fgleList.size()>0){
                        for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                            String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                            if(Q3projLedgerMap.containskey(mapkey)){
                                Q3projLedgerMap.get(mapkey).add(fgle);
                            }else{
                                List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                ledgerList.add(fgle);
                                Q3projLedgerMap.put(mapkey, ledgerList);
                            }
                        }
                    }
                    
                    // q2
                    fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: q2SDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: q2EDate];
                    system.debug('fgleList-->'+fgleList);
                    if(fgleList!=null && fgleList.size()>0){
                        for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){ String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                            if(Q2projLedgerMap.containskey(mapkey)){  Q2projLedgerMap.get(mapkey).add(fgle);
                            }else{
                                List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                ledgerList.add(fgle); Q2projLedgerMap.put(mapkey, ledgerList);
                            }
                        }
                    }
                    
                    // q1
                    fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: q1SDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: q1EDate];
                    system.debug('fgleList-->'+fgleList);
                    if(fgleList!=null && fgleList.size()>0){
                        for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){ String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                            if(Q1projLedgerMap.containskey(mapkey)){  Q1projLedgerMap.get(mapkey).add(fgle);
                            }else{
                                List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();ledgerList.add(fgle);
                                Q1projLedgerMap.put(mapkey, ledgerList);
                            }
                        }
                    }
                }
                if(!projBudgetMap.isEmpty() && projBudgetMap.size()>0){
                    for(String project : projBudgetMap.keyset()){
                        projectForecastWrapper pwrap = new projectForecastWrapper();
                        pwrap.Project = project;
                        Decimal projBudget = 0;
                        Decimal projConsume = 0;
                        List<BudgetForecastWrapper> bfrList = new List<BudgetForecastWrapper>();
                        for(ERP7__Budget_Account__c bac : projBudgetMap.get(project)){
                            BudgetForecastWrapper bfr = new BudgetForecastWrapper();
                            bfr.AccountType = bac.ERP7__Chart_of_Account__r.RecordType.DeveloperName;
                            bfr.CoaId = bac.ERP7__Chart_of_Account__c;
                            bfr.AccountNumber = bac.ERP7__Account_Number__c;
                            Decimal totalQuarter = 0;
                            if(bac.ERP7__First_Quarter_Amount__c!=null){
                                projBudget = projBudget + bac.ERP7__First_Quarter_Amount__c;
                                bfr.Q1budgetAmount = bac.ERP7__First_Quarter_Amount__c;
                                totalQuarter += bac.ERP7__First_Quarter_Amount__c;
                            }
                            if(bac.ERP7__Second_Quarter_Amount__c!=null){
                                projBudget = projBudget + bac.ERP7__Second_Quarter_Amount__c;
                                bfr.Q2budgetAmount = bac.ERP7__Second_Quarter_Amount__c;
                                totalQuarter += bac.ERP7__Second_Quarter_Amount__c;
                            }
                            if(bac.ERP7__Third_Quarter_Amount__c!=null){
                                projBudget = projBudget + bac.ERP7__Third_Quarter_Amount__c;
                                bfr.Q3budgetAmount = bac.ERP7__Third_Quarter_Amount__c;
                                totalQuarter += bac.ERP7__Third_Quarter_Amount__c;
                            }
                            if(bac.ERP7__Fourth_Quarter_Amount__c!=null){
                                projBudget = projBudget + bac.ERP7__Fourth_Quarter_Amount__c;
                                bfr.Q4budgetAmount = bac.ERP7__Fourth_Quarter_Amount__c;
                                totalQuarter += bac.ERP7__Fourth_Quarter_Amount__c;
                            }
                            Decimal q1consumeAmount = 0;
                            if(!Q1projLedgerMap.isEmpty() && Q1projLedgerMap.size()>0){
                                String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                system.debug('mapkey-->'+mapkey);
                                system.debug('Q1projLedgerMap-->'+Q1projLedgerMap.keySet());
                                if(Q1projLedgerMap.containskey(mapkey)){
                                    for(ERP7__Finance_General_Ledger_Entry__c fgle : Q1projLedgerMap.get(mapkey)){
                                        q1consumeAmount = q1consumeAmount + fgle.ERP7__Debit_Entry__c;
                                        projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                    }
                                }
                            }
                            bfr.Q1consumedAmount = q1consumeAmount;
                            if(q1consumeAmount!=0) bfr.Q1budgetUsed = ((bfr.Q1consumedAmount/bfr.Q1budgetAmount)*100).setScale(2);
                            
                            
                            Decimal q2consumeAmount = 0;
                            if(!Q2projLedgerMap.isEmpty() && Q2projLedgerMap.size()>0){
                                String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                system.debug('mapkey-->'+mapkey);
                                system.debug('Q2projLedgerMap-->'+Q2projLedgerMap.keySet());
                                if(Q2projLedgerMap.containskey(mapkey)){
                                    for(ERP7__Finance_General_Ledger_Entry__c fgle : Q2projLedgerMap.get(mapkey)){
                                        q2consumeAmount = q2consumeAmount + fgle.ERP7__Debit_Entry__c;
                                        projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                    }
                                }
                            }
                            bfr.Q2consumedAmount = q2consumeAmount;
                            if(q2consumeAmount!=0) bfr.Q2budgetUsed = ((bfr.Q2consumedAmount/bfr.Q2budgetAmount)*100).setScale(2);
                            
                            Decimal q3consumeAmount = 0;
                            if(!Q3projLedgerMap.isEmpty() && Q3projLedgerMap.size()>0){
                                String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                system.debug('mapkey-->'+mapkey);
                                system.debug('Q3projLedgerMap-->'+Q3projLedgerMap.keySet());
                                if(Q3projLedgerMap.containskey(mapkey)){
                                    for(ERP7__Finance_General_Ledger_Entry__c fgle : Q3projLedgerMap.get(mapkey)){
                                        q3consumeAmount = q3consumeAmount + fgle.ERP7__Debit_Entry__c;
                                        projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                    }
                                }
                            }
                            bfr.Q3consumedAmount = q3consumeAmount;
                            if(q3consumeAmount!=0) bfr.Q3budgetUsed = ((bfr.Q3consumedAmount/bfr.Q3budgetAmount)*100).setScale(2);
                            
                            Decimal q4consumeAmount = 0;
                            if(!Q4projLedgerMap.isEmpty() && Q4projLedgerMap.size()>0){
                                String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                system.debug('mapkey-->'+mapkey);
                                system.debug('Q4projLedgerMap-->'+Q4projLedgerMap.keySet());
                                if(Q4projLedgerMap.containskey(mapkey)){
                                    for(ERP7__Finance_General_Ledger_Entry__c fgle : Q4projLedgerMap.get(mapkey)){
                                        q4consumeAmount = q4consumeAmount + fgle.ERP7__Debit_Entry__c;
                                        projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                    }
                                }
                            }
                            bfr.Q4consumedAmount = q4consumeAmount;
                            if(q4consumeAmount!=0) bfr.Q4budgetUsed = ((bfr.Q4consumedAmount/bfr.Q4budgetAmount)*100).setScale(2);
                            
                            bfrList.add(bfr);
                        }
                        pwrap.ProjectBudgetAmount = projBudget;
                        pwrap.ProjectConsumeAmount = projConsume;
                        pwrap.ProjectAmountUsed = ((projConsume/projBudget)*100).setScale(2);
                        pwrap.budgetAccount = bfrList;
                        pwrapList.add(pwrap);
                    }
                }
            }
        }
        return pwrapList;
    }
    
    
    @AuraEnabled 
    public static List<projectForecastWrapper> fetchYearBudgetForecast(String OrgId, String BudgetId){
        List<projectForecastWrapper> pwrapList = new List<projectForecastWrapper>();
        Set<Id> coaIds = new Set<Id>();
        if(BudgetId!='' && BudgetId!=null){
            ERP7__Budget_Plan__c  bplan = [select Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c  from ERP7__Budget_Plan__c where Id=:BudgetId];
            Date sDate = bplan.ERP7__Start_Date__c;
            Date eDate = bplan.ERP7__End_Date__c;
            
            List<ERP7__Budget_Account__c> budgetAccountList = new List<ERP7__Budget_Account__c>();
            budgetAccountList = [select Id, ERP7__December_Budget__c, ERP7__November_Budget__c, ERP7__October_Budget__c, ERP7__September_Budget__c, ERP7__August_Budget__c, ERP7__July_Budget__c, ERP7__June_Budget__c, ERP7__May_Budget__c, ERP7__April_Budget__c,  ERP7__March_Budget__c, ERP7__January_Budget__c, ERP7__February_Budget__c, ERP7__First_Quarter_Amount__c, ERP7__Second_Quarter_Amount__c, ERP7__Third_Quarter_Amount__c, ERP7__Fourth_Quarter_Amount__c, Name, ERP7__Project__c, ERP7__Account_Number__c, ERP7__Budget_Account_Category__c, ERP7__Amount__c, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.RecordTypeId, ERP7__Organisation__c from ERP7__Budget_Account__c where ERP7__Budget_Plan__c=:BudgetId and ERP7__Project__c	!=null];//ERP7__December_Budget__c, ERP7__November_Budget__c, ERP7__October_Budget__c, ERP7__September_Budget__c, ERP7__August_Budget__c, ERP7__July_Budget__c, ERP7__June_Budget__c, ERP7__May_Budget__c, ERP7__April_Budget__c,  ERP7__March_Budget__c, ERP7__January_Budget__c, ERP7__February_Budget__c, ERP7__First_Quarter_Amount__c, ERP7__Second_Quarter_Amount__c,ERP7__Third_Quarter_Amount__c, ERP7__Fourth_Quarter_Amount__c,
            if(budgetAccountList!=null && budgetAccountList.size()>0){
                Map<Id, List<ERP7__Budget_Account__c>> projBudgetMap = new Map<Id, List<ERP7__Budget_Account__c>>();
                for(ERP7__Budget_Account__c ba : budgetAccountList){
                    if(projBudgetMap.containskey(ba.ERP7__Project__c)){
                        projBudgetMap.get(ba.ERP7__Project__c).add(ba);
                    }else{
                        List<ERP7__Budget_Account__c> budtAccountList = new List<ERP7__Budget_Account__c>();
                        budtAccountList.add(ba);
                        projBudgetMap.put(ba.ERP7__Project__c, budtAccountList);
                    }
                }
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> janprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> febprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> marprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> aprprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> mayprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> junprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> julprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> augprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> sepprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> octprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> novprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                Map<String, List<ERP7__Finance_General_Ledger_Entry__c>> decprojLedgerMap = new Map<String, List<ERP7__Finance_General_Ledger_Entry__c>>();
                
                if(!projBudgetMap.isEmpty() && projBudgetMap.size()>0){
                    Set<Id> projIds = new Set<Id>();
                    projIds = projBudgetMap.keyset();
                    system.debug('projIds-->'+projIds);
                    Integer year = 2024;
                    for (Integer month = 1; month <= 12; month++) {
                        Date startDate = Date.newInstance(year, month, 1);
                        Date endDate = startDate.addMonths(1).addDays(-1);
                        if(month==1){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                                    String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(janprojLedgerMap.containskey(mapkey)){
                                        janprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                        ledgerList.add(fgle);
                                        janprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        if(month==2){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                                    String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(febprojLedgerMap.containskey(mapkey)){
                                        febprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                        ledgerList.add(fgle);
                                        febprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //March
                        if(month==3){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                                    String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(marprojLedgerMap.containskey(mapkey)){
                                        marprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                        ledgerList.add(fgle);
                                        marprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //April
                        if(month==4){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                                    String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(aprprojLedgerMap.containskey(mapkey)){
                                        aprprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                        ledgerList.add(fgle);
                                        aprprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //May
                        if(month==5){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                                    String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(mayprojLedgerMap.containskey(mapkey)){
                                        mayprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                        ledgerList.add(fgle);
                                        mayprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //June
                        if(month==6){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                                    String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(junprojLedgerMap.containskey(mapkey)){
                                        junprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                        ledgerList.add(fgle);
                                        junprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //July
                        if(month==7){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){
                                    String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(julprojLedgerMap.containskey(mapkey)){
                                        julprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                                        ledgerList.add(fgle);
                                        julprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //August
                        if(month==8){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){ String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(augprojLedgerMap.containskey(mapkey)){ augprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();ledgerList.add(fgle);  augprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //September
                        if(month==9){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){ String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(sepprojLedgerMap.containskey(mapkey)){ sepprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>(); ledgerList.add(fgle); sepprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //October
                        if(month==10){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){ String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(octprojLedgerMap.containskey(mapkey)){ octprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>(); ledgerList.add(fgle); octprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //November
                        if(month==11){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){ String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(novprojLedgerMap.containskey(mapkey)){ novprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>(); ledgerList.add(fgle); novprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                        //December
                        if(month==12){
                            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            fgleList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Project__c, ERP7__Transactions__r.ERP7__Project__r.Name  from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Project__c IN :projIds AND ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: startDate AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: endDate];
                            system.debug('fgleList-->'+fgleList);
                            if(fgleList!=null && fgleList.size()>0){
                                for(ERP7__Finance_General_Ledger_Entry__c fgle : fgleList){ String mapkey = String.valueOf(fgle.ERP7__Transactions__r.ERP7__Project__c) + fgle.ERP7__Chart_of_Account__c;
                                    if(decprojLedgerMap.containskey(mapkey)){ decprojLedgerMap.get(mapkey).add(fgle);
                                    }else{
                                        List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();  ledgerList.add(fgle); decprojLedgerMap.put(mapkey, ledgerList);
                                    }
                                }
                            }
                        }
                    }
                }
                if(!projBudgetMap.isEmpty() && projBudgetMap.size()>0){
                    for(String project : projBudgetMap.keyset()){
                        projectForecastWrapper pwrap = new projectForecastWrapper();
                        pwrap.Project = project;
                        Decimal projBudget = 0;
                        Decimal projConsume = 0;
                        List<BudgetForecastWrapper> bfrList = new List<BudgetForecastWrapper>();
                        for(ERP7__Budget_Account__c bac : projBudgetMap.get(project)){
                            BudgetForecastWrapper bfr = new BudgetForecastWrapper();
                            bfr.AccountType = bac.ERP7__Chart_of_Account__r.RecordType.DeveloperName;
                            bfr.CoaId = bac.ERP7__Chart_of_Account__c;
                            bfr.AccountNumber = bac.ERP7__Account_Number__c;
                            Decimal totalQuarter = 0;
                            if(bac.ERP7__January_Budget__c!=null){  projBudget = projBudget + bac.ERP7__January_Budget__c; bfr.janbudgetAmount = bac.ERP7__January_Budget__c;
                                if(!janprojLedgerMap.isEmpty() && janprojLedgerMap.size()>0){ String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(janprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : janprojLedgerMap.get(mapkey)){   bfr.janconsumedAmount = bfr.janconsumedAmount + fgle.ERP7__Debit_Entry__c;  projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.janbudgetUsed = ((bfr.janconsumedAmount/bfr.janbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //February
                            if(bac.ERP7__February_Budget__c!=null){ projBudget = projBudget + bac.ERP7__February_Budget__c;  bfr.febbudgetAmount = bac.ERP7__February_Budget__c;
                                if(!febprojLedgerMap.isEmpty() && febprojLedgerMap.size()>0){  String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(febprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : febprojLedgerMap.get(mapkey)){ bfr.febconsumedAmount = bfr.febconsumedAmount + fgle.ERP7__Debit_Entry__c; projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.febbudgetUsed = ((bfr.febconsumedAmount/bfr.febbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //March
                            if(bac.ERP7__March_Budget__c!=null){  projBudget = projBudget + bac.ERP7__March_Budget__c;  bfr.marbudgetAmount = bac.ERP7__March_Budget__c;
                                if(!marprojLedgerMap.isEmpty() && marprojLedgerMap.size()>0){ String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(marprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : marprojLedgerMap.get(mapkey)){  bfr.marconsumedAmount = bfr.marconsumedAmount + fgle.ERP7__Debit_Entry__c; projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.marbudgetUsed = ((bfr.marconsumedAmount/bfr.marbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //April
                            if(bac.ERP7__April_Budget__c!=null){ projBudget = projBudget + bac.ERP7__April_Budget__c; bfr.aprbudgetAmount = bac.ERP7__April_Budget__c;
                                if(!aprprojLedgerMap.isEmpty() && aprprojLedgerMap.size()>0){ String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(aprprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : aprprojLedgerMap.get(mapkey)){  bfr.aprconsumedAmount = bfr.aprconsumedAmount + fgle.ERP7__Debit_Entry__c; projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.aprbudgetUsed = ((bfr.aprconsumedAmount/bfr.aprbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //May
                            if(bac.ERP7__May_Budget__c!=null){  projBudget = projBudget + bac.ERP7__May_Budget__c; bfr.maybudgetAmount = bac.ERP7__May_Budget__c;
                                if(!mayprojLedgerMap.isEmpty() && mayprojLedgerMap.size()>0){  String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(mayprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : mayprojLedgerMap.get(mapkey)){ bfr.mayconsumedAmount = bfr.mayconsumedAmount + fgle.ERP7__Debit_Entry__c; projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.maybudgetUsed = ((bfr.mayconsumedAmount/bfr.maybudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //June
                            if(bac.ERP7__June_Budget__c!=null){ projBudget = projBudget + bac.ERP7__June_Budget__c; bfr.junbudgetAmount = bac.ERP7__June_Budget__c;
                                if(!junprojLedgerMap.isEmpty() && junprojLedgerMap.size()>0){ String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(junprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : junprojLedgerMap.get(mapkey)){   bfr.junconsumedAmount = bfr.junconsumedAmount + fgle.ERP7__Debit_Entry__c;  projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.junbudgetUsed = ((bfr.junconsumedAmount/bfr.junbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //July
                            if(bac.ERP7__July_Budget__c!=null){ projBudget = projBudget + bac.ERP7__July_Budget__c;  bfr.julbudgetAmount = bac.ERP7__July_Budget__c;
                                if(!julprojLedgerMap.isEmpty() && julprojLedgerMap.size()>0){ String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(julprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : julprojLedgerMap.get(mapkey)){ bfr.julconsumedAmount = bfr.julconsumedAmount + fgle.ERP7__Debit_Entry__c; projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.junbudgetUsed = ((bfr.julconsumedAmount/bfr.julbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //August
                            if(bac.ERP7__August_Budget__c!=null){ projBudget = projBudget + bac.ERP7__August_Budget__c;  bfr.julbudgetAmount = bac.ERP7__August_Budget__c;
                                if(!augprojLedgerMap.isEmpty() && augprojLedgerMap.size()>0){ String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(augprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : augprojLedgerMap.get(mapkey)){ bfr.augconsumedAmount = bfr.augconsumedAmount + fgle.ERP7__Debit_Entry__c;  projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.augbudgetUsed = ((bfr.augconsumedAmount/bfr.augbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //September
                            if(bac.ERP7__September_Budget__c!=null){ projBudget = projBudget + bac.ERP7__September_Budget__c; bfr.sepbudgetAmount = bac.ERP7__September_Budget__c;
                                if(!sepprojLedgerMap.isEmpty() && sepprojLedgerMap.size()>0){  String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(sepprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : sepprojLedgerMap.get(mapkey)){ bfr.sepconsumedAmount = bfr.sepconsumedAmount + fgle.ERP7__Debit_Entry__c; projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.sepbudgetUsed = ((bfr.sepconsumedAmount/bfr.sepbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //October
                            if(bac.ERP7__October_Budget__c!=null){projBudget = projBudget + bac.ERP7__October_Budget__c;  bfr.octbudgetAmount = bac.ERP7__October_Budget__c;
                                if(!octprojLedgerMap.isEmpty() && octprojLedgerMap.size()>0){ String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(octprojLedgerMap.containskey(mapkey)){
                                        for(ERP7__Finance_General_Ledger_Entry__c fgle : octprojLedgerMap.get(mapkey)){ bfr.octconsumedAmount = bfr.octconsumedAmount + fgle.ERP7__Debit_Entry__c;  projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.octbudgetUsed = ((bfr.octconsumedAmount/bfr.octbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //November
                            if(bac.ERP7__November_Budget__c!=null){ projBudget = projBudget + bac.ERP7__November_Budget__c; bfr.novbudgetAmount = bac.ERP7__November_Budget__c;
                                if(!novprojLedgerMap.isEmpty() && novprojLedgerMap.size()>0){String mapkey = project + bac.ERP7__Chart_of_Account__c; system.debug('mapkey-->'+mapkey);
                                    if(novprojLedgerMap.containskey(mapkey)){ for(ERP7__Finance_General_Ledger_Entry__c fgle : novprojLedgerMap.get(mapkey)){  bfr.novconsumedAmount = bfr.novconsumedAmount + fgle.ERP7__Debit_Entry__c; projConsume = projConsume + fgle.ERP7__Debit_Entry__c; } 
                                                                            }
                                    bfr.novbudgetUsed = ((bfr.novconsumedAmount/bfr.novbudgetAmount)*100).setScale(2);
                                }
                            }
                            
                            //December
                            if(bac.ERP7__December_Budget__c!=null){ projBudget = projBudget + bac.ERP7__December_Budget__c; bfr.decbudgetAmount = bac.ERP7__December_Budget__c;
                                if(!decprojLedgerMap.isEmpty() && decprojLedgerMap.size()>0){
                                    String mapkey = project + bac.ERP7__Chart_of_Account__c;
                                    system.debug('mapkey-->'+mapkey);
                                    if(decprojLedgerMap.containskey(mapkey)){ for(ERP7__Finance_General_Ledger_Entry__c fgle : decprojLedgerMap.get(mapkey)){ bfr.decconsumedAmount = bfr.decconsumedAmount + fgle.ERP7__Debit_Entry__c; projConsume = projConsume + fgle.ERP7__Debit_Entry__c;
                                        }
                                    }
                                    bfr.decbudgetUsed = ((bfr.decconsumedAmount/bfr.decbudgetAmount)*100).setScale(2);
                                }
                            }
                            bfrList.add(bfr);
                        }
                        pwrap.ProjectBudgetAmount = projBudget;
                        pwrap.ProjectConsumeAmount = projConsume;
                        pwrap.ProjectAmountUsed = (projBudget > 0 && projConsume > 0) ? ((projConsume/projBudget)*100).setScale(2) : 0; // added shaguftha 17_04_24 greater than 0 validation to avoid System.MathException: Divide by 0	
                        pwrap.budgetAccount = bfrList;
                        pwrapList.add(pwrap);
                    }
                }
            }
        }
        return pwrapList;
    }
    
}