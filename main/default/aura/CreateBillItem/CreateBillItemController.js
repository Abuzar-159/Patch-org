({
    doInit : function(component, event, helper){
        try{
            helper.updateProject(component);
            console.log('doInit called CreateBillItem');
            var TotalAAPercentage = 0;
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null){
                if(component.get("v.Item.Accounts.length") > 0){
                    var itemAccs = component.get("v.Item.Accounts");
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            console.log('doinit TotalAAPercentage~>'+TotalAAPercentage);
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
            let poStatus = component.get("c.getCategoryList");
            poStatus.setCallback(this,function(response){
                let resList = response.getReturnValue();
                let resListupdated = [];
                for(var i in resList){
                    if(i!=0) resListupdated.push(resList[i]);
                }
                component.set("v.PoliCategoryList",resListupdated);                
                $A.util.addClass(component.find('mainSpin'), "slds-hide");            
            });
            $A.enqueueAction(poStatus);
            
            component.set("v.Access",$A.get("$Label.c.Other_Tax_Display"));
            component.set("v.TDSAccess",$A.get("$Label.c.TDS_Display"));
            
            console.log('before init ERP7__Tax_Rate__c~>'+component.get("v.Item.ERP7__Tax_Rate__c"));
            
            if(component.get("v.Item.ERP7__Tax_Rate__c") == null || component.get("v.Item.ERP7__Tax_Rate__c") == undefined || component.get("v.Item.ERP7__Tax_Rate__c") <= 0){
                if(component.get("v.Item.ERP7__Tax_Amount__c") != undefined && component.get("v.Item.ERP7__Tax_Amount__c") > 0){
                    var qty = (!$A.util.isEmpty(component.get("v.Item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Quantity__c"))) ? component.get("v.Item.ERP7__Quantity__c") : 0;
                    var amt = (!$A.util.isEmpty(component.get("v.Item.ERP7__Amount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Amount__c"))) ? component.get("v.Item.ERP7__Amount__c") : 0;
                    var taxamt = (!$A.util.isEmpty(component.get("v.Item.ERP7__Tax_Amount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Tax_Amount__c"))) ? component.get("v.Item.ERP7__Tax_Amount__c") : 0;
                    console.log('amt~>'+amt);
                    console.log('taxamt~>'+taxamt);
                    var amount = amt*qty;
                    console.log('amount~>'+amount);
                    //var tax_Percentage=cmp.get("v.Tax_Amount");
                    //var Amount=component.get("v.Item.ERP7__Amount__c");
                    var percentage = parseFloat((taxamt/amount)*100);
                    console.log('inhere4');
                    if(percentage != undefined && percentage != null){
                        console.log('inhere5~>'+percentage);
                        if(percentage >= 0){
                            percentage = percentage.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            console.log('ERP7__Tax_Rate__c 1~>'+percentage);
                            component.set("v.Item.ERP7__Tax_Rate__c",percentage);
                        }
                    }
                    console.log('inhere1');
                    component.UpdateTax();
                }
            }else{
                console.log('inhere22');
                component.UpdateTax();
            }
            console.log('after init ERP7__Tax_Rate__c~>'+component.get("v.Item.ERP7__Tax_Rate__c"));
            
            console.log('inhere2');
            helper.helperTotalPrice(component, event);
            
            setTimeout(
                $A.getCallback(function() {
                    var TotalAAPercentage2 = 0;
                    if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null){
                        if(component.get("v.Item.Accounts.length") > 0){
                            var itemAccs = component.get("v.Item.Accounts");
                            for(var i in itemAccs){
                                if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                                    if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage2 += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                                }
                            }
                        }
                    }
                    console.log('doinit TotalAAPercentage2~>'+TotalAAPercentage2);
                    component.set("v.TotalAAPercentage",TotalAAPercentage2);
                }), 5000
            );
        }catch(e){ console.log('doinit err '+e); }
        
    },
    
    deleteItem : function(component, event, helper) {
        component.set("v.deleteIndex",component.get("v.index"));
    },
    
    DeleteRecord : function(component, event, helper) { 
        console.log('DeleteRecord Called');
        //Moin added this 07th july 2023
        var item = component.get("v.Item");
        if(!$A.util.isUndefined(item)){
        component.set("v.Item.Accounts", []);
        //component.set("v.deleteIndex",component.get("v.index"));
        try {
            var e = $A.get("e.c:RequisitionToPurchaseOrderEvent");                                                  
            e.setParams({
                "Index": component.get("v.index")
            });
            e.fire();
        } catch (ex) {}
        component.set("v.TotalPrice",0);
        component.set("v.Tax",0);
        component.set("v.Tax_Amount",0);
		component.set("v.Discount",0);
        helper.helperTotalPrice(component, event);
        helper.UpdateTDSOnChange(component, event, helper);
        //$A.enqueueAction(component.get("c.updateTotalPrice"));
        }
    },
    
    displayAccounts : function(component,event,helper){
        try{
            var TotalAAPercentage = 0;
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null){
                if(component.get("v.Item.Accounts.length") > 0){
                    var itemAccs = component.get("v.Item.Accounts");
                    for(var i in itemAccs){
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
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null) polList = component.get("v.Item.Accounts");
            console.log('polList before~>'+polList.length);
            console.log('polList before~> '+JSON.stringify(polList));
            /*if (polList.length > 0 && Object.keys(polList[0]).length === 1 && polList[0].Project__c === "") {
                polList.shift();
            }*/
            polList = polList.filter(item => item.ERP7__Project__c !== "" || item.ERP7__Sort_Order__c !== undefined);
            console.log('polList before fixed '+JSON.stringify(polList));
            
            var pol = [];
            pol = component.get("v.billItems");
            var indexed = pol.length;
            var poliIndex = parseInt(component.get("v.index") + 1);
            if(pol != null) poliList = pol[indexed-1].Accounts;
            
            if(component.get("v.AutoAccountAllocation")){
                var coaId = '';
                var projId = '';
                 
                /*if(poliList[0] != undefined){
                    coaId = pol[indexed-1].ERP7__Chart_Of_Account__c;
                    projId = poliList[0].ERP7__Project__c;
                    component.set("v.Item.ERP7__Chart_Of_Account__c", pol[indexed-1].ERP7__Chart_Of_Account__c);
                    component.set("v.Item.ERP7__Account_Category__c", pol[indexed-1].ERP7__Account_Category__c);
                }else{
                    //coaId = 'a110600000YLX4kAAH';
                    //projId = 'a35240000004nA8AAI';
                }
                component.set("v.coaId", coaId);
                component.set("v.projId", projId);
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
                    
                    if(pol[0].ERP7__Chart_Of_Account__c != null && pol[0].ERP7__Chart_Of_Account__c != undefined && pol[0].ERP7__Chart_Of_Account__c != ''){
                        coaId = pol[0].ERP7__Chart_Of_Account__c;
                    }
                    console.log('coaId~>'+coaId);
                    component.set("v.Item.ERP7__Chart_Of_Account__c", coaId);
                    if(pol[0].ERP7__Account_Category__c != null && pol[0].ERP7__Account_Category__c != undefined && pol[0].ERP7__Account_Category__c != ''){
                        component.set("v.Item.ERP7__Account_Category__c", pol[0].ERP7__Account_Category__c);
                    }
                }
                
                if(remainingTotalAAPercent > 0){
                    polList.push({sObjectType :'ERP7__Dimension__c', ERP7__Chart_of_Account__c : coaId, ERP7__Project__c : projId, ERP7__Sort_Order__c:parseInt(poliIndex), ERP7__Allocation_Percentage__c :remainingTotalAAPercent, ERP7__Allocation_Amount__c: ((parseFloat(parseFloat(component.get("v.Item.ERP7__Quantity__c")) * parseFloat(component.get("v.Item.ERP7__Amount__c"))) * remainingTotalAAPercent)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")) });
                }else console.log('arshad new dimension not added because remainingTotalAAPercent~>'+remainingTotalAAPercent);         
            }else{
                if(remainingTotalAAPercent > 0){
                    polList.push({sObjectType :'ERP7__Dimension__c', ERP7__Chart_of_Account__c : null, ERP7__Project__c : null, ERP7__Sort_Order__c:parseInt(poliIndex), ERP7__Allocation_Percentage__c :remainingTotalAAPercent, ERP7__Allocation_Amount__c: ((parseFloat(parseFloat(component.get("v.Item.ERP7__Quantity__c")) * parseFloat(component.get("v.Item.ERP7__Amount__c"))) * remainingTotalAAPercent)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")) });
                }else console.log('arshad new dimension not added because remainingTotalAAPercent~>'+remainingTotalAAPercent);    
            }
            
            component.set("v.Item.Accounts",polList);
            console.log('polList after~>'+polList.length);
            console.log('polList'+JSON.stringify(polList));
            
            var TotalAAPercentage2 = 0;
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null){
                if(component.get("v.Item.Accounts.length") > 0){
                    var itemAccs = component.get("v.Item.Accounts");
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage2 += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage2);
        } catch (e) { console.log('displayAccounts err~>'+e); }
    },
    
    resetAA : function(component, event, helper) {
        try{
            console.log('inside resetAA');
            var TotalAAPercentage = 0;
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null){
                if(component.get("v.Item.Accounts.length") > 0){
                    var itemAccs = component.get("v.Item.Accounts");
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
            component.set("v.Item.ERP7__Chart_Of_Account__c", null);
            var poliList =[]; 
            poliList=component.get("v.Item.Accounts");
            for(var x in poliList){
                poliList[x].ERP7__Project__c = null;
            }
            component.set("v.Item.Accounts",poliList);
        } catch (e) { console.log('resetAA err~>'+e); }
    },
    
    deleteAnalyAcc :function(component, event, helper) {
        try{
            if(event.getSource().get('v.title') != undefined && event.getSource().get('v.title') != null){
                if(event.getSource().get('v.title') != ''){
                    if(component.get('v.recordId') ==undefined || component.get('v.recordId')==null || component.get('v.recordId') == ''){
                        var action=component.get("c.deleteDimensions");
                        action.setParams({'demId':event.getSource().get('v.title')});
                        action.setCallback(this,function(response){
                            //component.set("v.isMultiCurrency",response.getReturnValue().isMulticurrency);
                            //component.set("v.currencyList",response.getReturnValue().currencyList);
                        });
                        $A.enqueueAction(action);
                    }else{
                        console.log('id: ',event.getSource().get('v.title'));
                        var e = $A.get("e.c:TimeEvent");                                                  
                        e.setParams({
                            "value": event.getSource().get('v.title')
                        });
                        e.fire();
                    }
                }
            }
            console.log('inside deleteAnalyAcc');
            var poliList =[]; 
            poliList = component.get("v.Item.Accounts");
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
            component.set("v.Item.Accounts",null);
            console.log('poliList after delete poitems cmp 11 ~>',JSON.stringify(component.get("v.Item.Accounts")));
            console.log('poliList after delete poitems cmp 11 after ~>',JSON.stringify(poliList));
            //poliList = poliList.filter(item => (item.ERP7__Project__c && item.ERP7__Project__c !== "") || item.ERP7__Sort_Order__c !== undefined);
            component.set("v.Item.Accounts",poliList);
            console.log('poliList after delete poitems cmp 1122 ~>',JSON.stringify(component.get("v.Item.Accounts")));
            if(poliList.length <= 0 && component.get("v.Item.Accounts.length") > 0){
                component.set("v.Item.Accounts",null);
            }
            
            console.log('v.Item.Accounts after delete length poitems cmp~>'+component.get("v.Item.Accounts.length"));
            console.log('v.Item.Accounts after delete poitems cmp ~>'+JSON.stringify(component.get("v.Item.Accounts")));
            
            var TotalAAPercentage = 0;
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null){
                if(component.get("v.Item.Accounts.length") > 0){
                    var itemAccs = component.get("v.Item.Accounts");
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            console.log('here 2');
        } catch (e) { console.log('deleteAnalyAcc err~>'+e); }
    },
    
    updateACTaxAmount : function(component,event,helper){
        console.log('updateACTaxAmount called');
        try{
            var TotalAAPercentage = 0;
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null){
                if(component.get("v.Item.Accounts.length") > 0){
                    var itemAccs = component.get("v.Item.Accounts");
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
            console.log('ERP7__Total_Amount__c~>'+component.get("v.Item.ERP7__Total_Amount__c"));
            if(component.get("v.Item.ERP7__Total_Amount__c") != '' && component.get("v.Item.ERP7__Total_Amount__c") != null && component.get("v.Item.ERP7__Total_Amount__c") != undefined){
                var aaacount = []; aaacount = component.get("v.Item.Accounts");
                if(aaacount != null && aaacount != undefined){
                    console.log('inhere');
                    if(aaacount.length > 0){
                        console.log('inhere2');
                        for(var a in aaacount){
                            if(aaacount[a].ERP7__Allocation_Percentage__c != undefined && aaacount[a].ERP7__Allocation_Percentage__c != null && aaacount[a].ERP7__Allocation_Percentage__c != ''){
                                if(aaacount[a].ERP7__Allocation_Percentage__c > 0){
                                    if(!$A.util.isEmpty(component.get("v.Item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Quantity__c")) && !$A.util.isEmpty(component.get("v.Item.ERP7__Amount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Amount__c"))){
                                        aaacount[a].ERP7__Allocation_Amount__c = parseFloat((parseFloat(component.get("v.Item.ERP7__Quantity__c")) * parseFloat(component.get("v.Item.ERP7__Amount__c"))) * aaacount[a].ERP7__Allocation_Percentage__c)/100;
                                        aaacount[a].ERP7__Allocation_Amount__c = aaacount[a].ERP7__Allocation_Amount__c.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                    }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                                }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                            }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                        }
                    }
                }
                console.log('aaacount bfr'+JSON.stringify(aaacount));
                aaacount = aaacount.filter(item => (item.ERP7__Project__c && item.ERP7__Project__c !== "") || item.ERP7__Sort_Order__c !== undefined);
                console.log('aaacount after~>'+aaacount.length);
                console.log('aaacount aftr'+JSON.stringify(aaacount));
                component.set("v.Item.Accounts",aaacount); 
            }
        } catch (e) { console.log('updateACTaxAmount err~>'+e); }
    },
    
    updateACTaxPerentage : function(component,event,helper){
        try{
            if(component.get("v.Item.ERP7__Total_Amount__c") != '' && component.get("v.Item.ERP7__Total_Amount__c") != null && component.get("v.Item.ERP7__Total_Amount__c") != undefined){
                var aaacount = [];
                aaacount = component.get("v.Item.Accounts");
                for(var a in aaacount){
                    if(aaacount[a].ERP7__Allocation_Amount__c != undefined && aaacount[a].ERP7__Allocation_Amount__c != null && aaacount[a].ERP7__Allocation_Amount__c != ''){
                        if(aaacount[a].ERP7__Allocation_Amount__c > 0){
                            var percent = 0;
                            if(!$A.util.isEmpty(component.get("v.Item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Quantity__c")) && !$A.util.isEmpty(component.get("v.Item.ERP7__Amount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Amount__c"))){
                                percent = parseFloat(parseFloat(aaacount[a].ERP7__Allocation_Amount__c) / parseFloat(parseFloat(component.get("v.Item.ERP7__Quantity__c")) * parseFloat(component.get("v.Item.ERP7__Amount__c"))))*100;
                                aaacount[a].ERP7__Allocation_Percentage__c = percent.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                        }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                    }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                }
                console.log('aaacount bfr'+JSON.stringify(aaacount));
                aaacount = aaacount.filter(item => (item.ERP7__Project__c && item.ERP7__Project__c !== "") || item.ERP7__Sort_Order__c !== undefined);
                console.log('aaacount after~>'+aaacount.length);
                console.log('aaacount aftr'+JSON.stringify(aaacount));
                component.set("v.Item.Accounts",aaacount); 
            }
            
            var TotalAAPercentage = 0;
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null){
                if(component.get("v.Item.Accounts.length") > 0){
                    var itemAccs = component.get("v.Item.Accounts");
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
        } catch (e) { console.log('updateACTaxPerentage err~>'+e); }
    },
    
    updateTotalPrice : function(component, event, helper) {
        helper.helperTotalPrice(component, event);
        helper.UpdateTDSOnChange(component, event, helper);
    },
    
    validate : function(component,event,helper){
        component.NoErrors = true;
        var cmpqty = component.find("qty");
        if(!$A.util.isUndefined(cmpqty))
            helper.checkValidationField(component,cmpqty);
        var price = component.find("amount");
        if(!$A.util.isUndefined(price))
            helper.checkValidationField(component,price);
        var productField = component.find("product");
        if(!$A.util.isUndefined(productField))
            helper.checkvalidationLookup(component,productField);
        if(!component.NoErrors){
            var chartOfAccountField = component.find("chartOfAccount");
            if(!$A.util.isUndefined(chartOfAccountField))
                helper.checkvalidationLookup(component,chartOfAccountField);
            if(component.NoErrors)
                productField.set("v.inputStyleclass","");
        }else{
            var chartOfAccountField = component.find("chartOfAccount");
            chartOfAccountField.set("v.inputStyleclass","");
        }
        return component.NoErrors;
    },
    
    UpdateDiscount : function(component,event,helper){
		console.log('UpdateDiscount called');
        var item = component.get("v.Item");
        if(!$A.util.isUndefined(item)){
            
            var discountAMt = component.get("v.Discount");
            component.set("v.Discount",item.ERP7__Discount__c);
            if(item.ERP7__Discount__c=='') component.set("v.Item.ERP7__Discount__c",0); 
            helper.helperTotalPrice(component, event);
        }
    },
    
    UpdateTax : function(component,event,helper){
        try{
            console.log('UpdateTax called');
            var item = component.get("v.Item");
            if(!$A.util.isUndefined(item)){
                var qty = (!$A.util.isEmpty(component.get("v.Item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Quantity__c"))) ? component.get("v.Item.ERP7__Quantity__c") : 0;
                var amt = (!$A.util.isEmpty(component.get("v.Item.ERP7__Amount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Amount__c"))) ? component.get("v.Item.ERP7__Amount__c") : 0;
                var othertaxrate = (!$A.util.isEmpty(component.get("v.Item.ERP7__Other_Tax_Rate__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Other_Tax_Rate__c"))) ? component.get("v.Item.ERP7__Other_Tax_Rate__c") : 0;
                var taxamt = 0; var othertaxamt = 0;
                var taxrate = (!$A.util.isEmpty(component.get("v.Item.ERP7__Tax_Rate__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Tax_Rate__c"))) ? component.get("v.Item.ERP7__Tax_Rate__c") : 0;
                var discount = (!$A.util.isEmpty(component.get("v.Item.ERP7__Discount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Discount__c"))) ? component.get("v.Item.ERP7__Discount__c") : 0;
                
                if(taxrate > 0 && amt > 0 && qty > 0) taxamt = parseFloat((((amt*qty)-discount)/100) * taxrate);
                if(othertaxrate > 0) othertaxamt = parseFloat((amt/100) * othertaxrate);
                if(othertaxamt > 0) othertaxamt = othertaxamt*qty;
                var totalTax = taxamt + othertaxamt;
                component.set("v.Item.ERP7__Tax_Amount__c",taxamt.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
                component.set("v.Item.ERP7__Other_Tax__c",othertaxamt.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
                component.set("v.Tax",totalTax.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
                
                var Other_Tax_Amount = parseFloat(((amt*othertaxrate) / 100));
                component.set("v.Other_Tax_Amount",Other_Tax_Amount);
                
                var amount = parseFloat(amt*qty);
                var tax = component.get("v.Item.ERP7__Tax_Amount__c");
                
                component.set("v.Item.ERP7__Total_Amount__c",parseFloat(amount-discount).toFixed($A.get("$Label.c.DecimalPlacestoFixed"))); //+tax
                var totalAmount = component.get("v.Item.ERP7__Total_Amount__c");
                component.set("v.Tax_Amount",((totalAmount*taxrate)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            }
            /*
            var item = component.get("v.Item");
            //alert('q=>'+item.ERP7__Quantity__c);
            if(item.ERP7__Tax_Rate__c==undefined)item.ERP7__Tax_Rate__c=0;
            if(item.ERP7__Other_Tax_Rate__c==undefined)item.ERP7__Other_Tax_Rate__c=0;
            if(item.ERP7__Quantity__c==undefined)item.ERP7__Quantity__c=0;
            var tax=0;
            if(item.ERP7__Tax_Rate__c!=0)tax=(((item.ERP7__Amount__c*item.ERP7__Quantity__c)-item.ERP7__Discount__c)/100)*item.ERP7__Tax_Rate__c;
            tax=tax;
            var OTtax=0;
            if(item.ERP7__Other_Tax_Rate__c!=0)OTtax=(item.ERP7__Amount__c/100)*item.ERP7__Other_Tax_Rate__c;
            OTtax=OTtax*item.ERP7__Quantity__c;
            var totalTax=tax+OTtax;
            item.ERP7__Tax_Amount__c=tax;
            item.ERP7__Other_Tax__c=OTtax;
            //item.ERP7__Total_Amount__c = item.ERP7__Amount__c + item.ERP7__Tax_Amount__c;
            component.set("v.Item",item);
            component.set("v.Tax",totalTax);
            
            var rate=component.get("v.Item.ERP7__Tax_Rate__c");
            var Amount=component.get("v.Item.ERP7__Amount__c");
            var discount=component.get("v.Item.ERP7__Discount__c");
            
            var rate2=component.get("v.Item.ERP7__Other_Tax_Rate__c");
            component.set("v.Other_Tax_Amount",(Amount*rate2)/100);
            //var value=component.get("v.Tax_Amount");
            //var value2=component.get("v.Other_Tax_Amount");
            //component.set("v.Tax",value+value2);
            var amount=component.get("v.Item.ERP7__Amount__c")*component.get("v.Item.ERP7__Quantity__c");
            var tax=component.get("v.Item.ERP7__Tax_Amount__c");
            component.set("v.Item.ERP7__Total_Amount__c",amount-discount);//+tax
            var totalAmount = component.get("v.Item.ERP7__Total_Amount__c");
            component.set("v.Tax_Amount",((totalAmount*rate)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            */
            //$A.enqueueAction(component.get("c.updateACTaxAmount"));
        }catch(e){ console.log('UpdateTax err',e); }
        
    },
    
    UpdateTaxPercentage: function(cmp, event, helper){
        var tax_Percentage=cmp.get("v.Update_TDS_Amount");
        var Amount=cmp.get("v.Item.ERP7__Amount__c");
        var percentage=(tax_Percentage/Amount)*100;
        cmp.set("v.Item.ERP7__TDS_Rate__c",percentage);
        cmp.UpdateTDS();
    },
    
    UpdateTaxPercentage1: function(cmp, event, helper){
        var tax_Percentage=cmp.get("v.Other_Tax_Amount");
        var Amount=cmp.get("v.Item.ERP7__Amount__c");
        var percentage=((tax_Percentage/Amount)*100).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
        cmp.set("v.Item.ERP7__Other_Tax_Rate__c",percentage); 
        cmp.UpdateTax();
    },
    
    UpdateTaxPercentage2: function(component, event, helper){ 
        try{
            console.log('UpdateTaxPercentage2 called');
            var qty = (!$A.util.isEmpty(component.get("v.Item.ERP7__Quantity__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Quantity__c"))) ? component.get("v.Item.ERP7__Quantity__c") : 0;
            var amt = (!$A.util.isEmpty(component.get("v.Item.ERP7__Amount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Amount__c"))) ? component.get("v.Item.ERP7__Amount__c") : 0;
            var taxamt = (!$A.util.isEmpty(component.get("v.Item.ERP7__Tax_Amount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Tax_Amount__c"))) ? component.get("v.Item.ERP7__Tax_Amount__c") : 0;
            var discount = (!$A.util.isEmpty(component.get("v.Item.ERP7__Discount__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Discount__c"))) ? component.get("v.Item.ERP7__Discount__c") : 0;
            
            var amount = parseFloat(parseFloat(amt*qty) - discount);
            var percentage = parseFloat(((taxamt/amount)*100)).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
            component.set("v.Item.ERP7__Tax_Rate__c",percentage);
            console.log('ERP7__Tax_Rate__c sethere1');
            
            var taxrate = (!$A.util.isEmpty(component.get("v.Item.ERP7__Tax_Rate__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Tax_Rate__c"))) ? component.get("v.Item.ERP7__Tax_Rate__c") : 0;
            var othertaxrate = (!$A.util.isEmpty(component.get("v.Item.ERP7__Other_Tax_Rate__c")) && !$A.util.isUndefinedOrNull(component.get("v.Item.ERP7__Other_Tax_Rate__c"))) ? component.get("v.Item.ERP7__Other_Tax_Rate__c") : 0;
            var taxamt = 0; var othertaxamt = 0;
            if(taxrate > 0) taxamt = parseFloat(parseFloat(((amt*qty)-discount)/100) * taxrate);
            if(othertaxrate > 0) othertaxamt = parseFloat((amt/100) * othertaxrate);
            if(othertaxamt > 0) othertaxamt = othertaxamt*qty;
            var totalTax = taxamt + othertaxamt;
            //component.set("v.Item.ERP7__Tax_Amount__c",taxamt.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            //component.set("v.Item.ERP7__Other_Tax__c",othertaxamt.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            component.set("v.Tax",totalTax.toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            
            //var Other_Tax_Amount = parseFloat(((amt*othertaxrate) / 100));
            //component.set("v.Other_Tax_Amount",Other_Tax_Amount);
            
            var amount = parseFloat(amt*qty); 
            var tax = component.get("v.Item.ERP7__Tax_Amount__c");
            
            component.set("v.Item.ERP7__Total_Amount__c",parseFloat(amount-discount).toFixed($A.get("$Label.c.DecimalPlacestoFixed"))); //+tax
            var totalAmount = component.get("v.Item.ERP7__Total_Amount__c");
            component.set("v.Tax_Amount",((totalAmount*taxrate)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
            
            /*
        var amount=cmp.get("v.Item.ERP7__Amount__c")*cmp.get("v.Item.ERP7__Quantity__c")-cmp.get("v.Item.ERP7__Discount__c");
        var tax=cmp.get("v.Item.ERP7__Tax_Amount__c");
        
        //var tax_Percentage=cmp.get("v.Tax_Amount");
        //var Amount=cmp.get("v.Item.ERP7__Amount__c");
        var percentage=((tax/amount)*100).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
        cmp.set("v.Item.ERP7__Tax_Rate__c",percentage);
        var item = cmp.get("v.Item");
        //alert('q=>'+item.ERP7__Quantity__c);
        if(item.ERP7__Tax_Rate__c==undefined)item.ERP7__Tax_Rate__c=0;
        if(item.ERP7__Other_Tax_Rate__c==undefined)item.ERP7__Other_Tax_Rate__c=0;
        if(item.ERP7__Quantity__c==undefined)item.ERP7__Quantity__c=0;
        var tax=0;
        if(item.ERP7__Tax_Rate__c!=0)tax=(((item.ERP7__Amount__c*item.ERP7__Quantity__c)-item.ERP7__Discount__c)/100)*item.ERP7__Tax_Rate__c;
        tax=tax;
        var OTtax=0;
        if(item.ERP7__Other_Tax_Rate__c!=0)OTtax=(item.ERP7__Amount__c/100)*item.ERP7__Other_Tax_Rate__c;
        OTtax=OTtax*item.ERP7__Quantity__c;
        var totalTax=tax+OTtax;
        item.ERP7__Tax_Amount__c=tax;
        item.ERP7__Other_Tax__c=OTtax;
        //cmp.set("v.Item",item);
        cmp.set("v.Tax",totalTax);
        var rate=cmp.get("v.Item.ERP7__Tax_Rate__c");
        var Amount=cmp.get("v.Item.ERP7__Amount__c");
        var discount = cmp.get("v.Item.ERP7__Discount__c");
        
        cmp.set("v.Item.ERP7__Total_Amount__c",amount-discount);//+tax
        var totalAmount = cmp.get("v.Item.ERP7__Total_Amount__c");
        cmp.set("v.Tax_Amount",((totalAmount*rate)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")));
        //cmp.UpdateTax();
        */
        }catch(e){ console.log('UpdateTaxPercentage2 err',e); }
    },
    
    UpdateTDS : function(cmp, event, helper){
        helper.UpdateTDSOnChange(cmp, event, helper);
    },
    
    
    getprojectBudgetdetails : function(cmp, helper) {
        try{
            var obj = cmp.get('v.Item');
            console.log('obj getstockdetails: '+JSON.stringify(obj));
            var currcoa = cmp.get('v.Item.ERP7__Chart_Of_Account__c');
            console.log('currcoa : '+currcoa);
            console.log('projectId : '+cmp.get('v.projectId'));
            console.log('currcoa : '+currcoa);
            if((currcoa!='' && currcoa!=null) && (cmp.get('v.projectId') != '' && cmp.get('v.projectId') != null)){
                console.log('Entered');
                var action = cmp.get('c.getProjectBudget');
                action.setParams({'CoaId' : currcoa, 'Project': cmp.get('v.projectId')});
                action.setCallback(this,function(response){
                    let resList = response.getReturnValue();
                    console.log('response : '+JSON.stringify(resList));
                    //if(currprod == resList.Product){
                        cmp.set('v.Item.projBudget',resList.projBudget);
                        cmp.set('v.Item.projCommittedBudget',resList.projCommittedBudget);
                        cmp.set('v.Item.projConsumedBudget',resList.projConsumedBudget);
                        cmp.set('v.Item.projRemainingBudget',resList.projRemainingBudget);
                    	cmp.set('v.Item.ERP7__Budget_Account__c', resList.budget);
                        cmp.set('v.Item. ERP7__Project__c', cmp.get('v.projectId'));
                    //}
                    //component.set("v.POStatusoptions",resList);                
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");            
                });
                $A.enqueueAction(action);
            }
        } catch (e) { console.log('err~>'+e); }
    },
    
    
    
    
    //for the OCR by saqlain Khan

handleProductChange: function(component, event, helper) {
        // Get the new product ID from the lookup field
        let productId = component.get("v.Item.ERP7__Product__c");
        
        // Get the product name from the corresponding field (e.g., lookup field label)
        let productName = component.get("v.Item.Name");
        
        // Fire the updateProductEvent
        let compEvent = component.getEvent("updateProductEvent");
        compEvent.setParams({
            index: component.get("v.index"),        // Pass the index of the item
            productId: productId,                    // Pass the product ID
            productName: productName                 // Pass the product Name
        });
        compEvent.fire();
    },
    
   handleProductChange: function(component, event, helper) {
        // Get the selected product ID from the lookup (ERP7__Product__c)
        let productId = component.get("v.Item.ERP7__Product__c");
        let displayName = component.get("v.Item.Name");

        // Get the parent component reference and update its attributes
        let parent = component.get("v.parent");
        if (parent) {
            parent.set("v.Product", productId);  // Update parent Product
            parent.set("v.displayName", true);  // Update parent displayName to true
        }
    },

    handleNameChange: function(component, event, helper) {
        // Get the new name value from the input field
        let name = component.get("v.Item.Name");

        // Get the parent component reference and update its displayName
        let parent = component.get("v.parent");
        if (parent) {
            parent.set("v.displayName", false);  // Update parent displayName to false
        }
    }

})