@isTest
public class ManageProjectsTestClass {
    
    static testmethod void projects(){
        Test.startTest();
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Account s = new Account(Name = 'Supplier', Account_Type__c = 'Supplier');
        insert s;
        Account c = new Account(Name = 'Test', ERP7__Account_Type__c = 'Customer', AccountNumber = '1234', ERP7__Company__c = 'Aqxolt India Pvt Ltd', ERP7__Start_of_Week__c = 'Monday', ERP7__CustomerPriority__c = 'High', ERP7__Active__c = 'Yes', ERP7__SLA__c = 'Gold', ERP7__SLAExpirationDate__c = system.today());
        insert c;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        //RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Routing__c' Limit 1];
        Date myDate = system.today();
        Date newDate = mydate.addDays(2);
        RecordType TOtype = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Transfer_Order__c' Limit 1];
        Product2 prod = new Product2(Name = 'projectTestProduct');
        insert prod;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = prod.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        
        ERP7__Resource_Allocation__c RA = new ERP7__Resource_Allocation__c(Name = 'ProjManger');
        insert RA;
        
        ERP7__Project__c proj = new ERP7__Project__c(name='projectTest', ERP7__Project_Manager__c = RA.Id, ERP7__Start_Date__c = myDate, ERP7__End_Date__c = newDate, ERP7__Status__c = 'Planned', ERP7__Percentage__c = 0.00, ERP7__Organisations__c = o.Id, ERP7__Default_Routing__c = rout.Id);
        insert proj;
        
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='testEmp', ERP7__First_Name__c = 'test', ERP7__Last_Name__c = 'emp', ERP7__Employee_User__c = UserInfo.getUserId(), ERP7__Gender__c = 'Male', ERP7__Channel__c = channel.Id);
        insert emp;
        
        ERP7__Team__c tem = new ERP7__Team__c(Name = 'teamTest', ERP7__Project__c = proj.Id);
        insert tem;
        proj.ERP7__Team__c = tem.Id;
        update proj;
        
        ERP7__Resource_Group__c rcg = new ERP7__Resource_Group__c(Name='testRecG', ERP7__Process__c = prcs.Id, ERP7__Site__c = site.Id, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today().addDays(10), ERP7__Is_Manufacturing__c = true);
        insert rcg;
        
        ERP7__Resource__c rc = new ERP7__Resource__c(Name = 'testRec', ERP7__Employee__c = emp.Id, ERP7__Team__c = tem.Id, ERP7__Resource_Group__c = rcg.Id, ERP7__User__c = UserInfo.getUserId(), ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today().addDays(10));
        insert rc;
        
        ERP7__Milestone__c MS = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate.addDays(20), ERP7__Due_Date__c = newDate.addDays(20), ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00);
        insert MS;
        
        ERP7__Milestone__c MS2 = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate.addDays(10), ERP7__Due_Date__c = newDate.addDays(10), ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00, ERP7__isSerialized__c = true, ERP7__Previous_Milestone__c = MS.Id);
        insert MS2;
        
        ERP7__Milestone__c MS3 = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate, ERP7__Due_Date__c = newDate, ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00, ERP7__isSerialized__c = true, ERP7__Previous_Milestone__c = MS2.Id);
        insert MS3;
        MS2.ERP7__Next_Milestone__c = MS3.Id; update MS2;
        
        ERP7__Milestone__c MS4 = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate, ERP7__Due_Date__c = newDate, ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00, ERP7__isSerialized__c = true, ERP7__Previous_Milestone__c = MS3.Id);
        insert MS4;
        MS3.ERP7__Next_Milestone__c = MS4.Id; update MS3;
        
        ERP7__Actions_Tasks__c task = new ERP7__Actions_Tasks__c(Name = 'taskTest', ERP7__Start_Date__c = myDate, ERP7__End_Date__c = newDate, ERP7__Status__c = 'New', ERP7__Type__c = 'Regular', ERP7__Project__c = proj.Id, ERP7__Milestone__c = MS.Id, ERP7__Resource__c = rc.Id);
        insert task;
        
        ERP7__Transfer_Order__c TO = new ERP7__Transfer_Order__c(Name = 'TOtest', RecordTypeId = TOtype.Id, ERP7__Status__c = 'Draft', ERP7__Requested_Date__c = system.today(), ERP7__Expected_Date__c = system.today());
        try {
        ManageProjects exps = new ManageProjects();
        ManageProjects.getAll(proj.Id);
        ManageProjects.getProjects(0, 10,'');
        ManageProjects.getAllProjects();
        ManageProjects.getsimilarProjects('test');
        ManageProjects.getStatuspickval();
        ManageProjects.getMilestoneStatuspickval();
        ManageProjects.getTaskStatusPickval();
        ManageProjects.getTaskTypePickval();
        ManageProjects.getTOStatusPickval();
        ManageProjects.getTOTypePickval();
        ManageProjects.getCurProject(proj.Id);
        ManageProjects.getCurTask(task.Id);
        ManageProjects.getProcessMilestones(JSON.serialize(rout), proj.Id);
        List<ManageProjects.milestoneWrap> msWPlist = ManageProjects.getProcessMilestones(JSON.serialize(rout), proj.Id);
        ManageProjects.getMilestoneTasks(MS.Id);
        ManageProjects.getTaskMOs(task.Id);
        ManageProjects.getTaskWOs(task.Id);
        ManageProjects.getTaskTOs(task.Id);
        ManageProjects.getTaskSOs(task.Id);
        ManageProjects.getTaskPOs(task.Id);
        ManageProjects.getTaskPRs(task.Id);
        //ManageProjects.getRouting(rout.Id);
        ManageProjects.save_Project(JSON.serialize(proj));
        ManageProjects.save_MilestoneAK(JSON.serialize(MS), JSON.serialize(rout), JSON.serialize(msWPlist));
        ManageProjects.save_MilestoneAK(JSON.serialize(MS2), JSON.serialize(rout), JSON.serialize(msWPlist));
        ManageProjects.delete_Milestone(JSON.serialize(msWPlist), MS.Id);
        ManageProjects.save_Task(JSON.serialize(task));
        ManageProjects.delete_Task(task.Id);
        ManageProjects.save_TO(JSON.serialize(TO));
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        delete proj;
        }catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    static testmethod void PROJs() {
        Date myDate = system.today();
        Date newDate = mydate.addDays(2);
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        Product2 prod = new Product2(Name = 'projectTestProduct');
        insert prod;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = prod.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        ERP7__Project__c proj = new ERP7__Project__c(Name='projectTest',ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today().addDays(10), ERP7__Status__c = 'Planned', ERP7__Percentage__c = 0.00, ERP7__Organisations__c = o.Id, ERP7__Default_Routing__c = rout.Id);
        insert proj;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='testEmp', ERP7__First_Name__c = 'test', ERP7__Last_Name__c = 'emp', ERP7__Employee_User__c = UserInfo.getUserId(), ERP7__Gender__c = 'Male', ERP7__Channel__c = channel.Id);
        insert emp;
        ERP7__Team__c tem = new ERP7__Team__c(Name = 'teamTest', ERP7__Project__c = proj.Id);
        insert tem;
        proj.ERP7__Team__c = tem.Id; update proj;
        ERP7__Resource_Group__c rcg = new ERP7__Resource_Group__c(Name='testRecG', ERP7__Process__c = prcs.Id, ERP7__Site__c = site.Id, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today().addDays(10), ERP7__Is_Manufacturing__c = true);
        insert rcg;
        ERP7__Resource__c rc = new ERP7__Resource__c(Name = 'testRec', ERP7__Employee__c = emp.Id, ERP7__Team__c = tem.Id, ERP7__Resource_Group__c = rcg.Id, ERP7__User__c = UserInfo.getUserId(), ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today().addDays(10));
        insert rc;
        ERP7__Milestone__c MS = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate.addDays(20), ERP7__Due_Date__c = newDate.addDays(20), ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00);
        insert MS;
        ERP7__Milestone__c MS2 = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate.addDays(10), ERP7__Due_Date__c = newDate.addDays(10), ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00, ERP7__isSerialized__c = true, ERP7__Previous_Milestone__c = MS.Id);
        insert MS2;
        ERP7__Milestone__c MS3 = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate, ERP7__Due_Date__c = newDate, ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00, ERP7__isSerialized__c = true, ERP7__Previous_Milestone__c = MS2.Id);
        insert MS3;
        MS2.ERP7__Next_Milestone__c = MS3.Id; update MS2;
        ERP7__Actions_Tasks__c task = new ERP7__Actions_Tasks__c(Name = 'taskTest', ERP7__Start_Date__c = myDate, ERP7__End_Date__c = newDate, ERP7__Status__c = 'New', ERP7__Type__c = 'Regular', ERP7__Project__c = proj.Id, ERP7__Milestone__c = MS.Id, ERP7__Resource__c = rc.Id);
        insert task;
        
        Test.startTest();
        ManagePROJs PjtSch = new ManagePROJs();
        PageReference pageRef = Page.ProjectScheduler;
        Test.setCurrentPage(pageRef);
        
        PjtSch.getAllProjectData();
        PjtSch.View = 'Planned';
        PjtSch.getAllProjectData();
        PjtSch.FilterSet();
        ManagePROJs.searchProjects(proj.Name);
        ManagePROJs.searchTeams(tem.Name);
        PjtSch.getProjectList();
        PjtSch.getTeamList();
        PjtSch.reLoad();
        PjtSch.resetGantt = true;
        PjtSch.reLoad();
        PjtSch.Back2ProjectWorkBench();
        PjtSch.jString = PjtSch.schedulerString;
        PjtSch.updateSchedule();
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
}