({
    /*getAllDets : function(component, event, helper) {
        var action = component.get("c.getAll");
        action.setParams({
            pjtID : component.get("v.projectId")
        });
        action.setCallback(this, function(response) {
        });
        $A.enqueueAction(action);
    },*/
    
    doInit : function(component, event, helper) {
         console.log("currentProj 1: " , component.get("v.currentProj"));
        component.set("v.currencySymbol", $A.get("$Locale.currency"));
        if(component.get("v.isRefresh")){
            component.set("v.isRefresh", false);
            component.refreshMsPage(); 
        }
        helper.setProjectStatus(component, event);
         console.log("currentProj 2: " , component.get("v.currentProj"));
        if(component.get("v.projectId") != null && component.get("v.projectId") != undefined && component.get("v.projectId") != ""){
            console.log("currentProj 3: " , component.get("v.currentProj"));
            component.set("v.newProj", false);
            var qry = component.get("v.qry");
            var obj = component.get("v.projectId");
            if(obj == undefined || obj == null || obj == "") qry = ' ';
            else qry = ' And ERP7__Project__c = \''+obj+'\'';
            component.set("v.qry",qry);
            var projectRouting = "";
            helper.setProjectMilestones(component, event, projectRouting);
            console.log("currentProj 4: " , component.get("v.currentProj"));
        }
        else {
            component.set("v.newProj", true);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        console.log("currentProj: " , component.get("v.currentProj"));
    },
    openPDF : function(component, event, helper) {
        var projId = component.get("v.currentProj.Id");
        if (projId) {
            var url = '/apex/ERP7__ProjectDoc?ra=pdf&projId=' + projId;
            window.open(url, '_blank');
        } else {
            alert('Project ID is missing!');
        }
    },
    setProjectDetails : function(component, event, helper) {
        if(component.get("v.projectId") != null && component.get("v.projectId") != undefined && component.get("v.projectId") != ""){
            component.set("v.newProj", false);
            helper.setProjDetails(component, event);
            component.set("v.refreshAmts", false);
        }
        else {
            component.set("v.currentProj", {'Name': '',
                                            'Id' : '',
                                            'ERP7__Status__c': '--none--',
                                            'ERP7__Start_Date__c': '',
                                            'ERP7__End_Date__c': '',
                                            'ERP7__Project_Manager__c': '',
                                            'ERP7__Organisations__c' : ''
                                           });
            component.set("v.milestones", {'Name': '',
                                            'Id' : '',
                                            'ERP7__Status__c': '--none--',
                                            'ERP7__Start_Date__c': '',
                                            'ERP7__Due_Date__c': '',
                                           	'ERP7__Percentage__c' : '',
                                            'ERP7__Organisations__c' : ''
                                           });
            component.set("v.newProj", true);
        }
    },
    
    saveProject : function(component, event, helper) {
        var pjtManager = component.get("v.currentProj.ERP7__Project_Manager__c");
        var pjtOrganisation = component.get("v.currentProj.ERP7__Organisations__c");
        component.set("v.isresetProject", false);
        component.set("v.currentProj.ERP7__Project_Manager__c", null);
        component.set("v.currentProj.ERP7__Organisations__c", null);
        component.set("v.currentProj.ERP7__Project_Manager__c", pjtManager);
        component.set("v.currentProj.ERP7__Organisations__c", pjtOrganisation);
        
        if(component.get("v.newProj")) {
            var project = component.get("v.currentProj");
            project.ERP7__Active__c = true;
            project.ERP7__Percentage__c = 0; 
            component.set("v.currentProj", project);
        }
        var projNameCheck = helper.validateProjectName(component, event);
        var projManagerCheck = helper.validateProjectManager(component, event);
        var projOrg = helper.validateProjectOrganisation(component, event);
        if (projNameCheck && projManagerCheck && projOrg){
            component.set("v.isresetProject",true);
            helper.saveCurrProject(component, event);
        }
        else{
            component.set("v.isresetProject", false);
            var errorMessage = '';
            if(!projNameCheck && !projManagerCheck && !projOrg){
                errorMessage = "Please enter the required fields that are marked *.";
            }
            else{
                
                errorMessage = " Please enter "
                if (!projNameCheck)
                    errorMessage += "Project Name";
                
                if(!projManagerCheck){
                    if(errorMessage != " Please enter ")
                        errorMessage += " & ";
                    
                    errorMessage += "Project Manager";
                }
                
                if (!projOrg){
                    if(errorMessage != " Please enter ")
                        errorMessage += " & ";
                    
                    errorMessage += "Project Organisation ";
                }
                errorMessage += ".";
            }
            component.set("v.exceptionError",errorMessage);
        }
    },
    
    openModal :function(component, event, helper) {
        if(component.get("v.milestoneOptions").length < 1)  helper.setMilestonesStatus(component, event);
        $A.util.addClass(component.find("NewMilestone"), 'slds-fade-in-open');
        $A.util.addClass(component.find("NewMilestoneBackdrop"), 'slds-backdrop_open');
        component.set("v.isNewMS", true);
    },
    
    editopenModal :function(component, event, helper) {
        if(component.get("v.milestoneOptions").length < 1)  helper.setMilestonesStatus(component, event);
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
    
    addMilestone : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var milestone = component.get("v.newMilestone");
        var milestoneNameCheck;
        var milestoneToSave;
        if(component.get("v.isNewMS")){
            milestone.ERP7__Percentage__c = 0;
            milestone.ERP7__Project__c = component.get("v.projectId");
            milestone.ERP7__Organisations__c = component.get("v.currentProj").ERP7__Organisations__c;
            component.set("v.newMilestone", milestone);
         	milestoneNameCheck = helper.validateMilestoneName(component, event);
            milestoneToSave = component.get("v.newMilestone");
        }
        else{
            milestoneNameCheck = helper.validateEditMilestoneName(component, event);
            milestoneToSave = component.get("v.editMilestone");
        }
        if(milestoneNameCheck)
        	helper.saveMilestone(component, event, milestoneToSave);
        else {
            var errorMessage = '';
            errorMessage = " Please enter "
            if (!milestoneNameCheck)
                errorMessage += "Milestone Name";
            errorMessage += ".";
            component.set("v.exceptionError",errorMessage);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
    },
    
    EditMs : function(component, event, helper) {
		var msList = component.get("v.milestonesWP");
        component.set("v.isNewMS", false);
		var currentMsId = event.currentTarget.dataset.recordId;
        for(var i in msList) {
            if(msList[i].milestone.Id == currentMsId) {
                component.set("v.editMilestone", msList[i].milestone);
                if(component.get("v.milestoneOptions").length < 1) helper.setMilestonesStatus(component, event);
                helper.editopenModal(component, event, helper);
            }
        }
    },
    
    deleteMs : function(component, event, helper) {
		var msList = component.get("v.MilestonesWP");
		var currentMsId = event.currentTarget.dataset.recordId;
		var currentIndex = event.currentTarget.dataset.index;
        if(confirm("Are you sure?"))
        	helper.deletecurrentMilestone(component, event, currentMsId);
    },
    
    deleteTsk : function(component, event, helper) {
		var msList = component.get("v.MilestonesWP");
		var currentTskId = event.currentTarget.dataset.recordId;
		var currentMsIndex = event.currentTarget.dataset.record;
       
		var currentTskIndex = event.currentTarget.dataset.index;
        if(confirm("Are you sure?"))
        	helper.deletecurrentTask(component, event, currentTskId, currentTskIndex, currentMsIndex);
    },
    
    addTask : function(component, event, helper) {
        var currentMilestone = '';
        var milestones = component.get("v.milestonesWP");
        for (var i in milestones) {
            if(milestones[i].isCurrentM == true) {
                currentMilestone = milestones[i].milestone.Id;
                break;
            }
        }
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AddMilestoneTask",
            componentAttributes: {
                "milestoneId" : currentMilestone,
                "projectId" : component.get("v.projectId"),
                "currentMilestones" : component.get("v.milestonesWP"),
                "currentProject" : component.get("v.currentProj")
            }
        });
        evt.fire();
    },
    
    selectMilestone : function(component, event, helper) {
		var currentMilestone = event.currentTarget.dataset.recordId;
        var milestonesWrap = component.get("v.milestonesWP");
        var isopen = false;
        for(var i in milestonesWrap) {
            if(milestonesWrap[i].milestone.Id == currentMilestone)
                if(milestonesWrap[i].isCurrentM){
                    milestonesWrap[i].isCurrentM = false
                    isopen = true;
                }
        }
        if(!isopen) {
            for (var x in milestonesWrap)
                milestonesWrap[x].isCurrentM = false; 
            for (var x in milestonesWrap) {
                if(milestonesWrap[x].milestone.Id == currentMilestone)
                    milestonesWrap[x].isCurrentM = true; 
            }
        }
        component.set("v.milestonesWP", milestonesWrap);
    },
    
    openTask : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var currentTaskId = event.currentTarget.dataset.recordId;
        var milestones = component.get("v.milestonesWP");
        var currentMilestone = '';
        for (var ms in milestones)
            if(milestones[ms].isCurrentM)
                currentMilestone = milestones[ms];
        var tasks = currentMilestone.TaskList;
        var currentTask = '';
        for (var i in tasks)
            if(tasks[i].Id == currentTaskId){
                currentTask = tasks[i];
                break;
            }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AddMilestoneTask",
            componentAttributes: {
                "projectId" : component.get("v.projectId"),
                "newTask" : currentTask,
                "taskId" : currentTaskId,
                "currentMilestones" : component.get("v.milestonesWP"),
                "currentProject" : component.get("v.currentProj")
            }
        });
        evt.fire();
    },
    
    goBack : function(component, event, helper) {
        //window.history.back();
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ProjectWorkbench",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    closeError : function (cmp, event) {
    	cmp.set("v.exceptionError",'');
    },
    
    CreateBudget : function(cmp, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BudgetPlannerUpdated",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
            componentAttributes: {
                fromProject : true,
                ProjectId : cmp.get("v.projectId"),
                currentProj : cmp.get("v.currentProj")
            }
        });
        evt.fire();
    },
    
    onCheck : function(component, event, helper) {
        var currBudgetType = event.currentTarget.getAttribute('data-billType');
        if(currBudgetType=='PO'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreatePurchaseOrder",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
                componentAttributes: {
                    "currentProj" : component.get("v.currentProj"),
                    "ProjId" : component.get("v.projectId"),
                    "fromProject" : true
                }
            });
            evt.fire();
        }else if(currBudgetType=='Bill'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreateBill",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
                componentAttributes: {
                    "currentProj" : component.get("v.currentProj"),
                    "ProjId" : component.get("v.projectId"),
                    "fromProject" : true
                }
            });
            evt.fire();
        }else if(currBudgetType=='DebitNote'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreateDebitNote",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
                componentAttributes: {
                    "currentProj" : component.get("v.currentProj"),
                    "ProjectId" : component.get("v.projectId"),
                    "fromProject" : true,
                    "showPage" : true
                }
            });
            evt.fire();
        }else if(currBudgetType=='SalesOrder'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:OrderConsole",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
                componentAttributes: {
                    "currentProj" : component.get("v.currentProj"),
                    "projectId" : component.get("v.projectId"),
                    "fromProject" : true
                }
            });
            evt.fire();
        }else if(currBudgetType=='Invoice'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CreateInvoice",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
                componentAttributes: {
                }
            });
            evt.fire();
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Timesheets",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
                componentAttributes: {
                }
            });
            evt.fire();
        }
    },
    
    AddProjectType : function(component, event, helper) {
        component.set("v.PoTypeRecord", false);
    },
    
    cancelclick : function(component, event, helper) {
        component.set("v.PoTypeRecord", true);
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    switchTab : function(component,event,helper){
        var currentTab = component.get("v.selectedTab");
        component.set("v.selectedTab",currentTab);
    },
    
    setLimit : function(component,event,helper){
        console.log('Description-->'+component.get("v.currentProj.ERP7__Description__c").length);
        if(component.get("v.currentProj.ERP7__Description__c").length>120){
            var descr = component.get("v.currentProj.ERP7__Description__c");
            var myTruncatedString = descr.substring(0,118);
            component.set("v.exceptionError",'Maximum 120 Characters can be entered as Description');
            component.set("v.currentProj.ERP7__Description__c", myTruncatedString);
        }else{
            //console.log('Description-->'+component.get("v.currentProj.ERP7__Description__c").length);
        }
    }
    
    
})