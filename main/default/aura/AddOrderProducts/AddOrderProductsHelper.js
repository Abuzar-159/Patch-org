({        
	getInitialPro : function(cmp,event,orderId,currentQuantity) {
        
        var action=cmp.get("c.initialProducts");
        action.setParams({orderId : orderId,currentQuantity :currentQuantity});
        action.setCallback(this,function(response){
            var state=response.getState();	
            if(state=="SUCCESS"){
                console.log('res of initialProducts:',response.getReturnValue());
                var res=response.getReturnValue();                               
                cmp.set("v.listOfProduct",res);
                cmp.set("v.islistOfProduct",true);
                this.fetchOrderLine1(cmp,event);
            }else{
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+' '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchOrderLine1 : function(cmp,event){
        var action=cmp.get("c.fetchOrderLine");
        action.setParams({OrderId : cmp.get("v.OrderId")});
        action.setCallback(this,function(response){
            var state=response.getState();	
            if(state=="SUCCESS"){
               
                var res=response.getReturnValue();
                cmp.set("v.errorMsg",res.errorMsg);
                var selectedProducts=[];
                for(var i=0;i<res.ordLineWapper.length;i++){
                    selectedProducts[i]={};
                    selectedProducts[i].CurrentDiscounts = res.ordLineWapper[i].CurrentDiscounts;                    
                    selectedProducts[i].checkSelected=true;
                    if(res.ordLineWapper[i].ordLine.Description != undefined)
                    	selectedProducts[i].description=res.ordLineWapper[i].ordLine.Description;
                    else
                        selectedProducts[i].description='';
                    selectedProducts[i].disPlans=res.ordLineWapper[i].disPlans;
                    if(! res.ordLineWapper[i].isPercent)
                    	selectedProducts[i].discountPercent=res.ordLineWapper[i].discountPercent/res.ordLineWapper[i].ordLine.Quantity;
                    else
                        selectedProducts[i].discountPercent=res.ordLineWapper[i].discountPercent;
                    selectedProducts[i].discountPlan=res.ordLineWapper[i].discountPlan;
                    selectedProducts[i].isPercent=res.ordLineWapper[i].isPercent;
                    selectedProducts[i].maxDiscount=res.ordLineWapper[i].maxDiscount;
                    selectedProducts[i].minDiscount=res.ordLineWapper[i].minDiscount;
                    selectedProducts[i].otherTax=parseFloat(res.ordLineWapper[i].otherTax);
                    var pbeArray=[];
                    pbeArray.push({
                        Product:{
                            'Id':res.ordLineWapper[i].ordLine.Product2Id,
                            'Name':res.ordLineWapper[i].ordLine.Product2.Name,
                            'ProductCode':res.ordLineWapper[i].ordLine.Product2.ProductCode,
                            'ERP7__Version__c':res.ordLineWapper[i].ordLine.Product2.ERP7__Version__c !=undefined ? res.ordLineWapper[i].ordLine.Product2.ERP7__Version__c : '',
                            'ERP7__Picture__c':res.ordLineWapper[i].ordLine.Product2.ERP7__Picture__c,
                            'ERP7__Configure__c':res.ordLineWapper[i].ordLine.Product2.ERP7__Configure__c,
                            'ERP7__Allow_Back_Orders__c':res.ordLineWapper[i].ordLine.Product2.ERP7__Allow_Back_Orders__c,
                            'Description':res.ordLineWapper[i].ordLine.Description
                        }
                    });
                    selectedProducts[i].pbe={};                    
                    selectedProducts[i].pbe.Product2=pbeArray[0].Product;
                    selectedProducts[i].pbe.Product2Id=res.ordLineWapper[i].ordLine.Product2Id;
                    selectedProducts[i].pbe.UnitPrice=res.ordLineWapper[i].ordLine.UnitPrice;
                    selectedProducts[i].quantity=res.ordLineWapper[i].ordLine.Quantity;
                    selectedProducts[i].stock=res.ordLineWapper[i].stock;
                    selectedProducts[i].tax=res.ordLineWapper[i].tax;
                    selectedProducts[i].taxId=res.ordLineWapper[i].taxId;
                    selectedProducts[i].tiesDists=res.ordLineWapper[i].tierDists;
                    selectedProducts[i].vatAmount=parseFloat(res.ordLineWapper[i].vatAmount);
                    selectedProducts[i].orderLineId=res.ordLineWapper[i].ordLine.Id;
                    if(res.ordLineWapper[i].ordLine.ERP7__Product_Version__c != undefined)
                    	selectedProducts[i].version=res.ordLineWapper[i].ordLine.ERP7__Version__c;
                    else
                        selectedProducts[i].version='';
                }
                cmp.set("v.selectedProducts",selectedProducts);
                cmp.set("v.Spinner", false);
            }else{
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+' '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
    },
    
    taxCalculation : function(cmp,event){
        
        var selectedProducts=cmp.get("v.selectedProducts");        
        for(var i=0;i<selectedProducts.length;i++){
            var discount=0;
            var vatAmount1=0;
            var otherTax1=0;
            var discountPercent1=parseFloat(selectedProducts[i].discountPercent);
            if(selectedProducts[i].discountPercent != 0){
                if(selectedProducts[i].isPercent){
                    discount= ((parseFloat(selectedProducts[i].pbe.UnitPrice)*parseFloat(selectedProducts[i].quantity))*parseFloat(selectedProducts[i].discountPercent))/100;
                }else{
                    discount=parseFloat(selectedProducts[i].quantity)*parseFloat(selectedProducts[i].discountPercent);
                }
            }
            if(selectedProducts[i].tax.ERP7__Tax_Rate__c != undefined) vatAmount1= (selectedProducts[i].tax.ERP7__Apply_Tax_On__c == 'Cost Price' && selectedProducts[i].pbe.ERP7__Purchase_Price__c != undefined)?(parseFloat(selectedProducts[i].tax.ERP7__Tax_Rate__c) / 100 * (parseFloat(selectedProducts[i].pbe.ERP7__Purchase_Price__c))):(parseFloat(selectedProducts[i].tax.ERP7__Tax_Rate__c) / 100 * ((parseFloat(selectedProducts[i].pbe.UnitPrice)*parseFloat(selectedProducts[i].quantity)) - discount));
            if(selectedProducts[i].tax.ERP7__Other_Tax_Rate__c != undefined) otherTax1=(selectedProducts[i].tax.ERP7__Apply_Tax_On__c == 'Cost Price' && selectedProducts[i].pbe.ERP7__Purchase_Price__c != undefined)?(parseFloat(selectedProducts[i].tax.ERP7__Other_Tax_Rate__c) / 100 * (parseFloat(selectedProducts[i].pbe.ERP7__Purchase_Price__c))) : (parseFloat(selectedProducts[i].tax.ERP7__Other_Tax_Rate__c) / 100 * ((parseFloat(selectedProducts[i].pbe.UnitPrice)*parseFloat(selectedProducts[i].quantity)) - discount));
            selectedProducts[i].vatAmount=vatAmount1;
            selectedProducts[i].otherTax=otherTax1;
        }        
        cmp.set("v.selectedProducts",selectedProducts);
    },
    
    validatelistOfProduct : function(cmp,event){
        
        var listOfProduct = cmp.get("v.listOfProduct");
        var isFieldsCom=false;
        var isPercent=true;
        var count=0;
        for(var i=0;i<listOfProduct.length;i++){
            if(listOfProduct[i].checkSelected){
                count++;
               
                if(listOfProduct[i].pbe.UnitPrice == ''){
                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Please_enter_the_Price_fields_that_are_marked'));
                }
                
                if(listOfProduct[i].quantity == ''){
                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Please_enter_the_quantity_fields_that_are_marked'));
                }
                
                if(parseInt(listOfProduct[i].discountPercent) == 0){} 
                else if(listOfProduct[i].discountPercent == ''){
                    cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Please_enter_the_Discount_fields_that_are_marked'));
                    isPercent=false;
                }
                
                if(listOfProduct[i].pbe.UnitPrice == '' || listOfProduct[i].quantity == '' || isPercent==false){
                    return false;
                }else{
                    isFieldsCom=true;
                }
            }
        }
        
        if(count == 0){
            sforce.one.showToast({
                "title": $A.get('$Label.c.PH_Warning'),
                "message": $A.get('$Label.c.PH_OrderPRod_Please_select_item_to_add'),
                "type": "warning"
            });
        }
        if(isFieldsCom) return true;
        else return false;
    },
    
    validateFields : function(cmp,event){
       
        var selectedProducts=cmp.get("v.selectedProducts");
        var isFieldsCom=false;
        var isPercent=true;
        for(var i=0;i<selectedProducts.length;i++){
            
            if(selectedProducts[i].pbe.UnitPrice == ''){
                cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Please_enter_the_Price_fields_that_are_marked'));
            }
            
            if(selectedProducts[i].quantity == ''){
                cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Please_enter_the_quantity_fields_that_are_marked'));
            }
            
            if(parseInt(selectedProducts[i].discountPercent) == 0){} 
            else if(selectedProducts[i].discountPercent == ''){
                cmp.set("v.errorMsg",$A.get('$Label.c.PH_OrderProd_Please_enter_the_Discount'));
                isPercent=false;
            }               
                        
            if(selectedProducts[i].pbe.UnitPrice == '' || selectedProducts[i].quantity == '' || isPercent==false){
                return false;
            }else{
                isFieldsCom=true;
            }
        }
        if(isFieldsCom) return true;
        else return false;
    },
    
    //===============Product Configuration start===================
    Configure : function(cmp, event, proforConfig) { 
        
        var OrderId=cmp.get("v.OrderId");
        //var proforConfig=event.getSource().get("v.title");
       
        cmp.set("v.proforConfig",proforConfig);
        var action = cmp.get("c.getOptionProd");
        action.setParams({proforConfig : proforConfig,OrderId : OrderId});
        action.setCallback(this, function(response){
            var state=response.getState();	
            if(state==="SUCCESS"){
                
                cmp.set("v.proOptions",response.getReturnValue().featrWrapper);
               
                cmp.set("v.totalStock",response.getReturnValue().totalStock);
               
                cmp.set("v.proName",response.getReturnValue().product.Name);
                cmp.set("v.errorMsg",response.getReturnValue().errorMsg);
                this.optionRules(cmp,event,proforConfig);
                $A.util.addClass(cmp.find("configModal1"), 'slds-fade-in-open');
                $A.util.addClass(cmp.find("configModalBackdrop"), 'slds-fade-in-open');
                //cmp.set("v.Spinner", false); 
            }else{
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+' '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);        
    },
    
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
                                    //document.getElementById(child).checked=true;
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
                
                if(cmp.get('v.isSelectFirst') ==='true'){
                    
                    this.selectFirstOption1(cmp,event);
                }
                cmp.set("v.Spinner", false); 
            }else{
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+' '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
    },
    
    //=========Select first option from all feature==========
    selectFirstOption : function(cmp,event){
        
        var proOptions = cmp.get("v.proOptions");
       
        for(var i=0;i<proOptions.length;i++){            
            if(cmp.get('v.isSelectFirst') ==='true'){
                
                for(var j=0;j<proOptions[i].featOpt.length;j++){
                    var currentId=proOptions[i].featOpt[j].Id;
                    if(!document.getElementById(currentId).disabled){
                        document.getElementById(currentId).checked=true;
                        break;
                    }
                }
            }
            if(proOptions[i].feature.Name == 'Default' || proOptions[i].feature.Name == 'default'){
                
                for(var k=0;k<proOptions[i].featOpt.length;k++){
                    var currentId1=proOptions[i].featOpt[k].Id;
                    if(!document.getElementById(currentId1).disabled){
                        document.getElementById(currentId1).checked=true;
                    }
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
    
    disableOthers : function(cmp,event,currentTarget,feature){
        
        //var feature=document.getElementById(currentTarget).text;
        
        var proOption=cmp.get("v.proOptions");
        for(var i=0; i<proOption.length; i++){
            if(proOption[i].feature.Id == feature && proOption[i].feature.ERP7__Is_Multiple_BOM__c==false){
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
                }
            }
            
        }
    },
    //==============product configurator ends====================
})