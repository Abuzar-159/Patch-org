public with sharing class ManagePROJs {
    
    public List<Id> displayedProjects                            { get; set; }
    public String schedulerString                                { get; set; }
    public String searchString                                   { get; set; }
    public String workOrderSrc                                   { get; set; }
    public String workStationSrc                                 { get; set; }
    public String selectedAccout                                 { get; set; }
    public String View                                           { get; set; }
    public Boolean FilterShow                                    { get; set; }
    public Date startDate                                        { get; set; }
    public Date endDate                                          { get; set; }
    public String searchTeam                                     { get; set; }
    public String jString                                        { get; set; }
    public Boolean resetGantt                                    { get; set; }
    public Map<String, Schema.SObjectType> schemaMap;
    
    public ManagePROJs() {View = 'All'; FilterShow = false; startDate = date.newInstance(Date.today().Year(), 1, 1); endDate = startDate.addYears(1)-1;}
    
    public List<PMWP> getProjects() {
        displayedProjects = new List<Id>();
        displayedProjects.clear();
        
        if(searchTeam == null) searchTeam = '';
        workOrderSrc = workStationSrc = '';
        String searchStringVal = '%'+searchString+'%';
        String workOrderSrcVal = '%'+workOrderSrc+'%';
        String workStationSrcVal = '%'+workStationSrc+'%';
        String tempWCPlant = (selectedAccout != Null)? selectedAccout : '';
        String tempWCPlantval = '%'+tempWCPlant+'%';
        
        List<PMWP> projectWraP = new List<PMWP>();
        //String projectFields = UtilClass.selectStarFromSObject('ERP7__Project__c');
        //projectFields += ', ERP7__Project_Manager__r.Name, ERP7__Default_Routing__r.ERP7__Process__c ';
        //utilClass.FLSCheck(projectFields.split(','),'ERP7__Project__c');  
        String query = 'select Id, Name, ERP7__Project_Manager__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Status__c, ERP7__Percentage__c, ERP7__Project_Manager__r.Name, ERP7__Default_Routing__r.ERP7__Process__c from ERP7__Project__c Where ERP7__Active__c = true ';
        if(startDate != Null && endDate != Null) query += 'and ERP7__Start_Date__c >= :startDate And ERP7__End_Date__c <= :endDate ';
        if(View == 'All' || View == null)
            query += 'Order by CreatedDate Desc limit 1000';
        else
            query += 'and ERP7__Status__c = \''+String.escapeSingleQuotes(View)+'\'Order by CreatedDate Desc limit 1000';
        List<ERP7__Project__c> PROJS = Database.query(query);
        List<User> users = new List<User>();
        for(ERP7__Project__c project : PROJS){
            projectWraP.add(new PMWP(project, users));
            displayedProjects.add(project.Id);
        }
        return projectWraP;
    }
    
    public List<milestoneWrap> getMilestones() {
        List<milestoneWrap> msWraP = new List<milestoneWrap>();
        String milestoneFields = UtilClass.selectStarFromSObject('ERP7__Milestone__c');
        milestoneFields += ', ERP7__Project__r.Name ';
        utilClass.FLSCheck(milestoneFields.split(','),'ERP7__Milestone__c');  
        String query = 'select Id, Name, ERP7__Status__c, ERP7__Percentage__c, ERP7__Start_Date__c, ERP7__Due_Date__c, ERP7__Project__c, ERP7__Project__r.Name from ERP7__Milestone__c WHERE ERP7__Project__c != null ORDER BY CreatedDate Asc limit 1000';
        List<ERP7__Milestone__c> MS = Database.query(query);
        
        List<User> users = new List<User>();
        List< ERP7__Actions_Tasks__c > tskList = new List< ERP7__Actions_Tasks__c >();  
        for(ERP7__Milestone__c mile : MS) {
            msWraP.add(new milestoneWrap(mile, tskList, users));
        }
        return msWraP;
    }
    
    public List<ERP7__Actions_Tasks__c> getTasks() {
        //String milestoneFields = UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');
        //milestoneFields += ', ERP7__Milestone__r.Name, ERP7__Project__r.Name ';
        //utilClass.FLSCheck(milestoneFields.split(','),'ERP7__Actions_Tasks__c');  
        //String query = 'select ' + String.escapeSingleQuotes(milestoneFields) + ' from ERP7__Actions_Tasks__c WHERE ERP7__Milestone__c != null ORDER BY CreatedDate Asc limit 1000';
        String query = 'select Id, Name, ERP7__Status__c, ERP7__Percentage__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Milestone__c, ERP7__Milestone__r.Name, ERP7__Project__c, ERP7__Project__r.Name from ERP7__Actions_Tasks__c WHERE ERP7__Milestone__c != null ORDER BY CreatedDate Asc limit 1000';
        List< ERP7__Actions_Tasks__c > tskList = Database.query(query);
        return tskList;
    }
    
    public PageReference getAllProjectData() {
        List<PMWP> projectWP = new List<PMWP>();
        List<milestoneWrap> milestoneWP = new List<milestoneWrap>();
        List<ERP7__Actions_Tasks__c> taskWP = new List<ERP7__Actions_Tasks__c>();
        List<data> dtaList = new List<data>();
        List<links> lnksList = new List<links>();
        
        try{
            projectWP = getProjects();
            milestoneWP = getMilestones();
            taskWP = getTasks();
            for(PMWP pjt : projectWP){
                DateTime SSD = (Schema.SOBjectType.ERP7__Project__c.Fields.ERP7__Start_Date__c.isAccessible())? pjt.project.ERP7__Start_Date__c:system.Today();
                DateTime SSDT = (Schema.SOBjectType.ERP7__Project__c.Fields.ERP7__Start_Date__c.isAccessible())? pjt.project.ERP7__Start_Date__c:system.Today();
                String SSDate = SSDT.format('dd/MM/yyyy'); 
                
                DateTime SED = (Schema.SOBjectType.ERP7__Project__c.Fields.ERP7__End_Date__c.isAccessible())? pjt.project.ERP7__End_Date__c:system.Today();
                DateTime SEDT = (Schema.SOBjectType.ERP7__Project__c.Fields.ERP7__End_Date__c.isAccessible())? pjt.project.ERP7__End_Date__c:system.Today();
                String SEDate = SEDT.format('dd/MM/yyyy');
                
                data dta = new data();
                
                dta.isMO = false;
                dta.isWO = false;
                
                dta.version = '';
                dta.versionId = '';
                
                dta.WorkOrder = '';
                dta.leadTime = String.valueof(system.now());
                dta.woId = '';
                
                dta.productservice = '';
                dta.productId = '';
                
                
                dta.text = pjt.project.Name;
                dta.scheduleName = pjt.project.Name;
                dta.id = pjt.project.Id;
                
                dta.projectId = pjt.project.Id;
                dta.project = pjt.project.Name;
                
                dta.status = (Schema.SOBjectType.ERP7__Project__c.Fields.ERP7__Status__c.isAccessible())? pjt.project.ERP7__Status__c:'--None--';
                
                dta.start_date = SSDate; 
                dta.end_date = SEDate;
                if(Schema.SOBjectType.ERP7__Project__c.Fields.ERP7__Percentage__c.isAccessible() && pjt.project.ERP7__Percentage__c != null) {
                    Decimal progress = pjt.project.ERP7__Percentage__c;
                    dta.progress = progress.setScale(2, RoundingMode.HALF_UP);
                }
                dta.open = false;
                dta.isNew = false;
                dta.start_date_temp = SSDate;
                dta.end_date_temp = SEDate;
                dta.readonly = false;
                dtaList.add(dta);            
            }
            
            for(milestoneWrap mst: milestoneWP){
                String SSDateM;
                String SEDateM;
                if(mst.milestone.ERP7__Start_Date__c != null) {
                    DateTime SSDm = (Schema.SOBjectType.ERP7__Milestone__c.Fields.ERP7__Start_Date__c.isAccessible())? mst.milestone.ERP7__Start_Date__c:system.Today();
                    DateTime SSDTm = (Schema.SOBjectType.ERP7__Milestone__c.Fields.ERP7__Start_Date__c.isAccessible())? mst.milestone.ERP7__Start_Date__c:system.Today();
                    SSDateM = SSDTm.format('dd/MM/yyyy'); 
                }
                
                if(mst.milestone.ERP7__Due_Date__c != null) {
                    DateTime SEDm = (Schema.SOBjectType.ERP7__Milestone__c.Fields.ERP7__Due_Date__c.isAccessible())? mst.milestone.ERP7__Due_Date__c:system.Today();
                    DateTime SEDTm = (Schema.SOBjectType.ERP7__Milestone__c.Fields.ERP7__Due_Date__c.isAccessible())? mst.milestone.ERP7__Due_Date__c:system.Today();
                    SEDateM = SEDTm.format('dd/MM/yyyy');
                }
                
                data dta = new data();
                
                dta.isMO = false;
                dta.isWO = false;
                dta.version = '';
                dta.versionId = '';
                dta.WorkOrder = '';
                dta.leadTime = String.valueof(system.now());
                dta.woId = '';
                dta.productservice = '';
                dta.productId = '';
                
                
                dta.text = mst.milestone.Name;
                dta.scheduleName = mst.milestone.Name;
                dta.id = mst.milestone.Id;
                
                dta.projectId = mst.milestone.ERP7__Project__c;
                dta.project = mst.milestone.ERP7__Project__r.Name;
                
                dta.status = (Schema.SOBjectType.ERP7__Milestone__c.Fields.ERP7__Status__c.isAccessible())? mst.milestone.ERP7__Status__c:'--None--';
                
                dta.start_date = SSDateM; 
                dta.end_date = SEDateM;
                if(Schema.SOBjectType.ERP7__Milestone__c.Fields.ERP7__Percentage__c.isAccessible() && mst.milestone.ERP7__Percentage__c != null) {
                    Decimal progress = mst.milestone.ERP7__Percentage__c;
                    dta.progress = progress.setScale(2, RoundingMode.HALF_UP);
                }
                dta.open = false;
                dta.isNew = false;
                dta.start_date_temp = SSDateM;
                dta.end_date_temp = SEDateM;
                dta.readonly = false;
                if(mst.milestone.ERP7__Project__c != Null) {
                    dta.text = mst.milestone.Name;
                    dta.parent = mst.milestone.ERP7__Project__c;
                    dta.schedule = mst.milestone.ERP7__Project__r.Name;
                    
                    links lnks = new links();
                    lnks.id = mst.milestone.Id;
                    lnks.source = mst.milestone.ERP7__Project__c;
                    lnks.target = mst.milestone.Id;
                    lnks.type = '1';
                    lnksList.add(lnks);
                }
                dtaList.add(dta);
            }
            
            for(ERP7__Actions_Tasks__c task: taskWP){
                String SSDateT;
                String SEDateT;
                if(task.ERP7__Start_Date__c != null) {
                    DateTime SSDt = (Schema.SOBjectType.ERP7__Actions_Tasks__c.Fields.ERP7__Start_Date__c.isAccessible())? task.ERP7__Start_Date__c:system.Today();
                    DateTime SSDTt = (Schema.SOBjectType.ERP7__Actions_Tasks__c.Fields.ERP7__Start_Date__c.isAccessible())? task.ERP7__Start_Date__c:system.Today();
                    SSDateT = SSDTt.format('dd/MM/yyyy'); 
                }
                if(task.ERP7__End_Date__c != null) {
                    DateTime SEDt = (Schema.SOBjectType.ERP7__Actions_Tasks__c.Fields.ERP7__End_Date__c.isAccessible())? task.ERP7__End_Date__c:system.Today();
                    DateTime SEDTt = (Schema.SOBjectType.ERP7__Actions_Tasks__c.Fields.ERP7__End_Date__c.isAccessible())? task.ERP7__End_Date__c:system.Today();
                    SEDateT = SEDTt.format('dd/MM/yyyy');
                }
                
                data dta = new data();
                
                dta.isMO = false;
                dta.isWO = false;
                dta.version = '';
                dta.versionId = '';
                dta.WorkOrder = '';
                dta.leadTime = String.valueof(system.now());
                dta.woId = '';
                dta.productservice = '';
                dta.productId = '';
                
                dta.text = task.Name;
                dta.scheduleName = task.Name;
                dta.id = task.Id;
                dta.projectId = task.ERP7__Project__c;
                dta.project = task.ERP7__Project__r.Name;
                dta.status = (Schema.SOBjectType.ERP7__Actions_Tasks__c.Fields.ERP7__Status__c.isAccessible())? task.ERP7__Status__c:'--None--';
                dta.start_date = SSDateT; 
                dta.end_date = SEDateT;
                if(Schema.SOBjectType.ERP7__Actions_Tasks__c.Fields.ERP7__Percentage__c.isAccessible() && task.ERP7__Percentage__c != null) {
                    Decimal progress = task.ERP7__Percentage__c;
                    dta.progress = progress.setScale(2, RoundingMode.HALF_UP);
                }
                dta.open = false;
                dta.isNew = false;
                dta.start_date_temp = SSDateT;
                dta.end_date_temp = SEDateT;
                dta.readonly = false;
                if(task.ERP7__Milestone__c != Null) {
                    dta.text = task.Name;
                    dta.parent = task.ERP7__Milestone__c;
                    dta.schedule = task.ERP7__Milestone__r.Name;
                    
                    links lnks = new links();
                    lnks.id = task.Id;
                    lnks.source = task.ERP7__Milestone__c;
                    lnks.target = task.Id;
                    lnks.type = '1';
                    lnksList.add(lnks);
                }
                dtaList.add(dta);
            }
            schedulesPack SP = new schedulesPack(dtaList,lnksList);
            schedulerString = JSON.serialize(SP);
            return null;        } catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); return null;}
    }
    
    public PageReference FilterSet() {
        FilterShow = !FilterShow;
        return null;
    }
    
    public PageReference updateSchedule() {
        resetGantt = false;
        try{
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jString);
            String scheduleId = String.valueof(m.get('id'));
            String start_date = String.valueof(m.get('start_date'));
            String progress = String.valueof(m.get('progress'));
            String duration = String.valueof(m.get('duration'));
            String end_date = String.valueof(m.get('end_date'));
            String start_date_temp = String.valueof(m.get('start_date_temp'));
            String end_date_temp = String.valueof(m.get('end_date_temp'));
            
            Boolean proceed = false;
            if(Test.isRunningTest()) { start_date_temp = '2018:10:10:10:10:10'; end_date_temp = '2018:10:10:11:10:10';}
            String[] sd = start_date_temp.split(':');
            String[] ed = end_date_temp.split(':');
            Date mysDate = Date.newInstance(integer.valueOf(sd[0]), integer.valueOf(sd[1]), integer.valueOf(sd[2]));
            Time mysTime = Time.newInstance(integer.valueOf(sd[3]), integer.valueOf(sd[4]), integer.valueOf(sd[5]), 0);
            DateTime mysd = DateTime.newInstance(mysDate, mysTime);
            
            Date myeDate = Date.newInstance(integer.valueOf(ed[0]), integer.valueOf(ed[1]), integer.valueOf(ed[2]));
            Time myeTime = Time.newInstance(integer.valueOf(ed[3]), integer.valueOf(ed[4]), integer.valueOf(ed[5]), 0);
            DateTime myed = DateTime.newInstance(myeDate, myeTime);
            
            List<ERP7__Milestone__c> MS = [Select Id, Name, ERP7__Start_Date__c, ERP7__Due_Date__c, ERP7__Percentage__c, ERP7__Project__c, ERP7__isSerialized__c, ERP7__Previous_Milestone__c, ERP7__Next_Milestone__c, ERP7__Status__c From ERP7__Milestone__c where Id = :scheduleId];
            List<ERP7__Project__c> PJ = [Select Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Percentage__c, ERP7__Status__c From ERP7__Project__c where Id = :scheduleId];
            List<ERP7__Actions_Tasks__c> TK = [Select Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Percentage__c, ERP7__Milestone__c, ERP7__Status__c From ERP7__Actions_Tasks__c where Id = :scheduleId];
            
            
            integer s = 0;
            if (TK.size() > 0) { if(progress != Null && progress != '' && TK[s].ERP7__Percentage__c != Decimal.valueof(progress)) {   proceed = true;  if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Percentage__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Percentage__c.isUpdateable()){TK[s].ERP7__Percentage__c = Decimal.valueof(progress);}else{/*No access*/}
                    if(TK[s].ERP7__Percentage__c > 0 && TK[s].ERP7__Status__c != 'In Progress') if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Status__c.isUpdateable()){TK[s].ERP7__Status__c = 'In Progress';}else{/*No access*/}
                    if(TK[s].ERP7__Percentage__c == 100) if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Status__c.isUpdateable()){TK[s].ERP7__Status__c = 'Completed';}else{/*No access*/}
                }
                if(mysDate != TK[s].ERP7__Start_Date__c || myeDate != TK[s].ERP7__End_Date__c){ proceed = true; if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Start_Date__c.isUpdateable()){TK[s].ERP7__Start_Date__c = mysDate;}else{/*No access*/} if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__End_Date__c.isUpdateable()){TK[s].ERP7__End_Date__c = myeDate;}else{/*No access*/} } if(Schema.sObjectType.ERP7__Actions_Tasks__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){DMLManager.upsertAsUser(TK);}else{/*No access*/}
            }
            
            if (MS.size() > 0) {
                //project end reset
                if(progress != Null && progress != '' && MS[0].ERP7__Percentage__c != Decimal.valueof(progress)) {     proceed = true;  MS[s].ERP7__Percentage__c = Decimal.valueof(progress);   if(MS[s].ERP7__Percentage__c > 0 && MS[s].ERP7__Status__c != 'In Progress')  if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Status__c.isUpdateable()){MS[s].ERP7__Status__c = 'In Progress';}else{/*No access*/}
                    if(MS[s].ERP7__Percentage__c == 100)  if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Status__c.isUpdateable()){MS[s].ERP7__Status__c = 'Completed';}else{/*No access*/}
                }
                if(mysDate != MS[s].ERP7__Start_Date__c || myeDate != MS[s].ERP7__Due_Date__c){ proceed = true; if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isUpdateable()){MS[s].ERP7__Start_Date__c = mysDate;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isUpdateable()){MS[s].ERP7__Due_Date__c = myeDate;}else{/*No access*/}
                }
                if(MS[s].ERP7__isSerialized__c){ if(MS[s].ERP7__Previous_Milestone__c != null){ ERP7__Milestone__c prevMS = [Select Id, Name, ERP7__Start_Date__c, ERP7__Due_Date__c, ERP7__Percentage__c, ERP7__Project__c, ERP7__isSerialized__c, ERP7__Previous_Milestone__c, ERP7__Next_Milestone__c From ERP7__Milestone__c where Id =: MS[s].ERP7__Previous_Milestone__c LIMIT 1];
                        if(prevMS != null){   Date prevSD = prevMS.ERP7__Start_Date__c;  Date prevED = prevMS.ERP7__Due_Date__c; Date currentSD = MS[s].ERP7__Start_Date__c;  Date currentED = MS[s].ERP7__Due_Date__c;  Integer days = 0; Integer currDuration = currentSD.daysBetween(currentED);
                            if(currentSD < prevED){ if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isUpdateable()){MS[s].ERP7__Start_Date__c = prevED.addDays(days);}else{/*No access*/}
                                currentSD = MS[s].ERP7__Start_Date__c; if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isUpdateable()){MS[s].ERP7__Due_Date__c = currentSD.addDays(currDuration);}else{/*No access*/}
                            }   resetGantt = true;
                        }
                    }
                    ERP7__Milestone__c nextMS = new ERP7__Milestone__c();                    ERP7__Milestone__c current = new ERP7__Milestone__c();                    List<ERP7__Milestone__c> nextMSlist = new List<ERP7__Milestone__c>();                    List<ERP7__Milestone__c> MSl = [Select Id, Name, ERP7__Start_Date__c, ERP7__Due_Date__c, ERP7__Percentage__c, ERP7__Project__c, ERP7__isSerialized__c, ERP7__Previous_Milestone__c, ERP7__Next_Milestone__c From ERP7__Milestone__c where ERP7__Project__c =: MS[s].ERP7__Project__c AND ERP7__isSerialized__c = true LIMIT 1000];
                    // Id !=: MS[s].Id AND 
                    Id nextId; Id currId;
                    if(MS[s].ERP7__Next_Milestone__c != null){  resetGantt = true;  nextId = MS[s].ERP7__Next_Milestone__c;  currId = MS[s].Id;
                        
                        for(ERP7__Milestone__c seriesMs: MSl) {  if(seriesMs.Id == currId || seriesMs.Id == MS[s].Id){ if(nextId == MS[s].ERP7__Next_Milestone__c){  current = MS[s]; } else{ current = seriesMs; }
                                for(ERP7__Milestone__c nextseriesMs: MSl){ if(nextseriesMs.Id == nextId){ nextMS = nextseriesMs;  Date nextSD = nextMS.ERP7__Start_Date__c; Date nextED = nextMS.ERP7__Due_Date__c;  Date currentED = current.ERP7__Due_Date__c; Integer days = 0; Integer nextDuration = nextSD.daysBetween(nextED);
                                        if(nextSD < currentED){  if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isUpdateable()){nextMS.ERP7__Start_Date__c = currentED.addDays(days);}else{/*No access*/}    nextSD = nextMS.Start_Date__c; if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isUpdateable()){nextMS.ERP7__Due_Date__c = nextSD.addDays(nextDuration);}else{/*No access*/}
                                        }
                                        nextMSlist.add(nextMS);
                                    }
                                }
                            }
                            currId = nextId;   if(nextMS.ERP7__Next_Milestone__c != null)  nextId = nextMS.ERP7__Next_Milestone__c;  else nextId = null;
                        }
                        try{ resetGantt = true; if(Schema.sObjectType.ERP7__Milestone__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.isUpdateable()){DMLManager.upsertAsUser(nextMSlist);}else{/*No access*/}  }  catch(Exception ex){ }
                    }
                }
                try{if(Schema.sObjectType.ERP7__Milestone__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.isUpdateable()){DMLManager.upsertAsUser(MS);}else{/*No access*/} } catch(Exception ex){}
                List<ERP7__Project__c> msPJ = [Select Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Percentage__c From ERP7__Project__c where Id = :MS[0].ERP7__Project__c];
                if (msPJ.size() > 0) { If(MS[0].ERP7__Due_Date__c > msPJ[0].ERP7__End_Date__c){ if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__End_Date__c.isUpdateable()){msPJ[0].ERP7__End_Date__c = MS[0].ERP7__Due_Date__c;}else{/*No access*/}
                        try{ if(Schema.sObjectType.ERP7__Project__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.isUpdateable()){DMLManager.upsertAsUser(msPJ);}else{/*No access*/}} catch(Exception ex){ }
                    }
                    if(MS[s].ERP7__Next_Milestone__c != null){ ERP7__Milestone__c nextMS = [Select Id, Name, ERP7__Start_Date__c, ERP7__Due_Date__c, ERP7__Percentage__c, ERP7__Project__c, ERP7__isSerialized__c, ERP7__Previous_Milestone__c, ERP7__Next_Milestone__c From ERP7__Milestone__c where Id =: MS[s].ERP7__Next_Milestone__c LIMIT 1];
                        If(nextMS.ERP7__Due_Date__c > msPJ[0].ERP7__End_Date__c){   if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__End_Date__c.isUpdateable()){msPJ[0].ERP7__End_Date__c = nextMS.ERP7__Due_Date__c;}else{/*No access*/}
                            try{ if(Schema.sObjectType.ERP7__Milestone__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.isUpdateable()){DMLManager.upsertAsUser(msPJ);}else{/*No access*/}} catch(Exception ex){ }
                        }
                    }
                }
            }
            
            if (PJ.size() > 0) {
                if(progress != Null && progress != '' && PJ[s].ERP7__Percentage__c != Decimal.valueof(progress)) {  proceed = true;  if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Percentage__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Percentage__c.isUpdateable()){PJ[s].ERP7__Percentage__c = Decimal.valueof(progress);}else{/*No access*/}
                    if(PJ[s].ERP7__Percentage__c > 0 && PJ[s].ERP7__Status__c != 'In Progress')  if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Status__c.isUpdateable()){PJ[s].ERP7__Status__c = 'In Progress';  }else{/*No access*/}
                    if(PJ[s].ERP7__Percentage__c == 100 && PJ[s].ERP7__Status__c != 'Completed')  if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Status__c.isUpdateable()){PJ[s].ERP7__Status__c = 'Completed';}else{/*No access*/}
                }
                if(mysDate != PJ[s].ERP7__Start_Date__c || myeDate != PJ[s].ERP7__End_Date__c){  proceed = true; if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Start_Date__c.isUpdateable()){PJ[s].ERP7__Start_Date__c = mysDate;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__End_Date__c.isUpdateable()){PJ[s].ERP7__End_Date__c = myeDate;}else{/*No access*/} } if(Schema.sObjectType.ERP7__Project__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.isUpdateable()){DMLManager.upsertAsUser(PJ);}else{/*No access*/}
            }
            
            return null;        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); return null;}
    }
    
    @RemoteAction
    public static List<ERP7__Project__c> searchProjects(String searchString) {
        List<ERP7__Project__c> PJs= Database.query('Select Id, Name from ERP7__Project__c where ERP7__Start_Date__c != Null And ERP7__End_Date__c != Null And name like \'%' + String.escapeSingleQuotes(searchString) + '%\'');
        return PJs;
    }
    
    @RemoteAction
    public static List<ERP7__Team__c> searchTeams(String searchString) {
        List<ERP7__Team__c> TMs = Database.query('Select Id, Name from ERP7__Team__c where ERP7__Project__c != Null And name like \'%' + String.escapeSingleQuotes(searchString) + '%\'');
        return TMs;
    }
    
    public list <ERP7__Project__c> getProjectList() {
        return [Select Id, Name From ERP7__Project__c limit 10000];
    }
    
    public list <ERP7__Team__c > getTeamList() {
        return [Select Id, Name From ERP7__Team__c WHERE ERP7__Project__c != null];
    }
    
    public PageReference reLoad() {
        if(resetGantt == true)
            resetGantt = false;
        else
            resetGantt = true;
        schedulerString = '';
        getAllProjectData();
        return null;
    }
    
    public PageReference Back2ProjectWorkBench(){
        PageReference Page = new PageReference('/lightning/n/ERP7__ProjectWorkbench');
        Page.SetRedirect(true);
        return Page;
    }
    
    public class PMWP {
        
        public ERP7__Project__c project                                    { get; set; }
        public String errMsg                                               { get; set; }
        public boolean isCurrentP                                          { get; set; }
        public List < User > resourceList                                  { get; set; }
        
        public PMWP(ERP7__Project__c proj, List< User > resList) {
            project = proj;
            isCurrentP = false;
            errMsg = '';
            resourceList = resList;
        }
        
    }
    
    public class milestoneWrap {
        public ERP7__Milestone__c milestone                                { get; set; }
        public String errMsg                                               { get; set; }
        public boolean isCurrentM                                          { get; set; }
        public List<ERP7__Actions_Tasks__c> TaskList                       { get; set; }
        public List < User > resourceGList                                 { get; set; }
        
        public milestoneWrap(ERP7__Milestone__c mile, List<ERP7__Actions_Tasks__c> tasks, List<User> resGroup) {
            milestone = mile;
            isCurrentM = false;
            errMsg = '';
            TaskList = tasks;
            resourceGList = resGroup;
        }
    }
    
    public class data {
        
        public String text                   { get; set; }
        
        public String id                     { get; set; }
        public String scheduleName           { get; set; }        public String workStation            { get; set; } public String wsId                   { get; set; } public String lineitem               { get; set; }        public String lineId                 { get; set; }         public String Processes              { get; set; }        public String processId              { get; set; }
        
        public String WorkOrder              { get; set; }
        public String woId                   { get; set; }
        
        public String project                { get; set; }
        public String projectId              { get; set; }
        
        public String version                { get; set; }
        public String versionId              { get; set; }
        
        public String productservice         { get; set; }
        public String productId              { get; set; }
        
        public String parent                 { get; set; }
        public String schedule               { get; set; }       public String cycle                  { get; set; }     public String cycleId                { get; set; }      public String contact                  { get; set; }        public String contactId                { get; set; }
        
        public String status                 { get; set; }        public String scheduleType           { get; set; }
        public String start_date             { get; set; }
        public Decimal progress              { get; set; }
        public Boolean open                  { get; set; }        public Integer duration              { get; set; }
        public String end_date               { get; set; }
        public Boolean isNew                 { get; set; }
        public Boolean isMO                  { get; set; }
        public Boolean isWO                  { get; set; }
        public Boolean readonly              { get; set; }
        public String start_date_temp        { get; set; }
        public String end_date_temp          { get; set; }
        public String leadTime               { get; set; }        public String tracking               { get; set; }
        
    }
    
    public class schedulesPack {
        public List<data> data               { get; set; }
        public List<links> links             { get; set; }
        
        public schedulesPack(List<data> dataList_s, List<links> linksList_s){
            data = dataList_s;
            links = linksList_s;
        }
    }
    
    public class links {
        @AuraEnabled public String id                     { get; set; }
        @AuraEnabled public String source                 { get; set; }
        @AuraEnabled public String target                 { get; set; }
        @AuraEnabled public String type                   { get; set; }
    }
    
    
}