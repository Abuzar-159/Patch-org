({
    getProductDetails : function(component, event, productId){
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var action = component.get("c.fetchProductDetails");
        action.setParams({
            currProdId : productId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var res = response.getReturnValue();
                console.log('get prod details response.getReturnValue() : '+JSON.stringify(response.getReturnValue()));
                component.set("v.item.ERP7__Products__r",res);
                if(component.get("v.processSNBatch")){
                    component.set("v.BatchProd", res.ERP7__Lot_Tracked__c);
                    component.set("v.SerialProd", res.ERP7__Serialise__c);
                }
                if(res.Name.length > 80){
                    var name = res.Name;
                    name = name.substring(0,80);
                    component.set("v.item.Name", name);
                }
                else component.set("v.item.Name", res.Name);
                
                if(res.ERP7__Lot_Tracked__c == true || res.ERP7__Serialise__c == true)
                    component.set("v.SerialorBatch", true);
                if(res.ERP7__Serialise__c && component.get("v.processSNBatch"))   {
                   component.set("v.item.ERP7__Quantity_requested__c",1);
                    console.log('in here');
                } 
                
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
            }
            else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        setTimeout(function(){ component.set("v.exceptionError",errors[0].message); }, 5000);
                    }
                } else {
                    setTimeout(function(){ component.set("v.exceptionError",$A.get('$Label.c.Unknown_error')); }, 5000);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getProductStock : function(component, event, productId){
        console.log('getProductStock called');
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var action = component.get("c.fetchProductInventoryStock");
        action.setParams({
            currProdId : productId,
            siteId : component.get("v.FDId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log(' get prod stock response.getReturnValue() : '+response.getReturnValue());
                component.set("v.item.availableQty",response.getReturnValue());
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
            }
            else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
                //component.set("v.isresetProject", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       setTimeout(function(){ component.set("v.exceptionError",errors[0].message); }, 5000);
                    }
                } else {
                   setTimeout(function(){ component.set("v.exceptionError",$A.get('$Label.c.Unknown_error')); }, 5000);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getBatchStock : function(component, event, productId,batchId){
        console.log('getBatchStock called');
       // $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var action = component.get("c.fetchBatchProductInventoryStock");
        action.setParams({
            currProdId : productId,
            currBatchLot : batchId,
            siteId : component.get("v.FDId")
        });
        action.setCallback(this, function(response){
            console.log('response.getState() : '+response.getState());
            if(response.getState() === "SUCCESS"){
                console.log('response.getReturnValue() : '+response.getReturnValue());
                component.set("v.item.availableQty",response.getReturnValue());
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
            }
            else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
                //component.set("v.isresetProject", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       setTimeout(function(){ component.set("v.exceptionError",errors[0].message); }, 5000);
                    }
                } else {
                   setTimeout(function(){ component.set("v.exceptionError",$A.get('$Label.c.Unknown_error')); }, 5000);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    validateCheck : function(cmp) {
        if($A.util.isEmpty(cmp.get("v.value"))){
            cmp.set("v.class","hasError");
            return false;
        }else{
            cmp.set("v.class","");
            return true; 
        }
	},
    
    checkvalidationLookup : function(lkpField){
        if($A.util.isEmpty(lkpField.get("v.selectedRecord.Id"))){
            lkpField.set("v.inputStyleclass","hasError");
            return false;
        }else{
            lkpField.set("v.inputStyleclass","");
        	return true;
        }
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
            //component.set("v.showMainSpin",false);
            toastEvent.fire();
        }
    },
    
})