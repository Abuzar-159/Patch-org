/*
* Changes made by - Syed Moin Pasha
* Date - 07th September 2021
* Reason - To display Tax percentage and Tax Amount in Create PO screen
* 
* Changes made by - Syed Moin Pasha
* Date - 18th October 2021
* Reason - To prevent to update of order date on managing the po.
* Code change - added && porders.ERP7__Order_Date__c == null in the if conditon in line 711
*
* Changes made by - Arshad
* Date - 02/02/23 
* Reason - for return PO validation not to exceed returned qty/create duplicates if already returned
* Code change - method - fetchPOandPOLIs,save_PurchaseOrder
* 
* Changes made by - Arshad
* Reason - added method getOrderItemsforDropShip
*
* CHanges made by - Arshad 04 Dec 2023
* Reason - to save po and save attachments together in same synchronous process
* code chande - save_PurchaseOrder, FileData
*
*/

global with sharing class CreatePO {
    global PO__c PO                                                    { get; set; }   global static Integer addRow                                       { get; set; }
    global Integer nextIdent                                           { get; set; }     
    global static Integer toDelIdent                                   { get; set; }        global List<Purchase_Line_Items__c> Polis                          { get; set; }  
    global List<ID> soIds;                                                  global List<Sales_Order_Line_Item__c> soliList                     { get; set; }                       global String SOLIFields                                           { get; set; }  global String retUrl                                               { get; set; }  global Boolean flag                                                { get; set; }   global Boolean sflag                                               { get; set; }  public set<Id> productsIds                                        { get; set; }
    global String SOID;
    public String CurrentChannel;
    global List<Id> getsoIds(){
        return soIds;
    }
    global void setsoIds(List<Id> s){
    }
    global String getSOID(){  
        return SOID;
    }
    global void setSOID(String s){
        SOID = '';    
    }
    
    global createPO() {
        /*try{ 


if(ApexPages.Currentpage().getParameters().get('retUrl') != null)
retUrl = String.escapeSingleQuotes(ApexPages.Currentpage().getParameters().get('retUrl'));
nextIdent =0;
flag=false;
sflag=false;
soIds = new List<ID>();
productsIds  = new set<Id>();
soliList = new List<Sales_Order_Line_Item__c>();
poliWrapperList = new List<newWrapper>();
List<Employees__c> empList = new List<Employees__c>();
empList = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
Organisation_Business_Unit__c
From Employees__c
Where Employee_User__c = : UserInfo.getUserId()
Order by CreatedDate Asc Limit 1];

if(empList.size() > 0)CurrentChannel = (empList[0].Channel__c != null)?empList[0].Channel__c:null;
PO = new PO__c(Status__c='New',Channel__c=CurrentChannel);  
if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible())
SOLIFields = UtilClass.selectStarFromSObject('Sales_Order_Line_Item__c');
UtilClass.FlSCheck(SOLIFields.split(',') ,'Sales_Order_Line_Item__c');
if(ApexPages.Currentpage().getParameters().get('Id') != null){
SOID = String.escapeSingleQuotes(ApexPages.Currentpage().getParameters().get('Id'));
init();
//populatePO();

}
/*if(ApexPages.Currentpage().getParameters().get('recordId') != null){
populateRMAPO();
} */
        //} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        
    }
    
    global void doInit(){
        
    } 
    global void init(){
        /*
try{
if(soId!= null) { 
flag=true;
String recordFilter = (ApexPages.Currentpage().getParameters().get('soli') != null)? ' AND Id =\''+ApexPages.Currentpage().getParameters().get('soli')+'\'':'';
if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible())
soliList = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' ,Sales_Order__r.Name, Sales_Order__r.Order_Date__c, Sales_Order__r.Account__r.Name, Sales_Order__r.Channel__c, '+
+'Product__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c, Sales_Order__r.Authorised__c from Sales_Order_Line_Item__c '+
+'where Sales_Order__c  =\''+String.escapeSingleQuotes(soId)+'\'' +String.escapeSingleQuotes(recordFilter)+ 'order by Sales_Order__c ASC');                       

}
if(soliList.size() > 0) {
for(Sales_Order_Line_Item__c solis: soliList) {newWrapper nwrap = new newWrapper(nextIdent++);
productsIds.add(solis.Product__c);
if(Schema.sObjectType.Purchase_Line_Items__c.fields.Active__c.isAccessible()) nwrap.poli.Active__c = true; if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible()) nwrap.poli.Product__c = solis.Product__c;
if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Quantity__c.isAccessible()){ nwrap.poli.Quantity__c = solis.Quantity__c;
nwrap.poli.ERP7__Unit_Price__c = solis.Base_Price__c;
//nwrap.poli.Total_Price__c = solis.Quantity__c * nwrap.poli.Unit_Price__c;
nwrap.poli.Total_Price__c = solis.Total_Price__c;
}
if(Schema.sObjectType.Product2.isAccessible() && Schema.sObjectType.Product2.fields.Name.isAccessible() && Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible()) nwrap.poli.Name = solis.Product__r.Name;
if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) nwrap.poli.Sales_Order_Line_Item__c = solis.Id;
if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible()) nwrap.poli.Sales_Order__c = solis.Sales_Order__c;
poliWrapperList.add(nwrap);
}
}
} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
*/
    }
    public PageReference TotalPriceCalculation(){
        /*
if(poliWrapperList != null && poliWrapperList.size()>0)
for(Integer i=0; i<poliWrapperList.size(); i++) {
poliWrapperList[i].poli.Total_Price__c = (((poliWrapperList[i].poli.Quantity__c != null)?poliWrapperList[i].poli.Quantity__c:0) * ((poliWrapperList[i].poli.Unit_Price__c != null)?poliWrapperList[i].poli.Unit_Price__c:0)).setScale(2);
}*/
        return null;
        
    }
    global PageReference back() {
        /* try{
if(retUrl != null) return new PageReference(retUrl);} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
return null;
PageReference pageRef = ApexPages.currentPage();
return new PageReference('javascript:window.close()');*/
        return null;
    } 
    public pageReference getUnitPriceByVendor(){
        /*
Map<String,Decimal> productID_Map2Cost = new Map<String,Decimal>();

if(PO != null && PO.Vendor__c != null && productsIds != null && productsIds.size()>0){
for(ERP7__Cost_Card__c temp :[SELECT Id,Cost__c,End_Date__c,Product__c FROM ERP7__Cost_Card__c Where Supplier__c =:PO.Vendor__c AND Product__c in : productsIds AND End_Date__c >= Today order by LastModifiedDate desc])
if(!productID_Map2Cost.containsKey(temp.Product__c))productID_Map2Cost.put(temp.Product__c,temp.cost__c);
}
if(poliWrapperList != null && poliWrapperList.size()>0)
for(Integer i=0; i<poliWrapperList.size(); i++) {
if(productID_Map2Cost != null && productID_Map2Cost.get(poliWrapperList[i].poli.Product__c) != null){
poliWrapperList[i].poli.Unit_Price__c = productID_Map2Cost.get(poliWrapperList[i].poli.Product__c);
poliWrapperList[i].poli.Total_Price__c = (((poliWrapperList[i].poli.Quantity__c != null)?poliWrapperList[i].poli.Quantity__c:0) * ((poliWrapperList[i].poli.Unit_Price__c != null)?poliWrapperList[i].poli.Unit_Price__c:0)).setScale(2);
}
}*/
        return null;
        
    }
    global PageReference addPoliWrapperRows() {
        //try{
        if(poliWrapperList == null)poliWrapperList = new List<newWrapper>();
        if(nextIdent == null)nextIdent=0;
        //for(Integer i=0; i<addRow; i++) { 
        poliWrapperList.add(new newWrapper(nextIdent++)); 
        //}
        // } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    global PageReference delPoliWrapperRow() {
        try{
            Integer delPos = -1;
            for(Integer i=0; i<poliWrapperList.size(); i++) {if (poliWrapperList[i].ident == toDelIdent) delPos = i;
                                                            }
            if (-1 != delPos) newWrapper poliDel = poliWrapperList.remove(delPos);} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    global PageReference savePO() {
        /*try{
if(PO != null) DMLManager.upsertAsUser(PO);       
Polis = new List<Purchase_Line_Items__c>(); 
for(newWrapper nwrp: poliWrapperList) {
Purchase_Line_Items__c poli = new Purchase_Line_Items__c();
poli = nwrp.poli;
if(Schema.sObjectType.PO__c.isAccessible()) poli.Purchase_Orders__c = PO.Id;Polis.add(poli);
}
}
catch(exception ex){}
if(Polis.size() > 0) DMLManager.upsertAsUser(Polis); 
if(retUrl != null)return new PageReference(retUrl);else return new PageReference('/'+PO.Id);} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
*/return null;
    }
    
    /*public void populatePO(){ 
ERP7__Sales_Order__c SO = [Select Id, Name, ERP7__Account__c, ERP7__Contact__c, ERP7__Active__c, ERP7__Employees__c, 
ERP7__Order_Profile__c, ERP7__Expected_Date__c, ERP7__Bill_To_Address__c, ERP7__Order_Date__c, ERP7__Status__c, ERP7__Description__c from ERP7__Sales_Order__c
where Id=:SOID];
PO.Order_Date__c = SO.ERP7__Order_Date__c.date();
PO.Vendor_Address__c = SO.ERP7__Bill_To_Address__c;
PO.EmployeeRequester__c = SO.ERP7__Employees__c;
PO.Expected_Date__c = SO.ERP7__Expected_Date__c;
PO.Status__c = SO.ERP7__Status__c;
PO.Description__c = SO.ERP7__Description__c;

}*/
    @AuraEnabled public String channel {get; set;}
    @AuraEnabled public ERP7__Distribution_Channel__c distributionChannel {get; set;}
    @AuraEnabled public Account OrgAcc {get; set;}
    @AuraEnabled public Boolean salesAccess {get; set;}
    @AuraEnabled public String SOID1 {get; set;} 
    @AuraEnabled public Boolean paymnetAccess {get; set;} 
    @AuraEnabled public Boolean VenAccess {get; set;}
    @AuraEnabled public Boolean POLINameAcc {get; set;}
    @AuraEnabled public Boolean TaxAccess {get; set;}
    @AuraEnabled public Boolean AllocationAccess {get; set;}
    @AuraEnabled public Boolean displayVPO {get; set;}
    @AuraEnabled public Boolean TaxRate {get; set;}
    @AuraEnabled public Boolean packageType {get; set;}
    @AuraEnabled public Boolean displayName {get; set;}
    @AuraEnabled public Boolean versionAccess {get; set;}
    @AuraEnabled public Boolean QuoteAccess {get; set;}
    @AuraEnabled public Boolean hideRemove   {get; set;}
    @AuraEnabled public Boolean showOrg   {get; set;}
    @AuraEnabled public Boolean showDCbelow   {get; set;}
    @AuraEnabled public Boolean showReceive   {get; set;}
    @AuraEnabled public Boolean showUpload    {get; set;}
    @AuraEnabled public Boolean dontDefault   {get; set;}
    @AuraEnabled public Boolean skipTypeSelection   {get; set;}
    @AuraEnabled public Boolean ProjectOnPOScreen   {get; set;}
    @AuraEnabled public Boolean DepartmentOnPOScreen   {get; set;}
    @AuraEnabled public Boolean allowCustomProds  {get; set;}
    @AuraEnabled public Id AccountRectype {get; set;}
    @AuraEnabled public Id ContactRectype {get; set;}
    @AuraEnabled public ERP7__Address__c BillAdd {get; set;}
    @AuraEnabled public String  deliveryAdd {get; set;}
    @AuraEnabled public Boolean VendorAddRequired {get; set;}
    @AuraEnabled public Boolean VendorContactRequired {get; set;}
    @AuraEnabled public Boolean DCRequired         {get; set;}
    @AuraEnabled
    public static String uploadFile(String parent, String fileName, String base64Data, String contentType) { 
        system.debug('uploadFile-->');
        try{  base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');  Attachment a = new Attachment();  a.parentId = parent; a.Body = EncodingUtil.base64Decode(base64Data);  a.Name = fileName; a.ContentType = contentType; if(Schema.SObjectType.Attachment.isCreateable()){ system.debug('Attachment-->'+a); insert a; } else{ } return 'Success'; } catch(Exception e) { system.debug('Error:'+e.getMessage()+' Line:'+e.getLineNumber()); String exc=Json.serialize(e); return exc; }
        
    }
    @AuraEnabled
    public static String getFiles(String recId){
        if(recId != null && recId != ''){            List<Attachment> attchlist = [SELECT Id, Name, ParentId,Body FROM Attachment WHERE ParentId=:recId];
            if(attchlist.size() > 0) return JSON.serialize(attchlist);
            else return null;
        }else return null;
    }
     
    //Added by parveez on 16-Nov-23 for cloning the Attachment from the source PO.
    @AuraEnabled
    public static String cloneAttachment(String recId,List<Id> attachmentIds){ 
        try{
            if(recId != null && recId != ''){
                
                List<Attachment> clonedAttachments = new List<Attachment>();                List<Attachment> originalAttach = [SELECT Id, ParentId, Name, Body FROM Attachment WHERE Id IN:attachmentIds];
                if(originalAttach.size() > 0) {
                    
                    for (Attachment orgAttach : originalAttach) {
                        
                        Attachment clonedAttachment = new Attachment();                        clonedAttachment.ParentId = recId;                        clonedAttachment.Name = orgAttach.Name;                        clonedAttachment.Body = orgAttach.Body;                        clonedAttachments.add(clonedAttachment);
                        
                    }
                    insert clonedAttachments;
                }
            }
        }
        catch(Exception e) { system.debug('Error:'+e.getMessage()+' Line:'+e.getLineNumber()); }
        return null;
    }
    
    @AuraEnabled
    public static List<Attachment> DeleteAttachment(String attachId,String parentId){ try{ List<Attachment> Attachments = new List<Attachment>(); Attachment attach2del = new Attachment(); if(String.isNotEmpty(attachId)){ attach2del = [Select Id, Name, ParentId from Attachment where Id =: attachId AND ParentId != null]; if(attach2del.Id != null){ delete attach2del; } } if(String.isNotEmpty(parentId)) Attachments = [Select Id, Name, ParentId from Attachment where ParentId =:parentId Order By CreatedDate ASC]; return Attachments; } catch(Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } }
    
    
    @AuraEnabled
    public static ERP7__Distribution_Channel__c getDC(String DC){
        if(DC != null && DC != ''){
            List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.ERP7__Address__c,ERP7__Active__c from ERP7__Distribution_Channel__c
                                                          where Id=:DC and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
            if(dcList.size() > 0) return dcList[0];
        }
        else return null;
        return null;
    }
    
    @AuraEnabled
    public static ERP7__Address__c getCust(String customer){
        if(customer != null && customer != ''){
            List<ERP7__Address__c> addList = [Select Id, Name from ERP7__Address__c where ERP7__Customer__c =:customer and ERP7__Active__c = true 
                                              and ERP7__Is_Shipping_Address__c = true and ERP7__Primary__c = true order by CreatedDate ASC limit 1];
            if(addList.size() > 0) return addList[0];
            else return null;
        }
        else return null;
        
    }
    
    @AuraEnabled
    public static ERP7__Address__c getVendorAddress(String vendor){
        if(vendor != null && vendor != ''){
            List<ERP7__Address__c> addList = [Select Id, Name from ERP7__Address__c
                                              where ERP7__Customer__c=:vendor and ERP7__Active__c=true order by CreatedDate ASC limit 1];
            if(addList.size() > 0) return addList[0];
        }
        else return null;
        return null;
    }
    
    @AuraEnabled
    public static Id ContactRecordTypess(){		String conRectypeName = System.Label.Contact_Record_Name;			system.debug('conRectypeName : '+conRectypeName);			Id ConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(conRectypeName).getRecordTypeId();      return ConRecordTypeId;
    }
    
    @AuraEnabled
    public static CreatePO fetchChannelandDC(String OId,String SOLIId){
        
        /*'OId : '+OId*/
        CreatePO CP = new CreatePO();
        String RectypeName = System.Label.Account_Record_Name;
        system.debug('RectypeName : '+RectypeName);
        String conRectypeName = System.Label.Contact_Record_Name;
        system.debug('conRectypeName : '+conRectypeName);
        Id ConRecordTypeId;
        Id devRecordTypeId;
        
        if(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RectypeName).getRecordTypeId() != null) devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RectypeName).getRecordTypeId();
        if(Schema.SObjectType.Contact.getRecordTypeInfosByName().get(conRectypeName) != null) ConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(conRectypeName).getRecordTypeId();
        
        if(devRecordTypeId != null) CP.AccountRectype = devRecordTypeId;
        if(ConRecordTypeId != null) CP.ContactRectype = ConRecordTypeId;
        
        try{
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            if(empList.size()>0 && empList != null){
                CP.channel = empList[0].ERP7__Channel__c;
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.ERP7__Address__c,ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                /*fetchChannelandDC dcList is :'+dcList.size()*/
                if(dcList.size()>0 && dcList != null){
                    CP.distributionChannel = dcList[0];
                    CP.deliveryAdd = dcList[0].ERP7__Site__r.ERP7__Address__c;
                } 
                
            }
            List<ERP7__Address__c> billing  = new List<ERP7__Address__c>();
            // if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Active__c.isAccessible())  { CP.salesAccess = true; } else { CP.salesAccess = false; }
            if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Payment_Terms__c.isAccessible())  { CP.paymnetAccess = true; } else { CP.paymnetAccess = false; } 
            if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Vendor_product_Name__c.isAccessible()) { CP.VenAccess = true; } else { CP.VenAccess = false; }
            /* Visibility Control */
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){ 
                CP.AllocationAccess = FC.ERP7__Allocation_Process__c; CP.POLINameAcc=FC.ERP7__Show_product_code_PO__c; CP.hideRemove = FC.ERP7__Restrict_Selected_Channel__c; CP.showOrg = FC.ERP7__Show_PO_Organisation__c;  CP.showDCbelow = FC.ERP7__Show_DC_below__c;  CP.showReceive = FC.ERP7__Show_Receive_on_PO__c; CP.dontDefault = FC.ERP7__dont_default_dc__c;CP.VendorAddRequired = FC.ERP7__Po_Screen_Vendor_Address_Required__c; 
                CP.salesAccess = FC.ERP7__Is_Standard_Order__c;
                if(FC.ERP7__don_t_show_version_in_create_PO__c) CP.versionAccess = false; // changed the version visibility from field to custom settings FC
                else CP.versionAccess = true;
                if(FC.ERP7__PO_screen_Vendor_Contact_Not_Required__c) {
                    CP.VendorContactRequired = false;
                }else CP.VendorContactRequired = true;
                
                if(FC.ERP7__DC_not_required__c){
                    CP.DCRequired = false; 
                }else  CP.DCRequired = true; 
            }
            if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Tax__c.isAccessible()) { CP.TaxAccess = true; } else { CP.TaxAccess = false; }
            if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Tax_Rate__c.isAccessible()) { CP.TaxRate = true; } else { CP.TaxRate = false; }
            //if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Version__c.isAccessible()) { CP.versionAccess = true; } else { CP.versionAccess = false; }
            if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Quote_no__c.isAccessible()) { CP.QuoteAccess = true; } else { CP.QuoteAccess = false; }
            if(OId != ''){
                Order ord = [Select Id , Name , ERP7__Organisation__c , ERP7__Bill_To_Address__c ,ERP7__Contact__c,ERP7__Organisation_Business_Unit__c from Order where Id=:OId Limit 1];
                Account acc = [Select Id , Name   from Account Where Id=:ord.ERP7__Organisation__c limit 1];  CP.OrgAcc = acc;
                billing = [Select Id,Name from ERP7__Address__c where ERP7__Customer__c=:acc.Id and ERP7__Is_Billing_Address__c = true limit 1];
            } 
            else{
                Account acc = [Select Id , Name   from Account Where Id=:empList[0].ERP7__Channel__r.ERP7__Organisation__c limit 1]; CP.OrgAcc = acc;
                billing = [Select Id,Name from ERP7__Address__c where ERP7__Customer__c=:acc.Id and ERP7__Is_Billing_Address__c = true limit 1];
            }
            
            if(SOLIId != '' && SOLIId != null){
                ERP7__Sales_Order_Line_Item__c solilist = [Select Id,ERP7__Sales_Order__c ,Name From ERP7__Sales_Order_Line_Item__c where Id=:SOLIId];  if(solilist != null ) CP.SOID1 = solilist.ERP7__Sales_Order__c;
            }
            if(billing.size() > 0) CP.BillAdd = billing[0];
        }
        catch(Exception e){
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
        return CP;
    }
    
    @AuraEnabled 
    public static Boolean getFCdetails(){
        ERP7__Functionality_Control__c   FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ 
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
        }
        system.debug('FC : '+FC);
        if(FC != null){
            system.debug('FC product code: '+FC.ERP7__Show_product_code_PO__c);
            return FC.ERP7__Show_product_code_PO__c;
        }
        else return null;
    }
    /* @AuraEnabled
public static CreatePO fetchDoInit(){
CreatePO cpo = new CreatePO();
List<ERP7__Employees__c> emp = [Select Id,Channel__C FROM ERP7__Employees__c  Where ERP7__Employee_User__c  =:userinfo.getUserId()];
if(emp != null && emp.size()>0){
cpo.ChannelId = emp[0].Channel__c;
List<ERP7__Distribution_Channel__c> dc_list = [SELECT Id,Name,ERP7__Channel__c,ERP7__Site__c ,ERP7__Site__r.Name, ERP7__Site__r.ERP7__Address__c,ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line1__c,ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line2__c,ERP7__Site__r.ERP7__Address__r.ERP7__City__c,ERP7__Site__r.ERP7__Address__r.ERP7__State__c,ERP7__Site__r.ERP7__Address__r.ERP7__Postal_Code__c,ERP7__Site__r.ERP7__Address__r.ERP7__Country__c FROM ERP7__Distribution_Channel__c Where ERP7__Channel__c =: emp[0].Channel__c AND ERP7__Active__c = true AND ERP7__Site__c != null order by ERP7__Priority__c limit 1];
if(dc_list !=null && dc_list.size()>0) cpo.distributionchannel =dc_list[0]; 
}
return cpo;   

}

@AuraEnabled
public static String getSiteDetails(String recordId){
List<ERP7__Site__c> siteList = new List<ERP7__Site__c>(); if(String.isNotEmpty(recordId)) siteList = [SELECT Id,ERP7__Address__c FROM ERP7__Site__c Where Id=:recordId]; return (siteList.size()>0)? siteList[0].ERP7__Address__c:'';
}
@AuraEnabled
public static ERP7__Distribution_Channel__c getSiteDetailsbyDC(String recordId){
List<ERP7__Distribution_Channel__c> dcList = new List<ERP7__Distribution_Channel__c>(); if(String.isNotEmpty(recordId)) dcList = [SELECT Id,Name,ERP7__Channel__c,ERP7__Site__c ,ERP7__Site__r.Name FROM ERP7__Distribution_Channel__c Where Id =:recordId]; return (dcList.size()>0)? dcList[0]:null;
}
*/
    
    @AuraEnabled
    public static Order getOrderAddress(String orderId){
        if(orderId != null && orderId != ''){
            Order myorder = [Select Id, Name, ERP7__Ship_To_Address__c, ERP7__Ship_From_Address__c, ERP7__Bill_To_Address__c,AccountId from Order where Id =:orderId];
            return myorder;
        }
        return null;
    }
    
    // Changes made by Shaguftha on 14/07/2023 to fetch the products that are marked as Purchase from approved vendor and has the approved vendor with the selected vendor
    @AuraEnabled
    public static POWrapper getOrderItemsforPOLIDropShip(String orderId,String vendId,String venAdd){
        system.debug('getOrderItemsforPOLIDropShip orderId is :'+orderId);
        POWrapper poWrap = new POWrapper();
        List<OrderItem> ordItemList=new List<OrderItem>();
        List<ERP7__Purchase_Line_Items__c> prliList=new List<ERP7__Purchase_Line_Items__c>();
        List<ProductStock> prodlst = new List<ProductStock>();
        if(orderId != null && orderId != ''){
            ordItemList = [SELECT Id, ERP7__Total_Price__c, ERP7__All_Total_Price__c, Product2.ERP7__Purchase_From_Approved_Vendor__c,Product2.ERP7__Purchase_Lead_Time_days__c, Product2.Description, Product2Id, Product2.Name, ERP7__VAT_Percentage__c, UnitPrice, Product2.ERP7__Track_Inventory__c, Product2.ERP7__Is_Kit__c, Quantity, ERP7__Base_Price__c, ERP7__VAT_Amount__c, ERP7__Discount_Amount__c,
                           OrderItemNumber,OrderId,Order.Name, Order.ERP7__Ready_To_Pick_Pack__c, ERP7__Site__c, ERP7__Active__c, ERP7__Logistic_Quantity__c,ERP7__Version__c,ERP7__Inventory_Tracked__c,ERP7__Is_Kit__c,ERP7__PriceBookId__c, Product2.ERP7__Vendor_product_Name__c,
                           ERP7__Picked_Quantity__c, ERP7__Packed_Quantity__c, ERP7__Shipped_Quantity__c, ERP7__Reserved_Quantity__c,ERP7__Remaining_Quantity__c 
                           FROM OrderItem WHERE OrderId=:orderId AND Product2Id != Null AND Product2.ERP7__Issue_Purchase_Order__c = true AND Quantity > 0];
            set<Id> approvedVendorProds = new set<Id>();
            for(OrderItem ordItem :ordItemList){
                if(ordItem.Product2.ERP7__Purchase_From_Approved_Vendor__c) approvedVendorProds.add(ordItem.Product2Id);
            }
            System.debug('ordItemList is :'+ordItemList.size());
            Map<Id,ERP7__Approved_Vendor__c> productApprovedVendor = new Map<Id,ERP7__Approved_Vendor__c>();
            if(approvedVendorProds.size() > 0 && vendId != null && vendId != ''){
                List<ERP7__Approved_Vendor__c> approvedVendorLst = [Select Id,Name,ERP7__Vendor__c,ERP7__Product__c,ERP7__Cost_Card__c,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Cost_Card__r.ERP7__Start_Date__c,ERP7__Cost_Card__r.ERP7__End_Date__c,ERP7__Cost_Card__r.ERP7__Active__c,ERP7__Cost_Card__r.ERP7__Supplier__c from ERP7__Approved_Vendor__c where ERP7__Vendor__c=:vendId and ERP7__Product__c IN :approvedVendorProds and ERP7__Status__c=:'Approved' ];
                if(approvedVendorLst.size() > 0){
                    for(ERP7__Approved_Vendor__c appVen : approvedVendorLst){
                        if(!productApprovedVendor.containsKey(appVen.ERP7__Product__c)) productApprovedVendor.put(appVen.ERP7__Product__c,appVen);
                    }
                }
            }
            Decimal taxRate = 0;
            if(venAdd != '' && venAdd != null){
                taxRate = checkforTax(venAdd,vendId);
            }
            
            system.debug('taxRate from checkforTax set here1~>'+taxRate);
            
            for(OrderItem ordItem :ordItemList){
                if(ordItem.Product2.ERP7__Purchase_From_Approved_Vendor__c){
                    system.debug('productApprovedVendor.containsKey(ordItem.Product2Id) : '+productApprovedVendor.containsKey(ordItem.Product2Id));
                    if(productApprovedVendor.containsKey(ordItem.Product2Id)) {
                        ERP7__Purchase_Line_Items__c prli=new ERP7__Purchase_Line_Items__c();                        Decimal qty = ordItem.Quantity;                        Decimal logqty = (ordItem.ERP7__Logistic_Quantity__c > 0) ? ordItem.ERP7__Logistic_Quantity__c : 0;
                        
                        prli.Name = ordItem.Product2.Name;                         prli.ERP7__Product__c = ordItem.Product2Id;
                        prli.ERP7__Product__r = new Product2(Id=ordItem.Product2Id,Name=ordItem.Product2.Name,ERP7__Vendor_product_Name__c=ordItem.Product2.ERP7__Vendor_product_Name__c);                        prli.ERP7__Quantity__c = qty - logqty;                        prli.ERP7__Order__c = ordItem.OrderId;                        prli.ERP7__Order_Product__c=ordItem.Id;                        prli.ERP7__Vendor_product_Name__c = ordItem.Product2.ERP7__Vendor_product_Name__c;
                        //Moin commented this on 07th july 2023
                        //prli.ERP7__Unit_Price__c = (ordItem.UnitPrice > 0) ? ordItem.UnitPrice : 0;
                        if(productApprovedVendor.get(ordItem.Product2Id).ERP7__Cost_Card__c != null){
                            prli.ERP7__Cost_Card__c  = productApprovedVendor.get(ordItem.Product2Id).ERP7__Cost_Card__c;
                            prli.ERP7__Unit_Price__c = (productApprovedVendor.get(ordItem.Product2Id).ERP7__Cost_Card__r.ERP7__Cost__c > 0 && productApprovedVendor.get(ordItem.Product2Id).ERP7__Cost_Card__r.ERP7__Start_Date__c <= System.today() &&  productApprovedVendor.get(ordItem.Product2Id).ERP7__Cost_Card__r.ERP7__End_Date__c >= system.today()) ? productApprovedVendor.get(ordItem.Product2Id).ERP7__Cost_Card__r.ERP7__Cost__c : 0.0;
                            prli.ERP7__Total_Price__c = prli.ERP7__Unit_Price__c * prli.ERP7__Quantity__c;
                        }
                        else{
                            prli.ERP7__Unit_Price__c = 0.00;                            prli.ERP7__Total_Price__c = 0;
                        }
                        if(taxRate > 0){                            prli.ERP7__Tax_Rate__c = taxRate;
                            system.debug('prli.ERP7__Tax_Rate__c  : '+prli.ERP7__Tax_Rate__c );
                            if(prli.ERP7__Tax_Rate__c > 0){                                decimal tax = (prli.ERP7__Unit_Price__c /100) * prli.ERP7__Tax_Rate__c;                                tax = tax * prli.ERP7__Quantity__c;                                prli.ERP7__Tax__c = tax;                                prli.ERP7__Total_Price__c = prli.ERP7__Total_Price__c + tax;
                            }
                            
                        }
                        else{                            prli.ERP7__Tax_Rate__c = 0;                             prli.ERP7__Tax__c = 0;
                        }
                        
                        //prli.ERP7__Tax_Rate__c = (ordItem.ERP7__VAT_Percentage__c > 0) ? ordItem.ERP7__VAT_Percentage__c : 0;
                        
                        //prli.ERP7__Tax__c = (ordItem.ERP7__VAT_Amount__c > 0) ? ordItem.ERP7__VAT_Amount__c : 0;
                        
                        //prli.ERP7__Total_Price__c = (ordItem.ERP7__All_Total_Price__c > 0) ? ordItem.ERP7__All_Total_Price__c : 0;
                        prli.ERP7__Description__c = ordItem.Product2.Description;                        prli.ERP7__Lead_Time_Days__c = ordItem.Product2.ERP7__Purchase_Lead_Time_days__c;                        prliList.add(prli);   
                    }
                } 
                else{
                    ERP7__Purchase_Line_Items__c prli=new ERP7__Purchase_Line_Items__c();
                    Decimal qty = ordItem.Quantity;
                    Decimal logqty = (ordItem.ERP7__Logistic_Quantity__c > 0) ? ordItem.ERP7__Logistic_Quantity__c : 0;
                    
                    prli.Name = ordItem.Product2.Name; 
                    prli.ERP7__Product__c = ordItem.Product2Id;
                    prli.ERP7__Product__r = new Product2(Id=ordItem.Product2Id,Name=ordItem.Product2.Name,ERP7__Vendor_product_Name__c=ordItem.Product2.ERP7__Vendor_product_Name__c);
                    prli.ERP7__Quantity__c = qty - logqty;
                    prli.ERP7__Order__c = ordItem.OrderId;  
                    prli.ERP7__Order_Product__c=ordItem.Id;
                    prli.ERP7__Vendor_product_Name__c = ordItem.Product2.ERP7__Vendor_product_Name__c;
                    
                    
                    prli.ERP7__Unit_Price__c = 0.00;
                    prli.ERP7__Total_Price__c = 0;
                    if(taxRate > 0){
                        prli.ERP7__Tax_Rate__c = taxRate;
                        system.debug('prli.ERP7__Tax_Rate__c  : '+prli.ERP7__Tax_Rate__c );
                        if(prli.ERP7__Tax_Rate__c > 0){                            decimal tax = (prli.ERP7__Unit_Price__c  > 0) ? (prli.ERP7__Unit_Price__c /100) * prli.ERP7__Tax_Rate__c : 0;
                            tax = tax * prli.ERP7__Quantity__c;                            prli.ERP7__Tax__c = tax;                            prli.ERP7__Total_Price__c = prli.ERP7__Total_Price__c + tax;
                        }
                        
                    }
                    else{
                        prli.ERP7__Tax_Rate__c = 0;
                        prli.ERP7__Tax__c = 0;
                    }
                    
                    //prli.ERP7__Tax_Rate__c = (ordItem.ERP7__VAT_Percentage__c > 0) ? ordItem.ERP7__VAT_Percentage__c : 0;
                    
                    //prli.ERP7__Tax__c = (ordItem.ERP7__VAT_Amount__c > 0) ? ordItem.ERP7__VAT_Amount__c : 0;
                    
                    //prli.ERP7__Total_Price__c = (ordItem.ERP7__All_Total_Price__c > 0) ? ordItem.ERP7__All_Total_Price__c : 0;
                    prli.ERP7__Description__c = ordItem.Product2.Description;
                    prli.ERP7__Lead_Time_Days__c = ordItem.Product2.ERP7__Purchase_Lead_Time_days__c;
                    prliList.add(prli);  
                }
                
            }
            
            if(prliList.size() > 0){
                poWrap.wPOLIs =  prliList;
                set <Id> siteIds = new set <Id>(); 
                set <Id> prodIds = new set <Id>(); 
                
                for(ERP7__Purchase_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
                
                List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c Where product__c In: prodIds And Active__c = true  and (ERP7__No_of_Items_Requested__c > 0 or Number_of_Item_In_Stock__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)]; // And Warehouse__c In: siteIds 
                for(Id ProductId : prodIds){
                    Decimal demand = 0.0;  Decimal myStock = 0.0;  Decimal Awaitingstock = 0.0;
                    ProductStock pr = new ProductStock();
                    for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                        if(ProductId == WIIS.product__c){                            demand+=WIIS.ERP7__No_of_Items_Requested__c;                            myStock += WIIS.Number_of_Item_In_Stock__c;                            Awaitingstock+=WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                        }
                    }
                    
                    pr.Product = ProductId;
                    pr.Demand = demand;
                    pr.Stock = myStock;
                    pr.AwaitingStocks=Awaitingstock;
                    prodlst.add(pr);
                }
            }
            
            poWrap.productStocks = prodlst;
        }
        return poWrap;
    }
    
    @AuraEnabled
    public static POWrapper populateOrdItems(List<String> orderId1){
        system.debug('populateOrdItems orderId is :'+orderId1);
        POWrapper poWrap = new POWrapper();
        List<OrderItem> ordItemList=new List<OrderItem>();
        //ERP7__Sales_Order_Line_Item__c SOLI;
        List<ERP7__Purchase_Line_Items__c> prliList=new List<ERP7__Purchase_Line_Items__c>();
        Decimal Qty = 0;
        if(!orderId1.isEmpty()){
            ordItemList = [Select Id, Product2Id, Product2.Name, Quantity, OrderId,UnitPrice,Product2.ERP7__Vendor_product_Name__c,
                           ERP7__Total_Price__c, ERP7__PriceBook_Base_Price__c, Description, ERP7__Base_Price__c from OrderItem where OrderId IN :orderId1 and ERP7__Is_Back_Order__c = true];
            /*ordItemList is :'+ordItemList*/
            
            for(OrderItem ordItem:ordItemList){
                ERP7__Purchase_Line_Items__c prli=new ERP7__Purchase_Line_Items__c();
                prli.Name=ordItem.Id;
                prli.ERP7__Product__c=ordItem.Product2Id;
                prli.ERP7__Product__r=new Product2(Id=ordItem.Product2Id,Name=ordItem.Product2.Name,ERP7__Vendor_product_Name__c=ordItem.Product2.ERP7__Vendor_product_Name__c);
                prli.Quantity__c = ordItem.Quantity;
                prli.ERP7__Order__c=ordItem.OrderId;  
                prli.ERP7__Order_Product__c=ordItem.Id;
                prliList.add(prli);
            }
            
            list<ERP7__PO__c> POList=new list<ERP7__PO__c>();  
            POList=[SELECT Id, Name, ERP7__Order__c, ERP7__Active__c FROM ERP7__PO__c WHERE ERP7__Order__c=:orderId1 AND ERP7__Active__c=true];
            set<String> POIds=new set<String>();      
            for(ERP7__PO__c s:POList) POIds.add(s.Id);
            
            
            list<ERP7__Purchase_Line_Items__c> POLIList=new list<ERP7__Purchase_Line_Items__c>();  
            POLIList=[SELECT Id, Name, ERP7__Order_Product__c,ERP7__Quantity__c,ERP7__Product__c,ERP7__Lead_Time_Days__c FROM ERP7__Purchase_Line_Items__c
                      WHERE ERP7__Purchase_Orders__c IN:POIds AND ERP7__Product__c!=Null]; //ERP7__Sales_Order_Line_Item__c IN:SoliIds  
            // Map < Id, decimal > Prod_Quantity = new Map < Id, decimal > ();
            //for(ERP7__Purchase_Requisition_Line_Items__c pr :ReqLIList ) Prod_Quantity.put(pr.ERP7__Product__c,pr.ERP7__Quantity__c);
            
            //set<String> POLIIds=new set<String>();      
            //  for(ERP7__Purchase_Line_Items__c s:POLIList) POLIIds.add(s.Id);
            Map<String,Decimal> proQuanMap=new Map<String,Decimal>();
            Set<Id> proIds=new Set<Id>();
            for(ERP7__Purchase_Line_Items__c pr :POLIList ){ proIds.add(pr.ERP7__Product__c); }
            
            for(Id pro:proIds){                Decimal quantity=0;
                for(ERP7__Purchase_Line_Items__c pr :POLIList ){                    if(pro == pr.ERP7__Product__c){ quantity+=pr.ERP7__Quantity__c;}
                }
                proQuanMap.put(pro,quantity);
            }
            
            Map<String,Decimal> OrdproQuanMap=new Map<String,Decimal>();
            
            for(Id prod:proIds){                Decimal quantityOrd=0;
                for(OrderItem orp :ordItemList ){
                    if(prod == orp.Product2Id){ quantityOrd+=orp.Quantity; }
                }
                OrdproQuanMap.put(prod,quantityOrd);
            }
            
            Map<String,Decimal> ReqproQuanMap=new Map<String,Decimal>();
            
            for(String OrdMap : OrdproQuanMap.keySet()){                Decimal finalQty = 0 ;
                for(String Req :  proQuanMap.keySet()){
                    if(OrdMap == Req) {                        finalQty= OrdproQuanMap.get(OrdMap) - proQuanMap.get(Req);
                        /*finalQty : '+finalQty*/
                    }
                } 
                ReqproQuanMap.put(OrdMap,finalQty);  
            }
            /* for(String finalQ : ReqproQuanMap.keySet()){
if(ReqproQuanMap.get(finalQ))
}*/
            for(Integer i=0; i<prliList.size(); i++){
                for(String finalQ : ReqproQuanMap.keySet()){
                    if((finalQ == prliList[i].ERP7__Product__c) && (ReqproQuanMap.get(finalQ) != prliList[i].ERP7__Quantity__c) && (prliList[i].ERP7__Quantity__c != 0)){                        prliList[i].ERP7__Quantity__c = ReqproQuanMap.get(finalQ);
                    }
                    if((finalQ == prliList[i].ERP7__Product__c) && (prliList[i].ERP7__Quantity__c == 0)) prliList.remove(i); 
                }
            }
            /*  for(Integer i=0; i<ordItemList.size(); i++){              
for(Integer j=0 ;j<POLIList.size(); j++){ 
if((ordItemList[i].Product2Id==POLIList[j].ERP7__Product__c)&& (ordItemList[i].Quantity==POLIList[j].ERP7__Quantity__c)){ break;}

if((ordItemList[i].Product2Id==POLIList[j].ERP7__Product__c)&&(ordItemList[i].Quantity>POLIList[j].ERP7__Quantity__c)){
POLIList[j].ERP7__Quantity__c=ordItemList[i].Quantity-POLIList[j].ERP7__Quantity__c;

}                    

}
}

for(Integer i = 0;i<prliList.size(); i++){              
for(Integer j=0 ;j<POLIList.size(); j++){ 
if((prliList[i].ERP7__Product__c==POLIList[j].ERP7__Product__c)&&(prliList[i].ERP7__Quantity__c !=POLIList[j].ERP7__Quantity__c)){
prliList[i].ERP7__Quantity__c =POLIList[j].ERP7__Quantity__c;

}

else if((prliList[i].ERP7__Product__c==POLIList[j].ERP7__Product__c)&&(prliList[i].ERP7__Quantity__c ==POLIList[j].ERP7__Quantity__c)) prliList.remove(i);  
}
}*/
            //prli = new ERP7__Purchase_Requisition_Line_Items__c(Name = SOLI.Name,ERP7__Product__c = SOLI.ERP7__Product__c,ERP7__Product__r=new Product2(Id=SOLI.ERP7__Product__c,Name=SOLI.ERP7__Product__r.Name),Quantity__c = SOLI.ERP7__Quantity__c);//,ERP7__Price__c = SOLI.ERP7__PriceBook_Base_Price__c,ERP7__Amount__c = SOLI.ERP7__Total_Price__c
        } 
        
        system.debug('prliList size~>'+prliList.size());
        
        if(prliList.size() > 0){
            poWrap.wPOLIs =  prliList;
            set <Id> siteIds = new set <Id>(); 
            set <Id> prodIds = new set <Id>(); 
            List<ProductStock> prodlst = new List<ProductStock>();
            for(ERP7__Purchase_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            String DCId = '';
            if(empList.size()>0 && empList != null){
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                if(dcList.size() > 0) DCId = dcList[0].Id;
            }
            if(String.isNotEmpty(DCId)) {
                for(ERP7__Purchase_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
                List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                    From Distribution_Channel__c
                                                                    Where 
                                                                    Id=:DCId And Active__c = true order by ERP7__Priority__c ASC];
                
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
                
                List<ERP7__Stock_Inward_Line_Item__c> SILIList=new List<ERP7__Stock_Inward_Line_Item__c>();
                List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c
                                                Where product__c In: prodIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds
                                                and (ERP7__No_of_Items_Requested__c > 0 or Number_of_Item_In_Stock__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
                //  SILIList = [Select Id,Name ,ERP7__Product__c,ERP7__Quantity__c from ERP7__Stock_Inward_Line_Item__c where ERP7__Active__c =true AND ERP7__Quantity__c > 0 AND ERP7__Status__c = 'Awaiting Stock' AND ERP7__Product__c In:prodIds AND (ERP7__Purchase_Orders__c != null Or ERP7__Manufacturing_Order__c != null)];
                for(Id ProductId : prodIds){
                    Decimal demand = 0.0;  Decimal myStock = 0.0;  Decimal Awaitingstock = 0.0;
                    ProductStock pr = new ProductStock();
                    
                    for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                        if(ProductId == WIIS.product__c){              demand+=WIIS.ERP7__No_of_Items_Requested__c;                        myStock += WIIS.Number_of_Item_In_Stock__c;        Awaitingstock+=WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                                                        }
                        
                    }
                    
                    
                    pr.Product = ProductId;
                    pr.Demand = demand;
                    pr.Stock = myStock;
                    pr.AwaitingStocks=Awaitingstock;
                    prodlst.add(pr);
                }
            }
            poWrap.productStocks = prodlst;
        }
        else{
            poWrap.ErrMessage = 'No products available';
        }
        return poWrap;
    }
    
    @AuraEnabled
    public static POWrapper fetchPOandPOLIs(String purchaseId,Boolean returnToVendor){
        POWrapper poWrap = new POWrapper();
        String PORTVrecordTypeId = Schema.SObjectType.ERP7__PO__c.getRecordTypeInfosByDeveloperName().get('Return_to_Vendor_RTV').getRecordTypeId();
        
        ERP7__PO__c MasterPO = [SELECT  Id,Name, RecordTypeId, toLabel(RecordType.Name), RecordType.DeveloperName, ERP7__Active__c, ERP7__Channel__c, toLabel(ERP7__Shipment_Type__c),toLabel(ERP7__Shipment_Preference_Speed__c), toLabel(ERP7__Package_Type__c), ERP7__Quote_no__c, ERP7__Channel__r.Id, ERP7__Channel__r.Name, ERP7__Customer__c, ERP7__Customer__r.Id, ERP7__Customer__r.Name, ERP7__Delivery_Address__c, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Id, ERP7__Distribution_Channel__r.Name, ERP7__Expected_Date__c, ERP7__Invoice_Address__c, 
                                ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Organisation__r.Id, ERP7__Organisation__r.Name, ERP7__EmployeeRequester__c, ERP7__EmployeeRequester__r.Id, ERP7__EmployeeRequester__r.Name, ERP7__Ready_To_Receive__c, ERP7__Payment_Terms__c, ERP7__Status__c, ERP7__Vendor__c, ERP7__Vendor__r.Id, ERP7__Vendor__r.Name, ERP7__Vendor_Address__c, ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name, ERP7__Vendor_Contact__c,ERP7__Sales_Order__c,ERP7__Order__c,ERP7__Total_Amount__c,ERP7__Amount__c,ERP7__Tax_Amount__c ,ERP7__Billed_Quantity__c
                                FROM ERP7__PO__c WHERE Id =: purchaseId LIMIT 1];
        
        List<ERP7__Purchase_Line_Items__c> polis= [SELECT  Id,ERP7__Lead_Time_Days__c,ERP7__Account_Category__c, ERP7__Chart_of_Account__c, ERP7__Vendor_product_Name__c, Name, ERP7__Product__c,ERP7__Product__r.ProductCode, ERP7__Cost_Card__c, ERP7__Quantity__c, ERP7__Sort_Order__c, ERP7__Unit_Price__c, ERP7__Total_Price__c, ERP7__Description__c, ERP7__Purchase_Orders__c,ERP7__Version__c, ERP7__Tax_Rate__c, ERP7__Tax__c FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c =: purchaseId Order by ERP7__Sort_Order__c];
        poWrap.wPOLIs = new List<ERP7__Purchase_Line_Items__c>();
        if(returnToVendor){
            system.debug('MasterPO.ERP7__Distribution_Channel__c : '+MasterPO.ERP7__Distribution_Channel__c);
            poWrap.wPO = new ERP7__PO__c(Name = 'RTV - '+MasterPO.Name,RecordTypeId = PORTVrecordTypeId,ERP7__Package_Type__c=MasterPO.ERP7__Package_Type__c, ERP7__Active__c = true,ERP7__Channel__c = MasterPO.ERP7__Channel__c,ERP7__Channel__r = new ERP7__Channel__c(Id = MasterPO.ERP7__Channel__c,Name = MasterPO.ERP7__Channel__r.Name),ERP7__Shipment_Type__c = MasterPO.ERP7__Shipment_Type__c,ERP7__Shipment_Preference_Speed__c = MasterPO.ERP7__Shipment_Preference_Speed__c,ERP7__Quote_no__c = MasterPO.ERP7__Quote_no__c,ERP7__Customer__c = MasterPO.ERP7__Customer__c,ERP7__Delivery_Address__c = MasterPO.ERP7__Delivery_Address__c,ERP7__Description__c = MasterPO.ERP7__Description__c,ERP7__Distribution_Channel__c = MasterPO.ERP7__Distribution_Channel__c,ERP7__Distribution_Channel__r = new ERP7__Distribution_Channel__c(Id = MasterPO.ERP7__Distribution_Channel__c,Name = MasterPO.ERP7__Distribution_Channel__r.Name),ERP7__Expected_Date__c = MasterPO.ERP7__Expected_Date__c,
                                         ERP7__Invoice_Address__c = MasterPO.ERP7__Invoice_Address__c,ERP7__Organisation__c = MasterPO.ERP7__Organisation__c,ERP7__EmployeeRequester__c = MasterPO.ERP7__EmployeeRequester__c,ERP7__Payment_Terms__c = MasterPO.ERP7__Payment_Terms__c,ERP7__Status__c = MasterPO.ERP7__Status__c,ERP7__Vendor__c = MasterPO.ERP7__Vendor__c,ERP7__Vendor_Address__c = MasterPO.ERP7__Vendor_Address__c,ERP7__Vendor_Contact__c = MasterPO.ERP7__Vendor_Contact__c,ERP7__Sales_Order__c = MasterPO.ERP7__Sales_Order__c,ERP7__Order__c = MasterPO.ERP7__Order__c,ERP7__Master_Purchase_Orders__c = MasterPO.Id);
            
            for(ERP7__Purchase_Line_Items__c poli : polis){
                ERP7__Purchase_Line_Items__c  newRTVLine = new ERP7__Purchase_Line_Items__c();
                newRTVLine.Name = poli.Name;
                newRTVLine.ERP7__Lead_Time_Days__c= poli.ERP7__Lead_Time_Days__c;
                newRTVLine.ERP7__Account_Category__c= poli.ERP7__Account_Category__c;
                newRTVLine.ERP7__Chart_of_Account__c= poli.ERP7__Chart_of_Account__c;
                newRTVLine.ERP7__Vendor_product_Name__c= poli.ERP7__Vendor_product_Name__c;
                newRTVLine.ERP7__Product__c= poli.ERP7__Product__c;
                if(poli.ERP7__Product__r.ProductCode != null && poli.ERP7__Product__r.ProductCode != '') newRTVLine.ERP7__Product__r = new Product2(ProductCode = poli.ERP7__Product__r.ProductCode); // added by shaguftha on 29_11_23
                newRTVLine.ERP7__Cost_Card__c= poli.ERP7__Cost_Card__c;
                newRTVLine.ERP7__Quantity__c= poli.ERP7__Quantity__c;
                newRTVLine.ERP7__Sort_Order__c= poli.ERP7__Sort_Order__c;
                newRTVLine.ERP7__Unit_Price__c= poli.ERP7__Unit_Price__c;
                newRTVLine.ERP7__Total_Price__c = poli.ERP7__Total_Price__c;
                newRTVLine.ERP7__Description__c= poli.ERP7__Description__c;
                newRTVLine.ERP7__Version__c= poli.ERP7__Version__c;
                newRTVLine.ERP7__Tax_Rate__c= poli.ERP7__Tax_Rate__c;
                newRTVLine.ERP7__Tax__c = poli.ERP7__Tax__c ;
                poWrap.wPOLIs.add(newRTVLine); 
            }
        }
        else{
            poWrap.wPO = MasterPO;
            poWrap.wPOLIs = polis;
            if(MasterPO!=null && MasterPO.ERP7__Billed_Quantity__c!=null && MasterPO.ERP7__Billed_Quantity__c!=0){poWrap.isBilled=true;}
        }
        //New code added by Arshad 02/02/23
        List<ERP7__PO__c> existingReturnPOs = new List<ERP7__PO__c>();
        List<ERP7__Purchase_Line_Items__c> existingReturnPOLIs = new List<ERP7__Purchase_Line_Items__c>();
        existingReturnPOs = [SELECT Id, Name, ERP7__Active__c,ERP7__Status__c,ERP7__Master_Purchase_Orders__c FROM ERP7__PO__c WHERE RecordTypeId =:PORTVrecordTypeId AND ERP7__Master_Purchase_Orders__c != null AND ERP7__Master_Purchase_Orders__c =:purchaseId];
        if(existingReturnPOs.size() > 0) existingReturnPOLIs = [SELECT Id, Name, ERP7__Product__c,  ERP7__Quantity__c, ERP7__Unit_Price__c, ERP7__Total_Price__c, ERP7__Description__c, ERP7__Purchase_Orders__c,ERP7__Lead_Time_Days__c FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c IN :existingReturnPOs];
        poWrap.existingReturnPOs = existingReturnPOs;
        poWrap.existingReturnPOLIs = existingReturnPOLIs;
        //
        
        Set<Id> poliIds = new Set<Id>();
        List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
        for(ERP7__Purchase_Line_Items__c poli : poWrap.wPOLIs){
            poliIds.add(poli.Id);
        }
        demList = [select Id, Name, ERP7__Account_Category__c, ERP7__Allocation_Amount__c, ERP7__Allocation_Percentage__c, ERP7__Chart_of_Account__c, ERP7__Project__c, ERP7__Sort_Order__c, ERP7__Purchase_Line_Items__c from ERP7__Dimension__c where ERP7__Purchase_Line_Items__c IN :poliIds AND ERP7__Purchase_Line_Items__c != null];
        if(demList!=null && demList.size()>0) poWrap.demLIs = demList;
        String DCId = poWrap.wPO.ERP7__Distribution_Channel__c;
        set <Id> siteIds = new set <Id>(); 
        set <Id> prodIds = new set <Id>(); 
        List<ProductStock> prodlst = new List<ProductStock>();
        if(String.isNotEmpty(DCId)) {
            for(ERP7__Purchase_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
            List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c From Distribution_Channel__c Where  Id=:DCId And Active__c = true order by ERP7__Priority__c ASC];
            
            for(Distribution_Channel__c DC: DistributionChannels) { siteIds.add(DC.Site__c); }
            List<ERP7__Stock_Outward_Line_Item__c> SOLIList=new List<ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Stock_Inward_Line_Item__c> SILIList=new List<ERP7__Stock_Inward_Line_Item__c>();
            List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c, Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c, Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c 
                                            From Inventory_Stock__c Where product__c In: prodIds And Active__c = true And Warehouse__c In: siteIds  and  (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                           ];
            for(Id ProductId : prodIds){
                Decimal demand = 0.0;  Decimal myStock = 0.0;  Decimal Awaitingstock = 0.0;
                ProductStock pr = new ProductStock();
                
                for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                    if(ProductId == WIIS.product__c){                        myStock += WIIS.Number_of_Item_In_Stock__c;                        demand+=WIIS.ERP7__No_of_Items_Requested__c;                        Awaitingstock+=WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                    }
                }
                
                pr.Product = ProductId;
                pr.Demand = demand;
                pr.Stock = myStock;
                pr.AwaitingStocks=Awaitingstock;
                prodlst.add(pr);
            }
        }
        poWrap.productStocks = prodlst;
        poWrap.displayTaxRate = Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Tax_Rate__c.isAccessible();
        poWrap.displayTax = Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Tax__c.isAccessible();
        poWrap.displayVersion = Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Version__c.isAccessible();
        poWrap.displayQuote = Schema.sObjectType.ERP7__PO__c.fields.ERP7__Quote_no__c.isAccessible();
        poWrap.displayVPO = Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Vendor_product_Name__c.isAccessible();
        poWrap.displayName = Schema.sObjectType.Product2.fields.ERP7__Purchase_From_Approved_Vendor__c.isAccessible();
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
        if(FC != null){ poWrap.displayAllocations = FC.ERP7__Allocation_Process__c; poWrap.displayDCBelow = FC.ERP7__Show_DC_below__c; }
        return poWrap;
    }
    
    @AuraEnabled
    Public Static CreatePO getPOFC(){
        CreatePO CP = new CreatePO();
        
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  
        }
        if(FC != null){
            CP.POLINameAcc=FC.ERP7__POLI_Name__c; 
            CP.AllocationAccess = FC.ERP7__Allocation_Process__c; 
            CP.showUpload = FC.ERP7__Show_Upload_in_Create_PO__c;
            CP.allowCustomProds = FC.ERP7__Allow_Custom_Products__c;
            CP.VendorAddRequired = FC.ERP7__Po_Screen_Vendor_Address_Required__c;
            CP.skipTypeSelection = FC.ERP7__Purchase_Order_Skip_Type_Selection__c;
            CP.ProjectOnPOScreen = FC.ERP7__Project_on_PO_Screen__c; 
            CP.DepartmentOnPOScreen = FC.ERP7__Budget_Department_Allocation__c;
            CP.packageType = FC.ERP7__Display_Package_Type_on_PO_Screen__c;
            if(FC.ERP7__PO_screen_Vendor_Contact_Not_Required__c) {                CP.VendorContactRequired = false;
            }else CP.VendorContactRequired = true;
            if(FC.ERP7__don_t_show_version_in_create_PO__c) CP.versionAccess = false; // changed the version visibility from field to custom settings FC
            else CP.versionAccess = true;
            
            //CP.hideRemove = FC.ERP7__Restrict_Selected_Channel__c;
            //CP.showOrg = FC.ERP7__Show_PO_Organisation__c;  
            //CP.showDCbelow = FC.ERP7__Show_DC_below__c;  
            //CP.showReceive = FC.ERP7__Show_Receive_on_PO__c;
        }
        if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Tax__c.isAccessible()) { CP.TaxAccess = true; } else { CP.TaxAccess = false; }
        if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Tax_Rate__c.isAccessible()) { CP.TaxRate = true; } else { CP.TaxRate = false; }
        if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Quote_no__c.isAccessible()) { CP.QuoteAccess = true; } else { CP.QuoteAccess = false; }
        if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Vendor_product_Name__c.isAccessible()) { CP.displayVPO = true; } else { CP.displayVPO = false; }
        if(Schema.sObjectType.Product2.fields.ERP7__Purchase_From_Approved_Vendor__c.isAccessible()) { CP.displayName = true; } else { CP.displayName = false; }
        
        return CP;
    }
    
    @AuraEnabled
    public static PRStock populateSOLI(String soliID){
        /*inside soliID is :'+soliID*/
        PRStock pr = new PRStock();
        ERP7__Sales_Order_Line_Item__c SOLI;
        Purchase_Line_Items__c poli;
        String ProductId = '';
        if(soliID != null && soliID != ''){
            SOLI = [Select Id,Name, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Sales_Order__c,ERP7__Product__r.ERP7__Vendor_product_Name__c,
                    ERP7__Total_Price__c, ERP7__PriceBook_Base_Price__c, ERP7__Description__c, ERP7__Base_Price__c from ERP7__Sales_Order_Line_Item__c where Id=:soliID];
            poli = new Purchase_Line_Items__c(Name = SOLI.Name, ERP7__Sales_Order__c =SOLI.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__c = SOLI.Id,ERP7__Product__c = SOLI.ERP7__Product__c,ERP7__Product__r=new Product2(Id=SOLI.ERP7__Product__c,Name=SOLI.ERP7__Product__r.Name),Quantity__c = SOLI.ERP7__Quantity__c);//,ERP7__Unit_Price__c = SOLI.ERP7__PriceBook_Base_Price__c,ERP7__Total_Price__c = SOLI.ERP7__Total_Price__c
            ProductId = poli.ERP7__Product__c;
        }    
        Decimal myStock = 0.0;
        Decimal demand=0.0;
        Decimal Awaitingstock = 0.0;
        List <Id> siteIds = new List <Id>(); 
        system.debug('ProductId :  '+ProductId);
        if(String.isNotEmpty(ProductId)) {
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            if(empList.size()>0 && empList != null){
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                for(Distribution_Channel__c DC: dcList) {    siteIds.add(DC.Site__c);
                                                        }
                
            }
            
            List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                            Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                            Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                            From Inventory_Stock__c
                                            Where product__c =: ProductId And
                                            Active__c = true And
                                            Warehouse__c In: siteIds 
                                            and  (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                           ];
            
            for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                if(ProductId == WIIS.product__c)  {      myStock += WIIS.Number_of_Item_In_Stock__c;           demand+=WIIS.ERP7__No_of_Items_Requested__c; Awaitingstock += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                                                  }
            }
            
            pr.Prs = poli;
            pr.Demand = demand;
            pr.Stock = myStock;
            pr.AwaitingStocks=Awaitingstock;
            
            
        }
        
        
        return pr;
    }
    
    @AuraEnabled
    public static Purchase_Line_Items__c populateMpsline(String mpslineId){
        Purchase_Line_Items__c poli;
        if(mpslineId != null && mpslineId != ''){
            String mpsLineFields = UtilClass.selectStarFromSObject('ERP7__MPS_line_Item__c');
            utilClass.FLSCheck(mpsLineFields.split(','),'ERP7__MPS_line_Item__c');
            String query = 'select ' + String.escapeSingleQuotes(mpsLineFields) + ', ERP7__MPS__r.ERP7__Master_Production_Schedule__c, ERP7__MPS__r.ERP7__Version__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Version__c, ERP7__MPS__r.ERP7__Product__r.ERP7__Routing__c, ERP7__MPS__r.ERP7__Product__r.Name, ERP7__MPS__r.ERP7__Lot_Size__c, ERP7__MPS__r.ERP7__Product__c from ERP7__MPS_line_Item__c where Id =: mpslineId ';
            List<ERP7__MPS_line_Item__c> MPSSLines = Database.query(query);
            if(MPSSLines.size() > 0){
                poli = new Purchase_Line_Items__c();
                poli.Name = MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.Name;
                poli.ERP7__Quantity__c = MPSSLines[0].ERP7__MPS__r.ERP7__Lot_Size__c;
                poli.ERP7__Product__c = MPSSLines[0].ERP7__MPS__r.ERP7__Product__c;
                poli.ERP7__Product__r = new Product2(Id=MPSSLines[0].ERP7__MPS__r.ERP7__Product__c,Name=MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.Name);
                poli.ERP7__Version__c = (MPSSLines[0].ERP7__MPS__r.ERP7__Version__c != Null)? MPSSLines[0].ERP7__MPS__r.ERP7__Version__c : MPSSLines[0].ERP7__MPS__r.ERP7__Product__r.ERP7__Version__c;
            }
        }    
        return poli;
    }
    
    public class poliVenWrap{
        @AuraEnabled public Purchase_Line_Items__c  poli {get;set;}
        @AuraEnabled public String  vendId {get;set;}
        @AuraEnabled public String  MOId {get;set;}
        @AuraEnabled public decimal  stock {get;set;}
        @AuraEnabled public decimal  Awstock {get;set;}
        @AuraEnabled public decimal  ReqStock {get;set;}
    }
    
    @AuraEnabled
    public static poliVenWrap populateMrpline(String mrplineId){
        poliVenWrap wrap = new poliVenWrap();
        Purchase_Line_Items__c poli;
        if(mrplineId != null && mrplineId != ''){
            String mrpFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(mrpFields.split(','),'ERP7__MRP__c');
            String query = 'select ' + String.escapeSingleQuotes(mrpFields) + ', ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__MRP_Product__r.Name,ERP7__MRP_Product__r.ProductCode from ERP7__MRP__c where Id =: mrplineId ';
            List<ERP7__MRP__c> MRPS = Database.query(query);
            
            if(MRPS.size() > 0){
                ID ProdId =  MRPS[0].ERP7__MRP_Product__c;
                string appr = 'Approved';
                List<ERP7__Approved_Vendor__c> app = [Select Id,Name,ERP7__Lead_Time__c,ERP7__Product__c,ERP7__Vendor__c from ERP7__Approved_Vendor__c where ERP7__Product__c =:ProdId and ERP7__Status__c=:appr and ERP7__Vendor__c != null Order By ERP7__Default__c Desc ];
                if(app.size() > 0) wrap.vendId = app[0].ERP7__Vendor__c;
                Decimal curQuan = MRPS[0].ERP7__Total_Amount_Required__c;
                String SelectedSite = '';
                wrap.MOId = MRPS[0].ERP7__MO__c;
                system.debug('wrap.MoId : '+wrap.MoId);
                if(MRPS[0].ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != null) SelectedSite = MRPS[0].ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                else if(MRPS[0].ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != null) SelectedSite = MRPS[0].ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                
                if(SelectedSite != ''){
                    List<ERP7__Reordering_Rule__c> ReorderingRules = [Select Id, Name, ERP7__Base_Quantity__c, ERP7__Channel__c, ERP7__Lead_Time__c, 
                                                                      ERP7__Maximum_Quantity__c, ERP7__Minimum_Quantity__c, ERP7__Product__c, ERP7__Warning_Quantity__c,
                                                                      ERP7__Quantity_Multiple__c, ERP7__Stock_Quantity__c, ERP7__Warehouse__c, ERP7__MinimumHoldingQuantity__c, ERP7__MinimumOrderingQuantity__c
                                                                      From ERP7__Reordering_Rule__c
                                                                      Where ERP7__Product__c = :MRPS[0].ERP7__MRP_Product__c And
                                                                      ERP7__MinimumHoldingQuantity__c != Null And
                                                                      ERP7__MinimumOrderingQuantity__c != Null And
                                                                      ERP7__Warehouse__c = :SelectedSite
                                                                      Order By CreatedDate Desc Limit 1];
                    
                    if(ReorderingRules.size() > 0 && ReorderingRules[0].ERP7__MinimumOrderingQuantity__c > curQuan) curQuan = ReorderingRules[0].ERP7__MinimumOrderingQuantity__c; 
                } 
                poli = new Purchase_Line_Items__c();
                poli.Name = MRPS[0].ERP7__MRP_Product__r.Name;
                poli.ERP7__Quantity__c = curQuan;    
                poli.ERP7__Product__c = MRPS[0].ERP7__MRP_Product__c;
                poli.ERP7__Product__r = new Product2(Id=MRPS[0].ERP7__MRP_Product__c,Name=MRPS[0].ERP7__MRP_Product__r.Name,ProductCode = MRPS[0].ERP7__MRP_Product__r.ProductCode);
                poli.ERP7__Version__c = MRPS[0].ERP7__Version__c;
                poli.ERP7__MRP_Material_Requirements_Planning__c = MRPS[0].Id;
                wrap.poli= poli;
                // added by shaguftha on 08/08/2023
                List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c
                                                Where product__c = :MRPS[0].ERP7__MRP_Product__c And
                                                Active__c = true And
                                                Warehouse__c = :SelectedSite
                                                and  (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
                Decimal demand = 0.0;  Decimal myStock = 0.0;  Decimal Awaitingstock = 0.0;
                for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                    if(MRPS[0].ERP7__MRP_Product__c == WIIS.product__c)    {
                        myStock += WIIS.Number_of_Item_In_Stock__c;                
                        demand+=WIIS.ERP7__No_of_Items_Requested__c;    
                        Awaitingstock +=  WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                    }
                }
                wrap.stock = myStock;
                wrap.Awstock = Awaitingstock;
                wrap.ReqStock = demand;
                
            }
        }    
        return wrap;
    }
    
    @AuraEnabled
    public static Purchase_Line_Items__c populateRMAPO(String rmaliID){
        ERP7__RMA_Line_Item__c RMALI;
        Purchase_Line_Items__c poli;
        if(rmaliID != null && rmaliID != ''){
            RMALI = [Select Id, Name, ERP7__Quantity_Available__c, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.ERP7__SO__c,
                     ERP7__SOLI__c, ERP7__Quantity_Return__c, ERP7__Base_Price__c, ERP7__Sale_Price__c, ERP7__Product__c,ERP7__Product__r.Name 
                     from ERP7__RMA_Line_Item__c where Id=:rmaliID];
            poli = new Purchase_Line_Items__c(Name = RMALI.Name,ERP7__Product__c = RMALI.ERP7__Product__c,ERP7__Product__r=new Product2(Id=RMALI.ERP7__Product__c,Name=RMALI.ERP7__Product__r.Name),Quantity__c = RMALI.ERP7__Quantity_Return__c,ERP7__Unit_Price__c = RMALI.ERP7__Base_Price__c,ERP7__Total_Price__c = RMALI.ERP7__Sale_Price__c);
        }
        return poli;
    }
    
    @AuraEnabled
    public static POWrapper populateMOlines(String MOId){
        List<Purchase_Line_Items__c> prlis = new List<Purchase_Line_Items__c>();
        POWrapper poWrap = new POWrapper();
        set<Id> productsWithNoStock = new set<Id>();
        if(MOId != null && MOId != ''){
            String MOFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
            String AllMOFields = MOFields + ', ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Product__r.Name, ERP7__Product__r.QuantityUnitOfMeasure, ERP7__Version__r.Name, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Manufacturing_Order__r.Name, ERP7__Routing__r.ERP7__Finished_Products_Site__c ';
            ERP7__Manufacturing_Order__c MO = Database.query('SELECT '+String.escapeSingleQuotes(AllMOFields)+' FROM ERP7__Manufacturing_Order__c WHERE Id = :MOId Limit 1');
            String selectedSite = MO.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            
            String mrpFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(mrpFields.split(','),'ERP7__MRP__c');
            String query = 'select ' + String.escapeSingleQuotes(mrpFields) + ', ERP7__MRP_Product__r.Name,ERP7__MRP_Product__r.ProductCode,ERP7__MRP_Product__r.ERP7__Vendor_product_Name__c,ERP7__BOM__r.ERP7__Unit_of_Measure__c,ERP7__MRP_Product__r.QuantityUnitOfMeasure,ERP7__MRP_Product__r.ERP7__Serialise__c from ERP7__MRP__c where ERP7__MO__c =: MOId ';
            List<ERP7__MRP__c> MRPS = Database.query(query);
            //set<String> UOMstofetch = new set<String>();
            Set<Id> proIds = new Set<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            for(MRP__c mrp : MRPS){
                if(mrp.ERP7__MRP_Product__c != Null ) proIds.add(mrp.ERP7__MRP_Product__c);
                //if(mrp.ERP7__BOM__c != null) UOMstofetch.add(mrp.ERP7__BOM__r.ERP7__Unit_of_Measure__c);
                // if(mrp.ERP7__MRP_Product__c != null) UOMstofetch.add(mrp.ERP7__MRP_Product__r.QuantityUnitOfMeasure);
            }
            
            Map<Id, ERP7__Reordering_Rule__c> RRMap = new Map<Id, ERP7__Reordering_Rule__c>();
            if(selectedSite != Null && selectedSite != ''){
                List<ERP7__Reordering_Rule__c> ReorderingRules = [Select Id, Name, ERP7__Base_Quantity__c, ERP7__Channel__c, ERP7__Lead_Time__c, 
                                                                  ERP7__Maximum_Quantity__c, ERP7__Minimum_Quantity__c, ERP7__Product__c, ERP7__Warning_Quantity__c,
                                                                  ERP7__Quantity_Multiple__c, ERP7__Stock_Quantity__c, ERP7__Warehouse__c, ERP7__MinimumHoldingQuantity__c, ERP7__MinimumOrderingQuantity__c
                                                                  From ERP7__Reordering_Rule__c
                                                                  Where ERP7__Product__c In :proIds And
                                                                  ERP7__MinimumHoldingQuantity__c != Null And
                                                                  ERP7__MinimumOrderingQuantity__c != Null And
                                                                  ERP7__Warehouse__c = :selectedSite
                                                                  Order By CreatedDate Desc];
                for (ERP7__Reordering_Rule__c RR : ReorderingRules) if(!RRMap.containsKey(RR.ERP7__Product__c)) RRMap.put(RR.ERP7__Product__c,RR); 
                
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + ''; 
                List<AggregateResult> WIISLists = [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c =: selectedSite And (ERP7__Number_of_Item_In_Stock__c > 0) AND ERP7__Product__c In: proIds GROUP BY ERP7__Product__c];   
                
                /*Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
+' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC'); */
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    for(AggregateResult result : WIISLists){
                        if(proId == (Id)result.get('ERP7__Product__c')){
                            myStock += (Decimal)result.get('totalStock');
                        }
                    }
                    stockMap.put(proId,myStock);
                }
            }
            //Shaguftha M change 22-09-2023
            List<ERP7__UOM_Conversion__mdt> uom = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 1000];
            
            for(MRP__c mrp : MRPS){
                //Shaguftha M change 22-09-2023
                decimal weightMultiplier = 1;
                if(mrp.ERP7__BOM__c != null && mrp.ERP7__MRP_Product__c != null){
                    String newUOM = mrp.ERP7__MRP_Product__r.QuantityUnitOfMeasure; 
                    String oldUOM = mrp.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                    if(newUOM != '' && newUOM != null && oldUOM != '' && oldUOM != null && newUOM != oldUOM){
                        for(ERP7__UOM_Conversion__mdt uomNew  : uom){
                            if((uomNew.ERP7__From_UOM__c == oldUOM && uomNew.ERP7__To_UOM__c == newUOM) || (uomNew.ERP7__From_UOM__c == newUOM && uomNew.ERP7__To_UOM__c == oldUOM)){
                                if(uomNew.ERP7__From_UOM__c == oldUOM && uomNew.ERP7__To_UOM__c == newUOM){                                    weightMultiplier = uomNew.ERP7__From_Value__c/uomNew.ERP7__To_Value__c;
                                } else if(uomNew.ERP7__From_UOM__c == newUOM && uomNew.ERP7__To_UOM__c == oldUOM){                                    weightMultiplier = uomNew.ERP7__To_Value__c/uomNew.ERP7__From_Value__c;
                                }
                            } 
                        }
                    }
                    
                }
                system.debug('weightMultiplier : '+weightMultiplier);
                //Shaguftha M end change 22-09-2023
                if(mrp.ERP7__MRP_Product__c != Null && stockMap.containsKey(mrp.ERP7__MRP_Product__c) && mrp.ERP7__Fulfilled_Amount__c != (mrp.ERP7__Total_Amount_Required__c/weightMultiplier)){
                    Decimal FA = (mrp.ERP7__Fulfilled_Amount__c != Null)? mrp.ERP7__Fulfilled_Amount__c : 0;
                    if(stockMap.get(mrp.ERP7__MRP_Product__c) < ((mrp.ERP7__Total_Amount_Required__c/weightMultiplier) - FA)){
                        Purchase_Line_Items__c prli = new Purchase_Line_Items__c();
                        prli.Name = mrp.ERP7__MRP_Product__r.Name;
                        Decimal curQuan = mrp.ERP7__Total_Amount_Required__c - FA - stockMap.get(mrp.ERP7__MRP_Product__c);
                        if(RRMap.containsKey(mrp.ERP7__MRP_Product__c) && RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c != null && RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c > curQuan) curQuan = RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c;
                        prli.ERP7__Quantity__c = (mrp.ERP7__MRP_Product__r.ERP7__Serialise__c)? Math.round(curQuan/weightMultiplier) : (curQuan/weightMultiplier).setScale(3); // added by Shaguftha on 2/11/23 a it was getting multiple decimal places
                        prli.ERP7__Product__c = mrp.ERP7__MRP_Product__c;
                        prli.ERP7__Vendor_product_Name__c =  mrp.ERP7__MRP_Product__r.ERP7__Vendor_product_Name__c;
                        prli.ERP7__Product__r = new Product2(Id=mrp.ERP7__MRP_Product__c,Name=mrp.ERP7__MRP_Product__r.Name,ProductCode = mrp.ERP7__MRP_Product__r.ProductCode);
                        prli.ERP7__MRP_Material_Requirements_Planning__c = mrp.id;
                        prlis.add(prli);
                        productsWithNoStock.add(mrp.ERP7__MRP_Product__c);
                    }
                }
            }
            system.debug('productsWithNoStock : '+productsWithNoStock.size());
            string appr = 'Approved';
            List<ERP7__Approved_Vendor__c> app = [Select Id,Name,ERP7__Lead_Time__c,ERP7__Product__c,ERP7__Vendor__c from ERP7__Approved_Vendor__c where ERP7__Product__c IN:productsWithNoStock and ERP7__Status__c=:appr and ERP7__Vendor__c != null and ERP7__Cost_Card__c != null Order By ERP7__Vendor__c ];
            // Create a Map to store the count of vendors associated with each product
            Map<Id, Integer> vendorCountsByProduct = new Map<Id, Integer>();
            
            // Loop through the list of approved vendors and products
            for(ERP7__Approved_Vendor__c vendor : app) {
                // If the vendor's product is not in the map, add it with a count of 1
                if(!vendorCountsByProduct.containsKey(vendor.ERP7__Product__c)) {                    vendorCountsByProduct.put(vendor.ERP7__Product__c, 1);
                }
                // If the vendor's product is in the map, increment its count by 1
                else {                    vendorCountsByProduct.put(vendor.ERP7__Product__c, vendorCountsByProduct.get(vendor.ERP7__Product__c) + 1);
                }
            }
            
            // Create a Set to store the common approved vendors
            Set<Id> commonApprovedVendors = new Set<Id>();
            set<Id> productmissingApprovedVendors = new Set<Id>();
            // Loop through the map of vendor counts by product
            for(Id productId : productsWithNoStock) {
                // Create a Set to store the approved vendors associated with the current product
                Set<Id> vendorsForProduct = new Set<Id>();
                // Loop through the list of approved vendors and products
                for(ERP7__Approved_Vendor__c vendor : app) {
                    // If the vendor is associated with the current product, add it to the Set
                    if(vendor.ERP7__Product__c == productId) {                        vendorsForProduct.add(vendor.ERP7__Vendor__c);
                        system.debug('vendorsForProduct : '+vendorsForProduct);
                    }
                }
                
                // If the Set is empty, the product is missing an approved vendor
                system.debug('vendorsForProduct.isEmpty() : '+vendorsForProduct.isEmpty());
                system.debug('vendorCountsByProduct.containsKey(productId) : '+vendorCountsByProduct.containsKey(productId));
                if(vendorsForProduct.isEmpty() || !vendorCountsByProduct.containsKey(productId)) {
                    System.debug('Product ' + productId + ' is missing an approved vendor.');
                    productmissingApprovedVendors.add(productId);
                }
                // If this is the first product we're checking, add all its approved vendors to the common set
                else if(commonApprovedVendors.isEmpty()) {                    commonApprovedVendors.addAll(vendorsForProduct);
                }
                else if(!commonApprovedVendors.isEmpty()){
                    for(Id vendID : commonApprovedVendors){
                        if(!vendorsForProduct.contains(vendID)){
                            System.debug('Product in loops' + productId + ' is missing an approved vendor.');
                            productmissingApprovedVendors.add(productId);
                        }
                        else{
                            commonApprovedVendors.retainAll(vendorsForProduct);
                        }
                    }
                }
                // If this is not the first product we're checking, retain only the approved vendors that are common to both products
                
            }
            system.debug('productmissingApprovedVendors : '+productmissingApprovedVendors);
            // The commonApprovedVendors set now contains the IDs of the common approved vendors across all products
            system.debug('commonApprovedVendors : '+commonApprovedVendors);
            if(!commonApprovedVendors.isEmpty() && productmissingApprovedVendors.size() == 0)  poWrap.CommonVendor = commonApprovedVendors.iterator().next();
            else poWrap.CommonVendorMessage = System.Label.No_common_approved_Vendor_for_Products;
            
        }
        if(prlis.size() > 0){
            poWrap.wPOLIs =  prlis;
            set <Id> siteIds = new set <Id>(); 
            set <Id> prodIds = new set <Id>(); 
            List<ProductStock> prodlst = new List<ProductStock>();
            for(ERP7__Purchase_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            String DCId = '';
            if(empList.size()>0 && empList != null){
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                if(dcList.size() > 0) DCId = dcList[0].Id;
            }
            if(String.isNotEmpty(DCId)) {
                for(ERP7__Purchase_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
                List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                    From Distribution_Channel__c
                                                                    Where 
                                                                    Id=:DCId And Active__c = true order by ERP7__Priority__c ASC];
                
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
                
                List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c
                                                Where product__c In: prodIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds
                                                and  (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
                for(Id ProductId : prodIds){
                    Decimal demand = 0.0;  Decimal myStock = 0.0;  Decimal Awaitingstock = 0.0;
                    ProductStock pr = new ProductStock();
                    
                    for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                        if(ProductId == WIIS.product__c)                myStock += WIIS.Number_of_Item_In_Stock__c;                demand+=WIIS.ERP7__No_of_Items_Requested__c;    Awaitingstock +=  WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                    }
                    
                    pr.Product = ProductId;
                    pr.Demand = demand;
                    pr.Stock = myStock;
                    pr.AwaitingStocks=Awaitingstock;
                    prodlst.add(pr);
                }
            }
            poWrap.productStocks = prodlst;
        }
        else {return null;}
        return poWrap;
    }
    
    @AuraEnabled
    public static POWrapper populateSOlines(String SOId){
        /* *** Inside populateSOlines*/
        /* *** SOId is :'+SOId*/
        POWrapper poWrap = new POWrapper();
        List<Purchase_Line_Items__c> polis = new List<Purchase_Line_Items__c>();
        if(SOId != null && SOId != ''){
            String AllSOFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order__c');
            ERP7__Sales_Order__c SO = Database.query('SELECT '+String.escapeSingleQuotes(AllSOFields)+' FROM ERP7__Sales_Order__c WHERE Id = :SOId Limit 1');
            Id salePointId = SO.ERP7__Channel__c;
            String soliFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order_Line_Item__c');
            utilClass.FLSCheck(soliFields.split(','),'ERP7__Sales_Order_Line_Item__c');
            String query = 'select ' + String.escapeSingleQuotes(soliFields) + ', ERP7__Product__r.Name from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c =: SOId AND ERP7__Is_Back_Order__c = true';
            List<ERP7__Sales_Order_Line_Item__c> SOLIs = Database.query(query);
            
            Set<Id> proIds = new Set<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            for(Sales_Order_Line_Item__c soli : SOLIs)
                if(soli.ERP7__Product__c != Null ) 
                proIds.add(soli.ERP7__Product__c);
            
            Map<Id, ERP7__Reordering_Rule__c> RRMap = new Map<Id, ERP7__Reordering_Rule__c>();
            List<ERP7__Reordering_Rule__c> ReorderingRules = [Select Id, Name, ERP7__Product__c, ERP7__MinimumHoldingQuantity__c, ERP7__MinimumOrderingQuantity__c
                                                              From ERP7__Reordering_Rule__c
                                                              Where ERP7__Product__c In :proIds And
                                                              ERP7__MinimumHoldingQuantity__c != Null And
                                                              ERP7__MinimumOrderingQuantity__c != Null
                                                              Order By CreatedDate Desc];
            for (ERP7__Reordering_Rule__c RR : ReorderingRules) if(!RRMap.containsKey(RR.ERP7__Product__c)) RRMap.put(RR.ERP7__Product__c,RR);
            Map < String, ERP7__Distribution_Channel__c> siteDistribution = new Map < String, ERP7__Distribution_Channel__c> ();
            List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Primary__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Site__r.Name
                                                                          From ERP7__Distribution_Channel__c
                                                                          Where ERP7__Active__c = true And
                                                                          ERP7__Channel__c = : salePointId
                                                                          Order By ERP7__Priority__c Desc];
            for(ERP7__Distribution_Channel__c DC : DistributionChannels) if(DC.ERP7__Primary__c) siteDistribution.put(DC.ERP7__Channel__c,DC);
            
            String selectedSite = (siteDistribution != Null && siteDistribution.containsKey(salePointId))?siteDistribution.get(salePointId).ERP7__Site__c:null;
            
            if(selectedSite != null && selectedSite != ''){
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + ''; 
                List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                                    +' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC'); 
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    for(Inventory_Stock__c stock : WIISLists){ if(proId == stock.Product__c){ myStock += stock.Number_of_Item_In_Stock__c;
                                                                                            }
                                                             }
                    stockMap.put(proId,myStock);
                }
            }
            
            for(Sales_Order_Line_Item__c soli : SOLIs){
                if(soli.ERP7__Product__c != Null && stockMap.containsKey(soli.ERP7__Product__c)){
                    if(stockMap.get(soli.ERP7__Product__c) < (soli.ERP7__Quantity__c)){
                        Purchase_Line_Items__c poli = new Purchase_Line_Items__c();
                        poli.Name = soli.ERP7__Product__r.Name;
                        Decimal curQuan = soli.ERP7__Quantity__c; //- stockMap.get(soli.ERP7__Product__c);
                        if(RRMap.containsKey(soli.ERP7__Product__c) && RRMap.get(soli.ERP7__Product__c).MinimumOrderingQuantity__c != null && RRMap.get(soli.ERP7__Product__c).MinimumOrderingQuantity__c > curQuan) curQuan = RRMap.get(soli.ERP7__Product__c).MinimumOrderingQuantity__c;
                        poli.ERP7__Quantity__c = curQuan;
                        poli.ERP7__Sales_Order__c = soli.ERP7__Sales_Order__c;
                        poli.ERP7__Product__c = soli.ERP7__Product__c;
                        poli.ERP7__Product__r = new Product2(Id=soli.ERP7__Product__c, Name = soli.ERP7__Product__r.Name);
                        poli.ERP7__Sales_Order_Line_Item__c = soli.id;
                        polis.add(poli);
                    }
                }
            }
        } 
        if(polis.size() > 0){
            poWrap.wPOLIs =  polis;
            set <Id> siteIds = new set <Id>(); 
            set <Id> prodIds = new set <Id>(); 
            List<ProductStock> prodlst = new List<ProductStock>();
            for(ERP7__Purchase_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            String DCId = '';
            if(empList.size()>0 && empList != null){
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                if(dcList.size() > 0) DCId = dcList[0].Id;
            }
            if(String.isNotEmpty(DCId)) {
                for(ERP7__Purchase_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
                List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                    From Distribution_Channel__c
                                                                    Where 
                                                                    Id=:DCId And Active__c = true order by ERP7__Priority__c ASC];
                
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
                
                List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c
                                                Where product__c In: prodIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds 
                                                and  (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
                for(Id ProductId : prodIds){
                    Decimal demand = 0.0;  Decimal myStock = 0.0;  Decimal Awaitingstock = 0.0;
                    ProductStock pr = new ProductStock();
                    
                    for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                        if(ProductId == WIIS.product__c){                            demand+=WIIS.ERP7__No_of_Items_Requested__c;                    myStock += WIIS.Number_of_Item_In_Stock__c;    Awaitingstock += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                        }
                        
                    }
                    
                    
                    pr.Product = ProductId;
                    pr.Demand = demand;
                    pr.Stock = myStock;
                    pr.AwaitingStocks=Awaitingstock;
                    prodlst.add(pr);
                }
            }
            poWrap.productStocks = prodlst;
        }
        return poWrap;
        
    }
    
    @AuraEnabled
    public static List<Purchase_Line_Items__c> populateWOlines(String WOId){
        List<Purchase_Line_Items__c> prlis = new List<Purchase_Line_Items__c>();
        if(WOId != null && WOId != ''){
            String WOFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            String AllWOFields = WOFields + ', ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Product__r.Name, ERP7__Product__r.QuantityUnitOfMeasure, ERP7__Version__r.Name, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Routing__r.ERP7__Finished_Products_Site__c ';
            ERP7__WO__c WO = Database.query('SELECT '+String.escapeSingleQuotes(AllWOFields)+' FROM ERP7__WO__c WHERE Id = :WOId Limit 1');
            String selectedSite = WO.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            
            
            String mrpFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(mrpFields.split(','),'ERP7__MRP__c');
            String query = 'select ' + String.escapeSingleQuotes(mrpFields) + ', ERP7__MRP_Product__r.Name from ERP7__MRP__c where ERP7__Work_Order__c =: WOId ';
            List<ERP7__MRP__c> MRPS = Database.query(query);
            
            Set<Id> proIds = new Set<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            for(MRP__c mrp : MRPS){
                if(mrp.ERP7__MRP_Product__c != Null ) proIds.add(mrp.ERP7__MRP_Product__c);
            }
            
            Map<Id, ERP7__Reordering_Rule__c> RRMap = new Map<Id, ERP7__Reordering_Rule__c>();
            if(selectedSite != Null && selectedSite != ''){
                List<ERP7__Reordering_Rule__c> ReorderingRules = [Select Id, Name, ERP7__Base_Quantity__c, ERP7__Channel__c, ERP7__Lead_Time__c, 
                                                                  ERP7__Maximum_Quantity__c, ERP7__Minimum_Quantity__c, ERP7__Product__c, ERP7__Warning_Quantity__c,
                                                                  ERP7__Quantity_Multiple__c, ERP7__Stock_Quantity__c, ERP7__Warehouse__c, ERP7__MinimumHoldingQuantity__c, ERP7__MinimumOrderingQuantity__c
                                                                  From ERP7__Reordering_Rule__c
                                                                  Where ERP7__Product__c In :proIds And
                                                                  ERP7__MinimumHoldingQuantity__c != Null And
                                                                  ERP7__MinimumOrderingQuantity__c != Null And
                                                                  ERP7__Warehouse__c = :selectedSite
                                                                  Order By CreatedDate Desc];
                for (ERP7__Reordering_Rule__c RR : ReorderingRules) if(!RRMap.containsKey(RR.ERP7__Product__c)) RRMap.put(RR.ERP7__Product__c,RR); 
                
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + ''; 
                List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                                    +' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC'); 
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    for(Inventory_Stock__c stock : WIISLists){
                        if(proId == stock.Product__c){
                            myStock += stock.Number_of_Item_In_Stock__c;
                        }
                    }
                    stockMap.put(proId,myStock);
                }
            }
            
            for(MRP__c mrp : MRPS){
                if(mrp.ERP7__MRP_Product__c != Null && stockMap.containsKey(mrp.ERP7__MRP_Product__c) && mrp.ERP7__Fulfilled_Amount__c != mrp.ERP7__Total_Amount_Required__c){
                    Decimal FA = (mrp.ERP7__Fulfilled_Amount__c != Null)? mrp.ERP7__Fulfilled_Amount__c : 0;
                    if(stockMap.get(mrp.ERP7__MRP_Product__c) < (mrp.ERP7__Total_Amount_Required__c - FA)){
                        Purchase_Line_Items__c prli = new Purchase_Line_Items__c();
                        prli.Name = mrp.ERP7__MRP_Product__r.Name;
                        Decimal curQuan = mrp.ERP7__Total_Amount_Required__c - FA - stockMap.get(mrp.ERP7__MRP_Product__c);
                        if(RRMap.containsKey(mrp.ERP7__MRP_Product__c) && RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c != null && RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c > curQuan) curQuan = RRMap.get(mrp.ERP7__MRP_Product__c).MinimumOrderingQuantity__c;
                        prli.ERP7__Quantity__c = curQuan;
                        prli.ERP7__Product__c = mrp.ERP7__MRP_Product__c;
                        prli.ERP7__Product__r = new Product2(Id=mrp.ERP7__MRP_Product__c,Name=mrp.ERP7__MRP_Product__r.Name);
                        prli.ERP7__MRP_Material_Requirements_Planning__c = mrp.id;
                        prlis.add(prli);
                    }
                }
            }
        }    
        return prlis;
    }
    
    @AuraEnabled
    public static List<SelectOptions> getStatus(){
        List<SelectOptions> options = new List<SelectOptions>(); 
        options.add(new SelectOptions('--None--','--None--'));
        Schema.DescribeFieldResult fieldResult = PO__c.Status__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple){
            options.add(new SelectOptions(f.getLabel(),f.getValue()));
            system.debug('f : '+f);
        }  
        return options;
    }
    @AuraEnabled
    public static List<SelectOptions> getPackageType(){        List<SelectOptions> options = new List<SelectOptions>();         options.add(new SelectOptions('--None--','--None--'));        Schema.DescribeFieldResult fieldResult = PO__c.ERP7__Package_Type__c.getDescribe();         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple){            options.add(new SelectOptions(f.getLabel(),f.getValue()));
            system.debug('f : '+f);
        }  
        return options;
    }
    
    @AuraEnabled
    public static List<String> getFamily(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    @AuraEnabled
    public static List<String> getSubFamily(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Product2.ERP7__Product_Service_Family__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    @AuraEnabled
    public static List<String> getCategoryList(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = ERP7__Dimension__c.ERP7__Account_Category__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    
    @AuraEnabled
    public static List<String> getShipmentType(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = PO__c.ERP7__Shipment_Type__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    
    @AuraEnabled
    public static void AnalyticalAccounts(String AA, String PId){
        try{
            system.debug('AA-->'+AA);
            system.debug('PId-->'+PId);
            String demstring = AA.replace('[[', '[');
            demstring = demstring.replace(']]', ']');
            demstring = demstring.replace('],[', ',');
            system.debug('demstring-->'+demstring);
            List<ERP7__Dimension__c> demList1 = (List<ERP7__Dimension__c>) JSON.deserialize(demstring, List<ERP7__Dimension__c>.class);
            system.debug('demList-->'+demList1);
            List<Purchase_Line_Items__c> poli = [select Id, Name, ERP7__Organisation__c, ERP7__Sort_Order__c,ERP7__Account_Category__c,ERP7__Chart_of_Account__c from Purchase_Line_Items__c where ERP7__Purchase_Orders__c=:PId];            Map<Integer, Purchase_Line_Items__c > poliMap = new Map<Integer, Purchase_Line_Items__c >();
            for(Purchase_Line_Items__c pol : poli){                poliMap.put(Integer.valueOf(pol.ERP7__Sort_Order__c), pol);
            }
            system.debug('poliMap-->'+poliMap);
            if(demList1.size()>0){
                system.debug('demList1');
                for(ERP7__Dimension__c dem1 : demList1){
                    system.debug('Sort Order-->'+dem1.ERP7__Sort_Order__c);
                    if(dem1.ERP7__Sort_Order__c != null){
                        if(poliMap.containsKey(Integer.valueOf(dem1.ERP7__Sort_Order__c))){                            dem1.ERP7__Purchase_Line_Items__c = poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Id;                            dem1.Name = poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).Name;                            dem1.ERP7__Active__c = true;
                            if(poli[0].ERP7__Organisation__c != null) dem1.ERP7__Organisation__c = poli[0].ERP7__Organisation__c;
                            if(poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c != null) dem1.ERP7__Account_Category__c = poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Account_Category__c;
                            if(poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_of_Account__c != null) dem1.ERP7__Chart_of_Account__c = poliMap.get(Integer.valueOf(dem1.ERP7__Sort_Order__c)).ERP7__Chart_of_Account__c;
                        }
                    }
                }
                system.debug('demList1-->'+demList1);
                upsert demList1;
            }
        }catch(Exception e){ system.debug('Exception~>'+e.getStackTraceString()); }
    }
    
    @AuraEnabled
    public static void createAttachment(String filesData, String orderId){
        List<FileData> filesDataList = new List<FileData>();
        if(String.isNotEmpty(filesData)) filesDataList = (List<FileData>) JSON.deserialize(filesData, List<FileData>.class);
        system.debug('filesDataList~>'+filesDataList.size());
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        if(filesDataList.size() > 0 && orderId != null){
            for (FileData fileData : filesDataList) {
                system.debug('fileData.fileName~>'+fileData.fileName);
                
                fileData.base64Data = EncodingUtil.urlDecode(fileData.base64Data, 'UTF-8');  
                Attachment a = new Attachment();                  a.parentId = orderId;                 a.Body = EncodingUtil.base64Decode(fileData.base64Data);                 a.Name = fileData.fileName;                a.ContentType = fileData.contentType;                attachmentsToInsert.add(a);
            }
            system.debug('attachmentsToInsert~>'+attachmentsToInsert.size());
            if(attachmentsToInsert.size() > 0 && Schema.SObjectType.Attachment.isCreateable()){ insert attachmentsToInsert; } else{ }
        }
    }
    @AuraEnabled
    Public static PO__c save_PurchaseOrder(String purchaseOrder,String POLI_List, String rfpSupp, String rfpReq,String orderId,string shipmentid, List<String> pacakgeids, Boolean returnPO, String filesData){
        /* 'orderId :'+orderId */
        /* 'shipmentid :'+shipmentid */
        /* 'pacakgeids :'+pacakgeids */
        system.debug('POLI_List-->'+POLI_List);
        try{
            
            ERP7__PO__c porders = new ERP7__PO__c();
            
            List<FileData> filesDataList = new List<FileData>();
            if(String.isNotEmpty(filesData)) filesDataList = (List<FileData>) JSON.deserialize(filesData, List<FileData>.class);
            system.debug('filesDataList~>'+filesDataList.size());
            
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            
            if(returnPO){
                porders = (ERP7__PO__c) JSON.deserialize(purchaseOrder, ERP7__PO__c.class);
                //if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order_Date__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order_Date__c.isUpdateable() && (orderId == null || orderId =='')) porders.ERP7__Order_Date__c = system.today();
                if(orderId != null && orderId !='') if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order__c.isUpdateable())porders.ERP7__Order__c = orderId;
                List<Purchase_Line_Items__c> po_List = (List<Purchase_Line_Items__c>) JSON.deserialize(POLI_List, List<Purchase_Line_Items__c>.class);
                porders.RecordTypeId = Schema.SObjectType.ERP7__PO__c.getRecordTypeInfosByDeveloperName().get('Return_to_Vendor_RTV').getRecordTypeId();
                //porders.Id = null;
                porders.Name = null;
                //porders.Name = 'RTV-PO-';//Moin commented this
                
                //Commented By Parveez On 19/10/2023 for preventing ready to pick & pack from default false
                /*porders.ERP7__Ready_To_Receive__c = false;
Boolean Ready_To_Pick_Pack = false;
if(porders.ERP7__Ready_To_Pick_Pack__c){
Ready_To_Pick_Pack = porders.ERP7__Ready_To_Pick_Pack__c;
if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Pick_Pack__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Pick_Pack__c.isUpdateable() ) porders.ERP7__Ready_To_Pick_Pack__c = false;
}*/  
                //till here Commented By Parveez On 19/10/2023 
                
                //&& Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Receive__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Receive__c.isUpdateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order_Date__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order_Date__c.isUpdateable()
                if(porders != null ){ if(Schema.sObjectType.ERP7__PO__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.isUpdateable()) {upsert porders; }else { } }else { }
                
                for(Integer i = 0;i<po_List.size();i++){
                    //po_List[i].Id = null;
                    if(po_List[i].ERP7__Product__c != null) po_List[i].Name = null;// Shaguftha added the if condition on 31/07/23 please don't remove this condition.... It is added for the custom product wher the product lookup will not be avaialble(So the name entered by user will be lost) and the name will be set to the record Id //Moin added this on 09th june 2023
                    if(Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Purchase_Orders__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Purchase_Orders__c.isUpdateable()) po_List[i].ERP7__Purchase_Orders__c = porders.id;
                    if(Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Organisation__c.isUpdateable()) po_List[i].ERP7__Organisation__c = porders.ERP7__Organisation__c;
                    if(Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Sort_Order__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Sort_Order__c.isUpdateable()) po_List[i].ERP7__Sort_Order__c = i+1;
                    //if(po_List[i].ERP7__Sort_Order__c!=null && po_List[i].ERP7__Sort_Order__c!='') po_List[i].ERP7__Sort_Order__c 
                }
                if(po_List.size()>0 && Schema.sObjectType.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.isUpdateable()){ insert po_List; }else{ }
                
                Id plSoId = po_List[0].ERP7__Sales_Order__c;
                
                if(plSoId != null) if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Sales_Order__c.isUpdateable()) porders.ERP7__Sales_Order__c = plSoId;
                
                //if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Pick_Pack__c.isUpdateable()) porders.ERP7__Ready_To_Pick_Pack__c=Ready_To_Pick_Pack;  //Commented By Parveez On 19/10/2023 for preventing ready to pick & pack from default false
                
                //if(Schema.sObjectType.ERP7__PO__c.isUpdateable()){ update porders;}else{ }
                
            }
            else{
                porders = (ERP7__PO__c) JSON.deserialize(purchaseOrder, ERP7__PO__c.class);
                //if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order_Date__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order_Date__c.isUpdateable() && (orderId == null || orderId =='')) porders.ERP7__Order_Date__c = system.today();
                if(orderId != null && orderId !='') if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order__c.isUpdateable())porders.ERP7__Order__c = orderId;
                List<Purchase_Line_Items__c> po_List = (List<Purchase_Line_Items__c>) JSON.deserialize(POLI_List, List<Purchase_Line_Items__c>.class);
                
                Boolean Ready_To_Receive = false;
                if(porders.ERP7__Ready_To_Receive__c){
                    Ready_To_Receive = porders.ERP7__Ready_To_Receive__c;
                    if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Receive__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Receive__c.isUpdateable() ) porders.ERP7__Ready_To_Receive__c = false;
                }             
                //&& Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Receive__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Receive__c.isUpdateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order_Date__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.ERP7__Order_Date__c.isUpdateable()
                if(porders != null ){ if(Schema.sObjectType.ERP7__PO__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.isUpdateable()) {upsert porders; }else { } }else { }
                
                for(Integer i = 0;i<po_List.size();i++){
                    //po_List[i].Id= null;
                    if(po_List[i].ERP7__Product__c != null) po_List[i].Name = null;//Moin added this on 09th june 2023
                    if(Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Purchase_Orders__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Purchase_Orders__c.isUpdateable()) po_List[i].ERP7__Purchase_Orders__c = porders.id;
                    if(Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Organisation__c.isUpdateable()) po_List[i].ERP7__Organisation__c = porders.ERP7__Organisation__c;
                    if(Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Sort_Order__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.ERP7__Sort_Order__c.isUpdateable()) po_List[i].ERP7__Sort_Order__c = i+1;
                    //if(po_List[i].ERP7__Sort_Order__c!=null && po_List[i].ERP7__Sort_Order__c!='') po_List[i].ERP7__Sort_Order__c 
                }
                system.debug('porders.ERP7__Organisation__c--'+porders.ERP7__Organisation__c);
                if(po_List.size()>0 && Schema.sObjectType.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.isUpdateable()){ upsert po_List; }else{ }
                
                Id plSoId = po_List[0].ERP7__Sales_Order__c;
                
                if(plSoId != null) if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Sales_Order__c.isUpdateable()) porders.ERP7__Sales_Order__c = plSoId;
                
                if(Schema.sObjectType.ERP7__PO__c.fields.ERP7__Ready_To_Receive__c.isUpdateable()) porders.ERP7__Ready_To_Receive__c=Ready_To_Receive;
                
                if(Schema.sObjectType.ERP7__PO__c.isUpdateable()){ update porders;}else{ }
                
                if(rfpSupp != null && rfpSupp != '' && rfpReq != null && rfpReq != '' && porders.ERP7__Request__c != null){
                    ERP7__Request_Supplier__c reqSupplier = (ERP7__Request_Supplier__c) JSON.deserialize(rfpSupp, ERP7__Request_Supplier__c.class);
                    ERP7__Request__c req = (ERP7__Request__c) JSON.deserialize(rfpReq, ERP7__Request__c.class);
                    if(req != null && Schema.sObjectType.ERP7__Request__c.fields.ERP7__Status__c.isUpdateable()) req.ERP7__Status__c = 'Closed';
                    if(req != null && Schema.sObjectType.ERP7__Request__c.isUpdateable()){ update req; }else{ }
                    if(reqSupplier != null && Schema.sObjectType.ERP7__Request_Supplier__c.fields.ERP7__Is_Approved__c.isUpdateable()) reqSupplier.ERP7__Is_Approved__c = true;
                    if(reqSupplier != null && Schema.sObjectType.ERP7__Request_Supplier__c.isUpdateable()){ update reqSupplier; }else{ }
                }
                if(shipmentid != null && shipmentid !=''){
                    ERP7__Shipment__c ship = [select Id,Name,ERP7__Purchase_Orders__c from ERP7__Shipment__c where Id=:shipmentid];
                    if(Schema.sObjectType.ERP7__Shipment__c.fields.ERP7__Purchase_Orders__c.isUpdateable()) ship.ERP7__Purchase_Orders__c = porders.id;
                    if(Schema.sObjectType.ERP7__Shipment__c.isUpdateable()) { update ship; }else{ }
                } 
                if(pacakgeids.size() > 0){
                    List<ERP7__Package__c> packListtoupdate= new List<ERP7__Package__c>();
                    List<ERP7__Package__c> packList = [Select Id,Name ,ERP7__Purchase_Order__c from ERP7__Package__c where id in : pacakgeids];
                    for(ERP7__Package__c pack : packList){
                        if(Schema.sObjectType.ERP7__Package__c.fields.ERP7__Purchase_Order__c.isUpdateable()) pack.ERP7__Purchase_Order__c = porders.id;
                        packListtoupdate.add(pack);
                    }
                    if(Schema.sObjectType.ERP7__Package__c.isUpdateable()){ update packListtoupdate; }else{ }
                }
                
            }
            
            if(filesDataList.size() > 0 && porders.Id != null){
                for (FileData fileData : filesDataList) {
                    system.debug('fileData.fileName~>'+fileData.fileName);
                    
                    fileData.base64Data = EncodingUtil.urlDecode(fileData.base64Data, 'UTF-8');  
                    Attachment a = new Attachment();                    a.parentId = porders.Id;                     a.Body = EncodingUtil.base64Decode(fileData.base64Data);                  a.Name = fileData.fileName;                    a.ContentType = fileData.contentType;                    attachmentsToInsert.add(a);
                }
                system.debug('attachmentsToInsert~>'+attachmentsToInsert.size());
                if(attachmentsToInsert.size() > 0 && Schema.SObjectType.Attachment.isCreateable()){ insert attachmentsToInsert; } else{ }
            }
            return porders;
        }catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        } 
    }
    
    @AuraEnabled
    public static void saveAttachmentsApex(String attachments) {
        try {
            List<AttachmentWrapper> attachmentList = (List<AttachmentWrapper>) JSON.deserialize(attachments, List<AttachmentWrapper>.class);
            List<Attachment> attachmentsToInsert = new List<Attachment>();

            for (AttachmentWrapper fileData : attachmentList) {                Attachment attachment = new Attachment();                attachment.ParentId = fileData.parentId;                attachment.Body = EncodingUtil.base64Decode(fileData.base64Data);                attachment.Name = fileData.fileName;                attachment.ContentType = fileData.contentType;                attachmentsToInsert.add(attachment);
            }

            if (attachmentsToInsert.size() > 0) {                insert attachmentsToInsert;
            }
        } catch (Exception e) {
            system.debug('Error : '+e.getLineNumber()+' msg : '+e.getMessage());
            throw new AuraHandledException('Error saving attachments: ' + e.getMessage());
        }
    }

    public class AttachmentWrapper {
        public String fileName;
        public String base64Data;
        public String contentType;
        public String parentId;
    }
    //Added by Arshad 04 Dec 23 to save po and save attachments together in same synchronous process
    public class FileData {
        @AuraEnabled
        public String parentId;
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String base64Data;
        @AuraEnabled
        public String contentType;
    }
    
    @AuraEnabled
    public static CCWrapper fetchPrice(String ccId){ 
        if(String.isNotEmpty(ccId)){ 
            CCWrapper ccWrapper=new CCWrapper();
            ccWrapper.multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            ERP7__Cost_Card__c cc = new ERP7__Cost_Card__c(); 
            
            if(ccWrapper.multiCurrencyEnabled){                cc=Database.Query('SELECT Id,CurrencyIsoCode,ERP7__Supplier__c, Name,ERP7__Cost__c, ERP7__Product__c, ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Quantity__c,ERP7__Vendor_Part_Number__c FROM ERP7__Cost_Card__c WHERE Id=:ccId');
            }else{
                cc=[SELECT Id,Name,ERP7__Cost__c, ERP7__Product__c,ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c, ERP7__Quantity__c,ERP7__Vendor_Part_Number__c,ERP7__Supplier__c FROM ERP7__Cost_Card__c WHERE Id=:ccId];
            }
            
            if(cc != null){
                Id prodId = cc.ERP7__Product__c;
                Id SupplierId = cc.ERP7__Supplier__c;
                if(prodId != null && SupplierId != null){
                    List<ERP7__Approved_Vendor__c> app = [Select Id,Name,ERP7__Lead_Time__c from ERP7__Approved_Vendor__c where  ERP7__Product__c=: cc.ERP7__Product__c and ERP7__Vendor__c=:SupplierId and ERP7__Lead_Time__c != null and ERP7__Cost_Card__c = :ccId Limit 1];
                    if(app.size() > 0) ccWrapper.LeadTime = app[0].ERP7__Lead_Time__c;
                }
                else if(prodId != null && prodId != ''){
                    if(cc.ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c != null) ccWrapper.LeadTime = cc.ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c;
                    else ccWrapper.LeadTime = 0;
                }
            }
            
            if(cc.ERP7__Cost__c == null) cc.ERP7__Cost__c=0.00; 
            if(cc.ERP7__Quantity__c == null) cc.ERP7__Quantity__c=0;  
            
            ccWrapper.costcard = cc;
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ 
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
            }
            system.debug('FC : '+FC);
            if(FC != null){
                system.debug('FC unit price: '+FC.ERP7__Enable_Unit_price_edit_in_PO__c);
                ccWrapper.editUnitPrice = FC.ERP7__Enable_Unit_price_edit_in_PO__c;
            }
            
            return ccWrapper;//.ERP7__Cost__c;
        } else return null;
        
        // return 20;                                           
    }
    
    @AuraEnabled
    public static list<ERP7__Cost_Card__c> fetchCostCardIds(String vendorId){  
        if(String.isNotEmpty(vendorId)){                                             
            list<ERP7__Approved_Vendor__c> avList=[SELECT Id, Name, ERP7__Cost_Card__c FROM ERP7__Approved_Vendor__c WHERE ERP7__Vendor__c=:vendorId];
            Map<String,String> ccIds=new Map<String,String>();  
            for(ERP7__Approved_Vendor__c v:avList) ccIds.put(v.ERP7__Cost_Card__c, v.Id); 
            list<ERP7__Cost_Card__c> ccList=[SELECT Id, Name FROM ERP7__Cost_Card__c WHERE Id IN:ccIds.keySet()];  
            return ccList;    } else return null;                                          
    }
    /* @AuraEnabled
public static ERP7__Cost_Card__c fetchvenCC(String vendorId, String productId){  
List<ERP7__Cost_Card__c> ccRec = new List<ERP7__Cost_Card__c> ();
try{
if(String.isNotEmpty(vendorId) && String.isNotEmpty(productId)){
ERP7__Approved_Vendor__c app = [Select Id,Name ,ERP7__Cost_Card__c , ERP7__Product__c, ERP7__Vendor__c from ERP7__Approved_Vendor__c where Id= :vendorId and ERP7__Product__c =:productId];
string ccid = app.ERP7__Cost_Card__c;
ccRec = [SELECT Id, Name, ERP7__Product__c, ERP7__Supplier__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Cost__c, ERP7__Quantity__c,ERP7__Default__c 
FROM ERP7__Cost_Card__c 
WHERE ERP7__Product__c =:productId And
Id = :ccid
Order by CreatedDate Desc Limit 1];
}
}
catch(Exception e){
// 'Error at : '+e.getLineNumber()+'message : '+e.getMessage() 
}
if(!ccRec.isEmpty())
{  return ccRec[0]; }
else
{ return null; }
}*/
    
    @AuraEnabled
    public static ERP7__Cost_Card__c fetchProductCC(String vendorId, String productId){  
        /* '*** fetchProductCC vendorId==>'+vendorId */
        /* '*** fetchProductCC productId==>'+productId */
        List<ERP7__Cost_Card__c> ccRec = new List<ERP7__Cost_Card__c> ();
        try{
            if(String.isNotEmpty(vendorId) && String.isNotEmpty(productId)){
                ccRec = [SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c, ERP7__Supplier__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Cost__c, ERP7__Quantity__c,ERP7__Default__c 
                         FROM ERP7__Cost_Card__c 
                         WHERE ERP7__Product__c =:productId And
                         ERP7__Supplier__c =:vendorId  And
                         ERP7__End_Date__c >=: system.today() And
                         ERP7__Cost__c > 0.00 And
                         ERP7__Quantity__c > 0.00
                         Order by CreatedDate Desc Limit 1];
            }
            else if(String.isBlank(vendorId) && String.isNotEmpty(productId)){
                ccRec = [SELECT Id, Name, ERP7__Product__c, ERP7__Supplier__c, ERP7__Start_Date__c,ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c, ERP7__End_Date__c, ERP7__Cost__c, ERP7__Quantity__c,ERP7__Default__c 
                         FROM ERP7__Cost_Card__c 
                         WHERE ERP7__Product__c =:productId And
                         ERP7__Default__c =: true And ERP7__Supplier__c ='' And
                         ERP7__End_Date__c >=: system.today() And
                         ERP7__Cost__c > 0.00 And
                         ERP7__Quantity__c > 0.00
                         Order by CreatedDate Desc Limit 1];
            }
            else return null;
            
        }catch(Exception e){
            /* 'Error at : '+e.getLineNumber()+'message : '+e.getMessage() */
        }
        if(!ccRec.isEmpty())
        {  return ccRec[0]; }
        else
        { return null; }
        
    }
    
    @AuraEnabled
    public static Product2 fetchProductDesc(String productId){  
        if(String.isNotEmpty(productId)) return [Select Id, Name, ERP7__Vendor_Supplier_Description__c,ERP7__Vendor_product_Name__c, ERP7__Version__c, ERP7__Inventory_Account__c, ERP7__Project__c, ERP7__Project__r.ERP7__Account_Category__c from Product2 where Id =: productId Limit 1];
        else return null;
    }
    
    @AuraEnabled
    public static Account getVendorDetails(String AccId){  
        if(String.isNotEmpty(AccId)) return [SELECT Id, Name, ERP7__Payment_Terms__c FROM Account WHERE Id=:AccId];  
        else return null;                                          
    }
    
    
    @AuraEnabled
    public static ERP7__Employees__c fetchEmployeeRequester(){  
        List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
        empList = [SELECT Id, Name FROM ERP7__Employees__c WHERE ERP7__Employee_User__c=:UserInfo.getUserId() limit 1];  
        if(empList.size()>0) return empList[0];
        else return null;                                          
    }
    
    @AuraEnabled
    public static AccWrapper getVendorDetailsNew(String AccId, String proIds){  
        /* '*** getVendorDetails AccId==>'+AccId */
        AccWrapper AW = new AccWrapper();
        List<String> productIds = proIds.split(',');
        if(String.isNotEmpty(AccId)) { 
            Date tody = system.Today();
            AW.Acc = [SELECT Id, Name, ERP7__Payment_Terms__c FROM Account WHERE Id=:AccId]; 
            AW.ApprovedVendorPrice = [SELECT Id, Name, ERP7__Vendor__c, ERP7__Cost_Card__r.ERP7__Quantity__c, ERP7__Product__c, ERP7__Cost_Card__r.ERP7__Cost__c, ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c, ERP7__Lead_Time__c, ERP7__Status__c, ERP7__Type__c, ERP7__Cost_Card__c 
                                      FROM ERP7__Approved_Vendor__c 
                                      WHERE ERP7__Vendor__c=:AccId And 
                                      ERP7__Product__c In :productIds And 
                                      ERP7__Cost_Card__r.ERP7__Cost__c >= 0 And 
                                      ERP7__Cost_Card__r.ERP7__Active__c = true And 
                                      ERP7__Cost_Card__r.ERP7__Quantity__c >= 0 And 
                                      ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c >= 0 And 
                                      ERP7__Cost_Card__r.ERP7__Start_Date__c <= TODAY And 
                                      ERP7__Cost_Card__r.ERP7__End_Date__c >= TODAY]; 
            
            List<Contact> Contacts = [SELECT Id, Name, AccountId, ERP7__Primary__c FROM Contact WHERE AccountId =: AccId];
            if(Contacts.size() == 1) AW.Con = Contacts[0];
            else if(Contacts.size() > 1) {
                for(Contact con : Contacts){ 
                    //if(con.ERP7__Primary__c == true){
                    AW.Con = con;
                    break;
                    //}
                }
            }
        }
        return AW;                                          
    }
    
    @AuraEnabled
    public static AddressWrapper getOrgAddressDetails(String AccId){  
        AddressWrapper AW = new AddressWrapper();
        if(String.isNotEmpty(AccId)) {
            List<ERP7__Address__c> Addresses = [SELECT Id, Name, ERP7__Active__c, ERP7__Is_Billing_Address__c, ERP7__Is_Shipping_Address__c, ERP7__Customer__c, ERP7__Primary__c FROM ERP7__Address__c WHERE ERP7__Active__c = true And ERP7__Customer__c =: AccId And (ERP7__Is_Billing_Address__c = true Or ERP7__Is_Shipping_Address__c = true) Order By ERP7__Primary__c DESC LIMIT 100];
            if(Addresses.size() > 0) {
                for(ERP7__Address__c Address : Addresses){
                    if(Address.ERP7__Is_Billing_Address__c == true){                        AW.InvAdd = Address;                        break;
                    }
                }
                for(ERP7__Address__c Address : Addresses){
                    if(Address.ERP7__Is_Shipping_Address__c == true){                        AW.DelAdd = Address;                        break;
                    }
                }
            }
        }
        return AW;                                          
    }
    
    @AuraEnabled
    global static Account getDefaultVendor(String SelectedSite, List<String> ProIds)
    {    
        Account Acc = new Account();
        if(SelectedSite != '' && SelectedSite != null && ProIds != null && ProIds.size() > 0){
            List<Product2> products = [Select Id, Name, ERP7__Default_Vendor__c from Product2 where Id In: ProIds And ERP7__Default_Vendor__c != null order by ERP7__Default_Vendor__r.Name ASC Limit 1];
            if(products.size() > 0){                Acc = [Select Id, Name From Account Where Id =: products[0].ERP7__Default_Vendor__c];
            }   
        }
        
        return Acc;
    }
    @AuraEnabled
    Public Static ProductStock getstocks(String DCId,String ProductId){
        ProductStock pr = new ProductStock();
        Decimal myStock = 0.0;
        Decimal demand=0.0;
        Decimal Awaitingstock = 0.0;
        set<Id> siteIds = new set<Id>(); 
        if(String.isNotEmpty(DCId)) {
            List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                From Distribution_Channel__c
                                                                Where 
                                                                Id=:DCId And Active__c = true order by ERP7__Priority__c ASC Limit 1];
            
            if(DistributionChannels.size() > 0) siteIds.add(DistributionChannels[0].Site__c);
        }
        
        system.debug('siteIds : '+siteIds);
        if(String.isNotEmpty(ProductId)){ 
            List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
            if(siteIds.size() > 0){
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c
                                                Where product__c =: ProductId And
                                                Active__c = true And
                                                Warehouse__c In: siteIds and 
                                                (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
            }
            else{
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c
                                                Where product__c =: ProductId And
                                                Active__c = true And
                                                (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
                
            }
            
            for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                myStock += WIIS.Number_of_Item_In_Stock__c;                  demand += WIIS.ERP7__No_of_Items_Requested__c;                  Awaitingstock += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                
            }
            
            pr.Product = ProductId;
            pr.Demand = demand;
            pr.Stock = myStock;
            pr.AwaitingStocks=Awaitingstock;
        }
        return pr;
        
    }
    @AuraEnabled
    Public Static list<PRWrap> getExistingPO(String SOId,String OrderId){ 
        list<PRWrap> ReqList=new list<PRWrap>(); 
        if(String.isNotEmpty(SOId)){  
            list<ERP7__PO__c>  RList=[SELECT Id, Name, ERP7__Sales_Order__c ,ERP7__Sales_Order__r.Name ,ERP7__Active__c, ERP7__Vendor__c, ERP7__Vendor__r.Name, ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Name,ERP7__Status__c,ERP7__Delivery_Address__c,ERP7__Delivery_Address__r.Name
                                      FROM ERP7__PO__c 
                                      WHERE ERP7__Sales_Order__c=:SOId AND ERP7__Active__c=true Order By createdDate ASC];
            
            
            for(ERP7__PO__c log:RList) {  PRWrap w=new PRWrap();  w.Id=log.Id; w.Name=log.Name;  w.Order=log.ERP7__Sales_Order__r.Name;  w.Contact=log.ERP7__Vendor_Contact__r.Name;  w.Vendor=log.ERP7__Vendor__r.Name; w.Status=log.ERP7__Status__c; w.ToAddress=log.ERP7__Delivery_Address__r.Name;  ReqList.add(w); 
                                       }
            return ReqList;   
        }
        else if(String.isNotEmpty(OrderId)){
            list<ERP7__PO__c>  RList=[SELECT Id, Name, ERP7__Active__c,ERP7__Order__c,ERP7__Order__r.OrderNumber, ERP7__Vendor__c, ERP7__Vendor__r.Name, ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Name,ERP7__Status__c,ERP7__Delivery_Address__c,ERP7__Delivery_Address__r.Name
                                      FROM ERP7__PO__c 
                                      WHERE ERP7__Order__c=:OrderId AND ERP7__Active__c=true Order By createdDate ASC];
            
            
            for(ERP7__PO__c log:RList) {  PRWrap w=new PRWrap();  w.Id=log.Id; w.Name=log.Name;  w.Order=log.ERP7__Order__r.OrderNumber;  w.Contact=log.ERP7__Vendor_Contact__r.Name;  w.Vendor=log.ERP7__Vendor__r.Name; w.Status=log.ERP7__Status__c; w.ToAddress=log.ERP7__Delivery_Address__r.Name; ReqList.add(w); 
                                       }
            return ReqList;  
        } else return null;                                                           
        
    } 
    
    @AuraEnabled
    public static void deletePOLI(List<String> itemToDel){
        List<ERP7__Purchase_Line_Items__c> POLIToDel=[Select Id,Name from ERP7__Purchase_Line_Items__c where Id In:itemToDel];
        if(ERP7__Purchase_Line_Items__c.sObjectType.getDescribe().isDeletable()) { delete POLIToDel; } else { }
    }
    
    @AuraEnabled
    public static Id getRecentRecord(String ObjectAPIName){
        DateTime dt = system.now().addminutes(-1);
        String query = 'select Id, Name From '+ObjectAPIName+' where createddate>:dt'+' order by createddate desc';
        system.debug('query-->'+query);
        List<sObject> sList = new List<sObject>();
        sList = database.query(query);
        if(sList.size()>0) return sList[0].Id;
        else return null;
    }
    
    @AuraEnabled
    public static Contact getRecentContact(){
        DateTime dt = system.now().addminutes(-1);
        String query = 'select Id, Name, AccountId From Contact'+' where createddate>:dt'+' order by createddate desc';
        system.debug('query-->'+query);
        List<Contact> sList = new List<Contact>();
        sList = database.query(query);
        if(sList.size()>0) return sList[0];
        else return null;
    }
    
    @AuraEnabled
    public static ERP7__Address__c getRecentDA(){
        DateTime dt = system.now().addminutes(-1);
        String query = 'select Id, ERP7__Customer__c, ERP7__Contact__c From ERP7__Address__c'+' where createddate>:dt'+' order by createddate desc';
        system.debug('query-->'+query);
        List<ERP7__Address__c> sList = new List<ERP7__Address__c>();
        sList = database.query(query);
        if(sList.size()>0) return sList[0];
        else return null;
    }
    @AuraEnabled
    public static shipwrapper getpacklistdetails(String shipId, List<string> Packid)
    {
        shipwrapper swrap = new shipwrapper();
        ERP7__PO__c po = new ERP7__PO__c();
        string channelid,DCid = '';
        ERP7__Shipment__c shiprecord = new ERP7__Shipment__c();
        List<Contact> conlist = new List<Contact>();
        Account carrAcc = new Account();
        List<ERP7__Address__c> addlist = new List<ERP7__Address__c>();
        try{
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                       ERP7__Organisation_Business_Unit__c,ERP7__Channel__r.ERP7__Organisation__c
                       From ERP7__Employees__c
                       Where ERP7__Employee_User__c = : UserInfo.getUserId()
                       Order by CreatedDate Asc Limit 1];
            
            if(shipId !=null){
                shiprecord = [Select Id,Name ,ERP7__Billing_Address__c ,ERP7__Carrier_Forwarder__c, ERP7__Customer__c,ERP7__Purchase_Orders__c,ERP7__Shipping_Address__c,ERP7__Logistic__c,ERP7__Logistic__r.ERP7__Channel__c,ERP7__Logistic__r.ERP7__Distribution_Channel__c,ERP7__Carrier_Forwarder__r.Name,ERP7__Sales_Order__c FROM ERP7__Shipment__c where Id = :shipId];
                if(shiprecord.ERP7__Carrier_Forwarder__c != null) 
                {
                    carrAcc = [Select Id , Name   from Account Where Id=:shiprecord.ERP7__Carrier_Forwarder__c   limit 1];     conlist = [Select Id,Name,ERP7__Primary__c ,AccountId From Contact where AccountId=:shiprecord.ERP7__Carrier_Forwarder__c and ERP7__Primary__c = :true];  addlist = [Select Id,Name, ERP7__Customer__c From ERP7__Address__c where ERP7__Customer__c=:shiprecord.ERP7__Carrier_Forwarder__c];
                    
                }
                Account acc = [Select Id , Name   from Account Where Id=:empList[0].ERP7__Channel__r.ERP7__Organisation__c   limit 1];
                
                po.Name = 'PO-'+shiprecord.Name;                po.ERP7__Active__c = true;
                
                po.ERP7__Customer__c = shiprecord.ERP7__Customer__c;
                if(carrAcc.id != null || carrAcc.id != ''){                     po.ERP7__Vendor__c = carrAcc.id;                    po.ERP7__Vendor__r = new Account(Id = carrAcc.id,Name=carrAcc.Name); 
                    if(conlist.size() > 0 ) po.ERP7__Vendor_Contact__c = conlist[0].id;
                    if(addlist.size() > 0 )  po.ERP7__Vendor_Address__c = addlist[0].id;}
                if(acc.id != null || acc.id != '')
                {
                    po.ERP7__Organisation__c = acc.Id;                    po.ERP7__Organisation__r = new Account(Id = acc.Id,Name=acc.Name);                    po.ERP7__Delivery_Address__c = shiprecord.ERP7__Shipping_Address__c;                    po.ERP7__Invoice_Address__c = shiprecord.ERP7__Billing_Address__c;
                }
                
                po.ERP7__Expected_Date__c = system.today();                po.ERP7__Status__c = 'New';                po.ERP7__EmployeeRequester__c = empList[0].Id;                po.ERP7__Sales_Order__c = shiprecord.ERP7__Sales_Order__c;                channelid = shiprecord.ERP7__Logistic__r.ERP7__Channel__c;                DCid = shiprecord.ERP7__Logistic__r.ERP7__Distribution_Channel__c;
                
            }
        }catch(Exception e){ /* 'Error at: '+e.getLineNumber()+'Message : '+e.getMessage() */ }
        /* if(Packid != null && shipId == null){
for(string getid : Packid) packids.add(getid);

}*/
        
        /* if(packids.size() > 0){
packitems = [Select Id, Name, ERP7__Package__c,ERP7__Quantity__c,ERP7__Logistic_Line_Item__c,ERP7__Logistic_Line_Item__r.ERP7__Price_Product__c ,ERP7__Logistic_Line_Item__r.ERP7__Product__c,ERP7__Logistic_Line_Item__r.ERP7__Product__r.Name,ERP7__Logistic__c,ERP7__Logistic__r.ERP7__Channel__c,ERP7__Logistic__r.ERP7__Distribution_Channel__c  from ERP7__Package_List__c where ERP7__Package__c in: packids];
for(ERP7__Package_List__c packeditem : packitems){
prodids.add(packeditem.ERP7__Logistic_Line_Item__r.ERP7__Product__c);
}
if(prodids.size()>0){
costcards = [Select Id,name,ERP7__Product__c,ERP7__Cost__c from ERP7__Cost_Card__c where ERP7__Product__c in :prodids AND ERP7__Active__c = true And ERP7__Quantity__c >= 0 And ERP7__Minimum_Quantity__c >= 0 And ERP7__Start_Date__c <=:system.today()And ERP7__End_Date__c >=: system.today() Limit 1] ; 
for(ERP7__Cost_Card__c cost : costcards) costandProMap.put(cost.ERP7__Product__c,cost.ERP7__Cost__c);
}
for(ERP7__Package_List__c packeditem : packitems){
swrap.channelid = packeditem.ERP7__Logistic__r.ERP7__Channel__c;
swrap.DCid = packeditem.ERP7__Logistic__r.ERP7__Distribution_Channel__c;

ERP7__Purchase_Line_Items__c prli=new ERP7__Purchase_Line_Items__c();
prli.Name =  packeditem.Id;
prli.ERP7__Product__c=packeditem.ERP7__Logistic_Line_Item__r.ERP7__Product__c;
prli.ERP7__Product__r=new Product2(Id=packeditem.ERP7__Logistic_Line_Item__r.ERP7__Product__c,Name=packeditem.ERP7__Logistic_Line_Item__r.ERP7__Product__r.Name);
prli.Quantity__c = packeditem.ERP7__Quantity__c;
if(costandProMap.containsKey(packeditem.ERP7__Logistic_Line_Item__r.ERP7__Product__c)) prli.ERP7__Unit_Price__c = costandProMap.get(packeditem.ERP7__Logistic_Line_Item__r.ERP7__Product__c);
else prli.ERP7__Unit_Price__c = 0;
prli.ERP7__Total_Price__c = prli.Quantity__c * prli.ERP7__Unit_Price__c;
for(ERP7__Cost_Card__c cc : costcards){
if(cc.ERP7__Product__c == packeditem.ERP7__Logistic_Line_Item__r.ERP7__Product__c){
prli.ERP7__Cost_Card__c = cc.id;
}
}
prliList.add(prli);
}

}*/
        swrap.shipPO = po;
        swrap.channelid = channelid;
        swrap.DCid = DCid;
        return swrap;
    }
    
    Public class PRWrap{
        @AuraEnabled
        public String Id {get;set;} 
        @AuraEnabled
        public String Name {get;set;} 
        @AuraEnabled
        public String Order {get;set;} 
        @AuraEnabled
        public String Contact {get;set;} 
        @AuraEnabled
        public String ToAddress {get;set;} 
        @AuraEnabled
        public String  Status {get;set;} 
        @AuraEnabled
        public String  Vendor {get;set;} 
        
        public PRWrap(){            Name=Order=Contact=Vendor=ToAddress=Status='';    
        }    
        
    }
    
    global List<newWrapper> poliWrapperList                { get; set; }
    
    global class newWrapper {
        global Purchase_Line_Items__c poli                { get; set; }
        global Work_Order_Line_Items__c woli              { get; set; }  
        global Integer ident                              { get; set; } 
        
        global newWrapper(Integer inIdent) {
            try{
                ident = inIdent;
                poli = new Purchase_Line_Items__c(Unit_Price__c=0.00);
                woli = new Work_Order_Line_Items__c();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        }
    }
    
    public class AccWrapper {
        @AuraEnabled public Account Acc                                                       { get; set; }
        @AuraEnabled public Contact Con                                                       { get; set; }
        @AuraEnabled public List< ERP7__Approved_Vendor__c > ApprovedVendorPrice              { get; set; }  
        
        public AccWrapper() {
            Acc = new Account(ERP7__Payment_Terms__c = 0);
            Con = new Contact();
            ApprovedVendorPrice = new List< ERP7__Approved_Vendor__c >();
        }
    }
    
    public class AddressWrapper {
        @AuraEnabled public ERP7__Address__c InvAdd                                                       { get; set; }
        @AuraEnabled public ERP7__Address__c DelAdd                                                       { get; set; }
        
        public AddressWrapper() {
            InvAdd = new ERP7__Address__c();
            DelAdd = new ERP7__Address__c();
        }
    }
    
    public class CCWrapper{
        @AuraEnabled public ERP7__Cost_Card__c costcard                                                         { get; set; }
        @AuraEnabled public Boolean multiCurrencyEnabled                                                  { get; set; }
        @AuraEnabled public Boolean editUnitPrice                                                  { get; set; }
        @AuraEnabled public Decimal LeadTime                                                       { get; set; }
        public CCWrapper(){
            costcard=new ERP7__Cost_Card__c();
            multiCurrencyEnabled=false;
            editUnitPrice = false;
            LeadTime = 0;
        }
    }
    
    public class POWrapper{
        @AuraEnabled public ERP7__PO__c wPO                                         { get; set; }
        @AuraEnabled public List<ERP7__Purchase_Line_Items__c> wPOLIs               { get; set; }
        @AuraEnabled public List<ERP7__Dimension__c> demLIs               { get; set; }
        @AuraEnabled public Boolean displayTax                                      { get; set; }
        @AuraEnabled public Boolean displayAllocations                                    { get; set; }
        @AuraEnabled public Boolean displayTaxRate                                     { get; set; }
        @AuraEnabled public Boolean displayVersion                                      { get; set; }
        @AuraEnabled public Boolean displayQuote                                      { get; set; }
        @AuraEnabled public Boolean displayVPO                                      { get; set; }
        @AuraEnabled public Boolean displayName                                      { get; set; }
        @AuraEnabled public Boolean displayDCBelow                                      { get; set; }
        @AuraEnabled public Boolean isBilled                                      { get; set; }
        @AuraEnabled public List<ProductStock> productStocks                        { get; set; }
        @AuraEnabled public List<ProjectBudget> Projbudgets                        { get; set; }
        @AuraEnabled public List<ERP7__PO__c> existingReturnPOs                                         { get; set; }
        @AuraEnabled public List<ERP7__Purchase_Line_Items__c> existingReturnPOLIs               { get; set; }
        @AuraEnabled public String  CommonVendor                                      { get; set; }
        @AuraEnabled public String  CommonVendorMessage                                      { get; set; }
        @AuraEnabled public String  ErrMessage                                      { get; set; }
    }
    public class shipwrapper{
        @AuraEnabled public ERP7__PO__c shipPO              { get; set; }
        @AuraEnabled public String channelid                                           { get; set; }
        @AuraEnabled public String DCid                                                { get; set; }
        public shipwrapper(){
            shipPO = new ERP7__PO__c();
            channelid = DCid = '';
        }
    }
    
    public class ProductStock{
        @AuraEnabled public Decimal Demand                                  {get; set;}
        @AuraEnabled public Decimal Stock                                   {get; set;}
        @AuraEnabled public Decimal AwaitingStocks                          {get; set;}
        @AuraEnabled public String Product                                  {get; set;}
        public ProductStock(){
            Demand = 0.0;Stock = 0.0; AwaitingStocks = 0.0;
            Product = '';
        }
        
    }
    
    public class PRStock{
        @AuraEnabled public Decimal Demand                                  {get; set;}
        @AuraEnabled public Decimal Stock                                   {get; set;}
        @AuraEnabled public Decimal AwaitingStocks                          {get; set;}
        @AuraEnabled public Purchase_Line_Items__c Prs                                  {get; set;}
        public PRStock(){
            Demand = 0.0;Stock = 0.0; AwaitingStocks = 0.0;
            Prs = new Purchase_Line_Items__c();
        }
        
    }
    
    
    public class AnalyticalAccount{
        @AuraEnabled public Decimal Demand                                  {get; set;}
        @AuraEnabled public Decimal ItemsinStock                                   {get; set;}
        @AuraEnabled public Decimal AwaitingStocks                          {get; set;}
        @AuraEnabled public Decimal projBudget                                  {get; set;}
        @AuraEnabled public Decimal projCommittedBudget                                   {get; set;}
        @AuraEnabled public Decimal projConsumedBudget                          {get; set;}
        @AuraEnabled public Decimal projRemainingBudget                          {get; set;}
        @AuraEnabled public Purchase_Line_Items__c Prs                                  {get; set;}
        @AuraEnabled public List<ERP7__Dimension__c> Accounts                 {get;set;}
        public AnalyticalAccount(){            Demand = 0.0;ItemsinStock = 0.0; AwaitingStocks = 0.0;
            projCommittedBudget = projCommittedBudget = projConsumedBudget = projRemainingBudget;
            Prs = new Purchase_Line_Items__c();            Accounts = new List<ERP7__Dimension__c>();
        }
        
    }
    
    // For dependent Picklist
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    //Changed by Arshad 10 jul 23 - to show seperate label and value along with --None-- from custom label with empty value
    @AuraEnabled 
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        System.debug('ObjectName : '+ObjectName);
        System.debug('parentField: '+parentField);
        System.debug('childField: '+childField);
        Map<String,List<SelectOptions>> pickListMap = new Map<String,List<SelectOptions>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        List<SelectOptions> controllingValues = new List<SelectOptions>();
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){            return pw;
        }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        
        
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            //pickListMap.put(ple.getLabel(), new List<SelectOptions>());//removed by Asra 06/12
            pickListMap.put(ple.getValue(), new List<SelectOptions>());
            controllingValues.add(new SelectOptions(ple.label,ple.value));
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    if(controllingValues.get(i).value != System.label.NonePicklistType){//was controllingValues.get(i).label--changed by Asra 06/12
                        pickListMap.get(controllingValues.get(i).value).add(new SelectOptions(plew.label,plew.value));//was controllingValues.get(i).label--changed by Asra 06/12
                    }
                }
            }
        }
        
        if(controllingValues.size() > 0){
            controllingValues.add(0,new SelectOptions(System.label.NonePicklistType,''));
        }
        
        pw.controllingValues = controllingValues;
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    
    //Refer from here https://salesforce.stackexchange.com/questions/4462/get-lists-of-dependent-picklist-options-in-apex
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public class PicklistWrapper{
        @AuraEnabled
        public Map<String, List<SelectOptions>> pickListMap;
        @AuraEnabled
        public List<SelectOptions> controllingValues;
        @AuraEnabled
        public String parentFieldLabel;
        @AuraEnabled
        public String childFieldLabel;      
    }
    
    public class PicklistEntryWrapper{
        public String active;
        public String defaultValue;
        public String label;
        public String value;
        public String validFor;
        
    }
    
    
    @AuraEnabled
    public static multiCurrencyWrap getCurrencies(String PoId){
        try{
            system.debug('PoId-->'+PoId);
            //commented these lines 2298 and 2318 as the currency option is not showing in the create PO manage
            // if(PoId != null && PoId != ''){
            multiCurrencyWrap mc = new multiCurrencyWrap();
            List<selectOptions> options = new List<selectOptions>();
            boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            mc.isMulticurrency = IsmultiCurrencyEnabled;
            if(IsmultiCurrencyEnabled){   
                String PoIsoCode = '';
                if(String.isNotEmpty(PoId)){                    List <ERP7__PO__c> pos = Database.Query('SELECT Id,Name,CurrencyIsoCode FROM ERP7__PO__c where Id =:PoId limit 1');    
                    if(pos.size() > 0) POIsocode = String.valueOf(pos[0].get('CurrencyIsoCode'));
                    else POIsocode = '';
                }
                mc.POIsocode = POIsocode;
                List <sObject> currencies = Database.Query('SELECT IsoCode FROM CurrencyType');    
                for(sObject a : currencies){                       options.add(new SelectOptions(String.valueof(a.get('IsoCode')),String.valueof(a.get('IsoCode')))); 
                }
                mc.currencyList = options;
            }
            return mc;
        }catch(Exception e){
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static void deleteDimensions(String demId){
        if(String.isNotEmpty(demId)){
            List<ERP7__Dimension__c> demList = new List<ERP7__Dimension__c>();
            demList = [select Id from ERP7__Dimension__c where Id=:demId];
            if(demList.size()>0){ delete demList; }
        }
    }
    
    @AuraEnabled
    public static String getOrgCurrencies(String OrgId){
        String OrgIsocode = '';
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        
        if(IsmultiCurrencyEnabled){              List <Account> accounts = Database.Query('SELECT Id,Name,CurrencyIsoCode FROM Account where Id = :OrgId limit 1');    
            if(accounts.size() > 0) OrgIsocode = String.valueOf(accounts[0].get('CurrencyIsoCode'));
            else OrgIsocode = '';
        }
        return OrgIsocode;
    }
    
    public class multiCurrencyWrap{
        @AuraEnabled public Boolean isMulticurrency {get;set;}
        @AuraEnabled public List<selectOptions> currencyList {get;set;}
        @AuraEnabled public String POIsocode {get;set;}
        public multiCurrencyWrap(){
            isMulticurrency = false;
            currencyList = new List<selectOptions>();
            POIsocode = '';
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
    
    @AuraEnabled
    public static Decimal checkforTax(String addId, String AccId){
        Decimal taxRate = 0.00;
        if(AccId!=''){
            Account acc = new Account();
            acc = [select Id, Name, ERP7__Account_Profile__c from Account where Id=:AccId];
            if(acc.ERP7__Account_Profile__c !=null){
                //ECPQ__Profiling__c profile = new ECPQ__Profiling__c();
                //profile  = [Select Id,Name,ECPQ__Channel__c,ECPQ__Price_Book__c,ECPQ__Tax_Sourcing_Rules__c from ECPQ__Profiling__c where Id =:acc.ERP7__Account_Profile__c Limit 1];
                List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();                Date todayDate = system.today();
                profileTax=[Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where ERP7__Account_Profile__c =:acc.ERP7__Account_Profile__c AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Tax_Rate__c != Null AND ERP7__Product__c = Null AND ERP7__Active__c=true Order By ERP7__Province__c DESC];
                ERP7__Address__c quoteBillToAdd= new ERP7__Address__c();
                quoteBillToAdd = [Select Id,Name,ERP7__Active__c,Erp7__City__c,Erp7__Country__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where Id =:addId AND Erp7__Active__c=true Limit 1];
                String TaxPostalCode = '';                String TaxCity = '';                String TaxProvince = '';                String TaxCountry = '';
                if(quoteBillToAdd != Null){
                    if(quoteBillToAdd.ERP7__Postal_Code__c != Null && quoteBillToAdd.ERP7__Postal_Code__c != '') TaxPostalCode = quoteBillToAdd.ERP7__Postal_Code__c;
                    if(quoteBillToAdd.ERP7__City__c != Null && quoteBillToAdd.ERP7__City__c != '') TaxCity = quoteBillToAdd.ERP7__City__c;
                    if(quoteBillToAdd.ERP7__State__c != Null && quoteBillToAdd.ERP7__State__c != '') TaxProvince = quoteBillToAdd.ERP7__State__c;
                    if(quoteBillToAdd.ERP7__Country__c != Null && quoteBillToAdd.ERP7__Country__c != '') TaxCountry = quoteBillToAdd.ERP7__Country__c;
                    system.debug('TaxPostalCode-->'+TaxPostalCode);
                    system.debug('TaxCity-->'+TaxCity);
                    system.debug('TaxProvince-->'+TaxProvince);
                    system.debug('TaxCountry-->'+TaxCountry);
                    
                    for(ERP7__Tax__c profileTax1 : profileTax){
                        system.debug('TaxPostalCode-->'+TaxPostalCode);
                        if(TaxPostalCode != null && TaxPostalCode != '' && TaxPostalCode == profileTax1.ERP7__Postal_Code__c){                            taxRate = profileTax1.ERP7__Tax_Rate__c;
                        }
                        else if(TaxCity != null && TaxCity != '' && TaxCity == profileTax1.ERP7__City__c && (profileTax1.ERP7__Postal_Code__c == null || profileTax1.ERP7__Postal_Code__c == '')){                            taxRate = profileTax1.ERP7__Tax_Rate__c;
                        }
                        else if(TaxProvince != null && TaxProvince != '' && TaxProvince == profileTax1.ERP7__Province__c  && (profileTax1.ERP7__Postal_Code__c == null || profileTax1.ERP7__Postal_Code__c == '') && (profileTax1.ERP7__City__c == null || profileTax1.ERP7__City__c == '')){                            taxRate = profileTax1.ERP7__Tax_Rate__c;
                        }
                        else if(TaxCountry != null && TaxCountry != '' && TaxCountry == profileTax1.ERP7__Country__c  && (profileTax1.ERP7__Postal_Code__c == null || profileTax1.ERP7__Postal_Code__c == '') && (profileTax1.ERP7__City__c == null || profileTax1.ERP7__City__c == '') && (profileTax1.ERP7__Province__c == null || profileTax1.ERP7__Province__c == '')){                            taxRate = profileTax1.ERP7__Tax_Rate__c;
                        }
                    }
                    system.debug('taxRate set here1~>'+taxRate);
                    return taxRate;
                }else{		return taxRate;
                }
            }else{			return taxRate; 
            }
        }else{            return taxRate;
        }
    }
    
    //For add products
    @AuraEnabled
    public static WrapLst getProducts(String venId,String searchString,string searchFamily,String DCId,Boolean search,string subFamily){
        WrapLst wrap = new WrapLst();
        if(search == null) search = false;
        wrap.globalSearch = search;
        List<wrapper> wraplist = new List<wrapper>();
        List<Product2> prodList = new List<Product2>();
        system.debug('searchFamily : '+searchFamily);
        system.debug('subFamily : '+subFamily);
        if(searchString != null && searchString != '') searchString = '%'+searchString+'%';
        system.debug('searchString : '+searchString);
        string query = '';
        /* if(!search){
query = 'Select Id,Name,Description,ProductCode,ERP7__Purchase_Lead_Time_days__c,ERP7__Vendor_product_Name__c from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true';

if( venId != null && venId != ''){ //(searchFamily == null || searchFamily == '') && (searchString == null || searchString == '') &&
query+= ' and ERP7__Default_Vendor__c = :venId';
}

if(searchFamily != null && searchFamily != ''){
query+= ' and Family = :searchFamily';
}
if(subFamily != null && subFamily != ''){
query+= ' and ERP7__Product_Service_Family__c = :subFamily';
}
if(searchString != null && searchString != ''){

system.debug('searchString : '+searchString);
query+= ' and (Name LIKE :searchString or ProductCode LIKE :searchString or StockKeepingUnit LIKE :searchString )';
}
query+= ' Order By Name Limit 100';
prodList = Database.query(query);
system.debug('prodList.size() 1 : '+prodList.size());
if(prodList.size() == 0){
set<Id> productIds = new set<Id>();
string status = 'Approved';
query = 'Select Id,Name,ERP7__Product__c from ERP7__Approved_Vendor__c where ERP7__Product__c !=null and ERP7__Product__r.ERP7__Issue_Purchase_Order__c = true and ERP7__Status__c = :status';

if(venId != null && venId != ''){
query+= ' and ERP7__Vendor__c = :venId';
}
if(searchFamily != null && searchFamily != ''){
query+= ' and ERP7__Product__r.Family = :searchFamily';
}
if(subFamily != null && subFamily != ''){
query+= ' and ERP7__Product__r.ERP7__Product_Service_Family__c = :subFamily';
}
if(searchString != null && searchString != ''){
query+= ' and (ERP7__Product__r.Name LIKE :searchString or ERP7__Product__r.ProductCode LIKE :searchString or ERP7__Product__r.StockKeepingUnit LIKE :searchString )';
}
query+= ' Order By Name Limit 100';

List<ERP7__Approved_Vendor__c> approvedVendors = Database.query(query);
for(ERP7__Approved_Vendor__c appVen:approvedVendors){
productIds.add(appVen.ERP7__Product__c);
}
system.debug('productIds : '+productIds.size());
prodList = [Select Id,Name,Description,ProductCode,ERP7__Vendor_product_Name__c ,ERP7__Purchase_Lead_Time_days__c from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true and Id IN: productIds limit 100];
}
system.debug('prodList.size() 2 : '+prodList.size());
}*/
        Map<Id,ERP7__Approved_Vendor__c> ProdVendors = new Map<Id,ERP7__Approved_Vendor__c>();
        if((venId == null || venId == '') && (searchFamily == null || searchFamily == '') && (searchString == null || searchString == '') && (subFamily == null || subFamily == '')){
            system.debug('1 if last  ');    
            //wrap.Msg = Label.No_products_avaialble_to_view_based_on_selected_vendor;
            wrap.globalSearch = true;
            prodList = [Select Id,Name,Description,ProductCode,ERP7__Vendor_product_Name__c,ERP7__Purchase_Lead_Time_days__c  from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true limit 100];
        }
        else{
            
            //Added by Arshad 12 Oct to get Approved vendor products on first page 
            set<Id> alreadyAddedAppVendProds = new set<Id>();
            if(venId != null && venId != ''){
                system.debug('vendor~>'+venId);
                List<ERP7__Approved_Vendor__c> apprVendors = new List<ERP7__Approved_Vendor__c>();
                
                string status = 'Approved';
                query = 'Select Id,Name,ERP7__Product__c from ERP7__Approved_Vendor__c where ERP7__Product__c != null AND ERP7__Product__r.ERP7__Issue_Purchase_Order__c = true AND ERP7__Status__c =: status AND ERP7__Vendor__c =:venId '; 
                query+= ' Order By Name Limit 9000 ';
                
                apprVendors = Database.query(query);
                if(apprVendors.size() > 0){
                    for(ERP7__Approved_Vendor__c appVen:apprVendors){                        alreadyAddedAppVendProds.add(appVen.ERP7__Product__c);
                        if(alreadyAddedAppVendProds.size() >= 100) break;
                    }
                }
                
                system.debug('alreadyAddedAppVendProds : '+alreadyAddedAppVendProds.size());
            }
            
            query = 'Select Id,Name,Description,ERP7__Inventory_Account__c, ProductCode,ERP7__Vendor_product_Name__c,ERP7__Purchase_Lead_Time_days__c,ERP7__Purchase_From_Approved_Vendor__c from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true';
            if(alreadyAddedAppVendProds.size() > 0 && ((searchFamily == null || searchFamily == '') && (searchString == null || searchString == '') && (subFamily == null || subFamily == ''))){                query+= ' AND Id IN :alreadyAddedAppVendProds ';
            }else{
                if(searchString != null && searchString != '') query+= ' and (Name LIKE :searchString or ProductCode LIKE :searchString or StockKeepingUnit LIKE :searchString or ERP7__Vendor_product_Name__c LIKE :searchString) ';
                if(searchFamily != null && searchFamily != '') query+= ' and Family = :searchFamily ';
                if(subFamily != null && subFamily != '') query+= ' and ERP7__Product_Service_Family__c = :subFamily ';
            }
            query+= ' Order By Name Limit 100 ';
            prodList = Database.query(query);
            system.debug('prodList bfr: '+prodList.size());
            if(prodList.size() > 0 && venId != null && venId != ''){
                set<Id> appVendProds = new set<Id>();
                for(Product2 pr : prodList){
                    if(pr.ERP7__Purchase_From_Approved_Vendor__c) appVendProds.add(pr.Id);
                }
                system.debug('appVendProds bfr: '+appVendProds.size());
                if(appVendProds.size() > 0){
                    
                    string status = 'Approved';                    query = 'Select Id,Name,ERP7__Product__c,ERP7__Lead_Time__c from ERP7__Approved_Vendor__c where ERP7__Product__c !=null and ERP7__Product__r.ERP7__Issue_Purchase_Order__c = true and ERP7__Status__c = :status and ERP7__Product__c IN:appVendProds and ERP7__Vendor__c = :venId';                    query+= ' Order By Name Limit 100';
                    List<ERP7__Approved_Vendor__c> approvedVendors = Database.query(query);
                    system.debug('approvedVendors : '+approvedVendors.size());
                    if(approvedVendors.size() > 0){
                        for(ERP7__Approved_Vendor__c appVen:approvedVendors){                            if(appVen.ERP7__Product__c != null) ProdVendors.put(appVen.ERP7__Product__c,appVen);
                        }
                        system.debug('ProdVendors : '+ProdVendors.size());
                        Integer index = 0;
                        while(index < prodList.size()){
                            if(prodList[index].ERP7__Purchase_From_Approved_Vendor__c && !ProdVendors.containsKey(prodList[index].Id)) {                    prodList.remove(index);
                            }
                            else index++;
                        } 
                        system.debug('prodList after: '+prodList.size());
                    }
                    if(approvedVendors.size() == 0){                        Integer index = 0;
                        while(index < prodList.size()){
                            if(prodList[index].ERP7__Purchase_From_Approved_Vendor__c) {                                prodList.remove(index);
                            }
                            else index++;
                        }
                    }
                }
            }
            
        }
        
        List<ERP7__Cost_Card__c> costCards = new List<ERP7__Cost_Card__c>();
        
        system.debug('prodList 3: '+prodList.size());
        
        //Added by Arshad 03 Aug 2023
        if(prodList.size() > 0 && String.isNotEmpty(venId)){
            costCards = [SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c, ERP7__Supplier__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Cost__c, ERP7__Quantity__c, ERP7__Vendor_Part_Number__c, ERP7__Default__c 
                         FROM ERP7__Cost_Card__c WHERE ERP7__Product__c != null AND ERP7__Supplier__c != null AND ERP7__Product__c IN :prodList And ERP7__Supplier__c =:venId  And ERP7__End_Date__c >=: system.today() 
                         And ERP7__Cost__c > 0 And ERP7__Quantity__c > 0 And ERP7__Default__c = true Order by CreatedDate Desc Limit 1];
        }
        Map<String, ERP7__Cost_Card__c> defProdCostCartMap = new Map<String, ERP7__Cost_Card__c>();
        for(ERP7__Cost_Card__c cc: costCards){
            if(!defProdCostCartMap.containsKey(cc.ERP7__Product__c)){                defProdCostCartMap.put(cc.ERP7__Product__c,cc);
            }
        }
        
        set<Id> siteIds = new set<Id>();
        set<Id> productIds = new set<Id>();
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(DCId != null && DCId != '' && prodList.size() > 0){
            
            List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                                  where Id=:DCId and ERP7__Active__c=true];                
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
            for(Product2 pr:prodList) productIds.add(pr.Id);
            
            if(productIds.size() > 0) {
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,ERP7__No_of_Items_Requested__c,ERP7__Number_of_Items_Awaiting_in_Stock__c,
                                                ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                                Where product__c In: productIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds 
                                                and  (Number_of_Item_In_Stock__c > 0 or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                               ];
            }
            
        }
        
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        Map<String, Decimal> demandView = new Map<String, Decimal>();
        Map<String, Decimal> AwaitingstockView = new Map<String, Decimal>();
        
        for(Id prId:productIds){
            Decimal stock = 0;
            Decimal demand = 0;
            Decimal Awaitingstock=0;
            for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                if(prId == inven.product__c){                    stock += inven.ERP7__Number_of_Item_In_Stock__c;                    demand += inven.ERP7__No_of_Items_Requested__c;                    Awaitingstock += inven.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                }
            }
            stockView.put(prId,stock);
            demandView.put(prId,demand);
            AwaitingstockView.put(prId,Awaitingstock);
        }
        
        for(Product2 pr:prodList){
            wrapper wrapNew = new wrapper();
            wrapNew.prod = pr;
            wrapNew.VendorPartNumber = pr.ERP7__Vendor_product_Name__c;
            if(stockView.containsKey(pr.Id)) wrapNew.stock = stockView.get(pr.Id);
            else wrapNew.stock = 0;
            if(demandView.containsKey(pr.Id)) wrapNew.demand = demandView.get(pr.Id);
            else wrapNew.demand = 0;
            if(AwaitingstockView.containsKey(pr.Id)) wrapNew.AwaitStock = AwaitingstockView.get(pr.Id);
            else wrapNew.demand = 0;
            wrapNew.selCostCardId = '';
            wrapNew.selectedCostCard = new ERP7__Cost_Card__c();
            if(defProdCostCartMap.containsKey(pr.Id)){
                wrapNew.selCostCardId = defProdCostCartMap.get(pr.Id).Id;                wrapNew.selectedCostCard = defProdCostCartMap.get(pr.Id);
            }
            if(ProdVendors.containsKey(pr.Id)) wrapNew.LeadTime = (ProdVendors.get(pr.Id).ERP7__Lead_Time__c != null && ProdVendors.get(pr.Id).ERP7__Lead_Time__c != 0) ? ProdVendors.get(pr.Id).ERP7__Lead_Time__c : pr.ERP7__Purchase_Lead_Time_days__c;
            else wrapNew.LeadTime = pr.ERP7__Purchase_Lead_Time_days__c;
            if( wrapNew.LeadTime == null)  wrapNew.LeadTime = 0;
            wraplist.add(wrapNew);
        }
        
        system.debug('wraplist : '+wraplist.size());
        if(wraplist.size() > 0){
            wrap.wrapList = wraplist;
        } 
        else {            wrap.Msg= System.Label.No_products_available_to_view;
        }
        return wrap;
    }

    
    public class wrapper{
        @AuraEnabled public Product2 prod{get;set;}
        @AuraEnabled public String  VendorPartNumber {get;set;}
        @AuraEnabled public Decimal stock {get;set;}
        @AuraEnabled public Decimal demand {get;set;}
        @AuraEnabled public Decimal AwaitStock {get;set;}
        @AuraEnabled public String selCostCardId {get;set;}
        @AuraEnabled public Decimal LeadTime {get;set;} 
        @AuraEnabled public ERP7__Cost_Card__c selectedCostCard {get;set;}
    }
    
    public class WrapLst{
        @AuraEnabled public List<wrapper> wrapList {get;set;}
        @AuraEnabled public String Msg {get;set;}
        @AuraEnabled public Boolean globalSearch {get;set;}
    }
    
    @AuraEnabled
    public static String getPOCurrencies(String PoId){        String POIsocode = '';        List<selectOptions> options = new List<selectOptions>();        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        
        if(IsmultiCurrencyEnabled){               List <ERP7__PO__c> pos = Database.Query('SELECT Id,Name,CurrencyIsoCode FROM ERP7__PO__c where Id =:PoId limit 1');    
            if(pos.size() > 0) POIsocode = String.valueOf(pos[0].get('CurrencyIsoCode'));
            else POIsocode = '';
        }
        return POIsocode;
    }
    @AuraEnabled
    public static wrapProd getProdDetails(String prodId,String DCId){
        if(prodId != null && prodId != ''){
            wrapProd result = new wrapProd();
            Product2 prod = [Select Id,Name,ERP7__Vendor_product_Name__c,Description,ProductCode,ERP7__Purchase_Lead_Time_days__c from Product2 where Id =:prodId limit 1];
            system.debug('prod : '+prod);
            String selectedSite = '';
            if(String.isNotEmpty(DCId)){
                List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                    From Distribution_Channel__c
                                                                    Where 
                                                                    Id=:DCId And Active__c = true order by ERP7__Priority__c ASC Limit 1];
                
                if(DistributionChannels.size() > 0) selectedSite= DistributionChannels[0].Site__c;
            }
            else{
                List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c where ERP7__Employee_User__c=:UserInfo.getUserId()];
                if(empList.size()>0 && empList != null){                    String channel = empList[0].ERP7__Channel__c;
                    List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                        From Distribution_Channel__c
                                                                        Where 
                                                                        Channel__c=:channel And Active__c = true order by ERP7__Priority__c ASC Limit 1];
                    
                    if(DistributionChannels.size() > 0) selectedSite= DistributionChannels[0].Site__c;
                }
            }
            List<AggregateResult> WIISLists = [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock, SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) awaitingStock,SUM(ERP7__No_of_Items_Requested__c)requestedStocks FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c =: selectedSite And (ERP7__Number_of_Item_In_Stock__c > 0 OR ERP7__No_of_Items_Requested__c > 0 OR ERP7__Number_of_Items_Awaiting_in_Stock__c > 0 ) AND ERP7__Product__c =: prodId GROUP BY ERP7__Product__c];   
            system.debug('WIISLists : '+WIISLists);
            List<ERP7__Approved_Vendor__c> apprVendors = new List<ERP7__Approved_Vendor__c>();
            string status = 'Approved';
            String query = 'Select Id,Name,ERP7__Product__c,ERP7__Default__c,ERP7__Vendor__c,ERP7__Cost_Card__c,ERP7__Cost_Card__r.Name,ERP7__Cost_Card__r.ERP7__Cost__c,ERP7__Cost_Card__r.ERP7__Start_Date__c,ERP7__Cost_Card__r.ERP7__End_Date__c,ERP7__Lead_Time__c,ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c from ERP7__Approved_Vendor__c where ERP7__Product__c != null AND ERP7__Product__r.ERP7__Issue_Purchase_Order__c = true AND ERP7__Status__c =: status AND ERP7__Product__c =:prodId '; 
            query+= ' Order By ERP7__Default__c Limit 9000 ';
            apprVendors = Database.query(query);
            for(ERP7__Approved_Vendor__c appr : apprVendors){
                if(appr.ERP7__Default__c){
                    if(appr.ERP7__Cost_Card__c != null && appr.ERP7__Cost_Card__r.ERP7__Start_Date__c <= system.today() && appr.ERP7__Cost_Card__r.ERP7__End_Date__c >= system.today()){
                        result.prodId = appr.ERP7__Product__c;
                        result.prodName = prod.Name;
                        result.selCostCardId = appr.ERP7__Cost_Card__c;
                        //system.debug('prod.ERP7__Vendor_product_Name__c : '+prod.ERP7__Vendor_product_Name__c);
                        result.VendorPartNumber = (appr.ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c != null && appr.ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c != '') ? appr.ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c : prod.ERP7__Vendor_product_Name__c;
                        //system.debug('prod.ProductCode : '+prod.ProductCode);
                        result.ProductCode = prod.ProductCode;                        result.description = prod.Description;                        result.cost = appr.ERP7__Cost_Card__r.ERP7__Cost__c;                        result.venId = appr.ERP7__Vendor__c;
                        result.LeadTime = (appr.ERP7__Lead_Time__c != null && appr.ERP7__Lead_Time__c > 0) ? appr.ERP7__Lead_Time__c : prod.ERP7__Purchase_Lead_Time_days__c;
                        if(WIISLists.size() > 0) {                            result.stock = (Decimal) WIISLists[0].get('totalStock');                            result.AwaitStock = (Decimal) WIISLists[0].get('awaitingStock');                            result.demand = (Decimal) WIISLists[0].get('requestedStocks');
                        }
                        
                        break;
                    }
                }
                else{
                    if(appr.ERP7__Cost_Card__c != null && appr.ERP7__Cost_Card__r.ERP7__Start_Date__c <= system.today() && appr.ERP7__Cost_Card__r.ERP7__End_Date__c >= system.today()){
                        result.prodId = appr.ERP7__Product__c;
                        result.prodName = prod.Name;
                        result.selCostCardId = appr.ERP7__Cost_Card__c;
                        result.VendorPartNumber = (appr.ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c != null && appr.ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c != '') ? appr.ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c : prod.ERP7__Vendor_product_Name__c;
                        result.ProductCode = prod.ProductCode;                        result.description = prod.Description;                        result.cost = appr.ERP7__Cost_Card__r.ERP7__Cost__c;                        result.venId = appr.ERP7__Vendor__c;
                        result.LeadTime = (appr.ERP7__Lead_Time__c != null && appr.ERP7__Lead_Time__c > 0) ? appr.ERP7__Lead_Time__c : prod.ERP7__Purchase_Lead_Time_days__c;
                        if(WIISLists.size() > 0) {                            result.stock = (Decimal) WIISLists[0].get('totalStock');                            result.AwaitStock = (Decimal) WIISLists[0].get('awaitingStock');                            result.demand = (Decimal) WIISLists[0].get('requestedStocks');
                        }
                        break;
                    } 
                }
            }
            if(apprVendors.size() > 0 && (result.venId == null || result.venId == '')) {                result.errMsg = 'Approved vendors cost card is expired.';                result.prodId = prod.Id;                result.prodName = prod.Name;                result.ProductCode = prod.ProductCode;                result.VendorPartNumber = prod.ERP7__Vendor_product_Name__c;                result.description = prod.Description;
                if(WIISLists.size() > 0) {                    result.stock = (Decimal) WIISLists[0].get('totalStock');                    result.AwaitStock = (Decimal) WIISLists[0].get('awaitingStock');                    result.demand = (Decimal) WIISLists[0].get('requestedStocks');
                }
            }
            else if((result.venId == null || result.venId == '') && apprVendors.size() == 0) {
                result.errMsg = 'No Approved vendors set up';
                result.prodId = prod.Id;
                result.prodName = prod.Name;
                result.ProductCode = prod.ProductCode;
                result.VendorPartNumber = prod.ERP7__Vendor_product_Name__c;
                result.description = prod.Description;
                if(WIISLists.size() > 0) {                    result.stock = (Decimal) WIISLists[0].get('totalStock');                    result.AwaitStock = (Decimal) WIISLists[0].get('awaitingStock');                    result.demand = (Decimal) WIISLists[0].get('requestedStocks');
                }
            }
            return  result;           
        }
        else return null;
    }
    public class wrapProd{
        @AuraEnabled public String prodId            {get;set;}
        @AuraEnabled public String prodName            {get;set;}
        @AuraEnabled public String  VendorPartNumber {get;set;}
        @AuraEnabled public String ProductCode       {get;set;}
        @AuraEnabled public String description              {get;set;}
        @AuraEnabled public String venId             {get;set;}
        @AuraEnabled public String errMsg            {get;set;}
        @AuraEnabled public Decimal stock            {get;set;}
        @AuraEnabled public Decimal demand           {get;set;}
        @AuraEnabled public Decimal AwaitStock       {get;set;}
        @AuraEnabled public String selCostCardId     {get;set;}
        @AuraEnabled public Decimal LeadTime         {get;set;} 
        @AuraEnabled public Decimal cost             {get;set;}
        public wrapProd(){
            prodId     = '';
            prodName            = '';
            VendorPartNumber = '';
            ProductCode      = '';
            description            = '';
            venId            = '';
            errMsg            = '';
            stock           =0; 
            demand            =0; 
            AwaitStock       =0; 
            selCostCardId   = '';
            LeadTime         =0; 
            cost             =0;
        }
    }
    @AuraEnabled
    public static List<SelectOptions> getPORecordTypes(){
        List<SelectOptions> recordTypes = new List<SelectOptions>();
        for(RecordTypeInfo info: ERP7__PO__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                if(info.getName() != 'Master' && info.getName() != 'Principal') {
                    if(info.getName().contains('Standard'))  recordTypes.add(new SelectOptions(info.getName(),info.getRecordTypeId(),true));
                    else  recordTypes.add(new SelectOptions(info.getName(),info.getRecordTypeId(),false));
                }
            }
        }
        
        if(recordTypes.size() > 0) return recordTypes;
        else return null;
        
    }
    
    public class ProjectBudget{
        @AuraEnabled public Decimal projBudget                                  {get; set;}
        @AuraEnabled public Decimal projCommittedBudget                                   {get; set;}
        @AuraEnabled public Decimal projConsumedBudget                                   {get; set;}
        @AuraEnabled public Decimal projRemainingBudget                          {get; set;}
        @AuraEnabled public String budget                                  {get; set;}
        public ProjectBudget(){            projBudget = 0.0;projCommittedBudget = 0.0; projConsumedBudget = projRemainingBudget = 0.0;            budget = '';
        }
        
    }
    
    @AuraEnabled
    Public Static ProjectBudget getProjectBudget(String CoaId,String Project){        ProjectBudget pwrap = new ProjectBudget();        List< ERP7__Budget_Account__c > bacList = new List< ERP7__Budget_Account__c >();
        bacList = [select Id, Name, ERP7__Amount__c , ERP7__Committed_Amount__c , ERP7__Consumed_Amount__c , ERP7__Remaining_Amount__c  from ERP7__Budget_Account__c where ERP7__Project__c =:Project and ERP7__Chart_of_Account__c =:CoaId and ERP7__Budget_Plan__r.ERP7__Approved__c=true limit 1];
        if(bacList.size()>0){
            for(ERP7__Budget_Account__c bac : bacList){                pwrap.projBudget = bac.ERP7__Amount__c;                pwrap.projConsumedBudget = bac.ERP7__Consumed_Amount__c;                pwrap.projCommittedBudget = bac.ERP7__Committed_Amount__c;                pwrap.projRemainingBudget = bac.ERP7__Remaining_Amount__c;                pwrap.budget = bac.Id;
            }
        }
        return pwrap;
    }
    
    
    @AuraEnabled
    Public Static ProjectBudget getProjectDepartmentBudget(String CoaId,String Project, String Department){
        ProjectBudget pwrap = new ProjectBudget();
        List< ERP7__Budget_Account__c > bacList = new List< ERP7__Budget_Account__c >();
        bacList = [select Id, Name, ERP7__Amount__c , ERP7__Committed_Amount__c , ERP7__Consumed_Amount__c , ERP7__Remaining_Amount__c  from ERP7__Budget_Account__c where ERP7__Project__c =:Project and ERP7__Chart_of_Account__c =:CoaId and ERP7__Budget_Plan__r.ERP7__Approved__c=true and ERP7__Business_Unit__c=:Department limit 1];
        if(bacList.size()>0){
            for(ERP7__Budget_Account__c bac : bacList){                pwrap.projBudget = bac.ERP7__Amount__c;                pwrap.projConsumedBudget = bac.ERP7__Consumed_Amount__c;                pwrap.projCommittedBudget = bac.ERP7__Committed_Amount__c;                pwrap.projRemainingBudget = bac.ERP7__Remaining_Amount__c;                pwrap.budget = bac.Id;
            }
        }
        return pwrap;
    }
}