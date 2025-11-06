({
    doInitHandler: function(component, event, helper){
        console.log('Fedex doInitHandler called');
        var action = component.get("c.myConstructor");
        var sId = component.get("v.shipmentId");
        if(sId == 'undefined' || sId == null || sId == undefined) sId = '';
        action.setParams({ 
            shipId:sId,
            retValue:component.get("v.retValue"),
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                console.log('obj : ',JSON.stringify(obj));
                if(obj != null){
                    var wrError = response.getReturnValue().wrapError;
                    if(wrError != null && wrError != '' && wrError != undefined) component.set("v.errorMsg1", wrError);
                    component.set("v.myConsW", obj);
                    component.set("v.retValue", obj.retValue);
                    component.set('v.showeditBillDetails',obj.showeditBillDetails);
                    component.set('v.disableEditBillOptReturnShipment',obj.disableEditBillOptReturnShipment);
                    component.set('v.allowReturnShipment',obj.allowReturnShipment);
                    if(obj.allowReturnShipment){
                        component.set("v.returnshipment.ERP7__Billing_Account_Number__c",null);
                        component.set("v.returnshipment.ERP7__Billing_Postal_Code__c",null);
                        component.set("v.returnshipment.ERP7__Billing_Country_Code__c",null);
                        component.set("v.returnshipment.ERP7__Shipment_Billing_options__c",null);
                        component.set("v.returnshipment.ERP7__Billing_Contact__c",null);
                        component.set("v.returnshipment.ERP7__Billing_Address__c",null);
                    }
                    component.set('v.allowUPSReturnShipmentFromFedEx',obj.allowUPSReturnShipmentFromFedEx);
                    if(sId != 'undefined' && sId != null && sId != undefined && sId != ''){
                        console.log('obj.Shipment~>'+JSON.stringify(obj.Shipment));
                        console.log('obj.returnShipment~>'+JSON.stringify(obj.returnShipment));
                        component.set("v.shipment", obj.Shipment);
                        component.set("v.returnshipment", obj.returnShipment);
                        component.set("v.fromAddress", obj.fromAddress);
                        component.set("v.address", obj.toAddress);
                        component.set("v.ShowInvoice", obj.showCI);
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
                        
                        component.set('v.bufferlbl',response.getReturnValue().bufferLabel);
                        if(obj.Shipment.ERP7__Status__c == 'Shipped'){
                            component.set("v.ShowGetRate",false);
                            component.set("v.FEDEX_Services", obj.uWrap);
                        }
                        if(obj.Shipment.ERP7__Status__c == 'Picked Up'){
                            component.set("v.ShowGetRate",false);
                            component.set("v.FEDEX_Services", obj.uWrap);
                        }
                        if(obj.Shipment.ERP7__Status__c == 'Delivered'){
                            component.set("v.ShowGetRate",false);
                            component.set("v.FEDEX_Services", obj.uWrap);
                        }
                    }
                    
                    console.log('Fedex services~>'+JSON.stringify(obj.uWrap));  
                }
                
            }else{
                var errors = response.getError();
                console.log("myConstruct server error : ", errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    helperFun : function(component,event,secId) {
        var acc = component.find(secId);
        for(var i in acc){
            $A.util.toggleClass(acc[i], 'slds-show');  
            $A.util.toggleClass(acc[i], 'slds-hide');  
        }
    }
})