({
    searchMO : function(cmp, event, helper){
        cmp.set("v.Offset", 0);
        console.log('searchMO event.which : '+event.which);
        console.log('v.WCCP.searchMOs : '+cmp.get("v.WCCP.searchMOs"))
       // if(event.which == 13){
           //cmp.popInit();
        //}
       // if(event.which == undefined)
            if(cmp.get("v.WCCP.searchMOs") == null || cmp.get("v.WCCP.searchMOs") == undefined || cmp.get("v.WCCP.searchMOs") == "")
                $A.enqueueAction(cmp.get("c.getAllDetails"));
        	else  cmp.popInit();
    },
    
    statusSearchMO : function(cmp, event, helper){
        cmp.set("v.Offset", 0);
        cmp.set("v.WCCP.statusMOs", event.currentTarget.dataset.status);
        if(cmp.get("v.WCCP.statusMOs") == "All") $A.enqueueAction(cmp.get("c.getAllDetails"));
        else cmp.popInit();
    },
    
    TravellerDoc: function(component, event, helper){
        console.log('TravellerDoc');
        var MOId = event.currentTarget.dataset.recordId;
        component.set("v.MOId",MOId);
        if(component.get("v.ShowLangOptionForTraveller")){
            component.set("v.ShowLangOptionForTravellerModal",true);
        }else{
            var Traveller = $A.get("$Label.c.TravellerDOC");
            //Changes made by Arshad 14/06/2023
            if(component.get("v.ReplaceTravellerOrgURL")){
                var customOrgUrl =  $A.get("$Label.c.orgURL");
                console.log('customOrgUrl : ',customOrgUrl);
                var RecUrl = customOrgUrl+"/apex/"+Traveller+"?RId=" + MOId+'&ra=pdf';
                console.log('RecUrl~>'+RecUrl);
                window.open(RecUrl,'_blank'); 
            }else{
                var RecUrl = "/apex/"+Traveller+"?RId=" + MOId+'&ra=pdf';
                console.log('RecUrl~>'+RecUrl);
                window.open(RecUrl,'_blank'); 
            }
        }
    },
    
    goBackTraveller : function(component, event, helper) {
        component.set("v.ShowLangOptionForTravellerModal",false);
    },
    
    TravellerNext : function(component, event, helper) {
        var MOId = component.get("v.MOId");
        var Traveller = $A.get("$Label.c.TravellerDOC");
        var SelectedLang = component.get("v.SelectedLang");
        if(SelectedLang == "English"){
            Traveller = $A.get("$Label.c.TravellerDOC");
        }else if(SelectedLang == "French"){
            Traveller = $A.get("$Label.c.TravellerDOCFR");
        }
        if(component.get("v.ReplaceTravellerOrgURL")){
            var customOrgUrl =  $A.get("$Label.c.orgURL");
            console.log('customOrgUrl : ',customOrgUrl);
            var RecUrl = customOrgUrl+"/apex/"+Traveller+"?RId=" + MOId+'&ra=pdf';
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank'); 
        }else{
            var RecUrl = "/apex/"+Traveller+"?RId=" + MOId+'&ra=pdf';
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank'); 
        }
    },
    
	getAllDetails : function(cmp, event, helper) {
        if(cmp.get("v.View") == 'Shift Planner'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:UsersShiftMatch",
                componentAttributes: {
                    //View :tab,
                }
            });
            evt.fire();
        }
        else{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.getAll");
            action.setParams({ 
                currentWCCP : "", 
                IsNew : "true", 
                Flow : "MO",
                wcOffset : cmp.get("v.Offset"),
                RecordLimit : cmp.get("v.showPg")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                        try { 
                            if(response.getReturnValue().showPlanner == false && response.getReturnValue().showSheduler == true) cmp.NavScheduler();
                            else if(response.getReturnValue().showPlanner == false && response.getReturnValue().showBuilder == true) cmp.NavBuilder();
                            else{
                            cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                            cmp.set("v.showPlanner",response.getReturnValue().showPlanner);
                            cmp.set("v.showSheduler",response.getReturnValue().showSheduler);
                            cmp.set("v.showBuilder",response.getReturnValue().showBuilder); 
                                cmp.set("v.showStage",response.getReturnValue().showMOStage); 
                            cmp.set("v.ShowOrderandOrderProducts",response.getReturnValue().showOrderDetails);   
                                cmp.set("v.ShowLangOptionForTraveller",response.getReturnValue().ShowLangOptionForTraveller);
                                 cmp.set("v.ReplaceTravellerOrgURL",response.getReturnValue().ReplaceTravellerOrgURL);
                            /*if(!response.getReturnValue().showBuilder){
                                if(cmp.get("v.exceptionError")=='')
                                    cmp.set("v.exceptionError", "You don't have access to Builder, Contact your Administrator");
                            }*/
                                
                            cmp.set("v.WCCP", response.getReturnValue());
                            cmp.set("v.MOWRAP", response.getReturnValue().MOSWrp);
                            cmp.set("v.MOStatusCount", response.getReturnValue().totalMOS );
                            //pagination
                            cmp.set("v.recSize",response.getReturnValue().recSize);
                            if(cmp.get("v.WCCP.MOS").length>0){
                                var startCount = cmp.get("v.Offset") + 1;
                                var endCount = cmp.get("v.Offset") + cmp.get("v.WCCP.MOS").length;
                                cmp.set("v.startCount", startCount);
                                cmp.set("v.endCount", endCount);
                                var myPNS = [];
                                var ES = cmp.get("v.recSize");
                                var i=0;
                                var show=cmp.get('v.showPg');
                                while(ES >= show){
                                    i++; 
                                    myPNS.push(i); 
                                    ES=ES-show;
                                } 
                                if(ES > 0) myPNS.push(i+1);
                                cmp.set("v.PNS", myPNS);
                            }
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                                helper.MOStatusCount(cmp,event);
                       }
                        
                    } catch(err) {
                        cmp.set("v.exceptionError", err.message);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }
                else{
                    console.log('Error:',response.getError());
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
           
        }
    },
    
    loadAllDetails : function(cmp, event, helper) {
        window.scrollTo(0, 0);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var currentWCCP = cmp.get("v.WCCP");
        console.log('getAll currentWCCP : ',JSON.stringify(currentWCCP));
        var action = cmp.get("c.getAll");
        action.setParams({ 
            currentWCCP : JSON.stringify(currentWCCP), 
            IsNew : "false", 
            Flow : "MO",
            wcOffset : cmp.get("v.Offset"),
            RecordLimit : cmp.get("v.showPg")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try {
                    cmp.set("v.WCCP", response.getReturnValue());
                    cmp.set("v.MOWRAP", response.getReturnValue().MOSWrp);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    cmp.set("v.FilterShow", false);
                    
                    //pagination
                    cmp.set("v.recSize",response.getReturnValue().recSize);
                    if(cmp.get("v.WCCP.MOS").length>0){
                        var startCount = cmp.get("v.Offset") + 1;
                        var endCount = cmp.get("v.Offset") + cmp.get("v.WCCP.MOS").length;
                        cmp.set("v.startCount", startCount);
                        cmp.set("v.endCount", endCount);
                        //component.set("v.PageNum",1);
                        var myPNS = [];
                        var ES = cmp.get("v.recSize");
                        var i=0;
                        var show=cmp.get('v.showPg');
                        while(ES >= show){
                            i++; 
                            myPNS.push(i); 
                            ES=ES-show;
                        } 
                        if(ES > 0) myPNS.push(i+1);
                        cmp.set("v.PNS", myPNS);
                    }
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
            else{
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
	
    FilterSet : function (cmp, event) {
        cmp.set("v.FilterShow", !cmp.get("v.FilterShow"));
    },
    
    ScheduleMO: function(cmp, event, helper) {
        var MOId = event.currentTarget.dataset.recordId;
        $A.createComponent("c:WorkCenterSchedule",{
            "MOId":MOId,
            "Flow":'MO',
            "NAV":'WCCP',
            "RD":'yes'
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    NavScheduler : function (component, event) {
        var RecUrl = "/lightning/n/ERP7__Schedular";
        //$A.get("e.force:navigateToURL").setParams(
    	//{"url": RecUrl}).fire();
        window.open(RecUrl,"_self");
        
        /*var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:WorkCenterSchedule",
            componentAttributes: {
                "Flow":'MO',
                "NAV":'WCCPM',
                "RD":'yes',
                "tabNavi" : "MOworkbench"
            }
        });
        evt.fire();*/
    },
    
    NavBuilder : function (component, event) {
        var RecUrl = "/lightning/n/ERP7__Manufacturing_Builder";  //"/apex/ERP7__ManageMOS";
        //$A.get("e.force:navigateToURL").setParams(
    	//{"url": RecUrl}).fire();
    	window.open(RecUrl,"_self");
    },
    toggleTabs : function(cmp, event){
        var tab = event.currentTarget.dataset.tab;
        if(tab == 'Shift Planner'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:UsersShiftMatch",
                componentAttributes: {
                    View :tab,
                }
            });
            evt.fire();
        }
        else cmp.set("v.View", tab);
    },
	/*
    NavMO : function (component, event) {
        var RecUrl = "/apex/ERP7__ManufacturingOrderLC?rd=yes&nav=mp";
        $A.get("e.force:navigateToURL").setParams(
    	{"url": RecUrl}).fire();
    },
    */
    NavMO: function(cmp, event, helper) {
        $A.createComponent("c:WorkCenterSchedule",{
            "Flow":'MO',
            "NAV":'WCCP',
            "RD":'yes'
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    Nav2MO : function (component, event) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var moId = event.getSource().get("v.title");
        try{
         $A.createComponent("c:Manufacturing_Orders",{
             "MO":moId,
             "RD": "yes",
             "NAV": "mp",
             allowNav : true
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
            else{
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                console.log('Error occured ',errorMessage);
            }
        });
        }
        catch(err){
             console.log('Error occured '+err);
        }
        
       /* var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Manufacturing_Orders",
            componentAttributes: {
                "MO":moId,
                "RD": "yes",
                "NAV": "mp",
                allowNav : true
            }
        });
        evt.fire();*/
    },
    
    NavWO : function (component, event) {
        //var WOId = event.getSource().get("v.title");
        var WOId = event.currentTarget.dataset.recordId;
       /* var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BuildSchedule_M",
            componentAttributes: {
                "WO" : WOId,
                "RD" : "yes",
                "NAV": "mo",
            },
            isredirect : true
        });
        evt.fire();*/
        $A.createComponent("c:BuildSchedule_M",{
            "WO" : WOId,
            "RD" : "yes",
            "NAV": "mo",
                
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
    },
    
    EditRecord :function(cmp, event, helper){
        var RecordId = event.getSource().get("v.name");
        cmp.set("v.RecordId",RecordId);
        //cmp.set("v.Show",true);
        
        var windowHash = window.location.hash;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": RecordId,
             "panelOnDestroyCallback": function(event) {
                window.location.hash = windowHash;
             }
       });
       editRecordEvent.fire();
       
    },

    CancelEditRecord :function(cmp, event, helper){
        cmp.set("v.Show",false);
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
    
    Save : function(component, event, helper) {
        //component.find("editHandler").get("e.force:recordSave").fire();
        cmp.popInit();
	},

    CreateRecordWC : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var windowHash = window.location.hash;
        createRecordEvent.setParams({
            "entityApiName": "ERP7__Work_Center__c",
            "panelOnDestroyCallback": function(event) {
                window.location.hash = windowHash;
            }
        });
        createRecordEvent.fire();
    },
    
    CreateRecordRG : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var windowHash = window.location.hash;
        createRecordEvent.setParams({
            "entityApiName": "ERP7__Resource_Group__c",
            "panelOnDestroyCallback": function(event) {
                window.location.hash = windowHash;
            }
        });
        createRecordEvent.fire();
    },
    
    CreateRecordWP : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var windowHash = window.location.hash;
        createRecordEvent.setParams({
            "entityApiName": "ERP7__Work_Planner__c",
            "panelOnDestroyCallback": function(event) {
                window.location.hash = windowHash;
            }
        });
        createRecordEvent.fire();
    },
    
    CreateRecordRR : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var windowHash = window.location.hash;
        createRecordEvent.setParams({
            "entityApiName": "ERP7__Resource_Requirement__c",
            "panelOnDestroyCallback": function(event) {
                window.location.hash = windowHash;
            }
        });
        createRecordEvent.fire();
    },
    
    LoadShiftPlanner : function (cmp, event, helper) {
        //cmp.set("v.ShiftPlanner", false);
        cmp.set("v.ShiftPlanner", true);
    },
    
    closeError : function(component, event, helper) {
        component.set("v.exceptionError", "");
    },
    
    //Pagination.
    OfsetChange : function(component,event,helper){
        var Offsetval = component.find("pageId").get("v.value");
        console.log('Offsetval : ',Offsetval);
        console.log('Offsetval evt : ',event.currentTarget.value);
        var curOffset = component.get("v.Offset");
        console.log('curOffset : ',curOffset);
        var show = parseInt(component.get("v.showPg"));
        console.log('show : ',show);
        if(Offsetval > 0 && Offsetval <= component.get("v.PNS").length){
            console.log('inside if');
            if(((curOffset+show)/show) != Offsetval){
                console.log('inside if 2');
                var newOffset = (show*Offsetval)-show;
                component.set("v.Offset", newOffset);
                component.set("v.CheckOffset",true);
                var pageNum = (newOffset + show)/show;
                component.set("v.PageNum",pageNum);
            }
            helper.setMOs(component, event);
        } 
        else component.set("v.PageNum",((curOffset+show)/show));
    },
    
    setShow : function(component,event,helper){
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.PageNum", 1);
        helper.setMOs(component, event);
    },
    
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.showPg'));
            component.set("v.Offset", Offsetval);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.setMOs(component, event);
        }
    },
    
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.showPg"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            component.set("v.Offset", Offsetval);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.setMOs(component, event);
        }
    },
    
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.showPg'));
            component.set("v.Offset", Offsetval);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.setMOs(component, event);
        }
    },
    
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.showPg"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            component.set("v.Offset", Offsetval);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.setMOs(component, event);
        }
    },
    //Pagination End.
    
    Back2Planner : function(cmp, event, helper) {
        $A.createComponent("c:WorkCenterCapacityPlanning",{
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
})