({
    helperEvaluate : function(cmp) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var MPS = cmp.get("v.MPS");
        var action = cmp.get("c.Evaluates");
        var MPSS = JSON.stringify(MPS);
        console.log('MPSS : ',MPSS);
        action.setParams({ StrMPS : MPSS });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                try { 
                    console.log('res Evaluates : ',response.getReturnValue());
                    cmp.set("v.prevent", true);
                    cmp.set("v.MPS", response.getReturnValue());
                    cmp.set("v.Dirty", false);
                    cmp.set("v.Dirtys", true);
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
    getBOMS : function(cmp,event,helper){
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        console.log('getBOMS called');
        var version = cmp.get('v.MPS.MPS.ERP7__Version__c');
        console.log('version : ',version);
        if(version != null && version != undefined && version != ''){
            var action = cmp.get("c.getBomMPS");
            var MPSS = cmp.get("v.MPS.MPS");
            console.log('MPS : ',JSON.stringify(MPSS));
            action.setParams({ StrMPS : JSON.stringify(MPSS),versionId : version ,siteId : cmp.get('v.siteId')});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    try {
                        console.log('res getBomMPS : ',response.getReturnValue());
                        cmp.set("v.MPS", response.getReturnValue());
                        cmp.set("v.Dirty", false);
                        cmp.set("v.Dirtys", false);
                        cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                        cmp.set("v.prevent", true);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        helper.helperEvaluate(cmp);
                    } catch(err) {
                        cmp.set("v.exceptionError", err.message);
                        //alert("Exception : "+err.message);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }
                else{
                    console.log('error getBomMPS : ',response.getError());
                }
            });
            $A.enqueueAction(action);
            
        } 
    }
})