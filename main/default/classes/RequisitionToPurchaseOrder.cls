public with sharing class RequisitionToPurchaseOrder {

    public String prId                                                             { get; set; }         
    public String errorMsg                                                         { get; set; }
    public String errorMsg1                                                        { get; set; } 
    public String errorMsg2                                                        { get; set; }     
    public String exceptionMsg                                                     { get; set; }      
    public String PRFields                                                         { get; set; }   
    public String PRLIFields                                                       { get; set; }  
    public String POLIFields                                                       { get; set; } 
    public String CurrentTab                                                       { get; set; }
    public String requisitionId                                                    { get; set; }
    public List<Id> prIdList                                                       { get; set; }  
    public List<Id> prliIds                                                        { get; set; }
    public Boolean flag                                                            { get; set; } 
    public Boolean showTab2                                                        { get; set; }
    public Boolean showPRLIPnl                                                     { get; set; }
    public Boolean showNextBtn                                                     { get; set; }   
    public Boolean singleView                                                      { get; set; } public Boolean multipleView                                                    { get; set; }  
    public PO__c poInstance                                                        { get; set; }
    public Requisition__c PR                                                       { get; set; } 
    public Set<PRWrapper> selectedPRLIWrapSet                                      { get; set; }
    public List<PRWrapper> selectedPRLIWrapList                                    { get; set; }
    public List<Requisition__c> PRList                                             { get; set; }   
    public Map<Id, List<Purchase_Line_Items__c>> poliMap                           { get; set; }    
    public Purchase_Requisition_Line_Items__c prlis                                { get; set; }  
    public List<Purchase_Line_Items__c> poliItemList                               { get; set; }      
    public List<Purchase_Line_Items__c> poliList2Insert                            { get; set; }    
    public List<Purchase_Requisition_Line_Items__c> PRLIList                       { get; set; }
    public List<Purchase_Requisition_Line_Items__c> updatePRLIList                 { get; set; }
     
    /*
      Constructor
    */
    public RequisitionToPurchaseOrder() {
        try {
            
            
            string pureid = ApexPages.CurrentPage().getParameters().get('prId');
            
            if(pureid != null) requisitionId = pureid;
            
            PRFields = UtilClass.selectStarFromSObject('Requisition__c'); 
            UtilClass.FlSCheck(PRFields.split(',') ,'Requisition__c');
            POLIFields = UtilClass.selectStarFromSObject('Purchase_Line_Items__c'); 
            UtilClass.FlSCheck(POLIFields.split(',') ,'Purchase_Line_Items__c');
            PRLIFields = UtilClass.selectStarFromSObject('Purchase_Requisition_Line_Items__c');
            UtilClass.FlSCheck(PRLIFields.split(',') ,'Purchase_Requisition_Line_Items__c');
            
            showTab2 = true;
            showNextBtn = true;
            CurrentTab = 'tab1';
            errorMsg2 = '';
            exceptionMsg = '';            
            prIdList = new List<Id>();
            prliIds = new List<Id>();
            prliWrapMap = new Map<Id, PRWrapper>();
            PR = new Requisition__c();
            poInstance = new PO__c();        
            selectedPRLIWrapSet = new Set<PRWrapper>();        
            selectedPRLIWrapList = new List<PRWrapper>();
            PRList = new List<Requisition__c>();        
            poliMap = new Map<Id, List<Purchase_Line_Items__c>>();
            prlis = new Purchase_Requisition_Line_Items__c();                
            poliItemList = new List<Purchase_Line_Items__c>();
            poliList2Insert = new List<Purchase_Line_Items__c>();
            PRLIList = new List<Purchase_Requisition_Line_Items__c>();
            updatePRLIList = new List<Purchase_Requisition_Line_Items__c>();
            
            if(requisitionId != null) prIdList.add(requisitionId);
            PRList = getPRList(prIdList);
            if(PRList.size() == 1) {
                if(prList[0].Organisation__c != null) if(Schema.sObjectType.Requisition__c.fields.Organisation__c.isAccessible())poInstance.Organisation__c = prList[0].Organisation__c;
                if(prList[0].Originating_Business_Unit__c != null) if(Schema.sObjectType.Requisition__c.fields.Originating_Business_Unit__c.isAccessible())poInstance.Organisation_Business_Unit__c = prList[0].Originating_Business_Unit__c;
                if(prList[0].Originating_Business_Unit__c != null) if(Schema.sObjectType.Requisition__c.fields.Originating_Business_Unit__c.isAccessible())poInstance.Organisation_Business_Unit__c = prList[0].Originating_Business_Unit__c;
                if(prList[0].Programme__c != null) if(Schema.sObjectType.Requisition__c.fields.Programme__c.isAccessible())poInstance.Programme__c = prList[0].Programme__c;
                if(prList[0].Project__c != null) if(Schema.sObjectType.Requisition__c.fields.Project__c.isAccessible())poInstance.Project__c = prList[0].Project__c; 
                if(prList[0].Delivery_Address__c != null) if(Schema.sObjectType.Requisition__c.fields.Delivery_Address__c.isAccessible())poInstance.Delivery_Address__c = prList[0].Delivery_Address__c;
                if(prList[0].Expected_Delivery_Date__c != null) if(Schema.sObjectType.Requisition__c.fields.Expected_Delivery_Date__c.isAccessible())poInstance.Expected_Delivery_Date__c = prList[0].Expected_Delivery_Date__c;
                if(prList[0].Actual_Delivery_Date__c != null) if(Schema.sObjectType.Requisition__c.fields.Actual_Delivery_Date__c.isAccessible())poInstance.Actual_Delivery_Date__c = prList[0].Actual_Delivery_Date__c; 
                if(prList[0].Description__c != null) if(Schema.sObjectType.Requisition__c.fields.Description__c.isAccessible())poInstance.Description__c = prList[0].Description__c;
                poInstance.Order_Date__c = System.Today(); poInstance.Publication_Date__c = System.Today();             
                
                singleView = true; multipleView = false; PRLIList = getPRLIList(prIdList);                
                if(PRLIList != null && PRLIList.size() > 0) { for(Purchase_Requisition_Line_Items__c prli : PRLIList) { prliIds.add(prli.Id); }        
                }
                if(prliIds.size() > 0) displayPRLILineItems(prliIds);                       
                                        
            } else if(PRList.size() > 1) { diplayPRList(JSON.serialize(PRList)); singleView = false;  multipleView = true; }        
        } catch(Exception e) { exceptionMethod(e, 'constructor'); }
    }
    
    /*
      method for fetching purchase requisition list    
    */
    public List<Requisition__c> getPRList(List<Id> prIdList) {
        List<Requisition__c> PRList;
        try {
            if(prIdList.size() > 0) {
               if(Schema.sObjectType.Requisition__c.isAccessible()) PRList = Database.query('select ' + String.escapeSingleQuotes(PRFields) + ' ,Organisation__r.Name, Originating_Business_Unit__r.Name, '+
                     +' Requisitioned_By__r.Name, Cost_Centre__r.Name from Requisition__c where Id In: prIdList');
            } else {
               if(Schema.sObjectType.Requisition__c.isAccessible()) PRList = Database.query('select ' + String.escapeSingleQuotes(PRFields) + ' ,Organisation__r.Name, Originating_Business_Unit__r.Name, '+
                     +' Requisitioned_By__r.Name, Cost_Centre__r.Name from Requisition__c');
            } } catch(Exception e) { exceptionMethod(e, 'getPRList'); }   
        return PRList;        
    }
    
    /*
      method for fetching requisition line item list upon pr's
    */
    public List<Purchase_Requisition_Line_Items__c> getPRLIList(List<Id> prIdList) {  
         List<Purchase_Requisition_Line_Items__c> PRLIList;
        try {
            if(prIdList.size() > 0) {
                 if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.isAccessible()) PRLIList = Database.query('select ' + String.escapeSingleQuotes(PRLIFields) + ' ,Product__r.Name, Product__r.Issue_Purchase_Order__c, Purchase_Requisition__r.Name from Purchase_Requisition_Line_Items__c where Purchase_Requisition__c In: prIdList');
            } } catch(Exception e) { exceptionMethod(e, 'getPRLIList'); }   
        return PRLIList;
    }
    
    /*
      method for fetching purchase order line item upon PRLI's
    */
    public List<Purchase_Line_Items__c> getPOLIList(List<ID> prliIds) { 
        List<Purchase_Line_Items__c> poliList;
        try {
            if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.isAccessible())poliList = Database.query('select ' + String.escapeSingleQuotes(POLIFields) + ' ,Purchase_Orders__r.Name from Purchase_Line_Items__c where Purchase_Requisition_Line_Items__c In: prliIds');
        } catch(Exception e) { exceptionMethod(e, 'getPOLIList'); }   
        return poliList;
    }
    
    /*
      method for fetching sales orders list upon customer/salespoint/SalesOrder
    */
    public PageReference searchRequisition() {
         try {
            if(prlis.Purchase_Requisition__c == null && PR.Organisation__c == null) {
                errorMsg = System.Label.RequisitionToPurchaseOrder_ErrorMsg1;
            } else {
                errorMsg = '';
                if(prlis.Purchase_Requisition__c != null && PR.Organisation__c != null) {
                    if(Schema.sObjectType.Requisition__c.isAccessible())PRList = Database.query('select ' + String.escapeSingleQuotes(PRFields) + ' ,Organisation__r.Name, Originating_Business_Unit__r.Name, '+
                             +' Requisitioned_By__r.Name, Cost_Centre__r.Name from Requisition__c where '+
                             '(Id =\'' + String.escapeSingleQuotes(prlis.Purchase_Requisition__c) + '\' And Organisation__c =\'' + String.escapeSingleQuotes(PR.Organisation__c) + '\')');
                     
                    if(PRList.size() > 0) diplayPRList(JSON.serialize(PRList)); else errorMsg = System.Label.RequisitionToPurchaseOrder_ErrorMsg2;
                    
                } else if(prlis.Purchase_Requisition__c != null) {
                    if(Schema.sObjectType.Requisition__c.isAccessible())PRList = Database.query('select ' + String.escapeSingleQuotes(PRFields) + ' ,Organisation__r.Name, Originating_Business_Unit__r.Name, '+
                             +' Requisitioned_By__r.Name, Cost_Centre__r.Name from Requisition__c where '+
                             '(Id =\'' + String.escapeSingleQuotes(prlis.Purchase_Requisition__c) + '\')');
                     
                    if(PRList.size() > 0) diplayPRList(JSON.serialize(PRList)); else errorMsg = System.Label.RequisitionToPurchaseOrder_ErrorMsg2;
                    
                } else if(PR.Organisation__c != null) {
                    if(Schema.sObjectType.Requisition__c.isAccessible())PRList = Database.query('select ' + String.escapeSingleQuotes(PRFields) + ' ,Organisation__r.Name, Originating_Business_Unit__r.Name, '+
                             +' Requisitioned_By__r.Name, Cost_Centre__r.Name from Requisition__c where '+
                             '(Organisation__c =\'' + String.escapeSingleQuotes(PR.Organisation__c) + '\')');
                     
                    if(PRList.size() > 0) diplayPRList(JSON.serialize(PRList)); else errorMsg = System.Label.RequisitionToPurchaseOrder_ErrorMsg2;
                }
            }
        } catch(Exception e) { exceptionMethod(e, 'searchRequisition'); }   
        return null;
    }    
    /*
      method for displaying purchase requisition list upon customer / purchase requisition 
    */
    public void diplayPRList(String PRList1) {
        try {
            List<Requisition__c> PRList = (List<Requisition__c>)JSON.deserialize(PRList1, List<Requisition__c>.class);
            PRWrapList = new List<PRWrapper>();                     
            for(Requisition__c pr : PRList) { PRWrapper wrap = new PRWrapper(); wrap.prwrap = pr; PRWrapList.add(wrap); } 
        } catch(Exception e) { exceptionMethod(e, 'diplayPRList'); }   
    }
    
    /*
      method for fetching Single PR details and its corresponding PRLI list
    */
    public PageReference fetchSinglePRDetails() {
        try {
            errorMsg = '';
            if(flag) {
                prIdList = new List<Id>(); 
                if(prId != null) prIdList.add(prId);            
                if(prIdList.size() > 0) errorMsg = ''; diplayPRAndPRLIList(prIdList);        
            } else if(prliWrapMap.size() > 0) { for(String s : prliWrapMap.KeySet()) { if(prId == prliWrapMap.get(s).prliwrap.Purchase_Requisition__c) prliWrapMap.remove(s); } }
        } catch(Exception e) { exceptionMethod(e, 'fetchSinglePRDetails'); }   
        return null;
    }
        
    /*
      method for fetching multiple PR details and its respective PRLI list
    */
    public PageReference fetchMultiplePRDetails() {
        try {
             if(flag) {
                prIdList = new List<Id>();        
                if(PRWrapList.size() > 0) { for(PRWrapper wrap : PRWrapList) { if(wrap.prSelected == true) prIdList.add(wrap.prwrap.Id); } }                        
                if(prIdList.size() > 0) {  errorMsg = ''; diplayPRAndPRLIList(prIdList); } else errorMsg = System.Label.RequisitionToPurchaseOrder_ErrorMsg3;
               
            } else {
                prIdList = new List<Id>();
                prliWrapMap.clear();
                showPRLIPnl = false;
            }
        } catch(Exception e) { exceptionMethod(e, 'fetchMultiplePRDetails'); } 
        return null;
    }
    
    /*
      method invoked for displaying both SO & SOLI details
    */
    public void diplayPRAndPRLIList(List<Id> prIdList) {
        try {
            if(prIdList.size() > 0) {
                List<Requisition__c> prd = getPRList(prIdList);  
                PRLIList = getPRLIList(prIdList); 
                
                for(Purchase_Requisition_Line_Items__c prli : PRLIList) {
                    prliIds.add(prli.Id);
                }        
                if(prliIds.size() > 0) displayPRLILineItems(prliIds);            
                showPRLIPnl = true; 
            } 
        } catch(Exception e) { exceptionMethod(e, 'diplayPRAndPRLIList'); } 
    }
    
    /*
      method for displaying requisition line items and if existing purchase order line items
    */
    public void displayPRLILineItems(List<ID> prliIds){
        try {
            if(prliIds.size() > 0) poliItemList = getPOLIList(prliIds);
            List<Id> prlineitemIds = new List<Id>();
            for(Purchase_Line_Items__c p : poliItemList) {
                prlineitemIds.add(p.Purchase_Requisition_Line_Items__c);
            }
            for(Id prliId : prlineitemIds) {
                List<Purchase_Line_Items__c> myPoliList = new List<Purchase_Line_Items__c>();
                Boolean adding = false;
                for(Purchase_Line_Items__c poli : poliItemList) {
                    if(prliId == poli.Purchase_Requisition_Line_Items__c) {
                        myPoliList.add(poli);
                        adding = true;
                    }
                }                
                if(adding) poliMap.put(prliId, myPoliList);    
            }    
                
            if(PRLIList.size() > 0) {
                for(Purchase_Requisition_Line_Items__c prli : PRLIList) {
                    PRWrapper sw = new PRWrapper();
                    if(poliMap.KeySet().Contains(prli.Id)) {
                        sw.prliwrap = prli;
                        sw.prliwrapNew = prli;
                        sw.poliwrap = poliMap.get(prli.Id);
                        if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Quantity__c.isAccessible())sw.requestedQty = Integer.valueof(sw.prliwrapNew.Quantity__c);
                        sw.raisedQty = 0;
                        sw.requiredQty = 0;
                        for(Purchase_Line_Items__c p : sw.poliwrap) {
                            if(p.Quantity__c == sw.requestedQty) {
                                if(Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity__c.isAccessible())sw.raisedQty += Integer.valueof(p.Quantity__c);     
                                sw.prliwrapNew.Quantity__c = 0;
                            } else if(p.Quantity__c < sw.requestedQty) {
                                if(Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity__c.isAccessible())sw.raisedQty += Integer.valueof(p.Quantity__c); 
                                sw.requiredQty = sw.requestedQty - sw.raisedQty; sw.prliwrapNew.Quantity__c = sw.requiredQty;                                
                            }
                        }                        
                        sw.poName = 'POLI-'+prli.Product__r.Name;
                        if(prli.Is_Purchase_Order__c == true) { sw.poName = '-'; sw.status = 'Converted To Purchase Order'; } else sw.status = 'Draft';
                        
                        prliWrapMap.put(prli.Id,sw);
                        
                    } else if(prli.Product__r.Issue_Purchase_Order__c) {
                        sw.prliwrap = prli; sw.prliwrapNew = prli; sw.poName = 'POLI-'+prli.Product__r.Name;
                        sw.requestedQty = Integer.valueof(sw.prliwrapNew.Quantity__c); sw.requiredQty = Integer.valueof(sw.prliwrapNew.Quantity__c);
                        if(prli.Is_Purchase_Order__c == true) sw.status = 'Converted To Purchase Order'; else sw.status = 'Draft';
                        prliWrapMap.put(prli.Id,sw);
                    }                
                }
            } else errorMsg1 = System.Label.RequisitionToPurchaseOrder_ErrorMsg4;
        } catch(Exception e) { exceptionMethod(e, 'displayPRLILineItems'); } 
    }
    
    /*
      method for redirecting to next tab and populating selected PRLI's
    */
    public PageReference next() {
        try {
            Boolean proceed = true;
            if(prIdList.size() > 0) {
                errorMsg = '';
                selectedPRLIWrapSet = new Set<PRWrapper>();
                for(String s : prliWrapMap.KeySet()) {
                    if(prliWrapMap.get(s).prliwrapNew.Quantity__c > prliWrapMap.get(s).requestedQty) {
                        prliWrapMap.get(s).prliwrapNew.Quantity__c.addError('Required quantity cannot be greater than requested quantity ');
                        proceed = false; errorMsg2 = '';    
                    } else if(prliWrapMap.get(s).prliwrapNew.Quantity__c > prliWrapMap.get(s).requestedQty && prliWrapMap.get(s).prliSelected == true) {
                        prliWrapMap.get(s).prliwrap.Quantity__c.addError('Required quantity cannot be greater than requested quantity ');
                        proceed = false; errorMsg2 = '';
                    } else if(prliWrapMap.get(s).prliSelected == true && prliWrapMap.get(s).status == 'Draft') {
                        prliWrapMap.get(s).selectedQty = Integer.valueof(prliWrapMap.get(s).prliwrapNew.Quantity__c);
                        selectedPRLIWrapSet.add(prliWrapMap.get(s)); proceed = true; errorMsg2 = '';
                    }                    
                }
                if(proceed && selectedPRLIWrapSet.size() > 0) {
                    errorMsg = ''; CurrentTab ='tab2'; showTab2 = false; showNextBtn = false;
                    selectedPRLIWrapList.clear(); selectedPRLIWrapList.addAll(selectedPRLIWrapSet);            
                    
                    if(prList[0].Organisation__c != null) if(Schema.sObjectType.Requisition__c.fields.Organisation__c.isAccessible())poInstance.Organisation__c = prList[0].Organisation__c;
                    if(prList[0].Originating_Business_Unit__c != null) if(Schema.sObjectType.Requisition__c.fields.Originating_Business_Unit__c.isAccessible())poInstance.Organisation_Business_Unit__c = prList[0].Originating_Business_Unit__c;
                    if(prList[0].Originating_Business_Unit__c != null) if(Schema.sObjectType.Requisition__c.fields.Originating_Business_Unit__c.isAccessible())poInstance.Organisation_Business_Unit__c = prList[0].Originating_Business_Unit__c;
                    if(prList[0].Programme__c != null) if(Schema.sObjectType.Requisition__c.fields.Programme__c.isAccessible())poInstance.Programme__c = prList[0].Programme__c;
                    if(prList[0].Project__c != null) if(Schema.sObjectType.Requisition__c.fields.Project__c.isAccessible())poInstance.Project__c = prList[0].Project__c; 
                    if(prList[0].Delivery_Address__c != null) if(Schema.sObjectType.Requisition__c.fields.Delivery_Address__c.isAccessible())poInstance.Delivery_Address__c = prList[0].Delivery_Address__c;
                    if(prList[0].Expected_Delivery_Date__c != null) if(Schema.sObjectType.Requisition__c.fields.Expected_Delivery_Date__c.isAccessible())poInstance.Expected_Delivery_Date__c = prList[0].Expected_Delivery_Date__c;
                    if(prList[0].Actual_Delivery_Date__c != null) if(Schema.sObjectType.Requisition__c.fields.Actual_Delivery_Date__c.isAccessible())poInstance.Actual_Delivery_Date__c = prList[0].Actual_Delivery_Date__c; 
                    if(prList[0].Description__c != null) if(Schema.sObjectType.Requisition__c.fields.Description__c.isAccessible())poInstance.Description__c = prList[0].Description__c;
                    poInstance.Order_Date__c = System.Today();
                    poInstance.Publication_Date__c = System.Today();             
                } else errorMsg2 = System.Label.RequisitionToPurchaseOrder_ErrorMsg5; } else errorMsg = System.Label.RequisitionToPurchaseOrder_ErrorMsg6;          
        } catch(Exception e) { exceptionMethod(e, 'next'); } 
        return null;
    }
    
    /*
      method for converting PR to PO and redirecting to new PO detail page
    */
    public PageReference ConvertTOPO() {
        pageReference pg;
        try {
             Boolean flag = convertingPR2PODetails();        
            if(flag) {  pg = new pageReference('/'+poInstance.Id); pg.setRedirect(true); }        
        } catch(Exception e) { exceptionMethod(e, 'ConvertTOPO'); } 
        return pg;
    }
    
    /*
      method for creating multiple purchase orders
    */
    public PageReference saveAndNewPO() {
        PageReference page;
        try { 
             Boolean flag = convertingPR2PODetails();                
            if((requisitionId != null && requisitionId != '') && flag) {
                Page = new PageReference('/apex/RequisitionToPurchaseOrder'); page.getParameters().Put('prId', requisitionId);
                Page.setRedirect(true);
            } else if((requisitionId == null || requisitionId == '') && flag) {
                Page = new PageReference('/apex/RequisitionToPurchaseOrder'); Page.setRedirect(true);
            }        
        } catch(Exception e) { exceptionMethod(e, 'saveAndNewPO'); } 
        return page;
    }
    
    /*
      method invoked for converting single or multiple PR to PO details
    */
    public Boolean convertingPR2PODetails() {
        Boolean flag = false;
        try {
            selectedPRLIWrapperList = new List<PRWrapper>(); 
            
            if(poInstance.Name == null) {
                poInstance.Name.addError('Enter the value');
            } else {    
                if(singleView) {
                    for(String s : prliWrapMap.KeySet()) {
                        if(prliWrapMap.get(s).prliSelected == true) {
                            selectedPRLIWrapperList.add(prliWrapMap.get(s));                    
                            if(prliWrapMap.get(s).requiredQty == prliWrapMap.get(s).prliwrap.Quantity__c) {
                                if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Is_Purchase_Order__c.isCreateable() && Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Is_Purchase_Order__c.isUpdateable()) prliWrapMap.get(s).prliwrap.Is_Purchase_Order__c = true;                   
                                if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Quantity__c.isUpdateable()) prliWrapMap.get(s).prliwrap.Quantity__c = prliWrapMap.get(s).requestedQty;
                                updatePRLIList.add(prliWrapMap.get(s).prliwrap);
                            }
                        }
                    }
                } else if(selectedPRLIWrapList.size() > 0) {
                    for(PRWrapper sw : selectedPRLIWrapList) {
                        selectedPRLIWrapperList.add(sw);
                        if(sw.requiredQty == sw.prliwrap.Quantity__c) {
                            if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Is_Purchase_Order__c.isCreateable() && Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Is_Purchase_Order__c.isUpdateable()) sw.prliwrap.Is_Purchase_Order__c = true;                        
                            if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Quantity__c.isUpdateable()) sw.prliwrap.Quantity__c = sw.requestedQty;
                            updatePRLIList.add(sw.prliwrap);                        
                        }                                                
                    }
                }            
                
                if(selectedPRLIWrapperList.size() > 0) {
                    errorMsg1 = '';
                    if(poInstance != null) { if(Schema.sObjectType.ERP7__PO__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.isUpdateable()){ DMLManager.upsertAsUser(poInstance); } else{errorMsg1 = ' USer cannot upsert PO';}  }             
                    if(updatePRLIList.size() > 0) { if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.isCreateable() && Schema.sObjectType.Purchase_Requisition_Line_Items__c.isUpdateable()){ DMLManager.upsertAsUser(updatePRLIList); } else{errorMsg1 = ' USer cannot upsert PRLI'; } }
                    
                    for(PRWrapper sw : selectedPRLIWrapperList) {
                        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(); 
                        
                        if(sw.poName != null && Schema.sObjectType.Purchase_Line_Items__c.fields.Name.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Name.isUpdateable()) poli.Name = sw.poName;
                        if(sw.prliWrap.Product__c != null && Schema.sObjectType.Purchase_Line_Items__c.fields.Product__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Product__c.isUpdateable()) poli.Product__c = sw.prliWrap.Product__c;
                        if(sw.selectedQty != null && Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity__c.isUpdateable()) poli.Quantity__c = sw.selectedQty;
                        if(sw.selectedQty != null && Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity_Received__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity_Received__c.isUpdateable()) poli.Quantity_Received__c = sw.selectedQty;
                        if(poInstance.Id != null && Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Orders__c.isUpdateable()) poli.Purchase_Orders__c = poInstance.Id;
                        if(sw.prliWrap.Id != null && Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Requisition_Line_Items__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Requisition_Line_Items__c.isUpdateable()) poli.Purchase_Requisition_Line_Items__c = sw.prliWrap.Id;
                        if(sw.prliWrap.Purchase_Requisition__c != null && Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Requisitions__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Requisitions__c.isUpdateable()) poli.Purchase_Requisitions__c = sw.prliWrap.Purchase_Requisition__c;                    
                        
                        poliList2Insert.add(poli);
                    }
                    if(poliList2Insert.size() > 0) {
                        if(Schema.sObjectType.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.isUpdateable()) {DMLManager.upsertAsUser(poliList2Insert);}
                        else{ errorMsg1 = 'User is not allowed to  upsert Purchase Line items';}
                    }
                    flag = true;                                   
                } else errorMsg1 = System.Label.RequisitionToPurchaseOrder_ErrorMsg5;            
            }          
        } catch(Exception e) { exceptionMethod(e, 'convertingPR2PODetails'); } 
        return flag;
    }
    
    /*
      method for handling exceptions
    */
    public void exceptionMethod(Exception e, String methodName) {
        exceptionMsg = 'Inside ' + methodName +', '+ e.getTypeName() +', '+ e.getMessage() +', Line : '+ e.getLineNumber();
    }
        
    /*
      wrapper class for salesorder 
    */    
    public List<PRWrapper> PRWrapList                { get; set; } 
    public Map<Id, PRWrapper> prliWrapMap            { get; set; }
    public List<PRWrapper> selectedPRLIWrapperList   { get; set; } 
    
    public class PRWrapper {
        public String status                                   { get; set; }
        public String poName                                   { get; set; } 
        public Integer raisedQty                               { get; set; }
        public Integer requestedQty                            { get; set; }
        public Integer requiredQty                             { get; set; }
        public Integer selectedQty                             { get; set; }           
        public Boolean prSelected                              { get; set; }
        public Boolean prliSelected                            { get; set; }
        public Requisition__c prwrap                           { get; set; }           
        public List<Purchase_Line_Items__c> poliwrap           { get; set; }          
        public Purchase_Requisition_Line_Items__c prliwrap     { get; set; }   
        public Purchase_Requisition_Line_Items__c prliwrapNew  { get; set; }           
        
        public PRWrapper() {
            status = '';
            poName = '';
            raisedQty = 0;
            selectedQty = 0;
            requiredQty = 0;
            requestedQty = 0;
            prSelected = false;
            prliSelected = false;
            prwrap = new Requisition__c();
            poliwrap = new List<Purchase_Line_Items__c>();
            prliwrap = new Purchase_Requisition_Line_Items__c();
            prliwrapNew = new Purchase_Requisition_Line_Items__c();                        
        }
    }
}