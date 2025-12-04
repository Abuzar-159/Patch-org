({
	doInitHandler: function(component, event, helper){
        var action = component.get("c.myConstruct");
        var sId = component.get("v.shipmentId");
        if(sId == 'undefined' || sId == null || sId == undefined) sId = '';
        action.setParams({ 
            shipId:sId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var obj = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.myConsW", obj);
                
                if(sId != 'undefined' && sId != null && sId != undefined && sId != ''){
                    component.set("v.shipment", obj.Shipment);
                    component.set("v.fromAddress", obj.fromAddress);
                    component.set("v.address", obj.toAddress);
                    component.set("v.packageList", obj.Packages);
                }
            }
        });
        $A.enqueueAction(action);
    },
      
    helperFun : function(component,event,secId) {
	  	var acc = component.find(secId); 
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        } 
	}
})