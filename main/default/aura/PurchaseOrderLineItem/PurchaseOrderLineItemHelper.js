({
	validateCheck : function(cmp) {
        var ik = cmp.get("v.value");
        if($A.util.isEmpty(cmp.get("v.value"))){
          //cmp.set("v.class","hasError");
            $A.util.addClass(cmp, 'slds-has-error');
            return false;
        }else{
            //cmp.set("v.class","");
            $A.util.removeClass(cmp, 'slds-has-error');
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
    
    ValidateQuantity : function(component,event,helper){ 
        
        if(component.get("v.item.ERP7__Quantity__c")<=0) component.set("v.item.ERP7__Quantity__c",'');                                         
    },
    //below method to allocate the amount if changes done in unit price or quantity
    updateAllocationAmounts: function(component) {
        try {
            console.log('realloting ERP7__Allocation_Amount__c');
            var accounts = component.get("v.item.Accounts");
            
            var quantity = parseFloat(component.get("v.item.ERP7__Quantity__c") || 0);
            var unitPrice = parseFloat(component.get("v.item.ERP7__Unit_Price__c") || 0);
            var subtotal = quantity * unitPrice; // Excludes tax
            var decimalPlaces = parseInt($A.get("$Label.c.DecimalPlacestoFixed") || 2);
            
            if (accounts && accounts.length > 0 && subtotal > 0) {
                var updatedAccounts = accounts.map(function(acc) {
                    var percent = parseFloat(acc.ERP7__Allocation_Percentage__c || 0);
                    acc.ERP7__Allocation_Amount__c = (subtotal * percent / 100).toFixed(decimalPlaces);
                    return acc;
                });
                component.set("v.item.Accounts", updatedAccounts);
            }
            console.log('updatedAccounts ',JSON.stringify(updatedAccounts));
        } catch (e) {
            console.error("Error in updateAllocationAmounts:", e);
        }
    }
})