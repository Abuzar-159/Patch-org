public With Sharing class MulitplePOtoBill {
    @AuraEnabled    public ERP7__Channel__c channel {get; set;}    @AuraEnabled    public Account vendor {get; set;}    @AuraEnabled    public String DchId {get; set;}    @AuraEnabled    public ERP7__Distribution_Channel__c distributionChannel {get; set;}  
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
        else return [Select count() from ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Ready_To_Receive__c =false and ERP7__Distribution_Channel__c=:DcId AND ERP7__Vendor__c='0011o00001U1SQ0AAN'];
        
    }
    @AuraEnabled
    public static MulitplePOtoBill fetchChannelandDC(){
        MulitplePOtoBill CRTP = new MulitplePOtoBill();
        List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c
                                            where ERP7__Employee_User__c=:UserInfo.getUserId()];
        if(empList.size()>0 && empList != null){
            CRTP.channel = [Select Id,Name from ERP7__Channel__c where Id=:empList[0].ERP7__Channel__c limit 1];
            List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                          where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
            /*'fetchChannelandDC dcList is :'+dcList.size()*/
            if(dcList.size()>0 && dcList != null) { CRTP.distributionChannel = dcList[0]; CRTP.DchId =dcList[0].id;} 
            CRTP.vendor = [select Id, Name from Account where ERP7__Account_Type__c = 'Vendor' limit 1];
            
        }
        return CRTP;
    }
    @AuraEnabled(cacheable=true)
    public static POdata getPOlist(String searchString, String DcId, Integer Offset, Integer RecordLimit, String venId) {
        POdata pda = new POdata();
        Set<Id> poIds = new Set<Id>();
        Set<Id> billPoIds = new Set<Id>();
        Set<Id> poliIds = new Set<Id>();
        Map<Id, ERP7__PO__c> poMap = new Map<Id, ERP7__PO__c>();
        Map<Id, ERP7__Bill__c> poBillMap = new Map<Id, ERP7__Bill__c>();
        Map<Id, ERP7__Bill_Line_Item__c> poBillItemMap = new Map<Id, ERP7__Bill_Line_Item__c>();
        List<ERP7__PO__c> wbPo = new List<ERP7__PO__c>();
        List<ERP7__PO__c> polist  = new  List<ERP7__PO__c>();
        Integer ikOffset = Integer.valueof(Offset);
        system.debug('ikOffset : '+ikOffset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        system.debug('ikRecordLimit : '+ikRecordLimit);
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
        if(searchString != '' && searchString != null) {
            String strKey ='%'+searchString+'%';
            system.debug('strKey : '+strKey);
            system.debug('if executed');
            List<ERP7__PO__c> pos = [SELECT Id,Name,ERP7__Billed_Quantity__c,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Vendor__c=:venId  AND ERP7__Total_Due__c>0 and ERP7__Remaining_Billing_Quantity__c>0 and ERP7__Distribution_Channel__c=:DcId ORDER BY CreatedDate DESC ];
            /*poIds = (new Map<Id, ERP7__PO__c>(pos)).keyset();
            List<ERP7__Bill_Line_Item__c> billlineList = new List<ERP7__Bill_Line_Item__c>();
            billlineList = [select Id,ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Billed_Quantity__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Quantity__c,ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c  from ERP7__Bill_Line_Item__c where ERP7__Purchase_Orders__c In :poIds];
            for(ERP7__Bill_Line_Item__c bb : billlineList){
                if((bb.ERP7__Purchase_Order_Line_Items__c != null) && (bb.ERP7__Purchase_Order_Line_Items__r.ERP7__Quantity__c == bb.ERP7__Purchase_Order_Line_Items__r.ERP7__Billed_Quantity__c))
                poBillItemMap.put(bb.ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c, bb);
            }
            if(pos.size()>0){
                for(ERP7__PO__c pp : pos){
                    if(poBillItemMap.containskey(pp.Id)){
                        billPoIds.add(pp.Id);
                    }
                }
            }*/
            polist = [SELECT Id,Name,ERP7__Billed_Quantity__c,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE  ERP7__Active__c =:true  and ERP7__Vendor__c=:venId  AND Name like :strKey AND ERP7__Total_Due__c >0 and  ERP7__Distribution_Channel__c=:DcId and ERP7__Remaining_Billing_Quantity__c>0 ORDER BY CreatedDate DESC];//and Id Not IN :billPoIds
            wbPo = polist;
            /*if(polist.size()>0){
                poMap = new Map<Id,ERP7__PO__c>(polist);
                List<ERP7__Bill__c> billList = new List<ERP7__Bill__c>();
                billList = [select Id, Name, ERP7__Purchase_Order__c from ERP7__Bill__c where ERP7__Purchase_Order__c!=null order by createdDate desc limit 10000];
                if(billList.size()>0){
                    for(ERP7__Bill__c bb : billList){
                        poBillMap.put(bb.ERP7__Purchase_Order__c, bb);
                    }
                    for(ERP7__PO__c po : polist){
                        //if(!poBillMap.containskey(po.Id)){
                            wbPo.add(po);
                        //}
                    }
                }else{
                    wbPo = polist;
                }
            }*/
            system.debug('if polist : '+polist.size());
            pda.POlist = wbPo;
            //limit :ikRecordLimit Offset :ikOffset
            if(wbPo.size()>0){                Set<Id> wbPoId = (new Map<Id,ERP7__PO__c>(wbPo)).keyset();                wbPo = [SELECT Id,Name,ERP7__Billed_Quantity__c,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Vendor__c=:venId  AND ERP7__Total_Due__c>0 and ERP7__Distribution_Channel__c=:DcId and ERP7__Remaining_Billing_Quantity__c>0 ORDER BY CreatedDate DESC limit :ikRecordLimit Offset :ikOffset];            }
            
            polist = [SELECT Id,Name,ERP7__Billed_Quantity__c,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Vendor__c=:venId  AND ERP7__Total_Due__c >0 and ERP7__Distribution_Channel__c=:DcId and ERP7__Remaining_Billing_Quantity__c>0 ORDER BY CreatedDate DESC Limit 2000];
            pda.recsize = polist.size();
            system.debug('polist : '+polist.size());
            return pda;
        }
        else{
            List<ERP7__PO__c> pos = [SELECT Id,ERP7__Billed_Quantity__c,Name,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Vendor__c=:venId  AND ERP7__Total_Due__c>0 and ERP7__Remaining_Billing_Quantity__c>0 and ERP7__Distribution_Channel__c=:DcId ORDER BY CreatedDate DESC ];
            /*poIds = (new Map<Id, ERP7__PO__c>(pos)).keyset();
            List<ERP7__Bill_Line_Item__c> billlineList = new List<ERP7__Bill_Line_Item__c>();
            billlineList = [select Id,ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Billed_Quantity__c, ERP7__Purchase_Order_Line_Items__r.ERP7__Quantity__c,ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c  from ERP7__Bill_Line_Item__c where ERP7__Purchase_Orders__c In :poIds];
            for(ERP7__Bill_Line_Item__c bb : billlineList){
                if((bb.ERP7__Purchase_Order_Line_Items__c != null) && (bb.ERP7__Purchase_Order_Line_Items__r.ERP7__Quantity__c == bb.ERP7__Purchase_Order_Line_Items__r.ERP7__Billed_Quantity__c))
                poBillItemMap.put(bb.ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c, bb);
            }
            if(pos.size()>0){
                for(ERP7__PO__c pp : pos){
                    if(poBillItemMap.containskey(pp.Id)){
                        billPoIds.add(pp.Id);
                    }
                }
            }*/
            system.debug('billPoIds-->'+billPoIds);
            polist = [SELECT Id,Name,ERP7__Billed_Quantity__c,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Vendor__c=:venId  AND ERP7__Total_Due__c>0 and ERP7__Distribution_Channel__c=:DcId and ERP7__Remaining_Billing_Quantity__c>0  ORDER BY CreatedDate DESC ];//and Id Not IN :billPoIds
            wbPo = polist;
            /*if(polist.size()>0){
                poMap = new Map<Id,ERP7__PO__c>(polist);
                List<ERP7__Bill__c> billList = new List<ERP7__Bill__c>();
                billList = [select Id, Name, ERP7__Purchase_Order__c from ERP7__Bill__c where ERP7__Purchase_Order__c!=null and ERP7__Purchase_Order__c IN : poMap.keyset() order by createdDate desc limit 10000];
                system.debug('poMap--->'+poMap.size());
                if(billList.size()>0){
                    for(ERP7__Bill__c bb : billList){
                        poBillMap.put(bb.ERP7__Purchase_Order__c, bb);
                    }
                    for(ERP7__PO__c po : polist){
                        //if(!poBillMap.containskey(po.Id)){
                            wbPo.add(po);
                        //}
                    }
                }else{
                    wbPo = polist;
                }
            }*/
            
            if(wbPo.size()>0){
                Set<Id> wbPoId = (new Map<Id,ERP7__PO__c>(wbPo)).keyset();
                wbPo = [SELECT Id,Name,ERP7__Billed_Quantity__c,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Vendor__c=:venId  AND ERP7__Total_Due__c>0 and ERP7__Distribution_Channel__c=:DcId and ERP7__Remaining_Billing_Quantity__c>0 ORDER BY CreatedDate DESC limit :ikRecordLimit Offset :ikOffset];
            }
            pda.POlist = wbPo;
            polist = [SELECT Id,Name,ERP7__Billed_Quantity__c,ERP7__Total_Quantity__c,ERP7__Count_PO_Line_Items__c,ERP7__Customer__c,ERP7__Customer__r.Name,ERP7__Vendor__c,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__c,ERP7__Vendor_Contact__r.Name FROM ERP7__PO__c WHERE ERP7__Active__c =true and ERP7__Vendor__c=:venId  AND ERP7__Total_Due__c >0 and ERP7__Distribution_Channel__c=:DcId and ERP7__Remaining_Billing_Quantity__c>0 ORDER BY CreatedDate DESC Limit 2000];
            pda.recsize = polist.size();
            system.debug('polist : '+polist.size());
            return pda;
        } 
        //limit :ikRecordLimit Offset :ikOffset
        
    }
    @AuraEnabled    public static wrapper  createLogistics(String POLst){        system.debug('createLogistics called');        List<LineItemWrapper> lineWra = new List<LineItemWrapper>();        Map<Id, List<ERP7__Dimension__c>> PoliDimMap = new Map<Id, List<ERP7__Dimension__c>>();        set<Id> poIds = new set<Id>();        wrapper wrap = new wrapper();        String vendorId = '';        String orgId = '';        Boolean AllocationAccess = false;        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c(); FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());        if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();   }        if(FC != null){ AllocationAccess = FC.ERP7__Allocation_Process__c;  }        List < String >  POLst1= (List < String >) JSON.deserialize(POLst, List < String >.class);        List < ERP7__Purchase_Line_Items__c >  POLI2upsert= new List < ERP7__Purchase_Line_Items__c >();        system.debug('POLst1.size() : '+POLst1.size());        String poName = '';        if(POLst1.size() > 0){            for(String po : POLst1){                poIds.add(po);             }            List<ERP7__PO__c> selectedPO = [Select Id,Name,ERP7__Ready_To_Receive__c,ERP7__Vendor__c,ERP7__Channel__c,ERP7__Logistic_Created__c,ERP7__Distribution_Channel__c,ERP7__Expected_Date__c,ERP7__Barcode__c, ERP7__Organisation__c from ERP7__PO__c where Id In :poIds];            List<ERP7__Purchase_Line_Items__c> POLIS = [Select Id,ERP7__Purchase_Orders__c, ERP7__Sort_Order__c, Name,ERP7__Logistic_Quantity__c,ERP7__Billed_Quantity__c, ERP7__Product__c,ERP7__Version__c,ERP7__Explode__c,ERP7__Unit_Price__c,ERP7__Quantity__c, ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Description__c, ERP7__Special_Instruction__c, ERP7__Tax__c, ERP7__Total_Price__c, ERP7__Tax_Rate__c, ERP7__Product__r.Name, ERP7__Purchase_Orders__r.Name from ERP7__Purchase_Line_Items__c where ERP7__Purchase_Orders__c In :poIds];            Set<Id> poliIds = new Set<Id>();            if(AllocationAccess){                                for(ERP7__Purchase_Line_Items__c poli :POLIS){                    poliIds.add(poli.Id);                }                if(poliIds.size()>0){                    List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();                    demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.Name, ERP7__Project__c,ERP7__Project__r.Name,  ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c,ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c,ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c,ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c from ERP7__Dimension__c where ERP7__Purchase_Line_Items__c != null AND ERP7__Purchase_Line_Items__c IN :poliIds];                    for(ERP7__Dimension__c dem : demList){                        if(PoliDimMap.containskey(dem.ERP7__Purchase_Line_Items__c)){                            PoliDimMap.get(dem.ERP7__Purchase_Line_Items__c).add(dem);                        }else{                            List<ERP7__Dimension__c> demList1 = new List<ERP7__Dimension__c>();                            demList1.add(dem);                            PoliDimMap.put(dem.ERP7__Purchase_Line_Items__c, demList1);                        }                    }                }            }            system.debug('PoliDimMap-->'+PoliDimMap);            if(selectedPO.size() > 0){                for(ERP7__PO__c po : selectedPO){                   poName = poName + po.Name;                  poName = poName + ',';                    vendorId = po.ERP7__Vendor__c;                    if(po.ERP7__Organisation__c!=null) orgId = po.ERP7__Organisation__c;                }            }            if(orgId!=''&& orgId!=null){                wrap.Org = [select Id, Name from Account where Id = :orgId];            }            if(selectedPO.size() > 0){                if(vendorId!='' && vendorId!=null) {                    Account Acc = [select Id, Name from Account where Id = :vendorId];                    wrap.vendorName = Acc.Name;                }                String PORecTypeId = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get('PO_Bill').getRecordTypeId();                ERP7__Bill__c bill = new ERP7__Bill__c(RecordTypeId=PORecTypeId, ERP7__Vendor_Bill_Date__c = system.today(), ERP7__Due_Date__c = system.today(), ERP7__PO_Name__c = poName, ERP7__Vendor__c = vendorId,ERP7__Organisation__c = orgId);                upsert bill;                List<ERP7__Bill_Line_Item__c> billLines = new List<ERP7__Bill_Line_Item__c>();                for(ERP7__Purchase_Line_Items__c poli :POLIS){                    poli.ERP7__Logistic_Quantity__c=poli.ERP7__Quantity__c; POLI2upsert.add(poli);                    if(poli.ERP7__Billed_Quantity__c == null || poli.ERP7__Quantity__c != poli.ERP7__Billed_Quantity__c){                    ERP7__Bill_Line_Item__c billItem;                    if(poli.ERP7__Billed_Quantity__c != null)                    billItem = new ERP7__Bill_Line_Item__c(ERP7__Sort_Order__c = poli.ERP7__Sort_Order__c, ERP7__Purchase_Orders__c = poli.ERP7__Purchase_Orders__c,  ERP7__Tax_Rate__c = poli.ERP7__Tax_Rate__c, ERP7__Tax_Amount__c=poli.ERP7__Tax__c, ERP7__Item_Description__c=poli.ERP7__Description__c, Name=poli.Name, ERP7__Item_Type__c='Item', ERP7__Chart_Of_Account__c = poli.ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Product__c=poli.ERP7__Product__c, ERP7__Purchase_Order_Line_Items__c=poli.Id, ERP7__Amount__c = poli.ERP7__Unit_Price__c, ERP7__Quantity__c=poli.ERP7__Quantity__c-poli.ERP7__Billed_Quantity__c, ERP7__Discount__c=0.00, ERP7__Total_Amount__c = poli.ERP7__Total_Price__c);                     else                     billItem = new ERP7__Bill_Line_Item__c(ERP7__Sort_Order__c = poli.ERP7__Sort_Order__c,  ERP7__Purchase_Orders__c = poli.ERP7__Purchase_Orders__c,  ERP7__Tax_Rate__c = poli.ERP7__Tax_Rate__c, ERP7__Tax_Amount__c=poli.ERP7__Tax__c, ERP7__Item_Description__c=poli.ERP7__Description__c, Name=poli.Name, ERP7__Item_Type__c='Item', ERP7__Chart_Of_Account__c = poli.ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Product__c=poli.ERP7__Product__c, ERP7__Purchase_Order_Line_Items__c=poli.Id, ERP7__Amount__c = poli.ERP7__Unit_Price__c, ERP7__Quantity__c=poli.ERP7__Quantity__c, ERP7__Discount__c=0.00, ERP7__Total_Amount__c = poli.ERP7__Total_Price__c);                    billLines.add(billItem);                     LineItemWrapper lwp = new LineItemWrapper();                    if(PoliDimMap!=null && PoliDimMap.containskey(poli.Id) && !PoliDimMap.isEmpty()) {                         List<ERP7__Dimension__c> dem1 = new List<ERP7__Dimension__c>();                         dem1 = PoliDimMap.get(poli.Id);                         billItem.ERP7__Account_Category__c = dem1[0].ERP7__Account_Category__c;                         billItem.ERP7__Chart_Of_Account__c = dem1[0].ERP7__Chart_of_Account__c;                         lwp.AccAccountingName = dem1[0].ERP7__Chart_of_Account__r.Name;                    }                    lwp.billItem = billItem;                    if(PoliDimMap!=null && PoliDimMap.containskey(poli.Id) && !PoliDimMap.isEmpty()){                        for(ERP7__Dimension__c dem : PoliDimMap.get(poli.Id)){                            dem.ERP7__Sort_Order__c = poli.ERP7__Sort_Order__c;                         }                        system.debug('Entered');                        lwp.Allocations = PoliDimMap.get(poli.Id);                        lwp.displayAccoutning = true;                    }                    lwp.ProductName = poli.ERP7__Product__r.Name;                    lwp.PoName = poli.ERP7__Purchase_Orders__r.Name;                    system.debug('lwp.Allocations-->'+lwp.Allocations);                    lineWra.add(lwp);                    }                }                system.debug('billLines-->'+billLines.size());                                                wrap.bill = bill;                wrap.lineWrapper = lineWra;                wrap.billItems = billLines;                                  }        }        return wrap;    }   
    @AuraEnabled(cacheable=true)    public static Integer getNext(Integer v_Offset, Integer v_pagesize){        v_Offset += v_pagesize;        return v_Offset;    }        @AuraEnabled(cacheable=true)    public static Integer getPrevious(Integer v_Offset, Integer v_pagesize){        v_Offset -= v_pagesize;        return v_Offset;    }
    
    public class wrapper{
        @AuraEnabled public ERP7__Bill__c bill {get; set;} 
        @AuraEnabled public Account Org {get; set;} 
        @AuraEnabled public String vendorName {get; set;} 
        @AuraEnabled public List<ERP7__Bill_Line_Item__c> billItems {get; set;}
        @AuraEnabled public List<LineItemWrapper> lineWrapper       {get;set;}
        public wrapper(){
            bill = new ERP7__Bill__c();
            Org = new Account();
            vendorName = '';
            billItems=new List<ERP7__Bill_Line_Item__c>();
            lineWrapper = new List<LineItemWrapper>();
        }
        
    }
    
    public class LineItemWrapper{
        @AuraEnabled public ERP7__Bill_Line_Item__c billItem {get; set;}
        @AuraEnabled public List<ERP7__Dimension__c> Allocations {get; set;}
        @AuraEnabled public List<String> options                 {get;set;}
        @AuraEnabled public String ProductName {get;set;}
        @AuraEnabled public String AccAccountingName {get;set;}
        @AuraEnabled public Boolean displayAccoutning {get;set;}
        @AuraEnabled public String PoName {get;set;}
        public LineItemWrapper(){
            billItem = new ERP7__Bill_Line_Item__c();
            ProductName = AccAccountingName = null;
            PoName = null;
            Allocations = new List<ERP7__Dimension__c>();
            options = new List<String>();
            displayAccoutning = false;
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
        @AuraEnabled  public List<ERP7__PO__c> POlist { get;set;}
        @AuraEnabled  public Integer recsize { get;set;}
        
        
    }
    
    
    @AuraEnabled     public static ERP7__Bill__c updateLogistics(ERP7__Bill__c Logistic, String LOLI, String VendorId){        Set<Id> poliIds = new Set<Id>();        List<ERP7__Bill_Line_Item__c> logsticlst = (List<ERP7__Bill_Line_Item__c>) JSON.deserialize(LOLI, List<ERP7__Bill_Line_Item__c>.class);        system.debug('logsticlst : '+logsticlst.size());        upsert Logistic;        Map<Id, Id> MapBillPoliId = new Map<Id, Id>();        for(ERP7__Bill_Line_Item__c bb : logsticlst){             bb.ERP7__Bill__c = Logistic.Id;             poliIds.add(bb.ERP7__Purchase_Order_Line_Items__c);        }        upsert logsticlst;        for(ERP7__Bill_Line_Item__c bb : logsticlst){            MapBillPoliId.put(bb.ERP7__Purchase_Order_Line_Items__c, bb.Id);        }        List<ERP7__Dimension__c> demList1 = new List<ERP7__Dimension__c>();        demList1 = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.Name, ERP7__Project__c,ERP7__Project__r.Name,  ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c,ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c,ERP7__Purchase_Line_Items__r.ERP7__Account_Category__c,ERP7__Purchase_Line_Items__r.ERP7__Chart_of_Account__c from ERP7__Dimension__c where ERP7__Purchase_Line_Items__c != null AND ERP7__Purchase_Line_Items__c IN :poliIds];        system.debug('demList-->'+demList1);        List<ERP7__Bill_Line_Item__c> Billli = [select Id, Name, ERP7__Organisation__c, ERP7__Sort_Order__c,ERP7__Account_Category__c,ERP7__Chart_Of_Account__c from ERP7__Bill_Line_Item__c where ERP7__Bill__c=:Logistic.Id];        Map<Integer, ERP7__Bill_Line_Item__c > BilliMap = new Map<Integer, ERP7__Bill_Line_Item__c >();        for(ERP7__Bill_Line_Item__c pol : Billli){ BilliMap.put(Integer.valueOf(pol.ERP7__Sort_Order__c), pol); }        system.debug('BilliMap-->'+BilliMap);        if(demList1.size() > 0 && Billli.size() > 0){            system.debug('demList1');            for(ERP7__Dimension__c dem1 : demList1){                system.debug('Sort Order-->'+dem1.ERP7__Sort_Order__c);                system.debug('MapBillPoliId-->'+MapBillPoliId);                if(dem1.ERP7__Sort_Order__c != null){                    if(MapBillPoliId.containsKey(dem1.ERP7__Purchase_Line_Items__c)){                        dem1.Id = null;                        system.debug('MapBillPoliId.get(dem1.ERP7__Purchase_Line_Items__c)-->'+MapBillPoliId.get(dem1.ERP7__Purchase_Line_Items__c));                        dem1.ERP7__Bill_Line_Item__c = MapBillPoliId.get(dem1.ERP7__Purchase_Line_Items__c); dem1.Name = BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Name; dem1.ERP7__Active__c = true;                        if(Billli[0].ERP7__Organisation__c != null) dem1.ERP7__Organisation__c = Billli[0].ERP7__Organisation__c;                        if(BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c != null) dem1.ERP7__Account_Category__c = BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c;                        if(BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_Of_Account__c != null) dem1.ERP7__Chart_of_Account__c = BilliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_Of_Account__c;                    }                }            }            system.debug('demList1-->'+demList1);            insert demList1;        }        ERP7__Bill__c bb = [select Id, Name from ERP7__Bill__c where Id=:Logistic.Id];        Set<Id> PIds = new Set<Id>();        return bb;                    }    
}