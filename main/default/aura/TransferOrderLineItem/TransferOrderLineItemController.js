({
    deletetoli: function(component, event, helper) {
        try {
            var e = $A.get("e.c:IndexingEvent"); //  component.getEvent("ExpertServiceEvent");                                                       
            e.setParams({
                "Index": component.get("v.index")
            });
            e.fire();
        } catch (ex) {}
        
    },
    
    productChange : function(component, event, helper) {
        console.log('productChange FDId : '+component.get("v.FDId"));
        if(component.get("v.FDId")!=null && component.get("v.FDId")!=''){
            var productId = component.get("v.item.ERP7__Products__c");
            console.log('productChange productId : '+productId);
            if(productId == null || productId == undefined || productId == ""){
                component.set("v.item.availableQty","");
                component.set("v.item.ERP7__SerialNumber__c","");
                component.set("v.item.ERP7__Batch_Lot__c","");
                component.set("v.item.ERP7__Quantity_requested__c","");
                if(component.get("v.SerialProd") == true)
                    component.set("v.SerialProd", false);
            }
            else{
                helper.getProductDetails(component, event, productId);
                 var batchId = component.get("v.item.ERP7__Batch_Lot__c");
                var serialId = component.get("v.item.ERP7__SerialNumber__c");
                console.log('serialId : '+serialId);
                if(batchId != undefined && !$A.util.isEmpty(batchId) && !$A.util.isUndefinedOrNull(batchId)){
                    console.log('productChange is batch');
                     helper.getBatchStock(component, event, productId, batchId);
                }else if(serialId != undefined && !$A.util.isEmpty(serialId) && !$A.util.isUndefinedOrNull(serialId)){
                    console.log('productChange is serial');
                    component.set("v.item.availableQty", 1);
                }else{
                    console.log('productChange batch and serial empty');
                    helper.getProductStock(component, event, productId);
                }
            }
        }else{
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_select_the_distribution_channel'));
        }
    },
    
    batchChange : function(component, event, helper) {
        console.log('batchChange called');
        if(component.get("v.FDId")!=null && component.get("v.FDId")!=''){
            var productId = component.get("v.item.ERP7__Products__c");
            if(productId != null && productId != undefined && productId != ""){
                var batchId = component.get("v.item.ERP7__Batch_Lot__c");
                var serialId = component.get("v.item.ERP7__SerialNumber__c");
                if(!$A.util.isEmpty(batchId) && !$A.util.isUndefinedOrNull(batchId)){
                    console.log('batchChange is batch');
                    helper.getBatchStock(component, event, productId, batchId);
                }else if(!$A.util.isEmpty(serialId) && !$A.util.isUndefinedOrNull(serialId)){
                    console.log('batchChange is serial');
                    component.set("v.item.availableQty", 1);
                }else{
                    console.log('batchChange batch and serial empty');
                    helper.getProductStock(component, event, productId);
                }
            }
        }else{
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_select_the_distribution_channel'));
        }
    },
    
    serialChange : function(component, event, helper) {
        console.log('serialChange called');
        if(component.get("v.FDId")!=null && component.get("v.FDId")!=''){
            var productId = component.get("v.item.ERP7__Products__c");
            if(productId != null && productId != undefined && productId != ""){
                var batchId = component.get("v.item.ERP7__Batch_Lot__c");
                var serialId = component.get("v.item.ERP7__SerialNumber__c");
                if(!$A.util.isEmpty(batchId) && !$A.util.isUndefinedOrNull(batchId)){
                    console.log('batchChange is batch');
                    helper.getBatchStock(component, event, productId, batchId);
                }else if(!$A.util.isEmpty(serialId) && !$A.util.isUndefinedOrNull(serialId)){
                    console.log('batchChange is serial');
                    component.set("v.item.availableQty", 1);
                }else{
                    console.log('batchChange batch and serial empty');
                    helper.getProductStock(component, event, productId);
                }
            }
        }else{
            helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.Please_select_the_distribution_channel'));
        }
    },
    
    lookupClickBatch :function(component,helper){
        var acc = component.get("v.item.ERP7__Products__c");
        //alert(acc);
        var qry;
        if(acc == undefined || acc == null) qry = ' ';
        else qry = ' And ERP7__Product__c = \''+acc+'\'';
        component.set("v.qry",qry);
    },
    
    lookupClickSerial :function(cmp,helper){
        var acc = cmp.get("v.item.ERP7__Products__c");
        var qry;
         if(acc == undefined || acc == null) qry = ' ';
        else qry = 'AND ERP7__Product__c = \''+acc+'\''; //AND ERP7__Available__c = true 
        cmp.set("v.qry",qry);
    },
    
    prodValidate : function(component, event, helper){
        var NoErrors = true;
        var cmpProd = component.find("toliProduct");
        if (!$A.util.isUndefined(cmpProd))
            NoErrors = helper.checkvalidationLookup(cmpProd);
        return NoErrors;
    },
    
    prodSerBatValidate : function(component, event, helper){
        var NoErrors = true;
        if(component.get("v.processSNBatch")){
            if(component.get("v.SerialProd")){
                var cmpProd = component.find("toliSerial");
                if (!$A.util.isUndefined(cmpProd))
                    NoErrors = helper.checkvalidationLookup(cmpProd);
            }
            if(component.get("v.BatchProd")){
                var cmpProd = component.find("toliBatch");
                if (!$A.util.isUndefined(cmpProd))
                    NoErrors = helper.checkvalidationLookup(cmpProd);
            }
        }
        return NoErrors;
    },
    
    qtyValidate : function(component, event, helper){
        var NoErrors = true;
        var cmpqty = component.find("toliQty");
        if (!$A.util.isUndefined(cmpqty))
            NoErrors = helper.validateCheck(cmpqty);
        if(cmpqty.get("v.value")==0){
            cmpqty.set("v.class","hasError");
            NoErrors = false;
        }
        return NoErrors;
    },
    
    validateqtyValue : function(component, event, helper){
        var cmpqty = component.find("toliQty");
        if(cmpqty.get("v.value")>0){
            cmpqty.set("v.class", "");
        }
        else
            cmpqty.set("v.class", "hasError");
    },
    
    checkInventory : function(component, event, helper){
        var action = component.get("c.checkInventories");
        action.setParams({
            siteId : component.get("v.FDId"),
            ProductId : component.get("v.item.ERP7__Products__c"),
            quan : component.get("v.item.ERP7__Quantity_requested__c")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('checkInventory~>', response.getReturnValue());
                var res = response.getReturnValue();
                if(!res) helper.showToast($A.get('$Label.c.Error_UsersShiftMatch'),'error',$A.get('$Label.c.We_do_not_have_enough_inventory_on_the_selected_site'));
            }else{
                var errors = response.getError();
                console.log('errors checkInventory~>',errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    stockhandler : function(component, event, helper){
        console.log('stockhandler called');
        var productId = component.get("v.item.ERP7__Products__c");
        console.log('stockhandler productId : '+productId);
        console.log('stockhandler FDId : '+component.get("v.FDId"));
        
        if(productId == null || productId == undefined || productId == "" || $A.util.isEmpty(component.get("v.FDId")) || $A.util.isUndefinedOrNull(component.get("v.FDId"))){
            component.set("v.item.availableQty","");
            component.set("v.item.ERP7__SerialNumber__c","");
            component.set("v.item.ERP7__Batch_Lot__c","");
            component.set("v.item.ERP7__Quantity_requested__c","");
        }
        
        if(!$A.util.isEmpty(component.get("v.FDId")) && !$A.util.isUndefinedOrNull(component.get("v.FDId"))){
            if(!$A.util.isEmpty(productId) && !$A.util.isUndefinedOrNull(productId)){
                helper.getProductDetails(component, event, productId);
                 var batchId = component.get("v.item.ERP7__Batch_Lot__c");
                var serialId = component.get("v.item.ERP7__SerialNumber__c");
                if(!$A.util.isEmpty(batchId) && !$A.util.isUndefinedOrNull(batchId)){
                    console.log('stockhandler called is batch');
                     helper.getBatchStock(component, event, productId, batchId);
                }else if(!$A.util.isEmpty(serialId) && !$A.util.isUndefinedOrNull(serialId)){
                    console.log('stockhandler called is serial');
                    component.set("v.item.availableQty", 1);
                }else{
                    console.log('stockhandler called batch and serial empty');
                    helper.getProductStock(component, event, productId);
                }
            }
        }else{
            if(!$A.util.isEmpty(productId) && !$A.util.isUndefinedOrNull(productId)){
                helper.getProductDetails(component, event, productId);
            }
        }
    }
})