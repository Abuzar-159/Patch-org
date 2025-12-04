({
	getProjectDetails : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
		var action = component.get("c.getProjects");
        //component.set("v.Offset", 5);
        action.setParams({
            pjtOffset: component.get("v.Offset"),
            RecordLimit: component.get('v.show'),
            status: component.get('v.setStatus'),
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.ProjectsWP", response.getReturnValue());
                console.log('component.get("v.ProjectsWP").length ',component.get("v.ProjectsWP").length);
                var pjt = component.get("v.ProjectsWP");
                for(var i in pjt) {
                    component.set("v.recSize",pjt[i].recSize);
                }
                if(component.get("v.ProjectsWP").length>0){
                    var startCount = component.get("v.Offset") + 1;
                    var endCount = component.get("v.Offset") + component.get("v.ProjectsWP").length;
                    component.set("v.startCount", startCount);
                    component.set("v.endCount", endCount);
                    //component.set("v.PageNum",1);
                    var myPNS = [];
                    var ES = component.get("v.recSize");
                    var i=0;
                    var show=component.get('v.show');
                    while(ES >= show){
                        i++; myPNS.push(i); ES=ES-show;
                    } 
                    if(ES > 0) myPNS.push(i+1);
                    component.set("v.PNS", myPNS);
                }
                //this.projectStatusCount(component, event);
                component.set("v.menu",true);
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
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
	},
    
    getSearchProjects : function(component, event, pjtName) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
		var action = component.get("c.getsimilarProjects");
        action.setParams({
            "searchStr" : pjtName
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.ProjectsWP", response.getReturnValue());
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
        $A.enqueueAction(action);
	},
    
    projectStatusCount : function(component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var projects = component.get("v.ProjectsWP");
        var listPROJ = [];
        for (var i in projects) {
            if(projects[i].project.ERP7__Status__c == "Planned") {
                listPROJ.push(projects[i]);
            }
        }
        component.set("v.PlannedProjects", listPROJ.length);
        console.log('PlannedProjects',component.get("v.PlannedProjects"));
        listPROJ = [];
        for (var i in projects) {
            if(projects[i].project.ERP7__Status__c == "In Progress") {
                listPROJ.push(projects[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.inProgressProjects", listPROJ.length);
        console.log('inProgressProjects',component.get("v.inProgressProjects"));
        listPROJ = [];
        for (var i in projects) {
            if(projects[i].project.ERP7__Status__c == "Completed") {
                listPROJ.push(projects[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.CompletedProjects", listPROJ.length);
        console.log('CompletedProjects',component.get("v.CompletedProjects"));
        listPROJ = [];
        
        for (var i in projects) {
            if(projects[i].project.ERP7__Status__c == "Backlog") {
                listPROJ.push(projects[i]);
            }
        }
        if(listPROJ.length > 0)
            component.set("v.BacklogProjects", listPROJ.length);
        console.log('BacklogProjects',component.get("v.BacklogProjects"));
        
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    NavScheduler : function (component, event) {
        var RecUrl = "/apex/ERP7__ProjectScheduler";
        $A.get("e.force:navigateToURL").setParams(
    	{"url": RecUrl}).fire();
    }
})