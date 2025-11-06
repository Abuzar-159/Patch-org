({	//changes done by Asra on 28/12/2023--added lables for all error messages
    doInit : function(component, event, helper){
        component.set("v.isLoading",true);
        console.log('Fedex doInit called');
        var shipID = component.get("v.shipmentId");
        helper.doInitHandler(component, event, helper);
        console.log('shipID : ',shipID);
        try{
            if(shipID == null || shipID == '' || shipID == 'undefined' || shipID == undefined){
                var today = new Date();
                var monthDigit = today.getMonth() + 1;   
                if (monthDigit <= 9){ monthDigit = '0' + monthDigit; }
                component.set('v.shipment.ERP7__Shipment_Date__c',today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
                component.set('v.returnshipmentdate',today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
                console.log(' component.get("v.packageId") : ', component.get("v.packageId"));
                var paId = component.get("v.packageId");
                
                var toAddaction = component.get("c.fetchToAddress");
                toAddaction.setParams({packId:JSON.stringify(paId)});
                toAddaction.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        var obj = response.getReturnValue();
                        console.log('toaddress obj~>'+JSON.stringify(obj));
                        component.set("v.address", obj);
                        var AddresserrorMsg = '';
                        if($A.util.isEmpty(obj.ERP7__City__c) || $A.util.isUndefinedOrNull(obj.ERP7__City__c)){
                            AddresserrorMsg = $A.get('$Label.c.City_is_required_in_To_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Country__c) || $A.util.isUndefinedOrNull(obj.ERP7__Country__c)){
                            AddresserrorMsg = $A.get('$Label.c.Country_is_required_in_To_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__State__c) || $A.util.isUndefinedOrNull(obj.ERP7__State__c)){
                            AddresserrorMsg = $A.get('$Label.c.State_is_required_in_To_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Postal_Code__c) || $A.util.isUndefinedOrNull(obj.ERP7__Postal_Code__c)){
                            AddresserrorMsg = $A.get('$Label.c.Postal_Code_is_required_in_To_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Contact__c) || $A.util.isUndefinedOrNull(obj.ERP7__Contact__c)){
                            AddresserrorMsg = $A.get('$Label.c.Contact_is_required_in_To_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Customer__r.ERP7__Company__c) || $A.util.isUndefinedOrNull(obj.ERP7__Customer__r.ERP7__Company__c)){
                            if($A.util.isEmpty(obj.ERP7__Contact__r.ERP7__Company__c) || $A.util.isUndefinedOrNull(obj.ERP7__Contact__r.ERP7__Company__c)) AddresserrorMsg = $A.get('$Label.c.Company_is_required_in_To_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Customer__r.Phone) || $A.util.isUndefinedOrNull(obj.ERP7__Customer__r.Phone)){
                            if($A.util.isEmpty(obj.ERP7__Contact__r.Phone) || $A.util.isUndefinedOrNull(obj.ERP7__Contact__r.Phone)) AddresserrorMsg = $A.get('$Label.c.Phone_is_required_in_To_Address_Click_here_to_Update');
                        }
                        console.log('errormsg address~>'+AddresserrorMsg);
                        if(AddresserrorMsg != '' && obj.Id != undefined && obj.Id != null){
                            component.set("v.addresserrmsg", AddresserrorMsg);
                            component.set("v.redirectURL",'/'+obj.Id); 
                        }  
                    }else{
                        var errors = response.getError();
                        console.log("fetchFromAddress server error : ", errors);
                    }
                });
                $A.enqueueAction(toAddaction);
                
                var paId = component.get("v.packageId");
                var fromAddaction = component.get("c.fetchFromAddress");
                fromAddaction.setParams({packId:JSON.stringify(paId)});
                fromAddaction.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        var obj = response.getReturnValue();
                        console.log('fromAddress obj~>'+JSON.stringify(obj));
                        component.set("v.fromAddress", obj);
                        var AddresserrorMsg = '';
                        if($A.util.isEmpty(obj.ERP7__City__c) || $A.util.isUndefinedOrNull(obj.ERP7__City__c)){
                            AddresserrorMsg = $A.get('$Label.c.City_is_required_in_From_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Country__c) || $A.util.isUndefinedOrNull(obj.ERP7__Country__c)){
                            AddresserrorMsg = $A.get('$Label.c.Country_is_required_in_From_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__State__c) || $A.util.isUndefinedOrNull(obj.ERP7__State__c)){
                            AddresserrorMsg = $A.get('$Label.c.State_is_required_in_From_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Postal_Code__c) || $A.util.isUndefinedOrNull(obj.ERP7__Postal_Code__c)){
                            AddresserrorMsg = $A.get('$Label.c.Postal_Code_is_required_in_From_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Contact__c) || $A.util.isUndefinedOrNull(obj.ERP7__Contact__c)){
                            AddresserrorMsg = $A.get('$Label.c.Contact_is_required_in_From_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Customer__r.ERP7__Company__c) || $A.util.isUndefinedOrNull(obj.ERP7__Customer__r.ERP7__Company__c)){
                            if($A.util.isEmpty(obj.ERP7__Contact__r.ERP7__Company__c) || $A.util.isUndefinedOrNull(obj.ERP7__Contact__r.ERP7__Company__c)) AddresserrorMsg = $A.get('$Label.c.Company_is_required_in_From_Address_Click_here_to_Update');
                        }else if($A.util.isEmpty(obj.ERP7__Customer__r.Phone) || $A.util.isUndefinedOrNull(obj.ERP7__Customer__r.Phone)){
                            if($A.util.isEmpty(obj.ERP7__Contact__r.Phone) || $A.util.isUndefinedOrNull(obj.ERP7__Contact__r.Phone)) AddresserrorMsg = $A.get('$Label.c.Phone_is_required_in_From_Address_Click_here_to_UpdatePhone_is_required_in_From');
                        }
                        console.log('errormsg address~>'+AddresserrorMsg);
                        if(AddresserrorMsg != '' && obj.Id != undefined && obj.Id != null){
                            component.set("v.addresserrmsg", AddresserrorMsg);
                            component.set("v.redirectURL",'/'+obj.Id); 
                        }  
                    }else{
                        var errors = response.getError();
                        console.log("fetchFromAddress server error : ", errors);
                    }
                });
                $A.enqueueAction(fromAddaction);
                
                var paId = component.get("v.packageId");
                var fetchPackaction = component.get("c.fetchingPackages");
                fetchPackaction.setParams({packId:JSON.stringify(paId)});
                fetchPackaction.setCallback(this, function(response) {
                    if(response.getState() === "SUCCESS"){
                        console.log('Pack return : ',JSON.stringify(response.getReturnValue()));
                        var obj = response.getReturnValue();
                        component.set("v.packageList", obj);
                        
                        if(obj.length > 0){
                            if(obj[0].ERP7__Logistic__c != null && obj[0].ERP7__Logistic__c != '' && obj[0].ERP7__Logistic__c != undefined){
                                component.set('v.shipment.ERP7__Billing_Contact__c',obj[0].ERP7__Logistic__r.ERP7__Billing_Contact__c);
                                component.set('v.shipment.ERP7__Billing_Address__c',obj[0].ERP7__Logistic__r.ERP7__Billing_Address__c);
                                if(obj[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c != null && obj[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c != '' && obj[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c != undefined){
                                    component.set('v.shipment.ERP7__Billing_Account_Number__c',obj[0].ERP7__Logistic__r.ERP7__Billing_Account_number__c);
                                }
                                if(obj[0].ERP7__Logistic__r.ERP7__Billing_options__c != null && obj[0].ERP7__Logistic__r.ERP7__Billing_options__c != ''){
                                    component.set('v.shipment.ERP7__Shipment_Billing_options__c',obj[0].ERP7__Logistic__r.ERP7__Billing_options__c);
                                }
                                //component.set('v.shipment.ERP7__Description__c',obj[0].ERP7__Description__c);
                                
                                //Added by Arshad 06 Oct 2023
                                //if(component.get("v.allowUPSReturnShipmentFromFedEx")){
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
                $A.enqueueAction(fetchPackaction);
                var paId = component.get("v.packageId");
                var ShiptoContactAction = component.get("c.getShiptoContact");
                ShiptoContactAction.setParams({packId:JSON.stringify(paId)});
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
                
                var paId = component.get("v.packageId");
                var fetchpacklistaction = component.get("c.fetchingPackageLists");
                fetchpacklistaction.setParams({packId:JSON.stringify(paId)});
                fetchpacklistaction.setCallback(this, function(response) {
                    if(response.getState() === "SUCCESS"){
                        var obj = response.getReturnValue();
                        component.set("v.packageLists", obj);
                    }else{
                        var errors = response.getError();
                        console.log("fetchingPackageLists server error : ", errors);
                    }
                });
                $A.enqueueAction(fetchpacklistaction);
            }
            
            /* For Picklists*/ 
            var termsOfShipmentAction = component.get("c.getTermsOfShipment");
            var termsOfShipment = component.find("termsofshipment");
            var termsOfShipmentOpts=[];
            termsOfShipmentAction.setCallback(this, function(a) {
                for(var i=0;i< a.getReturnValue().length;i++){
                    termsOfShipmentOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                //termsOfShipment.set("v.options", termsOfShipmentOpts);
                component.set("v.shipment.ERP7__Terms_Of_Shipment__c",termsOfShipmentOpts[0].value);
                component.set("v.termsofshipmentOptions",termsOfShipmentOpts);
            });
            $A.enqueueAction(termsOfShipmentAction);
            
            var billingOptionsAction = component.get("c.getBillingOptions");
            var billingOpts=[];
            billingOptionsAction.setCallback(this, function(a) {
                for(var i=0;i< a.getReturnValue().length;i++){
                    billingOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                
                component.set("v.billingOptions",billingOpts);
                
            });
            $A.enqueueAction(billingOptionsAction); 
            
            var reasonForExpertAction = component.get("c.getReasonForExport");
            var reasonForExpert = component.find("reasonforexport");
            var reasonForExpertOpts=[];
            reasonForExpertAction.setCallback(this, function(a) {
                for(var i=0;i< a.getReturnValue().length;i++){
                    reasonForExpertOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                //reasonForExpert.set("v.options", reasonForExpertOpts);
                component.set("v.reasonforexportOptions",reasonForExpertOpts);
                component.set("v.shipment.ERP7__Reason_For_Export__c",reasonForExpertOpts[0].label);
            });
            $A.enqueueAction(reasonForExpertAction);
            
            var signatureServiceAction = component.get("c.getSignatureServices");
            var signatureservice = component.find("signatureservice");
            var signatureServiceOpts=[];
            signatureServiceAction.setCallback(this, function(a) {
                for(var i=0;i< a.getReturnValue().length;i++){
                    signatureServiceOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                //signatureservice.set("v.options", signatureServiceOpts);
                component.set("v.signatureserviceOptions",signatureServiceOpts);
                component.set("v.signatureservice", signatureServiceOpts);
            });
            $A.enqueueAction(signatureServiceAction);
            
            var statusconfirmationAction = component.get("c.getStatusConfirmation");
            var statusconfirmationOpts=[];
            statusconfirmationAction.setCallback(this, function(a) {
                for(var i=0;i< a.getReturnValue().length;i++){
                    statusconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                component.set("v.statusconfirmation", statusconfirmationOpts);
                component.set("v.statusconfirmationOptions",statusconfirmationOpts);
                
            });
            $A.enqueueAction(statusconfirmationAction);
             var FedexSpecialServicesAction = component.get("c.getSpecialServices");
            var specialService=[];
            FedexSpecialServicesAction.setCallback(this, function(a) {
                console.log('specialService : ',a.getReturnValue());
                for(var i=0;i< a.getReturnValue().length;i++){
                    specialService.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                console.log('specialService 2: ',specialService);
                component.set("v.specialServicesFedex", specialService);
               // component.set("v.statusconfirmationOptions",statusconfirmationOpts);
                
            });
            $A.enqueueAction(FedexSpecialServicesAction);
            
        }catch(error){
            console.log('error in Doinit : ',error);
        }	
        setTimeout(function(){component.set("v.isLoading", false);}, 5000);
    },
    
    setSSCPickList :function(component, event,helper) {
        var SSconfirmation = component.find("signatureservice");
        //SSconfirmation.set("v.options", component.get('v.signatureservice'));
        //component.set("v.signatureserviceOptions",component.get('v.signatureservice'));
    },
    
    setPickList :function(component, event,helper) {
        var statusconfirmation = component.find("statusconfirmation");
        //statusconfirmation.set("v.options", component.get('v.statusconfirmation'));
        //component.set("v.statusconfirmationOptions",component.get('v.statusconfirmation'));
    },
    
    closeError : function(component, event, helper) {
        component.set("v.exceptionError","");
    },
    
    backToRMAPackage : function(component, event, helper){
        
    },
    
    Shipping_Rate : function(component, event, helper){
        component.set("v.isLoading",true);
        console.log('Shipping Rate called~>'+component.get("v.shipment.ERP7__Shipment_Date__c")+' & typeof~>'+typeof component.get("v.shipment.ERP7__Shipment_Date__c"));
        component.set("v.errorMsg1", ''); 
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit; 
        }
        var dayDigit = today.getDate();
        if (dayDigit <= 9) {
            dayDigit = '0' + dayDigit; 
        }        
        var todayDate = today.getFullYear()+'-'+monthDigit+'-'+dayDigit;
        var packId = component.get("v.packageList");
        var fromAddress = component.get("v.fromAddress.Id");
        var toAdd = component.get("v.address.Id");
        
        var shipmentDate = component.get("v.shipment.ERP7__Shipment_Date__c"); //,today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        console.log('component shipment date~>'+component.get("v.shipment.ERP7__Shipment_Date__c"));
        console.log('todayDate~>'+todayDate);
        console.log('shipmentDate ~>'+shipmentDate);
        var errorFlag = true;
        var errorMsg = '';
        
        if(component.get("v.address.ERP7__Postal_Code__c") == '' || component.get("v.address.ERP7__Postal_Code__c") == null) {
            errorFlag = false;
            errorMsg = $A.get('$Label.c.To_Address_Postal_Code_Unavailable');
        }
        
        if(component.get("v.address.ERP7__Country__c") == '' || component.get("v.address.ERP7__Country__c") == null) {
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.To_Address_Country_Unavailable');
        }
        
        if(component.get("v.fromAddress.ERP7__Postal_Code__c") == '' || component.get("v.fromAddress.ERP7__Postal_Code__c") == null) {
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.From_Address_Postal_Code_Unavailable');
        }
        
        if(component.get("v.fromAddress.ERP7__Country__c") == '' || component.get("v.fromAddress.ERP7__Country__c") == null) {
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.From_Address_Country_Unavailable');
        }
        
        if(component.get("v.shipment.ERP7__Status__c") == 'Shipped' || component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.This_Package_Has_Already_Been') + component.get("v.shipment.ERP7__Status__c") + '.';
        }
        
        if(component.get("v.shipment.ERP7__Shipment_Date__c") < todayDate){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.The_Shipment_Date_Should_Not_Be_In_Past');
        }
        if(shipmentDate == null || shipmentDate == '' || shipmentDate == undefined){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Please_select_the_Shipment_Date_to_get_Rates');
        }
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg1", errorMsg);
        
        if(errorFlag){
            console.log('errorFlag is true');
            component.set("v.errorMsg1", '');
            var action = component.get("c.Shipping_Rate_Request");
            action.setParams({
                "packList":component.get("v.packageList"),
                "fromAdd":fromAddress,
                "tAddress":toAdd,
                "shipDate":shipmentDate,
                "myConsVar": myConsVariable,
                "isReturnShipment":false,
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var obj = response.getReturnValue();
                    console.log('Shipping_Rate response~>'+JSON.stringify(obj));
                    console.log('Shipping_Rate upsW.Error~>'+obj.Error);
                    component.set("v.FEDEX_Services", response.getReturnValue());
                    console.log('Fedex services in getrates~>'+JSON.stringify(obj));
                    component.set("v.ShowTimeInCostTab",obj.time_in_cost_tab);
                    component.set("v.WrapperMsg", obj.UPSErrorMsg);
                    component.set("v.errorMsg1", obj.Error);
                    component.set("v.ShowGetRate",true);
                }else{
                    var errors = response.getError();
                    console.log("Rate_Request server error : ", errors);
                }
            });
            $A.enqueueAction(action);
        }else{
            console.log('Shipping_Rate errorFlag false~>'+errorFlag);
            component.set("v.ShowTimeInCostTab",false);
            component.set("v.WrapperMsg", '');
            
        }
        setTimeout(function(){component.set("v.isLoading", false);}, 4000);
    },
    
    Shipping_Request: function(component, event,helper) {
        console.log('ENTERED Shipping_Request');
        try{
            component.set("v.isLoading",true);
            console.log('Shipping_Request called');
            component.set("v.errorMsg1", '');
            component.set("v.FEDEX_Services.UPSErrorMsg", '');
            component.set("v.WrapperMsg", '');
            component.set("v.errorMsg1", ''); 
            var today = new Date();
            var monthDigit = today.getMonth() + 1;
            if (monthDigit <= 9) {
                monthDigit = '0' + monthDigit; 
            }
            var dayDigit = today.getDate();
            if (dayDigit <= 9) {
                dayDigit = '0' + dayDigit; 
            }        
            var todayDate = today.getFullYear()+'-'+monthDigit+'-'+dayDigit;
            var errorFlag = true;
            var errorMsg = '';
            
            var rateWrapperList = component.get("v.FEDEX_Services.Services");
            
            var rateWrapper = '';
            for(var x in rateWrapperList){
                if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
            }
            
            var packId = component.get("v.packageList");
            var fromAddress = component.get("v.fromAddress");
            var toAdd = component.get("v.address");
            var shipmentDate = component.get("v.shipment.ERP7__Shipment_Date__c",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
            var myConsVariable = JSON.stringify(component.get("v.myConsW"));
            if(component.get("v.shipment.ERP7__Status__c") == 'Shipped' || component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
                errorFlag = false;
                errorMsg = $A.get('$Label.c.This_Package_Has_Already_Been') + ' ' + component.get("v.shipment.ERP7__Status__c") + '.';
            }
            
            if(component.get("v.shipment.ERP7__Shipment_Date__c") < todayDate){
                errorFlag = false;
                errorMsg = errorMsg + ' ' + $A.get('$Label.c.The_Shipment_Date_Should_Not_Be_In_Past');
            }
            
            if(rateWrapper == '' || rateWrapper == null){
                errorFlag = false;
                errorMsg = errorMsg + ' ' + $A.get('$Label.c.Service_Is_Unavailable_Please_Select_At_Least_One_Service_From_Shipping_Service');
            }
            
            if(errorMsg != null || errorMsg != '') component.set("v.errorMsg1", errorMsg);
            
            if(errorFlag){
                console.log('Shipping_Request errorFlag true');
                console.log('Shipping_Request packList~>'+JSON.stringify(component.get("v.packageList")));
                console.log('Shipping_Request fromAdd~>'+fromAddress);
                console.log('Shipping_Request toAdd~>'+toAdd);
                console.log('Shipping_Request shipDate~>'+shipmentDate);
                console.log('Shipping_Request myConsVar~>'+myConsVariable);
                console.log('Shipping_Request Shipment~>'+JSON.stringify(component.get("v.shipment")));
                console.log('Shipping_Request rateWrapperSelected~>'+rateWrapper);
                
                var action = component.get("c.Shipping_Request_Reply");
                action.setParams({ 
                    "packList":component.get("v.packageList"),
                    "fromAddress":fromAddress,
                    "toAddress":toAdd,
                    "ShipDateStamp":shipmentDate,
                    "myConsVar" : myConsVariable,
                    "Shipment":JSON.stringify(component.get("v.shipment")),
                    "rateWrapperSelected": rateWrapper,
                    "isReturnShipment":false,
                    "masterShipmentId":'',
                    "returnshipment":JSON.stringify(component.get("v.returnshipment")),
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS"){
                        console.log('response.getReturnValue() : ',response.getReturnValue());
                        var obj = response.getReturnValue();
                        //console.log('Shipping_Request response~>'+JSON.stringify(obj));
                        console.log('Shipping_Request upsW.Error~>'+obj.Error);
                        component.set("v.FEDEX_Services", obj);
                        console.log('show send returl label~>'+ obj.showreturnlabel);
                        component.set("v.showSendReturnLabel", obj.showreturnlabel);
                        component.set("v.errorMsg1", obj.Error);
                        console.log(' response.getReturnValue().Shipment~>'+response.getReturnValue().Shipment);
                        component.set("v.shipment", response.getReturnValue().Shipment);
                        component.set('v.bufferlbl',response.getReturnValue().bufferLabel);
                        
                        if(obj.Shipment.ERP7__Status__c == 'Shipped'){
                            component.set("v.WrapperMsg", obj.UPSErrorMsg);
                            component.set("v.ShowTimeInCostTab",false);
                            component.set("v.ShowGetRate",false);
                            component.set("v.ShowInvoice",response.getReturnValue().showCI);
                        }
                        component.set("v.isLoading", false);
                    }else{
                        var errors = response.getError();
                        console.log("Shipping_Request server error : ", errors);
                        component.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(action);
            }else{
                console.log('Shipping_Request errorFlag false~>'+errorFlag);
                component.set("v.isLoading", false);
            }
        }catch(e){
            console.log('err '+e);
            component.set("v.isLoading", false);
        }
        
    },
    
    //Added by Arshad
    closereturnmodal : function(component, event, helper){
        component.set("v.showreturnmodal",false);
        component.set("v.errorMsg1", ''); 
    },
    
    //Added by Arshad of both ups/fedex
    getreturnshipmentrates : function(component, event, helper){
        console.log('getreturnshipmentrates called');
        component.set("v.isLoading",true);
        try{
            component.set("v.errorMsg1", ''); 
            component.set("v.exceptionError", ''); 
            var today = new Date();
            var monthDigit = today.getMonth() + 1;
            if (monthDigit <= 9) {
                monthDigit = '0' + monthDigit; 
            }
            var dayDigit = today.getDate();
            if (dayDigit <= 9) {
                dayDigit = '0' + dayDigit; 
            }        
            var todayDate = today.getFullYear()+'-'+monthDigit+'-'+dayDigit;
            var packId = component.get("v.packageList");
            var fromAddress = component.get("v.fromAddress.Id");
            var toAdd = component.get("v.address.Id");
            
            var shipmentDate = component.get("v.returnshipmentdate"); 
            var myConsVariable = JSON.stringify(component.get("v.myConsW"));
            console.log('component shipment date~>'+component.get("v.returnshipmentdate"));
            console.log('todayDate~>'+todayDate);
            console.log('shipmentDate ~>'+shipmentDate);
            var errorFlag = true;
            var errorMsg = '';
            
            if(component.get("v.address.ERP7__Postal_Code__c") == '' || component.get("v.address.ERP7__Postal_Code__c") == null) {
                errorFlag = false;
                errorMsg = $A.get('$Label.c.To_Address_Postal_Code_Unavailable');
            }
            
            if(component.get("v.address.ERP7__Country__c") == '' || component.get("v.address.ERP7__Country__c") == null) {
                errorFlag = false;
                errorMsg = errorMsg + ' ' + $A.get('$Label.c.To_Address_Country_Unavailable');
            }
            
            if(component.get("v.fromAddress.ERP7__Postal_Code__c") == '' || component.get("v.fromAddress.ERP7__Postal_Code__c") == null) {
                errorFlag = false;
                errorMsg = errorMsg + ' ' + $A.get('$Label.c.From_Address_Postal_Code_Unavailable');
            }
            
            if(component.get("v.fromAddress.ERP7__Country__c") == '' || component.get("v.fromAddress.ERP7__Country__c") == null) {
                errorFlag = false;
                errorMsg = errorMsg + ' ' + $A.get('$Label.c.From_Address_Country_Unavailable');
            }
            
            /*if(component.get("v.shipment.ERP7__Status__c") == 'Shipped' || component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + 'This Package Has Already Been ' + component.get("v.shipment.ERP7__Status__c") + '.';
        }*/
            
            if(shipmentDate == null || shipmentDate == '' || shipmentDate == undefined){
                component.set("v.returnshipmentdate",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
                shipmentDate = component.get("v.returnshipmentdate"); 
            }
            
            if(component.get("v.returnshipmentdate") < todayDate){
                component.set("v.returnshipmentdate",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
                shipmentDate = component.get("v.returnshipmentdate"); 
                // errorFlag = false;
                // errorMsg = errorMsg + ' ' + 'The Shipment Date Should Not Be In Past.';
            }
            
            if(errorMsg != null || errorMsg != '') component.set("v.exceptionError", errorMsg);
            
            if(errorFlag){
                console.log('errorFlag is true');
                component.set("v.exceptionError", '');
                var action = component.get("c.Shipping_Rate_Request");
                action.setParams({
                    "packList":component.get("v.packageList"),
                    "fromAdd":toAdd,
                    "tAddress":fromAddress,
                    "shipDate":shipmentDate,
                    "myConsVar": myConsVariable,
                    "isReturnShipment":true,
                });
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        try{
                            var obj = response.getReturnValue();
                            console.log('getreturnshipmentrates response~>',obj);
                            console.log('getreturnshipmentrates upsW.Error~>'+obj.Error);
                            if(response.getReturnValue().Services != undefined && response.getReturnValue().Services != null){
                                component.set("v.FEDEX_Services.Services", response.getReturnValue().Services);
                            }
                            component.set("v.showreturnmodal", true);
                            
                            console.log('Fedex services in getrates~>'+JSON.stringify(obj));
                            var rateWrapperList = component.get("v.FEDEX_Services.Services");
                            if(rateWrapperList != undefined && rateWrapperList != null){
                                if(rateWrapperList.length > 0){
                                    var subString = 'GROUND';
                                    for(var x in rateWrapperList){
                                        if(rateWrapperList[x].Service != undefined && rateWrapperList[x].Service != null && rateWrapperList[x].Service != ''){
                                            if(rateWrapperList[x].Service.toLowerCase().includes(subString.toLowerCase())){
                                                rateWrapperList[x].Selected = true;
                                                break;
                                            }
                                        }
                                    }
                                    component.set("v.FEDEX_Services.Services",rateWrapperList);
                                }
                            }
                            component.set("v.exceptionError", obj.Error);
                            
                            //allowUPSReturnShipmentFromFedEx starts - Added by Arshad 26 Sep 2023 
                            console.log('selectedLogisticReturnShipType~>'+component.get("v.selectedLogisticReturnShipType"));
                            if(component.get("v.allowUPSReturnShipmentFromFedEx") && (component.get("v.selectedLogisticReturnShipType") == 'UPS' || component.get("v.selectedLogisticReturnShipType") == '')){
                                console.log('getting UPS services for return shipment');
                                
                                var UPSaction1 = component.get("c.getUPSmyConstruct");
                                
                                var sId = ''; 
                                if(component.get("v.shipment") != undefined && component.get("v.shipment") != null){
                                    if(component.get("v.shipment.Id") != undefined && component.get("v.shipment.Id") != null){
                                        sId = component.get("v.shipment.Id");
                                    }
                                }
                                console.log('sId~>'+sId);
                                
                                UPSaction1.setParams({ 
                                    "shipId":sId,
                                });
                                console.log('inhere1');
                                UPSaction1.setCallback(this, function(resp1) {
                                    console.log('stop lagging 1');
                                    setTimeout(function(){ console.log('stop lagging 2'); }, 1000);
                                    if (resp1.getState() === "SUCCESS"){
                                        var obj = resp1.getReturnValue();
                                        if(obj != null){
                                            var wrError = response.getReturnValue().wrapError;
                                            if(wrError != null && wrError != '' && wrError != undefined) component.set("v.errorMsg1", wrError);
                                            component.set("v.UpsmyConsW", obj);
                                            
                                            if(sId != ''){
                                                component.set("v.UPS_Services", obj.uWrap);
                                                
                                                var UPSmyConsVariable = JSON.stringify(component.get("v.UpsmyConsW"));
                                                console.log('UPSmyConsVariable~>',UPSmyConsVariable);
                                                
                                                var UPSaction2 = component.get("c.getUpsServicesWrapperList");
                                                console.log('inhere4');
                                                UPSaction2.setParams({
                                                    "packList":component.get("v.packageList"),
                                                    "fromAdd":toAdd,
                                                    "toAdd":fromAddress, 
                                                    "shipDate":shipmentDate, 
                                                    "myConsVar": UPSmyConsVariable,  
                                                    "Shipment":JSON.stringify(component.get("v.shipment")),
                                                    "isReturnShipment":true,
                                                });
                                                console.log('inhere5');
                                                UPSaction2.setCallback(this, function(resp2){
                                                    console.log('stop lagging 3');
                                                    setTimeout(function(){ console.log('stop lagging 4'); }, 1000);
                                                    if (resp2.getState() === "SUCCESS"){
                                                        var obj = resp2.getReturnValue();
                                                        console.log('getreturnshipmentrates response~>',obj);
                                                        console.log('getreturnshipmentrates upsW.Error~>'+obj.Error);
                                                        if(resp2.getReturnValue().Services != undefined && resp2.getReturnValue().Services != null){
                                                            component.set("v.UPS_Services.Services", resp2.getReturnValue().Services);
                                                        }
                                                        
                                                        var rateWrapperList = component.get("v.UPS_Services.Services");
                                                        if(rateWrapperList != undefined && rateWrapperList != null){
                                                            if(rateWrapperList.length > 0){
                                                                var subString = 'Ground';
                                                                for(var x in rateWrapperList){
                                                                    if(rateWrapperList[x].Service != undefined && rateWrapperList[x].Service != null && rateWrapperList[x].Service != ''){
                                                                        if(rateWrapperList[x].Service.toLowerCase().includes(subString.toLowerCase())){
                                                                            console.log('UPS Ground exists');
                                                                            rateWrapperList[x].Selected = true;
                                                                            break;
                                                                        }
                                                                    }
                                                                }
                                                                component.set("v.UPS_Services.Services",rateWrapperList);
                                                            }
                                                        }
                                                        component.set("v.exceptionError", obj.Error);
                                                        component.set("v.isLoading", false);
                                                    }
                                                    else{
                                                        var errors = resp2.getError();
                                                        console.log("getFedexServicesWrapperList server error : ", errors);
                                                        component.set("v.isLoading", false);
                                                    }
                                                });
                                                console.log('inhere6');
                                                $A.enqueueAction(UPSaction2);
                                                console.log('inhere7');
                                            }
                                            else{
                                                console.log('shipid null here');
                                                component.set("v.isLoading", false);
                                            }
                                        }
                                        else{
                                            console.log('obj null here');
                                            component.set("v.isLoading", false);
                                        }
                                    }
                                    else{
                                        var errors = resp1.getError();
                                        console.log("UPSaction1 server error : ", errors);
                                    }
                                });
                                console.log('inhere2');
                                $A.enqueueAction(UPSaction1);
                                console.log('inhere3');
                            }
                            else{
                                console.log('allowUPSReturnShipmentFromFedEx false');
                                component.set("v.isLoading", false);
                            }
                            //allowUPSReturnShipmentFromFedEx ends
                            
                        }catch(e){
                            console.log('errs here~>'+e);
                            component.set("v.isLoading", false);
                        }
                    }
                    else{
                        var errors = response.getError();
                        console.log("getreturnshipmentrates server error : ", errors);
                        component.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                console.log('getreturnshipmentrates errorFlag false~>'+errorFlag);    
                component.set("v.isLoading", false);
            }
        }catch(e){
            console.log('errs~>'+e);
            component.set("v.isLoading", false);
        }
        //setTimeout(function(){component.set("v.isLoading", false);}, 4000);
    },
    
    //Added by Arshad
    generateReturnShipment : function(component, event, helper){
        console.log('generateReturnShipment called');
        component.set("v.isLoading",true);
        component.set("v.exceptionError", '');
        component.set("v.errorMsg1", '');
        component.set("v.FEDEX_Services.UPSErrorMsg", '');
        component.set("v.WrapperMsg", '');
        component.set("v.errorMsg1", ''); 
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit; 
        }
        var dayDigit = today.getDate();
        if (dayDigit <= 9) {
            dayDigit = '0' + dayDigit; 
        }        
        var todayDate = today.getFullYear()+'-'+monthDigit+'-'+dayDigit;
        var errorFlag = true;
        var errorMsg = '';
        
        var rateWrapperList = component.get("v.FEDEX_Services.Services");
        
        var rateWrapperListBool = true;
        
        var rateWrapper = '';
        
        if(rateWrapperList != undefined && rateWrapperList != null){
            if(rateWrapperList.length > 0){
                for(var x in rateWrapperList){
                    if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
                }
            }else rateWrapperListBool = false;
        }else rateWrapperListBool = false;
        
        var packId = component.get("v.packageList");
        var fromAddress = component.get("v.fromAddress");
        var toAdd = component.get("v.address");
        var shipmentDate = component.get("v.returnshipmentdate"); //,today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        /*if(component.get("v.shipment.ERP7__Status__c") == 'Shipped' || component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = 'This Package Has Already Been ' + component.get("v.shipment.ERP7__Status__c") + '.';
        }*/
        
        if(component.get("v.returnshipmentdate") < todayDate){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.The_Shipment_Date_Should_Not_Be_In_Past');
        }
        
        if(rateWrapper == '' || rateWrapper == null){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.Please_Select_At_Least_One_Service_From_Shipping_Service_And_Cost');
        }
        
        if(rateWrapperListBool == false){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.Services_is_Unavailable_Please_try_again_later');
        }
        
        if(errorMsg != null || errorMsg != '') component.set("v.exceptionError", errorMsg);
        
        if(errorFlag){
            console.log('generateReturnShipment errorFlag true');
            console.log('generateReturnShipment packList~>'+JSON.stringify(component.get("v.packageList")));
            console.log('generateReturnShipment fromAdd~>'+fromAddress);
            console.log('generateReturnShipment toAdd~>'+toAdd);
            console.log('generateReturnShipment shipDate~>'+shipmentDate);
            console.log('generateReturnShipment myConsVar~>'+myConsVariable);
            console.log('generateReturnShipment Shipment~>'+JSON.stringify(component.get("v.shipment")));
            console.log('generateReturnShipment returnshipment~>'+JSON.stringify(component.get("v.returnshipment")));
            console.log('generateReturnShipment rateWrapperSelected~>'+rateWrapper);
            var masterShipmentId = '';
            if(!$A.util.isEmpty(component.get("v.shipment")) && !$A.util.isUndefinedOrNull(component.get("v.shipment"))){
                if(!$A.util.isEmpty(component.get("v.shipment.Id")) && !$A.util.isUndefinedOrNull(component.get("v.shipment.Id"))){
                    masterShipmentId = component.get("v.shipment.Id");
                }
            }
            console.log('masterShipmentId~>'+masterShipmentId);
            
            var action = component.get("c.Shipping_Request_Reply");
            action.setParams({ 
                "packList":component.get("v.packageList"),
                "fromAddress":toAdd,
                "toAddress":fromAddress,
                "ShipDateStamp":shipmentDate,
                "myConsVar" : myConsVariable,
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "rateWrapperSelected": rateWrapper,
                "isReturnShipment":true,
                "masterShipmentId":masterShipmentId,
                "returnshipment":JSON.stringify(component.get("v.returnshipment")),
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS"){
                    var obj = response.getReturnValue();
                    console.log('generateReturnShipment response~>',obj);
                    console.log('generateReturnShipment upsW.Error~>'+obj.Error);
                    //component.set("v.FEDEX_Services", obj);
                    //console.log('show send returl label~>'+ obj.showreturnlabel);
                    //component.set("v.showSendReturnLabel", obj.showreturnlabel);
                    component.set("v.exceptionError", obj.Error);
                    if(obj.Error == ''){
                        component.set("v.returnshipment", response.getReturnValue().Shipment);
                        component.set("v.showreturnmodal", false);
                    }
                    //component.set('v.bufferlbl',response.getReturnValue().bufferLabel);
                    /*if(obj.Shipment.ERP7__Status__c == 'Shipped'){
                        component.set("v.WrapperMsg", obj.UPSErrorMsg);
                        component.set("v.ShowTimeInCostTab",false);
                        component.set("v.ShowGetRate",false);
                    }*/
                }else{
                    var errors = response.getError();
                    console.log("generateReturnShipment server error : ", errors);
                }
            });
            $A.enqueueAction(action);
        }else{
            console.log('generateReturnShipment errorFlag false~>'+errorFlag);
        }
        setTimeout(function(){component.set("v.isLoading", false);}, 4000);
    },
    
    //Added by Arshad 26 Sep 2023
    generateUPSReturnShipmentFromFedEx :function(component, event, helper){
        try{
            console.log('generateUPSReturnShipmentFromFedEx called');
            component.set("v.isLoading",true);
            component.set("v.exceptionError", '');
            component.set("v.errorMsg1", '');
            component.set("v.WrapperMsg", '');
            component.set("v.errorMsg1", ''); 
            var today = new Date();
            var monthDigit = today.getMonth() + 1;
            if (monthDigit <= 9) {
                monthDigit = '0' + monthDigit; 
            }
            var dayDigit = today.getDate();
            if (dayDigit <= 9) {
                dayDigit = '0' + dayDigit; 
            }        
            var todayDate = today.getFullYear()+'-'+monthDigit+'-'+dayDigit;
            var errorFlag = true;
            var errorMsg = '';
            
            var rateWrapperList = component.get("v.UPS_Services.Services");
            
            var rateWrapperListBool = true;
            
            var rateWrapper = '';
            
            if(rateWrapperList != undefined && rateWrapperList != null){
                if(rateWrapperList.length > 0){
                    for(var x in rateWrapperList){
                        if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
                    }
                }else rateWrapperListBool = false;
            }else rateWrapperListBool = false;
            
            var packId = component.get("v.packageList");
            var fromAddress = component.get("v.fromAddress.Id");
            var toAdd = component.get("v.address.Id");
            var shipmentDate = component.get("v.returnshipmentdate"); //,today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
            var myConsVariable = JSON.stringify(component.get("v.UpsmyConsW"));
            /*if(component.get("v.shipment.ERP7__Status__c") == 'Shipped' || component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = 'This Package Has Already Been ' + component.get("v.shipment.ERP7__Status__c") + '.';
        }*/
            
            if(component.get("v.returnshipmentdate") < todayDate){
                errorFlag = false;
                errorMsg = $A.get('$Label.c.The_Shipment_Date_Should_Not_Be_In_Past');
            }
            
            if(rateWrapper == '' || rateWrapper == null){
                errorFlag = false;
                errorMsg = $A.get('$Label.c.Please_Select_At_Least_One_Service_From_Shipping_Service_And_Cost');
            }
            
            if(rateWrapperListBool == false){
                errorFlag = false;
                errorMsg = $A.get('$Label.c.Services_is_Unavailable_Please_try_again_later');
            }
            
            if(errorMsg != null || errorMsg != '') component.set("v.exceptionError", errorMsg);
            
            if(errorFlag){
                console.log('generateUPSReturnShipmentFromFedEx errorFlag true');
                console.log('generateUPSReturnShipmentFromFedEx packList~>'+JSON.stringify(component.get("v.packageList")));
                console.log('generateUPSReturnShipmentFromFedEx fromAdd~>'+fromAddress);
                console.log('generateUPSReturnShipmentFromFedEx toAdd~>'+toAdd);
                console.log('generateUPSReturnShipmentFromFedEx shipDate~>'+shipmentDate);
                console.log('generateUPSReturnShipmentFromFedEx myConsVar~>'+myConsVariable);
                console.log('generateUPSReturnShipmentFromFedEx Shipment~>'+JSON.stringify(component.get("v.shipment")));
                console.log('generateUPSReturnShipmentFromFedEx returnshipment~>'+JSON.stringify(component.get("v.returnshipment")));
                console.log('generateUPSReturnShipmentFromFedEx rateWrapperSelected~>'+rateWrapper);
                var masterShipmentId = '';
                if(!$A.util.isEmpty(component.get("v.shipment")) && !$A.util.isUndefinedOrNull(component.get("v.shipment"))){
                    if(!$A.util.isEmpty(component.get("v.shipment.Id")) && !$A.util.isUndefinedOrNull(component.get("v.shipment.Id"))){
                        masterShipmentId = component.get("v.shipment.Id");
                    }
                }
                console.log('masterShipmentId~>'+masterShipmentId);
                
                var action = component.get("c.generateUpsShipment");
                action.setParams({
                    "packList":packId,
                    "fromAdd":toAdd,
                    "toAdd":fromAddress, 
                    "shipDate":shipmentDate, 
                    "myConsVar": myConsVariable,
                    "Shipment":JSON.stringify(component.get("v.shipment")),
                    "rateWrapperSelected": rateWrapper,
                    "toShipType":false, //component.get("v.fromShipmentType"),
                    "frShipType":false, //component.get("v.toShipmentType"),
                    "isReturnShipment":true,
                    "masterShipmentId":masterShipmentId,
                    "returnshipment":JSON.stringify(component.get("v.returnshipment")),
                });
                
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS"){
                        var obj = response.getReturnValue();
                        console.log('generateUPSReturnShipmentFromFedEx response~>',obj);
                        console.log('generateUPSReturnShipmentFromFedEx upsW.Error~>'+obj.Error);
                        //component.set("v.FEDEX_Services", obj);
                        //console.log('show send returl label~>'+ obj.showreturnlabel);
                        //component.set("v.showSendReturnLabel", obj.showreturnlabel);
                        component.set("v.exceptionError", obj.Error);
                        if(obj.Error == ''){
                            component.set("v.returnshipment", response.getReturnValue().Shipment);
                            component.set("v.showreturnmodal", false);
                        }
                        //component.set('v.bufferlbl',response.getReturnValue().bufferLabel);
                        /*if(obj.Shipment.ERP7__Status__c == 'Shipped'){
                        component.set("v.WrapperMsg", obj.UPSErrorMsg);
                        component.set("v.ShowTimeInCostTab",false);
                        component.set("v.ShowGetRate",false);
                    }*/
                        component.set("v.isLoading", false);
                    }else{
                        var errors = response.getError();
                        console.log("generateUPSReturnShipmentFromFedEx server error : ", errors);
                        component.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(action);
            }else{
                console.log('generateUPSReturnShipmentFromFedEx errorFlag false~>'+errorFlag);
                component.set("v.isLoading", false);
            }
        }catch(e){
            console.log('generateUPSReturnShipmentFromFedEx errs~>'+e);
            component.set("v.isLoading", false);
        }
    },
    
    //only fedex label to be viewed with print option in init/ no print option if international fedex 
    CreateFedexLabel : function(component, event,helper) {
        console.log('CreateFedexLabel called');
        var shipmentsId = component.get("v.shipment.Id");
        var fileName = 'Fedex_Label';
        var val = 'pdf';
        
        var showIframe = false;
        var fromAddress = component.get("v.fromAddress.ERP7__Country__c");
        var toAddress = component.get("v.address.ERP7__Country__c");
        console.log('fromAddress~>'+fromAddress);
        console.log('toAddress~>'+toAddress);
        
        if(fromAddress != toAddress){
            val = 'nopdf';
            showIframe = true;
        }
        
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '';
            if(fromAddress != toAddress) viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&val='+val+'&showframe='+showIframe;
            else viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&val='+val;
            window.open(viewLabel,'_blank');
        }
    },
    
    CreateInvoice : function(component, event,helper) {
        var shipmentsId = component.get("v.shipment.Id");
        var fileName = 'Fedex_Commercial_Invoice';
        var val = 'nopdf';
        var showIframe = true;
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&val='+val+'&showframe='+showIframe;
            window.open(viewLabel,'_blank');
        }
    },
    
    //Added by Arshad //isforRMA
    SendReturnLabel : function(component, event,helper){
        console.log('SendReturnLabel called');
        var shipmentsId = component.get("v.shipment.Id"); 
        var fileName = 'Fedex_Label';
        var val = 'pdf';
        var shiptype = 'return';
        var contactId = '';
        if(component.get("v.address.ERP7__Contact__c") != undefined && component.get("v.address.ERP7__Contact__c") != null){
            if(component.get("v.address.ERP7__Contact__c") != ''){
                contactId = component.get("v.address.ERP7__Contact__c");
            }
        }
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&contactId='+contactId+'&shiptype='+shiptype;//+'&val='+val;
            window.open(viewLabel,'_blank');
        }
    },
    
    //Added by Arshad  //Fedex or UPS label to be viewed with print option in init //no print option init if international only if fedex
    CreateFedexReturnLabel : function(component, event,helper) {
        console.log('CreateFedexReturnLabel called');
        var shipmentsId = component.get("v.returnshipment.Id");
        var fileName = 'Fedex_Label';
        var val = 'pdf';
        var shiptype = 'return';
        
        var showIframe = false;
        var fromAddress = component.get("v.fromAddress.ERP7__Country__c");
        var toAddress = component.get("v.address.ERP7__Country__c");
        console.log('fromAddress~>'+fromAddress);
        console.log('toAddress~>'+toAddress);
        
        if(fromAddress != toAddress){
            val = 'nopdf';
            showIframe = true;
        }
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '';
            if(fromAddress != toAddress) viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&val='+val+'&shiptype='+shiptype+'&showframe='+showIframe;
            else viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&val='+val+'&shiptype='+shiptype;
            window.open(viewLabel,'_blank');
        }
    },
    
    //Added by Arshad ////Fedex or UPS label with no print option init for both
    SendReturnReturnLabel : function(component, event,helper){
        console.log('SendReturnReturnLabel called');
        var shipmentsId = component.get("v.returnshipment.Id"); 
        var fileName = 'Fedex_Label';
        var val = 'pdf';
        var shiptype = 'return';
        var contactId = '';
        if(component.get("v.address.ERP7__Contact__c") != undefined && component.get("v.address.ERP7__Contact__c") != null){
            if(component.get("v.address.ERP7__Contact__c") != ''){
                contactId = component.get("v.address.ERP7__Contact__c");
            }
        }
        
        var showIframe = false;
        var fromAddress = component.get("v.fromAddress.ERP7__Country__c");
        var toAddress = component.get("v.address.ERP7__Country__c");
        console.log('fromAddress~>'+fromAddress);
        console.log('toAddress~>'+toAddress);
        
        if(fromAddress != toAddress){
            val = 'nopdf';
            showIframe = true;
        }
        
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '';
            if(fromAddress != toAddress) viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&contactId='+contactId+'&shiptype='+shiptype+'&showframe='+showIframe;
            else viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&contactId='+contactId+'&shiptype='+shiptype;
            window.open(viewLabel,'_blank');
        }
    },
    
    Cancel_Request: function(component, event,helper) {
        component.set("v.isLoading", true);
        console.log('Cancel_Request Called');
        component.set("v.errorMsg1", '');
        component.set("v.FEDEX_Services.UPSErrorMsg", '');
        
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        
        var shipments = component.get("v.shipment");
        console.log('shipment in cancel~>'+JSON.stringify(shipments));
        
        var packId = component.get("v.packageList");
        var shipmentDate = component.get("v.shipment.ERP7__Shipment_Date__c",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        var errorFlag = true;
        var errorMsg = '';
        
        if($A.util.isEmpty(component.get("v.shipment.ERP7__Status__c")) || $A.util.isUndefinedOrNull(component.get("v.shipment.ERP7__Status__c"))){   
            errorFlag = false;
            errorMsg = $A.get('$Label.c.The_Shipment_Is_Unavailable');
        }
        console.log('here 4');
        if(component.get("v.shipment.ERP7__Status__c") != 'Shipped'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Request_To_Cancel_Shipment_Cannot_Be_Processed');
        }
        console.log('here 5');
        if(component.get("v.shipment.Pickup_Requested__c") == true){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Shipment_Pickup_Is_Active_Thus_Request_To_Cancel_The_Shipment_Cannot_Be_Process');
        }
        console.log('here 6');
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg1", errorMsg);
        console.log('here 7');
        if(errorFlag){
            console.log('error flag true');
            var action = component.get("c.Cancel_Request_Reply");
            action.setParams({ 
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "packList":packId,
                "TimeStamp":shipmentDate,
                "myConsVar" : myConsVariable
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var obj = response.getReturnValue();
                    console.log('Cancel request In success~>'+JSON.stringify(obj));
                    component.set("v.FEDEX_Services", obj);
                    console.log('Cancel request Error~>'+obj.Error);
                    component.set("v.errorMsg1", obj.Error);
                    component.set("v.errorMsg", obj.Error);
                    console.log('Cancel request UPSErrorMsg~>'+obj.UPSErrorMsg);
                    if(response.getReturnValue().UPSErrorMsg == 'Shipment deleted successfully'){
                        component.set("v.shipment", response.getReturnValue().Shipment);
                        component.set("v.ShowGetRate",true);
                        component.set("v.WrapperMsg",response.getReturnValue().UPSErrorMsg);
                    }
                } 
            }); 
            $A.enqueueAction(action);
        }else{
            console.log('Cancel_Request no errorFlag false');
        }
        setTimeout(function(){component.set("v.isLoading", false);}, 3000);
    },
    
    PickupAvailability : function(component, event,helper) {
        component.set("v.errorMsg", '');
        component.set("v.FEDEX_Services.UPSErrorMsg", '');
        
        var fromAddress = component.get("v.fromAddress.Id");
        var packId = component.get("v.packageList");
        var shipments = component.get("v.shipment");
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        var errorFlag = true;
        var errorMsg = '';
        
        if(component.get("v.shipment.ERP7__Pickup_Requested__c") == true){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.Shipment_Pickup_Is_Already_Active_For_This_Package');
        }
        
        if(component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Shipment_Delivered_Request_Cannot_Be_Processed');
        }
        
        if(component.get("v.shipment.ERP7__Status__c") != 'Shipped'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Shipment_Status_Must_Be_shipped_To_Process_Pickup_Rate_Request');
        }
        
        if(component.get("v.shipment.ERP7__Package_Ready_Time__c") == null || component.get("v.shipment.ERP7__Package_Ready_Time__c") == ''){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Pickup_Ready_Time_Unavailable');
        }
        
        if(component.get("v.shipment.ERP7__Customer_Close_Time__c") == null || component.get("v.shipment.ERP7__Customer_Close_Time__c") == ''){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Pickup_Close_Time_Unavailable');
        }
        
        if(component.get("v.shipment.ERP7__Customer_Close_Time__c") != component.get("v.shipment.ERP7__Package_Ready_Time__c")){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Pickup_Ready_Time_And_Pickup_Close_Time_Must_Be_Same');
        } 
        
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg", errorMsg);
        
        if(errorFlag){
            //alert('No Errors');
            var action = component.get("c.PickupAvailability_Reply");
            action.setParams({
                "fromAdd":fromAddress,
                "packList":packId, 
                "Shipment":JSON.stringify(component.get("v.shipment")), 
                "dispatchDate":component.get("v.shipment.ERP7__Package_Ready_Time__c"),
                "PackageReadyTime":component.get("v.shipment.ERP7__Package_Ready_Time__c"),
                "CustomerCloseTime":component.get("v.shipment.ERP7__Customer_Close_Time__c"),
                "fromShipmentType":component.get("v.fromShipmentType"),
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS"){
                    component.set("v.FEDEX_Services", res);
                    component.set("v.errorMsg", res.Error);
                    component.set("v.ShowGetRate",false);
                }
                else{
                    console.log('Error : '+response.getError());
                }
            }); 
            $A.enqueueAction(action);
        }
    },
    
    CreatePickup : function(component, event,helper) {
        component.set("v.errorMsg", '');
        component.set("v.FEDEX_Services.UPSErrorMsg", '');
        
        var fromAddress = component.get("v.fromAddress.Id");
        var packId = component.get("v.packageList");
        var shipments = component.get("v.shipment");
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        var errorFlag = true;
        var errorMsg = '';
        
        if(component.get("v.shipment.ERP7__Pickup_Requested__c") == true){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.Shipment_Pickup_Is_Already_Active_For_This_Package');
        }
        
        if(component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Shipment_Delivered_Request_Cannot_Be_Processed');
        }
        
        if(component.get("v.shipment.ERP7__Status__c") != 'Shipped'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Shipment_Status_Must_Be_shipped_To_Process_Pickup_Rate_Request');
        }
        
        if(component.get("v.shipment.ERP7__Package_Ready_Time__c") == null || component.get("v.shipment.ERP7__Package_Ready_Time__c") == ''){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Pickup_Ready_Time_Unavailable');
        }
        
        if(component.get("v.shipment.ERP7__Customer_Close_Time__c") == null || component.get("v.shipment.ERP7__Customer_Close_Time__c") == ''){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Pickup_Close_Time_Unavailable');
        }
        
        if(component.get("v.shipment.ERP7__Customer_Close_Time__c") != component.get("v.shipment.ERP7__Package_Ready_Time__c")){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Pickup_Ready_Time_And_Pickup_Close_Time_Must_Be_Same');
        } 
        
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg", errorMsg);
        
        if(errorFlag){
            var action = component.get("c.CreatePickup_Reply");
            action.setParams({
                "fromAdd":fromAddress,
                "packList":packId,
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "PackageReadyTime":component.get("v.shipment.ERP7__Package_Ready_Time__c"),
                "CustomerCloseTime":component.get("v.shipment.ERP7__Customer_Close_Time__c"),
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var res = response.getReturnValue();
                    component.set("v.FEDEX_Services", res);
                    component.set("v.errorMsg", res.Error);
                    component.set("v.shipment", response.getReturnValue().Shipment);
                    component.set("v.ShowGetRate",false);
                }else{
                    console.log('Err : '+JSON.stringify(response.getError()));
                }
            }); 
            $A.enqueueAction(action);
        }
    },
    
    CancelPickup : function(component, event,helper) {
        component.set("v.errorMsg", '');
        component.set("v.FEDEX_Services.UPSErrorMsg", '');
        
        var packId = component.get("v.packageList");
        var dispatchDate = component.get("v.shipment.ERP7__Package_Ready_Time__c");
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        var errorFlag = true;
        var errorMsg = '';
        
        if(component.get("v.shipment.ERP7__Pickup_Requested__c") == false){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.Shipment_Pickup_Unavailable_To_Cancel');
        }
        
        if(component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Shipment_Delivered_Request_Cannot_Be_Processed');
        }
        
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg", errorMsg);
        
        if(errorFlag){
            var action = component.get("c.CancelPickup_Reply");
            action.setParams({ 
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "packList":packId, 
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS") {
                    component.set("v.FEDEX_Services", res);
                    component.set("v.errorMsg", res.Error);
                    component.set("v.shipment", response.getReturnValue().Shipment);
                    component.set("v.ShowGetRate",false);
                } 
            }); 
            $A.enqueueAction(action);
        }
    },
    
    Track_Request : function(component, event,helper) {
        component.set("v.errorMsg", '');
        component.set("v.FEDEX_Services.UPSErrorMsg", '');
        
        var packId = component.get("v.packageList");
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        var errorFlag = true;
        var errorMsg = '';
        
        if(component.get("v.shipment.ERP7__Status__c") != 'Shipped'){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.Request_To_Track_The_Shipment_Cannot_Be_Processed');
        }
        
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg", errorMsg);
        if(errorFlag){
            component.set('v.Spinner',true);
            var action = component.get("c.Track_Request_Reply");
            action.setParams({ 
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "packList":packId, 
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS") {
                    component.set("v.FEDEX_Services", res);
                    component.set("v.errorMsg", res.Error);
                    component.set("v.ShowGetRate",false);
                    component.set('v.Spinner',false);
                }
                else{
                    component.set('v.Spinner',false);
                    console.log('Error : '+response.getError());
                    component.set("v.errorMsg", 'Error Occurred');
                }
            }); 
            $A.enqueueAction(action);
        } 
    },
    
    Signature_Proof : function(component, event,helper) {
        component.set("v.errorMsg", '');
        component.set("v.FEDEX_Services.UPSErrorMsg", '');
        
        var toAdd = component.get("v.address");
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        var errorFlag = true;
        var errorMsg = '';
        
        if(component.get("v.shipment.ERP7__Status__c") != 'Delivered'){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.Request_To_Get_Signature_Proof_Of_Delivery_For_This_Shipment_Cannot_Be_Processed');
        }
        
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg", errorMsg);
        
        if(errorFlag){
            var action = component.get("c.Signature_Proof_Reply ");
            action.setParams({ 
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "toAddress":toAdd,
                "myConsVar" : myConsVariable
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS") {
                    component.set("v.FEDEX_Services", res);
                    component.set("v.errorMsg", res.Error);
                    component.set("v.spodLetter",response.getReturnValue().spodLetter);
                    component.set("v.ShowGetRate",false);
                } 
            });  
            $A.enqueueAction(action);
        }
    },
    
    SelectAttachment : function(component, event, helper) {
        var spod = component.get("v.FEDEX_Services.spodLetter");
        component.set("v.spodLetter",spod);
        var urlAtt = '/servlet/servlet.FileDownload?file='+spod;
        //component.set("v.attUrl", urlAtt);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    sectionOne : function(component, event, helper) {
        helper.helperFun(component,event,'articleOne');
    },
    
    sectionTwo : function(component, event, helper) {
        helper.helperFun(component,event,'articleTwo');
    },
    
    sectionThree : function(component, event, helper) {
        helper.helperFun(component,event,'articleThree');
    },
    
    sectionFour : function(component, event, helper) {
        helper.helperFun(component,event,'articleFour');
    },
    
    CreateFedexbuffer : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/servlet/servlet.FileDownload?file=00P0600002X4MlsEAF"
        });
        urlEvent.fire();
    },
    
    toadresschange : function(component, event, helper) {
        var paId = component.get("v.packageId");
        var addressID = component.get("v.address.Id");
        var toAddaction = component.get("c.fetchAddresschange");
        if(addressID != null && addressID != '' && addressID != undefined){
            toAddaction.setParams({addId:addressID});
            toAddaction.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var obj = response.getReturnValue();
                    console.log('toaddress obj~>'+JSON.stringify(obj));
                    component.set("v.address", obj);
                }else{
                    var errors = response.getError();
                    console.log("fetchFromAddress server error : ", errors);
                }
            });
            $A.enqueueAction(toAddaction);
        }
    },
    
    fromAddresschange : function(component, event, helper) {
        var paId = component.get("v.packageId");
        var addressID = component.get("v.fromAddress.Id");
        if(addressID != null && addressID != '' && addressID != undefined){
            var fromAddaction = component.get("c.fetchAddresschange");
            fromAddaction.setParams({addId:addressID});
            fromAddaction.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var obj = response.getReturnValue();
                    console.log('fromAddress obj~>'+JSON.stringify(obj));
                    component.set("v.fromAddress", obj);
                }else{
                    var errors = response.getError();
                    console.log("fetchFromAddress server error : ", errors);
                }
            });
            $A.enqueueAction(fromAddaction);
        }
        
    },
    
    callOnAddressAPI : function(component, event, helper) {
        console.log('address validation called');
        var r = confirm('Do you want to verify the Shipping address?'); 
        console.log('r : ',r);
        if (r == true) {
            var paId = component.get("v.packageId");
            var myConsVariable = JSON.stringify(component.get("v.myConsW"));
            var addressID = component.get("v.address.Id");
            var fromAddaction = component.get("c.ValidateAddress");
            fromAddaction.setParams({"addId":addressID,"myConsVar": myConsVariable});
            fromAddaction.setCallback(this, function(response){
                console.log('ValidateAddress : ',response.getState());
                if(response.getState() === "SUCCESS"){
                    var obj = response.getReturnValue();
                    console.log('fromAddress obj~>',response.getReturnValue());
                    var addres = response.getReturnValue().Street +',' + response.getReturnValue().City + ',' + response.getReturnValue().StateOrProvinceCode + ',' + response.getReturnValue().CountryCode + ',' + response.getReturnValue().PostalCode ; 
                    component.set("v.SuggestedAddress", addres);
                    component.set("v.displayModal", true);
                }else{
                    var errors = response.getError();
                    console.log("fetchFromAddress server error : ", errors);
                }
            });
            $A.enqueueAction(fromAddaction);
        }
    },
    
    yesBtn : function(component, event, helper) {
        var fromAddaction = component.get("c.updateshipAddress");
        let shipaddress = component.get("v.address");
        var suggestedAdd = component.get("v.SuggestedAddress").split(',');
        console.log('suggestedAdd : ',suggestedAdd);
        shipaddress.ERP7__Address_Line1__c = suggestedAdd[0];
        shipaddress.ERP7__City__c = suggestedAdd[1];
        shipaddress.ERP7__State__c = suggestedAdd[2];
        shipaddress.ERP7__Country__c = suggestedAdd[3];
        shipaddress.ERP7__Postal_Code__c = suggestedAdd[4];
        
        var addressID = component.get("v.address.Id");
        fromAddaction.setParams({"addId":shipaddress});
        fromAddaction.setCallback(this, function(response){
            console.log('update : ',response.getState());
            if(response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                console.log('updateshipAddress obj~>',response.getReturnValue());
                component.set("v.address", response.getReturnValue());
                component.set("v.displayModal", false);
                
            }else{
                var errors = response.getError();
                console.log("updateshipAddress server error : ", errors);
            }
        });
        $A.enqueueAction(fromAddaction);
    },
    
    closeBtn :function(component, event, helper) {
        component.set("v.displayModal", false);
    }
})