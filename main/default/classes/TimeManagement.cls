public with sharing class TimeManagement {   
   @AuraEnabled 
   Public list<SelectOption> expertLocsList  {set;get;}
   @AuraEnabled 
   Public list<SelectOption> prodServiceList  {set;get;}   
   @AuraEnabled 
   Public list<SelectOption> TeamList         {set;get;}  
   @AuraEnabled 
   Public ERP7__System_Codes__c sysCode {set;get;} 
   @AuraEnabled 
   Public list<ERP7__Time_Off__c> TimeoffList {set;get;}     
   @AuraEnabled 
   Public ERP7__Time_Off__c Timeoff            {set;get;}  
   @AuraEnabled 
   Public list<SelectOption> TOTypeList            {set;get;} 
   @AuraEnabled 
   Public Boolean isSupervisor                     {set;get;} 
   @AuraEnabled 
   Public ERP7__Resource__c Resource           {set;get;}  
   @AuraEnabled 
   Public Date Today                               {set;get;}  
    @AuraEnabled
   public User User           {set;get;}
     
   /*FOR CREATE SELECTOPTIN TYPE */
   public class SelectOption {
        @AuraEnabled 
        public String value { get; set; }
        @AuraEnabled 
        public String label { get; set; }  
        /*CONSTRUCTOR */
        public SelectOption(String value, String label) { /*VALUE, LABEL OF SELECTOPTION TYPE*/
            this.value = value;  this.label = label;                       
        }
    }

    /*TIME COVETER FROM 12 HRS TO 24 HRS*/
    @AuraEnabled 
    public static list<Integer> timeConvert(String sTime) {   /*12 HOURS TIME OF STRING TYPE*/       
        String[] sTimeList=sTime.split(':');
        Integer hr=Integer.valueOf(sTimeList[0]);
        String[] sMinF=sTimeList[1].split(' ');
        Integer min=Integer.valueOf(sMinF[0]);     
        String fr=sMinF[1];
        list<Integer> iTime = new list<Integer>();      
        if(fr=='pm' && hr<12){  hr=hr+12; iTime.add(hr);      
        }else if(fr=='am' && hr==12){ iTime.add(0);          
        }
        else{       
           iTime.add(hr);
        }
       iTime.add(min);     
       return iTime; 
    } 
  
    /*FOR CONVERTING STRING TO DATE */
    public static Date stringToDate(String sDate){ /*STRING TYPE TIME*/
        Integer hrs=0,sec=0,min=0,msec=0,i=0,temp=0;
        try{
            List<String> timeCmpnt = new List<String>{};
            timeCmpnt = sDate.split('/',2);
            while(i < timeCmpnt.size() ){
                temp = Integer.valueOf( timeCmpnt[i].trim());  if(i == 0)  hrs = temp; else if(i == 1)  min = temp; ++i;
            }        } 
          catch(System.TypeException excp){           
        }   
        return date.newInstance(hrs, min, sec);
    }    
      
     
     /*UTIL METHOD TO GET WEEK DAYS*/
     @AuraEnabled 
     public static List<Date> getDates(Integer checker) {  /*PASSING START DATE*/ 
            Date startDate = System.today().addDays(checker); 
            List<Date> dates = new  List<Date>();
            for(Integer i=0;i<7;i++){
                dates.add(startDate.addDays(i));    
            }                      
            return dates;
      }           
               
     Public class TimeOffWrp{
       @AuraEnabled
       public String Start_Time        {set;get;} 
       @AuraEnabled
       public String End_Time          {set;get;}
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
       public Boolean IsValid             {set;get;}  
       public TimeOffWrp(){
             TOBool=false; TOType=''; isAvailable=true;IsValid=true;
       }  
     }
    
    
    Public class ResourceWrp{
       @AuraEnabled
       public String Id     {set;get;}
       @AuraEnabled
       public String Name     {set;get;} 
       @AuraEnabled
       public Date Start_Date     {set;get;}
       @AuraEnabled
       public Date End_Date     {set;get;}
       @AuraEnabled
       public String Start_Time     {set;get;} 
       @AuraEnabled
       public String End_Time     {set;get;}
       @AuraEnabled
       public String Break_Start_Time    {set;get;} 
       @AuraEnabled
       public String Break_End_Time     {set;get;} 
      
        
       @AuraEnabled
       public String Mon_Start_Time      {set;get;}  //Time
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
       public String Mon_Break_Start_Time      {set;get;}  //Time
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
       public Boolean isSupervisor        {set;get;}
       @AuraEnabled
       public Boolean isTimeoff           {set;get;} 
        
       public ResourceWrp(){
            TOT=new list<SelectOption>();
            TOTList=new list<list<SelectOption>>();
            ResourcesList=new list<ResourceWrp>();
            TimeOffList=new list<TimeOffWrp>();
            isSupervisor=isTimeoff=false;
       }   
    }
  
   @AuraEnabled 
   public static TimeManagement getLocationsAndServices(String LocationId,String ServiceId) {        
       TimeManagement TM=new TimeManagement();       
        list<ERP7__Work_Planner__c> WorkPlannerList=new list<ERP7__Work_Planner__c>();       
        WorkPlannerList=[SELECT Id, Name, ERP7__WorkCenter__c, ERP7__WorkCenter__r.ERP7__Location__c,ERP7__WorkCenter__r.ERP7__Location__r.Name, ERP7__Product__c,ERP7__Product__r.name FROM ERP7__Work_Planner__c
                        WHERE ERP7__Status__c='Approved' Order By LastModifiedDate]; 
       set<SelectOption> expertLocsList=new set<SelectOption>();
       set<SelectOption> prodServiceList=new set<SelectOption>();     
       set<String> LocIds=new set<String>(); 
       set<String> ProIds=new set<String>();
       for(ERP7__Work_Planner__c wp:WorkPlannerList){
           if(wp.ERP7__WorkCenter__r.ERP7__Location__c!=null) LocIds.add(wp.ERP7__WorkCenter__r.ERP7__Location__c); 
           if(wp.ERP7__Product__c!=null) ProIds.add(wp.ERP7__Product__c);
       }
       for(ERP7__Location__c loc:[SELECT Id, Name FROM ERP7__Location__c WHERE Id IN:LocIds]) expertLocsList.add(new SelectOption(loc.Id,loc.Name));
       for(Product2 p:[SELECT Id, Name FROM Product2 WHERE Id IN:ProIds]) prodServiceList.add(new SelectOption(p.Id,p.Name));     
       TM.expertLocsList=new list<SelectOption>(expertLocsList); 
       TM.prodServiceList=new list<SelectOption>(prodServiceList);
       
       /*FOR FETCHING DATE FORMAT OF HEADER*/ 
       if(Schema.sObjectType.ERP7__System_Codes__c.isAccessible()){
          list<ERP7__System_Codes__c>  sysCode=new list<ERP7__System_Codes__c>();
          sysCode = [SELECT Id, Date_Format__c,ERP7__Resource_Time_Interval__c FROM ERP7__System_Codes__c WHERE Name!=null ORDER BY LastModifiedDate LIMIT 1];         
          if(sysCode.size()>0) TM.sysCode=sysCode[0]; 
          else TM.sysCode=null;   } else TM.sysCode=null;
       
       TM.TeamList=new list<SelectOption>(); 
       for(ERP7__Team__c t:[SELECT Id, Name FROM ERP7__Team__c WHERE Name!=Null]) TM.TeamList.add(new SelectOption(t.Id,t.Name));      
       
      return TM; 
   }
   
    public static String formatTime(Time times){
        String sTime = '';
        Integer iHour = 0, iMin=0;
        if(times.hour() >= 12){
             if(! (times.hour() == 12)){ iHour = times.hour() - 12;
             }
             if(iHour == 0){
                iHour = 12;
             }
             iMin = times.minute();
             if(iHour < 10){ sTime = String.valueOf(iHour) + ':'; //10
             }
             else{
                sTime =  String.valueOf(iHour)  + ':';
             }
             if(iMin < 10){//10
                sTime += '0' + String.valueOf(iMin)  + ' PM';
             }
             else{
                sTime +=  String.valueOf(iMin) + ' PM';
             }
            
            
        }
        else{
             iHour = times.hour();
             iMin = times.minute();
             if(iHour < 10){  sTime = '0' + String.valueOf(iHour) + ':'; //10
             }
             else{
                sTime =  String.valueOf(iHour)  + ':';
             }
             if(iMin < 10){  sTime += '0' + String.valueOf(iMin)  + ' AM';
             }
             else{
                sTime +=  String.valueOf(iMin) + ' AM';
             }
        }
        return sTime;
    } 
    
    
   /*FOR FETCHING RESOURCES*/
   @AuraEnabled 
   public static ResourceWrp getResource(String selectedLocation,String ServiceId,Integer count,String selectedTeam) {     
       ResourceWrp ResWrp=new ResourceWrp();
       list<ERP7__Resource__c> ResourceList=new  list<ERP7__Resource__c>(); 
       //ResWrp.ResourcesList=ResourcesList;
       return ResWrp;
    } 
 
   @AuraEnabled
   public static String getUpdateResources(String RRecordJSON){ 
          ResourceWrp RRecord=(ResourceWrp )JSON.deserialize(RRecordJSON, ResourceWrp .class);         
          ERP7__Resource__c Resource= [SELECT Id, Name, ERP7__Resource_Group__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Break_Start_Time__c, ERP7__Break_End_Time__c,
                        ERP7__Mon_Start_Time__c, ERP7__Mon_End_Time__c, ERP7__Tue_Start_Time__c, ERP7__Tue_End_Time__c, ERP7__Wed_Start_Time__c, ERP7__Wed_End_Time__c,
                        ERP7__Thu_Start_Time__c, ERP7__Thu_End_Time__c, ERP7__Fri_Start_Time__c,ERP7__Fri_End_Time__c, ERP7__Sat_Start_Time__c, ERP7__Sat_End_Time__c, ERP7__Sun_Start_Time__c, ERP7__Sun_End_Time__c
                        ,Mon_Break_Start_Time__c, Mon_Break_End_Time__c, Tue_Break_Start_Time__c, Tue_Break_End_Time__c, Wed_Break_Start_Time__c, Wed_Break_End_Time__c, 
                        Thu_Break_Start_Time__c, Thu_Break_End_Time__c, Fri_Break_Start_Time__c, Fri_Break_End_Time__c, Sat_Break_Start_Time__c, Sat_Break_End_Time__c, Sun_Break_Start_Time__c, Sun_Break_End_Time__c
                        FROM ERP7__Resource__c WHERE Id=:RRecord.Id];         
       
         /* FRO COMMON BREAK TIME*/ 
       if(Schema.sObjectType.ERP7__Resource__c.fields.ERP7__Break_Start_Time__c.isUpdateable()){
         if(String.isNotEmpty(RRecord.Break_Start_Time)) Resource.ERP7__Break_Start_Time__c=Time.newInstance(timeConvert(RRecord.Break_Start_Time)[0],timeConvert(RRecord.Break_Start_Time)[1],0,0);  else Resource.ERP7__Break_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.ERP7__Break_End_Time__c.isUpdateable()){
         if(String.isNotEmpty(RRecord.Break_End_Time)) Resource.ERP7__Break_End_Time__c=Time.newInstance(timeConvert(RRecord.Break_End_Time)[0],timeConvert(RRecord.Break_End_Time)[1],0,0); else Resource.ERP7__Break_End_Time__c=null;
       }        
        /* FRO WEEK DAYS TIME*/
       if(Schema.sObjectType.ERP7__Resource__c.fields.Mon_Start_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Mon_Start_Time)) Resource.Mon_Start_Time__c=Time.newInstance(timeConvert(RRecord.Mon_Start_Time)[0],timeConvert(RRecord.Mon_Start_Time)[1],0,0); else Resource.Mon_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Mon_End_Time__c.isUpdateable()){
           if(String.isNotEmpty(RRecord.Mon_End_Time)) Resource.Mon_End_Time__c=Time.newInstance(timeConvert(RRecord.Mon_End_Time)[0],timeConvert(RRecord.Mon_End_Time)[1],0,0); else Resource.Mon_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Tue_Start_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Tue_Start_Time))  Resource.Tue_Start_Time__c=Time.newInstance(timeConvert(RRecord.Tue_Start_Time)[0],timeConvert(RRecord.Tue_Start_Time)[1],0,0); else Resource.Tue_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Tue_End_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Tue_End_Time))  Resource.Tue_End_Time__c=Time.newInstance(timeConvert(RRecord.Tue_End_Time)[0],timeConvert(RRecord.Tue_End_Time)[1],0,0); else Resource.Tue_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Wed_Start_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Wed_Start_Time))  Resource.Wed_Start_Time__c=Time.newInstance(timeConvert(RRecord.Wed_Start_Time)[0],timeConvert(RRecord.Wed_Start_Time)[1],0,0);  else Resource.Wed_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Wed_End_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Wed_End_Time))  Resource.Wed_End_Time__c=Time.newInstance(timeConvert(RRecord.Wed_End_Time)[0],timeConvert(RRecord.Wed_End_Time)[1],0,0); else Resource.Wed_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Thu_Start_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Thu_Start_Time)) Resource.Thu_Start_Time__c=Time.newInstance(timeConvert(RRecord.Thu_Start_Time)[0],timeConvert(RRecord.Thu_Start_Time)[1],0,0); else Resource.Thu_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Thu_End_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Thu_End_Time))  Resource.Thu_End_Time__c=Time.newInstance(timeConvert(RRecord.Thu_End_Time)[0],timeConvert(RRecord.Thu_End_Time)[1],0,0); else Resource.Thu_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Fri_Start_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Fri_Start_Time)) Resource.Fri_Start_Time__c=Time.newInstance(timeConvert(RRecord.Fri_Start_Time)[0],timeConvert(RRecord.Fri_Start_Time)[1],0,0); else Resource.Fri_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Fri_End_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Fri_End_Time)) Resource.Fri_End_Time__c=Time.newInstance(timeConvert(RRecord.Fri_End_Time)[0],timeConvert(RRecord.Fri_End_Time)[1],0,0); else Resource.Fri_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Sat_Start_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Sat_Start_Time)) Resource.Sat_Start_Time__c=Time.newInstance(timeConvert(RRecord.Sat_Start_Time)[0],timeConvert(RRecord.Sat_Start_Time)[1],0,0); else Resource.Sat_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Sat_End_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Sat_End_Time)) Resource.Sat_End_Time__c=Time.newInstance(timeConvert(RRecord.Sat_End_Time)[0],timeConvert(RRecord.Sat_End_Time)[1],0,0);  else Resource.Sat_End_Time__c=null;
       }
        if(Schema.sObjectType.ERP7__Resource__c.fields.Sun_Start_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Sun_Start_Time)) Resource.Sun_Start_Time__c=Time.newInstance(timeConvert(RRecord.Sun_Start_Time)[0],timeConvert(RRecord.Sun_Start_Time)[1],0,0);  else Resource.Sun_Start_Time__c=null; 
        }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Sun_End_Time__c.isUpdateable()){
          if(RRecord.sun_End_Time!=null) Resource.Sun_End_Time__c=Time.newInstance(timeConvert(RRecord.Sun_End_Time)[0],timeConvert(RRecord.Sun_End_Time)[1],0,0); else Resource.Sun_End_Time__c=null;
       }
       
        /* FRO WEEK DAYS BREAK TIME*/
        if(Schema.sObjectType.ERP7__Resource__c.fields.Mon_Break_Start_Time__c.isUpdateable()){
         if(String.isNotEmpty(RRecord.Mon_Break_Start_Time))  Resource.Mon_Break_Start_Time__c=Time.newInstance(timeConvert(RRecord.Mon_Break_Start_Time)[0],timeConvert(RRecord.Mon_Break_Start_Time)[1],0,0);
        else Resource.Mon_Break_Start_Time__c=null;
        }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Mon_Break_End_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Mon_Break_End_Time))  Resource.Mon_Break_End_Time__c=Time.newInstance(timeConvert(RRecord.Mon_Break_End_Time)[0],timeConvert(RRecord.Mon_Break_End_Time)[1],0,0); else Resource.Mon_Break_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Tue_Break_Start_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Tue_Break_Start_Time)) Resource.Tue_Break_Start_Time__c=Time.newInstance(timeConvert(RRecord.Tue_Break_Start_Time)[0],timeConvert(RRecord.Tue_Break_Start_Time)[1],0,0); else Resource.Tue_Break_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Tue_Break_End_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Tue_Break_End_Time)) Resource.Tue_Break_End_Time__c=Time.newInstance(timeConvert(RRecord.Tue_Break_End_Time)[0],timeConvert(RRecord.Tue_Break_End_Time)[1],0,0);
        else Resource.Tue_Break_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Wed_Break_Start_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Wed_Break_Start_Time))  Resource.Wed_Break_Start_Time__c=Time.newInstance(timeConvert(RRecord.Wed_Break_Start_Time)[0],timeConvert(RRecord.Wed_Break_Start_Time)[1],0,0); 
        else Resource.Wed_Break_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Wed_Break_End_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Wed_Break_End_Time)) Resource.Wed_Break_End_Time__c=Time.newInstance(timeConvert(RRecord.Wed_Break_End_Time)[0],timeConvert(RRecord.Wed_Break_End_Time)[1],0,0);
        else Resource.Wed_Break_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Thu_Break_Start_Time__c.isUpdateable()){
        if(String.isNotEmpty(RRecord.Thu_Break_Start_Time))  Resource.Thu_Break_Start_Time__c=Time.newInstance(timeConvert(RRecord.Thu_Break_Start_Time)[0],timeConvert(RRecord.Thu_Break_Start_Time)[1],0,0); 
        else Resource.Thu_Break_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Thu_Break_End_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Thu_Break_End_Time))  Resource.Thu_Break_End_Time__c=Time.newInstance(timeConvert(RRecord.Thu_Break_End_Time)[0],timeConvert(RRecord.Thu_Break_End_Time)[1],0,0);
          else Resource.Thu_Break_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Fri_Break_Start_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Fri_Break_Start_Time)) Resource.Fri_Break_Start_Time__c=Time.newInstance(timeConvert(RRecord.Fri_Break_Start_Time)[0],timeConvert(RRecord.Fri_Break_Start_Time)[1],0,0);
          else Resource.Fri_Break_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Fri_Break_End_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Fri_Break_End_Time))  Resource.Fri_Break_End_Time__c=Time.newInstance(timeConvert(RRecord.Fri_Break_End_Time)[0],timeConvert(RRecord.Fri_Break_End_Time)[1],0,0);
          else Resource.Fri_Break_End_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Sat_Break_Start_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Sat_Break_Start_Time))  Resource.Sat_Break_Start_Time__c=Time.newInstance(timeConvert(RRecord.Sat_Break_Start_Time)[0],timeConvert(RRecord.Sat_Break_Start_Time)[1],0,0);
          else Resource.Sat_Break_Start_Time__c=null;
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Sat_Break_End_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Sat_Break_End_Time))  Resource.Sat_Break_End_Time__c=Time.newInstance(timeConvert(RRecord.Sat_Break_End_Time)[0],timeConvert(RRecord.Sat_Break_End_Time)[1],0,0);
          else Resource.Sat_Break_End_Time__c=null;
       }        
       if(Schema.sObjectType.ERP7__Resource__c.fields.Sun_Break_Start_Time__c.isUpdateable()){
          if(String.isNotEmpty(RRecord.Sun_Break_Start_Time)) Resource.Sun_Break_Start_Time__c=Time.newInstance(timeConvert(RRecord.Sun_Break_Start_Time)[0],timeConvert(RRecord.Sun_Break_Start_Time)[1],0,0);
          else Resource.Sun_Break_Start_Time__c=null; 
       }
       if(Schema.sObjectType.ERP7__Resource__c.fields.Sun_Break_End_Time__c.isUpdateable()){
          if(RRecord.sun_Break_End_Time!=null) Resource.Sun_Break_End_Time__c=Time.newInstance(timeConvert(RRecord.Sun_Break_End_Time)[0],timeConvert(RRecord.Sun_Break_End_Time)[1],0,0); 
          else Resource.Sun_Break_End_Time__c=null;      
       }
       if(Schema.SObjectType.ERP7__Resource__c.isUpdateable()){ update Resource;}else{/*Not allowed to update Resource*/}
       return null;
   }
             
  /* @AuraEnabled 
   Public Static Timemanagement getTimeoffRecords(String RId){         
       Timemanagement TM=new Timemanagement(); 
       list<ERP7__Time_Off__c> TimeOffList=new list<ERP7__Time_Off__c>();
       if(String.isNotEmpty(RId)){ 
       TimeOffList=[SELECT Id, Name, ERP7__Resource__c, ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Type__c, ERP7__Start_Time__c, ERP7__End_Time__c,ERP7__Reason__c
                   FROM ERP7__Time_Off__c WHERE ERP7__Resource__c=:RId AND ERP7__Start_Date__c>=:System.today() AND ERP7__Type__c!=null
                   AND((ERP7__Start_Time__c=null AND ERP7__End_Time__c=null) OR (ERP7__Start_Time__c!=null AND ERP7__End_Time__c!=null))
                   AND ERP7__Start_Date__c!=null AND ERP7__End_Date__c!=null Order By ERP7__Start_Date__c];           
       TM.TimeoffList =TimeOffList;
       TM.Timeoff=new ERP7__Time_Off__c();
       TM.TOTypeList=getTOTypeList(); 
       TM.Resource=[SELECT Id,Name FROM ERP7__Resource__c WHERE Id=:RId]; 
       TM.Today=System.today();    
       list<ERP7__Team_Member__c> TeamMemberList=new list<ERP7__Team_Member__c>();    
       TeamMemberList=[SELECT Id, Name, ERP7__Resource__c,ERP7__Team__c,ERP7__Supervisor__c FROM ERP7__Team_Member__c WHERE ERP7__Resource__c=:RId AND ERP7__Team__c!=null ORDER BY LastModifiedDate LIMIT 1];    
       if(TeamMemberList.size()>0) TM.isSupervisor=TeamMemberList[0].ERP7__Supervisor__c;    
       return TM;      
      }else return null; 
      
    }*/
    
    /*FOR FETCH TIME OFF RECORDS OF USER*/
   @AuraEnabled 
   Public Static Timemanagement getTimeoffRecord(String userId){ 
       Timemanagement TM=new Timemanagement();  
       list<ERP7__Time_Off__c> TimeOffList=new list<ERP7__Time_Off__c>();
       if(String.isNotEmpty(userId)){
       TimeOffList=[SELECT Id, Name, ERP7__Resource__c, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Type__c, ERP7__Start_Time__c, ERP7__End_Time__c,ERP7__Reason__c
                   FROM ERP7__Time_Off__c WHERE ERP7__User__c=:userId AND ERP7__Start_Date__c>=:System.today() AND ERP7__Type__c!=null
                   AND ((ERP7__Start_Time__c=null AND ERP7__End_Time__c=null) OR (ERP7__Start_Time__c!=null AND ERP7__End_Time__c!=null))
                   AND ERP7__Start_Date__c!=null AND ERP7__End_Date__c!=null Order By ERP7__Start_Date__c];           
       TM.TimeoffList =TimeOffList;
       TM.Timeoff=new ERP7__Time_Off__c();
       TM.TOTypeList=getTOTypeList(); 
       TM.Today=System.today();
       TM.User=[SELECT Id, Name FROM User WHERE Id=:userId];    
       return TM;      
       }else {
       TM.Timeoff=new ERP7__Time_Off__c(); TM.TOTypeList=getTOTypeList(); TM.Today=System.today(); return TM;
       }     
    }    
    
    @AuraEnabled 
    Public Static list<SelectOption> getTOTypeList(){   
        list<SelectOption> typeList=new list<SelectOption>();
        //typeList.add(new SelectOption('','-- None --')); 
        List<Schema.PicklistEntry> typeListValues = Schema.sObjectType.ERP7__Time_Off__c.Fields.ERP7__Type__c.getPickListValues();       
        for(Schema.PicklistEntry a:typeListValues) typeList.add(new SelectOption(a.getValue(),a.getLabel()));  
        return typeList;
    }  
    
   @AuraEnabled
   public static ERP7__Time_Off__c getTOInstance(){
       return new ERP7__Time_Off__c();
   } 
    
    
     /*UPDATE TIME OFF RECORD*/
   @AuraEnabled
   Public static list<ERP7__Time_Off__c> getCreateTimeoff(String Timeoff, String ST, String ET, String action,String TOId){ 
	   if(String.isNotEmpty(Timeoff)){
       ERP7__Time_Off__c TORecord=new ERP7__Time_Off__c();
       String UserId;    
       if(action!='delete' && String.isNotEmpty(Timeoff)){ 
         TORecord=(ERP7__Time_Off__c) JSON.deserializeStrict(Timeoff, ERP7__Time_Off__c .class);  
         if(String.isNotEmpty(ST) && ST.split(':').size()>1) if(Schema.sObjectType.ERP7__Time_Off__c.fields.ERP7__Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Off__c.fields.ERP7__Start_Time__c.isUpdateable()) TORecord.ERP7__Start_Time__c=Time.newInstance(Integer.valueOf(ST.split(':')[0]),Integer.valueOf(ST.split(':')[1]),0,0);
         if(String.isNotEmpty(ET) && ET.split(':').size()>1) if(Schema.sObjectType.ERP7__Time_Off__c.fields.ERP7__End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Off__c.fields.ERP7__End_Time__c.isUpdateable()) TORecord.ERP7__End_Time__c=Time.newInstance(Integer.valueOf(ET.split(':')[0]),Integer.valueOf(ET.split(':')[1]),0,0);
           if(TORecord.ERP7__User__c!=null) UserId=TORecord.ERP7__User__c; 
           if(Schema.SObjectType.ERP7__Time_Off__c.isCreateable() && Schema.SObjectType.ERP7__Time_Off__c.isUpdateable()){upsert TORecord;}else{/*Not allowed to upsert*/}               
       }
           else {TORecord=(ERP7__Time_Off__c) JSON.deserializeStrict(Timeoff, ERP7__Time_Off__c .class);  if(TORecord.ERP7__User__c!=null) UserId=TORecord.ERP7__User__c; if(ERP7__Time_Off__c.sObjectType.getDescribe().isDeletable()) delete new ERP7__Time_Off__c(Id=TOId); else{ }
       }
        
       if(String.isNotEmpty(UserId))
           return  [SELECT Id, Name, ERP7__Resource__c, ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Type__c, ERP7__Start_Time__c, ERP7__End_Time__c,ERP7__Reason__c
                   FROM ERP7__Time_Off__c WHERE ERP7__User__c=:UserId AND ERP7__Start_Date__c>=:System.today() AND ERP7__Type__c!=null
                   AND((ERP7__Start_Time__c=null AND ERP7__End_Time__c=null) OR (ERP7__Start_Time__c!=null AND ERP7__End_Time__c!=null)) 
                   AND ERP7__Start_Date__c!=null AND ERP7__End_Date__c!=null Order By ERP7__Start_Date__c];
       else return null;   
      }else return null;				   
   }
   }