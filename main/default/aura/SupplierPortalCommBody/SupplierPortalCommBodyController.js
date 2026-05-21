({
	eventHandle :function(cmp, event, helper){
        if(event.getParam("AccId") != undefined)
        	cmp.set("v.AccId",event.getParam("AccId"));
        //if(event.getParam("catSel") != undefined && event.getParam("catSel") != "")
          //  cmp.set("v.catSel",event.getParam("catSel"));
        
      
        if(event.getParam("viewHome")){
            $A.createComponent( "c:SupplierPortalCommHome", {
                    "AccId":cmp.get("v.AccId"),    
                    //"cartProducts":cmp.get("v.cartItems")
                },
                function(newCmp) {
                    if (cmp.isValid()) {
                        var body = cmp.find("sldshide");
                        body.set("v.body", newCmp);        
                    }
                }
            );
        } 
    },
    initial :function(cmp,event,helper){
        helper.profile(cmp,event);
    },
    
})