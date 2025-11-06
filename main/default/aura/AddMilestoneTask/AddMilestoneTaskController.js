({
	doInit : function(component, event, helper) {
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
       
        
        var currentMilestone = '';
        var milestones = component.get("v.currentMilestones");
        for (var i in milestones) {
            if(milestones[i].Id == component.get("v.milestoneId")) {
                currentMilestone = milestones[i].milestone.ERP7__Resource_Group__c;
                component.set("v.mstResourceGroup", currentMilestone);
                
                break;
            }
        }
		
        if(component.get("v.milestoneId") != null && component.get("v.milestoneId") != undefined && component.get("v.milestoneId") != "")
            component.set("v.newTask.ERP7__Milestone__c", component.get("v.milestoneId"));
        
        helper.setTaskType(component, event);
        helper.setTaskStatus(component, event);
        if(component.get("v.newTask.Id")){
            helper.getTypeRelatedVal(component, event);
        }
	},
    
    fetchTask : function(component, event, helper) {
        if(component.get("v.taskId") != null && component.get("v.taskId") != undefined && component.get("v.taskId") != "")
        	helper.setTask(component, event);
        else {
            component.set("v.newTask",{'Name': '',
                                       'Id' : '',
                                       'ERP7__Status__c': '--none--',
                                       'ERP7__Type__c': '--none--',
                                       'ERP7__End_Date__c': '',
                                       'ERP7__Start_Date__c': '',
                                       'ERP7__Project__c': '',
                                       'ERP7__Milestone__c' : '',
                                       'ERP7__Owner__c' : ''
                                      });
            component.set("v.manufacturingOrders", null);
            component.set("v.workOrders", null);
            component.set("v.transferOrders", null);
            component.set("v.salesOrders", null);
            component.set("v.purchaseOrders", null);
            component.set("v.purchaseRequisitions", null);
        }
    },
    
    saveTask : function(component, event, helper) {
        
        if(component.get("v.projectId") != null && component.get("v.projectId") != undefined) {
            var taskM = component.get("v.newTask");
            taskM.ERP7__Project__c = component.get("v.projectId");
            component.set("v.newTask", taskM);
        }
        var taskNameCheck = helper.validateTaskName(component, event);
        var taskTypeCheck = helper.validateTaskType(component, event);
        var taskMilestoneCheck = helper.validateTaskMilestone(component, event);
        var taskResourceCheck = helper.validateTaskResource(component, event);
        if(taskNameCheck && taskTypeCheck && taskMilestoneCheck && taskResourceCheck)
            helper.saveCurrentTask(component, event);
        else{            
            var errorMessage = '';
            if(!taskNameCheck && !taskTypeCheck && !taskMilestoneCheck && !taskResourceCheck){
                errorMessage = "Please enter the required fields that are marked *.";
            }
            else if (!taskNameCheck && !taskTypeCheck && !taskMilestoneCheck) {
                errorMessage = "Please enter the required fields that are marked *.";
            }
                else if (!taskNameCheck && !taskTypeCheck && !taskResourceCheck) {
                    errorMessage = "Please enter the required fields that are marked *.";
                }
                    else if (!taskNameCheck && !taskResourceCheck && !taskMilestoneCheck) {
                        errorMessage = "Please enter the required fields that are marked *.";
                    }
                        else if (!taskResourceCheck && !taskTypeCheck && !taskMilestoneCheck) {
                            errorMessage = "Please enter the required fields that are marked *.";
                        }
                            else{
                                errorMessage = " Please enter "
                                if (!taskNameCheck)
                                    errorMessage += "Task Name";
                                
                                if(!taskTypeCheck){
                                    if(errorMessage != " Please enter ")
                                        errorMessage += " & ";
                                    
                                    errorMessage += "Task Type";
                                }
                                
                                if (!taskMilestoneCheck){
                                    if(errorMessage != " Please enter ")
                                        errorMessage += " & ";
                                    
                                    errorMessage += "Task Milestone ";
                                }
                                
                                if (!taskResourceCheck){
                                    if(errorMessage != " Please enter ")
                                        errorMessage += " & ";
                                    
                                    errorMessage += "Task Resource";
                                }
                                errorMessage += ".";
                            }
            component.set("v.exceptionError",errorMessage);
        }
    },
    
    navMO: function(component, event, helper) {
        /*$A.createComponent("c:WorkCenterSchedule",{
            "Flow":'MO',
            "NAV":'WCCP',
            "RD":'yes',
            "tabNavi" : 'PJTworkbench',
            "type" : 'Manufacturing Order',
            "Mtask" : component.get("v.newTask"),
            "taskId" : component.get("v.taskId"),
            "projectId" : component.get("v.projectId"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                "Flow":'MO',
                "NAV":'WCCP',
                "RD":'yes',
                "tabNavi" : 'PJTworkbench',
                "type" : 'Manufacturing Order',
                "Mtask" : component.get("v.newTask"),
                "taskId" : component.get("v.taskId"),
                "projectId" : component.get("v.projectId"),
                "currentMilestones" : component.get("v.currentMilestones"),
                "currentProject" : component.get("v.currentProject")
            }
        });
        evt.fire();
    },
    
    navWO: function(component, event, helper) {
        /*$A.createComponent("c:WorkCenterSchedule",{
            "Flow":'WO',
            "NAV":'WCCPM',
            "RD":'yes',
            "Mtask" : component.get("v.newTask"),
            "taskId" : component.get("v.taskId"),
            "projectId" : component.get("v.projectId"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                "Flow":'WO',
                "NAV":'WCCPM',
                "RD":'yes',
                "tabNavi" : 'PJTworkbench',
                "type" : 'Manufacturing Order',
                "Mtask" : component.get("v.newTask"),
                "taskId" : component.get("v.taskId"),
                "projectId" : component.get("v.projectId"),
                "currentMilestones" : component.get("v.currentMilestones"),
                "currentProject" : component.get("v.currentProject")
            }
        });
        evt.fire();
    },
    
    navTO: function(component, event, helper) {
        /*$A.createComponent("c:CreateTransferOrder",{
            "aura:id" : "taskTO",
            "Mtask" : component.get("v.newTask"),
            "taskId" : component.get("v.taskId"),
            "projectId" : component.get("v.projectId"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreateTransferOrder",
            componentAttributes: {
                "Mtask" : component.get("v.newTask"),
                "taskId" : component.get("v.taskId"),
                "projectId" : component.get("v.projectId"),
                "currentMilestones" : component.get("v.currentMilestones"),
                "currentProject" : component.get("v.currentProject")
            }
        });
        evt.fire();
    },
    
    navSO: function(component, event, helper) {
        /*$A.createComponent("c:OrderConsole",{
            "aura:id" : "taskSO",
            "Mtask" : component.get("v.newTask"),
            "taskId" : component.get("v.taskId"),
            "projectId" : component.get("v.projectId"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:OrderConsole",
            componentAttributes: {
                "Mtask" : component.get("v.newTask"),
                "taskId" : component.get("v.taskId"),
                "projectId" : component.get("v.projectId"),
                "currentMilestones" : component.get("v.currentMilestones"),
                "currentProject" : component.get("v.currentProject")
            }
        });
        evt.fire();
    },
    
    navPO: function(component, event, helper) {
        /*
        $A.createComponent("c:CreatePurchaseOrder",{
            "Mtask" : component.get("v.newTask"),
            "projectId" : component.get("v.projectId"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreatePurchaseOrder",
            componentAttributes: {
                "Mtask" : component.get("v.newTask"),
                "projectId" : component.get("v.projectId"),
                "currentMilestones" : component.get("v.currentMilestones"),
                "currentProject" : component.get("v.currentProject")
            }
        });
        evt.fire();
    },
    
    navPR: function(component, event, helper) {
        /*$A.createComponent("c:CreatePurchaseRequisition",{
            "Mtask" : component.get("v.newTask"),
            "projectId" : component.get("v.projectId"),
            "currentMilestones" : component.get("v.currentMilestones"),
            "currentProject" : component.get("v.currentProject")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreatePurchaseRequisition",
            componentAttributes: {
                "Mtask" : component.get("v.newTask"),
                "projectId" : component.get("v.projectId"),
                "currentMilestones" : component.get("v.currentMilestones"),
                "currentProject" : component.get("v.currentProject")
            }
        });
        evt.fire();
    },
        
    getTypeRelatedVal : function(component, event, helper) {
        var taskM = component.get("v.newTask");
        if(taskM.ERP7__Type__c == "Manufacturing Order")
            helper.getMOs(component, event);
        else if(taskM.ERP7__Type__c == "Work Order")
            helper.getWOs(component, event);
        else if(taskM.ERP7__Type__c == "Transfer Order")
            helper.getTOs(component, event);
        else if(taskM.ERP7__Type__c == "Sales Order")
            helper.getSOs(component, event);
        else if(taskM.ERP7__Type__c == "Purchase Order")
            helper.getPOs(component, event);
        else if(taskM.ERP7__Type__c == "Purchase Requisition")
            helper.getPRs(component, event);
    },
    
    goBack : function(component, event, helper) {
        /*
        $A.createComponent("c:Milestones",{
            "projectId" : component.get("v.projectId"),
            "milestonesWP" : component.get("v.currentMilestones"),
            "currentProj" : component.get("v.currentProject"),
            "isRefresh" : true
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Milestones",
            componentAttributes: {
                "projectId" : component.get("v.projectId"),
                "milestonesWP" : component.get("v.currentMilestones"),
                "currentProj" : component.get("v.currentProject"),
                "isRefresh" : true
            }
        });
        evt.fire();
    },
    
    NavMORecord : function (component, event) {
        
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/lightning/r/ERP7__Manufacturing_Order__c/" + RecId + "/view";
        window.open(RecUrl,'_blank');
    },
    
    NavWORecord : function (component, event) {
       
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/lightning/r/ERP7__WO__c/" + RecId + "/view";
        window.open(RecUrl,'_blank');
    },
    
    NavTORecord : function (component, event) {
        
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/lightning/r/ERP7__Transfer_Order__c/" + RecId + "/view";
        window.open(RecUrl,'_blank');
    },
    
    NavSORecord : function (component, event) {
       
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/lightning/r/ERP7__Sales_Order__c/" + RecId + "/view";
        window.open(RecUrl,'_blank');
    },
    
    NavPORecord : function (component, event) {
       
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/lightning/r/ERP7__PO__c/" + RecId + "/view";
        window.open(RecUrl,'_blank');
    },
    
    NavPRRecord : function (component, event) {
        
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/lightning/r/ERP7__Purchase_Requisition__c/" + RecId + "/view";
        window.open(RecUrl,'_blank');
    },
    
    hideChatter : function(component){
        component.set("v.ChatterTab", false);
    },
    
    showChatter : function(component){
        component.set("v.ChatterTab", true);
    },
    
    closeError : function (cmp, event) {
    	cmp.set("v.exceptionError",'');
    }
})