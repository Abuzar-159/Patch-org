({
	setTaskStatus : function(component, event) {
       
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
		var action = component.get("c.getTaskStatusPickval");
        var inputsel = component.find("taskStatus");
        var opts = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    if(response.getReturnValue()[i] != "Clocked In" && response.getReturnValue()[i] != "Clocked Out"){
                        opts.push({
                            "class": "optionClass",
                            label: response.getReturnValue()[i],
                            value: response.getReturnValue()[i]
                        });
                    }
                }
               
                //inputsel.set("v.options", opts);
                component.set("v.taskStatusOptions",opts);
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
        });
        $A.enqueueAction(action);
	},
    
    setTaskType : function(component, event) {
        
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
		var action = component.get("c.getTaskTypePickval");
        var inputsel = component.find("taskType");
        var opts = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    if(response.getReturnValue()[i] != "Upgrade"){
                        opts.push({
                            "class": "optionClass",
                            label: response.getReturnValue()[i],
                            value: response.getReturnValue()[i]
                        });
                    }
                }
                
               // inputsel.set("v.options", opts);
               component.set("v.taskTypeOptions",opts);
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
        });
        $A.enqueueAction(action);
	},
    
    setTOType : function(component, event) {
       
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
		var action = component.get("c.GetAvailableRecordTypeTO");
        var inputsel = component.find("newTOType");
        var opts = [];
        var labels = ["", "", ""];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
               
                var recType = response.getReturnValue();
                for (var key in recType) {
                    opts.push({
                        "class": "optionClass",
                        label: recType[key],
                        value: key
                    });
                }
                
                //inputsel.set("v.options", opts);
                component.set("v.newTOTypeOptions",opts);
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
        });
        $A.enqueueAction(action);
	},
    
    setTOStatus : function(component, event) {
        
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
		var action = component.get("c.getTOStatusPickval");
        var inputsel = component.find("newTOStatus");
        var opts = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    opts.push({
                        "class": "optionClass",
                        label: response.getReturnValue()[i],
                        value: response.getReturnValue()[i]
                    });
                }
                
                //inputsel.set("v.options", opts);
                component.set("v.newTOStatusOptions",opts);

            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
        });
        $A.enqueueAction(action);
	},
    
    setTask : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getCurTask");
        action.setParams( {
            "curTaskId" : component.get("v.taskId")
        });
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS") {
               
                component.set("v.newTask", response.getReturnValue());
               
                this.getTypeRelatedVal(component, event);
                component.set("v.isresetTask",true);
                component.set("v.isresetTask",false);
	            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    saveNewTO : function(component, event) {
       
        var TransferOrders = component.get("v.transferOrders");
        
        var action = component.get("c.save_TO");
        
        action.setParams({
            "TO" : JSON.stringify(component.get("v.newTransferOrder"))
        });
        action.setCallback(this, function(response) {
            
            if(response.getState() === "SUCCESS") {
                this.showToast('Success!','success','Task created Successfully');
                TransferOrders.push(response.getReturnValue());
                component.set("v.transferOrders", TransferOrders);
                
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide"); 
        });
        $A.enqueueAction(action);
    },
    
    saveCurrentTask : function(component, event) {
        
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.save_Task");
        var newMtask = true;
        if(component.get("v.newTask.Id")) {
            
            newMtask = false;
        }
        action.setParams( {
            "currentTask" : JSON.stringify(component.get("v.newTask"))
        });
        action.setCallback(this, function(response) {
            
            if(response.getState() === "SUCCESS") {
                if(newMtask)
                    this.showToast('Success!','success','Task created Successfully');
                else
                    this.showToast('Success!','success','Task updated Successfully');
                component.set("v.newTask", response.getReturnValue());
                component.set("v.taskId", response.getReturnValue().Id);
                
                this.getTypeRelatedVal(component, event);
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    getTypeRelatedVal : function(component, event) {
       
        var taskM = component.get("v.newTask");
        if(taskM.ERP7__Type__c == "Manufacturing Order")
            this.getMOs(component, event);
        else if(taskM.ERP7__Type__c == "Work Order")
            this.getWOs(component, event);
        else if(taskM.ERP7__Type__c == "Transfer Order")
            this.getTOs(component, event);
        else if(taskM.ERP7__Type__c == "Sales Order")
            this.getSOs(component, event);
        else if(taskM.ERP7__Type__c == "Purchase Order")
            this.getPOs(component, event);
        else if(taskM.ERP7__Type__c == "Purchase Requisition")
            this.getPRs(component, event);
    },
    
    getMOs : function(component, event) {
        
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getTaskMOs");
        action.setParams( {
            "taskId" : component.get("v.newTask").Id
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                
                component.set("v.manufacturingOrders", response.getReturnValue());
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    getWOs : function(component, event) {
       
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getTaskWOs");
        action.setParams( {
            "taskId" : component.get("v.newTask").Id
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                
                component.set("v.workOrders", response.getReturnValue());
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    getTOs : function(component, event) {
        
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getTaskTOs");
        action.setParams( {
            "taskId" : component.get("v.newTask").Id
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                
                component.set("v.transferOrders", response.getReturnValue());
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    getSOs : function(component, event) {
       
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getTaskSOs");
        action.setParams( {
            "taskId" : component.get("v.newTask").Id
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                
                component.set("v.salesOrders", response.getReturnValue());
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    getPOs : function(component, event) {
      
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getTaskPOs");
        action.setParams( {
            "taskId" : component.get("v.newTask").Id
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
              
                component.set("v.purchaseOrders", response.getReturnValue());
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    getPRs : function(component, event) {
       
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getTaskPRs");
        action.setParams( {
            "taskId" : component.get("v.newTask").Id
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                
                component.set("v.purchaseRequisitions", response.getReturnValue());
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    validateTaskName : function(component, event, helper) {
        
        var NOerrors = true;
        var taskName = component.find("taskName");
        if(!$A.util.isUndefined(taskName) || !$A.util.isEmpty(taskName))
            NOerrors =  this.checkValidationField(taskName);
      
        return NOerrors;
    },
    
    validateTaskType : function (component, event) {
        var NOerrors = true;
        var taskType = component.find("taskType");
        if(taskType.get("v.value") == "--None--"){
            
            NOerrors =  this.checkValidationField(taskType);
        }
       
        return NOerrors;
    },
    
    validateTaskMilestone : function (component, event) {
        var NOerrors = true;
        var taskMilestone = component.find("taskMilestone");
       
        if(!$A.util.isUndefined(taskMilestone) || !$A.util.isEmpty(taskMilestone)){
           
            NOerrors =  this.checkvalidationLookup(taskMilestone);
        }
       
        return NOerrors;
    },
    
    validateTaskResource : function (component, event) {
        var NOerrors = true;
        var taskResource = component.find("taskOwner");
        if(!$A.util.isUndefined(taskResource) || !$A.util.isEmpty(taskResource))
            NOerrors =  this.checkvalidationLookup(taskResource);
      
        return NOerrors;
    },
    
    validateMilestoneName : function(component, event, helper) {
        var NOerrors = true;
        var msName = component.find("milestoneName");
        if(!$A.util.isUndefined(msName) || !$A.util.isEmpty(msName))
            NOerrors =  this.checkValidationField(msName);
        
     
        return NOerrors;
    },
    
    validateMilestoneTeam: function (component, event) {
        var NOerrors = true;
        var msTeam = component.find("milestoneTeam");
        if(!$A.util.isUndefined(msTeam) || !$A.util.isEmpty(msTeam))
            NOerrors =  this.checkvalidationLookup(msTeam);
        
        return NOerrors;
    },
    
    checkvalidationLookup : function(cmp){
      
        if($A.util.isEmpty(cmp.get("v.selectedRecord.Id"))){
            
            cmp.set("v.inputStyleclass","hasError");
            return false;
        }else{
            
            cmp.set("v.inputStyleclass",""); 
            return true;
        }
    },
    
    checkValidationField : function(cmp){
        if($A.util.isEmpty(cmp.get("v.value")) || cmp.get("v.value") == "--None--"){
            cmp.set("v.class","hasError");
            return false;
        }else{
            cmp.set("v.class","");
            return true;
        }
        
    },
    
    closeTOModal :function(component, event) {
        
        component.set("v.newTransferOrder", null);
        $A.util.removeClass(component.find("NewTransferOrder"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("NewTransferOrderBackdrop"), 'slds-backdrop_open');
    },
    
    showToast : function(title, type, message) {
        
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
    }
})