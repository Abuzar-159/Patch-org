({
    gridView :function(cmp, event, helper){
        cmp.set("v.gridView", true);
        cmp.set("v.listView", false);
        var evt = $A.get("e.c:ProductListComm_BodyToHeader");
        evt.setParams({"productView":'grid'});
        evt.fire(); 
    },
    listView :function(cmp, event, helper){
        cmp.set("v.gridView", false);
        cmp.set("v.listView", true);
        var evt = $A.get("e.c:ProductListComm_BodyToHeader");
        evt.setParams({"productView":'list'});
        evt.fire(); 
    },
    
    /*eventHandle :function(cmp, event, helper){
        
    },*/
    
    changeSort: function(cmp, event, helper){
        var sort=document.getElementById("sort_value").value;
        cmp.set("v.sortOrder",sort);
        var a = cmp.get("c.fetchProByCat");
        $A.enqueueAction(a);
    },
    
    initial : function(cmp, event, helper) {
        //Function to excute before close the window or browser
        //window.addEventListener('beforeunload', helper.beforeUnloadHandler.bind(helper));
        
        /*if(cmp.get("v.AccId") != '')
            helper.saveCookiesProdToCart(cmp, event);*/        
        
        helper.profile(cmp,event);           
        helper.getFamily(cmp,event);
        helper.subtotal(cmp,event);
		//====May be this evt is not working====	
        /*if(cmp.get("v.AccId") != ""){
            var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({"AccId":cmp.get("v.AccId")});
            evt.fire();
        }*/
        //====May be this evt is not working====
        
        if(cmp.get("v.searchText") != "" && cmp.get("v.searchText") != undefined){
            cmp.set("v.catSel","");
            var a = cmp.get("c.fetchProByCat");
            $A.enqueueAction(a);
        }else if(cmp.get("v.catSel") != ""){
            var a = cmp.get("c.fetchProByCat");
            $A.enqueueAction(a);
        }else{            
            helper.initial(cmp,event);
        }        
                  
	},
    
    next : function(cmp, event, helper)
    { /*---Pagination Next Button Click--*/
        var ProductList = cmp.get("v.listOfProduct");
        var end = cmp.get("v.end");
        var start = cmp.get("v.start");
        var pageSize = cmp.get("v.pageSize");
        var paginationList = [];
        var paginationList = ProductList.slice(end+1,end+pageSize+1);//Slicing List as page number
        start = start + pageSize;
        end = end + pageSize;
        cmp.set("v.start",start);
        cmp.set("v.end",end);
        cmp.set('v.paginationList', paginationList);
        var currentPageNumber= cmp.get('v.currentPageNumber')+1;//Current Page Number
        cmp.set('v.currentPageNumber',currentPageNumber);
        helper.helperMethodPagination(cmp, event,parseInt(currentPageNumber));
    },
    previous : function(cmp, event, helper)
    {
         /*---Pagination previous Button Click--*/
        var ProductList = cmp.get("v.listOfProduct");//All product List
        var end = cmp.get("v.end");
        var start = cmp.get("v.start");
        var pageSize = cmp.get("v.pageSize");
        var paginationList = [];
        var paginationList = ProductList.slice(start-pageSize,start);//Slicing List as page number
        start = start - pageSize;
        end = end - pageSize;
        cmp.set("v.start",start);
        cmp.set("v.end",end);
        cmp.set('v.paginationList', paginationList);
        var currentPageNumber= cmp.get('v.currentPageNumber')-1;//Current Page Number
        cmp.set('v.currentPageNumber',currentPageNumber);
        helper.helperMethodPagination(cmp, event,parseInt(currentPageNumber));//Reset Pagination
    },
     currentPage: function(cmp, event, helper) {
         /*---Pagination Number Button Click--*/
        var selectedItem = event.currentTarget;
        var pagenum = selectedItem.dataset.record;//Current Page Number
        var pageSize = cmp.get("v.pageSize");
        var ProductList = cmp.get("v.listOfProduct");//All Product List
        var start =(pagenum-1)*pageSize;
        var end = ((pagenum-1)*pageSize)+pageSize-1;
        var paginationList = ProductList.slice(start,end+1);//Slicing List as page number
        cmp.set("v.start",start);
        cmp.set("v.end",end);
        cmp.set('v.paginationList', paginationList);
        cmp.set('v.currentPageNumber', parseInt(pagenum));
        helper.helperMethodPagination(cmp, event,parseInt(pagenum));//Reset Pagination
    },
    
    productDetails :function(cmp, event, helper){
        var prodId=event.currentTarget.dataset.value; 
        /*$A.createComponent( "c:ProductListCommProductDetails", {
            "AccId":cmp.get("v.AccId"),
            "ProductId":prodId,
        }, function(newCmp) {
            if (cmp.isValid()) {
                var body = cmp.find("sldshide");
                body.set("v.body", newCmp);        
            }
        }
        );  */
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ 
            "viewProduct":true,
            "ProdId": prodId
        });
        evt.fire();
    },
    
    selectAll :function(cmp, event, helper){
        cmp.set("v.catSel","");
        cmp.set("v.searchText","");
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ "carSelNull1":true});
        evt.fire();
        var selectedHeaderCheck = event.getSource().get("v.checked");
        var getAllId = cmp.find("checkbox1");
        /*if(! Array.isArray(getAllId)){
            if(selectedHeaderCheck == true){ 
                cmp.find("checkbox1").set("v.value", true);
                cmp.set("v.counter", 1);
            }else{
                cmp.find("checkbox1").set("v.value", false);
                cmp.set("v.counter", 0);
            }
        }else{*/
        if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
                    cmp.find("checkbox1")[i].set("v.checked", true);
                    cmp.set("v.counter", getAllId.length);                    
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    cmp.find("checkbox1")[i].set("v.checked", false);
                    cmp.set("v.counter", 0);
                }
            }
       // }
       
        if (selectedHeaderCheck == true) {
           	var listofCategories = cmp.get("v.listOfCategories");
            //listofCategories.splice(0, listofCategories.length)
            var allcatog=[];
            var allCat = cmp.find("checkbox1");//.get("v.text");
            for(var i=0;i<allCat.length;i++){
                if (allCat[i].get("v.checked") == true) {
                        allcatog.push(allCat[i].get("v.value"));
                    }
            }
            cmp.set("v.listOfCategories", allcatog);
            //var category=event.getSource().get("v.value");
            //cmp.set("v.listOfCategories",category);
            var a = cmp.get("c.fetchProByCat");
        	$A.enqueueAction(a);
        }
        else if(selectedHeaderCheck == false){
            var listofCategories = cmp.get("v.listOfCategories");
            listofCategories.splice(0, listofCategories.length)
            cmp.set("v.listOfCategories", listofCategories);
        }
       
    },
    
    checkboxSelect : function(cmp, event, helper) {
       	cmp.set("v.catSel","");
        cmp.set("v.searchText","");
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ "carSelNull1":true});
        evt.fire();
        var selectedRec = event.getSource().get("v.checked");
        var getSelectedNumber = cmp.get("v.counter");
        if (selectedRec == true) getSelectedNumber++;
        else getSelectedNumber--;
        
        if(selectedRec == false) cmp.find("All").set("v.checked", false);
       
        var getAllId = cmp.find("checkbox1");
        if(getAllId.length == getSelectedNumber) cmp.find("All").set("v.checked", true);        
        cmp.set("v.counter", getSelectedNumber);        
        
        //var selectedRec = event.getSource().get("v.value");
        var listofCategories = cmp.get("v.listOfCategories");
        var category=event.getSource().get("v.value");
        if(selectedRec)	listofCategories.push(category);
        if(selectedRec == false){
            var deselect=event.getSource().get("v.value");
            var index = listofCategories.indexOf(deselect); 
            
            if (index > -1) listofCategories.splice(index,1);
        }
        cmp.set("v.listOfCategories",listofCategories);
        
        var a = cmp.get("c.fetchProByCat");
        $A.enqueueAction(a);

    },
    
    fetchProByCat :function(cmp, event, helper) {
        
        var accId=cmp.get("v.AccId");        
        
        var pageSize = cmp.get("v.pageSize");        
        var action = cmp.get("c.fetchProdByCat");
        action.setParams({
            accId :accId,
            catogeries :cmp.get("v.listOfCategories"),
            sortOrd :cmp.get("v.sortOrder"),
            searchText :cmp.get("v.searchText"),
            catSel :cmp.get("v.catSel")
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();	
            
            if(STATE === "SUCCESS"){
                cmp.set("v.listOfProduct",response.getReturnValue().prodList);
                
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
                    //if(cmp.get("v.listOfProduct").length > 0){
                    for(var i=0; i< pageSize; i++){
                        paginationList.push(response.getReturnValue().prodList[i]);
                    } 
                    //}
                    
                }
                cmp.set('v.paginationList', paginationList);
                helper.helperMethodPagination(cmp, event,'1');
                
            }
        });
        $A.enqueueAction(action);     
    },
    
    addToCart :function(cmp, event, helper){ 
        
        var cartItem=event.currentTarget.dataset.value; 
        //var guestProds=cmp.get("v.guestProds");
        //guestProds.push(cartItem);
        //var guestQuant=1;
        if(cmp.get("v.AccId") == ''){
            //========implementing cookies==========
            helper.cookieImplement(cmp, event,cartItem);            
            //========/implementing cookies==========            
            var prodList={prodId:cartItem,quan:1};
            helper.setGuestProForSubtotal(cmp,event,prodList); 
            var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({ 
                "proCartGuest":true,
                "ProdIdGuest": prodList,
                //"guestQuant": guestQuant
            });
            evt.fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                'title': 'Success',
                'type': 'success',
                'mode': 'dismissable',
                'message': 'Product added to cart'
            });
            toastEvent.fire();
            helper.subtotal(cmp,event);
            /*var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({ 
                "proCartGuest":true,
                "ProdIdGuest": cartItem,
                //"guestQuant": guestQuant
            });
            evt.fire();*/
            
           }else if(cmp.get("v.AccId") != ''){
            cmp.set("v.cartItem", cartItem);
            var action = cmp.get("c.saveCarts");
            action.setParams({
                accId : cmp.get("v.AccId"),
                prodId : cmp.get("v.cartItem")
            });
            action.setCallback(this, function(response){
                var STATE = response.getState(); 
                
                if(STATE === "SUCCESS"){  
                    //var name= cmp.find("name1");//.get("v.value");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'title': 'Success',
                        'type': 'success',
                        'mode': 'dismissable',
                        'message': 'Product added to cart'
                    });
                    toastEvent.fire();
                    helper.subtotal(cmp,event);
                    
                    var noOfItemsOnCart = response.getReturnValue().cartpickitemList.length;
                    var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                    evt.setParams({"noOfItemsOnCart":noOfItemsOnCart});
                    evt.fire(); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    setQuan: function(cmp, event, helper){
        // this method because <lightning:input> is inside iteration
      	var quant= event.target.value;
        cmp.set("v.quantity",quant);
    },
    addToCartList :function(cmp, event, helper){
      	
        var productId;
        var quantity;
        if(cmp.get("v.AccId") == ''){
            productId = event.currentTarget.dataset.value;
            quantity = parseInt(cmp.get("v.quantity"));
            
            //var guestProds=cmp.get("v.guestProds");
        	//guestProds.push(productId);
            var prodList={prodId:productId,quan:quantity};
            var evt = $A.get("e.c:ProductListCommEvent");
            evt.setParams({ 
                "proCartGuest":true,
                "ProdIdGuest": prodList,
                //"guestQuant": guestQuant
            });
            evt.fire();            
            
            /*var expDate = new Date();
    		expDate.setTime(expDate.getTime() + (10 * 24 * 60 * 60 * 1000));
    		var expires = "expires="+expDate.toUTCString();*/
            var expires = new Date(Date.now()+60*60*1000).toString();            
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
                if (c.indexOf(productId) == 0) {
                    valueOfCookies = c.substring(productId.length+1, c.length);
                    isFindCookies = true;
                    break;
                }
            }
            //==================================
            if(isFindCookies)
                var CookiesData = productId+"="+(quantity+parseInt(valueOfCookies))+"; "+expires+";";
            else
                var CookiesData = productId+"="+quantity+"; "+expires+";";
            
            document.cookie = CookiesData;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                'title': 'Success',
                'type': 'success',
                'mode': 'dismissable',
                'message': 'Product added to cart'
            });
            toastEvent.fire();
            helper.subtotal(cmp,event);
        }else{
            productId=event.currentTarget.dataset.value;
            quantity = cmp.get("v.quantity");
            helper.addToCartList(cmp,event,productId,quantity);
        }
        //helper.addToCartList(cmp,event,productId,quantity);
        
        /*var action = cmp.get('c.addTocart');
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
                helper.subtotal(cmp,event);
                
                var noOfItemsOnCart = response.getReturnValue().cartpickitemList.length;
                var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                evt.setParams({"noOfItemsOnCart":noOfItemsOnCart});
                evt.fire(); 
            }
        });
        $A.enqueueAction(action); */
    },
})