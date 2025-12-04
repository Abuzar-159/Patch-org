({
	doInit : function(component, event, helper) {
        if(component.get('v.value') != null){
            //console.log('CurrencyOutputFiend v.value~>'+component.get('v.value'));
            //console.log('CurrencyOutputFiend v.Rate~>'+component.get('v.Rate'));
            var val = component.get('v.value') * component.get('v.Rate');
            //console.log('CurrencyOutputFiend finalValue~>'+val);
            component.set('v.finalValue', val);
        }
	}
})