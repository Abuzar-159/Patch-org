({
    setRfpDetails : function(component, event, reqIndex, resIndex,helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        try{
        let action = component.get("c.fetchAllDetails");
        console.log('RSId~>'+component.get("v.reqSupplierId"));
        action.setParams({
            RSId  : component.get("v.reqSupplierId"),
            //reqId : component.get("v.requestId")
            isEvaluate : false
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                if(response.getReturnValue().errorMsg == ''){
                    console.log('setRfpDetails json~>'+JSON.stringify(response.getReturnValue()));
                    component.set("v.RFPWrap", response.getReturnValue());
                    //rfp page.
                    component.set("v.reqSupplier", response.getReturnValue().reqSupplier);
                    component.set("v.request", response.getReturnValue().request);
                    component.set("v.reqContactList", response.getReturnValue().reqContact);
                    component.set("v.reqAttachment", response.getReturnValue().rfpAttact);
                    console.log('Attachments rfpAttact only~>',response.getReturnValue().rfpAttact);
                    
                    //requestandResponse Page.
                    component.set("v.reqRequirements", response.getReturnValue().rfpRequirements);
                    console.log('RS responses length~>'+response.getReturnValue().RFPResslength);
                    console.log('reqRequirements length~>'+response.getReturnValue().rfpRequirements.length);
                    console.log('reqRequirements JSON~>'+JSON.stringify(response.getReturnValue().rfpRequirements));
                    try{
                        let reqs = component.get("v.reqRequirements");
                        if(reqs.length > 0 && reqIndex != null && reqIndex != undefined){
                            if(reqIndex >= 0){
                                reqs[reqIndex].isCurrentReq = true;
                                if(resIndex != null && resIndex != undefined){
                                    if(resIndex >= 0){
                                        reqs[reqIndex].childReqs[resIndex].isCurrentReq = true;
                                    }
                                }
                            }
                            component.set("v.reqRequirements", reqs);
                        }
                        else{
                            component.set("v.exceptionError", "No requirements available.");
                        }
                    }catch(e){
                        console.log('error here~>'+e);
                    }
                    //FAQ page.
                    component.set("v.assignFAQsList", response.getReturnValue().FAQAssigns);
                    component.set("v.allFAQs", response.getReturnValue().FAQs);
                    component.set("v.currentFAQs", response.getReturnValue().FAQs);
                    console.log('FAQS length~>'+response.getReturnValue().FAQs.length);
                    component.set("v.refresh", false);
                    component.set("v.refresh", true);
                }
                else{
                    component.set("v.exceptionError",response.getReturnValue().errorMsg);
                    component.set("v.allowReq",false);
                    /*setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                            component.backMethod();
                        }), 5000
                    );*/
                }
                
            }
            else{
                let errors = response.getError();
                console.log("err fetchAllDetails -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        /*setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );*/
                        
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        /*setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );*/
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    /*setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );*/
                }
            }
            if(component.get("v.donotsetRatingCompliance")==false){
            //this.setSupRating(component, event,helper);
            //this.setSupCompliance(component, event,helper); 
            }
            component.set("v.showSpinner",false);
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
        setTimeout($A.getCallback(function () {
                console.log('setTimeout'); 
        }), 1000);}
    catch(err){
            console.log("Error catch:",err);
        }
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    setSupRating : function(component, event,helper) {
        console.log('setSupRating called');
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchSupRating");
        action.setCallback(this, function(response) {
            console.log('fetchSupRating state~>'+response.getState());
            if(response.getState() === "SUCCESS"){
                console.log("fetchSupRating resp-> ", JSON.stringify(response.getReturnValue()));
                component.set("v.resRatingOptions",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("err fetchSupRating -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    setSupCompliance : function(component, event,helper) {
        console.log('setSupCompliance called');
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchSupCompliance");
        action.setCallback(this, function(response) {
            console.log('fetchSupCompliance state~>'+response.getState());
            if(response.getState() === "SUCCESS"){
                console.log("fetchSupCompliance resp-> ", JSON.stringify(response.getReturnValue()));
                component.set("v.resComplianceOptions",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("err fetchSupCompliance -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    deleteResponse : function(component, event, reqId, reqIndex, resId, resIndex){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.delete_Response");
        action.setParams({
            responseId : resId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.serverSuccess","Response deleted Successfully");
                setTimeout($A.getCallback(function() { component.set("v.serverSuccess",""); }), 3000 );
                console.log('here deleted');
                // this.setRfpDetails(component, event, 0, -1);
                var reqList = []; reqList = component.get("v.reqRequirements");
                var responseList = []; if(reqList.length > 0) responseList = reqList[reqIndex].ResPackList;
                console.log('b4 responseList~>'+JSON.stringify(responseList));
                console.log('b4 responseList length~>'+responseList.length);
                if(responseList.length > 0) responseList.splice(resIndex, 1);
                responseList.splice(resIndex, 1); //newline added
                console.log('after responseList~>'+JSON.stringify(responseList));
                console.log('after responseList length~>'+responseList.length);
                if(reqList.length > 0 && responseList.length > 0) reqList[reqIndex].ResPackList = responseList;
                if(reqList.length > 0){
                    console.log('after 2 reqList~>'+JSON.stringify(reqList[reqIndex]));
                    console.log('after 2 reqList length~>'+reqList[reqIndex].ResPackList.length);
                }
                component.set("v.reqRequirements", reqList);
                component.set("v.resetRandR", false);
                component.set("v.resetRandR", true);
                
                /* var reqList =[];
                reqList=component.get("v.reqRequirements");
                var currentReq = reqList[reqIndex];
                var responseList = reqList[reqIndex].ResPackList;
                responseList.splice(resIndex, 1);
                reqList[reqIndex].ResPackList = responseList;
                component.set("v.reqRequirements", reqList);
                component.set("v.resetRandR", false);
                component.set("v.resetRandR", true); */
                component.set("v.refresh", false);
                component.set("v.refresh", true);
            }
            else{
                var errors = response.getError();
                console.log('errors~>'+errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                        
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    //child delete
    deleteChResponse : function(component, event, reqIndex, chReqIndex, chResIndex, chResId){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.delete_Response");
        action.setParams({
            responseId : chResId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.serverSuccess","Child Response deleted Successfully");
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.serverSuccess","");
                    }), 3000
                );
                
                var reqList =[];
                reqList=component.get("v.reqRequirements");
                var responseList = reqList[reqIndex].childReqs[chReqIndex].ResPackList;
                responseList.splice(chResIndex, 1);
                reqList[reqIndex].childReqs[chReqIndex].ResPackList = responseList;
                component.set("v.reqRequirements", reqList);
                component.set("v.resetRandR", false);
                component.set("v.resetRandR", true);
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                        
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    saveResponses : function(component, event, allResponsess, isSubmitted, helper){
        console.log('saveResponses helper called',allResponsess);
        for(var x in allResponsess){
            allResponsess[x].ERP7__Supplier__c = component.get('v.currentSupplier');
        }
        console.log('allResponsess after',allResponsess);
        console.log('currentSupplier',component.get("v.currentSupplier"));
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.save_reqResponses");
        action.setParams({
            allRess : JSON.stringify(allResponsess),
            isSubmit : isSubmitted,
            rfpSupp : JSON.stringify(component.get("v.reqSupplier"))
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('resp success~>'+JSON.stringify(response.getReturnValue()));
                //get opened index.
                var reqIndex = -1;
                var childReqIndex = -1;
                var req = component.get("v.reqRequirements");
                for(var i in req){
                    if(req[i].isCurrentReq) reqIndex = i;
                    for(var j in req[i].childReqs){
                        if(req[i].childReqs[j].isCurrentReq) childReqIndex = j;
                    }
                }
                if(reqIndex == -1) reqIndex = 0;
                console.log('this.setRfpDetails calling reqIndex~>'+reqIndex+' childReqIndex~>'+childReqIndex);
                component.set("v.donotsetRatingCompliance",true);
                this.setRfpDetails(component, event, reqIndex, childReqIndex,helper);
                if(isSubmitted){
                    component.set("v.serverSuccess","Responses Submitted Successfully");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.serverSuccess","");
                        }), 3000
                    );                   
                }
                else{ 
                    component.set("v.serverSuccess","Responses Captured Successfully");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.serverSuccess","");
                        }), 3000
                    );
                }
            }
            else{
                var errors = response.getError();
                console.log('error resp~>'+errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                        
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    validateResponseAnswer : function(component, event){
        var NOerrors = true;
        var resAnswer = component.find("responseAnswer");
        if(!$A.util.isUndefined(resAnswer) || !$A.util.isEmpty(resAnswer))
            NOerrors =  this.checkValidationField(projName);
        return NOerrors;
    },
    
    checkValidationField : function(cmp){
        if($A.util.isEmpty(cmp.get("v.value"))){
            cmp.set("v.class","hasError");
            return false;
        }else{
            cmp.set("v.class","");
            return true;
        }
        
    },
    
    getSearchQuestions : function(component, event, currentText){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.fetchFAQs");
        action.setParams({
            FAQList : JSON.stringify(component.get("v.allFAQs")),
            searchStr : currentText
        });
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS"){
                component.set("v.currentFAQs", response.getReturnValue());
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 3000
                    );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    reRender : function(component, event, helper) { },
    
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
        }
    }
})