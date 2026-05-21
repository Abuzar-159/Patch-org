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
        }else{
            sforce.one.showToast({
                "title": title,
                "message": message,
                "type": type
            });
        }
    },
    
    fetchOrg : function(cmp, event, helper) {
        var action = cmp.get("c.getDefaultOrganisation");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                cmp.set("v.Organisation",response.getReturnValue()); 
            }  
        });
        $A.enqueueAction(action); 
    },
    
    fetchPackageType : function(cmp, event, helper) {
        var action = cmp.get("c.fetchPackageType");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                cmp.set("v.PackageType",response.getReturnValue()); 
            }  
        });
        $A.enqueueAction(action); 
    },
    
    fetchCusAddress : function(component, event, helper) {
        var action=component.get("c.fetchCusAddress");
        action.setParams({'Id':component.get("v.AccId")});
        action.setCallback(this,function(response){
            component.set('v.toAddId',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
})