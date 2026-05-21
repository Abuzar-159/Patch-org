({
    hideSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");    
    },
    
    showSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");   
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
    
    calculateVariance : function(component, event){
        var dis = component.get("v.disabbled");
        if(!dis){
            console.log('calculateVariance notdis');
            var stockItem = component.get("v.stockTakeItem");
            stockItem.ERP7__Variance__c = parseFloat(stockItem.ERP7__Stock_In_Hand__c) -  parseFloat(stockItem.ERP7__Stock_Available__c);
            console.log('stockItem.ERP7__Variance__c : ',stockItem.ERP7__Variance__c);
            component.set("v.remainingVariance",stockItem.ERP7__Variance__c); 
            if(parseFloat(stockItem.ERP7__Variance__c)>0.00){
                console.log('In here1');
                let stockInwardItem  = component.get("v.stockInwardItem");
                stockInwardItem['ERP7__Quantity__c'] = parseFloat(stockItem.ERP7__Variance__c) -  parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
                component.set("v.stockInwardItem",stockInwardItem);
                var stockItem = component.get("v.stockTakeItem");
                var stockInward = component.get("v.stockInwardItem");
                console.log('stockInward~>'+JSON.stringify(stockInward));
                if(parseFloat(stockItem.ERP7__Variance__c)>0.00){
                    stockInward['ERP7__Quantity__c'] =  parseFloat(stockItem.ERP7__Variance__c);
                }
                component.set("v.stockInwardItem",stockInward);
                component.set("v.stockTakeItem",stockItem);
                if(component.get("v.prdIndex") != undefined && component.get("v.prdIndex") != null){
                    var prdArr = [] ;
                    if(component.get("v.isAdjusted")){
                        prdArr = component.get("v.adjustedProducts");
                    }else{
                        prdArr = component.get("v.products");
                    }
                    
                    var ik = []; var arsh = []; var stkowlst = [];
                    if(prdArr.length > 0){
                        console.log('stockInWardList of '+ component.get("v.prdIndex") +' b4 list length=>'+prdArr[component.get("v.prdIndex")].stockInWardList.length);
                        ik = prdArr[component.get("v.prdIndex")].stockInWardList;
                        arsh = prdArr[component.get("v.prdIndex")].stockOutWardList;
                    }  else console.log('prdArr.length 0');
                    var found = false;
                    for(var x in ik){
                        if(ik[x].ERP7__Product__c != undefined && ik[x].ERP7__Product__c != null && ik[x].ERP7__Product__c != '' && stockInward.ERP7__Product__c != undefined && stockInward.ERP7__Product__c != null && stockInward.ERP7__Product__c != ''){
                            if(ik[x].ERP7__Product__c == stockInward.ERP7__Product__c) {
                                ik[x] = stockInward;
                                found = true;
                                break; 
                            }
                        }
                    }
                    
                    for(var x in arsh){
                        if(!$A.util.isUndefinedOrNull(arsh[x].ERP7__Stock_Take_Line_Item__c) && !$A.util.isEmpty(arsh[x].ERP7__Stock_Take_Line_Item__c)){
                            stkowlst.push(arsh[x]);
                        }
                    }
                    
                    if(!found){
                        console.log('not found, pushing to ik');
                        ik.push(stockInward); 
                    }else console.log('found true so not pushing');
                    if(prdArr.length > 0){
                        console.log('stock inward pushed in stockInWardList of products index~>'+component.get("v.prdIndex"));
                        prdArr[component.get("v.prdIndex")].stockInWardList = ik;
                        prdArr[component.get("v.prdIndex")].stockOutWardList = stkowlst;
                        console.log('stockInWardList length of index after~>'+component.get("v.prdIndex")+' =>'+prdArr[component.get("v.prdIndex")].stockInWardList.length);
                    }else console.log('prdArr.length is 0');  
                }else console.log('prdIndex null');
            }
            else{
                console.log('In here2');
                let stockOutwardItem  = component.get("v.stockOutwardItem");
                stockOutwardItem['ERP7__Quantity__c'] =  (0.00 - parseFloat(stockItem.ERP7__Variance__c)) - parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
                component.set("v.stockOutwardItem",stockOutwardItem);
                var stockItem = component.get("v.stockTakeItem");
                var stockOutward = component.get("v.stockOutwardItem");
                console.log('stockOutward~>'+JSON.stringify(stockOutward));
                if(parseFloat(stockItem.ERP7__Variance__c)<0.00){
                    stockOutward['ERP7__Quantity__c'] =  (0.00 - parseFloat(stockItem.ERP7__Variance__c)) -  parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
                } 
                component.set("v.stockOutwardItem",stockOutward); 
                if(component.get("v.prdIndex") != undefined && component.get("v.prdIndex") != null){
                    var prdArr = [] ;
                    if(component.get("v.isAdjusted")){
                        prdArr = component.get("v.adjustedProducts");
                    }else{
                        prdArr = component.get("v.products");
                    }
                    
                    var ik = []; var arsh = []; var stkiwlst = [];
                    if(prdArr.length > 0){
                        console.log('stockOutWardList of '+ component.get("v.prdIndex") +' b4 list length=>'+prdArr[component.get("v.prdIndex")].stockOutWardList.length);
                        ik = prdArr[component.get("v.prdIndex")].stockOutWardList;
                        arsh = prdArr[component.get("v.prdIndex")].stockInWardList;
                    } else console.log('prdArr.length 0');
                    var found = false;
                    for(var x in ik){
                        if(ik[x].ERP7__Product__c != undefined && ik[x].ERP7__Product__c != null && ik[x].ERP7__Product__c != '' && stockOutward.ERP7__Product__c != undefined && stockOutward.ERP7__Product__c != null && stockOutward.ERP7__Product__c != ''){
                            if(ik[x].ERP7__Product__c == stockOutward.ERP7__Product__c) {
                                ik[x] = stockOutward;
                                found = true;
                                break; 
                            }
                        }
                    }
                    
                    for(var x in arsh){
                        if(!$A.util.isUndefinedOrNull(arsh[x].ERP7__Stock_Take_Line_Item__c) && !$A.util.isEmpty(arsh[x].ERP7__Stock_Take_Line_Item__c)){
                            stkiwlst.push(arsh[x]);
                        }
                    }
                    
                    if(!found){
                        console.log('not found, pushing to ik');
                        ik.push(stockOutward); 
                    } else console.log('stock outward found true so not pushing');
                    if(prdArr.length > 0){
                        console.log('stock outward pushed in stockOutWardList of products index~>'+component.get("v.prdIndex"));
                        prdArr[component.get("v.prdIndex")].stockOutWardList = ik;
                        prdArr[component.get("v.prdIndex")].stockInWardList = stkiwlst;
                        console.log('stockOutwardlist after length of index ~>'+component.get("v.prdIndex")+' =>'+prdArr[component.get("v.prdIndex")].stockOutWardList.length);
                    }else console.log('prdArr.length is 0');  
                }else console.log('prdIndex null');
            }
        }
    },
    
})