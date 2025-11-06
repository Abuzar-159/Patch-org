({//MyExpensescontroller
     toggleTabs : function(component, event, helper){
        var tab = event.currentTarget.dataset.tab;
        if(tab != component.get("v.Tab")) component.set("v.Tab", tab);
         if(tab == 'tab4'){
             helper.fetchPaidAmount(component, event);
         }else{
             helper.doInit(component, event);
         }
    },
    
    toggleViews : function(component, event){
        var view = event.currentTarget.dataset.tab;
        if(view != component.get("v.View")) component.set("v.View", view);
    },
    
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
        helper.fetchCurrencyCode(component, event, helper);
        helper.FieldAccess(component, event);
        /*
            if(component.get("v.ftctrl")==true){
                var tab1 = component.find("articleOne").getElement();
                //                $A.util.addClass(tab1,'slds-show');
                $A.util.removeClass(tab1,'slds-hide');
                component.set("v.ftctrl",false);
            }
        */
    },
    
    display : function(component, event, helper) { //displays all expenses of current user.
        helper.doInit(component, event);
        var uid= component.get("v.UserId");
        console.log('custom Id : ', uid);
        var actionNew = component.get("c.getSheet");
        actionNew.setParams({
            FiscalYear : component.get("v.selectedFY"),
            UserId : component.get("v.UserId")
        });
        actionNew.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.ExpenseListWP", response.getReturnValue());
                var eXwrap = component.get("v.ExpenseListWP");
                var EXlist = [];
                for(var i in eXwrap){
                    EXlist.push(eXwrap[i].Expense1);
                }
                component.set("v.table", EXlist);
            }
        });
        $A.enqueueAction(actionNew);
    },
    
    displayRefund : function(component, event, helper) { //displays all expenses of current user.
        helper.doInit(component, event);
        var actionNew = component.get("c.getSheetRefund");
        actionNew.setParams({
            FiscalYear : component.get("v.selectedFY"),
            UserId : component.get("v.UserId")
        });
        actionNew.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.ExpenseListWP", response.getReturnValue());
                var eXwrap = component.get("v.ExpenseListWP");
                var EXlist = [];
                for(var i in eXwrap){
                    EXlist.push(eXwrap[i].Expense1);
                }
                component.set("v.table4", EXlist);
            }
        });
        $A.enqueueAction(actionNew);
    },
    
    
    displayApproved : function(component, event, helper) {
        var actionNew = component.get("c.getSheetApproved");
        actionNew.setParams({
            FiscalYear : component.get("v.selectedFY")
        });
        actionNew.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.ApprovedExpenseListWP", response.getReturnValue());
                var eXwrap = component.get("v.ApprovedExpenseListWP");
                var EXlist = [];
                for(var i in eXwrap){
                    EXlist.push(eXwrap[i].Expense1);
                }
                component.set("v.table2", EXlist);
            }
        });
        $A.enqueueAction(actionNew);
    },
    
    /*getExpenseDetailsApproved: function(component) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getApprovedExpenses");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.table2", response.getReturnValue());
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },*/
    
    doesInit: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getEmployeeDetails"); // method in the apex class
        action.setCallback(this, function(a) {
            component.set("v.EmpDetails", a.getReturnValue()); 
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    //to delete Expenses
    handleDelClick : function(component, event, helper) {
        var self = this; // safe reference
        var result = confirm("Are You Sure");
        if (result) {
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
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
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            });
            // Enqueue the action
            $A.enqueueAction(deleteAction);
            return true;
        } else {
            return false;
        }
    },
   handleChange:function(component,event,helper){

    var isSelect = event.getSource().get("v.checked");
    var elem=[]; elem=component.find('expId');
    
    var SelectedSoliList=[];
    var SoliList =[]; SoliList=component.get("v.table"); 
    
    
    var SelectedSoliListDum=[];
    
    if(SoliList.length > 0){
        for(var j=0; j<SoliList.length; j++){ 
           if(isSelect==true){ 
               component.set("v.allselected", true);
               if(SoliList[j].Id){
                   if(elem){
                       if(elem.length){
                           elem[j].set("v.checked",true);        
                       }else elem.set("v.checked",true);        
                   }
                                                                     
                   SelectedSoliListDum.push(SoliList[j].Id); 
               }          
           }   
           else{
                component.set("v.allselected", false);
               if(elem){
                       if(elem.length){
                           elem[j].set("v.checked",false);        
                       }else elem.set("v.checked",false);        
                   }
               SelectedSoliListDum=[];
           }
       }
        component.set("v.selectedRows", SelectedSoliListDum);
        let tempindex = [];
        for(var i in SelectedSoliListDum){
            tempindex[i] = i; 
        }
       component.set("v.RowIndex",tempindex );
       console.log("RowIndex", component.get("v.RowIndex"));
        console.log("selectedRows", component.get("v.selectedRows"));
        console.log("SelectedSoliListDum",SelectedSoliListDum);
   }
},
    
    handleDelMainClick : function(component, event, helper){
         var selectedRows = component.get("v.selectedRows");
        if(selectedRows.length === 0){
            console.log("Empty");
            alert("Select Expenses to Delete.");
        }else{
              var self = this; // safe reference
        var result = confirm("Are You Sure");
            if (result) {
                $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                var items = component.get("v.table");
                var ind = component.get("v.RowIndex");
                var allselected = component.get("v.allselected");
                //allselected
                if(allselected){
                for(var i = 0; i < ind.length; i++){
                    items.splice(ind[i], ind.length); 
                    component.set("v.table", items);
                }
                }
                else{
                    for(var i = 0; i < ind.length; i++){
                    items.splice(ind[i], ind.length-1); 
                    component.set("v.table", items);
                } 
                }
                     console.log("before calling Function");
                    var deleteAction = component.get("c.deleteMultiExpense");
                    console.log("before setting success");
                    deleteAction.setParams({
                        "StrId": selectedRows
                    });
                    deleteAction.setCallback(self, function(a) {
                        var state = a.getState();
            			if (state === "SUCCESS") {
                            console.log("inside success");
                        //var recordId = a.getReturnValue();
                       // if (recordId == null) {
                       // } else {
                            
                        //} 
                    }
                   $A.util.addClass(component.find('mainSpin'), "slds-hide");
                });
    
            $A.enqueueAction(deleteAction);
            return true;
        } 
            else {
           return false;
        }
            
        
        }
    },
    
    handleCheckboxChange: function(component, event, helper){
        var selectedRows = component.get("v.selectedRows");
        var indexRows = component.get("v.RowIndex");
        var isSelect = event.getSource().get("v.checked");
        var expindex=  event.getSource().get("v.title");
        console.log("isSelected??", isSelect);
        console.log("expindex??", expindex);
 		var recordId = event.getSource().get("v.value");
		 console.log("recordId??", recordId);
        if (isSelect) {
            selectedRows.push(recordId);
            indexRows.push(expindex);
            console.log("selected rows", selectedRows);
            console.log("selected rows recId", recordId);
			console.log("selected indexes", indexRows);            
        } else {
            var index = -1;
            for (var i = 0; i < selectedRows.length; i++) {
                if (selectedRows[i] === recordId) {
                    index = i;
                    break;
                }
            }
            for (var i = 0; i < indexRows.length; i++) {
             if (indexRows[i] === expindex) {
                    index = i;
                    break;
                }
            }
            
            if (index > -1) {
                selectedRows.splice(index, 1);
                indexRows.splice(index, 1);
                console.log("after unselected rows", selectedRows);
                console.log("indexes after unselected rows", indexRows);
            }
        }
	
  component.set("v.selectedRows", selectedRows); 
        component.set("v.RowIndex", indexRows);
    },
    
    EditMainClick: function(component, event, helper){
         var selectedRows = component.get("v.selectedRows");
        if(selectedRows.length === 0){
            console.log("Empty");
            alert("Select Expenses to Edit.");
        }else{
             helper.NavigateMultiple(component, event, selectedRows);
            
        }
    },
    //to edit Expenses
    EditClick: function(component, event, helper) {
       // $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var ExpenseId = event.currentTarget.dataset.record;
        helper.Navigate(component, event, ExpenseId);
       // $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    
    selectFY : function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        $A.enqueueAction(component.get("c.display"));
        $A.enqueueAction(component.get("c.displayApproved"));
        helper.doInit(component, event);
    },
    
    CreateExpense: function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var userid= component.get("v.UserId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AddExpense",
            componentAttributes: {
                "uId" : userid
            }
        });
        evt.fire();
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    handleExpenseDelete: function(component, event, helper) {
        var items = component.get("v.table");
        items.splice(event.getParam("listIndex"), 1);
        component.set("v.table", items);
    },
    
    sortByName: function(component, event, helper) {
        component.set("v.tabSort", "S");
        helper.sortBy(component, "Name");
    },
    
    sortByProject: function(component, event, helper) {
        component.set("v.tabSort", "S");
        helper.sortBy(component, "ERP7__Project__r.Name");
    },
    
    sortByAmount: function(component, event, helper) {
        component.set("v.tabSort", "S");
        helper.sortBy(component, "ERP7__Amount_Submitted__c");
    },
    
    sortByVat: function(component, event, helper) {
        component.set("v.tabSort", "S");
        helper.sortBy(component, "ERP7__VAT_Amount__c");
    },
    
    sortByClaimed: function(component, event, helper) {
        component.set("v.tabSort", "S");
        helper.sortBy(component, "ERP7__Amount__c");
    },
    
    sortByDate: function(component, event, helper) {
        component.set("v.tabSort", "S");
        helper.sortBy(component, "ERP7__Date__c");
    },
    
    sortByNameApproved: function(component, event, helper) {
        component.set("v.tabSort", "A");
        helper.sortByApproved(component, "Name");
    },
    
    sortByProjectApproved: function(component, event, helper) {
        component.set("v.tabSort", "A");
        helper.sortByApproved(component, "Project__r.Name");
    },
    
    sortByAmountApproved: function(component, event, helper) {
        component.set("v.tabSort", "A");
        helper.sortByApproved(component, "ERP7__Amount_Submitted__c");
    },
    
    sortByVatApproved: function(component, event, helper) {
        component.set("v.tabSort", "A");
        helper.sortByApproved(component, "ERP7__VAT_Amount__c");
    },
    
    sortByClaimedApproved: function(component, event, helper) {
        component.set("v.tabSort", "A");
        helper.sortByApproved(component, "ERP7__Amount__c");
    }, 
    
    sortByDateApproved: function(component, event, helper) {
        component.set("v.tabSort", "A");
        helper.sortByApproved(component, "ERP7__Date__c");
    },
    
    sortByNameEmp : function(component, event, helper) {
        component.set("v.tabSort", "E");
        helper.sortByEmp(component, "Name");
    },
    
    sortByEmpNameEmp : function(component, event, helper) {
        component.set("v.tabSort", "E");
        helper.sortByEmp(component, "ERP7__Employee__r.ERP7__First_Name__c");
    },
    
    sortByProjectEmp : function(component, event, helper) {
        component.set("v.tabSort", "E");
        helper.sortByEmp(component, "ERP7__Project__r.Name");
    },
    
    sortBySubmittedEmp : function(component, event, helper) {
        component.set("v.tabSort", "E");
        helper.sortByEmp(component, "ERP7__Amount_Submitted__c");
    },
    
    sortByVatEmp : function(component, event, helper) {
        component.set("v.tabSort", "E");
        helper.sortByEmp(component, "ERP7__VAT_Amount__c");
    },
    
    sortByClaimedEmp : function(component, event, helper) {
        component.set("v.tabSort", "E");
        helper.sortByEmp(component, "ERP7__Amount__c");
    }, 
    
    sortByDateEmp : function(component, event, helper) {
        component.set("v.tabSort", "E");
        helper.sortByEmp(component, "ERP7__Date__c");
    },
    
    expenseManager : function(component, event, helper){
        var operation = event.getParam("value");
        if(operation == "Edit"){
            helper.Navigate(component, event, event.getSource().get("v.value"));
        }
        else if(operation == "Delete"){
            if (confirm("Are you sure ?")) {
                var deleteAction = component.get("c.deleteExpense");
                deleteAction.setParams({
                    "recordId": event.getSource().get("v.value")
                });
                deleteAction.setCallback(this, function(response) {
                    if (response.getReturnValue() != null) {
                        var deleteEvent = component.getEvent("delete");
                        deleteEvent.setParams({
                            "listIndex": event.getSource().get("v.name"),
                            "oldRecord": component.get("v.table")[event.getSource().get("v.name")]
                        }).fire();
                    }
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                });
                // Enqueue the action
                $A.enqueueAction(deleteAction);
                return true;
            }
        }
    },
    
    EMPleaveManager : function(component, event, helper){
        var operation = event.getParam("value");
        if(operation == "Approve"){
            component.set("v.empExpenseId", event.getSource().get("v.value"));
            component.set("v.empARIndex", event.getSource().get("v.name"));
            $A.util.addClass(component.find("approveExpenseModal"), 'slds-fade-in-open');
            $A.util.addClass(component.find("newExpenseModalBackdrop"), 'slds-backdrop_open');
        }
        else if(operation == "Reject"){
            component.set("v.empExpenseId", event.getSource().get("v.value"));
            component.set("v.empARIndex", event.getSource().get("v.name"));
            $A.util.addClass(component.find("rejectExpenseModal"), 'slds-fade-in-open');
            $A.util.addClass(component.find("newExpenseModalBackdrop"), 'slds-backdrop_open');
        }
    },
    
    getExpDetailsEmp : function(component, event, helper) {
        var actionNew = component.get("c.getApproval");
        actionNew.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.EmpExpenseListWP", response.getReturnValue());
                var eXwrap = component.get("v.EmpExpenseListWP");
                var EXlist = [];
                for(var i in eXwrap){
                    EXlist.push(eXwrap[i].Expense1);
                }
                component.set("v.empExpenses", EXlist);
            }
        });
        $A.enqueueAction(actionNew);
    },
    
    openApproveModal : function(component, event, helper){
        component.set("v.empExpenseId", event.currentTarget.dataset.recordId);
        component.set("v.empARIndex", event.currentTarget.dataset.index);
        $A.util.addClass(component.find("approveExpenseModal"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newExpenseModalBackdrop"), 'slds-backdrop_open');
    },
    
    closeApproveModal1 : function(component, event, helper){
        component.set("v.empExpenseId", "");
        component.set("v.empARIndex", 0);
        component.set("v.A_Rcomment", "");
        $A.util.removeClass(component.find("approveExpenseModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newExpenseModalBackdrop"), 'slds-backdrop_open');
    },
    
    openRejectModal : function(component, event, helper){
        component.set("v.empExpenseId", event.currentTarget.dataset.recordId);
        component.set("v.empARIndex", event.currentTarget.dataset.index);
        $A.util.addClass(component.find("rejectExpenseModal"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newExpenseModalBackdrop"), 'slds-backdrop_open');
    },
    
    closeRejectModal : function(component, event, helper){
        component.set("v.empExpenseId", "");
        component.set("v.empARIndex", 0);
        component.set("v.A_Rcomment", "");
        $A.util.removeClass(component.find("rejectExpenseModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newExpenseModalBackdrop"), 'slds-backdrop_open');
    },
    
    Approve : function(component, event, helper) {
        var action = component.get("c.saveApprovedExpense");
        action.setParams({
            reason: component.get("v.A_Rcomment"),
            tid   : component.get("v.empExpenseId"),
            sts: "Approved"
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                $A.util.removeClass(component.find("approveExpenseModal"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newExpenseModalBackdrop"), 'slds-backdrop_open');
                $A.enqueueAction(component.get("c.getExpDetailsEmp"));
                $A.enqueueAction(component.get("c.closeApproveModal"));
                component.set("v.serverSuccess", "Expense Approved.");
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.serverSuccess","");                      
                    }), 5000
                );

            }
        });
        $A.enqueueAction(action);
    },
    
    Reject : function(component, event, helper) {
        var action = component.get("c.saveApprovedExpense");
        action.setParams({
            reason: component.get("v.A_Rcomment"),
            tid   : component.get("v.empExpenseId"),
            sts   : "Rejected"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                $A.enqueueAction(component.get("c.getExpDetailsEmp"));
                $A.enqueueAction(component.get("c.closeRejectModal"));
                component.set("v.serverSuccess", "Expense Rejected.");
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.serverSuccess","");                      
                    }), 5000
                );

            }
        });
        $A.enqueueAction(action);
    },
    
    handlesubmitforApproval : function(component, event, helper) {
        var recId = event.currentTarget.getAttribute("data-recordId");
        console.log('openApprovedRejectedModel record Id:',recId);
        component.set("v.CurrentExpId",recId);
        
        $A.util.addClass(component.find("approveModal"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        
    },
    
    closeApproveModal : function(component, event, helper){
        component.set("v.A_Rcomment", "");
        $A.util.removeClass(component.find("approveModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
    },
    
    submitExp : function(component, event, helper){
        console.log('Inside submitExp:');
        try{
            var action = component.get("c.SendApprovedExpense");
            action.setParams({
                reason: component.get("v.A_Rcomment"),
                recId   : component.get("v.CurrentExpId"),
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var error = response.getReturnValue();
                    if (error == null) {
                        console.log('Submitted for Approval:');
                        const toastEvent = $A.get("e.force:showToast");
                        
                        toastEvent.setParams({
                            title: 'success',
                            message: 'Submitted for Approval Successfully.',
                            duration: '4000',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    
                }
            });
            $A.enqueueAction(action);
            
            component.set("v.A_Rcomment", "");
            $A.util.removeClass(component.find("approveModal"), 'slds-fade-in-open');
            $A.util.removeClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        }
        catch(e){console.log('Error in submitExp:',e);}
    },
    
    submitforApprovalMainClick : function(component, event, helper){
        try{
            var selectedRows = component.get("v.selectedRows");
            if(selectedRows.length === 0){
                console.log("Empty");
                alert("Select Expenses to Submit for Aprroval.");
            }
            else{
                var action = component.get("c.SendApprovedExpense");
                action.setParams({
                    "StrId": selectedRows
                });
                
                action.setCallback(self, function(a) {
                    var state = a.getState();
                    if (state === "SUCCESS") {
                        var error = response.getReturnValue();
                        if (error == null) {
                            console.log('Submitted for Approval:');
                            const toastEvent = $A.get("e.force:showToast");
                            
                            toastEvent.setParams({
                                title: 'success',
                                message: 'Leave Approved Successfully.',
                                duration: '4000',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    }
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                });
                
                $A.enqueueAction(action);
                
            }
        }
        catch(e){console.log('Error in submitforApprovalMainClick:',e);}
    },
    
})