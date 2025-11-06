({
    getAllDetails : function(component, event, helper) { 
        var logIds = component.get("v.logisticIds");
        var logisticIds = logIds.split(",");
        var LIds = JSON.stringify(logisticIds);
        
        var action = component.get("c.createShipments");    
        action.setParams({LogisticIds:LIds}); //, Customer:''
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                component.set("v.PreventChange", true);
                //component.set("v.Container", response.getReturnValue());
                component.set("v.Scanflow", response.getReturnValue().Allowscanning);
                component.set("v.ReplaceShipSlipOrgURL", response.getReturnValue().ReplaceShipSlipOrgURL);
                component.set("v.ShowLangOptionForShipSlip", response.getReturnValue().ShowLangOptionForShipSlip);
                component.set("v.SiteName", response.getReturnValue().SiteName);
                component.set("v.enableUPSRestAPI", response.getReturnValue().enableUPSRestAPI);
                component.set("v.enableFedexRestAPI", response.getReturnValue().enableFedexRestAPI);
                component.set("v.ChannelName", response.getReturnValue().ChannelName);
                component.set("v.ChannelId", response.getReturnValue().ChannelId);
                component.set("v.LogisticsRecords", response.getReturnValue().LogisticRecs);
                console.log('logrecs~>'+typeof response.getReturnValue().LogisticRecs);
                component.set("v.currentEmployee", response.getReturnValue().Employee);
                component.set("v.selectedSite", response.getReturnValue().selectedSite);
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                
                component.set("v.shipmentWrapperList", response.getReturnValue().shipmentWrapperList);
                
                component.set("v.PreventChange", false);
                if(component.get("v.shipId") != '' && component.get("v.shipId") != null && component.get("v.shipId") != undefined) {
                    component.createShipment();
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
                
            }
        });
        $A.enqueueAction(action);
        
    },
    
    AssignShipment : function(component, event, helper) {
        var shipId = event.getSource().get("v.title");
        component.set("v.shipId", shipId);
        //var a = component.get("c.createShipment");
        //$A.enqueueAction(a);
        component.createShipment();
    },
    
    createShipment : function(component, event, helper) {
        var shipId = component.get("v.shipId");
        var shipmentType = '';
        var obj = component.get("v.shipmentWrapperList");
        for(var x in obj) if(obj[x].shipM.Id == shipId) shipmentType = obj[x].shipmentType;
        var retValue = 'SOL'; 
        if(shipId != undefined && shipId != '' && shipId != null) { 
            if(shipmentType == 'UPS'){
                component.set("v.exceptionError", '');
                if(component.get("v.enableUPSRestAPI")){
                    component.set("v.showShipComponent",true);
                    component.set("v.showUPSRestAPIcomp",true);
                    component.set("v.selectedShipmentId",shipId);
                    
                    console.log('test');
                }
                else{
                    $A.createComponent("c:UPS", {
                        "shipmentId":shipId,
                    }, function(newcomponent, status, errorMessage){
                        if (status === "SUCCESS") {
                            
                            component.set("v.showShipComponent",true);
                            //component.set("v.showShipComponent",true);
                            var body = component.find("mybody");                            
                            body.set("v.body", newcomponent);  
                        }
                    });
                }
            } else if(shipmentType == 'USPS'){
                /*  
                   $A.createComponent("c:USPS", {
                        "packageId":selectedPackIds,
                    }, function(newcomponent, status, errorMessage){
                        if (status === "SUCCESS") {
                            component.set("v.showShipComponent",true);
                            var body = component.find("mybody");                            
                            body.set("v.body", newcomponent);  
                        }
                        else{
                            console.log("Error : ", errorMessage);
                        }
                    });*/ 
                
            } else if(shipmentType == 'FedEx'){
                 component.set("v.exceptionError", '');
                if(component.get("v.enableFedexRestAPI")){
                    component.set("v.showShipComponent",true);
                    component.set("v.showFedexRestAPIcomp",true);
                    component.set("v.selectedShipmentId",shipId);
                    console.log('test');
                }
                else{
                   
                    $A.createComponent("c:FedEx", {
                        "shipmentId":shipId,
                    }, function(newcomponent, status, errorMessage){
                        if (status === "SUCCESS") {
                            component.set("v.showShipComponent",true);
                            var body = component.find("mybody");                            
                            body.set("v.body", newcomponent);  
                        }
                    });
                }
            } else if(shipmentType == 'DHL'){
                /* 
                    $A.createComponent("c:DHL", {
                        "packageId":selectedPackIds,
                    }, function(newcomponent, status, errorMessage){
                        //alert('Status in fedex : ' +status);
                        if (status === "SUCCESS") {
                            component.set("v.showShipComponent",true);
                            var body = component.find("mybody");                            
                            body.set("v.body", newcomponent);  
                        }
                        else{
                            console.log("Error : ", errorMessage);
                        }
                    });*/
                
                
            } else if (shipmentType == 'Canada Post') {
                console.log('test1');
                // if (shipId.length == 1){
                console.log('test2');
                component.set("v.showShipComponent", true);
                component.set("v.showCPRestAPIcomp", true);
                component.set("v.selectedShipmentId",shipId);
                /* }else{
                      component.set("v.exceptionError", 'For Canada Post you can select only 1 package');
                  }*/
            }
                else { 
                component.set("v.exceptionError", '');
                $A.createComponent("c:InternalShipment",{
                    "shipmentID":shipId,
                    "showHeader":component.get("v.showHeader")
                },function(newcomponent, status, errorMessage){
                    if (status === "SUCCESS") {
                        component.set("v.showShipComponent",true);
                        var body = component.find("mybody");                            
                        body.set("v.body", newcomponent); 
                    }
                });
                
            }
        } 
    },
    
    checkAll : function(component, event, helper) {
        var obj = component.get("v.shipmentWrapperList");
        var val = component.get("v.checkAll");
        for(var x in obj){
            obj[x].shipSelected = val;
        }
        component.set("v.shipmentWrapperList",obj);
    },
    
    createShippingSlips : function(component, event, helper) {
        component.set("v.exceptionError","");
        var count = event.getSource().get("v.title");
        var shIds = '';
        var shipmentWrapperList = component.get("v.shipmentWrapperList");
        for(var x in shipmentWrapperList) { 
            if(shipmentWrapperList[x].shipSelected == true || x == count) {
                if(shIds == '') shIds = shipmentWrapperList[x].shipM.Id;
                else shIds += ','+shipmentWrapperList[x].shipM.Id;
            }
        }
        if(shIds == '') component.set("v.exceptionError", $A.get('$Label.c.Please_select_the_shipment'));
        else{
            console.log('shIds~>'+shIds);
            component.set("v.shIds",shIds);
            if(component.get("v.ShowLangOptionForShipSlip")){
                component.set("v.ShowLangOptionForShipSlipModal",true);
            }else{
                var shipSlip = $A.get("$Label.c.Ship_Slip");
                //Changes made by Arshad 14/06/2023
                if(component.get("v.ReplaceShipSlipOrgURL")){
                    var customOrgUrl =  $A.get("$Label.c.orgURL");
                    console.log('customOrgUrl : ',customOrgUrl);
                    var RecUrl = customOrgUrl+"/apex/"+shipSlip+"?shIds=" + shIds;
                    window.open(RecUrl,'_blank'); 
                }else{
                    var RecUrl = "/apex/"+shipSlip+"?shIds=" + shIds;
                    window.open(RecUrl,'_blank'); 
                }
            }
        }
    },
    
    createShippingSlipsforAll : function(component, event, helper) {
        component.set("v.exceptionError","");
        
        var shIds = '';
        var shipmentWrapperList = component.get("v.shipmentWrapperList");
        for(var x in shipmentWrapperList) { 
            if(shipmentWrapperList[x].shipSelected == true) {
                if(shIds == '') shIds = shipmentWrapperList[x].shipM.Id;
                else shIds += ','+shipmentWrapperList[x].shipM.Id;
            }
        }
        if(shIds == '') component.set("v.exceptionError", $A.get('$Label.c.Please_select_the_shipment'));
        else{
            console.log('shIds~>'+shIds);
            component.set("v.shIds",shIds);
            if(component.get("v.ShowLangOptionForShipSlip")){
                component.set("v.ShowLangOptionForShipSlipModal",true);
            }else{
                var shipSlip = $A.get("$Label.c.Ship_Slip");
                //Changes made by Arshad 14/06/2023
                if(component.get("v.ReplaceShipSlipOrgURL")){
                    var customOrgUrl =  $A.get("$Label.c.orgURL");
                    console.log('customOrgUrl : ',customOrgUrl);
                    var RecUrl = customOrgUrl+"/apex/"+shipSlip+"?shIds=" + shIds;
                    window.open(RecUrl,'_blank'); 
                }else{
                    var RecUrl = "/apex/"+shipSlip+"?shIds=" + shIds;
                    window.open(RecUrl,'_blank'); 
                }
            }
        }
    },
    
    //Added by Arshad for multi lang doc options 19/06/2023
    ShipSlipNext : function(component, event, helper) {
        var shIds = component.get("v.shIds");
        var shipSlip = $A.get("$Label.c.Ship_Slip");        
        var SelectedLang = component.get("v.SelectedLang");
        if(SelectedLang == "English"){
            shipSlip = $A.get("$Label.c.Ship_Slip");
        }else if(SelectedLang == "French"){
            shipSlip = $A.get("$Label.c.Ship_Slip_FR");
        }
        if(component.get("v.ReplaceShipSlipOrgURL")){
            var customOrgUrl =  $A.get("$Label.c.orgURL");
            console.log('customOrgUrl : ',customOrgUrl);
            var RecUrl = customOrgUrl+"/apex/"+shipSlip+"?shIds=" + shIds;
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank'); 
        }else{
            var RecUrl = "/apex/"+shipSlip+"?shIds=" + shIds;
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank'); 
        }
    },
    
    goBackShipSlip : function(component, event, helper) {
        component.set("v.ShowLangOptionForShipSlipModal",false);
    },
    
    setScriptLoaded : function(component, event, helper) {
        
    },
    
    Back2Outbound : function(component, event, helper) {
        $A.createComponent("c:OutboundLogistics",{
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
    },
    
    createPicks : function(component, event, helper) {
        var logIds = component.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Pick",{
            "logisticIds":logIds
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
    },
    
    createPacks : function(component, event, helper) {
        var logIds = component.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Pack",{
            "logisticIds":logIds
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
        
    },
    
    createShips : function(component, event, helper) {
        var logIds = component.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Ship",{
            "logisticIds":logIds
        },function(newcomponent, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
    },
    
    focusTOscan : function (component, event,helper) {
        component.set("v.scanValue",'');
        helper.focusTOscan(component, event);   
        
    },
    
    verifyScanCode : function (component, event, helper) {
        // var scanedfield = component.get("v.scanValue");
        // console.log('verifyScanCodes scanedfield : ',scanedfield);
        // var editedFieldId = event.getSource().getLocalId();
        // console.log('verifyScanCodes editedFieldId : ',editedFieldId);
        if(component.get("v.Scanflow")){
            var scan_Code = component.get("v.scanValue");
            var mybarcode = scan_Code;
            if(mybarcode != ''){
                component.set("v.exceptionError", '');
                if(mybarcode == 'ORDER') { component.Back2Outbound(); }
                else if(mybarcode == 'PICK') { component.createPicks(); }
                    else if(mybarcode == 'PACK') { component.createPacks(); }
                        else if(mybarcode == 'SHIP') { component.createShips(); }
                            else{  
                                component.set("v.exceptionError", $A.get('$Label.c.PH_OB_Invalid_barcode_scanned'));
                            }  
                component.set("v.scanValue",'');
            }
        }
    },
    
    closeError : function (component, event) {
        component.set("v.exceptionError",'');
    },
    
    deleteShipm : function (component, event, helper) {
        var r = confirm('Are you sure you want to delete?'); 
        if (r == true) {  
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var shipId = event.getSource().get("v.name");
            var logIds = component.get("v.logisticIds");
            var logisticIds = logIds.split(",");
            var LIds = JSON.stringify(logisticIds);
            
            var action = component.get("c.deleteShipments");
            action.setParams({ShipmentId:shipId, LogisticIds:LIds});
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log('success delepeShipments~>'+JSON.stringify(response.getReturnValue()));
                    console.log('logrecs~>'+JSON.stringify(response.getReturnValue().LogisticRecs));
                    //console.log('v.LogisticsRecords~>',component.get("v.LogisticsRecords"));
                    component.set("v.PreventChange", true);
                    console.log('here 1');
                    component.set("v.SiteName", response.getReturnValue().SiteName);
                    console.log('here 2');
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    component.set("v.shipmentWrapperList", response.getReturnValue().shipmentWrapperList);
                    component.set("v.exceptionError", response.getReturnValue().exceptionError);
                    console.log('exceptionError~>'+response.getReturnValue().exceptionError);
                    try{
                        console.log('del logrecs~>'+typeof response.getReturnValue().LogisticRecs);
                        component.set("v.LogisticsRecords", response.getReturnValue().LogisticRecs);
                        
                    }catch(e){
                        console.log('err~>'+JSON.stringify(e));
                    }
                }else{
                    console.log('error occured~>'+response.getReturnValue().exceptionError);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    StillToFulfill : function (component, event) {
        var logIds = component.get("v.logisticIds");
        //var RecUrl = "/apex/PickLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:StillToFulfillLightning",{
            "logisticIds":logIds
        },function(newcomponent, status, errorMessage){
            
            if (status === "SUCCESS") {
                // $A.util.removeClass(component.find('mainSpin'), "slds-hide");
                var body = component.find("body");
                body.set("v.body", newcomponent);
            }
        });
    },
})