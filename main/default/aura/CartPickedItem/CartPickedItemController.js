({
    doInit: function (component, event, helper) {
        console.log('doInit v.item.Id~>'+component.get('v.item.Id'));
        console.log('doInit v.item.ERP7__Product__c~>'+component.get('v.item.ERP7__Product__c'));
        if(!$A.util.isEmpty(component.get('v.item.Id')) && !$A.util.isUndefinedOrNull(component.get('v.item.Id'))){
            
            component.set("v.proceedChangeHandler",false);
            var currProd = component.get('v.item.ERP7__Product__c');
            if(currProd == undefined || currProd == null) currProd = '';
            console.log('doInit setting prod null & currProd~>'+currProd);
            component.set('v.item.ERP7__Product__c',null);
            
            component.set("v.proceedChangeHandler",true);
            component.set('v.item.ERP7__Product__c',currProd);
            
            component.set("v.disableSave",true);
        }
        component.set("v.pickedQty", component.get("v.item.ERP7__Quantity__c"));
        /*if(component.get("v.item.locfilter") != undefined){
        component.set('v.availLocIds', component.get("v.item.locfilter"));
        component.set('v.prodLocIds', component.get("v.item.locfilter"));
    }
    if(component.get("v.item.batchfilter") != undefined){
        component.set('v.availBatchIds', component.get("v.item.batchfilter"));
    }
    if(component.get("v.item.serialfilter") != undefined){
        component.set('v.availSerialIds', component.get("v.item.serialfilter"));
    }*/
    /*  if(component.get('v.item.ERP7__Product__c')){
        setTimeout(
            $A.getCallback(function() {
                var action = component.get('c.fetchInventory');
                $A.enqueueAction(action);
            }), 2000
        );
    }*/
},
    
    
    fetchInventory: function (component, event, helper) {
        
        try{
            console.log('scannedValueChanged : ',component.get('v.scannedValueChanged'));
            console.log('StopfecthInventory : ',component.get('v.StopfecthInventory'));
            console.log('fromMultipick : ',component.get('v.fromMultipick'));
            if(!component.get('v.StopfecthInventory') && !component.get('v.fromMultipick')){
                if(!component.get('v.scannedValueChanged')){
                    if((component.get('v.item') != undefined && component.get('v.item') != {}) && component.get("v.proceedChangeHandler")){
                        console.log('fetchInventory called');
                        component.set("v.showSpinnerItem",true);
                        
                        component.set("v.proceedChangeHandler",false);
                        
                        //Commented by parveez on 22-jan-24 for preventing recursive execution of the code and setting values.
                        
                        var currProd = component.get('v.item.ERP7__Product__c');
                        var batch = component.get('v.item.ERP7__Batch_Lot__c'); 
                        var fromLocation = component.get('v.item.ERP7__From_Location__c');
                        var serial = component.get('v.item.ERP7__Serial_Number__c');
                        console.log('currProd',currProd);
                        console.log('fromLocation',fromLocation);
                        console.log('batch',batch);
                        console.log('serial',serial);
                        console.log('siteID',component.get("v.siteID"));
                        /*if($A.util.isEmpty(currProd) || $A.util.isUndefinedOrNull(currProd)){
                    currProd = '';
                    batch = '';
                    fromLocation = '';
                    serial = '';
                }else{
                    if($A.util.isEmpty(fromLocation) || $A.util.isUndefinedOrNull(fromLocation)){
                        fromLocation = '';
                    }
                    if($A.util.isEmpty(batch) || $A.util.isUndefinedOrNull(batch)){
                        batch = '';
                    }
                    if($A.util.isEmpty(serial) || $A.util.isUndefinedOrNull(serial)){
                        serial = '';
                    }
                }
                
                console.log('currProd~>'+currProd);
                console.log('fromLocation~>'+fromLocation);
                console.log('batch~>'+batch);
                console.log('serial~>'+serial);
                
                if(currProd == '') {
                    component.set('v.item.ERP7__Available_Stock__c', 0); 
                    component.set('v.item.ERP7__From_Location__c',null);
                    component.set('v.item.ERP7__Batch_Lot__c',null);
                    component.set('v.item.ERP7__Serial_Number__c',null);
                    component.set("v.showSpinnerItem",false); 
                    component.set("v.proceedChangeHandler",true); 
                    return; 
                }*/
                    
                    /*if(batch =='' || fromLocation == '' ||serial=='' ){
                component.set('v.item.ERP7__Available_Stock__c',0);
                component.set('v.item.ERP7__Quantity__c',0);
                }*/
                    
                    var action = component.get("c.fetchProductSiteInvStock");
                    action.setParams({
                        currProdId: currProd,
                        site: component.get("v.siteID"),
                        fromLocation: fromLocation,
                        batch: batch,
                        serial: serial
                    });
                    //console.log('before fetchInventory setCallBack',component.get("v.item"));
                    action.setCallback(this, $A.getCallback(function(response) {//function (response) 
                        console.log('After fetchInventory setCallBack');
                        if (response.getState() == "SUCCESS") {
                            component.set("v.showSpinnerItem",true);
                            console.log('fetchInventory success');
                            console.log('arshad fetchInventory response.getReturnValue() : ',response.getReturnValue());
                            component.set('v.item.ERP7__Available_Stock__c', response.getReturnValue().totalQuantity);
                            component.set('v.item.ERP7__Product__r.ERP7__Serialise__c', response.getReturnValue().isSerial);
                            component.set('v.item.ERP7__Product__r.ERP7__Lot_Tracked__c', response.getReturnValue().isBatch);
                            component.set('v.item.ERP7__Inventory_Stock__c', response.getReturnValue().inventory);
                            var batch = response.getReturnValue().batchId;
                            if(response.getReturnValue().isBatch && response.getReturnValue().isSerial && component.get('v.item.ERP7__Serial_Number__c') != null && component.get('v.item.ERP7__Serial_Number__c') != '' && component.get('v.item.ERP7__Serial_Number__c') != undefined){
                                if(component.get('v.item.ERP7__Batch_Lot__c') == null || component.get('v.item.ERP7__Batch_Lot__c') == '' || component.get('v.item.ERP7__Batch_Lot__c') == undefined) component.set('v.item.ERP7__Batch_Lot__c',batch);
                            }
                            if (response.getReturnValue().isSerial && response.getReturnValue().totalQuantity > 0) {
                                component.set('v.item.ERP7__Available_Stock__c', 1);
                                component.set('v.item.ERP7__Quantity__c',response.getReturnValue().totalQuantity);
                            }
                            
                            
                            
                            
                            var availLocIdsfilter = '';
                            var availLocIds = [];
                            availLocIds = response.getReturnValue().availLocIds;
                            console.log('praveez Location Id length',availLocIds.length);
                            component.set("v.showSpinnerItem",true);
                            if(availLocIds.length > 0){
                                for(var obj in availLocIds){
                                    if(obj == 0) availLocIdsfilter = ' And ( Id = \''+availLocIds[obj]+'\' ';
                                    else availLocIdsfilter += ' Or Id = \''+availLocIds[obj]+'\' ';
                                }
                                
                                availLocIdsfilter += ') ';
                            } else availLocIdsfilter = ' AND Id = null ';
                            //availLocIdsfilter += ' AND ERP7__Site__c =\''+component.get("v.siteID")+'\' '; 
                            component.set("v.showSpinnerItem",false);
                            console.log('praveez Location Filter:',availLocIdsfilter);
                            
                            var availBatchIdsfilter = '';
                            var availBatchIds = [];
                            availBatchIds = response.getReturnValue().availBatchIds;
                            if(availBatchIds.length > 0){
                                for(var obj in availBatchIds){
                                    if(obj == 0) availBatchIdsfilter = ' And ( Id = \''+availBatchIds[obj]+'\' ';
                                    else availBatchIdsfilter += ' Or Id = \''+availBatchIds[obj]+'\' ';
                                }
                                availBatchIdsfilter += ') ';
                            } else availBatchIdsfilter = ' AND Id = null ';
                            //availBatchIdsfilter += ' And ERP7__Expired__c=false And ERP7__Available_Quantity__c > 0 And ERP7__Product__c = \''+component.get("v.item.ERP7__Product__c")+'\' ';
                            
                            var availSerialIdsfilter = '';
                            var availSerialIds = [];
                            availSerialIds = response.getReturnValue().availSerialIds;
                            console.log('arshad availSerialIds list ~>'+availSerialIds);
                            if(availSerialIds.length > 0){
                                for(var obj in availSerialIds){
                                    if(obj == 0) availSerialIdsfilter = ' And ( Id = \''+availSerialIds[obj]+'\' ';
                                    else availSerialIdsfilter += ' Or Id = \''+availSerialIds[obj]+'\' ';
                                }
                                availSerialIdsfilter += ') ';
                            } else availSerialIdsfilter = ' AND Id = null ';
                            //availSerialIdsfilter += ' And ERP7__Expired__c=false And ERP7__Product__c = \''+component.get("v.item.ERP7__Product__c")+'\' AND ERP7__Available__c = true ';
                            
                            console.log('arshad availLocIdsfilter~>'+availLocIdsfilter);
                            console.log('arshad availBatchIdsfilter~>'+availBatchIdsfilter);
                            console.log('arshad availSerialIdsfilter~>'+availSerialIdsfilter);
                            if(component.get('v.availLocIds') == '' || component.get('v.availLocIds') == null || component.get('v.availLocIds') == undefined) component.set('v.prodLocIds', availLocIdsfilter);
                            else component.set('v.prodLocIds', component.get('v.availLocIds'));
                            component.set('v.availLocIds', availLocIdsfilter);
                            
                            component.set('v.availBatchIds', availBatchIdsfilter);
                            component.set('v.availSerialIds', availSerialIdsfilter);
                            if(component.get("v.fromScanFlowforMultiPick")) component.set("v.callChangeLocation",component.get("v.item.ERP7__From_Location__c")); //
                            component.set("v.showSpinnerItem",false);
                            component.set("v.proceedChangeHandler",true); 
                        }else {
                            console.log('Error fetchInventory:', response.getError());
                            component.set("v.showSpinnerItem",false);
                            component.set("v.proceedChangeHandler",true); 
                        }
                    }));
                    component.set("v.showSpinnerItem",false);
                    $A.enqueueAction(action);
                }
            }
        }
        
        //console.log('item :',component.get('v.item'));
        
    }catch(err){
        console.log('err occured fetchInventory~>'+err.message);
        component.set("v.showSpinnerItem",false);
        component.set("v.proceedChangeHandler",true); 
    }
},
    
    deleteSlctd: function (component, event, helper) {
        console.log('deleting index-->',event.target.dataset.record);
        component.set("v.delindex", event.target.dataset.record);
    },
    
    onChangeCartPickedItem: function (component, event, helper) {
        component.set("v.disableSave",false);
        component.set("v.AllowNew", false);
    },
    
    onCommitCartPickedItem: function (component, event, helper) {
        if($A.util.isEmpty(component.get('v.item.ERP7__Quantity__c')) || $A.util.isUndefinedOrNull(component.get('v.item.ERP7__Quantity__c')) || component.get('v.item.ERP7__Quantity__c') <= 0){
            helper.warningToast(component, event, $A.get('$Label.c.PH_Please_Enter_Quantity'));
            component.set("v.item.ERP7__Quantity__c", 0);
            component.set("v.disableSave",false);
            component.set("v.showSpinnerItem",false);
            return;
        }
        
        if(component.get("v.item.ERP7__Quantity__c") > component.get("v.item.ERP7__Available_Stock__c")) {
            helper.warningToast(component, event, $A.get('$Label.c.Can_not_select_more_that_available_stock'));
            component.set("v.item.ERP7__Quantity__c", 0);
            component.set("v.disableSave",false);
            component.set("v.showSpinnerItem",false);
            return;
        }
        
        if (component.get("v.item.ERP7__Product__r.ERP7__Serialise__c")) {
            if (component.get("v.item.ERP7__Serial_Number__c") == '' || component.get("v.item.ERP7__Serial_Number__c") == undefined) {
                helper.warningToast(component, event, $A.get('$Label.c.Please_enter_serial_number_for_the_product'));
                component.set("v.item.ERP7__Quantity__c", 0);
                component.set("v.disableSave",false);
                component.set("v.showSpinnerItem",false);
                return;
            }
        }
        
        if (component.get("v.item.ERP7__Quantity__c") > 1 && component.get("v.item.ERP7__Product__r.ERP7__Serialise__c")) {
            helper.warningToast(component, event, $A.get('$Label.c.Can_not_select_more_that_available_stock'));
            component.set("v.item.ERP7__Quantity__c", 0);
            component.set("v.disableSave",false);
            component.set("v.showSpinnerItem",false);
            return;
        }
        
        component.set("v.showSpinnerItem",false);
        component.set("v.disableSave",false);
    },
    
    updateCartPickedItem: function (component, event, helper) {
        try{
            console.log('updateCartPickedItem called');
            component.set("v.disableSave",true);
            component.set("v.showSpinnerItem",true);
            console.log('v.item.ERP7__Quantity__c~>'+component.get("v.item.ERP7__Quantity__c"));
            console.log('v.item.ERP7__Available_Stock__c~>'+component.get("v.item.ERP7__Available_Stock__c"));
            console.log('v.pickedQty>'+component.get("v.pickedQty"));
            
            if($A.util.isEmpty(component.get('v.item.ERP7__Quantity__c')) || $A.util.isUndefinedOrNull(component.get('v.item.ERP7__Quantity__c')) || component.get('v.item.ERP7__Quantity__c') <= 0){
                helper.warningToast(component, event, $A.get('$Label.c.PH_Please_Enter_Quantity'));
                component.set("v.item.ERP7__Quantity__c", 0);
                component.set("v.disableSave",false);
                component.set("v.showSpinnerItem",false);
                return;
            }
            
            if (component.get("v.item.ERP7__Quantity__c") > component.get("v.item.ERP7__Available_Stock__c")) {
                console.log('here1');
                helper.warningToast(component, event, $A.get('$Label.c.Can_not_select_more_that_available_stock'));
                component.set("v.disableSave",false);
                component.set("v.showSpinnerItem",false);
                component.set("v.item.ERP7__Quantity__c", 0);
                //component.updateCartPickedItem();
                return;
            }
            
            if (component.get("v.item.ERP7__Product__r.ERP7__Serialise__c")) {
                if (component.get("v.item.ERP7__Serial_Number__c") == '' || component.get("v.item.ERP7__Serial_Number__c") == undefined) {
                    console.log('here2');
                    helper.warningToast(component, event, $A.get('$Label.c.Please_enter_serial_number_for_the_product'));
                    component.set("v.disableSave",false);
                    component.set("v.showSpinnerItem",false);
                    component.set("v.item.ERP7__Quantity__c", 0);
                    return;
                }
            }
            
            if (component.get("v.item.ERP7__Quantity__c") > 1 && component.get("v.item.ERP7__Product__r.ERP7__Serialise__c")) {
                console.log('here3');
                helper.warningToast(component, event, $A.get('$Label.c.Can_not_select_more_that_available_stock'));
                component.set("v.disableSave",false);
                component.set("v.showSpinnerItem",false);
                component.set("v.item.ERP7__Quantity__c", 0);
                return;
            }
            
            
            if(!$A.util.isUndefinedOrNull(component.get("v.item")) && component.get("v.pickedQty") != component.get("v.item.ERP7__Quantity__c")) {
                console.log('inhere going for action saveCartItem');
                if($A.util.isEmpty(component.get("v.item.ERP7__Cart__c"))){
                    component.set("v.item.ERP7__Cart__c", component.get("v.cartID"));
                }
                console.log('item : ',JSON.stringify(component.get("v.item")));
                var saveaction = component.get("c.saveCartItem");
                saveaction.setParams({
                    "pickeditem": JSON.stringify(component.get("v.item"))
                });
                //JSON.stringify(component.get("v.item"))
                saveaction.setCallback(this, function (res) {
                    if (res.getState() === 'SUCCESS') {
                        console.log('saveCartItem success~>',res.getReturnValue());
                        
                        component.set("v.item.Id", res.getReturnValue().Id);
                        component.set("v.disableSave",true);
                        component.set("v.item.ERP7__Quantity__c", res.getReturnValue().ERP7__Quantity__c);
                        
                        //component.set("v.item",res.getReturnValue());
                        
                        
                        component.set("v.item.ERP7__Available_Stock__c", res.getReturnValue().ERP7__Available_Stock__c);
                        
                        if (res.getReturnValue().ERP7__Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c < 0) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get('$Label.c.warning_UserAvailabilities'),
                                "message": $A.get('$Label.c.Can_not_select_more_that_available_stock')
                            });
                            toastEvent.fire();
                            component.set("v.item.ERP7__Quantity__c", 0);
                        }
                        
                        component.set("v.showSpinnerItem",false);
                        
                        //$A.enqueueAction(component.get("c.fetchInventory"));
                        
                        component.set("v.pickedQty", component.get("v.item.ERP7__Quantity__c"));
                        component.set("v.AllowNew", true);
                    } else {
                        console.log('Error updateCartPickedItem :', res.getError());
                        component.set("v.disableSave",false);
                        component.set("v.showSpinnerItem",false);
                    }
                });
                
                $A.enqueueAction(saveaction);
            }
        }catch(err){
            console.log('err occured updateCartPickedItem~>'+err.message);
            component.set("v.disableSave",false);
            component.set("v.showSpinnerItem",false);
        }
    },
    
    OpenModalSerial : function (cmp, event) {
        cmp.set("v.SearchSerialNos",'');
        cmp.set("v.exceptionError",'');
        console.log('prodLocIds OpenModalSerial : ',cmp.get('v.prodLocIds'));
        if(cmp.get('v.prodLocIds') == '' || cmp.get('v.prodLocIds') == null) cmp.set('v.prodLocIds', ' And Id = null');
        $A.util.addClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
        cmp.set("v.serialModalOpen",true);
        cmp.set("v.storeCompIndex",cmp.get('v.index'));
        cmp.set("v.showSpinnerItem",true);
        cmp.set("v.PickSelectedSerialNos",[]);
        cmp.set("v.PickSerialNos",[]);
        console.log('PickSelectedSerialNos in new',cmp.get("v.PickSelectedSerialNos"));
        
        var prodId = cmp.get('v.item.ERP7__Product__c');
        cmp.set("v.storeProdId",prodId);
        console.log('prodId : ',prodId);
        var site  = cmp.get("v.siteID");
        console.log('site : ',site);
        var loc  = cmp.get("v.item.ERP7__From_Location__c");
        cmp.set('v.Location',loc);
        var reqQty = cmp.get("v.requiredQty");
        console.log('reqQty : ',reqQty);
        var action = cmp.get("c.PreparePickSerialNos");
        action.setParams({
            productId: prodId,
            searchString: "",
            siteID : site,
            locId : loc,
            lmt : reqQty,
            serialIds : []
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                if(response.getReturnValue().error != ''){
                    cmp.set("v.exceptionError", response.getReturnValue().error);
                    cmp.set("v.PickSerialNos",[]);
                    cmp.set("v.showSpinnerItem",false);
                } else{
                    //alert('PickSerialNos : '+response.getReturnValue().PickSerialNos.length);
                    //alert('PickSelectedSerialNos : '+response.getReturnValue().PickSelectedSerialNos.length);
                    console.log('response.getReturnValue().PickSerialNos~>'+JSON.stringify(response.getReturnValue().PickSerialNos));
                    cmp.set("v.PickSerialNos", response.getReturnValue().PickSerialNos);
                    if(cmp.get("v.PickSerialNos").length >0)cmp.set("v.disableAdd",false);
                    cmp.set("v.showSpinnerItem",false);
                }
            }
        });
        $A.enqueueAction(action); 
    },
    ChangeLocation : function (cmp, event) {
        //if((cmp.get("v.callChangeLocation") && cmp.get("v.fromScanFlowforMultiPick")) ||(!cmp.get("v.callChangeLocation") && !cmp.get("v.fromScanFlowforMultiPick"))) {
        cmp.set("v.showSpinnerItem",true);
        console.log('inside changeLocation');
        var prodId = cmp.get('v.storeProdId');
        var site  = cmp.get("v.siteID");
        var loc  = cmp.get("v.item.ERP7__From_Location__c");
        cmp.set('v.Location',loc);
        var reqQty = cmp.get("v.requiredQty");
        //console.log('reqQty : ',reqQty);
        var action = cmp.get("c.PreparePickSerialNos");
        action.setParams({
            productId: prodId,
            searchString: "",
            siteID : site,
            locId : loc,
            lmt : reqQty,
            serialIds : []
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                if(response.getReturnValue().error != ''){
                    cmp.set("v.exceptionError", response.getReturnValue().error);
                    cmp.set("v.PickSerialNos",[]);
                    cmp.set("v.showSpinnerItem",false);
                } else{
                    //alert('PickSerialNos : '+response.getReturnValue().PickSerialNos.length);
                    //alert('PickSelectedSerialNos : '+response.getReturnValue().PickSelectedSerialNos.length);
                    console.log('response.getReturnValue().PickSerialNos~>'+JSON.stringify(response.getReturnValue().PickSerialNos));
                    cmp.set("v.PickSerialNos", response.getReturnValue().PickSerialNos);
                    if(cmp.get("v.PickSerialNos").length >0)cmp.set("v.disableAdd",false);
                    cmp.set("v.showSpinnerItem",false);
                }
            }
        });
        $A.enqueueAction(action);
        //cmp.set("v.callChangeLocation",false);
        // }
    },
    ChangeLocationmanual : function (cmp, event) {
        //if((cmp.get("v.callChangeLocation") && cmp.get("v.fromScanFlowforMultiPick")) ||(!cmp.get("v.callChangeLocation") && !cmp.get("v.fromScanFlowforMultiPick"))) {
        cmp.set("v.showSpinnerItem",true);
        console.log('inside changeLocation');
        var prodId = cmp.get('v.storeProdId');
        var site  = cmp.get("v.siteID");
        var loc  = cmp.get("v.Location");
        cmp.set('v.item.ERP7__From_Location__c',loc);
        var reqQty = cmp.get("v.requiredQty");
        //console.log('reqQty : ',reqQty);
        var action = cmp.get("c.PreparePickSerialNos");
        action.setParams({
            productId: prodId,
            searchString: "",
            siteID : site,
            locId : loc,
            lmt : reqQty,
            serialIds : []
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                if(response.getReturnValue().error != ''){
                    cmp.set("v.exceptionError", response.getReturnValue().error);
                    cmp.set("v.PickSerialNos",[]);
                    cmp.set("v.showSpinnerItem",false);
                } else{
                    //alert('PickSerialNos : '+response.getReturnValue().PickSerialNos.length);
                    //alert('PickSelectedSerialNos : '+response.getReturnValue().PickSelectedSerialNos.length);
                    console.log('response.getReturnValue().PickSerialNos~>'+JSON.stringify(response.getReturnValue().PickSerialNos));
                    cmp.set("v.PickSerialNos", response.getReturnValue().PickSerialNos);
                    if(cmp.get("v.PickSerialNos").length >0)cmp.set("v.disableAdd",false);
                    cmp.set("v.showSpinnerItem",false);
                }
            }
        });
        $A.enqueueAction(action);
        //cmp.set("v.callChangeLocation",false);
        // }
    },
    
    CloseMyModalPickSerial : function (cmp, event) {
        $A.util.removeClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
        cmp.set("v.serialModalOpen",false);
        cmp.set("v.storeProdId",''); 
    },
    
    FindSerials : function (cmp, event) {
        if((cmp.get("v.callFindSerials") && cmp.get("v.fromScanFlowforMultiPick")) ||(!cmp.get("v.callFindSerials") && !cmp.get("v.fromScanFlowforMultiPick"))) {
            cmp.set("v.showSpinnerItem",true);
            cmp.set("v.exceptionError",'');
            cmp.set("v.disableAdd", true);
            console.log('prodLocIds : ',cmp.get('v.prodLocIds'));
            var srchString = cmp.get('v.SearchSerialNos');
            console.log('srchString : ',srchString);
            var prodId = cmp.get('v.item.ERP7__Product__c');
            console.log('prodID'+prodId)
            var site  = cmp.get("v.siteID");
            var loc  = cmp.get("v.Location");
            console.log('loc : ',loc);
            var reqQty = cmp.get("v.requiredQty");
            console.log('reqQty : ',reqQty);
            var selectedSerial = cmp.get("v.PickSelectedSerialNos"); 
            var selectedSerialIDs = [];
            for(var x in selectedSerial){
                if(srchString != '' && srchString != null && srchString != undefined && (srchString == selectedSerial[x].SerialNo.Name || srchString == selectedSerial[x].SerialNo.ERP7__Barcode__c)){
                    cmp.set("v.exceptionError", $A.get('$Label.c.Serial_Numbers_Reserved_Selected'));
                    cmp.set("v.showSpinnerItem",false);
                    return;
                }  
                else selectedSerialIDs.push(selectedSerial[x].SerialNo.Id);
            }
            var action = cmp.get("c.PreparePickSerialNos");
            action.setParams({
                productId: prodId,
                searchString: srchString,
                siteID : site,
                locId : loc,
                lmt : reqQty,
                serialIds : selectedSerialIDs
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    console.log('PreparePickSerialNos res : ',response.getReturnValue());
                    if(response.getReturnValue().error != ''){
                        cmp.set("v.exceptionError", response.getReturnValue().error);
                        cmp.set("v.PickSerialNos", []);
                        cmp.set("v.showSpinnerItem",false);
                    } else{
                        //alert('PickSerialNos : '+response.getReturnValue().PickSerialNos.length);
                        //alert('PickSelectedSerialNos : '+response.getReturnValue().PickSelectedSerialNos.length);
                        cmp.set("v.PickSerialNos", response.getReturnValue().PickSerialNos);
                        var obj = cmp.get("v.PickSerialNos");
                        var selectedCount = 0;
                        for(var x in obj){
                            if(obj[x].isSelected) selectedCount++;
                        }
                        console.log('selectedCount:',selectedCount);
                        cmp.set("v.disableAdd", (selectedCount == 0));
                        cmp.set("v.showSpinnerItem",false);
                    }
                }
            });
            $A.enqueueAction(action); 
            cmp.set("v.callFindSerials",false);
            cmp.set("v.fromScanFlowforMultiPick",false);
        }
    },
    
    PickSerialNosDiv : function (cmp, event) {
        cmp.set("v.showSpinnerItem",true);
        var SId = event.currentTarget.getAttribute('data-serialId');
        var obj = cmp.get("v.PickSerialNos");
        var selectedCount = 0;
        for(var x in obj){
            if(SId == obj[x].SerialNo.Id) obj[x].isSelected = !obj[x].isSelected;
            if(obj[x].isSelected) selectedCount++;
        }
        cmp.set("v.disableAdd", (selectedCount == 0));
        cmp.set("v.PickSerialNos", obj);
        cmp.set("v.showSpinnerItem",false);
    },
    
    AddSerials : function (cmp, event) {
        if((cmp.get("v.callAddSerials") && cmp.get("v.fromScanFlowforMultiPick")) ||(!cmp.get("v.callAddSerials") && !cmp.get("v.fromScanFlowforMultiPick"))) {
            console.log('Inside AddSerials');
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
            cmp.set("v.callAddSerials",false);
            cmp.set("v.fromScanFlowforMultiPick",false);
        }
        //component.set("v.callAddSerials",true);
    },
    
    RemoveSerials: function (cmp, event) {
        if((cmp.get("v.callRemoveAllSerials") && cmp.get("v.fromScanFlowforMultiPick")) ||(!cmp.get("v.callRemoveAllSerials") && !cmp.get("v.fromScanFlowforMultiPick"))) {
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
            cmp.set("v.callRemoveAllSerials",false);
            cmp.set("v.fromScanFlowforMultiPick",false);    
        }
    },
    
    PickSelectedSerialNosDiv: function(cmp, event) {
        cmp.set("v.showSpinnerItem",true);
        var SId = event.currentTarget.getAttribute('data-serialId');
        var obj = cmp.get("v.PickSelectedSerialNos");
        var selectedCount = 0;
        for(var x in obj){
            if(SId == obj[x].SerialNo.Id) obj[x].isSelected = !obj[x].isSelected;
            if(obj[x].isSelected) selectedCount++;
        }
        cmp.set("v.disableRemove", !(selectedCount > 0));
        cmp.set("v.PickSelectedSerialNos", obj);
        cmp.set("v.showSpinnerItem",false);
    },
    
    saveAsDraft : function(cmp, event) {
        try{
            if((cmp.get("v.callsaveAsDraft") && cmp.get("v.fromScanFlowforMultiPick")) ||(!cmp.get("v.callsaveAsDraft") && !cmp.get("v.fromScanFlowforMultiPick"))) {
                cmp.set("v.showSpinnerItem",true);
                var selectedSerials = cmp.get("v.PickSelectedSerialNos");
                var serials = [];
                var cart = cmp.get('v.cartID');
                var prodId = cmp.get('v.item.ERP7__Product__c');
                var site  = cmp.get("v.siteID");
                var loc  = cmp.get("v.Location");
                
                
                if(selectedSerials.length > 0){
                    for(var x in selectedSerials){
                        serials.push(selectedSerials[x].SerialNo.Id);
                    }
                    console.log('serials : ',serials);
                    if(serials.length > 0){
                        var action = cmp.get("c.createInventoryforSerial");
                        action.setParams({
                            productId: prodId,
                            serials: JSON.stringify(serials),
                            siteID : site,
                            locId : loc,
                            cartId : cart
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            
                            if (state === "SUCCESS") {
                                console.log('response : ',response.getReturnValue());
                                if(response.getReturnValue() != null){
                                    var cartItems = response.getReturnValue();
                                    cmp.set("v.fromMultipick", true);
                                    cmp.set("v.CartItemInfo", response.getReturnValue());
                                    $A.util.removeClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
                                    $A.util.removeClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
                                    cmp.set("v.serialModalOpen",false);
                                    cmp.set('v.AllowNew',true);
                                    cmp.set("v.showSpinnerItem",false);
                                }
                                else{
                                    cmp.set("v.showSpinnerItem",false);
                                    console.log('error : ',response.getError());
                                }
                            }
                        });
                        $A.enqueueAction(action); 
                    }
                }
                else{
                    cmp.set("v.exceptionError",$A.get('$Label.c.Please_enter_serial_number_for_the_product')); 
                    cmp.set("v.showSpinnerItem",false);
                }
                cmp.set("v.callsaveAsDraft",false);
                cmp.set("v.fromScanFlowforMultiPick",false);  
            }
            
        }
        catch(e){console.log(e);}
    },
    
    PickMultiSerials : function(cmp, event) {
        try{
            if((cmp.get("v.callPickMultiSerials") && cmp.get("v.fromScanFlowforMultiPick")) ||(!cmp.get("v.callPickMultiSerials") && !cmp.get("v.fromScanFlowforMultiPick"))) {
                cmp.set("v.showSpinnerItem",true);
                var selectedSerials = cmp.get("v.PickSelectedSerialNos");
                console.log('selectedSerials:',JSON.stringify(selectedSerials));
                var serials = [];
                var cart = cmp.get('v.cartID');
                var prodId = cmp.get('v.item.ERP7__Product__c');
                var site  = cmp.get("v.siteID");
                var loc  = cmp.get("v.Location");
                
                console.log('prodId'+prodId);
                console.log('site'+site);
                console.log('loc'+loc);
                
                if(selectedSerials.length > 0){
                    for(var x in selectedSerials){
                        serials.push(selectedSerials[x].SerialNo.Id);
                    }
                    console.log('serials : ',serials);
                    
                    if(serials.length > 0){
                        var action = cmp.get("c.createInventoryforSerial");
                        action.setParams({
                            productId: prodId,
                            serials: JSON.stringify(serials),
                            siteID : site,
                            locId : loc,
                            cartId : cart
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            //alert(state);
                            if (state === "SUCCESS") {
                                console.log('response : ',response.getReturnValue());
                                if(response.getReturnValue() != null){
                                    var cartItems = response.getReturnValue();
                                    cmp.set("v.fromMultipick", true);
                                    cmp.set("v.CartItemInfo", response.getReturnValue());
                                    console.log('cart item info '+ response.getReturnValue())
                                    $A.util.removeClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
                                    $A.util.removeClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
                                    cmp.set("v.serialModalOpen",false);
                                    cmp.set('v.AllowNew',true);
                                    cmp.set('v.Showputaway',true);
                                    cmp.set("v.showSpinnerItem",false);
                                }
                                else{
                                    cmp.set("v.showSpinnerItem",false);
                                    console.log('error : ',response.getError()); 
                                }
                            }
                            else{
                                cmp.set("v.showSpinnerItem",false);
                                console.log('error : ',response.getError()); 
                            }
                        });
                        $A.enqueueAction(action); 
                    }
                }
                else{
                    cmp.set("v.exceptionError",$A.get('$Label.c.Please_enter_serial_number_for_the_product')); 
                    cmp.set("v.showSpinnerItem",false);
                }
                cmp.set("v.callPickMultiSerials",false);
                cmp.set("v.fromScanFlowforMultiPick",false);  
            }   
            
        }
        catch(e){console.log(e);}
        
    },
    
    selectAllSerials : function (cmp,event) {
        var checkedval = event.getSource().get('v.checked');
        cmp.set('v.selectAllSerials', checkedval);
        var obj = cmp.get("v.PickSerialNos");
        var showSerialsCount = cmp.get("v.requiredQty");
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
        if(checkedval) cmp.set("v.disableAdd", false);
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
    
    getselected : function(cmp,event){
        var checkedval = event.getSource().get('v.checked');
        console.log('checkedval : ',checkedval);
        cmp.set('v.selected',checkedval);
        if(checkedval) cmp.set('v.showMultidelete',true);
    },
    
    
    showToast: function(cmp, event, helper) {
        try{
            
            var title = $A.get('$Label.c.warning_UserAvailabilities');
            var message = cmp.get("v.exceptionError");
            var variant = "warning";
            if(message !=''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: title,
                    message: message,
                    type: variant,
                    duration: '300000'
                });
                toastEvent.fire();
            }
            
        }
        catch(e){console.log('exception:',e)} 
    }
    
})