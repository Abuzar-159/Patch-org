({
    initial : function(cmp, event, helper) {
        var prodId=cmp.get("v.ProductId");
        var action = cmp.get('c.productDetails');
        action.setParams({
            accId : cmp.get("v.AccId"),
            prodId :prodId
        });
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.prodDetail",response.getReturnValue().prodList);
                cmp.set("v.attFile",response.getReturnValue().attFile);
                cmp.set("v.conDocFile",response.getReturnValue().conDocFile);
                cmp.set("v.relProd",response.getReturnValue().relatedProd);
                cmp.set("v.RId",response.getReturnValue().prodList[0].pbe.Product2.ERP7__Routing__c);
                cmp.set("v.prodConfig",response.getReturnValue().prodList[0].pbe.Product2.ERP7__Configure__c);
                
                if(cmp.get("v.prodConfig")){
                    //helper.ConfigurePro(cmp, event);
                    helper.ConfigurePro1(cmp, event);
                }   
            }
            
        });
        $A.enqueueAction(action);
    },
    
    home : function(cmp, event, helper){
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({"viewHome":true});
        evt.fire();
    },
    
    detailPage :function(cmp, event, helper){
        var prodId=event.currentTarget.dataset.value;
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({
            "viewProduct":true,
            "ProdId":prodId,
        });
        evt.fire();
    },
    
    addTocart1 :function(cmp, event, helper){
        
        if(cmp.get("v.prodConfig") && cmp.get("v.AccId") == ""){
            if(cmp.get("v.openConModal")){
                var modal = cmp.find("EditModal");
                var modalBackdrop = cmp.find("EditModalBackdrop");
                $A.util.addClass(modal,"slds-fade-in-open");
                $A.util.addClass(modalBackdrop,"slds-backdrop_open");
                return;
            }            
        }
        
        if(cmp.get("v.prodConfig") && cmp.get("v.AccId") != ""){
            //helper.ConfirmConfiguration(cmp,event);
            helper.ConfirmConfiguration1(cmp,event);
        }        
        else{
            var quantity = cmp.find("quant").get("v.value");	
            
            if(cmp.get("v.AccId") == ''){
                
                var prodList={prodId:cmp.get("v.ProductId"),quan:quantity};
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
                    if (c.indexOf(cmp.get("v.ProductId")) == 0) {
                        valueOfCookies = c.substring(cmp.get("v.ProductId").length+1, c.length);
                        isFindCookies = true;
                        break;
                    }
                }
                //==================================
                if(isFindCookies)
                    var CookiesData = cmp.get("v.ProductId")+"="+(quantity+parseInt(valueOfCookies))+"; "+expires+";";
                else
                    var CookiesData = cmp.get("v.ProductId")+"="+quantity+"; "+expires+";";
                
                document.cookie = CookiesData;
            }else{
                var action = cmp.get('c.addTocart');
                action.setParams({
                    accId : cmp.get("v.AccId"),
                    prodId :cmp.get("v.ProductId"),
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
                $A.enqueueAction(action); 
            }             
        }        
    },
    
    addToCart2 :function(cmp, event, helper){
        var cartItem=event.currentTarget.dataset.value; 
        //cmp.set("v.cartItem", cartItem);
        if(cmp.get("v.AccId") == ''){
            helper.cookieImplement(cmp, event,cartItem);         
            var prodList={prodId:cartItem,quan:1};
            //helper.setGuestProForSubtotal(cmp,event,prodList); 
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
        }else if(cmp.get("v.AccId") != ''){
            var action = cmp.get("c.saveCarts");
            action.setParams({
                accId : cmp.get("v.AccId"),
                prodId : cartItem
            });
            action.setCallback(this, function(response){
                var STATE = response.getState(); 
                
                if(STATE === "SUCCESS"){
                    var noOfItemsOnCart = response.getReturnValue().cartpickitemList.length;
                    var evt = $A.get("e.c:ProductListComm_BodyToHeader");
                    evt.setParams({"noOfItemsOnCart":noOfItemsOnCart});
                    evt.fire(); 
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    handleChange : function(cmp,event,helper){
        var currentTarget=event.currentTarget.dataset.value;
        helper.disableOthers(cmp,event,currentTarget);
    },
    
    no : function(cmp, event) {
        var modal = cmp.find("EditModal");
        var modalBackdrop = cmp.find("EditModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
        cmp.set("v.openConModal",false);
        var a = cmp.get("c.addTocart1");
        $A.enqueueAction(a);
        //this.initial(cmp, event);
    },
    no1 : function(cmp, event) {
        var modal = cmp.find("EditModal");
        var modalBackdrop = cmp.find("EditModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");        
    },
    
    yes : function(cmp,event){
        var modal = cmp.find("EditModal");
        var modalBackdrop = cmp.find("EditModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
        
        var evt = $A.get("e.c:ProductListComm_BodyToHeader");
        evt.setParams({"showSignIn_G":true});
        evt.fire();
    },
    /*enabledOthers : function(cmp, event, helper){
        var currentTarget=event.currentTarget.dataset.value;
        helper.disableOthers(cmp,event,currentTarget);
        
        var proforConfig=cmp.get("v.ProductId");
        var action=cmp.get("c.getAllOptionRules");
        action.setParams({proId : proforConfig});
        action.setCallback(this, function(response){
            var state=response.getState();		
            if(state ==="SUCCESS"){
                var optionRules=response.getReturnValue().optionRules;
                if(optionRules.length > 0){
                    for(var i=0;i<optionRules.length;i++){
                        if(optionRules[i].ERP7__Type__c == "Dependency"){
                            var parent=optionRules[i].ERP7__Parent_Option__c;
                            var child=optionRules[i].ERP7__Child_Option__c;
                            var parentName=optionRules[i].ERP7__Parent_Option__r.ERP7__Optional_SKU__r.Name;
                            
                            if(currentTarget == parent){
                                if(document.getElementById(currentTarget).checked){                               
                                    document.getElementById(child).disabled=false;
                                }
                                else{
                                    document.getElementById(child).checked=false;
                                    document.getElementById(child).disabled=true;
                                    //document.getElementById(child).title=parentName+" required";
                                    for(var j=0;j<optionRules.length;j++){
                                        var parent1=optionRules[j].ERP7__Parent_Option__c;
                                        var child1=optionRules[j].ERP7__Child_Option__c;
                                        if(child == parent1){
                                            //=========================================================
                                            When multiple rule's products are dependent on each other
                                            //===========================================================
                                            //if(document.getElementById(child1).checked){ 
                                                document.getElementById(child1).checked=false;
                                                document.getElementById(child1).disabled=true;
                                            //}
                                            //========================================
                                            for(var k=0;k<optionRules.length;k++){
                                                var parent2=optionRules[k].ERP7__Parent_Option__c;
                                                var child2=optionRules[k].ERP7__Child_Option__c;
                                                if(child1 == parent2){
                                                    document.getElementById(child2).checked=false;
                                                    document.getElementById(child2).disabled=true;
                                                    
                                                    for(var l=0;l<optionRules.length;l++){
                                                        var parent3=optionRules[l].ERP7__Parent_Option__c;
                                                        var child3=optionRules[l].ERP7__Child_Option__c;
                                                        if(child2 == parent3){
                                                            document.getElementById(child3).checked=false;
                                                            document.getElementById(child3).disabled=true;
                                                        }
                                                    }
                                                }
                                            }
                                            //==============================================
                                        }
                                    }
                                }
                            }    
                        }    
                        else if(optionRules[i].ERP7__Type__c == "Exclusion"){
                            var parent=optionRules[i].ERP7__Parent_Option__c;
                            var child=optionRules[i].ERP7__Child_Option__c;
                            if(document.getElementById(currentTarget).checked){
                                if(currentTarget == parent){
                                    document.getElementById(child).checked=false;
                                    document.getElementById(child).disabled=true;
                                }else if(currentTarget == child){
                                    document.getElementById(parent).checked=false;
                                    document.getElementById(parent).disabled=true;
                                }
                            }else{
                                if(currentTarget == parent){
                                    //document.getElementById(child).checked=false;
                                    document.getElementById(child).disabled=false;
                                }else if(currentTarget == child){
                                    //document.getElementById(parent).checked=false;
                                    document.getElementById(parent).disabled=false;
                                }
                            }                          
                        }
                    }
                }            
            }
        });
        $A.enqueueAction(action);
    },*/
    
    /*VarianceSelection : function(cmp, event, helper) {
        var count = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        var recId = event.getSource().get("v.text");
        var BOMWrapperList = cmp.get("v.BOMWrapperList");
        if(value == true){
            for(var y in BOMWrapperList){
                var BOMWrapper = BOMWrapperList[y];
                if(y == count){
                    if(BOMWrapper.BOM.Id == recId){
                        for(var x in BOMWrapper.Variances){
                            BOMWrapper.Variances[x].ERP7__Active__c = false;
                        }
                    } else{
                        BOMWrapper.BOM.ERP7__Active__c = false;
                        for(var x in BOMWrapper.Variances){
                            if(BOMWrapper.Variances[x].Id != recId) BOMWrapper.Variances[x].ERP7__Active__c = false;
                        }
                    }
                }
            }
        }
        cmp.set("v.BOMWrapperList",BOMWrapperList);
    },*/    
    
    /*ConfirmConfiguration : function(cmp, event, helper) {
        var BOMWrapperList = cmp.get("v.BOMWrapperList");
        var NewRouting = cmp.get("v.NewRouting");
        var NewVersion = cmp.get("v.NewVersion");
        cmp.set("v.errorMsg","");
        if(NewRouting.Name == undefined || NewRouting.Name == "" || NewVersion.Name == undefined || NewVersion.Name == "")
            cmp.set("v.errorMsg","Required fields are missing");
        else {
            var error = false;
            for(var y in BOMWrapperList){
                var BOMWrapper = BOMWrapperList[y];
                var exist = false;
                if(BOMWrapper.BOM.ERP7__Active__c == true){
                    exist = true;
                } else{
                    for(var x in BOMWrapper.Variances){
                        if(BOMWrapper.Variances[x].ERP7__Active__c == true) {
                            exist = true;
                            break;
                        }
                    }
                }
                if(!exist) {
                    cmp.set("v.errorMsg","Sorry cannot confirm, configuration is incomplete");
                    error = true;
                    break;
                }
            } 
            if(!error){
                
                NewRouting.Name="Customer Portal Routing";
                NewVersion.Name="Customer Portal Version";
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            	var action = cmp.get("c.SaveConfiguration");
                action.setParams({"BOMWrapperList":JSON.stringify(BOMWrapperList), "RoutingId":cmp.get("v.SelectedRouting").Id, "NewRouting":JSON.stringify(NewRouting), "NewVersion":JSON.stringify(NewVersion)});
                action.setCallback(this, function(response) {
                    var state = response.getState(); 
                    
                    if (state === "SUCCESS") {
                        cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },*/
    
})