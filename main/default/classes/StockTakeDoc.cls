public class StockTakeDoc {
    public String sfdcBaseURL                                                           { get; set; }
    public String stockId                                                                 { get; set; }
    public String fetchedStockId                                                                 { get; set; }
    public ERP7__Stock_Take__c stockTake                                          { get; set; }
    public List<ERP7__Stock_Take_Line_Item__c> STLI                                    { get; set; }
    public String imageURl                             			{ get; set; }
    public String approvers										{ get; set; }
    public Boolean ShowAdjustedQty										{ get; set; }
    public Boolean ShowOrgDetails										{ get; set; }
    public List<ProcessInstanceWorkitem> pworkList 				{ get; set; }
    public StockTakeDoc() { 
        try {
            ShowAdjustedQty = true;
            ShowOrgDetails = true;
            stockTake = new ERP7__Stock_Take__c();
            STLI = new List<ERP7__Stock_Take_Line_Item__c>();
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.replace('.visualforce.com','.documentforce.com');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            stockId = '';
            fetchedStockId = '';
            if(ApexPages.CurrentPage().getParameters().get('Id') != Null) stockId = ApexPages.CurrentPage().getParameters().get('Id');
            system.debug('stockId : '+stockId);
            imageURL = '/servlet/servlet.FileDownload?file=';
            List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
            if(documentList.size() > 0) imageURL = imageURL + documentList[0].id; 
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
                if(FC == null){ 
                    FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
                }
                if(FC != null){
                    if(FC.ERP7__Show_adjusted_Qty_in_Stock_Take__c == false) ShowAdjustedQty = false;
                    if(FC.ERP7__Show_Org_details_in_stock_take__c == false) ShowOrgDetails = false;
                    system.debug('ShowAdjustedQty 111: '+ShowAdjustedQty);
                }
            system.debug('ShowAdjustedQty : '+ShowAdjustedQty);
        }
        catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); 
        }
    }
    
    public PageReference createPDF() {
        try { 
            if(String.isNotEmpty(stockId)){
                 pworkList = [
                    SELECT Id, ProcessInstanceId, OriginalActor.Name, Actor.Name, 
                    ElapsedTimeInDays, ElapsedTimeInHours, ElapsedTimeInMinutes, 
                    IsDeleted, CreatedDate, CreatedById, SystemModstamp 
                    FROM ProcessInstanceWorkitem 
                    WHERE ProcessInstance.targetObjectId =:stockId
                ];
                if(pworkList.size() > 0){
                    approvers = '';
                    for(ProcessInstanceWorkitem pp : pworkList){
                        if(approvers == '' || approvers == null) approvers = pp.OriginalActor.Name;
                        else approvers = approvers + ',' +pp.OriginalActor.Name;
                    }
                    system.debug('approvers : '+approvers);
                }
                system.debug('stockId : '+stockId);
                stockTake = [Select Id, Name, ERP7__Channel__c,ERP7__Approved_Date__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Employee__c,ERP7__Employee__r.Name, ERP7__Approver__c,ERP7__Site__r.ERP7__Address__c,ERP7__Site__r.ERP7__Address__r.ERP7__Contact__c,
                             ERP7__Site__r.ERP7__Address__r.ERP7__Contact__r.Name,ERP7__Site__r.ERP7__Address__r.ERP7__Customer__c,ERP7__Site__r.ERP7__Address__r.ERP7__Customer__r.Name,ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line1__c,
                             ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line2__c,ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line3__c,ERP7__Site__r.ERP7__Address__r.ERP7__City__c,ERP7__Site__r.ERP7__Address__r.ERP7__Postal_Code__c,
                             ERP7__Site__r.ERP7__Address__r.ERP7__State__c,ERP7__Site__r.ERP7__Address__r.ERP7__Country__c,ERP7__Site__r.ERP7__Address__r.ERP7__Contact__r.Phone,
                             ERP7__Approver__r.Name, ERP7__Start_Date__c,ERP7__End_Date__c, ERP7__Status__c, ERP7__Description__c,ERP7__Line_Item_Count__c FROM ERP7__Stock_Take__c WHERE Id =: stockId Limit 1];
                system.debug('stockTake : '+stockTake);
                if(stockTake.Id != null) fetchedStockId = stockTake.Id; 
                STLI = [SELECT Id, Name, ERP7__Adjusted_Quantity__c,ERP7__Inventory_Stock__c, ERP7__Material_Batch_Lot__c, ERP7__Product__c, ERP7__Serial__c, ERP7__Stock_Available__c, ERP7__Stock_In_Hand__c, ERP7__Stock_Take__c, ERP7__Variance__c, ERP7__Inventory_Stock__r.Id,
                        ERP7__Inventory_Stock__r.Name, ERP7__Inventory_Stock__r.ERP7__Location__c,ERP7__Inventory_Stock__r.ERP7__Warehouse__c,ERP7__Inventory_Stock__r.ERP7__Warehouse__r.Name ,ERP7__Inventory_Stock__r.ERP7__Location__r.Id, ERP7__Inventory_Stock__r.ERP7__Location__r.Name,
                        ERP7__Inventory_Stock__r.ERP7__Serial__c, ERP7__Inventory_Stock__r.ERP7__Serial__r.Id, ERP7__Inventory_Stock__r.ERP7__Serial__r.Name,ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c, 
                        ERP7__Inventory_Stock__r.ERP7__Batch_Lot__r.Id, ERP7__Inventory_Stock__r.ERP7__Batch_Lot__r.Name, ERP7__Inventory_Stock__r.ERP7__StorageContainer__c, ERP7__Inventory_Stock__r.ERP7__StorageContainer__r.Id, ERP7__Inventory_Stock__r.ERP7__StorageContainer__r.Name,
                        ERP7__Serial__r.Id,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Material_Batch_Lot__r.Id,ERP7__Material_Batch_Lot__r.Name,ERP7__Product__r.ProductCode,
                        ERP7__Product__r.Id, ERP7__Product__r.Name, ERP7__Product__r.StockKeepingUnit, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c 
                        FROM ERP7__Stock_Take_Line_Item__c Where ERP7__Stock_Take__c =: stockId AND ERP7__Inventory_Stock__c != null];
                system.debug('STLI.size() : '+STLI.size());
            }else{
                system.debug('stockId empty');
            }
        }
        catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }        
        return null;
    }
}