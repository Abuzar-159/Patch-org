({ 
    doInit : function(component, event, helper){   
        component.set("v.isLoading",true);
        var shipID = component.get("v.shipmentId");
        console.log('doInit called shipID~>'+shipID);
        console.log('doInit called packageId~>'+component.get("v.packageId"));
        
        helper.doInitHandler(component, event, helper);
        
        if(shipID == null || shipID == '' || shipID == 'undefined' || shipID == undefined){
            //Added by Arshad 31 Jan 2024
            var paId = component.get("v.packageId");
            if(!$A.util.isEmpty(paId) && !$A.util.isUndefinedOrNull(paId)){
                helper.initHelperActions(component, event, helper, paId);
            }
        }
        
        /* For Picklists*/ 
        var billingOptionsAction = component.get("c.getBillingOptions");
        var billingOpts=[];
        billingOptionsAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                billingOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            console.log('billingOpts~>'+billingOpts);
            component.set("v.billingOptions",billingOpts);
        });
        $A.enqueueAction(billingOptionsAction); 
        
        var qvnAction = component.get("c.getQVNotification");
        var qvn = component.find("qvn");
        var qvnOpts=[];
        qvnAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                qvnOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //qvn.set("v.options", qvnOpts); 
            component.set("v.qvnOptions",qvnOpts);
            
        });
        $A.enqueueAction(qvnAction); 
        
        var carbonneutralAction = component.get("c.getCarbonNeutral");
        var carbonneutral = component.find("carbonneutral");
        var carbonneutralOpts=[];
        carbonneutralAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                carbonneutralOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //carbonneutral.set("v.options", carbonneutralOpts);
            component.set("v.carbonneutralOptions",carbonneutralOpts);
            
        });
        $A.enqueueAction(carbonneutralAction);
        
        var codAction = component.get("c.getCOD");
        var cod = component.find("cod");
        var codOpts=[];
        codAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                codOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //cod.set("v.options", codOpts);
            component.set("v.codOptions",codOpts);
            
        });
        $A.enqueueAction(codAction);
        
        var dryiceAction = component.get("c.getDryIce");
        var dryice = component.find("dryice");
        var dryiceOpts=[];
        dryiceAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                dryiceOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //dryice.set("v.options", dryiceOpts);
            component.set("v.dryiceOptions",dryiceOpts);
            
        });
        $A.enqueueAction(dryiceAction);
        
        var returnserviceAction = component.get("c.getReturnService");
        var returnservice = component.find("returnservice");
        var returnserviceOpts=[];
        returnserviceAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                returnserviceOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //returnservice.set("v.options", returnserviceOpts);
            component.set("v.returnserviceOptions",returnserviceOpts);
            
        });
        $A.enqueueAction(returnserviceAction);    
        
        var saturdaydeliveryAction = component.get("c.getSaturdayDelivery");
        var saturdaydelivery = component.find("saturdaydelivery");
        var saturdaydeliveryOpts=[];
        saturdaydeliveryAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                saturdaydeliveryOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //saturdaydelivery.set("v.options", saturdaydeliveryOpts);
            component.set("v.saturdaydeliveryOptions",saturdaydeliveryOpts);
            component.set("v.sdconfirmation",saturdaydeliveryOpts);
            
        });
        $A.enqueueAction(saturdaydeliveryAction); 
        
        var additionalhandlingAction = component.get("c.getAdditionalHandling");
        var additionalhandling = component.find("additionalhandling");
        var additionalhandlingOpts=[];
        additionalhandlingAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                additionalhandlingOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //additionalhandling.set("v.options", additionalhandlingOpts);
            component.set("v.additionalhandlingOptions",additionalhandlingOpts);
            component.set("v.ahconfirmation",additionalhandlingOpts);
        });
        $A.enqueueAction(additionalhandlingAction);
        
        var verbalconfirmationAction = component.get("c.getVerbalConfirmation");
        var verbalconfirmation = component.find("verbalconfirmation");
        var verbalconfirmationOpts=[];
        verbalconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                verbalconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //verbalconfirmation.set("v.options", verbalconfirmationOpts);
            component.set("v.verbalconfirmationOptions",verbalconfirmationOpts);
            component.set("v.vcconfirmation",verbalconfirmationOpts);
        });
        $A.enqueueAction(verbalconfirmationAction); 
        
        var deliveryconfirmationAction = component.get("c.getDeliveryConfirmation");
        var deliveryconfirmation = component.find("deliveryconfirmation");
        var deliveryconfirmationOpts=[];
        deliveryconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                deliveryconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //deliveryconfirmation.set("v.options", deliveryconfirmationOpts);
            component.set("v.deliveryconfirmationOptions",deliveryconfirmationOpts); 
            component.set("v.dcconfirmation",deliveryconfirmationOpts); 
        });  
        $A.enqueueAction(deliveryconfirmationAction);
        
        var statusconfirmationAction = component.get("c.getStatusConfirmation");
        //var statusconfirmation = component.find("statusconfirmation");
        var statusconfirmationOpts=[];
        statusconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                statusconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.statusconfirmation", statusconfirmationOpts);
        });  
        $A.enqueueAction(statusconfirmationAction);
        
        var pucconfirmationAction = component.get("c.getPucConfirmation");
        var pucconfirmation = component.find("pucconfirmation");
        var pucconfirmationOpts=[];
        pucconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                pucconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.pucconfirmation", pucconfirmationOpts);
            //pucconfirmation.set("v.options", pucconfirmationOpts);
            component.set("v.pucconfirmationOptions", pucconfirmationOpts);
            
        });  
        $A.enqueueAction(pucconfirmationAction);
        
        var ifconfirmationAction = component.get("c.getIfConfirmation");
        var ifconfirmation = component.find("ifconfirmation");
        var ifconfirmationOpts=[];
        ifconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                ifconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.ifconfirmation", ifconfirmationOpts);
            //ifconfirmation.set("v.options", ifconfirmationOpts);
            component.set("v.ifconfirmationOptions", ifconfirmationOpts);
        });  
        $A.enqueueAction(ifconfirmationAction);
        
        var tosconfirmationAction = component.get("c.getTosConfirmation");
        var tosconfirmationOpts=[];
        tosconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                tosconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.tosconfirmation", tosconfirmationOpts);
        });  
        $A.enqueueAction(tosconfirmationAction);
        
        var rfeconfirmationAction = component.get("c.getRfeConfirmation");
        var rfeconfirmationOpts=[];
        rfeconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                rfeconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }    
            component.set("v.rfeconfirmation", rfeconfirmationOpts);
        });  
        $A.enqueueAction(rfeconfirmationAction);
        
        setTimeout(function(){component.set("v.isLoading", false);}, 6000);
    },
    
    setSSCPickList :function(component, event,helper) {
        var sdconfirmation = component.find("saturdaydelivery");
        var dcconfirmation = component.find("deliveryconfirmation");
        var ifconfirmation = component.find("ifconfirmation");
        var pucconfirmation = component.find("pucconfirmation");
        //sdconfirmation.set("v.options", component.get('v.sdconfirmation'));
        component.set("v.saturdaydeliveryOptions", component.get('v.sdconfirmation'));
        
        //dcconfirmation.set("v.options", component.get('v.dcconfirmation'));
        component.set("v.deliveryconfirmationOptions", component.get('v.dcconfirmation'));
        
        //ifconfirmation.set("v.options", component.get('v.ifconfirmation'));
        component.set("v.ifconfirmationOptions", component.get('v.ifconfirmation'));
        
        //pucconfirmation.set("v.options", component.get('v.pucconfirmation'));
        component.set("v.pucconfirmationOptions", component.get('v.pucconfirmation'));
        helper.setPickValues(component, event, helper);
    },
    
    setPickList :function(component, event,helper) {
        var statusconfirmation = component.find("statusconfirmation");
        //statusconfirmation.set("v.options", component.get('v.statusconfirmation'));
        component.set("v.statusconfirmationOptions", component.get('v.statusconfirmation'));
    },
    
    fetchForms :function(component, event, helper) {
        var interFormVl = component.get("v.shipment.ERP7__International_Forms__c");
        var toAddress = component.get("v.address.Id");
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        //alert('Inside fetchForms : ' +interFormVl);
        var action = component.get("c.displayForms");
        action.setParams({
            "interFormValue":interFormVl,
            "toAdd":toAddress, 
            "myConsVar": myConsVariable,  
            "Shipment":JSON.stringify(component.get("v.shipment"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var obj = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.UPS_Services", obj);
                component.set("v.errorMsg1", obj.Error);
                helper.setPickValues(component, event, helper);
            }  
        });
        $A.enqueueAction(action);
    },
    
    Rate_Request :function(component, event,helper){
        component.set("v.isLoading",true);
        console.log('Rate_Request called');
        component.set("v.errorMsg1", '');
        component.set("v.ShowTimeInCostTab", false);
        component.set("v.WrapperMsg", '');
        //component.set("v.UPS_Services.UPSErrorMsg",'');
        
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
        var obj ={};
        for(var i in packId){
            obj[i] = packId[i];
        }
        var fromAddress = component.get("v.fromAddress.Id");
        var toAddress = component.get("v.address.Id");
        var shipmentDate = component.get("v.shipment.ERP7__Shipment_Date__c"); //,today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        
        console.log('component shipment date~>'+component.get("v.shipment.ERP7__Shipment_Date__c"));
        console.log('todayDate~>'+todayDate);
        console.log('shipmentDate ~>'+shipmentDate);
        
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
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
        
        if(component.get("v.shipment.ERP7__Billing_Account_Number__c") != null && component.get("v.shipment.ERP7__Billing_Account_Number__c") != '' && component.get("v.shipment.ERP7__Billing_Account_Number__c") != undefined){
            if(component.get("v.shipment.ERP7__Billing_Postal_Code__c") == null || component.get("v.shipment.ERP7__Billing_Postal_Code__c") == '' || component.get("v.shipment.ERP7__Billing_Postal_Code__c") == undefined){
                errorMsg = $A.get('$Label.c.The_Third_party_Billling_postal_Code_is_Required');  
                errorFlag = false;
            }
            if(component.get("v.shipment.ERP7__Billing_Country_Code__c") == null || component.get("v.shipment.ERP7__Billing_Country_Code__c") == '' || component.get("v.shipment.ERP7__Billing_Country_Code__c") == undefined){
                errorMsg = $A.get('$Label.c.The_Third_party_Billling_Country_Code_is_Required');  
                errorFlag = false;
            }
        }
        
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg1", errorMsg);
        
        if(errorFlag){
            console.log('Rate_Request errorFlag true');
            console.log('Rate_Request packList~>'+component.get("v.packageList"));
            console.log('Rate_Request fromAdd~>'+fromAddress);
            console.log('Rate_Request toAdd~>'+toAddress);
            console.log('Rate_Request shipDate~>'+shipmentDate);
            console.log('Rate_Request myConsVar~>'+myConsVariable);
            console.log('Rate_Request Shipment~>'+JSON.stringify(component.get("v.shipment")));
            var action = component.get("c.Service_And_Rate_Request");
            action.setParams({
                "packList":component.get("v.packageList"),
                "fromAdd":fromAddress,
                "toAdd":toAddress, 
                "shipDate":shipmentDate, 
                "myConsVar": myConsVariable,  
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "isReturnShipment":false,
            });
            action.setCallback(this, function(response){
                if (response.getState() === "SUCCESS"){
                    var obj = response.getReturnValue();
                    console.log('Rate_Request response~>'+JSON.stringify(obj));
                    console.log('Rate_Request upsW.Error~>'+obj.Error);
                    component.set("v.UPS_Services", obj);
                    component.set("v.ShowTimeInCostTab",obj.time_in_cost_tab);
                    component.set("v.WrapperMsg", 'obj.UPSErrorMsg');
                    component.set("v.errorMsg1", obj.Error);
                    component.set("v.ShowGetRate",true);
                }else{
                    var errors = response.getError();
                    console.log("Rate_Request server error : ", errors);
                }
            });
            $A.enqueueAction(action);
        }else{
            console.log('Rate_Request errorFlag false~>'+errorFlag);
            component.set("v.ShowTimeInCostTab",false);
            component.set("v.WrapperMsg",'');
            
        }
        setTimeout(function(){component.set("v.isLoading", false);}, 4000);
    },
    
    Shipping_Request :function(component, event,helper) {
        try{
            component.set("v.isLoading",true);
            console.log('Shipping_Request called');
            component.set("v.errorMsg1", '');
            component.set("v.WrapperMsg", '');
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
            var rateWrapper = '';
            for(var x in rateWrapperList){
                if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
            }
            
            var packId = component.get("v.packageList");
            var fromAddress = component.get("v.fromAddress.Id");
            var toAddress = component.get("v.address.Id");
            var shipmentDate = component.get("v.shipment.ERP7__Shipment_Date__c",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
            var myConsVariable = JSON.stringify(component.get("v.myConsW"));
            
            if(component.get("v.shipment.ERP7__Status__c") == 'Shipped' || component.get("v.shipment.ERP7__Status__c") == 'Delivered'){
                errorFlag = false;
                errorMsg = $A.get('$Label.c.This_Package_Has_Already_Been') + component.get("v.shipment.ERP7__Status__c") + '.';
            }
            
            if(component.get("v.shipment.ERP7__Shipment_Date__c") < todayDate){
                errorFlag = false;
                errorMsg = errorMsg + ' ' + $A.get('$Label.c.The_Shipment_Date_Should_Not_Be_In_Past');
            }
            
            if(rateWrapper == '' || rateWrapper == null){
                errorFlag = false;
                errorMsg = errorMsg + ' ' + $A.get('$Label.c.Service_Is_Unavailable_Please_Select_At_Least_One_Service_From_Shipping_Service');
            }
            if(component.get("v.shipment.ERP7__Billing_Account_Number__c") != null && component.get("v.shipment.ERP7__Billing_Account_Number__c") != '' && component.get("v.shipment.ERP7__Billing_Account_Number__c") != undefined){
                if(component.get("v.shipment.ERP7__Billing_Postal_Code__c") == null || component.get("v.shipment.ERP7__Billing_Postal_Code__c") == '' || component.get("v.shipment.ERP7__Billing_Postal_Code__c") == undefined){
                    errorMsg = $A.get('$Label.c.The_Third_party_Billling_postal_Code_is_Required');  
                    errorFlag = false;
                }
                if(component.get("v.shipment.ERP7__Billing_Country_Code__c") == null || component.get("v.shipment.ERP7__Billing_Country_Code__c") == '' || component.get("v.shipment.ERP7__Billing_Country_Code__c") == undefined){
                    errorMsg = $A.get('$Label.c.The_Third_party_Billling_Country_Code_is_Required');  
                    errorFlag = false;
                }
            }
            if(errorMsg != null || errorMsg != '') component.set("v.errorMsg1", errorMsg);
            
            if(errorFlag){
                console.log('Shipping_Request errorFlag true');
                console.log('Shipping_Request packList~>'+JSON.stringify(packId));
                console.log('Shipping_Request fromAdd~>'+fromAddress);
                console.log('Shipping_Request toAdd~>'+toAddress);
                console.log('Shipping_Request shipDate~>'+shipmentDate);
                console.log('Shipping_Request myConsVar~>'+myConsVariable);
                console.log('Shipping_Request Shipment~>'+JSON.stringify(component.get("v.shipment")));
                console.log('Shipping_Request rateWrapperSelected~>'+rateWrapper);
                console.log('Shipping_Request toShipType~>'+component.get("v.toShipmentType"));
                console.log('Shipping_Request frShipType~>'+component.get("v.fromShipmentType"));
                
                var action = component.get("c.Process_Shipment_Request_Reply");
                action.setParams({
                    "packList":packId,
                    "fromAdd":fromAddress,
                    "toAdd":toAddress, 
                    "shipDate":shipmentDate, 
                    "myConsVar": myConsVariable,
                    "Shipment":JSON.stringify(component.get("v.shipment")),
                    "rateWrapperSelected": rateWrapper,
                    "toShipType":component.get("v.toShipmentType"),
                    "frShipType":component.get("v.fromShipmentType"),
                    "isReturnShipment":false,
                    "masterShipmentId":'',
                    "returnshipment":JSON.stringify(component.get("v.returnshipment")),
                });
                
                action.setCallback(this, function(response){
                    if (response.getState() === "SUCCESS"){
                        var obj = response.getReturnValue();
                        console.log('Shipping_Request request~>',response.getReturnValue().request);
                        console.log('Shipping_Request response~>',response.getReturnValue().responseStr);
                        console.log('Shipping_Request upsW.Error~>'+obj.Error);
                        component.set("v.UPS_Services", obj);
                        console.log('show send returl label~>'+ obj.showreturnlabel);
                        component.set("v.showSendReturnLabel", obj.showreturnlabel);
                        component.set("v.errorMsg1", obj.Error);
                        component.set("v.shipment", response.getReturnValue().Shipment);
                        if(obj.Shipment.ERP7__Status__c == 'Shipped'){
                            component.set("v.WrapperMsg", 'obj.UPSErrorMsg');
                            component.set("v.ShowTimeInCostTab",false);
                            component.set("v.ShowGetRate",false);   
                        }
                        component.set("v.isLoading", false);
                    }else{
                        var errors = response.getError();
                        console.log("Shipping_Request server error : ", errors);
                        component.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(action);
            }  else{
                console.log('Shipping_Request errorFlag false~>'+errorFlag);    
                component.set("v.isLoading", false);
            } 
        }catch(e){
            console.log('errs~>'+e);
            component.set("v.isLoading", false);
        }
    },
    
    //only UPS label to be viewed with print option in init
    CreateUPSLabel : function(component, event,helper){
        var shipmentsId = component.get("v.shipment.Id"); 
        var fileName = 'UPS_Label';
        var val = 'pdf';
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&val='+val;
            window.open(viewLabel,'_blank');
        }
    },
    
    //Added by Arshad //isforRMA (not used for generate return labels option)
    SendReturnLabel : function(component, event,helper){
        console.log('SendReturnLabel called');
        var shipmentsId = component.get("v.shipment.Id"); 
        var fileName = 'UPS_Label';
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
    
    //Added by Arshad
    closereturnmodal : function(component, event, helper){
        component.set("v.showreturnmodal",false);
        component.set("v.errorMsg1", ''); 
        component.set("v.exceptionError", ''); 
    },
    
    //Added by Arshad of both ups/fedex
    getreturnshipmentrates :function(component, event,helper){
        component.set("v.isLoading",true);
        console.log('getreturnshipmentrates called');
        component.set("v.errorMsg1", '');
        component.set("v.exceptionError", ''); 
        component.set("v.ShowTimeInCostTab", false);
        component.set("v.WrapperMsg", '');
        //component.set("v.UPS_Services.UPSErrorMsg",'');
        
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
        var obj ={};
        for(var i in packId){
            obj[i] = packId[i];
        }
        var fromAddress = component.get("v.fromAddress.Id");
        var toAddress = component.get("v.address.Id");
        var shipmentDate = component.get("v.returnshipmentdate"); //,today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        
        console.log('component shipment date~>'+component.get("v.returnshipmentdate"));
        console.log('todayDate~>'+todayDate);
        console.log('shipmentDate ~>'+shipmentDate);
        
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
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
            console.log('getreturnshipmentrates errorFlag true');
            console.log('getreturnshipmentrates packList~>',JSON.stringify(component.get("v.packageList")));
            console.log('getreturnshipmentrates fromAdd~>'+fromAddress);
            console.log('getreturnshipmentrates toAdd~>'+toAddress);
            console.log('getreturnshipmentrates shipDate~>'+shipmentDate);
            console.log('getreturnshipmentrates myConsVar~>',myConsVariable);
            var action = component.get("c.Service_And_Rate_Request");
            action.setParams({
                "packList":component.get("v.packageList"),
                "fromAdd":toAddress,
                "toAdd":fromAddress, 
                "shipDate":shipmentDate, 
                "myConsVar": myConsVariable,  
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "isReturnShipment":true,
            });
            action.setCallback(this, function(response){
                if (response.getState() === "SUCCESS"){
                    var obj = response.getReturnValue();
                    console.log('getreturnshipmentrates response~>',obj);
                    console.log('getreturnshipmentrates upsW.Error~>'+obj.Error);
                    if(response.getReturnValue().Services != undefined && response.getReturnValue().Services != null){
                        component.set("v.UPS_Services.Services", response.getReturnValue().Services);
                    }
                    
                    component.set("v.showreturnmodal", true);
                    
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
                    
                    //allowFedExReturnShipmentFromUPS starts - Added by Arshad 26 Sep 2023
                    console.log('selectedLogisticReturnShipType~>'+component.get("v.selectedLogisticReturnShipType"));
                    if(component.get("v.allowFedExReturnShipmentFromUPS") && (component.get("v.selectedLogisticReturnShipType") == 'FedEx' || component.get("v.selectedLogisticReturnShipType") == '')){ // && component.get("v.selectedLogisticReturnShipType") == 'FedEx'
                        console.log('getting FedEx services for return shipment');
                        
                        var FedExaction1 = component.get("c.getFedexmyConstructor");
                        var sId = ''; 
                        if(component.get("v.shipment") != undefined && component.get("v.shipment") != null){
                            if(component.get("v.shipment.Id") != undefined && component.get("v.shipment.Id") != null){
                                sId = component.get("v.shipment.Id");
                            }
                        }
                        console.log('sId~>'+sId);
                        
                        FedExaction1.setParams({ 
                            shipId:sId,
                            retValue:'',
                        });
                        console.log('inhere1');
                        FedExaction1.setCallback(this, function(resp1) {
                            console.log('stop lagging 1');
                            setTimeout(function(){ console.log('stop lagging 2'); }, 1000);
                            if (resp1.getState() === "SUCCESS"){
                                var obj = resp1.getReturnValue();
                                console.log('getFedexmyConstructor obj~>',obj);
                                if(obj != null){
                                    var wrError = resp1.getReturnValue().wrapError;
                                    if(wrError != null && wrError != '' && wrError != undefined) component.set("v.errorMsg1", wrError);
                                    component.set("v.FedexmyConsW", obj);
                                    
                                    if(sId != ''){
                                        component.set("v.FEDEX_Services", obj.uWrap);
                                        
                                        var FedexmyConsVariable = JSON.stringify(component.get("v.FedexmyConsW"));
                                        console.log('FedexmyConsVariable~>',FedexmyConsVariable);
                                        
                                        var FedExaction2 = component.get("c.getFedexServicesWrapperList");
                                        console.log('inhere4');
                                        FedExaction2.setParams({
                                            "packList":component.get("v.packageList"),
                                            "fromAdd":toAddress,
                                            "tAddress":fromAddress,
                                            "shipDate":shipmentDate,
                                            "myConsVar": FedexmyConsVariable,
                                            "isReturnShipment":true,
                                        });
                                        console.log('inhere5');
                                        FedExaction2.setCallback(this, function(resp2){
                                            console.log('stop lagging 3');
                                            setTimeout(function(){ console.log('stop lagging 4'); }, 1000);
                                            if(resp2.getState() === "SUCCESS"){
                                                try{
                                                    var obj = resp2.getReturnValue();
                                                    console.log('getFedexServicesWrapperList resp2~>',obj);
                                                    console.log('getFedexServicesWrapperList upsW.Error~>'+obj.Error);
                                                    if(resp2.getReturnValue().Services != undefined && resp2.getReturnValue().Services != null){
                                                        component.set("v.FEDEX_Services.Services", resp2.getReturnValue().Services);
                                                    }
                                                    
                                                    var rateWrapperList = component.get("v.FEDEX_Services.Services");
                                                    if(rateWrapperList != undefined && rateWrapperList != null){
                                                        if(rateWrapperList.length > 0){
                                                            var subString = 'GROUND';
                                                            for(var x in rateWrapperList){
                                                                if(rateWrapperList[x].Service != undefined && rateWrapperList[x].Service != null && rateWrapperList[x].Service != ''){
                                                                    if(rateWrapperList[x].Service.toLowerCase().includes(subString.toLowerCase())){
                                                                        console.log('Fedex Ground exists');
                                                                        rateWrapperList[x].Selected = true;
                                                                        break;
                                                                    }
                                                                }
                                                            }
                                                            component.set("v.FEDEX_Services.Services",rateWrapperList);
                                                        }
                                                    }
                                                    component.set("v.exceptionError", obj.Error);
                                                    component.set("v.isLoading", false);
                                                }catch(e){
                                                    console.log('getFedexServicesWrapperList errs here~>'+e);
                                                    component.set("v.isLoading", false);
                                                }
                                            }
                                            else{
                                                var errors = resp2.getError();
                                                console.log("getFedexServicesWrapperList server error : ", errors);
                                                component.set("v.isLoading", false);
                                            }
                                        });
                                        console.log('inhere6');
                                        $A.enqueueAction(FedExaction2); 
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
                                console.log("FedExaction1 server error : ", errors);
                                component.set("v.isLoading", false);
                            }
                        });
                        console.log('inhere2');
                        $A.enqueueAction(FedExaction1); 
                        console.log('inhere3');
                        
                    }
                    else{
                        console.log('allowFedExReturnShipmentFromUPS false');
                        component.set("v.isLoading", false);
                    }
                    //allowFedExReturnShipmentFromUPS ends
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
        //setTimeout(function(){component.set("v.isLoading", false);}, 5000);
    },
    
    //Added by Arshad
    generateReturnShipment :function(component, event,helper) {
        try{
            component.set("v.isLoading",true);
            console.log('generateReturnShipment called');
            component.set("v.errorMsg1", '');
            component.set("v.exceptionError", '');
            component.set("v.WrapperMsg", '');
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
            var toAddress = component.get("v.address.Id");
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
            
            if(component.get("v.shipment.ERP7__Billing_Account_Number__c") != null && component.get("v.shipment.ERP7__Billing_Account_Number__c") != '' && component.get("v.shipment.ERP7__Billing_Account_Number__c") != undefined){
                if(component.get("v.shipment.ERP7__Billing_Postal_Code__c") == null || component.get("v.shipment.ERP7__Billing_Postal_Code__c") == '' || component.get("v.shipment.ERP7__Billing_Postal_Code__c") == undefined){
                    errorMsg = $A.get('$Label.c.The_Third_party_Billling_postal_Code_is_Required');  
                    errorFlag = false;
                }
                if(component.get("v.shipment.ERP7__Billing_Country_Code__c") == null || component.get("v.shipment.ERP7__Billing_Country_Code__c") == '' || component.get("v.shipment.ERP7__Billing_Country_Code__c") == undefined){
                    errorMsg = $A.get('$Label.c.The_Third_party_Billling_Country_Code_is_Required');  
                    errorFlag = false;
                }
            }
            if(errorMsg != null || errorMsg != '') component.set("v.exceptionError", errorMsg);
            
            if(errorFlag){
                console.log('generateReturnShipment errorFlag true');
                console.log('generateReturnShipment packList~>'+JSON.stringify(packId));
                console.log('generateReturnShipment fromAdd~>'+fromAddress);
                console.log('generateReturnShipment toAdd~>'+toAddress);
                console.log('generateReturnShipment shipDate~>'+shipmentDate);
                console.log('generateReturnShipment myConsVar~>'+myConsVariable);
                console.log('generateReturnShipment Shipment~>'+JSON.stringify(component.get("v.shipment")));
                console.log('generateReturnShipment returnshipment~>'+JSON.stringify(component.get("v.returnshipment")));
                console.log('generateReturnShipment rateWrapperSelected~>'+rateWrapper);
                console.log('generateReturnShipment toShipType~>'+component.get("v.toShipmentType"));
                console.log('generateReturnShipment frShipType~>'+component.get("v.fromShipmentType"));
                
                var masterShipmentId = '';
                if(!$A.util.isEmpty(component.get("v.shipment")) && !$A.util.isUndefinedOrNull(component.get("v.shipment"))){
                    if(!$A.util.isEmpty(component.get("v.shipment.Id")) && !$A.util.isUndefinedOrNull(component.get("v.shipment.Id"))){
                        masterShipmentId = component.get("v.shipment.Id");
                    }
                }
                console.log('masterShipmentId~>'+masterShipmentId);
                
                var action = component.get("c.Process_Shipment_Request_Reply");
                action.setParams({
                    "packList":packId,
                    "fromAdd":toAddress,
                    "toAdd":fromAddress, 
                    "shipDate":shipmentDate, 
                    "myConsVar": myConsVariable,
                    "Shipment":JSON.stringify(component.get("v.shipment")),
                    "rateWrapperSelected": rateWrapper,
                    "toShipType":component.get("v.fromShipmentType"),
                    "frShipType":component.get("v.toShipmentType"),
                    "isReturnShipment":true,
                    "masterShipmentId":masterShipmentId,
                    "returnshipment":JSON.stringify(component.get("v.returnshipment")),
                });
                
                action.setCallback(this, function(response){
                    if (response.getState() === "SUCCESS"){
                        var obj = response.getReturnValue();
                        console.log('generateReturnShipment request~>',response.getReturnValue().request);
                        console.log('generateReturnShipment response~>',response.getReturnValue().responseStr);
                        console.log('generateReturnShipment upsW.Error~>'+obj.Error);
                        //component.set("v.UPS_Services", obj);
                        //console.log('show send returl label~>'+ obj.showreturnlabel);
                        //component.set("v.showSendReturnLabel", obj.showreturnlabel);
                        component.set("v.exceptionError", obj.Error);
                        if(obj.Error == ''){
                            component.set("v.returnshipment", response.getReturnValue().Shipment);
                            component.set("v.showreturnmodal", false);
                        }
                        /*if(obj.Shipment.ERP7__Status__c == 'Shipped'){
                        component.set("v.WrapperMsg", 'obj.UPSErrorMsg');
                        component.set("v.ShowTimeInCostTab",false);
                        component.set("v.ShowGetRate",false);   
                    }*/
                        component.set("v.isLoading", false);
                    }else{
                        var errors = response.getError();
                        console.log("generateReturnShipment server error : ", errors);
                        component.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(action);
            }    else{
                console.log('Shipping_Request errorFlag false~>'+errorFlag);    
                component.set("v.isLoading", false);
            } 
        }catch(e){
            console.log('errs~>'+e);
            component.set("v.isLoading", false);
        }
    },
    
    //Added by Arshad 26 Sep 2023
    generateFedExReturnShipmentFromUPS :function(component, event,helper) {
        try{
            component.set("v.isLoading",true);
            console.log('generateFedExReturnShipmentFromUPS called');
            component.set("v.errorMsg1", '');
            component.set("v.exceptionError", '');
            component.set("v.WrapperMsg", '');
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
            var toAddress = component.get("v.address");
            var shipmentDate = component.get("v.returnshipmentdate"); 
            var myConsVariable = JSON.stringify(component.get("v.FedexmyConsW"));
            
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
                console.log('generateFedExReturnShipmentFromUPS errorFlag true');
                console.log('generateFedExReturnShipmentFromUPS packList~>'+JSON.stringify(packId));
                console.log('generateFedExReturnShipmentFromUPS fromAdd~>'+fromAddress);
                console.log('generateFedExReturnShipmentFromUPS toAdd~>'+toAddress);
                console.log('generateFedExReturnShipmentFromUPS shipDate~>'+shipmentDate);
                console.log('generateFedExReturnShipmentFromUPS myConsVar~>'+myConsVariable);
                console.log('generateFedExReturnShipmentFromUPS Shipment~>'+JSON.stringify(component.get("v.shipment")));
                console.log('generateFedExReturnShipmentFromUPS returnshipment~>'+JSON.stringify(component.get("v.returnshipment")));
                console.log('generateFedExReturnShipmentFromUPS rateWrapperSelected~>'+rateWrapper);
                console.log('generateFedExReturnShipmentFromUPS toShipType~>'+component.get("v.toShipmentType"));
                console.log('generateFedExReturnShipmentFromUPS frShipType~>'+component.get("v.fromShipmentType"));
                
                var masterShipmentId = '';
                if(!$A.util.isEmpty(component.get("v.shipment")) && !$A.util.isUndefinedOrNull(component.get("v.shipment"))){
                    if(!$A.util.isEmpty(component.get("v.shipment.Id")) && !$A.util.isUndefinedOrNull(component.get("v.shipment.Id"))){
                        masterShipmentId = component.get("v.shipment.Id");
                    }
                }
                console.log('masterShipmentId~>'+masterShipmentId);
                
                var action = component.get("c.generateFedexShipment");
                
                action.setParams({ 
                    "packList":packId,
                    "fromAddress":toAddress,
                    "toAddress":fromAddress,
                    "ShipDateStamp":shipmentDate,
                    "myConsVar" : myConsVariable,
                    "Shipment":JSON.stringify(component.get("v.shipment")),
                    "rateWrapperSelected": rateWrapper,
                    "isReturnShipment":true,
                    "masterShipmentId":masterShipmentId,
                    "returnshipment":JSON.stringify(component.get("v.returnshipment")),
                });
                
                action.setCallback(this, function(response){
                    if (response.getState() === "SUCCESS"){
                        var obj = response.getReturnValue();
                        console.log('generateFedexShipment response~>',obj);
                        console.log('generateFedexShipment upsW.Error~>'+obj.Error);
                        
                        component.set("v.exceptionError", obj.Error);
                        if(obj.Error == ''){
                            component.set("v.returnshipment", response.getReturnValue().Shipment);
                            component.set("v.showreturnmodal", false);
                        }
                        component.set("v.isLoading", false);
                    }else{
                        var errors = response.getError();
                        console.log("generateFedexShipment server error : ", errors);
                        component.set("v.isLoading", false);
                    }
                });
                $A.enqueueAction(action);
            }else{
                console.log('Shipping_Request errorFlag false~>'+errorFlag);    
                component.set("v.isLoading", false);
            } 
        }catch(e){
            console.log('errs~>'+e);
            component.set("v.isLoading", false);
        }
    },
    
    closeError : function(component, event, helper) {
        component.set("v.exceptionError","");
    },
    
    
    //Added by Arshad //Fedex or UPS label to be viewed with print option in init //no print option init if international only if fedex
    CreateUPSReturnLabel : function(component, event,helper){
        console.log('CreateUPSReturnLabel called');
        var shipmentsId = component.get("v.returnshipment.Id"); 
        var fileName = 'UPS_Label';
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
        var fileName = 'UPS_Label';
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
    
    CommercialInvoice :function(component, event,helper) {
        var shipmentsId = component.get("v.shipment.Id");
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '/apex/ERP7__UPSCommercialInvoice?shipmentsId='+shipmentsId;
            window.open(viewLabel,'_blank');
        }
    },
    
    Cancel_Request :function(component, event,helper) {
        component.set("v.errorMsg1", '');
        component.set("v.UPS_Services.UPSErrorMsg", '');
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit; 
        }
        
        var shipments = component.get("v.shipment");
        console.log('shipments : '+JSON.stringify(shipments));
        var packId = component.get("v.packageList");
        var shipmentDate = component.get("v.shipment.ERP7__Shipment_Date__c",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        var errorFlag = true;
        var errorMsg = '';
        
        if(component.get("v.shipment.ERP7__Status__c") != 'Shipped'){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Request_To_Cancel_Shipment_Cannot_Be_Processed');
        }
        
        if(component.get("v.shipment.ERP7__Pickup_Requested__c") == true){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + $A.get('$Label.c.Shipment_Pickup_Is_Active_Thus_Request_To_Cancel_The_Shipment_Cannot_Be_Process');
        }
        
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg1", errorMsg);
        
        //alert('errorFlag : ' +errorFlag);
        
        if(errorFlag){
            var action = component.get("c.Cancel_Shipment_Request");
            action.setParams({
                "Shipment":JSON.stringify(shipments),
                "packList":packId,
                "myConsVar" : myConsVariable
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var obj = response.getReturnValue();
                if (state === "SUCCESS") {
                    console.log('Cancel_Shipment_Request resp~>',obj);
                    component.set("v.UPS_Services", obj);
                    component.set("v.errorMsg1", obj.Error);
                    component.set("v.errorMsg", obj.Error);
                    if(response.getReturnValue().UPSErrorMsg == 'Shipment Cancelled Successfully'){
                        component.set("v.shipment", response.getReturnValue().Shipment);
                        component.set("v.ShowGetRate",true);
                        $A.enqueueAction(component.get("c.doInit")); //Added by Arshad 31 Jan 2024 | UPS billing scenario - when a shipment is cancelled and new shipment is created on the same screen, without refreshing - shipment billing fields not auto populating 
                    }
                }else{
                    var errors = response.getError();
                    console.log("server error in Cancel_Shipment_Request : ", JSON.stringify(errors));
                } 
            }); 
            $A.enqueueAction(action);   
        }
    },
    
    PickupRate :function(component, event,helper) {
        //alert('Inside PickupRate');
        component.set("v.errorMsg", '');
        component.set("v.UPS_Services.UPSErrorMsg", '');
        var fromAddress = component.get("v.fromAddress.Id");
        var toAddress = component.get("v.address.Id");
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        //alert('Shipment : ' +JSON.stringify(component.get("v.shipment")));
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
            var action = component.get("c.Pickup_Rate_Request");
            action.setParams({
                "fromAdd":fromAddress,
                "toAdd":toAddress, 
                "Shipment":JSON.stringify(component.get("v.shipment")), 
                "dispatchDate":component.get("v.shipment.ERP7__Package_Ready_Time__c"),
                "PackageReadyTime":component.get("v.shipment.ERP7__Package_Ready_Time__c"),
                "CustomerCloseTime":component.get("v.shipment.ERP7__Customer_Close_Time__c"),
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var obj = response.getReturnValue();
                //alert('state : ' +state);
                if (state === "SUCCESS") {
                    component.set("v.UPS_Services", obj);
                    component.set("v.errorMsg", obj.Error);
                    component.set("v.ShowGetRate",false);
                } 
            }); 
            $A.enqueueAction(action);
        }
    },
    
    CreatePickup :function(component, event,helper) {
        component.set("v.errorMsg", '');
        component.set("v.UPS_Services.UPSErrorMsg", '');
        
        var fromAddress = component.get("v.fromAddress.Id");
        var toAddress = component.get("v.address.Id");
        var packId = component.get("v.packageList");
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        //alert('Inside CreatePickup');
        
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
            var action = component.get("c.CreatePickupRequest");
            action.setParams({
                "fromAdd":fromAddress,
                "toAdd":toAddress,
                "packList":packId, 
                "Shipment":JSON.stringify(component.get("v.shipment")), 
                "dispatchDate":component.get("v.shipment.ERP7__Package_Ready_Time__c"),
                "PackageReadyTime":component.get("v.shipment.ERP7__Package_Ready_Time__c"),
                "CustomerCloseTime":component.get("v.shipment.ERP7__Customer_Close_Time__c"),
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var obj = response.getReturnValue();
                //alert('state : ' +state);
                if (state === "SUCCESS") {
                    component.set("v.UPS_Services", obj);
                    component.set("v.errorMsg", obj.Error);
                    component.set("v.shipment", response.getReturnValue().Shipment);
                    component.set("v.ShowGetRate",false);
                } 
            }); 
            $A.enqueueAction(action);
        }
    },
    
    CancelPickup :function(component, event,helper) {
        //alert('CancelPickup');
        component.set("v.errorMsg", '');
        component.set("v.UPS_Services.UPSErrorMsg", '');
        var packId = component.get("v.packageList");
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
            var action = component.get("c.CancelPickupRequest");
            action.setParams({ 
                "packList1":JSON.stringify(packId), 
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert('state: ' +state);
                var obj = response.getReturnValue();
                var res = response.getReturnValue();
                if (state === "SUCCESS") {
                    component.set("v.UPS_Services", obj);
                    component.set("v.errorMsg", obj.Error);
                    component.set("v.shipment", response.getReturnValue().Shipment);
                    component.set("v.ShowGetRate",false);
                } 
            }); 
            $A.enqueueAction(action);
        }
    },
    
    Track_Request:function(component, event,helper) {
        //alert('Track Shipment');
        component.set("v.errorMsg", '');
        component.set("v.UPS_Services.UPSErrorMsg", '');
        
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
            var action = component.get("c.Track_Request_Reply");
            action.setParams({ 
                "packList1":packId, 
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert('state: ' +state);
                var obj = response.getReturnValue();
                if (state === "SUCCESS") {
                    component.set("v.UPS_Services", obj);
                    component.set("v.errorMsg", obj.Error);
                    component.set("v.ShowGetRate",false);
                } 
            }); 
            $A.enqueueAction(action);
        }
    },  
    
    Signature_Proof_Request :function(component, event,helper) {
        //alert('Signature Proof called');
        component.set("v.errorMsg", '');
        component.set("v.UPS_Services.UPSErrorMsg", '');
        
        var myConsVariable = JSON.stringify(component.get("v.myConsW"));
        
        var errorFlag = true;
        var errorMsg = '';
        
        if(component.get("v.shipment.ERP7__Status__c") != 'Delivered'){
            errorFlag = false;
            errorMsg = $A.get('$Label.c.Request_To_Get_Signature_Proof_Of_Delivery_For_This_Shipment_Cannot_Be_Processed');
        }
        
        if(errorMsg != null || errorMsg != '') component.set("v.errorMsg", errorMsg);
        
        if(errorFlag){
            var action = component.get("c.SPODRequest");
            action.setParams({
                "Shipment":JSON.stringify(component.get("v.shipment")),
                "myConsVar" : myConsVariable
            });    
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert('state: ' +state);    
                var obj = response.getReturnValue();
                if (state === "SUCCESS") { 
                    component.set("v.UPS_Services", obj);
                    component.set("v.errorMsg", obj.Error);
                    component.set("v.spodLetter", response.getReturnValue().spodLetter);
                    component.set("v.ShowGetRate",false);
                }  
            }); 
            $A.enqueueAction(action);
        }
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
    }
})