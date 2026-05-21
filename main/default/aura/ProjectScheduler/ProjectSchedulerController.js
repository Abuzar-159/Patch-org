({
	doInit : function(component, event, helper) {
        //helper.getDetails(component, event);
        var today = new Date();
        today = $A.localizationService.formatDate(today, "MMMM DD, YYYY");
        component.set("v.TODAY", today);
	},
    
    initGantt : function(component, event, helper) {
        helper.getDetails(component, event, helper);
    }
})