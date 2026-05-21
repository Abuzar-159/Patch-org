({
    
    deletePrli: function(component, event, helper) {
        try {
            var e = $A.get("e.c:IndexingEvent"); //  component.getEvent("ExpertServiceEvent");                                                       
            e.setParams({
                "Index": component.get("v.index")
            });
            e.fire();
        } catch (ex) {}        
    },
    
    updateTotalPrice : function(component,event,helper){
        
        var val = parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Price__c"));
        component.set("v.item.ERP7__Amount__c",val);
        
         var cmpqty = component.find("qty");
        if (!$A.util.isUndefined(cmpqty))
            helper.validateCheck(cmpqty);
        /*var price = component.find("amount");
        if (!$A.util.isUndefined(price))
            helper.validateCheck(price);*/
       helper.ValidateQuantity(component,event,helper);         
    },
    
    validate : function(component,event,helper){
        var NoErrors = true;
        var cmpqty = component.find("qty");
       /* if(!$A.util.isUndefined(cmpqty))
            NoErrors = helper.validateCheck(cmpqty);
        var price = component.find("amount");
        if(!$A.util.isUndefined(price))
            NoErrors = helper.validateCheck(price);*/
       
        var productField = component.find("product");
       // if(!$A.util.isUndefined(productField))
        //NoErrors = helper.checkvalidationLookup(productField);
        return NoErrors;
    },
    
    getProductCC: function(component, event, helper) {
        if($A.util.isEmpty(component.get("v.item.ERP7__Product__c"))){
            component.set("v.item.ERP7__Description__c",'');
            component.set("v.item.Name",'');
            component.set("v.item.ERP7__Quantity__c",'');
            component.set("v.item.ERP7__Price__c",'');
            component.set("v.item.ERP7__Amount__c",'');
        }
        
        if(component.get("v.item.ERP7__Description__c ") == null || component.get("v.item.ERP7__Description__c ") == '' || component.get("v.item.ERP7__Description__c ") == undefined){
            var action = component.get("c.fetchProductDesc");
            action.setParams({ "productId": component.get("v.item.ERP7__Product__c")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    if (response.getReturnValue() != null){
                        component.set("v.item.ERP7__Description__c", response.getReturnValue().ERP7__Vendor_Supplier_Description__c); 
                        var name = response.getReturnValue().Name;
						if(name.length >=80){
						var trimmedString = name.substring(0,79);
						console.log('trimmedString : ',trimmedString);
						component.set("v.item.Name", trimmedString);
						}
						else{
						
                        component.set("v.item.Name", response.getReturnValue().Name); 
						}
  
                    }
                    
                } 
            });
            $A.enqueueAction(action);
        }
    },
    getstockdetails : function(cmp, helper) {
        var obj = cmp.get('v.item');
        console.log('obj : '+JSON.stringify(obj));
        var currprod = cmp.get('v.item.ERP7__Product__c');
        console.log('currprod : '+currprod);
        console.log('Dc : '+cmp.get('v.dCId'));
        if(currprod != '' && currprod != null && cmp.get('v.dCId') != '' && cmp.get('v.dCId') != null){
            var action = cmp.get('c.getstocks');
            action.setParams({'DCId' : cmp.get('v.dCId'),'ProductId' : currprod});
            action.setCallback(this,function(response){
                let resList = response.getReturnValue();
                console.log('response : '+JSON.stringify(resList));
                if(currprod == resList.Product){
                    cmp.set('v.item.ItemsinStock',resList.Stock);
                    cmp.set('v.item.demand',resList.Demand);
                    cmp.set('v.item.AwaitingStock',resList.AwaitingStocks);
                }
                //component.set("v.POStatusoptions",resList);                
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");            
            });
            $A.enqueueAction(action);
        }
    }
})