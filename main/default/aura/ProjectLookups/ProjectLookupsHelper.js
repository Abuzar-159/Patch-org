({
    //typeahead already initialized
    typeaheadInitStatus: {},
    //"old value" to trigger reload on "v.value" change
    typeaheadOldValue: {},
    /*
        Creates the typeahead component using RequireJS, jQuery, Bootstrap and Bootstrap Typeahead
    */
    hfireEvt: function(component, event, helper) {
        var empid = component.get("v.value");
        var evt = component.getEvent("apprDisplay");
        evt.setParams({
            "Sobjectid": empid
        });
        evt.fire();
    },
    
    createTypeaheadComponent: function(component) {},
    /*
     * Method used by the typeahead to retrieve search results
     */
    substringMatcher: function(component) {
        //usefull to escape chars for regexp calculation
        function escapeRegExp(str) {
            return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
        }
        
        return function findMatches(q, cb) {
            q = escapeRegExp(q);  
            var action = component.get("c.search_SObject_Custom");
            var self = this;
            action.setParams({
                'type': component.get('v.type'),
                'searchString': q,
                'queryFilter':component.get('v.qry'),
                'SearchField':component.get('v.SearchField')
            });
            
            action.setCallback(this, function(a) {
                if (a.error && a.error.length) {
                    //return $A.error('Unexpected error: ' + a.error[0].message);
                    throw new Error('Unexpected error: ' + a.error[0].message);
                }
                var result = a.getReturnValue();
                
                var matches, substrRegex;
                
                // an array that will be populated with substring matches
                var matches = [];
                
                // regex used to determine if a string contains the substring `q`
                var substrRegex = new RegExp(q, 'i');
                var strs = JSON.parse(result);
                // iterate through the pool of strings and for any string that
                // contains the substring `q`, add it to the `matches` array
                $.each(strs, function(i, str) {
                    if (substrRegex.test(str.value)) {
                        // the typeahead jQuery plugin expects suggestions to a
                        // JavaScript object, refer to typeahead docs for more info
                        matches.push({
                            value: str.value,
                            id: str.id
                        });
                    }
                });
                if (!strs || !strs.length) {
                    
                    component.set('v.value', null);
                }
                cb(matches);
            });
            $A.enqueueAction(action);
            
        };
        
    },
    /*
     * Method used on initialization to get the "name" value of the lookup
     */
    loadFirstValue: function(component) {
        //this is necessary to avoid multiple initializations (same event fired again and again)
        if (this.typeaheadInitStatus[component.getGlobalId()]) {
            return;
        }
        this.typeaheadInitStatus[component.getGlobalId()] = true;
        this.loadValue(component);
        
    },
    
    /*
     * Method used to load the initial value of the typeahead 
     * (used both on initialization and when the "v.value" is changed)
     */
    loadValue: function(component, skipTypeaheadLoading) {
        try{ 
            this.typeaheadOldValue[component.getGlobalId()] = component.get('v.value');
            var action = component.get("c.get_CurrentValue");
            var self = this;
            action.setParams({
                'type': component.get('v.type'),
                'value': component.get('v.value'),
                'SearchField':component.get('v.SearchField')
            });
            
            action.setCallback(this, function(a) {
                if (a.error && a.error.length) {
                    //return $A.error('Unexpected error: ' + a.error[0].message);
                    throw new Error('Unexpected error: ' + a.error[0].message);
                }
                var result = a.getReturnValue();
                component.set('v.isLoading', false);
                component.set('v.nameValue', result);
                if (!skipTypeaheadLoading) self.createTypeaheadComponent(component);
            });
            $A.enqueueAction(action);
        }catch(err){}
    }
})