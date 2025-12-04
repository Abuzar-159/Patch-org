({
	loadPickList : function(component, event, helper) {
		 var action = component.get('c.getPickList');

      action.setCallback(this, function(response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set('v.picklist', response.getReturnValue());
        }
      });
      $A.enqueueAction(action); 
	},
    
    filterMethod: function(component, event, helper) {
       
        var compEvent = component.getEvent("family");
      
        compEvent.setParams({
            "familyType":event.target.dataset.record
        });
        compEvent.fire();
        //}     
    },
})