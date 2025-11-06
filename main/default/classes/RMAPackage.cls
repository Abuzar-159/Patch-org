public with sharing class RMAPackage {
 /*
    public Id rmaId                                                 {get;set;}
    public String RMAFields                                         {get;set;}    
    public String RMALIFields                                       {get;set;}          
    public String PackageFields                                     {get;set;}
    public String packageListFields                                 {get;set;}             
    public String ShipmentFields                                    {get;set;}
    public String PackageCustomSettingFields                        {get;set;}                                            
    public ERP7__Package__c pack                                    {get;set;}
    public ERP7__Return_Merchandise_Authorisation__c currentRMA     {get;set;}
    public String pkgTypeValue                                      {get;set;}    
    public Boolean poliPnl                                          {get;set;}
    public Boolean editpoliPnl                                      {get;set;}
    public Boolean showPackList                                     {get;set;}
    public Boolean showPackpnl                                      {get;set;}        
    public Boolean showFedexComponent                               {get;set;}  
    public Boolean showUPSComponent                                 {get;set;}  
    public Boolean showInternalShippingComponent                    {get;set;}  
    public String shipId                                            {get;set;}
    public String retValue                                          {get;set;}    
    public String packageId                                         {get;set;}
    public String errorMsg                                          {get;set;}
    public list <ERP7__Package_List__c> packLst                     {get;set;}
    public List<Id> selectedPackIds                                 {get;set;}
    public List<Shipment__c> shipmentList                           {get;set;}
    public String pack2updateId                                     {get;set;}
    public String shipmentType                                      {get;set;}   
    
    public String errormsg2                                         { get; set; }
    public Boolean hasAccess                                        { get; set; }     
    
    public RMAPackage(){
        errorMsg = '';
        showPackList = false;
        showPackpnl = false;
        editpoliPnl = false;
        poliPnl = false;
        packLst = new list<ERP7__Package_List__c>();
        packWrapLst = new List<packageWrapper>();
        selectedWrapLst = new List<packageWrapper>();
        editWrapLst = new List<packageWrapper>();
        shipWrapLst = new List<packageWrapper>();
        RMAFields = UtilClass.selectStarFromSObject('ERP7__Return_Merchandise_Authorisation__c');
        utilClass.FLSCheck(RMAFields.split(','),'ERP7__Return_Merchandise_Authorisation__c');
        RMALIFields = UtilClass.selectStarFromSObject('ERP7__RMA_Line_Item__c');
        utilClass.FLSCheck(RMALIFields.split(','),'ERP7__RMA_Line_Item__c');
        PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');      
        utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');
        packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
        utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');
        ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
        utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');
        PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
        utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c');
        
        PackageFields += ', Shipment__r.Name, Return_Merchandise_Authorisation__r.Account__c, Return_Merchandise_Authorisation__r.Account__r.Name, Return_Merchandise_Authorisation__r.Name ' ;
        
        init();                          
    }
    
    public void init(){
        List< RMA_Line_Item__c > rmaliList = new List< RMA_Line_Item__c >();
        List<Package__c> pkgList = new List<Package__c>();
        
        rmaId = ApexPages.Currentpage().getParameters().get('Id');
        if(rmaId !=null ) {
            currentRMA = Database.query('select ' + String.escapeSingleQuotes(RMAFields) + ' from ERP7__Return_Merchandise_Authorisation__c where Id =\'' + String.escapeSingleQuotes(rmaId)+'\'');
            pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where Return_Merchandise_Authorisation__c =\'' + String.escapeSingleQuotes(rmaId)+'\'');
        }
        
        if(pkgList.size() > 0){
            showPackList = true;
            for(Package__c pk : pkgList){
                packageWrapper selPckWrp = new packageWrapper();
                selPckWrp.pack = pk;
                selectedWrapLst.add(selPckWrp);
            }
        } else {
            showPackList = false;
            showPackpnl = true;
            poliPnl = true;
            editpoliPnl = false;
            pack = new ERP7__Package__c();
            pack.name = 'Pkg-' +currentRMA.name;
            pack.name__c = 'Pkg-' +currentRMA.name;
            pack.Length__c = 0.00;
            pack.Width__c = 0.00;
            pack.Height__c = 0.00;
            pack.Weight__c = 0.00;
            pack.Declared_Value__c = 0.00;
            pack.Return_Merchandise_Authorisation__c = currentRMA.id;
            pack.ERP7__Shipment_Type__c = currentRMA.ERP7__Frieght_Type__c; 
            
            list<ERP7__RMA_Line_Item__c> RMALI = [Select Id, Name, ERP7__Quantity_Available__c, ERP7__Return_Merchandise_Authorisation__c, 
                                                  ERP7__Return_Merchandise_Authorisation__r.ERP7__SO__c, ERP7__Return_Merchandise_Authorisation__r.ERP7__Account__c, 
                                                  ERP7__Return_Merchandise_Authorisation__r.ERP7__Account__r.Name, ERP7__SOLI__c, ERP7__Quantity_Return__c, 
                                                  ERP7__Base_Price__c, ERP7__Sale_Price__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Product__r.Weight__c
                                                  from ERP7__RMA_Line_Item__c 
                                                  where ERP7__Return_Merchandise_Authorisation__c=:rmaId];
            
            if(RMALI.size() > 0){
                for(ERP7__RMA_Line_Item__c RL: RMALI){
                    packageWrapper pckWrp = new packageWrapper();
                    pckWrp.pkgList.Name = RL.name;
                    pckWrp.pkgList.RMA_Line_Item__c = RL.Id;
                    pckWrp.pkgList.RMA_Line_Item__r = new ERP7__RMA_Line_Item__c(Id=RL.Id,Name = RL.Name, Product__c = RL.Product__c,Product__r = new Product2(Name=RL.Product__r.Name,Id = RL.Product__c));
                    pckWrp.pkgList.Return_Merchandise_Authorisation__c = RL.Return_Merchandise_Authorisation__c;//.ERP7__Account__r.Name = RL.Return_Merchandise_Authorisation__r.ERP7__Account__r.Name;
                    pckWrp.pkgList.Return_Merchandise_Authorisation__r = new Return_Merchandise_Authorisation__c(Id=RL.Return_Merchandise_Authorisation__c,ERP7__Account__c = RL.Return_Merchandise_Authorisation__r.Account__c,ERP7__Account__r = new Account(Id=RL.Return_Merchandise_Authorisation__r.Account__c,Name = RL.Return_Merchandise_Authorisation__r.Account__r.Name));
                    pckWrp.pkgList.Quantity__c = RL.ERP7__Quantity_Return__c;
                    packWrapLst.add(pckWrp);
                    
                    if(RL.ERP7__Product__r.Weight__c != null) pack.Weight__c += (RL.ERP7__Product__r.Weight__c * RL.ERP7__Quantity_Return__c); 
                    if(RL.ERP7__Sale_Price__c != null) pack.Declared_Value__c += (RL.ERP7__Sale_Price__c * RL.ERP7__Quantity_Return__c);
                }
            }
        }
    }
    
    public PageReference editPackage() {
        if(pack2updateId != null){
            pack = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' from Package__c where (Id =\'' + String.escapeSingleQuotes(pack2updateId) + '\')');  
            packLst = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ', RMA_Line_Item__r.Name, RMA_Line_Item__r.Product__r.Name, Return_Merchandise_Authorisation__r.ERP7__Picked_Quantity__c, Return_Merchandise_Authorisation__r.Account__c, Return_Merchandise_Authorisation__r.Account__r.Name from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(pack.Id) + '\' And Active__c = true) Order by CreatedDate Asc');                        
            packWrapLst = new list<packageWrapper>();
            for(Package_List__c pl : packLst){
                packageWrapper pckWrp = new packageWrapper();
                pckWrp.pkgList = pl;
                packWrapLst.add(pckWrp);
            }
            showPackList = false;
            showPackpnl = true;
        } 
        return null;
    }
    
    public PageReference createPackAndLI() {
        if(packWrapLst != null){
            List<Package_List__c> PL = new List<Package_List__c>();
            if(Schema.sObjectType.ERP7__Package__c.fields.Active__c.isCreateable() && Schema.sObjectType.ERP7__Package__c.fields.Active__c.isUpdateable()) pack.Active__c = true;
            if(pack != null){ if(Schema.sObjectType.ERP7__Package__c.isCreateable() && Schema.sObjectType.ERP7__Package__c.isUpdateable()) { DMLManager.upsertAsUser(pack); } else{  } }
            for(Integer i=1; i<=packWrapLst.size(); i++) {
                if(packWrapLst[i-1].pkgSelected == true) {
                  if(Schema.sObjectType.Package_List__c.fields.Package__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Package__c.isUpdateable()) packWrapLst[i-1].pkgList.Package__c = pack.Id;
                  if(Schema.sObjectType.Package_List__c.fields.Active__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Active__c.isUpdateable()) packWrapLst[i-1].pkgList.Active__c = true;
                  PL.add(packWrapLst[i-1].pkgList);
                } 
            }
            if(PL.size() > 0 && Schema.sObjectType.Package_List__c.isCreateable() && Schema.sObjectType.Package_List__c.isUpdateable()){hasAccess=true; upsert PL;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
        }
        PageReference pageRef = new PageReference('/apex/ERP7__RMAPackage?id='+currentRMA.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancel() {
        showPackList = true;
        showPackpnl = false;
        return null;
    }
    
    public PageReference populatePackDetails() {
        try { 
            List<Package_Details__c> pkgDetailList = new List<Package_Details__c>();
            if(pkgTypeValue != null && pkgTypeValue != '--None--') {
                pkgDetailList = Database.query('select ' + String.escapeSingleQuotes(PackageCustomSettingFields) + ' from ERP7__Package_Details__c where (Package_Type__c =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\') Limit 1');                             
                if(pkgDetailList.size() > 0) { pack.Length__c = pkgDetailList[pkgDetailList.size() - 1].Length__c; pack.Width__c = pkgDetailList[pkgDetailList.size() - 1].Width__c; pack.Height__c = pkgDetailList[pkgDetailList.size() - 1].Height__c; pack.Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].Weight_Unit__c; }
            } else errorMsg = 'Sorry, selected package type not available.';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null; 
    }
    
    public PageReference createPackages() {
        shipmentList = new List<Shipment__c>();
        return page.RMAPackage;
    }
    
    public PageReference deletePackage() {
        try {
            Set<Id> soliIds = new Set<Id>();
            MAP<Id, ERP7__RMA_Line_Item__c > soliMap = new MAP<Id, ERP7__RMA_Line_Item__c >();
            if(pack2updateId != null) {
                List<Package_List__c> packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,RMA_Line_Item__r.Quantity_Return__c from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(pack2updateId) + '\' And Active__c = true) Order by CreatedDate Asc');
                for(Package_List__c pls: packList) { soliIds.add(pls.ERP7__RMA_Line_Item__c); }
                List< ERP7__RMA_Line_Item__c > soliList = Database.query('select ' + String.escapeSingleQuotes(RMALIFields) + ' from ERP7__RMA_Line_Item__c where Id In: soliIds'); 
                for(Package_List__c pl: packList) {
                    for(ERP7__RMA_Line_Item__c solis: soliList) {
                        if(pl.ERP7__RMA_Line_Item__c == solis.Id) {
                            if(solis.Quantity_Return__c != null) {
                                if(Schema.sObjectType.ERP7__RMA_Line_Item__c.fields.Quantity_Return__c.isCreateable() && Schema.sObjectType.ERP7__RMA_Line_Item__c.fields.Quantity_Return__c.isUpdateable()) solis.Quantity_Return__c = solis.Quantity_Return__c - pl.Quantity__c;
                                soliMap.put(solis.Id, solis);
                            } break;
                        }
                    }
                }
            }
            if(soliMap.size() > 0) { if(Schema.sObjectType.ERP7__RMA_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__RMA_Line_Item__c.isCreateable()) { upsert soliMap.values(); }else{errormsg = 'You are not allowed to upser RMA line items'; } }
            if(pack2updateId != null && Package__c.sObjectType.getDescribe().isDeletable()) { delete new Package__c(Id = pack2updateId);    } else{ errormsg = 'You are not allowed to delete';}        
            createPackages();
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference createShipments() {
        List<Shipment__c> shipmentList = new List<Shipment__c>();
        rmaId = ApexPages.Currentpage().getParameters().get('Id');
        if(rmaId !=null ) {
            shipmentList = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' ,Sales_Order__r.Name, Customer__r.Name, Shipping_Address__r.Customer__r.Name, Shipping_Address__r.Address_Line1__c, Shipping_Address__r.Address_Line2__c, Shipping_Address__r.Address_Line3__c, '+
                                      +' Shipping_Address__r.City__c, Shipping_Address__r.County__c, Shipping_Address__r.Country__c, Shipping_Address__r.Contact__r.Phone, Shipping_Address__r.Contact__r.Fax, Shipping_Address__r.Contact__r.Name, Shipping_Address__r.Contact__r.Email, '+
                                      +' ERP7__Package__r.ERP7__Shipment_Type__c, RecordType.Name, '+
                                      +' Shipping_Address__r.State__c, Shipping_Address__r.Postal_Code__c, ERP7__Return_Merchandise_Authorisation__r.Name, Return_Merchandise_Authorisation__r.Account__c, Return_Merchandise_Authorisation__r.Account__r.Name from Shipment__c where (Return_Merchandise_Authorisation__c =\'' + String.escapeSingleQuotes(rmaId)+'\' And Active__c = true) Order by CreatedDate Asc');
        }
        
        if(shipmentList.size() > 0){
            shipWrapLst = new list<packageWrapper>();
            for(Shipment__c sh : shipmentList){
                packageWrapper selShWrp = new packageWrapper();
                selShWrp.ship = sh;
                if(selShWrp.ship.RecordType.Name == 'Fedex Shipping') selShWrp.shipmentType = 'FedEx';
                else if(selShWrp.ship.RecordType.Name == 'UPS Shipping') selShWrp.shipmentType = 'UPS';
                else if(selShWrp.ship.RecordType.Name == 'Internal Shipping') selShWrp.shipmentType = 'Shipment';
                shipWrapLst.add(selShWrp);
            }
        }
        
        return page.RMAShipment;
    }
    
    public PageReference initiateShipment() {
        String sType = '';
        Boolean error = false;
        selectedPackIds = new List<Id>();
        set<id> shipmentids = new set<id>();
        list <package__c> pack = new list<package__c>();
        
        if(selectedWrapLst != null) { 
            for(packageWrapper pw: selectedWrapLst) {
                if(pw.pkgSelected == true) {
                    if(sType == '') sType = pw.pack.Shipment_Type__c;
                    if(sType == pw.pack.Shipment_Type__c) {
                        selectedPackIds.add(pw.pack.Id);
                        if(shipmentType == null) shipmentType = pw.pack.Shipment_Type__c;
                    }else if (sType != pw.pack.Shipment_Type__c) {  errorMsg = 'You cannot select packages with different shipment type.'; error = true; break; }
                }
            }
        }
        
        if(shipWrapLst != null) { 
            for(packageWrapper pw: shipWrapLst) {
                if(pw.pkgSelected == true) { 
                    if(sType == '') sType = pw.shipmentType;
                    if(sType == pw.shipmentType) {
                        shipmentids.add(pw.ship.id);
                        if(shipmentType == null) shipmentType = pw.shipmentType;
                    }else if (sType != pw.shipmentType) { errorMsg = 'You cannot select packages with different shipment type.'; shipmentids.clear(); error = true; break; }
                }
            }
            
            
            if(shipmentids.size() > 0){
                pack = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' from Package__c where Return_Merchandise_Authorisation__c =\'' + String.escapeSingleQuotes(rmaId) + '\' And Shipment__c In: shipmentids  ');  
                for(package__c p : pack){
                    selectedPackIds.add(p.Id);    
                }
            }                            
        }
        if(!error) { errorMsg = '';
            if(selectedPackIds.size() > 0 && shipmentType == 'FedEx') { showPackList = false; showPackpnl = false; showfedexComponent = true; shipId = ''; retValue = 'SR'; }
            else if(selectedPackIds.size() > 0 && shipmentType == 'UPS') { showUPSComponent = true; shipId = ''; retValue = 'SR'; }
            else if(selectedPackIds.size() > 0 && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = ''; retValue = 'SR'; }
        }
        return null;
    }
     
    public PageReference back() {
        return null;
    }
    
    public list<packageWrapper> packWrapLst                      {get;set;}
    public list<packageWrapper> selectedWrapLst                  {get;set;}
    public list<packageWrapper> editWrapLst                      {get;set;}
    public list<packageWrapper> shipWrapLst                      {get;set;}
    
    public class packageWrapper{
        public Boolean pkgSelected                               {get;set;}
        public Package__c pack                                   {get;set;}
        public Package_List__c pkgList                           {get;set;}
        public ERP7__RMA_Line_Item__c RMLI                       {get;set;}
        public Shipment__c ship                                  {get;set;}
        public String shipmentType                               {get;set;}
        
        public packageWrapper(){
            pkgSelected = false;
            pack     = new Package__c(); 
            pkgList  = new Package_List__c();
            RMLI     = new RMA_Line_Item__c();
            ship     = new Shipment__c(); 
        } 
    }    
*/
}