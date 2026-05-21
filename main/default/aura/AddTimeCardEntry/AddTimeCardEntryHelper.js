({
    onchangeHelper: function(component, event, helper) {
        var newDate = component.get("v.timeSheet.ERP7__Week_Date__c");
        var dayadd = component.get("v.intweek");
        var action = component.get("c.TimeSheet_ManagerLC");
        action.setParams({
            nodays: dayadd,
            dateChange: newDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.counts', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message + errors);
                    }
                } else {
                    console.log("Unknown error" + errors);
                }
            }
        });
        $A.enqueueAction(action);
    }
    
})