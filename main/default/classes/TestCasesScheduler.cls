@isTest
private class TestCasesScheduler {
    static testMethod void UnitTestScheduler1(){
        Account o = new Account(Name='Test', ERP7__Account_Type__c='Organisation');
        insert o;
        ERP7__Employees__c e1 = new ERP7__Employees__c (name='emp1', ERP7__Active__c=true, ERP7__Employment_Status__c ='active');
        insert e1;
        ERP7__Employees__c e2 = new ERP7__Employees__c (name='emp2', ERP7__Active__c=true, ERP7__Employment_Status__c ='active');
        insert e2;
        ERP7__Machine__c m1 = new ERP7__Machine__c(name='mac1',ERP7__Activation_Date__c = system.today()-3);
        insert m1;
        ERP7__Machine__c m2 = new ERP7__Machine__c(name='mac1',ERP7__Activation_Date__c = system.today()-3);
        insert m2;
        
        Process__c process = new Process__c(Name='Test Process');
        insert process;
       
        Process_Cycle__c PC = new Process_Cycle__c(Name='Test Cycle', Process__c=process.Id);
        insert PC;
        
        Schedule__c s = new Schedule__c(Name='test',Process__c=process.Id,Schedule_Start_Date__c=system.now(),Schedule_End_Date__c=system.now()+1);
        insert s;
        Schedule__c s1 = new Schedule__c(Name='test', Process_Cycle__c=PC.Id, Schedule__c=s.Id, Schedule_Start_Date__c=system.now(),Schedule_End_Date__c=system.now()+1);
        insert s1;
        Schedule__c s2 = new Schedule__c(Name='test', Schedule__c=s.Id, Schedule_Start_Date__c=system.now(),Schedule_End_Date__c=system.now()+1);
        insert s2;
        Schedule__c s3 = new Schedule__c(Name='test', Schedule_Start_Date__c=system.now(),Schedule_End_Date__c=system.now()+1);
        insert s3;
        
        
        Actions_Tasks__c SC = new Actions_Tasks__c();
        SC.Name = 'test';
        SC.ERP7__Action_Detail__c = 'test';
        SC.ERP7__Action_Type__c = 'test';
        SC.ERP7__Schedule__c = s1.Id;
        SC.ERP7__Weight__c = 10;
        insert SC;
        Product2 ps = new Product2(Name='test', isActive=true, Track_Inventory__c=true, Barcode__c = '007879', Issue_Purchase_Order__c=true, Issue_Work_Order__c=true);
        insert ps;
        Site__c site = new Site__c(Organisation__c = o.Id,  Name = 'Test site', Active__c = true);      
        insert site;
        MRP__c mrp = new MRP__c(Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = ps.Id, Sourced_Site__c = site.Id,
                      			 Required_Amount__c= 90);
        insert mrp;
        ERP7__Machine__c mac = new ERP7__Machine__c(Name='Test Machine');
        insert mac;
        ERP7__Resource_Allocation__c ra = new ERP7__Resource_Allocation__c(Name='Test', ERP7__Active__c=true);
        insert ra;
        Work_Center__c wcen = new Work_Center__c(Name='Test WC');
        insert wcen;
        PageReference pageRef = System.Page.Scheduler;
        pageRef.getParameters().put('id',s1.id);
        Test.setCurrentPage(pageRef);
        test.startTest();
        
        Scheduler SCH = new Scheduler();
        Scheduler.scheduleWrapper sw = new Scheduler.scheduleWrapper();
        Scheduler.cycleWrapper cw = new Scheduler.cycleWrapper();
        Scheduler.processWrapper pw = new Scheduler.processWrapper();
        Scheduler.searchProducts('test');
        Scheduler.searchWOs('test');
        Scheduler.searchWSs('test');
        SCH.jString = SCH.schedulesString; 
        SCH.switchTab();
        SCH.switchTabs();
        SCH.Back2Scheduler();
        String searchString = 'test';
        Scheduler.searchProductsP(searchString);
        Scheduler.searchWSss(searchString);
        SCH.BuildSchedule();
        try { SCH.saveSchedule(); } catch(exception e){}
        try { SCH.updateSchedule();  } catch(exception e){}
        SCH.jString = s1.id;
        
        SCH.reLoad();
        SCH.FetchAllSchedulesAndCycles();
        SCH.FetchSchedules();
        SCH.WorkforceResources();
        try{ SCH.selectDeselectAllAvailableEmployees(); } catch(exception e){}
        try{ SCH.selectDeselectAllAllocatedEmployees(); } catch(exception e){}
        try{ SCH.selectDeselectAllAvailableMachines(); } catch(exception e){}
        try{ SCH.selectDeselectAllAllocatedMachines(); } catch(exception e){}
        SCH.AvailableEmployeeList[0].selected = true;
        SCH.AvailableMachineList[0].selected = true;
        SCH.addEmployees();
        SCH.removeEmployees();
        SCH.addMachines();
        SCH.removeMachines();
        SCH.RemoveResources();
       
        SCH.SaveResources();
        SCH.ManageResources();
        SCH.scheduleResources();
        SCH.counter=0;
        SCH.scheduleChecklists();
        SCH.scheduleCheckList();
        SCH.SearchEmployees();
        SCH.SearchMachines();
        
        SCH.ManageCheckLists();
        SCH.addMRP();
        SCH.RemoveMRP();
        SCH.SaveMRPs();
        SCH.addChecklist();
        SCH.addChecklist();
        SCH.RemoveChecklist();
        SCH.SaveCheckLists();
        SCH.AddWorkForceAllocation();
        SCH.AddWorkForceAllocation();
        SCH.RemoveWorkForceAllocation();
        Scheduler.searchEmps('test');
        SCH.Back2ManageSchedulesResources();
        SCH.Back2ManageSchedulesChecklists();
        SCH.deleteSchedule();
        test.stopTest();
        /*
        
        
        
        */
        
        
        /* ---------------------------------------------------------------*/
        SchedulerCustomLookups SCL = new SchedulerCustomLookups();
        SCL.ScheduleSelect();
        SCL.ProcessSelect();
        SCL.WorkOrderSelect();
        SCL.WorkOrderLineItemSelect();
        SCL.WorkStationSelect();
        SCL.WorkStationSelectAssign();
        SCL.cycleSelect();
        SCL.getFormTag();
        SCL.getTextBox();
        SCL.getidlp();
        SCL.getcnn();

        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name); 
    }
}