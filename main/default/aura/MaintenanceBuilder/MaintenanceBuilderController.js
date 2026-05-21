({
	getAllDetails : function(cmp, event, helper) { 
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.getAll");
        action.setParams({ View : cmp.get("v.View"), Site : "", WC : "", SO : "", statusWO : ""});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    var ik = JSON.stringify(response.getReturnValue());
                    //alert(ik);
                   	//cmp.set("v.View", "Work Center");
                    cmp.set("v.WCCP", response.getReturnValue());
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    loadAllDetails : function(cmp, event, helper) {
        window.scrollTo(0, 0);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.getAll");
        var myView = cmp.get("v.View");
        var mySite = (cmp.get("v.WC.ERP7__Plant__c") != undefined)? cmp.get("v.WC.ERP7__Plant__c") : "";
        var myWC = (cmp.get("v.WC.Id") != undefined)? cmp.get("v.WC.Id") : "";
        var mySO = (cmp.get("v.SOID") != undefined)? cmp.get("v.SOID") : "";
        action.setParams({
            View : myView,
            Site : mySite,
            WC : myWC,
            SO : mySO,
            statusWO : cmp.get("v.selectedWOStatus")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    cmp.set("v.WCCP", response.getReturnValue());
                    cmp.set("v.FilterShow", false);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },

    statusCard : function(cmp, event, helper){
        if(cmp.get("v.selectedWOStatus") != event.currentTarget.dataset.status){
            cmp.set("v.selectedWOStatus", event.currentTarget.dataset.status);
            cmp.popInit();
        }
    },
	
    ToggleButtonM : function (cmp, event) {
        cmp.set("v.View", "Manufacturing");
        cmp.popInit();
    },
    
    ToggleButtonW : function (cmp, event) {
        cmp.set("v.View", "Work Center");
        cmp.popInit();
    },

    FilterSet : function (cmp, event) {
        cmp.set("v.FilterShow", !cmp.get("v.FilterShow"));
    },

    toggleTabs : function(cmp, event){
        var tab = event.currentTarget.dataset.tab;
        cmp.set("v.View", tab);
    },

    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    //NavScheduler : function (component, event) {
        
        //var RecUrl = "/apex/ERP7__MaintenanceSchedule";
        //$A.get("e.force:navigateToURL").setParams(
    	//{"url": RecUrl}).fire();
        
        //window.location.href = '/apex/ERP7__ManufacturingSchedule';
    //},
    NavScheduler : function (component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                "Flow":'WO',
                "NAV":'WCCPM',
                "RD":'yes',
                "tabNavi" : "WOworkbench"
            }
        });
        evt.fire();
    },

    NavPlanner : function (component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterCapacityPlanningMaintenance",
            componentAttributes: {
            }
        });
        evt.fire();
    },
	
    NavWO : function (component, event) {
        var WO_Id = event.currentTarget.dataset.recordId;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Work_Orders",
            componentAttributes: {
                RD  : 'yes',
                NAV : 'mpe',
                WO  : WO_Id
            }
        });
        evt.fire();
    },
    
    NavMO : function (component, event) {
        var RecUrl = "/apex/ERP7__WorkOrderLC?rd=yes";
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": RecUrl
        });
        urlEvent.fire();
    },
    
    DeleteRecord :function(cmp, event, helper){
        var result = confirm("Are you sure?");
        var RecordId = event.getSource().get("v.name");
        if (result) {
            cmp.set("v.RecordId",RecordId);
            cmp.find("deleteHandler").reloadRecord();
        } 
    },
    
    CommitDeleteRecord : function(cmp, event, helper) {
		cmp.find("deleteHandler").deleteRecord($A.getCallback(function(deleteResult) {
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                cmp.popInit();
            }               
        }));
    },
    
    ScheduleWO: function(cmp, event, helper) {
        var WOId = event.getSource().get("v.name");
        $A.createComponent("c:WorkCenterSchedule",{
            "WOId":WOId,
            "Flow":'WO',
            "NAV":'MaintenanceBuilder',
            "RD":'yes'
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
})