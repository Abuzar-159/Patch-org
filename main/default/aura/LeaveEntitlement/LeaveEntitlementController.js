({
    getValues: function(cmp) {
        var action = cmp.get("c.getEntme");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.EmpEnt", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})