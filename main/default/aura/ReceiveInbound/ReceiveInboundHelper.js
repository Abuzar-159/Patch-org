({
    
    focusTOscan: function (component, event) {
        try{
        console.log('focusTOscan helper called');
        $(document).ready(function () {
            component.set("v.scanValue", '');
            var barcode = "";
            var pressed = false;
            var chars = [];
            $(window).keypress(function (e) {
                
                $(".scanMN").keypress(function (e) {
                    e.stopPropagation()
                });
                
                chars.push(String.fromCharCode(e.which));
                if (pressed == false) {
                    setTimeout(
                        function () {
                            pressed = false;
                            if (chars.length >= 3) {
                                var barcode = chars.join("");
                                barcode = barcode.trim();
                                chars = [];
                                pressed = false;
                                component.set("v.scanValue", barcode);
                                console.log('scanValue : ',component.get("v.scanValue"));
                                chars = [];
                                pressed = false;
                            }
                            chars = [];
                            pressed = false;
                        }, 500);
                }
                pressed = true;
            }); // end of window key press function         
            
            $(window).keydown(function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                }
            });
        });
            }catch(e){
            console.log('err',e);
        }
    },
    
    helperserial: function (component, event,helper,value,index) {
        try{
        console.log('helperserial called');
        if(value != '' && value != null && value != undefined && index != null && index != undefined){
            console.log('checkDuplicateSerials 2 called');
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action = component.get('c.checkDuplicateSerials');
            action.setParams({
                value : value,
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    if(response.getReturnValue() != null){
                        component.set("v.exceptionError", response.getReturnValue());
                    }else{
                        var SPLIS = component.get("v.Container.SPLIS");
                        if(SPLIS.length > 0){
                            for(var i in SPLIS){
                                if(SPLIS[i].sili.ERP7__Product__c != null && SPLIS[i].sili.ERP7__Product__c  != undefined && SPLIS[i].sili.ERP7__Product__c  != ''){
                                    if(SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c && i != index){
                                        if(SPLIS[i].sili.ERP7__Serial_Number__c != '' && SPLIS[i].sili.ERP7__Serial_Number__c != null && SPLIS[i].sili.ERP7__Serial_Number__c != undefined){
                                            if(value == SPLIS[i].sili.ERP7__Serial_Number__c){
                                                var errmsg = 'Duplicate Serial No '+value+' exists.';
                                                component.set("v.exceptionError",errmsg);
                                                break;
                                            }
                                        }
                                    }
                                    else if(SPLIS[i].sili.ERP7__Product__r.ERP7__Serialise__c && i == index && (component.get("v.exceptionError") == null || component.get("v.exceptionError") == '' || component.get("v.exceptionError") == undefined)){
                                        SPLIS[i].isSelected = true;
                                        component.set('v.hideSave',false);
                                        console.log('else');
                                    }
                                }
                                
                            }
                            component.set("v.Container.SPLIS",SPLIS);
                        }
                    }
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    setTimeout(function () { component.set("v.exceptionError",""); }, 6000);
                }else{
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    var err = response.getError();
                    component.set("v.exceptionError",err[0].message);
                    setTimeout(function () { component.set("v.exceptionError",""); }, 5000);
                    console.log('Error Duplicates:',err);
                }
            });
            $A.enqueueAction(action);
        }
            }catch(e){
            console.log('err',e);
        }
    },
    saveAtt : function(component,event,file,parentId){
        try{
        console.log('saveAtt called ');
        var reader = new FileReader();
        reader.onloadend = function() {
            var contents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
            var fileContents = contents.substring(dataStart);
            
            var action = component.get("c.uploadFile");
            
            action.setParams({
                parent: parentId,
                fileName: file.name,
                base64Data: encodeURIComponent(fileContents),
                contentType: file.type
            });
            action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS'){
                }else{
                    console.log('Error :',response.getError());
                }
            });
            $A.enqueueAction(action); 
        }
        reader.readAsDataURL(file);
        //}
        }catch(e){
            console.log('err',e);
        }
    },
    getpicklistValues : function(cmp,event){
        try{
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var obj11 =  cmp.get("v.objDetail");
        var controllingFieldAPI = cmp.get("v.controllingFieldAPI");
        var dependingFieldAPI = cmp.get("v.dependingFieldAPI");
        var action = cmp.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : obj11,
            'contrfieldApiName': controllingFieldAPI,
            'depfieldApiName': dependingFieldAPI 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in StoreResponse){
                    console.log('key~>'+key);
                    console.log('StoreResponse[key]~>'+JSON.stringify(StoreResponse[key]));
                    arrayMapKeys.push({key: key, value: StoreResponse[key]});
                }                
                console.log('arrayMapKeys~>',arrayMapKeys);
                
                cmp.set("v.depnedentFieldMap",arrayMapKeys);
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                cmp.set("v.listControllingValues", ControllerField);
                
                // cmp.set("v.SelectedTask",cmp.get("v.SelectedTask"));
                
                
            }else{
                var error = response.getError();
                console.log('getDependentMap err~>'+JSON.stringify(error));
            }
        });
        $A.enqueueAction(action);
        }catch(e){
            console.log('err',e);
        }        
    },
    fetchDepValues: function(component, ListOfDependentFields) {
        try{
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        }catch(e){
            console.log('err',e);
        }
        
    },
    uploadFile: function(component, accountId, fileContents) {
        try{
            var action = component.get('c.createAttachment');
            action.setParams({
                accountId: accountId,
                fileContents: fileContents
            });
            action.setCallback(this, function(response) {
                // Handle response
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('err',e);
        }
    },
    
    //new helper method for multiple files upload for QA guidelines arshad 13/07/23
    finishAllFilesUploadforQAguidelines : function(parentId,fileNameList,base64DataList,contentTypeList,component, event, helper) {
        try{
            console.log('finishAllFilesUploadforQAguidelines parentId~>'+JSON.stringify(parentId));
            console.log('finishAllFilesUploadforQAguidelines fileNameList~>'+fileNameList.length);
            console.log('finishAllFilesUploadforQAguidelines base64DataList~>'+base64DataList.length);
            console.log('finishAllFilesUploadforQAguidelines contentTypeList~>'+contentTypeList.length);
            var action = component.get("c.uploadMultipleFilesforQAguidelines");
            
            if(parentId.hasOwnProperty('Attachments')){
                delete parentId.Attachments;
            }
            console.log('finishAllFilesUploadforQAguidelines parentId final~>'+JSON.stringify(parentId));
            
            action.setParams({
                parent: JSON.stringify(parentId),
                fileName: fileNameList,
                base64Data: base64DataList,
                contentType: contentTypeList,
            });
            
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log("finishAllFilesUploadforQAguidelines resp: ", JSON.stringify(response.getReturnValue()));
                    //todo
                    //Moin commented this 07th september 2023 
                    component.getAllRecieveDetails(); 
                    //Added this
                    /*var exitingsolis = component.get("v.ExistingSILI");
                    for(var x in exitingsolis){
                        var sili = [];
                        sili = exitingsolis[x].guideline;                       
                        for(var y in sili){
                            if(sili[y].Id == parentId.Id){ 
                            sili[y].Attachments = response.getReturnValue();
                            }
                        }
                    }
                    component.set("v.ExistingSILI", exitingsolis);*/
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
                else{ 
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    var errors = response.getError();
                    console.log("server error in finishAllFilesUploadforQAguidelines : ", JSON.stringify(errors));
                    component.set("v.exceptionError", errors[0].message);
                }
            });
            $A.enqueueAction(action);
            
            setTimeout($A.getCallback(function () {
                console.log('setTimeout'); 
            }), 1000);   //dont remove setTimeout - for loading issue fix for upload files - Arshad
        }catch(e){
            console.log('finishAllFilesUpload err',e);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
    },
    showToast: function (title, type, message) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    
    uploadFiles: function (component, filesDataToUpload,recordId) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        const action = component.get("c.createAttachments");
        console.log('recordId : ',recordId);
        
        action.setParams({
            recordId: recordId,
            filesData: JSON.stringify(filesDataToUpload)
        });
        
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.getAllRecieveDetails();
              /*  try {
                    // Get the attachment files from the response
                    var attchfiles = response.getReturnValue() || [];
                    console.log('Attachment Files:', attchfiles);
                    
                    // Get the LOLIs array
                    var LOLIs = component.get('v.Container.LOLIS');
                    if (!LOLIs || !Array.isArray(LOLIs)) {
                        console.error('LOLIs is not an array or is undefined:', LOLIs);
                        return;
                    }
                   // component.set('v.Container.LOLIS',[]);
                    // Iterate through LOLIs and update the attachments
                    for (let item of LOLIs) {
                        console.log('Processing Record:', JSON.stringify(item));
                        if (item.LOLI && item.LOLI.Id === recordId && attchfiles.length > 0) {
                            console.log('Matched Record ID:', recordId);
                            console.log('Setting New Attachments:', JSON.stringify(attchfiles));
                            item.Attachments = attchfiles;
                            break; // Stop loop once matched
                        }
                    }
                        console.log('Updated LOLIs:', JSON.stringify(LOLIs));
                        // Update the component attribute
                    if (Array.isArray(LOLIs) && LOLIs.length > 0) {
                        component.set('v.Container.LOLIS', LOLIs);
                    } else {
                        console.error('LOLIs is not an array or is empty:', LOLIs);
                    }
                        
                    } catch (e) {
                        console.error('Error in helper:', e.message, e.stack);
                    }*/

               /* try{
                var attchfiles = [];
                    console.log('response.getReturnValue() : ',response.getReturnValue());
                    if(response.getReturnValue() != null) attchfiles = response.getReturnValue();
                    var LOLIs = component.get('v.Container.LOLIS');
                    console.log('LOLIs : ',JSON.stringify(LOLIs));
                    for(var x in LOLIs){
                        if(LOLIs[x].LOLI && LOLIs[x].LOLI.Id == recordId && attchfiles.length > 0){
                            console.log('attache : ');
                            if(LOLIs[x].Attach) LOLIs[x].Attach = attchfiles;
                            console.log('LOLIs[x].Attach : ',JSON.stringify(LOLIs[x].Attach));
                        }
                    }
                    component.set('v.Container.LOLIS',LOLIs);
                }catch(e){
                    console.log('error a helper : ',e);
                }*/
                this.showToast("Success", "success", "Files uploaded successfully.");
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            } else {
                const errors = response.getError();
                this.showToast("Error", "error", "Error uploading files: " + JSON.stringify(errors));
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });

        $A.enqueueAction(action);
    }

})