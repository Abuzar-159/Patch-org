({
    doInit: function(component, event, helper) {
        console.log('add time sheets');
        try {
        if(component.get("v.AccId")!='') component.set("v.timeSheet.ERP7__Vendor_Account__c",component.get("v.AccId"));
      
        helper.Navigate(component, event, helper);
        var action = component.get("c.getEmployees");
        action.setCallback(this, function(a) {
            component.set("v.emp", a.getReturnValue());
            var appro = component.get("v.timeSheet.ERP7__Approver__c");
            if(appro == '' || appro == null) component.set("v.timeSheet.ERP7__Approver__c", component.get("v.emp.ERP7__Employee_User__r.ManagerId"));// ERP7__Employee_User__r.Manager.FirstName
        });
        $A.enqueueAction(action);
    } catch (error) {
            console.log('err doinit '+JSON.stringify(error));
    }
    },
    Navigate: function(component, event, helper) {
        var week_int = component.get("v.weekint");
        $A.createComponent(
            "c:AddTimeCardEntry", {
                "tSheetcomp": component.get("v.timeSheet"),
                "intweek": week_int.toString()
            },
            function(newCmp) {
                if (component.isValid()) {
                    week_int = parseInt(week_int) + 7;
                    component.set("v.weekint", week_int);
                    var bodycmp = component.find("TimeCEContent");
                    var body = bodycmp.get("v.body");
                    body.reverse();
                    body[body.length] = newCmp;
                    body.reverse();
                    bodycmp.set("v.body", body);
                }
            }
        );
    },
    savetSheet: function(component, event, helper) {
        component.set("v.timeSheet.ERP7__Organisation__c", component.get("v.emp.ERP7__Organisation__c"));
        component.set("v.timeSheet.ERP7__Organisation_Business_Unit__c", component.get("v.emp.ERP7__Organisation_Business_Unit__c"));
        component.set("v.timeSheet.ERP7__Employees__c", component.get("v.emp.Id"));
       
        var action = component.get("c.saveTimesheet");
        action.setParams({
            tSheet: component.get("v.timeSheet"),
            AccId: component.get("v.AccId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var timesheetRef = response.getReturnValue();
              
                var sEvent = $A.get("e.c:saveEvent");
                sEvent.setParams({
                    "tSheetId": timesheetRef['Id'],
                    "orgId": timesheetRef['ERP7__Organisation__c'],
                    "buId": timesheetRef['ERP7__Organisation_Business_Unit__c'],
                    "tCardEntry": component.get("v.tceObj")
                });
                sEvent.fire();
                /*var toggleText = component.find("reload");
                    $A.util.toggleClass(toggleText, "slds-hide");*/
                 
                    //component.set("v.serverSuccess","Time Sheet Created");
                    if(component.get("v.EditRecord")) helper.showToast('Success!','success','Time Sheet Updated Successfully');
                    else helper.showToast('Success!','success','Time Sheet Created Successfully');
                setTimeout(
                    $A.getCallback(function() {
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:Timesheets",
                            componentAttributes: {
                                //contactId : component.get("v.contact.Id")
                            }
                        });
                        evt.fire();
                    }), 3000
                );
                    /**/
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
    },
    Cancel: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Timesheets",
            componentAttributes: {
                //contactId : component.get("v.contact.Id")
            }
        });
        evt.fire();
    },
    
    getStatus:function(component, event, helper) {
        var evt = component.getEvent("validationError");
        var status = component.find("status").get("v.value");
        evt.setParams({
            "statusSheet": status
        });
        evt.fire();
    }
})