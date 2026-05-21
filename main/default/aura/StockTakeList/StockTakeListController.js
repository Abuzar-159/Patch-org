({
    getStockList : function (component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var show = component.get("v.show");
        var action = component.get("c.getAll");
        if(component.get('v.searchText') != null || component.get('v.searchText') != ''){ component.set('v.searchText','');}
        action.setParams({searchText:"", Channel:"", Site:"", Offset:0, Show:show});
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.PreventChange", true);
                component.set("v.Container", response.getReturnValue());
                component.set("v.currentEmployee", response.getReturnValue().Employee);
                //component.find("Site").set("v.options", response.getReturnValue().channelSites);
                component.set("v.SiteOptions", response.getReturnValue().channelSites);
                component.set("v.selectedSite", response.getReturnValue().selectedSite);
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                component.set("v.PreventChange", false);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
            }else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
                var errors = response.getError();
                console.log("server error : ", errors);
                component.set("v.exceptionError", errors[0].message);
                setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
            }
        });
        $A.enqueueAction(action);
        
        var stockTakeStatus = component.get("c.getStockTakeStatus");
        stockTakeStatus.setCallback(this,function(response){
            //component.find("stStatus").set("v.options", response.getReturnValue());   
            component.set("v.stStatusOptions",response.getReturnValue());
        });
        $A.enqueueAction(stockTakeStatus);
    },
    
    LoadNow : function(component, event, helper) {
        window.scrollTo(0, 0);
        var searchtext = component.get("v.searchText");
        var channel = component.get("v.currentEmployee.ERP7__Channel__c");
        var site = component.get("v.selectedSite");
        var show = component.get("v.show");
        var offset = component.get("v.Container.Offset");
        if(channel == undefined || channel == null) { channel = ""; site = ""; }
        if(searchtext == undefined || searchtext == null) searchtext = "";
        
        if(!component.get("v.PreventChange") && channel != ""){
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
            component.set("v.showSpinner",true);
            var action = component.get("c.getAll");
            action.setParams({searchText:searchtext, Channel:channel, Site:site, Offset:offset, Show:show});
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS"){
                    component.set("v.PreventChange", true);
                    component.set("v.Container", response.getReturnValue());
                    component.set("v.currentEmployee", response.getReturnValue().Employee);
                    component.set("v.SiteOptions", response.getReturnValue().channelSites);
                    //component.find("Site").set("v.options", response.getReturnValue().channelSites);
                    component.set("v.selectedSite", response.getReturnValue().selectedSite);
                    component.set("v.exceptionError", response.getReturnValue().exceptionError);
                    component.set("v.PreventChange", false);
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                    component.set("v.showSpinner",false);
                }else{
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                    component.set("v.showSpinner",false);
                    var errors = response.getError();
                    console.log("server error : ", errors);
                    component.set("v.exceptionError", errors[0].message);
                    setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
                }
            });
            $A.enqueueAction(action);
        }
    }, 
    
    LoadChannelChange : function(component, event, helper) {
        if(!component.get("v.PreventChange")){
            window.scrollTo(0, 0);
            component.set("v.Container.Offset",0);
            var searchtext = component.get("v.searchText");
            var channel = component.get("v.currentEmployee.ERP7__Channel__c");
            var site = component.get("v.selectedSite");
            var show = component.get("v.show");
            var offset = component.get("v.Container.Offset");
            site = "";
            if(channel == undefined || channel == null) { channel = ""; site = ""; }
            if(searchtext == undefined || searchtext == null) searchtext = "";
            
            if(!component.get("v.PreventChange") && channel != ""){
                //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",true);
                var action = component.get("c.getAll");
                action.setParams({searchText:searchtext, Channel:channel, Site:site, Offset:offset, Show:show});
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        component.set("v.PreventChange", true);
                        component.set("v.Container", response.getReturnValue());
                        component.set("v.currentEmployee", response.getReturnValue().Employee);
                        component.set("v.SiteOptions", response.getReturnValue().channelSites);
                        //component.find("Site").set("v.options", response.getReturnValue().channelSites);
                        component.set("v.selectedSite", response.getReturnValue().selectedSite);
                        component.set("v.exceptionError", response.getReturnValue().exceptionError);
                        component.set("v.PreventChange", false);
                        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                        component.set("v.showSpinner",false);
                    }else{
                        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                        component.set("v.showSpinner",false);
                        var errors = response.getError();
                        console.log("server error : ", errors);
                        component.set("v.exceptionError", errors[0].message);
                        setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    SetShow : function(component, event, helper) {
        component.set("v.Container.Offset",0);
        component.LoadNow();
    },
    
    OfsetChange : function(component, event, helper) {
        var container = component.get("v.Container");
        var PNS = container.PNS;
        var PageNum = container.PageNum;
        var Offset = parseInt(container.Offset);
        var show = parseInt(component.get("v.show"));
        
        if(PageNum > 0 && PageNum <= PNS.length){
            if(((Offset+show)/show) != PageNum){
                Offset = (show*PageNum)-show;
                component.set("v.Container.Offset",Offset);
            }
            component.LoadNow();
        } else component.set("v.Container.PageNum",(Offset+show)/show);
    },
    
    Next : function(component, event, helper) {
        var container = component.get("v.Container");
        var show = parseInt(component.get("v.show"));
        var Offset = parseInt(container.Offset);
        var endCount = parseInt(container.endCount);
        var recSize = parseInt(container.recSize);
        
        if(endCount != recSize){
            var newOffset = Offset+show
            component.set("v.Container.Offset",Offset+show);
            component.LoadNow();
        }
    },
    
    NextLast : function(component, event, helper) {
        var container = component.get("v.Container");
        var PNS = container.PNS;
        var show = parseInt(component.get("v.show"));
        var endCount = parseInt(container.endCount);
        var recSize = parseInt(container.recSize);
        if(endCount != recSize){
            component.set("v.Container.Offset",((PNS.length-1)*show));
            component.LoadNow();
        }
    },
    
    Previous : function(component, event, helper) {
        var container = component.get("v.Container");
        var Offset = parseInt(container.Offset);
        var show = parseInt(component.get("v.show"));
        var startCount = parseInt(container.startCount);
        if(startCount > 1){
            component.set("v.Container.Offset",Offset-show);
            component.LoadNow();
        }
    },
    
    PreviousFirst : function(component, event, helper) {
        var container = component.get("v.Container");
        var startCount = parseInt(container.startCount);
        if(startCount > 1){
            component.set("v.Container.Offset",0);
            component.LoadNow();
        }
    },
    
    Load : function(component, event, helper) {
        if(!component.get("v.PreventChange")){
            component.set("v.Container.Offset",0);
            component.LoadNow();    
        }
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    callToStockTakeNew : function (component, event) {
        var currentChannel = component.get("v.currentEmployee.ERP7__Channel__c");
        var currentSite = component.get("v.selectedSite");
        //alert('currentChannel : ' +currentChannel);
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:StockTake",
            componentAttributes: {
                "selectedChannel":currentChannel,
                "currentEmpChannel":currentChannel,
                "selectedSite":currentSite,
                "isNew":true,
            }
        });
        evt.fire();
    },
    
    callToStockTake : function (component, event) {
        var selectedId = event.currentTarget.getAttribute('id');
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:StockTake",
            componentAttributes: {
                "stockTakeId":selectedId,
                "selectedSite":component.get("v.selectedSite"),
                "isNew":false,
            }
        });
        evt.fire();
    },
    
    removeItem : function(component, event) {
        component.set("v.ItemTOdelete",event.getSource().get("v.name"));
        component.set("v.showPOPUp",true);
    },
    
    DeleteRecordById : function(component, event, helper){
        var action = component.get("c.deleteStockTake");
        action.setParams({"StTaId":component.get("v.ItemTOdelete")});
        action.setCallback(this,function(response){
            if(response.getState() ==='SUCCESS'){
                if(response.getReturnValue() != ''){
                    component.set("v.exceptionError",response.getReturnValue());
                } else{
                    component.set("v.ItemTOdelete",'');
                    component.set("v.showPOPUp", false);
                    component.LoadNow();
                }
            }else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//already commented
                var errors = response.getError();
                console.log("server error : ", errors);
                component.set("v.exceptionError", errors[0].message);
                setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
            }
        });
        $A.enqueueAction(action);
    },
    
    CancelDelete :function(component, event, helper) {
        component.set("v.ItemTOdelete",'');
        component.set("v.showPOPUp",false);
    },
    
    editRecord : function(component, event, helper) {
        component.set("v.ItemToEdit",event.getSource().get("v.name"));
        var selectedId = component.get("v.ItemToEdit");
        
        var action = component.get("c.getStockTakeRec");
        action.setParams({StTaId:selectedId});
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() != null){
                    component.set("v.showEditPopup",true);
                    console.log('response.getReturnValue() : ',response.getReturnValue());
                    component.set("v.stockTake",response.getReturnValue());
                }
            }else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//already commented
                var errors = response.getError();
                console.log("server error : ", errors);
                component.set("v.exceptionError", errors[0].message);
                setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    CancelEdit :function(component, event, helper) {
        component.set("v.ItemToEdit",'');
        component.set("v.showEditPopup",false);
    },
    
    closeError : function (component, event) {
        component.set("v.exceptionError",'');
    },
    
    closepopup : function (component, event) {
        component.popinit(component, event);
    },
    
    saveEditStockTake :function(component, event, helper) {
        //alert('save called');
        var action = component.get("c.updateStockTake");
        action.setParams({"StockTakeRec":JSON.stringify(component.get("v.stockTake"))});
        action.setCallback(this,function(response){
            if(response.getState() ==='SUCCESS'){
                if(response.getReturnValue() != ''){
                    component.set("v.exceptionError",response.getReturnValue());
                } else{
                    component.set("v.ItemToEdit",'');
                    component.set("v.showEditPopup",false);
                    component.LoadNow();
                }
            }else{
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//already commented
                var errors = response.getError();
                console.log("server error : ", errors);
                component.set("v.exceptionError", errors[0].message);
                setTimeout(function(){component.set("v.exceptionError", "");}, 5000);
            }
        });
        $A.enqueueAction(action);
    },
    
    getSortedRecords : function(component,event,helper){
        component.set("v.OrderBy",event.currentTarget.id); 
        
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');   
        helper.getStocktakeRecords(component,event); 
    },
    
    focusTOscan : function (component, event,helper) {
        component.set("v.scanValue",'');
        helper.focusTOscan(component, event);
        
    },
    
    verifyScanCode : function (component, event, helper) {
        var scan_Code = component.get("v.scanValue");
        console.log('scan_Code : '+scan_Code);
        if(!$A.util.isEmpty(scan_Code) && !$A.util.isUndefinedOrNull(scan_Code)){
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
            component.set("v.showSpinner",true);
            if(scan_Code == 'NEW'){
                $A.enqueueAction(component.get('c.callToStockTakeNew'));
            }
            /*else if(scan_Code == 'MANAGE'){
              $A.enqueueAction(component.get('c.callToStockTake'));  
            }*/
            else if(scan_Code != 'NEW' && scan_Code.startsWith('STK-')){
                component.set('v.searchText',scan_Code);   
            }
                else{
                    component.set("v.exceptionError",$A.get('$Label.c.PH_OB_Invalid_barcode_scanned'));//translation added
                }
            component.set("v.scanValue",'');
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");
            component.set("v.showSpinner",false);
        }
     },
})