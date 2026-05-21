({
    eposFieldAccess:function (component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action=component.get("c.eposCheckFLS");
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.eposFLSCheck',response.getReturnValue());
            }
            else{
                var errors = response.getError();
                console.log("error -> ", errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(title, message, type){
        var toast = $A.get("e.force:showToast");
        if(toast){
            toast.setParams({
                title: title,
                message: message,
                type: type
            });
            toast.fire();
        }
    },
    
    hideSpinner : function (component, event) {
        var spinner = component.find('mainSpin');
        $A.util.addClass(spinner, "slds-hide");    
    },
 	
    showSpinner : function (component, event) {
        var spinner = component.find('mainSpin');
         $A.util.removeClass(spinner, "slds-hide");   
    },
    toggleHelper : function(component,event) {
        //alert('1');
        var target = event.getSource().get("v.name");
        //var RecId = target.getElement().parentElement.id;
        //var RecName = target.get("v.value");
        //var nm = component.get("v.name");
        alert(target);
        //var toggleText = component.find(target);
        //var togglec = component.find(target).class;
        //alert('togglec : '+togglec);
        document.getElementById(target).style.display = "block";
        //$A.util.toggleClass(toggleText, "toggle");
        //alert('3');
    },
    
    toggleDiv : function(component,event) {
        $(document).ready(function () {
            $("#toggle").click(function () {
                if ($(this).data('name') == 'show') {
                    $("#sidebar").animate({
                        width: '0%'
                    }).hide()
                    $("#map").animate({
                        width: '100%'
                    });
                    $(this).data('name', 'hide')
                } else {
                    $("#sidebar").animate({
                        width: '19%'
                    }).show()
                    $("#map").animate({
                        width: '80%'
                    });
                    $(this).data('name', 'show')
                }
            });
        });
    },
    
    toggleHelperIn : function(component,event) {
        var target = event.getSource().get("v.name");
        component.set("v.serialShow",true)
        document.getElementById(target).style.display = "block";
    },
    
    toggleHelperOut : function(component,event) {
        var target = event.getSource().get("v.name");
        if(component.get("v.serialShow")){
            document.getElementById(target).style.display = "none";
            component.set("v.serialShow",false)
        }
    },
    
    fetchPaymentType : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        try{
            var action = component.get("c.getPaymentType");
            var inputsel = component.find("accountType");
            var opts=[];
            opts.push({"class": "optionClass", label: '--None--', value: ''});
            action.setCallback(this, function(a) {
                /*for(var i=0;i< a.getReturnValue().length;i++){
                    opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }*/
                for(var res in a.getReturnValue()){
                    opts.push({"class": "optionClass", label: a.getReturnValue()[res], value: a.getReturnValue()[res]});
                }
                inputsel.set("v.options", opts);
            });
            $A.enqueueAction(action); 
        } catch(err) {
            //alert("Exception : "+err.message);
        }
    },
    
    fetchCRUD: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getCRUD");
        action.setCallback(this, function(a) {
            component.set("v.crudValues", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    //Controlling Dependent Picklist
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
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
                //alert('Something went wrong..');
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
        
    },
    
    //===============Product Configuration start===================
    optionRules : function(component,event,proforConfig) {
        var action=component.get("c.getAllOptionRules");
        action.setParams({proId : proforConfig});
        action.setCallback(this, function(response){
            var state=response.getState();		
            if(state ==="SUCCESS"){                
                var optionRules=response.getReturnValue().optionRules;
                this.selectFirstOption(component,event);
                component.set("v.optionRules",optionRules);
                if(optionRules.length > 0){
                    for(var i=0;i<optionRules.length;i++){
                        if(optionRules[i].ERP7__Type__c == "Dependency"){
                            var parent=optionRules[i].ERP7__Parent_Option__c;
                            var child=optionRules[i].ERP7__Child_Option__c;                            
                            var isParentChecked=document.getElementById(parent).checked;
                            var isParentDisabled=document.getElementById(parent).disabled;
                            
                            if(isParentDisabled == false){
                                if(isParentChecked == true){
                                    document.getElementById(child).disabled=false;
                                    document.getElementById(child).checked=true;
                                }
                            }
                            if(isParentChecked == false){
                                document.getElementById(child).checked=false;
                                document.getElementById(child).disabled=true;
                            }                            
                        }
                        else if(optionRules[i].ERP7__Type__c == "Exclusion"){
                            var parent=optionRules[i].ERP7__Parent_Option__c;
                            var child=optionRules[i].ERP7__Child_Option__c;                            
                            var isParentChecked=document.getElementById(parent).checked;
                            //var isParentDisabled=document.getElementById(parent).disabled;
                            if(isParentChecked == true){
                                document.getElementById(child).checked=false;
                                document.getElementById(child).disabled=true;
                            }
                        }
                    }                    
                }
                this.selectFirstOption1(component,event);
            }
        });
        $A.enqueueAction(action);
    },
    
    //=========Select first option from all feature==========
    selectFirstOption : function(component,event){
        var proOptions = component.get("v.proOptions");
        for(var i=0;i<proOptions.length;i++){
            for(var j=0;j<proOptions[i].featOpt.length;j++){
                var currentId=proOptions[i].featOpt[j].Id;
                if(!document.getElementById(currentId).disabled){
                    document.getElementById(currentId).checked=true;
                    break;
                }
            }
        }
    },
    
    //===============Select second option if first option is disabled======
    selectFirstOption1: function(component,event){
        var proOptions = component.get("v.proOptions");
        for(var i=0; i<proOptions.length;i++){
            for(var j=0;j<proOptions[i].featOpt.length;j++){
                var currentId=proOptions[i].featOpt[j].Id;
                if(document.getElementById(currentId).checked){
                    break;
                }else if(!document.getElementById(currentId).disabled){
                    document.getElementById(currentId).checked=true;
                    break;
                }
            }
        }
    },
    
    disableOthers : function(component,event,currentTarget,feature){
        //var feature=document.getElementById(currentTarget).text;
        var proOption=component.get("v.proOptions");
        for(var i=0; i<proOption.length; i++){
            if(proOption[i].feature.Id == feature){
                for(var j=0;j<proOption[i].featOpt.length;j++){
                    var foId=proOption[i].featOpt[j].Id;
                    if(proOption[i].featOpt[j].Id != currentTarget){
                        if(!document.getElementById(foId).disabled){
                            document.getElementById(foId).checked=false;
                        }                    		
                    }else{
                        document.getElementById(foId).checked=true;
                    }                       
                }
                break;                
            }            
        }
        this.setOptionRulesAfterChange(component,event,currentTarget);
    },
    
    setOptionRulesAfterChange : function(component,event,currentTarget){
        var optionRules=component.get("v.optionRules");
        if(optionRules.length > 0){
            for(var i=0;i<optionRules.length;i++){
                if(optionRules[i].ERP7__Type__c == "Dependency"){
                    var parent=optionRules[i].ERP7__Parent_Option__c;
                    var child=optionRules[i].ERP7__Child_Option__c;
                    //var parentName=optionRules[i].ERP7__Parent_Option__r.ERP7__Optional_SKU__r.Name;
                    
                    if(! document.getElementById(parent).checked){
                        document.getElementById(child).checked=false;
                        document.getElementById(child).disabled=true;
                    }
                    
                    if(currentTarget == parent){
                        if(document.getElementById(parent).checked){
                            if(document.getElementById(child).disabled){
                                document.getElementById(child).checked=false;
                            	document.getElementById(child).disabled=false;
                            }                            
                        }
                        else{
                            document.getElementById(child).checked=false;
                            document.getElementById(child).disabled=true;
                            
                            for(var j=0;j<optionRules.length;j++){
                                var parent1=optionRules[j].ERP7__Parent_Option__c;
                                var child1=optionRules[j].ERP7__Child_Option__c;
                                if(child == parent1){
                                    //=========================================================//
                                    //When multiple rule's products are dependent on each other//
                                    //=========================================================//
                                    //if(document.getElementById(child1).checked){ 
                                    document.getElementById(child1).checked=false;
                                    document.getElementById(child1).disabled=true;
                                    //}
                                    //==================optional======================
                                    for(var k=0;k<optionRules.length;k++){
                                        var parent2=optionRules[k].ERP7__Parent_Option__c;
                                        var child2=optionRules[k].ERP7__Child_Option__c;
                                        if(child1 == parent2){
                                            document.getElementById(child2).checked=false;
                                            document.getElementById(child2).disabled=true;
                                            
                                            for(var l=0;l<optionRules.length;l++){
                                                var parent3=optionRules[l].ERP7__Parent_Option__c;
                                                var child3=optionRules[l].ERP7__Child_Option__c;
                                                if(child2 == parent3){
                                                    document.getElementById(child3).checked=false;
                                                    document.getElementById(child3).disabled=true;
                                                }
                                            }
                                        }
                                    }
                                    //===================/optional===========================
                                }
                            }
                        }                        
                    }    
                }    
                else if(optionRules[i].ERP7__Type__c == "Exclusion"){
                    var parent=optionRules[i].ERP7__Parent_Option__c;
                    var child=optionRules[i].ERP7__Child_Option__c;                    
                    
                    if(document.getElementById(parent).checked){	// for current selected checkbox
                        document.getElementById(child).disabled=true;
                    }else if(! document.getElementById(parent).checked){	// for previous selected checkbox
                        document.getElementById(child).disabled=false;
                    }
                    
                    if(document.getElementById(child).checked){
                        document.getElementById(parent).disabled=true;
                    }else if(! document.getElementById(child).checked){
                        document.getElementById(parent).disabled=false
                    }
                                        
                    //for current selected checkbox
                    /*if(document.getElementById(currentTarget).checked){
                        if(currentTarget == parent){
                            document.getElementById(child).checked=false;
                            document.getElementById(child).disabled=true;
                        }else if(currentTarget == child){
                            document.getElementById(parent).checked=false;
                            document.getElementById(parent).disabled=true;
                        }
                    }else{
                        if(currentTarget == parent){
                            //document.getElementById(child).checked=false;
                            document.getElementById(child).disabled=false;
                        }else if(currentTarget == child){
                            //document.getElementById(parent).checked=false;
                            document.getElementById(parent).disabled=false;
                        }
                    } */                       
                }
            }
            
        }
    },
    
    VersionChanged : function(component, event,objsel1,prodId) {
        //var count = event.getSource().get("v.labelClass");
        var obj = component.get("v.ProductsAndDiscountsWrapperListt");
        var objsel=objsel1;
        /*for(var x in obj){
            if(x == count) { 
                objsel = obj[count];
            }
        }*/
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");        
        var currentSalepoints = new Array(component.get("v.currentSalepoint"));
        var SalesOrder2Creates = component.get("v.SalesOrder");
        var Customers = new Array(component.get("v.Customer"));
        var Contacts = new Array(component.get("v.Contact"));
        var SOP = component.get("v.SOP");
        var isBackorder = (SalesOrder2Creates.ERP7__Is_Back_Order__c == true)? true : false;
        if(objsel.quantity_s == "") objsel.quantity_s = 0;
        
        var action = component.get("c.VersionsChanged");
        action.setParams({
            itemId: objsel.product.Id,
            currentSalepoints1: JSON.stringify(currentSalepoints),
            isBackorder: isBackorder, 
            Customers1: JSON.stringify(Customers),
            Contacts1: JSON.stringify(Contacts),
            SOP: SOP,
            quantity_s: objsel.quantity_s,
            Version: objsel.Version
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {                
                for(var x in obj){
                   	//if(x == count) { 
                   	if(prodId == obj[x].product.Id){
                        var mypro = response.getReturnValue();
                        var pro = obj[x];
                        obj[x].product_Type = 'N/A';
                        var stk = mypro.stock;
                        obj[x].stock = stk;
                        //obj[x].pricebookEntry = mypro.pricebookEntry;
                        obj[x].pricebookEntry.Id = mypro.pricebookEntry.Id;
                        //alert(obj[x].pricebookEntry.Id);
                        if(obj[x].quantity_s > parseFloat(pro.stock)) obj[x].quantity_s = stk;
                        if(Boolean(pro.trackInventory) || Boolean(pro.product.ERP7__Is_Asset__c)){
                            /*Inventory Product*/
                            if(Boolean(pro.product.ERP7__Is_Asset__c)){
                                /*Rental Product*/
                                
                                if(pro.stock !='' && pro.stock != undefined && parseFloat(pro.stock) > 0){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = pro.stock;
                                }else{
                                    obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                }
                                
                            }else{
                                /*Non Rental Product*/
                                if(pro.stock !='' && pro.stock != undefined && pro.stock > 0){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = pro.stock;
                                }   
                                else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Back-Order';
                                }
                                else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].showcbox = true;
                                    obj[x].product_Type = 'Pre-Order';
                                }
                                else{
                                    obj[x].product_Type = (pro.stock === undefined)?0:pro.stock;
                                }
                            }  
                        }else{
                            /*Non Inventory Product*/
                            if(Boolean(pro.product.ERP7__Is_Kit__c)){
                                /*Kit Product*/
                                obj[x].showcbox = true;
                                obj[x].product_Type = 'Kit';
                                if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                    obj[x].product_Type = 'Kit (Pre-Order)';
                                }
                                else if(Boolean(pro.product.ERP7__Allow_Back_Orders__c)){
                                    obj[x].product_Type = 'Kit (Back-Order)';
                                } 
                            }
                            /*Non Kit Product*/   
                            else if(Boolean(pro.product.ERP7__Allow_Pre_Orders__c)){
                                obj[x].product_Type = 'Pre-Order';
                                obj[x].showcbox = true;
                            }
                            else if(pro.product.ERP7__Status__c === 'Released'){
                                    obj[x].product_Type = pro.product.ERP7__Item_Type__c;
                                    obj[x].showcbox = true;
                             }    
                        }
                    
                        //if(response.getReturnValue().Error != true) obj[count].stock = response.getReturnValue().Value;
                        //alert(obj[count].product_Type);
                        
                    }
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.ProductsAndDiscountsWrapperListt", obj);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Moin added this on 04th March 2024
    fetchPaymentGateways: function(component, event, helper) {
        var payRTS = component.get("c.getPaymentGateways");
        payRTS.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                //alert(response.getReturnValue());
                var recordtypeList = response.getReturnValue();
                var recordArray = [];
                for(var rt in recordtypeList)
                    recordArray.push(recordtypeList[rt]);
                //}
                component.set("v.paymentGatewayList",recordArray);
            }            
        });
        $A.enqueueAction(payRTS);
    }
    //===============Product Configuration ens===================
    
})