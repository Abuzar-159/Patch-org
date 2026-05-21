({
    doInit : function(component, event, helper) {
        console.log('doInit called');
        helper.getDependentPicklists(component, event, helper);
        helper.getReturnDependentPicklists(component, event, helper);
        helper.doini(component, event, helper);
        helper.getBillingOptionsPickList(component,event,helper);
        
        if(component.get('v.SOId') != '') {
            helper.fetchSoliList(component, event, helper);
            $A.util.removeClass(component.find('mainSpin'), "slds-hide"); // Show spinner because now the fetchstocksDC will start since the distribution channel is changed inside the fetchSoliList helper
        }else if(component.get('v.orderId') != '')
            helper.fetchOrdItemList(component, event, helper);
        else if(component.get('v.POId') != '')
            helper.fetchPOItemList(component, event,helper);
        else if(component.get('v.LogId') != ''){
            helper.fetchLogDetails(component, event,helper);
        }

    },
    
    fetchSoliList:function(component,event,helper){
        helper.fetchSoliList(component, event, helper);
    },
    
    fetchOrdItemList:function(component,event,helper){
        helper.fetchOrdItemList(component, event, helper);
    },
    
    fetchPOItemList : function(component,event,helper){
        helper.fetchPOItemList(component,event,helper);
    },
    
    fetchDistributionChannel:function(component,event,helper){
        console.log('fetchDistributionChannel called channel id~>'+component.get("v.channelId"));
        if(component.get("v.channelId") == undefined ||component.get("v.channelId") == '' || component.get("v.channelId") == null) component.set("v.DistributeChannelId",'');    
        else helper.fetchStoreAddress(component,event,helper,component.get("v.channelId")); 
    },
    fetchstocksDC: function(component, event, helper) {
    try {
        console.log('fetchstocksDC called dc~>' + component.get("v.DistributeChannelId"));

        if(component.get("v.DistributeChannelId") == undefined || component.get("v.DistributeChannelId") == '' || component.get("v.DistributeChannelId") == null) {
            return; // Exit if no distribution channel is selected
        }   
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        
        // var OrderId;
        // if (component.get('v.SOId') != '') 
        //     OrderId = component.get('v.SOId');
        // else if (component.get('v.orderId') != '')
        //     OrderId = component.get('v.orderId');
        // else if (component.get('v.POId') != '')
        //     OrderId = component.get('v.POId');

        console.log('component.get(v.SOId) = ' + component.get('v.SOId'));
        console.log('component.get(v.orderId) = ' + component.get('v.orderId'));
        console.log('component.get(v.POId) = ' + component.get('v.POId'));

        var OrderId = '';
        var idType = ''; // New variable to track the type

        // Logic to determine ID and Type
        if (component.get('v.SOId') != '' && component.get('v.SOId') != null) {
            OrderId = component.get('v.SOId');
            idType = 'SalesOrder'; // It is a Sales Order
        } 
        else if (component.get('v.orderId') != '' && component.get('v.orderId') != null) {
            OrderId = component.get('v.orderId');
            idType = 'Order'; // It is a Standard Order
        } 
        else if (component.get('v.POId') != '' && component.get('v.POId') != null) {
            OrderId = component.get('v.POId');
            idType = 'PO'; // It is a Purchase Order
        }

        console.log('Final OrderId: ', OrderId);
        console.log('Detected Type: ', idType);

        console.log('JSON.stringify(component.get("v.OrdItemList")) = ' + JSON.stringify(component.get("v.OrdItemList")));
        console.log('component.get("v.channelId") = ' + component.get("v.channelId"));
        console.log('JSON.stringify(component.get("v.LLIList")) = ' + JSON.stringify(component.get("v.LLIList")));
                
        // 2. Logic to select the correct list for 'orditms' parameter
        var itemsToSend = [];
        if (idType === 'SalesOrder') {
            itemsToSend = component.get("v.SoliList");
        } else if(idType === 'Order') {
            // Default to OrdItemList for Standard Orders (and potentially others if needed)
            itemsToSend = component.get("v.OrdItemList");
        }

        var action = component.get("c.getupdatedstocksDC");
        action.setParams({
            "OrdId": OrderId,
            "orditms": JSON.stringify(itemsToSend),
            "chnId": component.get("v.channelId"),
            "DCId": component.get("v.DistributeChannelId"),
            "LogItems": JSON.stringify(component.get("v.LLIList")),
            "idType": idType
        });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var returnVal = response.getReturnValue();
                console.log('response.getReturnValue() : ', returnVal);

                // --- HELPER FUNCTION FOR KIT LOGIC (Add this inside the callback or helper) ---
                // Calculates if a Kit is fully shipped based on its BOM components
                var isKitFullyShipped = function(lineItem, bomList) {
                    if (!lineItem || !bomList) return false;
                    
                    // Find all BOMs for this line item
                    var relatedBoms = [];
                    for(var k=0; k<bomList.length; k++){
                        // Check link for OrderItem or SOLI
                        if((lineItem.Id && bomList[k].OrderProdId == lineItem.Id) || 
                           (lineItem.Product2Id && bomList[k].Bom.ERP7__BOM_Product__c == lineItem.Product2Id) ||
                           (lineItem.ERP7__Product__c && bomList[k].Bom.ERP7__BOM_Product__c == lineItem.ERP7__Product__c)) {
                            relatedBoms.push(bomList[k]);
                        }
                    }
                    
                    if(relatedBoms.length === 0) return false; // No BOMs found, assume not fully shipped
                    
                    // Logic: If the parent Logistic Qty is >= (Order Qty * Sum of BOM Qty per unit), it's done.
                    // However, simpler check: Check if specific BOM stock/logistic status allows more.
                    // For this requirement: "Show Qty itself until sum of (qty to logistic) of all BOMs is less then logisticed qty"
                    
                    // SIMPLIFIED LOGIC BASED ON REQUIREMENT:
                    // If Logistic Qty on Parent > 0, it means *something* was shipped.
                    // We need to compare Parent Logistic Qty vs (Parent Order Qty * Total BOM Components per Parent Unit).
                    // Actually, usually Logistic Qty on parent is just a counter. 
                    // Let's use the standard "Remaining Qty" logic provided:
                    
                    // If (ParentLogisticQty < (ParentQty * Sum(BOM_Quantities))), then return False (Not fully shipped)
                    // But we don't have easy access to "Sum(BOM_Quantities)" easily without looping.
                    
                    // ALTERNATIVE: Just check if we can ship ONE more unit.
                    // If we can ship 1 more unit (Inventory check is separate), then it is not fully shipped.
                    
                    // BASED ON USER REQUEST: 
                    // "show that Qty only until the sum of (qty to logistic ) of all the BOMs of that kit is less then the logisticed qty of the end product"
                    // Interpret: If (Parent.Logistic_Qty < Expected_Total_Logistic_Qty_For_Full_Order), then show Parent.Qty.
                    
                    var totalBomsPerUnit = 0;
                    for(var b=0; b<relatedBoms.length; b++) {
                        totalBomsPerUnit += (relatedBoms[b].Bom.ERP7__Quantity__c || 0);
                    }
                    
                    var parentOrderQty = (lineItem.Quantity || lineItem.ERP7__Quantity__c || 0);
                    var parentLogisticQty = (lineItem.ERP7__Logistic_Quantity__c || 0);
                    
                    var totalExpectedLogisticQty = totalBomsPerUnit;

                    console.log('total expected Qty = ' + totalExpectedLogisticQty);
                    console.log('parentLogisticQty = ' + parentLogisticQty);
                    
                    // If current accumulated logistic qty is less than total expected, we have remaining items.
                    return (parentLogisticQty >= totalExpectedLogisticQty);
                };


                // addded a new methord for handlling the logistic creation of Sales Order line items by Abubakar on 14-02-2026 
                if (returnVal != null && idType === 'SalesOrder' && returnVal.UpdatedSoliListWrapper) {
                    var wrapperList = returnVal.UpdatedSoliListWrapper;
                    var processedSoliList = [];
                    var bomItems = returnVal.UpdatedBomList || []; // Get BOMs first
                    component.set("v.BomItemList", bomItems);

                    var explodedNames = [];
                    var hasExplodedItems = false;
                    var explodedIds = [];

                    // Flatten Wrapper to simple Object for UI
                    for(var i=0; i<wrapperList.length; i++) {
                        var wrap = wrapperList[i];
                        var soliObj = wrap.soli;

                        // Map Wrapper fields to Object properties
                        // soliObj.ERP7__Remaining_Quantity__c = wrap.remainingQty;
                        soliObj.ERP7__Reserved_Quantity__c = wrap.reservedQty;
                        soliObj.ERP7__Active__c = wrap.isActive; // Important for checkbox enable/disable
                        soliObj.IsExploded = wrap.isExploded;

                        // --- KIT REMAINING QTY LOGIC ---
                        if (soliObj.ERP7__Is_Kit__c) {
                            var fullyShipped = isKitFullyShipped(soliObj, bomItems);
                            if (fullyShipped) {
                                soliObj.ERP7__Remaining_Quantity__c = 0;
                                soliObj.ERP7__Active__c = false; // Disable row
                            } else {
                                var parentTotalQty = soliObj.ERP7__Quantity__c || 1;
                                var parentLogisticQty = soliObj.ERP7__Logistic_Quantity__c || 0;
                                
                                // 1. Calculate Ratio (Total BOM Qty per 1 Parent Kit)
                                var totalBomQtyForOrder = 0;
                                for (var j = 0; j < bomItems.length; j++) {
                                    // Match BOM to this SOLI (OrderProdId)
                                    if (bomItems[j].OrderProdId == soliObj.Id) {
                                        totalBomQtyForOrder += (bomItems[j].Bom.ERP7__Quantity__c || 0);
                                    }
                                }

                                // Ratio: If Parent Qty is 2 and Total BOM is 6, Ratio is 3
                                var bomPerKitRatio = (parentTotalQty > 0) ? (totalBomQtyForOrder / parentTotalQty) : 0;
                                
                                // 2. Calculate Previously Shipped Kits
                                var previouslyShippedKits = 0;
                                if (bomPerKitRatio > 0) {
                                    previouslyShippedKits = parentLogisticQty / bomPerKitRatio;
                                }
                                
                                // 3. Set Remaining Quantity
                                // Use Math.round to handle floating point precision (e.g. 1.9999 -> 2)
                                var calculatedRemaining = parentTotalQty - previouslyShippedKits;
                                soliObj.ERP7__Remaining_Quantity__c = Math.round(calculatedRemaining * 100) / 100;
                                
                                // 4. Disable if fully shipped
                                if (soliObj.ERP7__Remaining_Quantity__c <= 0) {
                                    soliObj.ERP7__Remaining_Quantity__c = 0;
                                    soliObj.ERP7__Active__c = false; 
                                }
                            }
                        } else {
                            // Standard Product Logic
                            soliObj.ERP7__Remaining_Quantity__c = wrap.remainingQty;
                        }
                        
                        // Track exploded items for Toast message
                        if (wrap.isExploded) {
                            hasExplodedItems = true;
                            explodedIds.push(soliObj.Id);
                            explodedNames.push(soliObj.ERP7__Product__r ? soliObj.ERP7__Product__r.Name : soliObj.Name);
                        }

                        processedSoliList.push(soliObj);
                    }

                    component.set("v.BomItemList", returnVal.UpdatedBomList);
                    
                    // for (var i = 0; i < processedSoliList.length; i++) {
                    //     if (processedSoliList[i].ERP7__Is_Kit__c) {
                    //         var hasEnoughStock = true;
                    //         for (var j = 0; j < bomItems.length; j++) {
                    //             // Check Bom items mapped to this SOLI Id
                    //             if (bomItems[j].OrderProdId == processedSoliList[i].Id && 
                    //                 bomItems[j].stock < bomItems[j].Bom.ERP7__Quantity__c) {
                    //                 hasEnoughStock = false;
                    //                 break;
                    //             }
                    //         }
                    //         processedSoliList[i].AllowKit = hasEnoughStock ? 'Allow' : 'Not-Allowed';
                    //     }
                    // }

                    // Kit Availability Check (Mirroring OrderItem logic)
                    var bomItems = component.get("v.BomItemList");
                    for (var i = 0; i < processedSoliList.length; i++) {
                        if (processedSoliList[i].ERP7__Is_Kit__c) {
                            var hasEnoughStock = true;
                            
                            // Get quantities for calculation
                            var parentTotalQty = processedSoliList[i].ERP7__Quantity__c || 1;
                            var parentRemainingQty = processedSoliList[i].ERP7__Remaining_Quantity__c || 0;

                            for (var j = 0; j < bomItems.length; j++) {
                                // Check Bom items mapped to this SOLI Id
                                if (bomItems[j].OrderProdId == processedSoliList[i].Id) {
                                    
                                    // Calculate Required Stock for REMAINING kits only
                                    // Unit Ratio = Total BOM Qty / Total Parent Qty
                                    var bomTotalQty = bomItems[j].Bom.ERP7__Quantity__c || 0;
                                    var unitRatio = (parentTotalQty > 0) ? (bomTotalQty / parentTotalQty) : 0;
                                    var requiredStockForRemaining = unitRatio * parentRemainingQty;
                                    
                                    // Check Stock
                                    if (bomItems[j].stock < requiredStockForRemaining) {
                                        hasEnoughStock = false;
                                        break;
                                    }
                                }
                            }
                            processedSoliList[i].AllowKit = hasEnoughStock ? 'Allow' : 'Not-Allowed';
                        }
                    }

                    // Show Toast for Exploded Items
                    if (hasExplodedItems) {
                        var lang = $A.get("$Locale.language");
                        var message = (lang === "fr") 
                            ? "Vous avez déjà explosé les produits suivants : " + explodedNames.join(', ') + "."
                            : "You have already exploded the following products: " + explodedNames.join(', ') + ".";
                        
                        component.set("v.exceptionError1", message);
                        component.set("v.SelectedSoliList", explodedIds);
                    }

                    // Update List
                    component.set("v.SoliList", processedSoliList);

                    console.log('updated v.SoliList by Abubakar = ' + JSON.stringify(component.get("v.SoliList")));

                    // // Re-calculate 'Select All' checkbox state
                    // var allSOLIselected = true;
                    // for (var i = 0; i < processedSoliList.length; i++) {
                    //     // Logic: Must be active, have remaining quantity, and not be exploded
                    //     if (!processedSoliList[i].IsExploded && processedSoliList[i].ERP7__Active__c) {
                    //         // Check Kit Allow status if it's a kit, otherwise check standard qty logic
                    //         if(processedSoliList[i].ERP7__Is_Kit__c){
                    //             if(processedSoliList[i].AllowKit != 'Allow') {
                    //                 // If kit is not allowed, we don't count it towards "Select All" logic (or treat as unchecked)
                    //             } else {
                    //                 allSOLIselected = allSOLIselected && processedSoliList[i].checked;
                    //             }
                    //         } else {
                    //             allSOLIselected = allSOLIselected && processedSoliList[i].checked;
                    //         }
                    //     }
                    // }
                    // component.set("v.allSOLIselected", allSOLIselected);

                    // 3. AUTO-SELECT LOGIC: Explicitly set .checked = true
                    var selectedSoliIds = [];
                    var allEligibleSelected = true;
                    var hasEligibleItems = false;

                    for (var i = 0; i < processedSoliList.length; i++) {
                        var s = processedSoliList[i];
                        
                        // Determine Eligibility (Must match conditions in your selectAllSoli logic)
                        var isEligible = !s.IsExploded && s.ERP7__Active__c && s.ERP7__Remaining_Quantity__c > 0;
                        if(s.ERP7__Is_Kit__c && s.AllowKit == 'Not-Allowed'){
                            isEligible = false;
                        }else if(s.ERP7__Is_Kit__c && s.AllowKit == 'Allow' && s.ERP7__Remaining_Quantity__c > 0){
                            isEligible = true;
                        }

                        if (isEligible) {
                            s.checked = true; // <--- THIS CHECKED THE ROW
                            selectedSoliIds.push(s);
                            hasEligibleItems = true;
                        } else {
                            s.checked = false;
                        }
                    }

                    // 4. Update Component
                    // Only set Select All to true if we actually selected something
                    component.set("v.allSOLIselected", hasEligibleItems); 
                    component.set("v.SoliList", processedSoliList);
                    component.set("v.SelectedSoliList", selectedSoliIds);
                }
                else if (returnVal != null && idType === 'Order') {
                    component.set("v.OrdItemList", response.getReturnValue().UpdatedOrdList);
                    component.set("v.BomItemList", response.getReturnValue().UpdatedBomList);
                    component.set("v.LLIList", response.getReturnValue().UpdatedlogList);
                    
                    let tempOrderitems = component.get("v.OrdItemList");
                    var bomItems = component.get("v.BomItemList");
                    var explodedOrderItems = response.getReturnValue().ExplodedOrderItems;
                    var hasExplodedItems = false;
                    var explodedIds = [];
                    var explodedNames = [];

                    for (var i = 0; i < tempOrderitems.length; i++) {
                        var item = tempOrderitems[i];
                        // --- KIT REMAINING QTY LOGIC ---
                        if (tempOrderitems[i].Product2 && tempOrderitems[i].Product2.ERP7__Is_Kit__c) {
                            var fullyShipped = isKitFullyShipped(tempOrderitems[i], bomItems);
                            if (fullyShipped) {
                                tempOrderitems[i].ERP7__Remaining_Quantity__c = 0;
                                tempOrderitems[i].ERP7__Active__c = false; // Disable row
                            } else {
                                var parentTotalQty = item.Quantity || 1;
                                var parentLogisticQty = item.ERP7__Logistic_Quantity__c || 0;
                                
                                // 1. Calculate Ratio
                                var totalBomQtyForOrder = 0;
                                for (var j = 0; j < bomItems.length; j++) {
                                    // Match BOM to this Order Item
                                    if (bomItems[j].OrderProdId == item.Id) {
                                        totalBomQtyForOrder += (bomItems[j].Bom.ERP7__Quantity__c || 0);
                                    }
                                }

                                var bomPerKitRatio = (parentTotalQty > 0) ? (totalBomQtyForOrder / parentTotalQty) : 0;
                                
                                // 2. Calculate Previously Shipped Kits
                                var previouslyShippedKits = 0;
                                if (bomPerKitRatio > 0) {
                                    previouslyShippedKits = parentLogisticQty / bomPerKitRatio;
                                }
                                
                                // 3. Set Remaining Quantity
                                var calculatedRemaining = parentTotalQty - previouslyShippedKits;
                                item.ERP7__Remaining_Quantity__c = Math.round(calculatedRemaining * 100) / 100;
                                
                                // 4. Disable if fully shipped
                                if (item.ERP7__Remaining_Quantity__c <= 0) {
                                    item.ERP7__Remaining_Quantity__c = 0;
                                    item.ERP7__Active__c = false;
                                }
                            }
                        }
                        // Note: Non-kit Remaining Qty is already calculated in Apex for OrdItems
                    }
                    
                    // Check for exploded items
                    for (var oiId in explodedOrderItems) {
                        if (explodedOrderItems[oiId]) {
                            hasExplodedItems = true;
                            for (var k in tempOrderitems) {
                                if (tempOrderitems[k].Id == oiId) {
                                    explodedNames.push(tempOrderitems[k].Product2.Name);
                                    tempOrderitems[k].IsExploded = true;
                                    explodedIds.push(oiId);
                                }
                            }
                        }
                    }
                    component.set("v.OrdItemList", tempOrderitems);
                    
                    // Handle exploded items
                    // if (hasExplodedItems) {
                    // component.set("v.exceptionError1", "You have already exploded the following products: " + explodedNames.join(', ') + ".");
                    if (hasExplodedItems) {
                        var lang = $A.get("$Locale.language"); // gets current org/user language
                        var message = "";

                        if (lang === "fr") {
                            message = "Vous avez déjà explosé les produits suivants : " + explodedNames.join(', ') + ".";
                        } else {
                            message = "You have already exploded the following products: " + explodedNames.join(', ') + ".";
                        }

                        component.set("v.exceptionError1", message);
                        component.set("v.SelectedSoliList", explodedIds);
                            
                        // Auto-create logistics for exploded items after 3 seconds
                        // setTimeout(function() {
                        //      helper.convertToLogistic(component, event, helper);
                        //  }, 3000);
                    }

                   
                    // var allSOLIselected = true;
                    // for (var i = 0; i < tempOrderitems.length; i++) {
                    //     if (!tempOrderitems[i].IsExploded && tempOrderitems[i].ERP7__Active__c && 
                    //         ((tempOrderitems[i].ERP7__Remaining_Quantity__c <= tempOrderitems[i].ERP7__Reserved_Quantity__c && 
                    //           tempOrderitems[i].ERP7__Remaining_Quantity__c > 0 && 
                    //           tempOrderitems[i].ERP7__Remaining_Quantity__c <= tempOrderitems[i].Quantity) || 
                    //          (tempOrderitems[i].Product2.ERP7__Is_Kit__c && tempOrderitems[i].AllowKit == 'Allow'))) {
                    //         allSOLIselected = allSOLIselected && tempOrderitems[i].checked;
                    //     }
                    // }
                    // component.set("v.allSOLIselected", allSOLIselected);
                    
                    // Handle kit items inventory check
                    // for (var i = 0; i < tempOrderitems.length; i++) {
                    //     if (tempOrderitems[i].Product2.ERP7__Is_Kit__c) {
                    //         var hasEnoughStock = true;
                    //         for (var j = 0; j < bomItems.length; j++) {
                    //             if (bomItems[j].OrderProdId == tempOrderitems[i].Id && 
                    //                 bomItems[j].stock < bomItems[j].Bom.ERP7__Quantity__c) {
                    //                 hasEnoughStock = false;
                    //                 break;
                    //             }
                    //         }
                    //         tempOrderitems[i].AllowKit = hasEnoughStock ? 'Allow' : 'Not-Allowed';
                    //     }
                    // }

                    for (var i = 0; i < tempOrderitems.length; i++) {
                        if (tempOrderitems[i].Product2.ERP7__Is_Kit__c) {
                            var hasEnoughStock = true;
                            
                            // Get quantities for calculation
                            var parentTotalQty = tempOrderitems[i].Quantity || 1;
                            var parentRemainingQty = tempOrderitems[i].ERP7__Remaining_Quantity__c || 0;

                            for (var j = 0; j < bomItems.length; j++) {
                                if (bomItems[j].OrderProdId == tempOrderitems[i].Id) {
                                    
                                    // Calculate Required Stock for REMAINING kits only
                                    var bomTotalQty = bomItems[j].Bom.ERP7__Quantity__c || 0;
                                    var unitRatio = (parentTotalQty > 0) ? (bomTotalQty / parentTotalQty) : 0;
                                    var requiredStockForRemaining = unitRatio * parentRemainingQty;

                                    if (bomItems[j].stock < requiredStockForRemaining) {
                                        hasEnoughStock = false;
                                        break;
                                    }
                                }
                            }
                            tempOrderitems[i].AllowKit = hasEnoughStock ? 'Allow' : 'Not-Allowed';
                        }
                    }
                    component.set("v.OrdItemList", tempOrderitems);

                    console.log('updated v.OrdItemList by Abubakar = ' + JSON.stringify(tempOrderitems));

                    // 2. AUTO-SELECT LOGIC: Explicitly set .checked = true
                    var selectedOrderIds = [];
                    var hasEligibleItems = false;

                    for (var i = 0; i < tempOrderitems.length; i++) {
                        var item = tempOrderitems[i];
                        
                        // Determine Eligibility (Matches conditions in selectAllSoli)
                        var isEligible = !item.IsExploded && item.ERP7__Active__c;

                        // Must not be exploded and must be Active
                        // Kit Eligibility
                        if (item.Product2.ERP7__Is_Kit__c) {
                            if (item.AllowKit == 'Allow' && item.ERP7__Remaining_Quantity__c > 0) {
                                isEligible = true;
                            }else{
                                isEligible = false;
                            }
                        } 
                        // Standard Product Eligibility (Check Stock vs Remaining)
                        else {
                            if (item.ERP7__Remaining_Quantity__c <= item.ERP7__Reserved_Quantity__c && 
                                item.ERP7__Remaining_Quantity__c > 0 && 
                                item.ERP7__Remaining_Quantity__c <= item.Quantity) {
                                isEligible = true;
                            }
                        }

                        // Apply Selection
                        if (isEligible) {
                            item.checked = true; // <--- THIS CHECKS THE ROW
                            selectedOrderIds.push(item);
                            hasEligibleItems = true;
                        } else {
                            item.checked = false;
                        }
                    }

                    component.set("v.OrdItemList", tempOrderitems);
                    component.set("v.allSOLIselected", hasEligibleItems);
                    component.set("v.SelectedSoliList", selectedOrderIds);
                    
                }

                // Update Logs
                if(returnVal.UpdatedlogList && returnVal.UpdatedlogList.length > 0) {
                    component.set("v.LLIList", returnVal.UpdatedlogList);
                }

                // Refresh the UI
                component.set("v.reRenderSOLItable", false);
                component.set("v.reRenderSOLItable", true);
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set("v.exceptionError", errors[0].message);
                }
            }
            
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });

        
        if (!$A.util.isEmpty(component.get("v.channelId")) && 
            !$A.util.isUndefinedOrNull(component.get("v.channelId"))) {
            
            $A.enqueueAction(action);
        } else {
            console.log('Channel not selected - skipping stock update');
            component.set("v.exceptionError", "Please select a Channel before proceeding.");
            
            component.set("v.allSOLIselected", false);
            var elem = component.find('schId');
            if (elem) {
                if (elem.length) {
                    for (var i in elem) {
                        elem[i].set("v.checked", false);
                    }
                } else {
                    elem.set("v.checked", false);
                }
            }
            component.set("v.SelectedSoliList", []);
            component.set("v.reRenderSOLItable", false);
            component.set("v.reRenderSOLItable", true);
            
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }
        
    } catch (e) {
        console.log('Error:', e);
        component.set("v.exceptionError", e.message);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    }
},
    
 /*   fetchstocksDC:function(component,event,helper){
        try{
            console.log('fetchstocksDC called dc~>'+component.get("v.DistributeChannelId"));
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            
            var OrderId;
            if(component.get('v.SOId') != '') 
                OrderId = component.get('v.SOId');
            else if(component.get('v.orderId') != '')
                OrderId = component.get('v.orderId');
                else if(component.get('v.POId') != '')
                    OrderId = component.get('v.POId');
            
            var action = component.get("c.getupdatedstocksDC");
            action.setParams({
                "OrdId" : OrderId,
                "orditms": JSON.stringify(component.get("v.OrdItemList")),
                "chnId" : component.get("v.channelId"),
                "DCId": component.get("v.DistributeChannelId"),
                "LogItems" : JSON.stringify(component.get("v.LLIList")),
                "idType": ''
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    console.log('response.getReturnValue() : ',response.getReturnValue())
                    if(response.getReturnValue() != null){
                        component.set("v.OrdItemList",response.getReturnValue().UpdatedOrdList);
                        component.set("v.BomItemList",response.getReturnValue().UpdatedBomList);
                        component.set("v.LLIList",response.getReturnValue().UpdatedlogList);
                    }
                    
                    component.set("v.allSOLIselected",false);
                    var elem = []; elem=component.find('schId');
                    if(elem){
                        if(elem.length){
                            for(var i in elem){
                                elem[i].set("v.checked",false);
                            }
                        }else elem.set("v.checked",false);
                    }
                    
                    component.set("v.SelectedSoliList",[]);
                    component.set("v.reRenderSOLItable",false);
                    component.set("v.reRenderSOLItable",true);
                    setTimeout($A.getCallback(function(){
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }),3000);
                    
                    //New code added by Parveez 28/07/23
                    
                    let tempOrderitems = component.get("v.OrdItemList");
                    let tempbom = component.get("v.BomItemList");
                    console.log('tempOrderitems.length : ',tempOrderitems.length);
                    if(tempOrderitems.length > 0){
                        for(var k in tempOrderitems){
                            let totalkitbom = [];
                            let bomwithinventory = [];
                            if(tempOrderitems[k].Product2Id != undefined && tempOrderitems[k].Product2.ERP7__Is_Kit__c){
                                
                                for(var i in tempbom){
                                     console.log('Product2Id:', tempOrderitems[k].Product2Id);
                                    console.log('tempbom[i].Bom.BOM_Product__c:', tempbom[i].Bom.ERP7__BOM_Product__c);
                                    if(tempOrderitems[k].Product2Id == tempbom[i].Bom.ERP7__BOM_Product__c){
                                        totalkitbom.push(tempbom[i].Name);
                                        if(tempbom[i].stock > 0){
                                            bomwithinventory.push(tempbom[i].Name);
                                        }  
                                    }
                                }
                                console.log('totalkitbom:',totalkitbom.length);
                                console.log('bomwithinventory:',bomwithinventory.length);
                                if(totalkitbom.length != bomwithinventory.length){
                                    tempOrderitems[k].AllowKit = 'Not-Allowed';
                                }
                                else if(totalkitbom.length == bomwithinventory.length){
                                    tempOrderitems[k].AllowKit = 'Allow';
                                }
                            }
                            
                        }
                        console.log('kitList :',JSON.stringify(tempOrderitems));
                    }
                    
                    //
                }else{
                    setTimeout($A.getCallback(function(){
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }),3000);
                    var errors = response.getError();
                    console.log("server error in fetchstocksDC : ", errors);
                    component.set("v.exceptionError", errors[0].message);
                    setTimeout( function(){component.set("v.exceptionError", "");}, 5000);
                } 
            });
            if(!$A.util.isEmpty(component.get("v.channelId")) && !$A.util.isUndefinedOrNull(component.get("v.channelId")) && !$A.util.isEmpty(component.get("v.DistributeChannelId")) && !$A.util.isUndefinedOrNull(component.get("v.DistributeChannelId")) && (component.get("v.OrdItemList").length > 0 || component.get("v.LLIList").length > 0)){
                $A.enqueueAction(action);
            }else{
                console.log('not updating stocks');
                component.set("v.allSOLIselected",false);
                var elem = []; elem=component.find('schId');
                console.log('elem ~>'+elem);
                if(elem){
                    if(elem.length){
                        for(var i in elem){
                            elem[i].set("v.checked",false);
                        }
                    }else elem.set("v.checked",false);
                }
                
                component.set("v.SelectedSoliList",[]);
                component.set("v.reRenderSOLItable",false);
                component.set("v.reRenderSOLItable",true);
                setTimeout($A.getCallback(function(){
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }),3000);
                
            }
        }
        catch(e){console.log('Error:',e);}
    },*/
   
 /*  fetchstocksDC: function(component, event, helper) {
        try {
            console.log('fetchstocksDC called dc~>' + component.get("v.DistributeChannelId"));
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            
            var OrderId;
            if (component.get('v.SOId') != '') 
                OrderId = component.get('v.SOId');
            else if (component.get('v.orderId') != '')
                OrderId = component.get('v.orderId');
            else if (component.get('v.POId') != '')
                OrderId = component.get('v.POId');
            
            var action = component.get("c.getupdatedstocksDC");
            action.setParams({
                "OrdId": OrderId,
                "orditms": JSON.stringify(component.get("v.OrdItemList")),
                "chnId": component.get("v.channelId"),
                "DCId": component.get("v.DistributeChannelId"),
                "LogItems": JSON.stringify(component.get("v.LLIList")),
                "idType": ''
            });

            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log('response.getReturnValue() : ', response.getReturnValue());
                    if (response.getReturnValue() != null) {
                        component.set("v.OrdItemList", response.getReturnValue().UpdatedOrdList);
                        component.set("v.BomItemList", response.getReturnValue().UpdatedBomList);
                        component.set("v.LLIList", response.getReturnValue().UpdatedlogList);
                        
                        let tempOrderitems = component.get("v.OrdItemList");
                        var explodedOrderItems = response.getReturnValue().ExplodedOrderItems;
                        var hasExplodedItems = false;
                        var explodedIds = [];
                        var explodedNames = [];
                        for (var oiId in explodedOrderItems) {
                            if (explodedOrderItems[oiId]) {
                                hasExplodedItems = true;
                                for (var k in tempOrderitems) {
                                    if (tempOrderitems[k].Id == oiId) {
                                        explodedNames.push(tempOrderitems[k].Product2.Name);
                                        tempOrderitems[k].IsExploded = true;
                                        explodedIds.push(oiId);
                                    }
                                }
                            }
                        }
                        component.set("v.OrdItemList", tempOrderitems); // Update with IsExploded
                        
                        if (hasExplodedItems) {
                            component.set("v.exceptionError", "You have already exploded the following products: " + explodedNames.join(', ') + ". Please proceed with automatic logistic creation.");
                            component.set("v.SelectedSoliList", explodedIds);
                            setTimeout(function() {
                                var convertAction = component.get("c.convertToLogistic");
                                $A.enqueueAction(convertAction);
                            }, 3000);
                        }

                        // Reset allSOLIselected
                        var allSOLIselected = true;
                        for (var i = 0; i < tempOrderitems.length; i++) {
                            if (!tempOrderitems[i].IsExploded && tempOrderitems[i].ERP7__Active__c && 
                                ((tempOrderitems[i].ERP7__Remaining_Quantity__c <= tempOrderitems[i].ERP7__Reserved_Quantity__c && 
                                  tempOrderitems[i].ERP7__Remaining_Quantity__c > 0 && 
                                  tempOrderitems[i].ERP7__Remaining_Quantity__c <= tempOrderitems[i].Quantity) || 
                                 (tempOrderitems[i].Product2.ERP7__Is_Kit__c && tempOrderitems[i].AllowKit == 'Allow'))) {
                                allSOLIselected = allSOLIselected && tempOrderitems[i].checked;
                            }
                        }
                        component.set("v.allSOLIselected", allSOLIselected);
                        
                        // Handle kit items
                        var bomItems = component.get("v.BomItemList");
                        for (var i = 0; i < tempOrderitems.length; i++) {
                            if (tempOrderitems[i].Product2.ERP7__Is_Kit__c) {
                                var hasEnoughStock = true;
                                for (var j = 0; j < bomItems.length; j++) {
                                    if (bomItems[j].OrderProdId == tempOrderitems[i].Id && 
                                        bomItems[j].stock < bomItems[j].Bom.ERP7__Quantity__c) {
                                        hasEnoughStock = false;
                                        break;
                                    }
                                }
                                tempOrderitems[i].AllowKit = hasEnoughStock ? 'Allow' : 'Not-Allowed';
                            }
                        }
                        component.set("v.OrdItemList", tempOrderitems);
                        
                        // Re-render component
                        $A.get('e.force:refreshView').fire();
                    }
                } else {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        component.set("v.exceptionError", errors[0].message);
                    }
                }
                
                // Hide spinner
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            });

            // Conditional execution of the Apex call
            if (!$A.util.isEmpty(component.get("v.channelId")) && !$A.util.isUndefinedOrNull(component.get("v.channelId")) && 
                !$A.util.isEmpty(component.get("v.DistributeChannelId")) && !$A.util.isUndefinedOrNull(component.get("v.DistributeChannelId")) && 
                (component.get("v.OrdItemList").length > 0 || component.get("v.LLIList").length > 0)) {
                $A.enqueueAction(action);
            } else {
                console.log('not updating stocks');
                component.set("v.allSOLIselected", false);
                var elem = component.find('schId');
                console.log('elem ~>' + elem);
                if (elem) {
                    if (elem.length) {
                        for (var i in elem) {
                            elem[i].set("v.checked", false);
                        }
                    } else {
                        elem.set("v.checked", false);
                    }
                }
                component.set("v.SelectedSoliList", []);
                component.set("v.reRenderSOLItable", false);
                component.set("v.reRenderSOLItable", true);
                setTimeout($A.getCallback(function() {
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }), 3000);
            }
        } catch (e) {
            console.log('Error:', e);
            component.set("v.exceptionError", e.message);
            $A.util.addClass(component.find('mainSpinner'), "slds-hide");
        }
    },
  */
   /* fetchstocksDC: function(component, event, helper) {
    try {
        console.log('fetchstocksDC called dc~>' + component.get("v.DistributeChannelId"));
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        
        var OrderId;
        if (component.get('v.SOId') != '') 
            OrderId = component.get('v.SOId');
        else if (component.get('v.orderId') != '')
            OrderId = component.get('v.orderId');
        else if (component.get('v.POId') != '')
            OrderId = component.get('v.POId');
        
        // Check if DC is populated before proceeding
        if (!$A.util.isEmpty(component.get("v.channelId")) && 
            !$A.util.isUndefinedOrNull(component.get("v.channelId")) && 
            !$A.util.isEmpty(component.get("v.DistributeChannelId")) && 
            !$A.util.isUndefinedOrNull(component.get("v.DistributeChannelId"))) {
            
            var action = component.get("c.getupdatedstocksDC");
            action.setParams({
                "OrdId": OrderId,
                "orditms": JSON.stringify(component.get("v.OrdItemList")),
                "chnId": component.get("v.channelId"),
                "DCId": component.get("v.DistributeChannelId"),
                "LogItems": JSON.stringify(component.get("v.LLIList")),
                "idType": ''
            });

            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log('response.getReturnValue() : ', response.getReturnValue());
                    if (response.getReturnValue() != null) {
                        component.set("v.OrdItemList", response.getReturnValue().UpdatedOrdList);
                        component.set("v.BomItemList", response.getReturnValue().UpdatedBomList);
                        component.set("v.LLIList", response.getReturnValue().UpdatedlogList);
                        
                        let tempOrderitems = component.get("v.OrdItemList");
                        var explodedOrderItems = response.getReturnValue().ExplodedOrderItems;
                        var hasExplodedItems = false;
                        var explodedIds = [];
                        var explodedNames = [];
                        
                        // Check for exploded items
                        for (var oiId in explodedOrderItems) {
                            if (explodedOrderItems[oiId]) {
                                hasExplodedItems = true;
                                for (var k in tempOrderitems) {
                                    if (tempOrderitems[k].Id == oiId) {
                                        explodedNames.push(tempOrderitems[k].Product2.Name);
                                        tempOrderitems[k].IsExploded = true;
                                        explodedIds.push(oiId);
                                    }
                                }
                            }
                        }
                        component.set("v.OrdItemList", tempOrderitems);
                        
                        // Handle exploded items - but only if DC is properly populated
                        if (hasExplodedItems) {
                            component.set("v.exceptionError", "You have already exploded the following products: " + explodedNames.join(', ') + ". Please proceed with automatic logistic creation.");
                            component.set("v.SelectedSoliList", explodedIds);
                            
                            // Only proceed with automatic creation if DC is properly set
                            if (!component.get("v.DCSelectionInProgress") && 
                                !$A.util.isEmpty(component.get("v.DistributeChannelId"))) {
                                setTimeout(function() {
                                    var convertAction = component.get("c.convertToLogistic");
                                    $A.enqueueAction(convertAction);
                                }, 3000);
                            }
                        }

                        // Reset selection logic
                        var allSOLIselected = true;
                        for (var i = 0; i < tempOrderitems.length; i++) {
                            if (!tempOrderitems[i].IsExploded && tempOrderitems[i].ERP7__Active__c && 
                                ((tempOrderitems[i].ERP7__Remaining_Quantity__c <= tempOrderitems[i].ERP7__Reserved_Quantity__c && 
                                  tempOrderitems[i].ERP7__Remaining_Quantity__c > 0 && 
                                  tempOrderitems[i].ERP7__Remaining_Quantity__c <= tempOrderitems[i].Quantity) || 
                                 (tempOrderitems[i].Product2.ERP7__Is_Kit__c && tempOrderitems[i].AllowKit == 'Allow'))) {
                                allSOLIselected = allSOLIselected && tempOrderitems[i].checked;
                            }
                        }
                        component.set("v.allSOLIselected", allSOLIselected);
                        
                        // Handle kit items inventory check
                        var bomItems = component.get("v.BomItemList");
                        for (var i = 0; i < tempOrderitems.length; i++) {
                            if (tempOrderitems[i].Product2.ERP7__Is_Kit__c) {
                                var hasEnoughStock = true;
                                for (var j = 0; j < bomItems.length; j++) {
                                    if (bomItems[j].OrderProdId == tempOrderitems[i].Id && 
                                        bomItems[j].stock < bomItems[j].Bom.ERP7__Quantity__c) {
                                        hasEnoughStock = false;
                                        break;
                                    }
                                }
                                tempOrderitems[i].AllowKit = hasEnoughStock ? 'Allow' : 'Not-Allowed';
                            }
                        }
                        component.set("v.OrdItemList", tempOrderitems);
                        
                        // Refresh the UI
                        $A.get('e.force:refreshView').fire();
                    }
                } else {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        component.set("v.exceptionError", errors[0].message);
                    }
                }
                
                // Hide spinner
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            });
            
            $A.enqueueAction(action);
        } else {
            console.log('DC not properly populated - skipping stock update');
            
            // Reset UI state
            component.set("v.allSOLIselected", false);
            var elem = component.find('schId');
            if (elem) {
                if (elem.length) {
                    for (var i in elem) {
                        elem[i].set("v.checked", false);
                    }
                } else {
                    elem.set("v.checked", false);
                }
            }
            component.set("v.SelectedSoliList", []);
            component.set("v.reRenderSOLItable", false);
            component.set("v.reRenderSOLItable", true);
            
            // Show error message if DC is not selected
            if ($A.util.isEmpty(component.get("v.DistributeChannelId"))) {
                component.set("v.exceptionError", "Please select a Distribution Center before proceeding.");
            }
            
            setTimeout($A.getCallback(function() {
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }), 3000);
        }
    } catch (e) {
        console.log('Error:', e);
        component.set("v.exceptionError", e.message);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    }
},*/
    reloadSoli:function(component,event,helper){
        location.reload();  
    },
    
    backToSoliTab:function(component,event,helper){
        try{
            component.set("v.selectedTab",'soli');
            let selectedItem = []; selectedItem = component.get("v.LLIList");
            console.log('selectedItem : ',selectedItem);
            var OrdItemList=[]; OrdItemList=component.get('v.OrdItemList');
            console.log('OrdItemList : ',OrdItemList);
            var selectedDum = [];
            if(selectedItem.length > 0 && OrdItemList.length > 0){
                console.log('2 here');
                for(var y in OrdItemList){
                    OrdItemList[y].checked = false;
                    for(var x in selectedItem){
                        if(OrdItemList[y].Id == selectedItem[x].ERP7__Order_Product__c){
                            OrdItemList[y].checked = true;
                            selectedDum.push(OrdItemList[y]);
                            console.log('3 in here');
                            break;
                            
                        } 
                    }
                    
                } 
                component.set("v.OrdItemList",OrdItemList); 
                component.set("v.SelectedSoliList",selectedDum); 
            }
            component.set("v.LLIList",[]); 
            component.set("v.selectedTab",'soli');
        }
        catch(e){console.log(e);}
    },
    
    backToSoli:function(component,event,helper){
         window.history.back();
        //component.set("v.selectedTab",'soli');
       /* if(component.get('v.SOId') !=''){
            var RecUrl = "/lightning/r/ERP7__Sales_Order__c/" + component.get('v.SOId') + "/view";
            window.open(RecUrl,'_parent');
        }else if(component.get('v.orderId') !=''){
            var RecUrl = "/lightning/r/Order/" + component.get('v.orderId') + "/view";
            window.open(RecUrl,'_parent');
        }else if(component.get('v.POId') !=''){
            var RecUrl = "/lightning/r/ERP7__PO__c/" + component.get('v.POId') + "/view";
            window.open(RecUrl,'_parent');
        }*/
    },
    
    resetSelected : function(component,event,helper){
        console.log('resetSelected called');
        component.set('v.SelectedSoliList',[]);
        component.set('v.allSOLIselected',false);
    },
    
    selectSoli: function(component, event, helper) {     
        var isSelect = event.getSource().get("v.checked");
        var recordId = event.getSource().get("v.value");
        
        var SelectedSoliList=[]; SelectedSoliList=component.get('v.SelectedSoliList');
        var SoliList =[]; SoliList=component.get("v.SoliList");
        var OrdItemList=[]; OrdItemList=component.get('v.OrdItemList');
        var POItemList=[]; POItemList=component.get('v.POItemList');
        var BomItems = [];BomItems = component.get('v.BomItemList');
        $A.util.removeClass(component.find("cnvrtLogBtnId"),'a_disabled'); 
        
        try{ 
            
            if (isSelect) {
                
                if(SoliList.length > 0){
                    for(var x = 0; x<SoliList.length; x++){
                        if(SoliList[x].Id==recordId ) SelectedSoliList.push(SoliList[x]);
                    }
                }
                else if(OrdItemList.length > 0){
                    for(var y = 0; y<OrdItemList.length; y++){
                        if(OrdItemList[y].Id==recordId )SelectedSoliList.push(OrdItemList[y]);
                        /*if(OrdItemList[y].Id==recordId ) {
                            	
                            	if(OrdItemList[y].Product2.ERP7__Is_Kit__c){   
                                    
                                    for(var k in BomItems) {
                                        if(OrdItemList[y].Product2Id == BomItems[k].Bom.ERP7__BOM_Product__c ){
                                            SelectedSoliList.push(BomItems[k].Bom);
                                        }
                                    }
                            	}
                            	else SelectedSoliList.push(OrdItemList[y]);
                            console.log('SelectedSoliList:',JSON.stringify(SelectedSoliList));
                       } */ 
                    }
                }else if(POItemList.length > 0){
                    for(var z = 0; z<POItemList.length; z++){
                        if(POItemList[z].Id==recordId ) SelectedSoliList.push(POItemList[z]);
                    }
                }
                
            }else {
                var SelectedSoliListDum=[]; SelectedSoliListDum=SelectedSoliList;
                for(var x=0;x<SelectedSoliListDum.length;x++){          
                    if(SelectedSoliListDum[x].Id==recordId){
                        // delete SelectedSoliListDum[x];
                        SelectedSoliListDum.splice(x,1);
                        break;
                    }               
                }
                SelectedSoliList=SelectedSoliListDum;
            }   
            
        }catch(ex){ console.log('ex in checkbox'+ex);  }    
        component.set("v.SelectedSoliList",SelectedSoliList);
        
        /* if(isSelect) $A.util.removeClass(component.find("cnvrtLogBtnId"),'a_disabled'); //.getElement()
     else $A.util.addClass(component.find("cnvrtLogBtnId"),'a_disabled');  //.getElement()  */
    },
    
    // selectAllSoli:function(component,event,helper){
    //     var isSelect = event.getSource().get("v.checked");
    //     console.log('isSelect : ',isSelect);
    //     var elem=[]; elem=component.find('schId');
    //     console.log('elem~>',elem);
    //     var SelectedSoliList=[];
    //     var SoliList =[]; SoliList=component.get("v.SoliList"); 
    //     var OrdItemList=[]; OrdItemList=component.get('v.OrdItemList');
    //     var POItemList=[]; POItemList=component.get('v.POItemList');
        
    //     var SelectedSoliListDum=[];
        
    //     if(SoliList.length > 0){
    //         for(var j=0; j<SoliList.length; j++){ 
    //             if(isSelect==true){  // && SoliList[j].ERP7__Active__c==true
    //                 if(SoliList[j].ERP7__Active__c==true){
    //                     if(elem){
    //                         if(elem.length){
    //                             elem[j].set("v.checked",true);        
    //                         }else elem.set("v.checked",true);        
    //                     }
                        
    //                     SelectedSoliListDum.push(SoliList[j]); 
    //                 }          
    //             }   
    //             else{
    //                 if(elem){
    //                     if(elem.length){
    //                         elem[j].set("v.checked",false);        
    //                     }else elem.set("v.checked",false);        
    //                 }
    //                 SelectedSoliListDum=[];
    //             }
    //         }
    //     }
    //     else if(OrdItemList.length > 0)  {
    //         for(var j=0; j<OrdItemList.length; j++){ 
    //             if(isSelect==true){  
    //                 if ((OrdItemList[j].ERP7__Active__c === true && ((OrdItemList[j].ERP7__Remaining_Quantity__c <= OrdItemList[j].ERP7__Reserved_Quantity__c && OrdItemList[j].ERP7__Remaining_Quantity__c > 0 &&  OrdItemList[j].ERP7__Remaining_Quantity__c <= OrdItemList[j].Quantity) || (OrdItemList[j].Product2.ERP7__Is_Kit__c && OrdItemList[j].AllowKit =='Allow')))){  // || OrdItemList[j].Product2.ERP7__Is_Kit__c    //.Quantity     
    //                     console.log('here222');
    //                     if(elem){
    //                         console.log('here1:+ elem.length +',elem.length);
    //                         if(elem.length){
    //                             console.log('here2');
    //                             elem[j].set("v.checked",true);        
    //                         }else{
    //                             console.log('here3');
    //                             elem.set("v.checked",true);
    //                         }   
    //                     }         
    //                     console.log('here pushed');
    //                     SelectedSoliListDum.push(OrdItemList[j]); 
    //                 }else{
    //                     console.log('here notpushed');
    //                 }
    //             }   
    //             else{
    //                 if(elem){
    //                     if(elem.length){
    //                         elem[j].set("v.checked",false);        
    //                     }else elem.set("v.checked",false);        
    //                 }
    //                 SelectedSoliListDum=[];
    //             }
    //         }
    //     }
    //         else if(POItemList.length > 0){
    //             for(var j=0; j<POItemList.length; j++){ 
    //                 if(isSelect==true){ 
    //                     if(POItemList[j].ERP7__Active__c==true){          
    //                         if(elem){
    //                             if(elem.length){
    //                                 elem[j].set("v.checked",true);        
    //                             }else elem.set("v.checked",true);        
    //                         }                                                     
    //                         SelectedSoliListDum.push(POItemList[j]); 
    //                     }          
    //                 }   
    //                 else{
    //                     if(elem){
    //                         if(elem.length){
    //                             elem[j].set("v.checked",false);        
    //                         }else elem.set("v.checked",false);        
    //                     }
    //                     SelectedSoliListDum=[];
    //                 }
    //             }
    //         }
    //     console.log('SelectedSoliListDum ~>'+SelectedSoliListDum.length);
    //     component.set("v.SelectedSoliList",SelectedSoliListDum); //SelectedSoliList
        
    //     if(isSelect && SelectedSoliListDum.length > 0) $A.util.removeClass(component.find("cnvrtLogBtnId"),'a_disabled');
    //     else $A.util.addClass(component.find("cnvrtLogBtnId"),'a_disabled');                               
    // },
    
    selectAllSoli: function(component, event, helper) {
        var isSelect = event.getSource().get("v.checked");
        console.log('isSelect : ', isSelect);
        
        var SelectedSoliListDum = [];
        var SoliList = component.get("v.SoliList");
        var OrdItemList = component.get('v.OrdItemList');
        var POItemList = component.get('v.POItemList');

        // --- 1. Handle Sales Order Line Items (SOLI) ---
        if (SoliList && SoliList.length > 0) {
            console.log('in SoliList');
            
            for (var j = 0; j < SoliList.length; j++) {
                if (isSelect) {
                    var isEligible = SoliList[j].ERP7__Active__c == true && !SoliList[j].IsExploded;
                    
                    // Specific Kit Logic if needed (matches your HTML logic)
                    if(SoliList[j].ERP7__Is_Kit__c && SoliList[j].AllowKit == 'Allow' &&  SoliList[j].ERP7__Remaining_Quantity__c > 0){
                        isEligible = true;
                    }

                    if (isEligible) {
                        SoliList[j].checked = true; // Update Data Model
                        SelectedSoliListDum.push(SoliList[j]);
                    } else {
                        SoliList[j].checked = false;
                    }
                } else {
                    // Deselect All
                    SoliList[j].checked = false; // Update Data Model
                }
            }
            // Trigger UI Update via Data Binding
            component.set("v.SoliList", SoliList);
        }
        
        // --- 2. Handle Standard Order Items ---
        else if (OrdItemList && OrdItemList.length > 0) {
            console.log('in OrdItemList');
            
            for (var j = 0; j < OrdItemList.length; j++) {
                if (isSelect) {
                    // Complex eligibility check (Active, Stock vs Remaining, Kit Allowed)
                    if (((OrdItemList[j].ERP7__Remaining_Quantity__c <= OrdItemList[j].ERP7__Reserved_Quantity__c &&
                          OrdItemList[j].ERP7__Remaining_Quantity__c > 0 &&
                          OrdItemList[j].ERP7__Remaining_Quantity__c <= OrdItemList[j].Quantity) && OrdItemList[j].ERP7__Active__c == true && !OrdItemList[j].IsExploded
                         )) {
                        
                        isEligible = true;
                    } 
                    if(OrdItemList[j].Product2.ERP7__Is_Kit__c && OrdItemList[j].AllowKit != 'Allow'){
                        isEligible = false;
                    }else if(OrdItemList[j].Product2.ERP7__Is_Kit__c && OrdItemList[j].AllowKit == 'Allow' && OrdItemList[j].ERP7__Remaining_Quantity__c > 0){
                        isEligible = true;
                    }
                    if(isEligible){
                        OrdItemList[j].checked = true; // Update Data Model
                        SelectedSoliListDum.push(OrdItemList[j]);
                    }else{
                        OrdItemList[j].checked = false;
                    }
                } else {
                    OrdItemList[j].checked = false;
                }
            }
            component.set("v.OrdItemList", OrdItemList);
        }
        
        // --- 3. Handle Purchase Order Items ---
        else if (POItemList && POItemList.length > 0) {
            for (var j = 0; j < POItemList.length; j++) {
                if (isSelect) {
                    if (POItemList[j].ERP7__Active__c == true) {
                        POItemList[j].checked = true; // Update Data Model
                        SelectedSoliListDum.push(POItemList[j]);
                    } else {
                        POItemList[j].checked = false;
                    }
                } else {
                    POItemList[j].checked = false;
                }
            }
            component.set("v.POItemList", POItemList);
        }

        console.log('SelectedSoliListDum size ~>' + SelectedSoliListDum.length);
        component.set("v.SelectedSoliList", SelectedSoliListDum);

        // Enable/Disable the main action button
        if (isSelect && SelectedSoliListDum.length > 0) {
            $A.util.removeClass(component.find("cnvrtLogBtnId"), 'a_disabled');
        } else {
            $A.util.addClass(component.find("cnvrtLogBtnId"), 'a_disabled');
        }
    },

    handleQtyChange: function(component, event, helper) {

        var inputCmp = event.getSource();
        var val = inputCmp.get("v.value");

        // --- FIX 1: STOP PREMATURE TOAST ---
        // If the field is cleared (empty or NaN), clear errors and stop processing.
        if (val === "" || val === null || isNaN(val)) {
            inputCmp.setCustomValidity(""); // Clear native error
            inputCmp.reportValidity();      // Update UI
            return; 
        }

        var params = event.getSource().get("v.name").split('_');
        var index = parseInt(params[0]);
        var type = params[1]; // 'SOLI' or 'ORD'
        var userInput = parseFloat(event.getSource().get("v.value"));
        
        var item;
        var listName;
        
        if (type === 'SOLI') {
            item = component.get("v.SoliList")[index];
            listName = "v.SoliList";
        } else {
            item = component.get("v.OrdItemList")[index];
            listName = "v.OrdItemList";
        }

        var isKit = (type === 'SOLI') ? item.ERP7__Is_Kit__c : (item.Product2 && item.Product2.ERP7__Is_Kit__c);
        var parentTotalQty = (type === 'SOLI') ? item.ERP7__Quantity__c : item.Quantity;
        var parentLogisticQty = item.ERP7__Logistic_Quantity__c || 0;
        var maxAllowedQty = 0;
        var kitStockAvailable = true; // Default true, set to false if BOM check fails

        // --- KIT LOGIC ---
        if (isKit) {
            // 1. Calculate the "Ratio" (Total BOM Qty per 1 Parent Kit)
            // We sum up the Total Required Qty of all BOMs for this line and divide by the Parent Order Qty.
            var bomItems = component.get("v.BomItemList");
            var totalBomQtyForOrder = 0;
            
            for (var j = 0; j < bomItems.length; j++) {
                // Match BOM to Parent
                if ((type === 'SOLI' && bomItems[j].OrderProdId === item.Id) || 
                    (type === 'ORD' && bomItems[j].OrderProdId === item.Id)) {
                    totalBomQtyForOrder += (bomItems[j].Bom.ERP7__Quantity__c || 0);
                }
            }

            // Ratio: How many total BOM items make up ONE Kit unit?
            // If Parent Qty is 2 and Total BOM Qty is 6 (2+4), then Ratio is 3.
            var bomPerKitRatio = (parentTotalQty > 0) ? (totalBomQtyForOrder / parentTotalQty) : 0;

            // 2. Determine how many Kits were ALREADY shipped
            // Formula: Parent Logistic Qty (Sum of BOMs shipped) / Ratio
            var previouslyShippedKits = 0;
            if (bomPerKitRatio > 0) {
                previouslyShippedKits = parentLogisticQty / bomPerKitRatio;
            }

            // 3. Max Remaining = Original Qty - Previously Shipped
            // Use Math.ceil/floor tolerance or simple rounding to handle floating point issues
            maxAllowedQty = parentTotalQty - previouslyShippedKits;
            // Round to 2 decimals to avoid floating point weirdness (e.g. 1.999999)
            maxAllowedQty = Math.round(maxAllowedQty * 100) / 100;

            // 2. DYNAMIC STOCK CHECK
            // Check if we have enough stock for the *Entered Quantity*
            if(userInput > 0) {
                for (var j = 0; j < bomItems.length; j++) {
                    var b = bomItems[j];
                    if ((type === 'SOLI' && b.OrderProdId === item.Id) || 
                        (type === 'ORD' && b.OrderProdId === item.Id)) {
                        
                        // How many of THIS component do we need for 1 parent unit?
                        var componentApexQty = b.Bom.ERP7__Quantity__c || 0;
                        var componentUnitRatio = (parentTotalQty > 0) ? (componentApexQty / parentTotalQty) : 0;
                        
                        // Required Stock = Unit Ratio * User Input
                        var requiredStock = componentUnitRatio * userInput;
                        var availableStock = b.stock || 0;
                        
                        if (availableStock < requiredStock) {
                            kitStockAvailable = false;
                            break; // Fail fast if one component is missing
                        }
                    }
                }
            }
        } 
        // --- STANDARD PRODUCT LOGIC ---
        else {
            // Simple Subtraction
            maxAllowedQty = parentTotalQty - parentLogisticQty;
        }

        // --- VALIDATION & UI UPDATE ---
        var isValid = true;
        var errorMsg = "";

        if (userInput < 0) {
            isValid = false;
            errorMsg = $A.get('$Label.c.Invalid_Quantity');
        } 
        else if (userInput > maxAllowedQty) {
            isValid = false;
            errorMsg = $A.get('$Label.c.Given_quantity_is_not_available'); 
        }
        else if (isKit && !kitStockAvailable) {
            // New Validation for Kits
            isValid = false; 
            // We treat this differently: We don't show a toast error immediately, 
            // instead we disable the row (AllowKit = 'Not-Allowed').
            // But we can show a specific message or just rely on the button disabling.
            // Let's mark it invalid so the code below handles disabling.
        }

        // STANDARD ERROR HANDLING (Toast/Highlight)
        if (!isValid) {
            if(userInput < 0 || userInput > maxAllowedQty) {
                sforce.one.showToast({
                    "title": "Error",
                    "message": errorMsg + " (Max: " + maxAllowedQty + ")",
                    "type": "error"
                });
                
                // Use Standard SLDS Error State (Fixes Red Box Glitch)
                inputCmp.setCustomValidity(errorMsg); 
                inputCmp.reportValidity(); 
            }
        } else {
            // Clear Error
            inputCmp.setCustomValidity(""); 
            inputCmp.reportValidity();
        }

        // UPDATE ITEM STATUS
        if(isKit) {
            if(isValid && kitStockAvailable) {
                item.AllowKit = 'Allow';
            } else {
                item.AllowKit = 'Not-Allowed'; // This Disables the row button in UI
                if(!kitStockAvailable && userInput > 0 && userInput <= maxAllowedQty) {
                     // Only show toast if quantity was technically within range but stock failed
                     // Use a debounce or just set exceptionError to avoid spamming toasts while typing
                     component.set("v.exceptionError", "Insufficient stock for Kit components for the entered quantity.");
                }
            }
        }
        
        // REFRESH LIST TO UPDATE BUTTON STATE (AllowKit)
        component.set(listName, component.get(listName));
    },

  convertToLogistic: function(component, event, helper) {
    try {
        console.log('convertToLogistic called');
        component.set('v.LLIList', []);
        var SelectedSoliList = component.get('v.SelectedSoliList');  
        console.log('SelectedSoliList ~>', SelectedSoliList.length);
        console.log('SelectedSoliList details:', JSON.stringify(SelectedSoliList));
        
        var SoliList = component.get("v.SoliList"); 
        var OrdItemList = component.get('v.OrdItemList');
        var POItemList = component.get('v.POItemList');
        var BomItemList = component.get("v.BomItemList");
        
        if (SelectedSoliList && SelectedSoliList.length > 0) {
            var LLIList = [];
            var globalCounter = 1;
            console.log('BomItemList:', BomItemList);

            // =================================================================
            // 1. GLOBAL VALIDATION LOOP
            // =================================================================
            for (let x = 0; x < SelectedSoliList.length; x++) {
                var item = SelectedSoliList[x];
                if (!item || typeof item === 'string' || item.IsExploded) continue;

                var isKit = false;
                var parentTotalQty = 0;
                var parentLogisticQty = 0;
                var itemName = '';

                // Resolve Item Type and Properties
                if (SoliList && SoliList.length > 0) {
                    isKit = item.ERP7__Is_Kit__c;
                    parentTotalQty = item.ERP7__Quantity__c || 0;
                    parentLogisticQty = item.ERP7__Logistic_Quantity__c || 0;
                    itemName = item.Name || 'SOLI';
                } else if (OrdItemList && OrdItemList.length > 0) {
                    isKit = item.Product2 && item.Product2.ERP7__Is_Kit__c;
                    parentTotalQty = item.Quantity || 0;
                    parentLogisticQty = item.ERP7__Logistic_Quantity__c || 0;
                    itemName = item.Product2 ? item.Product2.Name : 'Order Item';
                } else if (POItemList && POItemList.length > 0) {
                    // PO Logic (Simplified for validation)
                    parentTotalQty = item.ERP7__Quantity__c || 0;
                    parentLogisticQty = item.ERP7__Logistic_Quantity__c || 0;
                    itemName = item.Name || 'PO Item';
                }

                var userEnteredQty = parseFloat(item.ERP7__Remaining_Quantity__c) || 0;

                // A. Validate Input Range
                var maxQty = 0;
                if (isKit) {
                    // Kit Max Calculation (Same as handleQtyChange)
                    var totalBomQtyForOrder = 0;
                    for (var j = 0; j < BomItemList.length; j++) {
                        if ((SoliList.length > 0 && BomItemList[j].OrderProdId === item.Id) || 
                            (OrdItemList.length > 0 && BomItemList[j].OrderProdId === item.Id)) {
                            totalBomQtyForOrder += (BomItemList[j].Bom.ERP7__Quantity__c || 0);
                        }
                    }
                    var bomPerKitRatio = (parentTotalQty > 0) ? (totalBomQtyForOrder / parentTotalQty) : 0;
                    var previouslyShippedKits = (bomPerKitRatio > 0) ? (parentLogisticQty / bomPerKitRatio) : 0;
                    maxQty = Math.round((parentTotalQty - previouslyShippedKits) * 100) / 100;
                } else {
                    maxQty = parentTotalQty - parentLogisticQty;
                }

                if (userEnteredQty <= 0) {
                    // helper toast not working 
                    // helper.showToast('dismissible', 'Error', 'error', 'Invalid Quantity for ' + itemName + '. Must be greater than 0.', component);

                    sforce.one.showToast({
                        "title": "Error",
                        "message": 'Invalid Quantity for ' + itemName + '. Must be greater than 0.',
                        "type": "error"
                    });
                    return; // Stop Process
                }
                if (userEnteredQty > maxQty) {
                    // helper.showToast('dismissible', 'Error', 'error', 'Quantity for ' + itemName + ' cannot exceed ' + maxQty + '.', component);

                    sforce.one.showToast({
                        "title": "Error",
                        "message": 'Quantity for ' + itemName + ' cannot exceed ' + maxQty + '.',
                        "type": "error"
                    });
                    return; // Stop Process
                }

                // B. Validate Stock Availability (Especially for Kits)
                if (isKit) {
                    for (var j = 0; j < BomItemList.length; j++) {
                        var b = BomItemList[j];
                        if ((SoliList.length > 0 && b.OrderProdId === item.Id) || 
                            (OrdItemList.length > 0 && b.OrderProdId === item.Id)) {
                            
                            var componentApexQty = b.Bom.ERP7__Quantity__c || 0;
                            var componentUnitRatio = (parentTotalQty > 0) ? (componentApexQty / parentTotalQty) : 0;
                            var requiredStock = componentUnitRatio * userEnteredQty;
                            
                            if ((b.stock || 0) < requiredStock) {
                                // helper.showToast('dismissible', 'Error', 'error', 'Insufficient stock for Kit "' + itemName + '". Check component availability.', component);
                                
                                sforce.one.showToast({
                                    "title": "Error",
                                    "message": 'Insufficient stock for Kit "' + itemName + '". Check component availability.',
                                    "type": "error"
                                });
                                return; // Stop Process
                            }
                        }
                    }
                }
            }
            
            for (let x = 0; x < SelectedSoliList.length; x++) {
                var currentItem = SelectedSoliList[x];
                
                // Skip if item is just an ID string (not a full object)
                if (!currentItem || typeof currentItem === 'string' || currentItem.IsExploded) {
                    console.log('Skipping string ID item:', currentItem);
                    continue;
                }
                
                if (!currentItem) {
                    console.log('Skipping undefined item at index:', x);
                    continue;
                }
                
                console.log('Processing item:', currentItem.Id, 'IsExploded:', currentItem.IsExploded);
                
                // Skip exploded items as they should be handled automatically
                if (currentItem.IsExploded) {
                    console.log('Skipping exploded item:', currentItem.Id);
                    continue;
                }
                
                // if (SoliList && SoliList.length > 0 && currentItem.ERP7__Product__c) {
                //     console.log('SoliList processing');
                //     var obj = { 
                //         Name: currentItem.Name || 'SOLI-Logistic',
                //         ERP7__Product__c: currentItem.ERP7__Product__c,
                //         ERP7__Quantity__c: (currentItem.ERP7__Quantity__c || 0) - (currentItem.ERP7__Logistic_Quantity__c || 0),
                //         ERP7__Price_Product__c: currentItem.ERP7__Base_Price__c || 0,                  
                //         ERP7__Sales_Order_Line_Item__c: currentItem.Id,
                //         ERP7__Logistic__c: ''
                //     };
                    
                //     if (currentItem.ERP7__Product__r) {
                //         obj.ERP7__Product__r = {
                //             'Id': currentItem.ERP7__Product__c,
                //             'Name': currentItem.ERP7__Product__r.Name || 'Unknown Product'
                //         };
                //     }
                //     LLIList.push(obj);
                // }
                if (SoliList && SoliList.length > 0 && currentItem.ERP7__Product__c) {
                    console.log('SoliList processing');
                    
                    // --- NEW KIT LOGIC FOR SOLI ---
                    if (currentItem.ERP7__Is_Kit__c) {
                        console.log('Processing Kit SOLI');
                        var kitComponentsAdded = false;

                        // 1. Get Quantities for Ratio Calculation
                        var parentTotalQty = currentItem.ERP7__Quantity__c || 1; 
                        var userEnteredQty = parseFloat(currentItem.ERP7__Remaining_Quantity__c) || 0;
                                            
                        if (BomItemList && BomItemList.length > 0) {
                            for (var j = 0; j < BomItemList.length; j++) {
                                var bomItem = BomItemList[j];
                                // Match BOM to this specific SOLI using the OrderProdId mapped in Apex
                                if (bomItem && bomItem.Bom && 
                                    bomItem.Bom.ERP7__BOM_Product__c === currentItem.ERP7__Product__c && 
                                    bomItem.OrderProdId === currentItem.Id) {
                                    
                                    var componentName = 'Kit-Component';
                                    if (bomItem.Bom.ERP7__BOM_Component__r && bomItem.Bom.ERP7__BOM_Component__r.Name) {
                                        componentName = bomItem.Bom.ERP7__BOM_Component__r.Name;
                                    }

                                    // 2. Dynamic Calculation
                                    var apexTotalBomQty = bomItem.Bom.ERP7__Quantity__c || 0; // Total BOM qty for the full order line
                                    var unitBomQty = (parentTotalQty > 0) ? (apexTotalBomQty / parentTotalQty) : 0; // BOM qty per 1 parent unit
                                    var calculatedQty = unitBomQty * userEnteredQty; // BOM qty for the Remaining/Selected parent units
                                    
                                    var obj = { 
                                        Name: componentName + '-LogisticLine-' + (globalCounter++),
                                        ERP7__Product__c: bomItem.Bom.ERP7__BOM_Component__c,
                                        ERP7__Quantity__c: calculatedQty, // Quantity is already calc in Apex based on Parent Qty
                                        ERP7__Price_Product__c: (bomItem.pbe ? bomItem.pbe.UnitPrice : 0),                  
                                        ERP7__Sales_Order_Line_Item__c: currentItem.Id, // Link component back to Parent SOLI
                                        ERP7__Logistic__c: '',
                                        isKitComponent: true
                                    };
                                    
                                    if (bomItem.Bom.ERP7__BOM_Component__r) {
                                        obj.ERP7__Product__r = {
                                            'Id': bomItem.Bom.ERP7__BOM_Component__c,
                                            'Name': componentName
                                        };
                                    }
                                    LLIList.push(obj);
                                    kitComponentsAdded = true;
                                }
                            }
                        }
                        if (!kitComponentsAdded) console.log('No kit components found for SOLI:', currentItem.Id);
                    } 
                    // --- STANDARD SOLI LOGIC (Existing) ---
                    else {
                        var obj = { 
                            Name: (currentItem.Name || 'SOLI') + '-LogisticLine-' + (globalCounter++),
                            ERP7__Product__c: currentItem.ERP7__Product__c,
                            // ERP7__Quantity__c: (currentItem.ERP7__Quantity__c || 0) - (currentItem.ERP7__Logistic_Quantity__c || 0),
                            // CHANGE: Use the User Entered Remaining Quantity directly
                            ERP7__Quantity__c: parseFloat(currentItem.ERP7__Remaining_Quantity__c) || 0,
                            ERP7__Price_Product__c: currentItem.ERP7__Price_Product__c || 0,                  
                            ERP7__Sales_Order_Line_Item__c: currentItem.Id,
                            ERP7__Logistic__c: ''
                        };
                        
                        if (currentItem.ERP7__Product__r) {
                            obj.ERP7__Product__r = {
                                'Id': currentItem.ERP7__Product__c,
                                'Name': currentItem.ERP7__Product__r.Name || 'Unknown Product'
                            };
                        }
                        LLIList.push(obj);
                    }
                }
                else if (OrdItemList && OrdItemList.length > 0) {
                    console.log('OrdItemList processing');
                    
                    // Check if this is a kit product with proper structure
                    var isKitProduct = currentItem.Product2 && currentItem.Product2.ERP7__Is_Kit__c;
                    console.log('Is kit product:', isKitProduct, 'Product2 exists:', !!currentItem.Product2);
                    
                    if (isKitProduct) {
                        console.log('Processing kit product');
                        var kitComponentsAdded = false;

                        // 1. Get Quantities for Ratio Calculation
                        var parentTotalQty = currentItem.Quantity || 1;
                        var userEnteredQty = parseFloat(currentItem.ERP7__Remaining_Quantity__c) || 0;
                        
                        if (BomItemList && BomItemList.length > 0) {
                            for (var j = 0; j < BomItemList.length; j++) {
                                var bomItem = BomItemList[j];
                                if (bomItem && bomItem.Bom && bomItem.Bom.ERP7__BOM_Product__c === currentItem.Product2Id && 
                                    bomItem.OrderProdId === currentItem.Id) {
                                    
                                    var componentName = 'Kit-Component';
                                    if (bomItem.Bom.ERP7__BOM_Component__r && bomItem.Bom.ERP7__BOM_Component__r.Name) {
                                        componentName = bomItem.Bom.ERP7__BOM_Component__r.Name;
                                    }
                                    
                                    console.log('Adding kit component:', componentName);

                                    // 2. Dynamic Calculation
                                    var apexTotalBomQty = bomItem.Bom.ERP7__Quantity__c || 0;
                                    var unitBomQty = (parentTotalQty > 0) ? (apexTotalBomQty / parentTotalQty) : 0;
                                    var calculatedQty = unitBomQty * userEnteredQty;
                                    
                                    var obj = { 
                                        Name: componentName + '-LogisticLine-' + (globalCounter++),
                                        ERP7__Product__c: bomItem.Bom.ERP7__BOM_Component__c,
                                        ERP7__Quantity__c: calculatedQty,
                                        ERP7__Price_Product__c: (bomItem.pbe ? bomItem.pbe.UnitPrice : 0),                  
                                        ERP7__Order_Product__c: currentItem.Id,
                                        ERP7__Logistic__c: '',
                                        isKitComponent: true
                                    };
                                    
                                    if (bomItem.Bom.ERP7__BOM_Component__r) {
                                        obj.ERP7__Product__r = {
                                            'Id': bomItem.Bom.ERP7__BOM_Component__c,
                                            'Name': componentName
                                        };
                                    }
                                    LLIList.push(obj);
                                    kitComponentsAdded = true;
                                }
                            }
                        }
                        
                        if (!kitComponentsAdded) {
                            console.log('No kit components found for product:', currentItem.Product2Id);
                        }
                    }
                    else {
                        console.log('Processing non-kit product');
                        
                        // Safe access to product name
                        var productName = 'Unknown Product';
                        if (currentItem.Product2 && currentItem.Product2.Name) {
                            productName = currentItem.Product2.Name;
                        } else if (currentItem.Product2Id) {
                            productName = 'Product-' + currentItem.Product2Id;
                        }
                        
                        // Calculate quantity safely
                        var quantity = 0;
                        if (currentItem.ERP7__Remaining_Quantity__c > 0) {
                            quantity = currentItem.ERP7__Remaining_Quantity__c;
                        } else {
                            quantity = (currentItem.Quantity || 0) - (currentItem.ERP7__Logistic_Quantity__c || 0);
                        }
                        
                        // Only create LLI if we have a valid Product2Id
                        if (currentItem.Product2Id) {
                            var obj = { 
                                Name: productName + '-LogisticLine-' + (globalCounter++),
                                ERP7__Product__c: currentItem.Product2Id,
                                ERP7__Quantity__c: quantity,
                                ERP7__Price_Product__c: currentItem.UnitPrice || 0,                  
                                ERP7__Order_Product__c: currentItem.Id,
                                ERP7__Logistic__c: ''
                            };
                            
                            if (currentItem.Product2) {
                                obj.ERP7__Product__r = {
                                    'Id': currentItem.Product2Id,
                                    'Name': productName
                                };
                            }
                            LLIList.push(obj);
                        } else {
                            console.log('Skipping item without Product2Id:', currentItem.Id);
                        }
                    }
                }
                else if (POItemList && POItemList.length > 0 && currentItem.ERP7__Product__c) {
                    console.log('POItemList processing');
                    
                    // Track inventory check for PO items with safe access
                    var trackInventory = true;
                    if (currentItem.ERP7__Product__r) {
                        trackInventory = !(currentItem.ERP7__Product__r.ERP7__Track_Inventory__c === false || 
                                         currentItem.ERP7__Product__r.ERP7__Track_Inventory__c === null);
                    }
                    
                    if (!trackInventory) {
                        var productName = 'Unknown Product';
                        if (currentItem.ERP7__Product__r && currentItem.ERP7__Product__r.Name) {
                            productName = currentItem.ERP7__Product__r.Name;
                        }
                        component.set("v.exceptionError", 'Track Inventory is Disabled for product "' + productName + '". Logistic cannot be created.');
                        return;
                    }

                    var quantity = currentItem.ERP7__Quantity__c < currentItem.ERP7__Remaining_Quantity__c ?
                                  (currentItem.ERP7__Quantity__c || 0) - (currentItem.ERP7__Logistic_Quantity__c || 0) :
                                  (currentItem.ERP7__Remaining_Quantity__c || 0) - (currentItem.ERP7__Logistic_Quantity__c || 0);

                    var obj = { 
                        Name: (currentItem.Name || 'PO') + '-LogisticLine-' + (globalCounter++),
                        ERP7__Product__c: currentItem.ERP7__Product__c,
                        ERP7__Quantity__c: quantity,
                        ERP7__Price_Product__c: currentItem.ERP7__Unit_Price__c || 0,                  
                        ERP7__Purchase_Line_Items__c: currentItem.Id,
                        ERP7__Logistic__c: ''
                    };
                    
                    if (currentItem.ERP7__Product__r) {
                        obj.ERP7__Product__r = {
                            'Id': currentItem.ERP7__Product__c,
                            'Name': currentItem.ERP7__Product__r.Name || 'Unknown Product'
                        };
                    }
                    LLIList.push(obj);
                }
                else {
                    console.log('Item does not match any known type, skipping:', currentItem.Id);
                }
            }
            
            console.log('Final LLIList length:', LLIList.length);
            console.log('Final LLIList:', JSON.stringify(LLIList));
            component.set("v.LLIList", LLIList);
            
            // Only switch to log tab if we actually have items to process
            if (LLIList.length > 0) {
                component.set("v.selectedTab", 'log');
                console.log('Switched to log tab with', LLIList.length, 'items');
                
                // Set logistic name
                var lognum = 1;
                if (component.get("v.LogisticsExisting") && component.get("v.LogisticsExisting").length) {
                    lognum = parseInt(component.get("v.LogisticsExisting").length) + 1;
                }
                
                if (SoliList && SoliList.length > 0 && SoliList[0] && SoliList[0].ERP7__Sales_Order__r && SoliList[0].ERP7__Sales_Order__r.Name) {
                    var logName = SoliList[0].ERP7__Sales_Order__r.Name + '-Logistic-' + lognum;
                    component.set("v.Logistic.Name", logName);
                } else if (OrdItemList && OrdItemList.length > 0 && OrdItemList[0] && OrdItemList[0].Order && OrdItemList[0].Order.Name) {
                    var logName = OrdItemList[0].Order.Name + '-Logistic-' + lognum;
                    component.set("v.Logistic.Name", logName);
                } else if (POItemList && POItemList.length > 0 && POItemList[0] && POItemList[0].ERP7__Purchase_Orders__r && POItemList[0].ERP7__Purchase_Orders__r.Name) {
                    var logName = POItemList[0].ERP7__Purchase_Orders__r.Name + '-Logistic-' + lognum;
                    component.set("v.Logistic.Name", logName);
                } else {
                    component.set("v.Logistic.Name", 'Logistic-' + lognum);
                }
            } else {
                console.log('No items to process - not switching tabs');
                sforce.one.showToast({
                    "title": $A.get('$Label.c.warning_UserAvailabilities'),
                    "message": "No valid items selected for logistic creation. Exploded items are processed automatically.",
                    "type": "warning"
                });
            }
        }
        else {
            sforce.one.showToast({
                "title": $A.get('$Label.c.warning_UserAvailabilities'),
                "message": $A.get('$Label.c.No_Item_Selected'),
                "type": "warning"
            });
        }
    }
    catch(ex) {
        console.log('Error in convertToLogistic:', ex);
        var errorMessage = 'Error creating logistic: ';
        if (ex.message) {
            errorMessage += ex.message;
        } else {
            errorMessage += 'Unknown error occurred';
        }
        component.set("v.exceptionError", errorMessage);
    } 
},
    
    singleConvertToLogistic: function(component, event, helper) {  
        try{
            
            console.log('singleConvertToLogistic called');
            component.set('v.LLIList',[]);
            var index = event.currentTarget.dataset.service;
            console.log('index : ',index);
            var soliListForCom=[];soliListForCom=component.get("v.SoliList");
            var OrderListListForCom=[];OrderListListForCom=component.get("v.OrdItemList");
            var POListForCom=[];POListForCom=component.get("v.POItemList");
            var SoliList=[]; SoliList= component.get("v.SoliList"); 
            
            var BomItemList=[];BomItemList =component.get("v.BomItemList");
            var ordItemListDum= [];
            
            var ordItemList=[]; ordItemList = component.get("v.OrdItemList");
            
            var POItemList=[]; POItemList=component.get("v.POItemList");   
            
            /* for(var i in ordItemList){
                if(ordItemList[i].Product2.ERP7__Is_Kit__c){
                    
                    for(var j in BomItemList){
                        if(ordItemList[i].Product2Id == BomItemList[j].Bom.ERP7__BOM_Product__c ){
                            
                            ordItemListDum[j].Name = BomItemList[j].Bom.ERP7__BOM_Component__c.Name;
                            ordItemListDum[j].Product2.Id = BomItemList[j].Bom.ERP7__BOM_Component__r.Id;
                            ordItemListDum[j].Product2      = BomItemList[j].Bom.ERP7__BOM_Component__c;
                            ordItemListDum[j].ERP7__Remaining_Quantity__c = 1;
                            ordItemListDum[j].UnitPrice     = 0;
                            ordItemListDum[j].Id            = ordItemList[i].Id;
                        }
                    }
                }
            }*/
            
            
            
            var selectedSoli=[];//SoliList[index];
            if(SoliList.length > 0){
                selectedSoli=SoliList[index];	
            }else if(ordItemList.length > 0){       
                selectedSoli=ordItemList[index];
            }
            else if(POItemList.length > 0){
                selectedSoli=POItemList[index];
            }

            // =================================================================
            // 1. VALIDATION
            // =================================================================
            var isKit = false;
            var parentTotalQty = 0;
            var parentLogisticQty = 0;
            var itemName = '';

            if (SoliList.length > 0) {
                isKit = selectedSoli.ERP7__Is_Kit__c;
                parentTotalQty = selectedSoli.ERP7__Quantity__c;
                parentLogisticQty = selectedSoli.ERP7__Logistic_Quantity__c;
                itemName = selectedSoli.Name;
            } else if (ordItemList.length > 0) {
                isKit = selectedSoli.Product2.ERP7__Is_Kit__c;
                parentTotalQty = selectedSoli.Quantity;
                parentLogisticQty = selectedSoli.ERP7__Logistic_Quantity__c;
                itemName = selectedSoli.Product2.Name;
            }

            // Only validate input for Sales/Orders (PO usually doesn't have user input field)
            if (SoliList.length > 0 || ordItemList.length > 0) {
                var userEnteredQty = parseFloat(selectedSoli.ERP7__Remaining_Quantity__c) || 0;
                var maxQty = 0;

                if (isKit) {
                    var totalBomQtyForOrder = 0;
                    for (var j = 0; j < BomItemList.length; j++) {
                        if ((SoliList.length > 0 && BomItemList[j].OrderProdId === selectedSoli.Id) || 
                            (ordItemList.length > 0 && BomItemList[j].OrderProdId === selectedSoli.Id)) {
                            totalBomQtyForOrder += (BomItemList[j].Bom.ERP7__Quantity__c || 0);
                        }
                    }
                    var bomPerKitRatio = (parentTotalQty > 0) ? (totalBomQtyForOrder / parentTotalQty) : 0;
                    var previouslyShippedKits = (bomPerKitRatio > 0) ? (parentLogisticQty / bomPerKitRatio) : 0;
                    maxQty = Math.round((parentTotalQty - previouslyShippedKits) * 100) / 100;
                } else {
                    maxQty = parentTotalQty - parentLogisticQty;
                }

                if (userEnteredQty <= 0) {
                    // helper.showToast('dismissible', 'Error', 'error', 'Invalid Quantity. Must be greater than 0.', component);

                    sforce.one.showToast({
                        "title": "Error",
                        "message": 'Invalid Quantity. Must be greater than 0.',
                        "type": "error"
                    });
                    return;
                }
                if (userEnteredQty > maxQty) {
                    // helper.showToast('dismissible', 'Error', 'error', 'Quantity cannot exceed ' + maxQty + '.', component);
                    sforce.one.showToast({
                        "title": "Error",
                        "message": 'Quantity cannot exceed ' + maxQty + '.',
                        "type": "error"
                    });
                    return;
                }

                // Check Stock for Kits
                if (isKit) {
                    for (var j = 0; j < BomItemList.length; j++) {
                        var b = BomItemList[j];
                        if ((SoliList.length > 0 && b.OrderProdId === selectedSoli.Id) || 
                            (ordItemList.length > 0 && b.OrderProdId === selectedSoli.Id)) {
                            
                            var componentApexQty = b.Bom.ERP7__Quantity__c || 0;
                            var componentUnitRatio = (parentTotalQty > 0) ? (componentApexQty / parentTotalQty) : 0;
                            var requiredStock = componentUnitRatio * userEnteredQty;
                            
                            if ((b.stock || 0) < requiredStock) {
                                // helper.showToast('dismissible', 'Error', 'error', 'Insufficient stock for Kit components.', component);

                                sforce.one.showToast({
                                    "title": "Error",
                                    "message": 'Insufficient stock for Kit components.',
                                    "type": "error"
                                });
                                return;
                            }
                        }
                    }
                }
            }
            
            var LLIList=component.get('v.LLIList'); //LLIList=[];
            var LLIListMore=[]; 
            var globalCounter = 1;
            console.log('selectedSoli json~>'+JSON.stringify(selectedSoli));
            // if(soliListForCom.length > 0){
            //     console.log('soliListForCom inhere');
            //     var obj = { 
            //         Name:selectedSoli.Name,
            //         ERP7__Product__c:selectedSoli.ERP7__Product__c,
            //         ERP7__Quantity__c:selectedSoli.ERP7__Quantity__c-selectedSoli.ERP7__Logistic_Quantity__c,
            //         ERP7__Price_Product__c:selectedSoli.ERP7__Base_Price__c,                                     
            //         ERP7__Sales_Order_Line_Item__c:selectedSoli.Id,   
            //         ERP7__Logistic__c:''    
            //     };
            //     obj.ERP7__Product__r={
            //         'Id':selectedSoli.ERP7__Product__c,
            //         'Name':selectedSoli.ERP7__Product__r.Name 
            //     };
            //     LLIListMore.push(obj); //ERP7__Quantity__c
            // }
            if(soliListForCom.length > 0){
                console.log('soliListForCom inhere');
                
                // --- NEW KIT LOGIC FOR SINGLE SOLI ---
                if(selectedSoli.ERP7__Is_Kit__c){
                    console.log('Processing Single Kit SOLI');

                    var parentTotalQty = selectedSoli.ERP7__Quantity__c || 1;
                    var userEnteredQty = parseFloat(selectedSoli.ERP7__Remaining_Quantity__c) || 0;

                    for(var j in BomItemList){
                        // Match BOM Product to SOLI Product AND Match Reference ID to SOLI ID
                        if(selectedSoli.ERP7__Product__c == BomItemList[j].Bom.ERP7__BOM_Product__c && 
                           BomItemList[j].OrderProdId == selectedSoli.Id){
                            
                            var apexTotalBomQty = BomItemList[j].Bom.ERP7__Quantity__c || 0;
                            var unitBomQty = (parentTotalQty > 0) ? (apexTotalBomQty / parentTotalQty) : 0;
                            var calculatedQty = unitBomQty * userEnteredQty;

                            var obj = { 
                                Name: BomItemList[j].Bom.ERP7__BOM_Component__r.Name + '-LogisticLine-' + (globalCounter++),
                                ERP7__Product__c: BomItemList[j].Bom.ERP7__BOM_Component__c,
                                ERP7__Quantity__c: calculatedQty,
                                ERP7__Price_Product__c: (BomItemList[j].pbe != undefined) ? BomItemList[j].pbe.UnitPrice : 0,                  
                                ERP7__Sales_Order_Line_Item__c: selectedSoli.Id,
                                ERP7__Logistic__c: '',
                                isKitComponent: true
                            };
                            obj.ERP7__Product__r={
                                'Id': BomItemList[j].Bom.ERP7__BOM_Component__c,
                                'Name': BomItemList[j].Bom.ERP7__BOM_Component__r.Name 
                            };
                            LLIListMore.push(obj); 
                        }
                    }
                } 
                // --- STANDARD SOLI LOGIC (Existing) ---
                else {
                    var obj = { 
                        Name: (selectedSoli.ERP7__Product__r.Name || selectedSoli.Name ) +'-LogisticLine-'+(globalCounter++),
                        ERP7__Product__c: selectedSoli.ERP7__Product__c,
                        // ERP7__Quantity__c: selectedSoli.ERP7__Quantity__c - selectedSoli.ERP7__Logistic_Quantity__c,
                        ERP7__Quantity__c: parseFloat(selectedSoli.ERP7__Remaining_Quantity__c) || 0,
                        ERP7__Price_Product__c: selectedSoli.ERP7__Price_Product__c,                                     
                        ERP7__Sales_Order_Line_Item__c: selectedSoli.Id,   
                        ERP7__Logistic__c: ''    
                    };
                    obj.ERP7__Product__r = {
                        'Id': selectedSoli.ERP7__Product__c,
                        'Name': selectedSoli.ERP7__Product__r.Name 
                    };
                    LLIListMore.push(obj); 
                }
            }
            else if(OrderListListForCom.length > 0){
                console.log('OrderListListForCom inhere');
                if(selectedSoli.ERP7__Remaining_Quantity__c <= 0 || selectedSoli.ERP7__Remaining_Quantity__c > selectedSoli.Quantity){
                    component.set("v.exceptionError", $A.get('$Label.c.REMAINING_QUANTITY') +' > 0 && <= '+$A.get('$Label.c.Acc_Pay_Total_Quantity'));
                    setTimeout( function(){component.set("v.exceptionError", "");}, 5000);
                    return;
                }
                if(selectedSoli.Product2.ERP7__Is_Kit__c){
                    console.log('BomItemList : ',BomItemList);
                    var parentTotalQty = selectedSoli.Quantity || 1;
                    var userEnteredQty = parseFloat(selectedSoli.ERP7__Remaining_Quantity__c) || 0;

                    for(var j in BomItemList){
                        console.log('BomItemList[j].Bom.ERP7__BOM_Product__c : ',BomItemList[j].Bom.ERP7__BOM_Product__c);
                        console.log('BomItemList[j].OrderProdId : ',BomItemList[j].OrderProdId);
                        if(selectedSoli.Product2Id == BomItemList[j].Bom.ERP7__BOM_Product__c && BomItemList[j].OrderProdId == selectedSoli.Id){
                            console.log('in here 123');

                            var apexTotalBomQty = BomItemList[j].Bom.ERP7__Quantity__c || 0;
                            var unitBomQty = (parentTotalQty > 0) ? (apexTotalBomQty / parentTotalQty) : 0;
                            var calculatedQty = unitBomQty * userEnteredQty;
                            var obj = { 
                                Name: BomItemList[j].Bom.ERP7__BOM_Component__r.Name+'-LogisticLine-' + (globalCounter++), 
                                ERP7__Product__c:BomItemList[j].Bom.ERP7__BOM_Component__c,
                                ERP7__Quantity__c:calculatedQty,
                                ERP7__Price_Product__c: (BomItemList[j].pbe != undefined) ? BomItemList[j].pbe.UnitPrice : 0,                  
                                ERP7__Order_Product__c:selectedSoli.Id,
                                ERP7__Logistic__c:'',
                                isKitComponent: true
                            };
                            obj.ERP7__Product__r={
                                'Id':BomItemList[j].Bom.ERP7__BOM_Component__c,
                                'Name':BomItemList[j].Bom.ERP7__BOM_Component__r.Name 
                            };
                            LLIListMore.push(obj); 
                        }
                    }
                }
                else{
                    var obj = { 
                        Name:selectedSoli.Product2.Name+'-LogisticLine-'+(globalCounter++),
                        ERP7__Product__c:selectedSoli.Product2Id,
                        ERP7__Quantity__c: parseFloat(selectedSoli.ERP7__Remaining_Quantity__c) || 0, //selectedSoli.Quantity-selectedSoli.ERP7__Logistic_Quantity__c,
                        ERP7__Price_Product__c:selectedSoli.UnitPrice,                  
                        ERP7__Order_Product__c:selectedSoli.Id,
                        ERP7__Logistic__c:''
                    };
                    obj.ERP7__Product__r={
                        'Id':selectedSoli.Product2.Id,
                        'Name':selectedSoli.Product2.Name 
                    };
                    LLIListMore.push(obj); 
                }
                //ERP7__Quantity__c
                
                
                
            }
                else if(POListForCom.length > 0){
                    console.log('POListForCom inhere');
                    console.log('POListForCom ',JSON.stringify(POListForCom));
                    //var AQuantity=SelectedSoliList[x].ERP7__Quantity__c-SelectedSoliList[x].ERP7__Logistic_Quantity__c; SelectedSoliList[x].ERP7__Reserved_Quantity__c
                    console.log('selectedSoli.ERP7__Quantity__c=>',selectedSoli.ERP7__Quantity__c);
                    console.log('selectedSoli.ERP7__Logistic_Quantity__c=>',selectedSoli.ERP7__Logistic_Quantity__c);
                    console.log('selectedSoli.ERP7__Quantity__c-selectedSoli.ERP7__Logistic_Quantity__c=>',selectedSoli.ERP7__Quantity__c-selectedSoli.ERP7__Logistic_Quantity__c);
                    console.log('selectedSoli.ERP7__Remaining_Quantity__c ',selectedSoli.ERP7__Remaining_Quantity__c);
                    var obj={};
                   if (selectedSoli.ERP7__Product__r.ERP7__Track_Inventory__c === false || selectedSoli.ERP7__Product__r.ERP7__Track_Inventory__c === null) {
                        const productName = selectedSoli.ERP7__Product__r.Name || 'Unknown Product';
                        component.set("v.exceptionError", 'Track Inventory is Disabled for product "' + productName + '". Logistic cannot be created.');
                        return;
                    }


                    //updated by matheen on 7/8/25 for GIIH-686
                    if(selectedSoli.ERP7__Quantity__c < selectedSoli.ERP7__Remaining_Quantity__c){
                         obj = { 
                        Name:selectedSoli.Name + '-LogisticLine-' + (globalCounter++),
                        ERP7__Product__c:selectedSoli.ERP7__Product__c,
                        ERP7__Quantity__c:selectedSoli.ERP7__Quantity__c,
                        ERP7__Price_Product__c:selectedSoli.ERP7__Unit_Price__c,                  
                        ERP7__Purchase_Line_Items__c:selectedSoli.Id,
                        ERP7__Logistic__c:''
                     };
                    }
                     else{
                        obj = { 
                        Name:selectedSoli.Name + '-LogisticLine-' + (globalCounter++),
                        ERP7__Product__c:selectedSoli.ERP7__Product__c,
                        ERP7__Quantity__c:selectedSoli.ERP7__Remaining_Quantity__c-selectedSoli.ERP7__Logistic_Quantity__c,
                        ERP7__Price_Product__c:selectedSoli.ERP7__Unit_Price__c,                  
                        ERP7__Purchase_Line_Items__c:selectedSoli.Id,
                        ERP7__Logistic__c:''
                     };
                    }   
                    obj.ERP7__Product__r={
                        'Id':selectedSoli.ERP7__Product__c,
                        'Name':selectedSoli.ERP7__Product__r.Name 
                    };
                    LLIListMore.push(obj); //ERP7__Quantity__c
                }
            
            console.log('LLIListMore inhere pushing to LLIList');
            for(let x=0;x<LLIListMore.length;x++) LLIList.push(LLIListMore[x]); 
            
            console.log('LLIList singleConvertToLogistic json~>'+JSON.stringify(LLIList));
            component.set("v.LLIList",LLIList);
            if(component.get("v.LLIList").length > 0) component.set("v.selectedTab",'log');
            
            var lognum = parseInt(component.get("v.LogisticsExisting.length")+1);
            if(SoliList.length > 0){
                console.log('logName SoliList inhere');
                var logName = ''+SoliList[0].ERP7__Sales_Order__r.Name+'-Logistic-'+lognum;
                component.set("v.Logistic.Name",logName);
            }else if(ordItemList.length > 0){
                console.log('logName ordItemList inhere');
                var logName = ''+ordItemList[0].Order.Name+'-Logistic-'+lognum;
                component.set("v.Logistic.Name",logName);
            }else if(POItemList.length > 0){
                console.log('logName POItemList inhere');
                var logName = ''+POItemList[0].ERP7__Purchase_Orders__r.Name+'-Logistic-'+lognum;
                component.set("v.Logistic.Name",logName);
            }
        }
        catch(err){
             console.log('Raw Error: ', JSON.stringify(err));

            // Option 2: If it's a typical Error object
            if (err && err.message) {
                console.error('Error message: ', err.message);
            }

            // Option 3: General dump (might help in Aura)
            console.log('Error details:', JSON.parse(JSON.stringify(err)));
        }
        
        
    },
    
    // below code commented by abubakar to add a new validation to delete all the kit items if end product kit, 
    // getLLIDelete:function(component,event,helper){ 
    //     var deleteconfirm = confirm($A.get('$Label.c.Do_you_want_to_Delete_Item'));
    //     if(deleteconfirm){
    //         var LLIList=component.get("v.LLIList");
    //         //delete LLIList[event.currentTarget.dataset.service];
    //         console.log('LLIList bfr: ',LLIList);
    //         var index=event.currentTarget.dataset.service;
    //         LLIList.splice(index,1);
    //         //  delete LLIList[index];
            
    //         component.set("v.LLIList",LLIList);
    //         console.log('LLIList after: ',LLIList);
    //         component.set("v.reRenderLogisticTable",false);
    //         component.set("v.reRenderLogisticTable",true);
            
    //         // if(LLIList.length==1 || LLIList.length==0)  helper.getLLIDeleteSingle(component, event, helper);  
    //         if(LLIList.length==0){   
    //             component.set("v.LLIList",[]); 
    //             helper.getLLIDeleteSingle(component, event, helper);  
    //         }   
            
    //         if(component.get("v.selectedTab")=='log'){     
    //             component.set("v.selectedTab",'soli');
    //             component.set("v.selectedTab",'log');
    //         }
    //         else if(component.get("v.selectedTab")=='soli'){
    //             component.set("v.selectedTab",'log');
    //             component.set("v.selectedTab",'soli');
    //         }
            
    //     }
      
    // },

    getLLIDelete: function(component, event, helper) {
        // 1. Identify the item and its Parent ID
        var index = event.currentTarget.dataset.service;
        var LLIList = component.get("v.LLIList");
        var itemToDelete = LLIList[index];
        
        // Resolve Parent ID (Works for SOLI, OrderItem, or PO Item)
        var parentId = itemToDelete.ERP7__Sales_Order_Line_Item__c || 
                       itemToDelete.ERP7__Order_Product__c || 
                       itemToDelete.ERP7__Purchase_Line_Items__c;

        // 2. Check if this is a Kit (Multiple logistic lines sharing the same Parent ID)
        var isKit = false;
        var relatedCount = 0;
        
        if (parentId) {
            for(var i = 0; i < LLIList.length; i++) {
                var pId = LLIList[i].ERP7__Sales_Order_Line_Item__c || 
                          LLIList[i].ERP7__Order_Product__c || 
                          LLIList[i].ERP7__Purchase_Line_Items__c;
                if (pId === parentId) {
                    relatedCount++;
                }
            }
            // If more than 1 item shares the same parent, we treat it as a Kit bundle
            if (relatedCount > 1) isKit = true;
        }

        // 3. Execution Logic
        if (isKit) {
            // --- KIT DELETION LOGIC ---
            var confirmMsg = "This item is part of a Kit. Deleting it will remove all components of this Kit from the list. Do you want to proceed?";
            if (confirm(confirmMsg)) {

                console.log('LLIList bfr: ', JSON.stringify(LLIList));
                
                // A. Delete ALL Logistic Line Items associated with this Kit (Parent ID)
                var newLLIList = LLIList.filter(function(item) {
                    var pId = item.ERP7__Sales_Order_Line_Item__c || 
                              item.ERP7__Order_Product__c || 
                              item.ERP7__Purchase_Line_Items__c;
                    return pId !== parentId; // Keep only items that DO NOT match the Kit's Parent ID
                });
                component.set("v.LLIList", newLLIList);
                
                // C. UI Refresh
                component.set("v.reRenderLogisticTable", false);
                component.set("v.reRenderLogisticTable", true);
                
                // If list is empty, reset with a blank instance
                if (newLLIList.length === 0) {
                    helper.getLLIDeleteSingle(component, event, helper);
                }
                
                console.log('LLIList after: ', JSON.stringify(component.get("v.LLIList")));
            }
        } 
        else {
            // --- EXISTING STANDARD DELETE LOGIC ---
            var deleteconfirm = confirm($A.get('$Label.c.Do_you_want_to_Delete_Item'));
            if (deleteconfirm) {
                console.log('LLIList bfr: ', JSON.stringify(LLIList));
                // Delete single item by index
                LLIList.splice(index, 1);
                
                component.set("v.LLIList", LLIList);
                component.set("v.reRenderLogisticTable", false);
                component.set("v.reRenderLogisticTable", true);
                
                if (LLIList.length === 0) {
                    component.set("v.LLIList", []);
                    helper.getLLIDeleteSingle(component, event, helper);
                }

                console.log('LLIList after: ', JSON.stringify(component.get("v.LLIList")));
                
                // Toggle tabs to force refresh (Original Logic)
                if (component.get("v.selectedTab") == 'log') {
                    component.set("v.selectedTab", 'soli');
                    component.set("v.selectedTab", 'log');
                } else if (component.get("v.selectedTab") == 'soli') {
                    component.set("v.selectedTab", 'log');
                    component.set("v.selectedTab", 'soli');
                }
            }
        }
    },
    
    addLLI: function(component, event, helper){
        var action = component.get("c.getLLIInstance");     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {  
                var LLIList=[]; LLIList=component.get("v.LLIList");
                LLIList.push(response.getReturnValue());           
                component.set("v.LLIList",LLIList);
                
            }         
        });
        $A.enqueueAction(action);    
        
    },
    
    createLogistic:function(component,event,helper){
        console.log('in create logistic ');
        helper.createLogistic(component,event,helper);
    },
    
   /* verifyQuantity:function(component,event,helper){
        
        component.set("v.QuantityErrorMsg",'');  
        
        var Index=event.getSource().get("v.name"); 
        var SoliList =[]; SoliList=component.get("v.SoliList");
        var OrdItemList =[]; OrdItemList=component.get("v.OrdItemList");
        var POItemList =[]; POItemList=component.get("v.POItemList");
        
        var LLIList =[]; LLIList=component.get("v.LLIList"); 
        var lliRecord=LLIList[Index]; 
        var soliRecord; 
        for(var i in SoliList){ 
            if(SoliList[i].Id==lliRecord.ERP7__Sales_Order_Line_Item__c) soliRecord=SoliList[i];          
        }  
        
        var ordItRecord;
        for(var i in OrdItemList){
            if(OrdItemList[i].Id==lliRecord.ERP7__Order_Product__c) ordItRecord=OrdItemList[i];
        }
        var POLIRecord;
        for(var i in POItemList){
            if(POItemList[i].Id==lliRecord.ERP7__Purchase_Line_Items__c) POLIRecord=POItemList[i];
        }
        
        var elems=[]; elems=component.find('loliQuantityIds');
        var elem; if(elems.length>1) elem=elems[Index]; else elem=elems;
        
        var AQuantity;
        if(component.get('v.SOId') != ''){
            AQuantity=soliRecord.ERP7__Quantity__c-soliRecord.ERP7__Logistic_Quantity__c; //ERP7__Reserved_Quantity__c 
        }  
        if(component.get('v.orderId') != ''){
            AQuantity = ordItRecord.ERP7__Remaining_Quantity__c; //ordItRecord.Quantity-ordItRecord.ERP7__Logistic_Quantity__c;
        }
        if(component.get('v.POId') != ''){
            AQuantity=POLIRecord.ERP7__Quantity__c-POLIRecord.ERP7__Logistic_Quantity__c;
        }
        
        if(lliRecord.ERP7__Quantity__c>AQuantity){
            elem.set("v.class",'hasError');
            component.set("v.QuantityErrorMsg",$A.get('$Label.c.Given_quantity_is_not_available')); // on stock
            
            sforce.one.showToast({
                "title": $A.get('$Label.c.warning_UserAvailabilities'),
                "message": $A.get('$Label.c.Given_quantity_is_not_available'),
                "type": "warning"
            });
            
            
            //helper.showToast('dismissible','', 'Error', 'Given quantity is not available',component); //on stock  
        }      
        
        else if(lliRecord.ERP7__Quantity__c<=0) {
            component.set("v.QuantityErrorMsg",$A.get('$Label.c.Invalid_Quantity')); 
            sforce.one.showToast({
                "title": $A.get('$Label.c.warning_UserAvailabilities'),
                "message": $A.get('$Label.c.Invalid_Quantity'),
                "type": "warning"
            });
            //helper.showToast('dismissible','', 'Error', 'Invalid Quantity',component);  
            elem.set("v.class",'hasError');  
        }else{ 
            elem.set("v.class",''); 
            component.set("v.QuantityErrorMsg",''); 
        }
        
    }, */
    verifyQuantity: function(component, event, helper) {
    component.set("v.QuantityErrorMsg", '');
    var Index = event.getSource().get("v.name");
    var SoliList = component.get("v.SoliList");
    var OrdItemList = component.get("v.OrdItemList");
    var POItemList = component.get("v.POItemList");
    var LLIList = component.get("v.LLIList");
    var lliRecord = LLIList[Index];
    var soliRecord;
    for (var i in SoliList) {
        if (SoliList[i].Id == lliRecord.ERP7__Sales_Order_Line_Item__c) soliRecord = SoliList[i];
    }
    var ordItRecord;
    for (var i in OrdItemList) {
        if (OrdItemList[i].Id == lliRecord.ERP7__Order_Product__c) ordItRecord = OrdItemList[i];
    }
    var POLIRecord;
    for (var i in POItemList) {
        if (POItemList[i].Id == lliRecord.ERP7__Purchase_Line_Items__c) POLIRecord = POItemList[i];
    }
    var elems = component.find('loliQuantityIds');
    var elem = (elems.length > 1) ? elems[Index] : elems;
    var AQuantity;
    var isKit = false;

    if (component.get('v.SOId') != '') {
        AQuantity = soliRecord.ERP7__Quantity__c - soliRecord.ERP7__Logistic_Quantity__c;
        isKit = soliRecord.Product2 && soliRecord.Product2.ERP7__Is_Kit__c;
    } else if (component.get('v.orderId') != '') {
        AQuantity = ordItRecord.ERP7__Remaining_Quantity__c;
        isKit = ordItRecord.Product2 && ordItRecord.Product2.ERP7__Is_Kit__c;
    } else if (component.get('v.POId') != '') {
        AQuantity = POLIRecord.ERP7__Quantity__c - POLIRecord.ERP7__Logistic_Quantity__c;
        isKit = POLIRecord.Product2 && POLIRecord.Product2.ERP7__Is_Kit__c;
    }

    if (!isKit) {
        if (lliRecord.ERP7__Quantity__c > AQuantity) {
            elem.set("v.class", 'hasError');
            component.set("v.QuantityErrorMsg", $A.get('$Label.c.Given_quantity_is_not_available'));
            sforce.one.showToast({
                "title": $A.get('$Label.c.warning_UserAvailabilities'),
                "message": $A.get('$Label.c.Given_quantity_is_not_available'),
                "type": "warning"
            });
        } else if (lliRecord.ERP7__Quantity__c <= 0) {
            component.set("v.QuantityErrorMsg", $A.get('$Label.c.Invalid_Quantity'));
            sforce.one.showToast({
                "title": $A.get('$Label.c.warning_UserAvailabilities'),
                "message": $A.get('$Label.c.Invalid_Quantity'),
                "type": "warning"
            });
            elem.set("v.class", 'hasError');
        } else {
            elem.set("v.class", '');
            component.set("v.QuantityErrorMsg", '');
        }
    } else {
        elem.set("v.class", '');
        component.set("v.QuantityErrorMsg", '');
    }
},
    
    showLogisticRecordDetailsPage:function(component,event,helper){ 
        var recordId = event.target.dataset.record;  
        component.set("v.nameUrl",'/'+recordId); 
    },
    
    parentFieldChange : function(component, event, helper) {
        var controllerValue =  component.get("v.Logistic.ERP7__Shipment_type__c");//component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
        var pickListMap = component.get("v.depnedentFieldMap");
        console.log('parentFieldChange controllerValue : '+controllerValue);
        if (controllerValue != '' && controllerValue != null && controllerValue != undefined) {
            //get child picklist value
            
            //component.set("v.Logistic.ERP7__Shipment_type__c",controllerValue);
            var childValues = pickListMap[controllerValue];
            console.log('parentFieldChange childValues : ',JSON.stringify(childValues));
            var childValueList = [];
            //childValueList.push('');
            for (var i = 0; i < childValues.length; i++) {
                childValueList.push(childValues[i]);
            }
            // set the child list
            component.set("v.listDependingValues", childValueList);
            console.log('parentFieldChange listDependingValues : ',component.get("v.listDependingValues"));
            if(childValues.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
            }else{
                component.set("v.bDisabledDependentFld" , true); 
            }
        } else {
            var list = [];
            component.set("v.listDependingValues", list);
            component.set("v.bDisabledDependentFld" , true);
            console.log('setting ERP7__Shipment_type__c ERP7__Shipping_Preferences__c empty here');
            component.set("v.Logistic.ERP7__Shipment_type__c", '');
            component.set("v.Logistic.ERP7__Shipping_Preferences__c",'');
        }
        if(component.get("v.listDependingValues").length > 0){
            var listdependingValues = component.get("v.listDependingValues");
            console.log('parentFieldChange listdependingValues~>'+listdependingValues[0]);
            component.set("v.Logistic.ERP7__Shipping_Preferences__c",listdependingValues[0].value);
        }
        console.log('parentFieldChange v.Logistic.ERP7__Shipping_Preferences__c~>'+component.get("v.Logistic.ERP7__Shipping_Preferences__c"));
    },
    
    //Added by Arshad 26 Oct 23
    ReturnparentFieldChange : function(component, event, helper) {
        var controllerValue =  component.get("v.Logistic.ERP7__Shipment_type_Return__c");
        var pickListMap = component.get("v.RdepnedentFieldMap");
        console.log('ReturnparentFieldChange called controllerValue : '+controllerValue);
        if (controllerValue != '' && controllerValue != null && controllerValue != undefined) {
            //get child picklist value
            
            //component.set("v.Logistic.ERP7__Shipment_type__c",controllerValue);
            var childValues = pickListMap[controllerValue];
            console.log('ReturnparentFieldChange childValues : ',JSON.stringify(childValues));
            var childValueList = [];
            //childValueList.push('');
            for (var i = 0; i < childValues.length; i++) {
                childValueList.push(childValues[i]);
            }
            // set the child list
            component.set("v.RlistDependingValues", childValueList);
            console.log('ReturnparentFieldChange RlistDependingValues here: ',component.get("v.RlistDependingValues"));
            if(childValues.length > 0){
                component.set("v.RbDisabledDependentFld" , false);  
            }else{
                component.set("v.RbDisabledDependentFld" , true); 
            }
        } 
        else {
            var list = [];
            component.set("v.RlistDependingValues", list);
            component.set("v.RbDisabledDependentFld" , true);
            console.log('setting ERP7__Shipping_Preferences_Return__c empty here');
            //component.set("v.Logistic.ERP7__Shipment_type_Return__c", '');
            component.set("v.Logistic.ERP7__Shipping_Preferences_Return__c",'');
        }
        if(component.get("v.RlistDependingValues").length > 0){
            var RlistDependingValues = component.get("v.RlistDependingValues");
            console.log('ReturnparentFieldChange RlistDependingValues~>'+RlistDependingValues[0]);
            component.set("v.Logistic.ERP7__Shipping_Preferences_Return__c",RlistDependingValues[0].value);
        }
        console.log('ReturnparentFieldChange v.Logistic.ERP7__Shipping_Preferences_Return__c~>'+component.get("v.Logistic.ERP7__Shipping_Preferences_Return__c"));
    },
    
    closeError :function(component,event,helper){
      //  component.set(exceptionError,'');
      component.set("v.exceptionError", "");
         component.set("v.exceptionError1", "");
    },
    
    updateLogistic : function(component,event,helper){
        console.log('updateLogistic called');
         $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var err = false;
        var LLIList=[]; LLIList=component.get("v.LLIList");
        if(LLIList.length > 0){
            for(var x in LLIList){
                if(LLIList[x].ERP7__Quantity__c > LLIList[x].ERP7__Fulfilled_Quantity__c){
                    sforce.one.showToast({
                        "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                        "message": $A.get('$Label.c.Can_not_select_more_that_available_stock'),
                        "type": "error"
                    });
                    err =true;
                     $A.util.addClass(component.find('mainSpin'), "slds-hide");
                } 
            }
        }
        if(!err){
            component.set("v.Logistic.ERP7__Channel__c",component.get("v.channelId"));  
            component.set("v.Logistic.ERP7__Distribution_Channel__c",component.get("v.DistributeChannelId"));
            var Logistic=component.get("v.Logistic");  
            console.log('Logistic : ',JSON.stringify(Logistic));
            var LogisticJSON=JSON.stringify(Logistic); 
            var LLIList=[]; LLIList=component.get("v.LLIList");
            var LLIListJSON=JSON.stringify(LLIList); 
            var action = component.get("c.getUpdateLogistic");
            action.setParams({
                "LogisticJSON":LogisticJSON,
                "LLIListJSON":LLIListJSON
            });  
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {  
                    console.log('getCreateLogistic resp~>',response.getReturnValue());
                    
                    if(response.getReturnValue() != null){
                        if(response.getReturnValue().includes('STRING_TOO_LONG')){
                            sforce.one.showToast({
                                "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                                "message": $A.get('$Label.c.Logistic_name_should_not_exceed_80_characters'),
                                "type": "error"
                            });
                            $A.util.addClass(component.find('mainSpin'), "slds-hide");
                            return;
                        }
                    }                           
                    if(response.getReturnValue() == null){
                        sforce.one.showToast({
                            "title": $A.get('$Label.c.Success'),
                            "message": $A.get('$Label.c.Saved_Successfully'),
                            "type": "Success"
                        });
                        var RecUrl = "/lightning/r/ERP7__Logistic__c/" + component.get('v.LogId') + "/view";
                        window.open(RecUrl,'_parent'); 
                    }else{
                        sforce.one.showToast({
                            "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                            "message": response.getReturnValue(),
                            "type": "error"
                        });
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        return;
                    } 
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }else{
                    var error1=response.getError();
                    console.log('Error :',error1);
                    component.set('v.exceptionError',error1[0].message);
                    sforce.one.showToast({
                        "title": $A.get('$Label.c.Error_UsersShiftMatch'),
                        "message": error1[0].message,
                        "type": "error"
                    });
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }        
            });
            $A.enqueueAction(action);
        }
    },
    
    
})