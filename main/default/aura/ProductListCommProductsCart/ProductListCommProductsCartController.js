({    
    home :function(cmp, event, helper){
        //window.location.reload();
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ viewHome: true});
        evt.fire(); 
    },
    
    initial : function(cmp, event, helper) {
       
        /*var guestProds=[];
        var prod=cmp.get("v.guestProds");  
        for(var i=0;i<prod.length;i++){
            guestProds.push(prod[i].prodId);
        }*/
        if(cmp.get("v.AccId") == ''){
            helper.getAllProducts1(cmp,event);
        }else if(cmp.get("v.AccId") != ''){
            //var noOfItemsOnCart;                     
            var guestProds=[];
            var action=cmp.get("c.viewCart");
            action.setParams({
                accId : cmp.get("v.AccId"),
                guestProds:guestProds
            });   
            action.setCallback(this, function(response) {
                cmp.set("v.cartPickedItems",response.getReturnValue().cartproductWrapper);
                var lengthOfItems=cmp.get("v.cartPickedItems").length;
                if(lengthOfItems == 0){
                    cmp.set("v.isCartEmpty",true);
                }
                helper.subtotal(cmp,event);
                cmp.set("v.showContent",true);
                /*noOfItemsOnCart=cmp.get("v.cartPickedItems").length; 
                //var evt = $A.get("e.c:ProductListCommEvent"); 
                var evt = cmp.getEvent("RevProductListCommEvent"); 
                evt.setParams({noOfItemsOnCart:noOfItemsOnCart});
                evt.fire(); 
               */
                    
                });
                $A.enqueueAction(action);
        }
    },
    subTotal : function(cmp, event, helper){
        if(cmp.get("v.AccId") != ''){
            helper.subtotal(cmp,event);
        }else if(cmp.get("v.AccId") == ''){
            helper.updateCookies(cmp,event);
            helper.update_guestProds(cmp,event);            
            helper.subtotal(cmp,event);
        }
        
    },
    guestSubTotal : function(cmp,event, helper){
      	
        /*var subTotal = 0;
        var shippingCost =0;
        var totalCost;
        var cartPickedItems = cmp.get("v.cartPickedItems");
        var guestQuan = event.getSource().get("v.value");
        cmp.set("v.guestQuan",guestQuan);
        for(var j=0;j<cartPickedItems.length;j++){
            var selProduct=cartPickedItems[j];            
            
            subTotal+=(selProduct.cartproduct.UnitPrice * event.getSource().get("v.value"));
        } 
        totalCost = subTotal + shippingCost;
        cmp.set("v.subTotal",subTotal);
        cmp.set("v.shippingCost",shippingCost);
        cmp.set("v.totalCost",totalCost);     
        
        //set Subtotal to Header cart icon
        var evt= $A.get("e.c:ProductListComm_BodyToHeader");
        evt.setParams({isSubtotal:true,Subtotal:cmp.get("v.subTotal")});
        evt.fire();  */
    },
    
    removeRow:function(cmp, event, helper){
      
        //var cpiList = cmp.get("v.cartPickedItems"); 
        //var index=event.currentTarget.dataset.service;	
        
        if(cmp.get("v.AccId") != ''){
            var cpiList = cmp.get("v.cartPickedItems");
            var index=event.currentTarget.dataset.service;
            var itemsToDelete = cmp.get("v.itemsToDelete");
            var removedItem=cpiList[index];
            itemsToDelete.push(removedItem);
            cpiList.splice(index, 1);
            cmp.set("v.itemsToDelete",itemsToDelete);
            cmp.set("v.cartPickedItems", cpiList);
            helper.subtotal(cmp,event);
        }else{
            var prodForDel = event.currentTarget.getAttribute("data-value");
            var decodedCookie = decodeURIComponent(document.cookie);
        	var ca = decodedCookie.split(';');
            for(var i = 0; i < ca.length; i++) {
                var c = ca[i];
                while (c.charAt(0) == ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(prodForDel) == 0) {
                    //delete cookies
                    document.cookie = prodForDel +'=; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
                }
        	}
            cmp.set("v.proDeleted",true);
            
            var prodList={prodId:prodForDel,quan:1};
            var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({ 
                "proCartGuestDel":true,
                "ProdIdGuest": prodList,
                //"guestQuant": guestQuant
            });
            evt.fire();
            
            helper.getAllProducts1(cmp,event);
            /*var itemsToDelete = cmp.get("v.itemsToDelete");
            var removedItem=cpiList[index];
            itemsToDelete.push(removedItem);
            cpiList.splice(index, 1);
            cmp.set("v.itemsToDelete",itemsToDelete);	
            cmp.set("v.cartPickedItems", cpiList);
            helper.afterDelete(cmp,event);*/
            //helper.subtotal(cmp,event);
            /*var guestProds=cmp.get("v.guestProds");
            cpiList.splice(index, 1);
            cmp.set("v.cartPickedItems", cpiList);
            var prodId=event.currentTarget.getAttribute("data-value"); 
            for(var i=0; i<guestProds.length;i++){
                if(prodId == guestProds[i].prodId){
                    guestProds.pop(guestProds[i].prodId);
                    break;
                }
            }
            //helper.subtotal(cmp,event);
            */
        }
        
    },
    
    updateCart1 :function(cmp, event, helper){
        
        var selIdforDel=[];
        var myListforDel=cmp.get("v.itemsToDelete");
        for(var i=0;i<myListforDel.length;i++){
            var selProduct=myListforDel[i];
            selIdforDel.push(selProduct.cpiList.Id);
        }
        
        var cartQuantity =[];
        var cartPickedItems = cmp.get("v.cartPickedItems");
        for(var j=0;j<cartPickedItems.length;j++){
            var selProduct=cartPickedItems[j];
            cartQuantity.push(selProduct.cpiList);
        }     
        
        var action = cmp.get("c.cartUpdate");
        action.setParams({
            accId : cmp.get("v.AccId"),
            itemsToUpdate:cartQuantity,
            itemsToDelete:selIdforDel            
        });
        action.setCallback(this, function(response) {  
            var state = response.getState(); 
            if(state ==="SUCCESS"){
                var lengthOfItems=cmp.get("v.cartPickedItems").length;
                if(lengthOfItems == 0){
                    cmp.set("v.isCartEmpty",true);
                }
                    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Success',
                    'type': 'success',
                    'mode': 'dismissable',
                    'message': 'Cart updated successfully'
                });
                toastEvent.fire();
                var noOfItemsOnCart = cmp.get("v.cartPickedItems").length;
                var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                evt.setParams({"noOfItemsOnCart":noOfItemsOnCart});
                evt.fire(); 
            }            
        });
        $A.enqueueAction(action);
    },
    
    checkout :function(cmp, event, helper){
        
        if(cmp.get("v.PortalUser")){
            var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({ coupon:cmp.get("v.CouponRedemption"),totalCost:cmp.get("v.totalCost"),viewCheckout: true});
            evt.fire();   
        }else{
            var evt = $A.get("e.c:ProductListComm_BodyToHeader");
            evt.setParams({"showSignIn_G":true});
            evt.fire();
        }
        
    },
    
    /*eventHandler : function(cmp,event,helper){
    },*/
    
    detailPage : function(cmp, event, helper){
        var prodId=event.currentTarget.dataset.value; 
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ 
            "viewProduct":true,
            "ProdId": prodId
        });
        evt.fire();
    },
    
    applyCoupon : function(cmp, event, helper){
        var Coupon = cmp.get("v.couponCode");
        var totalCost = cmp.get("v.totalCost");
        var accountID = cmp.get("v.AccId");
        var action = cmp.get("c.applyCoupons");
        action.setParams({
            Coupon:Coupon,
            totalPrice:totalCost,
            accID:accountID
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();	
            if (state === "SUCCESS") {
                var res=response.getReturnValue();
                if(res != null){
                    cmp.set("v.CouponRedemption",response.getReturnValue());
                    cmp.set("v.couponApply",true);
                    var newTotalCost= parseFloat(cmp.get("v.totalCost")-res.ERP7__Value__c);
                    cmp.set("v.totalCost",newTotalCost);
                    cmp.set("v.appDate",res.ERP7__Redemption_Date__c);
                    cmp.set("v.amount",res.ERP7__Value__c);
                }else{
                    cmp.set("v.couponApply",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Error',
                        'type': 'error',
                        'mode': 'dismissable',
                        'message': 'Invalid Coupon Code'
                    });
                    toastEvent.fire();
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
    SignIn : function(cmp,event){
        var evt = $A.get("e.c:ProductListComm_BodyToHeader");
        evt.setParams({"showSignIn_G":true});
        evt.fire();
    },
    register : function(cmp,event){
        var evt = $A.get("e.c:ProductListComm_BodyToHeader");
        evt.setParams({"showRegister_G":true});
        evt.fire();
    },
})