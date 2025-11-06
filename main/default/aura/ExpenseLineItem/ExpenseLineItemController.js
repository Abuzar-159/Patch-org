({
    doInit: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        helper.setExpenseCategory(component, event);
        if(component.get("v.isSetCategory"))
            helper.setExpenseType(component, event);
        /*var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);*/
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        
        var expli1 = component.get("v.expli");
        var expl = component.get("v.expliiret");
        if(expl === true) {
           var expli1 = component.get("v.expli"); 
            var actionNew = component.get("c.getCOA");
                actionNew.setParams({
                    ExplineId : expli1.Id
                });
                actionNew.setCallback(this, function(response) {
                    if(response.getState() === "SUCCESS"){
                        component.set("v.expli.ERP7__Chart_Of_Account__c", response.getReturnValue());
                        console.log("COA", response.getReturnValue());
                    }
                });
                $A.enqueueAction(actionNew);
        }
        for(var i=0; i<expli1.length; i++){
            if((component.get("v.aItem.ExpLI.ERP7__Chart_Of_Account__c")==undefined || component.get("v.aItem.ExpLI.ERP7__Chart_Of_Account__c")==null) && expli1[i].Id == component.get("v.aItem.ExpLI.Id")){
                var actionNew = component.get("c.getCOA");
                actionNew.setParams({
                    ExplineId : expli1[i].Id
                });
                actionNew.setCallback(this, function(response) {
                    if(response.getState() === "SUCCESS"){
                        component.set("v.aItem.ExpLI.ERP7__Chart_Of_Account__c", response.getReturnValue());
                    }
                });
                $A.enqueueAction(actionNew);
            }
        }
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    
    addNew : function(component, event, helper) {
        var expList = component.get("v.expli");
        expList.unshift({sObjectType :'ERP7__Expense_Line_Item__c'});
        component.set("v.expli", expList);
    },
    
    deleteExpliWp : function(component, event, helper){
        var ind = component.get("v.index");
        var expWrp = component.get("v.expenseWrap1");
       
        try{
            if(expWrp[ind].ExpLI == undefined || expWrp[ind].ExpLI.Id == 'undefined') {
                var e = $A.get("e.c:IndexingEvent");
                e.setParams({
                    "Index" : component.get("v.index")
                })
                e.fire();
            }
            else {
                helper.deleteCurExpli(component, event, expWrp[ind].ExpLI);
            }
            
        } catch (ex) {}
    },
    
    
    closeError : function (cmp, event) {
        cmp.set("v.exceptionError",'');
    },
    
    /*onFileUploadedAK : function(cmp, event, helper) {
        var files = cmp.get("v.FileList");  
        var file = files[0][0];
        var filek = JSON.stringify(file);
        var parentId = event.getSource().get("v.name");
        if (files && files.length > 0) {
             var totalRequestSize = 0;

        for (var i = 0; i < files.length; i++) {
            var fileSize = files[i][0].size;

            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + files[i][0].name + ' exceeds the 2 MB limit.');
                return;
            }

            totalRequestSize += fileSize;

            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                return;
            }
        }
            var reader = new FileReader();
            reader.onloadend = function() {
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var contents = reader.result;
                var base64Mark = 'base64,';
                var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                var fileContents = contents.substring(dataStart);
                
                var action = cmp.get("c.uploadFileAK");
               
                action.setParams({
                    parent: parentId,
                    fileName: file.name,
                    base64Data: encodeURIComponent(fileContents),
                    contentType: file.type
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().exceptionError == '') {
                            var obj = cmp.get("v.expenseWrap1");
                            for(var x in obj){
                                if(obj[x].ExpLI.Id == parentId){
                                    obj[x].Attach = response.getReturnValue().Attach;
                                    break;
                                }
                            }
                            cmp.set("v.expenseWrap1",obj);
                        }        
                        cmp.set("v.exceptionError",response.getReturnValue().exceptionError); 
                        //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //var uscroll = document.getElementById(parentId);
                        //uscroll.scrollIntoView();
                    } 
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action); 
            }
            reader.readAsDataURL(file);
        }
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },*/
      onFileUploadedAK : function(cmp, event, helper) {
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//7
        cmp.set("v.showSpinner",true);
        try{
            let files = cmp.get("v.FileList");  
             var totalRequestSize = 0;
            for (let i = 0; i < files[0].length; i++) {
                let file = files[0][i];
               
    // Validate individual file size (max 2 MB) before processing
    if (file.size > 2000000) {
        helper.showToast("Error", "error", "File " + file.name + " exceeds the 2 MB limit.");
        cmp.set("v.showSpinner", false);
        return; // Skip processing for this file
    }
             totalRequestSize += file.size;
console.log("totalRequestSize",totalRequestSize);
            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                cmp.set("v.showSpinner", false);
                return;
            }}
console.log('FileList : ', JSON.stringify(FileList));
            let fileNameList = [];
            let base64DataList = [];
            let contentTypeList = [];
            
            if (files && files.length > 0) {
                let parentId = event.getSource().get("v.name");
                console.log('files : ',files.length);
                console.log('files[0] : ',files[0].length);
                if(files[0].length > 0){
                    for (let i = 0; i < files[0].length; i++) {
                         var totalRequestSize = 0;

       /* for ( i = 0; i < files.length; i++) {
            var fileSize = files[i][0].size;

            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + files[i][0].name + ' exceeds the 2 MB limit.');
                return;
            }

            totalRequestSize += fileSize;

            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                return;
            }
        }*/
                        console.log('i~>'+i);
                        let file = files[0][i];
                        let reader = new FileReader();
                        //reader.onloadend is asynchronous using let instead of var inside for loop arshad 
                        reader.onloadend = function() {
                            
                            console.log('inside reader.onloadend');
                            let contents = reader.result;
                            let base64Mark = 'base64,';
                            let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                            let fileContents = contents.substring(dataStart);
                           
                            
                            fileNameList.push(file.name);
                            base64DataList.push(encodeURIComponent(fileContents));
                            contentTypeList.push(file.type);

                            
                            console.log('fileNameList~>'+fileNameList.length);
                            console.log('base64DataList~>'+base64DataList.length);
                            console.log('contentTypeList~>'+contentTypeList.length);
                            
                            if(fileNameList.length == files[0].length){
                            helper.finishAllFilesUpload(parentId,fileNameList,base64DataList,contentTypeList,cmp,event,helper);
                            }else console.log('notequal');
                        }
                        reader.onerror = function() {
                            console.log('for i~>'+i+' err~>'+reader.error);
                            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//8
                            cmp.set("v.showSpinner",false);
                        };
                        reader.readAsDataURL(file);
                    }
                }
            }
        }catch(err){
            console.log("Error catch:",err);
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//9
            cmp.set("v.showSpinner",false);
        }
        
    },
    /*onFileUploadedAKMulti : function(cmp, event, helper) {
        var files = cmp.get("v.FileList");  
        var file = files[0][0];
        var filek = JSON.stringify(file);
        var parentId = event.getSource().get("v.name");
        console.log("Outside file");
        if (files && files.length > 0) {
             var totalRequestSize = 0;

        for (var i = 0; i < files.length; i++) {
            var fileSize = files[i][0].size;

            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + files[i][0].name + ' exceeds the 2 MB limit.');
                return;
            }

            totalRequestSize += fileSize;

            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                return;
            }
        }
            console.log("Inside file");
            var reader = new FileReader();
            reader.onloadend = function() {
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var contents = reader.result;
                var base64Mark = 'base64,';
                var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                var fileContents = contents.substring(dataStart);
                
                var action = cmp.get("c.uploadFileAK");
               
                action.setParams({
                    parent: parentId,
                    fileName: file.name,
                    base64Data: encodeURIComponent(fileContents),
                    contentType: file.type
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().exceptionError == '') {
                            console.log("response", response.getReturnValue().Attach);
                            var obj = cmp.get("v.expenseWrap1");
                            for(var i in obj){ 
                                for(var j in obj[i].expline){
                                    obj[i].expline[j].Attach='';
                                }
                            }
                            cmp.set("v.expenseWrap1",obj);
                            console.log("bfr attch allexpenceitems", obj);
                            var allexpenceitems=[];
                            for(var i in obj){ 
                                for(var j in obj[i].expline){
                                    allexpenceitems.push(obj[i].expline[j]);
                                }
                            }
                             console.log("allexpenceitems", allexpenceitems);
                            for(var x in allexpenceitems){
                                if(allexpenceitems[x].Id == parentId){
                                    allexpenceitems[x].Attach = response.getReturnValue().Attach;
                                    break;
                                }
                            }
                            console.log("after attch allexpenceitems", allexpenceitems);
                            for(var i in obj){ 
                                for(var j in obj[i].expline){
                                    obj[i].expline[j].Attach=response.getReturnValue().Attach;
                                }
                            }
                            console.log("after attch obj", obj);
                            cmp.set("v.expenseWrap1",obj);
                           
                        }        
                        cmp.set("v.exceptionError",response.getReturnValue().exceptionError); 
                        //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //var uscroll = document.getElementById(parentId);
                        //uscroll.scrollIntoView();
                    } 
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action); 
            }
            reader.readAsDataURL(file);
        }
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },*/
      onFileUploadedAKMulti : function(cmp, event, helper) {
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//7
        cmp.set("v.showSpinner",true);
        try{
            let files = cmp.get("v.FileList");  
             var totalRequestSize = 0;
            for (let i = 0; i < files[0].length; i++) {
                let file = files[0][i];
               
    // Validate individual file size (max 2 MB) before processing
    if (file.size > 2000000) {
        helper.showToast("Error", "error", "File " + file.name + " exceeds the 2 MB limit.");
        cmp.set("v.showSpinner", false);
        return; // Skip processing for this file
    }
             totalRequestSize += file.size;
console.log("totalRequestSize",totalRequestSize);
            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                cmp.set("v.showSpinner", false);
                return;
            }}
console.log('FileList : ', JSON.stringify(FileList));
            let fileNameList = [];
            let base64DataList = [];
            let contentTypeList = [];
            
            if (files && files.length > 0) {
                let parentId = event.getSource().get("v.name");
                console.log('files : ',files.length);
                console.log('files[0] : ',files[0].length);
                if(files[0].length > 0){
                    for (let i = 0; i < files[0].length; i++) {
                         var totalRequestSize = 0;

       /* for ( i = 0; i < files.length; i++) {
            var fileSize = files[i][0].size;

            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + files[i][0].name + ' exceeds the 2 MB limit.');
                return;
            }

            totalRequestSize += fileSize;

            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                return;
            }
        }*/
                        console.log('i~>'+i);
                        let file = files[0][i];
                        let reader = new FileReader();
                        //reader.onloadend is asynchronous using let instead of var inside for loop arshad 
                        reader.onloadend = function() {
                            
                            console.log('inside reader.onloadend');
                            let contents = reader.result;
                            let base64Mark = 'base64,';
                            let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                            let fileContents = contents.substring(dataStart);
                           
                            
                            fileNameList.push(file.name);
                            base64DataList.push(encodeURIComponent(fileContents));
                            contentTypeList.push(file.type);

                            
                            console.log('fileNameList~>'+fileNameList.length);
                            console.log('base64DataList~>'+base64DataList.length);
                            console.log('contentTypeList~>'+contentTypeList.length);
                            
                            if(fileNameList.length == files[0].length){
                            helper.finishAllFilesUpload(parentId,fileNameList,base64DataList,contentTypeList,cmp,event,helper);
                            }else console.log('notequal');
                        }
                        reader.onerror = function() {
                            console.log('for i~>'+i+' err~>'+reader.error);
                            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//8
                            cmp.set("v.showSpinner",false);
                        };
                        reader.readAsDataURL(file);
                    }
                }
            }
        }catch(err){
            console.log("Error catch:",err);
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//9
            cmp.set("v.showSpinner",false);
        }
        
    },
    
    DeleteRecordAT: function(cmp, event) {
        var result = confirm("Are you sure?");
        var RecordId = event.getSource().get("v.name");
        var ObjName = event.getSource().get("v.title");
        if (result) {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            //window.scrollTo(0, 0);
            //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
           if (!RecordId) {
    helper.showToast('Error', 'error', 'Record ID is missing or invalid.');
    return;
}
            try{
                var action = cmp.get("c.DeleteAT");
                action.setParams({
                    RAId: RecordId,
                    ObjName: ObjName
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var parentId = '';
                        if(response.getReturnValue().exceptionError == '') {
                            var objId = cmp.get("v.expli.Id");
                            var objId = cmp.get("v.expli.Id");
                            for(var x in obj){
                                if(obj[x].Attach.Id == RecordId){
                                    parentId = obj[x].ExpLI.Id;
                                    obj[x].Attach = response.getReturnValue().Attach;
                                    break;
                                }
                            }
                            cmp.set("v.expenseWrap1",obj);
                        }
                        cmp.set("v.exceptionError",response.getReturnValue().exceptionError);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //var uscroll = document.getElementById(parentId);
                        //uscroll.scrollIntoView();
                    } else { 
                        cmp.set("v.exceptionError",response.getReturnValue().exceptionError); 
                    }
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
            catch(err) {
                //alert("Exception : "+err.message);
                cmp.set("v.exceptionError : ",err.message);
            }
        } 
    },
    
    reRender : function(cmp, event, helper) { },
    
    updateTotalAmount : function(cmp, event, helper) {
        var subTotal = cmp.get("v.aItem.ExpLI.ERP7__Expensed_Submitted__c");
        var Tax = cmp.get("v.aItem.ExpLI.ERP7__VAT_Amount__c");
        var Total = cmp.get("v.aItem.ExpLI.ERP7__Claimed_Amount__c");
        if(!cmp.get("v.aItem.ExpLI.ERP7__Split_Total__c")){
            if(subTotal != null && subTotal != undefined && Tax != null && Tax != undefined && !$A.util.isEmpty(subTotal) && !$A.util.isEmpty(Tax)){
                var Total = parseFloat(subTotal) + parseFloat(Tax);
                cmp.set("v.aItem.ExpLI.ERP7__Claimed_Amount__c",Total);
            }else if((subTotal != null && subTotal != undefined) && (Tax == null || Tax == undefined || $A.util.isEmpty(Tax))){
                cmp.set("v.aItem.ExpLI.ERP7__Claimed_Amount__c",parseFloat(subTotal));
            }else if((subTotal == null || subTotal == undefined || $A.util.isEmpty(subTotal)) && (Tax != null && Tax != undefined)){
                cmp.set("v.aItem.ExpLI.ERP7__Claimed_Amount__c",parseFloat(Tax));
            }else{
                cmp.set("v.aItem.ExpLI.ERP7__Claimed_Amount__c",0);
            }
        }else{
            if(Tax != null && Tax != undefined && !$A.util.isEmpty(Tax)){
                var sTotal = parseFloat(Total) - parseFloat(Tax);
                cmp.set("v.aItem.ExpLI.ERP7__Expensed_Submitted__c", sTotal);
            }else{
                cmp.set("v.aItem.ExpLI.ERP7__Expensed_Submitted__c", parseFloat(Total));
            }
            
        }
    },
    
     updateTotalsAmount : function(cmp, event, helper) {
        var subTotal = cmp.get("v.expli.ERP7__Expensed_Submitted__c");
        var Tax = cmp.get("v.expli.ERP7__VAT_Amount__c");
        var Total = cmp.get("v.expli.ERP7__Claimed_Amount__c");
        if(!cmp.get("v.expli.ERP7__Split_Total__c")){
            if(subTotal != null && subTotal != undefined && Tax != null && Tax != undefined && !$A.util.isEmpty(subTotal) && !$A.util.isEmpty(Tax)){
                var Total = parseFloat(subTotal) + parseFloat(Tax);
                cmp.set("v.expli.ERP7__Claimed_Amount__c",Total);
            }else if((subTotal != null && subTotal != undefined) && (Tax == null || Tax == undefined || $A.util.isEmpty(Tax))){
                cmp.set("v.expli.ERP7__Claimed_Amount__c",parseFloat(subTotal));
            }else if((subTotal == null || subTotal == undefined || $A.util.isEmpty(subTotal)) && (Tax != null && Tax != undefined)){
                cmp.set("v.expli.ERP7__Claimed_Amount__c",parseFloat(Tax));
            }else{
                cmp.set("v.expli.ERP7__Claimed_Amount__c",0);
            }
        }else{
            if(Tax != null && Tax != undefined && !$A.util.isEmpty(Tax)){
                var sTotal = parseFloat(Total) - parseFloat(Tax);
                cmp.set("v.expli.ERP7__Expensed_Submitted__c", sTotal);
            }else{
                cmp.set("v.expli.ERP7__Expensed_Submitted__c", parseFloat(Total));
            }
            
        }
    },
    
    addLineItem : function(component, event) {
        var ExpType = event.getSource().get("v.value");
        if(ExpType == "Split"){
            //var expList = component.get("v.expenseWrap1");
            //expList.unshift({sObjectType :'ExpenseWrapper'});
            //component.set("v.expenseWrap1", expList);
        }
    },
    
    deleteSplitExpense : function(component, event, helper) {
        var splitExpense = event.currentTarget.dataset.record;
        var indexed = event.currentTarget.dataset.index;
        var expli1 = component.get("v.splittedExpLine");
        if(expli1[i]!=undefined){
            for(var i=0; i<expli1.length; i++){
                if(expli1[i].Id == splitExpense){
                    helper.deleteSplitExpli(component, event, expli1[i]);
                }
            }
        }else{
            var Expline = component.get("v.splittedExpLine");
            Expline.splice(indexed,1);
            component.set("v.splittedExpLine", Expline);
        }
    },
    
    openPopup : function(component, event, helper) {
        var splitExpense = event.currentTarget.dataset.record;
        var expli1 = component.get("v.expli");
        for(var i=0; i<expli1.length; i++){
            if(expli1[i].Id == splitExpense){
                component.set("v.splitExpense",expli1[i]);
                helper.fetchExistingExpense(component, event);
                
                component.set("v.SplitExpensePopup", true);
            }
        }
    },
    
    openPopupMultiple : function(component, event, helper) {
        var splitExpense = event.currentTarget.dataset.record;
        var expli1 = component.get("v.expline");
        for(var i=0; i<expli1.length; i++){
            if(expli1[i].Id == splitExpense){
                component.set("v.splitExpense",expli1[i]);
                helper.fetchExistingExpense(component, event);
                
                component.set("v.SplitExpensePopup", true);
            }
        }
    },
    
    CancelCalled : function(component, event, helper) {
        component.set("v.SplitExpensePopup", false);
    },
    
    addSplit : function(component, event, helper) {
        var expList = component.get("v.splittedExpLine");
        expList.unshift({sObjectType :'ERP7__Expense_Line_Item__c'});
        component.set("v.splittedExpLine", expList);
    },
    
    saveRecords : function(component, event, helper) {
        var expList = component.get("v.splittedExpLine");
        var AmountValidate = true;
        var COAValidate = true;
        
        for(var i=0;i<expList.length;i++){
            if(expList[i].ERP7__Claimed_Amount__c == null || expList[i].ERP7__Claimed_Amount__c == '' || expList[i].ERP7__Claimed_Amount__c == undefined){
                AmountValidate = false;
                helper.showToast('Error!','error','Please Enter the Amount');
            }
        }
        if(AmountValidate){
            for(var i=0;i<expList.length;i++){
                if(expList[i].ERP7__Chart_Of_Account__c == null || expList[i].ERP7__Chart_Of_Account__c == '' || expList[i].ERP7__Chart_Of_Account__c == undefined){
                    COAValidate = false;
                    helper.showToast('Error!','error','Please Select the Chart of Account');
                }
            }
        }
        if(AmountValidate && COAValidate){
            var actualAmount = component.get("v.splitExpense.ERP7__Claimed_Amount__c");
            var TotalAmount = 0.00;
            for(var i=0;i<expList.length;i++){
                TotalAmount = parseFloat(TotalAmount) + parseFloat(expList[i].ERP7__Claimed_Amount__c);
                
            }
            if(actualAmount != TotalAmount){
                helper.showToast('Error!','error','Split Amount does not match the Total Amount');
            }else{
                var action=component.get("c.CreateSplitItem");
                action.setParams({'Expline':JSON.stringify(component.get("v.splittedExpLine")), 'ExpRecord':JSON.stringify(component.get("v.splitExpense"))})
                action.setCallback(this,function(response){
                    if(response.getState() === "SUCCESS"){
                        helper.showToast('Success!','success','Expense Split Successfully');
                        component.set("v.SplitExpensePopup", false);
                    }
                    else{
                        var errors = response.getError();
                        console.log("err -> ", errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    
    
})