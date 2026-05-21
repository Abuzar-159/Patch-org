({
    doInit : function(component, event, helper) {
         component.set("v.CostCardFilter"," AND ERP7__Supplier__c != null AND ERP7__Product__c != null AND ERP7__Cost__c >= 0 AND ERP7__Active__c = true AND ERP7__Quantity__c >= 0 And ERP7__Minimum_Quantity__c >= 0 And ERP7__Start_Date__c <= TODAY And ERP7__End_Date__c >= TODAY ");
        console.log('from Mo?',component.get("v.FromMO") );
        if(!$A.util.isUndefined(component.get("v.MOId")) && !$A.util.isEmpty(component.get("v.MOId")) && component.get("v.FromMO") == true)
            helper.MOInit(component, event, helper);
        else{
            console.log('fromAP : '+component.get('v.fromAP'));
            console.log('from MO : '+component.get('v.FromMO'));
            console.log('MOId : '+component.get('v.MOId'));
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            
            var initaction = component.get("c.fetchChannelandDC");
            //initaction.setParams({});
            initaction.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    var obj = response.getReturnValue();
                    component.set('v.alloweditPrice',obj.editUnitPrice);
                    console.log('response.getReturnValue() : ',response.getReturnValue());
                    console.log('poliWrap : '+component.get('v.poliWrap'));
                    component.set("v.distributionChannel.Id",obj.distributionChannel.Id);
                    component.set("v.distributionChannel.Name",obj.distributionChannel.Name);
                    component.set("v.channelId",obj.distributionChannel.ERP7__Channel__c);
                    component.set("v.dChannelId", obj.distributionChannel.Id);
                    console.log('component.get(v.poliWrap) : '+component.get('v.poliWrap'));
                    if(component.get('v.poliWrap') == null || component.get('v.poliWrap') == ''){
                        console.log('1');
                        // let poli = obj.poli;
                        component.set('v.afterdelIndex', obj.poli.length); 
                        console.log('obj.poli.length',obj.poli.length);
                        if(obj.poli.length < 1) component.set('v.addProductsMsg','There are no products in demand');
                        for(var x in obj.poli){
                            console.log('2');
                            if(obj.poli[x].appvendr && obj.poli[x].appvendr.length == 1){//.length == 1
                                console.log('3');
                                var qry = '';
                                obj.poli[x].pli.ERP7__Approved_Vendor__c =  obj.poli[x].appvendr[0].Id;
                                obj.poli[x].pli.ERP7__Vendor__c = obj.poli[x].appvendr[0].ERP7__Vendor__c;
                                /*obj.poli[x].pli.ERP7__Cost_Card__c = obj.poli[x].appvendr[0].ERP7__Cost_Card__c;
                                obj.poli[x].pli.ERP7__Unit_Price__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c == null || obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c == '') ? "0" : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c;
                                obj.poli[x].pli.ERP7__Quantity__c = obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Quantity__c;
                                obj.poli[x].pli.ERP7__Total_Price__c = obj.poli[x].pli.ERP7__Unit_Price__c * obj.poli[x].pli.ERP7__Quantity__c;
                                obj.poli[x].pli.ERP7__Vendor_product_Name__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c == null ||obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c =='')?obj.poli[x].appvendr[0].ERP7__Product__r.ERP7__Vendor_product_Name__c : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c;*/
                                obj.poli[x].ERP7__Vendor_product_Name__c = obj.poli[x].appvendr[0].ERP7__Product__r.ERP7__Vendor_product_Name__c; 
                                obj.poli[x].pli.ERP7__Tax_Rate__c=0.00;
                                obj.poli[x].pli.ERP7__Tax__c=0;
                                obj.poli[x].pli.ERP7__Lead_Time_Days__c = (obj.poli[x].appvendr[0].ERP7__Lead_Time__c == null ||obj.poli[x].appvendr[0].ERP7__Lead_Time__c =='') ? obj.poli[x].appvendr[0].ERP7__Product__r.ERP7__Purchase_Lead_Time_days__c : obj.poli[x].appvendr[0].ERP7__Lead_Time__c;
                                qry = 'And ERP7__Product__c = \'' + obj.poli[x].pli.ERP7__Product__c + '\'';
                                qry += ' AND ERP7__Supplier__c =\'' + obj.poli[x].appvendr[0].ERP7__Vendor__c + '\'';
                                console.log('qry : ',qry);
                                obj.poli[x].ccqry = qry;
                                obj.poli[x].isSelected = false;
                                const yourDate = new Date();
                                const day = String(yourDate.getDate()).padStart(2, '0');
                                const month = String(yourDate.getMonth() + 1).padStart(2, '0');
                                const year = yourDate.getFullYear();
                                const datetoday= `${year}-${month}-${day}`;
                                console.log(datetoday +' == '+obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Start_Date__c +" && "+ datetoday + " == "+obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__End_Date__c);
                                if(obj.poli[x].appvendr[0].ERP7__Cost_Card__c != '' && obj.poli[x].appvendr[0].ERP7__Cost_Card__c != null && obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Start_Date__c <= datetoday && obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__End_Date__c >= datetoday){
                                    obj.poli[x].pli.ERP7__Cost_Card__c = obj.poli[x].appvendr[0].ERP7__Cost_Card__c;
                                    obj.poli[x].pli.ERP7__Unit_Price__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c == null || obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c == '') ? "0" : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Cost__c;
                                    obj.poli[x].pli.ERP7__Quantity__c = obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Quantity__c;
                                    obj.poli[x].pli.ERP7__Total_Price__c = obj.poli[x].pli.ERP7__Unit_Price__c * obj.poli[x].pli.ERP7__Quantity__c;
                                    obj.poli[x].pli.ERP7__Vendor_product_Name__c = (obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c == null ||obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c =='')?obj.poli[x].appvendr[0].ERP7__Product__r.ERP7__Vendor_product_Name__c : obj.poli[x].appvendr[0].ERP7__Cost_Card__r.ERP7__Vendor_Part_Number__c;
                                }
                            }
                        }
                        console.log('4');
                        console.log('here?');
                        component.set('v.poliWrap',obj);
                        console.log('component.get(v.poliWrap) after: '+JSON.stringify(component.get('v.poliWrap')));
                        //component.set('v.poliWrap.poli',poli);
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }
                    
                    else component.set('v.poliWrap',component.get('v.poliWrap'));
                    console.log('5');
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
                else{
                    console.log('Error:->',response.getError());
                    console.log('6');
                }
            });
            $A.enqueueAction(initaction);
        } 
        
    },
    addNew : function(component, event, helper) {
        var poliList = [];
        var Error = false;
        if(component.get("v.poliWrap.poli") != null) poliList = component.get("v.poliWrap.poli");
        if(!$A.util.isEmpty(poliList) && poliList.length > 0){
            for(var x in poliList){
                if(poliList[x].pli == undefined || poliList[x].pli == ''){
                    component.set('v.exceptionError',$A.get('$Label.c.PH_Please_Select_Product_to_proceed'));
                    Error = true;
                }
                else if(poliList[x].pli.ERP7__Product__c == null){
                    component.set('v.exceptionError',$A.get('$Label.c.PH_Please_Select_Product_to_proceed'));
                    Error = true;
                }
                    /*else if(poliList[x].pli.ERP7__Product__c != null && poliList[x].pli.ERP7__Vendor__c == null){
                        component.set('v.exceptionError',$A.get('$Label.c.PH_Please_Select_Vendor_to_proceed'));
                        Error = true;
                    }*/ //commented this on 22/12 as requested by Rahul
                
                        /*else if(poliList[x].pli.ERP7__Product__c != null && poliList[x].pli.ERP7__Approved_Vendor__c != null && poliList[x].pli.ERP7__Cost_Card__c == null){
                            component.set('v.exceptionError',$A.get('$Label.c.PH_Please_Select_Cost_card_to_proceed')); 
                            Error = true;
                        }
                            else if(poliList[x].pli.ERP7__Product__c != null && poliList[x].pli.ERP7__Approved_Vendor__c != null && poliList[x].pli.ERP7__Cost_Card__c != null && (poliList[x].pli.ERP7__Quantity__c <= 0 || $A.util.isEmpty(poliList[x].pli.ERP7__Quantity__c))){
                                component.set('v.exceptionError',$A.get('$Label.c.PH_Please_Enter_Quantity')); 
                                Error = true;
                            }*/
                
            }
            console.log('Error : '+Error);
            
        }
        if(!Error){
            console.log('poliList : ',JSON.stringify(poliList));
            var customProd = true;
            var qry='AND ERP7__Product__c = \'\'';
            poliList.unshift({pli: {sObjectType :'ERP7__Purchase_Line_Items__c', ERP7__Product__c : '',Name : '',ERP7__Quantity__c:"0",ERP7__Unit_Price__c:"0"},customProduct:customProd, ccqry:qry});
            console.log('poliList : ',JSON.stringify(poliList));
            component.set("v.poliWrap.poli",poliList);
            component.set('v.afterdelIndex', poliList.length);
        }
        
    },
    deletePoli : function(component, event, helper) {
        try{
            
            var currtItem=event.getSource().get('v.title');
            console.log('index',currtItem);
            var poliList;
            poliList = component.get("v.poliWrap.poli");
            console.log('poliList bfr:',poliList);
           if (currtItem >= 0 && currtItem < poliList.length) {
               component.set("v.reRenderPOLIS",false);
               poliList.splice(currtItem,1);
               console.log('poliList aftr:',poliList);
               component.set('v.afterdelIndex',poliList.length);
                console.log('afterdelIndex:',component.get('v.afterdelIndex'));
               component.set("v.reRenderPOLIS",true);
               //component.set("v.poliWrap.poli",poliList);
           }
        }
        catch(e){console.log('Exp:',e);}
        
        //var items=component.get('v.poliWrap.poli');
        //component.set("v.poliWrap.poli",items);
        
    },
    deleteDemandPolis: function(component, event, helper) {
        var poliList = component.get("v.poliWrap.poli");
        console.log('poliList bfr:',poliList);
        if (poliList.length > 1) {
            var result = confirm($A.get('$Label.c.Are_you_sure_you_want_to_delete'));
            if (result) {
                component.set("v.reRenderPOLIS",false);
                var customProd = false;
                //poliList.unshift({pli: {sObjectType :'ERP7__Purchase_Line_Items__c', ERP7__Product__c : '',Name : ''},customProduct:customProd});
                poliList.splice(1, poliList.length - 1);
                poliList[0].pli.ERP7__Product__c ='';
                poliList[0].pli.Name = '';
                poliList[0].pli.ERP7__Approved_Vendor__c = null;
                poliList[0].pli.ERP7__Vendor__c=null;
                poliList[0].pli.ERP7__Cost_Card__c = null;
                poliList[0].pli.ERP7__Quantity__c = 0;
                poliList[0].pli.ERP7__Unit_Price__c = "0";
                poliList[0].pli.ERP7__Total_Price__c = 0;
                poliList[0].pli.ERP7__Tax_Rate__c=0.00;
                poliList[0].pli.ERP7__Tax__c=0;
                poliList[0].isSelected = false;
                poliList[0].ERP7__Vendor_product_Name__c = '';
                console.log('poliList : ',JSON.stringify(poliList));
                component.set("v.reRenderPOLIS",true);
            }
        }
        //component.set('v.poliWrap.poli',poliList);
        component.set('v.afterdelIndex',poliList.length);
    },
    lookupClickProduct : function(component, event, helper) {
        try{
        var currindex = event.currentTarget.name;
        component.set('v.CurrpoliIndex',currindex);
        var prodlist = component.get('v.poliWrap.poli');
        var currProdId = '';
        console.log('currindex : '+currindex);
        for(var x in prodlist){
            console.log('prodlist[x] : '+JSON.stringify(prodlist[x]));
            if(x == currindex){//&& !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)
                prodlist[x].isSelected = true;
                currProdId = prodlist[x].pli.ERP7__Product__c;
            }
            /*else if(x == currindex && $A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)){
                component.set('v.exceptionError','Please Select Product to Proceed');
            }*/
        }
        //console.log('currProdId : '+currProdId);
        if(!$A.util.isEmpty(currProdId) && !$A.util.isUndefined(currProdId)){// && !$A.util.isUndefined(currProdId)
            console.log('not empty');
            helper.getStockdetails(component,event,currProdId,component.get('v.dChannelId'));
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var getProductVendors = component.get('c.getProdDetails');
            getProductVendors.setParams({
                ProductId : currProdId
            });
            getProductVendors.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    console.log('response of App vendor Id?',response.getReturnValue().ERP7__Approved_Vendors__r);
                    component.set('v.showvendor',true);
                    for(var x in prodlist){
                        if(x == currindex && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)){
                            prodlist[x].purchaseAppVendor = response.getReturnValue().ERP7__Purchase_From_Approved_Vendor__c;
                            prodlist[x].pli.Name = response.getReturnValue().Name;
                            prodlist[x].pli.ERP7__Tax_Rate__c=0.00;
                            prodlist[x].pli.ERP7__Tax__c=0;
                            prodlist[x].pli.ERP7__Lead_Time_Days__c = response.getReturnValue().ERP7__Purchase_Lead_Time_days__c;
                            prodlist[x].isSelected = false;
                            prodlist[x].pli.ERP7__Description__c = response.getReturnValue().Description;
                            if(response.getReturnValue().ERP7__Vendor_product_Name__c != '') prodlist[x].ERP7__Vendor_product_Name__c = response.getReturnValue().ERP7__Vendor_product_Name__c;
                            prodlist[x].ccqry = 'And ERP7__Product__c = \'' + prodlist[x].pli.ERP7__Product__c + '\'';
                            if(response.getReturnValue().ERP7__Purchase_From_Approved_Vendor__c){
                                helper.fetApproveVendor(component, event, helper, currProdId, currindex);
                            }
                            if(response.getReturnValue().ERP7__Approved_Vendors__r){
                            prodlist[x].pli.ERP7__Vendor__c= response.getReturnValue().ERP7__Approved_Vendors__r[0].ERP7__Vendor__c;
                            prodlist[x].pli.ERP7__Lead_Time_Days__c = (response.getReturnValue().ERP7__Approved_Vendors__r[0].ERP7__Lead_Time__c == null ||response.getReturnValue().ERP7__Approved_Vendors__r[0].ERP7__Lead_Time__c =='') ? response.getReturnValue().ERP7__Purchase_Lead_Time_days__c : response.getReturnValue().ERP7__Approved_Vendors__r[0].ERP7__Lead_Time__c;
                            console.log("yes?", response.getReturnValue().ERP7__Approved_Vendors__r[0].ERP7__Vendor__c);
                            }
                        }
                    }
                    component.set('v.poliWrap.poli',prodlist);
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(getProductVendors);
        }
        else{
            for(var x in prodlist){
                if(x == currindex ){
                    prodlist[x].pli.ERP7__Product__c ='';
                    prodlist[x].pli.Name = '';
                    prodlist[x].pli.ERP7__Approved_Vendor__c = null;
                    prodlist[x].pli.ERP7__Vendor__c=null;
                    prodlist[x].pli.ERP7__Cost_Card__c = null;
                    prodlist[x].pli.ERP7__Quantity__c = 0;
                    prodlist[x].pli.ERP7__Unit_Price__c = "0";
                    prodlist[x].pli.ERP7__Total_Price__c = 0;
                    prodlist[x].pli.ERP7__Tax_Rate__c=0.00;
                    prodlist[x].pli.ERP7__Tax__c=0;
                    prodlist[x].isSelected = false;
                    
                }
            }
            component.set('v.poliWrap.poli',prodlist);
        }
       console.log('component.get(v.poliWrap.poli)',component.get('v.poliWrap.poli')); 
        }catch(e){console.log('exception:',e);} 
    },
    popselectedDetails : function(cmp, event, helper) {
        if(cmp.get('v.exceptionError') != '') cmp.set('v.exceptionError','');
        var appvendorId = event.getSource().get('v.value');
        console.log('appvendorId : ',appvendorId);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var currindex = cmp.get('v.CurrpoliIndex');
        console.log('currindex : ',currindex);
        var prodlist = cmp.get('v.poliWrap.poli');
        console.log('prodlist : ',prodlist);
        var currProd = event.getSource().get('v.title');
        /* for(var x in prodlist){
            if((x == currindex ||  prodlist[x].pli.ERP7__Product__c == currindex) && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c) && prodlist[x].isSelected){
                currProd = prodlist[x].pli.ERP7__Product__c;
            }
        }*/
        console.log('currProd : ',currProd);
        if(!$A.util.isEmpty(currProd) && !$A.util.isEmpty(appvendorId)){
            var populatedetails = cmp.get('c.populatepolidetails');
            populatedetails.setParams({
                ProductId : currProd,
                venId : appvendorId
            });
            populatedetails.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    //cmp.set('v.showvendor',false);
                    var obj  = response.getReturnValue();
                    console.log('obj : ',response.getReturnValue());
                    var polilist = []; var vendortoset = ''; 
                    polilist = cmp.get('v.poliWrap.poli');
                    for(var x in polilist){
                        if((x == currindex || currProd == polilist[x].pli.ERP7__Product__c) && prodlist[x].isSelected){
                            if(currProd == obj.ERP7__Product__c) polilist[x].pli.ERP7__Product__c = obj.ERP7__Product__c;
                            //cmp.rfrshchild();
                            vendortoset = obj.ERP7__Supplier__c;
                            polilist[x].pli.ERP7__Vendor__c = obj.ERP7__Supplier__c;
                            polilist[x].pli.ERP7__Approved_Vendor__c =  appvendorId;
                            polilist[x].pli.ERP7__Cost_Card__c =  obj.Id;
                            polilist[x].pli.ERP7__Unit_Price__c = (obj.ERP7__Cost__c > 0) ? obj.ERP7__Cost__c : "0";
                            if(!$A.util.isEmpty(obj.ERP7__Product__r.ERP7__Vendor_product_Name__c) && !$A.util.isUndefined(obj.ERP7__Product__r.ERP7__Vendor_product_Name__c)) {
                                polilist[x].pli.ERP7__Vendor_product_Name__c = obj.ERP7__Product__r.ERP7__Vendor_product_Name__c;
                            }
                            if(obj.ERP7__Minimum_Quantity__c > 0 &&  obj.ERP7__Minimum_Quantity__c != '' &&  obj.ERP7__Minimum_Quantity__c != null &&  obj.ERP7__Minimum_Quantity__c != undefined){
                                if(polilist[x].pli.ERP7__Quantity__c == '' || polilist[x].pli.ERP7__Quantity__c == null || polilist[x].pli.ERP7__Quantity__c == undefined) polilist[x].pli.ERP7__Quantity__c = obj.ERP7__Minimum_Quantity__c;
                            }
                            if(polilist[x].pli.ERP7__Quantity__c != '' || polilist[x].pli.ERP7__Quantity__c != undefined) polilist[x].pli.ERP7__Total_Price__c = polilist[x].pli.ERP7__Quantity__c * obj.ERP7__Cost__c;
                            polilist[x].isSelected = false;
                        }
                    }
                    cmp.set('v.poliWrap.poli',polilist);
                    cmp.set('v.Vendorforqry',vendortoset);
                    var qry = ' ';
                    qry = 'And ERP7__Product__c = \'' + currProd + '\'';
                    qry += ' AND ERP7__Supplier__c =\'' + vendortoset + '\'';
                    cmp.set('v.ccqry',qry);
                    //var container = cmp.find("AppVenId");
                    
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(populatedetails);
        }
    },
    closeError : function(component, event, helper) {
        component.set('v.exceptionError','');
    },
    updateTotalPriceqty :function(cmp, event, helper) {
        var qty = event.getSource().get('v.value');
        var ind = event.getSource().get('v.title');
        var polilist = []; 
        polilist = cmp.get('v.poliWrap.poli');
        if(qty > 0){
            for(var x in polilist){
                if(x== ind){
                    //if(polilist[x].pli.ERP7__Unit_Price__c == null || polilist[x].pli.ERP7__Unit_Price__c == undefined) polilist[x].pli.ERP7__Unit_Price__c = "0";
                    polilist[x].pli.ERP7__Total_Price__c = parseFloat(qty) * parseFloat(polilist[x].pli.ERP7__Unit_Price__c);
                }
            }
            
        }
        else{
            for(var x in polilist){
                if(x== ind){
                    
                    polilist[x].pli.ERP7__Total_Price__c = 0;
                }
            }  
        }
        cmp.set('v.poliWrap.poli',polilist);
        
        //var val = parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"));
    },
    updateTotalPrice :function(cmp, event, helper) {
        var unitprice = event.getSource().get('v.value');
        var ind = event.getSource().get('v.title');
        var polilist = []; 
        polilist = cmp.get('v.poliWrap.poli');
        if(unitprice > 0){
            for(var x in polilist){
                if(x== ind){
                    if(polilist[x].pli.ERP7__Quantity__c == null || polilist[x].pli.ERP7__Quantity__c == undefined) polilist[x].pli.ERP7__Quantity__c = 0;
                    polilist[x].pli.ERP7__Total_Price__c = parseFloat(unitprice) * parseFloat(polilist[x].pli.ERP7__Quantity__c);
                }
            }
            
        }
        else{
            for(var x in polilist){
                if(x== ind){
                    
                    polilist[x].pli.ERP7__Total_Price__c = 0;
                }
            }  
        }
        cmp.set('v.poliWrap.poli',polilist);
        //var val = parseFloat(component.get("v.item.ERP7__Quantity__c")) * parseFloat(component.get("v.item.ERP7__Unit_Price__c"));
    },
    changeVendor : function(cmp, event, helper) {
        
        if(cmp.get('v.exceptionError') != '') cmp.set('v.exceptionError','');
        
        var ind = event.getSource().get('v.title');
        console.log('ind : '+ind);
        var poliList = [];
        poliList.unshift({sObjectType :'ERP7__Purchase_Line_Items__c'});
        if(!$A.util.isEmpty(ind)){
            var isopen = false;
            var prodlist = cmp.get('v.poliWrap.poli');
            var err = false;
            for(var x in prodlist){
                console.log('JSON.stringify(prodlist[x]) : '+JSON.stringify(prodlist[x]));
                if(JSON.stringify(prodlist[x]) === JSON.stringify(poliList[0])){
                    console.log('err');
                    cmp.set('v.exceptionError',$A.get('$Label.c.PH_Please_Select_Product_and_vendor_to_proceed'));
                    err =true;
                    break;
                }
                else if(x == ind && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)){
                    if(prodlist[x].isSelected){
                        prodlist[x].isSelected = false;
                        isopen = true;
                    } 
                    
                }
            }
            cmp.set('v.poliWrap.poli',prodlist);
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            if(!isopen && !err){
                cmp.set('v.showvendor',true);
                //cmp.set('v.poliWrap.appven','');
                for(var x in prodlist){
                    prodlist[x].isSelected = false;
                }
                helper.getupdateVen(cmp, event, helper,ind);
            }
            else{cmp.set('v.showvendor',false);}
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            
        }
        
    },
    nextclicked : function(cmp, event, helper) {
        
        var poliwrp = cmp.get('v.poliWrap');
        console.log('poliwrp : ',JSON.stringify(poliwrp));
        var obj = cmp.get('v.poliWrap.poli');
        console.log('obj : ',JSON.stringify(obj));
        console.log('objStock : ',obj.Stock);
        var Err = false;
        var poliList = [];
        poliList.unshift({"pli":{"ERP7__Product__c":""}});
        console.log('poliList : '+JSON.stringify(poliList[0]));
        if(obj.length > 0){
            for(var x in obj){
                console.log('obj[x] : '+JSON.stringify(obj[x]));
                
                if(JSON.stringify(obj[x]) === JSON.stringify(poliList[0])){
                    //cmp.set('v.exceptionError','Please select product to proceed');
                    //Err =true;
                    break;
                }
                if(obj[x].pli.Name == '' || obj[x].pli.Name == null){//obj[x].pli.ERP7__Product__c == null || obj[x].pli.ERP7__Product__c == '' ||
                    console.log('this is causing issue'+JSON.stringify(obj[x]));
                    cmp.set('v.exceptionError',$A.get('$Label.c.PH_Please_Select_Enter_Product_to_proceed'));
                    Err =true;
                    break;
                }
                else if(obj[x].pli.ERP7__Unit_Price__c < 0 || obj[x].pli.ERP7__Unit_Price__c == "" || obj[x].pli.ERP7__Unit_Price__c == null || obj[x].pli.ERP7__Unit_Price__c == undefined){
                    cmp.set('v.exceptionError',$A.get('$Label.c.PH_Please_Enter_Unit_Price')); 
                    Err =true;
                    break;
                }
                /* else if(obj[x].pli.ERP7__Product__c == null){
                    cmp.set('v.exceptionError','Please select product to proceed');
                    Err =true;
                   break;
                }*/
                
                else if((obj[x].pli.ERP7__Vendor__c == null || obj[x].pli.ERP7__Vendor__c == '')){
                    cmp.set('v.exceptionError',$A.get('$Label.c.PH_Please_Select_Vendor_to_proceed'));
                    Err =true;
                    break;
                }
                
                /* else if(obj[x].pli.ERP7__Vendor__c != null && (obj[x].pli.ERP7__Cost_Card__c == null || obj[x].pli.ERP7__Cost_Card__c == '')){
                        cmp.set('v.exceptionError','Please Select Cost card to proceed'); 
                        Err =true;
                        break;
                    }*/
                    else if((obj[x].pli.ERP7__Quantity__c <= 0 || obj[x].pli.ERP7__Quantity__c == undefined)){
                        cmp.set('v.exceptionError',$A.get('$Label.c.PH_Please_Enter_Quantity')); 
                        Err =true;
                        break;
                    } 
                
            }
            if(!Err){
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                console.log('Error : '+Err);
                $A.createComponent("c:ShowAllPOLIAndPO",{
                    "plolist":cmp.get('v.poliWrap'),
                    "editenableUnitPrice" : cmp.get('v.alloweditPrice'),
                    "fromAP" : cmp.get('v.fromAP'),
                    "DC" : cmp.get('v.dChannelId'),
                    "channel" :  cmp.get('v.channelId'),
                    "MOId" : cmp.get('v.MOId'),
                    "showAllocations" : cmp.get('v.showAllocations'),
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = cmp.find("body");
                        body.set("v.body", newCmp);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                
            }
        }
    },
    cancelclick : function(cmp, event, helper) {
        /*if(cmp.get('v.fromAP')) {
            console.log('From AP ');
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Accounts_Payable",
                componentAttributes: {
                    "aura:id": "AccountsPayable",
                    "selectedTab":"Purchase_Orders"
                }
            });
            evt.fire();
        }*/
        if(cmp.get('v.MOId')){
            console.log('From MO or showAll ');
            var MOId = cmp.get("v.MOId");
            $A.createComponent("c:Manufacturing_Orders",{
                "MO" :MOId,
                "NAV":'mp',
                "RD":'yes',
                "allowNav" : true
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = cmp.find("body");
                    body.set("v.body", newCmp);
                }
            });
            
        }
        else{
            var returl = '/lightning/page/home';
            window.open(returl,'_parent');
        }
        
    },
    lookupClickgetCC : function(cmp, event, helper) {
        var currindex = event.currentTarget.name;
        var qry = cmp.get('v.ccqry');
        cmp.set('v.ccqry',qry);
        
    },
    changeselectedVendor : function(cmp, event, helper) {
        console.log('Inside changeselectedVendor');
        var currindex = event.currentTarget.name;
        var prodlist = cmp.get('v.poliWrap.poli');
        var prodId = ''; var vendId = '';
        for(var x in prodlist){
            if(x == currindex ){//&& !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)
                prodId = prodlist[x].pli.ERP7__Product__c;
                vendId = prodlist[x].pli.ERP7__Vendor__c;
            }
        }
        
        if(!$A.util.isEmpty(prodId) && !$A.util.isEmpty(vendId)){
            var qry = ' ';
            qry = 'And ERP7__Product__c =\'' + prodId + '\'';
            qry += ' AND ERP7__Supplier__c =\'' + vendId + '\'';
            for(var x in prodlist){
                if(x == currindex && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)){
                    prodlist[x].pli.ERP7__Cost_Card__c = '';
                    prodlist[x].ccqry = qry;
                    prodlist[x].ccqry += ' And ERP7__Active__c = true And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
                }
            }
            cmp.set('v.poliWrap.poli',prodlist);
            // console.log('ccqry : ',cmp.get('v.ccqry'));
            /* var action = cmp.get('c.getvendorId');
            action.setParams({
                ProductId : prodId,
                vendorId : vendId
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    var result = response.getReturnValue();
                    console.log('result : ',response.getReturnValue());
                    cmp.set('v.Vendorforqry',result);
                    var qry = ' ';
                    qry = 'And ERP7__Product__c = \'' + prodId + '\'';
                    qry += ' AND ERP7__Supplier__c =\'' + cmp.get('v.Vendorforqry') + '\'';
                    cmp.set('v.ccqry',qry);
                    console.log('ccqry : ',cmp.get('v.ccqry'));
                }
                
            });
            $A.enqueueAction(action); */
        }
        else if($A.util.isEmpty(prodId) && !$A.util.isEmpty(vendId)){
            console.log('Inside empty prodId ');
            var qry = ' ';
            qry = 'And ERP7__Product__c = \'\'';
            qry += ' AND ERP7__Supplier__c =\'' + vendId + '\'';
            for(var x in prodlist){
                if(x == currindex && $A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)){
                    prodlist[x].pli.ERP7__Cost_Card__c = '';
                    prodlist[x].ccqry = qry;
                    prodlist[x].ccqry += ' And ERP7__Active__c = true And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
                    console.log('ccqry changed: ',prodlist[x].ccqry);
                }
            }
            cmp.set('v.poliWrap.poli',prodlist);
        }
        else if($A.util.isEmpty(prodId) && $A.util.isEmpty(vendId)){
            var qry = ' ';
            qry = 'And ERP7__Product__c = \'\'';
            qry += ' AND ERP7__Supplier__c =\'' + vendId + '\'';
            for(var x in prodlist){
                if(x == currindex && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c) && prodId == prodlist[x].pli.ERP7__Product__c){
                    prodlist[x].pli.ERP7__Cost_Card__c = '';
                    prodlist[x].ccqry = qry;
                    prodlist[x].ccqry += ' And ERP7__Active__c = true And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
                    qry = prodlist[x].ccqry;
                    //prodlist[x].pli.ERP7__Unit_Price__c = 0;
                    //prodlist[x].pli.ERP7__Quantity__c = 0;
                    //prodlist[x].pli.ERP7__Total_Price__c = 0;
                    if(prodlist[x].purchaseAppVendor) helper.fetApproveVendor(cmp, event, helper, prodId, currindex);
                    
                }
            }
            console.log('qry if no vendid ',qry);
            cmp.set('v.poliWrap.poli',prodlist);
            console.log('v.poliWrap.poli ',cmp.get('v.poliWrap.poli'));
        }
        else if(!$A.util.isEmpty(prodId) && $A.util.isEmpty(vendId)){
            for(var x in prodlist){
                if(x == currindex && !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c) && prodId == prodlist[x].pli.ERP7__Product__c){
                    prodlist[x].pli.ERP7__Cost_Card__c = '';
                }
            }
             cmp.set('v.poliWrap.poli',prodlist);
        }
        
    },
    lookupClickCostCard : function(cmp, event, helper) {
        console.log('on mouse hover lookupClickCostCard');
        var currindex = event.currentTarget.name;
        var prodlist = cmp.get('v.poliWrap.poli');
        var prodId = ''; var vendId = ''; var qry = '';
        for(var x in prodlist){
            if(x == currindex ){//&& !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)
                prodId = prodlist[x].pli.ERP7__Product__c;
                vendId = prodlist[x].pli.ERP7__Vendor__c;
            }
        }
        if($A.util.isEmpty(prodId) && $A.util.isEmpty(vendId)){
          qry = 'And ERP7__Product__c = \'\'';
            //qry += ' AND ERP7__Supplier__c =\'\'';
            for(var x in prodlist){
            if(x == currindex ){//&& !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)
                prodlist[x].ccqry = qry;
                prodlist[x].ccqry += ' And ERP7__Active__c = true And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
            }
        }
        }
        else if(!$A.util.isEmpty(prodId) && $A.util.isEmpty(vendId)){
          qry = 'And ERP7__Product__c =\'' + prodId + '\'';  
            //qry += ' AND ERP7__Supplier__c =\'\'';
            for(var x in prodlist){
            if(x == currindex ){//&& !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)
                prodlist[x].ccqry = qry;
                prodlist[x].ccqry += ' And ERP7__Active__c = true And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
            }
        }
        }
        else if(!$A.util.isEmpty(prodId) && !$A.util.isEmpty(vendId)){
             qry = 'And ERP7__Product__c =\'' + prodId + '\'';  
            qry += ' AND ERP7__Supplier__c =\'' + vendId + '\'';
            for(var x in prodlist){
            if(x == currindex ){//&& !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)
                prodlist[x].ccqry = qry;
                prodlist[x].ccqry += ' And ERP7__Active__c = true And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
            }
        }
        }
       console.log('qry',qry);
    },
    getCC : function(cmp, event, helper) {
        var currindex = event.currentTarget.name;
        var prodlist = cmp.get('v.poliWrap.poli');
        var prodId = ''; var CCId = '';
        console.log('inside getCC');
        for(var x in prodlist){
            if(x == currindex){//&& !$A.util.isEmpty(prodlist[x].pli.ERP7__Product__c)
                CCId = prodlist[x].pli.ERP7__Cost_Card__c;
                prodId = prodlist[x].pli.ERP7__Product__c;
                if(prodId != '') prodlist[x].ccqry = 'And ERP7__Product__c = \'' + prodId + '\'';
                if(prodId == '' || prodId == null || prodId == undefined) prodlist[x].ccqry = 'And ERP7__Product__c = \'\'';
                if(!$A.util.isEmpty(prodlist[x].pli.ERP7__Vendor__c)) prodlist[x].ccqry += ' AND ERP7__Supplier__c =\'' + prodlist[x].pli.ERP7__Vendor__c + '\'';
                prodlist[x].ccqry += ' And ERP7__Active__c = true And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
            }
        }
        cmp.set('v.poliWrap.poli',prodlist);
        if(!$A.util.isEmpty(CCId)){//!$A.util.isEmpty(prodId) && 
            var action = cmp.get('c.fetchPrice');
            action.setParams({
                ccId : CCId
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    var result = response.getReturnValue();
                    console.log('result',result);
                    if(result != null){
                        for(var x in prodlist){
                            if(x == currindex && prodlist[x].pli.ERP7__Cost_Card__c == CCId){//prodlist[x].pli.ERP7__Product__c == prodId &&
                                prodlist[x].pli.ERP7__Unit_Price__c = (result.ERP7__Cost__c != null && result.ERP7__Cost__c != '' && result.ERP7__Cost__c > 0) ? result.ERP7__Cost__c : "0";
                                if(prodId != '') prodlist[x].pli.ERP7__Vendor_product_Name__c = (result.ERP7__Vendor_Part_Number__c == null || result.ERP7__Vendor_Part_Number__c == '') ? result.ERP7__Product__r.ERP7__Vendor_product_Name__c : result.ERP7__Vendor_Part_Number__c;
                                if(prodId != '') prodlist[x].ERP7__Vendor_product_Name__c = result.ERP7__Product__r.ERP7__Vendor_product_Name__c; 
                                if(prodId == '' || prodId == null || prodId == undefined) prodlist[x].pli.ERP7__Vendor_product_Name__c = (result.ERP7__Vendor_Part_Number__c == null || result.ERP7__Vendor_Part_Number__c == '') ? '' : result.ERP7__Vendor_Part_Number__c;
                                //prodlist[x].pli.ERP7__Quantity__c = result.ERP7__Minimum_Quantity__c;
                                prodlist[x].pli.ERP7__Quantity__c =(prodlist[x].pli.ERP7__Quantity__c == 0|| prodlist[x].pli.ERP7__Quantity__c == null || prodlist[x].pli.ERP7__Quantity__c == undefined || prodlist[x].pli.ERP7__Quantity__c == '') ? result.ERP7__Quantity__c : prodlist[x].pli.ERP7__Quantity__c;
                                console.log('updated prodlist[x].pli.ERP7__Quantity__c',prodlist[x].pli.ERP7__Quantity__c);
                                prodlist[x].pli.ERP7__Total_Price__c = result.ERP7__Cost__c *  prodlist[x].pli.ERP7__Quantity__c;
                                
                            }
                        } 
                        cmp.set('v.poliWrap.poli',prodlist);
                    }
                    
                    
                }
                else{
                    console.log('Error : '+JSON.stringify(response.getError()));
                }
                
            });
            $A.enqueueAction(action);
        }
        else if(!$A.util.isEmpty(prodId) && $A.util.isEmpty(CCId)){
            for(var x in prodlist){
                if(x == currindex && prodlist[x].pli.ERP7__Product__c == prodId){
                    prodlist[x].pli.ERP7__Vendor_product_Name__c = prodlist[x].ERP7__Vendor_product_Name__c ;  
                }
            }
            cmp.set('v.poliWrap.poli',prodlist);
            console.log('prodlist', prodlist);
        }
                
    },
    DCchange : function(component,event,helper) {
        let dc = component.get('v.dChannelId');
        console.log('dc : ',dc);
        if(dc != null && dc != undefined && dc !=''){
            var action = component.get('c.getnewDc');
            action.setParams({DCId : dc});
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    var obj = response.getReturnValue();
                    if(obj != null && component.get('v.poliWrap') != null && component.get('v.poliWrap') != undefined){
                        component.set('v.poliWrap.distributionChannel',response.getReturnValue());
                        component.set('v.poliWrap.channel',response.getReturnValue().ERP7__Channel__c);  
                    }
                   
                }
            });
             $A.enqueueAction(action);
        }
        
        
    },
    createcostcard : function(component,event,helper) {
        component.set('v.CCError','');
        component.set('v.disableVendor',false);
        console.log('disableVendor bfr: ',component.get('v.disableVendor'));
        var prodId= event.currentTarget.getAttribute('data-index');
        console.log('prodId : ',prodId);
        var recId= event.currentTarget.getAttribute('data-recId');
        console.log('recId : ',recId);
        component.set('v.AddPOInd',recId);
        var venId= event.currentTarget.getAttribute('data-venId');
        console.log('venId : ',venId);
        var proName= event.currentTarget.getAttribute('data-proName');
        console.log('proName : ',proName); 
        var showven= event.currentTarget.getAttribute('data-showven');
        console.log('showven : ',showven); 
        component.set('v.disableVendor',showven);
        console.log('disableVendor : ',component.get('v.disableVendor'));
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
       
        today = mm + '/' + dd + '/' + yyyy;
        var after5yrs = new Date();
        var dd1 = String(after5yrs.getDate()).padStart(2, '0');
        var mm1 = String(after5yrs.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy5 = after5yrs.getFullYear() +  2;
        after5yrs = mm1 + '/' + dd1 + '/' + yyyy5; 
        component.set('v.newCC.ERP7__Product__c',prodId);
        component.set('v.newCC.ERP7__Minimum_Quantity__c',0.0);
        if(showven === true) component.set('v.newCC.ERP7__Supplier__c',venId);//changed on 2/1 by Asra
        component.set('v.newCC.ERP7__Start_Date__c',today);
        component.set('v.newCC.ERP7__End_Date__c',after5yrs);
        component.set('v.newCC.ERP7__Cost__c',0.0);
        component.set('v.newCC.ERP7__Active__c',true);
        component.set('v.newCC.ERP7__Quantity__c',1);
        if(proName != null && proName != '' && proName != undefined) component.set('v.newCC.Name',proName);
        $A.util.addClass(component.find("myModalCard"),"slds-fade-in-open");
        $A.util.addClass(component.find("myModalCardBackdrop"),"slds-backdrop_open");
        
    },
        closeCCModal : function(cmp,event,helper){
            $A.util.removeClass(cmp.find("myModalCard"),"slds-fade-in-open");
            $A.util.removeClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
            cmp.set('v.CCError','');
            cmp.set('v.newCC.ERP7__Product__c','');
            cmp.set('v.newCC.ERP7__Supplier__c','');
            cmp.set('v.newCC.ERP7__Cost__c',0.0);
            cmp.set('v.newCC.ERP7__Minimum_Quantity__c',0.0);
            cmp.set('v.newCC.Name','');
            cmp.set('v.newCC.ERP7__Start_Date__c','');
            cmp.set('v.newCC.ERP7__End_Date__c','');
             cmp.set('v.disableVendor',false);
            
    },
    CreateCC1 : function(cmp,event,helper){
        cmp.set('v.CCError','');
        console.log('1');
        var index=cmp.get('v.AddPOInd');
        console.log('index',index);
        if(cmp.get('v.newCC.Name') == '' || cmp.get('v.newCC.Name') == null || cmp.get('v.newCC.Name') == undefined){
            console.log('2');
            cmp.set('v.CCError',$A.get('$Label.c.PH_Please_add_the_Name_for_Cost_card'));
            return;
        }
        /*else if(cmp.get('v.newCC.ERP7__Product__c') == '' || cmp.get('v.newCC.ERP7__Product__c') == null || cmp.get('v.newCC.ERP7__Product__c') == undefined){
            console.log('3');
            cmp.set('v.CCError',$A.get('$Label.c.PH_Please_assign_the_Product'));
            return;
        }*/
        else if(cmp.get('v.newCC.ERP7__Supplier__c') == '' || cmp.get('v.newCC.ERP7__Supplier__c') == null || cmp.get('v.newCC.ERP7__Supplier__c') == undefined){
            console.log('4');
            cmp.set('v.CCError',$A.get('$Label.c.PH_Please_assign_the_Supplier'));
            return;
        }
         else if(cmp.get('v.newCC.ERP7__End_Date__c') == '' || cmp.get('v.newCC.ERP7__End_Date__c') == null || cmp.get('v.newCC.ERP7__End_Date__c') == undefined){
            console.log('5');
             cmp.set('v.CCError',$A.get('$Label.c.PH_Please_add_the_Expiry_for_Cost_card'));
            return;
        }
        else if(cmp.get('v.newCC.ERP7__Cost__c') == '' || cmp.get('v.newCC.ERP7__Cost__c') == null || cmp.get('v.newCC.ERP7__Cost__c') == undefined || cmp.get('v.newCC.ERP7__Cost__c') <= 0){
            console.log('7');
            cmp.set('v.CCError',$A.get('$Label.c.PH_Please_provide_a_valid_Cost_The_cost_cannot_be_less_than_or_equal_to_zero'));
            return;
        }
        /*else if(cmp.get('v.newCC.ERP7__Quantity__c') == '' || cmp.get('v.newCC.ERP7__Quantity__c') == null || cmp.get('v.newCC.ERP7__Quantity__c') == undefined || cmp.get('v.newCC.ERP7__Quantity__c') <= 0){
            console.log('7');
            cmp.set('v.CCError',$A.get('$Label.c.Invalid_Quantity'));
            return;
        }*/
        else{
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//add wait
            console.log('8');
           var action = cmp.get('c.createCCnew');
            console.log('9');
            action.setParams({CC : cmp.get('v.newCC')});
            console.log('10');
            action.setCallback(this, function(response){
                console.log('response.getState() : ',response.getState());
            if(response.getState() ==="SUCCESS"){
                cmp.set("v.exceptionError", response.getReturnValue().Error);
                if(response.getReturnValue().exError != '') return;
                var res=response.getReturnValue().CC;
                console.log('response.getReturnValue() : ',response.getReturnValue());
                let poli = cmp.get('v.poliWrap.poli');
                for(var x in poli){
                    //if(poli[x].pli.ERP7__Product__c == res.ERP7__Product__c){
                     if(x==index){
                        console.log('value match');
                        poli[x].pli.ERP7__Cost_Card__c = res.Id;
                        poli[x].pli.ERP7__Vendor__c = res.ERP7__Supplier__c;
                         poli[x].pli.ERP7__Unit_Price__c = (res.ERP7__Cost__c > 0) ? res.ERP7__Cost__c: "0";
                        poli[x].pli.ERP7__Quantity__c = res.ERP7__Minimum_Quantity__c;
                        poli[x].pli.ERP7__Total_Price__c = poli[x].pli.ERP7__Quantity__c * poli[x].pli.ERP7__Unit_Price__c ;
                    }
                }
                cmp.set('v.poliWrap.poli',poli);
                cmp.set('v.disableVendor',false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get('$Label.c.Success'),
                    "type":"success",
                    "message": $A.get('$Label.c.PH_Cost_Card_Created_successfully')
                });
                toastEvent.fire();
                $A.util.removeClass(cmp.find("myModalCard"),"slds-fade-in-open");
                $A.util.removeClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
                cmp.set('v.CCError','');
                cmp.set('v.newCC.ERP7__Product__c','');
                cmp.set('v.newCC.ERP7__Supplier__c','');
                cmp.set('v.newCC.ERP7__Cost__c',0.0);
                cmp.set('v.newCC.ERP7__Minimum_Quantity__c',0.0);
                cmp.set('v.newCC.ERP7__Quantity__c',0.0);
                cmp.set('v.newCC.Name','');
                cmp.set('v.newCC.ERP7__Start_Date__c','');
                cmp.set('v.newCC.ERP7__End_Date__c','');
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");//remove wait
            }
            });
            $A.enqueueAction(action);
        }
    },
    closeerror : function(cmp,event,helper){
        cmp.set('v.CCError','');
    },
    add: function(component, event, helper) {
        console.log('add called');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var vendid='';
        component.set('v.listOfProducts',[]);
        component.set('v.selectedListOfProducts',[]);
        component.set('v.searchItem','');
        component.set('v.seachItemFmily','');
        component.set('v.addProductsMsg','');
        helper.getDependentPicklistsFamily(component, event, helper);
        var action = component.get("c.getProducts");
        action.setParams({
            "venId":vendid,
            "searchString": component.get('v.searchItem'),
            "searchFamily": component.get('v.seachItemFmily'),
            "DCId": component.get('v.dChannelId')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('response getProducts : ',response.getReturnValue());
                console.log('setting listOfProducts here1');
                component.set('v.listOfProducts',response.getReturnValue().wrapList);
                
                //Added by Arshad 03 Aug 2023
                try{
                    var standProds = component.get('v.listOfProducts');
                    
                    // for(var x in standProds)  Commented by Parveez on 27 Sept 2023
                    for(var x = 0; x < standProds.length; x++){
                        standProds[x].ERP7__Lead_Time_Days__c = standProds[x].prod.ERP7__Purchase_Lead_Time_days__c;
                        if(standProds[x].selCostCardId != undefined && standProds[x].selCostCardId != null && standProds[x].selCostCardId != ''){
                            console.log('in here1 standProds[x].selCostCardId~>'+standProds[x].selCostCardId);
                            var res = standProds[x].selectedCostCard;
                            console.log('standProds[x].selectedCostCard res~>',res);
                            
                            standProds[x].unitPrice  = parseFloat(res.ERP7__Cost__c);
                            standProds[x].VendorPartNumber = res.ERP7__Vendor_Part_Number__c;
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
                }catch(e){
                    console.log('err~>',e);
                }
                var msg = response.getReturnValue().Msg;
                console.log('Msg----?',msg);
                 if(msg != null || msg != '' || msg != undefined) component.set('v.addProductsMsg',response.getReturnValue().Msg);
                console.log('Msg----?',component.get('v.addProductsMsg'));
                component.set('v.globalProdSearch',response.getReturnValue().globalSearch);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }else{
                console.log('Error addNew:',response.getError());
                component.set("v.exceptionError",response.getError());
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            component.set("v.showAddProducts",true);
            component.set("v.showStandardProducts",true);
        });
        $A.enqueueAction(action);
        
        /* var poliList = [];
        if(component.get("v.poli") != null) poliList = component.get("v.poli");
        poliList.unshift({sObjectType :'ERP7__Purchase_Line_Items__c',ItemsinStock : 0.0, demand: 0.0,AwaitingStock :0.0, Accounts : [], Category:'', AccAccount:''});
        component.set("v.poli",poliList);
        console.log('pli : '+JSON.stringify(component.get("v.poli")));*/
    },
    backToMainPage : function(component, event, helper) {
        component.set("v.showAddProducts",false);
    },
     closeaddProductsMsg : function(component, event, helper) {
        component.set('v.addProductsMsg','');
    },
        fetchProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.searchItem'));
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        helper.getSearchProducts(component);
    },
     fetchFamilyProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.seachItemFmily'));
        if(component.get('v.seachItemFmily') == '--None--') component.set('v.seachItemFmily','');
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        //helper.getSearchProducts(component);
        helper.familyFieldChange(component, event, helper);
    },
     fetchSubFamilyProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.subItemFmily'));
        if(component.get('v.subItemFmily') == '--None--') component.set('v.subItemFmily','');
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        helper.getSearchProducts(component);
    },
            handleCheckbox: function(component, event, helper) {
        let checkedval = event.getSource().get("v.checked");
        let index = event.getSource().get("v.name");
        var selectedProds = component.get('v.selectedListOfProducts');
        console.log('selectedProds bfr : ',selectedProds);
        if (checkedval && index != null && index != undefined && index != '') {
            console.log('in 1');
            let standProds = component.get('v.listOfProducts');
            for (let i = 0; i < standProds.length; i++) {
                if (i == index || standProds[i].prod.Id == index) {
                    selectedProds.push(standProds[i]);
                }
            }
            component.set('v.selectedListOfProducts', selectedProds);
        } else if (checkedval == false && index != null && index != undefined && index != '') {
            if(selectedProds != undefined && selectedProds != null && selectedProds != []){
                for (let i = selectedProds.length - 1; i >= 0; i--) {
                    if (selectedProds[i].prod.Id == index) {
                        selectedProds.splice(i, 1);
                    }
                }
                component.set('v.selectedListOfProducts', selectedProds); 
            }
        }
        console.log('selectedProds : ',selectedProds);
    },
        
    handleQuantity : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            ///for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].quantity = parseFloat(value);
                    if(standProds[x].unitPrice == null || standProds[x].unitPrice == '' || standProds[x].unitPrice == undefined) standProds[x].unitPrice = parseFloat(0);
                    if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(0);
                    let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                    console.log('tax  bfr:  ',tax);
                    tax = tax * standProds[x].quantity;
                    standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                    standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                    console.log('TotalPrice : ',standProds[x].TotalPrice);
                }
            }
            console.log('setting listOfProducts here2');
            component.set('v.listOfProducts',standProds);
        }
    },
    
    handleUnitPrice : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].unitPrice  = parseFloat(value);
                    if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
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
            }
            console.log('setting listOfProducts here3');
            component.set('v.listOfProducts',standProds);
        }
    },
    
    handletaxPercent : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].taxPercent = parseFloat(value);
                    if(standProds[x].unitPrice == null || standProds[x].unitPrice == '' || standProds[x].unitPrice == undefined) standProds[x].unitPrice = parseFloat(0);
                    if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                    let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                    console.log('tax  bfr:  ',tax);
                    tax = tax * standProds[x].quantity;
                    standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                    standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                    console.log('TotalPrice : ',standProds[x].TotalPrice);
                }
            }
            console.log('setting listOfProducts here4');
            component.set('v.listOfProducts',standProds);
        }
    },
         closeError : function (component, event) {
        component.set("v.exceptionError",'');
        component.set("v.successMsg",'');
    },
    handleCostCardChange: function(component, event, helper) {
        try{
            console.log('handleCostCardChange called');
            
            var index = event.currentTarget.getAttribute("data-index");
            console.log("handleCostCardChange index-: " + index);
            
            if(index != undefined && index != null){
                var standProds = component.get('v.listOfProducts');
                
                var value = (standProds[index].selCostCardId != undefined && standProds[index].selCostCardId != null && standProds[index].selCostCardId != '') ? standProds[index].selCostCardId : '';
                console.log('handleCostCardChange value~>' + value);
                
                if(value != ''){
                    console.log('getPrice calling value~>'+value);
                    var action = component.get("c.fetchPrice2");
                    action.setParams({
                        "ccId": value
                    });
                    action.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            if(response.getReturnValue() != null){
                                var res = response.getReturnValue().costcard;
                                console.log('res~>',res);
                                if (res != null) {
                                    
                                    //for(var x in standProds){
                                    for(var x = 0; x < standProds.length; x++){
                                        if(x == index){
                                            console.log('in here1 res.ERP7__Cost__c~>'+res.ERP7__Cost__c);
                                            standProds[x].selectedCostCard = res;
                                            if(res.ERP7__Vendor_Part_Number__c != null && res.ERP7__Vendor_Part_Number__c != '' && res.ERP7__Vendor_Part_Number__c != undefined) standProds[x].VendorPartNumber = res.ERP7__Vendor_Part_Number__c;
                                            else standProds[x].VendorPartNumber = res.ERP7__Product__r.ERP7__Vendor_product_Name__c;
                                            standProds[x].unitPrice  = parseFloat(res.ERP7__Cost__c);
                                            
                                            if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                                            
                                            //if(standProds[x].ERP7__Vendor__c == null || standProds[x].ERP7__Vendor__c == '' || standProds[x].ERP7__Vendor__c == undefined) standProds[x].ERP7__Vendor__c = parseFloat(0);
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
                                    }
                                    console.log('setting listOfProducts here3');
                                    component.set('v.listOfProducts',standProds);
                                }
                            } else{
                                console.log('getPrice response  null');
                            }
                            
                        }else{
                            console.log('getPrice Exception Occured~>',JSON.stringify(response.getError()));  
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
        }catch(e){
            console.log('err~>',e);
        }
    },
    addProducts : function(component, event, helper) {
        console.log('addProducts callled');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        try{
            component.set('v.successMsg','');
            let customProds = component.get('v.ClistOfProducts');
            let standProds = component.get('v.selectedListOfProducts');
            let productsToAdd = [];
            console.log('Tesetth ');
            var totalAmount = 0.0;
            var tax = 0.0;
            var subtotal = 0.0;
            var totalTax = 0.0;
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                let poliadd = {};
                //  if(standProds[x].checkSelected){
                poliadd.AwaitingStock = standProds[x].AwaitStock;
                poliadd.demand = standProds[x].demand; 
                poliadd.ItemsinStock = standProds[x].stock;
                poliadd.ERP7__Product__c = standProds[x].prod.Id;
                poliadd.Name = standProds[x].prod.Name;
                poliadd.ERP7__Cost_Card__c = (standProds[x].selCostCardId != undefined && standProds[x].selCostCardId != null && standProds[x].selCostCardId != '') ? standProds[x].selCostCardId : ''; //added by arshad
                console.log('poliadd.ERP7__Cost_Card__c~>'+poliadd.ERP7__Cost_Card__c);
                poliadd.ERP7__Quantity__c = standProds[x].quantity;
                poliadd.ERP7__Vendor_product_Name__c = (standProds[x].VendorPartNumber == null || standProds[x].VendorPartNumber == '' ||  standProds[x].VendorPartNumber == undefined) ? standProds[x].prod.ERP7__Vendor_product_Name__c : standProds[x].VendorPartNumber;
                poliadd.ERP7__Unit_Price__c = (standProds[x].unitPrice > 0) ?standProds[x].unitPrice : "0";
                poliadd.ERP7__Tax_Rate__c = standProds[x].taxPercent;
                poliadd.ERP7__Tax__c = standProds[x].taxAmount;
                poliadd.ERP7__Total_Price__c = standProds[x].TotalPrice;
                poliadd.ERP7__Vendor__c =  standProds[x].ERP7__Vendor__c ;  //(standProds[x].ERP7__Vendor__c != undefined && standProds[x].ERP7__Vendor__c != null && standProds[x].ERP7__Vendor__c != '') ?
                poliadd.ERP7__Lead_Time_Days__c = standProds[x].ERP7__Lead_Time_Days__c ; 
                poliadd.purchaseAppVendor = standProds[x].prod.ERP7__Purchase_From_Approved_Vendor__c;
                poliadd.customProduct = false;
                //poliadd.TotalAAPercentage=0;
                //poliadd.isAccCategoryChanged = false;
                poliadd.ERP7__Description__c = standProds[x].prod.Description;
                //poliadd.ERP7__Lead_Time_Days__c = standProds[x].prod.ERP7__Purchase_Lead_Time_days__c;
                subtotal = subtotal + (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice));
                totalAmount = totalAmount + (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                tax = (poliadd.ERP7__Unit_Price__c/100)*poliadd.ERP7__Tax_Rate__c;
                tax = (tax) * poliadd.ERP7__Quantity__c;
                totalTax = totalTax + tax;
                console.log('poliadd : ',poliadd);
                productsToAdd.push(poliadd); 
            }
            
            console.log('Tedwewrsetth ');
            var NameLabel = $A.get('$Label.c.Enter_Name');
            //for(var y in customProds){
            for(var y = 0; y < customProds.length; y++){
                let poliadd = {};
                if(customProds[y].Name != null && customProds[y].Name != undefined && customProds[y].Name != '' && customProds[y].Name != NameLabel){
                    poliadd.Name = customProds[y].Name;
                    poliadd.ERP7__Quantity__c = customProds[y].quantity;
                    poliadd.ERP7__Unit_Price__c = (customProds[y].unitPrice > 0) ? customProds[y].unitPrice : "0";
                    poliadd.ERP7__Tax_Rate__c = customProds[y].taxPercent;
                    poliadd.ERP7__Tax__c = customProds[y].taxAmount;
                    poliadd.ERP7__Total_Price__c = customProds[y].TotalPrice;
                    poliadd.ERP7__Description__c = customProds[y].Description;
                    poliadd.CustomProd = customProds[y].CustomProd;
                    subtotal = subtotal + (parseFloat(customProds[y].quantity) * parseFloat(customProds[y].unitPrice));
                    totalAmount = totalAmount + (parseFloat(customProds[y].quantity) * parseFloat(customProds[y].unitPrice)) + parseFloat(customProds[y].taxAmount);
                    tax = (poliadd.ERP7__Unit_Price__c/100)*poliadd.ERP7__Tax_Rate__c;
                    tax = (tax) * poliadd.ERP7__Quantity__c;
                    totalTax = totalTax + tax;
                    productsToAdd.push(poliadd);
                }
            }
            
            console.log('productsToAdd : ',productsToAdd.length);
            if(productsToAdd.length > 0){
                let poliList = []; 
                for(var x in productsToAdd){
                if(component.get("v.poliWrap.poli") != null) poliList = component.get("v.poliWrap.poli");
                    poliList.unshift({pli: {sObjectType :'ERP7__Purchase_Line_Items__c', ERP7__Product__c :  productsToAdd[x].ERP7__Product__c ,ERP7__Vendor__c:productsToAdd[x].ERP7__Vendor__c ,ERP7__Cost_Card__c:productsToAdd[x].ERP7__Cost_Card__c, Name : productsToAdd[x].Name,ERP7__Quantity__c:productsToAdd[x].ERP7__Quantity__c,ERP7__Unit_Price__c: productsToAdd[x].ERP7__Unit_Price__c,ERP7__Tax_Rate__c:productsToAdd[x].ERP7__Tax_Rate__c , ERP7__Tax__c:productsToAdd[x].ERP7__Tax__c, ERP7__Total_Price__c:productsToAdd[x].ERP7__Total_Price__c,ERP7__Vendor_product_Name__c:productsToAdd[x].ERP7__Vendor_product_Name__c,ERP7__Description__c:productsToAdd[x].ERP7__Description__c,ERP7__Lead_Time_Days__c:productsToAdd[x].ERP7__Lead_Time_Days__c},AwaitingStocks:productsToAdd[x].AwaitingStock,Demand:productsToAdd[x].demand,Stock:productsToAdd[x].ItemsinStock, purchaseAppVendor:productsToAdd[x].purchaseAppVendor, customProduct:productsToAdd[x].customProduct });
                
                /*var POind = component.get('v.AddPOInd');
                let poliwrp = component.get('v.AllPOs.POlist');
                let polilst = poliwrp[POind].POLIs;
                //let polilst = component.get('v.poli');
                console.log('polilst bfr: ',polilst.length);
                //if(component.get('v.poli') != null && component.get('v.poli') != undefined) polilst = component.get('v.poli');
                polilst = polilst.concat(productsToAdd);
                console.log('polilst after: ',polilst.length);
                poliwrp[POind].POLIs = polilst ;
                console.log('polilst after: ',poliwrp);
                component.set('v.AllPOs.POlist',poliwrp);
                console.log('polilst after: ',polilst);
                console.log('AllPOs.POlist after: ',component.get('v.AllPOs.POlist'));
                component.set('v.showAddProducts',false);*/
                
                component.set('v.successMsg','Products addedd successfully!');
                window.setTimeout( $A.getCallback(function() {  component.set('v.successMsg',''); }),5000);
                }
                component.set('v.showAddProducts',false);
                component.set('v.poliWrap.poli',poliList);
                component.set('v.afterdelIndex', poliList.length);
                console.log('poliList after: ',poliList);
                console.log('poliWrap.poli after: ',component.get('v.poliWrap.poli'));
            }
            else{
                component.set('v.addProductsMsg','Please select products to add!');
                window.setTimeout( $A.getCallback(function() {  component.set('v.addProductsMsg',''); }), 5000 );
            }
        }
        catch(err){
            console.log('error : ',err);
        }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
})