public with sharing class ESignature {
    @AuraEnabled
     public static Attachment captureSignature(String imageData, String parentid, String name) { 
         Attachment attach=new Attachment();
        try {   
            String imgSig=imageData;
            imgSig=imgSig.substringAfter(',');
            
            Attachment a = new Attachment(ParentId = parentid, Body =EncodingUtil.base64Decode(imgSig), ContentType = 'image/png', Name=name);        
            try { if(Schema.sObjectType.Attachment.isCreateable()){ DMLManager.insertAsUser(a); }else{ }
                  
                 attach=[Select Id,Name From Attachment where parentid=:parentid limit 1];
                 
                 
            } catch(DMLException ex) {  }  } catch(Exception e) { }
      return attach;
    }

}