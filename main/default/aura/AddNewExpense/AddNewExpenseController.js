({
    doInit: function(component, event, helper) {
        
        var action = component.get("c.getEmployees");
        action.setCallback(this, function(a) {
            component.set("v.emp", a.getReturnValue());
            component.set("v.Expense.ERP7__Approver__c",component.get("v.emp.ERP7__Employee_User__r.ManagerId"));
        });
        $A.enqueueAction(action);
    },
    
    Navigate: function(component, event, helper) {
        $A.createComponent(
            "c:Expense_Line_Item", {
                "expenseComp": component.get("Expense"),
            },
            function(newCmp) {
                if (component.isValid()) {
                    /*var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);*/
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
    cancelClick: function(component, event, helper) {
        location.reload();
    },
    saveExpenseSheet: function(component, event, helper) {
        
        var nameVal = component.find("name");
        var expName = nameVal.get("v.value");
        if (!expName) {
            nameVal.set("v.errors", [{
                message: "Enter Expense Sheet Title"
            }]);
        } else {
            nameVal.set("v.errors", null);
            
            component.set("v.Expense.ERP7__Account__c", component.get("v.emp.ERP7__Organisation__c"));
            component.set("v.Expense.ERP7__Organisation_Business_Unit__c", component.get("v.emp.ERP7__Organisation_Business_Unit__c"));
            component.set("v.Expense.ERP7__Employees__c", component.get("v.emp.Id"));
             var action = component.get("c.saveExpense");
             action.setParams({
                exp: component.get("v.Expense")
             });
             action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var expsheetRef = response.getReturnValue();
                    
                    var sEvent = $A.get("e.c:saveEvent");
                    
                    sEvent.setParams({
                        "expenseName": expsheetRef['Id'],
                        "orgId": expsheetRef['ERP7__Account__c'],
                        "buId": expsheetRef['ERP7__Organisation_Business_Unit__c'],
                        "expenseType": expsheetRef['ERP7__Expense_Type__c'],
                        "eLineItemName": expsheetRef['Name'],
                        "expenseDate": expsheetRef['ERP7__Expense_Date__c'],
                        "AmountSubmitted": expsheetRef['ERP7__Expensed_Submitted__c'],
                        "eLineEntry": component.get("v.eLineItem")
                    });
                    sEvent.fire();
                    
                } else if (state === "ERROR") {
                   
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +errors[0].message + errors);
                        }
                    } else {
                        console.log("Unknown error" + errors);
                    }
                }
            });
            $A.enqueueAction(action);
            //location.reload();
        }   
    }
})