({
    focusTOscan : function (component, event,helper) {
        component.set("v.scanValue",'');
        helper.focusTOscan(component, event);  
        
    },
    
    verifyScanCode : function (component, event, helper) {
        var scan_Code = component.get("v.scanValue");
        if(!$A.util.isEmpty(scan_Code)){
            var count = -1;
            var Tasks = component.get("v.Tasks");
            for(var x in Tasks){
                if(Tasks[x].ERP7__Barcode__c == scan_Code){
                    count = x;
                    break;
                }
            }
            if(count > -1){
                $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                var objsel = Tasks[count];
                var t = JSON.stringify(objsel);
                var action = component.get("c.SelectTasks"); 
                action.setParams({task:t});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.scanValue",'');
                        if(response.getReturnValue().errorMsg == ''){
                            try{
                                component.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                                component.set("v.Permit", response.getReturnValue().Permit);
                                component.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                                component.set("v.Busy",response.getReturnValue().Busy);
                                if(component.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && component.get("v.SelectedTask.ERP7__Status__c") == 'In-Progress'){
                                    var x = setInterval($A.getCallback(function() {
                                        var countDownDate = new Date(component.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c")).getTime();
                                        var now = new Date().getTime();
                                        var distance = now - countDownDate;
                                        
                                        // Time calculations for days, hours, minutes and seconds
                                        var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                                        var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                                        var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                                        var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                                        component.set("v.Timer",days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                                        
                                        if (distance < 0 || component.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In-Progress') {
                                            clearInterval(x);
                                            component.set("v.Timer","");
                                        } 
                                    }), 1000);
                                    
                                } else component.set("v.Timer","");
                                
                                component.set("v.signatureExist", false);
                                var selAttachs = component.get("v.SelectedAttachments");
                                for(var x in selAttachs){
                                    if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                        component.set("v.signatureExist", true);
                                    }
                                }
                                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                            } catch(err){ }
                        }
                        else component.set("v.errorMsg", response.getReturnValue().errorMsg);
                        
                    } else{
                        component.set("v.errorMsg", response.getError());
                    }
                });
                $A.enqueueAction(action);
            }
            else if(scan_Code === "Capture"){
                component.CaptureTheWeight();
            } else {
                var objm = component.get("v.MRPs");
                var objms = JSON.stringify(objm);
                //alert(scan_Code);
                var BarcodeAction = component.get("c.SearchScanCode");
                BarcodeAction.setParams({"scanCode":scan_Code,"MRPs": objms});
                BarcodeAction.setCallback(this,function(response){
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                       var obj = response.getReturnValue();
                        var ik = JSON.stringify(response.getReturnValue());
                        //alert(ik);
                        if(response.getReturnValue() != null){
                            component.set("v.scanValue",'');
                            var NewSOLI = component.get("v.NewSOLI");
                            //alert(JSON.stringify(NewSOLI));
                            //alert(obj.step);
                            //alert(obj.substep);
                            if(obj.step === "MO" && obj.substep === "Serial"){
                                NewSOLI.ERP7__MO_WO_Serial__c = obj.Serial.Id;
                                NewSOLI.ERP7__MO_WO_Serial__r = {Name:obj.Serial.Name,Id:obj.Serial.Id};
                                component.set("v.NewSOLI",NewSOLI);
                                //component.find("solisn").set("v.selectedRecordId", obj.Serial.Id);
                            }
                            else if(obj.step === "MO" && obj.substep === "Batch"){
                                //component.set("v.show",false);
                                NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c = obj.Batch.Id;
                                NewSOLI.ERP7__MO_WO_Material_Batch_Lot__r = {Name:obj.Batch.Name,Id:obj.Batch.Id};
                                component.set("v.NewSOLI",NewSOLI);
                                component.set("v.show",true);
                                //component.find("solibt").set("v.selectedRecordId", obj.Batch.Id);
                                //var h = component.find("solibt").getElements(); 
                                //alert(h);
                            }
                                else if(obj.step === "MRP" && obj.substep === "Serial"){
                                    NewSOLI.ERP7__Serial__c = obj.Serial.Id;
                                    NewSOLI.ERP7__Serial__r = {Name:obj.Serial.Name,Id:obj.Serial.Id};
                                    component.set("v.NewSOLI",NewSOLI);
                                    //component.find("solisni").set("v.selectedRecordId", obj.Serial.Id);
                                }
                                    else if(obj.step === "MRP" && obj.substep === "Batch"){
                                        NewSOLI.ERP7__Material_Batch_Lot__c = obj.Batch.Id;
                                        NewSOLI.ERP7__Material_Batch_Lot__r = {Name:obj.Batch.Name,Id:obj.Batch.Id};
                                        component.set("v.NewSOLI",NewSOLI);
                                        //component.find("solibti").set("v.selectedRecordId", obj.Batch.Id);
                                    }
                            var kNewSOLI = JSON.stringify(component.get("v.NewSOLI"));
                            //alert(kNewSOLI);
                        } 
                    }
                });
                $A.enqueueAction(BarcodeAction);
            }
        } 
    },
    
    handleSignatureEvent: function(cmp, event) {
        var Attachments = event.getParam("Attachments");
        //alert('Attachment ID==>'+Attachments.Id);
        //GetAllAttachments
        if(!cmp.get("v.IsSignatureTab")){
            var SelectedTask = cmp.get("v.SelectedTask");
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.GetAttachments"); 
            action.setParams({TaskId:SelectedTask.Id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                cmp.set("v.errorMsgPop", "");
                if (state === "SUCCESS") {
                    //cmp.popInit();
                    cmp.set("v.SelectedAttachments", response.getReturnValue());
                    cmp.set("v.signatureExist", false);
                    var selAttachs = cmp.get("v.SelectedAttachments");
                    for(var x in selAttachs){
                        if(selAttachs[x].ParentId == SelectedTask.Id && selAttachs[x].Name == 'Signature') cmp.set("v.signatureExist", true);
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } else{
                    cmp.set("v.errorMsgPop", response.getError());
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        } else{
            var WorkOrder = cmp.get("v.WorkOrder");
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.GetWOAttachments"); 
            action.setParams({WOId:WorkOrder.Id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                cmp.set("v.errorMsgPop", "");
                if (state === "SUCCESS") {
                    //cmp.popInit();
                    cmp.set("v.Signatures", response.getReturnValue());
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } else{
                    cmp.set("v.errorMsgPop", response.getError());
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    myAction : function(component, event, helper) {
        $(document).ready(function() {
            $("#pause").click(function() { 
                $(this).hide(); 
                $("#play").show();
                $("#aa").stop(true, false);
                //audioTag1.pause();
            });
            $("#play").click(function() {
                $(this).hide();
                $("#pause").show();
                //animateaa;
            });
        });
    },
    
    getAllDetails : function(cmp, event, helper) {
        var woId = cmp.get("v.WO");
        //alert(woId);
        var vrd = cmp.get("v.RD");
        var solid = cmp.get("v.soliID"); 
        var action = cmp.get("c.getAll");
        var countDownDate;
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        action.setParams({woId:woId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().errorMsg);
                //cmp.find("InputSelectDynamic").set("v.options", response.getReturnValue().Types);
                //cmp.find("status").set("v.options", response.getReturnValue().Statuses);
                cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                cmp.set("v.WorkOrder", response.getReturnValue().WorkOrder);
                cmp.set("v.ManuOrder", response.getReturnValue().manuOrders);
                cmp.set("v.UOMCs", response.getReturnValue().UOMCs);
                var obj = response.getReturnValue().MRPSSBW;
                for(var x in obj){ 
                    //if(obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs')
                    cmp.set("v.WeightCapture", true);
                    
                    var newUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure; 
                    var oldUOM = obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                    //var newUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure; 
                    //alert(oldUOM);
                    //alert(newUOM);
                    obj[x].WeightMultiplier = 1;
                    if(newUOM != '' && newUOM != undefined && oldUOM != '' && oldUOM != undefined && newUOM != oldUOM){
                        //alert('get converted value from custom settings and evaluate');
                        var UOMCs = cmp.get("v.UOMCs");
                        var conversionFound = false;
                        for(var k in UOMCs){
                            if((UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM) || (UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM)){
                                conversionFound = true;
                                if(UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM){
                                    obj[x].WeightMultiplier = UOMCs[k].ERP7__From_Value__c/UOMCs[k].ERP7__To_Value__c;
                                } else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM){
                                    obj[x].WeightMultiplier = UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c;
                                }
                            }
                        }
                    }
                }
                cmp.set("v.MRPs", obj);
                cmp.set("v.ReserveStock", response.getReturnValue().ReserveStock);
                cmp.set("v.Tasks", response.getReturnValue().Tasks);
                cmp.set("v.Task", response.getReturnValue().NewTask);
                cmp.set("v.Busy", response.getReturnValue().Busy);
                cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                cmp.set("v.Permit", response.getReturnValue().Permit);
                cmp.set("v.OperationAttachments", response.getReturnValue().OperationAttachmentsList);
                var urlAtt = '/servlet/servlet.FileDownload?file='+response.getReturnValue().SelectedAttachment.Id;
                cmp.set("v.attUrl", urlAtt);
                cmp.set("v.Employee", response.getReturnValue().Employee);
                //alert(urlAtt);
                cmp.set("v.Attachment", response.getReturnValue().SelectedAttachment);
                cmp.set("v.SelectedTask", response.getReturnValue().SelectedTask);
                cmp.set("v.NewTask", response.getReturnValue().NewTask);
                cmp.set("v.NewNote", response.getReturnValue().NewNote);
                cmp.set("v.NewNoteTemp", response.getReturnValue().NewNote);
                cmp.set("v.SelectedAttachments", response.getReturnValue().SelectedAttachments);
                cmp.set("v.signatureExist", false);

                var WOtasks = cmp.get("v.Tasks");
                for(var i in WOtasks){
                    if(WOtasks[i].ERP7__Status__c == "Completed"){
                        cmp.set("v.isWOcomplete", false);
                    }
                    else{
                        cmp.set("v.isWOcomplete", true);
                        break;
                    }
                }

                var selAttachs = cmp.get("v.SelectedAttachments");
                for(var x in selAttachs){
                    if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') cmp.set("v.signatureExist", true);
                }
                cmp.set("v.Signatures", response.getReturnValue().Signatures);
                cmp.set("v.SelectedNotes", response.getReturnValue().SelectedNotes);
                cmp.set("v.NewMRP", response.getReturnValue().NewMRP);
                cmp.set("v.NewSOLI",response.getReturnValue().NewSOLI);
                cmp.set("v.TimeSheet", response.getReturnValue().TimeSheet);
                cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                cmp.set("v.moSerialNos", response.getReturnValue().moSerialNos);
                cmp.set("v.moBatchNos", response.getReturnValue().moBatchNos);
                cmp.set("v.NWO", response.getReturnValue().nextWO);
                cmp.set("v.PWO", response.getReturnValue().prevWO);
                cmp.set("v.AllWOs", response.getReturnValue().AllWOs);
                
                cmp.set("v.WIPs", response.getReturnValue().WIPs);
                cmp.set("v.WIPFlows", response.getReturnValue().WIPFlows); 
                cmp.set("v.RAS", response.getReturnValue().RAS);
                cmp.set("v.WorkPlanners", response.getReturnValue().WorkPlanners); 
                if(response.getReturnValue().WorkOrder.ERP7__Start_Date__c != undefined) cmp.set("v.StartTime",response.getReturnValue().WorkOrder.ERP7__Start_Date__c); 
                if(response.getReturnValue().WorkOrder.ERP7__Expected_Date__c != undefined) cmp.set("v.EndTime",response.getReturnValue().WorkOrder.ERP7__Expected_Date__c); 
                cmp.set("v.CapacityPlanner", response.getReturnValue().CapacityPlanner);
                cmp.set("v.AvailableResources",response.getReturnValue().AvailableResources);
                //cmp.find("wpList").set("v.options", response.getReturnValue().wpList);
                //cmp.set("v.wpListOptions",response.getReturnValue().wpList);
                var OA = [];
                OA = cmp.get("v.OperationAttachments");
                var att = "";
                
                for(var i=0; i<OA.length; i++)
                {
                    att = OA[i].Attachments;
                    if(att.length > 0)
                        cmp.set("v.checkDrawings",true);
                }
                
                
                //var ik = cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c");
                //alert(ik);
                if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == "In-Progress"){
                    var x = setInterval($A.getCallback(function() {
                        var countDownDate = new Date(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c")).getTime();
                        var now = new Date().getTime();
                        var distance = now - countDownDate;
                        
                        // Time calculations for days, hours, minutes and seconds
                        var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                        var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                        var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                        var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                        cmp.set("v.Timer", days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                        if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In-Progress') {
                            clearInterval(x);
                            cmp.set("v.Timer","");
                        } 
                    }), 1000);
                } 
                // ExpectedDuration And RealDuration
                if(cmp.get("v.WorkOrder.ERP7__Planned_Date_From__c") != undefined && cmp.get("v.WorkOrder.ERP7__Planned_Date_To__c") != undefined){
                    var countDownDate = new Date(cmp.get("v.WorkOrder.ERP7__Planned_Date_From__c")).getTime();
                    var now = new Date(cmp.get("v.WorkOrder.ERP7__Planned_Date_To__c")).getTime();
                    var distance = now - countDownDate;
                    
                    // Time calculations for days, hours, minutes and seconds
                    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                    cmp.set("v.ExpectedDuration", days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                }
                if(cmp.get("v.WorkOrder.ERP7__Start_Date__c") != undefined && cmp.get("v.WorkOrder.ERP7__End_Date__c") != undefined){
                    var countDownDate = new Date(cmp.get("v.WorkOrder.ERP7__Start_Date__c")).getTime();
                    var now = new Date(cmp.get("v.WorkOrder.ERP7__End_Date__c")).getTime();
                    var distance = now - countDownDate;
                    
                    // Time calculations for days, hours, minutes and seconds
                    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                    cmp.set("v.RealDuration", days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                //document.getElementById("rot").classList.remove("erp-rotation");
                //document.getElementById("rot1").classList.remove("erp-rotation");
                //document.getElementById("weightspins").style.visibility = "hidden";
                //document.getElementById("mrpspins").style.visibility = "hidden";
                //document.getElementById("resourceSpins").style.visibility = "hidden";
            } else{
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                cmp.set("v.errorMsg", response.getError());
            }
        if(solid != null && solid != '' && solid != undefined){
            helper.getSOLIDetails(cmp, event, solid);
        }
        });
        $A.enqueueAction(action);        
    },
    
    ReloadAll : function(cmp, event, helper) {
        cmp.set("v.IsSignatureTab",false);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var woId = cmp.get("v.WO");
        //alert(woId);
        var vrd = cmp.get("v.RD");
        var action = cmp.get("c.getAll");
        var countDownDate;
        console.log("woId from reload: ",woId);
        action.setParams({woId:woId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().errorMsg);
                cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                cmp.set("v.WorkOrder", response.getReturnValue().WorkOrder);
                cmp.set("v.ManuOrder", response.getReturnValue().manuOrders);
                cmp.set("v.MRPs", response.getReturnValue().MRPSSBW);
                cmp.set("v.ReserveStock", response.getReturnValue().ReserveStock);
                cmp.set("v.Tasks", response.getReturnValue().Tasks);
                cmp.set("v.Task", response.getReturnValue().NewTask);
                cmp.set("v.NewMRP", response.getReturnValue().NewMRP);
                cmp.set("v.Busy", response.getReturnValue().Busy);
                //cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                cmp.set("v.Permit", response.getReturnValue().Permit);
                cmp.set("v.OperationAttachments", response.getReturnValue().OperationAttachmentsList);
                var urlAtt = '/servlet/servlet.FileDownload?file='+response.getReturnValue().SelectedAttachment.Id;
                cmp.set("v.attUrl", urlAtt);
                cmp.set("v.Employee", response.getReturnValue().Employee);
                //alert(urlAtt);
                cmp.set("v.Attachment", response.getReturnValue().SelectedAttachment);
                //cmp.set("v.SelectedTask", response.getReturnValue().SelectedTask);
                cmp.set("v.NewTask", response.getReturnValue().NewTask);
                cmp.set("v.TimeSheet", response.getReturnValue().TimeSheet);
                cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                //var ik = cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c");
                //alert(ik);
                if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == "In-Progress"){
                    var x = setInterval($A.getCallback(function() {
                        var countDownDate = new Date(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c")).getTime();
                        var now = new Date().getTime();
                        var distance = now - countDownDate;
                        
                        // Time calculations for days, hours, minutes and seconds
                        var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                        var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                        var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                        var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                        cmp.set("v.Timer", days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                        if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In-Progress') {
                            clearInterval(x);
                            cmp.set("v.Timer","");
                        } 
                    }), 1000);
                } 
                // ExpectedDuration And RealDuration
                if(cmp.get("v.WorkOrder.ERP7__Planned_Date_From__c") != undefined && cmp.get("v.WorkOrder.ERP7__Planned_Date_To__c") != undefined){
                    var countDownDate = new Date(cmp.get("v.WorkOrder.ERP7__Planned_Date_From__c")).getTime();
                    var now = new Date(cmp.get("v.WorkOrder.ERP7__Planned_Date_To__c")).getTime();
                    var distance = now - countDownDate;
                    
                    // Time calculations for days, hours, minutes and seconds
                    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                    cmp.set("v.ExpectedDuration", days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                }
                if(cmp.get("v.WorkOrder.ERP7__Start_Date__c") != undefined && cmp.get("v.WorkOrder.ERP7__End_Date__c") != undefined){
                    var countDownDate = new Date(cmp.get("v.WorkOrder.ERP7__Start_Date__c")).getTime();
                    var now = new Date(cmp.get("v.WorkOrder.ERP7__End_Date__c")).getTime();
                    var distance = now - countDownDate;
                    
                    // Time calculations for days, hours, minutes and seconds
                    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                    cmp.set("v.RealDuration", days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            } else{
                cmp.set("v.errorMsg", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    Reload1 : function (cmp, event) {
        //document.getElementById("rot1").classList.add("erp-rotation");
        cmp.popInit();
    },
    
    DeleteRecordRA: function(cmp, event) {
        var result = confirm("Are you sure?");
        var RecordId = event.getSource().get("v.name");
        if (result) {
            try{
                var action = cmp.get("c.DeleteRA");
                action.setParams({
                    RAId: RecordId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //cmp.popInit();
                        if(response.getReturnValue().errorMsg != '') cmp.set("v.errorMsg",response.getReturnValue().errorMsg);
                        else { 
                            cmp.popInit();
                        }
                    } else { 
                        cmp.set("v.errorMsg",response.getReturnValue().errorMsg); 
                    }
                });
                $A.enqueueAction(action);
            }
            catch(err) {
                //alert("Exception : "+err.message);
            }
        } 
    },
    
    DeleteRecordAT: function(cmp, event) {
        var result = confirm("Are you sure?");
        var RecordId = event.getSource().get("v.name");
        var ObjName = event.getSource().get("v.title");
        if (result) {
            try{
                var action = cmp.get("c.DeleteAT");
                action.setParams({
                    RAId: RecordId,
                    ObjName: ObjName
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //cmp.popInit();
                        if(response.getReturnValue().errorMsg != '') cmp.set("v.errorMsg",response.getReturnValue().errorMsg);
                        else { 
                            //cmp.popInit();
                            if(ObjName == 'Attachment'){
                                if(!cmp.get("v.IsSignatureTab")){
                                    var obj = cmp.get("v.SelectedAttachments");
                                    var count;
                                    for(var x in obj){
                                        if(obj[x].Id == RecordId) { 
                                            count = x;
                                        }
                                    }
                                    obj.splice(count, 1);
                                    cmp.set("v.SelectedAttachments",obj);
                                } else{
                                    var obj = cmp.get("v.Signatures");
                                    var count;
                                    for(var x in obj){
                                        if(obj[x].Id == RecordId) { 
                                            count = x;
                                        }
                                    }
                                    obj.splice(count, 1);
                                    cmp.set("v.Signatures",obj);
                                }
                            }
                            if(ObjName == 'Note'){
                                var obj = cmp.get("v.SelectedNotes");
                                var count;
                                for(var x in obj){
                                    if(obj[x].Id == RecordId) { 
                                        count = x;
                                    }
                                }
                                obj.splice(count, 1);
                                cmp.set("v.SelectedNotes",obj);
                            }
                            cmp.set("v.errorMsg","");
                        }
                    } else { 
                        cmp.set("v.errorMsg",response.getReturnValue().errorMsg); 
                    }
                });
                $A.enqueueAction(action);
            }
            catch(err) {
                //alert("Exception : "+err.message);
            }
        } 
    },
    
    openResourceAllocationModal: function(cmp, event) {
        $A.util.addClass(cmp.find("myResourceAllocationModal"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myResourceAllocationModalBackdrop"),"slds-backdrop_open");
    },
    
    closeResourceAllocationModal: function(cmp, event) {
        $A.util.removeClass(cmp.find("myResourceAllocationModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myResourceAllocationModalBackdrop"),"slds-backdrop_open");
    },
    
    lookupClickBatch :function(cmp,helper){
        var acc = undefined;
        var obj = cmp.get("v.MRPs"); 
        for(var x in obj){
            if(obj[x].isSelect) { 
                acc = obj[x].MRP.ERP7__MRP_Product__c;
            }
        }
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = ' And ERP7__Product__c = \''+acc+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
    },
    
    lookupClickSerial :function(cmp,helper){
        var acc = undefined;
        var obj = cmp.get("v.MRPs"); 
        for(var x in obj){
            if(obj[x].isSelect) { 
                acc = obj[x].MRP.ERP7__MRP_Product__c;
            }
        }
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = ' And ERP7__Product__c = \''+acc+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
    },
    
    lookupClickBatchFor :function(cmp,helper){
        var acc = undefined;
        var MO = cmp.get("v.ManuOrder");
        if(MO.ERP7__Product__c != undefined) acc = MO.ERP7__Product__c;
        
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' '; 
        else qry = ' And ERP7__Product__c = \''+acc+'\' And ERP7__Manufacturing_Order__c = \''+MO.Id+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
    },
    
    lookupClickSerialFor :function(cmp,helper){
        var acc = undefined;
        var MO = cmp.get("v.ManuOrder");
        if(MO.ERP7__Product__c != undefined) acc = MO.ERP7__Product__c;
        
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' '; 
        else qry = ' And ERP7__Product__c = \''+acc+'\' And ERP7__Manufacturing_Order__c = \''+MO.Id+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
    },
    
    NewTask : function(cmp, event, helper) {
        cmp.set("v.errorMsgPop", "");
        cmp.set("v.Task",cmp.get("v.NewTask"));
        cmp.set("v.Task.Name", "");
        $A.util.addClass(cmp.find("newTaskModal"),"slds-fade-in-open");
        $A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
    },
    
    NewNote : function(cmp, event, helper) {
        cmp.set("v.errorMsgPop", "");
        cmp.set("v.NewNote",cmp.get("v.NewNoteTemp"));
        cmp.set("v.NewNote.Title", "");
        cmp.set("v.NewNote.Body", "");
        cmp.set("v.NewNote.isPrivate", false);
        $A.util.addClass(cmp.find("newTaskNoteModal"),"slds-fade-in-open");
        $A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
    },
    
    UpdateCurrentTask : function(cmp, event, helper) {
        //$A.util.removeClass(cmp.find('TaskMenu'), 'slds-show');
        cmp.set("v.errorMsgPop", "");
        cmp.set("v.Task",cmp.get("v.SelectedTask"));
        $A.util.addClass(cmp.find("newTaskModal"),"slds-fade-in-open");
        $A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
    },
    
    ReloadNew : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find("newTaskModal"),"slds-fade-in-open");
        $A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
        $A.util.removeClass(cmp.find("newTaskNoteModal"),"slds-fade-in-open");
        /*
        var WOId = cmp.get("v.WorkOrder").Id;
        var rdm = cmp.get("v.RD");
        var navm = cmp.get("v.NAV");
        $A.createComponent("c:BuildSchedule_M",{
        "WO":WOId,"RD":rdm,"NAV":navm
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
        */
        //$A.get('e.force:refreshView').fire();
    },
    
    SaveTask : function(cmp, event, helper) {
        //alert('In');
        var Task = cmp.get("v.Task");
        var WO = cmp.get("v.WorkOrder");
        if(Task.ERP7__Finished_Quantity__c > WO.ERP7__Quantity_Ordered__c){
            cmp.set("v.errorMsgPop", "Finished Quantity cannot be greater than Quantity Ordered");
        } else{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var t = JSON.stringify(cmp.get("v.Task"));
            var action = cmp.get("c.SaveAction"); 
            action.setParams({task:t});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                cmp.set("v.errorMsgPop", "");
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        //document.getElementById("myModal2").classList.add("slds-hide");
                        //$('#myModal2').modal('hide');
                        $A.util.removeClass(cmp.find("newTaskModal"),"slds-fade-in-open");
                        $A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                    }
                    else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    console.log("Error : ", response.getError());
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    SaveNote : function(cmp, event, helper) {
        //alert('In');
        var NewNote = cmp.get("v.NewNote");
        var SelectedTask = cmp.get("v.SelectedTask");
        if(NewNote.Title == undefined || NewNote.Title == ""){
            cmp.set("v.errorMsgPop", "Required Field Missing");
        } else{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            NewNote.ParentId = SelectedTask.Id;
            var t = JSON.stringify(NewNote);
            //alert(t);
            var action = cmp.get("c.SaveNotes"); 
            action.setParams({NN:t});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                cmp.set("v.errorMsgPop", "");
                if (state === "SUCCESS") {
                    //document.getElementById("myModalNote").classList.add("slds-hide");
                    //$('#myModalNote').modal('hide');
                    //cmp.popInit();
                    $A.util.removeClass(cmp.find("newTaskNoteModal"),"slds-fade-in-open");
                    $A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
                    cmp.set("v.SelectedNotes", response.getReturnValue());
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } else{
                    cmp.set("v.errorMsgPop", response.getError());
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    GetAllAttachments : function(cmp, event, helper) {
        //alert('In');
        var SelectedTask = cmp.get("v.SelectedTask");
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.GetAttachments"); 
        action.setParams({TaskId:SelectedTask.Id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            cmp.set("v.errorMsgPop", "");
            if (state === "SUCCESS") {
                //cmp.popInit();
                cmp.set("v.SelectedAttachments", response.getReturnValue());
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            } else{
                cmp.set("v.errorMsgPop", response.getError());
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    TaskPlus : function(cmp, event, helper) {
        //alert('In');
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        cmp.set("v.Task",cmp.get("v.SelectedTask"));
        var taskplus = cmp.get("v.Task");
        taskplus.ERP7__Finished_Quantity__c += 1;
        var t = JSON.stringify(taskplus);
        //alert(t);
        var action = cmp.get("c.SaveAction"); 
        action.setParams({task:t});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    //cmp.set("v.SelectedTask.ERP7__Finished_Quantity__c",taskplus.ERP7__Finished_Quantity__c);
                    //cmp.popInit();
                    var obj = cmp.get("v.Tasks");
                    for(var x in obj){
                        if(obj[x].Id == taskplus.Id) { 
                            obj[x].ERP7__Finished_Quantity__c = taskplus.ERP7__Finished_Quantity__c;
                            break;
                        }
                    }
                    cmp.set("v.SelectedTask",taskplus);
                    cmp.set("v.Tasks",obj);
                }
                else cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.errorMsg", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    TaskMinus : function(cmp, event, helper) {
        //alert('In');
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        cmp.set("v.Task",cmp.get("v.SelectedTask"));
        var taskplus = cmp.get("v.Task");
        taskplus.ERP7__Finished_Quantity__c -= 1;
        var t = JSON.stringify(taskplus);
        var action = cmp.get("c.SaveAction"); 
        action.setParams({task:t});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    //cmp.set("v.SelectedTask.ERP7__Finished_Quantity__c",taskplus.ERP7__Finished_Quantity__c);
                    //cmp.popInit();
                    var obj = cmp.get("v.Tasks");
                    for(var x in obj){
                        if(obj[x].Id == taskplus.Id) { 
                            obj[x].ERP7__Finished_Quantity__c = taskplus.ERP7__Finished_Quantity__c;
                            break;
                        }
                    }
                    cmp.set("v.SelectedTask",taskplus);
                    cmp.set("v.Tasks",obj);
                }
                else cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.errorMsg", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    onFileUploaded : function(cmp, event, helper) {
        var files = cmp.get("v.FileList");  
        var totalRequestSize = 0; //
			for (var i = 0; i < files.length; i++) {
                var fileSize = files[i].base64Data.length;
                console.log('fileSize : ',fileSize);
                // Check individual file size (max 5 MB)
                if (fileSize > 2000000) { // 2 MB limit
                    helper.showToast('Error', 'error', 'File ' + filesDataToUpload[i].fileName + ' exceeds the 2 MB limit.');
                    return;
                }

                // Check total request size (max 6 MB)
                totalRequestSize += fileSize;
                console.log('totalRequestSize : ',totalRequestSize);
                if (totalRequestSize > 6000000) { // 6 MB total request size limit
                    helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                    return;
                }
            }
        var file = files[0][0];
        var filek = JSON.stringify(file);
        //alert(filek);
        var SelTask = cmp.get("v.SelectedTask");
        if (files && files.length > 0) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var reader = new FileReader();
            reader.onloadend = function() {
                var contents = reader.result;
                var base64Mark = 'base64,';
                var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                var fileContents = contents.substring(dataStart);
                
                var action = cmp.get("c.uploadFile");
                action.setParams({
                    parent: SelTask.Id,
                    fileName: file.name,
                    base64Data: encodeURIComponent(fileContents),
                    contentType: file.type
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        //alert(response.getReturnValue());
                        cmp.set("v.SelectedAttachments", response.getReturnValue());
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
            reader.readAsDataURL(file);
        }
    },
    
    SelectTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.currentTarget.getAttribute('data-mosoliId');
        var obj = cmp.get("v.Tasks");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
                break;
            }
        }
        var t = JSON.stringify(objsel);
        //cmp.set("v.SelectedTask.Id","");
        var action = cmp.get("c.SelectTasks"); 
        action.setParams({task:t});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    try{
                        cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                        //alert(response.getReturnValue().SelectedTask_TimeCardEntry.Id);
                        cmp.set("v.Permit", response.getReturnValue().Permit);
                        cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                        cmp.set("v.Busy",response.getReturnValue().Busy);
                        if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == 'In-Progress'){
                            var x = setInterval($A.getCallback(function() {
                                var countDownDate = new Date(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c")).getTime();
                                var now = new Date().getTime();
                                var distance = now - countDownDate;
                                
                                // Time calculations for days, hours, minutes and seconds
                                var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                                var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                                var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                                var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                                cmp.set("v.Timer",days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                                
                                if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In-Progress') {
                                    clearInterval(x);
                                    cmp.set("v.Timer","");
                                } 
                            }), 1000);
                            
                        } else cmp.set("v.Timer","");
                        
                        cmp.set("v.signatureExist", false);
                        var selAttachs = cmp.get("v.SelectedAttachments");
                        for(var x in selAttachs){
                            if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                cmp.set("v.signatureExist", true);
                            }
                        }
                        
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } catch(err){  }
                }
                else cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                
            } else{
                cmp.set("v.errorMsg", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    StartTimeCardEntry : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var task = cmp.get("v.SelectedTask");
        var t = JSON.stringify(task);
        var action = cmp.get("c.StartTimeCardEntrys"); 
        action.setParams({task:t});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                    cmp.set("v.Permit", response.getReturnValue().Permit);
                    cmp.set("v.Busy", true);
                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                    if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == 'In-Progress'){
                        var x = setInterval($A.getCallback(function() {
                            var countDownDate = new Date(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c")).getTime();
                            var now = new Date().getTime();
                            var distance = now - countDownDate;
                            
                            // Time calculations for days, hours, minutes and seconds
                            var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                            var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                            var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                            var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                            cmp.set("v.Timer",days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                            
                            if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In-Progress') {
                                clearInterval(x);
                                cmp.set("v.Timer","");
                            } 
                        }), 1000);
                    } else cmp.set("v.Timer","");
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
                else cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.errorMsg", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    StopTimeCardEntry : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var task = cmp.get("v.SelectedTask");
        var TCE = cmp.get("v.SelectedTask_TimeCardEntry");
        var t = JSON.stringify(task);
        var stce = JSON.stringify(TCE);
        var action = cmp.get("c.StopTimeCardEntrys"); 
        action.setParams({task:t, stce:stce});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                    cmp.set("v.Permit", response.getReturnValue().Permit);
                    cmp.set("v.Busy", response.getReturnValue().Busy);
                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                    cmp.set("v.Timer","");
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
                else cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.errorMsg", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    StopTimeCard : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var target = event.getSource();
        var count = target.getElement().parentElement.name;
        //alert(count);
        var obj = cmp.get("v.TimeCardEntries");
        var objsel;
        for(var x in obj){
            if(obj[x].Id == count) { 
                objsel = obj[x];
                break;
            }
        }
        var task = cmp.get("v.SelectedTask");
        var t = JSON.stringify(task);
        var stce = JSON.stringify(objsel);
        var action = cmp.get("c.StopTimeCardEntrys"); 
        action.setParams({task:t, stce:stce});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    cmp.popInit();
                }
                else cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.errorMsg", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    SelectAttachment : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var target = event.getSource();
        var count = target.getElement().parentElement.name;
        var par = target.getElement().parentElement.par;
        var obj = cmp.get("v.OperationAttachments");
        var objsel;
        for(var x in obj){
            if(x == par){
                for(var y in obj[x].Attachments){
                    if(y == count) { 
                        objsel = obj[x].Attachments[y];
                        break;
                    }
                }
            }
        }
        cmp.set("v.Attachment",objsel);
        var urlAtt = '/servlet/servlet.FileDownload?file='+objsel.Id;
        cmp.set("v.attUrl", urlAtt);
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },
    
    DeleteTask : function(cmp, event, helper) {
        if(confirm("Are you sure?")){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var Id = cmp.get("v.SelectedTask").Id;
            //alert('***test : '+Id);
            var action = cmp.get("c.DeleteAction"); 
            action.setParams({tId:Id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        //alert('popinit');
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.popInit();
                    }
                    else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                } else{
                    cmp.set("v.exceptionError", response.getError());
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
        }
    },
    
    StartTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.currentTarget.getAttribute('data-mosoliId');
        var obj = cmp.get("v.Tasks");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
                break;
            }
        }
        var Task = cmp.get("v.SelectedTask");
        if(Task.Id != objsel.Id) cmp.set("v.SelectedTask",objsel);
        Task = cmp.get("v.SelectedTask");
        var TimeSheet = cmp.get("v.TimeSheet");
        Task.ERP7__Status__c = "In-Progress";
        var WO = cmp.get("v.WorkOrder");
        var MRPS = cmp.get("v.MRPSS");
        var action = cmp.get("c.TaskUpdate"); 
        action.setParams({
            Task1: JSON.stringify(Task),
            WO1  : JSON.stringify(WO),
            MRPS1: JSON.stringify(MRPS)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                  //  alert("HERE...");
                    cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                    cmp.set("v.Tasks", response.getReturnValue().Tasks);
                    cmp.set("v.Busy", response.getReturnValue().Busy);
                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                    cmp.set("v.Permit", response.getReturnValue().Permit);
                    
                    if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == 'In-Progress'){
                        var x = setInterval($A.getCallback(function() {
                            var countDownDate = new Date(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c")).getTime();
                            var now = new Date().getTime();
                            var distance = now - countDownDate;
                            // Time calculations for days, hours, minutes and seconds
                            var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                            var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                            var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                            var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                            cmp.set("v.Timer",days + "d " + hours + "h "+ minutes + "m " + seconds + "s ");
                            //alert(distance);
                            if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In-Progress') {
                                clearInterval(x);
                                cmp.set("v.Timer","");
                            } 
                        }), 1000);
                        
                    } else cmp.set("v.Timer","");
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
                else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.exceptionError", response.getError());
            }
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    PauseTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.currentTarget.getAttribute('data-mosoliId');
        var obj = cmp.get("v.Tasks");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
                break;
            }
        }
        var Task = cmp.get("v.SelectedTask");
        if(Task.Id != objsel.Id) cmp.set("v.SelectedTask",objsel);
        Task = cmp.get("v.SelectedTask");
        var TimeSheet = cmp.get("v.TimeSheet");
        var WO = cmp.get("v.WorkOrder");
        var MRPS = cmp.get("v.MRPSS");
        Task.ERP7__Status__c = "On-Hold";
        var action = cmp.get("c.TaskUpdate"); 
        action.setParams({
            Task1 :JSON.stringify(Task),
            WO1   :JSON.stringify(WO),
            MRPS1 :JSON.stringify(MRPS)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                    cmp.set("v.Tasks", response.getReturnValue().Tasks);
                    cmp.set("v.Busy", response.getReturnValue().Busy);
                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                    cmp.set("v.Permit", response.getReturnValue().Permit);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
                else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.exceptionError", response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    PreFinishTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.currentTarget.getAttribute('data-mosoliId');
        var obj = cmp.get("v.Tasks");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
                break;
            }
        }
        cmp.set("v.SelectedTask",objsel);
        var Task = cmp.get("v.SelectedTask");
        var TimeSheet = cmp.get("v.TimeSheet");
        cmp.set("v.ToProduce",0)
        cmp.set("v.errorMsg","");
        cmp.set("v.errorMsgPop","");
        var WO = cmp.get("v.WorkOrder");
        //alert('In');
        var action = cmp.get("c.PreTaskFinish"); 
        action.setParams({Task1:JSON.stringify(Task)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    //cmp.set("v.MRPS",response.getReturnValue().MRPS);
                    cmp.set("v.MRPSS",response.getReturnValue().MRPSS);
                    cmp.set("v.Serial",response.getReturnValue().Serial);
                    cmp.set("v.Batch",response.getReturnValue().Batch);
                    if(response.getReturnValue().MRPS.length > 0){
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //$('#myModal3').modal('show');
                        //cmp.set("v.Evaluate",true);
                    } else{
                        //cmp.FinishMethod();
                        //WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Ordered__c;
                        var MRPS = cmp.get("v.MRPSS");
                        Task.ERP7__Status__c = "Completed";
                        var action = cmp.get("c.TaskUpdate"); 
                        action.setParams({
                            Task1 : JSON.stringify(Task),
                            WO1   : JSON.stringify(WO),
                            MRPS1 : JSON.stringify(MRPS)
                        });
                        action.setCallback(this, function(response){
                            var state = response.getState();
                            //alert(state);
                            if (state === "SUCCESS") {
                                if(response.getReturnValue().errorMsg == ''){
                                    cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                                    cmp.set("v.Tasks", response.getReturnValue().Tasks);
                                    cmp.set("v.Busy", response.getReturnValue().Busy);
                                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                                    cmp.set("v.Permit", response.getReturnValue().Permit);
                                    //task finished.
                                    var WOtasks = cmp.get("v.Tasks");
                                    for(var i in WOtasks){
                                        if(WOtasks[i].ERP7__Status__c == "Completed"){
                                            cmp.set("v.isWOcomplete", false);
                                        }
                                        else{
                                            cmp.set("v.isWOcomplete", true);
                                            break;
                                        }
                                    }
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    //$('#myModal3').modal('hide');
                                    //cmp.popInit();
                                }
                                else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            } else{
                                cmp.set("v.exceptionError", response.getError());
                            }
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        });
                        $A.enqueueAction(action);
                    }
                }
                else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            } else{
                cmp.set("v.exceptionError", response.getError());
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    
    PartialFinishTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var Task = cmp.get("v.SelectedTask");
        var WO = cmp.get("v.WorkOrder");
        var MRPS = cmp.get("v.MRPSS");
        var TimeSheet = cmp.get("v.TimeSheet");
        cmp.set("v.errorMsgPop", "");
        var error = false;
        var errorMrp = false;
        if(WO.ERP7__Quantity_Built__c > WO.ERP7__Quantity_Ordered__c){
            cmp.set("v.exceptionError", "Built quantity cannot be greater than ordered quantity");
            error = true;
        } 
        if(!error){
            for(var x in MRPS){
                if(MRPS[x].ERP7__Total_Amount_Required__c  < (MRPS[x].ERP7__Consumed_Quantity__c + MRPS[x].ERP7__Scrapped_Quantity__c)){
                    cmp.set("v.exceptionError", "Sum of consumed and scrapped quantity cannot be greater than total quantity");
                    error = true;
                }
            }
        }
        if(!error) {
            var action = cmp.get("c.TaskUpdatePartial"); 
            action.setParams({Task1:JSON.stringify(Task),WO1:JSON.stringify(WO),MRPS1:JSON.stringify(MRPS)});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                        cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                        cmp.set("v.Tasks", response.getReturnValue().Tasks);
                        cmp.set("v.Busy", response.getReturnValue().Busy);
                        cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                        cmp.set("v.Permit", response.getReturnValue().Permit);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        $('#myModal3').modal('hide');
                        //cmp.popInit();
                    }
                    else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                } else{
                    cmp.set("v.exceptionError", response.getError());
                }
            });
            $A.enqueueAction(action);
        }else{
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
    },
    
    FinishTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.currentTarget.getAttribute('data-mosoliId');
        var obj = cmp.get("v.Tasks");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
                break;
            }
        }
        cmp.set("v.SelectedTask",objsel);
        var Task = cmp.get("v.SelectedTask");
        var WO = cmp.get("v.WorkOrder");
        var MRPS = cmp.get("v.MRPSS");
        var TimeSheet = cmp.get("v.TimeSheet");
        cmp.set("v.exceptionError", "");
        var error = false;
        var errorMrp = false;
        if(WO.ERP7__Quantity_Built__c != WO.ERP7__Quantity_Ordered__c){
            cmp.set("v.exceptionError", "Built quantity should be equal to ordered quantity");
            error = true;
        } 
        if(!error){
            for(var x in MRPS){
                if(MRPS[x].ERP7__Total_Amount_Required__c  != (MRPS[x].ERP7__Consumed_Quantity__c + MRPS[x].ERP7__Scrapped_Quantity__c)){
                    cmp.set("v.exceptionError", "Sum of consumed and scrapped quantity should be equal to total quantity");
                    error = true;
                }
            }
        }
        if(!error) {
            Task.ERP7__Status__c = "Completed";
            var action = cmp.get("c.TaskUpdate"); 
            action.setParams({Task1:JSON.stringify(Task),WO1:JSON.stringify(WO),MRPS1:JSON.stringify(MRPS)});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                        cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                        cmp.set("v.Tasks", response.getReturnValue().Tasks);
                        cmp.set("v.Busy", response.getReturnValue().Busy);
                        cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                        cmp.set("v.Permit", response.getReturnValue().Permit);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //$('#myModal3').modal('hide');
                        //cmp.popInit();
                    }
                    else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                } else{
                    cmp.set("v.exceptionError", response.getError());
                }
            });
            $A.enqueueAction(action);
        }else{
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
    },
    
    CommitTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var Task = cmp.get("v.SelectedTask");
        var WO = cmp.get("v.WorkOrder");
        //var MRPS = cmp.get("v.MRPS");
        var MRPSS = cmp.get("v.MRPSS");
        var ToProduce = cmp.get("v.ToProduce");
        cmp.set("v.exceptionError", "");
        var error = false;
        var finish = true;
        //var eval = cmp.get("v.Evaluate");
        
        if(ToProduce == null || (WO.ERP7__Quantity_Built__c + ToProduce) > WO.ERP7__Quantity_Ordered__c){
            cmp.set("v.exceptionError", "Built quantity cannot be greater than ordered quantity or null");
            error = true;
        } 
        if(!error){
            for(var x in MRPSS){
                if(MRPSS[x].quantityToConsume == null || MRPSS[x].quantityToScrap == null){
                    cmp.set("v.exceptionError", "Required fields missing");
                    error = true;
                    break;
                }
                if(MRPSS[x].MRP.ERP7__Fulfilled_Amount__c < (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap)){
                    cmp.set("v.exceptionError", "Sum of consumed and scrapped quantity cannot be greater than fulfilled quantity");
                    error = true;
                    break;
                }
                if(MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && (MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap > 1)){
                    cmp.set("v.exceptionError", "Sum of consumed and scrapped quantity cannot be greater than one for Serialised product");
                    error = true;
                    break;
                }
                /*
                if((MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap) > 0 && (MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c || MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c) && MRPSS[x].Lot_Serial == ''){
                    cmp.set("v.exceptionError", "Lot/Serial Required");
                    error = true;
                    break;
                }
                */
            }
        }
        if(!error){
            for(var x in MRPSS){
                if(MRPSS[x].MRP.ERP7__Total_Amount_Required__c  != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap)){
                    finish = false;
                }
                MRPSS[x].MRP.ERP7__Consumed_Quantity__c = MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].quantityToConsume;
                MRPSS[x].MRP.ERP7__Scrapped_Quantity__c =  MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToScrap;
                
            }
            if((WO.ERP7__Quantity_Built__c + ToProduce) != WO.ERP7__Quantity_Ordered__c){
                finish = false;
            } 
            WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c + ToProduce;
        }
        if(finish && !error){
            Task.ERP7__Status__c = "Completed";
        }
        if(!error){
            var action = cmp.get("c.TaskUpdateNew");
            var MRPSSS = JSON.stringify(MRPSS);
            action.setParams({Task1:JSON.stringify(Task),WO1:JSON.stringify(WO),MRPSSS:MRPSSS});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                        cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                        cmp.set("v.Tasks", response.getReturnValue().Tasks);
                        cmp.set("v.WorkOrder", WO);
                        cmp.set("v.Busy", response.getReturnValue().Busy);
                        cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                        cmp.set("v.Permit", response.getReturnValue().Permit);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //cmp.set("v.Evaluate", false);
                        $('#myModal3').modal('hide');
                        //cmp.popInit();
                    }
                    else { 
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c - ToProduce;
                        for(var x in MRPSS){
                            MRPSS[x].MRP.ERP7__Consumed_Quantity__c = MRPSS[x].MRP.ERP7__Consumed_Quantity__c - MRPSS[x].quantityToConsume;
                            MRPSS[x].MRP.ERP7__Scrapped_Quantity__c =  MRPSS[x].MRP.ERP7__Scrapped_Quantity__c - MRPSS[x].quantityToScrap;
                        }
                        cmp.set("v.MRPSS", MRPSS);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c - ToProduce;
                    for(var x in MRPSS){
                        MRPSS[x].MRP.ERP7__Consumed_Quantity__c = MRPSS[x].MRP.ERP7__Consumed_Quantity__c - MRPSS[x].quantityToConsume;
                        MRPSS[x].MRP.ERP7__Scrapped_Quantity__c =  MRPSS[x].MRP.ERP7__Scrapped_Quantity__c - MRPSS[x].quantityToScrap;
                    }
                    cmp.set("v.MRPSS", MRPSS);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }else{
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        
    },
    
    ToProduceChange : function(cmp, event, helper) {
        var MRPSS = cmp.get("v.MRPSS");
        var ToProduce = cmp.get("v.ToProduce");
        var WO = cmp.get("v.WorkOrder");
        for(var x in MRPSS){
            if(WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) && MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) MRPSS[x].quantityToConsume = 1;
            else MRPSS[x].quantityToConsume = (WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c ))? (MRPSS[x].MRP.ERP7__Fulfilled_Amount__c*ToProduce)/WO.ERP7__Quantity_Ordered__c : 0;
        }
        cmp.set("v.MRPSS",MRPSS);
    },
    
    StopTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var Task = cmp.get("v.SelectedTask");
        var WO = cmp.get("v.WorkOrder");
        var MRPS = cmp.get("v.MRPSS");
        var TimeSheet = cmp.get("v.TimeSheet");
        //alert('***Task.ERP7__Start_Date__c : '+Task.ERP7__Start_Date__c);
        Task.ERP7__Status__c = "Cancelled";
        var action = cmp.get("c.TaskUpdate"); 
        action.setParams({
            Task1 : JSON.stringify(Task),
            WO1   : JSON.stringify(WO),
            MRPS1 : JSON.stringify(MRPS)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                    cmp.set("v.Tasks", response.getReturnValue().Tasks);
                    cmp.set("v.Busy", response.getReturnValue().Busy);
                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                    cmp.set("v.Permit", response.getReturnValue().Permit);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.popInit();
                }
                else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.exceptionError", response.getError());
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    
    CompleteTask : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var count = event.currentTarget.getAttribute('data-mosoliId');
        var obj = cmp.get("v.Tasks");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
                break;
            }
        }
        cmp.set("v.SelectedTask",objsel);
        var Task = cmp.get("v.SelectedTask");
        var WO = cmp.get("v.WorkOrder");
        var MRPS = cmp.get("v.MRPS");
        var TimeSheet = cmp.get("v.TimeSheet");
        //alert('***Task.ERP7__Start_Date__c : '+Task.ERP7__Start_Date__c);
        Task.ERP7__Status__c = "Completed";
        var action = cmp.get("c.TaskUpdate"); 
        action.setParams({Task1:JSON.stringify(Task),WO1:JSON.stringify(WO),MRPS1:JSON.stringify(MRPS)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == ''){
                    cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                    cmp.set("v.Tasks", response.getReturnValue().Tasks);
                    cmp.set("v.Busy", response.getReturnValue().Busy);
                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                    cmp.set("v.Permit", response.getReturnValue().Permit);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //cmp.popInit();
                }
                else cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
            } else{
                cmp.set("v.exceptionError", response.getError());
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    handlemenu: function(cmp,event,helper){
        var operation = event.detail.menuItem.get("v.title");
        if(operation == "MO"){
            helper.CreateMO(cmp,event,helper,event.detail.menuItem.get("v.value"));   
        } else{
        }
    },
    
    
    CreateMO : function(cmp, event, helper) { 
        var MRPId = event.currentTarget.getAttribute('data-mosoliId');
        var URL_RMA = '/apex/ERP7__ManufacturingOrderLC?mrpId='+MRPId;
        window.open(URL_RMA,'_self');
    },
    
    ReserveMRPStocks : function (cmp, event) {
        //document.getElementById("rot").classList.add("erp-rotation");
        var allMRPs = JSON.stringify(cmp.get("v.MRPs"));
        var action = cmp.get("c.ReserveMRPSStocks");
        action.setParams({
            MRPs: allMRPs
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                if(response.getReturnValue().errorMsg == '') {
                    cmp.popInit();
                }
                else {
                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg); 
                    //document.getElementById("rot").classList.remove("erp-rotation");
                }
            } else { cmp.set("v.exceptionError",response.getReturnValue().errorMsg); }
        });
        $A.enqueueAction(action);
    },
    
    CurrentSerialNumbers: function(cmp, event) {
        try{
            var count = event.getSource().get("v.name");
            var obj = cmp.get("v.MRPs"); 
            for(var x in obj){
                if(count == x) { 
                    cmp.set("v.mySerialNos",obj[x].SerialNos);
                    cmp.set("v.myBatchNos",[]);
                    break;
                }
            }
            window.scrollTo(0, 0);
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    CurrentBatchNumbers: function(cmp, event) {
        try{
            var count = event.getSource().get("v.name");
            var obj = cmp.get("v.MRPs"); 
            for(var x in obj){
                if(count == x) { 
                    cmp.set("v.myBatchNos",obj[x].Batches);
                    cmp.set("v.mySerialNos",[]);
                    break;
                }
            }
            window.scrollTo(0, 0);
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    NewMRP : function (cmp, event) {
        cmp.set("v.exceptionError","");
        var kk = cmp.get("v.NewMRP");
        if(kk.Name == null) kk.Name = "";
        kk.ERP7__BOM__c = "";
        kk.ERP7__Total_Amount_Required__c = "";
        kk.ERP7__Notes__c = "";
        //kk.ERP7__Consumed_Quantity__c = "";
        //kk.ERP7__Scrapped_Quantity__c = "";
        var ik = JSON.stringify(kk);
        //alert(ik);
        var WO = cmp.get("v.WorkOrder");
        kk.ERP7__Status__c = "Requested";
        kk.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
        if(WO.Id != undefined) kk.ERP7__Work_Order__c = WO.Id;
        kk.ERP7__Version__c = WO.ERP7__Version__c;
        //kk.ERP7__MRP_Product__c = WO.ERP7__Product__c;
        kk.ERP7__Work_Center__c  = WO.ERP7__Work_Center__c;
        kk.ERP7__MO__c = WO.ERP7__MO__c;
        cmp.set("v.NewMRP",kk);
        $A.util.addClass(cmp.find("myMRPModal"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
    },
    
    EditMRPOld : function (cmp, event) {
        cmp.set("v.exceptionError","");
        var count = event.getSource().get("v.name");
        //alert(count);
        var obj = cmp.get("v.MRPs");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count].MRP;
                var ik = JSON.stringify(objsel);
                //alert(ik);
            }
        }
        cmp.set("v.NewMRP",objsel);
    },
    
    updateMRP : function (cmp, event) {
        var MRP = cmp.get("v.NewMRP");
        var ik = JSON.stringify(MRP);
        //alert(ik);
        var error = false;
        if(MRP.Name == undefined || MRP.Name == "" || MRP.ERP7__BOM__c == undefined || MRP.ERP7__BOM__c == "" || MRP.ERP7__Total_Amount_Required__c == undefined || MRP.ERP7__Total_Amount_Required__c == "" || MRP.ERP7__MRP_Product__c == undefined || MRP.ERP7__MRP_Product__c == "") {
            error = true;
        } 
        if(!error){
            var action = cmp.get("c.MRPUpdate");
            action.setParams({
                MRP1 : JSON.stringify(MRP)
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    if(response.getReturnValue().errorMsg == ''){
                        $('#myModal9').modal('hide');
                        cmp.popInit();
                    } else document.getElementById("mrpspins").style.visibility = "hidden";
                }
                $A.util.removeClass(cmp.find("myMRPModal"), 'slds-fade-in-open');
                $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
            });
            $A.enqueueAction(action);
        } else{
            cmp.set("v.exceptionError","Required fields missing");
        }
    },
    
    SelectMRP: function(cmp, event) {
        try{
            var count = event.currentTarget.getAttribute('data-mrpcount');
            var obj = cmp.get("v.MRPs"); 
            var Fulfilled = true;
            cmp.set("v.WeightStr","0");
            for(var x in obj){
                if(count == x) { 
                    obj[x].isSelect = true;
                    if(obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true) cmp.set("v.WeightStr","1");
                    cmp.set("v.NewSOLI.ERP7__Serial__c", undefined);
                    cmp.set("v.NewSOLI.ERP7__Material_Batch_Lot__c",undefined);
                } else  obj[x].isSelect = false;
                if(obj[x].ActualWeight < obj[x].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
            }
            cmp.set("v.Fulfilled",Fulfilled);
            cmp.set("v.MRPs",obj);
            $A.util.addClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
            $A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    SelectMRP1: function(cmp, event) {
        try{
            var obj = cmp.get("v.MRPs"); 
            var TotalWeight = 0;
            var Fulfilled = true;
            cmp.set("v.WeightStr","0");
            for(var x in obj){
                if(0 == x) { 
                    obj[x].isSelect = true;
                    if(obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true) cmp.set("v.WeightStr","1");
                    cmp.set("v.NewSOLI.ERP7__Serial__c", undefined);
                    cmp.set("v.NewSOLI.ERP7__Material_Batch_Lot__c",undefined);
                } else  obj[x].isSelect = false;
                if(obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs') TotalWeight += obj[x].MRP.ERP7__Total_Amount_Required__c;
                if(obj[x].ActualWeight < obj[x].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
            }
            cmp.set("v.Fulfilled",Fulfilled); 
            cmp.set("v.MRPs",obj);
            cmp.set("v.TotalWeight",TotalWeight);
            $A.util.addClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
            $A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    SelectWIP: function(cmp, event) {
        try{
            var count = event.currentTarget.getAttribute('data-wipcount');
            var obj = cmp.get("v.WIPs"); 
            for(var x in obj){
                if(count == x) { 
                    cmp.set("v.SelectedWIP",obj[x]);
                } 
            }
            cmp.set("v.WIPs",obj);
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    UOMChange: function(cmp, event) { 
        try{
            cmp.set("v.exceptionError","");
            var obj = cmp.get("v.MRPs"); 
            for(var x in obj){
                if(obj[x].isSelect) {
                    obj[x].WeightMultiplier = 1;
                    obj[x].BOMWeightMultiplier = 1;
                    
                    var oldUOM = obj[x].SelectedUOM; 
                    var newUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
                    //var newUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
                    //var newUOM = obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;  
                    //var oldUOM = obj[x].SelectedUOM;
                    //alert(oldUOM); 
                    //alert(newUOM);
                    if(newUOM != '' && newUOM != undefined && oldUOM != '' && oldUOM != undefined && newUOM != oldUOM){
                        //alert('get converted value from custom settings and evaluate');
                        var UOMCs = cmp.get("v.UOMCs");
                        var conversionFound = false;
                        for(var k in UOMCs){
                            if((UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM) || (UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM)){
                                conversionFound = true;
                                if(UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM){
                                    obj[x].WeightMultiplier = UOMCs[k].ERP7__From_Value__c/UOMCs[k].ERP7__To_Value__c;
                                } else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM){
                                    obj[x].WeightMultiplier = UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c;
                                }
                                //document.getElementById("cardTransition").style.visibility = "hidden";
                                //document.getElementById("cardTransition").classList.add("cardTransition");
                                //document.getElementById("cardTransition").classList.add("cardTransitionClicked");
                                //obj[x].WeightMultiplier = Math.round(num * 100) / 100;
                                //alert(obj[x].WeightMultiplier);
                                break;
                            }
                        }
                        if(!conversionFound) {
                            var errMsgNew = "Conversion values between "+oldUOM+" and "+newUOM+" not found";
                            cmp.set("v.exceptionError",errMsgNew);
                            obj[x].SelectedUOM = newUOM; 
                            break;
                        }
                    }
                    
                    oldUOM = obj[x].SelectedUOM; 
                    newUOM = obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                    if(newUOM != '' && newUOM != undefined && oldUOM != '' && oldUOM != undefined && newUOM != oldUOM){
                        //alert('get converted value from custom settings and evaluate');
                        var UOMCs = cmp.get("v.UOMCs");
                        var conversionFound = false;
                        for(var k in UOMCs){
                            if((UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM) || (UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM)){
                                conversionFound = true;
                                if(UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM){
                                    obj[x].BOMWeightMultiplier = UOMCs[k].ERP7__From_Value__c/UOMCs[k].ERP7__To_Value__c;
                                } else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM){
                                    obj[x].BOMWeightMultiplier = UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c;
                                }
                                //document.getElementById("cardTransition").style.visibility = "hidden";
                                //document.getElementById("cardTransition").classList.add("cardTransition");
                                //document.getElementById("cardTransition").classList.add("cardTransitionClicked");
                                //obj[x].WeightMultiplier = Math.round(num * 100) / 100;
                                //alert(obj[x].BOMWeightMultiplier);
                                break;
                            }
                        }
                        if(!conversionFound) {
                            var errMsgNew = "Conversion values between "+oldUOM+" and "+newUOM+" not found";
                            cmp.set("v.exceptionError",errMsgNew);
                            break;
                        }
                    }
                    
                }
            } cmp.set("v.MRPs", obj); 
            
        } catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    CaptureWeight: function(cmp, event) {
        try{
            var MO = cmp.get("v.ManuOrder");
            var WO = cmp.get("v.WorkOrder");
            var obj = cmp.get("v.MRPs");
            var NewSOLI = cmp.get("v.NewSOLI");
            //cmp.get("v.WeightStr");
            var WeightStr = document.getElementById("WeightStr").value;
            //alert(WeightStr);
            var doubleWeight = 0.00;
            if (typeof WeightStr === 'string' || WeightStr instanceof String) doubleWeight = Number(WeightStr.replace(/[^0-9\.]+/g,""));
            else doubleWeight = WeightStr
            var weight = doubleWeight;
            var onlyweight = doubleWeight;
            cmp.set("v.Weight",doubleWeight);
            cmp.set("v.WeightStr",doubleWeight);
            document.getElementById("WeightStr").value = doubleWeight;
            var TotalWeight = 0;
            var succeed = false;
            var error = false;
            for(var x in obj){
                if(obj[x].isSelect) {
                    var oldUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
                    var newUOM = obj[x].SelectedUOM;
                    //alert(oldUOM);
                    //alert(newUOM);
                    //alert(weight);   
                    if(newUOM != oldUOM && weight >= 0){
                        //alert('get converted value from custom settings and evaluate');
                        var UOMCs = cmp.get("v.UOMCs");
                        var conversionFound = false;
                        var newWeight = 0;
                        for(var k in UOMCs){
                            if((UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM) || (UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM)){
                                conversionFound = true;
                                if(UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM){
                                    newWeight = UOMCs[k].ERP7__From_Value__c/UOMCs[k].ERP7__To_Value__c*weight;
                                } else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM){
                                    newWeight = UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c*weight;
                                }
                                weight = newWeight;
                                onlyweight = newWeight;
                                break;
                            }
                        }
                        if(!conversionFound) {
                            var errMsgNew = "Conversion values between "+oldUOM+" and "+newUOM+" not found";
                            cmp.set("v.exceptionError",errMsgNew);
                            break;
                        }
                    }
                    //alert(weight);
                    
                    if(obj[x].ActualWeight != undefined) weight = parseFloat(weight) + parseFloat(obj[x].ActualWeight);
                    var min = obj[x].MRP.ERP7__Expected_Quantity__c;
                    var max = obj[x].MRP.ERP7__Expected_Quantity__c;
                    var imin = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                    var imax = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                    if(obj[x].MRP.ERP7__Minimum_Variance__c != undefined && obj[x].MRP.ERP7__Minimum_Variance__c != "") min = obj[x].MRP.ERP7__Expected_Quantity__c - obj[x].MRP.ERP7__Minimum_Variance__c;
                    if(obj[x].MRP.ERP7__Maximum_Variance__c != undefined && obj[x].MRP.ERP7__Maximum_Variance__c != "") max = obj[x].MRP.ERP7__Expected_Quantity__c + obj[x].MRP.ERP7__Maximum_Variance__c;
                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c != undefined && obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c != "") imin = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c - obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c;
                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c != undefined && obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c != "") imax = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c + obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                    
                    //New Values
                    min = min/obj[x].WeightMultiplier;
                    max = max/obj[x].WeightMultiplier;
                    imin = imin/obj[x].WeightMultiplier;
                    imax = imax/obj[x].WeightMultiplier;
                    
                    
                    var NewSOLI = cmp.get("v.NewSOLI"); 
                    if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){                    
                        var quant1 = 0;
                        var quantin1 = 0;
                        //if(obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c){
                        quant1 = parseFloat(obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c);
                        if(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant1 += parseFloat(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c);
                        
                        
                        var SOLISM1 = obj[x].SOLIs;
                        for(var y in SOLISM1){
                            if(SOLISM1[y].ERP7__MO_WO_Serial__c == NewSOLI.ERP7__MO_WO_Serial__c) quantin1 += parseFloat(SOLISM1[y].ERP7__Quantity__c);
                        }
                       
                        // New Values quant1
                        quant1 = quant1/obj[x].WeightMultiplier;
                        
                        if((quantin1 + onlyweight) > quant1) error = true;
                        //}
                    }
                    
                    var weightCheck = weight.toFixed(4);
                    var onlyweightCheck = onlyweight.toFixed(4);
                    
                    if((obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c == false && onlyweightCheck > 0 && weightCheck <= max) || (obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c == true && onlyweightCheck > 0 && onlyweightCheck <= imax && onlyweightCheck >= imin && weightCheck <= max)){
                        if((obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && NewSOLI.ERP7__Serial__c == undefined) || (obj[x].MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c && NewSOLI.ERP7__Material_Batch_Lot__c == undefined) || (WO.ERP7__Product__r.ERP7__Serialise__c && NewSOLI.ERP7__MO_WO_Serial__c == undefined) || (WO.ERP7__Product__r.ERP7__Lot_Tracked__c && NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c == undefined)){
                            cmp.set("v.exceptionError","Required fields missing");
                        }  
                        
                        else if(obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && NewSOLI.ERP7__Serial__c != undefined && ((weight - obj[x].ActualWeight) > 1)){
                            cmp.set("v.exceptionError","Serialised product invalid quantity");
                        }
                            else if(error){
                                cmp.set("v.exceptionError","Invalid quantity/weight");
                            }
                                else {
                                    //document.getElementById("weightspins").style.visibility = "visible";
                                    $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                                    if(weight > obj[x].MRP.ERP7__Total_Amount_Required__c) obj[x].MRP.ERP7__Total_Amount_Required__c = weight;
                                    if(obj[x].MRP.ERP7__Fulfilled_Amount__c >= 0) obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c + (weight - obj[x].ActualWeight)*obj[x].WeightMultiplier);
                                    else obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat((weight - obj[x].ActualWeight)*obj[x].WeightMultiplier);
                                    var soliQuantity = weight - obj[x].ActualWeight;
                                    cmp.set("v.Weight",0);
                                    cmp.set("v.exceptionError","");
                                    NewSOLI.ERP7__Quantity__c = parseFloat(soliQuantity); //parseFloat(soliQuantity).toFixed(2);
                                    var objsels = JSON.stringify(NewSOLI);
                                    var objs = JSON.stringify(obj);
                                    var action = cmp.get("c.SaveNewSOLI");
                                    action.setParams({
                                        NewSOLI: objsels,
                                        MRPs: objs
                                    });
                                    action.setCallback(this, function(response) {
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            //cmp.popInit();
                                            if(response.getReturnValue().errorMsg != '') cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                                            else { 
                                                succeed = true;
                                                //obj[x].SOLIs = response.getReturnValue().SOLIs;
                                                
                                                cmp.set("v.WeightStr","0");
                                                cmp.set("v.NewSOLI.ERP7__Material_Batch_Lot__c", undefined);
                                                cmp.set("v.NewSOLI.ERP7__Serial__c", undefined);
                                                cmp.set("v.MRPs",response.getReturnValue().MRPSS);
                                                
                                                //cmp.set("v.NewSOLI",response.getReturnValue().NewSOLI);
                                                var ik = response.getReturnValue().MRPSS;
                                                var TW = 0;
                                                var Fulfilled = true;
                                                for(var y in ik){
                                                    if(ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs') TW += ik[y].MRP.ERP7__Total_Amount_Required__c;
                                                    if(ik[y].ActualWeight < ik[y].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
                                                }
                                                cmp.set("v.Fulfilled",Fulfilled);
                                                cmp.set("v.TotalWeight",TW);
                                                ///////////////////////////////////////////
                                                //var NewSOLI = cmp.get("v.NewSOLI"); 
                                                //alert(NewSOLI.ERP7__MO_WO_Serial__c);
                                                cmp.set("v.WCAP",true);
                                                if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
                                                    var PrintSB = false;
                                                    var objm = cmp.get("v.MRPs"); 
                                                    for(var x in objm){ 
                                                        if(objm[x].isSelect) { 
                                                            var quant = 0;
                                                            var quantin = 0;
                                                            //if(objm[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c){
                                                            quant = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                            if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                                                            //alert("max in :"+quant);
                                                            
                                                            var SOLISM = objm[x].SOLIs;
                                                            for(var y in SOLISM){
                                                                if((SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                                                            }
                                                            //alert("already in :"+quantin);
                                                            if(quantin*objm[x].WeightMultiplier >= quant) cmp.set("v.WCAP",false); 
                                                            //}
                                                        } 
                                                    }
                                                    for(var x in objm){ 
                                                        var q = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                        var qin = 0;
                                                        var qmin = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                        var qmax = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                        if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) qmax += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                                                        if(objm[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c > 0) qmin -= objm[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c;
                                                        
                                                        var SOLISMS = objm[x].SOLIs;
                                                        for(var y in SOLISMS){
                                                            if((SOLISMS[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) qin += SOLISMS[y].ERP7__Quantity__c;
                                                        }
                                                        if(qin*objm[x].WeightMultiplier >= qmin) PrintSB = true;
                                                        else{
                                                            PrintSB = false;
                                                            break;
                                                        }
                                                    }
                                                    cmp.set("v.PrintSB",PrintSB);
                                                }
                                                ////////////////////////////////////////////////////
                                                
                                            }
                                        } else { cmp.set("v.exceptionError",response.getReturnValue().errorMsg); }
                                        //document.getElementById("weightspins").style.visibility = "hidden";
                                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");  
                                    });
                                    $A.enqueueAction(action);
                                    
                                }
                    }
                    else {
                        cmp.set("v.exceptionError","Invalid weight to capture");
                    }
                }
            }
        }
        catch(err) {
            console.log("Exception : "+err.message);
        }
        
    },
    
    upsertWeights: function(cmp, event) {
        try{
            document.getElementById("weightspins").style.visibility = "visible";
            var obj = JSON.stringify(cmp.get("v.MRPs"));
            var action = cmp.get("c.SaveAllMRPs");
            action.setParams({
                MRPs: obj
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    if(response.getReturnValue().errorMsg == ''){
                        //$('#WeightCapture').modal('hide');
                        cmp.popInit();
                    } else document.getElementById("weightspins").style.visibility = "hidden";
                }
            });
            $A.enqueueAction(action);
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    Evaluate : function (cmp, event) {
        var mrp_Main = cmp.get("v.MRPEdit.MRP");
        var alternate_Mrps = cmp.get("v.NewMRPs.MRPSS");
        if(mrp_Main.ERP7__BOM__r.ERP7__Is_Protected__c == true){
            document.getElementById("mrpspins").style.visibility = "visible";
            var target = event.getSource();
            var count = target.getElement().parentElement.name;
            for(var x in alternate_Mrps){
                if(x != count) { 
                    alternate_Mrps[x].isSelect = false;
                }
            }
            document.getElementById("mrpspins").style.visibility = "hidden";
        }
        cmp.set("v.NewMRPs.MRPs",alternate_Mrps);
    },
    
    EditMRP : function (cmp, event) {
        var count = event.getSource().get("v.name");
        //alert(count);
        cmp.set("v.MRPEdit","");
        cmp.set("v.NewMRPs","");
        var obj = cmp.get("v.MRPs");
        var objsel;
        for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
            }
        }
        cmp.set("v.MRPEdit",objsel);
        var objsels = JSON.stringify(objsel);
        var objs = JSON.stringify(cmp.get("v.MRPs"));
        var action = cmp.get("c.MRPEdit");
        action.setParams({
            MRP: objsels,
            MRPs: objs
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                cmp.set("v.NewMRPs",response.getReturnValue());
                $A.util.addClass(cmp.find("myEditMRPModal"), 'slds-fade-in-open');
                $A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
            } else { cmp.set("v.exceptionError",response.getError()); }
        });
        $A.enqueueAction(action);
        
    },
    
    updateMRPNew : function (cmp, event) {
        document.getElementById("mrpspins").style.visibility = "visible";
        var mrp_Main = cmp.get("v.MRPEdit.MRP");
        var alternate_Mrps = JSON.stringify(cmp.get("v.NewMRPs.MRPSS"));
        var me = JSON.stringify(mrp_Main);
        //alert(me);
        //alert(alternate_Mrps);
        var action = cmp.get("c.MRPUpdateNew");
        action.setParams({
            mrpMain1 : JSON.stringify(mrp_Main),
            alternateMrps: alternate_Mrps
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                if(response.getReturnValue().errorMsg == ''){
                    $('#myModale').modal('hide');
                    cmp.popInit();
                } //else document.getElementById("mrpspins").style.visibility = "hidden";
                $A.util.removeClass(cmp.find("myEditMRPModal"), 'slds-fade-in-open');
                $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
            }
        });
        $A.enqueueAction(action);
    },
    
    DeleteRecordSOLI: function(cmp, event) {
        var result = confirm("Are you sure?");
        var RecordId = event.getSource().get("v.name");
        var obj = cmp.get("v.MRPs");
        if (result) {
            //document.getElementById("weightspins").style.visibility = "visible";
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            try{
                var obj = cmp.get("v.MRPs");
                var objs = JSON.stringify(obj);
                var action = cmp.get("c.DeleteSOLI");
                action.setParams({
                    SOLI: RecordId,
                    MRPs: objs
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //cmp.popInit();
                        if(response.getReturnValue().errorMsg != '') cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                        else { 
                            cmp.set("v.MRPs",response.getReturnValue().MRPSS);
                            cmp.set("v.NewSOLI",response.getReturnValue().NewSOLI);
                            var ik = response.getReturnValue().MRPs;
                            var TW = 0;
                            var Fulfilled = true;
                            for(var y in ik){
                                if(ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs') TW += ik[y].MRP.ERP7__Total_Amount_Required__c;
                                if(ik[y].ActualWeight < ik[y].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
                            }
                            cmp.set("v.Fulfilled",Fulfilled);
                            cmp.set("v.TotalWeight",TW);
                            
                            ///////////////////////////////////////////
                            var NewSOLI = cmp.get("v.NewSOLI"); 
                            //alert(NewSOLI.ERP7__MO_WO_Serial__c);
                            cmp.set("v.WCAP",true);
                            if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
                                var PrintSB = false;
                                var objm = cmp.get("v.MRPs"); 
                                for(var x in objm){ 
                                    if(objm[x].isSelect) { 
                                        var quant = 0;
                                        var quantin = 0;
                                        //if(objm[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c){
                                        quant = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                        if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                                        //alert("max in :"+quant);
                                        
                                        var SOLISM = objm[x].SOLIs;
                                        for(var y in SOLISM){
                                            if((SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                                        }
                                        //alert("already in :"+quantin);
                                        if(quantin*objm[x].WeightMultiplier >= quant) cmp.set("v.WCAP",false); 
                                        //}
                                    } 
                                }
                                for(var x in objm){ 
                                    var q = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                    var qin = 0;
                                    var qmin = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                    var qmax = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                    if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) qmax += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                                    if(objm[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c > 0) qmin -= objm[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c;
                                    
                                    var SOLISMS = objm[x].SOLIs;
                                    for(var y in SOLISMS){
                                        if((SOLISMS[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) qin += SOLISMS[y].ERP7__Quantity__c;
                                    }
                                    if(qin*objm[x].WeightMultiplier >= qmin) PrintSB = true;
                                    else{
                                        PrintSB = false;
                                        break;
                                    }
                                }
                                cmp.set("v.PrintSB",PrintSB);
                            }
                            ////////////////////////////////////////////////////
                            //document.getElementById("weightspins").style.visibility = "hidden";
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                    } else { 
                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg); 
                        //document.getElementById("weightspins").style.visibility = "hidden";
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
            catch(err) {
                //alert("Exception : "+err.message);
            }
        } 
    },
    
    SerialBOMValidation : function(cmp, event, helper) { 
        var NewSOLI = cmp.get("v.NewSOLI"); 
        //alert(NewSOLI.ERP7__MO_WO_Serial__c);
        cmp.set("v.WCAP",true);
        if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
            var PrintSB = false;
            var objm = cmp.get("v.MRPs"); 
            for(var x in objm){ 
                if(objm[x].isSelect) { 
                    var quant = 0;
                    var quantin = 0;
                    //if(objm[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c){
                    quant = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                    if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                    //alert("max in :"+quant);
                    
                    var SOLISM = objm[x].SOLIs;
                    for(var y in SOLISM){
                        if((SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                    }
                    //alert("already in :"+quantin);
                    if(quantin*objm[x].WeightMultiplier >= quant) cmp.set("v.WCAP",false); 
                    //}
                } 
            }
            for(var x in objm){ 
                var q = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                var qin = 0;
                var qmin = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                var qmax = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) qmax += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                if(objm[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c > 0) qmin -= objm[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c;
                
                var SOLISMS = objm[x].SOLIs;
                for(var y in SOLISMS){
                    if((SOLISMS[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) qin += SOLISMS[y].ERP7__Quantity__c;
                }
                if(qin*objm[x].WeightMultiplier >= qmin) PrintSB = true;
                else{
                    PrintSB = false;
                    break;
                }
            }
            cmp.set("v.PrintSB",PrintSB);
        }
    },
    
    Reload : function (cmp, event) {
        //document.getElementById("rot").classList.add("erp-rotation");
        cmp.popInit();
    },
    
    StartWO: function (cmp, event) {
        //window.scrollTo(0, 0);
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var RecId = event.getSource().get("v.name");
        var action = cmp.get("c.StartWORec");
        action.setParams({ RecId : RecId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    cmp.popInit();
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //alert("Exception : "+err.message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    WO2Finish : function (cmp, event) {
        try{
        var UpdateWORec = event.getSource().get("v.name");
        var action = cmp.get("c.GetWORec");
        action.setParams({ RecId : UpdateWORec});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.WO2Fin", response.getReturnValue().WorkOrder);
                cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                var obj = cmp.get("v.WIPs"); 
                for(var x in obj){
                    if(0 == x) { 
                        cmp.set("v.SelectedWIP",obj[x]);
                    }
                }
                cmp.set("v.WIPs",obj);

                var WOtasks = cmp.get("v.Tasks");
                for(var i in WOtasks){
                    if(WOtasks[i].ERP7__Status__c == "Completed"){
                        cmp.set("v.isWOcomplete", false);
                    }
                    else{
                        cmp.set("v.isWOcomplete", true);
                        break;
                    }
                }

                $A.util.addClass(cmp.find("finishModal"),"slds-fade-in-open");
                $A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
            } 
        });
        $A.enqueueAction(action);
        }catch(e){console.log("error in finish",e);}
    },
    
    FinishWIPFlow : function (cmp, event) {
        var count = event.currentTarget.getAttribute('data-wfcount');
        var obj = cmp.get("v.WIPFlows"); 
        if(obj[count].ERP7__Quantity__c > 0){
            obj[count].ERP7__Status__c = "Completed";
            //if(obj[count].ERP7__Product__r.ERP7__Serialise__c ) obj[count].ERP7__Quantity__c = obj[count].ERP7__Quantity_Unit__c; 
            var WFlow = JSON.stringify(obj[count]);
            var action = cmp.get("c.CompleteWIPFlow");
            action.setParams({ WIPFlow : WFlow});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try { 
                        cmp.set("v.WIPFlows",obj);
                    } catch(err) {
                        cmp.set("v.exceptionError", err.message);
                        //alert("Exception : "+err.message);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    validateBuiltQnty  : function(cmp, event, helper) {
        var WORec = cmp.get("v.WO2Fin");
        if(WORec.ERP7__Quantity_Built__c > WORec.ERP7__Quantity_Ordered__c){
            WORec.ERP7__Quantity_Built__c = WORec.ERP7__Quantity_Ordered__c;
            cmp.set("v.WO2Fin",WORec);
        }
    },
    
    validateFlowQnty  : function(cmp, event, helper) {
        var obj = cmp.get("v.WIPFlows");
        var count = event.getSource().get("v.labelClass");
        for(var x in obj){
            if(count == x) { 
                var flow = JSON.stringify(obj[x]);
                if(obj[x].ERP7__Product__c == obj[x].ERP7__Work_Orders__r.ERP7__Product__c && obj[x].ERP7__Product__r.ERP7__Serialise__c == true && obj[x].ERP7__Quantity__c > 1){
                    obj[x].ERP7__Quantity__c = 1;
                    cmp.set("v.WIPFlows",obj);
                } 
                else if(obj[x].ERP7__Quantity__c > (obj[x].ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c * obj[x].ERP7__Quantity_Unit__c)){
                    obj[x].ERP7__Quantity__c = obj[x].ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c * obj[x].ERP7__Quantity_Unit__c;
                    cmp.set("v.WIPFlows",obj);
                }
            }
        }
    },
    
    closeFinishModal : function(cmp, event) {
        $A.util.removeClass(cmp.find("finishModal"),"slds-fade-in-open");
        $A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
    },
    
    FinishWO : function (cmp, event) {
        window.scrollTo(0, 0);
        var WORec = cmp.get("v.WO2Fin");
        var flows = JSON.stringify(cmp.get("v.WIPFlows"));
        var action = cmp.get("c.UpdateWORec");
        action.setParams({ WO2Update1 : JSON.stringify(WORec), WIPFlows : flows});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    //document.getElementById('myModal1').style.display = 'none';
                    cmp.popInit();
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                }
                $A.util.removeClass(cmp.find("finishModal"),"slds-fade-in-open");
                $A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
            }
        });
        $A.enqueueAction(action);
    },
    
    GetResources: function(cmp, event) {
        //document.getElementById("resourceSpins").style.visibility = "visible";
        try{
            var obj = cmp.get("v.WorkPlanners"); 
            var Name = cmp.get("v.ResourceStr"); 
            var ST = cmp.get("v.StartTime"); 
            var ET = cmp.get("v.EndTime"); 
            var objsels = JSON.stringify(obj);
            var WPId = cmp.get("v.SelectedWP"); ;
            var RRId = cmp.get("v.selectedRR"); ;
            var action = cmp.get("c.GetAllResources");
            action.setParams({
                WPS: objsels,
                Name: Name,
                StartTime: ST,
                EndTime: ET,
                WPId: WPId,
                RRId: RRId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //cmp.popInit();
                    if(response.getReturnValue().errorMsg != '') cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    else { 
                        cmp.set("v.AvailableResources",response.getReturnValue().AvailableResources);
                    }
                } else { cmp.set("v.exceptionError",response.getReturnValue().errorMsg); }
                //document.getElementById("resourceSpins").style.visibility = "hidden";
            });
            $A.enqueueAction(action);
        }
        catch(err) {
            //document.getElementById("resourceSpins").style.visibility = "hidden";
            alert("Exception : "+err.message);
        }
        
    },
    
    upsertResources: function(cmp, event) {
        //document.getElementById("resourceSpins").style.visibility = "visible";
        try{
            var obj = cmp.get("v.AvailableResources");
            var objsels = JSON.stringify(obj);
            var ST = cmp.get("v.StartTime"); 
            var ET =cmp.get("v.EndTime"); 
            var WOO = JSON.stringify(cmp.get("v.WorkOrder"));
            
            var action = cmp.get("c.SaveResources");
            action.setParams({
                Resources: objsels,
                WO1: WOO,
                StartTime: ST,
                EndTime: ET
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //cmp.popInit();
                    if(response.getReturnValue().errorMsg != '') cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    else { 
                        $A.util.removeClass(cmp.find("myResourceAllocationModal"), 'slds-fade-in-open');
                        $A.util.removeClass(cmp.find("myResourceAllocationModalBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                    }
                } else { cmp.set("v.exceptionError",response.getReturnValue().errorMsg); }
                //document.getElementById("resourceSpins").style.visibility = "hidden"; 
            });
            $A.enqueueAction(action);
        }
        catch(err) {
            //document.getElementById("resourceSpins").style.visibility = "hidden"; 
            alert("Exception : "+err.message);
        }
    },
    
    SelectWP: function(cmp, event) {
        try{
            var count = String(event.currentTarget.getAttribute('data-rr'));
            var name = String(event.currentTarget.getAttribute('data-rrname'));
            //alert(count);
            cmp.set("v.selectedRR",count);
            cmp.set("v.selectedRRName",name);
            
        }
        catch(err) {
            alert("Exception : "+err.message);
        }
    },
    
    goBack : function(component,event,helper){
        window.history.back();
    },
    
    showSignature: function(cmp, event) {
        //document.getElementById("sigbody").style.visibility = "visible";
        cmp.set("v.IsSignatureTab",true);
    },
    
    lookupClickVersion :function(cmp,helper){
        var acc = cmp.get("v.WorkOrder.ERP7__Product__c");
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = ' And ERP7__Product__c = \''+acc+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
    },
    
    lookupClickRouting :function(cmp,helper){
        var acc = cmp.get("v.WorkOrder.ERP7__Product__c");
        var version = cmp.get("v.WorkOrder.ERP7__Version__c");
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = ' And ERP7__Product__c = \''+acc+'\'';
        if(version != undefined && version != '') qry += ' And ERP7__BOM_Version__c = \''+version+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
    },
    
    lookupChangeProduct :function(cmp,helper){
        cmp.set("v.WorkOrder.ERP7__Version__c", undefined);
    }, 
    
    lookupChangeVersion :function(cmp,helper){
        cmp.set("v.WorkOrder.ERP7__Routing__c", undefined);
    },
    
    lookupClickProduct :function(cmp,helper){
        var proId = cmp.get("v.WorkOrder.ERP7__Product__c");
        try{
            if(proId == '' || proId == undefined) {
                //alert(proId);
                cmp.set("v.WorkOrder.ERP7__Version__c", undefined);
                cmp.set("v.WorkOrder.ERP7__Routing__c", undefined);
            } else{
                //alert(proId);
                var action = cmp.get("c.GetDefaults");
                action.setParams({
                    proId: proId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //alert(state);
                        var WO = cmp.get("v.WorkOrder");
                        var RV = JSON.stringify(response.getReturnValue());
                        //alert('RV : '+RV);
                        //alert(response.getReturnValue().ERP7__Version__c);
                        //alert(response.getReturnValue().ERP7__Routing__c);
                        if(response.getReturnValue().ERP7__Version__c != undefined) {
                            //WO.ERP7__Version__c = response.getReturnValue().ERP7__Version__c;
                            cmp.set("v.WorkOrder.ERP7__Version__c", response.getReturnValue().ERP7__Version__c);
                            var kk = cmp.get("v.WorkOrder.ERP7__Version__c");
                            //alert('Version : '+kk);
                        }
                        if(response.getReturnValue().ERP7__Routing__c != undefined) {
                            //WO.ERP7__Routing__c = response.getReturnValue().ERP7__Routing__c;
                            cmp.set("v.WorkOrder.ERP7__Routing__c", response.getReturnValue().ERP7__Routing__c);
                            var kk1 = cmp.get("v.WorkOrder.ERP7__Routing__c");
                            //alert('Routing : '+kk1);
                        }
                        //cmp.set("v.WorkOrder",WO);
                    } 
                });
                $A.enqueueAction(action);
            }
        } catch(err) {
            //alert(err.message);
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            //alert("Exception : "+err.message);
        }
    },
    
    SaveWO : function (cmp, event, helper) {
        var WO = cmp.get("v.WorkOrder");
        var WOs = JSON.stringify(WO);
        //alert(WO.ERP7__Start_Date__c);
        if(WO.Name != undefined && WO.ERP7__Product__c != undefined && WO.ERP7__Product__c != '' && WO.ERP7__Version__c != undefined && WO.ERP7__Version__c != '' && WO.ERP7__Routing__c != undefined && WO.ERP7__Routing__c != '' && WO.ERP7__Quantity_Ordered__c  > 0 && WO.ERP7__Start_Date__c != undefined && WO.ERP7__ExpectedDate__c != undefined && WO.ERP7__Start_Date__c != "" && WO.ERP7__ExpectedDate__c != "" && !(WO.ERP7__Is_Signature_Required__c == true && cmp.get("v.IsSignatureTab") == false && cmp.get("v.Signatures").length == 0 && WO.ERP7__Status__c == 'Complete')){
            WO.ERP7__End_Date__c = WO.ERP7__ExpectedDate__c;
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.SaveW");
            action.setParams({
                WO: WOs                
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        cmp.set("v.exceptionError",'');
                        var WOId = response.getReturnValue().WorkOrder.Id;
                        cmp.set("v.WO",WOId);
                        if(cmp.get("v.IsSignatureTab") == true && WOId != undefined && WOId != '' && WO.ERP7__Is_Signature_Required__c == true && cmp.get("v.Signatures").length == 0){
                            var eSigComp = cmp.find('signatureEXs');
                            eSigComp.saveSignatureFromParent();
                        }
                        cmp.popInit();
                    } else if(response.getReturnValue().errorMsg != ''){
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                        window.scrollTo(0, 0);
                    }    
                }
            });
            $A.enqueueAction(action);
        } else {
            if(WO.ERP7__Is_Signature_Required__c == true && cmp.get("v.IsSignatureTab") == false && cmp.get("v.Signatures").length == 0 && WO.ERP7__Status__c == 'Complete') cmp.set("v.errorMsg",'Signature is required, sorry you cannot complete with out signature.');
            else cmp.set("v.exceptionError",'Required fields missing');
            window.scrollTo(0, 0);
        } 
    },
    
    showSignature: function(cmp, event) {
        //document.getElementById("sigbody").style.visibility = "visible";
        cmp.set("v.IsSignatureTab", true);
    },
    
    hideSignature: function(cmp, event) {
        cmp.set("v.IsSignatureTab", false);
    },
    
    tab1 : function(component, event, helper) {
        component.set("v.worksheetTab",true);
        component.set("v.drawingTab",false);
        component.set("v.timeTrackingTab",false);
        component.set("v.MRPSTab",false);
        component.set("v.resourceTab",false);
        
        component.set("v.currentProductionTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
    },
    
    tab2 : function(component, event, helper) {
        component.set("v.worksheetTab",false);
        component.set("v.drawingTab",true);
        component.set("v.timeTrackingTab",false);
        component.set("v.MRPSTab",false);
        component.set("v.resourceTab",false);
        
        component.set("v.currentProductionTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
    },
    
    tab3 : function(component, event, helper) {
        component.set("v.worksheetTab",false);
        component.set("v.drawingTab",false);
        component.set("v.timeTrackingTab",true);
        component.set("v.MRPSTab",false);
        component.set("v.resourceTab",false);
        
        component.set("v.currentProductionTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
    },
    
    tab4 : function(component, event, helper) {
        component.set("v.worksheetTab",false);
        component.set("v.drawingTab",false);
        component.set("v.timeTrackingTab",false);
        component.set("v.MRPSTab",true);
        component.set("v.resourceTab",false);
        
        component.set("v.currentProductionTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
    },
    
    tab5 : function(component, event, helper) {
        component.set("v.worksheetTab",false);
        component.set("v.drawingTab",false);
        component.set("v.timeTrackingTab",false);
        component.set("v.MRPSTab",false);
        component.set("v.resourceTab",true);
        
        component.set("v.currentProductionTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
    },
    
    tab6 : function(component, event, helper) {
        component.set("v.worksheetTab",false);
        component.set("v.drawingTab",false);
        component.set("v.timeTrackingTab",false);
        component.set("v.MRPSTab",false);
        component.set("v.resourceTab",false);
        
        component.set("v.currentProductionTab",true);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
    },
    
    tab7 : function(component, event, helper) {
        component.set("v.worksheetTab",false);
        component.set("v.drawingTab",false);
        component.set("v.timeTrackingTab",false);
        component.set("v.MRPSTab",false);
        component.set("v.resourceTab",false);
        
        component.set("v.currentProductionTab",false);
        component.set("v.serialorBatchesTab",true);
        component.set("v.signatureTab",false);
    },
    
    tab8 : function(component, event, helper) {
        component.set("v.worksheetTab",false);
        component.set("v.drawingTab",false);
        component.set("v.timeTrackingTab",false);
        component.set("v.MRPSTab",false);
        component.set("v.resourceTab",false);
        
        component.set("v.currentProductionTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",true);
    },
    
    openTaskDropdown : function(cmp, event){
        $A.util.addClass(cmp.find('TaskMenu'), 'slds-show');
        //cmp.set("v.openMenu",true);
    },
    
    closeTaskDropdown : function(cmp, event){
        $A.util.removeClass(cmp.find('TaskMenu'), 'slds-show');
        //cmp.set("v.openMenu",false);
    },
    
    closeMRPModal : function (cmp,event) {
        $A.util.removeClass(cmp.find("myMRPModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
    },
    
    closeStockAllocationModal : function (cmp,event) {
        $A.util.removeClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
    },
    
    openEditMRPModal : function (cmp,event) {
        $A.util.removeClass(cmp.find("myEditMRPModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
    },
    
    closeEditMRPModal : function (cmp,event) {
        $A.util.removeClass(cmp.find("myEditMRPModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
    },
    
    taskOperation : function(cmp, event, helper){
        var operation = event.getParam("value");
        if(operation == "Edit") $A.enqueueAction(cmp.get("c.UpdateCurrentTask"));
        else if(operation == "Delete") $A.enqueueAction(cmp.get("c.DeleteTask"));
    },

    editOrder : function(cmp, event){
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": cmp.get("v.WorkOrder.Id")
        });
        editRecordEvent.fire();
    },

    closeError : function(cmp){
        cmp.set("v.exceptionError", "");
    }
    
})