({
    getPrice: function(component, event, helper) {
        
        try {
            // component.find() 
            
            if (component.get("v.getPriceBool") == true) {
                var action = component.get("c.fetchPrice");
                if (component.get("v.item.ERP7__Cost_Card__c") != undefined && component.get("v.item.ERP7__Cost_Card__c") != null && component.get("v.item.ERP7__Cost_Card__c") != '') {
                    console.log('getPrice called ');
                    action.setParams({
                        "ccId": component.get("v.item.ERP7__Cost_Card__c")
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            if(response.getReturnValue() != null){
                                var res = response.getReturnValue().costcard;
                                var multiCurrencyEnabled=response.getReturnValue().multiCurrencyEnabled;
                                if (res != null) {
                                    if(multiCurrencyEnabled) component.set("v.item.CurrencyIsoCode",res.CurrencyIsoCode);
                                    component.set('v.alloweditPrice',response.getReturnValue().editUnitPrice);
                                    console.log('res.editUnitPrice : ',response.getReturnValue().editUnitPrice);
                                    //if(res.ERP7__Quantity__c >= 0) component.set("v.item.ERP7__Quantity__c",res.ERP7__Quantity__c); 
                                    if (res.ERP7__Cost__c >= 0) component.set("v.item.ERP7__Unit_Price__c", res.ERP7__Cost__c);
                                    var totalPrice = 0.00;
                                    if((!$A.util.isEmpty(component.get("v.DefTaxRate")) && !$A.util.isUndefinedOrNull(component.get("v.DefTaxRate")))){
                                        if(component.get("v.DefTaxRate") > 0){
                                            component.set("v.item.ERP7__Tax_Rate__c", component.get("v.DefTaxRate"));
                                            console.log('deftaxrate seting here');
                                        }
                                    }
                                    //var totalPrice= parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c")); 
                                    if (res.ERP7__Cost__c >= 0 && component.get("v.item.ERP7__Quantity__c") >= 0) totalPrice = res.ERP7__Cost__c * component.get("v.item.ERP7__Quantity__c");
                                    var taxAmount = (component.get("v.item.ERP7__Tax_Rate__c") * totalPrice)/100;
                                    component.set("v.item.ERP7__Tax__c", taxAmount.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
                                    if(component.get("v.item.ERP7__Tax__c")!=null && component.get("v.item.ERP7__Tax__c")!='' && component.get("v.item.ERP7__Tax__c")!=undefined) totalPrice = totalPrice;// + taxAmount.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                    component.set("v.item.ERP7__Cost_Card__c", component.get("v.item.ERP7__Cost_Card__c"));
                                    var totAmount = 0.00;
                                    totAmount = parseFloat(totalPrice.toFixed($A.get("$Label.c.DecimalPlacestoFixed"))) + parseFloat(taxAmount.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
                                    component.set("v.item.ERP7__Total_Price__c", totAmount);
                                    if(!$A.util.isEmpty(res.ERP7__Vendor_Part_Number__c) && !$A.util.isUndefinedOrNull(res.ERP7__Vendor_Part_Number__c)) component.set("v.item.ERP7__Vendor_product_Name__c",res.ERP7__Vendor_Part_Number__c);
                                    else  component.set("v.item.ERP7__Vendor_product_Name__c",res.ERP7__Product__r.ERP7__Vendor_product_Name__c);
                                   // component.set("v.item.ERP7__Lead_Time_Days__c",response.getReturnValue().LeadTime); commented shaguftha 16_01_24
                                    $A.enqueueAction(component.get("c.updateTotalPrice")); // added this line by shaguftha on 07_07_2023 as it was not calculating the total pice and tax correctly
                                }
                                //component.set("v.getPriceBool",'false');          
                            } else{
                                //('getPrice response  null');
                            }
                            
                        }
                        else{
                            //('getPrice Exception Occured');  
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
            
        } catch (e) { console.log('err~>'+e); }
    },
    
    getCategory : function(component, event, helper){
        //component.set("v.displayAccount", false);
        var TotalAAPercentage = 0;
        if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
            if(component.get("v.item.Accounts.length") > 0){
                var itemAccs = component.get("v.item.Accounts");
                //for(var i in itemAccs){
                for(var i = 0; i < itemAccs.length; i++){
                    if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                    }
                }
            }
        }
        component.set("v.TotalAAPercentage",TotalAAPercentage);
        let poStatus = component.get("c.getCategoryList");
        poStatus.setCallback(this,function(response){
            let resList = response.getReturnValue();
            let resListupdated = [];
            //for(var i in resList){
            for(var i = 0; i < resList.length; i++){
                if(i!=0) resListupdated.push(resList[i]);
            }
            component.set("v.PoliCategoryList",resListupdated);                
            $A.util.addClass(component.find('mainSpin'), "slds-hide");            
        });
        $A.enqueueAction(poStatus);
        /*setTimeout(
            $A.getCallback(function() {
                component.set("v.displayAccount", true);
            }), 3000
        );*/
    },
    
    getCostCard: function(component, event, helper) {
        try{
            var action = component.get("c.fetchCostCardIds");
            action.setParams({
                "vendorId": component.get("v.vendorId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    if (response.getReturnValue() != null) component.set("v.costCardIds", response.getReturnValue()); //item.ERP7__Cost_Card__c         
                }
            });
            $A.enqueueAction(action);
        } catch (e) { console.log('err~>'+e); }
    },
    
    getProductCC: function(component, event, helper) {
        console.log('getProductCC called');
        try{
            if($A.util.isEmpty(component.get("v.item"))){
                console.log('getProductCC inhere1');
                if($A.util.isEmpty(component.get("v.item.ERP7__Product__c")) || $A.util.isUndefinedOrNull(component.get("v.item.ERP7__Product__c"))){
                    if(component.get("v.item.ERP7__Cost_Card__c") != undefined)
                        component.set("v.item.ERP7__Cost_Card__c",null);
                    if(component.get("v.item.ERP7__Description__c")!= undefined)
                        component.set("v.item.ERP7__Description__c",'');
                    if(component.get("v.item.Name")!= undefined)
                        component.set("v.item.Name",'');
                    if(component.get("v.item.ERP7__Quantity__c")!= undefined)
                        component.set("v.item.ERP7__Quantity__c",'');
                    if(component.get("v.item.ERP7__Unit_Price__c")!= undefined)
                        component.set("v.item.ERP7__Unit_Price__c",'');
                    if(component.get("v.item.ERP7__Total_Price__c")!= undefined)
                        component.set("v.item.ERP7__Total_Price__c",'');
                }
            }
            else {
                console.log('getProductCC fetchProductCC calling');
                var action = component.get("c.fetchProductCC");
                action.setParams({
                    "vendorId": component.get("v.vendorId"),
                    "productId": component.get("v.item.ERP7__Product__c")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        console.log('getProductCC resp~>',response.getReturnValue());
                        if(response.getReturnValue() != null){   
                            console.log('getProductCC setting ERP7__Cost_Card__c here');
                            component.set("v.item.ERP7__Cost_Card__c", response.getReturnValue().Id); 
                           // component.set("v.item.ERP7__Lead_Time_Days__c", response.getReturnValue().ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c); commented shaguftha on 16_01_24
                        }
                        else component.set("v.item.ERP7__Cost_Card__c",null);
                    }else{
                        console.log('getProductCC error~>',JSON.stringify(response.getError()));
                    } 
                });
                $A.enqueueAction(action);
                
                if(component.get("v.item.ERP7__Description__c ") == null || component.get("v.item.ERP7__Description__c ") == '' || component.get("v.item.ERP7__Description__c ") == undefined){
                    console.log('fetchProductDesc calling');
                    var action = component.get("c.fetchProductDesc");
                    action.setParams({ "productId": component.get("v.item.ERP7__Product__c")});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            console.log('fetchProductDesc resp~>',response.getReturnValue());
                            
                            if (response.getReturnValue() != null) {
                                component.set("v.item.ERP7__Description__c", response.getReturnValue().ERP7__Vendor_Supplier_Description__c);
                                component.set("v.item.ERP7__Inventory_Account__c", response.getReturnValue().ERP7__Inventory_Account__c);
                                if(response.getReturnValue().ERP7__Version__c != null) component.set("v.item.ERP7__Version__c", response.getReturnValue().ERP7__Version__c);
                                var Name = response.getReturnValue().Name;
                                console.log('Name : ',Name,' Length : ',Name.length);
                                if(Name.length >= 80){
                                    var trimmedString = Name.substring(0, 79);
                                    console.log('trimmedString : ',trimmedString);
                                    component.set("v.item.Name",trimmedString);
                                }
                                else{
                                    component.set("v.item.Name",response.getReturnValue().Name);  
                                }
                                
                                if(component.get("v.item.ERP7__Vendor_product_Name__c ") == null || component.get("v.item.ERP7__Vendor_product_Name__c ") == '' || component.get("v.item.ERP7__Vendor_product_Name__c ") == undefined) component.set("v.item.ERP7__Vendor_product_Name__c",response.getReturnValue().ERP7__Vendor_product_Name__c);
                                
                            }
                        }
                    });
                    $A.enqueueAction(action);
                }
                $A.enqueueAction(component.get("c.getstockdetails"));
            }  
        } catch (e) { console.log('err~>'+e); }
    },
    
    setccList: function(component, event, helper) {
        component.find("costCard").set("v.listOfSearchRecords", component.get("v.costCardIds"));
    },
    
    updateTotalPrice: function(component, event, helper) {
        try{
            console.log('updateTotalPrice poli called');
            var qty = (!$A.util.isEmpty(component.get("v.item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Quantity__c"))) ? component.get("v.item.ERP7__Quantity__c") : 0;
            var unitprice = (!$A.util.isEmpty(component.get("v.item.ERP7__Unit_Price__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Unit_Price__c"))) ? component.get("v.item.ERP7__Unit_Price__c") : 0;
            var taxamt = (!$A.util.isEmpty(component.get("v.item.ERP7__Tax__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Tax__c"))) ? component.get("v.item.ERP7__Tax__c") : 0;
            
            var val = parseFloat(qty * unitprice) + parseFloat(taxamt);
            if(val != undefined && val != null){
                if(val > 0) val = val.toFixed($A.get("$Label.c.DecimalPlacestoFixed")); else val = 0;
            }else val = 0;
            component.set("v.item.ERP7__Total_Price__c",val);
            if((!$A.util.isEmpty(component.get("v.DefTaxRate")) && !$A.util.isUndefinedOrNull(component.get("v.DefTaxRate")))){
                if(component.get("v.DefTaxRate") > 0){
                    component.set("v.item.ERP7__Tax_Rate__c", component.get("v.DefTaxRate"));
                    console.log('deftaxrate setinghere1');
                }
            }
            component.set("v.TotalPrice",val);
            var cmpqty = component.find("qty");
            if(!$A.util.isUndefined(cmpqty)) helper.validateCheck(cmpqty);
            /*var price = component.find("amount");
        if (!$A.util.isUndefined(price))
            helper.validateCheck(price);*/
            helper.ValidateQuantity(component, event, helper);
            /* if(component.get("v.item.ERP7__Total_Price__c") != '' && component.get("v.item.ERP7__Total_Price__c") != null && component.get("v.item.ERP7__Total_Price__c") != undefined){
            if(component.get("v.item.ERP7__Total_Price__c") > 0){
                //do nothing
            }else component.set("v.item.Accounts",[]); 
        }else component.set("v.item.Accounts",[]); */
            $A.enqueueAction(component.get("c.UpdateTax"));
            //new line below
            helper.updateAllocationAmounts(component);
        } catch (e) { console.log('updateTotalPrice err~>'+e); }
    },
    
    deletePoli: function(component, event, helper) {
        
        //var itemToDel=component.get('v.itemToDel');
        var currtItem=event.getSource().get('v.title');
        //if(currtItem != null) itemToDel.push(currtItem);
        //component.set('v.itemToDel',itemToDel);
        console.log('currtItem:',currtItem);
        console.log('Index:',component.get("v.index"));
        try {
            console.log('try1');
            var e = $A.get("e.c:RequisitionToPurchaseOrderEvent"); //  component.getEvent("ExpertServiceEvent");                                                       
            console.log('try2');
            e.setParams({
                "Index": component.get("v.index"),
                "itemToDelCurr":currtItem
            });
            console.log('try3');
            e.fire();
            console.log('try4');
        } catch (ex) {console.log('catch:',ex);}
        console.log('out1');
        component.set("v.Tax",0);
        console.log('out2');
    },
    
    validate: function(component, event, helper) {
        var NoErrors = true;
        var cmpqty = component.find("qty");
        if (!$A.util.isUndefined(cmpqty))
            NoErrors = helper.validateCheck(cmpqty);
        var price = component.find("amount");
        if (!$A.util.isUndefined(price))
            NoErrors = helper.validateCheck(price);
        
        /*var productField = component.find("product");
        if (!$A.util.isUndefined(productField))
            NoErrors = helper.checkvalidationLookup(productField);*/
        return NoErrors;
    },
    
    lookupClickCostCard: function(cmp, helper) {
        try{
            var pro = cmp.get("v.item.ERP7__Product__c");
            var ven = cmp.get("v.vendorId");
            var recId = cmp.get("v.recId");
            console.log('lookupClickCostCard ven : ',ven);
            var qry = ' ';
            if (pro != undefined && pro != '') qry = 'And ERP7__Product__c = \'' + pro + '\'';
            else if(recId != undefined && recId != '' && pro == null) qry = 'And ERP7__Product__c = null';
            else if(recId == '' && pro == null) qry = 'And ERP7__Product__c = null';
            if (ven != undefined && ven != '') qry += ' AND ERP7__Supplier__c =\'' + ven + '\'';
            qry += ' AND ERP7__Cost__c >\=\ 0    And ERP7__Active__c = true And ERP7__Quantity__c >\=\ 0 And ERP7__Minimum_Quantity__c >\=\ 0 And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
            console.log('lookupClickCostCard qry : ',qry);
            cmp.set("v.qry", qry);
        } catch (e) { console.log('err~>'+e); }
    },
    
    lookupClickProduct : function(cmp, helper) {
        try{
            var ven = cmp.get("v.vendorId");
            var filerbaseOnven = $A.get("$Label.c.Show_Vendor_Product_Name");
            console.log('filerbaseOnven : ',filerbaseOnven);
            var qry = ' ';
            if(ven != undefined && ven != '' && filerbaseOnven)  qry += ' AND (ERP7__Default_Vendor__c =\'' + ven + '\' OR ERP7__Default_Vendor__c = \'\' )';
            //if(filerbaseOnven) qry += ' AND ERP7__Issue_Manufacturing_Order__c = false ';
            qry += ' AND ERP7__Issue_Purchase_Order__c = true ';
            //qry += 'OR ERP7__Default_Vendor__c = \'\' ';
            cmp.set("v.prodqry", qry);
            console.log('prodqry : ',qry);
        } catch (e) { console.log('err~>'+e); }
    },
    
    getstockdetails : function(cmp, helper) {
        try{
            var obj = cmp.get('v.item');
            console.log('obj getstockdetails: '+JSON.stringify(obj));
            var currprod = cmp.get('v.item.ERP7__Product__c');
            console.log('currprod : '+currprod);
            console.log('Dc : '+cmp.get('v.dCId'));
            if((currprod != '' && currprod != null) || (cmp.get('v.dCId') != '' && cmp.get('v.dCId') != null)){
                let defaultcc;
                if(cmp.get('v.vendorId') !=  null && cmp.get('v.vendorId') != '' && cmp.get('v.vendorId') != undefined) defaultcc = {'ERP7__Product__c':currprod,'ERP7__Supplier__c':cmp.get('v.vendorId')};
                else defaultcc = {'ERP7__Product__c':currprod};
                cmp.set('v.defaultCCval',defaultcc);
                console.log('defaultCCval : '+cmp.get('v.defaultCCval'));
                var action = cmp.get('c.getstocks');
                action.setParams({'DCId' : cmp.get('v.dCId'),'ProductId' : currprod});
                action.setCallback(this,function(response){
                    let resList = response.getReturnValue();
                    console.log('response : '+JSON.stringify(resList));
                    if(currprod == resList.Product){
                        cmp.set('v.item.ItemsinStock',resList.Stock);
                        cmp.set('v.item.demand',resList.Demand);
                        cmp.set('v.item.AwaitingStock',resList.AwaitingStocks);
                    }
                    //component.set("v.POStatusoptions",resList);                
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");            
                });
                $A.enqueueAction(action);
            }
        } catch (e) { console.log('err~>'+e); }
    },
    
    /*getvencostcard :function(component, helper) {
        var pro = component.get("v.item.ERP7__Product__c");
        var approveven = component.get('v.approvedVendor');
        if(approveven!= null){
            var action = component.get("c.fetchvenCC");
        
        action.setParams({
            "vendorId": approveven,
            "productId": pro
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null){   component.set("v.item.ERP7__Cost_Card__c", response.getReturnValue().Id);   
                }
                else component.set("v.item.ERP7__Cost_Card__c",'');
            } 
        });
        $A.enqueueAction(action);
            
        }
    },*/
    
    /* lookupClickApprover : function (component,event){
    	var pro = component.get("v.item.ERP7__Product__c");
        var cc = component.get("v.item.ERP7__Cost_Card__c");
        var qry= ' ';
        if (pro != undefined && pro != '') qry +=  'AND ERP7__Product__c = \''+ pro +'\' ';
        if(cc != undefined && cc != '') qry += 'AND ERP7__Cost_Card__c = \''+ cc +'\'';
        component.set('v.venqry',qry);
    }*/
    
    /* start :function (cmp,event){
        var row = event.currentTarget;
        cmp.set('v.row',row);
    },
    dragover: function(cmp,event){
        var e = event;
        e.preventDefault();
        
        var row=cmp.get('v.row');
        let children= Array.from(e.target.parentNode.parentNode.children);
        if(children.indexOf(e.target.parentNode)>children.indexOf(row))
            e.target.parentNode.after(row);
        else
            e.target.parentNode.before(row);
    },*/
    
    UpdateTax : function(component,event,helper){
        try{
            console.log('v.Tax set here bfr~>'+component.get("v.item.ERP7__Tax_Rate__c"));
            var qty = (!$A.util.isEmpty(component.get("v.item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Quantity__c"))) ? component.get("v.item.ERP7__Quantity__c") : 0;
            var unitprice = (!$A.util.isEmpty(component.get("v.item.ERP7__Unit_Price__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Unit_Price__c"))) ? component.get("v.item.ERP7__Unit_Price__c") : 0;
            var taxamt = 0;
            var taxrate = (!$A.util.isEmpty(component.get("v.item.ERP7__Tax_Rate__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Tax_Rate__c"))) ? component.get("v.item.ERP7__Tax_Rate__c") : 0;
            
            if(taxrate > 0 && unitprice > 0 && qty > 0) taxamt = parseFloat(((unitprice * qty)/100) * taxrate).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            //if(qty > 0 && taxamt > 0) taxamt = parseFloat(taxamt * qty).toFixed($A.get("$Label.c.DecimalPlacestoFixed")); else taxamt = 0;
            console.log('taxamt ~>'+taxamt+' typeof~>'+typeof taxamt);
            
            component.set("v.item.ERP7__Tax__c",taxamt);
            console.log('v.item.ERP7__Tax__c set here~>'+component.get("v.item.ERP7__Tax__c"));
            
            console.log('Tax Amount TEst :',parseFloat((unitprice * qty * taxrate) / 100));
            component.set("v.Tax",parseFloat((unitprice * qty * taxrate) / 100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            //component.set("v.Tax",parseFloat((unitprice * taxrate) / 100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            console.log('v.Tax set here after~>'+component.get("v.Tax"));
            
            console.log('parseFloat(qty * unitprice)~>'+parseFloat(qty * unitprice));
            
            var totalPrice = parseFloat(qty * unitprice) + parseFloat(taxamt);
            console.log('totalPrice ~>'+totalPrice+' typeof~>'+typeof totalPrice);
            if(totalPrice != undefined && totalPrice != null){
                if(totalPrice > 0) totalPrice = totalPrice.toFixed($A.get("$Label.c.DecimalPlacestoFixed")); else totalPrice = 0;
            }else totalPrice = 0;
            
            component.set("v.item.ERP7__Total_Price__c",totalPrice);
            console.log('v.item.ERP7__Total_Price__c set here~>'+component.get("v.item.ERP7__Total_Price__c"));
            //$A.enqueueAction(component.get("c.updateTotalPrice"));
        } catch (e) { console.log('UpdateTax err~>'+e); }
    },
    
    displayAccounts : function(component,event,helper){
        try{
            var action = component.get("c.fetchProductDesc");
            action.setParams({ "productId": component.get("v.item.ERP7__Product__c")});
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    if (response.getReturnValue() != null){
                        console.log('resp fetchProductDesc~>',response.getReturnValue());
                        var assignDefaultItemCOA = false;
                        if(component.get("v.isAccCategoryChanged") == false || $A.util.isEmpty(component.get("v.item.ERP7__Chart_of_Account__c")) || $A.util.isUndefinedOrNull(component.get("v.item.ERP7__Chart_of_Account__c"))){
                            assignDefaultItemCOA = true;
                        }
                        if(assignDefaultItemCOA == false){
                            if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                                if(component.get("v.item.Accounts.length") > 0){
                                    //dont assignDefaultItemCOA
                                }else assignDefaultItemCOA = true;
                            }else assignDefaultItemCOA = true;
                        }
                        if(!$A.util.isEmpty(response.getReturnValue().ERP7__Inventory_Account__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().ERP7__Inventory_Account__c)){
                            component.set("v.defaultProdAccA",response.getReturnValue().ERP7__Inventory_Account__c);
                            if(assignDefaultItemCOA) component.set("v.item.ERP7__Chart_of_Account__c", response.getReturnValue().ERP7__Inventory_Account__c);
                        }
                        
                        
                        var assignDefaultItemAccCategory = false;
                        if(component.get("v.isAccCategoryChanged") == false || $A.util.isEmpty(component.get("v.item.ERP7__Account_Category__c")) || $A.util.isUndefinedOrNull(component.get("v.item.ERP7__Account_Category__c"))){
                            assignDefaultItemAccCategory = true;
                        }
                        if(assignDefaultItemAccCategory == false){
                            if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                                if(component.get("v.item.Accounts.length") > 0){
                                    //dont assignDefaultItemAccCategory
                                }else assignDefaultItemAccCategory = true;
                            }else assignDefaultItemAccCategory = true;
                        }
                        if(!$A.util.isEmpty(response.getReturnValue().ERP7__Project__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().ERP7__Project__c)){
                            component.set("v.defaultProdAnalA",response.getReturnValue().ERP7__Project__c);
                            if(!$A.util.isEmpty(response.getReturnValue().ERP7__Project__r.ERP7__Account_Category__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().ERP7__Project__r.ERP7__Account_Category__c)){
                                if(assignDefaultItemAccCategory) component.set("v.item.ERP7__Account_Category__c", response.getReturnValue().ERP7__Project__r.ERP7__Account_Category__c);
                            }
                        }
                    }  
                    
                    var TotalAAPercentage = 0;
                    if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                        if(component.get("v.item.Accounts.length") > 0){
                            var itemAccs = component.get("v.item.Accounts");
                            //for(var i in itemAccs){
                            for(var i = 0; i < itemAccs.length; i++){
                                if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                                    if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                                }
                            }
                        }
                    }
                    component.set("v.TotalAAPercentage",TotalAAPercentage);
                    
                    console.log('arshad TotalAAPercentage~>'+component.get("v.TotalAAPercentage")+' typeof~>'+typeof component.get("v.TotalAAPercentage"));
                    var remainingTotalAAPercent = parseFloat(100 - component.get("v.TotalAAPercentage")).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    console.log('arshad remainingTotalAAPercent~>'+remainingTotalAAPercent+' typeof~>'+typeof remainingTotalAAPercent);
                    
                    component.set("v.displayAccount", true);
                    var poliList = [];
                    var polList = [];
                    if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null) polList = component.get("v.item.Accounts");
                    console.log('polList before~>'+polList.length);
                    
                    var pol = [];
                    pol = component.get("v.poli");
                    var indexed = pol.length;
                    var poliIndex = parseInt(component.get("v.index") + 1);
                    if(pol != null) poliList = pol[indexed-1].Accounts;
                    
                    console.log('component.get("v.item.ERP7__Quantity__c")~>'+component.get("v.item.ERP7__Quantity__c"));
                    console.log('parseFloat(component.get("v.item.ERP7__Quantity__c")~>'+parseFloat(component.get("v.item.ERP7__Quantity__c")));
                                
                    console.log('component.get("v.item.ERP7__Unit_Price__c")~>'+component.get("v.item.ERP7__Unit_Price__c"));
                    console.log('parseFloat(component.get("v.item.ERP7__Unit_Price__c"))~>'+parseFloat(component.get("v.item.ERP7__Unit_Price__c")));
                    
                    console.log('parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c")))~>'+parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))));
                    console.log('(parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))) * remainingTotalAAPercent)~>'+(parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))) * remainingTotalAAPercent));
                    
                    console.log('(parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))) * remainingTotalAAPercent)/100~>'+(parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))) * remainingTotalAAPercent)/100);
                                
                    if(component.get("v.AutoAccountAllocation")){
                        var coaId = '';
                        var projId = '';
                        /*
                            if(poliList[0] != undefined){
                                coaId = pol[indexed-1].ERP7__Chart_of_Account__c;
                                projId = poliList[0].ERP7__Project__c;
                                //component.set("v.coaId", coaId); why? 
                                //component.set("v.projId", projId); why?
                                component.set("v.item.ERP7__Chart_of_Account__c", pol[indexed-1].ERP7__Chart_of_Account__c);
                                component.set("v.item.ERP7__Account_Category__c", pol[indexed-1].ERP7__Account_Category__c);
                            }
                        */
                        
                        if(pol.length > 0){
                            console.log('Auto pol[0]~>'+JSON.stringify(pol[0]));
                            if(pol[0].Accounts != null && pol[0].Accounts != undefined){
                                if(pol[0].Accounts.length > 0){
                                    if(pol[0].Accounts[0].ERP7__Project__c != undefined && pol[0].Accounts[0].ERP7__Project__c != null && pol[0].Accounts[0].ERP7__Project__c != ''){
                                        projId = pol[0].Accounts[0].ERP7__Project__c;
                                    }
                                }
                            }
                            console.log('projId~>'+projId);
                            if(pol[0].ERP7__Chart_of_Account__c != null && pol[0].ERP7__Chart_of_Account__c != undefined && pol[0].ERP7__Chart_of_Account__c != ''){
                                coaId = pol[0].ERP7__Chart_of_Account__c;
                            }
                            console.log('coaId~>'+coaId);
                            component.set("v.item.ERP7__Chart_of_Account__c", coaId);
                            if(pol[0].ERP7__Account_Category__c != null && pol[0].ERP7__Account_Category__c != undefined && pol[0].ERP7__Account_Category__c != ''){
                                component.set("v.item.ERP7__Account_Category__c", pol[0].ERP7__Account_Category__c);
                            }
                        }
                        
                        if(remainingTotalAAPercent > 0){
                            polList.push({sObjectType :'ERP7__Dimension__c', ERP7__Chart_of_Account__c : coaId, ERP7__Project__c : projId, ERP7__Sort_Order__c:parseInt(poliIndex), ERP7__Allocation_Percentage__c :remainingTotalAAPercent, ERP7__Allocation_Amount__c: ((parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))) * remainingTotalAAPercent)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")) });
                        }else console.log('arshad new dimension not added because remainingTotalAAPercent~>'+remainingTotalAAPercent);         
                    }
                    else{
                        if(remainingTotalAAPercent > 0){
                            polList.push({sObjectType :'ERP7__Dimension__c', ERP7__Chart_of_Account__c : component.get("v.item.ERP7__Chart_of_Account__c"), ERP7__Project__c : (assignDefaultItemAccCategory) ? component.get("v.defaultProdAnalA") : '', ERP7__Sort_Order__c:parseInt(poliIndex), ERP7__Allocation_Percentage__c :remainingTotalAAPercent, ERP7__Allocation_Amount__c: ((parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))) * remainingTotalAAPercent)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")) });
                        }else console.log('arshad new dimension not added because remainingTotalAAPercent~>'+remainingTotalAAPercent);    
                    }
                    console.log('polList after~>'+polList.length);
                    component.set("v.item.Accounts",polList);
                    
                    var TotalAAPercentage2 = 0;
                    if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                        if(component.get("v.item.Accounts.length") > 0){
                            var itemAccs = component.get("v.item.Accounts");
                            //for(var i in itemAccs){
                            for(var i = 0; i < itemAccs.length; i++){
                                if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                                    if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage2 += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                                }
                            }
                        }
                    }
                    component.set("v.TotalAAPercentage",TotalAAPercentage2);
                }
                else{
                    var errors = response.getError();
                    console.log("fetchProductDesc error : ", errors);
                }
            });
            $A.enqueueAction(action);
            
        } catch (e) { console.log('displayAccounts err~>'+e); }
    },
    
    updateACTaxAmount : function(component,event,helper){
        try{
            var TotalAAPercentage = 0;
            if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                if(component.get("v.item.Accounts.length") > 0){
                    var itemAccs = component.get("v.item.Accounts");
                    //for(var i in itemAccs){
                    for(var i = 0; i < itemAccs.length; i++){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
            if(component.get("v.item.ERP7__Total_Price__c") != '' && component.get("v.item.ERP7__Total_Price__c") != null && component.get("v.item.ERP7__Total_Price__c") != undefined){
                var aaacount = []; aaacount = component.get("v.item.Accounts");
                if(aaacount != null && aaacount != undefined){
                    if(aaacount.length > 0){
                        //for(var a in aaacount){
                        for(var a = 0; a < aaacount.length; a++){
                            if(aaacount[a].ERP7__Allocation_Percentage__c != undefined && aaacount[a].ERP7__Allocation_Percentage__c != null && aaacount[a].ERP7__Allocation_Percentage__c != ''){
                                if(aaacount[a].ERP7__Allocation_Percentage__c > 0){
                                    if(!$A.util.isEmpty(component.get("v.item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Quantity__c")) && !$A.util.isEmpty(component.get("v.item.ERP7__Unit_Price__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Unit_Price__c"))){
                                        aaacount[a].ERP7__Allocation_Amount__c = parseFloat((parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))) * aaacount[a].ERP7__Allocation_Percentage__c)/100;
                                        aaacount[a].ERP7__Allocation_Amount__c = aaacount[a].ERP7__Allocation_Amount__c.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                    }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                                    //if(component.get("v.item.ERP7__Tax__c") == null || component.get("v.item.ERP7__Tax__c") == undefined || component.get("v.item.ERP7__Tax__c") == ''){
                                    //    aaacount[a].ERP7__Allocation_Amount__c = parseFloat(component.get("v.item.ERP7__Total_Price__c") * aaacount[a].ERP7__Allocation_Percentage__c)/100;
                                    //} else aaacount[a].ERP7__Allocation_Amount__c = parseFloat( parseFloat(component.get("v.item.ERP7__Total_Price__c") - component.get("v.item.ERP7__Tax__c")) * aaacount[a].ERP7__Allocation_Percentage__c)/100;
                                }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                            }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                        }
                    }
                }
                component.set("v.item.Accounts",aaacount); 
            }
        } catch (e) { console.log('updateACTaxAmount err~>'+e); }
    },
    
    updateACTaxPerentage : function(component,event,helper){
        try{
            if(component.get("v.item.ERP7__Total_Price__c") != '' && component.get("v.item.ERP7__Total_Price__c") != null && component.get("v.item.ERP7__Total_Price__c") != undefined){
                var aaacount = [];
                aaacount = component.get("v.item.Accounts");
                //for(var a in aaacount){
                for(var a = 0; a < aaacount.length; a++){
                    if(aaacount[a].ERP7__Allocation_Amount__c != undefined && aaacount[a].ERP7__Allocation_Amount__c != null && aaacount[a].ERP7__Allocation_Amount__c != ''){
                        if(aaacount[a].ERP7__Allocation_Amount__c > 0){
                            var percent = 0;
                            if(!$A.util.isEmpty(component.get("v.item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Quantity__c")) && !$A.util.isEmpty(component.get("v.item.ERP7__Unit_Price__c")) && !$A.util.isUndefinedOrNull(component.get("v.item.ERP7__Unit_Price__c"))){
                                percent = parseFloat(parseFloat(aaacount[a].ERP7__Allocation_Amount__c) / parseFloat(parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"))))*100;
                                aaacount[a].ERP7__Allocation_Percentage__c = percent.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                            //if(component.get("v.item.ERP7__Tax__c") == null || component.get("v.item.ERP7__Tax__c") == undefined || component.get("v.item.ERP7__Tax__c") == ''){
                            //    percent = parseFloat(aaacount[a].ERP7__Allocation_Amount__c / component.get("v.item.ERP7__Total_Price__c"))*100;
                            //}else percent = parseFloat(aaacount[a].ERP7__Allocation_Amount__c / parseFloat(component.get("v.item.ERP7__Total_Price__c") - component.get("v.item.ERP7__Tax__c")))*100;
                            
                        }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                    }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                }
                component.set("v.item.Accounts",aaacount); 
            }
            
            var TotalAAPercentage = 0;
            if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                if(component.get("v.item.Accounts.length") > 0){
                    var itemAccs = component.get("v.item.Accounts");
                    //for(var i in itemAccs){
                    for(var i = 0; i < itemAccs.length; i++){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
        } catch (e) { console.log('updateACTaxPerentage err~>'+e); }
    },
    
   /* deleteAnalyAcc :function(component, event, helper) {
        try{
            if(event.getSource().get('v.title') != undefined && event.getSource().get('v.title') != null){
                if(event.getSource().get('v.title') != ''){
                    var action=component.get("c.deleteDimensions");
                    action.setParams({'demId':event.getSource().get('v.title')});
                    action.setCallback(this,function(response){
                        //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                        //component.set("v.currencyList",response.getReturnValue().currencyList);
                    });
                    $A.enqueueAction(action);
                }
            }
            console.log('inside deleteAnalyAcc');
            var poliList =[]; 
            poliList = component.get("v.item.Accounts");
            console.log('poliList before delete length~>'+poliList.length);
            if(event.getSource().get('v.name') != undefined && event.getSource().get('v.name') != null){
                var index = event.getSource().get('v.name'); 
                console.log('going to delete index~>'+index);
                //poliList[index].ERP7__Project__c = null;
                //delete poliList[index].ERP7__Project__c;
                console.log('poliList before delete ~>'+JSON.stringify(poliList));
                poliList.splice(index,1);  
            }
            console.log('poliList after delete length ~>'+poliList.length);
            console.log('poliList after delete ~>'+JSON.stringify(poliList));
            
            component.set("v.item.Accounts",poliList);
            
            if(poliList.length <= 0 && component.get("v.item.Accounts.length") > 0){
                component.set("v.item.Accounts",null);
            }
            
            console.log('v.item.Accounts after delete length~>'+component.get("v.item.Accounts.length"));
            console.log('v.item.Accounts after delete ~>'+JSON.stringify(component.get("v.item.Accounts")));
            
            var TotalAAPercentage = 0;
            if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                if(component.get("v.item.Accounts.length") > 0){
                    var itemAccs = component.get("v.item.Accounts");
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }else{
                    console.log('inhere1');
                    component.set("v.item.ERP7__Chart_of_Account__c", null);
                    var defvalue = '';
                    var PoliCategoryList = component.get("v.PoliCategoryList");
                    if(PoliCategoryList != undefined && PoliCategoryList != null){
                        if(PoliCategoryList.length > 0){
                            defvalue = PoliCategoryList[0];
                        }
                    }
                    if(defvalue != '') component.set("v.item.ERP7__Account_Category__c", defvalue);
                    console.log('inhere2');
                    console.log('component.get("v.item.ERP7__Chart_of_Account__c")~>'+component.get("v.item.ERP7__Chart_of_Account__c"));
                    console.log('component.get("v.item.ERP7__Account_Category__c")~>'+component.get("v.item.ERP7__Account_Category__c"));
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
        } catch (e) { console.log('deleteAnalyAcc err~>'+e); }
    }, */
    
    deleteAnalyAcc :function(component, event, helper) {
        try{
            var index1 = event.getSource().get('v.name'); 
            if(event.getSource().get('v.title') != undefined && event.getSource().get('v.title') != null){
                if(event.getSource().get('v.title') != ''){
                    var action=component.get("c.deleteDimensions");
                    action.setParams({'demId':event.getSource().get('v.title')});
                    action.setCallback(this,function(response){
                        //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                        //component.set("v.currencyList",response.getReturnValue().currencyList);
                    });
                    $A.enqueueAction(action);
                }
            }
            console.log('inside deleteAnalyAcc');
            var poliList =[]; 
            poliList = component.get("v.item.Accounts");
            console.log('poliList before delete length poitems cmp~>'+poliList.length);
            if(event.getSource().get('v.name') != undefined && event.getSource().get('v.name') != null){
                var index = event.getSource().get('v.name'); 
                console.log('going to delete index poitems cmp~>'+index);
               // poliList[index].ERP7__Project__c = null;
                delete poliList[index].ERP7__Project__c;
                console.log('poliList before delete poitems cmp ~>'+JSON.stringify(poliList));
                poliList.splice(index,1);  
            }
            console.log('poliList after delete length poitems cmp ~>'+poliList.length);
            console.log('poliList after delete poitems cmp ~>',JSON.stringify(poliList));
            component.set("v.item.Accounts",null);
            console.log('poliList after delete poitems cmp 11 ~>',JSON.stringify(component.get("v.item.Accounts")));
            console.log('poliList after delete poitems cmp 11 after ~>',JSON.stringify(poliList));
            component.set("v.item.Accounts",poliList);
            console.log('poliList after delete poitems cmp 1122 ~>',JSON.stringify(component.get("v.item.Accounts")));
            if(poliList.length <= 0 && component.get("v.item.Accounts.length") > 0){
                component.set("v.item.Accounts",null);
            }
            
            console.log('v.item.Accounts after delete length poitems cmp~>'+component.get("v.item.Accounts.length"));
            console.log('v.item.Accounts after delete poitems cmp ~>'+JSON.stringify(component.get("v.item.Accounts")));
            
            var TotalAAPercentage = 0;
            if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                if(component.get("v.item.Accounts.length") > 0){
                    var itemAccs = component.get("v.item.Accounts");
                    //for(var i in itemAccs){
                    for(var i = 0; i < itemAccs.length; i++){
                        console.log('itemAccs[i] : ',JSON.stringify(itemAccs[i]));
                        if(itemAccs[i].ERP7__Project__c === '' && itemAccs[i].ERP7__Allocation_Percentage__c == undefined && itemAccs[i].sObjectType == undefined) {
                            itemAccs.splice(i,1);  
                            console.log('remove deleted items');
                        }
                        if(itemAccs[i] != undefined){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                                if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                            }
                        }
                       
                        
                    }
                }else{
                    console.log('inhere1');
                    component.set("v.item.ERP7__Chart_of_Account__c", null);
                    var defvalue = '';
                    var PoliCategoryList = component.get("v.PoliCategoryList");
                    if(PoliCategoryList != undefined && PoliCategoryList != null){
                        if(PoliCategoryList.length > 0){
                            defvalue = PoliCategoryList[0];
                        }
                    }
                    if(defvalue != '') component.set("v.item.ERP7__Account_Category__c", defvalue);
                    console.log('inhere2');
                    console.log('component.get("v.item.ERP7__Chart_of_Account__c")~>'+component.get("v.item.ERP7__Chart_of_Account__c"));
                    console.log('component.get("v.item.ERP7__Account_Category__c")~>'+component.get("v.item.ERP7__Account_Category__c"));
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
        } catch (e) { console.log('deleteAnalyAcc err~>'+e); }
    },
    
    
    resetAA : function(component, event, helper) {
        try{
            console.log('inside resetAA');
            var TotalAAPercentage = 0;
            if(component.get("v.item.Accounts") != undefined && component.get("v.item.Accounts") != null){
                if(component.get("v.item.Accounts.length") > 0){
                    var itemAccs = component.get("v.item.Accounts");
                    //for(var i in itemAccs){
                    for(var i = 0; i < itemAccs.length; i++){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
            component.set("v.item.ERP7__Chart_of_Account__c", null);
            var poliList =[]; 
            poliList=component.get("v.item.Accounts");
            //for(var x in poliList){
            for(var x = 0; x < poliList.length; x++){
                poliList[x].ERP7__Project__c = null;
            }
            component.set("v.item.Accounts",poliList);
            component.set("v.isAccCategoryChanged",true);
        } catch (e) { console.log('resetAA err~>'+e); }
    },
    
    
    
    getprojectBudgetdetails : function(cmp, helper) {
        try{
            var obj = cmp.get('v.item');
            console.log('obj getstockdetails: '+JSON.stringify(obj));
            var currprod = cmp.get('v.item.ERP7__Product__c');
            var currcoa = cmp.get('v.item.ERP7__Chart_of_Account__c');
            console.log('currprod : '+currprod);
            console.log('projectId : '+cmp.get('v.projectId'));
            if((currcoa!='' && currcoa!=null) && (cmp.get('v.projectId') != '' && cmp.get('v.projectId') != null)){
                var action = cmp.get('c.getProjectBudget');
                action.setParams({'CoaId' : currcoa, 'Project': cmp.get('v.projectId')});
                action.setCallback(this,function(response){
                    let resList = response.getReturnValue();
                    console.log('response : '+JSON.stringify(resList));
                    //if(currprod == resList.Product){
                        cmp.set('v.item.projBudget',resList.projBudget);
                        cmp.set('v.item.projCommittedBudget',resList.projCommittedBudget);
                        cmp.set('v.item.projConsumedBudget',resList.projConsumedBudget);
                        cmp.set('v.item.projRemainingBudget',resList.projRemainingBudget);
                    	cmp.set('v.item.ERP7__Budget_Account__c', resList.budget);
                        cmp.set('v.item.ERP7__Project__c', cmp.get('v.projectId'));
                    //}
                    //component.set("v.POStatusoptions",resList);                
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");            
                });
                $A.enqueueAction(action);
            }
        } catch (e) { console.log('err~>'+e); }
    },
    
    
    
    getprojectDepBudgetdetails : function(cmp, helper) {
        try{
            var obj = cmp.get('v.item');
            console.log('obj getstockdetails: '+JSON.stringify(obj));
            var currprod = cmp.get('v.item.ERP7__Product__c');
            var currcoa = cmp.get('v.item.ERP7__Chart_of_Account__c');
            var currdep = cmp.get('v.item.ERP7__Organisation_Business_Unit__c');
            console.log('currprod : '+currprod);
            console.log('projectId : '+cmp.get('v.projectId'));
            if((currcoa!='' && currcoa!=null) && (cmp.get('v.projectId') != '' && cmp.get('v.projectId') != null)){
                var action = cmp.get('c.getProjectDepartmentBudget');
                action.setParams({'CoaId' : currcoa, 'Project': cmp.get('v.projectId'), 'Department': currdep});
                action.setCallback(this,function(response){
                    let resList = response.getReturnValue();
                    console.log('response : '+JSON.stringify(resList));
                    if(resList!=null){
                        cmp.set('v.item.ERP7__Budget_Account__c', resList.budget);
                        cmp.set('v.item.ERP7__Project__c', cmp.get('v.projectId'));
                    }
                   
                    //component.set("v.POStatusoptions",resList);                
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");            
                });
                $A.enqueueAction(action);
            }
        } catch (e) { console.log('err~>'+e); }
    },
})