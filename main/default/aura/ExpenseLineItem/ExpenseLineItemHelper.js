({
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
    },
    
	setExpenseCategory : function(component, event) {
		var action = component.get("c.getCategorypickval");
        var inputsel = component.find("ExpenseCategory");
        var opts = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                opts.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputsel.set("v.options", opts);
            component.set("v.ExpenseCategoryOptions",opts);
        });
        $A.enqueueAction(action);
        component.set("v.isSetCategory",true);
	},
    
    setExpenseType : function(component, event) {
		var action = component.get("c.getTypepickval");
        var inputsel = component.find("ExpenseType");
        var opts = [];
        action.setCallback(this, function(response) {
            for (var i = 0; i < response.getReturnValue().length; i++) {
                opts.push({
                    "class": "optionClass",
                    label: response.getReturnValue()[i],
                    value: response.getReturnValue()[i]
                });
            }
            //inputsel.set("v.options", opts);
            component.set("v.ExpenseTypeOptions",opts);
        });
        $A.enqueueAction(action);
        component.set("v.isSetCategory",true);
	},
    
    deleteCurExpli : function(component, event, xpensLI) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var delAction = component.get("c.delCurExpli");
        var curExpLI = JSON.stringify(xpensLI);
        delAction.setParams({
            delExpli : curExpLI
        });
        delAction.setCallback(this, function(response) {
            var state = delAction.getState();
            if(state === "SUCCESS") {
                component.set("v.showexpli", false);
                var e = $A.get("e.c:IndexingEvent");
                e.setParams({
                    "Index" : component.get("v.index")
                })
                e.fire();
        		$A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(delAction);
    },
    
    
    deleteSplitExpli : function(component, event, xpensLI) {
        var delAction = component.get("c.delCurExpli");
        var curExpLI = JSON.stringify(xpensLI);
        delAction.setParams({
            delExpli : curExpLI
        });
        delAction.setCallback(this, function(response) {
            var state = delAction.getState();
            if(state === "SUCCESS") {
                this.fetchExistingExpense(component, event);
                var Expline = [];
                Expline = component.get("v.splittedExpLine");
                Expline.pop(xpensLI);
                component.set("v.splittedExpLine", Expline);
            }
        });
        $A.enqueueAction(delAction);
    },
    
    /*fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
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
        
    },*/
    
    fetchExistingExpense : function(component, event) {
        var action=component.get("c.fetchExpRecords");
        action.setParams({'ExpId':component.get("v.splitExpense.Id")})
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue()!=null){
                    var explist = response.getReturnValue();
                    var expLine = [];
                    if(component.get("v.splitExpense.ERP7__VAT_Amount__c") != null && component.get("v.splitExpense.ERP7__VAT_Amount__c") != undefined && component.get("v.splitExpense.ERP7__VAT_Amount__c")>0 && explist.length<= 0){
                        this.fetchTaxCOA(component, event);
                    }else{
                        for(var i=0; i<explist.length;i++){
                            expLine[i] = explist[i].expline;
                            expLine[i].ERP7__Chart_Of_Account__c = explist[i].COAId;
                        }
                    }
                    component.set("v.splittedExpLine", expLine);
                }
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchTaxCOA : function(component, event){
        var action=component.get("c.fetchDefaultTaxCOA");
        action.setParams({'Amount':component.get("v.splitExpense.ERP7__VAT_Amount__c")});
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue()!=null){
                    var ExpList = [];
                    ExpList = response.getReturnValue().expLine;
                    for(var i= 0; i<ExpList.length;i++){
                        ExpList[i].ERP7__Chart_Of_Account__c = response.getReturnValue().COAId;
                    }
                    if(response.getReturnValue()!=null) component.set("v.splittedExpLine", ExpList);
                    
                }
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
            }
        });
        $A.enqueueAction(action);
    }
    
})