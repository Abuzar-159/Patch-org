({
	getAllDetails : function(component, event, helper) { 
        var logIds = component.get("v.logisticIds");
        var logisticIds = logIds.split(",");
        var LIds = JSON.stringify(logisticIds);
        
        var action = component.get("c.createPacksInit");
        action.setParams({LogisticIds:LIds, Customer:''});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                
                component.set("v.PreventChange", true);
                //component.set("v.Container", response.getReturnValue());
                component.set("v.SiteName", response.getReturnValue().SiteName);
                component.set("v.Scanflow", response.getReturnValue().Allowscanning);
                component.set("v.ChannelName", response.getReturnValue().ChannelName);
                component.set("v.ChannelId", response.getReturnValue().ChannelId);
                component.set("v.Logistics", response.getReturnValue().LogisticRecs);
                component.set("v.currentEmployee", response.getReturnValue().Employee);
                component.set("v.selectedSite", response.getReturnValue().selectedSite);
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                 component.set("v.enableUPSRestAPI", response.getReturnValue().enableUPSRestAPI);
                component.set("v.enableFedexRestAPI", response.getReturnValue().enableFedexRestAPI);
                component.set("v.lineItemWrapperList", response.getReturnValue().lineItemWrapperList);
                component.set("v.packageWrapperList", response.getReturnValue().packageWrapperList);
                 component.set("v.Package2Create", response.getReturnValue().Package2Create);
                console.log('response.getReturnValue().Package2Create : ',response.getReturnValue().Package2Create);
                component.set('v.Shiptype',response.getReturnValue().Package2Create.ERP7__Shipment_Type__c);
                component.set("v.errorMsg2", response.getReturnValue().errorMsg2);
                component.set("v.Customers", response.getReturnValue().Customers);
                component.set("v.SSTypeAccess",response.getReturnValue().showSSType);
                component.set("v.disablePackName",response.getReturnValue().disablePackName);
                component.set("v.disablePackDeclaredValue",response.getReturnValue().disablePackDeclaredValue);
                component.set("v.Customer", response.getReturnValue().Customer);
                component.set("v.CustomerPresent", response.getReturnValue().CustomerPresent);
                component.set("v.createPack", response.getReturnValue().createPack);
                component.set("v.isAwaiting", response.getReturnValue().isAwaiting);
                component.set("v.pkgTypeValue", response.getReturnValue().pkgTypeValue);
                component.set("v.WeightUnit", response.getReturnValue().WeightUnit);
                component.set("v.Dimension", response.getReturnValue().DimensionUnit);
                component.set("v.PackageType", response.getReturnValue().PackageType);
                component.set("v.ShipmentType", response.getReturnValue().ShipmentType);
                component.set("v.declareaccess",response.getReturnValue().enableDecalre);
                component.set("v.allowZerodeclaredValue",response.getReturnValue().allowZerodeclaredValue);
                component.set("v.disableShipmentType",response.getReturnValue().disableShipType);
                component.set("v.ShowLangOptionForPackList",response.getReturnValue().ShowLangOptionForPackList);
                component.set("v.ReplacePackListOrgURL",response.getReturnValue().ReplacePackListOrgURL);
                
                component.set("v.PreventChange", false);
                helper.getDependentPicklists(component, event, helper);

                
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getAllCustomerDetails : function(component, event, helper) { 
        var logIds = component.get("v.logisticIds");
        var logisticIds = logIds.split(",");
        var LIds = JSON.stringify(logisticIds);
        var customer = component.get("v.Customer");
        //window.scrollTo(0,0);
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        
        var action = component.get("c.createPacksInit");
        action.setParams({LogisticIds:LIds, Customer:customer});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                
                component.set("v.PreventChange", true);
                //component.set("v.Container", response.getReturnValue());
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                component.set("v.packageWrapperList", response.getReturnValue().packageWrapperList);
                component.set("v.Package2Create", response.getReturnValue().Package2Create);
                component.set("v.errorMsg2", response.getReturnValue().errorMsg2);
                component.set("v.PreventChange", false);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    checkAll : function(component, event, helper) {
        var obj = component.get("v.lineItemWrapperList");
        var val = component.get("v.checkAll");
        let err = false;
        for(var x in obj){
            if((obj[x].NoofLineItems > 0) && obj[x].pack.ERP7__Status__c != 'Shipped' && obj[x].pack.ERP7__Status__c != 'Picked Up' && obj[x].pack.ERP7__Status__c != 'Delivered' && obj[x].pack.ERP7__Logistic__r.ERP7__Ready_To_Ship__c){
                obj[x].sel = val;
                //alert(x);
            }
            else if(!obj[x].pack.ERP7__Logistic__r.ERP7__Ready_To_Ship__c){
                component.set('v.exceptionError',$A.get('$Label.c.Please_enable_ready_to_ship_on_the_logistic'));
                err = true;
                break;
            }
            
        }
        component.set("v.lineItemWrapperList",obj);
        if(!err) component.set('v.showShipAllbtton',val);
    },
    
    checkAll2 : function(component, event, helper) {
        var obj = component.get("v.packageWrapperList");
        var val = component.get("v.checkAll2");
        for(var x in obj){
            obj[x].pkgSelected = val;
        }
        component.set("v.packageWrapperList",obj);
    },
    
    showship : function(component, event, helper) {
        var pkIds= [];
         var lineItemWrapperList = component.get("v.lineItemWrapperList");
        for(var x in lineItemWrapperList) { 
            if(lineItemWrapperList[x].sel == true) {//lineItemWrapperList[x].pack.ERP7__Shipment__c == undefined && 
               pkIds.push(lineItemWrapperList[x].pack.Id);
              //  else { pkIds += ','+lineItemWrapperList[x].pack.Id; } 
            }
        }
        console.log('pkIds showship: ',pkIds);
        if(pkIds.length > 1){
            component.set('v.showShipAllbtton',true);
             console.log('showShipAllbtton: ',component.get('v.showShipAllbtton'));
        }
    },
    
    createPackingLabels : function(component, event, helper) {
        component.set("v.exceptionError","");
        var count = event.getSource().get("v.class");
        var pkIds = '';
        var lineItemWrapperList = component.get("v.lineItemWrapperList");
        for(var x in lineItemWrapperList) { 
            if((lineItemWrapperList[x].sel == true || x == count)) {//lineItemWrapperList[x].pack.ERP7__Shipment__c == undefined && 
                if(pkIds == '') pkIds = lineItemWrapperList[x].pack.Id;
                else pkIds += ','+lineItemWrapperList[x].pack.Id;
            }
        }
        //alert(pkIds);
        if(pkIds == '') component.set("v.exceptionError", $A.get('$Label.c.Please_select_the_package'));
        else{
             var PackLabel = $A.get("$Label.c.Pack_Label");
            var RecUrl = "/apex/"+PackLabel+"?pkIds=" + pkIds;
        	window.open(RecUrl,'_blank');
        }
    },
    
    createSinglePackingLabel : function(component, event, helper) {
        component.set("v.exceptionError","");
        var indx = event.currentTarget.getAttribute('data-index');
        if(indx != undefined && indx != null){
            var pkIds = '';
            var lineItemWrapperList = component.get("v.lineItemWrapperList");
            for(var x in lineItemWrapperList) { 
                if(x == indx) {
                    pkIds = lineItemWrapperList[x].pack.Id;
                    break;
                }
            }
            if(pkIds != ''){
                var PackLabel = $A.get("$Label.c.Pack_Label");
                var RecUrl = "/apex/"+PackLabel+"?pkIds=" + pkIds;
                window.open(RecUrl,'_blank');
            }
        }
    },
    
    createPackingSlips : function(component, event, helper) {
        component.set("v.exceptionError","");
        var count = event.getSource().get("v.class");
        var pkIds = '';
        var lineItemWrapperList = component.get("v.lineItemWrapperList");
        for(var x in lineItemWrapperList) { 
            if((lineItemWrapperList[x].sel == true || x == count)) {//lineItemWrapperList[x].pack.ERP7__Shipment__c == undefined && 
                if(pkIds == '') pkIds = lineItemWrapperList[x].pack.Id;
                else pkIds += ','+lineItemWrapperList[x].pack.Id;
            }
        }
        if(pkIds == '') component.set("v.exceptionError", $A.get('$Label.c.Please_select_the_package'));
        else{
            console.log('pkIds~>'+pkIds);
            component.set("v.pkIds",pkIds);
            if(component.get("v.ShowLangOptionForPackList")){
                component.set("v.ShowLangOptionForPackListModal",true);
            }else{
                var PackSlip = $A.get("$Label.c.Pack_Slip");
                //Changes made by Arshad 14/06/2023
                if(component.get("v.ReplacePackListOrgURL")){
                    var customOrgUrl =  $A.get("$Label.c.orgURL");
                    console.log('customOrgUrl : ',customOrgUrl);
                    var RecUrl = customOrgUrl+"/apex/"+PackSlip+"?pkIds=" + pkIds;
                    console.log('RecUrl~>'+RecUrl);
                    window.open(RecUrl,'_blank'); 
                }else{
                    var RecUrl = "/apex/"+PackSlip+"?pkIds=" + pkIds;
                    console.log('RecUrl~>'+RecUrl);
                    window.open(RecUrl,'_blank'); 
                }
            }
        }
    },
    
    createSinglePackingSlip : function(component, event, helper) {
        component.set("v.exceptionError","");
        var indx = event.currentTarget.getAttribute('data-index');
        if(indx != undefined && indx != null){
            var pkIds = '';
            var lineItemWrapperList = component.get("v.lineItemWrapperList");
            for(var x in lineItemWrapperList) { 
                if(x == indx) {
                    pkIds = lineItemWrapperList[x].pack.Id;
                    break;
                }
            }
            if(pkIds != ''){
                console.log('pkIds~>'+pkIds);
                component.set("v.pkIds",pkIds);
                if(component.get("v.ShowLangOptionForPackList")){
                    component.set("v.ShowLangOptionForPackListModal",true);
                }else{
                    var PackSlip = $A.get("$Label.c.Pack_Slip");
                    //Changes made by Arshad 14/06/2023
                    if(component.get("v.ReplacePackListOrgURL")){
                        var customOrgUrl =  $A.get("$Label.c.orgURL");
                        console.log('customOrgUrl : ',customOrgUrl);
                        var RecUrl = customOrgUrl+"/apex/"+PackSlip+"?pkIds=" + pkIds;
                        console.log('RecUrl~>'+RecUrl);
                        window.open(RecUrl,'_blank'); 
                    }else{
                        var RecUrl = "/apex/"+PackSlip+"?pkIds=" + pkIds;
                        console.log('RecUrl~>'+RecUrl);
                        window.open(RecUrl,'_blank'); 
                    }
                }
            }
        }
    },
    
    //Added by Arshad for multi lang doc options 19/06/2023
    PackListNext : function(component, event, helper) {
        var pkIds = component.get("v.pkIds");
        var PackSlip = $A.get("$Label.c.Pack_Slip");
        var SelectedLang = component.get("v.SelectedLang");
        if(SelectedLang == "English"){
            PackSlip = $A.get("$Label.c.Pack_Slip");
        }else if(SelectedLang == "French"){
            PackSlip = $A.get("$Label.c.Pack_Slip_FR");
        }
        if(component.get("v.ReplacePackListOrgURL")){
            var customOrgUrl =  $A.get("$Label.c.orgURL");
            console.log('customOrgUrl : ',customOrgUrl);
            var RecUrl = customOrgUrl+"/apex/"+PackSlip+"?pkIds=" + pkIds;
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank'); 
        }else{
            var RecUrl = "/apex/"+PackSlip+"?pkIds=" + pkIds;
            console.log('RecUrl~>'+RecUrl);
            window.open(RecUrl,'_blank'); 
        }
    },
    
    goBackPackList : function(component, event, helper) {
        component.set("v.ShowLangOptionForPackListModal",false);
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
    
    createShipment : function(component, event, helper) {
        console.log('createShipment called ');
        component.set("v.exceptionError","");
       // var count = event.getSource().get("v.title");
        var lineItemWrapperList = component.get("v.lineItemWrapperList");
        var sType = '';
        var error = false;
        var selectedPackIds = []; 
        var shipmentType = '';
        component.set("v.exceptionError",'');
                
        for(var x in lineItemWrapperList) { 
            if(lineItemWrapperList[x].pack.ERP7__Shipment__c == undefined && lineItemWrapperList[x].pack.ERP7__Logistic__r.ERP7__Ready_To_Ship__c && (lineItemWrapperList[x].sel == true)) {
                if(sType == '') {
                    sType = lineItemWrapperList[x].pack.ERP7__Shipment_Type__c;
                }
                console.log('sType : ',sType);
                if(sType == lineItemWrapperList[x].pack.ERP7__Shipment_Type__c) { 
                    console.log('lineItemWrapperList[x].pack.ERP7__Shipment_Type__c : ',lineItemWrapperList[x].pack.ERP7__Shipment_Type__c);
                    selectedPackIds.push(lineItemWrapperList[x].pack.Id);
                    if(shipmentType == '') shipmentType = lineItemWrapperList[x].pack.ERP7__Shipment_Type__c;
                } else { 
                    component.set("v.exceptionError", $A.get('$Label.c.You_cannot_select_packages_with_different_shipment_type'));
                    error = true; 
                    break; 
                }
            }
        }
        console.log('selectedPackIds : ',selectedPackIds);
        console.log('error : ',error);
        if(!error) { 
            
            var retValue = 'SOL';  
            //alert('selectedPackIds : '+selectedPackIds.length);
            //alert('shipmentType : '+shipmentType);
            if(selectedPackIds.length > 0){
                if(shipmentType == 'UPS'){
                    console.log('enableUPSRestAPI : ',component.get("v.enableUPSRestAPI"));
                    if(component.get("v.enableUPSRestAPI")){
                       component.set("v.showShipComponent",true);
                         component.set("v.showUPSRestAPIcomp",true);
                        component.set("v.selectedPackIds",selectedPackIds);
                       console.log('selectedPackIds : ',JSON.stringify(component.get("v.selectedPackIds")));
                        console.log('test');
                    }
                    else{
                        $A.createComponent("c:UPS",{
                            "packageId":selectedPackIds,
                        }, function(newcomponent, status, errorMessage){
                            //alert('Status : ' +status);
                            if (status === "SUCCESS") {
                                component.set("v.showShipComponent",true);
                                var body = component.find("mybody");
                                body.set("v.body", newcomponent);
                            }
                        }); 
                    }
                	
                } 
                else if(shipmentType == 'USPS'){
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
                    }); 
                } 
                    else if(shipmentType == 'FedEx'){
                        console.log('component.get("v.enableFedexRestAPI") : ',component.get("v.enableFedexRestAPI"));
                        if(component.get("v.enableFedexRestAPI")){
                            component.set("v.showShipComponent",true);
                            component.set("v.showFedexRestAPIcomp",true);
                            component.set("v.selectedPackIds",selectedPackIds);
                            console.log('selectedPackIds : ',JSON.stringify(component.get("v.selectedPackIds")));
                            console.log('test');
                        }
                        else{
                            $A.createComponent("c:FedEx", {
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
                            });
                        }
                } else if(shipmentType == 'DHL'){
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
                    });
                    
                }    else if (shipmentType == 'Canada Post') {
                  if (selectedPackIds.length == 1){
                      component.set("v.showShipComponent", true);
                      component.set("v.showCPRestAPIcomp", true);
                      component.set("v.selectedPackIds", selectedPackIds);
                  }else{
                      component.set("v.exceptionError", 'For Canada Post you can select only 1 package');
                  }
              }/*else if(shipmentType == 'Canada Post'){
                    console.log('enableUPSRestAPI : ',component.get("v.enableUPSRestAPI"));
                    component.set("v.showShipComponent",true);
                    component.set("v.showUPSRestAPIcomp",true);
                    component.set("v.selectedPackIds",selectedPackIds);
                    console.log('selectedPackIds : ',JSON.stringify(component.get("v.selectedPackIds")));
                    console.log('test');   
                } */else { //if(shipmentType == 'Shipment')
                	$A.createComponent("c:InternalShipment",{
                        "packageIDS":selectedPackIds,
                        "showHeader":false
                    },function(newcomponent, status, errorMessage){
                        if (status === "SUCCESS") {
                            component.set("v.showShipComponent",true);
                            var body = component.find("mybody");                            
                            body.set("v.body", newcomponent);  
                        }
                    });
                }
            } 
            else component.set("v.exceptionError", $A.get('$Label.c.Please_select_the_package'));
        } 
    },
    
    createsingleShipment : function(component, event, helper) {
        component.set("v.exceptionError","");
        var indx = event.currentTarget.getAttribute('data-index');
        var lineItemWrapperList = component.get("v.lineItemWrapperList");
        var sType = '';
        var error = false;
        var selectedPackIds = []; 
        var shipmentType = '';
                
        if(indx != undefined && indx !=  null){
            for(var x in lineItemWrapperList) { 
                if(x == indx){
                    if(lineItemWrapperList[x].pack.ERP7__Shipment__c == undefined && lineItemWrapperList[x].pack.ERP7__Logistic__r.ERP7__Ready_To_Ship__c) {
                        if(lineItemWrapperList[x].pack.ERP7__Shipment_Type__c != undefined && lineItemWrapperList[x].pack.ERP7__Shipment_Type__c != null && lineItemWrapperList[x].pack.ERP7__Shipment_Type__c != '') {
                            sType = lineItemWrapperList[x].pack.ERP7__Shipment_Type__c;
                        }
                        if(sType != '') { 
                            selectedPackIds.push(lineItemWrapperList[x].pack.Id);
                            shipmentType = lineItemWrapperList[x].pack.ERP7__Shipment_Type__c;
                        } else { 
                            component.set("v.exceptionError", $A.get('$Label.c.Shipment_Type_not_defined_for_the_select_packages'));
                            error = true; 
                        }
                    }
                    break; 
                }
            }
        }
        
        if(!error) { 
            var retValue = 'SOL';  
             console.log('shipmentType : ',shipmentType);
            if(selectedPackIds.length > 0){
                if(shipmentType == 'UPS'){
                     console.log('enableUPSRestAPI : ',component.get("v.enableUPSRestAPI"));
                    if(component.get("v.enableUPSRestAPI")){
                        component.set("v.showShipComponent",true);
                        component.set("v.showUPSRestAPIcomp",true);
                        component.set("v.selectedPackIds",selectedPackIds);
                        console.log('test');
                    }
                    else{
                        $A.createComponent("c:UPS",{
                            "packageId":selectedPackIds,
                        }, function(newcomponent, status, errorMessage){
                            //alert('Status : ' +status);
                            if (status === "SUCCESS") {
                                component.set("v.showShipComponent",true);
                                var body = component.find("mybody");
                                body.set("v.body", newcomponent);
                            }
                        });
                    }
                } else if(shipmentType == 'USPS'){
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
                    }); 
                } else if(shipmentType == 'FedEx'){
                     console.log('component.get("v.enableFedexRestAPI") : ',component.get("v.enableFedexRestAPI"));
                        if(component.get("v.enableFedexRestAPI")){
                            component.set("v.showShipComponent",true);
                            component.set("v.showFedexRestAPIcomp",true);
                            component.set("v.selectedPackIds",selectedPackIds);
                            console.log('selectedPackIds : ',JSON.stringify(component.get("v.selectedPackIds")));
                            console.log('test');
                        }
                    else{
                        $A.createComponent("c:FedEx", {
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
                        });
                    }
                } else if(shipmentType == 'DHL'){
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
                    });
                    
                } else if (shipmentType == 'Canada Post') {
                    console.log("Inside CP");
                  if (selectedPackIds.length == 1){
                       console.log("Inside CP len");
                      component.set("v.showShipComponent", true);
                      component.set("v.showCPRestAPIcomp", true);
                      component.set("v.selectedPackIds", selectedPackIds);
                      console.log("showShipComponent: ",component.get("v.showShipComponent"));
                      console.log("showCPRestAPIcomp: ",component.get("v.showCPRestAPIcomp"));
                      console.log('selectedPackIds : ',JSON.stringify(component.get("v.selectedPackIds")));
                  }else{
                      console.log("Inside CP else");
                      component.set("v.exceptionError", 'For Canada Post you can select only 1 package');
                  }
              }
                    else { //if(shipmentType == 'Shipment')
                	$A.createComponent("c:InternalShipment",{
                        "packageIDS":selectedPackIds,
                        "showHeader":false
                    },function(newcomponent, status, errorMessage){
                        if (status === "SUCCESS") {
                            component.set("v.showShipComponent",true);
                            var body = component.find("mybody");                            
                            body.set("v.body", newcomponent);  
                        }
                    });
                }
            } 
            else component.set("v.exceptionError", $A.get('$Label.c.Please_select_the_package'));
        } 
    },
    
    editPack : function(component, event, helper) {
        //window.scrollTo(0,0);
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var packId = event.getSource().get("v.name");
        var action = component.get("c.editPackage");
        action.setParams({pack2updateId:packId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.PreventChange", true);
                component.set("v.fromedit", true);
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                component.set("v.createPack", response.getReturnValue().createPack);
                component.set("v.Package2Create", response.getReturnValue().Package2Create);
                component.set("v.packageWrapperList", response.getReturnValue().packageWrapperList);
                component.set("v.lineItemWrapperList", response.getReturnValue().lineItemWrapperList); 
                component.set("v.CustomerPresent", response.getReturnValue().CustomerPresent);
                component.set("v.isAwaiting", response.getReturnValue().isAwaiting);
                component.set("v.pkgTypeValue", response.getReturnValue().pkgTypeValue);
                component.set("v.PreventChange", false); 
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    deletePack : function(component, event, helper) {
        var r = confirm('Are you sure you want to delete?'); 
        if (r == true) {  
            //window.scrollTo(0,0);
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var packId = event.getSource().get("v.name");
            var logIds = component.get("v.logisticIds");
            var logisticIds = logIds.split(",");
            var LIds = JSON.stringify(logisticIds);
            
            var action = component.get("c.deletePackage");
            action.setParams({pack2updateId:packId, LogisticIds:LIds});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    //alert(response.getReturnValue().exceptionError);
                    component.set("v.PreventChange", true);
                    //component.set("v.Container", response.getReturnValue());
                    component.set("v.SiteName", response.getReturnValue().SiteName);
                    component.set("v.Logistics", response.getReturnValue().LogisticRecs);
                    component.set("v.currentEmployee", response.getReturnValue().Employee);
                    component.set("v.selectedSite", response.getReturnValue().selectedSite);
                    component.set("v.exceptionError", response.getReturnValue().exceptionError);
                    component.set("v.PreventChange", false);
                    
                    component.set("v.lineItemWrapperList", response.getReturnValue().lineItemWrapperList);
                    component.set("v.packageWrapperList", response.getReturnValue().packageWrapperList);
                    component.set("v.Package2Create", response.getReturnValue().Package2Create);
                    component.set("v.errorMsg2", response.getReturnValue().errorMsg2);
                    component.set("v.Customers", response.getReturnValue().Customers);
                    component.set("v.Customer", response.getReturnValue().Customer);
                    component.set("v.CustomerPresent", response.getReturnValue().CustomerPresent);
                    component.set("v.createPack", response.getReturnValue().createPack);
                    component.set("v.isAwaiting", response.getReturnValue().isAwaiting);
                    component.set("v.pkgTypeValue", response.getReturnValue().pkgTypeValue);
                    
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    populatePkgDetail : function(component, event, helper) {
        var packType = event.getSource().get("v.value");
        var action = component.get("c.populatePackDetails");
        action.setParams({Package2Create1:JSON.stringify(component.get("v.Package2Create")), pkgTypeValue:packType});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                component.set("v.errorMsg2", response.getReturnValue().errorMsg2);
                component.set("v.PreventChange", true);
                component.set("v.Package2Create",response.getReturnValue().Package2Create);
                component.set("v.PreventChange", false);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    fetchSOLIIs : function(component, event, helper) {
        var Package2Create = component.get("v.Package2Create");
        if(component.get("v.PreventChange") == false && Package2Create.ERP7__Logistic__c != undefined && Package2Create.ERP7__Logistic__c != ''){
            //window.scrollTo(0,0);
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var logIds = Package2Create.ERP7__Logistic__c;
            var logisticIds = logIds.split(",");
            var LIds = JSON.stringify(logisticIds);
            var action = component.get("c.createPacksInit");
            action.setParams({LogisticIds:LIds, Customer:''});
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    //alert(response.getReturnValue().exceptionError);
                    component.set("v.PreventChange", true);
                    //component.set("v.Container", response.getReturnValue());
                    component.set("v.exceptionError", response.getReturnValue().exceptionError);
                    component.set("v.packageWrapperList", response.getReturnValue().packageWrapperList);
                    component.set("v.Package2Create", response.getReturnValue().Package2Create);
                    component.set("v.errorMsg2", response.getReturnValue().errorMsg2);
                    component.set("v.Customers", response.getReturnValue().Customers);
                    component.set("v.Customer", response.getReturnValue().Customer);
                    component.set("v.CustomerPresent", response.getReturnValue().CustomerPresent);
                    //component.set("v.createPack", response.getReturnValue().createPack);
                    //component.set("v.isAwaiting", response.getReturnValue().isAwaiting);
                    component.set("v.pkgTypeValue", response.getReturnValue().pkgTypeValue);
                    component.set("v.PreventChange", false);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }        
    },
    
    processDetails : function(component, event, helper) {
        console.log('processDetails called');
        var Package2Create = component.get("v.Package2Create");
        var packageWrapperList = component.get("v.packageWrapperList");
        Package2Create.ERP7__Weight__c = Package2Create.ERP7__Declared_Value__c = 0;
        for(var x in packageWrapperList){
            console.log('packageWrapperList[x] : ',packageWrapperList[x]);
            var remainingQty = 0;
             if(packageWrapperList[x].loli.ERP7__Packed_Quantity__c > 0) remainingQty = (packageWrapperList[x].qtyToPick - packageWrapperList[x].loli.ERP7__Packed_Quantity__c);
            else remainingQty = packageWrapperList[x].qtyToPick;
            console.log('remainingQty : ',remainingQty);
            if(packageWrapperList[x].pkgSelected == false && (packageWrapperList[x].qtyToPack == '' || packageWrapperList[x].qtyToPack == null || packageWrapperList[x].qtyToPack == undefined)) { 
                packageWrapperList[x].qtyToPack = 0;
                break;
                //component.set('v.exceptionError',$A.get('$Label.c.Pack_qty_cannot_be_null'));
                
            }
            if(packageWrapperList[x].pkgSelected == true && (packageWrapperList[x].qtyToPack == '' || packageWrapperList[x].qtyToPack == null || packageWrapperList[x].qtyToPack == undefined)) { 
                packageWrapperList[x].qtyToPack = 0;
                component.set('v.exceptionError',$A.get('$Label.c.Pack_qty_cannot_be_null'));
                break;
            }
            if(packageWrapperList[x].pkgSelected == true && packageWrapperList[x].qtyToPack < 0) { 
               // packageWrapperList[x].qtyToPack = 0;
                component.set('v.exceptionError',$A.get('$Label.c.Pack_qty_cannot_be_less_than_zero'));
                packageWrapperList[x].qtyToPack = 0;
                break;
            }
            if(remainingQty == 0 && packageWrapperList[x].qtyToPack > packageWrapperList[x].qtyToPick && packageWrapperList[x].pkgSelected == true) { 
                component.set("v.exceptionError", $A.get('$Label.c.Packed_quantity_cannot_be_greater_than_picked_Quantity'));
                 packageWrapperList[x].qtyToPack = packageWrapperList[x].qtyToPick;
                break;
            }
            if(packageWrapperList[x].pkgSelected == true && packageWrapperList[x].qtyToPack > 0 && remainingQty > 0 && packageWrapperList[x].qtyToPack > remainingQty) { 
               // packageWrapperList[x].qtyToPack = 0;
                component.set('v.exceptionError','Packed Quantity cannot be greater than remaining qty');//$A.get('$Label.c.Packed_quantity_cannot_be_greater_than_picked_Quantity'));
               packageWrapperList[x].qtyToPack = remainingQty;
                break;
            }
            console.log('packageWrapperList[x].qtyToPack : ',packageWrapperList[x].qtyToPack);
            //added packageWrapperList[x].pkgSelected 26/10/23
            if(packageWrapperList[x].pkgSelected && packageWrapperList[x].loli.ERP7__Product__r.ERP7__Weight__c >= 0) Package2Create.ERP7__Weight__c += (packageWrapperList[x].loli.ERP7__Product__r.ERP7__Weight__c * packageWrapperList[x].qtyToPack);
            if(packageWrapperList[x].pkgSelected && packageWrapperList[x].loli.ERP7__Price_Product__c >= 0) Package2Create.ERP7__Declared_Value__c += (packageWrapperList[x].loli.ERP7__Price_Product__c * packageWrapperList[x].qtyToPack);                    
        } 
        component.set("v.PreventChange", true);
        component.set("v.Package2Create",Package2Create);
        component.set("v.PreventChange", false);
        component.set("v.packageWrapperList", packageWrapperList);
    },
    
    updatePack : function(component, event, helper) {
        var Package2Create = component.get("v.Package2Create");
        var packageWrapperList = component.get("v.packageWrapperList");
        var packageWrapperListjs = JSON.stringify(packageWrapperList);
        var logIds = component.get("v.logisticIds");
        var logisticIds = logIds.split(",");
        var LIds = JSON.stringify(logisticIds);
        var packlist = [];
        console.log('allowZerodeclaredValue : ',component.get("v.allowZerodeclaredValue"));
        /*
        var WeightStr = document.getElementById("WeightStr").value;
        var doubleWeight = 0.00; 
        if (typeof WeightStr === 'string' || WeightStr instanceof String) doubleWeight = Number(WeightStr.replace(/[^0-9\.]+/g,""));
        else doubleWeight = WeightStr;
        Package2Create.ERP7__Weight__c = doubleWeight;
        */
        var errMSG = component.get("v.errorMsg2");
         var exMSG = component.get("v.exceptionError");
        if(errMSG != null && errMSG != '' && errMSG != undefined && errMSG == 'Sorry, selected package type not available.'){
            component.set("v.exceptionError", $A.get('$Label.c.Please_select_a_diffrent_package_type_or_set_up_the_required_data'));
            return;
        }
        var error = false;
        for(var x in packageWrapperList) {
            if(packageWrapperList[x].pkgSelected == true){
                    packlist.push(packageWrapperList[x]);
             }
             var remainingQty = 0;
            console.log('packageWrapperList[x].loli.ERP7__Packed_Quantity__c : ',packageWrapperList[x].loli.ERP7__Packed_Quantity__c);
            console.log('packageWrapperList[x].qtyToPick  : ',packageWrapperList[x].qtyToPick);
             if(packageWrapperList[x].loli.ERP7__Packed_Quantity__c > 0) remainingQty = (parseFloat(packageWrapperList[x].qtyToPick) - parseFloat(packageWrapperList[x].loli.ERP7__Packed_Quantity__c));
            else remainingQty = packageWrapperList[x].qtyToPick;
            console.log('remainingQty : ',remainingQty);
            remainingQty = parseFloat(remainingQty.toFixed(2));
            console.log('remainingQty : ',remainingQty);
            if(remainingQty == 0 && packageWrapperList[x].qtyToPack > packageWrapperList[x].qtyToPick && packageWrapperList[x].pkgSelected == true) { 
                component.set("v.errorMsg2", $A.get('$Label.c.Packed_quantity_cannot_be_greater_than_picked_Quantity'));
                error = true; 
                break; 
            }
            if(packageWrapperList[x].qtyToPack < 0  && packageWrapperList[x].pkgSelected == true) { 
                component.set("v.exceptionError", $A.get('$Label.c.Packed_quantity_cannot_be_less_than_Zero'));
                error = true; 
                break; 
            }
            console.log('packageWrapperList[x].qtyToPack : ',packageWrapperList[x].qtyToPack);
            if(packageWrapperList[x].pkgSelected == true && packageWrapperList[x].qtyToPack > 0 && remainingQty > 0 && packageWrapperList[x].qtyToPack > remainingQty) { 
               // packageWrapperList[x].qtyToPack = 0;
                component.set('v.exceptionError','Packed Quantity cannot be greater than remaining qty');//$A.get('$Label.c.Packed_quantity_cannot_be_greater_than_picked_Quantity'));
                error = true; 
                break; 
            }
            if((packageWrapperList[x].qtyToPack == '' || packageWrapperList[x].qtyToPack == null || packageWrapperList[x].qtyToPack == undefined || packageWrapperList[x].qtyToPack == 0) && packageWrapperList[x].pkgSelected == true) { 
                component.set("v.exceptionError", $A.get('$Label.c.Packed_quantity_cannot_be_less_than_Or_equal_to_Zero'));
                error = true; 
                break; 
            }
            
            
        }
        if(packlist.length == 0 && component.get("v.fromedit") == false){
            error = true;
            component.set("v.errorMsg2", $A.get('$Label.c.PH_RMA_PACK_Select_atleast_one_line_item_to_create_package'));
        }
        if(Package2Create.ERP7__Package_Type__c == '' || Package2Create.ERP7__Package_Type__c == null || Package2Create.ERP7__Package_Type__c == undefined){
             component.set("v.exceptionError", $A.get('$Label.c.Please_enter_the_package_type'));
                error = true;
            return;
        }
        else if(Package2Create.ERP7__Length__c <=0 || Package2Create.ERP7__Length__c == null || Package2Create.ERP7__Length__c == undefined){
             component.set("v.exceptionError", $A.get('$Label.c.Please_enter_the_length_of_the_package'));
                error = true;
            return;
        }
        else if(Package2Create.ERP7__Width__c <=0 || Package2Create.ERP7__Width__c == null || Package2Create.ERP7__Width__c == undefined){
             component.set("v.exceptionError", $A.get('$Label.c.Please_enter_the_Width_of_the_package'));
                error = true;
            return;
        }
        else if(Package2Create.ERP7__Height__c <=0 || Package2Create.ERP7__Height__c == null || Package2Create.ERP7__Height__c == undefined){
             component.set("v.exceptionError", $A.get('$Label.c.Please_enter_the_height_of_the_package'));
                error = true;
            return;
        }
         else if(Package2Create.ERP7__Weight__c <=0 || Package2Create.ERP7__Weight__c == null || Package2Create.ERP7__Weight__c == undefined){
             component.set("v.exceptionError", $A.get('$Label.c.Please_enter_the_weight_of_the_package'));
                error = true;
            return;
        }
        else if((Package2Create.ERP7__Declared_Value__c == null || Package2Create.ERP7__Declared_Value__c == undefined) && component.get("v.allowZerodeclaredValue") == false){
             component.set("v.exceptionError", $A.get('$Label.c.Please_enter_the_declared_value_of_the_package'));
                error = true;
            return;
        }
        else if(Package2Create.ERP7__Declared_Value__c <= 0 && component.get("v.allowZerodeclaredValue") == false){
             component.set("v.exceptionError", $A.get('$Label.c.Please_enter_the_declared_value_of_the_package'));
                error = true;
            return;
        }
        else if(Package2Create.ERP7__Shipment_Type__c == '' || Package2Create.ERP7__Shipment_Type__c == null || Package2Create.ERP7__Shipment_Type__c == undefined|| Package2Create.ERP7__Shipment_Type__c == '--None--'){
             component.set("v.exceptionError", $A.get('$Label.c.Please_enter_the_shipment_type_of_the_package'));
                error = true;
            return;
        }
        if(!error){
            //window.scrollTo(0,0);
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action = component.get("c.updatePacks");
            action.setParams({Package2Create1:JSON.stringify(Package2Create), PackageWrapperListJs:packageWrapperListjs, LogisticIds:LIds, IsAwaiting:component.get("v.isAwaiting")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    console.log('res :',response.getReturnValue());
                    component.set("v.PreventChange", true);
                    component.set("v.Container", response.getReturnValue());
                    component.set("v.SiteName", response.getReturnValue().SiteName);
                    component.set("v.Logistics", response.getReturnValue().LogisticRecs);
                    component.set("v.currentEmployee", response.getReturnValue().Employee);
                    component.set("v.selectedSite", response.getReturnValue().selectedSite);
                    component.set("v.exceptionError", response.getReturnValue().exceptionError);
                    console.log('1 ');
                    component.set("v.lineItemWrapperList", response.getReturnValue().lineItemWrapperList);
                    component.set("v.packageWrapperList", response.getReturnValue().packageWrapperList);
                    component.set("v.Package2Create", response.getReturnValue().Package2Create);
                    console.log('2 ');
                    component.set("v.errorMsg2", response.getReturnValue().errorMsg2);
                    component.set("v.Customers", response.getReturnValue().Customers);
                    component.set("v.Customer", response.getReturnValue().Customer);
                    component.set("v.CustomerPresent", response.getReturnValue().CustomerPresent);
                    component.set("v.createPack", response.getReturnValue().createPack);
                     console.log('33');
                    component.set("v.isAwaiting", response.getReturnValue().isAwaiting);
                    component.set("v.pkgTypeValue", response.getReturnValue().pkgTypeValue);
                    component.set("v.PreventChange", false);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }        
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
    
   
    
    focusTOscan : function (component, event,helper) {
        component.set("v.scanValue",'');
        helper.focusTOscan(component, event);  
        
    },
    
    verifyScanCode : function (component, event, helper) { 
       // var scanedfield = component.get("v.scanValue");
       ///console.log('verifyScanCodes scanedfield : ',scanedfield);
       /// var editedFieldId = event.getSource().getLocalId();
       // console.log('verifyScanCodes editedFieldId : ',editedFieldId);
         if(component.get("v.Scanflow")){
            var scan_Code = component.get("v.scanValue");
            var mybarcode = scan_Code; 
            if(mybarcode != ''){
                component.set("v.exceptionError", '');
                //alert(mybarcode); 
                if(mybarcode == 'ORDER') { component.Back2Outbound(); }
                else if(mybarcode == 'PICK') { component.createPicks(); }
                    else if(mybarcode == 'PACK') { component.createPacks(); }
                        else if(mybarcode == 'SAVE') { if(component.get("v.createPack")) component.updatePack(); else component.set("v.exceptionError", $A.get('$Label.c.PH_OB_Invalid_barcode_scanned'));}
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
    parentFieldChange : function(component, event, helper) {
        console.log('parentFieldChange : ',component.get("v.Package2Create.ERP7__Shipment_Type__c"));
    	//var controllerValue = component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
        var pickListMap = component.get("v.depnedentFieldMap");
        console.log('pickListMap : '+pickListMap);
        var controllerValue =component.get("v.Package2Create.ERP7__Shipment_Type__c");
        if (controllerValue != '--None--' && controllerValue != undefined && controllerValue != null && controllerValue != '' && pickListMap != null && pickListMap != undefined) {
            console.log('in parent');
             //get child picklist value
            var childValues = pickListMap[controllerValue];
            var childValueList = [];
           // childValueList.push('--None--');
            for (var i in childValues) {
                childValueList.push(childValues[i]);
            }
            // set the child list
            component.set("v.listDependingValues", childValueList);
            
            if(childValues.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
            }else{
                component.set("v.bDisabledDependentFld" , true); 
            }
            
        } else {
            component.set("v.listDependingValues", ['Package']);
            component.set("v.bDisabledDependentFld" , true);
        }
	},
})