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
        var piAction = component.get("c.getPiNotification");
        var pi = component.find("pi");
        var piOpts=[];
        piAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                piOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //pi.set("v.options", piOpts);
            component.set("v.piOptions",piOpts);
            component.set("v.piconfirmation",piOpts);
            
        });
        $A.enqueueAction(piAction);
        
        var statusconfirmationAction = component.get("c.getStatusConfirmation");
        var statusconfirmationOpts=[];
        statusconfirmationAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                statusconfirmationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set("v.statusconfirmation", statusconfirmationOpts);
             
        });  
        $A.enqueueAction(statusconfirmationAction);
        
    }, 
    
    setPickList :function(cmp, event,helper) {
        //alert('pick called');
        var statusconfirmation = cmp.find("statusconfirmation");
        statusconfirmation.set("v.options", cmp.get('v.statusconfirmation'));
    },
    
    setSSCPickList :function(cmp, event,helper) {
        //alert('pick called');
        var piconfirmation = cmp.find("pi");
        //piconfirmation.set("v.options", cmp.get('v.piconfirmation'));
        component.set("v.piOptions",cmp.get('v.piconfirmation'));
    },
    
    Rate_Request :function(cmp, event,helper){
        cmp.set("v.errorMsg1", '');
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        var todayDate = today.getFullYear()+'-'+monthDigit+'-'+today.getDate();
        var packId = cmp.get("v.packageList");
        var fromAddress = cmp.get("v.fromAddress.Id");
        var toAddress = cmp.get("v.address.Id");
        var shipmentDate = cmp.get("v.shipment.ERP7__Shipment_Date__c",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        var errorFlag = true;
        var errorMsg = '';
        if(cmp.get("v.shipment.ERP7__Status__c") == 'Shipped' || cmp.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = 'This Package Has Already Been ' + cmp.get("v.shipment.ERP7__Status__c") + '.';
        }
         
        if(shipmentDate < todayDate){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + 'The Shipment Date Should Not Be In Past.';
        }
        
        if(errorMsg != null || errorMsg != '') cmp.set("v.errorMsg1", errorMsg);
        
        if(errorFlag){
            //alert('Inside true');
            var action = cmp.get("c.Shipping_Rate_Request");
            action.setParams({
                "packList":packId, 
                "fromAdd":fromAddress,
                "toAdd":toAddress, 
                "shipDate":shipmentDate,
                "myConsVar": myConsVariable,
                "Shipment":JSON.stringify(cmp.get("v.shipment"))
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var obj = response.getReturnValue();
               
                if (state === "SUCCESS") {
                    cmp.set("v.DHL_Services", obj);
                    cmp.set("v.errorMsg1", obj.Error);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    Shipping_Request :function(cmp, event,helper) {
        //alert('Shipping_Request Called.');
        cmp.set("v.errorMsg1", '');
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        var todayDate = today.getFullYear()+'-'+monthDigit+'-'+today.getDate();
        var errorFlag = true;
        var errorMsg = '';
        
        var rateWrapperList = cmp.get("v.DHL_Services.Services");
        var rateWrapper = '';
        for(var x in rateWrapperList){
        	if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
        }
        
        var packId = cmp.get("v.packageList");
        var fromAddress = cmp.get("v.fromAddress.Id");
        var toAddress = cmp.get("v.address.Id");
        var shipmentDate = cmp.get("v.shipment.ERP7__Shipment_Date__c",today.getFullYear()  + "-" + monthDigit + "-" + today.getDate());
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        
        if(cmp.get("v.shipment.ERP7__Status__c") == 'Shipped' || cmp.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = 'This Package Has Already Been ' + cmp.get("v.shipment.ERP7__Status__c") + '.';
        }
        
        if(shipmentDate < todayDate){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + 'The Shipment Date Should Not Be In Past.';
        }
        
        if(rateWrapper == '' || rateWrapper == null){
            errorFlag = false;
            errorMsg = errorMsg + ' ' + 'Service Is Unavailable, Please Select At Least One Service From Shipping Service And Cost.';
        }
        
        if(errorMsg != null || errorMsg != '') cmp.set("v.errorMsg1", errorMsg);
        
        if(errorFlag){
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
                    cmp.set("v.DHL_Services", obj);
                    cmp.set("v.errorMsg1", obj.Error);
                    if(response.getReturnValue().UPSErrorMsg == 'Package Shipped Successfully'){
                        //alert('Inside success');
                        cmp.set("v.shipment", response.getReturnValue().Shipment);
                   }
                } 
            });
            $A.enqueueAction(action);
        }
        
    },
    
    CreateUPSLabel : function(cmp, event,helper){
        var shipmentsId = cmp.get("v.shipment.Id"); 
        var fileName = 'DHL_Label';
        if(shipmentsId != '' && shipmentsId != null){
            var viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+shipmentsId+'&fileName='+fileName;
            window.open(viewLabel,'_blank');
        }
    },
    
    Cancel_Request :function(cmp, event,helper) {
        //alert('Cancel Request Called.'); 
        cmp.set("v.errorMsg1", '');
        var shipments = cmp.get("v.shipment");
        var packId = cmp.get("v.packageList");
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        var errorFlag = true;
        var errorMsg = '';
        
        if(cmp.get("v.shipment.ERP7__Status__c") == '' || cmp.get("v.shipment.ERP7__Status__c") == null){
            errorFlag = false;
            errorMsg = 'The Shipment Is Unavailable.';
            alert(errorMsg);
        }
        
        if(cmp.get("v.shipment.ERP7__Status__c") != 'Shipped'){
            errorFlag = false;
            errorMsg = 'Request To Cancel Shipment Cannot Be Processed.';
            alert(errorMsg);
        }
        
        if(errorMsg != null || errorMsg != '') cmp.set("v.errorMsg1", errorMsg);
        
        if(errorFlag){
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
                    cmp.set("v.DHL_Services", obj);
                    cmp.set("v.errorMsg1", obj.Error);
                    if(response.getReturnValue().UPSErrorMsg == 'Shipment Cancelled Successfully'){
                        //alert('Inside cancel Success');
                        cmp.set("v.shipment", response.getReturnValue().Shipment);
                    }
                }
            }); 
            $A.enqueueAction(action);
        }
    },
    
    Track_Request:function(cmp, event,helper) {
        //alert('Track Shipment');
        cmp.set("v.errorMsg1", '');
        var errorFlag = true;
        var errorMsg = '';
        
    	var packId = cmp.get("v.packageList");
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        
        if(cmp.get("v.shipment.ERP7__Status__c") == '' || cmp.get("v.shipment.ERP7__Status__c") == null){
            errorFlag = false;
            errorMsg = 'The Shipment Is Unavailable.';
        }
        
        if(cmp.get("v.shipment.ERP7__Status__c") == 'Delivered'){
            errorFlag = false;
            errorMsg = 'Shipment Delivered : Request Cannot Be Processed';
        }
        
        if(errorMsg != null || errorMsg != '') cmp.set("v.errorMsg1", errorMsg);
        
        if(errorFlag){
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
                    cmp.set("v.DHL_Services", obj);
                    cmp.set("v.errorMsg1", obj.Error);
                    if(response.getReturnValue().UPSErrorMsg == 'Track Shipment Activities'){
                        //alert('Inside track Success');
                        cmp.set("v.shipment", response.getReturnValue().Shipment);
                    }
               } 
            }); 
            $A.enqueueAction(action);
        }
    },  
    
    Signature_Proof_Request :function(cmp, event,helper) {
        alert('Signature Proof called');
        cmp.set("v.errorMsg1", '');
        cmp.set("v.DHL_Services.UPSErrorMsg", '');
        var errorFlag = true;
        var errorMsg = '';  	 
        
        var myConsVariable = JSON.stringify(cmp.get("v.myConsW"));
        
        if(cmp.get("v.shipment.ERP7__Status__c") == '' || cmp.get("v.shipment.ERP7__Status__c") == null){
            errorFlag = false;
            errorMsg = 'The Shipment Is Unavailable.';
        }
        
        if(cmp.get("v.shipment.ERP7__Status__c") != 'Delivered'){
            errorFlag = false;
            errorMsg = 'Request To Get Signature Proof Of Delivery For This Shipment Cannot Be Processed.';
        }
        
        if(errorMsg != null || errorMsg != '') cmp.set("v.errorMsg1", errorMsg);
        
        //alert('Error : ' +errorMsg);
        
        if(errorFlag){ 
            alert('Inside Success');
        	var action = cmp.get("c.SPOD");
            action.setParams({
                "Shipment":JSON.stringify(cmp.get("v.shipment")),
                "myConsVar" : myConsVariable
            });    
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert('state: ' +state);
                var obj = response.getReturnValue();
                if (state === "SUCCESS") {
                    cmp.set("v.DHL_Services", obj);
                    cmp.set("v.errorMsg1", obj.Error);
                    cmp.set("v.spodLetter", response.getReturnValue().spodLetter);
                    if(response.getReturnValue().UPSErrorMsg == 'Request for ePOD processed successfully'){
                        //alert('Inside spod Success');
                    }
               } 
            }); 
            $A.enqueueAction(action);   
        }
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