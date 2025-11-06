public with sharing class SupportController {

    public String selectValue            { get; set; }
    public String iceCaseID              { get; set; }  
    public List <ICE__c> iceCaseList     { get; set; } 

    public PageReference existingCase() {
        pageReference page = new pageReference('/apex/Case?caseId=' + iceCaseID);
        page.setRedirect(true);
        return page;
    }
        
    /*
      constructor
    */        
    public SupportController () {
        iceCaseList = new List <ICE__c>();
        selectValue = 'Open Cases';
        if(selectValue == 'Open Cases') {
            if(Schema.sObjectType.ICE__c.isAccessible()) iceCaseList = [select id, name, Subject__c, RecordType.Name, Status_Duration__c, CreatedDate, LastModifiedDate from ICE__c 
            where Status_Duration__c =: 'New' OR
            Status_Duration__c =: 'Re-Open' OR
            Status_Duration__c =: 'Replied' OR
            Status_Duration__c =: 'Under Investigation' OR  
            Status_Duration__c =: 'Waiting for reply' OR
            Status_Duration__c =: 'Assigned' OR
            Status_Duration__c =: 'In Progress' 
            ORDER BY CreatedDate DESC];
            
        } 
    }    
    
    /*
      fetch existing cases based on selected view
    */            
    public PageReference showIceCases() {
        
        if(selectValue == 'Open Cases') {
           if(Schema.sObjectType.ICE__c.isAccessible()) iceCaseList = [select id, name, Subject__c, RecordType.Name, Status_Duration__c, CreatedDate, LastModifiedDate from ICE__c 
            where Status_Duration__c =: 'New' OR
            Status_Duration__c =: 'Re-Open' OR
            Status_Duration__c =: 'Replied' OR
            Status_Duration__c =: 'Under Investigation' OR  
            Status_Duration__c =: 'Waiting for reply' OR
            Status_Duration__c =: 'Assigned' OR
            Status_Duration__c =: 'In Progress' 
            ORDER BY CreatedDate DESC];
           
        } else if(selectValue == 'Closed Cases') {
            if(Schema.sObjectType.ICE__c.isAccessible()) iceCaseList = [select id, name, Subject__c, RecordType.Name, Status_Duration__c, CreatedDate, LastModifiedDate from ICE__c
            where Status_Duration__c =: 'Closed' OR
            Status_Duration__c =: 'Completed' OR
            Status_Duration__c =: 'Created In Error'
            ORDER BY CreatedDate DESC];        
                       
        } else if(selectValue == 'On Hold/Rejected') {
            if(Schema.sObjectType.ICE__c.isAccessible()) iceCaseList = [select id, name, Subject__c, RecordType.Name, Status_Duration__c, CreatedDate, LastModifiedDate from ICE__c
            where Status_Duration__c =: 'On Hold' OR
            Status_Duration__c =: 'Rejected'
            ORDER BY CreatedDate DESC];        
           
        }        
        return null;
    }
    
    /*
      newCase page
    */    
    public PageReference newCase() {
        pageReference ref = new pageReference('/apex/NewCase');
        ref.setRedirect(true);        
        return ref;
    }     
}