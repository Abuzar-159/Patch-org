({
    focusTOscan: function (component, event) {
        console.log('focusTOscan helper called');
       

        $(document).ready(function () {
            console.log('inhere document');
            component.set("v.scanValue", '');
            var barcode = "";
            var pressed = false;
            var chars = [];
            var lastKeypressTime = 0;
            $(window).keypress(function (e) {
                console.log('keypressed inhere');
              
                    if(component.get("v.serialModalOpen") == false){
                        $(".scanMN").keypress(function (e) {
                            e.stopPropagation()
                        });
                    }
                    
                    chars.push(String.fromCharCode(e.which));
                    if (pressed == false) {
                        console.log('inhere pressed false');
                        setTimeout(
                            function () {
                                pressed = false;
                                if (chars.length >= 3) {
                                    var barcode = chars.join("");
                                    console.log('barcode bfr:',barcode);
                                    barcode = barcode.trim();
                                    chars = [];
                                    pressed = false;
                                    component.set("v.scanCode", barcode.trim());
                                    console.log('v.scanCode set',component.get("v.scanCode"));
                                }
                                /*if(chars.length < 3){
                                    this.showToast($A.get('$Label.c.warning_UserAvailabilities'),'warning',$A.get('$Label.c.The_scanned_barcode_length_should_be_greater_than_2'));
                                }*/
                                chars = [];
                                pressed = false;
                            }, 1000);
                    }
                    pressed = true;
                    //});
                    
            }); // end of window key press function         
            
            $(window).keydown(function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                }
            });
        });
    },
    
    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }
    },
    
    hideSpinner : function (component, event) {
        console.log('inside Hide Spin::');
        var spinner = component.find('spinner');
        //$A.util.addClass(spinner, "slds-hide");
        component.set("v.showSpinner",false);
    },
    
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event) {
        var spinner = component.find('spinner');
        //$A.util.removeClass(spinner, "slds-hide");   
        component.set("v.showSpinner",true);
    },
    
    getPickedItems : function(component,event){
        if(component.get("v.proceedCartIdChangeHandler")){
            component.set("v.proceedCartIdChangeHandler",false);
            if(component.get("v.cart.Id") != undefined && component.get("v.cart.Id") != ""){
                console.log('getPickedItems called');
                var action = component.get("c.fetchCartPickedDetails");
                action.setParams({
                    "cartId":component.get("v.cart.Id")
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        component.set("v.AllowNew",true);
                        if(response.getReturnValue().length > 0){
                            component.set("v.fromCartItems",true);
                            console.log('CartItemInfo sethere1~>',response.getReturnValue());
                            component.set("v.CartItemInfo",response.getReturnValue());
                            //var siteGet = component.get("v.site.Id");
                            //alert('siteGet  '+siteGet);
                            //component.set("v.site.Id",siteGet);
                        }else{
                            console.log('emptycartid3'); 
                            component.set("v.CartItemInfo",[]); 
                        }
                        component.set("v.proceedCartIdChangeHandler",true); 
                    }else{
                        console.log('Error getPickedItems:', response.getError());
                        component.set("v.proceedCartIdChangeHandler",true); 
                    }
                });
                if(!($A.util.isEmpty(component.get("v.cart.Id"))) || !($A.util.isUndefined(component.get("v.cart.Id")))){
                    $A.enqueueAction(action);
                }
                else{ 
                    console.log('emptycartid2'); 
                    component.set("v.CartItemInfo",[]); 
                    component.set("v.proceedCartIdChangeHandler",true); 
                }
            }
            else{
                console.log('emptycartid1'); 
                component.set("v.CartItemInfo",[]); 
                component.set("v.proceedCartIdChangeHandler",true); 
            }
        }
    },
    
    buildPutawayItems: function(component, event) {
        let action = component.get("c.createCartputawayItem");
        action.setParams({
            "cartId":component.get("v.cart.Id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let objlist = response.getReturnValue();
                for(var i=0;i<objlist.length;i++){
                    objlist[i].ERP7__To_Location__r = {Id:'',Name:''};
                    objlist[i].ERP7__Site__c='';
                    objlist[i].isselected = false; 
                }
                component.set("v.PutawayItems",objlist);
                component.set("v.ShowTab1", false);
                component.set("v.ShowTab2", true);
                component.set("v.selectAll", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    processPutaway : function(component, event){
        try
        {
            
            
            console.log('processPutaway called : ',component.get("v.site_dest.Id"));
            if (component.get("v.site_dest.Id") == null || component.get("v.site_dest.Id") == '' || component.get("v.site_dest.Id") == undefined){
                console.log('in set dest code');
                component.set("v.destSiteCode",component.get("v.scanCode"));
                console.log('destSiteCode : ',component.get("v.destSiteCode"));
                return; 
            }
            
            
            let objlist = component.get("v.PutawayItems");
            console.log('objlist : ',JSON.stringify(objlist));
            let newobjlist = [];
            var itemFound = false;
            var scanLocation = false;
            
            for(var i=0; i < objlist.length; i++){
                //var obj = objlist[i];
                console.log('obj : ',JSON.stringify(objlist[i]));
                console.log('component.get("v.scanCode") : ',component.get("v.scanCode"));
                if((!objlist[i].isselected)){
                    if((objlist[i].ERP7__Cart_Item__r.ERP7__Product__r.Name === component.get("v.scanCode"))){
                        console.log('matched');
                        component.set("v.scanCode",'');
                        itemFound = true; 
                        objlist[i].isselected = true;
                        // $(window).trigger('keypress'); 
                        break; 
                    }
                    else if(objlist[i].ERP7__Cart_Item__r.ERP7__Batch_Lot__c != null && objlist[i].ERP7__Cart_Item__r.ERP7__Batch_Lot__c != undefined &&  objlist[i].ERP7__Cart_Item__r.ERP7__Batch_Lot__c != '' && objlist[i].ERP7__Cart_Item__r.ERP7__Batch_Lot__r.Name == component.get("v.scanCode")){
                        console.log('matched');
                        component.set("v.scanCode",'');
                        itemFound = true; 
                        objlist[i].isselected = true;
                        // $(window).trigger('keypress'); 
                        break; 
                    }
                        else if(objlist[i].ERP7__Cart_Item__r.ERP7__Serial_Number__c != null && objlist[i].ERP7__Cart_Item__r.ERP7__Serial_Number__c != undefined &&  objlist[i].ERP7__Cart_Item__r.ERP7__Serial_Number__c != '' && objlist[i].ERP7__Cart_Item__r.ERP7__Serial_Number__r.Name == component.get("v.scanCode")){
                            console.log('matched');
                            component.set("v.scanCode",'');
                            itemFound = true; 
                            objlist[i].isselected = true;
                            // $(window).trigger('keypress'); 
                            break; 
                        }
                    
                }//else
                // newobjlist.push(obj);
                
                
                if(objlist[i].isselected && ($A.util.isUndefined(objlist[i].ERP7__To_Location__c) || $A.util.isEmpty(objlist[i].ERP7__To_Location__c))){
                    itemFound = true;
                    scanLocation = true;
                    // $(window).trigger('keypress'); 
                }
                
            } 
            console.log('itemFound : ',itemFound);
            console.log('scanLocation : ',scanLocation);
            if(itemFound && !scanLocation)
                component.set("v.PutawayItems",objlist);
            if(scanLocation && itemFound){
                var locationAction = component.get("c.getLocationByBarcode");
                locationAction.setParams({"bcode":component.get("v.scanCode"),"SiteId":component.get("v.site_dest.Id")});
                locationAction.setCallback(this,function(res){
                    let state = res.getState();
                    if (state === "SUCCESS") {
                        component.set("v.scanCode",'');
                        let obj = JSON.parse(res.getReturnValue());
                        if($A.util.isEmpty(obj.Error)){
                            let objlist = component.get("v.PutawayItems");
                            
                            for(var j=0;j<objlist.length;j++){
                                if(objlist[j].isselected && ($A.util.isUndefined(objlist[j].ERP7__To_Location__c) ||$A.util.isEmpty(objlist[j].ERP7__To_Location__c))){
                                    objlist[j].ERP7__To_Location__c = obj.Id;
                                    objlist[j].ERP7__To_Location__r = {Id:obj.Id,Name:obj.Name};
                                }
                            }
                            component.set("v.PutawayItems",objlist);   
                        }else{
                            this.showToast($A.get('$Label.c.Error_UsersShiftMatch'),"error",obj.Error); 
                        }
                    }
                });
                $A.enqueueAction(locationAction);
            }
            
            if(component.get("v.scanCode") === 'Putaway'){
                var action = component.get('c.Putaway');
                $A.enqueueAction(action);
            }
        }catch(e){
            console.log('error : ',e);
        }
    },
    getProductDetails : function(component,helper){
        console.log('fromSiteCode : ',component.get("v.fromSiteCode"));
        if(component.get("v.fromSiteCode") != null && component.get("v.fromSiteCode") != '' && component.get("v.fromSiteCode") != undefined){
            component.set('v.site.Id',component.get("v.fromSiteCode"));
            component.set("v.proceedCartIdChangeHandler",false);
        }
            var action = component.get("c.getProdDetails");
            action.setParams({"prodId" : component.get('v.prodRecordId'),siteId : component.get("v.fromSiteCode")});
            action.setCallback(this,function(response){
                console.log('response.getState() getProductDetails: ',response.getState());
                if(response.getState() === 'SUCCESS'){
                    if(response.getReturnValue() != null){
                        console.log('response : ',response.getReturnValue());
                        var standProds = response.getReturnValue();
                        let productsToAdd = [];
                        var existingitems = component.get('v.CartItemInfo');
                        var currentIndex = 0;
                        if(existingitems != undefined && existingitems.length > 0){
                            currentIndex = existingitems.length - 1;
                        }
                        var newItem = { 'index': currentIndex, 'cpi': { 'Id': null, 'Name': '', ERP7__Available_Stock__c: 0.00, 'ERP7__Quantity__c': 0.00, 'ERP7__Product__c': '', 'ERP7__From_Location__c': '', 'ERP7__From_Location__r': { 'Id': '', 'Name': '', 'ERP7__Barcode__c': '' }, 'ERP7__Product__r': { 'Id': '', 'Name': '', 'ERP7__Barcode__c': '' }, 'ERP7__Serial_Number__c': '', 'ERP7__Serial_Number__r': { 'Id': '', 'Name': '', 'ERP7__Serial_Number__c': '' }, 'ERP7__Fixed_Asset__c': '', 'ERP7__Fixed_Asset__r': { 'Id': '', 'Name': '' }, 'ERP7__Cart__c': component.get("v.cart.Id") } };
                        
                        newItem.cpi.ERP7__Available_Stock__c = standProds.stock;
                        newItem.cpi.ERP7__Product__c = standProds.product.Id;
                        newItem.cpi.ERP7__Product__r = {Id : standProds.product.Id,ERP7__Serialise__c : standProds.product.ERP7__Serialise__c,ERP7__Lot_Tracked__c :standProds.product.ERP7__Lot_Tracked__c };
                        newItem.cpi.Name = standProds.product.Name;
                        newItem.cpi.ERP7__Inventory_Stock__c = standProds.inventory;
                        newItem.index = currentIndex;
                        productsToAdd.push(newItem);
                        var allcartItems = existingitems.concat(productsToAdd);
                        console.log('allcartItems : ',JSON.stringify(allcartItems));
                        component.set('v.CartItemInfo',allcartItems);
                        if(standProds.errMsg != null && standProds.errMsg != '' && standProds.errMsg != undefined){
                            helper.showToast($A.get('$Label.c.warning_UserAvailabilities'),'warning',standProds.errMsg);
                        }	 
                    }
                }
            });
        $A.enqueueAction(action);
        
        
    },
    getLocation : function(component,helper){
        component.set('v.showSpinnerItem', true);
        console.log('inside check for loc');
        var action = component.get("c.searchLocation");
        action.setParams({
            "bcode": component.get("v.scanCode"),
            "SiteId": component.get("v.site.Id"),
        });
        action.setCallback(this, function (response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null) {
                    var obj = response.getReturnValue();
                    component.set("v.Location",response.getReturnValue());
                    component.set("v.callChangeLocation",true);
                    console.log('inside check for loc result:',obj);
                    var cartInfo = component.get("v.CartItemInfo");
                    for( var x in cartInfo){
                        if(cartInfo[x].cpi.ERP7__Product__c == component.get("v.storeProdId")){
                            cartInfo[x].cpi.ERP7__From_Location__c = obj;  
                        }
                    }
                    component.set("v.CartItemInfo",cartInfo);
                    console.log('CartItemInfo:',CartItemInfo);
                    component.set('v.showSpinnerItem', false);
                    return true;
                }
                else{
                    component.set('v.showSpinnerItem', false);
                    return false;
                }
            }
        });
        $A.enqueueAction(action);
        
    }, 
    getLOcount : function(cmp,event){
        console.log('in here?')
        let count = cmp.get("v.CartItemInfo");
        cmp.set("v.CartItemInfo", count);
    },
    
    FunctionalityControl : function (component, event) {
        try{
            
            var action = component.get("c.getFunctionality");
            action.setParams({});
            action.setCallback(this, function (response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.ShowglobaLocation",response.getReturnValue());  
                }
            });
            $A.enqueueAction(action);
            
        }
        catch(e){console.log('Exception in FunctionalityControl:',e);}
    },
                   
})