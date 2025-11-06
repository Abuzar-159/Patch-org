({
	subtotal : function(cmp,event) {
		var subTotal = 0;
        var shippingCost =0;
        var totalCost;
        //var unitPrice=[];
        //var quantity=[];
        var cartPickedItems = cmp.get("v.cartPickedItems");   
        for(var j=0;j<cartPickedItems.length;j++){
            var selProduct=cartPickedItems[j];
            if(cmp.get("v.AccId") != ""){  
                //unitPrice.push(selProduct.cartproduct.UnitPrice);
                //quantity.push(selProduct.cpiList.ERP7__Quantity__c);
                subTotal +=(selProduct.cartproduct.UnitPrice * selProduct.cpiList.ERP7__Quantity__c);
            }else{
                var Index;
                if(cmp.get("v.proDeleted"))
                    Index=undefined;
                else
                	Index=event.getSource().get("v.title");
                //var index=event.currentTarget.get("data-Index");
                var pro=cmp.get("v.guestProds");
                for(var i=0;i<pro.length;i++){
                    if(i==Index){
                        pro[i].quan=event.getSource().get("v.value");                        
                    }
                }
                cmp.set("v.guestProds",pro);
                var pro1=cmp.get("v.guestProds");
                for(var k=0;k<pro1.length;k++){
                    if(selProduct.cartproduct.Product2Id == pro1[k].prodId)
                    	subTotal +=(selProduct.cartproduct.UnitPrice * pro1[k].quan);
                }                
            }
            
        } 
        totalCost = subTotal + shippingCost;
        cmp.set("v.subTotal",subTotal);
        cmp.set("v.shippingCost",shippingCost);
        cmp.set("v.totalCost",totalCost);     
        
        //set Subtotal to Header cart icon
        var evt= $A.get("e.c:ProductListComm_BodyToHeader");
        evt.setParams({isSubtotal:true,Subtotal:cmp.get("v.subTotal")});
        evt.fire();
	},
    
    getAllProducts1 : function(cmp,event){
        
        var action = cmp.get("c.getAllProducts");
        action.setCallback(this, function(response) { 
            var state=response.getState();	
            if(state ==="SUCCESS"){
                var allProdIds=response.getReturnValue().allProd;
                var prodIds=[];
                for(var i=0;i<allProdIds.length;i++){
                    prodIds.push(allProdIds[i].Product2.Id);
                }
                cmp.set("v.allProdIds",prodIds);
                //fetching guest products from cookies
                var guestProdsIds=[];
                var guestProds=[];
                var valueOfCookies;
                var listOfProduct=cmp.get("v.allProdIds");
                var decodedCookie = decodeURIComponent(document.cookie);
                var ca = decodedCookie.split(';');
                for(var k=0; k < listOfProduct.length; k++){
                    var proId = listOfProduct[k];
                    for(var i = 0; i < ca.length; i++) {
                        var c = ca[i];
                        while (c.charAt(0) == ' ') {
                            c = c.substring(1);
                        }
                        if (c.indexOf(proId) == 0) { 
                            valueOfCookies = c.substring(proId.length+1, c.length);
                            guestProdsIds.push(proId);
                            guestProds.push({prodId:proId,quan:parseInt(valueOfCookies)});
                        }
                    }
                }
                cmp.set("v.guestProds",guestProds);
                if(cmp.get("v.proDeleted")){
                    this.update_guestProds(cmp,event); 
                    var noOfItemsOnCart = cmp.get("v.guestProds").length;
                    var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                    evt.setParams({"noOfItemsOnCart":noOfItemsOnCart});
                    evt.fire(); 
                }                
                this.getCartProductsGuest(cmp,event,guestProdsIds)
            }
        });
        $A.enqueueAction(action);
    },
    
    getCartProductsGuest : function(cmp,event,guestProdsIds){
        
        var action=cmp.get("c.viewCart");
        action.setParams({
            accId : cmp.get("v.AccId"),
            guestProds:guestProdsIds
        });   
        action.setCallback(this, function(response) {   
            var state=response.getState();
            if(state==="SUCCESS"){
                cmp.set("v.cartPickedItems",response.getReturnValue().cartproductWrapper);
                this.subtotal(cmp,event);  
                cmp.set("v.showContent",true);
            }                      
        });
        $A.enqueueAction(action);
    },
    
    updateCookies : function(cmp,event){
      	//update the cookies, update the guestProd and fire an event to Body cmp 
      	var updatedQuan = parseInt(event.getSource().get("v.value"));
        var prodId = event.getSource().get("v.name");
        
        var expires = new Date(Date.now()+60*60*1000).toString();
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        var valueOfCookies;
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(prodId) == 0) {
                valueOfCookies = c.substring(prodId.length+1, c.length);
                var CookiesData = prodId+"="+parseInt(updatedQuan)+"; "+expires+";";
                break;
            }
        }
        document.cookie = CookiesData;   
    },
    
    update_guestProds : function(cmp, event){
        
        var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({ 
                "quanUpdated":true,
                "guestProdsUpd": cmp.get("v.guestProds"),
                //"guestQuant": guestQuant
            });
            evt.fire();
    },
    /*afterDelete : function(cmp,event){
        var selIdforDel=[];
        var myListforDel=cmp.get("v.itemsToDelete");	
        
        for(var i=0;i<myListforDel.length;i++){
            var selProduct=myListforDel[i];
            selIdforDel.push(selProduct.cartproduct.Product2Id);
        }
        var guestProds=cmp.get("v.guestProds");
        for(var j=0;j<selIdforDel.length;j++){
            for(var i=0; i<guestProds.length;i++){
                if(selIdforDel[j] == guestProds[i].prodId){
                    guestProds.pop(guestProds[i].prodId);                    
                    break;
                }
            }
        }
        cmp.set("v.guestProds",guestProds);        
        
        var guestProds11=[];
        var prod=cmp.get("v.guestProds");
        for(var i=0;i<prod.length;i++){
            guestProds11.push(prod[i].prodId);
        }
        //var noOfItemsOnCart;
        var action=cmp.get("c.viewCart");
        action.setParams({
            accId : cmp.get("v.AccId"),
            guestProds:guestProds11
        });   
        action.setCallback(this, function(response) {   
            var state=response.getState();	
            cmp.set("v.cartPickedItems",response.getReturnValue().cartproductWrapper);
            //helper.subtotal(cmp,event);*/
            /*noOfItemsOnCart=cmp.get("v.cartPickedItems").length; 
            //var evt = $A.get("e.c:ProductListCommEvent"); 
            var evt = cmp.getEvent("RevProductListCommEvent"); 
            evt.setParams({noOfItemsOnCart:noOfItemsOnCart});
            evt.fire(); 
           */
            
        /*});
        $A.enqueueAction(action);
    }*/
})