({
    init: function (component, event, helper) {
        try {component.set("v.itemshow", true);
             component.set("v.editModal", true);
             component.set("v.DateVal", new Date().toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
             
             var action = component.get("c.getEmployees");
             action.setCallback(this, function (response) {
                 component.set("v.emp", response.getReturnValue());
                 //component.set('v.UserImageURL', response.getReturnValue().currUser.SmallPhotoUrl); 
                 component.set('v.isAdmin', component.get('v.emp.ERP7__Admin__c'));
                 component.set('v.multiUser', component.get('v.emp.ERP7__Admin__c'));
                 console.log('isAdmin: ',component.get('v.isAdmin'),' multiUser: ',component.get('v.multiUser'));
                 var appro = component.get("v.timeSheet.ERP7__Approver__c");
                 var approverlist = [];
                 var managerId = component.get("v.emp.ERP7__Employee_User__r.ManagerId");
                 var delegatedApproverId = component.get("v.emp.ERP7__Employee_User__r.DelegatedApproverId");
                 if (managerId) {
                     approverlist.push(managerId);
                 }
                 if (delegatedApproverId) {
                     approverlist.push(delegatedApproverId);
                 }
                 console.log('approverlist: ',approverlist);
                 var approverListStr = "('" + approverlist.join("','") + "')";
        		 component.set("v.approverList", approverListStr);
                 if ((component.get("v.multiUser")===false) && (appro == '' || appro == null)) {
                     if(component.get("v.emp.ERP7__Employee_User__r.ManagerId"))component.set("v.timeSheet.ERP7__Approver__c", component.get("v.emp.ERP7__Employee_User__r.ManagerId"));// ERP7__Employee_User__r.Manager.FirstName
                     else if(component.get("v.emp.ERP7__Employee_User__r.DelegatedApproverId"))component.set("v.timeSheet.ERP7__Approver__c", component.get("v.emp.ERP7__Employee_User__r.DelegatedApproverId"));// ERP7__Employee_User__r.Manager.FirstName
                 }
                 console.log('ERP7__Approver__c: ',component.get("v.timeSheet.ERP7__Approver__c"));
             });
             $A.enqueueAction(action);
             helper.updateDateRange(component);
             helper.generateDateCells(component);
             helper.defaultRow(component);
             helper.recordCount(component, event);
             
             var actionTCEStatus = component.get("c.getTCEStatus");
             actionTCEStatus.setCallback(this, function (response) {
                 component.set("v.TCEStatus", response.getReturnValue());
             });
             $A.enqueueAction(actionTCEStatus);
             
             var actionActiStatus = component.get("c.getActiStatus");
             actionActiStatus.setCallback(this, function (response) {
                 component.set("v.ActiStatus", response.getReturnValue());
             });
             $A.enqueueAction(actionActiStatus);
             
             var actionTSStatus = component.get("c.getTimeStatus");
             actionTSStatus.setCallback(this, function (response) {
                 component.set("v.TSStatus", response.getReturnValue());
             });
             $A.enqueueAction(actionTSStatus);
             
             var actionFC = component.get("c.getFunctionalityControl");
             actionFC.setCallback(this, function (response) {
                 component.set("v.FC", response.getReturnValue());
             });
             $A.enqueueAction(actionFC);
             
             var actionPIds = component.get("c.getProjectIds");
             actionPIds.setCallback(this, function (response) {
                 var state = response.getState();
                 if (state === "SUCCESS") {
                     var responseData = response.getReturnValue();
                     var qryString = `('${responseData.join("','")}')`;
                     console.log('qryString '+qryString);
                     component.set("v.projectIds", qryString);
                     console.log('component.get("v.projectIds")'+component.get("v.projectIds"));
                 } else {
                     console.log("Error fetching project IDs");
                 }
             });
             $A.enqueueAction(actionPIds);
            } catch (e) {
                console.log(e);
            }
    },
    calledTimeLog: function (component, event, helper) {
        component.set("v.showTabs", "TimeLog");
        component.set("v.rowsLength", 5);
        component.set("v.MyApprTimeId", "");
        component.set("v.DrafSubTimeId", "");
        component.set("v.AdminTimeSheetId", "");
        $A.enqueueAction(component.get("c.getTimeSheetAndEntries"));
        helper.recordCount(component, event);
    },
    
    calledDrafSubTimeSheet: function (component, event, helper) {
        helper.calledDrafSubTimeSheet(component);
    },
    
    onChange: function (component, event, helper) {
        $A.enqueueAction(component.get("c.calledDrafSubTimeSheet"));
    },
    
    ChangeApproved: function (component, event, helper) {
        $A.enqueueAction(component.get("c.calledApproRejTimeSheet"));
    },
    
    calledApproRejTimeSheet: function (component, event, helper) {
        helper.calledApproRejTimeSheet(component);
    },
    
    calledMyApproval: function (component, event, helper) {
        helper.calledMyApproval(component);
    },
    
    calledAdmin: function (component, event, helper) {
        component.set("v.showTabs", "Admin");
        if (component.get("v.EmployeeId") != '' && component.get("v.EmployeeId") != null) {
            helper.calledByEmp(component);
        } else {
            component.set("v.TimeSheetList", []);
        }
    },
    
    EditClick: function (component, event, helper) {
        var RecId = event.target.dataset.recordId;
        component.set("v.DrafSubTimeId", RecId);
        component.set("v.editModal", true);
        helper.getSheetandTimeCards(component, RecId);
    },
    
    EditMyApprClick: function (component, event, helper) {
        var RecId = event.target.dataset.recordId;
        component.set("v.MyApprTimeId", RecId);
        helper.getSheetandTimeCards(component, RecId);
    },
    
    EditAdminTimeSheetClick: function (component, event, helper) {
        var RecId = event.target.dataset.recordId;
        component.set("v.AdminTimeSheetId", RecId);
        helper.getSheetandTimeCards(component, RecId);
    },
    
    closeTimeDetails: function (component, event, helper) {
        if (component.get("v.DrafSubTimeId")) {
            component.set("v.DrafSubTimeId", "");
        } else if (component.get("v.MyApprTimeId")) {
            component.set("v.MyApprTimeId", "");
        } else if (component.get("v.AdminTimeSheetId")) {
            component.set("v.AdminTimeSheetId", "");
        }
    },
    
    handleDelClick: function (component, event, helper) {
        var result = confirm("Are you sure you want to delete this TimeSheet?");
        console.log('result : ',result);
        if (result) {
            console.log('event.target.dataset.recordId ' + event.target.dataset.recordId);
            var deleteAction = component.get("c.deleteAccount");
            deleteAction.setParams({
                "recordId": event.target.dataset.recordId
            });
            deleteAction.setCallback(this, function (response) {
                var recordId = response.getReturnValue();
                if (recordId == null) { } else {
                    var items = component.get("v.TimeSheetList");
                    items.splice(event.target.dataset.index, 1);
                    component.set("v.TimeSheetList", items);
                }
            });
            // Enqueue the action
            $A.enqueueAction(deleteAction);
        }
    },
    handleDelClickTimeLogs: function (component, event, helper) {
        console.log('Inside handleDelClickTimeLogs');
        var target = event.currentTarget;
        var index = target.dataset.index;
        console.log('timesheet id ' + index);
        var result = confirm("Are you sure you want to delete this TimeCardEntry?");
        console.log('result : ',result);
        if (result) {
            console.log('event.target.dataset.recordId ' + event.target.dataset.recordId);
            var deleteAction = component.get("c.deletetimeCard");
            deleteAction.setParams({
                "recordId": event.target.dataset.recordId,
                "tsheetId": index
            });
            deleteAction.setCallback(this, function (response) {
                var recordId = response.getReturnValue();
                if (recordId == null) { } else {
                    $A.enqueueAction(component.get("c.getTimeSheetAndEntries"));
                    //var items = component.get("v.TimeSheetList");
                    //items.splice(event.target.dataset.index, 1);
                    //component.set("v.TimeSheetList", items);
                }
            });
            $A.enqueueAction(deleteAction);
        }
        
    },
    
    decreaseDate: function (component, event, helper) {
        helper.decreaseDateRange(component);
        helper.generateDateCells(component);
        component.set("v.rowsLength", 5);
        $A.enqueueAction(component.get("c.getTimeSheetAndEntries"));
    },
    
    increaseDate: function (component, event, helper) {
        helper.increaseDateRange(component);
        helper.generateDateCells(component);
        component.set("v.rowsLength", 5);
        $A.enqueueAction(component.get("c.getTimeSheetAndEntries"));
    },
    
    handleDateRangeChange: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var selectedDateRange = component.get("v.selectedDateRange");
        component.set("v.showCustomRange", selectedDateRange === "Custom");
        helper.updateDateRange(component);
        helper.generateDateCells(component);
        component.set("v.rowsLength", 5);
        $A.enqueueAction(component.get("c.getTimeSheetAndEntries"));
    },
    filterSave: function (component, event, helper) {
        helper.updateDateRange(component);
        if (!component.get("v.showCustomRange")) {
            helper.generateDateCells(component);
        }
    },
    addRow: function (component, event, helper) {
        var multiUser = component.get("v.multiUser");
        var TimeDetails = component.get("v.TimeDetails");
        var dateCells = component.get("v.dateCells");
        var Employee = component.get("v.emp.Id");
        var timeCardList = [];
        for (var i = 0; i < dateCells.length; i++) {
            var targetDate = dateCells[i].actualDate;
            timeCardList.push({
                "Name": null,
                "ERP7__Week_Day_1__c": targetDate,
                "ERP7__Working_Minutes__c": "00:00",
                "ERP7__Schedule__c": null,
                "ERP7__Timesheet__c": null,
                "ERP7__Total_Hours__c": 0,
                "ERP7__Task__c": null,
                "ERP7__Activity_Risk__c": null,
            });
        }
        
        let resultItem = {
            "check": true,
            "TimeCardList": timeCardList,
            "TimeSheet": {
                "Id": null || '',
                "Name": '',
                "ERP7__Week_Date__c": '',
                "ERP7__Project__c": '',
                "ERP7__Employees__c": multiUser == false ? Employee : '',
                "ERP7__Approver__c": '',
                "ERP7__Status__c": 'Draft',
                "ERP7__Total_Hours__c": '',
                "ERP7__Project__r": '',
                "ERP7__Employees__r": '',
                "ERP7__Approver__r": '',
                "ERP7__Department__c": '',
                "ERP7__Programme__c": '',
            }
        };
        TimeDetails.push(resultItem);
        component.set("v.rowsLength", TimeDetails.length);
        component.set("v.TimeDetails", TimeDetails);
        
    },
    defRow: function (component, event, helper) {
        helper.defaultRow(component);
    },
    getTimeSheetAndEntries: function (component, event, helper) {
        console.log('getTimeSheetAndEntries');
        try {
            component.set("v.showSpinner", true);
            //var multiUser = component.get("v.multiUser");
            console.log('multiUser from getTimeSheetAndEntries',component.get("v.multiUser"));
            var StartDate = helper.ApexformatDate(component.get("v.startDate"));
            var EndDate = helper.ApexformatDate(component.get("v.endDate"));
            var rowLength = component.get("v.rowsLength");
            var actionNew = component.get("c.getTimeLogs");
            actionNew.setParams({
                startDate: StartDate,
                endDate: EndDate
            });
            actionNew.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var RespLen = response.getReturnValue().length;
                    var timeDetails = response.getReturnValue();
                    if (RespLen < rowLength) {
                        var looplen = rowLength - RespLen;
                        for (var i = 0; i < looplen; i++) {
                            timeDetails.push({
                                "check": true,
                                "TimeCardList": [],
                                "TimeSheet": {}
                            });
                        }
                    }
                    
                    let dateCells = component.get("v.dateCells");
                    let resultArray = [];
                    console.log('timeDetails' + JSON.stringify(timeDetails));
                    component.set("v.TimeDetails", resultArray);
                    var Employee = component.get("v.emp.Id");
                    var multiUser = component.get("v.multiUser");
                    console.log('multiUser after getTimeSheetAndEntries success',component.get("v.multiUser"));
                    for (let i = 0; i < timeDetails.length; i++) {
                        let TD = timeDetails[i];
                        let timeCardList = [];
                        
                        for (let j = 0; j < dateCells.length; j++) {
                            let dateCell = dateCells[j];
                            let targetDate = dateCell.actualDate;
                            let foundEntry = false;
                            console.log('TD.TimeCardList.length ' + TD.TimeCardList.length);
                            for (let k = 0; k < TD.TimeCardList.length; k++) {
                                let TE = TD.TimeCardList[k];
                                
                                if (targetDate === TE.ERP7__Week_Day_1__c) {
                                    var totalMinutes = TE.ERP7__Working_Minutes__c;
                                    console.log('totalMinutes ' + totalMinutes);
                                    totalMinutes = (totalMinutes == undefined || totalMinutes == null || totalMinutes == '') ? 0 : totalMinutes;
                                    const hours = Math.floor(totalMinutes / 60);
                                    const minutes = totalMinutes % 60;
                                    var timeRes = (hours < 10 ? "0" : "") + hours + ":" + (minutes < 10 ? "0" : "") + minutes;
                                    console.log('timeRes ' + timeRes);
                                    timeCardList.push({
                                        "Id": TE.Id,
                                        "Name": TE.Name,
                                        "ERP7__Week_Day_1__c": TE.ERP7__Week_Day_1__c,
                                        "ERP7__Schedule__c": TE.ERP7__Schedule__c,
                                        "ERP7__Working_Minutes__c": timeRes,
                                        // "ERP7__Activity_Status__c": TE.ERP7__Activity_Status__c,
                                        "ERP7__Timesheet__c": TE.ERP7__Timesheet__c,
                                        "ERP7__Total_Hours__c": TE.ERP7__Total_Hours__c,
                                        //  "ERP7__Week_Day_1_Comment__c": TE.ERP7__Week_Day_1_Comment__c,
                                        "ERP7__Task__c": TE.ERP7__Task__c,
                                        "ERP7__Activity_Risk__c": TE.ERP7__Activity_Risk__c,
                                        //"Time": timeRes,
                                    });
                                    foundEntry = true;
                                    break;
                                }
                            }
                            
                            if (!foundEntry) {
                                // Create a single object for the case when no entry is found
                                let emptyEntry = {
                                    "Name": null,
                                    "ERP7__Week_Day_1__c": targetDate,
                                    "ERP7__Working_Minutes__c": "00:00",
                                    "ERP7__Schedule__c": null,
                                    "ERP7__Timesheet__c": null,
                                    "ERP7__Total_Hours__c": 0,
                                    "ERP7__Task__c": null,
                                    "ERP7__Activity_Risk__c": null,
                                };
                                timeCardList.push(emptyEntry);
                            }
                        }
                        console.log('TD ' + JSON.stringify(TD));
                        console.log('TD.TimeSheet.ERP7__Employees__c ' + JSON.stringify(TD.TimeSheet.ERP7__Employees__c));
                        console.log('multiUser ' , multiUser, ' TD.TimeSheet.ERP7__Employees__c ',TD.TimeSheet.ERP7__Employees__c,' Employee ',Employee);
                        let resultItem = {
                            "check": TD.check,
                            "TimeCardList": timeCardList,
                            "TimeSheet": {
                                "Id": TD.TimeSheet.Id || '',
                                "Name": TD.TimeSheet.Name || '',
                                "ERP7__Week_Date__c": TD.TimeSheet.ERP7__Week_Date__c,
                                "ERP7__Project__c": TD.TimeSheet.ERP7__Project__c || '',
                                "ERP7__Employees__c": TD.TimeSheet.ERP7__Employees__c || multiUser == false ? Employee : '',
                                "ERP7__Approver__c": TD.TimeSheet.ERP7__Approver__c || '',
                                "ERP7__Status__c": TD.TimeSheet.ERP7__Status__c || 'Draft',
                                "ERP7__Total_Hours__c": TD.TimeSheet.ERP7__Total_Hours__c || '',
                                "ERP7__Project__r": TD.TimeSheet.ERP7__Project__r || '',
                                "ERP7__Employees__r": TD.TimeSheet.ERP7__Employees__r || '',
                                "ERP7__Approver__r": TD.TimeSheet.ERP7__Approver__r || '',
                                "ERP7__Department__c": TD.TimeSheet.ERP7__Department__c || '',
                                "ERP7__Programme__c": TD.TimeSheet.ERP7__Programme__c || '',
                            }
                        };
                        if(timeCardList.length > 0)resultArray.push(resultItem);
                    }
                    
                    component.set("v.rowsLength", resultArray.length);
                    component.set("v.TimeDetails", resultArray);
                    console.log('resultArray' + JSON.stringify(resultArray));
                    component.set("v.showSpinner", false);
                } else {
                    console.log('response.getError()' + response.getError());
                }
            });
            $A.enqueueAction(actionNew);
            
        } catch (e) {
            console.log(e);
        }
    },
    showPopup: function (component, event, helper) {
        try {
            console.log('showPopup');
            var popup = component.find('popup');
            var target = event.currentTarget;
            var index = target.dataset.index;
            var dateval = target.dataset.date;
            var popupDetail = target.dataset.show;
            component.set("v.popupDetail", popupDetail);
            console.log('popupDetail' + typeof component.get("v.popupDetail"));
            var tdElement = target.closest('td');
            
            if (tdElement) {
                var TopX = 0;
                var TopY = 0;
                var addedRow = 0;
                var rowsLength = component.get("v.rowsLength");
                var DateType = component.get("v.selectedDateRange");
                var IndexPlus = parseInt(index) + 1;
                if (DateType == "Today") {
                    if (rowsLength > 5) { rowsLength = rowsLength - 5; addedRow = 40 * rowsLength; }
                    TopX = 190 + addedRow + IndexPlus;
                    TopY = 314;
                } else if (DateType == "ThisWeek") {
                    if (rowsLength > 5) { rowsLength = rowsLength - 5; addedRow = 40 * rowsLength; }
                    TopX = 210 + addedRow + IndexPlus;
                    TopY = 314;
                } else if (DateType == "ThisMonth") {
                    if (rowsLength > 5) { rowsLength = rowsLength - 5; addedRow = 49 * rowsLength; }
                    TopX = 246 + addedRow;
                    TopY = 314;
                }
                
                var top = tdElement.offsetTop - TopX;
                var left = tdElement.offsetLeft - TopY;
                console.log('top' ,top);
                console.log('left' ,left);
                console.log('TopX' ,TopX);
                console.log('TopY' ,TopY);
                console.log('tdElement.offsetTop' ,tdElement.offsetTop);
                console.log('tdElement.offsetLeft' ,tdElement.offsetLeft);
                popup.getElement().style.top = top + 'px';
                popup.getElement().style.left = left + 'px';
                popup.getElement().style['z-index'] = 99;
                popup.getElement().style.width = '350px';
                popup.getElement().style['background-color'] = 'white';
                popup.getElement().position = 'absolute';
                popup.getElement().className = "slds-popover slds-nubbin_top-right";
                $A.util.removeClass(component.find("bdrop"), 'slds-hide');
            }
            component.set("v.modalVal", {});
            var TimeDetails = component.get("v.TimeDetails");
            let resultArray = {};
            var Time = "00:00";
            var existProj = "";
            var existEmp = "";
            for (let i = 0; i < TimeDetails.length; i++) {
                let TD = TimeDetails[i];
                let timeCard = {};
                if (index == i) {
                    for (let j = 0; j < TD.TimeCardList.length; j++) {
                        let TE = TD.TimeCardList[j];
                        if (dateval == TE.ERP7__Week_Day_1__c) {
                            Time = TE.ERP7__Working_Minutes__c || "00:00";
                            timeCard = {
                                "Id": TE.Id,
                                "Name": TE.Name || "",
                                "ERP7__Week_Day_1__c": TE.ERP7__Week_Day_1__c || dateval,
                                "ERP7__Working_Minutes__c": TE.ERP7__Working_Minutes__c,
                                //"ERP7__Activity_Status__c": TE.ERP7__Activity_Status__c || "",
                                "ERP7__Timesheet__c": TE.ERP7__Timesheet__c || "",
                                "ERP7__Total_Hours__c": TE.ERP7__Total_Hours__c || 0,
                                // "ERP7__Week_Day_1_Comment__c": TE.ERP7__Week_Day_1_Comment__c || "",
                                "ERP7__Schedule__c": TE.ERP7__Schedule__c || "",
                                //"Time": Time,
                                "ERP7__Task__c": TE.ERP7__Task__c || "",
                                "ERP7__Activity_Risk__c": TE.ERP7__Activity_Risk__c || "",
                            };
                        }
                    }
                    existProj = TD.TimeSheet.ERP7__Project__c;
                    existEmp = TD.TimeSheet.ERP7__Employees__c;
                    resultArray = {
                        "check": TD.check,
                        "TimeCard": timeCard,
                        "TimeSheet": {
                            "Id": TD.TimeSheet.Id,
                            "Name": TD.TimeSheet.Name || '',
                            "ERP7__Week_Date__c": TD.TimeSheet.ERP7__Week_Date__c,
                            "ERP7__Project__c": TD.TimeSheet.ERP7__Project__c || '',
                            "ERP7__Employees__c": TD.TimeSheet.ERP7__Employees__c || '',
                            "ERP7__Approver__c": TD.TimeSheet.ERP7__Approver__c || '',
                            "ERP7__Status__c": TD.TimeSheet.ERP7__Status__c || '',
                            "ERP7__Total_Hours__c": TD.TimeSheet.ERP7__Total_Hours__c || '',
                            "ERP7__Project__r": TD.TimeSheet.ERP7__Project__r || '',
                            "ERP7__Employees__r": TD.TimeSheet.ERP7__Employees__r || '',
                            "ERP7__Approver__r": TD.TimeSheet.ERP7__Approver__r || '',
                            "ERP7__Department__c": TD.TimeSheet.ERP7__Department__c || '',
                            "ERP7__Programme__c": TD.TimeSheet.ERP7__Programme__c || '',
                        }
                    }
                }
            }
            var timeArray = Time.split(':');
            
            var hours = timeArray[0];
            var minutes = timeArray[1];
            if(Time == "00:00"){
                component.set("v.hh", null);
                component.set("v.mm", null);    
            }else{
                component.set("v.hh", hours);
                component.set("v.mm", minutes);  
            }
            component.set("v.existProj", existProj);
            component.set("v.existEmp", existEmp);
            console.log('existEmp'+ existEmp);
            component.set("v.modalVal", resultArray);
            console.log('resultArray' + JSON.stringify(resultArray));
            console.log('modalVal' + JSON.stringify(component.get("v.modalVal")));
        } catch (e) {
            console.log(e);
        }
        
    },
    closeModal: function (component, event, helper) {
        var popup = component.find('popup');
        popup.getElement().className = 'slds-hide';
        $A.util.addClass(component.find("bdrop"), 'slds-hide');
    },
    onBlurhh: function (component, event, helper) {
        console.log('onBlurhh');
        try {
            console.log(event);
            var hhInput = event.getSource(); // This line may cause an error
            var hhValue = hhInput.get("v.value"); // Get the input value directly from the event
            console.log('hhValue' + hhValue);
            
            if (parseInt(hhValue) >= 24) {
                hhValue = parseInt(hhValue) % 24; // Wrap around 24 hours
            }
            
            if (hhValue == "") {
                hhValue = "00"; // Default to 00
            } else {
                if (parseInt(hhValue) < 10) {
                    hhValue = "0" + parseInt(hhValue); // Add leading zero
                }
            }
            
            hhInput.set("v.value", hhValue);
            if(component.get("v.editModal"))helper.calculateTotalHours(component);
            else helper.calculateTotalHours2(component);//helper.calculateTotalHours(component);
        } catch (e) {
            console.log(e);
        }
    },
    onBlurmm: function (component, event, helper) {
        try {
            var mmInput = event.getSource(); // Get the input component
            var mmValue = mmInput.get("v.value"); // Get the input value
            if (parseInt(mmValue) >= 60) {
                mmValue = parseInt(mmValue) % 60; // Wrap around 60 minutes
            }
            if (mmValue == "") {
                mmValue = "00"; // Default to 00
            } else {
                if (parseInt(mmValue) < 10) {
                    mmValue = "0" + parseInt(mmValue); // Add leading zero
                }
            }
            mmInput.set("v.value", mmValue);
            if(component.get("v.editModal"))helper.calculateTotalHours(component);
            else helper.calculateTotalHours2(component);//helper.calculateTotalHours(component);
        } catch (e) {
            console.log(e);
        }
    },
    onChangehh: function (component, event, helper) {
        console.log('handleHhInput');
        try {
            var hhInput = event.getSource(); // Get the input component
            var hhValue = hhInput.get("v.value"); // Get the input value
            hhInput.set("v.class", ""); // Remove the invalid or valid class
            var Index = hhInput.get("v.name");
            if (hhValue.length == 2) {
                // Move the focus to the next input
                var mmInput = component.find("mmitr"); // Find the mm input component
                if (mmInput) {
                    for (var i in mmInput) {
                        if (i == Index) {
                            mmInput[i].focus();
                        }
                    }
                } else {
                    component.find("mm1").focus();
                }
            }
            if(component.get("v.editModal"))helper.calculateTotalHours(component);
            else helper.calculateTotalHours2(component);
        } catch (e) {
            console.log(e);
        }
    },
    onChangemm: function (component, event, helper) {
        console.log('handleMmInput');
        try {
            var mmInput = event.getSource(); // Get the input component
            var mmValue = mmInput.get("v.value"); // Get the input value
            mmInput.set("v.class", ""); // Remove the invalid or valid class
            if (mmValue.length == 2) {
                console.log('handleMmI');
                mmInput.blur(); // Remove the focus
            }
            if(component.get("v.editModal"))helper.calculateTotalHours(component);
            else helper.calculateTotalHours2(component);//helper.calculateTotalHours(component);
        } catch (e) {
            console.log(e);
        }
    },
    getProjSchedule: function (component, event, helper) {
        var Proj = component.get('v.modalVal.TimeSheet.ERP7__Project__c');
        if (Proj == '' || Proj == null) component.set('v.modalVal.TimeCard.ERP7__Schedule__c', '');
    },
    getScheduleProj: function (component, event, helper) {
        component.set("v.ScdProjId", "");
        var SchId = component.get("v.modalVal.TimeCard.ERP7__Schedule__c");
        if (SchId != '' && SchId != null) {
            var action = component.get("c.get_CurrentValue");
            action.setParams({
                'type': 'ERP7__Schedule__c',
                'value': SchId,
                'SearchField': 'ERP7__Project__c'
            });
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    component.set("v.modalVal.TimeSheet.ERP7__Project__c", response.getReturnValue());
                    component.set("v.ScdProjId", response.getReturnValue());
                } else {
                    console.log('response.getError()' + JSON.stringify(response.getError()));
                }
            });
            $A.enqueueAction(action);
        }
    },
    saveTimeEntry: function (component, event, helper) {
        try {
            var hhValue = component.get("v.hh");
            var mmValue = component.get("v.mm");
            if(mmValue == null)mmValue="00";
            var time = hhValue + ":" + mmValue;
            const [hours, minutes] = time.split(':').map(Number);
            var totalMinutes = hours * 60 + minutes;
            var modalVal = component.get("v.modalVal");
            var TimeSheet = modalVal.TimeSheet;
            var TimeCard = modalVal.TimeCard;
            TimeCard.ERP7__Working_Minutes__c = totalMinutes;
            if (TimeSheet.ERP7__Week_Date__c == '' || TimeSheet.ERP7__Week_Date__c == null) {
                var currentDate = new Date(TimeCard.ERP7__Week_Day_1__c);
                var startOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
                TimeSheet.ERP7__Week_Date__c = startOfMonth;
            }
            var sheetMonth = new Date(TimeSheet.ERP7__Week_Date__c).getMonth() + 1; // Adding 1 since getMonth() returns values from 0 to 11
            var sheetYear = new Date(TimeSheet.ERP7__Week_Date__c).getFullYear();
            
            var cardEntryMonth = new Date(TimeCard.ERP7__Week_Day_1__c).getMonth() + 1;
            var cardEntryYear = new Date(TimeCard.ERP7__Week_Day_1__c).getFullYear();
            
            if (sheetMonth !== cardEntryMonth || sheetYear !== cardEntryYear) {
                helper.showToast($A.get('$Label.c.error'), 'error', 'Time Card is Last Moth and Time Entry is This Month so please created with new Project.');
                return;
            } else if (TimeSheet.ERP7__Project__c == '' || TimeSheet.ERP7__Project__c == null) {
                helper.showToast($A.get('$Label.c.error'), 'error', 'Please Select the Project.');
                return;
            } else if (totalMinutes == 0) {
                helper.showToast($A.get('$Label.c.error'), 'error', 'Time should be greater than a minute.');
                return;
            } else {
                TimeCard.ERP7__Project__c = TimeSheet.ERP7__Project__c;
                if (TimeSheet.Name == '' || TimeSheet.Name == null) TimeSheet.Name = 'TimeSheet (' + helper.monthFormatDate(new Date(TimeCard.ERP7__Week_Day_1__c)) + ')';
                if (TimeSheet.Id == '' || TimeSheet.Id == null) delete TimeSheet.Id;
                console.log('TimeSheet' + JSON.stringify(TimeSheet))
                console.log('TimeCard' + JSON.stringify(TimeCard))
                var action = component.get("c.saveTimeLogs");
                action.setParams({
                    tSheet: TimeSheet,
                    tCardEntry: TimeCard
                });
                action.setCallback(this, function (response) {
                    if (response.getState() === "SUCCESS") {
                        $A.util.addClass(component.find("bdrop"), 'slds-hide');
                        helper.showToast($A.get('$Label.c.Success'), 'success', 'Time Entry Created Successfully');
                        console.log('saveTimeLogs' + JSON.stringify(response.getReturnValue()));
                        component.set("v.rowsLength", 5);
                        
                        $A.enqueueAction(component.get("c.getTimeSheetAndEntries"));
                        var popup = component.find('popup');
                        popup.getElement().className = 'slds-hide';
                    } else {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            helper.showToast($A.get('$Label.c.error'), 'error', errors[0].message);
                            console.log('response.getError()' + JSON.stringify(response.getError()));
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        } catch (e) {
            console.log(e);
        }
    },
    submitForApproval: function (component, event, helper) {
        var TimeSheet;
        var TimeCardList;
        if(component.get("v.editModal")) {
            TimeSheet = component.get("v.TimeSheetListWP.TimeSheet");
            TimeCardList = component.get("v.TimeSheetListWP.TimeCardList");   
        }else{
            TimeSheet = component.get("v.timeSheet");
            TimeCardList = component.get("v.TimeCardList"); 
            let today = new Date(); 
            let todayDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());
            TimeSheet.ERP7__Week_Date__c= todayDate;
            if(component.get("v.multiUser")===false)TimeSheet.ERP7__Employees__c = component.get("v.emp.Id") ;
        }
        
        if (TimeSheet.ERP7__Project__c == null || TimeSheet.ERP7__Project__c == '') {
            helper.showToast('Error', 'error', 'Please select a Project');
            return;
        } else if (TimeSheet.ERP7__Approver__c == null || TimeSheet.ERP7__Approver__c == '') {
            helper.showToast('Error', 'error', 'Please select a Approver');
            return;
        }else if ((component.get("v.multiUser") && (component.get("v.editModal")===false) )&& (TimeSheet.ERP7__Employees__c == null || TimeSheet.ERP7__Employees__c == '')) {
            helper.showToast('Error', 'error', 'Please Select an Employee');
            return;
        }
        
        for (var i = 0; i < TimeCardList.length; i++) {
            var timeCard = TimeCardList[i];;
            if (timeCard.ERP7__Schedule__c == '' || timeCard.ERP7__Schedule__c == null) {
                //helper.showToast('Error', 'error', 'Please select a Scheduler');
                //return;
            }
        }
        component.set("v.ApprovalType", "Submitted");
        if(component.get("v.editModal")) helper.saveSheetandTimeCard(component);
        else helper.saveSheetandTimeCard2(component);
    },
    Approve: function (component, event, helper) {
        component.set("v.ApprovalType", "Approved");
        helper.saveSheetandTimeCard(component);
    },
    Reject: function (component, event, helper) {
        component.set("v.ApprovalType", "Rejected");
        helper.saveSheetandTimeCard(component);
    },
    checkAll: function (component, event, helper) {
        try {
            var dep = component.find("dependent");
            var mmInput = component.find("mmitr");
            var hhInput = component.find("hhitr");
            var TSL = component.get("v.TimeSheetListWP");
            for (var i = 0; i < dep.length; i++) {
                if (event.getSource().get("v.checked")) {
                    dep[i].set("v.checked", true);
                    TSL.TimeCardList[i].apphh = TSL.TimeCardList[i].subhh;
                    TSL.TimeCardList[i].appmm = TSL.TimeCardList[i].submm;
                    if (mmInput) { mmInput[i].set("v.disabled", true); } else { component.find("mm1").set("v.disabled", true); }
                    if (hhInput) { hhInput[i].set("v.disabled", true); } else { component.find("hh1").set("v.disabled", true); }
                } else {
                    dep[i].set("v.checked", false);
                    TSL.TimeCardList[i].apphh = "00";
                    TSL.TimeCardList[i].appmm = "00";
                    if (mmInput) { mmInput[i].set("v.disabled", false); } else { component.find("mm1").set("v.disabled", false); }
                    if (hhInput) { hhInput[i].set("v.disabled", false); } else { component.find("hh1").set("v.disabled", false); }
                }
            }
            component.set("v.TimeSheetListWP", TSL);
            helper.calculateTotalHours(component);
        } catch (e) {
            console.log('error', JSON.stringify(e));
            console.error(e);
        }
    },
    checkAsSubMin: function (component, event, helper) {
        try {
            var Index = event.getSource().get("v.name");
            var TSL = component.get("v.TimeSheetListWP");
            var mmInput = component.find("mmitr");
            var hhInput = component.find("hhitr");
            var mmInputField = mmInput != undefined && mmInput.length != undefined && mmInput.length > 0 ? mmInput[Index] : component.find("mm1");
            var hhInputField = mmInput != undefined && hhInput.length != undefined && hhInput.length > 0 ? hhInput[Index] : component.find("hh1");
            console.log(component.find("mm1"))
            console.log(component.find("hh1"))
            console.log(component.find("mmitr"))
            console.log(component.find("hhitr"))
            console.log(component.find("hht"))
            console.log(component.find("mmt"))
            console.log(event.getSource().get("v.checked"))
            if (event.getSource().get("v.checked")) {
                TSL.TimeCardList[Index].apphh = TSL.TimeCardList[Index].subhh;
                TSL.TimeCardList[Index].appmm = TSL.TimeCardList[Index].submm;
                //if (mmInput) { console.log('here'); mmInput[Index].set("v.disabled", true); } else { component.find("mm1").set("v.disabled", true); }
                //if (hhInput) { console.log('here'); hhInput[Index].set("v.disabled", true); } else { component.find("hh1").set("v.disabled", true); }
                mmInputField.set("v.disabled", true);
                hhInputField.set("v.disabled", true);
            } else {
                TSL.TimeCardList[Index].apphh = "00";
                TSL.TimeCardList[Index].appmm = "00";
                //if (mmInput) { mmInput[Index].set("v.disabled", false); } else { component.find("mm1").set("v.disabled", false); }
                //if (hhInput) { hhInput[Index].set("v.disabled", false); } else { component.find("hh1").set("v.disabled", false); }
                mmInputField.set("v.disabled", false);
                hhInputField.set("v.disabled", false);
            }
            
            if (TSL.TimeCardList.length > 1) {
                var dep = component.find("dependent");
                var allChecked = true;
                for (let i = 0; i < TSL.TimeCardList.length; i++) {
                    if (dep[i] != undefined && !dep[i].get("v.checked")) {
                        allChecked = false;
                        break;
                    }
                }
                if (component.find("master")) component.find("master").set("v.checked", allChecked);
            }
            // else{
            //     var AptimeRes = TSL.TimeCardList[Index].subhh + ":" + TSL.TimeCardList[Index].submm;
            //     component.set("v.ApproveHours", AptimeRes);
            // }
            component.set("v.TimeSheetListWP", TSL);
            helper.calculateTotalHours(component);
        } catch (e) {
            console.log('error' + JSON.stringify(e));
            console.error(e)
        }
        
    },
    handleHhBlur: function (component, event, helper) {
        console.log('handleHhBlur');
        try {
            console.log(event);
            var hhInput = event.getSource(); // This line may cause an error
            var hhValue = hhInput.get("v.value"); // Get the input value directly from the event
            console.log('hhValue' + hhValue);
            
            if (parseInt(hhValue) >= 24) {
                hhValue = parseInt(hhValue) % 24; // Wrap around 24 hours
            }
            
            if (hhValue == "") {
                hhValue = "00"; // Default to 00
            } else {
                if (parseInt(hhValue) < 10) {
                    hhValue = "0" + parseInt(hhValue); // Add leading zero
                }
            }
            
            hhInput.set("v.value", hhValue);
        } catch (e) {
            console.log(e);
        }
    },
    // Handle the blur event of the mm input
    handleMmBlur: function (component, event, helper) {
        try {
            var mmInput = event.getSource(); // Get the input component
            var mmValue = mmInput.get("v.value"); // Get the input value
            if (parseInt(mmValue) >= 60) {
                mmValue = parseInt(mmValue) % 60; // Wrap around 60 minutes
            }
            if (mmValue == "") {
                mmValue = "00"; // Default to 00
            } else {
                if (parseInt(mmValue) < 10) {
                    mmValue = "0" + parseInt(mmValue); // Add leading zero
                }
            }
            mmInput.set("v.value", mmValue);
        } catch (e) {
            console.log(e);
        }
    },
    
    // Handle the input event of the hh input
    handleHhInput: function (component, event, helper) {
        console.log('handleHhInput');
        try {
            var hhInput = event.getSource(); // Get the input component
            var hhValue = hhInput.get("v.value"); // Get the input value
            hhInput.set("v.class", ""); // Remove the invalid or valid class
            if (hhValue.length == 2) {
                // Move the focus to the next input
                console.log('handleHhI');
                var mmInput = component.find("mm"); // Find the mm input component
                mmInput.focus(); // Set the focus
            }
        } catch (e) {
            console.log(e);
        }
    },
    
    // Handle the input event of the mm input
    handleMmInput: function (component, event, helper) {
        console.log('handleMmInput');
        try {
            var mmInput = event.getSource(); // Get the input component
            var mmValue = mmInput.get("v.value"); // Get the input value
            mmInput.set("v.class", ""); // Remove the invalid or valid class
            if (mmValue.length == 2) {
                console.log('handleMmI');
                mmInput.blur(); // Remove the focus
            }
        } catch (e) {
            console.log(e);
        }
    },
    toggle: function (component, event, helper) {
        var itemshow= component.get('v.itemshow');
        console.log('itemshow brf: ',itemshow);
        component.set('v.itemshow',!itemshow);
        console.log('itemshow aftr: ',component.get('v.itemshow'));
        
    },
    addNew: function (component, event, helper) {
        console.log('Inside addNew');
        component.set("v.DrafSubTimeId", 'New');
        component.set("v.editModal", false);
        console.log('editModal',component.get("v.editModal"));
        component.set("v.TotalHours", "00");
        component.set("v.ApprovalType", '');
        console.log('editModal',component.get("v.ApprovalType"));
        let today = new Date(); // Get today's date
        let todayDate = today.toISOString().split('T')[0];
        var emptyTimeSheet = {
            'sobjectType': 'Timesheet__c',
            'ERP7__Employees__c': '',
            'ERP7__Week_Date__c': '',
            'Name': '',
            'ERP7__Project__c':'',
            'unknown_custom_field': '',
            'unknown_custom_field': '',
            'ERP7__Status__c': 'Draft',
            'ERP7__Approver__c': ''
        };
        var name='Timesheet ('+todayDate+')';
        component.set("v.timeSheet.Name", name);
        var timeSheet= component.get("v.timeSheet");
        if(component.get("v.multiUser"))timeSheet.ERP7__Approver__c='';//component.set("v.timeSheet.ERP7__Approver__c",''); 
        timeSheet.ERP7__Project__c='';//component.set("v.timeSheet.ERP7__Project__c",''); 
        component.set("v.timeSheet",timeSheet);
        //component.set("v.timeSheet.ERP7__Project__c", null);
        var newTimeCard = {
            ERP7__Week_Day_1__c: todayDate,
            ERP7__Schedule__c: '',
            ERP7__Task__c: 'Bug Fix',
            ERP7__Activity_Risk__c: '',
            subhh:"",
            submm:"",
        };
        component.set("v.TimeCardList", newTimeCard);
        //component.set("v.timeSheet",null);
    },
    saveNew: function (component, event, helper) {
        console.log('Inside saveNew',component.get("v.timeSheet"));
        console.log('EmployeeId',component.get("v.emp.Id"));
        var TimeSheet = component.get("v.timeSheet");
        var TimeCardList = component.get("v.TimeCardList");
        //var saveSheetandTimeCard2 = component.get("v.TimeSheetListWP.TimeCardList");
        if (TimeSheet.ERP7__Project__c == null || TimeSheet.ERP7__Project__c == '') {
            helper.showToast('Error', 'error', 'Please select a Project');
            return;
        } else if (TimeSheet.ERP7__Approver__c == null || TimeSheet.ERP7__Approver__c == '') {
            helper.showToast('Error', 'error', 'Please select an Approver');
            return;
        }else if (TimeSheet.Name == null || TimeSheet.Name == '') {
            helper.showToast('Error', 'error', 'Please enter a Name');
            return;
        }else if (component.get("v.multiUser") && (TimeSheet.ERP7__Employees__c == null || TimeSheet.ERP7__Employees__c == '')) {
            helper.showToast('Error', 'error', 'Please Select an Employee');
            return;
        }
        //component.set("v.showSpinner", true);
        for (var i = 0; i < TimeCardList.length; i++) {
            var timeCard = TimeCardList[i];
            TimeCardList[i].ERP7__Project__c=TimeSheet.ERP7__Project__c;
            if (timeCard.ERP7__Schedule__c == '' || timeCard.ERP7__Schedule__c == null) {
                //helper.showToast('Error', 'error', 'Please select a Scheduler');
                //return;
            }
        }
        let today = new Date(); // Get today's date
        let todayDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());//new Date(today.getFullYear(), today.getMonth(), 1);
        TimeSheet.ERP7__Week_Date__c= todayDate;//new Date(vBillDate.getFullYear(), vBillDate.getMonth(), 1);//new Date(vBillDate.getFullYear() , (vBillDate.getMonth() , 1) ;
        if(component.get("v.multiUser")===false)TimeSheet.ERP7__Employees__c = component.get("v.emp.Id") ;
        component.set("v.timeSheet",TimeSheet);
        component.set("v.TimeCardList",TimeCardList);
        helper.saveSheetandTimeCard2(component);
        
    },
    saveEdit: function (component, event, helper) {
        console.log('Inside saveEdit');
        //console.log('EmployeeId',component.get("v.emp.Id"));
       // var TimeSheet = component.get("v.timeSheet");
        //var TimeCardList = component.get("v.TimeCardList");
        var TimeSheetListWP = component.get("v.TimeSheetListWP");
        var TimeSheet = TimeSheetListWP.TimeSheet;
        var TimeCardList = TimeSheetListWP.TimeCardList;
        console.log('Inside saveNew',TimeSheet.Id);
        //var saveSheetandTimeCard2 = component.get("v.TimeSheetListWP.TimeCardList");
        if (TimeSheet.ERP7__Project__c == null || TimeSheet.ERP7__Project__c == '') {
            helper.showToast('Error', 'error', 'Please select a Project');
            return;
        } else if (TimeSheet.ERP7__Approver__c == null || TimeSheet.ERP7__Approver__c == '') {
            helper.showToast('Error', 'error', 'Please select an Approver');
            return;
        }else if (TimeSheet.Name == null || TimeSheet.Name == '') {
            helper.showToast('Error', 'error', 'Please enter a Name');
            return;
        }else if (component.get("v.multiUser") && (TimeSheet.ERP7__Employees__c == null || TimeSheet.ERP7__Employees__c == '')) {
            helper.showToast('Error', 'error', 'Please Select an Employee');
            return;
        }
        //component.set("v.showSpinner", true);
        for (var i = 0; i < TimeCardList.length; i++) {
            var timeCard = TimeCardList[i];
            TimeCardList[i].ERP7__Project__c=TimeSheet.ERP7__Project__c;
            if (timeCard.ERP7__Schedule__c == '' || timeCard.ERP7__Schedule__c == null) {
                /*helper.showToast('Error', 'error', 'Please select a Scheduler');
                return;*/
            }
        }
        //let today = new Date(); // Get today's date
        //let todayDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());//new Date(today.getFullYear(), today.getMonth(), 1);
        //TimeSheet.ERP7__Week_Date__c= todayDate;//new Date(vBillDate.getFullYear(), vBillDate.getMonth(), 1);//new Date(vBillDate.getFullYear() , (vBillDate.getMonth() , 1) ;
        //if(component.get("v.multiUser")===false)TimeSheet.ERP7__Employees__c = component.get("v.emp.Id") ;
        //component.set("v.timeSheet",TimeSheet);
        //component.set("v.TimeCardList",TimeCardList);
        helper.saveSheetandTimeCard2(component);
        
    },
    addNewTimeCard:  function (component, event, helper) {
        console.log('Inside TimeCardList');
        var TimeCardList = component.get("v.TimeCardList");
        for (var i = 0; i < TimeCardList.length; i++) {
            var timeCard = TimeCardList[i];;
            if (timeCard.ERP7__Schedule__c == '' || timeCard.ERP7__Schedule__c == null) {
                /*helper.showToast('Error', 'error', 'Please select a Scheduler');
                return;*/
            }
        }
        var currentDate = new Date();
        var year = currentDate.getFullYear();
        var month = (currentDate.getMonth() + 1).toString().padStart(2, '0');
        var day = currentDate.getDate().toString().padStart(2, '0');
        var formattedDate = `${day}-${month}-${year}`;
        let today = new Date(); // Get today's date
        let todayDate = today.toISOString().split('T')[0];
        //var TimeCardList=component.get("v.TimeCardList");
        var newTimeCard = {
            ERP7__Week_Day_1__c: todayDate,
            ERP7__Schedule__c: '',
            ERP7__Task__c: 'Bug Fix',
            ERP7__Activity_Risk__c: '',
            subhh:"",
            submm:"",
        };
        
        TimeCardList.push(newTimeCard);
        component.set("v.TimeCardList",TimeCardList);
    },
    handleDelNewLI:  function (component, event, helper) {
        var result = confirm("Are you sure you want to delete this Time card entry?");
        console.log('result : ',result);
        if (result) {
            console.log('Inside handleDelNewLI');
            var TimeCardList = component.get("v.TimeCardList");
            console.log('bfr TimeCardList: ',TimeCardList);
            var indexToDelete = event.target.dataset.index; 
            console.log('indexToDelete',indexToDelete);
            if (indexToDelete > -1 && indexToDelete < TimeCardList.length) {
                TimeCardList.splice(indexToDelete, 1);
            }
            component.set("v.TimeCardList", TimeCardList);
            console.log('aftr TimeCardList: ',TimeCardList);
        }
    },
    onChangeEmp:  function (component, event, helper) {
        if(component.get("v.timeSheet.ERP7__Employees__c")){
            console.log('Inside onChangeEmp');
            var action = component.get("c.getManagerId");
            action.setParams({
                Employees: component.get("v.timeSheet.ERP7__Employees__c")
            });
            console.log('Bfr setcallback');
            action.setCallback(this, function (response) {
                console.log('aftr setcallback');
                if (response.getState() === "SUCCESS") {
                    console.log('aftr success');
                    var resp = response.getReturnValue();
                    console.log('DelegatedApproverId: ', resp.ERP7__Employee_User__r.DelegatedApproverId);
					console.log('ManagerId: ', resp.ERP7__Employee_User__r.ManagerId);
                    if(response.getReturnValue())component.set("v.timeSheet.ERP7__Approver__c",response.getReturnValue().ERP7__Employee_User__r.ManagerId);  
                    var approverlist = [];
                    var managerId = resp.ERP7__Employee_User__r.ManagerId;
                    var delegatedApproverId = resp.ERP7__Employee_User__r.DelegatedApproverId
                    if (managerId) {
                        approverlist.push(managerId);
                    }
                    if (delegatedApproverId) {
                        approverlist.push(delegatedApproverId);
                    }
                    console.log('approverlist: ',approverlist);
                    var approverListStr = "('" + approverlist.join("','") + "')";
                    component.set("v.approverList", approverListStr);
                } else {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.showToast($A.get('$Label.c.error'), 'error', errors[0].message);
                        console.log('response.getError()' + JSON.stringify(response.getError()));
                    }
                }
            });
            $A.enqueueAction(action); 
        }
        
    },
    submitNew: function (component, event, helper) {
        console.log('Inside submitNew');
        //component.set("v.showSpinner", true);
        component.set("v.ApprovalType", "Submitted");
        var TimeSheetList= component.get("v.TimeSheetList");
        var TimeSheet;
        var RecId = event.target.dataset.recordId;
        console.log('RecId',RecId);
        for(var x=0; x<TimeSheetList.length; x++){
            console.log('Inside for ',x);
            if(RecId==TimeSheetList[x].Id){
                console.log('Inside If');
                TimeSheet=TimeSheetList[x];
                //TimeSheet.ERP7__Status__c='Submitted';
                console.log('TimeSheetList:',TimeSheet);
            }
        }
        var action = component.get("c.getTimeCardItems");
        action.setParams({
            tSheetId: TimeSheet.Id,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                console.log('response' , response.getReturnValue());
                component.set("v.TimeCardList",response.getReturnValue()); 
                console.log('TimeSheetList in controller: ',component.get("v.TimeCardList"));
                helper.saveSheetandTimeCard3(component,TimeSheet);
                //helper.showToast($A.get('$Label.c.Success'), 'success', `Time Sheet Successfully Approved!`);
                //helper.calledDrafSubTimeSheet(component);
                component.set("v.showSpinner", false);
            }else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    this.showToast($A.get('$Label.c.error'), 'error', errors[0].message);
                    console.log('response.getError()' + JSON.stringify(response.getError()));
                }
                component.set("v.showSpinner", false);
            }
        });$A.enqueueAction(action);
    }
})