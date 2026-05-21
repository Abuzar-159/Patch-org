({
    /*
    handleCmpEvent :  function(component, event, helper) { 
        console.log('handleCmpEvent called');
        var selectBarcode = component.get("v.SelectedBcrd");
        var stockTakeItem  = component.get("v.stockTakeItem");
        if(!$A.util.isEmpty(selectBarcode) && !$A.util.isUndefined(selectBarcode) && !$A.util.isUndefined(stockTakeItem) && !$A.util.isEmpty(stockTakeItem)){
            if(!$A.util.isEmpty(stockTakeItem.ERP7__Product_c) && !$A.util.isUndefined(stockTakeItem.ERP7__Product_c)){
                if(stockTakeItem.ERP7__Product__r.ERP7__Barcode__c === selectBarcode){
                    component.set("v.oldSelectedBcrd",true);
                    setTimeout(
                        $A.getCallback(function() {
                            component.set("v.SelectedBcrd",'');
                        }), 500
                    );
                    
                    if($A.util.isUndefined(stockTakeItem.ERP7__Stock_In_Hand__c) || $A.util.isEmpty(stockTakeItem.ERP7__Stock_In_Hand__c)){
                        stockTakeItem.ERP7__Stock_In_Hand__c = 1;
                    }else{
                        stockTakeItem.ERP7__Stock_In_Hand__c = parseFloat(stockTakeItem.ERP7__Stock_In_Hand__c) + parseFloat(1);
                    }
                    component.set("v.stockTakeItem",stockTakeItem);
                    helper.calculateVariance(component, event);  
                }else component.set("v.oldSelectedBcrd",false);
            }
        }
    },
    */
    
    updateDefaults : function(component, event, helper) {
        console.log('updateDefaults called');
        var stockInwardItem  = component.get("v.stockInwardItem");
        var stockOutwardItem = component.get("v.stockOutwardItem");
        if(component.get("v.stockTakeItem.ERP7__Inventory_Stock__c") != undefined && component.get("v.stockTakeItem.ERP7__Inventory_Stock__c") != null){
            stockInwardItem['ERP7__Site_ProductService_InventoryStock__r'] = component.get("v.stockTakeItem.ERP7__Inventory_Stock__r");
            stockOutwardItem['ERP7__Site_Product_Service_Inventory_Stock__r'] = component.get("v.stockTakeItem.ERP7__Inventory_Stock__r");
            stockInwardItem['ERP7__Site_ProductService_InventoryStock__c'] = component.get("v.stockTakeItem.ERP7__Inventory_Stock__c");
            stockOutwardItem['ERP7__Site_Product_Service_Inventory_Stock__c'] = component.get("v.stockTakeItem.ERP7__Inventory_Stock__c");
            
            if(component.get("v.stockTakeItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__c") != undefined && component.get("v.stockTakeItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__c") != null){
                stockInwardItem['ERP7__StorageContainer__c'] = component.get("v.stockTakeItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__c");
                stockInwardItem['ERP7__StorageContainer__r'] = component.get("v.stockTakeItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__r");
            }
            
            if(component.get("v.stockTakeItem.ERP7__Inventory_Stock__r.ERP7__Location__c") != undefined && component.get("v.stockTakeItem.ERP7__Inventory_Stock__r.ERP7__Location__c") != null){
                stockInwardItem['ERP7__Location__r'] = component.get("v.stockTakeItem.ERP7__Inventory_Stock__r.ERP7__Location__r");
                stockInwardItem['ERP7__Location__c'] = component.get("v.stockTakeItem.ERP7__Inventory_Stock__r.ERP7__Location__c");
            }
        }
        
        let inwardName = '';
        let outwardName = '';
        if(Boolean(component.get("v.stockTakeItem.ERP7__Product__r.ERP7__Is_Asset__c")) && component.get("v.stockTakeItem.ERP7__Fixed_Asset__c") != undefined && component.get("v.stockTakeItem.ERP7__Fixed_Asset__c") != null){
            stockInwardItem['ERP7__Fixed_Asset__c'] =  component.get("v.stockTakeItem.ERP7__Fixed_Asset__c");
            stockInwardItem['ERP7__Fixed_Asset__r'] = component.get("v.stockTakeItem.ERP7__Fixed_Asset__r");
            stockOutwardItem['ERP7__Fixed_Asset__c'] =  component.get("v.stockTakeItem.ERP7__Fixed_Asset__c")
            stockOutwardItem['ERP7__Fixed_Asset__r'] = component.get("v.stockTakeItem.ERP7__Fixed_Asset__r");
            inwardName = component.get("v.stockTakeItem.ERP7__Fixed_Asset__r.Name");
            outwardName = component.get("v.stockTakeItem.ERP7__Fixed_Asset__r.Name");
        }
        //else{
        if(component.get("v.stockTakeItem.ERP7__Product__c") != undefined && component.get("v.stockTakeItem.ERP7__Product__c") != null){
            stockInwardItem['ERP7__Product__c'] =  component.get("v.stockTakeItem.ERP7__Product__c");
            stockInwardItem['ERP7__Product__r'] = component.get("v.stockTakeItem.ERP7__Product__r");
            inwardName = component.get("v.stockTakeItem.ERP7__Product__r.Name");
            stockOutwardItem['ERP7__Product__c'] =  component.get("v.stockTakeItem.ERP7__Product__c");
            stockOutwardItem['ERP7__Product__r'] = component.get("v.stockTakeItem.ERP7__Product__r");
            outwardName = component.get("v.stockTakeItem.ERP7__Product__r.Name");
        }
        //}
        let stockTakeLineItem = {};
        stockTakeLineItem['Name'] = component.get("v.stockTakeItem.Name");  
        if(component.get("v.stockTakeItem.Id") != undefined && component.get("v.stockTakeItem.Id") != null) stockTakeLineItem['Id'] = component.get("v.stockTakeItem.Id");
        
        stockInwardItem['ERP7__Stock_Take_Line_Item__r'] = stockTakeLineItem;
        stockInwardItem['Name'] = ($A.util.isEmpty(component.get("v.stockTakeItem.Name")))? inwardName : component.get("v.stockTakeItem.Name");
        stockOutwardItem['ERP7__Stock_Take_Line_Item__r'] = stockTakeLineItem;
        stockOutwardItem['Name'] = ($A.util.isEmpty(component.get("v.stockTakeItem.Name")))? outwardName : component.get("v.stockTakeItem.Name");
        
        //stockInwardItem['ERP7__Material_Batch_Lot__r'] = 
        if(component.get("v.stockTakeItem.ERP7__Serial__c") != undefined && component.get("v.stockTakeItem.ERP7__Serial__c") != null){
            stockInwardItem['ERP7__Serial__r'] = component.get("v.stockTakeItem.ERP7__Serial__r");
            stockInwardItem['ERP7__Serial__c'] = component.get("v.stockTakeItem.ERP7__Serial__c");
            stockOutwardItem['ERP7__Serial__r'] = component.get("v.stockTakeItem.ERP7__Serial__r");
            stockOutwardItem['ERP7__Serial__c'] = component.get("v.stockTakeItem.ERP7__Serial__c");
        }
        
        component.set("v.stockInwardItem",stockInwardItem);
        component.set("v.stockOutwardItem",stockOutwardItem);
        component.set("v.outWardStatusOptions",component.get("v.stockOutWardStatus"));
        component.set("v.inWardReasonOptions",component.get("v.stockInWardReason"));
        
    },
    
    updateVariance : function(component, event, helper) {
        console.log('updateVariance called');
        component.set("v.showInward",false);
        component.set("v.showOutward",false);
        component.set("v.showInwardList",false);
        component.set("v.showOutwardList",false);
        let source = event.getSource().get("v.value");
        console.log('source : ',source);
        let inputCmp =  component.find("StockInHand");
        if(source >= 0){
            console.log('in here source >= 0');
            let stockItem = component.get("v.stockTakeItem");
            if(source != null && parseFloat(source) >= 0.00){
                console.log('stockItem.ERP7__Product__r.ERP7__Serialise__c : '+stockItem.ERP7__Product__r.ERP7__Serialise__c);
                console.log('stockItem.ERP7__Stock_In_Hand__c : ',stockItem.ERP7__Stock_In_Hand__c);
                if(stockItem.ERP7__Product__r.ERP7__Serialise__c && stockItem.ERP7__Stock_In_Hand__c >1){
                    //inputCmp.set("v.errors", [{message:"Value must be <= 1"}]);
                    inputCmp.setCustomValidity("Value must be <= 1");
                }
                /* else if(!stockItem.ERP7__Product__r.ERP7__Serialise__c && stockItem.ERP7__Stock_In_Hand__c == 0){
                        inputCmp.setCustomValidity("Value must be >= 0.00");
                        helper.showToast('Error','error','Please enter value greater than zero');
                        console.log('error 2');
                    }*/
                else{
                    console.log('success else');
                    inputCmp.setCustomValidity("");
                    helper.calculateVariance(component, event);  
                }
            } else {
                console.log('in here source~>'+source)
                if(source != undefined && source != null && source != '') inputCmp.setCustomValidity("Value must be >= 0"); 
                else inputCmp.setCustomValidity("");
                //inputCmp.set("v.errors", [{message:"Value must be >= 0.00 "}]); 
                stockItem.ERP7__Variance__c = 0.00; 
                
            }
            component.set("v.stockTakeItem",stockItem);
        }  else{
            console.log('in here 2')
            inputCmp.setCustomValidity("");
        }      
    },
    
    closepopups:  function (component, event, helper) {
        component.set("v.showInward",false);
        component.set("v.showOutward",false);
        component.set("v.showInwardList",false);
        component.set("v.showOutwardList",false);
        component.set("v.saveHide",false);
    },
    
    showStockInwardpopup:  function (component, event, helper) {
        var dis = component.get("v.disabbled");
        if(!dis){
            let stockItem = component.get("v.stockTakeItem");
            let stockInward = component.get("v.stockInwardItem");
            if(parseFloat(stockItem.ERP7__Variance__c)>0.00){
                stockInward['ERP7__Quantity__c'] =  parseFloat(stockItem.ERP7__Variance__c) -  parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
            }
            component.set("v.stockInwardItem",stockInward);
            component.set("v.showInward",true);
            component.set("v.showOutward",false);
            component.set("v.showInwardList",false);
            component.set("v.showOutwardList",false);
            component.set("v.saveHide",true);
        }
    },
    
    showStockOutwardpopup:  function (component, event, helper) {
        var dis = component.get("v.disabbled");
        if(!dis){
            var stockItem = component.get("v.stockTakeItem");
            var stockOutward = component.get("v.stockOutwardItem");
            if(parseFloat(stockItem.ERP7__Variance__c)<0.00){
                stockOutward['ERP7__Quantity__c'] =  (0.00 - parseFloat(stockItem.ERP7__Variance__c)) -  parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
            } 
            component.set("v.stockOutwardItem",stockOutward); 
            component.set("v.showInward",false);
            component.set("v.showOutward",true);
            component.set("v.showInwardList",false);
            component.set("v.showOutwardList",false);
            component.set("v.saveHide",true);
        }
    },
    
    showStockInwardListpopup:  function (component, event, helper) {
        var dis = component.get("v.disabbled");
        if(!dis){
            component.set("v.showInward",false);
            component.set("v.showOutward",false);
            component.set("v.showInwardList",true);
            component.set("v.showOutwardList",false);
            component.set("v.saveHide",true);
        }
    },
    
    showStockOutwardListpopup:  function (component, event, helper) {
        var dis = component.get("v.disabbled");
        if(!dis){
            component.set("v.showInward",false);
            component.set("v.showOutward",false);
            component.set("v.showInwardList",false);
            component.set("v.showOutwardList",true);
            component.set("v.saveHide",true);
        }
    },
    
    createStockInward : function (component, event, helper) {
        var dis = component.get("v.disabbled");
        if(!dis){
            console.log('createStockInward called stockItem~>'+JSON.stringify(component.get("v.stockTakeItem")));
            component.set("v.showInward",false);
            component.set("v.showOutward",false);
            component.set("v.showInwardList",false);
            component.set("v.showOutwardList",false);
            component.set("v.saveHide",false);
            if(!$A.util.isUndefinedOrNull(component.get("v.indexcount")) && !$A.util.isEmpty(component.get("v.indexcount"))){
                component.set("v.indexcount",undefined);
            }else{
                let stockItem = component.get("v.stockTakeItem");
                let stockInward = component.get("v.stockInwardItem");
                if(parseFloat(stockItem.ERP7__Variance__c)>0.00){
                    stockInward['ERP7__Quantity__c'] =  parseFloat(stockItem.ERP7__Variance__c) -  parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
                }
                component.set("v.stockInwardItem",stockInward);
                
                if(component.get("v.prdIndex") != undefined && component.get("v.prdIndex") != null){
                    var prdArr = [] ;
                    if(component.get("v.isAdjusted")){
                        prdArr = component.get("v.adjustedProducts");
                    }else{
                        prdArr = component.get("v.products");
                    }
                    var ik = []; var arsh = []; var stkowlst = [];
                    if(prdArr.length > 0){
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
                        console.log('not found pushing to ik');
                        ik.push(stockInward); 
                    } else console.log('found true so not pushing');
                    if(prdArr.length > 0){
                        prdArr[component.get("v.prdIndex")].stockInWardList = ik;
                        prdArr[component.get("v.prdIndex")].stockOutWardList = stkowlst;
                    }else console.log('prdArr.length is 0');  
                }else console.log('prdIndex null');
            }
        }
    },
    
    createStockOutward : function (component, event, helper) {
        var dis = component.get("v.disabbled");
        if(!dis){
            console.log('createStockOutward called stockItem~>'+JSON.stringify(component.get("v.stockTakeItem")));
            component.set("v.showInward",false);
            component.set("v.showOutward",false);
            component.set("v.showInwardList",false);
            component.set("v.showOutwardList",false);
            component.set("v.saveHide",false);
            console.log('createStockOutward !dis indexcount~>'+component.get("v.indexcount"));
            if(!$A.util.isUndefinedOrNull(component.get("v.indexcount")) && !$A.util.isEmpty(component.get("v.indexcount"))){
                component.set("v.indexcount",undefined);
            }else{
                var stockItem = component.get("v.stockTakeItem");
                var stockOutward = component.get("v.stockOutwardItem");
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
                        ik = prdArr[component.get("v.prdIndex")].stockOutWardList;
                        arsh = prdArr[component.get("v.prdIndex")].stockInWardList;
                    }  else console.log('prdArr.length 0');
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
                        console.log('not found pushing to ik');
                        ik.push(stockOutward); 
                    }else console.log('found true so not pushing');
                    if(prdArr.length > 0){
                        prdArr[component.get("v.prdIndex")].stockOutWardList = ik;
                        prdArr[component.get("v.prdIndex")].stockInWardList = stkiwlst;
                    }else console.log('prdArr.length is 0');  
                }else console.log('prdIndex null');
            }
        }
    },
    
})