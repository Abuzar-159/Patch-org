({
    getAllDetails : function(cmp, event, helper) {
        var logIds = cmp.get("v.logisticIds");
        var logisticIds = logIds.split(",");
        var LIds = JSON.stringify(logisticIds);
        //alert('logisticIds : '+LIds);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        
        var action = cmp.get("c.redirect2NextTab");
        action.setParams({LogisticIds:LIds});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                
                if(response.getReturnValue().soliWrapperList.length == 0 && cmp.get("v.navToPack")) {
                    console.log('packs 1');
                    cmp.createPacks();
                    console.log('packs 2');
                }
                
                console.log('success getAllDetails Pick : ',response.getReturnValue());
                cmp.set("v.PreventChange", true);
                //cmp.set("v.Container", response.getReturnValue());
                cmp.set("v.SiteName", response.getReturnValue().SiteName);
                cmp.set("v.Scanflow", response.getReturnValue().Allowscanning);
                cmp.set('v.showStockAddress',response.getReturnValue().displayStockAddress);
                cmp.set("v.ChannelName", response.getReturnValue().ChannelName);
                cmp.set("v.ChannelId", response.getReturnValue().ChannelId);
                cmp.set("v.Logistics", response.getReturnValue().LogisticRecs);
                console.log('soliWrapperList~>'+JSON.stringify(response.getReturnValue().soliWrapperList));
                cmp.set("v.soliWrapperList", response.getReturnValue().soliWrapperList);
                cmp.set("v.SerialIds2Exempt", response.getReturnValue().SerialIds2Exempt);
                cmp.set("v.stockMap", response.getReturnValue().stockMap);
                cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                cmp.set("v.showSN", response.getReturnValue().showSN);
                cmp.set("v.showBatch", response.getReturnValue().showBatch);
                cmp.set("v.barcodeLocMsg", response.getReturnValue().barcodeLocMsg);
                cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                cmp.set("v.PreventChange", false);
                cmp.set("v.initialSTOLISerial", "");
                
                cmp.set('v.BarcodeLabelhidden',response.getReturnValue().hideBarcodeLabel);
                cmp.set('v.ShowLangOptionForPickSlip',response.getReturnValue().ShowLangOptionForPickSlip);
                console.log('ShowLangOptionForPickSlip:',cmp.get('v.ShowLangOptionForPickSlip'));
                cmp.set('v.ReplacePickSlipOrgURL',response.getReturnValue().ReplacePickSlipOrgURL);
                
                
                
                //New code added by Arshad 18 Sep 2023 - to avoid heap size
                try{
                    console.log('commitedSOLIIdsList ~>',response.getReturnValue().commitedSOLIIdsList);
                    var commitedSOLIIdsList = [];
                    commitedSOLIIdsList = response.getReturnValue().commitedSOLIIdsList;
                    
                    console.log('commitedSOLIIdsList typeof~>'+typeof commitedSOLIIdsList);
                    console.log('commitedSOLIIdsList legnth~>'+commitedSOLIIdsList.length);
                    
                    if(commitedSOLIIdsList.length > 0){
                        console.log('inhere commitedSOLIIdsList');
                        
                        var myaction = cmp.get("c.getcommitedSOLIs");
                        myaction.setParams({
                            "soliIds": JSON.stringify(commitedSOLIIdsList),
                        });
                        myaction.setCallback(this, function(resp){
                            if(resp.getState() === "SUCCESS"){
                                console.log("doInit getcommitedSOLIs: ",resp.getReturnValue());
                                console.log("doInit getcommitedSOLIs length: ",resp.getReturnValue().length);
                                cmp.set('v.soliExistingList',resp.getReturnValue());
                                console.log('inhere after setting soliExistingList');
                                
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            }else{
                                var errors = resp.getError();
                                console.log("server error in getcommitedSOLIs : ", JSON.stringify(errors));
                                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                            } 
                        });
                        $A.enqueueAction(myaction);
                    }else{
                        console.log('inelse commitedSOLIIdsList');
                       console.log('event --'+JSON.stringify(event.getSource()));
                        //helper.fetchStocks(cmp, event, helper, -1);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }catch(e){
                    console.log('err~>'+e);
                    console.log('err occured commitedSOLIIdsList~>'+JSON.stringify(e));
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
                
                //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }else{
                var errors = response.getError();
                console.log("redirect2NextTab server error : ", errors);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    
    //added by Arshad 18 Sep 2023
    PreviousCommittedSOLI : function (component, event, helper) {
        try{
            console.log('PreviousCommittedSOLI called');
            var startIndexCommittedSOLI = component.get("v.startIndexCommittedSOLI");
            console.log('before start~>'+startIndexCommittedSOLI);
            startIndexCommittedSOLI -= 100;
            console.log('after start~>'+startIndexCommittedSOLI+' typeof~>'+typeof startIndexCommittedSOLI);
            component.set("v.startIndexCommittedSOLI",startIndexCommittedSOLI);
            
            var endIndexCommittedSOLI = component.get("v.endIndexCommittedSOLI");
            console.log('before end~>'+endIndexCommittedSOLI);
            endIndexCommittedSOLI -= 100;
            console.log('after end~>'+endIndexCommittedSOLI+' typeof~>'+typeof endIndexCommittedSOLI);
            component.set("v.endIndexCommittedSOLI",endIndexCommittedSOLI);
        }catch(e){
            console.log('err PreviousCommittedSOLI~>'+e);
        }
        
    },
    
    //added by Arshad 18 Sep 2023
    NextCommittedSOLI : function (component, event, helper) {
        try{
            console.log('NextCommittedSOLI called');
            var startIndexCommittedSOLI = component.get("v.startIndexCommittedSOLI");
            console.log('before start~>'+startIndexCommittedSOLI);
            startIndexCommittedSOLI += 100;
            console.log('after start~>'+startIndexCommittedSOLI+' typeof~>'+typeof startIndexCommittedSOLI);
            component.set("v.startIndexCommittedSOLI",startIndexCommittedSOLI);
            
            var endIndexCommittedSOLI = component.get("v.endIndexCommittedSOLI");
            console.log('before end~>'+endIndexCommittedSOLI);
            endIndexCommittedSOLI += 100;
            console.log('after end~>'+endIndexCommittedSOLI+' typeof~>'+typeof endIndexCommittedSOLI);
            component.set("v.endIndexCommittedSOLI",endIndexCommittedSOLI);
        }catch(e){
            console.log('err NextCommittedSOLI~>'+e);
        }
    },
    
    closeWarning : function (cmp, event, helper) {
        cmp.set('v.warningMSgError','');
    },
    
    // verifyScanCode : function (cmp, event, helper) {
    //     //  var scanedfield = cmp.get("v.scanValue");
    //     //  console.log('verifyScanCodes scanedfield : ',scanedfield);
    //     //  var editedFieldId = event.getSource().getLocalId();
    //     //console.log('verifyScanCodes editedFieldId : ',editedFieldId);
    //     console.log('Scanflow : ',cmp.get("v.Scanflow"));
    //     if(cmp.get("v.Scanflow")){
    //         var scan_Code = cmp.get("v.scanValue");
    //         cmp.set("v.exceptionError", "");
    //         cmp.set('v.warningMSgError','');
    //         console.log('scan_Code bfr: ',scan_Code);
    //         var mybarcode = scan_Code;
    //         console.log('PickMultiScreenInUse : ',cmp.get('v.PickMultiScreenInUse'));
    //         if(mybarcode != ''){
    //             cmp.set("v.exceptionError", '');    
    //             //alert(mybarcode); 
    //             if(mybarcode == 'ORDER') { cmp.Back2Outbound(); }
    //             else if(mybarcode == 'PICK') { 
    //                 if(cmp.get('v.PickMultiScreenInUse')) cmp.PickMultiSerials(); 
    //                 else cmp.createPicks();
    //             }
    //                 else if(mybarcode == 'SAVE') { cmp.saveSOLI(); }
    //                     else if(mybarcode == 'PACK') { cmp.createPacks(); }
    //                         else if(mybarcode == 'SHIP') { cmp.createShips(); }
    //                             else if(cmp.get('v.PickMultiScreenInUse')){
    //                                 if(mybarcode == 'ADDALL'){
    //                                     cmp.AddAllSerials();
    //                                 }
    //                                 else if(mybarcode == 'REMOVEALL'){
    //                                     cmp.RemoveAllSerials(); 
    //                                 }
    //                                     else{
    //                                         var selectedSeriallength = (cmp.get('v.PickSelectedSerialNos') != undefined) ? cmp.get('v.PickSelectedSerialNos').length : 0;
    //                                         console.log('selectedSeriallength :',selectedSeriallength);
    //                                         console.log('RemainingQty :',cmp.get('v.RemainingQty'));
    //                                         if(selectedSeriallength < cmp.get('v.RemainingQty')){
    //                                             var serialNos = cmp.get('v.PickSerialNos');
    //                                             var selectedCount = 0;
    //                                             var serialAvailable = false;
    //                                             for(var x in serialNos){
    //                                                 if(mybarcode == serialNos[x].SerialNo.ERP7__Barcode__c || mybarcode == serialNos[x].SerialNo.Name){
    //                                                     serialNos[x].isSelected = true;
    //                                                     if(serialNos[x].isSelected) selectedCount++;
    //                                                     serialAvailable = true;
    //                                                 }
    //                                             }
    //                                             if(!serialAvailable){
    //                                                 cmp.set('v.SearchSerialNos',mybarcode);
    //                                                 cmp.FindSerials();
    //                                                 var serialNos = cmp.get('v.PickSerialNos');
    //                                                 console.log('serialNos : ',serialNos);
    //                                                 if(serialNos.length == 0) { cmp.set('v.exceptionError','Invalid Barcode scanned'); }
    //                                                 else cmp.AddSerials();
    //                                             }
    //                                             else  {
    //                                                 cmp.set("v.PickSerialNos", serialNos);
    //                                                 cmp.AddSerials();
    //                                             }
                                                
    //                                         }
    //                                         else {
    //                                             let error = "The required serial numbers are selected";
    //                                             cmp.set('v.warningMSgError', error);
    //                                             console.log(' warningMSgError : ',cmp.get('v.warningMSgError'));
    //                                         }
    //                                         //cmp.set("v.disableAdd", (selectedCount == 0 || selectedCount > (cmp.get("v.RemainingQty") - cmp.get("v.PickSelectedSerialNos").length)));
                                            
    //                                     }
                                    
    //                             }
    //                                 else{  
    //                                     window.scrollTo(0,0);
                                        
    //                                     var SWLR = cmp.get("v.soliWrapperList");
    //                                     console.log('SWLR here~>',JSON.stringify(SWLR));
                                        
    //                                     for(var x in SWLR){
    //                                         console.log('*** SWLR[x].include : ',SWLR[x].include);
    //                                         console.log('*** soliVerified : ',SWLR[x].soliVerified);
    //                                         var addressname = '';
    //                                         var batchCode = '';
    //                                         for(var y in SWLR[x].Address){
    //                                             if(SWLR[x].Address[y].value == SWLR[x].AddressName) addressname = SWLR[x].Address[y].label;
    //                                         }
    //                                         for(var y in SWLR[x].BatchLotCodes){
    //                                             if(SWLR[x].BatchLotCodes[y].value == SWLR[x].batchLotCode) batchCode = SWLR[x].BatchLotCodes[y].label;
    //                                         }
                                            
    //                                         try{
    //                                             console.log('addressname: ',addressname);
    //                                             console.log('mybarcode : ',mybarcode);
    //                                             console.log('SWLR[x].requiredQty : ',SWLR[x].requiredQty);
    //                                             console.log('SWLR[x]: ',SWLR[x]);
    //                                             if(!$A.util.isEmpty(SWLR[x].LOLI) && !$A.util.isUndefinedOrNull(SWLR[x].LOLI)){
    //                                                 if(!$A.util.isEmpty(SWLR[x].LOLI.ERP7__Quantity__c) && !$A.util.isUndefinedOrNull(SWLR[x].LOLI.ERP7__Quantity__c)){
    //                                                     console.log('SWLR[x].LOLI.ERP7__Quantity__c: ',SWLR[x].LOLI.ERP7__Quantity__c);
    //                                                 }
    //                                             }
    //                                             console.log('SWLR[x].AddressName: ',SWLR[x].AddressName);
    //                                             console.log('batchCode : ',batchCode);
    //                                         }catch(e){ 
    //                                             console.log('err trycatch~>'+e);
    //                                         }
                                            
    //                                         if((SWLR[x].soliVerified || SWLR[x].include) && addressname == mybarcode){
    //                                             console.log('1 In IF');
    //                                             cmp.set('v.warningMSgError',$A.get('$Label.c.Inventory_location_is_already_scanned_Please_scan_Product_Lot_serial'));
    //                                             return;
    //                                         }
    //                                         if((SWLR[x].soliVerified || SWLR[x].include) && SWLR[x].AddressName != '' && SWLR[x].Product.ERP7__Lot_Tracked__c == true && batchCode == mybarcode && !$A.util.isEmpty(SWLR[x].LOLI) && !$A.util.isUndefinedOrNull(SWLR[x].LOLI) && !$A.util.isEmpty(SWLR[x].LOLI.ERP7__Quantity__c) && !$A.util.isUndefinedOrNull(SWLR[x].LOLI.ERP7__Quantity__c) && SWLR[x].LOLI.ERP7__Quantity__c == SWLR[x].requiredQty){
    //                                             console.log('2 In IF');
    //                                             cmp.set('v.warningMSgError',$A.get('$Label.c.The_pick_quantity_cannot_be_greater_than')+SWLR[x].LOLI.ERP7__Quantity__c+'');
    //                                             return;
    //                                         }
    //                                         //console.log('SWLR[x].SerialNumbers.ERP7__Serial__r.Name : ',SWLR[x].SerialNumbers.ERP7__Serial__);
    //                                         if(SWLR[x].soliVerified && SWLR[x].AddressName != '' && SWLR[x].serialized == true && SWLR[x].SerialNumbers.ERP7__Serial__r.Name == mybarcode){
    //                                             console.log('3 In IF');
    //                                             cmp.set('v.warningMSgError',$A.get('$Label.c.Serial_number_is_already_scanned'));
    //                                             return;
    //                                         }
    //                                         if(SWLR[x].soliVerified && SWLR[x].AddressName != '' && SWLR[x].serialized == false && SWLR[x].Product.ERP7__Lot_Tracked__c == false && SWLR[x].LOLI.ERP7__Product__r.ERP7__Barcode__c == mybarcode && SWLR[x].requiredQty == SWLR[x].LOLI.ERP7__Remaining_Quantity__c){
    //                                             console.log('4 In IF');
    //                                             cmp.set('v.warningMSgError',$A.get('$Label.c.Pick_quantity_cannot_be_greater_than_total_quantity'));
    //                                             return;
    //                                         }
    //                                     }
    //                                     $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
    //                                     var SWLI = JSON.stringify(SWLR);
    //                                     var action = cmp.get("c.scanLines");
    //                                     var scanNo = cmp.get("v.ScanNo");
    //                                     console.log('scanNo : ',scanNo);
    //                                     action.setParams({barcode:mybarcode,ScanNo:scanNo,SWL:SWLI});
    //                                     action.setCallback(this, function(response) {
    //                                         var state = response.getState();
    //                                         console.log('state : ',state);
    //                                         if (state === "SUCCESS") {
    //                                             console.log('response : ',response.getReturnValue());
    //                                             cmp.set("v.PreventChange", true);
    //                                             console.log('exceptionError~>'+response.getReturnValue().exceptionError);
    //                                             cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
    //                                             if(response.getReturnValue().barcodeLocMsg != undefined && response.getReturnValue().barcodeLocMsg != null && response.getReturnValue().barcodeLocMsg != ''){
    //                                                 var text = response.getReturnValue().barcodeLocMsg;
    //                                                 if(text.includes("Invalid")){
    //                                                     cmp.set("v.exceptionError", text);
    //                                                 }else{
    //                                                     cmp.set("v.barcodeLocMsg", response.getReturnValue().barcodeLocMsg);
    //                                                     //cmp.set("v.warningMSgError", response.getReturnValue().barcodeLocMsg);
    //                                                 }
    //                                             }
    //                                             cmp.set("v.soliWrapperList", response.getReturnValue().soliWrapperList);
    //                                             cmp.set("v.ScanNo", response.getReturnValue().ScanNo);
    //                                             cmp.set("v.PreventChange", false);
    //                                             $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    //                                             var obj = response.getReturnValue().soliWrapperList;
    //                                             try{
    //                                                 for(var x in obj){
    //                                                     if(obj[x].include && obj[x].LOLI.Id != null && obj[x].LOLI.Id != undefined && obj[x].LOLI.Id != ''){
    //                                                         if(document.getElementById(obj[x].LOLI.Id) != undefined && document.getElementById(obj[x].LOLI.Id) != null){
    //                                                             var uscroll = document.getElementById(obj[x].LOLI.Id);
    //                                                             if(uscroll != null && uscroll != undefined){
    //                                                                 uscroll.scrollIntoView();
    //                                                                 break;
    //                                                             }
    //                                                         }
                                                            
    //                                                     }
    //                                                 }
    //                                             }catch(e){
    //                                                 console.log('error~>'+e);
    //                                             }
    //                                         }
    //                                     });
    //                                     $A.enqueueAction(action);
    //                                 }  
    //             cmp.set("v.scanValue",'');
    //         }
    //     }
    // },
    verifyScanCode: function (cmp, event, helper) {
        console.log('Scanflow: ', cmp.get("v.Scanflow"));
        if (cmp.get("v.Scanflow")) {
            var scan_Code = cmp.get("v.scanValue");
            cmp.set("v.exceptionError", "");
            cmp.set("v.warningMSgError", "");
            console.log('scan_Code: ', scan_Code);
            var mybarcode = scan_Code.trim();
            console.log('Scanned barcode: ', mybarcode);
    
            if (mybarcode != '') {
                cmp.set("v.exceptionError", '');
                if (mybarcode == 'ORDER') { cmp.Back2Outbound(); }
                else if (mybarcode == 'PICK') { 
                    if (cmp.get('v.PickMultiScreenInUse')) cmp.PickMultiSerials(); 
                    else cmp.createPicks();
                }
                else if (mybarcode == 'SAVE') { cmp.saveSOLI(); }
                else if (mybarcode == 'PACK') { cmp.createPacks(); }
                else if (mybarcode == 'SHIP') { cmp.createShips(); }
                else if (cmp.get('v.PickMultiScreenInUse')) {
                    if (mybarcode == 'ADDALL') {
                        cmp.AddAllSerials();
                    }
                    else if (mybarcode == 'REMOVEALL') {
                        cmp.RemoveAllSerials();
                    }
                    else {
                        var selectedSeriallength = (cmp.get('v.PickSelectedSerialNos') != undefined) ? cmp.get('v.PickSelectedSerialNos').length : 0;
                        console.log('selectedSeriallength: ', selectedSeriallength);
                        console.log('RemainingQty: ', cmp.get('v.RemainingQty'));
                        if (selectedSeriallength < cmp.get('v.RemainingQty')) {
                            var serialNos = cmp.get('v.PickSerialNos');
                            var selectedCount = 0;
                            var serialAvailable = false;
                            for (var x in serialNos) {
                                if (mybarcode == serialNos[x].SerialNo.ERP7__Barcode__c || mybarcode == serialNos[x].SerialNo.Name) {
                                    serialNos[x].isSelected = true;
                                    if (serialNos[x].isSelected) selectedCount++;
                                    serialAvailable = true;
                                }
                            }
                            if (!serialAvailable) {
                                cmp.set('v.SearchSerialNos', mybarcode);
                                cmp.FindSerials();
                                var serialNos = cmp.get('v.PickSerialNos');
                                console.log('serialNos: ', serialNos);
                                if (serialNos.length == 0) {
                                    cmp.set('v.exceptionError', 'Invalid Barcode scanned');
                                }
                                else cmp.AddSerials();
                            }
                            else {
                                cmp.set("v.PickSerialNos", serialNos);
                                cmp.AddSerials();
                            }
                        }
                        else {
                            let error = "The required serial numbers are selected";
                            cmp.set('v.warningMSgError', error);
                            console.log('warningMSgError: ', cmp.get('v.warningMSgError'));
                        }
                    }
                }
                else {
                    window.scrollTo(0, 0);
                    var SWLR = cmp.get("v.soliWrapperList");
                    console.log('SWLR before scan: ', JSON.stringify(SWLR));
                    var SWLI = JSON.stringify(SWLR);
                    var scanNo = cmp.get("v.ScanNo");
                    console.log('ScanNo before scanLines call: ', scanNo);
    
                    // Reset ScanNo to 0 if it’s not a command and ScanNo is 1, assuming a new location scan
                    if (scanNo == 1 && !['ORDER', 'PICK', 'SAVE', 'PACK', 'SHIP'].includes(mybarcode)) {
                        console.log('Resetting ScanNo to 0 for new location scan');
                        scanNo = 0;
                        cmp.set("v.ScanNo", 0);
                    }
    
                    var action = cmp.get("c.scanLines");
                    action.setParams({ barcode: mybarcode, ScanNo: scanNo, SWL: SWLI });
    
                    $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            cmp.set("v.PreventChange", true);
                            cmp.set("v.exceptionError", result.exceptionError || '');
                            if (result.barcodeLocMsg) {
                                if (result.barcodeLocMsg.includes("Invalid")) {
                                    cmp.set("v.exceptionError", result.barcodeLocMsg);
                                    console.log('Invalid barcode detected: ', result.barcodeLocMsg);
                                } else {
                                    cmp.set("v.barcodeLocMsg", result.barcodeLocMsg);
                                }
                            }
    
                            var oldSWLR = cmp.get("v.soliWrapperList");
                            var newSWLR = result.soliWrapperList;
                            cmp.set("v.soliWrapperList", newSWLR);
                            cmp.set("v.ScanNo", result.ScanNo);
    
                            for (var i = 0; i < newSWLR.length; i++) {
                                if (newSWLR[i].soliVerified && newSWLR[i].include && 
                                    (!oldSWLR[i].soliVerified || oldSWLR[i].AddressName !== newSWLR[i].AddressName)) {
                                    console.log('Location updated for row ' + i + ': ', newSWLR[i].AddressName);
                                    var fakeEvent = {
                                        getSource: function() {
                                            return {
                                                get: function(param) {
                                                    return i;
                                                }
                                            };
                                        }
                                    };
                                    helper.fetchStocks(cmp, fakeEvent, helper);
                                    break;
                                }
                            }
    
                            cmp.set("v.PreventChange", false);
                            try {
                                var obj = result.soliWrapperList;
                                for (var x in obj) {
                                    if (obj[x].include && obj[x].LOLI.Id) {
                                        var uscroll = document.getElementById(obj[x].LOLI.Id);
                                        if (uscroll) {
                                            uscroll.scrollIntoView();
                                            break;
                                        }
                                    }
                                }
                            } catch (e) {
                                console.log('Scroll error: ', e);
                            }
                        } else {
                            console.log('scanLines error: ', response.getError());
                            var errorMessage = "Unknown error";
                            if (response.getError() && response.getError()[0] && response.getError()[0].message) {
                                errorMessage = response.getError()[0].message;
                            }
                            cmp.set("v.exceptionError", "An error occurred: " + errorMessage);
                        }
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    });
                    $A.enqueueAction(action);
                }
                cmp.set("v.scanValue", '');
            }
        }
    },
    CreateBarcodes : function(cmp, event, helper) {
        var logIds = cmp.get("v.logisticIds");
        var Pick_Barcode = $A.get("$Label.c.Pick_Barcode");
        var RecUrl = "/apex/"+Pick_Barcode+"?loIds=" + logIds;
        window.open(RecUrl,'_blank');
    },
    
    createPickingSlips : function(cmp, event, helper) {
        var logIds = cmp.get("v.logisticIds");
        var PickSlip = $A.get("$Label.c.Pick_Slip");
        
        if(cmp.get("v.ShowLangOptionForPickSlip")){
            cmp.set("v.ShowLangOptionForPicksliptModal",true);
        }
        else{
            
            //Changes made by Parveez 06/07/2023
            if(cmp.get("v.ReplacePickSlipOrgURL")){
                var customOrgUrl =  $A.get("$Label.c.orgURL");
                console.log('customOrgUrl : ',customOrgUrl);
                var RecUrl = customOrgUrl+"/apex/"+PickSlip+"?loIds=" + logIds;
                console.log('RecUrl~>'+RecUrl);
                window.open(RecUrl,'_blank'); 
            }
            else{
                var RecUrl = "/apex/"+PickSlip+"?loIds=" + logIds;
                console.log('RecUrl~>'+RecUrl);
                window.open(RecUrl,'_blank'); 
                
            }
        }
    },
    
    //Added by Parveez for multi lang doc options 06/07/2023
    PackListNext : function(component, event, helper) {
        var logIds = component.get("v.logisticIds");
        var PickSlip = $A.get("$Label.c.Pick_Slip");
        var SelectedLang = component.get("v.SelectedLang");
        console.log('Inside PackListNext~>');
        if(SelectedLang == "English"){
            PickSlip = $A.get("$Label.c.Pick_Slip");
        }else if(SelectedLang == "French"){
            PickSlip = $A.get("$Label.c.Pick_Slip_FR");
        }
        if(component.get("v.ReplacePickSlipOrgURL")){
            var customOrgUrl =  $A.get("$Label.c.orgURL");
            console.log('customOrgUrl : ',customOrgUrl);
            var RecUrl = customOrgUrl+"/apex/"+PickSlip+"?loIds=" + logIds;
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank'); 
        }else{
            var RecUrl = "/apex/"+PickSlip+"?loIds=" + logIds;
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank'); 
        }
    },
    
    goBackPackList : function(component, event, helper) {
        component.set("v.ShowLangOptionForPicksliptModal",false);
    },
    
    
    checkAll : function(cmp, event, helper) {
        var obj = cmp.get("v.soliWrapperList");
        var val = cmp.get("v.checkAll");
        for(var x in obj){
            obj[x].soliSelected = val;
        }
        cmp.set("v.soliWrapperList",obj);
        console.log('soli wrpaer checl --'+JSON.stringify(cmp.get("v.soliWrapperList")));
    },
    
    fetchBatchStock : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SWLR = cmp.get("v.soliWrapperList");
        var SMR = cmp.get("v.stockMap");
        var count = event.getSource().get("v.name");
        //alert(count);
        if(count >= 0){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var SWLI = JSON.stringify(SWLR[count]);
            console.log('SWLI : ',SWLI);
            var SMI = JSON.stringify(SMR);
            console.log('SMI : ',SMI);
            var action = cmp.get("c.fetchBatchStocks");
            action.setParams({SWL:SWLI,SM:SMI});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue().exceptionError == ''){
                        SWLR[count] = response.getReturnValue().soliWrapperList[0];
                        console.log('SWLR[count] : '+JSON.stringify(SWLR[count]));
                        cmp.set("v.soliWrapperList", SWLR);
                        cmp.set("v.stockMap", response.getReturnValue().stockMap);
                    }
                    else{
                        console.log('fetchBatchStocks exceptionError~>'+response.getReturnValue().exceptionError);
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        setTimeout(function(){cmp.set("v.exceptionError", "");}, 9000);
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }else{
                    var errors = response.getError();
                    console.log("server error in fetchBatchStocks : ", JSON.stringify(errors));
                    cmp.set("v.exceptionError", errors[0].message);
                    setTimeout(function(){cmp.set("v.exceptionError", "");}, 9000);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    // fetchSerialStock : function(cmp, event, helper) {
    //     console.log('fetchSerialStock called');
    //     try{
    //         let serialId = event.currentTarget.dataset.recordId;
    //         console.log('serialId : ',serialId);
    //         if(serialId != '' && serialId != null && serialId != undefined){
                
    //         }
    //     }catch(e){
    //         console.log('err~>'+e);
    //     }
    // },
    // changed by matheen on 1/5/25 to fix the issue stock not getting refreshed
    fetchSerialStock: function(cmp, event, helper) {
        console.log('fetchSerialStock called');
        try {
            let serialId = event.currentTarget.dataset.recordId;
            console.log('serialId : ', serialId);
            if (serialId != '' && serialId != null && serialId != undefined) {
                let index = event.currentTarget.closest("tr").getAttribute("id");
                console.log('index', index);
                let wrapperList = cmp.get("v.soliWrapperList");
                let count = wrapperList.findIndex(item => item.LOLI.Id === index);
                console.log('count', count);
                if (count !== -1) {
                    console.log('before call');
                    helper.fetchStocks(cmp, event, helper, count); 
                    console.log('after call');
                }
            }
        } catch (e) {
            console.log('err~>' + e);
        }
    },
    fetchStocks : function(cmp, event, helper) {
         var index = event.getSource().get("v.name");
        console.log('ind ----'+index);
        helper.fetchStocks(cmp, event, helper);
    },
    
    saveSOLI : function(cmp, event, helper) {
        console.log('saveSOLI called');
        
        window.scrollTo(0,0);
        cmp.set("v.exceptionError", "");
        var SWLR = cmp.get("v.soliWrapperList");
        var SER = cmp.get("v.SerialIds2Exempt");
        var SMR = cmp.get("v.stockMap");
        var logIds = cmp.get("v.logisticIds");
        var sel = false;
        for(var x in SWLR){
            if(SWLR[x].soliSelected == true && SWLR[x].LOLI.ERP7__Product__r.ERP7__Serialise__c && (SWLR[x].SerialNumbers.ERP7__Serial__c == null || SWLR[x].SerialNumbers.ERP7__Serial__c == undefined || SWLR[x].SerialNumbers.ERP7__Serial__c == '')){
                cmp.set("v.exceptionError",$A.get('$Label.c.Required_field_missing_Serial_Number'));
                break;
            }
            else if(SWLR[x].soliSelected == true && !SWLR[x].LOLI.ERP7__Product__r.ERP7__Serialise__c &&  SWLR[x].LOLI.ERP7__Product__r.ERP7__Lot_Tracked__c && (SWLR[x].batchLotCode == null || SWLR[x].batchLotCode == '' || SWLR[x].batchLotCode == undefined || SWLR[x].batchLotCode == '--None--')){
                cmp.set("v.exceptionError",'Please select the Lot number');
                return;
            }
            if(SWLR[x].soliSelected == true && (SWLR[x].requiredQty != null && SWLR[x].requiredQty != '' && SWLR[x].requiredQty != undefined)){
                if(SWLR[x].requiredQty <= 0) cmp.set("v.exceptionError",$A.get('$Label.c.Enter_Qty_greater_than_zero_to_pick'));
                else { sel = true; }
                break;
            }
            else if(SWLR[x].soliSelected == true && (SWLR[x].requiredQty == null || SWLR[x].requiredQty == '' || SWLR[x].requiredQty == undefined)){
                cmp.set("v.exceptionError",$A.get('$Label.c.Enter_Qty_to_pick'));
            }
        }
        
        console.log('exceptionError if any: ',cmp.get("v.exceptionError"));
        if(sel){
            //alert('picking');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var logisticIds = logIds.split(",");
            var LIds = JSON.stringify(logisticIds);
            var SWLI = JSON.stringify(SWLR);
            var SEI = JSON.stringify(SER);
            var SMI = JSON.stringify(SMR);
            var action = cmp.get("c.saveSOLIs");
            
            console.log('SWLI~>',SWLI);
            console.log('SEI~>',SEI);
            console.log('SMI~>',SMI);
            console.log('LIds~>',LIds);
            
            action.setParams({SWL:SWLI,SE:SEI,SM:SMI,LogisticIds:LIds});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    if(cmp.get("v.checkAll"))cmp.set("v.checkAll",false);
                    console.log('success inhere');
                    
                    //alert(response.getReturnValue().exceptionError);
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    if(response.getReturnValue().exceptionError == ''){
                        
                        cmp.set("v.navToPack",true);
                        cmp.getAllDetailsInit();
                        //alert(response.getReturnValue().soliWrapperList.length);
                        /*
                        if(response.getReturnValue().soliWrapperList.length == 0) {
                           cmp.createPacks();
                        }
                        else{
                            cmp.set("v.PreventChange", true);
                            //cmp.set("v.Container", response.getReturnValue());
                            cmp.set("v.SiteName", response.getReturnValue().SiteName);
                            cmp.set("v.Logistics", response.getReturnValue().LogisticRecs);
                            cmp.set("v.soliWrapperList", []);
                            cmp.set("v.soliWrapperList", response.getReturnValue().soliWrapperList);
                            cmp.set("v.SerialIds2Exempt", response.getReturnValue().SerialIds2Exempt);
                            cmp.set("v.stockMap", response.getReturnValue().stockMap);
                            cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                            cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                            //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                            cmp.set("v.showSN", response.getReturnValue().showSN);
                            cmp.set("v.showBatch", response.getReturnValue().showBatch);
                            cmp.set("v.barcodeLocMsg", response.getReturnValue().barcodeLocMsg);
                            cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                            cmp.set("v.PreventChange", false);
                            //cmp.createPicks();
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get('$Label.c.Success'),
                                "message": $A.get('$Label.c.Picked_successfully'),
                                "type": "success",
                            });
                            toastEvent.fire();
                            
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                        cmp.set("v.initialSTOLISerial", "");
                        */
                    }
                    else{
                        console.log("error --> ", response.getReturnValue().exceptionError);
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }
                else{
                    var errors = response.getError();
                    console.log("server error : ", errors);
                    cmp.set("v.exceptionError", errors[0].message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        } 
        else if(cmp.get("v.exceptionError") != '')  cmp.set("v.exceptionError", cmp.get('v.exceptionError'));
            else cmp.set("v.exceptionError", $A.get('$Label.c.Please_select_a_line_item_to_pick'));
    },
    
    setScriptLoaded : function(cmp, event, helper) {
        //alert();
        //$j('[data-toggle="popover"]').popover();
    },
    
    Back2Outbound : function(cmp, event, helper) {
        $A.createComponent("c:OutboundLogistics",{
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    createPicks : function(cmp, event, helper) {
        var logIds = cmp.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Pick",{
            "logisticIds":logIds
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    createPacks : function(cmp, event, helper) {
        var logIds = cmp.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Pack",{
            "logisticIds":logIds
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
        
    },
    
    createShips : function(cmp, event, helper) {
        var logIds = cmp.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Ship",{
            "logisticIds":logIds
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    focusTOscan : function (component, event,helper) {
        component.set("v.scanValue",'');
        helper.focusTOscan(component, event);  
        
    },
    
 changeInitialSerial : function(cmp, event){
    // Set the initial STOLI Serial if not already set
    if(cmp.get("v.initialSTOLISerial") == ""){
        cmp.set("v.initialSTOLISerial", event.currentTarget.dataset.recordId);
    }

    var prodIndex = event.currentTarget.dataset.index;
    console.log('prodIndex : ', prodIndex);

    if(prodIndex != null && prodIndex != '' && prodIndex != undefined){
        var solilist = cmp.get('v.soliWrapperList');
        var prodId = '';
        var batchId = '';

        // Loop through soliWrapperList to find the product and batch
        for(var x in solilist){
            if(x === prodIndex){
                prodId = solilist[x].LOLI.ERP7__Product__c;
                batchId = solilist[x].batchLotCode;
            }
        }

        var siteId = cmp.get('v.selectedSite');
        var serials2exclude = [];
        var action1 = cmp.get("c.getAllreservedSerials");

        // Pass the product ID to Apex to fetch reserved serials
        action1.setParams({ "productId": prodId });

        // Callback to process the response after reserved serials are fetched
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

                // Construct the query inside the callback after fetching reserved serials
                var qry = '';

                if (prodId != undefined) {
                    qry += ' AND ERP7__Product__c = \'' + prodId + '\' ';
                }
				//added a validation on init SOLISerialNo issue reported from semler.
                var initSerial = cmp.get("v.initialSTOLISerial");
                if(initSerial != null && initSerial != undefined && initSerial !='')qry += ' AND (ERP7__Available__c = true OR Id = \'' + cmp.get("v.initialSTOLISerial") + '\') ';
                else qry += ' AND ERP7__Available__c = true';
                qry += ' AND ERP7__Scrap__c = false ';

                if (siteId != '') {
                    qry += ' AND ERP7__Warehouse__c = \'' + siteId + '\' ';
                }

                if (batchId != '') {
                    qry += ' AND ERP7__Material_Batch_Lot__c = \'' + batchId + '\' ';
                }

                if (serials2exclude.length > 0) {
                    qry += ' AND Id NOT IN (\'' + serials2exclude.join("','") + '\') ';
                }

                console.log('final serial qry~>' + qry);
                cmp.set("v.SerialLookUpQry", qry);  // Set the query in the component after constructing it
            } else {
                console.log('Error fetching reserved serials');
            }
        });

        // Enqueue the action to run the server-side method
        $A.enqueueAction(action1);
    }
},
    closeError : function (cmp, event) {
        cmp.set("v.exceptionError",'');
    },
    
    StillToFulfill : function (component, event) {
        var logIds = component.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:StillToFulfillLightning",{
            "logisticIds":logIds
        },function(newCmp, status, errorMessage){
            
            if (status === "SUCCESS") {
                // $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    inlineEditSerial : function (component, event) {
        var index = event.target.dataset.id;
        console.log('index : ',index);
        if(index != null && index != '' && index != undefined){
            let lst = component.get('v.soliExistingList');
            for(var x in lst){
                if(x == index){
                    lst[x].editserial = true;
                } 
            }
            component.set('v.soliExistingList',lst);
        }
    },
    
    inlineEditbatch : function (component, event) {
        var index = event.target.dataset.id;
        console.log('index : ',index);
        if(index != null && index != '' && index != undefined){
            let lst = component.get('v.soliExistingList');
            for(var x in lst){
                if(x == index){
                    lst[x].editbatch = true;
                } 
            }
            component.set('v.soliExistingList',lst);
        }
        
    },
    
    checkbatchStock : function (component, event) {
        var index = event.currentTarget.name;
        console.log('index : ',index);
        if(index != null && index != undefined){
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            let lst = component.get('v.soliExistingList');
            var selectedBatch = '';
            var soli2updateID = '';
            var solqty = 0;
            console.log('in');
            for(var x in lst){
                if((x == index || lst[x].editbatch == true ) && (lst[x].soli.ERP7__Material_Batch_Lot__c != null && lst[x].soli.ERP7__Material_Batch_Lot__c != '' && lst[x].soli.ERP7__Material_Batch_Lot__c != undefined)){
                    console.log('value matched');
                    selectedBatch = lst[x].soli.ERP7__Material_Batch_Lot__c;
                    console.log('selectedBatch :  ',selectedBatch);
                    soli2updateID = lst[x].soli.Id;
                    console.log('soli2updateID : ',soli2updateID);
                    solqty = lst[x].soli.ERP7__Quantity__c;
                    console.log('solqty : ',solqty);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
                //else { console.log('else 1'); $A.util.addClass(component.find('mainSpin'), "slds-hide"); return;}
            }
            
            if(selectedBatch != null && selectedBatch != '' && selectedBatch != undefined && soli2updateID != null && soli2updateID != '' && soli2updateID != undefined && solqty != null && solqty != undefined){
                console.log('in 2 qty : ',solqty);
                $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                var action = component.get('c.getBatchStocks');
                action.setParams({
                    batchId : selectedBatch,
                    soli : soli2updateID
                });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    console.log('state : ',state);
                    console.log('response.getReturnValue() : ',response.getReturnValue());
                    if(state==='SUCCESS'){
                        var result = response.getReturnValue();
                        console.log('result : ',result);
                        if(result == 'Selected batch doesn\'t have enough quantity'){
                            component.set('v.editErrMsg',result); 
                        }
                        else if(result != null){
                            var res = JSON.parse(result);
                            console.log('res : ',res);
                            for(var x in lst){
                                if(x == index && lst[x].soli.Id == res.Id){
                                    lst[x].soli.ERP7__Material_Batch_Lot__c = res.ERP7__Material_Batch_Lot__c;
                                    lst[x].editbatch = false;
                                } 
                            }
                            component.set('v.soliExistingList',lst);
                        }
                    }
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
            else{
                console.log('else :  ',selectedBatch);
                $A.util.addClass(component.find('mainSpin'), "slds-hide"); 
                return;
            }
        }
    },
    
    checkserial : function (component, event) {
        var index = event.currentTarget.name;
        console.log('index : ',index);
        if(index != null && index != undefined){
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            let lst = component.get('v.soliExistingList');
            var selectedserial = '';
            var soli2updateID = '';
            var solqty = 0;
            console.log('in');
            for(var x in lst){
                console.log(lst[x].editserial);
                console.log(x);
                console.log(lst[x].soli.ERP7__Serial__c);
                if((x == index || lst[x].editserial == true) && (lst[x].soli.ERP7__Serial__c != null && lst[x].soli.ERP7__Serial__c != '' && lst[x].soli.ERP7__Serial__c != undefined)){
                    console.log('value matched');
                    selectedserial = lst[x].soli.ERP7__Serial__c;
                    console.log('selectedserial :  ',selectedserial);
                    soli2updateID = lst[x].soli.Id;
                    console.log('soli2updateID : ',soli2updateID);
                    
                }
                //else { console.log('else 1'); $A.util.addClass(component.find('mainSpin'), "slds-hide"); return;}
            }
            
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            if(selectedserial != null && selectedserial != '' && selectedserial != undefined && soli2updateID != null && soli2updateID != '' && soli2updateID != undefined){
                console.log('in 2  ');
                $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                var action = component.get('c.updateSerial');
                action.setParams({
                    serId : selectedserial,
                    soli : soli2updateID
                });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    console.log('state : ',state);
                    console.log('response.getReturnValue() : ',response.getReturnValue());
                    if(state==='SUCCESS'){
                        var result = response.getReturnValue();
                        console.log('result : ',result);
                        if(result == 'Selected serial is not avialable'){
                            component.set('v.editErrMsg',result); 
                        }
                        else if(result != null){
                            var res = JSON.parse(result);
                            console.log('res : ',res);
                            for(var x in lst){
                                if(x == index){
                                    lst[x].soli= res;
                                    console.log('lst[x].soli : ',lst[x].soli);
                                    lst[x].editserial = false;
                                } 
                            }
                            component.set('v.soliExistingList',lst);
                        }
                    }
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
            else{
                console.log('else :  ',selectedserial); 
                $A.util.addClass(component.find('mainSpin'), "slds-hide"); 
                return;
            }
        }
    },
    
    removeeditserial : function (component, event) {
        var index = event.target.dataset.id;
        console.log('index : ',index);
        if(index != null && index != '' && index != undefined){
            let lst = component.get('v.soliExistingList');
            for(var x in lst){
                if(x == index){
                    lst[x].editserial = false;
                } 
            }
            component.set('v.soliExistingList',lst);
        }	
    },
    
    removeeditbatch : function (component, event) {
        var index = event.target.dataset.id;
        console.log('index : ',index);
        if(index != null && index != '' && index != undefined){
            let lst = component.get('v.soliExistingList');
            for(var x in lst){
                if(x == index){
                    lst[x].editbatch = false;
                } 
            }
            component.set('v.soliExistingList',lst);
        }	
    },
    
    DeleteRecordSOLI: function(cmp, event) {
        var result = confirm("Are you sure?");
        var RecordId = event.getSource().get("v.name");
        //alert(RecordId);
        if (result) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            try{
                var action = cmp.get("c.unCommitSOLI");
                action.setParams({
                    SoliId: RecordId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        //alert(response.getReturnValue().exceptionError);
                        if(response.getReturnValue().exceptionError != ''){
                            cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        } else{
                            //alert('pick');
                            cmp.createPicks();
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
            catch(err) {
                //alert("Exception : "+err.message);
            }
        } 
    },
    
    OpenMyModalPickSerial: function (cmp, event) {
        $A.util.addClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
        cmp.set('v.PickMultiScreenInUse',true);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        
        var loglineId = event.getSource().get("v.name");
        var RemainingQty = event.getSource().get("v.value");
        console.log('outboind pick item RemainingQty~>',RemainingQty);
        cmp.set("v.pickloglineId", loglineId);
        cmp.set("v.RemainingQty", RemainingQty);
        var action = cmp.get("c.PreparePickSerialNos");
        action.setParams({
            logisticLineId: loglineId,
            searchString: "",
            reservedSelectedSerials: []
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(response.getReturnValue().exceptionError != ''){
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } else{
                    //alert('PickSerialNos : '+response.getReturnValue().PickSerialNos.length);
                    //alert('PickSelectedSerialNos : '+response.getReturnValue().PickSelectedSerialNos.length);
                    cmp.set("v.PickSerialNos", response.getReturnValue().PickSerialNos);
                    cmp.set("v.PickSelectedSerialNos", response.getReturnValue().PickSelectedSerialNos);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    CloseMyModalPickSerial: function (cmp, event) {
        cmp.set("v.pickloglineId", "");
        $A.util.removeClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
        cmp.set('v.PickMultiScreenInUse',false);
    },
    
    PickSerialNosDiv: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SId = event.currentTarget.getAttribute('data-serialId');
        var obj = cmp.get("v.PickSerialNos");
        var selectedCount = 0;
        for(var x in obj){
            if(SId == obj[x].SerialNo.Id) obj[x].isSelected = !obj[x].isSelected;
            if(obj[x].isSelected) selectedCount++;
        }
        cmp.set("v.disableAdd", (selectedCount == 0 || selectedCount > (cmp.get("v.RemainingQty") - cmp.get("v.PickSelectedSerialNos").length)));
        cmp.set("v.PickSerialNos", obj);
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },
    
    PickSelectedSerialNosDiv: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SId = event.currentTarget.getAttribute('data-serialId');
        var obj = cmp.get("v.PickSelectedSerialNos");
        var selectedCount = 0;
        for(var x in obj){
            if(SId == obj[x].SerialNo.Id) obj[x].isSelected = !obj[x].isSelected;
            if(obj[x].isSelected) selectedCount++;
        }
        cmp.set("v.disableRemove", !(selectedCount > 0));
        cmp.set("v.PickSelectedSerialNos", obj);
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },
    
    FindSerials: function (cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        cmp.set("v.disableAdd", true);
        var loglineId = cmp.get("v.pickloglineId");
        var srcStr = cmp.get("v.SearchSerialNos");
        var obj = cmp.get("v.PickSelectedSerialNos");
        var RSSerials = [];
        for(var x in obj){
            RSSerials.push(obj[x].SerialNo.Id)
        }
        var action = cmp.get("c.PreparePickSerialNos");
        action.setParams({
            logisticLineId: loglineId,
            searchString: srcStr,
            reservedSelectedSerials: RSSerials
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                if(response.getReturnValue().exceptionError != ''){
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } else{
                    //alert('PickSerialNos : '+response.getReturnValue().PickSerialNos.length);
                    
                    var objSource = response.getReturnValue().PickSerialNos;
                    console.log('objSource.length : ',objSource.length);
                    var destObj = (cmp.get("v.PickSelectedSerialNos") != undefined) ? cmp.get("v.PickSelectedSerialNos") : [];
                    console.log('destObj.length : ',destObj.length);
                    if(objSource.length > 0){
                        if(objSource[0].isSelected && destObj.length < cmp.get("v.RemainingQty")) cmp.set("v.disableAdd", false);
                        else objSource[0].isSelected = false;
                    }  
                    cmp.set("v.PickSerialNos", objSource);
                    console.log('PickSerialNos : ',cmp.get('v.PickSerialNos'));
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    AddSerials: function (cmp, event) {
        cmp.set("v.disableAdd", true);
        var objSource = cmp.get("v.PickSerialNos");
        var objDestn = cmp.get("v.PickSelectedSerialNos");        
        var i = 0;
        while (i < objSource.length) {
            if (objSource[i].isSelected) {
                objSource[i].isSelected = false;
                objDestn.unshift(objSource[i]);
                objSource.splice(i, 1);
            } else {
                ++i;
            }
        }
        cmp.set("v.PickSerialNos",objSource);
        cmp.set("v.PickSelectedSerialNos",objDestn);
        cmp.set('v.selectAllSerials', false);
    },
    
    RemoveSerials: function (cmp, event) {
        cmp.set("v.disableRemove", true);
        var objSource = cmp.get("v.PickSelectedSerialNos");
        var objDestn = cmp.get("v.PickSerialNos");
        var i = 0;
        while (i < objSource.length) {
            if (objSource[i].isSelected) {
                objSource[i].isSelected = false;
                objDestn.unshift(objSource[i]);
                objSource.splice(i, 1);
            } else {
                ++i;
            }
        }
        cmp.set("v.PickSerialNos",objDestn);
        cmp.set("v.PickSelectedSerialNos",objSource);
        cmp.set('v.selectAllSerials', false);
    },
    
    AddAllSerials: function (cmp, event) {
        console.log('AddAllSerials called');
        var objSource = cmp.get("v.PickSerialNos");
        var objDestn = cmp.get("v.PickSelectedSerialNos");   
        var RemainingQty = cmp.get("v.RemainingQty");
        var i = 0;
        while (i < objSource.length && objDestn.length < RemainingQty && objDestn.length < 500) {
            objSource[i].isSelected = false;
            objDestn.unshift(objSource[i]);
            objSource.splice(i, 1);
        }
        cmp.set("v.PickSerialNos",objSource);
        cmp.set("v.PickSelectedSerialNos",objDestn);
        cmp.set('v.selectAllSerials', false);
    },
    
    RemoveAllSerials: function (cmp, event) {
        var objSource = cmp.get("v.PickSelectedSerialNos");
        var objDestn = cmp.get("v.PickSerialNos");
        var i = 0;
        while (i < objSource.length) {
            objSource[i].isSelected = false;
            objDestn.unshift(objSource[i]);
            objSource.splice(i, 1);
        }
        cmp.set("v.PickSerialNos",objDestn);
        cmp.set("v.PickSelectedSerialNos",objSource);
        cmp.set('v.selectAllSerials', false);
    },
    
    PickMultiSerials: function (cmp, event) {
        console.log('PickMultiSerials called');
        
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        
        var loglineId = cmp.get("v.pickloglineId");
        var RemainingQty = cmp.get("v.RemainingQty");
        var selectedSerials = cmp.get("v.PickSelectedSerialNos");
        var selectedSerialIds = [];
        var i = 0;
        while (i < selectedSerials.length) { //
            if(i < RemainingQty){
                console.log(selectedSerials[i].SerialNo.Name);
                selectedSerialIds.push(selectedSerials[i].SerialNo.Id);
                i++;
            } else selectedSerials.splice(i, 1);
        } 
        //  alert(selectedSerialIds.length);
        // return;
        window.scrollTo(0,0);
        cmp.set("v.exceptionError", "");
        var SWLR = cmp.get("v.soliWrapperList");
        var SER = cmp.get("v.SerialIds2Exempt");
        var SMR = cmp.get("v.stockMap");
        var logIds = cmp.get("v.logisticIds");
        var sel = true;
        //alert(loglineId);
        for(var x in SWLR){
            //alert(SWLR[x].requiredQty);
            if(SWLR[x].LOLI.Id == loglineId){
                SWLR[x].soliSelected = true;
                SWLR[x].MultiSerialIds = selectedSerialIds;
                console.log(SWLR[x].SerialNumbers.Serial__c);
                //alert(SWLR[x].MultiSerialIds.length);
            }else{
                SWLR[x].soliSelected = false;
            }
        }
        
        if(sel){
            console.log('picking after sel');
            var logisticIds = logIds.split(",");
            var LIds = JSON.stringify(logisticIds);
            var SWLI = JSON.stringify(SWLR);
            var SEI = JSON.stringify(SER);
            var SMI = JSON.stringify(SMR);
            //alert(LIds);
            var action = cmp.get("c.saveSOLIs");
            action.setParams({SWL:SWLI,SE:SEI,SM:SMI,LogisticIds:LIds});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('PickMultiSerials success inhere');
                    
                    //alert(response.getReturnValue().exceptionError);
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    if(response.getReturnValue().exceptionError == ''){
                        //alert(response.getReturnValue().soliWrapperList.length);
                        cmp.set("v.navToPack",true);
                        cmp.getAllDetailsInit();
                        
                        $A.util.removeClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
                        $A.util.removeClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
                        cmp.set('v.PickMultiScreenInUse',false);
                        
                        /*
                        if(response.getReturnValue().soliWrapperList.length == 0) {
                            cmp.createPacks();
                        }
                        else{
                            cmp.set("v.pickloglineId", "");
                            $A.util.removeClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
                            $A.util.removeClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
                            cmp.set('v.PickMultiScreenInUse',false);
                            cmp.set("v.PreventChange", true);
                            //cmp.set("v.Container", response.getReturnValue());
                            cmp.set("v.SiteName", response.getReturnValue().SiteName);
                            cmp.set("v.Logistics", response.getReturnValue().LogisticRecs);
                            cmp.set("v.soliWrapperList", []);
                            cmp.set("v.soliWrapperList", response.getReturnValue().soliWrapperList);
                            cmp.set("v.SerialIds2Exempt", response.getReturnValue().SerialIds2Exempt);
                            cmp.set("v.stockMap", response.getReturnValue().stockMap);
                            cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                            cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                            //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                            cmp.set("v.showSN", response.getReturnValue().showSN);
                            cmp.set("v.showBatch", response.getReturnValue().showBatch);
                            cmp.set("v.barcodeLocMsg", response.getReturnValue().barcodeLocMsg);
                            cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                            cmp.set("v.PreventChange", false);
                            //cmp.createPicks();
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get('$Label.c.Success'),
                                "message": $A.get('$Label.c.Picked_successfully'),
                                "type": "success",
                            });
                            toastEvent.fire();
                            
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }
                        cmp.set("v.initialSTOLISerial", "");
                        */
                    }
                    else{
                        console.log("error --> ", response.getReturnValue().exceptionError);
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }
                else{
                    var errors = response.getError();
                    console.log("server error : ", errors);
                    cmp.set("v.exceptionError", errors[0].message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        } 
        else if(cmp.get("v.exceptionError") != '') {
            cmp.set("v.exceptionError", cmp.get('v.exceptionError'));
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        
    },
    
    selectAllSerials : function (cmp,event) {
        var checkedval = event.getSource().get('v.checked');
        cmp.set('v.selectAllSerials', checkedval);
        var obj = cmp.get("v.PickSerialNos");
        var showSerialsCount = cmp.get("v.showSerials");
        //alert(showSerialsCount);
        var i = 0;
        for(var x in obj){
            if(i < showSerialsCount){
                obj[x].isSelected = checkedval;
                i++;
            }
        }
        //alert(showSerialsCount);
        cmp.set("v.PickSerialNos", obj);
        cmp.set("v.disableAdd",!checkedval);
    },
    SetShowSerial : function(cmp, event, helper) {
        var obj = cmp.get("v.PickSerialNos");
        for(var x in obj){
            obj[x].isSelected = false;
        }
        cmp.set("v.PickSerialNos", obj);
        cmp.set('v.selectAllSerials', false);
    },
    
    
    
})