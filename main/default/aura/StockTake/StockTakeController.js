({
    verifyScanCode: function (component, event, helper) {
        try {
            var scan_Code = component.get("v.scanValue");
            console.log('verifyScanCode scan_Code : ', scan_Code);
            if (!$A.util.isEmpty(scan_Code) && !$A.util.isUndefinedOrNull(scan_Code)) {
                if (scan_Code == 'CANCEL') {
                    component.set("v.scanValue", '');
                    window.history.back();
                } else if (scan_Code == 'SAVE') {
                    $A.enqueueAction(component.get('c.updateStock'));
                    component.set("v.scanValue", '');
                } else {
                    if (component.get("v.currentEmpChannel") != null && component.get("v.currentEmpChannel") != undefined && component.get("v.currentEmpChannel") != '') {
                        component.set("v.showSpinner",true);
                        var found = false;
                        var allProductsList = component.get('v.allProductsList'); 
                        var Prods = component.get('v.products'); 
                        var BarcodeAction = component.get("c.SearchScanCode");
                        BarcodeAction.setParams({
                            "scanCode": scan_Code,
                            "selectedsite": component.get("v.selectedSite"),
                        });
                        BarcodeAction.setCallback(this, function (response) {
                            if (response.getState() === 'SUCCESS') {
                                if (response.getReturnValue() != null) {
                                    console.log('BarcodeAction resp not null');
                                    var obj = JSON.parse(response.getReturnValue());
                                    var stockTake = component.get("v.stockTake");
                                    if (obj.step == "Site") {
                                        var allsites = component.get("v.stSiteOptions");
                                        var siteexists = false;
                                        component.set("v.selectedlocation", '');
                                        component.set("v.selectedlocName", '');
                                        for (var i in allsites) {
                                            if (obj.Id == allsites[i].value) {
                                                siteexists = true;
                                                break;
                                            }
                                        }
                                        if (siteexists) {
                                            found = true;
                                            component.set("v.step", 'location');
                                            var reload = false;
                                            if (obj.Id == component.get("v.selectedSite")) {
                                                helper.showToast('Info', 'info', $A.get('$Label.c.Site_StockTake')+ ' ' + obj.Name + $A.get('$Label.c.already_selected'));//label for site
                                                reload = false;
                                            } else {
                                                helper.showToast('Info', 'info', $A.get('$Label.c.Site_StockTake')+ ' ' + obj.Name +' '+ $A.get('$Label.c.scanned'));//label for scanned and site
                                                reload = true;
                                            }
                                            stockTake.ERP7__Site__c = obj.Id;
                                            stockTake.ERP7__Site__r = { Name: obj.Name, Id: obj.Id };
                                            component.set('v.selectedSite', obj.Id);
                                            component.set("v.stockTake", stockTake);
                                            if (reload) $A.enqueueAction(component.get('c.fetchAllDetails'));
                                        } else {
                                            helper.showToast('Info', 'info', $A.get('$Label.c.Site_StockTake')+ ' ' + obj.Name + $A.get('$Label.c.does_not_belong_to_the_selected_channel'));//label for site
                                        }
                                    }
                                    else if (obj.step == "location") {
                                        found = true;
                                        component.set("v.step", "product");
                                        //var reload = false;
                                        if (obj.Id == component.get("v.selectedlocation")) {
                                            component.set("v.scanmsg",$A.get('$Label.c.InventoryConsole_Location')+' ' + obj.Name + $A.get('$Label.c.already_scanned_Please_scan_the_Products'));//label for location
                                            helper.showToast('Info', 'info', $A.get('$Label.c.InventoryConsole_Location')+' ' + obj.Name + $A.get('$Label.c.already_scanned'));//label for location
                                            //reload = false;
                                        } else {
                                            component.set("v.scanmsg",$A.get('$Label.c.InventoryConsole_Location')+' ' + obj.Name + $A.get('$Label.c.scanned_Please_scan_the_Products'));//label for location
                                            //helper.showToast('Info', 'info', 'Location ' + obj.Name + ' scanned.');
                                            //reload = true;
                                        }
                                        component.set("v.selectedlocation", obj.Id);
                                        component.set("v.selectedlocName", obj.Name);
                                        //if (reload) helper.getAllProds(component,event,component.get("v.selectedlocation"),component.get("v.scannedProduct")); //$A.enqueueAction(component.get('c.fetchAllDetails'));
                                    }
                                }
                                else {
                                    if (!$A.util.isEmpty(component.get("v.selectedSite")) && !$A.util.isUndefinedOrNull(component.get("v.selectedSite"))) {
                                        if (!$A.util.isEmpty(component.get("v.scannedProduct")) && !$A.util.isUndefinedOrNull(component.get("v.scannedProduct")) && !$A.util.isEmpty(component.get("v.scannedInventory")) && !$A.util.isUndefinedOrNull(component.get("v.scannedInventory"))){
                                            for(var i in Prods){
                                                if (!$A.util.isEmpty(Prods[i].stockTakeLineItem) && !$A.util.isUndefinedOrNull(Prods[i].stockTakeLineItem)) {
                                                    if (!$A.util.isEmpty(Prods[i].stockTakeLineItem.ERP7__Inventory_Stock__c) && !$A.util.isUndefinedOrNull(Prods[i].stockTakeLineItem.ERP7__Inventory_Stock__c)) {
                                                        if (!$A.util.isEmpty(Prods[i].stockTakeLineItem.ERP7__Product__c) && !$A.util.isUndefinedOrNull(Prods[i].stockTakeLineItem.ERP7__Product__c)) {
                                                            if(Prods[i].stockTakeLineItem.ERP7__Product__c == component.get("v.scannedProduct") && Prods[i].stockTakeLineItem.ERP7__Inventory_Stock__c == component.get("v.scannedInventory")){
                                                                if(Prods[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c == scan_Code && Prods[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c == false && Prods[i].stockTakeLineItem.ERP7__Product__r.ERP7__Lot_Tracked__c == false){
                                                                    found = true;
                                                                    component.set("v.step", "product");
                                                                    component.set("v.scannedProduct", Prods[i].stockTakeLineItem.ERP7__Product__c);
                                                                    component.set("v.scannedInventory", Prods[i].stockTakeLineItem.ERP7__Inventory_Stock__c);
                                                                    //component.set("v.scannedIndx", i);
                                                                    console.log('ntserial ntlot prod scanned again updating variance');
                                                                    helper.updatevariances(component,event,helper,i,Prods,Prods[i].stockTakeLineItem.ERP7__Product__c,Prods[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c,true);
                                                                    //do something
                                                                    break;
                                                                }
                                                                else if(Prods[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c){
                                                                    if (!$A.util.isEmpty(Prods[i].stockTakeLineItem.ERP7__Serial__c) && !$A.util.isUndefinedOrNull(Prods[i].stockTakeLineItem.ERP7__Serial__c)) {
                                                                        if (!$A.util.isEmpty(Prods[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c) && !$A.util.isUndefinedOrNull(Prods[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c)) {
                                                                            if (Prods[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c == scan_Code || Prods[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Barcode__c == scan_Code) {
                                                                                found = true;
                                                                                component.set("v.step", "product");
                                                                                component.set("v.scannedProduct",'');
                                                                                component.set("v.scannedInventory",'');
                                                                                //component.set("v.scannedIndx", -1);
                                                                                //dosomething
                                                                                console.log('first scan serial found updating variancenow');
                                                                                helper.updatevariances(component,event,helper,i,Prods,Prods[i].stockTakeLineItem.ERP7__Product__c,Prods[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c,true);
                                                                                break;
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                    else if(Prods[i].stockTakeLineItem.ERP7__Product__r.ERP7__Lot_Tracked__c){
                                                                        if (!$A.util.isEmpty(Prods[i].stockTakeLineItem.ERP7__Material_Batch_Lot__c) && !$A.util.isUndefinedOrNull(Prods[i].stockTakeLineItem.ERP7__Material_Batch_Lot__c)) {
                                                                            if (!$A.util.isEmpty(Prods[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name) && !$A.util.isUndefinedOrNull(Prods[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name)) {
                                                                                if (Prods[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name == scan_Code || Prods[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.ERP7__Barcode__c == scan_Code) {
                                                                                    found = true;
                                                                                    component.set("v.step", "product");
                                                                                    component.set("v.scannedProduct",'');
                                                                                    component.set("v.scannedInventory",'');
                                                                                    //component.set("v.scannedIndx", -1);
                                                                                    console.log('first scan Lot found updating variancenow');
                                                                                    helper.updatevariances(component,event,helper,i,Prods,Prods[i].stockTakeLineItem.ERP7__Product__c,Prods[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c,true);
                                                                                    //do something
                                                                                    break;
                                                                                }
                                                                            }
                                                                        }
                                                                    } 
                                                                else console.log('in else prods');
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        if(!found){
                                            console.log('scannedprod scannedinv empty');
                                            for (var i in allProductsList) {
                                                if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem)) {
                                                    if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Inventory_Stock__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Inventory_Stock__c)) {
                                                        if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Product__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Product__c)) {
                                                            if(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c == scan_Code && allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c == false && allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Lot_Tracked__c == false){
                                                                found = true;
                                                                component.set("v.step", "product");
                                                                component.set("v.scannedProduct", allProductsList[i].stockTakeLineItem.ERP7__Product__c);
                                                                component.set("v.scannedInventory",allProductsList[i].stockTakeLineItem.ERP7__Inventory_Stock__c);
                                                                //component.set("v.scannedIndx", i);
                                                                console.log('ntserial ntlot prod first scanned updating msg');
                                                                var msg = ''+allProductsList[i].stockTakeLineItem.ERP7__Product__r.Name+ ' '+$A.get('$Label.c.scanned')+$A.get('$Label.c.please_proceed_further');//last 2 labels added
                                                                component.set("v.scanmsg",msg);
                                                                //helper.updatevariances(component,event,helper,i,allProductsList,allProductsList[i].stockTakeLineItem.ERP7__Product__c,allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c,false);
                                                                //do something
                                                                break;
                                                            } 
                                                            else if(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c){
                                                                if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Serial__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Serial__c)) {
                                                                    if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c)) {
                                                                        if (allProductsList[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c == scan_Code || allProductsList[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Barcode__c == scan_Code) {
                                                                            found = true;
                                                                            component.set("v.step", "product");
                                                                            component.set("v.scannedProduct",'');
                                                                            component.set("v.scannedInventory",'');
                                                                            component.set("v.scannedIndx", -1);
                                                                            //dosomething
                                                                            console.log('first scan serial found updating variancenow');
                                                                            helper.updatevariances(component,event,helper,i,allProductsList,allProductsList[i].stockTakeLineItem.ERP7__Product__c,allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c,false);
                                                                            break;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                                else if(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Lot_Tracked__c){
                                                                    if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__c)) {
                                                                        if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name)) {
                                                                            if (allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name == scan_Code || allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.ERP7__Barcode__c == scan_Code) {
                                                                                found = true;
                                                                                component.set("v.step", "product");
                                                                                component.set("v.scannedProduct",'');
                                                                                component.set("v.scannedInventory",'');
                                                                                //component.set("v.scannedIndx", -1);
                                                                                console.log('first scan Lot found updating variancenow');
                                                                                helper.updatevariances(component,event,helper,i,allProductsList,allProductsList[i].stockTakeLineItem.ERP7__Product__c,allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c,false);
                                                                                //do something
                                                                                break;
                                                                            }
                                                                        }
                                                                    }
                                                                } 
                                                            else console.log('in else allProductsList');
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else {
                                found = false;
                                var errors = response.getError();
                                console.log("server error in BarcodeAction : ", errors);
                                
                            }
                            if(found){
                                console.log('found true');
                                //sort by scanned indx at first//
                            }
                            else {
                                console.log('found false');
                                component.set("v.scanmsg",'');
                                helper.showToast('Info', 'info', $A.get('$Label.c.PH_OB_Invalid_barcode_scanned'));
                            }
                            component.set("v.scanValue", '');
                            component.set("v.showSpinner",false);
                        });
                        $A.enqueueAction(BarcodeAction);
                    }
                    else {
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'Error', $A.get('$Label.c.Please_select_a_channel'));
                        component.set("v.scanmsg",'');
                        component.set("v.scanValue", '');
                    }
                } 
            }
        } catch (e) {
            console.log('error verifyScanCode~>' + e);
            helper.showToast('Info', 'info', $A.get('$Label.c.PH_OB_Invalid_barcode_scanned'));
            component.set("v.scanmsg",'');
            component.set("v.scanValue", '');
        }
    },
    
    /* verifyScanCode: function (component, event, helper) {
        try {
            var scan_Code = component.get("v.scanValue");
            console.log('scan_Code : ', scan_Code);
            if (!$A.util.isEmpty(scan_Code) && !$A.util.isUndefinedOrNull(scan_Code)) {
                helper.showSpinner(component, event);
                if (scan_Code == 'CANCEL') {
                    window.history.back();
                } else if (scan_Code == 'SAVE') {
                    $A.enqueueAction(component.get('c.updateStock'));
                } else {
                    var found = false;
                    var allProductsList = component.get('v.allProductsList'); //v.allProductsList
                    if (component.get("v.currentEmpChannel") != null && component.get("v.currentEmpChannel") != undefined && component.get("v.currentEmpChannel") != '') {
                        console.log('currentEmpChannel not empty');
                        if (component.get("v.step") == "Site" || component.get("v.step") == "location") {
                            console.log('step site/loc here');
                            var BarcodeAction = component.get("c.SearchScanCode");
                            BarcodeAction.setParams({
                                "scanCode": scan_Code,
                                "selectedsite": component.get("v.selectedSite"),
                            });
                            BarcodeAction.setCallback(this, function (response) {
                                if (response.getState() === 'SUCCESS') {
                                    helper.hideSpinner(component, event);
                                    if (response.getReturnValue() != null) {
                                        console.log('BarcodeAction resp not null');
                                        var obj = JSON.parse(response.getReturnValue());
                                        var stockTake = component.get("v.stockTake");
                                        if (obj.step == "Site") {
                                            var allsites = component.get("v.stSiteOptions");
                                            var siteexists = false;
                                            component.set("v.selectedlocation", '');
                                            component.set("v.selectedlocName", '');
                                            for (var i in allsites) {
                                                if (obj.Id == allsites[i].value) {
                                                    siteexists = true;
                                                    break;
                                                }
                                            }
                                            if (siteexists) {
                                                found = true;
                                                component.set("v.step", 'location');
                                                var reload = false;
                                                if (obj.Id == component.get("v.selectedSite")) {
                                                    helper.showToast('Info', 'info', 'Site ' + obj.Name + ' already selected.');
                                                    reload = false;
                                                } else {
                                                    helper.showToast('Info', 'info', 'Site ' + obj.Name + ' scanned.');
                                                    reload = true;
                                                }
                                                stockTake.ERP7__Site__c = obj.Id;
                                                stockTake.ERP7__Site__r = { Name: obj.Name, Id: obj.Id };
                                                component.set('v.selectedSite', obj.Id);
                                                component.set("v.stockTake", stockTake);
                                                if (reload) $A.enqueueAction(component.get('c.fetchAllDetails'));
                                            } else {
                                                helper.showToast('Info', 'info', 'Site ' + obj.Name + ' does not belong to the selected channel.');
                                            }
                                        }
                                        else if (obj.step == "location") {
                                            found = true;
                                            component.set("v.step", "product");
                                            var reload = false;
                                            if (obj.Id == component.get("v.selectedlocation")) {
                                                helper.showToast('Info', 'info', 'Location ' + obj.Name + ' already scanned.');
                                                reload = false;
                                            } else {
                                                helper.showToast('Info', 'info', 'Location ' + obj.Name + ' scanned.');
                                                reload = true;
                                            }
                                            component.set("v.selectedlocation", obj.Id);
                                            component.set("v.selectedlocName", obj.Name);
                                            if (reload) helper.getAllProds(component,event,component.get("v.selectedlocation"),component.get("v.scannedProduct")); //$A.enqueueAction(component.get('c.fetchAllDetails'));
                                        }
                                    }
                                    else {
                                        console.log('BarcodeAction resp null, not found , looking for products to sort out');
                                        for (var i in allProductsList) {
                                            if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem)) {
                                                if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Product__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Product__c)) {
                                                    if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c)) {
                                                        if (allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c == scan_Code) {
                                                            found = true;
                                                            component.set("v.step", "product");
                                                            var reload = false;
                                                            if (allProductsList[i].stockTakeLineItem.ERP7__Product__c == component.get("v.scannedProduct")) {
                                                                helper.showToast('Info', 'info', 'Product ' + allProductsList[i].stockTakeLineItem.ERP7__Product__r.Name + ' already scanned.');
                                                                reload = false;
                                                            } else {
                                                                helper.showToast('Info', 'info', 'Product ' + allProductsList[i].stockTakeLineItem.ERP7__Product__r.Name + ' scanned.');
                                                                reload = true;
                                                            }
                                                            component.set("v.scannedProduct", allProductsList[i].stockTakeLineItem.ERP7__Product__c);
                                                            component.set("v.scannedProductName", allProductsList[i].stockTakeLineItem.ERP7__Product__r.Name);
                                                            if (reload) helper.getAllProds(component,event,component.get("v.selectedlocation"),component.get("v.scannedProduct")); //$A.enqueueAction(component.get('c.fetchAllDetails'));
                                                            break;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else {
                                    found = false;
                                    var errors = response.getError();
                                    console.log("server error in BarcodeAction : ", errors);
                                   
                                }
                                if (!found) helper.showToast('Info', 'info', 'Invalid Barcode Scanned');
                            });
                            $A.enqueueAction(BarcodeAction);
                        }
                        else {
                            if (component.get("v.step") === "product") {
                                if ($A.util.isEmpty(component.get("v.scannedProduct")) || $A.util.isUndefinedOrNull(component.get("v.scannedProduct"))) {
                                    console.log('looking for prod to sort out');
                                    for (var i in allProductsList) {
                                        if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem)) {
                                            if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Product__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Product__c)) {
                                                if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c)) {
                                                    if (allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c == scan_Code) {
                                                        found = true;
                                                        component.set("v.step", "product");
                                                        var reload = false;
                                                        if (allProductsList[i].stockTakeLineItem.ERP7__Product__c == component.get("v.scannedProduct")) {
                                                            helper.showToast('Info', 'info', 'Product ' + allProductsList[i].stockTakeLineItem.ERP7__Product__r.Name + ' already scanned.');
                                                            reload = false;
                                                        } else {
                                                            helper.showToast('Info', 'info', 'Product ' + allProductsList[i].stockTakeLineItem.ERP7__Product__r.Name + ' scanned.');
                                                            reload = true;
                                                        }
                                                        component.set("v.scannedProduct", allProductsList[i].stockTakeLineItem.ERP7__Product__c);
                                                        component.set("v.scannedProductName", allProductsList[i].stockTakeLineItem.ERP7__Product__r.Name);
                                                        if (reload) helper.getAllProds(component,event,component.get("v.selectedlocation"),component.get("v.scannedProduct")); //$A.enqueueAction(component.get('c.fetchAllDetails'));
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }else{
                                    //todo
                                    console.log('prod already there looking for prod again/serial/lot/');
                                    var prodBarcodeFound = false;
                                    var prodSerialFound = false;
                                    var prodBatchFound = false;
                                    for (var i in allProductsList) {
                                        if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem)) {
                                            if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Product__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Product__c)) {
                                                if (allProductsList[i].stockTakeLineItem.ERP7__Product__c == component.get("v.scannedProduct")) {
                                                    if(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c == false && allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Lot_Tracked__c == false){
                                                        if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c)) {
                                                            if (allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Barcode__c == scan_Code) {
                                                                prodBarcodeFound = true;
                                                                //do something
                                                                break;
                                                            }
                                                        }
                                                    }else if(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c){
                                                        if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Serial__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Serial__c)) {
                                                            if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c)) {
                                                                if (allProductsList[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c == scan_Code || allProductsList[i].stockTakeLineItem.ERP7__Serial__r.ERP7__Barcode__c == scan_Code) {
                                                                    prodSerialFound = true;
                                                                    //do something
                                                                    break;
                                                                }
                                                            }
                                                        }
                                                    }else if(allProductsList[i].stockTakeLineItem.ERP7__Product__r.ERP7__Lot_Tracked__c){
                                                        if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__c) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__c)) {
                                                            if (!$A.util.isEmpty(allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name) && !$A.util.isUndefinedOrNull(allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name)) {
                                                                if (allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.Name == scan_Code || allProductsList[i].stockTakeLineItem.ERP7__Material_Batch_Lot__r.ERP7__Barcode__c == scan_Code) {
                                                                    prodBatchFound = true;
                                                                    //do something
                                                                    break;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    //todo
                                }
                            }
                            if (!found) helper.showToast('Info', 'info', 'Invalid Barcode Scanned');
                        }
                    }
                    else {
                        helper.showToast('Error', 'Error', 'Please select a channel');
                    }
                }
                
                helper.hideSpinner(component, event);
                component.set("v.scanValue", '');
            } else {
                console.log('scan_Code null');
                component.set("v.scanValue", '');
            }
        } catch (e) {
            console.log('error verifyScanCode~>' + e);
        }
    },
    */
    
    fetchAllDetails: function (component, event, helper) {
        console.log('prodRecordId fetchAllDetails 1: ',component.get("v.prodRecordId"));
        component.set("v.showSpinner",true);
        if (!component.get("v.PreventChange")) {
            component.set("v.selectedlocation",'');
            component.set("v.selectedlocName",'');
            console.log('fetchAllDetails called stockTakeId~>' + component.get("v.stockTakeId"));
            component.set("v.PreventChange", true);
            var show = component.get("v.show");
            var channel = '';
            var site = '';
            var recId = '';
            if(!$A.util.isEmpty(component.get("v.currentEmpChannel")) && !$A.util.isUndefinedOrNull(component.get("v.currentEmpChannel"))){
                channel = component.get("v.currentEmpChannel");
            }
            if(!$A.util.isEmpty(component.get("v.selectedChannel")) && !$A.util.isUndefinedOrNull(component.get("v.selectedChannel"))){
                channel = component.get("v.selectedChannel");
            }
            if(!$A.util.isEmpty(component.get("v.selectedSite")) && !$A.util.isUndefinedOrNull(component.get("v.selectedSite"))){
                site = component.get("v.selectedSite");
            }
            if(!$A.util.isEmpty(component.get("v.stockTakeId")) && !$A.util.isUndefinedOrNull(component.get("v.stockTakeId"))){
                recId = component.get("v.stockTakeId");
            }
            var showlocationStocks = component.get("v.showLocationStocks");
            var action = component.get("c.getAllDetails");
            action.setParams({ recordId: recId, searchText: component.get("v.searchString"), Channel: channel, Site: site, Offset: 0, Show: show ,location : component.get("v.stockTake.ERP7__Location__c"), showlocStocks : showlocationStocks,ProdId : component.get("v.prodRecordId")});
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    console.log('fetchAllDetails response.getReturnValue() : ', response.getReturnValue());
                    let stAudit = [];
                    let resstAudit = response.getReturnValue().stAudit;
                    for (let x in resstAudit) {
                        var obj = { "class": "optionClass", label: resstAudit[x].label, value: resstAudit[x].value };
                        stAudit.push(obj);
                    }
                    component.set("v.stauditOptions", stAudit);
                    //component.set("v.searchString", "");
                    let stockOutwardStatus = [];
                    let resstockOutwardStatus = response.getReturnValue().stockOutwardStatus;
                    for (let x in resstockOutwardStatus) {
                        var obj = { "class": "optionClass", label: resstockOutwardStatus[x].label, value: resstockOutwardStatus[x].value };
                        stockOutwardStatus.push(obj);
                    }
                    component.set("v.outWardStatus", stockOutwardStatus);
                    
                    let stockInwardReason = [];
                    let resstockInwardReason = response.getReturnValue().stockInwardReason;
                    for (let x in resstockInwardReason) {
                        var obj = { "class": "optionClass", label: resstockInwardReason[x].label, value: resstockInwardReason[x].value };
                        stockInwardReason.push(obj);
                    }
                    component.set("v.inWardReason", stockInwardReason);
                    
                    component.set("v.stSiteOptions", response.getReturnValue().channelSites);
                    component.set("v.selectedSite", response.getReturnValue().selectedSite);
                    if (response.getReturnValue().selectedSite != undefined && response.getReturnValue().selectedSite != null && response.getReturnValue().selectedSite != '') {
                        console.log('step here is~>' + component.get("v.step"));
                        if (component.get("v.step") != 'product') component.set("v.step", 'location');
                        //if (component.get("v.step") == 'location') component.set("v.step", 'product');
                        //else if (component.get("v.step") == 'Site') component.set("v.step", 'location');
                    } else {
                        component.set("v.step", 'Site');
                    }
                    component.set("v.stStatusOptions", response.getReturnValue().statusOption);
                    component.set('v.ShowAudit', response.getReturnValue().displayAudit);
                    component.set('v.showProdCode', response.getReturnValue().showProdCode);
                    component.set('v.showApprover', response.getReturnValue().showApprover);
                    component.set('v.showStockAddress', response.getReturnValue().displayStockAddress);
                    component.set('v.showVenCode', response.getReturnValue().showVendorCode);
                    
                    component.set("v.Container", response.getReturnValue());
                    component.set('v.showAdjustedQty',response.getReturnValue().showAdjustedQty);
                    console.log('here1');

                    component.set("v.stockTake", response.getReturnValue().StockTakeRec);
                   
                    if (response.getReturnValue().StockTakeRec != undefined && response.getReturnValue().StockTakeRec != null) {
                        if (response.getReturnValue().StockTakeRec.Id != undefined && response.getReturnValue().StockTakeRec.Id != null) {
                            if (response.getReturnValue().StockTakeRec.ERP7__Status__c != undefined && response.getReturnValue().StockTakeRec.ERP7__Status__c != null && response.getReturnValue().StockTakeRec.ERP7__Status__c != '') {
                                component.set("v.stockTakeStat", response.getReturnValue().StockTakeRec.ERP7__Status__c);
                            }
                        }
                    }
                    
                    console.log('here2');
                    component.set("v.currentEmployee", response.getReturnValue().Employee);
                    if (response.getReturnValue().Employee != undefined && response.getReturnValue().Employee != null) {
                        if (response.getReturnValue().Employee.Id != undefined && response.getReturnValue().Employee.Id != null) {
                            if (response.getReturnValue().Employee.ERP7__Channel__c != undefined && response.getReturnValue().Employee.ERP7__Channel__c != null) {
                                component.set("v.currentEmpChannel", response.getReturnValue().Employee.ERP7__Channel__c);
                            }
                        }
                    }
                    
                    console.log('here3');
                    component.set("v.products", response.getReturnValue().stockTakeWrapperList);
                    component.set("v.adjustedProducts", response.getReturnValue().adjustedstockTakeWrapperList);
                    component.set("v.allProductsList", response.getReturnValue().allstockTakeWrapperList);
                    component.set("v.allProductsListdum", response.getReturnValue().allstockTakeWrapperList);
                    if (component.get("v.products").length <= 0 && component.get("v.adjustedProducts").length <= 0) helper.showToast('Info', 'info', $A.get('$Label.c.No_Products_Available'));
                    component.set("v.exceptionError", response.getReturnValue().exceptionError);
                    component.set("v.PreventChange", false);
                    component.set("v.showSpinner",false);
                    component.set("v.prodRecordId", ''); // added by shaguftha on 13_02_24
                } else {
                    component.set("v.PreventChange", false);
                    var errors = response.getError();
                    console.log("server error in fetchAllDetails : ", errors);
                    component.set("v.exceptionError", errors[0].message);
                    component.set("v.showSpinner",false);
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.showSpinner",false);
        }
    },
    
    LoadNow: function (component, event, helper) {
        console.log('LoadNow called');
        var show = component.get("v.show");
        var offset = component.get("v.Container.Offset");
        var searchtext = '';
        var channel = '';
        var site = '';
        var recId = '';
        var Location = '';
        
        if(!$A.util.isEmpty(component.get("v.currentEmpChannel")) && !$A.util.isUndefinedOrNull(component.get("v.currentEmpChannel"))){
            channel = component.get("v.currentEmpChannel");
        }
        if(!$A.util.isEmpty(component.get("v.selectedSite")) && !$A.util.isUndefinedOrNull(component.get("v.selectedSite"))){
            site = component.get("v.selectedSite");
        }

        if(!$A.util.isEmpty(component.get("v.stockTakeId")) && !$A.util.isUndefinedOrNull(component.get("v.stockTakeId"))){
            recId = component.get("v.stockTakeId");
            component.set("v.recordId", component.get("v.stockTakeId"));
        }
        if(!$A.util.isEmpty(component.get("v.searchString")) && !$A.util.isUndefinedOrNull(component.get("v.searchString"))){
            searchtext = component.get("v.searchString");
        }
        console.log('searchtext : ',searchtext);
        if (!component.get("v.PreventChange")) { //&& channel != ""
            console.log('LoadNow called inhere');
            component.set("v.selectedlocation",'');
            component.set("v.selectedlocName",'');
            component.set("v.PreventChange", true);
            console.log('LoadNow offset~>' + offset + ' show~>' + show);
            component.set("v.showSpinner",true);
            //changes by shaguftha 01_01_24
           var adjustedlist = component.get("v.products");
            var excludeInventoryRecs = [];
            var newadjustedlist = [];
            for(var x in adjustedlist){
                if(adjustedlist[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != null && adjustedlist[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != '' && adjustedlist[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != undefined){
                    newadjustedlist.push(adjustedlist[x]);
                    excludeInventoryRecs.push(adjustedlist[x].stockTakeLineItem.ERP7__Inventory_Stock__c);
                }
            }
            console.log('newadjustedlist : ',JSON.stringify(newadjustedlist));
            var action = component.get("c.getAllDetails");
            action.setParams({
                recordId: recId,
                searchText: searchtext,
                Channel: channel,
                Site: site,
                Offset: offset,
                Show: show,
                location : component.get("v.stockTake.ERP7__Location__c"),
                inventoryRecs : JSON.stringify(excludeInventoryRecs),
                showlocStocks : component.get("v.showLocationStocks")
            });
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    let stAudit = [];
                    let resstAudit = response.getReturnValue().stAudit;
                    for (let x in resstAudit) {
                        var obj = { "class": "optionClass", label: resstAudit[x].label, value: resstAudit[x].value };
                        stAudit.push(obj);
                    }
                    component.set("v.stauditOptions", stAudit);
                    
                    let stockOutwardStatus = [];
                    let resstockOutwardStatus = response.getReturnValue().stockOutwardStatus;
                    for (let x in resstockOutwardStatus) {
                        var obj = { "class": "optionClass", label: resstockOutwardStatus[x].label, value: resstockOutwardStatus[x].value };
                        stockOutwardStatus.push(obj);
                    }
                    component.set("v.outWardStatus", stockOutwardStatus);
                    
                    let stockInwardReason = [];
                    let resstockInwardReason = response.getReturnValue().stockInwardReason;
                    for (let x in resstockInwardReason) {
                        var obj = { "class": "optionClass", label: resstockInwardReason[x].label, value: resstockInwardReason[x].value };
                        stockInwardReason.push(obj);
                    }
                    component.set("v.inWardReason", stockInwardReason);
                    
                    component.set("v.stSiteOptions", response.getReturnValue().channelSites);
                    component.set("v.selectedSite", response.getReturnValue().selectedSite);
                    if (response.getReturnValue().selectedSite != undefined && response.getReturnValue().selectedSite != null && response.getReturnValue().selectedSite != '') {
                        component.set("v.step", 'location');
                    } else {
                        component.set("v.step", 'Site');
                    }
                    component.set("v.stStatusOptions", response.getReturnValue().statusOption);
                    component.set('v.ShowAudit', response.getReturnValue().displayAudit);
                    component.set('v.showStockAddress', response.getReturnValue().displayStockAddress);
                    component.set('v.showProdCode', response.getReturnValue().showProdCode);
                    component.set('v.showApprover', response.getReturnValue().showApprover);
                    component.set("v.Container", response.getReturnValue());
                    
                    console.log('here1');
                    component.set("v.stockTake", response.getReturnValue().StockTakeRec);
                    if (response.getReturnValue().StockTakeRec != undefined && response.getReturnValue().StockTakeRec != null) {
                        if (response.getReturnValue().StockTakeRec.Id != undefined && response.getReturnValue().StockTakeRec.Id != null) {
                            if (response.getReturnValue().StockTakeRec.ERP7__Status__c != undefined && response.getReturnValue().StockTakeRec.ERP7__Status__c != null && response.getReturnValue().StockTakeRec.ERP7__Status__c != '') {
                                component.set("v.stockTakeStat", response.getReturnValue().StockTakeRec.ERP7__Status__c);
                            }
                        }
                    }
                    
                    console.log('here2');
                    component.set("v.currentEmployee", response.getReturnValue().Employee);
                    if (response.getReturnValue().Employee != undefined && response.getReturnValue().Employee != null) {
                        if (response.getReturnValue().Employee.Id != undefined && response.getReturnValue().Employee.Id != null) {
                            if (response.getReturnValue().Employee.ERP7__Channel__c != undefined && response.getReturnValue().Employee.ERP7__Channel__c != null) {
                                component.set("v.currentEmpChannel", response.getReturnValue().Employee.ERP7__Channel__c);
                            }
                        }
                    }
                    
                    console.log('here3 LoadNow prodslength~>' + response.getReturnValue().stockTakeWrapperList.length + ' adjprodslength~>' + response.getReturnValue().adjustedstockTakeWrapperList.length);
                    if(newadjustedlist != undefined && newadjustedlist.length > 0){
                        var prods = response.getReturnValue().stockTakeWrapperList;
                       
                        var finalprods = prods.concat(newadjustedlist);
                        console.log('finalprods : ',JSON.stringify(finalprods));
                        component.set("v.products", finalprods);
                        
                        var allprods = response.getReturnValue().allstockTakeWrapperList;
                        var allfinalprods = allprods.concat(newadjustedlist);
                        component.set("v.allProductsList", allfinalprods);
                    }
                    else {
                        component.set("v.products", response.getReturnValue().stockTakeWrapperList);
                        component.set("v.allProductsList", response.getReturnValue().allstockTakeWrapperList);
                    }
                    component.set("v.adjustedProducts", response.getReturnValue().adjustedstockTakeWrapperList);
                    //&& component.get("v.adjustedProducts").length <= 0 removed this from belpw line as the search is applicable to below products
                    if (component.get("v.products").length <= 0) helper.showToast('Info', 'info', $A.get('$Label.c.No_Products_Available'));
                    component.set("v.exceptionError", response.getReturnValue().exceptionError);
                    component.set("v.PreventChange", false);
                    component.set("v.showSpinner",false);
                } else {
                    component.set("v.PreventChange", false);
                    var errors = response.getError();
                    console.log("server error in LoadNow : ", errors);
                    component.set("v.exceptionError", errors[0].message);
                    component.set("v.showSpinner",false);
                }
                
            });
            $A.enqueueAction(action);
            
        }
        else{
            console.log('did not go in LoadNow');
        }
    },
    
    LoadChannelChange: function (component, event, helper) {
        console.log('LoadChannelChange called');
        if (!component.get("v.PreventChange")) {
            console.log('LoadChannelChange called inhere');
            component.set("v.PreventChange", true);
            window.scrollTo(0, 0);
            component.set("v.Container.Offset", 0);
            var show = component.get("v.show");
            var offset = component.get("v.Container.Offset");
            var searchtext = '';
            var channel = '';
            var site = '';
            
            if(!$A.util.isEmpty(component.get("v.currentEmpChannel")) && !$A.util.isUndefinedOrNull(component.get("v.currentEmpChannel"))){
                channel = component.get("v.currentEmpChannel");
            }
            if(!$A.util.isEmpty(component.get("v.selectedSite")) && !$A.util.isUndefinedOrNull(component.get("v.selectedSite"))){
                site = component.get("v.selectedSite");
            }
            if(!$A.util.isEmpty(component.get("v.searchString")) && !$A.util.isUndefinedOrNull(component.get("v.searchString"))){
                searchtext = component.get("v.searchString");
            }
            console.log('channel~>'+channel);
            if (channel != '') {
                component.set("v.selectedlocation",'');
                component.set("v.selectedlocName",'');
                component.set("v.showSpinner",true);
                var action = component.get("c.getAllDetails");
                action.setParams({ recordId: '', searchText: searchtext, Channel: channel, Site: site,  Offset: offset, Show: show });
                action.setCallback(this, function (response) {
                    if (response.getState() === "SUCCESS") {
                        let stAudit = [];
                        let resstAudit = response.getReturnValue().stAudit;
                        for (let x in resstAudit) {
                            var obj = { "class": "optionClass", label: resstAudit[x].label, value: resstAudit[x].value };
                            stAudit.push(obj);
                        }
                        component.set("v.stauditOptions", stAudit);
                        
                        let stockOutwardStatus = [];
                        let resstockOutwardStatus = response.getReturnValue().stockOutwardStatus;
                        for (let x in resstockOutwardStatus) {
                            var obj = { "class": "optionClass", label: resstockOutwardStatus[x].label, value: resstockOutwardStatus[x].value };
                            stockOutwardStatus.push(obj);
                        }
                        component.set("v.outWardStatus", stockOutwardStatus);
                        
                        let stockInwardReason = [];
                        let resstockInwardReason = response.getReturnValue().stockInwardReason;
                        for (let x in resstockInwardReason) {
                            var obj = { "class": "optionClass", label: resstockInwardReason[x].label, value: resstockInwardReason[x].value };
                            stockInwardReason.push(obj);
                        }
                        component.set("v.inWardReason", stockInwardReason);
                        
                        component.set("v.stSiteOptions", response.getReturnValue().channelSites);
                        component.set("v.selectedSite", response.getReturnValue().selectedSite);
                        if (response.getReturnValue().selectedSite != undefined && response.getReturnValue().selectedSite != null && response.getReturnValue().selectedSite != '') {
                            component.set("v.step", 'location');
                        } else {
                            component.set("v.step", 'Site');
                        }
                        component.set("v.stStatusOptions", response.getReturnValue().statusOption);
                        component.set('v.ShowAudit', response.getReturnValue().displayAudit);
                        component.set('v.showStockAddress', response.getReturnValue().displayStockAddress);
                        component.set('v.showProdCode', response.getReturnValue().showProdCode);
                        component.set('v.showApprover', response.getReturnValue().showApprover);
                        component.set("v.Container", response.getReturnValue());
                        
                        console.log('here1 showProdCode~>'+response.getReturnValue().showProdCode+' showApprover~>'+response.getReturnValue().showApprover);
                        component.set("v.stockTake", response.getReturnValue().StockTakeRec);
                        if (response.getReturnValue().StockTakeRec != undefined && response.getReturnValue().StockTakeRec != null) {
                            if (response.getReturnValue().StockTakeRec.Id != undefined && response.getReturnValue().StockTakeRec.Id != null) {
                                if (response.getReturnValue().StockTakeRec.ERP7__Status__c != undefined && response.getReturnValue().StockTakeRec.ERP7__Status__c != null && response.getReturnValue().StockTakeRec.ERP7__Status__c != '') {
                                    component.set("v.stockTakeStat", response.getReturnValue().StockTakeRec.ERP7__Status__c);
                                }
                            }
                        }
                        
                        console.log('here2');
                        component.set("v.currentEmployee", response.getReturnValue().Employee);
                        if (response.getReturnValue().Employee != undefined && response.getReturnValue().Employee != null) {
                            if (response.getReturnValue().Employee.Id != undefined && response.getReturnValue().Employee.Id != null) {
                                if (response.getReturnValue().Employee.ERP7__Channel__c != undefined && response.getReturnValue().Employee.ERP7__Channel__c != null) {
                                    component.set("v.currentEmpChannel", response.getReturnValue().Employee.ERP7__Channel__c);
                                }
                            }
                        }
                        
                        console.log('here3');
                        component.set("v.products", response.getReturnValue().stockTakeWrapperList);
                        component.set("v.adjustedProducts", response.getReturnValue().adjustedstockTakeWrapperList);
                        component.set("v.allProductsList", response.getReturnValue().allstockTakeWrapperList);
                        if (component.get("v.products").length <= 0 && component.get("v.adjustedProducts").length <= 0) helper.showToast('Info', 'info', $A.get('$Label.c.No_Products_Available'));
                        component.set("v.exceptionError", response.getReturnValue().exceptionError);
                        component.set("v.PreventChange", false);
                        component.set("v.showSpinner",false);
                    } else {
                        component.set("v.PreventChange", false);
                        var errors = response.getError();
                        console.log("server error in LoadNowChange : ", errors);
                        component.set("v.exceptionError", errors[0].message);
                        component.set("v.showSpinner",false);
                    }
                });
                $A.enqueueAction(action);
            } else {
                component.set("v.stSiteOptions", []);
                component.set("v.selectedSite", "");
                //component.set("v.Container", undefined);
                component.set("v.products", []);
                component.set("v.allProductsList", []);
                component.set("v.adjustedProducts", []);
                if (component.get("v.products").length <= 0 && component.get("v.adjustedProducts").length <= 0) helper.showToast('Info', 'info', $A.get('$Label.c.No_Products_Available'));
                component.set("v.exceptionError", '');
                var defcremp = {
                    'sobjectType': 'ERP7__Employees__c',
                    'ERP7__Channel__c': '',
                    'Name': '',
                }
                component.set("v.currentEmployee", defcremp);
                component.set("v.currentEmpChannel", "");
                component.set("v.PreventChange", false);
                component.set("v.showSpinner",false);
            }
            
        }
        else{
            console.log('did not go in LoadChannelChange');
        }
    },
    
    onchangeSearch: function (component, event, helper) {
        if (!component.get("v.PreventChange")) {
            component.set("v.Container.Offset", 0);
            component.LoadNow();
        }
    },
    
    onChangeSite: function (component, event, helper) {
        component.set("v.step", 'location');
        component.set("v.selectedlocation", '');
        component.set("v.selectedlocName", '');
        component.set("v.scannedProduct", '');
        component.set("v.scannedProductName", '');
        if (!component.get("v.PreventChange")) {
            component.set("v.Container.Offset", 0);
            component.LoadNow();
        }
    },
    onChangeLocation : function (component, event, helper) {
        try{
            console.log('Preventchange loc 1: ',component.get("v.PreventChange"));
            var loc = component.get("v.stockTake.ERP7__Location__c");
            console.log('loc :',loc);
            if(loc != null && loc != '' && loc != undefined){
                 //component.set("v.showSpinner",true);
                console.log('onChangeLocation called ');
                
                if(!component.get('v.loadlocationhelper')) {
                    helper.changeLocationHelper(component,loc,helper);
                    
                }
               /* var stockTakeWrapperList = component.get("v.allProductsList");
                console.log('all prod length : ',stockTakeWrapperList);
                var prodList = [];
                for(var x in stockTakeWrapperList){
                    //console.log('stockTakeWrapperList[x] : ',stockTakeWrapperList[x].showSelected);
                    if(stockTakeWrapperList[x].stockTakeLineItem.ERP7__Inventory_Stock__c != undefined && stockTakeWrapperList[x].stockTakeLineItem.ERP7__Inventory_Stock__c != null && stockTakeWrapperList[x].stockTakeLineItem.ERP7__Inventory_Stock__c != '')
                    {
                        if(stockTakeWrapperList[x].stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Location__c != null && stockTakeWrapperList[x].stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Location__c != undefined && stockTakeWrapperList[x].stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Location__c != '' && stockTakeWrapperList[x].stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Location__c == loc){
                            prodList.push(stockTakeWrapperList[x]);
                        } 
                    }
                    
                }
                if(prodList.length > 0){
                    
                
                var recSize = prodList.length;
                var PNS = [];
                var show = parseInt(component.get("v.show"));
                var Offset = parseInt(component.get("v.Container.Offset"));
                var ES = recSize;
                var j = 0;
                
                while (ES >= show) { j++; PNS.push(j); ES = ES - show; }
                if (ES > 0) PNS.push(j + 1);
                
               
                if (prodList.length > 0 && Offset != 0) {
                    var startCount = Offset + 1;
                    var endCount = Offset + prodList.length;
                    var PageNum = (Offset + show) / show;
                }
                else if (prodList.length > 0 && Offset == 0) {
                    var startCount = 1;
                    var endCount =  show;
                    var PageNum = 1;
                }
                
                
                component.set("v.Container.recSize", recSize);
                component.set("v.Container.PNS", PNS);
                component.set("v.Container.show", show);
                component.set("v.Container.Offset", Offset);
                component.set("v.Container.show", show);
                component.set("v.Container.startCount", startCount);
                component.set("v.Container.endCount", endCount);
                component.set("v.Container.PageNum", PageNum);
                console.log('prodList length : ',prodList);
                component.set("v.products", prodList);
                component.set("v.showSpinner",false); 
                }
                else{
                    component.set("v.showSpinner",false); 
                    helper.showToast('Info', 'info', $A.get('$Label.c.No_Products_Available'));
                } */
            }
            else if (!component.get("v.PreventChange")) component.fetchAllDetails();
        }catch(e){
            console.log('error : ',e);
        }
        
        
    },
    getbasedonLocation : function (component, event, helper) {
        console.log('Preventchange getbasedonLocation 2: ',component.get("v.PreventChange"));
        var loc = component.get("v.stockTake.ERP7__Location__c");
        console.log('loc :',loc);
        var checkedval = event.getSource().get("v.checked");;
        console.log('checkedval : ',checkedval);
        component.set('v.showLocationStocks',checkedval);
        component.fetchAllDetails();
        component.set("v.PreventChange",true);
        console.log('Preventchange getbasedonLocation 3: ',component.get("v.PreventChange"));
    },
    
    /*
    siteStepmethod: function (component, event) {
        component.set("v.selectedlocation", '');
        component.set("v.selectedlocName", '');
        component.set("v.scannedProduct", '');
        component.set("v.scannedProductName", '');
        component.set("v.selectedSite", '');
        component.set("v.step", 'Site');
        $A.enqueueAction(component.get('c.fetchAllDetails'));
    },
    
    locStepmethod: function (component, event) {
        component.set("v.selectedlocation", '');
        component.set("v.selectedlocName", '');
        component.set("v.scannedProduct", '');
        component.set("v.scannedProductName", '');
        component.set("v.step", 'location');
        $A.enqueueAction(component.get('c.fetchAllDetails'));
    },
    
    removePillLoc: function (component, event) {
        component.set("v.selectedlocation", '');
        component.set("v.selectedlocName", '');
        //component.set("v.step", 'location');
        $A.enqueueAction(component.get('c.fetchAllDetails'));
    },
    
    prodStepmethod: function (component, event) {
        if(component.get("v.step") != 'product'){
            component.set("v.scannedProduct", '');
            component.set("v.scannedProductName", '');
            component.set("v.step", 'product');
            $A.enqueueAction(component.get('c.fetchAllDetails'));
        }
    },
    
    removePillProd: function (component, event) {
        component.set("v.scannedProduct", '');
        component.set("v.scannedProductName", '');
        component.set("v.step", 'product');
        $A.enqueueAction(component.get('c.fetchAllDetails'));
    },
    
    updateRecordId: function (component, event, helper) {
        let stockObj = component.get("v.stockTake");
        
        component.set("v.recordId", stockObj['Id']);
    },
    
    update_RecordId: function (component, event, helper) {
        let stockTakeId = component.get("v.stockTakeId");
        component.set("v.recordId", stockTakeId);
    },
    
    resetComponent: function (component, event, helper) {
        if ($A.util.isEmpty(component.get("v.recordId")) || $A.util.isUndefined(component.get("v.recordId"))) {
            component.set("v.selectedlocation", '');
            component.set("v.selectedlocName", '');
            component.set("v.scannedProduct", '');
            component.set("v.scannedProductName", '');
            component.set("v.selectedSite", '');
            component.set("v.step", 'Site');
            component.set("v.products", []);
            component.set("v.allProductsList", []);
            component.set("v.allProductsListdum", []);
            component.set("v.locationlist", []);
            component.set("v.storageBinList", []);
            component.set("v.scanValue", '');
            component.set("v.productBarcode", '');
            component.set("v.searchString", '');
            let stockTake = component.get("v.stockTake");
            stockTake['ERP7__Site__c'] = ''
            stockTake['ERP7__Site__r'] = { Name: '', Id: '' };
            component.set("v.stockTake", stockTake);
            component.set("v.fireonChange", true);
            //component.doInit();
            
            var recId = component.get("v.recordId");
            var ik = component.get("v.stockTakeId");
            if (ik != '' && ik != undefined && ik != '') {
                component.set("v.recordId", component.get("v.stockTakeId"));
            }
            
            var siteId = component.get("v.siteId");
            if (siteId != null && siteId != '' && siteId != undefined) {
                component.set("v.stockTake.ERP7__Site__c", siteId);
            }
            
        } else {
            component.set("v.fireonChange", true);
            
        }
    },
  
  	 handleComponentEvent: function (component, event, helper) {
        var locationlists = component.get("v.locationlist");
        for (var x in locationlists) {
            //('x '+x+'locationlists '+JSON.stringify(locationlists[x]));
        }
        var searchString = event.getParam("searchString");
        
        var Allproducts = component.get("v.Allproducts");
        
        var selectProds = [];
        for (var x in Allproducts) {
            if (searchString.length > 1) {
                if (Allproducts[x].stockTakeLineItem.ERP7__Product__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || (!$A.util.isUndefined(Allproducts[x].stockTakeLineItem.ERP7__Product__r.StockKeepingUnit) && Allproducts[x].stockTakeLineItem.ERP7__Product__r.StockKeepingUnit.toLowerCase().indexOf(searchString.toLowerCase()) != -1) || (!$A.util.isUndefined(Allproducts[x].stockTakeLineItem.ERP7__Serial__c) && Allproducts[x].stockTakeLineItem.ERP7__Serial__r.ERP7__Serial_Number__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1) || (!$A.util.isUndefined(Allproducts[x].stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Location__c) && Allproducts[x].stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Location__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1)) {
                    Allproducts[x]['showSelected'] = true;
                    selectProds.push(Allproducts[x]);
                } else {
                    Allproducts[x]['showSelected'] = false;
                }
            } else {
                Allproducts[x]['showSelected'] = true;
            }
        }
        component.set("v.products", Allproducts);
    },
    
    */
    
    updateStock: function (component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.disaSave",true);
        console.log('updateStock called ');
        if (component.get('v.stockTake.ERP7__Audit_Period__c') == 'Quarterly' || component.get('v.stockTake.ERP7__Audit_Period__c') == 'Yearly') component.set('v.stockTake.ERP7__Full_Audit__c', true);
        
        console.log('full audit: ', component.get('v.stockTake.ERP7__Full_Audit__c'), ' audit period : ', component.get('v.stockTake.ERP7__Audit_Period__c'));
        var stk = component.get("v.stockTake");
        var err = false;
        if (stk.Name == null || stk.Name == '' || stk.Name == undefined) {
            err = true;
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', $A.get('$Label.c.Please_Enter_the_Name'));
        }
        console.log('err : ' + err);
        if (!err) {
            
            console.log('Full Audit : ', component.get('v.stockTake.ERP7__Full_Audit__c'));
            var prods = component.get("v.products");
            var allprods = component.get("v.allProductsList");
            var adjprods = component.get("v.adjustedProducts");
            
            var totalprods = [];
            var doninv = [];
            if(component.get('v.stockTake.ERP7__Full_Audit__c')){
                for (var x in prods) {
                    if(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != undefined && prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != null && prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != ''){
                        if ((prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c == undefined || prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c == null || prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c == '')) {
                            prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c = 0;
                            prods[x].stockTakeLineItem.ERP7__Variance__c = parseFloat(prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c) - parseFloat(prods[x].stockTakeLineItem.ERP7__Stock_Available__c);
                            let newSTLI = {
                                ERP7__Quantity__c: prods[x].stockTakeLineItem.ERP7__Stock_Available__c,
                                ERP7__Product__c: prods[x].stockTakeLineItem.ERP7__Product__c,
                                ERP7__Scrap__c: false,
                                ERP7__Material_Batch_Lot__c: prods[x].stockTakeLineItem.ERP7__Batch_Lot__c,
                                ERP7__Serial__c: prods[x].stockTakeLineItem.ERP7__Serial__c,
                                Name: prods[x].stockTakeLineItem.Name,
                                ERP7__Site_Product_Service_Inventory_Stock__c: prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c
                            };
                            prods[x].stockOutWardList.push(newSTLI);
                            if(!doninv.includes(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c)){
                                totalprods.push(prods[x]);
                                doninv.push(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c);
                            }else console.log('full audit prods doninv already includes');
                            
                        }
                    }
                }
            }
            else{
                var fromProdslst = [];
                
                for(var x in prods){
                    if(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != undefined && prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != null && prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != ''){
                        fromProdslst.push(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c);
                        if (prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != undefined && prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != null && prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != '') {
                            if (prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c >= 0) {
                                if (prods[x].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c) {
                                    //if (prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c == 0) 
                                    if(!doninv.includes(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c)){
                                        totalprods.push(prods[x]);
                                        doninv.push(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c);
                                    }else console.log('serialize prods doninv already includes');
                                } else {
                                    if(!doninv.includes(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c)){
                                        totalprods.push(prods[x]);
                                        doninv.push(prods[x].stockTakeLineItem.ERP7__Inventory_Stock__c);
                                    }else console.log('non serialize prods doninv already includes');
                                }
                            }
                        }
                    }
                }
                
                for(var x in allprods){
                    if(allprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != undefined && allprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != null && allprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c != ''){
                        if (!fromProdslst.includes(allprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c) && allprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != undefined && allprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != null && allprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c != '') {
                            if (allprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c >= 0) {
                                if (allprods[x].stockTakeLineItem.ERP7__Product__r.ERP7__Serialise__c) {
                                    //if (prods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c == 0) 
                                    if(!doninv.includes(allprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c)){
                                        totalprods.push(allprods[x]);
                                        doninv.push(allprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c);
                                    }
                                } else {
                                    if(!doninv.includes(allprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c)){
                                        totalprods.push(allprods[x]);
                                        doninv.push(allprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c);
                                    }
                                }
                            }else{
                                console.log('stock in hand empty');
                            }
                        }
                    }
                }
            }
            
            console.log('totalProds length after prods/allprods and/or audit~>' + totalprods.length);
            
            for (var x in adjprods) {
                 totalprods.push(adjprods[x]);
            }
            
           /* for (var x in adjprods) {
                if (component.get('v.stockTake.ERP7__Full_Audit__c') && (adjprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c == undefined || adjprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c == null || adjprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c == '')) {
                    adjprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c = 0;
                    adjprods[x].stockTakeLineItem.ERP7__Variance__c = parseFloat(adjprods[x].stockTakeLineItem.ERP7__Stock_In_Hand__c) - parseFloat(adjprods[x].stockTakeLineItem.ERP7__Stock_Available__c);
                    let newSTLI = {
                        ERP7__Quantity__c: adjprods[x].stockTakeLineItem.ERP7__Stock_Available__c,
                        ERP7__Product__c: adjprods[x].stockTakeLineItem.ERP7__Product__c,
                        ERP7__Scrap__c: false,
                        ERP7__Material_Batch_Lot__c: adjprods[x].stockTakeLineItem.ERP7__Batch_Lot__c,
                        ERP7__Serial__c: adjprods[x].stockTakeLineItem.ERP7__Serial__c,
                        Name: adjprods[x].stockTakeLineItem.Name,
                        ERP7__Site_Product_Service_Inventory_Stock__c: adjprods[x].stockTakeLineItem.ERP7__Inventory_Stock__c
                    };
                    adjprods[x].stockOutWardList.push(newSTLI);
                    totalprods.push(adjprods[x]);
                } else {
                    totalprods.push(adjprods[x]);
                }
            }
            console.log('totalProds length after adjprods and/or audit~>' + totalprods.length);
            */
            
            if (totalprods.length > 0) {
                var products_JSON = JSON.stringify(totalprods);
                console.log('products_JSON : ', products_JSON);
                let stockObj = component.get("v.stockTake");
                if ($A.util.isEmpty(stockObj['Id']) || $A.util.isUndefinedOrNull(stockObj['Id'])) stockObj['Id'] = null; // 
                stockObj['ERP7__Channel__c'] = component.get("v.currentEmpChannel");
                stockObj['ERP7__Site__c'] = component.get("v.selectedSite");
                stockObj['ERP7__Employee__c'] = component.get("v.stockTake.ERP7__Employee__c");
                stockObj['ERP7__Approver__c'] = component.get("v.stockTake.ERP7__Approver__c");
                if ($A.util.isEmpty(stockObj['ERP7__Start_Date__c'])) stockObj['ERP7__Start_Date__c'] = null;
                if ($A.util.isEmpty(stockObj['ERP7__End_Date__c'])) stockObj['ERP7__End_Date__c'] = null;
                let updateStockAction = component.get("c.update_Stocks");
                let stockTake_JSON = JSON.stringify(stockObj);
                console.log('stockTake_JSON : ', stockTake_JSON);
                updateStockAction.setParams({ "stockTakeObj": stockTake_JSON, "stockTakeITemsObj": products_JSON });
                updateStockAction.setCallback(this, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        if (response.getReturnValue().stockTake.Id != undefined && response.getReturnValue().stockTake.Id != null) {
                            helper.showToast($A.get('$Label.c.Success'), 'success', $A.get('$Label.c.Stock_Take_created_succesfully'));
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "isredirect": true,
                                "recordId": response.getReturnValue().stockTake.Id,
                                "slideDevName": "detail"
                            });
                            if (navEvt != undefined) navEvt.fire();
                        } else {
                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', $A.get('$Label.c.Unexpected_error_occured_Please_try_again_later'));
                        }
                        component.set("v.disaSave",false);
                        component.set("v.showSpinner",false);
                    } else {
                        component.set("v.disaSave",false);
                component.set("v.showSpinner",false);
                        console.log('Error save:', response.getError());
                    }
                });
                $A.enqueueAction(updateStockAction);
            }
            else {
                console.log('totalprods empty');
                component.set("v.disaSave",false);
                component.set("v.showSpinner",false);
                //component.set("v.exceptionError",'Please enter Stock In hand for atleast one product to create stock take');
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', $A.get('$Label.c.Please_enter_Stock_In_hand_for_atleast_one_product_to_create_stock_take'));
            }
        }else{
            component.set("v.disaSave",false);
            component.set("v.showSpinner",false);
        }
    },
    
    Cancel: function (component, event, helper) {
        window.history.back();
    },
    
    closeError: function (component, event, helper) {
        component.set("v.exceptionError",'');
    },
    
    //pagination
    SetShow: function (component, event, helper) {
        try {
            component.set("v.PreventChange", true);
            component.set("v.showSpinner",true);
            console.log('SetShow called arshad');
            component.set("v.Container.Offset", 0);
            //component.LoadNow();
            
            var dwrapallstockTakeWrapperList = [];
            var drwapstockTakeWrapperList = [];
            var stockTakeWrapperListRecs = [];
            var stockTakeWrapperList = component.get("v.allProductsList");
            
            dwrapallstockTakeWrapperList = stockTakeWrapperList;
            var recSize = stockTakeWrapperList.length;
            var PNS = [];
            var show = parseInt(component.get("v.show"));
            var Offset = parseInt(component.get("v.Container.Offset"));
            var ES = recSize;
            var j = 0;
            
            while (ES >= show) { j++; PNS.push(j); ES = ES - show; }
            if (ES > 0) PNS.push(j + 1);
            
            var countST = 0;
            for (var i = 0; i < stockTakeWrapperList.length; i++) {
                if (countST < (Offset + show) && countST >= Offset) {
                    stockTakeWrapperListRecs.push(stockTakeWrapperList[i]);
                }
                if (countST > (Offset + show)) break;
                countST++;
            }
            stockTakeWrapperList = stockTakeWrapperListRecs;
            
            if (stockTakeWrapperList.length > 0 && Offset != 0) {
                var startCount = Offset + 1;
                var endCount = Offset + stockTakeWrapperList.length;
                var PageNum = (Offset + show) / show;
            }
            else if (stockTakeWrapperList.length > 0 && Offset == 0) {
                var startCount = 1;
                var endCount = stockTakeWrapperList.length;
                var PageNum = 1;
            }
            
            drwapstockTakeWrapperList = stockTakeWrapperList;
            
            component.set("v.Container.recSize", recSize);
            component.set("v.Container.PNS", PNS);
            component.set("v.Container.show", show);
            component.set("v.Container.Offset", Offset);
            component.set("v.Container.show", show);
            component.set("v.Container.startCount", startCount);
            component.set("v.Container.endCount", endCount);
            component.set("v.Container.PageNum", PageNum);
            component.set("v.Container.stockTakeWrapperList", drwapstockTakeWrapperList);
            //component.set("v.Container.allstockTakeWrapperList",dwrapallstockTakeWrapperList);
            //component.set("v.allProductsList",dwrapallstockTakeWrapperList);
            component.set("v.products", drwapstockTakeWrapperList);
            console.log('prods length after setShow ~>' + component.get("v.products.length"));
            component.set("v.PreventChange", false);
            setTimeout(
                $A.getCallback(function () {
                    component.set("v.showSpinner",false);
                }), 1000);
        } catch (e) {
            console.log('error SetShow~>' + e);
            component.set("v.PreventChange", false);
            component.set("v.showSpinner",false);
        }
    },
    
    PreviousFirst: function (component, event, helper) {
        try {
            component.set("v.PreventChange", true);
            component.set("v.showSpinner",true);
            console.log('PreviousFirst called arshad');
            var show1 = parseInt(component.get("v.show"));
            if (component.get("v.Container.startCount") > 1) {
                var Offsetval1 = 0;
                component.set("v.Container.Offset", Offsetval1);
                //component.set("v.CheckOffset",true);
                component.set("v.Container.PageNum", ((component.get("v.Container.Offset") + show1) / show1));
                //component.LoadNow();
                
                var dwrapallstockTakeWrapperList = [];
                var drwapstockTakeWrapperList = [];
                var stockTakeWrapperListRecs = [];
                var stockTakeWrapperList = component.get("v.allProductsList");
                
                dwrapallstockTakeWrapperList = stockTakeWrapperList;
                var recSize = stockTakeWrapperList.length;
                var PNS = [];
                var show = parseInt(component.get("v.show"));
                var Offset = parseInt(component.get("v.Container.Offset"));
                var ES = recSize;
                var j = 0;
                
                while (ES >= show) { j++; PNS.push(j); ES = ES - show; }
                if (ES > 0) PNS.push(j + 1);
                
                var countST = 0;
                for (var i = 0; i < stockTakeWrapperList.length; i++) {
                    if (countST < (Offset + show) && countST >= Offset) {
                        stockTakeWrapperListRecs.push(stockTakeWrapperList[i]);
                    }
                    if (countST > (Offset + show)) break;
                    countST++;
                }
                stockTakeWrapperList = stockTakeWrapperListRecs;
                
                if (stockTakeWrapperList.length > 0 && Offset != 0) {
                    var startCount = Offset + 1;
                    var endCount = Offset + stockTakeWrapperList.length;
                    var PageNum = (Offset + show) / show;
                }
                else if (stockTakeWrapperList.length > 0 && Offset == 0) {
                    var startCount = 1;
                    var endCount = stockTakeWrapperList.length;
                    var PageNum = 1;
                }
                
                drwapstockTakeWrapperList = stockTakeWrapperList;
                
                component.set("v.Container.recSize", recSize);
                component.set("v.Container.PNS", PNS);
                component.set("v.Container.show", show);
                component.set("v.Container.Offset", Offset);
                component.set("v.Container.show", show);
                component.set("v.Container.startCount", startCount);
                component.set("v.Container.endCount", endCount);
                component.set("v.Container.PageNum", PageNum);
                component.set("v.Container.stockTakeWrapperList", drwapstockTakeWrapperList);
                //component.set("v.Container.allstockTakeWrapperList",dwrapallstockTakeWrapperList);
                //component.set("v.allProductsList",dwrapallstockTakeWrapperList);
                component.set("v.products", drwapstockTakeWrapperList);
            }
            console.log('prods length after PreviousFirst ~>' + component.get("v.products.length"));
            component.set("v.PreventChange", false);
            setTimeout(
                $A.getCallback(function () {
                    component.set("v.showSpinner",false);
                }), 1000);
        } catch (e) {
            console.log('error PreviousFirst~>' + e);
            component.set("v.PreventChange", false);
            component.set("v.showSpinner",false);
        }
    },
    
    Previous: function (component, event, helper) {
        try {
            component.set("v.PreventChange", true);
            component.set("v.showSpinner",true);
            console.log('Previous called arshad');
            if (component.get("v.Container.startCount") > 1) {
                var Offsetval1 = component.get("v.Container.Offset") - parseInt(component.get('v.show'));
                component.set("v.Container.Offset", Offsetval1);
                //component.set("v.CheckOffset",true);
                component.set("v.Container.PageNum", (component.get("v.Container.PageNum") - 1));
                //component.LoadNow();
                
                var dwrapallstockTakeWrapperList = [];
                var drwapstockTakeWrapperList = [];
                var stockTakeWrapperListRecs = [];
                var stockTakeWrapperList = component.get("v.allProductsList");
                
                dwrapallstockTakeWrapperList = stockTakeWrapperList;
                var recSize = stockTakeWrapperList.length;
                var PNS = [];
                var show = parseInt(component.get("v.show"));
                var Offset = parseInt(component.get("v.Container.Offset"));
                var ES = recSize;
                var j = 0;
                
                while (ES >= show) { j++; PNS.push(j); ES = ES - show; }
                if (ES > 0) PNS.push(j + 1);
                
                var countST = 0;
                for (var i = 0; i < stockTakeWrapperList.length; i++) {
                    if (countST < (Offset + show) && countST >= Offset) {
                        stockTakeWrapperListRecs.push(stockTakeWrapperList[i]);
                    }
                    if (countST > (Offset + show)) break;
                    countST++;
                }
                stockTakeWrapperList = stockTakeWrapperListRecs;
                
                if (stockTakeWrapperList.length > 0 && Offset != 0) {
                    var startCount = Offset + 1;
                    var endCount = Offset + stockTakeWrapperList.length;
                    var PageNum = (Offset + show) / show;
                }
                else if (stockTakeWrapperList.length > 0 && Offset == 0) {
                    var startCount = 1;
                    var endCount = stockTakeWrapperList.length;
                    var PageNum = 1;
                }
                
                drwapstockTakeWrapperList = stockTakeWrapperList;
                
                component.set("v.Container.recSize", recSize);
                component.set("v.Container.PNS", PNS);
                component.set("v.Container.show", show);
                component.set("v.Container.Offset", Offset);
                component.set("v.Container.show", show);
                component.set("v.Container.startCount", startCount);
                component.set("v.Container.endCount", endCount);
                component.set("v.Container.PageNum", PageNum);
                component.set("v.Container.stockTakeWrapperList", drwapstockTakeWrapperList);
                //component.set("v.Container.allstockTakeWrapperList",dwrapallstockTakeWrapperList);
                //component.set("v.allProductsList",dwrapallstockTakeWrapperList);
                component.set("v.products", drwapstockTakeWrapperList);
                
            }
            console.log('prods length after Previous ~>' + component.get("v.products.length"));
            component.set("v.PreventChange", false);
            setTimeout(
                $A.getCallback(function () {
                    component.set("v.showSpinner",false);
                }), 1000);
        } catch (e) {
            console.log('error Previous~>' + e);
            component.set("v.PreventChange", false);
            component.set("v.showSpinner",false);
        }
    },
    
    Next: function (component, event, helper) {
        try {
            //component.set("v.PreventChange", true);
            component.set("v.showSpinner",true);
            console.log('Next called arshad');
            if (component.get("v.Container.endCount") != component.get("v.Container.recSize")) {
                var Offsetval1 = component.get("v.Container.Offset") + parseInt(component.get('v.show'));
                component.set("v.Container.Offset", Offsetval1);
                //component.set("v.CheckOffset",true);
                component.set("v.Container.PageNum", (component.get("v.Container.PageNum") + 1));
                //component.LoadNow();
                
                console.log('in Next offset ~>' + component.get("v.Container.Offset") + ' pagenum~>' + component.get("v.Container.PageNum") + ' show~>' + component.get("v.show"));
                var dwrapallstockTakeWrapperList = [];
                var drwapstockTakeWrapperList = [];
                var stockTakeWrapperListRecs = [];
                var stockTakeWrapperList = component.get("v.allProductsList");
                
                dwrapallstockTakeWrapperList = stockTakeWrapperList;
                var recSize = stockTakeWrapperList.length;
                var PNS = [];
                var show = parseInt(component.get("v.show"));
                var Offset = parseInt(component.get("v.Container.Offset"));
                var ES = recSize;
                var j = 0;
                
                while (ES >= show) { j++; PNS.push(j); ES = ES - show; }
                if (ES > 0) PNS.push(j + 1);
                
                var countST = 0;
                console.log('Offset~>' + Offset + ' show~>' + show + 'Offset+show~>' + (Offset + show));
                for (var i = 0; i < stockTakeWrapperList.length; i++) {
                    if (countST < (Offset + show) && countST >= Offset) {
                        stockTakeWrapperListRecs.push(stockTakeWrapperList[i]);
                        console.log('pushed');
                    }
                    if (countST > (Offset + show)) break;
                    countST++;
                }
                stockTakeWrapperList = stockTakeWrapperListRecs;
                
                if (stockTakeWrapperList.length > 0 && Offset != 0) {
                    var startCount = Offset + 1;
                    var endCount = Offset + stockTakeWrapperList.length;
                    var PageNum = (Offset + show) / show;
                }
                else if (stockTakeWrapperList.length > 0 && Offset == 0) {
                    var startCount = 1;
                    var endCount = stockTakeWrapperList.length;
                    var PageNum = 1;
                }
                
                drwapstockTakeWrapperList = stockTakeWrapperList;
                
                console.log('dwrapallstockTakeWrapperList length~>' + dwrapallstockTakeWrapperList.length);
                console.log('drwapstockTakeWrapperList length~>' + drwapstockTakeWrapperList.length);
                component.set("v.Container.recSize", recSize);
                component.set("v.Container.PNS", PNS);
                component.set("v.Container.show", show);
                component.set("v.Container.Offset", Offset);
                component.set("v.Container.show", show);
                component.set("v.Container.startCount", startCount);
                component.set("v.Container.endCount", endCount);
                component.set("v.Container.PageNum", PageNum);
                component.set("v.Container.stockTakeWrapperList", drwapstockTakeWrapperList);
                //component.set("v.Container.allstockTakeWrapperList",dwrapallstockTakeWrapperList);
                //component.set("v.allProductsList",dwrapallstockTakeWrapperList);
                component.set("v.products", drwapstockTakeWrapperList);
                
            }
            console.log('prods length after Next ~>' + component.get("v.products.length"));
            component.set("v.PreventChange", false);
            setTimeout(
                $A.getCallback(function () {
                    component.set("v.showSpinner",false);
                }), 1000);
        } catch (e) {
            console.log('error Next~>' + e);
            component.set("v.PreventChange", false);
            component.set("v.showSpinner",false);
        }
    },
    
    NextLast: function (component, event, helper) {
        try {
            component.set("v.PreventChange", true);
            component.set("v.showSpinner",true);
            console.log('NextLast called arshad');
            var show1 = parseInt(component.get("v.show"));
            if (component.get("v.Container.endCount") != component.get("v.Container.recSize")) {
                var Offsetval1 = (component.get("v.Container.PNS").length - 1) * show1;
                component.set("v.Container.Offset", Offsetval1);
                //component.set("v.CheckOffset",true);
                component.set("v.Container.PageNum", ((component.get("v.Container.Offset") + show1) / show1));
                //component.LoadNow();
                
                var dwrapallstockTakeWrapperList = [];
                var drwapstockTakeWrapperList = [];
                var stockTakeWrapperListRecs = [];
                var stockTakeWrapperList = component.get("v.allProductsList");
                
                dwrapallstockTakeWrapperList = stockTakeWrapperList;
                var recSize = stockTakeWrapperList.length;
                var PNS = [];
                var show = parseInt(component.get("v.show"));
                var Offset = parseInt(component.get("v.Container.Offset"));
                var ES = recSize;
                var j = 0;
                
                while (ES >= show) { j++; PNS.push(j); ES = ES - show; }
                if (ES > 0) PNS.push(j + 1);
                
                var countST = 0;
                for (var i = 0; i < stockTakeWrapperList.length; i++) {
                    if (countST < (Offset + show) && countST >= Offset) {
                        stockTakeWrapperListRecs.push(stockTakeWrapperList[i]);
                    }
                    if (countST > (Offset + show)) break;
                    countST++;
                }
                stockTakeWrapperList = stockTakeWrapperListRecs;
                
                if (stockTakeWrapperList.length > 0 && Offset != 0) {
                    var startCount = Offset + 1;
                    var endCount = Offset + stockTakeWrapperList.length;
                    var PageNum = (Offset + show) / show;
                }
                else if (stockTakeWrapperList.length > 0 && Offset == 0) {
                    var startCount = 1;
                    var endCount = stockTakeWrapperList.length;
                    var PageNum = 1;
                }
                
                drwapstockTakeWrapperList = stockTakeWrapperList;
                
                component.set("v.Container.recSize", recSize);
                component.set("v.Container.PNS", PNS);
                component.set("v.Container.show", show);
                component.set("v.Container.Offset", Offset);
                component.set("v.Container.show", show);
                component.set("v.Container.startCount", startCount);
                component.set("v.Container.endCount", endCount);
                component.set("v.Container.PageNum", PageNum);
                component.set("v.Container.stockTakeWrapperList", drwapstockTakeWrapperList);
                //component.set("v.Container.allstockTakeWrapperList",dwrapallstockTakeWrapperList);
                //component.set("v.allProductsList",dwrapallstockTakeWrapperList);
                component.set("v.products", drwapstockTakeWrapperList);
                
            }
            console.log('prods length after NextLast ~>' + component.get("v.products.length"));
            component.set("v.PreventChange", false);
            setTimeout(
                $A.getCallback(function () {
                    component.set("v.showSpinner",false);
                }), 1000);
        } catch (e) {
            console.log('error NextLast~>' + e);
            component.set("v.PreventChange", false);
            component.set("v.showSpinner",false);
        }
    },
    
    OfsetChange: function (component, event, helper) {
        try {
            component.set("v.PreventChange", true);
            component.set("v.showSpinner",true);
            console.log('OfsetChange called arshad');
            var container1 = component.get("v.Container");
            var PNS1 = container1.PNS;
            var PageNum1 = parseInt(container1.PageNum);
            var Offset1 = parseInt(container1.Offset);
            var show1 = parseInt(component.get("v.show"));
            
            if (PageNum1 > 0 && PageNum1 <= PNS1.length) {
                if (((Offset1 + show1) / show1) != PageNum1) {
                    Offset1 = (show1 * PageNum1) - show1;
                    component.set("v.Container.Offset", Offset1);
                }
                //component.LoadNow();
                
                var dwrapallstockTakeWrapperList = [];
                var drwapstockTakeWrapperList = [];
                var stockTakeWrapperListRecs = [];
                var stockTakeWrapperList = component.get("v.allProductsList");
                
                dwrapallstockTakeWrapperList = stockTakeWrapperList;
                var recSize = stockTakeWrapperList.length;
                var PNS = [];
                var show = parseInt(component.get("v.show"));
                var Offset = parseInt(component.get("v.Container.Offset"));
                var ES = recSize;
                var j = 0;
                
                while (ES >= show) { j++; PNS.push(j); ES = ES - show; }
                if (ES > 0) PNS.push(j + 1);
                
                var countST = 0;
                for (var i = 0; i < stockTakeWrapperList.length; i++) {
                    if (countST < (Offset + show) && countST >= Offset) {
                        stockTakeWrapperListRecs.push(stockTakeWrapperList[i]);
                    }
                    if (countST > (Offset + show)) break;
                    countST++;
                }
                stockTakeWrapperList = stockTakeWrapperListRecs;
                
                if (stockTakeWrapperList.length > 0 && Offset != 0) {
                    var startCount = Offset + 1;
                    var endCount = Offset + stockTakeWrapperList.length;
                    var PageNum = (Offset + show) / show;
                }
                else if (stockTakeWrapperList.length > 0 && Offset == 0) {
                    var startCount = 1;
                    var endCount = stockTakeWrapperList.length;
                    var PageNum = 1;
                }
                
                drwapstockTakeWrapperList = stockTakeWrapperList;
                
                component.set("v.Container.recSize", recSize);
                component.set("v.Container.PNS", PNS);
                component.set("v.Container.show", show);
                component.set("v.Container.Offset", Offset);
                component.set("v.Container.show", show);
                component.set("v.Container.startCount", startCount);
                component.set("v.Container.endCount", endCount);
                component.set("v.Container.PageNum", PageNum);
                component.set("v.Container.stockTakeWrapperList", drwapstockTakeWrapperList);
                //component.set("v.Container.allstockTakeWrapperList",dwrapallstockTakeWrapperList);
                //component.set("v.allProductsList",dwrapallstockTakeWrapperList);
                component.set("v.products", drwapstockTakeWrapperList);
                
            } else component.set("v.Container.PageNum", (Offset1 + show1) / show1);
            console.log('prods length after OfsetChange ~>' + component.get("v.products.length"));
            component.set("v.PreventChange", false);
            setTimeout(
                $A.getCallback(function () {
                    component.set("v.showSpinner",false);
                }), 1000);
        } catch (e) {
            console.log('error OfsetChange~>' + e);
            component.set("v.PreventChange", false);
            component.set("v.showSpinner",false);
        }
    },
    //pagination
    
    //arshad sorting
    sortBy: function (component, event, helper) {
        try {
            component.set("v.PreventChange", true);
            component.set("v.showSpinner",true);
            console.log('sortBy called arshad');
            console.log('event.currentTarget.id : ', event.currentTarget.id);
            component.set("v.OrderBy", event.currentTarget.id);
            if (component.get("v.Order") == 'DESC') component.set("v.Order", 'ASC');
            else if (component.get("v.Order") == 'ASC') component.set("v.Order", 'DESC');
            console.log('component.get(v.Order) : ', component.get("v.Order"));
            //component.set("v.isLoading", true);
            var sortAsc = (component.get("v.Order") == 'ASC') ? true : false,
                sortField = event.currentTarget.id,
                table = component.get("v.allProductsList");
            //console.log('table b4~>'+JSON.stringify(table[0]));
            console.log('sortField~>' + sortField + ' sortAsc ~>' + component.get("v.Order") + ' table length~>' + table.length);
            //if(!$A.util.isEmpty(sortField) && !$A.util.isUndefinedOrNull(sortField) && table.length > 0){
            table.sort(function (a, b) {
                if (sortField == 'ProductName') {
                    var t1 = a.stockTakeLineItem.ERP7__Product__r.Name.toLowerCase() == b.stockTakeLineItem.ERP7__Product__r.Name.toLowerCase(),
                        t2 = a.stockTakeLineItem.ERP7__Product__r.Name.toLowerCase() > b.stockTakeLineItem.ERP7__Product__r.Name.toLowerCase();
                } else if (sortField == 'Serial') {
                    if (($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c)) && ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c))) return 0;
                    if (sortAsc) {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c)) return 1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c)) return -1;
                    } else {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c)) return -1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__c)) return 1;
                    }
                    
                    if (($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c)) && ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c))) return 0;
                    if (sortAsc) {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c)) return 1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c)) return -1;
                    } else {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c)) return -1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c)) return 1;
                    }
                    
                    var t1 = a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c.toLowerCase() == b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c.toLowerCase(),
                        t2 = a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c.toLowerCase() > b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Serial__r.ERP7__Serial_Number__c.toLowerCase();
                } 
                    else if (sortField == 'Lot') {
                    if (($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c)) && ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c))) return 0;
                    if (sortAsc) {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c)) return 1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c)) return -1;
                    } else {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c)) return -1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__c)) return 1;
                    }
                    
                    var t1 = a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__r.Name.toLowerCase() == b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__r.Name.toLowerCase(),
                        t2 = a.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__r.Name.toLowerCase() > b.stockTakeLineItem.ERP7__Inventory_Stock__r.ERP7__Batch_Lot__r.Name.toLowerCase();
                } 
                        else if (sortField == 'Stock') {
                    if (($A.util.isEmpty(a.stockTakeLineItem.ERP7__Stock_Available__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Stock_Available__c)) && ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Stock_Available__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Stock_Available__c))) return 0;
                    if (sortAsc) {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Stock_Available__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Stock_Available__c)) return 1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Stock_Available__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Stock_Available__c)) return -1;
                    } else {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Stock_Available__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Stock_Available__c)) return -1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Stock_Available__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Stock_Available__c)) return 1;
                    }
                    
                    var t1 = a.stockTakeLineItem.ERP7__Stock_Available__c == b.stockTakeLineItem.ERP7__Stock_Available__c,
                        t2 = a.stockTakeLineItem.ERP7__Stock_Available__c > b.stockTakeLineItem.ERP7__Stock_Available__c;
                } 
                            else if (sortField == 'ProductCodeSKU') {
                    if (($A.util.isEmpty(a.stliProdCodeSKU) || $A.util.isUndefinedOrNull(a.stliProdCodeSKU)) && ($A.util.isEmpty(b.stliProdCodeSKU) || $A.util.isUndefinedOrNull(b.stliProdCodeSKU))) return 0;
                    if (sortAsc) {
                        if ($A.util.isEmpty(b.stliProdCodeSKU) || $A.util.isUndefinedOrNull(b.stliProdCodeSKU)) return 1;
                        if ($A.util.isEmpty(a.stliProdCodeSKU) || $A.util.isUndefinedOrNull(a.stliProdCodeSKU)) return -1;
                    } else {
                        if ($A.util.isEmpty(b.stliProdCodeSKU) || $A.util.isUndefinedOrNull(b.stliProdCodeSKU)) return -1;
                        if ($A.util.isEmpty(a.stliProdCodeSKU) || $A.util.isUndefinedOrNull(a.stliProdCodeSKU)) return 1;
                    }
                    
                    var t1 = a.stliProdCodeSKU.toLowerCase() == b.stliProdCodeSKU.toLowerCase(),
                        t2 = a.stliProdCodeSKU.toLowerCase() > b.stliProdCodeSKU.toLowerCase();
                } 
                                else if (sortField == 'StockHand') {
                    if (($A.util.isEmpty(a.stockTakeLineItem.ERP7__Stock_In_Hand__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Stock_In_Hand__c)) && ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Stock_In_Hand__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Stock_In_Hand__c))) return 0;
                    if (sortAsc) {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Stock_In_Hand__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Stock_In_Hand__c)) return 1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Stock_In_Hand__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Stock_In_Hand__c)) return -1;
                    } else {
                        if ($A.util.isEmpty(b.stockTakeLineItem.ERP7__Stock_In_Hand__c) || $A.util.isUndefinedOrNull(b.stockTakeLineItem.ERP7__Stock_In_Hand__c)) return -1;
                        if ($A.util.isEmpty(a.stockTakeLineItem.ERP7__Stock_In_Hand__c) || $A.util.isUndefinedOrNull(a.stockTakeLineItem.ERP7__Stock_In_Hand__c)) return 1;
                    }
                    
                    var t1 = a.stockTakeLineItem.ERP7__Stock_In_Hand__c == b.stockTakeLineItem.ERP7__Stock_In_Hand__c,
                        t2 = a.stockTakeLineItem.ERP7__Stock_In_Hand__c > b.stockTakeLineItem.ERP7__Stock_In_Hand__c;
                }
                                    else if(sortField == 'InventoryLocation'){
                                       
                                        if (($A.util.isEmpty(a.inventoryLocation) || $A.util.isUndefinedOrNull(a.inventoryLocation)) && ($A.util.isEmpty(b.inventoryLocation) || $A.util.isUndefinedOrNull(b.inventoryLocation))) return 0;
                                        if (sortAsc) {
                                            if ($A.util.isEmpty(b.inventoryLocation) || $A.util.isUndefinedOrNull(b.inventoryLocation)) return 1;
                                            if ($A.util.isEmpty(a.inventoryLocation) || $A.util.isUndefinedOrNull(a.inventoryLocation)) return -1;
                                        } else {
                                            if ($A.util.isEmpty(b.inventoryLocation) || $A.util.isUndefinedOrNull(b.inventoryLocation)) return -1;
                                            if ($A.util.isEmpty(a.inventoryLocation) || $A.util.isUndefinedOrNull(a.inventoryLocation)) return 1;
                                        }
                                        var t1 = a.inventoryLocation.toLowerCase() == b.inventoryLocation.toLowerCase(),
                                            t2 = a.inventoryLocation.toLowerCase() > b.inventoryLocation.toLowerCase();   
                                    }
                return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? -1 : 1);
            });
            
            //arshad pagination after sort
            var stockTakeWrapperListRecs = [];
            var stockTakeWrapperList = [];
            var recSize = table.length;
            var PNS = [];
            var show = parseInt(component.get("v.show"));
            var Offset = parseInt(component.get("v.Container.Offset"));
            var ES = recSize;
            var j = 0;
            console.log('doing pagination show~>' + show + ' offset~>' + Offset + ' recSize~>' + recSize);
            
            while (ES >= show) { j++; PNS.push(j); ES = ES - show; }
            if (ES > 0) PNS.push(j + 1);
            
            var countST = 0;
            for (var i = 0; i < table.length; i++) {
                if (countST < (Offset + show) && countST >= Offset) {
                    stockTakeWrapperListRecs.push(table[i]);
                }
                if (countST > (Offset + show)) break;
                countST++;
            }
            table = stockTakeWrapperListRecs;
            
            if (table.length > 0 && Offset != 0) {
                var startCount = Offset + 1;
                var endCount = Offset + table.length;
                var PageNum = (Offset + show) / show;
            }
            else if (table.length > 0 && Offset == 0) {
                var startCount = 1;
                var endCount = table.length;
                var PageNum = 1;
            }
            
            stockTakeWrapperList = table;
            
            component.set("v.Container.recSize", recSize);
            component.set("v.Container.PNS", PNS);
            component.set("v.Container.show", show);
            component.set("v.Container.Offset", Offset);
            component.set("v.Container.show", show);
            component.set("v.Container.startCount", startCount);
            component.set("v.Container.endCount", endCount);
            component.set("v.Container.PageNum", PageNum);
            component.set("v.Container.stockTakeWrapperList", stockTakeWrapperList);
            console.log('setting prods stockTakeWrapperList length~>' + stockTakeWrapperList.length);
            component.set("v.products", stockTakeWrapperList);
            //console.log('table after~>'+JSON.stringify(table[0]));
            //}else{
            //console.log('not sorted'); 
            //}
            
            component.set("v.PreventChange", false);
            setTimeout(
                $A.getCallback(function () {
                    component.set("v.showSpinner",false);
                }), 1000);
            
        } catch (e) {
            console.log('error sortby~>' + e);
            component.set("v.PreventChange", false);
            component.set("v.showSpinner",false);
        }
    },
    
    focusTOscan: function (component, event, helper) {
        component.set("v.scanValue", '');
        helper.focusTOscan(component, event);
    },
    
})