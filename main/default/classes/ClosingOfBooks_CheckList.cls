public with Sharing class ClosingOfBooks_CheckList {
	
    public ClosingOfBooks_CheckList()
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

    public class dateWrapper{
        @AuraEnabled public Date sDate {get;set;}
        @AuraEnabled public Date eDate {get;set;}
        public dateWrapper(){
            sDate = system.today().addYears(-1);
            eDate = system.today();
        }
    }
    @AuraEnabled
    public static dateWrapper orgFYStartDate()
    {
        dateWrapper dwrap = new dateWrapper();
        Date sDate = Date.newinstance(system.today().year(), [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth, 1);
        //FiscalYearSettings fiscalYearSettings = [SELECT Id, Name, StartDate FROM FiscalYearSettings where StartDate<=:system.today() AND EndDate>=:system.today()LIMIT 1];
        dwrap.sDate = sDate;
        dwrap.eDate = sDate.addYears(1);
        return dwrap;
        //return Date.newinstance(system.today().year(), [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth, 1);
    }
    
    @AuraEnabled
    public static dateWrapper orgPrevFYStartDate()
    {
        dateWrapper dwrap = new dateWrapper();
        Date sDate = Date.newinstance(system.today().year()-1, [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth, 1);
        //FiscalYearSettings fiscalYearSettings = [SELECT Id, Name, StartDate FROM FiscalYearSettings where StartDate<=:system.today() AND EndDate>=:system.today()LIMIT 1];
        dwrap.sDate = sDate;
        dwrap.eDate = sDate.addYears(1);
        return dwrap;
        //return Date.newinstance(system.today().year()-1, [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth, 1);
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
             Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c, ERP7__Organisation__c FROM ERP7__Accounting_Period__c where ERP7__Start_Date__c IN : getDates AND ERP7__Organisation__c = :null ORDER BY ERP7__Start_Date__c ASC ]; 
    
        }else {
        Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c, ERP7__Organisation__c FROM ERP7__Accounting_Period__c where ERP7__Organisation__c = :org AND ERP7__Start_Date__c IN : getDates ORDER BY ERP7__Start_Date__c ASC ];
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
        Wrapper.APS = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c, ERP7__Organisation__c FROM ERP7__Accounting_Period__c where ERP7__Organisation__c = :org AND ERP7__Start_Date__c IN : getDates ORDER BY ERP7__Start_Date__c ASC ];
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
                List<ERP7__Accounting_Period__c> existing_Org = [SELECT Name, ERP7__Start_Date__c, ERP7__End_Date__c,ERP7__Status__c, ERP7__Organisation__c from ERP7__Accounting_Period__c where ERP7__Start_Date__c = :start_Of_date AND ERP7__Organisation__c = :org];
                
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
    
  	@AuraEnabled
    public static List<SelectOptions> getStatus(){
        List<SelectOptions> options = new List<SelectOptions>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Accounting_Period__c.ERP7__Status__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple){
            options.add(new SelectOptions(f.getLabel(),f.getValue()));
            system.debug('f : '+f);
        }  
        return options;
    }
    
    @AuraEnabled
    public static String updateAccountingStatus(ERP7__Accounting_Period__c accPeriod){
        try{
            update accPeriod;
            return null;
        }catch(Exception e){
            system.debug('Exception-->'+e+e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchInvoices(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Invoice__c> unpostedinvoices = new List<ERP7__Invoice__c>();
        List<ERP7__Invoice__c> unpaidinvoices = new List<ERP7__Invoice__c>();
        unpostedinvoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Invoice_Amount__c, ERP7__Account__r.Name, ERP7__Organisation__r.Name, ERP7__Paid_Amount__c, ERP7__Invoice_Date__c from ERP7__Invoice__c where ERP7__Posted__c = false and ERP7__Invoice_Date__c>=:StartDate and ERP7__Invoice_Date__c <=:EndDate and RecordType.Name != 'Advance'  and ERP7__Invoice_Amount__c > 0 and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];//and ERP7__Organisation__c=:OrgId 
        unpaidinvoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Invoice_Amount__c, ERP7__Account__r.Name, ERP7__Organisation__r.Name, ERP7__Paid_Amount__c, ERP7__Invoice_Date__c from ERP7__Invoice__c where ERP7__Posted__c = true and ERP7__Paid__c= false and ERP7__Invoice_Date__c>=:StartDate and ERP7__Invoice_Date__c <=:EndDate and RecordType.Name != 'Advance' and ERP7__Invoice_Amount__c > 0 and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];//and ERP7__Organisation__c=:OrgId 
        system.debug('unpaidInvoices-->'+unpaidInvoices);
        tw.unpaidInvoices = unpaidInvoices;
        tw.unpostedInvoices = unpostedinvoices;
        List<ERP7__Invoice__c> invoices = new List<ERP7__Invoice__c>();
        Set<Id> invoiceIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        invoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Invoice_Amount__c, ERP7__Account__r.Name, ERP7__Organisation__r.Name, ERP7__Paid_Amount__c, ERP7__Invoice_Date__c from ERP7__Invoice__c where ERP7__Posted__c = true and ERP7__Invoice_Date__c>=:StartDate and ERP7__Invoice_Date__c <=:EndDate and RecordType.Name != 'Advance' and ERP7__Invoice_Amount__c > 0 and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];//and ERP7__Organisation__c=:OrgId 
        if(invoices.size()>0){
            invoiceIds = (new Map<Id, ERP7__Invoice__c>(invoices)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Invoice__c, ERP7__Amount__c from ERP7__Transaction__c where ERP7__Invoice__c IN :invoiceIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Invoice__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Invoice__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Invoice__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Invoice__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Invoice__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Invoice__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Invoice__c inv : invoices){
                if(!TransMap.containsKey(inv.Id)){
                    tw.noTransInvoices.add(inv);
                }
                if(TransMap.containsKey(inv.Id) && !LedgerMap.containskey(inv.Id) && TransMap.get(inv.Id).ERP7__Amount__c>0){
                    tw.transNoLedgerInvoices.add(inv);
                }
                if(LedgerMap.containskey(inv.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(inv.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.ledgerMismatchInvoices.add(inv);
                    }
                }
            }
        }
        system.debug('unpaidInvoices-->'+tw.unpaidInvoices);
        return tw;
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchBills(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Bill__c> unpostedbills = new List<ERP7__Bill__c>();
        List<ERP7__Bill__c> unpaidbills = new List<ERP7__Bill__c>();
        List<ERP7__Bill__c> filteredBills = new List<ERP7__Bill__c>();
        unpostedbills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Total_Amount__c, ERP7__Organisation__r.Name, ERP7__Vendor__r.Name, ERP7__Amount_Paid__c, ERP7__Bill_Date__c from ERP7__Bill__c where ERP7__Posted__c = false and ERP7__Bill_Date__c>=:StartDate and ERP7__Bill_Date__c <=:EndDate and ERP7__Organisation__c!=null and ERP7__Organisation__c=:OrgId and ERP7__Total_Amount__c > 0 order by CreatedDate DESC];
        unpaidbills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Total_Amount__c, ERP7__Organisation__r.Name, ERP7__Vendor__r.Name, ERP7__Amount_Paid__c, ERP7__Bill_Date__c from ERP7__Bill__c where ERP7__Posted__c = true and ERP7__Bill_Date__c>=:StartDate and ERP7__Bill_Date__c <=:EndDate and ERP7__Organisation__c!=null and ERP7__Organisation__c=:OrgId and ERP7__Total_Amount__c > 0 order by CreatedDate DESC];
        for(ERP7__Bill__c bill : unpaidbills){
            if(bill.ERP7__Amount_Paid__c<bill.ERP7__Total_Amount__c){
                filteredBills.add(bill);
            }
        }
        tw.unpostedbills = unpostedbills;
        tw.unpaidbills = filteredBills;
        List<ERP7__Bill__c> bills = new List<ERP7__Bill__c>();
        Set<Id> billIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        bills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Total_Amount__c, ERP7__Organisation__r.Name, ERP7__Vendor__r.Name, ERP7__Amount_Paid__c, ERP7__Bill_Date__c from ERP7__Bill__c where ERP7__Posted__c = true and ERP7__Bill_Date__c>=:StartDate and ERP7__Bill_Date__c <=:EndDate and ERP7__Total_Amount__c > 0 and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];// and ERP7__Organisation__c=:OrgId 
        if(bills.size()>0){
            billIds = (new Map<Id, ERP7__Bill__c>(bills)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Bill__c, ERP7__Amount__c from ERP7__Transaction__c where ERP7__Bill__c	 IN :billIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Bill__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Bill__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Bill__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Bill__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Bill__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Bill__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Bill__c bill : bills){
                if(!TransMap.containsKey(bill.Id)){
                    tw.noTransBills.add(bill);
                }
                if(TransMap.containsKey(bill.Id) && !LedgerMap.containskey(bill.Id) && TransMap.get(bill.Id).ERP7__Amount__c>0){
                    tw.TransNoLedgerBills.add(bill);
                }
                if(LedgerMap.containskey(bill.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(bill.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.LedgerMismatchBills.add(bill);
                    }
                }
            }
        }
        return tw;
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchPayments(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Payment__c> unpostedpayments = new List<ERP7__Payment__c>();
        unpostedpayments = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Payment_Date__c, ERP7__Total_Amount__c, ERP7__Accounts__r.Name, ERP7__Account__r.Name from ERP7__Payment__c where ERP7__Posted__c = false and ERP7__Payment_Date__c>=:StartDate and ERP7__Payment_Date__c <=:EndDate and ERP7__Total_Amount__c>0 and ERP7__Account__c!=null and ERP7__Payment_Account__c!= null and ERP7__Account__c=:OrgId order by CreatedDate DESC];
        tw.unpostedpayments = unpostedpayments;
        List<ERP7__Payment__c> payments = new List<ERP7__Payment__c>();
        Set<Id> paymentIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        payments = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Payment_Date__c, ERP7__Total_Amount__c, ERP7__Accounts__r.Name, ERP7__Account__r.Name from ERP7__Payment__c where ERP7__Posted__c = true and ERP7__Payment_Date__c>=:StartDate and ERP7__Payment_Date__c <=:EndDate and ERP7__Payment_Account__c!= null and ERP7__Account__c=:OrgId order by CreatedDate DESC];// and ERP7__Account__c=:OrgId 
        if(payments.size()>0){
            paymentIds = (new Map<Id, ERP7__Payment__c>(payments)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Payment__c, ERP7__Amount__c from ERP7__Transaction__c where ERP7__Payment__c	 IN :paymentIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Payment__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Payment__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Payment__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Payment__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Payment__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Payment__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Payment__c pay : payments){
                if(!TransMap.containsKey(pay.Id)){
                    tw.noTransPayments.add(pay);
                }
                if(TransMap.containsKey(pay.Id) && !LedgerMap.containskey(pay.Id) && TransMap.get(pay.Id).ERP7__Amount__c>0){
                    tw.TransNoLedgerPayments.add(pay);
                }
                if(LedgerMap.containskey(pay.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(pay.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.LedgerMismatchPayments.add(pay);
                    }
                }
            }
        }
        return tw;
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchCreditNotes(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Credit_Note__c> unpostedCreditnotes = new List<ERP7__Credit_Note__c>();
        unpostedCreditnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Date__c, ERP7__Account__r.Name, ERP7__Organisation__r.Name, ERP7__Credit__c from ERP7__Credit_Note__c where ERP7__Posted__c = false and ERP7__Date__c>=:StartDate and ERP7__Credit__c>0 and ERP7__Date__c <=:EndDate and ERP7__Organisation__c!=null and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];
        tw.unpostedCreditnotes = unpostedCreditnotes;
        List<ERP7__Credit_Note__c> creditnotes = new List<ERP7__Credit_Note__c>();
        Set<Id> creditnoteIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        creditnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Date__c, ERP7__Account__r.Name, ERP7__Organisation__r.Name, ERP7__Credit__c from ERP7__Credit_Note__c where ERP7__Posted__c = true and ERP7__Date__c>=:StartDate and ERP7__Credit__c>0 and ERP7__Date__c <=:EndDate and ERP7__Organisation__c!=null and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];
        if(creditnotes.size()>0){
            creditnoteIds = (new Map<Id, ERP7__Credit_Note__c>(creditnotes)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Credit_Note__c from ERP7__Transaction__c where ERP7__Credit_Note__c	 IN :creditnoteIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Credit_Note__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Credit_Note__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Credit_Note__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Credit_Note__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Credit_Note__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Credit_Note__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Credit_Note__c creditnote : creditnotes){
                if(!TransMap.containsKey(creditnote.Id)){
                    tw.noTransCreditnotes.add(creditnote);
                }
                if(TransMap.containsKey(creditnote.Id) && !LedgerMap.containskey(creditnote.Id)){
                    tw.TransNoLedgerCreditNotes.add(creditnote);
                }
                if(LedgerMap.containskey(creditnote.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(creditnote.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.LedgerMismatchCreditNotes.add(creditnote);
                    }
                }
            }
        }
        return tw;
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchDebitNotes(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Debit_Note__c> unpostedDebitnotes = new List<ERP7__Debit_Note__c>();
        unpostedDebitnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Debit__c, ERP7__Account__r.Name, ERP7__Organisation__r.Name, ERP7__Credit_Note_Date__c from ERP7__Debit_Note__c where ERP7__Posted__c = false and ERP7__Credit_Note_Date__c>=:StartDate and ERP7__Credit_Note_Date__c <=:EndDate and ERP7__Debit__c>0 and ERP7__Organisation__c!=null and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];
        tw.unpostedDebitnotes = unpostedDebitnotes;
        List<ERP7__Debit_Note__c> debitnotes = new List<ERP7__Debit_Note__c>();
        Set<Id> debitnoteIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        debitnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Debit__c, ERP7__Account__r.Name, ERP7__Organisation__r.Name, ERP7__Credit_Note_Date__c from ERP7__Debit_Note__c where ERP7__Posted__c = true and ERP7__Credit_Note_Date__c>=:StartDate and ERP7__Credit_Note_Date__c <=:EndDate and ERP7__Debit__c>0 and ERP7__Organisation__c!=null and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];
        if(debitnotes.size()>0){
            debitnoteIds = (new Map<Id, ERP7__Debit_Note__c>(debitnotes)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Debit_Note__c from ERP7__Transaction__c where ERP7__Debit_Note__c IN :debitnoteIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Debit_Note__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Debit_Note__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Debit_Note__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Debit_Note__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Debit_Note__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Debit_Note__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Debit_Note__c debitnote : debitnotes){
                if(!TransMap.containsKey(debitnote.Id)){
                    tw.noTransDebitnotes.add(debitnote);
                }
                if(TransMap.containsKey(debitnote.Id) && !LedgerMap.containskey(debitnote.Id)){
                    tw.TransNoLedgerDebitnotes.add(debitnote);
                }
                if(LedgerMap.containskey(debitnote.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(debitnote.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.LedgerMismatchDebitnotes.add(debitnote);
                    }
                }
            }
        }
        return tw;
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchExpenses(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Expense__c> unpostedExpenses = new List<ERP7__Expense__c>();
        unpostedExpenses = [select Id, Name, ERP7__Paid__c, CreatedDate, ERP7__Amount__c, ERP7__Date__c from ERP7__Expense__c where ERP7__Paid__c = false and ERP7__Date__c>=:StartDate and ERP7__Date__c <=:EndDate order by CreatedDate DESC];
        tw.unpostedExpenses = unpostedExpenses;
        List<ERP7__Expense__c> expenses = new List<ERP7__Expense__c>();
        Set<Id> expenseIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        expenses = [select Id, Name, ERP7__Paid__c, CreatedDate, ERP7__Amount__c, ERP7__Date__c from ERP7__Expense__c where ERP7__Paid__c = true and ERP7__Date__c>=:StartDate and ERP7__Date__c <=:EndDate order by CreatedDate DESC];
        if(expenses.size()>0){
            expenseIds = (new Map<Id, ERP7__Expense__c>(expenses)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Expense__c	 from ERP7__Transaction__c where ERP7__Expense__c IN :expenseIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Expense__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Expense__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Expense__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Expense__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Expense__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Expense__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Expense__c exp : expenses){
                if(!TransMap.containsKey(exp.Id)){
                    tw.noTransExpenses.add(exp);
                }
                if(TransMap.containsKey(exp.Id) && !LedgerMap.containskey(exp.Id)){
                    tw.TransNoLedgerExpenses.add(exp);
                }
                if(LedgerMap.containskey(exp.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(exp.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.LedgerMismatchExpenses.add(exp);
                    }
                }
            }
        }
        return tw;
    }
    
    @AuraEnabled
    public static List<ERP7__Transaction__c> unReconciledTransactions(String OrgId, Date StartDate, Date EndDate){
        List<ERP7__Transaction__c> unReconcileTrans = new List<ERP7__Transaction__c>();
        unReconcileTrans = [select Id, Name, ERP7__Amount__c, CreatedDate, ERP7__Transaction_Date__c, ERP7__Organisation__r.Name from ERP7__Transaction__c where ERP7__Reconciled__c = false and ERP7__Transaction_Date__c>=:StartDate and ERP7__Transaction_Date__c <=:EndDate and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];
        return unReconcileTrans;
    }
    
    @AuraEnabled
    public static ledgerWrap assetInventory(String OrgId, Date StartDate, Date EndDate){
        ledgerWrap wrap = new ledgerWrap();
        List<ERP7__Finance_General_Ledger_Entry__c> assetLederList = new List<ERP7__Finance_General_Ledger_Entry__c>();
        assetLederList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Asset_Account__c, ERP7__Transactions__r.ERP7__Depreciation_Schedule__r.ERP7__Year__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.Name, ERP7__Organisation__r.Name, ERP7__Transactions__r.ERP7__Transaction_Date__c, ERP7__Transactions__r.ERP7__Amount__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Chart_of_Account__r.ERP7__Asset_Account__c = true and ERP7__Transactions__r.ERP7__Transaction_Date__c>=:StartDate and ERP7__Transactions__r.ERP7__Transaction_Date__c <=:EndDate and ERP7__Transactions__r.ERP7__Organisation__c=:OrgId order by ERP7__Chart_of_Account__r.Name DESC];
        wrap.ledgerEntries = assetLederList;
        for(ERP7__Finance_General_Ledger_Entry__c ledger : assetLederList){
            if(ledger.ERP7__Credit_Entry__c!=null) wrap.CreditSum = wrap.CreditSum + ledger.ERP7__Credit_Entry__c;
            if(ledger.ERP7__Debit_Entry__c!=null) wrap.DebitSum = wrap.DebitSum + ledger.ERP7__Debit_Entry__c;
        }
        return wrap;
    }
    
    @AuraEnabled
    public static ledgerWrap Receivable(String OrgId, Date StartDate, Date EndDate){
        ledgerWrap wrap = new ledgerWrap();
        List<ERP7__Finance_General_Ledger_Entry__c> assetLederList = new List<ERP7__Finance_General_Ledger_Entry__c>();
        assetLederList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Asset_Account__c, ERP7__Transactions__r.ERP7__Depreciation_Schedule__r.ERP7__Year__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.Name, ERP7__Organisation__r.Name, ERP7__Transactions__r.ERP7__Transaction_Date__c, ERP7__Transactions__r.ERP7__Amount__c from ERP7__Finance_General_Ledger_Entry__c where (ERP7__Chart_of_Account__r.Name LIKE '%RECEIVABLE%' OR ERP7__Chart_of_Account__r.Name LIKE '%Receivable%') and ERP7__Transactions__r.ERP7__Transaction_Date__c>=:StartDate and ERP7__Transactions__r.ERP7__Transaction_Date__c <=:EndDate  and ERP7__Transactions__r.ERP7__Organisation__c=:OrgId order by ERP7__Chart_of_Account__r.Name DESC];
        wrap.ledgerEntries = assetLederList;
        for(ERP7__Finance_General_Ledger_Entry__c ledger : assetLederList){
            if(ledger.ERP7__Credit_Entry__c!=null) wrap.CreditSum = wrap.CreditSum + ledger.ERP7__Credit_Entry__c;
            if(ledger.ERP7__Debit_Entry__c!=null) wrap.DebitSum = wrap.DebitSum + ledger.ERP7__Debit_Entry__c;
        }
        return wrap;
    }
    
    @AuraEnabled
    public static ledgerWrap Payable(String OrgId, Date StartDate, Date EndDate){
        ledgerWrap wrap = new ledgerWrap();
        List<ERP7__Finance_General_Ledger_Entry__c> assetLederList = new List<ERP7__Finance_General_Ledger_Entry__c>();
        assetLederList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Asset_Account__c, ERP7__Transactions__r.ERP7__Depreciation_Schedule__r.ERP7__Year__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.Name, ERP7__Organisation__r.Name, ERP7__Transactions__r.ERP7__Transaction_Date__c, ERP7__Transactions__r.ERP7__Amount__c from ERP7__Finance_General_Ledger_Entry__c where (ERP7__Chart_of_Account__r.Name LIKE '%PAYABLE%' OR ERP7__Chart_of_Account__r.Name LIKE '%Payable%') and ERP7__Transactions__r.ERP7__Transaction_Date__c>=:StartDate and ERP7__Transactions__r.ERP7__Transaction_Date__c <=:EndDate and ERP7__Transactions__r.ERP7__Organisation__c=:OrgId order by ERP7__Chart_of_Account__r.Name DESC];
        wrap.ledgerEntries = assetLederList;
        for(ERP7__Finance_General_Ledger_Entry__c ledger : assetLederList){
            if(ledger.ERP7__Credit_Entry__c!=null) wrap.CreditSum = wrap.CreditSum + ledger.ERP7__Credit_Entry__c;
            if(ledger.ERP7__Debit_Entry__c!=null) wrap.DebitSum = wrap.DebitSum + ledger.ERP7__Debit_Entry__c;
        }
        return wrap;
    }
    
    @AuraEnabled
    public static ledgerWrap incomeRevenue(String OrgId, Date StartDate, Date EndDate){
        ledgerWrap wrap = new ledgerWrap();
        List<ERP7__Finance_General_Ledger_Entry__c> assetLederList = new List<ERP7__Finance_General_Ledger_Entry__c>();
        assetLederList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Asset_Account__c, ERP7__Transactions__r.ERP7__Depreciation_Schedule__r.ERP7__Year__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.Name, ERP7__Organisation__r.Name, ERP7__Transactions__r.ERP7__Transaction_Date__c, ERP7__Transactions__r.ERP7__Amount__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Chart_of_Account__r.RecordType.DeveloperName = 'Income_Revenue' and ERP7__Transactions__r.ERP7__Transaction_Date__c>=:StartDate and ERP7__Transactions__r.ERP7__Transaction_Date__c <=:EndDate  and ERP7__Transactions__r.ERP7__Organisation__c=:OrgId order by ERP7__Chart_of_Account__r.Name DESC];
        wrap.ledgerEntries = assetLederList;
        for(ERP7__Finance_General_Ledger_Entry__c ledger : assetLederList){
            if(ledger.ERP7__Credit_Entry__c!=null) wrap.CreditSum = wrap.CreditSum + ledger.ERP7__Credit_Entry__c;
            if(ledger.ERP7__Debit_Entry__c!=null) wrap.DebitSum = wrap.DebitSum + ledger.ERP7__Debit_Entry__c;
        }
        assetLederList = [select Id, Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Asset_Account__c, ERP7__Transactions__r.ERP7__Depreciation_Schedule__r.ERP7__Year__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.Name, ERP7__Organisation__r.Name, ERP7__Transactions__r.ERP7__Transaction_Date__c, ERP7__Transactions__r.ERP7__Amount__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Chart_of_Account__r.RecordType.DeveloperName = 'Expense' and ERP7__Transactions__r.ERP7__Transaction_Date__c>=:StartDate and ERP7__Transactions__r.ERP7__Transaction_Date__c <=:EndDate and ERP7__Transactions__r.ERP7__Organisation__c=:OrgId order by ERP7__Chart_of_Account__r.Name DESC];
        wrap.expenseEntries = assetLederList;
        for(ERP7__Finance_General_Ledger_Entry__c ledger : assetLederList){
            if(ledger.ERP7__Credit_Entry__c!=null) wrap.ExpenseCreditSum = wrap.ExpenseCreditSum + ledger.ERP7__Credit_Entry__c;
            if(ledger.ERP7__Debit_Entry__c!=null) wrap.ExpenseDebitSum = wrap.ExpenseDebitSum + ledger.ERP7__Debit_Entry__c;
        }
        return wrap;
    }
    
    @AuraEnabled 
    public static String getInvoiceUpdate(String InvoiceId){
        ERP7__Invoice__c inv=new ERP7__Invoice__c();
        if(String.isNotEmpty(InvoiceId)){
            try{ 
                inv=[SELECT Id, Name, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c,ERP7__Status__c,RecordType.Name,RecordTypeId, ERP7__Account__c,ERP7__Account__r.Name,ERP7__Type__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c
                     ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order_S__r.Name,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c , ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c                  
                     ,ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c
                     FROM ERP7__Invoice__c 
                     WHERE Id=:InvoiceId];
                if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted__c.isUpdateable()){ if(inv.ERP7__Posted__c) inv.ERP7__Posted__c=false;  else inv.ERP7__Posted__c=true; } else{ /* no access*/ }
                //Moin added this on 29th november 
                if(inv.ERP7__Posted__c) inv.ERP7__Posted_Date__c = system.today();
                if(Schema.sObjectType.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.isUpdateable()){ upsert inv; } else{ /* no access*/ }
                return '';  
            }catch(Exception ex){  
                String errorMessage = String.valueOf(ex.getMessage());
                return errorMessage;  
            } 
        } 
        return null;  
    }
    
    @AuraEnabled 
    public static String getPaymentUpdate(String PaymentId){
        ERP7__Payment__c pay=new ERP7__Payment__c();
        if(String.isNotEmpty(PaymentId)){
            try{ 
                pay=[SELECT Id, Name, ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Sales_Order__r.Name,ERP7__Order__r.Name, ERP7__Amount__c, ERP7__Status__c, ERP7__Type__c, ERP7__Account__c, ERP7__Account__r.Name,
                     RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c,ERP7__Sales_Order__r.ERP7__Account__r.Name,ERP7__Order__r.Account.Name            
                     FROM ERP7__Payment__c 
                     WHERE Id=:PaymentId];
                if(pay.ERP7__Posted__c){ if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() ){pay.ERP7__Posted__c = false;} else{ /* no access*/}
                    //pay.ERP7__Posted_Date__c = date.today();
                } 
                else{
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() ){pay.ERP7__Posted__c=true;} else{ /* no access*/} if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable()){pay.ERP7__Posted_Date__c = date.today();} else{ /*no acc*/}
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert pay; } else{ /* no access*/ }
                } 
                return '';  
            }catch(Exception ex){  
                String errorMessage = String.valueOf(ex.getMessage());
                system.debug('errorMessage-->'+errorMessage);
                return errorMessage; 
            } 
        } 
        return null;  
    }
    
    @AuraEnabled 
    public static String getCreditNoteUpdate(String CreditId){
        ERP7__Credit_Note__c creditNote=new ERP7__Credit_Note__c();
        if(String.isNotEmpty(CreditId)){
            try{ 
                creditNote=[SELECT Id, Name, ERP7__Posted__c, ERP7__Posted_Date__c FROM ERP7__Credit_Note__c 
                     WHERE Id=:CreditId];
                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Posted__c.isUpdateable() ){creditNote.ERP7__Posted__c=true;} else{ /* no access*/} 
                //if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Posted_Date__c.isUpdateable()){creditNote.ERP7__Posted_Date__c = date.today();} else{ /*no acc*/}
                if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.isUpdateable()){ upsert creditNote; } else{ /* no access*/ }
                return '';  
            }catch(Exception ex){  
                String errorMessage = String.valueOf(ex.getMessage());
                system.debug('errorMessage-->'+errorMessage);
                return errorMessage; 
            } 
        } 
        return null;  
    }
    
     @AuraEnabled 
    public static String getDebitNoteUpdate(String DebitId){
        ERP7__Debit_Note__c debitNote=new ERP7__Debit_Note__c();
        if(String.isNotEmpty(DebitId)){
            try{ 
                debitNote=[SELECT Id, Name, ERP7__Posted__c FROM ERP7__Debit_Note__c 
                     WHERE Id=:DebitId];
                if(Schema.sObjectType.ERP7__Debit_Note__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note__c.fields.ERP7__Posted__c.isUpdateable() ){debitNote.ERP7__Posted__c=true;} else{ /* no access*/} 
                //if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Posted_Date__c.isUpdateable()){creditNote.ERP7__Posted_Date__c = date.today();} else{ /*no acc*/}
                if(Schema.sObjectType.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note__c.isUpdateable()){ upsert debitNote; } else{ /* no access*/ }
                return '';  
            }catch(Exception ex){  
                String errorMessage = String.valueOf(ex.getMessage());
                system.debug('errorMessage-->'+errorMessage);
                return errorMessage; 
            } 
        } 
        return null;  
    }
    
    @AuraEnabled 
    public static String getExpenseUpdate(String ExpenseId){
        ERP7__Expense__c expense=new ERP7__Expense__c();
        if(String.isNotEmpty(ExpenseId)){
            try{ 
                expense=[SELECT Id, Name, ERP7__Post__c, ERP7__Posted_Date__c, ERP7__Paid__c FROM ERP7__Expense__c 
                     WHERE Id=:ExpenseId];
                if(Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Post__c.isCreateable() && Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Post__c.isUpdateable() ){expense.ERP7__Post__c=true;} else{ /* no access*/} 
                if(Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Paid__c.isCreateable() && Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Paid__c.isUpdateable() ){expense.ERP7__Paid__c=true;} else{ /* no access*/} 
                if(Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Posted_Date__c.isUpdateable()){expense.ERP7__Posted_Date__c = date.today();} else{ /*no acc*/}
                if(Schema.sObjectType.ERP7__Expense__c.isCreateable() && Schema.sObjectType.ERP7__Expense__c.isUpdateable()){ upsert expense; } else{ /* no access*/ }
                return '';  
            }catch(Exception ex){  
                String errorMessage = String.valueOf(ex.getMessage());
                system.debug('errorMessage-->'+errorMessage);
                return errorMessage; 
            } 
        } 
        return null;  
    }
    
    @AuraEnabled 
    public static String getBillUpdate(String BillId){
        ERP7__Bill__c bill=new ERP7__Bill__c();
        if(String.isNotEmpty(BillId)){
            try{ 
                bill=[SELECT Id, Name, ERP7__Posted__c, ERP7__Posting_Date__c FROM ERP7__Bill__c 
                     WHERE Id=:BillId];
                if(Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Posted__c.isUpdateable() ){bill.ERP7__Posted__c=true;} else{ /* no access*/} 
                if(Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Posting_Date__c.isCreateable() && Schema.sObjectType.ERP7__Bill__c.fields.ERP7__Posting_Date__c.isUpdateable()){bill.ERP7__Posting_Date__c = date.today();} else{ /*no acc*/}
                if(Schema.sObjectType.ERP7__Bill__c.isCreateable() && Schema.sObjectType.ERP7__Bill__c.isUpdateable()){ upsert bill; } else{ /* no access*/ }
                return '';  
            }catch(Exception ex){  
                String errorMessage = String.valueOf(ex.getMessage());
                system.debug('errorMessage-->'+errorMessage);
                return errorMessage; 
            } 
        } 
        return null;  
    }
    
    @AuraEnabled 
    public static ERP7__Accounting_Period__c getAccountingAccountDetails(String AccPeriodId){
        ERP7__Accounting_Period__c acc = new ERP7__Accounting_Period__c();
        if(AccPeriodId!=null && AccPeriodId!=''){
            acc = [select Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Status__c, ERP7__Organisation__c from ERP7__Accounting_Period__c where Id=:AccPeriodId];
            return acc;
        }
        return acc;
    }
    public class ledgerWrap{
        @AuraEnabled public Decimal DebitSum {get;set;}
        @AuraEnabled public Decimal CreditSum {get;set;}
        @AuraEnabled public Decimal ExpenseDebitSum {get;set;}
        @AuraEnabled public Decimal ExpenseCreditSum {get;set;}
        @AuraEnabled public List<ERP7__Finance_General_Ledger_Entry__c> ledgerEntries {get;set;}
        @AuraEnabled public List<ERP7__Finance_General_Ledger_Entry__c> expenseEntries {get;set;}
        public ledgerWrap(){
            DebitSum = ExpenseDebitSum = 0;
            CreditSum = ExpenseCreditSum = 0;
            ledgerEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
            expenseEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
        }
    }
    
    
    public class TransactionWrapper{
        @AuraEnabled public List<ERP7__Invoice__c> unpostedInvoices {get;set;}
        @AuraEnabled public List<ERP7__Invoice__c> unpaidInvoices {get;set;}
        @AuraEnabled public List<ERP7__Invoice__c> noTransInvoices {get;set;}
        @AuraEnabled public List<ERP7__Invoice__c> transNoLedgerInvoices {get;set;}
        @AuraEnabled public List<ERP7__Invoice__c> ledgerMismatchInvoices {get;set;}
        
        @AuraEnabled public List<ERP7__Bill__c> NoTransBills {get;set;}
        @AuraEnabled public List<ERP7__Bill__c> TransNoLedgerBills {get;set;}
        @AuraEnabled public List<ERP7__Bill__c> LedgerMismatchBills {get;set;}
        @AuraEnabled public List<ERP7__Bill__c> unpostedBills {get;set;}
        @AuraEnabled public List<ERP7__Bill__c> unpaidBills {get;set;}
        
        @AuraEnabled public List<ERP7__Payment__c> unpostedPayments {get;set;}
        @AuraEnabled public List<ERP7__Payment__c> NoTransPayments {get;set;}
        @AuraEnabled public List<ERP7__Payment__c> TransNoLedgerPayments {get;set;}
        @AuraEnabled public List<ERP7__Payment__c> LedgerMismatchPayments {get;set;}
        
        @AuraEnabled public List<ERP7__Expense__c> unpostedExpenses {get;set;}
        @AuraEnabled public List<ERP7__Expense__c> NoTransExpenses {get;set;}
        @AuraEnabled public List<ERP7__Expense__c> TransNoLedgerExpenses {get;set;}
        @AuraEnabled public List<ERP7__Expense__c> LedgerMismatchExpenses {get;set;}
        
        @AuraEnabled public List<ERP7__Credit_Note__c> unpostedCreditnotes {get;set;}
        @AuraEnabled public List<ERP7__Credit_Note__c> noTransCreditnotes {get;set;}
        @AuraEnabled public List<ERP7__Credit_Note__c> TransNoLedgerCreditnotes {get;set;}
        @AuraEnabled public List<ERP7__Credit_Note__c> LedgerMismatchCreditnotes {get;set;}
        
        @AuraEnabled public List<ERP7__Debit_Note__c> unpostedDebitnotes {get;set;}
        @AuraEnabled public List<ERP7__Debit_Note__c> NoTransDebitnotes {get;set;}
        @AuraEnabled public List<ERP7__Debit_Note__c> TransNoLedgerDebitnotes {get;set;}
        @AuraEnabled public List<ERP7__Debit_Note__c> LedgerMismatchDebitnotes {get;set;}
        
        public TransactionWrapper(){
            unpostedInvoices = new List<ERP7__Invoice__c>();
            unpaidInvoices = new List<ERP7__Invoice__c>();
            noTransInvoices = transNoLedgerInvoices = ledgerMismatchInvoices = new List<ERP7__Invoice__c>();
            NoTransBills = TransNoLedgerBills = LedgerMismatchBills = new List<ERP7__Bill__c>();
            NoTransPayments = TransNoLedgerPayments = LedgerMismatchPayments = new List<ERP7__Payment__c>();
            NoTransExpenses = TransNoLedgerExpenses = LedgerMismatchExpenses = new List<ERP7__Expense__c>();
            noTransCreditnotes = TransNoLedgerCreditnotes = LedgerMismatchCreditnotes = new List<ERP7__Credit_Note__c>();
            NoTransDebitNotes = TransNoLedgerDebitNotes = LedgerMismatchDebitNotes = new List<ERP7__Debit_Note__c>();
            unpostedBills = new List<ERP7__Bill__c>();
            unpaidBills = new List<ERP7__Bill__c>();
            unpostedPayments = new List<ERP7__Payment__c>();
            unpostedExpenses = new List<ERP7__Expense__c>();
            unpostedCreditnotes = new List<ERP7__Credit_Note__c>();
            unpostedDebitnotes = new List<ERP7__Debit_Note__c>();
        }
    }
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        public selectOptions(String lab, string val) {
            label = lab; value = val; 
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab; value = val; selected = sel;
        }
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