({
    profile :function(cmp,event){
        var action = cmp.get("c.getProfileId");
        action.setCallback(this, function(response){
            var STATE=response.getState();
            if(STATE === "SUCCESS"){
                //cmp.set("v.profileId",response.getReturnValue().profId);
               
                var UserName=response.getReturnValue().name;
                if(UserName != "ERP Product catalog Community Site Guest User"){                  
                    cmp.set("v.PortalUser",true);
                }
                var acc=response.getReturnValue().acc;
                if(acc.Id != undefined){
                    cmp.set("v.AccId",acc.Id);
                    cmp.set("v.bodyTrue",true);
                }else{
                    cmp.set("v.bodyTrue",true);
                }
                
            }else{
                console.log('error :',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    /*beforeUnloadHandler : function(event) {
        //delete all cookies before close or when refresh
        var cookies = document.cookie.split(";");
        for (var i = 0; i < cookies.length; i++) {
            var cookie = cookies[i];
            var eqPos = cookie.indexOf("=");
            var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
            document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT";
        }
    },*/
})