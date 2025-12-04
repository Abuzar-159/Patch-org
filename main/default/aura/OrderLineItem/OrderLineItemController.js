({
    getPrice: function(component, event, helper) {
        
    },
    
    getCategory : function(component, event, helper){
        
    },
    
    getCostCard: function(component, event, helper) {
        
    },
    
    getProductCC: function(component, event, helper) {
        /*console.log('getProductCC called');
        try{
            if($A.util.isEmpty(component.get("v.item"))){
                console.log('getProductCC inhere1');
                if($A.util.isEmpty(component.get("v.item.ERP7__Product__c")) || $A.util.isUndefinedOrNull(component.get("v.item.ERP7__Product__c"))){
                    if(component.get("v.item.ERP7__Cost_Card__c") != undefined)
                        component.set("v.item.ERP7__Cost_Card__c",null);
                    if(component.get("v.item.ERP7__Detailed_Description__c")!= undefined)
                        component.set("v.item.ERP7__Detailed_Description__c",'');
                    if(component.get("v.item.Name")!= undefined)
                        component.set("v.item.Name",'');
                    if(component.get("v.item.Quantity")!= undefined)
                        component.set("v.item.Quantity",'');
                    if(component.get("v.item.UnitPrice")!= undefined)
                        component.set("v.item.UnitPrice",'');
                    if(component.get("v.item.ERP7__Total_Price__c")!= undefined)
                        component.set("v.item.ERP7__Total_Price__c",'');
                }
            }
            else {
                console.log('getProductCC fetchProductCC calling');
                var action = component.get("c.fetchProductCC");
                action.setParams({
                    "vendorId": component.get("v.vendorId"),
                    "productId": component.get("v.item.ERP7__Product__c")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        console.log('getProductCC resp~>',response.getReturnValue());
                        if(response.getReturnValue() != null){   
                            console.log('getProductCC setting ERP7__Cost_Card__c here');
                            component.set("v.item.ERP7__Cost_Card__c", response.getReturnValue().Id); 
                           // component.set("v.item.ERP7__Lead_Time_Days__c", response.getReturnValue().ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c); commented shaguftha on 16_01_24
                        }
                        else component.set("v.item.ERP7__Cost_Card__c",null);
                    }else{
                        console.log('getProductCC error~>',JSON.stringify(response.getError()));
                    } 
                });
                $A.enqueueAction(action);
                
                if(component.get("v.item.ERP7__Detailed_Description__c ") == null || component.get("v.item.ERP7__Detailed_Description__c ") == '' || component.get("v.item.ERP7__Detailed_Description__c ") == undefined){
                    console.log('fetchProductDesc calling');
                    var action = component.get("c.fetchProductDesc");
                    action.setParams({ "productId": component.get("v.item.ERP7__Product__c")});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            console.log('fetchProductDesc resp~>',response.getReturnValue());
                            
                            if (response.getReturnValue() != null) {
                                component.set("v.item.ERP7__Detailed_Description__c", response.getReturnValue().ERP7__Vendor_Supplier_Description__c);
                                component.set("v.item.ERP7__Inventory_Account__c", response.getReturnValue().ERP7__Inventory_Account__c);
                                if(response.getReturnValue().ERP7__Version__c != null) component.set("v.item.ERP7__Version__c", response.getReturnValue().ERP7__Version__c);
                                var Name = response.getReturnValue().Name;
                                console.log('Name : ',Name,' Length : ',Name.length);
                                if(Name.length >= 80){
                                    var trimmedString = Name.substring(0, 79);
                                    console.log('trimmedString : ',trimmedString);
                                    component.set("v.item.Name",trimmedString);
                                }
                                else{
                                    component.set("v.item.Name",response.getReturnValue().Name);  
                                }
                                
                                if(component.get("v.item.ERP7__Vendor_product_Name__c ") == null || component.get("v.item.ERP7__Vendor_product_Name__c ") == '' || component.get("v.item.ERP7__Vendor_product_Name__c ") == undefined) component.set("v.item.ERP7__Vendor_product_Name__c",response.getReturnValue().ERP7__Vendor_product_Name__c);
                                
                            }
                        }
                    });
                    $A.enqueueAction(action);
                }
                $A.enqueueAction(component.get("c.getstockdetails"));
            }  
        } catch (e) { console.log('err~>'+e); }*/
    },
    
    setccList: function(component, event, helper) {
        component.find("costCard").set("v.listOfSearchRecords", component.get("v.costCardIds"));
    },
    
    updateTotalPrice: function(component, event, helper) {
        try{
            console.log('updateTotalPrice poli called');
            var qty = (!$A.util.isEmpty(component.get("v.item.Quantity")) && !$A.util.isUndefinedOrNull(component.get("v.item.Quantity"))) ? component.get("v.item.Quantity") : 0;
            var unitprice = (!$A.util.isEmpty(component.get("v.item.UnitPrice")) && !$A.util.isUndefinedOrNull(component.get("v.item.UnitPrice"))) ? component.get("v.item.UnitPrice") : 0;
            var taxamt = (!$A.util.isEmpty(component.get("v.item.ERP7__VAT_Amount__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__VAT_Amount__c"))) ? component.get("v.item.ERP7__VAT_Amount__c") : 0;
            
            var val = parseFloat(qty * unitprice) + parseFloat(taxamt);
            if(val != undefined && val != null){
                if(val > 0) val = val.toFixed($A.get("$Label.c.DecimalPlacestoFixed")); else val = 0;
            }else val = 0;
            component.set("v.item.ERP7__Total_Price__c",val);
            if((!$A.util.isEmpty(component.get("v.DefTaxRate")) && !$A.util.isUndefinedOrNull(component.get("v.DefTaxRate")))){
                if(component.get("v.DefTaxRate") > 0){
                    component.set("v.item.ERP7__Discount_Percent__c", component.get("v.DefTaxRate"));
                    console.log('deftaxrate setinghere1');
                }
            }
            component.set("v.TotalPrice",val);
            var cmpqty = component.find("qty");
            if(!$A.util.isUndefined(cmpqty)) helper.validateCheck(cmpqty);
            helper.ValidateQuantity(component, event, helper);
            $A.enqueueAction(component.get("c.UpdateTax"));
        } catch (e) { console.log('updateTotalPrice err~>'+e); }
    },
    
    deletePoli: function(component, event, helper) {
        
        var currtItem=event.getSource().get('v.title');
        console.log('currtItem:',currtItem);
        console.log('Index:',component.get("v.index"));
        try {
            console.log('try1');
            var e = $A.get("e.c:RequisitionToPurchaseOrderEvent"); //  component.getEvent("ExpertServiceEvent");                                                       
            console.log('try2');
            e.setParams({
                "Index": component.get("v.index"),
                "itemToDelCurr":currtItem
            });
            console.log('try3');
            e.fire();
            console.log('try4');
        } catch (ex) {console.log('catch:',ex);}
        console.log('out1');
        component.set("v.Tax",0);
        console.log('out2');
    },
    
    validate: function(component, event, helper) {
        var NoErrors = true;
        var cmpqty = component.find("qty");
        if (!$A.util.isUndefined(cmpqty))
            NoErrors = helper.validateCheck(cmpqty);
        var price = component.find("amount");
        if (!$A.util.isUndefined(price))
            NoErrors = helper.validateCheck(price);
        
        /*var productField = component.find("product");
        if (!$A.util.isUndefined(productField))
            NoErrors = helper.checkvalidationLookup(productField);*/
        return NoErrors;
    },
    
    lookupClickCostCard: function(cmp, helper) {
        
    },
    
    lookupClickProduct : function(cmp, helper) {
        
    },
    
    getstockdetails : function(cmp, helper) {
        
    },
    
    
    UpdateTax : function(component,event,helper){
        try{
            console.log('v.Tax set here bfr~>'+component.get("v.item.ERP7__Discount_Percent__c"));
            var qty = (!$A.util.isEmpty(component.get("v.item.Quantity")) && !$A.util.isUndefinedOrNull(component.get("v.item.Quantity"))) ? component.get("v.item.Quantity") : 0;
            var unitprice = (!$A.util.isEmpty(component.get("v.item.UnitPrice")) && !$A.util.isUndefinedOrNull(component.get("v.item.UnitPrice"))) ? component.get("v.item.UnitPrice") : 0;
            var taxamt = 0;
            var taxrate = (!$A.util.isEmpty(component.get("v.item.ERP7__Discount_Percent__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Discount_Percent__c"))) ? component.get("v.item.ERP7__Discount_Percent__c") : 0;
            
            if(taxrate > 0 && unitprice > 0 && qty > 0) taxamt = parseFloat(((unitprice * qty)/100) * taxrate).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            //if(qty > 0 && taxamt > 0) taxamt = parseFloat(taxamt * qty).toFixed($A.get("$Label.c.DecimalPlacestoFixed")); else taxamt = 0;
            console.log('taxamt ~>'+taxamt+' typeof~>'+typeof taxamt);
            
            component.set("v.item.ERP7__VAT_Amount__c",taxamt);
            console.log('v.item.ERP7__VAT_Amount__c set here~>'+component.get("v.item.ERP7__VAT_Amount__c"));
            
            console.log('Tax Amount TEst :',parseFloat((unitprice * qty * taxrate) / 100));
            component.set("v.Tax",parseFloat((unitprice * qty * taxrate) / 100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            //component.set("v.Tax",parseFloat((unitprice * taxrate) / 100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            console.log('v.Tax set here after~>'+component.get("v.Tax"));
            
            console.log('parseFloat(qty * unitprice)~>'+parseFloat(qty * unitprice));
            
            var totalPrice = parseFloat(qty * unitprice) + parseFloat(taxamt);
            console.log('totalPrice ~>'+totalPrice+' typeof~>'+typeof totalPrice);
            if(totalPrice != undefined && totalPrice != null){
                if(totalPrice > 0) totalPrice = totalPrice.toFixed($A.get("$Label.c.DecimalPlacestoFixed")); else totalPrice = 0;
            }else totalPrice = 0;
            
            component.set("v.item.ERP7__Total_Price__c",totalPrice);
            console.log('v.item.ERP7__Total_Price__c set here~>'+component.get("v.item.ERP7__Total_Price__c"));
            component.set("v.TotalPrice",totalPrice);
            //$A.enqueueAction(component.get("c.updateACTaxAmount"));
        } catch (e) { console.log('UpdateTax err~>'+e); }
    },
    
    displayAccounts : function(component,event,helper){
        
    },
    
    updateACTaxAmount : function(component,event,helper){
        
    },
    
    updateACTaxPerentage : function(component,event,helper){
        
    },
    
  
    
    deleteAnalyAcc :function(component, event, helper) {
        
    },
    
    
    resetAA : function(component, event, helper) {
        
    },
    
    
    
    getprojectBudgetdetails : function(cmp, helper) {
        
    },
    
    
    
    getprojectDepBudgetdetails : function(cmp, helper) {
        
    },
})