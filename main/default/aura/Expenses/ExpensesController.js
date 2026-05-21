({
    Accordion: function(component, event, helper) {
        var acid = $(component.find("accordion").getElement()).accordion({
            active: 0,
            heightStyle: "content"
        });
    },
    doesInit: function(component, event, helper) {
        var action = component.get("c.getEmployeeDetails"); // method in the apex class
        action.setCallback(this, function(a) {
            component.set("v.EmpDetails", a.getReturnValue()); // variable in the component
        });
        $A.enqueueAction(action);
    },
    getExpenseDetails: function(cmp) {
        var action = cmp.get("c.getExpenses");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.table", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getExpenseDetailsApproved: function(cmp) {
        var action = cmp.get("c.getApprovedExpenses");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.table2", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    //to delete Expenses
    handleDelClick: function(component, event, helper) {
        var self = this; // safe reference
        var result = confirm("Are You Sure");
        if (result) {
            var deleteAction = component.get("c.deleteExpense");
            deleteAction.setParams({
                "recordId": event.target.dataset.recordId
            });
            deleteAction.setCallback(self, function(a) {
                var recordId = a.getReturnValue();
                if (recordId == null) {
                } else {
                    var deleteEvent = component.getEvent("delete");
                    deleteEvent.setParams({
                        "listIndex": event.target.dataset.index,
                        "oldRecord": component.get("v.table")[event.target.dataset.index]
                    }).fire();
                }
            });
            // Enqueue the action
            $A.enqueueAction(deleteAction);
            return true;
        } else {
            return false;
        }
    },
    handleExpenseDelete: function(component, event, helper) {
        var items = component.get("v.table");
        items.splice(event.getParam("listIndex"), 1);
        component.set("v.table", items);
    },
    EditClick: function(component, event, helper) {
        var createRecordEvent = $A.get("e.c:editTimesheetEvent");
        createRecordEvent.setParams({
            "timId": event.target.dataset.record
        });
        createRecordEvent.fire();
    },
    onChange: function(component, event, helper) {
        var selectCmp = component.find("InputSelectDynamic");
        var action = component.get("c.getExpenses");
        action.setParams({
            strDate: selectCmp.get("v.value"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.table', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        //table 2
        var selectCmp2 = component.find("InputSelectDynamic");
        var action2 = component.get("c.getApprovedExpenses");
        action2.setParams({
            strDate: selectCmp2.get("v.value"),
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.table2', response.getReturnValue());
            }
        });
        $A.enqueueAction(action2);
        helper.doInit(component, event);
    },
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
        helper.fetchCurrencyCode(component, event, helper);
        setTimeout(
            $A.getCallback(function() {
                if(component.get("v.ftctrl")==true){
                    
                    var tab1 = component.find("articleOne").getElement();
                    $A.util.addClass(tab1,'slds-show');
                    $A.util.removeClass(tab1,'slds-hide');
                    component.set("v.ftctrl",false);
                }
            }), 1000
        );
    },
    display: function(component, event, helper) {
        var action = component.get("c.getSheet");
        action.setCallback(this, function(a) {
            component.set("v.table", a.getReturnValue());
            component.set("v.sortAsc", true);
            helper.sortBy(component, "Name");
        });
        $A.enqueueAction(action);
    },
    sortByName: function(component, event, helper) {
        helper.sortBy(component, "Name");
    },
    sortByProject: function(component, event, helper) {
        helper.sortBy(component, "Project__r.Name");
    },
    sortByAmount: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Amount_Submitted__c");
    },
    sortByVat: function(component, event, helper) {
        helper.sortBy(component, "ERP7__VAT_Amount__c");
    },
    sortByClaimed: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Amount__c");
    },
    sortByDate: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Date__c");
    },
    sortByStatus: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Status__c");
    },
    displayApproved: function(component, event, helper) {
        var action = component.get("c.getSheetApproved");
        action.setCallback(this, function(a) {
            component.set("v.table2", a.getReturnValue());
            component.set("v.sortAsc", true);
            helper.sortByApproved(component, "Name");
        });
        $A.enqueueAction(action);
    },
    sortByNameApproved: function(component, event, helper) {
        helper.sortByApproved(component, "Name");
    },
    sortByProjectApproved: function(component, event, helper) {
        helper.sortByApproved(component, "Project__r.Name");
    },
    sortByAmountApproved: function(component, event, helper) {
        helper.sortByApproved(component, "ERP7__Amount_Submitted__c");
    },
    sortByVatApproved: function(component, event, helper) {
        helper.sortByApproved(component, "ERP7__VAT_Amount__c");
    },
    sortByClaimedApproved: function(component, event, helper) {
        helper.sortByApproved(component, "ERP7__Amount__c");
    },
    sortByDateApproved: function(component, event, helper) {
        helper.sortByApproved(component, "ERP7__Date__c");
    },
    sortByStatusApproved: function(component, event, helper) {
        helper.sortByApproved(component, "ERP7__Status__c");
    },
    CreateExpense: function(component, event, helper) {
        var btn = component.find("sldshide");
        $A.util.toggleClass(btn, "slds-hide");
        $A.createComponent(
            "c:AddExpense", {
            },
            function(newCmp) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);
                }
            }
        );
    },
    testToggle: function(component, event, helper) {
        var btn = component.find("sldshide");
        $A.util.toggleClass(btn, "slds-hide");
        helper.Navigate(component, event, helper);
    },
    
    ToggleCollapse : function(component, event, helper) {
        	
        		var ti = event.target;        
        		var tab1 = component.find("com1").getElement();
                var tab2 = component.find("com2").getElement();
                var tab3 = component.find("com3").getElement();
                
        if(ti != undefined){
            var tabIndex = ti.dataset.record;
        		
                $A.util.addClass(tab1,'slds-hide');
                $A.util.addClass(tab2,'slds-hide');
                $A.util.addClass(tab3,'slds-hide');
               
        if(tabIndex=='1'){
            $A.util.removeClass(tab3,'slds-show');
            $A.util.removeClass(tab2,'slds-show');
            $A.util.toggleClass(tab1,'slds-show');
        }
        else if(tabIndex=='2') {
            $A.util.removeClass(tab3,'slds-show');
            $A.util.toggleClass(tab2,'slds-show');
            $A.util.removeClass(tab1,'slds-show');
        }    
        else if(tabIndex=='3'){
              $A.util.toggleClass(tab3,'slds-show');
            $A.util.removeClass(tab2,'slds-show');
            $A.util.removeClass(tab1,'slds-show');
        } 
                
        
        }
   },
    
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    
   sectionTwo : function(component, event, helper) {
      helper.helperFun(component,event,'articleTwo');
    },
   
   sectionThree : function(component, event, helper) {
      helper.helperFun(component,event,'articleThree');
   }
})