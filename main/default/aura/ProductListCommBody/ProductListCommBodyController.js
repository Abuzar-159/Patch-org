({
	eventHandle :function(cmp, event, helper){
        if(event.getParam("carSelNull1")){
            cmp.set("v.catSel","");
            return;
        }
        if(event.getParam("proCartGuestDel")){
            return;
        }
        if(event.getParam("AccId") != undefined)
        	cmp.set("v.AccId",event.getParam("AccId"));
        if(event.getParam("catSel") != undefined && event.getParam("catSel") != "")
            cmp.set("v.catSel",event.getParam("catSel"));
        
        
        if(event.getParam("quanUpdated")){
           
            cmp.set("v.guestProds",event.getParam("guestProdsUpd"));
            return;
        }  
        
        if(event.getParam("proCartGuest")){
            
            var pro=event.getParam("ProdIdGuest");
            var prodIds=cmp.get("v.guestProds");	
            if(cmp.get("v.guestProds").length > 0){
                for(var i=0;i<prodIds.length;i++){
                    
                    if(prodIds[i].prodId==pro.prodId){
                        prodIds[i].quan +=pro.quan;		//prodIds[i].quan +=1;
                        cmp.set("v.noOfItemsOnCart",cmp.get("v.guestProds").length);
                        return;
                    }else if(i==prodIds.length-1){
                        
                        prodIds.push(pro);
                		cmp.set("v.guestProds",prodIds);
                        cmp.set("v.noOfItemsOnCart",cmp.get("v.guestProds").length);
                        return;
                    }
                 }
            }else{
                prodIds.push(pro);
                cmp.set("v.guestProds",prodIds);
                cmp.set("v.noOfItemsOnCart",cmp.get("v.guestProds").length);
                return;
            }
			//var guestQuant = event.getParam("guestQuant"); 
            //cmp.set("v.guestQuant",guestQuant);
            
            
            //prodIds.push(pro);
            //var unique = prodIds.filter((v, i, a) => a.indexOf(v) === i);//fetching unique Id
            //cmp.set("v.guestProds",prodIds);
            
        }
        
        
        if(event.getParam("searchText") != "" && event.getParam("searchText") != undefined && cmp.get("v.catSel") != ""){
            if(event.getParam("productView") == 'grid'){
                cmp.set("v.gridView",true);
                cmp.set("v.listView",false);
            }else if(event.getParam("productView") == 'list'){
                cmp.set("v.gridView",false);
                cmp.set("v.listView",true);
            }
            $A.createComponent( "c:ProductListComm", {
                "AccId":cmp.get("v.AccId"),
                "searchText":event.getParam("searchText"),
                "catSel":cmp.get("v.catSel"),
                "gridView":cmp.get("v.gridView"),
                "listView":cmp.get("v.listView")
                    //"cartProducts":cmp.get("v.cartItems")
                },
                function(newCmp) {
                    if (cmp.isValid()) {
                        var body = cmp.find("sldshide");
                        body.set("v.body", newCmp);        
                    }
                }
            );
        }else if(event.getParam("searchText") != "" && event.getParam("searchText") != undefined){
            if(event.getParam("productView") == 'grid'){
                cmp.set("v.gridView",true);
                cmp.set("v.listView",false);
            }else if(event.getParam("productView") == 'list'){
                cmp.set("v.gridView",false);
                cmp.set("v.listView",true);
            }
            $A.createComponent( "c:ProductListComm", {
                	"AccId":cmp.get("v.AccId"),
                    "searchText":event.getParam("searchText"),    
                    //"cartProducts":cmp.get("v.cartItems"),
                	"gridView":cmp.get("v.gridView"),
                	"listView":cmp.get("v.listView")
                },
                function(newCmp) {
                    if (cmp.isValid()) {
                        var body = cmp.find("sldshide");
                        body.set("v.body", newCmp);        
                    }
                }
            );
        }else if(cmp.get("v.catSel") != ""){
            if(event.getParam("productView") == 'grid'){
                cmp.set("v.gridView",true);
                cmp.set("v.listView",false);
            }else if(event.getParam("productView") == 'list'){
                cmp.set("v.gridView",false);
                cmp.set("v.listView",true);
            }
            $A.createComponent( "c:ProductListComm", {
                "AccId":cmp.get("v.AccId"),
                "catSel":cmp.get("v.catSel"),
                "gridView":cmp.get("v.gridView"),
                "listView":cmp.get("v.listView")
                    //"cartProducts":cmp.get("v.cartItems")
                },
                function(newCmp) {
                    if (cmp.isValid()) {
                        var body = cmp.find("sldshide");
                        body.set("v.body", newCmp);        
                    }
                }
            );
        }else if(event.getParam("searchText") == ""){
            if(event.getParam("productView") == 'grid'){
                cmp.set("v.gridView",true);
                cmp.set("v.listView",false);
            }else if(event.getParam("productView") == 'list'){
                cmp.set("v.gridView",false);
                cmp.set("v.listView",true);
            }
            $A.createComponent( "c:ProductListComm", {
                	"AccId":cmp.get("v.AccId"),
                	"gridView":cmp.get("v.gridView"),
                	"listView":cmp.get("v.listView")
                    //"searchText":event.getParam("searchText"),    
                    //"cartProducts":cmp.get("v.cartItems")
                },
                function(newCmp) {
                    if (cmp.isValid()) {
                        var body = cmp.find("sldshide");
                        body.set("v.body", newCmp);        
                    }
                }
            );
        }
        
        if(event.getParam("viewCart")){
            $A.createComponent( "c:ProductListCommProductsCart", {
                    "AccId":cmp.get("v.AccId"),
                	"PortalUser":cmp.get("v.PortalUser"),
                	//"guestProds":cmp.get("v.guestProds"),
                	//"guestQuant":cmp.get("v.guestQuant")
                },
                function(newCmp) {
                    if (cmp.isValid()) {
                        var body = cmp.find("sldshide");
                        body.set("v.body", newCmp);        
                    }
                }
            );
        }
        
        if(event.getParam("proGuestCookie1")){
            cmp.set("v.guestProds",event.getParam("guestProdsBody"))
        }
        
        ////////////////////previosly if(event.getParam("proCartGuest")) was here////////////////////////
        
        if(event.getParam("viewHome")){
            $A.createComponent( "c:ProductListComm", {
                    "AccId":cmp.get("v.AccId"),    
                //"guestProds":cmp.get("v.guestProds") 
                    //"cartProducts":cmp.get("v.cartItems")
                },
                function(newCmp) {
                    if (cmp.isValid()) {
                        var body = cmp.find("sldshide");
                        body.set("v.body", newCmp);        
                    }
                }
            );
        }  
        if(event.getParam("viewCheckout")){
            $A.createComponent( "c:ProductListCommCheckout", {
                    "AccId":cmp.get("v.AccId"),
                	"SubTotal":event.getParam("totalCost"),
                	"coupon":event.getParam("coupon")
                },
                function(newCmp) {
                    if (cmp.isValid()) {
                        var body = cmp.find("sldshide");
                        body.set("v.body", newCmp);        
                    }
                }
            );
        }
        if(event.getParam("myOrder")){
            $A.createComponent( "c:ProductListCommMyOrders", {
                "AccId":cmp.get("v.AccId")
            }, function(newCmp) {
                if (cmp.isValid()) {
                    var body = cmp.find("sldshide");
                    body.set("v.body", newCmp);        
                }
            }
            ); 
        }
        if(event.getParam("viewProduct")){
            $A.createComponent( "c:ProductListCommProductDetails", {
                "AccId":cmp.get("v.AccId"),
                "ProductId":event.getParam("ProdId")
            }, function(newCmp) {
                if (cmp.isValid()) {
                    var body = cmp.find("sldshide");
                    body.set("v.body", newCmp);        
                }
            }
            ); 
        }
        if(event.getParam("myAccount")){
            $A.createComponent( "c:ProductListCommMyAccount", {
                "AccId":cmp.get("v.AccId")
            }, function(newCmp) {
                if (cmp.isValid()) {
                    var body = cmp.find("sldshide");
                    body.set("v.body", newCmp);        
                }
            }
            ); 
        }
    },
    
    initial :function(cmp,event,helper){
       
        //cmp.set("v.noOfItemsOnCart",0);
        //Function to excute before close the window or browser
        //window.addEventListener('beforeunload', helper.beforeUnloadHandler.bind(helper));
        /*if (performance.navigation.type == 1)
        else*/
        	//window.addEventListener('beforeunload', helper.beforeUnloadHandler.bind(helper));        
        helper.profile(cmp,event);
    },
    
    /*deleteAllCookies : function(cmp,event){
        var cookies = document.cookie.split(";");
        for (var i = 0; i < cookies.length; i++) {
            var cookie = cookies[i];
            var eqPos = cookie.indexOf("=");
            var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
            document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT";
        }
    },*/
    
})