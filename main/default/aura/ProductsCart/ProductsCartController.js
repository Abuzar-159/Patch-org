({
    back: function(component, event, helper) {
        
        $A.createComponent(
            "c:ProductList", {
                "cartItems.length":component.get("v.cartProducts"),
                "totalPrice":component.get("v.totalPrice")
            },
            function(newCmp) {
                if (component.isValid()) {
                    var body = component.find("sldshide");
                    body.set("v.body", newCmp);
                    location.reload();
                }
            }
        );
    },
    
    deleteSoli: function(component, event, helper) {
        //component.destroy();
    },
    
    ApplyCoupon : function(component, event, helper) {
        var Coupon = component.get("v.coupon");
        var totalPrice = component.get("v.totalPrice");
        var accountID = component.get("v.accID");
        var action = component.get("c.applyCoupons");
        
        action.setParams({
            Coupon:Coupon,
            totalPrice:totalPrice,
            accID:accountID
        });
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            
            
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                //totalPrice = totalPrice - (totalPrice*obj[0].ERP7__Coupon__r.ERP7__Value_In_Percent__c);
                //totalPrice = totalPrice*obj[0].ERP7__Coupon__r.ERP7__Value_In_Percent__c/100;
                var newtotalPrice = parseFloat(component.get("v.totalPrice") - obj.ERP7__Value__c);
                var objList = new Array();
                objList.push(obj);
                component.set("v.CouponRedemption",objList);
                component.set("v.totalPrice", newtotalPrice); 
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
    
    saveSalesOrder : function(component,event,helper){
        var action = component.get('c.saveSO');
        var couponRed = component.get("v.CouponRedemption");//JSON.stringify()
        action.setParams({
            "cartProducts":component.get("v.cartProducts"),//JSON.stringify()
            "accID":component.get("v.accID"),
            "profileID":component.get("v.profileID"),
            "coupon1": JSON.stringify(component.get("v.CouponRedemption"))
            
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.so', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        /*$A.createComponent(
        "c:ProductCartThankYou", {
            
        },
        function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);

            }
        }
    ); */ 
    },
    
    saveSalesOrders : function(component,event,helper){
        var action = component.get('c.saveSO');
        var couponRed = JSON.stringify(component.get("v.CouponRedemption"));
        
        action.setParams({
            "cartProducts":JSON.stringify(component.get("v.cartProducts")),
            "accID":component.get("v.accID"),
            "profileID":component.get("v.profileID"),
            "Coupon1":JSON.stringify(couponRed)
            
        });  
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.so', response.getReturnValue());
                $A.createComponent(
                    "c:CardPayment", {
                        "SON":component.get("v.so.Id")
                    },
                    function(newCmp) {
                        if (component.isValid()) {
                            var body = component.find("sldshide");
                            body.set("v.body", newCmp);
                            
                        }
                    }
                );  
                
            }
        });
        if($A.util.isEmpty(component.get('v.so.Id')))
            $A.enqueueAction(action);
        else{
            $A.createComponent(
                "c:CardPayment", {
                    "SON":component.get("v.so.Id")
                },
                function(newCmp) {
                    if (component.isValid()) {
                        var body = component.find("sldshide");
                        body.set("v.body", newCmp);
                        
                    }
                });
            
        }
        
    }
})