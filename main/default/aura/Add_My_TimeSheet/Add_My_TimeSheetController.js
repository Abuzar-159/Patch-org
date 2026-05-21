({
    doInit : function(cmp, event, helper){
        cmp.set("v.Access",$A.get("$Label.c.Other_Tax_Display"));
        cmp.set("v.TDSAccess",$A.get("$Label.c.TDS_Display"));
       
        if(cmp.get("v.Item.ERP7__Tax_Amount__c")!=undefined){
            var amount=cmp.get("v.Item.ERP7__Amount__c")*cmp.get("v.Item.ERP7__Quantity__c");
            var tax=cmp.get("v.Item.ERP7__Tax_Amount__c");
           
            //var tax_Percentage=cmp.get("v.Tax_Amount");
            var Amount=cmp.get("v.Item.ERP7__Amount__c");
            var percentage=(tax/amount)*100;
           
            cmp.set("v.Item.ERP7__Tax_Rate__c",percentage);
            cmp.UpdateTax();
        }
        
        helper.helperTotalPrice(cmp, event);
        
    },
    deleteItem : function(component, event, helper) {
        component.set("v.deleteIndex",component.get("v.index"));
    },
    DeleteRecord : function(component, event, helper) { 
        try {
            var e = $A.get("e.c:RequisitionToPurchaseOrderEvent");                                                  
            
            e.setParams({
                "Index": component.get("v.index")
            });
            e.fire();
            component.set("v.TotalPrice",component.get("v.Item"));
            component.set("v.Tax",component.get("v.Item"));
        } catch (ex) {}
        //$A.enqueueAction(component.get("c.updateTotalPrice"));
        //alert(component.get("v.Item.Id"));
        if(component.get("v.Item.Id")!=null){
            var action=component.get('c.deleteLineItem');
            action.setParams({
                billItem : JSON.stringify(component.get("v.Item"))
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                alert(state);
                if( state === "SUCCESS" ){
                    component.set("v.TotalPrice",component.get("v.Item"));
            		component.set("v.Tax",component.get("v.Item"));
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    
    
    updateTotalPrice : function(component, event, helper) {
        helper.helperTotalPrice(component, event);
        component.updateTaxonQuantityChange();
        helper.UpdateTDSOnChange(component, event, helper);
        
    },
    validate : function(component,event,helper){
        component.NoErrors = true;
        var cmpqty = component.find("qty");
        if(!$A.util.isUndefined(cmpqty))
            helper.checkValidationField(component,cmpqty);
        var price = component.find("amount");
        if(!$A.util.isUndefined(price))
            helper.checkValidationField(component,price);
        var productField = component.find("product");
        if(!$A.util.isUndefined(productField))
            helper.checkvalidationLookup(component,productField);
        if(!component.NoErrors){
            var chartOfAccountField = component.find("chartOfAccount");
            if(!$A.util.isUndefined(chartOfAccountField))
                helper.checkvalidationLookup(component,chartOfAccountField);
            if(component.NoErrors)
                productField.set("v.inputStyleclass","");
        }else{
            console.log('component.NoErrors'+component.NoErrors);
            var chartOfAccountField = component.find("chartOfAccount");
            chartOfAccountField.set("v.inputStyleclass","");
        }
        return component.NoErrors;
    },
    UpdateDiscount : function(component,event,helper){
        var item = component.get("v.Item");
        
        if(!$A.util.isUndefined(item)){
            var discountAMt = component.get("v.Discount");
            
            component.set("v.Discount",item.ERP7__Discount__c);                          
        }
    },
    UpdateTax : function(component,event,helper){
        var item = component.get("v.Item");
        
        if(item.ERP7__Tax_Rate__c==undefined)item.ERP7__Tax_Rate__c=0;
        if(item.ERP7__Other_Tax_Rate__c==undefined)item.ERP7__Other_Tax_Rate__c=0;
        if(item.ERP7__Quantity__c==undefined)item.ERP7__Quantity__c=0;
        var tax=0;
        if(item.ERP7__Tax_Rate__c!=0)tax=(item.ERP7__Amount__c/100)*item.ERP7__Tax_Rate__c;
        tax=tax*item.ERP7__Quantity__c;
        var OTtax=0;
        if(item.ERP7__Other_Tax_Rate__c!=0)OTtax=(item.ERP7__Amount__c/100)*item.ERP7__Other_Tax_Rate__c;
        OTtax=OTtax*item.ERP7__Quantity__c;
        var totalTax=tax+OTtax;
        item.ERP7__Tax_Amount__c=tax;
        item.ERP7__Other_Tax__c=OTtax;
        //item.ERP7__Total_Amount__c = item.ERP7__Amount__c + item.ERP7__Tax_Amount__c;
        component.set("v.Item",item);
        component.set("v.Tax",totalTax);
       
        var rate=component.get("v.Item.ERP7__Tax_Rate__c");
        var Amount=component.get("v.Item.ERP7__Amount__c");
        component.set("v.Tax_Amount",((Amount*rate)/100).toFixed(3));
        var rate2=component.get("v.Item.ERP7__Other_Tax_Rate__c");
        component.set("v.Other_Tax_Amount",(Amount*rate2)/100);
        /*var value=component.get("v.Tax_Amount");
        var value2=component.get("v.Other_Tax_Amount");
        component.set("v.Tax",value+value2);*/
        var amount=component.get("v.Item.ERP7__Amount__c")*component.get("v.Item.ERP7__Quantity__c");
        var tax=component.get("v.Item.ERP7__Tax_Amount__c");
        component.set("v.Item.ERP7__Total_Amount__c",amount+tax);
    },
    
    UpdateTaxPercentage: function(cmp, event, helper){
        var tax_Percentage=cmp.get("v.Update_TDS_Amount");
        var Amount=cmp.get("v.Item.ERP7__Amount__c");
        var percentage=(tax_Percentage/Amount)*100;
        cmp.set("v.Item.ERP7__TDS_Rate__c",percentage);
        cmp.UpdateTDS();
    },
    
    UpdateTaxPercentage1: function(cmp, event, helper){
        var tax_Percentage=cmp.get("v.Other_Tax_Amount");
        var Amount=cmp.get("v.Item.ERP7__Amount__c");
        var percentage=((tax_Percentage/Amount)*100).toFixed(2);
        cmp.set("v.Item.ERP7__Other_Tax_Rate__c",percentage);
        cmp.UpdateTax();
    },
    
    
    UpdateTaxPercentage2: function(cmp, event, helper){
        var amount=cmp.get("v.Item.ERP7__Amount__c")*cmp.get("v.Item.ERP7__Quantity__c");
        var tax=cmp.get("v.Item.ERP7__Tax_Amount__c");
        
        
        //var tax_Percentage=cmp.get("v.Tax_Amount");
        //var Amount=cmp.get("v.Item.ERP7__Amount__c");
        var percentage=((tax/amount)*100).toFixed(3);
       
        cmp.set("v.Item.ERP7__Tax_Rate__c",percentage);
        var item = cmp.get("v.Item");
        
        if(item.ERP7__Tax_Rate__c==undefined)item.ERP7__Tax_Rate__c=0;
        if(item.ERP7__Other_Tax_Rate__c==undefined)item.ERP7__Other_Tax_Rate__c=0;
        if(item.ERP7__Quantity__c==undefined)item.ERP7__Quantity__c=0;
        var tax=0;
        if(item.ERP7__Tax_Rate__c!=0)tax=(item.ERP7__Amount__c/100)*item.ERP7__Tax_Rate__c;
        tax=tax*item.ERP7__Quantity__c;
        var OTtax=0;
        if(item.ERP7__Other_Tax_Rate__c!=0)OTtax=(item.ERP7__Amount__c/100)*item.ERP7__Other_Tax_Rate__c;
        OTtax=OTtax*item.ERP7__Quantity__c;
        var totalTax=tax+OTtax;
        item.ERP7__Tax_Amount__c=tax;
        item.ERP7__Other_Tax__c=OTtax;
        //cmp.set("v.Item",item);
        cmp.set("v.Tax",totalTax);
      
        var rate=cmp.get("v.Item.ERP7__Tax_Rate__c");
        var Amount=cmp.get("v.Item.ERP7__Amount__c");
        cmp.set("v.Tax_Amount",((Amount*rate)/100).toFixed(3));
        cmp.set("v.Item.ERP7__Total_Amount__c",amount+tax);
        //cmp.UpdateTax();
    },
    
    
    UpdateTDS : function(cmp, event, helper){
        helper.UpdateTDSOnChange(cmp, event, helper);
    },
})