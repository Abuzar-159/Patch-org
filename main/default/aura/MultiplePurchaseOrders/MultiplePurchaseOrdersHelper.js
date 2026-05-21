({
    getupdateVen : function(component,event,helper,index) {
        $A.util.removeClass(component.find('mainSpin'),"slds-hide");
        component.set('v.CurrpoliIndex',index);
        var poliwrp = component.get('v.poliWrap');
        var prodlist = component.get('v.poliWrap.poli');
        var currProdId = '';
        
        for(var x in prodlist){
            if(x == index && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)){
                prodlist[x].isSelected = true;
                currProdId = prodlist[x].pli.ERP7__Product__c;
            }
            else{
                prodlist[x].isSelected = false; 
            }
            
        }
        
        if(!$A.util.isEmpty(currProdId)){
            var getProductVendors = component.get('c.getvendor');
            getProductVendors.setParams({
                ProductId : currProdId
            });
            getProductVendors.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    var obj = response.getReturnValue();
                    
                    if(obj.appvendr.length > 0){
                        for(var x in prodlist){
                            if(x == index && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)){
                                prodlist[x].appvendr = obj.appvendr;  
                            }
                        }
                        //component.set('v.poliWrap.appven',obj.appven);
                        component.set('v.poliWrap.poli',prodlist);
                    }
                    else if(obj.appvendr.length == 0){
                        component.set('v.exceptionError',$A.get('$Label.c.PH_No_Approved_vendors_available'));
                    }
                }
            });
            $A.enqueueAction(getProductVendors);
        }
        //component.set('v.poliWrap.appven',poliwrp.appven);
        component.set('v.poliWrap.poli',prodlist);
        $A.util.addClass(component.find('mainSpin'),"slds-hide");
        
    },
    getStockdetails : function(component,event,ProdID,DChannelId) {
        console.log('helper called');
        try{
            $A.util.removeClass(component.find('mainSpin'),"slds-hide");
            
            var action = component.get('c.getstocks');
            action.setParams({
                ProductId : ProdID,
                DCId : DChannelId
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    var result = response.getReturnValue();
                    console.log('response : '+JSON.stringify(result));
                    var obj = component.get('v.poliWrap.poli');
                    for(var c in obj){
                        if(obj[c].pli.ERP7__Product__c == result.Product){
                            console.log('Product id matched');
                            obj[c].Demand =  result.Demand;
                            obj[c].Stock =  result.Stock;
                            obj[c].AwaitingStocks =  result.AwaitingStocks;
                        }
                    }
                    component.set('v.poliWrap.poli',obj);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('Error : '+JSON.stringify(e));
        }
        
    },
    
    
    fetApproveVendor : function(component, event, helper, currProdId, currindex){
        var prodlist = component.get('v.poliWrap.poli');
        var getProductVendors = component.get('c.getvendor');
        getProductVendors.setParams({
            ProductId : currProdId
        });
        getProductVendors.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                component.set('v.showvendor',true);
                var obj = response.getReturnValue();
                console.log('response : '+JSON.stringify(obj));
                //component.set('v.poliWrap.Stock',obj.Stock);
                //component.set('v.poliWrap.Demand',obj.Demand);
                //component.set('v.poliWrap.diffDmnStk',obj.diffDmnStk);
                if(obj.appvendr.length > 0){
                    //component.set('v.poliWrap.appven',obj.appvendr);                        
                    var proName = obj.appvendr[0].ERP7__Product__r.Name;
                    console.log('proName : ',proName);
                    var vendorProdname = obj.appvendr[0].ERP7__Product__r.ERP7__Vendor_product_Name__c;
                    console.log('vendorProdname : ',vendorProdname);
                    for(var x in prodlist){
                        if(x == currindex && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)){
                            prodlist[x].pli.Name =  proName;
                            prodlist[x].pli.ERP7__Vendor_product_Name__c =(prodlist[x].pli.ERP7__Cost_Card__c == null || prodlist[x].pli.ERP7__Cost_Card__c == '') ? vendorProdname : prodlist[x].pli.ERP7__Vendor_product_Name__c;
                            prodlist[x].appvendr = obj.appvendr;
                            prodlist[x].isSelected = true;
                        }
                    }
                    component.set('v.poliWrap.poli',prodlist);
                }
                else if(obj.appvendr.length == 0){
                    component.set('v.exceptionError',$A.get('$Label.c.PH_No_Approved_vendors_available'));
                    var emptylst = [];
                    //component.set('v.poliWrap.appven',emptylst);
                    
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(getProductVendors);
    },
    deletePoli : function(component, event, helper,currtItem) {
        console.log('helper called');
        //var currtItem=event.getSource().get('v.title');
        console.log('deletePoli currtItem : ',currtItem);
        var poliList;
        poliList=component.get("v.poliWrap.poli");
        console.log('poliList : ',JSON.stringify(poliList));
        console.log('(poliList.length - 1) : ',(poliList.length));
        poliList.splice(currtItem,1);
        console.log('(poliList.length) : ',(poliList.length));
        console.log('poliList after: ',JSON.stringify(poliList));
        component.set("v.poliWrap.poli",poliList);
    },
    MOInit : function(component, event, helper){
         $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var MOAction = component.get("c.populateMOlines");
        MOAction.setParams({MOId : component.get("v.MOId") });
        MOAction.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                
                var obj = response.getReturnValue();
                console.log('obj populateMOlines : ',response.getReturnValue());
                component.set('v.alloweditPrice',obj.editUnitPrice);
                component.set("v.distributionChannel.Id",obj.distributionChannel.Id);
                component.set("v.distributionChannel.Name",obj.distributionChannel.Name);
                component.set("v.channelId",obj.distributionChannel.ERP7__Channel__c);
                component.set("v.dChannelId", obj.distributionChannel.Id);
                component.set('v.showAllocations',obj.AllolateProcess);
                console.log('Coming true?',obj.AllolateProcess);
                 console.log('Coming showAllocations?',component.get('v.showAllocations'));
                if(obj.errorMSg != null && obj.errorMSg != undefined && obj.errorMSg != ''){
                    helper.showToast('Warning','warning',obj.errorMSg);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
                else{
                    if(obj.poli.length < 1) component.set('v.addProductsMsg','All BoMs have stock! Click on Add button to add a product');
                    for(var x in obj.poli){
                        if(obj.poli[x].appvendr != undefined && obj.poli[x].appvendr.length == 1){//if more than 1 approvendor need to chnage this
                            var qry = '';
                            obj.poli[x].pli.ERP7__Approved_Vendor__c =  obj.poli[x].appvendr[0].Id;
                            obj.poli[x].pli.ERP7__Vendor__c = obj.poli[x].appvendr[0].ERP7__Vendor__c;
                            //obj.poli[x].pli.ERP7__Cost_Card__c = obj.poli[x].appvendr[0].ERP7__Cost_Card__c;
                            obj.poli[x].pli.ERP7__Description__c = obj.poli[x].appvendr[0].ERP7__Product__r.Description;
                            //obj.poli[x].pli.ERP7__Unit_Price__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c == null || obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c == '') ? "0" : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c;
                            //if(obj.poli[x].pli.ERP7__Quantity__c == 0 || obj.poli[x].pli.ERP7__Quantity__c == null || obj.poli[x].pli.ERP7__Quantity__c == undefined || obj.poli[x].pli.ERP7__Quantity__c == '') obj.poli[x].pli.ERP7__Quantity__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c == null || obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c == '') ? 0 : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c;
                            //obj.poli[x].pli.ERP7__Total_Price__c = obj.poli[x].pli.ERP7__Unit_Price__c * obj.poli[x].pli.ERP7__Quantity__c;
                            //obj.poli[x].pli.ERP7__Vendor_product_Name__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c == null ||obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c =='')?obj.poli[x].appvendr[0].ERP7__Product__r.ERP7__Vendor_product_Name__c : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c;
                            obj.poli[x].ERP7__Vendor_product_Name__c = obj.poli[x].appvendr[0].ERP7__Product__r.ERP7__Vendor_product_Name__c; 
                            obj.poli[x].pli.ERP7__Lead_Time_Days__c = (obj.poli[x].appvendr[0].ERP7__Lead_Time__c == null ||obj.poli[x].appvendr[0].ERP7__Lead_Time__c =='') ? obj.poli[x].appvendr[0].ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c : obj.poli[x].appvendr[0].ERP7__Lead_Time__c;
                            qry = 'And ERP7__Product__c = \'' + obj.poli[x].pli.ERP7__Product__c + '\'';
                            qry += ' AND ERP7__Supplier__c =\'' + obj.poli[x].appvendr[0].ERP7__Vendor__c + '\'';
                            //console.log('qry : ',qry);
                            obj.poli[x].ccqry = qry;
                            obj.poli[x].isSelected = false;
                            const yourDate = new Date();
                            const day = String(yourDate.getDate()).padStart(2, '0');
                            const month = String(yourDate.getMonth() + 1).padStart(2, '0');
                            const year = yourDate.getFullYear();
                            const datetoday= `${year}-${month}-${day}`;
                            if(obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Start_Date__c <= datetoday && obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__End_Date__c >= datetoday){
                            obj.poli[x].pli.ERP7__Cost_Card__c = obj.poli[x].appvendr[0].ERP7__Cost_Card__c;
                            obj.poli[x].pli.ERP7__Unit_Price__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c == null || obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c == '') ? "0" : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c;
                            if(obj.poli[x].pli.ERP7__Quantity__c == 0 || obj.poli[x].pli.ERP7__Quantity__c == null || obj.poli[x].pli.ERP7__Quantity__c == undefined || obj.poli[x].pli.ERP7__Quantity__c == '') obj.poli[x].pli.ERP7__Quantity__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c == null || obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c == '') ? 0 : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Minimum_Quantity__c;
                            obj.poli[x].pli.ERP7__Total_Price__c = obj.poli[x].pli.ERP7__Unit_Price__c * obj.poli[x].pli.ERP7__Quantity__c;
                            obj.poli[x].pli.ERP7__Vendor_product_Name__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c == null ||obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c =='')?obj.poli[x].appvendr[0].ERP7__Product__r.ERP7__Vendor_product_Name__c : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c;
                            }
                      }
                        else{
                            qry = 'And ERP7__Product__c = \'' + obj.poli[x].pli.ERP7__Product__c + '\'';
                            //qry += ' AND ERP7__Supplier__c =\'' + obj.poli[x].appvendr[0].ERP7__Vendor__c + '\'';
                            //console.log('qry : ',qry);
                            obj.poli[x].ccqry = qry;
                        }
                    }
                    component.set('v.poliWrap',obj); 
                    component.set('v.afterdelIndex', obj.poli.length);
                    console.log('component.get(v.poliWrap) after: '+JSON.stringify(component.get('v.poliWrap')));
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
              
            }
        });
        $A.enqueueAction(MOAction);
        
    },
    showToast : function(title,type,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type":type,
            "message": message
        });
        toastEvent.fire();
    },
     getDependentPicklistsFamily : function(component, event, helper) {
        console.log('getDependentPicklistsFamily called');
        var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : component.get("v.Poructobj"),
            parentField : component.get("v.FamilycontrollingFieldAPI"),
            childField : component.get("v.SubFamilydependingFieldAPI")
        });
        
        action.setCallback(this, function(response){
            var status = response.getState();
            console.log('getDependentPicklistsFamily status : ',status);
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                console.log('getDependentPicklistsFamily pickListResponse : ',response.getReturnValue());
                //save response 
                component.set("v.FamilydepnedentFieldMap",pickListResponse.pickListMap);
                
                // create a empty array for store parent picklist values 
                var parentkeys = []; // for store all map keys 
                var parentField = []; // for store parent picklist value to set on lightning:select. 
                
                // Iterate over map and store the key
                for (var pickKey in pickListResponse.pickListMap) {
                    console.log('getDependentPicklistsFamily pickKey~>'+JSON.stringify(pickKey));
                    parentkeys.push(pickKey);
                }
                
                //set the parent field value for lightning:select
                /*if (parentkeys != undefined && parentkeys.length > 0) {
                    parentField.push('');
                }*/
                
                for (var i = 0; i < parentkeys.length; i++) {
                    parentField.push(parentkeys[i]);
                }  
                // set the parent picklist
                console.log('getDependentPicklist parentField~>'+JSON.stringify(parentField));
                console.log('getDependentPicklist pickListResponse.controllingValues~>'+JSON.stringify(pickListResponse.controllingValues));
                //component.set("v.listControllingValues", parentField);
                component.set("v.familylst", pickListResponse.controllingValues);
                console.log('familylst  : ',component.get("v.familylst"));       
                component.set("v.seachItemFmily", '');
                component.set("v.subItemFmily", '');
            }
            else{
                console.log('getDependentPicklist err : '+JSON.stringify(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
    },
     getSearchProducts :function(component){
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var vendId ='';
        component.set('v.listOfProducts',[]);
        //component.set('v.selectedListOfProducts', []);
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch helper: ',globalsearch);
        component.set('v.addProductsMsg','');
        var action = component.get("c.getProducts");
        action.setParams({
            "venId":vendId,
            "searchString": component.get('v.searchItem'),
            "searchFamily": component.get('v.seachItemFmily'),
            "DCId": component.get('v.dChannelId'),
            "search" : globalsearch,
            "subFamily": component.get('v.subItemFmily'),
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('response getSearchProducts: ',response.getReturnValue());
                console.log('setting listOfProducts here5');
                component.set('v.listOfProducts',response.getReturnValue().wrapList);
                
                //Added by Arshad 03 Aug 2023
                try{
                    var standProds = component.get('v.listOfProducts');
                    if(standProds != undefined){
                        for(var x = 0; x < standProds.length; x++){
                            standProds[x].ERP7__Lead_Time_Days__c = standProds[x].prod.ERP7__Purchase_Lead_Time_days__c;
                            if(standProds[x].selCostCardId != undefined && standProds[x].selCostCardId != null && standProds[x].selCostCardId != ''){
                                console.log('in here1 standProds[x].selCostCardId~>'+standProds[x].selCostCardId);
                                var res = standProds[x].selectedCostCard;
                                console.log('standProds[x].selectedCostCard res~>',res);
                                
                                standProds[x].unitPrice  = parseFloat(res.ERP7__Cost__c);
                                
                                if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                                
                                console.log('defaultTaxRate~>'+component.get("v.defaultTaxRate"));
                                if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(component.get("v.defaultTaxRate"));
                                
                                let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                                console.log('tax  bfr:  ',tax);
                                
                                tax = tax * standProds[x].quantity;
                                
                                standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                
                                if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                                console.log('unitPrice : ',standProds[x].unitPrice);
                                console.log('quantity : ',standProds[x].quantity);
                                console.log('taxAmount : ',standProds[x].taxAmount);
                                console.log('taxPercent : ',standProds[x].taxPercent);
                                
                                standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                                console.log('TotalPrice : ',standProds[x].TotalPrice);
                                
                            }
                            if(standProds[x].prod.ERP7__Approved_Vendors__r != undefined && standProds[x].prod.ERP7__Approved_Vendors__r != null && standProds[x].prod.ERP7__Approved_Vendors__r != ''){
                                standProds[x].ERP7__Vendor__c= standProds[x].prod.ERP7__Approved_Vendors__r[0].ERP7__Vendor__c;
                                standProds[x].ERP7__Lead_Time_Days__c = (standProds[x].prod.ERP7__Approved_Vendors__r[0].ERP7__Lead_Time__c == '' || standProds[x].prod.ERP7__Approved_Vendors__r[0].ERP7__Lead_Time__c == null) ? standProds[x].prod.ERP7__Purchase_Lead_Time_days__c : standProds[x].prod.ERP7__Approved_Vendors__r[0].ERP7__Lead_Time__c;
                                //console.log('ERP7__Vendor__c', JSON.stringify(standProds[x]));
                            }
                            else{
                                standProds[x].ERP7__Vendor__c='';
                                
                            }
                        }
                        console.log('setting listOfProducts here11');
                        console.log('v.listOfProducts',standProds);
                        component.set('v.listOfProducts',standProds);
                    }
                    //for(var x in standProds){
                    
                }catch(e){
                    console.log('err~>',e);
                }
                
                component.set('v.addProductsMsg',response.getReturnValue().Msg);
                component.set('v.globalProdSearch',response.getReturnValue().globalSearch);
                console.log('globalsearch helpers set: ',component.get('v.globalProdSearch'));
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }else{
                console.log('Error getSearchProducts:',response.getError());
                component.set("v.exceptionError",response.getError());
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
        });
        $A.enqueueAction(action);
        
    },
    familyFieldChange : function(component, event, helper){
        try{
            console.log('familyFieldChange called');
            var controllerValue = component.get("v.seachItemFmily");//component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
            var pickListMap = component.get("v.FamilydepnedentFieldMap");
            console.log('controllerValue : '+controllerValue);
            if (controllerValue != '' && controllerValue != null && controllerValue != undefined) {
                //get child picklist value
                var childValues = pickListMap[controllerValue];
                var childValueList = [];
                if(childValues != undefined && childValues != null){
                    if(childValues.length > 0){
                        //childValueList.push('');
                        for (var i = 0; i < childValues.length; i++) {
                            childValueList.push(childValues[i]);
                        }
                    }
                }
                // set the child list
                console.log('childValueList~>'+JSON.stringify(childValueList));
                component.set("v.subfamilylst", childValueList);
                component.set('v.subItemFmily',childValueList[0].value);
                if(childValueList.length > 0){
                    component.set("v.bDisabledSubFamilyFld" , false); 
                    helper.getSearchProducts(component);
                }else{
                    component.set("v.bDisabledSubFamilyFld" , true); 
                    helper.getSearchProducts(component);
                }
            } else {
                var list = [];
                component.set("v.subfamilylst", list);
                component.set("v.bDisabledSubFamilyFld" , true);
            }
            
            /*  if(component.get("v.subfamilylst").length > 0){
                var listdependingValues = component.get("v.subfamilylst");
                component.set("v.subItemFmily",listdependingValues[0].value);
            }*/
            
            console.log('v.subItemFmily~>'+component.get("v.subItemFmily"));
        }catch(e){
            console.log('err parentFieldChange~>',e);
        }
    },
})