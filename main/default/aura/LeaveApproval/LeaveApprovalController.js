({
    getLeaveDetails: function(component, event, helper) {
        helper.getLeaveDetails(component, event, helper);
    },
    sortByName: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Employee__r.ERP7__Last_Name__c");
    },
    show1: function(component, event, helper) {
        var rid = component.set("v.rid", event.target.dataset.record);
        var cmp = component.find('Approve');
        $A.util.addClass(cmp.getElement(), 'slds-show');
    },
    show2: function(component, event, helper) {
        var rid = component.set("v.rid", event.target.dataset.record);
        var cmp = component.find('Reject');
        $A.util.addClass(cmp.getElement(), 'slds-show');
    },
    Modal_hide: function(component, event, helper) {
        var btn = event.source;
        var cmp = component.find(btn.get("v.buttonTitle"));
        $A.util.removeClass(cmp.getElement(), 'slds-show');
        $A.util.addClass(cmp.getElement(), 'slds-hide');
        var apbtn = component.find('appbtn');
        var rejbtn = component.find('rejectbtn');
        $A.util.removeClass(apbtn, 'slds-show');
        $A.util.removeClass(rejbtn, 'slds-show');
    },
    Approve: function(component, event, helper) {
        var upd = component.get("v.rid");
        var body = component.find("ReasonApproved");
        var action = component.get("c.saveApprovedLeave");
        action.setParams({
            reason: body.get("v.value"),
            tid: upd,
            sts: "Approved"
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var submittedTs = component.get("v.Leaves");
                helper.getLeaveDetails(component, event, helper);
                var btn = event.source;
                var cmp = component.find(btn.get("v.buttonTitle"));
                $A.util.removeClass(cmp.getElement(), 'slds-show');
                $A.util.addClass(cmp.getElement(), 'slds-hide');
                body.set("v.value", '');
            }
        });
        $A.enqueueAction(action);
    },
    reject: function(component, event, helper) {
        var upd = component.get("v.rid");
        var action = component.get("c.saveApprovedLeave");
        action.setParams({
            reason: component.find("ReasonRejected").get("v.value"),
            tid: upd,
            sts: "Rejected"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.getLeaveDetails(component, event, helper);
                var btn = event.source;
                var cmp = component.find(btn.get("v.buttonTitle"));
                $A.util.removeClass(cmp.getElement(), 'slds-show');
                $A.util.addClass(cmp.getElement(), 'slds-hide');
            }
        });
        $A.enqueueAction(action);
    }
})