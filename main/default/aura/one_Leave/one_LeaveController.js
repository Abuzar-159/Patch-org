({
    handleAccountDelete: function(component, event, helper) {
        helper.refreshAccounts(component);
    },
    handleAccountEdit: function(component, event, helper) {
        component.set("v.accountId", event.getParam("recordId"));
    },
    handleAccountQuicksave: function(component, event, helper) {
        helper.refreshAccounts(component);
    },
    handleInit: function(component, event, helper) {
        helper.refreshAccounts(component); 
    },
    toggle: function(component, event, helper) {
        var toggleText = component.find("hide");
        $A.util.toggleClass(toggleText, "toggle");
        var hdr = component.find("header");
        $A.util.toggleClass(hdr, "toggle");
        var btn = component.find("newButton");
        $A.util.toggleClass(btn, "slds-hide");
        var tab = component.find("cmp");
        $A.util.toggleClass(tab, "slds-hide");
        helper.Create(component, event, helper)
    },
    testToggle: function(component, event, helper) {
        var toggleText = component.find("hide");
        $A.util.toggleClass(toggleText, "toggle");
        var hdr = component.find("header");
        $A.util.toggleClass(hdr, "toggle");
        var btn = component.find("newButton");
        $A.util.toggleClass(btn, "slds-hide");
        var tab = component.find("cmp");
        $A.util.toggleClass(tab, "slds-hide");
        helper.Navigate(component, event, helper)
    }
})