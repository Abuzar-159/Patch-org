({
	showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }else{
            sforce.one.showToast({
                "title": title,
                "message": message,
                "type": type
            });
        }
        
    },
    
    /*showToast : function(type,title,Msg) {
        var toastEvt = $A.get("e.force:showToast");
        if(!$A.util.isUndefined(toastEvt)){
            toastEvt.setParams({"type":type,"title":title,"message":Msg});
            toastEvt.fire();
        }
	},*/
})