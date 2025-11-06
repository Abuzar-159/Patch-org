({
	getProductDetails : function(component, event, productId){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchProductDetails");
        action.setParams({
            currProdId : productId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var res = response.getReturnValue();
                component.set("v.item.ERP7__Product__r",res);
                component.set("v.BatchProd", res.ERP7__Lot_Tracked__c);
                component.set("v.SerialProd", res.ERP7__Serialise__c);
                if(res.ERP7__Lot_Tracked__c == true || res.ERP7__Serialise__c == true)
                    component.set("v.SerialorBatch", true);
                if(res.ERP7__Serialise__c)
                    component.set("v.item.ERP7__Quantity__c",1);
               
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                    }
                } else {
                    component.set("v.exceptionError",$A.get('$Label.c.Unknown_error'));
                }
            }
        });
        $A.enqueueAction(action);
    },
    getProductStock : function(component, event, productId){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchProductInventoryStock");
        action.setParams({
            currProdId : productId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.item.availableQty",response.getReturnValue());
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                //component.set("v.isresetProject", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                    }
                } else {
                    component.set("v.exceptionError",$A.get('$Label.c.Unknown_error'));
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    /*
    getBatchStock : function(component, event, productId,batchId){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchBatchProductInventoryStock");
        action.setParams({
            currProdId : productId,
            currBatchLot : batchId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.item.availableQty",response.getReturnValue());
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                //component.set("v.isresetProject", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                    }
                } else {
                    component.set("v.exceptionError","Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },*/
    
    warningToast : function(cmp,event,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Warning!",
            "message": message,
            "type":"warning"
        });
        toastEvent.fire();
    },
})