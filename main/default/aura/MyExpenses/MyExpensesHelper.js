({//helper
    
    doInit: function(cmp, ev) {
       
        var selectCmp = cmp.find("InputSelectDynamic");
        var action = cmp.get("c.GetRecordCounts");
        action.setParams({
            strDate: selectCmp.get("v.value"),
            FiscalYear : cmp.get("v.selectedFY"),
            UserId : cmp.get("v.UserId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('GetRecordCounts Response:', response.getReturnValue());
                cmp.set('v.counts', response.getReturnValue());
                cmp.set("v.approvalProcess",response.getReturnValue().approvalProcess);
                //alert(response.getReturnValue().CustomSetting);
            }
        });
        $A.enqueueAction(action);
    },


    fetchPaidAmount : function(cmp, ev) {
        var selectCmp = cmp.find("InputSelectDynamic");
        var action = cmp.get("c.GetPaidRecordCounts");
        action.setParams({
            strDate: selectCmp.get("v.value"),
            FiscalYear : cmp.get("v.selectedFY")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.counts', response.getReturnValue());
                cmp.set("v.approvalProcess",response.getReturnValue().approvalProcess);
                //alert(response.getReturnValue().CustomSetting);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCurrencyCode: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getCurrencyIsoCode");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currencyCode", component.get("v.currency." + (response.getReturnValue())));
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    Navigate: function(component, event, expId) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        //alert(expId);
        var action = component.get("c.EditExpense");
        action.setParams({
            strId: expId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.TimeSheetObj', response.getReturnValue());
            }
            /*$A.util.addClass(component.find('mainSpin'), "slds-hide");
            $A.createComponent(
                "c:AddExpense", {
                    "isDraftEdit" : true,
                    "Expense": response.getReturnValue().expense,
                    "expli": response.getReturnValue().expenseLine
                },
                function(newCmp, status, errorMessage) {
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                }
            );*/
            //alert(response.getReturnValue().expense);
             var userid= component.get("v.UserId");
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:AddExpense",
                componentAttributes: {
                    "uId" : userid,
                    "isDraftEdit" : true,
                    "EditRecord" : true,
                    "Expense": response.getReturnValue().expense,
                    "expli": response.getReturnValue().expenseLine,
                    "accList": response.getReturnValue().accList,
                    "isEditAll":false,
                }
            });
            evt.fire();
        });
        $A.enqueueAction(action);
    },
    
    NavigateMultiple: function(component, event, selectedRows) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        //alert(expId);
        var action = component.get("c.EditMultiExpense");
        action.setParams({
            ExpIds: selectedRows
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.TimeSheetObjMul', response.getReturnValue());
                console.log("getReturnValue EditMultiExpense", response.getReturnValue());
                console.log("ExpenseexpenseLine", response.getReturnValue()[0].expenses);
                console.log("expwraplist -> ", response.getReturnValue()[0].expwraplist);
                 console.log("expenseLine -> ",  response.getReturnValue()[0].expenseLine);
            }
            /*$A.util.addClass(component.find('mainSpin'), "slds-hide");
            $A.createComponent(
                "c:AddExpense", {
                    "isDraftEdit" : true,
                    "Expense": response.getReturnValue().expense,
                    "expli": response.getReturnValue().expenseLine
                },
                function(newCmp, status, errorMessage) {
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                }
            );*/
            //alert(response.getReturnValue().expense);
             var userid= component.get("v.UserId");
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:AddExpense",
                componentAttributes: {
                    "uId" : userid,
                    "isDraftEdit" : true,
                    "EditRecord" : true,
                    "Expenses": response.getReturnValue()[0].expenses,
                    "expli": response.getReturnValue()[0].expenseLine,
                    "accList": response.getReturnValue()[0].accList,
                    "expWrapList":response.getReturnValue()[0].expwraplist,
                    "header":false,
                    "isEditAll":true,
                    //"": response.getReturnValue().expwraplist
                }
            });
            evt.fire();
        });
        $A.enqueueAction(action);
    },
    
    sortBy: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            table = component.get("v.table");
        sortAsc = field == sortField? !sortAsc: true;
        table.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.table", table);
    },
    
    sortByApproved: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            table2 = component.get("v.table2");
        sortAsc = field == sortField? !sortAsc: true;
        table2.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        }); 
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.table2", table2);
    },
    
    sortByEmp: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            table2 = component.get("v.empExpenses");
        sortAsc = field == sortField? !sortAsc: true;
        table2.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        }); 
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.empExpenses", table2);
    },
    
    tabSelect : function(component,event,secId) {
        var acc = component.find(secId);
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        $A.util.toggleClass(acc, 'slds-show');  
        $A.util.toggleClass(acc, 'slds-hide');  
    },
    
    FieldAccess:function (component, event) {
       
        
           var action=component.get("c.AddExpenseCheckFLS");
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.AddExpenseFLSCheck',response.getReturnValue());
                component.set("v.accessAllExpenses", response.getReturnValue().allExpenseAccess);
                if(component.get("v.TempUserId")!='') {
                   component.set("v.UserId",component.get("v.TempUserId")); 
                }else{
                  component.set("v.UserId", response.getReturnValue().UserId);  
                }
  
            }
            else{
                var errors = response.getError();
                console.log("error -> ", errors);
            }
        });
        $A.enqueueAction(action); 
        
        
    }
    
})