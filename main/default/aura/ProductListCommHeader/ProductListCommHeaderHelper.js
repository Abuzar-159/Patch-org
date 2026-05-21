({	
    getCategory :function(cmp,event){        
        
        
        var action = cmp.get('c.getCatList');
        action.setParams({
            accId : cmp.get("v.AccId"),
            guestProds : cmp.get("v.guestProds")
        });
      	action.setCallback(this, function(response) {
            var state = response.getState(); 
        if (state === "SUCCESS") {
            /*var res=response.getReturnValue();
            for(var i=0;i<res.length;i++){
            }*/
          	//cmp.set('v.categoryList', response.getReturnValue().catList);
          	if(cmp.get("v.AccId") != '')
            	cmp.set("v.noOfItemsOnCart",response.getReturnValue().cartpickitemList.length);
            
            //showing cart items in cartIcon
            var cartItems=[];
            if(response.getReturnValue().prodList.length > 0){
                
                if(response.getReturnValue().prodList.length == 1){
                    for(var i=0 ;i<1; i++){
                        cartItems.push(response.getReturnValue().prodList[i]);
                    } 
                }else{
                    for(var i=0 ;i<2; i++){
                        cartItems.push(response.getReturnValue().prodList[i]);
                    }                       
                }
                cmp.set("v.cartItems",cartItems);
            }else{
                cmp.set("v.cartItems",cartItems);
            }   
        }
      });
      $A.enqueueAction(action); 
    },
    
    showSignIn : function(cmp, event){
        cmp.set("v.showSignIn", true);
        cmp.set("v.Action", 'Register');
        var Action = cmp.get("v.Action");
        if (Action == 'Register') cmp.set("v.ActionName", 'Register an account');
    },
    
    SignInNow : function(cmp,event){
        cmp.set("v.showSignIn", true);
        cmp.set("v.Action", 'SignIn');
        var Action = cmp.get("v.Action");
        if (Action == 'SignIn') cmp.set("v.ActionName", 'Sign In');
    },
    
    /*subtotal : function(cmp, event) {
        var action=cmp.get("c.viewCart");
        action.setParams({
            accId : cmp.get("v.AccId")
        });   
        action.setCallback(this, function(response) {
            //cmp.set("v.cartPickedItems",response.getReturnValue().cartproductWrapper);
            var subTotal = 0;
            var cartPickedItems = response.getReturnValue().cartproductWrapper;            
            for(var j=0;j<cartPickedItems.length;j++){
                var selProduct=cartPickedItems[j];
                subTotal +=(selProduct.cartproduct.UnitPrice * selProduct.cpiList.ERP7__Quantity__c);
            } 
            
            cmp.set("v.SubTotal",subTotal);            
        });
        $A.enqueueAction(action);
	},*/
})