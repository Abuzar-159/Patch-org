({
    doInit : function(component, event, helper) {
            
        var action = component.get("c.brcodeImage");
        action.setParams({
            "Brcd" : component.get("v.Value"),
            "BarcdType" : component.get("v.BrcdType"),
            "BarcdHeight" : component.get("v.BrcdHeight"),
            "BarWidth" : component.get("v.BarsWidth"),
            "brcdValHide" : component.get("v.hideText"),
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.response1", response.getReturnValue());

            }
        });
        $A.enqueueAction(action);
    },
})