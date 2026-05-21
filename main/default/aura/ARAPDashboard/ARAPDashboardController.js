({
	closeIframe: function(component, event, helper) {
        // Set the visibility attribute to false to hide the iframe
        component.set("v.isIframeVisible", false);
        if(component.get("v.fromAP")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Accounts_Payable",
                componentAttributes: {  
                }
            });
            evt.fire();
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:AccountsReceivable",
                componentAttributes: {  
                }
            });
            evt.fire();
        }
    }
})