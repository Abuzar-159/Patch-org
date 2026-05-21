({
    doInit : function(component, event, helper){
        
        var shipID = component.get("v.shipmentId");
        helper.doInitHandler(component, event, helper);
        
       if(shipID == null || shipID == '' || shipID == 'undefined' || shipID == undefined){
        	var today = new Date();
            var monthDigit = today.getMonth() + 1;
            if (monthDigit <= 9) { monthDigit = '0' + monthDigit; } 
            component.set('v.shipment.ERP7__Shipment_Date__c',today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
            
            var paId = component.get("v.packageId");
            var action = component.get("c.fetchToAddress");
            action.setParams({packId:JSON.stringify(paId)});
            action.setCallback(this, function(response) {
                var state = response.getState();
                var obj = response.getReturnValue();
                if(state === "SUCCESS"){
                    component.set("v.address", obj);
                }
            });
            $A.enqueueAction(action);
            
            var paId = component.get("v.packageId");
            var action = component.get("c.fetchFromAddress");
            action.setParams({packId:JSON.stringify(paId)});
            action.setCallback(this, function(response) {
                var state = response.getState();
                var obj = response.getReturnValue();
                if(state === "SUCCESS"){
                    component.set("v.fromAddress", obj);
                }
            });
            $A.enqueueAction(action);
            
            var paId = component.get("v.packageId");
            var action = component.get("c.fetchingPackages");
            action.setParams({packId:JSON.stringify(paId)});
            action.setCallback(this, function(response) {
                var state = response.getState();
                var obj = response.getReturnValue();
                if(state === "SUCCESS"){
                    component.set("v.packageList", obj);
                }
            });
            $A.enqueueAction(action);
        }
        
        /* For Picklists */ 
        var statusconfirmationAction = component.get("c.getStatusConfirmation");
        var statusconfirmationOpts=[];
        statusconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                statusconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.statusconfirmation", statusconfirmationOpts);
             
        });  
        $A.enqueueAction(statusconfirmationAction);
          component.set("v.ShowGetRate", true);
        
    }, 
    
    setPickList :function(cmp, event,helper) {
        //alert('pick called');
        var statusconfirmation = cmp.find("statusconfirmation");
        //statusconfirmation.set("v.options", cmp.get('v.statusconfirmation'));
        cmp.set("v.statusconfirmationOptions",cmp.get('v.statusconfirmation'));
    },
    
    Rate_Request :function(cmp, event,helper) {
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        var packId = cmp.get("v.packageList");
        var fromAddress = cmp.get("v.fromAddress.Id");
        var toAddress = cmp.get("v.address.Id");
        var shipmentDate = cmp.get("v.shipment.ERP7__Shipment_Date__c",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        var action = cmp.get("c.Shipping_Rate_Request");
        action.setParams({
            "packList":packId, 
            "fromAdd":fromAddress,
            "tAddress":toAddress, 
            "shipDate":shipmentDate,
            "myConsVar": myConsVariable,
            //"Shipment":JSON.stringify(cmp.get("v.shipment"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           // var obj = response.getReturnValue();
            //return;
            if (state === "SUCCESS") {
                 var obj = response.getReturnValue();
                cmp.set("v.USPS_Services", obj);
                cmp.set("v.errorMsg1", response.getReturnValue().Error);
            }
        });
        $A.enqueueAction(action);
    },
    
    Shipping_Request :function(cmp, event,helper) {
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        
        var rateWrapperList = cmp.get("v.USPS_Services.Services");
        var rateWrapper = '';
        for(var x in rateWrapperList){
            if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
        }
        
        var packId = cmp.get("v.packageList");
        var fromAddress = cmp.get("v.fromAddress.Id");
        var toAddress = cmp.get("v.address.Id");
        var shipmentDate = cmp.get("v.shipment.ERP7__Shipment_Date__c",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        
        if(rateWrapper != ''){
            var action = cmp.get("c.Shipping_Request_Reply");
            action.setParams({
                "packList":packId,    
                "fromAdd":fromAddress,
                "toAdd":toAddress, 
                "shipDate":shipmentDate, 
                "myConsVar": myConsVariable,
                "Shipment":JSON.stringify(cmp.get("v.shipment")),
                "rateWrapperSelected": rateWrapper
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var obj = response.getReturnValue();
                
                if (state === "SUCCESS") {
                    cmp.set("v.USPS_Services", obj);
                    cmp.set("v.errorMsg1", response.getReturnValue().Error);
                    if(response.getReturnValue().UPSErrorMsg == 'Package Shipped Successfully'){
                        //alert('Inside success');
                        cmp.set("v.shipment", response.getReturnValue().Shipment);
                   }
                }
            });
            $A.enqueueAction(action);
        }else {
            cmp.set("v.errorMsg1", 'Service Is Unavailable, Please Select At Least One Service From Shipping Service And Cost');
        }   
    },
    
    CreateUPSLabel : function(cmp, event,helper){
        var shipmentsId = cmp.get("v.shipment.Id"); 
        var fileName = 'USPS_Label';
        var val = 'pdf';
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '/apex/ERP7__Pickpackship_PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName+'&val='+val;
            window.open(viewLabel,'_blank');
        }
    },
    
    Cancel_Request :function(cmp, event,helper) {
        
        var shipments = cmp.get("v.shipment");
        var packId = cmp.get("v.packageList");
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        
        var action = cmp.get("c.Cancel_Request_Reply");
        action.setParams({ 
            "Shipment":JSON.stringify(shipments),
            "packList":JSON.stringify(packId),
            "myConsVar" : myConsVariable
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var obj = response.getReturnValue();
            if (state === "SUCCESS") {
                cmp.set("v.USPS_Services", obj);
                cmp.set("v.errorMsg1", response.getReturnValue().Error);
                if(response.getReturnValue().UPSErrorMsg == 'Order Cancelled Successfully'){
                    cmp.set("v.shipment", response.getReturnValue().Shipment);
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    
    PickupRate :function(cmp, event,helper) {
  		var fromAddress = cmp.get("v.fromAddress.Id");
        var toAddress = cmp.get("v.address.Id");
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        var action = cmp.get("c.PickupAvailability_Reply");
        action.setParams({
            "fromAdd":fromAddress,
            "toAdd":toAddress, 
            "Shipment":JSON.stringify(cmp.get("v.shipment")),
            "PackageReadyTime":cmp.get("v.shipment.Package_Ready_Time__c"),
            "myConsVar" : myConsVariable
        });    

       action.setCallback(this, function(response) {
           var state = response.getState();
            var obj = response.getReturnValue();
            if (state === "SUCCESS") {
                cmp.set("v.errorMsg1", response.getReturnValue().Error);
                cmp.set("v.UPS_Services", obj);
            } 
        }); 
        $A.enqueueAction(action); 
    },
    
    CreatePickup :function(cmp, event,helper) {
        var fromAddress = cmp.get("v.fromAddress.Id");
        var toAddress = cmp.get("v.address.Id");
        var packId = cmp.get("v.packageList");
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        var action = cmp.get("c.CreatePickup_Reply");
        action.setParams({
            "fromAdd":fromAddress,
            "toAdd":toAddress,
            "packList":JSON.stringify(packId), 
            "Shipment":JSON.stringify(cmp.get("v.shipment")),
            "PackageReadyTime":cmp.get("v.shipment.Package_Ready_Time__c"),
            "myConsVar" : myConsVariable
        });    

       action.setCallback(this, function(response) {
           var state = response.getState();
            var obj = response.getReturnValue();
            if (state === "SUCCESS") {
                cmp.set("v.UPS_Services", obj);
                cmp.set("v.errorMsg1", response.getReturnValue().Error);
                cmp.set("v.shipment", response.getReturnValue().Shipment);
            } 
        }); 
        $A.enqueueAction(action); 
    },
    
    CancelPickup :function(cmp, event,helper) {
    	var packId = cmp.get("v.packageList");
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        var fromAddress = cmp.get("v.fromAddress.Id");
        
        var action = cmp.get("c.CancelPickup_Reply");
        action.setParams({
            "fromAdd":fromAddress,
            "packList":JSON.stringify(packId), 
            "Shipment":JSON.stringify(cmp.get("v.shipment")),
            "myConsVar" : myConsVariable
        });    

		action.setCallback(this, function(response) {
        	var state = response.getState();
           	//alert('state: ' +state);
            var obj = response.getReturnValue();
           	var res = response.getReturnValue();
           	if (state === "SUCCESS") {
                cmp.set("v.UPS_Services", obj);
                cmp.set("v.errorMsg1", response.getReturnValue().Error);
                cmp.set("v.shipment", response.getReturnValue().Shipment);
           } 
        }); 
        $A.enqueueAction(action);
    },
    
    Track_Request:function(cmp, event,helper) {
        //alert('Track Shipment');
        var packId = cmp.get("v.packageList");
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        
        var action = cmp.get("c.Track_Request_Reply");
        action.setParams({ 
            "packList":JSON.stringify(packId), 
            "Shipment":JSON.stringify(cmp.get("v.shipment")),
            "myConsVar" : myConsVariable
        });    

        action.setCallback(this, function(response) {
            var state = response.getState();
            var obj = response.getReturnValue();
            if (state === "SUCCESS") {
                cmp.set("v.USPS_Services", obj);
                cmp.set("v.errorMsg1", response.getReturnValue().Error);
                if(response.getReturnValue().UPSErrorMsg == 'Track Shipment Activities'){
                    //alert('Inside track Success');
                    cmp.set("v.shipment", response.getReturnValue().Shipment);
                }
           } 
        }); 
        $A.enqueueAction(action);
    },  
    
    Signature_Proof_Request :function(cmp, event,helper) {
        //alert('Signature Proof called');
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        var fromAddress = cmp.get("v.fromAddress.Id");
        
        var action = cmp.get("c.Signature_Proof_Reply");
        action.setParams({
            "fromAdd":fromAddress,
            "Shipment":JSON.stringify(cmp.get("v.shipment")),
            "myConsVar" : myConsVariable
        });    

        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('state: ' +state);
            var obj = response.getReturnValue();
            if (state === "SUCCESS") {
                cmp.set("v.errorMsg1", response.getReturnValue().Error);
                cmp.set("v.USPS_Services", obj);
           } 
        }); 
        $A.enqueueAction(action);
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
   }
   
})