public With Sharing Class ManageLocations {
    public Site__c currentWarehouse                                                       { get; set; } 
    public List<Location__c> Locations                                       { get; set; }
    public Location__c scannedLocation                                       { get; set; } 
    public List<StorageContainer__c> storageBins                                         { get; set; }
    public StorageContainer__c scannedBin                                                { get; set; }
    public String binCode                                                                 { get; set; }
    public String InventoryCode                                                           { get; set; }
    public String locationCode                                                            { get; set; }
    public String errorMsg                                                                { get; set; }
    public Map<Id, List<StorageContainer__c>> locationBinMap                             { get; set; }
    public List<Inventory_Stock__c>   warehouseInventory                   { get; set; }
  
    
    public ManageLocations() {}
    public ManageLocations(ApexPages.StandardController controller) {
    try{
        if(Schema.sObjectType.Site__c.isAccessible())
        currentWarehouse = [Select Id, Active__c, Capacityn__c, Organisation__c, Organisation_Business_Unit__c, Primary_Contact__c, Stock__c, Type__c
                                From Site__c
                                Where Id =: EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('id'),'UTF-8')];
        contruct();
        binCode = '';
        locationCode = '';
        errorMsg = '';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }            
    }
    
    public void contruct(){
    try{
        if(Schema.sObjectType.Location__c.isAccessible())
        Locations = [Select id, Name, Active__c, Site__c, Bin_Capacity__c, Item_Capacity__c, Total_Bins__c, Barcode__c 
                        From Location__c 
                        Where Active__c = true And
                        Site__c = : currentWarehouse.Id order by createdDate asc];
        
        if(Schema.sObjectType.StorageContainer__c.isAccessible())
        storageBins = [Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Location__c, Active__c, Status__c, 
                        Description__c, Organisation_Business_Unit__c, Organisation__c, Type__c, Location__r.Site__c, Barcode__c
                        FROM StorageContainer__c
                        Where Active__c = true And
                        Location__r.Site__c =: currentWarehouse.Id];
                  
                        
        locationBinMap = new Map<Id, List<StorageContainer__c>>();
        
        for(Location__c location : locations){
            List<StorageContainer__c> myBins = new List<StorageContainer__c>();
            for(StorageContainer__c bin : storageBins){
                if(location.Id == bin.Location__c){
                    myBins.add(bin);
                }
            }
            locationBinMap.put(location.Id, myBins);
        }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
     }
    
    public void getInventory(){
    try{   
        if(Schema.sObjectType.Inventory_Stock__c.isAccessible())     
               warehouseInventory = [Select id, Name, Product__r.Is_OverSized_Item__c,Status__c, Product__r.Barcode__c, Active__c, Organisation__c, Organisation_Business_Unit__c, Product__c, StorageContainer__c, 
                        Location__c  from Inventory_Stock__c WHERE StorageContainer__c != null AND Active__c = true AND 
                        StorageContainer__c =: scannedBin.Id ];  
                        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }                                                                          
    }
    
    
    public void getInventoryOverSize(){
    try{
        if(Schema.sObjectType.Inventory_Stock__c.isAccessible())
        warehouseInventory = [Select id, name,Status__c, Product__r.Is_OverSized_Item__c, Product__r.Barcode__c, Active__c, Organisation__c, Organisation_Business_Unit__c, Product__c, StorageContainer__c, 
                        Location__c  from Inventory_Stock__c WHERE StorageContainer__c = null AND Active__c = true AND 
                        Product__r.Barcode__c =: InventoryCode and Product__r.Is_OverSized_Item__c = true ];  
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }                                                              
    }
    
    public void getInventoryLocationCheckout(){    
    try{ 
        if(Schema.sObjectType.Inventory_Stock__c.isAccessible())  
               warehouseInventory = [Select id, Name, Product__r.Is_OverSized_Item__c,Status__c, Product__r.Barcode__c, Active__c, Organisation__c, Organisation_Business_Unit__c, Product__c, StorageContainer__c, 
                        Location__c  from Inventory_Stock__c WHERE StorageContainer__c != null AND Active__c = true AND 
                        StorageContainer__c =: scannedBin.Id ];   
               
               if(warehouseInventory.size() > 0){         
                   List<Inventory_Stock__c>   warehouseInventorys = new List<Inventory_Stock__c>();
                   for(Inventory_Stock__c Inventory : warehouseInventory){
                       if(Schema.sobjectType.Inventory_Stock__c.fields.Status__c.isAccessible()) Inventory.Status__c = 'Checked out';
                        warehouseInventorys.add(Inventory);
                   }
                   DMLManager.upsertAsUser(warehouseInventorys); 
              }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }                                                                           
    }
    
    
    public void getInventoryOverSizeLocationCheckout(){
    try{  
        if(Schema.sObjectType.Inventory_Stock__c.isAccessible())
               warehouseInventory = [Select id, name,Status__c, Product__r.Is_OverSized_Item__c, Product__r.Barcode__c, Active__c, Organisation__c, Organisation_Business_Unit__c, Product__c, StorageContainer__c, 
                        Location__c  from Inventory_Stock__c WHERE StorageContainer__c = null AND Active__c = true AND 
                        Product__r.Barcode__c =: InventoryCode and Product__r.Is_OverSized_Item__c = true ];                                                
               
               if(warehouseInventory.size() > 0){   if(Schema.sObjectType.Inventory_Stock__c.fields.Status__c.isAccessible()) warehouseInventory[0].Status__c  = 'Checked out';   DMLManager.upsertAsUser(warehouseInventory);
               } 
       } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }          
    }
    
    public pageReference binCheckIn() {
    try{
        if(binCode != Null && binCode != ''){    
            InventoryCode = binCode;       
            contruct();
            if(storageBins.size() > 0){
                boolean isBinAvailable = false;
                for(StorageContainer__c bin : storageBins){
                    if(bin.Barcode__c == binCode){
                        isBinAvailable = true;
                        scannedBin = bin;
                        break;
                    }
                }
             
                if(isBinAvailable){ 
                     getInventory();
                } else {
                     getInventoryOverSize();
                }
                if( warehouseInventory.size() > 0 && isBinAvailable ){ 
                    if(scannedBin.Status__c == 'Checked in'){  errorMsg = 'Bin \''+ binCode +'\' already checked in';  binCode = '';  return Null;
                    }
                    errorMsg = '';
                    locationCode = '';
                    
                    return Page.LocationCheckIn;
                } 
                else{
                    if(warehouseInventory.size() < 0){ errorMsg = 'Invalid Bin Code / Item Code \''+ binCode +'\'';  binCode = '';  return Null;
                     }else{
                            errorMsg = '';
                            locationCode = '';                   
                            return Page.LocationCheckIn;                     
                     }       
                }
            }
            else{
                errorMsg = 'Invalid Bin code \''+ binCode +'\'';  binCode = '';  return Null;
            }
        }
        errorMsg = 'Please enter Bincode';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference locationCheckIn() {
    try{
        if(locationCode != Null && locationCode != ''){
            contruct();
             boolean isLocationAvailable = false;
             for(Location__c location : locations){
                if(location.Barcode__c == locationCode){
                    scannedLocation = location;
                    isLocationAvailable = true;
                    break;
                }
            }
            if(isLocationAvailable){  
                if(warehouseInventory.size() > 0 ){ 
                  if (warehouseInventory[0].Product__r.Is_OverSized_Item__c) {   if(Schema.sObjectType.Inventory_Stock__c.fields.Location__c.isAccessible()) warehouseInventory[0].Location__c = scannedLocation.id;    if(Schema.sObjectType.Inventory_Stock__c.fields.Status__c.isAccessible()) warehouseInventory[0].Status__c  = 'Checked in';       DMLManager.upsertAsUser(warehouseInventory);    errorMsg = '';  binCode = '';  locationCode = ''; return Page.BinCheckIn;
                 }                                                                 
                 else if(scannedLocation.Bin_Capacity__c > scannedLocation.Total_Bins__c){
                     
                    List<Inventory_Stock__c>   warehouseInventorys = new List<Inventory_Stock__c>();
                    for(Inventory_Stock__c Inventory : warehouseInventory){
                        if(Schema.sObjectType.Inventory_Stock__c.fields.Status__c.isAccessible()) Inventory.Status__c = 'Checked in';
                        warehouseInventorys.add(Inventory);
                     }
                   DMLManager.upsertAsUser(warehouseInventorys);
                    
                    if(Schema.sObjectType.StorageContainer__c.fields.Location__c.isAccessible()) scannedBin.Location__c = scannedLocation.Id;
                    if(Schema.sObjectType.StorageContainer__c.fields.Status__c.isAccessible()) scannedBin.Status__c = 'Checked in';
                    DMLManager.upsertAsUser(scannedBin);                   
                    
                   
                                   
                    errorMsg = '';
                    binCode = '';
                    locationCode = '';
                    return Page.BinCheckIn;
                 }               
                 else{
                    errorMsg = 'Location \''+ locationCode +'\' completely occupied';  locationCode = ''; return Null;
                 }
              }  
            }
            else{
                errorMsg = 'Invalid location code \''+ locationCode +'\'';
                locationCode = '';
                return Null;
            }
        }
        errorMsg = 'Please enter location code';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference locationCheckOut() {
    try{
         if(locationCode != Null && locationCode != ''){
            contruct();
            boolean isLocationAvailable = false;
            for(Location__c location : locations){
                if(location.Barcode__c == locationCode){
                    scannedLocation = location;
                    isLocationAvailable = true;
                    break;
                }
            }
            if(isLocationAvailable){
                errorMsg = '';
                return Page.BinCheckOut;
            }
            else{
                errorMsg = 'Invalid location code \''+ locationCode +'\'';
                locationCode = '';
                return Null;
            }
        }
        errorMsg = 'Please enter location code';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference binCheckOut() {
    try{
        if(binCode != Null && binCode != ''){
            contruct();
            InventoryCode = binCode;
            List<StorageContainer__c> myBins = (locationBinMap.get(scannedLocation.Id) != Null)? locationBinMap.get(scannedLocation.Id) : new List<StorageContainer__c>();
            if(myBins.size() > 0){
                boolean isBinAvailable = false;
                for(StorageContainer__c bin : myBins){
                    if(bin.Barcode__c == binCode){
                        isBinAvailable = true;
                        scannedBin = bin;                       
                        break;
                    }
                }
               
                if(isBinAvailable){ 
                     getInventoryLocationCheckout();
                } else {
                     getInventoryOverSizeLocationCheckout();
                }
                
                if(isBinAvailable && warehouseInventory.size() > 0){
                    if(scannedBin.Status__c == 'Checked out'){  errorMsg = 'Bin \''+ binCode +'\' already checked out';   binCode = '';  return Null;
                    }
                    if(Schema.sObjectType.StorageContainer__c.fields.Status__c.isAccessible()) scannedBin.Status__c = 'Checked out';
                     DMLManager.upsertAsUser(scannedBin);
                    errorMsg = '';
                    binCode = '';
                    locationCode = '';
                    return Page.LocationCheckOut;
                } 
                else{
                     if(warehouseInventory.size() < 0){ errorMsg = 'Invalid Bin code / Item code \''+ binCode +'\''; binCode = '';  return Null;
                     }else{
                            errorMsg = '';
                            locationCode = '';                   
                            return Page.LocationCheckOut;                     
                     }   
                }
            }
            else{
                errorMsg = 'Invalid Bin code \''+ binCode +'\'';  binCode = '';  return Null;
            }
        }
        errorMsg = 'Please enter Bincode';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference Abort(){
    try{
        PageReference page = new PageReference('/'+currentWarehouse.Id);
        page.setredirect(true);
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return null;
    }
    
    public PageReference binCheckInBack(){
    try{
        PageReference page = new PageReference('/apex/BinCheckIn?id='+currentWarehouse.Id);
        page.setredirect(true);
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return null;
    }
   
    public PageReference binCheckOutBack(){
    try{
        PageReference page = new PageReference('/apex/LocationCheckOut?id='+currentWarehouse.Id);
        page.setredirect(true);
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return null;
    }
    
    public PageReference OverSizeItemCheck(){
    try{
        PageReference  page = new PageReference('/apex/OverSizeItemCheckIn?id='+currentWarehouse.id);
        page.setRedirect(true); 
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return null;
    }
    
    public PageReference ItemCheckOut(){
    try{
        PageReference page = new PageReference('/apex/ItemCheckOut?id='+currentWarehouse.id);
        page.setRedirect(true);
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return null;
    }
}