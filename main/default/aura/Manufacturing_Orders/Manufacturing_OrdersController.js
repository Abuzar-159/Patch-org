({
    focusTOscan : function (component, event,helper) {
        component.set("v.scanValue",'');
        helper.focusTOscan(component, event);

    },

    verifyScanCode : function (component, event, helper) {
        var scan_Code = component.get("v.scanValue");
        if(scan_Code === "Capture"){
            cmp.CaptureTheWeight();
        } else {
            var objm = component.get("v.MRPs");
            var objms = JSON.stringify(objm);
            //alert(scan_Code);

            if(!$A.util.isEmpty(scan_Code)){
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
        /*
        if(!$A.util.isEmpty(scan_Code)){
            helper.showSpinner(component, event);

            var BarcodeAction = component.get("c.SearchScanCode");
            BarcodeAction.setParams({"scanCode":scan_Code});
            BarcodeAction.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set('v.message',{});
                    helper.hideSpinner(component, event);
                    var obj = JSON.parse(response.getReturnValue());
                    var stockTake = component.get("v.stockTake");
                    if(response.getReturnValue() != null){
                        component.set("v.scanValue",'');
                        if(obj.step === "Site"){
                            stockTake.ERP7__Site__c = obj.Id;
                            stockTake.ERP7__Site__r = {Name:obj.Name,Id:obj.Id};
                            component.set("v.stockTake",stockTake);
                        }
                        if(obj.step === "location"){
                            component.set("v.step",'product');
                            var locFilter =" AND ERP7__Location__c ='"+obj.Id+"'";
                            var  siteFilter = "AND ERP7__Warehouse__c ='"+component.get("v.stockTake.ERP7__Site__r.Id")+"'";
                            helper.productfetchHelper(component, event,siteFilter,locFilter);
                        }
                    } else{
                        if(component.get("v.step") === "location"){
                            component.set("v.step",'product');
                        }else{
                            let msg = component.get('v.message');
                            msg['Title'] = 'Error';
                            msg['Severity']='error';
                            msg['Text'] = 'Please Select A Site ';
                            component.set('v.message',msg);
                        }
                    }
                }
            });
            if(component.get("v.step") === "Site" || component.get("v.step") === "location")
                $A.enqueueAction(BarcodeAction);
            else{
                helper.hideSpinner(component, event);
                component.set("v.productBarcode",component.get("v.scanValue"));
                component.set("v.scanValue",'');
            }
        }   */
    },

getAllDetails : function(cmp, event, helper) {
    console.log('getAllDetails called');

    $A.util.removeClass(cmp.find('mainSpinLoad'), "slds-hide");
    var vmo = cmp.get("v.MO");
    console.log('vmo : ',vmo);

    cmp.set("v.WCAP",true);
    cmp.set("v.show",true);
    if(cmp.get("v.serialorBatchesTab") == false) cmp.set("v.MRPSTab",true);
    var time=cmp.get("v.time");
    var vrd = cmp.get("v.RD");
    var action = cmp.get("c.getAll");
    action.setParams({vmoy:vmo,applyLimit : true,ShowAllWO : false});
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            console.log('res getAllDetails : ',response.getReturnValue());
            cmp.set("v.SerialsLength", response.getReturnValue().serialsLength);
            cmp.set("v.WipflowsLength", response.getReturnValue().wipflowsLength);
            cmp.set("v.showCosts", response.getReturnValue().showCosts);
            cmp.set("v.showRequisition", response.getReturnValue().showRequisition);
            cmp.set("v.isEditable", response.getReturnValue().isEditable);
            cmp.set("v.linksNewOptions", response.getReturnValue().linksNewOptions);
            cmp.set("v.showAutoStockAllocation", response.getReturnValue().showAutoStockAllocation);
            cmp.set("v.showManualStockAllocation", response.getReturnValue().showManualStockAllocation);
            cmp.set("v.ShowLangOptionForTraveller",response.getReturnValue().ShowLangOptionForTraveller);
            cmp.set("v.ReplaceTravellerOrgURL",response.getReturnValue().ReplaceTravellerOrgURL);
            cmp.set("v.showMultiPOs", response.getReturnValue().allowMultiPos);
            cmp.set('v.showSerialNumGeneration',response.getReturnValue().ShowCustomSerailNumberGeneration);
            cmp.set('v.showScrapDetails',response.getReturnValue().showScrapDetails);
            cmp.set('v.showMOLabels',response.getReturnValue().showMOLabels);
            cmp.set('v.allowMRPDelete',response.getReturnValue().AllowMRPDelete);
            cmp.set('v.enableQA',response.getReturnValue().enableQA); // added on 10_06_24 to have QA process
            cmp.set("v.preventsStatusEdit", response.getReturnValue().PreventStatusEdit);
            cmp.set("v.displayUplaodforItems",response.getReturnValue().showUplaodforItems);
            cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
            cmp.set("v.prevent", true);
            cmp.set("v.StandardOrder", response.getReturnValue().isStandardOrder);
            cmp.set("v.showVendorCode",response.getReturnValue().showVendorCode);
            console.log('StandardOrder : ',cmp.get("v.StandardOrder"));
            var tempMRPs = [];
            cmp.set("v.MRPs", tempMRPs);

            if(cmp.get("v.manuOrder.ERP7__Status__c") == '' || cmp.get("v.manuOrder.ERP7__Status__c") == null || cmp.get("v.manuOrder.ERP7__Status__c") == undefined) cmp.set("v.MOrderStatus", response.getReturnValue().moStatus);
            if(!cmp.get("v.schedulerMO")) cmp.set("v.manuOrder", response.getReturnValue().manuOrders);
            cmp.set("v.schedulerMO",false);
            cmp.set("v.NewWO.ERP7__MO__c", response.getReturnValue().manuOrders.Id);
            var kk = cmp.get("v.manuOrder");

            cmp.set("v.Product", response.getReturnValue().Product);
            console.log('Product 1 : ',response.getReturnValue().Product);
            cmp.set("v.Version", response.getReturnValue().Version);
            console.log('Version 1 : ',response.getReturnValue().Version);
            cmp.set("v.Routing", response.getReturnValue().Routing);

            var obj = response.getReturnValue().MRPs;
            cmp.set("v.UOMCs", response.getReturnValue().UOMCs);
            var showSAButton = false;
            var showAutoStock = response.getReturnValue().ReserveStock;
            var countofMRPgreen = 0;
            var allocatedStock = {}; // Track allocated stock for each BOM item

            for(var x in obj){
                var stk = obj[x].Stock;
                if(obj[x].MRP.ERP7__Total_Amount_Required__c != obj[x].MRP.ERP7__Fulfilled_Amount__c){
                    showSAButton = true;
                }

                cmp.set("v.WeightCapture", true);
                var newUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
                if(obj[x].MRP.ERP7__BOM__c != undefined && obj[x].MRP.ERP7__BOM__c != '' && obj[x].MRP.ERP7__BOM__c != null) var oldUOM = obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                obj[x].WeightMultiplier = 1;
                if(newUOM != '' && newUOM != undefined && oldUOM != '' && oldUOM != undefined && newUOM != oldUOM){
                    var UOMCs = cmp.get("v.UOMCs");
                    var conversionFound = false;
                    for(var k in UOMCs){
                        if((UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM) || (UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM)){
                            conversionFound = true;
                            if(UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM){
                                obj[x].WeightMultiplier = UOMCs[k].ERP7__From_Value__c/UOMCs[k].ERP7__To_Value__c;
                                obj[x].ActualWeight = obj[x].ActualWeight * obj[x].WeightMultiplier;
                            } else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM){
                                obj[x].WeightMultiplier = UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c;
                                obj[x].ActualWeight = obj[x].ActualWeight * obj[x].WeightMultiplier;
                            }
                        }
                    }
                }
                stk = stk * obj[x].WeightMultiplier;
                if(obj[x].MRP.ERP7__Total_Amount_Required__c == obj[x].MRP.ERP7__Fulfilled_Amount__c)  countofMRPgreen++;
                else if(stk > 0 && stk >= obj[x].MRP.ERP7__Total_Amount_Required__c){
                    countofMRPgreen++;
                }
                else if(stk > 0 && obj[x].MRP.ERP7__Fulfilled_Amount__c > 0 && (stk + obj[x].MRP.ERP7__Fulfilled_Amount__c) >= obj[x].MRP.ERP7__Total_Amount_Required__c ){
                    countofMRPgreen++;
                }
                if(stk <= 0) {
                    obj[x].bgColor = 'red-s';
                    obj[x].MRPQuantity = 0;
                }
                else if(stk > 0 && stk < obj[x].MRP.ERP7__Total_Amount_Required__c) {
                    obj[x].bgColor = 'orange';
                }
                else if(stk > 0 && stk >= obj[x].MRP.ERP7__Total_Amount_Required__c) {
                    obj[x].bgColor = 'green';
                }
                obj[x].MRPQuantity = (obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c);

                // Check and allocate stock
                var bomId = obj[x].MRP.ERP7__BOM__c;
                if (!allocatedStock[bomId]) {
                    console.log('in if');
                    allocatedStock[bomId] = 0;
                }
                var requiredStock = obj[x].MRPQuantity;
                console.log('requiredStock'+requiredStock);
                var availableStock = stk - allocatedStock[bomId];
                console.log('availableStock'+availableStock);
                if (availableStock >= requiredStock) {
                    console.log('in if 2');
                    allocatedStock[bomId] += requiredStock;
                    console.log('allocatedStock[bomId]'+allocatedStock[bomId]);
                } else {
                    console.log('in else');
                    allocatedStock[bomId] += availableStock;
                    console.log('allocatedStock[bomId]'+allocatedStock[bomId]);
                    obj[x].MRPQuantity = availableStock;
                }
            }
            if(countofMRPgreen > 0 && obj != undefined && countofMRPgreen == obj.length) showAutoStock = true;
            else showAutoStock = false;
            cmp.set("v.showSAButton", showSAButton);
            cmp.set("v.prevent", false);

            $A.util.addClass(cmp.find('mainSpinLoad'), "slds-hide");
            cmp.set("v.MRPs", obj);
            console.log('MRPs ',JSON.stringify(obj));
            cmp.set("v.WOs", response.getReturnValue().WOs);
            cmp.set("v.WOWS", response.getReturnValue().WOWS);
            cmp.set("v.SOLIs", response.getReturnValue().SOLIs);
            if(cmp.get("v.moSerialNos").length == 0){
                cmp.set("v.moSerialNos", response.getReturnValue().moSerialNos);
            }
            cmp.set("v.AllmoSerialNos", response.getReturnValue().moSerialNos);
            cmp.set("v.moBatchNos", response.getReturnValue().moBatchNos);
            cmp.set("v.ReserveStock", showAutoStock);

            cmp.set("v.SerialNumber2Upsert",response.getReturnValue().SerialNumber2Upsert);
            cmp.set("v.Batch2Upsert",response.getReturnValue().Batch2Upsert);
            cmp.set("v.NewSOLI",response.getReturnValue().NewSOLI);
            cmp.set("v.NewSOLITemp",response.getReturnValue().NewSOLI);
            cmp.set("v.NewMRP", response.getReturnValue().NewMRP);
            cmp.set("v.PRSS", response.getReturnValue().PRS);
            cmp.set("v.POSS", response.getReturnValue().POS);
            cmp.set("v.SelectedAttachments", response.getReturnValue().SelectedAttachments);
            cmp.set("v.Features", response.getReturnValue().Features);
            if(cmp.get("v.productId") != null && cmp.get("v.productId") != undefined && cmp.get("v.productId") != "") {
                var productMO = cmp.get("v.Product");
                productMO.Id = cmp.get("v.productId");
                productMO.Name = cmp.get("v.productName");
                cmp.set("v.Product", productMO);
                console.log('Product 2 : ',JSON.stringify(productMO));
            }
            console.log('bfr wipflows set 1 : ',response.getReturnValue().wipflows);
            if(cmp.get("v.Wipflows").length == 0){
                cmp.set('v.Wipflows',response.getReturnValue().wipflows);
            }

            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            $A.util.addClass(cmp.find('mainSpinLoad'), "slds-hide");
        } else{
            var errors = response.getError();
            console.log("server error in getAllDetails : ", JSON.stringify(errors));

            cmp.set("v.errorMsg", response.getError());
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            $A.util.addClass(cmp.find('mainSpinLoad'), "slds-hide");

        }
    });
    $A.enqueueAction(action);
    if((cmp.get("v.mosoliId") != undefined && cmp.get("v.mosoliId") != null && cmp.get("v.mosoliId") != '')||(cmp.get("v.MOrdItm") != undefined && cmp.get("v.MOrdItm") != '' && cmp.get("v.MOrdItm") != null)){
        helper.getSolis(cmp, event, helper);
    }
    if(cmp.get("v.mrpId") != undefined && cmp.get("v.mrpId") != '' && cmp.get("v.mrpId") != null){
        helper.getMRPMO(cmp, event, helper);
    }

    if(cmp.get("v.mpslineId") != undefined && cmp.get("v.mpslineId") != ''  && cmp.get("v.mpslineId") != null){

        helper.getMPSLine(cmp, event, helper);
    }
    helper.getParams(cmp, event, helper);
    helper.getStatus(cmp,event);
    helper.getpicklistValues(cmp, event);
},

    getAllMRPDetails : function(cmp, event, helper) {
        //alert("moId -~-> "+cmp.get("v.pageReference").state.id);//?id={!ERP7__Manufacturing_Order__c.Id}
        $A.util.removeClass(cmp.find('mainSpinLoad'), "slds-hide");
        var vmo = cmp.get("v.MO");
        cmp.set("v.WCAP",true);
        cmp.set("v.show",true);
        if(cmp.get("v.serialorBatchesTab") == false) cmp.set("v.MRPSTab",true);
        var time=cmp.get("v.time");
        var vrd = cmp.get("v.RD");
        var action = cmp.get("c.getAll");
        action.setParams({vmoy:vmo,applyLimit : true,ShowAllWO : false});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('res getAllDetails : ',response.getReturnValue());
                var tempMRPs = [];
                cmp.set("v.MRPs", tempMRPs);
                var obj = response.getReturnValue().MRPs;
                cmp.set("v.UOMCs", response.getReturnValue().UOMCs);
                var showSAButton = false;
                for(var x in obj){
                    var stk = obj[x].Stock;
                    //alert(stk);
                    if(obj[x].MRP.ERP7__Total_Amount_Required__c != obj[x].MRP.ERP7__Fulfilled_Amount__c){
                        showSAButton = true;
                    }
                    cmp.set("v.WeightCapture", true);
                    var newUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
                    var oldUOM = obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
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
                                    obj[x].ActualWeight = obj[x].ActualWeight * obj[x].WeightMultiplier;
                                } else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM){
                                    obj[x].WeightMultiplier = UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c;
                                    obj[x].ActualWeight = obj[x].ActualWeight * obj[x].WeightMultiplier;
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
                cmp.set("v.prevent", false);
                cmp.set("v.MRPs", obj);

                $A.util.addClass(cmp.find('mainSpinLoad'), "slds-hide");
            } else{
                cmp.set("v.errorMsg", response.getError());
                $A.util.addClass(cmp.find('mainSpinLoad'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },

    TravellerDoc: function(component, event, helper){
        console.log('TravellerDoc');
        var MOId = event.currentTarget.dataset.recordId;
        component.set("v.MOId",MOId);
        if(component.get("v.ShowLangOptionForTraveller")){
            component.set("v.ShowLangOptionForTravellerModal",true);
        }else{
            var Traveller = $A.get("$Label.c.TravellerDOC");
            //Changes made by Arshad 14/06/2023
            if(component.get("v.ReplaceTravellerOrgURL")){
                var customOrgUrl =  $A.get("$Label.c.orgURL");
                console.log('customOrgUrl : ',customOrgUrl);
                var RecUrl = customOrgUrl+"/apex/"+Traveller+"?RId=" + MOId+'&ra=pdf';
                console.log('RecUrl~>'+RecUrl);
                window.open(RecUrl,'_blank');
            }else{
                var RecUrl = "/apex/"+Traveller+"?RId=" + MOId+'&ra=pdf';
                console.log('RecUrl~>'+RecUrl);
                window.open(RecUrl,'_blank');
            }
        }
    },

    goBackTraveller : function(component, event, helper) {
        component.set("v.ShowLangOptionForTravellerModal",false);
    },

    TravellerNext : function(component, event, helper) {
        var MOId = component.get("v.MOId");
        var Traveller = $A.get("$Label.c.TravellerDOC");
        var SelectedLang = component.get("v.SelectedLang");
        if(SelectedLang == "English"){
            Traveller = $A.get("$Label.c.TravellerDOC");
        }else if(SelectedLang == "French"){
            Traveller = $A.get("$Label.c.TravellerDOCFR");
        }
        if(component.get("v.ReplaceTravellerOrgURL")){
            var customOrgUrl =  $A.get("$Label.c.orgURL");
            console.log('customOrgUrl : ',customOrgUrl);
            var RecUrl = customOrgUrl+"/apex/"+Traveller+"?RId=" + MOId+'&ra=pdf';
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank');
        }else{
            var RecUrl = "/apex/"+Traveller+"?RId=" + MOId+'&ra=pdf';
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank');
        }
    },

    SaveMO : function (cmp, event) {
        var MO = cmp.get("v.manuOrder");
        var Product = cmp.get("v.Product");
        var Version = cmp.get("v.Version");
        var Routing = cmp.get("v.Routing");
        var MOs = JSON.stringify(MO);

        //alert(MO.ERP7__StartDate__c);
        //v.manuOrder.ERP7__Is_Signature_Required__c == true
        //v.SelectedAttachments.length ==  cmp.get("v.SelectedAttachments").length;
        if(Product.Id != undefined && Product.Id != '' && Version.Id != undefined && Version.Id != '' && Routing.Id  != undefined && Routing.Id  != '' && MO.ERP7__Quantity__c  > 0 && MO.ERP7__StartDate__c != undefined && MO.ERP7__ExpectedDate__c != undefined && MO.ERP7__StartDate__c != "" && MO.ERP7__ExpectedDate__c != "" && !(MO.ERP7__Is_Signature_Required__c == true && cmp.get("v.sigTab") == false && cmp.get("v.SelectedAttachments").length == 0 && MO.ERP7__Status__c == 'Complete')){
            MO.ERP7__Product__c = Product.Id;
            MO.ERP7__Version__c = Version.Id;
            MO.ERP7__Routing__c = Routing.Id;
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.SaveM");
            action.setParams({
                MO: MOs
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue().errorMsg == ''){
                        cmp.set("v.errorMsg",'');
                        var MOId = response.getReturnValue().manuOrders.Id;
                        cmp.set("v.mrpId","");
                        cmp.set("v.mosoliId","");
                        cmp.set("v.MOrdItm","");
                        cmp.set("v.mpslineId","");
                        cmp.set("v.RD","yes");
                        cmp.set("v.MO",MOId);
                        cmp.set("v.manuOrder",response.getReturnValue().manuOrders);

                        if(cmp.get("v.sigTab") == true && MO.Id != undefined && MO.Id != '' && MO.ERP7__Is_Signature_Required__c == true && cmp.get("v.SelectedAttachments").length == 0){
                            var eSigComp = cmp.find('signatureEx');
                            eSigComp.saveSignatureFromParent();

                        }
                        // cmp.set("v.MRPs",cmp.get('v.MRPs'));

                        cmp.popInit();

                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");

                    } else if(response.getReturnValue().errorMsg != ''){
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set("v.errorMsg",response.getReturnValue().errorMsg);
                        //window.scrollTo(0, 0);
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            if(MO.ERP7__Is_Signature_Required__c == true && cmp.get("v.SelectedAttachments").length == 0 && MO.ERP7__Status__c == 'Complete') cmp.set("v.errorMsg",$A.get('$Label.c.Signature_Required'));
            else cmp.set("v.errorMsg",$A.get('$Label.c.Required_fields_missing'));
            //window.scrollTo(0, 0);
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");

        }
    },

    Nav2Record : function (cmp, event) {
        var MO = cmp.get("v.manuOrder");
        var RecUrl = "/" + MO.Id;
        window.open(RecUrl,'_Self');

    },

    Reload : function (cmp, event) {
        //$A.util.addClass(cmp.find('rot'), "erp-rotation");
        cmp.popInit();
        //$A.util.removeClass(cmp.find('rot'), "erp-rotation");
    },
    allocateForMRP : function (cmp, event,helper) {
        console.log('allocateForMRP called ');

        var MRPId = event.currentTarget.name;
        // alert(MRPId);
        if(MRPId != null && MRPId != '' && MRPId != undefined){
            var obj = cmp.get("v.MRPs");
            var wows = cmp.get("v.WOWS");
            var allocatelimit = parseInt(cmp.get("v.AutoSTockAllocationLimit"));
            var objsel = [];
            for(var x in obj){
                if(obj[x].MRP.Id == MRPId){
                    if(obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) allocatelimit = parseInt($A.get('$Label.c.AutoStockLimitSerial'));
                    console.log('MRPQuantity : ',obj[x].MRPQuantity);
                    console.log('Stock : ',obj[x].Stock);
                    console.log('WeightMultiplier : ',obj[x].WeightMultiplier);
                    console.log('obj[x].MRP.ERP7__Total_Amount_Required__c : ',obj[x].MRP.ERP7__Total_Amount_Required__c);
                    console.log('obj[x].MRP.ERP7__Fulfilled_Amount__c : ',obj[x].MRP.ERP7__Fulfilled_Amount__c);
                    var remainingQty = parseFloat(obj[x].MRP.ERP7__Total_Amount_Required__c) - parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c);
                    console.log('remainingQty : ',remainingQty);
                    if(obj[x].MRPQuantity == 0 ||  obj[x].MRPQuantity == '' || obj[x].MRPQuantity == null || obj[x].MRPQuantity == undefined){
                        cmp.set('v.exceptionError',$A.get('$Label.c.Enter_Quantity'));
                        break;
                    }
                    /* else if(obj[x].MRPQuantity > 0 && (obj[x].MRPQuantity > (obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c))){
                        cmp.set('v.exceptionError','Quantity cannot be greater than required : '+(obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c ));
                        break;
                    }*/
                    else if(obj[x].MRPQuantity > 0 && obj[x].MRPQuantity > (obj[x].Stock * obj[x].WeightMultiplier)){
                        cmp.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_greater_than') + ' : '+(obj[x].MRP.Stock * obj[x].WeightMultiplier));
                        break;
                    }
                        else{
                            objsel.push(obj[x]);
                            // allocatelimit = obj[x].MRPQuantity;
                            break;
                        }

                }
            }
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
                            helper.showToast('Sucess','success',$A.get("$Label.c.Stock_allocated_succesfully"));
                            //cmp.popInit();
                            var resMRP = response.getReturnValue().MRPs;
                            if(resMRP.length > 0){
                                for(var x in obj){
                                    if(obj[x].MRP.Id == MRPId){
                                        obj[x] = resMRP[0];
                                    }
                                }
                                cmp.set("v.MRPs",obj);
                                cmp.set("v.WOWS",wows);
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
    ReserveMRPStocks : function (cmp, event) {
        //cmp.set("v.showAllocationModal",false);

        var MOId = cmp.get("v.manuOrder").Id;

        var obj = cmp.get("v.MRPs");
        var wows = cmp.get("v.WOWS");
        var objsel = [];
        var autolimit = cmp.get("v.AutoSTockAllocationLimit");
        for(var x in obj){
            for(var y in wows){
                if(obj[x].MRP.ERP7__Work_Order__c == wows[y].WorkOrder.Id && wows[y].isSelect == true) {
                    objsel.push(obj[x]);
                    break;
                }
            }
        }
        var err = false;

        if(objsel.length == 0){
            cmp.set('v.exceptionError',$A.get('$Label.c.Please_select_Work_order_to_Allocate'));
            err = true;
        }
        var allMRPs = JSON.stringify(objsel);
        console.log('allMRPs : ',allMRPs);
        console.log('autolimit : ',parseInt(cmp.get("v.AutoSTockAllocationLimit")));

        console.log(err);
        // alert(autolimit);
        if(!err){
            $A.util.removeClass(cmp.find("selectWOsModal"), 'slds-fade-in-open');
            $A.util.removeClass(cmp.find("myselectWOsModalBackdrop"),"slds-backdrop_open");
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.ReserveMRPSStocks");
            action.setParams({
                MRPs: allMRPs,
                //AutostkLimit : parseInt(cmp.get("v.AutoSTockAllocationLimit"))
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    console.log('response : ',response.getReturnValue());
                    if(response.getReturnValue().errorMsg == '') {
                        cmp.popInit();

                        /*
                    $A.createComponent("c:Manufacturing_Orders",{
                        "MO" :MOId
                    },function(newCmp, status, errorMessage){
                        if (status === "SUCCESS") {
                            var body = cmp.find("body");
                            body.set("v.body", newCmp);
                        }
                    });
                    */
                        //cmp.set("v.MRPs",response.getReturnValue().MRPs);

                        //
                        /* window.setTimeout(
                                $A.getCallback(function() {
                                    cmp.popInit();
                                }), 20000
                            );*/
                        /* var initcall =  cmp.get('c.getAllDetails');   //cmp.popInit();
                   	initcall.setCallback(this, function(response) {
                        if (state === "SUCCESS") {

                            window.setTimeout(
                                $A.getCallback(function() {
                                    alert(state);
                                }), 5000
                            );
                            //location.reload();
                            //$A.get('e.force:refreshView').fire();
                        }
                        else{
                        }
                    });
                    $A.enqueueAction(initcall);*/
                        //helper.getAll(cmp,event)

                    }
                    else {
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    }
                } else {
                    console.log('error ReserveMRPSStocks : ',response.getError());
                    //cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }

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
            if (state === "SUCCESS") {
                cmp.set("v.editErrorMsg",response.getReturnValue().errorMsg);
                cmp.set("v.NewMRPs",response.getReturnValue());
                $A.util.addClass(cmp.find("editMRPModal"), 'slds-fade-in-open');
                $A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
            } else { cmp.set("v.editErrorMsg",response.getReturnValue().errorMsg); }
        });
        $A.enqueueAction(action);

    },

    updateMRP : function (cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var allMRPS = cmp.get("v.MRPs");
        var mrp_Main = cmp.get("v.MRPEdit.MRP");
        var alternate_Mrps = JSON.stringify(cmp.get("v.NewMRPs.MRPs"));
        var me = JSON.stringify(mrp_Main);
        for(var y in allMRPS){
            if(allMRPS[y].MRP.Id == mrp_Main.Id && mrp_Main.ERP7__Total_Amount_Required__c > (allMRPS[y].MRP.ERP7__BOM__r.ERP7__Quantity__c * allMRPS[y].MRP.ERP7__MO__r.ERP7__Quantity__c)) mrp_Main.ERP7__Status__c = 'Requested';
        }
        //alert(me);
        //alert(alternate_Mrps);
        var action = cmp.get("c.MRPUpdate");
        action.setParams({
            mrpMain1: JSON.stringify(mrp_Main),
            alternateMrps: alternate_Mrps
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.editErrorMsg",response.getReturnValue().errorMsg);
                if(response.getReturnValue().errorMsg == ''){
                    $A.util.removeClass(cmp.find("editMRPModal"), 'slds-fade-in-open');
                    $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    cmp.popInit();
                } else
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },

    Evaluate : function (cmp, event) {
        var mrp_Main = cmp.get("v.MRPEdit.MRP");
        var alternate_Mrps = cmp.get("v.NewMRPs.MRPs");
        if(mrp_Main.ERP7__BOM__r.ERP7__Is_Protected__c == true){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var target = event.getSource();
            var count = target.getElement().parentElement.name;
            for(var x in alternate_Mrps){
                if(x != count) {
                    alternate_Mrps[x].isSelect = false;
                }
            }
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        cmp.set("v.NewMRPs.MRPs",alternate_Mrps);
    },


    /*
    CreatePO:function(component, event, helper){
        var soliId = event.currentTarget.getAttribute('data-recordId');
        $A.createComponent("c:CreatePurchaseOrder",{
            "mrplineId":soliId,
            "cancelclick":component.getReference("c.backMO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    */

    CreatePurchaseRequisition:function(component, event, helper){
        var MO = component.get("v.manuOrder");
        var soliId = MO.Id;
        $A.createComponent("c:CreatePurchaseRequisition",{
            "MOId":soliId,
            "isNewTab":false,
            "cancelclick":component.getReference("c.backMO")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },

    CreatePurchaseOrder:function(component, event, helper){
        var MO = component.get("v.manuOrder");
        var soliId = MO.Id;
        if(component.get('v.showMultiPOs')){
            $A.util.addClass(component.find("POConfirmModalShow"), 'slds-fade-in-open');
            $A.util.addClass(component.find("POConfirmModalBackdrop"),"slds-backdrop_open");
            /* var showmultiPO = confirm('Do you want to create Multiple purchase orders');
            if(showmultiPO){
                console.log('showmultiPO : ',showmultiPO);
                $A.createComponent("c:MultiplePurchaseOrders",{
                    "MOId":soliId,
                    "FromMO":true
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                });
            }

            else{
                $A.createComponent("c:CreatePurchaseOrder",{
                    "MOId":soliId,
                    "cancelclick":component.getReference("c.backMO")
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                });
            }*/
        }
        else{

            $A.createComponent("c:CreatePurchaseOrder",{
                "MOId":soliId,
                "cancelclick":component.getReference("c.backMO")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }

    },

    backMO : function(component,event,helper){
        var MOId = component.get("v.manuOrder").Id;
        $A.createComponent("c:Manufacturing_Orders",{
            "MO" :MOId
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },


    lookupClickBatch :function(cmp,helper){
        try{
            //Product, Active true, Expired false, Avail qty > 0, siteId, ERP7__Routing__r.ERP7__Raw_Materials_Site__c
            console.log('component.get("v.manuOrder")~>'+JSON.stringify(cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c));

            var siteId = '';
            if(cmp.get("v.manuOrder").ERP7__Routing__c != undefined && cmp.get("v.manuOrder").ERP7__Routing__c != null){
                if(cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != undefined && cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != null){
                    siteId = cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
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
   lookupClickSerial: function(cmp, helper) {
    try {
        console.log('component.get("v.manuOrder")~>' + JSON.stringify(cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c));

        var siteId = '';
        if (cmp.get("v.manuOrder").ERP7__Routing__c != undefined && cmp.get("v.manuOrder").ERP7__Routing__c != null) {
            if (cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != undefined && cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != null) {
                siteId = cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            }
        }

        console.log('siteId~>' + siteId);

        var acc = undefined;
        var obj = cmp.get("v.MRPs");
        console.log('obj : ', obj);

        var serials2exclude = [];
        for (var x in obj) {
            if (obj[x].isSelect) {
                acc = obj[x].MRP.ERP7__MRP_Product__c;
            }
        }

        var action1 = cmp.get("c.getAllreservedSerials");
        action1.setParams({ "productId": acc });

        // Use a callback to ensure async behavior is handled
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS") {
                console.log('reserve response1: ', response1.getReturnValue());
                if (response1.getReturnValue() != null) {
                    serials2exclude = response1.getReturnValue();
                    console.log('serials2exclude in callback: ', serials2exclude);
                } else {
                    console.log('No reserved serials');
                }

                // Move query construction inside callback after getting the reserved serials
                var qry;
                if (acc == undefined) {
                    qry = ' ';
                } else {
                    qry = ' And ERP7__Product__c = \'' + acc + '\' ';
                }

                qry += ' And ERP7__Available__c = true AND ERP7__Expired__c = false AND ERP7__Scrap__c = false ';
                if (siteId != '') qry += ' AND ERP7__Warehouse__c = \'' + siteId + '\' ';

                if (serials2exclude.length > 0) {
                    // Format the array values for the SOQL query
                    qry += ' AND Id NOT IN (\'' + serials2exclude.join("','") + '\') ';
                }

                console.log('final serial qry~>' + qry);
                cmp.set("v.qry", qry);  // Set the query after it's ready
            } else {
                console.log('Error fetching reserved serials');
            }
        });

        // Enqueue the action
        $A.enqueueAction(action1);

    } catch (e) {
        console.log('lookupClickBatch err~>', e);
    }
},

    lookupClickBatchFor :function(cmp,helper){
        var acc = undefined;
        var MO = cmp.get("v.manuOrder");
        if(MO.ERP7__Product__c != undefined) acc = MO.ERP7__Product__c;

        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = ' And ERP7__Product__c = \''+acc+'\' And ERP7__Manufacturing_Order__c = \''+MO.Id+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
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
                    console.log('getSerialStock~>'+response.getReturnValue());
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
            var siteId = '';
            if(cmp.get("v.manuOrder").ERP7__Routing__c != undefined && cmp.get("v.manuOrder").ERP7__Routing__c != null){
                if(cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != undefined && cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c != null){
                    siteId = cmp.get("v.manuOrder").ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                }
            }
            console.log('siteId : ',siteId);
            var action = cmp.get("c.getBatchStock");
            action.setParams({
                batchId : bId,
                site : siteId
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    console.log('getBatchStock~>'+response.getReturnValue());
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

    lookupClickSerialFor :function(cmp,helper){
        try{
            console.log('lookupClickSerialFor called');

            var acc = undefined;
            var MO = cmp.get("v.manuOrder");
            if(MO.ERP7__Product__c != undefined) acc = MO.ERP7__Product__c;
            console.log('lookupClickSerialFor acc : ',acc);
            //alert(acc);
            var obj = cmp.get("v.MRPs");
            var stockAssignedSerialIds = [];
            for(var x in obj){
                if(obj[x].isSelect) {
                    console.log('obj[x] : ',obj[x]);
                    //acc = obj[x].MRP.ERP7__MRP_Product__c;
                    var RequiredQtyforSerial = (cmp.get("v.manuOrder.ERP7__Product__r.ERP7__Serialise__c")) ? (obj[x].MRP.ERP7__Total_Amount_Required__c / cmp.get("v.manuOrder.ERP7__Quantity__c")) : obj[x].MRP.ERP7__Total_Amount_Required__c;
                    console.log('RequiredQtyforSerial : ',RequiredQtyforSerial);
                    var soli = obj[x].SOLIs;
                    var fulfilledQty = 0;
                    if(soli != undefined && soli.length > 0){
                        for(var y in soli){
                            if(cmp.get("v.manuOrder.ERP7__Product__r.ERP7__Serialise__c") && obj[x].MRP.ERP7__MRP_Product__c == soli[y].ERP7__Product__c){
                                fulfilledQty +=   soli[y].ERP7__Quantity__c;
                            }
                            console.log('fulfilledQty : ',fulfilledQty);
                            console.log('RequiredQtyforSerial : ',RequiredQtyforSerial);
                            //if(fulfilledQty == RequiredQtyforSerial){ //Arshad 04 jul 2023
                            stockAssignedSerialIds.push(soli[y].ERP7__MO_WO_Serial__c);
                            //}
                            console.log('stockAssignedSerialIds : ',stockAssignedSerialIds);
                        }

                    }
                }
            }
            var qry;
            if(acc == undefined) qry = ' ';
            else if(stockAssignedSerialIds.length > 0){
                //qry = ' And ERP7__Product__c = \''+acc+'\' And ERP7__Manufacturing_Order__c = \''+MO.Id+'\' AND Id Not IN ( \''+stockAssignedSerialIds+'\')';
                qry = ' And ERP7__Product__c = \''+acc+'\' And ERP7__Manufacturing_Order__c = \''+MO.Id+'\' ';
                qry += ' And Id Not IN ( ';
                for(var obj in stockAssignedSerialIds){
                    qry += ' \''+stockAssignedSerialIds[obj]+'\' ';
                    if(obj < (stockAssignedSerialIds.length-1)) qry += ',';
                }
                qry += ')';

            }else qry = ' And ERP7__Product__c = \''+acc+'\' And ERP7__Manufacturing_Order__c = \''+MO.Id+'\'';

            cmp.set("v.qry",qry);
            console.log('lookupClickSerialFor qry : ',qry);
        }catch(e){
            console.log('err~>',e);
        }
        //alert(qry);
    },

    lookupClickVersion :function(cmp,helper){
        var acc = cmp.get("v.manuOrder.ERP7__Product__c");
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = ' And ERP7__Product__c = \''+acc+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
    },

    lookupClickRouting :function(cmp,helper){
        var acc = cmp.get("v.manuOrder.ERP7__Product__c");
        var version = cmp.get("v.manuOrder.ERP7__Version__c");
        //alert(acc);
        var qry;
        if(acc == undefined) qry = ' ';
        else qry = ' And ERP7__Product__c = \''+acc+'\'';
        if(version != undefined && version != '') qry += ' And ERP7__BOM_Version__c = \''+version+'\'';
        cmp.set("v.qry",qry);
        //alert(qry);
    },

    lookupChangeProduct :function(cmp,helper){
        if(cmp.get("v.prevent") == false){
            cmp.set("v.prevent", true);
            var Product = cmp.get("v.Product");
            console.log('Product 3 : ',JSON.stringify(Product));
            cmp.set("v.manuOrder.ERP7__Product__c", Product.Id);
            var proId = cmp.get("v.manuOrder.ERP7__Product__c");
            console.log('proId 3 : ',proId);
            if(proId == '' || proId == undefined) {
                var ob = JSON.parse('{"Id":"","Name":""}');
                cmp.set("v.Version", ob);

                cmp.set("v.Routing", ob);
                cmp.set("v.manuOrder.ERP7__Version__c", undefined);
                cmp.set("v.manuOrder.ERP7__Routing__c", undefined);
            }
            else{
                var action = cmp.get("c.GetDefaults");
                action.setParams({
                    proId: proId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //alert(state);
                        if(response.getReturnValue().Product.ERP7__Version__c != undefined) {
                            cmp.set("v.Version", response.getReturnValue().Version);
                            console.log('Version 3 : ',response.getReturnValue().Version);
                            var ver = (response.getReturnValue().Product.ERP7__Version__c).substr(0, 15);
                            cmp.set("v.manuOrder.ERP7__Version__c", ver);
                        }
                        if(response.getReturnValue().Product.ERP7__Routing__c != undefined) {
                            cmp.set("v.Routing", response.getReturnValue().Routing);
                            cmp.set("v.manuOrder.ERP7__Routing__c", response.getReturnValue().Product.ERP7__Routing__c);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
            cmp.set("v.prevent", false);
        }
    },

    lookupChangeVersion :function(cmp,helper){
        if(cmp.get("v.prevent") == false){
            var Version = cmp.get("v.Version");
            cmp.set("v.manuOrder.ERP7__Version__c", Version.Id);
            var ob = JSON.parse('{"Id":"","Name":""}');
            cmp.set("v.Routing", ob);
        }
    },

    lookupChangeRouting :function(cmp,helper){
        var Routings = cmp.get("v.Routing");
        cmp.set("v.manuOrder.ERP7__Routing__c", Routings.Id);
        var Routing = cmp.get("v.manuOrder.ERP7__Routing__c");
        var MO = cmp.get("v.manuOrder");
        //alert(Routing);
        if(Routing != '' && Routing != undefined && MO.Id == undefined){
            var action = cmp.get("c.GetRouting");
            action.setParams({
                routingId: Routing
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert(state);
                    cmp.set("v.manuOrder.ERP7__StartDate__c",response.getReturnValue().StartDate);
                    cmp.set("v.manuOrder.ERP7__ExpectedDate__c",response.getReturnValue().ExpectedDate);
                }
            });
            $A.enqueueAction(action);
        }
    },

    lookupChangeMO :function(cmp,helper){
        var vmo = cmp.get("v.NewWO.ERP7__MO__c");
        if(vmo != '' && vmo != undefined && cmp.get("v.prevent") == false){
            cmp.set("v.MO",vmo);
            cmp.set('v.workOrderTab',false);
            cmp.set('v.MRPSTab',true);
            cmp.set('v.serialorBatchesTab',false);
            cmp.set('v.finishedProductsTab',false);
            cmp.set('v.signatureTab',false);
            cmp.popInit();
        }
    },

    lookupClickProduct :function(cmp,helper){
        var proId = cmp.get("v.manuOrder.ERP7__Product__c");
        //alert(proId);
        if(proId == '' || proId == undefined) {
            //alert(proId);
            cmp.set("v.manuOrder.ERP7__Version__c", undefined);
            cmp.set("v.manuOrder.ERP7__Routing__c", undefined);
        }
        cmp.set("v.changeTrack",true);
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

    NewSerialPopup: function(cmp, event) {
        cmp.set("v.SerialPopupErrorMsg",'');
        cmp.set("v.SerialNumber2Upsert",undefined);
        cmp.set("v.SerialNumber2Upsert.Name","");
        cmp.set("v.SerialNumber2Upsert.ERP7__Serial_Number__c","");
        cmp.set("v.SerialNumber2Upsert.ERP7__Date_of_Manufacture__c",undefined);
        cmp.set("v.SerialNumber2Upsert.ERP7__Availability_date__c",undefined);
        cmp.set("v.SerialNumber2Upsert.ERP7__Shelf_Life_Expiration_Date__c",undefined);
        cmp.set("v.SerialNumber2Upsert.ERP7__Cost_Price__c",undefined);
        $A.util.addClass(cmp.find("myModalMOSerial"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("mySerialModalBackdrop"),"slds-backdrop_open");
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

    NewBatchPopup: function(cmp, event) {
        cmp.set("v.Batch2Upsert",undefined);
        cmp.set("v.Batch2Upsert.Name","");
        cmp.set("v.Batch2Upsert.ERP7__Next_Inspection_Date__c",undefined);
        cmp.set("v.Batch2Upsert.ERP7__Date_of_Manufacture__c",undefined);
        cmp.set("v.Batch2Upsert.ERP7__Availability_date__c",undefined);
        cmp.set("v.Batch2Upsert.ERP7__Shelf_Life_Expiration_Date__c",undefined);
        cmp.set("v.Batch2Upsert.ERP7__Cost_Price__c",undefined);
        $A.util.addClass(cmp.find("myModalMOBatch"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myBatchModalBackdrop"),"slds-backdrop_open");
    },

    EditMOBatch: function(cmp, event) {
        $A.util.addClass(cmp.find("myModalMOBatch"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myBatchModalBackdrop"),"slds-backdrop_open");
        var count = event.getSource().get("v.name");
        var obj = cmp.get("v.moBatchNos");
        var objsel;
        for(var x in obj){
            if(x == count) {
                objsel = obj[count];
            }
        }
        cmp.set("v.Batch2Upsert",objsel);
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
                                var obj = cmp.get("v.SelectedAttachments");
                                var count;
                                for(var x in obj){
                                    if(obj[x].Id == RecordId) {
                                        count = x;
                                    }
                                }
                                obj.splice(count, 1);
                                cmp.set("v.SelectedAttachments",obj);
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
    DeleteRecordserial : function(cmp, event) {
        var result = confirm("Are you sure?");
        console.log('result : '+result);
        var RecordId = event.getSource().get("v.name");
        if (result && RecordId != '') {
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
    DeleteRecord: function(cmp, event) {
        var result = confirm("Are you sure?");
        console.log('result : '+result);
        var RecordId = event.getSource().get("v.name");
        console.log('RecordId : '+RecordId);
        if (result && RecordId != '') {
            cmp.set("v.RecordId",RecordId);
            cmp.find("deleteHandler").reloadRecord();
        }
    },

    CommitDeleteRecord : function(cmp, event, helper) {
        cmp.find("deleteHandler").deleteRecord($A.getCallback(function(deleteResult) {
            console.log(deleteResult);
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                cmp.popInit();
            }
        }));
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
            var objs = JSON.stringify(cmp.get("v.manuOrder"));
            cmp.set("v.SerialPopupErrorMsg","");
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

    upsertBatch: function(cmp, event) {
        var rec = cmp.get("v.Batch2Upsert");
        if(rec.Name == undefined || rec.Name == "" || rec.ERP7__Date_of_Manufacture__c == undefined || rec.ERP7__Date_of_Manufacture__c == ""){
            cmp.set("v.BatchPopupErrorMsg",$A.get('$Label.c.Required_fields_missing'));
        }
        else{
            var objsels = JSON.stringify(cmp.get("v.Batch2Upsert"));
            var objs = JSON.stringify(cmp.get("v.manuOrder"));
            cmp.set("v.BatchPopupErrorMsg","");
            var action = cmp.get("c.SaveBatch");
            action.setParams({
                Batch: objsels,
                MO: objs
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.util.removeClass(cmp.find("myModalMOBatch"), 'slds-fade-in-open');
                    $A.util.removeClass(cmp.find("myBatchModalBackdrop"),"slds-backdrop_open");
                    cmp.popInit();
                } else { cmp.set("v.BatchPopupErrorMsg",response.getReturnValue().errorMsg); }
            });
            $A.enqueueAction(action);
        }
    },

    /*   SelectMRP: function(cmp, event) {
        console.log('SelectMRP called');
        cmp.set("v.showSpinner",true);
        try{
            cmp.set("v.exceptionError","");
            var count = event.currentTarget.getAttribute('data-mrpcount');
            var obj = cmp.get("v.MRPs");
            var moSerialNos = cmp.get("v.moSerialNos");
           var MOId = cmp.get("v.manuOrder.Id");
            var moBatchNos = cmp.get("v.moBatchNos");
            var NewSerialsForAllocation = [];
            var stockAssignedSerialIds = [];
            var Fulfilled = true;
            cmp.set("v.WeightStr","0");
            for(var x in obj){
                if(count == x) {
                    obj[x].isSelect = true;
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
                if(obj[x].ActualWeight < obj[x].MRP.ERP7__Total_Amount_Required__c) Fulfilled = false;
            }
            var action = cmp.get("c.getSerialNumbers");
            action.setParams({"offsetVal" : 0,"Mo" : MOId,"limitSer" : 1000,'SerialIds' : stockAssignedSerialIds});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                   // alert('success 1');
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
                    if(moBatchNos.length == 1){
                        newSOL.ERP7__MO_WO_Material_Batch_Lot__c = moBatchNos[0].Id;
                    }

                    console.log('SelectMRP moSerialNos.length~>'+moSerialNos.length);
                    cmp.set("v.saPage",true);
                    cmp.set("v.MRPs",obj);
                    cmp.set("v.Fulfilled",Fulfilled);
                    cmp.set("v.NewSOLI",newSOL);
                    cmp.set("v.SerialsForAllocation", NewSerialsForAllocation);
                    cmp.set("v.showSpinner",false);
                    console.log('settimeout showSpinner SelectMRP');
                }
            });
            $A.enqueueAction(action);


        } catch(err) {
            console.log('err occured SelectMRP~>',err);
             cmp.set("v.showSpinner",false);
        }
    },*/
    SelectMRP: function(cmp, event,helper) {
        console.log('SelectMRP called');
        cmp.set("v.showSpinner",true);
        try{
            cmp.set("v.exceptionError","");
            var count = event.currentTarget.getAttribute('data-mrpcount');console.log('count ',count);
            cmp.set("v.exceptionError","");
            var obj = cmp.get("v.MRPs");
            var MOId = cmp.get("v.manuOrder.Id");console.log('here 1 ');
            if(obj != undefined && obj.length > 0) {
                var selectedMRP = obj[count];
                // alert(selectedMRP.MRP.Id);
                try{console.log('here 2 ');
                var action = cmp.get("c.getMRPDetails");
                action.setParams({'MRP' : selectedMRP.MRP.Id,"Mo" : MOId});
                action.setCallback(this, function(response) {
                    var state = response.getState();console.log('here 3 ');
                    //alert(state);
                    if (state === "SUCCESS") {
                        var soli = response.getReturnValue();
                        var stockAssignedSerialIds = [];
                        var actualfulfilledWeight = 0;
                        /*
                        for(var y in soli){
                            stockAssignedSerialIds.push(soli[y].ERP7__MO_WO_Serial__c);
                            actualfulfilledWeight += soli[y].ERP7__Quantity__c;
                        }*/
                        console.log('here 4 ');
                        var serialQuantityMap = new Map();
                        var matchingSerialsSet = new Set();
                        for (var x in soli) {
                            var soliItem = soli[x];
                            var moWoSerial = soliItem.ERP7__MO_WO_Serial__c;
                            var quantity = soliItem.ERP7__Quantity__c;
                            if (moWoSerial !== undefined) {
                                if (serialQuantityMap.has(moWoSerial)) {
                                    serialQuantityMap.set(moWoSerial, serialQuantityMap.get(moWoSerial) + quantity);
                                } else {
                                    serialQuantityMap.set(moWoSerial, quantity);
                                }console.log('here 5 ');
                            }actualfulfilledWeight += soliItem.ERP7__Quantity__c;console.log('here 6 ');
                        }console.log('here 7 ');
                        for (var x in soli) {
                            var soliItem = soli[x];
                            if(soliItem.ERP7__BoM__c){
                            	var moWoSerial = soliItem.ERP7__MO_WO_Serial__c;
                            	var bomQuantity = soliItem.ERP7__BoM__r.ERP7__Quantity__c;

                            	if (moWoSerial !== undefined && serialQuantityMap.has(moWoSerial)) {
                                	var totalQuantity = serialQuantityMap.get(moWoSerial);
                                	//actualfulfilledWeight+=totalQuantity;
                                	if (totalQuantity === bomQuantity) {
                                    	matchingSerialsSet.add(moWoSerial);
                                	}
                            	}
                            }
                        }console.log('actualfulfilledWeight ',actualfulfilledWeight);
                        stockAssignedSerialIds = Array.from(matchingSerialsSet);
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
                        cmp.set("v.selectAllSerials",false);
                    }
                });
                $A.enqueueAction(action);}catch(err){ console.log('error ',err.message);}
            }
        } catch(err) {
            console.log('err occured SelectMRP~>',err);
            cmp.set("v.showSpinner",false);
        }
    },

    SelectSerialForAllocation: function(cmp, event) {
        console.log('SelectSerialForAllocation called');

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

    selectTheSerial: function(cmp, event) {
        var checkedval = event.getSource().get('v.checked');
        var obj = cmp.get("v.SerialsForAllocation");
        cmp.set("v.SerialsForAllocation", obj);
    },

    selectTheSerialonDiv: function(cmp, event) {
        var SId = event.currentTarget.getAttribute('data-serialId');
        var obj = cmp.get("v.SerialsForAllocation");
        var count = 0;
        for(var x in obj){
            if(SId == obj[x].Id){
                obj[x].SelectItem = !obj[x].SelectItem;
                //sbreak;
            }
            if(obj[x].SelectItem) count++;
        }
        cmp.set("v.SerialsForAllocation", obj);
        cmp.set("v.SelectedSerialsCount", count);

    },

    SerialForAllocation: function(cmp, event) {
        console.log('SerialForAllocation called');
        try{
            //  alert('3');
            var obj = cmp.get("v.MRPs");
            var moSerialNos = cmp.get("v.moSerialNos");
            var NewSerialsForAllocation = [];
            var stockAssignedSerialIds = [];
            cmp.set('v.selectAllSerials', false);
            for(var x in obj){
                console.log('inhere obj');
                if(obj[x].isSelect) {
                    console.log('inhere isSelect');
                    cmp.set("v.selectedMRP",obj[x].MRP);
                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c != undefined) cmp.set("v.WeightStr", obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c);
                    var soli = obj[x].SOLIs;
                    console.log('soli ',JSON.stringify(soli));
                    if(soli != undefined && soli.length > 0){
                      /*  for(var y in soli){
                            console.log('inhere soli innerloop');
                            stockAssignedSerialIds.push(soli[y].ERP7__MO_WO_Serial__c);
                        }*/
                        try {
                        var serialQuantityMap = new Map();
                    	var matchingSerialsSet = new Set();
                    	for (var x in soli) {
                        	var soliItem = soli[x];
                        	var moWoSerial = soliItem.ERP7__MO_WO_Serial__c;
                        	var quantity = soliItem.ERP7__Quantity__c;

                        	if (moWoSerial !== undefined) {
                            	if (serialQuantityMap.has(moWoSerial)) {
                                	serialQuantityMap.set(moWoSerial, serialQuantityMap.get(moWoSerial) + quantity);
                            	} else {
                                	serialQuantityMap.set(moWoSerial, quantity);
                            	}
                        	}
                    	}
                    	for (var x in soli) {
                        	var soliItem = soli[x];
                        	var moWoSerial = soliItem.ERP7__MO_WO_Serial__c;
                        	if(soliItem.ERP7__BoM__c){
                        		var bomQuantity = soliItem.ERP7__BoM__r.ERP7__Quantity__c;

                        		if (moWoSerial !== undefined && serialQuantityMap.has(moWoSerial)) {
                            		var totalQuantity = serialQuantityMap.get(moWoSerial);
                            		if (totalQuantity === bomQuantity) {
                                		matchingSerialsSet.add(moWoSerial);
                            		}
                        		}
                            }
                    	}
                    	stockAssignedSerialIds = Array.from(matchingSerialsSet); } catch (err) {
    console.error("️ Error Message: " + err.message);
    console.error(" Stack Trace: " + err.stack);
}
                    }
                    console.log('stockAssignedSerialIds after stock allocation ',stockAssignedSerialIds);
                    if(moSerialNos != undefined && moSerialNos.length > 0)
                    { moSerialNos.sort((a, b) => {
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
                     console.log('serials after : ',moSerialNos);
                    }
                    for(var y in moSerialNos){
                        console.log('inhere moSerialNos innerloop');
                        if(stockAssignedSerialIds.includes(moSerialNos[y].Id) == false) {
                            console.log('inhere moSerialNos innerloop if');
                            moSerialNos[y].SelectItem = false;
                            NewSerialsForAllocation.push(moSerialNos[y]);
                        }
                    }
                    cmp.set("v.SerialsForAllocation", NewSerialsForAllocation);
                    if(NewSerialsForAllocation.length > 0){
                        var newSOL = cmp.get("v.NewSOLI");
                        newSOL.ERP7__MO_WO_Serial__c = NewSerialsForAllocation[0].Id;
                        cmp.set("v.NewSOLI",newSOL);
                        console.log('inhere NewSOLI set');
                    }
                }
            }
            /* if(cmp.get('v.setmyParams')){
                cmp.set("v.saPage",true);
                cmp.set("v.showSpinner",false);
                cmp.set("v.setmyParams",false);
            }*/
            //alert('4');
            console.log('SerialForAllocation in here');

        }catch(e){
            console.log('err occured~>',e);
        }
    },

    SetShowSerial : function(cmp, event, helper) {
        var obj = cmp.get("v.SerialsForAllocation");
        for(var x in obj){
            obj[x].SelectItem = false;
        }
        cmp.set("v.SerialsForAllocation", obj);
        cmp.set('v.selectAllSerials', false);
        cmp.set("v.SelectedSerialsCount",0);
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
        if(checkedval) cmp.set("v.SelectedSerialsCount",i);
        else cmp.set("v.SelectedSerialsCount",0);
    },

    //changed by Arshad 05 Sep 2023
    //changes added by shagufuftha 08/09/2023
    /*  SelectMRP1: function(cmp, event) {
        console.log('SelectMRP1 called');
        cmp.set("v.showSpinner",true);
        try{

            window.scrollTo(0, 0);
            cmp.set("v.exceptionError","");
            var obj = cmp.get("v.MRPs");
            var MOId = cmp.get("v.manuOrder.Id");
            var limitSerials = cmp.get('v.showSerials');
             var stockAssignedSerialIds = [];
             var NewSerialsForAllocation = [];
            var TotalWeight = 0;
            var Fulfilled = true;
            cmp.set("v.WeightStr","0");
            for(var x in obj){
                if(0 == x) {
                    obj[x].isSelect = true;
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
                   // alert('success 1');
                    var moSerialNos = response.getReturnValue();
                    cmp.set("v.moSerialNos",moSerialNos);
                    //var moSerialNos = cmp.get("v.moSerialNos");
                    var moBatchNos = cmp.get("v.moBatchNos");



                   // alert('2');
                    var newSOL = cmp.get("v.NewSOLI");
                    for(var y in moSerialNos){
                        console.log('inhere moSerialNos innerloop');
                        if(stockAssignedSerialIds.includes(moSerialNos[y].Id) == false) {
                            console.log('inhere moSerialNos innerloop if');
                            moSerialNos[y].SelectItem = false;
                            NewSerialsForAllocation.push(moSerialNos[y]);
                        }
                    }
                    //alert('3');
                    if(NewSerialsForAllocation.length > 0){
                        newSOL.ERP7__MO_WO_Serial__c = NewSerialsForAllocation[0].Id;
                    }
                    if(moBatchNos.length == 1){
                        newSOL.ERP7__MO_WO_Material_Batch_Lot__c = moBatchNos[0].Id;
                    }
                    cmp.set("v.Fulfilled",Fulfilled);
                    cmp.set("v.MRPs",obj);
                    cmp.set("v.TotalWeight",TotalWeight);
                    cmp.set("v.NewSOLI",newSOL);
                    cmp.set("v.SerialsForAllocation", NewSerialsForAllocation);
                    console.log('SelectMRP1 moSerialNos.length~>'+moSerialNos.length);

                   // if(moSerialNos.length > 0) {
                    //    cmp.loadSerialForAllocation();
                   //     cmp.set("v.setmyParams",true);
                   // }
                   // else{
                        cmp.set("v.saPage",true);
                        cmp.set("v.showSpinner",false);
                        console.log('settimeout saPage SelectMRP1');
                    //}


                }
            });
            $A.enqueueAction(action);


        } catch(err) {
            console.log('err occured SelectMRP1~>',err);
            cmp.set("v.showSpinner",false);
        }
    },
    */
    SelectMRP1: function(cmp, event,helper) {
        console.log('SelectMRP1 called');
        cmp.set("v.showSpinner",true);
        try{

            window.scrollTo(0, 0);
            cmp.set("v.exceptionError","");
            var obj = cmp.get("v.MRPs");
            var MOId = cmp.get("v.manuOrder.Id");
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

                        //old code start
                       /* for(var y in soli){
                            stockAssignedSerialIds.push(soli[y].ERP7__MO_WO_Serial__c);
                            actualfulfilledWeight += soli[y].ERP7__Quantity__c;
                        }*/
                        //end

                        var serialQuantityMap = new Map();
                        var matchingSerialsSet = new Set();

                        for (var x in soli) {
                            var soliItem = soli[x];
                            var moWoSerial = soliItem.ERP7__MO_WO_Serial__c;
                            var quantity = soliItem.ERP7__Quantity__c;
                            if (moWoSerial !== undefined) {
                                if (serialQuantityMap.has(moWoSerial)) {
                                    serialQuantityMap.set(moWoSerial, serialQuantityMap.get(moWoSerial) + quantity);
                                } else {
                                    serialQuantityMap.set(moWoSerial, quantity);
                                }
                            }
                            actualfulfilledWeight+=quantity;
                        }
                        for (var x in soli) {
                            var soliItem = soli[x];
                            if(soliItem.ERP7__BoM__c){
                            	var moWoSerial = soliItem.ERP7__MO_WO_Serial__c;
                            	var bomQuantity = soliItem.ERP7__BoM__r.ERP7__Quantity__c;

                            	if (moWoSerial !== undefined && serialQuantityMap.has(moWoSerial)) {
                                	var totalQuantity = serialQuantityMap.get(moWoSerial);

                                	if (totalQuantity === bomQuantity) {
                                    	matchingSerialsSet.add(moWoSerial);
                                	}
                            	}
                            }
                        }console.log('matchingSerialsSet : ',matchingSerialsSet);
                        stockAssignedSerialIds = Array.from(matchingSerialsSet);
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
                    if(newUOM != '' && newUOM != undefined && oldUOM != '' && oldUOM != undefined && newUOM != oldUOM){
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
                                document.getElementById("cardTransition").classList.add("cardTransition");
                                break;
                            }
                        }

                        if(!conversionFound) {
                            var errMsgNew = $A.get('$Label.c.Conversion_values_between') + ' ' +oldUOM+ ' ' +$A.get('$Label.c.and')+ ' ' +newUOM+' ' +$A.get('$Label.c.not_found');
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
                                break;
                            }
                        }
                        if(!conversionFound) {
                            var errMsgNew = $A.get('$Label.c.Conversion_values_between') + ' '+oldUOM+' ' +$A.get('$Label.c.and')+ ' '+newUOM+' ' +$A.get('$Label.c.not_found');
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

    CaptureWeight: function(cmp, event){
        try{
            console.log('CaptureWeight called');
            var MO = cmp.get("v.manuOrder");
            const unchangedObj = JSON.parse(JSON.stringify(cmp.get("v.MRPs")));
            var obj = cmp.get("v.MRPs");
            var NewSOLI = cmp.get("v.NewSOLI");
            var WeightStr = document.getElementById("WeightStr").value;
            var doubleWeight = 0.00;
            if (typeof WeightStr === 'string' || WeightStr instanceof String) doubleWeight = Number(WeightStr.replace(/[^0-9\.]+/g,""));
            else doubleWeight = WeightStr;
            var weight = doubleWeight;
            var onlyweight = doubleWeight;

            /* console.log('doubleWeight : '+doubleWeight);
            console.log('weight : '+weight);
            console.log('onlyweight : '+onlyweight); */

            cmp.set("v.Weight",doubleWeight);
            cmp.set("v.WeightStr",doubleWeight);
            document.getElementById("WeightStr").value = doubleWeight;
            var TotalWeight = 0;
            var succeed = false;
            for(var x in obj){
                if(obj[x].isSelect){
                    obj[x].oldMRPQty = obj[x].MRP.ERP7__Fulfilled_Amount__c;
                    var oldUOM = obj[x].MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
                    var newUOM = obj[x].SelectedUOM;
                    var BbomUOM = obj[x].MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;

                    var UOMCs = cmp.get("v.UOMCs");
                    var conversionFound = false;
                    var newWeight = 0;
                    if(newUOM != oldUOM && weight >= 0){
                        //alert('get converted value from custom settings and evaluate');

                        for(var k in UOMCs){
                            if((UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM) || (UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM)){
                                conversionFound = true;
                                if(UOMCs[k].ERP7__From_UOM__c == oldUOM && UOMCs[k].ERP7__To_UOM__c == newUOM){
                                    newWeight = (UOMCs[k].ERP7__From_Value__c/UOMCs[k].ERP7__To_Value__c)*weight;
                                    //   alert('if newWeight: '+newWeight);
                                } else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == oldUOM){
                                    newWeight = (UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c)*weight;
                                    //   alert('else newWeight: '+newWeight);
                                }
                                weight = newWeight;
                                onlyweight = newWeight;
                                break;
                            }
                        }
                        if(!conversionFound) {
                            var errMsgNew = $A.get('$Label.c.Conversion_values_between') + ' ' +oldUOM+' ' +$A.get('$Label.c.and')+ ' '+newUOM+' ' +$A.get('$Label.c.not_found');
                            cmp.set("v.exceptionError",errMsgNew);
                            break;
                        }
                    }
                    else if(weight >= 0 && newUOM != BbomUOM){

                        for(var k in UOMCs){
                            if((UOMCs[k].ERP7__From_UOM__c == BbomUOM && UOMCs[k].ERP7__To_UOM__c == newUOM) || (UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == BbomUOM)){
                                conversionFound = true;
                                if(UOMCs[k].ERP7__From_UOM__c == BbomUOM && UOMCs[k].ERP7__To_UOM__c == newUOM){
                                    newWeight = (UOMCs[k].ERP7__From_Value__c/UOMCs[k].ERP7__To_Value__c)*weight;
                                    //alert('if BbomUOM newWeight: '+newWeight);
                                } else if(UOMCs[k].ERP7__From_UOM__c == newUOM && UOMCs[k].ERP7__To_UOM__c == BbomUOM){
                                    newWeight = (UOMCs[k].ERP7__To_Value__c/UOMCs[k].ERP7__From_Value__c)*weight;
                                    // alert('else BbomUOM newWeight: '+newWeight);
                                }
                                if(weight != newWeight){
                                    cmp.set("v.exceptionError",$A.get('$Label.c.Invalid_weight_to_capture'));
                                    return;
                                }

                            }
                        }
                    }

                    console.log('weight 1st : ',weight);
                    if(obj[x].ActualWeight != undefined) weight = parseFloat(weight) + parseFloat(obj[x].ActualWeight/obj[x].WeightMultiplier);//parseFloat(parseFloat(weight) + parseFloat(obj[x].ActualWeight/obj[x].WeightMultiplier)).toFixed(4);
                    // alert(weight);
                    var min = obj[x].MRP.ERP7__Expected_Quantity__c;
                    var max = obj[x].MRP.ERP7__Expected_Quantity__c;
                    //console.log('obj[x].MRP.ERP7__Expected_Quantity__c : ',obj[x].MRP.ERP7__Expected_Quantity__c);
                    var imin = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                    var imax = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                    if(obj[x].MRP.ERP7__Minimum_Variance__c != undefined && obj[x].MRP.ERP7__Minimum_Variance__c != "") min = obj[x].MRP.ERP7__Expected_Quantity__c - obj[x].MRP.ERP7__Minimum_Variance__c;
                    if(obj[x].MRP.ERP7__Maximum_Variance__c != undefined && obj[x].MRP.ERP7__Maximum_Variance__c != "") max = obj[x].MRP.ERP7__Expected_Quantity__c + obj[x].MRP.ERP7__Maximum_Variance__c;
                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c != undefined && obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c != "") imin = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c - obj[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c;
                    if(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c != undefined && obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c != "") imax = obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c + obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;

                    min = (min/obj[x].WeightMultiplier);
                    max = (max/obj[x].WeightMultiplier);
                    console.log('max : ',max);
                    imin = (imin/obj[x].WeightMultiplier);
                    imax = (imax/obj[x].WeightMultiplier);

                    var error = false;
                    var NewSOLI = cmp.get("v.NewSOLI");
                    console.log('NewSOLI : ',JSON.stringify(NewSOLI));
                    if(NewSOLI.ERP7__MO_WO_Serial__c != "" && NewSOLI.ERP7__MO_WO_Serial__c != undefined){
                        var quant1 = 0;
                        var quantin1 = 0;
                        //if(obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c){
                        quant1 = parseFloat(obj[x].MRP.ERP7__BOM__r.ERP7__Quantity__c);
                        console.log('quant1 :',quant1);
                        if(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant1 += parseFloat(obj[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c);
                        console.log('quant1 33:',quant1);
                        var SOLISM1 = obj[x].SOLIs;
                        for(var y in SOLISM1){
                            console.log('SOLISM1[y].ERP7__Quantity__c : ',SOLISM1[y].ERP7__Quantity__c);
                            if(SOLISM1[y].ERP7__MO_WO_Serial__c == NewSOLI.ERP7__MO_WO_Serial__c) quantin1 += parseFloat(SOLISM1[y].ERP7__Quantity__c);
                        }
                        //alert("already in 1 :"+quantin1);

                        // New Values quant1
                        quant1 = quant1/obj[x].WeightMultiplier;
                        //alert("already in after :"+quantin1);
                        if((quantin1 + onlyweight) > quant1) error = true;
                        //}
                    }

                    var weightCheck = weight; //weight.toFixed(4);
                    var onlyweightCheck = onlyweight;  //onlyweight.toFixed(4);
                    // alert(weight);
                    var selectedSerialNos = cmp.get("v.SerialsForAllocation");
                    var selectedSerialNos2Send = [];
                    for(var z in selectedSerialNos){
                        if(selectedSerialNos[z].SelectItem == true) {
                            selectedSerialNos2Send.push(selectedSerialNos[z].Id);
                        }
                    }

                    if((obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c == false && onlyweightCheck > 0 && weightCheck <= max) || (obj[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c == true && onlyweightCheck > 0 && onlyweightCheck <= imax && onlyweightCheck >= imin && weightCheck <= max)){
                        if((obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && (NewSOLI.ERP7__Serial__c == undefined || NewSOLI.ERP7__Serial__c == null || NewSOLI.ERP7__Serial__c == '')) || (obj[x].MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c && (NewSOLI.ERP7__Material_Batch_Lot__c == undefined || NewSOLI.ERP7__Material_Batch_Lot__c == null || NewSOLI.ERP7__Material_Batch_Lot__c == '')) || (MO.ERP7__Product__r.ERP7__Serialise__c && (NewSOLI.ERP7__MO_WO_Serial__c == undefined || NewSOLI.ERP7__MO_WO_Serial__c ==  null || NewSOLI.ERP7__MO_WO_Serial__c == '')) || (MO.ERP7__Product__r.ERP7__Lot_Tracked__c && (NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c == undefined || NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c == null || NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c == ''))){
                            cmp.set("v.exceptionError","Required fields missing");
                        }else if(obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && NewSOLI.ERP7__Serial__c != undefined && ((weight - obj[x].ActualWeight) > 1)){
                            cmp.set("v.exceptionError",$A.get('$Label.c.Serialised_product_invalid_quantity'));
                        }else if(error){
                            cmp.set("v.exceptionError",$A.get('$Label.c.Invalid_quantity_weight'));
                        }else if(selectedSerialNos.length > 0 && obj[x].MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == false && selectedSerialNos2Send.length == 0){
                            cmp.set("v.exceptionError",$A.get('$Label.c.Required_field_missing_Serial_Number'));
                        }
                            else{
                                //Changes Imran Khan 7/7/23
                                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");

                                console.log('weight~>'+weight);
                                console.log('ActualWeight~>'+obj[x].ActualWeight);
                                console.log('WeightMultiplier~>'+obj[x].WeightMultiplier);

                                console.log('before obj[x].MRP.ERP7__Fulfilled_Amount__c~>'+obj[x].MRP.ERP7__Fulfilled_Amount__c);

                                //alert('Total number of Serials Selected : '+selectedSerialNos2Send.length);
                                if(selectedSerialNos2Send.length > 0){
                                    if(obj[x].MRP.ERP7__Fulfilled_Amount__c >= 0) obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c + (weight - (obj[x].ActualWeight/obj[x].WeightMultiplier))*obj[x].WeightMultiplier*selectedSerialNos2Send.length);//parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c + (weight - obj[x].ActualWeight)*obj[x].WeightMultiplier*selectedSerialNos2Send.length);
                                    else obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat((weight - (obj[x].ActualWeight/obj[x].WeightMultiplier))*obj[x].WeightMultiplier*selectedSerialNos2Send.length);
                                }
                                else{
                                    if(obj[x].MRP.ERP7__Fulfilled_Amount__c >= 0) obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c + (weight - (obj[x].ActualWeight/obj[x].WeightMultiplier))*obj[x].WeightMultiplier);
                                    else obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat((weight - (obj[x].ActualWeight/obj[x].WeightMultiplier))*obj[x].WeightMultiplier);
                                }
                                //alert(obj[x].MRP.ERP7__Fulfilled_Amount__c);
                                console.log('after obj[x].MRP.ERP7__Fulfilled_Amount__c~>'+obj[x].MRP.ERP7__Fulfilled_Amount__c);

                                var soliQuantity = weight - (obj[x].ActualWeight/obj[x].WeightMultiplier); //  need to change
                                cmp.set("v.Weight",0);
                                cmp.set("v.exceptionError","");
                                NewSOLI.ERP7__Quantity__c = parseFloat(soliQuantity); //parseFloat(soliQuantity).toFixed(2);

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
                                        //cmp.popInit();
                                        console.log('response.getReturnValue() SaveNewSOLI : ',response.getReturnValue());
                                        if(response.getReturnValue().errorMsg != ''){
                                            cmp.set("v.exceptionError",response.getReturnValue().errorMsg);

                                            cmp.set("v.MRPs", unchangedObj);
                                            //if(obj[x].MRP.ERP7__Fulfilled_Amount__c > 0) obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c - (weight - obj[x].ActualWeight)*obj[x].WeightMultiplier);

                                            //console.log('after apex error thrown obj[x].MRP.ERP7__Fulfilled_Amount__c~>'+obj[x].MRP.ERP7__Fulfilled_Amount__c);

                                            //if(obj[x].MRP.ERP7__Fulfilled_Amount__c > 0) obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat(obj[x].MRP.ERP7__Fulfilled_Amount__c - (weight - obj[x].ActualWeight)*obj[x].WeightMultiplier);
                                            //else obj[x].MRP.ERP7__Fulfilled_Amount__c = parseFloat((weight - obj[x].ActualWeight)*obj[x].WeightMultiplier);
                                        }
                                        else {
                                            cmp.set("v.selectAllSerials",false);
                                            succeed = true;
                                            //obj[x].SOLIs = response.getReturnValue().SOLIs;

                                            cmp.set("v.WeightStr","0");
                                            cmp.set("v.NewSOLI.ERP7__Material_Batch_Lot__c", undefined);
                                            cmp.set("v.NewSOLI.ERP7__Serial__c", undefined);

                                            cmp.set("v.MRPs",response.getReturnValue().MRPs);
                                            cmp.set("v.moSerialNos",response.getReturnValue().moSerialNos);
                                            var ik = response.getReturnValue().MRPs;
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
                                                        //if(objm[x].MRP.ERP7__BOM__r.ERP7__Exact_Quantity__c){
                                                        quant = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                        if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) quant += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                                                        //alert("max in :"+quant);

                                                        var SOLISM = objm[x].SOLIs;
                                                        for(var y in SOLISM){
                                                            if(SOLISM[y].ERP7__MO_WO_Serial__c != '' && SOLISM[y].ERP7__MO_WO_Serial__c != undefined && NewSOLI.ERP7__MO_WO_Serial__c != '' && NewSOLI.ERP7__MO_WO_Serial__c != undefined && (SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                                                        }
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
                                                        if(SOLISMS[y].ERP7__MO_WO_Serial__c != '' && SOLISMS[y].ERP7__MO_WO_Serial__c != undefined && NewSOLI.ERP7__MO_WO_Serial__c != '' && NewSOLI.ERP7__MO_WO_Serial__c != undefined && (SOLISMS[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) qin += SOLISMS[y].ERP7__Quantity__c;
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
                                            else  if(NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c != "" && NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c != undefined){
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
                                                            if(SOLISM[y].ERP7__MO_WO_Material_Batch_Lot__c != '' && SOLISM[y].ERP7__MO_WO_Material_Batch_Lot__c != undefined && NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c != '' && NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c != undefined && (SOLISM[y].ERP7__MO_WO_Material_Batch_Lot__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Material_Batch_Lot__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                                                        }

                                                        if(quantin*objm[x].WeightMultiplier >= quant) cmp.set("v.WCAP",false);
                                                        //}
                                                    }
                                                }

                                                ////////////////////////////////////////////////////////
                                                for(var x in objm){
                                                    var q = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                    var qin = 0;
                                                    var qmin = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                    var qmax = objm[x].MRP.ERP7__BOM__r.ERP7__Quantity__c;
                                                    if(objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c > 0) qmax += objm[x].MRP.ERP7__BOM__r.ERP7__Maximum_Variance__c;
                                                    if(objm[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c > 0) qmin -= objm[x].MRP.ERP7__BOM__r.ERP7__Minimum_Variance__c;

                                                    var SOLISMS = objm[x].SOLIs;
                                                    for(var y in SOLISMS){
                                                        if(SOLISMS[y].ERP7__MO_WO_Serial__c != '' && SOLISMS[y].ERP7__MO_WO_Serial__c != undefined && NewSOLI.ERP7__MO_WO_Serial__c != '' && NewSOLI.ERP7__MO_WO_Serial__c != undefined && (SOLISMS[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) qin += SOLISMS[y].ERP7__Quantity__c;
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
                                        cmp.set('v.SelectedSerialsCount',0);
                                        cmp.loadSerialForAllocation();


                                    }
                                    else {
                                        var error = response.getError();
                                        console.log('error : ',error);
                                        if(error != undefined) cmp.set("v.exceptionError",error[0].message);
                                    }
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                });
                                $A.enqueueAction(action);
                            }
                    }
                    else {
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.set("v.exceptionError",$A.get('$Label.c.Invalid_weight_to_capture'));
                        cmp.set("v.MRPs", unchangedObj);
                    }
                }
            }
        } catch(err) {
            console.log("Exception : ",err);
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            cmp.set("v.MRPs", unchangedObj);
        }
    },

    upsertWeights: function(cmp, event) {
        try{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
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
                        cmp.popInit();
                    } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");;
                }
                //$A.util.removeClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
                //$A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(action);
        }
        catch(err) {
            //alert("Exception : "+err.message);
        }
    },

    NavRecord : function (component, event) {
        var RecId = event.target.getAttribute("title");
        //if(RecId=='') RecId = event.target.getAttribute("aura:id");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },

    NavWO : function (component, event) {
        if(component.get("v.allowNav")){
            var WOId = event.currentTarget.dataset.recordId;
            if(component.get("v.mosoliId") != null && component.get("v.mosoliId") != '' && component.get("v.mosoliId") != undefined){
                $A.createComponent("c:BuildSchedule_M",{
                    "WO":WOId,
                    "NAV":'mosoliId',
                    "RD":'yes',
                    "isFromMO":true,
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                });
            }
            else{

                $A.createComponent("c:BuildSchedule_M",{
                    "WO":WOId,
                    "NAV":'mo',
                    "RD":'yes',
                    "isFromMO":true,
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                });
            }
            /* var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:BuildSchedule_M",
                componentAttributes: {
                    "WO" : WOId,
                    "RD" : "yes",
                    "NAV": "mo"
                },
                isredirect : true
            });
            evt.fire();*/

        }
    },

    /*NavScheduler : function (component, event) {

        var RecUrl = "/apex/ERP7__ManufacturingSchedule";
        $A.get("e.force:navigateToURL").setParams(
            {"url": RecUrl}).fire();

        //window.location.href = '/apex/ERP7__ManufacturingSchedule';
    },*/

    DeleteRecordSOLI: function(cmp, event) {
        console.log('DeleteRecordSOLI called');
        var result = confirm("Are you sure?");
        var RecordId = event.getSource().get("v.name");
        var obj = cmp.get("v.MRPs");
        if (result) {
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
                            cmp.set("v.MRPs",response.getReturnValue().MRPs);
                            //cmp.set("v.NewSOLI",response.getReturnValue().NewSOLI);
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
                                        if(SOLISMS[y].ERP7__MO_WO_Serial__c == NewSOLI.ERP7__MO_WO_Serial__c) qin += SOLISMS[y].ERP7__Quantity__c;
                                    }
                                    if(qin*objm[x].WeightMultiplier >= qmin) PrintSB = true;
                                    else{
                                        PrintSB = false;
                                        break;
                                    }
                                }

                                //new code start. To get mo serials after deleting soli
                                var newSerials=response.getReturnValue().moSerialNos;
                                console.log('serials of mo after delting soli ',JSON.stringify(newSerials));
                                if(newSerials!==null && newSerials!==undefined && newSerials!==undefined && newSerials.length>0){
                                    cmp.set("v.moSerialNos",newSerials);
                                }
                                //new code end

                                cmp.set("v.PrintSB",PrintSB);
                            }
                            ////////////////////////////////////////////////////
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                        cmp.loadSerialForAllocation();
                    } else {
                        cmp.set("v.exceptionError",response.getReturnValue().errorMsg);
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

    NewMRP : function (cmp, event) {
        cmp.set("v.editErrorMsg","");
        var MO = cmp.get("v.manuOrder");
        var kk = cmp.get("v.NewMRP");
        if(kk.Name == null) kk.Name = "";
        kk.ERP7__BOM__c = "";
        kk.ERP7__Total_Amount_Required__c = "";
        kk.ERP7__Notes__c = "";
        //kk.ERP7__Consumed_Quantity__c = "";
        //kk.ERP7__Scrapped_Quantity__c = "";
        kk.ERP7__Work_Order__c = "";
        if(MO.Id != undefined) kk.ERP7__MO__c = MO.Id;
        var ik = JSON.stringify(kk);
        //alert(ik);
        cmp.set("v.NewMRP",kk);
        $A.util.addClass(cmp.find("newMRPModal"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
    },

    AutoStockAllocationInitial : function (cmp, event) {
        cmp.set("v.editErrorMsg","");
        var WOWs = cmp.get("v.WOWS");
        if(WOWs != undefined && WOWs.length > 0) WOWs[0].isSelect = true;
        /*
        for(var k in WOWs){
            WOWs[k].isSelect = true;
        }
        cmp.set("v.WOSSelectAll",true);
        */
        cmp.set("v.WOWS",WOWs);
        $A.util.addClass(cmp.find("selectWOsModal"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myselectWOsModalBackdrop"),"slds-backdrop_open");
    },

    AutoStockAllocationSelectAll : function (cmp, event) {
        var WOWs = cmp.get("v.WOWS");
        for(var k in WOWs){
            WOWs[k].isSelect = cmp.get("v.WOSSelectAll");
        }
        cmp.set("v.WOWS",WOWs);
    },

    EditMRPNew : function (cmp, event) {
        cmp.set("v.editErrorMsg","");
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

  /* updateNewMRP : function (cmp, event) {
       try{
    $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
    var MRP = cmp.get("v.NewMRP");
    var ik = JSON.stringify(MRP);
    var error = false;
    if(   MRP.ERP7__MRP_Product__c == undefined || MRP.ERP7__MRP_Product__c == "" || 
       MRP.ERP7__Total_Amount_Required__c == undefined || MRP.ERP7__Total_Amount_Required__c == "" || 
       MRP.ERP7__Work_Order__c == undefined || MRP.ERP7__Work_Order__c == "" ) {
        error = true;
        cmp.set('v.editErrorMsg', $A.get('$Label.c.Required_fields_missing'));
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    } else {
        var action = cmp.get("c.MRPNewUpdate1");
        action.setParams({
            MRP1: JSON.stringify(MRP)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.editErrorMsg", response.getReturnValue().errorMsg);
                if(response.getReturnValue().errorMsg == '') {
                    $A.util.removeClass(cmp.find("newMRPModal"), 'slds-fade-in-open');
                    $A.util.removeClass(cmp.find("myMRPModalBackdrop"), "slds-backdrop_open");
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    cmp.popInit();
                } else {
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    }}catch(e){console.log('eception on mrp update',e);}
},*/
    updateNewMRP: function (cmp, event) {
    try {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var MRP = cmp.get("v.NewMRP");
        var error = false;
        
        // Check for required fields and validate quantity
        if (MRP.ERP7__MRP_Product__c == undefined || MRP.ERP7__MRP_Product__c == "" || 
            MRP.ERP7__Total_Amount_Required__c == undefined || MRP.ERP7__Total_Amount_Required__c == "" || 
            MRP.ERP7__Work_Order__c == undefined || MRP.ERP7__Work_Order__c == "" ||
            MRP.ERP7__Total_Amount_Required__c <= 0) {
            
            error = true;
            let errorMsg = MRP.ERP7__Total_Amount_Required__c <= 0 
                ? 'Quantity required must be greater than zero'
                : $A.get('$Label.c.Required_fields_missing');
            cmp.set('v.editErrorMsg', errorMsg);
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        } else {
            var action = cmp.get("c.MRPNewUpdate1");
            action.setParams({
                MRP1: JSON.stringify(MRP)
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.editErrorMsg", response.getReturnValue().errorMsg);
                    if(response.getReturnValue().errorMsg == '') {
                        $A.util.removeClass(cmp.find("newMRPModal"), 'slds-fade-in-open');
                        $A.util.removeClass(cmp.find("myMRPModalBackdrop"), "slds-backdrop_open");
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        cmp.popInit();
                    } else {
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    } catch(e) {
        console.log('exception on mrp update', e);
    }
},

    goBack : function(component,event,helper){
        window.history.back();
    },

    Nav2Epos : function(cmp, event, helper) {
        var SO = event.currentTarget.getAttribute('data-mosoliId');

        $A.createComponent("c:OrderConsole",{
            "SON" : SO
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });


        // window.history.back();
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

                    var SOLISM = objm[x].SOLIs;
                    for(var y in SOLISM){
                        if((SOLISM[y].ERP7__MO_WO_Serial__c).substr(0, 15) == (NewSOLI.ERP7__MO_WO_Serial__c).substr(0, 15)) quantin += SOLISM[y].ERP7__Quantity__c;
                    }
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
                    if(SOLISMS[y].ERP7__MO_WO_Serial__c == NewSOLI.ERP7__MO_WO_Serial__c) qin += SOLISMS[y].ERP7__Quantity__c;
                }
                if(qin*objm[x].WeightMultiplier >= qmin) PrintSB = true;
                else{
                    PrintSB = false;
                    break;
                }
            }
            /*
            var NewSOLIK = cmp.get("v.NewSOLI");
            NewSOLIK.ERP7__Material_Batch_Lot__c = undefined;
            NewSOLIK.ERP7__Serial__c = undefined;
            alert(NewSOLIK.ERP7__Serial__c);
            alert(NewSOLIK.ERP7__Material_Batch_Lot__c);
            cmp.set("v.NewSOLI", NewSOLIK);
            */

            cmp.set("v.PrintSB",PrintSB);
        }
    },

    handleSignatureEvent: function(cmp, event) {
        var Attachments = event.getParam("Attachments");
        var manuOrder = cmp.get("v.manuOrder");
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.GetAttachments");
        action.setParams({MOId:manuOrder.Id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            cmp.set("v.errorMsg", "");
            if (state === "SUCCESS") {
                //cmp.popInit();
                cmp.set("v.SelectedAttachments", response.getReturnValue());
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            } else{
                cmp.set("v.errorMsg", response.getError());
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },

    showSignature: function(cmp, event) {
        document.getElementById("sigbody").style.visibility = "visible";
        cmp.set("v.sigTab", true);
    },

    hideSignature: function(cmp, event) {
        cmp.set("v.sigTab", false);
    },

    tab1 : function(component, event, helper) {
        component.set("v.MRPSTab",true);
        component.set("v.workOrderTab",false);
        component.set("v.finishedProductsTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
        component.set("v.qualityCheckTab",false);
        //component.set('v.moSerialNosShow', "10");
        //component.set('v.WipflowsShow', "10");
    },

    tab2 : function(component, event, helper) {
        component.set("v.MRPSTab",false);
        component.set("v.workOrderTab",true);
        component.set("v.finishedProductsTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
        component.set("v.qualityCheckTab",false);
        //component.set('v.moSerialNosShow', "10");
        //component.set('v.WipflowsShow', "10");
    },

    tab3 : function(component, event, helper) {
        component.set("v.MRPSTab",false);
        component.set("v.workOrderTab",false);
        component.set("v.finishedProductsTab",true);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",false);
        component.set("v.qualityCheckTab",false);
        //component.set('v.moSerialNosShow', "10");
        //component.set('v.WipflowsShow', "1000");

    },

    tab4 : function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get('c.getSerialNumbers');
        action.setParams({'offsetVal' : 0,'Mo' : component.get('v.manuOrder.Id')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            // alert(state);
            if (state === "SUCCESS") {
                //var startNew = parseInt(start) + 100;
                // var endNew = parseInt(end) + 100;
                // component.set('v.moSerialNosShowStart', startNew);
                // component.set('v.moSerialNosShow', endNew);
                component.set('v.AllmoSerialNos', response.getReturnValue());
                component.set('v.StartNo',parseInt(1));
                if(component.get('v.AllmoSerialNos') != undefined && component.get('v.AllmoSerialNos') != null && component.get('v.AllmoSerialNos') != '') component.set('v.EndNum',component.get('v.AllmoSerialNos').length);
                component.set("v.MRPSTab",false);
                component.set("v.workOrderTab",false);
                component.set("v.finishedProductsTab",false);
                component.set("v.serialorBatchesTab",true);
                component.set("v.signatureTab",false);
                component.set("v.qualityCheckTab",false);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);

        /*
        component.set('v.WipflowsShow', "300");
        component.set('v.moSerialNosShow', "1000");
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        */
    },

    tab5 : function(component, event, helper) {
        component.set("v.MRPSTab",false);
        component.set("v.workOrderTab",false);
        component.set("v.finishedProductsTab",false);
        component.set("v.serialorBatchesTab",false);
        component.set("v.signatureTab",true);
        component.set("v.qualityCheckTab",false);
        //component.set('v.moSerialNosShow', "10");
        //component.set('v.WipflowsShow', "10");
    },
    tabQA :  function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get('c.getStockinwards');
        action.setParams({'offsetVal' : 0,'MoId' : component.get('v.manuOrder.Id')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            // alert(state);
            if (state === "SUCCESS") {
                console.log('response.getReturnValue() : ',response.getReturnValue());
                if(response.getReturnValue() != null) component.set("v.ExistingSILI",response.getReturnValue());
                component.set("v.MRPSTab",false);
                component.set("v.workOrderTab",false);
                component.set("v.finishedProductsTab",false);
                component.set("v.serialorBatchesTab",false);
                component.set("v.signatureTab",false);
                component.set("v.qualityCheckTab",true);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);

    },
    displayWIPFlowsNext : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var obj = component.get("v.Wipflows");
        var start = component.get('v.WipflowsShowStart');
        var end = component.get('v.WipflowsShow');
        var action = component.get('c.getWIPFlows');
        action.setParams({'offsetVal' : parseInt(start + 100),'Mo' : component.get('v.manuOrder.Id')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var startNew = parseInt(start) + 100;
                var endNew = parseInt(end) + 100;
                component.set('v.WipflowsShowStart', startNew);
                component.set('v.WipflowsShow', endNew);
                component.set('v.Wipflows', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },

    displayWIPFlowsPrevious : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var obj = component.get("v.Wipflows");
        var start = component.get('v.WipflowsShowStart');
        var end = component.get('v.WipflowsShow');
        var action = component.get('c.getWIPFlows');
        action.setParams({'offsetVal' : parseInt(start - 100),'Mo' : component.get('v.manuOrder.Id')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var startNew = parseInt(start) - 100;
                var endNew = parseInt(end) - 100;
                component.set('v.WipflowsShowStart', startNew);
                component.set('v.WipflowsShow', endNew);
                component.set('v.Wipflows', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },

    displaySerialsNext : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var obj = component.get("v.AllmoSerialNos");
        //console.log('obj : ',obj.length);
        var start = component.get('v.moSerialNosShowStart');
        var end = component.get('v.moSerialNosShow');
        // var action = component.get('c.getSerialNumbers');
        // action.setParams({'offsetVal' : parseInt(start + 100),'Mo' : component.get('v.manuOrder.Id')});
        //  action.setCallback(this, function(response) {
        //     var state = response.getState();
        //     if (state === "SUCCESS") {
        var startNew = parseInt(start) + 100;
        var endNew = parseInt(end) + 100;
        component.set('v.moSerialNosShowStart', startNew);
        component.set('v.moSerialNosShow', endNew);
        // console.log('moSerialNosShowStart : ',component.get('v.moSerialNosShowStart'));
        // console.log('moSerialNosShow : ',component.get('v.moSerialNosShow'));
        // component.set('v.AllmoSerialNos', response.getReturnValue());
        // }
        //   });
        //  $A.enqueueAction(action);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },

    displaySerialsPrevious : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var obj = component.get("v.AllmoSerialNos");
        var start = component.get('v.moSerialNosShowStart');
        var end = component.get('v.moSerialNosShow');
        //  var action = component.get('c.getSerialNumbers');
        //  action.setParams({'offsetVal' : parseInt(start - 100),'Mo' : component.get('v.manuOrder.Id')});
        //  action.setCallback(this, function(response) {
        //    var state = response.getState();
        //    if (state === "SUCCESS") {
        var startNew = parseInt(start) - 100;
        var endNew = parseInt(end) - 100;
        component.set('v.moSerialNosShowStart', startNew);
        component.set('v.moSerialNosShow', endNew);
        // component.set('v.AllmoSerialNos', response.getReturnValue());
        // }
        // });
        //  $A.enqueueAction(action);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },

    closeStockAllocationModal : function (cmp,event) {
        var versionId = cmp.get('v.Version.Id');
        var versionName = cmp.get('v.Version.Name');
        var routing1 = cmp.get('v.Routing')

        cmp.set("v.saPage",false);
        window.scrollTo(0, 0);

        cmp.set("v.Version",{Id : versionId, Name : versionName});
        cmp.set("v.Routing",routing1);

        //cmp.set("v.moSerialNos", []);
        //cmp.set('v.Wipflows', []);
        //$A.get('e.force:refreshView').fire();
        //cmp.popInit();
        //cmp.popMRPDetails();
        // $A.util.removeClass(cmp.find("stockAllocationModal"), 'slds-fade-in-open');
        //$A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
    },

    closeNewMRPModal : function (cmp,event) {
        $A.util.removeClass(cmp.find("newMRPModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
        cmp.popInit();
    },

    closeEditMRPModal : function (cmp,event) {
        $A.util.removeClass(cmp.find("editMRPModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myMRPModalBackdrop"),"slds-backdrop_open");
                cmp.popInit();
    },

    closeMyModalSerial : function (cmp,event) {
        $A.util.removeClass(cmp.find("myModalSerial"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("mySerialModalBackdrop"),"slds-backdrop_open");
    },

    closeMyModalMOSerial : function (cmp,event) {
        $A.util.removeClass(cmp.find("myModalMOSerial"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("mySerialModalBackdrop"),"slds-backdrop_open");
    },

    closeMyModalMOBatch : function (cmp,event) {
        $A.util.removeClass(cmp.find("myModalMOBatch"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myBatchModalBackdrop"),"slds-backdrop_open");
    },
    closeError : function (cmp,event) {
        cmp.set("v.exceptionError",'');

    },

    closeSelectWOsModal : function (cmp,event) {
        //cmp.set("v.showAllocationModal",false);
        $A.util.removeClass(cmp.find("selectWOsModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myselectWOsModalBackdrop"),"slds-backdrop_open");
        cmp.popInit();
    },

   /* cancelAction : function (cmp,event) {
        var navi = cmp.get("v.NAV");
        var urlEvent = $A.get("e.force:navigateToURL");
        if(navi == 'mp'){
            urlEvent.setParams({
                "url": "/lightning/n/ERP7__Work_Center_Capacity_Planning"
            });

        }
        else if(navi == 'ms'){
            urlEvent.setParams({
                "url": "/apex/ERP7__ManufacturingSchedule"
            });
        }
            else if(navi == 'scheduler'){
                urlEvent.setParams({
                    "url": "/lightning/n/ERP7__Schedular"
                });
            }
                else if(navi == 'mb'){
                    urlEvent.setParams({
                        "url": "/lightning/n/ERP7__Manufacturing_Builder"
                    });
                }
                    else if(navi == 'invManage'){
                        console.log('invManage');
                       urlEvent.setParams({
                        "url": "/lightning/n/ERP7__Inventory_Management_Report"
                    });
                    }
        urlEvent.fire();
    },
    */
    cancelAction: function (cmp, event) {
        var navi = cmp.get("v.NAV");
        if (navi) {
            if (navi === 'mp') {
                window.location.href = "/lightning/n/ERP7__Work_Center_Capacity_Planning";
            } else if (navi === 'ms') {
                window.location.href = "/apex/ERP7__ManufacturingSchedule";
            } else if (navi === 'scheduler') {
                window.location.href = "/lightning/n/ERP7__Schedular";
            } else if (navi === 'mb') {
                window.location.href = "/lightning/n/ERP7__Manufacturing_Builder";
            } else if (navi === 'invManage') {
                console.log('invManage');
                window.location.href = "/lightning/n/ERP7__Inventory_Management_Report";
            }
        } else {
            window.history.back(); // Fallback to navigate back to previous page
        }
    },
    menuAction :  function (cmp,event,helper) {
        var selectedMenuid = event.detail.menuItem.get("v.value");
        var selectedMenu = event.detail.menuItem.get("v.label");
        console.log('selectedMenu : ',selectedMenu);
        switch(selectedMenu) {
            case $A.get('$Label.c.Create_Manufacturing_Order'):
                helper.CreateMO(cmp,event,selectedMenuid);
                break;
            case $A.get('$Label.c.Create_Purchase_Order'):
                helper.CreatePO(cmp,event,selectedMenuid);
                break;
            case $A.get('$Label.c.Create_Purchase_Requisition'):
                helper.CreatePR(cmp,event,selectedMenuid);
                break;
        }
    },
    /* generateSerialNumbers :  function(cmp, event,helper){
        try{

            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var fromval = cmp.get('v.FromSerialNum');
            console.log('fromval : ',fromval);
            var prefix = cmp.get('v.SerialPrefix');
            console.log('prefix : ',prefix);
            var startNum = parseInt(cmp.get('v.StartNo')) - parseInt(1);
            if(fromval != null && fromval != 0 && fromval != undefined && prefix != null && prefix != undefined && prefix != ''){
                var allSerials = cmp.get('v.AllmoSerialNos');
                var x = startNum;
                var serialIds = [];
                for(var x in allSerials){
                    if(x == cmp.get('v.EndNum')) break;
                    else{
                        serialIds.push(allSerials[x].Id);
                    }
                }
                console.log('serialIds : ',serialIds);
                var action = cmp.get("c.setSerials");
                action.setParams({ startNum : fromval,MOId : cmp.get('v.manuOrder.Id'),serPrefix :prefix ,startFrom :startNum,EndNo : cmp.get('v.EndNum') ,serialsId : serialIds});
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        if(response.getReturnValue() != null){
                            console.log('response.getReturnValue() : ',response.getReturnValue());
                            let result = response.getReturnValue();
                            if(result.includes('Duplicate') || result.includes('Error') || result.includes('duplicate') || result.includes('Failed')){
                                cmp.set('v.exceptionError',result);
                            }
                            else {
                                let actualResult = JSON.parse(result);
                                cmp.set('v.Wipflows',actualResult.wipflows);
                                cmp.set('v.AllmoSerialNos',actualResult.moSerialNos);
                                //cmp.set("v.SILIs", actualResult.SILIs);
                                helper.showToast('Success','success','Serial number generated Successfully');
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
                if(fromval == null || fromval == 0 || fromval == undefined) cmp.set('v.exceptionError','Please enter from value to generate serial Numbers');
                else cmp.set('v.exceptionError','Please enter Prefix to generate serial Numbers');
            }
        }
        catch(e){
            console.log('Error catch : ',e);
        }
    }, */
    generateSerialNumbers: function(cmp, event, helper) {
        try {
            const mainSpin = cmp.find('mainSpin');
            $A.util.removeClass(mainSpin, "slds-hide");

            const fromval = cmp.get('v.FromSerialNum');
            console.log('fromval:', fromval);

            const prefix = cmp.get('v.SerialPrefix');
            console.log('prefix:', prefix);

            const startNum = parseInt(cmp.get('v.StartNo')) - 1;

            if (fromval && prefix) {
                cmp.set('v.RefreshSerials',false);
                const allSerials = cmp.get('v.AllmoSerialNos');
                const updatedSerials = [];
                var numericValue = parseInt(fromval);
                for (let i = startNum; i < cmp.get('v.EndNum'); i++) {
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
                console.log('updatedSerials:', updatedSerials);
                var action = cmp.get("c.setSerials");
                action.setParams({MOId : cmp.get('v.manuOrder.Id'),serialsList : JSON.stringify(updatedSerials)});
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        if(response.getReturnValue() != null){
                            console.log('response.getReturnValue() : ',response.getReturnValue());
                            let result = response.getReturnValue();
                            if(result.includes('Duplicate') || result.includes('Error') || result.includes('duplicate') || result.includes('Failed')){
                                cmp.set('v.exceptionError',result);
                            }
                            else {

                                cmp.set('v.AllmoSerialNos',allSerials);
                                cmp.set('v.RefreshSerials',true);
                                //cmp.set("v.SILIs", actualResult.SILIs);
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

            } else {
                $A.util.addClass(mainSpin, "slds-hide");
                cmp.set('v.exceptionError', fromval ? $A.get('$Label.c.Please_enter_Prefix_to_generate_serial_Numbers') :$A.get('$Label.c.Please_enter_from_value_to_generate_serial_Numbers'));
            }
        } catch (e) {
            console.log('Error catch:', e);
        }
    },

    EvaluteMRPQty : function(cmp, event,helper){
        var MRPId = event.getSource().get('v.title');
        if(MRPId != '' && MRPId != undefined && MRPId != null){
            var val = event.getSource().get('v.value');
            if(val > 0){
                var obj = cmp.get('v.MRPs');
                for(var x in obj){
                    if(obj[x].MRP.Id == MRPId){
                        if(val > 0 && (val > (obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c))){
                            obj[x].MRPQuantity = (obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c );
                            cmp.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_greater_than')+' : '+(obj[x].MRP.ERP7__Total_Amount_Required__c - obj[x].MRP.ERP7__Fulfilled_Amount__c ));
                            break;
                        }
                        else if(val > 0 && val > (obj[x].Stock * obj[x].WeightMultiplier)){
                            obj[x].MRPQuantity = obj[x].Stock * obj[x].WeightMultiplier;
                            cmp.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_greater_than')+' : '+(obj[x].MRP.Stock * obj[x].WeightMultiplier));
                            break;
                        }

                    }
                }
                cmp.set('v.MRPs',obj);
            }
            else{
                cmp.set('v.exceptionError',$A.get('$Label.c.Enter_Quantity'));
            }

        }

    },
    closePOConfirmModal : function(component,event,helper){
        $A.util.removeClass(component.find("POConfirmModalShow"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("POConfirmModalBackdrop"),"slds-backdrop_open");
    },
    createMultiplePO  : function(component,event,helper){
        var MO = component.get("v.manuOrder");
        var soliId = MO.Id;
        $A.createComponent("c:MultiplePurchaseOrders",{
            "MOId":soliId,
            "FromMO":true
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    createSinglePO : function(component,event,helper){
        var MO = component.get("v.manuOrder");
        var soliId = MO.Id;
        $A.createComponent("c:CreatePurchaseOrder",{
            "MOId":soliId,
            "cancelclick":component.getReference("c.backMO"),
            "showPOType" : false
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    getSelectedMRP : function(component,event,helper){
        var mrpId = event.getSource().get('v.title');
        console.log('mrpId : ',mrpId);
        if(mrpId != null && mrpId != '' && mrpId != undefined){
            var checkedval = event.getSource().get('v.checked');
            var selectedMRPs = component.get('v.selectedMRPstoDelete');
            if(checkedval) selectedMRPs.push(mrpId);
            else {
                const index = selectedMRPs.indexOf(mrpId);
                console.log('index : ',index);
                const x = selectedMRPs.splice(index, 1);
            }
            component.set('v.selectedMRPstoDelete',selectedMRPs);
        }
    },
    deleteMRPs : function(component,event,helper){
        var mrpId = event.getSource().get('v.title');
        console.log('mrpId : ',mrpId);
        if(mrpId != null && mrpId != '' && mrpId != undefined){
            var MRP2delete = [];
            MRP2delete.push(mrpId);
            var confirmdelete = confirm($A.get('$Label.c.Are_you_sure_you_want_to_delete'));
            if(confirmdelete){
                helper.deleteMRPs(component,MRP2delete);
            }
        }
    },
    deleteAllMRPs : function(component,event,helper){
        var selectedMRPs = component.get('v.selectedMRPstoDelete');
        if(selectedMRPs != undefined && selectedMRPs.length > 0){
            var confirmdelete = confirm($A.get('$Label.c.Are_you_sure_you_want_to_delete'));
            if(confirmdelete){
                helper.deleteMRPs(component,selectedMRPs);
            }
        }
        else{
            helper.showToast($A.get('$Label.c.warning_UserAvailabilities'),'warning',$A.get('$Label.c.No_Item_Selected'));
        }

    },
    onControllerFieldChange: function(component, event, helper) {
        try{
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
        }catch(e){
            console.log('err',JSON.stringify(e));
        }
    },
    handleStatusChange : function (component, event,helper) {
        try{
            var statusval = event.getSource().get('v.value');
            console.log('statusval : ',statusval);
            var siliId = event.getSource().get('v.name');
            console.log('siliId : ',siliId);
            let receivedsili = component.get('v.ExistingSILI');
            var err = false;
            component.set('v.exceptionError','');

            console.log('InStockPickListValue : ',$A.get('$Label.c.InStockPickListValue'));
            console.log('PassedChecklistValue : ',$A.get('$Label.c.PassedChecklistValue'));

            console.log('enableQA~>'+component.get('v.enableQA'));
            if(component.get('v.enableQA')){

                for(var y in receivedsili){
                    if(receivedsili[y].guideline != null && receivedsili[y].guideline != undefined){
                        console.log('1 2 : ');
                        let qualityChecks =  receivedsili[y].guideline;
                        console.log('1 23  : ',JSON.stringify(qualityChecks));
                        for(var x in qualityChecks){
                            if(qualityChecks[x].ERP7__Stock_Inward_Line_Item__c == siliId && statusval == $A.get('$Label.c.InStockPickListValue') && qualityChecks[x].ERP7__Checklist__r.ERP7__Is_Mandatory__c){
                                console.log('qualityChecks[x].ERP7__Instructions__c : ',qualityChecks[x].ERP7__Instructions__c);
                                if(qualityChecks[x].ERP7__Instructions__c == '' || qualityChecks[x].ERP7__Instructions__c == null || qualityChecks[x].ERP7__Instructions__c == undefined || qualityChecks[x].ERP7__Instructions__c == '--None--'){
                                    component.set('v.exceptionError',$A.get('$Label.c.CompleteMandatoryChecklist'));
                                    err = true;
                                    break;
                                }else if(qualityChecks[x].ERP7__Instructions__c != $A.get('$Label.c.PassedChecklistValue')){
                                    component.set('v.exceptionError',$A.get('$Label.c.MandatoryChecklistpassed'));
                                    err = true;
                                    break;
                                }
                            }
                        }
                        console.log('err : ',err);
                        if(err){
                            if(receivedsili[y].sili.Id == siliId){
                                receivedsili[y].sili.ERP7__Status__c = 'Quality Check(QA)';
                            }
                        }
                    }

                }
                component.set('v.ExistingSILI',receivedsili);
            }

        }catch(e){
            console.log('catch err occured~>'+e);
        }

    },
    onFileUploadedQAGuideLines : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        try{
            var sourcevalue = event.getSource();
            if (sourcevalue!=null && sourcevalue!=undefined) {
                if(event.getSource().get("v.files")!=null && event.getSource().get("v.files").length > 0){
                    component.set("v.FileListforQAguidelines", event.getSource().get("v.files"));
                    let files = component.get("v.FileListforQAguidelines");
                    console.log('FileListforQAguidelines : ',FileList);
                    let fileNameList = [];
                    let base64DataList = [];
                    let contentTypeList = [];

                    if (files && files.length > 0) {
                        let parentId = event.getSource().get("v.name");
                        console.log('files : ',files.length);
                        console.log('files[0] : ',files[0].length);
                        if(files[0].length > 0){
                            for (let i = 0; i < files[0].length; i++) {
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
                                        helper.finishAllFilesUploadforQAguidelines(parentId,fileNameList,base64DataList,contentTypeList,component,event,helper);
                                    }else console.log('notequal');
                                }
                                reader.onerror = function() {
                                    console.log('for i~>'+i+' err~>'+reader.error);
                                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                };
                                reader.readAsDataURL(file);
                            }
                        }
                    }
                }
            }
        }catch(err){
            console.log("Error catch:",err);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }

    },
    SaveChecklists : function(component,event){
        let allsili = component.get('v.ExistingSILI');
        for(var i in allsili){
            if(allsili[i].guideline != null){
                let checklists = allsili[i].guideline;
                for(var x in checklists){
                    console.log('checklists[x]~>'+JSON.stringify(checklists[x]));
                    if(checklists[x].ERP7__Checklist__r.ERP7__Is_Mandatory__c){
                        if(checklists[x].ERP7__Checklist__r.ERP7__Has_Checklist__c && (checklists[x].ERP7__Instructions__c == null || checklists[x].ERP7__Instructions__c == undefined || checklists[x].ERP7__Instructions__c == '')){
                            component.set("v.exceptionError", $A.get('$Label.c.CompleteMandatoryChecklist'));
                            return;
                        }
                    }
                    if(checklists[x].hasOwnProperty('Attachments')){
                        delete checklists[x].Attachments;
                    }
                }
            }
        }
        var action = component.get('c.saveAlldetail');
        action.setParams({createdsili : JSON.stringify(allsili) });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() === 'Success'){
                    component.tabQA();
                }
                else {
                    console.log('error : ',response.getError());
                }
            }
        });
        $A.enqueueAction(action);
    },
    



})