({
	home :function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ viewHome: true});
        evt.fire(); 
    },
    
    initial : function(cmp, event, helper) {
        helper.initial(cmp, event);
	},
    
    saveAdd : function(cmp,event,helper){
        
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
            console.log('saveAdd')
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
                    helper.initial(cmp, event);
                    cmp.find("newAdd1").set("v.value","");
                    cmp.find("newAdd2").set("v.value","");
                    cmp.find("newAdd3").set("v.value","");
                    cmp.find("newCity").set("v.value","");
                    cmp.find("newCountry").set("v.value","--None--");
                    cmp.find("newState").set("v.value","--None--");
                    cmp.find("newZip").set("v.value","");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    updatePriAdd:function(cmp,event,helper){
        helper.validatefields(cmp,event);
        //var name=cmp.find("name").get("v.value");
        if(helper.validatefields(cmp,event)){
            var name=cmp.find("name").get("v.value");
            //var email=cmp.find("email").get("v.value");
            var mobile=cmp.find("mobile").get("v.value");
            var add1=cmp.find("add1").get("v.value");
            var add2=cmp.find("add2").get("v.value");
            var add3=cmp.find("add3").get("v.value");
            var city=cmp.find("city").get("v.value");
            var country=cmp.find("country").get("v.value");
            var state=cmp.find("state").get("v.value");
            var zip=cmp.find("zip").get("v.value");
            var action=cmp.get("c.updatePriAddress");
            action.setParams({
                accId:cmp.get("v.AccId"), 
                name : name,
                //email : email,
                mobile : mobile,
                add1 : add1,
                add2 : add2,
                add3 : add3,
                city : city,
                country : country,
                state : state,
                zip : zip,
                addId:cmp.get("v.priAddToUpdate"),
                conId:cmp.get("v.conId")
            });
            action.setCallback(this, function(response){
                var state=response.getState();
                if(state === "SUCCESS"){
                    helper.initial(cmp, event);
                    helper.EditCloseModal(cmp, event);
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
    
    openPriEditModal: function(cmp, event, helper) {
        cmp.set("v.priAddToUpdate",event.currentTarget.dataset.id);
        helper.setFieldsForUpdate(cmp,event);
        var modal = cmp.find("EditModal");
        var modalBackdrop = cmp.find("EditModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open");        
    },
    EditCloseModal: function(cmp, event, helper) {
        helper.initial(cmp, event);
        var modal = cmp.find("EditModal");
        var modalBackdrop = cmp.find("EditModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
        
        cmp.find("name").set("v.errors", null);
        cmp.find("mobile").set("v.errors", null);
        cmp.find("add1").set("v.errors", null);
        cmp.find("city").set("v.errors", null);
        cmp.find("zip").set("v.errors", null);
        cmp.set("v.errorMsg","");
        cmp.set("v.errorMsg1","");
    },
    openPriBillModal: function(cmp, event, helper) {
        cmp.set("v.billAddToUpdate",event.currentTarget.dataset.id);
        helper.setFieldsForUpdateBill(cmp,event);
        var modal = cmp.find("BillModal");
        var modalBackdrop = cmp.find("BillModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open");        
    },
    BillCloseModal: function(cmp, event, helper) {
        helper.initial(cmp, event);
        var modal = cmp.find("BillModal");
        var modalBackdrop = cmp.find("BillModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
        
        cmp.find("bilname").set("v.errors", null);
        cmp.find("biladd1").set("v.errors", null);
        cmp.find("bilcity").set("v.errors", null);
        cmp.find("bilzip").set("v.errors", null);
        cmp.set("v.errorMsg4","");
        cmp.set("v.errorMsg5","");
    },
    
    updateBillAdd : function(cmp,event,helper){
        helper.validatefieldsBill(cmp,event);
        //var name=cmp.find("name").get("v.value");
        if(helper.validatefieldsBill(cmp,event)){
            var name=cmp.find("bilname").get("v.value");
            //var email=cmp.find("email").get("v.value");
            //var mobile=cmp.find("mobile").get("v.value");
            var add1=cmp.find("biladd1").get("v.value");
            var add2=cmp.find("biladd2").get("v.value");
            var add3=cmp.find("biladd3").get("v.value");
            var city=cmp.find("bilcity").get("v.value");
            var country=cmp.find("bilcountry").get("v.value");
            var state=cmp.find("bilstate").get("v.value");
            var zip=cmp.find("bilzip").get("v.value");
            var action=cmp.get("c.updateBillAddress");
            action.setParams({
                accId:cmp.get("v.AccId"), 
                name : name,
                add1 : add1,
                add2 : add2,
                add3 : add3,
                city : city,
                country : country,
                state : state,
                zip : zip,
                addId:cmp.get("v.billAddToUpdate")
            });
            action.setCallback(this, function(response){
                var state=response.getState(); 
                if(state === "SUCCESS"){
                    helper.initial(cmp, event);
                    
                    var modal = cmp.find("BillModal");
                    var modalBackdrop = cmp.find("BillModalBackdrop");
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
    
    addShipAdd : function(cmp,event,helper){ 
        cmp.set("v.addNewShipAdd",true);
        var modal = cmp.find("ShipModal");
        var modalBackdrop = cmp.find("ShipModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open");        
        
    },
    
    openShipModal : function(cmp,event,helper){
        cmp.set("v.shipAddToUpdate",event.currentTarget.dataset.id);
        helper.setFieldsForUpdateShip(cmp,event);
        var modal = cmp.find("ShipModal");
        var modalBackdrop = cmp.find("ShipModalBackdrop");
        $A.util.addClass(modal,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,"slds-backdrop_open"); 
    },
    
    ShipCloseModal : function(cmp,event,helper){
        helper.initial(cmp, event);
        var modal = cmp.find("ShipModal");
        var modalBackdrop = cmp.find("ShipModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
        
        cmp.set("v.addNewShipAdd",false);
        
        cmp.find("sipname").set("v.errors", null);
        cmp.find("sipadd1").set("v.errors", null);
        cmp.find("sipcity").set("v.errors", null);
        cmp.find("sipzip").set("v.errors", null);
        cmp.set("v.errorMsg6","");
        cmp.set("v.errorMsg7","");
        
        cmp.find("sipname").set("v.value", "");
        cmp.find("sipadd1").set("v.value", "");
        cmp.find("sipadd2").set("v.value", "");
        cmp.find("sipadd3").set("v.value", "");
        cmp.find("sipcountry").set("v.value", "--None--");
        cmp.find("sipstate").set("v.value", "--None--");
        cmp.find("sipcity").set("v.value", "");
        cmp.find("sipzip").set("v.value", "");
    },
    
    updateShipAdd : function(cmp,event,helper){
        helper.validatefieldsShip(cmp,event);
        //var name=cmp.find("name").get("v.value");
        if(helper.validatefieldsShip(cmp,event)){
            var name=cmp.find("sipname").get("v.value");
            //var email=cmp.find("email").get("v.value");
            //var mobile=cmp.find("mobile").get("v.value");
            var add1=cmp.find("sipadd1").get("v.value");
            var add2=cmp.find("sipadd2").get("v.value");
            var add3=cmp.find("sipadd3").get("v.value");
            var city=cmp.find("sipcity").get("v.value");
            var country=cmp.find("sipcountry").get("v.value");
            var state=cmp.find("sipstate").get("v.value");
            var zip=cmp.find("sipzip").get("v.value");
            var action=cmp.get("c.updateShipAddress");
            if(cmp.get("v.addNewShipAdd")){
                action.setParams({
                    accId:cmp.get("v.AccId"), 
                    name : name,
                    add1 : add1,
                    add2 : add2,
                    add3 : add3,
                    city : city,
                    country : country,
                    state : state,
                    zip : zip,
                    addId:''
                });
            }else{
                action.setParams({
                    accId:cmp.get("v.AccId"), 
                    name : name,
                    add1 : add1,
                    add2 : add2,
                    add3 : add3,
                    city : city,
                    country : country,
                    state : state,
                    zip : zip,
                    addId:cmp.get("v.shipAddToUpdate")
                });
            }
            
            action.setCallback(this, function(response){
                var state=response.getState(); 
                if(state === "SUCCESS"){
                    helper.initial(cmp, event);
                    cmp.set("v.addNewShipAdd",false);
                    var modal = cmp.find("ShipModal");
                    var modalBackdrop = cmp.find("ShipModalBackdrop");
                    $A.util.removeClass(modal,"slds-fade-in-open");
                    $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
                    cmp.find("sipname").set("v.value", "");
                    cmp.find("sipadd1").set("v.value", "");
                    cmp.find("sipadd2").set("v.value", "");
                    cmp.find("sipadd3").set("v.value", "");
                    cmp.find("sipcountry").set("v.value", "--None--");
                    cmp.find("sipstate").set("v.value", "--None--");
                    cmp.find("sipcity").set("v.value", "");
                    cmp.find("sipzip").set("v.value", "");
                    
                    /*cmp.find("sipname").set("v.errors", null);
                    cmp.find("sipadd1").set("v.errors", null);
                    cmp.find("sipcity").set("v.errors", null);
                    cmp.find("sipzip").set("v.errors", null);
                    cmp.set("v.errorMsg6","");
                    cmp.set("v.errorMsg7","");*/
                    
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
        var action=cmp.get("c.delShipAddress");
        action.setParams({addForDel:cmp.get("v.addToDel")});
        action.setCallback(this, function(response){
            var state=response.getState();
            
            if(state === "SUCCESS"){ 
                //var a = cmp.get("c.initial");
        		//$A.enqueueAction(a);
        		helper.initial(cmp,event); 
                if(response.getReturnValue() == ""){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Success',
                        'type': 'success',
                        'mode': 'dismissable',
                        'message': 'Address Deleted'
                    });
                    toastEvent.fire(); 
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': response.getReturnValue()
                    });
                    toastEvent.fire(); 
                }
                           
                
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
    
})