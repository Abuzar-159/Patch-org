({
    doInit : function(component, event, helper) {
        component.set("v.setStatus", '');
        var action = component.get("c.getAllProjects");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.AllProjectsWP", response.getReturnValue());
                var projects = component.get("v.AllProjectsWP");
                var listPROJ = [];
                for (var i in projects) {
                    if(projects[i].ERP7__Status__c == "Planned") {
                        listPROJ.push(projects[i]);
                    }
                }
                component.set("v.PlannedProjects", listPROJ.length);
                console.log('PlannedProjects',component.get("v.PlannedProjects"));
                listPROJ = [];
                for (var i in projects) {
                    if(projects[i].ERP7__Status__c == "In Progress") {
                        listPROJ.push(projects[i]);
                    }
                }
                if(listPROJ.length > 0)
                    component.set("v.inProgressProjects", listPROJ.length);
                console.log('inProgressProjects',component.get("v.inProgressProjects"));
                listPROJ = [];
                for (var i in projects) {
                    if(projects[i].ERP7__Status__c == "Completed") {
                        listPROJ.push(projects[i]);
                    }
                }
                if(listPROJ.length > 0)
                    component.set("v.CompletedProjects", listPROJ.length);
                console.log('CompletedProjects',component.get("v.CompletedProjects"));
                listPROJ = [];
                
                for (var i in projects) {
                    if(projects[i].ERP7__Status__c == "Backlog") {
                        listPROJ.push(projects[i]);
                    }
                }
                if(listPROJ.length > 0)
                    component.set("v.BacklogProjects", listPROJ.length);
                console.log('BacklogProjects',component.get("v.BacklogProjects"));
                
            } 
        });
        $A.enqueueAction(action);
        helper.getProjectDetails(component, event);
	},
    
    searchProjects :function(component, event, helper) {
        if(event.which == 13){
            var currentText = component.get("v.searchProjectStr");
            if(currentText != null && currentText != undefined && currentText != "")
                helper.getSearchProjects(component, event, currentText);
        }
        if(event.which == undefined)
            if(component.get("v.searchProjectStr") == null || component.get("v.searchProjectStr") == undefined || component.get("v.searchProjectStr") == "")
                helper.getProjectDetails(component, event);
    },
    
    
    OfsetChange : function(component,event,helper){
        var Offsetval = component.find("pageId").get("v.value");
        var curOffset = component.get("v.Offset");
        var show = parseInt(component.get("v.show"));
        if(Offsetval > 0 && Offsetval <= component.get("v.PNS").length){
            if(((curOffset+show)/show) != Offsetval){
                var newOffset = (show*Offsetval)-show;
                component.set("v.Offset", newOffset);
                component.set("v.CheckOffset",true);
                var pageNum = (newOffset + show)/show;
                component.set("v.PageNum",pageNum);
            }
            helper.getProjectDetails(component, event, helper);
        } 
        else component.set("v.PageNum",((curOffset+show)/show));
    },
    
    AddProject : function (component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Milestones",
            componentAttributes: {
                "newProj" : true,
            }
        });
        evt.fire();
    },
    
    CreateBudget : function(cmp, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BudgetPlannerUpdated",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
            componentAttributes: {
                fromProjectWB : true
            }
        });
        evt.fire();
    },
    
    setShow : function(cmp,event,helper){
          cmp.set("v.startCount", 0);
          cmp.set("v.endCount", 0);
          cmp.set("v.Offset", 0);
          cmp.set("v.PageNum", 1);
         helper.getProjectDetails(cmp, event);
    },
    
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
                var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            	//alert(Offsetval);    
            	component.set("v.Offset", Offsetval);
                //component.set("v.CheckOffset",true);
                component.set("v.PageNum",(component.get("v.PageNum")+1));
                helper.getProjectDetails(component, event, helper);
            }
     },
    
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.getProjectDetails(component, event, helper);
        }
    },
    
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
               var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            	//alert(Offsetval);    
            	component.set("v.Offset", Offsetval);
                //component.set("v.CheckOffset",true);
            	component.set("v.PageNum",(component.get("v.PageNum")-1));
                helper.getProjectDetails(component, event, helper);
            }
    },
    
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
               var Offsetval = 0;
                component.set("v.Offset", Offsetval);
                //component.set("v.CheckOffset",true);
            	component.set("v.PageNum",((component.get("v.Offset")+show)/show));
                helper.getProjectDetails(component, event, helper);
            }
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    NavProject: function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var currentProjectId = event.currentTarget.dataset.recordId;
        var currentProjIndex = event.currentTarget.dataset.index;
        var projects = component.get("v.ProjectsWP");
        var currentProject = '';
        currentProject = projects[currentProjIndex].project;
         console.log("currentProject: " , currentProject);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Milestones",
            componentAttributes: {
                "projectId" : currentProjectId,
                "currentProj" : currentProject,
                "newProj" : false,
            }
        });
        evt.fire();
    },
    
    listViewTab: function(component, event, helper) {
        if(!component.get("v.ListView")) {
            $A.util.removeClass(component.find("gridProjects"), 'acitve-list');
            $A.util.addClass(component.find("listProjects"), 'acitve-list');
            component.set("v.GridView", false);
            component.set("v.ListView", true);
        }
    },
    
    gridViewTab: function(component, event, helper) {
        if(!component.get("v.GridView")) {
            $A.util.removeClass(component.find("listProjects"), 'acitve-list');
            $A.util.addClass(component.find("gridProjects"), 'acitve-list');
            component.set("v.ListView", false);
            component.set("v.GridView", true);
        }
    },
    
    closeError : function(component, event, helper) {
        component.set("v.exceptionError", "");
    },
    
    projectTabClick : function(component, event, helper) {
        component.set("v.projectTab", true);
        component.set("v.schedulerTab", false);
    },
    
    schedulerTabClick : function(component, event, helper) {
        component.set("v.projectTab", false);
        component.set("v.schedulerTab", true);
        helper.NavScheduler(component, event);
    },
    
    toggleSearch : function(component, event){
        component.set("v.showSearch", !component.get("v.showSearch"));
    },
    changeRecs : function(component, event, helper){
        var status = event.currentTarget.getAttribute("data-attribute");
        console.log('inside changeRecs');
        component.set("v.setStatus", status);
        helper.getProjectDetails(component, event);
    },
    statusSearchMO :function(component, event, helper){
        console.log('inside statusSearchMO');
        $A.enqueueAction(component.get("c.doInit"));
    }
})