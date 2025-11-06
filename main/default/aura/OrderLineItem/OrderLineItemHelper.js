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
        
        if(component.get("v.item.Quantity")<=0) component.set("v.item.ERP7__Quantity__c",'');                                         
    },
})