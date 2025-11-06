({
    fetchExistingRMAPkg : function(component, event, helper){
        var rmaliAction1 = component.get("c.fetchingPackages");
        rmaliAction1.setParams({
            returnID:component.get("v.ReturnMAID")
        });
        rmaliAction1.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var existingPkgs = response.getReturnValue().packageslist;
                component.set("v.packageList",response.getReturnValue().packageslist);
                if(existingPkgs.length > 0) {
                    component.set("v.pkgListBool",true);
                    component.set("v.pkgBool",false);
                    component.set("v.editPkgBool",false);
                }else{
                    component.set("v.pkgListBool",false);
                    component.set("v.pkgBool",true);
                    component.set("v.editPkgBool",false);
                    component.set("v.package",response.getReturnValue().packg);
                    
                    var shipmenttypeopts = component.get("v.shipmentTypeDynamicOptions");
                    var packagetypeopts = component.get("v.inputPackageTypeOptions");
                    if(!$A.util.isEmpty(component.get("v.frieghtType")) && !$A.util.isUndefinedOrNull(component.get("v.frieghtType"))){
                        component.set("v.package.ERP7__Shipment_Type__c", component.get("v.frieghtType"));
                    }else{
                        if(shipmenttypeopts.length>0) component.set("v.package.ERP7__Shipment_Type__c", shipmenttypeopts[0].value);
                    }
                    component.set("v.package.ERP7__Declared_Value__c", component.get("v.refundAmt"));
                    if(packagetypeopts.length>0) component.set("v.package.ERP7__Package_Type__c", packagetypeopts[0].value);
                }
            }else{
                var errors = response.getError();
                console.log("server error fetchExistingRMAPkg : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }
        });
        $A.enqueueAction(rmaliAction1);
    },
    
    fetchingExistingShipments : function(component, event, helper){
        console.log('entered fetchingExistingShipments');
        var rmaliAction2 = component.get("c.fetchShipments");
        var rmaID = component.get("v.ReturnMAID");
        rmaliAction2.setParams({
            returnId:rmaID
        });
        rmaliAction2.setCallback(this, function(response){
            var state = response.getState();
            if (response.getState() === "SUCCESS") {
                component.set("v.shipmentList",response.getReturnValue());
                console.log('shipmentList==>'+JSON.stringify(response.getReturnValue()));
                
            }else{
                var errors = response.getError();
                console.log("server error fetchExistingRMAPkg : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }
        });
        $A.enqueueAction(rmaliAction2);
    },
    
    picVal : function(component, event, helper){
        var action = component.get("c.getWeightUnits");
        var opts=[];
        opts.push({"class": "optionClass", label:"--None--", value: ""});
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.InputSelectDynamicOptions",opts);
        });
        $A.enqueueAction(action);
        
        var packageTypeAction = component.get("c.getPackageType");
        var packagetypeopts=[];
        packagetypeopts.push({"class": "optionClass", label:"--None--", value: ""});
        packageTypeAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                packagetypeopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.inputPackageTypeOptions",packagetypeopts);
            
        });
        $A.enqueueAction(packageTypeAction);
        
        var shipmentTypeAction = component.get("c.getShipmentType");
        var shipmenttypeopts=[];
        shipmenttypeopts.push({"class": "optionClass", label:"--None--", value: ""});
        shipmentTypeAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                shipmenttypeopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.shipmentTypeDynamicOptions",shipmenttypeopts);
            
        });
        $A.enqueueAction(shipmentTypeAction);
    },
    
    fetchingExistingRMA : function(component, event, helper){
        var action = component.get("c.displayRMA");
        var rmaID = component.get("v.ReturnMAID");
        action.setParams({
            returnId:rmaID
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                if(!$A.util.isEmpty(response.getReturnValue()) && !$A.util.isUndefinedOrNull(response.getReturnValue())){
                    component.set("v.RMA",response.getReturnValue().RMA.Name);
                    component.set("v.defaultShipmentType",response.getReturnValue().defaultShipmentType);
                    component.set("v.defaultShipmentSpeed",response.getReturnValue().defaultShipmentSpeed);
                    component.set("v.disablePackName",response.getReturnValue().disablePackName);
                    component.set("v.disablePackDeclaredValue",response.getReturnValue().disablePackDeclaredValue);
                    component.set("v.allowZerodeclaredValue",response.getReturnValue().allowZerodeclaredValue);
                    component.set("v.disableShipmentType",response.getReturnValue().disableShipType);
                    component.set("v.SSTypeAccess",response.getReturnValue().showSSType);
                    component.set("v.package.ERP7__Shipment_Service_Type__c", component.get("v.defaultShipmentSpeed"));
                }
                helper.getDependentPicklists(component, event, helper);
            }else{
                var errors = response.getError();
                console.log("server error fetchingExistingRMA : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }     
        });
        $A.enqueueAction(action);
    },
    
    fetchingRMALI : function(component, event, helper){
        var rmaliAction = component.get("c.fetchRMALineItems");
        rmaliAction.setParams({
            returnId:component.get("v.ReturnMAID")
        });
        rmaliAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('RMA List:',JSON.stringify(response.getReturnValue()));
                var WrapperList = response.getReturnValue();
                WrapperList.forEach(function(item) {
                    if (item.rma.ERP7__Acceptance_Type__c == 'Replacement') {
                        item.rma.ERP7__Serial_Number__c = '';
                        item.rma.ERP7__Batch_Lot__c = '';
                    }
                });
                component.set("v.rmawrapperList", WrapperList);

            }else{
                var errors = response.getError();
                console.log("server error fetchRMALineItems doInit : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }  
        });
        $A.enqueueAction(rmaliAction);
    },
    
    getDependentPicklists : function(component, event, helper) {
        console.log('getDependentPicklists called');
        var action = component.get("c.getDependentPicklistMap");
        action.setParams({
            ObjectName : component.get("v.objDetail"),
            parentField : component.get("v.controllingFieldAPI"),
            childField : component.get("v.dependingFieldAPI")
        });
        
        action.setCallback(this, function(response){
            var status = response.getState();
            console.log('status : ',status);
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                console.log('pickListResponse : ',response.getReturnValue());
                //save response 
                component.set("v.depnedentFieldMap",pickListResponse.pickListMap);
                
                // create a empty array for store parent picklist values 
                var parentkeys = []; // for store all map keys 
                var parentField = []; // for store parent picklist value to set on lightning:select. 
                
                // Iterate over map and store the key
                for (var pickKey in pickListResponse.pickListMap) {
                    parentkeys.push(pickKey);
                }
                
                //set the parent field value for lightning:select
                /* if (parentkeys != undefined && parentkeys.length > 0) {
                    parentField.push('--None--');
                }*/
                
                for (var i in parentkeys) {
                    parentField.push(parentkeys[i]);
                }  
                // set the parent picklist
                component.set("v.listControllingValues", parentField);
                console.log('listControllingValues : ',component.get("v.listControllingValues"));
                //
                var shiptype = component.get("v.defaultShipmentType");
                if(shiptype == null || shiptype == '' || shiptype == undefined){
                    component.set("v.package.ERP7__Shipment_Type__c", 'FedEx');
                }else component.set("v.package.ERP7__Shipment_Type__c", shiptype);
                
                var pickListMap = component.get("v.depnedentFieldMap");
                console.log('pickListMap : ',JSON.stringify(pickListMap));
                if(component.get("v.package.ERP7__Shipment_Type__c") != null && component.get("v.package.ERP7__Shipment_Type__c") != '' && component.get("v.package.ERP7__Shipment_Type__c") != undefined){
                    shiptype = component.get("v.package.ERP7__Shipment_Type__c")
                    var childValues = (pickListMap != null && pickListMap != undefined) ? pickListMap[shiptype] : [];
                    if(childValues == null || childValues == undefined) childValues = [];
                    var childValueList = [];
                    // childValueList.push('--None--');
                    for (var i in childValues) {
                        childValueList.push(childValues[i]);
                    }
                    // set the child list
                    console.log('childValueList: ',childValueList);
                    component.set("v.listDependingValues", childValueList);
                    
                    if(childValues.length > 0){
                        component.set("v.bDisabledDependentFld" , false);  
                        component.set("v.package.ERP7__Package_Type__c",component.get("v.listDependingValues")[0]);
                    }else{
                        component.set("v.bDisabledDependentFld" , true); 
                    }
                    
                }
                else {
                    component.set("v.listDependingValues", ['Package']);
                    component.set("v.package.ERP7__Package_Type__c",'Package');
                    component.set("v.bDisabledDependentFld" , true);
                }
                helper.displayPackageDetails(component,event,helper);
            }
            else{
                console.log('err : ',response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    displayPackageDetails : function(component, event, helper){
        console.log('displayPackageDetails called');
        component.set("v.isLoading",true);
        var packType = component.get("v.package.ERP7__Package_Type__c"); //event.getSource().get("v.value");
        console.log('displayPackageDetails~>'+packType);
        var action = component.get("c.populatePackDetails");
        action.setParams({
            Package2Create1:JSON.stringify(component.get("v.package")),
            pkgTypeValue:packType
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                if(response.getReturnValue() != undefined && response.getReturnValue() != null){
                    console.log('displayPackageDetails response~>'+JSON.stringify(response.getReturnValue()));
                    component.set("v.pkgtypenotallowed",false);
                    component.set("v.package", response.getReturnValue());
                    //component.set("v.package.ERP7__Shipment_Type__c", component.get("v.frieghtType"));
                    component.set("v.package.ERP7__Declared_Value__c", component.get("v.refundAmt"));
                    //component.set("v.package.ERP7__Package_Type__c", pacType);
                    component.set("v.isLoading",false);
                    /*component.set("v.package.ERP7__Weight__c", response.getReturnValue().ERP7__Weight__c);
                 component.set("v.package.ERP7__Height__c", response.getReturnValue().ERP7__Height__c);
            	 component.set("v.package.ERP7__Length__c", response.getReturnValue().ERP7__Length__c);
            	 component.set("v.package.ERP7__Width__c", response.getReturnValue().ERP7__Width__c);
                 component.set("v.package.ERP7__Description__c", response.getReturnValue().ERP7__Shipment_Description__c);
                 */
                }else{
                    component.set("v.package.ERP7__Weight__c", 0);
                    component.set("v.package.ERP7__Height__c", 0);
                    component.set("v.package.ERP7__Length__c", 0);
                    component.set("v.package.ERP7__Width__c", 0);
                    component.set("v.isLoading",false);
                }
            }else{
                component.set("v.pkgtypenotallowed",true);
                component.set("v.package.ERP7__Weight__c", 0);
                component.set("v.package.ERP7__Height__c", 0);
                component.set("v.package.ERP7__Length__c", 0);
                component.set("v.package.ERP7__Width__c", 0);
                component.set("v.isLoading",false);
                var errors = response.getError();
                console.log("server error displayPackageDetails : ", errors);
                component.set("v.errorMessage", $A.get('$Label.c.PH_RMA_PACK_Sorry_selected_package_type_not_available'));
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }
        });
        $A.enqueueAction(action);
    },
})