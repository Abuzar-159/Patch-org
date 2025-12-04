({
    setLeaveTypes : function(component, event, helper){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getLeaveTypes");
        var opts = [];
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    opts.push({
                        "class": "optionClass",
                        label: response.getReturnValue()[i],
                        value: response.getReturnValue()[i]
                    });
                }
                component.set("v.leaveTypes", opts);
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );


                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    doInit: function(component, event, helper) {
        $A.util.addClass(component.find("Admin-View"), 'slds-hidden');
       	$A.util.addClass(component.find("Employee-View"), 'slds-hidden');
        var today = new Date();
        var fiscalYear= today.getFullYear();
        component.set('v.currentFiscalYear', fiscalYear.toString());
        helper.getEmployee(component, event);
        helper.doInit2(component, event);
    },
    
    handlePrevButtonClick: function(component, event, helper) {
        var currentFiscalYearStr = component.get('v.currentFiscalYear');
        var currentFiscalYear = parseInt(currentFiscalYearStr);
        currentFiscalYear -= 1;
        component.set('v.currentFiscalYear', currentFiscalYear.toString());
        //component.set('v.currentFiscalYear', component.get('v.currentFiscalYear')-1);
    },
    handleNextButtonClick: function(component, event, helper) {
        var currentFiscalYearStr = component.get('v.currentFiscalYear');
        var currentFiscalYear = parseInt(currentFiscalYearStr);
        currentFiscalYear += 1;
        component.set('v.currentFiscalYear', currentFiscalYear.toString());
        //component.set('v.currentFiscalYear', component.get('v.currentFiscalYear')-1);
    },
    
    EditClick: function(component, event, helper) {
        component.set("v.newTimeOff",{ sobjectType : 'ERP7__Leave_Request__c'});
        component.set("v.isEdit", true);
        component.set("v.editIndex",event.currentTarget.dataset.index);
        var LeaveReq = component.get("v.table");
        component.set("v.newTimeOff", LeaveReq[event.currentTarget.dataset.index]);
        component.set("v.resetLookups", false);
        component.set("v.resetLookups", true);
        $A.enqueueAction(component.get("c.openTimeOffModal"));
    },
    
    handleAccountDelete: function(component, event, helper) {
        var items = component.get("v.table");
        items.splice(event.getParam("listIndex"), 1);
        component.set("v.table", items);
    },
    
    handleDelClick: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var deleteAction = component.get("c.deleteLeave");
        deleteAction.setParams({
            "recordId": event.target.dataset.recordId
        });
        deleteAction.setCallback(this, function(reponse) {
            if(response.getState() === "SUCCESS"){
                var recordId = response.getReturnValue();
                if (recordId == null) {
                    alert("See Apex Debug Log");
                } else {
                    var deleteEvent = component.getEvent("delete");
                    deleteEvent.setParams({
                        "listIndex": event.target.dataset.index,
                        "oldRecord": component.get("v.table")[event.target.dataset.index]
                    }).fire();
                }
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        // Enqueue the action
        $A.enqueueAction(deleteAction);
    },
    
    onChange: function(component, event, helper) {
        if(component.get("v.selectedFY") == ""){
            $A.enqueueAction(component.get("c.display"));
            $A.enqueueAction(component.get("c.displayApproved"));
            $A.enqueueAction(component.get("c.getHolidays"));
            $A.enqueueAction(component.get("c.getValues"));
            helper.doInit(component, event);
        }
        else{
            helper.FYchange(component, event);
        }
    },
    
    getHolidays: function(component, event, helper){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getEntitlementsHolidaysDefault");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.Holidays", response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    getValues: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getEntmeDefault");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.EmpEnt", response.getReturnValue());
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    display: function(component, event, helper) {
        try{
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getDefault");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.table", response.getReturnValue());
                var tables = component.get("v.table");
                if(tables.length > 0) component.set("v.currentEmployee", tables[0].ERP7__Employee__r.ERP7__Employee_User__c)
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
        }catch(e){alert(e);}
    },
    
    sortByName: function(component, event, helper) {
        helper.sortBy(component, "Name");
    },
    
    sortByDate: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Leave_Start_Date__c");
    },
    
    sortByEndDate: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Leave_End_Date__c");
    },
    
    sortByNumber: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Number_of_Days__c");
    },
    
    sortByType: function(component, event, helper) {
        helper.sortBy(component, "ERP7__Leave_Type__c");
    },
    
    sortByLeaveTypes:function(component, event, helper){
        component.set("v.EorH","E");
        helper.sortByLeaveType(component, "Name");
    },
    
    sortByHolidays: function(component, event, helper){
        component.set("v.EorH","H");
        helper.sortByHoliday(component, "Name");
    },
    	
    sortByNameApproved: function(component, event, helper) {
        component.set("v.EorH","A");
        helper.sortByApproved(component, "Name");
    },
    Approved: function(component, event, helper) {
        try{
            //var approvalValue = event.target.getAttribute('data-value');
            var approvalValue = event.currentTarget.getAttribute("data-attribute");
            console.log('approvalValue',approvalValue);
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action = component.get("c.getApproved");
            action.setParams({
                status: approvalValue,
                currentFiscalYear: component.get("v.currentFiscalYear")
            });
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS"){
                    component.set("v.Records", response.getReturnValue());
                    if(approvalValue==='Approved'){
                        component.set("v.ApprovedRec", response.getReturnValue());
                    }else{
                        component.set("v.RejectedRec", response.getReturnValue());
                    }
                    
                    console.log('approvalValue',response.getReturnValue());
                }
                else{
                    var errors = response.getError();
                    console.log("err -> ", errors);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.exceptionError",errors[0].message);
                            setTimeout(
                                $A.getCallback(function() {
                                    component.set("v.exceptionError","");
                                }), 5000
                            );
                            
                        }
                        else if(errors[0].pageErrors[0].message){
                            component.set("v.exceptionError", errors[0].pageErrors[0].message);
                            setTimeout(
                                $A.getCallback(function() {
                                    component.set("v.exceptionError","");
                                }), 5000
                            );
                            
                        }
                    }
                    else{
                        component.set("v.exceptionError","Unknown error");
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );
                        
                    }
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
            
        }
        catch(e){
            console.log('Exception in GetApproved:',e);
        }
    },
    DraftSubmit: function(component, event, helper) {
        try{
            //var approvalValue = event.target.getAttribute('data-value');
            //var approvalValue = event.currentTarget.getAttribute("data-attribute");
            //console.log('approvalValue',approvalValue);
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action = component.get("c.getDraftSubmitted");
            action.setParams({
                currentFiscalYear: component.get("v.currentFiscalYear")
            });
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS"){
                    component.set("v.Records", response.getReturnValue());
                    component.set("v.SubmittedRec", response.getReturnValue());
                    console.log('approvalValue',response.getReturnValue());
                }
                else{
                    var errors = response.getError();
                    console.log("err -> ", errors);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.exceptionError",errors[0].message);
                            setTimeout(
                                $A.getCallback(function() {
                                    component.set("v.exceptionError","");
                                }), 5000
                            );
                            
                        }
                        else if(errors[0].pageErrors[0].message){
                            component.set("v.exceptionError", errors[0].pageErrors[0].message);
                            setTimeout(
                                $A.getCallback(function() {
                                    component.set("v.exceptionError","");
                                }), 5000
                            );
                            
                        }
                    }
                    else{
                        component.set("v.exceptionError","Unknown error");
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );
                        
                    }
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
            
        }
        catch(e){
            console.log('Exception in GetApproved:',e);
        }
    },
    ChangeActive : function(component, event, helper) {
        var approvalValue = event.currentTarget.getAttribute("data-attribute");
        if(approvalValue == 'draft'){
            component.set("v.DraftActive",'active-page');
            component.set("v.ApprovedActive",'');
            component.set("v.RejectedActive",'');
            component.set("v.EntitleActive",'');
        }
        if(approvalValue == 'Approved'){
            component.set("v.DraftActive",'');
            component.set("v.ApprovedActive",'active-page');
            component.set("v.RejectedActive",'');
            component.set("v.EntitleActive",'');
        }
        if(approvalValue == 'Rejected'){
            component.set("v.DraftActive",'');
            component.set("v.ApprovedActive",'');
            component.set("v.RejectedActive",'active-page');
            component.set("v.EntitleActive",'');
        }
        if(approvalValue == 'Entitle'){
            component.set("v.DraftActive",'');
            component.set("v.ApprovedActive",'');
            component.set("v.RejectedActive",'');
            component.set("v.EntitleActive",'active-page');
        }
    },

    displayApproved: function(component, event, helper) {
        try{
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        console.log('Employee is Admin?:',component.get("v.IsAdmin"));
        var action = component.get("c.getDefaultApproved");

            action.setParams({
                currentFiscalYear: component.get("v.currentFiscalYear")
            });
        action.setCallback(this, function(response) {
            console.log('leave request:',JSON.stringify( response.getReturnValue()));
            if(response.getState() === "SUCCESS"){
               component.set("v.Records", response.getReturnValue());
               //component.set("v.ForApprovalRecords", response.getReturnValue());
        	}
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);

        }
        catch(e){
            console.log('Exception in GetApproved:',e);
        }
    },

    displaySubmitted: function(component, event, helper) {
        try{
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        console.log('Employee is Admin?:',component.get("v.IsAdmin"));
        var action = component.get("c.getSubmittedRequests");
            action.setParams({
            });
            action.setCallback(this, function(response) {
            console.log('Submitted for Approval leave requests:',JSON.stringify( response.getReturnValue()));
            if(response.getState() === "SUCCESS"){
               component.set("v.ForApprovalRecords", response.getReturnValue());
        	}
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);

        }
        catch(e){
            console.log('Exception in GetApproved:',e);
        }
    },

    tabChange : function(component, event, helper) {
        try{

            var approvalValue = event.currentTarget.getAttribute("data-attribute");
        if(approvalValue == 'LeaveApplication-tab'){
                component.set("v.CurrentTab",'LeaveApplication-tab');
                $A.util.removeClass(component.find('Entitlement-Page'), "active-page");
                $A.util.removeClass(component.find('Policy-Page'), "active-page"); 
                $A.util.removeClass(component.find('Employees-Page'), "active-page"); 
                $A.util.addClass(component.find('LeaveApp-Page'), "active-page");   
            	$A.util.removeClass(component.find('Approved-Page'), "active-page"); 
                $A.util.removeClass(component.find('Rejected-Page'), "active-page"); 
                $A.util.removeClass(component.find('Draft-Page'), "active-page"); 
        }
        if(approvalValue == 'Employees-tab'){

                component.set("v.CurrentTab",'Employees-tab');
                $A.util.removeClass(component.find('Entitlement-Page'), "active-page");
                $A.util.removeClass(component.find('Policy-Page'), "active-page"); 
                $A.util.removeClass(component.find('Draft-Page'), "active-page");
                $A.util.addClass(component.find('Employees-Page'), "active-page"); 
                $A.util.removeClass(component.find('LeaveApp-Page'), "active-page");
            	$A.util.removeClass(component.find('Approved-Page'), "active-page"); 
                $A.util.removeClass(component.find('Rejected-Page'), "active-page"); 

                var action = component.get("c.getEmployeRecords");

                action.setParams({ });
                action.setCallback(this, function(response) {
                    console.log('Employee Records:',JSON.stringify( response.getReturnValue()));
                    if(response.getState() === "SUCCESS"){
                        component.set("v.EmployeeRecords", response.getReturnValue());
                    }
                    else{
                        var errors = response.getError();
                        console.log("err -> ", errors);
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                component.set("v.exceptionError",errors[0].message);
                                setTimeout(
                                    $A.getCallback(function() {
                                        component.set("v.exceptionError","");
                                    }), 5000
                                );

                            }
                            else if(errors[0].pageErrors[0].message){
                                component.set("v.exceptionError", errors[0].pageErrors[0].message);
                                setTimeout(
                                    $A.getCallback(function() {
                                        component.set("v.exceptionError","");
                                    }), 5000
                                );

                            }
                        }
                        else{
                            component.set("v.exceptionError","Unknown error");
                            setTimeout(
                                $A.getCallback(function() {
                                    component.set("v.exceptionError","");
                                }), 5000
                            );

                        }
                    }
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
                
                
        }
        if(approvalValue == 'Policy-tab'){
            component.set("v.CurrentTab",'Policy-Page');
                $A.util.removeClass(component.find('Entitlement-Page'), "active-page");
                $A.util.addClass(component.find('Policy-Page'), "active-page"); 
                $A.util.removeClass(component.find('Draft-Page'), "active-page");
                $A.util.removeClass(component.find('Employees-Page'), "active-page"); 
                $A.util.removeClass(component.find('LeaveApp-Page'), "active-page"); 
            	$A.util.removeClass(component.find('Approved-Page'), "active-page"); 
                $A.util.removeClass(component.find('Rejected-Page'), "active-page"); 
        } 
        if(approvalValue == 'Entitlement-tab'){
            component.set("v.CurrentTab",'Entitlement-Page');
                $A.util.addClass(component.find('Entitlement-Page'), "active-page");
                $A.util.removeClass(component.find('Draft-Page'), "active-page");
                $A.util.removeClass(component.find('Policy-Page'), "active-page"); 
                $A.util.removeClass(component.find('Employees-Page'), "active-page"); 
                $A.util.removeClass(component.find('LeaveApp-Page'), "active-page"); 
            	$A.util.removeClass(component.find('Approved-Page'), "active-page"); 
                $A.util.removeClass(component.find('Rejected-Page'), "active-page"); 
        } 
        if(approvalValue == 'Draft-tab'){
                component.set("v.CurrentTab",'Draft-tab');
                $A.util.removeClass(component.find('Entitlement-Page'), "active-page");
                $A.util.removeClass(component.find('Policy-Page'), "active-page"); 
                $A.util.removeClass(component.find('Employees-Page'), "active-page"); 
                $A.util.removeClass(component.find('LeaveApp-Page'), "active-page"); 
                $A.util.addClass(component.find('Draft-Page'), "active-page"); 
            	$A.util.removeClass(component.find('Approved-Page'), "active-page"); 
                $A.util.removeClass(component.find('Rejected-Page'), "active-page"); 
        }
        if(approvalValue == 'Approved-tab'){
            component.set("v.CurrentTab",'Approved-Page');
                $A.util.addClass(component.find('Entitlement-Page'), "active-page");
                $A.util.removeClass(component.find('Draft-Page'), "active-page");
                $A.util.removeClass(component.find('Policy-Page'), "active-page"); 
                $A.util.removeClass(component.find('Employees-Page'), "active-page"); 
                $A.util.removeClass(component.find('LeaveApp-Page'), "active-page");  
            	$A.util.addClass(component.find('Approved-Page'), "active-page"); 
                $A.util.removeClass(component.find('Rejected-Page'), "active-page"); 
        } 
        if(approvalValue == 'Rejected-tab'){
            component.set("v.CurrentTab",'Rejected-Page');
                $A.util.addClass(component.find('Entitlement-Page'), "active-page");
                $A.util.removeClass(component.find('Draft-Page'), "active-page");
                $A.util.removeClass(component.find('Policy-Page'), "active-page"); 
                $A.util.removeClass(component.find('Employees-Page'), "active-page"); 
                $A.util.removeClass(component.find('LeaveApp-Page'), "active-page"); 
            	$A.util.removeClass(component.find('Approved-Page'), "active-page"); 
                $A.util.addClass(component.find('Rejected-Page'), "active-page"); 
        } 

        }
        catch(e){
            console.log('Exception in GetApproved:',e);
        }
    },
    
    sortByEmpName: function(component, event, helper) {
        helper.sortByEMP(component, "ERP7__Employee__r.ERP7__First_Name__c");
    },
    
    //ak
    getEmpLeaveDetails: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getApproval");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.empLeaves", response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    leaveManager : function(component, event, helper){
        var operation = event.getParam("value");
        if(operation == "Edit"){
            component.set("v.newTimeOff",{ sobjectType : 'ERP7__Leave_Request__c'});
            component.set("v.isEdit", true);
            component.set("v.editIndex",event.getSource().get("v.name"));
            var LeaveReq = component.get("v.table");
            component.set("v.newTimeOff", LeaveReq[event.getSource().get("v.name")]);
            component.set("v.resetLookups", false);
            component.set("v.resetLookups", true);
            $A.enqueueAction(component.get("c.openTimeOffModal"));
        }
        else if(operation == "Delete"){
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var deleteAction = component.get("c.deleteLeave");
            deleteAction.setParams({
                "recordId": event.getSource().get("v.value")
            });
            deleteAction.setCallback(this, function(response) {
                var recordId = response.getReturnValue();
                var deleteEvent = component.getEvent("delete");
                deleteEvent.setParams({
                    "listIndex": event.getSource().get("v.name"),
                    "oldRecord": component.get("v.table")[event.getSource().get("v.name")]
                }).fire();
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(deleteAction);
        }
    },
    
    EMPleaveManager : function(component, event, helper){
        var operation = event.getParam("value");
        if(operation == "Approve"){
            component.set("v.empLeaveId", event.getSource().get("v.value"));
            component.set("v.empARIndex", event.getSource().get("v.name"));
            $A.util.addClass(component.find("approveTimeOffModal"), 'slds-fade-in-open');
            $A.util.addClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        }
        else if(operation == "Reject"){
            component.set("v.empLeaveId", event.getSource().get("v.value"));
            component.set("v.empARIndex", event.getSource().get("v.name"));
            $A.util.addClass(component.find("rejectTimeOffModal"), 'slds-fade-in-open');
            $A.util.addClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        }
    },
    
    toggleTabs : function(component, event){
        var tab = event.currentTarget.dataset.tab;
        if(tab != component.get("v.Tab")) component.set("v.Tab", tab);
        if(tab == 'tab4') component.set("v.View", 'List');
    },
    
    toggleViews : function(component, event){
        var view = event.currentTarget.dataset.tab;
        if(view != component.get("v.View")) component.set("v.View", view);
    },
    
    openTimeOffModal : function(component, event, helper){
        $A.util.addClass(component.find("newTimeOffModal"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        console.log('openApproveModal set Leavereason to null');
        component.set("v.Leavereason", '');
        var today = new Date();
        var formattedDate = today.toISOString().slice(0, 10);
        component.set("v.newTimeOff.ERP7__Applied_Date__c", formattedDate);
        var approvalValue = event.currentTarget.getAttribute("data-attribute");
        if(approvalValue=='Edit'){
            var index = event.currentTarget.getAttribute("data-index");
            var records = component.get("v.Records");
            component.set("v.newTimeOff",records[index]);
            //component.set("v.Leavereason", records[index].ERP7__Leave_Reason__c);
            /*component.set("v.newTimeOff.Id",records[index].Id);
            component.set("v.newTimeOff.Name",records[index].Name);
            component.set("v.newTimeOff.ERP7__Approvers__c",records[index].ERP7__Approvers__c);
            component.set("v.newTimeOff.ERP7__Leave_Start_Date__c",records[index].ERP7__Leave_Start_Date__c);
            component.set("v.newTimeOff.ERP7__Leave_End_Date__c",records[index].ERP7__Leave_End_Date__c);
            component.set("v.newTimeOff.ERP7__Leave_Type__c",records[index].ERP7__Leave_Type__c);
            component.set("v.newTimeOff.ERP7__Number_of_Days__c",records[index].ERP7__Number_of_Days__c);
            component.set("v.newTimeOff.ERP7__Applied_Date__c",records[index].ERP7__Applied_Date__c);
            component.set("v.newTimeOff.ERP7__Leave_Reason__c",records[index].ERP7__Leave_Reason__c);*/
            console.log('newTimeOff',JSON.stringify(component.get("v.newTimeOff")));
        }
        var approver = component.get("v.newTimeOff.ERP7__Approvers__c");
        if(!(approver != null && approver != undefined && approver != ""))
            helper.setLeaveApprover(component, event);
    },

    openPopupModal : function(component, event, helper){
        console.log('Inside openPopupModal');
        $A.util.addClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
        var CurrentPopUp = event.currentTarget.getAttribute("data-attribute");
        component.set("v.CurrentPopUp",CurrentPopUp);
         
       
            component.set("v.newTimeOff",{ sobjectType : 'ERP7__Leave_Request__c'});
            component.set("v.isEdit", true);
            component.set("v.editIndex",event.currentTarget.dataset.index);
            var LeaveReq = component.get("v.ForApprovalRecords");
            console.log('Current Record for edit/delete:~>',JSON.stringify(LeaveReq[event.currentTarget.dataset.index]));
            component.set("v.newTimeOff", LeaveReq[event.currentTarget.dataset.index]);
            component.set("v.resetLookups", false);
            component.set("v.resetLookups", true);
        console.log('Last openPopupModal');
        
    },
    
    EditClickAdmin: function(component, event, helper){
        console.log('Inside EditClickAdmin');
        $A.util.addClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
        var CurrentPopUp = "Edit-Leaverequest";
        component.set("v.CurrentPopUp",CurrentPopUp);
        component.set("v.newTimeOff",{ sobjectType : 'ERP7__Leave_Request__c'});
        component.set("v.isEdit", true);
        component.set("v.editIndex",event.currentTarget.dataset.index);
        var LeaveReq = component.get("v.SubmittedRec");
        console.log('Current Record for edit/delete:~>',JSON.stringify(LeaveReq[event.currentTarget.dataset.index]));
        component.set("v.newTimeOff", LeaveReq[event.currentTarget.dataset.index]);
        component.set("v.resetLookups", false);
        component.set("v.resetLookups", true);
        console.log('Last EditClickAdmin');
    },
    handleDelClickAdmin:function(component, event, helper){
        console.log('Inside handleDelClickAdmin');
        $A.util.addClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
        var CurrentPopUp = "Delete-Leaverequest";
        component.set("v.CurrentPopUp",CurrentPopUp);
        component.set("v.newTimeOff",{ sobjectType : 'ERP7__Leave_Request__c'});
        component.set("v.isEdit", true);
        component.set("v.editIndex",event.currentTarget.dataset.index);
        var LeaveReq = component.get("v.SubmittedRec");
        console.log('Current Record for edit/delete:~>',JSON.stringify(LeaveReq[event.currentTarget.dataset.index]));
        component.set("v.newTimeOff", LeaveReq[event.currentTarget.dataset.index]);
        component.set("v.resetLookups", false);
        component.set("v.resetLookups", true);
        console.log('Last handleDelClickAdmin');
    },
    
    Save: function(component, event, helper){
        var action = component.get("c.getSaveLeaveRequest");
        action.setParams({
            LeaveReq1 : JSON.stringify(component.get("v.newTimeOff")),
            str : "Draft",
            leaveType : component.get("v.newTimeOff.ERP7__Leave_Type__c")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                $A.util.removeClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
                var LeaveRequests = component.get("v.SubmittedRec");
                if(!component.get("v.isEdit")){
                    LeaveRequests.push(response.getReturnValue());
                    component.set("v.serverSuccess", "New Leave Request Created Successfully.");
                }
                else{
                    LeaveRequests[component.get("v.editIndex")] = response.getReturnValue();
                    component.set("v.serverSuccess", "Leave Request Updated Successfully.");
                }
                component.set("v.SubmittedRec", LeaveRequests);
                //component.set("v.Tab", 'tab1');
                component.set("v.isEdit", false);
                //$A.enqueueAction(component.get("c.displaySubmitted")); 
            }
            else{
                $A.util.removeClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
                var errors = response.getError();
                console.log("err -> ", errors);
                component.set("v.exceptionError",errors[0].message);
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.exceptionError","");
                    }), 5000
                );
            }    
        });
        $A.enqueueAction(action);
        
    },
    SaveSubmit: function(component, event, helper){
        var action = component.get("c.getSaveLeaveRequest");
        action.setParams({
            LeaveReq1 : JSON.stringify(component.get("v.newTimeOff")),
            str : "Submitted",
            leaveType : component.get("v.newTimeOff.ERP7__Leave_Type__c")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                $A.util.removeClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
                var LeaveRequests = component.get("v.SubmittedRec");
                if(!component.get("v.isEdit")){
                    LeaveRequests.push(response.getReturnValue());
                    component.set("v.serverSuccess", "New Leave Request Created Successfully.");
                }
                else{
                    LeaveRequests[component.get("v.editIndex")] = response.getReturnValue();
                    component.set("v.serverSuccess", "Leave Request Updated Successfully.");
                }
                component.set("v.SubmittedRec", LeaveRequests);
                //component.set("v.Tab", 'tab1');
                component.set("v.isEdit", false);
               // $A.enqueueAction(component.get("c.displaySubmitted")); 
            }
            else{
                $A.util.removeClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
                var errors = response.getError();
                console.log("err -> ", errors);
                component.set("v.exceptionError",errors[0].message);
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.exceptionError","");
                    }), 5000
                );
            }    
        });
        $A.enqueueAction(action);
        
    },
    DeleteLeaveReq: function(component, event, helper){
        var action = component.get("c.DelLeaveRequest");
        var newTimeOff=component.get("v.newTimeOff");
        action.setParams({
            LeaveReqId : newTimeOff.Id,
            currentFiscalYear: component.get("v.currentFiscalYear")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                $A.util.removeClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
                /*var LeaveRequests = component.get("v.ForApprovalRecords");
                if(!component.get("v.isEdit")){
                    LeaveRequests.push(response.getReturnValue());
                    component.set("v.serverSuccess", "New Leave Request Created Successfully.");
                }
                else{
                    LeaveRequests[component.get("v.editIndex")] = response.getReturnValue();
                    component.set("v.serverSuccess", "Leave Request Updated Successfully.");
                }*/
               // component.set("v.ForApprovalRecords", response.getReturnValue());
                //component.set("v.Tab", 'tab1');
                component.set("v.isEdit", false);
                $A.enqueueAction(component.get('c.DraftSubmit'));
              //  helper.updatetRejected(component,event);
                
            }
            else{
                $A.util.removeClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
                var errors = response.getError();
                console.log("err -> ", errors);
                component.set("v.exceptionError",errors[0].message);
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.exceptionError","");
                    }), 5000
                );
            }    
        });
        $A.enqueueAction(action);
    },
    
    leaveDateChange : function(component, event, helper){
        if(component.get("v.newTimeOff.ERP7__Leave_Start_Date__c") != undefined && component.get("v.newTimeOff.ERP7__Leave_End_Date__c") != undefined){
            var duration = 0;
            var SD = new Date(component.get("v.newTimeOff.ERP7__Leave_Start_Date__c"));
            var ED = new Date(component.get("v.newTimeOff.ERP7__Leave_End_Date__c"));
            var timeDiffrence = Math.abs(ED.getTime() - SD.getTime());
            duration = Math.ceil(timeDiffrence / (1000 * 3600 * 24)) + 1;
            component.set("v.newTimeOff.ERP7__Number_of_Days__c", duration);
        }
        else component.set("v.newTimeOff.ERP7__Number_of_Days__c", 0);
    },
    
    saveTimeOff : function(component, event, helper) {
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        //component.set("v.newTimeOff.ERP7__Leave_Reason__c",component.get("v.Leavereason"));
        console.log('newTimeOff saveTimeOff',JSON.stringify(component.get("v.newTimeOff")));
        var action = component.get("c.getEnt1");
        console.log('newTimeOff saveTimeOff 2');
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                helper.upsertLeaveRequest(component, event, helper);
                $A.enqueueAction(component.get("c.displayApproved")); 
                $A.enqueueAction(component.get("c.displaySubmitted")); 
             }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
        
    },
    
    submitTimeOff : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        //component.set("v.newTimeOff.ERP7__Leave_Reason__c",component.get("v.Leavereason"));
        console.log('newTimeOff submitTimeOff',JSON.stringify(component.get("v.newTimeOff")));
        var action = component.get("c.getEnt1");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.newTimeOff.ERP7__Status__c", 'Submitted');
                helper.upsertLeaveRequestSub(component, event, helper);
                $A.enqueueAction(component.get("c.displayApproved"));
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 5000
                        );

                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );

                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    closeTimeOffModal : function(component, event){
        $A.util.removeClass(component.find("newTimeOffModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        if(component.get("v.isEdit")) component.set("v.newTimeOff",{sobjectType : 'ERP7__Leave_Request__c'});
        else{
            component.set("v.newTimeOff",{ 
                sobjectType : 'ERP7__Leave_Request__c',
                ERP7__Approvers__c : component.get("v.newTimeOff.ERP7__Approvers__c")
            });
        }
        component.set("v.isEdit", false);
    },

    closePopupModal : function(component, event){
        $A.util.removeClass(component.find("viewAplliedRequest"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newTimeOffModalBackdrop1"), 'slds-backdrop_open');
    },
    
    openApproveModal : function(component, event, helper){
        component.set("v.empLeaveId", event.currentTarget.dataset.recordId);
        component.set("v.empARIndex", event.currentTarget.dataset.index);
        $A.util.addClass(component.find("approveTimeOffModal"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
    },
    
    closeApproveModal : function(component, event, helper){
        component.set("v.empLeaveId", "");
        component.set("v.empARIndex", 0);
        component.set("v.A_Rcomment", "");
        $A.util.removeClass(component.find("approveTimeOffModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
    },
    
    openRejectModal : function(component, event, helper){
        component.set("v.empLeaveId", event.currentTarget.dataset.recordId);
        component.set("v.empARIndex", event.currentTarget.dataset.index);
        $A.util.addClass(component.find("rejectTimeOffModal"), 'slds-fade-in-open');
        $A.util.addClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
    },
    
    closeRejectModal : function(component, event, helper){
        component.set("v.empLeaveId", "");
        component.set("v.empARIndex", 0);
        component.set("v.A_Rcomment", "");
        $A.util.removeClass(component.find("rejectTimeOffModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
    },
    
    closeError : function(component){
        component.set("v.exceptionError","");
    },

    closeSuccess : function(component){
        component.set("v.serverSuccess","");
    },
    
    ApproveLeave: function (component, event, helper) {
        var recId = component.get("v.CurrentLeaveId");
        console.log('Inside ApproveLeave record Id:',recId);
        helper.ApprovedReject(component,recId,'Approved');
        $A.util.removeClass(component.find("approveTimeOffModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        component.set("v.CurrentLeaveId",'');
        $A.enqueueAction(component.get("c.displaySubmitted")); 
        //$A.get('e.force:refreshView').fire();
    }, 
    
    RejectLeave: function (component, event, helper) {
        var recId = component.get("v.CurrentLeaveId");
        helper.ApprovedReject(component,recId,'Rejected');
        $A.util.removeClass(component.find("rejectTimeOffModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        component.set("v.CurrentLeaveId",'');
        $A.enqueueAction(component.get("c.displaySubmitted"));
        //$A.get('e.force:refreshView').fire();
    },
    
    openApprovedRejectedModel: function (component, event, helper){
        var recId = event.currentTarget.getAttribute("data-recordId");
        var modeltype = event.currentTarget.getAttribute("data-name");
        console.log('openApprovedRejectedModel record Id:',recId);
        component.set("v.CurrentLeaveId",recId);
        if(modeltype == 'Approve'){
            $A.util.addClass(component.find("approveTimeOffModal"), 'slds-fade-in-open');
            $A.util.addClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        }
        if(modeltype == 'Reject'){
            $A.util.addClass(component.find("rejectTimeOffModal"), 'slds-fade-in-open'); 
            $A.util.addClass(component.find("newTimeOffModalBackdrop"), 'slds-backdrop_open');
        }
    },
     viewEmployee: function(component,event,helper){
    
        var clickedElement = event.currentTarget;

        var recordId = clickedElement.getAttribute("data-record");
        var recordName = clickedElement.getAttribute("data-name");
        console.log('view emp');

        var action=component.get("c.getEmployeeDetails");
        action.setParams({
            EmpId:recordId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
              // console.log('emp data',JSON.stringify(response.getReturnValue()));
                component.set("v.EmployeeEdit",response.getReturnValue());
                component.set('v.currentEmp', response.getReturnValue().Id);
                $A.util.addClass(component.find("EmployeeEditModal"), 'slds-fade-in-open');
                $A.util.addClass(component.find("EmployeeEditBackdrop"), 'slds-backdrop_open');
            }
        });
        $A.enqueueAction(action);
    },
    closeEmployeeEditModal: function(component,event,helper){
        component.set('v.isEmployeeEdit', false);
        $A.util.removeClass(component.find("EmployeeEditModal"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("EmployeeEditBackdrop"), 'slds-backdrop_open');
    },
    saveEmployeeEditModal : function(component,event,helper){

        var emp=component.get("v.EmployeeEdit");
        console.log('emp details',JSON.stringify(emp));
        
        var action=component.get("c.saveEmployee");

        action.setParams({
            emp:emp
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('saved emp successfully');
                component.set('v.isEmployeeEdit', false);
                $A.util.removeClass(component.find("EmployeeEditModal"), 'slds-fade-in-open');
                $A.util.removeClass(component.find("EmployeeEditBackdrop"), 'slds-backdrop_open');
                $A.enqueueAction(component.get("c.getEmployees"));
            }else{
                console.log('error occured');
            }
        });
        $A.enqueueAction(action);
        console.log('end');
        
    },
     getEmployees: function(component) {

        var action = component.get("c.getEmployeRecords");

        action.setCallback(this, function(response) {
            console.log('Employee Records:',JSON.stringify( response.getReturnValue()));
            if(response.getState() === "SUCCESS"){
                console.log('employees refreshed');
                component.set("v.EmployeeRecords", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);

    },
     editEmployeeByAdmin: function(component,event,helper){
        
        var clickedElement = event.currentTarget;

        var recordId = clickedElement.getAttribute("data-record");
        var recordName = clickedElement.getAttribute("data-name");

        var action=component.get("c.getEmployeeDetails");
        action.setParams({
            EmpId:recordId
        });
 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
              // console.log('emp data',JSON.stringify(response.getReturnValue()));
                component.set("v.EmployeeEdit",response.getReturnValue());
                component.set('v.currentEmp', response.getReturnValue().Id);
                component.set('v.isEmployeeEdit', true);
                $A.util.addClass(component.find("EmployeeEditModal"), 'slds-fade-in-open');
                $A.util.addClass(component.find("EmployeeEditBackdrop"), 'slds-backdrop_open');
            }
        });

        console.log("Record ID: " + recordId);
        console.log("Record Name: " + recordName);
        $A.enqueueAction(action);
    },
    
})