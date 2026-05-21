public with sharing class ManageOverSizeItemLocations {
    
    public Site__c currentWarehouse                                                         { get; set; } 
    public StorageContainer__c  scannedstorageBins                                         { get; set; }
    public List<Location__c> Locations                                         { get; set; }
    public Location__c scannedLocation                                         { get; set; } 
    public String itemCode                                                                  { get; set; }
    public String locationCode                                                              { get; set; }
    public String storageBin                                                                { get; set; }
    public String errorMsg                                                                  { get; set; }
    public List<Inventory_Stock__c>   warehouseInventory                     { get; set; }
    public List<StorageContainer__c> storageBins                                           { get; set; }                                              
    public List<Product2> allProducts                                             { get; set; }
    
    public ManageOverSizeItemLocations(){
    }
    
    public ManageOverSizeItemLocations(ApexPages.StandardController controller) {
    try{
            if(Schema.sObjectType.Site__c.isAccessible())
           currentWarehouse = [Select Id, Active__c, Capacityn__c, Organisation__c,  Primary_Contact__c, Stock__c, Type__c
                                From Site__c
                                Where Id =: EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('id'),'UTF-8')];
           itemCode = '';
           locationCode = '';
           errorMsg = '';
           } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    }
    
    public void contruct(){
    try{
        if(Schema.sObjectType.Location__c.isAccessible())
           Locations = [Select id, Name, Active__c, Site__c, Bin_Capacity__c, Barcode__c 
                        From Location__c 
                        Where Active__c = true And
                        Site__c = : currentWarehouse.Id order by createdDate asc];
         if(Schema.sObjectType.StorageContainer__c.isAccessible())              
           storageBins = [Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Location__c, Active__c, Status__c, 
                        Description__c,  Type__c, Location__r.Site__c, Barcode__c
                        FROM StorageContainer__c
                        Where Active__c = true And
                        Location__r.Site__c =: currentWarehouse.Id]; 
       } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }                             
                                             
    }
          
    public pageReference getProductFromInventory(){
    try{
           if(itemCode != null && itemCode != ''){
            if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) 
                 warehouseInventory = [Select id, name, Product__r.Barcode__c, Active__c, Organisation__c,  Product__c, StorageContainer__c, 
                        Location__c  from Inventory_Stock__c WHERE StorageContainer__c = null AND Active__c = true AND 
                        Product__r.Barcode__c =: itemCode and Product__r.Is_OverSized_Item__c = true limit 1];                              
           }
                errorMsg = 'Please enter Item code';
           if( warehouseInventory.size() > 0 ){
                 errorMsg = '';
                 return Page.OverSizeItemLocCheckIn;     
           }else{
                 errorMsg = 'Invalid Item code \''+ itemCode +'\'';
                 itemCode = '';
                 return Null;           
           } 
          // errorMsg = 'Please enter Item code';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return Null;              
    }
    
    public pageReference fetchProductFromInventory(){
    try{
           boolean isOversizedItem= false;
           if(itemCode != null && itemCode != ''){
            if(Schema.sObjectType.Inventory_Stock__c.isAccessible())
                 warehouseInventory = [Select id, name, Product__r.Barcode__c, Product__r.Is_OverSized_Item__c, Active__c, Organisation__c,  Product__c, StorageContainer__c, 
                        Location__c  from Inventory_Stock__c WHERE Active__c = true AND 
                        Product__r.Barcode__c =: itemCode limit 1];                              
           }
             errorMsg = 'Please enter Item code';
           if( warehouseInventory.size() > 0 ){
               if(Schema.sObjectType.Product2.isAccessible() && Schema.sObjectType.Product2.fields.Is_OverSized_Item__c.isAccessible() && Schema.sObjectType.Inventory_Stock__c.isAccessible() && Schema.sObjectType.Inventory_Stock__c.fields.ERP7__Product__c.isAccessible()) isOversizedItem = warehouseInventory[0].Product__r.Is_OverSized_Item__c;
               errorMsg = '';
               if(isOversizedItem){
                  return Page.ItemCheckInLocation;                 
                              
               }else{
                 return Page.ItemCheckInStorageBin;               
               }
           }else{
                 errorMsg = 'Invalid Item code \''+ itemCode +'\'';
                 itemCode = '';
                 return Null;           
           } 
         //  errorMsg = 'Please enter Item code'; 
           } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }    return Null;            
    }
    
    public pageReference ProductCheckOut(){
    try{
           boolean isOversizedItem= false;
           if(itemCode != null && itemCode != ''){
            if(Schema.sObjectType.Inventory_Stock__c.isAccessible())
                 warehouseInventory = [Select id, name, Product__r.Barcode__c, Product__r.Is_OverSized_Item__c, Active__c, Organisation__c, Product__c, StorageContainer__c, 
                        Location__c  from Inventory_Stock__c WHERE Active__c = true AND 
                        Product__r.Barcode__c =: itemCode limit 1];                              
           }
             errorMsg = 'Please enter Item code';
           if( warehouseInventory.size() > 0 ){               
                 errorMsg = '';
                if(Schema.sObjectType.Product2.isAccessible())
                 allProducts = [Select id, Name, isActive, Barcode__c, Category__c, Description__c, Status__c, Expiration_Date__c, Invoiceable__c, SKU__c, Item_Description__c, Item_Type__c, Item_Unit__c, Item_Unit_Value__c, Picture__c, Sub_Category__c, Transactable__c From Product2 Where id =: warehouseInventory[0].Product__c  And  isActive = true And Is_OverSized_Item__c = true limit 1];  
                 if(allProducts.size() > 0){
                     if(Schema.sObjectType.Product2.fields.Status__c.isAccessible()) allProducts[0].Status__c = 'Checked out';
                     DMLManager.upsertAsUser(allProducts);
                     itemCode = '';
                     errorMsg = 'Item Checked out successfully';
                     return Page.ItemCheckOut;
                 } else{
                     errorMsg = 'Invalid Item code \''+ itemCode +'\''; return Null;  
                 }      
                                      
           }else{
                 errorMsg = 'Invalid Item code \''+ itemCode +'\'';
                 itemCode = '';
                 return Null;           
           } 
          // errorMsg = 'Please enter Item code';  
           } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }   return Null;            
    }
    
    
    
    public pageReference locationCheck(){
    try{
           boolean isLocationAvailable = false;
           if(locationCode !=null && locationCode != ''){
                 contruct();                
                 for(Location__c location:Locations){
                    if(locationCode == location.Barcode__c){
                      scannedLocation = location;                    
                      isLocationAvailable = true;
                      break;
                    }  
                 } 
           }   
        errorMsg = 'Please enter location code';
           if(isLocationAvailable){                               
                 if(warehouseInventory.size() > 0 ){
                      if(Schema.sObjectType.Location__c.isAccessible()) warehouseInventory[0].Location__c = scannedLocation.id;
                     DMLManager.upsertAsUser(warehouseInventory);    
                    if(Schema.sObjectType.Product2.isAccessible())
                      allProducts = [Select id, Name, isActive, Barcode__c, Category__c, Description__c, Status__c, Expiration_Date__c, Invoiceable__c, SKU__c, Item_Description__c, Item_Type__c, Item_Unit__c, Item_Unit_Value__c, Picture__c, Sub_Category__c, Transactable__c From Product2 Where id =: warehouseInventory[0].Product__c  And  isActive = true And Is_OverSized_Item__c = true limit 1];  
                 
                      if(allProducts.size() > 0){
                          if(Schema.sObjectType.Product2.fields.Status__c.isAccessible()) allProducts[0].Status__c = 'Checked-in';
                        DMLManager.upsertAsUser(allProducts);                   
                      }                                                           
                 }        
                 itemCode = ''; 
                 locationCode = '';   
                 errorMsg = '';
                 return Page.OverSizeItemCheckIn;     
           }else{
                 errorMsg = 'Invalid location code \''+ locationCode +'\'';
                 locationCode = '';
                 return Null;         
           }
          // errorMsg = 'Please enter location code';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return Null;
    }
    
    public PageReference Abort(){
    try{
        PageReference page = new PageReference('/'+currentWarehouse.Id);
        page.setredirect(true);
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return null;
    }
    
    public PageReference backToBin(){
    try{
        PageReference page = new PageReference('/apex/BinCheckIn?id='+currentWarehouse.Id);
        page.setredirect(true);
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    public PageReference Back(){
    try{
       return page.OverSizeItemCheckIn;
       } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    
     public pageReference locationItemCheckIn(){
     try{
           boolean isLocationAvailable = false;
           if(locationCode !=null && locationCode != ''){
                 contruct();                
                 for(Location__c location:Locations){
                    if(locationCode == location.Barcode__c){
                      scannedLocation = location;                    
                      isLocationAvailable = true;
                      break;
                    }  
                 } 
           }    
         errorMsg = 'Please enter location code';
           if(isLocationAvailable){                               
                 if(warehouseInventory.size() > 0 ){
                    if(Schema.sobjectType.Location__c.isAccessible()) warehouseInventory[0].Location__c = scannedLocation.id;                   
                   DMLManager.upsertAsUser(warehouseInventory);                     
                 }        
                 itemCode = '';   
                 errorMsg = '';
                 locationCode = ''; 
                 return Page.ItemCheckIn;     
           }else{
                 errorMsg = 'Invalid location code \''+ locationCode +'\'';
                 locationCode = '';
                 return Null;         
           }
         //  errorMsg = 'Please enter location code';
           } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return Null;
    }
    
    
    public pageReference storageBinItemCheckIn(){
    try{
           boolean isLocationAvailable = false;
           if(storageBin !=null && storageBin != ''){
                 contruct();                
                 for(StorageContainer__c  storagesBins : storageBins){
                    if(storageBin == storagesBins.Barcode__c){
                      scannedstorageBins = storagesBins;                    
                      isLocationAvailable = true;
                      break;
                    }  
                 } 
           }    
        errorMsg = 'Please enter Storage Bin code';
           if(isLocationAvailable){                               
                 if(warehouseInventory.size() > 0 ){
                    if(Schema.sObjectType.StorageContainer__c.isAccessible()) warehouseInventory[0].StorageContainer__c = scannedstorageBins.id;
                     if(Schema.sObjectType.StorageContainer__c.fields.Location__c.isAccessible()) warehouseInventory[0].Location__c = scannedstorageBins.Location__c;
                    DMLManager.upsertAsUser(warehouseInventory);                     
                 }        
                 itemCode = '';
                 storageBin = '';   
                 errorMsg = '';
                 return Page.ItemCheckIn;     
           }else{
                 errorMsg = 'Invalid Storage Bin code \''+ storageBin +'\'';
                 locationCode = '';
                 return Null;         
           }
          // errorMsg = 'Please enter Storage Bin code';
           } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return Null;
    }
    
    
    public PageReference BackToItemCheckIn(){
    try{
        itemCode = '';   
        PageReference page = new PageReference('/apex/BinCheckIn?id='+currentWarehouse.Id);
        page.setredirect(true);
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return null;
    }
    
    public PageReference BackToLocationCheckOut(){
    try{
        itemCode = '';   
        PageReference page = new PageReference('/apex/LocationCheckOut?id='+currentWarehouse.Id);
        page.setredirect(true);
        return page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  return null;
    }
}