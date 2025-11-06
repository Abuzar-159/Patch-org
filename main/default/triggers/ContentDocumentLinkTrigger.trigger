trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    
    ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
    FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
    if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());  
                   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance(); }
    
    boolean ExeTrigger = false;
    if(FC!=null) ExeTrigger = FC.ERP7__Activate_ContentDocumentLink_Trigger__c;
    
    if(ExeTrigger == true){
        Set<Id> AllDocids = new set<Id>();
        Set<Id> EligibleDocIds = new set<Id>();
        
        for (ContentDocumentLink cdl : Trigger.new) {
            AllDocids.add(cdl.ContentDocumentId);
        }
        
        for(ContentDocument CD: [Select Id,FileExtension,title from ContentDocument where Id in: AllDocids])
        {
            if(CD.FileExtension != null && (CD.FileExtension.equals('jpg') || CD.FileExtension.equals('jpeg') || CD.FileExtension.equals('png') ||  CD.FileExtension.equals('webp') ||  CD.FileExtension.equals('pdf') || CD.FileExtension.equals('xlsx') || CD.FileExtension.equals('ppt') || CD.FileExtension.equals('doc') || CD.FileExtension.equals('gif') || CD.FileExtension.equals('txt') || CD.FileExtension.equals('csv')))
                EligibleDocIds.add(CD.Id);
        }
        
        for (ContentDocumentLink cdl : Trigger.new) {
            if(EligibleDocIds.contains(cdl.ContentDocumentId))
                cdl.Visibility = 'AllUsers';
        }    
    }else{
        System.debug('Trigger Not Execute');
    }
}