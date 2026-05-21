({
	doInit : function(component, event, helper) {
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        if(component.get("v.requestStatus") == "Open"){
            if(component.get("v.requestId")!=null && component.get("v.requestId")!=undefined && component.get("v.requestId")!=''){
                helper.setRfpDetails(component, event);
            }
            else{
                component.set("v.exceptionError", "Request unavailable.");
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.exceptionError","");
                    }), 5000
                );
            }
        }
        else{
            if(component.get("v.requestStatus") == "Review") component.set("v.exceptionError", "Selected RFP is in "+component.get("v.requestStatus")+".");
            else component.set("v.exceptionError", "Selected RFP has been "+component.get("v.requestStatus")+".");
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.exceptionError","");
                    window.history.back();
                }), 5000
            );
        }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    gobacktoPage:function(component,event,helper){
        console.log('fromRFPPage : ',component.get('v.fromRFPPage'));
        console.log('fromDetailPage : ',component.get('v.fromDetailPage'));
        if(component.get('v.fromDetailPage')){
            window.history.back();
        }
        else if(component.get('v.fromRFPPage')){
            window.location.reload(); 
        }
            else{
                window.history.back();
            }
    },
    
    changeView : function(component, event, helper){
		var selectView = event.currentTarget.dataset.record;
        if(selectView == "list"){
            $A.util.addClass(component.find('listIcon'), "acitve-list");
            $A.util.removeClass(component.find('gridIcon'), "acitve-list");
        }
        else if(selectView == "grid"){
            $A.util.removeClass(component.find('listIcon'), "acitve-list");
            $A.util.addClass(component.find('gridIcon'), "acitve-list");
        }
        component.set("v.view", selectView);
    },
    
    navPO: function(component, event, helper) {
		var supIndex = event.currentTarget.dataset.index;
        
        var supplier = component.get("v.reqSuppliers");
        supplier = supplier[supIndex].supplier;
        //var rwrap= component.get("v.RFPWrap");
        //console.log('cominghere?', rwrap[0].showReceive);
        console.log('RFPsupplier~>'+JSON.stringify(supplier));
        console.log('RFPrequest~>'+JSON.stringify(component.get("v.request")));
        $A.createComponent("c:CreatePurchaseOrder",{
            RFPsupplier : supplier,
            RFPrequest : component.get("v.request"),
            showReceive : component.get("v.showReceive"),
            QuoteAccess : false,
            versionAccess : false,
            showPOType : false
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    evaluateReq : function(component, event, helper){
        var supIndex = event.currentTarget.dataset.index;
		var suppId = event.currentTarget.dataset.recordId;
        
        $A.createComponent("c:RFPEvaluate",{
            reqSupplierId : suppId,
            requestId : component.get("v.request.Id"),
            isCompare : true,
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    navSupplier : function(component, event, helper){
		var suppId = event.currentTarget.dataset.recordId;
        var suppUrl='https://'+window.location.hostname.split('--')[0]+'/lightning/r/Account/'+suppId+'/view';
        window.open(suppUrl);
    },
    
    closeSuccess : function(component, event, helper){
        component.set("v.serverSuccess","");
    },
    
    closeError : function(component, event, helper){
        component.set("v.exceptionError","");
    }
})