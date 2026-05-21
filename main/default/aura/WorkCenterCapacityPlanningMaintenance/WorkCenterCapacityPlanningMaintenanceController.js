({
    searchWO : function(cmp, event, helper){
        cmp.set("v.Offset", 0);
        if(event.which == 13){
            cmp.popInit();
        }
        if(event.which == undefined)
            if(cmp.get("v.WCCP.searchWOs") == null || cmp.get("v.WCCP.searchWOs") == undefined || cmp.get("v.WCCP.searchWOs") == "")
                $A.enqueueAction(cmp.get("c.getAllDetails"));
    },
    
    statusSearchWO : function(cmp, event, helper){
        cmp.set("v.Offset", 0);
        cmp.set("v.WCCP.statusWOs", event.currentTarget.dataset.status);
        if(cmp.get("v.WCCP.statusWOs") == "All") $A.enqueueAction(cmp.get("c.getAllDetails"));
        else cmp.popInit();
    },
    
    getAllDetails : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.getAll");
        action.setParams({
            currentWCCP : "",
            IsNew : true,
            Flow : "WO",
            wcOffset : cmp.get("v.Offset"),
            RecordLimit : cmp.get("v.showPg")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try { 
                    cmp.set("v.WCCP", response.getReturnValue());
                    cmp.set("v.WOSWrap", response.getReturnValue().WOSWrp);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    
                    //pagination
                    cmp.set("v.recSize",response.getReturnValue().recSize);
                    if(cmp.get("v.WCCP.WOS").length>0){
                        var startCount = cmp.get("v.Offset") + 1;
                        var endCount = cmp.get("v.Offset") + cmp.get("v.WCCP.WOS").length;
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
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }
            else console.log("error -> ", response.getError());
        });
        $A.enqueueAction(action);
    },
    
    loadAllDetails : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var currentWCCP = cmp.get("v.WCCP");
        var action = cmp.get("c.getAll");
        action.setParams({
            currentWCCP : JSON.stringify(currentWCCP),
            IsNew : false,
            Flow : "WO",
            wcOffset : cmp.get("v.Offset"),
            RecordLimit : cmp.get("v.showPg")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try {
                    cmp.set("v.WCCP", response.getReturnValue());
                    cmp.set("v.WOSWrap", response.getReturnValue().WOSWrp);
                    cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                    
                    //pagination
                    cmp.set("v.recSize",response.getReturnValue().recSize);
                    if(cmp.get("v.WCCP.WOS").length>0){
                        var startCount = cmp.get("v.Offset") + 1;
                        var endCount = cmp.get("v.Offset") + cmp.get("v.WCCP.WOS").length;
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
                
                } catch(err) {
                    cmp.set("v.exceptionError", err.message);
                    //alert("Exception : "+err.message);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            }else{console.log("error : ",cmp.getError());}
        });
        $A.enqueueAction(action);
    },
	
    FilterSet : function (cmp, event) {
        cmp.set("v.FilterShow", !cmp.get("v.FilterShow"));
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    NavScheduler : function (component, event) {
        //var RecUrl = "/lightning/n/ERP7__Schedular";
        //$A.get("e.force:navigateToURL").setParams(
    	//{"url": RecUrl}).fire();
        //window.open(RecUrl,"_self");
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
    
    NavBuilder : function (component, event) {
        var RecUrl = "/lightning/n/ERP7__Maintenance_Builder"; //"/apex/ERP7__ManageWOS";
        $A.get("e.force:navigateToURL").setParams(
    	{"url": RecUrl}).fire();
    },
	
    NavMO : function (component, event) {
        var RecUrl = "/apex/ERP7__WorkOrderLC?rd=yes";
        $A.get("e.force:navigateToURL").setParams(
    	{"url": RecUrl}).fire();
    },
    
    /*
    NavWO : function (component, event) {
        var RecUrl = "/apex/ERP7__WorkOrderLC?rd=yes&nav=mpe";
        $A.get("e.force:navigateToURL").setParams(
    	{"url": RecUrl}).fire();
    },
    */
    
    NavWO: function(cmp, event, helper) {
        $A.createComponent("c:WorkCenterSchedule",{
            "Flow":'WO',
            "NAV":'WCCPM',
            "RD":'yes'
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    Nav2WO : function (component, event) {
        //var WO = event.getSource().get("v.title");
        var WO_Id = event.currentTarget.dataset.recordId;
        //var RecUrl = "/apex/ERP7__WorkOrderLC?rd=yes&nav=mpe&wo="+WO;
        //$A.get("e.force:navigateToURL").setParams(
        //{"url": RecUrl}).fire();
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

    toggleTabs : function(cmp, event){
        var tab = event.currentTarget.dataset.tab;
        if(tab == 'Shift Planner'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:UsersShiftMatch",
                componentAttributes: {
                    View : tab,
                    Flow : 'Maintainance',
                    navWorkbench : 'WO'
                }
            });
            evt.fire();
        }
        else cmp.set("v.View", tab);
    },

    //Pagination.
    OfsetChange : function(component,event,helper){
        var Offsetval = component.find("pageId").get("v.value");
        var curOffset = component.get("v.Offset");
        var show = parseInt(component.get("v.showPg"));
        if(Offsetval > 0 && Offsetval <= component.get("v.PNS").length){
            if(((curOffset+show)/show) != Offsetval){
                var newOffset = (show*Offsetval)-show;
                component.set("v.Offset", newOffset);
                component.set("v.CheckOffset",true);
                var pageNum = (newOffset + show)/show;
                component.set("v.PageNum",pageNum);
            }
            $A.enqueueAction(component.get("c.loadAllDetails"));
            //helper.setMOs(component, event);
        } 
        else component.set("v.PageNum",((curOffset+show)/show));
    },
    
    setShow : function(component,event,helper){
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.PageNum", 1);
        $A.enqueueAction(component.get("c.loadAllDetails"));
        //helper.setMOs(component, event);
    },
    
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.showPg'));
            component.set("v.Offset", Offsetval);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            $A.enqueueAction(component.get("c.loadAllDetails"));
            //helper.setMOs(component, event);
        }
    },
    
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.showPg"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            component.set("v.Offset", Offsetval);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            $A.enqueueAction(component.get("c.loadAllDetails"));
            //helper.setMOs(component, event);
        }
    },
    
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.showPg'));
            component.set("v.Offset", Offsetval);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            $A.enqueueAction(component.get("c.loadAllDetails"));
            //helper.setMOs(component, event);
        }
    },
    
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.showPg"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            component.set("v.Offset", Offsetval);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            //helper.setMOs(component, event);
            $A.enqueueAction(component.get("c.loadAllDetails"));
        }
    },
    //Pagination End.

    closeError : function (component, event, helper){
        component.set("v.exceptionError","");
    }
    
})