({
    doInit: function (component, event, helper) {
        try {
            var recordId = component.get("v.recordId");
            component.set("v.recordId", recordId);
            console.log('recordId'+recordId);
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action = component.get("c.ActiveUser");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try{         
                        console.log('loaded');  
                        component.set("v.hasAccess",true);
                        component.set("v.profile", response.getReturnValue().userDetail);
                        console.log(response.getReturnValue().Error);                        
                        $A.util.addClass(component.find('mainSpin'), "slds-hide"); 
                    }catch(e){
                        console.log('error '+e);
                    }
                } else {
                    console.log('Error calling Apex class method ' + JSON.stringify(response.getError()));
                }
                
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log('error ' + e);
        }
    },
    GoogleLogin: function (component, event, helper) {
        try {
            var action = component.get("c.GoogleDriveAuthUri");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    window.location.href = response.getReturnValue();
                } else {
                    console.log('Error calling Apex class method ' + JSON.stringify(response.getError()));
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log('error ' + e);
        }
    },
    handleFilesChange: function(component, event, helper) {
        console.log('inside file change:');
        try{
        component.set("v.showDelete",true);
        var fileName = 'No File Selected..';
        
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            var fileItem = [];
            for(var i=0;i<event.getSource().get("v.files").length;i++){
                fileItem.push(event.getSource().get("v.files")[i]['name']);
            }
        }
        
       component.set("v.fillList",fileItem);
       console.log('Filname :',fileName);
       component.set("v.fileName", fileName);
        }catch(e){
            console.log(e);
        }
    },
    removeAttachment : function(component, event, helper) {
        component.set("v.showDelete",false);
        var fileName = 'No File Selected..';
        component.set("v.fileName", fileName);
        
        var fillList=component.get("v.fillList");
        fillList.splice(0, fillList.length); 
        component.set("v.fillList",fillList);
    },
    handleCheckSalesforce : function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        component.set("v.SyncSalesforce", isChecked);
        component.set("v.isFileUploadDisabled", false);
        var SyncSales = component.get("v.SyncSalesforce");
                var SyncGDrive = component.get("v.SyncGDrive");
            if(!SyncSales && !SyncGDrive){                
                component.set("v.isFileUploadDisabled", true);
            }
    },
    
    handleCheckGDrive : function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        component.set("v.SyncGDrive", isChecked);
        component.set("v.isFileUploadDisabled", false);
        var SyncSales = component.get("v.SyncSalesforce");
                var SyncGDrive = component.get("v.SyncGDrive");
            if(!SyncSales && !SyncGDrive){                
                component.set("v.isFileUploadDisabled", true);
            }
    },
    uploadFile : function(component, event, helper){
        console.log('uploadFile Called');
        try {
            var SyncSales = component.get("v.SyncSalesforce");
                var SyncGDrive = component.get("v.SyncGDrive");
            if(!SyncSales && !SyncGDrive){                
                helper.showToast($A.get('$Label.c.PH_Warning'),'warning','Please Select Salesforce or Google Drive');
            }else if(SyncSales == true && SyncGDrive == false){
                helper.showToast('Success','success','Attachment Created Successfully.');
            }else{
                var FileInput = component.get("v.FileList");
                var parentId = component.get("v.recordId"); 
                var FileIds=[];
                var uploadedFiles = event.getParam("files");
                console.log('uploadedFiles '+JSON.stringify(uploadedFiles));
                for(var i in uploadedFiles)
            if(uploadedFiles[i].documentId !='')
                FileIds.push(uploadedFiles[i].documentId);
                console.log('FileIds '+JSON.stringify(FileIds));
                helper.UploadFile(parentId, FileIds, SyncSales, SyncGDrive,component,event);                
            }
        } catch (e) { 
            console.log('error ' + e);
        }        
    },
    cancelBtn : function(component, event, helper) {
        location.reload();
        //window.location.href = "/"+component.get("v.recordId");
    },
    reRender : function(component, event, helper) {
        
    }
})