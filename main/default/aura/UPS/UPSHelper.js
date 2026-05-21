({
    doInitHandler: function(component, event, helper){
        console.log('doInitHandler helper called');
        var action = component.get("c.myConstruct");
        var sId = component.get("v.shipmentId");
        var paId = component.get("v.packageId");
        if(sId == 'undefined' || sId == null || sId == undefined) sId = '';
        action.setParams({ 
            shipId:sId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                console.log('obj upsconstructor~>',JSON.stringify(obj));
                if(obj != null){
                    var wrError = response.getReturnValue().wrapError;
                    if(wrError != null && wrError != '' && wrError != undefined) component.set("v.errorMsg1", wrError);
                    component.set("v.myConsW", obj);
                    component.set('v.showeditBillDetails',obj.showeditBillDetails);
                    component.set('v.allowReturnShipment',obj.allowReturnShipment);
                    component.set('v.disableEditBillOptReturnShipment',obj.disableEditBillOptReturnShipment);
                    
                    component.set('v.allowFedExReturnShipmentFromUPS',obj.allowFedExReturnShipmentFromUPS);
                    if(sId != 'undefined' && sId != null && sId != undefined && sId != ''){
                        console.log('obj.Packages.length~>'+obj.Packages.length);
                        console.log('obj.Shipment~>'+JSON.stringify(obj.Shipment));
                        if(!$A.util.isUndefinedOrNull(obj.Shipment.Id) && !$A.util.isEmpty(obj.Shipment.Id) && obj.Shipment.ERP7__Status__c != 'Cancelled'){ //Added by Arshad 31 Jan 2024
                            console.log('obj.returnShipment~>'+JSON.stringify(obj.returnShipment));
                            component.set("v.shipment", obj.Shipment);
                            component.set("v.returnshipment", obj.returnShipment);
                            component.set("v.fromAddress", obj.fromAddress);
                            component.set("v.address", obj.toAddress);
                            component.set("v.packageList", obj.Packages);
                            
                            //Added by Arshad 06 Oct 2023
                            if(obj.Packages.length > 0){
                                if(obj.Packages[0].ERP7__Logistic__c != null && obj.Packages[0].ERP7__Logistic__c != '' && obj.Packages[0].ERP7__Logistic__c != undefined){
                                    if(!$A.util.isEmpty(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c) && !$A.util.isUndefinedOrNull(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c)) component.set("v.returnshipment.ERP7__Billing_Account_Number__c",obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c);
                                    if(!$A.util.isEmpty(obj.Packages[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c) && !$A.util.isUndefinedOrNull(obj.Packages[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c)) component.set("v.returnshipment.ERP7__Shipment_Billing_options__c",obj.Packages[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c);
                                    if(!$A.util.isEmpty(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c) && !$A.util.isUndefinedOrNull(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c)) component.set("v.returnshipment.ERP7__Billing_Contact__c",obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c);
                                    if(!$A.util.isEmpty(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c) && !$A.util.isUndefinedOrNull(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c)){
                                        component.set("v.returnshipment.ERP7__Billing_Address__c",obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c);
                                        if(!$A.util.isEmpty(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c) && !$A.util.isUndefinedOrNull(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c)) component.set("v.returnshipment.ERP7__Billing_Postal_Code__c",obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c);
                                        if(!$A.util.isEmpty(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Country__c) && !$A.util.isUndefinedOrNull(obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Country__c)){
                                            var BillCountryAction = component.get("c.getCountryCode");
                                            BillCountryAction.setParams({
                                                "countryName": obj.Packages[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Country__c,
                                            });
                                            BillCountryAction.setCallback(this, function(BillCountryResp){
                                                if(BillCountryResp.getState() === "SUCCESS"){
                                                    console.log("BillCountryAction resp: ", BillCountryResp.getReturnValue());
                                                    component.set("v.returnshipment.ERP7__Billing_Country_Code__c",BillCountryResp.getReturnValue());
                                                }else{
                                                    var errors = BillCountryResp.getError();
                                                    console.log("server error in BillCountryAction : ", JSON.stringify(errors));
                                                } 
                                            });
                                            $A.enqueueAction(BillCountryAction);
                                        }else component.set("v.returnshipment.ERP7__Billing_Country_Code__c",'');
                                    }
                                    if(!$A.util.isEmpty(obj.Packages[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c) && !$A.util.isUndefinedOrNull(obj.Packages[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c)){
                                        component.set("v.selectedLogisticReturnShipType",obj.Packages[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c);
                                        component.set("v.selectedTabRS",obj.Packages[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c);
                                        console.log('selectedLogisticReturnShipType selectedTabRS~>'+obj.Packages[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c);
                                    }
                                }
                            }
                            
                            if(obj.Shipment.ERP7__Status__c == 'Shipped'){
                                component.set("v.ShowGetRate",false);
                                component.set("v.UPS_Services", obj.uWrap);
                            }
                            if(obj.Shipment.ERP7__Status__c == 'Picked Up'){
                                component.set("v.ShowGetRate",false);
                                component.set("v.UPS_Services", obj.uWrap);
                            }
                            if(obj.Shipment.ERP7__Status__c == 'Delivered'){
                                component.set("v.ShowGetRate",false);
                                component.set("v.UPS_Services", obj.uWrap);
                            }
                        }
                        else{
                            //Added by Arshad 31 Jan 2024
                            var paId = component.get("v.packageId");
                            if(!$A.util.isEmpty(paId) && !$A.util.isUndefinedOrNull(paId)){
                                console.log('calling initHelperActions from here paId~>'+paId);
                                helper.initHelperActions(component, event, helper, paId);
                            }else{
                                console.log('in else obj.Packages.length~>'+obj.Packages.length);
                                if(obj.Packages.length > 0){
                                    var selectedPackIds = []; 
                                    for(var x in obj.Packages) { 
                                        selectedPackIds.push(obj.Packages[x].Id);
                                    }
                                    console.log('selectedPackIds ~>'+selectedPackIds);
                                    component.set("v.packageId",selectedPackIds);
                                    var paId1 = component.get("v.packageId");
                                    if(!$A.util.isEmpty(paId1) && !$A.util.isUndefinedOrNull(paId1)){
                                        console.log('else calling initHelperActions from here paId1~>'+paId1);
                                        this.initHelperActions(component, event, helper, paId1);
                                    }
                                }
                            }
                        }
                    } 
                }
                
            }else{
                var errors = response.getError();
                console.log("myConstruct server error : ", errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    setPickValues : function(component, event, helper){
        if(component.find("tosconfirmation") != undefined){
            var tos = component.find("tosconfirmation");
            //tos.set("v.options", component.get('v.tosconfirmation'));
            component.set("v.tosconfirmationOptions",component.get('v.tosconfirmation'));
        }
        if(component.find("rfeconfirmation") != undefined){
            var rfe = component.find("rfeconfirmation");
            //rfe.set("v.options", component.get('v.rfeconfirmation'));
            component.set("v.rfeconfirmationOptions",component.get('v.rfeconfirmation'));
        }  
    },
    
    helperFun : function(component,event,secId) {
        var acc = component.find(secId); 
        for(var i in acc) {
            $A.util.toggleClass(acc[i], 'slds-show');  
            $A.util.toggleClass(acc[i], 'slds-hide');  
        } 
    },
    
    //Added by Arshad 31 Jan 2024
    initHelperActions : function(component, event, helper, paId){
        console.log('initHelperActions called');
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) { monthDigit = '0' + monthDigit; } 
        component.set('v.shipment.ERP7__Shipment_Date__c',today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        component.set('v.returnshipmentdate',today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var action1 = component.get("c.fetchToAddress");
        action1.setParams({
            packId:JSON.stringify(paId)
        });
        action1.setCallback(this, function(response) {
            console.log('fetchToAddress response.getState() : ',response.getState());
            if(response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                console.log('fetchToAddress obj : ',response.getReturnValue());
                component.set("v.address", obj);
            }else{
                var errors = response.getError();
                console.log("fetchToAddress server error : ", errors);
            }
        });
        $A.enqueueAction(action1);
        
        var action2 = component.get("c.fetchFromAddress");
        action2.setParams({
            packId:JSON.stringify(paId)
        });
        action2.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                component.set("v.fromAddress", obj);
            }else{
                var errors = response.getError();
                console.log("fetchFromAddress server error : ", errors);
            }
        });
        $A.enqueueAction(action2);
        
        var action3 = component.get("c.fetchingPackages");
        action3.setParams({
            pakIds:paId
        });
        action3.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                console.log('obj packa : ',JSON.stringify(response.getReturnValue()));
                component.set("v.packageList", obj);
                if(obj.length > 0){
                    if(obj[0].ERP7__Logistic__c != null && obj[0].ERP7__Logistic__c != '' && obj[0].ERP7__Logistic__c != undefined){
                        if(obj[0].ERP7__Logistic__r.ERP7__Billing_Postal_Code__c != null && obj[0].ERP7__Logistic__r.ERP7__Billing_Postal_Code__c != '' && obj[0].ERP7__Logistic__r.ERP7__Billing_Postal_Code__c != undefined){
                            component.set('v.shipment.ERP7__Billing_Postal_Code__c',obj[0].ERP7__Logistic__r.ERP7__Billing_Postal_Code__c);
                        }
                        if(obj[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c != null && obj[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c != '' && obj[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c != undefined){
                            component.set('v.shipment.ERP7__Billing_Account_Number__c',obj[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c);
                        }
                        if(obj[0].ERP7__Logistic__r.ERP7__Billing_Country_Code__c != null && obj[0].ERP7__Logistic__r.ERP7__Billing_Country_Code__c != '' && obj[0].ERP7__Logistic__r.ERP7__Billing_Country_Code__c != undefined){
                            component.set('v.shipment.ERP7__Billing_Country_Code__c',obj[0].ERP7__Logistic__r.ERP7__Billing_Country_Code__c);
                        }
                        if(obj[0].ERP7__Logistic__r.ERP7__Billing_options__c != null && obj[0].ERP7__Logistic__r.ERP7__Billing_options__c != ''){
                            component.set('v.shipment.ERP7__Shipment_Billing_options__c',obj[0].ERP7__Logistic__r.ERP7__Billing_options__c);
                        }
                        //component.set('v.shipment.ERP7__Description__c',obj[0].ERP7__Description__c);
                        
                        //Added by Arshad 26 Oct 2023
                        //if(component.get("v.allowFedExReturnShipmentFromUPS")){
                        if(!$A.util.isEmpty(obj[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c) && !$A.util.isUndefinedOrNull(obj[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c)) component.set("v.returnshipment.ERP7__Billing_Account_Number__c",obj[0].ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c);
                        if(!$A.util.isEmpty(obj[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c) && !$A.util.isUndefinedOrNull(obj[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c)) component.set("v.returnshipment.ERP7__Shipment_Billing_options__c",obj[0].ERP7__Logistic__r.ERP7__Bill_To_Return__c);
                        if(!$A.util.isEmpty(obj[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c) && !$A.util.isUndefinedOrNull(obj[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c)) component.set("v.returnshipment.ERP7__Billing_Contact__c",obj[0].ERP7__Logistic__r.ERP7__Billing_Contact_Return__c);
                        if(!$A.util.isEmpty(obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c) && !$A.util.isUndefinedOrNull(obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c)){
                            component.set("v.returnshipment.ERP7__Billing_Address__c",obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__c);
                            if(!$A.util.isEmpty(obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c) && !$A.util.isUndefinedOrNull(obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c)) component.set("v.returnshipment.ERP7__Billing_Postal_Code__c",obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c);
                            if(!$A.util.isEmpty(obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Country__c) && !$A.util.isUndefinedOrNull(obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Country__c)){
                                var BillCountryAction = component.get("c.getCountryCode");
                                BillCountryAction.setParams({
                                    "countryName": obj[0].ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Country__c,
                                });
                                BillCountryAction.setCallback(this, function(BillCountryResp){
                                    if(BillCountryResp.getState() === "SUCCESS"){
                                        console.log("BillCountryAction resp: ", BillCountryResp.getReturnValue());
                                        component.set("v.returnshipment.ERP7__Billing_Country_Code__c",BillCountryResp.getReturnValue());
                                    }else{
                                        var errors = BillCountryResp.getError();
                                        console.log("server error in BillCountryAction : ", JSON.stringify(errors));
                                    } 
                                });
                                $A.enqueueAction(BillCountryAction);
                            }else component.set("v.returnshipment.ERP7__Billing_Country_Code__c",'');
                        }
                        if(!$A.util.isEmpty(obj[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c) && !$A.util.isUndefinedOrNull(obj[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c)){
                            component.set("v.selectedLogisticReturnShipType",obj[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c);
                            component.set("v.selectedTabRS",obj[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c);
                            console.log('selectedLogisticReturnShipType selectedTabRS~>'+obj[0].ERP7__Logistic__r.ERP7__Shipment_type_Return__c);
                        }
                        //}
                        
                        console.log('v.shipment~>'+JSON.stringify(component.get("v.shipment")));
                        console.log('v.returnshipment~>'+JSON.stringify(component.get("v.returnshipment")));
                    }
                }
            }else{
                var errors = response.getError();
                console.log("fetchingPackages server error : ", errors);
            }
        });
        $A.enqueueAction(action3);
        
        var action4 = component.get("c.fetchingPackageLists");
        action4.setParams({
            packId:JSON.stringify(paId)
        });
        action4.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                component.set("v.packageLists", obj);
            }else{
                var errors = response.getError();
                console.log("fetchingPackageLists server error : ", errors);
            }
        });
        $A.enqueueAction(action4);
        
        var ShiptoContactAction = component.get("c.getShiptoContact");
        ShiptoContactAction.setParams({
            packId:JSON.stringify(paId)
        });
        ShiptoContactAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                console.log('getShiptoContact response : ',response.getReturnValue());
                component.set("v.ShiptoContact", obj);
            }else{
                var errors = response.getError();
                console.log("getShiptoContact server error : ", errors);
            }
        });
        $A.enqueueAction(ShiptoContactAction);
        
    },
})