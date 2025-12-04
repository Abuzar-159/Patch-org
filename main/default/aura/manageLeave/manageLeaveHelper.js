({ 
    updatetRejected :function(component, event) {
        var action = component.get("c.getApproved");
        action.setParams({
            status: 'Rejected',
            currentFiscalYear: component.get("v.currentFiscalYear")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.Records", response.getReturnValue());
                
                component.set("v.RejectedRec", response.getReturnValue());
                
                
                console.log('approvalValue',response.getReturnValue());
            }
        });
         $A.enqueueAction(action);
    },
    
    doInit: function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.GetRecordCounts");
        action.setParams({
            strDate: component.get("v.selectedFY")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.counts', response.getReturnValue());
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
    
    getEmployee: function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getCurrentUserEmp");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.Employee', response.getReturnValue().currEmp);
                console.log('Employee User:',JSON.stringify(response.getReturnValue().currEmp));
				component.set('v.UserImageURL', response.getReturnValue().currUser.SmallPhotoUrl);
                if(response.getReturnValue().currEmp.ERP7__Admin__c){
                    console.log('Current User is Admin:',response.getReturnValue().currEmp.ERP7__Admin__c);
                    component.set('v.IsAdmin',true);
                    $A.util.removeClass(component.find("Admin-View"), 'slds-hidden');
                    $A.util.addClass(component.find("Admin-View"), 'slds-visible');
                }
                else{
                    $A.util.removeClass(component.find("Employee-View"), 'slds-hidden');
                    $A.util.addClass(component.find("Employee-View"), 'slds-visible');
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
        $A.enqueueAction(action);
    },
    
    doInit2: function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.GetRecordCounts");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.counts', response.getReturnValue());
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
    
    FYchange : function(component, event){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getAccounts");
        action.setParams({
            strDate: component.get("v.selectedFY")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.table', response.getReturnValue());
                $A.enqueueAction(action2);
            }
        });
        var action2 = component.get("c.getLeaveApproved");
        action2.setParams({
            strDate: component.get("v.selectedFY")
        });
        action2.setCallback(this, function(response){
            if (response.getState() === "SUCCESS") {
                component.set('v.Records', response.getReturnValue());
                $A.enqueueAction(action3);
            }
        });
        var action3 = component.get("c.getEntitlementsHolidays");
        action3.setParams({
            strDate: component.get("v.selectedFY")
        });
        action3.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.Holidays', response.getReturnValue());
                $A.enqueueAction(action4);
            }
        });
        var action4 = component.get("c.getEntme");
        action4.setParams({
            strDate: component.get("v.selectedFY")
        });
        action4.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.EmpEnt', response.getReturnValue());
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                this.doInit(component, event);
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    sortBy: function(component, field) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
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
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    sortByApproved: function(component, field) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            Records = component.get("v.Records");
        sortAsc = field == sortField? !sortAsc: true;
        Records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.Records", Records);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    sortByLeaveType: function(component, field) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            EmpEnt = component.get("v.EmpEnt");
        sortAsc = field == sortField? !sortAsc: true;
        EmpEnt.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.EmpEnt", EmpEnt);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    sortByHoliday: function(component, field) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            Holidays = component.get("v.Holidays");
        sortAsc = field == sortField? !sortAsc: true;
        Holidays.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.Holidays", Holidays);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    sortByEMP : function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            Leaves = component.get("v.empLeaves");
        sortAsc = field == sortField? !sortAsc: true;
        Leaves.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.empLeaves", Leaves);
    },
    
    setLeaveApprover : function(component, event){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var approverAction = component.get("c.getApproverDetails");
        approverAction.setCallback(this, function(response) {
            if(response.getState()==="SUCCESS"){
                component.set("v.newTimeOff.ERP7__Approvers__c",response.getReturnValue().ManagerId);
                component.set("v.resetLookups", false);
                component.set("v.resetLookups", true);
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
        $A.enqueueAction(approverAction);
    },
    
    upsertLeaveRequest : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        
        
        if (component.get("v.newTimeOff.ERP7__Leave_Type__c") == 'Sick Leave') {
            console.log('inside Sick Leave: '); 
            if(component.get("v.Employee.ERP7__Sick_Leave_Available__c")<=0 || component.get("v.Employee.ERP7__Sick_Leave_Available__c") < component.get("v.newTimeOff.ERP7__Number_of_Days__c")){
                component.set("v.exceptionError", "Sick leaves are not Allowed"); setTimeout($A.getCallback(function () { component.set("v.exceptionError", ""); }), 5000);
                return;
            }
        }
        
        if (component.get("v.newTimeOff.ERP7__Leave_Type__c") == 'Casual Leave') {
            if(component.get("v.Employee.ERP7__Casual_Leave_Available__c")<=0 || component.get("v.Employee.ERP7__Casual_Leave_Available__c") < component.get("v.newTimeOff.ERP7__Number_of_Days__c")){
                component.set("v.exceptionError", "Casual leaves are not Allowed"); setTimeout($A.getCallback(function () { component.set("v.exceptionError", ""); }), 5000);
                return;
            }
        }
        
        if (component.get("v.newTimeOff.ERP7__Leave_Type__c") == 'Maternity/ Paternity Leave') {
            
            if(component.get("v.Employee.ERP7__Paternity_Leave_Avaiable__c")<=0 || component.get("v.Employee.ERP7__Paternity_Leave_Avaiable__c") < component.get("v.newTimeOff.ERP7__Number_of_Days__c")){
                component.set("v.exceptionError", "Maternity/ Paternity leaves are not Allowed"); setTimeout($A.getCallback(function () { component.set("v.exceptionError", ""); }), 5000);    
                return;
            }
            
        }
        
        if (component.get("v.newTimeOff.ERP7__Leave_Type__c") == 'Annual Leave') {
            
            if(component.get("v.Employee.ERP7__Annual_Leave_Available__c")<=0 || component.get("v.Employee.ERP7__Annual_Leave_Available__c") < component.get("v.newTimeOff.ERP7__Number_of_Days__c")){
                component.set("v.exceptionError","Annual leaves are not Allowed"); setTimeout( $A.getCallback(function() { component.set("v.exceptionError",""); }), 5000 );
                return;
            }
            
        }
        
        if (component.get("v.newTimeOff.ERP7__Leave_Type__c") == 'Earned Leave') {
            if(component.get("v.Employee.ERP7__Earned_Leave_Available__c")<=0 || component.get("v.Employee.ERP7__Earned_Leave_Available__c") < component.get("v.newTimeOff.ERP7__Number_of_Days__c")){
                component.set("v.exceptionError","Earned leaves are not Allowed"); setTimeout( $A.getCallback(function() { component.set("v.exceptionError",""); }), 5000 );
                return;
            }
            
            
        } 
        
            var action = component.get("c.getSaveLeaveRequest");
            action.setParams({
                LeaveReq1 : JSON.stringify(component.get("v.newTimeOff")),
                str : "Draft",
                leaveType : component.get("v.newTimeOff.ERP7__Leave_Type__c")
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var LeaveRequests = component.get("v.table");
                     var LeaveRequests2 = component.get("v.ForApprovalRecords");
                    if(!component.get("v.isEdit")){
                        LeaveRequests.push(response.getReturnValue());
                        LeaveRequests2.push(response.getReturnValue());
                        component.set("v.serverSuccess", "New Leave Request Created Successfully.");
                    }
                    else{
                        LeaveRequests[component.get("v.editIndex")] = response.getReturnValue();
                        LeaveRequests2[component.get("v.editIndex")] = response.getReturnValue();
                        component.set("v.serverSuccess", "Leave Request Updated Successfully.");
                    }
                    component.set("v.table", LeaveRequests);
                    component.set("v.ForApprovalRecords", LeaveRequests2);
                    component.set("v.Tab", 'tab1');
                    $A.enqueueAction(component.get("c.closeTimeOffModal"));
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );
                    
                    component.set("v.isEdit", false);
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
    
    upsertLeaveRequestSub : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        console.log('newTimeOff upsertLeaveRequestSub',JSON.stringify(component.get("v.newTimeOff")));
        var action = component.get("c.getSaveLeaveRequest");
        action.setParams({
            LeaveReq1 : JSON.stringify(component.get("v.newTimeOff")),
            str: "Submitted",
            leaveType : component.get("v.newTimeOff.ERP7__Leave_Type__c")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var LeaveRequests = component.get("v.table");
                var LeaveRequests2 = component.get("v.ForApprovalRecords");
                if(!component.get("v.isEdit")){
                    LeaveRequests.push(response.getReturnValue());
                    LeaveRequests2.push(response.getReturnValue());
                    component.set("v.serverSuccess", "New Leave Request Created Successfully.");
                }
                else{
                    LeaveRequests[component.get("v.editIndex")] = response.getReturnValue();
                    LeaveRequests2[component.get("v.editIndex")] = response.getReturnValue();
                    component.set("v.serverSuccess", "Leave Request Updated Successfully.");
                }
                component.set("v.table", LeaveRequests);
                component.set("v.ForApprovalRecords", LeaveRequests2);
                component.set("v.Tab", 'tab1');
                $A.enqueueAction(component.get("c.closeTimeOffModal"));
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.exceptionError","");
                    }), 5000
                );

                component.set("v.isEdit", false);
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
    
    ApprovedReject: function (component,LeaveId,ApprovalType) {
        try 
        {
			 console.log('A_Rcomment:',component.get("v.A_Rcomment"));
             console.log('empLeaveId:',component.get("v.empLeaveId"));
             console.log('ApprovalType:',ApprovalType);
             console.log('LeaveId:',LeaveId);
            var action = component.get("c.saveApprovedLeave");
            action.setParams({
                reason: component.get("v.A_Rcomment"),
                sts:ApprovalType, 
                LeaveId:LeaveId
            });
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var error = response.getReturnValue();
                    if (error == null) {
                        console.log('Approved/rejected:');
                        
                        const toastEvent = $A.get("e.force:showToast");
                        let title, message, type;
                        
                        if (ApprovalType === 'Approved') {
                            title = 'Success';
                            message = 'Leave Approved Successfully.';
                            type = 'success';
                        } else if (ApprovalType === 'Rejected') {
                            title = 'Warning';
                            message = 'Leave Rejected.';
                            type = 'warning';
                        }
                        
                        toastEvent.setParams({
                            title: title,
                            message: message,
                            duration: '4000',
                            type: type,
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);
            
            
        } 
        catch (e) {console.log('error' + JSON.stringify(e))}
    },
})