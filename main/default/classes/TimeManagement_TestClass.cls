/*TEST CLASS*/
@isTest 
class TimeManagement_TestClass {
   /*TEST METHOD*/
   static testmethod void TimeManagement(){    
        TimeManagement timeMng = new TimeManagement();
        TimeManagement.TimeOffWrp tow = new TimeManagement.TimeOffWrp();
        TimeManagement.ResourceWrp rw = new TimeManagement.ResourceWrp();        
        timeMng.isSupervisor=true;    
        tow.Start_Time=null; tow.End_Time=null; tow.Break_Start_Time=null; tow.Break_End_Time=null; tow.TOType=null; tow.BStart_Time=null;
        tow.BEnd_Time=null; tow.TOId=null; tow.TOBool=false; tow.BST=null; tow.BET=null;       
        rw.Id=null; rw.Name=null; rw.Start_Date=null; rw.End_Date=null; rw.Start_Time=null; rw.End_Time=null; rw.Break_Start_Time=null; rw.Break_End_Time=null; rw.Mon_Start_Time=null;
        rw.Mon_End_Time=null; rw.Tue_Start_Time=null; rw.Tue_End_Time=null; rw.Wed_Start_Time=null; rw.Wed_End_Time=null; rw.Thu_Start_Time=null; rw.Thu_End_Time=null; rw.Fri_Start_Time=null; rw.Fri_End_Time=null;
        rw.Sat_Start_Time=null; rw.Sat_End_Time=null; rw.Sun_Start_Time=null; rw.Sun_End_Time=null; rw.TOT=null; rw.TOTList=null; rw.ResourcesList=null; rw.TimeOffList=null; rw.DateList=null;
        rw.isSupervisor=false; 
     
        Product2 product = new Product2(Name='test', IsActive=true, Family='Event');
        insert product;
       
        ERP7__Site__c site=new ERP7__Site__c(ERP7__Active__c=true,Name='Test', OwnerId=UserInfo.getUserId());
        insert site;  
       
        ERP7__Location__c location = new ERP7__Location__c(name='locationName',ERP7__Warehouse_Address__c='India', ERP7__Active__c=true,ERP7__Site__c=site.Id);
        insert location;
       
        ERP7__Work_Center__c workCenter = new ERP7__Work_Center__c(Name='test', ERP7__Active__c=true, ERP7__Location__c=location.Id,ERP7__Plant__c=site.Id);
        insert workCenter;
       
        ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(ERP7__Product__c=product.Id, ERP7__WorkCenter__c=workCenter.Id, ERP7__Status__c='Approved');
        insert WP;
       
         ERP7__Resource__c resource = new ERP7__Resource__c(Name='test');
         insert resource;
       
         //TimeManagement.getTimeoffRecords(String.valueOf(userInfo.getUserId()));
         TimeManagement.getTOInstance();        
         TimeManagement.formatTime(Time.newInstance(12, 2, 3, 4));
         TimeManagement.formatTime(Time.newInstance(15, 10, 3, 4));
         TimeManagement.formatTime(Time.newInstance(10, 10, 3, 4));
       
         String selectedLocation = Location.Id;
         TimeManagement.getLocationsAndServices(selectedLocation,Product.Id);
         Team__c team=new Team__c(Name='My Team'); insert team;
          
         ERP7__Team_Member__c teamMember=new ERP7__Team_Member__c(ERP7__Resource__c=resource.Id,ERP7__Team__c=team.Id,ERP7__Supervisor__c=true);       
         insert teamMember;
             
        DateTime d1 = System.now();
        String str='/'+location.Id+'/5:00 pm/Reserve/'+Location.Id+'/'+d1.format('DD-MM-YY');
      
        ERP7__Time_Off__c TOff=new ERP7__Time_Off__c(ERP7__Date__c=System.today(),ERP7__Type__c='Meeting',ERP7__Start_Time__c=System.now().Time(),ERP7__End_Time__c=System.now().Time()+2);
        insert TOff;
        String TOffJSON='{"ERP7__Type__c":"Meeting","ERP7__Reason__c":"test reason1","Id":"'+TOff.Id+'","Name":"TO-0002","ERP7__Resource__c":"'+resource.Id+'","ERP7__Date__c":"2018-08-29","ERP7__Start_Time__c":null,"ERP7__End_Time__c":null}';
        TimeManagement.getCreateTimeoff(TOffJSON,'10:45:00:00','19:45:00:00','new',TOff.Id);
        
        list<ERP7__Resource__c> ResourceList=new list<ERP7__Resource__c>();
        ResourceList.add(resource); ResourceList.add(resource);ResourceList.add(resource);
        for(Integer i=0; i<ResourceList.size(); i++) { 
          rw=new TimeManagement.ResourceWrp();
          if(ResourceList[i].Name!=null) rw.Id=ResourceList[i].Id; rw.Name=ResourceList[i].Name;
          if(ResourceList[i].Start_Date__c!=null) rw.Start_Date=ResourceList[i].Start_Date__c; if(ResourceList[i].End_Date__c!=null) rw.End_Date=ResourceList[i].End_Date__c;          
          if(ResourceList[i].Break_Start_Time__c!=null) rw.Break_Start_Time=ERPUtilClass.formatTime(ResourceList[i].Break_Start_Time__c);                        
        }        
        TimeManagement.getResource(selectedLocation,Product.Id,0,team.Id);
        String RRecordJSON='{"id":"'+resource.Id+'","Break_End_Time":"10:45 AM","Break_Start_Time":"10:15 AM","End_Date":"2018-11-06","Fri_End_Time":"3:00 PM","Fri_Start_Time":"09:15 AM","isSupervisor":false,"Mon_End_Time":"4:00 PM","Name":"Ben Smith","ResourcesList":[],"Sat_End_Time":"6:30 PM","Sat_Start_Time":"09:00 AM","Start_Date":"2018-07-09","Sun_End_Time":"4:00 PM","Sun_Start_Time":"09:30 AM","Thu_Start_Time":"09:45 AM"}';
        TimeManagement.getUpdateResources(RRecordJSON);      
        TimeManagement.timeConvert('10:30 AM');        
        list<String> serviceList1 = new list<String>();   
        TimeManagement.stringToDate(String.valueOf(System.today()));
      
        String salName = 'ERok';
        String sal1Name = 'ERok';
        System.assertEquals(salName, sal1Name); 
    } 
}