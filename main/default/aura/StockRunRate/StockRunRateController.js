({
	getAllDetails : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.getAllInitial");
        action.setParams({ ProductName : cmp.get("v.SearchStr"),
                          StartDate : cmp.get("v.StartDate"),
                          EndDate : cmp.get("v.EndDate") ,
                          siteId : cmp.get("v.siteId")
                         
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('init state : ',state);
            if (state === "SUCCESS") {  
                try {  
                	
                    console.log('init response : ',response.getReturnValue());
                    cmp.set("v.MPS", response.getReturnValue());
                    cmp.set("v.mpsStatusOptions",response.getReturnValue().mpsStatus);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    cmp.set("v.StartDate",response.getReturnValue().StartDate);
                    cmp.set("v.EndDate",response.getReturnValue().EndDate);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
            else{
                console.log('Error init : ',response.getError());
            }
        });
        $A.enqueueAction(action);
        /*var action = cmp.get("c.getAllStockRunRate");
        action.setParams({ currentMPS : "", IsNew : "true", onLoad : true });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                try {  
                	cmp.set("v.MPS", response.getReturnValue());
                    console.log('init response : ',response.getReturnValue());
                    //cmp.set("v.MPSHolder", response.getReturnValue());
                    //cmp.find("mpsStatus").set("v.options", response.getReturnValue().mpsStatus); 
                    cmp.set("v.mpsStatusOptions",response.getReturnValue().mpsStatus);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action); */
    },
    
    loadAllDetails : function(cmp, event, helper) {
        var proceed = cmp.get("v.proceed");
        //alert();
        window.scrollTo(0, 0);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var curMPS = cmp.get("v.MPS");
        console.log('curMPS : ',JSON.stringify(curMPS));
        var action = cmp.get("c.getAllStockRunRate");
        action.setParams({ currentMPS : JSON.stringify(curMPS), IsNew : "false", onLoad : false });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    cmp.set("v.MPS.MPSS", response.getReturnValue().MPSS);
                    console.log('getAllStockRunRate res : ',response.getReturnValue());
                    //cmp.set("v.MPSHolder.MPSS", response.getReturnValue().MPSS);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    loadDetails : function(cmp, event, helper) {
        cmp.popInit();
       /* var proceed = cmp.get("v.proceed");
        //alert();
        window.scrollTo(0, 0);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var curMPS = cmp.get("v.MPS");
        var action = cmp.get("c.getAllStockRunRateOnDate");
        action.setParams({ currentMPS : JSON.stringify(curMPS), IsNew : "false"});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    cmp.set("v.MPS.MPSS", response.getReturnValue().MPSS);
                    console.log('getAllStockRunRateOnDate res : ',response.getReturnValue());
                    //cmp.set("v.MPSHolder.MPSS", response.getReturnValue().MPSS);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);*/
    },
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    navigateToMyComponent : function(component, event, helper) {
        var RecId = event.getSource().get("v.title");
        console.log('RecId : ',RecId);
        if(RecId != '' && RecId != null && RecId != undefined){
            let prodlist = component.get("v.MPS.ProdList");
            var prodDetails = {};
            for(var x in prodlist){
                if(prodlist[x].Prod.Id == RecId){
                    console.log('match');
                    prodDetails = prodlist[x];
                }
            }
            console.log('prodDetails : ',JSON.stringify(prodDetails));
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:MPS_AT",
                componentAttributes: {
                    ProdId : RecId,
                    SelectedProduct : prodDetails,
                    SRR : "true",
                    onloadDate : component.get("v.StartDate"), //component.get("v.MPS.InitialDate"),
                    siteId : component.get("v.siteId")
                }
            });
            evt.fire();
        }
        
    },
    
    
    NavMPS : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/apex/ERP7__MPS_AT?SRR=true&MPSId=" + RecId +"&loadingdate="+component.get("v.MPS.InitialDate");//+"&loadingdate="+component.get("v.MPS.InitialDate")
        //window.open(RecUrl,'_self');
        $A.get("e.force:navigateToURL").setParams(
    	{"url": RecUrl}).fire();
    },
    
    handleComponentEvent : function(cmp,event,helper){
		var searchString = event.getParam("searchString");
        console.log('searchString : ',searchString);
        var MPSS = cmp.get("v.MPS.MPSS");
         console.log('MPSS : ',MPSS);
        if(searchString.length>0){
            console.log('IN  ');
            MPSS = MPSS.filter(function (el) {
                return (el.searchString.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
            });
            cmp.set("v.MPS.MPSS",MPSS);
        } else{
            cmp.loadInit();
        }
    }
})