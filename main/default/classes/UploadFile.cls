public with sharing class UploadFile{
    
    @AuraEnabled
    public static Map<Blob,Attachment> RetriveAttachmentRecord(){
        Map<Blob,Attachment> AttachMap=new Map<Blob,Attachment>();
        /* AttachMap=ProductLifecycleManagement.RetriveAttachmentRecord();
        
        */
     return AttachMap;
    } 
    
    public Boolean booVar {set;get;}
    
    public UploadFile(){
        booVar=false;
    }
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) { 
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {  fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        } 
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        try{  
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        if(Schema.sObjectType.Attachment.fields.parentId.isCreateable()) oAttachment.parentId =parentId;
        if(Schema.sObjectType.Attachment.fields.Body.isCreateable()) oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        if(Schema.sObjectType.Attachment.fields.Name.isCreateable()) oAttachment.Name = fileName;
        if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) oAttachment.ContentType = contentType;
 
            if(Schema.SObjectType.Attachment.isCreateable()){insert oAttachment;} else{/*not allowed to insert*/}
       
        list<Attachment> atList = [SELECT Id, parentId FROM Attachment WHERE parentId =:parentId AND Id!=:oAttachment.Id];   
            if(Attachment.sObjectType.getDescribe().isDeletable()) delete atList;  else{ }  
            
     /*  //ERP7__Media__c mediaRecord=new ERP7__Media__c();
       ERP7__Media__c MediaRecord=[SELECT Id, Name, ERP7__File__c, ERP7__Order__c, ERP7__Active__c FROM ERP7__Media__c WHERE Id='a4B1o000000CzGAEA0'];
       
       MediaRecord.ERP7__File__c=String.ValueOf(EncodingUtil.base64Decode(base64Data)); 
       upsert MediaRecord;   
       */ 
        
        appendToFile(oAttachment.Id, base64Data);
        
        
        return oAttachment.Id;
        }catch(Exception ex){ return null;   }     
    }
  
    private static void appendToFile(Id fileId, String base64Data) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment a = [ SELECT Id, Body FROM Attachment WHERE Id =: fileId];  
        String existingBody = EncodingUtil.base64Encode(a.Body);
        try{
        if(Schema.sObjectType.Attachment.fields.Body.isUpdateable()) a.Body = EncodingUtil.base64Decode(existingBody + base64Data);}catch(Exception ex){}
        if(Schema.SObjectType.Attachment.isUpdateable()){update a;}else{/*not allowed to update*/}
        
        
        
        
    }
}