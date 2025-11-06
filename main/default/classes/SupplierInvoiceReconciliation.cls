public With Sharing Class SupplierInvoiceReconciliation {

public String endDate                                        { get; set; }
public String startDate                                      { get; set; }
public Bill__c  SupplierOrganisation             { get; set; }
public List<PO__c> poList                                    { get; set; }
public String Poli_Id                                        { get; set; }
public Static Map<Id,Purchase_Line_Items__c> POLI_Map        { get; set; }
public Static Map<Id,Stock_Inward_Line_Item__c> SPLI_Map    { get; set; }
public Static Map<Id,Bill_Line_Item__c> SILI_Map { get; set; }

    public SupplierInvoiceReconciliation (){
    try{
        Poli_Id ='';
        if(Schema.sObjectType.Account.isAccessible()){
            Account DefaultOrganisation = [Select Name FROM Account Where Account_Type__c='Organisation' and Default__c =true limit 1];
            SupplierOrganisation = new Bill__c();
        }
        }catch(QueryException e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'No Default Organisation Found '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'Exception Occcured '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
    }
    
    public PageReference supplierPO(){
       try{
        if(Schema.sObjectType.PO__c.isAccessible()){
            if(String.isNotEmpty(startDate)&&String.isNotEmpty(endDate) )
                    polist = (SupplierOrganisation.Vendor__c != null)? [Select Name,Status__c,Total_Quantity__c,Reconciled_Quantity__c,Amount__c,Code__c,Order_Date__c FROM PO__c WHERE Vendor__c =:SupplierOrganisation.Vendor__c AND Status__c Not In('Reconciled','Closed','Cancelled','Rejected') AND Order_Date__c >= :Date.parse(startDate) AND Order_Date__c <= :Date.parse(enddate)]:new List<PO__c>();
            else
                poList = (SupplierOrganisation.Vendor__c != null)?[Select Name,Code__c,Status__c,Total_Quantity__c,Reconciled_Quantity__c,Amount__c,Order_Date__c FROM PO__c WHERE Vendor__c =:SupplierOrganisation.Vendor__c AND Status__c Not In('Reconciled','Closed','Cancelled','Rejected')]:new List<PO__c>();//'001b000003ITjpF'
            }
        }
        catch(QueryException e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'Exception Occcured No Records Found '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'Exception Occcured '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
        return null;
    }
   


    @RemoteAction
    public static List<Purchase_Line_Items__c> getPOLIList(String Poid) {
    try{
    if(Schema.sObjectType.Purchase_Line_Items__c.isAccessible())
    POLI_Map= new Map<Id,Purchase_Line_Items__c>([SELECT Name,Quantity_Received__c,Quantity__c,Total_Price__c,Product__r.Name,Product__c FROM Purchase_Line_Items__c WHERE Purchase_Orders__c = :Poid and Reconciled__c=false]);
                 
    }
    catch(QueryException e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'Exception Occcured No Records Found '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
    catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'Exception Occcured '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
   return POLI_Map.values();
    }
   
    
    @RemoteAction
    public static List<Stock_Inward_Line_Item__c> getSPLIList(String Poli) {
      try{
            if(Schema.sObjectType.Stock_Inward_Line_Item__c.isAccessible())
            SPLI_Map= new Map<Id,Stock_Inward_Line_Item__c>([SELECT Name,CreatedDate,Purchase_Orders__c,Quantity__c,Amount__c,Product__r.Name,Product__c FROM Stock_Inward_Line_Item__c WHERE Purchase_Line_Items__c= :Poli AND Reconciled__c=false]);
                 
          }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'Exception Occcured '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
    return SPLI_Map.values();
    }
    
    @RemoteAction
    public static List<Bill_Line_Item__c> getSILIList(String Poli) {
    try{
        if(Schema.sObjectType.Bill_Line_Item__c.isAccessible())
        SILI_Map= new Map<Id,Bill_Line_Item__c>([SELECT Name,CreatedDate,Bill__c,Purchase_Order_Line_Items__c,Purchase_Order_Line_Items__r.Product__r.Name,Quantity__c,Total_Amount__c FROM Bill_Line_Item__c WHERE Purchase_Order_Line_Items__c= :Poli AND Reconciled__c=false]);
                 
    }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'Exception Occcured '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
   return SILI_Map.values();
    }
   
     public pageReference paymentProcess(){
         return new PageReference ('/apex/VendorPayment?SID='+SupplierOrganisation.Vendor__c);
     }
    public pageReference updatePOLI() {
          
        if(String.isNotEmpty(Poli_Id)){  Purchase_Line_Items__c poli = new Purchase_Line_Items__c(id=(ID)Poli_Id,Reconciled__c=true);  if(Schema.sObjectType.Purchase_Line_Items__c.fields.Reconciled__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Reconciled__c.isUpdateable()){ DMLManager.upsertAsUser(poli);} else{ /* no access */ } supplierPO();}    
        return null;
    }
    @RemoteAction    
    public Static void updateReconcile(String poliId) {
         
        if(String.isNotEmpty(poliId)){  Purchase_Line_Items__c poli = new Purchase_Line_Items__c(id=(ID)poliId,Reconciled__c=true); if(Schema.sObjectType.Purchase_Line_Items__c.fields.Reconciled__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Reconciled__c.isUpdateable()){ DMLManager.upsertAsUser(poli); } else{ /* no access */ } }    
       
        }
     @RemoteAction    
    public Static void updateSupplierAndSite_Items(String supinv,string siteLi) {
    try{
        String[] SupplierInvLi = supinv.split(',');
        String[] SitePurchaseLi = siteLi.split(',');
        List<Bill_Line_Item__c> supplierInvoiceList = new List<Bill_Line_Item__c>();
        List<Stock_Inward_Line_Item__c> sitePurchaseList = new List<Stock_Inward_Line_Item__c>();
       if(SupplierInvLi.size()>0) 
           for(Integer i=0;i<SupplierInvLi.size();i++) {Bill_Line_Item__c sinv = new Bill_Line_Item__c(id=(ID)SupplierInvLi[i],Reconciled__c=true);supplierInvoiceList.add(sinv);}
        if(SitePurchaseLi.size()>0)
         for(Integer i=0;i<SitePurchaseLi.size();i++) {Stock_Inward_Line_Item__c spli = new Stock_Inward_Line_Item__c(Id=(ID)SitePurchaseLi[i],Reconciled__c=true); sitePurchaseList.add(spli);}
        if(supplierInvoiceList.size()>0 && Schema.sObjectType.Bill_Line_Item__c.fields.Reconciled__c.isCreateable() && Schema.sObjectType.Bill_Line_Item__c.fields.Reconciled__c.isUpdateable()) { DMLManager.upsertAsUser(supplierInvoiceList); } else{ /* no access */ }
        if(sitePurchaseList.size()>0 && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Reconciled__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Reconciled__c.isUpdateable()) { DMLManager.upsertAsUser(sitePurchaseList); }  else{ /* no access */ }
        }
    catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.FATAL,'Exception Occcured '+e.getMessage()+' at Line No: '+e.getLineNumber()));
        }
    
    }
  
 }