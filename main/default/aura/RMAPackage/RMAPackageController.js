({
    doInit : function(component, event, helper){
        try{
            console.log('Init RMAPackage called');
        component.set("v.isLoading",true);
            
        console.log('component.get("v.isforRMA")==>'+component.get("v.isforRMA"));
            let ref = component.get('v.pageReference'); 
                
            let param01 = ref.state.c__isforRMAevt;
            console.log('param01==>'+param01);
            component.set("v.isforRMA",param01);
            if(component.get("v.isforRMA")== param01){
                component.set("v.isforRMA",param01);
            }
            
            
            if(component.get("v.isforRMA")==true  ){
                let ref = component.get('v.pageReference'); 
                
                let param1 = ref.state.c__selectedTabEvt;
                let param2 = ref.state.c__showShipComponentEvt;
                let param3 = ref.state.c__rmaReturnIdEvt;
                
                component.set( 'v.selectedTab', param1);
                component.set( 'v.showShipComponent', param2);
                component.set("v.ReturnMAID",param3);
                
                console.log('param1-->'+param1);
                console.log('param2-->'+param2);
                console.log('ReturnMAID==>'+component.get("v.ReturnMAID"));
                
            }
        var getobjName = component.get("c.getobjName");
        getobjName.setCallback(this, function(a){
            if(a.getState() === "SUCCESS"){
                component.set("v.RMAObjectLabel",a.getReturnValue());
                if(a.getReturnValue() != undefined && a.getReturnValue() != null && a.getReturnValue() != ''){
                    if(a.getReturnValue() == 'Return goods Authorization (RGA)'){
                        component.set("v.RMAObjectLabel",'Return Goods Authorization (RGA)');
                    }
                }
            }
        });
        $A.enqueueAction(getobjName);
        
        var action = component.get("c.getWeightUnits");
        
        var opts=[];
        opts.push({"class": "optionClass", label:"--None--", value: ""});
        action.setCallback(this, function(a){
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.InputSelectDynamicOptions",opts);
            
        });
        $A.enqueueAction(action);
        
        var packageTypeAction = component.get("c.getPackageType");
        var packagetypeopts=[];
        packagetypeopts.push({"class": "optionClass", label:"--None--", value: ""});
        packageTypeAction.setCallback(this, function(a){
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
        
        if(!$A.util.isEmpty(component.get("v.frieghtType")) && !$A.util.isUndefinedOrNull(component.get("v.frieghtType"))){
            component.set("v.package.ERP7__Shipment_Type__c", component.get("v.frieghtType"));
        }else{
            if(shipmenttypeopts.length>0) component.set("v.package.ERP7__Shipment_Type__c", shipmenttypeopts[0].value);
        }
        component.set("v.package.ERP7__Declared_Value__c", component.get("v.refundAmt"));
        if(packagetypeopts.length>0) component.set("v.package.ERP7__Package_Type__c", packagetypeopts[0].value);
        
            console.log('ReturnMAID-->'+component.get("v.ReturnMAID"));
        //if(ReturnMAID != null && ReturnMAID != undefined)
        if(component.get("v.ReturnMAID") != null && component.get("v.ReturnMAID") != undefined){
            helper.fetchingRMALI(component, event, helper);
            helper.fetchExistingRMAPkg(component, event, helper);
            helper.fetchingExistingShipments(component, event, helper);
            helper.fetchingExistingRMA(component, event, helper);    
        }     
        setTimeout(function(){component.set("v.isLoading", false);}, 5000);
            
        }catch(e){
            console.log('error--->'+e);
        }
    },
    
    parentFieldChange : function(component, event, helper) {
        console.log('parentFieldChange : ',component.get("v.package.ERP7__Shipment_Type__c"));
    	//var controllerValue = component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
        var pickListMap = component.get("v.depnedentFieldMap");
        console.log('pickListMap : '+pickListMap);
        var controllerValue =component.get("v.package.ERP7__Shipment_Type__c");
        if (controllerValue != '--None--' && controllerValue != undefined && controllerValue != null && controllerValue != '' && pickListMap != null && pickListMap != undefined) {
            console.log('in parent');
             //get child picklist value
            var childValues = pickListMap[controllerValue];
            var childValueList = [];
           // childValueList.push('--None--');
            for (var i in childValues) {
                childValueList.push(childValues[i]);
            }
            // set the child list
            component.set("v.listDependingValues", childValueList);
            
            if(childValues.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                component.set("v.package.ERP7__Package_Type__c",component.get("v.listDependingValues")[0]);
            }else{
                component.set("v.bDisabledDependentFld" , true); 
            }
            helper.displayPackageDetails(component,event,helper);
        } else {
            component.set("v.listDependingValues", ['Package']);
            component.set("v.bDisabledDependentFld" , true);
        }
	},
    
    closeError : function(component, event, helper) {
        component.set("v.errorMessage","");
    },
    
    savePackages : function(component, event, helper){
        component.set("v.isLoading",true);
        console.log('savePackages  called');
        var pkgDetails = JSON.stringify(component.get("v.package"));
        var rmaLiDetails = component.get("v.rmawrapperList");
        
        var SOLIlist2create =[];
        for(var j=0;j<rmaLiDetails.length; j++){
            if(rmaLiDetails[j].rma.ERP7__Acceptance_Type__c == 'Replacement') {
                var obj = { 
                    
                    ERP7__Product__c:rmaLiDetails[j].rma.ERP7__Product__c,
                    ERP7__Quantity__c:rmaLiDetails[j].rma.ERP7__Quantity_Return__c,
                    ERP7__Active__c:true,                  
                    ERP7__Site_Product_Service_Inventory_Stock__c: rmaLiDetails[j].rma.ERP7__Site_Item_Inventory_Stock__c,
                    ERP7__Serial__c: rmaLiDetails[j].rma.ERP7__Serial_Number__c,
                    ERP7__Batch_Lot_Code__c: rmaLiDetails[j].rma.ERP7__Batch_Lot__c,
                    ERP7__Status__c:"Committed",
                    ERP7__Order__c: rmaLiDetails[j].rma.ERP7__Return_Merchandise_Authorisation__r.ERP7__Order__c,
                    ERP7__Order_Product__c: rmaLiDetails[j].rma.ERP7__Ord_Item__c,
                    ERP7__RMA_Line_Item__c: rmaLiDetails[j].rma.Id
                };
                SOLIlist2create.push(obj);
            }
        }
        
        console.log('SOLIlist2create:',JSON.stringify(SOLIlist2create));
        
        var rmaArr = [];
        for(var i=0; i<rmaLiDetails.length; i++){
            if(rmaLiDetails[i].isSelected) {
                rmaArr.push(rmaLiDetails[i]);
            }
        }
       
        var bool = true;
        if($A.util.isEmpty(component.get("v.package.ERP7__Package_Type__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Package_Type__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_Select_Package_Type'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Shipment_Type__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Shipment_Type__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_Select_Shipment_Type'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Weight__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Weight__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_Weight'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if(component.get("v.package.ERP7__Weight__c") <= 0){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Weight_should_be_greater_than_0'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Weight_Unit__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Weight_Unit__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_Select_Weight_Unit'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Length__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Length__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_length'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if(component.get("v.package.ERP7__Length__c") <= 0){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Length_should_be_greater_than_0'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Width__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Width__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_width'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if(component.get("v.package.ERP7__Width__c") <= 0){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Width_should_be_greater_than_0'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Height__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Height__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_height'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if(component.get("v.package.ERP7__Height__c") <= 0){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Height_should_be_greater_than_0'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if(($A.util.isEmpty(component.get("v.package.ERP7__Declared_Value__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Declared_Value__c"))) && component.get("v.allowZerodeclaredValue") == false){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_Declared_Value'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if(component.get("v.package.ERP7__Declared_Value__c") <= 0  && component.get("v.allowZerodeclaredValue") == false){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Declared_Value_should_be_greater_than_0'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }
            
        
        var action = component.get("c.savePackageDetails");
        action.setParams({
            pkg1 : pkgDetails,
            rmaLiWrapList : JSON.stringify(rmaArr),
            rmaId : component.get("v.ReturnMAID"),
            SOLIs : JSON.stringify(SOLIlist2create)
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('Response in savePackages~>'+JSON.stringify(response.getReturnValue()));
                component.set("v.packageList",response.getReturnValue());
                component.set("v.pkgListBool",true);
                component.set("v.pkgBool",false);
                component.set("v.isLoading",false);
            }else{ 
                component.set("v.isLoading",false);
                var errors = response.getError();
                console.log("server error savePackages : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            } 
        });
        if(component.get("v.pkgtypenotallowed")){
            component.set("v.isLoading",false);
            component.set("v.errorMessage", $A.get('$Label.c.PH_RMA_PACK_Sorry_selected_package_type_not_available'));
            setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
        }else{
            if(bool){
                if(rmaArr.length>0){
                    $A.enqueueAction(action);
                }else{
                    component.set("v.isLoading",false);
                    component.set("v.errorMessage", $A.get('$Label.c.PH_RMA_PACK_Select_atleast_one_line_item_to_create_package'));
                    setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
                }
            }else{
                console.log('bool is false in savePackages');
                component.set("v.isLoading",false);
            } 
        }
        
    },
    
    cancelRMAPackage : function(component, event, helper){
        console.log('ReturnMAID~>'+component.get("v.ReturnMAID"));
        $A.createComponent(
            "c:RMA", {
                "RMAId":component.get("v.ReturnMAID")
            },
            function(newCmp) {
                if(component.isValid()){
                    var body = component.find("sldshide");
                    body.set("v.body", newCmp);
                }
            }
        );
    },
    
    removeshipcmp: function(component, event, helper){
        component.set("v.isLoading",true);
        component.set("v.showShipComponent",false);
        helper.fetchExistingRMAPkg(component, event, helper);
        helper.fetchingExistingShipments(component, event, helper);
        helper.fetchingExistingRMA(component, event, helper);    
        setTimeout(function(){component.set("v.isLoading",false);}, 3000);
    },
    
    displayPackageDetails : function(component, event, helper){
        helper.displayPackageDetails(component,event,helper);
    },
    
    editPackagePanel :  function(component, event, helper){
        component.set("v.isLoading",true);
        var selectedItem = event.currentTarget;
        var recordId= selectedItem.dataset.record;
        helper.picVal(component, event, helper);
        var action = component.get("c.editPackages");
        action.setParams({
            packageID:recordId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                if(!$A.util.isEmpty(response.getReturnValue()) && !$A.util.isUndefinedOrNull(response.getReturnValue())){
                    component.set("v.package", response.getReturnValue());
                    $A.enqueueAction(plAction);
                    //component.set("v.packageListEdit", response.getReturnValue());
                    setTimeout(function(){component.set("v.isLoading", false);}, 5000);
                }else{
                    component.set("v.isLoading",false);
                    component.set("v.errorMessage", $A.get('$Label.c.PH_RMA_PACK_No_Package_Found'));
                    setTimeout(function(){component.set("v.errorMessage", "");}, 3000);
                }
            }else{
                component.set("v.isLoading",false);
                var errors = response.getError();
                console.log("server error editPackages editPackagePanel : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }    
        });
        $A.enqueueAction(action);
        
        var plAction = component.get("c.fetchPackageListEdit");
        plAction.setParams({
            packageID:recordId
        });
        plAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.rmawrapperList", []);
                component.set("v.packageListEdit", response.getReturnValue());
                component.set("v.pkgListBool",false);
                component.set("v.pkgBool",false);
                component.set("v.editPkgBool",true);
            }else{
                var errors = response.getError();
                console.log("server error fetchPackageListEdit editPackagePanel : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }  
        });
    },
    
    deletePackagePanel : function(component, event, helper){
        component.set("v.isLoading",true);
        var selectedItem = event.currentTarget;
        var recordId= selectedItem.dataset.record;
        var action = component.get("c.deletePackages");
        action.setParams({
            packID:recordId,
            returnId:component.get("v.ReturnMAID"),
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.packageList",response.getReturnValue());
                helper.fetchingRMALI(component, event, helper);
                helper.fetchExistingRMAPkg(component, event, helper);
                helper.fetchingExistingShipments(component, event, helper);
                helper.fetchingExistingRMA(component, event, helper);    
                setTimeout(function(){component.set("v.isLoading",false);}, 5000);
            }else{
                component.set("v.isLoading",false);
                var errors = response.getError();
                console.log("server error deletePackagePanel : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }  
        });
        var result = confirm("Do you want to delete this package?");
        if(result) $A.enqueueAction(action); else component.set("v.isLoading",false);
    },
    
    deleteShipment : function(component, event, helper){
        component.set("v.isLoading",true);
        var selectedItem = event.currentTarget;
        var recordId= selectedItem.dataset.record;
        var action = component.get("c.deleteShipments");
        action.setParams({
            shipId:recordId,
            returnId:component.get("v.ReturnMAID")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.shipmentList",response.getReturnValue());
                helper.fetchExistingRMAPkg(component, event, helper);
                helper.fetchingExistingShipments(component, event, helper);
                helper.fetchingExistingRMA(component, event, helper);    
                setTimeout(function(){component.set("v.isLoading",false);}, 3000);
            }else{
                component.set("v.isLoading",false);
                var errors = response.getError();
                console.log("server error deleteShipment : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }  
        });
        var result = confirm("Do you want to delete this shipment?");
        if(result) $A.enqueueAction(action); else component.set("v.isLoading",false);
    },
    
    cancelEditPackage : function(component, event, helper){
        component.set("v.pkgListBool",true);
        component.set("v.pkgBool",false);
        component.set("v.editPkgBool",false);
    },
    
    savePack : function(component, event, helper){
        component.set("v.isLoading",true);
        var pkgDetails = JSON.stringify(component.get("v.package"));
        var rmaLiDetails = component.get("v.rmawrapperList");
        var rmaArr = [];
        for(var i=0; i<rmaLiDetails.length; i++){
            if(rmaLiDetails[i].isSelected){
                rmaArr.push(rmaLiDetails[i]);
            }
        }
        console.log('pkgDetails~>'+pkgDetails);
        console.log('rmaLiDetails~>'+JSON.stringify(rmaArr));
        console.log('ReturnMAID~>'+component.get("v.ReturnMAID"));
        
        var bool = true;
        if($A.util.isEmpty(component.get("v.package.ERP7__Package_Type__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Package_Type__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_Select_Package_Type'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Shipment_Type__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Shipment_Type__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_Select_Shipment_Type'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Weight__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Weight__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_Weight'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Weight_Unit__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Weight_Unit__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_Select_Weight_Unit'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Length__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Length__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_length'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Width__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Width__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_width'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Height__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Height__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_height'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }else if($A.util.isEmpty(component.get("v.package.ERP7__Declared_Value__c")) || $A.util.isUndefinedOrNull(component.get("v.package.ERP7__Declared_Value__c"))){
            bool = false;
            component.set("v.errorMessage",$A.get('$Label.c.PH_RMA_PACK_Please_enter_Declared_Value'));
            setTimeout(function(){
                component.set("v.errorMessage", "");
            }, 5000);
        }
        
        var action = component.get("c.savePackageDetails");
        action.setParams({
            pkg1 : pkgDetails,
            rmaLiWrapList : JSON.stringify(rmaArr),
            rmaId : component.get("v.ReturnMAID")
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                component.set("v.packageList",response.getReturnValue());
                component.set("v.pkgListBool",true);
                component.set("v.pkgBool",false);
                component.set("v.editPkgBool",false);
                component.set("v.isLoading",false);
            }else{
                component.set("v.isLoading",false);
                var errors = response.getError();
                console.log("server error savePack : ", errors);
                component.set("v.errorMessage", errors[0].message);
                setTimeout(function(){component.set("v.errorMessage", "");}, 5000);
            }  
        });
        if(bool){
            $A.enqueueAction(action);
        }else{
            component.set("v.isLoading",false);
            console.log('bool is false');
        }
    },
    
    selectAll : function(component, event, helper){
        var maincheck = event.getSource().get("v.checked");
        var allRecords = component.get("v.rmawrapperList");
        if(allRecords.length>0){
            for(var i in allRecords){
                if(maincheck){
                    allRecords[i].isSelected = true;
                }else{
                    allRecords[i].isSelected = false;
                }
            }
        }
        component.set("v.rmawrapperList",allRecords);
    },
    
    checkmaincheckbox : function(component, event, helper){
        var allRecords = component.get("v.rmawrapperList");
        var index = event.getSource().get("v.label");
        console.log("Index checkmaincheckbox:", index);
        var bool = false;
        if(allRecords.length>0){
            for(var i in allRecords){
                if(allRecords[i].isSelected){
                    bool = true;
                }else{
                    bool = false;
                    break;
                }
            }
        }
        if(bool) component.find("selectallrmali").set("v.checked",true); else component.find("selectallrmali").set("v.checked",false);
    },
    /* FedexComponent : function(component, event, helper){
        var packId = event.currentTarget.dataset.record;
        
        $A.createComponent(
            "c:FedEx", {
                "packageId":packId
            },
            function(newCmp) {
                if (component.isValid()) {
                    var body = component.find("sldshide");
                    body.set("v.body", newCmp);
                    
                }
            }
        );
    }, */
    
    changeTab: function(component, event, helper){
        console.log('changeTab called~>'+event.getParam('id'));
        
        /*var tab = '';
         if(!$A.util.isEmpty(event.getParam('id')) && !$A.util.isUndefinedOrNull(event.getParam('id'))) tab = event.getParam('id');
         console.log('tab~>'+tab);
        if(!$A.util.isEmpty(tab) && !$A.util.isUndefinedOrNull(tab)) component.set("v.selectedTab",tab);
        console.log('selectedTab~>'+component.get("v.selectedTab"));
        if(component.get("v.selectedTab") == 'ship') component.set("v.showShipComponent",true); else component.set("v.showShipComponent",false);*/
    },
    
    packtoship : function(component, event, helper){
        var packId = event.currentTarget.dataset.record; 
        var shipId =event.currentTarget.dataset.variablename;
        var shipmentType = event.currentTarget.dataset.resource; 
        console.log('packId~>'+packId);
        console.log('shipmentType~>'+shipmentType);
        var selectedPackIds = []; 
        /*$A.createComponent(
            "c:InternalShipment", {
                "packageID":packId,
                "shipmentID":shipId,
            },
            function(newCmp) {
                if (component.isValid()) {
                    var body = component.find("sldshide");
                    body.set("v.body", newCmp);
                    
                }
            }
        );*/
        if(!$A.util.isEmpty(packId) && !$A.util.isUndefinedOrNull(packId)){
            selectedPackIds.push(packId);
            console.log('selectedPackIds~>'+selectedPackIds);
            component.set('v.selectedPackIds',selectedPackIds);

            if(!$A.util.isEmpty(shipmentType) && !$A.util.isUndefinedOrNull(shipmentType)){
                if(shipmentType == 'UPS'){
                    $A.createComponent("c:UPS",{
                        "packageId":selectedPackIds,
                        "isforRMA":true,
                    }, function(newCmp, status, errorMessage){
                        if (status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");
                            body.set("v.body", newCmp);
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    });
                } else if(shipmentType == 'USPS'){
                    $A.createComponent("c:USPS", {
                        "packageId":selectedPackIds,
                    }, function(newCmp, status, errorMessage){
                        if (status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");                            
                            body.set("v.body", newCmp);  
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    }); 
                }
                /*
                    else if(shipmentType == 'FedEx'){
                    $A.createComponent("c:FedEx", {
                        "packageId":selectedPackIds,
                        "retValue":"SR",
                        "isforRMA":true,
                    }, function(newCmp, status, errorMessage){
                        if (status === "SUCCESS"){
                            console.log('status->'+status);
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");                            
                            body.set("v.body", newCmp);  
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    });
                } */
                    else if(shipmentType == 'FedEx'){
                    console.log('shipment type is fedex');
                    component.set('v.pkgListBool',false);
                    component.set('v.showFedexRestAPIcomp',true);
                    component.set('v.retValue', 'SR'); 
                    
                    //console.log('retValue==>'+component.get(v.retValue));
    				component.set('v.isforRMA', true);
                   	
                }
               
                else if(shipmentType == 'DHL'){
                    $A.createComponent("c:DHL", {
                        "packageId":selectedPackIds,
                    }, function(newCmp, status, errorMessage){
                        if(status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");                            
                            body.set("v.body", newCmp);  
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    });
                    
                } else { //if(shipmentType == 'Shipment')
                    $A.createComponent("c:InternalShipment",{
                        "packageIDS":selectedPackIds,
                        "showHeader":false,
                    },function(newCmp, status, errorMessage){
                        if (status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");                            
                            body.set("v.body", newCmp);  
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    });
                }
            }else{
                console.log('shipmentType is empty~>'+shipmentType);
            }
        }else{
            console.log('packId is empty~>'+packId);
        } 
    },
    
    
    
    gotoshipment: function(component, event, helper){
        console.log('gotoshipment called');
        var shipId = event.currentTarget.dataset.record;
        console.log('shipId=>'+shipId);
        var shipmentType = '';
        
        var packId = event.currentTarget.dataset.record; 
        console.log('packId~>'+packId);
        var selectedPackIds = [];
        
        shipmentType = event.currentTarget.dataset.variablename;
        console.log('shipmentType=>'+shipmentType);
        
        if(!$A.util.isEmpty(packId) && !$A.util.isUndefinedOrNull(packId)){
            console.log('entered if 1');
            selectedPackIds.push(packId);
            console.log('selectedPackIds~>'+selectedPackIds);
            component.set('v.selectedPackIds',selectedPackIds);
        
        if(!$A.util.isEmpty(shipId) && !$A.util.isUndefinedOrNull(shipId)){
            console.log('entered if 2');
            if(!$A.util.isEmpty(shipmentType) && !$A.util.isUndefinedOrNull(shipmentType)){
                console.log('entered if 3');
                if(shipmentType == 'UPS Shipping'){
                    $A.createComponent("c:UPS",{
                        "shipmentId":shipId,
                        "isforRMA":true,
                    }, function(newCmp, status, errorMessage){
                        if (status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");
                            body.set("v.body", newCmp);
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    });
                } else if(shipmentType == 'USPS Shipping'){
                    /*$A.createComponent("c:USPS", {
                        "packageId":selectedPackIds,
                    }, function(newCmp, status, errorMessage){
                        if (status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");                            
                            body.set("v.body", newCmp);  
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    }); */
                } else if(shipmentType == 'Fedex Shipping'){
                    console.log('entered Fedex Shipping 1');
                    component.set('v.pkgListBool',false);
                    component.set('v.showFedexRestAPIcomp',true),
                    component.set('v.retValue', 'SR'); 
    				component.set('v.isforRMA', true);
                    component.set("v.selectedTab","pack");
                    console.log('entered Fedex Shipping 2');
                     /*function(newCmp, status, errorMessage){
                        if (status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");                            
                            body.set("v.body", newCmp);  
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    };*/
                } else if(shipmentType == 'DHL Shipping'){
                    /*$A.createComponent("c:DHL", {
                        "packageId":selectedPackIds,
                    }, function(newCmp, status, errorMessage){
                        if(status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");                            
                            body.set("v.body", newCmp);  
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    });*/
                } else { //if(shipmentType == 'Shipment')
                    $A.createComponent("c:InternalShipment",{
                        "shipmentID":shipId,
                        "showHeader":false,
                    },function(newCmp, status, errorMessage){
                        if (status === "SUCCESS"){
                            component.set("v.selectedTab","ship");
                            component.set("v.showShipComponent",true);
                            var body = component.find("shipcmp");                            
                            body.set("v.body", newCmp);  
                        }else{
                            console.log("Error : ", errorMessage);
                        }
                    });
                }
            }else{
                console.log('Invalid/null shipment type~>'+shipmentType);
            }
        }
        }else{
            console.log('packId is null/undefined~>'+shipId);
        }   
    },
    
    gobacktoRMAPage:function(comp,event,helper){
        if(comp.get('v.ReturnMAID') !=''){
            var RecUrl = "/lightning/r/ERP7__Return_Merchandise_Authorisation__c/" + comp.get('v.ReturnMAID') + "/view";
            window.open(RecUrl,'_parent');
        }else{
            window.history.back();
        }
    },
    
    OpenMyModalPickSerial: function (cmp, event) {
        $A.util.addClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
        var index = event.getSource().get("v.label");
        cmp.set("v.currentIndex",index);
        cmp.set('v.PickMultiScreenInUse',true);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        
        var rmalineId = event.getSource().get("v.name");
        console.log('RMAline item Id~>',rmalineId);
        var RemainingQty = event.getSource().get("v.value");
        
        cmp.set("v.RemainingQty", RemainingQty);
        cmp.set("v.rmalineId", RemainingQty);
		console.log('RMAline item RemainingQty~>',RemainingQty);
	        
        var action = cmp.get("c.PreparePickSerialNos");
        action.setParams({
            RMALineId: rmalineId,
            searchString: "",
            //reservedSelectedSerials: []
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                //console.log(response.getReturnValue());
                const availableSerials = response.getReturnValue().PickSerialNos;
                const stockAvailableSerials = availableSerials.filter(serial => serial.ProductsiteInventory !== '');
                cmp.set("v.PickSerialNos", stockAvailableSerials);
                console.log('PickSerialNos:~>',JSON.stringify(cmp.get("v.PickSerialNos")));
                cmp.set("v.PickSelectedSerialNos", response.getReturnValue().PickSelectedSerialNos);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");  
            }
        });
        $A.enqueueAction(action);
    },
    
    CloseMyModalPickSerial: function (cmp, event) {
        $A.util.removeClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
    },
    
      PickSerialNosDiv: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SId = event.currentTarget.getAttribute('data-serialId');
        var obj = cmp.get("v.PickSerialNos");
        var selectedCount = 0;
        for(var x in obj){
            if(SId == obj[x].SerialNo.Id) obj[x].isSelected = !obj[x].isSelected;
            if(obj[x].isSelected) selectedCount++;
        }
        cmp.set("v.disableAdd", (selectedCount == 0 || selectedCount > (cmp.get("v.RemainingQty") - cmp.get("v.PickSelectedSerialNos").length)));
        cmp.set("v.PickSerialNos", obj);
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },
    
    PickSelectedSerialNosDiv: function(cmp, event) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var SId = event.currentTarget.getAttribute('data-serialId');
        var obj = cmp.get("v.PickSelectedSerialNos");
        var selectedCount = 0;
        for(var x in obj){
            if(SId == obj[x].SerialNo.Id) obj[x].isSelected = !obj[x].isSelected;
            if(obj[x].isSelected) selectedCount++;
        }
        cmp.set("v.disableRemove", !(selectedCount > 0));
        cmp.set("v.PickSelectedSerialNos", obj);
        console.log('PickSelectedSerialNosDiv',cmp.get("v.PickSelectedSerialNos"));
        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
    },
    
    getavailableBatches: function(cmp,event,handler){
        try{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var productId = event.currentTarget.getAttribute('data-record');
            var CurrSiteId = event.currentTarget.getAttribute('data-record-SiteId'); 
            console.log('productId:',productId)
            console.log('CurrSiteId:',CurrSiteId)
            var action = cmp.get("c.getAvailableBatches");
            action.setParams({
                currProdId: productId,
                site:CurrSiteId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    console.log('Result of getavailableBatches:',JSON.stringify(response.getReturnValue()));
                    cmp.set("v.availBatchIds", response.getReturnValue());
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");  
                }
            });
            $A.enqueueAction(action);
            
        }
        catch(e){console.log('Exception in getavailableBatches:',e);}
    },
    
    AddSerials: function (cmp, event) {
        cmp.set("v.disableAdd", true);
        var objSource = cmp.get("v.PickSerialNos");
        var objDestn = cmp.get("v.PickSelectedSerialNos");        
        var i = 0;
        while (i < objSource.length) {
            if (objSource[i].isSelected) {
                objSource[i].isSelected = false;
                objDestn.unshift(objSource[i]);
                objSource.splice(i, 1);
            } else {
                ++i;
            }
        }
        cmp.set("v.PickSerialNos",objSource);
        cmp.set("v.PickSelectedSerialNos",objDestn);
        console.log('AddSerials selectedSerials:',cmp.get("v.PickSelectedSerialNos"));
        cmp.set('v.selectAllSerials', false);
    },
    
    RemoveSerials: function (cmp, event) {
        cmp.set("v.disableRemove", true);
        var objSource = cmp.get("v.PickSelectedSerialNos");
        var objDestn = cmp.get("v.PickSerialNos");
        var i = 0;
        while (i < objSource.length) {
            if (objSource[i].isSelected) {
                objSource[i].isSelected = false;
                objDestn.unshift(objSource[i]);
                objSource.splice(i, 1);
            } else {
                ++i;
            }
        }
        cmp.set("v.PickSerialNos",objDestn);
        cmp.set("v.PickSelectedSerialNos",objSource);
        cmp.set('v.selectAllSerials', false);
    },
    
    AddAllSerials: function (cmp, event) {
        console.log('AddAllSerials called');
        var objSource = cmp.get("v.PickSerialNos");
        var objDestn = cmp.get("v.PickSelectedSerialNos");   
        var RemainingQty = cmp.get("v.RemainingQty");
        var i = 0;
        while (i < objSource.length && objDestn.length < 500 && objDestn.length < RemainingQty ) {
            objSource[i].isSelected = false;
            objDestn.unshift(objSource[i]);
            objSource.splice(i, 1);
        }
        cmp.set("v.PickSerialNos",objSource);
        cmp.set("v.PickSelectedSerialNos",objDestn);
        cmp.set('v.selectAllSerials', false);
    },
    
    RemoveAllSerials: function (cmp, event) {
        var objSource = cmp.get("v.PickSelectedSerialNos");
        var objDestn = cmp.get("v.PickSerialNos");
        var i = 0;
        while (i < objSource.length) {
            objSource[i].isSelected = false;
            objDestn.unshift(objSource[i]);
            objSource.splice(i, 1);
        }
        cmp.set("v.PickSerialNos",objDestn);
        cmp.set("v.PickSelectedSerialNos",objSource);
        cmp.set('v.selectAllSerials', false);
    },
    
   changeInitialSerial : function(cmp, event){
        if(cmp.get("v.initialSTOLISerial") == ""){
            cmp.set("v.initialSTOLISerial", event.currentTarget.dataset.recordId);
        }
    },
    
    fetchSerialStock : function(cmp, event, helper) {
        console.log('fetchSerialStock called');
        try{
            let serialId = event.currentTarget.dataset.recordId;
            
            if(serialId != '' && serialId != null && serialId != undefined){
                console.log('serialId : ',serialId);
            }
        }catch(e){
            console.log('err~>'+e);
        }
    },
    
    PickMultiSerials: function (cmp, event) {
        try{
            
            console.log('PickMultiSerials called');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            
            var loglineId = cmp.get("v.rmalineId");
            var RemainingQty = cmp.get("v.RemainingQty");
            
            var selectedSerials = cmp.get("v.PickSelectedSerialNos");
            console.log('selectedSerials:', selectedSerials);
            var selectedSerialIds = [];
            
            var i = 0;
            while (i < selectedSerials.length && i < RemainingQty) { 
                console.log(selectedSerials[i].SerialNo.Name);
                selectedSerialIds.push(selectedSerials[i].SerialNo.Id);
                selectedSerialIds.push(selectedSerials[i].SerialNo.Name);
                i++;
            }
            var WrapperList = cmp.get("v.rmawrapperList");
            var index = cmp.get("v.currentIndex");
            
            // Ensure that index is within the bounds of WrapperList
            if (index >= 0 && index < WrapperList.length) {
                var j = 0;
                for (var k in WrapperList) {
                    if (WrapperList.hasOwnProperty(k)) {
                        WrapperList[k].rma.ERP7__Serial_Number__c = selectedSerials[j].SerialNo.Id;
                        WrapperList[k].rma.ERP7__Serial_Number__r.Id = selectedSerials[j].SerialNo.Id;
                        WrapperList[k].rma.ERP7__Serial_Number__r.ERP7__Serial_No__c = selectedSerials[j].SerialNo.Name;
                        WrapperList[k].rma.ERP7__Site_Item_Inventory_Stock__c = selectedSerials[j].ProductsiteInventory;
                        j++;
                        if (j >= selectedSerials.length) {
                            break;
                        }
                    }
                }
            }
            
            cmp.set("v.rmawrapperList", WrapperList);
            
            
            $A.util.removeClass(cmp.find("myModalPickSerial"), 'slds-fade-in-open');
            $A.util.removeClass(cmp.find("myModalMOSerialBackDrop"),"slds-backdrop_open");
            cmp.set('v.PickMultiScreenInUse',false);
            
        }
        catch(e){console.log('Exception in PickMultiSerials::',e);}
        
    },
    
    selectAllSerials : function (cmp,event) {
        var checkedval = event.getSource().get('v.checked');
        cmp.set('v.selectAllSerials', checkedval);
        var obj = cmp.get("v.PickSerialNos");
        var showSerialsCount = cmp.get("v.showSerials");
        //alert(showSerialsCount);
        var i = 0;
        for(var x in obj){
            if(i < showSerialsCount){
                obj[x].isSelected = checkedval;
                i++;
            }
        }
        //alert(showSerialsCount);
        cmp.set("v.PickSerialNos", obj);
        cmp.set("v.disableAdd",!checkedval);
    },
    
   handleMyEvent: function(cmp, event) {
        console.log('entered handleMyEvent');
        const selectedTab = event.getParam('selectedTabEvt');
        const showShipComponent = event.getParam('showShipComponentEvt');
        
        // Set the component attributes based on the event parameters
        cmp.set('v.selectedTab', selectedTab);
        cmp.set('v.showShipComponent', showShipComponent);
    }
    
});