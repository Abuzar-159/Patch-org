({
    getupdateVen : function(component,event,helper,index,POindex) {
        console.log('helper clled');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        //component.set('v.CurrpoliIndex',index);
        var poliwrp = component.get('v.AllPOs.POlist');
        var currProdId = '';
        var currVendorId = '';
        for(var x in poliwrp){
            if(x == POindex){
                currVendorId = poliwrp[x].PO.ERP7__Vendor__c;
                for(var i in poliwrp[x].POLIs){
                    if(i == index){
                        poliwrp[x].POLIs[i].ERP7__Active__c = true;
                        currProdId = poliwrp[x].POLIs[i].ERP7__Product__c;
                    }
                    
                }
            }
        }
        if(!$A.util.isEmpty(currProdId) && !$A.util.isEmpty(currVendorId)){
            var getProductVendors = component.get('c.getApprovedvendor');
            getProductVendors.setParams({
                ProductId : currProdId,
                vendorId : currVendorId
            });
            getProductVendors.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    var obj = response.getReturnValue();
                    if(obj.appven.length > 0){
                        component.set('v.poliWrap.appven',obj.appven);
                        component.set('v.AllPOs.POlist',poliwrp);
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        
                    }
                    else if(obj.appven.length == 0){
                        component.set('v.poliWrap.appven',{});
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        
                        component.set('v.exceptionError',$A.get('$Label.c.PH_No_Approved_vendors_available'));
                    }
                }
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            });
            $A.enqueueAction(getProductVendors);
        }
        else if($A.util.isEmpty(currProdId)){
            console.log('Custom prod');
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
    }
    
    },
    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            //component.set("v.showMainSpin",false);
            toastEvent.fire();
        }
    },
    getPOdetails: function(cmp, evt, helper) {
        var poids = cmp.get('v.poliIds');
        console.log('poids : '+poids);
        if(poids.length > 0){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var getPO = cmp.get('c.getAllExistPO');
            getPO.setParams({
                polist : JSON.stringify(poids),
            });
            getPO.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var obj  = response.getReturnValue();
                    console.log('obj : ',response.getReturnValue());
                    cmp.set('v.AllPOs',obj);
                    var polist= cmp.get("v.AllPOs.POlist");
                    for(var i in polist){
                        polist[i].PO.FileList=[];
                        polist[i].PO.fillList=[];
                        polist[i].PO.Llist=[];
                        polist[i].PO.fileName=[];
                        polist[i].PO.taxrate=0;
                        polist[i].PO.SubTotal=0;
                        polist[i].PO.TotalTax=0;
                        polist[i].PO.TotalAmount=0;
                        console.log('polist[i].PO',polist[i].PO.Id);
                        var pol=polist[i].PO.Id;
                        cmp.set("v.recordId", pol);
                        var getDem = cmp.get('c.getAllExistDem');
                        getDem.setParams({
                            pol : pol
                        });
                        getDem.setCallback(this,function(response){
                            var state = response.getState();
                            if(state === 'SUCCESS'){
                                console.log('response.getReturnValue()', response.getReturnValue());
                                console.log('dimensions', response.getReturnValue().dimensions);
                                console.log('attachments', response.getReturnValue().attachments);
                                if(response.getReturnValue().attachments) cmp.set("v.uploadedFile", response.getReturnValue().attachments);
                                cmp.set("v.dimensionList", response.getReturnValue().dimensions);
                                var dimensionList = cmp.get("v.dimensionList");
                                for(var j in polist[i].POLIs){
                                    polist[i].POLIs[j].Accounts=[];
                                    polist[i].POLIs[j].TotalAAPercentage=0;
                                    polist[i].POLIs[j].custom = false;
                                    if(polist[i].POLIs[j].ERP7__Unit_Price__c == 0)polist[i].POLIs[j].ERP7__Unit_Price__c ="0";
                                    polist[i].POLIs[j].ERP7__Active__c = false;
                                    var allocationPercentageTotal = 0;
                                    var acc=polist[i].POLIs[j].Accounts;
                                    for(var k in dimensionList){
                                        if(dimensionList[k].ERP7__Purchase_Line_Items__c == polist[i].POLIs[j].Id){
                                            console.log('inside?');
                                            console.log('polist[i].POLIs[j].Id?',polist[i].POLIs[j].Id);
                                            console.log('dimensionList[k].ERP7__Purchase_Line_Items__c',dimensionList[k].ERP7__Purchase_Line_Items__c);
                                            acc.push(dimensionList[k]); 
                                            allocationPercentageTotal += dimensionList[k].ERP7__Allocation_Percentage__c;
                                            console.log(' dimensionList[k].ERP7__Allocation_Percentage__c?',dimensionList[k].ERP7__Allocation_Percentage__c);
                                            cmp.set("v.displayAccount",true);
                                            console.log('Set?',cmp.get("v.displayAccount"));
                                            console.log('Set TotalAAPercentage?',allocationPercentageTotal);
                                            
                                            delete dimensionList[k]; 
                                        }
                                    }
                                    polist[i].POLIs[j].TotalAAPercentage=allocationPercentageTotal;
                                    console.log('Set tper?',polist[i].POLIs[j].TotalAAPercentage);
                                    cmp.set("v.AllPOs.POlist",polist);
                                    //helper.fetchOrgCurrncy(cmp,event,helper);
                                }
                                console.log('dimensionList',dimensionList);
                            } 
                            cmp.set("v.dimensionList",dimensionList);
                            cmp.set("v.AllPOs.POlist",polist);
                            console.log('AllPOs.POlist',cmp.get("v.AllPOs.POlist"));
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        });
                        $A.enqueueAction(getDem);
                    }
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    helper.updateAmounts(cmp);
                    helper.changeAddressEdit(cmp);
                }
            });
            $A.enqueueAction(getPO);
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        }
    },
    
    saveAtt2 : function(component,event,file,parentId){
        console.log('saveAtt2 called ');
        var reader = new FileReader();
        reader.onloadend = function() {
            var contents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
            var fileContents = contents.substring(dataStart);
            
            var action = component.get("c.uploadFile");
            
            action.setParams({
                parent: parentId,
                fileName: file.name,
                base64Data: encodeURIComponent(fileContents),
                contentType: file.type
            });
            action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS'){
                    console.log('response from: saveAtt2',response.getReturnValue());
                }else{
                    console.log('Error :',response.getError());
                }
            });
            $A.enqueueAction(action); 
        }
        reader.readAsDataURL(file);
        //}
        console.log('saveAtt2 end '); 
    },
    fetchOrgCurrncy : function(component, event, helper) {
        console.log('fetchOrgCurrncy CurrencyIsoCode called');
        var polist= component.get("v.AllPOs.POlist");
        var org = polist[0].PO.ERP7__Organisation__c;
        var action=component.get("c.getOrgCurrencies");
        action.setParams({'OrgId' : org});
        action.setCallback(this,function(response){
            console.log('getOrgCurrencies CurrencyIsoCode ~>'+response.getReturnValue());
            if(response.getReturnValue() != null){
                var polist= component.get("v.AllPOs.POlist");
                for(var i in polist){
                    polist[i].PO.CurrencyIsoCode = response.getReturnValue();
                }
                component.set("v.AllPOs.POlist",polist);
            }
            
        });
        $A.enqueueAction(action);
    },
    getVendorAddress  : function(component, event, helper) {
        console.log('getVendorAddress called');
        /*var venList;
        var polist= component.get("v.AllPOs.POlist");
        for(var i in polist){
            venList.push(polist[i].PO.ERP7__Vendor__c);
        }*/
        var venList = [];  // Initialize venList as an array
        
        var polist = component.get("v.AllPOs.POlist");
        for (var i in polist) {
            venList.push(polist[i].PO.ERP7__Vendor__c);
        }
        console.log('venList', venList);
        var action=component.get("c.getVendorAddress");
        action.setParams({'venList' : venList});
        action.setCallback(this,function(response){
            var obj = response.getReturnValue();
            console.log('venList response ~~~~~~~~~~>', obj);
            if(response.getReturnValue() != null){
                var alladress = obj.addresses;
                console.log('alladress',alladress);
                var alltaxes = obj.taxes;
                console.log('alltaxes',alltaxes);
                var polist= component.get("v.AllPOs.POlist");
                for(var i in polist){
                    for(var j in alladress){
                        if(alladress[j].ERP7__Customer__c == polist[i].PO.ERP7__Vendor__c){
                            polist[i].PO.ERP7__Vendor_Address__c = alladress[j].Id;
                            for(var k in polist[i].POLIs){
                                for(var h in alltaxes){
                                    if(h==j){
                                        polist[i].POLIs[k].ERP7__Tax_Rate__c=alltaxes[h];
                                        polist[i].PO.taxrate=alltaxes[h];
                                        var qty = (!$A.util.isEmpty(polist[i].POLIs[k].ERP7__Quantity__c)) && (!$A.util.isUndefinedOrNull(polist[i].POLIs[k].ERP7__Quantity__c)) ? polist[i].POLIs[k].ERP7__Quantity__c : 0;
                                        var unitprice = (!$A.util.isEmpty(polist[i].POLIs[k].ERP7__Unit_Price__c) && !$A.util.isUndefinedOrNull(polist[i].POLIs[k].ERP7__Unit_Price__c)) ? polist[i].POLIs[k].ERP7__Unit_Price__c : 0;
                                        var taxamt = 0;
                                        var taxrate = (!$A.util.isEmpty(polist[i].POLIs[k].ERP7__Tax_Rate__c)) && (!$A.util.isUndefinedOrNull(polist[i].POLIs[k].ERP7__Tax_Rate__c)) ? polist[i].POLIs[k].ERP7__Tax_Rate__c : 0;
                                        console.log('qty',qty);
                                        console.log('unitprice',unitprice);
                                        if(taxrate > 0 && unitprice > 0 && qty > 0) taxamt = parseFloat(((unitprice * qty)/100) * taxrate).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                        var totalPrice = parseFloat(qty * unitprice) + parseFloat(taxamt);
                                        console.log('taxamt',taxamt);
                                        console.log('totalPrice',totalPrice);
                                        polist[i].POLIs[k].ERP7__Tax__c=taxamt;
                                        polist[i].POLIs[k].ERP7__Total_Price__c=totalPrice;
                                    }
                                    
                                }
                                
                                
                            }
                            break;
                        }
                    }
                    
                }
                component.set("v.AllPOs.POlist",polist);
                helper.updateAmounts(component);
                //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }
            
        });
        $A.enqueueAction(action);
    },
    getStockdetails : function(component,event,ProdID,poindex,POliindex,DChannelId) {
        console.log('helper called 4m getStockdetails');
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
                    var prodlist = [];
                    prodlist = component.get('v.plolist.poli');
                    console.log('prodlist bfr',prodlist);
                    prodlist.unshift({pli:{ERP7__Product__c: ProdID}});
                    console.log('prodlist unshift',JSON.stringify(prodlist));
                    
                    for(var i in prodlist){
                        if(prodlist[i].pli.ERP7__Product__c == result.Product){
                            prodlist[i].AwaitingStocks=result.AwaitingStocks;
                            prodlist[i].Demand=result.Demand;
                            prodlist[i].Stock=result.Stock;
                        }
                    }
                    console.log('prodlist aft',JSON.stringify(prodlist));
                    //prodlist.splice(0, 0, "Demand": result.Demand, "Stock": result.Stock, "AwaitingStocks": result.AwaitingStocks);
                    //prodlist.splice(0, 0, {"AwaitingStocks": result.AwaitingStocks, "Demand": result.Demand, "Stock": result.Stock});poliList.unshift({pli: {sObjectType :'ERP7__Purchase_Line_Items__c', ERP7__Product__c : '',Name : ''}});
                    //prodlist.unshift({AwaitingStocks:result.AwaitingStocks, Demand: result.Demand, Stock: result.Stock});
                    component.set('v.plolist.poli',prodlist);
                    /*var prodlist = component.get('v.AllPOs.POlist');
                    for(var x in prodlist){ 
                        if(x == poindex){
                            for(var i in prodlist[x].POLIs){
                                if(i == POliindex){
                                   prodlist[x].POLIs[i].ERP7__Product__c;
                                }  
                            }
                            
                        }
                        
                    }
                    for(var c in obj[x].POLIs){
                        if(obj[c].pli.ERP7__Product__c == result.Product){
                            console.log('Product id matched');
                            obj[c].Demand =  result.Demand;
                            obj[c].Stock =  result.Stock;
                            obj[c].AwaitingStocks =  result.AwaitingStocks;
                        }
                    }*/
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(action);
        }catch(e){
            console.log('Error : '+JSON.stringify(e));
        }
        
    },
    AnalyticalAccountCoaCheck : function(component, event, helper) {
        console.log('Inside AnalyticalAccountCoaCheck');  
        var POlist = component.get("v.AllPOs.POlist");
        var bool = false;
        //for(var x in poli){
        for(var i = 0; i < POlist.length; i++){
            for(var x = 0; x < POlist[i].POLIs.length; x++){
                var acc = [];
                acc = POlist[i].POLIs[x].Accounts;
                if(acc != undefined && acc != null){
                    if(acc.length > 0){
                        if(POlist[i].POLIs[x].ERP7__Chart_of_Account__c ==null || POlist[i].POLIs[x].ERP7__Chart_of_Account__c == undefined || POlist[i].POLIs[x].ERP7__Chart_of_Account__c == '') {
                            return true;
                        }
                        //for(var y in acc){
                        for(var y = 0; y < acc.length; y++){
                            if(acc[y].ERP7__Project__c == null || acc[y].ERP7__Project__c == undefined || acc[y].ERP7__Project__c == ''){
                                return true;
                            }
                            /*if(acc[y].ERP7__Allocation_Percentage__c == null || acc[y].ERP7__Allocation_Percentage__c == 0 || acc[y].ERP7__Allocation_Percentage__c == ''|| acc[y].ERP7__Allocation_Percentage__c <100){
                                return true;
                            }
                            if(acc[y].ERP7__Allocation_Amount__c == null || acc[y].ERP7__Allocation_Amount__c == undefined || acc[y].ERP7__Allocation_Amount__c == ''){
                                return true;
                            }*/
                        }
                    }
                }
            }
        }
        return bool;
    },
    AnalyticalAccountAmount : function(component, event, helper) {
        console.log('Inside AnalyticalAccountAmount');  
        var POlist = component.get("v.AllPOs.POlist");
        var bool = false;
        for(var i = 0; i < POlist.length; i++){
            for(var x = 0; x < POlist[i].POLIs.length; x++){
                var acc = [];
                acc = POlist[i].POLIs[x].Accounts;
                if(acc != undefined && acc != null){
                    if(acc.length > 0){
                        if(POlist[i].POLIs[x].TotalAAPercentage == null || POlist[i].POLIs[x].TotalAAPercentage == undefined || POlist[i].POLIs[x].TotalAAPercentage == '' || POlist[i].POLIs[x].TotalAAPercentage <100 || POlist[i].POLIs[x].TotalAAPercentage == 0 || POlist[i].POLIs[x].TotalAAPercentage >100) {
                            return true;
                        }
                    }
                }
            }
        }
        return bool;
    },
    updateACafterchange : function(component,event,index,Pindex){
        try{
            var TotalAAPercentage = 0;
            var polist =component.get("v.AllPOs.POlist");
            var Polii=polist[index].POLIs[Pindex];
            if(Polii.Accounts != undefined && Polii.Accounts != null){
                console.log('1');
                if(Polii.Accounts.length > 0){
                    console.log('2');
                    var itemAccs = Polii.Accounts;
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            console.log('3');
            Polii.TotalAAPercentage=TotalAAPercentage;
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
            if(Polii.ERP7__Total_Price__c != '' && Polii.ERP7__Total_Price__c != null && Polii.ERP7__Total_Price__c != undefined){
                var aaacount = []; aaacount = Polii.Accounts;
                if(aaacount != null && aaacount != undefined){
                    console.log('4');
                    if(aaacount.length > 0){
                        for(var a in aaacount){
                            if(aaacount[a].ERP7__Allocation_Percentage__c != undefined && aaacount[a].ERP7__Allocation_Percentage__c != null && aaacount[a].ERP7__Allocation_Percentage__c != ''){
                                if(aaacount[a].ERP7__Allocation_Percentage__c > 0){
                                    if(!$A.util.isEmpty(Polii.ERP7__Quantity__c) && !$A.util.isUndefinedOrNull(Polii.ERP7__Quantity__c) && !$A.util.isEmpty(Polii.ERP7__Unit_Price__c) && !$A.util.isUndefinedOrNull(Polii.ERP7__Unit_Price__c)){
                                        aaacount[a].ERP7__Allocation_Amount__c = parseFloat((parseFloat(Polii.ERP7__Quantity__c) * parseFloat(Polii.ERP7__Unit_Price__c)) * aaacount[a].ERP7__Allocation_Percentage__c)/100;
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
                Polii.Accounts = aaacount; 
                component.set("v.AllPOs.POlist",polist);
                console.log('Polii with TotalAAPercentage?',Polii);
                console.log('component.set("v.AllPOs.POlist",polist);~>',component.set("v.AllPOs.POlist",polist));
            }
        } catch (e) { console.log('updateACTaxAmount err~>',e); }
    },
    updateAmounts : function(cmp){
        console.log('updateAmounts called');
        var SubTotal =0;
        var TotalTax =0;
        var TotalAmount = 0;
        var polist= cmp.get("v.AllPOs.POlist");
        for(var i in polist){
            SubTotal= 0;
            TotalTax = 0;
            TotalAmount = 0;
            var tax =0;
            if(polist[i].POLIs != undefined && polist[i].POLIs != null){
                for(var x in polist[i].POLIs){ 
                    tax=0;
                    SubTotal += (polist[i].POLIs[x].ERP7__Unit_Price__c * polist[i].POLIs[x].ERP7__Quantity__c);
                    console.log('(polist[i].POLIs[x].ERP7__Unit_Price__c/100)',JSON.stringify(polist[i].POLIs[x].ERP7__Unit_Price__c/100));
                    console.log('polist[i].POLIs[x].ERP7__Tax_Rate__c',JSON.stringify(polist[i].POLIs[x].ERP7__Tax_Rate__c));
                    tax = ((polist[i].POLIs[x].ERP7__Unit_Price__c/100)*polist[i].POLIs[x].ERP7__Tax_Rate__c);
                    console.log('tax',tax);
                    TotalTax += ((tax) * polist[i].POLIs[x].ERP7__Quantity__c);
                    console.log('TotalTax',TotalTax);
                    TotalAmount += (parseFloat(polist[i].POLIs[x].ERP7__Quantity__c * polist[i].POLIs[x].ERP7__Unit_Price__c) + parseFloat(polist[i].POLIs[x].ERP7__Tax__c));
                }
            }
            console.log('SubTotal',SubTotal);
            console.log('TotalTax',TotalTax);
            console.log('TotalAmount',TotalAmount);
            if(SubTotal >= 0) {
                SubTotal = SubTotal.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                polist[i].PO.SubTotal=SubTotal;
            }
            if(TotalTax >= 0) {
                TotalTax = TotalTax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                polist[i].PO.TotalTax=TotalTax; 
            }
            if(TotalAmount >= 0) {
                TotalAmount = TotalAmount.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                polist[i].PO.TotalAmount=TotalAmount; 
            }
            
        }
        cmp.set("v.AllPOs.POlist",polist);
    },
    updateFromTax : function(cmp,index){
        console.log('updateFromTax called');
        console.log('index:',index);
        var TotalTax =0;
        var TotalAmount = 0;
        var polist= cmp.get("v.AllPOs.POlist");
        for(var x in polist[index].POLIs){
            TotalTax = 0;
            TotalAmount = 0;
            var tax =0;
            tax=0;
            tax = ((polist[index].POLIs[x].ERP7__Unit_Price__c/100)*polist[index].POLIs[x].ERP7__Tax_Rate__c);
            console.log('tax',tax);
            TotalTax += ((tax) * polist[index].POLIs[x].ERP7__Quantity__c);
            console.log('TotalTax',TotalTax);
            TotalAmount += (parseFloat(polist[index].POLIs[x].ERP7__Quantity__c * polist[index].POLIs[x].ERP7__Unit_Price__c) + parseFloat(polist[index].POLIs[x].ERP7__Tax__c));
            
            console.log('TotalTax',TotalTax);
            console.log('TotalAmount',TotalAmount);
            if(TotalTax >= 0) {
                TotalTax = TotalTax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                polist[index].PO.TotalTax=TotalTax; 
            }
            if(TotalAmount >= 0) {
                TotalAmount = TotalAmount.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                polist[index].PO.TotalAmount=TotalAmount; 
            }
            
        }
         cmp.set("v.AllPOs.POlist",polist);
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
        var POind = component.get('v.AddPOInd');
        var poliwrp = component.get('v.AllPOs.POlist');
        var vendId = poliwrp[POind].PO.ERP7__Vendor__c;
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
                            standProds[x].ERP7__Vendor__c = vendId;
                            if(standProds[x].prod.ERP7__Approved_Vendors__r != undefined && standProds[x].prod.ERP7__Approved_Vendors__r != null && standProds[x].prod.ERP7__Approved_Vendors__r != ''){
                                for(var y = 0; y < standProds[x].prod.ERP7__Approved_Vendors__r.length; y++){
                                    if(standProds[x].prod.ERP7__Approved_Vendors__r[y].ERP7__Vendor__c == vendId){
                                        standProds[x].ERP7__Lead_Time_Days__c = (standProds[x].prod.ERP7__Approved_Vendors__r[y].ERP7__Lead_Time__c == '' || standProds[x].prod.ERP7__Approved_Vendors__r[y].ERP7__Lead_Time__c == null) ? standProds[x].prod.ERP7__Purchase_Lead_Time_days__c : standProds[x].prod.ERP7__Approved_Vendors__r[y].ERP7__Lead_Time__c; 
                                    }
                                }
                            }
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
                        }
                        console.log('setting listOfProducts here11');
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
    changeAddressEdit : function(component,event,helper){ 
        var polist= component.get("v.AllPOs.POlist");
        var index =0;
        var Polii=polist[index].PO.ERP7__Vendor_Address__c;
        var ven=polist[index].PO.ERP7__Vendor__c;
        console.log('Polii',Polii);
        if(Polii != undefined && Polii != null && Polii != ''){
            var getPO = component.get("c.checkforTax");
            getPO.setParams({
                "addId":Polii,
                "AccId":ven
            });
            
            getPO.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    if(response.getReturnValue()>0){
                        console.log('getReturnValue ', response.getReturnValue());  
                        polist[index].PO.taxrate = response.getReturnValue();
                        }
                    else{
                        console.log('or else');
                        polist[index].PO.taxrate = 0;
                        }
                        component.set("v.AllPOs.POlist",polist); 
                }
                else{
                    var errors = response.getError();
                    console.log("fetchProductDesc error : ", errors);
                }
            });
            $A.enqueueAction(getPO);
        }
    }
    
})