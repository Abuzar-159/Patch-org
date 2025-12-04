({
	setRfpDetails : function(component, event, reqIndex, resIndex) {
        //alert("reqIndex : "+reqIndex);alert("resIndex : "+resIndex);
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        //alert("INIT helper called...");
		var action = component.get("c.fetchAllDetails");
        action.setParams({
            RSId  : component.get("v.reqSupplierId"),
            isEvaluate : true
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.clear();
                component.set("v.RFPWrap", response.getReturnValue());
                //rfp page.
                component.set("v.reqSupplier", response.getReturnValue().reqSupplier);
                component.set("v.request", response.getReturnValue().request);
                
                //requestandResponse Page.
                component.set("v.reqRequirements", response.getReturnValue().rfpRequirements);
                var reqs = component.get("v.reqRequirements");
                if(reqs.length>0){
                    if(reqIndex >= 0){
                        reqs[reqIndex].isCurrentReq = true;
                        if(resIndex >= 0){
                            reqs[reqIndex].childReqs[resIndex].isCurrentReq = true;
                        }
                    }
                    component.set("v.reqRequirements", reqs);
                }
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
	},
    
    setRating : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchRating");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.resRatingOptions",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    
    setCompliance : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchCompliance");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.resComplianceOptions",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    
    saveResponses : function(component, event, allResponsess, isSubmitted){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.save_reqResponses");
        action.setParams({
            allRess : JSON.stringify(allResponsess),
            isSubmit : isSubmitted,
            rfpSupp : JSON.stringify(component.get("v.reqSupplier"))
        });
        action.setCallback(this, function(response){
            //alert(response.getState());
            if(response.getState() === "SUCCESS"){
                component.set("v.serverSuccess","Responses Captured Successfully");
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.exceptionError","");
                    }), 3000
                );
                //get opened index.
                var reqIndex = -1;
                var childReqIndex = -1;
                var req = component.get("v.reqRequirements");
                for(var i in req){
                    if(req[i].isCurrentReq) reqIndex = i;
                    for(var j in req[i].childReqs){
                        if(req[i].childReqs[j].isCurrentReq) childReqIndex = j;
                    }
                }
                if(reqIndex == -1) reqIndex = 0;
                this.setRfpDetails(component, event, reqIndex, childReqIndex);
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    reRender : function(component, event, helper) { },
    
    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }
    }
})