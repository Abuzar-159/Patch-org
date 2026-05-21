({
    showSpinner: function(cmp, event, helper) {
        cmp.set("v.Spinner", true); 
    },    
    hideSpinner : function(cmp,event,helper){
        cmp.set("v.Spinner", false);
    },
    showToolTip : function(cmp, event) {
        cmp.set("v.tooltip" ,true);        
    },
    HideToolTip : function(cmp,event){
        cmp.set("v.tooltip" , false);
    },
    initial : function(cmp, event, helper) {
        
        //var isSelectFirst=$A.get("$Label.c.isSelectFirst");
        
        cmp.set('v.isSelectFirst',$A.get("$Label.c.isSelectFirst"));
        cmp.set('v.isAllFeatCom',$A.get("$Label.c.isAllFeatCom"));
        var initialQunatity=1;
        var action=cmp.get("c.fetchOrder");
        action.setParams({OrderId : cmp.get("v.OrderId")});
        action.setCallback(this,function(response){
            var state=response.getState();	
            if(state=="SUCCESS"){
                var res=response.getReturnValue();
                
                cmp.set("v.errorMsg",res.errorMsg);
                if(res.errorMsg != '') return;
                if(res.isPBAssign == false){
                    cmp.set("v.islistOfProduct",false);
                    //cmp.find("allpricebook").set("v.options", res.allpriBook);
                    cmp.set("v.allpricebookOptions",res.allpriBook);
                    cmp.set("v.allpribook",res.allpriBook[0].value);
                    var modal = cmp.find("PBModal");
                    var modalBackdrop = cmp.find("PBModalBackdrop");
                    $A.util.addClass(modal,"slds-fade-in-open");
                    $A.util.addClass(modalBackdrop,"slds-backdrop_open");
                    cmp.set("v.Spinner", false);
                }else{
                    cmp.set("v.orderName",'Order : '+res.ord.OrderNumber);
                    //cmp.find("profamily_List").set("v.options", response.getReturnValue().prodFam);
                    cmp.set("v.prodFamilyList",response.getReturnValue().prodFam);
                    //cmp.find("proCat_List").set("v.options", response.getReturnValue().prodCat);
                    cmp.set("v.prodCategoryList",response.getReturnValue().prodCat);
                    helper.getInitialPro(cmp,event,res.ord.Id,initialQunatity);
                }                              
            }else{
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+' '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
    },
    closeError : function(cmp,event){
        cmp.set("v.errorMsg",'');
    },
    savePricebook :function(component, event, helper) {
        var pricebook=component.get("v.allpribook");
        
        var action = component.get("c.savePriBook");
        action.setParams({
            selRecord : component.get("v.OrderId"),
            pricebook : pricebook
        });
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state =="SUCCESS"){
                var a = component.get("c.initial");
                $A.enqueueAction(a);
                sforce.one.showToast({
                    "title": $A.get('$Label.c.Success'),
                    "message": $A.get('$Label.c.PH_OrderProd_Pricebook_added_to_Order'),
                    "type": "success"
                });
                /*
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Success',
                    'type': 'success',
                    'mode': 'dismissable',
                    'message': 'Pricebook added to Opportunity'
                });
                toastEvent.fire();*/
                component.set("v.Spinner", false);
                var modal = component.find("PBModal");
                var modalBackdrop = component.find("PBModalBackdrop");
                $A.util.removeClass(modal,"slds-fade-in-open");
                $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
            }else{
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+' '+error[0].stackTrace);
            }            
        });
        $A.enqueueAction(action);
    },
    PBcloseModal: function(component, event, helper) {
        var modal = component.find("PBModal");
        var modalBackdrop = component.find("PBModalBackdrop");
        $A.util.removeClass(modal,"slds-fade-in-open");
        $A.util.removeClass(modalBackdrop,"slds-backdrop_open");
    },
    
    getProduct : function(cmp,event,helper){
        
        cmp.set("v.resVersion","");
        cmp.set("v.selConfiguration",[]);
        var name=cmp.get("v.name");
        var proCode=cmp.get("v.proCode");
        var proFamily=cmp.get("v.prodFam");
        var proCat=cmp.get("v.prodCat");
        
        if(proFamily == 'None') proFamily='';
        if(proCat == 'None') proCat='';
        var action=cmp.get("c.fetchProducts");
        action.setParams({
            OrderId : cmp.get("v.OrderId"),
            name:name,
            proCode : proCode,
            proFamily : proFamily,
            proCat :proCat
        });
        action.setCallback(this, function(response){
            var state=response.getState(); 
            if(state=="SUCCESS"){
                
                var res=response.getReturnValue();
                cmp.set("v.listOfProduct",res);
                cmp.set("v.islistOfProduct",true);
                cmp.set("v.Spinner", false);
            }else{
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+' '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    checkboxSelect : function(cmp,event,helper){
        
        if(event.getSource().get("v.checked")){
            var proId=event.getSource().get("v.name");
            
            var listOfProduct = cmp.get("v.listOfProduct");
            
            for(var i=0;i<listOfProduct.length;i++){
                if(listOfProduct[i].pbe.Product2.Id == proId){
                    if(listOfProduct[i].pbe.Product2.ERP7__Configure__c){
                        helper.Configure(cmp,event,proId);
                        cmp.set("v.Spinner", false); 
                    }
                }
            }
        }        
    },
    
    handleQuantity : function(cmp,event,helper){
        
        var index=event.getSource().get("v.title");
        var quantity=event.getSource().get("v.value");
        var listOfProduct=cmp.get("v.listOfProduct");
        var crtlistOfProduct=listOfProduct[index];
        
        /*if(crtlistOfProduct.pbe.Product2.ERP7__Serialise__c && quantity > 1){
            sforce.one.showToast({
                "title": "Warning!",
                "message": "Can not add more than one quantity for Serialize Product.",
                "type": "warning"
            });
            crtlistOfProduct.quantity=1;
            listOfProduct[index]=crtlistOfProduct;
            cmp.set('v.listOfProduct',listOfProduct);
            return;
        }*/
        if(quantity != 0 && quantity != ''){
            var action=cmp.get("c.getDiscountPlan");
            action.setParams({
                OrderId : cmp.get("v.OrderId"),
                prodId : crtlistOfProduct.pbe.Product2Id,
                quantity : quantity
            });
            action.setCallback(this,function(response){
                var state=response.getState();	
                if(state == "SUCCESS"){
                    var res=response.getReturnValue();
                    
                    crtlistOfProduct.CurrentDiscounts=res[0].CurrentDiscounts;
                    crtlistOfProduct.disPlans=res[0].disPlans;
                    crtlistOfProduct.discountPercent=res[0].discountPercent;
                    crtlistOfProduct.maxDiscount=res[0].maxDiscount;
                    crtlistOfProduct.minDiscount=res[0].minDiscount;
                    crtlistOfProduct.tiesDists=res[0].tiesDists;
                    for(var i=0;i<listOfProduct.length;i++){
                        if(i==index)
                            listOfProduct[i]=crtlistOfProduct;
                    }
                    cmp.set("v.listOfProduct",listOfProduct);
                    return;
                }
            });
            $A.enqueueAction(action);
        }        
    },
    
    handleDiscPlan : function(cmp,event,helper){
        
        var currentProd=event.getSource().get("v.title");
        var discountPlan=event.getSource().get("v.value");
        
        var listOfProduct=cmp.get("v.listOfProduct");
        
        if(discountPlan != ''){
            for(var i=0;i<listOfProduct.length;i++){
                if(currentProd == listOfProduct[i].pbe.Product2Id){
                    listOfProduct[i].discountPlan=discountPlan;
                    for(var j=0;j<listOfProduct[i].disPlans.length;j++){
                        if(discountPlan == listOfProduct[i].disPlans[j].Id){
                            if(listOfProduct[i].disPlans[j].ERP7__Default_Discount_Percentage__c != undefined){
                                listOfProduct[i].isPercent=true;
                                if(listOfProduct[i].disPlans[j].ERP7__Default_Discount_Percentage__c != undefined)
                                    listOfProduct[i].discountPercent=listOfProduct[i].disPlans[j].ERP7__Default_Discount_Percentage__c;
                                else
                                    listOfProduct[i].discountPercent=0;
                                if(listOfProduct[i].disPlans[j].ERP7__Floor_Discount_Percentage__c != undefined)
                                    listOfProduct[i].minDiscount=listOfProduct[i].disPlans[j].ERP7__Floor_Discount_Percentage__c;
                                else
                                    listOfProduct[i].minDiscount=0;
                                if(listOfProduct[i].disPlans[j].ERP7__Ceiling_Discount_Percentage__c != undefined)
                                    listOfProduct[i].maxDiscount=listOfProduct[i].disPlans[j].ERP7__Ceiling_Discount_Percentage__c;
                                else
                                    listOfProduct[i].maxDiscount=0;
                            }else{
                                listOfProduct[i].isPercent=false;
                                if(listOfProduct[i].disPlans[j].ERP7__Default_Discount_Value__c != undefined)
                                    listOfProduct[i].discountPercent=listOfProduct[i].disPlans[j].ERP7__Default_Discount_Value__c;
                                else
                                    listOfProduct[i].discountPercent=0;
                                if(listOfProduct[i].disPlans[j].ERP7__Floor_Discount_Value__c != undefined)
                                    listOfProduct[i].minDiscount=listOfProduct[i].disPlans[j].ERP7__Floor_Discount_Value__c;
                                else
                                    listOfProduct[i].minDiscount=0;
                                if(listOfProduct[i].disPlans[j].ERP7__Ceiling_Discount_Value__c != undefined)
                                    listOfProduct[i].maxDiscount=listOfProduct[i].disPlans[j].ERP7__Ceiling_Discount_Value__c;
                                else
                                    listOfProduct[i].maxDiscount=0;
                            }                                
                            cmp.set("v.listOfProduct",listOfProduct);
                            return;
                        }
                    }                
                }            
            }
        }else{
            for(var i=0;i<listOfProduct.length;i++){
                if(currentProd == listOfProduct[i].pbe.Product2Id){
                    listOfProduct[i].discountPlan=discountPlan;
                    listOfProduct[i].isPercent=true;
                    listOfProduct[i].discountPercent=0;
                    listOfProduct[i].minDiscount=0;
                    listOfProduct[i].maxDiscount=0;
                    cmp.set("v.listOfProduct",listOfProduct);
                    return;
                }
            }
        }
    },
    
    handleDiscount : function(cmp,event,helper){
        
        var currentIndex=event.getSource().get("v.title");
        var discount=event.getSource().get("v.value");
        var listOfProduct=cmp.get("v.listOfProduct");
        var crtlistOfProduct=listOfProduct[currentIndex];
        if(discount != ''){
            if(crtlistOfProduct.maxDiscount != 0){
                if(discount > crtlistOfProduct.maxDiscount){
                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Discount_was_larger_than_Max_discount'));
                    //crtlistOfProduct.discountPercent=0;
                    for(var i=0;i<listOfProduct.length;i++){
                        if(i==currentIndex){
                            for(var j=0;j<listOfProduct[i].disPlans.length;j++){
                                if(crtlistOfProduct.isPercent){
                                    crtlistOfProduct.discountPercent=listOfProduct[i].disPlans[j].ERP7__Default_Discount_Percentage__c;
                                    break;
                                }
                                
                                else
                                    crtlistOfProduct.discountPercent=listOfProduct[i].disPlans[j].ERP7__Default_Discount_Value__c;
                            }                            	
                            listOfProduct[i]=crtlistOfProduct;
                        }   
                    }
                    cmp.set("v.listOfProduct",listOfProduct);
                    return;
                }
            }            
        }
    },
    
    addProducts : function(cmp,event,helper){
        //cmp.set("v.Spinner", true); 
        var flag=helper.validatelistOfProduct(cmp,event);
        
        if(flag){
            var selectedProducts=cmp.get("v.selectedProducts");
            var productMatchedIndx=[];
            var listOfProduct = cmp.get("v.listOfProduct");
            
            //****For Serialize product********            
            for(var i=0;i<listOfProduct.length;i++){
                if(listOfProduct[i].checkSelected && listOfProduct[i].pbe.Product2.ERP7__Serialise__c){
                    if(listOfProduct[i].stock > 0){
                        if(listOfProduct[i].quantity > 0){
                            selectedProducts.push(listOfProduct[i]);
                            sforce.one.showToast({
                                "title": $A.get('$Label.c.Success'),
                                "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                "type": "success"
                            });
                        }
                        else
                            cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                    }
                    else if(listOfProduct[i].pbe.Product2.ERP7__Allow_Back_Orders__c){	//listOfProduct[i].stock == 0 && 
                        if(listOfProduct[i].quantity > 0){
                            selectedProducts.push(listOfProduct[i]);
                            sforce.one.showToast({
                                "title": $A.get('$Label.c.Success'),
                                "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                "type": "success"
                            });
                        }
                        else
                            cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                    }
                    
                        else  cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Products_having_stock_zero_are_not_allowed_to_add'));
                }
            }
            
            //****For Serialize product ends****
            
            
            if(selectedProducts.length > 0){
                for(var i=0;i<listOfProduct.length;i++){
                    if(listOfProduct[i].checkSelected && listOfProduct[i].pbe.Product2.ERP7__Serialise__c == false){
                        if(listOfProduct[i].stock > 0 || listOfProduct[i].pbe.Product2.ERP7__Allow_Back_Orders__c || listOfProduct[i].pbe.Product2.ERP7__Is_Kit__c)
                        {
                            if(listOfProduct[i].quantity > 0){
                                for(var j=0;j<selectedProducts.length;j++){
                                    if(listOfProduct[i].pbe.Product2.Id == selectedProducts[j].pbe.Product2.Id)
                                    {
                                        productMatchedIndx.push(i);
                                        selectedProducts[j].CurrentDiscounts=listOfProduct[i].CurrentDiscounts;
                                        selectedProducts[j].disPlans=listOfProduct[i].disPlans;
                                        selectedProducts[j].discountPercent=listOfProduct[i].discountPercent;
                                        selectedProducts[j].discountPlan=listOfProduct[i].discountPlan;
                                        selectedProducts[j].isPercent=listOfProduct[i].isPercent;
                                        selectedProducts[j].maxDiscount=listOfProduct[i].maxDiscount;
                                        selectedProducts[j].minDiscount=listOfProduct[i].minDiscount;
                                        selectedProducts[j].version=listOfProduct[i].version;                                    
                                        selectedProducts[j].pbe.UnitPrice=listOfProduct[i].pbe.UnitPrice;
                                        selectedProducts[j].quantity =parseInt(selectedProducts[j].quantity) + parseInt(listOfProduct[i].quantity);
                                        selectedProducts[j].otherTax=parseInt(listOfProduct[i].otherTax);
                                        selectedProducts[j].tax=listOfProduct[i].tax;
                                        selectedProducts[j].taxId=listOfProduct[i].taxId;
                                        selectedProducts[j].vatAmount=listOfProduct[i].vatAmount;
                                        sforce.one.showToast({
                                            "title": $A.get('$Label.c.Success'),
                                            "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                            "type": "success"
                                        });
                                        /*var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            'title': 'Success',
                                            'type': 'success',
                                            'mode': 'dismissable',
                                            'message': 'Added Successfully'
                                        });
                                        toastEvent.fire();*/
                                    }
                                }                                              
                            }                		
                            else
                                cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                        }
                        else  cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Products_having_stock_zero_are_not_allowed_to_add'));
                    }
                }
                
                productMatchedIndx.sort(function(a, b){return b - a});
                if(productMatchedIndx.length > 0){
                    for(var k=0;k<productMatchedIndx.length;k++){
                        listOfProduct.splice(productMatchedIndx[k], 1);
                    }
                    for(var i=0;i<listOfProduct.length;i++){
                        if(listOfProduct[i].checkSelected && listOfProduct[i].pbe.Product2.ERP7__Serialise__c == false){
                            if(listOfProduct[i].stock > 0){
                                if(listOfProduct[i].quantity > 0){
                                    selectedProducts.push(listOfProduct[i]);
                                    sforce.one.showToast({
                                        "title": $A.get('$Label.c.Success'),
                                        "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                        "type": "success"
                                    });
                                }
                                else
                                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                            }
                            else if(listOfProduct[i].pbe.Product2.ERP7__Allow_Back_Orders__c){	//listOfProduct[i].stock == 0 && 
                                if(listOfProduct[i].quantity > 0){
                                    selectedProducts.push(listOfProduct[i]);
                                    sforce.one.showToast({
                                        "title": $A.get('$Label.c.Success'),
                                        "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                        "type": "success"
                                    });
                                }
                                else
                                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                            }
                                else if(listOfProduct[i].pbe.Product2.ERP7__Is_Kit__c){	//listOfProduct[i].stock == 0 && 
                                    if(listOfProduct[i].quantity > 0){
                                        selectedProducts.push(listOfProduct[i]);
                                        sforce.one.showToast({
                                            "title": $A.get('$Label.c.Success'),
                                            "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                            "type": "success"
                                        });
                                    }
                                    else
                                        cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                                }
                            
                                    else  cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Products_having_stock_zero_are_not_allowed_to_add'));
                        }
                    }
                }
                else{
                    for(var i=0;i<listOfProduct.length;i++){
                        if(listOfProduct[i].checkSelected && listOfProduct[i].pbe.Product2.ERP7__Serialise__c==false){
                            if(listOfProduct[i].stock > 0){
                                if(listOfProduct[i].quantity > 0){
                                    selectedProducts.push(listOfProduct[i]);
                                    sforce.one.showToast({
                                        "title": $A.get('$Label.c.Success'),
                                        "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                        "type": "success"
                                    });
                                }
                                else
                                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                            }
                            else if(listOfProduct[i].pbe.Product2.ERP7__Allow_Back_Orders__c){	//listOfProduct[i].stock == 0 && 
                                if(listOfProduct[i].quantity > 0){
                                    selectedProducts.push(listOfProduct[i]);
                                    sforce.one.showToast({
                                        "title": $A.get('$Label.c.Success'),
                                        "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                        "type": "success"
                                    });
                                }
                                else
                                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                            }
                                else if(listOfProduct[i].pbe.Product2.ERP7__Is_Kit__c){	//listOfProduct[i].stock == 0 && 
                                    if(listOfProduct[i].quantity > 0){
                                        selectedProducts.push(listOfProduct[i]);
                                        sforce.one.showToast({
                                            "title": $A.get('$Label.c.Success'),
                                            "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                            "type": "success"
                                        });
                                    }
                                    else
                                        cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                                }
                                    else  cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Products_having_stock_zero_are_not_allowed_to_add'));
                        }
                    }
                }
            }else{
                for(var i=0;i<listOfProduct.length;i++){
                    if(listOfProduct[i].checkSelected && listOfProduct[i].pbe.Product2.ERP7__Serialise__c == false){
                        if(listOfProduct[i].stock > 0){
                            if(listOfProduct[i].quantity > 0){
                                selectedProducts.push(listOfProduct[i]);
                                sforce.one.showToast({
                                    "title": $A.get('$Label.c.Success'),
                                    "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                    "type": "success"
                                });
                            }
                            else
                                cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                        }
                        else if(listOfProduct[i].pbe.Product2.ERP7__Allow_Back_Orders__c){	//listOfProduct[i].stock == 0 && 
                            if(listOfProduct[i].quantity > 0){
                                selectedProducts.push(listOfProduct[i]);
                                sforce.one.showToast({
                                    "title": $A.get('$Label.c.Success'),
                                    "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                    "type": "success"
                                });
                            }
                            else
                                cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                        }
                            else if(listOfProduct[i].pbe.Product2.ERP7__Is_Kit__c){	//listOfProduct[i].stock == 0 && 
                                if(listOfProduct[i].quantity > 0){
                                    selectedProducts.push(listOfProduct[i]);
                                    sforce.one.showToast({
                                        "title": $A.get('$Label.c.Success'),
                                        "message": $A.get('$Label.c.PH_OrderProd_Added_Successfully'),
                                        "type": "success"
                                    });
                                }
                                else
                                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Items_having_quantity_zero_are_not_allowed_to_add'));
                            }
                                else  cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Products_having_stock_zero_are_not_allowed_to_add'));
                    }
                }
            }     
            cmp.set("v.selectedProducts",selectedProducts);
            helper.taxCalculation(cmp,event);
            var a = cmp.get("c.getProduct");
            $A.enqueueAction(a);
            cmp.set("v.Spinner", false); 
        }   
    },
    
    removeItem: function(cmp,event,helper){
        
        //var index=event.currentTarget.dataset.service; 
        var index=event.getSource().get("v.title"); 
        var itemsToDel=cmp.get("v.itemsToDel");
        
        var selectedProducts=cmp.get("v.selectedProducts");
        for(var i=0;i<selectedProducts.length;i++){
            if(index == i){
                if(selectedProducts[i].orderLineId != '') 
                    itemsToDel.push(selectedProducts[i].orderLineId);
                selectedProducts.splice(i, 1);
                // this toast used for the visualforce page
                sforce.one.showToast({
                    "title": $A.get('$Label.c.Success'),
                    "message": $A.get('$Label.c.PH_OrderPRod_Item_Removed'),
                    "type": "success"
                });
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Success',
                    'type': 'success',
                    'mode': 'dismissable',
                    'message': 'Item Removed'
                });
                toastEvent.fire();*/
            }
        }
        cmp.set("v.selectedProducts",selectedProducts);
        cmp.set("v.itemsToDel",itemsToDel);
    },
    
    handleUnitPriceSel : function(cmp,event,helper){
        
        helper.taxCalculation(cmp,event);
    },
    
    handleQuantitySel: function(cmp,event,helper){
        
        var index=event.getSource().get("v.title");
        
        var quantity=event.getSource().get("v.value");
        
        var selectedProducts=cmp.get("v.selectedProducts");
        
        var crtselectedProducts=selectedProducts[index];
        
        /*if(crtselectedProducts.pbe.Product2.ERP7__Serialise__c && quantity > 1){
            sforce.one.showToast({
                "title": "Warning!",
                "message": "Can not add more than one quantity for Serialize Product.",
                "type": "warning"
            });
            crtselectedProducts.quantity=1;
            selectedProducts[index]=crtselectedProducts;
            cmp.set('v.selectedProducts',selectedProducts);
            return;
        }*/
        if(quantity != 0 && quantity != ''){
            var action=cmp.get("c.getDiscountPlan");
            action.setParams({
                OrderId : cmp.get("v.OrderId"),
                prodId : crtselectedProducts.pbe.Product2Id,
                quantity : quantity
            });
            action.setCallback(this,function(response){
                var state=response.getState();
                if(state == "SUCCESS"){
                    var res=response.getReturnValue();
                    
                    crtselectedProducts.discountPlan=res[0].discountPlan;
                    crtselectedProducts.CurrentDiscounts=res[0].CurrentDiscounts;
                    crtselectedProducts.disPlans=res[0].disPlans;
                    crtselectedProducts.discountPercent=res[0].discountPercent;
                    crtselectedProducts.maxDiscount=res[0].maxDiscount;
                    crtselectedProducts.minDiscount=res[0].minDiscount;
                    crtselectedProducts.tierDists=res[0].tierDists;
                    for(var i=0;i<selectedProducts.length;i++){
                        if(i==index)
                            selectedProducts[i]=crtselectedProducts;
                    }
                    cmp.set("v.selectedProducts",selectedProducts);
                    helper.taxCalculation(cmp,event);
                    return;
                }
            });
            $A.enqueueAction(action);
        }   
    },
    
    handleDiscPlanSel : function(cmp,event,helper){
        
        var currentProd=event.getSource().get("v.title");
        var discountPlan=event.getSource().get("v.value");
        
        var selectedProducts=cmp.get("v.selectedProducts");
        if(discountPlan != ''){
            for(var i=0;i<selectedProducts.length;i++){
                if(currentProd == selectedProducts[i].pbe.Product2Id){
                    selectedProducts[i].discountPlan=discountPlan;
                    for(var j=0;j<selectedProducts[i].disPlans.length;j++){
                        if(discountPlan == selectedProducts[i].disPlans[j].Id){
                            if(selectedProducts[i].disPlans[j].ERP7__Default_Discount_Percentage__c != undefined){
                                selectedProducts[i].isPercent=true;
                                if(selectedProducts[i].disPlans[j].ERP7__Default_Discount_Percentage__c != undefined)
                                    selectedProducts[i].discountPercent=selectedProducts[i].disPlans[j].ERP7__Default_Discount_Percentage__c;
                                else
                                    selectedProducts[i].discountPercent=0;
                                if(selectedProducts[i].disPlans[j].ERP7__Floor_Discount_Percentage__c != undefined)
                                    selectedProducts[i].minDiscount=selectedProducts[i].disPlans[j].ERP7__Floor_Discount_Percentage__c;
                                else
                                    selectedProducts[i].minDiscount=0;
                                if(selectedProducts[i].disPlans[j].ERP7__Ceiling_Discount_Percentage__c != undefined)
                                    selectedProducts[i].maxDiscount=selectedProducts[i].disPlans[j].ERP7__Ceiling_Discount_Percentage__c;
                                else
                                    selectedProducts[i].maxDiscount=0;
                            }else{
                                selectedProducts[i].isPercent=false;
                                if(selectedProducts[i].disPlans[j].ERP7__Default_Discount_Value__c != undefined)
                                    selectedProducts[i].discountPercent=selectedProducts[i].disPlans[j].ERP7__Default_Discount_Value__c;
                                else
                                    selectedProducts[i].discountPercent=0;
                                if(selectedProducts[i].disPlans[j].ERP7__Floor_Discount_Value__c != undefined)
                                    selectedProducts[i].minDiscount=selectedProducts[i].disPlans[j].ERP7__Floor_Discount_Value__c;
                                else
                                    selectedProducts[i].minDiscount=0;
                                if(selectedProducts[i].disPlans[j].ERP7__Ceiling_Discount_Value__c != undefined)
                                    selectedProducts[i].maxDiscount=selectedProducts[i].disPlans[j].ERP7__Ceiling_Discount_Value__c;
                                else
                                    selectedProducts[i].maxDiscount=0;
                            }                                
                            cmp.set("v.selectedProducts",selectedProducts);
                            return;
                        }
                    }                
                }            
            }
        }else{
            for(var i=0;i<selectedProducts.length;i++){
                if(currentProd == selectedProducts[i].pbe.Product2Id){
                    selectedProducts[i].discountPlan=discountPlan;
                    selectedProducts[i].isPercent=true;
                    selectedProducts[i].discountPercent=0;
                    selectedProducts[i].minDiscount=0;
                    selectedProducts[i].maxDiscount=0;
                    cmp.set("v.selectedProducts",selectedProducts);
                    return;
                }
            }
        }    
    },
    
    handleDiscountSel : function(cmp,event,helper){
        
        var currentIndex=event.getSource().get("v.title");
        var discount=event.getSource().get("v.value");
        var selectedProducts=cmp.get("v.selectedProducts");
        var crtselectedProducts=selectedProducts[currentIndex];
        if(discount != ''){
            if(crtselectedProducts.maxDiscount != 0){
                if(discount > crtselectedProducts.maxDiscount){
                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Discount_was_larger_than_Max_discount'));
                    //crtselectedProducts.discountPercent=0;
                    for(var i=0;i<selectedProducts.length;i++){
                        if(i==currentIndex){
                            for(var j=0;j<selectedProducts[i].disPlans.length;j++){
                                if(crtselectedProducts.isPercent){
                                    crtselectedProducts.discountPercent=selectedProducts[i].disPlans[j].ERP7__Default_Discount_Percentage__c;
                                    break;
                                }
                                else
                                    crtselectedProducts.discountPercent=selectedProducts[i].disPlans[j].ERP7__Default_Discount_Value__c;
                            }                            	
                            selectedProducts[i]=crtselectedProducts;
                        }   
                    }
                    cmp.set("v.selectedProducts",selectedProducts);
                    helper.taxCalculation(cmp,event);
                    return;
                }else{
                    helper.taxCalculation(cmp,event);
                }
            }else{
                helper.taxCalculation(cmp,event);
            }            
        }
    },
    
    cancelOrderLine: function(cmp,event,helper){
        //var RecUrl = "/" + cmp.get("v.OrderId");
        //window.open(RecUrl,'_Self');
        var RecUrl = "/lightning/r/Order/" + cmp.get("v.OrderId") + "/view";
        window.open(RecUrl,'_parent');
    },
    
    next : function(cmp,event,helper){
        cmp.set("v.viewListOfProduct",false);
    },
    
    previous : function(cmp,event,helper){
        cmp.set("v.viewListOfProduct",true);
    },
    
    handleDrag : function(cmp, event, helper) {
        cmp.set("v.DragIndex", event.target.id);
    },
    
    allowDrop : function(cmp, event, helper) {
        event.preventDefault();
    },
    
    handleDrop : function(cmp, event, helper) {        
        var DragIndex = parseInt(cmp.get("v.DragIndex"));
        var indexVal=parseInt(event.currentTarget.getAttribute('data-index'));
        var selectedProducts = cmp.get("v.selectedProducts"); 
        var ShiftElement = selectedProducts[DragIndex];
        selectedProducts.splice(DragIndex, 1);                                          
        selectedProducts.splice(indexVal, 0 , ShiftElement);
        cmp.set("v.selectedProducts", selectedProducts);
    },
    
    saveOrderLine1 : function(cmp,event,helper){
        
        var valFields=helper.validateFields(cmp,event);
        
        if(valFields){
            var selectedProducts=cmp.get("v.selectedProducts");
            
            var action=cmp.get("c.saveOrderLine");
            action.setParams({
                OrderId : cmp.get("v.OrderId"),
                selectedProducts : JSON.stringify(selectedProducts),
                itemsToDel : cmp.get('v.itemsToDel')
            });
            action.setCallback(this, function(response){
                var state=response.getState(); 
                if(state=="SUCCESS"){
                    
                    if(response.getReturnValue() != null)
                        if(response.getReturnValue().includes('The Price Book Entry must belong to the Price Book related to the Order'))
                            cmp.set("v.errorMsg",$A.get('$Label.c.PH_Label'));
                        else
                            cmp.set("v.errorMsg",response.getReturnValue());
                    else{
                        if(selectedProducts.length > 0){
                            //var RecUrl = "/" + cmp.get("v.OrderId");
                            //window.open(RecUrl,'_Self');
                            var RecUrl = "/lightning/r/Order/" + cmp.get("v.OrderId") + "/view";
                            window.open(RecUrl,'_parent');
                        }
                    }
                }else{
                    var error=response.getError();
                    cmp.set("v.errorMsg",error[0].message+' '+error[0].stackTrace);
                }
            });
            $A.enqueueAction(action);
        }        
    },   
    
    //===============Product Configuration start===================
    /*Configure : function(cmp, event, helper) { 
      
        var quoteId=cmp.get("v.quoteId");
        var proforConfig=event.getSource().get("v.title");
      
        cmp.set("v.proforConfig",proforConfig);
        var action = cmp.get("c.getOptionProd");
        action.setParams({proforConfig : proforConfig,quoteId : quoteId});
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state==="SUCCESS"){
                
                cmp.set("v.proOptions",response.getReturnValue().featrWrapper);
                
                cmp.set("v.totalStock",response.getReturnValue().totalStock);
                
                cmp.set("v.proName",response.getReturnValue().product.Name);
                cmp.set("v.errorMsg",response.getReturnValue().errorMsg);
                helper.optionRules(cmp,event,proforConfig);
                $A.util.addClass(cmp.find("configModal1"), 'slds-fade-in-open');
                $A.util.addClass(cmp.find("configModalBackdrop"), 'slds-fade-in-open');
            }
        });
        $A.enqueueAction(action);        
    },*/
    
    closeConfigureModal : function(cmp, event){
        $A.util.removeClass(cmp.find("configModal1"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("configModalBackdrop"), 'slds-fade-in-open');
    },
    
    confirmConfiguration : function(cmp,event,helper){
        
        cmp.set("v.errorMsg",'');
        cmp.set("v.selConfiguration",[]);
        var selectedProds=[];
        var selProTotalPri=0;
        var selConfiguration=cmp.get("v.selConfiguration");
        var proFeatureMap=cmp.get("v.proFeatureMap");
        var proOptions=cmp.get("v.proOptions");
        
        for(var i=0; i<proOptions.length;i++){
            var feature=proOptions[i].feature.Name;
            var count=0;
            for(var j=0;j<proOptions[i].featOpt.length;j++){
                var opt=proOptions[i].featOpt[j].Id;
                if(document.getElementById(opt).checked){
                    
                    var totalStock=cmp.get('v.totalStock');
                    for(var l=0;l<totalStock.length;l++){
                        if(totalStock[l].ProId == proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id){
                            
                            if(totalStock[l].stockAvlb > 0 || proOptions[i].featOpt[j].ERP7__Optional_SKU__r.ERP7__Allow_Back_Orders__c){
                                
                                var opt1=proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id;
                                selConfiguration.push(proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Name);
                                selectedProds.push(opt1);
                                proFeatureMap[opt1]=proOptions[i].feature.Id;
                                for(var k=0;k<proOptions[i].pbe.length;k++){
                                    if(proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Id==proOptions[i].pbe[k].Product2Id){
                                        var quantity1=document.getElementById(proOptions[i].pbe[k].Product2Id).value;
                                        selProTotalPri+=proOptions[i].pbe[k].UnitPrice*quantity1;
                                    }
                                }
                                count=1;
                                break;
                            }
                            else{
                                cmp.set("v.errorMsg",proOptions[i].featOpt[j].ERP7__Optional_SKU__r.Name+' was stock zero');
                                return;
                            }
                        }
                    }                    
                }
            }  
            
            if(count == 0 && cmp.get("v.isAllFeatCom") === 'true'){
                //alert('Please select '+feature);
                cmp.set("v.errorMsg",'Please select '+feature);
                
                return;
            }
        }   
        var prodId=cmp.get("v.proforConfig");
        var theMap = cmp.get("v.proMap");
        for(var i=0;i<selectedProds.length;i++){
            var qunaity=document.getElementById(selectedProds[i]).value;
            theMap[selectedProds[i]]=qunaity;
        }
        cmp.set("v.proMap",theMap);
        
        var action=cmp.get("c.createVersion");
        action.setParams({
            "selectedProds" : JSON.stringify(cmp.get("v.proMap")),
            //proOptions : JSON.stringify(proOptions),
            proFeatureMap : JSON.stringify(cmp.get("v.proFeatureMap")),
            prodId : prodId
        });
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state === "SUCCESS"){
                
                cmp.set("v.proMap",{});
                var search=response.getReturnValue().search("Line Number @");
                
                if(search != -1)
                    cmp.set("v.errorMsg",response.getReturnValue());
                else{
                    cmp.set("v.resVersion",response.getReturnValue());
                    cmp.set("v.selConfiguration",selConfiguration);
                    var obj=cmp.get("v.listOfProduct");
                    
                    for(var i=0;i<obj.length;i++){                    
                        if(prodId == obj[i].pbe.Product2.Id){
                            obj[i].version=response.getReturnValue();  
                            obj[i].pbe.UnitPrice+=selProTotalPri;
                            break;
                        }
                    }
                    cmp.set("v.listOfProduct",obj);
                    
                }
                
                /*var obj=cmp.get("v.ProductsAndDiscountsWrapperListt");
                var objForConfigure=[];
                for(var i=0;i<obj.length;i++){                    
                    if(prodId == obj[i].product.Id){
                        obj[i].Version=response.getReturnValue();
                        objForConfigure=obj[i];
                        break;
                    }
                }
                cmp.set("v.ProductsAndDiscountsWrapperListt",obj);
                
                //helper.VersionChanged(cmp,event,objForConfigure,prodId);
                */
                $A.util.removeClass(cmp.find("configModal1"), 'slds-fade-in-open');
                $A.util.removeClass(cmp.find("configModalBackdrop"), 'slds-fade-in-open');
                //var sObjectUrl='https://'+window.location.hostname.split('--')[0]+'.lightning.force.com/lightning/r/ERP7__Version__c/'+response.getReturnValue()+'/view';
                //window.open(sObjectUrl,'_parent');
            }
        });
        $A.enqueueAction(action);
    },
    
    detailPage : function(cmp,event,helper){
        var RecId = event.currentTarget.getAttribute('data-proId');
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    handleChange : function(cmp,event,helper){
        
        var currentTarget=event.currentTarget.dataset.value;
        //var currentTarget=event.currentTarget.getAttribute('id');
        var feature = event.currentTarget.getAttribute('data-feature');
        
        helper.disableOthers(cmp,event,currentTarget,feature);
    },
    //================Product configuration end==================================
    
    
})