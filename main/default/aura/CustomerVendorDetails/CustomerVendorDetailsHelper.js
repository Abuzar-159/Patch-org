({
	fetchAmountDetails : function(component, event, helper) {
        var action=component.get("c.fetchAmounts");
        action.setParams({
            "customerVendorId":component.get("v.customerVendorId"),
            "StartDate":component.get("v.StartDate"),
            "EndDate":component.get("v.EndDate")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.TransactionAmountWrapper",response.getReturnValue());
                //component.set("v.StartDate",response.getReturnValue().StartDate);
                //component.set("v.EndDate",response.getReturnValue().EndDate);
                //component.set("v.showMmainSpin",false);
            }  
        });
        $A.enqueueAction(action);
    },
})
({
    handleScroll: function(component, event, helper) {
        var header = component.find("myHeader").getElement();
        var sticky = header.offsetTop;
        
        if (window.pageYOffset > sticky) {
            $A.util.addClass(header, "sticky");
        } else {
            $A.util.removeClass(header, "sticky");
        }
    }
})