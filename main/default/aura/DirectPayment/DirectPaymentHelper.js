({
	showToast : function(type,title,Msg) {
        var toastEvt = $A.get("e.force:showToast");
        if(!$A.util.isUndefined(toastEvt)){
            toastEvt.setParams({"type":type,"title":title,"message":Msg});
            toastEvt.fire();
        }
	},
})