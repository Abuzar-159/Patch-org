({
    focusTOscan: function (component, event, helper) {
        component.set("v.scanValue", '');
        helper.focusTOscan(component, event);
       
    },
    
    doInit: function (component, event, helper) {
        console.log('prodRecordId : ',component.get('v.prodRecordId'));
        if(component.get('v.prodRecordId') != null && component.get('v.prodRecordId') != '' && component.get('v.prodRecordId') != undefined){
            helper.getProductDetails(component,helper);
        }
        helper.FunctionalityControl(component,helper);
    },
    
    destSiteCodeChange: function (component, event, helper) {
        console.log('destSiteCodeChange called');
        var action = component.get("c.searchwarehouse");
        action.setParams({
            "bcode": component.get("v.destSiteCode")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (!$A.util.isEmpty(response.getReturnValue())){
                    component.set("v.site_dest", response.getReturnValue());
                    component.set("v.site_dest.Id", response.getReturnValue().Id);
                }
                else
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.No_Warehouse_Exists_with') + component.get('v.destSiteCode') + $A.get('$Label.c.Barcode_Outbound_logistics'));
            }
        });
        $A.enqueueAction(action);
    },
    
    fromSiteCodeChange: function (component, event, helper) {
        console.log('fromSiteCodeChange called : ',component.get("v.fromSiteCode"));
        console.log('Scanned_val set 1:',component.get("v.Scanned_val"));
        console.log('v.scanCode set 1:',component.get("v.scanCode"));
        helper.showSpinner(component);
        var action = component.get("c.searchwarehouse");
        action.setParams({
            "bcode": component.get("v.fromSiteCode")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('res fromSiteCode searchwarehouse : ',response.getReturnValue());
                if (!$A.util.isEmpty(response.getReturnValue())){
                    component.set("v.site", response.getReturnValue());
                    component.set("v.site.Id", response.getReturnValue().Id);
                }
                else
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.No_Warehouse_Exists_with') + component.get('v.fromSiteCode') + $A.get('$Label.c.Barcode_Outbound_logistics'));
                helper.hideSpinner(component);
            } else {
                console.log('Error :', response.getError());
                helper.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    nextStep: function (component, event, helper) {
        component.set("v.step", 'serialcode');
    },
    
    barcodeChange: function (component, event, helper) {
        console.log('barcodeChange called : step : ',component.get("v.step"));
        var pageUrl = window.location.href;
        if (!$A.util.isEmpty(component.get("v.scanCode")) && pageUrl.includes("ERP7__Stock_Transfer")) {
            if (component.get("v.ShowTab1")) {
                var step = component.get("v.step");
                helper.showSpinner(component);
                if((component.get("v.prevscanCode") != component.get("v.scanCode")) &&  (component.get("v.site.Id") == null || component.get("v.site.Id") == '' || component.get("v.site.Id") == undefined)){
                    component.set("v.fromSiteCode",component.get("v.scanCode"));
                    helper.hideSpinner(component);
                    return;
                }
                else if((component.get("v.prevscanCode") != component.get("v.scanCode")) && (component.get("v.site.Id") != null || component.get("v.site.Id") != '' || component.get("v.site.Id") != undefined) && (component.get("v.cart.Id") == null || component.get("v.cart.Id") == '' || component.get("v.cart.Id") == undefined))
                {
                    console.log('Change Cart called');
                    var siteGet = component.get("v.site.Id");
                    var ScannedCode =  component.get("v.scanCode");
                    var setValue = [];  
                    setValue.push("");  
                    setValue.push(siteGet);  
                    component.set("v.allSites",setValue);
                    if (!$A.util.isEmpty(siteGet)) {
                        
                        var action = component.get("c.getScannedCartDetails");
                        action.setParams({ "siteId": siteGet,
                                          "SacnnedValue" : ScannedCode
                                         });
                        action.setCallback(this, function (response) {
                            if (response.getState() == "SUCCESS") {
                                console.log('success getScannedCartDetails~>',response.getReturnValue());
                                component.set("v.AllowNew", true);
                                console.log('v.cart Change Here');
                                component.set("v.cart", response.getReturnValue());
                                if(!response.getReturnValue()){
                                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error",$A.get('$Label.c.No_Cart_Associated') + component.get('v.scanCode') + $A.get('$Label.c.Barcode_Outbound_logistics')); 
                                }
                                
                                component.set("v.proceedSiteIdChangeHandler",true);
                            }else{
                                console.log('Error PopulateEmployeeCart 1:', response.getError());
                                component.set("v.proceedSiteIdChangeHandler",true);
                            }
                            
                        });
                        if(!$A.util.isUndefined(siteGet) || !$A.util.isEmpty(siteGet)){
                            $A.enqueueAction(action);
                        }else{
                            component.set("v.proceedSiteIdChangeHandler",true);
                        }
                    }
                    else {
                        component.set("v.cart.ERP7__Site__c", '');
                        console.log('v.cart sethere2');
                        component.set("v.cart.Id", '');
                        component.set("v.cart.Name", '');
                        
                        component.set("v.proceedSiteIdChangeHandler",true);
                    }
                    helper.hideSpinner(component);
                    return;
                }
                
                    else if((component.get("v.prevscanCode") != component.get("v.scanCode")) && (component.get("v.site.Id") != null && component.get("v.cart.Id") != null) && component.get("v.scanCode") === 'ADD NEW' )
                    {
                        $A.enqueueAction(component.get("c.AddNew"));
                        helper.hideSpinner(component);
                        return;
                    }
                       
                else
                {
                            //Searching info for sacnned barcode.   
                    if((component.get("v.prevscanCode") != component.get("v.scanCode")) && (component.get("v.site.Id") != null && component.get("v.cart.Id") != null))
                    {
                        if((component.get("v.prevscanCode") != component.get("v.scanCode")) && (step === 'serialcode')){
                                    component.set("v.step", '');
                                    step = '';
                                    component.set("v.AllowNew", true);
                                }
                                
                                var cartInfo = component.get("v.CartItemInfo");
                                console.log('CartItemInfo : ',cartInfo);
                                var newItem = (component.get("v.AllowNew")) ? { 'index': 0, 'cpi': { 'Id': null, 'Name': '', ERP7__Available_Stock__c: 0.00, 'ERP7__Quantity__c': 0.00, 'ERP7__Product__c': '', 'ERP7__From_Location__c': '', 'ERP7__From_Location__r': { 'Id': '', 'Name': '', 'ERP7__Barcode__c': '' }, 'ERP7__Product__r': { 'Id': '', 'Name': '', 'ERP7__Barcode__c': '' }, 'ERP7__Serial_Number__c': '', 'ERP7__Serial_Number__r': { 'Id': '', 'Name': '', 'ERP7__Serial_Number__c': '' }, 'ERP7__Fixed_Asset__c': '', 'ERP7__Fixed_Asset__r': { 'Id': '', 'Name': '' }, 'ERP7__Cart__c': component.get("v.cart.Id") } } : cartInfo[0];
                                console.log('newItem.cpi ~>',JSON.stringify(newItem.cpi));
                                var serialprod = (newItem.cpi.ERP7__Product__r.ERP7__Serialise__c != undefined) ? newItem.cpi.ERP7__Product__r.ERP7__Serialise__c : false;
                                if(serialprod && component.get("v.prevscanCode") != component.get("v.scanCode") && component.get("v.scanCode") == 'PICK'){
                                    component.set("v.openSerialModal",true);
                                    component.set("v.fromScanFlowforMultiPick",true);
                                    return;
                                }
                         if((serialprod && component.get("v.prevscanCode") != component.get("v.scanCode")) &&(component.get("v.serialModalOpen") == true) && (component.get("v.storeProdId") != '' ))
                        {console.log('serialModalOpen : ', component.get("v.serialModalOpen"));
                         console.log('From StockTransfer');
                         component.set("v.fromScanFlowforMultiPick",true);
                         var mybarcode = component.get("v.scanCode");
                         /*var childCmp = component.find("childCmp");
                     var storeCompIndex = component.get("v.storeCompIndex");
                     var childCmpId = 'childCmp_' + storeCompIndex; console.log('childCmpId',childCmpId);
                     var childCmp = component.find(childCmpId);*/
                     if(mybarcode == 'PICK') {  
                         component.set("v.callPickMultiSerials",true);}//childCmp.callPickMultiSerials(); } 
                     else if(mybarcode == 'DRAFT') { component.set("v.callsaveAsDraft",true);}//childCmp.callsaveAsDraft(); }
                         else if(mybarcode == 'REMOVEALL'){component.set("v.callRemoveAllSerials",true);}//childCmp.callRemoveAllSerials();}
                             else{
                                 
                                 var selectedSeriallength = (component.get('v.PickSelectedSerialNos') != undefined) ? component.get('v.PickSelectedSerialNos').length : 0;
                                 console.log('selectedSeriallength frm StockTransfer:',selectedSeriallength);
                                 
                                 var serialNos = component.get('v.PickSerialNos');
                                 var selectedCount = 0;
                                 var serialAvailable = false;
                                 for(var x in serialNos){
                                     if(mybarcode == serialNos[x].SerialNo.ERP7__Barcode__c || mybarcode == serialNos[x].SerialNo.Name){
                                         serialNos[x].isSelected = true;
                                         if(serialNos[x].isSelected) selectedCount++;
                                         serialAvailable = true;
                                     }
                                 }
                                 if(serialAvailable == false){ 
                                     var isLoc=helper.getLocation(component,event);
                                     if(isLoc == false){
                                         component.set('v.SearchSerialNos',mybarcode);
                                         component.set("v.callFindSerials",true);//childCmp.callFindSerials();
                                         var serialNos = component.get('v.PickSerialNos');
                                         console.log('serialNos frm StockTransfer 1: ',serialNos);
                                         if(serialNos.length == 0) { helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", 'Invalid Barcode scanned');}//helper.warningToast(component, event, 'Invalid Barcode scanned');}//component.set('v.exceptionError','Invalid Barcode scanned');       
                                         else component.set("v.callAddSerials",true);//childCmp.callAddSerials(component,event,helper);
                                     }
                                 }
                                 
             
                                 else{
                                     component.set("v.PickSerialNos", serialNos);
                                     console.log('serialNos frm StockTransfer 2: ');
                                     component.set("v.callAddSerials",true);//helper.AddSerials(component,event,helper);
                                 }
                             }
                    }
                        //if(component.get("v.prevscanCode") != component.get("v.scanCode") || $A.util.isUndefined(component.get("v.scanCode"))){
                        if (step != 'serialcode'){
                            var action = component.get("c.searchBarcode");
                            // var cartCPI = (cartInfo != undefined && cartInfo.length == 1) ? cartInfo[0].cpi : (cartInfo.length > 1 ? cartInfo[cartInfo.length - 1].cpi : newItem.cpi);
                            //  console.log('cartCPI : ',JSON.stringify(cartCPI));
                            action.setParams({
                                "bcode": component.get("v.scanCode"),
                                "SiteId": component.get("v.site.Id"),
                                "LocId": newItem.cpi.ERP7__From_Location__c,
                                "step": step,
                                "cartPickedItem": JSON.stringify(newItem.cpi)
                            });
                            action.setCallback(this, function (response){
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    component.set("v.prevscanCode", component.get("v.scanCode"));
                                    component.set("v.scanCode", '');
                                    if (response.getReturnValue() != null) {
                                        
                                        console.log('Barcode obj :~>',response.getReturnValue());
                                        var obj = response.getReturnValue();
                                        if (obj.errMsg == null || obj.errMsg == '' || obj.errMsg == undefined) {
                                            console.log('CartItemInfo set barcodesacnner :~>',JSON.stringify(cartInfo));
                                            console.log('cartInfo.length',cartInfo.length);
                                            //component.set("v.CartItemInfo", obj.PickedItemWrapList);
                                            ///changed here on 06/02/24
                                            var cartlen=cartInfo.length;
                                            
                                            if(cartInfo.length > 1){
                                                console.log('cartInfo.length is > 1');
                                                console.log('CartItemInfo when size >1 bfr:~>',JSON.stringify(cartInfo));
                                                console.log('obj.PickedItemWrapList~>',obj.PickedItemWrapList);
                                                for( var x in cartInfo){
                                                    console.log('for loop index: ',cartInfo[x].index);
                                                    console.log('for loop length: ',cartInfo.length-1);
                                                    if(cartInfo[x].index==cartInfo.length-1){
                                                        console.log('in loop ');
                                                        var pickedResult = obj.PickedItemWrapList[0];
                                                        console.log('1 : ',pickedResult.invdetails);
                                                        cartInfo[x].cpi.ERP7__Available_Stock__c= pickedResult.invdetails.totalQuantity;
                                                        cartInfo[x].cpi.ERP7__Product__c = pickedResult.cpi.ERP7__Product__c;
                                                        cartInfo[x].cpi.ERP7__Product__r.ERP7__Serialise__c = pickedResult.invdetails.isSerial; 
                                                        cartInfo[x].cpi.ERP7__Product__r.ERP7__Lot_Tracked__c = pickedResult.invdetails.isBatch; 
                                                        cartInfo[x].cpi.ERP7__Inventory_Stock__c = pickedResult.invdetails.inventory;
                                                        if(pickedResult.cpi.ERP7__Batch_Lot__c != undefined && pickedResult.cpi.ERP7__Batch_Lot__c != null) cartInfo[x].cpi.ERP7__Batch_Lot__c = pickedResult.cpi.ERP7__Batch_Lot__c;
                                                        if(pickedResult.cpi.ERP7__Serial_Number__c != undefined && pickedResult.cpi.ERP7__Serial_Number__c != null) cartInfo[x].cpi.ERP7__Serial_Number__c = pickedResult.cpi.ERP7__Serial_Number__c;
                                                        if(pickedResult.cpi.ERP7__From_Location__c != undefined && pickedResult.cpi.ERP7__From_Location__c != null) cartInfo[x].cpi.ERP7__From_Location__c = pickedResult.cpi.ERP7__From_Location__c;
                                                        
                                                        console.log('2 : ');
                                                        var availLocIdsfilter = '';
                                                        var availLocIds = [];
                                                        availLocIds = pickedResult.invdetails.availLocIds; 
                                                        console.log('3 ');
                                                        if(availLocIds.length > 0){
                                                            for(var obj in availLocIds){
                                                                if(obj == 0) availLocIdsfilter = ' And ( Id = \''+availLocIds[obj]+'\' ';
                                                                else availLocIdsfilter += ' Or Id = \''+availLocIds[obj]+'\' ';
                                                            }
                                                            availLocIdsfilter += ') ';
                                                        } else availLocIdsfilter = ' AND Id = null ';
                                                        cartInfo[x].locfilter = availLocIdsfilter;
                                                        console.log('4 ');
                                                        var availBatchIdsfilter = '';
                                                        var availBatchIds = [];
                                                        availBatchIds = pickedResult.invdetails.availBatchIds;
                                                        if(availBatchIds.length > 0){
                                                            for(var obj in availBatchIds){
                                                                if(obj == 0) availBatchIdsfilter = ' And ( Id = \''+availBatchIds[obj]+'\' ';
                                                                else availBatchIdsfilter += ' Or Id = \''+availBatchIds[obj]+'\' ';
                                                            }
                                                            availBatchIdsfilter += ') ';
                                                        } else availBatchIdsfilter = ' AND Id = null ';
                                                        cartInfo[x].batchfilter = availBatchIdsfilter;
                                                        var availSerialIdsfilter = '';
                                                        var availSerialIds = [];
                                                        availSerialIds = pickedResult.invdetails.availSerialIds;
                                                        console.log('arshad availSerialIds list ~>'+availSerialIds);
                                                        if(availSerialIds.length > 0){
                                                            for(var obj in availSerialIds){
                                                                if(obj == 0) availSerialIdsfilter = ' And ( Id = \''+availSerialIds[obj]+'\' ';
                                                                else availSerialIdsfilter += ' Or Id = \''+availSerialIds[obj]+'\' ';
                                                            }
                                                            availSerialIdsfilter += ') ';
                                                        } else availSerialIdsfilter = ' AND Id = null ';
                                                        cartInfo[x].serialfilter = availSerialIdsfilter;
                                                    }
                                                }
                                                //cartInfo.add(obj.PickedItemWrapList[0]);
                                                console.log('CartItemInfo when size >1 aftr:~>',JSON.stringify(cartInfo));
                                            }else if(cartInfo.length == 1){
                                                console.log('cartInfo.length is 1');
                                                var pickedResult = obj.PickedItemWrapList[0];
                                                cartInfo[0].cpi.ERP7__Product__c=pickedResult.cpi.ERP7__Product__c;
                                                console.log('1 : ',pickedResult);
                                                cartInfo[0].cpi.ERP7__Available_Stock__c= pickedResult.invdetails.totalQuantity;
                                                console.log('2');
                                                cartInfo[0].cpi.ERP7__Product__r.ERP7__Serialise__c = pickedResult.invdetails.isSerial; 
                                                cartInfo[0].cpi.ERP7__Product__r.ERP7__Lot_Tracked__c = pickedResult.invdetails.isBatch; 
                                                cartInfo[0].cpi.ERP7__Inventory_Stock__c = pickedResult.invdetails.inventory;
                                                if(pickedResult.cpi.ERP7__Batch_Lot__c != undefined && pickedResult.cpi.ERP7__Batch_Lot__c != null) cartInfo[0].cpi.ERP7__Batch_Lot__c = pickedResult.cpi.ERP7__Batch_Lot__c;
                                                if(pickedResult.cpi.ERP7__Serial_Number__c != undefined && pickedResult.cpi.ERP7__Serial_Number__c != null) cartInfo[0].cpi.ERP7__Serial_Number__c = pickedResult.cpi.ERP7__Serial_Number__c;
                                                if(pickedResult.cpi.ERP7__From_Location__c != undefined && pickedResult.cpi.ERP7__From_Location__c != null) cartInfo[0].cpi.ERP7__From_Location__c = pickedResult.cpi.ERP7__From_Location__c;
                                                
                                                var availLocIdsfilter = '';
                                                var availLocIds = [];
                                                availLocIds = pickedResult.invdetails.availLocIds; 
                                                console.log('availLocIds.length : ',availLocIds.length);
                                                if(availLocIds.length > 0){
                                                    for(var obj in availLocIds){
                                                        if(obj == 0) availLocIdsfilter = ' And ( Id = \''+availLocIds[obj]+'\' ';
                                                        else availLocIdsfilter += ' Or Id = \''+availLocIds[obj]+'\' ';
                                                    }
                                                    availLocIdsfilter += ') ';
                                                } else availLocIdsfilter = ' AND Id = null ';
                                                cartInfo[0].locfilter = availLocIdsfilter;
                                                var availBatchIdsfilter = '';
                                                var availBatchIds = [];
                                                availBatchIds = pickedResult.invdetails.availBatchIds;
                                                console.log('availBatchIds.length : ',availBatchIds.length);
                                                if(availBatchIds.length > 0){
                                                    for(var obj in availBatchIds){
                                                        if(obj == 0) availBatchIdsfilter = ' And ( Id = \''+availBatchIds[obj]+'\' ';
                                                        else availBatchIdsfilter += ' Or Id = \''+availBatchIds[obj]+'\' ';
                                                    }
                                                    availBatchIdsfilter += ') ';
                                                } else availBatchIdsfilter = ' AND Id = null ';
                                                cartInfo[0].batchfilter = availBatchIdsfilter;
                                                var availSerialIdsfilter = '';
                                                var availSerialIds = [];
                                                availSerialIds = pickedResult.invdetails.availSerialIds;
                                                console.log('arshad availSerialIds list ~>'+availSerialIds);
                                                if(availSerialIds.length > 0){
                                                    for(var obj in availSerialIds){
                                                        if(obj == 0) availSerialIdsfilter = ' And ( Id = \''+availSerialIds[obj]+'\' ';
                                                        else availSerialIdsfilter += ' Or Id = \''+availSerialIds[obj]+'\' ';
                                                    }
                                                    availSerialIdsfilter += ') ';
                                                } else availSerialIdsfilter = ' AND Id = null ';
                                                cartInfo[0].serialfilter = availSerialIdsfilter;
                                                console.log('CartItemInfo when size =1 :~>',JSON.stringify(cartInfo));
                                            }   
                                            ///
                                            component.set("v.scannedValueChanged",true);
                                            component.set("v.CartItemInfo",cartInfo);
                                            helper.hideSpinner(component);
                                            console.log('CartItemInfo After set :~>',component.get("v.CartItemInfo"));
                                            
                                        } else {
                                            helper.hideSpinner(component);
                                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", obj.errMsg);
                                        }
                                        
                                    }
                                    else{
                                        console.log('ERRor : ',response.getError());
                                        helper.hideSpinner(component);
                                    }
                                }
                            });
                            $A.enqueueAction(action);
                            component.set("v.scannedValueChanged",false);
                            //  if (!$A.util.isEmpty(component.get("v.scanCode")))
                            //  $A.enqueueAction(action);
                        } 
                        else {
                            helper.hideSpinner(component);
                            if ($A.util.isUndefined(newItem.cpi.ERP7__Serial_Number__c))
                                if (newItem.cpi.ERP7__Batch_Lot__r.Name === component.get("v.scanCode").trim()) {
                                    newItem.cpi.ERP7__Quantity__c += 1.00;
                                    component.set("v.scanCode", '');
                                }
                            if ((component.get("v.AllowNew"))) {
                                cartInfo.unshift(newItem);
                                component.set("v.AllowNew", false);
                            } else
                                cartInfo[0] = newItem;
                            console.log('CartItemInfo sethere3~>',cartInfo);
                            component.set("v.CartItemInfo", cartInfo);
                        }
                         
                     }
                    
                    else if((component.get("v.prevscanCode") == component.get("v.scanCode")) && (component.get("v.site.Id") != null && component.get("v.cart.Id") != null))
                    {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        if(toastEvent != undefined){
                            toastEvent.setParams({
                                "mode":"dismissible",
                                "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                                "type": Error,
                                "message": $A.get('$Label.c.Same_Code_Scanned')
                            });
                            toastEvent.fire();
                        }
                        
                    }
                }
                
            }
            else {
                helper.processPutaway(component, event);
            }
            
        }
    },
    
    onclickTab1: function (component, event, helper) {
        console.log('onclickTab1');
        component.set("v.ShowTab2", false);
        component.set("v.ShowTab1", true);
        component.set("v.ShowTab3", false);
    },
    
    onclickTab2: function (component, event, helper) {
        
        console.log('onclickTab2');
        component.set("v.ShowTab3", false);
        var CartItemInfo = component.get('v.CartItemInfo');
        for (var i in CartItemInfo) {
            
            var cpi = CartItemInfo[i].cpi;
            console.log('cpi : ',cpi);
            if (cpi.ERP7__Quantity__c == 0 || cpi.ERP7__Quantity__c == '') {
                var msg = $A.get('$Label.c.PH_Enter_Quantity_for_Product')+' : ' + cpi.ERP7__Product__r.Name;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", msg);
                return;
            }
            if (cpi.ERP7__Product__r.ERP7__Lot_Tracked__c && cpi.ERP7__Batch_Lot__c == '') {
                var msg = $A.get('$Label.c.Please_select_Batch_for_product') +': ' + cpi.ERP7__Product__r.Name;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", msg);
                return;
            }
            if (cpi.ERP7__Product__r.ERP7__Serialise__c && cpi.ERP7__Serial_Number__c == '') {
                var msg = $A.get('$Label.c.Please_enter_serial_number_for_the_product')+' : '+ cpi.ERP7__Product__r.Name;
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", msg);
                return;
            }
        }
        if (component.get("v.site") == null || component.get("v.site.Id") == null || component.get("v.site.Id") == '' || component.get("v.site.Id") == undefined)
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_select_Source_Site'));
        else if (component.get("v.cart.Id") == null || component.get("v.cart.Id") == undefined)
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_select_The_Cart'));
            else if (component.get("v.ShowTab1") && component.get("v.CartItemInfo").length === 0)
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.No_Items_in_Cart'));
                else {
                    console.log('AllowNew : ',component.get("v.AllowNew"));
                    if (component.get("v.AllowNew")) {
                        helper.buildPutawayItems(component, event);
                    } else
                        helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_Complete_The_Activity'));
                }
        
        
    },
    
    onclickTab3 : function (component, event, helper) {
        component.set("v.ShowTab2", false);
        component.set("v.ShowTab1", false);
        component.set("v.ShowTab3", true);
        
    },
    
    Cancel: function (component, event, helper) {
        location.reload();
    },
    
    AddNew: function (component, event, helper) {
        if ((component.get("v.cart.Id") == null || component.get("v.cart.Id") == '' || component.get("v.cart.Id") == undefined) && (component.get("v.site") == null || component.get("v.site.Id") == null || component.get("v.site.Id") == '' || component.get("v.site.Id") == undefined))
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_select_Source_Site'));
        else if (component.get("v.cart.Id") == null || component.get("v.cart.Id") == '' || component.get("v.cart.Id") == undefined)
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_select_The_Cart'));
            else {
                component.set("v.AllowNew", false);
                let add = component.get("v.CartItemInfo");
                let len = add.length;
                let obj = { 'selected':false,'index': len, 'cpi': { 'Id': null, 'Name': '', ERP7__Available_Stock__c: 0.00, 'ERP7__Quantity__c': 0.00, 'ERP7__Product__c': '', 'ERP7__From_Location__c': '', 'ERP7__From_Location__r': { 'Id': '', 'Name': '', 'ERP7__Barcode__c': '' }, 'ERP7__Product__r': { 'Id': '', 'Name': '', 'ERP7__Barcode__c': '' }, 'ERP7__Serial_Number__c': '', 'ERP7__Serial_Number__r': { 'Id': '', 'Name': '', 'ERP7__Serial_Number__c': '' }, 'ERP7__Fixed_Asset__c': '', 'ERP7__Fixed_Asset__r': { 'Id': '', 'Name': '' }, 'ERP7__Cart__c': component.get("v.cart.Id") } };
                add.unshift(obj);
                component.set("v.CartItemInfo", add);
                component.set("v.fromMultipick", false);
                component.set("v.fromCartItems", false);
                console.log('CartItemInfo sethere3~>',add);
                /*
                if (component.get("v.AllowNew")) {
                    component.set("v.AllowNew", false);
                    let add = component.get("v.CartItemInfo");
                    let len = add.length;
                    let obj = { 'index': len, 'cpi': { 'Id': null, 'Name': '', ERP7__Available_Stock__c: 0.00, 'ERP7__Quantity__c': 0.00, 'ERP7__Product__c': '', 'ERP7__From_Location__c': '', 'ERP7__From_Location__r': { 'Id': '', 'Name': '', 'ERP7__Barcode__c': '' }, 'ERP7__Product__r': { 'Id': '', 'Name': '', 'ERP7__Barcode__c': '' }, 'ERP7__Serial_Number__c': '', 'ERP7__Serial_Number__r': { 'Id': '', 'Name': '', 'ERP7__Serial_Number__c': '' }, 'ERP7__Fixed_Asset__c': '', 'ERP7__Fixed_Asset__r': { 'Id': '', 'Name': '' }, 'ERP7__Cart__c': component.get("v.cart.Id") } };
                    add.unshift(obj);
                    component.set("v.CartItemInfo", add);
                } else {
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_Complete_The_Activity'));
                }
                */
            }
    },
    
    getItemList: function (component, event, helper) {
        helper.getPickedItems(component, event);
    },
    
    Putaway: function (component, event, helper) {
        if (component.get("v.site_dest.Id") == null || component.get("v.site_dest.Id") == '' || component.get("v.site_dest.Id") == undefined)
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_select_The_Destination_site'));
        else {
            let selectedItems = [];
            let items = component.get("v.PutawayItems");
            
            for (var i in items) {
                var obj = items[i];
                if (obj.isselected) {
                    /*if (obj.ERP7__To_Location__r.Id == '') {
                        var msg = 'Please select location for product : ' + obj.ERP7__Cart_Item__r.ERP7__Product__r.Name;
                        helper.showToast("Warning!", "warning", msg);
                        return;
                    }*/
                    if (obj.ERP7__Putaway_Quantity__c > obj.ERP7__Cart_Item__r.ERP7__Quantity__c) {
                        var msg = obj.ERP7__Cart_Item__r.ERP7__Product__r.Name +': '+ $A.get('$Label.c.Putaway_Quantity_can_not_be_greater_than_Picked_Quantity');
                        helper.showToast($A.get('$Label.c.warning_UserAvailabilities'), "warning", msg);
                        return;
                    }
                    
                    if (obj.ERP7__Putaway_Quantity__c == 0) {
                        var msg = obj.ERP7__Cart_Item__r.ERP7__Product__r.Name + ': '+ $A.get('$Label.c.Putaway_Quantity_Must_be_greater_than_Zero');
                        helper.showToast($A.get('$Label.c.warning_UserAvailabilities'), "warning", msg);
                        return;
                    }
                }
            }
            for (var x in items) {
                var obj = items[x];
                if (obj.isselected) {
                    console.log('obj.Name.length : ',obj.Name.length);
                    if(obj.Name.length > 80){
                        obj.Name = obj.Name.substring(0,79);
                        console.log('obj.Name : ',obj.Name);
                    }
                    obj.ERP7__Site__c = component.get("v.site_dest.Id");
                    delete obj['isselected'];
                    selectedItems.push(obj);
                }
            }
            
            if (selectedItems.length > 0) {
                
                var saveAction = component.get("c.saveCartputawayItem");
                saveAction.setParams({ "items": JSON.stringify(selectedItems), "siteId": component.get("v.site_dest.Id") });
                saveAction.setCallback(this, function (response) {
                    let state = response.getState();
                    if (state === 'SUCCESS') {
                        helper.showToast("", "success", $A.get('$Label.c.Putaway_is_Successfull'));
                        helper.buildPutawayItems(component, event);
                        component.set("v.CartItemInfo",[]);
                        helper.getPickedItems(component, event);
                    } else {
                        for (var i in items) {
                            var obj = items[i];
                            obj.isselected = false;
                        }
                        component.set('v.PutawayItems',items);
                        console.log("Error >>> ", response.getError());
                        var erorr = response.getError();
                        var msg = erorr[0].pageErrors[0].message;
                        if (msg.includes('System.ListException: Duplicate id in list'))
                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', $A.get('$Label.c.Can_not_Putaway_duplicate_items_in_one_Inventory'));
                        if (msg.includes('DUPLICATE_EXTERNAL_ID'))
                            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', $A.get('$Label.c.Can_not_Putaway_duplicate_items_in_one_Inventory'));
                    }
                });
                $A.enqueueAction(saveAction);
            } else {
                helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_Select_Item'));
            }
        }
    },
    
    PopulateEmployeeCart: function (component, event, helper) {
        if(component.get("v.proceedSiteIdChangeHandler")){
            component.set("v.proceedSiteIdChangeHandler",false);
            
            console.log('PopulateEmployeeCart called');
            var siteGet = component.get("v.site.Id");
            var setValue = [];  
            setValue.push("");  
            setValue.push(siteGet);  
            component.set("v.allSites",setValue);
            if (!$A.util.isEmpty(siteGet)) {
                //alert('site change'+siteGet);
                //component.set("v.cart.ERP7__Site__c",siteGet);
                var action = component.get("c.getSiteofCartDetails");
                action.setParams({ "siteId": siteGet });
                action.setCallback(this, function (response) {
                    if (response.getState() == "SUCCESS") {
                        console.log('success getSiteofCartDetails~>',response.getReturnValue());
                        component.set("v.AllowNew", true);
                        console.log('v.cart sethere1');
                        component.set("v.cart", response.getReturnValue());
                        component.set("v.proceedSiteIdChangeHandler",true);
                    }else{
                        console.log('Error PopulateEmployeeCart:', response.getError());
                        component.set("v.proceedSiteIdChangeHandler",true);
                    }
                    
                });
                if(!$A.util.isUndefined(siteGet) || !$A.util.isEmpty(siteGet)){
                    $A.enqueueAction(action);
                }else{
                    component.set("v.proceedSiteIdChangeHandler",true);
                }
            }
            else {
                component.set("v.cart.ERP7__Site__c", '');
                console.log('v.cart sethere2');
                component.set("v.cart.Id", '');
                component.set("v.cart.Name", '');
                //component.set("v.site.Id",'');
                //component.set("v.site.Name",'');
                
                component.set("v.proceedSiteIdChangeHandler",true);
            }
        }
    },
    
    /* deleteSlctd: function (component, event, helper) {
        var record = component.get("v.CartItemInfo");
        console.log('delete index : ',component.get("v.selectedIndex2Delete"));
        var selctedRecwithId = [];
        if (!$A.util.isUndefined(component.get("v.selectedIndex2Delete"))) {
            for (var x = 0; x < record.length; x++) {
                if (record[x].index === parseInt(component.get("v.selectedIndex2Delete"))) {
                    var obj = record[x];
                    if (obj.cpi.Id != null)
                        selctedRecwithId.push(obj.cpi.Id);
                    record.splice(x, 1);
                }
            }
            for (var j = 0; j < record.length; j++)record[j].index = j;
            console.log('CartItemInfo sethere4~>',record);
            component.set("v.CartItemInfo", record);
            //if(record.length ==0)
            component.set("v.AllowNew", true);
            component.set("v.selectedIndex2Delete", undefined);
        }
        if (selctedRecwithId != undefined && selctedRecwithId.length > 0) {
            var delaction = component.get("c.delSlctRec");
            delaction.setParams({
                "slctRec": selctedRecwithId.toString()
            });
            delaction.setCallback(this, function (res) {
                
            });
            $A.enqueueAction(delaction);
        }
        
    },*/
    deleteSlctd: function (component, event, helper) {
        try{
            
            /*console.log('inside the delete:');
            if (component.get("v.deleting")) {
                // Function is already being executed, prevent multiple invocations
                return;
            }
            
            var deleteconfirm = confirm('Do you want to delete item?');
            if (!deleteconfirm) {
                component.set("v.deleting", false);
                return;
            }*/
            
            component.set("v.deleting", true); // Set the flag to indicate deletion process
            component.set("v.showSpinnerItem", true); // Show spinner during deletion
            
            var selectedIndex = component.get("v.selectedIndex2Delete");
            console.log('selectedIndex to Delete :',selectedIndex);
            if ($A.util.isUndefinedOrNull(selectedIndex)) {
                component.set("v.deleting", false); // Reset the flag
                component.set("v.showSpinnerItem", false); // Hide spinner
                return;
            }
            
            var cartItemInfo = component.get("v.CartItemInfo");
            var selectedRecord = cartItemInfo[selectedIndex];
            var selctedRecwithId = [];
            
            if (selectedRecord) {
                if (selectedRecord.cpi && selectedRecord.cpi.Id) {
                    selctedRecwithId.push(selectedRecord.cpi.Id);
                }
                
                cartItemInfo.splice(selectedIndex, 1);
                
                for (var i = 0; i < cartItemInfo.length; i++) {
                    cartItemInfo[i].index = i;
                }
                
                component.set("v.CartItemInfo", cartItemInfo);
                component.set("v.AllowNew", true);
                component.set("v.selectedIndex2Delete", undefined);
            }
            
            
            
            if (selctedRecwithId.length > 0) {
                var delaction = component.get("c.delSlctRec");
                delaction.setParams({
                    "slctRec": selctedRecwithId.join(',')
                });
                delaction.setCallback(this, function (res) {
                    // Handle callback if needed
                });
                $A.enqueueAction(delaction);
            }
            
            setTimeout(function () {
                component.set("v.deleting", false); // Reset the flag after deletion process
                component.set("v.showSpinnerItem", false); // Hide spinner
            }, 1000); // Adjust the timeout value as needed (in milliseconds)
            
            component.set("v.showdeleteModal",false); 
            
        }
        catch(e){console.log(e);}
        
    },
    
    opendeleteModal : function (component, event, helper) {
        if(component.get("v.selectedIndex2Delete") !='')
            component.set("v.showdeleteModal",true); 
    },
    
    closedeleteModal : function (component, event, helper) { 
        component.set("v.showdeleteModal",false); 
        component.set("v.selectedIndex2Delete",'');
    },
    
    
    
    
    cancel: function (component, event, helper) { location.reload(); },
    
    getAllitems : function (component, event, helper) { 
        var start = component.get('v.startdate');
        var end = component.get('v.Enddate');
        var site = component.get('v.site');
        var err =false;
        if (component.get("v.site") == null || component.get("v.site.Id") == null || component.get("v.site.Id") == '' || component.get("v.site.Id") == undefined){
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_select_Source_Site'));
            err =true;
        }
        else if (component.get("v.site_dest.Id") == '' || component.get("v.site_dest.Id") == null || component.get("v.site_dest.Id") == undefined){
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), "error", $A.get('$Label.c.Please_select_The_Destination_site'));
            err =true;
        }
        /*else if($A.util.isUndefinedOrNull(start)){
           helper.showToast("Error!", "error", "Please select The From date");
           err =true; 
        } 
        else if($A.util.isUndefinedOrNull(end)){
           helper.showToast("Error!", "error", "Please select The To date");
           err =true; 
        } */
        
        if(!err && !$A.util.isUndefinedOrNull(start) && !$A.util.isUndefinedOrNull(end)){
            var action = component.get('c.getAll');
            action.setParams({'Site' : component.get("v.site.Id"),
                              'destination' : component.get("v.site_dest.Id"),
                              'fromdate' : start,
                              'To' : end});
            action.setCallback(this, function (res) {
                var state = res.getState();
                if(res.getReturnValue() != null){
                    component.set('v.Allputawayitems',res.getReturnValue());
                }
                else if(res.getReturnValue() == null){
                    var allitems = [];
                    component.set('v.Allputawayitems',allitems);
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    
    showPDF :function (component, event, helper) {
        var allcartitems = component.get('v.Allputawayitems');
        var site = component.get('v.site.Id');
        var des_site = component.get("v.site_dest.Id")
        var allitemsId = '';
        for( var i in allcartitems){
            if(allitemsId == '') allitemsId = allcartitems[i].Id;
            else allitemsId += ','+allcartitems[i].Id;
        }
        var StockTransferDocVfPage = $A.get('$Label.c.StockTransferDocVfPage');
        console.log('StockTransferDocVfPage custom label~>'+StockTransferDocVfPage);
        
        if(allitemsId != ''){
            var RecUrl = "/apex/"+StockTransferDocVfPage+"?cartIds=" +allitemsId+"&SourceSite=" +site+"&DesSite="+des_site;
            window.open(RecUrl,'_blank');
        }
        
    },
    selectAllPutaway : function(cmp,event,helper){
        try{
            var checkedval = event.getSource().get('v.checked');
            console.log('checkedval : ',checkedval);
            cmp.set('v.selectAll',checkedval);
            var Items= cmp.get('v.PutawayItems');
            var globalSelectedLocation = cmp.get("v.globalSelectedLocation");
           
                /*for(var x in Items){
                    Items[x].isselected = checkedval;
                    for(var x in Items){
                        Items[x].selected = checkedval;   
                    }
                }*/
            
            for (var x in Items) {
                Items[x].isselected = checkedval;
                Items[x].selected = checkedval;   
                if (!$A.util.isEmpty(globalSelectedLocation)) {
                    Items[x].ERP7__To_Location__r.Id = checkedval ? globalSelectedLocation : '';
                    Items[x].ERP7__To_Location__c = checkedval ? globalSelectedLocation : '';
                }
                else{
                    Items[x].isselected = checkedval;
                    Items[x].selected = checkedval; 
                } 
                    
            }
            cmp.set('v.PutawayItems',Items);
        }
        catch(e){console.log('Error selectAllPutaway:',e);}
    },
    selectAllPicked : function(cmp,event,helper){
        var checkedval = event.getSource().get('v.checked');
        console.log('checkedval : ',checkedval);
        cmp.set('v.selectAllPick',checkedval);
        var Items= cmp.get('v.CartItemInfo');
        var selectedcount = 0;
        for(var x in Items){
            console.log('Items[x].selected : ',Items[x]);
            Items[x].selected = checkedval;
            if(Items[x].selected ) selectedcount++;
        }
        cmp.set('v.fromCartItems',true);
        cmp.set('v.CartItemInfo',Items);
        cmp.set('v.showMultidelete',(selectedcount > 1));
    },
    deletePickItems: function (cmp, event, helper) {
        var deleteconfirm = confirm($A.get('$Label.c.Do_you_want_to_delete_the_selected_items'));
        if (!deleteconfirm) {
            return;
        }
        cmp.set("v.reRenderLIS",false);
        var cartItemInfo = cmp.get('v.CartItemInfo');
        var selectedItems = [];
        var selectedIds = [];
        console.log('Length of CartItemInfo:',cartItemInfo.length);
        console.log('cartItemInfo bfr:',cartItemInfo);
        for (var i = cartItemInfo.length-1; i >= 0; i--) {
            //for (var i = 0; i<cartItemInfo.length; i++) {
            if (cartItemInfo[i].selected) {
                selectedItems.push(cartItemInfo[i]);
                if (cartItemInfo[i].cpi && cartItemInfo[i].cpi.Id) {
                    selectedIds.push(cartItemInfo[i].cpi.Id);
                }
                cartItemInfo.splice(i, 1);
                //console.log('i:',i);
            }
        }
        console.log('Length of CartItemInfo aftr:',cartItemInfo.length);
        if (selectedItems.length === 0) {
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', $A.get('$Label.c.Select_items_to_delete'));
            return;
        }
        //console.log('cartItemInfo aftr:',cartItemInfo);
        cmp.set('v.showSpinnerItem', true);
        
        //cmp.set('v.CartItemInfo', cartItemInfo);
        
        console.log('cartItemInfo.length:',cartItemInfo.length);
        //console.log('cartItemInfo[0].selected:',cartItemInfo[0].selected);
        console.log('cartItemInfo aftr:',cartItemInfo);
        //cmp.set('v.CartItemInfo', cartItemInfo);
        console.log('DeleteItemsList:',JSON.stringify(selectedIds));
        
        if (selectedIds.length > 0) {
            var delAction = cmp.get('c.delSlctRec');
            delAction.setParams({
                'slctRec': selectedIds.join(',')
            });
            
            delAction.setCallback(this, function (res) {
                var state = res.getState();
                if (state === 'SUCCESS') {
                    cmp.set('v.AllowNew', true);
                    helper.getLOcount(cmp,event);
                } else {
                    helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'), 'error', $A.get('$Label.c.Error_deleting_items'));
                }
                
                cmp.set('v.showSpinnerItem', false);
                cmp.set("v.reRenderLIS",true);
                helper.getLOcount(cmp,event);
            });
            
            $A.enqueueAction(delAction);
        } else {
            cmp.set('v.AllowNew', true);
            cmp.set('v.showSpinnerItem', false);
            cmp.set("v.reRenderLIS",true);
            helper.getLOcount(cmp,event);
        }
    }
     
})