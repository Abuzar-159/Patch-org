({
    doInit : function(component, event, helper){
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
        
        if(component.get("v.Item.ERP7__Tax_Amount__c")!=undefined){
            var amount=component.get("v.Item.ERP7__Amount__c")*component.get("v.Item.ERP7__Quantity__c");
            var tax=component.get("v.Item.ERP7__Tax_Amount__c");
            //var tax_Percentage=cmp.get("v.Tax_Amount");
            var Amount=component.get("v.Item.ERP7__Amount__c");
            var percentage=(tax/amount)*100;
            component.set("v.Item.ERP7__Tax_Rate__c",percentage);
            component.UpdateTax();
        }
        
        helper.helperTotalPrice(component, event);
        var orglist=component.get("v.orglineItems");
        console.log("orglist in DoInit"+JSON.stringify(orglist));
        
    },
    
    deleteItem : function(component, event, helper) {
        component.set("v.deleteIndex",component.get("v.index"));
    },
    
    DeleteRecord : function(component, event, helper) { 
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
        $A.enqueueAction(component.get("c.updateTotalPrice"));
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
            var remainingTotalAAPercent = parseFloat(100 - component.get("v.TotalAAPercentage"));
            console.log('arshad remainingTotalAAPercent~>'+remainingTotalAAPercent+' typeof~>'+typeof remainingTotalAAPercent);
            
            component.set("v.displayAccount", true);
            var poliList = [];
            var polList = [];
            if(component.get("v.Item.Accounts") != undefined && component.get("v.Item.Accounts") != null) polList = component.get("v.Item.Accounts");
            var pol = [];
            pol = component.get("v.billItems");
            var indexed = pol.length;
            var poliIndex = parseInt(component.get("v.index") + 1);
            if(pol != null) poliList = pol[indexed-1].Accounts;
            if(component.get("v.AutoAccountAllocation")){
                var coaId = '';
                var projId = '';
                if(poliList[0] != undefined){
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
                
                if(remainingTotalAAPercent > 0){
                    polList.unshift({sObjectType :'ERP7__Dimension__c', ERP7__Chart_of_Account__c : coaId, ERP7__Project__c : projId, ERP7__Sort_Order__c:parseInt(poliIndex), ERP7__Allocation_Percentage__c :remainingTotalAAPercent, ERP7__Allocation_Amount__c: (parseFloat(parseFloat(component.get("v.Item.ERP7__Quantity__c")) * parseFloat(component.get("v.Item.ERP7__Amount__c"))) * remainingTotalAAPercent)/100 });
                }else console.log('arshad new dimension not added because remainingTotalAAPercent~>'+remainingTotalAAPercent);         
            }else{
                if(remainingTotalAAPercent > 0){
                    polList.unshift({sObjectType :'ERP7__Dimension__c', ERP7__Sort_Order__c:parseInt(poliIndex), ERP7__Allocation_Percentage__c :remainingTotalAAPercent, ERP7__Allocation_Amount__c: (parseFloat(parseFloat(component.get("v.Item.ERP7__Quantity__c")) * parseFloat(component.get("v.Item.ERP7__Amount__c"))) * remainingTotalAAPercent)/100 });
                }else console.log('arshad new dimension not added because remainingTotalAAPercent~>'+remainingTotalAAPercent);    
            }
            
            component.set("v.Item.Accounts",polList);
            
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
            component.set("v.TotalAAPercentage2",TotalAAPercentage2);
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
            
            component.set("v.Item.ERP7__Chart_of_Account__c", null);
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
            poliList = component.get("v.Item.Accounts");
            if(event.getSource().get('v.name') != undefined && event.getSource().get('v.name') != null){
                var index = event.getSource().get('v.name'); 
                console.log('index~>'+index);
                poliList.splice(index,1);  
            }
            
            component.set("v.Item.Accounts",poliList);
            
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
        /*var index=component.get("v.index");
        console.log("Index",component.get("v.index"));
        var orglist=component.get("v.orglineItems");
        var actqty=component.get("v.Item.ERP7__Quantity__c");
        console.log("Item.ERP7__Quantity__c",component.get("v.Item.ERP7__Quantity__c"));
        console.log("Here");
        console.log("orglist"+JSON.stringify(orglist));
        var inputCmp = component.find("currency");
        for(let x=0; x<orglist.length; x++){
            if(x==index && actqty !== null && actqty !== undefined && actqty !== '' && !isNaN(actqty)){
                console.log("here2");console.log("orglist[x].ERP7__Quantity__c: "+orglist[x].ERP7__Quantity__c);
                if(orglist[x].ERP7__Quantity__c<actqty)component.set("v.Item.ERP7__Quantity__c",orglist[x].ERP7__Quantity__c);
                console.log("Error");
            }else{
                
            }
        }
        console.log("No Error");
        console.log("No Error 2");*/
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
            //alert('q=>'+item.ERP7__Quantity__c);
            if(item.ERP7__Tax_Rate__c==undefined || isNaN(item.ERP7__Tax_Rate__c))item.ERP7__Tax_Rate__c=0;
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
            /*var value=component.get("v.Tax_Amount");
            var value2=component.get("v.Other_Tax_Amount");
            component.set("v.Tax",value+value2);*/
            var amount=component.get("v.Item.ERP7__Amount__c")*component.get("v.Item.ERP7__Quantity__c");
            var tax=component.get("v.Item.ERP7__Tax_Amount__c");
            component.set("v.Item.ERP7__Total_Amount__c",amount-discount);//+tax
            var totalAmount = component.get("v.Item.ERP7__Total_Amount__c");
            component.set("v.Tax_Amount",((totalAmount*rate)/100).toFixed(3));
        }catch(e){ console.log('UpdateTax err',e); }
        //$A.enqueueAction(component.get("c.updateACTaxAmount"));
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
        var percentage=((tax_Percentage/Amount)*100).toFixed(2);
        cmp.set("v.Item.ERP7__Other_Tax_Rate__c",percentage);
        cmp.UpdateTax();
    },

    UpdateTaxPercentage2: function(cmp, event, helper){
        var amount=cmp.get("v.Item.ERP7__Amount__c")*cmp.get("v.Item.ERP7__Quantity__c")-cmp.get("v.Item.ERP7__Discount__c");
        var tax=cmp.get("v.Item.ERP7__Tax_Amount__c");
        
        //var tax_Percentage=cmp.get("v.Tax_Amount");
        //var Amount=cmp.get("v.Item.ERP7__Amount__c");
        var percentage=((tax/amount)*100).toFixed(3);
        percentage = isNaN(percentage) ? 0 : percentage;
        cmp.set("v.Item.ERP7__Tax_Rate__c",percentage);
        var item = cmp.get("v.Item");
        //alert('q=>'+item.ERP7__Quantity__c);
        if(item.ERP7__Tax_Rate__c==undefined || isNaN(item.ERP7__Tax_Rate__c))item.ERP7__Tax_Rate__c=0;
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
        cmp.set("v.Tax_Amount",((totalAmount*rate)/100).toFixed(3));
        //cmp.UpdateTax();
    },
    
    UpdateTDS : function(cmp, event, helper){
        helper.UpdateTDSOnChange(cmp, event, helper);
    },
})