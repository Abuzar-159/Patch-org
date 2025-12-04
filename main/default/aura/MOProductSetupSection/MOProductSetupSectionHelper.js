({
    //Changed by Arshad 08 Aug 23
    removecloned : function(component,event) {
        console.log('removecloned called');
        component.set('v.showspinner',true);
        var ProcessId = component.get('v.Process.Id');
        var Prod= component.get('v.Productdetails.Id'); 
        
        var SelectedVersion = component.get('v.SelectedVersion');
        var SelectedVersionId = '';
        
        if(SelectedVersion != undefined && SelectedVersion != null && SelectedVersion != ''){
            if(SelectedVersion.Id != undefined && SelectedVersion.Id != null){
                SelectedVersionId = SelectedVersion.Id;
            }
        }
        console.log('SelectedVersionId~>'+SelectedVersionId);
        
        var action = component.get("c.deleteallcloned");
        action.setParams({
            PrId: ProcessId,
            ProdId : Prod,
            VerId : SelectedVersionId,
        });
        
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue(); 
                
                console.log('ProcessId~>'+ProcessId);
                
                var ver = component.get('v.SelectedVersion');
                var pr = {'Id':''}; // was ''; - Changed by Arshad 07 Aug 23
                
                var prod = component.get('v.Productdetails');
                
                //below code added by Arshad 08 Aug 23
                var SelectedVersionToClone = component.get("v.SelectedVersionToClone");
                console.log('SelectedVersionToClone~>'+JSON.stringify(SelectedVersionToClone));
                if(SelectedVersionToClone != undefined && SelectedVersionToClone != null && SelectedVersionToClone != ''){ 
                    if(SelectedVersionToClone.Id != undefined && SelectedVersionToClone.Id != null){
                        ver = SelectedVersionToClone;
                    }
                }
                
                var ProcessToClone = component.get("v.ProcessToClone");
                console.log('ProcessToClone~>'+JSON.stringify(ProcessToClone));
                if(ProcessToClone != undefined && ProcessToClone != null && ProcessToClone != ''){
                    if(ProcessToClone.Id != undefined && ProcessToClone.Id != null){
                        pr = ProcessToClone;
                    }
                }
                //
                
                var alldetail = {Product : prod,version : ver,process : pr};
                console.log('alldetail befoe going back to MOProductConfiguration~>',JSON.stringify(alldetail));
                
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:MOProductConfiguration",
                    componentAttributes: {
                        "CurrProdLst" : alldetail
                    }
                });
                evt.fire();
                component.set('v.showspinner',false);
            }else{
                console.log('Error :',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
  /*  helpershowToastss : function(title, type, message) {
        console.log('insde toast');
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            //component.set("v.showMainSpin",false);
            toastEvent.fire();
        }
    },*/
    helpershowToastss : function(title, type, messageMap) {
    var toastEvent = $A.get("e.force:showToast");
    if (toastEvent) {
        var lang = $A.get("$Locale.language"); 
        
        var message = messageMap[lang] || messageMap['en'];

        toastEvent.setParams({
            "mode": "dismissible",
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
},

    saveAtt : function(component,event,file,parentId,helper){
        component.set('v.showspinner',true);
        
        var reader = new FileReader();
        reader.onloadend = function() {
            var contents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
            var fileContents = contents.substring(dataStart);
            var verId = component.get('v.SelectedVersion.Id');
            var action = component.get("c.uploadFile");
            
            action.setParams({
                parent: parentId,
                fileName: file.name,
                base64Data: encodeURIComponent(fileContents),
                contentType: file.type,
                'versionId':verId
            });
            action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS'){
                    component.set('v.showspinner',false);
                    var result = response.getReturnValue();
                    console.log('uploadFile result : ',result);
                    component.set('v.ProcessCycles',result);
                    helper.fixSort(component);
                }else{
                    component.set('v.showspinner',false)
                    console.log('Error:',response.getError());
                }
            });
            $A.enqueueAction(action); 
        }
        reader.readAsDataURL(file);
    },
    fetchPicklistValues : function(component,objDetails,controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                console.log("getDependentMap-->Asra 1",response.getReturnValue());
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
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
                component.set("v.listControllingValues", ControllerField);
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        console.log('dependentFields->Asra',dependentFields);
        
    },
    getFC : function(component){
        var getFCresult= component.get('c.fetchFCResult');
        getFCresult.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result : ',result);
                if(result != null){
                    component.set('v.allowNonInventoryItems',result);  
                }
                
            }
        });
        $A.enqueueAction(getFCresult);
    },
    getProducts : function(component){
        component.set('v.showspinner',true);
        component.set("v.listOfProducts",[]);
        var ProcessId = component.get('v.Process.Id');
        console.log('ProcessId : ',ProcessId);
        var ProdId = component.get('v.Productdetails.Id');
        console.log('ProdId : ',ProdId);
        let searchfamily = component.get('v.seachItemFmily');
        if(searchfamily == '--None--') searchfamily = '';
        let searchsubfamily = component.get('v.subItemFmily');
        if(searchsubfamily == '--None--') searchsubfamily = '';
        let getProducts = component.get("c.getAllProds");
        getProducts.setParams({
            "processId":ProcessId,
            "ProductId" : ProdId,
            "search" : component.get('v.searchItem'),
            "Family" : searchfamily,
            "SubFamily" : searchsubfamily,
        });
        getProducts.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('getAllProds response : ',response.getReturnValue());
                let resList = response.getReturnValue();
                if(resList != null){
                    component.set("v.listOfProducts",resList);  
                }
                else {
                    // component.set("v.addProductsMsg",'No Products avaialble to view'); 
                    component.set("v.listOfProducts",[]); 
                }
            }
            else{
                console.log('getAllProds error : ',response.getError());
            }
            component.set('v.showspinner',false);
        });
        $A.enqueueAction(getProducts); 
    },
    getDependentPicklists : function(component, event, helper) {
        console.log('getDependentPicklists called');
        try{
            var action = component.get("c.getDependentPicklist");
            action.setParams({
                ObjectName : component.get("v.objDetail1"),
                parentField : component.get("v.controllingFieldAPI1"),
                childField : component.get("v.dependingFieldAPI1")
            });
            
            action.setCallback(this, function(response){
                var status = response.getState();
                console.log('status : ',status);
                if(status === "SUCCESS"){
                    var pickListResponse = response.getReturnValue();
                    console.log('pickListResponse :-------Asra2 ',response.getReturnValue());
                    //save response 
                    component.set("v.depnedentFieldMap1",pickListResponse.pickListMap);
                    
                    // create a empty array for store parent picklist values 
                    var parentkeys = []; // for store all map keys 
                    var parentField = []; // for store parent picklist value to set on lightning:select. 
                    
                    // Iterate over map and store the key
                    for (var pickKey in pickListResponse.pickListMap) {
                        parentkeys.push(pickKey);
                    }
                    
                    
                    parentField.push('--None--');
                    for (var i = 0; i < parentkeys.length; i++) {
                        parentField.push(parentkeys[i]);
                    }  
                    // set the parent picklist
                    component.set("v.listControllingValues1", parentField);
                    console.log('listControllingValues 1: ',component.get("v.listControllingValues1"));
                    component.set("v.seachItemFmily", '--None--');
                    component.set("v.listDependingValues1", ['--None--']);
                    component.set("v.bDisabledDependentFld1" , true);
                }
                else{
                    console.log('err : ',response.getError());
                }
            });
            
            $A.enqueueAction(action);
        }
        catch(e){
            console.log('e : ',e);
        }
        
    },
    parentFieldChange : function(component, event, helper) {
        var controllerValue =  component.get("v.seachItemFmily");
        var pickListMap = component.get("v.depnedentFieldMap1");
        console.log('controllerValue : '+controllerValue);
        if (controllerValue != '' && controllerValue != null && controllerValue != undefined) {
            //get child picklist value
            
            //component.set("v.Logistic.ERP7__Shipment_type__c",controllerValue);
            var childValues = [];
            if(pickListMap[controllerValue] != undefined) childValues  = pickListMap[controllerValue];
            console.log('childValues : ',childValues);
            var childValueList = [];
            //childValueList.push('');
            for (var i = 0; i < childValues.length; i++) {
                childValueList.push(childValues[i]);
            }
            // set the child list
            component.set("v.listDependingValues1", childValueList);
            console.log('listDependingValues : ',component.get("v.listDependingValues1"));
            if(childValues != undefined && childValues.length > 0){
                component.set("v.bDisabledDependentFld1" , false);  
            }else{
                component.set("v.listDependingValues1", ['--None--']);
                component.set("v.bDisabledDependentFld1" , true); 
            }
        } else {
            component.set("v.listDependingValues1", ['--None--']);
            component.set("v.bDisabledDependentFld1" , true);
        }
        if(component.get("v.listDependingValues1").length > 0){
            var listdependingValues = component.get("v.listDependingValues1");
            console.log('listdependingValues~>'+listdependingValues[0]);
            
        }
    },
    getFCVals : function(component){
        var action = component.get('c.geFC');
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.allowWIPValidation',result.allowWIPValidation);
                component.set('v.showVenCodeandProdCode',result.showVenCode);
            }
        });
        $A.enqueueAction(action);
    },
    fixSort : function(component){
        var TestResult = component.get('v.ProcessCycles');
        var sortedlist = component.get('v.sortedlist');
        if(sortedlist){
            
            for(var x=0;x<TestResult.length;x++){
                if(sortedlist[x]==1){
                    TestResult[x].expanded = true;
                }else{
                    TestResult[x].expanded = false;
                }
                
            }
            component.set('v.ProcessCycles',TestResult);
        }  
    },
    getProcessdetails : function(component,prodId,processId,verId){
        try{
        component.set('v.showspinner',true);
        var action = component.get('c.alldetails');
        action.setParams({
            'ProcsId' :processId,
            'WCIds' :[],
            'versionId':verId,
            'action' : component.get('v.Action')
        });
        /*action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('response helper : ',response.getReturnValue());
                var TestResult = response.getReturnValue();
                component.set('v.Action','Edit');
                console.log('in here in Edit');
                var sortedlist = [];
                for(var x=0;x<TestResult.length;x++){
                    if(x == 0) {
                        TestResult[x].expanded = true;
                        sortedlist[x] = 1;
                    }
                    else{
                        TestResult[x].expanded = false;
                        sortedlist[x] = 0;
                    }
                }
                //console.log('sortedlist?',sortedlist);
                //component.set('v.sortedlist',sortedlist);
                component.set('v.ProcessCycles',response.getReturnValue());
                console.log('value set');
                component.set('v.showspinner',false);
                
            }
            else{
                var err = response.getError();
                console.log('error : '+JSON.stringify(err));
                component.set('v.exceptionError','Error Occured');
                component.set('v.showspinner',false);
                
            }
        });*/
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('response helper:', response.getReturnValue());
                
                var TestResult = response.getReturnValue();
                
                if (Array.isArray(TestResult)) {
                    component.set('v.Action', 'Edit');
                    
                    var sortedlist = [];
                    for (var x = 0; x < TestResult.length; x++) {
                        if (x === 0) {
                            TestResult[x].expanded = true;
                            sortedlist[x] = 1;
                        } else {
                            TestResult[x].expanded = false;
                            sortedlist[x] = 0;
                        }
                    }
                    console.log('ProcessCycles value set');
                    component.set('v.showspinner', false);
                    component.set('v.ProcessCycles', TestResult);
                    
                } else {
                    console.error('Unexpected data structure in response.');
                    // Handle the unexpected data structure case
                }
                
                component.set('v.showspinner', false);
            } else {
                var err = response.getError();
                console.error('Error:', JSON.stringify(err));
                component.set('v.exceptionError', $A.get('$Label.c.Error_UsersShiftMatch'));
                component.set('v.showspinner', false);
            }
        });
        
        $A.enqueueAction(action);
        }catch(e){
            console.log('error : ',e);
        }
        
    },
    
    
    
    
})