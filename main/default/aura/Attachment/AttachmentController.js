({
    doSave: function(component, event, helper) {
       helper.doSave(component, event, helper);
    },
 
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..'; 
        var fileBody=event.getSource().get("v.files")[0]
      
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
             // component.set("v.AttachmentBody",event.getSource().get("v.files")[0]);
           /*FOR PLM APPLICATION*/
            if(component.get("v.Application")=='PLM') helper.doSave(component, event, helper);
        } 
        component.set("v.fileName", fileName);
    },
    
    doInitNew:function(component, event, helper) {
        helper.doInitNew(component, event, helper);
        
    },
})