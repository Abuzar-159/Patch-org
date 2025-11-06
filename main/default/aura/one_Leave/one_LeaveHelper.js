({
    refreshAccounts: function(component) {
        var self = this; 
        var refreshAction = component.get("c.getAccounts");
        refreshAction.setCallback(self, function(a) {
            component.set("v.accounts", a.getReturnValue());
        });
        $A.enqueueAction(refreshAction);
    },
    Navigate: function(component, event, helper) {
        var action = component.get("c.getLeavebyId");
        action.setParams({
            strId: event.getParams("leaveId")['leaveID']
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                
                $A.createComponent(
                    "c:LeaveRequestForm", {
                        "LeaveReqs": response.getReturnValue()
                    },
                    function(newCmp) {
                        if (component.isValid()) {
                            var body = component.get("v.body");
                            body.push(newCmp);
                            component.set("v.body", body);
                        }
                    }
                );
            }
        });
        $A.enqueueAction(action);
    },
    Create: function(component, event, helper) {
        $A.createComponent(
            "c:LeaveRequestForm", {
                
            },
            function(newCmp) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);
                }
            }
        );
    }
})