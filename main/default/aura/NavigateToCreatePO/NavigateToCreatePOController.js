({
    InitLoad : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        
        if(urlEvent) {
            urlEvent.setParams({
                "url": "/lightning/n/ERP7__Create_Purchase_Orders"
            });
            
            urlEvent.fire();
        }
    }
})