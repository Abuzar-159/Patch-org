({
	profile :function(cmp,event){
        var UserName;
        var action = cmp.get("c.getProfileId");
        action.setCallback(this, function(response){
            var STATE=response.getState();
            if(STATE === "SUCCESS"){
                var UserName = response.getReturnValue().name;
                if(UserName != "ERP Supplier Portal Community Site Guest User"){
                    cmp.set("v.PortalUser",true);    
                }
                var acc=response.getReturnValue().acc;
                if(acc.Id != undefined){
                    cmp.set("v.AccId",acc.Id);
                    cmp.set("v.bodyTrue",true);
                }else{
                    cmp.set("v.bodyTrue",true);
                }
               //component.set("v.Spinner", false); 
            }
        });
        $A.enqueueAction(action);
    },
})