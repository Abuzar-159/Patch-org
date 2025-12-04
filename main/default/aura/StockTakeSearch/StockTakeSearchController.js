({
	SearchString : function(component, event, helper) {
        var searchparam = component.find("searchBox").get("v.value");
        var searchEvent = component.getEvent("Search_Event");
        searchEvent.setParams({"searchString":searchparam});
        searchEvent.fire();
	},
})