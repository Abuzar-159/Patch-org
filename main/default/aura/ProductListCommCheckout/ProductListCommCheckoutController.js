({
	home :function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ viewHome: true});
        evt.fire(); 
    },
    
    initial : function(cmp, event, helper) {
        helper.getAddresses1(cmp,event);
        helper.getUserDetails(cmp, event);
        //helper.cartItems(cmp, event);
        //helper.UPSServices1(cmp,event);
        //helper.createSalesOrder(cmp, event);
	},
    
    openDeleteAdd : function(cmp,event){
        var modal = cmp.find("delModal");
        var modalBackdrop = cmp.find("delModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open");
        cmp.set("v.addToDel",event.currentTarget.dataset.id);
    },
    closeDeleteAdd : function(cmp,event){
        var modal = cmp.find("delModal");
        var modalBackdrop = cmp.find("delModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");        
    },
    deleteAdd : function(cmp,event,helper){
        //var valueForDel=event.getSource().get("v.value");
        var action=cmp.get("c.delAddress");
        action.setParams({addForDel:cmp.get("v.addToDel")});
        action.setCallback(this, function(response){
            var state=response.getState(); 	
            
            if(state === "SUCCESS"){ 
                //var a = cmp.get("c.initial");
        		//$A.enqueueAction(a);
        		helper.getAddresses3(cmp,event);        		
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Success',
                    'type': 'success',
                    'mode': 'dismissable',
                    'message': 'Address Deleted'
                });
                toastEvent.fire();            
                
            }else if(state == "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': "Can't delete address. This address assigned with your sales order."
                });
                toastEvent.fire();
            }
            var modal = cmp.find("delModal");
            var modalBackdrop = cmp.find("delModalBackdrop");
            $A.util.removeClass(modal,"slds-fade-in-open");
            $A.util.removeClass(modalBackdrop,"slds-backdrop_open"); 
            
        });
        $A.enqueueAction(action);
    },
    
    openUpdateAdd : function(cmp,event,helper){
        cmp.set("v.addToUpdate",event.currentTarget.dataset.id);
        helper.setFieldsForUpdate(cmp,event);
        var modal = cmp.find("EditModal");
        var modalBackdrop = cmp.find("EditModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open");        
    },
    closeUpdateAdd : function(cmp,event){
        var modal = cmp.find("EditModal");
        var modalBackdrop = cmp.find("EditModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");        
    },
    updateAddress : function(cmp,event,helper){
        helper.validatefields(cmp,event);
        if(helper.validatefields(cmp,event)){
            var name=cmp.find("name").get("v.value");
            //var mobile=cmp.find("mobile").get("v.value");
            var add1=cmp.find("add1").get("v.value");
            var add2=cmp.find("add2").get("v.value");
            var add3=cmp.find("add3").get("v.value");
            var city=cmp.find("city").get("v.value");
            var country=cmp.find("country").get("v.value");
            var state=cmp.find("state").get("v.value");
            var zip=cmp.find("zip").get("v.value");
            var action=cmp.get("c.updateAddress1");
            
            action.setParams({
                accId:cmp.get("v.AccId"), 
                name : name,
                mobile : '',
                add1 : add1,
                add2 : add2,
                add3 : add3,
                city : city,
                country : country,
                state : state,
                zip : zip,
                addId:cmp.get("v.addId"),
                conId:cmp.get("v.conId")
            });
            action.setCallback(this, function(response){
                var state=response.getState(); 
                if(state === "SUCCESS"){
                    helper.getAddresses3(cmp,event);
                    var modal = cmp.find("EditModal");
                    var modalBackdrop = cmp.find("EditModalBackdrop");
                    $A.util.removeClass(modal,"slds-fade-in-open");
                    $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Success',
                        'type': 'success',
                        'mode': 'dismissable',
                        'message': 'Address updated'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    AddAndDeliver : function(cmp,event, helper){
        cmp.set("v.hideShipping",true);
        cmp.set("v.changeAddress",false);
        helper.validatefields1(cmp,event);
        if(helper.validatefields1(cmp,event)){
            var name=cmp.find("newName11").get("v.value");
            //var mobile=cmp.find("newMobile1").get("v.value");
            var add1=cmp.find("newAdd11").get("v.value");
            var add2=cmp.find("newAdd21").get("v.value");
            var add3=cmp.find("newAdd31").get("v.value");
            var city=cmp.find("newCity1").get("v.value");
            var country=cmp.find("newCountry1").get("v.value");
            var state=cmp.find("newState1").get("v.value");
            var zip=cmp.find("newZip1").get("v.value");
            var action=cmp.get("c.updateAddress1");
            action.setParams({
                accId:cmp.get("v.AccId"), 
                name : name,
                mobile : '',
                add1 : add1,
                add2 : add2,
                add3 : add3,
                city : city,
                country : country,
                state : state,
                zip : zip,
                addId:'',
                conId:cmp.get("v.conId")
            });
            action.setCallback(this, function(response){
                var state=response.getState(); 
                if(state === "SUCCESS"){
                    var SOId=cmp.get("v.SOId");
                    var addId=response.getReturnValue();
                    helper.getAddresses2(cmp,event,SOId,addId);
                    var modal = cmp.find("addModal");
                    var modalBackdrop = cmp.find("addModalBackdrop");
                    $A.util.removeClass(modal,"slds-fade-in-open");
                    $A.util.removeClass(modalBackdrop,"slds-backdrop_open");                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    openAddAddressModal : function(cmp,event){
        var modal = cmp.find("addModal");
        var modalBackdrop = cmp.find("addModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open"); 
    },
    closeAddModal : function(cmp,event){
        var modal = cmp.find("addModal");
        var modalBackdrop = cmp.find("addModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");        
    },
    
    saveAndDeliver : function(cmp,event,helper){
        cmp.set("v.hideShipping",true);
        helper.validateNewfields(cmp,event);
        if(helper.validateNewfields(cmp,event)){
            var name=cmp.find("newName1").get("v.value");
            var mobile=cmp.find("newMobile").get("v.value");
            var add1=cmp.find("newAdd1").get("v.value");
            var add2=cmp.find("newAdd2").get("v.value");
            var add3=cmp.find("newAdd3").get("v.value");
            var city=cmp.find("newCity").get("v.value");
            var country=cmp.find("newCountry").get("v.value");
            var state=cmp.find("newState").get("v.value");
            var zip=cmp.find("newZip").get("v.value");
            var action=cmp.get("c.updateAddress1");
            action.setParams({
                accId:cmp.get("v.AccId"), 
                name : name,
                mobile : mobile,
                add1 : add1,
                add2 : add2,
                add3 : add3,
                city : city,
                country : country,
                state : state,
                zip : zip,
                addId:'',
                conId:cmp.get("v.conId")
            });
            action.setCallback(this, function(response){
                var state=response.getState(); 
                if(state === "SUCCESS"){
                    helper.getAddresses1(cmp, event);
                    //var addId=response.getReturnValue();
                    //var SOId=cmp.get("v.SOId")
                    //helper.getAddresses2(cmp,event,SOId,addId);  
                    
                    //cmp.set("v.showAddress",false);
                    //cmp.set("v.changeAddress",false);
                    
                    /*var modal = cmp.find("addModal");
                    var modalBackdrop = cmp.find("addModalBackdrop");
                    $A.util.removeClass(modal,"slds-fade-in-open");
                    $A.util.removeClass(modalBackdrop,"slds-backdrop_open");*/
                    
                    cmp.find("newAdd1").set("v.value","");
                    cmp.find("newAdd2").set("v.value","");
                    cmp.find("newAdd3").set("v.value","");
                    cmp.find("newCity").set("v.value","");
                    cmp.find("newCountry").set("v.value","--None--");
                    cmp.find("newState").set("v.value","--None--");
                    cmp.find("newZip").set("v.value","");
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Success',
                        'type': 'success',
                        'mode': 'dismissable',
                        'message': 'Address updated'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    saveAddToSO : function(cmp,event,helper){
        cmp.set("v.hideShipping",true);
        cmp.set("v.shippingNotAvailable",false);
        var SOId=cmp.get("v.SOId");
        var addId=event.currentTarget.dataset.id;
        helper.saveAddToSO(cmp,event,SOId,addId);
        cmp.set("v.changeAddress",false);
    },
    
    /*openAddAddressModal : function(cmp,event,helepr){
    },*/
    
    confirmAndPay : function(cmp, event, helper){
      	
        var currentAdd=cmp.get("v.showOneAddress");
        var SOId=cmp.get("v.SOId");
        var addId=currentAdd[0].Id;
        helper.saveAddToSO1(cmp,event,SOId,addId);
      /*  if(cmp.get("v.shippingCost") == 0){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': 'Please select a shipping service'
                });
                toastEvent.fire();
        }else{*/
         	var SOId=cmp.get("v.SOId");
            if(SOId != undefined){
                var host=$A.get("$Label.c.Host_PathCustomerPortal")
                var li=$A.get("$Label.c.CardPaymentLC");
				var url = host + li;                
                var whLink="https://"+url+"?SON="+SOId;
                window.open(whLink, '_top');
            }
            /*var cartProducts=cmp.get("v.cartProducts");
            
            //var coupon = cmp.get("v.coupon");        
            
            var action=cmp.get("c.createSO");
            action.setParams({
                AccId:cmp.get("v.AccId"),
                cartProducts : JSON.stringify(cmp.get("v.cartProducts")),
                coupon : JSON.stringify(cmp.get("v.coupon"))
            });
            action.setCallback(this, function(response){
                var state=response.getState(); 
                if(state==="SUCCESS"){
                    var SOId=response.getReturnValue().so[0].Id;
                    if(SOId != undefined){
                        var li=$A.get("$Label.c.CardPaymentLC");
                        var whLink=li+"?SON="+SOId;
                        window.open(whLink, '_top');
                    }                
                }
            });
            $A.enqueueAction(action); */   
       // }        
    },
    
    subscribe:function(cmp,event,helper){
         var action=cmp.get("c.updateSPNCheckbox");
            action.setParams({
                subsActive:cmp.get('v.changeSPN'),
            });
             action.setCallback(this,function(response){
                               var state = response.getState();
                 if(state === "SUCCESS") {
                     
                 }
                    
                 else {
                     
                 }
                     
             });
        $A.enqueueAction(action);                     
    },
    
    /*openUPSModal: function(cmp, event, helper) {
        var modal = cmp.find("UPSModal");
        var modalBackdrop = cmp.find("UPSModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open");
        helper.UPSServices1(cmp,event);
    },
    UPSCloseModal: function(cmp, event, helper) {
        var modal = cmp.find("UPSModal");
        var modalBackdrop = cmp.find("UPSModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
    },
    UPSServices1:function(cmp,event,helper){
        helper.UPSServices1(cmp, event);
    },
    
    openFedExModal: function(cmp, event, helper) {
        var modal = cmp.find("FedExModal");
        var modalBackdrop = cmp.find("FedExModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open");
        helper.FedExServices(cmp, event);
    },
    FedExCloseModal: function(cmp, event, helper) {
        var modal = cmp.find("FedExModal");
        var modalBackdrop = cmp.find("FedExModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
    },
    FedExServices:function(cmp, event, helper){
        helper.FedExServices(cmp,event);
    },*/
    
    saveEstimateToOrder: function(cmp, event) {
        var SalesOrder = cmp.get("v.SOId");	
        //alert('UPS Service In '+SalesOrder[0].Id);
        if(SalesOrder != undefined){
            cmp.set("v.UPSError", '');
        } else{
            cmp.set("v.UPSError", 'Sales order in not Found');
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        
        if(SalesOrder != undefined){            
            var RecId = SalesOrder;            
            //var rateWrapperList = cmp.get("v.shippingServices");
            //var rateWrapperList = cmp.get("v.UPS_Services.Services");
            var rateWrapperList=event.getSource().get("v.title");
            
            var rateWrapper = '';
            rateWrapper = JSON.stringify(rateWrapperList)
            var shipDate = cmp.get("v.UPS_Services.ShipmentDate");
            var AdditionalPercentage = cmp.get("v.UPS_Services.Additional");
            //alert(AdditionalPercentage);
            if(rateWrapper != ''){
                var action = cmp.get("c.UPSServiceSave");
                action.setParams({ 
                    soId: SalesOrder,
                    rateWrapperSelected: rateWrapper,
                    shipDate: shipDate,
                    additionalPercent: AdditionalPercentage
                });                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        cmp.set("v.shippingCost",response.getReturnValue());                                          
                    }
                });
                $A.enqueueAction(action);
            }           
        } 
    },
    
    changeAddress : function(cmp,event){
        cmp.set("v.shippingCost",0);
        cmp.set("v.changeAddress",true);
    },
    
    /*saveFedExEstimateToOrder: function(cmp, event) {
        
        var SalesOrder = cmp.get("v.SOId");	
        //alert('UPS Service In '+SalesOrder[0].Id);
        if(SalesOrder != undefined){
            cmp.set("v.FedExError", '');
        } else{
            cmp.set("v.FedExError", 'Sales order in not Found');
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        }
        
        if(SalesOrder != undefined){
            var RecId = SalesOrder;
            var rateWrapperList = cmp.get("v.FEDEX_Services.Services");
            var rateWrapper = '';
            for(var x in rateWrapperList){
                if(rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
            }
            var shipDate = cmp.get("v.UPS_Services.ShipmentDate");
            var AdditionalPercentage = cmp.get("v.UPS_Services.Additional");
            
            if(rateWrapper != ''){
                var action = cmp.get("c.FedServicesSave");
                action.setParams({ 
                    soId: SalesOrder,
                    rateWrapperSelected: rateWrapper, 
                    additionalPercent: AdditionalPercentage
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        cmp.set("v.shippingCost",response.getReturnValue())
                        $A.util.removeClass(cmp.find("FedExModal"),"slds-fade-in-open");
                        $A.util.removeClass(cmp.find("FedExModalBackdrop"),"slds-backdrop_open");                                            
                    }
                });
                $A.enqueueAction(action);
            }
        } 
    },*/
})