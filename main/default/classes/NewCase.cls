public with sharing class NewCase {    
    
    public String category                           { get; set; }    
    public String topic                              { get; set; }
    public String severity                           { get; set; }
    public String subject                            { get; set; }
    public String description                        { get; set; }
    public String noteDesp                           { get; set; } 
    public String currentIndex                       { get; set; }
    public String lookupId                           { get; set; }
    public String selectValue                        { get; set; }      
    public String objectName                         { get; set; } public String objectID                           { get; set; }     
    public String customLabel                        { get; set; }
    public ICE__c newICE                             { get; set; }
    public Note newComment                           { get; set; }
    public ID newIceCaseID                           { get; set; }         
    public ICE__c topicList                          { get; set; }
    public List <RecordType> rType                   { get; set; }
    public List <Note> notesList                     { get; set; }
    public List<Attachment> attList                  { get; set; }      
    public Attachment newAttachment                  { get; set; }  public Boolean preventDisplay                    { get; set; }
    public Boolean lookupLabel                       { get; set; }   
    public Boolean showAttachBlock                   { get; set; }
    public Boolean showCommentBlock                  { get; set; }
    public Boolean showComments_Attachcments         { get; set; }        
    public List <attachmentWrapper> attachmentList   { get; set; }         
    public Map<String,Id> RecordTypeByIdMap          { get; set; }        
    public Boolean showIcePopup                      { get; set; } 
    public Boolean bool                              { get; set; }  
    public String caseId                             { get; set; }
    
    /*      
      constructor
    */    
    public NewCase() {
    
        try {
            severity = 'Medium';
            customLabel = '';
            RecordTypeByIdMap = new Map<String,Id>{};
            attachmentList = new List <attachmentWrapper>();
            newAttachment = new Attachment();
            attList = new List<Attachment>();
            if(caseId == null) {
                attachmentWrapper AW = new attachmentWrapper();
                AW.Att = new Attachment();
                attachmentList.add(AW);
            }
            newIceCaseID = null;
            showComments_Attachcments = false;                    
            showIcePopup = false;    
            newICE = new ICE__c();     
            bool = false;
            if(ApexPages.CurrentPage().getParameters().get('caseId') != null) caseId = String.escapeSingleQuotes(EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('caseId'),'UTF-8'));
            if(caseId != null) { showCommentBlock = true; showComments_Attachcments = true; topicList = new ICE__c(); String iceFields; if(Schema.sObjectType.ERP7__ICE__c.isAccessible()) iceFields = UtilClass.selectStarFromSObject('ERP7__ICE__c');  UtilClass.FlSCheck(iceFields.split(',') ,'ERP7__ICE__c');List <ICE__c> iceList; if(!Schema.sObjectType.ICE__c.isAccessible()){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ICE__c.Label)); }else{iceList = Database.query('select ' + String.escapeSingleQuotes(iceFields) + ' from ICE__c where id = \''+ String.escapeSingleQuotes(caseId) +'\' limit 1');}
             String rType;  
             if(!Schema.sObjectType.RecordType.isAccessible()) {  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.RecordType.Label)); 
            } else {
              String rtid = '';
              if(iceList.size()>0) if(iceList[0].RecordTypeId != null) rtid = iceList[0].RecordTypeId;
              if(String.isNotEmpty(rtid)) rType = Schema.SObjectType.ERP7__ICE__c.getRecordTypeInfosById().get(rtid).getName(); 
            }      
            if(Schema.sObjectType.RecordType.fields.Name.isAccessible() && String.isNotEmpty(rType)) category = rType;  
            if(Schema.sobjectType.ICE__c.fields.Topic__c.isAccessible()) topicList.Topic__c = iceList[0].Topic__c;  if(Schema.sobjectType.ICE__c.fields.Priority__c.isAccessible()) severity = iceList[0].Priority__c; if(Schema.sobjectType.ICE__c.fields.Subject__c.isAccessible()) subject = iceList[0].Subject__c; if(Schema.sobjectType.ICE__c.fields.Description__c.isAccessible()) description = iceList[0].Description__c; if(Schema.sObjectType.Note.isAccessible()) notesList = [select id, Title, Body, ParentId, CreatedDate from Note where parentId =: caseId order by CreatedDate DESC]; if(Schema.sObjectType.attachment.isAccessible()) attList = [select id, name, parentId, createdDate from attachment where parentId =: caseId order by CreatedDate DESC];for(Attachment att: attList) {attachmentWrapper AW1 = new attachmentWrapper(); Aw1.Att = att;if(Schema.sObjectType.attachment.fields.Name.isAccessible()) Aw1.attName = Aw1.Att.name; if(Schema.sObjectType.attachment.fields.createdDate.isAccessible()) Aw1.dt = att.createdDate;   attachmentList.add(Aw1);  } } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      Fetch list of record type from Ice
    */    
    public List<SelectOption> getrTypeList() { 
    try{   
        if(!Schema.sObjectType.RecordType.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.RecordType.Label)); return null;
   } else{
        rType =  [Select ID, Name, IsActive From RecordType Where sObjectType = 'ERP7__ICE__c' And IsActive = true];
        } 
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('', '-- Select a Category --'));        
        for(RecordType r : rType) {
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible()) RecordTypeByIdMap.put(r.Name,r.Id);
            if(Schema.sObjectType.RecordType.fields.Name.isAccessible()) options.add(new selectOption(r.Name,r.Name));
        }        
        return options;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      Getter property for severity
    */
    public List<SelectOption> getPriority() {
    try{
        List<SelectOption> options = new List<SelectOption>();
            options.add(new selectOption('-- Select a severity level--', '-- Select a severity level--'));
            options.add(new selectOption('Critical', 'Critical'));
            options.add(new selectOption('High', 'High'));
            options.add(new selectOption('Medium', 'Medium'));
            options.add(new selectOption('Low', 'Low'));
            return options;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
    }    
                                      
    /*
      Add new ice case
    */    
    public PageReference saveNewICE() {   
        try {
                    
        if (Schema.sObjectType.ICE__c.fields.Topic__c.isCreateable() && Schema.sObjectType.ICE__c.fields.Topic__c.isUpdateable()) {newICE.Topic__c = topic;}
        if (Schema.sObjectType.ICE__c.fields.Priority__c.isCreateable() && Schema.sObjectType.ICE__c.fields.Priority__c.isUpdateable()) {newICE.Priority__c = severity;}
        if (Schema.sObjectType.ICE__c.fields.Subject__c.isCreateable() && Schema.sObjectType.ICE__c.fields.Subject__c.isUpdateable()) {newICE.Subject__c = subject;}
        if (Schema.sObjectType.ICE__c.fields.Description__c.isCreateable() && Schema.sObjectType.ICE__c.fields.Description__c.isUpdateable()) {newICE.Description__c = description;}
        if (Schema.sObjectType.ICE__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ICE__c.fields.RecordTypeId.isUpdateable()) {newICE.RecordTypeId = RecordTypeByIdMap.get(category);}         
        if (Schema.sObjectType.ICE__c.fields.Status_Duration__c.isCreateable() && Schema.sObjectType.ICE__c.fields.Status_Duration__c.isUpdateable()) {newICE.Status_Duration__c = 'New';}            
            if(Schema.sObjectType.ICE__c.isCreateable() && Schema.sObjectType.ICE__c.isUpdateable()) DMLManager.upsertAsUser(newICE);  else{ }                    
            newIceCaseID = newICE.id;
            showComments_Attachcments = true;        
            showCommentBlock = true;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      getter property for dynamic custom lookup
    */
    public String fetchLookup {
        get {            
           try {
               if((objectName != null && objectName != '') || (lookupId != null && lookupId != '')) {
                    bool = false;
                    String convertedString;
                    if(objectName != null && (lookupId == '' || lookupId == null)) {lookupId = objectName;category = objectName;customLabel = lookupId;
                    }
                    if(lookupId != null) convertedString = lookupId;            
                    if(lookupId != null) {
                        topicList = new ICE__c(RecordTypeId=RecordTypeByIdMap.get(lookupId));
                    }   
                    String q; 
                    if(Schema.sObjectType.ERP7__ICE__c.isAccessible())                                    
                    q = UtilClass.selectStarFromSObject('ERP7__ICE__c');
                    UtilClass.FlSCheck(q.split(',') ,'ERP7__ICE__c'); 
                    if(convertedString != null){ 
                        convertedString = convertedString.replace(' ','_');
                        bool = q.containsIgnoreCase(convertedString); 
                    }           
                    if(bool == true) {
                        lookupLabel = true;
                        return convertedString+'__c'; }    }   } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }            
            
            return null;            
        }
    }
    
    /*
      fetching record type value in lookupId
    */
    public PageReference fetchLookup() {            
        try {
            if(fetchLookup != null) {
                customLabel = lookupId;
            } else {
                customLabel = '';
            }
            if(lookupId != null) category = lookupId; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }     
        return null;
    }
    
    /*
      Render comment or attachment block
    */
    public PageReference uploadComment_Attachment() { 
        try {
            if(selectValue == 'Attachment') { showComments_Attachcments = true; showAttachBlock = true;  showCommentBlock = false;
            } else if(selectValue == 'Comment') { showComments_Attachcments = true;showCommentBlock = true; showAttachBlock = false;    if(newIceCaseID != null)  if(!Schema.sObjectType.Note.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Note.Label)); return null;} else { notesList = [select id, Title, Body, ParentId, CreatedDate from Note where parentId =: newIceCaseID order by CreatedDate DESC]; }      }   } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }                                   
        return null;
    }
        
    /*
      Upload new attachment
    */      
    public PageReference uploadAttachment() {                          
        try {
            showCommentBlock = false;
            showAttachBlock = true;
            ICE__c iceParentId;
            attachmentWrapper AW;
            attachment att;
            if(newIceCaseID != null || caseId != null) 
                if(!Schema.sObjectType.ICE__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ICE__c.Label)); return null;
   } else {
              iceParentId = [select id, name, RecordTypeId from ICE__c where id =: newIceCaseID OR id =: caseId limit 1];  }    
                       
            if(currentIndex != null) AW = attachmentList.get(Integer.valueOf(currentIndex) - 1);        
            if(iceParentId.id != null) newAttachment.ParentId = iceParentId.id;            
            try {
                if(Schema.sObjectType.Attachment.isCreateable() && Schema.sObjectType.Attachment.isUpdateable()) DMLManager.insertAsUser(newAttachment); else{ }
            } catch(Exception e) {}        
            if(AW.Att.Id != null && Schema.sObjectType.attachment.isDeletable()) DMLManager.deleteAsUser(AW.Att); if(iceParentId.id != null) if(!Schema.sObjectType.attachment.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.attachment.Label)); return null; } else {att = [select id, name, parentId, createdDate from attachment where parentId =: iceParentId.id limit 1];  }  AW.Att = newAttachment;if(AW.Att.Name != null) if(Schema.sObjectType.attachment.fields.Name.isAccessible()) Aw.attName = AW.Att.Name;if(att != null) if(Schema.sObjectType.attachment.fields.createdDate.isAccessible()) Aw.dt = att.createdDate;if(Schema.sObjectType.Attachment.fields.body.isAccessible()) newAttachment.body = null;    newAttachment = new Attachment();   showIcePopup = true;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      Upload new comment
    */     
    public PageReference uploadComment() {                       
        try {   
            ICE__c iceParentId;
            if(newIceCaseID != null || caseId != null) 
                if(!Schema.sObjectType.ICE__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ICE__c.Label));return null;
   } else {
              iceParentId = [select id, name, RecordTypeId from ICE__c where id =: newIceCaseID OR id =: caseId limit 1];   }   
                
            showCommentBlock = true;
            showAttachBlock = false;
            newComment = new Note();            
            if(Schema.sObjectType.Note.fields.Title.isAccessible()) newComment.Title = 'Comment';
            if(noteDesp != null) if(Schema.sObjectType.Note.fields.Body.isAccessible()) newComment.Body = noteDesp;        
            if(iceParentId.id != null) if(Schema.sObjectType.Note.fields.ParentId.isAccessible()) newComment.ParentId = iceParentId.id;        
            if(Schema.sObjectType.Note.isCreateable() && Schema.sObjectType.Note.isUpdateable()) DMLManager.upsertAsUser(newComment); else{ }
            
            if(iceParentId.id != null)
                if(!Schema.sObjectType.Note.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Note.Label));return null;
   } else {
              notesList = [select id, Title, Body, ParentId, CreatedDate from Note where parentId =: iceParentId.id order by CreatedDate DESC];}          
                
            noteDesp = '';} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } 
        return null;
    }       
    
    /*
      Back to 2 supportPage
    */    
    public PageReference Back2Support() { 
        try{       
        pageReference page = new pageReference('/apex/Support');
        page.setRedirect(true);        
        return page;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }return null;
    }
    
    /*
      Attachment wrapper class
    */    
    public class attachmentWrapper {
        public Attachment Att     { get; set; }   public String attName     { get; set; } public DateTime dt        { get; set; }              
    }    
    
    /*
      Add multiple attachment rows
    */    
    public PageReference addAttachment() {
        try{         
        attachmentWrapper AW = new attachmentWrapper();
        AW.Att = new Attachment();
        attachmentList.add(AW);  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }        
        return null;
    }        
    
    /*
      Remove attached rows
    */
    public PageReference removeAttachment() {        
        try {
            attachmentWrapper AW;
            if(currentIndex != null) AW = attachmentList.remove(Integer.valueOf(currentIndex) - 1);
            if(AW.Att.Id != null && Schema.sObjectType.Attachment.isDeletable()) DMLManager.deleteAsUser(AW.Att); else{ }
       } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      Get attachment List size
    */    
    public Integer getattachmentListSize(){
    try{
        return this.attachmentList.size();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }return null;
    }    
    
    /*
      hide ice popup
    */
    public pageReference hideIcePopup() {
    try{
        lookupLabel = true;
        showIcePopup = false;
        category = '';
        topic = '';
        severity = 'Medium';
        subject = '';
        description = '';
        lookupLabel = false;
        showAttachBlock = false;                   
        showCommentBlock = false;                  
        showComments_Attachcments = false;  
        notesList = new List <Note>();
        attachmentList = new List <attachmentWrapper>(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }       
        return null;
    }       
}