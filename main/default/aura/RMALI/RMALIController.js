({
	validationCheck : function(component, event, helper) {
		var val = event.getSource().get("v.value");
        var max = component.get('v.max');
        if(parseFloat(val)<=0 || parseFloat(val)> parseFloat(max)){
            component.set('v.errMsg','value must > 0 && <='+max);
        }else{
            component.set('v.errMsg','');
        }
	}
})