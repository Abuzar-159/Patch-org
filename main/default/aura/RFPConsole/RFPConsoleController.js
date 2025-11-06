({
    doInit : function(component, event, helper) {
        console.log('doInit called');
        component.set("v.donotsetRatingCompliance",false);
        helper.setSupRating(component, event, helper);
        helper.setSupCompliance(component, event, helper);
        if(component.get("v.requestId")!=null && component.get("v.requestId")!=undefined && component.get("v.requestId")!=''){
            //component.set("v.frominitial",true);
            helper.setRfpDetails(component, event, 0, -1,helper);
        }
        else{
            //component.set("v.frominitial",false);
           component.set("v.exceptionError", "No request available for suplier : "+ component.get("v.reqSupplierName"));
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.exceptionError","");
                    window.history.back();
                }), 5000
            );
        }
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    changedRequestId : function(component, event, helper) {
        if(component.get("v.reqSupplierId")!=null && component.get("v.reqSupplierId")!=undefined && component.get("v.reqSupplierId")!=''){
            console.log('doInit changedRequestId');
            helper.setRfpDetails(component, event, 0, -1,helper);
        }
    },
    //Parent CRUD.
    addNew : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
		var reqId = event.currentTarget.dataset.recordId;
		var reqIndex = event.currentTarget.dataset.index;
        var reqList = component.get("v.reqRequirements");
        var currentReq = [];
        if(currentReq != null && currentReq != undefined) currentReq = reqList[reqIndex];
        currentReq.ResPackList.push({sObjectType :'responseWrapper'});
        console.log('currentReq new JSON~>'+JSON.stringify(currentReq));
        reqList[reqIndex] = currentReq;
        component.set("v.reqRequirements",reqList);
        component.set("v.resetRandR", false);
        component.set("v.resetRandR", true);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    testmethods : function(component, event, helper) {
        console.log('here 123');
    },
    
    deleteRes : function(component, event, helper) {
        var reqId = event.currentTarget.dataset.reqId;//requirement Id.
		var reqIndex = event.currentTarget.dataset.reqIndex;//requirement Index.
		var resId = event.currentTarget.dataset.record;//response Id.
		var resIndex = event.currentTarget.dataset.index;//response Index.
        if(resId != null && resId != undefined && resId != ''){
            if(confirm("Are you sure ?")){
                console.log('here 1');
                helper.deleteResponse(component, event, reqId, reqIndex, resId, resIndex);
            }
        }
        else{
            console.log('here 2 new');
            var reqList=component.get("v.reqRequirements");
            var responseList = reqList[reqIndex].ResPackList;
            responseList.splice(resIndex, 1);
            reqList[reqIndex].ResPackList = responseList;
            console.log('respacklist JSON~>'+JSON.stringify(reqList[reqIndex]));
            component.set("v.reqRequirements", reqList);
            component.set("v.resetRandR", false);
            component.set("v.resetRandR", true);
            component.set("v.refresh", false);
            component.set("v.refresh", true);
        }
    },
    
    selectRequirement : function(component, event, helper) {
		var currentReqId = event.currentTarget.dataset.recordId;
		var currentReqIndex = event.currentTarget.dataset.index;
        var requirementsWrap = component.get("v.reqRequirements");
        var isopen = false;
        for (var y in requirementsWrap){
            requirementsWrap[y].isCurrentReq = false; 
        }
        requirementsWrap[currentReqIndex].isCurrentReq = true;
        component.set("v.reqRequirements", requirementsWrap);
    },
    //Parent CRUD End.
    
    //Child CRUD.
    addChNew : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var chReqIndex = event.currentTarget.dataset.index;//child requirement Index.
        var reqIndex = event.currentTarget.dataset.reqIndex;//parent requirement Index.
        var reqList = component.get("v.reqRequirements");
        var currentChReq = reqList[reqIndex].childReqs[chReqIndex];
        currentChReq.ResPackList.push({sObjectType :'responseWrapper'});
        reqList[reqIndex].childReqs[chReqIndex] = currentChReq;
        component.set("v.reqRequirements",reqList);
        component.set("v.resetRandR", false);
        component.set("v.resetRandR", true);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    deleteChRes : function(component, event, helper) {
		var reqIndex = event.currentTarget.dataset.reqIndex;//parent requirement Index.
		var chReqIndex = event.currentTarget.dataset.record;//child requirement Index.
		var chResIndex = event.currentTarget.dataset.index;//child response Index.
        var chResId = event.currentTarget.dataset.recordId;//child response Id.
        
        if(chResId != null && chResId != undefined && chResId != ''){
            if(confirm("Are you sure ?")){
                helper.deleteChResponse(component, event, reqIndex, chReqIndex, chResIndex, chResId);
            }
        }
        else{
            var reqList =[];
            reqList=component.get("v.reqRequirements");
            var responseList = reqList[reqIndex].childReqs[chReqIndex].ResPackList;
            responseList.splice(chResIndex, 1);
            reqList[reqIndex].childReqs[chReqIndex].ResPackList = responseList;
            component.set("v.reqRequirements", reqList);
            component.set("v.resetRandR", false);
            component.set("v.resetRandR", true);
        }
    },
    
    selectChRequirement : function(component, event, helper) {
        var currentReqId = event.currentTarget.dataset.recordId;
        var currentReqIndex = event.currentTarget.dataset.index;//child requirement Index.
        var reqIndex = event.currentTarget.dataset.reqIndex;//parent requirement Index.
        var requirementsWrap = component.get("v.reqRequirements");
        var isopen = false;        
        //to close opened req
        if(requirementsWrap[reqIndex].childReqs[currentReqIndex].isCurrentReq){
            requirementsWrap[reqIndex].childReqs[currentReqIndex].isCurrentReq = false;
            isopen = true;
        }
        //to open
        if(!isopen) {
            for (var y in requirementsWrap){
                for(var z in requirementsWrap[y].childReqs){
                    requirementsWrap[y].childReqs[z].isCurrentReq = false;
                } 
            }
            requirementsWrap[reqIndex].childReqs[currentReqIndex].isCurrentReq = true;
        }
        component.set("v.reqRequirements", requirementsWrap);
        //helper.setSupRating(component, event);
    },
    //Child CRUD End.
    
    saveallResponses : function(component, event, helper){
        try{
            var params = event.getParam('arguments');
            var isSubmitted = false
            if (params) {
                isSubmitted = params.param1;
            }
            var allReqs = component.get("v.reqRequirements");
            var allResponsess = [];
            var answerError = true;
            var childAnswerError = true;
            var reqNum = 0.0;
            console.log('reqs here');
            for (var i in allReqs){
                for(var j in allReqs[i].ResPackList){
                    //answerError = helper.validateResponseAnswer(component, event);
                    if(allReqs[i].ResPackList[j].Res.ERP7__Response_Answer__c == '' || allReqs[i].ResPackList[j].Res.ERP7__Response_Answer__c == undefined || allReqs[i].ResPackList[j].Res.ERP7__Response_Answer__c == null){
                        answerError = false;
                        break;
                    }
                }
                if(!answerError){
                    break;
                }
                for (var j in allReqs[i].childReqs){
                    if(allReqs[i].childReqs[j].ResPackList.length > 0){
                        for(var k in allReqs[i].childReqs[j].ResPackList){
                            //childAnswerError = helper.validateResponseAnswer(component, event);
                            childAnswerError = !(allReqs[i].childReqs[j].ResPackList[k].Res.ERP7__Response_Answer__c == '' || allReqs[i].childReqs[j].ResPackList[k].Res.ERP7__Response_Answer__c == undefined || allReqs[i].childReqs[j].ResPackList[k].Res.ERP7__Response_Answer__c == null);
                            if(!childAnswerError){
                                break;
                            }
                        }
                        if(!childAnswerError){
                            break;
                        }
                    }
                }
                if(!childAnswerError){
                    break;
                }
            }
            if(answerError && childAnswerError){
                for(var x in allReqs){
                    //parent respones.
                    for(var y in allReqs[x].ResPackList){
                        if(allReqs[x].ResPackList[y].Res.Id == undefined){
                            allReqs[x].ResPackList[y].Res.Name = allReqs[x].Req.Name + " - response"+parseInt(y+1).toString();
                            allReqs[x].ResPackList[y].Res.ERP7__Request__c = allReqs[x].Req.ERP7__Request__c;
                            allReqs[x].ResPackList[y].Res.ERP7__Request_Supplier__c = component.get("v.reqSupplierId");
                            allReqs[x].ResPackList[y].Res.ERP7__Requirement__c = allReqs[x].Req.Id;
                            //allReqs[x].ResPackList[y].Res.ERP7__Supplier__c = component.get("v.currentSupplier");
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
                                //allReqs[x].childReqs[y].ResPackList[z].Res.ERP7__Supplier__c = component.get("v.currentSupplier");
                            }
                            
                            allResponsess.push(allReqs[x].childReqs[y].ResPackList[z].Res);
                        }
                    }
                }
                console.log('allResponsess JSON~>'+JSON.stringify(allResponsess));
                if(allResponsess.length > 0) helper.saveResponses(component, event, allResponsess, isSubmitted, helper);
                else console.log('no responses list empty');
            }
            else{
                var exceptErr = "Please enter all response(s).";
                if(!answerError && !childAnswerError) exceptErr = "Please enter all response(s).";
                else if(!answerError) exceptErr = "Please enter all parent response(s).";
                    else if(!childAnswerError) exceptErr = "Please enter all child response(s).";
                component.set("v.exceptionError", exceptErr);
            }
        }catch(e){
            console.log('saveallResponses err~>'+e);
        }
    },
    
    openSubmitModal : function(component, event, helper){
        console.log('openSubmitModal called');
        component.set("v.showSubmitModal",true);
        //$A.util.addClass(component.find("mySubmitModal"),"slds-fade-in-open");
        //$A.util.addClass(component.find("mySubmitModalBackdrop"),"slds-backdrop_open");
    },
    
    submitRequests : function(component, event, helper){
        var allReqs = component.get("v.reqRequirements");
        var answerError = true;
        var uploadError = true;
        var childAnswerError = true;
        var childUploadError = true;
        var multiAnswerError = true;
        var reqNum = 0.0;
        var childReqNum = 0.0;
        for(var i in allReqs){
            //parent answer required.
            if(allReqs[i].Req.ERP7__Answer_Required__c){
                if(allReqs[i].ResPackList.length <= 0){
                    answerError = false;
                    reqNum = parseFloat(i)+1.0;
                }
            }
            //parent upload required.
            if(allReqs[i].Req.ERP7__Upload_Required__c){
                for(var j in allReqs[i].ResPackList){
                    //answerError = helper.validateResponseAnswer(component, event);
                    uploadError = !(allReqs[i].ResPackList[j].Att.Id == '' || allReqs[i].ResPackList[j].Att.Id == undefined || allReqs[i].ResPackList[j].Att.Id == null);
                    if(!uploadError){ 
                        reqNum = parseFloat(i)+1.0;
                        break;
                    }
                }
            }
            
            //child answer required.
            if(allReqs[i].childReqs.length > 0){
                for(var j in allReqs[i].childReqs){
                    if(allReqs[i].childReqs[j].Req.ERP7__Answer_Required__c){
                        if(allReqs[i].childReqs[j].ResPackList.length <= 0){
                            childAnswerError = false;
                            childReqNum = (parseFloat(i)+1.0)+((parseFloat(j)+1)*0.1);
                        }
                    }
                }
            }
            //child upload required.
            if(allReqs[i].childReqs.length > 0){
                for(var j in allReqs[i].childReqs){
                    if(allReqs[i].childReqs[j].Req.ERP7__Upload_Required__c){
                        for(var k in allReqs[i].childReqs[j].ResPackList){
                            //answerError = helper.validateResponseAnswer(component, event);
                            childUploadError = !(allReqs[i].childReqs[j].ResPackList[k].Att.Id == '' || allReqs[i].childReqs[j].ResPackList[k].Att.Id == undefined || allReqs[i].childReqs[j].ResPackList[k].Att.Id == null);
                            if(!childUploadError){ 
                                childReqNum = (parseFloat(i)+1.0)+((parseFloat(j)+1)*0.1);
                                break;
                            }
                        }
                    }
                }
            }
            if(!uploadError || !answerError || !childAnswerError || !childUploadError) break;
        }
        if(answerError && uploadError && childAnswerError && childUploadError){
            component.set("v.showSubmitModal",false);
            component.saveAll(true);
        }
        else{
            var errorMessage = "";
            if(!answerError && !uploadError && !childAnswerError && !childUploadError)
                errorMessage = "Please enter the required fields that are marked * of requirement no. "+reqNum+", "+childReqNum;
            if((!answerError || !uploadError) && (!childAnswerError || !childUploadError))
                errorMessage = "Please enter the required fields that are marked * of requirement no. "+reqNum+", "+childReqNum;
            if(!answerError && !uploadError)
                errorMessage = "Please enter the required fields that are marked * of requirement no. "+reqNum;
            if(!childAnswerError && !childUploadError)
                errorMessage = "Please enter the required fields that are marked * of requirement no. "+childReqNum;
            else if(!uploadError)
                errorMessage = "Please upload attachment to response(s) of requirement no. "+reqNum;
                else if(!answerError)
                    errorMessage = "Please provide response(s) of requirement no. "+reqNum;
                    else if(!childAnswerError)
                        errorMessage = "Please upload attachment to response(s) of child requirement no. "+childReqNum;
                        else if(!childUploadError)
                            errorMessage = "Please provide response(s) of child requirement no. "+childReqNum;
            component.set("v.exceptionError", errorMessage);
        }
        
    },
    
    closeSubmitModal : function(component, event, helper) {
        component.set("v.showSubmitModal",false);
        //$A.util.removeClass(component.find("mySubmitModal"),"slds-fade-in-open");
        //$A.util.removeClass(component.find("mySubmitModalBackdrop"),"slds-backdrop_open");
    },
    
    DeleteResAT: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        let reqIndex = -1;
        let childReqIndex = -1;
        let index = event.currentTarget.getAttribute("data-index");
        reqIndex=index;
        let Pindex = event.currentTarget.getAttribute("data-PIndex");
        childReqIndex=Pindex;
		var RecordId = event.currentTarget.dataset.recordId;
        if (confirm("Are you sure?")) {
            var action = component.get("c.DeleteAT");
            action.setParams({
                RAId : RecordId,
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS"){
                    component.set("v.serverSuccess","Attachment deleted Successfully.");
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.serverSuccess","");
                            //window.history.back();
                        }), 3000
                    );
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    var reqIndex = -1;
                    var childReqIndex = -1;
                    var req = component.get("v.reqRequirements");
                    for(var i in req){
                        if(req[i].isCurrentReq) reqIndex = i;
                        for(var j in req[i].childReqs){
                            if(req[i].childReqs[j].isCurrentReq) childReqIndex = j;
                        }
                    }
                    helper.setRfpDetails(component, event, reqIndex, childReqIndex,helper);
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
            
        } 
    },
    
    onFileUploaded : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        try{let ind = event.getSource().get('v.title');
            let reqIndex = -1;
            let childReqIndex = -1;
            const index = ind.split('-', 2);
            reqIndex = index[0];
            childReqIndex = index[1];
            let files = component.get("v.FileList");
            let file = files[0][0];
            let filek = JSON.stringify(file);
            let parentId = event.getSource().get("v.name");
            if (files && files.length > 0) {
               
                var totalRequestSize = 0; //
                for (var i = 0; i < files.length; i++) {
                    var fileSize = files[i].base64Data.length;
                    console.log('fileSize : ',fileSize);
                    // Check individual file size (max 5 MB)
                    if (fileSize > 2000000) { // 2 MB limit
                        helper.showToast('Error', 'error', 'File ' + filesDataToUpload[i].fileName + ' exceeds the 2 MB limit.');
                        return;
                    }
    
                    // Check total request size (max 6 MB)
                    totalRequestSize += fileSize;
                    console.log('totalRequestSize : ',totalRequestSize);
                    if (totalRequestSize > 6000000) { // 6 MB total request size limit
                        helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                        return;
                    }
                }
                let reader = new FileReader();
                reader.onloadend = function() {
                    let contents = reader.result;
                    let base64Mark = 'base64,';
                    let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                    let fileContents = contents.substring(dataStart);
                    
                    let action = component.get("c.uploadFile");
                    console.log('In here->1');
                    action.setParams({
                        parent: parentId,
                        fileName: file.name,
                        base64Data: encodeURIComponent(fileContents),
                        contentType: file.type
                    });
                    action.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            console.log('In here->2');
                            //helper.showToast('Success!','success','Attachment uploaded Successfully.');
                            component.set("v.serverSuccess","Attachment uploaded Successfully.");
                            /* setTimeout(
                                $A.getCallback(function() {
                                    component.set("v.serverSuccess","");
                                }), 3000
                            );*/
                            /*let reqIndex = -1;
                            let childReqIndex = -1;
                            let req = component.get("v.reqRequirements");
                            for(let i in req){
                                if(req[i].isCurrentReq) reqIndex = i;
                                for(let j in req[i].childReqs){
                                    if(req[i].childReqs[j].isCurrentReq) childReqIndex = j;
                                }
                            }*/
                            helper.setRfpDetails(component, event, reqIndex, childReqIndex,helper);
                            $A.util.addClass(component.find('mainSpin'), "slds-hide");
                            setTimeout($A.getCallback(function () {
                                console.log('setTimeout4'); 
                            }), 1000);
                        }
                        else{
                            $A.util.addClass(component.find('mainSpin'), "slds-hide");
                            setTimeout($A.getCallback(function () {
                                console.log('setTimeout3'); 
                            }), 1000);
                            let errors = response.getError();
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
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        setTimeout($A.getCallback(function () {
                            console.log('setTimeout1'); 
                        }), 1000);
                    });
                    $A.enqueueAction(action); 
                    setTimeout($A.getCallback(function () {
                        console.log('setTimeout2'); 
                }), 1000);
            }
            reader.readAsDataURL(file);
        }
        }catch(err){
            console.log("Error catch:",err);
        }
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    reRender : function(component, event, helper) { },
    
    searchQuestion : function(component, event, helper){
        if(event.which == 13){
            var currentText = component.get("v.searchQuestionStr");
            if(currentText != null && currentText != undefined && currentText != "")
                helper.getSearchQuestions(component, event, currentText);
        }
        if(event.which == undefined)
            if(component.get("v.searchQuestionStr") == null || component.get("v.searchQuestionStr") == undefined || component.get("v.searchQuestionStr") == "")
                component.set("v.currentFAQs", component.get("v.allFAQs"));
    },
    
    tab1 : function(component, event, helper){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.RFPTab",true);
        component.set("v.RandRTab",false);
        component.set("v.FAQsTab",false);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
                      
    tab2 : function(component, event, helper){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.RFPTab",false);
        component.set("v.RandRTab", true);
        component.set("v.FAQsTab",false);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
                      
    tab3 : function(component, event, helper){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.RFPTab", false);
        component.set("v.RandRTab", false);
        component.set("v.FAQsTab", true);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    navBack : function(component, event, helper){
        if(component.get("v.RFPnav") == 'supplierRFPs'){
            $A.createComponent("c:SupplierRequests",{
                currentSupplier : component.get("v.reqSupplier.ERP7__Supplier__c"),
                temp : true
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("RFPbody");
                    body.set("v.body", newCmp);
                }
                else{
                    console.log("err -> ",errorMessage);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            /*var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:SupplierRequests",
                componentAttributes: {
                    currentSupplier : component.get("v.reqSupplier.ERP7__Supplier__c"),
                    temp : true
                }
            });
            evt.fire();*/
        }
        else{
            window.history.back();
        }
    },
    
    closeSuccess : function(component, event, helper){
        component.set("v.serverSuccess","");
    },
    
    closeError : function(component, event, helper){
        component.set("v.exceptionError","");
    }
})