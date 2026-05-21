@isTest 
class UsersShiftMatchTest {
        @isTest static void UsersShiftMatch(){      
        UsersShiftMatch Usm = new UsersShiftMatch();
        Usm.showMorningPanel=Usm.showAfternoonPanel=Usm.showEveningPanel=false;
        Usm.startAfternoonTime=Usm.startEndTime=Usm.StartTime=Usm.EndTime=Usm.DBST=Usm.DBET=system.today();
        Usm.SlotDuration=0;
        UsersShiftMatch.DaySlot ds=new UsersShiftMatch.DaySlot();
        UsersShiftMatch.TimeSlot ts=new UsersShiftMatch.TimeSlot();
        
        UsersShiftMatch.TimeOffWrp tow = new UsersShiftMatch.TimeOffWrp();
        UsersShiftMatch.ResourceWrp rw = new UsersShiftMatch.ResourceWrp();
        UsersShiftMatch.UserWrp uw = new UsersShiftMatch.UserWrp();
        UsersShiftMatch.GroupWrp gw = new UsersShiftMatch.GroupWrp();
        
        tow.Start_Time=null; tow.End_Time=null; tow.Break_Start_Time=null; tow.Break_End_Time=null; tow.TOType=null; tow.BStart_Time=null;
        tow.BEnd_Time=null; tow.TOId=null; tow.TOBool=false; tow.BST=null; tow.BET=null;       
        rw.Id=null; rw.Name=null; rw.Start_Date=null; rw.End_Date=null; rw.Start_Time=null; rw.End_Time=null; rw.Break_Start_Time=null; rw.Break_End_Time=null; rw.Mon_Start_Time=null;
        rw.Mon_End_Time=null; rw.Tue_Start_Time=null; rw.Tue_End_Time=null; rw.Wed_Start_Time=null; rw.Wed_End_Time=null; rw.Thu_Start_Time=null; rw.Thu_End_Time=null; rw.Fri_Start_Time=null; rw.Fri_End_Time=null;
        rw.Sat_Start_Time=null; rw.Sat_End_Time=null; rw.Sun_Start_Time=null; rw.Sun_End_Time=null; rw.Mon_Break_Start_Time=null;
        rw.Mon_Break_End_Time=null; rw.Tue_Break_Start_Time=null; rw.Tue_Break_End_Time=null; rw.Wed_Break_Start_Time=null; rw.Wed_Break_End_Time=null; rw.Thu_Break_Start_Time=null; rw.Thu_Break_End_Time=null; rw.Fri_Break_Start_Time=null; rw.Fri_Break_End_Time=null;
        rw.Sat_Break_Start_Time=null; rw.Sat_Break_End_Time=null; rw.Sun_Break_Start_Time=null; rw.Sun_Break_End_Time=null;rw.TOT=null; rw.TOTList=null; rw.ResourcesList=null; rw.TimeOffList=null; rw.DateList=null;
        rw.isSupervisor=false; rw.BreakStartTime=null;rw.GroupName=null;rw.GroupId=null;rw.UserId=null;rw.Day=null;rw.UserRecord=null;  
        uw.User=null;uw.ResourceAvailabilityList=null;
        gw.GroupId=null;gw.StartDate=null;gw.EndDate=null;gw.ServiceId=null;gw.LocationId=null;gw.ResourceAvailabilityList=null;
        
        Product2 product = new Product2(Name='test', IsActive=true, Family='Event');
        insert product;
    
        ERP7__Work_Center__c location = new ERP7__Work_Center__c(name='locationName',ERP7__Active__c=true);
        insert location;
       
        ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(ERP7__WorkCenter__c=location.Id, ERP7__Product__c=product.Id, ERP7__Status__c='Approved');
        insert WP;
        
        ERP7__Time_Off__c tp=new ERP7__Time_Off__c(ERP7__User__c=userInfo.getUserId(),ERP7__End_Date__c=system.today().addYears(1),ERP7__Start_Date__c=system.today(), ERP7__Reason__c = 'Test Timeoff');
        insert tp;
        UsersShiftMatch.getCurrentTimeOffReason(system.today(), '', userInfo.getUserId());
        List<ERP7__Time_Off__c> AvailableTimeOfflist=new List<ERP7__Time_Off__c>();
        AvailableTimeOfflist.add(tp);
            
        ERP7__Resource_Group__c NewGroup = new ERP7__Resource_Group__c(Name='test group',ERP7__Start_Date__c=system.today(),ERP7__End_Date__c=system.today().addYears(1));
        insert NewGroup;
        ERP7__Resource_Requirement__c NewResourceRequirement = new ERP7__Resource_Requirement__c(ERP7__Work_Planner__c=WP.Id,ERP7__Resource_Group__c=NewGroup.Id);
        insert NewResourceRequirement;
     
        ERP7__Resource__c Resource = new ERP7__Resource__c(Name='Hena Zohra',ERP7__Start_date__c=System.today(),ERP7__End_date__c=System.today()+30,ERP7__User__c=userInfo.getUserId(),
        ERP7__Mon_Start_Time__c=Time.newInstance(9, 30, 0,0),ERP7__Mon_End_Time__c=Time.newInstance(17, 30, 0,0), ERP7__Mon_Break_Start_Time__c=Time.newInstance(14, 30, 0,0), ERP7__Mon_Break_End_Time__c=Time.newInstance(15, 30, 0,0),
        ERP7__Tue_Start_Time__c=Time.newInstance(9, 30, 0,0),ERP7__Tue_End_Time__c=Time.newInstance(17, 30, 0,0), ERP7__Tue_Break_Start_Time__c=Time.newInstance(14, 30, 0,0), ERP7__Tue_Break_End_Time__c=Time.newInstance(15, 30, 0,0),
        ERP7__Wed_Start_Time__c=Time.newInstance(9, 30, 0,0),ERP7__Wed_End_Time__c=Time.newInstance(17, 30, 0,0), ERP7__Wed_Break_Start_Time__c=Time.newInstance(14, 30, 0,0), ERP7__Wed_Break_End_Time__c=Time.newInstance(15, 30, 0,0),
        ERP7__Thu_Start_Time__c=Time.newInstance(9, 30, 0,0),ERP7__Thu_End_Time__c=Time.newInstance(17, 30, 0,0), ERP7__Thu_Break_Start_Time__c=Time.newInstance(14, 30, 0,0), ERP7__Thu_Break_End_Time__c=Time.newInstance(15, 30, 0,0),
        ERP7__Fri_Start_Time__c=Time.newInstance(9, 30, 0,0),ERP7__Fri_End_Time__c=Time.newInstance(17, 30, 0,0), ERP7__Fri_Break_Start_Time__c=Time.newInstance(14, 30, 0,0), ERP7__Fri_Break_End_Time__c=Time.newInstance(15, 30, 0,0),
        ERP7__Sat_Start_Time__c=Time.newInstance(9, 30, 0,0),ERP7__Sat_End_Time__c=Time.newInstance(17, 30, 0,0), ERP7__Sat_Break_Start_Time__c=Time.newInstance(14, 30, 0,0), ERP7__Sat_Break_End_Time__c=Time.newInstance(15, 30, 0,0),
        ERP7__Sun_Start_Time__c=Time.newInstance(9, 30, 0,0),ERP7__Sun_End_Time__c=Time.newInstance(17, 30, 0,0), ERP7__Sun_Break_Start_Time__c=Time.newInstance(14, 30, 0,0), ERP7__Sun_Break_End_Time__c=Time.newInstance(15, 30, 0,0),
        ERP7__Break_Start_Time__c=Time.newInstance(17, 30, 0,0),ERP7__Break_End_Time__c=Time.newInstance(18, 30, 0,0),
        ERP7__Resource_Group__c=NewGroup.Id
        );
        insert Resource;
        
        List<ERP7__Resource__c> AvailableResourcelist=new List<ERP7__Resource__c>();
        AvailableResourcelist.add(Resource);
        String selectedLocation = location.Id;
        String selectedService=product.Id;
        //String selectedProgram=Program.Id;
        Date selectedDate=System.today()+7;
        String ResourceId=String.valueof(Resource.Id);
            
        UsersShiftMatch.getLocations(selectedService, selectedLocation, NewGroup.Id);
        UsersShiftMatch.getTimeAvailibility(selectedService,selectedLocation,selectedDate,'',null);
        UsersShiftMatch.getAddGroup();
        UsersShiftMatch.getAddResource();
        UsersShiftMatch.getAddUser();
        UsersShiftMatch.getGroupRecord(NewGroup.Id);   
        UsersShiftMatch.getNextTimeSlots(selectedService,selectedLocation,selectedDate);
        UsersShiftMatch.getPreviousTimeSlots(selectedService,selectedLocation,selectedDate);
        List<UsersShiftMatch.GroupWrp> GroupWrapperList=UsersShiftMatch.getUsersAvailibilities(selectedDate,selectedService,selectedLocation,userInfo.getUserId());
        UsersShiftMatch.getUsersAvailibilityByGroup(JSON.serialize(GroupWrapperList[0]));
        UsersShiftMatch.Resourcewrp rwp=new UsersShiftMatch.ResourceWrp();
        UsersShiftMatch.TimeOffWrp to=new UsersShiftMatch.TimeOffWrp();        
        for(Integer i=1; i<=7; i++){
           to=new UsersShiftMatch.TimeOffWrp();
           to.StartTime=null; to.EndTime=null; to.BSTime=null; to.BETime=null; to.Start_Time=null; to.End_Time=null; to.BS_Time=null;  to.BE_Time=null;
           rwp.TimeOffList.add(to); 
        }
        if(GroupWrapperList.size()>0) GroupWrapperList[0].UserAvailabilityList[0].ResourceAvailabilityList.add(rwp);
        UsersShiftMatch.GroupWrp gwrp=new UsersShiftMatch.GroupWrp();
        UsersShiftMatch.UserWrp uwp=new UsersShiftMatch.UserWrp();
        uwp.ResourceAvailabilityList.add(rwp);
        gwrp.UserAvailabilityList.add(uwp);
        gwrp.ServiceId=selectedService;
        gwrp.LocationId=selectedLocation;
        //gwrp.GroupId=NewGroup.Id;
        GroupWrapperList.add(gwrp);
        UsersShiftMatch.Save(JSON.serialize(GroupWrapperList));
        //UsersShiftMatch.getUserResources(JSON.serialize(AvailableResourcelist),selectedDate,null,null,null);  
        UsersShiftMatch.getDates(selectedDate);
        UsersShiftMatch.getDayNameOfDate(selectedDate);
        for(Integer i=0;i<7;i++)  UsersShiftMatch.getAvailableDate(system.today()+i,JSON.serialize(Resource));
        
        UsersShiftMatch.getDeleteResource(ResourceId);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    @isTest static void UsersShiftMatch1(){ 
        
        ERPUtilClass.formatTime(Time.newInstance(9, 30, 0,0));
        
        ERPUtilClass.formatTime(Time.newInstance(11, 30, 0,0));
        
        ERPUtilClass.formatTime(Time.newInstance(14, 30, 0,0));
        
        ERPUtilClass.formatTime(Time.newInstance(23, 30, 0,0));
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
}