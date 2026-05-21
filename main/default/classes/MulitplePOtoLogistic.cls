public With Sharing class MulitplePOtoLogistic {
    @AuraEnabled
    public ERP7__Channel__c channel {get; set;}
    @AuraEnabled
    public String DchId {get; set;}
    @AuraEnabled
    public ERP7__Distribution_Channel__c distributionChannel {get; set;}
    @AuraEnabled
    public static Integer TotalRecords(String DCId){
        system.debug('DCId : '+DCId);
        if(DCId == '' || DCId == null) {
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            /*'inside empList is :'+empList */
            List<ERP7__Distribution_Channel__c> dcList;
            system.debug('empList.size() : '+empList.size());
            if(empList.size()>0 && empList != null){
                dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                          where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                
                if(dcList.size() > 0) DcId = dcList[0].Id;
                else DcId = '';
            }
        }
        if(DcId == '' || DcId == null) return 0;
        else return [Select count() from ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Ready_To_Receive__c =false and ERP7__Distribution_Channel__c=:DcId];
        
    }
    @AuraEnabled
    public static MulitplePOtoLogistic fetchChannelandDC(){
        MulitplePOtoLogistic CRTP = new MulitplePOtoLogistic();
        List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c
                                            where ERP7__Employee_User__c=:UserInfo.getUserId()];
        if(empList.size()>0 && empList != null){
            CRTP.channel = [Select Id,Name from ERP7__Channel__c where Id=:empList[0].ERP7__Channel__c limit 1];
            List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                          where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
            /*'fetchChannelandDC dcList is :'+dcList.size()*/
            if(dcList.size()>0 && dcList != null) { CRTP.distributionChannel = dcList[0]; CRTP.DchId =dcList[0].id;} 
            
        }
        return CRTP;
    }
    @AuraEnabled(cacheable=true)
    public static String getPOlist(String searchString, String DcId, Integer pageSize, Integer pageNumber) {
        POdata pda = new POdata();
        List<polst> POlist1 = new List<polst>(); 
        List<ERP7__PO__c> polist  = new  List<ERP7__PO__c>();
        Integer offset = (pageNumber - 1) * pageSize;
        
        //Total Records
        Integer recordEnd = pageSize * pageNumber;
        system.debug('DcId : '+DcId);
        //string searchKeyword = '%' + searchKey + '%';
        
        if(DcId == '' || DcId == null){
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            /*'inside empList is :'+empList */
            List<ERP7__Distribution_Channel__c> dcList;
            system.debug('empList.size() : '+empList.size());
            if(empList.size()>0 && empList != null){
                dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                          where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                
                if(dcList.size() > 0) DcId = dcList[0].Id;
            }
            
        }
        system.debug('searchString : '+searchString);
         String returnrecordId = RecordTypeUtil.getObjectRecordTypeIds('ERP7__PO__c','Standard_Purchase_Order');
        
        
        if(searchString != '' && searchString != null) {
            
            String strKey ='%'+searchString+'%';
            system.debug('strKey : '+strKey);
            system.debug('if executed');
            Integer totalRecords = [SELECT COUNT() FROM ERP7__PO__c WHERE   (Name like :strKey Or ERP7__Vendor__r.Name like :strKey) AND ERP7__Active__c =true and ERP7__Ready_To_Receive__c =false and ERP7__Distribution_Channel__c=:DcId and ERP7__Total_Quantity__c > 0 and RecordTypeId = :returnrecordId];
            system.debug('totalRecords : '+totalRecords);
            pda.pageSize = pageSize;
            system.debug('pda.pageSize : '+pda.pageSize);
            pda.pageNumber = pageNumber;
            system.debug('pda.pageNumber : '+pda.pageNumber);
            pda.recordStart = offset + 1;
            system.debug('pda.recordStart : '+pda.recordStart);
            pda.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            system.debug('pda.recordEnd : '+pda.recordEnd);
            pda.totalRecords = totalRecords;
            system.debug('pda.totalRecords : '+pda.totalRecords);
            polist = [SELECT Id,Name,ERP7__Total_Quantity__c,ERP7__Logistic_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE  ERP7__Active__c =:true  AND (Name like :strKey  Or ERP7__Vendor__r.Name like :strKey) AND ERP7__Ready_To_Receive__c =false and ERP7__Distribution_Channel__c=:DcId and ERP7__Total_Quantity__c > 0 and RecordTypeId = :returnrecordId ORDER BY CreatedDate DESC LIMIT :pageSize ];//OFFSET :offset
            system.debug('if polist : '+polist.size());
            for(ERP7__PO__c po : polist) { 
            	POlist1.add(new polst(po,false));
            }
            pda.POlist = POlist1;
        }
        else {
            Integer totalRecords = [SELECT COUNT() FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Ready_To_Receive__c =false and ERP7__Distribution_Channel__c=:DcId and ERP7__Total_Quantity__c > 0 and RecordTypeId =: returnrecordId];
            system.debug('totalRecords : '+totalRecords);
            pda.pageSize = pageSize;
            system.debug('pda.pageSize : '+pda.pageSize);
            pda.pageNumber = pageNumber;
            system.debug('pda.pageNumber : '+pda.pageNumber);
            pda.recordStart = offset + 1;
            system.debug('pda.recordStart : '+pda.recordStart);
            pda.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            system.debug('pda.recordEnd : '+pda.recordEnd);
            pda.totalRecords = totalRecords;
            system.debug('pda.totalRecords : '+pda.totalRecords);
            polist = [SELECT Id,Name,ERP7__Logistic_Quantity__c,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Ready_To_Receive__c =false and ERP7__Distribution_Channel__c=:DcId and ERP7__Total_Quantity__c > 0 and RecordTypeId =: returnrecordId ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offset];
            for(ERP7__PO__c po : polist) { 
                POlist1.add(new polst(po,false));
            }
            pda.POlist = POlist1;
        }
        String jsonDT = JSON.serialize(pda);
        system.debug(' pda.POlist : '+ pda.POlist.size()+'  pda.POlist : '+pda.POlist);
        return jsonDT;
        
        
        
    }
    @AuraEnabled
    public static wrapper  createLogistics(String POLst){
        system.debug('createLogistics called');
        set<Id> poIds = new set<Id>();
        wrapper wrap = new wrapper();
        List < String >  POLst1= (List < String >) JSON.deserialize(POLst, List < String >.class);
        List < ERP7__Purchase_Line_Items__c >  POLI2upsert= new List < ERP7__Purchase_Line_Items__c >();
        system.debug('POLst1.size() : '+POLst1.size());
        if(POLst1.size() > 0){
            for(String po : POLst1){
                poIds.add(po); 
            }
            List<ERP7__PO__c> selectedPO = [Select Id,Name,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name,ERP7__Vendor_Contact__r.FirstName,ERP7__Vendor_Contact__r.LastName,ERP7__Ready_To_Receive__c,ERP7__Vendor__c,ERP7__Channel__c,ERP7__Logistic_Created__c,ERP7__Distribution_Channel__c,ERP7__Expected_Date__c,ERP7__Barcode__c from ERP7__PO__c where Id In :poIds];
            List<ERP7__Purchase_Line_Items__c> POLIS = [Select Id,Name,ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.Name,ERP7__Logistic_Quantity__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Version__c,ERP7__Explode__c,ERP7__Unit_Price__c,ERP7__Quantity__c from ERP7__Purchase_Line_Items__c where ERP7__Purchase_Orders__c In :poIds and ERP7__Product__r.ERP7__Track_Inventory__c = true];
            if(selectedPO.size() > 0){
                String PORecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Logistic__c','Purchase_Order');
                ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name=system.Today()+'-Logistic', ERP7__Type__c='Inbound', ERP7__Active__c=true,Channel__c=selectedPO[0].ERP7__Channel__c, RecordTypeId=PORecTypeId,ERP7__Distribution_Channel__c=selectedPO[0].ERP7__Distribution_Channel__c);
                Logistic.ERP7__Account__c = selectedPO[0].ERP7__Vendor__c;
                Logistic.ERP7__Account__r = new Account(Id = selectedPO[0].ERP7__Vendor__c,Name =  selectedPO[0].ERP7__Vendor__r.Name);
                Logistic.ERP7__Contact__c = selectedPO[0].ERP7__Vendor_Contact__c;
                if(!test.isRunningTest()) {
                    Logistic.ERP7__Contact__r = new Contact(Id = selectedPO[0].ERP7__Vendor_Contact__c,FirstName = selectedPO[0].ERP7__Vendor_Contact__r.Name,LastName=selectedPO[0].ERP7__Vendor_Contact__r.LastName);
                }
                if(selectedPO[0].ERP7__Expected_Date__c != null) Logistic.ERP7__Logistic_Expected_Date__c = selectedPO[0].ERP7__Expected_Date__c;
                else Logistic.ERP7__Logistic_Expected_Date__c = system.today();
                if(selectedPO[0].ERP7__Barcode__c != null && selectedPO[0].ERP7__Barcode__c != '') Logistic.ERP7__Logistic_Barcode__c=selectedPO[0].ERP7__Barcode__c;
                else Logistic.ERP7__Logistic_Barcode__c = generateRandomString(12);
                List<ERP7__Logistic_Line_Item__c> myLines = new List<ERP7__Logistic_Line_Item__c>();
                for(ERP7__Purchase_Line_Items__c poli :POLIS){
                    //poli.ERP7__Logistic_Quantity__c=poli.ERP7__Quantity__c; POLI2upsert.add(poli);
                    Integer j = 1;
                    string name = poli.Name+'-LogisticLine-'+String.valueof(j);
                    if(name.Length() > 80){
                        name = name.substring(0, 60) + '-LogisticLine-'+String.valueof(j);
                        system.debug('name : '+name);
                    }
                    if(poli.ERP7__Logistic_Quantity__c  == null) poli.ERP7__Logistic_Quantity__c = 0;
                    ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name=name, ERP7__Product__c=poli.ERP7__Product__c, ERP7__Purchase_Line_Items__c=poli.Id, ERP7__Production_Version__c = poli.ERP7__Version__c, ERP7__Explode__c = poli.ERP7__Explode__c, ERP7__Price_Product__c = poli.ERP7__Unit_Price__c,ERP7__Status__c='Reserved',ERP7__Quantity__c=poli.ERP7__Quantity__c - poli.ERP7__Logistic_Quantity__c);  //// ERP7__Price_Product__c = POLI.ERP7__Total_Price__c We should be considering Unit Price
                    loli.ERP7__Product__r = new Product2(Id= poli.ERP7__Product__c,Name =poli.ERP7__Product__r.Name);
                    loli.ERP7__Purchase_Line_Items__r = new ERP7__Purchase_Line_Items__c(Id=poli.Id,Name = poli.Name,ERP7__Quantity__c = poli.ERP7__Quantity__c,ERP7__Logistic_Quantity__c = poli.ERP7__Logistic_Quantity__c,ERP7__Purchase_Orders__r = new PO__c(Name=poli.ERP7__Purchase_Orders__r.Name,Id = poli.ERP7__Purchase_Orders__c));
                    myLines.add(loli);  j++;             
                }
                if(myLines.size() > 0){
                    // upsert Logistic;
                    
                    List<ERP7__Logistic_Line_Item__c> logisticsLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
                    for(ERP7__Logistic_Line_Item__c allLolis : myLines){
                        if(allLolis.ERP7__Quantity__c > 0) logisticsLines2upsert.add(allLolis);
                        //allLolis.Logistic__c = Logistic.Id;
                        
                    }
                    wrap.logistic = Logistic;
                    if(logisticsLines2upsert.size() > 0) wrap.logisticlines = logisticsLines2upsert;// upsert logisticsLines2upsert;
                    
                    //wrap.logistic = [Select Id,Name,Channel__c,Channel__r.Name,ERP7__Distribution_Channel__c,ERP7__Distribution_Channel__r.Name,ERP7__Active__c,ERP7__Total_Quantity__c,ERP7__Logistic_Barcode__c,ERP7__Logistic_Expected_Date__c from Logistic__c where Id=:Logistic.Id];
                    
                    /* set<Id> loglineIds = new set<Id>();
for(ERP7__Logistic_Line_Item__c loglne:logisticsLines2upsert) loglineIds.add(loglne.Id);
wrap.logisticlines = [Select Id,Name,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Production_Version__c,ERP7__Production_Version__r.Id,ERP7__Production_Version__r.Name,ERP7__Purchase_Line_Items__r.Id,ERP7__Purchase_Line_Items__r.Name from ERP7__Logistic_Line_Item__c where Id In : loglineIds];
for(ERP7__PO__c po : selectedPO) { po.ERP7__Logistic_Created__c = true; po.ERP7__Ready_To_Receive__c =true;}
update selectedPO;
update POLI2upsert;*/
                }
                
            }
        }
        return wrap;
    }
    @AuraEnabled 
    public static ERP7__Logistic__c updateLogistics(ERP7__Logistic__c Logistic,List<Id> SelectedPRLIs,String LOLI){
        List<ERP7__Logistic_Line_Item__c> logsticlst = (List<ERP7__Logistic_Line_Item__c>) JSON.deserialize(LOLI, List<ERP7__Logistic_Line_Item__c>.class);
        system.debug('logsticlst : '+logsticlst.size());
        List<ERP7__Purchase_Line_Items__c> RPLI2Update = new List<ERP7__Purchase_Line_Items__c>();
        List<ERP7__Purchase_Line_Items__c> prlis = [Select Id,Name , ERP7__Purchase_Orders__c,ERP7__Logistic_Quantity__c from ERP7__Purchase_Line_Items__c where Id In: SelectedPRLIs];
        system.debug('prlis : '+prlis.size());
        List<ERP7__Logistic_Line_Item__c> logline2upsert = new List<ERP7__Logistic_Line_Item__c>();
        for(ERP7__Logistic_Line_Item__c log : logsticlst){
            system.debug('log : '+log);
            for(ERP7__Purchase_Line_Items__c prli : prlis){
                if(log.ERP7__Purchase_Line_Items__c == prli.Id) {
                    logline2upsert.add(log);
                    if(prli.ERP7__Logistic_Quantity__c == null) prli.ERP7__Logistic_Quantity__c = 0;
                    prli.ERP7__Logistic_Quantity__c = prli.ERP7__Logistic_Quantity__c + log.ERP7__Quantity__c;
                    RPLI2Update.add(prli);
                }
            }
        }
        if(logline2upsert.size() > 0){
            if(Logistic.ERP7__Shipment_type__c == '' || Logistic.ERP7__Shipment_type__c == null)  Logistic.ERP7__Shipment_type__c='UPS';
            if(Logistic.ERP7__Shipment_Preference_Speed__c == '' || Logistic.ERP7__Shipment_Preference_Speed__c == null) Logistic.ERP7__Shipping_Preferences__c='--None--';
                      
            upsert Logistic;
            
            set<Id> poIds = new set<Id>();
            for(ERP7__Logistic_Line_Item__c ll : logline2upsert) { ll.Logistic__c = Logistic.Id; }
            upsert logline2upsert;
            
            for(ERP7__Purchase_Line_Items__c pr : prlis) poIds.add(pr.ERP7__Purchase_Orders__c);
            if(RPLI2Update.size() > 0) update RPLI2Update;
            List<ERP7__PO__c> POs2update = [Select Id,Name,ERP7__Logistic_Created__c,ERP7__Total_Quantity__c,ERP7__Logistic_Quantity__c,ERP7__Status__c from ERP7__PO__c where Id In:poIds];
            List<ERP7__Purchase_Line_Items__c> trackPRqty = [Select Id,Name,ERP7__Product__c,ERP7__Quantity__c,ERP7__Purchase_Orders__c from ERP7__Purchase_Line_Items__c where ERP7__Purchase_Orders__c IN:poIds and ERP7__Product__r.ERP7__Track_Inventory__c = false];
            Map<Id,decimal> noniventoryMap = new Map<Id,decimal>();
            for(ERP7__PO__c po : POs2update) { 
                decimal noninventoryItem = 0;
                po.ERP7__Logistic_Created__c = true;
                for(ERP7__Purchase_Line_Items__c pr : trackPRqty){
                    if(po.Id == pr.ERP7__Purchase_Orders__c){
                        noninventoryItem += pr.ERP7__Quantity__c;
                    }
                }
                system.debug('noninventoryItem : '+noninventoryItem);
                if(po.ERP7__Logistic_Quantity__c == po.ERP7__Total_Quantity__c) po.ERP7__Ready_To_Receive__c = true;
              	else if(noninventoryItem > 0 && (po.ERP7__Logistic_Quantity__c == (po.ERP7__Total_Quantity__c - noninventoryItem))) po.ERP7__Ready_To_Receive__c = true;
                po.ERP7__Status__c = 'Approved';
            }
            if(POs2update.size() > 0) update POs2update;
            
        }
        return Logistic;
        
    }
    @AuraEnabled(cacheable=true)
    public static Integer getNext(Integer v_Offset, Integer v_pagesize){
        v_Offset += v_pagesize;
        return v_Offset;
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getPrevious(Integer v_Offset, Integer v_pagesize){
        v_Offset -= v_pagesize;
        return v_Offset;
    }
    public class wrapper{
        @AuraEnabled public Logistic__c logistic {get; set;} 
        @AuraEnabled public List<ERP7__Logistic_Line_Item__c> logisticlines {get; set;}
        public wrapper(){
            logistic = new Logistic__c();
            logisticlines=new List<ERP7__Logistic_Line_Item__c>();
        }
        
    }
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    public class POdata{
        public List<polst> POlist { get;set;}
        public Integer recsize { get;set;}
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        
    }
    public class polst{
        public ERP7__PO__c PO  	{ get;set;}
        public Boolean isSelected 	{ get;set;}
        public polst(ERP7__PO__c newPO, Boolean selected){
            PO = newPO; isSelected = selected;
        }
    }
    
    
}