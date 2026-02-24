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
                                    if(component.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && component.get("v.SelectedTask.ERP7__Status__c") == 'In Progress'){
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

                                            if (distance < 0 || component.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In Progress') {
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
                            else{
                                component.set("v.exceptionError", response.getReturnValue().errorMsg);
                                ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            }
                        } else{
                            component.set("v.exceptionError", response.getError());
                            // //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
                    });
                    $A.enqueueAction(action);
                }
                else if(scan_Code === "Capture"){
                    component.CaptureTheWeight();
                } else {
                    var objm = component.get("v.MRPs");
                    var objms = JSON.stringify(objm);
                    var BarcodeAction = component.get("c.SearchScanCode");
                    BarcodeAction.setParams({"scanCode":scan_Code,"MRPs": objms});
                    BarcodeAction.setCallback(this,function(response){
                        var state = response.getState();
                        if(state === 'SUCCESS'){
                            var obj = response.getReturnValue();
                            var ik = JSON.stringify(response.getReturnValue());
                            if(response.getReturnValue() != null){
                                component.set("v.scanValue",'');
                                var NewSOLI = component.get("v.NewSOLI");
                                if(obj.step === "MO" && obj.substep === "Serial"){
                                    NewSOLI.ERP7__MO_WO_Serial__c = obj.Serial.Id;
                                    NewSOLI.ERP7__MO_WO_Serial__r = {Name:obj.Serial.Name,Id:obj.Serial.Id};
                                    component.set("v.NewSOLI",NewSOLI);
                                }
                                else if(obj.step === "MO" && obj.substep === "Batch"){
                                    NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c = obj.Batch.Id;
                                    NewSOLI.ERP7__MO_WO_Material_Batch_Lot__r = {Name:obj.Batch.Name,Id:obj.Batch.Id};
                                    component.set("v.NewSOLI",NewSOLI);
                                    component.set("v.show",true);
                                }
                                    else if(obj.step === "MRP" && obj.substep === "Serial"){
                                        NewSOLI.ERP7__Serial__c = obj.Serial.Id;
                                        NewSOLI.ERP7__Serial__r = {Name:obj.Serial.Name,Id:obj.Serial.Id};
                                        component.set("v.NewSOLI",NewSOLI);
                                    }
                                        else if(obj.step === "MRP" && obj.substep === "Batch"){
                                            NewSOLI.ERP7__Material_Batch_Lot__c = obj.Batch.Id;
                                            NewSOLI.ERP7__Material_Batch_Lot__r = {Name:obj.Batch.Name,Id:obj.Batch.Id};
                                            component.set("v.NewSOLI",NewSOLI);
                                        }
                                var kNewSOLI = JSON.stringify(component.get("v.NewSOLI"));
                            }
                        }
                    });
                    $A.enqueueAction(BarcodeAction);
                }
            }
        },

        handleSignatureEvent: function(cmp, event) {
            var Attachments = event.getParam("Attachments");
            if(!cmp.get("v.IsSignatureTab")){
                var SelectedTask = cmp.get("v.SelectedTask");
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var action = cmp.get("c.GetAttachments");
                action.setParams({TaskId:SelectedTask.Id});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    cmp.set("v.exceptionError", "");
                    if (state === "SUCCESS") {
                        cmp.set("v.SelectedAttachments", response.getReturnValue());
                        cmp.set("v.signatureExist", false);
                        var selAttachs = cmp.get("v.SelectedAttachments");
                        for(var x in selAttachs){
                            if(selAttachs[x].ParentId == SelectedTask.Id && selAttachs[x].Name == 'Signature') cmp.set("v.signatureExist", true);
                        }
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else{
                        cmp.set("v.exceptionError", response.getError());
                        ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                    cmp.set("v.exceptionError", "");
                    if (state === "SUCCESS") {
                        //cmp.popInit();
                        cmp.set("v.Signatures", response.getReturnValue());
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else{
                        cmp.set("v.exceptionError", response.getError());
                        ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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

        taskOperation : function(cmp, event, helper){
            var operation = event.getParam("value");
             var taskId = event.getSource().get("v.name");
            console.log('taskId: ', taskId);
            if(taskId != null && taskId != '' && taskId != undefined){
                let tasklist = cmp.get('v.Tasks');
                for(var x in tasklist){
                    if(tasklist[x].Id == taskId){
                        cmp.set('v.SelectedTask',tasklist[x]);
                        break;
                    }
                }
            }
            if(operation == "Edit"){
                var action = cmp.get("c.UpdateTask");
                $A.enqueueAction(action);
            }
            else if(operation == "Delete"){
                var action = cmp.get("c.DeleteTask");
                $A.enqueueAction(action);
            }
        },

        changeCurrentWO : function(cmp, event, helper){
            var op = event.currentTarget.dataset.record;
            //var ind = event.currentTarget.dataset.index;
            var allWOs = cmp.get("v.AllWOs");
            //if((allWOs[ind].ERP7__Status__c == "Completed" || allWOs[ind].ERP7__Status__c == "In Progress") && op != allWOs[ind].Id){
            if(op == "next")
                cmp.set("v.WO", cmp.get("v.NWO"));
            else if(op == "prev")
                cmp.set("v.WO", cmp.get("v.PWO"));
                else	cmp.set("v.WO", op);
            var nextenable = cmp.get('v.NWO');
            var prevenable = cmp.get('v.PWO');
            if(nextenable!=''){
                var status =  cmp.get('v.WorkOrder.ERP7__Status__c');
                if(status == 'Complete'){
                    cmp.popInit();
                }
                else{
                    cmp.set('v.exceptionError',$A.get('$Label.c.Complete_current_process_cycle'));
                }
            }
            else{
                cmp.popInit();
            }

        },

        getAllDetails : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            helper.getpicklistValues(cmp, event);
            var toBuild = cmp.get("v.agentToBuild");
            console.log('toBuild : ',toBuild);
            var woId = cmp.get("v.WO");
            var vrd = cmp.get("v.RD");
            var checkWOId = cmp.get("v.agentWOId");
            console.log('checkWOId : ',checkWOId);
            // Only override WO if passed via param
            if (checkWOId) {
                woId = checkWOId;

                // If toBuild is explicitly passed and true, trigger build logic
                if (toBuild === true) {
                    console.log('Triggering build logic for WO: ', woId);
                    helper.agentGetMOData(cmp, event, helper);
                }
            }
            cmp.set("v.selectAllCheckbox", false);
            var action = cmp.get("c.getAll");
            var countDownDate;
            action.setParams({woId:woId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try{
                        console.log('response getAll : ',response.getReturnValue());
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        //if(!$A.util.isEmpty(cmp.get("v.exceptionError"))) //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        cmp.set("v.SerialsLength", response.getReturnValue().serialsLength);
                        cmp.set("v.WorkOrder", response.getReturnValue().WorkOrder);
                        cmp.set("v.ManuOrder", response.getReturnValue().manuOrders);
                        cmp.set("v.UOMCs", response.getReturnValue().UOMCs);
                        cmp.set("v.checkAll",false);
                        cmp.set("v.rendertablist",response.getReturnValue().rendertabs);
                        cmp.set("v.linksNewOptions",response.getReturnValue().linksNewOptions);
                        cmp.set("v.showAutoStockAllocation", response.getReturnValue().showAutoStockAllocation);
                        cmp.set("v.showManualStockAllocation", response.getReturnValue().showManualStockAllocation);
                        cmp.set('v.showWC',response.getReturnValue().ShowWorkCenter);
                        cmp.set('v.showProductDesc',response.getReturnValue().showProdDesc);
                        cmp.set('v.showSerialNumGeneration',response.getReturnValue().ShowCustomSerailNumberGeneration);
                        cmp.set('v.byPassWOComplete',response.getReturnValue().byPassWOComplete);
                        cmp.set('v.showSearchWIP',response.getReturnValue().showSearch);
                        cmp.set('v.displayProducedSection',response.getReturnValue().showProducedSection);
                        cmp.set('v.maxCutValidation',response.getReturnValue().maxCutValidation);
                        cmp.set('v.hideToProduceforMRP',response.getReturnValue().hideToProduceForOnlyMRP);
                        cmp.set('v.MaxAllowedCuts',response.getReturnValue().MaxCuts);
                        cmp.set("v.showVendorCode",response.getReturnValue().showVendorCode);
                        cmp.set('v.EnterconsumeQty',response.getReturnValue().EnterconsumeQtyAutomatical);
                        cmp.set('v.showScrapDetails',response.getReturnValue().showScrapDetails);
                        console.log('EnterconsumeQty : ',cmp.get('v.EnterconsumeQty'));
                        var obj = response.getReturnValue().MRPSSBW;
                        var showSAButton = false;
                        var ConsumedMRPCount = 0;
                        for(var x in obj){
                            if(Number(obj[x].MRP.ERP7__Consumed_Quantity__c) > 0 || Number(obj[x].MRP.ERP7__Scrapped_Quantity__c) > 0){
                                ConsumedMRPCount += 1;
                            }

                            var stk = obj[x].Stock;
                            if(obj[x].MRP.ERP7__Total_Amount_Required__c != obj[x].MRP.ERP7__Fulfilled_Amount__c){
                                showSAButton = true;
                            }
                            cmp.set("v.WeightCapture", true);

                            var newUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
                            var oldUOM = obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                            obj[x].WeightMultiplier = 1;
                            if(newUOM != '' && newUOM != undefined && oldUOM != '' && oldUOM != undefined && newUOM != oldUOM){
                                //alert('get converted value from custom settings and evaluate');
                                if(cmp.get("v.isReload")){
                                    cmp.set("v.warningError", $A.get('$Label.c.Get_converted_value_from_custom_settings_and_evaluate'));
                                    setTimeout(
                                        $A.getCallback(function() {
                                            cmp.set("v.warningError","");
                                        }), 2000
                                    );
                                    cmp.set("v.isReload", false);
                                }
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
                            //added by imran for color fix
                            stk = stk * obj[x].WeightMultiplier;
                            if(stk <= 0) obj[x].bgColor = 'red-s';
                            else if(stk > 0 && stk < obj[x].MRP.ERP7__Total_Amount_Required__c) obj[x].bgColor = 'orange';
                                else if(stk > obj[x].MRP.ERP7__Total_Amount_Required__c) obj[x].bgColor = 'green';
                        }
                        cmp.set("v.showSAButton", showSAButton);
                        cmp.set("v.MRPs", obj);
                        // if(cmp.get('v.EnterconsumeQty') == true){cmp.set('v.ToProduce',cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));  }
                        console.log('ToProduce init : ',cmp.get('v.ToProduce'));
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
                        cmp.set("v.Attachment", response.getReturnValue().SelectedAttachment);
                        //if(cmp.get('v.SelectedTask') != null && cmp.get('v.SelectedTask') != '' && cmp.get('v.SelectedTask') != undefined)
                        // if(cmp.get("v.SelectedTask.Id") == response.getReturnValue().SelectedTask.Id)
                        cmp.set("v.SelectedTask", response.getReturnValue().SelectedTask);

                        cmp.set("v.NewTask", response.getReturnValue().NewTask);
                        cmp.set("v.NewNote", response.getReturnValue().NewNote);
                        cmp.set("v.NewNoteTemp", response.getReturnValue().NewNote);
                        cmp.set("v.SelectedAttachments", response.getReturnValue().SelectedAttachments);
                        cmp.set("v.signatureExist", false);
                        cmp.set("v.tasklists",response.getReturnValue().tasklist);
                        var WOtasks = cmp.get("v.Tasks");
                        //alert(cmp.get("v.taskStatus"));
                        var showSave = false;
                        for(var i in WOtasks){
                            if(WOtasks[i].ERP7__Status__c == cmp.get("v.taskStatus")){
                                cmp.set("v.isWOcomplete", false);
                                cmp.set('v.showcheck',false);
                                showSave = false;
                            }
                            else{
                                cmp.set("v.isWOcomplete", true);
                                cmp.set('v.showcheck',true);
                                showSave = true;
                                break;
                            }
                        }
                        cmp.set('v.showTaskSave',showSave);
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
                        cmp.set("v.AllmoSerialNos", response.getReturnValue().moSerialNos);
                        cmp.set("v.moSerialNos", response.getReturnValue().moSerialNos);
                        cmp.set("v.moBatchNos", response.getReturnValue().moBatchNos);
                        cmp.set("v.NWO", response.getReturnValue().nextWO);
                        cmp.set("v.PWO", response.getReturnValue().prevWO);
                        cmp.set("v.AllWOs", response.getReturnValue().AllWOs);
                        cmp.set("v.ToProduce", 0); cmp.set("v.ToScrap", 0);
                        cmp.set("v.WIPs", response.getReturnValue().WIPs);
                        console.log('1: ');
                        var flows = response.getReturnValue().WIPFlows;
                        cmp.set('v.AllWIPFlows',flows);
                        // Start --> Restrict display of unfulfilled WIPFlows - Imran Khan - 6/7/23
                        /* commented SM 14/09/23 if(response.getReturnValue().WIPFlows.length > 0 && response.getReturnValue().manuOrders.ERP7__Product__r.ERP7__Serialise__c == true){
                            var customFlows = [];
                            for(var i in flows){
                                flows[i].StockAllocated = false;
                                if(flows[i].wipFlow.ERP7__WIP__r.ERP7__Serial_Number__c != undefined && flows[i].wipFlow.ERP7__WIP__r.ERP7__Serial_Number__c != null && ((flows[i].wipFlow.ERP7__Quantity__c + flows[i].wipFlow.ERP7__Quantity_Scrapped__c) != flows[i].wipFlow.ERP7__Quantity_Ordered__c)){
                                    var SN = flows[i].wipFlow.ERP7__WIP__r.ERP7__Serial_Number__c;
                                    console.log('SN : ',SN);
                                       //alert(obj.length);
                                    var mrpCount = 0;
                                    var countFulfilled = 0;// removed from obj loop and added above as the WIPs were not showing
                                    for(var x in obj){
                                        var bomQuantity = 0;
                                              var soli = obj[x].SOLIs;
                                        if(soli != undefined && soli.length > 0){
                                            for(var y in soli){
                                                var bomQuantity = (obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c != undefined)? (obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c) : 0; // added obj[x].WeightMultiplier
                                                console.log('soli[y].ERP7__Quantity__c : '+soli[y].ERP7__Quantity__c);
                                                console.log('obj[x].WeightMultiplier : '+obj[x].WeightMultiplier);
                                                if(SN == soli[y].ERP7__MO_WO_Serial__c){
                                                    var soliQty = (soli[y].ERP7__Quantity__c * obj[x].WeightMultiplier);
                                                    console.log('soliQty : ',soliQty);
                                                    console.log('in if : ',countFulfilled);
                                                    countFulfilled += soliQty;
                                                }
                                               // else if(soli[y].ERP7__MO_WO_Serial__c == null && obj[x].MRP.Id == soli[y].ERP7__MRP_Material_Requirements_Planning__c) countFulfilled += soliQty; // added by shaguftha
                                            }
                                        }
                                        countFulfilled = parseFloat(countFulfilled).toFixed(4);
                                        bomQuantity = parseFloat(bomQuantity).toFixed(4);
                                       console.log('countFulfilled : ',countFulfilled);
                                        console.log('bomQuantity : ',bomQuantity);
                                        if(countFulfilled > 0 && countFulfilled >= bomQuantity) mrpCount++; //changed from == to >= by shaguftha
                                        console.log('mrpCount : ',mrpCount);
                                    }

                                    if(mrpCount == obj.length){
                                        flows[i].StockAllocated = true;
                                        customFlows.push(flows[i]);
                                        if(customFlows.length == cmp.get('v.WipflowsShowforBuild')) break;
                                    }
                                }
                            }
                            flows = customFlows;
                            console.log('flows : ',JSON.stringify(customFlows));
                        } */
                        // End --> Restrict display of unfulfilled WIPFlows - Imran Khan - 6/7/23

                        var qtyBuild =0;
                        var onlyProducedWIPs = [];
                        if(response.getReturnValue().WIPFlows.length > 0){
                            for(var i in flows){
                                if(flows[i].wipFlow.ERP7__Type__c == 'Produced' || flows[i].wipFlow.ERP7__Type__c == 'Processed'){
                                    qtyBuild += flows[i].wipFlow.ERP7__Quantity__c;
                                }
                                if(flows[i].wipFlow.ERP7__Quantity__c > 0 || flows[i].wipFlow.ERP7__Quantity_Scrapped__c > 0){
                                    onlyProducedWIPs.push(flows[i].wipFlow);
                                }
                            }
                        }
                        console.log('2: ');

                        if(qtyBuild > 0) cmp.set('v.showCompleteWO',true);
                        else cmp.set('v.showCompleteWO',false);
                        if(cmp.get('v.hideToProduceforMRP') && ConsumedMRPCount > 0) cmp.set('v.showCompleteWO',true);
                        cmp.set('v.onlyManufacturedWIPFlows',onlyProducedWIPs);
                        console.log('onlyManufacturedWIPFlows : ',onlyProducedWIPs);
                        cmp.set("v.WIPFlows", flows);
                        cmp.set("v.SearchWIPFlows", flows);
                        console.log('flows WIP: ',JSON.stringify(cmp.get("v.WIPFlows")));
                        if(cmp.get('v.WorkOrder.ERP7__Status__c') == 'Complete') cmp.set('v.SelectedWIPflow','');
                        else{
                            if(cmp.get('v.SelectedWIPflow') == null || cmp.get('v.SelectedWIPflow') == '' || cmp.get('v.SelectedWIPflow') == undefined ){
                                cmp.set('v.SelectedWIPflow',cmp.get('v.WIPFlows[0].wipFlow'));
                            }else cmp.set('v.SelectedWIPflow',cmp.get("v.SelectedWIPflow"));
                        }
                        console.log('SelectedWIPflow init : ',JSON.stringify(cmp.get("v.SelectedWIPflow")));
                        cmp.set("v.RAS", response.getReturnValue().RAS);
                        cmp.set("v.WorkPlanners", response.getReturnValue().WorkPlanners);
                        if(response.getReturnValue().WorkOrder.ERP7__Start_Date__c != undefined) cmp.set("v.StartTime",response.getReturnValue().WorkOrder.ERP7__Start_Date__c);
                        if(response.getReturnValue().WorkOrder.ERP7__Expected_Date__c != undefined) cmp.set("v.EndTime",response.getReturnValue().WorkOrder.ERP7__Expected_Date__c);
                        cmp.set("v.CapacityPlanner", response.getReturnValue().CapacityPlanner);
                        cmp.set("v.AvailableResources",response.getReturnValue().AvailableResources);
                        console.log('inhere before');
                         try{
                             cmp.set("v.WPoptions", response.getReturnValue().wpList);

                           //cmp.find("wpList").set("v.options", response.getReturnValue().wpList)
                        }catch(e){
                            console.log('err~>'+e);
                        }
                        var OA = [];
                        OA = cmp.get("v.OperationAttachments");
                        var att = "";
                        for(var i=0; i<OA.length; i++){
                            att = OA[i].Attachments;
                            if(att.length > 0)
                                cmp.set("v.checkDrawings",true);
                            else  cmp.set("v.checkDrawings",false);
                        }
                        //var ik = cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c");
                        if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == "In Progress"){
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
                                if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In Progress') {
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

                        /*var checklist = response.getReturnValue().checklist;
                        helper.getpicklistValues(cmp, event,checklist);
                        cmp.set('v.guidelinechecklist',response.getReturnValue().guidelines);
                        cmp.set('v.guidelinexits',response.getReturnValue().recordCreated);
                        //cmp.set("v.Checklist", );
                        var check = cmp.get('v.Checklist'); */
                        if(cmp.get('v.showSearchWIP') && cmp.get('v.AllWIPFlows.length') > 0) {
                            helper.getSearchDetails(cmp, event);
                            if(cmp.get('v.fPage')){
                                var getWIPsAction = cmp.get("c.getWIPs");
                                console.log('getWIPsAction calling');
                                $A.enqueueAction(getWIPsAction);
                            }
                        }
                        console.log('inhere atlast');
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }catch(e){
                        console.log('err occured~>'+e);
                    }
                } else{
                    var error = response.getError();
                    console.log('error: ',error);
                    if(error != undefined) cmp.set("v.exceptionError", error[0].message);
                    ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);

        },

        ReloadAll : function(cmp, event, helper) {
            cmp.set("v.IsSignatureTab",false);
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var woId = cmp.get("v.WO");
            var vrd = cmp.get("v.RD");
            var action = cmp.get("c.getAll");
            var countDownDate;
            action.setParams({woId:woId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                    //if(!$A.util.isEmpty(cmp.get("v.exceptionError"))) //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                    cmp.set("v.Attachment", response.getReturnValue().SelectedAttachment);
                    //cmp.set("v.SelectedTask", response.getReturnValue().SelectedTask);
                    cmp.set("v.NewTask", response.getReturnValue().NewTask);
                    cmp.set("v.TimeSheet", response.getReturnValue().TimeSheet);
                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                    if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == "In Progress"){
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
                            if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In Progress') {
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
                    cmp.set("v.exceptionError", response.getError());
                    ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                }
            });
            $A.enqueueAction(action);
        },

        Reload1 : function (cmp, event) {
            document.getElementById("rot1").classList.add("erp-rotation");
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
                            if(response.getReturnValue().errorMsg != ''){
                                cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                                ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            }
                            else {
                                cmp.popInit();
                            }
                        } else {
                            cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
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
                            if(response.getReturnValue().errorMsg != ''){
                                cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                                ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            }
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
                                cmp.set("v.exceptionError","");
                            }
                        } else {
                            cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                            // //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
            cmp.set("v.raPage",true);
            //$A.util.addClass(cmp.find("myResourceAllocationModal"), 'slds-fade-in-open');
            //$A.util.addClass(cmp.find("myResourceAllocationModalBackdrop"),"slds-backdrop_open");
        },

        manageScreen: function(cmp, event) {
            if(cmp.get("v.saPage") || cmp.get("v.fPage") || cmp.get("v.raPage")) cmp.set("v.mainPage",false);
            else cmp.set("v.mainPage",true);
        },

        lookupClickBatch :function(cmp,helper){
            try{
                console.log('component.get("v.ManuOrder")~>'+JSON.stringify(cmp.get("v.ManuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c));

                var siteId = '';
                if(cmp.get("v.ManuOrder").ERP7__Routing__c != undefined && cmp.get("v.ManuOrder").ERP7__Routing__c != null){
                    if(cmp.get("v.ManuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != undefined && cmp.get("v.ManuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != null){
                        siteId = cmp.get("v.ManuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                    }
                }

                console.log('siteId~>'+siteId);

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

                qry += ' AND ERP7__Product__c != null AND ERP7__Active__c = true AND ERP7__Expired__c = false AND ERP7__Available_Quantity__c > 0 ';
                if(siteId != '') qry += ' AND ERP7__Received_site__c Like \'%'+siteId+'%\' ';

                console.log('final batch qry~>'+qry);

                cmp.set("v.qry",qry);
                //alert(qry);

            }catch(e){
                console.log('lookupClickBatch err~>',e);
            }
        },

        lookupClickSerial :function(cmp,helper){
            try{
                console.log('component.get("v.ManuOrder")~>'+JSON.stringify(cmp.get("v.ManuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c));

                var siteId = '';
                if(cmp.get("v.ManuOrder").ERP7__Routing__c != undefined && cmp.get("v.ManuOrder").ERP7__Routing__c != null){
                    if(cmp.get("v.ManuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != undefined && cmp.get("v.ManuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != null){
                        siteId = cmp.get("v.ManuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                    }
                }

                console.log('siteId~>'+siteId);

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

                qry += ' And ERP7__Available__c = true AND ERP7__Expired__c = false AND ERP7__Scrap__c = false ';
                if(siteId != '') qry += ' AND ERP7__Warehouse__c = \''+siteId+'\' ';

                console.log('final serial qry~>'+qry);

                cmp.set("v.qry",qry);
                //alert(qry);
            }catch(e){
                console.log('lookupClickBatch err~>',e);
            }
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
            cmp.set("v.exceptionError", "");
            cmp.set("v.Task",cmp.get("v.NewTask"));
            cmp.set("v.Task.Name", "");
            $A.util.addClass(cmp.find("newTaskModal"),"slds-fade-in-open");
            $A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
        },

        NewNote : function(cmp, event, helper) {
            cmp.set("v.exceptionError", "");
            cmp.set("v.NewNote",cmp.get("v.NewNoteTemp"));
            cmp.set("v.NewNote.Title", "");
            cmp.set("v.NewNote.Body", "");
            cmp.set("v.NewNote.isPrivate", false);
            $A.util.addClass(cmp.find("newTaskNoteModal"),"slds-fade-in-open");
            $A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
        },

        UpdateTask : function(cmp, event, helper) {
            cmp.set("v.exceptionError", "");
            cmp.set("v.Task",cmp.get("v.SelectedTask"));
            $A.util.addClass(cmp.find("newTaskModal"),"slds-fade-in-open");
            $A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
        },

        ReloadNew : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find("newTaskModal"),"slds-fade-in-open");
            $A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
            $A.util.removeClass(cmp.find("newTaskNoteModal"),"slds-fade-in-open");
        },

        SaveTask : function(cmp, event, helper) {
            //alert('In');
            var Task = cmp.get("v.Task");
            var WO = cmp.get("v.WorkOrder");
            if(Task.ERP7__Finished_Quantity__c > WO.ERP7__Quantity_Ordered__c){
                cmp.set("v.exceptionError", $A.get('$Label.c.Finished_Quantity_cannot_be_greater_than_Quantity_Ordered'));
                ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
            }

            else if(Task.Name == '' || Task.Name == null || Task.Name == undefined){
                cmp.set("v.exceptionError", $A.get('$Label.c.Enter_the_task_Name'));
            }
                else if(Task.ERP7__Operation__c == '' || Task.ERP7__Operation__c == null || Task.ERP7__Operation__c == undefined){
                    cmp.set("v.exceptionError", $A.get('$Label.c.Please_Select_the_Operation'));
                }
                    else if(Task.ERP7__Process_Cycle__c == '' || Task.ERP7__Process_Cycle__c == null || Task.ERP7__Process_Cycle__c == undefined){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Please_Select_the_Process_cycle'));
                    }
                        else if(Task.ERP7__Work_Center__c == '' || Task.ERP7__Work_Center__c == null || Task.ERP7__Work_Center__c == undefined){
                            cmp.set("v.exceptionError", $A.get('$Label.c.Please_Select_the_Work_center'));
                        }
                            else{
                                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                                var t = JSON.stringify(cmp.get("v.Task"));
                                var action = cmp.get("c.SaveAction");
                                action.setParams({task:t});
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    //alert(state);
                                    cmp.set("v.exceptionError", "");
                                    if (state === "SUCCESS") {
                                        if(response.getReturnValue().errorMsg == ''){
                                            $A.util.removeClass(cmp.find("newTaskModal"),"slds-fade-in-open");
                                            $A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
                                            cmp.popInit();
                                        }
                                        else{
                                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                                            ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                        }
                                    }
                                    else{
                                        var errors = response.getError();
                                        cmp.set("v.exceptionError", errors[0].message);
                                        ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                cmp.set("v.exceptionError",$A.get('$Label.c.Required_fields_missing'));
                ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
            }
            else{
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                NewNote.ParentId = SelectedTask.Id;
                var t = JSON.stringify(NewNote);
                //alert(t);
                var action = cmp.get("c.SaveNotes");
                action.setParams({NN:t});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    cmp.set("v.exceptionError", "");
                    if (state === "SUCCESS") {
                        $A.util.removeClass(cmp.find("newTaskNoteModal"),"slds-fade-in-open");
                        $A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
                        //cmp.popInit();
                        cmp.set("v.SelectedNotes", response.getReturnValue());
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else{
                        cmp.set("v.exceptionError", response.getError());
                        ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                cmp.set("v.exceptionError", "");
                if (state === "SUCCESS") {
                    //cmp.popInit();
                    cmp.set("v.SelectedAttachments", response.getReturnValue());
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                    else{
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    ////setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                    else{
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                }
            });
            $A.enqueueAction(action);
        },

    /*  onFileUploaded: function (cmp, event, helper) {
        try {
            console.log('onFileUploaded called');
            var files = cmp.get("v.FileList");
            var SelTask = cmp.get("v.SelectedTask");
            var totalRequestSize = 0;

            if (files && files.length > 0) {
                // Check total request size and individual file sizes
                for (let i = 0; i < files.length; i++) {
                    const file = files[i][0];
                    const fileSize = file.size;

                    // Check individual file size (max 2 MB)
                    if (fileSize > 2000000) {
                        helper.showToast('Error', 'error', 'File ' + file.name + ' exceeds the 2 MB limit.');
                        return;
                    }

                    // Accumulate total request size
                    totalRequestSize += fileSize;

                    // Check total request size (max 6 MB)
                    if (totalRequestSize > 6000000) {
                        helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                        return;
                    }
                }

                var file = files[0][0]; // Handle the first file
                var reader = new FileReader();

                reader.onloadend = function () {
                    var contents = reader.result;
                    var base64Mark = 'base64,';
                    var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                    var fileContents = contents.substring(dataStart);
                    var action = cmp.get("c.uploadFile");
                    cmp.set("v.showLoadingSpinner", true);

                    action.setParams({
                        parent: SelTask.Id,
                        fileName: file.name,
                        base64Data: encodeURIComponent(fileContents),
                        contentType: file.type
                    });

                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        console.log('state : ', state);
                        if (state === "SUCCESS") {
                            console.log('res : ', response.getReturnValue());
                            cmp.set("v.SelectedAttachments", response.getReturnValue());
                            cmp.set("v.showLoadingSpinner", false);
                        } else {
                            console.log('error : ', response.getError());
                        }
                    });
                    $A.enqueueAction(action);
                };
                reader.readAsDataURL(file);
            }
        } catch (e) {
            console.log('error upload : ', e);
        }

            /* var files = cmp.get("v.FileList");
            var file = files[0][0];
            var filek = JSON.stringify(file);
            var SelTask = cmp.get("v.SelectedTask");
            if (files.length > 0) { //files &&
               $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var reader = new FileReader();
                reader.onloadend = function() {
                    var contents = reader.result;
                    var base64Mark = 'base64,';
                    var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                    var fileContents = contents.substring(dataStart);
                    var fileAction = cmp.get("c.uploadFile");
                    fileAction.setParams({
                        parent: SelTask.Id,
                        fileName: file.name,
                        base64Data: encodeURIComponent(fileContents),
                        contentType: file.type
                    });
                    fileAction.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            //alert(response.getReturnValue());
                            reader.readAsDataURL(file);
                            cmp.set("v.SelectedAttachments", response.getReturnValue());
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        } else $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                    });
                    $A.enqueueAction(fileAction);
                }
            }
        },*/
     onFileUploaded : function(cmp, event, helper) {
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//7
        cmp.set("v.showSpinner",true);
        try{
            let files = cmp.get("v.FileList");
             var totalRequestSize = 0;
            for (let i = 0; i < files[0].length; i++) {
                let file = files[0][i];

    // Validate individual file size (max 2 MB) before processing
    if (file.size > 2000000) {
        helper.showToast("Error", "error", "File " + file.name + " exceeds the 2 MB limit.");
        cmp.set("v.showSpinner", false);
        return; // Skip processing for this file
    }
             totalRequestSize += file.size;
console.log("totalRequestSize",totalRequestSize);
            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                cmp.set("v.showSpinner", false);
                return;
            }}
console.log('FileList : ', JSON.stringify(FileList));
            let fileNameList = [];
            let base64DataList = [];
            let contentTypeList = [];

            if (files && files.length > 0) {
                let parentId = event.getSource().get("v.name");
                console.log('files : ',files.length);
                console.log('files[0] : ',files[0].length);
                if(files[0].length > 0){
                    for (let i = 0; i < files[0].length; i++) {
                         var totalRequestSize = 0;

       /* for ( i = 0; i < files.length; i++) {
            var fileSize = files[i][0].size;

            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + files[i][0].name + ' exceeds the 2 MB limit.');
                return;
            }

            totalRequestSize += fileSize;

            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                return;
            }
        }*/
                        console.log('i~>'+i);
                        let file = files[0][i];
                        let reader = new FileReader();
                        //reader.onloadend is asynchronous using let instead of var inside for loop arshad
                        reader.onloadend = function() {

                            console.log('inside reader.onloadend');
                            let contents = reader.result;
                            let base64Mark = 'base64,';
                            let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                            let fileContents = contents.substring(dataStart);


                            fileNameList.push(file.name);
                            base64DataList.push(encodeURIComponent(fileContents));
                            contentTypeList.push(file.type);


                            console.log('fileNameList~>'+fileNameList.length);
                            console.log('base64DataList~>'+base64DataList.length);
                            console.log('contentTypeList~>'+contentTypeList.length);

                            if(fileNameList.length == files[0].length){
                            helper.finishAllFilesUpload(parentId,fileNameList,base64DataList,contentTypeList,cmp,event,helper);
                            }else console.log('notequal');
                        }
                        reader.onerror = function() {
                            console.log('for i~>'+i+' err~>'+reader.error);
                            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//8
                            cmp.set("v.showSpinner",false);
                        };
                        reader.readAsDataURL(file);
                    }
                }
            }
        }catch(err){
            console.log("Error catch:",err);
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//9
            cmp.set("v.showSpinner",false);
        }

    },

        SelectTask : function(cmp, event, helper) {
            var count = event.currentTarget.getAttribute('data-mosoliId');
            var obj = cmp.get("v.Tasks");
            var objsel;
            for(var x in obj){
                if(x == count) {
                    objsel = obj[count];
                    break;
                }
            }
            if(objsel.Id != cmp.get("v.SelectedTask.Id")){
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
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
                                cmp.set("v.MRPSS", response.getReturnValue().MRPS);
                                console.log('MRPSS SelectTasks: ',response.getReturnValue());
                                cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                                cmp.set("v.Permit", response.getReturnValue().Permit);
                                cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                                cmp.set("v.Busy",response.getReturnValue().Busy);
                                //cmp.set('v.guidelinexits',response.getReturnValue().recordCreated);
                                //cmp.set('v.Checklist',response.getReturnValue().checklist);
                                //cmp.set('v.guidelinechecklist',response.getReturnValue().guidelines);

                                //if(cmp.get('v.guidelinechecklist').length > 0) cmp.set('v.guidelinexits',true);
                                if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == 'In Progress'){
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

                                        if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In Progress') {
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
                                //if(cmp.get("v.SelectedTask.ERP7__Status__c") == 'Completed') cmp.popInit();
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");

                            } catch(err){  }
                        }
                        else{
                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
                    } else{
                        cmp.set("v.exceptionError", response.getError());
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                });
                $A.enqueueAction(action);
            }
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
                        if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == 'In Progress'){
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

                                if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In Progress') {
                                    clearInterval(x);
                                    cmp.set("v.Timer","");
                                }
                            }), 1000);
                        } else cmp.set("v.Timer","");
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                    else{
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                        cmp.set("v.Permit", response.getReturnValue().Permit);
                        cmp.set("v.Busy", response.getReturnValue().Busy);
                        cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                        cmp.set("v.Timer","");
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                    else{
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                }
            });
            $A.enqueueAction(action);
        },

        StopTimeCard : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var target = event.getSource();
            var count = target.get("v.value");
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
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        cmp.popInit();
                    }
                    else{
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                }
            });
            $A.enqueueAction(action);
        },

        SelectAttachment : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            // var target = event.getSource();
            var count =event.target.getAttribute("title");
            //target.getElement().parentElement.name;
            var par = event.target.getAttribute("id");
            //target.getElement().parentElement.par;
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
                // else break;
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
                var action = cmp.get("c.DeleteAction");
                action.setParams({tId:Id});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().errorMsg == ''){
                            //alert('popinit');
                            cmp.popInit();
                        }
                        else{
                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
                    } else{
                        cmp.set("v.exceptionError", response.getError());
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                });
                $A.enqueueAction(action);
            }
        },

        StartTask : function(cmp, event, helper) {
            console.log('StartTask : ');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var count = event.getSource().get('v.name');
            console.log('count : ',count);
            var obj = cmp.get("v.Tasks");
            var objsel;
            for(var x in obj){
                if(obj[x].Id == count) {
                    objsel = obj[x];
                    break;
                }
            }
            var Task = cmp.get("v.SelectedTask");
            if(Task.Id != objsel.Id) cmp.set("v.SelectedTask",objsel);
            Task = cmp.get("v.SelectedTask");
            var TimeSheet = cmp.get("v.TimeSheet");
            Task.ERP7__Status__c = "In Progress";
            var WO = cmp.get("v.WorkOrder");
            var MRPS = cmp.get("v.MRPSS");
            var action = cmp.get("c.TaskUpdate");
            console.log('tasklists : ',JSON.stringify(cmp.get('v.tasklists')));
            action.setParams({
                Task1:JSON.stringify(Task),
                WO1:JSON.stringify(WO),
                MRPS1:JSON.stringify(MRPS)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        console.log('TaskUpdate : ',response.getReturnValue().Tasks);
                        console.log('SelectedTask : ',response.getReturnValue().SelectedTask);
                        cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                        cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                        cmp.set("v.Tasks", response.getReturnValue().Tasks);
                        var tasklist =  cmp.get('v.tasklists');
                        for(var x in tasklist){
                            if(tasklist[x].Task.Id == Task.Id){
                                tasklist[x].Task = cmp.get("v.SelectedTask");
                                break;
                            }
                        }
                         cmp.set("v.tasklists", tasklist);
                        cmp.set("v.Busy", response.getReturnValue().Busy);
                        cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                        cmp.set("v.Permit", response.getReturnValue().Permit);

                        if(cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") != undefined && cmp.get("v.SelectedTask.ERP7__Status__c") == 'In Progress'){
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
                                if (distance < 0 || cmp.get("v.SelectedTask_TimeCardEntry.ERP7__Start_Time__c") == undefined || cmp.get("v.SelectedTask.ERP7__Status__c") != 'In Progress') {
                                    clearInterval(x);
                                    cmp.set("v.Timer","");
                                }
                            }), 1000);

                        } else cmp.set("v.Timer","");
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                    else{
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                } else{
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.exceptionError",errors[0].message);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            console.log("ERROR msg > ",errors[0]);
                        }
                    } else {
                        component.set("v.exceptionError","Unknown error");
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
        },

        PauseTask : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var count = event.getSource().get('v.name');
            var obj = cmp.get("v.Tasks");
            var objsel;
            for(var x in obj){
                if(obj[x].Id == count) {
                    objsel = obj[x];
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
                Task1:JSON.stringify(Task),
                WO1:JSON.stringify(WO),
                MRPS1:JSON.stringify(MRPS)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                        cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                        cmp.set("v.Tasks", response.getReturnValue().Tasks);
                        var tasklist =  cmp.get('v.tasklists');
                        for(var x in tasklist){
                            if(tasklist[x].Task.Id == Task.Id){
                                tasklist[x].Task = cmp.get("v.SelectedTask");
                                break;
                            }
                        }
                         cmp.set("v.tasklists", tasklist);
                        cmp.set("v.Busy", response.getReturnValue().Busy);
                        cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                        cmp.set("v.Permit", response.getReturnValue().Permit);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                    else{
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                } else{
                    cmp.set("v.exceptionError", response.getError());
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
        },

        PreFinishTask : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //var count = event.getSource().get('v.name');
            /*var obj = cmp.get("v.Tasks");
            var objsel;
            for(var x in obj){
                if(obj[x].Id == count) {
                    objsel = obj[x];
                    break;
                }
            }
            cmp.set("v.SelectedTask",objsel);*/
            var Task = cmp.get("v.SelectedTask");
            var tasklist = cmp.get("v.tasklists");
            for(var x in tasklist){
                if(tasklist[x].Task.Id == Task.Id){
                    if(tasklist[x].checklists != undefined && tasklist[x].checklists != null && tasklist[x].checklists.length > 0){
                        for(var y in tasklist[x].checklists){
                            if(tasklist[x].checklists[y].ERP7__Is_Mandatory__c){
                                console.log('1');
                                console.log('2 : ',tasklist[x].checklists[y].ERP7__Instructions__c);
                                if(tasklist[x].checklists[y].ERP7__Instructions__c == undefined || tasklist[x].checklists[y].ERP7__Instructions__c == null || tasklist[x].checklists[y].ERP7__Instructions__c == '' || tasklist[x].checklists[y].ERP7__Instructions__c == '--None--' || tasklist[x].checklists[y].ERP7__Instructions__c == 'Pending'){

                                    cmp.set('v.exceptionError',$A.get('$Label.c.Please_complete_the_checklists')+' : ' +tasklist[x].checklists[y].Name);
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    cmp.set("v.SelectedTask.ERP7__Status__c", tasklist[x].Task.ERP7__Status__c);
                                    return;
                                }
                                else{
                                    tasklist[x].checklists[y].ERP7__Action_Task__c = tasklist[x].Task.Id;
                                }
                            }
                        }
                    }
                }
            }

            var checklistAction = cmp.get('c.SaveTaskValues');
            checklistAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                   // cmp.set("v.tasklists",response.getReturnValue().tasklist);
                    var TimeSheet = cmp.get("v.TimeSheet");
                    cmp.set("v.ToProduce",0);
                    cmp.set("v.exceptionError","");
                    cmp.set("v.exceptionError","");
                    var WO = cmp.get("v.WorkOrder");

                    var action = cmp.get("c.PreTaskFinish");
                    action.setParams({Task1:JSON.stringify(Task)});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            if(response.getReturnValue().errorMsg == ''){
                                //cmp.set("v.MRPSS",response.getReturnValue().MRPSS);
                                //cmp.set("v.Serial",response.getReturnValue().Serial);
                                //cmp.set("v.Batch",response.getReturnValue().Batch);
                                cmp.set("v.allWOProducts", response.getReturnValue().WOproducts);
                                if(response.getReturnValue().MRPS.length > 0){
                                    //$A.util.addClass(cmp.find("prodQtyModal"),"slds-fade-in-open");
                                    //$A.util.addClass(cmp.find("prodQtyModalBackdrop"),"slds-backdrop_open");
                                    cmp.set("v.ToProduce", Task.ERP7__Finished_Quantity__c);

                                    var MRPSS = cmp.get("v.MRPSS");
                                    var ToProduce = cmp.get("v.ToProduce");
                                    var WO = cmp.get("v.WorkOrder");
                                    for(var x in MRPSS){
                                        var qtytoConsume = 0;
                                        if(WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) && MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) qtytoConsume = 1;
                                        else qtytoConsume = (WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c ))? (MRPSS[x].MRP.ERP7__Total_Amount_Required__c*ToProduce)/WO.ERP7__Quantity_Ordered__c : 0;
                                        MRPSS[x].quantityToConsume = qtytoConsume; //Math.round((qtytoConsume + Number.EPSILON) * 100) / 100;
                                    }
                                    cmp.set("v.MRPSS",MRPSS);
                                    var WOtasks = cmp.get("v.Tasks");

                                    if(WOtasks.length == 1) cmp.set('v.showcheck',false);
                                    for(var i in WOtasks){
                                        if(WOtasks[i].ERP7__Status__c == cmp.get("v.taskStatus")){
                                            cmp.set("v.isWOcomplete", false);
                                            cmp.set('v.showcheck',false);
                                        }
                                        else{
                                            cmp.set("v.isWOcomplete", true);
                                            cmp.set('v.showcheck',true);
                                            break;
                                        }
                                    }
                                }
                                else{
                                    var WO1 = cmp.get("v.WorkOrder");
                                    var MRPS = cmp.get("v.MRPSS");
                                    Task.ERP7__Status__c = cmp.get("v.taskStatus"); //"Completed";
                                    var action = cmp.get("c.TaskUpdate");
                                    action.setParams({
                                        Task1:JSON.stringify(Task),
                                        WO1:JSON.stringify(WO1),
                                        MRPS1:JSON.stringify(MRPS)
                                    });
                                    action.setCallback(this, function(response) {
                                        if (response.getState() === "SUCCESS") {
                                            if(response.getReturnValue().errorMsg == ''){
                                                cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                                                cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                                                cmp.set("v.Tasks", response.getReturnValue().Tasks);
                                                cmp.set("v.tasklists",response.getReturnValue().tasklist);
                                                cmp.set("v.Busy", response.getReturnValue().Busy);
                                                cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                                                cmp.set("v.Permit", response.getReturnValue().Permit);
                                                var WOtasks = cmp.get("v.Tasks");
                                                if(WOtasks.length == 1) cmp.set('v.showcheck',false);
                                                for(var i in WOtasks){
                                                    if(WOtasks[i].ERP7__Status__c == cmp.get("v.taskStatus")){
                                                        cmp.set("v.isWOcomplete", false);
                                                        cmp.set('v.showcheck',false);
                                                    }
                                                    else{
                                                        cmp.set("v.isWOcomplete", true);
                                                        cmp.set('v.showcheck',true);
                                                        break;
                                                    }
                                                }
                                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                            }
                                            else {
                                                console.log("error -> ", response.getReturnValue().errorMsg);
                                                cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                                                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                            }
                                        } else{
                                            console.log("error -> ", response.getError());
                                            cmp.set("v.exceptionError", response.getError());
                                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                        }
                                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    });
                                    $A.enqueueAction(action);
                                }
                            }
                            else{
                                cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            }
                        } else{
                            cmp.set("v.exceptionError", response.getError());
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
                    });
                    $A.enqueueAction(action);
                }
            });
            $A.enqueueAction(checklistAction);
        },

        closeProdQtyModal : function(cmp, event){
            $A.util.removeClass(cmp.find("prodQtyModal"),"slds-fade-in-open");
            $A.util.removeClass(cmp.find("prodQtyModalBackdrop"),"slds-backdrop_open");
        },
         imageError: function(component,event,helper){
            console.log('imageError called');
            event.target.style.display = 'none';
        },

        PartialFinishTask : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var Task = cmp.get("v.SelectedTask");
            var WO = cmp.get("v.WorkOrder");
            var MRPS = cmp.get("v.MRPSS");
            var TimeSheet = cmp.get("v.TimeSheet");
            cmp.set("v.exceptionError", "");
            var error = false;
            var errorMrp = false;
            if(WO.ERP7__Quantity_Built__c > WO.ERP7__Quantity_Ordered__c){
                cmp.set("v.exceptionError", $A.get('$Label.c.Built_quantity_cannot_be_greater_than_ordered_quantity'));
                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                error = true;
            }
            if(!error){
                for(var x in MRPS){
                    if(MRPS[x].ERP7__Total_Amount_Required__c  < (MRPS[x].ERP7__Consumed_Quantity__c + MRPS[x].ERP7__Scrapped_Quantity__c)){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot_be_greater_than_fulfilled_quantity'));
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                    }
                }
            }
            if(!error) {
                var action = cmp.get("c.TaskUpdatePartial");
                action.setParams({Task1:JSON.stringify(Task),WO1:JSON.stringify(WO),MRPS1:JSON.stringify(MRPS)});
                action.setCallback(this, function(response) {
                    var state = response.getState();
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
                            $A.util.removeClass(cmp.find("prodQtyModal"),"slds-fade-in-open");
                            $A.util.removeClass(cmp.find("prodQtyModalBackdrop"),"slds-backdrop_open");
                            //cmp.popInit();
                        }
                        else{
                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
                    } else{
                        cmp.set("v.exceptionError", response.getError());
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                cmp.set("v.exceptionError",  $A.get('$Label.c.Built_quantity_cannot_be_greater_than_ordered_quantity'));
                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                error = true;
            }
            if(!error){
                for(var x in MRPS){
                    if(MRPS[x].ERP7__Total_Amount_Required__c  != (MRPS[x].ERP7__Consumed_Quantity__c + MRPS[x].ERP7__Scrapped_Quantity__c)){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot_be_greater_than_fulfilled_quantity'));
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                    }
                }
            }
            if(!error) {
                Task.ERP7__Status__c = cmp.get("v.taskStatus"); //"Completed";
                var action = cmp.get("c.TaskUpdate");
                action.setParams({
                    Task1:JSON.stringify(Task),
                    WO1:JSON.stringify(WO),
                    MRPS1:JSON.stringify(MRPS)
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();

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
                            $A.util.removeClass(cmp.find("prodQtyModal"),"slds-fade-in-open");
                            $A.util.removeClass(cmp.find("prodQtyModalBackdrop"),"slds-backdrop_open");
                            //cmp.popInit();
                        }
                        else{
                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
                    } else{
                        cmp.set("v.exceptionError", response.getError());
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                });
                $A.enqueueAction(action);
            }else{
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        },

        CommitTask : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var wipStatus = '';
            if(event.currentTarget != undefined) {
                wipStatus = event.currentTarget.dataset.record;
                cmp.set("v.wipFlowIndex", event.currentTarget.dataset.index);
            }
            var Task = cmp.get("v.SelectedTask");
            var WO = cmp.get("v.WorkOrder");
            //var MRPS = cmp.get("v.MRPS");
            var MRPSS = cmp.get("v.MRPSS");
            var ToProduce = cmp.get("v.ToProduce");
            cmp.set("v.exceptionError", "");
            var error = false;
            var finish = true;
            //var eval = cmp.get("v.Evaluate");
            if(ToProduce == null || (Number(WO.ERP7__Quantity_Built__c) + Number(ToProduce)) > WO.ERP7__Quantity_Ordered__c){
                cmp.set("v.exceptionError",  $A.get('$Label.c.Built_quantity_cannot_be_greater_than_ordered_quantity'));
                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                error = true;
            }
            if(!error){
                for(var x in MRPSS){
                     let mrp =MRPSS[x].MRP ;
                    if(mrp.ERP7__Total_Amount_Required__c > 0 && mrp.ERP7__Fulfilled_Amount__c == 0){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Please_allocate_stock_to_consume'));
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                        break;
                    }
                    if(MRPSS[x].quantityToConsume == null || MRPSS[x].quantityToScrap == null){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Required_fields_missing'));
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                        break;
                    }
                    if(MRPSS[x].MRP.ERP7__Fulfilled_Amount__c < (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap)){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot_be_greater_than_fulfilled_quantity'));
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                        break;
                    }
                   /* commented by shaguftha on 07/11/2023
                    * if(MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && (MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap > 1)){
                        cmp.set("v.exceptionError", "Sum of consumed and scrapped quantity cannot be greater than one for Serialised product");
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                        break;
                    }*/
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
                    var qtytoconsume = 0; var qtytoscarp = 0;
                    qtytoconsume = MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].quantityToConsume;
                    MRPSS[x].MRP.ERP7__Consumed_Quantity__c = qtytoconsume; //Math.round((qtytoconsume + Number.EPSILON) * 100) / 100;
                    qtytoscarp =  MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToScrap;
                    MRPSS[x].MRP.ERP7__Scrapped_Quantity__c = qtytoscarp; //Math.round((qtytoscarp + Number.EPSILON) * 100) / 100;

                }
                /*if((WO.ERP7__Quantity_Built__c + ToProduce) != WO.ERP7__Quantity_Ordered__c){
                    finish = false;
                }
                WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c + ToProduce;*/
            }
            if(finish && !error){
                Task.ERP7__Status__c = cmp.get("v.taskStatus"); //"Completed";
            }
            if(!error){
                var action = cmp.get("c.TaskUpdateNew");
                var MRPSSS = JSON.stringify(MRPSS);
                action.setParams({
                    Task1:JSON.stringify(Task),
                    WO1:JSON.stringify(WO),
                    MRPSSS:MRPSSS,
                    //MRPS_UOM: JSON.stringify(cmp.get("v.MRPs")),
                    all_UOMs : JSON.stringify(cmp.get("v.UOMCs"))
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().errorMsg == ''){
                            cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                            cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                            cmp.set("v.Tasks", response.getReturnValue().Tasks);
                            cmp.set("v.WorkOrder",response.getReturnValue().WorkOrder);
                            cmp.set("v.Busy", response.getReturnValue().Busy);
                            cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                            cmp.set("v.Permit", response.getReturnValue().Permit);
                            cmp.set("v.signatureExist", false);
                            var selAttachs = cmp.get("v.SelectedAttachments");
                            for(var x in selAttachs){
                                if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                    cmp.set("v.signatureExist", true);
                                }
                            }

                            //cmp.set("v.Evaluate", false);
                            //$('#myModal3').modal('hide');
                            //$A.util.removeClass(cmp.find("prodQtyModal"),"slds-fade-in-open");
                            //$A.util.removeClass(cmp.find("prodQtyModalBackdrop"),"slds-backdrop_open");
                            //cmp.popInit();
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            if(wipStatus == "Finish"){
                                var finishWIPAction = cmp.get("c.FinishWIPFlow");
                                $A.enqueueAction(finishWIPAction);
                            }
                            else if(wipStatus == "Scrap"){
                                var scrapWIPAction = cmp.get("c.setScrapWIPFlow");
                                $A.enqueueAction(scrapWIPAction);
                            }
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                        else {
                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c - ToProduce;
                            for(var x in MRPSS){
                                var qtytoconsume = 0; var qtytoscarp = 0;
                                qtytoconsume = MRPSS[x].MRP.ERP7__Consumed_Quantity__c - MRPSS[x].quantityToConsume;
                                MRPSS[x].MRP.ERP7__Consumed_Quantity__c = qtytoconsume; //Math.round((qtytoconsume + Number.EPSILON) * 100) / 100;
                                qtytoscarp =  MRPSS[x].MRP.ERP7__Scrapped_Quantity__c - MRPSS[x].quantityToScrap;
                                MRPSS[x].MRP.ERP7__Scrapped_Quantity__c = qtytoscarp; //Math.round((qtytoscarp + Number.EPSILON) * 100) / 100;
                            }
                            cmp.set("v.MRPSS", MRPSS);

                            cmp.set("v.signatureExist", false);
                            var selAttachs = cmp.get("v.SelectedAttachments");
                            for(var x in selAttachs){
                                if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                    cmp.set("v.signatureExist", true);
                                }
                            }
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }

                    } else{
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c - ToProduce;
                        for(var x in MRPSS){
                            var qtytoconsume = 0; var qtytoscarp = 0;
                            qtytoconsume = MRPSS[x].MRP.ERP7__Consumed_Quantity__c - MRPSS[x].quantityToConsume;
                            MRPSS[x].MRP.ERP7__Consumed_Quantity__c = qtytoconsume; //Math.round((qtytoconsume + Number.EPSILON) * 100) / 100;
                            qtytoscarp = MRPSS[x].MRP.ERP7__Scrapped_Quantity__c - MRPSS[x].quantityToScrap;
                            MRPSS[x].MRP.ERP7__Scrapped_Quantity__c =  qtytoscarp; //Math.round((qtytoscarp + Number.EPSILON) * 100) / 100;

                        }
                        cmp.set("v.MRPSS", MRPSS);
                        cmp.set("v.signatureExist", false);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }else{
                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }

        },

        CommitTaskonFinsh : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var wipStatus = '';
            var Task = cmp.get("v.SelectedTask");
            var WO = cmp.get("v.WorkOrder");
            console.log('WO : ',JSON.stringify(WO));
            var MRPSS = cmp.get("v.MRPSS");
            var ToProduce = cmp.get("v.ToProduce");
            cmp.set("v.exceptionError", "");
            var error = false;
            var finish = true;
            console.log('hideToProduceforMRP : ',cmp.get('v.hideToProduceforMRP'));console.log('WO.ERP7__Quantity_Built__c ',WO.ERP7__Quantity_Built__c);console.log('ToProduce ',ToProduce);console.log('WO.ERP7__Quantity_Ordered__c ',WO.ERP7__Quantity_Ordered__c);
            if(!cmp.get('v.hideToProduceforMRP') && (ToProduce == null || (Number(WO.ERP7__Quantity_Built__c) + Number(ToProduce)) > WO.ERP7__Quantity_Ordered__c)){
                console.log('here 081123');
                cmp.set("v.exceptionError",  $A.get('$Label.c.Built_quantity_cannot_be_greater_than_ordered_quantity'));
                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                error = true;
            }
            if(!error){
                for(var x in MRPSS){
                    console.log('AllMRPs[x] CommitTaskonFinsh: ',MRPSS[x]);
                    if(MRPSS[x].quantityToConsume == null || MRPSS[x].quantityToScrap == null){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Required_fields_missing'));
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                        break;
                    }
                    if(MRPSS[x].quantityToConsume == '') MRPSS[x].quantityToConsume = 0;
                    if(MRPSS[x].quantityToScrap == '') MRPSS[x].quantityToScrap = 0;
                    var totalQ = (parseFloat(MRPSS[x].MRP.ERP7__Consumed_Quantity__c) + parseFloat(MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) + parseFloat(MRPSS[x].quantityToConsume) + parseFloat(MRPSS[x].quantityToScrap));
                    console.log('totalQ : ',totalQ);
                    if(MRPSS[x].MRP.ERP7__Fulfilled_Amount__c < totalQ){ //(MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap)
                        cmp.set("v.exceptionError", $A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot_be_greater_than_fulfilled_quantity'));
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                        break;
                    }
                    console.log('MRPSS[x].quantityToConsume : ',MRPSS[x].quantityToConsume);
                    console.log('MRPSS[x].quantityToScrap : ',MRPSS[x].quantityToScrap);
                  /* commented by shaguftha on 07/11/23
                   * if(MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && ((MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap) > 1)){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot_be_greater_than_one_for_Serialised'));
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        error = true;
                        break;
                    }*/
                }
            }
            if(!error){

                var producedQty = 0;
                var scrapQty = 0;
                var isCommitted = true;
                /*for(var x in MRPSS){
                    //producedQty = (MRPSS[x].MRP.ERP7__Total_Amount_Required__c*(MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].quantityToConsume))/WO.ERP7__Quantity_Ordered__c;
                    //scrapQty = (MRPSS[x].MRP.ERP7__Total_Amount_Required__c*(MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToScrap))/WO.ERP7__Quantity_Ordered__c;
                    producedQty = (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].quantityToConsume)*WO.ERP7__Quantity_Ordered__c /MRPSS[x].MRP.ERP7__Total_Amount_Required__c;
                    scrapQty = (MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToScrap)*WO.ERP7__Quantity_Ordered__c /MRPSS[x].MRP.ERP7__Total_Amount_Required__c;
                }*/
                if(cmp.get("v.ToProduce") > 0 || cmp.get("v.ToScrap") > 0){
                    var wo2FinQtyB = cmp.get("v.WO2Fin.ERP7__Quantity_Built__c");
                    var wo2FinQtyS = cmp.get("v.WO2Fin.ERP7__Quantity_Scrapped__c");
                    //alert(wo2FinQtyB); alert(wo2FinQtyS);
                    wo2FinQtyB += Number(cmp.get("v.ToProduce"));
                    wo2FinQtyS += Number(cmp.get("v.ToScrap"));
                    //wo2FinQtyB = Math.round((wo2FinQtyB + Number.EPSILON) * 100) / 100;
                    //wo2FinQtyS = Math.round((wo2FinQtyS + Number.EPSILON) * 100) / 100;
                    cmp.set("v.WO2Fin.ERP7__Quantity_Built__c", wo2FinQtyB);
                    cmp.set("v.WO2Fin.ERP7__Quantity_Scrapped__c", wo2FinQtyS);
                    //cmp.set("v.WO2Fin.ERP7__Quantity_Built__c", producedQty);
                    //cmp.set("v.WO2Fin.ERP7__Quantity_Scrapped__c", scrapQty);
                }
                for(var x in MRPSS){
                    console.log('MRPSS[x].MRP.ERP7__Total_Amount_Required__c ',MRPSS[x].MRP.ERP7__Total_Amount_Required__c );
                    console.log('match with total amount ',(Number(MRPSS[x].MRP.ERP7__Consumed_Quantity__c) + Number(MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) + Number(MRPSS[x].quantityToConsume) + Number(MRPSS[x].quantityToScrap)));//(Number(MRPSS[x].MRP.ERP7__Consumed_Quantity__c) + Number(MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) + Number(MRPSS[x].quantityToConsume) + Number(MRPSS[x].quantityToScrap))
                    if(MRPSS[x].MRP.ERP7__Total_Amount_Required__c  != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap)){
                        console.log('finish is false');
                        finish = false;
                    }
                    var consume =0; var scrap =0;
                    console.log('Number.parseFloat(MRPSS[x].MRP.ERP7__Consumed_Quantity__c).toFixed(4) : ',Number.parseFloat(MRPSS[x].MRP.ERP7__Consumed_Quantity__c).toFixed(4));
                    console.log('Number.parseFloat(MRPSS[x].quantityToConsume).toFixed(4) : ',Number.parseFloat(MRPSS[x].quantityToConsume).toFixed(4));
                    consume=  (parseFloat(MRPSS[x].MRP.ERP7__Consumed_Quantity__c) + parseFloat(MRPSS[x].quantityToConsume)).toFixed(4)
                    // Number.parseFloat(MRPSS[x].MRP.ERP7__Consumed_Quantity__c).toFixed(4) +  Number.parseFloat(MRPSS[x].quantityToConsume).toFixed(4);
                    console.log('consume : ',consume);
                    MRPSS[x].MRP.ERP7__Consumed_Quantity__c  = Number.parseFloat(consume).toFixed(4);

                    console.log('MRPSS[x].MRP.ERP7__Consumed_Quantity__c CommitTaskonFinsh: ',MRPSS[x].MRP.ERP7__Consumed_Quantity__c);
                    scrap = (parseFloat(MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) + parseFloat(MRPSS[x].quantityToScrap)).toFixed(4)
                    // Number.parseFloat(MRPSS[x].MRP.ERP7__Scrapped_Quantity__c).toFixed(4) + Number.parseFloat(MRPSS[x].quantityToScrap).toFixed(4);
                    console.log('scrap : ',scrap);
                    MRPSS[x].MRP.ERP7__Scrapped_Quantity__c = Number.parseFloat(scrap).toFixed(4);
                    console.log('MRPSS[x].MRP.ERP7__Scrapped_Quantity__c CommitTaskonFinsh: ',MRPSS[x].MRP.ERP7__Scrapped_Quantity__c);

                }
            }
            if(finish && !error){console.log('wo status set here??')
                Task.ERP7__Status__c = "Completed"; //cmp.get("v.taskStatus");
                WO.ERP7__Status__c = "Complete";
            }
            console.log('error CommitTaskonFinsh : ',error);
            console.log('finish CommitTaskonFinsh : ',finish);
            if(!error){
                var action = cmp.get("c.TaskUpdateNew");
                var MRPSSS = JSON.stringify(MRPSS);
                action.setParams({
                    Task1:JSON.stringify(Task),
                    WO1:JSON.stringify(WO),
                    MRPSSS:MRPSSS,
                    //MRPS_UOM: JSON.stringify(cmp.get("v.MRPs")),
                    all_UOMs : JSON.stringify(cmp.get("v.UOMCs"))
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        console.log('response.getReturnValue() CommitTaskonFinsh : ',response.getReturnValue());
                        if(response.getReturnValue().errorMsg == ''){
                            cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                            cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                            cmp.set("v.Tasks", response.getReturnValue().Tasks);
                            cmp.set("v.WorkOrder", WO);
                            cmp.set("v.Busy", response.getReturnValue().Busy);
                            cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                            cmp.set("v.Permit", response.getReturnValue().Permit);

                            cmp.set("v.signatureExist", false);
                            var selAttachs = cmp.get("v.SelectedAttachments");
                            for(var x in selAttachs){
                                if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                    cmp.set("v.signatureExist", true);
                                }
                            }
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                        else {
                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c - ToProduce;
                            //WO.ERP7__Quantity_Built__c = Math.round((WO.ERP7__Quantity_Built__c + Number.EPSILON) * 100) / 100;
                            for(var x in MRPSS){
                                MRPSS[x].MRP.ERP7__Consumed_Quantity__c = Number.parseFloat(MRPSS[x].MRP.ERP7__Consumed_Quantity__c).toFixed(4) - Number.parseFloat(MRPSS[x].quantityToConsume).toFixed(4);
                                //MRPSS[x].MRP.ERP7__Consumed_Quantity__c = Math.round((MRPSS[x].MRP.ERP7__Consumed_Quantity__c + Number.EPSILON) * 100) / 100;
                                MRPSS[x].MRP.ERP7__Scrapped_Quantity__c =  Number.parseFloat(MRPSS[x].MRP.ERP7__Scrapped_Quantity__c).toFixed(4) - Number.parseFloat(MRPSS[x].quantityToScrap).toFixed(4);
                                //MRPSS[x].MRP.ERP7__Scrapped_Quantity__c = Math.round((MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + Number.EPSILON) * 100) / 100;
                            }
                            cmp.set("v.MRPSS", MRPSS);

                            cmp.set("v.signatureExist", false);
                            var selAttachs = cmp.get("v.SelectedAttachments");
                            for(var x in selAttachs){
                                if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                    cmp.set("v.signatureExist", true);
                                }
                            }
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }

                    } else{
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c - ToProduce;
                        //WO.ERP7__Quantity_Built__c = Math.round((WO.ERP7__Quantity_Built__c + Number.EPSILON) * 100) / 100;

                        for(var x in MRPSS){
                            MRPSS[x].MRP.ERP7__Consumed_Quantity__c = Number.parseFloat(MRPSS[x].MRP.ERP7__Consumed_Quantity__c).toFixed(4) - Number.parseFloat(MRPSS[x].quantityToConsume).toFixed(4);
                            //MRPSS[x].MRP.ERP7__Consumed_Quantity__c = Math.round((MRPSS[x].MRP.ERP7__Consumed_Quantity__c + Number.EPSILON) * 100) / 100;
                            MRPSS[x].MRP.ERP7__Scrapped_Quantity__c =  Number.parseFloat(MRPSS[x].MRP.ERP7__Scrapped_Quantity__c).toFixed(4) - Number.parseFloat(MRPSS[x].quantityToScrap).toFixed(4);
                            //MRPSS[x].MRP.ERP7__Scrapped_Quantity__c = Math.round((MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + Number.EPSILON) * 100) / 100;
                        }
                        cmp.set("v.MRPSS", MRPSS);
                        cmp.set("v.signatureExist", false);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }else{
                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                return error;
            }

        },

        ToProduceChange : function(cmp, event, helper) {
            var MRPSS = cmp.get("v.MRPSS");
            var ToProduce = cmp.get("v.ToProduce");
            var WO = cmp.get("v.WorkOrder");
            for(var x in MRPSS){
                if(WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) && MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) MRPSS[x].quantityToConsume = 1;
                else MRPSS[x].quantityToConsume = (WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c ))? (MRPSS[x].MRP.ERP7__Total_Amount_Required__c*ToProduce)/WO.ERP7__Quantity_Ordered__c : 0;
            }
            cmp.set("v.MRPSS",MRPSS);
        },

        StopTask : function(cmp, event, helper) {
            if(confirm("Are you sure?")){
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var Task = cmp.get("v.SelectedTask");
                var WO = cmp.get("v.WorkOrder");
                var MRPS = cmp.get("v.MRPSS");
                var TimeSheet = cmp.get("v.TimeSheet");
                Task.ERP7__Status__c = "Cancelled";
                var action = cmp.get("c.TaskUpdate");
                action.setParams({
                    Task1:JSON.stringify(Task),
                    WO1:JSON.stringify(WO),
                    MRPS1:JSON.stringify(MRPS)
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().errorMsg == ''){
                            cmp.set("v.Tasks", response.getReturnValue().Tasks);
                            cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                            cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                            var tasklist =  cmp.get('v.tasklists');
                            for(var x in tasklist){
                                if(tasklist[x].Task.Id == Task.Id){
                                    tasklist[x].Task = cmp.get("v.SelectedTask");
                                    break;
                                }
                            }
                            cmp.set("v.tasklists", tasklist);
                            cmp.set("v.Busy", response.getReturnValue().Busy);
                            cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                            cmp.set("v.Permit", response.getReturnValue().Permit);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            cmp.popInit();
                        }
                        else{
                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
                    } else{
                        cmp.set("v.exceptionError", response.getError());
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
        },
        CompleteTask : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var Task = cmp.get("v.SelectedTask");
            console.log('Task : ',JSON.stringify(Task));
            var error = false;
            var tasklist = cmp.get("v.tasklists");
            for(var x in tasklist){
                if(tasklist[x].Task.Id == Task.Id){
                    if(tasklist[x].checklists != undefined && tasklist[x].checklists != null && tasklist[x].checklists.length > 0){
                        for(var y in tasklist[x].checklists){
                            if(tasklist[x].checklists[y].ERP7__Is_Mandatory__c){
                                console.log('1');
                                console.log('2 : ',tasklist[x].checklists[y].ERP7__Instructions__c);
                                if(tasklist[x].checklists[y].ERP7__Instructions__c == undefined || tasklist[x].checklists[y].ERP7__Instructions__c == null || tasklist[x].checklists[y].ERP7__Instructions__c == '' || tasklist[x].checklists[y].ERP7__Instructions__c == '--None--' || tasklist[x].checklists[y].ERP7__Instructions__c == 'Pending'){
                                    error =true;
                                    cmp.set('v.exceptionError',$A.get('$Label.c.Please_complete_the_checklists')+':' +tasklist[x].checklists[y].Name);
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    cmp.set("v.SelectedTask.ERP7__Status__c", tasklist[x].Task.ERP7__Status__c);
                                    return;
                                }
                                else{
                                   tasklist[x].checklists[y].ERP7__Action_Task__c = tasklist[x].Task.Id;
                                }
                            }
                        }
                    }
                }
            }
             if(!error){
                 var checklistAction = cmp.get('c.SaveTaskValues');
                 checklistAction.setCallback(this, function(response) {
                     var state = response.getState();
                     if (state === "SUCCESS") {
                        var WO = cmp.get("v.WorkOrder");
                        var MRPS = cmp.get("v.MRPs");
                        var TimeSheet = cmp.get("v.TimeSheet");
                         var action = cmp.get("c.TaskUpdate");
                        action.setParams({
                            Task1:JSON.stringify(Task),
                            WO1:JSON.stringify(WO),
                            MRPS1:JSON.stringify(MRPS)
                        });
                         action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                if(response.getReturnValue().errorMsg == ''){
                                    console.log('CompleteTask res : ',response.getReturnValue());
                                    cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                                    cmp.set("v.Tasks", response.getReturnValue().Tasks);
                                    cmp.set("v.Busy", response.getReturnValue().Busy);
                                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                                    cmp.set("v.Permit", response.getReturnValue().Permit);
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    //cmp.set('v.showTaskSave',showSave);
                                    cmp.popInit();
                                }
                                else{
                                    cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                }
                            } else{
                                console.log('CompleteTask error : ',response.getError());
                                cmp.set("v.exceptionError", response.getError());
                                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            }
                        });
                        $A.enqueueAction(action);
                    }
                    else{
                        console.log('Error : '+JSON.stringify(response.getError()));
                    }
                });
                $A.enqueueAction(checklistAction);
            }
        },
       /* CompleteTask : function(cmp, event, helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
           // var count = event.currentTarget.getAttribute('data-mosoliId');
            //var obj = cmp.get("v.Tasks");
          //  var objsel;
           // var showSave = false;
           // for(var x in obj){
               // if(x == count) {
                  //  objsel = obj[count];
                  //  break;
              //  }
                //if(obj[x].ERP7__Status__c != cmp.get("v.taskStatus"))  showSave = true;
               // else showSave =false;
            //}
           // cmp.set("v.SelectedTask",objsel);
            var Task = cmp.get("v.SelectedTask");
            console.log('Task : ',JSON.stringify(Task));
            var error = false;
            var checks = cmp.get('v.Checklist');
            var guidelines = cmp.get('v.guidelinechecklist');
            var guidelength = 0;
            var checklst = 0;
            if(guidelines!= null && guidelines != undefined && guidelines != '') guidelength=cmp.get('v.guidelinechecklist').length;
            if(checks != null && checks != undefined && checks != '') checklst = checks.length;
            if(checklst  > 0 && guidelength == 0 && Task.ERP7__Status__c == 'Completed'){

                for(var i in checks){
                    if(checks[i].ERP7__Operation__c != null && checks[i].ERP7__Operation__c != '' && checks[i].ERP7__Operation__c == Task.ERP7__Operation__c && checks[i].ERP7__Is_Mandatory__c){
                        if((checks[i].ERP7__Has_Checklist__c == true) && (checks[i].ERP7__Result__c == null || checks[i].ERP7__Result__c == '' || checks[i].ERP7__Result__c == '--None--')){
                            error =true;
                            cmp.set('v.exceptionError',$A.get('$Label.c.Please_complete_the_checklists') +checks[i].Name);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            break;
                        }
                        else if((checks[i].ERP7__Has_Checklist__c == false) && (checks[i].ERP7__Action_Detail__c == '' || checks[i].ERP7__Action_Detail__c == null || checks[i].ERP7__Action_Detail__c == undefined)){
                            error =true;
                            cmp.set('v.exceptionError',$A.get('$Label.c.Please_complete_the_checklists') +checks[i].Name);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            break;
                        }
                    }
                }
            }
            if(!error){
                var checklistAction = cmp.get('c.SaveTaskValues');
                checklistAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var WO = cmp.get("v.WorkOrder");
                        var MRPS = cmp.get("v.MRPs");
                        var TimeSheet = cmp.get("v.TimeSheet");
                        //Task.ERP7__Status__c = cmp.get("v.taskStatus");//"Completed";
                        var action = cmp.get("c.TaskUpdate");
                        action.setParams({
                            Task1:JSON.stringify(Task),
                            WO1:JSON.stringify(WO),
                            MRPS1:JSON.stringify(MRPS)
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                if(response.getReturnValue().errorMsg == ''){
                                    console.log('CompleteTask res : ',response.getReturnValue());
                                    cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                                    cmp.set("v.Tasks", response.getReturnValue().Tasks);
                                    cmp.set("v.Busy", response.getReturnValue().Busy);
                                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                                    cmp.set("v.Permit", response.getReturnValue().Permit);
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    //cmp.set('v.showTaskSave',showSave);
                                    cmp.popInit();
                                }
                                else{
                                    cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                }
                            } else{
                                console.log('CompleteTask error : ',response.getError());
                                cmp.set("v.exceptionError", response.getError());
                                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            }
                        });
                        $A.enqueueAction(action);
                    }
                    else{
                        console.log('Error : '+JSON.stringify(response.getError()));
                    }
                });
                $A.enqueueAction(checklistAction);
            }
        },
        */
        /* CreateMO : function(cmp, event, helper) {
            var MRPId = event.currentTarget.getAttribute('data-mosoliId');
            var URL_RMA = '/apex/ERP7__ManufacturingOrderLC?mrpId='+MRPId;
            window.open(URL_RMA,'_self');
        },*/

        ReserveMRPStocks : function (cmp, event) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //document.getElementById("rot").classList.add("erp-rotation");
            var allMRPs = JSON.stringify(cmp.get("v.MRPs"));
            var action = cmp.get("c.ReserveMRPSStocks");
            action.setParams({
                MRPs: allMRPs
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == '') {
                        cmp.popInit();
                    }
                    else {
                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        //document.getElementById("rot").classList.remove("erp-rotation");
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                } else{
                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                }
            });
            $A.enqueueAction(action);
        },

        CurrentSerialNumbers: function(cmp, event) {
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
        },

        CurrentBatchNumbers: function(cmp, event) {
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
            var WO = cmp.get("v.WorkOrder");
            kk.ERP7__Status__c = "Requested";
            kk.ERP7__Process_Cycle__c = WO.ERP7__Process_Cycle__c;
            if(WO.Id != undefined) kk.ERP7__Work_Order__c = WO.Id;
            kk.ERP7__Version__c = WO.ERP7__Version__c;
            //kk.ERP7__MRP_Product__c = WO.ERP7__Product__c;
            kk.ERP7__Work_Center__c  = WO.ERP7__Work_Center__c;
            kk.ERP7__MO__c = WO.ERP7__MO__c;
            cmp.set("v.NewMRP",kk);
            $A.util.addClass(cmp.find("newMRPModal"), 'slds-fade-in-open');
            $A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
        },

        closeNewMRPModal : function (cmp, event) {
            $A.util.removeClass(cmp.find("newMRPModal"), 'slds-fade-in-open');
            $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
        },

        EditMRPOld : function (cmp, event) {
            cmp.set("v.exceptionError","");
            var count = event.getSource().get("v.name");
            var obj = cmp.get("v.MRPs");
            var objsel;
            for(var x in obj){
                if(x == count) {
                    objsel = obj[count].MRP;
                    var ik = JSON.stringify(objsel);
                }
            }
            cmp.set("v.NewMRP",objsel);
        },

        updateMRP : function (cmp, event) {
            var MRP = cmp.get("v.NewMRP");
            var ik = JSON.stringify(MRP);
            var error = false;
            if(MRP.Name == undefined || MRP.Name == "" || MRP.ERP7__BOM__c == undefined || MRP.ERP7__BOM__c == "" || MRP.ERP7__Total_Amount_Required__c == undefined || MRP.ERP7__Total_Amount_Required__c == "" || MRP.ERP7__MRP_Product__c == undefined || MRP.ERP7__MRP_Product__c == "") {
                error = true;
                cmp.set('v.editErrorMsg',$A.get('$Label.c.Please_enter_the_required_fields'));
            }
            console.log('error : '+error);
            if(!error){
                console.log('inside if');
                var action = cmp.get("c.MRPUpdate");
                action.setParams({
                    MRP1: JSON.stringify(MRP)
                });
                console.log('JSON.stringify(MRP) : '+JSON.stringify(MRP));
                action.setCallback(this, function(response) {
                    console.log('response.getState() : '+response.getState());
                    if (response.getState() === "SUCCESS") {
                        console.log('errMsg : '+response.getReturnValue().errorMsg);
                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        if(response.getReturnValue().errorMsg == ''){
                            $A.util.removeClass(cmp.find("newMRPModal"), 'slds-fade-in-open');
                            $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
                            //document.getElementById("mrpspins").style.visibility = "hidden";
                            cmp.popInit();
                        } //else document.getElementById("mrpspins").style.visibility = "hidden";
                    }
                });
                $A.enqueueAction(action);
            } else{
                cmp.set("v.exceptionError","Required fields missing");
                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
            }
        },

        /*SelectMRP: function(cmp, event) {
            var count = event.currentTarget.getAttribute('data-mrpcount');
            var obj = cmp.get("v.MRPs");
            var Fulfilled = true;
            var moSerialNos = cmp.get("v.moSerialNos");

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
            //$A.util.addClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
            //$A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
            cmp.set("v.saPage", true);
            if(moSerialNos.length > 0) cmp.loadSerialForAllocation();
        },
        */
        SelectMRP: function(cmp, event,helper) {
            console.log('SelectMRP called');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            try{
                cmp.set("v.exceptionError","");
                var count = event.currentTarget.getAttribute('data-mrpcount');
                cmp.set("v.exceptionError","");
                var obj = cmp.get("v.MRPs");
                var MOId = cmp.get("v.ManuOrder.Id");
                if(obj != undefined && obj.length > 0) {
                    var selectedMRP = obj[count];
                    // alert(selectedMRP.MRP.Id);
                    var action = cmp.get("c.getMRPDetails");
                    action.setParams({'MRP' : selectedMRP.MRP.Id,"Mo" : MOId});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        //alert(state);
                        if (state === "SUCCESS") {
                            var soli = response.getReturnValue();
                            var stockAssignedSerialIds = [];
                            var actualfulfilledWeight = 0;
                            for(var y in soli){
                                stockAssignedSerialIds.push(soli[y].ERP7__MO_WO_Serial__c);
                                actualfulfilledWeight += soli[y].ERP7__Quantity__c;
                            }
                            //alert(actualfulfilledWeight);
                            var TotalWeight = 0;
                            var Fulfilled = true;
                            cmp.set("v.WeightStr","0");
                            for(var x in obj){
                                if(count == x) {
                                    obj[x].isSelect = true;
                                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c != undefined) cmp.set("v.WeightStr", obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c);
                                    obj[x].SOLIs = soli;
                                    obj[x].ActualWeight= actualfulfilledWeight;
                                    cmp.set("v.selectedMRP",obj[x].MRP);
                                }
                                else  {
                                    obj[x].isSelect = false;
                                    obj[x].SOLIs = [];
                                }
                                if(obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs') TotalWeight += obj[x].MRP.ERP7__Total_Amount_Required__c;
                                if(obj[x].ActualWeight < obj[x].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
                                console.log('obj[x].ActualWeight : ',obj[x].ActualWeight);
                            }
                            helper.getSerials(cmp,stockAssignedSerialIds);
                            cmp.set("v.Fulfilled",Fulfilled);
                            cmp.set("v.MRPs",obj);
                            cmp.set("v.TotalWeight",TotalWeight);

                        }
                    });
                    $A.enqueueAction(action);
                }
            } catch(err) {
                console.log('err occured SelectMRP~>',err);
                cmp.set("v.showSpinner",false);
            }
        },
        SelectSerialForAllocation: function(cmp, event) {
            var count = event.currentTarget.getAttribute('data-serialcount');
            var obj = cmp.get("v.SerialsForAllocation");
            for(var x in obj){
                if(count == x) {
                    var newSOL = cmp.get("v.NewSOLI");
                    newSOL.ERP7__MO_WO_Serial__c = obj[x].Id;
                    cmp.set("v.NewSOLI",newSOL);
                }
            }

        },

        SetShowSerial : function(cmp, event, helper) {
            var obj = cmp.get("v.SerialsForAllocation");
            for(var x in obj){
                obj[x].SelectItem = false;
            }
            cmp.set("v.SerialsForAllocation", obj);
            cmp.set('v.selectAllSerials', false);
        },

        selectTheSerial: function(cmp, event) {
            var checkedval = event.getSource().get('v.checked');
            var obj = cmp.get("v.SerialsForAllocation");
            cmp.set("v.SerialsForAllocation", obj);
        },

        selectTheSerialonDiv: function(cmp, event) {
            var SId = event.currentTarget.getAttribute('data-serialId');
            var obj = cmp.get("v.SerialsForAllocation");
            for(var x in obj){
                if(SId == obj[x].Id){
                    obj[x].SelectItem = !obj[x].SelectItem;
                }
            }
            cmp.set("v.SerialsForAllocation", obj);
        },

        SerialForAllocation: function(cmp, event) {
            console.log('SerialForAllocation : ');
            var obj = cmp.get("v.MRPs");
            var moSerialNos = cmp.get("v.moSerialNos");
            var NewSerialsForAllocation = [];
            var stockAssignedSerialIds = [];
            cmp.set('v.selectAllSerials', false);
            for(var x in obj){
                if(obj[x].isSelect) {
                    cmp.set("v.selectedMRP",obj[x].MRP);
                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c != undefined) cmp.set("v.WeightStr", obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c);
                    var soli = obj[x].SOLIs;
                    if(soli != undefined && soli.length > 0){
                        for(var y in soli){
                            if(soli[y].ERP7__MO_WO_Serial__c != undefined) stockAssignedSerialIds.push(soli[y].ERP7__MO_WO_Serial__c);
                        }
                    }
                    for(var y in moSerialNos){
                        if(stockAssignedSerialIds.includes(moSerialNos[y].Id) == false) {
                            moSerialNos[y].SelectItem = false;
                            NewSerialsForAllocation.push(moSerialNos[y]);
                        }
                    }
                    cmp.set("v.SerialsForAllocation", NewSerialsForAllocation);
                    if(NewSerialsForAllocation.length > 0){
                        var newSOL = cmp.get("v.NewSOLI");
                        newSOL.ERP7__MO_WO_Serial__c = NewSerialsForAllocation[0].Id;
                        cmp.set("v.NewSOLI",newSOL);
                        //alert('Ser'+newSOL.ERP7__MO_WO_Serial__c);
                    }
                }
            }
        },

        selectAllSerials : function (cmp,event) {
            var checkedval = event.getSource().get('v.checked');
            cmp.set('v.selectAllSerials', checkedval);
            var obj = cmp.get("v.SerialsForAllocation");
            var showSerialsCount = cmp.get("v.showSerials");
            //alert(showSerialsCount);
            var i = 0;
            for(var x in obj){
                if(i < showSerialsCount){
                    obj[x].SelectItem = checkedval;
                    i++;
                }
            }
            //alert(showSerialsCount);
            cmp.set("v.SerialsForAllocation", obj);
        },

        /*  SelectMRP1: function(cmp, event) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            console.log('SelectMRP1 called');
            try{
                var unchangedObj = cmp.get("v.MRPs");
                console.log('unchangedObj : ',unchangedObj);
                var obj = cmp.get("v.MRPs");
                var TotalWeight = 0;
                var Fulfilled = true;
                var stockAssignedSerialIds = [];
                 var NewSerialsForAllocation = [];
                 cmp.set("v.WeightStr","0");
                var MOId = cmp.get("v.ManuOrder.Id");
                for(var x in obj){
                    if(0 == x) {
                        if(obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c != undefined) cmp.set("v.WeightStr", obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c);
                        var soli = obj[x].SOLIs;
                        if(soli != undefined && soli.length > 0){
                            console.log('soli : ',soli.length);
                            for(var y in soli){
                                stockAssignedSerialIds.push(soli[y].ERP7__MO_WO_Serial__c);
                            }
                        }
                        cmp.set("v.selectedMRP",obj[x].MRP);
                    } else  obj[x].isSelect = false;
                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs') TotalWeight += obj[x].MRP.ERP7__Total_Amount_Required__c;
                    if(obj[x].ActualWeight < obj[x].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
                }
                var action = cmp.get("c.getSerialNumbers");
                action.setParams({"offsetVal" : 0,"Mo" : MOId,"limitSer" : 1000,'SerialIds' : stockAssignedSerialIds});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var moSerialNos = response.getReturnValue();
                        cmp.set("v.moSerialNos",moSerialNos);
                        var newSOL = cmp.get("v.NewSOLI");
                        for(var y in moSerialNos){
                            console.log('inhere moSerialNos innerloop');
                            if(stockAssignedSerialIds.includes(moSerialNos[y].Id) == false) {
                                console.log('inhere moSerialNos innerloop if');
                                moSerialNos[y].SelectItem = false;
                                NewSerialsForAllocation.push(moSerialNos[y]);
                            }
                        }
                        if(NewSerialsForAllocation.length > 0){
                            newSOL.ERP7__MO_WO_Serial__c = NewSerialsForAllocation[0].Id;
                        }
                        cmp.set("v.Fulfilled",Fulfilled);
                        cmp.set("v.MRPs",obj);
                        cmp.set("v.TotalWeight",TotalWeight);
                        cmp.set("v.NewSOLI",newSOL);
                        cmp.set("v.SerialsForAllocation", NewSerialsForAllocation);
                        cmp.set("v.saPage", true);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        if(unchangedObj.length > 0){
                            unchangedObj[0].isSelect = true;
                            cmp.set("v.MRPs",unchangedObj);
                        }

                       // if(moSerialNos.length > 0) cmp.loadSerialForAllocation();
                    }
                });
                $A.enqueueAction(action);
            }
            catch(err) {
                console.log('err occured SelectMRP1~>',err);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
            //$A.util.addClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
            //$A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
        },*/
        SelectMRP1: function(cmp, event,helper) {
            console.log('SelectMRP1 called');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            try{

                window.scrollTo(0, 0);
                cmp.set("v.exceptionError","");
                var obj = cmp.get("v.MRPs");
                var MOId = cmp.get("v.ManuOrder.Id");
                if(obj != undefined && obj.length > 0) {
                    var selectedMRP = obj[0];
                    // alert(selectedMRP.MRP.Id);
                    var action = cmp.get("c.getMRPDetails");
                    action.setParams({'MRP' : selectedMRP.MRP.Id,"Mo" : MOId});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        //alert(state);
                        if (state === "SUCCESS") {
                            var soli = response.getReturnValue();
                            var stockAssignedSerialIds = [];
                            var actualfulfilledWeight = 0;
                            for(var y in soli){
                                stockAssignedSerialIds.push(soli[y].ERP7__MO_WO_Serial__c);
                                actualfulfilledWeight += soli[y].ERP7__Quantity__c;
                            }
                            //alert(actualfulfilledWeight);
                            var TotalWeight = 0;
                            var Fulfilled = true;
                            cmp.set("v.WeightStr","0");
                            for(var x in obj){
                                if(0 == x) {
                                    obj[x].isSelect = true;
                                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c != undefined) cmp.set("v.WeightStr", obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c);
                                    obj[x].SOLIs = soli;
                                    obj[x].ActualWeight= actualfulfilledWeight;
                                    cmp.set("v.selectedMRP",obj[x].MRP);
                                }
                                else  obj[x].isSelect = false;
                                if(obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs') TotalWeight += obj[x].MRP.ERP7__Total_Amount_Required__c;
                                if(obj[x].ActualWeight < obj[x].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
                                console.log('obj[x].ActualWeight : ',obj[x].ActualWeight);
                            }
                            helper.getSerials(cmp,stockAssignedSerialIds);
                            cmp.set("v.Fulfilled",Fulfilled);
                            cmp.set("v.MRPs",obj);
                            cmp.set("v.TotalWeight",TotalWeight);

                        }
                    });
                    $A.enqueueAction(action);
                }
            } catch(err) {
                console.log('err occured SelectMRP1~>',err);
                cmp.set("v.showSpinner",false);
            }
        },

        closeStockAllocationModal : function(cmp, event) {
            cmp.set("v.WeightStr","0");
            cmp.set("v.Weight", 0);
            //$A.util.removeClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
            //$A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
            cmp.set("v.saPage", false);
            // cmp.popInit();
        },

        SelectWIP: function(cmp, event) {
            //var count = event.currentTarget.getAttribute('data-wipcount');
            var count = event.currentTarget.dataset.index;
            var obj = cmp.get("v.WIPs");
            cmp.set("v.SelectedWIP",obj[count]);
            /*for(var x in obj){
                if(count == x) {
                    cmp.set("v.SelectedWIP",obj[x]);
                }
            }
            cmp.set("v.WIPs",obj);*/
        },

        SelectWIPflow: function(cmp, event) {
            //var count = event.currentTarget.getAttribute('data-wipcount');
            var count = event.currentTarget.dataset.index;
            var obj = cmp.get("v.WIPFlows");
            cmp.set("v.SelectedWIPflow",obj[count].wipFlow);
            cmp.set('v.commitWIPFlow',false);
            cmp.set('v.WIPflowQty',0);
            if(cmp.get('v.EnterconsumeQty') == true){
                if(cmp.get('v.ManuOrder.ERP7__Product__r.ERP7__Serialise__c')) {
                    cmp.set("v.ToProduce",1);
                    cmp.set("v.ToScrap",0);
                }
                else {
                    cmp.set("v.ToProduce",cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));
                    cmp.set("v.ToScrap",0);
                }
                console.log('ToProduce finish SelectWIPflow : ',cmp.get("v.ToProduce"));
            }
            /*for(var x in obj){
                if(count == x) {
                    cmp.set("v.SelectedWIP",obj[x]);
                }
            }
            cmp.set("v.WIPs",obj);*/
        },

        UOMChange: function(cmp, event) {
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
                                //obj[x].WeightMultiplier = Math.round((obj[x].WeightMultiplier + Number.EPSILON) * 100) / 100;
                                //document.getElementById("cardTransition").style.visibility = "hidden";
                                document.getElementById("cardTransition").classList.add("cardTransition");
                                //document.getElementById("cardTransition").classList.add("cardTransitionClicked");
                                //obj[x].WeightMultiplier = Math.round(num * 100) / 100;
                                break;
                            }
                        }
                        if(!conversionFound) {
                            var errMsgNew = $A.get('$Label.c.Conversion_values_between') + ' ' +oldUOM+' ' +$A.get('$Label.c.and')+ ' '+newUOM+' ' +$A.get('$Label.c.not_found');
                            cmp.set("v.exceptionError",errMsgNew);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
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
                                //obj[x].BOMWeightMultiplier = Math.round((obj[x].BOMWeightMultiplier + Number.EPSILON) * 100) / 100;
                                //document.getElementById("cardTransition").style.visibility = "hidden";
                                //document.getElementById("cardTransition").classList.add("cardTransition");
                                //document.getElementById("cardTransition").classList.add("cardTransitionClicked");
                                //obj[x].WeightMultiplier = Math.round(num * 100) / 100;
                                break;
                            }
                        }
                        if(!conversionFound) {
                            var errMsgNew = $A.get('$Label.c.Conversion_values_between') + ' '+oldUOM+' ' +$A.get('$Label.c.and')+ ' '+newUOM+' ' +$A.get('$Label.c.not_found');
                            cmp.set("v.exceptionError",errMsgNew);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            break;
                        }
                    }

                }
            } cmp.set("v.MRPs", obj);
        },

        /*  CaptureWeight: function(cmp, event) {
            const unchangedObj = JSON.parse(JSON.stringify(cmp.get("v.MRPs")));
            var MO = cmp.get("v.ManuOrder");
            var WO = cmp.get("v.WorkOrder");
            var obj = cmp.get("v.MRPs");
            var NewSOLI = cmp.get("v.NewSOLI");
            //cmp.get("v.WeightStr");
            var WeightStr = document.getElementById("WeightStr").value;
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
                            //cmp.set("v.exceptionError",errMsgNew);
                            cmp.set("v.exceptionError",errMsgNew);
                            //setTimeout($A.getCallback(function(){cmp.set("v.exceptionError","");}), 5000);
                            break;
                        }
                    }

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
                    }
                    var weightCheck = weight.toFixed(4);
                    var onlyweightCheck = onlyweight.toFixed(4);

                    if((obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c == false && onlyweightCheck > 0 && weightCheck <= max) || (obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c == true && onlyweightCheck > 0 && onlyweightCheck <= imax && onlyweightCheck >= imin && weightCheck <= max)){
                        if((obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && NewSOLI.ERP7__Serial__c == undefined) || (obj[x].MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c && NewSOLI.ERP7__Material_Batch_Lot__c == undefined) || (WO.ERP7__Product__r.ERP7__Serialise__c && NewSOLI.ERP7__MO_WO_Serial__c == undefined) || (WO.ERP7__Product__r.ERP7__Lot_Tracked__c && NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c == undefined)){
                            cmp.set("v.exceptionError","Required fields missing");
                            //setTimeout($A.getCallback(function(){cmp.set("v.exceptionError","");}), 5000);
                        }

                        else if(obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && NewSOLI.ERP7__Serial__c != undefined && ((weight - obj[x].ActualWeight) > 1)){
                            cmp.set("v.exceptionError","Serialised product invalid quantity");
                            //setTimeout($A.getCallback(function(){cmp.set("v.exceptionError","");}), 5000);
                        }
                        else if(error){
                            cmp.set("v.exceptionError","Invalid quantity/weight");
                            //setTimeout($A.getCallback(function(){cmp.set("v.exceptionError","");}), 5000);
                        }
                        else {

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

                                    if(response.getReturnValue().errorMsg != ''){
                                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                                        //setTimeout($A.getCallback(function(){cmp.set("v.exceptionError","");}), 5000);
                                        cmp.set("v.MRPs", unchangedObj);
                                    }
                                    else {

                                        //alert("here");
                                        succeed = true;
                                        cmp.set("v.WeightStr","0");
                                        cmp.set("v.NewSOLI.ERP7__Material_Batch_Lot__c", undefined);
                                        cmp.set("v.NewSOLI.ERP7__Serial__c", undefined);
                                        cmp.set("v.MRPs",response.getReturnValue().MRPSS);
                                        var ik = response.getReturnValue().MRPSS;
                                        var TW = 0;
                                        var Fulfilled = true;
                                        for(var y in ik){
                                            if(ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs') TW += ik[y].MRP.ERP7__Total_Amount_Required__c;
                                            if(ik[y].ActualWeight < ik[y].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
                                        }
                                        cmp.set("v.Fulfilled",Fulfilled);
                                        cmp.set("v.TotalWeight",TW);
                                        cmp.set("v.WCAP",true);
                                        if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
                                            var PrintSB = false;
                                            var objm = cmp.get("v.MRPs");
                                            for(var x in objm){
                                                if(objm[x].isSelect) {
                                                    var quant = 0;
                                                    var quantin = 0;
                                                    quant = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                    if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;

                                                    var SOLISM = objm[x].SOLIs;
                                                    for(var y in SOLISM){
                                                        if((SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                                                    }
                                                    if(quantin*objm[x].WeightMultiplier >= quant) cmp.set("v.WCAP",false);
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

                                    }
                                } else{
                                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                                    //setTimeout($A.getCallback(function(){cmp.set("v.exceptionError","");}), 5000);
                                }
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            });
                            $A.enqueueAction(action);
                        }
                    }
                    else {
                        cmp.set("v.exceptionError","Invalid weight to capture");
                        //setTimeout($A.getCallback(function(){cmp.set("v.exceptionError","");}), 5000);
                        cmp.set("v.MRPs", unchangedObj);
                    }
                }
            }

        },*/
        CaptureWeight: function(cmp, event) {
            try{
                console.log('In Capture');
                const unchangedObj = JSON.parse(JSON.stringify(cmp.get("v.MRPs")));
                var MO = cmp.get("v.ManuOrder");
                var WO = cmp.get("v.WorkOrder");
                var obj = cmp.get("v.MRPs");
                var NewSOLI = cmp.get("v.NewSOLI");
                var WeightStr = document.getElementById("WeightStr").value;
                var doubleWeight = 0.00;
                if (typeof WeightStr === 'string' || WeightStr instanceof String) doubleWeight = Number(WeightStr.replace(/[^0-9\.]+/g,""));
                else doubleWeight = WeightStr;
                console.log('doubleWeight : '+doubleWeight);

                //var weight =((doubleWeight + Number.EPSILON) * 100) / 100;
                //var onlyweight = ((doubleWeight + Number.EPSILON) * 100) / 100;

                var weight = doubleWeight;
                var onlyweight = doubleWeight;

                console.log('weight : '+weight);

                console.log('weight here1~>'+weight);
                console.log('onlyweight here1~>'+onlyweight);

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
                        if(newUOM != oldUOM && weight >= 0){
                            var UOMCs = cmp.get("v.UOMCs");
                            var conversionFound = false;
                            var newWeight = 0;
                            for(var k in UOMCs){
                                if((UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM) || (UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM)){
                                    conversionFound = true;
                                    if(UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM){
                                        newWeight = (UOMCs[k].ERP7__From_Value__c/UOMCs[k].ERP7__To_Value__c)*weight;
                                    }
                                    else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM){
                                        newWeight = (UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c)*weight;
                                    }
                                    weight = newWeight; //((newWeight + Number.EPSILON) * 100) / 100;
                                    onlyweight = newWeight; //((newWeight + Number.EPSILON) * 100) / 100;
                                    console.log('newWeight UOM : ',newWeight);
                                    break;
                                }
                                if(!conversionFound) {
                                    var errMsgNew = $A.get('$Label.c.Conversion_values_between') + ' '+oldUOM+' ' +$A.get('$Label.c.and')+ ' '+newUOM+' ' +$A.get('$Label.c.not_found');
                                    //cmp.set("v.exceptionError",errMsgNew);
                                    cmp.set("v.exceptionError",errMsgNew);
                                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                    break;
                                }
                            }
                        }

                        console.log('weight here2~>'+weight);
                        console.log('onlyweight here2~>'+onlyweight);
                        console.log('obj[x].ActualWeight here2~>'+obj[x].ActualWeight);
                        console.log('obj[x].WeightMultiplier here2~>'+obj[x].WeightMultiplier);

                        if(obj[x].ActualWeight != undefined) weight = parseFloat(parseFloat(parseFloat(weight) + parseFloat(obj[x].ActualWeight))/obj[x].WeightMultiplier).toFixed(4); //parseFloat(weight) + parseFloat(obj[x].ActualWeight);

                        console.log('weight here3~>'+weight);

                        //weight = ((weight + Number.EPSILON) * 100) / 100;
                        var min = obj[x].MRP.ERP7__Expected_Quantity__c; //((obj[x].MRP.ERP7__Expected_Quantity__c + Number.EPSILON) * 100) / 100;
                        var max = obj[x].MRP.ERP7__Expected_Quantity__c; //((obj[x].MRP.ERP7__Expected_Quantity__c + Number.EPSILON) * 100) / 100;
                        var imin = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c; //((obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c + Number.EPSILON) * 100) / 100;
                        var imax = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c; //((obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c + Number.EPSILON) * 100) / 100;
                        if(obj[x].MRP.ERP7__Minimum_Variance__c != undefined && obj[x].MRP.ERP7__Minimum_Variance__c != "") min = obj[x].MRP.ERP7__Expected_Quantity__c - obj[x].MRP.ERP7__Minimum_Variance__c;
                        if(obj[x].MRP.ERP7__Maximum_Variance__c != undefined && obj[x].MRP.ERP7__Maximum_Variance__c != "") max = obj[x].MRP.ERP7__Expected_Quantity__c + obj[x].MRP.ERP7__Maximum_Variance__c;
                        if(obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c != undefined && obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c != "") imin = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c - obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c;
                        if(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c != undefined && obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c != "") imax = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c + obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;

                        //New Values
                        min = (min/obj[x].WeightMultiplier); //(((min/obj[x].WeightMultiplier) + Number.EPSILON) * 100) / 100;
                        max = (max/obj[x].WeightMultiplier); //(((max/obj[x].WeightMultiplier) + Number.EPSILON) * 100) / 100;
                        imin = (imin/obj[x].WeightMultiplier); //(((imin/obj[x].WeightMultiplier) + Number.EPSILON) * 100) / 100;
                        imax = (imax/obj[x].WeightMultiplier); //(((imax/obj[x].WeightMultiplier) + Number.EPSILON) * 100) / 100;
                        var NewSOLI = cmp.get("v.NewSOLI");
                        if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
                            var quant1 = 0;
                            var quantin1 = 0;
                            quant1 = parseFloat(obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c);

                            if(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant1 += parseFloat(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c);

                            var SOLISM1 = obj[x].SOLIs;
                            for(var y in SOLISM1){
                                if(SOLISM1[y].ERP7__MO_WO_Serial__c == NewSOLI.ERP7__MO_WO_Serial__c) quantin1 += parseFloat(SOLISM1[y].ERP7__Quantity__c);
                            }

                            // New Values quant1
                            quant1 = (quant1/obj[x].WeightMultiplier); //(((quant1/obj[x].WeightMultiplier) + Number.EPSILON) * 100) / 100;

                            if((quantin1 + onlyweight) > quant1) error = true;
                        }
                        //var weightCheck = ((weight + Number.EPSILON) * 100) / 100;
                        //var onlyweightCheck = ((onlyweight + Number.EPSILON) * 100) / 100;  //parseFloat(onlyweight);  //.toFixed(4);

                        var weightCheck = weight
                        var onlyweightCheck = onlyweight;

                        var selectedSerialNos = cmp.get("v.SerialsForAllocation");
                        var selectedSerialNos2Send = [];
                        for(var z in selectedSerialNos){
                            if(selectedSerialNos[z].SelectItem == true) {
                                selectedSerialNos2Send.push(selectedSerialNos[z].Id);
                            }
                        }

                        /*
                        alert('obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c : '+obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c);
                        alert('onlyweightCheck : '+onlyweightCheck);
                        alert('weightCheck : '+weightCheck);
                        alert('max : '+max);
                        alert('imax : '+imax);
                        alert('imin : '+imin);
                        */
                        console.log('obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c : '+obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c);
                        console.log('onlyweightCheck : '+onlyweightCheck);
                        console.log('weightCheck : '+weightCheck);
                        console.log('max : '+max);
                        console.log('imax : '+imax);
                        console.log('imin : '+imin);

                        if((obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c == false && onlyweightCheck > 0 && weightCheck <= max) || (obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c == true && onlyweightCheck > 0 && onlyweightCheck <= imax && onlyweightCheck >= imin && weightCheck <= max)){
                            if((obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && (NewSOLI.ERP7__Serial__c == undefined || NewSOLI.ERP7__Serial__c == null || NewSOLI.ERP7__Serial__c == '')) || (obj[x].MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c && (NewSOLI.ERP7__Material_Batch_Lot__c == undefined || NewSOLI.ERP7__Material_Batch_Lot__c == null || NewSOLI.ERP7__Material_Batch_Lot__c == '')) || (WO.ERP7__Product__r.ERP7__Serialise__c && (NewSOLI.ERP7__MO_WO_Serial__c == undefined || NewSOLI.ERP7__MO_WO_Serial__c ==  null || NewSOLI.ERP7__MO_WO_Serial__c == '')) || (WO.ERP7__Product__r.ERP7__Lot_Tracked__c && (NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c == undefined || NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c == null || NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c == ''))){
                                cmp.set("v.exceptionError",$A.get('$Label.c.Required_fields_missing'));
                                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","")}), 5000);
                            }else if(obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && NewSOLI.ERP7__Serial__c != undefined && ((weight - obj[x].ActualWeight) > 1)){
                                cmp.set("v.exceptionError",$A.get('$Label.c.Serialised_product_invalid_quantity'));
                                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            }else if(error){
                                cmp.set("v.exceptionError",$A.get('$Label.c.Invalid_quantity_weight'));
                                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            }else if(selectedSerialNos.length > 0 && obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == false && selectedSerialNos2Send.length == 0){
                                cmp.set("v.exceptionError",$A.get('$Label.c.Required_field_missing_Serial_Number'));
                            }else{
                                console.log('0 : comp '+obj[x].MRP.ERP7__Fulfilled_Amount__c);
                                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");

                                //if(weight > obj[x].MRP.ERP7__Total_Amount_Required__c) obj[x].MRP.ERP7__Total_Amount_Required__c = parseFloat(weight); //((weight + Number.EPSILON) * 100) / 100;

                                if(selectedSerialNos2Send.length > 0){
                                    if(obj[x].MRP.ERP7__Fulfilled_Amount__c >= 0) obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c + (weight - (obj[x].ActualWeight/obj[x].WeightMultiplier))*obj[x].WeightMultiplier*selectedSerialNos2Send.length);
                                    else obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat((weight - (obj[x].ActualWeight/obj[x].WeightMultiplier))*obj[x].WeightMultiplier)*selectedSerialNos2Send.length;
                                }
                                else{
                                    if(obj[x].MRP.ERP7__Fulfilled_Amount__c >= 0) obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c + (weight - (obj[x].ActualWeight/obj[x].WeightMultiplier))*obj[x].WeightMultiplier);
                                    else obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat((weight - (obj[x].ActualWeight/obj[x].WeightMultiplier))*obj[x].WeightMultiplier);
                                }

                                /*
                                if(obj[x].MRP.ERP7__Fulfilled_Amount__c >= 0) {
                                    console.log('In If');
                                    obj[x].MRP.ERP7__Fulfilled_Amount__c = (parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c) + parseFloat((weight - obj[x].ActualWeight) * obj[x].WeightMultiplier));
                                }
                                else {
                                    obj[x].MRP.ERP7__Fulfilled_Amount__c = ((parseFloat(weight) - obj[x].ActualWeight)*obj[x].WeightMultiplier);
                                }
                                */
                                console.log('1 : '+obj[x].MRP.ERP7__Fulfilled_Amount__c);
                                //obj[x].MRP.ERP7__Fulfilled_Amount__c  = ((obj[x].MRP.ERP7__Fulfilled_Amount__c  + Number.EPSILON) * 100) / 100;
                                //alert('2 : '+obj[x].MRP.ERP7__Fulfilled_Amount__c);
                                var soliQuantity = weight - (obj[x].ActualWeight/obj[x].WeightMultiplier);
                                //var soliQuantity = weight - obj[x].ActualWeight;
                                cmp.set("v.Weight",0);
                                cmp.set("v.exceptionError","");
                                NewSOLI.ERP7__Quantity__c = soliQuantity; //((soliQuantity + Number.EPSILON) * 100) / 100; //parseFloat(soliQuantity);
                                var objsels = JSON.stringify(NewSOLI);
                                var objs = JSON.stringify(obj);
                                var moSerialNos = JSON.stringify(selectedSerialNos2Send);
                                var action = cmp.get("c.SaveNewSOLI");
                                action.setParams({
                                    NewSOLI: objsels,
                                    MRPs: objs,
                                    SerialNos: moSerialNos
                                });
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        if(response.getReturnValue().errorMsg != ''){
                                            cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                            cmp.set("v.MRPs", unchangedObj);
                                        }
                                        else {
                                            cmp.set("v.selectAllSerials",false);
                                            succeed = true;
                                            cmp.set("v.WeightStr","0");
                                            cmp.set("v.NewSOLI.ERP7__Material_Batch_Lot__c", undefined);
                                            cmp.set("v.NewSOLI.ERP7__Serial__c", undefined);
                                            console.log('response.getReturnValue() SaveNewSOLI :  ',response.getReturnValue());
                                            cmp.set("v.MRPs",response.getReturnValue().MRPSS);
                                            var ik = response.getReturnValue().MRPSS;
                                            var TW = 0;
                                            var Fulfilled = true;
                                            for(var y in ik){
                                                if(ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'gram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'kilogram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'milligram' || ik[y].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c == 'lbs') TW += ik[y].MRP.ERP7__Total_Amount_Required__c;
                                                if(ik[y].ActualWeight < ik[y].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
                                            }
                                            cmp.set("v.Fulfilled",Fulfilled);
                                            cmp.set("v.TotalWeight",TW);
                                            cmp.set("v.WCAP",true);
                                            console.log('NewSOLI : ',JSON.stringify(NewSOLI));
                                            if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
                                                var PrintSB = false;
                                                var objm = cmp.get("v.MRPs");
                                                for(var x in objm){
                                                    if(objm[x].isSelect) {
                                                        var quant = 0;
                                                        var quantin = 0;
                                                        quant = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                        if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                                                        //quant = Math.round((quant + Number.EPSILON) * 100) / 100;

                                                        var SOLISM = objm[x].SOLIs;
                                                        console.log('SOLISM : ',JSON.stringify(SOLISM));
                                                        for(var y in SOLISM){
                                                            quantin += SOLISM[y].ERP7__Quantity__c;
                                                            /*if(SOLISM[y].ERP7__MO_WO_Serial__c != undefined && SOLISM[y].ERP7__MO_WO_Serial__c != null) { // added if condition by shaguftha
                                                                if((SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                                                            } */
                                                            //quantin = Math.round((quantin + Number.EPSILON) * 100) / 100;
                                                            console.log('quantin : ',quantin);
                                                        }
                                                        if(quantin*objm[x].WeightMultiplier >= quant) cmp.set("v.WCAP",false);
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
                                                        qin += SOLISMS[y].ERP7__Quantity__c;
                                                        /*   if(SOLISM[y].ERP7__MO_WO_Serial__c != undefined && SOLISM[y].ERP7__MO_WO_Serial__c != null) { // added if condition by shaguftha
                                                        if((SOLISMS[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) qin += SOLISMS[y].ERP7__Quantity__c;
                                                              console.log('qin : ',qin);
                                                    } */
                                                    }
                                                    //qin =  Math.round((qin + Number.EPSILON) * 100) / 100;
                                                    //qmin = Math.round((qmin + Number.EPSILON) * 100) / 100;
                                                    //q = Math.round((q + Number.EPSILON) * 100) / 100;
                                                    //qmax= Math.round((qmax + Number.EPSILON) * 100) / 100;
                                                    if(qin*objm[x].WeightMultiplier >= qmin) PrintSB = true;
                                                    else{
                                                        PrintSB = false;
                                                        break;
                                                    }
                                                }
                                                cmp.set("v.PrintSB",PrintSB);

                                            }
                                        }
                                        console.log('aftr serial allocation called');
                                        cmp.loadSerialForAllocation();
                                        console.log('aftr serial allocation called');

                                    } else{
                                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                                    }
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                });
                                $A.enqueueAction(action);
                            }
                        }
                        else {
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            cmp.set("v.exceptionError",$A.get('$Label.c.Invalid_weight_to_capture'));
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            cmp.set("v.MRPs", unchangedObj);
                        }
                    }
                }
            } catch(err) {
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                console.log("Exception : "+err.message);
                cmp.set("v.MRPs", unchangedObj);
            }
        },

        upsertWeights: function(cmp, event) {
            //document.getElementById("weightspins").style.visibility = "visible";
            var obj = JSON.stringify(cmp.get("v.MRPs"));
            var action = cmp.get("c.SaveAllMRPs");
            action.setParams({
                MRPs: obj
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    if(response.getReturnValue().errorMsg == ''){
                        document.getElementById("weightspins").style.visibility = "hidden"
                        //$A.util.removeClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
                        //$A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
                        cmp.set("v.saPage", false);
                        cmp.popInit();
                    } //else document.getElementById("weightspins").style.visibility = "hidden";
                }
            });
            $A.enqueueAction(action);
        },

        NavRecord : function (component, event) {
            var RecId = event.target.getAttribute("title");
            //event.getSource().get("v.title");
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
                //document.getElementById("mrpspins").style.visibility = "hidden";
            }
            cmp.set("v.NewMRPs.MRPs",alternate_Mrps);
        },

        EditMRP : function (cmp, event) {
            var count = event.getSource().get("v.name");
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
                if (state === "SUCCESS") {
                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    cmp.set("v.NewMRPs",response.getReturnValue());
                    $A.util.addClass(cmp.find("editMRPModal"), 'slds-fade-in-open');
                    $A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
                } else{
                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                }
            });
            $A.enqueueAction(action);

        },

        closeEditMRPModal : function(cmp, event) {
            $A.util.removeClass(cmp.find("editMRPModal"), 'slds-fade-in-open');
            $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
        },

        updateMRPNew : function (cmp, event) {
            //document.getElementById("mrpspins").style.visibility = "visible";
            var mrp_Main = cmp.get("v.MRPEdit.MRP");
            var alternate_Mrps = JSON.stringify(cmp.get("v.NewMRPs.MRPSS"));
            var me = JSON.stringify(mrp_Main);
            var action = cmp.get("c.MRPUpdateNew");
            action.setParams({
                mrpMain1: JSON.stringify(mrp_Main),
                alternateMrps: alternate_Mrps
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    if(response.getReturnValue().errorMsg == ''){
                        $A.util.removeClass(cmp.find("editMRPModal"), 'slds-fade-in-open');
                        $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                        //document.getElementById("mrpspins").style.visibility = "hidden";
                    } //else document.getElementById("mrpspins").style.visibility = "hidden";
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
                        if(response.getReturnValue().errorMsg != ''){
                            cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
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

                            var NewSOLI = cmp.get("v.NewSOLI");
                            cmp.set("v.WCAP",true);
                            if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
                                var PrintSB = false;
                                var objm = cmp.get("v.MRPs");
                                for(var x in objm){
                                    if(objm[x].isSelect) {
                                        var quant = 0;
                                        var quantin = 0;
                                        quant = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                        if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;

                                        var SOLISM = objm[x].SOLIs;
                                        for(var y in SOLISM){
                                            if(SOLISM[y].ERP7__MO_WO_Serial__c != undefined && SOLISM[y].ERP7__MO_WO_Serial__c != null) { // added if condition by shaguftha
                                                if((SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                                            }
                                        }
                                        //quant = Math.round((quant + Number.EPSILON) * 100) / 100;
                                        //quantin = Math.round((quantin + Number.EPSILON) * 100) / 100;

                                        if(quantin*objm[x].WeightMultiplier >= quant) cmp.set("v.WCAP",false);
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
                                        if(SOLISMS[y].ERP7__MO_WO_Serial__c == NewSOLI.ERP7__MO_WO_Serial__c) qin += SOLISMS[y].ERP7__Quantity__c;
                                    }
                                    //qin = Math.round((qin + Number.EPSILON) * 100) / 100;
                                    //qmin = Math.round((qmin + Number.EPSILON) * 100) / 100;
                                    if(qin*objm[x].WeightMultiplier >= qmin) PrintSB = true;
                                    else{
                                        PrintSB = false;
                                        break;
                                    }
                                }
                                cmp.set("v.PrintSB",PrintSB);
                            }
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                        cmp.loadSerialForAllocation();
                    } else {
                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
        },

        SerialBOMValidation : function(cmp, event, helper) {
            var NewSOLI = cmp.get("v.NewSOLI");
            cmp.set("v.WCAP",true);
            if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
                var PrintSB = false;
                var objm = cmp.get("v.MRPs");
                for(var x in objm){
                    if(objm[x].isSelect) {
                        var quant = 0;
                        var quantin = 0;
                        quant = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                        if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;

                        var SOLISM = objm[x].SOLIs;
                        for(var y in SOLISM){
                            if(SOLISM[y].ERP7__MO_WO_Serial__c != undefined && SOLISM[y].ERP7__MO_WO_Serial__c != null) { // added if condition by shaguftha
                                if((SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                            }
                        }
                        //quant = Math.round((quant + Number.EPSILON) * 100) / 100;
                        //quantin = Math.round((quantin + Number.EPSILON) * 100) / 100;
                        if(quantin*objm[x].WeightMultiplier >= quant) cmp.set("v.WCAP",false);
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
                        if(SOLISMS[y].ERP7__MO_WO_Serial__c == NewSOLI.ERP7__MO_WO_Serial__c) qin += SOLISMS[y].ERP7__Quantity__c;
                    }
                    //qin = Math.round((qin + Number.EPSILON) * 100) / 100;
                    //qmin = Math.round((qmin + Number.EPSILON) * 100) / 100;
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
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var RecId = event.getSource().get("v.name");
            var action = cmp.get("c.StartWORec");
            action.setParams({ RecId : RecId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try {
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.popInit();
                    } catch(err) {
                        cmp.set("v.exceptionError", err.message);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
        },

        /*    WO2Finish : function (cmp, event) {
            console.log('WO2Finish called');

            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var UpdateWORec = event.getSource().get("v.name");

            var qtyBuild = 0;
            var qtyScrap = 0;
            var wipFlows = cmp.get("v.WIPFlows");
            //alert(wipFlows.length);
            if(wipFlows.length > 0){
                for(var i in wipFlows){
                    console.log('wipFlows[i] : ',JSON.stringify(wipFlows[i]));
                    if(wipFlows[i].wipFlow.ERP7__Quantity__c > 0){
                        qtyBuild += wipFlows[i].wipFlow.ERP7__Quantity__c;
                    }
                    if(wipFlows[i].wipFlow.ERP7__Quantity_Scrapped__c > 0){
                        qtyScrap += wipFlows[i].wipFlow.ERP7__Quantity_Scrapped__c;
                    }

                }
            }
            if(qtyBuild > 0) cmp.set("v.showCompleteWO",true);
            else cmp.set('v.showCompleteWO',false);
            var action = cmp.get("c.GetWORec");
            action.setParams({ RecId : UpdateWORec});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.WO2Fin", response.getReturnValue().WorkOrder);
                    let objs = response.getReturnValue().MRPSS;
                    console.log('response GetWORec : ',response.getReturnValue());
                    cmp.set("v.MRPSS", objs);
                    console.log('EnterconsumeQty : ',cmp.get('v.EnterconsumeQty'));

                    if(cmp.get('v.EnterconsumeQty') == true){
                        if(!cmp.get('v.ManuOrder.ERP7__Product__r.ERP7__Serialise__c')) {
                            var MRPS = cmp.get('v.MRPSS');
                            for(var i in MRPS){
                                if(MRPS[i].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c){
                                    cmp.set('v.WIPflowQty',1);
                                    cmp.set("v.ToProduce",1);
                                }
                            }
                            if(cmp.get("v.WIPflowQty") == 0) {
                                var remainigQty = cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c') - (qtyBuild + qtyScrap);
                                cmp.set("v.WIPflowQty",remainigQty);
                                cmp.set("v.ToProduce",remainigQty);
                            }
                            console.log('ToProduce finish : ',cmp.get("v.ToProduce"));
                        }
                    }

                    cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                    //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    var obj = cmp.get("v.WIPs");
                    for(var x in obj){
                        if(0 == x) {
                            cmp.set("v.SelectedWIP",obj[x].wipFlow);
                        }
                    }
                    cmp.set("v.WIPs",obj);
                    //cmp.set("v.WO2Fin.ERP7__Quantity_Built__c", qtyBuild);
                }
                if(cmp.get("v.WIPFlows").length > 0){//
                    //$A.util.addClass(cmp.find("finishModal"),"slds-fade-in-open");
                    cmp.set("v.fPage",true);
                    if(cmp.get("v.MRPSS").length > 0){
                        var MRPSS = cmp.get("v.MRPSS");
                        var WO = cmp.get("v.WorkOrder");
                        for(var x in MRPSS){

                        }
                    }
                    cmp.set("v.MRPSS", MRPSS);
                    var producedQty = 0;
                    var scrapQty = 0;
                    var obj = cmp.get("v.WIPFlows");
                    for(var y in obj){
                        console.log('obj[y] : ',JSON.stringify(obj[y]));
                       // if(obj[y].wipFlow.ERP7__Status__c == "Completed"){
                            if(obj[y].wipFlow.ERP7__Quantity__c > 0)
                                producedQty += obj[y].wipFlow.ERP7__Quantity__c;
                            if(obj[y].wipFlow.ERP7__Quantity_Scrapped__c > 0)
                                scrapQty += obj[y].wipFlow.ERP7__Quantity_Scrapped__c;
                       // }
                    }
                    producedQty = Number.parseFloat(producedQty).toFixed(4);
                    scrapQty = Number.parseFloat(scrapQty).toFixed(4);
                    console.log('scrapQty : ',scrapQty);
                    console.log('producedQty : ',producedQty);
                    cmp.set("v.WO2Fin.ERP7__Quantity_Built__c", producedQty);
                    cmp.set("v.WO2Fin.ERP7__Quantity_Scrapped__c", scrapQty);

                }
                else if(cmp.get("v.MRPSS").length > 0 && cmp.get("v.WIPFlows").length <= 0){
                    cmp.set("v.fPage",true);
                    var producedQty = 0;
                    var scrapQty = 0;
                    var isCommitted = true;
                    var WO = cmp.get("v.WorkOrder");
                    var MRPSS = cmp.get("v.MRPSS");

                }
                    else{
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set("v.WO2Fin.ERP7__Quantity_Built__c",cmp.get("v.WO2Fin.ERP7__Quantity_Ordered__c "));
                        var finishAction = cmp.get("c.FinishWO1");
                        $A.enqueueAction(finishAction);
                    }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                //$A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
            });
            $A.enqueueAction(action);
      }, */
        WO2Finish : function (cmp, event) {
            console.log('WO2Finish called');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var agentWO = cmp.get("v.agentWOId");
            console.log('agentWO',agentWO);
            var UpdateWORec = event.getSource().get("v.name");
            var MOId = JSON.stringify(cmp.get("v.ManuOrder"));
            if(agentWO){
                UpdateWORec = agentWO;
            }
            console.log('UpdateWORec',UpdateWORec);
            console.log('MOId',MOId);
            //if(UpdateWORec == undefined || UpdateWORec == null || UpdateWORec == '') UpdateWORec = cmp.get("v.WorkOrder.Id");
            var qtyBuild = 0;
            var qtyScrap = 0;
            var wipFlows = cmp.get("v.WIPFlows");
            console.log('wipFlows : ', wipFlows);
            var action = cmp.get("c.GetWORec");
            action.setParams({
                RecId: UpdateWORec,
                MO: MOId,
                MRPS: JSON.stringify(cmp.get("v.MRPs"))
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.WO2Fin", response.getReturnValue().WorkOrder);
                    let objs = response.getReturnValue().MRPSS;
                    console.log('response GetWORec : ',response.getReturnValue());
                    cmp.set("v.MRPSS", objs);
                    console.log('EnterconsumeQty : ',cmp.get('v.EnterconsumeQty'));
                    cmp.set("v.startingSerial",'');
                    cmp.set("v.startNum",0);
                    cmp.set("v.endNum",200);
                    cmp.set("v.TotalWIPQtyProduced",0);
                    cmp.set("v.TotalWIPQtyScrapped",0);
                    //alert('1');
                    var serials = response.getReturnValue().moSerialNos;
                    console.log('serials bfr : ',serials);
                    // Assuming 'serials' is an array of objects with a 'Name' property
                    // Assuming 'serials' is an array of objects with a 'Name' property
                    if(serials != undefined && serials.length > 0)
                    { serials.sort((a, b) => {
                        // Extract the numeric portion using regular expressions
                        var matchA = a.Name.match(/-(\d+)/);
                        var aNumber = matchA ? parseInt(matchA[1]) : parseInt(a.Name);
                        console.log('aNumber : ',aNumber);
                        var matchB = b.Name.match(/-(\d+)/);
                        var bNumber = matchB ? parseInt(matchB[1]) : parseInt(b.Name);
                        console.log('bNumber : ',bNumber);
                        // Pad the numbers with leading zeros to ensure consistent number of digits
                        var aPadded = aNumber.toString().padStart(4, '0');
                        console.log('aPadded : ',aPadded);
                        var bPadded = bNumber.toString().padStart(4, '0');
                        console.log('aPadded : ',aPadded);

                        // Compare the padded numbers
                        return aPadded.localeCompare(bPadded);
                    });
                     console.log('serials after : ',serials);
                    }
                    /* var MRPNEw = cmp.get('v.MRPs');
                    for(var x in MRPNEw){
                        for(var y in objs){
                            if(MRPNEw[x].MRP.Id == objs[y].MRP.Id){
                               MRPNEw[x].StockallocatedSerials =   objs[y].StockallocatedSerials;
                                break;
                            }
                        }
                    }*/
                    //added changes to keep the bom with 0 qty and proceed with building the end product 
                    var serials2Produce = [];
                    for(var x in serials){
                        var mrpcount = 0;
                        var totalRequiredMRPs = 0;// added by bushra
                        for(var y in objs){
                            var mrp = objs[y].MRP;// added by bm
                            var soli = objs[y].StockallocatedSerials;
                            if (mrp.ERP7__Total_Amount_Required__c > 0) {
                                totalRequiredMRPs++;
                            }
                            if (mrp.ERP7__Total_Amount_Required__c == 0) {
                                // NEW: Zero-req BOMs auto-count as "allocated" (no stock needed)
                                mrpcount++;
                            }
                           else if(soli != undefined && soli.length > 0){
                                if(soli.includes(serials[x].Id)) {
                                    mrpcount++;
                                    console.log('match');
                                }
                            }

                        }
                        console.log('mrpcount : ',mrpcount);
                        console.log('objs.length : ',objs.length);
                        /*if(mrpcount == objs.length){
                            console.log('in match');
                            serials[x].selected = false;
                            serials2Produce.push(serials[x]);
                        }*/
                        if (mrpcount >= totalRequiredMRPs) { 
                            serials[x].selected = false;
                            serials2Produce.push(serials[x]);
                        }
                    }
                    console.log('serials2Produce : ',serials2Produce);
                    cmp.set("v.moSerialForProduction",serials2Produce);
                }
                if(cmp.get('v.ManuOrder.ERP7__Product__r.ERP7__Serialise__c')) cmp.set('v.showWIPsection',false);
                if(cmp.get('v.EnterconsumeQty') == true){
                    if(!cmp.get('v.ManuOrder.ERP7__Product__r.ERP7__Serialise__c')) {
                        var MRPS = cmp.get('v.MRPSS');
                        for(var i in MRPS){
                            if(MRPS[i].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c){
                                cmp.set('v.WIPflowQty',1);
                                cmp.set("v.ToProduce",1);
                            }
                        }
                        if(cmp.get("v.WIPflowQty") == 0) {
                            var remainigQty = cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c') - (qtyBuild + qtyScrap);
                            cmp.set("v.WIPflowQty",remainigQty);
                            cmp.set("v.ToProduce",remainigQty);
                        }
                        console.log('ToProduce finish : ',cmp.get("v.ToProduce"));
                    }
                }

                cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                var obj = cmp.get("v.WIPs");
                for(var x in obj){
                    if(0 == x) {
                        console.log('here 1');
                        cmp.set("v.SelectedWIP",obj[x].wipFlow);
                    }
                }
                cmp.set("v.WIPs",obj);
                //alert('13');
                if(cmp.get("v.WIPFlows").length > 0){//
                    cmp.set("v.fPage",true);
                    var producedQty = 0;
                    var scrapQty = 0;
                    var obj = cmp.get("v.WIPFlows");
                    for(var y in obj){
                        console.log('obj[y] : ',JSON.stringify(obj[y]));
                        if(obj[y].wipFlow.ERP7__Quantity__c > 0)
                            producedQty += obj[y].wipFlow.ERP7__Quantity__c;
                        if(obj[y].wipFlow.ERP7__Quantity_Scrapped__c > 0)
                            scrapQty += obj[y].wipFlow.ERP7__Quantity_Scrapped__c;
                    }
                    producedQty = Number.parseFloat(producedQty).toFixed(4);
                    scrapQty = Number.parseFloat(scrapQty).toFixed(4);
                    cmp.set("v.WO2Fin.ERP7__Quantity_Built__c", producedQty);
                    cmp.set("v.WO2Fin.ERP7__Quantity_Scrapped__c", scrapQty);

                }
                else if(cmp.get("v.MRPSS").length > 0 && cmp.get("v.WIPFlows").length <= 0){
                    cmp.set("v.fPage",true);
                    var producedQty = 0;
                    var scrapQty = 0;
                    var isCommitted = true;
                    var WO = cmp.get("v.WorkOrder");
                    var MRPSS = cmp.get("v.MRPSS");

                }
                    else{
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set("v.WO2Fin.ERP7__Quantity_Built__c",cmp.get("v.WO2Fin.ERP7__Quantity_Ordered__c "));
                        var finishAction = cmp.get("c.FinishWO1");
                        $A.enqueueAction(finishAction);
                    }
                //alert('14');
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                //$A.util.addClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
            });
            $A.enqueueAction(action);
        },

        Consume_ScrapQty : function (cmp, event){
            console.log('Consume_ScrapQty called' );
            var MRPSS = cmp.get("v.MRPSS");
            var WO = cmp.get("v.WorkOrder");
            if(cmp.get("v.ToProduce") > WO.ERP7__Quantity_Ordered__c) cmp.set("v.ToProduce", WO.ERP7__Quantity_Ordered__c);
            if(cmp.get("v.ToProduce") < 0) cmp.set("v.ToProduce", 0);
            console.log('ToScrap bfr :',cmp.get("v.ToScrap"));
            console.log('ToProduce bfr :',cmp.get("v.ToProduce"));
            console.log('WO.ERP7__Quantity_Ordered__c" :',WO.ERP7__Quantity_Ordered__c);
            if(cmp.get("v.ToScrap") > WO.ERP7__Quantity_Ordered__c) cmp.set("v.ToScrap", WO.ERP7__Quantity_Ordered__c);
            if(cmp.get("v.ToScrap") < 0) cmp.set("v.ToScrap", 0);
            var ToProduce = cmp.get("v.ToProduce");
            var ToScrap = cmp.get("v.ToScrap");
            console.log('ToScrap after :',ToScrap);
            console.log('ToProduce after :',ToProduce);
            for(var x in MRPSS){
                if(ToProduce >= 0){
                   /* if(WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) && MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) {
                        if(ToProduce == 0) MRPSS[x].quantityToConsume = 0;
                        else MRPSS[x].quantityToConsume = Number.parseFloat(MRPSS[x].MRP.ERP7__BOM__r.ERP7__Quantity__c).toFixed(4); // it was 1 - imran change
                    }
                    else {*/
                        /* if(MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Total_Amount_Required__c > MRPSS[x].MRP.ERP7__Fulfilled_Amount__c) //&& (Number.parseFloat(MRPSS[x].MRP.ERP7__BOM__r.ERP7__For_Multiples__c) * Number.parseFloat(WO.ERP7__Quantity_Ordered__c)) == MRPSS[x].MRP.ERP7__Fulfilled_Amount__c){
                        {
                            console.log('If condition satisfies');
                            MRPSS[x].quantityToConsume = (WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c ))? Number.parseFloat((MRPSS[x].MRP.ERP7__Fulfilled_Amount__c*ToProduce)/WO.ERP7__Quantity_Ordered__c).toFixed(4) : 0;
                        } */
                        // Commented to get the qty based on total amount required not based on the fulfilled amount for example if total MO Qty is 5 and fulfillied is 3 then the Consume will be (3 * 3)/5 = 1.8 which is not correct
                        // else
                        MRPSS[x].quantityToConsume = (WO.ERP7__Quantity_Ordered__c >=0 && ToProduce >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c ))? Number.parseFloat((MRPSS[x].MRP.ERP7__Total_Amount_Required__c*ToProduce)/WO.ERP7__Quantity_Ordered__c).toFixed(4) : 0;
                        /*if(MRPSS[x].MRP.ERP7__Fulfilled_Amount__c < (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap))
                        {
                         if(ToProduce > 0)  MRPSS[x].quantityToConsume = Number.parseFloat(((MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap +  MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) - MRPSS[x].MRP.ERP7__Fulfilled_Amount__c)).toFixed(4); }*/
                    //}
                    console.log('MRPSS[x].quantityToConsume after :',MRPSS[x].quantityToConsume);

                }
                if(ToScrap >= 0){
                    //ToScrap >= 0 is removed on 10/04/23 from below if condition as it was making both the scrap and consume qty as 1 for serialise prod
                   /* if(WO.ERP7__Quantity_Ordered__c >=0 && ToScrap >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) && MRPSS[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) {
                        if(ToScrap == 0) MRPSS[x].quantityToScrap = 0;
                        else MRPSS[x].quantityToScrap = Number.parseFloat(MRPSS[x].MRP.ERP7__BOM__r.ERP7__Quantity__c).toFixed(4);// it was 1 - imran change
                    }
                    else {*/
                        MRPSS[x].quantityToScrap = (WO.ERP7__Quantity_Ordered__c >=0 && ToScrap >= 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c > 0 && MRPSS[x].MRP.ERP7__Fulfilled_Amount__c != (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c ))? Number.parseFloat((MRPSS[x].MRP.ERP7__Total_Amount_Required__c*ToScrap)/WO.ERP7__Quantity_Ordered__c).toFixed(4) : 0;
                        /* if(MRPSS[x].MRP.ERP7__Fulfilled_Amount__c < (MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].MRP.ERP7__Scrapped_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap))
                        {
                         if(ToScrap > 0)  MRPSS[x].quantityToScrap = ((MRPSS[x].MRP.ERP7__Consumed_Quantity__c + MRPSS[x].quantityToConsume + MRPSS[x].quantityToScrap +  MRPSS[x].MRP.ERP7__Scrapped_Quantity__c) - MRPSS[x].MRP.ERP7__Fulfilled_Amount__c); }*/

                   // }
                    console.log('MRPSS[x].quantityToScrap after :',MRPSS[x].quantityToScrap);

                }
            }
            cmp.set("v.MRPSS",MRPSS);
        },

        FinishWIPFlow : function (cmp, event) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            if(cmp.get("v.wipFlowIndex") == -1){
                cmp.set("v.wipFlowIndex", event.currentTarget.dataset.index);
                var count = cmp.get("v.wipFlowIndex");
            }
            else var count = cmp.get("v.wipFlowIndex");
            var obj = cmp.get("v.WIPFlows");
            var isMOserial = cmp.get("v.ManuOrder.ERP7__Serialise__c");
            var totalWIPFlowQty = 0;
            for(var i in obj){
                totalWIPFlowQty += Number(obj[i].wipFlow.ERP7__Quantity__c);
            }
            //totalWIPFlowQty = Math.round((totalWIPFlowQty + Number.EPSILON) * 100) / 100;
            if(obj[count].wipFlow.ERP7__Quantity__c > 0){
                cmp.set("v.WO2Fin.wipFlow.ERP7__Quantity_Built__c", obj[count].wipFlow.ERP7__Quantity__c);
                if(!obj[count].wipFlow.ERP7__Product__r.ERP7__Serialise__c && (totalWIPFlowQty == cmp.get("v.WO2Fin.ERP7__Quantity_Ordered__c")))
                    obj[count].wipFlow.ERP7__Status__c = "Completed";
                else if(obj[count].wipFlow.ERP7__Product__r.ERP7__Serialise__c || isMOserial)
                    obj[count].wipFlow.ERP7__Status__c = "Completed";
                var WFlow = JSON.stringify(obj[count]);
                var action = cmp.get("c.CompleteWIPFlow");
                action.setParams({ WIPFlow : WFlow});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        cmp.set("v.WIPs", response.getReturnValue().WIPs);
                        cmp.set("v.MRPSS",response.getReturnValue().MRPSS);
                        if(obj[count].ERP7__Status__c !="Completed") obj.push(response.getReturnValue().WIPFlows[0]);
                        cmp.set("v.WIPFlows",obj);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.popInit();
                    }
                    cmp.set("v.wipFlowIndex", -1);
                });
                $A.enqueueAction(action);
            }
            else{
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        },

        setScrapWIPFlow : function (cmp, event) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //var count = event.currentTarget.getAttribute('data-wfcount');
            var count = 0;
            var obj = cmp.get("v.WIPFlows");
            var isMOserial = cmp.get("v.ManuOrder.ERP7__Serialise__c");
            obj[count].ERP7__Type__c = "Scrapped";
            var totalWIPFlowQty = 0;
            for(var i in obj){
                totalWIPFlowQty += Number(obj[i].wipFlow.ERP7__Quantity__c);
            }
            //totalWIPFlowQty = Math.round((totalWIPFlowQty + Number.EPSILON) * 100) / 100;
            if(obj[count].wipFlow.ERP7__Quantity__c > 0){
                if(!obj[count].wipFlow.ERP7__Product__r.ERP7__Serialise__c && (totalWIPFlowQty == cmp.get("v.WO2Fin.ERP7__Quantity_Ordered__c")))
                    obj[count].wipFlow.ERP7__Status__c = "Completed";
                else if(obj[count].wipFlow.ERP7__Product__r.ERP7__Serialise__c || isMOserial)
                    obj[count].wipFlow.ERP7__Status__c = "Completed";
                var action = cmp.get("c.ScrapWIPFlow");
                action.setParams({
                    WIPFlow : JSON.stringify(obj[count])
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        try {
                            cmp.set("v.WIPs", response.getReturnValue().WIPs);
                            cmp.set("v.MRPSS",response.getReturnValue().MRPSS);
                            if(obj[count].wipFlow.ERP7__Status__c !="Completed")
                                obj.push(response.getReturnValue().WIPFlows[0]);
                            cmp.set("v.WIPFlows",obj);
                            var producedQty = 0;
                            var scrapQty = 0;
                            for(var y in obj){
                                if(obj[y].ERP7__Status__c == "Completed"){
                                    if(obj[y].ERP7__Type__c == "Produced")
                                        producedQty += obj[y].ERP7__Quantity__c;
                                    if(obj[y].ERP7__Type__c == "Scrapped")
                                        scrapQty += obj[y].ERP7__Quantity__c;
                                }
                            }
                            cmp.set("v.WO2Fin.ERP7__Quantity_Built__c",producedQty);
                            cmp.set("v.WO2Fin.ERP7__Quantity_Scrapped__c",scrapQty);
                            cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                            cmp.popInit();
                        } catch(err) {
                            cmp.set("v.exceptionError", err.message);
                            //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                        }
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
            else{
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        },

        validateBuiltQnty  : function(cmp, event, helper) {
            var WORec = cmp.get("v.WO2Fin");
            if(WORec.ERP7__Quantity_Built__c > WORec.ERP7__Quantity_Ordered__c){
                WORec.ERP7__Quantity_Built__c = WORec.ERP7__Quantity_Ordered__c;
                cmp.set("v.WO2Fin",WORec);
            }
        },

        validateFlowQnty  : function(cmp, event, helper) { // method changed by shaguftha on 08/08/23 to add a validation to prevent produce or scrap greater than orderedQty
            var obj = cmp.get("v.WIPFlows");
            cmp.set('v.exceptionError','');
            var count = event.getSource().get("v.name");
            console.log('count : ',count);
            var enterQty = Number(cmp.get('v.WIPflowQty'));
            console.log('enterQty : ',enterQty);
            var type = cmp.get('v.WIPflowType');
            var producedQty = 0;
            var scrapQty = 0;
            var processQty = 0;
            if(type == "Produced") producedQty += enterQty;
            else if(type == "Scrapped")  scrapQty += enterQty;
            //  var MRPS = cmp.get('v.MRPSS');
            /* for(var i in MRPS){
                console.log('MRPS[i] : ',MRPS[i]);
                console.log('obj[count] : ',obj[count]);
                if(MRPS[i].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c &&  obj[count].wipFlow.ERP7__Product__r.ERP7__Serialise__c != true && enterQty > 1){
                    cmp.set('v.exceptionError','There is a serialized BOM.You can produce only 1 Qty');
                    cmp.set('v.WIPflowQty',1);
                    return;
                }
            }*/
            for(var x in obj){
                if(obj[x].wipFlow.Id == count){//x == count
                    if(obj[x].wipFlow.ERP7__Quantity__c > 0){
                        producedQty += obj[x].wipFlow.ERP7__Quantity__c;
                    }
                    if(obj[x].wipFlow.ERP7__Quantity_Scrapped__c > 0){
                        scrapQty += obj[x].wipFlow.ERP7__Quantity_Scrapped__c;
                    }
                    console.log('producedQty : ',producedQty);
                    console.log('scrapQty : ',scrapQty);
                    if(enterQty > obj[x].wipFlow.ERP7__Quantity_Ordered__c && obj[x].wipFlow.ERP7__Quantity__c == 0 && obj[x].wipFlow.ERP7__Quantity_Scrapped__c == 0){
                        var qty = obj[x].wipFlow.ERP7__Quantity_Ordered__c;
                        cmp.set('v.WIPflowQty',qty);
                        enterQty = qty;
                        console.log('qty : ',qty);
                        cmp.set('v.exceptionError',$A.get('$Label.c.The_sum_of_qty_produced_and_scrapped_cannot_be_greater_than_order_qty'));

                    }
                    else if((obj[x].wipFlow.ERP7__Quantity__c + obj[x].wipFlow.ERP7__Quantity_Scrapped__c + enterQty) > obj[x].wipFlow.ERP7__Quantity_Ordered__c){
                        var qty = (obj[x].wipFlow.ERP7__Quantity_Ordered__c - (obj[x].wipFlow.ERP7__Quantity__c + obj[x].wipFlow.ERP7__Quantity_Scrapped__c));
                        cmp.set('v.WIPflowQty',Number(qty));
                        enterQty = qty;
                        console.log('qty 2: ',qty);
                        cmp.set('v.exceptionError',$A.get('$Label.c.The_sum_of_qty_produced_and_scrapped_cannot_be_greater_than_order_qty'));

                    }

                }
                /* if(obj[x].wipFlow.ERP7__Status__c == "Completed"){

                  if(obj[x].wipFlow.ERP7__Type__c == "Produced")
                        producedQty += enterQty; // Number(obj[x].ERP7__Quantity__c);
                    if(obj[x].wipFlow.ERP7__Type__c == "Scrapped")
                        scrapQty += enterQty; //Number(obj[x].ERP7__Quantity__c);
                    if(obj[x].wipFlow.ERP7__Type__c == "Processed")
                        processQty += enterQty; //Number(obj[x].ERP7__Quantity__c);
                } */
            }
            //producedQty = Math.round((producedQty + Number.EPSILON) * 100) / 100;
            //scrapQty = Math.round((scrapQty + Number.EPSILON) * 100) / 100;
            //processQty = Math.round((processQty + Number.EPSILON) * 100) / 100;

            /* var flow = JSON.stringify(obj[count]);
            var processqty = obj[count].wipFlow.ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c * obj[count].wipFlow.ERP7__Quantity_Unit__c - (producedQty+scrapQty+processQty);
            if(obj[count].wipFlow.ERP7__Product__c == obj[count].wipFlow.ERP7__Work_Orders__r.ERP7__Product__c && obj[count].wipFlow.ERP7__Product__r.ERP7__Serialise__c == true && obj[count].wipFlow.ERP7__Quantity__c > 1){
                obj[count].wipFlow.ERP7__Quantity__c = 1;
                console.log('in 1');
                cmp.set("v.WIPFlows",obj);
            }
            else if(obj[count].wipFlow.ERP7__Product__c == obj[count].wipFlow.ERP7__Work_Orders__r.ERP7__Product__c && obj[count].wipFlow.ERP7__Quantity__c > (obj[count].wipFlow.ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c * obj[count].wipFlow.ERP7__Quantity_Unit__c - (producedQty+scrapQty))){
                obj[count].wipFlow.ERP7__Quantity__c = obj[count].wipFlow.ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c * obj[count].wipFlow.ERP7__Quantity_Unit__c - (producedQty+scrapQty);
                console.log('in 2');
                cmp.set("v.WIPFlows",obj);
            }
                else if(obj[count].wipFlow.ERP7__Product__c != obj[count].wipFlow.ERP7__Work_Orders__r.ERP7__Product__c && obj[count].wipFlow.ERP7__Quantity__c > (obj[count].wipFlow.ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c * obj[count].wipFlow.ERP7__Quantity_Unit__c - (producedQty+scrapQty))){
                    console.log('in 3');
                }*/
            if(type == "Produced") cmp.set("v.ToProduce", enterQty);
            else if(type == "Scrapped") cmp.set("v.ToScrap", enterQty);
            var WORec = cmp.get('v.WorkOrder');
            console.log('WORec : ',JSON.stringify(WORec));
            console.log('MaxAllowedCuts : ',cmp.get('v.MaxAllowedCuts'));
            console.log('maxCutValidation : ',cmp.get('v.maxCutValidation'));
            var totalProduced = parseFloat(enterQty) + parseFloat(WORec.ERP7__Quantity_Built__c)  + parseFloat(WORec.ERP7__Quantity_Scrapped__c);
            console.log('totalProduced : ',totalProduced);
            if(cmp.get('v.maxCutValidation') && totalProduced > cmp.get('v.MaxAllowedCuts')){
                console.log('in');
                cmp.set('v.WIPflowQty',0);
                cmp.set('v.exceptionError',$A.get('$Label.c.The_Quantity_Produced_cannot_be_greater_than_expected') +' : '+cmp.get('v.MaxAllowedCuts'));
            }
        },

        FinishWO1 : function (cmp, event, helper) {
            $A.util.removeClass(cmp.find("mainSpin"),"slds-hide");
            var MRPS_toUse = cmp.get("v.MRPSS");
            var WO = cmp.get("v.WorkOrder");
            var stock2Consume = 0;
            var stock2Scrap = 0;
            var ConsumedMRPCount = 0;
            for (var i in MRPS_toUse){
                console.log('MRPS_toUse : ',MRPS_toUse[i]);
                stock2Consume += Number(Number(MRPS_toUse[i].MRP.ERP7__Consumed_Quantity__c) + Number(MRPS_toUse[i].quantityToConsume));
                stock2Scrap += Number(Number(MRPS_toUse[i].MRP.ERP7__Scrapped_Quantity__c) + Number(MRPS_toUse[i].quantityToScrap));
                if(((Number(Number(MRPS_toUse[i].MRP.ERP7__Consumed_Quantity__c) + Number(MRPS_toUse[i].quantityToConsume))) + ( Number(Number(MRPS_toUse[i].MRP.ERP7__Scrapped_Quantity__c) + Number(MRPS_toUse[i].quantityToScrap)))) == MRPS_toUse[i].MRP.ERP7__Total_Amount_Required__c){
                     ConsumedMRPCount += 1;
                }
            }
             if((Number(WO.ERP7__Quantity_Built__c) + Number(WO.ERP7__Quantity_Scrapped__c)) == Number(WO.ERP7__Quantity_Ordered__c)){
        WO.ERP7__Status__c = 'Complete';
        console.log('Setting WO Status to Complete - Qty matches');
    }
            if(ConsumedMRPCount > 0 && MRPS_toUse != undefined && ConsumedMRPCount != MRPS_toUse.length && cmp.get('v.hideToProduceforMRP')) cmp.set('v.showCompleteWO',true);
            console.log('showCompleteWO : ',cmp.get('v.showCompleteWO'));
            console.log('MRPS_toUse.length : ',MRPS_toUse.length);
            if(MRPS_toUse != undefined && ConsumedMRPCount == MRPS_toUse.length && cmp.get('v.hideToProduceforMRP')) {//
                WO.ERP7__Status__c = 'Complete';console.log('set wo status her2??');
                WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Ordered__c;
                cmp.set("v.WO2Fin",WO);
                cmp.set('v.WorkOrder',WO);
            }
            console.log('stock2Consume : '+stock2Consume);
            console.log('stock2Scrap : '+stock2Scrap);
            console.log('WO : ',WO);

            if((stock2Consume + stock2Scrap) > 0){
                var BOMaction = cmp.get("c.CommitTaskonFinsh");
                BOMaction.setCallback(this, function(response) {
                    if(response.getState() === "SUCCESS") {
                        console.log('response.getReturnValue() FinishWO1: ',response.getReturnValue());
                        if(!response.getReturnValue()) {
                            helper.finalFinishWO(cmp, event);
                        }
                    }
                });
                $A.enqueueAction(BOMaction);
            }
            else{
                helper.finalFinishWO(cmp, event);
            }
        },

        //Build_Commit
        FinishWO : function (cmp, event, helper) {
            console.log('FinishWO called');

            var WO = cmp.get("v.WorkOrder");
            var Task = cmp.get("v.SelectedTask");
            var wipStatus = '';
            var typewip = cmp.get('v.WIPflowType');
            console.log('showWIPsection~>'+cmp.get('v.showWIPsection'));

            if(cmp.get('v.showWIPsection')){

                var wipflows = cmp.get('v.WIPFlows');
                console.log('wipflows : ',wipflows);
                if(wipflows.length == 0) {
                    console.log('if');
                    var finishAction = cmp.get("c.FinishWO1");
                    console.log('FinishWO1 calling');
                    $A.enqueueAction(finishAction);
                }
                else{
                    console.log('inhere else');
                    var AllMRPs = cmp.get('v.MRPSS');

                    var ToProduce = cmp.get("v.ToProduce");
                    cmp.set("v.exceptionError", "");
                    var error = false;
                    if(ToProduce == null || ToProduce == undefined || cmp.get('v.WIPflowQty') == null || cmp.get('v.WIPflowQty') == undefined){
                        cmp.set("v.exceptionError", $A.get('$Label.c.Built_quantity_cannot_be_null'));
                        error = true;
                    }

                    if(!error){
                        for(var x in AllMRPs){
                            console.log('AllMRPs[x] FinishWO : ',AllMRPs[x]);
                             let mrp = AllMRPs[x].MRP;
                            //mrp.ERP7__Total_Amount_Required__c != 0 , was added to build the end product if the req qty of any of any of the bom is 0
                            if(mrp.ERP7__Total_Amount_Required__c > 0 && mrp.ERP7__Fulfilled_Amount__c == 0){
                                cmp.set("v.exceptionError", $A.get('$Label.c.Please_allocate_stock_to_consume'));
                                error = true;
                            }
                            if(AllMRPs[x].quantityToConsume == null || AllMRPs[x].quantityToScrap == null){
                                cmp.set("v.exceptionError", $A.get('$Label.c.Required_fields_missing'));
                                error = true;
                            }
                            const sumofall = Number.parseFloat((Number(AllMRPs[x].MRP.ERP7__Consumed_Quantity__c) + Number(AllMRPs[x].MRP.ERP7__Scrapped_Quantity__c) + Number(AllMRPs[x].quantityToConsume) + Number(AllMRPs[x].quantityToScrap))).toFixed(4);
                            if(sumofall > Number(AllMRPs[x].MRP.ERP7__Fulfilled_Amount__c)){
                                cmp.set("v.exceptionError", $A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot') +AllMRPs[x].MRP.ERP7__MRP_Product__r.Name);
                                error = true;
                                break;
                            }
                            console.log('AllMRPs[x].quantityToConsume : ',AllMRPs[x].quantityToConsume);
                            console.log('AllMRPs[x].quantityToScrap : ',AllMRPs[x].quantityToScrap);
                            let totalqty = (parseFloat(AllMRPs[x].quantityToConsume) + parseFloat(AllMRPs[x].quantityToScrap));
                            console.log('totalqty : ',totalqty);
                           /*if(AllMRPs[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && (totalqty > 1)){
                                cmp.set("v.exceptionError", $A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot_be'));
                                error = true;
                                break;
                            }  commented by shaguftha on 23_11_23*/
                        }
                    }

                    if(!error){
                        for(var x in AllMRPs){
                            AllMRPs[x].MRP.ERP7__Consumed_Quantity__c = Number.parseFloat(Number.parseFloat((AllMRPs[x].MRP.ERP7__Consumed_Quantity__c)) + Number.parseFloat((AllMRPs[x].quantityToConsume))).toFixed(4);
                            console.log('consumed Qty 5: ',AllMRPs[x].MRP.ERP7__Consumed_Quantity__c);
                            AllMRPs[x].MRP.ERP7__Scrapped_Quantity__c = Number.parseFloat(Number.parseFloat((AllMRPs[x].MRP.ERP7__Scrapped_Quantity__c)) + Number.parseFloat((AllMRPs[x].quantityToScrap))).toFixed(4);
                        }
                        var count = 0;
                        var currentWIPflow = cmp.get('v.SelectedWIPflow');

                        var allWIPflows = cmp.get('v.WIPFlows');

                        var iscompleted = false;
                        var qtyBuild = 0;
                        var qtyScrapped = 0;
                        for(var x in allWIPflows){
                            if(allWIPflows[x].wipFlow.Id == currentWIPflow.Id){ //&& (Number(allWIPflows[x].ERP7__Quantity__c) != Number(allWIPflows[x].ERP7__Quantity_Ordered__c))){ //&& (Number(currentWIPflow.ERP7__Quantity__c) !=  Number(allWIPflows[x].ERP7__Quantity__c))
                                if(currentWIPflow.ERP7__Product__r.ERP7__Serialise__c) {
                                    if(typewip == "Scrapped") currentWIPflow.ERP7__Quantity_Scrapped__c = 1;
                                    else currentWIPflow.ERP7__Quantity__c = 1;
                                }
                                else{
                                    if(typewip == "Scrapped") currentWIPflow.ERP7__Quantity_Scrapped__c = Number(currentWIPflow.ERP7__Quantity_Scrapped__c) + Number(cmp.get('v.WIPflowQty'));
                                    else currentWIPflow.ERP7__Quantity__c = Number(currentWIPflow.ERP7__Quantity__c) + Number(cmp.get('v.WIPflowQty'));
                                }
                                qtyBuild += currentWIPflow.ERP7__Quantity__c;
                                qtyScrapped = currentWIPflow.ERP7__Quantity_Scrapped__c;
                                if((currentWIPflow.ERP7__Quantity__c + currentWIPflow.ERP7__Quantity_Scrapped__c) == currentWIPflow.ERP7__Quantity_Ordered__c) currentWIPflow.ERP7__Status__c = 'Completed';
                            }
                            if(allWIPflows[x].wipFlow.Id == currentWIPflow.Id && ((Number(allWIPflows[x].wipFlow.ERP7__Quantity__c) + Number(allWIPflows[x].wipFlow.ERP7__Quantity_Scrapped__c)) > Number(allWIPflows[x].wipFlow.ERP7__Quantity_Ordered__c))){
                                cmp.set("v.exceptionError", $A.get('$Label.c.Built_quantity_cannot_be_greater_than_ordered_quantity'));
                                error = true;
                                break;
                            }
                            // if(allWIPflows[x].wipFlow.Id == currentWIPflow.Id && ((Number(allWIPflows[x].wipFlow.ERP7__Quantity__c) + Number(allWIPflows[x].wipFlow.ERP7__Quantity_Scrapped__c)) == Number(allWIPflows[x].wipFlow.ERP7__Quantity_Ordered__c))) currentWIPflow.ERP7__Status__c = 'Completed';
                            //if((allWIPflows[x].wipFlow.ERP7__Type__c == 'Produced' || allWIPflows[x].wipFlow.ERP7__Type__c == 'Processed') && ((Number(allWIPflows[x].wipFlow.ERP7__Quantity__c)) == Number(allWIPflows[x].wipFlow.ERP7__Quantity_Ordered__c))) count=count+1;// iscompleted = true; //allWIPflows[x].wipFlow.ERP7__Status__c == 'Completed' || removed from if condition as it was completing the partial MO
                            if(allWIPflows[x].wipFlow.ERP7__Quantity__c != null && allWIPflows[x].wipFlow.ERP7__Quantity__c > 0 && currentWIPflow.Id != allWIPflows[x].wipFlow.Id){

                                qtyBuild += allWIPflows[x].wipFlow.ERP7__Quantity__c;
                            }
                            else if(allWIPflows[x].wipFlow.ERP7__Quantity_Scrapped__c != null && allWIPflows[x].wipFlow.ERP7__Quantity_Scrapped__c > 0 && currentWIPflow.Id != allWIPflows[x].wipFlow.Id) qtyScrapped += allWIPflows[x].wipFlow.ERP7__Quantity_Scrapped__c;


                        }

                        // if(count == allWIPflows.length) iscompleted =true;
                        //  else iscompleted = false;
                        //  console.log('iscompleted : ',iscompleted);
                        console.log('qtyBuild : ',qtyBuild);
                        console.log('qtyScrapped : ',qtyScrapped);
                        if(qtyBuild > 0)  WO.ERP7__Quantity_Built__c =  (WO.ERP7__Quantity_Built__c > 0 && cmp.get("v.ManuOrder.ERP7__Serialise__c")) ? (Number(WO.ERP7__Quantity_Built__c) + Number(qtyBuild)) : Number(qtyBuild);
                        if(qtyScrapped > 0) WO.ERP7__Quantity_Scrapped__c =  (WO.ERP7__Quantity_Scrapped__c > 0 && cmp.get("v.ManuOrder.ERP7__Serialise__c")) ? (Number(WO.ERP7__Quantity_Scrapped__c) + Number(qtyScrapped)) : Number(qtyScrapped);
                        console.log('qtyBuild after: ',qtyBuild);
                        if(!cmp.get('v.byPassWOComplete') && (WO.ERP7__Quantity_Built__c  + WO.ERP7__Quantity_Scrapped__c) == WO.ERP7__Quantity_Ordered__c) WO.ERP7__Status__c = 'Complete';
                        /* if(qtyBuild == 0) {
                            if(currentWIPflow.ERP7__Type__c == 'Produced' || currentWIPflow.ERP7__Type__c == 'Processed') WO.ERP7__Quantity_Built__c = currentWIPflow.ERP7__Quantity__c;
                            if(currentWIPflow.ERP7__Type__c == 'Scrapped') WO.ERP7__Quantity_Scrapped__c = currentWIPflow.ERP7__Quantity__c;
                        }*/

                        if(!error){
                            console.log('inherer1 arshad');
                            cmp.set('v.SelectedWIPflow',currentWIPflow);
                            console.log('arshad JSON.stringify(currentWIPflow) : ',JSON.stringify(currentWIPflow));
                            console.log('arshad JSON.stringify(AllMRPs)~>',JSON.stringify(AllMRPs));
                            console.log('arshad JSON.stringify(WO)~>',JSON.stringify(WO));
                            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                            var action = cmp.get("c.completeWIPflowandCreateInventory");
                            action.setParams({
                                'Task1' : JSON.stringify(Task),
                                'WO1':JSON.stringify(WO),
                                'MRPSSS':JSON.stringify(AllMRPs),
                                'all_UOMs' : JSON.stringify(cmp.get("v.UOMCs")),
                                'currentflow' : JSON.stringify(currentWIPflow) //JSON.stringify(cmp.get('v.SelectedWIPflow'))
                            });
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    if(response.getReturnValue().errorMsg == ''){
                                        console.log('resp arshad completeWIPflowandCreateInventory :',response.getReturnValue());
                                        cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                                        cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                                        cmp.set("v.Tasks", response.getReturnValue().Tasks);
                                        cmp.set("v.WorkOrder",response.getReturnValue().WorkOrder);
                                        cmp.set("v.Busy", response.getReturnValue().Busy);
                                        cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                                        cmp.set("v.Permit", response.getReturnValue().Permit);
                                        cmp.set("v.MRPSS", response.getReturnValue().MRPSSBW);
                                        cmp.set('v.WIPflowQty',0);
                                        cmp.set("v.signatureExist", false);
                                        var selAttachs = cmp.get("v.SelectedAttachments");
                                        for(var x in selAttachs){
                                            if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                                cmp.set("v.signatureExist", true);
                                            }
                                        }
                                        var updatedWO = cmp.get("v.WorkOrder");
                                        console.log(' updatedWO :',JSON.stringify(updatedWO));
                                        if((Number(updatedWO.ERP7__Quantity_Built__c) +  Number(updatedWO.ERP7__Quantity_Scrapped__c)) == Number(updatedWO.ERP7__Quantity_Ordered__c)) {
                                            wipStatus = "Finish";
                                        }
                                        console.log('wipStatus : ',wipStatus);
                                        if(wipStatus == "Finish" && !cmp.get('v.byPassWOComplete')){
                                            cmp.set("v.WO2Fin",updatedWO);
                                            helper.finalFinishWO(cmp,event);
                                        }
                                        else cmp.popInit();
                                        cmp.set('v.WIPflowType', 'Produced'); // added to default back to the old list 17_07_24

                                        //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    }
                                    else {
                                        cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                                        WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c - ToProduce;
                                        console.log('else WO Qty : ',WO.ERP7__Quantity_Built__c);
                                        for(var x in AllMRPs){
                                            var qtytoconsume = 0; var qtytoscarp = 0;
                                            AllMRPs[x].MRP.ERP7__Consumed_Quantity__c = AllMRPs[x].MRP.ERP7__Consumed_Quantity__c - AllMRPs[x].quantityToConsume;
                                            console.log('consumed Qty 6: ',AllMRPs[x].MRP.ERP7__Consumed_Quantity__c);
                                            AllMRPs[x].MRP.ERP7__Scrapped_Quantity__c =  AllMRPs[x].MRP.ERP7__Scrapped_Quantity__c - AllMRPs[x].quantityToScrap;

                                        }
                                        cmp.set("v.MRPSS", AllMRPs);

                                        cmp.set("v.signatureExist", false);
                                        var selAttachs = cmp.get("v.SelectedAttachments");
                                        for(var x in selAttachs){
                                            if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                                cmp.set("v.signatureExist", true);
                                            }
                                        }
                                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    }
                                }

                            });
                            $A.enqueueAction(action);
                        }
                    }
                }

            }
            else{
                var wipflows = cmp.get('v.WIPFlows');
                if(wipflows.length == 0) {
                    console.log('if');
                    var finishAction = cmp.get("c.FinishWO1");
                    console.log('FinishWO1 calling');
                    $A.enqueueAction(finishAction);
                }
                else{
                    console.log('inhereheelse arshad1');
                    var serials = cmp.get('v.moSerialForProduction');
                    var serialsToProduce = [];
                    var totalQty = 0;
                    let today = new Date();
                    console.log(today);

                    let dd = today.getDate();
                    let mm = today.getMonth() + 1;

                    let yyyy = today.getFullYear();
                    if (dd < 10) {
                        dd = '0' + dd;
                    }
                    if (mm < 10) {
                        mm = '0' + mm;
                    }
                    today = yyyy+ '-' +mm + '-'  + dd;
                    var SelectedWipflows = cmp.get('v.SelectedWIPflow');
                    console.log('SelectedWipflows bfr serials set: ',JSON.stringify(SelectedWipflows));
                    var serialstoset = [];
                    for(var x in serials){
                        if(serials[x].selected) {
                            totalQty++;
                            if(cmp.get('v.TypeOfWIP') == 'Produced') {
                                serials[x].ERP7__Available__c = true;
                            }else if(cmp.get('v.TypeOfWIP') == 'Scrapped') serials[x].ERP7__Scrap__c = true;
                            serials[x].ERP7__Date_of_Manufacture__c =today;
                            serials[x].ERP7__Production_Version__c = SelectedWipflows.ERP7__Version__c;
                            serialsToProduce.push({'Id':serials[x].Id,'Name' : serials[x].Name,'ERP7__Available__c' : serials[x].ERP7__Available__c,'ERP7__Scrap__c' : serials[x].ERP7__Scrap__c,'ERP7__Date_of_Manufacture__c' : serials[x].ERP7__Date_of_Manufacture__c,'ERP7__Production_Version__c' : serials[x].ERP7__Production_Version__c,'ERP7__Manufacturing_Order__c':serials[x].ERP7__Manufacturing_Order__c});
                            //serialsToProduce.push(serials[x]);
                        }
                        else {
                            serials[x].selected = false;
                            serialstoset.push(serials[x]);
                        }
                    }
                    //  alert(serialsToProduce.length);
                    if(serialsToProduce.length > 0){
                        let mrps = cmp.get('v.MRPSS');
                        for(var x in mrps){
                            console.log('mrps[x] : ',JSON.stringify(mrps[x]));
                            console.log('consumed Qty 1: ',mrps[x].MRP.ERP7__Consumed_Quantity__c);
                            const sumofall = Number.parseFloat((Number(mrps[x].MRP.ERP7__Consumed_Quantity__c) + Number(mrps[x].MRP.ERP7__Scrapped_Quantity__c) + Number(mrps[x].quantityToConsume) + Number(mrps[x].quantityToScrap))).toFixed(4);
                            console.log('sumofall : ',sumofall);
                            let mrp1 = mrps[x].MRP;
                            if(mrp1.ERP7__Total_Amount_Required__c > 0 && mrp1.ERP7__Fulfilled_Amount__c == 0){
                                cmp.set('v.exceptionError',$A.get('$Label.c.Please_allocate_stock_to_consume'));
                                return;
                            } else if((parseFloat(mrps[x].quantityToConsume) + parseFloat(mrps[x].quantityToScrap)) > mrps[x].MRP.ERP7__Fulfilled_Amount__c){
                                cmp.set('v.exceptionError',$A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot_be_greater_than_fulfilled_quantity'));
                                return;
                            }

                                else   if(sumofall > Number(mrps[x].MRP.ERP7__Fulfilled_Amount__c)){
                                    cmp.set("v.exceptionError", $A.get('$Label.c.Sum_of_consumed_and_scrapped_quantity_cannot') +mrps[x].MRP.ERP7__MRP_Product__r.Name);
                                    return;
                                }
                                    /* commented  on 09_01_2023 to fix the issue of updating MRP with wrong qty when error encountered in the other MRPs
                                     * else{
                                        mrps[x].MRP.ERP7__Consumed_Quantity__c = Number.parseFloat(Number.parseFloat((mrps[x].MRP.ERP7__Consumed_Quantity__c)) + Number.parseFloat((mrps[x].quantityToConsume))).toFixed(4);
                                        mrps[x].MRP.ERP7__Scrapped_Quantity__c = Number.parseFloat(Number.parseFloat((mrps[x].MRP.ERP7__Scrapped_Quantity__c)) + Number.parseFloat((mrps[x].quantityToScrap))).toFixed(4);
                                        console.log('consumed Qty 2: ',mrps[x].MRP.ERP7__Consumed_Quantity__c);
                                    }*/
                        }

                        for(var x in mrps){
                            mrps[x].MRP.ERP7__Consumed_Quantity__c = Number.parseFloat(Number.parseFloat((mrps[x].MRP.ERP7__Consumed_Quantity__c)) + Number.parseFloat((mrps[x].quantityToConsume))).toFixed(4);
                            mrps[x].MRP.ERP7__Scrapped_Quantity__c = Number.parseFloat(Number.parseFloat((mrps[x].MRP.ERP7__Scrapped_Quantity__c)) + Number.parseFloat((mrps[x].quantityToScrap))).toFixed(4);
                            console.log('consumed Qty 2: ',mrps[x].MRP.ERP7__Consumed_Quantity__c);
                        }
                        /*  var wipflows = cmp.get('v.WIPFlows');
                var SelectedWipflows = [];
                var qtyBuild = 0;
                var qtyScrapped = 0;
                if(wipflows.length > 0) {
                    for(var x in wipflows){
                        console.log('wipflows[x].selected : ',wipflows[x].selected);
                        if(wipflows[x].selected){

                            console.log('selected');
                            //if(wipflows[x].wipFlow.ERP7__Product__c != cmp.get('v.WorkOrder.ERP7__Product__c') && cmp.get('v.TypeOfWIP') == 'Produced')   wipflows[x].wipFlow.ERP7__Type__c = 'Processed';
                            //else wipflows[x].wipFlow.ERP7__Type__c = cmp.get('v.TypeOfWIP');
                            if(wipflows[x].wipFlow.ERP7__Product__r.ERP7__Serialise__c){
                                if(cmp.get('v.TypeOfWIP') == "Scrapped") wipflows[x].wipFlow.ERP7__Quantity_Scrapped__c  = 1;
                                else wipflows[x].wipFlow.ERP7__Quantity__c = 1;
                            }
                            else {
                                if(cmp.get('v.TypeOfWIP') == "Scrapped") wipflows[x].wipFlow.ERP7__Quantity_Scrapped__c = cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c');
                                else wipflows[x].wipFlow.ERP7__Quantity__c = cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c');
                            }
                            wipflows[x].wipFlow.ERP7__Status__c = 'Completed';
                            SelectedWipflows.push(wipflows[x]);
                        }
                        if(wipflows[x].wipFlow.ERP7__Quantity__c != null && wipflows[x].wipFlow.ERP7__Quantity__c > 0) qtyBuild += wipflows[x].wipFlow.ERP7__Quantity__c;
                        else if(wipflows[x].wipFlow.ERP7__Quantity_Scrapped__c != null && wipflows[x].wipFlow.ERP7__Quantity_Scrapped__c > 0) qtyScrapped += wipflows[x].wipFlow.ERP7__Quantity_Scrapped__c;


                    }
                }*/
                        console.log('totalQty : ',totalQty);
                        console.log('SelectedWipflows bfr: ',JSON.stringify(SelectedWipflows));
                        if(cmp.get('v.TypeOfWIP') == 'Produced') {
                            WO.ERP7__Quantity_Built__c =  (WO.ERP7__Quantity_Built__c > 0 && cmp.get("v.ManuOrder.ERP7__Serialise__c")) ? (Number(WO.ERP7__Quantity_Built__c) + Number(totalQty)) : Number(totalQty);
                            SelectedWipflows.ERP7__Quantity__c = (SelectedWipflows.ERP7__Quantity__c > 0) ? (Number(SelectedWipflows.ERP7__Quantity__c) + Number(totalQty)) : Number(totalQty);
                        }
                        else if(cmp.get('v.TypeOfWIP') == 'Scrapped') {
                            WO.ERP7__Quantity_Scrapped__c =  (WO.ERP7__Quantity_Scrapped__c > 0 && cmp.get("v.ManuOrder.ERP7__Serialise__c")) ? (Number(WO.ERP7__Quantity_Scrapped__c) + Number(totalQty)) : Number(totalQty);
                            SelectedWipflows.ERP7__Quantity_Scrapped__c = (SelectedWipflows.ERP7__Quantity_Scrapped__c > 0) ? (Number(SelectedWipflows.ERP7__Quantity_Scrapped__c) + Number(totalQty)) : Number(totalQty);
                        }

                        var selectedWIP = [];
                        selectedWIP.push(SelectedWipflows);
                        console.log('selectedWIP : ',JSON.stringify(selectedWIP));
                        console.log('arshad1 JSON.stringify(mrps)~>',JSON.stringify(mrps));
                        console.log('arshad1 JSON.stringify(WO)~>',JSON.stringify(WO));
                        console.log(' JSON.stringify(SelectSerials)~>',JSON.stringify(serialsToProduce));

                        var action = cmp.get("c.completetheWOandWIP");
                        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                        action.setParams({
                            'Task1' : JSON.stringify(Task),
                            'WO1':JSON.stringify(WO),
                            'MRPSSS':JSON.stringify(mrps),
                            'all_UOMs' : JSON.stringify(cmp.get("v.UOMCs")),
                            'WIPflows' : JSON.stringify(selectedWIP),
                            'type' : cmp.get('v.TypeOfWIP'),
                            'SelectSerials' : JSON.stringify(serialsToProduce)
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                console.log('completetheWOandWIP response : ',response.getReturnValue());
                                if(response.getReturnValue().errorMsg == ''){
                                    console.log('res completetheWOandWIP :',response.getReturnValue());
                                    cmp.set("v.SelectedTask",response.getReturnValue().SelectedTask);
                                    cmp.set("v.TimeCardEntries", response.getReturnValue().TimeCardEntries);
                                    cmp.set("v.Tasks", response.getReturnValue().Tasks);
                                    cmp.set("v.WorkOrder",response.getReturnValue().WorkOrder);
                                    cmp.set("v.Busy", response.getReturnValue().Busy);
                                    cmp.set("v.SelectedTask_TimeCardEntry", response.getReturnValue().SelectedTask_TimeCardEntry);
                                    cmp.set("v.Permit", response.getReturnValue().Permit);
                                    cmp.set("v.MRPSS", response.getReturnValue().MRPSSBW);
                                    cmp.set('v.WIPflowQty',0);
                                    cmp.set("v.signatureExist", false);
                                    var selAttachs = cmp.get("v.SelectedAttachments");
                                    for(var x in selAttachs){
                                        if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                            cmp.set("v.signatureExist", true);
                                        }
                                    }
                                    var updatedWO = cmp.get("v.WorkOrder");
                                    console.log(' updatedWO :',JSON.stringify(updatedWO));
                                    if((Number(updatedWO.ERP7__Quantity_Built__c) +  Number(updatedWO.ERP7__Quantity_Scrapped__c)) == Number(updatedWO.ERP7__Quantity_Ordered__c)) {
                                        wipStatus = "Finish";
                                    }
                                    console.log('wipStatus : ',wipStatus);
                                    if(wipStatus == "Finish"){
                                        cmp.set("v.WO2Fin",updatedWO);
                                        helper.finalFinishWO(cmp,event);
                                    }

                                    let mrps = cmp.get('v.MRPSS');
                                    for(var x in mrps){
                                        mrps[x].quantityToConsume = 0;
                                        mrps[x].quantityToScrap = 0;
                                    }
                                    cmp.set('v.MRPSS',mrps);
                                    cmp.set('v.TotalWIPQtyProduced',0);
                                    cmp.set('v.TotalWIPQtyScrapped',0);
                                    // cmp.BuildFinish();
                                    cmp.popInit();
                                    cmp.set('v.TypeOfWIP', 'Produced'); // added to default back to the old list 08_01_24
                                    cmp.set('v.moSerialForProduction',serialstoset);

                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                }
                                else {
                                    cmp.set("v.exceptionError", response.getReturnValue().errorMsg);
                                    if(cmp.get('v.TypeOfWIP') == 'Produced') {
                                        WO.ERP7__Quantity_Built__c =  (WO.ERP7__Quantity_Built__c > 0 && cmp.get("v.ManuOrder.ERP7__Serialise__c")) ? (Number(WO.ERP7__Quantity_Built__c) - Number(totalQty)) : 0;
                                       // SelectedWipflows.ERP7__Quantity__c = (SelectedWipflows.ERP7__Quantity__c > 0) ? (Number(SelectedWipflows.ERP7__Quantity__c) + Number(totalQty)) : Number(totalQty);
                                    }
                                    else if(cmp.get('v.TypeOfWIP') == 'Scrapped') {
                                        WO.ERP7__Quantity_Scrapped__c =  (WO.ERP7__Quantity_Scrapped__c > 0 && cmp.get("v.ManuOrder.ERP7__Serialise__c")) ? (Number(WO.ERP7__Quantity_Scrapped__c) - Number(totalQty)) :0;
                                      //  SelectedWipflows.ERP7__Quantity_Scrapped__c = (SelectedWipflows.ERP7__Quantity_Scrapped__c > 0) ? (Number(SelectedWipflows.ERP7__Quantity_Scrapped__c) + Number(totalQty)) : Number(totalQty);
                                    }
                                    //WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Built__c - ToProduce;
                                    console.log('else WO Qty 2 : ',WO.ERP7__Quantity_Built__c);
                                    console.log('else WO scrap Qty 2 : ',WO.ERP7__Quantity_Scrapped__c);
                                    for(var x in AllMRPs){
                                        var qtytoconsume = 0; var qtytoscarp = 0;
                                        AllMRPs[x].MRP.ERP7__Consumed_Quantity__c = AllMRPs[x].MRP.ERP7__Consumed_Quantity__c - AllMRPs[x].quantityToConsume;
                                        AllMRPs[x].MRP.ERP7__Scrapped_Quantity__c =  AllMRPs[x].MRP.ERP7__Scrapped_Quantity__c - AllMRPs[x].quantityToScrap;
                                        console.log('consumed Qty 3: ',AllMRPs[x].MRP.ERP7__Consumed_Quantity__c);

                                    }
                                    cmp.set("v.MRPSS", AllMRPs);

                                    cmp.set("v.signatureExist", false);
                                    var selAttachs = cmp.get("v.SelectedAttachments");
                                    for(var x in selAttachs){
                                        if(selAttachs[x].ParentId == response.getReturnValue().SelectedTask.Id && selAttachs[x].Name == 'Signature') {
                                            cmp.set("v.signatureExist", true);
                                        }
                                    }
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                }
                            }
                            else{
                                var error = response.getError();
                                console.log('error : ',error);
                                if(error != undefined && error.length > 0) {
                                    cmp.set("v.exceptionError", error[0].message);

                                }
                                console.log('SelectedWipflows err bfr set : ',JSON.stringify(SelectedWipflows));
                                if(cmp.get('v.TypeOfWIP') == 'Produced') {
                                    WO.ERP7__Quantity_Built__c =  (WO.ERP7__Quantity_Built__c > 0 && cmp.get("v.ManuOrder.ERP7__Serialise__c")) ? (Number(WO.ERP7__Quantity_Built__c) - Number(totalQty)) : Number(totalQty);
                                    SelectedWipflows.ERP7__Quantity__c = (SelectedWipflows.ERP7__Quantity__c > 0) ? (Number(SelectedWipflows.ERP7__Quantity__c) - Number(totalQty)) : Number(totalQty);
                                }
                                else if(cmp.get('v.TypeOfWIP') == 'Scrapped') {
                                    WO.ERP7__Quantity_Scrapped__c =  (WO.ERP7__Quantity_Scrapped__c > 0 && cmp.get("v.ManuOrder.ERP7__Serialise__c")) ? (Number(WO.ERP7__Quantity_Scrapped__c) - Number(totalQty)) : Number(totalQty);
                                    SelectedWipflows.ERP7__Quantity_Scrapped__c = (SelectedWipflows.ERP7__Quantity_Scrapped__c > 0) ? (Number(SelectedWipflows.ERP7__Quantity_Scrapped__c) - Number(totalQty)) : Number(totalQty);
                                }
                                cmp.set("v.SelectedWIPflow", SelectedWipflows);
                                console.log('SelectedWipflows err after set : ',JSON.stringify(SelectedWipflows));
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            }
                        });
                        $A.enqueueAction(action);
                    }
                    else{
                        cmp.set('v.exceptionError',$A.get('$Label.c.Please_Select_Serials_To_Produce'));
                    }
                }


            }
        },

        closeFinishModal : function(cmp, event) {
            //$A.util.removeClass(cmp.find("finishModal"),"slds-fade-in-open");
            //$A.util.removeClass(cmp.find("newTaskModalBackdrop"),"slds-backdrop_open");
            cmp.set("v.fPage",false);
        },

        GetResources: function(cmp, event) {
            var obj = cmp.get("v.WorkPlanners");
            var Name = cmp.get("v.ResourceStr");
            var ST = cmp.get("v.StartTime");
            var ET = cmp.get("v.EndTime");
            var objsels = JSON.stringify(obj);
            var WPId = cmp.get("v.SelectedWP");
            var RRId = cmp.get("v.selectedRR");
            console.log('ST: '+ST+' ET: '+ET);
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
                    console.log('response.getReturnValue(): ',response.getReturnValue());
                    //cmp.popInit();
                    if(response.getReturnValue().errorMsg != '') cmp.set("v.ResourcePopupErrorMsg",response.getReturnValue().errorMsg);
                    else {
                        cmp.set("v.AvailableResources",response.getReturnValue().AvailableResources);
                    }
                } else { cmp.set("v.ResourcePopupErrorMsg",response.getReturnValue().errorMsg); }
            });
            $A.enqueueAction(action);

        },

        upsertResources: function(cmp, event) {
            var obj = cmp.get("v.AvailableResources");
            var objsels = JSON.stringify(obj);
            var ST = cmp.get("v.StartTime");
            var ET =cmp.get("v.EndTime");
            var WOO = cmp.get("v.WorkOrder");

            var action = cmp.get("c.SaveResources");
            action.setParams({
                Resources: objsels,
                WO1: JSON.stringify(WOO),
                StartTime: ST,
                EndTime: ET
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //cmp.popInit();
                    if(response.getReturnValue().errorMsg != '') cmp.set("v.ResourcePopupErrorMsg",response.getReturnValue().errorMsg);
                    else {
                        cmp.set("v.raPage",false);
                        //$A.util.removeClass(cmp.find("myResourceAllocationModal"),"slds-fade-in-open");
                        //$A.util.removeClass(cmp.find("myResourceAllocationModalBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                    }
                } else { cmp.set("v.ResourcePopupErrorMsg",response.getReturnValue().errorMsg); }
            });
            $A.enqueueAction(action);
        },

        closeResourceAllocationModal : function (cmp, event) {
            cmp.set("v.raPage",false);
            //$A.util.removeClass(cmp.find("myResourceAllocationModal"),"slds-fade-in-open");
            //$A.util.removeClass(cmp.find("myResourceAllocationModalBackdrop"),"slds-backdrop_open");
        },

        SelectWP: function(cmp, event) {
            var count = String(event.currentTarget.getAttribute('data-rr'));
            var name = String(event.currentTarget.getAttribute('data-rrname'));
            cmp.set("v.selectedRR",count);
            cmp.set("v.selectedRRName",name);
        },

        /* goBack : function(component,event,helper){
            window.history.back();
        },
        */
        showSignature: function(cmp, event) {
            document.getElementById("sigbody").style.visibility = "visible";
            cmp.set("v.IsSignatureTab",true);
        },

        tab1 : function(cmp, event, helper) {
            cmp.set("v.worksheetTab",true);
            cmp.set("v.drawingTab",false);
            cmp.set("v.timeTrackingTab",false);
            cmp.set("v.MRPSTab",false);
            cmp.set("v.resourceTab",false);

            cmp.set("v.currentProductionTab",false);
            cmp.set("v.serialorBatchesTab",false);
            cmp.set("v.signatureTab",false);
        },

        tab2 : function(cmp, event, helper) {
            cmp.set("v.worksheetTab",false);
            cmp.set("v.drawingTab",true);
            cmp.set("v.timeTrackingTab",false);
            cmp.set("v.MRPSTab",false);
            cmp.set("v.resourceTab",false);

            cmp.set("v.currentProductionTab",false);
            cmp.set("v.serialorBatchesTab",false);
            cmp.set("v.signatureTab",false);
        },

        tab3 : function(cmp, event, helper) {
            cmp.set("v.worksheetTab",false);
            cmp.set("v.drawingTab",false);
            cmp.set("v.timeTrackingTab",true);
            cmp.set("v.MRPSTab",false);
            cmp.set("v.resourceTab",false);

            cmp.set("v.currentProductionTab",false);
            cmp.set("v.serialorBatchesTab",false);
            cmp.set("v.signatureTab",false);
        },

        tab4 : function(cmp, event, helper) {
            cmp.set("v.worksheetTab",false);
            cmp.set("v.drawingTab",false);
            cmp.set("v.timeTrackingTab",false);
            cmp.set("v.MRPSTab",true);
            cmp.set("v.resourceTab",false);

            cmp.set("v.currentProductionTab",false);
            cmp.set("v.serialorBatchesTab",false);
            cmp.set("v.signatureTab",false);
        },

        tab5 : function(cmp, event, helper) {
            cmp.set("v.worksheetTab",false);
            cmp.set("v.drawingTab",false);
            cmp.set("v.timeTrackingTab",false);
            cmp.set("v.MRPSTab",false);
            cmp.set("v.resourceTab",true);

            cmp.set("v.currentProductionTab",false);
            cmp.set("v.serialorBatchesTab",false);
            cmp.set("v.signatureTab",false);
        },

        tab6 : function(cmp, event, helper) {
            cmp.set("v.worksheetTab",false);
            cmp.set("v.drawingTab",false);
            cmp.set("v.timeTrackingTab",false);
            cmp.set("v.MRPSTab",false);
            cmp.set("v.resourceTab",false);

            cmp.set("v.currentProductionTab",true);
            cmp.set("v.serialorBatchesTab",false);
            cmp.set("v.signatureTab",false);
        },

        tab7 : function(cmp, event, helper) {
            cmp.set("v.worksheetTab",false);
            cmp.set("v.drawingTab",false);
            cmp.set("v.timeTrackingTab",false);
            cmp.set("v.MRPSTab",false);
            cmp.set("v.resourceTab",false);

            cmp.set("v.currentProductionTab",false);
            cmp.set("v.serialorBatchesTab",true);
            cmp.set("v.signatureTab",false);
        },

        tab8 : function(cmp, event, helper) {
            cmp.set("v.worksheetTab",false);
            cmp.set("v.drawingTab",false);
            cmp.set("v.timeTrackingTab",false);
            cmp.set("v.MRPSTab",false);
            cmp.set("v.resourceTab",false);

            cmp.set("v.currentProductionTab",false);
            cmp.set("v.serialorBatchesTab",false);
            cmp.set("v.signatureTab",true);
        },

        displayWIPFlowsNext : function(component, event, helper) {
            var obj = component.get("v.AllWIPFlows");
            var start = component.get('v.WipflowsShowStart');
            var end = component.get('v.WipflowsShow');
            var startNew = parseInt(start) + 100;
            var endNew = parseInt(end) + 100;
            component.set('v.WipflowsShowStart', startNew);
            component.set('v.WipflowsShow', endNew);
            /*  var action = component.get('c.getWIPFlows');
            action.setParams({'offsetVal' : parseInt(start + 100),'Mo' : component.get('v.ManuOrder.Id')});
            action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var startNew = parseInt(start) + 100;
                        var endNew = parseInt(end) + 100;
                        component.set('v.WipflowsShowStart', startNew);
                        component.set('v.WipflowsShow', endNew);
                        component.set('v.AllWIPFlows', response.getReturnValue());
                    }
            });
            $A.enqueueAction(action);*/


        },

        displayWIPFlowsPrevious : function(component, event, helper) {
            var obj = component.get("v.AllWIPFlows");
            var start = component.get('v.WipflowsShowStart');
            var end = component.get('v.WipflowsShow');
            var startNew = parseInt(start) - 100;
            var endNew = parseInt(end) - 100;
            component.set('v.WipflowsShowStart', startNew);
            component.set('v.WipflowsShow', endNew);
            /*var action = component.get('c.getWIPFlows');
            action.setParams({'offsetVal' : parseInt(start - 100),'Mo' : component.get('v.ManuOrder.Id')});
            action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var startNew = parseInt(start) - 100;
                        var endNew = parseInt(end) - 100;
                        component.set('v.WipflowsShowStart', startNew);
                        component.set('v.WipflowsShow', endNew);
                        component.set('v.AllWIPFlows', response.getReturnValue());
                    }
            });
            $A.enqueueAction(action); */

        },

        displaySerialsNext : function(component, event, helper) {
            var obj = component.get("v.AllmoSerialNos");
            var start = component.get('v.moSerialNosShowStart');
            var end = component.get('v.moSerialNosShow');
            var action = component.get('c.getSerialNumbers');
            action.setParams({'offsetVal' : parseInt(start + 100),'Mo' : component.get('v.ManuOrder.Id')});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var startNew = parseInt(start) + 100;
                    var endNew = parseInt(end) + 100;
                    component.set('v.moSerialNosShowStart', startNew);
                    component.set('v.moSerialNosShow', endNew);
                    component.set('v.AllmoSerialNos', response.getReturnValue());
                }
            });
            $A.enqueueAction(action);

        },

        displaySerialsPrevious : function(component, event, helper) {
            var obj = component.get("v.AllmoSerialNos");
            var start = component.get('v.moSerialNosShowStart');
            var end = component.get('v.moSerialNosShow');
            var action = component.get('c.getSerialNumbers');
            action.setParams({'offsetVal' : parseInt(start - 100),'Mo' : component.get('v.ManuOrder.Id')});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var startNew = parseInt(start) - 100;
                    var endNew = parseInt(end) - 100;
                    component.set('v.moSerialNosShowStart', startNew);
                    component.set('v.moSerialNosShow', endNew);
                    component.set('v.AllmoSerialNos', response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        },

        closeError : function(cmp, event){
            cmp.set("v.exceptionError", "");
        },

        closeWarning : function(cmp, event){
            cmp.set("v.warningError", "");
        },

        getSOLISerialStock : function(cmp, event){
            if(!$A.util.isEmpty(cmp.get("v.NewSOLI.ERP7__Serial__c")) && !$A.util.isUndefinedOrNull(cmp.get("v.NewSOLI.ERP7__Serial__c"))){
                //alert("getSOLISerialStock");
                var sId = cmp.get("v.NewSOLI.ERP7__Serial__c");
                var action = cmp.get("c.getSerialStock");
                action.setParams({
                    serialId : sId
                });
                action.setCallback(this, function(response){
                    //alert(response.getState());
                    if(response.getState() === "SUCCESS"){
                        //alert(response.getReturnValue());
                        cmp.set("v.SOLI_SerialStock", response.getReturnValue());
                    }
                    else{
                        var errors = response.getError();
                        cmp.set("v.exceptionError", errors[0].message);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                });
                $A.enqueueAction(action);
            }
            else cmp.set("v.SOLI_SerialStock", 0);
        },

        getSOLIBatchStock : function(cmp, event){
            if(!$A.util.isEmpty(cmp.get("v.NewSOLI.ERP7__Material_Batch_Lot__c")) && !$A.util.isUndefinedOrNull(cmp.get("v.NewSOLI.ERP7__Material_Batch_Lot__c"))){
                var bId = cmp.get("v.NewSOLI.ERP7__Material_Batch_Lot__c");
                var action = cmp.get("c.getBatchStock");
                action.setParams({
                    batchId : bId
                });
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        cmp.set("v.SOLI_BatchStock", response.getReturnValue());
                    }
                    else{
                        var errors = response.getError();
                        cmp.set("v.exceptionError", errors[0].message);
                        //setTimeout($A.getCallback(function() {cmp.set("v.exceptionError","");}), 5000);
                    }
                });
                $A.enqueueAction(action);
            }
            else cmp.set("v.SOLI_BatchStock", 0);
        },

        onControllerFieldChange: function(component, event, helper) {
            var controllerValueKey = component.get("v.ControllingValue"); // get selected controller field value
            var depnedentFieldMap = component.get("v.depnedentFieldMap");

            if (controllerValueKey != '--- None ---') {

                var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
                if(ListOfDependentFields.length > 0){
                    component.set("v.bDisabledDependentFld" , false);
                    helper.fetchDepValues(component, ListOfDependentFields);
                }else{
                    component.set("v.bDisabledDependentFld" , true);
                    component.set("v.listDependingValues", ['--- None ---']);
                }


            } else {
                component.set("v.listDependingValues", ['--- None ---']);
                component.set("v.bDisabledDependentFld" , true);
            }
        },
        SaveTaskValues : function(cmp,event,helper){

            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var wid = cmp.get('v.WorkOrder.Id');
            var taks = cmp.get('v.tasklists');
            for(var x in taks){
                taks[x].isSelected = true;
            }
            console.log('tasklists : ',taks);
            var checllists = cmp.get('v.Checklist');
            var gchecklist = cmp.get('v.guidelinechecklist');
            var action = cmp.get("c.Savechecklists");
            action.setParams({check : JSON.stringify(checllists),WorkId : wid,guideline : JSON.stringify(gchecklist),tsks : JSON.stringify(taks) });
            action.setCallback(this, function(response) {
                var state = response.getState();
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                if(state === 'SUCCESS'){
                    cmp.set('v.guidelinechecklist',response.getReturnValue().guidelines);
                    cmp.set('v.guidelinexits',response.getReturnValue().recordCreated);
                    cmp.set('v.Checklist',response.getReturnValue().checklist);
                    cmp.set('v.tasklists',response.getReturnValue().tasklist);
                    cmp.set('v.Tasks',response.getReturnValue().Tasks);
                    cmp.set("v.SelectedTask",response.getReturnValue().Tasks[0]);
                    cmp.popInit();
                }
                else{
                    cmp.set('v.errorMsg',response.getReturnValue().errorMsg);
                }

            });
            $A.enqueueAction(action);


        },
        checkreq : function(cmp, event, helper) {
            try{
                var checkval = event.getSource().get('v.checked');
                var Task = cmp.get('v.SelectedTask');
                var checks = cmp.get('v.Checklist');
                var guidelines = cmp.get('v.guidelinechecklist');

                var guidelinelength = 0;
                var checklistlength = 0;
                if(guidelines != undefined && guidelines != null && guidelines != '') guidelinelength = guidelines.length;
                if(checks != undefined && checks != null && checks != '') checklistlength = checks.length;

                if(checkval && checklistlength > 0 && guidelinelength == 0){
                    for(var i in checks){
                        if(checks[i].ERP7__Operation__c != null && checks[i].ERP7__Operation__c != '' && checks[i].ERP7__Operation__c == Task.ERP7__Operation__c && checks[i].ERP7__Is_Mandatory__c){
                            if(checks[i].ERP7__Has_Checklist__c && (checks[i].ERP7__Result__c == null || checks[i].ERP7__Result__c == '' && checks[i].ERP7__Result__c == '--None--')){
                                cmp.set('v.exceptionError',$A.get('$Label.c.Please_complete_the_required_checklists'));
                            }
                            else if(!checks[i].ERP7__Has_Checklist__c && (checks[i].ERP7__Action_Detail__c == '' || checks[i].ERP7__Action_Detail__c == null || checks[i].ERP7__Action_Detail__c == undefined)){
                                cmp.set('v.exceptionError',$A.get('$Label.c.Please_complete_the_required_checklists'));
                            }
                        }
                        else{ break;}
                    }

                }
            }catch(error){console.log('Error : '+error)}

        },
        selectAll : function(cmp, event, helper) {
            /* var Task = cmp.get("v.SelectedTask");
            var err =false;
            if(Task.ERP7__Operation__r.ERP7__Required__c == true && cmp.get('v.guidelinechecklist').length == 0  && cmp.get('v.Checklist').length > 0){
                err = true;
                cmp.set('v.exceptionError','Please complete the checklists');
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
            if(!err){*/
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var tasks = cmp.get("v.tasklists");
            var val = event.getSource().get("v.checked");
            //cmp.find("checkingAll")
            cmp.set("v.checkAll",val);

            for(var x in tasks){
                //if(tasks[x].LOLI.ERP7__Quantity_Received__c > LOLI[x].LOLI.ERP7__Putaway_Quantity__c)
                tasks[x].isSelected = val;
            }
            cmp.set("v.tasklists",tasks);
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            // }
            //cmp.set("v.checkAll",false);
        },
        menuAction :  function (cmp,event,helper) {
            var selectedMenuid = event.detail.menuItem.get("v.value");
            //var selectedMenu = event.detail.menuItem.get("v.label");//commented these and added the next 3 lines to facilitate translation on 19/02 Asra
            var selectedMenu='';
            if(event.detail.menuItem.get("v.label")== $A.get('$Label.c.Create_Manufacturing_Order'))selectedMenu = "Create Manufacturing Order";
            else selectedMenu = event.detail.menuItem.get("v.label");
            console.log('selectedMenu : ',selectedMenu);
            switch(selectedMenu) {
                case "Create Manufacturing Order":
                    var URL_RMA = '/apex/ERP7__ManufacturingOrderLC?mrpId='+selectedMenuid;
                    window.open(URL_RMA,'_self');
                    break;
            }
        },
        completeCurrentTask : function (cmp,event,helper) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var val = cmp.find("actionBox").get("v.checked");
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        },
        commitWIPflow : function (cmp,event,helper) {
            var checkval = event.getSource().get('v.checked');
            cmp.set('v.commitWIPFlow',checkval);
            /* if(cmp.get('v.commitWIPFlow')){
                var count = event.getSource().get('v.name');
                var allWIPflows = cmp.get('v.WIPFlows');
                for(var x in allWIPflows){
                    if(x == count){
                       allWIPflows[x].ERP7__Status__c = 'Completed';
                    }
                }
                cmp.set('v.WIPFlows',allWIPflows);
            }*/
        },
        finalFinish : function (cmp,event,helper) {
           // var confirmval = confirm($A.get('$Label.c.Do_you_want_to_complete_the_Work_Order'));
            //console.log('confirmval : ',confirmval);
            //if(confirmval)
          //  {
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");

                var WId = event.getSource().get('v.name');
                var WO = cmp.get('v.WorkOrder');
                WO.ERP7__Status__c = 'Complete';
                if(WO.ERP7__Quantity_Built__c == 0 && WO.ERP7__Quantity_Scrapped__c == 0) WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Ordered__c;
                // WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Ordered__c; commented by shaguftha on 2/11/23 to avoid the override of actual built qty and added above line with if condition
                var allWIp = cmp.get('v.WIPFlows');
                for(var i in allWIp){
                    allWIp[i].wipFlow.ERP7__Status__c = 'Completed';
                }
                console.log('WO bfr : ',JSON.stringify(WO));
                var action = cmp.get('c.CompleteWipandWO');
                action.setParams({ 'WorkOrder' : JSON.stringify(WO), 'WIPs' : JSON.stringify(allWIp)});
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS" && response.getReturnValue() == "SUCCESS") {
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set('v.WorkOrder',WO);
                        cmp.set('v.WIPFlows',allWIp);
                        cmp.set('v.WO2Fin',WO);
                        helper.finalFinishWO(cmp,event,helper);
                    }
                    else{
                        console.log('error on final finish : '+JSON.stringify(response.getError()));
                    }
                });
                $A.enqueueAction(action);
           // }
        },

        goBack : function(cmp, event){
            console.log('arshad goback called');
            var nav = cmp.get("v.NAV");
            var isFromMO = cmp.get("v.isFromMO");

            console.log('nav~>'+nav);
            console.log('isFromMO~>'+isFromMO);

            if(isFromMO){
                var moId = cmp.get("v.ManuOrder").Id
                if(!$A.util.isUndefinedOrNull(moId)){
                    $A.createComponent("c:Manufacturing_Orders",{
                        "MO": moId,
                        "NAV":'mp',
                        "RD":'yes',
                        "allowNav" : true
                    },function(newCmp, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = cmp.find("body");
                            body.set("v.body", newCmp);
                        }
                    });
                }
            }else{
                if(nav == 'mosoliId'){
                    var loc = window.location.href;
                    var loc1 = loc.split('/apex')[0];
                    loc1 += "/lightning/n/ERP7__Work_Center_Capacity_Planning";
                    //var URL_RMA = loc1.append("lightning/n/ERP7__Work_Center_Capacity_Planning");
                    window.open(loc1,'_self');
                }else if(nav == 'mo'){
                    loc = "/lightning/n/ERP7__Work_Center_Capacity_Planning";
                    window.open(loc,'_self');
                }else{
                    window.history.back();
                }
            }
        },

        Nav2MO : function(cmp, event,helper){
            var moId = cmp.get("v.ManuOrder").Id
            if(!$A.util.isUndefinedOrNull(moId)){
                $A.createComponent("c:Manufacturing_Orders",{
                    "MO": moId,
                    "NAV":'mp',
                    "RD":'yes',
                    "allowNav" : true
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = cmp.find("body");
                        body.set("v.body", newCmp);
                    }
                });
            }

            /* var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Manufacturing_Orders",
                componentAttributes: {
                    "MO": moId,
                    "NAV":'mp',
                    "RD":'yes',
                    "allowNav" : true
                }
            });
            evt.fire();*/
        },

        handleWipStatusChange : function(cmp, event,helper){
            //alert('handleWipStatusChange');
            var selectedValue = event.getSource().get("v.value"); //cmp.find("WIPFlowType").get("v.value");
            console.log('selectedValue : ',selectedValue);
            var nameValue = event.getSource().get("v.name");
            console.log('nameValue : ',nameValue);

            if(nameValue != null && nameValue != '' && nameValue != undefined){
                //added by shaguftha on 25/07/2023 to get the user entered value
                let wipQty = cmp.get('v.WIPflowQty');
                console.log('wipQty : ',wipQty);
                if(selectedValue == 'Scrapped'){
                    /* var allWip = cmp.get('v.WIPFlows');
                    for(var x in allWip){
                        if(allWip[x].Id == nameValue){
                            allWip[x].ERP7__Type__c = 'Scrapped';
                        }
                    }*/
                    if(cmp.get('v.ManuOrder.ERP7__Product__r.ERP7__Serialise__c')) {
                        cmp.set("v.ToScrap",1);
                        cmp.set("v.ToProduce",0);
                    }
                    else {
                        if(wipQty != null && wipQty != undefined && wipQty > 0) cmp.set("v.ToScrap",wipQty); //added by shaguftha on 25/07/2023 to set the user entered value
                        else cmp.set("v.ToScrap",cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));
                        cmp.set("v.ToProduce",0);
                    }
                }
                else{
                    if(cmp.get('v.ManuOrder.ERP7__Product__r.ERP7__Serialise__c')) {
                        cmp.set("v.ToProduce",1);
                        cmp.set("v.ToScrap",0);
                    }
                    else {
                        if(wipQty != null && wipQty != undefined && wipQty > 0) cmp.set("v.ToProduce",wipQty); //added by shaguftha on 25/07/2023 to set the user entered value
                        else cmp.set("v.ToProduce",cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));
                        cmp.set("v.ToScrap",0);
                    }
                }
            }


        },
        generateSerialNumbers :  function(cmp, event,helper){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var fromval = cmp.get('v.FromSerialNum');
            console.log('fromval : ',fromval);
            var prefix = cmp.get('v.SerialPrefix');
            console.log('prefix : ',prefix);

                const startNum = parseInt(cmp.get('v.startNum')) - 1;
                 const updatedSerials = [];
                if (fromval && prefix) {
                    cmp.set('v.RefreshSerials',false);
                    const allSerials = cmp.get('v.AllmoSerialNos');

                    var numericValue = parseInt(fromval);
                    for (let i = startNum; i < cmp.get('v.endNum'); i++) {
                        const serial = allSerials[i];
                        const formattedSerial = prefix + numericValue.toString().padStart(fromval.toString().length, '0');
                        console.log('formattedSerial : ',formattedSerial);
                        // Assuming 'Name' field is used for serial numbers
                        serial.Name =  formattedSerial;
                        serial.ERP7__Serial_No__c = formattedSerial;
                        serial.ERP7__Barcode__c = formattedSerial;
                        updatedSerials.push(serial);
                        allSerials[i] = serial;
                        numericValue = numericValue+1;
                    }
                }
                    console.log('updatedSerials:', updatedSerials);
            if(fromval != null && fromval != 0 && fromval != undefined && prefix != null && prefix != undefined && prefix != ''){
                var action = cmp.get("c.setSerials");
                 action.setParams({MOId : cmp.get('v.ManuOrder.Id'),serialsList : JSON.stringify(updatedSerials)});
                //action.setParams({ startNum : fromval,MOId : cmp.get('v.ManuOrder.Id'), woId : cmp.get("v.WO"),serPrefix :prefix });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        if(response.getReturnValue() != null){
                            console.log('response.getReturnValue() : ',response.getReturnValue());
                            let result = response.getReturnValue();
                            if(result.includes('Duplicate') || result.includes('Error') || result.includes('duplicate') || result.includes('Failed')){
                                cmp.set('v.exceptionError',result);
                            }
                            else {
                                cmp.set('v.WIPFlows',JSON.parse(result));
                                helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.Serial_number_generated_Successfully'));
                            }
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                    }
                    else{
                        console.log('error : ',response.getError());
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }

                });
                $A.enqueueAction(action);
            }
            else{
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                if(fromval == null || fromval == 0 || fromval == undefined) cmp.set('v.exceptionError',$A.get('$Label.c.Please_enter_from_value_to_generate_serial_Numbers'));
                else cmp.set('v.exceptionError',$A.get('$Label.c.Please_enter_Prefix_to_generate_serial_Numbers'));
            }
        },
        cancelAction : function (cmp,event) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/lightning/n/ERP7__Work_Center_Capacity_Planning"
            });
            urlEvent.fire();
        },

        //select all
        selectAllWIps : function (cmp,event) {
            var checkedval = event.getSource().get('v.checked');
            let wipflows = cmp.get('v.WIPFlows');
            var totalQty = 0;
            var lmt = cmp.get('v.WipflowsShowforBuild');

            for(var x in wipflows){
                if(lmt > 0 && (wipflows[x].wipFlow.ERP7__Quantity__c + wipflows[x].wipFlow.ERP7__Quantity_Scrapped__c) != wipflows[x].wipFlow.ERP7__Quantity_Ordered__c){
                    wipflows[x].selected = checkedval;
                    lmt--;
                }
                if(wipflows[x].selected && (wipflows[x].wipFlow.ERP7__Quantity__c + wipflows[x].wipFlow.ERP7__Quantity_Scrapped__c) != wipflows[x].wipFlow.ERP7__Quantity_Ordered__c) totalQty++;
            }
            cmp.set('v.WIPFlows',wipflows);
            if(checkedval){
                cmp.set('v.showWIPsection',false);
                let mrps = cmp.get('v.MRPSS');
                for(var x in mrps){
                     let mrp =mrps[x].MRP ;
                    if(mrp.ERP7__Total_Amount_Required__c > 0 && mrp.ERP7__Fulfilled_Amount__c == 0){
                        cmp.set('v.exceptionError',$A.get('$Label.c.Please_allocate_stock_to_consume'));
                        return;
                    }
                    else{
                        if(cmp.get('v.TypeOfWIP') == 'Produced') {
                            //mrps[x].quantityToConsume = ((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty);
                            mrps[x].quantityToConsume = parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                            mrps[x].quantityToScrap = 0;
                        }
                        else if(cmp.get('v.TypeOfWIP') == 'Scrapped'){
                            mrps[x].quantityToConsume = 0;
                            mrps[x].quantityToScrap = parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                            //mrps[x].quantityToScrap = ((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty);
                        }
                    }
                }


                cmp.set('v.MRPSS',mrps);
                if(cmp.get('v.TypeOfWIP') == 'Produced') {
                    cmp.set('v.TotalWIPQtyProduced',totalQty);
                    cmp.set('v.TotalWIPQtyScrapped',0);
                }
                else{
                    cmp.set('v.TotalWIPQtyProduced',0);
                    cmp.set('v.TotalWIPQtyScrapped',totalQty);
                }
            }
            else{
                cmp.set('v.showWIPsection',true);
                let mrps = cmp.get('v.MRPSS');
                for(var x in mrps){
                    mrps[x].quantityToConsume = 0;
                    mrps[x].quantityToScrap = 0;
                }
                cmp.set('v.MRPSS',mrps);
                cmp.set('v.TotalWIPQtyProduced',0);
                cmp.set('v.TotalWIPQtyScrapped',0);
            }
        },

        SetWIPs : function (cmp,event) {
            var checkedval = cmp.get('v.selectAllCheckbox');
            let wipflows = cmp.get('v.WIPFlows');
            var totalQty = 0;
            var lmt = cmp.get('v.WipflowsShowforBuild');

            for(var x in wipflows){
                wipflows[x].selected = false;
            }
            cmp.set('v.WIPFlows',wipflows);
            cmp.set('v.selectAllCheckbox',false);
        },
        handleWiptypeChange : function (cmp,event) {
            //alert('handleWiptypeChange');
            let serials = cmp.get('v.moSerialForProduction');
            var totalQty = 0;
            for(var x in serials){
                if(serials[x].selected) totalQty++;
            }
            // cmp.set('v.WIPFlows',wipflows);

            cmp.set('v.showWIPsection',false);
            let mrps = cmp.get('v.MRPSS');
            for(var x in mrps){
                 let mrp =mrps[x].MRP ;
                    if(mrp.ERP7__Total_Amount_Required__c > 0 && mrp.ERP7__Fulfilled_Amount__c == 0){
                    cmp.set('v.exceptionError',$A.get('$Label.c.Please_allocate_stock_to_consume'));
                    return;
                }
                else{
                    if(cmp.get('v.TypeOfWIP') == 'Produced') {
                        mrps[x].quantityToConsume = ((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty);
                        mrps[x].quantityToScrap = 0;
                    }
                    else if(cmp.get('v.TypeOfWIP') == 'Scrapped'){
                        mrps[x].quantityToConsume = 0;
                        mrps[x].quantityToScrap =((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty);;
                    }
                }
            }

            cmp.set('v.MRPSS',mrps);
            if(cmp.get('v.TypeOfWIP') == 'Produced') {
                cmp.set('v.TotalWIPQtyProduced',totalQty);
                cmp.set('v.TotalWIPQtyScrapped',0);
            }
            else{
                cmp.set('v.TotalWIPQtyProduced',0);
                cmp.set('v.TotalWIPQtyScrapped',totalQty);
            }
        },

        handleWiptypeChangeOld : function(cmp,event){
            //alert('In handleWiptypeChange');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            let wipflows = cmp.get('v.WIPFlows');
            var totalQty = 0;
            for(var x in wipflows){
                console.log('wipflows[x].selected : ',wipflows[x].selected);
                if(wipflows[x].selected) totalQty++;
            }
            console.log('totalQty : ',totalQty);
            var type = cmp.get('v.TypeOfWIP');
            let mrps = cmp.get('v.MRPSS');
            if(type == 'Produced'){
                console.log('TotalWIPQtyProduced : ',cmp.get('v.TotalWIPQtyProduced'));
                for(var x in mrps){
                    if((mrps[x].MRP.ERP7__Total_Amount_Required__c == mrps[x].MRP.ERP7__Fulfilled_Amount__c)){
                        mrps[x].quantityToConsume = (totalQty == 0) ? mrps[x].MRP.ERP7__Fulfilled_Amount__c : ((mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty);
                        mrps[x].quantityToScrap = 0;
                        console.log('mrps[x].quantityToConsume : ',mrps[x].quantityToConsume);
                    }
                }
                cmp.set('v.TotalWIPQtyProduced',totalQty);
                cmp.set('v.TotalWIPQtyScrapped',0);
            }
            else if(type == 'Scrapped'){
                console.log('TotalWIPQtyScrapped : ',cmp.get('v.TotalWIPQtyScrapped'));
                for(var x in mrps){
                    if((mrps[x].MRP.ERP7__Total_Amount_Required__c == mrps[x].MRP.ERP7__Fulfilled_Amount__c)){
                        mrps[x].quantityToScrap = (totalQty == 0) ? mrps[x].MRP.ERP7__Fulfilled_Amount__c : ((mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty);
                        mrps[x].quantityToConsume = 0;
                        console.log('mrps[x].quantityToScrap : ',mrps[x].quantityToScrap);
                    }
                }
                cmp.set('v.TotalWIPQtyScrapped',totalQty);
                cmp.set('v.TotalWIPQtyProduced',0);
            }
            cmp.set('v.MRPSS',mrps);
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        },

        //select single
        selectedWIps : function(cmp,event){
            console.log('selectedWIps called');
            var checkedval = event.getSource().get('v.checked');
            console.log('checkedval : ',checkedval);
            let wipflows = cmp.get('v.WIPFlows');
            var wipId = event.getSource().get('v.name');
            var alreadyselctedWIps = false;
            var totalQty = 0;
            for(var x in wipflows){
                if(wipflows[x].wipFlow.Id === wipId) {
                    wipflows[x].selected = checkedval;
                }
                if(alreadyselctedWIps == false && wipflows[x].selected == true) alreadyselctedWIps = true;
                if(wipflows[x].selected) totalQty += totalQty;
            }
            cmp.set('v.WIPFlows',wipflows);
            console.log('alreadyselctedWIps : ',alreadyselctedWIps);
            if(alreadyselctedWIps || checkedval){
                console.log('if');
                cmp.set('v.showWIPsection',false);
                let mrps = cmp.get('v.MRPSS');
                for(var x in mrps){
                    let mrp =mrps[x].MRP ;
                    if(mrp.ERP7__Total_Amount_Required__c > 0 && mrp.ERP7__Fulfilled_Amount__c == 0){
                        cmp.set('v.exceptionError',$A.get('$Label.c.Please_allocate_stock_to_consume'));
                        return;
                    }
                    else{
                        console.log('TypeOfWIP~>'+cmp.get('v.TypeOfWIP'));

                        if(cmp.get('v.TypeOfWIP') == 'Produced') {
                            console.log('mrps[x].quantityToConsume before~>'+mrps[x].quantityToConsume);
                            console.log('parseFloat(mrps[x].quantityToConsume)~>'+parseFloat(mrps[x].quantityToConsume));
                            console.log('mrps[x].MRP.ERP7__Total_Amount_Required__c~>'+mrps[x].MRP.ERP7__Total_Amount_Required__c);
                            console.log('v.WorkOrder.ERP7__Quantity_Ordered__c~>'+cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));

                            if(checkedval)  mrps[x].quantityToConsume = parseFloat((mrps[x].quantityToConsume + (mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'))).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                            else mrps[x].quantityToConsume = parseFloat((mrps[x].quantityToConsume - (mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'))).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));

                            //if(checkedval)  mrps[x].quantityToConsume = parseFloat(mrps[x].quantityToConsume) + (mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));
                            //else mrps[x].quantityToConsume = parseFloat(mrps[x].quantityToConsume) - (mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));
                            mrps[x].quantityToScrap = 0;

                            console.log('mrps[x].quantityToConsume after~>'+mrps[x].quantityToConsume);
                        }
                        else if(cmp.get('v.TypeOfWIP') == 'Scrapped'){
                            mrps[x].quantityToConsume = 0;

                            if(checkedval) mrps[x].quantityToScrap = parseFloat((mrps[x].quantityToScrap + (mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'))).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                            else mrps[x].quantityToScrap = parseFloat((mrps[x].quantityToScrap - (mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'))).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));

                            //if(checkedval) mrps[x].quantityToScrap = parseFloat(mrps[x].quantityToScrap) + (mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));
                            //else mrps[x].quantityToScrap = parseFloat(mrps[x].quantityToScrap) - (mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c'));
                        }
                    }
                }


                cmp.set('v.MRPSS',mrps);
                if(cmp.get('v.TypeOfWIP') == 'Produced') {
                    if(checkedval) cmp.set('v.TotalWIPQtyProduced',(cmp.get('v.TotalWIPQtyProduced') + 1));
                    else cmp.set('v.TotalWIPQtyProduced',(cmp.get('v.TotalWIPQtyProduced') - 1));
                    cmp.set('v.TotalWIPQtyScrapped',cmp.get('v.TotalWIPQtyScrapped'));
                }
                else if(cmp.get('v.TypeOfWIP') == 'Scrapped'){
                    if(checkedval) cmp.set('v.TotalWIPQtyScrapped',(cmp.get('v.TotalWIPQtyScrapped') + 1));
                    else cmp.set('v.TotalWIPQtyScrapped',(cmp.get('v.TotalWIPQtyScrapped') - 1));
                    cmp.set('v.TotalWIPQtyProduced',cmp.get('v.TotalWIPQtyProduced'));
                }
            }
            else{
                console.log('else');
                cmp.set('v.showWIPsection',true);
                let mrps = cmp.get('v.MRPSS');
                for(var x in mrps){
                    mrps[x].quantityToConsume = 0;
                    mrps[x].quantityToScrap = 0;
                }
                cmp.set('v.MRPSS',mrps);
                cmp.set('v.TotalWIPQtyProduced',0);
                cmp.set('v.TotalWIPQtyScrapped',0);
            }
            console.log('SelectedWIPflow : ',JSON.stringify(cmp.get('v.SelectedWIPflow')));

        },
        AutoStockAllocationInitial : function (cmp, event) {
            cmp.set("v.editErrorMsg","");
            var obj = cmp.get("v.MRPs");
            for(var x in obj){
                obj[x].MRPQuantity = (obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c);
            }
            cmp.set("v.MRPs",obj);
            $A.util.addClass(cmp.find("selectWOsModal"), 'slds-fade-in-open');
            $A.util.addClass(cmp.find("myselectWOsModalBackdrop"),"slds-backdrop_open");
        },
        closeSelectWOsModal : function (cmp,event) {
            $A.util.removeClass(cmp.find("selectWOsModal"), 'slds-fade-in-open');
            $A.util.removeClass(cmp.find("myselectWOsModalBackdrop"),"slds-backdrop_open");
            // cmp.popInit();
        },
        allocateForMRP : function (cmp, event,helper) {
            console.log('allocateForMRP called ');

            var MRPId = event.currentTarget.name;
            // alert(MRPId);
            if(MRPId != null && MRPId != '' && MRPId != undefined){
                var obj = cmp.get("v.MRPs");
                var allocatelimit = parseInt(cmp.get("v.AutoSTockAllocationLimit"));
                var objsel = [];
                for(var x in obj){
                    if(obj[x].MRP.Id == MRPId){
                        // alert(obj[x].MRPQuantity);
                        if(obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) allocatelimit = parseInt($A.get('$Label.c.AutoStockLimitSerial'));
                        if(obj[x].MRPQuantity == 0 ||  obj[x].MRPQuantity == '' || obj[x].MRPQuantity == null || obj[x].MRPQuantity == undefined){
                            cmp.set('v.exceptionError',$A.get('$Label.c.Enter_Quantity'));
                            break;
                        }
                        else if(obj[x].MRPQuantity > 0 && (obj[x].MRPQuantity > (obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c))){
                            cmp.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_greater_than')+' : '+(obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c ));
                            break;
                        }
                            else if(obj[x].MRPQuantity > 0 && obj[x].MRPQuantity > (obj[x].Stock * obj[x].WeightMultiplier)){
                                cmp.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_greater_than')+' : '+(obj[x].MRP.Stock * obj[x].WeightMultiplier));
                                break;
                            }
                                else{
                                    objsel.push(obj[x]);
                                    //limit = obj[x].MRPQuantity;
                                    break;
                                }

                    }
                }
                // alert(parseInt(cmp.get("v.AutoSTockAllocationLimit")));
                if(objsel.length > 0){
                    $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                    var allMRPs = JSON.stringify(objsel);
                    var action = cmp.get("c.ReserveMRPSStocks");
                    action.setParams({
                        MRPs: allMRPs,
                        AutostkLimit : allocatelimit
                    });

                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        //alert(state);
                        if (state === "SUCCESS") {
                            console.log('response : ',response.getReturnValue());
                            if(response.getReturnValue().errorMsg == '') {
                                helper.showToast($A.get('$Label.c.Success1'),'success',$A.get('$Label.c.Stock_allocated_succesfully'));
                                //cmp.popInit();
                                var resMRP = response.getReturnValue().MRPSS;
                                if(resMRP.length > 0){
                                    for(var x in obj){
                                        if(obj[x].MRP.Id == MRPId){
                                            obj[x] = resMRP[0];
                                        }
                                    }
                                    cmp.set("v.MRPs",obj);
                                }
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");

                            }
                            else {
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                            }
                        }
                        else {
                            console.log('error ReserveMRPSStocks : ',response.getError());
                            var err = response.getError();
                            if(err != undefined && err.length > 0) cmp.set("v.exceptionError",err[0].message);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
        },
        selectSerialsForProduction: function (cmp, event) {
            var checkedval = event.getSource().get('v.checked');
            cmp.set('v.selectAllCheckbox', checkedval);

            var obj = cmp.get("v.moSerialForProduction");
            var showSerialsCount = cmp.get("v.WipflowsShowforBuild");
            var startNum = cmp.get("v.startNum");
            console.log('startNum : ',startNum);
            var endNum = cmp.get("v.endNum");
            console.log('endNum : ',endNum);
            var selectedSerials = 0;
            for(var x in obj){
                obj[x].selected = false;
            }

            console.log('selectedSerials 2: ',selectedSerials);
            for (var i = startNum; i < endNum && i < obj.length; i++) {
                obj[i].selected = checkedval;
                selectedSerials++;
            }
            console.log('selectedSerials 1 : '+selectedSerials);


            cmp.set("v.moSerialForProduction", obj);

            if (checkedval) {
                cmp.set('v.showWIPsection', false);
                let mrps = cmp.get('v.MRPSS');
                let totalSelected = selectedSerials;
                for (var x in mrps) {
                    let mrp = mrps[x].MRP;
                    if (mrp.ERP7__Total_Amount_Required__c > 0 && mrp.ERP7__Fulfilled_Amount__c == 0) {
                        cmp.set('v.exceptionError', $A.get('$Label.c.Please_allocate_stock_to_consume'));
                        return;
                    } else {
                        if (cmp.get('v.TypeOfWIP') == 'Produced') {
                            mrps[x].quantityToConsume = parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalSelected).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                            mrps[x].quantityToScrap = 0;
                        } else if (cmp.get('v.TypeOfWIP') == 'Scrapped') {
                            mrps[x].quantityToConsume = 0;
                            mrps[x].quantityToScrap = parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c / cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalSelected).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                        }
                    }
                }

                cmp.set('v.MRPSS', mrps);

                if (cmp.get('v.TypeOfWIP') == 'Produced') {
                    cmp.set('v.TotalWIPQtyProduced', totalSelected);
                    cmp.set('v.TotalWIPQtyScrapped', 0);
                } else {
                    cmp.set('v.TotalWIPQtyProduced', 0);
                    cmp.set('v.TotalWIPQtyScrapped', totalSelected);
                }
            } else {
                cmp.set('v.showWIPsection', false); //changed to true on 17 jul,24 jira AA-542
                let mrps = cmp.get('v.MRPSS');

                for (var x in mrps) {
                    mrps[x].quantityToConsume = 0;
                    mrps[x].quantityToScrap = 0;
                }

                cmp.set('v.MRPSS', mrps);
                cmp.set('v.TotalWIPQtyProduced', 0);
                cmp.set('v.TotalWIPQtyScrapped', 0);
            }
        },
        /*selectSerialsForProduction : function (cmp,event) {
            var checkedval = event.getSource().get('v.checked');
            cmp.set('v.selectAllCheckbox', checkedval);
            var obj = cmp.get("v.moSerialForProduction");
            var showSerialsCount = cmp.get("v.WipflowsShowforBuild");
            var i = 0;
            for(var x in obj){
                if(i < showSerialsCount){
                    obj[x].selected = checkedval;
                    i++;
                }
            }
            cmp.set("v.moSerialForProduction", obj);
            if(checkedval){
                cmp.set('v.showWIPsection',false);
                let mrps = cmp.get('v.MRPSS');
                for(var x in mrps){
                    if(mrps[x].MRP.ERP7__Fulfilled_Amount__c == 0){
                        cmp.set('v.exceptionError',$A.get('$Label.c.Please_allocate_stock_to_consume'));
                        return;
                    }
                    else{
                        if(cmp.get('v.TypeOfWIP') == 'Produced') {
                            mrps[x].quantityToConsume = parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * i).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                            mrps[x].quantityToScrap = 0;
                        }
                        else if(cmp.get('v.TypeOfWIP') == 'Scrapped'){
                            mrps[x].quantityToConsume = 0;
                            mrps[x].quantityToScrap = parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * i).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                        }
                    }
                }
                cmp.set('v.MRPSS',mrps);
                if(cmp.get('v.TypeOfWIP') == 'Produced') {
                    cmp.set('v.TotalWIPQtyProduced',i);
                    cmp.set('v.TotalWIPQtyScrapped',0);
                }
                else{
                    cmp.set('v.TotalWIPQtyProduced',0);
                    cmp.set('v.TotalWIPQtyScrapped',i);
                }
            }
            else{
                cmp.set('v.showWIPsection',true);
                let mrps = cmp.get('v.MRPSS');
                for(var x in mrps){
                    mrps[x].quantityToConsume = 0;
                    mrps[x].quantityToScrap = 0;
                }
                cmp.set('v.MRPSS',mrps);
                cmp.set('v.TotalWIPQtyProduced',0);
                cmp.set('v.TotalWIPQtyScrapped',0);
            }
        },*/
        /*setSerialForProduction : function (cmp,event) {
            var checkedval = cmp.get('v.selectAllCheckbox');
            let serials = cmp.get('v.moSerialForProduction');
            var totalQty = 0;
            var lmt = cmp.get('v.WipflowsShowforBuild');
            cmp.set('v.endNum',lmt);
            var startlmt = cmp.get('v.startNum');
            for(var x in serials){
                serials[x].selected = false;
            }
            cmp.set('v.moSerialForProduction',serials);
            cmp.set('v.selectAllCheckbox',false);
        },*/
        setSerialForProduction: function (cmp, event) {
            let serials = cmp.get('v.moSerialForProduction');
            let lmt = cmp.get('v.WipflowsShowforBuild');
            cmp.set('v.endNum', parseInt(cmp.get('v.startNum')) + parseInt(lmt)); // Adjust endNum calculation

            // Resetting all serials to unselected
            for (let x in serials) {
                serials[x].selected = false;
            }

            cmp.set('v.moSerialForProduction', serials);
            cmp.set('v.selectAllCheckbox', false);
        },
        selectdivSerials : function (cmp,event) {
            console.log('WO details : ',JSON.stringify(cmp.get('v.WorkOrder')));
            let obj = cmp.get('v.moSerialForProduction');
            if(obj != undefined && obj.length > 0){
                var SId = event.currentTarget.getAttribute('data-serialId');
                var totalQty = 0;
                for(var x in obj){
                    if(SId == obj[x].Id){
                        obj[x].selected = !obj[x].selected;
                    }
                    if(obj[x].selected) totalQty++;
                }
                cmp.set("v.moSerialForProduction", obj);
                if(totalQty > 0){
                    cmp.set('v.showWIPsection',false);
                    let mrps = cmp.get('v.MRPSS');
                    for(var x in mrps){
                         let mrp =mrps[x].MRP ;
                    if(mrp.ERP7__Total_Amount_Required__c > 0 && mrp.ERP7__Fulfilled_Amount__c == 0){
                            cmp.set('v.exceptionError',$A.get('$Label.c.Please_allocate_stock_to_consume'));
                            return;
                        }
                        else{
                            if(cmp.get('v.TypeOfWIP') == 'Produced') {
                                mrps[x].quantityToConsume = parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                                mrps[x].quantityToScrap = 0;
                            }
                            else if(cmp.get('v.TypeOfWIP') == 'Scrapped'){
                                mrps[x].quantityToConsume = 0;
                                mrps[x].quantityToScrap = parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                            }
                        }
                    }
                    cmp.set('v.MRPSS',mrps);
                    if(cmp.get('v.TypeOfWIP') == 'Produced') {
                        cmp.set('v.TotalWIPQtyProduced',totalQty);
                        cmp.set('v.TotalWIPQtyScrapped',0);
                    }
                    else{
                        cmp.set('v.TotalWIPQtyProduced',0);
                        cmp.set('v.TotalWIPQtyScrapped',totalQty);
                    }
                }
                else{
                    cmp.set('v.showWIPsection',false); // made from true to false shaguftha 01_01_24
                    let mrps = cmp.get('v.MRPSS');
                    for(var x in mrps){
                        mrps[x].quantityToConsume = 0;
                        mrps[x].quantityToScrap = 0;
                    }
                    cmp.set('v.MRPSS',mrps);
                    cmp.set('v.TotalWIPQtyProduced',0);
                    cmp.set('v.TotalWIPQtyScrapped',0);
                }
            }

        },
      /*  getWIPs: function(cmp, event) {
            console.log('combinedSearch called');
            var allWIPS = cmp.get('v.SearchWIPFlows');
            console.log('allWIPS : ',allWIPS);
            var searchWIPVal = cmp.get('v.searchWIP').toLowerCase();
            console.log('searchWIPVal : ',searchWIPVal);
            var selectedGrade = cmp.get('v.selectedGrade');
            console.log('selectedGrade : ',selectedGrade);
            var thickness = cmp.get('v.thickness');
            console.log('thickness : ',thickness);
            var width = cmp.get('v.selectedWidth');
            console.log('width : ',width);
            var searchResult = [];
            if((searchWIPVal != null && searchWIPVal != '' && searchWIPVal != undefined) ||
               (selectedGrade != null && selectedGrade != '' && selectedGrade != undefined && selectedGrade != '--None--') ||
               (thickness  != null && thickness != '' && thickness != undefined && thickness != '--None--') ||
              (width != null && width != '' && width != undefined && width != '--None--')){
                for (var x in allWIPS) {
                    if(allWIPS[x].wipFlow != null && allWIPS[x].wipFlow != undefined){
                        var wipName = allWIPS[x].wipFlow.Name.toLowerCase();
                        var productName = allWIPS[x].wipFlow.ERP7__Product__r.Name.toLowerCase();
                        var productGrade = allWIPS[x].wipFlow.ERP7__Product__r.ERP7__Grade__c;
                        console.log('productGrade : ',productGrade);
                        var productThickness = allWIPS[x].wipFlow.ERP7__Product__r.ERP7__Thickness__c;
                        console.log('productThickness : ',productThickness);
                        var productWidth = allWIPS[x].wipFlow.ERP7__Product__r.ERP7__Width__c;
                        console.log('productWidth : ',productWidth);
                        if (((searchWIPVal != null && searchWIPVal != '' && searchWIPVal != undefined) && (wipName.includes(searchWIPVal) || productName.includes(searchWIPVal))) ||
                            (selectedGrade != null && selectedGrade != '' && selectedGrade != undefined && selectedGrade != '--None--' && productGrade === selectedGrade) ||
                            (thickness  != null && thickness != '' && thickness != undefined && thickness != '--None--' && productThickness == thickness) ||
                            (width != null && width != '' && width != undefined && width != '--None--' &&  width == productWidth)) {
                            searchResult.push(allWIPS[x]);
                        }
                    }
                }
                if (searchResult.length === 0)  cmp.set('v.warningError', 'No products available based on search..');
            }

            console.log('searchResult : ', searchResult);

            if (searchResult.length === 0) {
                cmp.set('v.WIPFlows', allWIPS);
            } else {
                cmp.set('v.warningError', '');
                cmp.set('v.WIPFlows', searchResult);
            }
        },*/
        getWIPs: function(cmp, event) {
            console.log('combinedSearch called');
            var allWIPS = cmp.get('v.SearchWIPFlows');
            console.log('allWIPS : ',allWIPS);
            var searchWIPVal = cmp.get('v.searchWIP').toLowerCase();
            console.log('searchWIPVal : ',searchWIPVal);
            var selectedGrade = cmp.get('v.selectedGrade');
            console.log('selectedGrade : ',selectedGrade);
            var thickness = cmp.get('v.thickness');
            console.log('thickness : ',thickness);
            var width = cmp.get('v.selectedWidth');
            console.log('width : ',width);
            var length = cmp.get('v.length');
            console.log('length : ',length);
            var searchResult = [];

            for (var x in allWIPS) {
                if(allWIPS[x].wipFlow != null && allWIPS[x].wipFlow != undefined){
                    var wipName = allWIPS[x].wipFlow.Name.toLowerCase();
                    var productName = allWIPS[x].wipFlow.ERP7__Product__r.Name.toLowerCase();
                    var productGrade = allWIPS[x].wipFlow.ERP7__Product__r.ERP7__Grade__c;
                    console.log('productGrade : ',productGrade);
                    var productThickness = allWIPS[x].wipFlow.ERP7__Product__r.ERP7__Thickness__c;
                    console.log('productThickness : ',productThickness);
                    var productWidth = allWIPS[x].wipFlow.ERP7__Product__r.ERP7__Width__c;
                    console.log('productWidth : ',productWidth);
                    var productLength = allWIPS[x].wipFlow.ERP7__Product__r.ERP7__Length__c;
                    console.log('productLength : ',productLength);

                    if ((selectedGrade === null || selectedGrade === '' || selectedGrade === '--None--' || productGrade === selectedGrade) &&
                        (thickness === null || thickness === '' || thickness === '--None--' || productThickness == thickness) &&
                        (width === null || width === '' || width === '--None--' ||  width == productWidth) &&
                        (length === null || length === '' || length === '--None--' ||  length == productLength) &&
                        (searchWIPVal === '' || wipName.includes(searchWIPVal) || productName.includes(searchWIPVal))) {
                        searchResult.push(allWIPS[x]);
                    }
                }
            }

            if (searchResult.length === 0) {
                cmp.set('v.warningError', $A.get('$Label.c.No_Products_Available'));
            }

            console.log('searchResult : ', searchResult);

            if (searchResult.length === 0) {
                cmp.set('v.WIPFlows', allWIPS);
            } else {
                cmp.set('v.warningError', '');
                cmp.set('v.WIPFlows', searchResult);
            }
        },

        handleWIPEdit : function(cmp, event) {
            var wipId = event.getSource().get('v.name');
            console.log(wipId);
            if(wipId != '' && wipId != null && wipId != undefined){
                var WIPs = cmp.get('v.onlyManufacturedWIPFlows');
                for(var x in WIPs){
                    if(WIPs[x].Id == wipId){
                        cmp.set('v.wipRecord',WIPs[x]);
                        break;
                    }
                }
                $A.util.addClass(cmp.find("editWIPModal"), 'slds-fade-in-open');
                $A.util.addClass(cmp.find("myeditModalBackdrop"), 'slds-backdrop_open');
            }

        },
        closeWIPpopup : function(cmp, event) {
            $A.util.removeClass(cmp.find("editWIPModal"), 'slds-fade-in-open');
            $A.util.removeClass(cmp.find("myeditModalBackdrop"), 'slds-backdrop_open');
        },
        saveEditWIP : function(cmp, event,helper) {
            var wipRecord = cmp.get('v.wipRecord');
            console.log('wipRecord : ',wipRecord);
            var action = cmp.get('c.saveWIPs');
            action.setParams({
                'WIP' : JSON.stringify(wipRecord),
                'WoId' : cmp.get('v.WorkOrder.Id')
            });
             action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var wipresult = response.getReturnValue();
                    console.log('wipresult : ',response.getReturnValue());
                    if(wipresult != null){
                        var WIPs = cmp.get('v.onlyManufacturedWIPFlows');
                        for(var x in WIPs){
                            if(WIPs[x].Id == wipresult.wip.Id){
                                WIPs[x] = wipresult.wip;
                                break;
                            }
                        }
                        cmp.set('v.onlyManufacturedWIPFlows',WIPs);
                        var WIPflow = cmp.get('v.WIPFlows');
                        for(var x in WIPflow){
                            if(WIPflow[x].wipFlow.Id == wipresult.wip.Id) {
                                WIPflow[x].wipFlow.ERP7__Quantity__c = wipresult.wip.ERP7__Quantity__c;
                                WIPflow[x].wipFlow.ERP7__Quantity_Scrapped__c = wipresult.wip.ERP7__Quantity_Scrapped__c;
                            }
                        }
                         cmp.set('v.WIPFlows',WIPflow);
                        if(wipresult.wo != undefined && wipresult.wo != null){
                            cmp.set('v.WorkOrder.ERP7__Quantity_Built__c',wipresult.wo.ERP7__Quantity_Built__c);
                            cmp.set('v.WorkOrder.ERP7__Quantity_Scrapped__c',wipresult.wo.ERP7__Quantity_Scrapped__c);
                        }
                        helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.WIP_updated_successfully'))
                    }

                    $A.util.removeClass(cmp.find("editWIPModal"), 'slds-fade-in-open');
                    $A.util.removeClass(cmp.find("myeditModalBackdrop"), 'slds-backdrop_open');
                }
             });
             $A.enqueueAction(action);
        },
        setStatusAsNew : function(cmp, event,helper) {
            //$A.util.addClass(cmp.find("todoId"), 'dropbtn1');
           // $A.util.removeClass(cmp.find("doneId"), 'dropbtn2');
            var count = event.currentTarget.dataset.id;
            console.log('count : ',count);
             var obj = cmp.get("v.Tasks");
            var objsel;
            for(var x in obj){
                if(x == count) {
                    objsel = obj[count];
                    break;
                }
            }
            cmp.set("v.SelectedTask",objsel);
            cmp.set("v.SelectedTask.ERP7__Status__c", 'New');
            var action = cmp.get("c.CompleteTask");
            $A.enqueueAction(action);

        },
        setStatusAsDone : function(cmp, event,helper) {
            //$A.util.removeClass(cmp.find("todoId"), 'dropbtn1');
            //$A.util.addClass(cmp.find("doneId"), 'dropbtn2');
            var count = event.currentTarget.dataset.id;
            console.log('count : ',count);
             var obj = cmp.get("v.Tasks");
            var objsel;
            for(var x in obj){
                if(x == count) {
                    objsel = obj[count];
                    break;
                }
            }
            cmp.set("v.SelectedTask",objsel);
            cmp.set("v.SelectedTask.ERP7__Status__c", 'Completed');
            var action = cmp.get("c.CompleteTask");
            $A.enqueueAction(action);
        },
        getfilteredSerials: function (cmp, event,helper) {
            try {
                let startingSerial = cmp.get("v.startingSerial");
                let count = cmp.get("v.WipflowsShowforBuild");
                let startNum = 0;
                let endNum = 0;
                let serials = cmp.get('v.moSerialForProduction');

                if (startingSerial) {
                    let found = false;
                    for (let i = 0; i < serials.length; i++) {
                        var name = serials[i].Name;
                        console.log('name : ',name);
                        if (name && (name === startingSerial || name.includes(startingSerial))) {
                            startNum = i;
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        helper.showToast('warning','warning','Serial not found');
                        console.warn('Starting serial not found in serials list');
                    }
                } else {
                    console.log('Starting serial is empty, defaulting to startNum = 0');
                }

                endNum = parseInt(startNum) + parseInt(count); // Ensure count is parsed as an integer
                cmp.set('v.startNum', startNum);
                cmp.set('v.endNum', endNum);

                console.log('startingSerial : ' + startingSerial);
                console.log('count : ' + count);
                console.log('startNum : ' + startNum);
                console.log('endNum : ' + endNum);
                for (let x in serials) {
                    serials[x].selected = false;
                }

                cmp.set('v.moSerialForProduction', serials);
                cmp.set('v.selectAllCheckbox', false);
                cmp.set('v.TotalWIPQtyProduced',0);
                cmp.set('v.TotalWIPQtyScrapped',0);
                 let mrps = cmp.get('v.MRPSS');
                for(var x in mrps){
                        if(cmp.get('v.TypeOfWIP') == 'Produced') {
                            mrps[x].quantityToConsume = 0;//parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                            mrps[x].quantityToScrap = 0;
                        }
                        else if(cmp.get('v.TypeOfWIP') == 'Scrapped'){
                            mrps[x].quantityToConsume = 0;
                            mrps[x].quantityToScrap = 0;//parseFloat(((mrps[x].MRP.ERP7__Total_Amount_Required__c/cmp.get('v.WorkOrder.ERP7__Quantity_Ordered__c')) * totalQty).toFixed($A.get("$Label.c.DecimalPlacestoFixedMO")));
                        }
                }
                cmp.set('v.MRPSS',mrps);
            } catch (error) {
                console.error('Error in getfilteredSerials:', error);
            }
        },
         EditMOSerial: function(cmp, event) {
            $A.util.addClass(cmp.find("myModalMOSerial"), 'slds-fade-in-open');
            $A.util.addClass(cmp.find("mySerialModalBackdrop"),"slds-backdrop_open");
            var count = event.getSource().get("v.name");
            var obj = cmp.get("v.moSerialNos");
            var objsel;
            for(var x in obj){
                if(x == count) {
                    objsel = obj[count];
                }
            }
            cmp.set("v.SerialNumber2Upsert",objsel);
        },
         DeleteRecordserial : function(cmp, event) {
            var result = confirm("Are you sure?");
            console.log('result : '+result);
            var RecordId = event.getSource().get("v.name");
            if (result && RecordId != '') {
                console.log("in if");
                var deleteserial = cmp.get('c.deleteSerial');
                deleteserial.setParams({'RecId':RecordId});
                deleteserial.setCallback(this, function(response) {
                    var state = response.getState();
                    if (cmp.isValid() && state === "SUCCESS") {
                        cmp.popInit();
                    }
                });
                $A.enqueueAction(deleteserial);
            }
        },
         closeMyModalMOSerial : function (cmp,event) {
            $A.util.removeClass(cmp.find("myModalMOSerial"), 'slds-fade-in-open');
            $A.util.removeClass(cmp.find("mySerialModalBackdrop"),"slds-backdrop_open");
        },
          upsertSerial: function(cmp, event) {
            var rec = cmp.get("v.SerialNumber2Upsert");
            console.log('rec : '+JSON.stringify(rec));
            if(rec.Name == undefined || rec.Name == "" || rec.ERP7__Serial_Number__c == undefined || rec.ERP7__Serial_Number__c == "" || rec.ERP7__Date_of_Manufacture__c == undefined || rec.ERP7__Date_of_Manufacture__c == ""){
                cmp.set("v.SerialPopupErrorMsg",$A.get('$Label.c.Required_fields_missing'));
            }
            else{
                console.log('inside else');
                var objsels = JSON.stringify(cmp.get("v.SerialNumber2Upsert"));
                 console.log('objsels ');
                var objs = JSON.stringify(cmp.get("v.ManuOrder"));
                 console.log('objs ');
                cmp.set("v.SerialPopupErrorMsg","");
                 console.log('cmp set');
                var action = cmp.get("c.SaveSerial");
                action.setParams({
                    SerialNumber: objsels,
                    MO: objs
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state : '+state);
                    if (state === "SUCCESS") {
                        $A.util.removeClass(cmp.find("myModalMOSerial"), 'slds-fade-in-open');
                        $A.util.removeClass(cmp.find("mySerialModalBackdrop"),"slds-backdrop_open");
                        cmp.popInit();
                    } else { cmp.set("v.SerialPopupErrorMsg",response.getReturnValue().errorMsg); console.log('ERR : '+JSON.stringify(response.getError()));}
                });
                $A.enqueueAction(action);
            }
        },
    generateSerialNumbers: function(cmp, event, helper) {
        try {
            const mainSpin = cmp.find('mainSpin');
            $A.util.removeClass(mainSpin, "slds-hide");

            const fromval = cmp.get('v.FromSerialNum');
            console.log('fromval:', fromval);

            const prefix = cmp.get('v.SerialPrefix');
            console.log('prefix:', prefix);

            const startNum = parseInt(cmp.get('v.startNum')) - 1;
            const endNum = parseInt(cmp.get('v.endNum'));
            console.log('startNum:', startNum);
            console.log('endNum:', endNum);

            if (fromval && prefix) {
                cmp.set('v.RefreshSerials', false);
                const allSerials = cmp.get('v.AllmoSerialNos') || [];
                const updatedSerials = [];

                // Ensure allSerials has enough objects
                for (let i = allSerials.length; i < endNum; i++) {
                    allSerials.push({});
                }

                var numericValue = parseInt(fromval);
                for (let i = startNum; i < endNum; i++) {
                    const serial = allSerials[i];
                    const formattedSerial = prefix + numericValue.toString().padStart(fromval.toString().length, '0');
                    console.log('formattedSerial : ', formattedSerial);
                    serial.Name = formattedSerial;
                    serial.ERP7__Serial_No__c = formattedSerial;
                    serial.ERP7__Barcode__c = formattedSerial;
                    updatedSerials.push(serial);
                    allSerials[i] = serial;
                    numericValue = numericValue + 1;
                }

                console.log('updatedSerials:', updatedSerials);
                var action = cmp.get("c.setSerials2");
                action.setParams({ MOId: cmp.get('v.ManuOrder.Id'), serialsList: JSON.stringify(updatedSerials) });
                action.setCallback(this, function(response) {
                    console.log('Callback executed');
                    console.log('Response:', response);
                    console.log('Return Value:', response.getReturnValue());

                    if (response.getState() === "SUCCESS") {
                        console.log('Apex call successful');
                        if (response.getReturnValue() != null) {
                            console.log('response.getReturnValue() : ', response.getReturnValue());
                            let result = response.getReturnValue();
                            if (result.includes('Duplicate') || result.includes('Error') || result.includes('duplicate') || result.includes('Failed')) {
                                cmp.set('v.exceptionError', result);
                            } else {
                                cmp.set('v.AllmoSerialNos', allSerials);
                                cmp.set('v.RefreshSerials', true);
                                console.log('RefreshSerials set to true');
                                helper.showToast($A.get('$Label.c.Success'), 'success', $A.get('$Label.c.Serial_number_generated_Successfully'));
                            }
                        } else {
                            console.log('Return value is null');
                        }
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else {
                        console.log('error : ', response.getError());
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);

            } else {
                $A.util.addClass(mainSpin, "slds-hide");
                cmp.set('v.exceptionError', fromval ? $A.get('$Label.c.Please_enter_Prefix_to_generate_serial_Numbers') : $A.get('$Label.c.Please_enter_from_value_to_generate_serial_Numbers'));
            }
        } catch (e) {
            console.log('Error catch:', e);
        }
    },
    handleExpiryDateChange: function(cmp, event, helper) {
        console.log('handleExpiryDateChange called');

        var newExpiryDate = event.getSource().get("v.value");
        console.log('newExpiryDate : ', newExpiryDate);

        var selectedWIPflow = cmp.get("v.SelectedWIPflow");
        console.log('selectedWIPflow : ', JSON.stringify(selectedWIPflow));

        if (!selectedWIPflow || !selectedWIPflow.Id) {
            console.error('Error: selectedWIPflow is undefined or missing Id');
            cmp.set("v.exceptionError", "No WIP Flow selected. Please select a WIP Flow and try again.");
            return;
        }

        var wipFlowId = selectedWIPflow.Id;
        console.log('wipFlowId : ', wipFlowId);

        var wipFlows = cmp.get("v.WIPFlows");
        console.log('wipFlows : ', JSON.stringify(wipFlows));

        // Update selectedWIPflow
        selectedWIPflow.ERP7__Expiry_Date__c = newExpiryDate;
        cmp.set("v.SelectedWIPflow", selectedWIPflow);
        console.log('Updated selectedWIPflow : ', JSON.stringify(selectedWIPflow));

        // Update corresponding WIPflow in v.WIPFlows
        var foundWIPflow = false;
        for (var i = 0; i < wipFlows.length; i++) {
            console.log('In LOOP, wipFlows[' + i + '].wipFlow.Id : ', wipFlows[i].wipFlow.Id);
            if (wipFlows[i].wipFlow.Id === wipFlowId) {
                console.log('WIP Flow ID matched: ', wipFlowId);
                wipFlows[i].wipFlow.ERP7__Expiry_Date__c = newExpiryDate;
                foundWIPflow = true;
                break;
            }
        }

        if (!foundWIPflow) {
            console.error('Error: No WIP Flow found with ID: ', wipFlowId);
            cmp.set("v.exceptionError", "WIP Flow not found in WIPFlows. Please ensure the correct WIP Flow is selected.");
            return;
        }

        cmp.set("v.WIPFlows", wipFlows);
        console.log('Updated wipFlows : ', JSON.stringify(wipFlows));
    }
    })