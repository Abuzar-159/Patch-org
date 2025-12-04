({
    focusTOscan: function (component, event) {
        console.log('focusTOscan helper called');
        $(document).ready(function () {
            component.set("v.scanValue", '');
            var barcode = "";
            var pressed = false;
            var chars = [];
            $(window).keypress(function (e) {
                $(".stocktakescan").keypress(function (e) { //change added by Arshad 07/07/2023 to fix issues if typing in free text fast or scanning anything on other pages after navigating from this cmp or typing fast on app launcher search
                    $(".scanMN").keypress(function (e) {
                        e.stopPropagation()
                    });
                    
                    chars.push(String.fromCharCode(e.which));
                    if (pressed == false) {
                        setTimeout(
                            function () {
                                pressed = false;
                                if (chars.length >= 3) {
                                    var barcode = chars.join("");
                                    barcode = barcode.trim();
                                    chars = [];
                                    pressed = false;
                                    component.set("v.scanValue", barcode);
                                    console.log('scanValue : ',component.get("v.scanValue"));
                                    chars = [];
                                    pressed = false;
                                }
                                chars = [];
                                pressed = false;
                            }, 500);
                    }
                    pressed = true;
                });
            }); // end of window key press function         
            
            $(window).keydown(function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                }
            });
        });
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
            toastEvent.fire();
        }
    },
    
    updatevariances : function(component,event,helper,indx,allProductsList,prodId,isSerial,bool){
        try{
            console.log('updatevariances called indx~>'+indx+' prodId~>'+prodId);
            //var allProductsList = component.get("v.allProductsList");
            var stockItem = allProductsList[indx].stockTakeLineItem;
            component.set("v.exceptionError",'');
            if(stockItem.ERP7__Product__c == prodId){
                if(isSerial){
                    console.log('updatevariances isSerial true');
                    var errmsg = '';
                    var msg = $A.get('$Label.c.Serial_No')+stockItem.ERP7__Serial__r.ERP7__Serial_Number__c + ' '+$A.get('$Label.c.scanned_for_product')+' '+stockItem.ERP7__Product__r.Name+$A.get('$Label.c.please_proceed_further');
                    if(stockItem.ERP7__Stock_In_Hand__c != undefined && stockItem.ERP7__Stock_In_Hand__c != null && stockItem.ERP7__Stock_In_Hand__c != ''){
                        if(stockItem.ERP7__Stock_In_Hand__c == 1) errmsg = $A.get('$Label.c.Quantity_cannot_be_greated_than_1_for_serialized_products');
                    }
                    stockItem.ERP7__Stock_In_Hand__c = 1;
                    component.set("v.exceptionError",errmsg);
                    component.set("v.scanmsg",msg);
                    console.log('stockInHand Updated~>'+stockItem.ERP7__Stock_In_Hand__c);
                }else{
                    console.log('updatevariances isSerial false');
                    var inhand = stockItem.ERP7__Stock_In_Hand__c;
                    if(inhand == undefined || inhand == null || inhand == ''){
                        stockItem.ERP7__Stock_In_Hand__c = 1;
                    }else{
                        stockItem.ERP7__Stock_In_Hand__c = parseInt(inhand) + 1;
                    }
                    var msg = $A.get('$Label.c.Quantity_Updated_for_selected_Product')+stockItem.ERP7__Product__r.Name+$A.get('$Label.c.please_proceed_further');
                    component.set("v.scanmsg",msg);
                }
                //alignment start//
                let stockInwardItem  = component.get("v.stockInwardItem");
                let stockOutwardItem = component.get("v.stockOutwardItem");
                if(stockItem.ERP7__Inventory_Stock__c != undefined && stockItem.ERP7__Inventory_Stock__c != null && stockItem.ERP7__Inventory_Stock__c != ''){
                    stockInwardItem['ERP7__Site_ProductService_InventoryStock__r'] = stockItem.ERP7__Inventory_Stock__r;
                    stockOutwardItem['ERP7__Site_Product_Service_Inventory_Stock__r'] = stockItem.ERP7__Inventory_Stock__r;
                    stockInwardItem['ERP7__Site_ProductService_InventoryStock__c'] = stockItem.ERP7__Inventory_Stock__c;
                    stockOutwardItem['ERP7__Site_Product_Service_Inventory_Stock__c'] = stockItem.ERP7__Inventory_Stock__c;
                    
                    if(stockItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__c != undefined && stockItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__c != null && stockItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__c != ''){
                        stockInwardItem['ERP7__StorageContainer__c'] = stockItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__c;
                        stockInwardItem['ERP7__StorageContainer__r'] = stockItem.ERP7__Inventory_Stock__r.ERP7__StorageContainer__r;
                    }
                    
                    if(stockItem.ERP7__Inventory_Stock__r.ERP7__Location__c != undefined && stockItem.ERP7__Inventory_Stock__r.ERP7__Location__c != null && stockItem.ERP7__Inventory_Stock__r.ERP7__Location__c != ''){
                        stockInwardItem['ERP7__Location__r'] = stockItem.ERP7__Inventory_Stock__r.ERP7__Location__r;
                        stockInwardItem['ERP7__Location__c'] = stockItem.ERP7__Inventory_Stock__r.ERP7__Location__c;
                    }
                }
                let inwardName = '';
                let outwardName = '';
                stockInwardItem['ERP7__Product__c'] =  stockItem.ERP7__Product__c;
                stockInwardItem['ERP7__Product__r'] = stockItem.ERP7__Product__r;
                inwardName = stockItem.ERP7__Product__r.Name;
                stockOutwardItem['ERP7__Product__c'] =  stockItem.ERP7__Product__c;
                stockOutwardItem['ERP7__Product__r'] = stockItem.ERP7__Product__r;
                outwardName = stockItem.ERP7__Product__r.Name;
                let stockTakeLineItem = {};
                stockTakeLineItem['Name'] = stockItem.Name;  
                if(stockItem.Id != undefined && stockItem.Id != null && stockItem.Id != '') stockTakeLineItem['Id'] = stockItem.Id;
                stockInwardItem['ERP7__Stock_Take_Line_Item__r'] = stockTakeLineItem;
                stockInwardItem['Name'] = ($A.util.isEmpty(stockItem.Name) || $A.util.isUndefinedOrNull(stockItem.Name))? inwardName : stockItem.Name;
                stockOutwardItem['ERP7__Stock_Take_Line_Item__r'] = stockTakeLineItem;
                stockOutwardItem['Name'] = ($A.util.isEmpty(stockItem.Name) || $A.util.isUndefinedOrNull(stockItem.Name))? outwardName : stockItem.Name;
                //stockInwardItem['ERP7__Material_Batch_Lot__r'] = 
                if(stockItem.ERP7__Serial__c != undefined && stockItem.ERP7__Serial__c != null && stockItem.ERP7__Serial__c != ''){
                    stockInwardItem['ERP7__Serial__r'] = stockItem.ERP7__Serial__r;
                    stockInwardItem['ERP7__Serial__c'] = stockItem.ERP7__Serial__c;
                    stockOutwardItem['ERP7__Serial__r'] = stockItem.ERP7__Serial__r;
                    stockOutwardItem['ERP7__Serial__c'] = stockItem.ERP7__Serial__c;
                }
                //alignment end//
                
                stockItem.ERP7__Variance__c = parseFloat(stockItem.ERP7__Stock_In_Hand__c) -  parseFloat(stockItem.ERP7__Stock_Available__c);
                if(parseFloat(stockItem.ERP7__Variance__c)>0.00){
                    console.log('stockItem.ERP7__Variance__c > 0 inward');
                    stockInwardItem['ERP7__Quantity__c'] = parseFloat(stockItem.ERP7__Variance__c) -  parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
                    console.log('stockInwardItem~>'+JSON.stringify(stockInwardItem));
                    if(parseFloat(stockItem.ERP7__Variance__c)>0.00){
                        stockInwardItem['ERP7__Quantity__c'] =  parseFloat(stockItem.ERP7__Variance__c);
                    }
                    var ik = []; var arsh = []; var stkowlst = [];
                    ik = allProductsList[indx].stockInWardList;
                    arsh = allProductsList[indx].stockOutWardList;
                    var found = false;
                    for(var x in ik){
                        if(ik[x].ERP7__Product__c != undefined && ik[x].ERP7__Product__c != null && ik[x].ERP7__Product__c != '' && stockInwardItem.ERP7__Product__c != undefined && stockInwardItem.ERP7__Product__c != null && stockInwardItem.ERP7__Product__c != ''){
                            if(ik[x].ERP7__Product__c == stockInwardItem.ERP7__Product__c) {
                                ik[x] = stockInwardItem;
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
                        ik.push(stockInwardItem); 
                    }else console.log('stockinward found true so not pushing');
                    allProductsList[indx].stockInWardList = ik;
                    allProductsList[indx].stockOutWardList = stkowlst;
                }
                else{
                    console.log('stockItem.ERP7__Variance__c < 0 outward');
                    stockOutwardItem['ERP7__Quantity__c'] =  (0.00 - parseFloat(stockItem.ERP7__Variance__c)) - parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
                    console.log('stockOutwardItem~>'+JSON.stringify(stockOutwardItem));
                    if(parseFloat(stockItem.ERP7__Variance__c)<0.00){
                        stockOutwardItem['ERP7__Quantity__c'] =  (0.00 - parseFloat(stockItem.ERP7__Variance__c)) -  parseFloat(stockItem.ERP7__Adjusted_Quantity__c);
                    } 
                    var ik = []; var arsh = []; var stkiwlst = [];
                    ik = allProductsList[indx].stockOutWardList;
                    arsh = allProductsList[indx].stockInWardList;
                    var found = false;
                    for(var x in ik){
                        if(ik[x].ERP7__Product__c != undefined && ik[x].ERP7__Product__c != null && ik[x].ERP7__Product__c != '' && stockOutwardItem.ERP7__Product__c != undefined && stockOutwardItem.ERP7__Product__c != null && stockOutwardItem.ERP7__Product__c != ''){
                            if(ik[x].ERP7__Product__c == stockOutwardItem.ERP7__Product__c) {
                                ik[x] = stockOutwardItem;
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
                        ik.push(stockOutwardItem); 
                    } else console.log('stock outward found true so not pushing');
                    allProductsList[indx].stockOutWardList = ik;
                    allProductsList[indx].stockInWardList = stkiwlst;
                }
                console.log('bool here is~>'+bool);
                if(bool) component.set("v.products",allProductsList);
                else component.set("v.allProductsList",allProductsList);
                
                var allProds = component.get("v.allProductsList");
                var prods = component.get("v.products");
                var foundInProds = false;
                for(var i in prods){
                    if (!$A.util.isEmpty(prods[i].stockTakeLineItem) && !$A.util.isUndefinedOrNull(prods[i].stockTakeLineItem)) {
                        if (!$A.util.isEmpty(prods[i].stockTakeLineItem.ERP7__Inventory_Stock__c) && !$A.util.isUndefinedOrNull(prods[i].stockTakeLineItem.ERP7__Inventory_Stock__c)) {
                            if (!$A.util.isEmpty(prods[i].stockTakeLineItem.ERP7__Product__c) && !$A.util.isUndefinedOrNull(prods[i].stockTakeLineItem.ERP7__Product__c)) {
                                if(prods[i].stockTakeLineItem.ERP7__Inventory_Stock__c == allProductsList[indx].stockTakeLineItem.ERP7__Inventory_Stock__c && prods[i].stockTakeLineItem.ERP7__Product__c == allProds[indx].stockTakeLineItem.ERP7__Product__c){
                                    foundInProds = true;
                                    prods.splice(i, 1);
                                    prods.unshift(allProductsList[indx]);
                                    //allProds.splice(indx, 1);
                                    break;
                                }
                            }
                        }
                    }
                }
                if(!foundInProds){
                    prods.unshift(allProductsList[indx]);
                    //allProds.splice(indx, 1);
                }
                component.set("v.products",prods);
                component.set("v.allProductsList",allProds);
            } 
        }catch(e){
            console.log('updatevariances error~>'+e);
            component.set("v.scanmsg",'');
            component.set("v.exceptionError",'');
            helper.showToast('Info', 'info', $A.get('$Label.c.PH_OB_Invalid_barcode_scanned'));
        }
    },
    changeLocationHelper : function(component,loc,helper){
        if (!component.get("v.PreventChange")) {
            console.log('changeLocationHelper called inhere');
            component.set("v.PreventChange", true);
            window.scrollTo(0, 0);
            component.set("v.Container.Offset", 0);
            var show = component.get("v.show");
            var offset = component.get("v.Container.Offset");
            var searchtext = '';
            var channel = '';
            var site = '';
            var recId = '';
            var Location = '';
            
            if(!$A.util.isEmpty(component.get("v.currentEmpChannel")) && !$A.util.isUndefinedOrNull(component.get("v.currentEmpChannel"))){
                channel = component.get("v.currentEmpChannel");
            }
            if(!$A.util.isEmpty(component.get("v.selectedSite")) && !$A.util.isUndefinedOrNull(component.get("v.selectedSite"))){
                site = component.get("v.selectedSite");
            }
            
            if(!$A.util.isEmpty(component.get("v.stockTakeId")) && !$A.util.isUndefinedOrNull(component.get("v.stockTakeId"))){
                recId = component.get("v.stockTakeId");
                component.set("v.recordId", component.get("v.stockTakeId"));
            }
            if(!$A.util.isEmpty(component.get("v.searchString")) && !$A.util.isUndefinedOrNull(component.get("v.searchString"))){
                searchtext = component.get("v.searchString");
            }
            
            if(!$A.util.isEmpty(component.get("v.currentEmpChannel")) && !$A.util.isUndefinedOrNull(component.get("v.currentEmpChannel"))){
                channel = component.get("v.currentEmpChannel");
            }
            if(!$A.util.isEmpty(component.get("v.selectedSite")) && !$A.util.isUndefinedOrNull(component.get("v.selectedSite"))){
                site = component.get("v.selectedSite");
            }
            if(!$A.util.isEmpty(component.get("v.searchString")) && !$A.util.isUndefinedOrNull(component.get("v.searchString"))){
                searchtext = component.get("v.searchString");
            }
            console.log('channel~>'+channel);
            component.set("v.selectedlocation",'');
            component.set("v.selectedlocName",'');
            component.set("v.showSpinner",true);
            var showlocationStocks = component.get("v.showLocationStocks");
            var action = component.get("c.getAllDetails");
            action.setParams({
                recordId: recId,
                searchText: searchtext,
                Channel: channel,
                Site: site,
                Offset: offset,
                Show: show,
                location : component.get("v.stockTake.ERP7__Location__c"),
                showlocStocks : showlocationStocks
            });
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    console.log('res changeLocationHelper: ',response.getReturnValue());
                    let stAudit = [];
                    let resstAudit = response.getReturnValue().stAudit;
                    for (let x in resstAudit) {
                        var obj = { "class": "optionClass", label: resstAudit[x].label, value: resstAudit[x].value };
                        stAudit.push(obj);
                    }
                    component.set("v.stauditOptions", stAudit);
                    
                    let stockOutwardStatus = [];
                    let resstockOutwardStatus = response.getReturnValue().stockOutwardStatus;
                    for (let x in resstockOutwardStatus) {
                        var obj = { "class": "optionClass", label: resstockOutwardStatus[x].label, value: resstockOutwardStatus[x].value };
                        stockOutwardStatus.push(obj);
                    }
                    component.set("v.outWardStatus", stockOutwardStatus);
                    
                    let stockInwardReason = [];
                    let resstockInwardReason = response.getReturnValue().stockInwardReason;
                    for (let x in resstockInwardReason) {
                        var obj = { "class": "optionClass", label: resstockInwardReason[x].label, value: resstockInwardReason[x].value };
                        stockInwardReason.push(obj);
                    }
                    component.set("v.inWardReason", stockInwardReason);
                    
                    component.set("v.stSiteOptions", response.getReturnValue().channelSites);
                    component.set("v.selectedSite", response.getReturnValue().selectedSite);
                    if (response.getReturnValue().selectedSite != undefined && response.getReturnValue().selectedSite != null && response.getReturnValue().selectedSite != '') {
                        component.set("v.step", 'location');
                    } else {
                        component.set("v.step", 'Site');
                    }
                    component.set("v.stStatusOptions", response.getReturnValue().statusOption);
                    component.set('v.ShowAudit', response.getReturnValue().displayAudit);
                    component.set('v.showStockAddress', response.getReturnValue().displayStockAddress);
                    component.set('v.showProdCode', response.getReturnValue().showProdCode);
                    component.set('v.showApprover', response.getReturnValue().showApprover);
                    component.set("v.Container", response.getReturnValue());
                    
                    console.log('here1');
                    component.set("v.stockTake", response.getReturnValue().StockTakeRec);
                    if (response.getReturnValue().StockTakeRec != undefined && response.getReturnValue().StockTakeRec != null) {
                        if (response.getReturnValue().StockTakeRec.Id != undefined && response.getReturnValue().StockTakeRec.Id != null) {
                            if (response.getReturnValue().StockTakeRec.ERP7__Status__c != undefined && response.getReturnValue().StockTakeRec.ERP7__Status__c != null && response.getReturnValue().StockTakeRec.ERP7__Status__c != '') {
                                component.set("v.stockTakeStat", response.getReturnValue().StockTakeRec.ERP7__Status__c);
                            }
                        }
                    }
                    component.set("v.stockTake.ERP7__Location__c",loc);
                    console.log('here2');
                    component.set("v.currentEmployee", response.getReturnValue().Employee);
                    if (response.getReturnValue().Employee != undefined && response.getReturnValue().Employee != null) {
                        if (response.getReturnValue().Employee.Id != undefined && response.getReturnValue().Employee.Id != null) {
                            if (response.getReturnValue().Employee.ERP7__Channel__c != undefined && response.getReturnValue().Employee.ERP7__Channel__c != null) {
                                component.set("v.currentEmpChannel", response.getReturnValue().Employee.ERP7__Channel__c);
                            }
                        }
                    }
                    
                    console.log('here3 LoadNow prodslength~>' + response.getReturnValue().stockTakeWrapperList.length + ' adjprodslength~>' + response.getReturnValue().adjustedstockTakeWrapperList.length);
                    component.set("v.products", response.getReturnValue().stockTakeWrapperList);
                    component.set("v.adjustedProducts", response.getReturnValue().adjustedstockTakeWrapperList);
                    component.set("v.allProductsList", response.getReturnValue().allstockTakeWrapperList);
                    if (component.get("v.products").length <= 0 && component.get("v.adjustedProducts").length <= 0) helper.showToast('Info', 'info', $A.get('$Label.c.No_Products_Available'));
                    component.set("v.exceptionError", response.getReturnValue().exceptionError);
                    component.set("v.PreventChange", false);
                    component.set("v.loadlocationhelper", false);
                    component.set("v.showSpinner",false);
                } else {
                    component.set("v.PreventChange", false);
                    component.set("v.loadlocationhelper", false);
                    var errors = response.getError();
                    console.log("server error in LoadNow : ", errors);
                    component.set("v.exceptionError", errors[0].message);
                    component.set("v.showSpinner",false);
                }
                
            });
            $A.enqueueAction(action);
            
            
        }
        else{
            console.log('did not go in changeLocationHelper');
        }
    }
    
})