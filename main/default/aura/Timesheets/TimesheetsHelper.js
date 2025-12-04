({
    enableAllCheckboxes: function (checkboxes) {
        console.log('enableAllCheckboxes');
        checkboxes.forEach(function (checkbox) {
            console.log('checkbox');
            checkbox.set("v.disabled", false);
        });
    },
    recordCount: function (component, event) {
        var action = component.get("c.GetRecordCounts");
        action.setParams({
            strDate: component.get("v.selectedFY")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var counts = response.getReturnValue();
                const Thours = Math.floor(counts.numTimesheetSub / 60);
                const Tminutes = counts.numTimesheetSub % 60;
                var timeRes = (Thours < 10 ? "0" : "") + Thours + ":" + (Tminutes < 10 ? "0" : "") + Tminutes;
                counts.numTimesheetSub = timeRes;
                const Aphours = Math.floor(counts.numTimesheetApp / 60);
                const Apminutes = counts.numTimesheetApp % 60;
                var AptimeRes = (Aphours < 10 ? "0" : "") + Aphours + ":" + (Apminutes < 10 ? "0" : "") + Apminutes;
                counts.numTimesheetApp = AptimeRes;
                const Rphours = Math.floor(counts.numTimesheetRej / 60);
                const Rpminutes = counts.numTimesheetRej % 60;
                var RptimeRes = (Rphours < 10 ? "0" : "") + Rphours + ":" + (Rpminutes < 10 ? "0" : "") + Rpminutes;
                counts.numTimesheetRej = RptimeRes;
                counts.MyApprovalSub="00:00";
                    counts.MyApprovalApp="00:00";
                    counts.MyApprovalRej="00:00";
                component.set('v.counts', counts);
            }
        });
        $A.enqueueAction(action);
    },
    updateDateRange: function (component) {
        try {
            var selectedDateRange = component.get("v.selectedDateRange");
            var currentDate = new Date(component.get("v.DateVal")); // Current date
            component.set("v.DateString", '');
            switch (selectedDateRange) {
                case "Today":
                    if (this.formatDate(new Date()) == this.formatDate(currentDate)) {
                        component.set("v.DateString", 'Today');
                    } else {
                        component.set("v.DateString", this.formatDate(currentDate));
                    }
                    component.set("v.startDate", this.formatDate(currentDate));
                    component.set("v.endDate", this.formatDate(currentDate));
                    break;
                case "Yesterday":
                    var yesterday = new Date(currentDate);
                    yesterday.setDate(currentDate.getDate() - 1);
                    component.set("v.DateString", this.formatDate(yesterday));
                    component.set("v.startDate", this.formatDate(yesterday));
                    component.set("v.endDate", this.formatDate(yesterday));
                    break;
                case "ThisWeek":
                    var startOfWeek = new Date(currentDate);
                    startOfWeek.setDate(currentDate.getDate() - currentDate.getDay()); // Start of the week (Sunday)
                    var endOfWeek = new Date(startOfWeek);
                    endOfWeek.setDate(startOfWeek.getDate() + 6); // End of the week (Saturday)
                    component.set("v.startDate", this.formatDate(startOfWeek));
                    component.set("v.endDate", this.formatDate(endOfWeek));
                    break;
                case "LastWeek":
                    var startOfLastWeek = new Date(currentDate);
                    startOfLastWeek.setDate(currentDate.getDate() - currentDate.getDay() - 7);
                    var endOfLastWeek = new Date(startOfLastWeek);
                    endOfLastWeek.setDate(startOfLastWeek.getDate() + 6);
                    component.set("v.startDate", this.formatDate(startOfLastWeek));
                    component.set("v.endDate", this.formatDate(endOfLastWeek));
                    break;
                case "ThisMonth":
                    var startOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
                    var endOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
                    component.set("v.startDate", this.formatDate(startOfMonth));
                    component.set("v.endDate", this.formatDate(endOfMonth));
                    component.set("v.DateString", this.monthFormatDate(startOfMonth));
                    break;
                case "LastMonth":
                    var startOfLastMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1);
                    var endOfLastMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 0);
                    component.set("v.startDate", this.formatDate(startOfLastMonth));
                    component.set("v.endDate", this.formatDate(endOfLastMonth));
                    component.set("v.DateString", this.monthFormatDate(startOfLastMonth));
                    break;
                case "Custom":
                    var customStartDate = new Date(component.get("v.customStartDate"));
                    var customEndDate = new Date(component.get("v.customEndDate"));
                    component.set("v.startDate", this.formatDate(customStartDate));
                    component.set("v.endDate", this.formatDate(customEndDate));
                    break;
                default:
                    break;
            }
        } catch (e) {
            console.log(e);
        }
    },
    
    decreaseDateRange: function (component) {
        try {
            var selectedDateRange = component.get("v.selectedDateRange");
            var currentDate = new Date(); // Current date
            var DateVal = component.get("v.DateVal");
            console.log('DateVal' + DateVal);
            component.set("v.DateString", '');
            switch (selectedDateRange) {
                case "Today":
                    var today = new Date(DateVal);
                    today.setDate(today.getDate() - 1);
                    component.set("v.DateVal", today.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
                    if (this.formatDate(today) == this.formatDate(currentDate)) {
                        component.set("v.DateString", 'Today');
                    } else {
                        component.set("v.DateString", this.formatDate(today));
                    }
                    component.set("v.startDate", this.formatDate(today));
                    component.set("v.endDate", this.formatDate(today));
                    break;
                case "Yesterday":
                    var today = new Date(DateVal);
                    today.setDate(today.getDate() - 1);
                    component.set("v.DateVal", today.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
                    if (this.formatDate(today) == this.formatDate(currentDate)) {
                        component.set("v.DateString", 'Today');
                    } else {
                        component.set("v.DateString", this.formatDate(today));
                    }
                    component.set("v.startDate", this.formatDate(today));
                    component.set("v.endDate", this.formatDate(today));
                    break;
                case "ThisWeek":
                case "LastWeek":
                    var start = new Date(component.get("v.startDate"));
                    var end = new Date(component.get("v.endDate"));
                    
                    start.setDate(start.getDate() - 7);
                    end.setDate(end.getDate() - 7);
                    component.set("v.DateVal", start.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
                    component.set("v.startDate", this.formatDate(start));
                    component.set("v.endDate", this.formatDate(end));
                    break;
                case "ThisMonth":
                case "LastMonth":
                    var start = new Date(component.get("v.startDate"));
                    var end = new Date(component.get("v.endDate"));
                    
                    start.setMonth(start.getMonth() - 1);
                    end = new Date(start.getFullYear(), start.getMonth() + 1, 0);
                    component.set("v.DateVal", start.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
                    component.set("v.startDate", this.formatDate(start));
                    component.set("v.endDate", this.formatDate(end));
                    component.set("v.DateString", this.monthFormatDate(start));
                    break;
                case "Custom":
                    // Implement custom logic for handling custom date range
                    // Set startDate and endDate accordingly
                    break;
                default:
                    break;
            }
        } catch (e) {
            console.log(e);
        }
    },
    
    increaseDateRange: function (component) {
        try {
            var selectedDateRange = component.get("v.selectedDateRange");
            var currentDate = new Date(); // Current date
            var DateVal = component.get("v.DateVal");
            console.log('DateVal' + currentDate.getDate());
            component.set("v.DateString", '');
            switch (selectedDateRange) {
                case "Today":
                    var today = new Date(DateVal);
                    today.setDate(today.getDate() + 1);
                    component.set("v.DateVal", today.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
                    if (this.formatDate(today) == this.formatDate(currentDate)) {
                        component.set("v.DateString", 'Today');
                    } else {
                        component.set("v.DateString", this.formatDate(today));
                    }
                    component.set("v.startDate", this.formatDate(today));
                    component.set("v.endDate", this.formatDate(today));
                    break;
                case "Yesterday":
                    var today = new Date(DateVal);
                    today.setDate(today.getDate() + 1);
                    component.set("v.DateVal", today.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
                    if (this.formatDate(today) == this.formatDate(currentDate)) {
                        component.set("v.DateString", 'Today');
                    } else {
                        component.set("v.DateString", this.formatDate(today));
                    }
                    component.set("v.startDate", this.formatDate(today));
                    component.set("v.endDate", this.formatDate(today));
                    break;
                case "ThisWeek":
                case "LastWeek":
                    var start = new Date(component.get("v.startDate"));
                    var end = new Date(component.get("v.endDate"));
                    
                    start.setDate(start.getDate() + 7);
                    end.setDate(end.getDate() + 7);
                    component.set("v.DateVal", start.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
                    component.set("v.startDate", this.formatDate(start));
                    component.set("v.endDate", this.formatDate(end));
                    break;
                case "ThisMonth":
                case "LastMonth":
                    var start = new Date(component.get("v.startDate"));
                    var end = new Date(component.get("v.endDate"));
                    
                    start.setMonth(start.getMonth() + 1);
                    end = new Date(start.getFullYear(), start.getMonth() + 1, 0);
                    component.set("v.DateVal", start.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }));
                    component.set("v.startDate", this.formatDate(start));
                    component.set("v.endDate", this.formatDate(end));
                    component.set("v.DateString", this.monthFormatDate(start));
                    break;
                case "Custom":
                    // Implement custom logic for handling custom date range
                    // Set startDate and endDate accordingly
                    break;
                default:
                    break;
            }
        } catch (e) {
            console.log(e);
        }
    },
    
    formatDate: function (date) {
        var day = date.getDate();
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        
        var month = monthNames[date.getMonth()];
        var year = date.getFullYear();
        
        if (day < 10) {
            day = '0' + day;
        }
        
        return day + ' ' + month + ' ' + year;
    },
    ApexformatDate: function (date) {
        var inputDate = new Date(date);
        
        // Get the components of the date (year, month, day)
        var year = inputDate.getFullYear();
        var month = ("0" + (inputDate.getMonth() + 1)).slice(-2); // Months are zero-based
        var day = ("0" + inputDate.getDate()).slice(-2);
        
        // Create the formatted date string in "YYYY-MM-DD" format
        return year + "-" + month + "-" + day;
    },
    monthFormatDate: function (date) {
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        
        var month = monthNames[date.getMonth()];
        var year = date.getFullYear();
        
        return month + ' ' + year;
    },
    generateDateCells: function (component) {
        console.log('generateDateCells');
        var startDate = new Date(component.get("v.startDate"));
        var endDate = new Date(component.get("v.endDate"));
        var dateCells = [];
        component.set("v.dateCells", dateCells);
        console.log('startDate' + startDate);
        console.log('endDate' + endDate);
        while (startDate <= endDate) {
            dateCells.push({ formatDate: this.formatDateCell(startDate), actualDate: this.ApexformatDate(startDate) });
            startDate.setDate(startDate.getDate() + 1);
        }
        component.set("v.dateCells", dateCells);
    },
    
    formatDateCell: function (date) {
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var formattedDate = monthNames[date.getMonth()] + ' ' + this.padNumber(date.getDate()) + ' <br/> ' + this.getDayAbbreviation(date.getDay());
        return formattedDate;
    },
    
    padNumber: function (number) {
        return number < 10 ? '0' + number : number;
    },
    
    getDayAbbreviation: function (dayIndex) {
        var dayAbbreviations = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        return dayAbbreviations[dayIndex];
    },
    defaultRow: function (component) {
        var rowsLength = component.get("v.rowsLength");
        var rowsArray = [];
        
        for (var i = 0; i < rowsLength; i++) {
            rowsArray.push(i);
        }
        console.log('rowsArray' + JSON.stringify(rowsArray));
        // Set the array in the component attribute
        //component.set("v.rowsArray", rowsArray);
    },
    hideSpinner: function (component) {
        try {
            $A.util.addClass(component.find('spinner'), "slds-hide");
        } catch (e) {
            console.log('error ' + JSON.stringify(e));
            console.error(e);
        }
    },
    showSpinner: function (component) {
        $A.util.removeClass(component.find('spinner'), "slds-hide");
    },
    showToast: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent != undefined) {
            toastEvent.setParams({
                "mode": "dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }
    },
    calculateTotalHours: function (component) {
        console.log('calculateTotalHours called');
        var TSL = component.get("v.TimeSheetListWP");
        var TotalHours = 0;
        var AppHours = 0;
        var setTSL=false;
        for (let i = 0; i < TSL.TimeCardList.length; i++) {
            var TE = TSL.TimeCardList[i];
            var hhValue = TE.subhh;
            var mmValue = TE.submm;
            var time = hhValue + ":" + mmValue;
            const [hours, minutes] = time.split(':').map(Number);
            var totalMinutes = hours * 60 + minutes;
            TotalHours = TotalHours + totalMinutes;
            var newtotalmins=totalMinutes;
            if (TE.apphh) {
                var hhValue = TE.apphh;
                var mmValue = TE.appmm;
                if(mmValue==null || mmValue==''|| mmValue==undefined)mmValue="00";
                var time = hhValue + ":" + mmValue;
                const [hours, minutes] = time.split(':').map(Number);
                var totalMinutes = hours * 60 + minutes;
                AppHours = AppHours + totalMinutes;
            }var apphh; var appmm;
            /*if(TSL.TimeCardList[i].apphh<10) {
                apphh="0" + TSL.TimeCardList[i].apphh;
            }else apphh=TSL.TimeCardList[i].apphh;
            if(TSL.TimeCardList[i].appmm< 10) {
                appmm="0" + TSL.TimeCardList[i].appmm;
            }else appmm=TSL.TimeCardList[i].appmm;
            console.log('TSL.TimeCardList[i].subhh: ',Number(TSL.TimeCardList[i].subhh));
            console.log('apphh: ',Number(apphh));
            console.log('TSL.TimeCardList[i].submm: ',Number(TSL.TimeCardList[i].submm));
            console.log('appmm: ',Number(appmm));
            if(TSL.TimeCardList[i].subhh < apphh || (Number(TSL.TimeCardList[i].subhh) === Number(apphh) && TSL.TimeCardList[i].submm < appmm)){
                TSL.TimeCardList[i].apphh=TSL.TimeCardList[i].appmm="00";
                setTSL=true;
                this.showToast($A.get('$Label.c.error'), 'error', 'Approved Hours cannot be greater than submitted hours');
            }*/
            if(TSL.TimeCardList[i].apphh<10) {
                apphh="0" + TSL.TimeCardList[i].apphh;
            }else apphh=TSL.TimeCardList[i].apphh;
            if(TSL.TimeCardList[i].appmm< 10) {
                appmm="0" + TSL.TimeCardList[i].appmm;
            }else appmm=TSL.TimeCardList[i].appmm;
            if(appmm==undefined || appmm==null || appmm=='')appmm="00";
			var hhValue2 = apphh;
            var mmValue2 = appmm;
            var atime2 = hhValue2 + ":" + mmValue2;
            const [hours2, minutes2] = atime2.split(':').map(Number);
            var atotalMinutes2 = hours2 * 60 + minutes2;
            console.log('apphh: ',apphh);
            console.log('appmm: ',appmm);
            console.log('atotalMinutes2: ',atotalMinutes2);
            console.log('newtotalmins: ',newtotalmins);
            console.log('TSL.TimeCardList[i].subhh: ',TSL.TimeCardList[i].subhh);
            console.log('TSL.TimeCardList[i].submm: ',TSL.TimeCardList[i].submm);
            if(newtotalmins < atotalMinutes2){
                TSL.TimeCardList[i].apphh=TSL.TimeCardList[i].appmm="00";
                setTSL=true;
                this.showToast($A.get('$Label.c.error'), 'error', 'Approved Hours cannot be greater than submitted hours');
            }
        }
        if(setTSL) component.set("v.TimeSheetListWP", TSL);
        const Thours = Math.floor(TotalHours / 60);
        const Tminutes = TotalHours % 60;
        var timeRes = (Thours < 10 ? "0" : "") + Thours + ":" + (Tminutes < 10 ? "0" : "") + Tminutes;
        component.set("v.TotalHours", timeRes);
        const Aphours = Math.floor(AppHours / 60);
        const Apminutes = AppHours % 60;
        var AptimeRes = (Aphours < 10 ? "0" : "") + Aphours + ":" + (Apminutes < 10 ? "0" : "") + Apminutes;
        component.set("v.ApproveHours", AptimeRes);
    },
    calculateTotalHours2: function (component) {
        var TSL = component.get("v.TimeCardList");
        var TotalHours = 0;
        var AppHours = 0;
        for (let i = 0; i < TSL.length; i++) {
            var TE = TSL[i];
            var hhValue = TE.subhh;
            var mmValue = TE.submm;
            if(mmValue==null||mmValue==''||mmValue==undefined)mmValue="00";
            var time = hhValue + ":" + mmValue;
            const [hours, minutes] = time.split(':').map(Number);
            var totalMinutes = hours * 60 + minutes;
            TotalHours = TotalHours + totalMinutes;
            if (TE.apphh) {
                var hhValue = TE.apphh;
                var mmValue = TE.appmm;
                var time = hhValue + ":" + mmValue;
                const [hours, minutes] = time.split(':').map(Number);
                var totalMinutes = hours * 60 + minutes;
                AppHours = AppHours + totalMinutes;
            }
        }
        const Thours = Math.floor(TotalHours / 60);
        const Tminutes = TotalHours % 60;
        var timeRes = (Thours < 10 ? "0" : "") + Thours + ":" + (Tminutes < 10 ? "0" : "") + Tminutes;
        component.set("v.TotalHours", timeRes);
        const Aphours = Math.floor(AppHours / 60);
        const Apminutes = AppHours % 60;
        var AptimeRes = (Aphours < 10 ? "0" : "") + Aphours + ":" + (Apminutes < 10 ? "0" : "") + Apminutes;
        component.set("v.ApproveHours", AptimeRes);
    },
    getSheetandTimeCards: function (component, RecId) {
        try {
            component.set("v.showSpinner", true);
            var actionNew = component.get("c.getSheetandTimeCards");
            actionNew.setParams({
                TimeSheetId: RecId
            });
            actionNew.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var TSL = response.getReturnValue();
                    console.log('TSL' + JSON.stringify(TSL))
                    if (TSL.TimeSheet.ERP7__Approver__c == '' || TSL.TimeSheet.ERP7__Approver__c == null) TSL.TimeSheet.ERP7__Approver__c = component.get("v.emp.ERP7__Employee_User__r.ManagerId");
                    
                    var TotalHours = 0;
                    for (let i = 0; i < TSL.TimeCardList.length; i++) {
                        var TE = TSL.TimeCardList[i];
                        var TCardId = TE.Id;
                        if (TCardId != undefined && TCardId != null && TCardId != '') {
                            var totalMinutes = TE.ERP7__Working_Minutes__c;
                            totalMinutes = (totalMinutes == undefined || totalMinutes == null || totalMinutes == '') ? 0 : totalMinutes;
                            TotalHours = TotalHours + totalMinutes;
                            const hours = Math.floor(totalMinutes / 60);
                            const minutes = totalMinutes % 60;
                            var hoursHH = (hours < 10 ? "0" : "") + hours;
                            var minutesMM = (minutes < 10 ? "0" : "") + minutes;
                            TSL.TimeCardList[i].subhh = hoursHH;
                            TSL.TimeCardList[i].submm = minutesMM;
                            //TSL.TimeCardList[i].apphh = "";
                            //TSL.TimeCardList[i].appmm = "";
                            //if(!TE.ERP7__Approve_Minutes__c) TSL.TimeCardList[i].ERP7__Approve_Minutes__c = 0;
                        } else {
                            delete TSL.TimeCardList[i].ERP7__Schedule__c;
                        }
                    }
                    const Thours = Math.floor(TotalHours / 60);
                    const Tminutes = TotalHours % 60;
                    var timeRes = (Thours < 10 ? "0" : "") + Thours + ":" + (Tminutes < 10 ? "0" : "") + Tminutes;
                    console.log('TSL' + JSON.stringify(TSL));
                    component.set("v.TimeSheetListWP", TSL);
                    console.log('TSL' + JSON.stringify(component.get("v.TimeSheetListWP")));
                    component.set("v.TotalHours", timeRes);
                    component.set("v.ApproveHours", "00:00");
                    component.set("v.showSpinner", false);
                    if (component.get("v.TimeSheetListWP.TimeCardList.length") > 1) {
                        component.set("v.showCheckbox", true);
                    } else {
                        component.set("v.showCheckbox", false);
                    }
                    console.log('showCheckbox',component.get("v.showCheckbox"));
                } else {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        this.showToast($A.get('$Label.c.error'), 'error', errors[0].message);
                        console.log('response.getError()' + JSON.stringify(response.getError()));
                    }
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(actionNew);
        } catch (e) {
            component.set("v.showSpinner", false);
            console.log('error ' + JSON.stringify(e));
            console.error(e);
        }
    },
    saveSheetandTimeCard: function (component) {
        try {
            console.log('saveSheetandTimeCard');
            var errorinApprHrs=false;
            component.set("v.showSpinner", true);
            var TimeSheetListWP = component.get("v.TimeSheetListWP");
            var TimeSheet = TimeSheetListWP.TimeSheet;
            var TimeCards = TimeSheetListWP.TimeCardList;
            var ApprovalType = component.get("v.ApprovalType");
            for (var i = 0; i < TimeCards.length; i++) {
                var TimeCard = TimeCards[i];
                var ShhValue = TimeCard.subhh;
                var SmmValue = TimeCard.submm;
                var time = ShhValue + ":" + SmmValue;
                const [shours, sminutes] = time.split(':').map(Number);
                var totalMinutes = shours * 60 + sminutes;
                TimeCards[i].ERP7__Working_Minutes__c = totalMinutes;
                //if (TimeCard.subhh) delete TimeCards[i].subhh;
                //if (TimeCard.submm) delete TimeCards[i].submm;
                
                var hhValue = TimeCard.apphh;
                var mmValue = TimeCard.appmm;
                var atime = hhValue + ":" + mmValue;
                const [hours, minutes] = atime.split(':').map(Number);
                var atotalMinutes = hours * 60 + minutes;
                if (ApprovalType == 'Approved') TimeCards[i].ERP7__Approve_Minutes__c = atotalMinutes;
                //if (TimeCard.apphh) delete TimeCards[i].apphh;
                //if (TimeCard.appmm) delete TimeCards[i].appmm;
                console.log('TimeCard',TimeCard);
                console.log('TimeCard',JSON.stringify(TimeCard));
                if(TimeCard.ERP7__Approve_Minutes__c==0) {
                    this.showToast($A.get('$Label.c.error'), 'error', 'Please enter approved hours');
                    errorinApprHrs= true;
                }/*else{
                    if (TimeCard.subhh) delete TimeCards[i].subhh;
                    if (TimeCard.submm) delete TimeCards[i].submm;
                    if (TimeCard.apphh) delete TimeCards[i].apphh;
                    if (TimeCard.appmm) delete TimeCards[i].appmm;//thi
                }*/
            }
            if(errorinApprHrs==false){
                for (var i = 0; i < TimeCards.length; i++) {
                    var TimeCard = TimeCards[i];
                    if (TimeCard.subhh) delete TimeCards[i].subhh;
                    if (TimeCard.submm) delete TimeCards[i].submm;
                    if (TimeCard.apphh) delete TimeCards[i].apphh;
                    if (TimeCard.appmm) delete TimeCards[i].appmm;
                }
                var action = component.get("c.saveSheetandTimeCards");
                action.setParams({
                    tSheet: TimeSheet,
                    tCardList: JSON.stringify(TimeCards),
                    ApprovalType: ApprovalType,
                });
                action.setCallback(this, function (response) {
                    if (response.getState() === "SUCCESS") {
                        console.log('response' + response.getReturnValue());
                        console.log('response' + JSON.stringify(response.getReturnValue()));
                        this.showToast($A.get('$Label.c.Success'), 'success', `Time Sheet Successfully ${ApprovalType}`);
                        if (component.get("v.DrafSubTimeId")) {
                            component.set("v.DrafSubTimeId", "");
                            this.calledDrafSubTimeSheet(component);
                        } else if (component.get("v.MyApprTimeId")) {
                            component.set("v.MyApprTimeId", "");
                            this.calledMyApproval(component);
                        } else if (component.get("v.AdminTimeSheetId")) {
                            component.set("v.AdminTimeSheetId", "");
                            this.calledByEmp(component);
                        }
                        component.set("v.showSpinner", false);
                    } else {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            this.showToast($A.get('$Label.c.error'), 'error', errors[0].message);
                            console.log('response.getError()' + JSON.stringify(response.getError()));
                        }
                        component.set("v.showSpinner", false);
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                component.set("v.showSpinner", false);
            }
        } catch (e) {
            component.set("v.showSpinner", false);
            console.log('error' + JSON.stringify(e))
        }
        
    },
    saveSheetandTimeCard2: function (component) {
        try {
            console.log('saveSheetandTimeCard');
            var errorinApprHrs=false;
            component.set("v.showSpinner", true);
            //var TimeSheetListWP = component.get("v.TimeSheetListWP");
            var TimeSheet;
            var TimeCards;
            var ApprovalType = component.get("v.ApprovalType");
            if(component.get('v.editModal')===false){
                TimeSheet = component.get("v.timeSheet");
                TimeCards = component.get("v.TimeCardList");
            }else{
                var TimeSheetListWP = component.get("v.TimeSheetListWP");
                TimeSheet = TimeSheetListWP.TimeSheet;
                TimeCards = TimeSheetListWP.TimeCardList;
            }
            for (var i = 0; i < TimeCards.length; i++) {
                var TimeCard = TimeCards[i];
                var ShhValue = TimeCard.subhh;
                var SmmValue = TimeCard.submm;
                var time = ShhValue + ":" + SmmValue;
                const [shours, sminutes] = time.split(':').map(Number);
                var totalMinutes = shours * 60 + sminutes;
                TimeCards[i].ERP7__Working_Minutes__c = totalMinutes;
                //if (TimeCard.subhh) delete TimeCards[i].subhh;
                //if (TimeCard.submm) delete TimeCards[i].submm;
                
                var hhValue = TimeCard.apphh;
                var mmValue = TimeCard.appmm;
                var atime = hhValue + ":" + mmValue;
                const [hours, minutes] = atime.split(':').map(Number);
                var atotalMinutes = hours * 60 + minutes;
                if (ApprovalType == 'Approved') TimeCards[i].ERP7__Approve_Minutes__c = atotalMinutes;
                //if (TimeCard.apphh) delete TimeCards[i].apphh;
                //if (TimeCard.appmm) delete TimeCards[i].appmm;
                console.log('TimeCard',TimeCard);
                console.log('TimeCard',JSON.stringify(TimeCard));
                TimeCards[i].ERP7__Project__c=TimeSheet.ERP7__Project__c;
                if(TimeCard.ERP7__Approve_Minutes__c==0) {
                    this.showToast($A.get('$Label.c.error'), 'error', 'Please enter approved hours');
                    errorinApprHrs= true;
                }/*else{
                    if (TimeCard.subhh) delete TimeCards[i].subhh;
                    if (TimeCard.submm) delete TimeCards[i].submm;
                    if (TimeCard.apphh) delete TimeCards[i].apphh;
                    if (TimeCard.appmm) delete TimeCards[i].appmm;//thi
                }*/
            }
            if(errorinApprHrs==false){
                for (var i = 0; i < TimeCards.length; i++) {
                    var TimeCard = TimeCards[i];
                    if (TimeCard.subhh) delete TimeCards[i].subhh;
                    if (TimeCard.submm) delete TimeCards[i].submm;
                    if (TimeCard.apphh) delete TimeCards[i].apphh;
                    if (TimeCard.appmm) delete TimeCards[i].appmm;
                }
                var action = component.get("c.saveSheetandTimeCards");
                action.setParams({
                    tSheet: TimeSheet,
                    tCardList: JSON.stringify(TimeCards),
                    ApprovalType: ApprovalType,
                });
                action.setCallback(this, function (response) {
                    if (response.getState() === "SUCCESS") {
                        console.log('response' + response.getReturnValue());
                        console.log('response' + JSON.stringify(response.getReturnValue()));
                        this.showToast($A.get('$Label.c.Success'), 'success', `Time Sheet created successfully!`);
                        if (component.get("v.DrafSubTimeId")) {
                            component.set("v.DrafSubTimeId", "");
                            this.calledDrafSubTimeSheet(component);
                        } else if (component.get("v.MyApprTimeId")) {
                            component.set("v.MyApprTimeId", "");
                            this.calledMyApproval(component);
                        } else if (component.get("v.AdminTimeSheetId")) {
                            component.set("v.AdminTimeSheetId", "");
                            this.calledByEmp(component);
                        }
                        component.set("v.showSpinner", false);
                        component.set("v.editModal", true);
                    } else {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            this.showToast($A.get('$Label.c.error'), 'error', errors[0].message);
                            console.log('response.getError()' + JSON.stringify(response.getError()));
                        }
                        component.set("v.showSpinner", false);
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                component.set("v.showSpinner", false);
            }
        } catch (e) {
            component.set("v.showSpinner", false);
            console.log('error' + JSON.stringify(e))
        }
        
    },
    calledByEmp: function(component){
        try {
            component.set("v.showSpinner", true);
            component.set("v.showTabs", "Admin");
            component.set("v.MyApprTimeId", "");
            component.set("v.AdminTimeSheetId", "");
            component.set("v.DrafSubTimeId", "");
            var actionNew = component.get("c.getAllTimeSheets");
            actionNew.setParams({
                FiscalYearApproved: component.get("v.selectedFY"),
                EmployeeId: component.get("v.EmployeeId")
            });
            actionNew.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    console.log('response.getReturnValue()'+JSON.stringify(response.getReturnValue()))
                    var TimeSheets = response.getReturnValue();
                    for (var i = 0; i < TimeSheets.length; i++) {
                        var TimeSheet = TimeSheets[i];
                        var SubMinutes = TimeSheet.ERP7__Submitted_Minutes__c;
                        var AppMinutes = TimeSheet.ERP7__Approved_Minutes__c;
                        console.log('SubMinutes ' + SubMinutes);
                        console.log('AppMinutes ' + AppMinutes);
                        SubMinutes = (SubMinutes == undefined || SubMinutes == null || SubMinutes == '') ? 0 : SubMinutes;
                        const shours = Math.floor(SubMinutes / 60);
                        const sminutes = SubMinutes % 60;
                        var SubtimeRes = (shours < 10 ? "0" : "") + shours + ":" + (sminutes < 10 ? "0" : "") + sminutes;
                        TimeSheets[i].ERP7__Submitted_Minutes__c = SubtimeRes;
                        AppMinutes = (AppMinutes == undefined || AppMinutes == null || AppMinutes == '') ? 0 : AppMinutes;
                        const ahours = Math.floor(AppMinutes / 60);
                        const aminutes = AppMinutes % 60;
                        var ApptimeRes = (ahours < 10 ? "0" : "") + ahours + ":" + (aminutes < 10 ? "0" : "") + aminutes;
                        TimeSheets[i].ERP7__Approved_Minutes__c = ApptimeRes;
                    }
                    component.set("v.TimeSheetList", TimeSheets);
                    component.set("v.showSpinner", false);
                }else{
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        this.showToast($A.get('$Label.c.error'), 'error', errors[0].message);
                        console.log('response.getError()' + JSON.stringify(response.getError()));
                    }
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(actionNew);
        } catch (e) {
            component.set("v.showSpinner", false);
        }
    },
    calledMyApproval: function (component) {
        try {
            component.set("v.showSpinner", true);
            component.set("v.showTabs", "MyApproval");
            component.set("v.MyApprTimeId", "");
            component.set("v.DrafSubTimeId", "");
            component.set("v.AdminTimeSheetId", "");
            var actionNew = component.get("c.getSheetsToApprove");
            var countsubmittedhours=0;
            // actionNew.setParams({ });
            actionNew.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var TimeSheets = response.getReturnValue();
                    for (var i = 0; i < TimeSheets.length; i++) {
                        var TimeSheet = TimeSheets[i];
                        var SubMinutes = TimeSheet.ERP7__Submitted_Minutes__c;
                        console.log('SubMinutes ' + SubMinutes);
                        SubMinutes = (SubMinutes == undefined || SubMinutes == null || SubMinutes == '') ? 0 : SubMinutes;
                        const shours = Math.floor(SubMinutes / 60);
                        const sminutes = SubMinutes % 60;
                        var SubtimeRes = (shours < 10 ? "0" : "") + shours + ":" + (sminutes < 10 ? "0" : "") + sminutes;
                        TimeSheets[i].ERP7__Submitted_Minutes__c = SubtimeRes;
                        countsubmittedhours = countsubmittedhours + parseInt(SubMinutes);
                        console.log('countsubmittedhour for loop:',countsubmittedhours);
                    }
                    component.set("v.TimeSheetList", TimeSheets);
                    console.log('countsubmittedhour bfr:',countsubmittedhours);
                    const Thours = Math.floor(countsubmittedhours / 60);
                    const Tminutes = countsubmittedhours % 60;
                    console.log('Thours: ',Thours);
                    console.log('Tminutes: ',Tminutes);
                    var timeRes = (Thours < 10 ? "0" : "") + Thours + ":" + (Tminutes < 10 ? "0" : "") + Tminutes;
                    console.log('timeRes: ',timeRes);
                    countsubmittedhours = timeRes;
                    console.log('countsubmittedhours aftr:',countsubmittedhours);
                    var counts = component.get('v.counts');
                    counts.MyApprovalSub=countsubmittedhours;
                    counts.MyApprovalApp="00:00";
                    counts.MyApprovalRej="00:00";
                    component.set('v.counts', counts);
                    console.log('counts: ',component.get('v.counts'));
                    console.log('counts.MyApprovalSub: ',counts.MyApprovalSub);
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(actionNew);
            //this.recordCount(component, event);
        } catch (e) {
            component.set("v.showSpinner", false);
        }
    },
    calledApproRejTimeSheet: function (component) {
        try {
            component.set("v.showSpinner", true);
            component.set("v.showTabs", "ApproRejTimeSheet");
            component.set("v.MyApprTimeId", "");
            component.set("v.DrafSubTimeId", "");
            component.set("v.AdminTimeSheetId", "");
            var actionNew = component.get("c.getSheetsApproved");
            actionNew.setParams({
                FiscalYearApproved: component.get("v.selectedFY")
            });
            actionNew.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var TimeSheets = response.getReturnValue();
                    for (var i = 0; i < TimeSheets.length; i++) {
                        var TimeSheet = TimeSheets[i];
                        var SubMinutes = TimeSheet.ERP7__Submitted_Minutes__c;
                        var AppMinutes = TimeSheet.ERP7__Approved_Minutes__c;
                        console.log('SubMinutes ' + SubMinutes);
                        console.log('AppMinutes ' + AppMinutes);
                        SubMinutes = (SubMinutes == undefined || SubMinutes == null || SubMinutes == '') ? 0 : SubMinutes;
                        const shours = Math.floor(SubMinutes / 60);
                        const sminutes = SubMinutes % 60;
                        var SubtimeRes = (shours < 10 ? "0" : "") + shours + ":" + (sminutes < 10 ? "0" : "") + sminutes;
                        TimeSheets[i].ERP7__Submitted_Minutes__c = SubtimeRes;
                        AppMinutes = (AppMinutes == undefined || AppMinutes == null || AppMinutes == '') ? 0 : AppMinutes;
                        const ahours = Math.floor(AppMinutes / 60);
                        const aminutes = AppMinutes % 60;
                        var ApptimeRes = (ahours < 10 ? "0" : "") + ahours + ":" + (aminutes < 10 ? "0" : "") + aminutes;
                        TimeSheets[i].ERP7__Approved_Minutes__c = ApptimeRes;
                    }
                    component.set("v.TimeSheetList", TimeSheets);
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(actionNew);
            this.recordCount(component, event);
        } catch (e) {
            component.set("v.showSpinner", false);
        }
    },
    calledDrafSubTimeSheet: function (component) {
        try {
            component.set("v.showSpinner", true);
            component.set("v.showTabs", "DrafSubTimeSheet");
            component.set("v.MyApprTimeId", "");
            component.set("v.DrafSubTimeId", "");
            component.set("v.AdminTimeSheetId", "");
            var actionNew = component.get("c.getDrafSubTimeCards");
            actionNew.setParams({
                FiscalYear: component.get("v.selectedFY")
            });
            actionNew.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var TimeSheets = response.getReturnValue();
                    for (var i = 0; i < TimeSheets.length; i++) {
                        var TimeSheet = TimeSheets[i];
                        var SubMinutes = TimeSheet.ERP7__Submitted_Minutes__c;
                        console.log('SubMinutes ' + SubMinutes);
                        SubMinutes = (SubMinutes == undefined || SubMinutes == null || SubMinutes == '') ? 0 : SubMinutes;
                        const shours = Math.floor(SubMinutes / 60);
                        const sminutes = SubMinutes % 60;
                        var SubtimeRes = (shours < 10 ? "0" : "") + shours + ":" + (sminutes < 10 ? "0" : "") + sminutes;
                        TimeSheets[i].ERP7__Submitted_Minutes__c = SubtimeRes;
                    }
                    component.set("v.TimeSheetList", TimeSheets);
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(actionNew);
            this.recordCount(component, event);
        } catch (e) {
            component.set("v.showSpinner", false);
            console.log('err-> ' + e);
        }
    },
    saveSheetandTimeCard3: function (component,TimeSheet) {
        try {
            console.log('Inside SaveSheetandTimeCard3');
            console.log('TimeSheetList in helper: ',component.get("v.TimeCardList"));
            component.set("v.showSpinner", true);
            //var TimeSheet = component.get("v.timeSheet");
            var TimeCards = component.get("v.TimeCardList");
            var ApprovalType = component.get("v.ApprovalType");
            
            var action = component.get("c.saveSheetandTimeCards");
            action.setParams({
                tSheet: TimeSheet,
                tCardList: JSON.stringify(TimeCards),
                ApprovalType: ApprovalType,
            });
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    console.log('response' + response.getReturnValue());
                    console.log('response' + JSON.stringify(response.getReturnValue()));
                    this.showToast($A.get('$Label.c.Success'), 'success', `Time Sheet Successfully ${ApprovalType}`);
                    this.calledDrafSubTimeSheet(component);
                    component.set("v.showSpinner", false);
                    component.set("v.editModal", true);
                } else {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        this.showToast($A.get('$Label.c.error'), 'error', errors[0].message);
                        console.log('response.getError()' + JSON.stringify(response.getError()));
                    }
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);
            
        } catch (e) {
            component.set("v.showSpinner", false);
            console.log('error' + JSON.stringify(e))
        }
        
    },
})