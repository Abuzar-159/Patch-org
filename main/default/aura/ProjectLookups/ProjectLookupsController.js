({
    /*
        Verify component has been loaded with the required params
    */
    fireEvt: function(component, event, helper) {
        try {
            var empid = component.get("v.value");
        
            var evt = $A.get("e.c:apprDisplayEvent"); 
            evt.setParams({
                recId: empid
            });
            evt.fire();
        } catch (ex) {}
    },
    qryset: function(component, event, helper) {
      try {
          component.set("v.qry",event.getParam("qry"));
      } catch (ex) {}
    },
    
    initSetup: function(component, event, helper) {
        try {
            if (!component.get('v.type')) {
                //$A.error("inputLookup component requires a valid SObject type as input: [" + component.getGlobalId() + "]");
                throw new Error("inputLookup component requires a valid SObject type as input: [" + component.getGlobalId() + "]");
                //return;
            
            }
        } catch (ex) {}
    },

    /*
        When RequireJS is loaded, loads the typeahead component
    */
    initTypeahead: function(component, event, helper) {
        try {
            //first load the current value of the lookup field and then
            //creates the typeahead component
            helper.loadFirstValue(component);
        } catch (ex) {}
    },
    /*
     * When the input field is manually changed, the corresponding value (id) is set to null
     */
    checkNullValue: function(component, event, helper) {
        try {
            helper.hfireEvt(component, event, helper);
            component.set('v.value', null);
        } catch (ex) {}
    }
})