({
	getYears : function(component) {
        var action = component.get("c.getYearsList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.years", response.getReturnValue());
            }
            else {
                console.log("Failed to get years");
            }
        });
        $A.enqueueAction(action);
    },
    
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
})