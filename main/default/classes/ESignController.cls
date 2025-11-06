global with sharing class ESignController {
    
    global static String signatureId{get;set;}
    
    
    @RemoteAction
     global static string captureSignature(String imageData, String recId, String name) {        
        Attachment a = new Attachment (ParentId = recId,
                                       Body = EncodingUtil.base64Decode(imageData),
                                       ContentType = 'image/png',
                                       Name = name);
                                       
        try{
             if(Schema.sObjectType.Attachment.isCreateable()){ DMLManager.insertAsUser(a); }else{ }                                  
            return 'SUCCESS';
        }catch(DMLException ex){
            return 'FAILURE';            
        }
    }
}