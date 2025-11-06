({
    getLeaveDetails: function(component, event, helper) {
        var action = component.get("c.getApproval");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Leaves", response.getReturnValue());
                component.set("v.sortAsc", true);
            	this.sortBy(component, "ERP7__Employee__r.ERP7__Last_Name__c");
            }
        });
        $A.enqueueAction(action);
    },
    
    sortBy: function(component, field, helper) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            Leaves = component.get("v.Leaves");
        sortAsc = field == sortField? !sortAsc: true;
        Leaves.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.Leaves", Leaves);
    }
})