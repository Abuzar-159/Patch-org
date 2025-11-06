({
    verifyScanCodes : function (component, event,helper) {
        try{
            var scanedfield = component.get("v.scanValue");
            console.log('verifyScanCodes scanedfield : ',scanedfield);
            var editedFieldId = event.getSource().getLocalId();
            console.log('verifyScanCodes editedFieldId : ',editedFieldId);
            if(editedFieldId == scanedfield){
                
                console.log('onchange verifyScanCodes ~>'+component.get("v.scanValue"));
                component.set("v.exceptionError", '');
                var scan_Code = component.get("v.scanValue");
                var mybarcode = scan_Code;
                var itemfound = false;
                var productID = '';
                if(mybarcode != '' && mybarcode != null && mybarcode != undefined){
                    component.set("v.Container.DisMsg", '');
                    if(component.get("v.showCreateNewLotModal")){
                        console.log('New Lot Modal is open, scan anything to set the LotName here');
                        component.set("v.newBatch.ERP7__Barcode__c",mybarcode);
                        component.set("v.newBatch.Name",mybarcode);
                    }else{
                        if(mybarcode == 'ORDER') component.Back2Inbound(); 
                        else if(mybarcode == 'RECEIVE') component.getAllRecieveDetails(); 
                            else if(mybarcode == 'SAVE') component.SaveAllLOLines(); 
                                else{
                                    var sili = component.get('v.Container.SPLIS');
                                    let serialProduct = [];
                                    let batchProduct = [];
                                    var counter = 0;
                                    //var alreadymsg = false;
                                    var itemFoundforSerials = false;
                                    var msg= '';
                                    for(var x in sili){
                                        if(sili[x].sili.ERP7__Product__c != null && sili[x].sili.ERP7__Product__c != undefined && sili[x].sili.ERP7__Product__c != ''){
                                            if(sili[x].sili.ERP7__Product__r.ERP7__Barcode__c == mybarcode){
                                                console.log('Product found for barcode~>'+mybarcode);
                                                counter = x;
                                                if(sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && sili[x].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                                    component.set("v.SerialNoScan",false);
                                                    productID = sili[x].sili.ERP7__Product__c;
                                                    console.log('batch product scanned~>'+sili[x].sili.ERP7__Product__r.Name);
                                                    var msg= '';
                                                    if(sili[x].siliverified){
                                                        if(!sili[x].isSelected || sili[x].sili.ERP7__Material_Batch_Lot__c == null || sili[x].sili.ERP7__Material_Batch_Lot__c == undefined || sili[x].sili.ERP7__Material_Batch_Lot__c == ''){
                                                            msg = sili[x].sili.ERP7__Product__r.Name+ $A.get('$Label.c.Product_is_already_scanned_please_scan_the_Lot');
                                                            sili[x].isSelected = true;
                                                        }else{
                                                            msg = sili[x].sili.ERP7__Product__r.Name+ $A.get('$Label.c.Product_is_already_scanned');
                                                            sili[x].isSelected = true;
                                                        }
                                                    }else{
                                                        msg = sili[x].sili.ERP7__Product__r.Name+$A.get('$Label.c.Product_is_scanned_please_scan_the_Lot');
                                                        sili[x].siliverified = true;
                                                        sili[x].isSelected = true;
                                                    }
                                                    component.set("v.scannedProd", productID);
                                                    component.set("v.scannedIndx", x);
                                                    batchProduct.push(sili[x]);
                                                    itemfound= true;
                                                    component.set('v.hideSave',false);
                                                    break;
                                                }
                                                else if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false){
                                                    productID = sili[x].sili.ERP7__Product__c;
                                                    console.log('serial product scanned~>'+sili[x].sili.ERP7__Product__r.Name);
                                                    if(!itemFoundforSerials){
                                                        if(component.get("v.scannedProd") == productID){
                                                            msg = sili[x].sili.ERP7__Product__r.Name+$A.get('$Label.c.Product_is_already_scanned');
                                                        }else{
                                                            msg = sili[x].sili.ERP7__Product__r.Name+ $A.get('$Label.c.Product_is_scanned');
                                                        }
                                                    }
                                                    sili[x].isSelected = true;
                                                    component.set("v.scannedProd", productID);
                                                    serialProduct.push(sili[x]);
                                                    itemfound= true;
                                                    itemFoundforSerials = true;
                                                    component.set('v.hideSave',false);
                                                }
                                                    else if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c){
                                                        productID = sili[x].sili.ERP7__Product__c;
                                                        console.log('serialbatch product scanned~>'+sili[x].sili.ERP7__Product__r.Name);
                                                        if(!itemFoundforSerials){
                                                            if(component.get("v.scannedProd") == productID){
                                                                msg = sili[x].sili.ERP7__Product__r.Name+$A.get('$Label.c.Product_is_already_scanned');
                                                            }else{
                                                                msg = sili[x].sili.ERP7__Product__r.Name+ $A.get('$Label.c.Product_is_scanned');
                                                            }
                                                        }
                                                        
                                                        sili[x].isSelected = true;
                                                        component.set("v.scannedProd", productID);
                                                        serialProduct.push(sili[x]);
                                                        batchProduct.push(sili[x]);
                                                        itemfound= true;
                                                        itemFoundforSerials = true;
                                                    }
                                                        else if(!sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && !sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && component.get("v.SerialNoScan") == false) {
                                                            productID = sili[x].sili.ERP7__Product__c;
                                                            if(sili[x].sili.ERP7__Location__c == '' || sili[x].sili.ERP7__Location__c == null || sili[x].sili.ERP7__Location__c == undefined){
                                                                msg = sili[x].sili.ERP7__Product__r.Name+ $A.get('$Label.c.Product_is_selected_please_proceed_further');
                                                                sili[x].siliverified = true;
                                                                sili[x].isSelected = true;
                                                                itemfound= true;
                                                            }else { sili[x].siliverified = true; sili[x].isSelected = true; itemfound= true; }
                                                            component.set("v.scannedIndx", x);
                                                            component.set('v.hideSave',false);
                                                            break;
                                                        }
                                            }
                                            else{
                                                console.log('prod barcode not matched');
                                            }
                                        }
                                    }
                                    
                                    if(itemFoundforSerials){
                                        var moreserialsTodo = false;
                                        if(!$A.util.isEmpty(component.get("v.scannedProd")) && !$A.util.isUndefinedOrNull(component.get("v.scannedProd"))){
                                            for(var x in sili){ 
                                                if(sili[x].sili.ERP7__Product__c == component.get("v.scannedProd")){
                                                    if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && (sili[x].sili.ERP7__Serial_Number__c == null || sili[x].sili.ERP7__Serial_Number__c == undefined || sili[x].sili.ERP7__Serial_Number__c == '')){
                                                        moreserialsTodo = true;
                                                        sili[x].siliverified = true;
                                                        productID = sili[x].sili.ERP7__Product__c;
                                                        component.set("v.scannedProd", productID);
                                                        component.set("v.scannedIndx", x);
                                                        component.set("v.SerialNoScan",true);
                                                        if(sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c) msg += $A.get('$Label.c.Please_scan_the_Lot_and_Serial_Numbers'); else msg += $A.get('$Label.c.Please_scan_the_Serial_Numbers');
                                                        console.log('in here 1');
                                                        component.set('v.hideSave',false);
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                        if(!moreserialsTodo){
                                            component.set("v.SerialNoScan",false);
                                        }
                                    }else{
                                        console.log('itemFoundforSerials false');
                                    }
                                    
                                    console.log('b4 scannedProd~>'+component.get("v.scannedProd"));
                                    console.log('b4 scannedIndx~>'+component.get("v.scannedIndx"));                        
                                    //if(!alreadymsg){
                                    component.set("v.Container.DisMsg", msg);
                                    //for assigning serialnums/isSelected/siliVerified
                                    component.set("v.Container.SPLIS",sili);
                                    
                                    if(!itemfound){
                                        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                                        console.log('itemfound false b4 action mybarcode~>'+mybarcode+' scannedProd~>'+component.get("v.scannedProd")+'scannedIndx ~>'+component.get("v.scannedIndx"));
                                        var siteid = component.get("v.selectedSite");
                                        console.log('siteid~>'+siteid);
                                        var action = component.get("c.getscandetailsnew");
                                        action.setParams({
                                            barcode : mybarcode,
                                            prodId : component.get("v.scannedProd"),
                                            count : component.get("v.scannedIndx"),
                                            sili : JSON.stringify(component.get('v.Container.SPLIS')),
                                            loli : JSON.stringify(component.get('v.Container.LOLIS')),
                                            site : siteid
                                        });
                                        action.setCallback(this, function(response){
                                            if(response.getState() === "SUCCESS"){
                                                console.log('response getscandetailsnew: ',response.getReturnValue());
                                                if(response.getReturnValue().comWrapper != null && response.getReturnValue().comWrapper !=undefined){
                                                    if(response.getReturnValue().comWrapper.DisMsg == ''){
                                                        if(response.getReturnValue().bool){
                                                            console.log('getscandetailsnew bool true setting scannedProd,scannedIndx,SerialNoScan(if existing is false)'); 
                                                            component.set("v.scannedProd",response.getReturnValue().scannedProdId);
                                                            component.set("v.scannedIndx",response.getReturnValue().scannedIndx);
                                                            if(component.get("v.SerialNoScan") == false){
                                                                component.set("v.SerialNoScan",response.getReturnValue().serialscan);
                                                            }
                                                        }else console.log('getscandetailsnew bool false'); 
                                                        component.set('v.Container',response.getReturnValue().comWrapper);
                                                        component.set('v.hideSave',false);
                                                        console.log('getscandetailsnew batchAssigned~>'+response.getReturnValue().batchAssigned+' BatchId~>'+response.getReturnValue().BatchId);
                                                        if(response.getReturnValue().batchAssigned && !$A.util.isEmpty(response.getReturnValue().BatchId) && !$A.util.isUndefinedOrNull(response.getReturnValue().BatchId)){
                                                            console.log('batchAssigned apex');
                                                            component.set("v.SerialNoScan",true);
                                                            if(response.getReturnValue().alreadybatchscanned){
                                                                var msg = response.getReturnValue().BatchName+ $A.get('$Label.c.Batch_is_already_scanned_for_the_Product') +response.getReturnValue().prodName+ $A.get('$Label.c.please_proceed_further');
                                                                component.set("v.Container.DisMsg", msg);
                                                                console.log('alreadybatchscanned msg set~>'+msg);
                                                            }else{
                                                                var msg = response.getReturnValue().BatchName+$A.get('$Label.c.Batch_is_scanned_for_the_Product')+response.getReturnValue().prodName+ $A.get('$Label.c.please_proceed_further');
                                                                component.set("v.Container.DisMsg", msg);
                                                                console.log('batchscanned msg set~>'+msg);
                                                            }
                                                            
                                                        }else{
                                                            console.log('batch not assigned apex');
                                                        }
                                                    }else{
                                                        console.log('DisMsg not empty~>'+response.getReturnValue().comWrapper.DisMsg);
                                                        console.log('here1');
                                                        console.log('SerialNoScan ~>'+component.get("v.SerialNoScan")+' scannedProd~>'+component.get("v.scannedProd")+' scannedIndx~>'+component.get("v.scannedIndx"));
                                                        if(component.get("v.SerialNoScan") && !$A.util.isEmpty(component.get("v.scannedProd")) && !$A.util.isUndefinedOrNull(component.get("v.scannedProd")) && component.get("v.scannedIndx") != -1){
                                                            var Serialaction = component.get('c.checkDuplicateSerials');
                                                            Serialaction.setParams({
                                                                value : mybarcode,
                                                            });
                                                            Serialaction.setCallback(this, function(resp){
                                                                if(resp.getState() === "SUCCESS"){
                                                                    var returnbool = true;
                                                                    var dupliserialfound = false;
                                                                    console.log('checkDuplicateSerials response~>'+resp.getReturnValue());
                                                                    if(resp.getReturnValue() != null){
                                                                        console.log('checkDuplicateSerials resp not null');
                                                                        component.set("v.exceptionError", resp.getReturnValue());
                                                                        returnbool = false;
                                                                        dupliserialfound = true;
                                                                    }else{
                                                                        console.log('checkDuplicateSerials resp null');
                                                                        var SPLIS2 = component.get("v.Container.SPLIS");
                                                                        if(SPLIS2.length > 0){
                                                                            for(var i in SPLIS2){
                                                                                if(SPLIS2[i].sili.ERP7__Product__c != null && SPLIS2[i].sili.ERP7__Product__c  != undefined && SPLIS2[i].sili.ERP7__Product__c  != ''){
                                                                                    if(SPLIS2[i].sili.ERP7__Product__r.ERP7__Serialise__c && i != parseInt(component.get("v.scannedIndx"))){
                                                                                        if(SPLIS2[i].sili.ERP7__Serial_Number__c != '' && SPLIS2[i].sili.ERP7__Serial_Number__c != null && SPLIS2[i].sili.ERP7__Serial_Number__c != undefined){
                                                                                            if(mybarcode == SPLIS2[i].sili.ERP7__Serial_Number__c){
                                                                                                console.log('duplicate found in currentlist');
                                                                                                var errmsg = 'Duplicate Serial No '+mybarcode+' exists.';
                                                                                                component.set("v.exceptionError",errmsg);
                                                                                                returnbool = false;
                                                                                                dupliserialfound = true;
                                                                                                break;
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                        if(returnbool){
                                                                            console.log('returnbool true');
                                                                            var serBool = false;
                                                                            var serBoolIndx = -1;
                                                                            var sili = [];
                                                                            var msg = '';
                                                                            sili = component.get('v.Container.SPLIS');
                                                                            if(!$A.util.isEmpty(component.get("v.scannedProd")) && !$A.util.isUndefinedOrNull(component.get("v.scannedProd")) && !$A.util.isEmpty(component.get("v.scannedIndx")) && !$A.util.isUndefinedOrNull(component.get("v.scannedIndx"))){
                                                                                for(var x in sili){ 
                                                                                    if(x == parseInt(component.get("v.scannedIndx"))){
                                                                                        console.log('in here 2.0');
                                                                                        if(sili[x].sili.ERP7__Product__c != null && sili[x].sili.ERP7__Product__c != undefined && (sili[x].sili.ERP7__Serial_Number__c == '' || sili[x].sili.ERP7__Serial_Number__c == null || sili[x].sili.ERP7__Serial_Number__c == undefined)){
                                                                                            if(sili[x].sili.ERP7__Product__c == component.get("v.scannedProd") && sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && sili[x].isSelected && sili[x].siliverified){
                                                                                                console.log('serialno assigned done');
                                                                                                sili[x].sili.ERP7__Serial_Number__c = mybarcode;
                                                                                                //component.set("v.SerialNoScan",false);
                                                                                                serBool = true;
                                                                                                serBoolIndx = x;
                                                                                                sili[x].isSelected = true;
                                                                                                component.set('v.hideSave',false);
                                                                                                break;
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                            if(serBool && component.get("v.SerialNoScan")){
                                                                                var boolnext = false;
                                                                                if(!$A.util.isEmpty(component.get("v.scannedProd")) && !$A.util.isUndefinedOrNull(component.get("v.scannedProd"))){
                                                                                    for(var x in sili){ 
                                                                                        if(sili[x].sili.ERP7__Product__c == component.get("v.scannedProd")){
                                                                                            if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c){
                                                                                                if(sili[x].sili.ERP7__Serial_Number__c == undefined || sili[x].sili.ERP7__Serial_Number__c == null || sili[x].sili.ERP7__Serial_Number__c == '' ){
                                                                                                    if(sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && (sili[x].sili.ERP7__Material_Batch_Lot__c == undefined || sili[x].sili.ERP7__Material_Batch_Lot__c == null || sili[x].sili.ERP7__Material_Batch_Lot__c == '')) msg = sili[x].sili.ERP7__Product__r.Name+' Product is scanned, please scan the Lot and Serial Numbers';
                                                                                                    else msg = sili[x].sili.ERP7__Product__r.Name+ $A.get('$Label.c.Product_is_scanned_please_scan_the_Serial_Numbers');
                                                                                                    sili[x].siliverified = true;
                                                                                                    console.log('next siliverified indx~>'+x);
                                                                                                    component.set("v.scannedIndx", x);
                                                                                                    component.set("v.SerialNoScan",true);
                                                                                                    boolnext = true;
                                                                                                    console.log('in here 3');
                                                                                                    component.set('v.hideSave',false);
                                                                                                    break;
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                                if(!boolnext){
                                                                                    component.set("v.SerialNoScan",false);
                                                                                }
                                                                            }else{
                                                                                console.log('in here 3 else');
                                                                                component.set('v.exceptionError',response.getReturnValue().comWrapper.DisMsg);
                                                                            }
                                                                            component.set("v.Container.DisMsg", msg);
                                                                            component.set("v.Container.SPLIS",sili);
                                                                            component.set('v.hideSave',false);
                                                                        }else{
                                                                            console.log('returnbool false');
                                                                            if(!dupliserialfound) component.set('v.exceptionError',response.getReturnValue().comWrapper.DisMsg);
                                                                        }
                                                                        console.log('returnbool here~>'+returnbool);
                                                                    }
                                                                }else{
                                                                    var err = response.getError();
                                                                    component.set("v.exceptionError",err[0].message);
                                                                    setTimeout(function () { component.set("v.exceptionError",""); }, 5000);
                                                                    console.log('Error Duplicates:',err);
                                                                }
                                                            });
                                                            $A.enqueueAction(Serialaction);
                                                        }else{
                                                            console.log('here20');
                                                            component.set('v.exceptionError',response.getReturnValue().comWrapper.DisMsg);
                                                        }
                                                    } 
                                                }
                                                setTimeout(function () { $A.util.addClass(component.find('mainSpin'), "slds-hide"); }, 2000);
                                            }else{
                                                setTimeout(function () { $A.util.addClass(component.find('mainSpin'), "slds-hide"); }, 2000);
                                                var errors = response.getError();
                                                console.log("server error getscandetailsnew: ", errors);
                                            } 
                                        });
                                        $A.enqueueAction(action);
                                    }else{
                                        console.log('item found true');
                                    }
                                }
                    }
                    component.set("v.scanValue",'');
                }
            }
        }catch(e){
            console.log('error verifyScanCodes~>'+e);
            component.set("v.scanValue",'');
        }
    },
    
    getAllRecieveDetails : function(component, event, helper) {
        try{
            var logIds = component.get("v.logisticIds");
            console.log('logIds : ',logIds);
            var logisticIds = logIds.split(",");
            var LIds = JSON.stringify(logisticIds);
            console.log('logisticIds : '+LIds);
            
            var MOId = component.get("v.MOIds");
            
            /*var InStockLabel = $A.get("$Label.c.InStockPickListValue");
            component.set("v.InStockLabel", InStockLabel);
            var QualityCheckLabel = $A.get("$Label.c.Quality_Check_QA");
            component.set("v.QualityCheckLabel", QualityCheckLabel);*/
            if(component.get("v.logisticIds") != undefined && component.get("v.logisticIds") != null && component.get("v.logisticIds") != ''){
                $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                var action = component.get("c.ReceiveAl");
                action.setParams({LogisticIdss:LIds});
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        console.log('response.getReturnValue() : ',response.getReturnValue());
                        component.set("v.Container", response.getReturnValue());
                        component.set('v.showBarcode',response.getReturnValue().showProdBarcodeReceive);
                        component.set('v.disableNameReceive',response.getReturnValue().disableNameReceive);
                        component.set('v.disableLocReceive',response.getReturnValue().disableLocReceive);
                        component.set("v.AllocationAccess",response.getReturnValue().AllocationAccess);
                        console.log('setting SILILOLI here : ',response.getReturnValue().SILILOLI);
                        component.set("v.ExistingSILI",response.getReturnValue().SILILOLI);
                        component.set("v.statusOption",response.getReturnValue().status);
                        component.set("v.showfileUpload",response.getReturnValue().showUpload);
                        component.set("v.showVendorCode",response.getReturnValue().showVendorCode);
                        component.set("v.displayUplaodforItems",response.getReturnValue().showUplaodforItems);
                        console.log('response.getReturnValue().status : ',response.getReturnValue().status);
                        if(component.get("v.statusOption") != undefined && component.get("v.statusOption") != null){
                            component.set('v.SelectedStatus',component.get("v.statusOption[0].value"));
                        }
                        //changes 25-03-22 for diff tables by arshad
                        var BatchProdNos = 0;
                        var SerialProdNos = 0;
                        var NormalProducts = 0;
                        var SerBatchProducts = 0;
                        if(component.get("v.Container.SPLIS").length > 0){
                            var SPLIS = component.get("v.Container.SPLIS");
                            for(var i in SPLIS){
                                if(SPLIS[i].sili.ERP7__Product__c != null && SPLIS[i].sili.ERP7__Product__c  != undefined && SPLIS[i].sili.ERP7__Product__c  != ''){
                                    if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                        BatchProdNos += 1;
                                    }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c){
                                        SerialProdNos += 1;
                                    }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                        NormalProducts += 1;
                                    }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c){
                                        SerBatchProducts += 1;
                                    }
                                }
                            }
                        }
                        component.set("v.BatchProdsize", BatchProdNos);
                        component.set("v.SerialProdsize", SerialProdNos);
                        component.set("v.NormalProdsize", NormalProducts);
                        component.set("v.SerBatchProdsize", SerBatchProducts);
                        if(NormalProducts == 0 && SerialProdNos == 0 && BatchProdNos == 0 && SerBatchProducts == 0 && (component.get('v.ExistingSILI').length == 0)) component.set('v.hideSave',true);
                        console.log('hideSave : ',component.get('v.hideSave'));
                        
                        component.set("v.SiteName", response.getReturnValue().SiteName);
                        component.set("v.ChannelName", response.getReturnValue().ChannelName);
                        component.set("v.ChannelId", response.getReturnValue().ChannelId);
                        component.set("v.selectedSite", response.getReturnValue().selectedSite);
                        component.set("v.exceptionError", response.getReturnValue().exceptionError);
                        component.set("v.DisplayStatus", response.getReturnValue().showStatus);
                        
                        //added Shaguftha for QA change
                        component.set("v.showQA", response.getReturnValue().showInboundQA);
                        component.set("v.preventsStatusEdit", response.getReturnValue().PreventStatusEdit);
                        
                        
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        console.log('Error:',response.getError());
                    }
                });
                $A.enqueueAction(action);
            }
            else if(MOId != null && MOId != '' && MOId != undefined){
                var MIds = MOId.split(",");
                console.log('MIds : '+MIds);
                $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                var action = component.get("c.ReceiveMOItems");
                action.setParams({MOrderIds:JSON.stringify(MIds)});
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        console.log('response.getReturnValue() : ',response.getReturnValue());
                        component.set("v.Container", response.getReturnValue());
                        component.set('v.showBarcode',response.getReturnValue().showProdBarcodeReceive);
                        component.set('v.disableNameReceive',response.getReturnValue().disableNameReceive);
                        component.set('v.disableLocReceive',response.getReturnValue().disableLocReceive);
                        component.set("v.AllocationAccess",response.getReturnValue().AllocationAccess);
                        console.log('setting SILILOLI here : ',response.getReturnValue().SILILOLI);
                        component.set("v.ExistingSILI",response.getReturnValue().SILILOLI);
                        component.set("v.statusOption",response.getReturnValue().status);
                        component.set("v.showfileUpload",response.getReturnValue().showUpload);
                        component.set("v.showVendorCode",response.getReturnValue().showVendorCode);
                        component.set("v.displayUplaodforItems",response.getReturnValue().showUplaodforItems);
                        console.log('response.getReturnValue().status : ',response.getReturnValue().status);
                        if(component.get("v.statusOption") != undefined && component.get("v.statusOption") != null){
                            component.set('v.SelectedStatus',component.get("v.statusOption[0].value"));
                        }
                        component.set("v.SiteName", response.getReturnValue().SiteName);
                        component.set("v.ChannelName", response.getReturnValue().ChannelName);
                        component.set("v.ChannelId", response.getReturnValue().ChannelId);
                        component.set("v.selectedSite", response.getReturnValue().selectedSite);
                        component.set("v.exceptionError", response.getReturnValue().exceptionError);
                        component.set("v.DisplayStatus", response.getReturnValue().showStatus);
                        
                        //added Shaguftha for QA change
                        component.set("v.showQA", response.getReturnValue().showInboundQA);
                        component.set("v.preventsStatusEdit", response.getReturnValue().PreventStatusEdit);
                        
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        console.log('Error:',response.getError());
                    }
                });
                $A.enqueueAction(action);
                
            }
            helper.getpicklistValues(component, event);
        }catch(e){
            console.log('err',e);
        }
    },
    
    createBatchModal : function(component,event,helper){
        try{
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            component.set('v.BatchError','');
            var LOLId=event.currentTarget.getAttribute('data-index');
            component.set('v.currLOLIForBatch',LOLId);
            var prodId=event.currentTarget.getAttribute('data-prodId');
            component.set('v.newBatch.ERP7__Product__c',prodId);
            component.set('v.newBatch.ERP7__Shelf_Life_Expiration_Date__c','');
            var prodName=event.currentTarget.getAttribute('data-proName');
            component.set('v.proNameForBatch',prodName);
            var Container=component.get('v.Container');
            component.set('v.FileList',[]);
            component.set('v.fillList',[]);
            
            component.set('v.showDelete',false);
            //$A.util.addClass(component.find("myModalCard"),"slds-fade-in-open");
            //$A.util.addClass(component.find("myModalCardBackdrop"),"slds-backdrop_open");
            component.set("v.showCreateNewLotModal",true);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
            //component.find('NewLotNameFocus').focus();
            //component.find("NewLotNameFocus").getElement().focus();
        }catch(e){
            console.log('err',e);
        }
        
    },
    
    closeBatchModal : function(component,event,helper){
        try{
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            //$A.util.removeClass(component.find("myModalCard"),"slds-fade-in-open");
            //$A.util.removeClass(component.find("myModalCardBackdrop"),"slds-backdrop_open");
            component.set("v.showCreateNewLotModal",false);
            component.set('v.BatchError','');
            component.set('v.newBatch.ERP7__Product__c','');
            component.set('v.newBatch.ERP7__Production_Version__c','');
            component.set('v.newBatch.Name','');
            component.set('v.newBatch.ERP7__Barcode__c','');
            component.set('v.proNameForBatch','');
            component.set('v.currLOLIForBatch','');
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }catch(e){
            console.log('err',e);
        }
    },
    
    CreateBatch1: function(component,event,helper){
        try{
            console.log('CreateBatch1 ');
            component.set("v.exceptionError",'');
            var newBatch=component.get('v.newBatch');
            console.log('newBatch :  ',JSON.stringify(newBatch));
            if($A.util.isUndefinedOrNull(newBatch.ERP7__Shelf_Life_Expiration_Date__c) || $A.util.isEmpty(newBatch.ERP7__Shelf_Life_Expiration_Date__c)){
                delete newBatch['ERP7__Shelf_Life_Expiration_Date__c'];
            }
            
            if(newBatch.Name.length > 80){
                component.set("v.exceptionError", $A.get('$Label.c.Batch_name_too_large'));
                return;
            }
            if(newBatch.Name==""){
                component.set("v.exceptionError", $A.get('$Label.c.Please_Enter_Name'));
                return;
            }
            if(newBatch.ERP7__Product__c==""){
                component.set("v.exceptionError", $A.get('$Label.c.Please_select_the_Product'));
                return;
            }
            newBatch.ERP7__Vendor__c = component.get('v.vendId');
            newBatch.ERP7__Received_site__c = component.get('v.selectedSite');
            console.log('newBatch.ERP7__Vendor__c : '+newBatch.ERP7__Vendor__c)
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action=component.get('c.createBatch1');
            console.log('CreateBatch1111 ');
            action.setParams({newBatch1 : JSON.stringify(newBatch)});
            action.setCallback(this, function(response){
                if(response.getState() ==="SUCCESS"){
                    console.log('success');
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    console.log('response.getReturnValue().exError~>'+response.getReturnValue().exError);
                    component.set("v.exceptionError", response.getReturnValue().exError);
                    if(response.getReturnValue().exError != '') return;
                    var resBatch=response.getReturnValue().batch;
                    console.log('resBatch : ',resBatch);
                    delete resBatch['ERP7__Shelf_Life_Expiration_Date__c'];
                    var LOLI = component.get("v.Container.SPLIS");
                    console.log('currLOLIForBatch : ',component.get('v.currLOLIForBatch'));
                    for(var i in LOLI){
                        if(LOLI[i].sili.ERP7__Logistic_Line_Item__c == component.get('v.currLOLIForBatch')){
                            LOLI[i].sili.ERP7__Material_Batch_Lot__c=resBatch.Id;  
                        }
                    }
                    component.set('v.Container.SPLIS',LOLI);
                    
                    var LOLIS = component.get("v.Container.LOLIS");
                    for(var i in LOLIS){
                        if(LOLIS[i].LOLI != undefined && LOLIS[i].LOLI != null && LOLIS[i].LOLI.Id == component.get('v.currLOLIForBatch')){
                            LOLIS[i].assignedBatch=resBatch.Id;  
                        }
                    }
                    component.set('v.Container.LOLIS',LOLIS);
                    component.set("v.showCreateNewLotModal",false);
                    if(component.get("v.showfileUpload")){
                        var fillList11=component.get("v.fillList");
                        console.log('fillList11 :',fillList11.length);
                        if(component.find("fileId").get("v.files")!=null){
                            var recordId=resBatch.Id;
                            if (component.find("fileId").get("v.files").length > 0 && fillList11.length > 0) {   
                                console.log('here 2');
                                var fileInput = component.get("v.FileList");
                                for(var i=0;i<fileInput.length;i++) helper.saveAtt(component,event,fileInput[i],recordId);
                                
                            }
                        } 
                    }
                    //Moin added this 
                    component.set("v.showCreateNewLotModal",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get('$Label.c.Success'),
                        "type":"success",
                        "message": $A.get('$Label.c.Batch_Created_successfully')
                    });
                    toastEvent.fire();
                    
                    //changes 25-03-22 for diff tables by arshad
                    var BatchProdNos = 0;
                    var SerialProdNos = 0;
                    var NormalProducts = 0;
                    var SerBatchProducts = 0;
                    if(component.get("v.Container.SPLIS").length > 0){
                        var SPLIS = component.get("v.Container.SPLIS");
                        for(var i in SPLIS){
                            if(SPLIS[i].sili.ERP7__Product__c != null && SPLIS[i].sili.ERP7__Product__c  != undefined && SPLIS[i].sili.ERP7__Product__c  != ''){
                                if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                    BatchProdNos += 1;
                                }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c){
                                    SerialProdNos += 1;
                                }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                    NormalProducts += 1;
                                }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c){
                                    SerBatchProducts += 1;
                                }
                            }
                        }
                    }
                    component.set("v.BatchProdsize", BatchProdNos);
                    component.set("v.SerialProdsize", SerialProdNos);
                    component.set("v.NormalProdsize", NormalProducts);
                    component.set("v.SerBatchProdsize", SerBatchProducts);
                    if(NormalProducts == 0 && SerialProdNos == 0 && BatchProdNos == 0 && SerBatchProducts == 0 && (component.get('v.ExistingSILI').length == 0)) component.set('v.hideSave',true);
                    console.log('hideSave : ',component.get('v.hideSave'));
                    
                    //$A.util.removeClass(component.find("myModalCard"),"slds-fade-in-open");
                    //$A.util.removeClass(component.find("myModalCardBackdrop"),"slds-backdrop_open");
                    component.set("v.showCreateNewLotModal",false);
                    component.set('v.BatchError','');
                    component.set('v.newBatch.ERP7__Product__c','');
                    component.set('v.newBatch.ERP7__Production_Version__c','');
                    component.set('v.newBatch.Name','');
                    component.set('v.newBatch.ERP7__Barcode__c','');
                    
                }else{
                    var error=response.getError();
                    console.log('Error:',error);
                    component.set("v.exceptionError", error[0].message+' '+error[0].stackTrace);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('err',e);
        }
    },
    
    updateBarcode : function(component,event,helper){
        var name=event.getSource().get("v.value");
        component.set('v.newBatch.ERP7__Barcode__c',name);
    }, 
    
    Back2Inbound : function(component, event, helper) {
        try{
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            $A.createComponent("c:InboundReceiveLogistics",{
            },function(newcomponent, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newcomponent);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    
                }
            });
        }catch(e){
            console.log('err',e);
        }
    },
    
    getselectedlineitems : function(component, event, helper) {
        try{
            var check = event.getSource().get('v.checked');
            console.log('check : ',check);
            var loliId = event.getSource().get('v.name'); //event.target.dataset.id;
            console.log('loliId : ',loliId);
            var itemCounter = event.getSource().get('v.title');
            console.log('itemCounter : ',itemCounter);
            let sili = component.get('v.Container.SPLIS');
            let loli = component.get('v.Container.LOLIS');
            if(check && loliId != null && loliId != undefined){
                component.set('v.hideSave',false);
                console.log('loliId in: ',loliId);
                $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                
                var err = false;
                for(var x in sili){
                    if(loliId == sili[x].sili.ERP7__Logistic_Line_Item__c || x == loliId){
                        if(sili[x].sili.ERP7__Product__c != null && sili[x].sili.ERP7__Product__c  != undefined && sili[x].sili.ERP7__Product__c  != ''){
                            if(loli[itemCounter].LOLI.Id == sili[x].sili.ERP7__Logistic_Line_Item__c && sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && !$A.util.isEmpty(loli[itemCounter].assignedBatch) && !$A.util.isUndefinedOrNull(loli[itemCounter].assignedBatch)){
                                sili[x].sili.ERP7__Material_Batch_Lot__c = loli[itemCounter].assignedBatch;
                            }
                            component.set("v.scannedProd", sili[x].sili.ERP7__Product__c);
                            component.set("v.scannedIndx", x);
                            if(sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && sili[x].sili.ERP7__Product__r.ERP7__Serialise__c == false && (sili[x].sili.ERP7__Material_Batch_Lot__c == null || sili[x].sili.ERP7__Material_Batch_Lot__c == '' || sili[x].sili.ERP7__Material_Batch_Lot__c == undefined)){
                                component.set("v.exceptionError", $A.get('$Label.c.Please_select_Lot_Number_for_the_product'));
                                
                                event.getSource().set("v.checked",false);
                                sili[x].isSelected = true;
                                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                err = true; 
                            } else if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && (sili[x].sili.ERP7__Serial_Number__c == null || sili[x].sili.ERP7__Serial_Number__c == '' || sili[x].sili.ERP7__Serial_Number__c == undefined)){
                                component.set("v.exceptionError", $A.get('$Label.c.Please_enter_serial_number_for_the_product'));
                                event.getSource().set("v.checked",false);
                                sili[x].isSelected = true;
                                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                err = true;
                            } 
                                else if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c){
                                    if(sili[x].sili.ERP7__Serial_Number__c == null || sili[x].sili.ERP7__Serial_Number__c == '' || sili[x].sili.ERP7__Serial_Number__c == undefined){
                                        component.set("v.exceptionError", $A.get('$Label.c.Please_enter_serial_number_for_the_product'));
                                        event.getSource().set("v.checked",false);
                                        sili[x].isSelected = true;
                                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                        err = true;
                                    }
                                    if(sili[x].sili.ERP7__Material_Batch_Lot__c == null || sili[x].sili.ERP7__Material_Batch_Lot__c == '' || sili[x].sili.ERP7__Material_Batch_Lot__c == undefined){
                                        component.set("v.exceptionError", $A.get('$Label.c.Please_select_Lot_Number_for_the_product'));
                                        event.getSource().set("v.checked",false);
                                        sili[x].isSelected = true;
                                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                        err = true; 
                                    }
                                } else if(!sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && sili[x].sili.ERP7__Quantity__c > sili[x].RemainingQty){
                                    component.set("v.exceptionError", $A.get('$Label.c.Quantity_cannot_be_greater_than')+sili[x].RemainingQty);
                                    sili[x].isSelected = false;
                                    event.getSource().set("v.checked",false);
                                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                    err = true;
                                } else if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c  && sili[x].sili.ERP7__Quantity__c > 1){
                                    component.set("v.exceptionError", $A.get('$Label.c.Quantity_cannot_be_greater_than_1_for_serial_product'));
                                    event.getSource().set("v.checked",false);
                                    sili[x].isSelected = false;
                                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                    err = true;
                                }
                            /* else if(x == loliId && sili[x].isSelected && ){
                                    component.set("v.exceptionError", 'Product is already selected'); 
                                    event.getSource().set("v.checked",true);
                                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                                    err = true;
                                }*/
                            else{
                                sili[x].isSelected = true; 
                                err = false;
                            }
                        break;
                    } 
                }
            }
            
            console.log('sili : ',JSON.stringify(sili));
            component.set('v.Container.SPLIS',sili);
            
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            if(err) {
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.exceptionError", '');  
                    }), 3000
                );
                return;
            }
        }
            if(!check){
                for(var x in sili){
                    if(loliId == sili[x].sili.ERP7__Logistic_Line_Item__c || x == loliId){
                        sili[x].isSelected = false; 
                    }
                }
                component.set('v.Container.SPLIS',sili);
                if(sili.length >= 1 ){
                    component.set('v.hideSave',false);
                }
            }
        }catch(e){
            console.log('err',e);
        }
    },
    //added by matheen
    handleExpiryDateChange: function(component, event, helper) {
        var stockCounter = event.getSource().get("v.name"); // Get the stockCounter (index)
        var newExpiryDate = event.getSource().get("v.value"); // Get the selected date
        
        var allStocks = component.get("v.Container.SPLIS");
        if (allStocks && allStocks.length > stockCounter) {
            allStocks[stockCounter].sili.ERP7__Expiry_Date__c = newExpiryDate;
            component.set("v.Container.SPLIS", allStocks);
        }
    },

    SaveAllLOLines : function(component, event, helper) {
        try{
            var LOLIS = component.get('v.Container.LOLIS');
            var SOLIS = component.get('v.Container.SPLIS');
            console.log('SOLIS 1 : ',JSON.stringify(SOLIS));
            let allsili = component.get('v.ExistingSILI');
            console.log('sili n : ExistingSILI : ',JSON.stringify(allsili));
            console.log('showQA~>'+component.get('v.showQA'));
            
            for(var i in allsili){
                if(allsili[i].guideline != null){
                    let checklists = allsili[i].guideline;
                    for(var x in checklists){
                        console.log('checklists[x]~>'+JSON.stringify(checklists[x]));
                        if(checklists[x].hasOwnProperty('Attachments')){
                            delete checklists[x].Attachments;
                        }
                    }
                }
            }
            
            if(component.get('v.showQA')){
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
                        } 
                    }
                }
            }
            
            for(var x in LOLIS){
                if(!$A.util.isEmpty(LOLIS[x].assignedBatch) && !$A.util.isUndefinedOrNull(LOLIS[x].assignedBatch) && !$A.util.isEmpty(LOLIS[x].loliId) && !$A.util.isUndefinedOrNull(LOLIS[x].loliId)){
                    for(var i in SOLIS){
                        if(SOLIS[i].isSelected && !$A.util.isEmpty(SOLIS[i].loliId) && !$A.util.isUndefinedOrNull(SOLIS[i].loliId) && !$A.util.isEmpty(SOLIS[i].sili.ERP7__Product__c) && !$A.util.isUndefinedOrNull(SOLIS[i].sili.ERP7__Product__c)){
                            if(LOLIS[x].loliId == SOLIS[i].loliId && SOLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c){
                                SOLIS[i].sili.ERP7__Material_Batch_Lot__c = LOLIS[x].assignedBatch;
                            }
                        }
                    }
                }
            }
            console.log('SOLIS 2 : ',JSON.stringify(SOLIS));
            component.set("v.Container.SPLIS",SOLIS);
            console.log('SOLIS 3 : ',JSON.stringify(SOLIS));
            let selected = [];
            let sili = component.get('v.Container.SPLIS');
            console.log('sili : ',JSON.stringify(sili));
            for(var x in sili){
                console.log('sili[x].sili.ERP7__Location__c bfr: ',sili[x].sili.ERP7__Location__c);
                if(sili[x].isSelected && (sili[x].sili.ERP7__Location__c == '' || sili[x].sili.ERP7__Location__c == undefined)) sili[x].sili.ERP7__Location__c = null;
                console.log('sili[x].sili.ERP7__Location__c after: ',sili[x].sili.ERP7__Location__c);
                if(sili[x].isSelected && sili[x].sili.ERP7__Product__c != null && sili[x].sili.ERP7__Product__c  != undefined && sili[x].sili.ERP7__Product__c  != ''){
                    if(sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && (sili[x].sili.ERP7__Material_Batch_Lot__c == null || sili[x].sili.ERP7__Material_Batch_Lot__c == '' || sili[x].sili.ERP7__Material_Batch_Lot__c == undefined)){
                        component.set("v.exceptionError", $A.get('$Label.c.Please_select_Lot_for_Product_to_proceed'));
                        return;
                    }else if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && (sili[x].sili.ERP7__Serial_Number__c == null || sili[x].sili.ERP7__Serial_Number__c == '' || sili[x].sili.ERP7__Serial_Number__c == undefined)){
                        component.set("v.exceptionError", $A.get('$Label.c.Please_enter_serial_number_for_Product_to_proceed'));
                        return;
                    }else if(!sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && sili[x].sili.ERP7__Quantity__c > sili[x].RemainingQty){
                        component.set("v.exceptionError", $A.get('$Label.c.Quantity_cannot_be_greater_than')+sili[x].RemainingQty);
                        return;
                    }else if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c  && sili[x].sili.ERP7__Quantity__c > 1){
                        component.set("v.exceptionError", $A.get('$Label.c.Quantity_cannot_be_greater_than_1_for_serial_product'));
                        return;
                    }else if(sili[x].sili.ERP7__Quantity__c <= 0){
                        component.set("v.exceptionError", $A.get('$Label.c.Quantity_cannot_be_less_than_or_equal_to_zero_for_product')+sili[x].sili.ERP7__Product__r.Name);
                        return;
                    }else selected.push(sili[x].sili);
                }
            }
            // console.log('selected : ',selected.length);
            console.log('selected items list : ',JSON.stringify(selected));
            //return;
            //console.log('component.get(v.ExistingSILI).length : ',component.get('v.ExistingSILI').length);
            /* if(selected.length == 0 && sili.length > 0){
               component.set("v.exceptionError", 'Please select line item/Product to proceed.'); 
            }*/
            if(selected.length > 0 || component.get('v.ExistingSILI').length > 0){
                $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                
                var action = component.get('c.saveAlldetail');
                action.setParams({sili : JSON.stringify(selected),selectecSite : component.get('v.selectedSite'),createdsili : JSON.stringify(allsili) });
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        console.log('resp~>',response.getReturnValue());
                        if(response.getReturnValue().exceptionError != '' && response.getReturnValue().exceptionError != null && response.getReturnValue().exceptionError != undefined){
                            var errmsg = response.getReturnValue().exceptionError;
                            console.log('errmsg : ',errmsg);
                            console.log('Index-->'+errmsg.indexOf("duplicate"));
                            //Moin Commented this below code on 13th November 2023 
                            /*if(errmsg.indexOf("duplicate") != -1 && errmsg.indexOf("serial") != -1){
                                component.set("v.exceptionError",$A.get('$Label.c.Duplicate_Serial_Numbers_Found'));
                            }else{
                                component.set("v.exceptionError", errmsg);
                            }*/
                            
                            var match = errmsg.match(/FIELD_CUSTOM_VALIDATION_EXCEPTION, (.+):/);
                            console.log('match : ', match);
                            // Display the extracted error message
                            if (match && match[1]) {
                                var errorMessageParts = match[1].split(':');
                                if (errorMessageParts.length === 2 && errorMessageParts !=null) {
                                    var part1 = errorMessageParts[0].trim();
                                    component.set("v.exceptionError",part1);
                                }else{
                                    component.set("v.exceptionError",match[1]);
                                }
                            } else {
                                // If no match is found, display the original error message
                                component.set("v.exceptionError", errmsg);
                            }
                            
                            //commented 25-05-22 arshad
                            /*for(var x in sili){
                                if(sili[x].isSelected){
                                    sili[x].isSelected = false;
                                }
                            }*/
                            component.set('v.Container.SPLIS',sili);
                            
                        }
                        else{
                            // console.log('no exceptionError : ',response.getReturnValue());
                            console.log('res receive : ',response.getReturnValue());
                            let splis = response.getReturnValue().SPLIS;
                            console.log('splis : ',splis.length);
                            
                            /*console.log(' bgfr: ',JSON.stringify(component.get('v.Container.SPLIS')));
                            if(splis.length == 0 && component.get("v.ExistingSILI").length) component.set('v.Container.SPLIS',sili);
                            else*/ 
                            component.set('v.Container',response.getReturnValue());
                            
                            component.set("v.ExistingSILI",response.getReturnValue().SILILOLI);
                            
                            if(splis.length == 0 && selected.length == 0) {
                                component.set('v.Container.SPLIS',sili);
                                component.set('v.Container.LOLIS',LOLIS);  
                                console.log('splis after: ',JSON.stringify(component.get('v.Container.SPLIS')));
                            } 
                            var toastEvent = $A.get("e.force:showToast");
                            if(toastEvent!=undefined){
                                toastEvent.setParams({
                                    'title' : $A.get('$Label.c.Success'),
                                    'message': $A.get('$Label.c.The_items_saved_Successfully'),
                                    'duration':' 5000',
                                    'key': 'info_alt',
                                    'type': 'success',
                                    'mode': 'dismissible',
                                    'dismissible' : true,
                                    "variant": "Success",
                                });
                                toastEvent.fire();
                            }
                            var BatchProdNos = 0;
                            var SerialProdNos = 0;
                            var NormalProducts = 0;
                            var SerBatchProducts = 0;
                            console.log('component.get("v.Container.SPLIS").length : ',component.get("v.Container.SPLIS").length);
                            if(component.get("v.Container.SPLIS").length > 0){
                                console.log('yes');
                                var SPLIS = component.get("v.Container.SPLIS");
                                for(var i in SPLIS){
                                    if(SPLIS[i].sili.ERP7__Product__c != null && SPLIS[i].sili.ERP7__Product__c  != undefined && SPLIS[i].sili.ERP7__Product__c  != ''){
                                        if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                            BatchProdNos += 1;
                                        }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c){
                                            SerialProdNos += 1;
                                        }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                            NormalProducts += 1;
                                        }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c){
                                            SerBatchProducts += 1;
                                        }
                                    }
                                }
                            }
                            component.set("v.BatchProdsize", BatchProdNos);
                            component.set("v.SerialProdsize", SerialProdNos);
                            component.set("v.NormalProdsize", NormalProducts);
                            component.set("v.SerBatchProdsize", SerBatchProducts);
                            if(NormalProducts == 0 && SerialProdNos == 0 && BatchProdNos == 0 && SerBatchProducts == 0 && (component.get('v.ExistingSILI').length == 0)) component.set('v.hideSave',true);
                            console.log('hideSave : ',component.get('v.hideSave'));
                        }
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        component.set('v.hideSave',true);
                        //changes 25-03-22 for diff tables by arshad
                        //Moin moved this on top on 14th November 2023
                        /*var BatchProdNos = 0;
                        var SerialProdNos = 0;
                        var NormalProducts = 0;
                        var SerBatchProducts = 0;
                        console.log('component.get("v.Container.SPLIS").length : ',component.get("v.Container.SPLIS").length);
                        if(component.get("v.Container.SPLIS").length > 0){
                            console.log('yes');
                            var SPLIS = component.get("v.Container.SPLIS");
                            for(var i in SPLIS){
                                if(SPLIS[i].sili.ERP7__Product__c != null && SPLIS[i].sili.ERP7__Product__c  != undefined && SPLIS[i].sili.ERP7__Product__c  != ''){
                                    if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                        BatchProdNos += 1;
                                    }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c){
                                        SerialProdNos += 1;
                                    }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c == false && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c == false){
                                        NormalProducts += 1;
                                    }else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c){
                                        SerBatchProducts += 1;
                                    }
                                }
                            }
                        }
                        component.set("v.BatchProdsize", BatchProdNos);
                        component.set("v.SerialProdsize", SerialProdNos);
                        component.set("v.NormalProdsize", NormalProducts);
                        component.set("v.SerBatchProdsize", SerBatchProducts);
                        if(NormalProducts == 0 && SerialProdNos == 0 && BatchProdNos == 0 && SerBatchProducts == 0 && (component.get('v.ExistingSILI').length == 0)) component.set('v.hideSave',true);
                        console.log('hideSave : ',component.get('v.hideSave'));*/
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                component.set("v.exceptionError", $A.get('$Label.c.Please_select_line_item_Product_to_proceed'));
                
            }
        }
        catch(err){
            console.log('er : ',JSON.stringify(err));
        }
        
    },
    
    reRender : function(component, event, helper) { },
    
    closeError : function(component, event, helper) {
        component.set('v.exceptionError','');
    },
    
    focusTOscan : function (component, event,helper) {
        try{
            var scanedfield = component.get("v.scanValue");
            console.log('focusTOscan scanedfield : ',scanedfield);
            var editedFieldId = event.getSource().getLocalId();
            console.log('focusTOscan editedFieldId : ',editedFieldId);
            if(editedFieldId == scanedfield){
                console.log('focusTOscan helper ');
                component.set("v.scanValue",'');
                helper.focusTOscan(component, event); 
            }
        }catch(e){
            console.log('err',JSON.stringify(e));
        }
    },
    
    checkSerials : function (component, event,helper) {
        try{
            console.log('checkDuplicateSerials called');
            component.set("v.exceptionError","");
            var value =event.getSource().get("v.value");
            var index = event.getSource().get('v.name'); 
            console.log('value : ',value);
            console.log('index : ',index);
            //if(event.which == 13){
            helper.helperserial(component, event,helper,value,index);
            //}
        }catch(e){
            console.log('err',JSON.stringify(e));
        }
    },
    
    handlequantity : function (component, event,helper) {
        try{
            let value =event.getSource().get("v.value");
            console.log('value : ',value);
            var error = false;
            var index = event.getSource().get('v.name'); 
            console.log('index : ',index);
            var LOLId=event.getSource().get('v.title'); //event.target.getAttribute('data-index');
            console.log('LOLId : ',LOLId);
            let sili = component.get('v.Container.SPLIS');
            if(value != '' && value != null && value != undefined && LOLId != null && LOLId != '' && LOLId != undefined && index != null && index != undefined){
                for(var x in sili){
                    if(sili[x].sili.ERP7__Logistic_Line_Item__c == LOLId && x == index){
                        if(sili[x].sili.ERP7__Serial_Number__c != '' && sili[x].sili.ERP7__Serial_Number__c != null && sili[x].sili.ERP7__Serial_Number__c != undefined){
                            /* if(value == 0){
                        component.set('v.exceptionError','Quantity cannot be equal to zero');
                        error = true;
                    }*/
                        if(sili[x].sili.ERP7__Product__r.ERP7__Lot_Tracked__c &&  (value >  sili[x].RemainingQty)){
                            component.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_greater_than')+sili[x].RemainingQty);
                            sili[x].sili.ERP7__Quantity__c = sili[x].RemainingQty;
                            error = true;
                            setTimeout(function(){component.set("v.exceptionError", "");
                                                  console.log('Inside settimeout');}, 5000);
                        }else if(sili[x].sili.ERP7__Product__r.ERP7__Serialise__c && value > 1){
                            sili[x].sili.ERP7__Quantity__c = 1;
                            component.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_greater_than_1_for_serial_product'));
                            error = true; 
                            setTimeout(function(){component.set("v.exceptionError", "");
                                                  console.log('Inside settimeout');}, 5000);
                        }else if(value <= 0 && !sili[x].sili.ERP7__Product__r.ERP7__Serialise__c){
                            sili[x].sili.ERP7__Quantity__c = sili[x].RemainingQty;
                            component.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_less_than_zero'));
                            error = true;
                            setTimeout(function(){component.set("v.exceptionError", "");
                                                  console.log('Inside settimeout');}, 5000);
                        }else if(value <= 0 && sili[x].sili.ERP7__Product__r.ERP7__Serialise__c){
                            sili[x].sili.ERP7__Quantity__c = 1;
                            component.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_less_than_zero'));
                            error = true;
                            setTimeout(function(){component.set("v.exceptionError", "");
                                                  console.log('Inside settimeout');}, 5000);
                        }
                    }	
                }
            } 
        }
            else{
                component.set('v.exceptionError',$A.get('$Label.c.Quantity_cannot_be_less_than_zero'));
                setTimeout(function(){component.set("v.exceptionError", "");
                                      console.log('Inside settimeout');}, 5000);
            }
            if(error){
                component.set('v.Container.SPLIS',sili);
                return;
            }
        }catch(e){
            console.log('err',JSON.stringify(e));
        }
    },
    handleStatusChange: function (component, event, helper) {
    try {
        var statusval = event.getSource().get('v.value');
        console.log('statusval : ', statusval);
        var siliId = event.getSource().get('v.name');
        console.log('siliId : ', siliId);
        component.set('v.hideSave', false);
        let receivedsili = component.get('v.ExistingSILI');
        var err = false;
        component.set('v.exceptionError', '');

        console.log('InStockPickListValue : ', $A.get('$Label.c.InStockPickListValue'));
        console.log('PassedChecklistValue : ', $A.get('$Label.c.PassedChecklistValue'));
        console.log('showQA~>' + component.get('v.showQA'));

        if (component.get('v.showQA')) {
            for (var y in receivedsili) {
                if (receivedsili[y].guideline != null && receivedsili[y].guideline != undefined) {
                    console.log('1 2 : ');
                    let qualityChecks = receivedsili[y].guideline;
                    console.log('1 23  : ', JSON.stringify(qualityChecks));

                    for (var x in qualityChecks) {
                        // Validate for the matching SILI and the status to be "In Stock"
                        if (qualityChecks[x].ERP7__Stock_Inward_Line_Item__c == siliId && statusval == $A.get('$Label.c.InStockPickListValue')) {
                            // If the checklist is mandatory and the instruction is missing
                            if (qualityChecks[x].ERP7__Checklist__r.ERP7__Is_Mandatory__c) {
                                console.log('Checklist mandatory and pending');
                                console.log('Checklist ins :',qualityChecks[x].ERP7__Instructions__c);
                                 console.log('Checklist ERP7__Has_Checklist__c :',qualityChecks[x].ERP7__Has_Checklist__c);
                                console.log('Checklist qualityChecks[x].ERP7__Checklist__r.ERP7__Has_Checklist__c :',qualityChecks[x].ERP7__Checklist__r.ERP7__Has_Checklist__c);

                                // Check if the instructions are missing or not passed
                                if (!qualityChecks[x].ERP7__Instructions__c || qualityChecks[x].ERP7__Instructions__c == '--None--' || qualityChecks[x].ERP7__Instructions__c == null) {
                                    component.set('v.exceptionError', $A.get('$Label.c.CompleteMandatoryChecklist'));
                                    err = true;
                                    break;
                                } 
                                // Check for checklist in the related object and validate passed value
                                else if (qualityChecks[x].ERP7__Checklist__r.ERP7__Has_Checklist__c != undefined) {
                                    if (qualityChecks[x].ERP7__Checklist__r.ERP7__Has_Checklist__c && qualityChecks[x].ERP7__Instructions__c != $A.get('$Label.c.PassedChecklistValue')) {
                                        component.set('v.exceptionError', $A.get('$Label.c.MandatoryChecklistpassed'));
                                        err = true;
                                        break;
                                    }
                                }
                                // Check for checklist directly on the object and validate passed value
                                else if (qualityChecks[x].ERP7__Has_checklist__c != undefined) {
                                    if (qualityChecks[x].ERP7__Has_checklist__c && qualityChecks[x].ERP7__Instructions__c != $A.get('$Label.c.PassedChecklistValue')) {
                                        component.set('v.exceptionError', $A.get('$Label.c.MandatoryChecklistpassed'));
                                        err = true;
                                        break;
                                    }
                                }
                            } else {
                                console.log('Checklist not mandatory');
                            }
                        }
                    }

                    console.log('err : ', err);
                    if (err) {
                        if (receivedsili[y].sili.Id == siliId) {
                            receivedsili[y].sili.ERP7__Status__c = 'Quality Check(QA)';
                        }
                    }
                }
            }
            // Set the modified SILI list back to the component
            component.set('v.ExistingSILI', receivedsili);
        }
    } catch (e) {
        console.log('catch err occurred~>' + e);
    }
},

 back2Inbound : function (component, event,helper) {
        var loc = window.location.reload();
        console.log('loc : ',loc);
        
    },
    showStatusChange : function (component, event,helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        $A.util.addClass(component.find("myModalStatus"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalStatusBackdrop"),"slds-backdrop_open");
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    closestatusModal : function(component,event,helper){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        $A.util.removeClass(component.find("myModalStatus"),"slds-fade-in-open");
        $A.util.removeClass(component.find("myModalStatusBackdrop"),"slds-backdrop_open");
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    updateStatus : function(component,event,helper){
        try{
            console.log('arshad updateStatus called');
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var status = component.get('v.SelectedStatus');
            console.log('status : ',status);
            if(status != null && status != '' && status != undefined){
                let receivedsili = component.get('v.ExistingSILI');
                let receivedsiliSili = [];
                var err = false;
                
                console.log('InStockPickListValue : ',$A.get('$Label.c.InStockPickListValue'));
                console.log('PassedChecklistValue : ',$A.get('$Label.c.PassedChecklistValue'));
                
                if(component.get('v.showQA') && status == 'In Stock'){//$A.get('$Label.c.InStockPickListValue')
                    for(var y in receivedsili){
                        if(receivedsili[y].guideline != null && receivedsili[y].guideline != undefined){
                            console.log('1 2 : ');
                            let qualityChecks =  receivedsili[y].guideline;
                            console.log('1 23  : ',JSON.stringify(qualityChecks));
                            for(var x in qualityChecks){
                                if(qualityChecks[x].ERP7__Checklist__r.ERP7__Is_Mandatory__c){
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
                        }   
                    }
                } 
                
                if(err == false){
                    for(var x in receivedsili){
                        receivedsili[x].sili.ERP7__Status__c = status;
                        receivedsiliSili.push(receivedsili[x].sili);
                    }
                    var action = component.get('c.UpdateSILI');
                    action.setParams({'sili':JSON.stringify(receivedsiliSili)});
                    action.setCallback(this,function(response){
                        if(response.getState() === 'SUCCESS'){
                            if(response.getReturnValue() != null){
                                console.log('arshad inhere set success');
                                component.set("v.ExistingSILI",receivedsili);    
                            }else{
                                console.log('arshad in here else null');
                            }
                        }else{
                            console.log('arshad in here err thrown~>',response.getError());
                            var err = response.getError();
                            component.set("v.exceptionError",err[0].message);
                            setTimeout(function () { component.set("v.exceptionError",""); }, 5000);
                        }          
                    });
                    $A.enqueueAction(action);  
                    
                    $A.util.removeClass(component.find("myModalStatus"),"slds-fade-in-open");
                    $A.util.removeClass(component.find("myModalStatusBackdrop"),"slds-backdrop_open");
                }else{
                    console.log('err is true');
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            else{
                component.set("v.exceptionError",'Please select the status to change'); 
                $A.util.removeClass(component.find("myModalStatus"),"slds-fade-in-open");
                $A.util.removeClass(component.find("myModalStatusBackdrop"),"slds-backdrop_open");
                $A.util.addClass(component.find('mainSpin'), "slds-hide"); 
            }
        }catch(e){
            console.log('err',JSON.stringify(e));
        }
    },
    
    //method changed for multiple files upload arshad 30/03/23
    handleFilesChange: function(component, event, helper) {
        try{
            console.log('handleFilesChange called');
            component.set("v.showDelete",true);
            var fileName = 'No File Selected..';
            var files = component.get("v.fillList");  
            //console.log('files length : ',event.getSource().get("v.files").length);
            var allfiles = component.get("v.FileList"); 
            var sourcevalue = event.getSource();
            if (sourcevalue!=null && sourcevalue!=undefined) {
                if(event.getSource().get("v.files")!=null && event.getSource().get("v.files").length > 0){
                    //fileName = event.getSource().get("v.files")[0]['name'];
                    console.log('fileName : ',fileName);
                    var fileItem = [];
                    console.log('files : ',files.length);
                    if(files.length > 0) fileItem = files;
                    
                    var fileItemList = [];
                    console.log('allfiles : ',allfiles.length);
                    if(allfiles.length > 0) fileItemList = allfiles;
                    for(var i=0;i<event.getSource().get("v.files").length;i++){
                        fileItem.push(event.getSource().get("v.files")[i]['name']);
                        fileItemList.push(event.getSource().get("v.files")[i]);
                    }
                }
            }
            //alert(fileItem);
            component.set("v.fillList",fileItem);
            component.set("v.FileList",fileItemList);
            component.set("v.fileName", fileName);
        }catch(e){
            console.log('err',JSON.stringify(e));
        }
    },
    removeAttachment : function(component, event, helper) {
        component.set("v.showDelete",false);
        var fileName = 'No File Selected..';
        component.set("v.fileName", fileName);        
        var fillList=component.get("v.fillList");
        fillList.splice(0, fillList.length); 
        component.set("v.fillList",fillList);
        
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
    
handleUploadFinished: function(component, event, helper) {
    try {
        var parms = event.getSource().get('v.recordId');
        if (!parms) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "Record ID is missing.",
                type: "error"
            });
            toastEvent.fire();
            return;
        }
        console.log('parms : ', parms);
        var action = component.get('c.getuploadedfiles');
        action.setParams({
            recId: parms
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getReturnValue from handleUploadFinished : ', response.getReturnValue());
            if (state === 'SUCCESS' && response.getReturnValue() != null) {
                var result = response.getReturnValue();
                // Check if the Apex method returned an error
                if (result.error) {
                    component.set('v.uploadError', result.error);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: result.error, // Display the error from Apex
                        type: "error"
                    });
                    toastEvent.fire();
                    return;
                }
                // Process successful response
                var LOLIs = component.get('v.Container.LOLIS');
                for (var x in LOLIs) {
                    if (LOLIs[x].LOLI != undefined && LOLIs[x].LOLI != null) {
                        if (LOLIs[x].LOLI.Id == parms) {
                            LOLIs[x].Attach = result.links; // Use 'links' from Apex response
                        }
                    }
                }
                console.log('LOLIs : ', LOLIs);
                component.set("v.Container.LOLIS", LOLIs);
                component.set('v.uploadError', ''); // Clear any previous errors
                component.getAllRecieveDetails(); // Refresh data
                // Optionally uncomment to refresh the view
                // $A.get('e.force:refreshView').fire();
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.log('errors', errors);
                var errorMessage = 'An unexpected error occurred while processing the file.';
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
                component.set('v.uploadError', errorMessage);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: errorMessage,
                    type: "error"
                });
                toastEvent.fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: "No files found or invalid record ID.",
                    type: "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    } catch (e) {
        console.log('err', JSON.stringify(e));
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Error",
            message: "An error occurred while uploading the file: " + e.message,
            type: "error"
        });
        toastEvent.fire();
    }
},
    
    handleUploadFinished1: function (component, event, helper) {
        try {
            var parms = event.getSource().get('v.recordId');
            var uploadedFiles = event.getParam("files");  
            var documentId = uploadedFiles[0].documentId;  
            var fileName = uploadedFiles[0].name;  
            var fName = component.find("fileName").get("v.value"); 
            console.log('parms : ', parms);

            var action = component.get('c.UpdateFiles');
            action.setParams({
                "documentId":documentId, 
                "title": fName,
                "recordId": parms
            });
            action.setCallback(this, function (response) {
                console.log('response.getReturnValue : ', response.getReturnValue());
                if (response.getState() === 'SUCCESS' && response.getReturnValue() != null) {
                    var LOLIs = component.get('v.Container.LOLIS');
                    for (var x in LOLIs) {
                        if (LOLIs[x].LOLI != undefined && LOLIs[x].LOLI != null) {
                            if (LOLIs[x].LOLI.Id == parms) {
                                LOLIs[x].Attach = response.getReturnValue();
                            }
                        }
                    }
                    console.log('LOLIs : ', LOLIs);
                    component.set("v.Container.LOLIS", LOLIs);
                }

            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log('err', JSON.stringify(e));
        }
    },
    
    
    imageError: function(component,event,helper){
        console.log('imageError called');
        event.target.style.display = 'none';
    },
    
    //added by arshad
    DeleteRecordATforQAGuideLines : function(component,event,helper){
        try{
            var result = confirm("Are you sure?");
            console.log('result : ',result);
            var RecordId = event.getSource().get("v.name");
            console.log('RecordId : ',RecordId);
            var parentId = event.getSource().get("v.title"); 
            console.log('parentId : ',JSON.stringify(parentId));
            if(result){
                var action = component.get('c.DeleteAttachFromInboundList');
                action.setParams({
                    attachId: RecordId,
                    parentId: parentId,
                });
                action.setCallback(this, function(response) {
                    console.log('response.getReturnValue : ',response.getReturnValue());
                    if(response.getState() === 'SUCCESS'){
                        component.getAllRecieveDetails(); 
                        /*var exitingsolis = component.get("v.ExistingSILI");
                    for(var x in exitingsolis){
                        var sili = [];
                        sili = exitingsolis[x].guideline;                       
                        for(var y in sili){
                            if(sili[y].Id == parentId){ 
                            sili[y].Attachments = response.getReturnValue();
                            }
                        }
                    }
                    component.set("v.ExistingSILI", exitingsolis);*/
                }else{
                    var errors = response.getError();
                    console.log("server error in doInit : ", JSON.stringify(errors));
                    component.set("v.exceptionError", errors[0].message);
                }
            });
            $A.enqueueAction(action);
        }
        }catch(e){
            console.log('err',JSON.stringify(e));
        }
    },
    
    DeleteRecordAT : function(component,event,helper){
        try{
            var result = confirm("Are you sure?");
            console.log('result : ',result);
            var parms = event.getSource().get('v.name');
            console.log('parms : ',parms);
            var logId = event.getSource().get('v.title');
            console.log('logId : ',logId);
            if(result){
                var action = component.get('c.deleteFile');
                action.setParams({
                    recId: parms,
                    LoId : logId
                });
                action.setCallback(this, function(response) {
                    console.log('response.getReturnValue : ',response.getReturnValue());
                    if(response.getState() === 'SUCCESS'){//Moin commented this && response.getReturnValue() != null
                        var LOLIs = component.get('v.Container.LOLIS');
                        for(var x in LOLIs){
                            if(LOLIs[x].LOLI != undefined && LOLIs[x].LOLI != null){
                                if(LOLIs[x].LOLI.Id == logId){
                                    LOLIs[x].Attach =  response.getReturnValue();
                                }
                            }
                        }
                        component.set("v.Container.LOLIS", LOLIs);  
                        console.log('LOLIs : ',LOLIs);
                        
                    }
                    
                });
                $A.enqueueAction(action);
            }
        }catch(e){
            console.log('err',JSON.stringify(e));
        }
    },
    
    setChecklistResult : function(component,event,helper){
        component.set('v.hideSave',false);
        /* var checkId = event.getSource().get('v.name');
        console.log('event.currentTarget.value : ',event.currentTarget.value);
        console.log('checkId : ',checkId);
        if(checkId != null && checkId != undefined && checkId != ''){
            var checks = component.get('v.Container.ProdChecks');
            for(var x in checks){
                if(checkId == checks[x].Checks.Id){
                    checks[x].Checks.ERP7__Result__c = event.currentTarget.value;
                }
            }
            component.set('v.Container.ProdChecks',checks);
            component.set('v.hideSave',false);
        }*/
    },
    setActions : function(component,event,helper){
        console.log('setActions called');
        component.set('v.hideSave',false);
        console.log('setActions called : ',component.get('v.hideSave'));
        /* var checkId = event.getSource().get('v.title');
        console.log('event.currentTarget.value : ',event.currentTarget.value);
        console.log('checkId : ',checkId);
        if(checkId != null && checkId != undefined && checkId != ''){
            var checks = component.get('v.Container.ProdChecks');
            for(var x in checks){
                if(checkId == checks[x].Checks.Id){
                    checks[x].Checks.ERP7__Action_Detail__c = event.currentTarget.value;
                }
            }
            component.set('v.Container.ProdChecks',checks);
            component.set('v.hideSave',false);
        }*/
    },
    
    reRender : function(component, event, helper) { 
    },
    onFileUploadedQAGuideLines: function(component, event, helper) {
    $A.util.removeClass(component.find('mainSpin'), "slds-hide"); // Show spinner
    try {
        var sourcevalue = event.getSource();
        if (sourcevalue != null && sourcevalue != undefined) {
            if (event.getSource().get("v.files") != null && event.getSource().get("v.files").length > 0) {
                component.set("v.FileListforQAguidelines", event.getSource().get("v.files"));
                let files = component.get("v.FileListforQAguidelines");
                console.log('FileListforQAguidelines: ', files);

                let fileNameList = [];
                let base64DataList = [];
                let contentTypeList = [];

                if (files && files.length > 0) {
                    let parentId = event.getSource().get("v.name");
                    console.log('files: ', files.length);
                    console.log('files[0]: ', files[0].length);

                    // Validation: Check individual and total file sizes
                    let totalSize = 0;
                    const MAX_FILE_SIZE = 2 * 1024 * 1024; // 2 MB
                    const MAX_TOTAL_SIZE = 6 * 1024 * 1024; // 6 MB

                    for (let i = 0; i < files[0].length; i++) {
                        let file = files[0][i];
                        console.log('File size: ', file.size);

                        // Check individual file size
                        if (file.size > MAX_FILE_SIZE) {
                            throw new Error(`File "${file.name}" exceeds the 2 MB size limit.`);
                        }

                        // Accumulate total size
                        totalSize += file.size;
                    }

                    // Check total size
                    if (totalSize > MAX_TOTAL_SIZE) {
                        throw new Error(`Total file size exceeds the 6 MB limit.`);
                    }

                    // Proceed with file upload if validation passes
                    if (files[0].length > 0) {
                        for (let i = 0; i < files[0].length; i++) {
                            let file = files[0][i];
                            let reader = new FileReader();

                            // Asynchronous file reading
                            reader.onloadend = function() {
                                console.log('inside reader.onloadend');
                                let contents = reader.result;
                                let base64Mark = 'base64,';
                                let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                                let fileContents = contents.substring(dataStart);

                                fileNameList.push(file.name);
                                base64DataList.push(encodeURIComponent(fileContents));
                                contentTypeList.push(file.type);

                                console.log('fileNameList: ', fileNameList.length);
                                console.log('base64DataList: ', base64DataList.length);
                                console.log('contentTypeList: ', contentTypeList.length);

                                // Check if all files are processed
                                if (fileNameList.length == files[0].length) {
                                    helper.finishAllFilesUploadforQAguidelines(parentId, fileNameList, base64DataList, contentTypeList, component, event, helper);
                                } else {
                                    console.log('Not all files processed yet.');
                                }
                            };

                            reader.onerror = function() {
                                console.log('Error reading file: ', reader.error);
                                $A.util.addClass(component.find('mainSpin'), "slds-hide"); // Hide spinner
                            };

                            reader.readAsDataURL(file);
                        }
                    }
                }
            }
        }
    } catch (err) {
        console.log("Error catch: ", err);
        $A.util.addClass(component.find('mainSpin'), "slds-hide"); // Hide spinner

        // Show error message to the user
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Error",
            message: err.message,
            type: "error"
        });
        toastEvent.fire();
    }
},
    generateSerials : function(component, event, helper) {
        var loliId = event.getSource().get('v.name');
        if(loliId != null && loliId != '' && loliId != undefined){
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var lolis = component.get('v.Container.LOLIS');
            var silis = component.get('v.Container.SPLIS');
            for(var x in lolis){
                if(loliId == lolis[x].LOLI.Id){
                    var prefix  = lolis[x].LOLI.ERP7__Serial_Number_Prefix__c;
                    var startnumb = lolis[x].LOLI.ERP7__Starting_Number__c;
                    var numericValue = parseInt(startnumb); 
                    if(prefix != null && prefix != '' && prefix != undefined && startnumb != null && startnumb != undefined){
                        for(var y in silis){
                            if(silis[y].loliId == lolis[x].loliId){
                                console.log('numericValue : ',numericValue);
                                const formattedSerial = prefix + numericValue.toString().padStart(startnumb.toString().length, '0');
                                console.log('formattedSerial : ',formattedSerial);
                                silis[y].sili.ERP7__Serial_Number__c = formattedSerial;//prefix +startnumb;
                                console.log('silis[y].sili.ERP7__Serial_Number__c : ',silis[y].sili.ERP7__Serial_Number__c);
                                numericValue = numericValue + 1;
                            }
                        }
                    }
                }
            }
            component.set('v.Container.SPLIS',silis);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
    },
    selectAllSerials : function(component,event,helper){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var checkval = event.getSource().get('v.checked'); //component.get('v.SelectSerials');
        console.log('checkval : ',checkval);
        var LOLIId = event.getSource().get('v.name');
        console.log('LOLIId : ',LOLIId); 
        var container = component.get('v.Container.SPLIS');
        for(var x in container){
            if(container[x].loliId == LOLIId){
                if(container[x].sili.ERP7__Serial_Number__c != null && container[x].sili.ERP7__Serial_Number__c != '' && container[x].sili.ERP7__Serial_Number__c != undefined){
                    container[x].isSelected = checkval; 
                }
                else{
                    component.set('v.exceptionError','Please enter Serial Numbers');
                    component.set('v.SelectSerials',false);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    return;
                }
                
            }
        }
        component.set('v.Container.SPLIS',container);
        if(checkval) component.set('v.hideSave',false);
        else component.set('v.hideSave',true);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    selectAllbatchSerials : function(component,event,helper){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var checkval = component.get('v.SelectBatchSerials');
        console.log('checkval : ',checkval);
        var LOLIId = event.getSource().get('v.name');
        console.log('LOLIId : ',LOLIId);
        var container = component.get('v.Container.SPLIS');
        for(var x in container){
            if(container[x].loliId == LOLIId){
                if(container[x].sili.ERP7__Serial_Number__c != null && container[x].sili.ERP7__Serial_Number__c != '' && container[x].sili.ERP7__Serial_Number__c != undefined){
                    container[x].isSelected = checkval; 
                }
                else{
                    component.set('v.exceptionError','Please enter Serial Numbers');
                    component.set('v.SelectBatchSerials',false);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    return;
                }
                
            }
        }
        component.set('v.Container.SPLIS',container);
        if(checkval) component.set('v.hideSave',false);
        else component.set('v.hideSave',true);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    handlelotchange: function(component, event, helper){
        console.log('Inside handlelotchange');
        var LOLId=event.currentTarget.getAttribute('data-index');
        var name=event.currentTarget.name;//event.currentTarget.getAttribute('name');
        console.log('name',name);
        component.set('v.currLOLIForBatch',LOLId);
        var LOLI = component.get("v.Container.SPLIS");
        console.log('currLOLIForBatch : ',component.get('v.currLOLIForBatch'));
        
        for(var i in LOLI){
            if(LOLI[i].sili.ERP7__Logistic_Line_Item__c == component.get('v.currLOLIForBatch')){
                console.log(' LOLI[i].sili.ERP7__Material_Batch_Lot__c: ',LOLI[i].sili.ERP7__Material_Batch_Lot__c);
                if(name==null ||name==''||name==undefined)LOLI[i].sili.ERP7__Material_Batch_Lot__c='' ; 
                console.log('after LOLI[i].sili.ERP7__Material_Batch_Lot__c: ',LOLI[i].sili.ERP7__Material_Batch_Lot__c);
            }
        }
        component.set('v.Container.SPLIS',LOLI);
        var LOLIS = component.get("v.Container.LOLIS");
        var assignbatch;
        for(var i in LOLIS){
            if(LOLIS[i].LOLI != undefined && LOLIS[i].LOLI != null && LOLIS[i].LOLI.Id == component.get('v.currLOLIForBatch')){
                assignbatch=LOLIS[i].assignedBatch;
                console.log('assbatch: ',assignbatch);
            }
        }
    }
})