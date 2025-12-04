({
    doInit: function(component, event, helper) {
          /*component.set("v.expli", []);
    component.set("v.expline", []);
    component.set("v.splittedExpLine", []);
    component.set("v.listControllingValues", []);
    component.set("v.listDependingValues", ['--- None ---']);

    // Maps / objects
    component.set("v.depnedentFieldMap", {});
    component.set("v.Org", {});
    component.set("v.AddExpenseFLSCheck", { sObjectType: 'AddExpenseFLSCheck' });

    // aItem default map
    component.set("v.aItem", {
        Name: '',
        ERP7__Expense_Date__c: '',
        ERP7__Expensed_Submitted__c: '0.00',
        ERP7__VAT_Amount__c: '0',
        ERP7__Claimed_Amount__c: '0.00',
        ERP7__Description__c: ''
    });

    // Expense default if you still need it:
    var exp = {
        sobjectType: 'Expense__c',
        ERP7__Employees__c: '',
        ERP7__Status__c: '',
        ERP7__Approver__c: ''
    };
    component.set("v.Expense", exp);*/
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
        var result = confirm("Are you sure you want to delete this expense item?");
        if (!result) {
            return; 
        }
        try{
            if(expWrp[ind].ExpLI == undefined || expWrp[ind].ExpLI.Id == 'undefined' || expWrp[ind].ExpLI.Id==null) {
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
    
    deleteExpliWpmulti : function(component, event, helper) {
        var lineIndex  = component.get("v.index");
        var wrapIndex  = component.get("v.parentIndex");
        var expWrap    = component.get("v.expenseWrap1");
        
        var result = confirm("Are you sure you want to delete this expense item?");
        if (!result) {
            return;
        }
        
        try {
            var lineWrapper = expWrap[wrapIndex].expline[lineIndex];
            var expLI = lineWrapper.ExpLI ? lineWrapper.ExpLI : lineWrapper;
            
            if (!expLI || !expLI.Id) {
                // 🔹 Unsaved row → just tell parent to drop it
                var e = $A.get("e.c:IndexingEvent");
                e.setParams({
                    "Index"       : lineIndex,
                    "ParentIndex" : wrapIndex
                });
                e.fire();
            } else {
                // 🔹 Saved row → server delete then splice
                helper.deleteCurExpliMulti(component, expLI, wrapIndex, lineIndex);
            }
        } catch (ex) {
            console.error('[deleteExpliWpmulti] ex:', ex);
        }
    },


    
    closeError : function (cmp, event) {
        cmp.set("v.exceptionError",'');
    },
     onFileUploadedAK : function(cmp, event, helper) {
        var files = cmp.get("v.FileList");
        console.log('[onFileUploadedAK] FileList:', files);
       	var file = files[0][0];
       	console.log('[onFileUploadedAK] Selected file:', file);
        var maxSizeBytes = 2 * 1024 * 1024; // 4.5 MB
         if (file.size > maxSizeBytes) {
             console.warn('[onFileUploadedAK] File too large. Size = ' + file.size);
             //alert('File size cannot exceed 4.5 MB.');
            var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
                 title: "Error",
                 message: "File size cannot exceed 2 MB.",
                 type: "error"
             });
             toastEvent.fire();
             
             $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
             
             //cmp.set("v.FileList", null);
             
             
             return; // 🚫 do NOT continue to upload
         }
        var filek = JSON.stringify(file);
        var parentId = event.getSource().get("v.name");
        console.log('[onFileUploadedAK] parentId (should be ExpLI.Id):', parentId);
        if (files && files.length > 0) {
            var reader = new FileReader();
            reader.onloadend = $A.getCallback(function() {
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var contents = reader.result;
                console.log('[onFileUploadedAK] FileReader result:', contents ? contents.substring(0, 100) + '...' : contents);
                var base64Mark = 'base64,';
                var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                var fileContents = contents.substring(dataStart);
                console.log('[onFileUploadedAK] Extracted base64 data length:', fileContents.length);

                var action = cmp.get("c.uploadFileAK");
                console.log('[onFileUploadedAK] Calling Apex uploadFileAK with params:', {
                    parent: parentId,
                    fileName: file.name,
                    base64Data: '[base64 omitted]',
                    contentType: file.type
                });

                action.setParams({
                    parent: parentId,
                    fileName: file.name,
                    base64Data: encodeURIComponent(fileContents),
                    contentType: file.type
                });
                action.setCallback(this, $A.getCallback(function(response) {
                    var state = response.getState();
                    console.log('[onFileUploadedAK] Apex response state:', state);
                    if (state === "SUCCESS") {
                        var retVal = response.getReturnValue();
                        console.log('[onFileUploadedAK] Apex return value:', retVal);
                        if(retVal.exceptionError == '') {
                            var obj = cmp.get("v.expenseWrap1");
                            console.log('[onFileUploadedAK] expenseWrap1 before update:', JSON.stringify(obj));
                            var found = false;
                            for(var x in obj){
                                console.log('s1');
                                if(obj[x].ExpLI.Id == parentId){
                                    console.log('s2');
                                    if (!obj[x].Attachments) {
                                        obj[x].Attachments = [];
                                    }
                                    // Add the new attachment to the list
                                    for(let i=0;i<retVal.Attachments.length;i++){
                                        console.log('push attachments here');
                                        let newAtt = retVal.Attachments[i];
    									console.log('Checking attachment:', newAtt);
                                        let alreadyExists =false;
                                        if(obj[x].Attachments.length>0){
                                            alreadyExists = obj[x].Attachments.some(att => att.Id === newAtt.Id);
                                        }
                                        if (!alreadyExists) {
                                            obj[x].Attachments.push(newAtt);
                                        }
                                    }
                                   // obj[x].Attachments.push(retVal.Attachments);
                                    found = true;
                                    console.log('Added new attachment to list:', JSON.stringify(obj[x].Attachments));
                                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                    break;
                                }
                            }
                            if(!found) {
                                console.warn('[onFileUploadedAK] No matching line item found for parentId:', parentId);
                            }
                            cmp.set("v.expenseWrap1",obj);
                            console.log('[onFileUploadedAK] expenseWrap1 after update:', obj);
                        }
                        cmp.set("v.exceptionError",response.getReturnValue().exceptionError);
                        //var uscroll = document.getElementById(parentId);
                        //uscroll.scrollIntoView();
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }));
                $A.enqueueAction(action);
            });
            reader.readAsDataURL(file);
        } else {
            console.warn('[onFileUploadedAK] No files found in FileList.');
        }
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
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
     /* onFileUploadedAK : function(cmp, event, helper) {
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
        
    },*/
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
     /* onFileUploadedAKMulti : function(cmp, event, helper) {
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
        
    },*/
    onFileUploadedAKMulti : function(cmp, event, helper) {
        var files = cmp.get("v.FileList");
        console.log('[onFileUploadedAKMulti] FileList:', files);
        
        if (!files || !files[0] || !files[0][0]) {
            console.warn('[onFileUploadedAKMulti] No files found in FileList.');
            return;
        }
        
        var file = files[0][0];
        console.log('[onFileUploadedAKMulti] Selected file:', file);
        
        var maxSizeBytes = 2 * 1024 * 1024; // 4.5 MB
        if (file.size > maxSizeBytes) {
            console.warn('[onFileUploadedAK] File too large. Size = ' + file.size);
            // alert('File size cannot exceed 4.5 MB.');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "File size cannot exceed 2 MB.",
                type: "error"
            });
            toastEvent.fire();
            
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            
            //cmp.set("v.FileList", null);
            
            
            return; // 🚫 do NOT continue to upload
        }
        var parentId = event.getSource().get("v.name"); // ExpLI.Id
        console.log('[onFileUploadedAKMulti] parentId (line Id):', parentId);
        
        if (!parentId) {
            console.warn('[onFileUploadedAKMulti] No parentId on lightning:input name attribute.');
            return;
        }
        
        var reader = new FileReader();
        reader.onloadend = $A.getCallback(function() {
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            
            var contents = reader.result;
            console.log('[onFileUploadedAKMulti] FileReader result:',
                        contents ? contents.substring(0, 100) + '...' : contents);
            
            var base64Mark = 'base64,';
            var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
            var fileContents = contents.substring(dataStart);
            console.log('[onFileUploadedAKMulti] Extracted base64 data length:', fileContents.length);
            
            // 🔴 REUSE existing Apex method
            var action = cmp.get("c.uploadFileAK");
            
            console.log('[onFileUploadedAKMulti] Calling Apex uploadFileAK with params:', {
                parent: parentId,
                fileName: file.name,
                base64Data: '[base64 omitted]',
                contentType: file.type
            });
            
            action.setParams({
                parent: parentId,
                fileName: file.name,
                base64Data: encodeURIComponent(fileContents),
                contentType: file.type
            });
            
            action.setCallback(this, $A.getCallback(function(response) {
                var state = response.getState();
                console.log('[onFileUploadedAKMulti] Apex response state:', state);
                
                if (state === "SUCCESS") {
                    var retVal = response.getReturnValue();
                    console.log('[onFileUploadedAKMulti] Apex return value:', retVal);
                    
                    if (retVal.exceptionError === '') {
                        // 🔴 Update accList instead of expenseWrap1
                        var accList = cmp.get("v.accList") || [];
                        console.log('[onFileUploadedAKMulti] accList before:', JSON.stringify(accList));
                        
                        if (retVal.Attachments && retVal.Attachments.length > 0) {
                            retVal.Attachments.forEach(function(newAtt) {
                                // Ensure ParentId is set (in case Apex doesn’t SELECT it)
                                if (!newAtt.ParentId) {
                                    newAtt.ParentId = parentId;
                                }
                                
                                var exists = accList.some(function(att) {
                                    return att.Id === newAtt.Id;
                                });
                                if (!exists) {
                                    accList.push(newAtt);
                                    console.log('[onFileUploadedAKMulti] Added attachment Id:', newAtt.Id);
                                }
                            });
                        }
                        
                        cmp.set("v.accList", accList);
                        console.log('[onFileUploadedAKMulti] accList after:', JSON.stringify(accList));
                    }
                    
                    cmp.set("v.exceptionError", retVal.exceptionError);
                } else {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error('[onFileUploadedAKMulti] Error:', errors[0].message);
                        cmp.set("v.exceptionError", errors[0].message);
                    } else {
                        console.error('[onFileUploadedAKMulti] Unknown error');
                        cmp.set("v.exceptionError", "Unknown error occurred.");
                    }
                }
                
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }));
            
            $A.enqueueAction(action);
        });
        
        reader.readAsDataURL(file);
    },

    
   /* DeleteRecordAT: function(cmp, event) {
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
    },*/
    DeleteRecordAT: function(cmp, event) {
        // Get the ID and object name from the button
        console.log('in DELETE RECORD AT Line item');
        var RecordId = event.getSource().get("v.name");
        console.log('RECORF id: '+RecordId);
        var ObjName = event.getSource().get("v.title");
        console.log('Objname: '+ObjName);
        // Exit early if the RecordId is invalid
        if (RecordId == null || RecordId == undefined) {
            return;
        }
        
        // Use a confirmation dialog for user experience
        var result = confirm("Are you sure?");
        if (!result) {
            return; // Exit if the user cancels
        }
        
        // Show the spinner while the action is in progress
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        
        // Call the Apex controller to delete the attachment
        var action = cmp.get("c.DeleteAT");
        action.setParams({
            RAId: RecordId,
            ObjName: ObjName
        });
        
        // Set the callback function to handle the response
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                console.log('retVal: ',JSON.stringify(retVal));
                if (retVal.exceptionError == '') {
                    // Get the main data object from the component
                    var obj = cmp.get("v.expenseWrap1");
                    console.log('obj: ',JSON.stringify(obj));
                    
                    // Find the specific expense line item to update
                    for (var x in obj) {
                        // Check if the current line item has the deleted attachment's parentId
                        if (obj[x].ExpLI.Id === retVal.expLineId) {
                            // The Apex method now returns a list of *remaining* attachments.
                            // We directly set this list on the component's attribute.
                            obj[x].Attachments = retVal.Attachments;
                            break;
                        }
                    }
                    
                    // Set the updated object back to the component to trigger a UI re-render
                    cmp.set("v.expenseWrap1", obj);
                }
                // Display any exceptions from Apex
                cmp.set("v.exceptionError", retVal.exceptionError);
            } else {
                // Handle any Apex call failures
                var errors = response.getError();
                if (errors) {
                    cmp.set("v.exceptionError", errors[0].message);
                } else {
                    cmp.set("v.exceptionError", "Unknown error occurred.");
                }
            }
            // Hide the spinner regardless of success or failure
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        });
        
        // Enqueue the action to send it to the server
        $A.enqueueAction(action);
    },    
    DeleteRecordATMulti: function(cmp, event) {
    console.log('in DELETE RECORD AT Line item');

    var RecordId = event.getSource().get("v.name");
    console.log('RECORD id: ' + RecordId);
    var ObjName = event.getSource().get("v.title");
    console.log('Objname: ' + ObjName);

    // Exit early if the RecordId is invalid
    if (!RecordId) {
        return;
    }

    // Confirmation
    var result = confirm("Are you sure?");
    if (!result) {
        return;
    }

    // Show spinner
    $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");

    // Call Apex
    var action = cmp.get("c.DeleteAT");
    action.setParams({
        RAId: RecordId,
        ObjName: ObjName
    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        console.log('DeleteRecordAT state:', state);

        if (state === "SUCCESS") {
            var retVal = response.getReturnValue();
            console.log('retVal: ', JSON.stringify(retVal));

            if (retVal.exceptionError === '') {
                var expLineId         = retVal.expLineId;
                var serverAttachments = retVal.Attachments || [];

                // Just in case ParentId is missing, enforce it
                serverAttachments.forEach(function(a) {
                    if (!a.ParentId) {
                        a.ParentId = expLineId;
                    }
                });

                // Current global accList
                var accList = cmp.get("v.accList") || [];
                console.log('accList before: ', JSON.stringify(accList));

                // 1) Remove all attachments for this line from accList
                var newAccList = accList.filter(function(att) {
                    return att.ParentId !== expLineId;
                });

                // 2) Add the fresh server list for this line
                Array.prototype.push.apply(newAccList, serverAttachments);

                cmp.set("v.accList", newAccList);
                console.log('accList after: ', JSON.stringify(newAccList));
            }

            // Display any exceptions from Apex
            cmp.set("v.exceptionError", retVal.exceptionError);

        } else {
            // Handle errors
            var errors = response.getError();
            if (errors && errors[0] && errors[0].message) {
                cmp.set("v.exceptionError", errors[0].message);
            } else {
                cmp.set("v.exceptionError", 'Unknown error occurred.');
            }
        }

        // Hide spinner
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    });

    $A.enqueueAction(action);
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