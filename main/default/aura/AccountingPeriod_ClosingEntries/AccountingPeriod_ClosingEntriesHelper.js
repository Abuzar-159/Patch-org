({
    getRE : function(component,event) {
        var REAction = component.get("c.FetchRetainedEarnings");
        REAction.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                
                if(!$A.util.isEmpty(response.getReturnValue())){
                    component.set("v.RE_COA",response.getReturnValue());
                   
                }
            }
        });
        $A.enqueueAction(REAction);
    }
})