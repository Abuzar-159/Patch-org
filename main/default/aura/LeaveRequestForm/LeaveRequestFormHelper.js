({
    /*Submit: function(component, LeaveReq, helper) {
        component.set("v.LeaveReqs.ERP7__Leave_Start_Date__c", $A.util.sanitizeJs($(component.find("StrDate").getElement()).val()));
        component.set("v.LeaveReqs.ERP7__Leave_End_Date__c", $A.util.sanitizeJs($(component.find("EndDate").getElement()).val()));
        this.upsertLeaveRequestSub(component, LeaveReq, function(a) {
            var LeaveReqs = component.get("v.LeaveReqs");
            component.set("v.LeaveReqs", LeaveReqs);
        });
    },
    upsertLeaveRequestSub: function(component, LeaveReq, callback) {
        var action = component.get("c.getSaveLeaveRequest");
        var pickVal = component.find("leave").get("v.value");
        action.setParams({
            "LeaveReq": LeaveReq,
            str: "Submitted",
            leaveType:pickVal 
        });
        if (callback) {
            action.setCallback(this, callback);
        }
        $A.enqueueAction(action);
    },*/  
    upsertLeaveRequestSub: function(component, event, helper) {
        this.displayErrors(component, event, helper); 
        var errorMessageTime = component.get("v.errorMessage");
        
        setTimeout(
            $A.getCallback(function() {
                var errorMessage = component.get("v.errorMessage");
                if(errorMessage == undefined || errorMessage == null || errorMessage == ''){
                    component.set("v.LeaveReqs.ERP7__Leave_Start_Date__c", $(component.find("StrDate").getElement()).val());
                    component.set("v.LeaveReqs.ERP7__Leave_End_Date__c",$(component.find("EndDate").getElement()).val());
                    
                    var obj = component.get("v.LeaveReqs");
                    
                    
                    var action = component.get("c.getSaveLeaveRequest");
                    var pickVal = component.find("leave").get("v.value");
                    action.setParams({
                        "LeaveReq": component.get("v.LeaveReqs"),
                        str: "Submitted",
                        leaveType:pickVal 
                    });
                    
                    action.setCallback(this, function(a) {
                        var state = a.getState();
                        if (state === "SUCCESS") {
                            
                            var LeaveReqs = component.get("v.LeaveReqs");
                            component.set("v.LeaveReqs", a.getReturnValue());
                            
                        }else {
                            
                        }          
                    });
                    $A.enqueueAction(action);
                    setTimeout(
                        $A.getCallback(function() {
                            location.reload();
                        }), 4000
                    );
                }
                
            }), 2000
        );
    },
   /* Save: function(component, LeaveReq) {
        component.set("v.LeaveReqs.ERP7__Leave_Start_Date__c", $A.util.sanitizeJs($(component.find("StrDate").getElement()).val()));
        component.set("v.LeaveReqs.ERP7__Leave_End_Date__c", $A.util.sanitizeJs($(component.find("EndDate").getElement()).val()));
        this.upsertLeaveRequest(component, LeaveReq);
    },*/
    upsertLeaveRequest: function(component, event, helper) {
        
         this.displayErrors(component, event, helper); 
        var errorMessageTime = component.get("v.errorMessage");
        
        setTimeout(
            $A.getCallback(function() {
                var errorMessage = component.get("v.errorMessage");
                if(errorMessage == undefined || errorMessage == null || errorMessage == ''){
                    component.set("v.LeaveReqs.ERP7__Leave_Start_Date__c", $(component.find("StrDate").getElement()).val());
                    component.set("v.LeaveReqs.ERP7__Leave_End_Date__c",$(component.find("EndDate").getElement()).val());
                    
                    var obj = component.get("v.LeaveReqs");
                   
                    
                    var action = component.get("c.getSaveLeaveRequest");
                    var pickVal = component.find("leave").get("v.value");
                    action.setParams({
                        "LeaveReq": component.get("v.LeaveReqs"),
                        str: "Draft",
                        leaveType:pickVal 
                    });
                    
                    action.setCallback(this, function(a) {
                        var state = a.getState();
                        if (state === "SUCCESS") {
                            
                            var LeaveReqs = component.get("v.LeaveReqs");
                            component.set("v.LeaveReqs", a.getReturnValue());
                            
                        }else {
                            
                        }          
                    });
                    $A.enqueueAction(action);
                    setTimeout(
                        $A.getCallback(function() {
                            location.reload();
                            /*$A.createComponent(
                                "c:one_Leave", {
                                },
                                function(newCmp) {
                                    if (component.isValid()) {
                                        var body = component.get("v.body");
                                        body.push(newCmp);
                                        component.set("v.body", body);
                                    }
                                }
                            );*/
                    
                }), 4000
            );
        }
    }), 2000
        );
        
        
        },
    
displayErrors: function(component, event, helper) {
	var leaveVar = component.find("leave").get("v.value");//component.get("v.leaveType");
    var action = component.get("c.getValuesPick");
    
	action.setParams({
            "LeaveReq": component.get("v.LeaveReqs"),
            leaveType:leaveVar 
        });
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
            component.set("v.errorMessage", response.getReturnValue());
                    		
        }
        else {
        }
    });

    $A.enqueueAction(action);
}
})