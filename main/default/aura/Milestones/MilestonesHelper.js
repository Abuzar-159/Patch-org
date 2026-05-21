({
    setProjectStatus : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getStatuspickval");
        //var inputsel = component.find("ProjectStatus");
        var opts = [];
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    if(response.getReturnValue()[i] != "Backlog" && response.getReturnValue()[i] != "Approved" && response.getReturnValue()[i] != "Rejected" && response.getReturnValue()[i] != "Awaiting Financial Approval" && response.getReturnValue()[i] != "Awaiting Exec Approval"){
                        opts.push({
                            "class": "optionClass",
                            label: response.getReturnValue()[i],
                            value: response.getReturnValue()[i]
                        });
                    }
                }
                //inputsel.set("v.options", opts);
                component.set("v.projectOptions", opts);
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    
    setMilestonesStatus : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getMilestoneStatuspickval");
        //var inputsel = component.find("newMilestoneStatus");
        //var inputEditsel = component.find("editMilestoneStatus");
        var opts = component.get("v.projectStatusOpts");
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
                //inputEditsel.set("v.options", opts);
                component.set("v.milestoneOptions",opts);
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    
    setProjDetails : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getCurProject");
        action.setParams( {
            "curProjId" : component.get("v.projectId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                //component.set("v.isresetProject", true);
                component.set("v.currentProj", response.getReturnValue());
                var projectRouting = "";
                this.setProjectMilestones(component, event, projectRouting);
                component.set("v.newProj",false);
            }
            component.set("v.isresetProject", false);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    setProjectMilestones : function(component, event, projectRouting) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getProcessMilestones");
        action.setParams( {
            "curRouting" : JSON.stringify(projectRouting),
            "curProject" : component.get("v.projectId")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.milestonesWP", response.getReturnValue());
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    saveCurrProject : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.save_Project");
        action.setParams( {
            "currentProject" : JSON.stringify(component.get("v.currentProj"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if(state === "SUCCESS" && res.errMsg == "") {
                component.set("v.isresetProject", false);
                component.set("v.currentProj", response.getReturnValue().project);
                component.set("v.projectId", response.getReturnValue().project.Id);
                this.setProjDetails(component, event);
                if(component.get("v.newProj"))
                    this.showToast('Success!','success','Project created Successfully');
                else
                    this.showToast('Success!','success','Project updated Successfully');
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.isresetProject", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                    }
                } else {
                    component.set("v.exceptionError","Unknown error");
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    saveMilestone : function(component, event, milestoneToSave) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var projectRouting = component.get("v.currentProj");
        projectRouting = projectRouting.ERP7__Default_Routing__r;
        var milestones = [];
        milestones = component.get("v.milestonesWP");
        var newMilestone = component.get("v.newMilestone");
        var action = component.get("c.save_MilestoneAK");
        action.setParams( {
            "newMilestone" : JSON.stringify(milestoneToSave),
            "currentRouting" : JSON.stringify(projectRouting),
            "msList" : JSON.stringify(milestones)
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                this.showToast('Success!','success','Milestone created Successfully');
                if(component.get("v.isNewMS")){
                    milestones.push(response.getReturnValue());
                    component.set("v.milestonesWP", milestones);
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                this.closeModal(component, event);
                this.editcloseModal(component, event);
                this.setProjDetails(component, event);
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                    }
                } else {
                    component.set("v.exceptionError","Unknown error");
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    deletecurrentMilestone : function(component, event, currentMsId) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var deleteAction = component.get("c.delete_Milestone");
        deleteAction.setParams({
            "msWrap" : JSON.stringify(component.get("v.milestonesWP")),
            "recordId": currentMsId
        });
        deleteAction.setCallback(self, function(response) {
            if(response.getState() === "SUCCESS") {
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.milestonesWP", response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent != undefined){
                    toastEvent.setParams({
                        "mode":"dismissible",
                        "title": 'Success!',
                        "type": 'success',
                        "message": 'Milestone was deleted Successfully'
                    });
                    toastEvent.fire();
                }
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error~>"+errors);
                }
            }
        });
        $A.enqueueAction(deleteAction);
    },
    
    /*setMilestoneTasks : function(component, event, currentMilestone) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var action = component.get("c.getMilestoneTasks");
        action.setParams( {
            "currMilestone" : currentMilestone
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.milestoneTasks", response.getReturnValue());
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },*/
    
    deletecurrentTask : function(component, event, currentTskId,  currentTskIndex, currentMsIndex) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var deleteAction = component.get("c.delete_Task");
        deleteAction.setParams({
            "recordId": currentTskId
        });
        deleteAction.setCallback(self, function(response) {
            if(response.getState() === "SUCCESS") {
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                
                var msWP = component.get("v.milestonesWP");
                var TkList = msWP[currentMsIndex].TaskList;
                TkList.splice(currentTskIndex, 1);
                msWP[currentMsIndex].TaskList = TkList;
                component.set("v.milestonesWP", msWP);
                
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent != undefined){
                    toastEvent.setParams({
                        "mode":"dismissible",
                        "title": 'Success!',
                        "type": 'success',
                        "message": 'Task was deleted Successfully'
                    });
                    toastEvent.fire();
                }
                //this.setProjDetails(component, event);
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.exceptionError",errors[0].message);
                    }
                } else {
                    component.set("v.exceptionError","Unknown error");
                }
            }
        });
        $A.enqueueAction(deleteAction);
    },
    
    milestonesTab: function(component, event, helper) {
        if(!component.get("v.showTab1")){
            component.set("v.ShowTab2", false);
            component.set("v.ShowTab1", true);
        }
    },
    
    openModal :function(component, event, helper) {
        $A.util.addClass(component.find("NewMilestone"), 'slds-fade-in-open');
        $A.util.addClass(component.find("NewMilestoneBackdrop"), 'slds-backdrop_open');
    },
    
    closeModal :function(component, event, helper) {
        component.set("v.newMilestone", {'Name': '',
                                         'ERP7__Status__c': '--none--',
                                         'ERP7__Start_Date__c': '',
                                         'ERP7__Due_Date__c': '',
                                         'ERP7__Percentage__c' : '',
                                         'ERP7__Organisations__c' : ''
                                        });
        component.set("v.isresetProject", true);
        component.set("v.isresetProject", false);
        $A.util.removeClass(component.find("NewMilestone"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("NewMilestoneBackdrop"), 'slds-backdrop_open');
    },
    
    editopenModal :function(component, event, helper) {
        $A.util.addClass(component.find("EditMilestone"), 'slds-fade-in-open');
        $A.util.addClass(component.find("EditMilestoneBackdrop"), 'slds-backdrop_open');
        component.set("v.isNewMS", false);
    },
    
    editcloseModal :function(component, event, helper) {
        component.set("v.editMilestone", {'Name': '',
                                            'Id' : '',
                                            'ERP7__Status__c': '--none--',
                                            'ERP7__Start_Date__c': '',
                                            'ERP7__Due_Date__c': '',
                                           	'ERP7__Percentage__c' : '',
                                            'ERP7__Organisations__c' : ''
                                           });
        component.set("v.isresetProject", true);
        component.set("v.isresetProject", false);
        $A.util.removeClass(component.find("EditMilestone"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("EditMilestoneBackdrop"), 'slds-backdrop_open');
    },
    
    validateProjectName : function(component, event, helper) {
        var NOerrors = true;
        var projName = component.find("projectName");
        if(!$A.util.isUndefined(projName) || !$A.util.isEmpty(projName))
            NOerrors =  this.checkValidationField(projName);
        
        return NOerrors;
    },
    
    validateProjectManager : function (component, event) {
        var NOerrors = true;
        var ProjManager = component.find("projectManager");
        if(!$A.util.isUndefined(ProjManager) || !$A.util.isEmpty(ProjManager))
            NOerrors =  this.checkvalidationLookup(ProjManager);
        return NOerrors;
    },
    
    validateProjectStartDate : function(component, event, helper) {
        var NOerrors = true;
        var projSD = component.find("projectStartDate");
        if(!$A.util.isUndefined(projSD) || !$A.util.isEmpty(projSD))
            NOerrors =  this.checkValidationField(projSD);
        return NOerrors;
    },
    
    validateProjectEndDate : function(component, event, helper) {
        var NOerrors = true;
        var projED = component.find("projectEndDate");
        if(!$A.util.isUndefined(projED) || !$A.util.isEmpty(projED))
            NOerrors =  this.checkValidationField(projED);
        
        return NOerrors;
    },
    
    validateProjectRouting : function (component, event) {
        var NOerrors = true;
        var ProjRouting = component.find("projectRouting");
        if(!$A.util.isUndefined(ProjRouting) || !$A.util.isEmpty(ProjRouting))
            NOerrors =  this.checkvalidationLookup(ProjRouting);
        return NOerrors;
    },
    
    validateProjectOrganisation : function (component, event) {
        var NOerrors = true;
        var ProjOrg = component.find("projectOrganisation");
        if(!$A.util.isUndefined(ProjOrg) || !$A.util.isEmpty(ProjOrg))
            NOerrors =  this.checkvalidationLookup(ProjOrg);
        return NOerrors;
    },
    
    validateMilestoneName : function(component, event, helper) {
        var NOerrors = true;
        var msName = component.find("newMilestoneName");
        if(!$A.util.isUndefined(msName) || !$A.util.isEmpty(msName))
            NOerrors =  this.checkValidationField(msName);
        
        return NOerrors;
    },
    
    validateEditMilestoneName : function(component, event, helper) {
        var NOerrors = true;
        var msName = component.find("editMilestoneName");
        if(!$A.util.isUndefined(msName) || !$A.util.isEmpty(msName))
            NOerrors =  this.checkValidationField(msName);
        
        return NOerrors;
    },
    
    validateMilestoneTeam: function (component, event) {
        var NOerrors = true;
        var msTeam = component.find("newMilestoneTeam");
        if(!$A.util.isUndefined(msTeam) || !$A.util.isEmpty(msTeam))
            NOerrors =  this.checkvalidationLookup(msTeam);
        return NOerrors;
    },
    
    checkvalidationLookup : function(cmp){
       
        if($A.util.isEmpty(cmp.get("v.selectedRecordId"))){
            cmp.set("v.inputStyleclass","hasError");
            return false;
        }else{
            cmp.set("v.inputStyleclass",""); 
            return true;
        }
    },
    
    checkValidationField : function(cmp){
        if($A.util.isEmpty(cmp.get("v.value"))){
            cmp.set("v.class","hasError");
            return false;
        }else{
            cmp.set("v.class","");
            return true;
        }
        
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
            toastEvent.fire();
        }
    }
})