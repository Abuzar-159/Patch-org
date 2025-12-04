global with sharing class Scheduler {

    public MRP__c MRP                                            { get; set; }
    public Schedule__c Schedule                                  { get; set; }
    public List<Schedule__c> Schedules                           { get; set; }
    public List<Process_Cycle__c> processCycles                  { get; set; }
    public String schedulesString                                { get; set; }
    public String comAppend                                      { get; set; }
    public String jString                                        { get; set; }
    public Boolean proceed                                       { get; set; }
    public String searchString                                   { get; set; }
    public String workOrderSrc                                   { get; set; }
    public String workStationSrc                                 { get; set; }
    public String searchStringId                                 { get; set; }
    public String workOrderSrcId                                 { get; set; }
    public String workStationSrcId                               { get; set; }
    public String globalsearch                                   { get; set; }
    public String profileImageUrl                                { get; set; }
    public Map<Id, Schedule__c> mapSchedules                     { get; set; }
    public Schedule__c selSchedule                               { get; set; }
    public List<Resource_Allocation__c> workForceAllocations     { get; set; }
    public List<Resource_Allocation__c> workForceAllocations2Del { get; set; }
    public String scheduleId                                     { get; set; }
    public Integer counter                                       { get; set; }
    public String searchEmpString                                { get; set; }
    public String searchEmpId                                    { get; set; }
    public List<Schedule__c> selSchedules                        { get; set; }
    public List<Employee> AllocatedEmployeeList                  { get; set; }
    public List<Employee> AvailableEmployeeList                  { get; set; }
    public List<Employee> EmployeeList                           { get; set; }
    public String empIdsAllocated                                { get; set; }
    public List<Machine> AllocatedMachineList                    { get; set; }
    public List<Machine> AvailableMachineList                    { get; set; }
    public List<Machine> MachineList                             { get; set; }
    public String machineIdsAllocated                            { get; set; }
    public List<Resource_Allocation__c > MachineAllocs           { get; set; }
    public List<Resource_Allocation__c > ResourceAllocation      { get; set; }
    public List<Resource_Allocation__c > MachineAllocs2Del       { get; set; }
    public List<Actions_Tasks__c> ScheduleChecklist              { get; set; }
    public List<Actions_Tasks__c> ScheduleChecklist2Del          { get; set; }
    public List<MRP__c> ScheduleMRPs                             { get; set; }
    public List<MRP__c> ScheduleMRPs2Del                         { get; set; }
    public Boolean switchCheck                                   { get; set; }
    public Boolean selectAll                                     { get; set; }
    public Boolean deSelectAll                                   { get; set; }
    public List<ResourceAllocation> ResourceAllocations          { get; set; }
    public List<Resource_Allocation__c> Resource2Del             { get; set; }
    public String ErrMsg                                         { get; set; }
    public Boolean Error                                         { get; set; }
    public String searchMachString                               { get; set; }
    public String selectedType                                   { get; set; }
    
    public List<Process__c> processes                            { get; set; }
    public List<Process_Cycle__c> PCs                            { get; set; } 
    public List<Schedule__c> scheduless                          { get; set; } 
    public List<processWrapper> PWL                              { get; set; } 
    
    public static Map<String, Schema.SObjectType> schemaMap;
    
    public Scheduler(){
    try{
        selectAll = false;
        deselectAll = false;
        switchCheck = true;
        Error = false;
        schedulesString = ErrMsg = searchMachString = '';
        scheduleId = '';
        globalsearch = '';
        selectedType = 'ra'; //checklist
        if(searchString == null) searchString = '';
        workOrderSrc = workStationSrc = '';
        mrp = new MRP__c();
        schedule = new Schedule__c();
        FetchSchedulesAndCycles();
        proceed = false;
        mapSchedules = new Map<Id, Schedule__c>();
        
        comAppend = Community_Util.communityValue();
        if(comAppend == null || comAppend == '') {
            comAppend = '/apex';
        } else {
            comAppend = '/' + comAppend + '/apex';
        }
        User user;
        if(Schema.sObjectType.User.isAccessible())
        user= [select FullPhotoUrl, SmallPhotoUrl from User where Id =: UserInfo.getUserId()];
        profileImageUrl=user.FullPhotoUrl; 
        workForceAllocations2Del = new List<Resource_Allocation__c>();
        ScheduleChecklist2Del = new List<Actions_Tasks__c>();
        empIdsAllocated = 'Employees';
        Resource2Del = new List<Resource_Allocation__c>();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return ;
        }
    }
    
    public PageReference switchTab(){
        switchCheck = true;
        selectAll = false;
        deselectAll = false;
        return null;
    }
    
    public PageReference switchTabs(){
        switchCheck = false;
        selectAll = false;
        deselectAll = false;
        return null;
    }
    
    @RemoteAction
    global static List<Product_Service__c> searchProducts(String searchString) {
        if(!Schema.sObjectType.Product_Service__c.isAccessible()){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Product_Service__c.Label));} else {
        List<Product_Service__c> products = Database.query('Select Id, Name from ERP7__Product_Service__c where name like \'%' + String.escapeSingleQuotes(searchString) + '%\'');
            return products;} return null;
    }
    
    @RemoteAction
    global static List<Product2> searchProductsP(String searchString) {
        if(!Schema.sObjectType.Product2.isAccessible()){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Product2.Label));} else {
        List<Product2> products = Database.query('Select Id, Name from Product2 where name like \'%' + String.escapeSingleQuotes(searchString) + '%\'');
            return products;} return null;
    }
    
    @RemoteAction
    global static List<WO__c> searchWOs(String searchString) {
        if(!Schema.sObjectType.WO__c.isAccessible() || Schema.sObjectType.WO__c.Fields.Name.isAccessible()){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.WO__c.Label));} else {
        List<WO__c> WOs = Database.query('Select Id, Name from ERP7__WO__c where name like \'%' + String.escapeSingleQuotes(searchString) + '%\'');
            return WOs;} return null;
    }
    
   
    @RemoteAction
    global static List<Work_Station__c> searchWSs(String searchString) {
        if(!Schema.sObjectType.Work_Station__c.isAccessible() || Schema.sObjectType.ERP7__Work_Station__c.Fields.Name.isAccessible()){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.WO__c.Label));} else {
        List<Work_Station__c> WSs = Database.query('Select Id, Name from ERP7__Work_Station__c where name like \'%' + String.escapeSingleQuotes(searchString) + '%\'');
        return WSs;}return null;
    }
   
    
    @RemoteAction
    global static List<Work_Center__c> searchWSss(String searchString) {
        if(!Schema.sObjectType.Work_Center__c.isAccessible() || Schema.sObjectType.ERP7__Work_Center__c.Fields.Name.isAccessible()){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.WO__c.Label));} else {
        List<Work_Center__c> WSs = Database.query('Select Id, Name from ERP7__Work_Center__c where name like \'%' + String.escapeSingleQuotes(searchString) + '%\'');
        return WSs;}return null;
    }
   
    public PageReference selectDeselectAllAvailableEmployees(){
        if(selectAll == true){
            for(Employee e : AvailableEmployeeList){
                e.selected = true;
            }
        } 
        else {
            for(Employee e : AvailableEmployeeList){
                e.selected = false;
            }
        }
        return null;
    }
    
    public PageReference selectDeselectAllAllocatedEmployees(){
        if(deSelectAll == true){
            for(Employee e : AllocatedEmployeeList){
                e.selected = true;
            }
        } 
        else {
            for(Employee e : AllocatedEmployeeList){
                e.selected = false;
            }
        }
        return null;
    }
    
    
    public PageReference selectDeselectAllAvailableMachines(){
        if(selectAll == true){
            for(Machine e : AvailableMachineList){
                e.selected = true;
            }
        } 
        else {
            for(Machine e : AvailableMachineList){
                e.selected = false;
            }
        }
        return null;
    }
    
    public PageReference selectDeselectAllAllocatedMachines(){
        if(deSelectAll == true){
            for(Machine e : AllocatedMachineList){
                e.selected = true;
            }
        } 
        else {
            for(Machine e : AllocatedMachineList){
                e.selected = false;
            }
        }
        return null;
    }
    
    
    
    
    public PageReference addEmployees(){
    try{
        selectAll = false;
        deSelectAll = false;
        
        for(Integer i=0; i<AllocatedEmployeeList.size(); i++){
            AllocatedEmployeeList[i].selected = false;
        }
        for(Employee e : AvailableEmployeeList){
            if(e.selected == true){
                e.selected = false;  
                Employee en = new Employee();
                en.Id = e.Id;
                en.Name = e.Name;
                en.Selected = false;
                en.Employee = e.Employee;
                AllocatedEmployeeList.add(en);
                ResourceAllocation resAlloc = new ResourceAllocation();
                Resource_Allocation__c RA = new Resource_Allocation__c();
                    RA.Schedule__c = selSchedule.Id;
                    RA.Employees__c = e.Id;
                    RA.Name = selSchedule.Name;
                    RA.ERP7__Active__c = true;
                    if(Schema.SObjectType.Schedule__c.Fields.ERP7__Schedule_Start_Date__c.isAccessible() && selSchedule.ERP7__Schedule_Start_Date__c != Null) RA.ERP7__Start_Date__c = selSchedule.ERP7__Schedule_Start_Date__c;
                    if(Schema.SObjectType.Schedule__c.Fields.ERP7__Schedule_End_Date__c.isAccessible() && selSchedule.ERP7__Schedule_End_Date__c != Null) RA.ERP7__End_Date__c = selSchedule.ERP7__Schedule_End_Date__c;
                    if(Schema.SObjectType.Schedule__c.Fields.Work_Center_Assignment__c.isAccessible() && selSchedule.Work_Center_Assignment__r.Work_Center__c != Null) RA.ERP7__Work_Center__c = selSchedule.Work_Center_Assignment__r.Work_Center__c;
                    if(Schema.SObjectType.Schedule__c.Fields.ERP7__Product__c.isAccessible() && selSchedule.ERP7__Product__c != Null) RA.ERP7__Product__c = selSchedule.ERP7__Product__c;
                    if(Schema.SObjectType.Schedule__c.Fields.ERP7__Process__c.isAccessible() && selSchedule.ERP7__Process__c != Null) RA.ERP7__Process__c = selSchedule.ERP7__Process__c;
                resAlloc.RA = RA;
                ResourceAllocations.add(resAlloc);
            }
        } 
         return null;    
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
             return null;
         }
         
    }
    
    public PageReference removeEmployees(){
    try{
        selectAll = false;
        deSelectAll = false;
        
        
        for(Integer i=0; i<AvailableEmployeeList.size(); i++){
            AvailableEmployeeList[i].selected = false;
        }
        for(Employee e : AllocatedEmployeeList){
           if(e.selected == true){
                Employee en = new Employee();
                en.Id = e.Id;
                en.Name = e.Name;
                en.Selected = false;
                en.Employee = e.Employee;
                AvailableEmployeeList.add(en);
            }
        }
        
        Integer sizek  = AllocatedEmployeeList.size();
        while(sizek > 0){
            if(AllocatedEmployeeList[sizek-1].selected == true)
            AllocatedEmployeeList.remove(sizek-1);
            sizek--;
        }
         return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
            }
    }
    
    public PageReference RemoveResources(){
    try{
        for(ResourceAllocation RA : ResourceAllocations){
            if(RA.Selected == true){
                if(RA.RA.Id != Null) Resource2Del.add(RA.RA);
            }
        }
        Integer sizek  = ResourceAllocations.size();
        while(sizek > 0){
            if(ResourceAllocations[sizek-1].selected == true)
            ResourceAllocations.remove(sizek-1);
            sizek--;
        }
       if(Schema.sObjectType.Resource_Allocation__c.isDeletable()) DMLManager.deleteAsUser(Resource2Del);
        WorkforceResources();
         return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
        }
    }
    
    public PageReference SaveResources(){
    try{
        // Validations
        List<Resource_Allocation__c>  RAS = new List<Resource_Allocation__c>();
        Set<Id> empIds = new Set<Id>();
        Set<Id> macIds = new Set<Id>();
        List<Id> ras2excludeIds = new List<Id>();
        boolean error = false;
        schemaMap = Schema.getGlobalDescribe();
        for(ResourceAllocation RA : ResourceAllocations){
            if(RA.RA.ERP7__Start_Date__c >= RA.RA.ERP7__End_Date__c || RA.RA.ERP7__Start_Date__c < selSchedule.ERP7__Schedule_Start_Date__c || RA.RA.ERP7__End_Date__c > selSchedule.ERP7__Schedule_End_Date__c){ 
                Ra.ErrMsg = 'Resource start date and end date should always fall within the schedule or Invalid dates'; 
                Ra.Error = true;  
                error = true;
            }else{
                if(RA.RA.Employees__c != Null) empIds.add(RA.RA.Employees__c);
                if(RA.RA.Machine__c != Null) macIds.add(RA.RA.Machine__c);
                if(RA.RA.Id != Null) ras2excludeIds.add(RA.RA.Id);
            }
        }
        
        if(!error){
             DateTime ssd;
             if(Schema.SObjectType.Schedule__c.Fields.ERP7__Schedule_Start_Date__c.isAccessible()) ssd = selSchedule.ERP7__Schedule_Start_Date__c;
            DateTime sed;
            if(Schema.SObjectType.Schedule__c.Fields.ERP7__Schedule_End_Date__c.isAccessible()) sed = selSchedule.ERP7__Schedule_End_Date__c;
            Date ssdd = date.newinstance(ssd.year(), ssd.month(), ssd.day());
            Date sedd = date.newinstance(sed.year(), sed.month(), sed.day());
            
            String allFieldsemp = fetchAllFields('ERP7__Employees__c');
            utilClass.FLSCheck(allFieldsemp.split(','),'ERP7__Employees__c');
            allFieldsemp += ', ReportingManager__r.Name, Employee_Profiling__r.Name';
            String queryemp = 'select ' + String.escapeSingleQuotes(allFieldsemp) + ' from ERP7__Employees__c where Active__c = true and Id in : empIds';
            List<ERP7__Employees__c> Employees; 
            if(Schema.sObjectType.Employees__c.isAccessible())
            Employees = Database.query(queryemp);
            Map<Id,ERP7__Employees__c> empMap = new Map<Id,ERP7__Employees__c>();
            for(ERP7__Employees__c e : Employees){
                empMap.put(e.Id,e);
            }
            
            String allFieldsm = fetchAllFields('ERP7__Machine__c');
            utilClass.FLSCheck(allFieldsm.split(','),'ERP7__Machine__c');
            String querym = 'select ' + String.escapeSingleQuotes(allFieldsm) + ' from ERP7__Machine__c where Id in : macIds';
            List<ERP7__Machine__c> Machines;
            if(Schema.sObjectType.Machine__c.isAccessible())
            Machines = Database.query(querym);
            Map<Id,ERP7__Machine__c> macMap = new Map<Id,ERP7__Machine__c>();
            for(ERP7__Machine__c m : Machines){
                macMap.put(m.Id,m);
            }
            
            String allFields2 = fetchAllFields('ERP7__Leave_Entitlements_Holidays__c');
            utilClass.FLSCheck(allFields2.split(','),'ERP7__Leave_Entitlements_Holidays__c');
            allFields2 += ', ERP7__Leave_Entitlement__r.Employee__c ';
            String query2 = 'select ' + String.escapeSingleQuotes(allFields2) + ' from ERP7__Leave_Entitlements_Holidays__c where ERP7__Active__c = true and ERP7__Leave_Entitlement__r.Employee__c in : empIds and ERP7__Valid_From_Date__c >= :ssdd  and ERP7__Valid_To_Date__c <= :sedd ';
            List<ERP7__Leave_Entitlements_Holidays__c> EmployeeLeaves;
            if(Schema.sObjectType.Leave_Entitlements_Holidays__c.isAccessible())
            EmployeeLeaves = Database.query(query2);
            
            String allFields3 = fetchAllFields('ERP7__Resource_Allocation__c');
            utilClass.FLSCheck(allFields3.split(','),'ERP7__Resource_Allocation__c');
            allFields3 += ', Employees__r.Name ';
            String query3 = 'select ' + String.escapeSingleQuotes(allFields3) + ' from Resource_Allocation__c where Id not in : ras2excludeIds and (Employees__c In : empIds or Machine__c In : macIds) and Start_Date__c >= :ssd and End_Date__c <= :sed order by CreatedDate asc ';
            List<ERP7__Resource_Allocation__c> RAllocations;
            if(Schema.sObjectType.Resource_Allocation__c.isAccessible())
            RAllocations= Database.query(query3);
            
            for(ResourceAllocation RA : ResourceAllocations){
                if(RA.RA.Id != Null) RAllocations.add(RA.RA);
            }
            
            Map<Id,List<Resource_Allocation__c>> empResources = new Map<Id,List<Resource_Allocation__c>>();
            for(Id EId : empIds){
                List<Resource_Allocation__c> myRA = new List<Resource_Allocation__c>();
                for(Resource_Allocation__c RAE : RAllocations){
                    if(RAE.Employees__c == EId){
                        myRA.add(RAE);
                    }
                }
                empResources.put(EId,myRA);
            }
            
            Map<Id,List<Resource_Allocation__c>> macResources = new Map<Id,List<Resource_Allocation__c>>();
            for(Id EId : macIds){
                List<Resource_Allocation__c> myRA = new List<Resource_Allocation__c>();
                for(Resource_Allocation__c RAE : RAllocations){
                    if(RAE.Machine__c == EId){
                        myRA.add(RAE);
                    }
                }
                macResources.put(EId,myRA);
            }
            
            Map<Id,List<ERP7__Leave_Entitlements_Holidays__c>> empLeaves = new Map<Id,List<ERP7__Leave_Entitlements_Holidays__c>>();
            for(Id EId : empIds){
                List<ERP7__Leave_Entitlements_Holidays__c> myRA = new List<ERP7__Leave_Entitlements_Holidays__c>();
                for(ERP7__Leave_Entitlements_Holidays__c RAE : EmployeeLeaves){
                    if(RAE.ERP7__Leave_Entitlement__r.Employee__c == EId){
                        myRA.add(RAE);
                    }
                }
                empLeaves.put(EId,myRA);
            }
            
            for(ResourceAllocation RA : ResourceAllocations){
                if(RA.RA.Employees__c != Null){
                
                    //--------- Other Resources ------------
                    List<Resource_Allocation__c> ERA = empResources.get(RA.RA.Employees__c);
                    for(Resource_Allocation__c RAE : ERA){
                         if(RA.RA.Id != RAE.Id && RAE.Employees__c != Null && ((RAE.Start_Date__c >= RA.RA.Start_Date__c && RAE.End_Date__c <= RA.RA.End_Date__c) ||
                            (RA.RA.Start_Date__c >= RAE.Start_Date__c && RA.RA.End_Date__c <= RAE.End_Date__c) ||
                            (RAE.Start_Date__c < RA.RA.Start_Date__c && RAE.End_Date__c > RA.RA.Start_Date__c && RAE.End_Date__c <= RA.RA.End_Date__c) ||
                            (RAE.Start_Date__c > RA.RA.Start_Date__c && RAE.End_Date__c > RA.RA.End_Date__c && RAE.Start_Date__c < RA.RA.End_Date__c))){ 
                                Ra.ErrMsg = 'Employee already allocated for this time'; 
                                Ra.Error = true;  
                                error = true;
                        }
                    }
                    
                    //--------- Leaves ------------
                    if(!Ra.Error){
                        List<ERP7__Leave_Entitlements_Holidays__c> empHolidays = empLeaves.get(RA.RA.Employees__c);
                        Date ssddd = date.newinstance(RA.RA.Start_Date__c.year(), RA.RA.Start_Date__c.month(), RA.RA.Start_Date__c.day());
                        Date seddd = date.newinstance(RA.RA.End_Date__c.year(), RA.RA.End_Date__c.month(), RA.RA.End_Date__c.day());
                        for(ERP7__Leave_Entitlements_Holidays__c Leav : empHolidays){
                             if(((Leav.Valid_From_Date__c >= ssddd && Leav.Valid_To_Date__c <= seddd) ||
                                (ssddd >= Leav.Valid_From_Date__c && seddd <= Leav.Valid_To_Date__c) ||
                                (Leav.Valid_From_Date__c < ssddd && Leav.Valid_To_Date__c > ssddd && Leav.Valid_To_Date__c <= seddd) ||
                                (Leav.Valid_From_Date__c > ssddd && Leav.Valid_To_Date__c > seddd && Leav.Valid_From_Date__c < seddd))){ 
                                    Ra.ErrMsg = 'Employee is on Leave for this time'; 
                                    Ra.Error = true;  
                                    error = true;
                            }
                        }
                    }
                    if(!Ra.Error){
                        //--------- Hours ------------
                        Employees__c employe = empMap.get(RA.RA.Employees__c);
                        decimal hoursnew;
                        if(RA.RA.Start_Date__c != null && RA.RA.End_Date__c != null){
                            decimal Hours = decimal.valueOf((RA.RA.End_Date__c.getTime() - RA.RA.Start_Date__c.getTime()));
                            hoursnew = (Hours/(1000*60*60)).setscale(2);
                            if(employe.No_of_Hours_Day__c != Null && hoursnew >= 24){
                                Decimal maxhoursperday = (employe.Maximum_Overtime_Hours_Day__c != Null)? employe.No_of_Hours_Day__c + employe.Maximum_Overtime_Hours_Day__c : employe.No_of_Hours_Day__c;
                                hoursnew = hoursnew*maxhoursperday/24;
                            }
                            else if(employe.No_of_Hours_Day__c != Null && hoursnew < 24){
                                Decimal maxhoursperday = (employe.Maximum_Overtime_Hours_Day__c != Null)? employe.No_of_Hours_Day__c + employe.Maximum_Overtime_Hours_Day__c : employe.No_of_Hours_Day__c;
                                hoursnew = maxhoursperday;
                            }
                            if(employe.No_of_Hours_Day__c == Null && hoursnew >= 24){
                                hoursnew = hoursnew*16/24;
                            }
                            else if(employe.No_of_Hours_Day__c == Null && hoursnew < 24){
                               hoursnew = 16;
                            }
                        }
                        if(RA.RA.Hours__c > hoursnew){
                            Ra.ErrMsg = 'Max Hours for this employee can be '+String.valueof(hoursnew); 
                            Ra.Error = true;  
                            error = true;
                        }
                        
                    }
                }
                
                //machines validations
                
                if(RA.RA.Machine__c != Null){
                
                    //--------- Other Resources ------------
                    List<Resource_Allocation__c> ERA = macResources.get(RA.RA.Machine__c);
                    for(Resource_Allocation__c RAE : ERA){
                         if(RA.RA.Id != RAE.Id && RAE.Machine__c != Null && ((RAE.Start_Date__c >= RA.RA.Start_Date__c && RAE.End_Date__c <= RA.RA.End_Date__c) ||
                            (RA.RA.Start_Date__c >= RAE.Start_Date__c && RA.RA.End_Date__c <= RAE.End_Date__c) ||
                            (RAE.Start_Date__c < RA.RA.Start_Date__c && RAE.End_Date__c > RA.RA.Start_Date__c && RAE.End_Date__c <= RA.RA.End_Date__c) ||
                            (RAE.Start_Date__c > RA.RA.Start_Date__c && RAE.End_Date__c > RA.RA.End_Date__c && RAE.Start_Date__c < RA.RA.End_Date__c))){ 
                                Ra.ErrMsg = 'Machine already allocated for this time'; 
                                Ra.Error = true;  
                                error = true;
                        }
                    }
                    
                    if(!Ra.Error){
                        //--------- Hours ------------
                        Machine__c machin = macMap.get(RA.RA.Machine__c);
                        
                        decimal hoursnew;
                        if(RA.RA.Start_Date__c != null && RA.RA.End_Date__c != null){
                            decimal Hours = decimal.valueOf((RA.RA.End_Date__c.getTime() - RA.RA.Start_Date__c.getTime()));
                            hoursnew = (Hours/(1000*60*60)).setscale(2);
                            if(machin.Maximum_Hours_Day__c != Null && hoursnew >= 24){
                                Decimal maxhoursperday = machin.Maximum_Hours_Day__c;
                                hoursnew = hoursnew*maxhoursperday/24;
                            }
                            else if(machin.Maximum_Hours_Day__c != Null && hoursnew < 24){
                                Decimal maxhoursperday = machin.Maximum_Hours_Day__c;
                                hoursnew = maxhoursperday;
                            }
                            if(machin.Maximum_Hours_Day__c == Null && hoursnew >= 24){
                                hoursnew = hoursnew*16/24;
                            }
                            else if(machin.Maximum_Hours_Day__c == Null && hoursnew < 24){
                               hoursnew = 16;
                            }
                        }
                        if(RA.RA.Hours__c > hoursnew){
                            Ra.ErrMsg = 'Max Hours for this machine can be '+String.valueof(hoursnew); 
                            Ra.Error = true;  
                            error = true;
                        }
                        
                    }
                }
                RAS.add(RA.RA);
            }
        }
        
        
        if(!error){
            if(Schema.sObjectType.Resource_Allocation__c.isCreateable() && Schema.sObjectType.Resource_Allocation__c.isUpdateable()) { DMLManager.upsertAsUser(RAS); } else{ /* no access */ }
            WorkforceResources();
        }
         return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
        }
    }
    
    public PageReference addMachines(){
    try{
        selectAll = false;
        deSelectAll = false;
        for(Integer i=0; i<AllocatedMachineList.size(); i++){
            AllocatedMachineList[i].selected = false;
        }
        for(Machine e : AvailableMachineList){
            if(e.selected == true){
                Machine en = new Machine();
                en.Id = e.Id;
                en.Name = e.Name;
                en.Selected = false;
                en.Machine = e.Machine;
                AllocatedMachineList.add(en);
                ResourceAllocation resAlloc = new ResourceAllocation();
                Resource_Allocation__c RA = new Resource_Allocation__c();
                    RA.Schedule__c = selSchedule.Id;
                    RA.Machine__c = e.Id;
                    RA.Name = selSchedule.Name;
                    RA.ERP7__Active__c = true;
                    if(Schema.SObjectType.Schedule__c.Fields.ERP7__Schedule_Start_Date__c.isAccessible() && selSchedule.ERP7__Schedule_Start_Date__c != Null) RA.ERP7__Start_Date__c = selSchedule.ERP7__Schedule_Start_Date__c;
                    if(Schema.SObjectType.Schedule__c.Fields.ERP7__Schedule_End_Date__c.isAccessible() && selSchedule.ERP7__Schedule_End_Date__c != Null) RA.ERP7__End_Date__c = selSchedule.ERP7__Schedule_End_Date__c;
                    if(Schema.SObjectType.Schedule__c.Fields.Work_Center_Assignment__c.isAccessible() && selSchedule.Work_Center_Assignment__r.Work_Center__c != Null) RA.ERP7__Work_Center__c = selSchedule.Work_Center_Assignment__r.Work_Center__c;
                    if(Schema.SObjectType.Schedule__c.Fields.ERP7__Product__c.isAccessible() && selSchedule.ERP7__Product__c != Null) RA.ERP7__Product__c = selSchedule.ERP7__Product__c;
                    if(Schema.SObjectType.Schedule__c.Fields.ERP7__Process__c.isAccessible() && selSchedule.ERP7__Process__c != Null) RA.ERP7__Process__c = selSchedule.ERP7__Process__c;
                resAlloc.RA = RA;
                ResourceAllocations.add(resAlloc);
            }
        }
        
        
        Integer sizek  = AvailableMachineList.size();
        while(sizek > 0){
            if(AvailableMachineList[sizek-1].selected == true)
            AvailableMachineList.remove(sizek-1);
            sizek--;
        }
         return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
            }
    }
    public PageReference removeMachines(){
         for(Integer i=0; i<AvailableMachineList.size(); i++){
            AvailableMachineList[i].selected = false;
        }
        for(Machine e : AllocatedMachineList){
           if(e.selected == true){
                Machine en = new Machine();
                en.Id = e.Id;
                en.Name = e.Name;
                en.Selected = false;
                en.Machine = e.Machine;
                AvailableMachineList.add(en);
            }
        }
        
        Integer sizek  = AllocatedMachineList.size();
        while(sizek > 0){
            if(AllocatedMachineList[sizek-1].selected == true)
            AllocatedMachineList.remove(sizek-1);
            sizek--;
        }
        return null;
    }
    
    
    
    public PageReference FetchSchedulesAndCycles(){
    try{
        schemaMap = Schema.getGlobalDescribe();
        String allFields = fetchAllFields('ERP7__Schedule__c');
        UtilClass.FLSCheck(allFields.split(','),'ERP7__Schedule__c');
        mapSchedules = new Map<Id, Schedule__c>(); 
        
        String searchStringVal = '%'+searchString+'%';
        String workOrderSrcVal = '%'+workOrderSrc+'%';
        String workStationSrcVal = '%'+workStationSrc+'%';
        
        allFields += ',Work_Order_Line_Item__r.Name, Process__r.Name, Work_Order__r.Project__r.Name, Work_Order__r.Project__c, Project__r.Name, Work_Order__r.Name, Work_Order__r.Lead_Time__c, Product__r.Name, Work_Center_Assignment__r.Work_Center__c, Work_Center_Assignment__r.Work_Center__r.Name, Process_Cycle__r.Name, RecordType.Name, Schedule__r.Name, Work_Center__r.Name,Work_Center_Assignment__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c';
        String query;
        
        if(workStationSrc == '' && workOrderSrc == '' && searchString == '') query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Schedule__c order by CreatedDate asc ';
       
        else if(workStationSrc != '') query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Schedule__c where Work_Order__r.Name like : workOrderSrcVal and Product__r.Name like : searchStringVal and (Schedule__c = Null or (Work_Center_Assignment__r.Work_Center__r.Name like : workStationSrcVal and Schedule__c != Null)) order by CreatedDate asc ';
         
        else query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Schedule__c where Work_Order__r.Name like : workOrderSrcVal and Product__r.Name like : searchStringVal order by CreatedDate asc ';
       
        if(Schema.sObjectType.Schedule__c.isAccessible())
        Schedules = Database.query(query);
        
        for(Schedule__c s : Schedules){
            mapSchedules.put(s.Id,s);
        }
        
        List<data> dtaList = new List<data>();
        List<links> lnksList = new List<links>();
        
        for(Schedule__c sch : Schedules){
            DateTime SSD = (Schema.SOBjectType.Schedule__c.Fields.Schedule_Start_Date__c.isAccessible())? sch.Schedule_Start_Date__c:system.Now();
            DateTime SSDT = (Schema.SOBjectType.Schedule__c.Fields.Schedule_Start_Date__c.isAccessible())? sch.Schedule_Start_Date__c:system.Now();
            String SSDate = SSDT.format('dd/MM/yyyy HH:mm:ss'); 
            
            DateTime SED = (Schema.SOBjectType.Schedule__c.Fields.Schedule_End_Date__c.isAccessible())? sch.Schedule_End_Date__c:system.Now();
            DateTime SEDT = (Schema.SOBjectType.Schedule__c.Fields.Schedule_End_Date__c.isAccessible())? sch.Schedule_End_Date__c:system.Now();
            String SEDate = SEDT.format('dd/MM/yyyy HH:mm:ss'); 
            
            data dta = new data();
            
            dta.text = (sch.Process__r.Name != null && sch.Process__r.Name != '')? sch.Process__r.Name : sch.Name;
            
            dta.id = sch.Id; 
            dta.scheduleName = sch.Name;
            
            dta.workStation = (Schema.SOBjectType.Schedule__c.Fields.Work_Center_Assignment__c.isAccessible())? sch.Work_Center_Assignment__r.Name:'';
            dta.wsId = (Schema.SOBjectType.Schedule__c.Fields.Work_Center_Assignment__c.isAccessible())? sch.Work_Center_Assignment__c:null;
            
            dta.lineitem = (Schema.SOBjectType.Schedule__c.Fields.Work_Order_Line_Item__c.isAccessible())? sch.Work_Order_Line_Item__r.Name:'';
            dta.lineId = (Schema.SOBjectType.Schedule__c.Fields.Work_Order_Line_Item__c.isAccessible())? sch.Work_Order_Line_Item__c:null;
            
            dta.Processes = (Schema.SOBjectType.Schedule__c.Fields.Process__c.isAccessible())? sch.Process__r.Name:'';
            dta.ProcessId = (Schema.SOBjectType.Schedule__c.Fields.Process__c.isAccessible())?sch.Process__c:null;
            
            dta.WorkOrder = (Schema.SOBjectType.Schedule__c.Fields.Work_Order__c.isAccessible())? sch.Work_Order__r.Name:'';
            dta.leadTime = (Schema.SOBjectType.Schedule__c.Fields.Work_Order__c.isAccessible())? String.valueof(sch.Work_Order__r.lead_Time__c):String.valueof(system.now());
            dta.woId = (Schema.SOBjectType.Schedule__c.Fields.Work_Order__c.isAccessible())? sch.Work_Order__c:null;
            
            dta.productservice = (Schema.SOBjectType.Schedule__c.Fields.Product__c.isAccessible())? sch.Product__r.Name:'';
            dta.productId = (Schema.SOBjectType.Schedule__c.Fields.Product__c.isAccessible())? sch.Product__c:null;
            
            dta.cycle = (Schema.SOBjectType.Schedule__c.Fields.Process_Cycle__c.isAccessible())? sch.Process_Cycle__r.Name:'';
            dta.cycleId = (Schema.SOBjectType.Schedule__c.Fields.Process_Cycle__c.isAccessible())? sch.Process_Cycle__c:null;
            
            dta.status = (Schema.SOBjectType.Schedule__c.Fields.Status__c.isAccessible())? sch.Status__c:'None';
            dta.start_date = SSDate; 
            dta.end_date = SEDate;
            if(Schema.SOBjectType.Schedule__c.Fields.Progress__c.isAccessible() && sch.Progress__c != null) dta.progress = sch.Progress__c;
            dta.open = true;
            dta.duration = integer.valueof(sch.Duration__c);
            dta.scheduleType = sch.RecordType.Name;
            
            if(sch.Schedule__c != Null) {
                dta.text = (sch.Process_Cycle__c != Null)? sch.Process_Cycle__r.Name : sch.Name;
                dta.parent = sch.Schedule__c;
                dta.schedule = sch.Schedule__r.Name;
                
                dta.leadTime = '';
                dta.productservice = '';
                dta.WorkOrder = '';
                
                links lnks = new links();
                    lnks.id = sch.Id;
                    lnks.source = sch.Schedule__c;
                    lnks.target = sch.Id;
                    lnks.type = '1';
                lnksList.add(lnks);
            }
            dtaList.add(dta);
        }
        schedulesPack SP = new schedulesPack(dtaList,lnksList);
        schedulesString = JSON.serialize(SP);
         return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return Null;
        }
    }
    
    public PageReference FetchAllSchedulesAndCycles(){
    try{
        schemaMap = Schema.getGlobalDescribe();
        String allFields = fetchAllFields('ERP7__Schedule__c');
        utilClass.FLSCheck(allFields.split(','),'ERP7__Schedule__c');
        mapSchedules = new Map<Id, Schedule__c>(); 
        
        String searchStringVal = '%'+searchString+'%';
        String workOrderSrcVal = '%'+workOrderSrc+'%';
        String workStationSrcVal = '%'+workStationSrc+'%';
        
        allFields += ',Work_Order_Line_Item__r.Name, Project__r.Name, Work_Order__r.Project__r.Name, Work_Order__r.Project__c, Work_Order__r.Lead_Time__c, Process__r.Name, Work_Order__r.Name, Product__r.Name, Work_Center_Assignment__r.Work_Center__c, Work_Center_Assignment__r.Work_Center__r.Name, Process_Cycle__r.Name, RecordType.Name, Schedule__r.Name, Work_Center__r.Name,Work_Center_Assignment__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c';
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Schedule__c order by CreatedDate asc ';
        if(Schema.sObjectType.Schedule__c.isAccessible())
        Schedules = Database.query(query);
        
        for(Schedule__c s : Schedules){
            mapSchedules.put(s.Id,s);
        }
        if(Schema.sObjectType.Process__c.isAccessible())
        processes = [Select Id, Name from Process__c Limit 10000];
        if(Schema.sObjectType.Process_Cycle__c.isAccessible())
        PCs = [Select Id, Name, Process__c from Process_Cycle__c where Process__c In :processes order by createddate asc];
        
        String querys = 'select ' + String.escapeSingleQuotes(allFields) + ' from Schedule__c where Process__c In :processes order by Schedule__r.name,createdDate asc ';
        if(Schema.sObjectType.Schedule__c.isAccessible())
        scheduless = Database.query(querys);
        
        Map<Id, List<Schedule__c>> processSchedules = new  Map<Id, List<Schedule__c>>();
        Map<Id, List<Schedule__c>> subSchedules = new Map<Id, List<Schedule__c>>();
        
        //Process Loop
        for(Process__c Process : processes){
            List<Schedule__c> myParentSchedules = new List<Schedule__c>();
            for(Schedule__c s : scheduless){
                if(s.Schedule__c == Null && s.Process__c == process.Id) myParentSchedules.add(s);
            }
            processSchedules.put(process.Id,myParentSchedules);
            
            for(Schedule__c s : myParentSchedules){
                List<Schedule__c> mySubSchedules = new List<Schedule__c>();
                for(Schedule__c ss : scheduless){
                    if(s.Id == ss.Schedule__c && ss.Process_Cycle__c != Null) mySubSchedules.add(ss); //ss.Process_Cycle__c != Null
                }
                subSchedules.put(s.Id,mySubSchedules);
               
            }
        }
        PWL = new List<processWrapper>();
        
        //Process Loop
        for(Process__c Process : processes){
            processWrapper PW = new processWrapper();
            
            PW.process = Process;
            PW.processCycles = new List<Process_Cycle__c>();
            for(Process_Cycle__c PC : PCs){
                if(PC.Process__c == Process.Id){ 
                    PW.processCycles.add(PC);
                }
            } 
            List<scheduleWrapper> SWL = new List<scheduleWrapper>();
            
            for(Schedule__c s : processSchedules.get(process.Id)){
                scheduleWrapper SW = new scheduleWrapper();
                SW.cycleWrapperList = new List<cycleWrapper>();
                
                SW.schedule = s;
                List<Schedule__c> mySubSchedules = new List<Schedule__c>();
                for(Schedule__c ss : subSchedules.get(s.Id)){
                    mySubSchedules.add(ss);
                }
                
                for(Process_Cycle__c PC : PW.processCycles){
                    cycleWrapper cw = new cycleWrapper(); 
                    cw.cycle = PC;
                    boolean exist = false;
                    for(Schedule__c ss : mySubSchedules){
                        if(ss.Process_Cycle__c == PC.Id){ cw.schedule = ss; exist = true; break; }
                    }
                    if(!exist) cw.schedule = new Schedule__c();
                    SW.cycleWrapperList.add(cw); 
                    
                } 
            
                
                SW.subSchedules = mySubSchedules;
                SWL.add(SW);
            }
            PW.processSchedules = SWL;
            if(PW.processCycles.size() > 0) PWL.add(PW);
        }
         return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return Null;
        }
    }
    
    public PageReference saveSchedule() {
    try{
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jString);
        Boolean isNewSchedule = (Boolean) m.get('isNew');
        
        String scheduleId = String.valueof(m.get('id'));
        String scheduleName = String.valueof(m.get('scheduleName'));
        String workStation = String.valueof(m.get('workStation'));
        String wsId = String.valueof(m.get('wsId'));
        String lineitem = String.valueof(m.get('lineitem'));
        String lineId = String.valueof(m.get('lineId'));
        String Processes = String.valueof(m.get('Processes'));
        String processId = String.valueof(m.get('processId'));
        String WorkOrder = String.valueof(m.get('WorkOrder'));
        String woId = String.valueof(m.get('woId'));
        String productservice = String.valueof(m.get('productservice'));
        String productId = String.valueof(m.get('productId'));
        String parent = String.valueof(m.get('parent'));
        String schedul = String.valueof(m.get('schedule'));
        String cycle = String.valueof(m.get('cycle'));
        String cycleId = String.valueof(m.get('cycleId'));
        String status = String.valueof(m.get('status'));
        String scheduleType = String.valueof(m.get('scheduleType'));
        String start_date = String.valueof(m.get('start_date'));
        String start_date_temp = String.valueof(m.get('start_date_temp'));
        String progress = String.valueof(m.get('progress'));
        String duration = String.valueof(m.get('duration'));
        String end_date = String.valueof(m.get('end_date'));
        String end_date_temp = String.valueof(m.get('end_date_temp'));
       
        schemaMap = Schema.getGlobalDescribe();
        String allFields = fetchAllFields('ERP7__Schedule__c');
         utilClass.FLSCheck(allFields.split(','),'ERP7__Schedule__c');
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Schedule__c where id =: scheduleId';
        if(isNewSchedule == true) Schedule = new Schedule__c();
        else if(Schema.sObjectType.Schedule__c.isAccessible())Schedule = Database.query(query);
            Schedule.Name = scheduleName;
            if(processId != Null && processId != '') Schedule.Process__c = processId; else Schedule.Process__c = null;
            if(cycleId != Null && cycleId != '') Schedule.Process_Cycle__c = cycleId; else Schedule.Process_Cycle__c = null;
            if(productId != Null && productId != '') Schedule.Product__c = productId; else Schedule.Product__c = null;
            if(progress != Null && progress != '') Schedule.Progress__c = Decimal.valueof(progress); 
            if(parent != Null && parent != '' && parent != '0') Schedule.Schedule__c = parent; else Schedule.Schedule__c = null;
            
            String[] sd = start_date_temp.split(':');
            String[] ed = end_date_temp.split(':');
            Date mysDate = Date.newInstance(integer.valueOf(sd[0]), integer.valueOf(sd[1]), integer.valueOf(sd[2]));
            Time mysTime = Time.newInstance(integer.valueOf(sd[3]), integer.valueOf(sd[4]), integer.valueOf(sd[5]), 0);
            DateTime mysd = DateTime.newInstance(mysDate, mysTime);
            
            Date myeDate = Date.newInstance(integer.valueOf(ed[0]), integer.valueOf(ed[1]), integer.valueOf(ed[2]));
            Time myeTime = Time.newInstance(integer.valueOf(ed[3]), integer.valueOf(ed[4]), integer.valueOf(ed[5]), 0);
            DateTime myed = DateTime.newInstance(myeDate, myeTime);

            Schedule.Schedule_Start_Date__c = mysd;
            Schedule.Schedule_End_Date__c = myed;
            Schedule.Status__c = status;
            if(woId != Null && woId != '') Schedule.Work_Order__c = woId; else Schedule.Work_Order__c = null;
            if(lineId != Null && lineId != '') Schedule.Work_Order_Line_Item__c = lineId; else Schedule.Work_Order_Line_Item__c = null;
            if(wsId != Null && wsId != '') Schedule.Work_Center_Assignment__c = wsId; else Schedule.Work_Center_Assignment__c = null;
        if(Schema.sObjectType.Schedule__c.isCreateable()&& Schema.sObjectType.Schedule__c.isUpdateable()) { DMLManager.upsertAsUser(Schedule); } else{ /* not allowed */ }
        return null;
       }catch(Exception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));    
        return null;
        }
    }
    
    public PageReference updateSchedule() {
        try{
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jString);
        String scheduleId = String.valueof(m.get('id'));
        String start_date = String.valueof(m.get('start_date'));
        String progress = String.valueof(m.get('progress'));
        String duration = String.valueof(m.get('duration'));
        String end_date = String.valueof(m.get('end_date'));
        String start_date_temp = String.valueof(m.get('start_date_temp'));
        String end_date_temp = String.valueof(m.get('end_date_temp'));
       
        schemaMap = Schema.getGlobalDescribe();
        String allFields = fetchAllFields('ERP7__Schedule__c');
        utilClass.FLSCheck(allFields.split(','),'ERP7__Schedule__c');
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Schedule__c where id =: scheduleId';
        if(Schema.sObjectType.Schedule__c.isAccessible())
        Schedule = Database.query(query);
        
        Boolean proceed = false;
        
        String[] sd = start_date_temp.split(':');
        String[] ed = end_date_temp.split(':');
        Date mysDate = Date.newInstance(integer.valueOf(sd[0]), integer.valueOf(sd[1]), integer.valueOf(sd[2]));
        Time mysTime = Time.newInstance(integer.valueOf(sd[3]), integer.valueOf(sd[4]), integer.valueOf(sd[5]), 0);
        DateTime mysd = DateTime.newInstance(mysDate, mysTime);
        
        Date myeDate = Date.newInstance(integer.valueOf(ed[0]), integer.valueOf(ed[1]), integer.valueOf(ed[2]));
        Time myeTime = Time.newInstance(integer.valueOf(ed[3]), integer.valueOf(ed[4]), integer.valueOf(ed[5]), 0);
        DateTime myed = DateTime.newInstance(myeDate, myeTime);
        
        if(progress != Null && progress != '' && Schedule.Progress__c != Decimal.valueof(progress)) { 
            proceed = true;
            Schedule.Progress__c = Decimal.valueof(progress); 
        }
        if(mysd != Schedule.Schedule_Start_Date__c || myed != Schedule.Schedule_End_Date__c ){
            proceed = true;
            Schedule.Schedule_Start_Date__c = mysd;
            Schedule.Schedule_End_Date__c = myed;
        }
            if(proceed && Schema.sObjectType.Schedule__c.isCreateable()&& Schema.sObjectType.Schedule__c.isUpdateable()) { DMLManager.upsertAsUser(Schedule); } else { /* not allowed */ }
         return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
        }
    }
    
    public PageReference deleteSchedule() {
        String deleteScheduleId = jString;
        if(deleteScheduleId != Null && deleteScheduleId != ''){
            List<Schedule__c> delSchedule;
            if(Schema.sObjectType.Schedule__c.isAccessible())
            delSchedule = [Select id, Name, Schedule__c From Schedule__c where id = :deleteScheduleId or Schedule__c = :deleteScheduleId];
            if (Schema.sObjectType.Schedule__c.isDeletable()) { DMLManager.deleteAsUser(delSchedule); } else{ /* not alloweed */ }
        }
        return null;
    }
    
    public PageReference reLoad() {
        FetchSchedulesAndCycles();
        return null;
    }
    
    public PageReference FetchSchedules(){
        schemaMap = Schema.getGlobalDescribe();
        String allFields = fetchAllFields('ERP7__Schedule__c');
        utilClass.FLSCheck(allFields.split(','),'ERP7__Schedule__c');
        String searchStringVal = '%'+searchString+'%';
        String workOrderSrcVal = '%'+workOrderSrc+'%';
        String workStationSrcVal = '%'+workStationSrc+'%';
        String globalsrc = '%'+globalsearch+'%';
        allFields += ',Work_Order_Line_Item__r.Name, Work_Order__r.Project__r.Name, Work_Order__r.Project__c, Project__r.Name, Process__r.Name, Work_Order__r.Name, Product__r.Name, Work_Center_Assignment__r.Work_Center__c, Work_Center_Assignment__r.Work_Center__r.Name, Process_Cycle__r.Name, RecordType.Name, Schedule__r.Name, Work_Center__r.Name,Work_Center_Assignment__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c';
        String query;
        DateTime nowTime = System.Now();
        query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Schedule__c where (Work_Order__r.Name like : globalsrc or Product__r.Name like : globalsrc or Name like : globalsrc or Process__r.Name like : globalsrc) and Schedule_End_Date__c > :nowTime order by CreatedDate asc ';
        if (Schema.sObjectType.Schedule__c.isAccessible())
        Schedules = Database.query(query);
       
        for(Schedule__c s : Schedules){
            mapSchedules.put(s.Id,s);
        }
        
        return Null;
    }
    
    public PageReference ManageResources(){
        return Page.ManageSchedulesChecklists;
    }
    
    public PageReference scheduleResources(){
        scheduleId = jString;
        PageReference page = new pageReference('/apex/ScheduleResourceAllocation');
        page.getparameters().put('id',scheduleId);
        return Page;
    }
    
    public PageReference scheduleChecklists(){
        scheduleId = jString;
        PageReference page = new pageReference('/apex/ScheduleCheckLists');
        page.getparameters().put('id',scheduleId);
        return Page;
    }
    
    public PageReference scheduleCheckList(){
        scheduleId = jString;
        PageReference page = new pageReference('/apex/scheduleCheckLists');
        page.getparameters().put('id',scheduleId);
        return Page;
    }
    
    public PageReference SearchEmployees(){
        schemaMap = Schema.getGlobalDescribe();
        String searchStringall = '%'+searchString+'%';
        String allFields1 = fetchAllFields('ERP7__Employees__c');
        utilClass.FLSCheck(allFields1.split(','),'ERP7__Employees__c');
        allFields1 += ', ReportingManager__r.Name, Employee_Profiling__r.Name';
        String query1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__Employees__c where Active__c = true And (Name like : searchStringall or Job_Title__c like : searchStringall or ReportingManager__r.Name like : searchStringall or Employee_Profiling__r.Name like : searchStringall or Email__c like : searchStringall) Limit 1000';
        List<ERP7__Employees__c> Employees;
        if(Schema.sObjectType.Employees__c.isAccessible())
        Employees = Database.query(query1);
        AvailableEmployeeList = new List<Employee>();
        //skills maps
           
        String allFieldsk = fetchAllFields('ERP7__Employee_Skill__c');
        utilClass.FLSCheck(allFieldsk.split(','),'ERP7__Employee_Skill__c');
        allFieldsk += ',ERP7__Skill__r.Name, ERP7__Skill__r.Skill_Name__c ';
        String querysk = 'select ' + String.escapeSingleQuotes(allFieldsk) + ' from ERP7__Employee_Skill__c where ERP7__Employee__c in :Employees and ERP7__Skill__c != Null';
        List<ERP7__Employee_Skill__c> EmployeeSkills ;
        if(Schema.sObjectType.Employee_Skill__c.isAccessible())
        EmployeeSkills = Database.query(querysk);
        
        for(ERP7__Employees__c emp : Employees){
            String skills = '';
            for(Integer i=0; i<EmployeeSkills.size(); i++){
                if(emp.Id == EmployeeSkills[i].Employee__c){
                    skills += (i==EmployeeSkills.size()-1)? EmployeeSkills[0].ERP7__Skill__r.Skill_Name__c : (EmployeeSkills[0].ERP7__Skill__r.Skill_Name__c+', ');
                    
                }
            }
            Employee e = new Employee();
            e.Id = emp.Id;
            e.Name = emp.Name;
            e.Employee = emp;
            e.Skills = skills;
            AvailableEmployeeList.add(e);
        }
        return Null;
    }
    
    public PageReference SearchMachines(){
        schemaMap = Schema.getGlobalDescribe();
        String searchStringall = '%'+searchMachString+'%';
        DateTime ssd = selSchedule.ERP7__Schedule_Start_Date__c;
        Date ssdd = date.newinstance(ssd.year(), ssd.month(), ssd.day());
        String allFieldsm = fetchAllFields('ERP7__Machine__c');
        utilClass.FLSCheck(allFieldsm.split(','),'ERP7__Machine__c');
        String querym = 'select ' + String.escapeSingleQuotes(allFieldsm) + ' from ERP7__Machine__c where ERP7__Activation_Date__c < :ssdd And (Name like : searchStringall) Limit 1000';
        List<ERP7__Machine__c> Machines;
        if(Schema.sObjectType.Machine__c.isAccessible())
        Machines = Database.query(querym);
        AvailableMachineList = new List<Machine>();
        for(Machine__c mach : Machines){
            Machine e = new Machine();
            e.Id = mach.Id;
            e.Name = mach.Name;
            e.Machine = mach;
            AvailableMachineList.add(e);
        }
        return Null;
    }
    
    public PageReference WorkforceResources(){
        FetchSchedules();
        ResourceAllocation = new List<Resource_Allocation__c >();
        ResourceAllocations = new List<ResourceAllocation>();
        scheduleId = apexpages.currentpage().getparameters().get('id');
        selSchedule = mapSchedules.get(scheduleId);
        selSchedules = new List<Schedule__c>();
        selSchedules.add(selSchedule);
        if(scheduleId != '' && scheduleId != null){
            AvailableEmployeeList = new List<Employee>();
            AllocatedEmployeeList = new List<Employee>();
            EmployeeList = new List<Employee>();
            AvailableMachineList = new List<Machine>();
            AllocatedMachineList = new List<Machine>();
            MachineList = new List<Machine>();
            schemaMap = Schema.getGlobalDescribe();
            
            String allFields = fetchAllFields('ERP7__Resource_Allocation__c');
            utilClass.FLSCheck(allFields.split(','),'ERP7__Resource_Allocation__c');
            allFields += ', Employees__r.Name ';
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Resource_Allocation__c where Schedule__c =: scheduleId and Employees__c != null order by CreatedDate asc ';
            if(Schema.sObjectType.Resource_Allocation__c.isAccessible())
            workForceAllocations = Database.query(query);
            
            for(Resource_Allocation__c RA : workForceAllocations){
                ResourceAllocation.add(RA);
                ResourceAllocation resAlloc = new ResourceAllocation();
                resAlloc.RA = RA;
                ResourceAllocations.add(resAlloc);
                
            }
            
            String allFields1 = fetchAllFields('ERP7__Employees__c');
            utilClass.FLSCheck(allFields1.split(','),'ERP7__Employees__c');
            allFields1 += ', ReportingManager__r.Name, Employee_Profiling__r.Name';
            String query1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__Employees__c where Active__c = true Limit 1000';
            List<ERP7__Employees__c> Employees;
            if(Schema.sObjectType.Employees__c.isAccessible())
            Employees = Database.query(query1);
            List<Id> emplId = new List<Id>();
            
            //skills maps
           
            String allFieldsk = fetchAllFields('ERP7__Employee_Skill__c');
            utilClass.FLSCheck(allFieldsk.split(','),'ERP7__Employee_Skill__c');
            allFieldsk += ',ERP7__Skill__r.Name, ERP7__Skill__r.Skill_Name__c ';
            String querysk = 'select ' + String.escapeSingleQuotes(allFieldsk) + ' from ERP7__Employee_Skill__c where ERP7__Employee__c in :Employees and ERP7__Skill__c != Null';
            List<ERP7__Employee_Skill__c> EmployeeSkills;
            if(Schema.sObjectType.Employee_Skill__c.isAccessible())
            EmployeeSkills = Database.query(querysk);
            
            for(ERP7__Employees__c emp : Employees){
                String skills = '';
                for(Integer i=0; i<EmployeeSkills.size(); i++){
                    if(emp.Id == EmployeeSkills[i].Employee__c){
                        skills += (i==EmployeeSkills.size()-1)? EmployeeSkills[0].ERP7__Skill__r.Skill_Name__c : (EmployeeSkills[0].ERP7__Skill__r.Skill_Name__c+', ');
                    }
                }
                Employee e = new Employee();
                e.Id = emp.Id;
                e.Name = emp.Name;
                e.Employee = emp;
                e.Skills = skills;
                AvailableEmployeeList.add(e);
            }
            
            
            DateTime ssd = selSchedule.ERP7__Schedule_Start_Date__c;
            Date ssdd = date.newinstance(ssd.year(), ssd.month(), ssd.day());
            String allFieldsma = fetchAllFields('ERP7__Resource_Allocation__c');
            utilClass.FLSCheck(allFieldsma.split(','),'ERP7__Resource_Allocation__c');
            allFieldsma += ', ERP7__Machine__r.Name ';
            String queryma = 'select ' + String.escapeSingleQuotes(allFieldsma) + ' from ERP7__Resource_Allocation__c where Schedule__c =: scheduleId and Machine__c != null order by CreatedDate asc ';
            if(Schema.sObjectType.Resource_Allocation__c.isAccessible())
            machineAllocs = Database.query(queryma);
            
            String allFieldsm = fetchAllFields('ERP7__Machine__c');
            utilClass.FLSCheck(allFieldsm.split(','),'ERP7__Machine__c');
            String querym = 'select ' + String.escapeSingleQuotes(allFieldsm) + ' from ERP7__Machine__c where ERP7__Activation_Date__c < :ssdd Limit 1000';
            List<ERP7__Machine__c> Machines;
            if(Schema.sObjectType.Machine__c.isAccessible())
            Machines= Database.query(querym);
            
            
           
            String allFields4 = fetchAllFields('ERP7__Resource_Allocation__c');
            utilClass.FLSCheck(allFields4.split(','),'ERP7__Resource_Allocation__c');
            allFields4 += ', Machine__r.Name ';
            String query4 = 'select ' + String.escapeSingleQuotes(allFields) + ' from Resource_Allocation__c where Machine__c In : Machines and Start_Date__c != null and End_Date__c != null order by CreatedDate asc ';
            List<ERP7__Resource_Allocation__c> allMachineAllocations;
                if(Schema.sObjectType.Resource_Allocation__c.isAccessible())
            allMachineAllocations= Database.query(query4);
            
            for(Resource_Allocation__c RA : machineAllocs){
                ResourceAllocation.add(RA);
                ResourceAllocation resAlloc = new ResourceAllocation();
                resAlloc.RA = RA;
                ResourceAllocations.add(resAlloc);
            }
           
            for(Machine__c mach : Machines){
                Machine e = new Machine();
                e.Id = mach.Id;
                e.Name = mach.Name;
                e.Machine = mach;
                AvailableMachineList.add(e);
            }
            
            
        }
        return null;
    }
    
    public PageReference BuildSchedule(){
        ManageCheckLists();
        WorkforceResources();
        return Null;
    }
    
    
    public PageReference ManageCheckLists(){
        FetchSchedulesAndCycles();
        scheduleId = apexpages.currentpage().getparameters().get('id');
        selSchedule = mapSchedules.get(scheduleId);
        ScheduleChecklist2Del = new List<Actions_Tasks__c>();
        ScheduleMRPs2Del = new List<MRP__c>();
        selSchedule = mapSchedules.get(scheduleId);
        selSchedules = new List<Schedule__c>();
        selSchedules.add(selSchedule);
        if(scheduleId != '' && scheduleId != null){
            schemaMap = Schema.getGlobalDescribe();
            
            String allFields = fetchAllFields('ERP7__Actions_Tasks__c');
            utilClass.FLSCheck(allFields.split(','),'ERP7__Actions_Tasks__c');
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from Actions_Tasks__c where Schedule__c =: scheduleId order by CreatedDate asc ';
            if(Schema.sObjectType.Actions_Tasks__c.isAccessible())
            ScheduleChecklist = Database.query(query);
            
            if(Schema.sObjectType.MRP__c.isAccessible())
            ScheduleMRPs = [Select Id, Name, Amount_Required__c, BOM__c, Bill_Of_Material_Product__c, BOM_Actual_Cost__c, BOM_Requirement_Cost__c, 
                                Check_Out_Process__c, Fulfilled_Amount__c, Process_Cycle__c, Process__c,  
                                Maximum_Hold_days__c, Notes__c, MRP_Product__c, Production_Cycle__c, Total_Amount_Required__c, 
                                Requested_Requirement_Date__c, Site__c, Request_Fulfilled_Date__c, Sourced_Site__c, Status__c, Schedule__c
                                From MRP__c
                                Where Schedule__c =: scheduleId order by CreatedDate asc];
            
           
        }
        return null;
    }
    
    public PageReference addMRP(){
        MRP__c mrp = new MRP__c();
            mrp.Process__c = selSchedule.Process__c;
            mrp.MRP_Product__c = selSchedule.Product__c;
            mrp.Schedule__c = selSchedule.Id;
            mrp.Process_Cycle__c = selSchedule.Process_Cycle__c; 
        ScheduleMRPs.add(mrp);
        return null;
    }
    
    public PageReference RemoveMRP(){
        MRP__c WR2Delete = ScheduleMRPs.remove(counter);
        if(WR2Delete.Id != Null) ScheduleMRPs2Del.add(WR2Delete);
        return null;
    }
    
    public PageReference SaveMRPs(){
        try{  if (Schema.sObjectType.MRP__c.isDeletable()) { DMLManager.deleteAsUser(ScheduleMRPs2Del);} else{ /* no access*/ } } catch(exception e){}
        try{  if(Schema.sObjectType.MRP__c.isCreateable()&& Schema.sObjectType.MRP__c.isUpdateable())  { DMLManager.upsertAsUser(ScheduleMRPs);} else{ /* not allowed */ } } catch(exception e){}
        ManageCheckLists();
        return null;
    }
    
    public PageReference addChecklist(){
        ScheduleChecklist.add(new Actions_Tasks__c(Schedule__c=selSchedule.Id));
        return null;
    }
    
    public PageReference RemoveChecklist(){
        Actions_Tasks__c WR2Delete = ScheduleChecklist.remove(counter);
        if(WR2Delete.Id != Null) ScheduleChecklist2Del.add(WR2Delete);
        return null;
    }
    
    public PageReference SaveCheckLists(){
        if(ScheduleChecklist2Del.size() > 0 && Schema.sObjectType.Actions_Tasks__c.isDeletable()) { DMLManager.deleteAsUser(ScheduleChecklist2Del); } else{ /* no access*/ }
        if(ScheduleChecklist.size() > 0 && Schema.sObjectType.Actions_Tasks__c.isCreateable()&& Schema.sObjectType.Actions_Tasks__c.isUpdateable()) { DMLManager.upsertAsuser(ScheduleChecklist); } else { /*no access*/ }
        ManageCheckLists();
        return null;
    }
    
    
    public PageReference AddWorkForceAllocation(){
        workForceAllocations.add(new Resource_Allocation__c(Schedule__c=selSchedule.Id));
        return null;
    }
    
    public PageReference RemoveWorkForceAllocation(){
        Resource_Allocation__c WR2Delete = workForceAllocations.remove(counter);
        if(WR2Delete.Id != Null) workForceAllocations2Del.add(WR2Delete);
        return null;
    }
    
    @RemoteAction
    global static List<Employees__c> searchEmps(String searchString) {
        if(Schema.sObjectType.Employees__c.isAccessible()){
        List<Employees__c> emps = Database.query('Select Id, Name from Employees__c where name like \'%' + String.escapeSingleQuotes(searchString) + '%\'');
        return emps;
        }
        return null;
    }
    
    public PageReference Back2ManageSchedulesResources(){
        return null;
    }
    
    public PageReference Back2ManageSchedulesChecklists(){
        PageReference pag = new pageReference('/'+selSchedule.Id);
        pag.setredirect(true);
        String detail = apexpages.currentpage().getparameters().get('detail');
        if(detail == 'true') return pag;
        else return Page.ManageSchedulesChecklists;
    }
    
    public PageReference Back2Scheduler(){
        return Page.Scheduler;
    }
    
    public String fetchAllFields(String sObj){
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObj).getDescribe().fields.getMap();
        String allFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(allFields == null || allFields == ''){
                allFields = fieldName;
            }else{
                allFields = allFields + ', ' + fieldName;
            }
        }
        return allFields;
    }
    
    public class schedulesPack {
        public List<data> data               { get; set; }
        public List<links> links             { get; set; }
        
        public schedulesPack(List<data> dataList_s, List<links> linksList_s){
            data = dataList_s;
            links = linksList_s;
        }
    }
    
    public class data {
    
        public String text                   { get; set; }
        
        public String id                     { get; set; }
        public String scheduleName           { get; set; }
        
        public String workStation            { get; set; }
        public String wsId                   { get; set; }
        
        public String lineitem               { get; set; }
        public String lineId                 { get; set; }
        
        public String Processes              { get; set; }
        public String processId              { get; set; }
        
        public String WorkOrder              { get; set; }
        public String woId                   { get; set; }
        
        public String productservice         { get; set; }
        public String productId              { get; set; }
        
        public String parent                 { get; set; }
        public String schedule               { get; set; }
        
        public String cycle                  { get; set; }
        public String cycleId                { get; set; }
        
        public String status                 { get; set; }
        public String scheduleType           { get; set; }
        public String start_date             { get; set; }
        public Decimal progress              { get; set; }
        public Boolean open                  { get; set; }
        public Integer duration              { get; set; }
        public String end_date               { get; set; }
        public Boolean isNew                 { get; set; }
        public String start_date_temp        { get; set; }
        public String end_date_temp          { get; set; }
        public String leadTime               { get; set; }
    }
    
    public class links {
        public String id                     { get; set; }
        public String source                 { get; set; }
        public String target                 { get; set; }
        public String type                   { get; set; }
    }
    
    public class Employee {
        public String Id                     { get; set; }
        public String Name                   { get; set; }
        public Boolean Selected              { get; set; }
        public Employees__c Employee         { get; set; }
        public String Skills                 { get; set; }
        
        public Employee(){
            Name = Skills = '';
            Selected = false;
        }
    }
    
     public class Machine {
        public String Id                     { get; set; }
        public String Name                   { get; set; }
        public Boolean Selected              { get; set; }
        public Machine__c Machine            { get; set; }
        
        public Machine(){
            Id = '';
            Name = '';
            Selected = false;
        }
    }
    
    public class ResourceAllocation{
        public Boolean Selected              { get; set; }
        public Resource_Allocation__c RA     { get; set; }
        public String errMsg                 { get; set; }
        public Boolean Error                 { get; set; }
        
        public ResourceAllocation(){
            errMsg = '';
            Selected = Error = false;
        }
    }
    
    public class scheduleWrapper{
        public Schedule__c schedule                            { get; set; }
        public List<Schedule__c> subSchedules                  { get; set; }
        public List<cycleWrapper> cycleWrapperList             { get; set; }
        
        public scheduleWrapper(){
        }
    }
    
    public class cycleWrapper{
        public Schedule__c schedule                            { get; set; }
        public Process_Cycle__c cycle                          { get; set; }
        
        public cycleWrapper(){
        }
    }
    
    public class processWrapper{
        public Process__c process                              { get; set; }
        public List<Process_Cycle__c> processCycles            { get; set; }
        public List<scheduleWrapper> processSchedules          { get; set; }
        public processWrapper(){
        }
    }
    
}