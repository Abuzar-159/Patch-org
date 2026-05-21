public with sharing class ShipmentManagements {
    
    public String soliId                               { get; set; }
    public String packId                               { get; set; }    
    public String type                                 { get; set; }   
    public String shipmentId                           { get; set; } 
    public Package__c Pack                             { get; set; }
    public String errorMsg                             { get; set; }
    public Sales_Order__c currentSalesOrder            { get; set; }       
    public List<Package__c> Packages                   { get; set; }    
    public Channel__c  currentSalepoint                { get; set; }
    public String rType                                { get; set; }  
    public List<Shipment__c> Shipments                 { get; set; }
    public Map<Id, Package__c> packMap                 { get; set; }
    public List<packageWrapper> packageWrapperList     { get; set; }
    public List<lineItemWrapper> lineItemWrapperList   { get; set; }
    public List<Sales_Order_Line_Item__c> currentItems { get; set; }
    public Package__c Package2Create                   { get; set; }
    public Boolean CreatePack                          { get; set; }
    public String pack2updateId                        { get; set; }
    public List<Package_List__c> packageLists          { get; set; }
    public Integer maincount                           { get; set; }
    public Integer subcount                            { get; set; }
    public Boolean selectAll                           { get; set; }
    
    public String getCurrencyISO(){
        return UserInfo.getDefaultCurrency();
    }
    public ShipmentManagements(){  
        ShipmentManagementCon();
    }
    public Sales_Order__c getCurrentOrder(string Ord){
        try{
            String AllSalesOrderFields = UtilClass.selectStarFromSObject('Sales_Order__c');
            utilClass.FLSCheck(AllSalesOrderFields.split(','),'Sales_Order__c');
            AllSalesOrderFields += ', Account__r.Name, Channel__r.Name, Order_Type__r.Name';
            String query = 'select ' + String.escapeSingleQuotes(AllSalesOrderFields) + ' from Sales_Order__c where Id = :Ord Or Name = :Ord Limit 1';
            if(Schema.SObjectType.Sales_Order__c.isAccessible()){
                Sales_Order__c order = Database.query(query);
                return order;
            }
            return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
        }
        
    }
    
    public List<Sales_Order_Line_Item__c> getCurrentOrderItems(Id Ord){
        if(Schema.SObjectType.Sales_Order_Line_Item__c.isAccessible()){
            UtilClass.FLSCheck(new String[] {'Id','Name','ERP7__Base_Price__c','ERP7__Discount_Amount__c','ERP7__Description__c','ERP7__Invoice__c','ERP7__Price_Product__c','ERP7__Total_Price__c','ERP7__VAT_Amount__c','ERP7__ReturnedQuantity__c','ERP7__Package__c','ERP7__Product__c','ERP7__Quantity__c','ERP7__Sales_Order__c','ERP7__Other_Tax__c'},'Sales_Order_Line_Item__c');
            return [Select Id, Name, Base_Price__c, Discount_Amount__c,Description__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c, ReturnedQuantity__c, Package__c,
            Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Other_Tax__c,
            Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c
            From Sales_Order_Line_Item__c 
            Where Sales_Order__c =: Ord];
        }
        return null;
    }
    
    public Void ShipmentManagementCon(){ 
        try { 
            String Son;
            if(ApexPages.currentPage().getParameters().get('SON') != null) Son = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('SON'),'UTF-8');
            if(Son != Null && Son != ''){
                currentSalesOrder = getCurrentOrder(Son);
                currentItems= getCurrentOrderItems(currentSalesOrder.id);
            }
            CreatePack = false;
            pack2updateId = '';
            Package2Create = new Package__c();
            if(Schema.sObjectType.Package__c.isAccessible())
            Packages = [Select id, Name, Shipment_Type__c, Active__c, Deposit_Tag__c, Name__c, Sales_Order__c, Status__c, Package_Quantity__c, Shipment__c, 
            Shipment__r.Name, Height__c, Length__c, Package_Type__c, Weight__c, Declared_Value__c,
            Weight_Unit__c, Width__c From Package__c
            Where Sales_Order__c =: currentSalesOrder.Id And
            Active__c = true Order by Shipment__r.Name, CreatedDate Asc];            
            if(Schema.sObjectType.Package__c.isAccessible())
            packMap = new Map <Id, Package__c>([Select id, Name, Shipment_Type__c, Active__c, Deposit_Tag__c, Name__c, 
             Sales_Order__c, Status__c
            From Package__c Where Sales_Order__c =: currentSalesOrder.Id]);
            if(Schema.sObjectType.Channel__c.isAccessible())
            currentSalepoint = [Select Id, Name, Active__c, City__c, Country__c, Organisation__c, Site__c, 
            State_Province__c, Street__c, Tax__c, Zip_Postal_Code__c, Shipper_Name__c, Company__c, Phone__c From Channel__c 
            Where Id = : currentSalesorder.Channel__c Limit 1];
            
            rType = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');               
            if (String.isNotEmpty(rType) && Schema.sObjectType.Shipment__c.isAccessible()) {
                Shipments = [Select Id, Name, Active__c, Billing_Address__c, Customer__c, Customer_Contact__c, Invoice__c,  Package__c, 
                 Package_Weight__c, UPS_Services__c, UPS_Service_Code__c, UPS_Package_Type__c, UPS_Package_Weight_Unit__c,
                Sales_Order__c, Shipment_Date__c, RecordTypeId, Number_Of_Pieces_In_Shipment__c, Shipment_Delivery_Date__c, Shipment_Status__c, 
                Shipping_Address__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Supplier__c, Tracking_Number__c, Shipment_Identification_Number__c, Tracking_Unique_Id__c,               
                Package_Ready_Time__c, Customer_Close_Time__c, Delivery_Confirmation__c, Additional_Handling__c, Saturday_Delivery__c, Carbon_Neutral__c, QV_Notification__c, International_Forms__c, 
                Dry_Ice__c, Declared_Value__c, COD__c, Product_Unit_Code__c, Return_Service__c, Pickup_Confirmation_Number__c, Pickup_Requested__c, 
                Length__c, Width__c, Height__c, Unit__c, Pickup_Location__c, Verbal_Confirmation__c From 
                Shipment__c Where Sales_Order__c = : currentSalesOrder.Id And
                Status__c != 'Cancelled' And RecordTypeId = : rType Order by CreatedDate Asc];
                
            }
            if(Schema.sObjectType.Package_List__c.isAccessible())
            packageLists = [Select Id, Name, Active__c, Package__c, Quantity__c, Sales_Order_Line_Item__c, Package__r.Sales_Order__c
            From Package_List__c
            Where Package__r.Sales_Order__c =: currentSalesOrder.Id And
            Active__c = true Order by CreatedDate Asc];
            
            
            lineItemWrapperList = new List<lineItemWrapper>();
            for(Package__c P : Packages){
                lineItemWrapper LW = new lineItemWrapper();
                LW.pack = P;
                if(Schema.sObjectType.Package__c.fields.Weight_Unit__c.isAccessible() && P.Weight_Unit__c == 'KGS') LW.units = 'cm';
                else LW.units = 'in';
                
                for(Shipment__c S : Shipments){
                    if(Schema.sObjectType.Package__c.fields.Shipment__c.isAccessible() && S.Id == P.Shipment__c){
                        LW.shipment = S;
                        break;
                    }
                }
                if(Schema.sObjectType.Package__c.fields.Package_Quantity__c.isAccessible())LW.NoofLineItems = P.Package_Quantity__c;                
                lineItemWrapperList.add(LW);
            }
            
            packageWrapperList = new List<packageWrapper>();
            
            for(Sales_Order_Line_Item__c soli : currentItems){
                packageWrapper PW = new packageWrapper();
                PW.Soli = soli;
                List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>();
                for(Package_List__c pl : packageLists){
                    if(Schema.sObjectType.Package_List__c.fields.Sales_Order_Line_Item__c.isAccessible() && pl.Sales_Order_Line_Item__c == soli.Id){
                        innerPackageWrapper ipw = new innerPackageWrapper();
                        if(Schema.sObjectType.Package_List__c.fields.Package__c.isAccessible())ipw.pack = String.valueof(pl.Package__c);
                        if(Schema.sObjectType.Package_List__c.fields.Package__c.isAccessible())ipw.packege = packMap.get(pl.Package__c);
                        ipw.packageList = pl;
                        
                        ipw.packList.add(new SelectOption('','--None--'));
                        if(Schema.sObjectType.Package__c.fields.Status__c.isAccessible() && ipw.packege.Status__c == 'Shipped' || ipw.packege.Status__c == 'Picked Up' || ipw.packege.Status__c == 'Delivered')
                        ipw.packList.add(new SelectOption(String.valueof(ipw.packege.Id),ipw.packege.Name__c)); 
                        
                        for(Package__c P : Packages){
                            if(Schema.sObjectType.Package__c.fields.Status__c.isAccessible() &&(P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered') && (ipw.packege.Status__c != 'Shipped' && ipw.packege.Status__c != 'Picked Up' && ipw.packege.Status__c != 'Delivered'))
                            ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c));  
                        }
                        ipwList.add(ipw);
                    }
                } 
                if(ipwList.size() > 0) {
                    PW.innerPackList = ipwList; 
                } else {
                    innerPackageWrapper ipw = new innerPackageWrapper();
                    
                    ipw.packList.add(new SelectOption('','--None--'));
                    
                    for(Package__c P : Packages){
                        if(Schema.sObjectType.Package__c.fields.Status__c.isAccessible() && P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered')
                        ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c));  
                    }
                    PW.innerPackList.add(ipw);
                }
                packageWrapperList.add(PW);
            }                           
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
    }

    public PageReference updatePacks(){
        try {
            Boolean error = false;
            for(packageWrapper PW : packageWrapperList){
                Decimal itemCount = 0;
                for(innerPackageWrapper ipw : PW.innerPackList){
                    if(ipw.packageList.Quantity__c != Null) itemCount += ipw.packageList.Quantity__c;
                    if((ipw.pack == '' || ipw.pack == Null) && ipw.packageList.Quantity__c > 0){
                        if(Schema.sobjectType.ERP7__Package_List__c.fields.Quantity__c.isAccessible()) ipw.packageList.Quantity__c.addError('Select package');
                        error = true;
                    } else if((ipw.pack != '' && ipw.pack != Null) && !(ipw.packageList.Quantity__c > 0)){
                        if(Schema.sobjectType.ERP7__Package_List__c.fields.Quantity__c.isAccessible()) ipw.packageList.Quantity__c.addError('Provide quantity to pack');
                        error = true;
                    } else if(itemCount > PW.soli.Quantity__c){
                        if(Schema.sobjectType.ERP7__Package_List__c.fields.Quantity__c.isAccessible()) ipw.packageList.Quantity__c.addError('Invalid quantity');
                        error = true;
                    }
                }
            }
            if(!error){
                List<Package_List__c> PLS = new List<Package_List__c>();
                for(packageWrapper PW : packageWrapperList){
                    for(innerPackageWrapper ipw : PW.innerPackList){
                        if(ipw.packageList.Quantity__c > 0 && ipw.pack != '' && ipw.pack != Null){
                            if(Schema.sobjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible() && Schema.sobjectType.Product2.fields.Name.isAccessible()) ipw.packageList.Name = 'Package List - '+PW.soli.Product__r.Name;
                            ipw.packageList.Active__c = true;
                            ipw.packageList.Package__c = ipw.pack;
                            if(Schema.sobjectType.Sales_Order_Line_Item__c.isAccessible()) ipw.packageList.Sales_Order_Line_Item__c = PW.soli.Id;
                            PLS.add(ipw.packageList);
                        }
                    }
                }
                if(PLS.size() > 0 && Schema.sObjectType.Package_List__c.isCreateable()&& Schema.sObjectType.Package_List__c.isUpdateable()) { DMLManager.UpsertAsUSer(PLS); } else{ /* no access*/}
                ShipmentManagementCon();
            }
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference assignNewPack(){
        try { 
            innerPackageWrapper ipw = new innerPackageWrapper();
            ipw.packList.add(new SelectOption('','--None--'));
            for(Package__c P : Packages){
                if(P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered')
                if(Schema.sobjectType.Package__c.fields.Name__c.isAccessible()) ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c));  
            }
            packageWrapperList[maincount].innerPackList.add(ipw);
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference deassignNewPack(){
        try {
            innerPackageWrapper ipw = packageWrapperList[maincount].innerPackList.remove(subcount);
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference createPackage(){
        try {
            Package2Create = new Package__c();
            if(Schema.sobjectType.Package__c.fields.Active__c.isAccessible()) Package2Create.Active__c = true;
            if(Schema.sobjectType.Package__c.fields.Length__c.isAccessible()) Package2Create.Length__c = 1;
            if(Schema.sobjectType.Package__c.fields.Width__c.isAccessible()) Package2Create.Width__c = 1;
            if(Schema.sobjectType.Package__c.fields.Height__c.isAccessible()) Package2Create.Height__c = 1;
            if(Schema.sObjectType.Sales_Order__c.isAccessible() && currentSalesOrder.Id != null) Package2Create.Sales_Order__c = currentSalesOrder.Id;
            CreatePack = true;
            errorMsg = '';
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference editPackage(){
        try {
            if(Schema.sObjectType.Package__c.isAccessible())
            Package2Create = [Select id, Name, Shipment_Type__c, Active__c, Deposit_Tag__c, Name__c, Sales_Order__c, Status__c, Height__c, Declared_Value__c,
            Length__c, Package_Type__c, Weight__c, Weight_Unit__c, Width__c
            From Package__c
            Where id = :pack2updateId];
            CreatePack = true;
            errorMsg = '';
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference deletePackage() {
        try {
            if(Schema.sObjectType.Package__c.isAccessible())
            Package2Create = [Select id, Name, Active__c, Deposit_Tag__c, Name__c,  Sales_Order__c, Status__c
            From Package__c
            Where id = :pack2updateId];
            if(Schema.sObjectType.Package__c.isDeletable()) { DMLManager.DeleteAsUSer(Package2Create); } else{ /* no access*/ }
            errorMsg = '';
            ShipmentManagementCon();
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference savePackage(){
        try {
            errorMsg = '';
            if(Schema.sObjectType.Package__c.isCreateable()&& Schema.sObjectType.Package__c.isUpdateable()) { DMLManager.UpsertAsUSer(Package2Create); } else{ /* no access*/}
            CreatePack = false;
            ShipmentManagementCon();
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference cancelPackage() {
        try {
            CreatePack = false;
            ShipmentManagementCon();
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference Next(){
        return Null;
    }
    
    public PageReference NextUPS(){
        try {
            String packIds = '';
            for(lineItemWrapper liw : lineItemWrapperList) {
                if(liw.sel) {
                    if(liw.pack.Shipment_Type__c == 'UPS') {
                        if(packIds != '') packIds += ',';
                        packIds = packIds + liw.pack.Id;
                    } else errorMsg = System.Label.ShipmentManagement_Error_Message2;
                } else errorMsg = System.Label.ShipmentManagement_Error_Message1;                        
            }
            if(packIds != '') {
                PageReference Page = new PageReference('/apex/UPS');
                Page.getParameters().put('txt', ApexPages.currentPage().getParameters().get('txt'));     
                Page.getParameters().put('frm', ApexPages.currentPage().getParameters().get('frm'));
                Page.getParameters().put('pack', packIds);
                Page.setRedirect(true);
                return Page;
            }     
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference NextInternal() {
        try {
            String packIds = '';
            for(lineItemWrapper liw : lineItemWrapperList){
                if(liw.sel) {
                    if(liw.pack.Shipment_Type__c == 'Internal Shipping') {
                        if(packIds != '') packIds += ',';
                        packIds = packIds+liw.pack.Id;
                    } else errorMsg = System.Label.ShipmentManagement_Error_Message3;
                } else errorMsg = System.Label.ShipmentManagement_Error_Message1;
            }        
            if(packIds != '') {
                PageReference Page = new PageReference('/apex/InternalShipping');
                Page.getParameters().put('txt', ApexPages.currentPage().getParameters().get('txt'));     
                Page.getParameters().put('frm', ApexPages.currentPage().getParameters().get('frm'));
                Page.getParameters().put('pack', packIds);
                Page.setRedirect(true);
                return Page;
            }     
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference redirecting() {
        PageReference pg;
        try {            
            if(type.equals('Internal Shipping')) {
                pg = new PageReference('/apex/InternalShipping');
                pg.getParameters().put('shipmentId', shipmentId);
                pg.setRedirect(true);
            } else if(type.equals('UPS')) {
                pg = new PageReference('/apex/UPS');
                pg.getParameters().put('shipmentId', shipmentId);
                pg.setRedirect(true);
            }        
        } catch(Exception E){ errorMsg = E.getMessage() +' , Line '+ e.getLineNumber(); }
        return pg;
    }
    
    public class innerPackageWrapper{
        public List<SelectOption> packList               { get; set; }
        public String pack                               { get; set; }
        public Package__c packege                        { get; set; }
        public Package_List__c packageList               { get; set; }
        
        public innerPackageWrapper(){ 
            packege = new Package__c();
            packageList = new Package_List__c();
            packList = new List<SelectOption>();
            pack = '';
        }
    }
    
    public class packageWrapper{
        public Sales_Order_Line_Item__c Soli                     { get; set; }
        public List<innerPackageWrapper> innerPackList           { get; set; }        
        
        public packageWrapper(){ 
            Soli = new Sales_Order_Line_Item__c();
            innerPackList = new List<innerPackageWrapper>();
        }
    }
    
    public class lineItemWrapper {
        public Package__c pack                           { get; set; }
        public Shipment__c shipment                      { get; set; }
        public Decimal NoofLineItems                     { get; set; }
        public Boolean sel                               { get; set; }
        public String units                              { get; set; }  
        
        public lineItemWrapper(){}
    }
}