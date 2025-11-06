({
    changeLocation : function(component, event, helper) {
        try{
            
            const globalLocation = component.get("v.globalLocation");
            const isSelected = component.get("v.item.isselected");
            const item = component.get("v.item");
            
            if (isSelected && !$A.util.isEmpty(globalLocation)) {
                item.ERP7__To_Location__r.Id = globalLocation;
                item.ERP7__To_Location__c = globalLocation;
            } 
            else if (!isSelected && !$A.util.isEmpty(globalLocation)) {
                item.ERP7__To_Location__r.Id = '';
                item.ERP7__To_Location__c = '';
            }
            component.set("v.item", item);
        }
        catch(e){console.log('error in Change Item Location:',e);}
    },
    updateLocation : function(component, event, helper) {
        if(!$A.util.isUndefined(component.get("v.item")))
		component.set("v.item.ERP7__To_Location__c",component.get("v.item.ERP7__To_Location__r.Id"));
	},
})