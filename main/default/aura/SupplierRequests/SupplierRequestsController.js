({
	doInit : function(component, event, helper) {
        if(event.getParam("viewHome")){
            component.set("v.revert",false);
            $A.createComponent("c:SupplierPortalCommHome",{
                AccId:component.get("v.currentSupplier")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
            return;
        }
		helper.setRFPDetails(component, event, '');
	},
    
    setSingleStatus : function(component, event, helper){
        //alert("inside setSingleStatus...");
		var reqStatus = event.currentTarget.dataset.record;
        component.set("v.singleRFPStatus", reqStatus);
        component.set("v.Offset", 0);
        helper.setRFPDetails(component, event, component.get("v.searchReqProd"));
    },
    
    searchRFP : function(component, event, helper){
        if(event.which == 13){
            var currentText = component.get("v.searchReqProd");
            if(currentText != null && currentText != undefined && currentText != "")
                helper.setRFPDetails(component, event, currentText);
        }
        if(event.which == undefined)
            if(component.get("v.searchReqProd") == null || component.get("v.searchReqProd") == undefined || component.get("v.searchReqProd") == "")
                helper.setRFPDetails(component, event, '');
    },
    
    /*sortRequests : function(component, event, helper){
		var reqSort = event.currentTarget.dataset.record;
        component.set("v.sortRFPBy", reqSort);
        alert(component.get("v.sortRFPBy"));
        switch(component.get("v.ascRFPOrder")) {
            case "":
                component.set("v.ascRFPOrder", "ASC");
                break;
            case "ASC":
                component.set("v.ascRFPOrder", "DESC");
                break;
            case "DESC":
                component.set("v.ascRFPOrder", "ASC");
                break;
            default:
                component.set("v.ascRFPOrder", "");
        }
        //alert(component.get("v.ascRFPOrder"))
        helper.setRFPDetails(component, event, component.get("v.searchReqProd"));
    },*/
    
    openRFPModal : function(component, event, helper){
        helper.setPublicRFPDetails(component, event, '');
    },
    
    searchPublicRequest : function(component, event, helper){
        if(event.which == 13){
            var currentText = component.get("v.searchPublicReqProd");
            if(currentText != null && currentText != undefined && currentText != "")
                helper.setPublicRFPDetails(component, event, currentText);
        }
        if(event.which == undefined)
            if(component.get("v.searchPublicReqProd") == null || component.get("v.searchPublicReqProd") == undefined || component.get("v.searchPublicReqProd") == "")
                helper.setPublicRFPDetails(component, event, '');
    },
    
    handleRFPSelectAll : function(component, event, helper){
        var publicRFPs = component.get("v.publicRequests");
        if(component.get("v.selectAll") == true){
            for(var i in publicRFPs){
                publicRFPs[i].selected = true;
            }
            component.set("v.publicRequests",publicRFPs);
        }
        else if(component.get("v.selectAll") == false){
            for(var i in publicRFPs){
                publicRFPs[i].selected = false;
            }
            component.set("v.publicRequests",publicRFPs);
        }
    },
    
    handleRFPSelect : function(component, event, helper){
        var publicRFPs = component.get("v.publicRequests");
        if(component.get("v.selectAll") == true){
            for(var i in publicRFPs){
                if(!publicRFPs[i].selected){
                    component.set("v.selectAll", false);
                    break;
                }
            }
            component.set("v.publicRequests",publicRFPs);
        }
        else{
            component.set("v.selectAll", true);
            for(var i in publicRFPs){
                if(!publicRFPs[i].selected){
                    component.set("v.selectAll", false);
                    break;
                }
            }
            component.set("v.publicRequests",publicRFPs);
        }
    },
    
    applyRFPsingle : function(component, event, helper){
        try{
            var publicRFPs = component.get("v.publicRequests");
            var selectedRequests = [];
            var reqIndex = event.currentTarget.dataset.index;
            if(reqIndex != undefined && reqIndex != null && reqIndex != '') selectedRequests.push(publicRFPs[reqIndex].request);
            if(selectedRequests.length > 0) helper.applyForRequest(component, event, selectedRequests);
            else console.log('applyRFPsingle selectedRequests empty');
        }catch(e){
            console.log('applyRFPsingle error ~>'+e);
        }
    },
    
    applyRFPs : function(component, event, helper){
        var publicRFPs = component.get("v.publicRequests");
        var selectedRequests = [];
        for (var i in publicRFPs){
            if(publicRFPs[i].selected)
                selectedRequests.push(publicRFPs[i].request);
        }
        if(selectedRequests.length > 0) helper.applyForRequest(component, event, selectedRequests);
        else console.log('applyRFPs selectedRequests empty');
    },
    
    closeRFPModal : function(component, event, helper){
        $A.util.removeClass(component.find("newRFP"), 'slds-fade-in-open');
        $A.util.removeClass(component.find("newRFPBackdrop"), 'slds-backdrop_open');
    },
    
    NavConsole : function(component, event, helper){
        console.log('NavConsole called');
        try{
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var supplierId = '';
            var requestId = '';
            var rsIndex = '';
            supplierId = event.currentTarget.dataset.recordId;
            console.log('currentSupplier',component.get("v.currentSupplier"));
            requestId = event.currentTarget.dataset.record;
            rsIndex = event.currentTarget.dataset.index;
            var request = component.get("v.requests");
            var RS = request[rsIndex].reqSupplier.ERP7__Is_Submitted__c;
            request = request[rsIndex].request;
            var allow = RS && (request.ERP7__Status__c == 'Closed');
            if(request.ERP7__Status__c == 'Open' || allow){
                console.log('creating RFPconsole cmp');
                $A.createComponent("c:RFPConsole",{
                    reqSupplierId : supplierId,
                    requestId : requestId,
                    RFPnav : 'supplierRFPs',
                    currentSupplier: component.get("v.currentSupplier"),
                    //frominitial: true
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }
                });
                /*var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:RFPConsole",
                componentAttributes: {
                    reqSupplierId : supplierId,
                    requestId : requestId,
                    RFPnav : 'supplierRFPs',
                }
            });
            evt.fire();*/
        }
            else if(request.ERP7__Status__c == 'Review'){
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.exceptionError", "The selected RFP is in "+request.ERP7__Status__c);
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.exceptionError","");
                    }), 5000
                );
            }
                else{
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    component.set("v.exceptionError", "The selected RFP has been "+request.ERP7__Status__c);
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.exceptionError","");
                        }), 5000
                    );
                }
        }catch(e){
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
            console.log('NavConsole err~>'+e);
        }
    },
    
    NavRecord : function(component, event, helper){
        var RecordId = event.currentTarget.dataset.recordId;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": RecordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }, 
    
    getRecord : function(component, event, helper){
        component.set("v.revert",false);
        var RecId=event.currentTarget.dataset.recordId;
          var PageAPI=event.currentTarget.dataset.record;
        $A.createComponent("c:SupplierFieldSet",{
            RecordId : RecId,AccId :component.get("v.currentSupplier"), ObName :"RFPs"
        },function(newCmp, status, errorMessage){
            if (component.isValid() && status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
            else{
               
            }
        }); 
    },
   
    //Pagination.
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
            helper.setRFPDetails(component, event, component.get("v.searchReqProd"));
        } 
        else component.set("v.PageNum",((curOffset+show)/show));
    },
    
    setShow : function(component,event,helper){
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.PageNum", 1);
        helper.setRFPDetails(component, event, component.get("v.searchReqProd"));
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.setRFPDetails(component, event, component.get("v.searchReqProd"));
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
            helper.setRFPDetails(component, event, component.get("v.searchReqProd"));
        }
    },
    
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.setRFPDetails(component, event, component.get("v.searchReqProd"));
        }
    },
    
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.setRFPDetails(component, event, component.get("v.searchReqProd"));
        }
    },
    //Pagination End.
    
    closeSuccess : function(component, event, helper){
        component.set("v.serverSuccess","");
    },
    
    closeError : function(component, event, helper){
        component.set("v.exceptionError","");
    },
    
    home :function(component, event, helper){
        component.set("v.revert",false);
        $A.createComponent("c:SupplierPortalCommHome",{
          AccId  :component.get("v.currentSupplier")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
})