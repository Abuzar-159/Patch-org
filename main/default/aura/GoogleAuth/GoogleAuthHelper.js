({
    showToast : function(title, type, message) {
        console.log('called');
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message 
            });
            toastEvent.fire();
        }
    },
    UploadFile: function(parentId, documentIds,SyncSales, SyncGDrive,component,event){
        try{
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action = component.get("c.uploadGFile");
            action.setParams({
                parent: parentId,
                documentIds: documentIds,
                SyncSales: SyncSales,
                SyncGDrive: SyncGDrive
            });
            action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS'){
                    console.log('SUCCESS');
                    component.set("v.fillList",[]);
                    component.set("v.showDelete",false);
                    component.set("v.profile", response.getReturnValue().userDetail); 
                    if(response.getReturnValue().Error != null && response.getReturnValue().Error !='') {
                       this.showToast('Error','error',response.getReturnValue().Error);  
                    }else{
                        if(SyncSales == true && SyncGDrive == true){
                            this.showToast('Success','success','Attachment and Google File Created Successfully.');
                        }else if(SyncSales == true && SyncGDrive == false){
                            this.showToast('Success','success','Attachment Created Successfully.');
                        }else if(SyncSales == false && SyncGDrive == true){
                            this.showToast('Success','success','Google File Created Successfully.');
                        }
                    }
                    $A.util.addClass(component.find('mainSpin'), "slds-hide"); 
                    $A.get('e.force:refreshView').fire();                
                }else{                
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    var errors = response.getError();
                    if (errors) {
                        console.log(JSON.stringify(errors));
                        if (errors[0] && errors[0].message) {                                    
                            this.showToast('Error','error',errors[0].message);
                        }
                    } else {
                        console.log("Unknown error~>"+errors);
                    }                
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log('error ' + e);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
    }
})