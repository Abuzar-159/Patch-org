({
	changeTab : function(component, event, helper) {
        console.log('changeTAB called~>'+component.get("v.selectedTab")+' and name~>'+component.get("v.name"));
        component.set("v.selectedTab",component.get("v.name"));
        console.log('changeTAB end');
	}
})