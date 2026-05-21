({
    doInit : function(component, event, helper) {
        if(component.get("v.requestId")!=null && component.get("v.requestId")!=undefined && component.get("v.requestId")!=''){
            helper.setRfpDetails(component, event, 0, -1);
            helper.setRating(component, event);
            helper.setCompliance(component, event);
        }
        else{
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            component.set("v.exceptionError", "No request available for suplier : "+ component.get("v.reqSupplierName"));
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.exceptionError","");
                    window.history.back();
                    
                }), 5000
            );
        }
    },
    
    //Parent.
    selectRequirement : function(component, event, helper) {
		var currentReqId = event.currentTarget.dataset.recordId;
		var currentReqIndex = event.currentTarget.dataset.index;
        var requirementsWrap = component.get("v.reqRequirements");
        var isopen = false;
        //to close opened req
        if(requirementsWrap[currentReqIndex].isCurrentReq){
            requirementsWrap[currentReqIndex].isCurrentReq = false
            isopen = true;
        }
        //to open
        if(!isopen) {
            for (var y in requirementsWrap){
                requirementsWrap[y].isCurrentReq = false; 
            }
            requirementsWrap[currentReqIndex].isCurrentReq = true;
        }
        component.set("v.reqRequirements", requirementsWrap);
        //helper.setSupRating(component, event);
    },
    //Parent End.
    
    //Child.
    selectChRequirement : function(component, event, helper) {
        
        var currentReqId = event.currentTarget.dataset.recordId;
        
        var currentReqIndex = event.currentTarget.dataset.index;//child requirement Index.
        
        var reqIndex = event.currentTarget.dataset.reqIndex;//parent requirement Index.
        
        var reqsWrap = component.get("v.reqRequirements");
        
        var isopen = false;        
        //to close opened req
        if(reqsWrap[reqIndex].childReqs[currentReqIndex].isCurrentReq){
            reqsWrap[reqIndex].childReqs[currentReqIndex].isCurrentReq = false;
            isopen = true;
        }
        //to open
        if(!isopen) {
            for (var y in reqsWrap){
                for(var z in reqsWrap[y].childReqs){
                    reqsWrap[y].childReqs[z].isCurrentReq = false;
                } 
            }
            reqsWrap[reqIndex].childReqs[currentReqIndex].isCurrentReq = true;
        }
        var requirementsWrap = reqsWrap;
        component.set("v.reqRequirements", requirementsWrap);
        //helper.setSupRating(component, event);
    },
    //Child End.
    
    saveallResponses : function(component, event, helper){
        var isSubmitted = false;
        var allReqs = component.get("v.reqRequirements");
        var allResponsess = [];
        for(var x in allReqs){
            //parent respones.
            for(var y in allReqs[x].ResPackList){
                if(allReqs[x].ResPackList[y].Res.Id == undefined){
                    allReqs[x].ResPackList[y].Res.Name = allReqs[x].Req.Name + " - response"+y;
                    allReqs[x].ResPackList[y].Res.ERP7__Request__c = allReqs[x].Req.ERP7__Request__c;
                    allReqs[x].ResPackList[y].Res.ERP7__Request_Supplier__c = component.get("v.reqSupplierId");
                    allReqs[x].ResPackList[y].Res.ERP7__Requirement__c = allReqs[x].Req.Id;
                }
                allResponsess.push(allReqs[x].ResPackList[y].Res);
            }
            //child respones.
            for(var y in allReqs[x].childReqs){
                for(var z in allReqs[x].childReqs[y].ResPackList){
                    if(allReqs[x].childReqs[y].ResPackList[z].Res.Id == undefined){
                        allReqs[x].childReqs[y].ResPackList[z].Res.ERP7__Request__c = allReqs[x].childReqs[y].Req.ERP7__Request__c;
                        allReqs[x].childReqs[y].ResPackList[z].Res.ERP7__Request_Supplier__c = component.get("v.reqSupplierId");
                        allReqs[x].childReqs[y].ResPackList[z].Res.ERP7__Requirement__c = allReqs[x].childReqs[y].Req.Id;
                    }
                    
                    allResponsess.push(allReqs[x].childReqs[y].ResPackList[z].Res);
                }
            }
        }
        helper.saveResponses(component, event, allResponsess, isSubmitted);
    },
    
    navSupplier : function(component, event, helper){
        if(component.get("v.isCompare"))
            location.reload();
        else
            window.history.back();
        /*var recordId = component.get("v.reqSupplierId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();*/
    },
    
    closeSuccess : function(component, event, helper){
        component.set("v.serverSuccess","");
    },
    
    closeError : function(component, event, helper){
        component.set("v.exceptionError","");
    }
})