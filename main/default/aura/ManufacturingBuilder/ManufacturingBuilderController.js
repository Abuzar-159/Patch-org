({
	getAllDetails : function(cmp, event, helper) {
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.getAll");
        //alert(cmp.get("v.View"));
        action.setParams({ 
            View : cmp.get("v.View"),
            Site : "",
            WC : "",
            SO : "",
            WOstate : "All",
            durationMO : cmp.get("v.MOduration"),
            timelineMO : cmp.get("v.MOtimeLine")
        });
        action.setCallback(this, function(response) {
            document.getElementById("spinnerSet").classList.add("slds-hide");
            if (response.getState() === "SUCCESS"){
                try{
                    cmp.set("v.showPlanner",response.getReturnValue().showPlanner);
                    cmp.set("v.showSheduler",response.getReturnValue().showSheduler);
                    cmp.set("v.StandardOrder",response.getReturnValue().isStandardOrder);
                    cmp.set("v.showBuilder",response.getReturnValue().showBuilder); 
                    cmp.set("v.showMO",response.getReturnValue().showMO);
                    cmp.set("v.IssuedWO",response.getReturnValue().IssuedWO);
                    cmp.set("v.ProgressWO",response.getReturnValue().ProgressWO);
                    cmp.set("v.CompletedWO",response.getReturnValue().CompletedWO); 
                    cmp.set("v.BackLogWO",response.getReturnValue().BackLogWO);
                    cmp.set("v.WCCP", response.getReturnValue());
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    //var today = new Date();
        			//cmp.set("v.today", today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
            else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                if (errors){
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error~>"+errors);
                }
            }
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    loadAllDetails : function(cmp, event, helper) {
        //window.scrollTo(0, 0);
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        document.getElementById("spinnerSet").classList.remove("slds-hide");
        var action = cmp.get("c.getAll");
        var mySite = (cmp.get("v.WC.ERP7__Plant__c") != undefined)? cmp.get("v.WC.ERP7__Plant__c") : "";
        var myWC = (cmp.get("v.WC.Id") != undefined)? cmp.get("v.WC.Id") : "";
        var mySO = (cmp.get("v.SOID") != undefined)? cmp.get("v.SOID") : "";
        var myOrd = (cmp.get("v.OrderID") != undefined)? cmp.get("v.OrderID") : "";
        action.setParams({
            View : cmp.get("v.View"),
            Site : mySite,
            WC : myWC,
            SO : mySO,
            WOstate : cmp.get("v.selectedWOStatus"),
            durationMO : cmp.get("v.MOduration"),
            timelineMO : cmp.get("v.MOtimeLine"),
            order : myOrd
        });
       
        action.setCallback(this, function(response) {
            document.getElementById("spinnerSet").classList.add("slds-hide");
            if (response.getState() === "SUCCESS") {
                try { 
                    cmp.set("v.WCCP", response.getReturnValue());
                    cmp.set("v.FilterShow", false);
                    cmp.set("v.IssuedWO",response.getReturnValue().IssuedWO);
                    cmp.set("v.ProgressWO",response.getReturnValue().ProgressWO);
                    cmp.set("v.CompletedWO",response.getReturnValue().CompletedWO); 
                    cmp.set("v.BackLogWO",response.getReturnValue().BackLogWO);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
            else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error~>"+errors);
                }
            }
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    statusCard : function(cmp, event, helper){
        if(cmp.get("v.selectedWOStatus") != event.currentTarget.dataset.status){
            cmp.set("v.selectedWOStatus", event.currentTarget.dataset.status);
            cmp.popInit();
        }
    },
    
    handleDuration : function(cmp, event, helper){
        
        if(event.which == 13){
            if(cmp.get("v.MOduration") <= 0) cmp.set("v.MOduration", 1);
            //if(cmp.get("v.MOtimeLine") == 'D' && cmp.get("v.MOduration")%2 == 0)
                //cmp.set("v.MOduration", cmp.get("v.MOduration")+1);
            cmp.popInit();
        }
    },
    
    handleTimeline : function(cmp, event, helper){
        if(cmp.get("v.MOtimeLine") == 'D' && cmp.get("v.MOduration")%2 == 0)
            cmp.set("v.MOduration", cmp.get("v.MOduration")+1);
        cmp.popInit();
    },
    
    toggleTabs : function(cmp, event){
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var tab = event.currentTarget.dataset.tab;
        cmp.set("v.View", tab);
        setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }), 1000
        );

    },
    
    FilterSet : function (cmp, event) {
        console.log('FilterShow : '+cmp.get("v.FilterShow"));
        cmp.set("v.FilterShow", !cmp.get("v.FilterShow"));
        console.log('FilterShow after: '+cmp.get("v.FilterShow"));
    },
    
    NavRecord : function (cmp, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    NavScheduler : function (cmp, event) {
        var RecUrl = "/lightning/n/ERP7__Schedular";
        //$A.get("e.force:navigateToURL").setParams(
    	//{"url": RecUrl}).fire();
    	window.open(RecUrl,"_self");
    },
    
    
    NavPlanner : function (cmp, event) {
        var RecUrl = "/lightning/n/ERP7__Work_Center_Capacity_Planning";
       // var urlEvent = $A.get("e.force:navigateToURL");
        //urlEvent.setParams({
          //"url": RecUrl
        //});
        //urlEvent.fire();
    	window.open(RecUrl,"_self");
        
    },
	
    NavMO : function (cmp, event) {
        var RecUrl = "/apex/ERP7__ManufacturingOrderLC?rd=yes&nav=mb";
        //$A.get("e.force:navigateToURL").setParams(
    	//{"url": RecUrl}).fire();
    	window.open(RecUrl,"_self");
    },
    
    Nav2MO : function (cmp, event) {
        var MO = event.currentTarget.dataset.recordId;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Manufacturing_Orders",
            componentAttributes: {
                "MO": MO,
                "RD" : "yes",
                "NAV": "mb"
            },
            isredirect : true
        });
        evt.fire();
    },
    
    NavWO : function (cmp, event) {
        var WOId = event.currentTarget.dataset.recordId;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BuildSchedule_M",
            componentAttributes: {
                "WO" : WOId,
                "RD" : "yes",
                "NAV": "mo"
            },
            isredirect : true
        });
        evt.fire();
    },
    
    ScheduleMO: function(cmp, event, helper) {
        var MOId = event.currentTarget.dataset.recordId;
        $A.createComponent("c:WorkCenterSchedule",{
            "MOId":MOId,
            "Flow":'MO',
            "NAV":'ManufacturingBuilder',
            "RD":'yes'
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    
    closeError : function(cmp, event, helper){
        if(cmp.get('v.WC.ERP7__Plant__c') != '') cmp.set('v.WC.ERP7__Plant__c','');
        if(cmp.get('v.WC.Id') != '') cmp.set('v.WC.Id','');
        if(cmp.get('v.SOID') != '') cmp.set('v.SOID','');
        //if(cmp.get('v.SOID') != '') cmp.set('v.SOID','');
        //if(cmp.get('v.SOID') != '') cmp.set('v.SOID','');
        cmp.set("v.exceptionError","");
    }
    
})