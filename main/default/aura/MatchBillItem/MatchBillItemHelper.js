({
	 showToast : function(title, type, message) {
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
    createRecord :function(component,event,sObject,defaultvalues){
         var windowHash = window.location.hash;
            var createRecordEvent = $A.get("e.force:createRecord");
        if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": sObject,
                "defaultFieldValues":defaultvalues,
                "panelOnDestroyCallback": function(event) {
                    window.location.hash = windowHash;
                }
            });
            
                createRecordEvent.fire();
        }     
    },
    checkvalidation : function(component,event){
        var vouchercmp = component.find("voucheramount");
        var voucherAmt = vouchercmp.get("v.value");
        
        if($A.util.isEmpty(voucherAmt) || parseFloat(voucherAmt) <= 0.00){
            vouchercmp.set("v.class","slds-input hasError");
            component.noErrors = false;
        }else
            vouchercmp.set("v.class","slds-input");
    },
    
    HelperSaveRecord : function(component,event, helper){
        
        var item = component.get("v.item");
        component.set("v.item.ERP7__Matched__c",true);
        component.set("v.item.ERP7__Approved__c",true);
        component.set("v.item.ERP7__Posted__c",true);
        item.ERP7__Matched__c = true;
        item.ERP7__Approved__c = true;
        item.ERP7__Posted__c = true;
        var updateAction = component.get("c.update_Bill");
                        updateAction.setParams({"obj":JSON.stringify(component.get("v.item"))});
                        updateAction.setCallback(this,function(response){
                            if(response.getState() === 'SUCCESS'){
                                //helper.showToast('Error!','error','Please Match the Bill Before Approve');
                            }
                            
                        });
                        $A.enqueueAction(updateAction);
    },
})