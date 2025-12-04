public with Sharing class Accounting_Period {
	
    public Accounting_Period()
    {
    
    }
     @AuraEnabled
    public static Wrapper getDefaultOrg(String passed_start_date, String passed_end_date)
    {   
        Date start_Date = Date.valueOf(passed_start_date);
        Date end_Date = Date.valueOf(passed_end_date);
        Date start_date_temp = start_date;
        //Getting thr number of months.
        integer numberOfMonths = start_date.monthsBetween(end_date)+1;  
        Date start_Of_date;
        Wrapper Wrapper = new Wrapper();
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        ERP7__Employees__c emp=new ERP7__Employees__c();
        
       try{ emp = [Select id, Name, ERP7__Organisation__c,ERP7__Employee_User__c from ERP7__Employees__c where ERP7__Employee_User__c =: u.id];
        }catch(Exception e){
		
	    }
         
        id org = emp.ERP7__Organisation__c;
        
        integer count =0;
       Set<Date> getDates = new Set<Date>();
       for( integer i=numberOfMonths; i>0; i--)
        		{
            		start_date_temp = start_date_temp.addMonths(count);
        			start_Of_date = start_date_temp.toStartOfMonth();
                    getDates.add(start_Of_date);
                    count =1;
        		 }
        
        
        Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c FROM ERP7__Accounting_Period__c where ERP7__Organisation__c =:emp.ERP7__Organisation__c AND ERP7__Start_Date__c IN : getDates ORDER BY ERP7__Start_Date__c ASC ];
        Wrapper.acc.ERP7__Organisation__c = emp.ERP7__Organisation__c;
        if(Wrapper.APS.size() >= numberOfMonths)
        {
            //'All records are there for selected organisation.
            Wrapper.checkTotalRecords=true;
        }
	
     	return Wrapper;
    }

    @AuraEnabled
    public static Date orgFYStartDate()
    {
        return Date.newinstance(system.today().year(), [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth, 1);
    }
    
     @AuraEnabled
    public static Wrapper initRecords()
    {
         Wrapper Wrapper = new Wrapper();
         Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c FROM ERP7__Accounting_Period__c ORDER BY ERP7__Start_Date__c ASC ];
         return Wrapper;
    }
    
     @AuraEnabled
    public static Wrapper updateRecords(String passed_start_date, String passed_end_date,String org)
    {
        Wrapper Wrapper = new Wrapper();
         Date getstart_Date = Date.valueOf(passed_start_date);
       	Date getend_Date = Date.valueOf(passed_end_date);
        
        //Getting the correct Start Date
        Date starts = getstart_Date.toStartOfMonth();
        if(starts !=  getstart_Date ){
            starts = starts.addMonths(1);
            //'Start_Date is not 1st..
            }
        
        //Getting the correct end Date
        Date endstarts = getend_Date.toStartOfMonth();
        Date ends = endstarts.AddMonths(1).AddDays(-1);
        if(ends != getend_Date ){ends = endstarts.addMonths(-1);
                               ends = ends.AddMonths(1).AddDays(-1);}
        
        
         Date start_Date = Date.valueOf(starts);
       	 Date end_Date = Date.valueOf(ends);
         Date start_date_temp = start_date;
        integer numberOfMonths = start_date.monthsBetween(end_date)+1;  
       Date start_Of_date;
         integer count =0;
         Set<Date> getDates = new Set<Date>();
         for( integer i=numberOfMonths; i>0; i--)
        		{
            		start_date_temp = start_date_temp.addMonths(count);
        			start_Of_date = start_date_temp.toStartOfMonth();
                    getDates.add(start_Of_date);
                    count =1;
        		 }

        if(org==''){
            //<================ Org is null ==================>
             Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c FROM ERP7__Accounting_Period__c where ERP7__Start_Date__c IN : getDates AND ERP7__Organisation__c = :null ORDER BY ERP7__Start_Date__c ASC ]; 
    
        }else {
        Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c FROM ERP7__Accounting_Period__c where ERP7__Organisation__c = :org AND ERP7__Start_Date__c IN : getDates ORDER BY ERP7__Start_Date__c ASC ];
        }
        if(Wrapper.APS.size()<1){
            	//'No records found for this organisation.'
                Wrapper.checkRecords= true;}
        //Checking the total records
        if(Wrapper.APS.size() >= numberOfMonths)
        {
            //'All records are there for selected organisation.'
            Wrapper.checkTotalRecords=true;
        }

            return Wrapper;
        
    }
    
      @AuraEnabled
    public static Wrapper updateOnDates(String passed_start_date, String passed_end_date, String org)
    {
        integer count=0;
        Date getstart_Date = Date.valueOf(passed_start_date);
       	Date getend_Date = Date.valueOf(passed_end_date);
        
        //Getting the correct Start Date
        Date starts = getstart_Date.toStartOfMonth();
        if(starts !=  getstart_Date ){
            starts = starts.addMonths(1);
            
            }
        
        //Getting the correct end Date
        Date endstarts = getend_Date.toStartOfMonth();
        Date ends = endstarts.AddMonths(1).AddDays(-1);
        if(ends != getend_Date ){ends = endstarts.addMonths(-1);
                               ends = ends.AddMonths(1).AddDays(-1);}
        
       if(org=='')
       {  org = null;
       }
       Date start_Date = Date.valueOf(starts);
       Date end_Date = Date.valueOf(ends);
       date start_date_temp = start_date;
       integer numberOfMonths = start_date.monthsBetween(end_date)+1;  
       date start_Of_date;
       date  end_Of_date;
      
       Set<Date> getDates = new Set<Date>();
       for( integer i=numberOfMonths; i>0; i--)
        		{
            		start_date_temp = start_date_temp.addMonths(count);
        			start_Of_date = start_date_temp.toStartOfMonth();
                    getDates.add(start_Of_date);
                    count =1;
        		 }
        
        Wrapper Wrapper = new Wrapper();
        Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c FROM ERP7__Accounting_Period__c where ERP7__Organisation__c = :org AND ERP7__Start_Date__c IN : getDates ORDER BY ERP7__Start_Date__c ASC ];
         if(Wrapper.APS.size()<1){
           Wrapper.checkRecords= true;
            } 
         //Checking the total records
        if(Wrapper.APS.size() >= numberOfMonths)
        {
            //'All records are there for selected organisation.'
            Wrapper.checkTotalRecords=true;
        }
        return Wrapper;
    }
    
     @AuraEnabled
    public static Wrapper getRecordsOnOrgNull(String passed_start_date, String passed_end_date, String org)
    {
         Wrapper Wrapper = new Wrapper();
        if(org == '' || org == null){
            org = null;
            Date getstart_Date = Date.valueOf(passed_start_date);
            Date getend_Date = Date.valueOf(passed_end_date);
            
            //Getting the correct Start Date
            Date starts = getstart_Date.toStartOfMonth();
            if(starts !=  getstart_Date ){
                starts = starts.addMonths(1);
                //'Start_Date is not 1st.......
            }
            
            //Getting the correct end Date
            Date endstarts = getend_Date.toStartOfMonth();
            Date ends = endstarts.AddMonths(1).AddDays(-1);
            if(ends != getend_Date ){ends = endstarts.addMonths(-1);
                                     ends = ends.AddMonths(1).AddDays(-1);}
            Date start_Date = Date.valueOf(starts);
            Date end_Date = Date.valueOf(ends);
            Date start_date_temp = start_date;
            
            //Getting the number of months.
            integer numberOfMonths = start_date.monthsBetween(end_date)+1;        
            date start_Of_date;
            date  end_Of_date; 
            integer count=0;
            Set<Date> getRecords= new Set<Date>();
            List<ERP7__Accounting_Period__c> accounting_period = new List<ERP7__Accounting_Period__c>();
            for( integer i=numberOfMonths; i>0; i--){
                start_date_temp = start_date_temp.addMonths(count);
                start_Of_date = start_date_temp.toStartOfMonth();
                end_Of_date = start_Of_date.AddMonths(1).AddDays(-1);
                
                //checking the existing records for org for given date 
                List<ERP7__Accounting_Period__c> existing_Org = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c from ERP7__Accounting_Period__c where ERP7__Start_Date__c = :start_Of_date AND ERP7__Organisation__c = :org];
                
                if(existing_Org.size()<1){
                    accounting_period.add(new ERP7__Accounting_Period__c(Name=start_date_temp.format(),
                                                                         ERP7__Start_Date__c = start_date_temp.toStartOfMonth(),
                                                                         ERP7__End_Date__c = end_Of_date,
                                                                         ERP7__Status__c = 'Open',
                                                                         ERP7__Organisation__c = org));
                    getRecords.add(start_Of_date);
                }else{ getRecords.add(start_Of_date); }
                count=1;
            }
            if(Schema.sObjectType.ERP7__Accounting_Period__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.ERP7__Organisation__c.isCreateable()){
                insert accounting_period; 
            }else { }
            
            Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c FROM ERP7__Accounting_Period__c where ERP7__Organisation__c = :org AND ERP7__Start_Date__c IN : getRecords ORDER BY ERP7__Start_Date__c ASC ];
            if(accounting_period.size()>=1){
                Wrapper.checkinserted = true;
                Wrapper.checkRecords= false;
            }else{Wrapper.existRecords = true;} 
            
            //Checking the total records
            if(Wrapper.APS.size() >= numberOfMonths){
                //'All records are there for selected organisation.'
                Wrapper.checkTotalRecords=true;
            }
        }
        
        return Wrapper;
    }
    
    @AuraEnabled
    public static Wrapper setDate(String passed_start_date, String passed_end_date, String org)
    {
        String orgName='';
        try{
            if(org !='' || org == null)
            {
            	orgName = [Select Name From Account where Id = :org].Name ;
             } else {
                 org = null;
             	}
           }
        catch(Exception e)
        {/*'Erorrs in orgID...'*/}
        
        
        Date getstart_Date = Date.valueOf(passed_start_date);
       	Date getend_Date = Date.valueOf(passed_end_date);
        
        //Getting the correct Start Date
        Date starts = getstart_Date.toStartOfMonth();
        if(starts !=  getstart_Date ){
            starts = starts.addMonths(1);
            //'Start_Date is not 1st.......'
            }
        
        //Getting the correct end Date
        Date endstarts = getend_Date.toStartOfMonth();
        Date ends = endstarts.AddMonths(1).AddDays(-1);
        if(ends != getend_Date ){ends = endstarts.addMonths(-1);
                               ends = ends.AddMonths(1).AddDays(-1);}
        Wrapper Wrapper = new Wrapper();
        Date start_Date = Date.valueOf(starts);
       	Date end_Date = Date.valueOf(ends);
        date start_date_temp = start_date;
        List<ERP7__Accounting_Period__c> accounting_period = new List<ERP7__Accounting_Period__c>();
     	
        //Getting the number of months.
  		integer numberOfMonths = start_date.monthsBetween(end_date)+1;        
        date start_Of_date;
    	date  end_Of_date; 
        integer count=0;
        
        //Declaring set to get all existing dates.
        List<ERP7__Accounting_Period__c> existing_dates = [SELECT ERP7__Start_Date__c,ERP7__Organisation__c from ERP7__Accounting_Period__c];
        Set<Date> getRecords= new Set<Date>();
        Set<Date> exist_dates = new Set<Date>();
        integer size=existing_dates.size();
        for(integer i=0;i<size;i++){
         exist_dates.add(existing_dates[i].ERP7__Start_Date__c);
            }
        
        
         //Declaring set to get all existing orgs.
        Set<String> exist_Org = new Set<String>();
        
        try{
        	 for( integer i=numberOfMonths; i>0; i--)
        		{
            		start_date_temp = start_date_temp.addMonths(count);
        			start_Of_date = start_date_temp.toStartOfMonth();
        			end_Of_date = start_Of_date.AddMonths(1).AddDays(-1);
            		
                    //checking the existing records for org for given date 
            		List<ERP7__Accounting_Period__c> existing_Org = [SELECT ERP7__Organisation__c from ERP7__Accounting_Period__c where ERP7__Start_Date__c = :start_Of_date AND ERP7__Organisation__c = :org];
           			integer orgSize=existing_Org.size();
            
        			
                    for(integer j=0;j<orgSize;j++){
         				 exist_Org.add(existing_Org[j].ERP7__Organisation__c);
            		}
            
       				
                    if(exist_dates.contains(start_Of_date) && existing_Org.size() >=1 ){
            			getRecords.add(start_Of_date);
                        count=1;
                        }
            		    else{
            			accounting_period.add(new ERP7__Accounting_Period__c(Name=start_date_temp.format(),
                                                           ERP7__Start_Date__c = start_date_temp.toStartOfMonth(),
                                                           ERP7__End_Date__c = end_Of_date,
                                                           ERP7__Status__c = 'Open',
                                                           ERP7__Organisation__c = org));
               			getRecords.add(start_Of_date);
               			count=1;
            			}
        			  }
        	    }
        catch(Exception e)
        {/*'Erorrs in orgID...existing_Org list return null.*/}
         
        if(Schema.sObjectType.ERP7__Accounting_Period__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.ERP7__Organisation__c.isCreateable()){
            insert accounting_period;
        }else { }
        
        Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c FROM ERP7__Accounting_Period__c where ERP7__Organisation__c = :org AND ERP7__Start_Date__c IN : getRecords ORDER BY ERP7__Start_Date__c ASC ];
         if(accounting_period.size()>=1){
           Wrapper.checkinserted = true;
           Wrapper.checkRecords= false;
            }else{Wrapper.existRecords = true;}
         //Checking the total records
        if(Wrapper.APS.size() >= numberOfMonths)
        {
            /*'All records are there for selected organisation.'*/
            Wrapper.checkTotalRecords=true;
        }
        return Wrapper;
   }
    
    public class Wrapper{
        @AuraEnabled public List<ERP7__Accounting_Period__c> APS    { get; set; }
        @AuraEnabled public String ErrorMsg						 { get; set; }
        @AuraEnabled public ERP7__Accounting_Period__c AP		     { get; set; }
        @AuraEnabled public Account  acc     						 { get; set; }
        @AuraEnabled public Boolean checkinserted					 { get; set; }
        @AuraEnabled public Boolean checkRecords					 { get; set; }
        @AuraEnabled public Boolean existRecords					 { get; set; }
        @AuraEnabled public Boolean checkTotalRecords				 { get; set; }
        public Wrapper(){
           APS = new List<ERP7__Accounting_Period__c>();
           AP = new ERP7__Accounting_Period__c();
           acc = new Account();
		   ErrorMsg = '';
		   checkinserted = false; 
           checkRecords  = false;
           existRecords  = false;
           checkTotalRecords =false;
        }
    
    }
}