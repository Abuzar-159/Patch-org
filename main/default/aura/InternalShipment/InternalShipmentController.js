({
    myAction : function(cmp, event, helper) {
        
    },
    
    handleSignatureEvent: function(cmp, event) {
        var Attachments = event.getParam("Attachments");
        // alert('Attachment ID==>'+Attachments.Id);
        
    },
    
    init :  function(cmp, event, helper) {
        console.log('Internal SHipment init called');
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        
        try{
            var action=cmp.get("c.initSetUp1");
            var packID = cmp.get("v.packageIDS"); //cmp.get("v.packageID");
            var shipID=cmp.get("v.shipmentID");
            
            action.setParams({
                'packageID':packID,    
                'shipmentid': shipID,
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide"); 
                    var showpo = $A.get("$Label.c.showcreatePO");
                    cmp.set('v.showcreatePO',showpo);
                    /* if(shipID != '' && shipID != undefined && shipID != null){
                     cmp.set('v.shipidexists',true);
                 	}*/
                    console.log(' res init : ',response.getReturnValue());
                    console.log(' hideShipment : ',response.getReturnValue().hideShipment);//Asra 10/4/24
                    cmp.set('v.hideShipment',response.getReturnValue().hideShipment);//Asra 10/4/24
                    cmp.set('v.recordPOexists',response.getReturnValue().showPO);
                    cmp.set('v.HideCheckList',response.getReturnValue().isSoliPresent);
                    cmp.set('v.hideDelTab',response.getReturnValue().hideDeliveredTab);
                    cmp.set('v.allPackageList',response.getReturnValue().packageList);
                    var quntity=cmp.get('v.allPackageList');
                    console.log('quntity : ',quntity);
                    var arrquantity=[];
                    var i=0;
                    if(quntity!=null || quntity!=''){
                        var index=0;
                        for(var q in quntity){
                            console.log(quntity[index].pack);
                            if(quntity[index].pack.ERP7__Delivered_Quantity__c==null || quntity[index].pack.ERP7__Delivered_Quantity__c=='' ){
                                quntity[index].pack.ERP7__Delivered_Quantity__c=0; 
                            }  
                            quntity[index].pack.ERP7__RemaingQuantity__c=quntity[index].pack.ERP7__Quantity__c-quntity[index].pack.ERP7__Delivered_Quantity__c;  
                            index=index+1;
                        }
                    }
                    cmp.set('v.render',response.getReturnValue().renderFields);
                    console.log('render : ',response.getReturnValue().renderFields);
                    cmp.set('v.Delivered',response.getReturnValue().Delivered);
                    cmp.set('v.call',false);
                    cmp.set('v.Attachments',response.getReturnValue().attachments);
                    cmp.set('v.ShipmentFlows',response.getReturnValue().allSF);
                    cmp.set('v.fromAddress',response.getReturnValue().fromaddress);
                    cmp.set('v.toAddress',response.getReturnValue().toaddress);
                    cmp.set('v.packageList',response.getReturnValue().fetchPackage);
                    cmp.set('v.shipment',response.getReturnValue().shipment);
                    if(cmp.get('v.shipment').length > 0){
                        if(cmp.get('v.shipment[0].ERP7__Received_By__c') != '' && cmp.get('v.shipment[0].ERP7__Received_By__c') != undefined && cmp.get('v.shipment[0].ERP7__Received_By__c') != null){
                            cmp.set("v.DeliveryFN",cmp.get('v.shipment[0].ERP7__Received_By__c'));
                        }
                        if(cmp.get('v.shipment[0].ERP7__Carrier_Forwarder__c') != '' && cmp.get('v.shipment[0].ERP7__Carrier_Forwarder__c') != undefined && cmp.get('v.shipment[0].ERP7__Carrier_Forwarder__c') != null && shipID != '' && shipID != undefined && shipID != null) cmp.set('v.shipidexists',true);
                    }
                    
                    cmp.set('v.deliveryShipment',response.getReturnValue().deliveryshipmentFlow);
                    cmp.set('v.deliveryShipment[0].ERP7__Time__c',response.getReturnValue().DT);
                    cmp.set('v.pckTypePCKLST',response.getReturnValue().packageTypePicklist);
                    cmp.set('v.productunitTypePCKLST',response.getReturnValue().productUnitPicklist);
                    cmp.set('v.SSPKL',response.getReturnValue().SSPicklist);
                    
                    cmp.set('v.shipflostatus', response.getReturnValue().SFSPKLST);
                    cmp.set('v.pckLstStsOptions', response.getReturnValue().pckLstSts);
                    //cmp.find("shipmentStatus").set("v.options", response.getReturnValue().shipmentStageOption);
                    var stages = response.getReturnValue().shipmentStageOption;
                    cmp.set('v.SSpicklist',stages);
                    cmp.set('v.deliverystage', stages);
                    cmp.set('v.SelectedAttachments', response.getReturnValue().allAttachments);
                    cmp.set('v.SelectedNotes', response.getReturnValue().Notes);
                    if(cmp.find("shipType")!= undefined){
                        cmp.set("v.shiptype", response.getReturnValue().STPickList);
                    }
                    cmp.set('v.pckListStatusOptns',response.getReturnValue().pckLstStatus) ;
                    cmp.set('v.call',true);
                    cmp.set('v.showPackDimension',response.getReturnValue().showDimension);
                    cmp.set("v.WeightUnit", response.getReturnValue().WeightUnit);
                   cmp.set("v.Dimension", response.getReturnValue().DimensionUnit); 
                }
                else{
                    var errors = response.getError();
                    console.log("getShiptoContact server error : ", errors);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide"); 
                }
            });
            $A.enqueueAction(action); 
            
            var ShiptoContactAction = cmp.get("c.getShiptoContact");
            ShiptoContactAction.setParams({packId:JSON.stringify(packID)});
            ShiptoContactAction.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS"){
                    var obj = response.getReturnValue();
                    console.log('getShiptoContact response : ',response.getReturnValue());
                    cmp.set("v.ShiptoContact", obj);
                }else{
                    var errors = response.getError();
                    console.log("getShiptoContact server error : ", errors);
                }
            });
            $A.enqueueAction(ShiptoContactAction);
        }catch(error){
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide"); 
            console.log('error : ',error);
        }	
        
    }, 
    
    closeError : function(cmp, event, helper) {
        cmp.set("v.message",'');
        cmp.set("v.exceptionError",'');
    },
    
    changeToAddress: function(cmp, event, helper){
        if(cmp.get('v.toAddress[0].Id')!=null && cmp.get('v.toAddress[0].Id')!='' && cmp.get('v.toAddress[0].Id')!=undefined
           && cmp.get('v.call')){
            var toAddressID=cmp.get('v.toAddress[0].Id');
            var action=cmp.get("c.getAddress");    
            action.setParams({
                packageID:toAddressID,    
                
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set('v.toAddress',response.getReturnValue().address);
                    cmp.set('v.call',false);
                }else{
                }
            });
            $A.enqueueAction(action);   
        }
        
    },    
    
    changeFromAddress:function(cmp, event, helper){
        if(cmp.get('v.fromAddress[0].Id')!=null && cmp.get('v.fromAddress[0].Id')!='' && cmp.get('v.fromAddress[0].Id')!=undefined
           && cmp.get('v.call')){
            var fromAddressID=cmp.get('v.fromAddress[0].Id');
            var action=cmp.get("c.getAddress");    
            action.setParams({
                packageID:fromAddressID,    
                
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set('v.fromAddress',response.getReturnValue().address);
                    cmp.set('v.call',false);
                }else{
                }
            });
            $A.enqueueAction(action);   
        }
        
    },
    
    gotoOutbound: function (cmp, event, helper) {
        var url = '/apex/ERP7__OutboundLogistics' ;
        window.open(url, '_self');
    },
    
    saveShipment : function(cmp, event, helper) {
        console.log('saveShipment called');
        cmp.set('v.showSpinner',true);
        var action=cmp.get("c.saveTheShipment");   
        var shp= JSON.stringify(cmp.get('v.shipment'));
        console.log('shp b4~>'+shp);
        action.setParams({
            selShp:shp, 
            toAddress1:JSON.stringify(cmp.get('v.toAddress')),
            fromaddress1:JSON.stringify(cmp.get('v.fromAddress')),
            Packages1:JSON.stringify(cmp.get('v.packageList')),
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('saveShipment response success');
                cmp.set('v.deliveryShipment[0].ERP7__Time__c',response.getReturnValue().DT);
                cmp.set('v.shipment',response.getReturnValue().shipment);
                var stages = response.getReturnValue().shipmentStageOption;
                cmp.set("v.deliverystage", response.getReturnValue().shipmentStageOption);
                
                cmp.set('v.recordPOexists',response.getReturnValue().showPO);
                console.log('showPO : '+response.getReturnValue().showPO);
                if(cmp.get('v.shipment').length > 0) {
                    if(cmp.get('v.shipment[0].ERP7__Carrier_Forwarder__c') != '' && cmp.get('v.shipment[0].ERP7__Carrier_Forwarder__c') != undefined && cmp.get('v.shipment[0].ERP7__Carrier_Forwarder__c') != null) cmp.set('v.shipidexists',true);
                    if(cmp.get("v.DeliveryFN") != '' && cmp.get("v.DeliveryFN") != undefined && cmp.get("v.DeliveryFN") != null) cmp.set('v.shipment[0].ERP7__Received_By__c',cmp.get("v.DeliveryFN"));
                    console.log('shipidexists : '+cmp.get("v.shipidexists"));
                    console.log('showcreatePO : '+cmp.get("v.showcreatePO"));
                    cmp.set("v.message",$A.get('$Label.c.Shipment_Saved_Successfully'));
                }
                cmp.set('v.showSpinner',false);
            }
            else{
                cmp.set('v.showSpinner',false);
                cmp.set('v.errorMsgPop',response.getReturnValue().errMsg);
                console.log('error if any==>'+response.getReturnValue().errMsg);
            } 
        });
        $A.enqueueAction(action);
    },
    
    savePickUP: function(cmp, event, helper) {
        console.log('savePickUP called');
        cmp.set('v.showSpinner',true);
        var PSF= JSON.stringify(cmp.get('v.pickupShipment'));
        var action=cmp.get("c.saveSF");    
        action.setParams({
            pupSF:PSF, 
            recordType:'Pickup',    
            selShipment1:JSON.stringify(cmp.get('v.shipment')), 
            imageData:'',
            SelPackage1:JSON.stringify(cmp.get('v.packageList')),
            CreateLogistic: false,   
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                cmp.set('v.pickupShipment',undefined);
                cmp.set('v.showSpinner',false);
                cmp.set('v.showRightTwoDelivery',false);
                cmp.set('v.showRightTwoDropOff',false);
                cmp.set('v.showRightTwoPickUP',false);
                cmp.set('v.ShipmentFlows',response.getReturnValue().allSF);
                cmp.set('v.showSF',true);
                cmp.set('v.showPDSection',true);
                cmp.set('v.shipment',response.getReturnValue().shipment);
                cmp.set('v.Delivered',response.getReturnValue().Delivered);
                if(cmp.get('v.shipment').length > 0) {
                    if(cmp.get("v.DeliveryFN") != '' && cmp.get("v.DeliveryFN") != undefined && cmp.get("v.DeliveryFN") != null) cmp.set('v.shipment[0].ERP7__Received_By__c',cmp.get("v.DeliveryFN"));
                }
            }
            else{
                cmp.set('v.showSpinner',false);
                console.log('Error-->'+JSON.stringify(response.getError()));
            } 
        });
        $A.enqueueAction(action);
    },
    
    saveDSF: function(cmp, event, helper){   
        console.log('saveDSF called');
        helper.capture(cmp);
        console.log('after helper capture');
        
        cmp.set('v.showSpinner',true);
        var PSF= JSON.stringify(cmp.get('v.deliveryShipment'));
        
        console.log('saveDSF PSF~>'+PSF);
        console.log('saveDSF JSON shipment~>'+JSON.stringify(cmp.get('v.shipment')));
        console.log('saveDSF signatureData~>'+cmp.get('v.signatureData'));
        console.log('saveDSF JSON packageList~>'+JSON.stringify(cmp.get('v.packageList')));
        console.log('saveDSF HideCheckList~>'+cmp.get('v.HideCheckList'));
        var action=cmp.get("c.saveSF");    
        action.setParams({
            pupSF:PSF, 
            recordType:'Delivery',    
            selShipment1:JSON.stringify(cmp.get('v.shipment')), 
            imageData:cmp.get('v.signatureData'), 
            SelPackage1:JSON.stringify(cmp.get('v.packageList')),
            CreateLogistic: cmp.get('v.HideCheckList'),   
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response in saveDSF~>'+JSON.stringify(response.getReturnValue()));
                cmp.set('v.active1','slds-tabs--default__item'); 
                cmp.set('v.active3','slds-tabs--default__item');                                                    
                cmp.set('v.active2','slds-tabs--default__item slds-is-active');
                cmp.set('v.Attachments',response.getReturnValue().attachments);
                cmp.set('v.deliveryShipment',response.getReturnValue().deliveryshipmentFlow);
                cmp.set('v.Attachments',response.getReturnValue().attachments);
                cmp.set('v.Delivered',response.getReturnValue().Delivered);
                cmp.set('v.shipment',response.getReturnValue().shipment);
                if(cmp.get('v.shipment').length > 0) {
                    if(cmp.get("v.DeliveryFN") != '' && cmp.get("v.DeliveryFN") != undefined && cmp.get("v.DeliveryFN") != null){
                        cmp.set('v.shipment[0].ERP7__Received_By__c',cmp.get("v.DeliveryFN"));
                        if(response.getReturnValue().shipment[0].ERP7__Status__c != undefined && response.getReturnValue().shipment[0].ERP7__Status__c != null) cmp.set('v.shipment[0].ERP7__Status__c',response.getReturnValue().shipment[0].ERP7__Status__c);
                    }
                }
                cmp.set('v.refreshnow',false);
                cmp.set('v.refreshnow',true);
                cmp.set('v.showSpinner',false);
                cmp.set('v.showRightTwoDelivery',false);
                cmp.set('v.showRightTwoDropOff',false);
                cmp.set('v.showRightTwoPickUP',false);
                cmp.set('v.ShipmentFlows',response.getReturnValue().allSF);
                cmp.set('v.showPDSection',true);
                cmp.set('v.showSF',true);
                cmp.set('v.pickupShipment',undefined);
                cmp.set('v.dropoffShipment',undefined);
                cmp.set('v.refreshnow',false);
                cmp.set('v.refreshnow',true);
            }
            else{
                cmp.set('v.showSpinner',false);
                console.log('Error occured...'+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    cancelSF:function(cmp, event, helper) { 
        if(cmp.get('v.Delivered') && $A.util.isEmpty(cmp.get('v.ShipmentFlows')) ){
            cmp.set('v.showPDSection',false); 
            cmp.set('v.showRightTwoPickUP',true);
            cmp.set('v.showSF',false);
            // cmp.set("v.shipflostatus", cmp.get('v.shipflostatus'));
        }else{
            cmp.set('v.showPDSection',true);   
            if( cmp.get('v.ShipmentFlows')!=null && cmp.get('v.ShipmentFlows')!=undefined && cmp.get('v.ShipmentFlows')!='' ){
                cmp.set('v.showSF',true);
            }  
        }
        cmp.set('v.showRightTwoCheckList',false); 
        cmp.set('v.active2','slds-tabs--default__item slds-is-active');  
        cmp.set('v.active1','slds-tabs--default__item');
        cmp.set('v.active4','slds-tabs--default__item'); 
        cmp.set('v.active3','slds-tabs--default__item');   
        cmp.set('v.showSpinner',true);
        cmp.set('v.showRightOne',false);    
        cmp.set('v.showRightTwoDelivery',false);
        cmp.set('v.showRightTwoDropOff',false);
        if(cmp.get('v.ShipmentFlows')!=null && cmp.get('v.ShipmentFlows')!=undefined && cmp.get('v.ShipmentFlows')!='' ){
            cmp.set('v.showRightTwoPickUP',false);
        }
        cmp.set('v.pickupShipment',undefined);
        cmp.set('v.dropoffShipment',undefined);
        cmp.set('v.showSpinner',false);
    },
    
    NewSF:function(cmp, event, helper) { 
        cmp.set('v.showPDSection',false); 
        cmp.set('v.showRightTwoPickUP',true);
        cmp.set('v.showSF',false);
        // cmp.find("SFSPick").set("v.options", cmp.get('v.SFOption'));
    },
    
    EditSF:function(cmp, event, helper) {
        cmp.set('v.showPDSection',false);
        var SFId = event.target.id;
        cmp.set('v.showSpinner',true);
        var action=cmp.get("c.EditShipF");    
        action.setParams({
            currentSFID:SFId, 
            selShipment1:JSON.stringify(cmp.get('v.shipment')),   
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.showSpinner',false);
                if(response.getReturnValue().RT=='Delivery'){
                    
                    cmp.set('v.deliveryShipment',response.getReturnValue().EdtSF);
                    cmp.set('v.showSF',false);
                    cmp.set('v.showRightTwoDelivery',true);
                    //cmp.find("SFSDel").set("v.options", cmp.get('v.SFOption'));                                      
                }else if(response.getReturnValue().RT=='DropOff'){
                    
                    cmp.set('v.dropoffShipment',response.getReturnValue().EdtSF);
                    cmp.set('v.showSF',false);                                              
                    cmp.set('v.showRightTwoDropOff',true);
                    // cmp.find("SFSDrop").set("v.options", cmp.get('v.SFOption'));                                            
                }else if(response.getReturnValue().RT=='Pickup'){
                    cmp.set('v.pickupShipment',response.getReturnValue().EdtSF);
                    cmp.set('v.showSF',false);
                    cmp.set('v.showRightTwoPickUP',true);
                    // cmp.find("SFSPick").set("v.options", cmp.get('v.SFOption'));
                }
            }else{
                cmp.set('v.showSpinner',false);
            } 
        });
        $A.enqueueAction(action);
        
    },
    
    DeleteSF:function(cmp, event, helper) { 
        var result = confirm("Are you sure?");
        if(result){
            cmp.set('v.showSpinner',true);
            var SFId = event.target.id;
            var action=cmp.get("c.DeleteShipF");    
            action.setParams({
                currentSFID:SFId, 
                selShipment1:JSON.stringify(cmp.get('v.shipment')),   
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set('v.showSpinner',false);
                    cmp.set('v.ShipmentFlows',response.getReturnValue().allSF);
                }else{
                    cmp.set('v.showSpinner',false);
                    console.log('ERROR-->'+JSON.stringify(response.getError()));
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    toaddss:function(cmp, event, helper) { 
        cmp.set('v.call',true);    
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(cmp, event, helper) { 
        cmp.set("v.showSpinner", true); 
    },  
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(cmp,event,helper){
        cmp.set("v.showSpinner", false);
    },
    
    sectionOne : function(cmp, event, helper) { 
        helper.helperFun(cmp,event,'articleOne');
    },
    
    sectionTwo : function(cmp, event, helper) {
        helper.helperFun(cmp,event,'articleTwo');
    },
    
    sectionThree : function(cmp, event, helper) {
        helper.helperFun(cmp,event,'articleThree');
    },
    
    sectionFour : function(cmp, event, helper) {
        helper.helperFun(cmp,event,'articleFour');
    },
    rightSectionTwo: function(cmp, event, helper) {
        cmp.set('v.active2','slds-tabs--default__item slds-is-active');  
        cmp.set('v.active1','slds-tabs--default__item'); 
        cmp.set('v.showRightOne',false); 
        cmp.set('v.showRightTwo',true); 
        if(cmp.get('v.ShipmentFlows')!=null && cmp.get('v.ShipmentFlows')!=undefined && cmp.get('v.ShipmentFlows')!='' ){
            cmp.set('v.showSF',true);
        }
        cmp.set('v.showRightTwoDelivery',false);
        cmp.set('v.showRightTwoDropOff',false);
        cmp.set('v.showRightTwoPickUP',false);
        
    },
    
    rightSectionOne: function(cmp, event, helper) {
        var d='Cancelled';
        cmp.set('v.showPDSection',false);    
        cmp.set('v.showRightTwoCheckList',false);                                                    
        cmp.set('v.active2','slds-tabs--default__item'); 
        cmp.set('v.active3','slds-tabs--default__item'); 
        cmp.set('v.active4','slds-tabs--default__item');                                                  
        cmp.set('v.active1','slds-tabs--default__item slds-is-active');
        cmp.set('v.showRightOne',true); 
        cmp.set('v.showRightTwo',false); 
        cmp.set('v.showRightTwoDelivery',false);
        cmp.set('v.showRightTwoDropOff',false);
        cmp.set('v.showRightTwoPickUP',false); 
        cmp.set("v.deliverystage", cmp.get('v.SSpicklist'));
        cmp.set('v.showSF',false);                                                   
        
    },
    showrightSectionTwoPickUP:function(cmp, event, helper) { 
        cmp.set('v.showRightTwoCheckList',false); 
        cmp.set('v.showRightTwoPickUP',true);  cmp.set('v.showSF',false);
        cmp.set('v.showRightTwo',true); 
        cmp.set('v.showRightOne',false);
        cmp.set('v.showRightTwoDropOff',false); 
        cmp.set('v.showRightTwoDelivery',false); 
        cmp.set("v.shipflostatus", cmp.get('v.SFOption'));
        cmp.set('v.pickupShipment',undefined);
        
    },
    showrightSectionTwoDropOff:function(cmp, event, helper) {
        cmp.set('v.showRightTwoDropOff',true); cmp.set('v.showSF',false);
        cmp.set('v.showRightTwo',true); 
        cmp.set('v.showRightTwoDelivery',false);  
        cmp.set('v.showRightTwoPickUP',false); 
        cmp.set('v.showRightOne',false); 
        cmp.set("v.shipflostatus", cmp.get('v.SFOption'));
        //cmp.find("SFSDrop").set("v.options", cmp.get('v.SFOption'));
        cmp.set('v.dropoffShipment',undefined);
        
    },
    showrightSectionTwoDelivery:function(cmp, event, helper) {
        cmp.set('v.showPDSection',false);
        cmp.set('v.showRightTwoCheckList',false); 
        cmp.set('v.active3','slds-tabs--default__item slds-is-active');  
        cmp.set('v.active4','slds-tabs--default__item');  
        cmp.set('v.active1','slds-tabs--default__item');    
        cmp.set('v.active2','slds-tabs--default__item');   
        cmp.set('v.showRightTwoDelivery',true); cmp.set('v.showSF',false);
        cmp.set('v.showRightTwo',true);
        cmp.set('v.showRightTwoDropOff',false);
        cmp.set('v.showRightTwoPickUP',false); 
        cmp.set('v.showRightOne',false);  
        cmp.set('v.callSigInit',true);  
    },
    
    showrightSectionCheckList:function(cmp, event, helper) {
        cmp.set('v.showPDSection',false);
        cmp.set('v.active4','slds-tabs--default__item slds-is-active');
        cmp.set('v.active3','slds-tabs--default__item');  
        cmp.set('v.active1','slds-tabs--default__item');    
        cmp.set('v.active2','slds-tabs--default__item');   
        cmp.set('v.showRightTwoDelivery',false); cmp.set('v.showSF',false);
        cmp.set('v.showRightTwo',true);
        cmp.set('v.showRightTwoDropOff',false);
        cmp.set('v.showRightTwoPickUP',false); 
        cmp.set('v.showRightOne',false);
        cmp.set('v.callSigInit',false); 
        cmp.set('v.showRightTwoCheckList',true); 
        var opt=[];
        opt[0]='Delivered';
        opt[1]='Item(s) Missing';
        
        cmp.set('v.chklistopt',opt);
    },
    
    checkCurrentList:function(cmp,event,helper){
        
        var all  = event.getSource().get("v.name");
        var EQDQ=event.getSource().get("v.value");
        var enterQuantity=parseInt(EQDQ.substring(0 , all.indexOf(",")));
        var deliveredQuantity=parseInt(EQDQ.substring(EQDQ.indexOf(",") + 1)); 
        var check=isNaN(deliveredQuantity);
        if(check){deliveredQuantity=0;}
        var totalQuantity=parseInt(all.substring(0 , all.indexOf(",")));
        var currentID =parseInt(all.substring(all.indexOf(",") + 1));
        
        var aa=enterQuantity+deliveredQuantity;
        
        if(aa>totalQuantity){
            cmp.get('v.dis',false);
            var cmp=cmp.find("checkbox-01");
            var replace=[]; 
            var check = cmp.get('v.getCheckCount');
            if(check != '' && check != null && check != undefined){
                for(var key in check){
                    if(check[key]!=currentID){ replace.push(key); }
                }
            }
            cmp.set('v.getCheckCount',replace);
        }else{ 
            var count=[];
            var c = cmp.get('v.getCheckCount');
            if(c != '' && c != null && c != undefined){
                for(var key in c){ 
                    if(c[key]==currentID){ if(event.getSource().get("v.checked")) count.push(c[key]); }
                    else count.push(c[key]);
                }
            }
            if(count.includes(currentID)){ console.log('arshad'); }else{ if(event.getSource().get("v.checked")) count.push(currentID);}
            
            cmp.set('v.getCheckCount',count);
        } 
    },
    
    saveCheckList:function(cmp,event,helper){
        console.log('saveCheckList called');
        var list=cmp.get('v.allPackageList');  
        var EQ=cmp.find("EnterQuantity");
        var call='true';
        var i=0;
        var totalQuan;
        for(var q in list ){ 
            if(isNaN(list[i].pack.ERP7__Delivered_Quantity__c)){list[i].pack.ERP7__Delivered_Quantity__c=0;}
            totalQuan= parseInt(list[i].pack.ERP7__Delivered_Quantity__c)+parseInt(list[i].pack.ERP7__RemaingQuantity__c);
            if(totalQuan>list[i].pack.ERP7__Quantity__c && list[i].pack.ERP7__Status__c!='Delivered'){ 
                call='false';
                if(EQ[i]!=undefined){
                    EQ[i].setCustomValidity("Verify Qty");
                    EQ[i].reportValidity();   
                }else{
                    EQ.setCustomValidity("Verify Qty");
                    EQ.reportValidity();   
                }
                var cmp=[];
                cmp=cmp.find("checkbox-01");
                if(cmp.length!=undefined)
                { for(var c in cmp)
                {cmp[c].set("v.checked", false);}}
                if(cmp.length==undefined){cmp.set("v.checked", false);}
            }
            i=i+1;
        }
        if(call=='true' && cmp.get('v.getCheckCount') != null && cmp.get('v.getCheckCount') != '' && cmp.get('v.getCheckCount') != undefined && cmp.get("v.getCheckCount").length > 0){
            cmp.set('v.showSpinner',true);
            var list=cmp.get('v.allPackageList'); 
            var l=0;
            for(var q in list ){
                if(EQ[l]!=undefined){
                    EQ[l].setCustomValidity("");
                    EQ[l].reportValidity();
                }else{
                    EQ.setCustomValidity("");
                    EQ.reportValidity();
                }
                l=l+1;
            }
            var arr=[];
            arr= cmp.get('v.getCheckCount');
            var arrJSON=[];
            arrJSON=JSON.stringify(arr);
            var quantityValues=cmp.get('v.allquantityvalues');
            var quantiyJSON=[];
            quantiyJSON=JSON.stringify(quantityValues);
            var action=cmp.get("c.updatepackageList");    
            console.log('allPackageList : ',JSON.stringify(cmp.get('v.allPackageList')));
            action.setParams({
                pacStrId:JSON.stringify(cmp.get('v.packageList')),    
                packStr:JSON.stringify(cmp.get('v.allPackageList')),
                counts:arrJSON,
                quantityValues :quantiyJSON,   
            });
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log('saveCheckList resp success');
                    cmp.set('v.hideDelTab',response.getReturnValue().hideDeliveredTab);
                    cmp.set('v.allPackageList',response.getReturnValue().packageList);
                    cmp.set('v.getCheckCount',[]);
                    cmp.set('v.showSpinner',false);
                    var quntity=cmp.get('v.allPackageList');
                    var index=0;
                    for(var q in quntity){
                        quntity[index].pack.ERP7__RemaingQuantity__c = 0;  
                        if(quntity[index].pack.ERP7__Delivered_Quantity__c == null )quntity[index].pack.ERP7__RemaingQuantity__c=quntity[index].pack.ERP7__Quantity__c;  
                        else quntity[index].pack.ERP7__RemaingQuantity__c=quntity[index].pack.ERP7__Quantity__c-quntity[index].pack.ERP7__Delivered_Quantity__c; 
                        if(quntity[index].pack.ERP7__Delivered_Quantity__c == quntity[index].pack.ERP7__Quantity__c) cmp.set('v.checkedAll',false);
                        else cmp.set('v.checkedAll',true);
                        index=index+1;
                    }
                }else{
                    console.log('saveCheckList error');
                    cmp.set('v.hideDelTab',true);
                    cmp.set('v.showSpinner',false);
                    cmp.set('v.getCheckCount',[]);
                } 
            });
            $A.enqueueAction(action);
        }
        
    },
    
    checkDelivered : function(cmp,event,helper){
        var enterQuantity=event.currentTarget.getAttribute("value"); 
        var all=event.currentTarget.getAttribute("name"); 
        var totalQuantity=all.substring(0 , all.indexOf(","));
        var currentID = all.substring(all.indexOf(",") + 1);  
        
        if(totalQuantity>=enterQuantity){
            cmp.set('v.showSpinner',true);
            var action=cmp.get("c.updatepackageList");    
            action.setParams({
                packageId:cmp.get('v.packageList'),    
                packListID:currentID, 
                deliverdQuantity :enterQuantity, 
                
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set('v.packageList',response.getReturnValue().fetchPackage);
                    cmp.set('v.showSpinner',false);
                    
                }else{
                    cmp.set('v.showSpinner',false);
                }
            });
            $A.enqueueAction(action);
        }else{ var result = confirm($A.get('$Label.c.Delivered_quantity_Should_less_than_total_quantity'));
              var cmp=cmp.find("checkbox-01");
              cmp.find("checkbox-01").set("v.checked", false);
              
             }  
    },
    
    onClear1: function(cmp, evt, h) {
        cmp.get('v.signaturePad').clear();
    },
    
    onReadOnly: function(cmp, evt, h) {
        var signature = cmp.find('signature');
        signature.capture();
        signature.set('v.readOnly', true);
    },
    
    getSign: function(cmp, evt, h) {
        if(cmp.get('v.callSigInit')){    
            h.init(cmp);
            cmp.set('v.callSigInit',false);}
    },
    
    onScriptReady: function(cmp, evt, h) {
        h.init(cmp);
    },
    
    onCapture: function(cmp, evt, h) {
        h.capture(cmp);
    },
    
    handleTouchMove: function(cmp, evt, h) {
        evt.stopPropagation();
    },
    
    onTouch: function(cmp, evt, h) {
        h.touch(cmp);
    },
    
    onClear: function(cmp, evt, h) {
        h.clear(cmp);
    },
    
  /*  onFileUploaded : function(cmp, event, helper) {//changed by asra on 23/5
        var files = cmp.get("v.FileList");  
        console.log('onFileUploaded called');
        var file = files[0][0];
        var filek = JSON.stringify(file);
        var regID=cmp.get('v.shipment[0].Id');
        console.log('regID : ',regID);
        if (files && files.length > 0) {
            cmp.set('v.showAttachSpin', true);
            // cmp.set('v.showSpinner',true);
            var reader = new FileReader();
            reader.onloadend = function() {
                let contents = reader.result;
                let base64Mark = 'base64,';
                let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                let fileContents = contents.substring(dataStart);
                console.log('reader.result length~>'+reader.result.length);
                console.log('b4 action v.packageList : ',JSON.stringify(cmp.get('v.packageList')));
                var action = cmp.get("c.uploadFile");
                action.setParams({
                    parent:regID,
                    fileName: file.name,
                    base64Data: encodeURIComponent(fileContents),
                    contentType: file.type,
                    pckgForSoId1:JSON.stringify(cmp.get('v.packageList')),
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        console.log('upload attachment success');
                        
                        cmp.set("v.SelectedAttachments", response.getReturnValue());
                        var obj = cmp.get("v.SelectedAttachments");
                        cmp.set("v.SelectedAttachments",obj);
                        cmp.set("v.message",$A.get('$Label.c.Attachment_added_Successfully'));
                        setTimeout($A.getCallback(function () {
                            cmp.set("v.message",'');  
                        }), 5000);   
                        //cmp.init(cmp, event, helper);
                        cmp.set('v.showAttachSpin', false);
                    } else {
                        cmp.set('v.showAttachSpin', false);
                        var errors = response.getError();
                        console.log('upload attachment error~>'+errors);
                        console.log('upload attachment error msg~>'+errors[0].message);
                        cmp.set('v.exceptionError', $A.get('$Label.c.Invalid_file_or_file_size_exceeded_3_MB'));
                        setTimeout($A.getCallback(function () {
                            cmp.set('v.exceptionError','');
                        }), 5000);   
                    }
                });
                
                if(reader.result.length < 2000000){
                    $A.enqueueAction(action);
                    console.log('aftr action called'); 
                    //cmp.set("v.message","Attachment Uploading...");
                    //setTimeout($A.getCallback(function () {
                    //cmp.set("v.message",'');  
                    //}), 100);
                    setTimeout($A.getCallback(function () {//from here
                        console.log('setTimeout'); 
                    }), 1000); //till here
                }else{
                    cmp.set('v.showAttachSpin', false);
                    cmp.set('v.exceptionError', $A.get('$Label.c.Invalid_file_or_file_size_exceeded_3_MB'));
                    setTimeout($A.getCallback(function () {
                        cmp.set('v.exceptionError','');
                    }), 5000);   
                }
                let totalRequestSize = 0; // Initialize total request size
                for (let i = 0; i < reader.length; i++) {
                    let file = files[i][0];
                    totalRequestSize += file.size; // Add file size to total
                    
                    // Check if total request size exceeds 6 MB
                    if (totalRequestSize > 6000000) {
                        cmp.set("v.exceptionError", $A.get("$Label.c.Invalid_file_or_file_size_exceeded_6_MB"));
                        setTimeout(
                            $A.getCallback(function () {
                                cmp.set("v.exceptionError", "");
                            }),
                            5000
                        );
                        return;
                    }
                }
                
                
            }
            reader.readAsDataURL(file);
        }
    },*/
      onFileUploaded : function(cmp, event, helper) {
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//7
        cmp.set("v.showSpinner",true);
        try{
            let files = cmp.get("v.FileList");  
             var totalRequestSize = 0;
            for (let i = 0; i < files[0].length; i++) {
                let file = files[0][i];
               
    // Validate individual file size (max 2 MB) before processing
    if (file.size > 2000000) {
        helper.showToast("Error", "error", "File " + file.name + " exceeds the 2 MB limit.");
        cmp.set("v.showSpinner", false);
        return; // Skip processing for this file
    }
             totalRequestSize += file.size;
console.log("totalRequestSize",totalRequestSize);
            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                cmp.set("v.showSpinner", false);
                return;
            }}
console.log('FileList : ', JSON.stringify(FileList));
            let fileNameList = [];
            let base64DataList = [];
            let contentTypeList = [];
            
            if (files && files.length > 0) {
                let parentId = event.getSource().get("v.name");
                console.log('files : ',files.length);
                console.log('files[0] : ',files[0].length);
                if(files[0].length > 0){
                    for (let i = 0; i < files[0].length; i++) {
                         var totalRequestSize = 0;

       /* for ( i = 0; i < files.length; i++) {
            var fileSize = files[i][0].size;

            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + files[i][0].name + ' exceeds the 2 MB limit.');
                return;
            }

            totalRequestSize += fileSize;

            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                return;
            }
        }*/
                        console.log('i~>'+i);
                        let file = files[0][i];
                        let reader = new FileReader();
                        //reader.onloadend is asynchronous using let instead of var inside for loop arshad 
                        reader.onloadend = function() {
                            
                            console.log('inside reader.onloadend');
                            let contents = reader.result;
                            let base64Mark = 'base64,';
                            let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                            let fileContents = contents.substring(dataStart);
                           
                            
                            fileNameList.push(file.name);
                            base64DataList.push(encodeURIComponent(fileContents));
                            contentTypeList.push(file.type);

                            
                            console.log('fileNameList~>'+fileNameList.length);
                            console.log('base64DataList~>'+base64DataList.length);
                            console.log('contentTypeList~>'+contentTypeList.length);
                            
                            if(fileNameList.length == files[0].length){
                            helper.finishAllFilesUpload(parentId,fileNameList,base64DataList,contentTypeList,cmp,event,helper);
                            }else console.log('notequal');
                        }
                        reader.onerror = function() {
                            console.log('for i~>'+i+' err~>'+reader.error);
                            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//8
                            cmp.set("v.showSpinner",false);
                        };
                        reader.readAsDataURL(file);
                    }
                }
            }
        }catch(err){
            console.log("Error catch:",err);
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//9
            cmp.set("v.showSpinner",false);
        }
        
    },
    
    NewNote : function(cmp, event, helper) {
        if(cmp.get("v.Delivered")){
            cmp.set("v.errorMsgPop", "");
            cmp.set("v.NewNote",cmp.get("v.NewNoteTemp"));
            cmp.set("v.NewNote.Title", "");
            cmp.set("v.NewNote.Body", "");
            cmp.set("v.NewNote.isPrivate", false);
            var cmpTarget = cmp.find('Modalbox');
            var cmpBack = cmp.find('Modalbackdrop');
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
        }
    },
    
    DeleteRecordAT: function(cmp, event) { 
        var result = confirm("Are you sure?");
        var RecordId = event.target.id;//event.getSource().get("v.data-name");
        var ObjName =event.target.title;// event.getSource().get("v.Title");
        var index=event.target.name;
        
        if (result) {cmp.set('v.showSpinner',true);
                     var action = cmp.get("c.DeleteAT");
                     action.setParams({
                         RAId:RecordId,
                         ObjName:ObjName,
                         pckgForSoId1:JSON.stringify(cmp.get('v.packageList')),
                         index:index,
                     });
                     action.setCallback(this, function(response) {
                         var state = response.getState();
                         if (state === "SUCCESS") { 
                             cmp.set('v.showSpinner',false);
                             
                             if(ObjName == 'Attachment'){
                                 var obj = cmp.get("v.SelectedAttachments");
                                 var count;
                                 for(var x in obj){
                                     if(obj[x].Id == RecordId) { 
                                         count = x;
                                     }
                                 }
                                 obj.splice(count, 1);
                                 cmp.set("v.SelectedAttachments",obj);
                             }
                             if(ObjName == 'Note'){
                                 var obj = cmp.get("v.SelectedNotes");
                                 var count;
                                 for(var x in obj){
                                     if(obj[x].Id == RecordId) { 
                                         count = x;
                                     }
                                 }
                                 obj.splice(count, 1);
                                 cmp.set("v.SelectedNotes",obj);
                             }
                             
                         } else {
                             
                         }
                     });
                     $A.enqueueAction(action);
                    }
        
    },
    
    SaveNote : function(cmp, event, helper) {
        cmp.set("v.errorMsgPop", '');
        var cmpTarget = cmp.find('Modalbox');
        var cmpBack = cmp.find('Modalbackdrop');
        var NewNote = cmp.get("v.NewNote");
        NewNote.ParentId= cmp.get('v.shipment[0].Id');
        if(NewNote.Title == undefined || NewNote.Title == ""){ 
            cmp.set("v.errorMsgPop", "Please enter the title");
        } else{
            $A.util.removeClass(cmpBack,'slds-backdrop--open');
            $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
            var t = JSON.stringify(NewNote);
            cmp.set('v.showSpinner',true);
            var action = cmp.get("c.SaveNotes"); 
            action.setParams({NN:t,regID:cmp.get('v.shipment[0].Id'),});
            action.setCallback(this, function(response) {
                var state = response.getState();
                cmp.set("v.errorMsgPop", "");
                if (state === "SUCCESS") {
                    cmp.set('v.showSpinner',false);
                    cmp.set("v.SelectedNotes", response.getReturnValue());
                } else{
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    closeModal:function(cmp,event,helper){ 
        cmp.set("v.errorMsgPop", '');
        var cmpTarget = cmp.find('Modalbox');
        var cmpBack = cmp.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    
    hideNotification:function(cmp, event, helper){
        cmp.set("v.message",'');
        cmp.set("v.exceptionError",'');
    },
    
    newNoteDis:function(cmp, event, helper){
        
    },
    
    createPOmodal : function(cmp, event, helper){
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var shipId = cmp.get("v.shipmentID");
        var packID = cmp.get("v.packageIDS");
        if(shipId != '' && shipId != undefined){
            $A.createComponent("c:CreatePurchaseOrder",{
                "ShipmentId": cmp.get("v.shipmentID"),
                "fromshipment" : true
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide"); 
                    var body = cmp.find("body");                            
                    body.set("v.body", newCmp); 
                }
            }); 
        }
        else if((packID != '' || packID != undefined) && (shipId == '' || shipId == undefined)){
            $A.createComponent("c:CreatePurchaseOrder",{
                "ShipmentId":cmp.get("v.shipmentID"),
                "PackIds" : cmp.get("v.packageIDS"),
                "fromshipment" : true
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide"); 
                    
                    var body = cmp.find("body");                            
                    body.set("v.body", newCmp); 
                }
            }); 
        }
        
    },
   
    checkAllList : function(cmp, event, helper){
        var currentcheck = cmp.find('checkbox-all').get('v.checked');
        
        var alllst = cmp.get('v.allPackageList');
        var check=cmp.get('v.getCheckCount');
        var count = [];
        for(var x in alllst){
            if(((parseInt(alllst[x].pack.ERP7__Delivered_Quantity__c) + parseInt(alllst[x].pack.ERP7__RemaingQuantity__c)) == parseInt(alllst[x].pack.ERP7__Quantity__c)) && (parseInt(alllst[x].pack.ERP7__Delivered_Quantity__c) == parseInt(alllst[x].pack.ERP7__Quantity__c))){
                break;
            }
            else if(((parseInt(alllst[x].pack.ERP7__Delivered_Quantity__c) + parseInt(alllst[x].pack.ERP7__RemaingQuantity__c)) != parseInt(alllst[x].pack.ERP7__Quantity__c)) || (parseInt(alllst[x].pack.ERP7__Delivered_Quantity__c) < parseInt(alllst[x].pack.ERP7__Quantity__c)))	{
                alllst[x].selected = currentcheck;
                count.push(x);
            }
        }
        cmp.set('v.allPackageList',alllst);
        cmp.set('v.getCheckCount',count);
    }
})