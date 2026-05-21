({	
    
    profile :function(cmp,event){
        var UserName;
        var action = cmp.get("c.getProfileId");
        action.setCallback(this, function(response){
            var STATE=response.getState();
            if(STATE === "SUCCESS"){                
                
                //if(cmp.get("v.AccId") == ""){
                    var UserName=response.getReturnValue().name;
                console.log('UserName'+UserName)
                    if(UserName != "ERP Product catalog Community Site Guest User"){                  
                        /*var evt = $A.get("e.c:ProductListCommEvent");                
                        evt.setParams({});
                        evt.fire();*/
                        var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                        evt.setParams({"UserName":UserName});
                        evt.fire();
                    }              
                    var acc=response.getReturnValue().acc;
                    if(acc.Id != undefined){
                        cmp.set("v.AccId",acc.Id); 
                        //this.initial(cmp,event);
                    }
                //}               
            }
        });
        $A.enqueueAction(action);
    },
    setGuestProdFromCookie : function(cmp,event){
        var action = cmp.get("c.getAllProducts");
        action.setCallback(this, function(response) {
            var state = response.getState();	
            
            if (state === "SUCCESS") {
                var allProdIds=response.getReturnValue().allProd;
                var prodIds=[];
                for(var i=0;i<allProdIds.length;i++){
                    prodIds.push(allProdIds[i].Product2.Id);
                }
                
                var guestProds=[];
                var guestProds1=[];
                var valueOfCookies;
                var decodedCookie = decodeURIComponent(document.cookie);
                var ca = decodedCookie.split(';');
                for(var k=0; k < prodIds.length; k++){
                    var proId = prodIds[k];
                    for(var i = 0; i < ca.length; i++) {
                        var c = ca[i];
                        while (c.charAt(0) == ' ') {
                            c = c.substring(1);
                        }
                        if (c.indexOf(proId) == 0) { 
                            valueOfCookies = c.substring(proId.length+1, c.length);
                            guestProds.push({prodId:proId,quan:parseInt(valueOfCookies)});
                            guestProds1.push(proId);
                        }
                    }
                }
                var evt = $A.get("e.c:ProductListCommEvent");
                evt.setParams({ 
                    "proGuestCookie1":true,
                    "guestProdsBody": guestProds
                });
                evt.fire();
                //cmp.set("v.guestProds",guestProds);
                noOfItemsOnCart = guestProds1.length;
                var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                evt.setParams({
                    "guestProdsSetted":true,
                    "guestProdsForHeader":guestProds1,
                    "noOfItemsOnCart":noOfItemsOnCart
                });
                evt.fire();
            }
        });
        $A.enqueueAction(action); 
    },
    
    initial : function(cmp, event){
      	var accId=cmp.get("v.AccId");           
        var pageSize = cmp.get("v.pageSize");
        var action = cmp.get("c.productFetch");  
        action.setParams({
            accId : accId,
            sortOrd :cmp.get("v.sortOrder")
        });
        action.setCallback(this, function(response){
            var STATE=response.getState();
            if(STATE === "SUCCESS"){
                
                cmp.set("v.listOfProduct",response.getReturnValue().prodList);
                
                //cmp.set("v.attFile",response.getReturnValue().attFile);
                
                cmp.set("v.totalSize", cmp.get("v.listOfProduct").length);
                cmp.set("v.start",0);
                cmp.set("v.end",pageSize-1);
                var paginationList = [];
                if(response.getReturnValue().length < pageSize){
                    paginationList=response.getReturnValue().prodList;
                }
                else{
                    if(cmp.get("v.listOfProduct").length <= 12){
                        pageSize = cmp.get("v.listOfProduct").length;
                    }
                    for(var i=0; i< pageSize; i++){
                        paginationList.push(response.getReturnValue().prodList[i]);
                    } 
                }
                cmp.set('v.paginationList', paginationList);
                this.helperMethodPagination(cmp, event,'1');
                this.saveCookiesProdToCart(cmp, event);
                if(cmp.get("v.AccId") == ''){	//previosly this was in "ProductListCommController"
                	this.setGuestProdFromCookie(cmp,event); 
                }
                //=================category===========================
                var category=[];
                var proList = cmp.get("v.listOfProduct");
                for(i=0;i<proList.length;i++){
                    if(proList[i].pbe.Product2.ERP7__Category__c != undefined){                        
                        if(category.length > 0){
                            for(var j=0;j<category.length;j++){
                                if(category[j] != proList[i].pbe.Product2.ERP7__Category__c) {
                                    category.push(proList[i].pbe.Product2.ERP7__Category__c); 
                                    break;
                                }
                                //break;
                            }                          
                        }
                        else{
                            category.push(proList[i].pbe.Product2.ERP7__Category__c);
                        }
                    }                    
                }
                var unique = category.filter((v, i, a) => a.indexOf(v) === i);
                var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                evt.setParams({
                    "catFetch":true,
                    "Catogeries":unique
                });
                evt.fire();
                //==================category===========================
                
            }
        });
        $A.enqueueAction(action);   
    },
    
    getFamily:function(cmp,event){
        var action = cmp.get('c.getFamilyList');
        //var action = cmp.get('c.getCatList');
      	action.setCallback(this, function(response) {
        var state = response.getState();	
            
        if (state === "SUCCESS") {
          	cmp.set('v.familyList', response.getReturnValue());
        }
      });
      $A.enqueueAction(action); 
    },
    
    saveCookiesProdToCart : function(cmp,event){
        var accId =cmp.get("v.AccId");
        if(accId != ''){
            var listOfProduct=cmp.get("v.listOfProduct");
            var decodedCookie = decodeURIComponent(document.cookie);
        	var ca = decodedCookie.split(';');
            for(var k=0; k < listOfProduct.length; k++){
                var proId = listOfProduct[k].pbe.Product2.Id;
                for(var i = 0; i < ca.length; i++) {
                var c = ca[i];
                
                while (c.charAt(0) == ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(proId) == 0) {
                    
                    var quantity=c.substring(proId.length+1, c.length);
                    this.addToCartList(cmp,event,proId,quantity);
                    //delete cookies
                    document.cookie = proId +'=; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
                }
        	}
            }            
        //}else{
            /**Delete Cookies which product are not matched with related price book entry**/
            /*
             
            var listOfProduct=cmp.get("v.listOfProduct");
            var decodedCookie = decodeURIComponent(document.cookie);
        	var ca = decodedCookie.split(';');
            for(var k=0; k < listOfProduct.length; k++){
                var proId = listOfProduct[k].pbe.Product2.Id;
                for(var i = 0; i < ca.length; i++) {
                    var c = ca[i];
                    while (c.charAt(0) == ' ') {
                        c = c.substring(1);
                    }
                    if (c.indexOf(proId) == 0) { 
                        //delete cookies
                        document.cookie = proId +'=; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
                    }
                }
            }*/
            this.deleteCookieWhenProNotMatch(cmp,event);
        }
    },
    
    deleteCookieWhenProNotMatch :function(cmp,event){
        var action = cmp.get("c.getAllProducts");
        action.setCallback(this, function(response) {
            var state = response.getState();	
        if (state === "SUCCESS") {
            var allProdIds=response.getReturnValue().allProd;
            var prodIds=[];
            for(var i=0;i<allProdIds.length;i++){
                prodIds.push(allProdIds[i].Product2.Id);
            }
            
            var decodedCookie = decodeURIComponent(document.cookie);
            var ca = decodedCookie.split(';');
            for(var k=0; k < prodIds.length; k++){
                var proId = prodIds[k];
                for(var i = 0; i < ca.length; i++) {
                    var c = ca[i];
                    while (c.charAt(0) == ' ') {
                        c = c.substring(1);
                    }
                    if (c.indexOf(proId) == 0) { 
                        document.cookie = proId +'=; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
                    }
                }
            }
        }
      });
      $A.enqueueAction(action);         
    },
    /*setAccToHeader :function(cmp,event){
        var evt = $A.get("e.c:ProductListComm_BodyToHeader");
        evt.setParams({"accId":cmp.get("v.AccId")});
        evt.fire(); 
    },    */
    
    helperMethodPagination :function(cmp, event,pageNumber){
        var pageSize = cmp.get("v.pageSize");//Number Of Row Per Page
        var totalpage=Math.ceil(cmp.get("v.listOfProduct").length/pageSize);//Number Of Total Pages
        var paginationPageNumb=[];
        var cont=1;
        /*---Pagination Logic Start--*/
        if(pageNumber<7){
            for(var i=1; i<= totalpage; i++){
                paginationPageNumb.push(i);
                if(cont>7){
                    paginationPageNumb.push('...');
                    paginationPageNumb.push(totalpage);
                    break;
                }
                cont++;
            }
        }
        else{
            paginationPageNumb.push('1');
            paginationPageNumb.push('2');
            paginationPageNumb.push('...');
            pageNumber=(pageNumber<=0)?2:((pageNumber>=totalpage)? (totalpage-3) :(( pageNumber==totalpage-1 )?(pageNumber = pageNumber-2):( (pageNumber==totalpage-2 ) ? (pageNumber-1):pageNumber ))) ;
            for(var i=pageNumber-2; i<=pageNumber+2 ; i++){
                paginationPageNumb.push(i);
            }
            paginationPageNumb.push('...');
            paginationPageNumb.push(totalpage);
        }
        cmp.set('v.paginationPageNumb', null);
        cmp.set('v.paginationPageNumb', paginationPageNumb);
    },
    
    subtotal : function(cmp, event) {
		
        var guestProds=cmp.get("v.guestProds");
        var guestProdsIds=[];
        for(var i=0; i<guestProds.length;i++){
            guestProdsIds.push(guestProds[i].prodId);
        }
        var action=cmp.get("c.viewCart");
        action.setParams({
            accId : cmp.get("v.AccId"),
            guestProds : guestProdsIds
        });   
        action.setCallback(this, function(response) {
            var state=response.getState();	
            
            var subTotal = 0;
            if(state === "SUCCESS"){
                //cmp.set("v.cartPickedItems",response.getReturnValue().cartproductWrapper);                
                var cartPickedItems = response.getReturnValue().cartproductWrapper;  
                for(var j=0;j<cartPickedItems.length;j++){
                    var selProduct=cartPickedItems[j];
                    
                    if(cmp.get("v.AccId") != ''){
                        subTotal +=(selProduct.cartproduct.UnitPrice * selProduct.cpiList.ERP7__Quantity__c);
                    }else if(cmp.get("v.AccId") == ''){
                        for(var i=0;i<guestProds.length;i++){
                            if(guestProds[i].prodId == selProduct.cartproduct.Product2.Id){
                                subTotal +=(selProduct.cartproduct.UnitPrice * guestProds[i].quan);
                                break;
                            }
                        }
                    }
                } 
                //cmp.set("v.SubTotal",subTotal);  
                var evt= $A.get("e.c:ProductListComm_BodyToHeader");
                evt.setParams({isSubtotal:true,Subtotal:subTotal});
                evt.fire();
            }
        });
        $A.enqueueAction(action);
	},
    
    addToCartList : function(cmp,event,productId,quantity){
      	var action = cmp.get('c.addTocart');
        action.setParams({
            accId : cmp.get("v.AccId"),
            prodId :productId,
            quant : quantity
        });
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Success',
                    'type': 'success',
                    'mode': 'dismissable',
                    'message': 'Product added to cart'
                });
                toastEvent.fire();
                this.subtotal(cmp,event);
                
                var noOfItemsOnCart = response.getReturnValue().cartpickitemList.length;
                var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                evt.setParams({"noOfItemsOnCart":noOfItemsOnCart});
                evt.fire(); 
            }
        });
        $A.enqueueAction(action);  
    },
    
    cookieImplement : function(cmp,event,cartItem){
        
        /*var expDate = new Date();
    		expDate.setTime(expDate.getTime() + (10 * 24 * 60 * 60 * 1000));
    		var expires = "expires="+expDate.toUTCString();*/
        var expires = new Date(Date.now()+60*60*1000).toString();
        var qunt = 1;
        //==================================
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        var valueOfCookies;
        var isFindCookies = false;
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(cartItem) == 0) {
                valueOfCookies = c.substring(cartItem.length+1, c.length);
                isFindCookies = true;
                break;
            }
        }
        //==================================
        if(isFindCookies)
        	var CookiesData = cartItem+"="+(qunt+parseInt(valueOfCookies))+"; "+expires+";";
        else
            var CookiesData = cartItem+"="+qunt+"; "+expires+";";
        
        document.cookie = CookiesData;
        
    },
    
    setGuestProForSubtotal : function(cmp,event,prodList){
        	var pro=prodList;
            var prodIds=cmp.get("v.guestProds");
            if(cmp.get("v.guestProds").length > 0){
                for(var i=0;i<prodIds.length;i++){
                    if(prodIds[i].prodId==pro.prodId){
                        //prodIds[i].quan +=1;
                        //cmp.set("v.noOfItemsOnCart",cmp.get("v.guestProds").length);
                        return;
                        
                    }else if(i==prodIds.length-1){
                        
                        prodIds.push(pro);
                		cmp.set("v.guestProds",prodIds);
                        //cmp.set("v.noOfItemsOnCart",cmp.get("v.guestProds").length);
                        return;
                        
                    }
                 }
            }else{
                prodIds.push(pro);
                cmp.set("v.guestProds",prodIds);
                
            }
    },
    /*beforeUnloadHandler : function(event) {
	},*/
})