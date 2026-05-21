({
    helperTotalPrice : function(component, event) {
        try{
            console.log('helperTotalPrice called');
            var item = component.get("v.Item");
            if(!$A.util.isUndefined(item)){
                var totalPrice = 0.00;
                if(item.ERP7__Quantity__c==0) item.ERP7__Quantity__c=1;
                if(item.ERP7__Discount__c==undefined) item.ERP7__Discount__c=0;
                totalPrice += (parseFloat(item.ERP7__Quantity__c) * parseFloat(item.ERP7__Amount__c))  - item.ERP7__Discount__c;//+ item.ERP7__Tax_Amount__c
                if(totalPrice > 0.00){
                    component.set("v.Item.ERP7__Total_Amount__c",totalPrice.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
                    component.set("v.TotalPrice",totalPrice.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
                }
            }
            component.updateTaxonQuantityChange();
            component.updateACTaxAmountChange();
        }catch(e){
            console.log('helperTotalPrice err',e);
        }
    },
    
    updateProject : function(component) {
        console.log('in here XYZ');
        
        let lastValues = [];
        
        window.setInterval($A.getCallback(function() {
            let accounts = component.get("v.Item.Accounts");
            let changed = false;
            
            for (let i = 0; i < accounts.length; i++) {
                let current = accounts[i].ERP7__Project__c;
                if (current !== lastValues[i]) {
                    changed = true;
                    lastValues[i] = current;
                }
            }
            
            if (changed) {
                console.log('changing');
                // Run your filter logic here
                console.log('filtered bfr: '+JSON.stringify(accounts));
                let filtered = accounts.filter(item =>
                                               (item.ERP7__Project__c && item.ERP7__Project__c !== "") ||
                                               item.ERP7__Sort_Order__c !== undefined
                                              );
                console.log('filtered aftr: '+JSON.stringify(filtered));
                component.set("v.Item.Accounts", filtered);
            }
            
        }), 500);
    },
    
    checkvalidationLookup : function(component,poli_List){
        if($A.util.isEmpty(poli_List.get("v.selectedRecordId"))){
            poli_List.set("v.inputStyleclass","hasError");
            if(component.NoErrors)component.NoErrors = false;
        }else{
            poli_List.set("v.inputStyleclass","");
            
        }
    },
    checkValidationField : function(component,cmp){
        if($A.util.isEmpty(cmp.get("v.value"))){
            cmp.set("v.class","slds-input hasError");
            if(component.NoErrors)component.NoErrors = false;
        }else{
            cmp.set("v.class","slds-input");
        }
        
    },
    UpdateTDSOnChange : function(cmp, event, helper){
        var TDS_Rate = cmp.get('v.Item.ERP7__TDS_Rate__c');
        if(TDS_Rate!=undefined){
            var TDS_Amount = (cmp.get('v.Item.ERP7__Amount__c')/100)*TDS_Rate;
            cmp.set("v.Update_TDS_Amount",TDS_Amount);
            cmp.set('v.Item.ERP7__TDS_Amount__c',TDS_Amount);
            cmp.set('v.TDS_Amount',TDS_Amount);
            cmp.set('v.TDS_Rate',TDS_Rate);
        }
    },
})