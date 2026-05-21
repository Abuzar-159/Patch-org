({
    getExpDetails: function(component, event, helper) {
        var action = component.get("c.getApproval");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Exp", response.getReturnValue());
                component.set("v.sortAsc", true);
            	helper.sortBy(component, "Name");
            }
        });
        $A.enqueueAction(action);
    },
    sortByName: function(component, event, helper) {
        helper.sortBy(component, "Employees__r.First_Name__c");
    },
    sortByNameExp: function(component, event, helper) {
        helper.sortBy(component, "Name");
    },
    sortByProject: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Project__r.Name");
    },
    sortBySubmitted: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Amount_Submitted__c");
    },
    sortByVat: function(component, event, helper) {
        helper.sortBy(component, "ERP7__VAT_Amount__c");
    },
    sortByClaimed: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Amount__c");
    },
    sortByStatus: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Status__c");
    },
    show1: function(component, event, helper) {
        try{
            var rid = component.set("v.rid", event.currentTarget.dataset.record);
        //var cmp = component.find('Approve');
        $A.util.addClass(component.find("Approve"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
        }catch(Exception){
            console.log('Exception',Exception);
        }
        
    },
    show2: function(component, event, helper) {
        var rid = component.set("v.rid", event.currentTarget.dataset.record);
        //var cmp = component.find('Reject');
         $A.util.addClass(component.find("Reject"), 'slds-fade-in-open');
        $A.util.addClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
    },
    
     hide1: function(component, event, helper) {
        //var rid = component.set("v.rid", event.target.dataset.record);
        //var cmp = component.find('Approve');
        $A.util.removeClass(component.find("Approve"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
    },
    hide2: function(component, event, helper) {
        //var rid = component.set("v.rid", event.target.dataset.record);
        //var cmp = component.find('Reject');
         $A.util.removeClass(component.find("Reject"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
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
        var action = component.get("c.saveApprovedExpense");
        action.setParams({
            reason: body.get("v.value"),
            tid: upd,
            sts: "Approved"
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                $A.util.removeClass(component.find("Approve"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
                helper.showToast('Success!','success','Expense Approved');
                var submittedTs = component.get("v.Exp");
                helper.getExpDetails(component, event, helper);
                var btn = event.source;
                var cmp = component.find(btn.get("v.buttonTitle"));
                body.set("v.value", '');
            }
        });
        $A.enqueueAction(action);
    },
    reject: function(component, event, helper) {
        var upd = component.get("v.rid");
        var action = component.get("c.saveApprovedExpense");
        action.setParams({
            reason: component.find("ReasonRejected").get("v.value"),
            tid: upd,
            sts: "Rejected"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                $A.util.removeClass(component.find("Reject"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("expenseBackdrop"), 'slds-backdrop_open');
                helper.showToast('Success!','success','Expense Rejected');
                helper.getExpDetails(component, event, helper);
                var btn = event.source;
                var cmp = component.find(btn.get("v.buttonTitle"));
            }
        });
        $A.enqueueAction(action);
    }
})