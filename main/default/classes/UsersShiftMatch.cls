Public with sharing class UsersShiftMatch {
    @AuraEnabled Public list<TimeSlot> TimeSlotList             {get;set;} 
    @AuraEnabled Public Date selectedDate                       {get;set;}  
    @AuraEnabled Public Date FirstDate                          {get;set;}  
    @AuraEnabled public Date TodayDate                          {get;set;}
    @AuraEnabled public Boolean showNext                        {get;set;} 
    @AuraEnabled public Boolean showPrevious                    {get;set;} 
    @AuraEnabled Public String ExpMsg                           {get;set;}
    @AuraEnabled Public Boolean showMorningPanel                {get;set;} 
    @AuraEnabled Public Boolean showAfternoonPanel              {get;set;} 
    @AuraEnabled Public Boolean showEveningPanel                {get;set;}
    @AuraEnabled Public DateTime startAfternoonTime             {get;set;}
    @AuraEnabled Public DateTime startEndTime                   {get;set;}
    @AuraEnabled Public List<DaySlot> DaySlots                  {get;set;}
    @AuraEnabled Public List<Date> DayList                      {get;set;}
    @AuraEnabled Public Integer SlotDuration                    {get;set;} 
    @AuraEnabled public List<UserWrp>    UserList               {get;set;}
    Private String ResourceAvailabiliyFilter                    {get;set;}
    @AuraEnabled public Set<Id> LocationIds                     {get;set;}
    @AuraEnabled public Set<Id> GroupIds                        {get;set;}
    @AuraEnabled Public Set<Id> ProgramIds                  {set;get;}
    @AuraEnabled Public Set<Id> ServiceIds                  {set;get;}
    @AuraEnabled Public String UserType                    {set;get;}
    
    /*CONSTRUCTOR*/
    Public UsersShiftMatch(){
        TimeSlotList=new list<TimeSlot>();
        DaySlots=new List<DaySlot>(); 
        ExpMsg='';
        FirstDate=TodayDate=System.today();
        selectedDate=TodayDate=System.today()+7;        
        showNext=true;
        showPrevious=false;
        DayList=new List<Date>();
        UserList=new List<UserWrp>();
        ResourceAvailabiliyFilter= ' AND ((ERP7__Mon_Start_Time__c!=null AND ERP7__Mon_End_Time__c!=null) OR (ERP7__Tue_Start_Time__c!=null AND ERP7__Tue_End_Time__c!=null) OR (ERP7__Wed_Start_Time__c!=null AND ERP7__Wed_End_Time__c!=null) OR (ERP7__Thu_Start_Time__c!=null AND  ERP7__Thu_End_Time__c!=null) OR (ERP7__Fri_Start_Time__c!=null AND ERP7__Fri_End_Time__c!=null) OR  (ERP7__Sat_Start_Time__c!=null AND ERP7__Sat_End_Time__c!=null) OR (ERP7__Sun_Start_Time__c!=null AND ERP7__Sun_End_Time__c!=null))';       
        GroupIds=new Set<Id>(); 
        ProgramIds=new Set<Id>();
        ServiceIds=new Set<Id>();
        LocationIds=new Set<Id>();
    }
    
    Public class DaySlot{
        @AuraEnabled Public list<TimeSlot> TimeSlots             {get;set;}  
        Public DaySlot(){
            TimeSlots=new list<TimeSlot>();             
        }  
    } 
    
    Public class TimeSlot{
        @AuraEnabled Public DateTime Slot            {set;get;}       
        @AuraEnabled Public Boolean IsAvailable      {set;get;}
        @AuraEnabled Public String ResourceId        {set;get;}
        @AuraEnabled Public Boolean checked          {set;get;}
        Public TimeSlot(){
            slot=null; ResourceId=null; isAvailable=checked=false; 
        }  
    } 
    /*WRAPPER CLASS FOR RESOURCES*/
    Public class ResourceWrp{
        @AuraEnabled
        public String Id     {set;get;}
        @AuraEnabled
        public String Name     {set;get;} 
        @AuraEnabled
        public DateTime Start_Date     {set;get;}
        @AuraEnabled
        public DateTime End_Date     {set;get;}
        @AuraEnabled
        public String Start_Time     {set;get;} 
        @AuraEnabled
        public String End_Time     {set;get;}
        @AuraEnabled
        public String Break_Start_Time    {set;get;} 
        @AuraEnabled
        public String Break_End_Time     {set;get;} 
        
        @AuraEnabled
        public String Mon_Start_Time      {set;get;} 
        @AuraEnabled
        public String Mon_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Tue_Start_Time      {set;get;} 
        @AuraEnabled
        public String Tue_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Wed_Start_Time      {set;get;} 
        @AuraEnabled
        public String Wed_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Thu_Start_Time      {set;get;} 
        @AuraEnabled
        public String Thu_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Fri_Start_Time      {set;get;} 
        @AuraEnabled
        public String Fri_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Sat_Start_Time      {set;get;} 
        @AuraEnabled
        public String Sat_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Sun_Start_Time      {set;get;} 
        @AuraEnabled
        public String Sun_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Mon_Break_Start_Time      {set;get;}  
        @AuraEnabled
        public String Mon_Break_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Tue_Break_Start_Time      {set;get;} 
        @AuraEnabled
        public String Tue_Break_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Wed_Break_Start_Time      {set;get;} 
        @AuraEnabled
        public String Wed_Break_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Thu_Break_Start_Time      {set;get;} 
        @AuraEnabled
        public String Thu_Break_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Fri_Break_Start_Time      {set;get;} 
        @AuraEnabled
        public String Fri_Break_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Sat_Break_Start_Time      {set;get;} 
        @AuraEnabled
        public String Sat_Break_End_Time        {set;get;} 
        
        @AuraEnabled
        public String Sun_Break_Start_Time      {set;get;} 
        @AuraEnabled
        public String Sun_Break_End_Time        {set;get;} 
        
        @AuraEnabled
        public list<SelectOption> TOT     {set;get;}
        @AuraEnabled
        public list<list<SelectOption>> TOTList     {set;get;}
        
        @AuraEnabled
        public list<ResourceWrp> ResourcesList     {set;get;} 
        
        @AuraEnabled
        public list<TimeOffWrp> TimeOffList        {set;get;}       
        @AuraEnabled
        public list<Date> DateList           {set;get;}
        
        @AuraEnabled
        public String BreakStartTime       {set;get;}
        @AuraEnabled
        public Boolean isSupervisor        {set;get;}
        @AuraEnabled
        public Boolean isTimeoff           {set;get;} 
        @AuraEnabled
        public String GroupName            {set;get;} 
        @AuraEnabled
        public String GroupId              {set;get;} 
        @AuraEnabled
        public String UserId               {set;get;} 
        @AuraEnabled
        public Date Day                    {set;get;} 
        @AuraEnabled  
        public User UserRecord             {set;get;} 
        @AuraEnabled  
        public String TeamId              {set;get;} 
        
        /*CONSTRUCTOR*/  
        public ResourceWrp(){
            TOT=new list<SelectOption>();
            TOTList=new list<list<SelectOption>>();
            ResourcesList=new list<ResourceWrp>();
            TimeOffList=new list<TimeOffWrp>();
            isSupervisor=isTimeoff=false; 
            GroupName=GroupId=UserId=TeamId=null;
            UserRecord = new User();
        }   
    }
    
    /*User Wrapper class*/
    Public class UserWrp{
        @AuraEnabled Public User User                                   {set;get;}  
        @AuraEnabled Public List<ResourceWrp> ResourceAvailabilityList  {set;get;} 
        Public UserWrp(){
            User=new User();
            ResourceAvailabilityList=new List<ResourceWrp>(); 
        } 
    }
    
    /*WRAPPER CLASS FOR TIME OFF*/
    Public class TimeOffWrp{
        @AuraEnabled
        public String Start_Time        {set;get;} 
        @AuraEnabled
        public String End_Time          {set;get;}
        @AuraEnabled
        public String BS_Time          {set;get;}
        @AuraEnabled
        public String BE_Time          {set;get;}     
        @AuraEnabled
        public String Break_Start_Time  {set;get;}
        @AuraEnabled
        public String Break_End_Time    {set;get;}
        @AuraEnabled
        public Boolean TOBool           {set;get;}
        @AuraEnabled
        public String TOType            {set;get;}
        @AuraEnabled
        public String BStart_Time       {set;get;} 
        @AuraEnabled
        public String BEnd_Time         {set;get;}  
        @AuraEnabled
        public String TOId              {set;get;} 
        @AuraEnabled
        public String BST               {set;get;} 
        @AuraEnabled
        public String BET               {set;get;} 
        @AuraEnabled
        public Boolean isAvailable      {set;get;}  
        @AuraEnabled
        public Boolean showTimePanelST  {set;get;}  
        @AuraEnabled
        public Boolean showTimePanelET  {set;get;} 
        @AuraEnabled
        public Boolean showTimePanelBST  {set;get;}  
        @AuraEnabled
        public Boolean showTimePanelBET  {set;get;}   
        @AuraEnabled
        public Time StartTime        {set;get;} 
        @AuraEnabled
        public Time EndTime          {set;get;}   
        @AuraEnabled
        public Time BSTime               {set;get;} 
        @AuraEnabled
        public Time BETime               {set;get;} 
        @AuraEnabled
        public Boolean IsValid             {set;get;}   
        @AuraEnabled
        public Boolean isHoliday             {set;get;} 
        @AuraEnabled
        public Boolean isTimeOff             {set;get;} 
        @AuraEnabled
        public Decimal Capacity              {set;get;} 
        @AuraEnabled
        public Decimal RemainingCapacity     {set;get;}       
        @AuraEnabled
        public Decimal Demand                {set;get;} 
        
        
        public TimeOffWrp(){
            TOBool=isHoliday=isTimeOff=showTimePanelST=showTimePanelET=showTimePanelBST=showTimePanelBET=false; TOType=''; isAvailable=true; IsValid=true;
            StartTime=null; EndTime=null; BSTime=null;  BETime=null; Start_Time=null; End_Time=null; BS_Time=null;  BE_Time=null;   Capacity=0; RemainingCapacity=0; Demand=0; 
        }  
    }
    
    /*Group Wrapper class*/
    Public class GroupWrp{
        @AuraEnabled Public String GroupId                                   {set;get;} 
        @AuraEnabled Public DateTime StartDate                                   {set;get;}
        @AuraEnabled Public DateTime EndDate                                     {set;get;}       
        @AuraEnabled Public String ServiceId                                 {set;get;} 
        @AuraEnabled Public String LocationId                                {set;get;} 
        @AuraEnabled Public List<ResourceWrp> ResourceAvailabilityList       {set;get;}  
        @AuraEnabled Public List<UserWrp> UserAvailabilityList               {set;get;} 
        @AuraEnabled Public String LoginUserId                              {set;get;}   
        
        Public GroupWrp(){
            ResourceAvailabilityList=new List<ResourceWrp>(); 
            UserAvailabilityList=new List<UserWrp>();  
        } 
    }
    
    Public DateTime StartTime                      {set;get;}
    Public DateTime EndTime                        {set;get;}
    Public DateTime DBST                           {set;get;}
    Public DateTime DBET                           {set;get;}  
    /*FETCH AVAILABLE LOCATIONS FOR A SERVICE*/
    @AuraEnabled 
    public static UsersShiftMatch getLocations(String ServiceId, String LocationId, String GroupId){ 
        UsersShiftMatch US=new UsersShiftMatch();           
        list<ERP7__Resource_Requirement__c> RRList=new list<ERP7__Resource_Requirement__c>();
        
        String ServiceFilter = (String.isNotEmpty(ServiceId))?' AND ERP7__Work_Planner__r.ERP7__Product__c=:ServiceId':''; 
        String LocationFilter = (String.isNotEmpty(LocationId))?' AND ERP7__Work_Planner__r.ERP7__WorkCenter__c=:LocationId':'';
        String GroupFilter = (String.isNotEmpty(GroupId))?' AND ERP7__Resource_Group__c=:GroupId':'';        
        String Status='Approved';
        String StatusFilter = '  AND ERP7__Work_Planner__r.ERP7__Status__c=:Status';
        String RRString='SELECT Id, Name, ERP7__Work_Planner__c,ERP7__Work_Planner__r.ERP7__WorkCenter__c, ERP7__Resource_Group__c,ERP7__Work_Planner__r.ERP7__Product__c '+
            'FROM ERP7__Resource_Requirement__c '+ 
            'WHERE ERP7__Resource_Group__c!=null AND ERP7__Work_Planner__c !=null AND ERP7__Work_Planner__r.ERP7__WorkCenter__r.ERP7__Active__c=true AND ERP7__Work_Planner__r.ERP7__Product__c!=null AND ERP7__Work_Planner__r.ERP7__Product__r.IsActive=true '+String.escapeSingleQuotes(ServiceFilter)+String.escapeSingleQuotes(LocationFilter)+String.escapeSingleQuotes(StatusFilter)+String.escapeSingleQuotes(GroupFilter)+' Order By LastModifiedDate'; //ServiceFilterDum
        RRList=database.query(RRString);          
        set<Id> LocationIds=new set<Id>(); set<Id> GroupIds=new set<Id>();
        List<set<Id>> returnList=new List<set<Id>>();
        for(ERP7__Resource_Requirement__c rr:RRList){
            LocationIds.add(rr.ERP7__Work_Planner__r.ERP7__WorkCenter__c); GroupIds.add(rr.ERP7__Resource_Group__c); 
        } 
        US.LocationIds=LocationIds;   US.GroupIds=GroupIds; 
        return US;
    }
    
    public Static String getDayNameOfDate(Date DateVal){
        List<String> listDay = new List<String>{'Saturday' , 'Sunday' , 'Monday' , 'Tuesday' , 'Wednesday' , 'Thursday' , 'Friday'};
            Integer remainder = Math.mod(date.newInstance(0001, 1, 1).daysBetween(DateVal) , 7);
        return listDay.get(remainder).subString(0,3); 
    }
    Public Static UsersShiftMatch getAvailableDate(DateTime startTime, String Resource1){
        ERP7__Resource__c Resource = (ERP7__Resource__c) JSON.deserialize(Resource1, ERP7__Resource__c.class);
        UsersShiftMatch TS=new UsersShiftMatch();
        DateTime EndTime, DBST, DBET;
        Date RST = Resource.ERP7__Start_date__c;
        Resource.ERP7__Start_date__c=Date.valueOf(startTime);String DayName=getDayNameOfDate(Resource.ERP7__Start_date__c);
        if(DayName=='Mon' && Resource.ERP7__Mon_Start_Time__c != null && Resource.ERP7__Mon_End_Time__c != null){ 
            StartTime = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Mon_Start_Time__c);
            EndTime=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Mon_End_Time__c);
            if(Resource.ERP7__Mon_Break_Start_Time__c != null && Resource.ERP7__Mon_Break_End_Time__c != null){
                DBST = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Mon_Break_Start_Time__c);
                DBET=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Mon_Break_End_Time__c); 
            }
        }
        else if(DayName=='Tue' && Resource.ERP7__Tue_Start_Time__c != null && Resource.ERP7__Tue_End_Time__c != null){
            StartTime = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Tue_Start_Time__c);
            EndTime=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Tue_End_Time__c);
            if(Resource.ERP7__Tue_Break_Start_Time__c != null && Resource.ERP7__Tue_Break_End_Time__c != null){
                DBST = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Tue_Break_Start_Time__c);
                DBET=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Tue_Break_End_Time__c); 
            }  
        }
        else if(DayName=='Wed' && Resource.ERP7__Wed_Start_Time__c != null && Resource.ERP7__Wed_End_Time__c != null){ 
            
            StartTime = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Wed_Start_Time__c);
            EndTime=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Wed_End_Time__c);
            if(Resource.ERP7__Wed_Break_Start_Time__c != null && Resource.ERP7__Wed_Break_End_Time__c != null){
                DBST = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Wed_Break_Start_Time__c);
                DBET=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Wed_Break_End_Time__c); 
            }  
        }
        else if(DayName=='Thu' && Resource.ERP7__Thu_Start_Time__c != null && Resource.ERP7__Thu_End_Time__c != null){
            StartTime = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Thu_Start_Time__c);
            EndTime=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Thu_End_Time__c);
            if(Resource.ERP7__Thu_Break_Start_Time__c != null && Resource.ERP7__Thu_Break_End_Time__c != null){
                DBST = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Thu_Break_Start_Time__c);
                DBET=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Thu_Break_End_Time__c); 
            } 
        }
        else if(DayName=='Fri' && Resource.ERP7__Fri_Start_Time__c != null && Resource.ERP7__Fri_End_Time__c != null){
            StartTime = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Fri_Start_Time__c);
            EndTime=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Fri_End_Time__c);
            if(Resource.ERP7__Fri_Break_Start_Time__c != null && Resource.ERP7__Fri_Break_End_Time__c != null){
                DBST = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Fri_Break_Start_Time__c);
                DBET=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Fri_Break_End_Time__c); 
            } 
        }
        else if(DayName=='Sat' && Resource.ERP7__Sat_Start_Time__c != null && Resource.ERP7__Sat_End_Time__c != null){ 
            StartTime = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Sat_Start_Time__c);
            EndTime=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Sat_End_Time__c);
            if(Resource.ERP7__Sat_Break_Start_Time__c != null && Resource.ERP7__Sat_Break_End_Time__c != null){
                DBST = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Sat_Break_Start_Time__c); 
                DBET=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Sat_Break_End_Time__c); 
            }    
        }
        else if(DayName=='Sun' && Resource.ERP7__Sun_Start_Time__c != null && Resource.ERP7__Sun_End_Time__c != null){
            StartTime = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Sun_Start_Time__c);
            EndTime=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Sun_End_Time__c);
            if(Resource.ERP7__Sun_Break_Start_Time__c != null && Resource.ERP7__Sun_Break_End_Time__c != null){
                DBST = DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Sun_Break_Start_Time__c);
                DBET=DateTime.newInstance(Resource.ERP7__Start_Date__c,Resource.ERP7__Sun_Break_End_Time__c); 
            } 
        }
        TS.StartTime=StartTime;
        TS.EndTime=EndTime;
        TS.DBST=DBST;
        TS.DBET=DBET;
        Resource.ERP7__Start_date__c = RST;
        return TS;
        
    }   
    
    @AuraEnabled
    Public static UsersShiftMatch getNextTimeSlots(String ServiceId, String LocationId, Date selectedDate) {
        selectedDate=selectedDate+1;
        UsersShiftMatch us=getTimeAvailibility(ServiceId, LocationId, selectedDate, 'Next', null);                         
        us.showNext=true;  us.showPrevious=true; 
        return us;
    }
    
    @AuraEnabled
    Public static UsersShiftMatch getPreviousTimeSlots(String ServiceId, String LocationId, Date selectedDate) {
        selectedDate=selectedDate-7; 
        UsersShiftMatch us=getTimeAvailibility(ServiceId, LocationId, selectedDate, 'Prev', null);
        us.showNext=true;  us.showPrevious=true; 
        if(selectedDate<=System.today()) us.showPrevious=false; 
        return us;
    }
    
    Public Static Map<String, Set<String>> getUserType() {
        String UserType='normal';        
        list<ERP7__Resource_Requirement__c> RRList=new list<ERP7__Resource_Requirement__c>();
        RRList=[SELECT Id, Name, ERP7__Resource_Group__c FROM ERP7__Resource_Requirement__c
                WHERE ERP7__Resource_Group__c!=null AND  ERP7__Work_Planner__r.ERP7__Status__c='Approved' AND ERP7__Work_Planner__r.ERP7__WorkCenter__c!=null AND ERP7__Work_Planner__r.ERP7__WorkCenter__r.ERP7__Active__c=true AND ERP7__Work_Planner__r.ERP7__Product__c!=null AND ERP7__Work_Planner__r.ERP7__Product__r.IsActive=true
                Order By LastModifiedDate];        
        set<String> RGIdsUser=new set<String>();
        for(ERP7__Resource_Requirement__c rr:RRList) RGIdsUser.add(rr.ERP7__Resource_Group__c);
        
        list<ERP7__Resource__c> ResourceList=new  list<ERP7__Resource__c>();
        set<String> ResourceIds=new set<String>();
        ResourceList= [SELECT Id, Name, ERP7__Resource_Group__c, ERP7__Team__c, ERP7__User__c, ERP7__Supervisor_User__c, ERP7__Super_User__c FROM ERP7__Resource__c
                       WHERE ERP7__Resource_Group__c IN:RGIdsUser 
                       AND ERP7__User__c=:userInfo.getUserId()];  
        Set<String> TeamIds=new Set<String>();
        for(ERP7__Resource__c res:ResourceList) if(res.ERP7__Super_User__c) { UserType='superUser'; break;}
        if(UserType!='superUser'){ 
            for(ERP7__Resource__c res:ResourceList){ 
                if(res.ERP7__Supervisor_User__c && UserType!='supervisor') UserType='supervisor';
                if(res.ERP7__Team__c!=null) TeamIds.add(res.ERP7__Team__c);    
            }
        }
        Map<String, Set<String>> UserTypeMap=new  Map<String, Set<String>>{UserType => TeamIds};
            return UserTypeMap;
    }
    
    @AuraEnabled
    Public static UsersShiftMatch getTimeAvailibility(String ServiceId, String LocationId, Date selectedDate, String Action, Date WeekSelectedDate) { 
        Map<String, Set<String>> UserTypeMap=getUserType();
        UsersShiftMatch us = new UsersShiftMatch();
        try{
            if(String.isEmpty(String.valueOf(selectedDate))) selectedDate=System.today();
            if(WeekSelectedDate<System.today()) WeekSelectedDate=System.today();
            if(WeekSelectedDate==null) WeekSelectedDate=selectedDate;
            Date FirstDate;
            if(WeekSelectedDate!=null){
                for(Integer d=0; d<=7; d++){
                    FirstDate=WeekSelectedDate-d; 
                    if(getWeekDayNameOfDate(FirstDate)=='Mon') Break;           
                }
            }
            if(FirstDate!=null) selectedDate=FirstDate;
            us.selectedDate=selectedDate;
            us.DayList=getDates(selectedDate);
            Date weekLastDay = system.today();
            if(us.DayList.size() > 0) weekLastDay = us.DayList[us.DayList.size()-1];
            list<ERP7__Resource_Requirement__c> RRList=new list<ERP7__Resource_Requirement__c>();
            String ServiceFilter = (String.isNotEmpty(ServiceId))?' AND ERP7__Work_Planner__r.ERP7__Product__c=:ServiceId':''; 
            String LocationFilter = (String.isNotEmpty(LocationId))?' AND ERP7__Work_Planner__r.ERP7__WorkCenter__c=:LocationId':'';           
            String Status='Approved';
            String StatusFilter = '  AND ERP7__Work_Planner__r.ERP7__Status__c=:Status';
            String RRString='SELECT Id, Name, ERP7__Work_Planner__c,ERP7__Work_Planner__r.ERP7__WorkCenter__c, ERP7__Resource_Group__c,ERP7__Work_Planner__r.ERP7__Product__c '+
                'FROM ERP7__Resource_Requirement__c '+ 
                'WHERE ERP7__Resource_Group__c!=null AND ERP7__Work_Planner__c !=null AND ERP7__Work_Planner__r.ERP7__WorkCenter__r.ERP7__Active__c=true AND ERP7__Work_Planner__r.ERP7__Product__c!=null AND ERP7__Work_Planner__r.ERP7__Product__r.IsActive=true '+String.escapeSingleQuotes(ServiceFilter)+String.escapeSingleQuotes(LocationFilter)+String.escapeSingleQuotes(StatusFilter)+' Order By LastModifiedDate'; 
            RRList=database.query(RRString);          
            set<String> RGIdsUser=new set<String>();
            for(ERP7__Resource_Requirement__c rr:RRList) RGIdsUser.add(rr.ERP7__Resource_Group__c);
            list<ERP7__Resource__c> AvailableResourceList=new  list<ERP7__Resource__c>();
            String allFields = UtilClass.selectStarFromSObject('ERP7__Resource__c');
            Date TodayDate=System.today();             
            
            String TeamFilter=''; String UserFilter=''; String LogInUserId=userInfo.getUserId(); us.UserType='superUser';
            Set<String> TeamIds=new Set<String>();
            if(UserTypeMap.keySet().size()>0) TeamIds.addAll(UserTypeMap.get(new List<String>(UserTypeMap.keySet())[0]));           
            if(new List<String>(UserTypeMap.keySet())[0]=='supervisor' && TeamIds.size()>0) {TeamFilter = (new List<String>(UserTypeMap.keySet())[0]=='supervisor')?' AND ERP7__Team__c IN:TeamIds':''; us.UserType='supervisor';} 
            else if(new List<String>(UserTypeMap.keySet())[0]=='normal') {UserFilter = (new List<String>(UserTypeMap.keySet())[0]=='normal')?' AND ERP7__User__c=:LogInUserId':'';  us.UserType='normal';}
            String queryString = 'select ERP7__User__r.Name, ERP7__User__r.fullphotourl, ERP7__Resource_Group__r.Name, ERP7__Team__r.Name, ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Resource__c where ERP7__User__r.IsActive=true AND ERP7__End_Date__c>=:TodayDate AND ERP7__Resource_Group__c IN:RGIdsUser AND RecordType.DeveloperName!=\'Room\' '+String.escapeSingleQuotes(us.ResourceAvailabiliyFilter)+String.escapeSingleQuotes(TeamFilter)+String.escapeSingleQuotes(UserFilter)+' ORDER By ERP7__User__r.Name, CreatedDate ASC';//, CreatedDate
            AvailableResourceList=Database.query(queryString);  
            RGIdsUser.clear();
            for(ERP7__Resource__c resource:AvailableResourceList) RGIdsUser.add(resource.ERP7__Resource_Group__c);
            for(ERP7__Resource_Requirement__c rr:RRList){
                if(RGIdsUser.contains(rr.ERP7__Resource_Group__c)){
                    us.ServiceIds.add(rr.ERP7__Work_Planner__r.ERP7__Product__c); 
                    us.LocationIds.add(rr.ERP7__Work_Planner__r.ERP7__WorkCenter__c);  
                }
            }
            
            
            
            List<String> UserIds=new List<String>();  
            for(ERP7__Resource__c res:AvailableResourceList) UserIds.add(res.ERP7__User__c);
            List<User> UserList=[SELECT Id, Name, fullphotourl FROM User WHERE Id IN:UserIds];
            Map<Id,User> UserMap=new  Map<Id,User>(UserList);
            List < ERP7__Leave_Entitlements_Holidays__c > HolidayList = [SELECT Id, Name, ERP7__Active__c, ERP7__Date_Of_Holiday__c FROM ERP7__Leave_Entitlements_Holidays__c WHERE ERP7__Date_Of_Holiday__c >= TODAY AND ERP7__Active__c = true];        
            
            
            Date EndDate, StartDate;
            Map<String, List<ERP7__Resource__c>> UserResourcesMap=new Map<String, List<ERP7__Resource__c>>();
            List<ERP7__Resource__c> ResourceList=new List<ERP7__Resource__c>();
            for (ERP7__Resource__c Resource: AvailableResourceList) {
                ResourceList=new List<ERP7__Resource__c>();
                if(UserResourcesMap.containsKey(Resource.ERP7__User__c)) ResourceList = UserResourcesMap.get(Resource.ERP7__User__c);
                ResourceList.add(Resource);                
                UserResourcesMap.put(Resource.ERP7__User__c, ResourceList);
            } 
            
            
            list < ERP7__Time_Off__c > TimeOffList = [SELECT Id, Name, ERP7__Resource__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Type__c, ERP7__Start_Time__c, ERP7__End_Time__c, ERP7__User__c
                                                      FROM ERP7__Time_Off__c WHERE                        
                                                      ERP7__End_Date__c >= : System.today()  
                                                      AND ERP7__User__c In : UserResourcesMap.keySet()
                                                      AND ERP7__Type__c != null
                                                      AND((ERP7__Start_Time__c = null AND ERP7__End_Time__c = null) OR(ERP7__Start_Time__c != null AND ERP7__End_Time__c != null))
                                                      AND ERP7__Start_Date__c != null AND ERP7__End_Date__c != null Order By ERP7__Start_Date__c
                                                     ];
            
            Map < Id, list < ERP7__Time_Off__c >> TimeOffMap = new Map < Id, list < ERP7__Time_Off__c >> ();
            for (ERP7__Time_Off__c TO: TimeOffList) {
                List<ERP7__Time_Off__c> TOList=new List<ERP7__Time_Off__c>();                     
                if (TimeOffMap.containsKey(TO.ERP7__User__c)) TOList=TimeOffMap.get(TO.ERP7__User__c);
                TOList.add(TO);
                TimeOffMap.put(TO.ERP7__User__c, TOList);
            }
            
            
            List<UserWrp> UserWrapperList=new List<UserWrp>(); 
            UserWrp uWrp=new UserWrp();
            Integer count=0;
            
         
            List<ERP7__Capacity__c> CapList=new List<ERP7__Capacity__c>();
            String allFields1 = UtilClass.selectStarFromSObject('ERP7__Capacity__c');   
            String queryString1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__Capacity__c where ERP7__Capacity_Hrs__c>=0 AND ERP7__User__c!=null AND ERP7__Resource__c!=null AND ERP7__Date__c >=: selectedDate AND ERP7__Date__c <=: weekLastDay ORDER By ERP7__Date__c DESC';
            CapList=Database.query(queryString1);
            
            Map< String, list < ERP7__Capacity__c >> ResCapMap = new Map < String, list < ERP7__Capacity__c >> ();
            List<ERP7__Capacity__c> cpList=new List<ERP7__Capacity__c>();
            for(ERP7__Capacity__c cp: CapList){
                cpList=new List<ERP7__Capacity__c>();
                if (ResCapMap.containsKey(cp.ERP7__User__c)) cpList=ResCapMap.get(cp.ERP7__User__c);
                cpList.add(cp);
                ResCapMap.put(cp.ERP7__User__c, cpList);
            }
            
            for (integer u = 0; u <UserResourcesMap.size(); u++){
                uWrp=new UserWrp();
                AvailableResourceList=UserResourcesMap.get(new List<String>(UserResourcesMap.keySet())[u]);
                TimeOffList=new list < ERP7__Time_Off__c >();
                TimeOffList=TimeOffMap.get(new List<String>(UserResourcesMap.keySet())[u]);
                
                uWrp.ResourceAvailabilityList = getUserResources(JSON.serialize(AvailableResourceList), selectedDate, JSON.serialize(HolidayList),JSON.serialize(TimeOffList), JSON.serialize(ResCapMap.get(new List<String>(UserResourcesMap.keySet())[u])));
                count+=uWrp.ResourceAvailabilityList.size();               
                uWrp.User=UserMap.get(new List<String>(UserResourcesMap.keySet())[u]); 
                if(uWrp.ResourceAvailabilityList.size()>0) if(uWrp.ResourceAvailabilityList[0].TimeOffList.size()>0) us.UserList.add(uWrp);
                AvailableResourceList=new List<ERP7__Resource__c>();
            } 
            
            if(selectedDate>System.today()) us.showPrevious=true; 
            else us.showPrevious=false; }catch(Exception ex){ 
                throw new AuraHandledException(ex.getMessage());                             
            }    
        return us;   
    } 
    
    /*UTIL METHOD TO GET WEEK DAYS*/
    @AuraEnabled 
    public static List<Date> getDates(Date startDate) {   
        List<Date> dates = new  List<Date>();
        for(Integer i=0;i<7;i++){
            dates.add(startDate.addDays(i));    
        }                      
        return dates;
    } 
    
    /*FOR GETTING WEEK DAY NAME BY A DATE*/
    Public Static String getWeekDayNameOfDate(Date DateVal){
        List<String> listDay = new List<String>{'Saturday' , 'Sunday' , 'Monday' , 'Tuesday' , 'Wednesday' , 'Thursday' , 'Friday'};
            Integer remainder = Math.mod(date.newInstance(0001, 1, 1).daysBetween(DateVal) , 7);
        return listDay.get(remainder).subString(0,3); 
    }
    
    /*GET USER TIME SLOTS*/  
    /*@AuraEnabled 
    Public static list<ResourceWrp> getUserResources(List <ERP7__Resource__c> AvailableResourceList, Date selectedDate, List < ERP7__Leave_Entitlements_Holidays__c > HolidayList,  list < ERP7__Time_Off__c > TimeOffList, List<ERP7__Capacity__c> CapList) {
        list<ResourceWrp> ResourceAvailabilityList=new list<ResourceWrp>();
        List<TimeOffWrp> AvailibilityList=new List<TimeOffWrp>();
        List<ResourceWrp> DayWiseList=new List<ResourceWrp>();        
        try{
            Map<Id, ERP7__Resource__c> ResourceMap = new Map<Id, ERP7__Resource__c>(AvailableResourceList);
            List < TimeSlot > AllTimeSlotList = new List < TimeSlot > ();
            Set<DateTime> Slots = new Set<DateTime>();
            Set<Date> Holidays=new Set<Date>();
            for(ERP7__Leave_Entitlements_Holidays__c hd:HolidayList) Holidays.add(hd.ERP7__Date_Of_Holiday__c);
            Boolean isHoliday=false;
            Boolean isTimeOff=false;      
            list<Date> DateList=getDates(selectedDate);
            
            list<ERP7__Resource__c> ResourceList=new list<ERP7__Resource__c>();        
            if(AvailableResourceList.size()>0) ResourceList=AvailableResourceList; 
            
            
            Map< String, list < ERP7__Capacity__c >> ResCapMap = new Map < String, list < ERP7__Capacity__c >> ();
            List<ERP7__Capacity__c> cpList=new List<ERP7__Capacity__c>();
            try{     
            for(ERP7__Capacity__c cp: CapList){
            cpList=new List<ERP7__Capacity__c>();                     
            if (ResCapMap.containsKey(cp.ERP7__Product__c)) cpList=ResCapMap.get(cp.ERP7__Product__c);
            cpList.add(cp);
            ResCapMap.put(cp.ERP7__Product__c, cpList); //ERP7__Resource__c  cp.ERP7__Product__c+':'+cp.ERP7__Date__c
            }
            
            } catch(Exception e1) {} 
            
            
            ResourceWrp rw=new ResourceWrp();
            for(Integer i=0; i<ResourceList.size(); i++){ 
                rw=new ResourceWrp(); 
                if(ResourceList[i].Name!=null) rw.Id=ResourceList[i].Id; rw.Name=ResourceList[i].Name;
                if(ResourceList[i].ERP7__Resource_Group__c!=null) rw.GroupName=ResourceList[i].ERP7__Resource_Group__r.Name;
                if(ResourceList[i].ERP7__Resource_Group__c!=null) rw.GroupId=ResourceList[i].ERP7__Resource_Group__c;
                if(ResourceList[i].ERP7__User__c!=null) rw.UserId=ResourceList[i].ERP7__User__c; 
                
                if(ResourceList[i].Start_Date__c!=null) rw.Start_Date=ResourceList[i].Start_Date__c;
                if(ResourceList[i].End_Date__c!=null) rw.End_Date=ResourceList[i].End_Date__c;          
                if(ResourceList[i].Break_Start_Time__c!=null) rw.Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Break_Start_Time__c);             
                if(ResourceList[i].Break_End_Time__c!=null) rw.Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Break_End_Time__c); 
                
                
                /*FRO WEEK DAYS TIME*/
    
                /*
                rw.Mon_Start_Time=null; rw.Mon_End_Time=null; rw.Tue_Start_Time=null; rw.Tue_End_Time=null; rw.Wed_Start_Time=null; rw.Wed_End_Time=null; rw.Thu_Start_Time=null; rw.Thu_End_Time=null; rw.Fri_Start_Time=null; rw.Fri_End_Time=null; rw.Sat_Start_Time=null; rw.Sat_End_Time=null; rw.Sun_Start_Time=null; rw.Sun_End_Time=null;     
                if(ResourceList[i].Mon_Start_Time__c!=null) rw.Mon_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Start_Time__c);
                if(ResourceList[i].Mon_End_Time__c!=null) rw.Mon_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_End_Time__c); 
                if(ResourceList[i].Tue_Start_Time__c!=null)  rw.Tue_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Start_Time__c);
                if(ResourceList[i].Tue_End_Time__c!=null) rw.Tue_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_End_Time__c);           
                if(ResourceList[i].Wed_Start_Time__c!=null) rw.Wed_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Start_Time__c);
                if(ResourceList[i].Wed_End_Time__c!=null)  rw.Wed_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_End_Time__c);
                if(ResourceList[i].Thu_Start_Time__c!=null) rw.Thu_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Start_Time__c);
                if(ResourceList[i].Thu_End_Time__c!=null) rw.Thu_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_End_Time__c);            
                if(ResourceList[i].Fri_Start_Time__c!=null) rw.Fri_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Start_Time__c);
                if(ResourceList[i].Fri_End_Time__c!=null) rw.Fri_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_End_Time__c);
                if(ResourceList[i].Sat_Start_Time__c!=null) rw.Sat_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Start_Time__c);
                if(ResourceList[i].Sat_End_Time__c!=null) rw.Sat_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_End_Time__c);
                if(ResourceList[i].Sun_Start_Time__c!=null) rw.Sun_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Start_Time__c);
                if(ResourceList[i].Sun_End_Time__c!=null) rw.Sun_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_End_Time__c); 
                
                /*FRO WEEK DAYS BREAK TIME*/
    
                /*
                rw.Mon_Break_Start_Time=null; rw.Mon_Break_End_Time=null; rw.Tue_Break_Start_Time=null; rw.Tue_Break_End_Time=null; rw.Wed_Break_Start_Time=null; rw.Wed_Break_End_Time=null; rw.Thu_Break_Start_Time=null; rw.Thu_Break_End_Time=null; rw.Fri_Break_Start_Time=null; rw.Fri_Break_End_Time=null; rw.Sat_Break_Start_Time=null; rw.Sat_Break_End_Time=null; rw.Sun_Break_Start_Time=null; rw.Sun_Break_End_Time=null;    
                if(ResourceList[i].Mon_Break_Start_Time__c!=null) rw.Mon_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Break_Start_Time__c);
                if(ResourceList[i].Mon_Break_End_Time__c!=null) rw.Mon_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Break_End_Time__c); 
                if(ResourceList[i].Tue_Break_Start_Time__c!=null)  rw.Tue_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Break_Start_Time__c);
                if(ResourceList[i].Tue_Break_End_Time__c!=null) rw.Tue_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Break_End_Time__c);           
                if(ResourceList[i].Wed_Break_Start_Time__c!=null) rw.Wed_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Break_Start_Time__c);
                if(ResourceList[i].Wed_Break_End_Time__c!=null)  rw.Wed_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Break_End_Time__c);
                if(ResourceList[i].Thu_Break_Start_Time__c!=null) rw.Thu_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Break_Start_Time__c);
                if(ResourceList[i].Thu_Break_End_Time__c!=null) rw.Thu_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Break_End_Time__c);            
                if(ResourceList[i].Fri_Break_Start_Time__c!=null) rw.Fri_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Break_Start_Time__c);
                if(ResourceList[i].Fri_Break_End_Time__c!=null) rw.Fri_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Break_End_Time__c);
                if(ResourceList[i].Sat_Break_Start_Time__c!=null) rw.Sat_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Break_Start_Time__c);
                if(ResourceList[i].Sat_Break_End_Time__c!=null) rw.Sat_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Break_End_Time__c);
                if(ResourceList[i].Sun_Break_Start_Time__c!=null) rw.Sun_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Break_Start_Time__c);
                if(ResourceList[i].Sun_Break_End_Time__c!=null) rw.Sun_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Break_End_Time__c);                                            
                
                for(Integer j=0; j<DateList.size(); j++){                                            
                    TimeOffWrp tw=new TimeOffWrp();               
                    tw.Start_Time=null; tw.End_Time=null;      
                    isHoliday=isTimeOff=false; 
                    
                    try{ 
                    cpList=ResCapMap.get(ResourceList[i].Id); //ResourceList[i].Id+':'+DateList[j]
                    if(cpList!=null){
                    tw.Capacity=cpList[0].ERP7__Capacity__c;//ERP7__Capacity_Hrs__c;
                    tw.RemainingCapacity=cpList[0].ERP7__Remaining_Capacity__c;
                    if(cpList[0].ERP7__Demand_Quantity__c!=null) tw.Demand=cpList[0].ERP7__Demand_Quantity__c;else tw.Demand=0;  //ERP7__Demand_Hrs__c   tw.Demand=cpList[0].ERP7__Demand_Quantity__c+cpList[0].ERP7__TimeOff_Hrs__c; 
                    }
                    }catch(Exception e2){ } 
                    
                    
                    if(Holidays.contains(DateList[j]) && ResourceList[i].ERP7__Override_Holidays__c==false) isHoliday=true; // && ResourceList[i].ERP7__Override_Holidays__c==false
                    if(isHoliday==false && TimeOffList!=null)  
                        for (ERP7__Time_Off__c to: TimeOffList){
                            if (to.ERP7__Start_Date__c <= DateList[j] && to.ERP7__End_Date__c >= DateList[j]) {
                                isTimeOff = true;
                                Break;
                            }
                        }
                    
                    
                    String DayName=getWeekDayNameOfDate(DateList[j]);           
                    if(DayName=='Mon'){
                        tw.Start_Time=rw.Mon_Start_Time; 
                        tw.End_Time=rw.Mon_End_Time;                 
                        tw.BST=rw.Mon_Break_Start_Time;
                        tw.BET=rw.Mon_Break_End_Time;
                        if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today()) tw.isAvailable=false; 
                    }  
                    
                    if(DayName=='Tue'){
                        tw.Start_Time=rw.Tue_Start_Time; 
                        tw.End_Time=rw.Tue_End_Time;                 
                        tw.BST=rw.Tue_Break_Start_Time;
                        tw.BET=rw.Tue_Break_End_Time;
                        if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today()) tw.isAvailable=false;
                    }
                    
                    
                    if(DayName=='Wed'){
                        tw.Start_Time=rw.Wed_Start_Time; 
                        tw.End_Time=rw.Wed_End_Time;                 
                        tw.BST=rw.Wed_Break_Start_Time;
                        tw.BET=rw.Wed_Break_End_Time;
                        if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today()) tw.isAvailable=false;
                    }
                    
                    if(DayName=='Thu'){
                        tw.Start_Time=rw.Thu_Start_Time; 
                        tw.End_Time=rw.Thu_End_Time;                 
                        tw.BST=rw.Thu_Break_Start_Time;
                        tw.BET=rw.Thu_Break_End_Time;
                        if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today()) tw.isAvailable=false;
                    }
                    if(DayName=='Fri'){
                        tw.Start_Time=rw.Fri_Start_Time; 
                        tw.End_Time=rw.Fri_End_Time;                 
                        tw.BST=rw.Fri_Break_Start_Time;
                        tw.BET=rw.Fri_Break_End_Time;
                        if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today()) tw.isAvailable=false;
                    }
                    if(DayName=='Sat'){
                        tw.Start_Time=rw.Sat_Start_Time; 
                        tw.End_Time=rw.Sat_End_Time;                 
                        tw.BST=rw.Sat_Break_Start_Time;
                        tw.BET=rw.Sat_Break_End_Time;
                        if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today()) tw.isAvailable=false;
                    }
                    if(DayName=='Sun'){
                        tw.Start_Time=rw.Sun_Start_Time; 
                        tw.End_Time=rw.Sun_End_Time;                 
                        tw.BST=rw.Sun_Break_Start_Time;
                        tw.BET=rw.Sun_Break_End_Time; 
                        if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today()) tw.isAvailable=false;
                    }
                    if(isHoliday || isTimeOff){
                        if(isHoliday) tw.isHoliday=true;
                        else if(isTimeOff) tw.isTimeOff=true;
                        tw.isAvailable=false;
                    } 
                    if(rw.End_Date>=DateList[0]) rw.TimeOffList.add(tw); 
                    rw.Day=DateList[j];             
                } 
                DayWiseList.add(rw); 
            } 
        }catch(Exception ex){}   
        return DayWiseList;
    }*/
    
    @AuraEnabled 
    Public static list<ResourceWrp> getUserResources(String AvailableResourceList1, Date selectedDate, String HolidayList1,  String TimeOffList1, String CapList1) { /*, String MyAct, String LId, String SId, Product2 Product, ERP7__SystemCode__c sysCode, List < ERP7__Holiday__c > HolidayList, List < ERP7__Registration__c > myBookedRegs, list < ERP7__Time_Off__c > myTOs*/
        list<ResourceWrp> ResourceAvailabilityList=new list<ResourceWrp>();
        List<TimeOffWrp> AvailibilityList=new List<TimeOffWrp>();
        List<ResourceWrp> DayWiseList=new List<ResourceWrp>();   
        
        List < ERP7__Resource__c > AvailableResourceList = (List < ERP7__Resource__c > ) JSON.deserialize(AvailableResourceList1, List < ERP7__Resource__c > .class);
        List < ERP7__Leave_Entitlements_Holidays__c > HolidayList = (List < ERP7__Leave_Entitlements_Holidays__c > ) JSON.deserialize(HolidayList1, List < ERP7__Leave_Entitlements_Holidays__c > .class);
        List < ERP7__Time_Off__c > TimeOffList = (List < ERP7__Time_Off__c > ) JSON.deserialize(TimeOffList1, List < ERP7__Time_Off__c > .class);
        List < ERP7__Capacity__c > CapList = (List < ERP7__Capacity__c > ) JSON.deserialize(CapList1, List < ERP7__Capacity__c > .class);
        
      try{
        Map<Id, ERP7__Resource__c> ResourceMap = new Map<Id, ERP7__Resource__c>(AvailableResourceList);
        List < TimeSlot > AllTimeSlotList = new List < TimeSlot > ();
        Set<DateTime> Slots = new Set<DateTime>();
      
    // List<ERP7__Holiday__c> HolidayList=new List<ERP7__Holiday__c>();
    Set<Date> Holidays=new Set<Date>();
    for(ERP7__Leave_Entitlements_Holidays__c hd:HolidayList) Holidays.add(hd.ERP7__Date_Of_Holiday__c);
    /* list < ERP7__Time_Off__c > TimeOffList=new list < ERP7__Time_Off__c >(); 
    if(TimeOffs.size()>0) TimeOffList=TimeOffs;     
    */     
    Boolean isHoliday=false;
    Boolean isTimeOff=false;             
    list<Date> DateList=getDates(selectedDate);
    list<ERP7__Resource__c> ResourceList=new list<ERP7__Resource__c>();        
    if(AvailableResourceList.size()>0) ResourceList=AvailableResourceList; 
        
     Map< String, list < ERP7__Capacity__c >> ResCapMap = new Map < String, list < ERP7__Capacity__c >> ();
     List<ERP7__Capacity__c> cpList=new List<ERP7__Capacity__c>();
     try{     
     for(ERP7__Capacity__c cp: CapList){
         cpList=new List<ERP7__Capacity__c>();                     
         if (ResCapMap.containsKey(cp.ERP7__Resource__c)) cpList=ResCapMap.get(cp.ERP7__Resource__c);
            cpList.add(cp);
            ResCapMap.put(cp.ERP7__Resource__c+':'+cp.ERP7__Date__c, cpList);
     }
     
     } catch(Exception e1) {} 
          
    ResourceWrp rw=new ResourceWrp(); 
    for(Integer i=0; i<ResourceList.size(); i++){ 
        rw=new ResourceWrp(); 
        if(ResourceList[i].Name!=null) rw.Id=ResourceList[i].Id; rw.Name=ResourceList[i].Name;
        if(ResourceList[i].ERP7__Resource_Group__c!=null) rw.GroupName=ResourceList[i].ERP7__Resource_Group__r.Name;
        if(ResourceList[i].ERP7__Resource_Group__c!=null) rw.GroupId=ResourceList[i].ERP7__Resource_Group__c;
        if(ResourceList[i].ERP7__User__c!=null) rw.UserId=ResourceList[i].ERP7__User__c; 
        
        if(ResourceList[i].Start_Date__c!=null) rw.Start_Date=ResourceList[i].Start_Date__c;
        if(ResourceList[i].End_Date__c!=null) rw.End_Date=ResourceList[i].End_Date__c;          
        if(ResourceList[i].Break_Start_Time__c!=null) rw.Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Break_Start_Time__c);             
        if(ResourceList[i].Break_End_Time__c!=null) rw.Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Break_End_Time__c); 
      
        /*FRO WEEK DAYS TIME*/
        rw.Mon_Start_Time=null; rw.Mon_End_Time=null; rw.Tue_Start_Time=null; rw.Tue_End_Time=null; rw.Wed_Start_Time=null; rw.Wed_End_Time=null; rw.Thu_Start_Time=null; rw.Thu_End_Time=null; rw.Fri_Start_Time=null; rw.Fri_End_Time=null; rw.Sat_Start_Time=null; rw.Sat_End_Time=null; rw.Sun_Start_Time=null; rw.Sun_End_Time=null;     
        if(ResourceList[i].Mon_Start_Time__c!=null) rw.Mon_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Start_Time__c);
        if(ResourceList[i].Mon_End_Time__c!=null) rw.Mon_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_End_Time__c); 
        if(ResourceList[i].Tue_Start_Time__c!=null)  rw.Tue_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Start_Time__c);
        if(ResourceList[i].Tue_End_Time__c!=null) rw.Tue_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_End_Time__c);           
        if(ResourceList[i].Wed_Start_Time__c!=null) rw.Wed_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Start_Time__c);
        if(ResourceList[i].Wed_End_Time__c!=null)  rw.Wed_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_End_Time__c);
        if(ResourceList[i].Thu_Start_Time__c!=null) rw.Thu_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Start_Time__c);
        if(ResourceList[i].Thu_End_Time__c!=null) rw.Thu_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_End_Time__c);            
        if(ResourceList[i].Fri_Start_Time__c!=null) rw.Fri_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Start_Time__c);
        if(ResourceList[i].Fri_End_Time__c!=null) rw.Fri_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_End_Time__c);
        if(ResourceList[i].Sat_Start_Time__c!=null) rw.Sat_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Start_Time__c);
        if(ResourceList[i].Sat_End_Time__c!=null) rw.Sat_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_End_Time__c);
        if(ResourceList[i].Sun_Start_Time__c!=null) rw.Sun_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Start_Time__c);
        if(ResourceList[i].Sun_End_Time__c!=null) rw.Sun_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_End_Time__c); 
        
        /*FRO WEEK DAYS BREAK TIME*/
        rw.Mon_Break_Start_Time=null; rw.Mon_Break_End_Time=null; rw.Tue_Break_Start_Time=null; rw.Tue_Break_End_Time=null; rw.Wed_Break_Start_Time=null; rw.Wed_Break_End_Time=null; rw.Thu_Break_Start_Time=null; rw.Thu_Break_End_Time=null; rw.Fri_Break_Start_Time=null; rw.Fri_Break_End_Time=null; rw.Sat_Break_Start_Time=null; rw.Sat_Break_End_Time=null; rw.Sun_Break_Start_Time=null; rw.Sun_Break_End_Time=null;    
        if(ResourceList[i].Mon_Break_Start_Time__c!=null) rw.Mon_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Break_Start_Time__c);
        if(ResourceList[i].Mon_Break_End_Time__c!=null) rw.Mon_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Break_End_Time__c); 
        if(ResourceList[i].Tue_Break_Start_Time__c!=null)  rw.Tue_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Break_Start_Time__c);
        if(ResourceList[i].Tue_Break_End_Time__c!=null) rw.Tue_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Break_End_Time__c);           
        if(ResourceList[i].Wed_Break_Start_Time__c!=null) rw.Wed_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Break_Start_Time__c);
        if(ResourceList[i].Wed_Break_End_Time__c!=null)  rw.Wed_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Break_End_Time__c);
        if(ResourceList[i].Thu_Break_Start_Time__c!=null) rw.Thu_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Break_Start_Time__c);
        if(ResourceList[i].Thu_Break_End_Time__c!=null) rw.Thu_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Break_End_Time__c);            
        if(ResourceList[i].Fri_Break_Start_Time__c!=null) rw.Fri_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Break_Start_Time__c);
        if(ResourceList[i].Fri_Break_End_Time__c!=null) rw.Fri_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Break_End_Time__c);
        if(ResourceList[i].Sat_Break_Start_Time__c!=null) rw.Sat_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Break_Start_Time__c);
        if(ResourceList[i].Sat_Break_End_Time__c!=null) rw.Sat_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Break_End_Time__c);
        if(ResourceList[i].Sun_Break_Start_Time__c!=null) rw.Sun_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Break_Start_Time__c);
        if(ResourceList[i].Sun_Break_End_Time__c!=null) rw.Sun_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Break_End_Time__c); 
         
        cpList=new List<ERP7__Capacity__c>();
        for(Integer j=0; j<DateList.size(); j++){
           TimeOffWrp tw=new TimeOffWrp();
           try{ 
           cpList=ResCapMap.get(ResourceList[i].Id+':'+DateList[j]);
           if(cpList!=null){
             tw.Capacity=cpList[0].ERP7__Capacity_Hrs__c;
             tw.RemainingCapacity=cpList[0].ERP7__Remaining_Capacity_Hrs__c;
             if(cpList[0].ERP7__Demand_Hrs__c!=null) tw.Demand=cpList[0].ERP7__Demand_Hrs__c;//response.getReturnValue()
             else tw.Demand=0;  
            }
           }catch(Exception e2){ } 
              
           tw.Start_Time=null; tw.End_Time=null;      
           //if(rw.End_Date>=DateList[j] && ResourceList[i].Start_Date__c<=DateList[j] && DateList[j]>=System.today()){
            isHoliday=isTimeOff=false;   
            if(Holidays.contains(DateList[j]) && ResourceList[i].ERP7__Override_Holidays__c==false) isHoliday=true; // && ResourceList[i].ERP7__Override_Holidays__c==false
            
            if(isHoliday==false && TimeOffList!=null)  
            for (ERP7__Time_Off__c to: TimeOffList){
                if (to.ERP7__Start_Date__c <= DateList[j] && to.ERP7__End_Date__c >= DateList[j]) {
                    isTimeOff = true; Break;
                }
            }
              
              
            String DayName=getWeekDayNameOfDate(DateList[j]);           
            if(DayName=='Mon'){ 
                tw.Start_Time=rw.Mon_Start_Time; 
                tw.End_Time=rw.Mon_End_Time;                 
                tw.BST=rw.Mon_Break_Start_Time;
                tw.BET=rw.Mon_Break_End_Time;
                if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today() || tw.Start_Time==null || tw.End_Time==null) tw.isAvailable=false;
                //if(tw.Start_Time!=null && tw.End_Time!=null) tw.isAvailable=true; else tw.isAvailable=false;
                //else tw.isAvailable=true;
             }  
                        
            if(DayName=='Tue'){
                tw.Start_Time=rw.Tue_Start_Time; 
                tw.End_Time=rw.Tue_End_Time;                 
                tw.BST=rw.Tue_Break_Start_Time;
                tw.BET=rw.Tue_Break_End_Time;
                if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today() || tw.Start_Time==null || tw.End_Time==null) tw.isAvailable=false;
                //if(tw.Start_Time!=null && tw.End_Time!=null) tw.isAvailable=true; else tw.isAvailable=false;
            }
            
            
            if(DayName=='Wed'){
                tw.Start_Time=rw.Wed_Start_Time; 
                tw.End_Time=rw.Wed_End_Time;                 
                tw.BST=rw.Wed_Break_Start_Time;
                tw.BET=rw.Wed_Break_End_Time;
                if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today() || tw.Start_Time==null || tw.End_Time==null) tw.isAvailable=false;
                //if(tw.Start_Time!=null && tw.End_Time!=null) tw.isAvailable=true; else tw.isAvailable=false; 
            }
            
            if(DayName=='Thu'){
                tw.Start_Time=rw.Thu_Start_Time; 
                tw.End_Time=rw.Thu_End_Time;                 
                tw.BST=rw.Thu_Break_Start_Time;
                tw.BET=rw.Thu_Break_End_Time;                
                if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today() || tw.Start_Time==null || tw.End_Time==null) tw.isAvailable=false;
                //if(tw.Start_Time!=null && tw.End_Time!=null) tw.isAvailable=true; else tw.isAvailable=false; 
            }
            if(DayName=='Fri'){
                tw.Start_Time=rw.Fri_Start_Time; 
                tw.End_Time=rw.Fri_End_Time;                 
                tw.BST=rw.Fri_Break_Start_Time;
                tw.BET=rw.Fri_Break_End_Time;
                if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today() || tw.Start_Time==null || tw.End_Time==null) tw.isAvailable=false;
               // if(tw.Start_Time!=null && tw.End_Time!=null) tw.isAvailable=true; else tw.isAvailable=false; 
            }
            if(DayName=='Sat'){
                tw.Start_Time=rw.Sat_Start_Time; 
                tw.End_Time=rw.Sat_End_Time;                 
                tw.BST=rw.Sat_Break_Start_Time;
                tw.BET=rw.Sat_Break_End_Time;
                if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today() || tw.Start_Time==null || tw.End_Time==null) tw.isAvailable=false;
                //if(tw.Start_Time!=null && tw.End_Time!=null) tw.isAvailable=true; else tw.isAvailable=false; 
            }
            if(DayName=='Sun'){
                tw.Start_Time=rw.Sun_Start_Time; 
                tw.End_Time=rw.Sun_End_Time;                 
                tw.BST=rw.Sun_Break_Start_Time;
                tw.BET=rw.Sun_Break_End_Time; 
                if(rw.End_Date<DateList[j] || ResourceList[i].Start_Date__c>DateList[j] || DateList[j]<System.today() || tw.Start_Time==null || tw.End_Time==null) tw.isAvailable=false;
                //if(tw.Start_Time!=null && tw.End_Time!=null) tw.isAvailable=true; else tw.isAvailable=false; 
            }    
            if(isHoliday || isTimeOff){ if(isHoliday) tw.isHoliday=true;else if(isTimeOff) tw.isTimeOff=true; tw.isAvailable=false;
            } 
            if(rw.End_Date>=DateList[0]) rw.TimeOffList.add(tw); 
              
        rw.Day=DateList[j];             
        } 
             
        //if(rw.TimeOffList.size()>0) DayWiseList.add(rw); 
        Boolean isValidResource=false;
        for(TimeOffWrp day:rw.TimeOffList) if(day.isAvailable && day.Start_Time!=null && day.End_Time!=null){
            isValidResource=true; Break;  
        }
        if(rw.TimeOffList.size()>0 && isValidResource) DayWiseList.add(rw); 
        
            
    } 
      }catch(Exception ex){}   
        return DayWiseList;
    }
    
    @AuraEnabled 
    Public static GroupWrp getAddGroup(){
        Resourcewrp rw=new ResourceWrp();
        TimeOffWrp to=new TimeOffWrp();        
        for(Integer i=1; i<=7; i++){
            to=new TimeOffWrp();
            to.StartTime=null; to.EndTime=null; to.BSTime=null; to.BETime=null; to.Start_Time=null; to.End_Time=null; to.BS_Time=null;  to.BE_Time=null;
            rw.TimeOffList.add(to); 
        }
        GroupWrp gwrp=new GroupWrp();
        UserWrp uw=new UserWrp();
        uw.ResourceAvailabilityList.add(rw);
        gwrp.UserAvailabilityList.add(uw);
        return gwrp;
    }
    
    @AuraEnabled 
    Public static ResourceWrp getAddResource() {
        Resourcewrp rw=new ResourceWrp();
        TimeOffWrp to=new TimeOffWrp();        
        for(Integer i=1; i<=7; i++){
            to=new TimeOffWrp();
            to.StartTime=null; to.EndTime=null; to.BSTime=null; to.BETime=null; to.Start_Time=null; to.End_Time=null; to.BS_Time=null;  to.BE_Time=null;
            rw.TimeOffList.add(to); 
        }
        rw.Start_Date=System.today(); rw.End_Date=System.today().addYears(1); rw.TeamId=null;
        return rw;
    }
    
    @AuraEnabled 
    Public static UserWrp getAddUser() {
        UserWrp uw=new UserWrp();
        Resourcewrp rw=new ResourceWrp();
        TimeOffWrp to=new TimeOffWrp();        
        for(Integer i=1; i<=7; i++){
            to=new TimeOffWrp();
            to.StartTime=null; to.EndTime=null; to.BSTime=null; to.BETime=null; to.Start_Time=null; to.End_Time=null; to.BS_Time=null;  to.BE_Time=null;
            rw.TimeOffList.add(to); 
        }
        uw.ResourceAvailabilityList.add(rw);
        return uw;
    }
    
    @AuraEnabled 
    Public static List<GroupWrp> getUsersAvailibilities( Date selectedDate, String ServiceId, String LocationId, String UserId) { 
        if(selectedDate==null) selectedDate=System.today();
        UsersShiftMatch us=new UsersShiftMatch();
        GroupWrp groupWrap=new GroupWrp();
        List<GroupWrp> groupList=new  List<GroupWrp>(); 
        List<UserWrp> UserAvailabilityList=new  List<UserWrp>(); //String QryFilter = (String.isNotEmpty(val))?' AND ERP7__Vendor__c IN: ids':''; 
        list<ERP7__Resource__c> ResourceList=new  list<ERP7__Resource__c>();
        list<ERP7__Resource__c> Resources=new  list<ERP7__Resource__c>();
        
        list<ERP7__Resource_Requirement__c> RRList=new list<ERP7__Resource_Requirement__c>();
        String ServiceFilter = (String.isNotEmpty(ServiceId))?' AND ERP7__Work_Planner__r.ERP7__Product__c=:ServiceId':''; 
        String LocationFilter = (String.isNotEmpty(LocationId))?' AND ERP7__Work_Planner__r.ERP7__WorkCenter__c=:LocationId':'';
        String UserFilter1 = (String.isNotEmpty(UserId))?' AND ERP7__User__c=:UserId':''; 
        String Status='Approved';
        String StatusFilter = '  AND ERP7__Work_Planner__r.ERP7__Status__c=:Status';
        
        String RRString='SELECT Id, Name, ERP7__Work_Planner__c,ERP7__Work_Planner__r.ERP7__WorkCenter__c, ERP7__Resource_Group__c,ERP7__Work_Planner__r.ERP7__Product__c '+
            'FROM ERP7__Resource_Requirement__c '+ 
            'WHERE ERP7__Resource_Group__c!=null AND ERP7__Work_Planner__c !=null AND ERP7__Work_Planner__r.ERP7__WorkCenter__r.ERP7__Active__c=true AND ERP7__Work_Planner__r.ERP7__Product__c!=null AND ERP7__Work_Planner__r.ERP7__Product__r.IsActive=true '+String.escapeSingleQuotes(ServiceFilter)+String.escapeSingleQuotes(LocationFilter)+String.escapeSingleQuotes(StatusFilter)+'  Order By LastModifiedDate';//ServiceFilterDum
        RRList=database.query(RRString);
        
        set<String> RGIdsUser=new set<String>();
        for(ERP7__Resource_Requirement__c rr:RRList) RGIdsUser.add(rr.ERP7__Resource_Group__c);
        
        Map<Id, List<ERP7__Resource_Requirement__c>> GroupRRMap=new Map<Id, List<ERP7__Resource_Requirement__c>>();
        list<ERP7__Resource_Requirement__c> RRListNew=new list<ERP7__Resource_Requirement__c>();
        
        for(ERP7__Resource_Requirement__c rr:RRList){
            RRListNew=new list<ERP7__Resource_Requirement__c>();
            if (GroupRRMap.containsKey(rr.ERP7__Resource_Group__c)) RRListNew=GroupRRMap.get(rr.ERP7__Resource_Group__c); 
            RRListNew.add(rr); 
            GroupRRMap.put(rr.ERP7__Resource_Group__c, RRListNew);                    
        }
        String allFields = UtilClass.selectStarFromSObject('ERP7__Resource__c');
        Date TodayDate=System.today();
        
        Map<String, Set<String>> UserTypeMap=getUserType();     
        String TeamFilter=''; String UserFilter=''; String LogInUserId=userInfo.getUserId();      
        Set<String> TeamIds=new Set<String>();
        if(UserTypeMap.keySet().size()>0) TeamIds.addAll(UserTypeMap.get(new List<String>(UserTypeMap.keySet())[0]));           
        if(new List<String>(UserTypeMap.keySet())[0]=='supervisor' && TeamIds.size()>0) TeamFilter = (new List<String>(UserTypeMap.keySet())[0]=='supervisor')?' AND ERP7__Team__c IN:TeamIds':''; 
        else if(new List<String>(UserTypeMap.keySet())[0]=='normal') UserFilter = (new List<String>(UserTypeMap.keySet())[0]=='normal')?' AND ERP7__User__c=:LogInUserId':'';  
        String queryString = 'select ERP7__User__r.Name, ERP7__User__r.fullphotourl, ERP7__Resource_Group__r.Name, ERP7__Team__r.Name, ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Resource__c where ERP7__User__r.IsActive=true AND ERP7__End_Date__c>=:TodayDate AND ERP7__Resource_Group__c IN:RGIdsUser AND RecordType.DeveloperName!=\'Room\' '+String.escapeSingleQuotes(UserFilter1)+String.escapeSingleQuotes(us.ResourceAvailabiliyFilter)+String.escapeSingleQuotes(TeamFilter+UserFilter)+' ORDER By ERP7__User__r.Name, CreatedDate ASC';  
        Resources=Database.query(queryString); 
        set<Id> UserIds=new set<Id>();                                                                                    
        for(ERP7__Resource__c res:Resources) UserIds.add(res.ERP7__User__c);
        List<ERP7__Leave_Entitlements_Holidays__c> HolidayList=new List<ERP7__Leave_Entitlements_Holidays__c>();
        Set<Date> Holidays=new Set<Date>();
        for(ERP7__Leave_Entitlements_Holidays__c hd:HolidayList) Holidays.add(hd.ERP7__Date_Of_Holiday__c);
        Boolean isHoliday=false;
        
        List<ResourceWrp> DayWiseList=new List<ResourceWrp>();                                                                                       
        list<Date> DateList=getDates(selectedDate);     
        List<User> UserList=[SELECT Id, Name, Email, Phone, fullphotourl FROM User WHERE Id IN:UserIds];
        
        List<ERP7__Resource_Group__c> Groups=new List<ERP7__Resource_Group__c>(); 
        String groupAllFields = UtilClass.selectStarFromSObject('ERP7__Resource_Group__c');
        String groupString = 'select ' + String.escapeSingleQuotes(groupAllFields) + ' from ERP7__Resource_Group__c where Id IN:RGIdsUser ORDER By ERP7__Start_Date__c ASC'; // And (ERP7__End_Date__c>=:TodayDate OR ERP7__End_Date__c=null)  
        Groups=Database.query(groupString); 
        list<ERP7__Resource__c> RList=new  list<ERP7__Resource__c>();
        UserWrp UserAvailability=new UserWrp();
        
        for(Integer g=0; g<Groups.size(); g++){
            groupWrap=new GroupWrp();
            groupWrap.GroupId=Groups[g].Id;
            if(new List<String>(UserTypeMap.keySet())[0]=='normal') { 
                groupWrap.LoginUserId=LogInUserId; }
            if(GroupRRMap.get(Groups[g].Id).size()>0) {        
                if(GroupRRMap.get(Groups[g].Id)[0].ERP7__Work_Planner__r.ERP7__Product__c!=null) groupWrap.ServiceId=GroupRRMap.get(Groups[g].Id)[0].ERP7__Work_Planner__r.ERP7__Product__c;
                if(GroupRRMap.get(Groups[g].Id)[0].ERP7__Work_Planner__r.ERP7__WorkCenter__c!=null) groupWrap.LocationId=GroupRRMap.get(Groups[g].Id)[0].ERP7__Work_Planner__r.ERP7__WorkCenter__c;
            }  
            UserAvailabilityList=new  List<UserWrp>();              
            for(Integer u=0; u<UserList.size(); u++){
                UserAvailability=new UserWrp(); 
                RList=new  list<ERP7__Resource__c>();        
                for(Integer i=0; i<Resources.size(); i++){           
                    if(Groups[g].ERP7__Start_Date__c!=null && Groups[g].ERP7__End_Date__c!=null){  
                        if(Groups[g].Id==Resources[i].ERP7__Resource_Group__c && UserList[u].Id==Resources[i].ERP7__User__c
                           && Resources[i].ERP7__Start_Date__c<=Groups[g].ERP7__End_Date__c
                           && Resources[i].ERP7__End_Date__c>=Groups[g].ERP7__Start_Date__c) 
                            RList.add(Resources[i]); 
                    }else{
                        if(Groups[g].Id==Resources[i].ERP7__Resource_Group__c && UserList[u].Id==Resources[i].ERP7__User__c)  RList.add(Resources[i]); 
                    }            
                }     
                ResourceList=RList;
                DayWiseList=new List<ResourceWrp>();     
                for(Integer i=0; i<ResourceList.size(); i++){ 
                    if(groupWrap.StartDate!=null){
                        if(ResourceList[i].Start_Date__c < groupWrap.StartDate) groupWrap.StartDate=ResourceList[i].Start_Date__c;
                    }else groupWrap.StartDate=ResourceList[i].Start_Date__c;
                    
                    if(groupWrap.EndDate!=null){
                        if(ResourceList[i].End_Date__c > groupWrap.EndDate) groupWrap.EndDate=ResourceList[i].End_Date__c; 
                    }else groupWrap.EndDate=ResourceList[i].End_Date__c;
                    
                    ResourceWrp rw=new ResourceWrp();   
                    if(ResourceList[i].Name!=null) rw.Id=ResourceList[i].Id; rw.Name=ResourceList[i].Name;
                    if(ResourceList[i].ERP7__Resource_Group__c!=null) rw.GroupName=ResourceList[i].ERP7__Resource_Group__r.Name;
                    if(ResourceList[i].ERP7__Resource_Group__c!=null) rw.GroupId=ResourceList[i].ERP7__Resource_Group__c;
                    if(ResourceList[i].ERP7__User__c!=null) rw.UserId=ResourceList[i].ERP7__User__c; 
                    
                    if(ResourceList[i].Start_Date__c!=null) rw.Start_Date=ResourceList[i].Start_Date__c;
                    if(ResourceList[i].End_Date__c!=null) rw.End_Date=ResourceList[i].End_Date__c;          
                    if(ResourceList[i].Break_Start_Time__c!=null) rw.Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Break_Start_Time__c);             
                    if(ResourceList[i].Break_End_Time__c!=null) rw.Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Break_End_Time__c); 
                    
                    /*FRO WEEK DAYS TIME*/
                    rw.Mon_Start_Time=null; rw.Mon_End_Time=null; rw.Tue_Start_Time=null; rw.Tue_End_Time=null; rw.Wed_Start_Time=null; rw.Wed_End_Time=null; rw.Thu_Start_Time=null; rw.Thu_End_Time=null; rw.Fri_Start_Time=null; rw.Fri_End_Time=null; rw.Sat_Start_Time=null; rw.Sat_End_Time=null; rw.Sun_Start_Time=null; rw.Sun_End_Time=null;     
                    if(ResourceList[i].Mon_Start_Time__c!=null) rw.Mon_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Start_Time__c);
                    if(ResourceList[i].Mon_End_Time__c!=null) rw.Mon_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_End_Time__c); 
                    if(ResourceList[i].Tue_Start_Time__c!=null)  rw.Tue_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Start_Time__c);
                    if(ResourceList[i].Tue_End_Time__c!=null) rw.Tue_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_End_Time__c);           
                    if(ResourceList[i].Wed_Start_Time__c!=null) rw.Wed_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Start_Time__c);
                    if(ResourceList[i].Wed_End_Time__c!=null)  rw.Wed_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_End_Time__c);
                    if(ResourceList[i].Thu_Start_Time__c!=null) rw.Thu_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Start_Time__c);
                    if(ResourceList[i].Thu_End_Time__c!=null) rw.Thu_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_End_Time__c);            
                    if(ResourceList[i].Fri_Start_Time__c!=null) rw.Fri_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Start_Time__c);
                    if(ResourceList[i].Fri_End_Time__c!=null) rw.Fri_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_End_Time__c);
                    if(ResourceList[i].Sat_Start_Time__c!=null) rw.Sat_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Start_Time__c);
                    if(ResourceList[i].Sat_End_Time__c!=null) rw.Sat_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_End_Time__c);
                    if(ResourceList[i].Sun_Start_Time__c!=null) rw.Sun_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Start_Time__c);
                    if(ResourceList[i].Sun_End_Time__c!=null) rw.Sun_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_End_Time__c); 
                    
                    /*FRO WEEK DAYS BREAK TIME*/
                    rw.Mon_Break_Start_Time=null; rw.Mon_Break_End_Time=null; rw.Tue_Break_Start_Time=null; rw.Tue_Break_End_Time=null; rw.Wed_Break_Start_Time=null; rw.Wed_Break_End_Time=null; rw.Thu_Break_Start_Time=null; rw.Thu_Break_End_Time=null; rw.Fri_Break_Start_Time=null; rw.Fri_Break_End_Time=null; rw.Sat_Break_Start_Time=null; rw.Sat_Break_End_Time=null; rw.Sun_Break_Start_Time=null; rw.Sun_Break_End_Time=null;    
                    if(ResourceList[i].Mon_Break_Start_Time__c!=null) rw.Mon_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Break_Start_Time__c);
                    if(ResourceList[i].Mon_Break_End_Time__c!=null) rw.Mon_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Break_End_Time__c); 
                    if(ResourceList[i].Tue_Break_Start_Time__c!=null)  rw.Tue_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Break_Start_Time__c);
                    if(ResourceList[i].Tue_Break_End_Time__c!=null) rw.Tue_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Break_End_Time__c);           
                    if(ResourceList[i].Wed_Break_Start_Time__c!=null) rw.Wed_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Break_Start_Time__c);
                    if(ResourceList[i].Wed_Break_End_Time__c!=null)  rw.Wed_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Break_End_Time__c);
                    if(ResourceList[i].Thu_Break_Start_Time__c!=null) rw.Thu_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Break_Start_Time__c);
                    if(ResourceList[i].Thu_Break_End_Time__c!=null) rw.Thu_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Break_End_Time__c);            
                    if(ResourceList[i].Fri_Break_Start_Time__c!=null) rw.Fri_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Break_Start_Time__c);
                    if(ResourceList[i].Fri_Break_End_Time__c!=null) rw.Fri_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Break_End_Time__c);
                    if(ResourceList[i].Sat_Break_Start_Time__c!=null) rw.Sat_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Break_Start_Time__c);
                    if(ResourceList[i].Sat_Break_End_Time__c!=null) rw.Sat_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Break_End_Time__c);
                    if(ResourceList[i].Sun_Break_Start_Time__c!=null) rw.Sun_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Break_Start_Time__c);
                    if(ResourceList[i].Sun_Break_End_Time__c!=null) rw.Sun_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Break_End_Time__c); 
                    
                    for(Integer j=0; j<DateList.size(); j++){
                        TimeOffWrp tw=new TimeOffWrp(); tw.Start_Time=null; tw.End_Time=null;             
                        isHoliday=false;   
                        if(Holidays.contains(DateList[j]) && ResourceList[i].ERP7__Override_Holidays__c==false) isHoliday=true;
                        String DayName=getWeekDayNameOfDate(DateList[j]);           
                        
                        if(DayName=='Mon' && isHoliday==false){
                            if(ResourceList[i].Mon_Start_Time__c!=null) tw.StartTime=ResourceList[i].Mon_Start_Time__c;
                            if(ResourceList[i].Mon_End_Time__c!=null) tw.EndTime=ResourceList[i].Mon_End_Time__c;                   
                            if(ResourceList[i].Mon_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Mon_Break_Start_Time__c;    
                            if(ResourceList[i].Mon_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Mon_Break_End_Time__c;                        
                        } 
                        
                        if(DayName=='Tue' && isHoliday==false){
                            if(ResourceList[i].Tue_Start_Time__c!=null) tw.StartTime=ResourceList[i].Tue_Start_Time__c;
                            if(ResourceList[i].Tue_End_Time__c!=null) tw.EndTime=ResourceList[i].Tue_End_Time__c;                   
                            if(ResourceList[i].Tue_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Tue_Break_Start_Time__c;    
                            if(ResourceList[i].Tue_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Tue_Break_End_Time__c;                        
                        } 
                        
                        
                        if(DayName=='Wed' && isHoliday==false){
                            if(ResourceList[i].Wed_Start_Time__c!=null) tw.StartTime=ResourceList[i].Wed_Start_Time__c;
                            if(ResourceList[i].Wed_End_Time__c!=null) tw.EndTime=ResourceList[i].Wed_End_Time__c;                   
                            if(ResourceList[i].Wed_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Wed_Break_Start_Time__c;    
                            if(ResourceList[i].Wed_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Wed_Break_End_Time__c;                        
                        } 
                        
                        
                        if(DayName=='Thu' && isHoliday==false){
                            if(ResourceList[i].Thu_Start_Time__c!=null) tw.StartTime=ResourceList[i].Thu_Start_Time__c;
                            if(ResourceList[i].Thu_End_Time__c!=null) tw.EndTime=ResourceList[i].Thu_End_Time__c;                   
                            if(ResourceList[i].Thu_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Thu_Break_Start_Time__c;    
                            if(ResourceList[i].Thu_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Thu_Break_End_Time__c;                        
                        } 
                        
                        
                        if(DayName=='Fri' && isHoliday==false){
                            if(ResourceList[i].Fri_Start_Time__c!=null) tw.StartTime=ResourceList[i].Fri_Start_Time__c;
                            if(ResourceList[i].Fri_End_Time__c!=null) tw.EndTime=ResourceList[i].Fri_End_Time__c;                   
                            if(ResourceList[i].Fri_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Fri_Break_Start_Time__c;    
                            if(ResourceList[i].Fri_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Fri_Break_End_Time__c;                        
                        } 
                        
                        
                        if(DayName=='Sat' && isHoliday==false){
                            if(ResourceList[i].Sat_Start_Time__c!=null) tw.StartTime=ResourceList[i].Sat_Start_Time__c;
                            if(ResourceList[i].Sat_End_Time__c!=null) tw.EndTime=ResourceList[i].Sat_End_Time__c;                   
                            if(ResourceList[i].Sat_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Sat_Break_Start_Time__c;    
                            if(ResourceList[i].Sat_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Sat_Break_End_Time__c;                        
                        }
                        
                        if(DayName=='Sun' && isHoliday==false){
                            if(ResourceList[i].Sun_Start_Time__c!=null) tw.StartTime=ResourceList[i].Sun_Start_Time__c;
                            if(ResourceList[i].Sun_End_Time__c!=null) tw.EndTime=ResourceList[i].Sun_End_Time__c;                   
                            if(ResourceList[i].Sun_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Sun_Break_Start_Time__c;    
                            if(ResourceList[i].Sun_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Sun_Break_End_Time__c;                        
                        }                               
                        rw.TimeOffList.add(tw);  rw.Day=DateList[j];
                        if(ResourceList[i].ERP7__Team__c!=null) rw.TeamId=ResourceList[i].ERP7__Team__c;
                    }
                    DayWiseList.add(rw);
                }    
                UserAvailability.ResourceAvailabilityList=DayWiseList; 
                UserAvailability.User=UserList[u];    
                if(UserAvailability.ResourceAvailabilityList.size()>0) UserAvailabilityList.add(UserAvailability);
                
            }
            groupWrap.UserAvailabilityList=UserAvailabilityList;    
            if(groupWrap.UserAvailabilityList.size()>0) groupList.add(groupWrap);        
        }  
       return groupList;
    }
    
    @AuraEnabled 
    Public static ResourceWrp getResourceClone() { 
        return new ResourceWrp();
    }                    
    @AuraEnabled
    Public static String getDeleteResource(String ResourceId) {
        if(ERP7__Resource__c.sObjectType.getDescribe().isDeletable()) delete new ERP7__Resource__c(Id=ResourceId); else{ }
        return ResourceId;          
    } 
    
    
    @AuraEnabled
    Public static ERP7__Resource_Group__c getGroupRecord(String GroupId) {
        return [SELECT Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c FROM ERP7__Resource_Group__c WHERE Id=:GroupId];       
    } 
    
    @AuraEnabled
    Public static void Save(String GroupWrapperList){
        try{ 
            List < GroupWrp > GroupList = (List < GroupWrp > ) JSON.deserialize(GroupWrapperList, List < GroupWrp > .class);
            Boolean check = false;
            list < Resourcewrp > DayWiseList;
            Map<Id,User> UserMap=new Map<Id,User>([SELECT Id, Name, Email, Phone, fullphotourl FROM User WHERE IsActive=true]); 
            
            list < ERP7__Work_Planner__c > WrokPlannerList = new list < ERP7__Work_Planner__c > ();
            WrokPlannerList = [SELECT Id, Name, ERP7__WorkCenter__c, ERP7__Product__c,  ERP7__Status__c
                               FROM ERP7__Work_Planner__c
                               WHERE ERP7__Status__c = 'Approved'
                               AND ERP7__WorkCenter__r.ERP7__Active__c = true
                               AND ERP7__Product__r.IsActive = true
                               Order By LastModifiedDate
                              ];
            
            Map < ID, ERP7__Work_Center__c > LocationMap = new Map < ID, ERP7__Work_Center__c > ([SELECT Id, Name FROM ERP7__Work_Center__c WHERE ERP7__Active__c = true]);
            Map < ID, Product2 > ServiceMap = new Map < ID, Product2 > ([SELECT Id, Name FROM Product2 WHERE IsActive = true]);
            Map < ID, ERP7__Resource_Group__c > GroupMap = new Map < ID, ERP7__Resource_Group__c > ([SELECT Id, Name, ERP7__Default_Team__c  FROM ERP7__Resource_Group__c]);     
            
            WrokPlannerList = [SELECT Id, Name, ERP7__Product__c, ERP7__WorkCenter__c,  ERP7__Status__c
                               FROM ERP7__Work_Planner__c
                               WHERE ERP7__Status__c = 'Approved'
                               AND ERP7__WorkCenter__r.ERP7__Active__c = true
                               AND ERP7__Product__r.IsActive = true
                               Order By LastModifiedDate
                              ];
            
            
            ERP7__Work_Planner__c WrokPlanner = new ERP7__Work_Planner__c();
            ERP7__Resource_Group__c NewGroup = new ERP7__Resource_Group__c();
            ERP7__Resource_Requirement__c NewResourceRequirement = new ERP7__Resource_Requirement__c();
            Boolean isWP = false;
            
            Date FirstDate=System.today();
            for(Integer d=0; d<=7; d++){
                FirstDate=System.today()-d;
                if(getWeekDayNameOfDate(FirstDate)=='Mon') Break;           
            }
            Date MondayDate=FirstDate;
            for (integer k = 0; k < GroupList.size(); k++) {       
                if(GroupList[k].StartDate == null) GroupList[k].StartDate = System.today();
                if(GroupList[k].EndDate == null) GroupList[k].EndDate = System.today().addYears(1);
                if(String.isEmpty(GroupList[k].GroupId)) GroupList[k].GroupId=null;
                if(String.isEmpty(GroupList[k].ServiceId)) GroupList[k].ServiceId=null;
                if(String.isEmpty(GroupList[k].LocationId)) GroupList[k].LocationId=null;        
                Boolean isNewGroup=false;
                if (GroupList[k].GroupId == null) {
                    ERP7__Team__c Team=new ERP7__Team__c();
                    if(Schema.sObjectType.ERP7__Team__c.fields.Name.isCreateable() && Schema.SObjectType.ERP7__Team__c.fields.Name.isUpdateable()) Team.Name = ServiceMap.get(GroupList[k].ServiceId).Name + ' - ' + LocationMap.get(GroupList[k].LocationId).Name;
                    if(Schema.sObjectType.ERP7__Team__c.isCreateable() && Schema.SObjectType.ERP7__Team__c.isUpdateable()){insert Team;}else{/*not allowed to insert*/}
                    
                    NewGroup = new ERP7__Resource_Group__c();
                    if(Schema.sObjectType.ERP7__Resource_Group__c.fields.Name.isCreateable()) NewGroup.Name = ServiceMap.get(GroupList[k].ServiceId).Name + ' - ' + LocationMap.get(GroupList[k].LocationId).Name;
                    if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__Start_Date__c.isCreateable()) NewGroup.ERP7__Start_Date__c = GroupList[k].StartDate;
                    if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__End_Date__c.isCreateable()) NewGroup.ERP7__End_Date__c = GroupList[k].EndDate;
                    if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__Default_Team__c.isCreateable()) NewGroup.ERP7__Default_Team__c=Team.Id;
                    if(Schema.SObjectType.ERP7__Resource_Group__c.isCreateable()){insert NewGroup;}else{/*not allowed to insert*/}
                    GroupList[k].GroupId = NewGroup.Id;
                    isNewGroup=true;
                    GroupMap.put(NewGroup.Id,NewGroup);
                }else{
                    ERP7__Resource_Group__c upresg = new ERP7__Resource_Group__c(Id=GroupList[k].GroupId);
                    if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__Start_Date__c.isUpdateable()) upresg.ERP7__Start_Date__c=GroupList[k].StartDate; 
                    if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__End_Date__c.isUpdateable()) upresg.ERP7__End_Date__c=GroupList[k].EndDate;
                    if(Schema.SObjectType.ERP7__Resource_Group__c.isUpdateable()) update upresg; else{ }
                }
                
                
                isWP = false;
                WrokPlanner = new ERP7__Work_Planner__c();
                for (ERP7__Work_Planner__c wp: WrokPlannerList) { 
                    if (GroupList[k].ServiceId == wp.ERP7__Product__c && GroupList[k].LocationId == wp.ERP7__WorkCenter__c) {
                        isWP = true;
                        WrokPlanner = wp;
                        break;
                    }
                }
                
                
                if (isWP == false && GroupList[k].ServiceId!=null && GroupList[k].LocationId!=null) {
                    if(Schema.sObjectType.ERP7__Work_Planner__c.fields.Name.isCreateable()) WrokPlanner.Name = ServiceMap.get(GroupList[k].ServiceId).Name + ' - ' + LocationMap.get(GroupList[k].LocationId).Name; 
                    if(Schema.sObjectType.ERP7__Work_Planner__c.fields.ERP7__WorkCenter__c.isCreateable()) WrokPlanner.ERP7__WorkCenter__c = GroupList[k].LocationId; 
                    if(Schema.sObjectType.ERP7__Work_Planner__c.fields.ERP7__Product__c.isCreateable()) WrokPlanner.ERP7__Product__c = GroupList[k].ServiceId; 
                    if(Schema.sObjectType.ERP7__Work_Planner__c.fields.ERP7__Status__c.isCreateable()) WrokPlanner.ERP7__Status__c = 'Approved';  
                    if(Schema.SObjectType.ERP7__Work_Planner__c.isCreateable()){insert WrokPlanner;}else{/*not allowed to insert*/}
                }
                
                if(isNewGroup && GroupList[k].ServiceId!=null && GroupList[k].LocationId!=null){
                    NewResourceRequirement = new ERP7__Resource_Requirement__c();
                    if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.Name.isCreateable()) NewResourceRequirement.Name = ServiceMap.get(GroupList[k].ServiceId).Name + ' - ' + LocationMap.get(GroupList[k].LocationId).Name;
                    if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Work_Planner__c.isCreateable()) NewResourceRequirement.ERP7__Work_Planner__c = WrokPlanner.Id;
                    if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Resource_Group__c.isCreateable()) NewResourceRequirement.ERP7__Resource_Group__c = GroupList[k].GroupId;
                    if(Schema.SObjectType.ERP7__Resource_Requirement__c.isCreateable()){ insert NewResourceRequirement; }else{/*not allowed to insert*/}
                }
                List < UserWrp > UserAvailabilityList = GroupList[k].UserAvailabilityList;
                list < ERP7__Resource__c > ResourceList = new list < ERP7__Resource__c > ();
                for (UserWrp usr: UserAvailabilityList) {
                    ResourceList = new list < ERP7__Resource__c > ();
                    DayWiseList = usr.ResourceAvailabilityList;
                    ERP7__Resource__c er = new ERP7__Resource__c();
                    
                    
                    for (ResourceWrp Wrapper: DayWiseList) {
                        er = new ERP7__Resource__c();
                        if (Wrapper.Id != null) er.Id = Wrapper.Id;
                        if (Wrapper.TeamId != null && Schema.sObjectType.ERP7__Resource__c.fields.ERP7__Team__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.ERP7__Team__c.isUpdateable()) er.ERP7__Team__c = Wrapper.TeamId;
                        if (GroupList[k].GroupId != null && Schema.sObjectType.ERP7__Resource__c.fields.ERP7__Resource_Group__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.ERP7__Resource_Group__c.isUpdateable()) er.ERP7__Resource_Group__c = GroupList[k].GroupId;
                        if (GroupMap.get(GroupList[k].GroupId).ERP7__Default_Team__c != null && Schema.sObjectType.ERP7__Resource__c.fields.ERP7__Team__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.ERP7__Team__c.isUpdateable()) er.ERP7__Team__c = GroupMap.get(GroupList[k].GroupId).ERP7__Default_Team__c;
                        list < Date > DateList = getDates(MondayDate); //GroupList[k].StartDate System.today()
                        list < TimeOffWrp > TimeOffList = Wrapper.TimeOffList;
                        
                        for (integer j = 0; j < TimeOffList.size(); j++) {
                            TimeOffWrp tm = TimeOffList[j];
                            String DayName = getWeekDayNameOfDate(DateList[j]);
                            
                            Time StartTime, EndTime, BSTime, BETime;
                            
                            if (tm.Start_Time != null) StartTime = Time.newInstance(Integer.valueOf(tm.Start_Time.split(':')[0]), Integer.valueOf(tm.Start_Time.split(':')[1]), 0, 0); //DateTime.newInstanceGMT(System.today(), tm.StartTime);
                            if (tm.End_Time != null) EndTime = Time.newInstance(Integer.valueOf(tm.End_Time.split(':')[0]), Integer.valueOf(tm.End_Time.split(':')[1]), 0, 0);
                            if (tm.BS_Time != null) BSTime = Time.newInstance(Integer.valueOf(tm.BS_Time.split(':')[0]), Integer.valueOf(tm.BS_Time.split(':')[1]), 0, 0);
                            if (tm.BE_Time != null) BETime = Time.newInstance(Integer.valueOf(tm.BE_Time.split(':')[0]), Integer.valueOf(tm.BE_Time.split(':')[1]), 0, 0);
                            
                            if (DayName == 'Mon') {
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Mon_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Mon_Start_Time__c.isUpdateable()) er.Mon_Start_Time__c = StartTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Mon_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Mon_End_Time__c.isUpdateable()) er.Mon_End_Time__c = EndTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Mon_Break_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Mon_Break_Start_Time__c.isUpdateable()) er.Mon_Break_Start_Time__c = BSTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Mon_Break_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Mon_Break_End_Time__c.isUpdateable()) er.Mon_Break_End_Time__c = BETime;
                                
                            }
                            
                            if (DayName == 'Tue') {
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Tue_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Tue_Start_Time__c.isUpdateable()) er.Tue_Start_Time__c = StartTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Tue_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Tue_End_Time__c.isUpdateable()) er.Tue_End_Time__c = EndTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Tue_Break_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Tue_Break_Start_Time__c.isUpdateable()) er.Tue_Break_Start_Time__c = BSTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Tue_Break_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Tue_Break_End_Time__c.isUpdateable()) er.Tue_Break_End_Time__c = BETime;
                                
                            }
                            
                            if (DayName == 'Wed') {
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Wed_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Wed_Start_Time__c.isUpdateable()) er.Wed_Start_Time__c = StartTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Wed_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Wed_End_Time__c.isUpdateable()) er.Wed_End_Time__c = EndTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Wed_Break_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Wed_Break_Start_Time__c.isUpdateable()) er.Wed_Break_Start_Time__c = BSTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Wed_Break_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Wed_Break_End_Time__c.isUpdateable()) er.Wed_Break_End_Time__c = BETime;
                                
                            }
                            
                            if (DayName == 'Thu') {
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Thu_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Thu_Start_Time__c.isUpdateable()) er.Thu_Start_Time__c = StartTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Thu_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Thu_End_Time__c.isUpdateable()) er.Thu_End_Time__c = EndTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Thu_Break_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Thu_Break_Start_Time__c.isUpdateable()) er.Thu_Break_Start_Time__c = BSTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Thu_Break_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Thu_Break_End_Time__c.isUpdateable()) er.Thu_Break_End_Time__c = BETime;
                                
                            }
                            
                            if (DayName == 'Fri') {
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Fri_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Fri_Start_Time__c.isUpdateable()) er.Fri_Start_Time__c = StartTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Fri_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Fri_End_Time__c.isUpdateable()) er.Fri_End_Time__c = EndTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Fri_Break_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Fri_Break_Start_Time__c.isUpdateable()) er.Fri_Break_Start_Time__c = BSTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Fri_Break_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Fri_Break_End_Time__c.isUpdateable()) er.Fri_Break_End_Time__c = BETime;
                                
                            }
                            
                            if (DayName == 'Sat') {
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Sat_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Sat_Start_Time__c.isUpdateable()) er.Sat_Start_Time__c = StartTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Sat_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Sat_End_Time__c.isUpdateable()) er.Sat_End_Time__c = EndTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Sat_Break_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Sat_Break_Start_Time__c.isUpdateable())er.Sat_Break_Start_Time__c = BSTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Sat_Break_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Sat_Break_End_Time__c.isUpdateable()) er.Sat_Break_End_Time__c = BETime;
                                
                            }
                            
                            
                            if (DayName == 'Sun') {
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Sun_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Sun_Start_Time__c.isUpdateable()) er.Sun_Start_Time__c = StartTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Sun_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Sun_End_Time__c.isUpdateable()) er.Sun_End_Time__c = EndTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Sun_Break_Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Sun_Break_Start_Time__c.isUpdateable()) er.Sun_Break_Start_Time__c = BSTime;
                                if(Schema.sObjectType.ERP7__Resource__c.fields.Sun_Break_End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Sun_Break_End_Time__c.isUpdateable()) er.Sun_Break_End_Time__c = BETime;
                                
                            }
                        }
                        
                        if (er.Id == null && usr.User.Id != null) {
                            if(Schema.sObjectType.ERP7__Resource__c.fields.ERP7__User__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.ERP7__User__c.isUpdateable()) er.ERP7__User__c = usr.User.Id;
                            if(Schema.sObjectType.ERP7__Resource__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Name.isUpdateable()){ if(usr.User.Name!=null) er.Name = usr.User.Name;  else er.Name = UserMap.get(usr.User.Id).Name; }
                            if(Schema.sObjectType.ERP7__Resource__c.fields.Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.Start_Date__c.isUpdateable()){
                                if (GroupList[k].StartDate != null) {  
                                    DateTime dt= GroupList[k].StartDate;
                                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                                    er.Start_Date__c=myDate;
                                }
                            }
                            if(Schema.sObjectType.ERP7__Resource__c.fields.End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Resource__c.fields.End_Date__c.isUpdateable()){
                                if (GroupList[k].EndDate != null) {
                                    DateTime dt= GroupList[k].EndDate;
                                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                                    er.End_Date__c=myDate;
                                }
                            }
                        }
                        ResourceList.add(er);
                    }
                        if(Schema.SObjectType.ERP7__Resource__c.isCreateable() && Schema.SObjectType.ERP7__Resource__c.isUpdateable()){upsert ResourceList;}else{/*not allowed to upsert*/}
                }  
            }
        }catch(Exception ex){ }     
    }
    
    @AuraEnabled
    Public static GroupWrp getUsersAvailibilityByGroup(String GroupWrapper){      
        GroupWrp groupRecord=(GroupWrp) JSON.deserialize(GroupWrapper, GroupWrp .class);
        list<ERP7__Resource_Requirement__c> RRList=new list<ERP7__Resource_Requirement__c>();
        RRList=[SELECT Id, Name, ERP7__Work_Planner__c,ERP7__Work_Planner__r.ERP7__WorkCenter__c, ERP7__Resource_Group__c,ERP7__Work_Planner__r.ERP7__Product__c
                FROM ERP7__Resource_Requirement__c 
                WHERE ERP7__Work_Planner__r.ERP7__Product__c=:groupRecord.ServiceId
                AND ERP7__Work_Planner__r.ERP7__WorkCenter__c=:groupRecord.LocationId
                AND ERP7__Resource_Group__c!=null AND ERP7__Work_Planner__c !=null
                AND ERP7__Work_Planner__r.ERP7__Status__c='Approved'
                AND ERP7__Work_Planner__r.ERP7__WorkCenter__r.ERP7__Active__c=true
                AND ERP7__Work_Planner__r.ERP7__Product__r.IsActive=true
                Order By LastModifiedDate];   
        Set<String> GroupIds=new Set<String>();
        for(ERP7__Resource_Requirement__c rr:RRList) GroupIds.add(rr.ERP7__Resource_Group__c);
        
        List<ResourceWrp> DayWiseList=new List<ResourceWrp>();
        UsersShiftMatch us=new UsersShiftMatch();     
        if(GroupIds.contains(groupRecord.GroupId)){ 
            list<ERP7__Resource__c> ResourceList=new  list<ERP7__Resource__c>(); list<ERP7__Resource__c> Resources=new  list<ERP7__Resource__c>();
            String allFields = UtilClass.selectStarFromSObject('ERP7__Resource__c');
            String GroupId=groupRecord.GroupId; Date TodayDate=System.today();
            DateTime dT2=groupRecord.StartDate;
            Date StartDate = date.newinstance(dT2.year(), dT2.month(), dT2.day());
            DateTime dT1=groupRecord.EndDate; 
            Date EndDate = date.newinstance(dT1.year(), dT1.month(), dT1.day());
            String StartDateFilter = (StartDate!=null)?' AND ERP7__Start_Date__c<=:StartDate':''; String EndDateFilter = (EndDate!=null)?' AND (ERP7__End_Date__c>=:StartDate AND ERP7__End_Date__c>=:EndDate)':'';        
            Map<String, Set<String>> UserTypeMap=getUserType();
            String TeamFilter=''; String UserFilter=''; String LogInUserId=userInfo.getUserId();
            Set<String> TeamIds=new Set<String>();
            if(UserTypeMap.keySet().size()>0) TeamIds.addAll(UserTypeMap.get(new List<String>(UserTypeMap.keySet())[0]));           
            if(new List<String>(UserTypeMap.keySet())[0]=='supervisor' && TeamIds.size()>0) TeamFilter = (new List<String>(UserTypeMap.keySet())[0]=='supervisor')?' AND ERP7__Team__c IN:TeamIds':''; 
            else if(new List<String>(UserTypeMap.keySet())[0]=='normal') UserFilter = (new List<String>(UserTypeMap.keySet())[0]=='normal')?' AND ERP7__User__c=:LogInUserId':'';  
            String queryString = 'select ERP7__User__r.Name, ERP7__User__r.fullphotourl, ERP7__Resource_Group__r.Name, ERP7__Team__r.Name, ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Resource__c where ERP7__User__c!=null AND ERP7__User__r.IsActive=true AND ERP7__End_Date__c>=:TodayDate AND ERP7__Resource_Group__c=:GroupId AND RecordType.DeveloperName!=\'Room\' '+String.escapeSingleQuotes(StartDateFilter)+String.escapeSingleQuotes(EndDateFilter)+String.escapeSingleQuotes(us.ResourceAvailabiliyFilter)+String.escapeSingleQuotes(TeamFilter)+String.escapeSingleQuotes(UserFilter)+' ORDER By  ERP7__User__r.Name, CreatedDate  ASC';  
            Resources=Database.query(queryString); // AND ERP7__Start_Date__c<=:StartDate    AND ERP7__Start_Date__c<=:StartDate AND ERP7__End_Date__c>=:TodayDate
            if(EndDate<StartDate) Resources.clear();
            List<ERP7__Leave_Entitlements_Holidays__c> HolidayList=new List<ERP7__Leave_Entitlements_Holidays__c>();
            Set<Date> Holidays=new Set<Date>();
            for(ERP7__Leave_Entitlements_Holidays__c hd:HolidayList) Holidays.add(hd.ERP7__Date_Of_Holiday__c); //Holidays.add(hd.ERP7__Date__c);
            Boolean isHolyday=false;
            
            Date FirstDate;
            if(StartDate==null) StartDate=System.today();
            if(StartDate!=null){
                for(Integer d=0; d<=7; d++){
                    DateTime dt= StartDate-d;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    FirstDate=myDate;
                    if(getWeekDayNameOfDate(FirstDate)=='Mon') Break;           
                }
            }
            list<Date> DateList=getDates(FirstDate); //groupRecord.StartDate 
            Set<String> UserIds=new Set<String>();
            for(ERP7__Resource__c res:Resources) UserIds.add(res.ERP7__User__c);    
            List<User> UserList=[SELECT Id, Name, Email, Phone, fullphotourl FROM User WHERE Id=:UserIds];
            
            
            List<UserWrp> UserAvailabilityList=new  List<UserWrp>(); 
            list<ERP7__Resource__c> RList=new  list<ERP7__Resource__c>(); 
            UserWrp UserAvailability=new UserWrp(); 
            for(Integer u=0; u<UserList.size(); u++){
                UserAvailability=new UserWrp();
                
                RList=new  list<ERP7__Resource__c>();
                for(Integer i=0; i<Resources.size(); i++){
                    if(groupRecord.GroupId==Resources[i].ERP7__Resource_Group__c && UserList[u].Id==Resources[i].ERP7__User__c) 
                        RList.add(Resources[i]);  
                }     
                ResourceList=RList;
                DayWiseList=new List<ResourceWrp>();     
                for(Integer i=0; i<ResourceList.size(); i++){ 
                    ResourceWrp rw=new ResourceWrp();
                    
                    if(ResourceList[i].Name!=null) rw.Id=ResourceList[i].Id; rw.Name=ResourceList[i].Name;
                    if(ResourceList[i].ERP7__Resource_Group__c!=null) rw.GroupName=ResourceList[i].ERP7__Resource_Group__r.Name;
                    if(ResourceList[i].ERP7__Resource_Group__c!=null) rw.GroupId=ResourceList[i].ERP7__Resource_Group__c;
                    if(ResourceList[i].ERP7__User__c!=null) rw.UserId=ResourceList[i].ERP7__User__c; 
                    
                    if(ResourceList[i].Start_Date__c!=null) rw.Start_Date=ResourceList[i].Start_Date__c;
                    if(ResourceList[i].End_Date__c!=null) rw.End_Date=ResourceList[i].End_Date__c;          
                    if(ResourceList[i].Break_Start_Time__c!=null) rw.Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Break_Start_Time__c);             
                    if(ResourceList[i].Break_End_Time__c!=null) rw.Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Break_End_Time__c); 
                    
                    /*FRO WEEK DAYS TIME*/
                    rw.Mon_Start_Time=null; rw.Mon_End_Time=null; rw.Tue_Start_Time=null; rw.Tue_End_Time=null; rw.Wed_Start_Time=null; rw.Wed_End_Time=null; rw.Thu_Start_Time=null; rw.Thu_End_Time=null; rw.Fri_Start_Time=null; rw.Fri_End_Time=null; rw.Sat_Start_Time=null; rw.Sat_End_Time=null; rw.Sun_Start_Time=null; rw.Sun_End_Time=null;     
                    if(ResourceList[i].Mon_Start_Time__c!=null) rw.Mon_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Start_Time__c);
                    if(ResourceList[i].Mon_End_Time__c!=null) rw.Mon_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_End_Time__c); 
                    if(ResourceList[i].Tue_Start_Time__c!=null)  rw.Tue_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Start_Time__c);
                    if(ResourceList[i].Tue_End_Time__c!=null) rw.Tue_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_End_Time__c);           
                    if(ResourceList[i].Wed_Start_Time__c!=null) rw.Wed_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Start_Time__c);
                    if(ResourceList[i].Wed_End_Time__c!=null)  rw.Wed_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_End_Time__c);
                    if(ResourceList[i].Thu_Start_Time__c!=null) rw.Thu_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Start_Time__c);
                    if(ResourceList[i].Thu_End_Time__c!=null) rw.Thu_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_End_Time__c);            
                    if(ResourceList[i].Fri_Start_Time__c!=null) rw.Fri_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Start_Time__c);
                    if(ResourceList[i].Fri_End_Time__c!=null) rw.Fri_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_End_Time__c);
                    if(ResourceList[i].Sat_Start_Time__c!=null) rw.Sat_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Start_Time__c);
                    if(ResourceList[i].Sat_End_Time__c!=null) rw.Sat_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_End_Time__c);
                    if(ResourceList[i].Sun_Start_Time__c!=null) rw.Sun_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Start_Time__c);
                    if(ResourceList[i].Sun_End_Time__c!=null) rw.Sun_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_End_Time__c); 
                    
                    /*FRO WEEK DAYS BREAK TIME*/
                    rw.Mon_Break_Start_Time=null; rw.Mon_Break_End_Time=null; rw.Tue_Break_Start_Time=null; rw.Tue_Break_End_Time=null; rw.Wed_Break_Start_Time=null; rw.Wed_Break_End_Time=null; rw.Thu_Break_Start_Time=null; rw.Thu_Break_End_Time=null; rw.Fri_Break_Start_Time=null; rw.Fri_Break_End_Time=null; rw.Sat_Break_Start_Time=null; rw.Sat_Break_End_Time=null; rw.Sun_Break_Start_Time=null; rw.Sun_Break_End_Time=null;    
                    if(ResourceList[i].Mon_Break_Start_Time__c!=null) rw.Mon_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Break_Start_Time__c);
                    if(ResourceList[i].Mon_Break_End_Time__c!=null) rw.Mon_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Mon_Break_End_Time__c); 
                    if(ResourceList[i].Tue_Break_Start_Time__c!=null)  rw.Tue_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Break_Start_Time__c);
                    if(ResourceList[i].Tue_Break_End_Time__c!=null) rw.Tue_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Tue_Break_End_Time__c);           
                    if(ResourceList[i].Wed_Break_Start_Time__c!=null) rw.Wed_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Break_Start_Time__c);
                    if(ResourceList[i].Wed_Break_End_Time__c!=null)  rw.Wed_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Wed_Break_End_Time__c);
                    if(ResourceList[i].Thu_Break_Start_Time__c!=null) rw.Thu_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Break_Start_Time__c);
                    if(ResourceList[i].Thu_Break_End_Time__c!=null) rw.Thu_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Thu_Break_End_Time__c);            
                    if(ResourceList[i].Fri_Break_Start_Time__c!=null) rw.Fri_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Break_Start_Time__c);
                    if(ResourceList[i].Fri_Break_End_Time__c!=null) rw.Fri_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Fri_Break_End_Time__c);
                    if(ResourceList[i].Sat_Break_Start_Time__c!=null) rw.Sat_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Break_Start_Time__c);
                    if(ResourceList[i].Sat_Break_End_Time__c!=null) rw.Sat_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sat_Break_End_Time__c);
                    if(ResourceList[i].Sun_Break_Start_Time__c!=null) rw.Sun_Break_Start_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Break_Start_Time__c);
                    if(ResourceList[i].Sun_Break_End_Time__c!=null) rw.Sun_Break_End_Time=ERPUtilClass.formatTime24Hours(ResourceList[i].Sun_Break_End_Time__c); 
                    
                    for(Integer j=0; j<DateList.size(); j++){
                        TimeOffWrp tw=new TimeOffWrp();               
                        tw.Start_Time=null; tw.End_Time=null;             
                        if(rw.End_Date>=DateList[j]){           
                            isHolyday=false;   
                            if(Holidays.contains(DateList[j]) && ResourceList[i].ERP7__Override_Holidays__c==false) isHolyday=true;
                            String DayName=getWeekDayNameOfDate(DateList[j]);           
                            
                            if(DayName=='Mon' && isHolyday==false){
                                if(ResourceList[i].Mon_Start_Time__c!=null) tw.StartTime=ResourceList[i].Mon_Start_Time__c;
                                if(ResourceList[i].Mon_End_Time__c!=null) tw.EndTime=ResourceList[i].Mon_End_Time__c;                   
                                if(ResourceList[i].Mon_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Mon_Break_Start_Time__c;    
                                if(ResourceList[i].Mon_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Mon_Break_End_Time__c;                        
                            } 
                            
                            if(DayName=='Tue' && isHolyday==false){
                                if(ResourceList[i].Tue_Start_Time__c!=null) tw.StartTime=ResourceList[i].Tue_Start_Time__c;
                                if(ResourceList[i].Tue_End_Time__c!=null) tw.EndTime=ResourceList[i].Tue_End_Time__c;                   
                                if(ResourceList[i].Tue_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Tue_Break_Start_Time__c;    
                                if(ResourceList[i].Tue_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Tue_Break_End_Time__c;                        
                            } 
                            
                            
                            if(DayName=='Wed' && isHolyday==false){
                                if(ResourceList[i].Wed_Start_Time__c!=null) tw.StartTime=ResourceList[i].Wed_Start_Time__c;
                                if(ResourceList[i].Wed_End_Time__c!=null) tw.EndTime=ResourceList[i].Wed_End_Time__c;                   
                                if(ResourceList[i].Wed_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Wed_Break_Start_Time__c;    
                                if(ResourceList[i].Wed_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Wed_Break_End_Time__c;                        
                            } 
                            
                            
                            if(DayName=='Thu' && isHolyday==false){
                                if(ResourceList[i].Thu_Start_Time__c!=null) tw.StartTime=ResourceList[i].Thu_Start_Time__c;
                                if(ResourceList[i].Thu_End_Time__c!=null) tw.EndTime=ResourceList[i].Thu_End_Time__c;                   
                                if(ResourceList[i].Thu_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Thu_Break_Start_Time__c;    
                                if(ResourceList[i].Thu_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Thu_Break_End_Time__c;                        
                            } 
                            
                            
                            if(DayName=='Fri' && isHolyday==false){
                                if(ResourceList[i].Fri_Start_Time__c!=null) tw.StartTime=ResourceList[i].Fri_Start_Time__c;
                                if(ResourceList[i].Fri_End_Time__c!=null) tw.EndTime=ResourceList[i].Fri_End_Time__c;                   
                                if(ResourceList[i].Fri_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Fri_Break_Start_Time__c;    
                                if(ResourceList[i].Fri_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Fri_Break_End_Time__c;                        
                            } 
                            
                            
                            if(DayName=='Sat' && isHolyday==false){
                                if(ResourceList[i].Sat_Start_Time__c!=null) tw.StartTime=ResourceList[i].Sat_Start_Time__c;
                                if(ResourceList[i].Sat_End_Time__c!=null) tw.EndTime=ResourceList[i].Sat_End_Time__c;                   
                                if(ResourceList[i].Sat_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Sat_Break_Start_Time__c;    
                                if(ResourceList[i].Sat_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Sat_Break_End_Time__c;                        
                            }
                            
                            if(DayName=='Sun' && isHolyday==false){
                                if(ResourceList[i].Sun_Start_Time__c!=null) tw.StartTime=ResourceList[i].Sun_Start_Time__c;
                                if(ResourceList[i].Sun_End_Time__c!=null) tw.EndTime=ResourceList[i].Sun_End_Time__c;                   
                                if(ResourceList[i].Sun_Break_Start_Time__c!=null) tw.BSTime=ResourceList[i].Sun_Break_Start_Time__c;    
                                if(ResourceList[i].Sun_Break_End_Time__c!=null) tw.BETime=ResourceList[i].Sun_Break_End_Time__c;                        
                            }
                            
                        }else tw.isAvailable=false;         
                        rw.TimeOffList.add(tw); 
                        rw.Day=DateList[j]; 
                    }
                    DayWiseList.add(rw);
                }    
                UserAvailability.ResourceAvailabilityList=DayWiseList; 
                UserAvailability.User=UserList[u];    
                if(UserAvailability.ResourceAvailabilityList.size()>0) UserAvailabilityList.add(UserAvailability);
            } 
            groupRecord.UserAvailabilityList=UserAvailabilityList; 
            
        }else {/*'No group found');*/}
        return groupRecord;
    } 
     @AuraEnabled
    public static String getCurrentTimeOffReason(Date toDate, String slotDate, String selectedUserId){
        try{
            date mydate = toDate;//date.parse(toDate);
            List<ERP7__Time_Off__c> TO = new List<ERP7__Time_Off__c>();
            TO = [SELECT Id, ERP7__Reason__c FROM ERP7__Time_Off__c WHERE (ERP7__Start_Date__c =: mydate OR ERP7__End_Date__c =: mydate) AND ERP7__User__c =: selectedUserId ORDER BY ERP7__Start_Date__c ASC];
            if(TO.size() > 0) return TO[0].ERP7__Reason__c;
            else return 'No time off available.';
        }
        catch(Exception e){ throw new AuraHandledException(e.getMessage());        }
    }
}