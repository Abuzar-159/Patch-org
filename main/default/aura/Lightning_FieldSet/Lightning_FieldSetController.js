({
    doInit : function(component, event, helper) {
        var action = component.get("c.getFields");
        action.setParams({
            sObjectName : component.get("v.objectApiName"),
            fieldSetApiName :component.get("v.fieldSetApiName")});
        action.setCallback(this,function(response){
            component.set("v.fields",response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    submit:function(component, event, helper){
        component.find("recordViewForm").submit();
    },
    handleSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        component.set("v.recordId",payload.id);
    },
    setDefaultValues : function(component, event, helper) {
      var obj = component.get("v.defaultValues");
        if(!$A.util.isUndefinedOrNull(obj)){
            var renderedFields = component.find("input_field");
            for(var  x in renderedFields)
                if(obj.hasOwnProperty(renderedFields[x].get('v.fieldName')))
                    renderedFields[x].set("v.value",obj[renderedFields[x].get('v.fieldName')]); 
        }     
    },
})