({
    doInit : function(component, event, helper) {
        var action=component.get("c.getIntialproducts");
        action.setCallback(this,function(response){
            component.set('v.products',response.getReturnValue());
            helper.fetchOrg(component, event, helper); 
            helper.fetchCusAddress(component, event, helper);
            helper.fetchPackageType(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    
    fetchProducs : function(component, event, helper) {
        var action=component.get("c.getseacrhedProducts");
        action.setParams({'searchItem':component.get("v.fetchProd")});
        action.setCallback(this,function(response){
            component.set('v.products',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    
    checkboxSelect: function(component, event, helper) {
        console.log(event.getSource().get('v.checked'));
        console.log(event.getSource().get('v.value'));
        var productLis= [];
        productLis = component.get("v.products");
        var selectProd = [];
        selectProd = component.get("v.selectedProduct");
        for(var i=0;i<productLis.length;i++){
            if(i==event.getSource().get('v.value') && event.getSource().get('v.checked')){
                productLis[event.getSource().get('v.value')].quantity = 1;
                selectProd.push(productLis[event.getSource().get('v.value')]);
            }else if(i==event.getSource().get('v.value') && !event.getSource().get('v.checked')){
                productLis[event.getSource().get('v.value')].quantity = 0;
                selectProd.pop(productLis[event.getSource().get('v.value')]);
            }
        }
        component.set("v.products",productLis);
        component.set("v.selectedProduct", selectProd);
    },
    
    cheboxSelect: function(component, event, helper) {
        console.log(event.getSource().get('v.checked'));
        console.log(event.getSource().get('v.value'));
        var productLis= [];
        productLis = component.get("v.products");
        var selectProd = [];
        selectProd = component.get("v.serviceList");
        var rateWrapper = '';
        for(var i=0;i<selectProd.length;i++){
            if(i==event.getSource().get('v.value') && event.getSource().get('v.checked')){
                component.set("v.ServiceName", selectProd[i].ServiceManual);
                rateWrapper = JSON.stringify(selectProd[i]);
                component.set("v.rateWrap",rateWrapper);
            }
        }
    },
    
    
    createShipment : function(component, event, helper) {
        var selectedPro = [];
        selectedPro = component.get("v.selectedProduct");
        if(selectedPro.length < 1){
            helper.showToast('Error!','error',$A.get('$Label.c.Please_select_the_products'));
            return;
        }else{
            component.set("v.displayProducts", false);
        }
    },
    
    
    toadresschange : function(component, event, helper) {
        var action=component.get("c.fetchAddress");
        action.setParams({'Id':component.get("v.toAddId")});
        action.setCallback(this,function(response){
            component.set('v.address',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    fromAddresschange : function(component, event, helper) {
        var action=component.get("c.fetchAddress");
        action.setParams({'Id':component.get("v.fromAddId")});
        action.setCallback(this,function(response){
            component.set('v.fromAddress',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    Back : function(component, event, helper) {
        component.set("v.displayProducts", true);
        var serviceList = [];
        component.set("v.selectedProduct",serviceList);
    },
    
    getR : function(component, event, helper) {
        component.set("v.showMmainSpin", true);
        var action=component.get("c.UPSServices");
        action.setParams({'shipaddress':component.get("v.address"),'packType':component.get("v.pkgType"), 'shipDate':'', 'fromaddress':component.get("v.fromAddress"), 'selectedProd':component.get("v.selectedProduct")});
        action.setCallback(this,function(response){
            console.log('Response'+JSON.stringify(response.getReturnValue()));
            component.set("v.showMmainSpin", false);
            component.set("v.serviceList",response.getReturnValue().Services);
            var serviceList = [];
            serviceList = response.getReturnValue().Services;
            if(serviceList.length < 1) component.set("v.SaveErrorMsg", response.getReturnValue().UPSErrorMsg);
            //component.set("v.displayService",true);
        });
        $A.enqueueAction(action);
    },
    
    cancelCale : function(component, event, helper) {
        component.set("v.displayService",false);
    },
    
    fetchOrgAddress : function(component, event, helper) {
        var action=component.get("c.fetchCusAddress");
        action.setParams({'Id':component.get("v.Organisation.Id")});
        action.setCallback(this,function(response){
            component.set('v.fromAddId',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    onClick : function(component, event, helper) {
        component.set("v.SaveErrorMsg", '');
    },
    
    BackToRecord : function(component, event, helper) {
        history.back();
    },
    
    createShipmentRecord : function(component, event, helper) {
        var serviceName  = component.get("v.ServiceName");
        if((serviceName != undefined) && (serviceName.includes('UPS'))) {
            $A.enqueueAction(component.get("c.createUPSShip"));
        }else{
            $A.enqueueAction(component.get("c.createFedexShip"));
        }
    },
    
    createUPSShip : function(cmp, event, helper){
        cmp.set("v.showMmainSpin", true);
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
        var action = cmp.get("c.Process_Shipment_Request_Reply");
        action.setParams({
            "packList":null,
            "fromAdd":cmp.get("v.fromAddId"),
            "toAdd":cmp.get("v.toAddId"), 
            "shipDate":todayDate, 
            "myConsVar": null,
            "Shipment":null,
            "rateWrapperSelected": cmp.get("v.rateWrap"),
            "toShipType":null,
            "frShipType":null,
            "selectedProd":cmp.get("v.selectedProduct"),
            "AccId":cmp.get("v.AccId")
        });
        
        action.setCallback(this, function(response){
            cmp.set("v.showMmainSpin", false);
            if (response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                console.log('Shipping_Request response~>',response.getReturnValue().request);
                console.log('Shipping_Request upsW.Error~>'+obj.Error);
                cmp.set("v.SaveErrorMsg", obj.Error);
                if(obj.Error == ''){
                    var fileName;
                    fileName = 'UPS_Label';
                    var val = 'pdf';
                    var viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+response.getReturnValue().Shipment.Id+'&fileName='+fileName+'&val='+val;
                    window.open(viewLabel,'_self');
                }
            }else{
                var errors = response.getError();
                console.log("Shipping_Request server error : ", errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    createFedexShip : function(cmp, event, helper){
        cmp.set("v.showMmainSpin", true);
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
        var action = cmp.get("c.Shipping_Request_Reply");
        action.setParams({
            "packList":null,
            "fromAdd":cmp.get("v.fromAddId"),
            "toAdd":cmp.get("v.toAddId"), 
            "ShipDateStamp":todayDate, 
            "myConsVar": null,
            "Shipment":null,
            "rateWrapperSelected": cmp.get("v.rateWrap"),
            "selectedProd":cmp.get("v.selectedProduct")
        });
        
        action.setCallback(this, function(response){
            cmp.set("v.showMmainSpin", false);
            if (response.getState() === "SUCCESS"){
                var obj = response.getReturnValue();
                console.log('Shipping_Request response~>',response.getReturnValue().request);
                console.log('Shipping_Request upsW.Error~>'+obj.Error);
                cmp.set("v.SaveErrorMsg", obj.Error);
                if(obj.Error == ''){
                    var fileName;
                    fileName = 'Fedex_Label';
                    var val = 'pdf';
                    var viewLabel = '/apex/ERP7__PrintUPSLabel?shipmentsId='+response.getReturnValue().Shipment.Id+'&fileName='+fileName+'&val='+val;
                    window.open(viewLabel,'_self');
                }
            }else{
                var errors = response.getError();
                console.log("Shipping_Request server error : ", errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    
})