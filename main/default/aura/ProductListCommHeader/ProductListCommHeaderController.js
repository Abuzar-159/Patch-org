({    
    
     /*HandlerProductListCommEvent: function(cmp, event, helper){
    },*/
    
	/*showHide : function(cmp, event, helper){
        helper.showHide(cmp, event, helper);
    },
    hideOnBlur : function(cmp, event, helper){
        var myMenu = cmp.find('myMenu');
        $A.util.removeClass(myMenu, 'slds-is-open');
    },*/
    home :function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ viewHome: true});
        evt.fire(); 
    },
    initial :function(cmp, event, helper){
        console.log('cmp.get("v.UserName")'+cmp.get("v.UserName"));
        if(cmp.get("v.UserName") != "GuestUser"){
            cmp.set("v.PortalUser",true);
        }
        //helper.showHide(cmp, event, helper);        
        helper.getCategory(cmp,event);
        //helper.subtotal(cmp,event);
    },
    
    sendToBody :function(cmp, event, helper){
        var searchText = document.getElementById("seachbox").value;   
        var catSel=event.currentTarget.dataset.value;
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({
            "searchText": searchText,
            "productView" : cmp.get("v.productView")
        });
        evt.fire();
    },
    sendCat : function(cmp, event, helper){
        var catSel=event.currentTarget.dataset.value;
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({
            catSel: catSel,
            productView : cmp.get("v.productView")
        });
        evt.fire();
    },
    
    viewCart1 : function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ viewCart: true});
        evt.fire();
    },
    
    checkOut :function(cmp, event, helper){
        
        if(cmp.get("v.PortalUser")){
            /*var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({ viewCheckout: true});
            evt.fire();*/
            var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({ totalCost:cmp.get("v.SubTotal"),viewCheckout: true});
            evt.fire(); 
        }else{
            cmp.set("v.errMsg","");
            var Action = event.currentTarget.getAttribute('data-Action');
            cmp.set("v.showSignIn", true);
            cmp.set("v.Action", Action);
    
            if (Action == 'SignIn') cmp.set("v.ActionName", 'Sign In');
            else if (Action == 'Register') cmp.set("v.ActionName", 'Register an account');
        }
                 
    },
    
    closeSignInModal : function(cmp,event){
        cmp.set("v.showSignIn", false);
    },
    
    /*SignInAction : function(cmp,event){
        cmp.set("v.showSignIn", true);
        cmp.set("v.Action", 'SignIn');
        var Action = cmp.get("v.Action");
        if (Action == 'SignIn') cmp.set("v.ActionName", 'Sign In');
    },*/
        
    
   /* ProductListComm_BodyToHeaderHandler:function(cmp, event, helper){

    },*/
    
    eventHandler :function(cmp, event, helper){
        
        if(event.getParam("isSubtotal"))
        	cmp.set("v.SubTotal",event.getParam("Subtotal"));
        
        if(event.getParam("accId") != undefined){
            cmp.set("v.AccId", event.getParam("accId"));
            helper.getCategory(cmp,event);
        }
        
        if(event.getParam("noOfItemsOnCart") != undefined){
            var noOfItemsOnCart = event.getParam("noOfItemsOnCart");
            cmp.set("v.noOfItemsOnCart",noOfItemsOnCart);
            helper.getCategory(cmp,event);	//for showing updated product on header icons
            /*var noOfItems = cmp.get("v.noOfItemsOnCart");
            var noOfItemsOnCart = event.getParam("noOfItemsOnCart");
            var finalItems=noOfItems+noOfItemsOnCart;
            cmp.set("v.noOfItemsOnCart",finalItems);*/
        }
        if(event.getParam("UserName") != undefined){
            cmp.set("v.UserName",event.getParam("UserName"));
            cmp.set("v.PortalUser",true);
        }
        //var cat=event.getParam("Catogeries");
        if(event.getParam("catFetch")){
            if(event.getParam("Catogeries").length > 0){
                cmp.set("v.catList",event.getParam("Catogeries"));
            }
        }
        if(event.getParam("showSignIn_G")){
            cmp.set("v.showSignIn", true);
            cmp.set("v.Action", 'SignIn');
            cmp.set("v.ActionName", 'Sign In');
        }
        if(event.getParam("showRegister_G")){
            cmp.set("v.showSignIn", true);
            cmp.set("v.Action", 'Register');
            cmp.set("v.ActionName", 'Register an account');
        }
        if(event.getParam("guestProdsSetted")){
            cmp.set("v.guestProds",event.getParam("guestProdsForHeader"));
            cmp.set("v.noOfItemsOnCart",event.getParam("noOfItemsOnCart"));
            helper.getCategory(cmp,event);
        }
        
        if(event.getParam("productView") != undefined || event.getParam("productView") != ''){
            cmp.set("v.productView",event.getParam("productView"));
        }        
        
    },
    
    eventHandle1:function(cmp, event, helper){
        if(event.getParam("hideRegister")){
            cmp.set("v.showSignIn", false);
        }
        
        if(event.getParam("actionName") != undefined){
            if (event.getParam("actionName") == 'Password Reset') 
                cmp.set("v.ActionName", 'Password Reset');
            if(event.getParam("actionName") == 'Register'){
                //cmp.set("v.errMsg","");
                cmp.set("v.showSignIn", false);
                helper.showSignIn(cmp,event);
            }else if(event.getParam("actionName") == 'SignIn'){
                cmp.set("v.showSignIn", false);
                helper.SignInNow(cmp,event);
            }
        }   
        
        if(event.getParam("proCartGuest")){
            if(cmp.get("v.AccId") == ''){
                var pro=event.getParam("ProdIdGuest");
                var guestProds = cmp.get("v.guestProds");	
                guestProds.push(pro.prodId);
                var guestProds2 = cmp.get("v.guestProds");
                var unique = guestProds2.filter((v, i, a) => a.indexOf(v) === i);
                helper.getCategory(cmp,event);
            }                     
        }
        if(event.getParam("proCartGuestDel")){
            if(cmp.get("v.AccId") == ''){
                var pro=event.getParam("ProdIdGuest");
                var guestProds = cmp.get("v.guestProds");
                guestProds.pop(pro.prodId);
                var guestProds2 = cmp.get("v.guestProds");
                var unique = guestProds2.filter((v, i, a) => a.indexOf(v) === i);
                helper.getCategory(cmp,event);
            }                     
        }
    },
    
    showSignIn: function(cmp, event, helper) {
        cmp.set("v.errMsg","");
        var Action = event.currentTarget.getAttribute('data-Action');
        cmp.set("v.showSignIn", true);
        cmp.set("v.Action", Action);

        if (Action == 'SignIn') cmp.set("v.ActionName", 'Sign In');
        else if (Action == 'Register') cmp.set("v.ActionName", 'Register an account');
        //else cmp.set("v.ActionName", 'Password Reset');

    },
    
    detailPage : function(cmp, event, helper){
        var prodId=event.currentTarget.dataset.value; 
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ 
            "viewProduct":true,
            "ProdId": prodId
        });
        evt.fire();
    },
    
    myAccount:function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({myAccount: true});
        evt.fire();
    },
    
    myOrders : function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({myOrder: true});
        evt.fire();
    }
    
})