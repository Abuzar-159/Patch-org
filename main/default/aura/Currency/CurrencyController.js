({
	doInit : function(component, event, helper) {
        if(component.get('v.value')!=null){
            var val = component.get('v.value') * component.get('v.Rate');
            val=Math.round(val);
            component.set('v.finalValue', val);
        }
	}
})