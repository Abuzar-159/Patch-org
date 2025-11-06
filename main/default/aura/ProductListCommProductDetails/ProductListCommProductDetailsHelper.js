({
    ConfigurePro1 : function(cmp, event){
        var proforConfig=cmp.get("v.ProductId");
        //cmp.set("v.proforConfig",proforConfig)
        var action = cmp.get("c.getOptionProd");
        action.setParams({proforConfig : proforConfig});
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state==="SUCCESS"){
                cmp.set("v.proOptions",response.getReturnValue().featrWrapper);
                //this.checkedFirstOpt(cmp,event);
                this.optionRules(cmp,event,proforConfig);
            }
        });
        $A.enqueueAction(action);
    },
    
    /*checkedFirstOpt : function(cmp, event){
        var proOptions = cmp.get("v.proOptions");
        for(var i=0;i<proOptions.length;i++){
            for(var j=0;j<proOptions[i].featOpt.length;j++){
                var currentId=proOptions[i].featOpt[j].Id;
                //var isDisabled=document.getElementById(proOptions[i].featOpt[j].Id).disabled;                
            }
            //document.getElementById(proOptions[i].featOpt[0].Id)
        }
    },*/
    
    optionRules : function(cmp,event,proforConfig) {
        var action=cmp.get("c.getAllOptionRules");
        action.setParams({proId : proforConfig});
        action.setCallback(this, function(response){
            var state=response.getState();		
            if(state ==="SUCCESS"){                
                var optionRules=response.getReturnValue().optionRules;
                this.selectFirstOption(cmp,event);
                cmp.set("v.optionRules",optionRules);
                if(optionRules.length > 0){
                    for(var i=0;i<optionRules.length;i++){
                        if(optionRules[i].ERP7__Type__c == "Dependency"){
                            var parent=optionRules[i].ERP7__Parent_Option__c;
                            var child=optionRules[i].ERP7__Child_Option__c;                            
                            var isParentChecked=document.getElementById(parent).checked;
                            var isParentDisabled=document.getElementById(parent).disabled;
                            
                            if(isParentDisabled == false){
                                if(isParentChecked == true){
                                    document.getElementById(child).disabled=false;
                                    document.getElementById(child).checked=true;
                                }
                            }
                            if(isParentChecked == false){
                                document.getElementById(child).checked=false;
                                document.getElementById(child).disabled=true;
                            }                            
                        }
                        else if(optionRules[i].ERP7__Type__c == "Exclusion"){
                            var parent=optionRules[i].ERP7__Parent_Option__c;
                            var child=optionRules[i].ERP7__Child_Option__c;                            
                            var isParentChecked=document.getElementById(parent).checked;
                            //var isParentDisabled=document.getElementById(parent).disabled;
                            if(isParentChecked == true){
                                document.getElementById(child).checked=false;
                                document.getElementById(child).disabled=true;
                            }
                        }
                    }                    
                }
                this.selectFirstOption1(cmp,event);
            }
        });
        $A.enqueueAction(action);
    },
    
    //=========Select first option from all feature==========
    selectFirstOption : function(cmp,event){
        var proOptions = cmp.get("v.proOptions");
        for(var i=0;i<proOptions.length;i++){
            for(var j=0;j<proOptions[i].featOpt.length;j++){
                var currentId=proOptions[i].featOpt[j].Id;
                if(!document.getElementById(currentId).disabled){
                    document.getElementById(currentId).checked=true;
                    break;
                }
            }
        }
    },
    
    //===============Select second option if first option is disabled======
    selectFirstOption1: function(cmp,event){
        var proOptions = cmp.get("v.proOptions");
        for(var i=0; i<proOptions.length;i++){
            for(var j=0;j<proOptions[i].featOpt.length;j++){
                var currentId=proOptions[i].featOpt[j].Id;
                if(document.getElementById(currentId).checked){
                    break;
                }else if(!document.getElementById(currentId).disabled){
                    document.getElementById(currentId).checked=true;
                    break;
                }
            }
        }
    },
    
    disableOthers : function(cmp,event,currentTarget){
        var feature=document.getElementById(currentTarget).text;
        var proOption=cmp.get("v.proOptions");
        for(var i=0; i<proOption.length; i++){
            if(proOption[i].feature.Id == feature){
                for(var j=0;j<proOption[i].featOpt.length;j++){
                    var foId=proOption[i].featOpt[j].Id;
                    if(proOption[i].featOpt[j].Id != currentTarget){
                        if(!document.getElementById(foId).disabled){
                            document.getElementById(foId).checked=false;
                        }                    		
                    }else{
                        document.getElementById(foId).checked=true;
                    }                       
                }
                break;                
            }            
        }
        this.setOptionRulesAfterChange(cmp,event,currentTarget);
    },
    
    setOptionRulesAfterChange : function(cmp,event,currentTarget){
        var optionRules=cmp.get("v.optionRules");
        if(optionRules.length > 0){
            for(var i=0;i<optionRules.length;i++){
                if(optionRules[i].ERP7__Type__c == "Dependency"){
                    var parent=optionRules[i].ERP7__Parent_Option__c;
                    var child=optionRules[i].ERP7__Child_Option__c;
                    //var parentName=optionRules[i].ERP7__Parent_Option__r.ERP7__Optional_SKU__r.Name;
                    
                    if(! document.getElementById(parent).checked){
                        document.getElementById(child).checked=false;
                        document.getElementById(child).disabled=true;
                    }
                    
                    if(currentTarget == parent){
                        if(document.getElementById(parent).checked){
                            if(document.getElementById(child).disabled){
                                document.getElementById(child).checked=false;
                            	document.getElementById(child).disabled=false;
                            }                            
                        }
                        else{
                            document.getElementById(child).checked=false;
                            document.getElementById(child).disabled=true;
                            
                            for(var j=0;j<optionRules.length;j++){
                                var parent1=optionRules[j].ERP7__Parent_Option__c;
                                var child1=optionRules[j].ERP7__Child_Option__c;
                                if(child == parent1){
                                    //=========================================================//
                                    //When multiple rule's products are dependent on each other//
                                    //=========================================================//
                                    //if(document.getElementById(child1).checked){ 
                                    document.getElementById(child1).checked=false;
                                    document.getElementById(child1).disabled=true;
                                    //}
                                    //==================optional======================
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
                                    //===================/optional===========================
                                }
                            }
                        }                        
                    }    
                }    
                else if(optionRules[i].ERP7__Type__c == "Exclusion"){
                    var parent=optionRules[i].ERP7__Parent_Option__c;
                    var child=optionRules[i].ERP7__Child_Option__c;                    
                    
                    if(document.getElementById(parent).checked){	// for current selected checkbox
                        document.getElementById(child).disabled=true;
                    }else if(! document.getElementById(parent).checked){	// for previous selected checkbox
                        document.getElementById(child).disabled=false;
                    }
                    
                    if(document.getElementById(child).checked){
                        document.getElementById(parent).disabled=true;
                    }else if(! document.getElementById(child).checked){
                        document.getElementById(parent).disabled=false
                    }
                                        
                    //for current selected checkbox
                    /*if(document.getElementById(currentTarget).checked){
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
                    } */                       
                }
            }
            
        }
    },
    
    ConfirmConfiguration1 : function(cmp,event){
        var selectedProds=[];
        var proOptions=cmp.get("v.proOptions");
        for(var i=0; i<proOptions.length;i++){
            var feature=proOptions[i].feature.Name;
            var count=0;
            for(j=0;j<proOptions[i].featOpt.length;j++){
                var opt=proOptions[i].featOpt[j].Id;
                if(document.getElementById(opt).checked){
                    var opt1=proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id;
                    selectedProds.push(opt1);
                    count=1;
                    break;
                }
            }            
            if(count == 0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'mode': 'dismissable',
                    'message': 'Please select '+feature
                });
                toastEvent.fire();
                return;
            }
        }   
        var action=cmp.get("c.createVersion");
        action.setParams({
            selectedProds : selectedProds,
            //proOptions : JSON.stringify(proOptions),
            prodId : cmp.get("v.ProductId")
        });
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state === "SUCCESS"){
                cmp.set("v.newVId",response.getReturnValue());
                this.addCartAfterConfig(cmp,event);
            }
        });
        $A.enqueueAction(action);      
    },
    
    /*ConfigurePro : function(cmp, event){
        var RId = cmp.get("v.RId");
        var action = cmp.get("c.ConfigureMO");
        action.setParams({"RId":RId});
        action.setCallback(this, function(response) {
            var state = response.getState();	
            if (state === "SUCCESS") {
                cmp.set("v.NewVersion", response.getReturnValue().SelectedVersion);
                cmp.set("v.NewRouting", response.getReturnValue().SelectedRouting);
                if(response.getReturnValue().SelectedRouting.Name == undefined) cmp.set("v.RoutingConfigure", false);
                else cmp.set("v.RoutingConfigure", true);
                cmp.set("v.SelectedRouting", response.getReturnValue().Routing);
                cmp.set("v.SelectedVersion", response.getReturnValue().Version);
                cmp.set("v.BOMS", response.getReturnValue().BOMS);
                cmp.set("v.BOMWrapperList", response.getReturnValue().BOMWrapperList);
                cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
            }
        });
        $A.enqueueAction(action);
    },*/
    
    
    
    /*ConfirmConfiguration : function(cmp, event) {
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
            	var action = cmp.get("c.SaveConfiguration");
                action.setParams({"BOMWrapperList":JSON.stringify(BOMWrapperList), "RoutingId":cmp.get("v.SelectedRouting").Id, "NewRouting":JSON.stringify(NewRouting), "NewVersion":JSON.stringify(NewVersion)});
                action.setCallback(this, function(response) {
                    var state = response.getState(); 
                    if (state === "SUCCESS") {
                        cmp.set("v.newVId",response.getReturnValue().SelectedVersion.Id);                        
                        cmp.set("v.errorMsg", response.getReturnValue().errorMsg);
                        this.addCartAfterConfig(cmp,event);
                    }
                });
               $A.enqueueAction(action);
            }
        }
    },*/
    
    addCartAfterConfig :function(cmp, event){
        var quantity = cmp.find("quant").get("v.value");	
       
        var action = cmp.get('c.addTocartForConf');
        action.setParams({
            accId : cmp.get("v.AccId"),
            prodId :cmp.get("v.ProductId"),
            quant : quantity,
            newVId : cmp.get("v.newVId")
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
    
    subtotal : function(cmp, event) {
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
            //cmp.set("v.SubTotal",subTotal);  
            var evt= $A.get("e.c:ProductListComm_BodyToHeader");
            evt.setParams({isSubtotal:true,Subtotal:subTotal});
            evt.fire();
            
        });
        $A.enqueueAction(action);
    },
    
    cookieImplement : function(cmp,event,cartItem){
        /*var expDate = new Date();
    		expDate.setTime(expDate.getTime() + (10 * 24 * 60 * 60 * 1000));
    		var expires = "expires="+expDate.toUTCString();*/
        var expires = new Date(Date.now()+60*60*1000).toString();
        var qunt = 1;
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
        if(isFindCookies)
            var CookiesData = cartItem+"="+(qunt+parseInt(valueOfCookies))+"; "+expires+";";
        else
            var CookiesData = cartItem+"="+qunt+"; "+expires+";";
        document.cookie = CookiesData;        
    },
    
})