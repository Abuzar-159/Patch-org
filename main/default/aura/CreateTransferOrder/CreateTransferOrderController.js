({
    doInit : function(component, event, helper) {
        console.log('Create TO doInit');
        helper.setChannelandDC(component, event);
        helper.setTOStatus(component, event);
         helper.getDependentPicklists(component, event, helper);
        console.log('prodRecordId 1st line: ',component.get('v.prodRecordId'));
        if(component.get('v.prodRecordId') != null && component.get('v.prodRecordId') != '' && component.get('v.prodRecordId') != undefined){
            helper.getProductDetails(component,helper);
        }
        //helper.setTOShipmenttype(component, event);
    },
    
    addNew : function(component, event, helper) {
        var transfer = component.get("v.TO");
        if($A.util.isEmpty(transfer.ERP7__Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__Channel__c)){
            setTimeout(function(){ component.set("v.exceptionError",$A.get('$Label.c.Please_select_a_channel')); }, 5000);
        }else if($A.util.isEmpty(transfer.ERP7__Distribution_Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__Distribution_Channel__c)){
            setTimeout(function(){ component.set("v.exceptionError",$A.get('$Label.c.Please_Select_a_Distribution_Channel'));  }, 5000);          
        }else if($A.util.isEmpty(transfer.ERP7__To_Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__To_Channel__c)){
            setTimeout(function(){ component.set("v.exceptionError",$A.get('$Label.c.Please_Select_a_Channel_to_transfer')); }, 5000);
        }else if($A.util.isEmpty(transfer.ERP7__To_Distribution_Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__To_Distribution_Channel__c)){
            setTimeout(function(){ component.set("v.exceptionError",$A.get('$Label.c.Please_Select_a_Distribution_Channel_to_transfer')); }, 5000);
        }else{
            var toliList = [];
            if(component.get("v.TOLI") != null) toliList = component.get("v.TOLI");
            toliList.unshift({sObjectType :'toliWrap'});
            component.set("v.TOLI",toliList);
        }
    },
    
    toChannelchange : function(component, event, helper){
        var transfer = component.get("v.TO");
        var qry = 'AND ERP7__Channel__c = \''+transfer.ERP7__To_Channel__c+'\' AND Id != \''+transfer.ERP7__Distribution_Channel__c+'\'';
        component.set("v.toDCqry",qry);
        if($A.util.isEmpty(transfer.ERP7__To_Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__To_Channel__c)){
            console.log('toChannelchange going to null to DC');
            component.set("v.TO.ERP7__To_Distribution_Channel__c",null);
        }
    },
    
    fromChannelchange : function(component, event, helper){
        var transfer = component.get("v.TO");
        if($A.util.isEmpty(transfer.ERP7__Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__Channel__c)){
            console.log('fromChannelchange going to null from DC');
            component.set("v.TO.ERP7__Distribution_Channel__c",null);
        }
    },
    
    deletetoli :function(component, event, helper) {
        var toliList =[]; 
        toliList=component.get("v.TOLI");       
        var index=event.getParam("Index");
        toliList.splice(index,1);
        component.set("v.TOLI",toliList);
    },
    
    saveclick : function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.disaSave",true);
        component.set("v.exceptionError",'');
         
        console.log('saveclick called');
        
        if(component.get("v.TO.ERP7__Shipment_Type__c") == '--None--') component.set("v.TO.ERP7__Shipment_Preference_Speed__c",'--None--');
        var currTo = component.get("v.TO");
        currTo.ERP7__Active__c = true;
        if(currTo.ERP7__Ready_To_Pick_Pack__c) component.set("v.TO.ERP7__Status__c", 'Requested'); 
        if(component.get("v.Mtask") != null && component.get("v.Mtask") != undefined && component.get("v.Mtask") != ""){
            var task = component.get("v.Mtask");
            component.set("v.TO.ERP7__Tasks__c", task.Id); 
            component.set("v.TO.ERP7__Project__c", task.ERP7__Project__c); 
            //currTo.ERP7__Tasks__c = task.Id;
            //currTo.ERP7__Project__c = task.ERP7__Project__c;
        }
        //component.set("v.TO",currTo);
        var toli = component.get("v.TOLI");
        var toliLength = toli.length;
        var transfer = component.get("v.TO");
        var checkToSerBat = false;
        var errorMessage = '';
        var errbool = false;
        console.log('arsh before vals');
        if($A.util.isEmpty(transfer.ERP7__Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__Channel__c)){
            errorMessage = $A.get('$Label.c.Please_select_a_Source_Channel');
            errbool = true;
        }else if($A.util.isEmpty(transfer.ERP7__Distribution_Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__Distribution_Channel__c)){
            errorMessage = $A.get('$Label.c.Please_select_a_Source_Distribution_Channel');
            errbool = true;
        }else if($A.util.isEmpty(transfer.ERP7__To_Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__To_Channel__c)){
            errorMessage = $A.get('$Label.c.Please_Select_a_Channel_to_transfer');
            errbool = true;
        }else if($A.util.isEmpty(transfer.ERP7__To_Distribution_Channel__c) || $A.util.isUndefinedOrNull(transfer.ERP7__To_Distribution_Channel__c)){
            errorMessage = $A.get('$Label.c.Please_Select_a_Distribution_Channel_to_transfer');
            errbool = true;
        }else if(!toliLength > 0){
            errorMessage = $A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item');
            errbool = true;
        }
        
        if(errbool == false){
            console.log('2 errbool false');
            if(toliLength > 0){
               if(component.get("v.processSNBatch")) checkToSerBat  = helper.validateTOLISerBat(component, event);
                var toliqty = component.get("v.TOLI");
                for(var i in toliqty){
                    if($A.util.isEmpty(toliqty[i].ERP7__Products__c) || $A.util.isUndefinedOrNull(toliqty[i].ERP7__Products__c)){
                        errorMessage = $A.get('$Label.c.Please_select_a_product_for_the_line_item');
                        errbool = true;
                        break;
                    }
                    if($A.util.isEmpty(toliqty[i].ERP7__Quantity_requested__c) || $A.util.isUndefinedOrNull(toliqty[i].ERP7__Quantity_requested__c)){
                        errorMessage = $A.get('$Label.c.Please_enter_a_valid_quantity_for_the_line_item');
                        errbool = true;
                        break;
                    }
                    if($A.util.isEmpty(toliqty[i].availableQty) || $A.util.isUndefinedOrNull(toliqty[i].availableQty)){
                        errorMessage = $A.get('$Label.c.Available_quantity_of_the_stock_cannot_be_empty');
                        errbool = true;
                        break;
                    }
                    if(toliqty[i].ERP7__Quantity_requested__c > toliqty[i].availableQty){
                        errorMessage = $A.get('$Label.c.Requested_quantity_is_more_than_available_quantity_for_the_line_items');
                        errbool = true;
                        break;
                    }
                    if(toliqty[i].ERP7__Quantity_requested__c <= 0){
                        errorMessage = $A.get('$Label.c.Requested_quantity_should_be_greater_than_0_for_the_line_items');
                        errbool = true;
                        break;
                    }
                }
            }else{
                errorMessage = $A.get('$Label.c.PH_DebNote_Please_add_a_Line_Item');
                errbool = true;
            }
            if(toliLength > 0 && !checkToSerBat && component.get("v.processSNBatch")){
                errorMessage = $A.get('$Label.c.Please_select_a_Serial_Lot_for_the_line_items');
                errbool = true;
            }
        }
        
        if(errbool && errorMessage != ''){
            console.log('saveclick errbool true');
            component.set("v.showSpinner",false);
            component.set("v.disaSave",false);
            component.set("v.exceptionError", errorMessage);
        }else{
            if(errbool == false) helper.saveTOandTOLI(component, event);
        }
    },
    
    goBackTask : function(component, event) {
        $A.createComponent("c:AddMilestoneTask",{
            "aura:id" : "taskCmp",
            "projectId" : component.get("v.projectId"),
            "taskId" : component.get("v.Mtask.Id"),
            "newTask" : component.get("v.Mtask"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    cancelclick : function(component, event, helper) {
        window.history.back();
    },
    
    closeError : function(component, event, helper) {
        component.set("v.exceptionError","");
    },
    
    fromDCchange : function(component, event, helper) {
        console.log('fromDCchange called');
        var chn = component.get('v.TO.ERP7__Channel__c');
        var Dchn = component.get('v.TO.ERP7__Distribution_Channel__c');
        console.log('chn : '+chn);
        console.log('Dchn : '+Dchn);
        if(chn != '' && chn != null && Dchn != null && Dchn != '' && chn != undefined && Dchn != undefined){
            var action = component.get("c.getSitefromDC");
            action.setParams({'DChannel' : Dchn});
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS") {
                    var empData = response.getReturnValue();
                    var transfer = component.get("v.TO");
                    //transfer.ERP7__Channel__c = empData.channel;
                    //transfer.ERP7__Distribution_Channel__c = empData.distributionChannel.Id;
                    if(!$A.util.isEmpty(empData.distributionChannel.Id) && !$A.util.isUndefinedOrNull(empData.distributionChannel.Id)){
                        if(!$A.util.isEmpty(empData.distributionChannel.ERP7__Site__c) && !$A.util.isUndefinedOrNull(empData.distributionChannel.ERP7__Site__c)){
                            component.set("v.TO.ERP7__From_Site__c",empData.distributionChannel.ERP7__Site__c);
                            if(!$A.util.isEmpty(empData.distributionChannel.ERP7__Site__r.ERP7__Address__c) && !$A.util.isUndefinedOrNull(empData.distributionChannel.ERP7__Site__r.ERP7__Address__c)){
                                component.set("v.TO.ERP7__From_Address__c",empData.distributionChannel.ERP7__Site__r.ERP7__Address__c);
                            }
                        }
                    }
                    component.set("v.showSpinner",false);
                }
                else{
                    component.set("v.showSpinner",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                             setTimeout(function(){ component.set("v.exceptionError",errors[0].message); }, 5000);
                        }
                    } else {
                       setTimeout(function(){ component.set("v.exceptionError","Unknown error"); }, 5000);
                    }
                }
                component.set("v.showSpinner",false);
            });
            $A.enqueueAction(action);
        }
        //helper.setChannelandDC(component, event);
    },
     parentFieldChange : function(component, event, helper) {
    	var controllerValue = component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
        var pickListMap = component.get("v.depnedentFieldMap");

        if (controllerValue != '--None--') {
             //get child picklist value
            var childValues = pickListMap[controllerValue];
            var childValueList = [];
            childValueList.push('--None--');
            for (var i = 0; i < childValues.length; i++) {
                childValueList.push(childValues[i]);
            }
            // set the child list
            component.set("v.listDependingValues", childValueList);
            
            if(childValues.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
            }else{
                component.set("v.bDisabledDependentFld" , true); 
            }
            
        } else {
            component.set("v.listDependingValues", ['--None--']);
            component.set("v.bDisabledDependentFld" , true);
        }
	},
    
    checkready2pick : function(component, event, helper) {
        var currTO = component.get('v.TO');
        var getcheck = event.getSource().get('v.checked');
        console.log('getcheck : '+getcheck);
        currTO.ERP7__Ready_To_Pick_Pack__c = getcheck;
        component.set('v.TO',currTO);
        
    }
})