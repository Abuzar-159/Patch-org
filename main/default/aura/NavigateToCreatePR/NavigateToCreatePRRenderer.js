({
    rerender : function(component, helper) {
        this.superRerender();
        var urlEvent = $A.get("e.force:navigateToURL");
        
        if(urlEvent) {
            urlEvent.setParams({
                "url": "/lightning/n/ERP7__Create_Purchase_Requisition"
            });
            
            urlEvent.fire();
        }
    }
})