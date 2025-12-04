({
    Submit: function(component, event, helper) {
        var LeaveReqs = component.get("v.LeaveReqs");
        var action = component.get("c.getEnt1");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Allowance", response.getReturnValue());
                var valid = component.get("v.Allowance");
                for (var y = 0; y < valid.length; y++) {
                    var numD = valid[y].ERP7__Available_Allowance__c;
                }
                //name validation
                var colorCmp = component.find("name");
                var myColor = colorCmp.get("v.value");
                if (!myColor) {
                    colorCmp.set("v.errors", [{
                        message: "Enter Leave Request Name" 
                    }]);
                } else {
                    colorCmp.set("v.errors", null);
                    var d1 = $(component.find('StrDate').getElement()).datepicker('getDate');
                    var d2 = $(component.find('EndDate').getElement()).datepicker('getDate');
                    var diff = 0;
                    if (d1 && d2) {
                        diff = Math.floor((d2.getTime() - d1.getTime()) / 86400000); // ms per day
                    }
                    //Number of days validation
                    /*var days = component.find("totalValue");
                    var mydays = days.get("v.value");
                    if (mydays <= 0 || isNaN(mydays) || mydays != diff + 1) {
                        days.set("v.errors", [{
                            message: "Sorry, Invalid Entry"
                        }]);
                    } else {
                        days.set("v.errors", null);
                        var days = component.find("totalValue");
                        var mydays = days.get("v.value");
                        if (mydays > numD) {
                            days.set("v.errors", [{
                                message: "Sorry, the request exceeded your remaining allowance"
                            }]);
                        } else {
                            days.set("v.errors", null);*/
                            //helper.Submit(component, LeaveReqs);
                            helper.upsertLeaveRequestSub(component, event, helper);
                            var btn = component.find("dest");
                            $A.util.toggleClass(btn, "slds-hide");
                            //location.reload();
                            /*$A.createComponent(
                                "c:oneLeave", {
                                },
                                function(newCmp) {
                                    if (component.isValid()) {
                                        var body = component.get("v.body");
                                        body.push(newCmp);
                                        component.set("v.body", body);
                                    }
                                }
                            );*/
                       // }
                    //}
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    Save: function(component, event, helper) {
        
        var action = component.get("c.getEnt1");
        
        var LeaveReqs = component.get("v.LeaveReqs");
        var sdate = component.find('StrDate');
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.Allowance", response.getReturnValue());
                var valid = component.get("v.Allowance");
                for (var y = 0; y < valid.length; y++) {
                    var numD = valid[y].ERP7__Available_Allowance__c;
                }
                var colorCmp = component.find("name");
                var myColor = colorCmp.get("v.value");
                if (!myColor) {
                    colorCmp.set("v.errors", [{
                        message: "Enter Leave Request Name"
                    }]);
                } else {
                    colorCmp.set("v.errors", null);
                    var d1 = $(component.find('StrDate').getElement()).datepicker('getDate');
                    var d2 = $(component.find('EndDate').getElement()).datepicker('getDate');
                    var diff = 0;
                    if (d1 && d2) {
                        diff = Math.floor((d2.getTime() - d1.getTime()) / 86400000); // ms per day
                    }
                    helper.upsertLeaveRequest(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
    Back: function(component, event, helper) {
        var btn = component.find("dest");
        $A.util.toggleClass(btn, "slds-hide");
        location.reload();
        $A.createComponent(
            "c:oneLeave", {
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
    datePicker: function(component, event, helper) {
        
        var action = component.get("c.getHolid");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Holidays", response.getReturnValue());
                var holid = component.get("v.Holidays");
                var action = component.get("c.getAccounts");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.newLeave", response.getReturnValue());
                        var AllData = component.get("v.newLeave");
                        var ikarray = [];
                        for (var i = 0; i < AllData.length; i++) {
                            for (var j = 0; j < AllData[i].ERP7__Duration__c; j++) {
                               var ddd = AllData[i].ERP7__Leave_Start_Date__c;
                                var date2Block = new Date(ddd);
                                date2Block.setDate(date2Block.getDate() + j);
                                date2Block.setHours(0);
                                date2Block.setMinutes(0);
                                date2Block.setSeconds(0);
                                ikarray.push(date2Block);
                            }
                        }
                        for (var i = 0; i < holid.length; i++) {
                            var ddd = holid[i].ERP7__Date_Of_Holiday__c;
                            var date2Block = new Date(ddd);
                            date2Block.setHours(0);
                            date2Block.setMinutes(0);
                            date2Block.setSeconds(0);
                            ikarray.push(date2Block);
                        }
                        $(component.find("StrDate").getElement()).datepicker({
                            changeMonth: true,
                            changeYear: true,
                            showAnim: 'slide',
                            minDate: "-3M",
                            maxDate: "+9M",
                            beforeShowDay: function(dt) {
                                var iklogic = ikarray.length;
                                var str = jQuery.datepicker.formatDate('yy-mm-dd', dt);
                                var existk = true;
                                for (var i = 0; i < iklogic; i++) {
                                    var dater = new Date(dt);
                                    var datei = new Date(ikarray[i]);
                                    var dd = dater.toString();
                                    var ii = datei.toString();
                                    if (dd == ii) {
                                        existk = false;
                                        break;
                                    }
                                }
                                return [existk];
                            },
                            onSelect: function(selected) {
                            	//$(component.find("EndDate").getElement()).datepicker("option", "minDate", selected);
                            }
                        });
                        $(component.find("EndDate").getElement()).datepicker({
                            changeMonth: true,
                            changeYear: true,
                            showAnim: 'slide',
                            minDate: "-3M",
                            maxDate: "+9M",
                            beforeShowDay: function(dt) {
                                var iklogic = ikarray.length;
                            	var str = jQuery.datepicker.formatDate('yy-mm-dd', dt);
                                var existk = true;
                                for (var i = 0; i < iklogic; i++) {
                                    
                                    var dater = new Date(dt);
                                    var datei = new Date(ikarray[i]);
                                    var dd = dater.toString();
                                    var ii = datei.toString();
                                    if (dd == ii) {
                                        existk = false;
                                        break;
                                    }
                                }
                                return [existk];
                            },
                            onSelect: function(selected) {
                            	//$(component.find("StrDate").getElement()).datepicker("option", "maxDate", selected);
                            }
                        });
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action);
        
        /*var action = component.get("c.getHolid");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Holidays", response.getReturnValue());
                var holid = component.get("v.Holidays");
                var action = component.get("c.getAccounts");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.newLeave", response.getReturnValue());
                        var AllData = component.get("v.newLeave");
                        var ikarray = [];
                        for (var i = 0; i < AllData.length; i++) {
                            for (var j = 0; j < AllData[i].ERP7__Duration__c; j++) {
                               var ddd = AllData[i].ERP7__Leave_Start_Date__c;
                                var date2Block = new Date(ddd);
                                date2Block.setDate(date2Block.getDate() + j);
                                date2Block.setHours(0);
                                date2Block.setMinutes(0);
                                date2Block.setSeconds(0);
                                ikarray.push(date2Block);
                            }
                        }
                        for (var i = 0; i < holid.length; i++) {
                            var ddd = holid[i].ERP7__Date_Of_Holiday__c;
                            var date2Block = new Date(ddd);
                            date2Block.setHours(0);
                            date2Block.setMinutes(0);
                            date2Block.setSeconds(0);
                            ikarray.push(date2Block);
                        }
                        $(component.find("StrDate").getElement()).datepicker({
                            changeMonth: true,
                            changeYear: true,
                            showAnim: 'slide',
                            minDate: "-3M",
                            maxDate: "+9M",
                            beforeShowDay: function(dt) {
                                var iklogic = ikarray.length;
                                var str = jQuery.datepicker.formatDate('yy-mm-dd', dt);
                                var existk = true;
                                for (var i = 0; i < iklogic; i++) {
                                    var dater = new Date(dt);
                                    var datei = new Date(ikarray[i]);
                                    var dd = dater.toString();
                                    var ii = datei.toString();
                                    if (dd == ii) {
                                        existk = false;
                                        break;
                                    }
                                }
                                return [existk];
                            },
                            onSelect: function(selected) {
                            	$(component.find("EndDate").getElement()).datepicker("option", "minDate", selected);
                            }
                        });
                        $(component.find("EndDate").getElement()).datepicker({
                            changeMonth: true,
                            changeYear: true,
                            showAnim: 'slide',
                            minDate: "-3M",
                            maxDate: "+9M",
                            beforeShowDay: function(dt) {
                                var iklogic = ikarray.length;
                                var str = jQuery.datepicker.formatDate('yy-mm-dd', dt);
                                var existk = true;
                                for (var i = 0; i < iklogic; i++) {
                                    var dater = new Date(dt);
                                    var datei = new Date(ikarray[i]);
                                    var dd = dater.toString();
                                    var ii = datei.toString();
                                    if (dd == ii) {
                                        existk = false;
                                        break;
                                    }
                                }
                                return [existk];
                            },
                            onSelect: function(selected) {
                            	$(component.find("StrDate").getElement()).datepicker("option", "maxDate", selected);
                            }
                        });
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action);*/
    },
    
    populateDate: function(component, event, helper){
        
        try{
        
        var str = $(component.find("StrDate").getElement()).val();
        var end = $(component.find("EndDate").getElement()).val();
         if(str !='' && end !=''){
        function parseDate(str) {
    		var mdy = str.split('/');
    		return new Date(mdy[2], mdy[0]-1, mdy[1]);       
        }

		function daydiff(str, end) {
   		 return Math.round((end-str)/(1000*60*60*24)+1);
		}
        //if(totalNumber !='NaN' && totalNumber != undefined && totalNumber !='' && totalNumber !=0) 
             if(isNaN(daydiff(parseDate(str), parseDate(end)))==false) component.find("totalValue").set("v.value",daydiff(parseDate(str), parseDate(end)));
            }
            }catch(ex){} 
        },
    
    fetchLeaveTypeValues: function(component, event, helper){
        var leaveVar = component.find("leave").get("v.value");
        component.set("v.leaveType",leaveVar);
    },
    
    doInit: function(component, event, helper){
        var action = component.get("c.getLeaveTypes");
        var inputsel = component.find("leave");
        var opts = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                opts.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputsel.set("v.options", opts);
            component.set("v.leaveOptions",opts);
        });
        var approverAction = component.get("c.getApproverDetails");
        approverAction.setCallback(this, function(a) {
            if(a.getState()==="SUCCESS"){
                component.set("v.LeaveReqs.ERP7__Approvers__c",a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
        $A.enqueueAction(approverAction);
    }     
})