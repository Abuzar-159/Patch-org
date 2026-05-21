({
	doInit : function(cmp, event, helper) {
        var brcdheight = cmp.get("v.BrcdHeight");
        var brcdtype = cmp.get("v.BrcdType");
        var value = cmp.get("v.Value");
        var height = cmp.get("v.Height");
        var width = cmp.get("v.Width");
        var action = cmp.get("c.getAll"); 
        action.setParams({BarcdHeight:brcdheight,BarcdType:brcdtype,Brcd:value,Height:height,Width:width});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                cmp.set("v.BrcodeImage", response.getReturnValue());
            }      
        });
        $A.enqueueAction(action);
    }, 
})